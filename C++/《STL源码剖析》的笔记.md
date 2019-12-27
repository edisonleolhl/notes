# 庖丁解牛 恢恢乎游刃有余

第 1 章 STL 概论与版本简介
第 2 章 空间配置器（allocator）
第 3 章 迭代器（iterators）概念与 traits 编程技法
第 4 章 序列式容器（sequence containers）
第 5 章 关联式容器（associattive containers）
第 6 章 算法（algorithms）
第 7 章 仿函数（functors，另名 函数对象 function objects）
第 8 章 配接器（adapters）

## Chapter1 STL概论与版本简介

STL的价值在两方面。低层次而言，STL 带给我们一套极具实用价值的零组件，以及一个整合的组织。这种价值就像 MFC 或 VCL 之于 Windows软件开发过程所带来的价值一样，直接而明朗，令大多数人有最立即明显的感受。除此之外 STL还带给我们一个高层次的、以泛型思维（Generic Paradigm）为基础的、系统化的、条理分明的「软件组件分类学（components taxonomy）」。从这个角度来看，STL是个抽象概念库（library of abstract concepts），这些「抽象概念」包括最基础的Assignable（可被赋值）、Default Constructible（不需任何自变量就可建构）、Equality Comparable（可判断是否等同）、LessThan Comparable（可比较大小）、Regular（正规）…，高阶一点的概念则包括 Input Iterator（具输入功能的迭代器）、Output Iterator（具输出功能的迭代器）、Forward Iterator（单向迭代器）、Bidirectional Iterator（双向迭代器）、Random Access Iterator（随机存取迭代器）、Unary Function（一元函数）、Binary Function（二元函数）、Predicate（传回真假值的一元判断式）、Binary Predicate（传回真假值的二元判断式）…，更高阶的概念包括 sequence container（序列式容器）、associative container（关系型容器）…。STL的创新价值便在于具体叙述了上述这些抽象概念，并加以系统化

STL 所实现的，是依据泛型思维架设起来的一个概念结构。这个以抽象概念（abstract concepts）为主体而非以实际类别（classes）为主体的结构，形成了一个严谨的接口标准。在此接口之下，任何组件有最大的独立性，并以所谓迭代器（iterator）胶合起来，或以所谓配接器（adapter）互相配接，或以所谓仿函数（functor）动态选择某种策略（policy 或 strategy）。

STL提供六大组件，彼此可以组合套用：

1. 容器（containers）：各种数据结构，如 vector, list, deque, set, map ，用来存放数据，详见本书 4, 5 两章。从实作的角度看，STL 容器是一种 class template。就体积而言，这一部份很像冰山在海面下的比率。
2. 算法（algorithms）：各种常用算法如 sort, search, copy, erase …，详见第 6 章。从实作的角度看，STL 算法是一种 function template。
3. 迭代器（iterators）：扮演容器与算法之间的胶着剂，是所谓的「泛型指标」，详见第3章。共有五种类型，以及其它衍生变化。从实作的角度看，迭代器是一种将 operator*, operator->, operator++, operator-- 等指标相关操作予以多载化的 class template。所有STL容器都附带有自己专属的迭代器—是的，只有容器设计者才知道如何巡访自己的元素。原生指标（native pointer）也是一种迭代器。
4. 仿函数（functors）/函数对象：行为类似函数，可做为算法的某种策略（policy），详见第 7 章。从实作的角度看，仿函数是一种重载了 operator() 的 class 或class template。一般函数指标可视为狭义的仿函数。
5. 配接器（adapters）：一种用来修饰容器（containers）或仿函数（functors）或迭代器（iterators）接口的东西，详见第 8 章。例如 STL 提供的 queue 和stack ，虽然看似容器，其实只能算是一种容器配接器，因为它们的底部完全借助 deque ，所有动作都由底层的 deque 供应。改变functor接口者，称为function adapter，改变container接口者，称为container adapter，改变iterator接口者，称为iterator adapter。配接器的实作技术很难一言以蔽之，必须逐一分析，详见第 8 章。
6. 配置器（allocators）：负责空间配置与管理，详见第 2 章。从实作的角度看，配置器是一个实现了动态空间配置、空间管理、空间释放的 class template。

图 1-1 显示 STL 六大组件的交互关系。

![《STL源码剖析》的笔记-STLsixcomponents.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8ASTL%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-STLsixcomponents.png)

### 可能令你困惑的C++语法

#### 临时对象的产生与运用

所谓临时对象，就是一种无名对象（unnamed objects）。它的出现如果不在程序员的预期之下（例如任何pass by value/值传递动作都会引发copy动作，于是形成一个临时对象），往往造成效率上的负担 。但有时候刻意制造一些临时对象，却又是使程序干净清爽的技巧。刻意制造临时对象的方法是，在类型名称之后直接加一对小括号，并可指定初值，例如 Shape(3,5) 或 int(8) ，其意义相当于唤起相 应 的constructor且 不 指 定对象 名 称 。 STL 最 常 将 此 技 巧 应 用 于 仿 函 数（functor）与算法的搭配上

#### function call操作符（operator()）

函数调用符号`()`也可以被重载

许多STL算法都提供两个版本，一个用于一般状况（例如排序时以递增方式排列），一个用于特殊状况（例如排序时由使用者指定以何种特殊关系进行排列）。像这种情况，需要使用者指定某个条件或某个策略，而条件或策略的背后由一整组动作构成，便需要某种特殊的东西来代表这「一整组动作」。代表「一整组动作」的，当然是函式。过去 C语言时代，欲将函式当做参数传递，唯有透过函式指标（pointer to function，或称 function pointer）才能达成

但是函式指标有缺点，最重要的是它无法持有自己的状态（所谓区域状态，local states），也无法达到组件技术中的可配接性（adaptability）—也就是无法再将某些修饰条件加诸于其上而改变其状态。为此，STL 算法的特殊版本所接受的所谓「条件」或「策略」或「一整组动作」，都以仿函式形式呈现。所谓仿函式（functor）就是使用起来像函式一样的东西。如果你针对某个 class 进行 operator() 多载化，它就成为一个仿函式。至于要成为一个可配接的仿函式，还需要一些额外的努力（详见第 8 章）。

下面是将operator()重载的例子

```c++
// file: 1functor.cpp
#include <iostream>
using namespace std;
//由于将 operator() 多载化了，因此 plus 成了一个仿函式
template <class T>
struct plus {
    T operator() (const T& x, const T& y) const { return x + y; }
};
//由于将 operator() 多载化了，因此 minus成了一个仿函式
template <class T>
struct minus {
    T operator() (const T& x, const T& y) const { return x - y; }
};
int main()
{
    // 以下产生仿函式对象。
    plus<int> plusobj;
    // 以下使用仿函式，就像使用一般函式一样。
    cout << plusobj(3,5) << endl; // 8
    cout << minusobj(3,5) << endl; // -2
    // 以下直接产生仿函式的暂时对象（第一对小括号），并呼叫之（第二对小括号）。
    cout << plus<int>() (43,50) << endl; // 93
    cout << minus<int>() (43,50) << endl; // -7
}
```

## Chapter2 空间配置器allocator

以STL 的运用角度而言，空间配置器是最不需要介绍的东西，它总是隐藏在一切组件（更具体地说是指容器，container）的背后，默默工作默默付出。但若以 STL的实作角度而言，第一个需要介绍的就是空间配置器，因为整个STL的操作对象（所有的数值）都存放在容器之内，而容器一定需要配置空间以置放数据。不先掌握空间配置器的原理，难免在观察其它 STL 组件的实作时处处遇到挡路石。

因为空间不一定是内存，也可以是磁盘或其他存储媒介，所以不叫内存配置器

### 空间配置器的标准接口

根据 STL 的规范，以下是allocator的必要接口

```c++
//以下各种 type 的设计原由，第三章详述。
allocator::value_type
allocator::pointer
allocator::const_pointer
allocator::reference
allocator::const_reference
allocator::size_type
allocator::difference_type
allocator::rebind
    // 一个嵌套的（nested）class template。class rebind<U> 拥有唯一成员 other ，那是一个 typedef，代表 allocator<U> 。
allocator::allocator()
    // default constructor。
allocator::allocator (const allocator&)
    // copy constructor。
template <class U>allocator:: allocator (const allocator<U>&)
    // 泛化的copy constructor。
allocator::~allocator()
    // default constructor。
pointer allocator:: address (reference x) const
    // 传回某个对象的地址。算式 a.address(x) 等同于 &x 。
const_pointer allocator:: address (const_reference x) const
    // 传回某个 const 对象的地址。算式 a.address(x) 等同于 &x 。
pointer allocator:: allocate (size_type n, cosnt void* = 0)
    // 配置空间，足以储存 n 个 T 对象。第二自变量是个提示。实作上可能会利用它来增进区域性（locality），或完全忽略之。
void allocator:: deallocate (pointer p, size_type n)
    // 归还先前配置的空间。
size_type allocator:: max_size() const
    // 传回可成功配置的最大量。
void allocator:: construct (pointer p, const T& x)
    // 等同于 new(const void*) p) T(x) 。
void allocator:: destroy(pointer p)
    // 等同于 p->~T() 。
```

### 具备次配置力的SGI空间配置器

SGI STL 的 配 置 器 与 众 不 同 ， 也 与 标 准 规 范 不 同 ， 其 名 称 是 alloc 而 非allocator ，而且不接受任何自变量。换句话说如果你要在程序中明白采用SGI 配置器，不能采用标准写法：

