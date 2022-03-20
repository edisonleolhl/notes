# 探秘Java中的ThreadLocal

## 多线程基础

`Thread`对象代表一个线程，我们可以在代码中调用`Thread.currentThread()`获取当前线程

## ThreadLocal

### 简介

ThreadLocal是一个关于创建线程局部变量的类。

通常情况下，我们创建的变量是可以被任何一个线程访问并修改的。而使用ThreadLocal创建的变量只能被当前线程访问，其他线程则无法访问和修改。



### 用法

创建，支持泛型

```java
ThreadLocal<String> mStringThreadLocal = new ThreadLocal<>(); 
```

set方法

```java
mStringThreadLocal.set("hello world"); 
```

get方法

```java
mStringThreadLocal.get();
```

### 源码

刚才的get与set方法的源码如下，两个方法都用到了方法getMap()

```java
  public T get() {
      Thread t = Thread.currentThread();// 首先获取当前线程
      ThreadLocalMap map = getMap(t); // 用当前线程获取ThreadLocalMap对象
      if (map != null) {
          ThreadLocalMap.Entry e = map.getEntry(this);
          if (e != null) {
              @SuppressWarnings("unchecked")
              T result = (T)e.value;
              return result;
          }
      }
      return setInitialValue();
  }


  public void set(T value) {
      Thread t = Thread.currentThread();
      ThreadLocalMap map = getMap(t);
      if (map != null)
          map.set(this, value);
      else
          createMap(t, value);
    }

ThreadLocalMap getMap(Thread t) {
    return t.threadLocals;
}
```

从getMap()方法可以看到，ThreadLocalMap是ThreadLocal的内部类，ThreadLocalMap的内部类Entry实际持有线程私有变量（TLS），源码如下：

```java
public class ThreadLocal<T> {
  ...
  static class ThreadLocalMap {

        /**
         * The entries in this hash map extend WeakReference, using
         * its main ref field as the key (which is always a
         * ThreadLocal object).  Note that null keys (i.e. entry.get()
         * == null) mean that the key is no longer referenced, so the
         * entry can be expunged from table.  Such entries are referred to
         * as "stale entries" in the code that follows.
         */
        static class Entry extends WeakReference<ThreadLocal<?>> {
            /** The value associated with this ThreadLocal. */
            Object value;

            Entry(ThreadLocal<?> k, Object v) {
                super(k);
                value = v;
            }
        }
}
```

可以看到，Thread类中有threadLocals变量（ThreadLocalMap类型），ThreadLocalMap是ThreadLocal的内部类

### 注意

如果使用了线程池，上一个线程设置了ThreadLocal，线程用完后不会被销毁，而是会回归线程池等待下一次分配，这时ThreadLocal可能就会污染，所以一般线程用完ThreadLocal后最后调用remove方法

```java
  /**
   * Removes the current thread's value for this thread-local
   * variable.  If this thread-local variable is subsequently
   * {@linkplain #get read} by the current thread, its value will be
   * reinitialized by invoking its {@link #initialValue} method,
   * unless its value is {@linkplain #set set} by the current thread
   * in the interim.  This may result in multiple invocations of the
   * {@code initialValue} method in the current thread.
   *
   * @since 1.5
   */
   public void remove() {
       ThreadLocalMap m = getMap(Thread.currentThread());
       if (m != null)
           m.remove(this);
   }
```

## Inheritable ThreadLocal（ITL）

ThreadLocal是线程私有数据，线程之间无法传递，但ThreadLocal.java中提供了ITL，可以用于父子线程之间的上下文传递

### 源码

Thread类不仅有threadLocals变量，还有inheritableThreadLocals变量（它也是ThreadLocalMap类型）

使用InheritableThreadLocal可以将某个线程的ThreadLocal值在其子线程创建时传递过去，在Thread类中创建线程时有特殊的处理逻辑

```java
//Thread.java
 private void init(ThreadGroup g, Runnable target, String name,
                      long stackSize, AccessControlContext acc) {
        //code goes here
        if (parent.inheritableThreadLocals != null)
            this.inheritableThreadLocals =
                ThreadLocal.createInheritedMap(parent.inheritableThreadLocals);
        /* Stash the specified stack size in case the VM cares */
        this.stackSize = stackSize;

        /* Set thread ID */
        tid = nextThreadID();
}
```



