# Effective C++

## 1. Accustoming Yourself to C++

### Item 1: View C++ as a federation of languages

C++应该被视为四个部分组成的联邦

- C：基础C的语法，因为C++兼容C
- 面向对象的C++：C with Class（ctor&dtor）、封装、继承、多态、虚函数（动态绑定）
- 模板C++：模板元编程
- STL

### Item 2: Prefer consts, enums, and inlines to #defines

- #defins对编译报错排查非常不友好

- const在C++中有很多用武之地，比#defines适用广泛

- enum 比const更像#defines，但没有#defines的副作用

- 模板+inlines可以节省函数调用的开销，比#defines好用

  ```c++
  // #defines函数
  #define CALL_WITH_MAX(a, b) f((a) > (b) ? (a) : (b))
  CALL_WITH_MAX(++a, b);          // a is incremented twice
  
  // 模板+inlines
  template<typename T>                               // because we don't
  inline void callWithMax(const T& a, const T& b)    // know what T is, we
  {                                                  // pass by reference-to-
    f(a > b ? a : b);                                // const — see Item 20
  }
  
  
  ```

### Item 3: Use `const` whenever possible

- constant可以帮助编译器检查使用错误

- constant多才多艺：you can use it for constants at global or namespace scope (see [Item 2](javascript:void(0))), as well as for objects declared `static` at file, function, or block scope. Inside classes, you can use it for both static and non-static data members. For pointers, you can specify whether the pointer itself is `const`, the data it points to is `const`, both, or neither

  ```c++
  char greeting[] = "Hello";
  
  char *p = greeting;                    // non-const pointer,
                                         // non-const data
  
  const char *p = greeting;              // non-const pointer,
                                         // const data
  
  char * const p = greeting;             // const pointer,
                                         // non-const data
  
  const char * const p = greeting;       // const pointer,
                                         // const data
  ```

- 注意const_iterator，它表现的像const T*（即指向常量的指针）

  ```c++
  std::vector<int> vec;
  ...
  
  const std::vector<int>::iterator iter =     // iter acts like a T* const
    vec.begin();
  *iter = 10;                                 // OK, changes what iter points to
  ++iter;                                    // error! iter is const
  
  std::vector<int>::const_iterator cIter =   //cIter acts like a const T*
    vec.begin();
  *cIter = 10;                               // error! *cIter is const
  ++cIter;                                  // fine, changes cIter
  ```

- const成员函数很好用，仅仅是函数的常量性也可以重载成员函数

  ```c++
  const char&                                       // operator[] for
   operator[](const std::size_t position) const      // const objects
   { return text[position]; }
   char&                                             // operator[] for
   operator[](const std::size_t position) const      // non-const objects
   { return text[position]; }
  ```

- 编译器只能bitwise-constness，即const成员函数不允许修改任何非static的成员变量，但是这样就无法检查那些指针成员变量，这样很可能会与预期不符；但有些时候需要使得成员变量可修改（如在length()成员函数中获取长度），则可以用mutable关键解决。编译器只能这样，但我们编写代码的时候一定要按照logical-constness去编写

- 当const成员函数与非const成员函数有重复代码时，可以用non-const版本去调用const版本，从而节省代码，非const版本对const并没有做出任何承诺，所以自由度更大

### Item 4: Make sure that objects are initialized before they're used

- 分清楚构造函数的初始化与赋值

  ```c++
  // 这是先给所有成员变量调用默认构造函数进行初始化，然后再给他们赋值
  ABEntry::ABEntry(const std::string& name, const std::string& address,
                   const std::list<PhoneNumber>& phones)
  {
    theName = name;                       // these are all assignments,
    theAddress = address;                 // not initializations
    thePhones = phones
    numTimesConsulted = 0;
  }
  
  // 直接进行成员变量初始化，而不是赋值，可以节约
  ABEntry::ABEntry(const std::string& name, const std::string& address,
                   const std::list<PhoneNumber>& phones)
  : theName(name),
    theAddress(address),                  // these are now all initializations
    thePhones(phones),
    numTimesConsulted(0)
  {} 
  ```

- 注意成员变量初始化的顺序并不是构造函数中写的那样，而是他们在类中的声明顺序！

## 2. Constructors, Destructors, and Assignment Operators

### Item 5: Know what functions C++ silently writes and calls

- 如果你像下面这样简单声明一个类，编译器会给你自动生成默认构造函数、默认析构函数、默认赋值函数

  ```c++
  
  class Empty{};
  
  class Empty {
  public:
    Empty() { ... }                            // default constructor
    Empty(const Empty& rhs) { ... }            // copy constructor
  
    ~Empty() { ... }                           // destructor — 
    Empty& operator=(const Empty& rhs) { ... } // copy assignment operator
  };
  
  
  
  ```

- 如果你写了构造函数，编译器就不会生成默认构造函数

- 默认拷贝构造函数与默认拷贝赋值函数仅仅把非static的成员变量拷贝过去（这又会调用成员变量的拷贝构造函数）

- 如果类的成员变量中有引用类型或者const类型，则**必须**由程序员手动编写拷贝赋值函数，否则编译器不知如何去生成默认的

### Item 6: Explicitly disallow the use of compiler-generated functions you do not want

- 编译器自动生成的四个默认函数都是public的，如果你不想类的使用者调用这些自动生成的默认函数，你可以将它们声明为private

- 进一步地，private函数仍可以被成员函数和友元函数调用，你可以仅声明它们为private，而不实现它，这样，类的使用者在链接阶段就会报错，这在C++的iostreams库中经常使用

  ```c++
  class Uncopyable {
  protected:                                   // allow construction
    Uncopyable() {}                            // and destruction of
    ~Uncopyable() {}                           // derived objects...
  
  private:
    Uncopyable(const Uncopyable&);             // ...but prevent copying
    Uncopyable& operator=(const Uncopyable&);
  };
  
  
  ```

- C++11支持delete关键字，直接在被禁用的函数后面加上delete即可，如果有人使用，编译器会直接报错的

### Item 7: Declare destructors virtual in polymorphic base classes

- when a derived class object is deleted through a pointer to a base class with a non-virtual destructor, results are undefined.
- 有可能发生的是：派生类的基类部分被析构了，但是派生类所特有的那部分成员变量没有被析构，这就是『部分析构』的问题，造成内存泄露
- 所以一定要在基类的析构函数前加上virtual关键字，保证这是个虚函数
- 但如果确定某个类不会被继承，那就不要加virtual关键字，因为虚函数会带来额外的内存开销（虚表指针）
- 知识点：纯虚函数会让类变成抽象类，抽象类无法实例化，只能作为基类。那如果我想让一个类变成抽象类，但是没有哪个虚函数可以被用作纯虚函数（纯虚函数意味着派生类一定要重写它），这时可以把析构函数声明成纯虚函数

### Item 8: Prevent exceptions from leaving destructors

- Destructors should never emit exceptions. If functions called in a destructor may throw, the destructor should catch any exceptions, then swallow them or terminate the program.

- If class clients need to be able to react to exceptions thrown during an operation, the class should provide a regular (i.e., non-destructor) function that performs the operation.

### Item 9: Never call virtual functions during construction or destruction

- 知识点：构造函数的构造顺序是先执行基类的构造函数，再执行派生类的构造函数；析构函数的析构顺序是先执行派生类的析构函数，再执行基类的析构函数；
- 在构造函数中调用虚函数，可能会读取派生类特有的成员变量，而这些成员变量还未初始化，读取还未初始化的变量是非常危险的，在还未调用派生类构造函数之前，该对象还是基类类型
- 在析构函数中调用虚函数，可能读取派生类特有的成员变量时，这些成员变量已经析构了，

### Item 10: Have assignment operators return a reference to `*this`

- 建议赋值运算符返回`*this`，这样就可以连续赋值了

  ```c++
  int x, y, z;
  
  x = y = z = 15;                        // chain of assignments
  x = (y = (z = 15));  									 // 解析顺序
  ```

- 不仅`operator=`，`operator+=`等赋值运算符建议都这样

  ```c++
  class Widget {
  public:
    ...
    Widget& operator+=(const Widget& rhs   // the convention applies to
    {                                      // +=, -=, *=, etc.
     ...
     return *this;
    }
     Widget& operator=(int rhs)            // it applies even if the
     {                                     // operator's parameter type
        ...                                // is unconventional
        return *this;
     }
     ...
  };
  ```

