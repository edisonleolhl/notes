>本文大部分摘自《Effective Java》，示例为本人手打，IDE是eclipse。
>本人之前写过一篇关于泛型的介绍：http://www.jianshu.com/p/dc70a0058a29

##1. 先看几个定义

- 泛型（generic）：

    - 声明中具有一个或者多个类型参数（type parameter）的类或者接口，就是泛型类或者接口。
    
    - 例如，从Java 1.5发行版本开始，List接口就只有单个类型参数E，表示列表的元素类型。
    
    - 从技术角度来看，这个借口的名称应该是指现在的List<E>（读作“list of E/E的列表”），但是人们一般把它简称为List。
    
    - 泛型类和接口统称为泛型（generic type）。

- 参数化的类型（parameterized type）：
        
    - 构成格式。先是类或者接口的名称，接着用尖括号`<>`把对应于泛型形式类型参数的实际类型参数列表括起来。

    - 例如，List<String>（读作“list of string”）是一个参数化的类型，表示元素类型为String的列表。（String是与形式类型参数E相对应的实际类型参数）
    
- 原生态类型（raw type）：

    - 不带任何实际类型参数的泛型名称

    - 例如，与List<E>相对应的原生态类型是List。原生态类型就像从类型生命中删除了所有泛型信息一样。

    - 实际上，原生态类型List与Java平台没有泛型之前的接口类型List完全一样。

##2. 从一个原生态类型的示例引出泛型

