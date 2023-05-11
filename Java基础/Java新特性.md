## JDK9到JDK17的新特性

### JDK9新特性（2017年9月）

模块化

提供了List.of()、Set.of()、Map.of()和Map.ofEntries()等工厂方法

接口支持私有方法

Optional 类改进

多版本兼容Jar包

JShell工具

try-with-resources的改进

Stream API的改进

设置G1为JVM默认垃圾收集器

支持http2.0和websocket的API

重要特性：主要是API的优化，如支持HTTP2的Client API、JVM采用G1为默认垃圾收集器。


### JDK10新特性（2018年3月）

局部变量类型推断，类似JS可以通过var来修饰局部变量，编译之后会推断出值的真实类型

不可变集合的改进

并行全垃圾回收器 G1，来优化G1的延迟

线程本地握手，允许在不执行全局VM安全点的情况下执行线程回调，可以停止单个线程，而不需要停止所有线程或不停止线程

Optional新增orElseThrow()方法

类数据共享

Unicode 语言标签扩展

根证书

重要特性：通过var关键字实现局部变量类型推断，使Java语言变成弱类型语言、JVM的G1垃圾回收由单线程改成多线程并行处理，降低G1的停顿时间。

### JDK11新特性（2018年9月）（LTS版本）

增加一些字符串处理方法

用于 Lambda 参数的局部变量语法

Http Client重写，支持HTTP/1.1和HTTP/2 ，也支持 websockets

可运行单一Java源码文件，如：java Test.java

ZGC：可伸缩低延迟垃圾收集器，ZGC可以看做是G1之上更细粒度的内存管理策略。由于内存的不断分配回收会产生大量的内存碎片空间，因此需要整理策略防止内存空间碎片化，在整理期间需要将对于内存引用的线程逻辑暂停，这个过程被称为"Stop the world"。只有当整理完成后，线程逻辑才可以继续运行。（并行回收）

支持 TLS 1.3 协议

Flight Recorder（飞行记录器），基于OS、JVM和JDK的事件产生的数据收集框架

对Stream、Optional、集合API进行增强

重要特性：对于JDK9和JDK10的完善，主要是对于Stream、集合等API的增强、新增ZGC垃圾收集器。

### JDK12新特性（2019年3月）

Switch 表达式扩展，可以有返回值

新增NumberFormat对复杂数字的格式化

字符串支持transform、indent操作

新增方法Files.mismatch(Path, Path)

Teeing Collector

支持unicode 11

Shenandoah GC，新增的GC算法

G1收集器的优化，将GC的垃圾分为强制部分和可选部分，强制部分会被回收，可选部分可能不会被回收，提高GC的效率

重要特性：switch表达式语法扩展、G1收集器优化、新增Shenandoah GC垃圾回收算法。

### JDK13新特性（2019年9月）

Switch 表达式扩展，switch表达式增加yield关键字用于返回结果，作用类似于return，如果没有返回结果则使用break

文本块升级 """ ，引入了文本块，可以使用"""三个双引号表示文本块，文本块内部就不需要使用换行的转义字符

SocketAPI 重构，Socket的底层实现优化，引入了NIO

FileSystems.newFileSystem新方法

ZGC优化，增强 ZGC 释放未使用内存，将标记长时间空闲的堆内存空间返还给操作系统，保证堆大小不会小于配置的最小堆内存大小，如果堆最大和最小内存大小设置一样，则不会释放内存还给操作系统

重要特性：ZGC优化，释放内存还给操作系统、socket底层实现引入NIO。

### JDK14新特性（2020年3月）

instanceof模式匹配，instanceof类型匹配语法简化，可以直接给对象赋值，如if(obj instanceof String str),如果obj是字符串类型则直接赋值给了str变量

引入Record类型，类似于Lombok 的@Data注解，可以向Lombok一样自动生成构造器、equals、getter等方法；

Switch 表达式-标准化

改进 NullPointerExceptions提示信息，打印具体哪个方法抛的空指针异常，避免同一行代码多个函数调用时无法判断具体是哪个函数抛异常的困扰，方便异常排查；

删除 CMS 垃圾回收器

### JDK15新特性（2020年9月）

EdDSA 数字签名算法

Sealed Classes（封闭类，预览），通过sealed关键字修饰抽象类限定只允许指定的子类才可以实现或继承抽象类，避免抽象类被滥用

Hidden Classes（隐藏类）

移除 Nashorn JavaScript引擎

改进java.net.DatagramSocket 和 java.net.MulticastSocket底层实现

### JDK16新特性（2021年3月）

允许在 JDK C ++源代码中使用 C ++ 14功能

ZGC性能优化，去掉ZGC线程堆栈处理从安全点到并发阶段

增加 Unix 域套接字通道

弹性元空间能力

提供用于打包独立 Java 应用程序的 jpackage 工具

JDK16相当于是将JDK14、JDK15的一些特性进行了正式引入，如instanceof模式匹配（Pattern matching）、record的引入等最终到JDK16变成了final版本。

### JDK17新特性（2021年9月）（LTS版本）

Free Java License