- 所有的内置类型以及标准库几乎都这样操作了，你最好也这样，除非你有充足的理由

### Item 11: Handle assignment to self in `operator=`

- 赋值函数的编写要考虑**自赋值**的情况，很多时候使用者会不经意使用了自赋值，如a[i]=a[j] or *p = *q，考虑以下场景：Widget持有一个指向Bitmap的裸指针，这时需要小心处理赋值函数的自赋值情况

  ```c++
  class Bitmap { ... };
  
  class Widget {
    ...
  
  private:
    Bitmap *pb;                                     // ptr to a heap-allocated object
  };
  ```

  

- 方法一（不推荐）：仅使用地址判断，这是一种异常不安全的方法，，假设在new的时候发生异常（比如内存不够），那么pb就指向一个已删除的bitmap，既不能安全的读，也不能安全的删除

  ```c++
  Widget& Widget::operator=(const Widget& rhs)
  {
    if (this == &rhs) return *this;   // identity test: if a self-assignment,
                                      // do nothing
    delete pb;
    pb = new Bitmap(*rhs.pb);
  
    return *this;
  }
  ```

- 方法二（还可以）：先复制指针，这是一种异常安全的方法，即使在new的时候发生异常，pb也不会便

  ```c++
  Widget& Widget::operator=(const Widget& rhs)
  {
    Bitmap *pOrig = pb;               // remember original pb
    pb = new Bitmap(*rhs.pb);         // point pb to a copy of rhs's bitmap
    delete pOrig;                     // delete the original pb
    return *this;
  }
  ```

- 方法三（推荐）：copy-and-swap技巧，非常有用

  ```c++
  class Widget {
    ...
    void swap(Widget& rhs);   // exchange *this's and rhs's data;
    ...                       // see Item 29 for details
  };
  
  Widget& Widget::operator=(const Widget& rhs)
  {
    Widget temp(rhs);             // make a copy of rhs's data
  
    swap(temp);                   // swap *this's data with the copy's
    return *this;
  }
  ```

### Item 12: Copy all parts of an object

- 知识点：编译器默认生成的拷贝函数（拷贝构造&&拷贝赋值）会把每个成员变量拷贝过去

- 当你自己编写了拷贝函数，你肯定不喜欢默认的拷贝函数，当你编写了拷贝函数后，又往里面添加了成员变量，如果不修改原来的拷贝函数，那么会造成**部分拷贝**的问题（同时你也要修改构造函数与operator=）

- 当有继承关系时，派生类的拷贝函数别忘记拷贝基类的成员变量

  ```c++
  class Customer {
    ...
  };
  class PriorityCustomer: public Customer{
    ...
  };
  
  PriorityCustomer&
  PriorityCustomer::operator=(const PriorityCustomer& rhs)
  {
    logCall("PriorityCustomer copy assignment operator");
  
    Customer::operator=(rhs);           // assign base class parts
    priority = rhs.priority;
  
    return *this;
  }
  ```

- 不应在拷贝赋值函数中调用拷贝构造函数，因为拷贝赋值函数是在对象已存在的时候才调用的

- 同理，不应在拷贝构造函数中调用拷贝赋值函数，因为拷贝构造函数是在对象还不存在的时候才调用的

- 如果你发现，拷贝构造函数与拷贝赋值函数有许多重复代码段，那么可以抽出一个private成员函数（一般叫init函数）来节省代码

## Resource Management

### Item 13: Use objects to manage resources.（RAII：Resource Acquisition Is Initialization）

- 把对象的指针直接给使用者，很容易造成内存泄露，因为我们没法保证使用者的操作会不会遗漏delete
- 最好的方法是用工厂方法把对象包裹在指针（特别是引用计数的智能指针，reference-counting smart pointer，RCSP）中，返回给使用者，这样在类的析构函数中就会自动释放内存，不用操心使用者的使用方式了
- 因为拷贝auto_ptr会置空，所以用tr1::shared_ptr通常是个更好的选择

### Item 14: Think carefully about copying behavior in resource-managing classes.

- 不是所有的资源都是在堆中的， 所以智能指针不合适来管理这些资源
- 比如，一个叫lock_guard的类来管理lock，这样lock的使用者就不用担心忘记调用unlock了，但是这时lock_guard被拷贝了怎么办？可以为lock_guard禁止拷贝（参考item6，将拷贝函数设为privite，或者用C++11中的delete关键字）

### Item 15: Provide access to raw resources in resource-managing classes.

- 智能指针如shared_ptr提供了get()函数获得原来的裸指针，已获得向C API的兼容

### Item 16: Use the same form in corresponding uses of `new` and `delete`.

- 知识点：new关键字干两件事，通过operator new分配内存，一个或多个构造函数在那片内存上被调用；delete关键字也干两件事，一个或多个析构函数在那片内存上被调用，然后通过operator delete释放内存
- If you use `[]` in a `new` expression, you must use `[]` in the corresponding `delete` expression. If you don't use `[]` in a `new` expression, you mustn't use `[]` in the corresponding `delete` expression.

### Item 17: Store `newed` objects in smart pointers in standalone statements.

- 使用智能指针管理对象时要在单独声明的语句中执行，否则在异常情况会有内存泄露

  ```c++
  processWidget(std::tr1::shared_ptr<Widget>(new Widget), priority());
  ```

- 编译器可能出于效率考虑编排顺序，假设顺序如下，而在priority发生异常时，new出来的内存就会被泄露

  ```c++
  1. 执行new Widget
  2. 调用priority()函数
  3. 调用std::tr1::shared_ptr的构造函数
  ```

- 感觉这种情况挺极端的，一般大家都会这样写吧

  ```c++
  std::tr1::shared_ptr<Widget> pw(new Widget);  // store newed object
                                                // in a smart pointer in a
                                                // standalone statement
  
  processWidget(pw, priority());                // this call won't leak
  ```

## Designs and Declarations

### Item 18: Make interfaces easy to use correctly and hard to use incorrectly

- Ways to prevent errors include creating new types, restricting operations on types, constraining object values, and eliminating client resource management responsibilities.i

### Item 19: Treat class design as type design

- How should objects of your new type be created and destroyed?--`operator new`, `operator new[]`, `operator delete`, and `operator delete[]`
- How should object initialization differ from object assignment?
- What does it mean for objects of your new type to be passed by value?--defined by copy constructor
- What are the restrictions on legal values for your new type?--parameters of ctors must be valid
-  **Does your new type fit into an inheritance graph?**--如果新类继承自某个基类，那就要遵守已存在的继承体系，如果新类要作为其他类的基类，就要注意virtual的声明
- What kind of type conversions are allowed for your new type?
- What standard functions should be disallowed?--用private或delete关键字声明成员函数
-  **Who should have access to the members of your new type?**--public ? private ?
- What is the “undeclared interface” of your new type?
- How general is your new type?
-  **Is a new type really what you need?** 

### Item 20: Prefer pass-by-reference-to-`const` to pass-by-value

- pass-by-value需要多次调用构造函数和析构函数，传const引用可以节省
- 传const引用可以避免slicing problem，即当一个派生类对象被按值传递为基类对象，这样就只调用了基类对象的构造函数，派生类对象特有的部分就被sliced off了
- 对于C++的内置类型，如int，还是pass-by-values效率更高，因为引用在编译器的角度看来就是指针，解引用是需要性能的，主要有些大的内置类型，如STL的容器，里面不止有一个指针，所以还是pass-by-reference-to-const最好
- 总之，对于内置类型、STL迭代器以及函数对象类型，可以考虑pass-by-value，其他的都可以用paas-by-reference-to-const

### Item 21: Don't try to return a reference when you must return an object

- Never return a pointer or reference to a local stack object, a reference to a heap-allocated object, or a pointer or reference to a local static object if there is a chance that more than one such object will be needed.

  ```c++
  inline const Rational operator*(const Rational& lhs, const Rational& rhs)
  {
    return Rational(lhs.n * rhs.n, lhs.d * rhs.d);
  }
  ```

  

### Item 22: Declare data members `private`

- 保持一致性，用户只能使用成员函数来获取成员
- 这样就可以提供只读、只写、可读写的成员变量
- 对成员封装，用户看不到实际值，对用户暴露的接口只需要提供不变的语义即可，类的作者可以在后面改变行为，如果一开始就给用户暴露了成员变量，那么推动用户去修改他们的代码是很困难的

