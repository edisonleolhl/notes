# Java8 函数式编程

## Lambda表达式

- Lambda表达式可以简化匿名内部类

  普通的匿名内部类：在这个例子中，我们创建了一个新对象，它实现了ActionListener 接口。这个接口只有一个方法actionPerformed，当用户点击屏幕上的按钮时，button 就会调用这个方法。匿名内部类实现了该方法。

  ```java
  例2-1　使用匿名内部类将行为和按钮单击进行关联
  button.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent event) {
      System.out.println("button clicked");
    }
  });
  ```

  若用Lambda表达式，则可以化简，注意event不需要指定类型，后台可以根据addActionListener的函数签名推断event的类型

  ```java
  例2-2　使用Lambda 表达式将行为和按钮单击进行关联
  button.addActionListener(event -> System.out.println("button clicked"));
  ```

- 其他的Lambda例子

  ```java
  // ➊中所示的Lambda 表达式不包含参数，使用空括号() 表示没有参数。该Lambda 表达式实现了Runnable 接口，该接口也只有一个run 方法，没有参数，且返回类型为void
  Runnable noArguments = () -> System.out.println("Hello World"); 
  
  // ➋中所示的Lambda 表达式包含且只包含一个参数，可省略参数的括号，这和例2-2 中的形式一样。
  ActionListener oneArgument = event -> System.out.println("button clicked"); 
  
  // Lambda 表达式的主体不仅可以是一个表达式，而且也可以是一段代码块，使用大括号（{}）将代码块括起来，如➌所示
  Runnable multiStatement = () -> { 
    System.out.print("Hello");
    System.out.println(" World");
  };
  
  // Lambda 表达式也可以表示包含多个参数的方法，如➍所示，注意这该Lambda表达式是『创建』了两个数字相加的代码（或者叫函数），变量add的类型是BinaryOperator<Long>
  BinaryOperator<Long> add = (x, y) -> x + y; 

  // 如➎所示可以显式声明参数类型
  BinaryOperator<Long> addExplicit = (Long x, Long y) -> x + y; 
  ```

- Lambda表达式也叫闭包，未赋值的变量与周边环境隔离起来，进而被绑定到一个特定的值，所以，Lambda中被引用的不是变量，而是值，注意局部变量在**既成事实**上必须要是final的

  ```java
  // 例2-6　Lambda 表达式中引用既成事实上的final 变量
  String name = getUserName();
  button.addActionListener(event -> System.out.println("hi " + name));
  
  // 例2-7　未使用既成事实上的final 变量，导致无法通过编译
  String name = getUserName();
  name = formatUserName(name);
  button.addActionListener(event -> System.out.println("hi " + name));
  ```

- 函数接口

  函数接口是只有一个抽象方法的接口，用作Lambda 表达式的类型。

  使用只有一个方法的接口来表示某特定方法并反复使用，是很早就有的习惯，lambda用同样的技巧，并称之为『函数接口』

  ```java
  // 例2-8　ActionListener 接口：接受ActionEvent 类型的参数，返回空
  public interface ActionListener extends EventListener {
    public void actionPerformed(ActionEvent event);
  }
  ```

- 表2-1　Java中重要的函数接口
  
  接口 | 参数 | 返回类型 | 示例
  ---| ---|---|---
  Predicate<T> | T | boolean | 这张唱片已经发行了吗
  Consumer<T> | T | void | 输出一个值
  Function<T,R>|  T | R | 获得Artist 对象的名字
  Supplier<T> | None | T | 工厂方法
  UnaryOperator<T> | T | T | 逻辑非（ !）
  BinaryOperator<T> | (T, T) | T  | 求两个数的乘积（ *）

- 类型推断

  菱形操作符

  ```java
  // 例2-9　使用菱形操作符，根据变量类型做推断
  Map<String, Integer> oldWordCounts = new HashMap<String, Integer>(); // 明确指定
  Map<String, Integer> diamondWordCounts = new HashMap<>(); // 编译器类型推断
  // 例2-10　使用菱形操作符，根据方法签名做推断
  private void useHashmap(Map<String, String> values);
  useHashmap(new HashMap<>()); // 类型推断，注意在Java7无法通过编译
  ```

  Predicate函数接口，看下源码与用法就知道是咋回事了，Lambda表达式实现了Predicate函数接口，重写了其抽象方法test，重写后的方法体就是`return x > 5；`

  ```java
  public interface Predicate<T> {
    boolean test(T t);
  }
  Predicate<Integer> atLeast5 = x -> x > 5;
  ```

  推断系统虽然很智能，但需要一定的信息

  ```java
  // 例2-13　略显复杂的类型推断
  BinaryOperator<Long> addLongs = (x, y) -> x + y;
  // 没有泛型，代码则通不过编译
  BinaryOperator add = (x, y) -> x + y;
  // 报错：Operator '& #x002B;' cannot be applied to java.lang.Object, java.lang.Object.
  ```

