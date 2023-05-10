# Java

Java核心技术第十版源码：<https://github.com/deyou123/corejava>

与C++的不同

- Java中int永远是32位的，C++的int可能是16位、32位，也可能是编译器提供商指定的其他大小，唯一的限制是不能小于short int，不能大于long int

- Java中所有函数都属于某个类的方法（标准术语称其为方法，而不是成员函数

- 静态成员函数（static member function），这些函数定义在类的内部，并且不对对象进行操作，Java中的main方法必须是静态的

- Java的main方法没有为操作系统返回『退出代码』，若想返回非0值，则要调用System.exit方法

- Java没有无符号形式的int、long、short或btye类型，整形都是有包括负数的

- C++中的数值甚至指针都可以代替布尔值，非0值相当于布尔值的true，Java中整型值与布尔值不能相互转换

- C++会区分定义和声明，Java不会

- Java声明一个变量后，必须用赋值语句对变量进行显示初始化，千万不要使用未初始化的变量

- C++用const表示常量，Java用final表示常量，但是const仍然是Java中的保留字，只是没有使用

- 类常量，static final，放在类的定义中

- 与C或C++不同，Java不使用逗号运算符。不过，可以在for语句的第1和第3部分中使用逗号分隔表达式列表。

## 数据类型

### 浮点类型

- float：4字节，数值后面带f或F

- double：8字节，数值后面带d或D，或者不写（默认double）

- 如果在数值计算中不允许有任何误差，则应该用BigDecimal类，因为浮点类型用二进制表示，精度不够

### 特殊值

- Float.POSTIVE_INFINITY, Float.NEGATIVE_INFINITY, Float.NaN

- Double.POSTIVE_INFINITY, Double.NEGATIVE_INFINITY, Double.NaN

- 一个正整数除以0的结果是正无穷大（Double.POSTIVE_INFINITY），计算0/0或者负数的平方根的结果为NaN

### 强制类型转换

- 如果想对浮点数进行舍入运算，用Math.round(double)方法，但因为该方法返回long类型，如果自动转换可能会丢失精度，建议在前面加上(int)强制类型转换。

  ```java
  double x = 9.97;
  int nx = (int) Math.round(x);
  ```

- 如果试图将一个数值从一种类型强制转换为另一种类型，而又超出了目标类型的表示范围，结果就会截断成一个完全不同的值。例如，（byte）300的实际值为44。

### 二元赋值的强制类型转换

- 假设x为int，则`x += 3.5;`是合法的，等效于`x = (int) (x+3.5)`

### 条件运算符、三元运算符

- 如短路的if，三元运算符，均与C++保持一致

### 位运算符

- 四个位运算符：`&, |, ^, ~`。应用在布尔值上时，&和|运算符也会得到一个布尔值。这些运算符与&&和||运算符很类似，不过&和|运算符不采用"短路"方式来求值，也就是说，得到计算结果之前两个操作数都需要计算。

- 还有>>和<<运算符将位模式左移或右移，最后，>>>运算符会用0填充高位，这与>>不同，它会用符号位填充高位。不存在<<<运算符。

- 移位运算符的右操作数要完成模32的运算（除非左操作数是long类型，在这种情况下需要对右操作数模64）。例如，1<<35的值等同于1<<3或8。

- 在C/C++中，不能保证>>是完成算术移位（扩展符号位）还是逻辑移位（填充0）。实现者可以选择其中更高效的任何一种做法。这意味着C/C++>>运算符对于负数生成的结果可能会依赖于具体的实现。Java则消除了这种不确定性。

### 枚举类型

```java
enum Size {SMALL, MEDIUM, LARGE, EXTRA_LARGE};
```

### 字符串

- 从概念上讲，Java字符串就是Unicode字符序列

- Java没有内置的字符串类型，而是在标准Java类库中提供了一个预定义类，很自然地叫做String。每个用双引号括起来的字符串都是String类的一个实例

#### 子串

- String类的substring方法可以从一个较大的字符串提取出一个子串

- substring方法的第二个参数是不想复制的第一个位置。

- substring的工作方式有一个优点：容易计算子串的长度。字符串s.substring（a，b）的长度为b-a

  ```java
  String greeting = "Hello";
    String s = greeting.substring(0, 3); // 返回Hel
  ```

#### 拼接

- 与绝大多数的程序设计语言一样，Java语言允许使用+号连接（拼接）两个字符串。

- 当将一个字符串与一个非字符串的值进行拼接时，后者被转换成字符串

- 如果要组合多个字符串，用一个定界符分割，可以使用静态的join方法

  ```java
  String all = String.join(" / ", "S", "M", "L", "XL");
    // all is the string "S / M / L / XL"
  ```

#### 不可变字符串（与C/C++有较大差异）

- String类没有提供用于修改字符串的方法。如果希望将greeting的内容修改为"Help！"，不能直接地将greeting的最后两个位置的字符修改为'p'和'！'，这对于C/C++同学是非常不友好的，C++字符串是可修改的，也就是可以修改字符串的单个字符。其实Java修改字符串很简单，利用子串与拼接即可

  ```java
  greeting = greeting.substring(0, 3) + "p!";
  ```

- 由于不能修改Java字符串中的字符，所以在Java文档中将String类对象称为不可变字符串，如同数字3永远是数字3一样，字符串"Hello"永远包含字符H、e、l、l和o的代码单元序列，而不能修改其中的任何一个字符。当然，可以修改字符串变量greeting，让它引用另外一个字符串，这就如同可以将存放3的数值变量改成存放4一样。

- 粗看，通过拼接来创建新字符串看起来确实效率不高，不过不可变字符串有一个显而易见的优点：编译器可以字符串共享。可以想象将各种字符串存放在公共的存储池中。字符串变量指向存储池中相应的位置。如果复制一个字符串变量，原始字符串与复制的字符串共享相同的字符。

- 总而言之，Java的设计者认为共享带来的高效率远远胜过于提取、拼接字符串所带来的低效率。查看一下程序会发现：很少需要修改字符串，而是往往需要对字符串进行比较

- C++程序员可能会认为Java字符串是字符型数组：`char greeting[] = "Hello";`，这是错的，Java字符串大致类似于char_指针，`char* greeting = "Hello";`。

- 当用`Help!`替换Java字符串变量原有的`Hello`时，Java代码大致进行下列操作，那原来的`Hello`在内存就没有变量指向了，那岂不是会引起内存泄露呢？这在C中可能是个问题，但是Java有垃圾回收

  ```java
  char* temp = malloc(6);
    strncpy(temp, greeting, 3);
    strncpy(temp + 3, "p!", 3);
    greeting = temp;
  ```

#### 检测字符串是否相等

- 可以使用equals方法检测两个字符串是否相等，`boolean flag = s.equals(t);`，可以是字符串常量，也可以是字符串字面量，`"Hello".equals(greeting);`是合法的！

- equalsIgnoreCase()方法可以不区分大消息检测是否相等

- **一定不要使用==运算符检测了两个字符串是否相等，==是比较两者在内存的位置，两个字符串很有可能内容相同，但是在内存中地址不一样**

- C++可以放心地使用==字符串进行比较，**因为重载了==运算符以便检测字符串内存的相等性**，所以Java字符串变量其实很像是一个指向字符串常量的指针

- C程序员从不使用==进行字符串比较，而是使用strcmp，Java的compareTo方法与strcmp完全类似，`if (greeting.compareTo("Hello") == 0)`，但Java还是equals方法更加清晰一点

#### 空串与Null串

- 空串""是长度为0的字符串。可以调用以下代码检查一个字符串是否为空：`if (str.length() == 0)`或`if (str.equals(""))`，空串是一个Java对象，有自己的串长度（0）和内容（空）

- 不过，String变量还可以存放一个特殊的值，名为null，这表示目前没有任何对象与该变量关联，要检查一个字符串是否为null，要使用以下条件：`if (str == null)`

- 有时要检查一个字符串既不是null也不为空串，这种情况下就一定要两者结合使用，`if (str != null && str.length() != 0)`，判断顺序很重要，如果在一个null值上调用方法，将会出现错误

#### 码点与代码单元

- Java字符串由char值序列组成。从3.3.3节"char类型"已经看到，char数据类型是一个采用UTF-16编码表示Unicode码点的代码单元。大多数的常用Unicode字符使用一个代码单元就可以表示，而辅助字符需要一对代码单元表示。

- String的length方法将返回采用UTF-16编码表示的给定字符串所需要的代码单元数量

- 码点数量可以使用：`int cpCount = greeting.codePointCount(0, greeting.length());`

- 调用s.charAt（n）将返回位置n的代码单元，n介于0~s.length（）-1之间：`char first = greeting.charAt(0); // first is 'H'`

#### Java API

> java.lang.String

> 如果某个方法是在这个版本之后添加的，就会给出一个单独的版本号。

- `char charAt(int index)`

  返回给定位置的代码单元。除非对底层的代码单元感兴趣，否则不需要调用这个方法。

- `int codePointAt(int index)5.0`

  返回从给定位置开始的码点。

- `int offsetByCodePoints(int startIndex，int cpCount)5.0`

  返回从startIndex代码点开始，位移cpCount后的码点索引。

- `int compareTo(String other)`

  按照字典顺序，如果字符串位于other之前，返回一个负数；如果字符串位于other之后，返回一个正数；如果两个字符串相等，返回0。

- `IntStream codePoints()8`

  将这个字符串的码点作为一个流返回。调用toArray将它们放在一个数组中。

- `new String(int[]codePoints，int offset，int count)5.0`

  用数组中从offset开始的count个码点构造一个字符串。

- `boolean equals(Object other)`

  如果字符串与other相等，返回true。

- `boolean equalsIgnoreCase(String other)`

  如果字符串与other相等(忽略大小写)，返回true。

- `boolean startsWith(String prefix)`

- `boolean endsWith(String suffix)`

  如果字符串以suffix开头或结尾，则返回true。

- `int index0f(String str)`

- `int index0f(int cp)`

- `int index0f(int cp，int fromIndex)`

  返回与字符串str或代码点cp匹配的第一个子串的开始位置。这个位置从索引0或fromIndex开始计算。如果在原始串中不存在str，返回-1。

- `int lastIndex0f(String str)`

- `int lastIndex0f(String str，int fromIndex)`

- `int lastindex0f(int cp)`

- `int lastindex0f(int cp，int fromIndex)`

  返回与字符串str或代码点cp匹配的最后一个子串的开始位置。这个位置从原始串尾端或fromIndex开始计算。

- `int length()`

  返回字符串的长度。

- `int codePointCount(int startIndex，int endIndex)5.0`

  返回startIndex和endIndex-1之间的代码点数量。没有配成对的代用字符将计入代码点。

- `String replace(CharSequence oldString，CharSequence newString)`

  返回一个新字符串。这个字符串用newString代替原始字符串中所有的oldString。可以用String或StringBuilder对象作为CharSequence参数。

- `String substring(int beginIndex)`

- `String substring(int beginIndex，int endIndex)`

  返回一个新字符串。这个字符串包含原始字符串中从beginIndex到串尾或或endIndex–1的所有代码单元。

- `String toLowerCase（）`

- `String toUpperCase（）`

  返回一个新字符串。这个字符串将原始字符串中的大写字母改为小写，或者将原始字符串中的所有小写字母改成了大写字母。

- `String trim（）`

  返回一个新字符串。这个字符串将删除了原始字符串头部和尾部的空格。

- `String join（CharSequence delimiter，CharSequence...elements）8`

  返回一个新字符串，用给定的定界符连接所有元素。

#### StringBuilder类

- 每次连接字符串，都会构建一个新的String对象，既耗时，又浪费空间。使用StringBuilder类就可以避免这个问题的发生。

  ```java
  StringBuilder builder = new StringBuilder();
    builder.append(ch); // appends a single character
    builder.append(str); // appends a string
    String completedString = builder.toString(); // 最后获得String对象
  ```

- 在JDK5.0中引入StringBuilder类。这个类的前身是StringBuffer，其效率稍有些低，但允许采用多线程的方式执行添加或删除字符的操作。如果所有字符串在一个单线程中编辑（通常都是这样），则应该用StringBuilder替代它。这两个类的API是相同的。java.lang.StringBuilder 5.0

- `StringBuilder（）`

  构造一个空的字符串构建器。

- `int length（）`

  返回构建器或缓冲器中的代码单元数量。

- `StringBuilder append（String str）`

  追加一个字符串并返回this。

- `StringBuilder append（char c）`

  追加一个代码单元并返回this。

- `StringBuilder appendCodePoint（int cp）`

  追加一个代码点，并将其转换为一个或两个代码单元并返回this。

- `void setCharAt（int i，char c）`

  将第i个代码单元设置为c。

- `StringBuilder insert（int offset，String str）`

  在offset位置插入一个字符串并返回this。

- `StringBuilder insert（int offset，Char c）`

  在offset位置插入一个代码单元并返回this。

- `StringBuilder delete（int startIndex，int endIndex）`

  删除偏移量从startIndex到-endIndex-1的代码单元并返回this。

- `String toString（）`

  返回一个与构建器或缓冲器内容相同的字符串。

### 读取输入

Scanner类定义在java.util包中。当使用的类不是定义在基本java.lang包中时，一定要使用import指示字将相应的包加载进来

> 因为输入是可见的，所以Scanner类不适用于从控制台读取密码。Java SE 6特别引入了Console类实现这个目的

java.util.Scanner 5.0

- `Scanner（InputStream in）`

  用给定的输入流创建一个Scanner对象。

- `String nextLine（）`

  读取输入的下一行内容。

- `String next（）`

  读取输入的下一个单词（以空格作为分隔符）。

- `int nextInt（）`

- `double nextDouble（）`

  读取并转换下一个表示整数或浮点数的字符序列。

- `boolean hasNext（）`

  检测输入中是否还有其他单词。

- `boolean hasNextInt（）`

- `boolean hasNextDouble（）`

  检测是否还有表示整数或浮点数的下一个字符序列。

### 文件输入与输出

- 要想对文件进行读取，就需要一个用File对象构造一个Scanner对象，如下所示：`Scanner in = new Scanner(Paths.get("myfile.txt"), "UTF-8");`

  > 如果文件名中包含反斜杠符号，就要记住在每个反斜杠之前再加一个额外的反斜杠："c：\mydirectory\myfile.txt"。

- 要想写入文件，就需要构造一个PrintWriter对象。在构造器中，只需要提供文件名：`PrintWriter out = new PrintWriter("myfile.txt", "UTF-8");`，如果文件不存在，创建该文件。可以像输出到System.out一样使用print、println以及printf命令

### 控制流程

- Java的控制流程结构与C和C++的控制流程结构一样，只有很少的例外情况。没有goto语句，但break语句可以带标签，可以利用它实现从内层循环跳出的目的（这种情况C语言采用goto语句实现）

#### 块作用域

- 块（即复合语句）是指由一对大括号括起来的若干条简单的Java语句。块确定了变量的作用域。一个块可以嵌套在另一个块中

- 但是，不能在嵌套的两个块中声明同名的变量，否则会无法通过编译。在C++中，可以在嵌套的块中重定义一个变量。在内层定义的变量会覆盖在外层定义的变量。这样，有可能会导致程序设计错误，因此在Java中不允许这样做。

#### switch语句

- 在处理多个选项时，使用if/else结构显得有些笨拙。Java有一个与C/C++完全一样的switch语句。

- 编译代码时可以考虑加上-Xlint：fallthrough选项，`javac --Xlint：fallthrough Test.java`，这样一来，如果某个分支最后缺少一个break语句，编译器就会给出一个警告消息。

- case标签可以是：

  - 类型为char、byte、short或int的常量表达式。

  - 枚举常量。

  - 从Java SE 7开始，case标签还可以是字符串字面量

#### 中断控制流程语句

- 尽管Java的设计者将goto作为保留字，但实际上并没有打算在语言中使用它。通常，使用goto语句被认为是一种拙劣的程序设计风格。

- 与C++不同，Java还提供了一种带标签的break语句，用于跳出多重嵌套的循环语句。有时候，在嵌套很深的循环语句中会发生一些不可预料的事情。此时可能更加希望跳到嵌套的所有循环语句之外。通过添加一些额外的条件判断实现各层循环的检测很不方便。只能跳出语句块，而不能跳入语句块。

  ```java
  read_data:
    while () {
        ...
        for (...) {
            if (n < 1) {
                break read_data;
            }
        }
    }
  ```

- Java的continue同理

### 大数值

- 如果基本的整数和浮点数精度不能够满足需求，那么可以使用java.math包中的两个很有用的类：BigInteger和BigDecimal。这两个类可以处理包含任意长度数字序列的数值。BigInteger类实现了任意精度的整数运算，BigDecimal实现了任意精度的浮点数运算。

- 使用静态的valueOf方法可以将普通的数值转换为大数值：`BigInteger a = BigInteger.valueOf(100);`

- 遗憾的是，不能使用人们熟悉的算术运算符（如：+和*）处理大数值。而需要使用大数值类中的add和multiply方法。

- **与C++不同，Java没有提供运算符重载功能**。程序员无法重定义+和*运算符，使其应用于BigInteger类的add和multiply运算。Java语言的设计者确实为字符串的连接重载了+运算符，但没有重载其他的运算符，也没有给Java程序员在自己的类中重载运算符的机会。

API java.math.BigInteger 1.1

- `BigInteger add（BigInteger other）`

- `BigInteger subtract（BigInteger other）`

- `BigInteger multiply（BigInteger other）`

- `BigInteger divide（BigInteger other）`

- `BigInteger mod（BigInteger other）`

  返回这个大整数和另一个大整数other的和、差、积、商以及余数。

- `int compareTo（BigInteger other）`

  如果这个大整数与另一个大整数other相等，返回0；如果这个大整数小于另一个大整数other，返回负数；否则，返回正数。

- `static BigInteger valueOf（long x）`

  返回值等于x的大整数。

java.math.BigInteger 1.1

- `BigDecimal add（BigDecimal other）`

- `BigDecimal subtract（BigDecimal other）`

- `BigDecimal multiply（BigDecimal other）`

- `BigDecimal divide（BigDecimal other，RoundingMode mode）5.0`

  返回这个大实数与另一个大实数other的和、差、积、商。要想计算商，必须给出舍入方式（rounding mode）。RoundingMode.HALF_UP是在学校中学习的四舍五入方式（即，数值0到4舍去，数值5到9进位）。它适用于常规的计算。有关其他的舍入方式请参看API文档。

- `int compareTo（BigDecimal other）`

  如果这个大实数与另一个大实数相等，返回0；如果这个大实数小于另一个大实数，返回负数；否则，返回正数。

- `static BigDecimal valueOf（long x）`

- `static BigDecimal valueOf（long x，int scale）`

  cv返回值为x或x/10scale的一个大实数。

### 数组

- 数组是一种数据结构，用来存储同一类型值的集合。通过一个整型下标可以访问数组中的每一个值。例如，如果a是一个整型数组，a[i]就是数组中下标为i的整数。

- 创建一个数字数组时，所有元素都初始化为0。boolean数组的元素会初始化为false。对象数组的元素则初始化为一个特殊值null，这表示这些元素（还）未存放任何对象。

- 一旦创建了数组，就不能再改变它的大小（尽管可以改变每一个数组元素）。如果经常需要在运行过程中扩展数组的大小，就应该使用另一种数据结构----数组列表（array list）

  ```java
  int[] a; // 声明
    int[] a = new int[100]; // 这条语句创建了一个可以存储100个整数的数组，等同于C++的int *a = new int[100]；
    int len = a.length; // 获得数组中元素个数，注意length不是方法，而是成员变量
    int[] smallPrimes = {2, 3, 5, 7, 11, 13}; // 创建对象数组并初始化
    smallPrimes = new int[] {17, 19}; // 在不创建新变量的情况下重新初始化一个数组
  ```

- 在Java中，允许数组长度为0。在编写一个结果为数组的方法时，如果碰巧结果为空，则这种语法形式就显得非常有用。注意，数组长度为0与null不同。此时可以创建一个长度为0的数组：

  ```java
  new elementType[0]
  ```

#### foreach循环

- foreach循环定义一个变量用于暂存集合中的每一个元素，并执行相应的语句（当然，也可以是语句块）。collection这一集合表达式必须是一个数组或者是一个实现了Iterable接口的类对象（例如ArrayList）

  ```java
  for (variable : collection) statement
  ```

- for each循环语句显得更加简洁、更不易出错（不必为下标的起始值和终止值而操心）

- 有个更加简单的方式打印数组中的所有值，即利用Arrays类的toString方法。调用Arrays.toString（a），返回一个包含数组元素的字符串，这些元素被放置在括号内，并用逗号分隔，例如，"[2，3，5，7，11，13]

#### 数组拷贝

- 将一个数组变量拷贝给另一个数组变量。这时，两个变量将引用同一个数组：

  ```java
  int[] luckyNumbers = smallPrimes;
    luckNumbers[5] = 12; // now smallPrimes[5] is also 12
  ```

- 如果希望将所有值都拷贝到一个新的数组里面，则要使用Array类的copyOf方法，第二个参数是新数组的长度，如果长度更大，那么多余元素则赋值默认值，如果长度更小，则只拷贝前面的元素

  ```java
  int[] copiedLuckyNumbers = Arrays.copyOf(luckNumbers, luckNumbers.length);
  ```

#### 命令行参数

- 在Java应用程序的main方法中，程序名并没有存储在args数组中

  ```shell
  java Message -h world # args[0]是'-h'，而不是'Message'或'java'，args[1]是'world'
    Message -h world # C++可执行二进制文件，args[0]是`Message`
  ```

#### 数组API

java.util.Arrays 1.2

- `static String toString（type[]a）5.0`

  返回包含a中数据元素的字符串，这些数据元素被放在括号内，并用逗号分隔。

  参数：a 类型为int、long、short、char、byte、boolean、float或double的数组。

- `static type copyOf（type[]a，int length）6`

- `static type copyOfRange（type[]a，int start，int end）6`

  返回与a类型相同的一个数组，其长度为length或者end-start，数组元素为a的值。

  参数：a 类型为int、long、short、char、byte、boolean、float或double的数组。

  start 起始下标（包含这个值）。

  end 终止下标（不包含这个值）。这个值可能大于a.length。在这种情况下，结果为0或false。

  length 拷贝的数据元素长度。如果length值大于a.length，结果为0或false；否则，数组中只有前面length个数据元素的拷贝值。