### Item 23: Prefer non-member non-friend functions to member functions

- 封装性：我们对一个东西封装得越多，它暴露的东西就越少，那么我们对它的修改灵活性就大大提高了
- 知识点：only members and friends have access to private members.
- 因为成员函数还可以看见private成员变量与private函数，所以封装性不如非友元成员函数好，所以我们更希望用non-member non-friend function
- Putting all convenience functions in multiple header files — but one namespace — also means that clients can easily extend the set of convenience functions. All they have to do is add more non-member non-friend functions to the namespace.

### Item 24: Declare non-member functions when type conversions should apply to all parameters

- If you need type conversions on all parameters to a function (including the one pointed to by the `this` pointer), the function must be a non-member.

  ```c++
  class Rational {
  
    ...                                             // contains no operator*
  };
  const Rational operator*(const Rational& lhs,     // now a non-member
                           const Rational& rhs)     // function
  {
    return Rational(lhs.numerator() * rhs.numerator(),
                    lhs.denominator() * rhs.denominator());
  }
  Rational oneFourth(1, 4);
  Rational result;
  
  result = oneFourth * 2;                           // fine
  result = 2 * oneFourth;                           // hooray, it works!
  ```

### Item 25: Consider support for a non-throwing `swap`

- swap函数默认调用std::swap，只需要类型T支持拷贝（构造or赋值）即可

  ```c++
  namespace std {
  
    template<typename T>          // typical implementation of std::swap;
    void swap(T& a, T& b)         // swaps a's and b's values
    {
      T temp(a);
      a = b;
      b = temp;
    }
  }
  ```

- 但如果你编写的类有pimpl（point to implementation）技法，swap仅需交换两个指针，如果使用std::swap会交换造成三次Widget的拷贝，还会造成三次WidgetImpl的拷贝，非常影响效率

  ```c++
  class WidgetImpl {                          // class for Widget data;
  public:                                     // details are unimportant
    ...
  
  private:
    int a, b, c;                              // possibly lots of data —
    std::vector<double> v;                    // expensive to copy!
    ...
  };
  
  class Widget {                              // class using the pimpl idiom
  public:
    Widget(const Widget& rhs);
    Widget& operator=(const Widget& rhs)      // to copy a Widget, copy its
    {                                         // WidgetImpl object. For
     ...                                      // details on implementing
     *pImpl = *(rhs.pImpl);                    // operator= in general,
     ...                                       // see Items 10, 11, and 12.
    }
    ...
  
  private:
    WidgetImpl *pImpl;                         // ptr to object with this
  };   
  ```

  这时可以这样编写swap，先写一个swap成员函数，在其中调用swap函数，然后在std命名空间全特化swap函数，这样swap成员函数就会调用这个全特化版本（注意我们一般不给std命名空间**加**模板，但是可以在std命名空间全特化模板）

  ```c++
  class Widget {                     // same as above, except for the
  public:                            // addition of the swap mem func
    ...
    void swap(Widget& other)
    {
      using std::swap;               // the need for this declaration
                                     // is explained later in this Item
  
      swap(pImpl, other.pImpl);      // to swap Widgets, swap their
    }                                // pImpl pointers
    ...
  };
  
  namespace std {
  
    template<>                       // revised specialization of
    void swap<Widget>(Widget& a,     // std::swap
                      Widget& b)
    {
      a.swap(b);                     // to swap Widgets, call their
    }                                // swap member function
  }
  
  
  ```

- 但， 加入Widget与WidgetImpl不是类，而是类模板，上面的swap方法就行不通了，因为：类模板可以偏特化，但函数模板不能偏特化，所以以下函数模板行不通

  ```c++
  namespace std {
    template<typename T>
    void swap<Widget<T> >(Widget<T>& a,      // error! illegal code!
                          Widget<T>& b)
    { a.swap(b); }
  }
  ```

- 如果使用了pimpl的类模板在命名空间下，可以这样编写swap，当swap两个Widget<T>对象时，C++的命名查找规则（即argument-dependent lookup）会找到Widget-specific version in WidgetStuff命名空间，这就是我们希望的

  ```c++
  namespace WidgetStuff {
    ...                                     // templatized WidgetImpl, etc.
  
    template<typename T>                    // as before, including the swap
    class Widget { ... };                   // member function
  
    ...
  
    template<typename T>                    // non-member swap function;
    void swap(Widget<T>& a,                 // not part of the std namespace
              Widget<T>& b)                                         
    {
      a.swap(b);
    }
  }
  ```

  

- 客户端视角的最佳写法，命名查找规则在全局命名空间或一个命名空间中查找T-specific的swap函数，如果没有，则用std::swap（记得用using声明），如果类模板的创建者在std命名空间中还编写了Widget-specific的std::swap特化版本，则会用它

  ```c++
  template<typename T>
  void doSomething(T& obj1, T& obj2)
  {
    using std::swap;           // make std::swap available in this function
    ...
    swap(obj1, obj2);          // call the best swap for objects of type T
    ...
  }
  ```

- 建议：swap成员函数永远不要抛异常，因为swap函数就是帮助类（类模板）提供强有力的异常安全保证。但非成员函数的swap没有这个保证，因为默认的swap是基于拷贝构造与拷贝赋值的，它俩允许抛异常

  ```shell
  Things to Remember
  • Provide a swap member function when std::swap would be inefficient for your type. Make sure your swap doesn't throw exceptions.
  • If you offer a member swap, also offer a non-member swap that calls the member. For classes (not templates), specialize std::swap, too.
  • When calling swap, employ a using declaration for std::swap, then call swap without namespace qualification.
  • It's fine to totally specialize std templates for user-defined types, but never try to add something completely new to std.
  ```

### Item 26: Postpone variable definitions as long as possible.

- 变量的定义要越晚越好，否则有可能白白执行默认构造函数与默认析构函数

- 变量的定义与初始化最好放一起，以提供性能

  ```c++
  // bad
    std::string encrypted;                // default-construct encrypted
    encrypted = password;                 // assign to encrypted
  
  // good
  std::string encrypted(password);        // define and initialize
                                            // via copy constructor
  ```

- 注意循环内外的变量定义区别，如果你知道赋值函数开销更小，可以使用方法A，特别是当n变大时，如果赋值函数开销很大，可以使用方法B

  > • Approach A: 1 constructor + 1 destructor + `n` assignments.

  > • Approach B: `n` constructors + `n` destructors.

  ```c++
  // Approach A: define outside loop   // Approach B: define inside loop
  
  Widget w;
  for (int i = 0; i < n; ++i){         for (int i = 0; i < n; ++i) {
    w = some value dependent on i;       Widget w(some value dependent on i);
    ...                                  ...
  }  
  ```

### Item 27: Minimize casting.

- C风格的老式转换

  ```c++
  
  // C-style casts look like this
  (T) expression                      // cast expression to be of type T
  
  // Function-style casts use this syntax:
  T(expression)                       // cast expression to be of type T
  ```

>  `const_cast` is typically used to cast away the constness of objects. It is the only C++-style cast that can do this.