```c++
vector<int, std::allocator<int> > iv; // in VC or CB
```

必须这么写：

```c++
vector<int, std::alloc> iv; // in GCC
```

SGI STL allocator未能符合标准规格，这个事实通常不会对我们带来困扰，因为通常我们使用预设的空间配置器，很少需要自行指定配置器名称，而SGI STL的每一个容器都已经指定其预设的空间配置器为 alloc 。例如下面的 vector 宣告：

```c++
template <class T, class Alloc = alloc> // 预设使用 alloc为配置器
class vector { ... };
```

#### SGI 标准的空间配置器，std::allocator（不推荐）

虽然 SGI 也定义有一个符合部份标准、名为 allocator 的配置器，但SGI自己从未用过它，也不建议我们使用。主要原因是效率不彰，只把 C++的 ::operator new 和 ::operator delete 做一层薄薄的包装而已

#### SGI 特殊的空间配置器 ，std::alloc（推荐）

一般我们习惯的C++内存配置操作和释放操作如下

```c++
class Foo { ... };
Foo* pf = new Foo; //配置内存，然后建构对象
delete pf; //将对象解构，然后释放内存
```

new包含两段操作：

- 调用::operator new 配置内存
- 调用Foo::Foo()构造对象内容

delete也包含两段操作

- 调用Foo::~Foo()将对象析构
- 调用::operator delete释放内存

为了精密分工，STL allocator 决定将这两阶段动作区分开来。

- 内存配置动作由 alloc:allocate() 负责
- 内存释放动作由 alloc::deallocate() 负责
- 对象建构动作由 ::construct() 负责
- 对象解构动作由 ::destroy() 负责

![《STL源码剖析》的笔记-stlconstructanddestroy.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8ASTL%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-stlconstructanddestroy.png)

#### construct()和destroy()

#### 空间的配置与释放，std::alloc

考虑小型区块所可能造成的内存破碎问题，SGI 设计了双层级配置器，第一级配置器直接使用 malloc() 和 free() ，第二级配置器则视情况采用不同的策略：当配置区块超过128bytes，视之为「足够大」，便呼叫第一级配置器；当配置区块小于 128bytes，视之为「过小」，为了降低额外负担（overhead，见 2.2.6 节），便采用复杂的memory pool整理方式，而不再求助于第一级配置器。整个设计究竟只开放第一级配置器，或是同时开放第二级配置器，取决于 __USE_MALLOC  是否被定义（唔，我们可以轻易测试出来，SGI STL 并未定义 __USE_MALLOC） ：

>注：__USE_MALLOC 这个名称取得不甚理想，因为无论如何，最终总是使用 malloc()

```c++
# ifdef __USE_MALLOC
...
typedef __malloc_alloc_template <0> malloc_alloc;
typedef malloc_alloc alloc;
# else
...
//令 alloc 为第二级配置器
//令 alloc为第一级配置器
typedef __default_alloc_template<__NODE_ALLOCATOR_THREADS, 0> alloc;
#endif /* ! __USE_MALLOC */
```

其 中 __malloc_alloc_template 就 是 第 一 级 配 置 器 ， __default_alloc_template 就是第二级配置器。稍后分别有详细介绍。再次提醒你注意， alloc 并不接受任何 template 型别参数。

无论 alloc 被定义为第一级或第二级配置器，SGI 还为它再包装一个接口如下，使配置器的接口能够符合 STL规格

```c++
template<class T, class Alloc>
class simple_alloc {
public:
static T * allocate(size_t n)
    { return 0 == n? 0 : (T*) Alloc::allocate(n * sizeof (T)); }
static T * allocate(void)
    { return (T*) Alloc::allocate(sizeof (T)); }
static void deallocate (T *p, size_t n)
    { if (0 != n) Alloc::deallocate(p, n * sizeof (T)); }
static void deallocate(T *p)
    { Alloc::deallocate(p, sizeof (T)); }
};
```

其内部四个成员函式其实都是单纯的转调用，调用传入之配置器（可能是第一级也可能是第二级）的成员函式。这个接口使配置器的配置单位从 bytes转为个别元素的大小（ sizeof(T) ）。SGI STL 容器全都使用这个 simple_alloc 接口，例如：

```c++
template <class T, class Alloc = alloc> // 预设使用 alloc为配置器
class vector {
protected:
// 专属之空间配置器，每次配置一个元素大小
    typedef simple_alloc<value_type, Alloc>data_allocator;
    void deallocate () {
        if (...)
            data_allocator::deallocate(start, end_of_storage - start);
    }
// ...
};
```

两级配置器的关系、接口包装以及实际应用方式如下

![《STL源码剖析》的笔记-stltwoadapators.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8ASTL%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-stltwoadapators.png)

![《STL源码剖析》的笔记-stladaptorinterface.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8ASTL%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-stladaptorinterface.png)

#### 第一级配置器 __malloc_alloc_template 剖析

第一级配置器以malloc（），free（），rea1lc（）等C函数执行实际的内存配置、释放、重配置操作，并实现出类似C++ new-handler的机制。是的，它不能直接运用C++ new-handler机制，因为它并非使用::operator new来配置内存所谓C++ new handler机制是，你可以要求系统在内存配置需求无法被满足时，调用一个你所指定的函数。换句话说，一旦::operator new无法完成任务在丢出 std：bad alloc异常状态之前，会先调用由客端指定的处理例程。该处理例程通常即被称为new-handler

请注意，SGI 第一级配置器的 allocate() 和 realloc() 都是在呼叫 malloc()和 realloc() 不成功后，改呼叫 oom_malloc() 和 oom_realloc() 。后两者都有内循环，不断呼叫「内存不足处理例程」，期望在某次呼叫之后，获得足够的内存而圆满达成任务。但如果「内存不足处理例程」并未被客端设定，oom_malloc() 和 oom_realloc() 便老实不客气地呼叫 __THROW_BAD_ALLOC ，丢出bad_alloc异常讯息，或利用 exit(1) 硬生生中止程序。

#### 第二级配置器 __default_alloc_template 剖析

第二级配置器多了一些机制，避免太多小额区块造成内存的破碎。小额区块带
来的其实不仅是内存破碎而已，配置时的额外负担（overhead）也是一大问题 8 。
额外负担永远无法避免，毕竟系统要靠这多出来的空间来管理内存，如图2-3。
但是区块愈小，额外负担所占的比例就愈大、愈显得浪费。

![《STL源码剖析》的笔记-memorytax.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8ASTL%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-memorytax.png)

SGI第二级配置器的作法是，如果区块够大，超过 128 bytes，就移交第一级配置器处理。当区块小于 128 bytes，则以记忆池（memory pool）管理，此法又称为次层配置（sub-allocation）：每次配置一大块内存，并维护对应之自由串行（free-list）。下次若再有相同大小的内存需求，就直接从free-lists中拨出。如果客端释还小额区块，就由配置器回收到free-lists中—是的，别忘了，配置器除了负责配置，也负责回收。为了方便管理，SGI第二级配置器会主动将任何小额区块的内存需求量上调至8的倍数（例如客端要求 30 bytes，就自动调整为 32bytes），并维护 16 个 free-lists，各自管理大小分别为 8, 16, 24, 32, 40, 48, 56, 64, 72,80, 88, 96, 104, 112, 120, 128 bytes的小额区块。free-lists 的节点结构如下：

```c++
union obj {
    union obj * free_list_link;
    char client_data[1]; /* The client sees this. */
};
```

![《STL源码剖析》的笔记-secondadaptorfreelist.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8ASTL%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-secondadaptorfreelist.png)

#### 空间配置函数allocate()

身 为 一 个 配 置 器 ， __default_alloc_template 拥 有 配 置 器 的 标 准 介 面 函 式
allocate() 。此函式首先判断区块大小，大于 128 bytes 就呼叫第一级配置器，小
于 128 bytes 就检查对应的 free list。如果free list之内有可用的区块，就直接拿来
用，如果没有可用区块，就将区块大小上调至 8 倍数边界，然后呼叫 refill() ，
准备为 free list 重新填充空间。 refill() 将于稍后介绍。

```c++
// n must be > 0
static void * allocate(size_t n)
{
    obj * volatile * my_free_list;
    obj * result;
    // 大于 128 就呼叫第一级配置器
    if (n > (size_t) __MAX_BYTES)
        return(malloc_alloc::allocate (n));
    }
    // 寻找 16 个 free lists 中适当的一个
    my_free_list = free_list + FREELIST_INDEX (n);
    result = *my_free_list;
    if (result == 0) {
        // 没找到可用的 free list ，准备重新填充 free list
        void *r = refill (ROUND_UP(n));
        return r;
    }
    // 调整 free list
    //下节详述
    *my_free_list = result -> free_list_link;
    return (result);
};
```

区块自free list拨出的动作，如图

![《STL源码剖析》的笔记-allocatefunction.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8ASTL%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-allocatefunction.png)

#### 空间释放函数deallocate()

身 为 一 个 配 置 器 ， __default_alloc_template 拥 有 配 置 器 标 准 介 面 函 式deallocate() 。此函式首先判断区块大小，大于 128 bytes 就呼叫第一级配置器，小于 128 bytes 就找出对应的 free list，将区块回收。