### 局限性

1. 线程不安全

   Inheritable ThreadLocal并不是用来解决线程不安全的问题的，因此父子线程之间的修改会影响到其他线程

2. 线程池中失效

3. 使用线程池要及时remove

   如果使用了线程池，则Thread、Inheritable ThreadLocal变量都要remove，否则线程池回收后，变量还存在内存中（key是弱引用被回收，但value还在），导致内存泄露

## 一些问题

### ThreadLocalMap的底层结构？数组？链表？哈希表？

用数组是因为，我们开发过程中可以一个线程可以有多个TreadLocal来存放不同类型的对象的，但是他们都将放到你当前线程的ThreadLocalMap里，所以肯定要数组来存。

很像HashMap的，但是看源码可以发现，它并未实现Map接口，而且他的Entry是继承WeakReference（弱引用）的，也没有看到HashMap中的next，所以不存在链表了。

### **能跟我说一下对象存放在哪里么？**

在Java中，栈内存归属于单个线程，每个线程都会有一个栈内存，其存储的变量只能在其所属线程中可见，即栈内存可以理解成线程的私有内存，而堆内存中的对象对所有线程可见，堆内存中的对象可以被所有线程访问。

### **那么是不是说ThreadLocal的实例以及其值存放在栈上呢？**

其实不是的，因为ThreadLocal实例实际上也是被其创建的类持有（更顶端应该是被线程持有），而ThreadLocal的值其实也是被线程实例持有，它们都是位于堆上，只是通过一些技巧将可见性修改成了线程可见。

### 内存泄露

ThreadLocal在保存的时候会把自己当做Key存在ThreadLocalMap中，正常情况应该是key和value都应该被外界强引用才对，但是现在key被设计成WeakReference弱引用了。

> 只具有弱引用的对象拥有更短暂的生命周期，在垃圾回收器线程扫描它所管辖的内存区域的过程中，一旦发现了只具有弱引用的对象，不管当前内存空间足够与否，都会回收它的内存。
>
> 不过，由于垃圾回收器是一个优先级很低的线程，因此不一定会很快发现那些只具有弱引用的对象。

这就导致了一个问题，ThreadLocal在没有外部强引用时，发生GC时会被回收，如果创建ThreadLocal的线程一直持续运行，那么这个Entry对象中的value就有可能一直得不到回收，发生内存泄露。

就比如线程池里面的线程，线程都是复用的，那么之前的线程实例处理完之后，出于复用的目的线程依然存活，所以，ThreadLocal设定的value值被持有，导致内存泄露。

按照道理一个线程使用完，ThreadLocalMap是应该要被清空的，但是现在线程被复用了。

**解决**：在代码的最后使用remove就好了（参见上文的『注意』小节

### **那为什么ThreadLocalMap的key要设计成弱引用？**

key不设置成弱引用的话就会造成和entry中value一样内存泄漏的场景。

## C++的ThreadLocal

C++11引入了ThreadLocal，但其实现与原理与Java大相庭径

- 它会影响变量的存储周期(Storage duration)，C++中有4种存储周期：

    1. automatic
    2. static
    3. dynamic
    4. thread

- 有且只有thread_local关键字修饰的变量具有线程周期(thread duration)，这些变量(或者说对象）在线程开始的时候被生成(allocated)，在线程结束的时候被销毁(deallocated)。并且每 一个线程都拥有一个独立的变量实例(Each thread has its own instance of the object)。thread_local 可以和static 与 extern关键字联合使用，这将影响变量的链接属性(to adjust linkage)。

- 以下三类变量可以被声明为thread_local：

    1. 命名空间下的全局变量
    2. 类的static成员变量
    3. 本地变量

- 引用《C++ Concurrency in Action》书中的例子来说明这3种情况：

    ```c++
    thread_local int x;  //A thread-local variable at namespace scope
    class X
    {
        static thread_local std::string s; //A thread-local static class data member
    };
    static thread_local std::string X::s;  //The definition of X::s is required

    void foo()
    {
        thread_local std::vector<int> v;  //A thread-local local variable
    }
    ```