> • `dynamic_cast` is primarily used to perform “safe downcasting,” i.e., to determine whether an object is of a particular type in an inheritance hierarchy. It is the only cast that cannot be performed using the old-style syntax. It is also the only cast that may have a significant runtime cost. (I'll provide details on this a bit later.)

> • `reinterpret_cast` is intended for low-level casts that yield implementation-dependent (i.e., unportable) results, e.g., casting a pointer to an `int`. Such casts should be rare outside low-level code. I use it only once in this book, and that's only when discussing how you might write a debugging allocator for raw memory (see [Item 50](javascript:void(0))).

> • `static_cast` can be used to force implicit conversions (e.g., non-`const` object to `const` object (as in [Item 3](javascript:void(0))), `int` to `double`, etc.). It can also be used to perform the reverse of many such conversions (e.g., `void*` pointers to typed pointers, pointer-to-base to pointer-to-derived), though it cannot cast from `const` to non-`const` objects. (Only `const_cast` can do that.)

- 在派生类中想调用有重写的基类函数，可以像下面这样解决

  ```c++
  class SpecialWindow: public Window {
  public:
    virtual void onResize() {
      Window::onResize();                    // call Window::onResize
      ...                                    // on *this
    }
    ...
  
  };
  ```

- 建议

- > • Avoid casts whenever practical, especially `dynamic_cast`s in performance-sensitive code. If a design requires casting, try to develop a cast-free alternative.

  > • When casting is necessary, try to hide it inside a function. Clients can then call the function instead of putting casts in their own code.

  > • Prefer C++-style casts to old-style casts. They are easier to see, and they are more specific about what they do.

### Item 28: Avoid returning “handles” to object internals.

- 类的private成员变量，如果用public的getter方法把它们的引用暴露出去，则会造成修改

  ```c++
  struct RectData {                    // Point data for a Rectangle
    Point ulhc;                        // ulhc = " upper left-hand corner"
    Point lrhc;                        // lrhc = " lower right-hand corner"
  };
  
  class Rectangle {
  public:
    ...
    Point& upperLeft() const { return pData->ulhc; } // 仅仅声明成const成员函数是没法阻止客户端修改成员变量的
    Point& lowerRight() const { return pData->lrhc; }
    ...
  private:
    std::tr1::shared_ptr<RectData> pData;
  };
  
  // 客户端代码
  Point coord1(0, 0);
  Point coord2(100, 100);
  
  const Rectangle rec(coord1, coord2);     // rec is a const rectangle from
                                           // (0, 0) to (100, 100)
  
  rec.upperLeft().setX(50);                // now rec goes from
                                           // (50, 0) to (100, 100)!
  ```

- 更好的做法：

  ```c++
  class Rectangle {
  public:
    ...
    const Point& upperLeft() const { return pData->ulhc; }
    const Point& lowerRight() const { return pData->lrhc; }
    ...
  };
  ```

### Item 29: Strive for exception-safe code.

- Exception-safe functions offer one of three guarantees:

  > • Functions offering the basic guarantee promise that if an exception is thrown, everything in the program remains in a valid state. 
  >
  > • Functions offering the strong guarantee promise that if an exception is thrown, the state of the program is unchanged.
  >
  > • Functions offering the nothrow guarantee promise never to throw exceptions, because they always do what they promise to do.

- 锁资源的管理最好由智能指针维护的对象来管理，像下面的代码，如果在new抛出了异常，则lock永远不会被释放

  ```c++
  void PrettyMenu::changeBackground(std::istream& imgSrc)
  {
    lock(&mutex);                      // acquire mutex (as in Item 14)
  
    delete bgImage;                    // get rid of old background
    ++imageChanges;                    // update image change count
    bgImage = new Image(imgSrc);       // install new background
  
    unlock(&mutex);                    // release mutex
  }
  ```

- 除了lock的问题，如果new时抛异常，上面的代码会使bgImage指向空，所以最好的做法是用智能指针来管理，只有当new成功时，reset函数才会被调用

  ```c++
  class PrettyMenu {
    ...
    std::tr1::shared_ptr<Image> bgImage;
    ...
  };
  
  void PrettyMenu::changeBackground(std::istream& imgSrc)
  {
    Lock ml(&mutex);
  
    bgImage.reset(new Image(imgSrc));  // replace bgImage's internal
                                       // pointer with the result of the
                                       // "new Image" expression
    ++imageChanges;
  }
  ```

### Item 30: Understand the ins and outs of inlining.

- 内联函数不需要函数调用开销，非常棒

- Bear in mind that `inline` is a request to compilers, not a command.

- 内联函数必须在头文件中！因为绝大多数构建环境都是在编译阶段做内联，为了用函数体替代函数调用，编译器必须知道函数是什么样子

- 模板也是经常放在头文件，理由同上

- 函数内联需要开销，会导致代码膨胀

- `virtual` means “wait until runtime to figure out which function to call,” and `inline` means “before execution, replace the call site with the called function.

  

- > • Limit most inlining to small, frequently called functions. This facilitates debugging and binary upgradability, minimizes potential code bloat, and maximizes the chances of greater program speed.

  > • Don't declare function templates `inline` just because they appear in header files.

> • Limit most inlining to small, frequently called functions. This facilitates debugging and binary upgradability, minimizes potential code bloat, and maximizes the chances of greater program speed.

> • Don't declare function templates `inline` just because they appear in header files.

### Item 31: Minimize compilation dependencies between files

- Avoid using objects when object references and pointers will do
- Depend on class declarations instead of class definitions whenever you can（只需要函数声明就可以
-  Provide separate header files for declarations and definitions

## 6. Inheritance and Object-Oriented Design

### Item 32: Make sure public inheritance models “is-a.”

- 如果类D public继承自类B，这意味着D也是一个B（is-a），但反过来不成立，这意味着使用B的地方，也能使用D，因为D是一个B
- 这也很容易理解：一个指向基类的指针，同时也可以指向派生类

### Item 33: Avoid hiding inherited names

- C++的同名局部变量会覆盖同名全局变量，这就是hiding names

- 在继承体系中，基类部分的内容被嵌入（nested）在派生类的作用域中，所以可以在派生类的作用域中调用其基类的方法或者读取成员，或者是enums，内嵌类，typedefs

- 基类的重载函数，会被派生类的同名函数所隐藏，即**重载无法被继承**

  ```c++
  class Base {
  private:
    int x;
  
  public:
    virtual void mf1() = 0;
    virtual void mf1(int);
  
    virtual void mf2();
  
    void mf3();
    void mf3(double);
    ...
  };
  
  class Derived: public Base {
  public:
    virtual void mf1();
    void mf3();
    void mf4();
    ...
  };
  
  d.mf1();                   // fine, calls Derived::mf1
  d.mf1(x);                  // error! Derived::mf1 hides Base::mf1
  
  d.mf2();                   // fine, calls Base::mf2
  
  d.mf3();                   // fine, calls Derived::mf3
  d.mf3(x);                  // error! Derived::mf3 hides Base::mf3
  ```

- 若想使重载也能被继承，需要使用**using**关键字（注意得在public域中）

  ```c++
  class Derived: public Base {
    public:
    using Base::mf1;       // make all things in Base named mf1 and mf3
    using Base::mf3;       // visible (and public) in Derived's scope
  
    virtual void mf1();
    void mf3();
    void mf4();
    ...
  };
  
  Derived d;
  int x;
  
  ...
  
  d.mf1();                 // still fine, still calls Derived::mf1
  d.mf1(x);                // now okay, calls Base::mf1
  
  d.mf2();                 // still fine, still calls Base::mf2
  
  d.mf3();                 // fine, calls Derived::mf3
  d.mf3(x);                // now okay, calls Base::mf3
  ```

  

### Item 34: Differentiate between inheritance of interface and inheritance of implementation

- 区别接口继承与实现继承，它们正好对应函数声明与函数定义的区别

- 知识点：纯虚函数会使得类变成抽象类，即无法被实例化，只能用于被继承的基类

  ```c++
  class Shape {
  public:
    virtual void draw() const = 0;
  
    virtual void error(const std::string& msg);
  
    int objectID() const;
  
    ...
  };
  ```

  

- **声明纯虚函数的意义在于，派生类仅仅继承了函数接口（funciton interface），就像上面的Shape::draw，具体的实现还是要派生类自己去定义**

- 从语法的角度，纯虚函数也可以有定义，调用纯虚函数的唯一方式是通过类名：

  ```c++
  class Rectangle: public Shape { ... };
  class Ellipse: public Shape { ... };
  
  
  Shape *ps = new Shape;              // error! Shape is abstract
  
  Shape *ps1 = new Rectangle;         // fine
  ps1->draw();                     // calls Rectangle::draw
  
  Shape *ps2 = new Ellipse;           // fine
  ps2->draw();                     // calls Ellipse::draw
  
  ps1->Shape::draw();                 // calls Shape::draw
  
  ps2->Shape::draw();                 // calls Shape::draw
  ```

- **声明虚函数的意义在于，派生类不仅可以继承函数接口，而且还可以继承默认实现，这意味着派生类如果不需要有特殊的实现，完全可以直接使用基类的默认实现**

- 派生类使用基类提供的虚函数默认实现，可能太过于隐式，如果基类作者想让继承者都显式声明一下，可以用下面这个技巧：因为纯虚函数，每个派生类都得重写fly方法，而基类又提供了defaultFly实现，所以派生类完全可以使用基类提供的这个默认实现

  ```c++
  class Airplane {
  public:
    virtual void fly(const Airport& destination) = 0;
  
    ...
  
  protected:
    void defaultFly(const Airport& destination) {
      // default code for flying an airplane to the given destination
        }
  };
  
  class ModelA: public Airplane {
  public:
    virtual void fly(const Airport& destination)
    { defaultFly(destination); }
  
    ...
  };
  
  class ModelB: public Airplane {
  public:
    virtual void fly(const Airport& destination)
    { defaultFly(destination); }
  
    ...
  };
  
  ```

- **声明非虚函数的意义在于，派生类继承了函数接口以及强制实现，毕竟非虚函数意味着不变量，不管在继承体系中如何变动**

- 建议：

  - The first mistake is to declare all functions non-virtual.
  - The other common problem is to declare all member functions virtual.

### Item 35: Consider alternatives to virtual functions

#### NVI / Tmpelate Method

- This basic design — having clients call private virtual functions indirectly through public non-virtual member functions — is known as the non-virtual interface (NVI) idiom. It's a particular manifestation of the more general design pattern called Template Method (模板方法)

  ```c++
  class GameCharacter {
  public:
    virtual int healthValue() const;        // return character's health rating;
    
  // NVI/模板方法
  class GameCharacter {
  public:
    int healthValue() const               // derived classes do not redefine
    {                                     
  
      ...                                 // do "before" stuff — see below
  
      int retVal = doHealthValue();       // do the real work
  
      ...                                 // do "after" stuff — see below
  
      return retVal;
    }
    ...
  
  private:
    virtual int doHealthValue() const     // derived classes may redefine this
    {
      ...                                 // default algorithm for calculating
    }                                     // character's health
  };
  ```

- NVI/模板方法的好处是可以固化before&after stuff，真正执行的代码交给派生类自己去实现，相当于把实现延后定义了

- NVI/模板方法还有一个好处是，固化了虚函数是何时被调用的（在before之后，在after之前），但虚函数是如何被实现的取决于派生类的实现

#### 策略模式

- Replace virtual functions with function pointer data members, a stripped-down manifestation of the Strategy design pattern.
- Different instances of the same character type can have different health calculation functions.

#### 通过tr1::function实现的策略模式

- Replace virtual functions with tr1::function data members, thus allowing use of any callable entity with a signature compatible with what you need. This, too, is a form of the Strategy design pattern.
- Replace virtual functions in one hierarchy with virtual functions in another hierarchy. This is the conventional implementation of the Strategy design pattern.

### Item 36: Never redefine an inherited non-virtual function

- 继承体系中的非虚函数是静态绑定的，That means that because `pB` is declared to be of type pointer-to-`B`, non-virtual functions invoked through `pB` will always be those defined for class `B`, even if `pB` points to an object of a class derived from `B`

- 而虚函数是动态绑定的，具体调用基类还是派生类的成员函数，取决于指针指向的对象是哪个

  ```c++
  class D: public B {
  public:
    void mf();                      // hides B::mf; see Item 33
  
    ...
  
  };
  
  D x;                              // x is an object of type D
  B *pB = &x;  
  D *pD = &x;
  
  pB->mf();                         // calls B::mf
  
  pD->mf();                         // calls D::mf
  ```

- 为什么不要重定义非虚函数：公开继承意味着is-a关系，适用于基类的一切东西应该也适用于派生类，而派生类继承的基类非虚函数也应该能够适用，既然能够适用，就不应该重定义它。如果真的出现要重定义非虚函数的情况，你要看看你的类设计是否合理（比如该方法是否应该变成虚函数）

### Item 37: Never redefine a function's inherited default parameter value

- 静态类型在编译器就决定了，而动态类型在运行时才知道

  ```c++
  Shape *ps;                       // static type = Shape*
  Shape *pc = new Circle;          // static type = Shape*
  Shape *pr = new Rectangle;       // static type = Shape*
  
  ps = pc;                       // ps's dynamic type is
                                 // now Circle*
  
  ps = pr;                       // ps's dynamic type is
                                 // now Rectangle*
  ```

- virtual functions are dynamically bound(late bound), but default parameter values are statically bound(early bound).

  ```c++
  class Shape {
  public:
    enum ShapeColor { Red, Green, Blue };
  
    // all shapes must offer a function to draw themselves
    virtual void draw(ShapeColor color = Red) const = 0;
  };
  class Rectangle: public Shape {
  public:
    // notice the different default parameter value — bad!
    virtual void draw(ShapeColor color = Green) const; // 不会如你所愿的调用Green默认参数
    ...
  };
  
  Shape *pr = new Rectangle;       // static type = Shape*
  pr->draw();                       // calls Rectangle::draw(Shape::Red)!
  ```

- 在继承体系中，如果你想修改虚函数的默认参数，这根本不管用，C++是出于运行时效率考量的，因为如果默认参数还是动态绑定的话，那么在运行时还得去找合适的虚函数默认参数

### Item 38: Model “has-a” or “is-implemented-in-terms-of” through composition

- 组合：Composition is the relationship between types that arises when objects of one type contain objects of another type.
- 组合意味着has-a的关系，或者是implemented in terms of的关系，has-a的关系很好理解，而implemented in terms of的关系可以这样理解：想象一下你正在设计一个set，但是STL默认的set模板是用二叉搜索树实现的，所以多包含了一些指针，你的程序对内存很吃紧，所以得自己实现一个，你决定用STL的list模板来实现，因为list允许重复，所以你的set肯定不能公开继承list（那意味着is-a）关系，你决定在你的set模板的成员函数中组合一个std::list，这个时候就说明了你的set is implemented in-terms-of std::set！
- In the application domain, composition means has-a. In the implementation domain, it means is-implemented-in-terms-of.

### Item 39: Use private inheritance judiciously（审慎地）

- 知识点：私有继承不能将派生类转换为基类（就像下面代码出错的那样），以及，私有继承自基类的成员函数，在派生类当中是private的  

  ```c++
  class Person { ... };
  class Student: private Person { ... };     // inheritance is now private
  
  void eat(const Person& p);                 // anyone can eat
  
  void study(const Student& s);              // only students study
  
  Person p;                                  // p is a Person
  Student s;                                 // s is a Student
  
  eat(p);                                    // fine, p is a Person
  
  eat(s);                                    // error! a Student isn't a Person
  ```

- 这也就意味着：私有继承是is-implemented-in-terms-of.，实现是被继承的，而接口是被忽略的

- 私有继承与组合一样，都是is-implemented-in-terms-of，use composition whenever you can, and use private inheritance whenever you must

- 一个用于私有继承的例子：empty base optimization (EBO)，仅能用于单层继承

  ```c++
  class Empty {};                      // has no data, so objects should
                                       // use no memory
  // sizeof(Empty) is 1
  class HoldsAnInt: private Empty {
  private:
    int x;
  };
  
  // sizeof(HoldsAnInt) == sizeof(int) // 因为空基类优化，继承空基类不需要额外内存
  ```

### Item 40: Use multiple inheritance judiciously

- 多重继承可能会导致歧义，当两个基类有同名函数时，派生类不知道调用哪个

- 多重继承会带来菱形继承问题，基类的成员变量在最底下的派生类可能会被复制两次，为了解决这个问题，可以使用虚继承，但是虚继承比普通继承会带来额外开销（size、speed。。），当虚基类没有任何成员变量时，虚继承是很实用的

  ```c++
  class File { ... };
  class InputFile: virtual public File { ... };
  class OutputFile: virtual public File { ... };
  class IOFile: public InputFile,
                public OutputFile
  { ... };
  ```

- 多重继承很难理解，但还是很有用的，当某个设计必须要用到多重继承时，大胆使用吧，只是要小心上述两个问题

## 7. Templates and Generic Programming

Templates are a wonderful way to save time and avoid code replication

### Item 41: Understand implicit interfaces and compile-time polymorphism

- 模板元编程，类与模板都支持接口与多态

  ```c++
  template<typename T>
  void doProcessing(T& w)
  {
    if (w.size() > 10 && w != someNastyWidget) {
       T temp(w);
       temp.normalize();
       temp.swap(w);
    }
  }
  
  
  • What's important is that the set of expressions that must be valid in order for the template to compile is the implicit interface that T must support.
  • The calls to functions involving w such as operator> and operator!= may involve instantiating templates to make these calls succeed. Such instantiation occurs during compilation. Because instantiating function templates with different template parameters leads to different functions being called, this is known as compile-time polymorphism.
  ```

- An explicit interface typically consists of function signatures, i.e., function names, parameter types, return types, etc. An implicit interface is quite different.It consists of **valid expressions**.比如下面代码中，类型T的size()函数不需要返回整形，只需要operator>能够在类型T与int之间使用即可，甚至可以是另一类型Y，只需要能够有隐式转换从Y到T

  ```c++
  template<typename T>
  void doProcessing(T& w)
  {
    if (w.size() > 10 && w != someNastyWidget) {
    ...
  ```

- 类的接口在函数签名上是显式的；而模板的接口是隐式的，而且是基于valid expression的

- 类的多态是通过虚函数实现的，发生在运行时；而模板的多态发生在模板实例化与函数重载解析时

### Item 42: Understand the two meanings of `typename`

- class关键字与typename关键字在声明模板类型参数时是一样的，但更推荐typename的写法，语义理解不容易出错，T不一定得是个class type，可以是int这种built-in type

  ```c++
  template<class T> class Widget;                 // uses "class"
  
  template<typename T> class Widget;              // uses "typename"
  ```

- The general rule is simple: anytime you refer to a **nested dependent type name** in a template, you must immediately precede it by the word `typename`.

  ```c++
  template<typename C>                           // this is valid C++
  void print2nd(const C& container)
  {
    if (container.size() >= 2) {
      typename C::const_iterator iter(container.begin()); // 如果不用typename关键字告诉编译器这是内嵌类型，编译器根本不知道iter是什么，所以编译就会报错
      ...
    }
  }
  ```

- 萃取：the type of thing pointed to by objects of type `IterT`，temp变量的类型就是由iter所指向的对象的类型，假设iter是`vector<int>::iterator`，那么temp就是type `int`，假设iter是`list<string>::iterator`，那么temp就是type `string`，`std::iterator_traits<IterT>::value_type`是内嵌类型，所以我们必须用typename关键字声明它

  ```c++
  template<typename IterT>
  void workWithIterator(IterT iter)
  {
    typename std::iterator_traits<IterT>::value_type temp(*iter);
    ...
  }
  
  // 为了简洁，可以用typedef
  typedef typename std::iterator_traits<IterT>::value_type value_type;
  
    value_type temp(*iter);
  ```

### Item 43: Know how to access names in templatized base classes

- 派生类调用基类的方法是可以的，但是模板派生类调用基类的方法不一定能成功

  ```c++
  class CompanyA {
  public:
    ...
    void sendCleartext(const std::string& msg);
    void sendEncrypted(const std::string& msg);
    ...
  };
  
  class CompanyB {
  public:
    ...
    void sendCleartext(const std::string& msg);
    void sendEncrypted(const std::string& msg);
    ...
  };
  
  
  template<typename Company>
  class MsgSender {
  public:
    ...                                   // ctors, dtor, etc.
  
    void sendClear(const MsgInfo& info)
    {
      std::string msg;
      create msg from info;
  
      Company c;
      c.sendCleartext(msg);
    }
  
    void sendSecret(const MsgInfo& info)   // similar to sendClear, except
    { ... }                                // calls c.sendEncrypted
  };
  
  // 假设有需求需要在发送的时候添加日志，这很容易联想到创建一个派生类来完成这项工作，但是编译器会报错！
  // 因为LoggingMsgSender继承自MsgSender<Company>，它并不知道这个类长什么样，所以就不知道有没有sendClear函数
  template<typename Company>
  class LoggingMsgSender: public MsgSender<Company> {
  public:
    ...                                    // ctors, dtor, etc.
    void sendClearMsg(const MsgInfo& info)
    {
      write "before sending" info to the log;
  
      sendClear(info);                     // call base class function;
                                           // this code will not compile!
      write "after sending" info to the log;
    }
    ...
  
  };
  // 换个角度进一步说明问题，假设有companyZ，它压根没有sendCleartext函数，所以上面的LoggingMsgSender根本无法适配
  class CompanyZ {                             // this class offers no
  public:                                      // sendCleartext function
    ...
    void sendEncrypted(const std::string& msg);
    ...
  };
  // 为了纠正这个问题，可以使用模板全特化total template specialization
  template<>                                 // a total specialization of
  class MsgSender<CompanyZ> {                // MsgSender; the same as the
  public:                                    // general template, except
    ...                                      // sendCleartext is omitted
    void sendSecret(const MsgInfo& info)
    { ... }
  };
  ```

- 为了解决在模板派生类中无法调用基类函数的问题，有三种方式：

  - this->

    ```c++
    template<typename Company>
    class LoggingMsgSender: public MsgSender<Company> {
    public:
    
      ...
    
      void sendClearMsg(const MsgInfo& info)
      {
        write "before sending" info to the log;
    
        this->sendClear(info);                // okay, assumes that
                                              // sendClear will be inherited
        write "after sending" info to the log;
      }
    
      ...
    
    };
    ```

  - using声明（注意这和item33的不同，item33阐述了基类函数被隐藏的问题，这里是编译器不去搜索基类空间除非我们显式告诉编译器

    ```c++
    template<typename Company>
    class LoggingMsgSender: public MsgSender<Company> {
    public:
      using MsgSender<Company>::sendClear;   // tell compilers to assume
      ...                                    // that sendClear is in the
                                             // base class
      void sendClearMsg(const MsgInfo& info)
      {
        ...
        sendClear(info);                   // okay, assumes that
        ...                                // sendClear will be inherited
      }
    
      ...
    };
    ```

  - `baseClass<T>::foo()`显式调用基类命名空间，这是最后考虑的方法，以为如果这个函数是虚函数，显式指定会阻止虚函数动态绑定的行为

    ```c++
    template<typename Company>
    class LoggingMsgSender: public MsgSender<Company> {
    public:
      ...
      void sendClearMsg(const MsgInfo& info)
      {
        ...
        MsgSender<Company>::sendClear(info);      // okay, assumes that
        ...                                       // sendClear will be
      }        
      ...
    };
    ```


### Item 44: Factor parameter-independent code out of templates

- 模板可能会带来代码膨胀，源代码可能看起来很紧凑，但是目标代码会急剧膨胀

- 在没有模板的代码里，我们写代码也会遵从 commonality and variability analysis，在代码复用上不自觉地践行，在非模板代码里，代码重复是显性的，但是在模板代码里，代码重复是隐性的，因为它们来自于同一份源代码

  > • Templates generate multiple classes and multiple functions, so any template code not dependent on a template parameter causes bloat.

  > • Bloat due to non-type template parameters can often be eliminated by replacing template parameters with function parameters or class data members.

  > • Bloat due to type parameters can be reduced by sharing implementations for instantiation types with identical binary representations.

### Item 45: Use member function templates to accept “all compatible types.”

- generalized copy construction，我们可以从shared_ptr<Y>类型来构造shared_ptr<T>类型

  ```c++
  template<class T> class shared_ptr {
  public:
    shared_ptr(shared_ptr const& r);                 // copy constructor
  
    template<class Y>                                // generalized
      shared_ptr(shared_ptr<Y> const& r);            // copy constructor
  
    shared_ptr& operator=(shared_ptr const& r);      // copy assignment
  
    template<class Y>                                // generalized
      shared_ptr& operator=(shared_ptr<Y> const& r); // copy assignment
    ...
  };
  ```

- 如果没有用这项技法，那么shared_ptr<Base> 与shared_ptr<Derived>完全是两个类，如果想通过一个构造另一个，得像下面这样

  ```c++
  template<typename T>
  class SmartPtr {
  public:                             // smart pointers are typically
    explicit SmartPtr(T *realPtr);    // initialized by built-in pointers
    ...
  };
  
  SmartPtr<Top> pt1 =                 // convert SmartPtr<Middle> ⇒
    SmartPtr<Middle>(new Middle);     //   SmartPtr<Top>
  
  SmartPtr<Top> pt2 =                 // convert SmartPtr<Bottom> ⇒
    SmartPtr<Bottom>(new Bottom);     //   SmartPtr<Top>
  
  SmartPtr<const Top> pct2 = pt1;     // convert SmartPtr<Top> ⇒
                                      //  SmartPtr<const Top>
  ```

### Item 46: Define non-member functions inside templates when type conversions are desired

- 与item24一致，只不过是在模板的基础上

- When writing a class template that offers functions related to the template that support implicit type conversions on all parameters, define those functions as friends inside the class template.

### Item 47: Use traits classes for information about types

- 复习五种迭代器

  - input iterator：只能向前移动，每次只能一步，只能向指向的地方读取，istream_iterator是个例子

  - ouptut iterator：只能向前移动，每次只能一步，只能向指向的地方写入，ostream_iterator是个例子

  - forward iterator：可以向指向的地方读取或者写入，是上两个的结合增强

  - bidrectional iterator：在forward iterator的基础上可以向后移动

  - random access iterator：可以向前向后跳跃移动，比如vector、deque、string的迭代器就属于这种

  - C++标准库中有tag struct来区分它们

    ```c++
    
    struct input_iterator_tag {};
    
    struct output_iterator_tag {};
    
    struct forward_iterator_tag: public input_iterator_tag {};
    
    struct bidirectional_iterator_tag: public forward_iterator_tag {};
    
    struct random_access_iterator_tag: public bidirectional_iterator_tag {};
    ```

    

- advance是函数模板，用于把指定指针移动指定距离，签名如下

  ```c++
  template<typename IterT, typename DistT>       // move iter d units
  void advance(IterT& iter, DistT d);            // forward; if d < 0,
                                                 // move iter backward
  ```

- 如果要完全兼容五种迭代器，则advance的实现得逐步遍历（因为前四种不支持运算符operator+=，这需要线性时间，一种优化方法是分辨当前的迭代器类型，再做判断，这正是萃取traits技术的用武之地

  ```c++
  template<typename IterT, typename DistT>
  void advance(IterT& iter, DistT d)
  {
    if (iter is a random access iterator) {
       iter += d;                                      // use iterator arithmetic
    }                                                  // for random access iters
    else {
      if (d >= 0) { while (d--) ++iter; }              // use iterative calls to
      else { while (d++) --iter; }                     // ++ or -- for other
    }                                                  // iterator categories
  }
  ```

- 萃取技术需要用到iterator_traits结构体

  ```c++
  template<typename IterT>          // template for information about
  struct iterator_traits;           // iterator types
  ```

- 对于用户定义的迭代器，每个迭代器类型必须包含内嵌的typedef iterator_category，比如deque与list

  ```c++
  template < ... >                    // template params elided
  class deque {
  public:
    class iterator {
    public:
      typedef random_access_iterator_tag iterator_category;
      ...
  
  
  template < ... >
  class list {
  public:
    class iterator {
    public:
      typedef bidirectional_iterator_tag iterator_category;
      ...
  
  ```

  - iterator_traits结构体中就包含了这个typedef

  ```c++
    // the iterator_category for type IterT is whatever IterT says it is;
    // see Item 42 for info on the use of "typedef typename"
    template<typename IterT>
    struct iterator_traits {
      typedef typename IterT::iterator_category iterator_category;
      ...
    };
  ```

- 对于指针，iterator_traits使用了偏特化技术，指针行为类似random access iterator，所以

  ```c++
  template<typename IterT>               // partial template specialization
  struct iterator_traits<IterT*>         // for built-in pointer types
  
  {
    typedef random_access_iterator_tag iterator_category;
    ...
  };
  ```

- 现在，我们可以总结traits类的设计实现：

  - Identify some information about types you'd like to make available (e.g., for iterators, their iterator category).
  - Choose a name to identify that information (e.g., `iterator_category`).
  - Provide a template and set of specializations (e.g., `iterator_traits`) that contain the information for the types you want to support.

- 现在，我们就可以重新定义advance模板函数了

  ```c++
  template<typename IterT, typename DistT>
  void advance(IterT& iter, DistT d)
  {
    if (typeid(typename std::iterator_traits<IterT>::iterator_category) ==
       typeid(std::random_access_iterator_tag))
    ...
  }
  ```

- 但是，上面的代码还是有点问题，if语句在运行时才知道，我们真正需要的是在编译期有条件地构造类型，这正是函数重载的用武之地

  ```c++
  template<typename IterT, typename DistT>
  void advance(IterT& iter, DistT d)
  {
    doAdvance(                                              // call the version
      iter, d,                                              // of doAdvance
      typename                                              // that is
        std::iterator_traits<IterT>::iterator_category()    // appropriate for
    );                                                      // iter's iterator
  }     
  
  template<typename IterT, typename DistT>              // use this impl for
  void doAdvance(IterT& iter, DistT d,                  // random access
                 std::random_access_iterator_tag)       // iterators
  
  {
    iter += d;
  }
  
  template<typename IterT, typename DistT>              // use this impl for
  void doAdvance(IterT& iter, DistT d,                  // bidirectional
                 std::bidirectional_iterator_tag)       // iterators
  {
    if (d >= 0) { while (d--) ++iter; }
    else { while (d++) --iter;         }
  }
  
  template<typename IterT, typename DistT>              // use this impl for
  void doAdvance(IterT& iter, DistT d,                  // input iterators
                 std::input_iterator_tag)
  {
    if (d < 0 ) {
       throw std::out_of_range("Negative distance");    // see below
    }
    while (d--) ++iter;
  }
  
  
  ```

### Item 48: Be aware of template metaprogramming

- 模板元编程是用C++写的程序，它的执行时机是**C++的编译期**，产出结果是模板实例化后的C++源代码
- Template metaprogramming can shift work from runtime to compile-time, thus enabling earlier error detection and higher runtime performance.
- TMP can be used to generate custom code based on combinations of policy choices, and it can also be used to avoid generating code inappropriate for particular types.

## 8. Customizing new and delete

- C++不像Java有Garbage Collection（GC）机制，主要靠operator new 与opertor delete负责内存的申请与释放，还有个辅助角色：new-handler
- 多个对象用operator new[]与operator delete[]
- STL容器的内存由allocator对象管理，而不是直接由new与delete管理

### Item 49: Understand the behavior of the new-handler

- 当operator new无法满足内存申请，就会抛出异常，用户可以用std::set_new_handler来捕获

  ```c++
  namespace std {
  
    typedef void (*new_handler)();
    new_handler set_new_handler(new_handler p) throw();
  }
  
  
  // function to call if operator new can't allocate enough memory
  void outOfMem()
  {
    std::cerr << "Unable to satisfy request for memory\n";
    std::abort();
  }
  
  int main()
  {
    std::set_new_handler(outOfMem);
    int *pBigDataArray = new int[100000000L];
    ...
  }
  ```

- new-handler的设计可以从以下建议中挑选一个：

  - Make more memory available
  - Install a different new-handler
  - Deinstall the new-handler
  - Throw an exception
  - Not return, typically by calling `abort` or `exit`.

- 可以为不同的类个性化定制new-handler

  ```c++
  class Widget {
  public:
    static std::new_handler set_new_handler(std::new_handler p) throw();
    static void * operator new(std::size_t size) throw(std::bad_alloc);
  private:
    static std::new_handler currentHandler;
  };
  
  // Static class members must be defined outside the class definition
  std::new_handler Widget::currentHandler = 0;    // init to null in the class
                                                  // impl. file
  
  // 注意Widget类的set_new_handler函数，仅仅做传递，为啥要保存见下面第二点
  std::new_handler Widget::set_new_handler(std::new_handler p) throw()
  {
    std::new_handler oldHandler = currentHandler;
    currentHandler = p;
    return oldHandler;
  }
  ```

  - 现在，`Widget`'s `operator new`会做下面三件事
    1. Call the standard `set_new_handler` with `Widget`'s error-handling function. This installs `Widget`'s new-handler as the global new-handler.
    2. Call the global `operator new` to perform the actual memory allocation. If allocation fails, the global `operator new` invokes `Widget`'s new-handler. In that case, `Widget`'s `operator new` must restore the original global new-handler, then propagate the exception.
    3. If the global `operator new` was able to allocate enough memory for a `Widget` object, `Widget`'s `operator new` returns a pointer to the allocated memory. 

- new-handler也是资源，根据RAII思想，应该用对象来管理它

  ```c++
  class NewHandlerHolder {
  public:
    explicit NewHandlerHolder(std::new_handler nh)    // acquire current
    :handler(nh) {}                                   // new-handler
  
    ~NewHandlerHolder()                               // release it
    { std::set_new_handler(handler); }
  private:
    std::new_handler handler;                         // remember it
  
    NewHandlerHolder(const NewHandlerHolder&);        // prevent copying
    NewHandlerHolder&                                 // (see Item 14)
     operator=(const NewHandlerHolder&);
  };
  
  // Widget类的operator new就很简单了
  void * Widget::operator new(std::size_t size) throw(std::bad_alloc)
  {
    NewHandlerHolder                              // install Widget's
     h(std::set_new_handler(currentHandler));     // new-handler
  
    return ::operator new(size);                  // allocate memory
                                                  // or throw
    }                                               // restore global
                                                  // new-handler
  ```

- 最后，用户使用的代码如下：

  ```c++
  void outOfMem();                   // decl. of func. to call if mem. alloc.
                                     // for Widget objects fails
  
  Widget::set_new_handler(outOfMem); // set outOfMem as Widget's
                                     // new-handling function
  
  Widget *pw1 = new Widget;          // if memory allocation
                                     // fails, call outOfMem
  
  std::string *ps = new std::string; // if memory allocation fails,
                                     // call the global new-handling
                                     // function (if there is one)
  
  Widget::set_new_handler(0);        // set the Widget-specific
                                     // new-handling function to
                                     // nothing (i.e., null)
  
  Widget *pw2 = new Widget;          // if mem. alloc. fails, throw an
                                     // exception immediately. (There is
                                     // no new- handling function for
                                     // class Widget.)
  ```

### Item 50: Understand when it makes sense to replace `new` and `delete`

- 有时程序员想自定义new与delete的逻辑，出于以下原因：

  - 检测用户错误：用户可能忘记调用delete，或者调用两次
  - 改进效率：默认的new与delete是通用的，自定义的会更适合自己的程序，提升效率
  - 收集用户数据
  - 减少内存开销

- C++要求所有的opeartor new返回的指针对于任意类型是**内存对齐**的，下面代码中返回的是malloc offset by the size of an int，这很有可能会造成崩溃

  ```c++
  static const int signature = 0xDEADBEEF;
  
  typedef unsigned char Byte;
  
  // this code has several flaws—see below
  void* operator new(std::size_t size) throw(std::bad_alloc)
  {
    using namespace std;
  
    size_t realSize = size + 2 * sizeof(int);    // increase size of request so2
                                                 // signatures will also fit inside
  
    void *pMem = malloc(realSize);               // call malloc to get theactual
    if (!pMem) throw bad_alloc();                // memory
  
    // write signature into first and last parts of the memory
     *(static_cast<int*>(pMem)) = signature;
    *(reinterpret_cast<int*>(static_cast<Byte*>(pMem)+realSize-sizeof(int))) =
    signature;
  
    // return a pointer to the memory just past the first signature
    return static_cast<Byte*>(pMem) + sizeof(int);
  }
  ```

### Item 51: Adhere to convention when writing `new` and `delete`

- Implementing a conformant `operator new` requires having the right return value, calling the new-handling function when insufficient memory is available (see [Item 49](javascript:void(0))), and being prepared to cope with requests for no memory
- Return value of operator new:  If you can supply the requested memory, you return a pointer to it. If you can't, you follow the rule described in [Item 49](javascript:void(0)) and throw an exception of type `bad_alloc`.
- `operator new` should contain an infinite loop trying to allocate memory, should call the new-handler if it can't satisfy a memory request, and should handle requests for zero bytes. Class-specific versions should handle requests for larger blocks than expected.
- `operator delete` should do nothing if passed a pointer that is null. Class-specific versions should handle blocks that are larger than expected.

### Item 52: Write placement `delete` if you write placement `new`

- new一个对象有两步，调用operator new函数申请内存，然后再调用类的构造函数构造对象，如果第二步失败，则第一步申请的内存必须释放，否则就会内存泄露，用户无法参与到这个内存泄露的处理中来，必须由C++运行时系统来管理，operator delete函数必须找到对应的operator new所申请的内存地址，它才能释放掉这块内存

  ```c++
  Widget *pw = new Widget;
  
  // 默认的new与delete是配对的，C++运行时系统可以很轻松的找到对应的内存去释放
  void* operator new(std::size_t) throw(std::bad_alloc);
  
  void operator delete(void *rawMemory) throw();  // normal signature
                                                  // at global scope
  
  void operator delete(void *rawMemory,           // typical normal
                       std::size_t size) throw(); // signature at class
                                                  // scope
  ```

- 但假设用户自定义了operator new，在上述现象发生时，C++运行时系统找不到对应的内存去释放，会造成内存泄露，

  ```c++
  void* operator new(std::size_t, void *pMemory) throw();   // "placement
                                                            // new"
  ```

- C++标准库的placement new相比operator new有额外的入参，一个void *指针指向了对象在哪里被构建；但从广义上看，只要有额外的入参，都可以算作placement new的语义范畴

  ```c++
  void* operator new(std::size_t, void *pMemory) throw();   // "placement
                                                            // new"
  ```

- 只要用了placement new，就要用对应placement delete，否则就会有细微的、断断续续的内存泄露

- 使用placement new与placement delete时，要注意不要隐藏了普通版本的new与delete

## 9. Miscellany

### Item 53: Pay attention to compiler warnings

- Take compiler warnings seriously, and strive to compile warning-free at the maximum warning level supported by your compilers.
- Don't become dependent on compiler warnings, because different compilers warn about different things. Porting to a new compiler may eliminate warning messages you've come to rely on.

### Item 54: Familiarize yourself with the standard library, including TR1

- C++98 includes:

  ```shell
  • The Standard Template Library (STL), including containers (vector, string, map, etc.); iterators; algorithms (find, sort, transform, etc.); function objects (less, greater, etc.); and various container and function object adapters (stack, priority_queue, mem_fun, not1, etc.).
  • Iostreams, including support for user-defined buffering, internationalized IO, and the predefined objects cin, cout, cerr, and clog.
  • Support for internationalization, including the ability to have multiple active locales. Types like wchar_t (usually 16 bits/char) and wstring (strings of wchar_ts) facilitate working with Unicode.
  • Support for numeric processing, including templates for complex numbers (complex) and arrays of pure values (valarray).
  • An exception hierarchy, including the base class exception, its derived classes logic_error and runtime_error, and various classes that inherit from those.
  • C89's standard library. Everything in the 1989 C standard library is also in C++.
  ```

- TR1 (“Technical Report 1” from the C++ Library Working Group)

  - shared_ptr与weak_ptr，shared_ptr有引用计数机制，当最后一个指向对象的指针销毁时，对象所占用的内存自动释放，shared_ptr可以处理无环的数据结构，但无法处理有环的数据结构，因为会出现循环引用的问题，这时weak_ptr就派上用场了，weak_ptr不参与引用计数

  - tr1::function：可以代表任何可调用的实体（如函数或函数对象），比如下面代码可接受任何可调用的实体，只要以std::string作为函数返回值，int作为参数

    ```c++
    void registerCallback(std::tr1::function<std::string (int)> func);
                                                     // the param "func" will
                                                     // take any callable entity
                                                     // with a sig consistent
                                                     // with "std::string (int)"
    ```

  - tr1::bind：完全包含了STL的bind1st与bind2nd的功能

  - Hash Tables: `tr1::unordered_set`, `tr1::unordered_multiset`, `tr1::unordered_map`, and `tr1::unordered_multimap`.

  - Regular expressions

  - Tuples：比pair更强大，支持任意数量

  - tr1::array：STL版本的数组，支持begin、end成员函数，在编译期tr1::array的长度就固定了

  - Trype Trais

  - tr1::result_of

  - and so on

- TR1本身是个标准，需要一个具体的实现，Boost就是个很不错的库

### Item 55: Familiarize yourself with Boost.

- Boost库非常好，与C++标准联系紧密



# More Effective C++

## Basics

This chapter describes the differences between pointers and references

### Item 1:  Distinguish between pointers and references.

- 引用必须初始化，不能为空；而指针可以
- 当你需知道你所指向的东西肯定不为空时，可以用引用
- operator[]返回的是引用，这样就可以直接写：v[5]=10，如果operator[]返回的是指针，你需要这样写：*v[5]=10

### **Item 2:**Prefer C++-style casts.

- C的转换，C++的static_cast都能做
- const_cast是用来把常量性转换丢弃的，即把常量转换为非常量
- dynamic_cast是在继承体系中安全地向下转换，即把指向基类的指针或引用转换为指向派生类的，注意不能用于非虚函数，也不能去除常量性
- reinterpret_cast

### **Item 3:****Never treat arrays polymorphically.**

- C风格的数组，不支持C++的多态，因为array[i]其实是*(array+i)，而`i*sizeof(an object in the array)`是声明数组时的类型，无法保证多态性

### Item 4: Avoid gratuitous default constructors.

- 很多时候，默认的构造函数无法满足的我们对构造函数的要求

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