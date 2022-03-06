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