- 习题

  ```java
  // 以如下方式重载check 方法后，还能正确推断出check(x -> x > 5) 的类型吗？
  // No - the lambda expression could be inferred as IntPred or Predicate<Integer> so the overload is ambiguous.
  interface IntPred {
  boolean test(Integer value);
  }
  boolean check(Predicate<Integer> predicate);
  boolean check(IntPred predicate);
  ```

## 流（Stream）

- 从外部迭代到内部迭代

  最开始，我们习惯用for循环遍历，或者拿到集合的迭代器，执行hasNext()与next()方法进行遍历操作，但是这都是在集合的外部进行遍历的，而流可以让迭代在集合的内部进行，Stream 是用函数式编程方式在集合类上进行复杂操作的工具。

  ```java
  // 例3-1　使用for 循环计算来自伦敦的艺术家人数
  int count = 0;
  for (Artist artist : allArtists) {
    if (artist.isFrom("London")) {
      count++;
    }
  }
  // 例3-2　使用迭代器计算来自伦敦的艺术家人数
  int count = 0;
  Iterator<Artist> iterator = allArtists.iterator();
  while(iterator.hasNext()) {
    Artist artist = iterator.next();
    if (artist.isFrom("London")) {
      count++;
    }
  }
  // 例3-3　使用内部迭代计算来自伦敦的艺术家人数
  long count = allArtists.stream()
      .filter(artist -> artist.isFrom("London"))
      .count();
  ```

- 实现机制：看上去流操作将集合遍历拆分成了『过滤+计数』，但实际上仍只需要一次循环

  像filter这样只描述stream，但是不产生新集合的方法叫做**惰性求值方法**，像count 这样最终会从Stream 产生值的方法叫作**及早求值方法**

  ```java
  // 例3-5　由于使用了惰性求值，没有输出艺术家的名字
  allArtists.stream()
    .filter(artist -> {
      System.out.println(artist.getName());
      return artist.isFrom("London");
  });
  // 例3-6　输出艺术家的名字
  long count = allArtists.stream()
    .filter(artist -> {
        System.out.println(artist.getName());
        return artist.isFrom("London");
    })
    .count();
  ```

  使用这些操作的理想方式就是形成一个惰性求值的链，最后用一个及早求值的操作返回想要的结果，有点像建造者模式，最后调用build方法时，对象才会真正创建