- `static void sort（type[]a）`

  采用优化的快速排序算法对数组进行排序。

  参数：a 类型为int、long、short、char、byte、boolean、float或double的数组。

- `static int binarySearch（type[]a，type v）`

- `static int binarySearch（type[]a，int start，int end，type v）6`

  采用二分搜索算法查找值v。如果查找成功，则返回相应的下标值；否则，返回一个负数值r。-r-1是为保持a有序v应插入的位置。

  参数：a 类型为int、long、short、char、byte、boolean、float或double的有序数组。

  start 起始下标（包含这个值）。

  end 终止下标（不包含这个值）。

  v 同a的数据元素类型相同的值。

- `static void fill（type[]a，type v）`

  将数组的所有数据元素值设置为v。

  参数：a 类型为int、long、short、char、byte、boolean、float或double的数组。 v 与a数据元素类型相同的一个值。

- `static boolean equals（type[]a，type[]b）`

  如果两个数组大小相同，并且下标相同的元素都对应相等，返回true。

  参数：a、b 类型为int、long、short、char、byte、boolean、float或double的两个数组。

#### 多维数组

- 二维数组

  ```java
  double[][] balances; // 声明
    balances = new double[NYEARS][NRATES] // 初始化
    int[][] = magicSquare = { // 直接初始化
        {16,3,2,13},
        {5,10,,11,8},
        {9,6,7,12},
        {4,15,14,1}
    };
  ```

- for each循环语句不能自动处理二维数组的每一个元素。它是按照行，也就是一维数组处理的。要想访问二维数组a的所有元素，需要使用两个嵌套的循环，

- 要想快速地打印一个二维数组的数据元素列表，可以调用

  ```java
  System.out.println(Arrays.deepToString(a));
  ```

#### 不规则数组

- 实际上Java没有多维数组的概念，只有一维数组，多维数组可以理解为数组的数组

- Java的二维数组相当于C++的：

  ```c++
  double** balances = new double*[10]; // 一个包含是个指针的数组
    for (int i = 0; i < 10; i++) {
        balances = new double[6]; // 指针数组的每一个元素被填充了一个包含6个数字的数组
    }
  ```

## 对象和类

在Java中，只有基本类型（primitive types）不是对象，例如，数值、字符和布尔类型的值都不是对象。 所有的数组类型，不管是对象数组还是基本类型的数组都扩展了Object类。

### OOP与类

### 对象与对象变量

- `new Date()`表达式构造了一个新对象，构造的对象如果要多次使用，可以存放在一个变量中，`Data birthday = new Date();`

- 对象变量定义后，但没有引用具体的对象，所以调用该对象变量的方法将会编译报错，这时可以new一个对象初始化这个变量，也可以引用一个已存在的对象（变量），这时两个变量引用一个对象

- 一定要认识到：一个对象变量并没有实际包含一个对象，而仅仅引用一个对象。

- 在Java中，任何对象变量的值都是对存储在另外一个地方的一个对象的引用。new操作符的返回值也是一个引用

- 可以显式地将对象变量设置为null，表明这个对象变量目前没有引用任何对象。

- 如果将一个方法应用于一个值为null的对象上，那么就会产生运行时错误。局部变量不会自动地初始化为null，而必须通过调用new或将它们设置为null进行初始化

- Java中的对象引用其实相当于C++的对象指针，C++没有空引用。在Java中的null引用对应C++中的NULL指针。

- 所有的Java对象都存储在堆中。当一个对象包含另一个对象变量时，这个变量依然包含着指向另一个堆对象的指针。

- 在C++中，指针十分令人头疼，并常常导致程序错误。稍不小心就会创建一个错误的指针，或者造成内存溢出。在Java语言中，这些问题都不复存在。如果使用一个没有初始化的指针，运行系统将会产生一个运行时错误，而不是生成一个随机的结果。同时，不必担心内存管理问题，垃圾收集器将会处理相关的事宜。

- 在Java中，必须使用clone方法获得对象的完整拷贝。

### 更改器方法与访问器方法

- 访问对象且有可能修改对象的方法叫更改器方（mutator method），只访问对象而不修改对象的方法有时称为访问器方法（accessor method）。

- 在C++中，带有const后缀的方法是访问器方法；默认为更改器方法。但是，在Java语言中，访问器方法与更改器方法在语法上没有明显的区别。

### 构造器

- 构造器与类同名。在构造Employee类的对象时，构造器会运行，以便将实例域初始化为所希望的状态。

- 构造器与其他的方法有一个重要的不同。构造器总是伴随着new操作符的执行被调用，而不能对一个已经存在的对象调用构造器来达到重新设置实例域的目的

- Java构造器的工作方式与C++一样。但是，要记住所有的Java对象都是在堆中构造的，构造器总是伴随着new操作符一起使用。C++程序员最易犯的错误就是忘记new操作符：

  ```java
  Employee number007("James Bond", 1000, 1950); // C++, not Java
    new Employee number007("James Bond", 1000, 1950); // Java
  ```

- 警告：请注意，不要在构造器中定义与实例域重名的局部变量。

### 隐式参数与显式参数

- 隐式（implicit）参数，是出现在方法名前的Employee类对象。显式参数是明显地列在方法声明中的参数。

- 在每一个方法中，**关键字this表示隐式参数**

  ```java
  public void raiseSalary(double byPercent) {
        double raise = this.salary * byPercent / 100;
        this.salary += raise;
    }
  ```

- 在C++中，通常在类的外面定义方法，如果在类的内部定义方法，这个方法将自动地成为内联（inline）方法。

- 在Java中，所有的方法都必须在类的内部定义，但并不表示它们是内联方法。是否将某个方法设置为内联方法是Java虚拟机的任务。即时编译器会监视调用那些简洁、经常被调用、没有被重载以及可优化的方法。

- C++也有同样的原则。方法可以访问所属类的私有特性（feature），而不仅限于访问隐式参数的私有特性。

### final实例域

- 可以将实例域定义为final。构建对象时必须初始化这样的域。也就是说，必须确保在每一个构造器执行之后，这个域的值被设置，并且在后面的操作中，不能够再对它进行修改。

- final修饰符大都应用于基本（primitive）类型域，或不可变（immutable）类的域（如果类中的每个方法都不会改变其对象，这种类就是不可变的类。例如，String类就是一个不可变的类）。

- 但是final关键字对于可变的类可能会引起歧义：

  ```java
  class Employee {
        public Employee () { evaluation = new StringBuilder();}
        private final StringBuilder evaluations;
        public void giveColdStar() {
            evaluation.append(LocalDate.now() + ": Cold star!\n");
        }

    }
  ```

### static静态域

- 如果将域定义为static，1000个类的对象，也只有这一个static域，因为它是属于类的，而不属于任何独立的对象。举例，下面的nextId维护了Employee类的static域，所有对象都可以访问，且唯一，所以用来做全局唯一的ID值，是非常合适的

  ```java
  class Employee {
  private static int nextId = 1;
    private int id;
    public void setId() {
        id = nextId;
        nextId++;
    }
  }
  ```

#### 静态常量

- `static final xxx`，System.out是一个典型的静态常量

  ```java
  public class Math {
        public static final double PI = 3.1415926;
    }

    int 2pi = 2*Math.PI; // 程序中可以直接用Math.PI访问static域
  ```

#### 静态方法

- 静态方法是一种不能向对象实施操作的方法。例如，Math类的pow方法就是一个静态方法。`Math.pow(x,a)`，不使用任何Math对象，换句话说，没有隐式参数

- 静态方法不能访问非静态域，但可以访问自身类中的静态域，可以通过类名调用静态方法，

- 两种情况使用静态方法比较好

  - 一个方法不需要访问对象状态，其所需参数都是通过显式参数提供（例如：Math.pow）。

  - 一个方法只需要访问类的静态域（例如：Employee.getNextId）。

    ```java
    class Employee {}
          ...
          public static int getNextId() {
              return nextId;
          }
      }

      int n = Employee.getNextId();
    ```

#### C++注释

- Java中的静态域与静态方法在功能上与C++相同。但是，语法书写上却稍有所不同。在C++中，使用：：操作符访问自身作用域之外的静态域和静态方法，如`Math::PI`

- 术语"static"有一段不寻常的历史。起初，C引入关键字static是为了表示退出一个块后依然存在的局部变量。在这种情况下，术语"static"是有意义的：变量一直存在，当再次进入该块时仍然存在。随后，static在C中有了第二种含义，表示不能被其他文件访问的全局变量和函数。为了避免引入一个新的关键字，关键字static被重用了。最后，C++第三次重用了这个关键字，与前面赋予的含义完全不一样，这里将其解释为：属于类且不属于类对象的变量和函数。这个含义与Java相同。

#### 静态工厂

- 静态方法还有另外一种常见的用途。类似LocalDate和NumberFormat的类使用静态工厂方法（factory method）来构造对象。

#### main方法

- main方法不对任何对象进行操作。事实上，在启动程序时还没有任何一个对象。静态的main方法将执行并创建程序所需要的对象。

- 提示：每一个类可以有一个main方法。这是一个常用于对类进行单元测试的技巧。

  ```java
  class Employee {
        ...
        public static void main (String[] args) { // unit test
            ...
        }
    }
    class Application {
        ...
        public static void main (String[] args) { // main entrance
            ...
        }
    }
  ```

  ```shell
    # 独立测试
    java Employee
    # 运行程序，Employee的main方法永远不会执行
    java Application
  ```

### 方法参数

- **Java程序设计语言总是采用按值调用(call by value)**。也就是说，方法得到的是所有参数值的一个拷贝，特别是，方法不能修改传递给它的任何参数变量的内容。

- 方法参数共有两种类型：

  - 基本数据类型（数字、布尔值）。所以一个方法不能修改数值型或布尔型的参数

  - 对象引用。一个方法得到的是对象引用的拷贝，对象引用及其他的拷贝同时引用同一个对象。

  - 读者已经看到，一个方法不可能修改一个基本数据类型的参数。而对象引用作为参数就不同了，比如

    ```java
    public static void tripleSalary(Employee x) {
          x.raiseSalary(200);
      }
      harry = new Employee(...);
      tripleSalary(harry);
    ```

    具体的执行过程为：

    1）x被初始化为harry值的拷贝，这里是一个对象的引用。

    2）raiseSalary方法应用于这个对象引用。x和harry同时引用的那个Employee对象的薪金提高了 200%。

    3）方法结束后，参数变量x不再使用。当然，对象变量harry继续引用那个薪金增至3倍的雇员对象

  - 所以，一个方法可以改变一个对象参数的状态，一个方法不能让对象参数引用一个新的对象。

- C++注释：C++有值调用和引用调用。引用参数标有&符号。例如，可以轻松地实现void tripleValue（double&x）方法或void swap（Employee&x，Employee&y）方法实现修改它们的引用参数的目的。

### 对象构造

#### 重载

- Java允许重载任何方法，而不只是构造器方法。因此，要完整地描述一个方法，需要指出方法名以及参数类型。这叫做方法的签名（signature）。注意返回类型不是签名的一部分

#### 默认域初始化

- 如果在构造器中没有显式地给域赋予初值，那么就会被自动地赋为默认值：数值为0、布尔值为false、对象引用为null。然而，只有缺少程序设计经验的人才会这样做。确实，如果不明确地对域进行初始化，就会影响程序代码的可读性。

- 这是域与局部变量的主要不同点。**必须明确地初始化方法中的局部变量**。但是，如果没有初始化类中的域，将会被自动初始化为默认值（0、false或null）。

#### 无参/默认构造方法

- 很多类都包含一个无参数的构造函数，对象由无参数构造函数创建时，其状态会设置为适当的默认值

- 如果在编写一个类时没有编写构造器，那么系统就会提供一个无参数构造器。这个构造器将所有的实例域设置为默认值。

- 如果类中提供了至少一个构造器，但是没有提供无参数的构造器，则在构造对象时如果没有提供参数就会被视为不合法。

- 如果确实想调用无参构造器，那么程序员就得显示提供一个默认的无参构造器，

#### 显式域初始化

- Java中的域初始值不一定是常量值，也可以是调用常量来初始化，这是和C++很大的区别

  ```java
  class Employee {
  private static int nextId;
    private int id = assignId();
    private static int assignId() {
        int r = nextId;
        nextId++;
        return r;
    }
  }
  ```

- C++注释：在C++中，不能直接初始化类的实例域。所有的域必须在构造器中设置。但是，有一个特殊的初始化器列表语法，如下所示：

  ```c++
  Employee::Employee(String n, double s) : name(n), salary(s) {

    }
  ```

#### 参数名

- 参数变量用同样的名字将实例域屏蔽起来，但可以加上this访问实例域

  ```java
  public Employee(String n, double salary) {
        this.name = name;
        this.salary = salary;
    }
  ```

- C++注释：在C++中，经常用下划线或某个固定的字母（一般选用m或x）作为实例域的前缀。Java程序员一般不这么做

#### 构造器调用另一个构造器

- Java可以在构造器内部使用this调用另一个构造器

  ```java public Employee(String n, double salary) {

  ```
  this("Employee @" + nextId, s);
    nextId++;
  ```

  }

- 采用这种方式使用this关键字非常有用，这样对公共的构造器代码部分只编写一次即可。

- C++注释：在Java中，this引用等价于C++的this指针。但是，**在C++中，一个构造器不能调用另一个构造器**。在C++中，必须将抽取出的公共初始化代码编写成一个独立的方法。

#### 对象析构与finalize方法

- 由于Java有自动的垃圾回收器，不需要人工回收内存，所以Java不支持析构器。

- 可以为任何一个类添加finalize方法。finalize方法将在垃圾回收器清除对象之前调用。在实际应用中，不要依赖于使用finalize方法回收任何短缺的资源，这是因为很难知道这个方法什么时候才能够调用。

### 包(package)

- 使用包的主要原因是确保类名的唯一性。假如两个程序员不约而同地建立了Employee类。只要将这些类放置在不同的包中，就不会产生冲突。

- 从编译器的角度来看，嵌套的包之间没有任何关系。例如，java.util包与java.util.jar包毫无关系。每一个都拥有独立的类集合。

#### 导入

- 但是，需要注意的是，只能使用星号（_）导入一个包，而不能使用`import java._`或`import java._._`导入以java为前缀的所有包。

- C++注释：C++程序员经常将import与#include弄混。实际上，这两者之间并没有共同之处。在C++中，必须使用#include将外部特性的声明加载进来，这是因为C++编译器无法查看任何文件的内部，除了正在编译的文件以及在头文件中明确包含的文件。Java编译器可以查看其他文件的内部，只要告诉它到哪里去查看就可以了。

- 在Java中，通过显式地给出包名，如java.util.Date，就可以不使用import；而在C++中，**无法避免使用#include指令**。

- Import语句的唯一的好处是简捷。可以使用简短的名字而不是完整的包名来引用一个类。例如，在import java.util._（或import java.util.Date）语句之后，可以仅仅用Date引用java.util.Date类。 _*在C++中，与包机制类似的是命名空间（namespace）。在Java中，package与import语句类似于C++中的namespace和using指令。__

#### 静态导入

- import语句不仅可以导入类，还增加了导入静态方法和静态域的功能。

  ```java import static Math; sqrt(pow(x,2) + pow(y,2)); // if no static import Math.sqrt(Math(x,2) + Math(y,2));

#### 将类放入包中

- 要想将一个类放入包中，就必须将包的名字放在源文件的开头，包中定义类的代码之前。

  ```java
  package com.xxx.xxx;
    public class Emplyee
    ...
  ```

- 如果没有在源文件中放置package语句，这个源文件中的类就被放置在一个默认包（defaulf package）中。默认包是一个没有名字的包。

#### 包作用域

- 标记为public的部分可以被任意的类使用；标记为private的部分只能被定义它们的类使用。如果没有指定public或private，这个部分（类、方法或变量）可以被同一个包中的所有方法访问。

### 类设计技巧

1. 一定要保证数据私有

2. 一定要对数据初始化

3. 不要在类中使用过多的基本类型

4. 不是所有的域都需要独立的域访问器和域更改器

5. 将职责过多的类进行分解

6. 类名和方法名要能够体现它们的职责 命名类名的良好习惯是采用一个名词（Order）、前面有形容词修饰的名词（RushOrder）或动名词（有"-ing"后缀）修饰名词（例如，BillingAddress）。对于方法来说，习惯是访问器方法用小写get开头（getSalary），更改器方法用小写的set开头（setSalary）。

7. 优先使用不可变的类

## 继承

- 继承已存在的类就是复用（继承）这些类的方法和域。在此基础上，还可以添加一些新的方法和域，以满足新的需求。

- 反射（reflection）是指在程序运行期间发现更多的类及其属性的能力

- "is-a"关系是继承的一个明显特征

- **Java没有多继承**

### 超类与子类

- extends关键字表示继承

  ```java
  public class Manager extends Employee {}
  ```

- C++注释：Java与C++定义继承类的方式十分相似。Java用关键字extends代替了C++中的冒号（`:`）。在Java中，所有的继承都是公有继承，而没有C++中的私有继承和保护继承。

- 关键字extends表明正在构造的新类派生于一个已存在的类。已存在的类称为超类（superclass）、基类（base class）或父类（parent class）；新类称为子类（subclass）、派生类（derived class）或孩子类（child class）。超类和子类是Java程序员最常用的两个术语，而了解其他语言的程序员可能更加偏爱使用父类和孩子类，这些都是继承时使用的术语。

- 前缀"超"和"子"来源于计算机科学和数学理论中的集合语言的术语。所有雇员组成的集合包含所有经理组成的集合。可以这样说，雇员集合是经理集合的超集，也可以说，经理集合是雇员集合的子集。

- 在通过扩展超类定义子类的时候，仅需要指出子类与超类的不同之处。因此在设计类的时候，应该将通用的方法放在超类中，而将具有特殊用途的方法放在子类中，这种将通用的功能放到超类的做法，在面向对象程序设计中十分普遍。

#### 覆盖(override)

- 子类可以定义同名方法来覆盖超类的方法

- super关键字指示编译器调用超类方法，注释：有些人认为super与this引用是类似的概念，实际上，这样比较并不太恰当。这是因为super不是一个对象的引用，不能将super赋给另一个对象变量，它只是一个指示编译器调用超类方法的特殊关键字。

  ```java
  public class Manager extneds Employee {
        private double bonus;
        public double getSalary() {
            double salary = super.getSalary();
            return baseSarary + bonus;
        }
    }
  ```

- 正像前面所看到的那样，在子类中可以增加域、增加方法或覆盖超类的方法，然而绝对不能删除继承的任何域和方法。

- C++注释：在Java中使用关键字super调用超类的方法，而在C++中则采用超类名加上：：操作符的形式。例如，在Manager类的getSalary方法中，应该将super.getSalary替换为Employee：：getSalary。

#### 子类构造器

- 由于Manager类的构造器不能访问Employee类的私有域，所以必须利用Employee类的构造器对这部分私有域进行初始化，我们可以通过super实现对超类构造器的调用。使用super调用构造器的语句必须是子类构造器的第一条语句。

  ```java
  public Manager(String name, double salary) {
        super(name, salary);
        bonus = 0;
    }
  ```

- 如果子类的构造器没有显式地调用超类的构造器，则将自动地调用超类默认（没有参数）的构造器。如果超类没有不带参数的构造器，并且在子类的构造器中又没有显式地调用超类的其他构造器，则Java编译器将报告错误。

- 回忆一下，关键字this有两个用途：一是引用隐式参数，二是调用该类其他的构造器。同样，super关键字也有两个用途：一是调用超类的方法，二是调用超类的构造器。在调用构造器的时候，这两个关键字的使用方式很相似。调用构造器的语句只能作为另一个构造器的第一条语句出现。构造参数既可以传递给本类（this）的其他构造器，也可以传递给超类（super）的构造器。

- C++注释：在C++的构造函数中，使用初始化列表语法调用超类的构造函数，而不调用super。在C++中，Manager的构造函数如下所示：

  ```c++
  Manager::Manager(String name, double salary) : Employee(name, salary) {
        bonus = 0;
    }
  ```

#### 多态

- is-a"规则的另一种表述法是置换法则。它表明程序中出现超类对象的任何地方都可以用子类对象置换。

- 在Java程序设计语言中，对象变量是多态的。一个Employee变量既可以引用一个Employee类对象，也可以引用一个Employee类的任何一个子类的对象（例如，Manager、Executive、Secretary等）

  ```java
  Employee e;
    e = new Employee(..);
    e = new Manager(..);

    Manager boss = new Manager(..);
    Employee[] staff = new Employee[3];
    staff[0] = boss;
    boss.setBonus(500); // ok
    staff[0].setBonus(500); // error，staff[0]声明的是Employee
    Manager m = staff[i]; // error，不能将超类的引用赋给子类变量，不是所有的员工都是经理
  ```

#### 理解方法调用（重要!）

- 弄清楚如何在对象上应用方法调用非常重要。下面假设要调用x.f（args），隐式参数x声明为类C的一个对象。下面是调用过程的详细描述：

  - 编译器查看对象的声明类型和方法名。假设调用x.f（param），且隐式参数x声明为C类的对象。需要注意的是：有可能存在多个名字为f，但参数类型不一样的方法。例如，可能存在方法f（int）和方法f（String）。编译器将会一一列举所有C类中名为f的方法和其超类中访问属性为public且名为f的方法（超类的私有方法不可访问）。至此，编译器已获得所有可能被调用的候选方法。

  - 接下来，编译器将查看调用方法时提供的参数类型。如果在所有名为f的方法中存在一个与提供的参数类型完全匹配，就选择这个方法。这个过程被称为重载解析（overloading resolution）。例如，对于调用x.f（"Hello"）来说，编译器将会挑选f（String），而不是f（int）。由于允许类型转换（int可以转换成double，Manager可以转换成Employee，等等），所以这个过程可能很复杂。如果编译器没有找到与参数类型匹配的方法，或者发现经过类型转换后有多个方法与之匹配，就会报告一个错误。至此，编译器已获得需要调用的方法名字和参数类型。

    - 因为方法返回类型不影响方法签名，所以允许子类将覆盖方法定义为原返回类型的子类型

      ```java
      public Employee getBuddy() {} public Manager getBuddy() {} // 重载方法
      ```

  - 如果是private方法、static方法、final方法（有关final修饰符的含义将在下一节讲述）或者构造器，那么编译器将可以准确地知道应该调用哪个方法，我们将这种调用方式称为静态绑定（static binding）。与此对应的是，调用的方法依赖于隐式参数的实际类型，并且在运行时实现动态绑定。在我们列举的示例中，编译器采用动态绑定的方式生成一条调用f（String）的指令。

  - 当程序运行，并且采用动态绑定调用方法时，虚拟机一定调用与x所引用对象的实际类型最合适的那个类的方法。假设x的实际类型是D，它是C类的子类。如果D类定义了方法f（String），就直接调用它；否则，将在D类的超类中寻找f（String），以此类推。

    - 每次调用方法都要进行搜索，时间开销相当大。因此，虚拟机预先为每个类创建了一个**方法表（method table）**，其中列出了所有方法的签名和实际调用的方法。这样一来，在真正调用方法的时候，虚拟机仅查找这个表就行了。在前面的例子中，虚拟机搜索D类的方法表，以便寻找与调用f（Sting）相匹配的方法。这个方法既有可能是D.f（String），也有可能是X.f（String），这里的X是D的超类。这里需要提醒一点，如果调用super.f（param），编译器将对隐式参数超类的方法表进行搜索。