```c++
// p 不可以是 0
static void deallocate (void *p, size_t n)
{
    obj *q = (obj *)p;
    obj * volatile * my_free_list;
    // 大于 128 就呼叫第一级配置器
    if (n > (size_t) __MAX_BYTES) {
        malloc_alloc::deallocate (p, n);
        return;
    }
    // 寻找对应的 free list
    my_free_list = free_list + FREELIST_INDEX(n);
    // 调整 free list ，回收区块
    q -> free_list_link = *my_free_list;
    *my_free_list = q;
    }
```

区块回收纳入free list的动作，如图

![《STL源码剖析》的笔记-deallocatefunction.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8ASTL%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-deallocatefunction.png)

#### 重新填充free lists

回头讨论先前说过的 allocate() 。当它发现free list中没有可用区块了，就呼叫refill() 准 备 为free list重 新 填 充 空 间 。 新 的 空 间 将 取 自 记 忆 池 （ 经 由chunk_alloc() 完成）。预设取得20个新节点（新区块），但万一记忆池空间不足，获得的节点数（区块数）可能小于 20

#### 内存池/记忆池（memory pool）

举个例子，见图 2-7，假设程序一开始，客端就呼叫 chunk_alloc(32,20) ，于是malloc() 配置 40个 32bytes区块，其中第 1 个交出，另 19 个交给 free_list[3]维 护 ， 余20 个 留 给 记 忆 池 。 接 下 来 客 端 呼 叫 chunk_alloc(64,20) ， 此 时free_list[7] 空空如也，必须向记忆池要求支持。记忆池只够供应 (32*20)/64=10个 64bytes区块，就把这 10 个区块传回，第 1 个交给客端，余 9个由 free_list[7]维护。此时记忆池全空。接下来再呼叫 chunk_alloc(96, 20) ，此时 free_list[11]空空如也，必须向记忆池要求支持，而记忆池此时也是空的，于是以 malloc() 配置 40+n（附加量）个 96bytes 区块，其中第 1 个交出，另 19 个交给 free_list[11]维护，余 20+n（附加量）个区块留给记忆池……。万一山穷水尽，整个system heap 空间都不够了（以至无法为记忆池注入活水源头）， malloc() 行动失败， chunk_alloc() 就㆕处寻找有无「尚有未用区块，且区块够大」之free lists。找到的话就挖一块交出，找不到的话就呼叫第一级配置器。第一级配置器其实也是使用 malloc() 来配置内存，但它有 out-of-memory处理机制（类似 new-handler 机制），或许有机会释放其它的内存拿来此处使用。如果可以，就成功，否则发出bad_alloc异常。

![《STL源码剖析》的笔记-memorypool.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8ASTL%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-memorypool.png)

SGI STL默认使用第二级配置器

### 内存基本处理工具

STL定义有五个全域函式，作用于未初始化空间上。这样的功能对于容器的实作很有帮助，我们会在第4章容器实作码中，看到它们的吃重演出。前两个函式是 2.2.3节说过，用于建构 的 construct() 和用于解构的 destroy() ，另三个函式是uninitialized_copy(),uninitialized_fill(),uninitialized_fill_n() 10，分别对应于高阶函式 copy() 、 fill() 、 fill_n()— 这些都是 STL 算法，将在第六章介绍。如果你要使用本节的三个低阶函式，应该含入 `<memory>` ，不过SGI 把它们实际定义于 `<stl_uninitialized>` 。

#### 1. uninitialized_copy

```c++
template <class InputIterator, class ForwardIterator>
ForwardIterator uninitialized_copy (InputIterator first, InputIterator last, ForwardIterator result);
```

uninitialized_copy() 使我们能够将内存的配置与对象的建构行为分离开来。如果做为输出目的地的 [result, result+(last-first)) 范围内的每一个迭 代 器 都 指 向 未 初 始 化 区 域 ， 则 uninitialized_copy() 会 使 用copy constructor，为身为输入来源之 [first,last) 范围内的每一个对象产生一份复制品，放进输出范围中。换句话说，针对输入范围内的每一个迭代器 i ，此函式会呼叫 construct(&*(result+(i-first)),*i) ，产生 *i 的复制品，放置于输出范围的相对位置上。式中的 construct() 已于 2.2.3 节讨论过。

如果你有需要实作一个容器， uninitialized_copy() 这样的函式会为你带来很大的帮助，因为容器的全范围建构式（range constructor）通常以两个步骤完成：

- 配置内存区块，足以包含范围内的所有元素。
- 使用 uninitialized_copy() ，在该内存区块上建构元素。

C++标准规格书要求 uninitialized_copy() 具有 "commit or rollback"语意，意思是要不就「建构出所有必要元素」，要不就（当有任何一个copy constructor失败时）「不建构任何东西」。

#### 2. uninitialized_fill

```c++
template <class ForwardIterator, class T>
void uninitialized_fill (ForwardIterator first, ForwardIterator last, const T& x);
```

uninitialized_fill() 也能够使我们将内存配置与对象的建构行为分离开来。如果 [first,last) 范围内的每个迭代器都指向未初始化的内存，那么uninitialized_fill() 会在该范围内产生 x （上式第三参数）的复制品。换句话 说 uninitialized_fill() 会 针 对 操 作 范 围 内 的 每 个 迭 代 器 i ， 呼 叫construct(&*i, x) ，在 i 所指之处产生 x 的复制品。式中的 construct() 已于 2.2.3节讨论过。

和 uninitialized_copy() 一样， uninitialized_fill() 必须具备 "commit orrollback"语意，换句话说它要不就产生出所有必要元素，要不就不产生任何元素。如果有任何一个copy constructor丢出异常（exception）， uninitialized_fill()必须能够将已产生之所有元素解构掉。

#### 3. uninitialized_fill_n

```c++
template <class ForwardIterator, class Size, class T>
ForwardIterator uninitialized_fill_n (ForwardIterator first, Size n, const T& x);
```

uninitialized_fill_n() 能够使我们将内存配置与对象建构行为分离开来。它会为指定范围内的所有元素设定相同的初值。如果 [first, first+n) 范围内的每一个迭代器都指向未初始化的内存，那么uninitialized_fill_n() 会呼叫copy constructor，在该范围内产生 x （上式第三参数）的复制品。也就是说面对 [first,first+n) 范围内的每个迭代器 i ，uninitialized_fill_n() 会呼叫 construct(&*i, x) ，在对应位置处产生 x 的复制品。式中的 construct() 已于 2.2.3 节讨论过。

uninitialized_fill_n() 也具有 "commit or rollback"语意：要不就产生所有必要的元素，否则就不产生任何元素。如果任何一个copy constructor丢出异常（exception）， uninitialized_fill_n() 必须解构已产生的所有元素。

以 下 分 别 介 绍 这 三 个 函 式 的 实 作 法 。 其 中 所 呈 现 的iterators （ 迭 代 器 ） 、value_type() 、 __type_traits 、 __true_type 、 __false_type 、 is_POD_type等实作技术，都将于第三章介绍。

#### 三个函数的实现

##### uninitialized_fill_n

首先是 uninitialized_fill_n() 的源码。本函式接受三个参数：

1. 迭代器 first 指向欲初始化空间的起始处
2. n 表示欲初始化空间的大小
3. x 表示初值

```c++
template <class ForwardIterator, class Size, class T>
inline ForwardIterator uninitialized_fill_n (ForwardIterator first,
Size n, const T&x ) {
    return __uninitialized_fill_n(first, n, x, value_type(first) );
    // 以上，利用 value_type() 取出 first的 value type.
}
```

这个函式的进行逻辑是，首先萃取出迭代器 first 的 value type（详见第三章），
然后判断该型别是否为 POD型别：

```c++
template <class ForwardIterator, class Size, class T, class T1>
inline ForwardIterator __uninitialized_fill_n (ForwardIterator first,
Size n, const T& x, T1*)
{
    // 以下 __type_traits<> 技法，详见 3.7 节
    typedef typename __type_traits <T1>::is_POD_type is_POD;
    return __uninitialized_fill_n_aux(first, n, x, is_POD());
}
```

POD意指 Plain Old Data，也就是纯量型别（scalar types）或传统的 C struct型别。POD型别必然拥有 trivialctor/dtor/copy/assignment函式，因此，我们可以对POD型别采取最有效率的初值填写手法，而对non-POD 型别采取最保险安全的作法：

```c++
//如果 copy construction 等同于 assignment, 而且
// destructor 是 trivial，以下就有效。
//如果是 POD型别，执行流程就会转进到以下函式。这是藉由 function template
//的自变量推导机制而得。
template <class ForwardIterator, class Size, class T>
inline ForwardIterator
__uninitialized_fill_n_aux (ForwardIterator first, Size n,
const T& x, __true_type ) {
    return fill_n (first, n, x); //交由高阶函式执行。见 6.4.2节。
}
// 如果不是 POD 型别，执行流程就会转进到以下函式。这是藉由 function template
//的自变量推导机制而得。
template <class ForwardIterator, class Size, class T>
ForwardIterator
__uninitialized_fill_n_aux (ForwardIterator first, Size n,
const T& x, __false_type ) {
    ForwardIterator cur = first;
    // 为求阅读顺畅，以下将原本该有的异常处理（ exception handling ）省略。
    for ( ; n > 0; --n, ++cur)
        construct(&*cur, x);
    return cur;
}
```

##### uninitialized_copy

下面列出 uninitialized_copy() 的源码。本函式接受三个参数：