- 常用的流操作

  collect(toList()) 方法由Stream 里的值生成一个列表，是一个及早求值操作。

  ```java
  List<String> collected = Stream.of("a", "b", "c") 
    .collect(Collectors.toList()); 
  assertEquals(Arrays.asList("a", "b", "c"), collected); 
  ```

  map 方法，从一个流的值转换成一个新的流，传给map 的Lambda 表达式只接受一个String 类型的参数，返回一个新的String。参数和返回值不必属于同一种类型，但是Lambda 表达式必须是Function 接口的一个实例（`Function<T,R>`），是惰性求值

  ```java
  // 例3-9　使用map 操作将字符串转换为大写形式
  List<String> collected = Stream.of("a", "b", "hello")
    .map(string -> string.toUpperCase()) 􀁮
    .collect(toList());
  assertEquals(asList("A", "B", "HELLO"), collected);
  ```

  filter，保留stream中的一些元素，而过滤掉其他的，是惰性求值，传给filter的Lambda表达式的函数接口正是Predicat
  
  ```java
  // 例3-11　函数式风格
  List<String> beginningWithNumbers = Stream.of("a", "1abc", "abc1")
    .filter(value -> isDigit(value.charAt(0)))
    .collect(toList());
  ```

  flatMap：有时，用户希望让map操作有点变化，生成一个新的Stream 对象取而代之。用户通常不希望结果是一连串的流，此时flatMap 最能派上用场。Lambda函数接口与map的一样，都是Function，只是方法的返回值限定为Stream类型

  ```java
  // 例3-12　包含多个列表的Stream
  List<Integer> together = Stream.of(asList(1, 2), asList(3, 4))
      .flatMap(numbers -> numbers.stream())
      .collect(toList());
  assertEquals(asList(1, 2, 3, 4), together);
  ```

  max和min

  ```java
  // 例3-13　使用Stream 查找最短曲目
  List<Track> tracks = asList(new Track("Bakai", 524),
      new Track("Violets for Your Furs", 378),
      new Track("Time Was", 451));
  Track shortestTrack = tracks.stream()
      .min(Comparator.comparing(track -> track.getLength()))
      .get();
  assertEquals(tracks.get(1), shortestTrack);
  ```

  reduce 操作可以实现从一组值中生成一个值。在上述例子中用到的count、min 和max 方法，因为常用而被纳入标准库中。事实上，这些方法都是reduce 操作。

  ```java
  T reduce(T identity, BinaryOperator<T> accumulator);
  // 例3-16　使用reduce 求和，这段求和代码不适合在生产环境中，仅作示例
  int count = Stream.of(1, 2, 3)
      .reduce(0, (acc, element) -> acc + element);
  assertEquals(6, count);
  // 例3-17　展开reduce 操作
  BinaryOperator<Integer> accumulator = (acc, element) -> acc + element;
  int count = accumulator.apply(
      accumulator.apply(
          accumulator.apply(0, 1),
          2),
      3);
  ```

- 习题

  ```java
  // 编写一个函数，接受艺术家列表作为参数，返回一个字符串列表，其中包含艺术家的姓名和国籍（可重复）；
  // 我的丑陋写法。。
  List<String> extract(List<Artist> artists) {
    return Stream.of(
      artists.stream().map(artist -> artist.getName()).collect(toList()),
      artists.stream().map(artist -> artist.getNationality()).collect(toList())
    ).flatMap(list -> list.stream()).collect(Collectors.toList());
  }
  // 标准答案，使用flatMap
  List<String> getNamesAndOrigins(List<Artist> artists) {
    return artists.stream()
      .flatMap(artist -> Stream.of(artist.getName(), artist.getNationality()))
      .collect(toList());
  }
  
  // 修改代码，将外部迭代变为内部迭代
  int totalMembers = 0;
  for (Artist artist : artists) {
    Stream<Artist> members = artist.getMembers();
    totalMembers += members.count();
  }
  // 标准答案
  int countBandMembersInternal(List<Artist> artists) {
        // NB: readers haven't learnt about primitives yet, so can't use the sum() method
        return artists.stream()
                       .map(artist -> artist.getMembers().count())
                       .reduce(0L, Long::sum)
                       .intValue();
  
  // 计算一个字符串中小写字母的个数（提示：参阅String 对象的chars 方法）。s
  public static int countLower(String str) {
    return (int) str.chars().filter(x -> x >= 'a' && x <= 'z').count();
  //        return (int) string.chars()
  //                           .filter(Character::isLowerCase)
  //                           .count();
  }
  
  // 在一个字符串列表中，找出包含最多小写字母的字符串。对于空列表，返回Optional<String> 对象。
  // 我的写法，因为comparing方法要传入Function函数接口，所以得先创建一个
  public static Function<String, Integer> countLowerFunc() {
    return str -> {
      return Math.toIntExact(str.chars().filter(x -> x >= 'a' && x <= 'z').count());
    };
  }
  public static Optional<String> findMostLowerCaseString(ArrayList<String> strList) {
    return strList.stream().
        max(Comparator.comparing(countLowerFunc()));
  }
  // 标准答案，comparingInt接收一个toIntFunction，所以可以复用上面的countLower函数
  public static Optional<String> mostLowercaseString(List<String> strings) {
    return strings.stream()
      .max(Comparator.comparingInt(StreamTest::countLower));
  }
  ```

## 类库

- 在代码中使用Lambda表达式

  ```java
  // 例4-1　使用isDebugEnabled 方法降低日志性能开销
  Logger logger = new Logger();
  if (logger.isDebugEnabled()) {
  logger.debug("Look at this: " + expensiveOperation());
  }
  // 例4-2　使用Lambda 表达式简化日志代码
  Logger logger = new Logger();
  logger.debug(() -> "Look at this: " + expensiveOperation());
  // 例4-3　启用Lambda 表达式实现的日志记录器
  // 调用get() 方法，相当于调用传入的Lambda 表达式
  public void debug(Supplier<String> message) {
    if (isDebugEnabled()) {
      debug(message.get());
    }
  }
  ```

