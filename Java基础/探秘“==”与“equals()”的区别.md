
>本文采用总分总的小学生写作手法较为深入地探究了“==”与“equals()”的区别 :-)

## 概括
- 用途：equals()和“==”操作用于对象的比较，检查俩对象的相等性。

- 性质：前者是方法，后者是操作符。

- 区别：
    1. ==是判断两个变量或实例是不是指向同一个内存空间 
    equals()是判断两个变量或实例所指向的内存空间的值是不是相同 

    2. ==是指对内存地址进行比较 
    equals()是对字符串的内容进行比较

    3. ==指引用是否相同 
    equals()指的是值是否相同

- 通俗来说，如何记住区别？（不严谨的说法）
    ==：等于。
    equals：相同。

## “==”是什么？
1. 是什么？
    “==”或等号操作在Java编程语言中是一个二元操作符，用于比较原生类型和对象。就原生类型如boolean、int、float来说，使用“==”来比较两者，这个很好掌握，比如1=1。但是在比较对象的时候，就会与equals()造成困惑。

2. 原理：
    “==”对比两个对象基于内存引用，如果两个对象的引用完全相同（指向同一个对象）时，“==”操作将返回true，否则返回false。

3. 编程示例：

    ```java
        class AnotherClass{
            
        }
        public class EqualsTest {
            public static void main(String[] args) {
                //基本数据类型：int、float、double、boolean、char等 
                char ch1 = 'a';
                char ch2 = 'a';
                System.out.println("char比较结果：" + (ch1==ch2));
                
                int i1 = 100;
                int i2 = 100;
                System.out.println("int比较结果：" + (i1==i2));
                
                //字符串数据类型
                String str1 = new String("liaoshaoshao");
                String str2 = new String("liaoshaoshao");
                String str3 = str2;
                System.out.println("两个new出来的字符串比较结果：" + (str1==str2));
                System.out.println("赋值出来的字符串比较结果：" + (str3==str2));
                
                //对象
                AnotherClass ac1 = new AnotherClass();
                AnotherClass ac2 = new AnotherClass();
                AnotherClass ac3 = ac2;
                System.out.println("两个new出来的对象比较结果：" + (ac1==ac2));
                System.out.println("赋值出来的对象比较结果：" + (ac3==ac2));
            }
        }
    ```

    控制台输出：    

    ```bash
        char比较结果：true
        int比较结果：true
        两个new出来的字符串比较结果：false
        赋值出来的字符串比较结果：true
        两个new出来的对象比较结果：false
        赋值出来的对象比较结果：true
    ```
    
## "equals()"是什么？
- 是什么？
    equals()方法定义在Object类里面，根据具体的业务逻辑来定义该方法，用于检查两个对象的相等性。

- 实际用途：
    Java 语言里的 equals方法其实是交给开发者去覆写的，让开发者自己去定义满足什么条件的两个Object是equal的。

- 在默认情况下(即该类默认继承Object类)，equals()和==是一样的，除非被覆写(override)了。
    因为在Object类中有equals()，其代码如下：
    
    ```java
        public boolean equals(Object obj) {
            return (this == obj);
        }
    
    ```
    可以看出，如果不覆写，那么equals()与==没什么区别。
    >引申阅读：
    官方API文档中关于Object类的equals()的解释：
    public boolean equals(Object obj)指示其他某个对象是否与此对象“相等”。 
    equals 方法在非空对象引用上实现相等关系： 

      - 自反性：对于任何非空引用值 x，x.equals(x) 都应返回 true。 
      - 对称性：对于任何非空引用值 x 和 y，当且仅当 y.equals(x) 返回 true 时，x.equals(y) 才应返回 true。 
      - 传递性：对于任何非空引用值 x、y 和 z，如果 x.equals(y) 返回 true，并且 y.equals(z) 返回 true，那么 x.equals(z) 应返回 true。 
      - 一致性：对于任何非空引用值 x 和 y，多次调用 x.equals(y) 始终返回 true 或始终返回 false，前提是对象上 equals 比较中所用的信息没有被修改。 
      - 对于任何非空引用值 x，x.equals(null) 都应返回 false。 
      Object 类的 equals 方法实现对象上差别可能性最大的相等关系；即，对于任何非空引用值 x 和 y，当且仅当 x 和 y 引用同一个对象时，此方法才返回 true（x == y 具有值 true）。 
      - 注意：当此方法被重写时，通常有必要重写 hashCode 方法，以维护 hashCode 方法的常规协定，该协定声明相等对象必须具有相等的哈希码。 

- 假设该类覆写了equals()，那么就按照开发者自己想要的逻辑来判断。最典型的例子当属String类，String类中已经覆写了equals()，源码如下：

    ```java
        public boolean equals(Object anObject) {
            if (this == anObject) {
                return true;
            }
            if (anObject instanceof String) {
                String anotherString = (String) anObject;
                int n = value.length;
                if (n == anotherString.value.length) {
                    char v1[] = value;
                    char v2[] = anotherString.value;
                    int i = 0;
                    while (n-- != 0) {
                        if (v1[i] != v2[i])
                            return false;
                        i++;
                    }
                    return true;
                }
            }
            return false;
        }
    ```

    个人见解：
    - String类的equals()方法调用后，首先会比较这两个String类的对象（即两个字符串)的地址是否相等，若相等，那当然“equals”，返回true。
    - anObject即为传入的参数，首先得确定它是String类的对象，所以用instanceof来判断，如果连String类型都不是，那只执行最后的`return false`。满足条件后，强制转换为String类型。
    - value.length是自对象的字符串长度。
    - 两个字符串长度相等，才能继续比较，长度不等，则返回false。
    - 接下来就是依次比较两个字符串中字符是否相等，若出现了不相等的字符，直接返回false，如果一直到比较完了都没有出现不相等的字符，则返回true
    - **结论：String类中的equals方法用来比较两个字符串内容是否相等。**(当然，地址相等，那么内容肯定也是相等的）

## 总结：
- 对于值变量（int、float、double、char等），用“==”来判断相等性。

- 对于String，用“==”来判断字符串地址是否相等，用“equals()”来判断字符串内容是否相等。

- 对于引用对象，用“==”来判断对象地址是否相等，经常覆写equals方法，让开发者自己去定义满足什么条件的两个Object是equal的。

>引申阅读：
>[https://www.zhihu.com/question/26872848](https://www.zhihu.com/question/26872848)

>学生一枚，难免有错误之处，请各位大神斧正。

> 原文发表于：https://www.jianshu.com/p/e93cf60246de, by 2016.09.20 19:11:33