- 在运行时，调用e.getSalary（）的解析过程为：

  - 首先，虚拟机提取e的实际类型的方法表。既可能是Employee、Manager的方法表，也可能是Employee类的其他子类的方法表。

  - 接下来，虚拟机搜索定义getSalary签名的类。此时，虚拟机已经知道应该调用哪个方法。

  - 最后，虚拟机调用方法。

- 动态绑定有一个非常重要的特性：无需对现存的代码进行修改，就可以对程序进行扩展。假设增加一个新类Executive，并且变量e有可能引用这个类的对象，我们不需要对包含调用e.getSalary（）的代码进行重新编译。如果e恰好引用一个Executive类的对象，就会自动地调用Executive.getSalary（）方法。

- 警告：在覆盖一个方法的时候，子类方法不能低于超类方法的可见性。特别是，如果超类方法是public，子类方法一定要声明为public。经常会发生这类错误：在声明子类方法的时候，遗漏了public修饰符。此时，编译器将会把它解释为试图提供更严格的访问权限。

#### 阻止继承：final类和方法

- 有时候，可能希望阻止人们利用某个类定义子类。不允许扩展的类被称为final类。如果在定义类的时候使用了final修饰符就表明这个类是final类。例如，假设希望阻止人们定义Executive类的子类，就可以在定义这个类的时候，使用final修饰符声明。声明格式如下所示：

  ```java
  public final class Excutive extends Manager {}
  ```

- 类中的特定方法也可以被声明为final。如果这样做，子类就不能覆盖这个方法（final类中的所有方法自动地成为final方法）

  ```java
  public class Employee {
        public final String getName() {}
    }
  ```

- 前面曾经说过，域也可以被声明为final。对于final域来说，构造对象之后就不允许改变它们的值了。不过，如果将一个类声明为final，只有其中的方法自动地成为final，而不包括域。

- 将方法或类声明为final主要目的是：确保它们不会在子类中改变语义。

- C++注释：C++默认所有方法都不具有多态性，而Java反过来，作者提倡在两者之间寻找一个平衡

#### 强制类型转换

- 正像有时候需要将浮点型数值转换成整型数值一样，有时候也可能需要将某个类的对象引用转换成另外一个类的对象引用。对象引用的转换语法与数值表达式的类型转换类似，仅需要用一对圆括号将目标类名括起来，并放置在需要转换的对象引用之前就可以了。

- 进行类型转换的唯一原因是：在暂时忽视对象的实际类型之后，使用对象的全部功能。

- 将一个值存入变量时，编译器将检查是否允许该操作。**将一个子类的引用赋给一个超类变量，编译器是允许的**。但将一个超类的引用赋给一个子类变量，必须进行类型转换，这样才能够通过运行时的检查。

- 在将超类转换成子类之前，应该使用instanceof进行检查。如果变量是null，用instanceof检查也不会产生异常

  ```java
  if (staff[1] instanceof Manager) {
        boss = (Manger) staff[1];
    }
  ```

- Java的强制类型转换转换很像像C++的dynamic_cast操作，它们之间只有一点重要的区别：当类型转换失败时，Java不会生成一个null对象，而是抛出一个异常。从这个意义上讲，有点像C++中的引用（reference）转换。真是令人生厌。在C++中，可以在一个操作中完成类型测试和类型转换。

  ```c++
  Manager* boss = dynamic_cast<Manager*>(staff[1]); // C++
    if (boss != NULL) ...
  ```

  在Java中，需要将instanceof运算符和类型转换组合起来使用：

  ```java
  if (staff[1] instanceof Manager) {
        boss = (Manger) staff[1];
    }
  ```

#### 抽象类

- 为了提高程序的清晰度，人们只将抽象类作为派生其他类的基类，而不作为想使用的特定的实例类。包含一个或多个抽象方法的类本身必须被声明为抽象的。但注意抽象类内部是可以有具体数据和具体方法的

  ```java
  // 抽象方法
    public abstract String getDescription();
    // 抽象类
    public abstract class Person {}
  ```

- 类即使不含抽象方法，也可以将类声明为抽象类。

- 抽象类不能被实例化。也就是说，如果将一个类声明为abstract，就不能创建这个类的对象。需要注意，可以定义一个抽象类的对象变量，但是它只能引用非抽象子类的对象

- 在C++中，有一种在尾部用=0标记的抽象方法，称为纯虚函数。只要有一个纯虚函数，这个类就是抽象类。在C++中，没有提供用于表示抽象类的特殊关键字。

#### 受保护访问

- 大家都知道，最好将类中的域标记为private，而方法标记为public。任何声明为private的内容对其他类都是不可见的。前面已经看到，这对于子类来说也完全适用，即子类也不能访问超类的私有域。

- 然而，在有些时候，人们希望超类中的某些方法允许被子类访问，或允许子类的方法访问超类的某个域。为此，需要将这些方法或域声明为protected。

- C++注释：事实上，Java中的受保护部分对所有子类及同一个包中的所有其他类都可见。这与C++中的保护机制稍有不同，Java中的protected概念要比C++中的安全性差。

- Java用于控制可见性的4个访问修饰符：

  - 仅对本类可见----private。

  - 对所有类可见----public。

  - 对本包和所有子类可见----protected。

  - 对本包可见----默认（很遗憾），不需要修饰符。

### Object: 所有类的超类

- Object类是Java中所有类的始祖，在Java中每个类都是由它扩展而来的。如果一个类没有明确指出超类，Object类就是这个类的超类

- C++注释：在C++中没有所有类的根类，不过，每个指针都可以转换成void*指针。

#### equals方法

- `Object.equals(a,b)`方法：如果两个参数都为null，则返回true；如果一个为null，则返回false，如果两个都不为null，则调用`a.equals(b)`

- 在子类中定义equals方法时，首先调用超类的equals。如果检测失败，对象就不可能相等。如果超类中的域都相等，就需要比较子类中的实例域。

- 一个比较好的equals方法

  ```java
  public class Employee {
    public boolean equals(Object otherObject) { // 注意显式参数是Object类
        // quick test
        if (this == otherObject) return true;
        // must return false if the explicit parameter is null
        if (otherObject == null) return false;
        // if class don't match, they can't be equal
        if (getClass() != otherObject.getClass()) return false;
        // now we know otherObject is a non-null Employee
        Employee other = (Employee) otherObject;
        // 为了防备name或hireDay可能为null的情况，需要使用Objects.equals方法
        return Object.equals(name, other.name) && salary == other.salary && Obejct.equals(hireDay, other.hireDay);
    }
  }
  ```

#### equals: 相等测试和继承

- 有些程序员喜欢在equals方法中调用instanceof方法，但是这有一些麻烦，比如Java语言规范要求equals方法具有以下特性

  - 自反性：对于任何非空引用x，x.equals（x）应该返回true。

  - 对称性：对于任何引用x和y，当且仅当y.equals（x）返回true，x.equals（y）也应该返回true。

  - 传递性：对于任何引用x、y和z，如果x.equals（y）返回true，y.equals（z）返回true，x.equals（z）也应该返回true。

  - 一致性：如果x和y引用的对象没有发生变化，反复调用x.equals（y）应该返回同样的结果。

  - 对于任意非空引用x，x.equals（null）应该返回false。

- 完美equals方法建议

  - 显式参数命名为otherObject，稍后需要将它转换成另一个叫做other的变量。

  - 检测this与otherObject是否引用同一个对象：

    这条语句只是一个优化。实际上，这是一种经常采用的形式。因为计算这个等式要比一个一个地比较类中的域所付出的代价小得多。

  - 检测otherObject是否为null，如果为null，返回false。这项检测是很必要的。

  - 比较this与otherObject是否属于同一个类。如果equals的语义在每个子类中有所改变，就使用getClass检测：

    - 所有的子类都拥有统一的语义，就使用instanceof检测：

  - 将otherObject转换为相应的类类型变量：

  - 现在开始对所有需要比较的域进行比较了。使用==比较基本类型域，使用equals比较对象域。如果所有的域都匹配，就返回true；否则返回false。

    - 如果在子类中重新定义equals，就要在其中包含调用super.equals(other)

- 如果确定一个方法是覆盖方法，可以添加`@Override`告知编译器这个 方法要对超类的某个方法进行覆盖，如果没有找到对应的超类方法，则编译器报错

#### hashCode方法

- 由于hashCode方法定义在Object类中，因此每个对象都有一个默认的散列码，其值为对象的存储地址。

- hashCode方法应该返回一个整型数值（也可以是负数），并合理地组合实例域的散列码，以便能够让各个不同的对象产生的散列码更加均匀。

- Equals与hashCode的定义必须一致：如果x.equals（y）返回true，那么x.hashCode（）就必须与y.hashCode（）具有相同的值。

- 如果存在数组类型的域，那么可以使用静态的Arrays.hashCode方法计算一个散列码，这个散列码由数组元素的散列码组成。

- hashCode方法优化

  ```java
  // 优化前
  public int hashCode() {
  return 7 * name.hashCode() // 可以使用null安全的Object.hashCode方法来改进
        + 11 * new Double(salary).hashCode() // 可以使用静态方法Double.hashCode()方法来避免创建Double对象
        + 13 * hireDay.hashCode(); // 可以使用null安全的Object.hashCode方法来改进
  }

   // 优化后
  public int hashCode() {
    return 7 * Object.hashCode(name)
        + 11 * Double.hashCode(salary)
        + 13 * Object.hashCode(hireDay);
  }
  // 还可以用hash()方法直接组合，hash()方法会对各参数分别调用Object.hashCode()方法，并组合这些散列值
  public int hashCode() {
      return Object.hash(name, salary, hireDay);
  }
  ```

#### toString方法

- 在Object中还有一个重要的方法，就是toString方法，它用于返回表示对象值的字符串。

- 绝大多数（但不是全部）的toString方法都遵循这样的格式：类的名字，随后是一对方括号括起来的域值。

  ```java
  // Empoloyee类的toString方法
    public String toString() {
        return getClass().getName()
            + "[name=" + name
            + ",salary=" + salary
            + ",hireDay=" + hireDay
            + "]";
    }
    // Manager类的toString方法
    public String toString() {
        return super.toString() 
            + "[bonus=" + bonus
            + "]";
    }
  ```

- 只要对象与一个字符串通过操作符"+"连接起来，Java编译就会自动地调用toString方法，以便获得这个对象的字符串描述

- 在调用x.toString（）的地方可以用""+x替代。这条语句将一个空串与x的字符串表示相连接。这里的x就是x.toString（）。与toString不同的是，如果x是基本类型，这条语句照样能够执行。

- 数组的toString方法要使用静态方法Array.toString，多维数组要使用静态方法Array.deepToString

- 提示：强烈建议为自定义的每一个类增加toString方法。这样做不仅自己受益，而且所有使用这个类的程序员也会从这个日志记录支持中受益匪浅

### 泛型数组列表

- ArrayList是一个采用类型参数（type parameter）的泛型类（generic class）。为了指定数组列表保存的元素对象类型，需要用一对尖括号将类名括起来加在后面，例如，`ArrayList<Employee>`

- 数组列表管理着对象引用的一个内部数组。最终，数组的全部空间有可能被用尽。这就显现出数组列表的操作魅力：如果调用add且内部数组已经满了，数组列表就将自动地创建一个更大的数组，并将所有的对象从较小的数组中拷贝到较大的数组中。

- 如果已经清楚或能够估计出数组可能存储的元素数量，就可以在填充数组之前调用ensureCapacity方法：

  ```java
  staff.ensureCapacity(100);
  ```

  这个方法调用将分配一个包含100个对象的内部数组。然后调用100次add，而不用重新分配空间。（有点像C++的vector的reserve方法）

- 一旦能够确认数组列表的大小不再发生变化，就可以调用trimToSize方法。这个方法将存储区域的大小调整为当前元素数量所需要的存储空间数目。垃圾回收器将回收多余的存储空间。 一旦整理了数组列表的大小，添加新元素就需要花时间再次移动存储块，所以应该在确认不会添加任何元素时，再调用trimToSize。（有点像C++的vector的shrink_to_fit方法

- C++注释：ArrayList类似于C++的vector模板。ArrayList与vector都是泛型类型。但是C++的vector模板为了便于访问元素重载了[]运算符。由于Java没有运算符重载，所以必须调用显式的方法。此外，C++向量是值拷贝。如果a和b是两个向量，赋值操作a=b将会构造一个与b长度相同的新向量a，并将所有的元素由b拷贝到a，而在Java中，这条赋值语句的操作结果是让a和b引用同一个数组列表。

- `java.util.ArrayList<E>1.2`

  - `ArrayList<E>（）`

    构造一个空数组列表。

  - `ArrayList<E>（int initialCapacity）`

    用指定容量构造一个空数组列表。 参数：initalCapacity 数组列表的最初容量

  - `boolean add（E obj）`

    在数组列表的尾端添加一个元素。永远返回true。 参数：obj 添加的元素

  - `int size（）`

    返回存储在数组列表中的当前元素数量。（这个值将小于或等于数组列表的容量。）

  - `void ensureCapacity（int capacity）`

    确保数组列表在不重新分配存储空间的情况下就能够保存给定数量的元素。 参数：capacity 需要的存储容量

  - `void trimToSize（）`

    将数组列表的存储容量削减到当前尺寸。

#### 访问数组列表元素

- `java.util.ArrayList<T>1.2`

- `void set（int index，E obj）`

    设置数组列表指定位置的元素值，这个操作将覆盖这个位置的原有内容。
    参数：index　位置（必须介于0~size（）-1之间）
    obj　新的值

- `E get（int index）`

    获得指定位置的元素值。
    参数：index　获得的元素位置（必须介于0~size（）-1之间）

- `void add（int index，E obj）`

    向后移动元素，以便插入元素。
    参数：index　插入位置（必须介于0~size（）-1之间）
    obj　新元素

- `E remove（int index）`

    删除一个元素，并将后面的元素向前移动。被删除的元素由返回值返回。
    参数：index　被删除的元素位置（必须介于0~size（）-1之间）

- for each循环

  ```java
  for (Employee e : staff) {
        do somthing;
    }
  ```

### 对象包装器与自动装箱

- 有时，需要将int这样的基本类型转换为对象。所有的基本类型都有一个与之对应的类。例如，Integer类对应基本类型int。通常，这些类称为**包装器（wrapper）**。这些对象包装器类拥有很明显的名字：Integer、Long、Float、Double、Short、Byte、Character、Void和Boolean（前6个类派生于公共的超类Number）。对象包装器类是不可变的，即一旦构造了包装器，就不允许更改包装在其中的值。同时，对象包装器类还是final，因此不能定义它们的子类。

- 假设想定义一个整型数组列表。而尖括号中的类型参数不允许是基本类型，也就是说，不允许写成`ArrayList<int>`。这里就用到了Integer对象包装器类。我们可以声明一个Integer对象的数组列表。由于每个值分别包装在对象中，所以`ArrayList<Integer>`的效率远远低于`int[]`数组。

  ```java
  ArrayList<Integer> list = new ArrayList<>();
    list.add(3); // 自动装箱（autoboxing），自动转变为：list.add(Integer.valueOf(3));
    int n = list.get(i); // 自动装箱：int n = list.get(i).intValue();
    Integer  n = 3;
    n++; //算数表达式也可以自动装箱
  ```

- 包装器的`==`是检测对象是否指向同个区域，所以大概率是不相等的

- 首先，由于包装器类引用可以为null，所以自动装箱有可能会抛出一个NullPointerException异常

- 另外，如果在一个条件表达式中混合使用Integer和Double类型，Integer值就会拆箱，提升为double，再装箱为Double

- 要想将字符串转换成整形，可以使用Integer类的静态方法

  ```java
  String s = "sss";
    int x = Integer.parseInt(s);
  ```

### 参数数量可变的方法

- 比如printf方法，这里的省略号...是Java代码的一部分，它表明这个方法可以接收任意数量的对象（除fmt参数之外

  ```java
  public class PrintStream {
        public PrintStream print(String fmt, Object... args) { return format(fmt, args); }
    }
  ```

- main方法甚至可以改成

  ```java
  public static void main(String... args) {}
  ```

### 枚举类

- `public enum Size {SAMLL, MEDIUM, LARGE, EXTRA_LARGE};`

- 这个声明定义的类型是一个类，它刚好有4个实例，在此尽量不要构造新对象。因此，在比较两个枚举类型的值时，永远不需要调用equals，而直接使用"=="就可以了。

- 如果需要的话，可以在枚举类型中添加一些构造器、方法和域。当然，构造器只是在构造枚举常量的时候被调用。

- 所有的枚举类型都是Enum类的子类。它们继承了这个类的许多方法。其中最有用的一个是toString，这个方法能够返回枚举常量名。例如，Size.SMALL.toString（）将返回字符串"SMALL"。

- toString的逆方法是静态方法valueOf

  ```java
  Size s = Enum.valueOf(Size.class, "SMALL"); // 返回指定名字、给定类的枚举常量。
  ```

- 每个枚举类型都有一个静态的values方法，它将返回一个包含全部枚举值的数组。例如，如下调用：`Size[] values = Size.value();`，返回包含元素Size.SMALL，Size.MEDIUM，Size.LARGE和Size.EXTRA_LARGE的数组。

- ordinal方法返回enum声明中枚举常量的位置，位置从0开始计数。例如：Size.MEDIUM.ordinal（）返回1。

### 反射

- 反射库（reflection library）提供了一个非常丰富且精心设计的工具集，以便编写能够动态操纵Java代码的程序。这项功能被大量地应用于JavaBeans中，它是Java组件的体系结构（有关JavaBeans的详细内容在卷Ⅱ中阐述）。特别是在设计或运行中添加新类时，能够快速地应用开发工具动态地查询新添加类的能力。

- 能够分析类能力的程序称为反射（reflective）。反射机制的功能极其强大，在下面可以看到，反射机制可以用来：

  - 在运行时分析类的能力。

  - 在运行时查看对象，例如，编写一个toString方法供所有类使用。

  - 实现通用的数组操作代码。

  - 利用Method对象，这个对象很像C++中的函数指针。

#### Class类

- 在程序运行期间，Java运行时系统始终为所有的对象维护一个被称为运行时的类型标识。这个信息跟踪着每个对象所属的类。虚拟机利用运行时类型信息选择相应的方法执行。

- 然而，可以通过专门的Java类访问这些信息。保存这些信息的类被称为Class，这个名字很容易让人混淆。Object类中的`getClass()`方法将会返回一个Class类型的实例。

- 如同用一个Employee对象表示一个特定的雇员属性一样，一个Class对象将表示一个特定类的属性。最常用的Class方法是`getName()`。这个方法将返回类的名字。如果类在一个包里，包的名字也作为类名的一部分

- 还有静态方法forName获得类名对应的Class对象

  ```java
  String className = "java.util.Random";
    Class c1 = Class.forName(className);
  ```

- 获得Class类对象的第三种方法非常简单。如果T是任意的Java类型（或void关键字），T.class将代表匹配的类对象。例如：

  ```java
  Class c1 = Random.class;
    Class c2 = int.class;
    Class c3 = Double[].class;
  ```

  请注意，一个Class对象实际上表示的是一个类型，而这个类型未必一定是一种类。例如，int不是类，但`int.class`是一个Class类型的对象。

- 虚拟机为每个类型管理一个Class对象。因此，可以利用==运算符实现两个类对象比较的操作。还有一个很有用的方法`newInstance()`，可以用来动态地创建一个类的实例。例如，`e.getClass().newInstance();`创建了一个与e具有相同类类型的实例。newInstance方法调用默认的构造器（没有参数的构造器）初始化新创建的对象。如果这个类没有默认的构造器，就会抛出一个异常。

- 将forName与newInstance配合起来使用，可以根据存储在字符串中的类名创建一个对象。

  ```java
  String s = "java.util.Random";
    Object m = Class.forName(s).newInstance();
  ```

- C++注释：newInstance方法对应C++中虚拟构造器的习惯用法。然而，C++中的虚拟构造器不是一种语言特性，需要由专门的库支持。Class类与C++中的type_info类相似，getClass方法与C++中的typeid运算符等价。但Java中的Class比C++中的type_info的功能强。C++中的type_info只能以字符串的形式显示一个类型的名字，而不能创建那个类型的对象。

#### 捕获异常

- 当程序运行过程中发生错误时，就会"抛出异常"。抛出异常比终止程序要灵活得多，这是因为可以提供一个"捕获"异常的处理器（handler）对异常情况进行处理。

- 如果没有提供处理器，程序就会终止，并在控制台上打印出一条信息，其中给出了异常的类型。可能在前面已经看到过一些异常报告，例如，偶然使用了null引用或者数组越界等。

- 异常有两种类型：未检查异常和已检查异常。对于已检查异常，编译器将会检查是否提供了处理器。然而，有很多常见的异常，例如，访问null引用，都属于未检查异常。编译器不会查看是否为这些错误提供了处理器。毕竟，应该精心地编写代码来避免这些错误的发生，而不要将精力花在编写异常处理器上。

- 如果类名不存在，则将跳过try块中的剩余代码，程序直接进入catch子句（这里，利用Throwable类的printStackTrace方法打印出栈的轨迹。Throwable是Exception类的超类）。如果try块中没有抛出任何异常，那么会跳过catch子句的处理器代码。

  ```java
  try {
        String name = ...;
        Class c1 = Class.forName(name);
    } catch (Exception e) {
        e.printStackTrace();
    }
  ```