### 基本类型

- 由于装箱类型是对象，因此在内存中存在额外开销。比如，整型在内存中占用
4 字节，整型对象却要占用16 字节。

- 将基本类型转换为装箱类型，称为装箱，反之则称为拆箱，两者都需要额外的计算开销。对于需要大量数值运算的算法来说，装箱和拆箱的计算开销，以及装箱类型占用的额外内存，会明显减缓程序的运行速度。

- 为了减少开销，Stream对基本类型和装箱类型做了区分
  - 从T转为long：`toLongFunction<T, long>`
  - 接收long参数，返回T：`T LongFunction(long)`
  - 基本类型对应的Stream：`LongStream`

  ```java
  // 例4-4　使用summaryStatistics 方法统计曲目长度
  // mapToInt返回IntStream对象
  public static void printTrackLengthStatistics(Album album) {
  IntSummaryStatistics trackLengthStats
      = album.getTracks()
          .mapToInt(track -> track.getLength())
          .summaryStatistics();
  System.out.printf("Max: %d, Min: %d, Ave: %f, Sum: %d",
      trackLengthStats.getMax(),
      trackLengthStats.getMin(),
      trackLengthStats.getAverage(),
      trackLengthStats.getSum());
  }
  ```

### 重载解析

- 一般，Java会选择更具体的类型进行重载解析，比如String继承自Object

  ```java
  // 例4-5　方法调用
  overloadedMethod("abc");
  // 例4-6　两个重载方法可供选择，但最终会输出String
  private void overloadedMethod(Object o) {
    System.out.print("Object");
  }
  private void overloadedMethod(String s) {
    System.out.print("String");
  }
  ```

- Lambda表达式作为参数时，原则也差不多

  - 如果只有一个可能的目标类􀅖 型，由相应函数接口里的参数类型推导得出；
  - 如果有多个可能的目标类型，由最具体的类型推导得出；
  - 如果有多个可能的目标类型且最具体的类型不明确，则需人为指定类型。

### @FunctionalInterface

- 每个用作函数接口的接口都应该添加这个注释

- 该注释会强制javac 检查一个接口是否符合函数接口的标准。如果该注释添加给一个枚举
类型、类或另一个注释，或者接口包含不止一个抽象方法，javac 就会报错。重构代码时，
使用它能很容易发现问题。

### 默认方法

- 因为Java8对所有Collection接口增加了stream方法，在之前Java1~7编写的MyCustomList实现了Collection接口，也必须要增加了stream方法才行，这打破了兼容性

- 默认方法正是为了解决这个情况而产生的，：Collection 接口告诉它所有的子类：
“如果你没有实现stream 方法，就使用我的吧。”接口中这样的方法叫作**默认方法**，在任何接口中，无论函数接口还是非函数接口，都可以使用该方法。

  ```java
  // 例4-10　默认方法示例：forEach 实现方式
  default void forEach(Consumer<? super T> action) {
    for (T t : this) {
      action.accept(t);
    }
  }
  ```

- 接口没有成员变量，所以默认方法只能通过调用子类的方法来修改子类本身

### 多重继承

- 接口允许多重继承，如果一个类继承的两个接口中有同名的默认方法，编译器就不知道继承哪个，于是报错

- 重载同名的默认方法即可解决该问题，下面的代码使用了增强的super方法，用来指明接口Carriage中定义的默认方法

  ```java
  // 例4-21　实现rock 方法
  public class MusicalCarriage
  implements Carriage, Jukebox {
    @Override
    public String rock() {
      return Carriage.super.rock();
    }
  }
  ```

### Optional

- Optional 是为核心类库新设计的一个数据类型，用来替换null 值，最大的用处是：**避免NPE！！！**

- 使用方法

  - 使用Optional 对象的方式之一是在调用get() 方法前，先使用isPresent 检查Optional对象是否有值。
  - 使用orElse 方法则更简洁，当Optional 对象为空时，该方法提供了一个备选值。
  - 如果计算备选值在计算上太过繁琐，即可使用orElseGet 方法。该方法接受一个
  Supplier 对象，只有在Optional 对象真正为空时才会调用

