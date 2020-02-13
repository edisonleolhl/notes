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

####　one loop per thread（不是thread per connection)

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