- 对于已检查异常，只需要提供一个异常处理器。可以很容易地发现会抛出已检查异常的方法。如果调用了一个抛出已检查异常的方法，而又没有提供处理器，编译器就会给出错误报告。

#### 利用反射分析类的能力

- 反射机制最重要的内容----检查类的结构

- 在java.lang.reflect包中有三个类Field、Method和Constructor分别用于描述类的域、方法和构造器。这三个类都有一个叫做getName的方法，用来返回项目的名称。Field类有一个getType方法，用来返回描述域所属类型的Class对象。Method和Constructor类有能够报告参数类型的方法，Method类还有一个可以报告返回类型的方法。

```java
package reflection;

import java.util.*;
import java.lang.reflect.*;

/**
 * This program uses reflection to print all features of a class.
 * @version 1.1 2004-02-21
 * @author Cay Horstmann
 */
public class ReflectionTest
{
   public static void main(String[] args)
   {
      // read class name from command line args or user input
      String name;
      if (args.length > 0) name = args[0];
      else
      {
         Scanner in = new Scanner(System.in);
         System.out.println("Enter class name (e.g. java.util.Date): ");
         name = in.next();
      }

      try
      {
         // print class name and superclass name (if != Object)
         Class cl = Class.forName(name);
         Class supercl = cl.getSuperclass();
         String modifiers = Modifier.toString(cl.getModifiers());
         if (modifiers.length() > 0) System.out.print(modifiers + " ");
         System.out.print("class " + name);
         if (supercl != null && supercl != Object.class) System.out.print(" extends "
               + supercl.getName());

         System.out.print("\n{\n");
         printConstructors(cl);
         System.out.println();
         printMethods(cl);
         System.out.println();
         printFields(cl);
         System.out.println("}");
      }
      catch (ClassNotFoundException e)
      {
         e.printStackTrace();
      }
      System.exit(0);
   }

   /**
    * Prints all constructors of a class
    * @param cl a class
    */
   public static void printConstructors(Class cl)
   {
      Constructor[] constructors = cl.getDeclaredConstructors();

      for (Constructor c : constructors)
      {
         String name = c.getName();
         System.out.print("   ");
         String modifiers = Modifier.toString(c.getModifiers());
         if (modifiers.length() > 0) System.out.print(modifiers + " ");         
         System.out.print(name + "(");

         // print parameter types
         Class[] paramTypes = c.getParameterTypes();
         for (int j = 0; j < paramTypes.length; j++)
         {
            if (j > 0) System.out.print(", ");
            System.out.print(paramTypes[j].getName());
         }
         System.out.println(");");
      }
   }

   /**
    * Prints all methods of a class
    * @param cl a class
    */
   public static void printMethods(Class cl)
   {
      Method[] methods = cl.getDeclaredMethods();

      for (Method m : methods)
      {
         Class retType = m.getReturnType();
         String name = m.getName();

         System.out.print("   ");
         // print modifiers, return type and method name
         String modifiers = Modifier.toString(m.getModifiers());
         if (modifiers.length() > 0) System.out.print(modifiers + " ");         
         System.out.print(retType.getName() + " " + name + "(");

         // print parameter types
         Class[] paramTypes = m.getParameterTypes();
         for (int j = 0; j < paramTypes.length; j++)
         {
            if (j > 0) System.out.print(", ");
            System.out.print(paramTypes[j].getName());
         }
         System.out.println(");");
      }
   }

   /**
    * Prints all fields of a class
    * @param cl a class
    */
   public static void printFields(Class cl)
   {
      Field[] fields = cl.getDeclaredFields();

      for (Field f : fields)
      {
         Class type = f.getType();
         String name = f.getName();
         System.out.print("   ");
         String modifiers = Modifier.toString(f.getModifiers());
         if (modifiers.length() > 0) System.out.print(modifiers + " ");         
         System.out.println(type.getName() + " " + name + ";");
      }
   }
}
```

#### 在运行时使用反射分析对象

- 如果知道想要查看的域名和类型，查看指定的域是一件很容易的事情。而利用反射机制可以查看在编译时还不清楚的对象域。

- 查看对象域的关键方法是Field类中的get方法。如果f是一个Field类型的对象（例如，通过getDeclaredFields得到的对象），obj是某个包含f域的类的对象，f.get（obj）将返回一个对象，其值为obj域的当前值。

  ```java
  Employee harry = new Employee("Harry Hacker", 35000, 10, 1, 1989);
    Class cl = harry.getClass();
    Field f = cl.getDeclaredFiled("name");
    Object v = f.get(harry); // the value of the "name" field of the object "harry", i.e., the String object "Harry Hacker"，根据多态，一个变量（v）即可以引用超类对象，也可以引用子类的对象
  ```

- 实际上，这段代码存在一个问题。由于name是一个私有域，所以get方法将会抛出一个IllegalAccessException。只有利用get方法才能得到可访问域的值。除非拥有访问权限，否则Java安全机制只允许查看任意对象有哪些域，而不允许读取它们的值。

- 反射机制的默认行为受限于Java的访问控制。然而，如果一个Java程序没有受到安全管理器的控制，就可以覆盖访问控制。为了达到这个目的，需要调用Field、Method或Constructor对象的setAccessible方法。setAccessible方法是AccessibleObject类中的一个方法，它是Field、Method和Constructor类的公共超类。这个特性是为调试、持久存储和相似机制提供的。

- String域作为Object没问题，但是Java数值类型不是对象，这时反射机制会自动打包成Integer/Double等等，也可以使用Field类的getDouble方法

- 刚才说明的是读域，有读就有写，用`f.set(obj, value)`可以修改域

- 下面介绍一个可供任意类使用的通用toString方法。其中使用getDeclaredFileds获得所有的数据域，然后使用setAccessible将所有的域设置为可访问的。对于每个域，获得了名字和值。泛型toString方法需要解释几个复杂的问题。循环引用将有可能导致无限递归。因此，ObjectAnalyzer将记录已经被访问过的对象。另外，为了能够查看数组内部，需要采用一种不同的方式。有关这种方式的具体内容将在下一节中详细论述。

```java
// ObjectAnalyzer.java
package objectAnalyzer;
import java.lang.reflect.AccessibleObject;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
public class ObjectAnalyzer
{
private ArrayList<Object> visited = new ArrayList<>();

/**
    * Converts an object to a string representation that lists all fields.
    * @param obj an object
    * @return a string with the object's class name and all field names and
    * values
    */
public String toString(Object obj)
{
    if (obj == null) return "null";
    if (visited.contains(obj)) return "...";
    visited.add(obj);
    Class cl = obj.getClass();
    if (cl == String.class) return (String) obj;
    if (cl.isArray())
    {
        String r = cl.getComponentType() + "[]{";
        for (int i = 0; i < Array.getLength(obj); i++)
        {
            if (i > 0) r += ",";
            Object val = Array.get(obj, i);
            if (cl.getComponentType().isPrimitive()) r += val;
            else r += toString(val);
        }
        return r + "}";
    }

    String r = cl.getName();
    // inspect the fields of this class and all superclasses
    do
    {
        r += "[";
        Field[] fields = cl.getDeclaredFields();
        AccessibleObject.setAccessible(fields, true);
        // get the names and values of all fields
        for (Field f : fields)
        {
            if (!Modifier.isStatic(f.getModifiers()))
            {
            if (!r.endsWith("[")) r += ",";
            r += f.getName() + "=";
            try
            {
                Class t = f.getType();
                Object val = f.get(obj);
                if (t.isPrimitive()) r += val;
                else r += toString(val);
            }
            catch (Exception e)
            {
                e.printStackTrace();
            }
            }
        }
        r += "]";
        cl = cl.getSuperclass();
    }
    while (cl != null);

    return r;
}
}
// ObjectAnalyzerTest.java
package objectAnalyzer;
import java.util.ArrayList;
/**
* This program uses reflection to spy on objects.
* @version 1.12 2012-01-26
* @author Cay Horstmann
*/
public class ObjectAnalyzerTest
{
public static void main(String[] args)
{
    ArrayList<Integer> squares = new ArrayList<>();
    for (int i = 1; i <= 5; i++)
        squares.add(i * i);
    System.out.println(new ObjectAnalyzer().toString(squares));
}
}
```

#### 使用反射编写泛型数组代码

- 当一个`Employee[]`数组临时转换为`Object[]`数组是可行的，但是再也无法转回原来的`Employee[]`数组，当编写一个通用的copyOf方法时，得按照以下步骤考虑：

  - 首先获得a数组的类对象。Array类的静态方法

  - 确认它是一个数组。

  - 使用Class类（只能定义表示数组的类对象）的getComponentType方法确定数组对应的类型。

    ```java
    public static Object goodCopyOf(Object a, int newLength) 
    {
      Class cl = a.getClass();
      if (!cl.isArray()) return null;
      Class componentType = cl.getComponentType();
      int length = Array.getLength(a);
      Object newArray = Array.newInstance(componentType, newLength);
      System.arraycopy(a, 0, newArray, 0, Math.min(length, newLength));
      return newArray;
    }
      ...
      String[] b = { "Tom", "Dick", "Harry" };
      b = (String[]) goodCopyOf(b, 10);
      System.out.println(Arrays.toString(b));
    ```

#### 调用任意方法

- 在C和C++中，可以从函数指针执行任意函数。**从表面上看，Java没有提供方法指针，即将一个方法的存储地址传给另外一个方法，以便第二个方法能够随后调用它。**事实上，Java的设计者曾说过：方法指针是很危险的，并且常常会带来隐患。他们认为Java提供的接口（interface）（将在下一章讨论）是一种更好的解决方案。**然而，反射机制允许你调用任意方法（相当于方法/函数指针）。**

- 在Method类中有一个invoke方法，它允许调用包装在当前Method对象中的方法。invoke方法的签名是：`Object invoke(Object obj, Object... args)`

  - 第一个参数是隐式参数，其余的对象提供了显式参数

  - 对于静态方法，第一个参数可以被忽略，即可以将它设置为null。

  - 例如，假设用ml代表Employee类的getName方法，下面这条语句显示了如何调用这个方法：`String n = (String) m1.invoke(harry);`

  - 如果返回类型是基本类型，invoke方法会返回其包装器类型。例如，假设m2表示Employee类的getSalary方法，那么返回的对象实际上是一个Double，必须相应地完成类型转换。可以使用自动拆箱将它转换为一个double：`double s = (Double) m2.invoke(harry);`

- 如何得到Method对象呢？当然，可以通过调用getDeclareMethods方法，然后对返回的Method对象数组进行查找，直到发现想要的方法为止。也可以通过调用Class类中的getMethod方法得到想要的方法。`Method getMethod(String name, Class... parameterTypes)`

### 继承的设计技巧

1. 将公共操作和域放在超类

  这就是为什么将姓名域放在Person类中，而没有将它放在Employee和Student类中的原因。

2. 不要使用受保护的域

  然而，protected机制并不能够带来更好的保护，其原因主要有两点。第一，子类集合是无限制的，任何一个人都能够由某个类派生一个子类，并编写代码以直接访问protected的实例域，从而破坏了封装性。第二，在Java程序设计语言中，在同一个包中的所有类都可以访问proteced域，而不管它是否为这个类的子类。

3. 使用继承实现"is-a"关系

   1. 除非所有继承的方法都有意义，否则不要使用继承

   2. 在覆盖方法时，不要改变预期的行为

   3. 使用多态，而非类型信息

    使用多态方法或接口编写的代码比使用对多种类型进行检测的代码更加易于维护和扩展。像下面这种代码完全可以用继承与多态来解决

    ```java
    if (x is of type 1) action1(x);
    else if (x is of type 2) action2(x);
    ```

4. 不要过多地使用反射

反射机制使得人们可以通过在运行时查看域和方法，让人们编写出更具有通用性的程序。这种功能对于编写系统程序来说极其实用，但是通常不适于编写应用程序。反射是很脆弱的，即编译器很难帮助人们发现程序中的错误，因此只有在运行时才发现错误并导致异常。

## 接口、lambda表达式与内部类

- 接口（interface）技术，这种技术主要用来描述类具有什么功能，而并不给出每个功能的具体实现。一个类可以实现（implement）一个或多个接口，并在需要接口的地方，随时使用实现了相应接口的对象。

- 了解接口以后，再继续介绍lambda表达式，这是一种表示可以在将来某个时间点执行的代码块的简洁方法。使用lambda表达式，可以用一种精巧而简洁的方式表示使用回调或变量行为的代码。

- 接下来，讨论内部类（inner class）机制。理论上讲，内部类有些复杂，内部类定义在另外一个类的内部，其中的方法可以访问包含它们的外部类的域。内部类技术主要用于设计具有相互协作关系的类集合。

### 接口

#### 接口概念

- 在Java程序设计语言中**，接口不是类，而是对类的一组需求描述**，这些类要遵从接口描述的统一格式进行定义。

- 我们经常听到服务提供商这样说："如果类遵从某个特定接口，那么就履行这项服务"。下面给出一个具体的示例。Arrays类中的sort方法承诺可以对对象数组进行排序，但要求满足下列前提：对象所属的类必须实现了Comparable接口。这就是说，任何实现Comparable接口的类都需要包含compareTo方法，并且这个方法的参数必须是一个Object对象，返回一个整型数值。

- 接口中的所有方法自动地属于public。因此，在接口中声明方法时，不必提供关键字public。

- 接口可能包含多个方法，在接口中还可以定义常量。然而，更为重要的是要知道接口不能提供哪些功能。接口绝不能含有实例域，在Java SE 8之前，也不能在接口中实现方法。（当然，这些方法不能引用实例域----接口没有实例。）

- 警告：在接口声明中，没有将compareTo方法声明为public，这是因为在接口中的所有方法都自动地是public。不过，在实现接口时，必须把方法声明为public；否则，编译器将认为这个方法的访问属性是包可见性，即类的默认访问属性

- 为什么不直接在类内部提供一个compareTo方法，而必须实现Comparable接口呢？因为Java是强类型语言，在调用sort方法前，编译器会检查这个方法是否存在

- 继承体系中的接口

  - Employee实现的是`Comparable<Employee>`接口，Manager扩展/继承了Employee，如果Manager对compareTo方法也覆盖了，那就必须要有经理与雇员相比较的思想准备，而不能把雇员转变为经理再与经理比较

  - 如果子类之间的比较含义不一样，那就属于不同类对象的非法比较。每个compareTo方法都应该在开始时进行下列检测：`if (getClass() != other.getClass()) throw new ClassCastException();`

  - 如果存在这样一种通用算法（叫规则更好），它能够对两个不同的子类对象进行比较，则应该在超类中提供一个compareTo方法，并将这个方法声明为final。

  - 例如，假设不管薪水的多少都想让经理大于雇员，像Executive和Secretary这样的子类又该怎么办呢？如果一定要按照职务排列的话，那就应该在Employee类中提供一个rank方法。每个子类覆盖rank，并实现一个考虑rank值的compareTo方法。

#### 接口的特性

- 接口不是类，尤其不能使用new运算符实例化一个接口，然而，尽管不能构造接口的对象，却能声明接口的变量，接口变量必须引用实现了接口的类对象：

  ```java
  x = new Comparable(..); // ERROR
    Comparable x; // OK
    x = new Employee(...); // OK
  ```

- 接下来，如同使用instanceof检查一个对象是否属于某个特定类一样，也可以使用instance检查一个对象 是否实现了某个特定的接口：`if (anObject instancef comparable) {...}`

- 与可以建立类的继承关系一样，接口也可以被扩展。这里允许存在多条从具有较高通用性的接口到较高专用性 的接口的链。

- 虽然在接口中不能包含实例域或静态方法，但却可以包含常量。与接口中的方法都自动地被设置为public一样，接口中的域将被自动设为public static final。

- 尽管每个类只能够拥有一个超类，但却可以实现多个接口。这就为定义类的行为提供了极大的灵活性。例如，Java程序设计语言有一个非常重要的内置接口，称为Cloneable（将在6.2.3节中给予详细的讨论）。如果某个类实现了这个Cloneable接口，Object类中的clone方法就可以创建类对象的一个拷贝。如果希望自己设计的类拥有克隆和比较的能力，只要实现这两个接口就可以了。使用逗号将实现的各个接口分隔开。`class Employee implements Cloneable, Comparable`

#### 接口与抽象类

- 为什么Java程序设计语言还要不辞辛苦地引入接口概念？为什么不将Comparable直接设计成抽象类。 然后，Employee类再直接扩展这个抽象类，并提供compareTo方法的实现。因为Java只支持单继承，Employee已经扩展了Person类了

- 有些程序设计语言允许一个类有多个超类，例如C++。我们将此特性称为多重继承（multiple inheritance）。而Java的设计者选择了不支持多继承，其主要原因是多继承会让语言本身变得非常复杂（如同C++），效率也会降低（如同Eiffel）。

- 实际上，接口可以提供多重继承的大多数好处，同时还能避免多重继承的复杂性和低效性。

- C++注释：C++具有多重继承特性，随之带来了一些诸如虚基类、控制规则和横向指针类型转换等复杂特性。很少有C++程序员使用多继承，甚至有些人说：就不应该使用多继承。

#### 接口中的静态方法

- 在Java SE 8中，允许在接口中增加静态方法。理论上讲，没有任何理由认为这是不合法的。只是这有违于将接口作为抽象规范的初衷。目前为止，通常的做法都是将静态方法放在伴随类中。

#### 接口中的默认方法

- 可以为接口方法提供一个默认实现。必须用default修饰符标记这样一个方法。

- 默认实现可以解决编译冲突的问题：

  - 比如你只想实现接口中的几个方法，如果没有默认实现的方法，那么自定义的类得把所有方法都实现一遍才行。

  - 接口演化（interface evolution）：很早以前定义的类实现了一个接口，后来这个接口增加了一个非默认方法，再重新编译这个自定义的类则会报错，应该增添默认实现方法，保证源代码兼容

- 注释：在Java API中，你会看到很多接口都有相应的伴随类，这个伴随类中实现了相应接口的部分或所有方法，如Collection/AbstractCollection或MouseListener/MouseAdapter。在Java SE 8中，这个技术已经过时。现在可以直接在接口中实现方法。

#### 解决默认方法冲突

- 如果先在一个接口中将一个方法定义为默认方法，然后又在超类或另一个接口中定义了同样的方法，会发生什么情况，Java的规则相当简单

  - 超类优先。如果超类提供了一个具体方法，接口中的同名而且有相同参数类型的默认方法会被忽略。

  - 接口冲突。如果一个超接口提供了一个默认方法，另一个接口提供了一个同名而且参数类型（不论是否是默认参数）相同的方法，必须覆盖这个方法来解决冲突

### 接口示例

#### 接口与回调

- 回调（callback）是一种常见的程序设计模式。在这种模式中，可以指出某个特定事件发生时应该采取的动作。例如，可以指出在按下鼠标或选择某个菜单项时应该采取什么行动。

#### Comparator接口

- 对一个字符串数组排序，因为String类实现了`Comparable<String>`，而且String.compareTo方法可以按字典顺序比较字符串。

- 现在假设我们希望按长度递增的顺序对字符串进行排序，而不是按字典顺序进行排序。肯定不能让String类用两种不同的方式实现compareTo方法----更何况，String类也不应由我们来修改。要处理这种情况，Arrays.sort方法还有第二个版本，有一个数组和一个比较器（comparator）作为参数，比较器是实现了Comparator接口的类的实例。

  ```java
  public interface Compartor<T> { 
        int compare(T first, T second);
    }
  ```

  要按长度比较字符串，可以如下定义一个实现`Comparator<String>`的类：

  ```java
  class LengthComparator implements Comparator<String> { 
        public int compare(String first, String second) {
            return first.length() - second.length();
        }
    }
  ```

- 比较器的使用

  - 手动使用

    具体完成比较时，需要建立一个实例：

    ```java
    Comprator<String> comp = new LengthComparator();
      if (comp.compare(words[i], words[i] > 0)) ...
    ```

    将这个调用与`words[i].compareTo(words[j])`做比较。这个compare方法要在比较器对象上调用，而不是在字符串本身上调用。

  - 要对一个数组排序，需要为Arrays.sort方法传入一个LengthComparator对象：

    ```java
    String[] friends = { "peter", "Paul", "Mary"};
      Arrays.sort(friends, new LengthComparator());
    ```

#### 对象克隆

- 要了解克隆的具体含义，先来回忆为一个包含对象引用的变量建立副本时会发生什么。原变量和副本都是同一个对象的引用。这说明，任何一个变量改变都会影响另一个变量。

- 如果希望copy是一个新对象，它的初始状态与original相同，但是之后它们各自会有自己不同的状态，这种情况下就可以使用clone方法。

- 浅拷贝，类的某些域如果是可变的对象，那么拷贝时会引用同一份可变域，这就是浅拷贝

- 深拷贝，把类的所有可变的域对象都重新复制一遍

- 注释：Cloneable接口是Java提供的一组标记接口（tagging interface）之一。（有些程序员称之为记号接口（marker interface））。应该记得，Comparable等接口的通常用途是确保一个类实现一个或一组特定的方法。标记接口不包含任何方法；它唯一的作用就是允许在类型查询中使用instanceof。**建议你自己的程序中不要使用标记接口。**

- 即使clone的默认（浅拷贝）实现能够满足要求，还是需要实现Cloneable接口，将clone重新定义为public，再调用super.clone（）。

- 如果在一个对象上调用clone，但这个对象的类并没有实现Cloneable接口，Object类的clone方法就会抛出一个CloneNotSupportedException。

### lambda表达式

- lambda表达式是一个可传递的代码块，可以在以后执行一次或多次。lambda表达式就是一个代码块，以及必须传入代码的变量规范。比如：

  ```java
  (String first, String second) ->
    {
        if (first.length() < second.length()) return -1;
        else if (first.length() > second.length()) return 1;
        else return 0;
    }
  ```

- 即使没有参数，也需要提供空括号，就像无参方法一样

  ```java
  () -> { for (int i = 100; i >= 0; i--) System.out.println(i); }
  ```

- 如果方法只有一个参数，且参数类型可以推到出来（如String会调用length()方法），则可以省略小括号

  ```java
  ActionListener listener = event->System.out.println("The time is " + new Date()"); // instead of (event)-> ... or (ActionEvent event)-> ...
  ```

