# Effective STL

>  个人建议，看本书前最好看一遍侯捷写的STL源码剖析，知道源码方能理解如何使用

## 容器

### 1. 慎重选择容器类型

### 2. 不要试图编写独立于容器类型的代码

不同容器的用法不同，支持的方法、迭代器种类、迭代器/指针/引用失效场景也不尽相同，所以不能独立

### 3. 确保容器中的对象拷贝正确而高效

- 往容器中添加元素，存入容器的是程序员所指定的对象的拷贝
- 当存在继承关系的情况下，拷贝会导致剥离（splice）

```c++
vector<Widget> vw;
class SpecialWidget: public Widget{
  ...
}
SpeicialWidget sw;
vw.push_back(sw); // sw作为基类对象被拷贝进vw中，派生类特有的部分在拷贝时被丢弃
```

- 使拷贝动作高效、正确、防止剥离问题的一个简单办法是使容器包含指针而不是对象，但需要注意内存泄露，可以使用智能指针

### 4. 调用empty()而不是检查size()是否为0

- 容器的emtpy()函数总是在常数时间返回，而size()不一定
- list容器支持splice，在常数时间内可以将两个list拼接（splice）在一起，所以list不会保存容器所包含多少个元素，即size()函数得遍历容器才能知道，所以需要O(n)时间
- 总之，empty()总是可以代替size==0

### 5. 区间成员函数优先于单成员函数

- 单成员函数，如`container::insert(xxx)`会导致多次调用，可能需要多次元素移动（如在vector的中间频繁insert），可能需要多次指针赋值（在list的中间频繁insert），可能需要多次扩容

- 区间成员函数，如`container::asign(iter_1, iter_2)`、`container::copy(iter_1, iter_2, iter)`等，事先就知道了要插入多少元素，性能更快

-  Range construction. All standard containers offer a constructor of this form: 

  ```c++
  container::container( InputIterator begin, // beginning of rang
                       InputIterator end); //end of range 
  ```

-  Range insertion. All standard sequence containers offer this form of insert:

  ```c++
  void container::insert(iterator position, // where to insert the range
  InputIterator begin, // start of range to insert
  InputIterator end); // end of range to insert
  ```

  注意：关联容器的insert不需要指名insert position，因为position由内部数据结构与算法决定的

  ```c++
  void container::insert(lnputIterator begin, InputIterator end);
  ```

- Range erasure. Every standard container offers a range form of erase, but the return types differ for sequence and associative containers. Sequence containers provide this,

  ```c++
  iterator container::erase(iterator begin, iterator end); 
  
  
  ```

  while associative containers offer this: 

  ```c++
  void container::erase(iterator begin, iterator end);
  ```

- Range assignment

  ```c++
  void container::assign(lnputIterator begin, InputIterator end);
  ```

### 6. 当心C++编译器最烦人的分析机制

- 有些时候可以使用有名的迭代器来传入STL函数中，这样就可以避免编译器把代码分析成程序员意料之外的函数声明

  ```c++
  ifstream dataFile("ints.dat");
  list<int> data(istream_iterator<int>(dataFile), // warning! this doesn't do
   istream_iterator<int>()); // what you think it does
  
  
  // 有名的迭代器，可以防止上述情况
  fstream dataFile(" ints.dat");
  istream_iterator<int> dataBegin(dataFile);
  istream_iterator<int> dataEnd;
  list<int> data(dataBegin, dataEnd);
  ```

  

### 7. 如果容器中存放了new出来的对象，在析构时记得手动调用delete释放

- 容器析构时会调用每个容器中每个元素的析构函数，但是如果这个元素是指针，指针所指向的对象则不会析构，需要程序员手动调用delete去析构，否则会有内存泄露！
- 用boost库的shared_ptr智能指针可以避免这种情况

### 8. 切勿创建包含auto_ptr的容器对象

- auto_ptr的容器（简称COAP）不可移植，C++标准都禁止使用它，但是有的STL平台没有禁止，这会导致很多难以预料的错误

  ```c++
  auto_ptr<Widget> pw1 (new Widget); // pwl1points to a Widget
  auto_ptr<Widget> pw2(pw1); // pw2 points to pw1's Widget;
   // pw1 is set to NULL. (Ownership
   // of the Widget is transferred
   //from pw1 to pw2.)
  pw1 = pw2; // pw1 now points to the Widget
  // again; pw2 is set to NULL
  ```

- 比如std::sort会将元素复制给临时变量，COAP会导致容器中有些auto_ptr变为NULL！

  >  std::auto_ptr已经移除了，现在的替代品是std::unique_ptr

### 9. 慎重选择删除元素的方法

- To eliminate all objects in a container that have a particular value: 

  - If the container is a vector, string, or deque, use the erase-remove idiom. 

    ```c++
    c.erase( remove(c.begin(), c.end(), 1963), // the erase-remove idiom is
     c.end()); //the best way to get rid of
    // elements with a specific
    // value when c is a vector,
    //string, or deque
    ```

    

  - If the container is a list, use list::remove.

    ```c++
    c. remove(1963); //the remove member function is the
    // best way to get rid of elements with
    // a specific value when c is a list
    ```

    

  - If the container is a standard associative container, use its erase member function. 

    ```c++
    c.erase(1963); // the erase member function is the
    // best way to get rid of elements with
    // a specific value when c is a
    // standard associative container
    ```

    

