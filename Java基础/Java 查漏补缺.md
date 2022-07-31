# Java 查漏补缺

## 集合框架

Collection 接口 ( java.util.Collection ) 和 Map 接口 ( java.util.Map ) 是 Java 集合类的两个主要“根”接口。

### Collection 接口 - List 接口

[Java 集合框架之 List 接口及其子类篇](https://mp.weixin.qq.com/s/Z9vQxWQGqDZ55uCrON3avw)

- List 接口是 Collection 接口的子接口，可以存储重复元素的有序集合 。
- List 保存了插入顺序，允许按位置访问和插入元素。
- List 接口是 ListIterator 接口的工厂，通过 ListIterator 迭代器接口，可以向前或向后迭代 list 中的元素。
- ArrayList 、LinkedList 、Vector 都是 List 接口的实现类，其中 ArrayList 和 LinkedList 在编写 java 程序时广泛使用，Vector 类在 java 5 之后被弃用。

```java
// 接口声明
public interface List<E> extends Collection<E>;
// 使用方法
List<T> list = new ArrayList<T>();
```

#### ArrayList

[​ArrayList 底层结构与源码分析](https://mp.weixin.qq.com/s/UYCt2DeV-FcwgyRONarnBA)

- ArrayList 对应于顺序存储结构（数组）
- ArrayList 基本等同于 Vector，ArrayList 是线程不安全（执行效率高），在多线程情况下，不建议使用 ArrayList 。
- ArrayList 中维护了一个 Object 类型的数组 elementData（`transient Object[] elementData;`）
- 当创建对象时，如果使用的是无参构造器，则初始 elementData 容量为 0
- 当添加元素时：先判断是否需要扩容，如果需要扩容，则调用 grow 方法；否则直接添加元素到合适的位置
- 如果使用的是无参构造器，如果第一次添加元素，需要扩容的话，则扩容 elementData 的大小为 10，如果需要再次扩容的话，则扩容 elementData 为 1.5 倍。
- 如果使用的是指定大小的有参构造器，则初始 elementData 的大小为指定大小，如果需要扩容，则扩容为指定大小的 1.5 倍。
- ArrayList 插入和删除操作的时间复杂度为 O(n)  ，查找操作的时间复杂度为 O(1) 。

### Collection 接口 - Queue 接口

<https://mp.weixin.qq.com/s/Z9vQxWQGqDZ55uCrON3avw>

- Queue 接口出现在 java.util 包中，它也继承自 Collection 接口，用于保存要按先进先出 FIFO（First In First Out）顺序处理的元素。
- 常见的实现类是PriorityQueue与LinkedList，但不是线程安全的，若想要线程安全的 Queue，可以使用java.util.concurrent 包下面的 PriorityBlockingQueue 类

```java
// 接口声明
public interface Queue extends Collection  

// 使用方法
Queue<Obj> queue = new PriorityQueue<Obj> ();
Queue<Integer> q = new LinkedList<>();
```

### Map 接口之 HashMap、LinkedHashMap、TreeMap 之间的区别和特点

<https://mp.weixin.qq.com/s/co76AhTSQD8Lt5u2A89QlA>

- Map 接口不是 Collection 接口的子接口，与 Collection 是并列存在的。
- 键值对，一一对应，键不能重复，值可以重复
- Map 接口有些实现类支持 key 为 null，也支持 value 为 null，比如 HashMap 和 LinkedHashMap ，注意 key 为 null 只能有一个，value 为 null 可以有多个。TreeMap 不允许 key 为 null ，如果 key 为 null 将抛出空指针异常。
- 增删改查方法分别为：put()、remove()、put()、get() 。

```java
Map<Obj, Obj> hm = new HashMap<Obj, Obj>();
// Obj 表示要存储在 Map 中的对象的类型
```

- HashMap是 Map 接口的基本实现，使用哈希技术，保存在HashMap 的键值对的顺序不是插入顺序
- LinkedHashMap 在保持 HashMap 快速插入、搜索和删除的优势之外，有一个额外的特性，即维护插入其中的元素的顺序。
- TreeMap 实现了 Map 和 NavigableMap 接口，继承了抽象类 AbstractMap。TreeMap 根据其键的自然顺序进行排序，或者根据创建时提供的比较器（取决于使用哪个构造器）进行排序

### Collection 接口 - Set 接口

<https://mp.weixin.qq.com/s/ZXxyFsw5VziD08Fuq_UPlA>

- java.util.set 接口继承自 Collection 接口，是一个不能存储重复元素的无序集合。它与数学中的集合在特性上是一致的。

```java
// Set 接口的定义：
public interface Set extends Collection
// Set 接口实例的创建：
Set<Obj> set = new HashSet<Obj>();
```

- HashSet 类是哈希表数据结构的固有实现，插入到 HashSet 中的对象的存储顺序与插入顺序无关，允许插入 null
- LinkedHashSet 类是 HashSet 的子类，也是其有序版本，它的底层由一个双向链表维护元素的次序
- TreeSet 类，实现了 SortedSet  接口， SortedSet 继承自 Set 接口，所以 TreeSet 也保留了 Set 的一些基本属性。它的行为类似于一个简单的 Set，但是它以排序的格式存储元素。TreeSet 使用树型数据结构进行存储。对象默认按升序排序存储
