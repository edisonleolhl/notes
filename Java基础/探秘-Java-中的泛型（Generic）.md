>本文包括：
>1. JDK5之前集合对象使用问题
>2. 泛型的出现
>3. 泛型应用
>4. 泛型典型应用
>5. 自定义泛型——泛型方法
>6. 自定义泛型——泛型类
>7. 泛型的高级应用——通配符(wildcard)
>8. 泛型通配符的扩展阅读

## 泛型（Generic）

### 1、JDK5之前集合对象使用问题

1. 可以向集合添加任何类型对象 

2. 从集合取出对象时，数据类型丢失，使用与类型相关方法，强制类型转换。

3. 程序存在安全隐患 

### 2、泛型的出现

1. JDK5中的泛型允许程序员使用泛型技术限制集合的处理类型

        List<String> list = new ArrayList<String>();

2. **注意**：泛型是提供给javac编译器使用的，它用于限定集合的输入类型，让编译器在源代码级别上，即挡住向集合中插入非法数据。但编译器编译完带有泛型的java程序后，生成的.class文件中将不再带有泛型信息，因此程序运行效率不受影响，这个过程称为“**擦除**”。

3. 泛型的基本术语，以ArrayList<E>为例："<>"读作typeof

    - ArrayList<E>中的E称为类型参数变量
    - ArrayList<Integer>中的Integer称为实际类型参数。
    - 整个ArrayList<Integer>称为参数化类型ParameterizedType

### 3、 泛型应用

- 类型安全检查

- 编写通用Java程序（Java框架）

### 4、泛型典型应用

1. 使用Type-Safe的集合对象

    - List
    
    - Set

    - Map

2. List示例：

    ```java
        //使用类型安全List
        List<String> list = new LinkedList<String>();
        //因为使用泛型，只能添加String类型元素
        list.add("aaa");
        list.add("bbb");
        list.add("ccc");
        
        //遍历List有三种方法
        
        //方法一：因为List是有序的（存入顺序和取出顺序一样），通过size和get方法进行遍历
        for (int i = 0; i < list.size(); i++) {
            String s = list.get(i);
            System.out.println(s);
        }

        //方法二：因为List继承Collection接口，通过Collection的iterator进行遍历
        Iterator<String> iterator = list.iterator();
        //遍历iterator通过迭代器hasNext和next方法进行遍历
        while (iterator.hasNext()) {
            String s = iterator.next();
            System.out.println(s);
        }
     
        //方法三：JDK5引入了foreach循环结构，通过foreach结构遍历List
        for (String s : list) {
            System.out.println(s);
        }
    ```

3. Set示例：
    
    ```java
        //使用类型安全Set
        Set<String> set = new TreeSet<String>();

        set.add("asd");
        set.add("fdf");
        set.add("bxc");
    
        //取出Set元素有两种方法，因为Set是无序的，所以比List少一种遍历方法
        //方法一：Set继承Collection，所以可以使用Iterator遍历
        Iterator<String> iterator = set.iterator();
        while (iterator.hasNext()) {
            String s = iterator.next();
            System.out.println(s);
        }

        //方法二：JDK5引入了foreach
        for (String s : set) {
            System.out.println(s);
        }
    ```

4. Map示例：

    ```java
        //使用类型安全的Map -- 因为Map是一个键值对结构，执行两个类型泛型
        Map<String, String> map = new HashMap<String, String>();

        map.put("aaa", "111");
        map.put("bbb", "222");

        //取出Map元素有两种方法
        //方法一：通过Map的keySet()进行遍历
        Set<String> keys = map.keySet(); // 获得key的集合
        for (String key : keys) {
            System.out.println(key + ":" + map.get(key));
        }

        //方法二：通过map的entrySet()，获得每一个键值对。
        Set<Map.Entry<String, String>> entrySet = map.entrySet(); //每个元素都是一个键值对

        for (Entry<String, String> entry : entrySet) {
            //通过entry的getKey()和getValue()获得每一个键值对的键和值
            System.out.println(entry.getKey() + ":" + entry.getValue());
        }
    ```

### 5、自定义泛型——泛型方法

1. Java中的普通方法、构造方法和静态方法中都可以使用泛型。方法使用泛型前，必须对泛型进行声明，语法：<T>，T可以是任意字母，但通常必须要大写。<T>通常需放在方法的返回值声明之前。
例如：

    ```java  
        public static <T> void doxx(T t）;
    ```

2. 假设有这样一个需求，要求实现指定位置上数组元素的交换，这个数组中的元素可能是int型，可能是String类型。

    - 未使用泛型代码如下：

        ```java
            //String类型数组
            public void changePosition(String[] arr, int index1, int index2) {
                String temp = arr[index1];
                arr[index1] = arr[index2];
                arr[index2] = temp;
            }
            
            //int类型数组
            public void changePosition(int[] arr, int index1, int index2) {
                int temp = arr[index1];
                arr[index1] = arr[index2]; 
                arr[index2] = temp; 
            }
    
            Integer[] arr1 = new Integer[] { 1, 2, 3, 4, 5 };
            changePosition(arr1, 1, 3); 
            System.out.println(Arrays.toString(arr1));
    
            String[] arr2 = new String[] { "aaa", "bbb", "ccc", "ddd" };
            changePosition(arr2, 0, 2);
            System.out.println(Arrays.toString(arr2));
        ```

    - 使用泛型代码如下：
        
        ```java
            // 使用泛型 编写交换数组通用方法，类型可以String 可以 int --- 通过类型
            public <T> void changePosition(T[] arr, int index1, int index2) {
                T temp = arr[index1];
                arr[index1] = arr[index2];
                arr[index2] = temp;
            }

            Integer[] arr1 = new Integer[] { 1, 2, 3, 4, 5 };
            changePosition(arr1, 1, 3); 
            System.out.println(Arrays.toString(arr1));
    
            String[] arr2 = new String[] { "aaa", "bbb", "ccc", "ddd" };
            changePosition(arr2, 0, 2);
            System.out.println(Arrays.toString(arr2));
        ```

    - 两者输出相同，所以利用泛型可以编写通用的Java程序