- To eliminate all objects in a container that satisfy a particular predicate: 
  - If the container is a vector, string, or deque, use the erase-remove_if idiom. 
  
    ```c++
    c.erase(remove_if(c.begin(), c.end(), badValue), // this is the best way to
     c.end()); // get rid of objects 
    ```
  
    
  
  - If the container is a list, use list::remove_if. 
  
    ```c++
    c.remove_if(badValue); // this is the best way to get rid of
     // objects where badValue returns
     //true when c is a list
    ```
  
    
  
  - If the container is a standard associative container, use remove_copy_if and swap, or write a loop to walk the container elements, being sure to postincrement your iterator when you pass it to erase.  
  
    ```c++
    // 方法一：remove_copy_if & swap
    AssocContainer<int> c; // c is now one of the standard associative containers
    …… 
     
    AssocContainer<int> goodValues; // temporary container to hold unremoved values
    remove_copy_if(c.begin(), c.end(), // copy unremoved values from c to goodValues
       inserter( goodValues, 
       goodValues.end()), 
       badValue):
    c.swap(goodValues): // swap the contents of c and goodValues
    
    // 方法二：循环
    AssocContainer<int> c;
    
    // 错误的示例
    for (AssocContainer<int>::iterator i = c.begin(); // clear, straightforward, and buggy code to erase every element
    i!= c.end(); 
    ++i) { 
       if (badValue(*i)) c.erase(i); // in c where badValue  returns true; don't do this!
    } 
    
    
    // 正确的示例
    for (AssocContainer<int>::iterator i = c.begin(); i != c.end(); ){ // i incremented below
       if (badValue(*i)) c.erase(i++); //把未递增的i传给erase，但真正erase前，i已递增，所以不会失效
       else ++i;
    }
    ```
  
- To do something inside the loop (in addition to erasing objects): 

  - If the container is a standard sequence container, write a loop to walk the container elements, being sure to update your iterator with erase's return value each time von call it. **记住：顺序容器的erase，除了会使迭代器本身失效，还会使迭代器后面的所有迭代都失效！**

  ```c++
  // 之前的erase&remove方法行不通了，必须要用循环来做
  // 记住：顺序容器的erase，除了会使迭代器本身失效，还会使迭代器后面的所有迭代都失效！
  // 但因为顺序容器的erase函数会返回迭代器后面那个迭代器，所以可以靠返回值来继续循环
  for (SeqContainer<int>::iterator i = c.begin(); i != c.end();){
  if (badValue(*i)){
    logFile << "Erasing " << *i << '\n';
    i = c.erase(i); // keep i valid by assigning
  } //erase's return value to it
    else ++i;
  }
  ```

  - If the container is a standard associative container, write a loop to walk the container elements, being sure to postincrement your iterator when you pass it to erase.

  ```c++
  // 后缀递增的技术已经在上面写过了
  ```

### 10. 了解分配子（allocator）的限制与约定

- Make your allocator a template, with the template parameter T representing the type of objects for which you are allocating memory.
-  Provide the typedefs pointer and reference, but always have pointer be T* and reference be T&.
- Never give your allocators per-object state. In general, allocators should have no nonstatic data members.
- Remember that an allocator's allocate member functions are passed the number of objects for which memory is required, not the number of bytes needed. Also remember that these functions return T* pointers Ma the pointer typedef), even though no T objects have yet been constructed.
- Be sure to provide the nested rebind template on which standard containers depend

### 11. 理解自定义allocator的合理用法

- 同一类型的分配子必须是等价的

  > 如果不等价，由allocator1分配出来的list1拼接由allocator2分配出来的list2后，将不会释放list2的内存，造成内存泄露，所以必须等价

- 如果你认为STL默认的内存管理器（即`allocator<T>`）太慢，或者浪费内存，或者你只需要单线程环境，`allocator<T>`的线程安全性牺牲了部分性能用于同步，再或者你想把容器中的对象对象放在一个特殊堆的相邻位置上以便局部化

### 12. 切勿依赖STL容器的线程安全性

- 标准C++并没有提供保证

- 这时候通用做法是加锁

  ```c++
  vector<int> v;
  …
  getMutexFor(v);
  vector<int>::iterator first5(find(v.begin(), v.end(), 5));
  if (first5 != v.end()) { // this is now safe
   *first5 = 0; // so is this
  }
  releaseMutexFor(v);
  ```

- 使用面向对象的思想来管理锁，『获得资源时即初始化』（resorce acquisition is initialization，RAII），可以防止程序员忘记释放锁的情况发生

  ```c++
  Lock(const Containers container)
   : c(container)
   {
   getMutexFor(c); // acquire mutex in the constructor
   }
   ~Lock()
   {
   releaseMutexFor(c); // release it in the destructor
   }
  private:
   const Container& c;
  }; 
  
  
  vector<int> v;
  …
  { // create new block;
   Lock<vector<int> > lock(v); // acquire mutex
   vector<int>::iterator first5(find(v.begin(), v.end(), 5));
   if (first5 != v.end()) {
   *first5 = 0;
   }
  } // close block, automatically
   // releasing the mutex
  ```

## vector和string

### 13. vector和string优先于动态分配的数组

- 使用new来动态分配内存，必须要有delete，否则会内存泄露
- 如果分配单个对象，new与delete成对使用，如果分配数组，new[]与delete[]成对使用
- 对于同一个new分配的对象，确保只delete一次，double delete的结果也是不确定的

### 14. 使用reserve来减少不必要的内存重新分配