JDK 17 将取代 JDK 11 成为下一个长期支持版本

Spring 6 和 Spring Boot 3需要JDK17

移除实验性的 AOT 和 JIT 编译器

恢复始终执行严格模式 (Always-Strict) 的浮点定义

正式引入密封类sealed class，限制抽象类的实现

统一日志异步刷新，先将日志写入缓存，然后再异步刷新

虽然JDK17也是一个LTS版本，但是并没有像JDK8和JDK11一样引入比较突出的特性，主要是对前几个版本的整合和完善。

## 模块化 Java9

模块是新的结构，就像我们已经有包一样。使用新的模块化编程开发的应用程序可以看作是交互模块的集合，这些模块之间具有明确定义的边界和依赖关系。

在java模块化编程中：

- 一个模块通常只是一个 jar 文件，在根目录下有一个文件module-info.class。
- 要使用模块，请将 jar 文件包含到modulepath而不是classpath. 添加到类路径的模块化 jar 文件是普通的 jar 文件，module-info.class文件将被忽略。

总结：模块化的目的，是让jdk的各个组件可以被分拆，复用和替换重写

## 本地变量类型推断 Java10

```java
// 在Java 10之前版本中，我们想定义定义局部变量时。我们需要在赋值的左侧提供显式类型，并在赋值的右边提供实现类型：   
MyObject value = new MyObject();
// 在Java 10中，提供了本地变量类型推断的功能，可以通过var声明变量：
var value = new MyObject();
```

## 语法糖

### Collectors.teeing()

teeing 收集器已公开为静态方法Collectors::teeing。该收集器将其输入转发给其他两个收集器，然后将它们的结果使用函数合并。

借鉴unix管道的思想

```c++
List<Student> list = Arrays.asList(
        new Student("唐一", 55),
        new Student("唐二", 60),
        new Student("唐三", 90));

//平均分 总分
String result = list.stream().collect(Collectors.teeing(
        Collectors.averagingInt(Student::getScore),
        Collectors.summingInt(Student::getScore),
        (s1, s2) -> s1 + ":" + s2));

//最低分  最高分
String result2 = list.stream().collect(Collectors.teeing(
        Collectors.minBy(Comparator.comparing(Student::getScore)),
        Collectors.maxBy(Comparator.comparing(Student::getScore)),
        (s1, s2) -> s1.orElseThrow() + ":" + s2.orElseThrow()
));

System.out.println(result);
System.out.println(result2);
```

### yield关键字（jdk13）

使用yield，我们现在可以有效地从 switch 表达式返回值，并能够更容易实现策略模式。

```java
public class SwitchTest {
    public static void main(String[] args) {
        var me = 4;
        var operation = "平方";
        var result = switch (operation) {
            case "加倍" -> {
                yield me * 2;
            }
            case "平方" -> {
                yield me * me;
            }
            default -> me;
        };

        System.out.println(result);
    }
}
```

### 文本块改进（jdk13）

```java
// 早些时候，为了在我们的代码中嵌入 JSON，我们将其声明为字符串文字：
String json  = "{\r\n" + "\"name\" : \"lingli\",\r\n" + "\"website\" : \"https://www.alibaba.com/\"\r\n" + "}";

// 现在让我们使用字符串文本块编写相同的 JSON ：
String json = """ 
{     
    "name" : "Baeldung",     
    "website" : "https://www.alibaba.com/" 
} 
""";
```

### record记录类（jdk16正式）

传统的Java应用程序通过创建一个类，通过该类的构造方法实例化类，并通过getter和setter方法访问成员变量或者设置成员变量的值。有了record关键字，你的代码会变得更加简洁。

```java
/**
 * record 记录类
 * 你也可以覆写equals() hashCode() toString()方法，不用写get、set了
 * @author DAYANG
 */
record User(String name, Integer age) {
    
    @Override
    public String toString() {
        return "User[" +
                "name='" + name + '\'' +
                ", age=" + age +
                ']';
    }
    @Override
    public boolean equals(Object obj) {
        return false;
    }
    @Override
    public int hashCode() {
        return 0;
    }
}
```

## GC

GC变化

- JDK9: 设置G1为JVM默认垃圾收集器
- JDK10：并行全垃圾回收器 G1，通过并行Full GC, 改善G1的延迟。目前对G1的full GC的实现采用了单线程-清除-压缩算法。JDK10开始使用并行化-清除-压缩算法。
- JDK11：推出ZGC新一代垃圾回收器（实验性）,目标是GC暂停时间不会超过10ms，既能处理几百兆的小堆，也能处理几个T的大堆。
- JDK14 ：删除CMS垃圾回收器;弃用 ParallelScavenge + SerialOld GC 的垃圾回收算法组合;将 zgc 垃圾回收器移植到 macOS 和 windows 平台
- JDk 15 : ZGC (JEP 377) 和Shenandoah (JEP 379) 不再是实验性功能。默认的 GC 仍然是G1。
- JDK16：增强ZGC，ZGC获得了 46个增强功能 和25个错误修复，控制stw时间不超过10毫秒