- 示例

  ```java
  // 创建某个值的Optional 对象
  Optional<String> a = Optional.of("a");
  assertEquals("a", a.get());
  // 创建空Optional对象
  Optional emptyOptional = Optional.empty();
  // 从null值创建Optional对象
  Optional alsoEmpty = Optional.ofNullable(null);
  // 例4-24　使用orElse 和orElseGet 方法
  assertEquals("b", emptyOptional.orElse("b"));
  assertEquals("c", emptyOptional.orElseGet(() -> "c"));
  ```

- 习题

  ```java


## 高级集合类和收集器

### 方法引用

- `artist -> artist.getName()`可以用`Artist::getName`代替，这就是方法引用，构造函数可以用`Artist::new`

### 元素顺序

- Stream不会主动去排序，只会按元素的出现顺序按序处理，大多数操作都是在有序流上效率更高，比如filter、map和reduce

- 使用并行流时，forEach方法不能保证元素是按顺序处理的，请用forEachOrdered方法

### 收集器

- 这就是收集器，一种通用的、从流生成复杂值的结构。只要将它传给collect 方法，所有的流就都可以使用它了。

- 常见的，如toList、toSet、toMap

- 有时想用TreeSet，但不想由框架在背后自动为我指定一种Set，可以使用`stream.collect(toCollection(TreeSet::new));`

- 转换成值：还可以利用收集器让流生成一个值。maxBy 和minBy 允许用户按某种特定的顺序生成一个值

  ```java
  // 例5-6　找出成员最多的乐队
  public Optional<Artist> biggestGroup(Stream<Artist> artists) {
    Function<Artist,Long> getCount = artist -> artist.getMembers().count();
    return artists.collect(maxBy(comparing(getCount)));
  }
  // 例5-7　找出一组专辑上曲目的平均数
  public double averageNumberOfTracks(List<Album> albums) {
    return albums.stream()
        .collect(averagingInt(album -> album.getTrackList().size()));
  }
  ```

- 数据分块，以划分代替两次过滤，它使用Predicate 对象判断一个元素应该属于哪个部分，并根据布尔值返回一个Map 到列表。

  ```java
  // 例5-8　将艺术家组成的流分成乐队和独唱歌手两部分
  public Map<Boolean, List<Artist>> bandsAndSolo(Stream<Artist> artists) {
  return artists.collect(partitioningBy(artist -> artist.isSolo()));
  }
  ```

- 数据分组，更加自然的划分操作，使用任意值对数据分组，很像SQL的group by

  ```java
  // 例5-10　使用主唱对专辑分组
  public Map<Artist, List<Album>> albumsByArtist(Stream<Album> albums) {
  return albums.collect(groupingBy(album -> album.getMainMusician()));
  }
  ```

- 字符串：有些时候使用Stream是为了得到一个最后的字符串，可以使用

  ```java
  // 例5-12　使用流和收集器格式化艺术家姓名，参数分别是(分隔符，前缀，后缀)
  String result =
      artists.stream()
          .map(Artist::getName)
          .collect(Collectors.joining(", ", "[", "]"));
  ```

- 数据分组并计数：效果等同于SQL的groupby + count

  ```java
  // 例5-14　使用收集器计算每个艺术家的专辑数
  public Map<Artist, Long> numberOfAlbums(Stream<Album> albums) {
    return albums.collect(groupingBy(album -> album.getMainMusician(), counting());
    }
  ```

- mapping允许在收集器的容器上执行类似map的操作，但是需要指明什么样的集合类存储结果，比如toList

  ```java
  // 例5-16　使用收集器求每个艺术家的专辑名
  public Map<Artist, List<String>> nameOfAlbums(Stream<Album> albums) {
    return albums.collect(groupingBy(Album::getMainMusician, mapping(Album::getName, toList())));
  }
  ```

- 重构和定制收集器：如果想打印Artist列表的艺术家名字

  ```java
  // 例5-20　使用reduce 和StringCombiner 类格式化艺术家姓名
  String combined =
      artists.stream()
      .map(Artist::getName)
      .reduce(new StringCombiner(", ", "[", "]"),
        StringCombiner::add,
        StringCombiner::merge)
      .ToString();
  // 例5-21　add 方法返回连接新元素后的结果
  public StringCombiner add(String element) {
    if (areAtStart()) {
        builder.append(prefix);
      } else {
        builder.append(delim);
      }
      builder.append(element);
    }
    return this;
  }
  // 例5-22　merge 方法连接两个StringCombiner 对象
  public StringCombiner merge(StringCombiner other) {
    builder.append(other.builder);
    return this;
  }
  ```

- 将上述的reduce操作重构成一个收集器，会很好复用

  ```java
  // 例5-24　使用定制的收集器StringCollector 收集字符串
  String result =
      artists.stream()
          .map(Artist::getName)
          .collect(new StringCollector(", ", "[", "]"));
  ```

- 出于教学目的，编写这样的收集器，St ringCollector支持泛型，待收集元素、累加器类型、最终结果类型，已字符串为例，

  ```java
  public class StringCollector implements Collector<String, StringCombiner, String> {
    // 工厂方法，用来创建容器
    public Supplier<StringCombiner> supplier() {
      return () -> new StringCombiner(delim, prefix, suffix);
    }
  
    // accumulator 是一个函数，它将当前元素叠加到收集器
    public BiConsumer<StringCombiner, String> accumulator() {
      return StringCombiner::add;
    }
  
    // combiner 合并两个容器
    public BinaryOperator<StringCombiner> combiner() {
      return StringCombiner::merge;
    }
  
    // finisher 方法返回收集操作的最终结果
    public Function<StringCombiner, String> finisher() {
      return StringCombiner::toString;
    }
  }；

