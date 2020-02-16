# 《Linux多线程服务端编程：使用Muduo C++库》的笔记.md

by陈硕

陈硕个人网站关于本书的[介绍](http://chenshuo.com/book/)

Muduo库[源码](https://github.com/chenshuo/muduo)

thread per connection 一般与阻塞式I/O

I/O复用一般用非阻塞式

## 第1章 线程安全的对象生命期管理

编写线程安全的类不是难事，用**同步原语（synchronization primitives）**保护内部状态即可。但是对象的生与死不能由对象自身拥有的**mutex（互斥器）**来保护。如何避免对象析构时可能存在的**race condition（竞态条件）**是C++多线程编程面临的基本问题，可以借助Boost库中的shared_ptr和weak_ptr完美解决（已加入C++11标准）。这也是实现线程安全的Observer模式的必备技术。

### 当析构函数遇到多线程

一个对象能被多个线程同时看到，对象的销毁就要格外注意，可能出现多种竞态条件

- 在即将析构一个对象时，从何而知此刻是否有别的线程正在执行该对象的成员函数？
- 如何保证在执行成员函数期间，对象不会在另一个线程被析构？
- 在调用某个对象的成员函数之前，如何得知这个对象还活着？它的析构函数会不会碰巧执行到一半？

线程安全的定义如下：

- 多个线程同时访问时，其表现出正确的行为。
- 无论操作系统如何调度这些线程，无论这些线程的执行顺序如何**交织（interleaving）**。
- 调用端代码无须额外的同步或其他协调动作。

### 对象的创建很简单

对象构造要做到线程安全，唯一的要求是在构造期间不要泄露this指针，即

- 不要在构造函数中注册任何回调；
- 也不要在构造函数中把this传给跨线程的对象；
- 即便在构造函数的最后一行也不行。

之所以这样规定，是因为在构造函数执行期间对象还没有完成初始化，如果this被泄露（escape）给了其他对象（其自身创建的子对象除外），那么别的线程有可能访问这个半成品对象，这会造成难以预料的后果。

如下的二段式构造是个好方法，

```c++
Foo* pFoo = new Foo;
Observalbe* s = getSubject();
pFoo->observe(s);
```

即使构造函数的最后一行也不要泄露this，因为Foo有可能是个基类，基类先于派生类构造，执行完Foo::Foo()的最后一行代码还会继续执行派生类的构造函数，这时most-derived class的对象还处于构造中，仍然不安全。

### 销毁太难

对象析构在单线程里不成问题，最多需要避免注意空悬指针和野指针

#### mutex数据成员不是办法

在析构函数中调用mutex加锁似乎是个不错的主意，但是当前线程调用析构函数完成前对象并没有释放，有可能另一个线程正准备读取这个对象了，另一个线程发现这个对象还在（因为析构函数没有结束），于是等待锁释放再读取，若此时原线程已经将对象销毁了，那么mutex也被销毁，而整等待锁释放的那个一个线程将发生无法预料的事情

作为class数据成员，mutex只能同步本class其他数据成员的读写，不能保证安全析构，因为mutex成员的生命期最多和对象一样长，而析构动作可以说是发生在对象身亡之时。

另外，对于基类对象，调用基类析构函数时，派生类对象的那部分已经析构了，所以基类对象拥有的mutex不能保护整个析构过程。

### shared_ptr/weak_ptr

原始指针经常会造成空悬指针的问题，**引入另外一层间接性（another layer of indirection）**，加入一个proxy指针，原始指针指向proxy指针，proxy指针指向Object，并且proxy还持有一个计数器，记录当前有多少个原始指针指向自己，这就是**引用计数型智能指针**。它用对象来管理共享资源（把Object看作资源），这是handle/body惯用技法（idiom）。

shared_ptr是引用计数型智能指针，在Boost和std::tr1里均提供，也被纳入C++11标准库，现代主流的C++编译器都能很好地支持。shared_ptr<T>是一个类模板（class template），它只有一个类型参数，使用起来很方便。引用计数是自动化资源管理的常用手法，当引用计数降为0时，对象（资源）即被销毁。weak_ptr也是一个引用计数型智能指针，但是它不增加对象的引用次数，即弱（weak）引用。

- shared_ptr控制对象的生命期。shared_ptr是强引用（想象成用铁丝绑住堆上的对象），只要有一个指向x对象的shared_ptr存在，该x对象就不会析构。当指向对象x的最后一个shared_ptr析构或reset()的时候，x保证会被销毁。
- weak_ptr不控制对象的生命期，但是它知道对象是否还活着（想象成用棉线轻轻拴住堆上的对象）。如果对象还活着，那么它可以提升（promote）为有效的shared_ptr；如果对象已经死了，提升会失败，返回一个空的shared_ptr。“提升／lock()”行为是线程安全的。
- shared_ptr/weak_ptr的“计数”在主流平台上是**原子操作**，**没有用锁**，性能不俗。
- shared_ptr/weak_ptr的线程安全级别与std::string和STL容器一样，后面还会讲。

shared_ptr/weak_ptr都是**值语意**，要么是栈上对象，或是其他对象的直接数据成员，或是标准库容器里的元素。几乎不会有下面这种用法：

```c++
shared_ptr<Foo>* pFoo = new shared_ptr<Foo>(new Foo); // WRONG semantic
```

### shared_ptr与观察者模式结合

这里的Observable有一个weak_ptr的vector，如果改为shared_ptr的vector，那么除非手动调用unregister()，否则Observer对象永远不会析构，

```c++
class Observer : public boost::enable_shared_from_this<Observer>
{
 public:
  virtual ~Observer();
  virtual void update() = 0;

  void observe(Observable* s);

 protected:
  Observable* subject_;
};

class Observable
{
 public:
  void register_(boost::weak_ptr<Observer> x);
  // void unregister(boost::weak_ptr<Observer> x); // 不需要它

  void notifyObservers()
  {
    muduo::MutexLockGuard lock(mutex_);
    Iterator it = observers_.begin();
    while (it != observers_.end())
    {
      boost::shared_ptr<Observer> obj(it->lock()); // 尝试提示，这一步是线程安全的
      if (obj)
      {
        // 提升成功，现在引用计数至少为2，提升成功就说明本来it所指对象就存在，至少为1，obj又计数了，所以至少为2
        obj->update(); // 没有竞态条件，因为obj在栈上，对象不可能在本作用域内销毁
        ++it;
      }
      else
      {
        // 对象已销毁，从容器中拿掉weak_ptr
        printf("notifyObservers() erase\n");
        it = observers_.erase(it);
      }
    }
  }

 private:
  mutable muduo::MutexLock mutex_;
  std::vector<boost::weak_ptr<Observer> > observers_;
  typedef std::vector<boost::weak_ptr<Observer> >::iterator Iterator;
};
```

### 再论shared_ptr的线程安全

虽然我们借shared_ptr来实现线程安全的对象释放，但是shared_ptr本身不是100％线程安全的。它的引用计数本身是安全且无锁的，但对象的读写则不是，因为shared_ptr有两个数据成员，读写操作不能原子化。根据文档 11 ，shared_ptr的线程安全级别和内建类型、标准库容器、std::string一样，即：

- 一个shared_ptr对象实体可被多个线程同时读取；
- 两个shared_ptr对象实体可以被两个线程同时写入，“析构”算写操作；
- 如果要从多个线程读写同一个shared_ptr对象，那么需要加锁。

请注意，以上是**shared_ptr对象本身的线程安全级别**，不是它管理的对象的线程安全级别。

在多个线程同时访问同一个shared_ptr，正确的做法使用mutex保护，注意，对于共享变量的读写，临界区越小越好。

如果要销毁对象，我们固然可以在临界区内执行globalPtr.reset()，但是这样往往会让对象析构发生在临界区以内，增加了临界区的长度。一种改进办法是定义一个localPtr，用它在临界区内与globalPtr交换（swap()），这样能保证把对象的销毁推迟到临界区之外

### 对象池

#### enable_shared_from_this

#### 弱回调（事件通知中非常有用）

如果对象还活着，就调用它的成员函数，否则忽略之

### 垃圾回收与并发编程

有垃圾回收就好办。Google的Go语言教程明确指出，没有垃圾回收的并发编程是困难的（Concurrency is hard without garbage collection）。但是由于指针算术的存在，在C/C++里实现全自动垃圾回收更加困难。而那些天生具备垃圾回收的语言在并发编程方面具有明显的优势，Java是目前支持并发编程最好的主流语言，它的util.concurrent库和内存模型是C++11效仿的对象。

## 第2章 线程同步精要

并发编程有两种基本模型，一种是message passing，另一种是shared memory。在分布式系统中，运行在多台机器上的多个进程的并行编程只有一种实用模型：message passing 1 。在单机上，我们也可以照搬message passing作为多个进程的并发模型。这样整个分布式系统的架构的一致性很强，扩容（scale out）起来也较容易。在多线程编程中，message passing更容易保证程序的正确性，有的语言只提供这一种模型。

本章多次借鉴《Real-World Concurrency》

线程同步的四项原则，按重要性排列：

1. 首要原则是尽量最低限度地共享对象，减少需要同步的场合。一个对象能不暴露给别的线程就不要暴露；如果要暴露，优先考虑immutable对象；实在不行才暴露可修改的对象，并用同步措施来充分保护它。
2. 其次是使用高级的并发编程构件，如TaskQueue、Producer-Consumer Queue、CountDownLatch等等。
3. 最后不得已必须使用底层同步原语（primitives）时，只用非递归的互斥器和条件变量，慎用读写锁，不要用信号量。
4. 除了使用atomic整数之外，不自己编写lock-free代码，也不要用“内核级”同步原语。不凭空猜测“哪种做法性能会更好”，比如spin lock vs. mutex。

### 互斥锁（Pthreads里的mutex）

互斥器（mutex）恐怕是使用得最多的同步原语，粗略地说，它保护了临界区，任何一个时刻最多只能有一个线程在此mutex划出的临界区内活动。单独使用mutex时，我们主要为了保护共享数据。我（陈硕）个人的原则是：

- 用RAII手法封装mutex的创建、销毁、加锁、解锁这四个操作。用RAII封装这几个操作是通行的做法，这几乎是C++的标准实践。
- 只用非递归的mutex（即不可重入的mutex）。
- 不手工调用lock()和unlock()函数，一切交给栈上的Guard对象的构造和析构函数负责。Guard对象的生命期正好等于临界区（分析对象在什么时候析构是C++程序员的基本功）。这样我们保证始终在同一个函数同一个scope里对某个mutex加锁和解锁。避免在foo()里加锁，然后跑到bar()里解锁；也避免在不同的语句分支中分别加锁、解锁。这种做法被称为Scoped Locking。
- 在每次构造Guard对象的时候，思考一路上（调用栈上）已经持有的锁，防止因加锁顺序不同而导致死锁（deadlock）。由于Guard对象是栈上对象，看函数调用栈就能分析用锁的情况，非常便利。

次要原则有：

- 不使用跨进程的mutex，进程间通信只用TCP sockets。
- 加锁、解锁在同一个线程，线程a不能去unlock线程b已经锁住的mutex（RAII自动保证）。
- 别忘了解锁（RAII自动保证）。
- 不重复解锁（RAII自动保证）。
- 必要的时候可以考虑用PTHREAD_MUTEX_ERRORCHECK来排错。

#### 只使用非递归的mutex

谈谈我坚持使用非递归的互斥器的个人想法。

mutex分为**递归（recursive）**和**非递归（non-recursive）**两种，这是POSIX的叫法，另外的名字是**可重入（reentrant）**与非可重入。这两种mutex作为线程间（inter-thread）的同步工具时没有区别，它们的唯一区别在于：同一个线程可以重复对recursive mutex加锁，**但是不能重复对non-recursive mutex加锁**。

首选非递归mutex，绝对不是为了性能，而是为了体现设计意图。non-recursive和recursive的性能差别其实不大，因为少用一个计数器，前者略快一点点而已。在同一个线程里多次对non-recursive mutex加锁会立刻导致死锁，我认为这是它的优点，能帮助我们思考代码对锁的期求，并且及早（在编码阶段）发现问题。非递归的mutex，产生死锁容易debug。

如果确实需要在遍历的时候修改vector，有两种做法，一是把修改推后，记住循环中试图添加或删除哪些元素，等循环结束了再依记录修改foos；二是用copy-on-write，见本章后面的例子。

如果一个函数既可能在已加锁的情况下调用，又可能在未加锁的情况下调用，那么就拆成两个函数（说实话，没理解为什么要这么做。。）：

1. 跟原来的函数同名，函数加锁，转而调用第2个函数。
2. 给函数名加上后缀WithLockHold，不加锁，把原来的函数体搬过来。

```c++
void post(const Foo& f){
    MutexLockGuard lock(mutex);
    postWithLockHold(f); // 不用担心开销，编译器会自动内联
}
void postWithLockHold(const Foo& f){ // 引入这个函数是为了体现代码作者的意图，尽管push_back
    foo.push_back(f);
}
```

#### 死锁

坚持只使用非迭代的mutex，线程自己与自己死锁的时候，很容易debug。

两个类之间也可能产生死锁，例子见recipes/thread/test/MutualDeadLock.cc

### 条件变量（与互斥锁结合使用，经典实现是blockingqueue与countdownlatch）

互斥器（mutex）是加锁原语，用来排他性地访问共享数据，它不是等待原语。在使用mutex的时候，我们一般都会期望加锁不要阻塞，总是能立刻拿到锁。然后尽快访问数据，用完之后尽快解锁，这样才能不影响并发性和性能。
如果需要等待某个条件成立，我们应该使用**条件变量（condition variable）**。条件变量顾名思义是一个或多个线程等待某个布尔表达式为真，即等待别的线程“唤醒”它。条件变量的学名叫**管程（monitor）**。条件变量只有一种正确使用的方式，几乎不可能用错。对于wait端：

1. 必须与mutex一起使用，该布尔表达式的读写需受此mutex保护。
2. 在mutex已上锁的时候才能调用wait()。
3. 把判断布尔条件和wait()放到while循环中。

写成代码是：

上面的代码中必须用while循环来等待条件变量，而不能用if语句，原因是**虚假唤醒（spurious wakeup）**。这也是面试多线程编程的常见考点。

对于signal/broadcast端：

1. 不一定要在mutex已上锁的情况下调用signal（理论上）。
2. 在signal之前一般要修改布尔表达式。
3. 修改布尔表达式通常要用mutex保护（至少用作full memory barrier）。
4. 注意区分signal与broadcast：“broadcast通常用于表明状态变化，signal通常用于表示资源可用。（broadcast should generally be used to indicate state change rather than resource availability。）“

阻塞队列实现于muduo/base/BlockingQueue.h

条件变量是非常底层的同步原语，很少直接使用，一般都是用它来实现高层的同步措施，如`BlockingQueue<T>`或CountDownLatch。
**倒计时（CountDownLatch）**是一种常用且易用的同步手段。它主要有两种用途：

- 主线程发起多个子线程，等这些子线程各自都完成一定的任务之后，主线程才继续执行。通常用于**主线程等待多个子线程完成初始化**。
- 主线程发起多个子线程，子线程都等待主线程，主线程完成其他一些任务之后通知所有子线程开始执行。通常用于**多个子线程等待主线程发出“起跑”命令**。

当然我们可以直接用条件变量来实现以上两种同步。不过如果用CountDownLatch的话，程序的逻辑更清晰。源码位于muduo/base/CountDownLatch.{h,cc}，接口如下：

```c++
class CountDownLatch : noncopyable
{
 public:
  explicit CountDownLatch(int count);   // 倒数几次
  void wait();                          // 等待计数值变0
  void countDown();                     // 计数-1
  int getCount() const;

 private:
  mutable MutexLock mutex_;
  Condition condition_ GUARDED_BY(mutex_);
  int count_ GUARDED_BY(mutex_);
};
```

它的实现几乎就是条件变量的教科书式应用：

```c++
void CountDownLatch::wait()
{
  MutexLockGuard lock(mutex_);
  while (count_ > 0)
  {
    condition_.wait();
  }
}

void CountDownLatch::countDown()
{
  MutexLockGuard lock(mutex_);
  --count_;
  if (count_ == 0)
  {
    condition_.notifyAll();
  }
}
```

### 不要用读写锁和信号量（陈硕的经验，本节的“我”都指陈硕）

**读写锁（Readers-Writer lock，简写为rwlock）**是个看上去很美的抽象，它明确区分了read和write两种行为。初学者常干的一件事情是，一见到某个共享数据结构频繁读而很少写，就把mutex替换为rwlock。甚至首选rwlock来保护共享状态，这不见得是正确的。

- 从正确性方面来说，一种典型的易犯错误是在持有read lock的时候修改了共享数据。这通常发生在程序的维护阶段，为了新增功能，程序员不小心在原来read lock保护的函数中调用了会修改状态的函数。这种错误的后果跟无保护并发读写共享数据是一样的。
- 从性能方面来说，读写锁不见得比普通mutex更高效。无论如何reader lock加锁的开销不会比mutex lock小，因为它要更新当前reader的数目。如果临界区很小，锁竞争不激烈，那么mutex往往会更快。见§1.9的例子。
- reader lock可能允许**提升（upgrade）**为writer lock，也可能不允许提升。考虑§2.1.1的post()和traverse()示例，如果用读写锁来保护foos对象，那么post()应该持有写锁，而traverse()应该持有读锁。如果允许把读锁提升为写锁，后果跟使用recursive mutex一样，会造成迭代器失效，程序崩溃。如果不允许提升，后果跟使用non-recursive mutex一样，会造成死锁。我宁愿程序死锁，留个“全尸”好查验。
- 通常reader lock是可重入的，writer lock是不可重入的。但是为了防止writer饥饿，writer lock通常会阻塞后来的reader lock，因此reader lock在重入的时候可能死锁。另外，在追求低延迟读取的场合也不适用读写锁

**信号量（Semaphore）**：我没有遇到过需要使用信号量的情况，无从谈及个人经验。我认为信号量不是必备的同步原语，因为条件变量配合互斥器可以完全替代其功能，而且更不易用错。除了[RWC]指出的“semaphore has no notion of ownership”之外，信号量的另一个问题在于它有自己的计数值，而通常我们自己的数据结构也有长度值，这就造成了同样的信息存了两份，需要时刻保持一致，这增加了程序员的负担和出错的可能。如果要控制并发度，可以考虑用muduo::ThreadPool。

说一句不知天高地厚的话，如果程序里需要解决如“哲学家就餐”之类的复杂IPC问题，我认为应该首先检讨这个设计：为什么线程之间会有如此复杂的资源争抢（一个线程要同时抢到两个资源，一个资源可以被两个线程争夺）？如果在工作中遇到，我会把“想吃饭”这个事情专门交给一个为各位哲学家分派餐具的线程来做，然后每个哲学家等在一个简单的condition variable上，到时间了有人通知他去吃饭。从哲学上说，教科书上的解决方案是平权，每个哲学家有自己的线程，自己去拿筷子；我宁愿用集权的方式，用一个线程专门管餐具的分配，让其他哲学家线程拿个号等在食堂门口好了。这样不损失多少效率，却让程序简单很多。

Pthreads还提供了barrier这个同步原语，我认为不如CountDownLatch实用。

### 封装MutexLock、MutexLockGuard、Condition

本节把前面用到的MutexLock、MutexLockGuard、Condition等class的代码列出来，前面两个class没多大难度，后面那个有点意思。这几个class都不允许拷贝构造和赋值。完整代码可以在muduo/base找到。

MutexLock和MutexLockGuard这两个class应该能在纸上默写出来，没有太多需要解释的。MutexLock的附加值在于提供了isLockedByThisThread()函数，用于程序断言。它用到的CurrentThread::tid()函数将在第4章介绍。

```c++
class MutexLock
{
public:
    MutexLock(): holder_(0){
        pthread_mutex_init(&mutex_, NULL);
    }
    ~MutexLock(){
        assert(holder_ == 0);
        pthread_mutex_destroy(&mutex_);
    }
    bool isLockedByThisThread(){
        return holder_ == CurrentThread::tid();
    }
    void assertLocked(){
        assert(isLockedByThisThread());
    }
    void lock(){        // 仅供MutexLockGuard调用，严禁用户代码调用
        pthread_mutex_lock(&mutex_);    // 这两行顺序不能反
        holder_ = CurrentThread::tid();
    }
    void unlock(){      // 仅供MutexLockGuard调用，严禁用户代码调用
        holder_ = 0;                   // 这两行顺序不能反
        pthread_mutex_unlock(&mutex_);
    }
    pthread_mutex_t* getPthreadMutex(){  // 仅供Condition调用，严禁用户代码调用
        return &mutex_;
    }
private:
    pthread_mutex_t mutex_;
    pid_t holder_;
};

class MutexLockGuard
{
public:
    explicit MutexLockGuard(MutexLock& mutex) : mutex_(mutex){
        mutex_.lock();
    }
    ~MutexLockGuard(){
        mutex_.unlock();
    }
private:
    MutexLock& mutex_;
};

#define MutexLockGuard(x) static_assert(false, "missing mutex guard var name")
```

最后的宏是为了防止程序出现以下错误：

```c++
void doit(){
    MutexLockGuard(mutex); // 遗漏变量名，产生一个临时对象又马上销毁了，结果没有锁住临界区
    // 正确写法如下：
    MutexLockGuard lock(mutex);
    // 临界区
}
```

下面的Condition class简单地封装了Pthreads condition variable

```c++
class Condition
{
public:
    explicit Condition(MutexLock& mutex) : mutex_(mutex){
        pthread_cond_init(*pcond_, NULL);
    }
    ~Condition() {
        pthread_cond_destroy(&pcond_);
    }
    void wait(){
        pthread_cond_wait(&pcond_, mutex_.getPthreadMutex());
    }
    void notify(){
        pthread_cond_signal(&pcond_);
    }
    void notifyAll(){
        pthread_cond_broadcast(&pcond_);
    }
private:
    MutexLock& mutex_;
    pthread_cond_t pcond_;
}
```

如果一个class要包含MutexLock和Condition，请注意它们的声明顺序和初始化顺序，mutex_应限于condition_构造，并作为后者的构造参数：

```c++
class CountDownLatch{
public:
    CountDownLatch(int count) : mutex_(), condition_(mutex_), count_(count) { } // 初始化顺序要与成员声明保持一致
private:
    mutable MutexLock mutex_; // 顺序很重要，先mutex后condition
    Condition condition_;
    int count_;
}
```

mutex和condition variable都是非常底层的同步原语，实际开发中最好使用基于它们的高级并发编程工具

### 线程安全的Singleton实现

人们一度认为double checked locking（DCL）是有效的，但是后来有人指出由于乱序执行的影响，DCL是靠不住的。

在实践中，用pthread_once就行，下面代码没有任何花哨的技巧，只是使用pthread_once来保证**lazy initialization**

```c++
template<typename T>
class Singleton : noncopyable
{
 public:
  Singleton() = delete;
  ~Singleton() = delete;

  static T& instance()
  {
    pthread_once(&ponce_, &Singleton::init);
    return *value_;
  }

 private:
  static void init()
  {
    value_ = new T();
    if (!detail::has_no_destroy<T>::value)
    {
      ::atexit(destroy);
    }
  }

 private:
  static pthread_once_t ponce_;
  static T*             value_;
};

template<typename T>
pthread_once_t Singleton<T>::ponce_ = PTHREAD_ONCE_INIT;

template<typename T>
T* Singleton<T>::value_ = NULL;
```

使用方法也很简单：

```c++
Foo& foo = Singleton<Foo>::instance();
```

### sleep(3)不是同步原语

我认为sleep()/usleep()/nanosleep()只能出现在测试代码中，比如写单元测试的时候；或者用于有意延长临界区，加速复现死锁的情况。sleep不具备memory barrier语义，它不能保证内存的可见性

生产代码中线程的等待可分为两种：一种是**等待资源可用**（要么等在select/poll/epoll_wait上，要么等在条件变量上，BlockingQueue和CountDownLatch也算条件变量）；一种是等着**进入临界区（等在mutex上）**以便读写共享数据。后一种等待通常极短，否则程序性能和伸缩性就会有问题。

在程序的正常执行中，如果需要等待一段已知的时间，应该往event loop里注册一个timer，然后在timer的回调函数里接着干活，因为线程是个珍贵的共享资源，不能轻易浪费（阻塞也是浪费）。如果等待某个事件发生，那么应该采用条件变量或IO事件回调，不能用sleep来轮询。**在用户态做轮询（polling）是低效的**。

### 借shared_ptr实现copy-on-write

那就是用shared_ptr来管理共享数据。原理如下：

- shared_ptr是引用计数型智能指针，如果当前只有一个观察者，那么引用计数的值为1 47 。
- 对于write端，如果发现引用计数为1，这时可以安全地修改共享对象，不必担心有人正在读它。
- 对于read端，在读之前把引用计数加1，读完之后减1，这样保证在读的期间其引用计数大于1，可以阻止并发写。
- 比较难的是，对于write端，如果发现引用计数大于1，该如何处理？sleep()一小段时间肯定是错的。

recipes/thread/test/CopyOnWrite_test.cc

在read端，用一个栈上局部FooListPtr变量当做“观察者”，它使得g_foos的引用计数增加(L6)。traverse()函数的临界区是L4～L8，临界区内只读了一次共享变量g_foos（这里多线程并发读写shared_ptr，因此必须用mutex保护），比原来的写法大为缩短。而且多个线程同时调用traverse()也不会相互阻塞。

```c++
void traverse()
{
  FooListPtr foos;
  {
    MutexLockGuard lock(mutex);
    foos = g_foos;
    assert(!g_foos.unique());
  }

  // assert(!foos.unique()); this may not hold

  for (std::vector<Foo>::const_iterator it = foos->begin();
      it != foos->end(); ++it)
  {
    it->doit();
  }
}
```

关键看write端的post()该如何写。按照前面的描述，如果g_foos.unique()为true，我们可以放心地在原地（in-place）修改FooList。如果g_foos.unique()为false，说明这时别的线程正在读取FooList，我们不能原地修改，而是复制一份（L23），在副本上修改（L27）。这样就避免了死锁。

```c++
void post(const Foo& f)
{
  printf("post\n");
  MutexLockGuard lock(mutex);
  if (!g_foos.unique())
  {
    g_foos.reset(new FooList(*g_foos));
    printf("copy the whole list\n");
  }
  assert(g_foos.unique());
  g_foos->push_back(f);
}
```

注意这里临界区包括整个函数（L20～L27），其他写法都是错的。读者可以试着运行这个程序，看看什么时候会打印L24的消息。

## 第3章 多线程服务器的适用场合与常用编程模型

本章主要讲我个人在多线程开发方面的一些粗浅经验。总结了一两种常用的线程模型，归纳了进程间通信与线程同步的最佳实践，以期用简单规范的方式开发功能正确、线程安全的多线程程序。本章假定读者已经有多线程编程的知识与经验（本书不是一篇入门教程）。

### 进程与线程

**进程（process）**是操作里最重要的两个概念之一（另一个是文件），粗略地讲，一个进程是“内存中正在运行的程序”。本书的进程指的是Linux操作系统通过fork()系统调用产生的那个东西，或者Windows下CreateProcess()的产物。

**每个进程有自己独立的地址空间（address space）**，“在同一个进程”还是“不在同一个进程”是系统功能划分的重要决策点。

**线程的特点是共享地址空间**，从而可以高效地共享数据。一台机器上的多个进程能高效地共享代码段（操作系统可以映射为同样的物理内存），但不能共享数据。如果多个进程大量共享内存，等于是把多进程程序当成多线程来写，掩耳盗铃。

### 单线程服务器的常用编程模型

适用的最广泛的估计是**非阻塞式I/O+I/O复用（non-blocking I/O + I/O multiplexing**，这也叫**Reactor模式**。

在“non-blocking IO＋IO multiplexing”这种模型中，程序的基本结构是一个**事件循环（event loop）**，以**事件驱动（event-driven）**和事件回调的方式实现业务逻辑：

```c++
while(!done){
    int timeout_ms = max(1000, getNextTimedCallback());
    int retval = ::poll(fds, nfds, timeout_ms);
    if(retval < 0){
        处理错误，回调用户的timer handler
    }
    else{
        处理到期的timers，回调用户的timer handler
        if(retval > 0){
            处理IO事件，回调用户的IO event handler
        }
    }
}
```

这里select(2)/poll(2)有伸缩性方面的不足，**Linux下可替换为epoll(4)**，其他操作系统也有对应的高性能替代品。

Reactor模型的优点很明显，编程不难，效率也不错。不仅可以用于读写socket，连接的建立（connect(2)/accept(2)）甚至DNS解析都可以用非阻塞方式进行，以提高并发度和吞吐量（throughput），对于IO密集的应用是个不错的选择。lighttpd就是这样，它内部的fdevent结构十分精妙，值得学习。

基于事件驱动的编程模型也有其本质的缺点，它要求事件回调函数必须是非阻塞的。对于涉及网络IO的请求响应式协议，它容易割裂业务逻辑，使其散布于多个回调函数之中，相对不容易理解和维护。现代的语言有一些应对方法（例如coroutine），但是本书只关注C++这种传统语言，因此就不展开讨论了。

### 多线程服务器的常用编程模型

1. **每个请求（现场）创建一个线程**，使用**阻塞式IO**操作。可惜伸缩性不佳。
2. 使用**线程池**，同样使用阻塞式IO操作。与第1种相比，这是提高性能的措施。
3. 使用**non-blocking IO＋IO multiplexing**。
4. Leader/Follower等高级模式。

在默认情况下，我会使用第3种，即non-blocking IO＋one loop per thread模式来编写多线程C++网络服务程序（Muduo就是这种模式）。

#### one loop per thread（不是thread per connection)

此种模型下，程序里的每个IO线程有一个event loop（或者叫Reactor），用于处理读写和定时事件（无论周期性的还是单次的），代码框架跟本章第二节的代码一样。

libev的作者说：

**One loop per thread is usually a good model.** Doing this is almost never wrong, sometimes a better-performance model exists, but it is always a good start.

这种方式的好处是：

- 线程数目基本固定，可以在程序启动的时候设置，不会频繁创建与销毁。
- 可以很方便地在线程间调配负载。
- IO事件发生的线程是固定的，同一个TCP连接不必考虑事件并发。

Eventloop代表了线程的主循环，需要让哪个线程干活，就把timer或IOchannel（如TCP连接）**注册到哪个线程的loop**里即可。对实时性有要求的connection可以单独用一个线程；数据量大的connection可以独占一个线程，并把数据处理任务分摊到另几个计算线程中（用线程池）；其他次要的辅助性connections可以共享一个线程。

对于non-trivial的服务端程序，一般会采用non-blocking IO＋IO multiplexing，每个connection/acceptor都会注册到某个event loop上，程序里有多个event loop，每个线程至多有一个event loop。
多线程程序对event loop提出了更高的要求，那就是“线程安全”。要允许一个线程往别的线程的loop里塞东西，这个loop必须得是线程安全的。如何实现一个优质的多线程Reactor？可参考第8章。

小结：thread per connection不适合高并发场合，其scalability不佳。one loop per thread的并发度足够大，且与CPU数目成正比。

#### 线程池

不过，对于没有IO而光有计算任务的线程，使用event loop有点浪费，我会用一种补充方案，即用blocking queue实现的任务队列（TaskQueue）：

```c++
typedef boost::function<void()> Functor;
BlockingQueue<Functor> taskQueue; // 线程安全的阻塞队列
void workerThread(){
    while(running) // running 是个全局变量
    {
        Functor task = taskQueue.take(); // this blocks
        task(); // 在产品代码中需要考虑异常处理
    }
}
```

用这种方式实现线程池特别容易，以下是启动容量（并发数）为N的线程池：

```c++
int N = num_of_computing_threads;
for(int i = 0; i < N; ++i){
    create_thread(&workerThread); // 伪代码，启动线程
}
```

使用起来也简单：

```c++
Foo foo; // Foo 有calc() 成员函数
boost::function<void()> task = boost::bind(&Foo:calc, &foo);
taskQueue.post(task);
```

上面十几行代码就实现了一个简单的固定数目的线程池，功能大概相当于Java中的ThreadPoolExecutor的某种“配置”。当然，在真实的项目中，这些代码都应该封装到一个class中，而不是使用全局对象。另外需要注意一点：Foo对象的生命期，第1章详细讨论了这个问题。
muduo的线程池比这个略复杂，因为要提供stop()操作。

除了任务队列，还可以用`BlockingQueue<T>`实现数据的生产者消费者队列，即T是数据类型而非函数对象，queue的消费者(s)从中拿到数据进行处理。

`BlockingQueue<T>`是多线程编程的利器，它的实现可参照Java util.concurrent里的(Array|Linked)BlockingQueue。这份Java代码可读性很高，代码的基本结构和教科书一致（1个mutex，2个condition variables），健壮性要高得多。如果不想自己实现，用现成的库更好。muduo里有一个基本的实现，包括无界的BlockingQueue和有界的BoundedBlockingQueue两个class。有兴趣的读者还可以试试Intel Threading Building Blocks里的`concurrent_queue<T>`，性能估计会更好。

#### 小结

总结起来，我推荐的C++多线程服务端编程模式为：one (event) loop per thread+ thread pool。

- event loop（也叫IO loop）用作IO multiplexing，配合non-blocking IO和定时器。
- thread pool用来做计算，具体可以是任务队列或生产者消费者队列。
以这种方式写服务器程序，需要一个优质的基于Reactor模式的网络库来支撑，muduo正是这样的网络库。

程序里具体用几个loop、线程池的大小等参数需要根据应用来设定，基本的原则是“阻抗匹配”，使得CPU和IO都能高效地运作，具体的例子见此处 。
此外，程序里或许还有个别执行特殊任务的线程，比如logging，这对应用程序来说基本是不可见的，但是在分配资源（CPU和IO）的时候要算进去，以免高估了系统的容量。

### 进程间通信只用TCP

Linux下进程间通信（IPC）的方式数不胜数，光[UNPv2]列出的就有：匿名管道（pipe）、具名管道（FIFO）、POSIX消息队列、共享内存、信号（signals）等等，更不必说Sockets了。同步原语（synchronization primitives）也很多，如互斥器（mutex）、条件变量（condition variable）、读写锁（reader-writer lock）、文件锁（record locking）、信号量（semaphore）等等。

如何选择呢？根据我的个人经验，贵精不贵多，认真挑选三四样东西就能完全满足我的工作需要，而且每样我都能用得很熟，不容易犯错。

**进程间通信我首选Sockets**（主要指TCP，我没有用过UDP，也不考虑Unix domain协议），其最大的好处在于：可以跨主机，具有伸缩性。反正都是多进程了，如果一台机器的处理能力不够，很自然地就能用多台机器来处理。把进程分散到同一局域网的多台机器上，程序改改host:port配置就能继续用。相反，前面列出的其他IPC都不能跨机器，这就限制了scalability。

在编程上，**TCP sockets和pipe都是操作文件描述符，用来收发字节流，都可以read/write/fcntl/select/poll等**。不同的是，**TCP是双向的，Linux的pipe是单向的**，进程间双向通信还得开两个文件描述符，不方便；**而且进程要有父子关系才能用pipe**，这些都限制了pipe的使用。在收发字节流这一通信模型下，没有比Sockets/TCP更自然的IPC了。当然，pipe也有一个经典应用场景，那就是写Reactor/event loop时用来异步唤醒select（或等价的poll/epoll_wait）调用，Sun HotSpot JVM在Linux就是这么做的。

TCP port由一个进程独占，**且操作系统会自动回收**（listening port和已建立连接的TCP socket都是文件描述符，在进程结束时操作系统会关闭所有文件描述符）。这说明，即使程序意外退出，也不会给系统留下垃圾，程序重启之后能比较容易地恢复，而不需要重启操作系统（用跨进程的mutex就有这个风险）。还有一个好处，既然port是独占的，那么可以防止程序重复启动，后面那个进程抢不到port，自然就没法初始化了，避免造成意料之外的结果。

两个进程通过TCP通信，如果一个崩溃了，操作系统会关闭连接，**另一个进程几乎立刻就能感知**，可以快速failover。当然应用层的心跳也是必不可少的（§9.3）。

与其他IPC相比，TCP协议的一个天生的好处是“**可记录、可重现**”。tcpdump和Wireshark是解决两个进程间协议和状态争端的好帮手，也是性能（吞吐量、延迟）分析的利器。我们可以借此编写分布式程序的自动化回归测试。也可以用tcpcopy之类的工具进行压力测试。TCP还能跨语言，服务端和客户端不必使用同一种语言。试想如果用共享内存作为IPC，C++程序如何与Java通信，难道用JNI吗？

另外，如果网络库带“连接重试”功能的话，我们可以不要求系统里的进程以特定的顺序启动，任何一个进程都能单独重启。换句话说，**TCP连接是可再生的**，连接的任何一方都可以退出再启动，重建连接之后就能继续工作，这对开发牢靠的分布式系统意义重大。

### 多线程服务器的适用场合

开发服务端程序的一个基本任务是处理并发连接，现在服务端网络编程处理并发连接主要有两种方式：

- 当“线程”很廉价时，一台机器上可以创建远高于CPU数目的“线程”。这时一个线程只处理一个TCP连接（甚至半个），通常使用阻塞IO（至少看起来如此）。例如，Python gevent、Go goroutine、Erlang actor。这里的“线程”由语言的runtime自行调度，与操作系统线程不是一回事。
- 当线程很宝贵时，一台机器上只能创建与CPU数目相当的线程。这时**一个线程要处理多个TCP连接上的IO**，通常使用**非阻塞IO和IO multiplexing**。例如，libevent、muduo、Netty。这是原生线程，能被操作系统的任务调度器看见。

对于一台多核服务器，可用的**模式（model）**有

1. 运行一个单线程的进程：**不可伸缩的（scalable）**，不能发挥多核机器的计算能力。
2. 运行一个多线程的进程；
3. 运行多个单线程的进程；
   1. 简单地把模式1中的进程运行多份
   2. 主进程+woker进程，如果必须绑定到一个TCP port，比如httpd+fastcgi
4. 运行多个多线程的进程：千夫所指，它不但没有结合2和3的优点，反而汇聚了二者的缺点

什么时候一个服务器程序应该是多线程的？

如果线程启动和销毁的时间远远小于实际任务的耗时，那么多线程是有益的。如果每次启动线程相比比较耗时，不如直接在当前线程搞定，也可以用一个线程池，把工作任务交给线程池，避免阻塞当前线程（特别要避免阻塞IO线程）

#### 必须用单线程的场合

有两种场合必须使用单线程：

1. 程序可能会fork(2)；
2. 限制程序的CPU占用率。

#### 使用多线程程序的场景

我认为多线程的适用场景是：提高响应速度，让IO和“计算”相互重叠，降低latency。虽然多线程不能提高绝对性能，但能提高平均响应性能。

#### 线程的分类

据我的经验，一个多线程服务程序中的线程大致可分为3类：

1. **IO线程**，这类线程的主循环是IO multiplexing，阻塞地等在select/poll/epoll_wait系统调用上。这类线程也处理定时事件。当然它的功能不止IO，有些简单计算也可以放入其中，比如消息的编码或解码。
2. **计算线程**，这类线程的主循环是blockingqueue，阻塞地等在conditionvariable上。这类线程一般位于thread pool中。这种线程通常不涉及IO，一般要避免任何阻塞操作。
3. **第三方库所用的线程**，比如logging，又比如database connection。

服务器程序一般不会频繁地启动和终止线程。甚至，在我写过的程序里，create thread只在程序启动时调用，在服务运行期间是不可调用的

#### 什么是线程池大小的阻抗匹配原则

如果池中线程在执行任务时，密集计算所占的时间比重为P（0＜P≤1），而系统一共有C个CPU，为了让这C个CPU跑满而又不过载，线程池大小的经验公式T＝C/P。T是个hint，考虑到P值的估计不是很准确，T的最佳值可以上下浮动50％.这个经验公式的原理很简单，T个线程，每个线程占用P的CPU时间，如果刚好占满C个CPU，那么必有T×P＝C。下面验证一下边界条件的正确性。

假设C＝8，P＝1.0，线程池的任务完全是密集计算，那么T＝8。只要8个活动线程就能让8个CPU饱和，再多也没用，因为CPU资源已经耗光了。

假设C＝8，P＝0.5，线程池的任务有一半是计算，有一半等在IO上，那么T＝16。考虑操作系统能灵活、合理地调度sleeping/writing/running线程，那么大概16个“50％繁忙的线程”能让8个CPU忙个不停。启动更多的线程并不能提高吞吐量，反而因为增加上下文切换的开销而降低性能。

如果P＜0.2，这个公式就不适用了，T可以取一个固定值，比如5×C。另外，公式里的C不一定是CPU总数，可以是“分配给这项任务的CPU数目”，比如在8核机器上分出4个核来做一项任务，那么C＝4。

#### proactor多线程编程模型

Proactor。如果一次请求响应中要和别的进程打多次交道，那么Proactor模型往往能做到更高的并发度。当然，代价是代码变得支离破碎，难以理解。

Proactor能提高吞吐，但不能降低延迟，所以我没有深入研究。另外，在没有语言直接支持的情况下，Proactor模式让代码非常破碎，在C++中使用Proactor是很痛苦的。因此最好在“线程”很廉价的语言中使用这种方式，这时runtime往往会屏蔽细节，程序用单线程阻塞IO的方式来处理TCP连接。

#### 一个多线程的进程和多个单线程的进程如何取舍

我认为，在其他条件相同的情况下，可以根据工作集（work set）的大小来取舍。工作集是指服务程序响应一次请求所访问的内存大小。

如果工作集较大，那么就用多线程，避免CPU cache换入换出，影响性能；否则，就用单线程多进程，享受单线程编程的便利。

## 第4章 C++多线程系统编程精要

学习多线程编程面临的最大的思维方式的转变有两点：

- 当前线程可能随时会被切换出去，或者说被抢占（preempt）了。
- 多线程程序中事件的发生顺序不再有全局统一的先后关系

当线程被切换回来继续执行下一条语句（指令）的时候，全局数据（包括当前进程在操作系统内核中的状态）可能已经被其他线程修改了。例如，在没有为指针p加锁的情况下，if (p && p->next) { /* ... */ }有可能导致segfault，因为在逻辑与 （&&）的前一个分支evaluate为true之后的一刹那，p可能被其他线程置为NULL或是被释放，后一个分支就访问了非法地址。

多线程程序的正确性不能依赖于任何一个线程的执行速度，**不能通过原地等待（sleep()）来假定其他线程的事件已经发生**，而必须通过**适当的同步**来让当前线程能看到其他线程的事件的结果。无论线程执行得快与慢（被操作系统切换出去得越多，执行越慢），程序都应该能正常工作。

### 基本线程原语的选用

POSIX threads函数由上百个，但常用的只有十几个，而且在C++程序中通常会有更易用的wrapper，而不会直接调用Pthreads函数。这11个最基本的Pthreads函数是：

2个：线程的创建和等待结束（join）。封装为muduo::Thread。

4个：mutex的创建、销毁、加锁、解锁。封装为muduo::MutexLock。

5个：条件变量的创建、销毁、等待、通知、广播。封装为muduo::Condition。

这些封装class都很直截了当，加起来也就一两百行代码，却已经构成了多线程编程的全部必备原语。**用这三样东西（thread、mutex、condition）可以完成任何多线程编程任务**。当然我们一般也不会直接使用它们（mutex除外），而是使用更高层的封装，例如mutex::ThreadPool和mutex::CountDownLatch等，见第2章。

除此之外，Pthreads还提供了其他一些原语，有些是可以酌情使用的，有些则是不推荐使用的。可以酌情使用的有：

- pthread_once，封装为`muduo::Singleton<T>`。其实不如直接用全局变量。
- pthread_key*，封装为`muduo::ThreadLocal<T>`。可以考虑用__thread替换之。不建议使用：
- pthread_rwlock，读写锁通常应慎用。muduo没有封装读写锁，这是有意的
- sem_*，避免用信号量（semaphore）。它的功能与条件变量重合，但容易用错。
- pthread_{cancel, kill}。程序中出现了它们，则通常意味着设计出了问题。

不推荐使用读写锁的原因是它往往造成提高性能的错觉（允许多个线程并发读），实际上在很多情况下，与使用最简单的mutex相比，它实际上降低了性能。另外，写操作会阻塞读操作，如果要求优化读操作的延迟，用读写锁是不合适的。

**多线程系统编程的难点不在于学习线程原语（primitives），而在于理解多线程与现有的C/C++库函数和系统调用的交互关系，以进一步学习如何设计并实现线程安全且高效的程序。**

### C/C++系统库的线程安全性

之前的标准没有涉及线程，C++11定义了一个线程库std::thread。

对于标准而言，关键的不是定义线程库，而是规定**内存模型（memory model）**。特别是规定一个线程对某个共享变量的修改何时能被其他线程看到，这称为**内存序（memory ordering）**或者**内存能见度（memory visibility）**

### Linux上的线程标识(不用pthread_self函数而用gettid函数)

POSIX threads库提供了**pthread_self函数用于返回当前进程的标识符**，其类型为pthread_t。**pthread_t不一定是一个数值类型（整数或指针），也有可能是一个结构体**，因此Pthreads专门提供了pthread_equal函数用于对比两个线程标识符是否相等。这就带来一系列问题，包括：

- 无法打印输出pthread_t，因为不知道其确切类型。也就没法在日志中用它表示当前线程的id。
- 无法比较pthread_t的大小或计算其hash值，因此无法用作关联容器的key。
- 无法定义一个非法的pthread_t值，用来表示绝对不可能存在的线程id，因此MutexLock class没有办法有效判断当前线程是否已经持有本锁。
- pthread_t值只在进程内有意义，与操作系统的任务调度之间无法建立有效关联。比方说在/proc文件系统中找不到pthread_t对应的task。

Pthreads只保证**同一进程之内，同一时刻的各个线程的id不同**；不能保证同一进程先后多个线程具有不同的id，更不要说一台机器上多个进程之间的id唯一性了。

因此，**pthread_t并不适合用作程序中对线程的标识符**。
在Linux上，我建议使用**gettid(2)系统调用的返回值作为线程id**，这么做的好处有：

- 它的类型是pid_t，其值通常是一个小整数，便于在日志中输出。
- 在现代Linux中，它直接表示内核的任务调度id，因此在/proc文件系统中可以轻易找到对应项：/proc/tid或/prod/pid/task/tid。
- 在其他系统工具中也容易定位到具体某一个线程，例如在top(1)中我们可以按线程列出任务，然后找出CPU使用率最高的线程id，再根据程序日志判断到底哪一个线程在耗用CPU。
- 任何时刻都是全局唯一的，并且由于Linux分配新pid采用递增轮回办法，短时间内启动的多个线程也会具有不同的线程id。
- 0是非法值，因为操作系统第一个进程init的pid是1。

在glibc中并未提供gettid接口的声明，使用者需要自行使用syscall来调用该此函数。

```c++
#include <sys/syscall.h>
printf("main loop thread id: %ld\n", syscall(SYS_gettid));
// 也可以创建包裹函数来方便调用
pid_t gettid() { return syscall(SYS_gettid); }
```

每一次执行一次系统调用（内核态用户态的切换）似乎有些浪费，可以用缓存。muduo::CurrentThread::tid()采取的办法是用__thread变量来缓存gettid(2)的返回值，这样只有在本线程第一次调用的时候才进行系统调用，以后都是直接从thread local缓存的线程id拿到结果 14 ，效率无忧。多线程程序在打日志的时候可以在每一条日志消息中包含当前线程的id，不必担心有效率损失。

### 线程的创建于销毁的守则

线程的创建和销毁是编写多线程程序的基本要素，线程的创建比销毁要容易得多，只需要遵循几条简单的原则：

- 程序库不应该在未提前告知的情况下创建自己的“背景线程”：线程是稀缺资源，如果程序有不止一个线程，就很难安全地fork了
- 尽量用相同的方式创建线程（例如muduo::Thread）：可以做统一的**簿记（bookkeeping）**工作
- 在进入main()函数之前不应该启动线程：因为这会影响全局对象的安全构造
- 程序中线程的创建最好能在初始化阶段全部完成。

线程的销毁有几种方式：

- 自然死亡(唯一一种正常方式）。从线程主函数返回，线程正常退出。
- 非正常死亡。从线程主函数抛出异常或线程触发segfault信号等非法操作
- 自杀。在线程中调用pthread_exit()来立刻退出线程。
- 他杀。其他线程调用pthread_cancel()来强制终止某个线程。
pthread_kill()是往线程发信号，留到§4.10再讨论。

exit(3)在C++不是线程安全的，除了终止进程，还会析构全局对象和已经构造完的函数静态对象。这有潜在的死锁可能，考虑下面这个例子。

```c++
void someFunctionMayCallExit(){
    exit(1);
}
class GlobalObject{
public:
    void doit(){
        MutexLockGuard lock(mutex_);
        someFunctionMayCallExit();
    }
    ~GlobalObject(){
        printf("GlobalObject:~GlobalObject\n");
        MutexLockGuard lock(mutex_); // 此处发生死锁
    }
private:
    MutexLock mutex_;
};
GlobalObject g_obj;
int mian(){
    g_obj.doit();
}
```

GlobalObject::doit()函数辗转调用了exit()，从而触发了全局对象g_obj的析构。GlobalObject的析构函数会试图加锁mutex_，而此时mutex_已经被GlobalObject::doit()锁住了，于是造成了死锁。

C++标准没有照顾全局对象在多线程环境下的析构，据我看似乎也没有更好的办法。在编写长期运行的多线程服务程序的时候，可以不必追求安全地退出，而是让进程进入拒绝服务状态，然后就可以直接杀掉了

### 善用__thread关键字

__thread是GCC内置的**线程局部存储设施（thread local storage）**。它的实现非常高效，比pthread_key_t快很多

**只能用于修饰POD类型**，不能修饰class类型，因为无法自动调用构造函数和析构函数。__thread可以**用于修饰全局变量、函数内的静态变量**，但是不能用于修饰函数的局部变量或者class的普通成员变量。另外，__thread变量的初始化只能用编译期常量

**__thread变量是每个线程有一份独立实体**，各个线程的变量值互不干扰。除了这个主要用途，它还可以修饰那些“值可能会变，带有全局性，但是又不值得用全局锁保护”的变量

### 多线程与IO（建议每个文件描述符仅由一个线程操作）

在进行多线程网络编程的时候，几个自然的问题是：如何处理IO？能否多个线程同时读写同一个socket文件描述符 28 ？我们知道用多线程同时处理多个socket通常可以提高效率，那么用多线程处理同一个socket也可以提高效率吗？

首先，操作文件描述符的系统调用本身是线程安全的，我们不用担心多个线程同时操作文件描述符会造成进程崩溃或内核崩溃。

但是，多个线程同时操作同一个socket文件描述符确实很麻烦，我认为是得不偿失的。需要考虑的情况如下：

- 如果一个线程正在阻塞地read(2)某个socket，而另一个线程close(2)了此socket。
- 如果一个线程正在阻塞地accept(2)某个listening socket，而另一个线程close(2)了此socket。
- 更糟糕的是，一个线程正准备read(2)某个socket，而另一个线程close(2)了此socket；第三个线程又恰好open(2)了另一个文件描述，其fd号码正好与前面的socket相同，这样程序逻辑就混乱了。

我认为以上这几种情况都反映了程序逻辑设计上有问题。
现在假设不考虑关闭文件描述符，只考虑读和写，情况也不见得多好。因为socket读写的特点是不保证完整性，读100字节有可能只返回20字节，写操作也是一样的。

- 如果两个线程同时read同一个TCP socket，两个线程几乎同时各自收到一部分数据，如何把数据拼成完整的消息？如何知道哪部分数据先到达？
- 如果两个线程同时write同一个TCP socket，每个线程都只发出去半条消息，那接收方收到数据如何处理？
- 如果给每个TCP socket配一把锁，让同时只能有一个线程读或写此socket，似乎可以“解决”问题，但这样还不如直接始终让同一个线程来操作此socket来得简单。
- 对于非阻塞IO，情况是一样的，而且收发消息的完整性与原子性几乎不可能用锁来保证，因为这样会阻塞其他IO线程。

如此看来，理论上只有read和write可以分到两个线程去，因为TCP socket是双向IO。问题是真的值得把read和write拆开成两个线程吗？
以上讨论的都是网络IO，那么多线程可以加速磁盘IO吗？首先要避免lseek(2)/ read(2)的race condition（§4.2）。做到这一点之后，据我看，用多个线程read或write同一个文件也不会提速。不仅如此，多个线程分别read或write同一个磁盘上的多个文件也不见得能提速。因为每块磁盘都有一个操作队列，多个线程的读写请求到了内核是排队执行的。只有在内核缓存了大部分数据的情况下，多线程读这些热数据才可能比单线程快。多线程磁盘IO的一个思路是每个磁盘配一个线程，把所有针对此磁盘的IO都挪到同一个线程，这样或许能避免或减少内核中的锁争用。我认为应该用“显然是正确”的方式来编写程序，一个文件只由一个进程中的一个线程来读写，这种做法显然是正确的。

为了简单起见，我认为多线程程序应该遵循的原则是：**每个文件描述符只由一个线程操作**，从而轻松解决消息收发的顺序性问题，也避免了关闭文件描述符的各种race condition。一个线程可以操作多个文件描述符，但一个线程不能操作别的线程拥有的文件描述符。这一点不难做到，muduo网络库已经把这些细节封装了。

epoll也遵循相同的原则。Linux文档并没有说明：当一个线程正阻塞在epoll_ wait()上时，另一个线程往此epoll fd添加一个新的监视fd会发生什么。新fd上的事件会不会在此次epoll_wait()调用中返回？为了稳妥起见，我们应该把对同一个epoll fd的操作（添加、删除、修改、等待）都放到同一个线程中执行，这正是我们需要[…]

epoll也遵循相同的原则。Linux文档并没有说明：当一个线程正阻塞在epoll_ wait()上时，另一个线程往此epoll fd添加一个新的监视fd会发生什么。新fd上的事件会不会在此次epoll_wait()调用中返回？为了稳妥起见，我们应该把对同一个epoll fd的操作（添加、删除、修改、等待）都放到同一个线程中执行，这正是我们需要muduo::EventLoop::wakeup()的原因。

当然，一般的程序不会直接使用epoll、read、write，这些底层操作都由网络库代劳了。

这条规则有两个例外：对于磁盘文件，在必要的时候多个线程可以同时调用pread(2)/pwrite(2)来读写同一个文件；**对于UDP**，由于协议本身保证消息的原子性，在适当的条件下（比如消息之间彼此独立）可以多个线程同时读写同一个UDP文件描述符。

### 用RAII包装文件描述符

本节谈一谈在多线程程序中如何管理文件描述符。Linux的**文件描述符（file descriptor）**是小整数，在程序刚刚启动的时候，**0是标准输入，1是标准输出，2是标准错误**。这时如果我们新打开一个文件，它的文件描述符会是3，因为POSIX标准要求每次新打开文件（含socket）的时候必须使用当前最小可用的文件描述符号码。

POSIX这种分配文件描述符的方式稍不注意就会造成**串话**。比如前面举过的例子，一个线程正准备read(2)某个socket，而第二个线程几乎同时close(2)了此socket；第三个线程又恰好open(2)了另一个文件描述符，其号码正好与前面的socket相同（因为比它小的号码都被占用了）。这时第一个线程可能会读到不属于它的数据，不仅如此，还把第三个线程的功能也破坏了，因为第一个线程把数据读走了（TCP连接的数据只能读一次，磁盘文件会移动当前位置）。另外一种情况，一个线程从fd＝8收到了比较耗时的请求，它开始处理这个请求，并记住要把响应结果发给fd＝8。但是在处理过程中，fd＝8断开连接，被关闭了，又有新的连接到来，碰巧使用了相同的fd＝8。当线程完成响应的计算，把结果发给fd＝8时，接收方已经物是人非，后果难以预料。

在单线程程序中，或许可以通过某种全局表来避免串话；在多线程程序中，我不认为这种做法会是高效的（通常意味着每次读写都要对全局表加锁）。
在C++里解决这个问题的办法很简单：RAII。用Socket对象包装文件描述符，所有对此文件描述符的读写操作都通过此对象进行，在对象的析构函数里关闭文件描述符。这样一来，只要Socket对象还活着，就不会有其他Socket对象跟它有一样的文件描述符，也就不可能串话。

为了应对这种情况，防止访问失效的对象或者发生网络串话，muduo使用shared_ptr来管理TcpConnection的生命期。这是唯一一个采用引用计数方式管理生命期的对象。如果不用shared_ptr，我想不出其他安全且高效的办法来管理多线程网络服务端程序中的并发连接。

### RAII与fork()(子进程没法继承某些资源，所以无法正常工作)

假如程序fork()，资源管理就变难了，fork()之后，子进程继承了父进程的几乎全部状态，如地址空间与文件描述符，但也有少数例外，子进程不会继承：

- 父进程的内存锁，mlock(2)、mlockall(2)。
- 父进程的文件锁，fcntl(2)。
- 父进程的某些定时器，setitimer(2)、alarm(2)、timer_create(2)等等。
- 其他，见man 2 fork。

通常我们会用RAII手法来管理以上种类的资源（加锁解锁、创建销毁定时器等等），但是在fork()出来的子进程中不一定正常工作，**因为资源在fork()时已经被释放了**。

### 多线程与fork()（建议别在多线程里面fork）

多线程与fork()的协作性很差。这是POSIX系列操作系统的历史包袱。因为长期以来程序都是单线程的，fork()运转正常。当20世纪90年代初期引入多线程之后，fork()的适用范围大为缩减。

fork()一般不能在多线程程序中调用 ，因为Linux的fork()只克隆当前线程的thread of control，不克隆其他线程。fork()之后，除了当前线程之外，其他线程都消失了。也就是说不能一下子fork()出一个和父进程一样的多线程子进程。

fork()之后子进程中只有一个线程，其他线程都消失了，这就造成一个危险的局面。其他线程可能正好位于临界区之内，持有了某个锁，而它突然死亡，再也没有机会去解锁了。如果子进程试图再对同一个mutex加锁，就会立刻死锁。

唯一安全的做法是在fork()之后立即调用exec()执行另一个程序，彻底隔断子进程与父进程的联系。

### 多线程与signal（多线程中不要用signal）

Linux/Unix的信号（signal）与多线程可谓是**水火不容**。在单线程时代，编写信号处理函数（signal handler）就是一件棘手的事情，

在多线程程序中，使用signal的第一原则是不要使用signal。包括

- 不要用signal作为IPC的手段，包括不要用SIGUSR1等信号来触发服务端的行为。
- 也不要使用基于signal实现的定时函数，包括alarm/ualarm/setitimer/timer_create、sleep/usleep等等。
- 不主动处理各种异常信号（SIGTERM、SIGINT等等），只用默认语义：结束进程。有一个例外：SIGPIPE，服务器程序通常的做法是忽略此信号，否则如果对方断开连接，而本机继续write的话，会导致程序意外终止。
- 在没有别的替代方法的情况下（比方说需要处理SIGCHLD信号），把异步信号转换为同步的文件描述符事件。传统的做法是在signal handler里往一个特定的pipe(2)写一个字节，在主程序中从这个pipe读取，从而纳入统一的IO事件处理框架中去。现代Linux的做法是采用signalfd(2)把信号直接转换为文件描述符事件，从而从根本上避免使用signal handler。

### 第5章 高效的多线程日志

- 诊断日志（diagnostic log） 　即log4j、logback、slf4j、glog、g2log、log4cxx、log4cpp、log4cplus、Pantheios、ezlogger等常用日志库提供的日志功能。文本的，供人阅读的，通常**用于故障诊断和追踪（trace）**，也可用于性能分析，本章主要讨论这个。

- 交易日志（transaction log） 　即数据库的write-ahead log、文件系统的journaling等，用于**记录状态变更**，通过回放日志可以逐步恢复每一次修改之后的状态。

在服务端编程中，日志是必不可少的，在生产环境中应该做到“Log Everything All The Time”。对于关键进程，日志通常要记录

1. 收到的每条内部消息的id（还可以包括关键字段、长度、hash等）；
2. 收到的每条外部消息的全文；
3. 发出的每条消息的全文，每条消息都有全局唯一的id；
4. 关键内部状态的变更，等等。

每条日志都有时间戳，这样就能完整追踪分布式系统中一个事件的来龙去脉。也只有这样才能查清楚发生故障时究竟发生了什么，比如业务处理流程卡在了哪一步。

诊断日志不光是给程序员看的，更多的时候是给运维人员看的，因此日志的内容应避免造成误解，不要误导调查故障的主攻方向，拖延故障解决的时间。

一个日志库大体可分为前端（frontend）和后端（backend）两部分。前端是供应用程序使用的接口（API），并生成日志消息（log message）；后端则负责把日志消息写到目的地（destination）。这两部分的接口有可能简单到只有一个回调函数：`void output(const char* message, int len);`。其中的message字符串是一条完整的日志消息，包含**日志级别、时间戳、源文件位置、线程id**等基本字段，以及程序输出的具体消息内容。

前端位于muduo/base/Logging.{h,cc}，后端位于muduo/base/LogFile.{h,cc}

在多线程程序中，前端和后端都与单线程程序无甚区别，无非是**每个线程有自己的前端，整个程序共用一个后端**。但难点在于将日志数据从多个前端高效地传输到后端。这是一个典型的**多生产者-单消费者**问题，对生产者（前端）而言，要尽量做到低延迟、低CPU开销、无阻塞；对消费者（后端）而言，要做到足够大的吞吐量，并占用较少资源。

对C++程序而言，最好整个程序（包括主程序和程序库）都使用相同的日志库，程序有一个整体的日志输出，而不要各个组件有各自的日志输出。从这个意义上讲，日志库是个singleton。
C++日志库的前端大体上有两种API风格：

```c++
// C/Java的printf(fmt, ...)风格，例如
log_info("Received %d bytes from %s", len, getClientName().c_str());
// C++的stream <<风格，例如
LOG_INFO << "Received " << len << " bytes from " << getClientName();
```

muduo日志库是C++ stream风格，这样用起来更自然，不必费心保持格式字符串与参数类型的一致性，可以随用随写，而且是类型安全的。

stream风格的另一个好处是当输出的日志级别高于语句的日志级别时，打印日志是个空操作，运行时开销接近零。比方说当日志级别为WARNING时，LOG_INFO <<是空操作，这个uuju根本不会调用std::string getClientName()函数，减小了开销，而printf风格不易做到这一点

muduo没有用标准库中的iostream，而是自己写的LogStream class，位于muduo/base/LogStream.{h,cc}，这主要是出于性能原因

### 功能需求

最重要的功能是**日志消息有多种级别（level）**，如TRACE、DEBUG、INFO、WARN、ERROR、FATAL等，并且在运行时可以调整，如在测试环境输出DEBUG级别的日志，在生产环境输出INFO级别的日志。并且还可可以临时在线调整，如某台机器消息量过大，磁盘空间紧张，可以临时调整为WARNING，减少日志数目。又比如某个新上线的进程行为略显古怪，可以临时调整为DEBUG级别输出，打印更细节的日志消息以便分析

对于分布式系统中的服务进程而言，日志的**目的地（destination）**只有一个：**本地文件**。往网络写日志消息是不靠谱的，因为诊断日志的功能之一正是诊断网络故障。

日志文件的**滚动（rolling）**是必需的，这样可以简化日志**归档（archive）**的实现。rolling的条件通常有两个：**文件大小**（例如每写满1GB就换下一个文件）和**时间**（例如每天零点新建一个日志文件，不论前一个文件有没有写满）。muduo日志库的LogFile会自动根据文件大小和时间来主动滚动日志文件。

一个典型的日志文件：`logfile_test.2012060-144022.hostname.3605.log`，由以下几部分组成

- 第1部分logfile_test是进程的名字。通常是main()函数参数中argv[0]的basename(3)，这样容易区分究竟是哪个服务程序的日志。必要时还可以把程序版本加进去。
- 第2部分是文件的创建时间（GMT时区）。这样很容易通过文件名来选择某一时间范围内的日志，例如用通配符`*.20120603-14*`表示2012年6月3日下午2点（GMT）左右的日志文件(s)。
- 第3部分是机器名称。这样即便把日志文件拷贝到别的机器上也能追溯其来源。
- 第4部分是进程id。如果一个程序一秒之内反复重启，那么每次都会生成不同的日志文件。
- 第5部分是统一的后缀名.log。同样是为了便于周边配套脚本的编写。

muduo的日志文件滚动没有采用文件改名的办法，即`dmesg.log`是最新日志，`dmesg.log.1`是前一个日志，`dmesg.log.2.gz`是更早的日志等。这种做法的一个好处是`dmesg.log`始终是最新日志，便于编写某些及时解析日志的脚本。

日志文件压缩与归档（archive）不是日志库应有的功能，而应该交给专门的脚本去做，这样C++和Java的服务程序可以共享这一基础设施。

磁盘空间监控也不是日志库的必备功能。

往文件写日志的一个常见问题是，万一程序崩溃，那么最后若干条日志往往就丢失了，因为日志库不能每条消息都flush硬盘，更不能每条日志都open/close文件，这样性能开销太大。muduo日志库用两个办法来应对这一点，其一是定期（默认3秒）将缓冲区内的日志消息flush到硬盘（**定期flush**）；其二是每条内存中的日志消息都带有cookie（或者叫哨兵值/sentry），其值为某个函数的地址，这样通过在core dump文件中查找cookie就能找到尚未来得及写入磁盘的消息（**携带cookie**）。

**日志消息的格式是固定的**，不需要运行时配置，这样可节省每条日志解析格式字符串的开销。我认为日志的格式在项目的整个生命周期几乎不会改变，因为我们经常会为不同目的编写parse日志的脚本，既要解析最近几天的日志文件，也要和几个月之前，甚至一年之前的日志文件的同类数据做对比。如果在此期间日志格式变了，势必会增加很多无谓的工作量。如果真的需要调整消息格式，直接修改代码并重新编译即可。

- 尽量每条日志占一行。这样很容易用awk、sed、grep等命令行工具来快速联机分析日志，比方说要查看“2012-06-03 08:02:00”至“2012-06-03 08:02:59”这1分钟内每秒打印日志的条数（直方图），可以运行
`$ grep -o '^20120603 08:02:..' | sort | uniq -c`
- 时间戳精确到微秒。每条消息都通过gettimeofday(2)获得当前时间，这么做不会有什么性能损失。因为在x86-64 Linux上，gettimeofday(2)不是系统调用，不会陷入内核。
- 始终使用GMT时区（Z）。对于跨洲的分布式系统而言，可省去本地时区转换的麻烦（别忘了主要西方国家大多实行夏令时），更易于追查事件的顺序。
- 打印线程id。便于分析多线程程序的时序，也可以检测死锁。这里的线程id是指调用LOG_INFO <<的线程
- 打印源文件名和行号

### 性能需求

编写Linux服务端程序的时候，我们需要一个高效的日志库。只有日志库足够高效，程序员才敢在代码中输出足够多的诊断信息，减小运维难度，提升效率。高效性体现在几方面：

- 每秒写几千上万条日志的时候没有明显的性能损失。
- 能应对一个进程产生大量日志数据的场景，例如1GB/min。
- 不阻塞正常的执行流程。
- 在多线程程序中，不造成争用（contention）。这里列举一些具体的性能指标，考虑往普通7200rpm SATA硬盘写日志文件的情况：
- 磁盘带宽约是110MB/s，日志库应该能瞬时写满这个带宽（不必持续太久）。
- 假如每条日志消息的平均长度是110字节，这意味着1秒要写100万条日志。

以上是“高性能”日志库的最低指标。如果磁盘带宽更高，那么日志库的预期性能指标也会相应提高。反过来说，在磁盘带宽确定的情况下，日志库的性能只要“足够好”就行了。Muduo日志库在现在的PC上可以每秒写200万条日志。

### 多线程异步日志（背景进程收集日志消息）

多线程程序对日志库提出了新的需求：线程安全，即多个线程可以并发写日志，两个线程的日志消息不会出现交织。线程安全不难办到，简单的办法是用一个**全局mutex保护IO**，或者**每个线程单独写一个日志文件**，但这两种做法的高效性就堪忧了。前者会造成全部线程抢一个锁，后者有可能让业务线程阻塞在写磁盘操作上。

我认为一个多线程程序的每个进程最好只写一个日志文件，这样分析日志更容易，不必在多个文件中跳来跳去。再说多线程写多个文件也不一定能提速，见此处 的分析。解决办法不难想到，用一个**背景线程**负责收集日志消息，并写入日志文件，其他业务线程只管往这个“日志线程”发送日志消息，这称为“异步日志”

在多线程服务程序中，异步日志（叫“**非阻塞日志**”似乎更准确）是必需的，因为如果在网络IO线程或业务线程中直接往磁盘写数据的话，写操作偶尔可能阻塞长达数秒之久（原因很复杂，可能是磁盘或磁盘控制器复位）。这可能导致请求方超时，或者耽误发送心跳消息，在分布式系统中更可能造成多米诺骨牌效应，例如误报死锁引发自动failover等。因此，在正常的实时业务处理流程中应该彻底避免磁盘IO，这在使用one loop per thread模型的非阻塞服务端程序中尤为重要，因为线程是复用的，阻塞线程意味着影响多个客户连接。

我们需要一个“队列”来将日志前端的数据传送到后端（日志线程），但这个“队列”不必是现成的`BlockingQueue<std::string>`，因为不用每次产生一条日志消息都通知（notify()）接收方。

muduo日志库采用的是**双缓冲（double buffering）**技术，基本思路是准备两块buffer：A和B，前端负责往buffer A填数据（日志消息），后端负责将buffer B的数据写入文件。当buffer A写满之后，交换A和B，让后端将buffer A的数据写入文件，而前端则往buffer B填入新的日志消息，如此往复。用两个buffer的好处是在新建日志消息的时候不必等待磁盘文件操作，也避免每条新日志消息都触发（唤醒）后端日志线程。换言之，前端不是将一条条日志消息分别传送给后端，而是将多条日志消息拼成一个大的buffer传送给后端，相当于批处理，减少了线程唤醒的频度，降低开销。另外，为了及时将日志消息写入文件，即便buffer A未满，日志库也会每3秒执行一次上述交换写入操作。

实际实现采用了**四个缓冲区**，这样可以进一步减少或避免日志前端的等待。数据结构如下（ muduo/base/AsyncLoggin.h）：

```c++
typedef boost::ptr_vector<LargeBuffer> BufferVector;
typedef BufferVector::auto_type BufferPtr;
muduo::MutexLock mutex_;
muduo::Condition cond_;
BufferPtr currentBuffer_;
BufferPtr nextBuffer_;
BufferVector buffers_;
```

其中，LargeBuffer类型是FixedBuffer classtemplate的一份具体实现（instantiation），其大小为4MB，可以存至少1000条日志消息。`boost::ptr_vector<T>::auto_type`类型类似C++11中的std::unique_ptr，具备移动语义（move semantics），而且能自动管理对象生命期。mutex_用于保护后面的四个数据成员。buffers_存放的是供后端写入的buffer。

先来看发送方代码，位于muduo/base/AsyncLogging.cc。

```c++
void AsyncLogging::append(const char* logline, int len)
{
  muduo::MutexLockGuard lock(mutex_);
  if (currentBuffer_->avail() > len)
  {
    currentBuffer_->append(logline, len);
  }
  else
  {
    buffers_.push_back(std::move(currentBuffer_));
    if (nextBuffer_)
    {
      currentBuffer_ = std::move(nextBuffer_);
    }
    else
    {
      currentBuffer_.reset(new Buffer); // Rarely happens
    }
    currentBuffer_->append(logline, len);
    cond_.notify();
  }
}
```

![20200213173323.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200213173323.png)

前端在生成一条日志消息的时候会调用AsyncLogging::append()。在这个函数中，如果当前缓冲（currentBuffer_）剩余的空间足够大，则会直接把日志消息拷贝（追加）到当前缓冲中，这是最常见的情况。这里拷贝一条日志消息并不会带来多大开销。前后端代码的其余部分都没有拷贝，而是简单的指针交换。

否则，说明当前缓冲已经写满，就把它送入（移入）buffers_，并试图把预备好的另一块缓冲（nextBuffer_）移用（move）为当前缓冲，然后追加日志消息并通知（唤醒）后端开始写入日志数据。以上两种情况在临界区之内都没有耗时的操作，运行时间为常数。

如果前端写入速度太快，一下子把两块缓冲都用完了，那么只好分配一块新的buffer，作为当前缓冲，这是极少发生的情况。

再来看接收方（后端）实现，这里只给出了最关键的临界区内的代码（L59～L72），其他琐事请见源文件（muduo/base/AsyncLogging.cc)。

```c++
void AsyncLogging::threadFunc()
{
  BufferPtr newBuffer1(new Buffer);
  BufferPtr newBuffer2(new Buffer);
  BufferVector buffersToWrite;
  buffersToWrite.reserve(16);
  while (running_)
  {
    // swap out what need to be written, keep CS short
    {
      muduo::MutexLockGuard lock(mutex_);
      if (buffers_.empty())  // unusual usage!一般都是while
      {
        cond_.waitForSeconds(flushInterval_);
      }
      buffers_.push_back(std::move(currentBuffer_));
      currentBuffer_ = std::move(newBuffer1);
      buffersToWrite.swap(buffers_);
      if (!nextBuffer_)
      {
        nextBuffer_ = std::move(newBuffer2);
      }
    }
    // output buffersToWrite to file
    // re-fill newBuffer1 and newBuffer2
  }
  // flush output
}
```

![20200213173349.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200213173349.png)

首先准备好两块空闲的buffer，以备在临界区内交换（L53、L54）。在临界区内，等待条件触发（L61～L64），这里的条件有两个：其一是超时，其二是前端写满了一个或多个buffer。注意这里是非常规的condition variable用法，它没有使用while循环，而且等待时间有上限。
当“条件”满足时，先将当前缓冲（currentBuffer_）移入buffers_（L65），并立刻将空闲的newBuffer1移为当前缓冲（L66）。注意这整段代码位于临界区之内，因此不会有任何race condition。接下来将buffers_与buffersToWrite交换（L67），后面的代码可以在临界区之外安全地访问buffersToWrite，将其中的日志数据写入文件（L73）。临界区里最后干的一件事情是用newBuffer2替换nextBuffer_（L68～L71），这样前端始终有一个预备buffer可供调配。nextBuffer_可以减少前端临界区分配内存的概率，缩短前端临界区长度。注意到后端临界区内也没有耗时的操作，运行时间为常数。

L74会将buffersToWrite内的buffer重新填充newBuffer1和newBuffer2，这样下一次执行的时候还有两个空闲buffer可用于替换前端的当前缓冲和预备缓冲。最后，这四个缓冲在程序启动的时候会全部填充为0，这样可以避免程序热身时page fault引发性能不稳定。

以下再用图表展示前端和后端的具体交互情况。一开始先分配好四个缓冲区A、B、C、D，前端和后端各持有其中两个。前端和后端各有一个缓冲区数组，初始时都是空的。

第一种情况是前端写日志的频度不高，后端3秒超时后将“当前缓冲currentBuffer_”写入文件，见图5-1（图中变量名为简写，下同）。

![20200213173047.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200213173047.png)

在第2.9秒的时候，currentBuffer_使用了80％，在第3秒的时候后端线程醒过来，先把currentBuffer_送入buffers_（L65），再把newBuffer1移用为currentBuffer_（L66）。随后第3+秒，交换buffers_和buffersToWrite（L67），离开临界区，后端开始将buffer A写入文件。写完（write done）之后再把newBuffer1重新填上，等待下一次cond_.waitForSeconds()返回。

第二种情况，在3秒超时之前已经写满了当前缓冲，于是唤醒后端线程开始写入文件，见图5-2。

![20200213173535.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200213173535.png)

在第1.5秒的时候，currentBuffer_使用了80％；第1.8秒，currentBuffer_写满，于是将当前缓冲送入buffers_（L37），并将nextBuffer_移用为当前缓冲（L39～L42），然后唤醒后端线程开始写入。当后端线程唤醒之后（第1.8+秒），先将currentBuffer_送入buffers_（L65），再把newBuffer1移用为currentBuffer_（L66），然后交换buffers_和buffersToWrite（L67），最后用newBuffer2替换nextBuffer_（L68～L71），即保证前端有两个空缓冲可用。离开临界区之后，将buffersToWrite中的缓冲区A和B写入文件，写完之后重新填充newBuffer1和newBuffer2，完成一次循环。

上面这两种情况都是最常见的，再来看一看前端需要分配新buffer的两种情况。

第三种情况，前端在短时间内密集写入日志消息，用完了两个缓冲，并重新分配了一块新的缓冲，见图5-3。

![20200213173638.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200213173638.png)

在第1.8秒的时候，缓冲A已经写满，缓冲B也接近写满，并且已经notify()了后端线程，但是出于种种原因，后端线程并没有立刻开始工作。到了第1.9秒，缓冲B也已经写满，前端线程新分配了缓冲E。到了第1.8+秒，后端线程终于获得控制权，将C、D两块缓冲交给前端，并开始将A、B、E依次写入文件。一段时间之后，完成写入操作，用A、B重新填充那两块空闲缓冲。注意这里有意用A和B来填充newBuffer1/2，而释放了缓冲E，这是因为使用A和B不会造成page fault。

思考题：阅读代码并回答，缓冲E是何时在哪个线程释放的？

第四种情况，文件写入速度较慢，导致前端耗尽了两个缓冲，并分配了新缓冲，见图5-4

![20200213173754.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200213173754.png)

前1.8+秒的场景和前面“第二种情况”相同，前端写满了一个缓冲，唤醒后端线程开始写入文件。之后，后端花了较长时间（大半秒）才将数据写完。这期间前端又用完了两个缓冲，并分配了一个新的缓冲，这期间前端的notify()已经丢失。当后端写完（write done）后，发现buffers_不为空（L61），立刻进入下一循环。即替换前端的两个缓冲，并开始一次写入C、D、E。假定前端在此期间产生的日志较少，请读者补全后续的情况。

#### 如果日志消息堆积怎么办

对于同步日志来说，这不是问题，因为阻塞IO自然限制了前端的写入速度，起到了**节流阀（throttling）**的作用。

但是对于异步日志来说，这就是典型的生产速度高于消费速度问题，会造成数据在内存中堆积，严重时引发性能问题（可用内存不足）或程序崩溃（分配内存失败）。

muduo日志库处理日志堆积的方法很简单：**直接丢掉多余的日志buffer**，以腾出内存，见第87～96行代码。这样可以防止日志库本身引起程序故障，是一种自我保护措施。将来或许可以加上网络报警功能，通知人工介入，以尽快修复故障。

### 其他方案

当然在前端和后端之间高效传递日志消息的办法不止这一种，比方说使用常规的`muduo::BlockingQueue<std::string>`或`muduo::BoundedBlockingQueue<std::string>`在前后端之间传递日志消息，其中每个std::string是一条消息。这种做法每条日志消息都要分配内存，特别是在前端线程分配的内存要由后端线程释放，因此对malloc的实现要求较高，需要针对多线程特别优化。另外，如果用这种方案，那么需要修改LogStream的Buffer，使之直接将日志写到std::string中，可节省一次内存拷贝

但经过测试，还是异步日志较好，muduo的异步日志实现用了一个全局锁，尽管临界区很小，但是如果线程很多，**锁争用（lock contention）**也可能影响性能。

为了简化实现，目前muduo日志库只允许指定日志文件的名字，不允许指定其路径。日志库会把日志文件写到当前路径，因此可以在启动脚本（shell脚本）里改变当前路径，以达到相同的目的。

## 第6章 muduo网络库简介

线程安全、只支持Linux、只支持TCP、只支持IPv4，只考虑内网，只支持一种使用模式：非阻塞IO+one event loop per thread，不支持阻塞IO

### muduo网络库的安装

CMake、Boost、静态编译

### 目录结构

![20200213191918.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200213191918.png)

muduo/base目录是一些基础库，都是用户可见的类

![20200213192338.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200213192338.png)

网络核心库：muduo是基于Reactor模式的网络库，其核心是个事件循环EventLoop，用于响应计时器和IO事件。muduo采用基于对象（object-based）而非面向对象（objectoriented）的设计风格，其事件回调接口多以boost::function＋boost::bind表达，用户在使用muduo的时候不需要继承其中的class。网络库核心位于muduo/net和muduo/net/poller，一共不到4300行代码，以下灰底表示用户不可见的内部类。

![20200213192522.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200213192522.png)

网络附属库：它们不是核心内容，在使用的时候需要链接相应的库，例如-lmuduo_http、-lmuduo_inspect等等。HttpServer和Inspector暴露出一个http界面，用于监控进程的状态，类似于Java JMX（§9.5）。
附属模块位于muduo/net/{http,inspect,protorpc}等处。

![20200213192708.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200213192708.png)

#### 代码结构

muduo的头文件明确分为客户可见和客户不可见两类。以下是安装之后暴露的头文件和库文件。对于使用muduo库而言，只需要掌握5个关键类：Buffer、EventLoop、TcpConnection、TcpClient、TcpServer。

图6-1是muduo的网络核心库的头文件包含关系，用户可见的为白底，用户不可见的为灰底。

![20200213192821.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200213192821.png)

公开接口：

- Buffer仿Netty ChannelBuffer的buffer class，数据的读写通过buffer进行。用户代码不需要调用read(2)/write(2)，只需要处理收到的数据和准备好要发送的数据（§7.4）。
- InetAddress封装IPv4地址（end point），注意，它不能解析域名，只认IP地址。因为直接用**gethostbyname(3)解析域名会阻塞IO线程**。
- EventLoop事件循环（反应器Reactor），每个线程只能有一个EventLoop实体，它负责IO和定时器事件的分派。它用eventfd(2)来异步唤醒，这有别于传统的用一对pipe(2)的办法。它用TimerQueue作为计时器管理，用Poller作为IO multiplexing。
- EventLoopThread启动一个线程，在其中运行EventLoop::loop()。
- TcpConnection整个网络库的核心，封装一次TCP连接，注意它不能发起连接。
- TcpClient用于编写网络客户端，能发起连接，并且有重试功能。
- TcpServer用于编写网络服务器，接受客户的连接。

在这些类中，TcpConnection的生命期依靠shared_ptr管理（即用户和库共同控制）。Buffer的生命期由TcpConnection控制。其余类的生命期由用户控制。Buffer和InetAddress具有值语义，可以拷贝；其他class都是对象语义，不可以拷贝。

内部实现：

- Channel是selectable IO channel，负责注册与响应IO事件，注意它不拥有file descriptor。它是Acceptor、Connector、EventLoop、TimerQueue、TcpConnection的成员，生命期由后者控制。
- Socket是一个RAIIhandle，封装一个filedescriptor，并在析构时关闭fd。它是Acceptor、TcpConnection的成员，生命期由后者控制。EventLoop、TimerQueue也拥有fd，但是不封装为Socket class。
- SocketsOps封装各种Sockets系统调用。
- Poller是PollPoller和EPollPoller的基类，采用“电平触发”的语意。它是EventLoop的成员，生命期由后者控制。
- PollPoller和EPollPoller封装poll(2)和epoll(4)两种IO multiplexing后端。poll的存在价值是便于调试，因为poll(2)调用是上下文无关的，用strace(1)很容易知道库的行为是否正确。
- Connector用于发起TCP连接，它是TcpClient的成员，生命期由后者控制。
- Acceptor用于接受TCP连接，它是TcpServer的成员，生命期由后者控制。
- TimerQueue用timerfd实现定时，这有别于传统的设置poll/epoll_wait的等待时长的办法。TimerQueue用std::map来管理Timer，常用操作的复杂度是O(logN)，N为定时器数目。它是EventLoop的成员，生命期由后者控制。
- EventLoopThreadPool用于创建IO线程池，用于把TcpConnection分派到某个EventLoop线程上。它是TcpServer的成员，生命期由后者控制。

图6-2是muduo的简化类图，Buffer是TcpConnection的成员。

![20200213193416.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200213193416.png)

#### 例子

muduo附带了十几个示例程序，编译出来有近百个可执行文件。这些例子位于 目录，其中包括从Boost.Asio、Java Netty、Python Twisted等处移植过来的例子。这些例子基本覆盖了常见的服务端网络编程功能点，从这些例子可以充分学习非阻塞网络编程。

![20200213193520.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200213193520.png)

#### 线程模型

muduo的线程模型符合我主张的**one loop per thread＋thread pool**模型。每个线程最多有一个EventLoop，每个TcpConnection必须归某个EventLoop管理，所有的IO会转移到这个线程。换句话说，**一个file descriptor只能由一个线程读写**。TcpConnection所在的线程由其所属的EventLoop决定，这样我们可以很方便地把不同的TCP连接放到不同的线程去，也可以把一些TCP连接放到一个线程里。TcpConnection和EventLoop是线程安全的，可以跨线程调用。

TcpServer直接支持多线程，它有两种模式：

- 单线程，accept(2)与TcpConnection用同一个线程做IO。
- 多线程，accept(2)与EventLoop在同一个线程，另外创建一个EventLoopThreadPool，新到的连接会按round-robin方式分配到线程池

以下转自[muduo多线程的处理](https://www.jianshu.com/p/7e023dd5fb79)

muduo是基于one loop per thread模型的。那么什么是one loop per thread模型呢？

字面意思上讲就是每个线程里有个loop,即消息循环。我们知道服务器必定有一个监听的socket和1到N个连接的socket，每个socket也必定有网络事件。我们可以启动设定数量的线程，让这些线程来承担网络事件。

每个进程默认都会启动一个线程，即这个线程不需要我们手动去创建，称之为主线程。一般地我们让主线程来承担监听socket的网络事件。至于连接socket的事件要不要在主线程中处理，这个得看我们启动其他线程即工作线程的数量。如果启动了工作线程，那么连接socket的网络事件一定是在工作线程中处理的。

每个线程的事件处理都是在一个EventLoop的while循环中，而**每一个EventLoop都有一个多路事件复用解析器epoller**。循环的主体部分是等待epoll事件触发，从而处理事件。主线程EventLoop的epoller会添加监听socket可读事件，而工作线程只添加了定时器处理事件（每个EventLoop都会有，主线程有EventLoop,当然也添加了定时器处理事件）。在没有事件触发之前，epoller都是阻塞的，导致线程被挂起。

当有连接来到时，挂起的主线程恢复，会执行新连接的回调函数。在该函数中，会从线程池中取得一个线程来接管新连接socket的处理。那么问题来了，既然工作线程已经阻塞了，那他是如何处理新连接socket相关事件的呢，也就是什么时候恢复呢？

原来，每个EventLoop还有一个**wakeup事件**。主线程通知工作线程去处理事件的时候，工作线程发现不在本线程的时间片中，于是唤醒工作线程了。

### 使用教程

muduo只支持Linux 2.6.x下的并发非阻塞TCP网络编程，它的核心是每个IO线程一个事件循环，**把IO事件分发到回调函数上**

#### TCP网络编程本质论

基于事件的非阻塞网络编程是编写高性能并发网络服务程序的主流模式，头一次使用这种方式编程通常需要转换思维模式。把原来“主动调用recv(2)来接收数据，主动调用accept(2)来接受新连接，主动调用send(2)来发送数据”的思路换成“注册一个收数据的回调，网络库收到数据会调用我，直接把数据提供给我，供我消费。注册一个接受连接的回调，网络库接受了新连接会回调我，直接把新的连接对象传给我，供我使用。需要发送数据的时候，只管往连接中写，网络库会负责无阻塞地发送。

我认为，TCP网络编程最本质的是处理三个半事件：

- 1 **连接的建立**，包括服务端接受（accept）新连接和客户端成功发起（connect）连接。TCP连接一旦建立，客户端和服务端是平等的，可以各自收发数据。
- 2 **连接的断开**，包括主动断开（close、shutdown）和被动断开（read(2)返回0）。
- 3 **消息到达**，文件描述符可读。这是最为重要的一个事件，对它的处理方式决定了网络编程的风格（阻塞还是非阻塞，如何处理分包，应用层的缓冲如何设计，等等）。
- 3.5　**消息发送完毕**，这算半个。对于低流量的服务，可以不必关心这个事件；另外，这里的“发送完毕”是指将数据写入操作系统的缓冲区，将由TCP协议栈负责数据的发送与重传，不代表对方已经收到数据。

#### echo服务的实现

muduo的使用非常简单，不需要从指定的类派生，也不用覆写虚函数，只需要注册几个回调函数去处理前面提到的三个半事件就行了。
下面以经典的echo回显服务为例：

1．定义EchoServer class，不需要派生自任何基类。位于examples/simple/echo/echo.h

![20200214095703.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214095703.png)

在构造函数里注册回调函数。位于examples/simple/echo.cc

![20200214095739.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214095739.png)

2．实现EchoServer::onConnection()和EchoServer::onMessage()。

![20200214095750.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214095750.png)

L37和L40是echo服务的“业务逻辑”：把收到的数据原封不动地发回客户端。注意我们不用担心L40的send(msg)是否完整地发送了数据，因为muduo网络库会帮我们管理发送缓冲区。
这两个函数体现了“基于事件编程”的典型做法，即程序主体是被动等待事件发生，事件发生之后网络库会调用（回调）事先注册的**事件处理函数（event handler）**

在onConnection()函数中，conn参数是TcpConnection对象的shared_ptr，TcpConnection::connected()返回一个bool值，表明目前连接是建立还是断开，TcpConnection的peerAddress()和localAddress()成员函数分别返回对方和本地的地址（以InetAddress对象表示的IP和port）。

在onMessage()函数中，conn参数是收到数据的那个TCP连接；buf是已经收到的数据，buf的数据会累积，直到用户从中取走（retrieve）数据。注意buf是指针，表明用户代码可以修改（消费）buffer；time是收到数据的确切时间，即epoll_wait(2)返回的时间，注意这个时间通常比read(2)发生的时间略早，可以用于正确测量程序的消息处理延迟。另外，Timestamp对象采用pass-by-value，而不是pass-by-(const)reference，这是有意的，因为在x86-64上可以直接通过寄存器传参。

3．在main()里用EventLoop让整个程序跑起来。

![20200214100208.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214100208.png)

完整的代码见muduo/examples/simple/echo。这个几十行的小程序实现了一个单线程并发的echo服务程序，可以同时处理多个连接。

这个程序用到了TcpServer、EventLoop、TcpConnection、Buffer这几个class，也大致反映了这几个class的典型用法，后文还会详细介绍这几个class。注意，以后的代码大多会省略namespace。

####　七步实现finger服务

Python Twisted是一款非常好的网络库，它也采用Reactor作为网络编程的基本模型，所以从使用上与muduo颇有相似之处

finger是Twisted文档的一个经典例子，本文展示如何用muduo来实现最简单的finger服务端。限于篇幅，只实现finger01～finger07。代码位于examples/twisted/finger。

1．拒绝连接。 　什么都不做，程序空等。

![20200214100509.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214100509.png)

2．接受新连接。 　在1079端口侦听新连接，接受连接之后什么都不做，程序空等。muduo会自动丢弃收到的数据。

![20200214100532.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214100532.png)

3．主动断开连接。 　接受新连接之后主动断开。以下省略头文件和namespace。

![20200214100617.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214100617.png)

4．读取用户名，然后断开连接。 　如果读到一行以\r\n结尾的消息，就断开连接。注意这段代码有安全问题，如果恶意客户端不断发送数据而不换行，会撑爆服务端的内存。另外，Buffer::findCRLF()是线性查找，如果客户端每次发一个字节，服务端的时间复杂度为O(N2 )，会消耗CPU资源。

![20200214100833.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214100833.png)

5．读取用户名、输出错误信息，然后断开连接。 　如果读到一行以\r\n结尾的消息，就发送一条出错信息，然后断开连接。安全问题同上。

![20200214100913.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214100913.png)

6．从空的UserMap里查找用户。 　从一行消息中拿到用户名（L30），在UserMap里查找，然后返回结果。安全问题同上。

![20200214101110.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214101110.png)

7．往UserMap里添加一个用户。 　与前面几乎完全一样，只多了L39。``users["schen"] = "Happy and well";`

### 详解muduo多线程模型

本节以一个Sudoku Solver为例，回顾了并发网络服务程序的多种设计方案，并介绍了使用muduo网络库编写多线程服务器的两种最常用手法。下一章的例子展现了muduo在编写单线程并发网络服务程序方面的能力与便捷性。今天我们先看一看它在多线程方面的表现。本节代码参见： 。

#### 数独求解服务器

假设有这么一个网络编程任务：写一个求解数独的程序（Sudoku Solver），并把它做成一个网络服务。

一个简单的以\r\n分隔的文本行协议，使用TCP长连接，客户端在不需要服务时主动断开连接。
请求：[id:]<81digits>\r\n
响应：[id:]<81digits>\r\n
或者：[id:]NoSolution\r\n

其中[id:]表示可选的id，用于区分先后的请求，以支持Parallel Pipelining，响应中会回显请求中的id。

<81digits> 是 Sudoku 的棋盘，9 × 9 个数字，从左上角到右下角按行扫描，未 知数字以 0 表示。如果 Sudoku 有解，那么响应是填满数字的棋盘;如果无解，则返 回 NoSolution。

```shell
例子1 请求: 000000010400000000020000000000050407008000300001090000300400200050100000000806000\r\n
响应:
693784512487512936125963874932651487568247391741398625319475268856129743274836159\r\n
例子2 请求: a:000000010400000000020000000000050407008000300001090000300400200050100000000806000\r\n
响应:
a:693784512487512936125963874932651487568247391741398625319475268856129743274836159\r\n
例子3 请求: b:000000010400000000020000000000050407008000300001090000300400200050100000000806005\r\n
响应:b:NoSolution\r\n
```

Sudoku的求解算法见《谈谈数独（Sudoku）》 28 一文，这不是本文的重点。假设我们已经有一个函数能求解Sudoku，它的原型如下：
`string solveSudoku(const string& puzzle);`
函数的输入是上文的“<81digits>”，输出是“<81digits>”或“NoSolution”。这个函数是个pure function，同时也是线程安全的。
有了这个函数，我们以§6.4.2“echo服务的实现”中出现的EchoServer为蓝本，稍加修改就能得到SudokuServer。这里只列出最关键的onMessage()函数，完整的代码见 。onMessage()的主要功能是处理协议格式，并调用solveSudoku()求解问题。这个函数应该能正确处理TCP分包。

![20200214103453.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214103453.png)

#### 常见的并发网络服务程序设计方案（重点）

![concurrentmodel.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/concurrentmodel.png)

- 方案0 accept+read/write
  
  不是并发服务器，而是**迭代(iterative)服务器**，因为一次只服务一个客户。不适合长连接，倒是很适合daytime这种write-only的短连接服务
  
  ![20200214104206.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214104206.png)

- 方案1 accept+fork
  
  这是传统的Unix并发网络编程方案，[UNP]称之为child-per-client或fork()-per-client，另外也俗称**process-per-connection**。这种方案适合并发连接数不大的情况。至今仍有一些网络服务程序用这种方式实现，比如PostgreSQL和Perforce的服务端。这种方案适合“计算响应的工作量远大于fork()的开销”这种情况，比如数据库服务器。这种方案适合长连接，但不太适合短连接
  
  ![20200214104223.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214104223.png)

- 方案2 accept+thread
  
  这是传统的Java网络编程方案**thread-per-connection**，在Java 1.4引入NIO之前，Java网络服务多采用这种方案。它的初始化开销比方案1要小很多，但与求解Sudoku的用时差不多，仍然不适合短连接服务。这种方案的伸缩性受到线程数的限制，一两百个还行，几千个的话对操作系统的scheduler恐怕是个不小的负担。
  
  ![20200214104502.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214104502.png)

- 方案3 prefork

  针对accept+fork的优化，不用现场创建进程，但容易引起accept的惊群效应

- 方案4 pre threaded

  针对accept+thread的优化，不用现场创建线程

以上几种方案都是**阻塞式**网络编程，**程序流程（thread of control）**通常阻塞在read()上，等待数据到达。但是TCP是个全双工协议，同时支持read()和write()操作，当一个线程／进程阻塞在read()上，但程序又想给这个TCP连接发数据，那该怎么办？比如说echo client，既要从stdin读，又要从网络读，当程序正在阻塞地读网络的时候，如何处理键盘输入？（我记得这个例子来自unp，当时正好要引入IO复用的概念）

一种方法是两个进程/线程，一个负责读，一个负责写。

另一种方法是使用**IO multiplexing**，也就是select/poll/epoll/kqueue这一系列的“多路选择器”，让一个thread of control能处理多个连接。“IO复用”其实复用的不是IO连接，而是**复用线程**。使用select/poll**几乎肯定要配合non-blocking IO**，而使用non-blocking IO肯定要使用**应用层buffer**，原因见§7.4。这就不是一件轻松的事儿了，如果每个程序都去搞一套自己的IO multiplexing机制（本质是event-driven事件驱动），这是一种很大的浪费。感谢Doug Schmidt为我们总结出了Reactor模式，让event-driven网络编程有章可循。继而出现了一些通用的Reactor框架／库，比如libevent、muduo、Netty、twisted、POE等等。有了这些库，我想基本不用去编写阻塞式的网络程序了

这里先用一小段Python代码简要地回顾“以IO multiplexing方式实现并发echo server”的基本做法。为了简单起见，以下代码并**没有开启non-blocking**，也没有考虑数据发送不完整（L28）等情况。首先定义一个从文件描述符到socket对象的映射（L14），程序的主体是一个事件循环（L15～L32），每当有IO事件发生时，就针对不同的文件描述符（fileno）执行不同的操作（L16, L17）。对于listening fd，接受（accept）新连接，并注册到IO事件关注列表（watch list），然后把连接添加到connections字典中（L18～L23）。对于客户连接，则读取并回显数据，并处理连接的关闭（L24～L32）。对于echo服务而言，真正的业务逻辑只有L28：将收到的数据原样发回客户端。

![20200214110717.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214110717.png)

注意以上代码不是功能完善的IO multiplexing范本，它没有考虑错误处理，也没有实现定时功能，而且只适合侦听（listen）一个端口的网络服务程序。如果需要侦听多个端口，或者要同时扮演客户端，那么代码的结构需要推倒重来。

这个代码骨架可用于实现多种TCP服务器。例如写一个聊天服务只需改动3行代码，如下所示。业务逻辑是L28～L30：将本连接收到的数据转发给其他客户连接。

![20200214110748.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214110748.png)

但是这种把业务逻辑隐藏在一个大循环中的做法其实不利于将来功能的扩展，我们能不能设法把业务逻辑抽取出来，与网络基础代码分离呢？

Doug Schmidt指出，其实网络编程中有很多是事务性（routine）的工作，可以**提取为公用的框架或库**，而用户只需要填**上关键的业务逻辑代码**，并**将回调注册到框架中**，就可以实现完整的网络服务，这正是Reactor模式的主要思想。

而Reactor的意义在于将消息（IO事件）分发到用户提供的处理函数，并保持网络部分的通用代码不变，独立于用户的业务逻辑。

单线程Reactor的程序执行顺序如图6-11（左图）所示。在没有事件的时候，线程等待在select/poll/epoll_wait等函数上。事件到达后由网络库处理IO，再把消息通知（回调）客户端代码。Reactor事件循环所在的线程通常叫IO线程。通常由网络库负责读写socket，用户代码负载解码、计算、编码。

注意由于只有一个线程，因此事件是顺序处理的，一个线程同时只能做一件事情。在这种协作式多任务中，事件的优先级得不到保证，因为从“poll返回之后”到“下一次调用poll进入等待之前”这段时间内，线程不会被其他连接上的数据或事件抢占（见图6-11的右图）。如果我们想要延迟计算（把compute()推迟100ms），那么也不能用sleep()之类的阻塞调用，而应该注册超时回调，以避免阻塞当前IO线程。

![20200214111042.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214111042.png)

- 方案5 poll(reactor)
  
  基本的单线程Reactor方案（如上图所示），适合IO密集的应用，不太适合CPU密集的应用，因为较难发挥多核的威力。这里用一小段Python代码展示Reactor模式的雏形。为了节省篇幅，这里直接使用了全局变量，也没有处理异常。程序的核心仍然是事件循环（L42～L46），与前面不同的是，事件的处理通过handlers转发到各个函数中，不再集中在一坨。例如**listening fd的处理函数是handle_accept，它会注册客户连接的handler。普通客户连接的处理函数是handle_request，其中又把连接断开和数据到达这两个事件分开，后者由handle_input处理**。业务逻辑位于单独的handle_input函数，实现了分离。

  ![20200214113210.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214113210.png)

  必须说明的是，完善的非阻塞IO网络库远比这个玩具代码复杂，需要考虑各种错误场景。特别是要真正接管数据的收发，而不是像这个示例那样直接在事件处理回调函数中发送网络数据。

- 方案6 reactor+thread-per-task

  过渡方案，不在Reactor线程计算，而是创建一个新线程去计算，以充分利用多核CPU，因为，该方案为每个请求（不是连接）创建一个线程，这个开销可以用线程池来避免。该方案还有一个缺点是乱序，请求的次序与计算结果的次序不一定一致

- 方案7 reactor+worker thread
  
  为了让返回结果的顺序确定，我们可以为每个连接创建一个计算线程，每个连接上的请求固定发给同一个线程去算，先到先得。这也是一个过渡方案，因为并发连接数受限于线程数目，这个方案或许还不如直接使用阻塞IO的thread-per-connection方案

- 方案8 reactor+thread pool

  全部的IO工作都在一个Reactor线程完成，而**计算任务交给thread pool**。如果计算任务彼此独立，而且IO的压力不大，那么这种方案是非常适用的。Sudoku Solver正好符合。代码参见examples/sudoku/server_threadpool.cc。该方案使用线程池的代码与单线程Reactor的方案5相比变化不大，只是把原来onMessage()中涉及计算和发回响应的部分抽出来做成一个函数，然后交给ThreadPool去计算。记住方案8有乱序返回的可能，客户端要根据id来匹配响应。线程池的另外一个作用是执行阻塞操作。比如有的数据库的客户端只提供同步访问，那么可以把数据库查询放到线程池中，可以避免阻塞IO线程，不会影响其他客户连接。

  ![20200214114016.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214114016.png)

  ![20200214114338.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214114338.png)

- **方案9 reactors in threads**
  
  这是**muduo内置的多线程方案**，也是Netty内置的多线程方案。这种方案的特点是**one loop per thread**，有一个main Reactor负责accept(2)连接，然后把连接挂在某个sub Reactor中（muduo采用round-robin的方式来选择sub Reactor），**这样该连接的所有操作都在那个sub Reactor所处的线程中完成**。多个连接可能被分派到多个线程中，以充分利用CPU。

  muduo采用的是**固定大小的Reactor pool**，池子的大小通常根据CPU数目确定，也就是说线程数是固定的，这样程序的总体处理能力不会随连接数增加而下降。另外，由于一个连接完全由一个线程管理，那么请求的顺序性有保证，突发请求也不会占满全部8个核（如果需要优化突发请求，可以考虑方案11）。这种方案把IO分派给多个线程，防止出现一个Reactor的处理能力饱和。

  与方案8的线程池相比，方案9减少了进出thread pool的两次上下文切换，在把多个连接分散到多个Reactor线程之后，小规模计算可以在当前IO线程完成并发回结果，从而降低响应的延迟。我认为这是一个适应性很强的多线程IO模型，因此把它作为muduo的默认线程模型

  **图很重要，IO Thread由线程池创建出来，compute操作就在IO Thread中进行**

  ![20200214114719.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214114719.png)

- 方案10 reactors in processes

  Nginx的内置方案，如果连接之间无交互，这也是很好的选择，工作进程之间相互独立，可以热升级

- 方案11 reactors+thread pool

  把方案8和方案9混合，既使用多个Reactor来处理IO，又使用线程池来处理计算。这种方案适合既有突发IO（利用多线程处理多个连接上的IO），又有突发计算的应用（利用线程池把一个连接上的计算任务分配给多个线程去做），见图6-14（下图）。要注意与方案（reactors in threads)的比较，这里的compute都在线程池中进行。资源利用率可能比方案9高，一个客户不会被同一线程的其他客户阻塞，但**延迟也比方案9略大**

  ![20200214115347.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200214115347.png)

#### 结语

我再用银行柜台办理业务为比喻，简述各种模型的特点。银行有旋转门，办理业务的客户人员从旋转门进出（IO）；银行也有柜台，客户在柜台办理业务（计算）。要想办理业务，客户要先通过旋转门进入银行；办理完之后，客户要再次通过旋转门离开银行。一个客户可以办理多次业务，每次都必须从旋转门进出（TCP长连接）。另外，旋转门一次只允许一个客户通过（无论进出），因为read()/write()只能同时调用其中一个。

方案5： 这间小银行有一个旋转门、一个柜台，每次只允许一名客户办理业务。而且当有人在办理业务时，旋转门是锁住的（计算和IO在同一线程）。为了维持工作效率，银行要求客户应该尽快办理业务，最好不要在取款的时候打电话去问家里人密码，也不要在通过旋转门的时候停下来系鞋带，这都会阻塞其他堵在门外的客户。如果客户很少，这是很经济且高效的方案；但是如果场地较大（多核），则这种布局就浪费了不少资源，只能并发（concurrent）不能并行（parallel）。如果确实一次办不完，应该离开柜台，到门外等着，等银行通知再来继续办理（分阶段回调）。

方案8： 这间银行有一个旋转门，一个或多个柜台。银行进门之后有一个队列，客户在这里排队到柜台（线程池）办理业务。即在单线程Reactor后面接了一个线程池用于计算，可以利用多核。旋转门基本是不锁的，随时都可以进出。但是排队会消耗一点时间，相比之下，方案5中客户一进门就能立刻办理业务。另外一种做法是线程池里的每个线程有自己的任务队列，而不是整个线程池共用一个任务队列。这样的好处是避免全局队列的锁争用，坏处是计算资源有可能分配不平均，降低并行度。

方案9： 这间大银行相当于包含方案5中的多家小银行，每个客户进大门的时候就被固定分配到某一间小银行中，他的业务只能由这间小银行办理，他每次都要进出小银行的旋转门。但总体来看，大银行可以同时服务多个客户。这时同样要求办理业务时不能空等（阻塞），否则会影响分到同一间小银行的其他客户。而且必要的时候可以为VIP客户单独开一间或几间小银行，优先办理VIP业务。这跟方案5不同，当普通客户在办理业务的时候，VIP客户也只能在门外等着（见图6-11的右图）。这是一种适应性很强的方案，也是muduo原生的多线程IO模型。

方案11 ：这间大银行有多个旋转门，多个柜台。旋转门和柜台之间没有一一对应关系，客户进大门的时候就被固定分配到某一旋转门中（奇怪的安排，易于实现线程安全的IO，见§4.6），进入旋转门之后，有一个队列，客户在此排队到柜台办理业务。这种方案的资源利用率可能比方案9更高，一个客户不会被同一小银行的其他客户阻塞，但延迟也比方案9略大。

## 第7章 muduo编程示例

### 文件传输

#### 为什么muduo中的TcpConnection::shutdown()没有直接关闭TCP连接

muduo TcpConnection没有提供close()，而只提供shutdown()，这么做是为了收发数据的完整性。

TCP是一个全双工协议，同一个文件描述符既可读又可写，shutdownWrite()关闭了“写”方向的连接，保留了“读”方向，这称为**TCP half-close**。如果直接close(socket_fd)，那么socket_fd就不能读或写了。

用shutdown而不用close的效果是，如果对方已经发送了数据，这些数据还“在路上”，那么muduo不会漏收这些数据。换句话说，muduo在TCP这一层面解决了“当你打算关闭网络连接的时候，如何得知对方是否发了一些数据而你还没有收到？”这一问题。当然，这个问题也可以在上面的协议层解决，双方商量好不再互发数据，就可以直接断开连接。

也就是说muduo把“主动关闭连接”这件事情分成两步来做，如果要主动关闭连接，它会**先关本地“写”端，等对方关闭之后，再关本地“读”端**。

另外，如果当前output buffer里还有数据尚未发出的话，muduo也不会立刻调用shutdownWrite，而是等到数据发送完毕再shutdown，可以避免对方漏收数据。

### muduo Buffer类的设计与使用

本节介绍muduo中输入输出缓冲区的设计与实现。文中buffer指一般的应用层缓冲区、缓冲技术，Buffer特指muduo::net::Buffer class。

#### muduo的IO模型

[UNP] 6.2节总结了Unix/Linux上的五种IO模型：阻塞（blocking）、非阻塞（non-blocking）、IO复用（IO multiplexing）、信号驱动（signal-driven）、异步（asynchronous）。这些都是单线程下的IO模型。

one loop per thread is usually a good model

event loop是non-blocking网络编程的核心，在现实生活中，non-blocking几乎总是和IO multiplexing一起使用，原因有两点：

1. 没有人真的会用**轮询（busy-pooling）**来检查某个non-blocking IO操作是否完成，这样太浪费CPU cycles。
2. IO multiplexing一般不能和blocking IO用在一起，因为blocking IO中read()/write()/accept()/connect()都有可能阻塞当前线程，这样线程就没办法处理其他socket上的IO事件了。见[UNP] 16.6节“nonblocking accept”的例子。

所以，当我提到non-blocking的时候，实际上指的是non-blocking＋IO multiplexing，单用其中任何一个是不现实的。另外，本书所有的“连接”均指TCP连接，socket和connection在文中可互换使用。当然，non-blocking编程比blocking难得多

#### 为什么non-blocking网络编程中应用层buffer是必需的

non-blocking IO的核心思想是**避免阻塞在read()或write()或其他IO系统调用**上，这样可以最大限度地复用thread-of-control，让一个线程能服务于多个socket连接。**IO线程只能阻塞在IO multiplexing函数**上，如select/poll/epoll_wait。这样一来，应用层的缓冲是必需的，每个TCP socket都要有stateful的input buffer和output buffer。

- TcpConnection必须要有output buffer

  考虑一个常见场景：程序想通过TCP连接发送100kB的数据，但是在write()调用中，操作系统只接受了80kB（受TCP advertised window的控制，细节见[TCPv1]），你肯定不想在原地等待，因为不知道会等多久（取决于对方什么时候接收数据，然后滑动TCP窗口）。程序应该尽快交出控制权，返回event loop。在这种情况下，剩余的20kB数据怎么办？

  对于应用程序而言，它只管生成数据，它不应该关心到底数据是一次性发送还是分成几次发送，这些应该由网络库来操心，程序只要调用TcpConnection::send()就行了，网络库会负责到底。网络库应该接管这剩余的20kB数据，把它保存在该TCP connection的output buffer里，然后注册POLLOUT事件，一旦socket变得可写就立刻发送数据。当然，这第二次write()也不一定能完全写入20kB，如果还有剩余，网络库应该继续关注POLLOUT事件；如果写完了20kB，网络库应该停止关注POLLOUT，以免造成**busy loop**

  如果程序又写入了50kB，而这时候output buffer里还有待发送的20kB数据，那么网络库不应该直接调用write()，而应该把这50kB数据append在那20kB数据之后，等socket变得可写的时候再一并写入。

  如果output buffer里还有待发送的数据，而程序又想关闭连接（对程序而言，调用TcpConnection::send()之后他就认为数据迟早会发出去），那么这时候网络库不能立刻关闭连接，而要等数据发送完毕

- TcpConnection必须要有input buffer 　

  TCP是一个无边界的字节流协议，接收方必须要处理“收到的数据尚不构成一条完整的消息”和“一次收到两条消息的数据”等情况。一个常见的场景是，发送方send()了两条1kB的消息（共2kB），接收方收到数据的情况可能是：

    ·一次性收到2kB数据；
    ·分两次收到，第一次600B，第二次1400B；
    ·分两次收到，第一次1400B，第二次600B；
    ·分两次收到，第一次1kB，第二次1kB；
    ·分三次收到，第一次600B，第二次800B，第三次600B；
    ·其他任何可能。一般而言，长度为n字节的消息分块到达的可能性有2n-1 种

  网络库在处理“socket可读”事件的时候，必须一次性把socket里的数据读完（从操作系统buffer搬到应用层buffer），否则会反复触发POLLIN事件，造成busy-loop。那么网络库必然要应对“数据不完整”的情况，**收到的数据先放到input buffer里，等构成一条完整的消息再通知程序**的业务逻辑。这通常是codec的职责，见§7.3“Boost.Asio的聊天服务器”中的“TCP分包”的论述与代码。所以，在TCP网络编程中，网络库必须要给每个TCP connection配置input buffer。

- 在非阻塞网络编程中，如何设计并使用缓冲区？
  
  一方面我们希望减少系统调用，一次读的数据越多越划算，那么似乎应该准备一个大的缓冲区。另一方面希望减少内存占用。如果有10000个并发连接，每个连接一建立就分配各50kB的读写缓冲区的话，将占用1GB内存，而大多数时候这些缓冲区的使用率很低。muduo用readv(2)结合**栈上空间**巧妙地解决了这个问题。

  具体做法是，在栈上准备一个65536字节的extrabuf，然后利用readv()来读取数据，iovec有两块，第一块指向muduo Buffer中的writable字节，另一块指向栈上的extrabuf。这样如果读入的数据不多，那么全部都读到Buffer中去了；如果长度超过Buffer的writable字节数，就会读到栈上的extrabuf里，然后程序再把extrabuf里的数据append()到Buffer中，代码见§8.7.2。

  这么做利用了临时栈上空间，避免每个连接的初始Buffer过大造成的内存浪费，也避免反复调用read()的系统开销（由于缓冲区足够大，通常一次readv()系统调用就能读完全部数据）

  陈硕说这是一个创新点（利用栈上空间设计缓冲区）

#### 前方添加（prepend）

前面说muduo Buffer有个小小的创新（或许不是创新，我记得在哪儿看到过类似的做法，忘了出处），即提供prependable空间，让程序能以很低的代价在数据前面添加几个字节。

比方说，程序以固定的4个字节表示消息的长度（为了解决粘包问题），我要序列化一个消息，但是不知道它有多长，那么我可以一直append()直到序列化完成，然后在刚才固定的4个字节中填充消息的长度。这样既可以以空间换时间

### 一种自动反射消息类型的Google Protobuf网络传输方案

Google Protocol Buffers（简称Protobuf）是一款非常优秀的库，它定义了一种紧凑（compact，相对XML和JSON而言）的可扩展二进制消息格式，特别适合网络数据传输。

它为多种语言提供binding，大大方便了分布式程序的开发，让系统不再局限于用某一种语言来编写。

本节要解决的问题是：通信双方在编译时就共享proto文件的情况下，接收方在收到Protobuf二进制数据流之后，如何自动创建具体类型的Protobuf Message对象，并用收到的数据填充该Message对象（即反序列化）。“自动”的意思是：当程序中新增一个Protobuf Message类型时，这部分代码不需要修改，不需要自己去注册消息类型。其实，Google Protobuf本身具有很强的**反射（reflection）**功能，可以根据type name创建具体类型的Message对象，我们直接利用即可。

### 限制服务器的最大并发连接数

本节中的“并发连接数”是指一个服务端程序能同时支持的客户端连接数，连接由客户端主动发起，服务端被动接受（accept(2)）连接。（如果要限制应用程序主动发起的连接，则问题要简单得多，毕竟主动权和决定权都在程序本身。）

#### 为什么要限制并发连接数

一方面，我们不希望服务程序超载；另一方面，更因为filedescriptor是稀缺资源，如果出现filedescriptor耗尽，很棘手，跟“malloc()失败/new抛出std::bad_alloc”差不多同样棘手。

假如accept(2)返回EMFILE该如何应对？这意味着**本进程的文件描述符已经达到上限**，无法为新连接创建socket文件描述符。但是，既然没有socket文件描述符来表示这个连接，我们就无法close(2)它。程序继续运行，再一次调用epoll_wait。这时候epoll_wait会立刻返回，因为新连接还等待处理，**listening fd还是可读的**。这样程序立刻就陷入了**busy loop**，CPU占用率接近100％.这既影响同一event loop上的连接，也影响同一机器上的其他服务。

muduo的Acceptor的解决方法如下：**准备一个空闲的文件描述符**。遇到这种情况，先关闭这个空闲文件，获得一个文件描述符的名额；再accept(2)拿到新socket连接的描述符；随后立刻close(2)它，这样就优雅地断开了客户端连接；最后重新打开一个空闲文件，把“坑”占住，以备再次出现这种情况时使用。

其实有另外一种比较简单的办法：file descriptor是hard limit，我们可以自己设一个稍低一点的**soft limit**，如果超过soft limit就主动关闭新连接，这样就可避免触及“file descriptor耗尽”这种边界条件

### 定时器

#### 程序中的时间

在一般的服务端程序设计中，与时间有关的常见任务有：

1. 获取当前时间，计算时间间隔。
2. 时区转换与日期计算；把纽约当地时间转换为上海当地时间；2011-02-05之后第100天是几月几号星期几；等等。
3. 定时操作，比如在预定的时间执行任务，或者在一段延时之后执行任务。

其中第2项看起来比较复杂，但其实最简单。日期计算用Julian Day Number，时区转换用tz database；唯一麻烦一点的是夏令时，但也可以用tz database解决。

真正麻烦的是第1项和第3项。一方面，Linux有一大把令人眼花缭乱的与时间相关的函数和结构体，在程序中该如何选用？另一方面，计算机中的时钟不是理想的计时器，它可能会漂移或跳变。最后，民用的UTC时间与闰秒的关系也让定时任务变得复杂和微妙。当然，与系统当前时间有关的操作也让单元测试变得困难。

#### Linux时间函数

用于获取当前时间和用于定时的函数有很多，我的取舍如下：

- （计时）只使用gettimeofday(2)来获取当前时间
  - 精度很高
  - 在x86-64平台上不是系统调用，而是在用户态实现的，没有上下文切换和陷入内核的开销，
- （定时）只使用timerfd_*系列函数来处理定时任务
  - 不涉及信号（多线程里的信号是个麻烦事），
  - 精度很高，精度比select/poll/epoll的timeout更高（timeout的精度只有毫秒）
  - timerfd_create把时间变为一个文件描述符，该“文件”超时的那一刻变为可读，很容易融入select/poll框架中，用统一的方式来处理IO事件和超时事件，这正是Reactor模式的长处

#### 用timing wheel踢掉空闲连接

本节介绍如何使用timing wheel来踢掉空闲的连接。一个连接如果若干秒没有收到数据，就被认为是空闲连接。本文的代码见 。

在严肃的网络程序中，应用层的心跳协议是必不可少的。应该用心跳消息来判断对方进程是否能正常工作，“踢掉空闲连接”只是一时的权宜之计。我这里想顺便讲讲shared_ptr和weak_ptr的用法。

如果一个连接连续几秒（后文以8s为例）内没有收到数据，就把它断开，为此有两种简单、粗暴的做法：

- 每个连接保存“最后收到数据的时间lastReceiveTime”，然后用一个定时器，每秒遍历一遍所有连接，断开那些(now - connection.lastReceiveTime)＞8s的connection。这种做法全局只有一个repeated timer，不过**每次timeout都要检查全部连接**，如果连接数目比较大（几千上万），这一步可能会比较费时。
- 每个连接设置一个one-shot timer，超时定为8s，在超时的时候就断开本连接。当然，每次收到数据要去更新timer。这种做法**需要很多个one-shot timer，会频繁地更新timers**。如果连接数目比较大，可能对EventLoop的TimerQueue造成压力。

**使用timing wheel能避免上述两种做法的缺点**。timing wheel可以翻译为“时间轮盘”或“刻度盘”，本文保留英文。

连接超时不需要精确定时，只要大致8秒超时断开就行，多一秒、少一秒关系不大。处理连接超时可用一个简单的数据结构：8个桶组成的循环队列。第1个桶放1秒之后将要超时的连接，第2个桶放2秒之后将要超时的连接。每个连接一收到数据就把自己放到第8个桶，然后在每秒的timer里把第一个桶里的连接断开，把这个空桶挪到队尾。这样大致可以做到8秒没有数据就超时断开连接。更重要的是，每次不用检查全部的连接，只要检查第一个桶里的连接，相当于把任务分散了。

simple timing wheel的基本结构是一个**循环队列**，还有一个指向队尾的指针（tail），这个指针每秒移动一格，就像钟表上的时针，timing wheel由此得名。

timing wheel中的每个格子是个hash set，可以容纳不止一个连接。

除了timing wheel另外一个思路是“选择排序”：使用链表将TcpConnection串起来，TcpConnection每次收到消息就把自己移到链表末尾，这样链表是按接收时间先后排序的。再用一个定时器定期从链表前端查找并踢掉超时的连接（直到当前连接未超时或到达链表末尾）。代码示例位于同一目录。

## 第8章 muduo网络库设计与实现

本章从零开始逐步实现一个类似muduo的基于Reactor模式的C++网络库，大体反映了muduo网络相关部分的开发过程。本章大致分为三段，为了与代码匹配，本章的小节从0开始编号。注意本章呈现的代码与现在muduo的代码略有出入。

1. §8.0至§8.3介绍Reactor模式的现代C++实现，包括EventLoop、Poller、Channel、TimerQueue、EventLoopThread等class；
2. §8.4至§8.9介绍基于Reactor的单线程、非阻塞、并发TCP server网络编程，主要介绍Acceptor、Socket、TcpServer、TcpConnection、Buffer等class；
3. §8.10至§8.13是提高篇，介绍one loop per thread的实现（用EventLoopThreadPool实现多线程TcpServer），Connector和TcpClient class，还有用epoll(4)替换poll(2)作为Poller的IO multiplexing机制等。

本章的代码位于recipes/reactor，会直接使用muduo/base中的日志、线程等基础库。

### 8.0 什么都不做的EventLoop

首先定义EventLoop class的基本接口：构造函数、析构函数、loop()成员函数。注意EventLoop是不可拷贝的，因此它继承了boost::noncopyable。muduo中的大多数class都是不可拷贝的，因此以后只会强调某个class是可拷贝的。

### 8.1 Reactor的关键结构

本节讲Reactor最核心的事件分发机制，即将IO multiplexing拿到的IO事件分发给各个文件描述符（fd）的事件处理函数。

### 8.2 TimerQueue定时器

有了前面的Reactor基础，我们可以给EventLoop加上定时器功能。传统的Reactor通过控制select(2)和poll(2)的等待时间来实现定时，而现在在Linux中有了timerfd，我们可以用和处理IO事件相同的方式来处理定时，代码的一致性更好。

### 8.3 EventLoop::runInLoop()函数

EventLoop有一个非常有用的功能：在它的IO线程内执行某个用户任务回调，即`EventLoop::runInLoop(const Functor& cb)`，其中`Functor是boost::function<void()>`。如果用户在当前IO线程调用这个函数，回调会同步进行；如果用户在其他线程调用runInLoop()，cb会被加入队列，IO线程会被唤醒来调用这个Functor。

### 8.4 实现TCP网络库

到目前为止，Reactor事件处理框架已初具规模，从本节开始我们用它逐步实现一个非阻塞TCP网络编程库。从poll(2)返回到再次调用poll(2)阻塞称为一次事件循环。图8-3值得印在脑中，它有助于理解一次循环中各种回调发生的顺序。

![20200215101034.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200215101034.png)

传统的Reactor实现一般会把timers做成循环中单独的一步，而muduo把它和IO handlers等同视之，这是使用timerfd的附带效应。将来有必要时也可以在调用IO handlers之前或之后处理timers。

后面几节的内容安排如下：

§8.4介绍Acceptor class，用于accept(2)新连接。

§8.5介绍TcpServer，处理新建TcpConnection。

§8.6处理TcpConnection断开连接。

§8.7介绍Buffer class并用它读取数据。

§8.8介绍如何无阻塞发送数据。

§8.9完善TcpConnection，处理SIGPIPE、TCP keep alive等。

至此，单线程TCP服务端网络编程已经基本成型，大部分muduo示例都可以运行。

### 8.10 多线程TcpServer

本章的最后几节介绍三个主题：多线程TcpServer、TcpClient、epoll(4)，主题之间相互独立。

本节介绍多线程TcpServer，用到了EventLoopThreadPool class。
EventLoopThreadPooll

用one loop per thread的思想实现多线程TcpServer的关键步骤是在新建TcpConnection时从**event loop pool里挑选一个loop给TcpConnection用**。也就是说多线程TcpServer自己的EventLoop**只用来接受新连接**，而新连接会用其他EventLoop来执行IO。（单线程TcpServer的EventLoop是与TcpConnection共享的。）muduo的event loop pool由EventLoopThreadPool class表示

### epoll

epoll(4)是Linux独有的高效的IO multiplexing机制，它与poll(2)的不同之处主要在于poll(2)每次返回整个文件描述符数组，用户代码需要遍历数组以找到哪些文件描述符上有IO事件（见此处 的Poller::fillActiveChannels()），而epoll_wait(2)返回的是活动fd的列表，需要遍历的数组通常会小得多。在并发连接数较大而活动连接比例不高时，epoll(4)比poll(2)更高效。

## 第9章 分布式系统工程实践

本章谈的分布式系统是指运行在公司防火墙以内的信息基础设施（infrastructure），用于对外（客户）提供联机信息服务，不是针对公司员工的办公自动化系统。服务器的硬件平台是多核Intel x86-64处理器、几十GB内存、千兆网互联、常规存储、运行Linux操作系统。系统的规模大约在几十台到几百台，可以位于一个机房，也可以位于全球的多个数据中心。只有两台机器的双机容错（热备）系统不是本章的讨论范围。服务程序是普通的Linux用户进程，进程之间通过TCP/IP通信。特别是，本章不考虑分布式存储系统，只考虑分布式即时计算

### 我们在技术浪潮中的位置

- 单机服务端编程问题已经基本解决

  编写高吞吐、高并发、高性能的服务端程序的技术已经成熟。无论是程序设计还是性能调优，都有成熟的办法。在分布式系统中，单机表现出来就是一个网口（§9.7.3），能收发消息，至于它内部用什么语言什么编程模型都是次要的。在满足性能要求的前提下，应该用尽量简单直接的编程方式。单机的技术热点不在于提高性能，而在于解放程序员的生产力，例如牺牲少许性能，用更易于开发的语言。

- 在编程模型方面，分布式对象已被淘汰

  准确地说是远程对象，对象位于另一个进程（可能运行在另一台机器上），程序就像操作本地对象一样通过成员函数调用来使用远程服务。这种模型的本质难点在于容错语义。假设对象所在的机器坏了怎么办？已经发起但尚未返回的调用到底有没有成功？推荐Google的好文《Introduction to Distributed System Design》

- 大规模分布式系统处于技术浪潮的前期

  大家都在摸索中前进，尚未形成一套完整的方法论。某些领域相对成熟一些（分布式非结构化存储、离线数据处理等），有一些开源的组件。但更多更本质的问题（正确性、可靠性、可用性、容错性、一致性）尚没有一套行之有效的方法论来指导实践，有的只是一些相对零散的经验。有人开玩笑说：“我不知道哪种方法一定能行，但是知道哪些方法是行不通的。”这或许正是我们这一阶段的真实写照，分布式系统开发还处于“摸着石头过河”阶段。

#### 分布式系统的本质困难

Jim Waldo等人写的《A Note on Distributed Computing》 20 一针见血地指出分布式系统的本质困难在于partial failure。

拿我们熟悉的单机和分布式做个对比，初看起来，分布式系统很像是放大了的单机。一台机器通过总线把CPU、内存、扩展卡（网卡和磁盘控制器）连到一起，一个分布式系统通过网络把服务进程连到一起，网络就是总线。这种看法对吗？单机和分布式的区别究竟在哪里？能不能按照编写单机程序的思路来设计分布式系统？

分布式系统不是放大了的单机系统，根本原因在于单机没有**部分故障（partial failure**）一说。对于单机，我们能轻易判断某个进程、某个硬件是否还在正常工作。而在分布式系统中，这是无解的，我们无法及时得知另外一台机器的死活，也无法把机器崩溃与网络故障区分开来。这正是分布式系统与单机的最大区别。

例如一次RPC调用超时，调用方无法区分

- 是网络故障还是对方机器崩溃？
- 软件还是硬件错误？
- 是去的路上出错还是回来的路上出错？
- 对方有没有收到请求，能不能重试？

### 分布式系统的可靠性浅说

本节谈谈我对分布式系统可靠性的理解。要谈可靠性，必须要谈基本指标tMTBF （平均无故障运行时间，单位通常是小时）。tMTBF 与可靠性的关系如下，其中t是系统运行时间。

Realiability = exp(-t/tMTBF)

可靠性与**可用性（availability）**是两码事，可靠性指的是数据不丢失的概率，可用性指的是数据或服务能被随时访问到的概率

#### 分布式系统的软件不要求7×24可靠

运行在一台机器（设备）上的软件的可靠性受限于硬件，如果硬件本身的可靠性不高，那么软件做得再可靠也没有意义。自己开发的软件的可靠性只需要略高于硬件及操作系统即可，即“**不当木桶的短板”**。学软件（计算机科学系）出身的人往往认为硬件不会坏，而学硬件（电子信息系）出身的人一般都认为硬件不会坏才怪。半导体器件是非常娇弱的，宇宙射线的中子和集成电路封装材料中的同位素衰变产生的α-粒子在击中硅片时会释放能量，有可能影响储能器件的“状态”，造成bit翻转。

遇到某些发生概率很小的严重错误事件时，可以直接退出进程，举例来说

- 如果初始化mutex失败，直接退出进程好了，反正程序也无法正确执行下去。
- 一般的程序不必在意内存分配失败，遇到这种情况直接退出即可。一方面是在程序分配内存失败之前，资源监控系统应该已经报警，实施负载迁移；另一方面，如果真遇到std::bad_alloc异常，也没有特别有效的办法来应对。
- 程序也不必考虑磁盘写满，因为在磁盘写满之前，监控系统已经报警。如果是关键业务，必然已经有人采取必要的措施来腾出磁盘空间。

#### “能随时重启进程”作为程序设计目标

既然硬件和软件条件都不需要（不允许）程序长期运行，那么程序在设计的时候必须想清楚重启进程的方式与代价。进程重启大致可分为软硬件故障导致的意外重启与软硬件升级引起的有计划主动重启。无论是哪种重启，都最好让最终用户感觉不到程序在重启。重启耗时应尽量短，中断服务的时间也尽量短，或者最好能做到根本不中断服务。重启进程之后，应该能自动恢复服务，最好避免需要手动恢复。

以上说明，由于不必区分进程的正常退出与异常终止，程序也就不必做到能安全退出，只要能安全被杀即可。这大大简化了多线程服务端编程，我们只需关心正常的业务逻辑，不必为安全退出进程费心。

无论是程序主动调用exit(3)或是被管理员kill(1)，进程都能立即重启。这就要求程序只使用操作系统能自动回收的IPC，不使用生命期大于进程的IPC，也不使用无法重建的IPC。具体说，**只用TCP为进程间通信的唯一手段，进程一退出，连接与端口自动关闭。而且无论连接的哪一方断连，都可以重建TCP连接，恢复通信**。

不要使用跨进程的mutex或semaphore，也不要使用共享内存，因为进程意外终止的话，无法清理资源，特别是无法解锁。另外也不要使用父子进程共享文件描述符的方式来通信（pipe(2)），父进程死了，子进程怎么办？pipe是无法重建的。

意外重启的常见情况及其原因是

- 服务进程本机重启——程序bug或内存耗尽。
- 机器重启——kernel bug，偶然硬件错误。
- 服务进程移机重启——硬件／网络故障。

### 分布式系统中心跳协议的设计

前面提到使用TCP连接作为分布式系统中进程间通信的唯一方式，其好处之一是任何一方进程意外退出的时候对方能及时得到连接断开的通知，因为操作系统会关闭进程使用中的TCP socket，会往对方发送FIN分节（TCP segment）。尽管如此，应用层的心跳还是必不可少的。原因有

- 如果操作系统崩溃导致机器重启，没有机会发送FIN分节。
- 服务器硬件故障导致机器重启，也没有机会发送FIN分节。
- 并发连接数很高时，操作系统或进程如果重启，可能没有机会断开全部连接。换句话说，FIN分节可能出现丢包，但这时没有机会重试。
- 网络故障，连接双方得知这一情况的唯一方案是检测心跳超时。

为什么TCP keepalive不能替代应用层心跳？**心跳除了说明应用程序还活着（进程还在，网络通畅），更重要的是表明应用程序还能正常工作。而TCP keepalive由操作系统负责探查，即便进程死锁或阻塞，操作系统也会如常收发TCP keepalive消息**。对方无法得知这一异常。

心跳协议的基本形式是：如果进程C依赖S，那么S应该按固定周期向C发送心跳，而C按固定的周期检查心跳。换言之，通常是服务端向客户端发送心跳。

举个例子：

心跳的发送很简单，Sender以1秒为周期向Receiver发送心跳消息，而Receiver以1秒为周期检查心跳消息。注意到Sender和Receiver的计时器是独立的，因此可能会出现“发送和检查时机不对齐”情况，这是完全正常的。

心跳的检查也很简单，**如果Receiver最后一次收到心跳消息的时间与当前时间之差超过某个timeout值**，那么就判断对方心跳失效。例如Sender所在的机器在Ts ＝11.5时刻崩溃，Receiver在Tr ＝12时刻检查心跳是正常的，在Tr ＝13时刻发现过去timeout秒之内没有收到心跳消息，于是判断心跳失效（图9-8）。注意到这距离实际发生崩溃的时刻已过去了1.5秒，这是不可避免的延迟。**分布式系统没有全局瞬时状态**，不存在立刻判断对方故障的方法，这是分布式系统的本质困难

![20200215105648.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200215105648.png)

如果要保守一些，可以在连续两次检查都失效的情况下认定Sender已无法提供服务，但这种方法发现故障的延迟比前一种方法要多一个检查周期。这反映了心跳协议的内在矛盾：高置信度与低反应时间不可兼得。

现在的问题是如何确定发送周期、检查周期、timeout这三个值。通常Sender的发送周期和Receiver的检查周期相同，均为Tc ；而timeout＞Tc ，timeout的选择要能容忍网络消息延时波动和定时器的波动。图9-9中Ts ＝12.1发出的消息由于网络延迟波动，错过了检查点，如果timeout过小，会造成误报。

![20200215105755.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200215105755.png)

尽管发送周期和检查周期均为Tc ，但无法保证每个检查周期内恰好收到一条心跳，有可能一条也没有收到。因此为了避免误报（false alarm），通常可取timeout＝2Tc 。

Tc 的选择要平衡两方面因素：**Tc 越小，Sender和Receiver单位时间内处理的心跳消息越多，开销越大；Tc 越大，Receiver检测到故障的延迟也就越大**。在故障延迟敏感的场合，可取Tc ＝1s，否则可取Tc ＝10s。总结一下心跳的判断规则：**如果最近的心跳消息的接收时间早于now－2Tc ，可判断心跳失效**。

心跳消息应该包含发送方的标识符，可按§9.4的方式确定分布式系统中每个进程的唯一标识符。

以上是Sender和Receiver直接通过TCP连接发送心跳的做法，如果Sender和Receiver之间有其他消息中转进程，那么还应该在心跳消息中加上Sender的发送时间，防止消息在传输过程中堆积而导致假心跳（见图9-10）。相应的判断规则改为：**如果最近的心跳消息的发送时间早于now－2Tc ，心跳失效**。使用这种方式时，两台机器的时间应该都通过NTP协议与时间服务器同步，否则几秒的时钟差可能造成误判心跳失效，因为Receiver始终收到的是“过去”发送的消息。

![20200215111401.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200215111401.png)

考虑到闰秒的影响，Tc 小于1秒是无意义的，因为闰秒会让两台机器的相对时差发生跳变，可能造成误报警，如图9-11所示。

![20200215111804.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200215111804.png)

心跳协议还有两个关键点，为了防止伪心跳

1. 要在工作线程发送，不要单独起一个“心跳线程”：防止工作线程死锁或阻塞时还在继续发心跳
2. 与业务消息用同一个连接，不要单独用“心跳连接”：心跳消息的作用之一是验证网络畅通，如果它验证的不是收发业务数据的TCP连接畅通，那其意义就大为缩水了。特别要避免用TCP做业务连接，用UDP发送心跳消息，防止一旦TCP业务连接上出现消息堆积而影响正常业务处理时，程序还一如既往地发送UDP心跳，造成客户端误认为服务可用。

### 分布式系统中的进程标识

本节假定一台机器（host）只有一个IP，不考虑multihome的情况。同时假定分布式系统中的每一台机器都正确运行了NTP，各台机器的时间大体同步。

“进程（process）”是操作系统的两大基本概念之一，指的是在内存中运行的程序。

本节所指的“进程标识符”是用来**唯一标识一个程序的“一次运行”**的。每次启动一个进程，这个进程应该被赋予一个唯一的标识符，与当前正在运行的所有进程都不同；不仅如此，它应该与历史上曾经运行过，目前已消亡的进程也都不同（这两条的直接推论是，与将来可能运行的进程也都不同）。“为每个进程命名”在分布式系统中有相当大的实际意义，特别是在考虑failover的时候。因为一个程序重启之后的新进程和它的“前世进程”的状态通常不一样，凡是与它打交道的其他进程(s)最好能通过它的进程标识符变更来很容易地判断该程序已经重启，而采取必要的救灾措施，防止搭错话。

#### 错误做法

在分布式系统中，如何指涉（refer to）某一个进程呢，或者说一个进程如何取得自己的全局标识符（以下简称gpid）？容易想到的有两种做法：

- ip:port（port一般指对外服务的listening port）
- host:pid

如果进程本身是无状态的，那么重启也没关系，用ip:port来标识一个服务是可以的。但是如果服务是由状态的，那就有很大关系了。

host:pid也不是个好方法，因为**pid的状态空间很小，重复的概率较大**，比如Linux的pid最大值默认是32768，虽然pid是递增的，但是机器运行很久后pid可能遇到上限再回到目前空闲的最小pid，这样是由可能重复pid的

用一个足够强的随机数做gpid，虽然不会重复，但是gpid本身无意义，不便于管理和维护，比方说根据gpid找到是哪个机器上运行的哪个进程

#### 正确做法

正确做法：以四元组`ip:port:start_time:pid`作为分布式系统中进程的gpid，其中start_time是64-bit整数，表示进程的启动时刻（UTC时区，从Unix Epoch到现在的微秒数，muduo::Timestamp）。理由如下：

- 容易保证唯一性。如果程序短时间重启，那么两个进程的pid必定不重复（还没有走完一个轮回：就算每秒创建1000个进程，也要30多秒才会轮回，而以这么高的速度创建进程的话，服务器已基本瘫痪了。）；如果程序运行了相当长一段时间再重启，那么两次启动的start_time必定不重复。
- 产生这种gpid的成本很低（几次低成本系统调用），没有用到全局服务器，不存在single point of failure。
- gpid本身有意义，根据gpid立刻就能知道是什么进程（port），运行在哪台机器（IP），是什么时间启动的，在/proc目录中的位置（/proc/pid）等，进程的资源使用情况也可以通过运行在那台机器上的监控程序报告出来。
- gpid具有历史意义，便于将来追溯。比方说进程crash，那么我知道它的gpid，就可以去历史记录中查询它crash之前的CPU和内存负载有多大。

进一步，还可以把程序的名称和版本号作为gpid的一部分，这起到锦上添花的作用。

有了唯一的gpid，那么生成全局唯一的消息id字符串也十分简单，只要在进程内使用一个**原子计数器**，用计数器递增的值和gpid即可组成每个消息的全局唯一id。这个消息id本身包含了发送者的gpid，便于追溯。当消息被传递到多个程序中，也可以根据gpid追溯其来源。

#### TCP协议的启示

本节讲的这个gpid其实是由TCP协议启发而来的。TCP用ip:port来表示endpoint，两个endpoint构成一个socket。这似乎符合一开始提到的以ip:port来标识进程的做法。其实不然。在发起TCP连接的时候，为了防止前一次同样地址的连接的干扰（称为wandering duplicates，即流浪的packets），TCP协议使用seq号码（这种在SYN packet里第一次发送的seq号码称为**initial sequence number，ISN**）来区分本次连接和以往的连接。TCP的这种思路与我们防止进程的“前世”干扰“今生”很相像。内核每次新建TCP连接的时候会设法**递增ISN以确保与上次连接最后使用的seq号码不同**。相当于说把start_time加入到了endpoint之中，这就很接近我们后面提到的“正确的gpid”做法了。

###　构建易于维护的分布式程序

本节标题中的“易于维护”指的是supportability，不是maintainability。前者是从运维人员的角度说，程序管理起来很方便，日常的劳动负担小；后者是从开发人员的角度说，代码好读好改。

分布式系统中的每个长期运行的、会与其他机器打交道的进程都应该提供一个管理接口，对外提供一个维修探查通道，可以查看进程的全部状态。一种具体的做法是在程序里**内置HTTP服务器**，能查看基本的进程健康状态与当前负载，包括活动连接及其用途。

### 为系统演化做准备

可扩展的消息格式，避免协议的版本号，避免通过TCP连接发送C struct或使用bit fields（不易升级、不夸语言），采用某种中间语言来描述消息格式，推荐Google Protocol Buffers

### 分布式程序的自动化回归测试

### 分布式系统部署、监控与进程管理的几重境界

## 第10章 C++编译链接模型精要

C++要与C兼容，不仅兼容语法，更重要的事兼容C的编译模型与运行模型，也就是说能**直接使用C的头文件和库**

图10-1表明了Linux上编译一个C++程序的典型过程。其中最耗时间的是cc1plus这一步，在一台正在编译C++项目的机器上运行top(1)，排在首位的往往就是这个进程。

![20200215115428.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200215115428.png)

值得指出的是，图10-1中各个阶段的界线并不是铁定的。通常cpp和cc1plus会合并成一个进程；而cc1plus和as之间既可以以临时文件（*.s）为中介，也可以以管道（pipe）为中介；对于单一源文件的小程序，往往不必生成.o文件。另外，linker还有一个名字叫做link editor。

在不同的语境下，“编译”一词有不同的含义。如果笼统地说把.cc文件“编译”为可执行文件，那么指的是preprocessor/compiler/assembler/linker这四个步骤。如果区分“编译”和“链接”，那么“编译”通常指的是从源文件生成目标文件这几步（即g++ -c）。如果进一步区分预处理、编译（代码转换）、汇编，那么编译器实际看到的是预处理器完成头文件替换和宏展开之后的源代码。

**C++至今（包括C++11）没有模块机制**，不能像其他现代编程语言那样用import或using来引入当前源文件用到的库（含其他package/module里的函数或类），而必须用include头文件的方式来机械地将库的接口声明以文本替换的方式载入，再重新parse一遍。这么做一方面让编译效率奇低，编译器动辄要parse几万行预处理之后的源码，哪怕源文件只有几百行；另一方面，也留下了巨大的隐患。部分原因是头文件包含具有传递性，引入不必要的依赖。但这是为了兼容C而不得不作出的妥协

比如有一个简单的小程序，只用了printf(3)，却不得不包含stdio.h，把其他不相关的函数、struct定义、宏、typedef、全局变量等等也统统引入到当前命名空间。

值得一提的是，为了兼容C语言，C++付出了很大的代价。例如要兼容C语言的隐式类型转换规则（例如整数类型提升），这让C++的**函数重载决议（overload resolution）**规则变得无比复杂。

### C语言的编译模型及其成因

基本都是些历史

### C++的编译模型

#### 单遍继承

C++也继承了单遍编译。在单遍编译时，编译器只能根据目前看到的代码做出决策，读到后面的代码也不会影响前面做出的决定。这特别影响了**名字查找（name lookup）**和**函数重载决议**。

先说名字查找，C++中的名字包括类型名、函数名、变量名、typedef名、template名等等。比方说对下面这行代码

```c++
Foo<T> a; // Foo、T、a这三个名字都不是macro
```

如果不知道Foo、T、a这三个名字分别代表什么，编译器就无法进行语法分析。根据之前出现的代码不同，上面这行语句至少有三种可能性：

1. Foo是个`template<typename X> class Foo;`，T是type，那么这句话以T为模板类型参数类型具现化了`Foo<T>`类型，并定义了变量a。
2. Foo是个`template<int X> class Foo;`，T是constint变量，那么这句话以T为非类型模板参数具现化了`Foo<T>`类型，并定义了变量a。
3. Foo、T、a都是int，这句话是个没啥用的表达式语句。

别忘了operator<()是可以重载的，这句简单代码还可以表达别的意思。另外一个经典的例子是AA BB(CC);，这句话既可以声明函数，也可以定义变量。

C++只能通过解析源码来了解名字的含义，不能像其他语言那样通过直接读取目标代码中的元数据来获得所需信息（函数原型、class类型定义等等）。这意味着要想准确理解一行C++代码的含义，我们需要通读这行代码之前的所有代码，并理解每个符号（包括操作符）的定义。而头文件的存在使得肉眼观察几乎是不可能的。完全有可能出现一种情况：某人不经意改变了头文件，或者仅仅是改变了源文件中头文件的包含顺序，就改变了代码的含义，破坏了代码的功能。这时能造成编译错误已经是谢天谢地了。

C++编译器的符号表至少要保存目前已看到的每个名字的含义，包括class的成员定义、已声明的变量、已知的函数原型等，才能正确解析源代码。这还没有考虑template，编译template的难度超乎想象。编译器还要正确处理作用域嵌套引发的名字的含义变化：内层作用域中的名字有可能遮住[…]

再说**函数重载决议** ，当C++编译器读到一个函数调用语句时，它必须（也只能）从目前已看到的同名函数中选出最佳函数。**哪怕后面的代码中出现了更合适的匹配，也不能影响当前的决定**。这意味着如果我们交换两个namespace级的函数定义在源代码中的位置，那么有可能改变程序的行为。

对于下面的代码，如果把void bar()的定义挪到void foo(char)之后，程序的输出就不一样了

```c++
void foo(int){ printf("foo(int);\n"); }
void bar(){ foo('a'); }
void foo(char){ printf("foo(char);\n"); }
int main(){
  bar();
}
```

其实由于C++新增了不少语言特性，C++编译器并不能真正做到像C那样过眼即忘的单遍编译。但是C++必须兼容C的语意，因此编译器不得不装得好像是单遍编译（准确地说是单遍parse）一样，哪怕它内部是multiple pass的

#### 前向声明（对函数or类的前向声明）

几乎每份C++编码规范 44 45 46 都会建议尽量使用前向声明来减少编译期依赖，这里我用“单向编译”来解释一下这为什么是可行的，很多时候甚至是必需的。

如果代码里调用了函数foo()，C++编译器parse此处函数调用时，需要生成函数调用的目标代码。为了完成语法检查并生成调用函数的目标代码，编译器需要知道函数的参数个数和类型以及函数的返回值类型，它并不需要知道函数体的实现（除非要做inline展开）。因此我们通常把函数原型放到头文件里，这样每个包含了此头文件的源文件都可以使用这个函数。这是每个C/C++程序员都明白的事情。

当然，光有函数原型是不够的，程序其中某一个源文件应该定义这个函数，否则会造成链接错误（未定义的符号）。这个定义foo()函数的源文件通常也会包含foo()的头文件。但是，假设在定义foo()函数时把参数类型写错了，会出现什么情况？

```c++
// in foo.h
void foo(int); // 原型声明
// in foo.cc
#include "foo.h"
void foo(int, bool){}
```

编译foo.cc会有错吗？不会，因为编译器会认为foo有两个重载。但是**链接**整个程序会报错：找不到void foo(int)的定义。你有没有遇到过类似的问题？

这是C++的一种典型缺陷，即一样东西区分声明和定义，代码放到不同的文件中，这就有出现不一致的可能性。C/C++里很多稀奇古怪的错误就源自于此，比如[ExpC]举的一个经典例子：在一个源文件里声明extern char* name，在另一个源文件里却定义成char name[]＝"Shuo Chen";。

函数原型声明可以看作是对函数的**前向声明（forward declaration）**，除此之外我们还常常用到class的前向声明。

有些时候class的前向声明是必需的。有些时候class的完整定义是必需的[CCS，条款22] ，例如要访问class的成员，或者要知道class的大小以便分配空间。其他时候，有class的前向声明就足够了，编译器只需要知道有这么个名字的class。

### C++链接（linking）

好比一本书中的章节有交叉引用，即正文里会出现“请参考第X页第X章第X节”，因为可能随时调整章节顺序、增减篇幅，这都会影响最终出现的页数和章节。所以为了引用，要在文字中放anchor（LATEX是\label），需要引用时注明要引用的anchor（LATEX中式\ref{ch:cppCompilation}

传统one-pass链接器的工作方式，在使用这种链接器的时候要注意参数顺序，**越基础的库越放到后面**。如果程序用到了多个library，这些library之间有依赖（假设不存在循环依赖），那么链接器的参数顺序应该是依赖图的拓扑排序。这样保证每个未决符号都可以在后面出现的库中找到。比如A、B两个彼此独立的库同时依赖C库，那么链接的顺序是ABC或BAC。

为什么这个规定不是反过来，先列出基础库，再列出应用库呢？原因是前一种做法的**内存消耗要小得多**。如果先处理基础库，链接器不知道库里哪些符号会被后面的代码用到，因此只能每一个都记住，链接器的内存消耗跟所有库的大小之和成正比。反过来，如果先处理应用库，那么只需要记住目前尚未查到定义的符号就行了。链接器的内存消耗跟程序中外部符号的多少成正比。

以上简要介绍了C语言的链接模型，C++与之相比主要增加了两项内容：

- 函数重载，需要类型安全的链接 ，即name mangling
- vague linkage，即同一个符号有多份互不冲突的定义。

name mangling的事情一般不需要程序员操心，只要掌握**extern "C"**的用法，能和C程序库interoperate就行。何况现在一般的C语言库的头文件都会适当使用extern "C"，使之也能用于C++程序(对于加了extern "C"的函数，编译器要用C的规则去翻译函数，因为C没有函数重载，不会翻译函数参数)。

C语言通常一个符号在程序中只能有一处定义，否则就会造成重复定义。C++则不同，编译器在处理单个源文件的时候并不知道某些符号是否应该在本编译单元定义。为了保险起见，只能每个目标文件生成一份“**弱定义**”，而依赖链接器去选择一份作为最终的定义，这就是vague linkage。不这么做的话就会出现未定义的符号错误，因为链接器通常不会聪明到反过来调用编译器去生成未定义的符号

#### 函数重载

众所周知，为了实现函数重载，C++编译器普遍采用**名字改编（name mangling**）的办法，**为每个重载函数生成独一无二的名字**，这样在链接的时候就能找到正确的重载版本。比如foo.cc里定义了两个foo()重载函数。

注意普通non-template函数的mangled name不包含返回类型。记得吗，**返回类型不参与函数重载**。

这其实有一个小小的隐患，也是“C++典型缺陷”的一个体现。如果一个源文件用到了重载函数，但它看到的函数原型声明的返回类型是错的，**链接器无法捕捉这样的错误**。

#### inline函数

于inline函数的关系，C++源代码里**调用一个函数并不意味着生成的目标代码里也会做一次真正的函数调用（可能看不到call指令）**。现在的编译器聪明到可以自动判断一个函数是否适合inline，因此inline关键字在源文件中往往不是必需的。当然，在头文件里inline还是要的，为了防止链接器抱怨重复定义（multiple definition）。现在的C++编译器采用重复代码消除的办法来避免重复定义。也就是说，如果编译器无法inline展开的话，每个编译单元都会生成inline函数的目标代码，然后链接器会从多份实现中任选一份保留，其余的则丢弃（vague linkage）。如果编译器能够展开inline函数，那就不必单独为之生成目标代码了（除非使用函数指针指向它）。

除了inline函数，g++还有大量的**内置函数（built-in function）**，因此源代码中出现memcpy、memset、strlen、sin、exp之类的“函数调用”不一定真的会调用libc里的库函数。另外，由于编译器知道这些函数的功能，因此优化起来更充分。例如muduo日志库就使用了内置strchr()函数在编译期求出文件的basename。

#### 模板

C++模板包括函数模板和类模板，与链接相关的话题包括：

- 函数定义，包括具现化后的函数模板、类模板的成员函数、类模板的静态成员函数等。
- 变量定义，包括函数模板的静态数据变量、类模板的静态数据成员、类模板的全局对象等。

按照C++模板的具现化规则，编译器会为每一个用到的类模板成员函数**具现化一份实体**。这样看来真的造成了代码膨胀，但实际情况并不一定如此，如果我们用-O2编译一下，会发现编译器把这些短函数都inline展开了。

#### 虚函数

在现在的C++实现中，虚函数的动态调用（动态绑定、运行期决议）是通过**虚函数表（vtable）**进行的，每个多态class都应该有一份vtable。定义或继承了虚函数的对象中会有一个隐含成员：指向vtable的指针，即vptr。在构造和析构对象的时候，编译器生成的代码会修改这个vptr成员，这就要用到vtable的定义（使用其地址）。因此我们有时看到的链接错误不是抱怨找不到某个虚函数的定义，而是**找不到虚函数表的定义**。例如：

![20200215151712.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200215151712.png)

出现这种错误的根本原因是程序中某个虚函数没有定义，知道了这个方向，查找问题就不难了。
另外，按道理说，一个多态class的vtable应该恰好被某一个目标文件定义，这样链接就不会有错。但是C++编译器有时无法判断是否应该在当前编译单元生成vtable定义 63 ，为了保险起见，只能每个编译单元都生成vtable，交给链接器[…]

### 工程项目中头文件的使用规则

既然短时间内C++还无法摆脱头文件和预处理，因此我们要深入理解可能存在的陷阱。在实际项目中，有必要规范头文件和预处理的用法，避免它们的危害。一旦为了使用某个struct或者某个库函数而包含了一个头文件，那么这个头文件中定义的其他名字（struct、函数、宏）也被引入当前编译单元，有可能制造麻烦。

#### 头文件的害处

我认为头文件的害处主要体现在以下几方面：

- 传递性。头文件可以再包含其他头文件。一方面造成编译缓慢；另一方面，任何一个头文件改动一点点代码都会需要重新编译所有直接或间接包含它的源文件。

- 顺序性。一个源文件可以包含多个头文件。如果头文件内容组织不当，会造成程序的语义跟头文件包含的顺序有关，也跟是否包含某一个头文件有关。

- 差异性。内容差异造成不同源文件看到的头文件不一致，时间差异造成头文件与库文件内容不一致。例如§12.7提到不同的编译选项会造成Visual C++ std::string的大小不一样。说明整个程序应该用统一的编译选项。如果程序用到了第三方静态库或者动态库，除了拿到头文件和库文件，我们还要拿到当时编译这个库的编译选项，才能安全无误地使用这个程序库。

反观现代的编程语言，它们比C++的历史包袱轻多了，**模块化**做得也比较好。模块化的做法主要有两种：

- 对于解释型语言，import的时候直接把对应模块的源文件解析（parse）一遍（不再是简单地把源文件包含进来）。
- 对于编译型语言，编译出来的目标文件（例如Java的.class文件）里直接包含了足够的元数据，import的时候只需要读目标文件的内容，不需要读源文件。

这两种做法都避免了声明与定义不一致的问题，因为在这些语言里声明与定义是一体的。同时这种import手法也不会引入不想要的名字，大大简化了名字查找的负担（无论是人脑还是编译器），也不用担心import的顺序不同造成代码功能变化。

#### 头文件的使用规则

- “将文件间的编译依赖降至最小。”[EC3，条款31]
- “将定义式之间的依赖关系降至最小。避免循环依赖。”[CCS，条款22]
- “让class名字、头文件名字、源文件名字直接相关。” 70 这样方便源代码的定位。muduo源码遵循这一原则，例如TcpClient class的头文件是TcpClient.h，其成员函数定义在TcpClient.cc。
- “令头文件自给自足。”[CCS，条款23] 例如要使用muduo的TcpServer，可以直接包含TcpServer.h。为了验证TcpServer.h的自足性（self-contained），TcpServer.cc第一个包含的头文件就是它。
- “总是在头文件内写内部#include guard（护套），不要在源文件写外部护套。”[CCS，条款24] 这是因为现在的预处理对这种通用做法有特别的优化，GNU cpp在第二次#include同一个头文件时甚至不会去读这个文件，而是直接跳过
- #include guard用的宏的名字应该包含文件的路径全名（从版本管理器的角度），必要的话还要加上项目名称（如果每个项目有自己的代码仓库） 72 。
- 如果编写程序库，那么公开的头文件应该表达模块的接口，必要的时候可以把实现细节放到内部头文件中。muduo的头文件满足这条规则。

### 工程项目中库文件的组织原则

改动程序本身或它依赖的库之后应该重新测试，否则测试通过的版本和实际运行的版本根本就是两个东西。一旦出了问题，责任就难理清了。

这个问题对于C++之外的语言也同样存在，我认为凡是可以在编译之后替换库的语言都需要考虑类似的问题。对于脚本语言来说，除了库之外，解释器的版本（Python2.5/2.6/2.7）也会影响程序的行为，因此有Pythonvirtualenv和Rubyrbenv这样的工具，允许一台机器同时安装多个解释器版本。Java程序的行为除了跟class path里的那些jar文件有关，也跟JVM的版本有关，通常我们不能在没有充分测试的情况下升级JVM的大版本（从1.5到1.6）。

另外一个需要考虑的是C++标准库（libstdc++）的版本与C标准库（glibc）的版本。C++标准库的版本跟C++编译器直接关联，我想一般不会有人去替换系统的libstdc++。C标准库的版本跟Linux操作系统的版本直接相关，一般也没有人单独升级glibc，因为这基本上意味着要重新编译用户态的所有代码。为了稳妥起见，通常**建议用Linux发行版自带的那个gcc版本来编译你的代码**。因为这个版本的gcc是Linux发行版主要支持的编译器版本，当前kernel和用户态的其他程序也基本是它编译的，如果它有什么问题的话，早就被人发现了。

**Linux的共享库（shared library）**比Windows的动态链接库在C++编程方面要好用得多，对应用程序来说基本可算是透明的，跟使用静态库无区别。主要体现在：

- 一致的内存管理。**Linux动态库与应用程序共享同一个heap**，因此动态库分配的内存可以交给应用程序去释放，反之亦可。
- 一致的初始化。动态库里的静态对象（全局对象、namespace级的对象等等）的初始化和程序其他地方的静态对象一样，不用特别区分对象的位置。
- 在动态库的接口中可以放心地使用class、STL、boost（如果版本相同）。

一个C++库的发布方式有三种：动态库（.so）、静态库（.a）、源码库（.cc）

![20200215154139.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200215154139.png)

按照传统的观点，动态库比静态库节省磁盘空间和内存空间，并且具备动态更新的能力（可以hot fix bug），似乎动态库应该是目前的首选。但是正是这种动态更新的能力让动态库成了烫手的山芋。

#### 动态库是有害的

Jeffrey Richter对动态库的本质问题有精辟的论述：

> 一旦替换了某个应用程序用到的动态库，**先前运行正常的这个程序使用的将不再是当初build和测试时的代码**。结果是程序的行为变得不可预期。怎样在fix bug和增加feature的同时，还能保证不会损坏现有的应用程序？我（Jeffrey Richter）曾经对这个问题思考了很久，并且得出了一个结论——那就是这是不可能的。

作为库的作者，你肯定不希望更新部署一个看似有益无害的bug fix之后，星期一早上被应用程序的维护者的电话吵醒，说程序不能启动（新的库破坏了二进制兼容性）或者出现了不符合预期的行为。

作为应用程序的作者，你也肯定不希望星期一一大早被运维的同事吵醒，说你负责的某个服务进程无法启动或者行为异常。经排查，发现只有某一个动态库的版本与上星期不同。你该朝谁发火呢？

既然双方都不想过这种提心吊胆的日子，那为什么还要用动态库呢？

#### 静态库也好不到哪里去

静态库相比动态库有几个好处

- 依赖管理在编译期决定，不用担心日后它用的库会变。同理，调试core dump不会遇到库更新导致debug符号失效的情况。
- 运行速度可能更快，因为没有PLT（过程查找表），函数调用的开销更小。
- 发布方便，只要把单个可执行文件拷贝到模板机器上。

静态库的一个小缺点是链接比动态库慢

静态库的作者把源文件编译成.a库文件，连同头文件一起打包发布。应用程序的作者用库的头文件编译自己的代码，并链接到.a库文件，得到可执行文件。这里有一个编译的**时间差**：编译库文件比编译可执行文件要早，这就可能造成编译应用程序时看到的头文件与编译静态库时不一样。比如编译net1.1时用的是boost 1.34，但是编译xyz这个应用程序时用的是boost 1.40，而xyz依赖net1.1，这就造成了编译错误，甚至更糟糕地导致不可预期的结果

这说明应用程序在使用静态库的时候必须要采用完全相同的开发环境（更底层的库、编译器版本、编译器选项）

静态库把库之间的版本依赖完全放到编译期，这比动态库要省心得多，但是仍然不是一件容易的事情。下面略举几种可能遇到的情况：

- 迫使升级高版本。假设一开始应用程序app 1.0依赖net 1.0和hub 1.0，一切正常。在开发app 1.1的时候，我们要用到net 1.1的功能。但是hub 1.0仍然依赖net 1.0，hub库的作者暂时没有升级到net 1.1的打算。如果不小心的话，就会造成hub 1.0链接到net 1.1。这就跟编译hub 1.0的环境不同了，hub 1.0的行为不再是经过充分测试的。

- 重复链接。如果Makefile编写不当，有可能出现hub 1.0继续链接到net 1.0，而应用程序则链接到net 1.1的情况。这时如果net库里有internal linkage的静态变量，可能造成奇怪的行为，因为同一个变量现在有了两个实体，违背了ODR。

- 版本冲突。比方说app升级到1.2版，想加入一个库cab 1.0，但是cab 1.0依赖net 1.2。这时我们的问题是，如果用net 1.1，则不满足cab 1.0的需求；如果用net 1.2，则不满足hub 1.1的需求。那该怎么办？

#### 源码编译才是王道

每个应用程序自己选择要用到的库，并自行编译为单个可执行文件。彻底避免头文件与库文件之间的时间差，确保整个项目的源文件采用相同的编译选项，也不用为库的版本搭配操心。这么做的缺点是编译时间很长，因为把各个库的编译任务从库文件的作者转嫁到了每个应用程序的作者。

另外，最好能和源码版本工具配合，让应用程序只需指定用哪个库，build工具能自动帮我们check out库的源码。这样库的作者只需要维护少数几个branch，发布库的时候不需要把头文件和库文件打包供人下载，只要push到特定的branch就行。而且这个build工具最好还能解析库的Makefile（或等价的build script），自动帮我们解决库的传递性依赖，就像Apache Ivy能做的那样。

在目前看到的开源build工具里，最接近这一点的是Chromium的gyp和腾讯的typhoon-blade，其他如SCons、CMake、Premake、Waf等等工具仍然是以库的思路来搭建项目。

### 总结

**由于C++的头文件与源文件分离**，并且目标文件里没有足够的元数据供编译器使用，因此必须**同时提供库文件和头文件**。也就是说要想使用一个已经编译好的C/C++库（无论是静态库还是动态库），我们需要两样东西，一是头文件（.h），二是库文件（.a或.so），这就存在了这两样东西不匹配的可能。这是造就C++简陋脆弱的模块机制的根本原因。C++库之间的依赖管理远比其他现代语言复杂，在编写程序库和应用程序时，要熟悉各种机制的优缺点，采用开发及维护成本较低的方式来组织和发布库。

## 第11章 反思C++面向对象与虚函数

### 程序库的二进制兼容性

作为C++程序员，只要工作涉及二进制的程序库（特别是动态库），都需要了解二进制兼容性方面的知识。

C/C++的**二进制兼容性（binary compatibility）**有多重含义，本文主要在“库文件单独升级，现有可执行文件是否受影响”这个意义下讨论，我称之为library（主要是shared library，即动态链接库）的**ABI（application binary interface）**

### 避免使用虚函数作为库的接口

### 动态库接口的推荐做法

### 以boost::function和boost::bind取代虚函数

### iostream的用途与局限

#### stdio格式化输入输出的缺点

- 输入与输出的格式字符串不一致
- 输入的参数不统一，传入scanf需要取地址符&
- 缓冲区溢出的危险

snprintf()能够指定输出缓冲区大小的函数，安全

#### iostream的设计初衷——可扩展

可扩展有两层意思：一是可以扩展到用户自定义类型（类型可扩展），二是通过集成iostream来定义自己的stream（功能可扩展）

#### iostream与标准库其他组件的交互

“值语义”与“对象语义”

不同于标准库其他class的“**值语义（value semantics）**”，iostream是“**对象语义（object semantics）**” ，即iostream是non-copyable。这是正确的，因为如果fstream代表一个打开的文件的话，拷贝一个fstream对象意味着什么呢？表示打开了两个文件吗？如果销毁一个fstream对象，它会关闭文件句柄，那么另一个fstream对象副本会因此受影响吗？

iostream禁止拷贝，**利用对象的生命期来明确管理资源（如文件）**，很自然地就避免了这些问题。这就是RAII，一种重要且独特的C++编程手法。

#### iostream在使用方面的缺点

- 格式化输出很繁琐：iostream采用manipulator来格式化
- 外部可配置性很差：C stdio的格式化字符串体现了重要的“数据就是代码”的思想，所以更加灵活
- iostream的状态：会影响后面的代码，而printf是上下文无关的
- 通用性：C++的iostream只此一家，而printf风格的格式化其他语言也具备
- **线程安全与原子性**：iostream在线程方面没有保证，`cout<<a<<b`就是两次函数调用，两次调用中间可能会被打断进行上下文切换，造成输出不连续，很有可能其他线程打印的字符插入其中。因此，**iostream并不适合在多线程做logging**

iostream在实际项目的应用大大受限

#### iostream在设计方面的缺点

iostream是个面向对象的IO类库，使用了多重继承和虚拟继承，看下面的类图，这是明显的菱形继承，iostream继承自istream与ostream，而这两个又都继承自ios

#### iostream小结

在C++项目中，自己写个File class，把项目用到的文件IO功能简单封装一下（以RAII手法封装FILE*或者file descriptor都可以，视情况而定），通常就能满足需要。记得**把拷贝构造和赋值操作符禁用**，**在析构函数里释放资源**，避免泄露内部的handle，这样就能自动避免很多C语言文件操作的常见错误。

如果要用stream方式做logging，可以抛开繁重的iostream，自己写一个简单的LogStream，重载几个operator<<操作符，用起来一样方便；而且可以用stack buffer，轻松做到线程安全与高效

### 值语义与数据抽象

#### 什么是值语义

**值语义（value semantics）**指的是对象的拷贝与原对象无关，就像拷贝int一样。C++的内置类型（bool/int/double/char）都是值语义，标准库里的complex<>、pair<>、vector<>、map<>、string等等类型也都是值语意，拷贝之后就与原对象脱离关系

与值语义对应的是“**对象语义（object semantics）**”，或者叫做引用语义（reference semantics），由于“引用”一词在C++里有特殊含义，所以我在本文中使用“对象语义”这个术语。对象语义指的是面向对象意义下的对象，对象拷贝是禁止的。例如muduo里的Thread是对象语义，拷贝Thread是无意义的，也是被禁止的：因为Thread代表线程，拷贝一个Thread对象并不能让系统增加一个一模一样的线程。

同样的道理，拷贝一个Employee对象是没有意义的，一个雇员不会变成两个雇员，他也不会领两份薪水。拷贝TcpConnection对象也没有意义，系统中只有一个TCP连接，拷贝TcpConnection对象不会让我们拥有两个连接。Printer也是不能拷贝的，系统只连接了一个打印机，拷贝Printer并不能凭空增加打印机。凡此总总，面向对象意义下的“对象”是non-copyable。

值语义的对象不一定是POD，例如string就不是POD，但它是值语义的。

值语义的对象不一定小，例如`vector<int>`的元素可多可少，但它始终是值语义的。当然，很多值语义的对象都是小的，例如complex<>、muduo::Date、muduo:: Timestamp。

#### 值语义与生命期

值语义的一个巨大好处是生命期管理很简单，就跟int一样——你不需要操心int的生命期。值语义的对象要么是stack object，要么直接作为其他object的成员，因此我们不用担心它的生命期（一个函数使用自己stack上的对象，一个成员函数使用自己的数据成员对象）。相反，对象语义的object由于不能拷贝，因此我们只能通过指针或引用来使用它。

一旦使用指针和引用来操作对象，那么就要担心所指的对象是否已被释放，这一度是C++程序bug的一大来源。此外，由于**C++只能通过指针或引用来获得多态性**，那么在C++里从事基于继承和多态的面向对象编程有其本质的困难——对象生命期管理（资源管理）。

比如parent和child，parent has a child, child has a parent，一个很直接但是易错的方法如下：

```c++
class Child;
class Parent : boost::noncopyable
{
  Child* myChild;
};
class Child : boost::noncopyable
{
  Parent* myParent;
};
```

如果直接使用指针作为成员，那么如何确保指针的有效性？如何防止出现空悬指针？Child和Parent由谁负责释放？在释放某个Parent对象的时候，如何确保程序中没有指向它的指针？那么释放某个Child对象的时候呢？

这一系列问题一度是C++面向对象编程头疼的问题，不过现在有了smart pointer，我们可以借助smart pointer把对象语义转换为值语义，从而轻松解决对象生命期问题：让Parent持有Child的smart pointer，同时让Child持有Parent的smart pointer，这样始终引用对方的时候就不用担心出现空悬指针。当然，**其中一个smart pointer应该是weak reference，否则会出现循环引用**，导致内存泄漏。到底哪一个是weak reference，则取决于具体应用场景。

考虑一个稍微复杂一点的对象模型：“a Child has parents: mom and dad; a Parent has one or more Child(ren); a Parent knows his/her spouse.”如何才能避免出现空悬指针，同时避免出现内存泄漏呢？借助shared_ptr把裸指针转换为值语义，我们就不用担心这两个问题了：

![20200216101315.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200216101315.png)

所以智能指针是真的很有用

#### 值语义与标准库

C++要求凡是能放入标准容器的类型必须具有值语义。准确地说：type必须是SGIAssignable concept的model。但是，由于C++编译器会为class默认提供copy constructor和assignment operator，因此除非明确禁止，否则class总是可以作为标准库的元素类型——尽管程序可以编译通过，但是隐藏了资源管理方面的bug。

因此，在写一个C++ class的时候，让它默认继承boost::noncopyable，几乎总是正确的。

在现代C++中，一般不需要自己编写copy constructor或assignment operator，因为只要每个数据成员都具有值语义的话，编译器自动生成的member-wise copying& assigning就能正常工作；如果以smart ptr为成员来持有其他对象，那么就能自动启用或禁用copying & assigning。例外：编写HashMap这类底层库时还是需要自己实现copy control。

#### 值语义与C++语言

C++的class设计（妥协）如下：

- class的layout与C struct一样，没有额外的开销。定义一个“只包含一个int成员的class”的对象开销和定义一个int一样。
- 甚至class data member都默认是uninitialized，因为函数局部的int也是如此。
- class可以在stack上创建，也可以在heap上创建。因为int可以是stack variable。
- class的数组就是一个个class对象挨着，没有额外的indirection。因为int数组就是这样的。因此派生类数组的指针不能安全转换为基类指针。
- 编译器会为class默认生成copy constructor和assignment operator。其他语言没有copy constructor一说，也不允许重载assignment operator。C++的对象默认是可以拷贝的，这是一个尴尬的特性。
- 当class type传入函数时，默认是make a copy（除非参数声明为reference）。因为把int传入函数时是make a copy。

这些设计带来性能上的好处，原因是**memory locality**，C++内存模型要紧凑得多

#### 什么是数据抽象

**数据抽象（data abstraction）**是与**面向对象（object-oriented）**并列的一种**编程范式（programming paradigm）**。说“数据抽象”或许显得陌生，它的另外一个名字“抽象数据类型（abstract data type，ADT）”想必如雷贯耳。支持数据抽象”一直是C++语言的设计目标。

数据抽象就是ADT，主要表现为它所支持的操作，如stack::push()、stack::pop()，这些操作具有明确的时间和空间复杂度，另外，ADT可以隐藏实现细节，比如stack既可以用动态数组又可以用链表实现。数据抽象适合封装数据，语义简单，容易使用。

C++标准库里complex<>、pair<>、vector<>、list<>、map<>、set<>、string、stack、queue都是数据抽象的例子

面向对象真正核心的思想是**消息传递（messaging）**，“封装、继承、多态”只是表象。关于这一点，孟岩和王益都有精彩的论述，笔者不再赘言。

## 第12章 C++经验谈

### 用异或来交换变量是错误的

版本一：用临时变量交换两个数是很简单的，这也是简洁高效的

```c++
void reverse_by_swap(char* str, int n){
    char* begin = str;
    char* end = str + n - 1;
    while(begin < end){
        char temp = *begin;
        *begin = *end;
        *end = temp;
        ++begin;
        --end;
    }
}
```

版本二：用异或是非常fancy，非常花里胡哨的做法，它并不比版本一快，因为查看汇编代码，发现它的指令更多

```c++
void reverse_by_swap(char* str, int n){
    char* begin = str;
    char* end = str + n - 1;
    while(begin < end){
        *begin ^= *end;
        *end ^= *begin;
        *begin ^=*end;
        ++begin;
        --end;
    }
}

版本三：用STL中的reverse算法，不用担心调用函数的开销，编译器会把reverse自动内联展开，生成的优化汇编代码与版本一一样快

```c++
void reverse_by_swap(char* str, int n){
  std::reverse(str, str + n);
}
```

### 不要重载全局::operator new()

#### 内存管理的基本要去

如果只考虑分配和释放，内存管理基本要求是“不重不漏”：既不重复delete，也不漏掉delete。也就是说我们常说的new/delete要配对，**“配对”不仅是个数相等，还隐含了new和delete的调用本身要匹配**，不要“东家借的东西西家还”。例如：

- 用系统默认的malloc()分配的内存要交给系统默认的free()去释放。
- 用系统默认的new表达式创建的对象要交给系统默认的delete表达式去析构并释放。
- 用系统默认的new[]表达式创建的对象要交给系统默认的delete[]表达式去析构并释放。
- 用系统默认的::operator new()分配的内存要交给系统默认的::operator delete()去释放。
- 用placement new创建的对象要用placement delete（为了表述方便，姑且这么说吧）去析构（其实就是直接调用析构函数）。
- 从某个内存池A分配的内存要还给这个内存池。
- 如果定制new/delete，那么要按规矩来。见《Effective C++中文版（第3版）》[EC3]第8章“定制new和delete”。

### 带符号整数的除法与余数

### 在单元测试中mock系统调用

### 慎用匿名namespace

匿名namespace（anonymous namespace或称unnamed namespace）是C++语言的一项非常有用的功能，其主要目的是**让该namespace中的成员（变量或函数）具有独一无二的全局名称**，避免**名字碰撞（name collisions）**。一般在编写.cpp文件时，如果需要写一些小的helper函数，我们常常会放到匿名namespace里。

我最近在工作中遇到并重新思考了这一问题，发现匿名namespace并不是多多益善。

####　C语言的static关键字的两种用法

C语言的static关键字有两种用途：

1. 用于函数内部修饰变量，即函数内的静态变量。这种变量的生存期长于该函数，使得函数具有一定的“状态”。使用静态变量的函数一般是不可重入的，也不是线程安全的
2. 用在文件级别（函数体之外），修饰变量或函数，表示该变量或函数，表示该变量或函数只在本文件可见，其他文件看不到、也访问不到该变量或函数

#### C++语言的static关键字的四种用法

由于C++引入了class，在保持与C语言兼容的同时，static关键字又有了两种新用法：

1. 用于修饰class的数据成员，即所谓“**静态成员**”。这种数据成员的生存期大于class的对象（实体／instance）。静态数据成员是每个class有一份，普通数据成员是每个instance有一份，因此也分别叫做class variable和instance variable。
2. 用于修饰class的成员函数，即所谓“**静态成员函数**”。这种成员函数只能访问class variable和其他静态程序函数，不能访问instance variable或instance method。

当然，这几种用法可以相互组合，比如C++的成员函数（无论static还是instance）都可以有其局部的静态变量（上面的用法1）。对于class template和function template，其中的static对象的真正个数跟template instantiation（模板具现化）有关，相信学过C++模板的人不会陌生。

可见在C++里static被overload了多次。匿名namespace的引入是为了减轻static的负担，它替换了static的第2种用途。也就是说，在C++里不必使用文件级的static关键字，我们可以用匿名namespace达到相同的效果

#### 匿名namespace的不便之处

在工程实践中，匿名namespace有两大不利之处：

1. 匿名namespace中的函数是“匿名”的，那么在确实需要引用它的时候就比较麻烦。
2. 使用某些版本的g++时，同一个文件**每次编译出来的二进制文件会变化**。

```c++
namespace{
  void foo(){

  }
}
int main(){
  foo();
}
```

总而言之，匿名namespace没什么大问题，使用它也不是什么过错。万一它碍事了，可以用普通具名namespace替代之。

### 采用有利于版本管理的代码格式

**版本管理（version controlling）**是每个程序员的基本技能，C++程序员也不例外。版本管理的基本功能之一是追踪代码变化，让你能清楚地知道代码是如何一步步变成现在的这个样子的，以及每次check-in都具体改动了哪些内部。无论是传统的集中式版本管理工具，如Subversion，还是新型的分布式管理工具，如Git/Hg，比较**两个版本（revision）**的差异都是其基本功能，即俗称“做一下diff”。

所谓“有利于版本管理”，就是指在代码中合理使用换行符，对diff工具友好，让diff的结果清晰明了地表达代码的改动。diff一般以行为单位，也可以以单词为单位，本文只考虑最常见的**逐行比较（diff by lines）**。

#### 对diff友好的代码格式

- 多行注释也用//，不用/* */

- 一行代码只定义一个变量（我觉得要根据情况而定

- 函数声明中的参数若大于3个，那么在逗号后换行，这样每个参数占一行

- 函数调用时的参数若大于3个，则把实参分行写

- class初始化列表也遵循一行一个的原则

  > 类成员是按照它们在类里被声明的顺序进行初始化的，和它们在成员初始化列表中列出的顺序没一点关系。对一个对象的所有成员来说，它们的析构函数被调用的顺序总是和它们在构造函数里被创建的顺序相反。

- Google的C++编程规范明确指出，namespace不增加缩进 26 。这么做非常有道理，方便diff -p把函数名显示在每个diff chunk的头上。

- public与private，我认为这是C++语法的一个缺陷，如果我把一个成员函数从public区移到private区，那么从diff上看不出来我干了什么

#### 对grep友好的代码风格

#### 一切为了效率

### 再探std::string

Scott Meyers在《Effective STL》[ESTL]第15条提到std::string有多种实现方式，归纳起来有三类，而每类又有多种变化。

1. 无特殊处理（eager copy），采用类似std::vector的数据结构。现在很少有实现采用这种方式。
2. Copy-on-Write（COW）。g++的std::string一直采用这种方式实现。
3. 短字符串优化（SSO），利用string对象本身的空间来存储短字符串。Visual C++用的是这种实现方式。

#### 直接拷贝（eager copy）——针对中等长度字符串

类似std::vector的“三指针”结构。代码骨架（省略模板）如下，数据结构示意图如图12-1所示。eager copy string 1

![20200216131950.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200216131950.png)

对象的大小是3个指针，在32-bit中是12字节，在64-bit中是24字节。eager copy string 2

Eager copy string的另一种实现方式是把后两个成员变量替换成整数，表示字符串的长度和容量，代码骨架如下，数据结构示意图如图12-2所示。

![20200216153020.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200216153020.png)

这种方式没什么改变，size_t和char*是一样大的，但是如果字符串不是很大的话，在64-bit下可以用uint32_t，新的string结构在64-bit是8+4+4=16，比原来的24字节小了点。eager copy string 3

#### 写时复制（copy-on-write）——针对长字符串

string对象里只放一个指针，如图12-4所示。值得一提的是COW对多线程不友好

![20200216151653.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200216151653.png)

![20200216153408.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200216153408.png)

拷贝是O(1)时间，但是拷贝后的第一次operator[]可能是O(n)时间

#### 短字符串优化（SSO）——针对短字符串

string对象比前面两个都大，因为有本地缓冲区（local buffer）。
内存布局如图12-5（左图）所示。如果字符串比较短（通常的阈值是15字节），那么直接存放在对象的buffer里，如图12-5（右图）所示。start指向data.buffer。这里capacity与buffer用联合体union声明，表示共用一块内存。

![20200216153536.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200216153536.png)

![20200216153632.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200216153632.png)

如果字符串超过15字节，那么就变成类似图12-2的eager copy 2结构，start指向堆上分配的空间（见图12-6）。

![20200216153755.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200216153755.png)

短字符串优化的实现方式不止一种，主要区别是把那三个指针／整数中的哪一个与本地缓冲重合。

同样地，如果字符串不是特别大的话，可以用32bit来表示长度和容量，这样在64-bit下会更省空间

### 用STL algorithm轻松解决几道算法面试题

#### 用next_permutation生成排列与组合

生成N个元素的全排列：这是next_permutation()的基本用法，把元素从小到大放好（即字典序最小的排列），然后反复调用next_permutation()就行了。

```c++
  int elements[] = { 1, 2, 3, 4 };
  const size_t N = sizeof(elements)/sizeof(elements[0]);
  std::vector<int> vec(elements, elements + N);

  int count = 0;
  do
  {
    std::cout << ++count << ": ";
    std::copy(vec.begin(), vec.end(),
              std::ostream_iterator<int>(std::cout, ", "));
    std::cout << std::endl;
  } while (next_permutation(vec.begin(), vec.end()));
```

从n个元素中取出m个的所有组合：输出从7个不同元素中取出3个元素的所有组合。思路：对序列{1, 1, 1, 0, 0, 0, 0}做全排列。对于每个排列，输出数字1对应的位置上的元素。代码如下：

```c++
  int values[] = { 1, 2, 3, 4, 5, 6, 7 };
  int elements[] = { 1, 1, 1, 0, 0, 0, 0 };
  const size_t N = sizeof(elements)/sizeof(elements[0]);
  assert(N == sizeof(values)/sizeof(values[0]));
  std::vector<int> selectors(elements, elements + N);

  int count = 0;
  do
  {
    std::cout << ++count << ": ";
    for (size_t i = 0; i < selectors.size(); ++i)
    {
      if (selectors[i])
      {
        std::cout << values[i] << ", ";
      }
    }
    std::cout << std::endl;
  } while (prev_permutation(selectors.begin(), selectors.end()));
```

#### 用unique()去除连续重复空白

题目 　给你一个字符串，要求原地（in-place）把相邻的多个空格替换为一个 39 。例如，输入"a␣␣b"，输出"a␣b"；输入"aaa␣␣␣bbb␣␣"，输出"aaa␣bbb␣"。

这道题目不难，手写的话也就是单重循环，复杂度是O(N)时间和O(1)空间。这里展示用std::unique()的解法，思路很简单：std::unique()的作用是去除相邻的重复元素，我们只要把“重复元素”定义为“两个元素都是空格”即可。注意**所有针对区间的STL algorithm都只能调换区间内元素的顺序，不能真正删除容器内的元素**，因此需要erase。关键代码如下：

```c++
struct AreBothSpaces
{
  bool operator()(char x, char y) const
  {
    return x == ' ' && y == ' ';
  }
};

void removeContinuousSpaces(std::string& str)
{
  std::string::iterator last
    = std::unique(str.begin(), str.end(), AreBothSpaces());
  str.erase(last, str.end());
}
```

#### 用{make,push,pop}_heap()实现多路归并

题目 　用一台4GiB内存的机器对磁盘上的单个100GB文件排序。

这种单机外部排序题目的标准思路是先分块排序，然后多路归并成输出文件。多路归并很容易用heap排序实现，比方说要归并已经按从小到大的顺序排好序的32个文件，我们可以构造一个32元素的min heap，每个元素是`std::pair<Record, FILE*>`。然后每次取出堆顶的元素，将其Record写入输出文件；如果FILE*还可读，就读入一条Record，再向heap中添加`std::pair<Record, FILE*>`。这样当heap为空的时候，多路归并就完成了。注意在这个过程中heap的大小通常会慢慢变小，因为有可能某个输入文件已经全部读完了。
这种方法比传统的二路归并要节省很多遍磁盘读写，假如用教科书上的二路归并来做外部排序 41 ，那么[…]

#### 用partition()实现“重排数组，让奇数位于偶数前面

std::partition()的作用是把符合条件的元素放到区间首部，不符合条件的元素放到区间后部，我们只需把“符合条件”定义为“元素是奇数”就能解决这道题。复杂度是O(N)时间和O(1)空间。为节省篇幅，isOdd()直接做成了函数，而不是函数对象，缺点是有可能阻碍编译器实施inlining。

如果题目要求原本元素的顺序不能改变，则用std::stable_partition()

#### 用lower_bound()查找IP地址所属城市

题目 　已知N个IP地址区间和它们对应的城市名称，写一个程序，能从IP地址找到它所在的城市。注意这些IP地址区间互不重叠。

这道题目的naïve解法是O(N)，借助std::lower_bound()可以轻易做到O(logN)查找，代价是事先做一遍O(N logN)的排序。如果区间相对固定而查找很频繁，这么做是值得的。
