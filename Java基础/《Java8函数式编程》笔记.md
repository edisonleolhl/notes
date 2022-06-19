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

  