- 无需指定lambda表达式的返回类型。lambda表达式的返回类型总是会由上下文推导得出。但是注意，lambda表达式里的所有分支对于是否有返回值要一致，否则是不合法的

- 比较器例子

  ```java
  String[] planets = new String[] { "Mercury", "Venus", "Earth", "Mars", 
        "Jupiter", "Saturn", "Uranus", "Neptune" };
    System.out.println(Arrays.toString(planets));
    System.out.println("Sorted in dictionary order:");
    Arrays.sort(planets);
    System.out.println(Arrays.toString(planets));
    System.out.println("Sorted by length:");
    Arrays.sort(planets, (first, second) -> first.length() - second.length());
  ```

#### 函数式接口

- 对于只有一个抽象方法的接口，需要这种接口的对象时，就可以提供一个lambda表达式。这种接口称为函数式接口（functional interface）。

- 为了展示如何转换为函数式接口，下面考虑Arrays.sort方法。它的第二个参数需要一个Comparator实例，Comparator就是只有一个方法的接口，在底层，Arrays.sort方法会接收实现了`Comparator<String>`的某个类的对象。在这个对象上调用compare方法会执行这个lambda表达式的体。这些对象和类的管理完全取决于具体实现，与使用传统的内联类相比，这样可能要高效得多。最好把lambda表达式看作是一个函数，而不是一个对象，另外要接受lambda表达式可以传递到函数式接口。

- 实际上，在Java中，对lambda表达式所能做的也只是能转换为函数式接口。在其他支持函数字面量的程序设计语言中，可以声明函数类型（如（String，String）->int）、声明这些类型的变量，还可以使用变量保存函数表达式。不过，Java设计者还是决定保持我们熟悉的接口概念，没有为Java语言增加函数类型。

- java.util.function包中有一个尤其有用的接口Predicate，ArrayList类有一个removeIf方法，它的参数就是一个Predicate。这个接口专门用来传递lambda表达式。例如，

  ```java
  public interface Predicate<T> {
        boolean test(T t);
    }

    list.removeIf(e -> e == null);
  ```

#### 方法引用

方法引用等价于lambda表达式

```java
Timer t = new Timer(1000, System.out::println);
```

#### 构造器引用

构造器引用与方法引用很类似，只不过方法名为new。例如，Person：：new是Person构造器的一个引用。哪一个构造器呢？这取决于上下文。

#### 变量作用域

- lambda表达式可以访问外围方法或类中的变量，即自由变量，Java可以捕获(capture)它们，可以称之为闭包(closure)

  ```java
  public static void repeatMessage(String text) {
        ActionListener listener = event -> {
            System.out.println(text);
        }
    }
  ```

- 这里有一个重要的限制。在lambda表达式中，只能引用值不会改变的变量。

  ```java
  public static void repeatMessage(String text) {
        for (int i = 0; i < 10; ++i) {
            ActionListener listener = event -> {
                System.out.println(i + " " + text); // error! 
            }
        }
    }
  ```

- 这里有一条规则：lambda表达式中捕获的变量必须实际上是最终变量（effectively final）。实际上的最终变量是指，这个变量初始化之后就不会再为它赋新值。

- lambda表达式的体与嵌套块有相同的作用域。这里同样适用命名冲突和遮蔽的有关规则。在lambda表达式中声明与一个局部变量同名的参数或局部变量是不合法的。

- 在方法中，不能有两个同名的局部变量，因此，lambda表达式中同样也不能有同名的局部变量。

- 在一个lambda表达式中使用this关键字时，是指创建这个lambda表达式的方法的this参数。

#### 处理lambda表达式

- 使用lambda表达式的重点是延迟执行（deferred execution）。毕竟，如果想要立即执行代码，完全可以直接执行，而无需把它包装在一个lambda表达式中。之所以希望以后再执行代码，这有很多原因，如：

  - 在一个单独的线程中运行代码；

  - 多次运行代码；

  - 在算法的适当位置运行代码（例如，排序中的比较操作）；

  - 发生某种情况时执行代码（如，点击了一个按钮，数据到达，等等）；

  - 只在必要时才运行代码。

#### 再谈Comparator

### 内部类

- 内部类（inner class）是定义在另一个类中的类。为什么需要使用内部类呢？其主要原因有以下三点：

  - 内部类方法可以访问该类定义所在的作用域中的数据，包括私有的数据。

  - 内部类可以对同一个包中的其他类隐藏起来。

  - 当想要定义一个回调函数且不想编写大量代码时，使用匿名（anonymous）内部类比较便捷。

- C++注释：C++有嵌套类(nested class)。一个被嵌套的类包含在外围类的作用域内。下面是一个典型的例子，一个链表类定义了一个存储结点的类和一个定义迭代器位置的类。

  ```c++
  class LinkedList {
        public:
            class Iterator {
                public:
                    void insert(int x);
                    int erase();
                    ...
            };
            ...
        private:
            class Link {
                public:
                    Link* next;
                    int data;
            };
            ...
    }
  ```

- 嵌套是一种类之间的关系，而不是对象之间的关系。一个LinkedList对象并不包含Iterator类型或Link类 型的子对象。

- 嵌套类有两个好处：命名控制和访问控制。由于名字Iterator嵌套在LinkedList类的内部，所以在外部被命名为LinkedList::Iterator，这样就不会与其他名为Iterator的类发生冲突。在Java中这个并不重要，因为Java包已经提供了相同的命名控制。需要注意的是，Link类位于LinkedList类的私有部分，因此，Link对其他的代码均不可见。鉴于此情况，可以将Link的数据域设计为公有的，它仍然是安全的。这些数据域只能被LinkedList类（具有访问这些数据域的合理需要）中的方法访问，而不会暴露给其他的代码。在Java中，只有内部类能够实现这样的控制。

- 然而，Java内部类还有另外一个功能，这使得它比C++的嵌套类更加丰富，用途更加广泛。内部类的对象有一个隐式引用，它引用了实例化该内部对象的外围类对象。通过这个指针，可以访问外围类对象的全部状态。在Java中，static内部类没有这种附加指针，这样的内部类与C++中的嵌套类很相似。

#### 举例

- 这里的TimePrinter类位于TalkingClock类内部。这并不意味着每个TalkingClock都有一个TimePrinter实例域。如前所示，TimePrinter对象是由TalkingClock类的方法构造。

- beep变量是外部类对象的数据域，之所以能够引用，是因为内部类有一个**隐式引用**指向了创建它的外部类对象，这个引用在定义中是不可见的。**外围类的引用在构造器中设置**。编译器修改了所有的内部类的构造器，添加一个外围类引用的参数。

  ```java
  public class InnerClassTest
    {
    public static void main(String[] args)
    {
        TalkingClock clock = new TalkingClock(1000, true);
        clock.start();

        // keep program running until user selects "Ok"
        JOptionPane.showMessageDialog(null, "Quit program?");
        System.exit(0);
    }
    }

    /**
    * A clock that prints the time in regular intervals.
    */
    class TalkingClock
    {
    private int interval;
    private boolean beep;

    /**
        * Constructs a talking clock
        * @param interval the interval between messages (in milliseconds)
        * @param beep true if the clock should beep
        */
    public TalkingClock(int interval, boolean beep)
    {
        this.interval = interval;
        this.beep = beep;
    }

    /**
        * Starts the clock.
        */
    public void start()
    {
        ActionListener listener = new TimePrinter();
        Timer t = new Timer(interval, listener);
        t.start();
    }

    public class TimePrinter implements ActionListener
    {
        public void actionPerformed(ActionEvent event)
        {
            System.out.println("At the tone, the time is " + new Date());
            if (beep) Toolkit.getDefaultToolkit().beep();
        }
    }
    }
  ```

#### 内部类的特殊语法规则

- 使用外部类引用的正规语法还比较复杂，`OuterClass.this`表示外部类引用，比如，上面代码的内部类可以这样写

  ```java
  if (TalkingClock.this.beep) Toolkit.getDefaultToolkit().beep();
  ```

- 反过来，构造内部对象时用`outerObject.new InnerClass()`

  ```java
  TalkingClock jabberer = new TalkingClock(1000, true);
    TalkingClock.TimePrinter listener = jabberer.new TimePrinter();
  ```

- 需要注意，在外围类的作用域之外，可以这样引用内部类：`OuterClass.InnerClass`

- 注释：内部类中声明的所有静态域都必须是final。原因很简单。我们希望一个静态域只有一个实例，不过对于每个外部对象，会分别有一个单独的内部类实例。如果这个域不是final，它可能就不是唯一的。

#### 局部内部类

- 可以在一个方法中定义类，这就是局部内部类，不能用public或private访问说明符进行声明，它的作用域只在声明这个局部类的块中

- 局部内部类可以对外部世界完全隐藏起来

#### 由外部方法访问变量

- 与其他内部类相比较，局部类还有一个优点。它们不仅能够访问包含它们的外部类，还可以访问局部变量。不过，那些局部变量必须事实上为final。这说明，它们一旦赋值就绝不会改变。

#### 匿名内部类

- 假如只创建这个类的一个对象，就不必命名了。这种类被称为匿名内部类（anonymous inner class)。

  ```java
  public void start(int interval, boolean beep)
    {
        ActionListener listener = new ActionListener()
            {
                public void actionPerformed(ActionEvent event)
                {
                System.out.println("At the tone, the time is " + new Date());
                if (beep) Toolkit.getDefaultToolkit().beep();
                }
            };
        Timer t = new Timer(interval, listener);
        t.start();
    }
    new SuperType(construction parameters) {
        inner class methods and data
    }
  ```

- 由于构造器的名字必须与类名相同，而匿名类没有类名，所以，匿名类不能有构造器。

- 如果构造参数的闭小括号后面跟一个开大括号，正在定义的就是匿名内部类。

  ```java
  Person queen = new Person("Mary"); // a Person object
    Person count = new Person("Dracula") {...} // an object of an inner class extending Person
  ```

- 多年来，Java程序员习惯的做法是用匿名内部类实现事件监听器和其他回调。如今最好还是使用lambda表达式

#### 静态内部类

- 有时候，使用内部类只是为了把一个类隐藏在另外一个类的内部，并不需要内部类引用外围类对象。为此，可以将内部类声明为static，以便取消产生的引用。

- 当然，只有内部类可以声明为static。静态内部类的对象除了没有对生成它的外围类对象的引用特权外，与其他所有内部类完全一样。

### 代理

- 在本章的最后，讨论一下代理（proxy）。利用代理可以在运行时创建一个实现了一组给定接口的新类。这种功能只有在编译时无法确定需要实现哪个接口时才有必要使用。对于应用程序设计人员来说，遇到这种情况的机会很少。如果对这种高级技术不感兴趣，可以跳过本节内容。然而，对于系统程序设计人员来说，代理带来的灵活性却十分重要。

## 第7章 异常、断言和日志

### 处理错误

- 在Java中，如果某个方法不能够采用正常的途径完整它的任务，就可以通过另外一个路径退出方法。在这种情况下，方法并不返回任何值，而是抛出（throw）一个封装了错误信息的对象。需要注意的是，这个方法将会立刻退出，并不返回任何值。此外，调用这个方法的代码也将无法继续执行，取而代之的是，异常处理机制开始搜索能够处理这种异常状况的异常处理器（exception handler）

#### 异常分类

- 在Java程序设计语言中，异常对象都是派生于Throwable类的一个实例。稍后还可以看到，如果Java中内置的异常类不能够满足需求，用户可以创建自己的异常类。

- 所有的异常都是由Throwable继承而来，但在下一层立即分解为两个分支：Error和Exception。 Error类层次结构描述了Java运行时系统的内部错误和资源耗尽错误。应用程序不应该抛出这种类型的对象。

- 在设计Java程序时，需要关注Exception层次结构。这个层次结构又分解为两个分支：一个分支派生于RuntimeException；另一个分支包含其他异常。划分两个分支的规则是：由程序错误导致的异常属于RuntimeException；而程序本身没有问题，但由于像I/O错误这类问题导致的异常属于其他异常。

- 派生于RuntimeException的异常包含下面几种情况：

  - 错误的类型转换。

  - 数组访问越界。

  - 访问null指针。

- 不是派生于RuntimeException的异常包括：

  - 试图在文件尾部后面读取数据。

  - 试图打开一个不存在的文件。

  - 试图根据给定的字符串查找Class对象，而这个字符串表示的类并不存在。

- "如果出现RuntimeException异常，那么就一定是你的问题"是一条相当有道理的规则。

- Java语言规范将派生于Error类或RuntimeException类的所有异常称为非受查（unchecked）异常，所有其他的异常称为受查（checked）异常。编译器将核查是否为所有的受查异常提供了异常处理器。

- 注释：RuntimeException这个名字很容易让人混淆。实际上，现在讨论的所有错误都发生在运行时。 C++注释：如果熟悉标准C++类库中的异常层次结构，就一定会感到有些困惑。C++有两个基本的异常类，一个是runtime_error；另一个是logic_error。**logic_error类相当于Java中的RuntimeException，它表示程序中的逻辑错误；runtime_error类是所有由于不可预测的原因所引发的异常的基类。它相当于Java中的非RuntimeException异常。**

#### 声明受查异常

- 需要记住在遇到下面4种情况时应该抛出异常：

  1. 调用一个抛出受查异常的方法，例如，FileInputStream构造器。

  2. 程序运行过程中发现错误，并且利用throw语句抛出一个受查异常（下一节将详细地介绍throw语句）

  3. 程序出现错误，例如，a[–1]=0会抛出一个ArrayIndexOutOfBoundsException这样的非受查异 常.

  4. Java虚拟机和运行时库出现的内部错误。

- 如果一个方法有可能抛出多个受查异常类型，那么就必须在方法的首部列出所有的异常类。每个异常类之间用逗号隔开。如下面这个例子所示：

  ```java
  class MyAnimation {
        public Image loadImage(String s) throws FileNotFoundException, EOFException {
            ...
        }
    }
  ```

- 但是，不需要声明Java的内部错误，即从Error继承的错误。任何程序代码都具有抛出那些异常的潜能，而我们对其没有任何控制能力。

- 同样，也不应该声明从RuntimeException继承的那些非受查异常。（如ArrayIndexOfBoundException，这些RuntimeException完全在我们的控制之下，我们应该花费精力修正程序错误，而不是说明错误发生的可能性上

- 总之，一个方法必须声明所有可能抛出的受查异常，而非受查异常要么不可控制（Error），要么就应该避免发生（RuntimeException）。如果方法没有声明所有可能发生的受查异常，编译器就会发出一个错误消息。

- 如果在子类中覆盖了超类的一个方法，子类方法中声明的受查异常不能比超类方法中声明的异常更通用（也就是说，子类方法中可以抛出更特定的异常，或者根本不抛出任何异常）。特别需要说明的是，如果超类方法没有抛出任何受查异常，子类也不能抛出任何受查异常。

#### 如何抛出异常

- 对于一个已经存在的异常类，将其抛出非常容易。在这种情况下：

  1. 找到一个合适的异常类。

  2. 创建这个类的一个对象。

  3. 将对象抛出。

- 一旦方法抛出了异常，这个方法就不可能返回到调用者。也就是说，不必为返回的默认值或错误代码担忧。

  ```java
   String readData(Scanner in) throws EOFException {
        while (...) {
            if (!in.hasNext()) { // EOF encountered
                if (n < len) throw new EOFExcpetion();
            }
        }
        return s;
  }
  ```

- C++注释：在C++与Java中，抛出异常的过程基本相同，只有一点微小的差别。在Java中，只能抛出Throwable子类的对象，而在C++中，却可以抛出任何类型的值。

#### 创建异常类

- 我们需要做的只是定义一个派生于Exception的类，或者派生于Exception子类的类。例如，定义一个派生于IOException的类。习惯上，定义的类应该包含两个构造器，一个是默认的构造器；另一个是带有详细描述信息的构造器（超类Throwable的toString方法将会打印出这些详细信息，这在调试中非常有用）。

  ```java
   class FileFormatException extends IOException {
        public FileFormatException() {}
        public FileFormatException(String gripe) {
            super(gripe);
        }
   }
  ```

### 捕获异常

#### 捕获异常

- 如果某个异常发生的时候没有在任何地方进行捕获，那程序就会终止执行，并在控制台上打印出异常信息，其中包括异常的类型和堆栈的内容。

- 要想捕获一个异常，必须设置try/catch语句块。最简单的try语句块如下所示： 如果在try语句块中的任何代码抛出了一个在catch子句中说明的异常类，那么：

  1. 程序将跳过try语句块的其余代码。

  2. 程序将执行catch子句中的处理器代码。

- 如果在try语句块中的代码没有抛出任何异常，那么程序将跳过catch子句。

- 如果方法中的任何代码抛出了一个在catch子句中没有声明的异常类型，那么这个方法就会立刻退出（希望调用者为这种类型的异常设计了catch子句）。

- 如果一个方法可能会出错，有两种选择：try catch处理 or 抛出异常(throws xxxException)，哪种方法更好呢？**通常，应该捕获那些知道如何处理的异常，而将那些不知道怎样处理的异常继续进行传递。**

- 如果想传递一个异常，就必须在方法的首部添加一个throws说明符，以便告知调用者这个方法可能会抛出异常。

- "这个规则也有一个例外。前面曾经提到过：如果编写一个覆盖超类的方法，而这个方法又没有抛出异常（如JComponent中的paintComponent），那么这个方法就必须捕获方法代码中出现的每一个受查异常。不允许在子类的throws说明符中出现超过超类方法所列出的异常类范围。"

#### 捕获多个异常

- "在一个try语句块中可以捕获多个异常类型，并对不同类型的异常做出不同的处理。可以按照下列方式为每个异常类型使用一个单独的catch子句："

- "注释：捕获多个异常不仅会让你的代码看起来更简单，还会更高效。生成的字节码只包含一个对应公共catch子句的代码块。"

#### 再次抛出异常与异常链

- "在catch子句中可以抛出一个异常，这样做的目的是改变异常的类型。"

- "不过，可以有一种更好的处理方法，并且将原始异常设置为新异常的"原因"：

  ```java
  try {
        access the databse
    } catch (SQLException e) {
        Throwable se = new Servlet Exception("database error");
        se.initCause(e);
        throw se;
    }
    ...
    // 当捕获到异常时，就可以使用下面这条语句重新得到原始异常：
    Throwable e = se.getCause();
  ```

强烈建议使用这种包装技术。这样可以让用户抛出子系统中的高级异常，而不会丢失原始异常的细节。"

- 当然，也可以仅仅用日志记录一下异常，再把catch的异常继续往上蹭抛出

#### finally子句

- 当代码抛出一个异常时，就会终止方法中剩余代码的处理，并退出这个方法的执行。如果方法获得了一些本地资源，并且只有这个方法自己知道，又如果这些资源在退出方法之前必须被回收，那么就会产生资源回收问题。"

- "不管是否有异常被捕获，finally子句中的代码都被执行。"

- "try语句可以只有finally子句，而没有catch子句"

- "提示：这里，强烈建议解耦合try/catch和try/finally语句块。这样可以提高代码的清晰度。例如：""内层的try语句块只有一个职责，就是确保关闭输入流。外层的try语句块也只有一个职责，就是确保报告出现的错误。这种设计方式不仅清楚，而且还具有一个功能，就是将会报告finally子句中出现的错误。

  ```java
  try {
    try {
            ...
    } catch {
        in.close();
    }
  } catch (IOExceptione ) {
    // show error message
  }
  ```

#### 带资源的try语句

- 假设我们在try catch语句中干一些事，其中可能会发生IOException，最后关闭输入流，输入流关闭时也可能发生IOException，如果简单把关闭输入流的操作放在finally子句中，那它可能会覆盖原本代码的抛出的IOException，如果想保留原始的异常，则需要嵌套的try catch语句，比较复杂

- 下面的try语句退出时，会自动调用res.close()，无论是正常退出或者存在异常，都会调用，就好像使用了finally子句一样

  ```java
    try (Scanner in = new Scanner(new FileInputStream("text.log"))) {
        while (in.hasNext()) {
            ...
        }
    }
  ```

- "原来的异常会重新抛出，而close方法抛出的异常会"被抑制"。这些异常将自动捕获，并由addSuppressed方法增加到原来的异常。如果对这些异常感兴趣，可以调用getSuppressed方法，它会得到从close方法抛出并被抑制的异常列表。"

- "注释：带资源的try语句自身也可以有catch子句和一个finally子句。这些子句会在关闭资源之后执行。不过在实际中，一个try语句中加入这么多内容可能不是一个好主意。"

#### 分析堆栈轨迹元素

- 堆栈轨迹（stack trace）是一个方法调用过程的列表，它包含了程序执行过程中方法调用的特定位置。前面已经看到过这种列表，当Java程序正常终止，而没有捕获异常时，这个列表就会显示出来。

- 可以调用Throwable类的printStackTrace方法访问堆栈轨迹的文本描述信息。"

### 使用异常机制的技巧（早抛出晚捕获）

1. 异常处理不能代替简单的测试

2. 不要过分地细化异常

3. 利用异常层次结构

4. 不要压制异常

5. 在检测错误时，苛刻 "要比放任更好

6. 不要羞于传递异常

### 使用断言

#### 概念

- 断言是致命的，不可恢复的，断言只用于开发和测试阶段

- Java语言引入了关键字assert，有两种形式

  ```java
  assert 条件
    assert 条件:表达式
  ```

- "这两种形式都会对条件进行检测，如果结果为false，则抛出一个AssertionError异常。在第二种形式中，表达式将被传入AssertionError的构造器，并转换成一个消息字符串。

- 注释："表达式"部分的唯一目的是产生一个消息字符串。AssertionError对象并不存储表达式的值"

- "C++注释：C语言中的assert宏将断言中的条件转换成一个字符串。当断言失败时，这个字符串将会被打印出来。例如，若assert（x>=0）失败，那么将打印出失败条件"x>=0"。在Java中，条件并不会自动地成为错误报告中的一部分。如果希望看到这个条件，就必须将它以字符串的形式传递给AssertionError对象：assert x>=0："x>=0"。"

#### 启用/禁用断言

- "在默认情况下，断言被禁用。可以在运行程序时用-enableassertions或-ea选项启用：`java -enableassertions MyApp`

- 需要注意的是，在启用或禁用断言时不必重新编译程序。启用或禁用断言是类加载器（class loader）的功能。当断言被禁用时，类加载器将跳过断言代码，因此，不会降低程序运行的速度。