### 6、自定义泛型——泛型类

1. 如果一个类多处都要用到同一个泛型，这时可以吧泛型定义在类上（即类级别的泛型），语法如下：

    ```java
        public class GenericDao<T>{
            private T field1;
            public void save(T obj){}
            public T getId(int id){}
        }
    ```

    >**注意：**静态方法不能使用类定义的泛型，应该单独定义泛型。

2. 示例：

    如果在1.5节中还需要一个需求：倒序数组，那么可以自定义一个泛型类：
        
    ```java
        public class ArraysUtils<A> { // 类的泛型
            // 将数组倒序
            public void reverse(A[] arr) {
                /*
                 * 只需要遍历数组前一半元素，和后一半元素 对应元素 交换位置
                 */
                for (int i = 0; i < arr.length / 2; i++) {
                    // String first = arr[i];
                    // String second = arr[arr.length - 1 - i];
                    A temp = arr[i];
                    arr[i] = arr[arr.length - 1 - i];
                    arr[arr.length - 1 - i] = temp;
                }
            }
        
            public void changePosition(A[] arr, int index1, int index2) {
                A temp = arr[index1];
                arr[index1] = arr[index2];
                arr[index2] = temp;
            }
        }
    ```

>对应泛型类型参数起名 T E K V ---- 泛型类型可以以任意大写字母命名，建议你使用有意义的字母
如：T Template E Element  K key V value  

### 7、泛型的高级应用——通配符(wildcard)

1. 假设有一个方法，接受一个集合，并打印出集合中的所有元素，如下所示：

    ```java
        // ? 代表任意类型
        public void print(List<?> list) { // 泛型类型 可以是任何类型 --- 泛型通配符
            for (Object string : list) {
                System.out.println(string);
            }
        }
        
        public void demo10() {
            // 打印数组中所有元素内容
            List<String> list = new LinkedList<String>();
    
            list.add("aaa");
            list.add("bbb");
            list.add("ccc");
            print(list);
    
            List<Integer> list2 = new LinkedList<Integer>();
    
            list2.add(111);
            list2.add(222);
            list2.add(333);
    
            print(list2);
        }
    ```

2. 只用通配符的情况下很少，通常还需要通过指定上下边界，限制通配符类型范围。
    用法：
    
    - 指定上边界：

        ```java    
            List<？ extends Number> list = new ArrayList<Integer>(); //继承自Number，即指定了泛型的上边界为Number，且包括Number
        ```

    - 指定下边界：
    
        ```java
            List<? super String> list = new ArrayList<Object>(); //是String的父类，即指定了泛型的下边界为String，且包括String
        ```
        
    - 上下边界不能同时使用 ：

        ```java
            List<? extends Object super Integer> list = new ArrayList<Object>(); //错误！没有这么写的
        ```

3. 上下边界的应用：

    - 范例一：
    
    Set中有方法：addAll(Collection<? extends E> c)  //将目标集合c的内容添加到当前set ，? extends E 目标集合是E的子类型 
    
    即有如下代码，可以运行成功：
        
        ```java
            Set<Number> set = new HashSet<Number>();
            List<Integer> list = new ArrayList<Integer>();
            set.addAll(list); // list 中 Integer 自动转换为 Number
        ```
    
    - 范例二：

    TreeSet有构造方法：TreeSet(Comparator<? super E> comparator) //传入E的父类型的比较器
    
    即有如下代码，可以运行成功：
    
        ```java
            Set<Apple> set = new TreeSet<Apple>(); // 默认需要苹果比较器排序 
            
            class FruitComparator implements Comparator<Fruit> {} //水果的比较器
            Set<Apple> set = new TreeSet<Apple>(new FruitComparator()); // 需要Apple比较器 ，传入 Fruit比较器    ，依据构造方法，可行    
        ```

4. 错误范例：

    ```java
        public void add(List<? extends Number> list){
            list.add(100);  //会报错！使用通配符后，不要使用与类型相关的方法。
        }
    ```

### 8、泛型通配符的扩展阅读

1. 关于泛型还可深入研究，在《Effective Java 2th Edition》有相关介绍，感兴趣的同学可以阅读一下。

2. 最后还介绍一下关于泛型通配符的上下边界问题，什么时候用上边界，什么时候用下边界？
PECS：producer extends consumer super

    1. 频繁往外读取内容的，适合用上界Extends。
    
    2. 经常往里插入的，适合用下界Super。

3. 例如：

    ```java
        // compile error
        //    List <? extends Fruit> appList2 = new ArrayList();
        //    appList2.add(new Fruit());
        //    appList2.add(new Apple());
        //    appList2.add(new RedApple());

        // no error
        List <? super Fruit> appList = new ArrayList();
        appList.add(new Fruit());
        appList.add(new Apple());
        appList.add(new RedApple());
    ```

> 参考：http://stackoverflow.com/questions/2723397/what-is-pecs-producer-extends-consumer-super

> 原文发表于：https://www.jianshu.com/p/dc70a0058a29, by 2016.10.03 17:49:50