- 迭代器 first 指向输入端的起始位置
- 迭代器 last 指向输入端的结束位置（前闭后开区间）
- 迭代器 result 指向输出端（欲初始化空间）的起始处

```c++
template <class InputIterator, class ForwardIterator>
inline ForwardIterator
uninitialized_copy (InputIterator first, InputIterator last,
ForwardIterator result) {
    return __uninitialized_copy(first, last, result,value_type(result) );
    // 以上，利用 value_type() 取出 first的 value type.
}
```

这个函式的进行逻辑是，首先萃取出迭代器 result 的 value type（详见第三章），
然后判断该型别是否为 POD型别：

```c++
template <class InputIterator, class ForwardIterator, class T>
inline ForwardIterator
__uninitialized_copy (InputIterator first, InputIterator last,
ForwardIterator result, T*) {
typedef typename __type_traits<T>::is_POD_type is_POD;
    return __uninitialized_copy_aux(first, last, result, is_POD());
    // 以上，企图利用 is_POD() 所获得的结果，让编译器做自变量推导。
}
```

POD意指 Plain Old Data，也就是纯量型别（scalar types）或传统的 C struct型别。POD型别必然拥有 trivialctor/dtor/copy/assignment函式，因此，我们可以对POD型别采取最有效率的复制手法，而对 non-POD 型别采取最保险安全的作法：

```c++
//如果 copy construction 等同于 assignment, 而且
// destructor 是 trivial，以下就有效。
//如果是 POD型别，执行流程就会转进到以下函式。这是藉由 function template
//的自变量推导机制而得。
template <class InputIterator, class ForwardIterator>
inline ForwardIterator
__uninitialized_copy_aux (InputIterator first, InputIterator last, ForwardIterator result, __true_type ) {
    return copy (first, last, result); //呼叫 STL算法 copy()
}

// 如果是 non-POD型别，执行流程就会转进到以下函式。这是藉由 function template
//的自变量推导机制而得。
template <class InputIterator, class ForwardIterator>
ForwardIterator
__uninitialized_copy_aux (InputIterator first, InputIterator last, ForwardIterator result, __false_type ) {
    ForwardIterator cur = result;
    // 为求阅读顺畅，以下将原本该有的异常处理（ exception handling ）省略。
    for ( ; first != last; ++first, ++cur)
        construct (&*cur, *first); //必须一个一个元素地建构，无法批量进行
    return cur;
}
```

针对 char* 和 wchar_t* 两种型别，可以最具效率的作法 memmove （直接搬移内存内容）来执行复制行为。因此 SGI 得以为这两种型别设计一份特化版本。

```c++
//以下是针对 const char* 的特化版本
inline char*uninitialized_copy (const char* first, const char* last,
char* result) {
memmove (result, first, last - first);
return result + (last - first);
}
//以下是针对 const wchar_t* 的特化版本
inline wchar_t* uninitialized_copy (const wchar_t* first, const wchar_t* last,
wchar_t* result) {
memmove (result, first, sizeof(wchar_t) * (last - first));
return result + (last - first);
}
```

##### uninitialized_fill

下面列出 uninitialized_fill() 的源码。本函式接受三个参数：

- 迭代器 first 指向输出端（欲初始化空间）的起始处
- 迭代器 last 指向输出端（欲初始化空间）的结束处（前闭后开区间）
- x 表示初值

```c++
template <class ForwardIterator, class T>
inline void uninitialized_fill (ForwardIterator first, ForwardIterator last,
const T& x) {
__uninitialized_fill(first, last, x, value_type(first) );
}
```

这个函式的进行逻辑是，首先萃取出迭代器 first 的 value type（详见第三章），然后判断该型别是否为 POD型别：

```c++
template <class ForwardIterator, class T, class T1>
inline void __uninitialized_fill (ForwardIterator first, ForwardIterator last,
const T& x, T1*) {
typedef typename __type_traits<T1>::is_POD_type is_POD;
__uninitialized_fill_aux(first, last, x, is_POD());
}
```

POD意指 Plain Old Data，也就是纯量型别（scalar types）或传统的 C struct型别。POD型别必然拥有 trivialctor/dtor/copy/assignment函式，因此，我们可以对POD型别采取最有效率的初值填写手法，而对non-POD 型别采取最保险安全的作法

```c++
//如果 copy construction 等同于 assignment, 而且
// destructor 是 trivial，以下就有效。
//如果是 POD型别，执行流程就会转进到以下函式。这是藉由 function template
//的自变量推导机制而得。
template <class ForwardIterator, class T>
inline void
__uninitialized_fill_aux (ForwardIterator first, ForwardIterator last,
const T& x, __true_type)
{
    fill (first, last, x); //呼叫 STL算法 fill()
}

// 如果是 non-POD型别，执行流程就会转进到以下函式。这是藉由 function template
//的自变量推导机制而得。
template <class ForwardIterator, class T>
void
__uninitialized_fill_aux (ForwardIterator first, ForwardIterator last,
const T& x, __false_type)
{
    ForwardIterator cur = first;
    // 为求阅读顺畅，以下将原本该有的异常处理（ exception handling ）省略。
    for ( ; cur != last; ++cur)
        construct(&*cur, x);//必须一个一个元素地建构，无法批量进行
}
```

本节三个函式对效率的特殊考虑，以图形显示。

![《STL源码剖析》的笔记-threememoryoperatationfunction.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8ASTL%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-threememoryoperatationfunction.png)

#### Placement new