- 也可以在某个类或整个包中使用断言，例如：`java -ea:MyClass -ea:com.mycompany.mylib... MyApp`

- 这条命令将开启MyClass类以及在com.mycompany.mylib包和它的子包中的所有类的断言。选项-ea将开启默认包中的所有类的断言。

- 也可以用选项-disableassertions或-da禁用某个特定类和包的断言：`java -ea:... -da:MyClass MyApp`

- 有些类不是由类加载器加载，而是直接由虚拟机加载。可以使用这些开关有选择地启用或禁用那些类中的断言。"

### 记录日志

- 记录日志API就是为了解决这个问题而设计的。下面先讨论这些API的优点。

  - 可以很容易地取消全部日志记录，或者仅仅取消某个级别的日志，而且打开和关闭这个操作也很容易。

  - 可以很简单地禁止日志记录的输出，因此，将这些日志代码留在程序中的开销很小。

  - 日志记录可以被定向到不同的处理器，用于在控制台中显示，用于存储在文件中等。

  - 日志记录器和处理器都可以对记录进行过滤。过滤器可以根据过滤实现器制定的标准丢弃那些无用的记录项。

  - 日志记录可以采用不同的方式格式化，例如，纯文本或XML。

  - 应用程序可以使用多个日志记录器，它们使用类似包名的这种具有层次结构的名字，例如，com.mycompany.myapp。

  - 在默认情况下，日志系统的配置由配置文件控制。如果需要的话，应用程序可以替换这个配置。"

### 调试技巧

1. 打印变量，System.out.println or logger.info(xx) or xxxClass.toString()

2. 一个不太为人所知但却非常有效的技巧是在每一个类中放置一个单独的main方法。这样就可以对每一个类进行单元测试。利用这种技巧，只需要创建少量的对象，调用所有的方法，并检测每个方法是否能够正确地运行就可以了。另外，可以为每个类保留一个main方法，然后分别为每个文件调用Java虚拟机进行运行测试。在运行applet应用程序的时候，这些main方法不会被调用，而在运行应用程序的时候，Java虚拟机只调用启动类的main方法。"

3. 第2点的技巧，可以用junit单元测试框架来实现

4. 日志代理

5. "利用Throwable类提供的printStackTrace方法，可以从任何一个异常对象中获得堆栈情况。"

6. printStackTrace(PrintWriter s)将堆栈轨迹发送到文件中

7. "通常，将一个程序中的错误信息保存在一个文件中是非常有用的，`java myprog 1>errors.txt 2>&1

8. 略

9. "要想观察类的加载过程，可以用-verbose标志启动Java虚拟机<有时候，这种方法有助于诊断由于类路径引发的问题。

10. -Xlint选项告诉编译器对一些普遍容易出现的代码问题进行检查"

11. jconsole

12. "可以使用jmap实用工具获得一个堆的转储，其中显示了堆中的每个对象。"

13. "如果使用-Xprof标志运行Java虚拟机，就会运行一个基本的剖析器来跟踪那些代码中经常被调用的方法。剖析信息将发送给System.out。输出结果中还会显示哪些方法是由即时编译器编译的。"

## 第8章 泛型程序设计（Generic programming）

- 至少在表面上看来，泛型很像C++中的模板。与Java一样，在C++中，模板也是最先被添加到语言中支持强类型集合的。但是，多年之后人们发现模板还有其他的用武之地。学习完本章的内容可以发现Java中的泛型在程序中也有新的用途。

### why

#### 类型参数的好处（可读性&安全性）

- 在Java支持泛型类之前，泛型程序设计非常挫，有一个Object引用的数组

  ```java public class ArrayList {

  ```
  private Object[] elementData;
    public Object get(int i) {...}
    public void add(Object o) {...}
  ```

  }

- 这样有两个问题，第一，获取一个值必须要强制类型转换，第二，没有错误检查，这也就意味着可以往里面添加任何类对象，编译和运行都不会报错，只有在最后强转时才会产生错误

  ```java
  ArrayList files = new ArrayList();
    files.add("filename.txt");
    String filename = (String) files.get(0);
    files.add(new File("...")); // 往ArrayList中添加File类对象，编译和运行不会报错
  ```

- 泛型提供了一个更好的解决方案：类型参数（type parameters）。ArrayList类有一个类型参数用来指示元素的类型：

  ```java
  ArrayList<String> files = new ArrayList<String>();
  ```

- 这使得代码具有更好的可读性。人们一看就知道这个数组列表中包含的是String对象。

- 注释：前面已经提到，在Java SE 7及以后的版本中，构造函数中可以省略泛型类型：省略的类型可以从变量的类型推断得出。

  ```java
  ArrayList<String> files = new ArrayList<>();
  ```

- 编译器也可以很好地利用这个信息。当调用get的时候，不需要进行强制类型转换，编译器就知道返回值类型为String，而不是Object：

  ```java
  String filename = files.get(0);
  ```

- 编译器还知道`ArrayList<String>`中add方法有一个类型为String的参数。这将比使用Object类型的参数安全一些。现在，编译器可以进行检查，避免插入错误类型的对象。下面的例子就无法通过编译，出现编译错误比类在运行时出现类的强制类型转换异常要好得多

  ```java
  files.add(new File("xxx")); // error
  ```

### 定义简单泛型类

- 一个泛型类（generic class）就是具有一个或多个类型变量的类。本章使用一个简单的Pair类作为例子。对于这个类来说，我们只关注泛型，而不会为数据存储的细节烦恼。下面是Pair类的代码：

  ```java
  public class Pair<T> 
    {
    private T first;
    private T second;

    public Pair() { first = null; second = null; }
    public Pair(T first, T second) { this.first = first;  this.second = second; }

    public T getFirst() { return first; }
    public T getSecond() { return second; }

    public void setFirst(T newValue) { first = newValue; }
    public void setSecond(T newValue) { second = newValue; }

    public String toString() { return "(" + first + ", " + second + ")"; }

    public static <T> Pair<T> makePair(Supplier<T> constr)
    {
        return new Pair<>(constr.get(), constr.get());
    }

    public static <T> Pair<T> makePair(Class<T> cl)
    {
        try { return new Pair<>(cl.newInstance(), cl.newInstance()); }
        catch (Exception ex) { return null; }
    }        
    }
  ```

- C++注释：从表面上看，Java的泛型类类似于C++的模板类。唯一明显的不同是Java没有专用的template关键字。但是，在本章中读者将会看到，这两种机制有着本质的区别。

#### 泛型方法

- 前面已经介绍了如何定义一个泛型类。实际上，还可以定义一个带有类型参数的简单方法。

  ```java
  class ArrayAlg {
        public static <T> T getMiddle(T... a) {
            return a[a.length / 2];
        }
    }
  ```

- 这个方法是在普通类中定义的，而不是在泛型类中定义的。然而，这是一个泛型方法，可以从尖括号和类型变量看出这一点。注意，类型变量放在修饰符（这里是public static）的后面，返回类型的前面。

- 泛型方法可以定义在普通类中，也可以定义在泛型类中。

- 当调用一个泛型方法时，在方法名前的尖括号中放入具体的类型：在这种情况（实际也是大多数情况）下，方法调用中可以省略`<String>`类型参数。编译器有足够的信息能够推断出所调用的方法

  ```java
  String middle = ArrayAlg.<String>getMiddle("John", "Q.", "public");
    String middle = ArrayAlg.getMiddle("John", "Q.", "public"); // 可省略
  ```

#### 类型变量的限定

- 有时，类或方法需要对类型变量加以约束，比如，假设泛型类需要类型参数T具有compareTo方法，解决这个问题的方案是将T限制为实现了Comparable接口（只含一个方法compareTo的标准接口）的类。可以通过对类型变量T设置限定（bound）实现这一点，如果传入的参数不是实现Comparable接口的类，则会报编译错误

  ```java
  public static <T extends Comparable> T min(T[] a) ...
  ```

- C++注释：在C++中不能对模板参数的类型加以限制。如果程序员用一个不适当的类型实例化一个模板，将会在模板代码中报告一个（通常是含糊不清的）错误消息。

- 读者或许会感到奇怪----在此为什么使用关键字extends而不是implements？毕竟，Comparable是一个接口。记法`<T extends BoudingType>`表示T应该是绑定类型的子类型（subtype）。T和绑定类型可以是类，也可以是接口。选择关键字extends的原因是更接近子类的概念，并且Java的设计者也不打算在语言中再添加一个新的关键字（如sub）。

- 可以有多个限定，用`&`分隔，如`T extends Comparable & Serializable`，`,`是用来分隔类型变量的

### 泛型代码和虚拟机

- **虚拟机没有泛型类型对象----所有对象都属于普通类**

#### 类型擦除

- 无论何时定义一个泛型类型，都自动提供了一个相应的原始类型（raw type）。原始类型的名字就是删去类型参数后的泛型类型名。擦除（erased）类型变量，并替换为限定类型（无限定的变量用Object）。

- 因为T是一个无限定的变量，所以直接用Object替换。结果是一个普通的类，就好像泛型引入Java语言之前已经实现的那样。

- C++注释：就这点而言，Java泛型与C++模板有很大的区别。C++中每个模板的实例化产生不同的类型，这一现象称为"模板代码膨胀"。Java不存在这个问题的困扰。

#### 翻译泛型表达式

- 当程序调用泛型方法时，如果擦除返回类型，编译器插入强制类型转换。`Employee buddy = buddies.getFirst()`，也就是说，编译器把这个方法调用翻译为两条虚拟机指令：

  - 对原始方法Pair.getFirst的调用。

  - 将返回的Object类型强制转换为Employee类型。

- 当存取一个泛型域时也要插入强制类型转换。`Employee buddy = buddies.first`也会在结果字节码中插入强制类型转换。

### 约束与局限性

#### 不能用基本类型实例化类型参数

- 不能用类型参数代替基本类型。因此，没有`Pair<double>`，只有`Pair<Double>`。当然，其原因是类型擦除。擦除之后，Pair类含有Object类型的域，而Object不能存储double值。

- 这的确令人烦恼。但是，这样做与Java语言中基本类型的独立状态相一致。

#### 运行时类型查询只适用于原始类型

- 虚拟机中的对象总有一个特定的非泛型类型。因此，所有的类型查询只产生原始类型。例如：`if (a instanceof Pair<String>) // error`

- 实际上仅仅测试a是否是任意类型的一个Pair。下面的测试同样如此：`if (a instanceof Pair<T>) // error`

- 或强制类型转换：`Pair<String> p = (Pair<String>) a;`

- 为提醒这一风险，试图查询一个对象是否属于某个泛型类型时，倘若使用instanceof会得到一个编译器错误，如果使用强制类型转换会得到一个警告。

- 同样的道理，getClass方法总是返回原始类型。例如下面代码其比较的结果是true，这是因为两次调用getClass都将返回Pair.class。

  ```java
  Pair<String> strPair = ..;
    Pair<Employee> employeePair = ...;
    if (strPair.getClass() == employeePair.getClass()) // they are equal
  ```

#### 不能创建参数化类型的数组（Java不支持泛型类型的数组）

- 不能实例化参数化类型的数组，例如：`Pair<String>[] table = new Pair<String>[10]; //error`

- 这有什么问题呢？擦除之后，table的类型是`Pair[]`。可以把它转换为`Object[]`：`Object[] objarray = table;`

- 数组会记住它的元素类型，如果试图存储其他类型的元素，就会抛出一个Array-StoreException异常

#### Varargs警告

上一节中已经了解到，Java不支持泛型类型的数组。这一节中我们再来讨论一个相关的问题：向参数个数可变的方法传递一个泛型类型的实例。

#### 不能实例化类型变量

- 不能使用像new T（...），new T[...]或T.class这样的表达式中的类型变量。

- 因为类型擦除后，T就变成了Object，你肯定不是像new Object()，在Java SE 8之后，最好的解决办法是让调用者提供一个构造器表达式。例如：`Pair<String> p = Pair.makePair(String::new);`

#### 不能构造泛型数组

- 就像不能实例化一个泛型实例一样，也不能实例化数组。不过原因有所不同，毕竟数组会填充null值，构造时看上去是安全的。不过，数组本身也有类型，用来监控存储在虚拟机中的数组。这个类型会被擦除

- 下面代码是老式做法，利用了反射

  ```java
  public static <T extends Comparable> T[] minmax(T... a)
    {
        T[] mm = (T[]) Array.newInstance(a.getClass().getComponentType(), 2);
        T min = a[0];
        T max = a[0];
        for (int i = 1; i < a.length; i++)
        {
        if (min.compareTo(a[i]) > 0) min = a[i];
        if (max.compareTo(a[i]) < 0) max = a[i];
        }
        mm[0] = min;
        mm[1] = max;
        return (T[]) mm; // compiles with warning
    }
    ...
    String[] ss = ArrayAlg.minmax("Tom", "Dick", "Harry");
    System.out.println(Arrays.toString(ss));
    Integer[] is = ArrayAlg.minmax(1,2,3);
    System.out.println(Arrays.toString(is));
  ```

#### 泛型类的静态上下文中类型变量无效

- 不能在静态域或方法中引用类型变量。

#### 不能抛出或捕获泛型类的实例

- 既不能抛出也不能捕获泛型类对象。实际上，甚至泛型类扩展Throwable都是不合法的。

- catch子句中不能捕获类型变量。

### 泛型类型的继承规则

- 在使用泛型类时，需要了解一些有关继承和子类型的准则。下面先从许多程序员感觉不太直观的情况开始。考虑一个类和一个子类，如Employee和Manager。`Pair<Manager>`是`Pair<Employee>`的一个子类吗？答案是"不是"，

- 注释：必须注意泛型与Java数组之间的重要区别。可以将一个`Manager[]`数组赋给一个类型为`Employee[]`的变量

- 永远可以将参数化类型转换为一个原始类型。例如，Pair

  <employee>是原始类型Pair的一个子类型。在与遗留代码衔接时，这个转换非常必要。</employee>

### 通配符类型

#### 概念

- 通配符类型中，允许类型参数变化。例如，通配符类型`Pair<? extends Employee>`表示任何泛型Pair类型，它的类型参数是Employee的子类，如`Pair<Manager>`，但不是`Pair<String>`。

- 类型`Pair<Manager>`是`Pair<？extends Employee>`的子类型

- 所以方法`public static void printBuddies(Pair<? extends Employee> p)`即可以接收`Pair<Manager>`也可以接收`Pair<Emloyee>`作为参数

#### 通配符的超类型限定

- 通配符限定与类型变量限定十分类似，但是，还有一个附加的能力，即可以指定一个超类型限定（supertype bound），如下所示：`? super Manager`

- 这个通配符限制为Manager的所有超类型。（已有的super关键字十分准确地描述了这种联系，这一点令人感到非常欣慰。）

- 所以方法`public static void printBuddies(Pair<? super Manager> p)`不能接收`Pair<Emloyee>`作为参数，但可以接收`Pair<Manager>`或`Pair<Excutive>`作为参数

#### 无限定通配符

- 还可以使用无限定的通配符，例如，`Pair<？>`。初看起来，这好像与原始的Pair类型一样。实际上，有很大的不同。

- getFirst的返回值只能赋给一个Object。setFirst方法不能被调用，甚至不能用Object调用。`Pair<？>`和Pair本质的不同在于：可以用任意Object对象调用原始Pair类的setObject方法。

- 注释：可以调用setFirst（null）。

- 为什么要使用这样脆弱的类型？它对于许多简单的操作非常有用。例如，下面这个方法将用来测试一个pair是否包含一个null引用，它不需要实际的类型。

  ```java
  public static boolean hasNulls(Pair<?> p) {
    return p.getFirst() == null || p.getSecond() == null;
  }
  ```

#### 通配符捕获

- 通配符不是类型变量，因此，不能在编写代码中使用"？"作为一种类型，可以在通配符参数的方法里面调用带泛型参数的辅助方法，这个泛型参数T会捕获通配符，虽然编写代码时不知道是哪种类型的通配符，但是这是一个明确的类型

  ```java
  public static void swap(Pair<?> p) {
        swapHelper(p);
    }
    public static <T> void swapHelper(Pair<T> p) {
        T t = p.getFirst();
        p.setFirst(p.getSecond());
        p.setSecond(t);
    }
  ```

- 通配符捕获只有在有许多限制的情况下才是合法的。编译器必须能够确信通配符表达的是单个、确定的类型。例如，`ArrayList<Pair<T>>`中的T永远不能捕获`ArrayList<Pair<？>>`中的通配符。

### 反射和泛型

- 反射允许你在运行时分析任意的对象。如果对象是泛型类的实例，关于泛型类型参数则得不到太多信息，因为它们会被擦除。在下面的小节中，可以了解利用反射可以获得泛型类的什么信息。

#### 泛型Class类

- 现在，Class类是泛型的。例如，`String.class`实际上是一个`Class<String>`类的对象（事实上，是唯一的对象）。

- 类型参数十分有用，这是因为它允许`Class<T>`方法的返回类型更加具有针对性。

## 第9章 集合

### Java集合框架

#### 将集合的接口与实现分离

- 与现代的数据结构类库的常见情况一样，Java集合类库也将接口（interface）与实现（implementation）分离。首先，看一下人们熟悉的数据结构----队列（queue）是如何分离的。

- 队列接口指出可以在队列的尾部添加元素，在队列的头部删除元素，并且可以查找队列中元素的个数。当需要收集对象，并按照"先进先出"的规则检索对象时就应该使用队列

- 队列通常有两种实现方式，一种使用循环数组，一种使用链表，每一个实现都可以通过一个实现了Queue接口的类表示

- 在研究API文档时，会发现另外一组名字以Abstract开头的类，例如，AbstractQueue。这些类是为类库实现者而设计的。如果想要实现自己的队列类（也许不太可能），会发现扩展AbstractQueue类要比实现Queue接口中的所有方法轻松得多。

#### Collection接口

- 在Java类库中，集合类的基本接口是Collection接口。这个接口有两个基本方法：

  ```java
   public interface Collection<e> {
    boolean add(E element);
    Iterator<E> iterator();
    ...
  }
  ```

- 除了这两个方法之外，还有几个方法，将在稍后介绍。

- add方法用于向集合中添加元素。如果添加元素确实改变了集合就返回true，如果集合没有发生变化就返回false。例如，如果试图向集中添加一个对象，而这个对象在集中已经存在，这个添加请求就没有实效，因为集中不允许有重复的对象。

- iterator方法用于返回一个实现了Iterator接口的对象。可以使用这个迭代器对象依次访问集合中的元素。下一节讨论迭代器。

#### 迭代器

- Iterator接口包含4个方法：

  ```java
  public interface Iterator<E> {
        E next();
        boolean hasNext();
        void remove();
        default void forEachRemaining(Consumer<? super E> action);
    }
  ```

- for each"循环可以与任何实现了Iterable接口的对象一起工作，这个接口只包含一个抽象方法（如下）。Collection接口扩展了Iterable接口。因此，对于标准类库中的任何集合都可以使用"for each"循环。

  ```java
  public interface Iterable<E> {
        Iterator<E> iterator();
    }
  ```

- Java集合类库中的迭代器与其他类库中的迭代器在概念上有着重要的区别。在传统的集合类库中，例如，C++的标准模版库，迭代器是根据数组索引建模的。如果给定这样一个迭代器，就可以查看指定位置上的元素，就像知道数组索引i就可以查看数组元素a[i]一样。不需要查找元素，就可以将迭代器向前移动一个位置。这与不需要执行查找操作就可以通过i++将数组索引向前移动一样。但是，Java迭代器并不是这样操作的，每次查找迭代器都会变动，查找的唯一方法是调用next，迭代器随着变动。

- 因此，应该将Java迭代器认为是位于两个元素之间。当调用next时，迭代器就越过下一个元素，并返回刚刚越过的那个元素的引用

- 这里还有一个有用的推论。可以将Iterator.next与InputStream.read看作为等效的。从数据流中读取一个字节，就会自动地"消耗掉"这个字节。下一次调用read将会消耗并返回输入的下一个字节。用同样的方式，反复地调用next就可以读取集合中所有元素。

- 注意，在调用remove方法之前，一定要调用next方法，否则会报IllegalStateException异常

  ```java
  Iterator<String> it = c.iterator();
    it.next();
    it.remove();
    it.next(); // 必须先调用next越过要删除的元素
    it.remove();
  ```

#### 泛型实用方法

java.util.Collection

<e>1.2</e>

- Iterator

  <e>iterator（）</e>

  返回一个用于访问集合中每个元素的迭代器。

- int size（）

  返回当前存储在集合中的元素个数。

- boolean isEmpty（）

  如果集合中没有元素，返回true。

- boolean contains（Object obj）

  如果集合中包含了一个与obj相等的对象，返回true。

- boolean containsAll（Collection<？>other）

  如果这个集合包含other集合中的所有元素，返回true。

- boolean add（Object element）

  将一个元素添加到集合中。如果由于这个调用改变了集合，返回true。

- boolean addAll（Collection<？extends E>other）

  将other集合中的所有元素添加到这个集合。如果由于这个调用改变了集合，返回true。

- boolean remove（Object obj）

  从这个集合中删除等于obj的对象。如果有匹配的对象被删除，返回true。

- boolean removeAll（Collection<？>other）

  从这个集合中删除other集合中存在的所有元素。如果由于这个调用改变了集合，返回true。

- default boolean removeIf（Predicate<？super E>filter）8

  从这个集合删除filter返回true的所有元素。如果由于这个调用改变了集合，则返回true。

- void clear（）

  从这个集合中删除所有的元素。

- boolean retainAll（Collection<？>other）

  从这个集合中删除所有与other集合中的元素不同的元素。如果由于这个调用改变了集合，返回true。

- Object[]toArray（）

  返回这个集合的对象数组。

- `<T>T[]toArray（T[]arrayToFill)`

  返回这个集合的对象数组。如果arrayToFill足够大，就将集合中的元素填入这个数组中。剩余空间填补null；否则，分配一个新数组，其成员类型与arrayToFill的成员类型相同，其长度等于集合的大小，并填充集合元素。

`java.util.Iterator<E>1.2`

- boolean hasNext（）

  如果存在可访问的元素，返回true。

- E next（）

  返回将要访问的下一个对象。如果已经到达了集合的尾部，将抛出一个NoSuchElement Exception。