1. 在Java 1.5版本发行之前（即无泛型之前），假设有这样的集合声明：
    
        /**
         * My stamp collection. Contains only stamp instances.
         * /
        private final Collection stamps = ... ;

    如果不小心将一个coin放入了stamp集合，这个错误的操作照样可以编译和运行，并且没有任何错误提示：

        stamp.add(new Coin(...));

    直到从stamp集合中获取到这个coin时才会收到错误提示：
    
        for(Iterator i = stamps.iterator(); i.hasNext();){
            Stamp s = (Stamp) i.next(); // 抛出ClassCastException异常！！！
        }

    这种错误应该尽快发现，最好在编译时就发现。在本例中，这个错误已经存在很久很久了，距离你现在的代码也许已经很远很远了，一旦出现这种错误，你可能得花费大量时间找出错误的原因。

2. 有了泛型之后，就可以利用改进后的类型声明来代替集合中这种注释，告诉编译器之前的注释隐含的信息（注释是给人看到，而不是给机器看的）：

        //Parameterized collection type - typesafe
        private final Collection<Stamp> stamp = ... ;

    有了这条声明，编译器就知道了：stamps应该只包含stamp实例。如果这时候再试图添加一个coin实例进入stamp集合中，那么编译器给出error,准确地告诉你哪里出错了。

    这就是泛型的好处。

    **如果使用原生态类型，就失掉了泛型在安全性和表述性方面的所有优势。**
    既然不应该使用原生态类型，为什么还要允许使用它们呢？
    因为Java在之前版本已经有大量的代码，为了提供兼容性，旧代码和新代码应可以互用。
    这种需求被称作移植兼容性（Migration Compatibility）。

##3. 原生态类型（如List）与参数化的类型（如List`<Object>`）的区别

1. 不严格地说：前者逃避了泛型检查，后者则明确告知编译器它能够持有任何类型的对象。

2. 虽然你可以将List`<String>`传递给List，但不能将它传递给List`<Object>`。泛型有子类型化（subtyping）的规则，List`<String>`是原生态类型List的一个子类型，而不是参数化类型List`<Object>`的子类型。

3. **简而言之：如果使用像List这样的原生态类型，就会失掉安全性，但是如果使用像List`<Object>`这样的参数化类型，则不会。**

4. 为了更具体地说明两者的区别，有下面的示例：

        import java.util.ArrayList;
        import java.util.List;
        
        public class Main {
            public static void main(String[] args){
                List<String> strings = new ArrayList<String>();
                unsafeAdd(strings, new Integer(42));
                //String s = strings.get(0); 
            }
            
            private static void unsafeAdd(List list, Object o){
                list.add(o);
            }
        }

    编译后，没有error。这说明unsafeAdd方法已经被调用，并且检查后没出错误。
    
    若把注释符号去掉，如下：

        import java.util.ArrayList;
        import java.util.List;
        
        public class Main {
            public static void main(String[] args){
                List<String> strings = new ArrayList<String>();
                unsafeAdd(strings, new Integer(42));
                String s = strings.get(0); 
            }
            
            private static void unsafeAdd(List list, Object o){
                list.add(o);
            }
        }

    
    编译后，控制台输出error：

        Exception in thread "main" java.lang.ClassCastException: java.lang.Integer cannot be cast to java.lang.String
            at Main.main(Main.java:8)

    **这说明**：用原生态类型，在取出的时候不能确定其类型，所以不能转为String类型，所以会报错，这种错误与前文的coin、stamp的示例基本相同，应当极力避免。

    如果在unsafeAdd声明中用参数化类型List<Object>代替原生态类型List，即：
            
        private static void unsafeAdd(List<Object> list, Object o){
            list.add(o);
        }

    在IDE中会直接报错：
    
        The method unsafeAdd(List<Object>, Object) in the type Main is not applicable for the arguments (List<String>, Integer)

    **这说明**：用参数化类型更加安全。

##4. Set<?>：无限制的通配符类型（unbounded wildcard type）

1. 在不确定或者不在乎集合中的元素类型的情况下，你有可能还是会继续使用原生态类型。例如，想要编写一个方法，它有两个集合（set），并从中返回它们共有的元素的数量。如果你对泛型不熟悉的话，可以参考以下方式来编写这种方法：
    
        // Use of raw type for unknown element type - don't do this!
        static int numElmentsInCommon(Set s1, Set s2){
            int result = 0;
            for(Object o1 : s1){
                if(s2.contains(o1)){
                    result ++;
                }
            }
            return result;
        }

    这个方法倒是可以，但使用了原生态类型，这是很危险的。从Java 1.5发行版本开始，Java就提供了一种很安全的替代方法，称作无限制的通配符类型（unbounded wildcard type）。如果要使用泛型，但不确定或者不关心实际的类型参数，就可以使用一个问号代替。例如，泛型Set<E>的无限制通配符类型为Set<?>（读作“某个类型的集合/set of unknown”）。这是最普通的参数化Set类型，可以持有任何集合。

2. 上面的方法，可以改进一下，更加安全：

        // Unbounded wildcard type - typesafe and flexible!
        static int numElmentsInCommon(Set<?> s1, Set<?> s2){
            int result = 0;
            for(Object o1 : s1){
                if(s2.contains(o1)){
                    result ++;
                }
            }
            return result;
        }

    无限制的通配类型和原生态类型之间有什么区别呢？这一点不需要赘述，但通配符类型是安全的，原生态类型则不安全。由于可以将任何元素放进原生态类型的集合中，因此很容易破坏该集合的类型约束条件（如前文的unsafeAdd方法，放入的时候不报错，取出的时候才报错）。但不能将任何元素（除了null之外）放到Collection<?>中。

3. 不要在新代码中使用原生态类型，这条规则有两个小小的例外，这两个例外都源于“泛型信息可以在运行时被擦除”这一事实。

    - 第一个例外：在类文字（class literal）中必须使用原生态类型。规范不允许使用参数化类型（虽然允许数组类型和基本类型）。换句话说，List.class， String[].class 和 int.class都合法，但是List<String.class>和List<?>.class则不合法。

    - 第二个例外。由于泛型信息可以在运行时被擦除，因此在参数化类型而非无限制通配符类型上使用instanceof操作符是非法的。用无限制通配符类型代替原生态类型，对instanceof操作符的行为不会产生任何影响。在这种情况下，<>和?就显得多余了。下面是利用泛型来使用instanceof操作符的首选方法：

            // Legitimate use of raw type - instanceof operator
            if(o instanceof Set){
                Set<?> m = (Set<?>) o;
                ...
            }

        注意，一旦确定这个o是个Set，就必须将它转换为通配符类型Set<?>，而不是转换为原生态类型Set。这是个受检的（checked）转换，因此不会导致编译时警告。

##5. 结论

1. 使用原生态类型会在运行时导致异常，因此不要再新代码中使用。原生态类型只是为了与引入泛型之前的遗留代码进行兼容和互用而提供的。

2. 回顾一下本文的要点：

    - Set<Object>是个参数话类型，表示可以包含任何对象类型的一个集合；
    
    - Set<?>则是一个通配符类型，表示只能包含某种未知对象类型的一个集合；
    
    - Set则是个原生态类型，它脱离了泛型系统。
    
    - 前两种是安全的，最后一种不安全。