[推荐阅读](https://www.cnblogs.com/luxiaoxun/archive/2012/08/10/2631812.html)

Placement new 的含义

placement new 是重载 operator new 的一个标准、全局的版本，它不能够被自定义的版本代替（不像普通版本的 operator new 和 operator delete 能够被替换）。

```c++
void *operator new( size_t, void * p ) throw() { return p; }
```

placement new 的执行忽略了 size_t 参数，只返还第二个参数。其结果是允许用户把一个对象放到一个特定的地方，达到调用构造函数的效果。和其他普通的 new 不同的是，它在括号里多了另外一个参数。比如：

```c++
Widget * p = new Widget;                    //ordinary new

pi = new (ptr) int; pi = new (ptr) int;     //placement new
```

括号里的参数 ptr 是一个指针，它指向一个内存缓冲器，placement new 将在这个缓冲器上分配一个对象。Placement new 的返回值是这个被构造对象的地址 (比如括号中的传递参数)。placement new 主要适用于：在对时间要求非常高的应用程序中，因为这些程序分配的时间是确定的；长时间运行而不被打断的程序；以及执行一个垃圾收集器 (garbage collector)。

Placement new只是 operator new 重载的一个版本。它并不分配内存，只是返回指向已经分配好的某段内存的一个指针。因此不能删除它，但需要调用对象的析构函数。

如果你想在已经分配的内存中创建一个对象，使用 new 时行不通的。也就是说 placement new 允许你在一个已经分配好的内存中（栈或者堆中）构造一个新的对象。原型中 void* p 实际上就是指向一个已经分配好的内存缓冲区的的首地址

#### trivial destructor

如果用户不定义析构函数，而是用系统自带的，则说明，析构函数基本没有什么用（但默认会被调用）我们称之为 trivial destructor。反之，如果特定定义了析构函数，则说明需要在释放空间之前做一些事情，则这个析构函数称为 non-trivial destructor。如果某个类中只有基本类型的话是没有必要调用析构函数的，delelte p 的时候基本不会产生析构代码，

在 C++ 的类中如果只有基本的数据类型，也就不需要写显式的析构函数，即用默认析构函数就够用了，但是如果类中有个指向其他类的指针，并且在构造时候分配了新的空间，则在析构函数中必须显式释放这块空间，否则会产生内存泄露，

在 STL 中空间配置时候 destory（）函数会判断要释放的迭代器的指向的对象有没有 trivial destructor（STL 中有一个 has_trivial_destructor 函数，很容易实现检测），如果有 trivial destructor 则什么都不做，如果没有即需要执行一些操作，则执行真正的 destory 函数。

把trivial翻译为“无关痛痒”，也就是说这个destructor是默认的，是无关痛痒的

#### volatile

[谈谈 C/C++ 中的 volatile](https://liam.page/2018/01/18/volatile-in-C-and-Cpp/)

[C/C++ 中 volatile 关键字详解](https://www.cnblogs.com/yc_sunniwell/archive/2010/07/14/1777432.html)

## Chapter3 迭代器（iterators）概念与traits编程技法

迭代器：提供一种方法，俾得依序巡访某个聚合物（容器）所含的各个元素，而又无需曝露该聚合物的内部表述方式。

### 3.1 迭代器设计思维 — STL 关键所在

不论是泛型思维或 STL 的实际运用，迭代器（iterators）都扮演重要角色。STL 的中心思想在于，将数据容器（containers）和算法（algorithms）分开，彼此独立设计，最后再以一帖胶着剂将它们撮合在一起。容器和算法的泛型化，从技术角度来看并不困难，C++ 的 class templates 和 function templates可分别达成目标。如何设计出两者之间的良好胶着剂，才是大难题。以下是容器、算法、迭代器（iterator，扮演黏胶角色）的合作展示。以算法 find()为例，它接受两个迭代器和一个「搜寻标的」：

```c++
//摘自 SGI <stl_algo.h>
template <class InputIterator, class T>
InputIterator find (InputIterator first,
InputIterator last,
const T& value) {
    while (first != last && *first != value)
        ++first;
    return first;
}
```

只要给予不同的迭代器， find() 便能够对不同的容器做搜寻动作：

```c++
// file : 3find.cpp
#include <vector>
#include <list>
#include <deque>
#include <algorithm>
#include <iostream>
using namespace std;
int main()
{
    const int arraySize = 7;
    int ia[arraySize] = { 0,1,2,3,4,5,6 };
    vector <int> ivect(ia, ia+arraySize);
    list <int> ilist(ia, ia+arraySize);
    deque <int> ideque(ia, ia+arraySize); //注意：VC6[x]，未符合标准
    vector<int>::iterator it1 = find (ivect.begin(), ivect.end(), 4);
    if (it1 == ivect.end())
        cout << "4 not found." << endl;
    else
        cout << "4 found. " << *it1 << endl;
    // 执行结果：4 found. 4
    list<int>::iterator it2 =find (ilist.begin(), ilist.end(), 6);
    if (it2 == ilist.end())
        cout << "6 not found." << endl;
    else
        cout << "6 found. " << *it2 << endl;
    // 执行结果：6 found. 6
    deque<int>::iterator it3 = find (ideque.begin(), ideque.end(), 8);
    if (it3 == ideque.end())
        cout << "8 not found." << endl;
    else
        cout << "8 found. " << *it3 << endl;
    // 执行结果：8 not found.
}
```

### 3.2 迭代器 （iterator ） 是一种 smart pointer

迭代器是一种行为类似指针的对象，而指针的各种行为中最常见也最重要的便是内容提领（dereference）和成员取用（member access），因此迭代器最重要的编程工作就是对 operator* 和 operator-> 进行多载化（overloading）工程

为了完成一个针对 List 而设计的迭代器，我们无可避免地曝露了太多 List 实作细节：在 main() 之中为了制作 begin 和 end 两个迭代器，我们曝露了 ListItem ；在 ListIter class之中为了达成 operator++ 的目的，我们曝露了 ListItem 的操作函式 next() 。如果不是为了迭代器， ListItem原本应该完全隐藏起来不曝光的。换句话说，要设计出 ListIter ，首先必须对 List的实作细节有非常丰富的了解。既然这无可避免，干脆就把迭代器的开发工作交给 List 的设计者好了，如此一来所有实作细节反而得以封装起来不被使用者看到。**这正是为什么每一种 STL容器都提供有专属迭代器的缘故**。

### 3.3 迭代器相应型别/类别 （associated types ）

算法之中运用迭代器时，很可能会用到其相应型别（associated type）。什么是相应型别？迭代器所指之物的型别便是其一。假设算法中有必要宣告一个变量，以「迭代器所指对象的型别」为型别，如何是好？毕竟C++只支持sizeof() ，并未支持 typeof() ！即便动用 RTTI 性质中的 typeid() ，获得的也只是型别名称，不能拿来做变量宣告之用。

解决办法是：利用 function template 的**参数推导**（argument deducation）机制。

例如：

```c++
template <class I, class T>
void func_impl(I iter, T t)
{
    T tmp; // 这里解决了问题。T就是迭代器所指之物的型别，本例为 int
    // ... 这里做原本 func()应该做的全部工作
};
template <class I>
inline
void func(I iter)
{
    func_impl( iter,*iter);// func 的工作全部移往 func_impl
}
int main()
{
    int i;
    func(&i);
}
```

我们以 func() 为对外接口，却把实际动作全部置于 func_impl() 之中。由于func_impl() 是一个 function template，一旦被呼叫，编译器会自动进行 template自变量推导。于是导出型别 T ，顺利解决了问题。迭代器相应型别（associated types）不只是「迭代器所指对象的型别」一种而已。根据经验，最常用的相应型别有五种，然而并非任何情况下任何一种都可利用上述的 template自变量推导机制来取得。我们需要更全面的解法。

### 3.4 Traits 编程技法 — STL 源码门钥

迭代器所指物件的型别，称为该迭代器的value type。上述的自变量型别推导技巧虽然可用于 value type，却非全面可用：万一value type必须用于函式的传回值，就束手无策了，毕竟函式的「template 自变量推导机制」推而导之的只是自变量，无法推导函式的回返值型别。

我们需要其它方法。宣告巢状型别似乎是个好主意，像这样：

```c++
template <class T>
struct MyIter{
    typedef T value_type; // 巢状型别宣告（nested type）
    T* ptr;
    MyIter(T* p=0) : ptr(p) { }
    T& operator*() const { return *ptr; }
    // ...
};
template <class I>
typename I::value_type //这一整行是 func的回返值型别
func(I ite)
{ return *ite; }

// ...
MyIter<int> ite(new int(8));
cout << func (ite); //输出：8
```

注意， func() 的回返型别必须加上关键词 typename ，因为 T 是一个 template参数，在它被编译器具现化之前，编译器对 T 一无所悉，换句话说编译器此时并不知道 `MyIter<T>::value_type` 代表的是一个型别或是一个 member function或是一个 data member。关键词 typename 的用意在告诉编译器说这是一个型别，如此才能顺利通过编译。

看起来不错。但是有个隐晦的陷阱：**并不是所有迭代器都是 class type。原生指针就不是**！如果不是 class type，就无法为它定义巢状型别。但 STL（以及整个泛型思维）绝对必须接受原生指标做为一种迭代器，所以上面这样还不够。有没有办法可以让上述的一般化概念针对特定情况（例如针对原生指标）做特殊化处理呢？是的，template partial specialization可以做到。

#### Partial Specialization（偏特化）的意义

如果 class template拥有一个以上的 template参数，我们可以针对其中某个（或数个，但非全部）template参数进行特化工作。换句话说我们可以在泛化设计中提供一个特化版本（也就是将泛化版本中的某些template参数赋予明确的指定）。

假设有一个 class template如下：

```c++
template<typename U, typename V, typename T>
class C { ... };
```

partial specialization的字面意义容易误导我们以为，所谓「偏特化版」一定是对template参数 U 或 V 或 T （或某种组合）指定某个自变量值。事实不然，[Austern99]对于partial specialization的意义说得十分得体：**所谓partial specialization的意思是提供另一份 template定义式，而其本身仍为 templatized**。《泛型技术》一书对 partial specialization 的定义是：**针对（任何）template 参数更进一步的条件限制，所设计出来的一个特化版本**。

由此，面对以下这么一个 class template：

```c++
template<typename T>
class C { ... }; // 这个泛化版本允许（接受）T为任何型别
```

我们便很容易接受它有一个型式如下的partial specialization：

```c++
template<typename T>
class C<T*> { ... }; //这个特化版本仅适用于「T为原生指标」的情况
// 「T为原生指标」便是「T 为任何型别」的一个更进一步的条件限制
```

有了这项利器，我们便可以解决前述「巢状型别」未能解决的问题。先前的问题是，原生指标并非 class，因此无法为它们定义巢状型别。现在，我们可以针对「迭代器之 template自变量为指标」者，设计特化版的迭代器。

#### traits萃取

提高警觉，我们进入关键地带了。下面这个 class template专门用来「萃取」迭代器的特性，而 value type 正是迭代器的特性之一：

```c++
template <class I>
structiterator_traits { // traits 意为「特性」
typedef typename I ::value_type value_type;
};
```

这个所谓的traits，其意义是，如果 I 定义有自己的value type，那么透过这个traits的作用，萃取出来的 value_type 就是 I::value_type 。换句话说如果 I定义有自己的value type，先前那个 func() 可以改写成这样：

```c++
template <class I>
typename iterator_traits<I>::value_type // 这一整行是函式回返型别
func(I ite)
{ return *ite; }
```

但这除了多一层间接性，又带来什么好处？**好处是traits可以拥有特化版本**。现在，我们令 iterator_traites 拥有一个partial specializations 如下：

```c++
template <class T>
struct iterator_traits< T* > { //偏特化版—迭代器是个原生指标
    typedef T value_type;
};
```

于是，原生指标 int* 虽然不是一种 class type，亦可透过traits取其value type。这就解决了先前的问题。但是请注意，针对「指向常数对象的指针（pointer-to- const ）」，下面这个式子得到什么结果：

```c++
iterator_traits<const int*>::value_type
```

获得的是 const int 而非 int 。这是我们期望的吗？我们希望利用这种机制来宣告一个暂时变量，使其型别与迭代器的value type相同，而现在，宣告一个无法 赋 值 （ 因 const 之 故 ） 的 暂 时 变 数 ， 没 什 么 用 ！ 因 此 ， 如 果 迭 代 器 是 个pointer-to- const ，我们应该设法令其value type为一个 non- const 型别。没问题，只要另外设计一个特化版本，就能解决这个问题：

```c++
template <class T>
struct iterator_traits< const T* > { // 偏特化版—当迭代器是个 pointer-to-const
    typedef T value_type; // 萃取出来的型别应该是 T 而非 const T
};
```

现在，不论面对的是迭代器 MyIter ，或是原生指标 int* 或 const int* ，都可以透过traits取出正确的（我们所期望的）value type。图3-1说明traits所扮演的「特性萃取机」角色，萃取各个迭代器的特性。这里所谓的迭代器特性，指的是迭代器的相应型别（associated types）。当然，若要这个「特性萃取机」traits能够有效运作，每一个迭代器必须遵循约定，**自行以巢状型别定义（nested typedef）的方式定义出相应型别（associated types）**。这种一个约定，谁不遵守这个约定，谁就不能相容于 STL 这个大家庭。

根据经验，最常用到的迭代器相应型别有五种：value type, difference type, pointer, reference,iterator catagoly。如果你希望你所开发的容器能与 STL 水乳交融，一定要为你的容器的迭代器定义这五种相应型别。「特性萃取机」traits 会很忠实地将原汁原味榨取出来：

```c++
template <class I>
structiterator_traits {
typedef typename I::iterator_category iterator_category;
typedef typename I::value_type value_type;
typedef typename I::difference_type difference_type;
typedef typename I::pointer pointer;
typedef typename I::reference reference;
};
```

iterator_traits 必须针对传入之型别为 pointer 及 pointer-to-const 者，设计特化版本，稍后数节为你展示如何进行。

#### 3.4.1 迭代器相应型别之一 ：value type

所谓value type，是指迭代器所指对象的型别。任何一个打算与 STL算法有完美搭配的 class，都应该定义自己的 value type 巢状型别，作法就像上节所述。

#### 3.4.2 迭代器相应型别之二 ：difference type

difference type 用来表示两个迭代器之间的距离，也因此，它可以用来表示一个容器的最大容量，因为对于连续空间的容器而言，头尾之间的距离就是其最大容量。如果一个泛型算法提供计数功能，例如 STL的 count() ，其传回值就必须使用迭代器的 difference type：

```c++
template <class I, class T>
typename iterator_traits<I>::difference_type //这一整行是函式回返型别
count (I first, I last, const T& value) {
    typename iterator_traits<I>::difference_type n = 0;
    for ( ; first != last; ++first)
    if (*first == value)
        ++n;
    return n;
}
```

针对相应型别difference type，traits的两个（针对原生指标而写的）特化版本如下，以C++内建的 ptrdiff_t（ 定义于 `<cstddef>` 头文件）做为原生指标的difference type：

```c++
template <class I>
structiterator_traits {
    ...
    typedef typename I::difference_type difference_type;
};

//针对原生指标而设计的「偏特化（ partial specialization ）」版
template <class T>
structiterator_traits<T*> {
    ...
    typedef ptrdiff_t difference_type;
};

//针对原生的 pointer-to- const 而设计的「偏特化（ partial specialization ）」版
template <class T>
struct iterator_traits<const T*> {
    ...
    typedef ptrdiff_t difference_type;
};
```

现在，任何时候当我们需要任何迭代器 I的difference type，可以这么写：`typename iterator_traits<I>::difference_type`

#### 3.4.3 迭代器相应型别之三 ：reference type

从「迭代器所指之物的内容是否允许改变」的角度观之，迭代器分为两种：不允许改变「所指对象之内容」者，称为constant iterators，例如 constint* pic ；允许改变「所指对象之内容」者，称为 mutable iterators，例如 int* pi 。当我们对一个 mutable iterators做提领动作时，获得的不应该是个右值（rvalue），应该是个左值（lvalue），因为右值不允许赋值动作（assignment），左值才允许：

```c++
int* pi = new int(5);
const int* pci = new int(9);
*pi = 7; // 对 mutable iterator 做提领动作时，获得的应该是个左值，允许赋值。
*pci = 1; // 这个动作不允许，因为 pci是个 constant iterator，
// 提领 pci所得结果，是个右值，不允许被赋值。
```

在 C++中，**函式如果要传回左值，都是以by reference的方式进行**，所以当 p 是个 mutable iterators时，**如果其value type是 T ，那么 *p 的型别不应该是 T ，应该是 T&** 。将此道理扩充，如果 p 是一个 constant iterators，其value type是 T ，那么 *p 的型别不应该是 const T ，而应该是 const T& 。这里所讨论的 *p 的型别，即所谓的reference type。实作细节将在下一小节一并展示。

#### 3.4.4 迭代器相应型别之四 ：pointer type

pointers和 references 在 C++中有非常密切的关连。如果「传回一个左值，令它代表 p 所指之物」是可能的，那么「传回一个左值，令它代表 p 所指之物的位址」也一定可以。也就是说我们能够传回一个 pointer，指向迭代器所指之物。这些相应型别已在先前的 ListIter class中出现过：

```c++
Item& operator* () const { return *ptr; }
Item* operator-> () const { return ptr; }
```

Item& 便是 ListIter 的reference type而 Item* 便是其pointer type。

现在我们把 reference type和pointer type 这两个相应型别加入traits内：

```c++
template <class I>
structiterator_traits {
    ...
    typedef typename I::pointer pointer;
    typedef typename I::reference reference;
};

//针对原生指标而设计的「偏特化版（ partial specialization ）」
template <class T>
structiterator_traits<T*> {
    ...
    typedef T* pointer;
    typedef T& reference;
};

//针对原生的 pointer-to- const 而设计的「偏特化版（ partial specialization ）」
template <class T>
structiterator_traits<const T*> {
    ...
    typedef const T* pointer;
    typedef const T& reference;
};
```

#### 3.4.5 迭代器相应型别之五 ：iterator_category

根据移动特性与施行动作，迭代器被分为五类：

- Input Iterator：这种迭代器所指对象，不允许外界改变。只读（read only）。
- Output Iterator：唯写（write only）。
- Forward Iterator：允许「写入型」算法（例如 replace() ）在此种迭代器所形成的区间上做读写动作。
- Bidirectional Iterator：可双向移动。某些算法需要逆向走访某个迭代器区间（例如逆向拷贝某范围内的元素），就可以使用 Bidirectional Iterators。
- Random Access Iterator：前㆕种迭代器都只供应一部份指标算术能力（前三种支持 operator++ ，第四种再加上 operator-- ），第五种则涵盖所有指标算术能力，包括 p+n, p-n, p[n], p1-p2, p1<p2 。

这些迭代器的分类与从属关系，可以图3-2 表示。直线与箭头代表的并非 C++ 的继承关系，而是所谓concept（概念）与refinement（强化）的关系 。

![《STL源码剖析》的笔记-iteratorscategory.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8ASTL%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-iteratorscategory.png)

设计算法时，如果可能，我们尽量针对图3-2中的某种迭代器提供一个明确定义，并针对更强化的某种迭代器提供另一种定义，这样才能在不同情况下提供最大效率。研究STL 的过程中，每一分每一秒我们都要念兹在兹，效率是个重要课题。假设有个算法可接受Forward Iterator，你以Random Access Iterator喂给它，它当然也会接受，因为一个Random Access Iterator必然是一个ForwardIterator（见图 3-2）。但是可用并不代表最佳！

##### 以 advanced()为例

拿 advance() 来说（这是许多算法内部常用的一个函式），此函式有两个参数，迭代器 p 和数值 n ；函式内部将 p 累进 n 次（前进 n 距离）。下面有三份定义，一份针对Input Iterator，一份针对Bidirectional Iterator，另一份针对Random Access Iterator。倒是没有针对ForwardIterator而设计的版本，因为那和针对InputIterator而设计的版本完全一致。

```c++
template <class InputIterator, class Distance>
voidadvance_II (InputIterator& i, Distance n)
{
// 单向，逐一前进
while (n--) ++i; //或写 for ( ; n > 0; --n, ++i );
}

template <class BidirectionalIterator, class Distance>
voidadvance_BI (BidirectionalIterator& i, Distance n)
{
    // 双向，逐一前进
    if (n >= 0)
        while (n--) ++i; //或写 for ( ; n > 0; --n, ++i );
    else
        while (n++) --i; //或写 for ( ; n < 0; ++n, --i );
}

template <class RandomAccessIterator, class Distance>
voidadvance_RAI (RandomAccessIterator& i, Distance n)
{
    // 双向，跳跃前进
    i += n;
}
```

现在，当程序呼叫 advance() ，应该选用（呼叫）哪一份函式定义呢？如果选择advance_II() ，对Random Access Iterator而言极度缺乏效率，原本O(1)的操作竟成为O(N)。如果选择 advance_RAI() ，则它无法接受Input Iterator。我们需要将三者合一，下面是一种作法：

```c++
template <class InputIterator, class Distance>
voidadvance (InputIterator& i, Distance n)
{
    if (is_random_access_iterator(i))
        advance_RAI(i, n); // 此函式有待设计
    else if (is_bidirectional_iterator (i))
        advance_BI(i, n); // 此函式有待设计
    else
        advance_II(i, n);
}
```

但是像这样在执行时期才决定使用哪一个版本，会影响程序效率。最好能够在编译期就选择正确的版本。多载化函式机制可以达成这个目标。前述三个 advance_xx() 都有两个函式参数，型别都未定（因为都是 template参数）。为了令其同名，形成多载化函式，我们必须加上一个型别已确定的函式参数，使函式多载化机制得以有效运作起来。设计考虑如下：如果traits有能力萃取出迭代器的种类，我们便可利用这个「迭代器类型」相应型别做为 advanced() 的第三参数。这个相应型别一定必须是个class type，不能只是数值号码类的东西，因为编译器需仰赖（一个型别）来进行多载化决议程序（overloaded resolution）。下面定义五个 classes，代表五种迭代器类型：

```c++
//五个做为标记用的型别（tag types）
structinput_iterator_tag { };
structoutput_iterator_tag { };
structforward_iterator_tag : public input_iterator_tag { };
structbidirectional_iterator_tag : public forward_iterator_tag { };
struct random_access_iterator_tag : publicbidirectional_iterator_tag { };
```

这些 classes只做为标记用，所以不需要任何成员。至于为什么运用继承机制，稍后再解释。现在重新设计 __ advance() （由于只在内部使用，所以函式名称加上特定的前导符），并加上第三参数，使它们形成多载化：

```c++
template <class InputIterator, class Distance>
inline void __advance (InputIterator& i, Distance n,
input_iterator_tag)
{
    // 单向，逐一前进
    while (n--) ++i;
}

//这是一个单纯的转呼叫函式（ trivial forwarding function ）。稍后讨论如何免除之。
template <class ForwardIterator, class Distance>
inline void __advance (ForwardIterator& i, Distance n,
forward_iterator_tag)
{
    advance(i, n, input_iterator_tag());
}

// 单纯地进行转呼叫（ forwarding ）
template <class BidiectionalIterator, class Distance>
inline void __advance (BidiectionalIterator& i, Distance n,
bidirectional_iterator_tag)
{
    // 双向，逐一前进
    if (n >= 0)
        while (n--) ++i;
    else
        while (n++) --i;
}

template <class RandomAccessIterator, class Distance>
inline void __advance (RandomAccessIterator& i, Distance n,
random_access_iterator_tag)
{
    // 双向，跳跃前进
    i += n;
}
```

注意上述语法，每个 __ advance() 的最后一个参数都只宣告型别，并未指定参数名称，因为它纯粹只是用来启动多载化机制，函式之中根本不使用该参数。如果硬要加上参数名称也可以，画蛇添足罢了。

行 进 至 此 ， 还 需 要 一 个 对 外 开 放 的 上 层 控 制 介 面 ， 呼 叫 上 述 各 个 多 载 化 的__ advance() 。 此 一 上 层 介 面 只 需 两 个 参 数 ， 当 它 准 备 将 工 作 转 给 上 述 的__ advance() 时，才自行加上第三自变量：迭代器类型。因此，这个上层函式必须有能力从它所获得的迭代器中推导出其类型—这份工作自然是交给 traits 机制：

```c++
template <class InputIterator, class Distance>
inline void advance (InputIterator& i, Distance n)
{
    __advance(i, n, iterator_traits< InputIterator >::iterator_category()); 3
}
```

注意上述语法， `iterator_traits<Iterator>::iterator_category()` 将产生一个暂时对象（道理就像 int() 会产生一个 int 暂时对象一样），其型别应该隶属前述五个迭代器类型之一。然后，根据这个型别，编译器才决定呼叫哪一个__ advance() 多载函式。因此，为了满足上述行为，traits必须再增加一个相应型别：

```c++
template <class I>
struct iterator_traits {
    ...
    typedef typename I::iterator_category iterator_category;
};

//针对原生指标而设计的「偏特化版（ partial specialization ）」
template <class T>
struct iterator_traits<T*> {
    ...
    // 注意，原生指标是一种 Random Access Iterator
    typedef random_access_iterator_tag iterator_category;
};

//针对原生的 pointer-to- const 而设计的「偏特化版（ partial specialization ）」
template <class T>
struct iterator_traits<const T*>
    ...
    // 注意，原生的 pointer-to- const是一种 Random Access Iterator
    typedef random_access_iterator_tag iterator_category;
};
```

任何一个迭代器，其类型永远应该落在「该迭代器所隶属之各种类型中，最强化的那个」。例如 int* 既是Random Access Iterator又是 Bidirectional Iterator，同时也是Forward Iterator，而且也是Input Iterator，那么，其类型应该归属为
random_access_iterator_tag。你是否注意到 advance() 的 template参数名称取得好像不怎么理想：

```c++
template <class InputIterator , class Distance>
inline void advance (InputIterator& i, Distance n);
```

按说 advanced() 既然可以接受各种类型的迭代器，就不应将其型别参数命名为InputIterator 。这其实是 STL 算法的一个命名规则：**以算法所能接受之最低阶迭代器类型，来为其迭代器型别参数命名**。

##### 消除“单纯传递调用的函数”

以 class 来定义迭代器的各种分类标签，不唯可以促成多载化机制的成功运作（使
编译器得以正确执行多载化决议程序，overloaded resolution），另一个好处是，透过继承，我们可以不必再写「单纯只做转呼叫」的函式（例如前述的 advance()
ForwardIterator版）。为什么能够如此？考虑下面这个小例子，从其输出结果可
以看出端倪：

```c++
// file: 3tag-test.cpp
//模拟测试 tag types 继承关系所带来的影响。
#include <iostream>
using namespace std;
struct B { }; // B 可比拟为 InputIterator
struct D1 : public B { }; // D1 可比拟为 ForwardIterator
struct D2 : public D1 { }; // D2 可比拟为 BidirectionalIterator

template <class I>
func(I& p, B)
{ cout << "B version" << endl; }

template <class I>
func(I& p, D2)
{ cout << "D2 version" << endl; }

int main()
{
    int* p;
    func(p, B()); // 参数与自变量完全吻合。输出 : "B version"
    func(p, D1()); // 参数与自变量未能完全吻合；因继承关系而自动转呼叫。
                    //输出:"B version"
    func(p, D2()); // 参数与自变量完全吻合。输出 : "D2 version"
}
```

##### 以 distance()为例

关于「迭代器类型标签」的应用，以下再举一例。 distance() 也是常用的一个迭代器操作函式，用来计算两个迭代器之间的距离。针对不同的迭代器类型，它
可以有不同的计算方式，带来不同的效率。整个设计模式和前述的 advance() 如
出一辙：

```c++
template <class InputIterator>
inline iterator_traits<InputIterator>::difference_type
__distance (InputIterator first, InputIterator last,
input_iterator_tag ) {
iterator_traits<InputIterator>::difference_type n = 0;
    // 逐一累计距离
    while (first != last) {
        ++first; ++n;
    }
    return n;
}

template <class RandomAccessIterator>
inline iterator_traits<RandomAccessIterator>::difference_type
__distance (RandomAccessIterator first, RandomAccessIterator last,
random_access_iterator_tag ) {
    // 直接计算差距
    return last - first;
}

template <class InputIterator>
inline iterator_traits<InputIterator>::difference_type
distance (InputIterator first, InputIterator last) {
typedef typename iterator_traits<InputIterator>::iterator_category category;
    return __distance(first, last, category());
}
```

注意， distance() 可接受任何类型的迭代器；其 template型别参数之所以命名为 InputIterator ，是为了遵循STL 算法的命名规则：**以算法所能接受之最初级类型来为其迭代器型别参数命名**。此外也请注意，由于迭代器类型之间存在着继承关系，「转呼叫（forwarding）」的行为模式因此自然存在—这一点我已在前一节讨论过。换句话说，当客端呼叫 distance() 并使用 Output Iterators或 Forward Iterators 或Bidirectional Iterators，统统都会转呼叫 Input Iterator版的那个 __distance() 函式。

### std::iterator的保证

为了符合规范，任何迭代器都应该提供五个巢状相应型别，以利traits萃取，否则便是自外于整个STL架构，可能无法与其它 STL 组件顺利搭配。然而写码难免挂一漏万，谁也不能保证不会有粗心大意的时候。如果能够将事情简化，就好多了。STL提供了一个 iterators class如下，如果每个新设计的迭代器都继承自它，就保证符合 STL 所需之规范：

```c++
template <class Category,
    class T,
    class Distance = ptrdiff_t,
    class Pointer = T*,
    class Reference = T&>
struct iterator {
    typedef Category iterator_category;
    typedef T value_type;
    typedef Distance difference_type;
    typedef Pointer pointer;
    typedef Reference reference;
};
```

iterator class不含任何成员，纯粹只是型别定义，所以继承它并不会招致任何额外负担。由于后三个参数皆有默认值，新的迭代器只需提供前两个参数即可。

比如自己写的ListIter，如果采用这种写法，应该这样写

```c++
template <class Item>
struct ListIter :
public std::iterator<std::forward_iterator_tag, Item>
{ ... }
```

### 总结

设计适当的相应型别（associated types），是迭代器的责任。设计适当的迭代器，则是容器的责任。唯容器本身，才知道该设计出怎样的迭代器来走访自己，并执行迭代器该有的各种行为（前进、后退、取值、取用成员…）。至于算法，完全可以独立于容器和迭代器之外自行发展，只要设计时以迭代器为对外接口就行。

traits编程技法，大量运用于 STL 实作品中。它利用「巢状型别」的写码技巧与编译器的template自变量推导功能，补强 C++未能提供的关于型别认证方面的能力，补强 C++不为强型（strong typed）语言的遗憾。了解traits编程技法，就像获得「芝麻开门」口诀一样，从此得以一窥 STL 源码堂奥。

### 3.6 iterator 源码完整重列

### 3.7 SGI STL 的私房菜 ： __type_traits

traits编程技法很棒，适度弥补了 C++ 语言本身的不足。STL只对迭代器加以规范，制定出 iterator_traits 这样的东西。SGI 把这种技法进一步扩大到迭代器以外的世界，于是有了所谓的 __type_traits 。双底线前缀词意指这是SGISTL 内部所用的东西，不在 STL 标准规范之内。

**iterator_traits 负责萃取迭代器的特性， __type_traits 则负责萃取型别（type）的特性**。此处我们所关注的型别特性是指：这个型别是否具备non-trivial defalt ctor ？是否具备 non-trivial copy ctor？是否具备 non-trivial assignment operator？是否具备 non-trivialdtor？如果答案是否定的，我们在对这个型别进行建构、解构、拷贝、赋值等动作时，就可以采用最有效率的措施（例如根本不唤起尸位素餐的那些constructor, destructor），而采用内存直接处理动作 如malloc() 、 memcpy() 等等，获得最高效率。这对于大规模而动作频繁的容器，有着显著的效率提升。

定义于 SGI <type_traits.h> 中的 __type_traits ，提供了一种机制，允许针对不同的型别属性（type attributes），在编译时期完成函式派送决定（function dispatch）。这对于撰写 template很有帮助，例如，当我们准备对一个「元素型别未知」的数组执行 copy 动作时，如果我们能事先知道其元素型别是否有一个 trivialcopy constructor ， 便 能 够 帮 助 我 们 决 定 是 否 可 使 用 快 速 的 memcpy() 或memmove() 。从 iterator_traits 得 来 的 经 验 ， 我 们 希 望 ， 程 式 之 中 可 以 这 样 运 用

```c++
__type_traits<T> ， T 代表任意型别：
__type_traits<T>::has_trivial_default_constructor
__type_traits<T>::has_trivial_copy_constructor
__type_traits<T>::has_trivial_assignment_operator
__type_traits<T>::has_trivial_destructor
__type_traits<T>::is_POD_type // POD : Plain Old Data
```

我们希望上述式子响应我们「真」或「假」（以便我们决定采取什么策略），但其结果不应该只是个 bool 值，应该是个有着真/假性质的「对象」，因为我们希望利用其响应结果来进行自变量推导，而编译器只有面对 class object形式的自变量，才会做自变量推导。为此，上述式子应该传回这样的东西：

```c++struct__true_type { };
struct__false_type { };
```

这两个空白 classes没有任何成员，不会带来额外负担，却又能够标示真假，满足我们所需。

为了达成上述五个式子， __type_traits 内必须定义一些typedefs，其值不是__true_type 就是 __false_type 。下面是 SGI的作法：

```c++
template <class type>
struct__type_traits
typedef __true_type this_dummy_member_must_be_first ;
    /* 不要移除这个成员。它通知「有能力自动将 __type_traits 特化」
    的编译器说，我们现在所看到的这个 __type_traits template 是特
    殊的。这是为了确保万一编译器也使用一个名为 __type_traits 而其
    实与此处定义并无任何关联的 template 时，所有事情都仍将顺利运作。
    */
/* 以下条件应被遵守，因为编译器有可能自动为各型别产生专属的 __type_traits
    特化版本：
    - 你可以重新排列以下的成员次序
    - 你可以移除以下任何成员
    - 绝对不可以将以下成员重新命名而却没有改变编译器中的对应名称
    - 新加入的成员会被视为一般成员，除非你在编译器中加上适当支持。*/
typedef __false_type has_trivial_default_constructor ;
typedef __false_type has_trivial_copy_constructor ;
typedef __false_type has_trivial_assignment_operator ;
typedef __false_type has_trivial_destructor ;
typedef __false_type is_POD_type;
};
```

为什么SGI 把所有巢状型别都定义为 __false _type 呢？是的，SGI 定义出最保守的值，然后（稍后可见）再针对每一个纯量型别（scalar types）设计适当的__type_traits 特化版本，这样就解决了问题。上述 __type_traits 可以接受任何型别的自变量，五个typedefs将经由以下管道获得实值：

- 一般具现体（general instantiation），内含对所有型别都必定有效的保守值。上述各个 has_trivial_xxx 型别都被定义为 __false_type ，就是对所有型别都必定有效的保守值。
- 经过宣告的特化版本，例如 <type_traits.h> 内对所有 C++纯量型别（scalar types）提供了对映的特化宣告。稍后展示。
- 某些编译器（如 Silicon Graphics N32和 N64编译器）会自动为所有型别提供适当的特化版本。（这真是了不起的技术。不过我对其精确程度存疑）

__types_traits 在SGI STL中的应用很广。下面我举几个实例。第一个例子是出现于本书 2.3.3节的 uninitialized_fill_n() 全域函式：

```c++
template <class ForwardIterator, class Size, class T>
inline ForwardIterator uninitialized_fill_n (ForwardIterator first,
Size n , const T& x ) {
    return __uninitialized_fill_n(first, n, x, value_type(first) );
}
```

此函式以 x为蓝本，自迭代器 first 开始建构 n个元素。为求取最大效率，首先 以 value_type() （ 3.6节 ） 萃 取 出 迭 代 器 first 的value type， 再 利 用__type_traits 判断该型别是否为 POD型别：

```c++
template <class ForwardIterator, class Size, class T, class T1>
inline ForwardIterator __uninitialized_fill_n (ForwardIterator first,
Size n, const T& x, T1*)
{
    typedef typename __type_traits<T1>::is_POD_type is_POD;
    return __uninitialized_fill_n_aux(first, n, x, is_POD());
}
```

以下就「是否为 POD型别」采取最适当的措施：

```c++
//如果不是 POD型别，就会派送（ dispatch ）到这里
template <class ForwardIterator, class Size, class T>
ForwardIterator
__uninitialized_fill_n_aux (ForwardIterator first, Size n,
const T& x, __false_type ) {
ForwardIterator cur = first;
    // 为求阅读顺畅简化，以下将原本有的异常处理（ exception handling ）去除。
    for ( ; n > 0; --n, ++cur)
        construct(&*cur, x); //见 2.2.3节
    return cur;
}

//如果是 POD型别，就会派送（ dispatch ）到这里。下两行是原文件所附注解。
//如果 copy construction 等同于 assignment ，而且有 trivial destructor ，
//以下就有效。
template <class ForwardIterator, class Size, class T>
inline ForwardIterator
__uninitialized_fill_n_aux (ForwardIterator first, Size n,
const T& x, __true_type ) {
    return fill_n (first, n, x); //交由高阶函式执行，如下所示。
}

//以下是定义于 <stl_algobase.h> 中的 fill_n()
template <class OutputIterator, class Size, class T>
OutputIterator fill_n (OutputIterator first, Size n, const T& value) {
    for ( ; n > 0; --n, ++first)
        *first = value;
    return first;
}
```

第二个例子是负责对象解构的 destroy() 全域函式。此函式之源码及解说在 2.2.3节有完整的说明。

第三个例子是出现于本书第6章的 copy() 全域函式（泛型算法之一）。这个函式有非常多的特化（specialization）与强化（refinement）版本，殚精竭虑，全都是为了效率考虑，希望在适当的情况下采用最「雷霆万钧」的手段。最基本的想法是这样：

```c++
//拷贝一个数组，其元素为任意型别，视情况采用最有效率的拷贝手段。
template <class T> inline void copy (T* source,T* destination,int n) {
    copy(source,destination,n,
        typename __type_traits<T>::has_trivial_copy_constructor() );
}

//拷贝一个数组，其元素型别拥有 non-trivial copy constructors 。
template <class T> void copy (T* source,T* destination,int n, __false_type)
{ ... }

//拷贝一个数组，其元素型别拥有 trivial copy constructors 。
//可借助 memcpy() 完成工作
template <class T> void copy (T* source,T* destination,int n, __true_type)
{ ... }
```

以上只是针对「函式参数为原生指标」的情况而做的设计。第6章的 copy() 演算法是个泛型版本，情况又复杂许多。详见 6.4.3节。

因 此 如 果 你 是 SGI STL的 使 用 者 ， 你 可 以 在 自 己 的 程 式 中 充 份 运 用 这 个__type_traits。加入编译器足够厉害，可以萃取出来我的Shape是否有 trivial defalt ctor或trivial copy ctor或trivial assignment operator或 trivial dtor，但如果不够厉害，萃取出来的都是__false_type，这样的结果未免过于保守，所以最保险的方法是自行设计一个__type_traits特化版本，明白地告诉编译器：

```c++
template<>struct __type_traits<Shape> {
    typedef __true_type has_trivial_default_constructor;
    typedef __false_type has_trivial_copy_constructor;
    typedef __false_type has_trivial_assignment_operator;
    typedef __false_type has_trivial_destructor;
    typedef __false_type is_POD_type;
};
```

究竟一个 class什么时候该有自己的 non-trivial default constructor, non-trivial copy constructor, non-trivial assignment operator, non-trivial destructor 呢？一个简单的判断准则是：如果 class 内含指标成员，并且对它进行内存动态配置，那么这个class就需要实作出自己的 non-trivial-xxx。

即使你无法全面针对你自己定义的型别，设计 __type_traits 特化版本，无论如何，至少，有了这个 __type_traits 之后，当我们设计新的泛型算法时，面对C++纯量型别，便有足够的信息决定采用最有效的拷贝动作或赋值动作—因为每一个纯量型别都有对应的 __type_traits 特化版本，其中每一个 typedef 的值都是 __true_type 。

#### type traits 类型特征

从字面上理解，Type Traits 就是” 类型的特征” 的意思。在 C++ 元编程中，程序员不少时候都需要了解一些类型的特征信息，并根据这些类型信息选择应有的操作。Type Traits 有助于编写通用、可复用的代码。

https://blog.csdn.net/mogoweb/article/details/79264925


指标 - 指针
配接器 - 适配器
提领 - 解引用
决议 - 解析
具现化 - 实例化
物件 - 对象
自变量 - 参数
函式 - 函数
型别 - 类型
巢状 - 内嵌