- void remove（）

  删除上次访问的对象。这个方法必须紧跟在访问一个元素之后执行。如果上次访问之后，集合已经发生了变化，这个方法将抛出一个IllegalStateException。

#### 集合框架中的接口

```shell
Iterable    -> Collection  -> List
                        -> Set      -> SortedSet    ->NavigableSet
                        -> Queue    -> Deque

Map         -> SortedMap   -> NavigableMap
Iterator    -> ListIterator
RandomAccess
```

- List是一个有序集合（ordered collection）。元素会增加到容器中的特定位置。可以采用两种方式访问元素：使用迭代器访问，或者使用一个整数索引来访问。后一种方法称为随机访问（random access），因为这样可以按任意顺序访问元素。与之不同，使用迭代器访问时，必须顺序地访问元素。

- 注释：为了避免对链表完成随机访问操作，Java SE 1.4引入了一个标记接口RandomAccess。这个接口不包含任何方法，不过可以用它来测试一个特定的集合是否支持高效的随机访问：

- Set接口等同于Collection接口，不过其方法的行为有更严谨的定义。集（set）的add方法不允许增加重复的元素。要适当地定义集的equals方法：只要两个集包含同样的元素就认为是相等的，而不要求这些元素有同样的顺序。hashCode方法的定义要保证包含相同元素的两个集会得到相同的散列码。 既然方法签名是一样的，为什么还要建立一个单独的接口呢？从概念上讲，并不是所有集合都是集。建立一个Set接口可以让程序员编写只接受集的方法。（Set不能包含重复值）

- 最后，Java SE 6引入了接口NavigableSet和NavigableMap，其中包含一些用于搜索和遍历有序集和映射的方法。（理想情况下，这些方法本应当直接包含在SortedSet和SortedMap接口中。）TreeSet和TreeMap类实现了这些接口。

### 具体的集合

```shell
AbstractCollection  ->  AbstractList    ->  ArrayList // 动态增长和缩减
                                        ->  AbstractSequentialList      -> LinkedList  // 可以在任意位置高效插入与删除
                    ->  AbstractSet     ->  HashSet(无重复元素的无序集合)    ->      LinkedHashSet // 可以记住元素插入次序的集
                                        ->  EnumSet(包含枚举类型值的集)
                                        ->  TreeSet(有序集)
                    -> AbstractQueue    ->  PriorityQueue // 高效删除最小元素的集
                    -> ArrayQueue // 用循环数组实现的双端队列

AbstractMap         -> HashMap(存储键值)          -> LinkedHashMap
                    -> TreeMap
                    -> EnumMap
                    -> WeakHashMap
                    -> IdentityHashMap
```

#### 链表(LinkedList)

- Java的list都是双向链接的

- 由于迭代器是描述集合中位置的，所以这种依赖于位置的add方法将由迭代器负责。只有对自然有序的集合使用迭代器添加元素才有实际意义。例如，下一节将要讨论的集（set）类型，其中的元素完全无序。因此，在Iterator接口中就没有add方法。相反地，集合类库提供了子接口ListIterator，其中包含add方法

- ListIterator接口有两个方法，previous()与hasPrevious()，可以反向遍历链表，正好与next与hasNext对应

- LinkedList累的listIterator方法返回一个实现了listIterator接口的迭代器对象

- Add方法在迭代器位置之前添加一个新对象

- Java的LinkedList还提供get(int index)方法，但每次都要从头开始搜索，效率很低（注释：get方法做了微小的优化：如果索引大于size（）/2就从列表尾端开始搜索元素。）

#### 数组列表(ArrayList)

- 广泛使用的容器

- 注释：对于一个经验丰富的Java程序员来说，在需要动态数组时，可能会使用Vector类。为什么要用ArrayList取代Vector呢？原因很简单：Vector类的所有方法都是同步的。可以由两个线程安全地访问一个Vector对象。但是，如果由一个线程访问Vector，代码要在同步操作上耗费大量的时间。这种情况还是很常见的。而ArrayList方法不是同步的，因此，建议在不需要同步时使用ArrayList，而不要使用Vector。

#### 散列集(HashTable，HashSet)

- 链表和数组可以按照人们的意愿排列元素的次序。但是，如果想要查看某个指定的元素，却又忘记了它的位置，就需要访问所有元素，直到找到为止。如果集合中包含的元素很多，将会消耗很多时间。如果不在意元素的顺序，可以有几种能够快速查找元素的数据结构。其缺点是无法控制元素出现的次序。它们将按照有利于其操作目的的原则组织数据。

- 散列表为每个对象计算一个整数，称为**散列码（hash code）**。散列码是由对象的实例域产生的一个整数。更准确地说，具有不同数据域的对象将产生不同的散列码。

- 在Java中，散列表用链表数组实现。每个列表被称为**桶（bucket）**。要想查找表中对象的位置，就要先计算它的散列码，然后与桶的总数取余，所得到的结果就是保存这个元素的桶的索引

- 当然，有时候会遇到桶被占满的情况，这也是不可避免的。这种现象被称为**散列冲突（hash collision）**。这时，需要用新对象与桶中的所有对象进行比较，查看这个对象是否已经存在。如果散列码是合理且随机分布的，桶的数目也足够大，需要比较的次数就会很少。

- 桶满时会从链表变为**平衡二叉树**，以提高查找性能

- 桶的初始数量会影响散列表的性能，最好是一个素数，以减少哈希冲突

- 如果散列表太满，就需要**再散列（rehashed）**。如果要对散列表再散列，就需要创建一个桶数更多的表，并将所有元素插入到这个新表中，然后丢弃原来的表。装填因子（load factor）决定何时对散列表进行再散列。例如，如果装填因子为0.75（默认值），而表中超过75%的位置已经填入元素，这个表就会用双倍的桶数自动地进行再散列。对于大多数应用程序来说，装填因子为0.75是比较合理的。

- Java集合类库提供了一个HashSet类，它实现了基于散列表的集。可以用add方法添加元素。contains方法已经被重新定义，用来快速地查看是否某个元素已经出现在集中。它只在某个桶中查找元素，而不必查看集合中的所有元素。

- 散列集迭代器将依次访问所有的桶。由于散列将元素分散在表的各个位置上，所以访问它们的顺序几乎是随机的。只有不关心集合中元素的顺序时才应该使用HashSet。

#### 树集(TreeSet，红黑树)

- TreeSet类与散列集十分类似，不过，它比散列集有所改进。树集是一个有序集合（sorted collection）。可以以任意顺序将元素插入到集合中。在对集合进行遍历时，每个值将自动地按照排序后的顺序呈现。

#### 队列与双端队列

- 在Java SE 6中引入了Deque接口，并由ArrayDeque和LinkedList类实现。这两个类都提供了双端队列，而且在必要时可以增加队列的长度。

- c++的pop相当于java的poll，c++的top/front相当于java的peek

#### 优先级队列

- 优先级队列（priority queue）中的元素可以按照任意的顺序插入，却总是按照排序的顺序进行检索。也就是说，无论何时调用remove方法，总会获得当前优先级队列中最小的元素。然而，优先级队列并没有对所有的元素进行排序。如果用迭代的方式处理这些元素，并不需要对它们进行排序。优先级队列使用了一个优雅且高效的数据结构，称为堆（heap）。堆是一个可以自我调整的二叉树，对树执行添加（add）和删除（remore）操作，可以让最小的元素移动到根，而不必花费时间对元素进行排序。

- 使用优先级队列的典型示例是任务调度。每一个任务有一个优先级，任务以随机顺序添加到队列中。每当启动一个新的任务时，都将优先级最高的任务从队列中删除（由于习惯上将1设为"最高"优先级，所以会将最小的元素删除）。

### 映射(Map)

#### 基本操作

- Java类库为映射提供了两个通用的实现：HashMap和TreeMap。这两个类都实现了Map接口。

- 散列映射对键进行散列，树映射用键的整体顺序对元素进行排序，并将其组织成搜索树。散列或比较函数只能作用于键。与键关联的值不能进行散列或比较。

- 应该选择散列映射还是树映射呢？与集一样，散列稍微快一些，如果不需要按照排列顺序访问键，就最好选择散列。

#### 更新映射项

- putIfAbsent

- merge

#### 映射视图

- Set

  <k> keySet()</k>

- Collection

  <v> values()</v>

- Set

  <map, entry<k,v="">&gt; entrySet()</map,>

#### 弱散列映射

- 设计WeakHashMap类是为了解决一个有趣的问题。如果有一个值，对应的键已经不再使用了，将会出现什么情况呢？假定对某个键的最后一次引用已经消亡，不再有任何途径引用这个值的对象了。但是，由于在程序中的任何部分没有再出现这个键，所以，这个键/值对无法从映射中删除。为什么垃圾回收器不能够删除它呢？难道删除无用的对象不是垃圾回收器的工作吗？

- 遗憾的是，事情没有这样简单。垃圾回收器跟踪活动的对象。只要映射对象是活动的，其中的所有桶也是活动的，它们不能被回收。因此，需要由程序负责从长期存活的映射表中删除那些无用的值。或者使用WeakHashMap完成这件事情。当对键的唯一引用来自散列条目时，这一数据结构将与垃圾回收器协同工作一起删除键值对

#### 链接散列集与映射

- LinkedHashSet和LinkedHashMap类用来记住插入元素项的顺序。这样就可以避免在散列表中的项从表面上看是随机排列的。当条目插入到表中时，就会并入到双向链表中

#### 枚举集与映射

- EnumSet是一个枚举类型元素集的高效实现。由于枚举类型只有有限个实例，所以EnumSet内部用位序列实现。如果对应的值在集中，则相应的位被置为1。

- EnumSet类没有公共的构造器。可以使用静态工厂方法构造这个集

- 注释：在EnumSet的API文档中，将会看到`E extends Enum<E>`这样奇怪的类型参数。简单地说，它的意思是"E是一个枚举类型。"所有的枚举类型都扩展于泛型Enum类。例如，Weekday扩展`Enum<Weekday>`。

#### 标识散列映射

- 类IdentityHashMap有特殊的作用。在这个类中，键的散列值不是用hashCode函数计算的，而是用System.identityHashCode方法计算的。这是Object.hashCode方法根据对象的内存地址来计算散列码时所使用的方式。而且，在对两个对象进行比较时，IdentityHashMap类使用==，而不使用equals。

- 也就是说，不同的键对象，即使内容相同，也被视为是不同的对象。在实现对象遍历算法（如对象串行化）时，这个类非常有用，可以用来跟踪每个对象的遍历状况。

### 视图

- 映射类的keySet方法就是一个这样的示例。初看起来，好像这个方法创建了一个新集，并将映射中的所有键都填进去，然后返回这个集。但是，情况并非如此。取而代之的是：keySet方法返回一个实现Set接口的类对象，这个类的方法对原映射进行操作。这种集合称为视图。

#### 轻量级集合包装器

- Arrays类的静态方法asList将返回一个包装了普通Java数组的List包装器。这个方法可以将数组传递给一个期望得到列表或集合参数的方法

  ```java
  Card[] cardDeck = new Card[52];
    ...
    List<Card> cardList = Arrays.asList(cardDeck);
  ```

- 返回的对象不是ArrayList。它是一个视图对象，带有访问底层数组的get和set方法。改变数组大小的所有方法（例如，与迭代器相关的add和remove方法）都会抛出一个Unsupported OperationException异常。

- Collections的静态方法nCopies

- Collections的静态方法singleton

#### 子范围（subrange）

- 例如，假设有一个列表staff，想从中取出第10个~第19个元素。可以使用subList方法来获得一个列表的子范围视图。第一个索引包含在内，第二个索引则不包含在内。这与String类的substring操作中的参数情况相同。

- **对子范围的任何操作都会影响原集合**

  ```java
  List group2 = staff.subList(10,20);
    group2.clear(); // group2清空，并且staff的第10~19个元素也清空了
  ```

- 有序集允许使用排序顺序建立子范围

  ```java
  SortedSet<E> subSet(E from, E to)
    SortedSet<E> headSet(E to)
    SortedSet<E> tailSet(E from)
  ```

- 有序映射同样也可以

  ```java
  SortedMap<k,v> subMap(K from, K to)
    SortedMap<k,v> headMap(K to)
    SortedMap<k,v> tailMap(K from)</k,v></k,v></k,v>
  ```

#### 不可修改的视图

- Collections还有几个方法，用于产生集合的不可修改视图（unmodifiable views）。这些视图对现有集合增加了一个运行时的检查。如果发现试图对集合进行修改，就抛出一个异常，同时这个集合将保持未修改的状态。

#### 同步视图

- 如果由多个线程访问集合，就必须确保集不会被意外地破坏。例如，如果一个线程试图将元素添加到散列表中，同时另一个线程正在对散列表进行再散列，其结果将是灾难性的。

- 类库的设计者使用视图机制来确保常规集合的线程安全，而不是实现线程安全的集合类。例如，Collections类的静态synchronizedMap方法可以将任何一个映射表转换成具有同步访问方法的Map：

### 算法

#### 排序和混排

- Collections类中的sort方法可以对实现了List接口的集合进行排序

  ```java
  List<String> staff = neww LinkedList<>();
    fill collection
    Collections.sort(staff);
  ```

- 这个sort方法假定列表元素实现了Comparable接口。如果想采用其他方式对列表进行排序，可以使用List接口的sort方法并传入一个Comparator对象。可以如下按工资对一个员工列表排序：

  ```java
  staff.sort(Comparator.comparingDouble(Employee::getSalary));
  ```

- 如果想按照降序对列表进行排序，可以使用一种非常方便的静态方法Collections.reverse-Order()。这个方法将返回一个比较器，比较器则返回b.compareTo（a）。例如，

  ```java
  staff.sort(Comparator.reverseOrder());
  ```

- 也可以使用如下方式逆向排序

  ```java
  staff.sort(Comparator.comparingDouble(Employee::getSalary).reversed());
  ```

- Java对于列表的排序不像其他语言那样使用归并排序，而是**先把列表所有元素转入一个数组，对数组进行排序，再把排序后的序列复制回列表**

- 集合类库中使用的排序算法比快速排序要慢一些，快速排序是通用排序算法的传统选择。但是，归并排序有一个主要的优点：稳定，即不需要交换相同的元素。

- Collections类有个算法shuffle，用来打乱列表中的元素顺序

#### 二分查找

- Collections类的binarySearch方法实现了这个算法。注意，集合必须是排好序的，否则算法将返回错误的答案。要想查找某个元素，必须提供集合以及要查找的元素。如果集合没有采用Comparable接口的compareTo方法进行排序，就还要提供一个比较器对象。

- 只有采用随机访问，二分查找才有意义。如果必须利用迭代方式一次次地遍历链表的一半元素来找到中间位置的元素，二分查找就完全失去了优势。因此，如果为binarySearch算法提供一个链表，它将自动地变为线性查找。

- 如果binarySearch方法返回的数值大于等于0，则表示匹配对象的索引。也就是说，c.get（i）等于在这个比较顺序下的element。如果返回负值，则表示没有匹配的元素。但是，可以利用返回值计算应该将element插入到集合的哪个位置，以保持集合的有序性，插入的位置是

  ```java
  if (i < 0) {
        insertionPoint = -i - 1;
    }
  ```

#### 简单算法

java.util.Collections 1.2

- `static<T extends Comparable<？super T>>T min（Collection<T>elements）`

- `static<T extends Comparable<？super T>>T max（Collection<T>elements）`

- `static<T>min（Collection<T>elements，Comparator<？super T>c）`

- `static<T>max（Collection<T>elements，Comparator<？super T>c）`

  返回集合中最小的或最大的元素（为清楚起见，参数的边界被简化了）。

- `static<T>void copy（List<？super T>to，List<T>from）`

  将原列表中的所有元素复制到目标列表的相应位置上。目标列表的长度至少与原列表一样。

- `static<T>void fill（List<？super T>l，T value）`

  将列表中所有位置设置为相同的值。

- `static<T>boolean addAll（Collection<？super T>c，T...values）5.0`

  将所有的值添加到集合中。如果集合改变了，则返回true。

- `static<T>boolean replaceAll（List<T>l，T oldValue，T newValue）1.4`

  用newValue取代所有值为oldValue的元素。

- `static int indexOfSubList（List<？>l，List<？>s）1.4`

- `static int lastIndexOfSubList（List<？>l，List<？>s）1.4`

  返回l中第一个或最后一个等于s子列表的索引。如果l中不存在等于s的子列表，则返回–1。例如，1为[s，t，a，r]，s为[t，a，r]，两个方法都将返回索引1。

- `static void swap（List<？>l，int i，int j）1.4`

  交换给定偏移量的两个元素。

- `static void reverse（List<？>l）`

  逆置列表中元素的顺序。例如，逆置列表[t，a，r]后将得到列表[r，a，t]。这个方法的时间复杂度为O（n），n为列表的长度。

- `static void rotate（List<？>l，int d）1.4`

  旋转列表中的元素，将索引i的条目移动到位置（i+d）%l.size（）。例如，将列表[t，a，r]旋转移2个位置后得到[a，r，t]。这个方法的时间复杂度为O（n），n为列表的长度。

- `static int frequency（Collection<？>c，Object o）5.0`

  返回c中与对象o相同的元素个数。

- `boolean disjoint（Collection<？>c1，Collection<？>c2）5.0`

  如果两个集合没有共同的元素，则返回true。

java.util.Collection

<t>1.2</t>

- `default boolean removeIf（Predicate<？super E>filter）8`

  删除所有匹配的元素。

java.util.List

<e>1.2</e>

- `default void replaceAll（UnaryOperator<E>op）8`

  对这个列表的所有元素应用这个操作。

#### 批操作

- `col1.removeAll(col2);`

  从col1删除col2中出现的所有元素

- `col1.retainAll(col2);`

  从col1删除所有未在col2中出现的元素

#### 集合与数组的转换

- 把数组转换为集合，Arrays.asList包装器可以达到目的

  ```java
  String[] values = ...;
    Hashset<String> staff = new HashSet<>(Arrays.asList(values));
  ```

- 从集合转为数组困难一点，可以用toArray方法， 但是返回的是Object数组，不能执行强制类型转换

  ```java
  String[] values = (String)[] staff.toArray(); // Error!
  ```

- 正确的做法要像下面这样

  ```java
  String[] values = staff.toArray(new String[0]);
  ```

### 遗留的集合

- Hashtable，同HashMap类

- Enumeration接口，与Iterator接口十分相似

- Property属性映射，非常特殊，kv都是字符串，可以save到文件也可以从文件load

- 栈stack

- 位集bitset，用于存放位序列，称为位向量或位数组更合适，C++注释：C++中的bitset模板与Java平台的BitSet功能一样。

## 第14章 并发

### 什么是线程

不要调用Thread类或Runnable对象的run方法。直接调用run方法，只会执行同一个线程中的任务，而不会启动新线程。应该调用Thread.start方法。这个方法将创建一个执行run方法的新线程。

- Thread（Runnable target）

  构造一个新线程，用于调用给定目标的run（）方法

- void start（）

  启动这个线程，将引发调用run（）方法。这个方法将立即返回，并且新线程将并发运行。

- void run（）

  调用关联Runnable的run方法。

java.lang.Runnable 1.0

- void run（）

  必须覆盖这个方法，并在这个方法中提供所要执行的任务指令。

### 中断线程

- 没有可以强制线程终止的方法。然而，interrupt方法可以用来请求终止线程。

- 当对一个线程调用interrupt方法时，线程的中断状态将被置位。这是每一个线程都具有的boolean标志。每个线程都应该不时地检查这个标志，以判断线程是否被中断。

- 要想弄清中断状态是否被置位，首先调用静态的Thread.currentThread方法获得当前线程，然后调用isInterrupted方法：

  ```java
  while (Thread.currentThread().isInterrupted() && more work to do) {
        do more work;
    }
  ```

- 但是，如果线程被阻塞，就无法检测中断状态。这是产生InterruptedException异常的地方。当在一个被阻塞的线程（调用sleep或wait）上调用interrupt方法时，阻塞调用将会被Interrupted Exception异常中断。

- 没有任何语言方面的需求要求一个被中断的线程应该终止。中断一个线程不过是引起它的注意。被中断的线程可以决定如何响应中断。某些线程是如此重要以至于应该处理完异常后，继续执行，而不理会中断。

java.lang.Thread 1.0

- void interrupt（）

  向线程发送中断请求。线程的中断状态将被设置为true。如果目前该线程被一个sleep调用阻塞，那么，InterruptedException异常被抛出。

- static boolean interrupted（）

  测试当前线程（即正在执行这一命令的线程）是否被中断。注意，这是一个静态方法。这一调用会产生副作用----它将当前线程的中断状态重置为false。

- boolean isInterrupted（）

  测试线程是否被终止。不像静态的中断方法，这一调用不改变线程的中断状态。

- static Thread currentThread（）

  返回代表当前执行线程的Thread对象。

#### 线程状态

- 线程可以有如下6种状态：

  - New（新创建）

  - Runnable（可运行）

  - Blocked（被阻塞）

  - Waiting（等待）

  - Timed waiting（计时等待）

  - Terminated（被终止）

- 下一节对每一种状态进行解释。要确定一个线程的当前状态，可调用getState方法。

#### 新创建线程

- 当用new操作符创建一个新线程时，如new Thread（r），该线程还没有开始运行。这意味着它的状态是new。当一个线程处于新创建状态时，程序还没有开始运行线程中的代码。在线程运行之前还有一些基础工作要做。

#### 可运行线程

- 一旦调用start方法，线程处于runnable状态。**一个可运行的线程可能正在运行也可能没有运行**，这取决于操作系统给线程提供运行的时间。（Java的规范说明没有将它作为一个单独状态。一个正在运行中的线程仍然处于可运行状态。）

- 一旦一个线程开始运行，它不必始终保持运行。事实上，运行中的线程被中断，目的是为了让其他线程获得运行机会。线程调度的细节依赖于操作系统提供的服务。抢占式调度系统给每一个可运行线程一个时间片来执行任务。当时间片用完，操作系统剥夺该线程的运行权，并给另一个线程运行机会。当选择下一个线程时，操作系统考虑线程的优先级

#### 被阻塞线程和等待线程

- 当线程处于被阻塞或等待状态时，它暂时不活动。它不运行任何代码且消耗最少的资源。直到线程调度器重新激活它。细节取决于它是怎样达到非活动状态的。