- 注意这四个函数的区别：size(), capacity(), resize(), reserve()，只有vector和string同时提供了这4个函数
  - `size()` tells you how many elements are in the container. It does not tell you how much memory the container has allocated for the elements it holds.  
  - `capacity()` tells you how many elements the container can hold in the memory it has already allocated. This is how many total elements the container can hold in that memory, not how many more elements it can hold. If you'd like to find out how much unoccupied memory a vector or string has, you must subtract size() from capacity(). If size and capacity return the same value, there is no empty space in the container, and the next insertion (via insert or push_back, etc.) will trigger the reallocation steps above. 
  - `resize(size_t n)` forces the container to change to n the number of elements it holds. After the call to resize, size will return n. If n is smaller than the current size, elements at the end of the container will be destroyed. If n is larger than the current size, new default-constructed elements will be added to the end of the container. If n is larger than the current capacity, a reallocation will take place before the elements are added.  
  - `reserve(size_t n)` forces the container to change its capacity to at least n. provided n is no less than the current size. This typically forces a reallocation, because the capacity needs to be increased. (If n is less than the current capacity, vector ignores the call and does nothing, string may reduce its capacity to the maximum of size() and n. but the string's size definitely remains unchanged. In my experience, using reserve to trim the excess capacity from a string is gene

- 如果事先知道vector/string会增加多少，可以用reserve()函数一次性扩容，因为自动扩容大概是原来容量的两倍，可能需要多次自动扩容，损耗性能

### 15. 注意string实现的多样性

- `sizeof(string)`是多大？取决于实现平台

- 几乎所有string的实现都会包含以下几项
  - **The size** of the string, i.e., the number of characters it contains.  
  - **The capacity** of the memory holding the string's characters. (For a review of the difference between a string's size and its capacity, see Item 14.)  
  - **The value** of the string, i.e., the characters making up the string. In addition, a string may hold  A copy of its allocator. For an explanation of why this field is optional, turn to Item 10 and read about the curious rules governing allocators. string implementations that depend on reference counting also contain  
  - **The reference** count for the value.

- 不同实现的区别

  - string values may or may not be reference counted. By default, many implementations do use reference counting, but they usually offer a way to turn it off, often via a preprocessor macro（预处理宏）. 