### 一些细节

- Lambda表达式，对Map的改变，比如缓存不存在时读db

  ```java
  // 例5-32　使用computeIfAbsent 缓存
  public Artist getArtist(String name) {
    return artistCache.computeIfAbsent(name, this::readArtistFromDB);
  }

  // 例5-34　使用内部迭代遍历Map 里的值
  Map<Artist, Integer> countOfAlbums = new HashMap<>();
  albumsByArtist.forEach((artist, albums) -> {
    countOfAlbums.put(artist, albums.size());
  });
  ```

- 习题

  ```java
  // 使用Map 的computeIfAbsent 方法高效计算斐波那契数列。这里的“高效”是指避免将那些较小的序列重复计算多次。
  public class Fibonacci {
  
      private final Map<Integer,Long> cache;
  
      public Fibonacci() {
          cache = new HashMap<>();
          cache.put(0, 0L);
          cache.put(1, 1L);
      }
  
      public long fibonacci(int x) {
          return cache.computeIfAbsent(x, n -> fibonacci(n-1) + fibonacci(n-2));
      }
  
  }
  ```

## 数据并行化

- 如果已经有一个Stream 对象， 调用它的parallel 方法就能让其拥有并行操作的能力。如果想从一个集合类创建一个流，调用parallelStream 就能立即获得一个拥有并行能力的流。

  ```java
  // 例6-1　串行化计算专辑曲目长度
  public int serialArraySum() {
    return albums.stream()
      .flatMap(Album::getTracks)
      .mapToInt(Track::getLength)
      .sum();
  }
  // 例6-2　并行化计算专辑曲目长度
  public int parallelArraySum() {
    return albums.parallelStream()
      .flatMap(Album::getTracks)
      .mapToInt(Track::getLength)
      .sum();
  }

- 限制:

  - 串行调用reduce 方法，初始值可以为任意值，为了让其在并行化时能工作正常，初值必须为组合函数的恒等值。比如加法中0为恒等值，乘法中1为恒等值
  - reduce 操作的另一个限制是组合操作必须符合结合律
  - 避免持有锁

- 性能：

  - 数据大小：输入数据的大小会影响并行化处理对性能的提升。将问题分解之后并行化处理，再将结果合并会带来额外的开销。因此只有数据足够大、每个数据处理管道花费的时间足够多时，并行化处理才有意义
  - 源数据结构：最好是易于拆分的，如数组
  - 装箱：处理基本类型比处理装箱类型要快。
  - 多核CPU：显然，只有一个CPU，并行完全没用
  - 处理每个元素所花的时间：一般来说，处理每个元素花的时间越多，并行化收益越大

- 并行流框架，基于分解与合并，所以分解数据源的效率很重要

  - ArrayList、数组或IntStream.range，这些数据结构支持随机读取，也就是说它们能轻而易举地被任意分解。
  - HashSet、TreeSet，这些数据结构不易公平地被分解，但是大多数时候分解是可能的。
  - 可能要花O(N) 的时间复杂度来分解问题。其中包括LinkedList，对半分解太难了。还有Streams.iterate 和BufferedReader.lines，它们长度未知，因此很难预测该在哪里分解。

- 如果能避开有状态，选用无状态操作，就能获得更好的并行性能。无状态操作包括map、filter 和flatMap，有状态操作包括sorted、distinct 和limit。

- 举例，并行化计算滑动平均数

  ```java
  public static double[] simpleMovingAverage(double[] values, int n) {
    double[] sums = Arrays.copyOf(values, values.length); // 并行操作会改变数组，所以先拷贝一份
    Arrays.parallelPrefix(sums, Double::sum); // 并行流操作，sums保存了求和结果
    int start = n - 1;
    return IntStream.range(start, sums.length) 􀁰
        .mapToDouble(i -> {
            double prefix = (i == start ? 0 : sums[i - n]);
            return (sums[i] - prefix) / n; // 总和减去窗口起始值，再除以n得到平均
        })
        .toArray(); 
  }
  ```

## 测试、调试和重构

- Lambda化可以有效的实践DRY原则，充分复用

  ```java
    // 例7-5　Order 类的命令式实现
    public long countRunningTime() {
        long count = 0;
        for (Album album : albums) {
            for (Track track : album.getTrackList()) {
                count += track.getLength();
            }
        }
        return count;}
    public long countMusicians() {
        long count = 0;
        for (Album album : albums) {
            count += album.getMusicianList().size();
        }
        return count;
    }
    public long countTracks() {
        long count = 0;
        for (Album album : albums) {
            count += album.getTrackList().size();
        }
        return count;
    }

    // 例7-7　使用领域方法重构Order 类
    public long countFeature(ToLongFunction<Album> function) {
        return albums.stream()
          .mapToLong(function)
          .sum();
    }
    public long countTracks() {
        return countFeature(album -> album.getTracks().count());
    }
    public long countRunningTime() {
        return countFeature(album -> album.getTracks()
          .mapToLong(track -> track.getLength())
          .sum());
    }
    public long countMusicians() {
        return countFeature(album -> album.getMusicians().count());
    }
    ```
  
- Lambda表达式的单元测试，因为Lambda表达式没有名字，不能直接调用，而从源代码复制Lambda表达式到测试代码中，又太松散，可以使用**方法引用**，然后单独测试方法

  ```java
  例7-10　将列表中元素的第一个字母转换成大写
  public static List<String> elementFirstToUpperCaseLambdas(List<String> words) {
    return words.stream()
      .map(value -> { 􀁮
        char firstChar = Character.toUpperCase(value.charAt(0));
        return firstChar + value.substring(1);
      })
      .collect(Collectors.<String>toList());
  }
  例7-12　将首字母转换为大写，应用到所有列表元素
  public static List<String> elementFirstToUppercase(List<String> words) {
    return words.stream()
      .map(Testing::firstToUppercase)
      .collect(Collectors.<String>toList());
  }
  public static String firstToUppercase(String value) { 􀁮
    char firstChar = Character.toUpperCase(value.charAt(0));
    return firstChar + value.substring(1);
  }
  ```

- 惰性求值和调试，流操作会让调试变得复杂

- 解决方案：peak，可以查看流中的每个值，同时能继续操作流

  ```java
  例7-18　使用peek 方法记录中间值
  Set<String> nationalities
    = album.getMusicians()
      .filter(artist -> artist.getName().startsWith("The"))
      .map(artist -> artist.getNationality())
      .peek(nation -> System.out.println("Found nationality: " + nation))
      .collect(Collectors.<String>toSet());
  ```

- 在peek方法中加入断点，就可以逐个调试流中的元素了

## 设计和架构的原则

- 观测不可变性和实现不可变性。观测不可变性是指在其他对象看来，该类是不可变的；实现不可变性是指对象本身不可变。实现不可变性意味着观测不可变性，反之则不一定成立。

- java.lang.String 宣称是不可变的，但事实上只是观测不可变，因为它在第一次调用 hashCode 方法时缓存了生成的散列值。在其他类看来，这是完全安全的，它们看不出散列值是每次在构造函数中计算出来的，还是从缓存中返回的

- 我们说不可变对象实现了开闭原则，是因为它们的内部状态无法改变，可以安全地为其增
加新的方法。新增加的方法无法改变对象的内部状态，因此对修改是闭合的；但它们又增
加了新的行为，因此对扩展是开放的