- 当一个线程试图获取一个内部的对象锁（而不是java.util.concurrent库中的锁），而该锁被其他线程持有，则该线程进入阻塞状态（我们在14.5.3节讨论java.util.concurrent锁，在14.5.5节讨论内部对象锁）。当所有其他线程释放该锁，并且线程调度器允许本线程持有它的时候，该线程将变成非阻塞状态。

- 当线程等待另一个线程通知调度器一个条件时，它自己进入等待状态。我们在第14.5.4节来讨论条件。在调用Object.wait方法或Thread.join方法，或者是等待java.util.concurrent库中的Lock或Condition时，就会出现这种情况。实际上，被阻塞状态与等待状态是有很大不同的。

- 有几个方法有一个超时参数。调用它们导致线程进入计时等待（timed waiting）状态。这一状态将一直保持到超时期满或者接收到适当的通知。带有超时参数的方法有Thread.sleep和Object.wait、Thread.join、Lock.tryLock以及Condition.await的计时版。

#### 被终止的线程

- 线程因如下两个原因之一而被终止：

  - 因为run方法正常退出而自然死亡。

  - 因为一个没有捕获的异常终止了run方法而意外死亡。

- void join（）

  等待终止指定的线程。

- void join（long millis）

  等待指定的线程死亡或者经过指定的毫秒数。

- Thread.State getState（）5.0

  得到这一线程的状态；NEW、RUNNABLE、BLOCKED、WAITING、TIMED_WAITING或TERMINATED之一。

- void stop（）

  停止该线程。这一方法已过时。

- void suspend（）

  暂停这一线程的执行。这一方法已过时。

- void resume（）

  恢复线程。这一方法仅仅在调用suspend（）之后调用。这一方法已过时。

### 线程属性

#### 线程优先级

- 在Java程序设计语言中，每一个线程有一个优先级。默认情况下，一个线程继承它的父线程的优先级。可以用setPriority方法提高或降低任何一个线程的优先级。可以将优先级设置为在MIN_PRIORITY（在Thread类中定义为1）与MAX_PRIORITY（定义为10）之间的任何值。NORM_PRIORITY被定义为5。

- 每当线程调度器有机会选择新线程时，它首先选择具有较高优先级的线程。但是，线程优先级是高度依赖于系统的。当虚拟机依赖于宿主机平台的线程实现机制时，Java线程的优先级被映射到宿主机平台的优先级上，优先级个数也许更多，也许更少。

#### 守护线程

- 可以通过调用`t.setDaemon(true);`将线程转换为守护线程（daemon thread）。这样一个线程没有什么神奇。守护线程的唯一用途是为其他线程提供服务。计时线程就是一个例子，它定时地发送"计时器嘀嗒"信号给其他线程或清空过时的高速缓存项的线程。当只剩下守护线程时，虚拟机就退出了，由于如果只剩下守护线程，就没必要继续运行程序了。

- `t.setDaemon(true);`方法必须要在线程启动之前调用

### 同步

#### 锁对象

- 有两种机制防止代码块受并发访问的干扰。Java语言提供一个synchronized关键字达到这一目的，并且Java SE 5.0引入了ReentrantLock类。synchronized关键字自动提供一个锁以及相关的"条件"，对于大多数需要显式锁的情况，这是很便利的。

- 用ReentrantLock保护代码块的基本结构

  ```java
  myLock.lock();
    try {
        critical section
    } finally {
        myLock.unlock(); // make sure the lock is unlocked even if an exception is thrown
    }
  ```

- 这一结构确保任何时刻只有一个线程进入临界区。一旦一个线程封锁了锁对象，其他任何线程都无法通过lock语句。当其他线程调用lock时，它们被阻塞，直到第一个线程释放锁对象。

- 警告：把解锁操作括在finally子句之内是至关重要的。如果在临界区的代码抛出异常，锁必须被释放。否则，其他线程将永远阻塞。

- 锁是可重入的，因为线程可以重复地获得已经持有的锁。锁保持一个持有计数（hold count）来跟踪对lock方法的嵌套调用。线程在每一次调用lock都要调用unlock来释放锁。由于这一特性，被一个锁保护的代码可以调用另一个使用相同的锁的方法。

#### 条件对象

- 通常，线程进入临界区，却发现在某一条件满足之后它才能执行。要使用一个条件对象来管理那些已经获得了一个锁但是却不能做有用工作的线程。在这一节里，我们介绍Java库中条件对象的实现。（由于历史的原因，条件对象经常被称为条件变量（conditional variable）。）

- 一个锁对象可以有一个或多个相关的条件对象。你可以用newCondition方法获得一个条件对象。

- 至关重要的是最终需要某个其他线程调用signalAll方法。当一个线程调用await时，它没有办法重新激活自身。它寄希望于其他线程。如果没有其他线程来重新激活等待的线程，它就永远不再运行了。这将导致令人不快的死锁（deadlock）现象。如果所有其他线程被阻塞，最后一个活动线程在解除其他线程的阻塞状态之前就调用await方法，那么它也被阻塞。没有任何线程可以解除其他线程的阻塞，那么该程序就挂起了。

- 应该何时调用signalAll呢？经验上讲，在对象的状态有利于等待线程的方向改变时调用signalAll。例如，当一个账户余额发生改变时，等待的线程会应该有机会检查余额。在例子中，当完成了转账时，调用signalAll方法。

- 注意调用signalAll不会立即激活一个等待线程。它仅仅解除等待线程的阻塞，以便这些线程可以在当前线程退出同步方法之后，通过竞争实现对对象的访问。

- 另一个方法signal，则是随机解除等待集中某个线程的阻塞状态。这比解除所有线程的阻塞更加有效，但也存在危险。如果随机选择的线程发现自己仍然不能运行，那么它再次被阻塞。如果没有其他线程再次调用signal，那么系统就死锁了。

- 警告：当一个线程拥有某个条件的锁时，它仅仅可以在该条件上调用await、signalAll或signal方法。

#### synchronized关键字

- **从1.0版开始，Java中的每一个对象都有一个内部锁。**如果一个方法用synchronized关键字声明，那么对象的锁将保护整个方法。也就是说，要调用该方法，线程必须获得内部的对象锁。

  ```java
  public synchronized void method() {
      method body
  }
  // 等价于
  public void method() {
    this.intrinsicLock.lock();
    try {
        method body
    } finally {
        this.intrinsicLock.unlock();
    }
  }
  ```

- 内部对象锁只有一个相关条件。wait方法添加一个线程到等待集中，notifyAll/notify方法解除等待线程的阻塞状态。换句话说，调用wait或notifyAll等价于

  ```java
  intrinsicCondition.await();
    intrinsicCondition.signalAll();
  ```

- 注释：wait、notifyAll以及notify方法是Object类的final方法。Condition方法必须被命名为await、signalAll和signal以便它们不会与那些方法发生冲突。

  ```java
  Class Bank {
    private double[] accounts;
    public synchronized void transfer(int from, int amount) throws InterrruptedException {
        while (accounts[from] < amount) {
            wait(); // wait on intrinsic object lock's single condition
        }
    }
    accounts[from] -= amount;
    accounts[to] += amount;
    notifAll(); // notify all threads waiting on the condition
  }
  ```

- 内部锁和条件存在一些局限。包括：

  - 不能中断一个正在试图获得锁的线程。

  - 试图获得锁时不能设定超时。

  - 每个锁仅有单一的条件，可能是不够的。

#### Volatile域

- volatile关键字为实例域的同步访问提供了一种免锁机制。如果声明一个域为volatile，那么编译器和虚拟机就知道该域是可能被另一个线程并发更新的。

- Volatile变量不能提供原子性。例如，方法

#### 原子性

- 假设对共享变量除了赋值之外并不完成其他操作，那么可以将这些共享变量声明为volatile。 java.util.concurrent.atomic包中有很多类使用了很高效的机器级指令（而不是使用锁）来保证其他操作的原子性。例如，AtomicInteger类提供了方法incrementAndGet和decrementAndGet，它们分别以原子方式将一个整数自增或自减。

- incrementAndGet方法以原子方式将AtomicLong自增，并返回自增后的值。也就是说，获得值、增1并设置然后生成新值的操作不会中断。可以保证即使是多个线程并发地访问同一个实例，也会计算并返回正确的值。

- 如果有大量线程要访问相同的原子值，性能会大幅下降，因为乐观更新需要太多次重试。Java SE 8提供了LongAdder和LongAccumulator类来解决这个问题。LongAdder包括多个变量（加数），其总和为当前值。可以有多个线程更新不同的加数，线程个数增加时会自动提供新的加数。通常情况下，只有当所有工作都完成之后才需要总和的值，对于这种情况，这种方法会很高效。性能会有显著的提升。

#### 线程局部变量（thread local）

- 有时可能要避免共享变量，使用ThreadLocal辅助类为各个线程提供各自的实例。

`java.lang.ThreadLocal<T>1.2`

- T get（）

  得到这个线程的当前值。如果是首次调用get，会调用initialize来得到这个值。

- protected initialize（）

  应覆盖这个方法来提供一个初始值。默认情况下，这个方法返回null。

- void set（T t）

  为这个线程设置一个新值。

- void remove（）

  删除对应这个线程的值。

- `static<S>ThreadLocal<S>withInitial（（Supplier<？extends S>supplier）8`

  创建一个线程局部变量，其初始值通过调用给定的supplier生成。 java.util.concurrent.ThreadLocalRandom 7

- static ThreadLocalRandom current（）

  返回特定于当前线程的Random类实例。

#### 锁测试（trylock）与超时

- 线程在调用lock方法来获得另一个线程所持有的锁的时候，很可能发生阻塞。应该更加谨慎地申请锁。tryLock方法试图申请一个锁，在成功获得锁后返回true，否则，立即返回false，而且线程可以立即离开去做其他事情。

  ```java
  if (MyLock.tryLock()) {
        try {
            ...
        } finally {
            MyLock.unlock();
        }
    } else {
        ...
    }
  ```

- 可以调用tryLock时，使用超时参数，像这样：

  ```java
  if (MyLock.tryLock(100, TimeUnit.MILLISECONDS))...
  ```

- TimeUnit是一个枚举类型，可以取的值包括SECONDS、MILLISECONDS、MICROSECONDS和NANOSECONDS。

java.util.concurrent.locks.Lock 5.0

- boolean tryLock（）

  尝试获得锁而没有发生阻塞；如果成功返回真。这个方法会抢夺可用的锁，即使该锁有公平加锁策略，即便其他线程已经等待很久也是如此。

- boolean tryLock（long time，TimeUnit unit）

  尝试获得锁，阻塞时间不会超过给定的值；如果成功返回true。

- void lockInterruptibly（）

  获得锁，但是会不确定地发生阻塞。如果线程被中断，抛出一个InterruptedException异常。

java.util.concurrent.locks.Condition 5.0

- boolean await（long time，TimeUnit unit）

  进入该条件的等待集，直到线程从等待集中移出或等待了指定的时间之后才解除阻塞。如果因为等待时间到了而返回就返回false，否则返回true。

- void awaitUninterruptibly（）

  进入该条件的等待集，直到线程从等待集移出才解除阻塞。如果线程被中断，该方法不会抛出InterruptedException异常。

#### 读/写锁

- java.util.concurrent.locks包定义了两个锁类，我们已经讨论的ReentrantLock类和ReentrantReadWriteLock类。如果很多线程从一个数据结构读取数据而很少线程修改其中数据的话，后者是十分有用的。在这种情况下，允许对读者线程共享访问是合适的。当然，写者线程依然必须是互斥访问的。

- 下面是使用读/写锁的必要步骤：

  ```java
  // 1\. 构造一个ReentrantReadWriteLock对象：
    private ReentrantReadWriteLock rwl = new ReentrantReadWriteLock();

    // 2\. 抽取读锁和写锁：
    private Lock readLock = rwl.readLock();
    private Lock writeLock = rwl.writeLock();

    // 3\. 对所有的获取方法加读锁：
    public double getTotalBalance() {
        readLock.lock();
        try {
            ...
        } finally {
            readLock.unlock();
        }
    }

    // 4\. 对所有的修改方法加写锁：
    public void transfer(...) {
        writeLock.lock();
        try {
            ...
        } finally {
            writeLock.unlock();
        }
    }
  ```

java.util.concurrent.locks.ReentrantReadWriteLock 5.0

- Lock readLock（）

  得到一个可以被多个读操作共用的读锁，但会排斥所有写操作。

- Lock writeLock（）

  得到一个写锁，排斥所有其他的读操作和写操作。

#### 为什么弃用stop和suspend方法

- 初始的Java版本定义了一个stop方法用来终止一个线程，以及一个suspend方法用来阻塞一个线程直至另一个线程调用resume。stop和suspend方法有一些共同点：都试图控制一个给定线程的行为。

- 不安全的stop：首先来看看stop方法，该方法终止所有未结束的方法，包括run方法。当线程被终止，立即释放被它锁住的所有对象的锁。这会导致对象处于不一致的状态。例如，假定TransferThread在从一个账户向另一个账户转账的过程中被终止，钱款已经转出，却没有转入目标账户，现在银行对象就被破坏了。因为锁已经被释放，这种破坏会被其他尚未停止的线程观察到。

- 可能会死锁的suspend：接下来，看看suspend方法有什么问题。与stop不同，suspend不会破坏对象。但是，如果用suspend挂起一个持有一个锁的线程，那么，该锁在恢复之前是不可用的。如果调用suspend方法的线程试图获得同一个锁，那么程序死锁：被挂起的线程等着被恢复，而将其挂起的线程等待获得锁。

#### 阻塞队列

- 对于许多线程问题，可以通过使用一个或多个队列以优雅且安全的方式将其形式化。生产者线程向队列插入元素，消费者线程则取出它们。使用队列，可以安全地从一个线程向另一个线程传递数据。

- 当试图向队列添加元素而队列已满，或是想从队列移出元素而队列为空的时候，阻塞队列（blocking queue）导致线程阻塞。在协调多个线程之间的合作时，阻塞队列是一个有用的工具。工作者线程可以周期性地将中间结果存储在阻塞队列中。其他的工作者线程移出中间结果并进一步加以修改

- java.util.concurrent包提供了阻塞队列的几个变种。

  - LinkedBlockingQueue在默认情况下，容量是没有上边界的，但是，也可以选择指定最大容量。LinkedBlockingDeque是一个双端的版本。

  - ArrayBlockingQueue在构造时需要指定容量，并且有一个可选的参数来指定是否需要公平性。若设置了公平参数，则那么等待了最长时间的线程会优先得到处理。通常，公平性会降低性能，只有在确实非常需要时才使用它。

  - PriorityBlockingQueue是一个带优先级的队列，而不是先进先出队列。元素按照它们的优先级顺序被移出。该队列是没有容量上限，但是，如果队列是空的，取元素的操作会阻塞。（有关优先级队列的详细内容参看第9章。）

  - 最后，DelayQueue包含实现Delayed接口的对象，getDelay方法返回对象的残留延迟。负值表示延迟已经结束。元素只有在延迟用完的情况下才能从DelayQueue移除。还必须实现compareTo方法。DelayQueue使用该方法对元素进行排序：

    ```java
    interface Delayed extends Comparable<delayed> {
        long getDelay(TimeUnit unit);
    }
    ```

### 线程安全的集合

#### 高效的映射、集和队列

- java.util.concurrent包提供了映射、有序集和队列的高效实现：ConcurrentHashMap、ConcurrentSkipListMap、ConcurrentSkipListSet和ConcurrentLinkedQueue。

- 这些集合使用复杂的算法，通过允许并发地访问数据结构的不同部分来使竞争极小化。

- 集合获取大小可能需要遍历，从而不是常数时间

java.util.concurrent.ConcurrentLinkedQueue

<e>5.0</e>

- `ConcurrentLinkedQueue<E>（）`

  构造一个可以被多线程安全访问的无边界非阻塞的队列。

java.util.concurrent.ConcurrentLinkedQueue

<e>6</e>

- `ConcurrentSkipListSet<E>（）`

- `ConcurrentSkipListSet<E>（Comparator<？super E>comp）`

  构造一个可以被多线程安全访问的有序集。第一个构造器要求元素实现Comparable接口。

java.util.concurrent.ConcurrentHashMap

<k，v>5.0
java.util.concurrent.ConcurrentSkipListMap<k，v>6</k，v></k，v>

- `ConcurrentHashMap<K，V>（）`

- `ConcurrentHashMap<K，V>（int initialCapacity）`

- `ConcurrentHashMap<K，V>（int initialCapacity，float loadFactor，int`concurrencyLevel）

构造一个可以被多线程安全访问的散列映射表。

参数：initialCapacity 集合的初始容量。默认值为16。

loadFactor 控制调整：如果每一个桶的平均负载超过这个因子，表的大小会被重新调整。默认值为0.75。

concurrencyLevel 并发写者线程的估计数目。

- `ConcurrentSkipListMap<K，V>（）`

- `ConcurrentSkipListSet<K，V>（Comparator<？super K>comp）` 构造一个可以被多线程安全访问的有序的映像表。第一个构造器要求键实现Comparable接口。

#### 映射条目的原子更新

- 传统的做法是使用replace操作，它会以原子方式用一个新值替换原值，前提是之前没有其他线程把原值替换为其他值。必须一直这么做，直到replace成功：

  ```java
  do {
        oldValue = map.get(word);
        newValue = oldValue == null ? 1 : oldValue + 1;
    } while (!map.replace(word, oldValue, newValue));
  ```

- 或者，可以使用一个ConcurrentHashMap<string，atomiclong>，或者在Java SE 8中，还可以使用ConcurrentHashMap<string，longadder>。更新代码如下：

  ```java
  map.putIfAbsent(word, new LongAddr());
    map.get(word).increment();
    //or
    map.putIfAbsent(word, new LongAddr()).increment();
  ```

#### 写数组的拷贝

- CopyOnWriteArrayList和CopyOnWriteArraySet是线程安全的集合，其中所有的修改线程对底层数组进行复制

#### Callable与Future

- Runnable封装一个异步运行的任务，可以把它想象成为一个没有参数和返回值的异步方法。Callable与Runnable类似，但是有返回值。Callable接口是一个参数化的类型，只有一个方法call。

  ```java
  public interface Callable<V> {
        V call() throws Exception;
    }
  ```

- 类型参数是返回值的类型。例如，Callable

  <integer>表示一个最终返回Integer对象的异步计算。</integer>

- Future保存异步计算的结果。可以启动一个计算，将Future对象交给某个线程，然后忘掉它。Future对象的所有者在结果计算好之后就可以获得它。

- Future接口具有下面的方法：

  ```java
  public interface Future<V> {
        V get() throws ...;
        V get(long timeout, TimeUnit unit) throws ...;
        void cancel(boolean mayInterrupt);
        boolean isCanceld();
        boolean isDone();
    }
  ```

- 第一个get方法的调用被阻塞，直到计算完成。如果在计算完成之前，第二个方法的调用超时，抛出一个TimeoutException异常。如果运行该计算的线程被中断，两个方法都将抛出InterruptedException。如果计算已经完成，那么get方法立即返回。

- 如果计算还在进行，isDone方法返回false；如果完成了，则返回true。

- 可以用cancel方法取消该计算。如果计算还没有开始，它被取消且不再开始。如果计算处于运行之中，那么如果mayInterrupt参数为true，它就被中断。

### 执行器

- 构建一个新的线程是有一定代价的，因为涉及与操作系统的交互。如果程序中创建了大量的生命期很短的线程，应该使用线程池（thread pool）。一个线程池中包含许多准备运行的空闲线程。将Runnable对象交给线程池，就会有一个线程调用run方法。当run方法退出时，线程不会死亡，而是在池中准备为下一个请求提供服务。

- 另一个使用线程池的理由是减少并发线程的数目。创建大量线程会大大降低性能甚至使虚拟机崩溃。如果有一个会创建许多线程的算法，应该使用一个线程数"固定的"线程池以限制并发线程的总数。

#### 线程池

- 执行器（Executor）类有许多静态工厂方法用来构建线程池，

  java.util.concurrent.Executors 5.0

  - `ExecutorService newCachedThreadPool（）`

    返回一个带缓存的线程池，该池在必要的时候创建线程，在线程空闲60秒之后终止线程。

  - `ExecutorService newFixedThreadPool（int threads）`

    返回一个线程池，该池中的线程数由参数指定。

  - `ExecutorService newSingleThreadExecutor（）`

    返回一个执行器，它在一个单个的线程中依次执行各个任务。

- 该池会在方便的时候尽早执行提交的任务。调用submit时，会得到一个Future对象，可用来查询该任务的状态。

java.util.concurrent.ExecutorService 5.0

- `Future<T>submit（Callable<T>task）`

    第一个submit方法返回一个奇怪样子的Future<？>。可以使用这样一个对象来调用isDone、cancel或isCancelled。但是，get方法在完成的时候只是简单地返回null。

- `Future<T>submit（Runnable task，T result）`

    第二个版本的Submit也提交一个Runnable，并且Future的get方法在完成的时候返回指定的result对象。

- `Future<？>submit（Runnable task）`

    第三个版本的Submit提交一个Callable，并且返回的Future对象将在计算结果准备好的时候得到它。

- 当用完一个线程池的时候，调用shutdown。该方法启动该池的关闭序列。被关闭的执行器不再接受新的任务。当所有任务都完成以后，线程池中的线程死亡。另一种方法是调用shutdownNow。该池取消尚未开始的所有任务并试图中断正在运行的线程。

- 下面是典型流程：

  1. 调用Executors类中静态的方法newCachedThreadPool或newFixedThreadPool。

  2. 调用submit提交Runnable或Callable对象。

  3. 如果想要取消一个任务，或如果提交Callable对象，那就要保存好返回的Future对象。

  4. 当不再提交任何任务时，调用shutdown。

#### 预定执行

- ScheduledExecutorService接口具有为预定执行（Scheduled Execution）或重复执行任务而设计的方法。它是一种允许使用线程池机制的java.util.Timer的泛化。Executors类的newScheduledThreadPool和newSingleThreadScheduledExecutor方法将返回实现了Scheduled-ExecutorService接口的对象。

- 可以预定Runnable或Callable在初始的延迟之后只运行一次。也可以预定一个Runnable对象周期性地运行

### 同步器

信号量，倒计时门栓，障栅，交换器，同步队列，

> 原文发表于：https://www.jianshu.com/p/72aa83b1a810, by 2021.10.09 15:51:43 有所修改