- string objects may range in size from one to at least seven times the size of char* pointers.（一倍指针的实现是string对象本身就是个指针，这个指针指向的结构体包括size、capacity、refcnt、point（to values array），如下图）

  ![image-20220306174144883](https://tva1.sinaimg.cn/large/e6c9d24egy1h00awfzjcyj20l40cm3yu.jpg)

- Creation of a new string value may require zero, one, or two dynamic allocations.（取决于用了几层指针）
  
- string objects may or may not share information on the string's size and capacity.
  
- strings may or may not support per-object allocators.
  
- Different implementations have different policies regarding minimum allocations for character buffers.

### 16. 了解如何把vector和string数据传给旧的API

- 假设v是`vector<int>`容器，对于C语言API：`void doSomething(const int* pInts, size_t numInts)`，可以传入`doSomething(&v[0], v.size())`，但是如果v为空，`&v[0]`指向的就是空的了，不太安全，还是在前面判断非空比较好
- 假设s是`string`，对于C语言API：`void doSomething(const char* pString)`，可以传入`doSomething(s.c_str())`，即使s长度为零也没关系，c_str()返回指向空字符串的指针
- 没有特殊情况，不建议这样做，这一节只是介绍方法而已

### 17. 使用swap技巧去除多余的容量（C++11已有shrink-to-fit方法

- 假设v是个很大的vector，经过很多次erase后，没有多少元素了，但是其容量还是很大，很消耗内存，可以调用shrink-to-fit方法，但是其实现比较有技巧
- swap技巧：`vector<T>(v).swap(v);`
- 解释：`vector<T>(v)`创建一个临时向量，它是v的拷贝，**注意vector的拷贝构造函数只为所拷贝的元素分配所需内存**，所以临时向量没有多余容量，其与v变量交换，v具有了被去除之后的容量，而临时向量变成了臃肿的容量，最后被析构，从而达到shrink-to-fit的目的！
- 同理，可以对string也这样操作
- swap技巧还可以用于清除一个容器：`vector<T>().swap(v)`，`string().swap(s)`
- swap容器，不仅内容被交换，迭代器、指针、引用也被交换（string除外），但依然有效，只不过指向的元素在另一个容器中

### 18. 避免使用`vector<bool>`

- C++标准规定，如果c是包含对象T的容器，且c支持operator[]，则下面代码必须能够被编译

  ```c++
  T *p = &c[0]; // initialize a T* with the address
   // of whatever operator[] returns
  ```

- 但是`vector<bool>`不能这样编译，为了节省空间，每个bool仅占一个二进制位，很像位域bitfield

- 已有`std::bitset`可以代替`vector<bool>`

## 关联容器

### 19. 理解相等（equality）和等价（equivalence）的区别

- STL有许多函数需要确定两个值是否相同，但它们的判断方式不同

  - find对相同的定义是**相等**，以operator==为基础
  - set::insert对相同的定义是**等价**，已operator<为基础

- 相等很好理解，而等价的理解需要了解关联容器的特点，等价是以"**在已排序的区间中对象值的相对顺序**"为基础，比如，`set<Widget>`的默认比较函数是`less<Widget>`，而在默认情况`less<Widget>`只是简单调用针对Widget类的operator<，也就是是说：w1与w2对于operator<是等价的，当且仅当：

  ```c++
  !(w1 < w2) && !(w2 < w1)
    // 按照一定的排序准则，两个值中的任一个都不在另一个前面，则这两个值是**等价**的
  ```

- 当用户自定义比较函数时，上面的operator<就被替换为自定义的比较函数

  ```c++
  !c.key_comp()(x, y) && !c.key_comp()(y, x) // it's not true that x precedes
  // y in c's sort order and it's
  // also not true that y precedes
  ```

  

- 对于stl::find，是以operator==作为相等的比较准则，而对于set的find成员函数，是已operator<作为等价的比较准则，对set容器调用stl::find与直接调用成员函数set::find，两者的结果可能会不一样

### 20. 为包含指针的关联容器指定比较类型

- 这种情况要非常小心

  ```c++
  set<string*> ssp; // ssp = "set of string ptrs"
  ssp.insert(new string("Anteater"));
  ssp.insert(new string("Wombat"));
  ssp.insert(new string("Lemur"));
  ssp.insert(new string("Penguin"));
  
  for (set<string*>::const_iterator i = ssp.begin(); i != ssp.end(); ++i)
  
   cout << *i << endl;
    // you expect to see this: "Anteater","Lemur”,"'Penguin”,"Wombat"
  ```

- `set<string*> ssp;`等同于`set<string*, less<string*>> ssp;`，所以并不是以string的字典序作为比较顺序，而是以string*这个指针来作为比较顺序，也就是内存地址，这可与预期完全不一样了

- 解决方法是自定义解引用的比较函数

  ```c++
  struct DereferenceLess {
  template <typename PtrType>
  bool operator()(PtrType pT1, // parameters are passed by
     PtrType pT2) const // value, because we expect them
     { // to be (or to act like) pointers
      return *pT1 < *pT2;
     }
  };
  ```

### 21. 总是让比较函数在相等时候返回false

- 如果operator<被替换为了operator<=，那么在调用`set<int>::insert`时，假设原来已有元素10，记为10a，新的10记为10b，则判断等价的方式为

  ```c++
  !(10A<= 10B)&&!(10B<= 10A) //test 10Aand 10B for equivalence
  ```

- 这会导致两个10被判定为不等价，于是第二个10也可以加入到set集合中，完全违背了不重复的原则

- 技术上说，对于关联容器的比较函数必须是严格弱序化的（strict weak ordering）

### 22. 切勿直接修改set或multiset的键

- 每个元素的key是维持元素之间顺序的判断标准，贸然修改会导致不确定的结果
- 真有这样的需求，可以这样操作
  - 找到元素
  - 拷贝它，并修改成你希望的值
  - 把原来的元素删除，一般是erase函数
  - 把拷贝的新值插入到容器中，按照原来的排序，新元素与旧元素应该是相同位置或者挨着的，可以用带有指示插入位置的insert函数，插入位置来自于第一步的找到元素

### 23. 考虑用排序的vector替代关联容器

- 适用于三阶段的业务场景：
  - 设置阶段：创建并大量插入元素
  - 查找阶段：很少或几乎没有插入或删除操作
  - 重组阶段：增删改该数据结构，然后继续第二步，然后循环

- 有序的关联容器一般是平衡二叉树及其变异，插入删除一般伴随着移动操作，比较消耗时间

- 如果是排序的vector，可以很方便使用binary_search, lower_bound, equal_range等函数

- vector的空间消耗比关联容器更小，且是连续地址空间，可以减少缺页

- 典型的代码如下，符合三阶段业务场景

  ```c++
  vector<Widget> vw; // alternative to set<Widget>
  …… //Setup phase: lots of
  // insertions, few lookups
  sort(vw.begin(), vw.end()); // end of Setup phase. (When
  // simulating a multiset, you
  // might prefer stable_sort
  // instead; see Item 31.)
  Widget w; // object for value to look up
  …… //start Lookup phase
  if (binary_search(vw.begin(), vw.end(), w))... // lookup via binary_search
  vector<Widget>::iterator i =
   lower_bound(vw.begin(), vw.end(), w); // lookup via lower_bound;
  if (i != vw.end() && !(*i < w))... // see Item 45 for an explana-
   //tion of the"!(*i < w)" test
  pair<vector<Widget>::iterator,
  vector<Widget>::iterator> range =
  equal_range(vw.begin(), vw.end(), w); // lookup via equal_range
  if (range.first != range.second)...
  … // end Lookup phase, start
  // Reorganize phase
  sort(vw.begin(), vw.end()); // begin new Lookup phase... 
  ```

  

### 24. 效率至关重要时，在map::operator[]与map::insert中谨慎选择

- map::operator[]是为了方便添加和更新功能在同一个函数中，在下面的示例中，是添加功能：

  ```c++
  map<int, Widget> m;
  m[1] = 1.50;
  ```

- The expression m[1] is shorthand for `m.operator[](1)`, so this is a call to map::operator[]. That function must return a reference to a Widget, because m's mapped type is Widget. In this case, m doesn't yet have anything in it, so there is no entry in the map for the key 1. operator[] therefore default-constructs a Widget to act as the value associated with 1, then returns a reference to that Widget. Finally, the Widget becomes the target of an assignment: the assigned value is 1.50.

- 直接调用m.insert，可以节省三个函数调用：创建默认构造函数的临时Widget对象，析构Widget对象，还有Widget的赋值操作符

- 总结：
  - 如果要更新已有的map元素，优先选择operator[]
  - 如果要添加一个元素，还是选择map::insert

### 25. 熟悉非标准的散列容器

- 散列容器基于hash，它们的比较方法不是基于operator<，而是operator==，因为元素hash后要与已有元素的hash进行**相等**比较，而且散列容器不需要保持有序性，所以不是以**等价**作为比较标准
- 书中说散列容器不是STL的一部分，但好像后来加入了

## 迭代器

### 26. 尽量用iterator代替const_iterator、 reverse_iterator和const_reverse_iterator

- 有些容器的成员函数只接受iterator

  ```c++
  iterator insert(iterator position, const T& x);
  iterator erase(iterator position);
  iterator erase(iterator rangeBegin, iterator rangeEnd);
  
  ```

- reverse_iterator可以  用其base成员函数转换为iterator。const_reverse_iterator也可以类似地  base转换成为const_iterator。但可能需要一些调整
- const_iterator无法转换为iterator

### 27. 用distance和advance把const_iterator转化成iterator

- 用`const_cast<>`映射转换很可能行不通，而且不可移植

- 要得到与const_iterator指向同一位置的iterator，首先将iterator指向容器的起始位置，然后把它向前移到和const_iterator 离容器起始位置的偏移一样的位置即可，distance 返回两个指向同一个容器的iterator之间的距离； advance则用于将一个iterator移动指定的距离

- 首先考虑：

  ```c++
  typedef deque<int> IntDeque; // 和以前一样
  typedef IntDeque::iterator Iter;
  typedef IntDeque::const_iterator ConstIter;
  IntDeque d;
  ConstIter ci;
  ... //  ci指向d
  Iter i(d.begin()); // 初始化i为d.begin()
  // 错误的做法：
  advance(i, distance(i, ci)); // 把i移到指向ci位置，但留意下面关于为什么，在它编译前要调整的原因 
  ```

- 为什么错误？但是InputIterator没法推断出两个类型，具有歧义

  ```c++
  template<typename InputIterator>
  typename iterator_traits<InputIterator>::difference_type
  distance(InputIterator first, InputIterator last);
  ```

- 修改方法：显式的指名distance调用的模板参数类型

  ```c++
  advance(i, distance<ConstIter>(i, ci));
  ```

- 对于随机访问的迭代器（ 比如vector、string和deque的 ）而言，这是 是常数时间的操作。对于双向跌代器是，线性时间 的操作。

### 28. 了解如何通过reverse_iterator的base得到iterator

-  实现在一个reverse_iterator ri指出的位置上删除元素 就应 删除ri.base()的前一个元素。对于删除操作   ri和ri.base()并不等价  且ri.base()不是ri对应的iterator。
- reverse_iterator的base成员函数 回一个“对应的”iterator的 法并不准确。对于插入操作  的确如此；但是对于删除操作并非如此。当 需要把reverse_iterator转换成iterator的时候，有一点非常重要的是你必须知道你准备怎么处理返回的iterator，因为只有这样你才能决定你得到的iterator是否是你需要的。

![image-20220308220954725](https://tva1.sinaimg.cn/large/e6c9d24egy1h02tw21nl5j20ak07474a.jpg)

### 29. 需要一个一个字符输入时考虑使用istreambuf_iterator

- 你可以像istream_iterator一样使用istreambuf_iterator但`istream_iterator<char>`对象使用`operator>>`来从输入流中读取单个字符。

  `istreambuf_iterator<char>`对象进入流的缓冲区并直接读取下一个字符

## 算法

两个目标：

1. 介绍少见的算法
2. 避免算法的常见用法问题

### 30. 确保目标区间足够大

### 31. 了解你的排序选择

- 部分排序？使用partial_sort

  ```c++
  bool qualityCompare(const Widget& lhs, const Widget& rhs)
  {
  	//  lhs的质 是不是比rhs的质 好
  }
  ...
  partial_sort(widgets.begin(), // 把最好的20个元素
    widgets.begin() + 20, //  按顺序 放在widgets的前端
    widgets.end(),
    qualityCompare);
  ... // 使用widgets...
  ```

- 部分排序的结果是否可以不排序？partial_sort给了更多的信息，如果不需要这额外的信息，可以考虑使用nth_element

  ```c++
  nth_element(widgets.begin(), // 把最好的20个元素
    widgets.begin() + 19, // 放在widgets前端 
    widgets.end(), // 但不用担心
    qualityCompare); // 它们的顺序
  ```

- 除了stable_sort是稳定的，sort、partial_sort、nth_element都是不稳定的

- partition算法，重排区间的元素从而满足某个标准的元素都在区间的开头

  ```c++
  bool hasAcceptableQuality(const Widget& w)
  {
  	//  返回w质量等级是否是2或更高;
  }
  vector<Widget>::iterator goodEnd = // 把所有满足hasAcceptableQuality
    partition(widgets.begin(), // 的widgets移动到widgets前端 
    widgets.end(), // 并且返回一个指向第一个
    hasAcceptableQuality); // 不满足的widget的跌代器
  ```

- 算法sort、stable_sort、partial_sort和nth_element  需要随机迭代器， 所以它们可能只能 用于vector、string、deque和数组

- 如果想对list进行partial_sort或nth_element，必须间接完成，即把元素拷贝到一个支持随机访问迭代器的容器中，然后应用需要的算法

- list的sort成员函数可以代替sort和stable_sort

- partition和stable_partition只需要双向迭代器，所有可以在任何标准序列迭代器上使用partition和stable_partition

  

### 32. 如果你真的想删除东西的话就在类似remove的算法后接上erase

- remove接收指定它操作的元素区间的一对跌代器。它不接收一个容器 所以remove不知道它作用于哪个容器。此外 remove也不可能发现容器， 因为没有办法从一个迭代器获取对应于它的容器。

  ```c++
  template<class ForwardIterator, class T>
  ForwardIterator remove(ForwardIterator first, ForwardIterator last,
  const T& value);
  ```

- 所以：唯一从容器中除去一个元素的方法是在那个容器上应用一个成员函数（一般是erase），因为remove无法知道它正在操作的容器

- remove做了什么：

  - remove移动指定区间中的元素直到所有“不删除的”元素在区间的开头相对位置和原来它们的一样。它返回一个指向最后一个的下一个“不删除的”元素的跌代器。 返回值是区间的“新逻辑终点"
  - 在内部，  remove遍历这个区间， 把要 “删除的”值覆盖为后面要保留的值。 这个覆盖通过对持有被覆盖的值的元素赋值来完成
  - 你可以想象remove完成了一种压缩 ，被删除的值表演了在压缩中被填充的洞的角色

- 所以remove一般要与erase连起来使用

  ```c++
  vector<int> v; // 正如从前
  v.erase(remove(v.begin(), v.end(), 99), v.end()); // 真的删除所有// 等于99的元素
  cout << v.size(); // 现在返回7
  ```

### 33. 提防在指针的容器上使用类似remove的算法

- 如果你无法避免在存放指针的容器上使用remove， 排除这个问题一种方法是在应用erase-remove惯用法之前先删除指针并设置它们为空，然后除去容器中的所有空指针
- 智能指针可以在这个问题上防止内存泄露

### 34. 注意哪个算法需要有序区间

- 搜索算法binary_search、lower_bound、upper_bound和equal_range需要有序区间，因为它们使用二分查找，注意传入的迭代器得是随机访问迭代器，如果是其他如双向迭代器，则运行需要线性时间

- 算法set_union、set_intersection、set_difference和set_symmetric_difference的四人组提供了线性时间设置它们名字所提出的操作的性能，如果不是有序区间，则不能保证以线性时间完成

- merge和inplace_merge执行了有效的单遍合并排序算法： 它们读取两个有序区间， 然后产生一个包含了两个源区间所有元素的新有序区间。它们以线性时间执行，如果它们不知道源区间已经有序就不能完成。

- includes用来检测是否一个区 的所有对象也在另一个区 中。因为includes可能假设的两个区间已经有序。 所以它保证了线性时间性能 。没有那个保证，一般来说它会变慢。

- unique和unique_copy：从每个相等元素的**连续**组中去除第一个以外所有的元素，这意味着原区间得排好序；而且unique从一个间 除去元素的方式和remove一样， 也就是说它只是区分出不除去的元素

  > STL的unique和Unix的uniq之间有惊人的相似

### 35. mismatch或lexicographical比 实现简单的忽略大小写字符串比较

### 36. 了解copy_if的正确实现

### 37. 用accumulate或for_each来统计区间

- count告诉你一个区间有多少个元素

- count_if统计出满足某个判别式的元素个数

- min_element, max_element获得区间最小值与最大值

- accumulate适合更个个性化的统计处理，不在`<algorithm>`中，而是在`<numeric>`中
  - 形式一：两个迭代器和一个初始值，返回初始值加上区间值的和
  ```c++
  list<double> ld;
  double sum = accumulate(ld.begin(), ld.end(), 0.0); //注意要0.0
  ```
  
  - 形式二：两个迭代器和一个初始值，再加上一个处理函数，返回初始值与所有区间值的经过处理函数后的结果
  
    ```c++
    //自定义处理函数函数
    string::size_type stringLengthSum(string::size_type sumSoFar, const string& s) {
      return sumSoFar + s.size();
    }
    
    
    set<string> ss;
    string::size_type lengthSum = accumulate(ss.begin(), ss.end(), static_cast<string::size_type>(0), stringLengthSum);
    
    
    // 标准multiplies仿函数
    vector<float> vf;
    float  product = accumulate(vf.begin(), vf.end(), 1.0f, multiplies<float>());
    
    ```
  
    

- For_each对区间每个元素执行操作，返回的是一个函数对象

> 作者更青睐于accumulate，而不是for_each

## 函数子、函数子类、函数及其他

> 函数子即仿函数（functor）

### 38. 遵循按值传递的原则来设计函数子类

- 由于函数对象往往按值传递和返回，所以得确保编写的函数对象在经过了传递之后还能正常工作
- 这意味着：
  - 函数对象尽可能小，否则复制开销昂贵
  -  函数对象必须是单态的（不是多态的），即不能使用虚函数，否则如果形参是基类，实参是派生类，则传递过程中会产生剥离问题（slicing problem）

### 39. 确保判别式是纯函数

- 判别式（predicate）是一个返回值为bool类型的函数，标准关联容器的比较函数就是判别式，find_if等算法也用判别式来作为参数
- 纯函数（pure function）返回值仅依赖参数，即若x、y是两个对象，当且仅当x或y的值发生变化时，f(x,y)的值才会发生变化
- 判别式类（predicate class）是一个函数子类/仿函数类，其operator()函数是一个判别式
- 为啥判别式得是纯函数？因为用做判别式的函数对象经常先被复制，然后存放起来以待之后使用，它不知道这段时间发生什么，如果不是纯函数，可能与预期结果不一致

### 40. 若一个类是函数子，则应使它可配接

### 41. 理解ptr_fun、mem_fun和mem_fun_ref的来由

- For_each函数调用的是容器内对象的非成员函数

  ```c++
  template<typename InputIterator, typename Function>
  Function for_each(InputIterator begin, InputIterator end, Function f)
  {
  	while (begin != end) f(*begin++);
  }
  
  void test(Widget& w);
  vector<Widget> vw;
  for_each(vw.begin(), vw.end(), test); // #1可以编译
  ```

- 但如果test函数是Widget的成员函数，简单传入成员函数不能编译

  ```c++
  class Widget {
    public:
     void test();
  }
  
  for_each(vw.begin(), vw.end(), &Widget::test); // #2不能编译！
  ```

- 但如果用的是存放Widget*指针的容器，简单传入成员函数不能编译

  ```c++
  list<Widget*> lpw;
  for_each(lpw.begin(), lpw.end(), &Widget::test); // #3不能调用
  ```

- 总的来说，mem_fun适配语法#3，称为**函数对象适配器(function object adaptor)**，mem_fun带有一个到成员函数的指针 pmf 并返回一个mem_fun_t类型的对象。 是一个仿函数类 容纳成员函数指针， 并提供一个operator() ，在operator()中调用了通过参数传递进来的对象上的该成员函数

  ```c++
  template<typename R, typename C> // 用于不带参数的non-const成员函数 mem_fun_t<R,C> // 的mem_fun声明。
  mem_fun(R(C::*pmf)()); // C是类，R是被指向
  // 的成员函数的返回类型
  ```

- mem_fun_ref函数适配语法#2到语法#1，并产生mem_fun_ref_t类型的适配器对象

- ptr_func在这里不需要使用，而mem_fun是针对成员函数（member function）的适配器，mem_fun_ref是针对对象容器的适配器，但取名不太雅致

### 42. 确定`less<T>`表示`operator<`

- 假设Widget类有重量和最大速度两个属性，通常大家按照重量排序

  ```c++
  bool operator<(const Widget& lhs, const Widget& rhs) {
  	return lhs.weight() < rhs.weight(); 
  }
  ```

- 如果我们想建立按照最大速度排序的`mutiset<Widget>`，我们知道默认比较函数`less<Widget>`，而且我们知道默认的`less<Widget>`通过调用Widget的`operator<`来工作，如果特化`less<Widget>`的默认比较函数，让它只关注Widget的最高速度

  ```c++
  template<>
  struct std::less<Widget>:
  public std::binary_function<Widget,
  // 这是一个std::less
  // 的Widget的特化;
  // 也是非常坏的主意
  Widget, bool> // 关于这个基类更多
  { // 的信息参见条款40
  bool operator()(const Widget& lhs, const Widget& rhs) const {
    return lhs.maxSpeed() < rhs.maxSpeed(); 
  }
  ```

- 在程序员们的惯性思维中，operator+做加法，operator-做减法，operator==做比较，而且less等价于使用operator<，让less做operator<意外的事情是对程序员预期的无故破坏，与最小惊讶原则相反

- 当然，对于std::less的特化还是有的，比如boost库的shared_ptr的一部分

  ```c++
  namespace std {
    template<typename T> // 这是一个用于boost::shared_ptr<T> struct less<boost::shared_ptr<T> >: // 的std::less的特化
      public // (boost是一个namespace) binary function<boost::shared_ptr<T>,
      boost::shared_ptr<T>,// 这是惯例的
      bool> { // 基类(参见条款40) bool operator()(const boost::shared_ptr<T>& a,
      const boost::shared_ptr<T>& b) const
      {
      	return less<T*>()(a.get(),b.get()); // shared_ptr::get返回
        
      }
    }; 
  }
  ```

- 正确的做法，新建一个仿函数类来进行比较

  ```c++
  struct MaxSpeedCompare:
  public binary_function<Widget, Widget, bool> {
  bool operator()(const Widget& lhs, const Widget& rhs) const {
  	return lhs.maxSpeed() < rhs.maxSpeed(); }
  };
  
  multiset<Widget, MaxSpeedCompare> widgets;
  ```

## 使用STL编程

### 43. 尽量用算法调用代替手写循环

- STL算法内部都有循环，调用STL算法一般比手写循环更优
- 效率:算法通常比程序员产生的循环更高效。
  - 比如，手写循环每次遍历都要调用iter::end()函数检查是否到达末尾，而STL算法完全可以内联减少函数开销
  - 再比如，库设计者知道最快的遍历方法，而库使用者不知道，举例：deque基于指针的遍历比基于迭代器的遍历更快
  - STL算法都在性能上达到了精益求精的地步，一般的程序员很难达到，即使是用erase-remove惯用法 所获得的性能也比程序员一般循环要好
- 正确性:写循环时比调用算法更容易产生错误。
- 可维护性:算法通常使代码比相应的显式循环更干净、更直观。

- 当然，并不是绝对的， 出于编写的难易程度、可读性、可维护性，可能有时候手写循环会更加一目了然

### 44. 容器的成员函数优先于同名算法

- 有些容器拥有和STL算法同名的成员函数。关联容器提供了count、find、lower_bound、upper_bound和 equal_range，而list提供了remove、remove_if、unique、sort、merge和reverse。大多数情况下，你应该用成员函 数代替算法。这样做有两个理由。首先，成员函数更快。其次，比起算法来，它们与容器结合得更好(尤其 是关联容器)。那是因为同名的算法和成员函数通常并不是是一样的。
- 比如，成员函数`set<T>::fin(xx)d`调用二分查找，时间复杂度O(logn)，同名STL算法`find(set<T>::iter_begin(), set<T::iter_end(), xxx)`调用线性查找，时间复杂度O(n)
- 还有一个原因，关联容器使用『等价』来判断相同性，而STL算法使用『相等』来判断相同性，参见第19条款
- 特别是list，肯定要用它自己提供的成员函数，比如`list::erase`是实实在在地删除了元素，没有必要再调用`erase`了

### 45. 注意count、find、binary_search、lower_bound、upper_bound 和equal_range的区别

- 对于未排序的容器，查找都得线性，可供考虑的只有if与count，如果是想知道某个值在不在容器中，则find性能更好，因为找到就直接停止了

  - count回答的问题是:“是否存在这个值，如果有，那么存在几份拷贝?”

    ```c++
    list<Widget> lw; // Widget的list Widget w; // 特定的Widget值 ...
    if (count(lw.begin(), lw.end(), w)) {
    ... // w在lw中 } else {
    ... // 不在 }
    ```

  - 而find回答的问题 是:“是否存在，如果有，那么它在哪儿?”

    ```c++
    if (find(lw.begin(), lw.end(), w) != lw.end()) {
    ... // 找到了
    } else {
    ... // 没找到
    }
    ```

- 有序区间的搜索算法(binary_search、lower_bound、upper_bound和equal_range)是对数时间的

  - binary_search回答这个问题:“它在吗?”不像标准C库中的(因此也是标准C++库中的) bsearch，binary_search只返回一个bool值

  - lower_bound回答这个问题:“它在吗?如果是，第一个拷贝在哪里?如果不是，它将在哪里？lower_bound返回一个迭代器，这个迭代器指向这个值的第一个拷贝(如果找到的话)或者到可以插入这个值的位置(如果没找到)。

    ```c++
    // 假设我们有一个Timestamp类和一个Timestamp的vector，它按照老的timestamp放在前面 的方法排序
    // 1. 现在假设我们有一个特殊的timestamp——ageLimit，而且我们从vt中删除所有比ageLimit老的timestamp。即我们需要在vt中找到一个位置:第一个不比ageLimit更老的元素
    vt.erase(vt.begin(), lower_bound(vt.begin(), // 从vt中排除所有
    vt.end(), // 排在ageLimit的值 ageLimit)); // 前面的对象
                                     
    // 2. 我们要排除所有至少和ageLimit一样老的timestamp，也就是我们需要找到 第一个比ageLimit年轻的timestamp的位置
                                     vt.erase(vt.begin(), upper_bound(vt.begin(), // 从vt中除去所有 vt.end(), // 排在ageLimit的值前面 ageLimit)); // 或者等价的对象
    
    ```

    

  - equal_range回答：“它在吗，如果是，那么在哪儿?”equal_range返回一对迭代器，第一个等于lower_bound返回的迭代 器，第二个等于upper_bound返回的(也就是，等价于要搜索值区间的末迭代器的下一个)

    ```c++
    VWIterPair p = equal_range(vw.begin(), vw.end(), w);
    if (p.first != p.second) { // 如果equal_range不返回
    // 空的区间...
    ... // 说明找到了，p.first指向
    // 第一个而p.second
    // 指向最后一个的下一个
     else {
       // 没找到，p.first与p.second都指向搜索值要插入的位置
     }
      
     // equal_range很容易计数，调用distance算法即可
      distance(p.first, p.second)
    ```

    > 当然，也许叫equivalent_range（因为是『等价』来判别相同性的）会更好，但叫equal_range也非常好

- count与find算法都用『相等』来搜索，而binary_search、lower_bound、upper_bound和equal_range则用『等价』。

- 对于顺序容器，以上建议非常有用；对于关联容器（set, multiset, map, multimap），调用它们的成员函数往往比STL算法更好

### 46. 考虑使用函数对象代替函数作算法的参数

- 假设要降序排序一个double的vector，可以给sort算法传入函数对象，也可以传普通函数

  ```c++
  // 函数对象
  vector<double> v;
  sort(v.begin(), v.end(), greater<double>());
  
  // 普通函数
  inline
  bool doubleGreater(double d1, double d2) {
  	return dl > d2; 
  }
  ...
  sort(v.begin(), v.end(), doubleGreater);
  ```

- 很多人可能会认为经过内联的普通函数要比函数对象要快，但是实际是函数对象更快，因为函数对象的operator()也是内联，编译器在模板实例化的时候内联了，所以第一个sort没有额外的函数调用。而第二个sort函数实际上传入了一个函数指针，编译器产生间接函数调用

- 把函数指针作为参数会抑制内联的事实解释了一个长期使用C的程序员经常发现却难以相信的现象:在速度 上，C++的sort实际上总是使C的qsort感到窘迫。当然，C++有函数、实例化的类模板和看起来很有趣的 operator()函数需要调用，而C只是进行简单的函数调用，但所有的C++“开销”都在编译期被吸收。在运行 期，sort内联调用它的比较函数(假设比较函数已经被声明为inline而且它的函数体在编译期可以得到)而 qsort通过一个指针调用它的比较函数。结果是sort运行得更快

### 47. 避免产生直写型（write-only）代码

- 直写代码：很容易写，但很难读和理解
- 代码的读比写更经常，这是软件工程的真理。也就是说软件的维护比开发花费多得多的时间。不能读和理解 的软件不能被维护，不能维护的软件几乎没有不值得拥有

### 48. 总是#include适当的头文件

- 几乎所有的容器都在同名的头文件里，比如，vector在<vector>中声明，list在<list>中声明等。例外的是<set>和<map>。<set>声明了set和multiset，<map>声明了map和multimap。
- 除了四个算法外，所有的算法都在<algorithm>中声明。例外的是accumulate(参见条款37)、 inner_product、adjacent_difference和partial_sum。这些算法在<numeric>中声明。
- 特殊的迭代器，包括istream_iterators和istreambuf_iterators(参见条款29)，在<iterator>中声明。
- 标准仿函数(比如less<T>)和仿函数适配器(比如not1、bind2nd)在<functional>中声明。

### 49. 学习破解有关STL的编译器诊断信息

- string没有带int参数的构造函数，编译器报错如下

  ```c++
  example.cpp(20): error C2664:'__thiscall std::basic_string<char, struct std::char_traits<char>,class std::allocator<char> >::std::basic_string<char, struct std::char_traits<char>,class std::allocator<char> >(const class std::allocator<char> &)': cannot convert parameter 1 from 'const int' to 'const class std::allocator<char> &' Reason: cannot convert from 'const int' to 'const class std::allocator<char>
  No constructor could take the source type, or constructor overload resolution was ambiguous
  ```

- string不是一个类，它是一个typedef，这是因为字符串的C++观念已经被泛化为表示**带有任意字符特性(“traits”)**的**任意字符类型的序列**并储存 在以**任意分配器分类的内存**中。在C++里所有类似字符串的对象实际上都是basic_string模板的实例

  ```c++
  basic_string<char, char_traits<char>, allocator<char> >
  
  // 根据具体平台，下面报错信息更加常见，在脑子里面替换为std::string即可
  std::basic_string<char, struct std::char_traits<char>, class std::allocator<char> >
  ```

- 几乎所有STL实现都使用某种内在的模板来实现标准关联容器(set、multiset、map和multimap)。就 像使用string的源代码通常导致诊断信息提及basic_string一样，使用标准关联容器的源代码经常会导致诊断信 息提及一些内在的树模板，比如`std::_Tree`, `std::_tree`, `std::_rb_tree`

- 对于vector和string，迭代器有时是指针，所以如果你用迭代器犯了错误，编译器诊断信息可能会提及 涉及指针类型。例如，如果你的源代码涉及vector<double>::iterator，编译器消息有时会提及double*指 针。

- 提到back_insert_iterator、front_insert_iterator或insert_iterator的消息经常意味着你错误调用了 back_inserter、front_inserter或inserter，一一对应，

- 类似地，如果你得到的一条消息提及binder1st或binder2nd，你或许错误地使用了bind1st或bind2nd。 (bind1st返回binder1st类型的对象，而bind2nd返回binder2nd类型的对象。
- 输出迭代器(例如ostream_iterator、ostreambuf_iterators(参见条款29)，和从back_inserter、 front_inserter和inserter返回的迭代器)在赋值操作符内部做输出或插入工作，所以如果你错误使用了 这些迭代器类型之一，你很可能得到一条消息，抱怨在你从未听说过的一个赋值操作符里的某个东西
- 你得到一条源于STL算法实现内部的错误信息(即，源代码引发的错误在<algorithm>中)，也许是你 试图给那算法用的类型出错了。例如，你可能传了错误种类的迭代器
- 你使用常见的STL组件比如vector、string或for_each算法，而编译器说不知道你在说什么，你也许没有 #include一个需要的头文件

### 50. 让你自己熟悉有关STL的网站



```

```