# 第三部分：类设计者的工具

第 13 章 拷贝控制 439

第 14 章 操作重载与类型转换 489

第 15 章 面向对象程序设计 525

第 16 章 模板与泛型编程 577

## Chapter13 拷贝控制

一个类通过定义五种特殊的成员函数来控制对象的拷贝、移动、赋值和销毁操作。

- 拷贝构造函数（copy constructor）
- 拷贝赋值运算符（copy-assignment operator）
- 移动构造函数（move constructor）
- 移动赋值运算符（move-assignment operator）
- 析构函数（destructor）

这些操作统称为拷贝控制操作（copy control）。

在定义任何类时，拷贝控制操作都是必要部分。

### 拷贝、赋值与销毁

#### 拷贝构造函数（The Copy Constructor）

如果一个构造函数的第一个参数是自身类类型的引用（几乎总是 `const` 引用），且任何额外参数都有默认值，则此构造函数是拷贝构造函数。

```c++
class Foo
{
public:
    Foo();   // default constructor
    Foo(const Foo&);   // copy constructor
    // ...
};
```

> 为什么一定是引用类型？
>
> 因为拷贝构造函数的参数若不是引用类型，则为了调用拷贝构造函数，必须拷贝它的实参，但为了拷贝实参，我们又需要调用拷贝构造函数，如此循环。

由于拷贝构造函数在一些情况下会被隐式使用，因此通常不会声明为 `explicit` 的。

如果类未定义自己的拷贝构造函数，编译器会为类合成一个。一般情况下，**合成拷贝构造函数（synthesized copy constructor）**会将其参数的非 `static` 成员逐个拷贝到正在创建的对象中。

```c++
class Sales_data
{
public:
    // other members and constructors as before
    // declaration equivalent to the synthesized copy constructor
    Sales_data(const Sales_data&);    
private:
    std::string bookNo;
    int units_sold = 0;
    double revenue = 0.0;
};

// equivalent to the copy constructor that would be synthesized for Sales_data
Sales_data::Sales_data(const Sales_data &orig):
    bookNo(orig.bookNo),    // uses the string copy constructor
    units_sold(orig.units_sold),    // copies orig.units_sold
    revenue(orig.revenue)   // copies orig.revenue
    { } // empty bod
```

使用直接初始化时，实际上是要求编译器按照函数匹配规则来选择与实参最匹配的构造函数。使用拷贝初始化时，是要求编译器将右侧运算对象拷贝到正在创建的对象中，如果需要的话还要进行类型转换。

```c++
string dots(10, '.');   // direct initialization
string s(dots);         // direct initialization
string s2 = dots;       // copy initialization
string null_book = "9-999-99999-9";    // copy initialization
string nines = string(100, '9');       // copy initialization
```

拷贝初始化通常使用拷贝构造函数来完成。但如果一个类拥有移动构造函数，则拷贝初始化有时会使用移动构造函数而非拷贝构造函数来完成。

发生拷贝初始化的情况：

- 用 `=` 定义变量。
- 将对象作为实参传递给非引用类型的形参。
- 从返回类型为非引用类型的函数返回对象。
- 用花括号列表初始化数组中的元素或聚合类中的成员。

当传递一个实参或者从函数返回一个值时，不能隐式使用 `explicit` 构造函数。

```c++
vector<int> v1(10);     // ok: direct initialization
vector<int> v2 = 10;    // error: constructor that takes a size is explicit
void f(vector<int>);    // f's parameter is copy initialized
f(10);      // error: can't use an explicit constructor to copy an argument
f(vector<int>(10));     // ok: directly construct a temporary vector from an int
```

#### 拷贝赋值运算符

**重载运算符（overloaded operator）**的参数表示运算符的运算对象，其本质是一个函数，其名字由`operator`关键字加上运算符组成，运算符函数也有返回类型和参数列表。如果一个运算符是成员函数，则其左侧运算对象会绑定到隐式的 `this` 参数上。

**拷贝赋值运算符**本身是一个重载的赋值运算符，定义为类的成员函数，左侧运算对象绑定到隐含的`this`参数，而右侧运算对象时所属类类型，作为函数的参数，函数返回指向其左侧运算对象的引用。当对类对象进行赋值时，会使用拷贝赋值运算符。

赋值运算符通常应该返回一个指向其左侧运算对象的引用。

```c++
class Foo
{
public:
    Foo& operator=(const Foo&);  // assignment operator
    // ...
};
```

标准库通常要求保存在容器中的类型要具有赋值运算符，且其返回值是**左侧运算对象的引用**。

如果类未定义自己的拷贝赋值运算符，编译器会为类**合成**一个。一般情况下，**合成拷贝赋值运算符（synthesized copy-assignment operator）**会将其右侧运算对象的非 `static` 成员逐个赋值给左侧运算对象的对应成员，之后返回左侧运算对象的引用。

```c++
// equivalent to the synthesized copy-assignment operator
Sales_data& Sales_data::operator=(const Sales_data &rhs)
{
    bookNo = rhs.bookNo;    // calls the string::operator=
    units_sold = rhs.units_sold;    // uses the built-in int assignment
    revenue = rhs.revenue;  // uses the built-in double
    assignment
    return *this;   // return a reference to this object
}
```

#### 析构函数（The Destructor）

与构造函数相反，析构函数负责释放对象使用的资源，并销毁对象的非 `static` 数据成员。

析构函数的名字由波浪号 `~` 接类名构成，它没有返回值，也不接受参数。由于析构函数不接受参数，所以它不能被重载。

```c++
class Foo
{
public:
    ~Foo(); // destructor
    // ...
};
```

析构函数首先执行函数体，然后再销毁数据成员。**成员按照初始化顺序的逆序销毁**。

成员销毁时发生什么完全依赖于成员的类型，销毁类类型的成员需要执行成员自己的析构函数，内置类型没有析构函数。

隐式销毁一个内置指针类型的成员不会 `delete` 它所指向的对象。但是智能指针是类类型，具有析构函数，所以智能指针成员在析构阶段会被自动销毁。

**合成析构函数（synthesized destructor）**：当一个类未定义自己的析构函数时，编译器会为它定义合成的。

注意：析构函数体不销毁成员，成员是在析构函数体之后**隐含的析构阶段**中被销毁的，所以函数体经常为空。

#### 三/五法则

需要析构函数的类一般也需要拷贝和赋值操作。

- 比如合成的析构函数不会`delete`一个指针数据成员，所以需要析构函数，由此推断出拷贝和赋值操作也是需要的，用来`new`一个内存空间。

需要拷贝操作的类一般也需要赋值操作，反之亦然。

- 比如某个类的对象都有独一无二的序号，如果用合成的拷贝构造函数，则两个拷贝的两个对象序号一样，故需要拷贝构造函数，一般也需要拷贝赋值运算符。

#### 使用=default

可以通过将拷贝控制成员定义为 `=default` 来显式地要求编译器生成合成版本。

```c++
class Sales_data
{
public:
    // copy control; use defaults
    Sales_data() = default;
    Sales_data(const Sales_data&) = default;
    ~Sales_data() = default;
    // other members as before
};
```

在类内使用 `=default` 修饰成员声明时，合成的函数是隐式内联的。如果不希望合成的是内联函数，应该只对成员的类外定义使用 `=default`。

只能对具有合成版本的成员函数使用 `=default`。

#### 阻止拷贝

大多数类应该定义默认构造函数、拷贝构造函数和拷贝赋值运算符，无论是显式地还是隐式地。

但是有些类，如`iostream`阻止拷贝操作，以避免多个对象写入或读取相同的IO缓冲，为了阻止拷贝，一定要定义拷贝控制成员来实现阻止拷贝的效果，否则编译器会生成合成版本。

在 C++11 新标准中，将拷贝构造函数和拷贝赋值运算符定义为删除的函数（deleted function）可以阻止类对象的拷贝。删除的函数是一种虽然进行了声明，但是却不能以任何方式使用的函数。定义删除函数的方式是在函数的形参列表后面添加 `=delete`。

```c++
struct NoCopy
{
    NoCopy() = default; // use the synthesized default constructor
    NoCopy(const NoCopy&) = delete; // no copy
    NoCopy &operator=(const NoCopy&) = delete; // no assignment
    ~NoCopy() = default; // use the synthesized destructor
    // other members
};
```

`=delete` 和 `=default` 有两点不同：

- `=delete` 可以对任何函数使用；`=default` 只能对具有合成版本的函数使用。
- `=delete` 必须出现在函数第一次声明的地方；`=default` 既能出现在类内，也能出现在类外。

析构函数不能是删除的函数。对于析构函数被删除的类型，不能定义该类型的变量或者释放指向该类型动态分配对象的指针。

**如果一个类中有数据成员不能默认构造、拷贝或销毁，则对应的合成拷贝控制成员将被定义为删除的**。

在旧版本的 C++ 标准中，类通过将拷贝构造函数和拷贝赋值运算符声明为 `private` 成员来阻止类对象的拷贝。在新标准中建议使用 `=delete` 而非 `private`。

### 拷贝控制和资源管理

通常，管理类外资源的类必须定义拷贝控制成员。因为这种类需要析构函数释放资源，从而推测这种类也需要定义拷贝构造函数和拷贝赋值运算符。

#### 行为像值的类

类的行为像一个值，意味拷贝时，副本和原对象是完全独立的。像下面的`HasPtr`的成员变量`ps`指向的`string`，每个`HasPtr`对象都必须有自己的拷贝，于是需要拷贝构造函数、拷贝赋值函数、析构函数。

```c++
class HasPtr
{
public:
    HasPtr(const std::string &s = std::string()):
        ps(new std::string(s)), i(0) { }
    // each HasPtr has its own copy of the string to which ps points
    HasPtr(const HasPtr &p):
        ps(new std::string(*p.ps)), i(p.i) { }
    HasPtr& operator=(const HasPtr &);
    ~HasPtr() { delete ps; }
    
private:
    std::string *ps;
    int i;
};
```

编写赋值运算符时有两点需要注意：

- 即使将一个对象赋予它自身，赋值运算符也能正确工作，即能处理自赋值情况，并能保证异常发生时代码也是安全的。

  ```c++
  // WRONG way to write an assignment operator!
  HasPtr& HasPtr::operator=(const HasPtr &rhs)
  {
      delete ps;   // frees the string to which this object points
      // if rhs and *this are the same object, we're copying from deleted memory!
      ps = new string(*(rhs.ps));
      i = rhs.i;
      return *this;
  }
  ```

- 赋值运算符通常结合了拷贝构造函数和析构函数的工作。

  编写赋值运算符时，一个好的方法是先将右侧运算对象拷贝到一个**局部临时对象**中。拷贝完成后，就可以安全地销毁左侧运算对象的现有成员了。

  ```c++
  HasPtr& HasPtr::operator=(const HasPtr &rhs)
  {
      auto newp = new string(*rhs.ps);    // copy the underlying string
      delete ps;   // free the old memory
      ps = newp;   // copy data from rhs into this object
      i = rhs.i;
      return *this;   // return this object
  }
  ```

  > 自我感觉，上面的拷贝赋值函数可以使用**拷贝并交换（copy and swap）**技术，这也能解决自赋值的情况
  > ```c++
  > HasPtr& HasPtr::operator=(const HasPtr &rhs)
  > {
  >    HasPtr copy = rhs;
  >    std::swap(*this, copy);
  >    return *this;   // return this object
  > }
  > ```

#### 定义行为像指针的类

使用`shared_ptr`来管理类中的资源，可以使得类的行为像个指针。但有时，我们希望直接管理资源，这时使用**引用计数（reference count）**可以使得类的行为像个指针。

引用计数的工作方式与`shared_ptr`很像，需要以下几点：

- 每个构造函数（拷贝构造函数除外）创建一个引用计数，用来记录有多少个对象与正在创建的对象共享状态
- 拷贝构造函数不分配新的计数器，而是拷贝给定对象的数据成员，包括计数器，然后计数器递增，表明共享状态的对象多了一个
- 析构函数递减计数器，表明共享状态的对象少了一个，如果计数器变为0，则析构函数负责释放资源（比如内存）
- 拷贝赋值运算符递增右侧运算对象的计数器，递减左侧运算对象的计数器，如果左侧运算对象的计数器变为0，则销毁状态，释放资源

思考：引用计数可以用`static`成员来实现吗？

答：不行，`static`成员变量可以由该类所有对象共享，而不是所有类对象都共享状态，所以不行。

计数器不能直接作为对象的成员，应该将计数器保存在动态内存中，当创建一个对象时，我们也分配一个新的计数器，当拷贝或赋值对象时，拷贝指向计数器的指针。

`HasPtr`类的引用计数版本：

```c++
class HasPtr
{
public:
    // constructor allocates a new string and a new counter, which it sets to 1
    HasPtr(const std::string &s = std::string()):
        ps(new std::string(s)), i(0), use(new std::size_t(1)) {}
    // copy constructor copies all three data members and increments the counter
    HasPtr(const HasPtr &p):
        ps(p.ps), i(p.i), use(p.use) { ++*use; }
    HasPtr& operator=(const HasPtr&);
    ~HasPtr();

private:
    std::string *ps;
    int i;
    std::size_t *use; // member to keep track of how many objects share *ps
};
```

析构函数释放内存前应该判断是否还有其他对象指向这块内存，如果引用计数为0，则释放内存，拷贝赋值构造函数则检查左侧运算对象（即当前丢向）的引用计数是否为0。

```c++
HasPtr::~HasPtr()
{
    if (--*use == 0)
    {   // if the reference count goes to 0
        delete ps;   // delete the string
        delete use;  // and the counter
    }
}

HasPtr& HasPtr::operator=(const HasPtr &rhs)
{
    ++*rhs.use;    // increment the use count of the right-hand operand
    if (--*use == 0)
    {   // then decrement this object's counter
        delete ps; // if no other users
        delete use; // free this object's allocated members
    }
    ps = rhs.ps;    // copy data from rhs into this object
    i = rhs.i;
    use = rhs.use;
    return *this;   // return this object
}
```

### 交换操作

通常，管理类外资源的类会定义 `swap` 函数。如果一个类定义了自己的 `swap` 函数，算法将使用自定义版本，否则将使用标准库定义的 `swap`。

由于 `swap` 函数的存在就是为了优化代码，所以一般将其声明为内联函数。

我们更希望`swap`交换指针，而不是分配新的内存：

```c++
class HasPtr
{
    friend void swap(HasPtr&, HasPtr&);
    // other members as in § 13.2.1 (p. 511)
};

inline void swap(HasPtr &lhs, HasPtr &rhs)
{
    using std::swap;
    swap(lhs.ps, rhs.ps);   // swap the pointers, not the string data
    swap(lhs.i, rhs.i);     // swap the int members
}
```

与拷贝控制成员不同，`swap`并不是必要的，但是对于分配了资源的类，定义`swap`可能是一种很重要的**优化**手段。

一些算法在交换两个元素时会调用 `swap` 函数，其中每个 `swap` 调用都应该是未加限定的。如果存在类型特定的 `swap` 版本，其**匹配程度会优于 *std* 中定义的版本**（假定作用域中有 `using` 声明）。

```c++
void swap(Foo &lhs, Foo &rhs)
{
    // Not good: this function uses the library version of swap, not the HasPtr version
  	// equivalent to directly use swap in standard library
    std::swap(lhs.h, rhs.h);
    // swap other members of type Foo
}

void swap(Foo &lhs, Foo &rhs)
{
    using std::swap;
    swap(lhs.h, rhs.h);  // uses the HasPtr version of swap
    // swap other members of type Foo
}
```

定义了 `swap` 的类通常用 `swap` 来实现赋值运算符。在这种版本的赋值运算符中，右侧运算对象以值方式传递，赋值运算符使用了一种叫做**拷贝并交换（copy and swap）**的技术。这种方式可以正确处理**自赋值**情况且天然就是**异常安全的**。

```c++
// note rhs is passed by value, which means the HasPtr copy constructor
// copies the string in the right-hand operand into rhs
HasPtr& HasPtr::operator=(HasPtr rhs)
{
    // swap the contents of the left-hand operand with the local variable rhs
    swap(*this, rhs);   // rhs now points to the memory this object had used
    return *this;       // rhs is destroyed, which deletes the pointer in rhs
}
```

> std::swap in C++98
> ```c++
> template <class T> void swap ( T& a, T& b )
> {
>   T c(a); a=b; b=c;
> }
> ```
>
> std::swap in C++11
> ```c++
> template <class T> void swap (T& a, T& b)
> {
>   T c(std::move(a)); a=std::move(b); b=std::move(c);
> }
> template <class T, size_t N> void swap (T (&a)[N], T (&b)[N])
> {
>   for (size_t i = 0; i<N; ++i) swap (a[i],b[i]);
> }
> ```
>
> 可以看到，在C++11中，std::swap内部使用了std::move，这样速度更快

#### 拷贝控制示例

拷贝赋值运算符通常结合了拷贝构造函数和析构函数的工作。在这种情况下，公共部分应该放在 `private` 的工具函数中完成。

### 动态管理内存类

移动构造函数通常是将资源从给定对象 **“移动”** 而不是拷贝到正在创建的对象中。

### 对象移动（Moving Objects）

某些情况下，一个对象拷贝后就立即被销毁了，此时移动而非拷贝对象会大幅度提高性能。

在旧版本的标准库中，容器所能保存的类型必须是可拷贝的。但在新标准中，可以用容器保存不可拷贝，但可移动的类型。

标准库容器、`string` 和 `shared_ptr` 类既支持移动也支持拷贝。IO 类和 `unique_ptr` 类可以移动但不能拷贝。

#### 右值引用（Rvalue Reference）

为了支持移动操作，C++11 引入了右值引用类型。**右值引用就是必须绑定到右值的引用**。可以通过 `&&` 来获得右值引用。

右值引用有一个重要的性质——只能绑定到一个将要销毁的对象，所以我们可以自由地将一个右值引用的资源”移动“到另一个对象中，或使用右值引用自由地接管所引用对象的资源。

我们不能将左值引用绑定到要求转换的表达式、字面常量或是返回右值的表达式，而右值引用有着完全相反的绑定特性。

```c++
int i = 42;
int &r = i;         // ok: r refers to i
int &&rr = i;       // error: cannot bind an rvalue reference to an
int &r2 = i * 42;   // error: i * 42 is an rvalue
const int &r3 = i * 42;    // ok: we can bind a reference to const to an rvalue
int &&rr2 = i * 42;        // ok: bind rr2 to the result of the multiplication
```

左值与右值的区别：

- 左值是持久的，右值是短暂的

**变量可以看作只有一个运算对象而没有运算符的表达式**，而变量表达式都是左值，故我们不能将一个右值引用绑定到一个右值引用类型的变量上（有点反直觉）

```c++
int &&rr1 = 42;     // ok: literals are rvalues
int &&rr2 = rr1;    // error: the expression rr1 is an lvalue!
```

调用 `move` 函数可以获得绑定在左值上的右值引用，此函数定义在头文件 *utility* 中。

```c++
int &&rr3 = std::move(rr1);
```

调用 `move` 函数的代码应该使用 `std::move` 而非 `move`，这样做可以避免潜在的名字冲突。

#### 移动构造函数和移动赋值运算符

为了使我们的类支持移动操作，需要定义移动构造函数和移动赋值运算符。

移动构造函数的第一个参数是该类类型的右值引用，其他任何额外参数都必须有默认值。

除了完成资源移动，移动构造函数还必须确保移后源对象是可以安全销毁的。而且一旦移动完成，源对象就丧失了对被移动的资源的所有权。

新标准引入的，在函数的形参列表后面添加关键字 `noexcept` 可以指明该函数不会抛出任何异常。

对于构造函数，`noexcept` 位于形参列表和初始化列表开头的冒号之间。在类的头文件声明和定义中（如果定义在类外）都应该指定 `noexcept`。

```c++
class StrVec
{
public:
    StrVec(StrVec&&) noexcept;  // move constructor
    // other members as before
};

StrVec::StrVec(StrVec &&s) noexcept : /* member initializers */
{ /* constructor body */ }
```

标准库容器能对异常发生时其自身的行为提供保障。虽然移动操作通常不抛出异常，但抛出异常也是允许的。为了安全起见，除非容器确定元素类型的移动操作不会抛出异常，否则在重新分配内存的过程中，它就必须使用拷贝而非移动操作。

不抛出异常的移动构造函数和移动赋值运算符必须标记为 `noexcept`。

类似移动构造函数一样，如果移动赋值运算符不抛出任何异常，也应该标记为`noexcept`，类似拷贝赋值运算符，移动赋值运算符必须能处理自赋值的情况。

```c++
StrVec &StrVec::operator=(StrVec &&rhs) noexcept
{
    // direct test for self-assignment
    if (this != &rhs)
    {
        free();     // free existing elements
        elements = rhs.elements;    // take over resources from rhs
        first_free = rhs.first_free;
        cap = rhs.cap;
        // leave rhs in a destructible state
        rhs.elements = rhs.first_free = rhs.cap = nullptr;
    }
    return *this;
}
```

只有当一个类没有定义任何拷贝控制成员，且类的每个非 `static` 数据成员都可以移动时，编译器才会为类合成移动构造函数和移动赋值运算符。编译器可以移动内置类型的成员。如果一个成员是类类型，且该类有对应的移动操作，则编译器也能移动该成员。

```c++
// the compiler will synthesize the move operations for X and hasX
struct X
{
    int i;   // built-in types can be moved
    std::string s;   // string defines its own move operations
};

struct hasX
{
    X mem; // X has synthesized move operations
};

X x, x2 = std::move(x);         // uses the synthesized move constructor
hasX hx, hx2 = std::move(hx);   // uses the synthesized move constructor
```

与拷贝操作不同，移动操作永远不会被**隐式**定义为删除的函数。但如果显式地要求编译器生成 `=default` 的移动操作，且编译器不能移动全部成员，则移动操作会被定义为删除的函数。

定义了移动构造函数或移动赋值运算符的类必须也定义自己的拷贝操作，否则这些成员会被默认地定义为删除的函数。

如果一个类既有移动构造函数，又有拷贝构造函数，则根据函数匹配的原则来确定使用哪个构造函数，移动右值，拷贝左值。

如果一个类有可用的拷贝构造函数而没有移动构造函数，则其对象是通过拷贝构造函数来 “移动” 的，即使调用 `move` 函数时也是如此。拷贝赋值运算符和移动赋值运算符的情况类似。这种代替几乎肯定是安全的。

```c++
class Foo
{
public:
    Foo() = default;
    Foo(const Foo&);    // copy constructor
    // other members, but Foo does not define a move constructor
};

Foo x;
Foo y(x);   // copy constructor; x is an lvalue
Foo z(std::move(x));    // copy constructor, because there is no move constructor
```

使用非引用参数的单一赋值运算符可以实现拷贝赋值和移动赋值两种功能。依赖于实参的类型，左值被拷贝，右值被移动。

```c++
// assignment operator is both the move- and copy-assignment operator
HasPtr& operator=(HasPtr rhs)
{ 
    swap(*this, rhs);
    return *this;
}

hp = hp2;   // hp2 is an lvalue; copy constructor used to copy hp2
hp = std::move(hp2);    // move constructor moves hp2
```

建议将五个拷贝控制成员当成一个整体来对待。如果一个类需要任何一个拷贝操作，它就应该定义所有五个操作。

C++11 标准库定义了移动迭代器（move iterator）适配器。一个移动迭代器通过改变给定迭代器的解引用运算符的行为来适配此迭代器。移动迭代器的解引用运算符返回一个右值引用。

调用 `make_move_iterator` 函数能将一个普通迭代器转换成移动迭代器。原迭代器的所有其他操作在移动迭代器中都照常工作。

最好不要在移动构造函数和移动赋值运算符这些类实现代码之外的地方随意使用 `std::move` 操作。

#### 右值引用和成员函数

区分移动和拷贝的重载函数通常有一个版本接受一个 `const T&` 参数，另一个版本接受一个 `T&&` 参数（*T* 为类型）。

```c++
void push_back(const X&);   // copy: binds to any kind of X
void push_back(X&&);        // move: binds only to modifiable rvalues of type X
```

有时可以对右值赋值：

```c++
string s1, s2;
s1 + s2 = "wow!";
```

在旧标准中，没有办法阻止这种使用方式。为了维持向下兼容性，新标准库仍然允许向右值赋值。但是可以在自己的类中阻止这种行为，规定左侧运算对象（即 `this` 指向的对象）必须是一个左值。

在非 `static` 成员函数的形参列表后面添加**引用限定符（reference qualifier）**可以指定 `this` 的左值 / 右值属性。引用限定符可以是 `&` 或者 `&&`，分别表示 `this` 可以指向一个左值或右值对象。引用限定符必须同时出现在函数的声明和定义中。

```c++
class Foo
{
public:
    Foo &operator=(const Foo&) &; // may assign only to modifiable lvalues
    // other members of Foo
};

Foo &Foo::operator=(const Foo &rhs) &
{
    // do whatever is needed to assign rhs to this object
    return *this;
}
```

对于`&`限定的函数，只能将它用于左值；对于`&&`限定的函数，只能用于右值：

```c++
Foo &retFoo();		//返回一个引用；retFoo调用是一个左值
Foo retVal();			//返回一个值；retVal调用是一个右值
Foo i, j;					//i和j是左值
i = j;						//正确：i是左值
retFoo() = j;			//正确：retFoo()返回一个左值
retVal() = j;			//错误：retVal()返回一个右值
i = retVal();			//正确：我们可以将一个右值作为赋值操作的右侧运算对象
```

一个非 `static` 成员函数可以同时使用 `const` 和引用限定符，此时引用限定符跟在 `const` 限定符之后。

```c++
class Foo
{
public:
    Foo someMem() & const;      // error: const qualifier must come first
    Foo anotherMem() const &;   // ok: const qualifier comes first
};
```

引用限定符也可以区分成员函数的重载版本。

```c++
class Foo
{
public:
    Foo sorted() &&;        // may run on modifiable rvalues
    Foo sorted() const &;   // may run on any kind of Foo
};

retVal().sorted();   // retVal() is an rvalue, calls Foo::sorted() &&
retFoo().sorted();   // retFoo() is an lvalue, calls Foo::sorted() const &
```



定义`const`成员函数时，可以定义两个版本，唯一的差别就是一个有`const`限定而另一个没有，但是引用限定的规则不一样，如果一个成员函数有引用限定符，则具有相同参数列表的**所有重载版本**都必须有引用限定符。

```c++
class Foo
{
public:
    Foo sorted() &&;
    Foo sorted() const;    // error: must have reference qualifier
    // Comp is type alias for the function type
    // that can be used to compare int values
    using Comp = bool(const int&, const int&);
    Foo sorted(Comp*);  // ok: different parameter list
};
```

## Chapter14 重载运算与类型转换

### 基本概念

重载的运算符是具有特殊名字的函数，它们的名字由关键字 `operator` 和其后要定义的运算符号组成。和其它函数一样，重载的运算符也包含返回类型、参数列表以及函数体。

重载运算符函数的参数数量和该运算符作用的运算对象数量一样多。对于二元运算符来说，左侧运算对象传递给第一个参数，右侧运算对象传递给第二个参数。除了重载的函数调用运算符 `operator()` 之外，其他重载运算符不能含有默认实参。

如果一个运算符函数是类的成员函数，则它的第一个运算对象会绑定到隐式的 `this` 指针上。因此成员运算符函数的显式参数数量比运算对象的数量少一个。

当运算符作用于内置类型的运算对象时，无法改变该运算符的含义。

只能重载大多数已有的运算符，无权声明新的运算符号。

重载运算符的优先级和结合律与对应的内置运算符一致。

![14-1](https://tva1.sinaimg.cn/large/006y8mN6ly1g7hcrpualtj30kz06t3yt.jpg)

可以像调用普通函数一样直接调用运算符函数。

```c++
// equivalent calls to a nonmember operator function
data1 + data2;              // normal expression
operator+(data1, data2);    // equivalent function call
data1 += data2;             // expression-based ''call''
data1.operator+=(data2);    // equivalent call to a member operator function
```

通常情况下，不应该重载逗号 `,`、取地址 `&`、逻辑与 `&&` 和逻辑或 `||` 运算符。

建议只有当操作的含义对于用户来说清晰明了时才使用重载运算符，重载运算符的返回类型也应该与其内置版本的返回类型兼容。

如果类中含有算术运算符或位运算符，则最好也提供对应的复合赋值运算符。

把运算符定义为成员函数时，它的左侧运算对象必须是运算符所属类型的对象。

```c++
string s = "world";
string t = s + "!";     // ok: we can add a const char* to a string
string u = "hi" + s;    // would be an error if + were a member of string
```

如何选择将运算符定义为成员函数还是普通函数：

- 赋值 `=`、下标 `[]`、调用 `()` 和成员访问箭头 `->` 运算符必须是成员函数。
- 复合赋值运算符一般是成员函数，但并非必须。
- **改变对象状态**或者与给定类型密切相关的运算符，如递增、递减、解引用运算符，通常是成员函数。
- 具有**对称性**的运算符可能转换任意一端的运算对象，如算术、相等性、关系和位运算符，通常是普通函数。

### 输入和输出运算符

#### 重载输出运算符<< 

通常情况下，输出运算符的第一个形参是 `ostream` 类型的普通引用，因为要向流写入内容会改变其内容，所以不能为常量，而我们又无法复制`ostream`的对象，所以必须是引用。第二个形参是要打印类型的常量引用，我们用引用避免复制实参，因为打印对象不需要改变对象所以定义为常量引用返回。值是它的 `ostream` （引用）形参。

输出运算符应该尽量减少格式化操作。通常，输出运算符应该主要负责打印对象的内容而非控制格式，输出运算符不应该打印换行符。

输入输出运算符必须是非成员函数。而由于 IO 操作通常需要读写类的非公有数据，所以输入输出运算符一般被声明为友元。

#### 重载输入运算符 >>

通常情况下，输入运算符的第一个形参是要读取的流的普通引用，第二个形参是要读入的目的对象的普通引用，返回值是它的第一个形参。

```c++
istream &operator>>(istream &is, Sales_data &item)
{
    double price;   // no need to initialize; we'll read into price before we use it
    is >> item.bookNo >> item.units_sold >> price;
    if (is)    // check that the inputs succeeded
        item.revenue = item.units_sold * price;
    else
        item = Sales_data();    // input failed: give the object the default state
    return is;
}
```

**输入运算符必须处理输入失败的情况，而输出运算符不需要**。

以下情况可能导致读取操作失败：

- 读取了错误类型的数据。
- 读取操作到达文件末尾。
- 遇到输入流的其他错误。

当读取操作发生错误时，输入操作符应该负责从错误状态中恢复（有点类似回滚操作:P）。

如果输入的数据不符合规定的格式，即使从技术上看 IO 操作是成功的，输入运算符也应该设置流的条件状态以标示出失败信息。通常情况下，输入运算符只设置 `failbit` 状态。`eofbit`、`badbit` 等错误最好由 IO 标准库自己标示。

### 算术和关系运算符

通常情况下，算术和关系运算符应该定义为非成员函数，以便两侧的运算对象进行转换。其次，由于这些运算符一般不会改变运算对象的状态，所以形参都是常量引用。

算术运算符通常会计算它的两个运算对象并得到一个新值，这个值通常存储在一个局部变量内，操作完成后返回该局部变量的副本作为结果（返回类型建议设置为原对象的 `const` 类型）。

如果类定义了算术运算符，则通常也会定义对应的复合赋值运算符，此时最有效的方式是使用复合赋值来实现算术运算符。

#### 相等运算符

通常情况下，C++中的类通过定义相等运算符来检验两个对象是否相等，它们会比较对象的每一个成员，只有当对应的成员都相等时才认为两个对象相等（也许有例外，只需要部分成员相等即认为相等）

相等运算符设计准则：

- 如果类在逻辑上有相等性的含义，则应该定义 `operator==` 而非一个普通的命名函数。这样做便于使用标准库容器和算法，也更容易记忆。

- 通常情况下，`operator==` 应该具有传递性。

- 如果类定义了 `operator==`，则也应该定义 `operator!=`。

- `operator==` 和 `operator!=` 中的一个应该把具体工作委托给另一个。

  ```c++
  bool operator==(const Sales_data &lhs, const Sales_data &rhs)
  {
      return lhs.isbn() == rhs.isbn() &&
          lhs.units_sold == rhs.units_sold &&
          lhs.revenue == rhs.revenue;
  }
  
  bool operator!=(const Sales_data &lhs, const Sales_data &rhs)
  {
      return !(lhs == rhs);
  }
  ```

#### 关系运算符

定义了相等运算符的类通常也会定义关系运算符。因为关联容器和一些算法要用到小于运算符，所以定义 `operator<` 会比较实用。

关系运算符设计准则：

- 定义顺序关系，令其与关联容器中对关键字的要求保持一致。
- 如果类定义了 `operator==`，则关系运算符的定义应该与 `operator==` 保持一致。特别是，如果两个对象是不相等的，那么其中一个对象应该小于另一个对象。
- 只有存在唯一一种逻辑可靠的小于关系时，才应该考虑为类定义 `operator<`。

#### 赋值运算符

除了前文提到的拷贝赋值运算符和移动赋值运算符，类还可以定义其他赋值运算符以使用别的类型作为右侧运算对象。

比如用初始化列表作为参数赋值，这种方法无须检查自赋值，因为形参是初始化列表，如下定义：

```c++
StrVec &StrVec::operator=(initializer_list<string> il)
{
    // alloc_n_copy allocates space and copies elements from the given range
    auto data = alloc_n_copy(il.begin(), il.end());
    free();     // destroy the elements in this object and free the space
    elements = data.first;      // update data members to point to the new
    space
    first_free = cap = data.second;
    return *this;
}
```

赋值运算符必须定义为成员函数，复合赋值运算符通常也是如此。这两类运算符都应该**返回其左侧运算对象的引用**。

```c++
// member binary operator: left-hand operand is bound to the implicit this pointer
// assumes that both objects refer to the same book
Sales_data& Sales_data::operator+=(const Sales_data &rhs)
{
    units_sold += rhs.units_sold;
    revenue += rhs.revenue;
    return *this;
}
```

### 下标运算符

下标运算符必须定义为成员函数。

类通常会定义两个版本的下标运算符：一个返回普通引用，另一个是类的常量成员并返回常量引用。

当`StrVec`是非常量时，我们可以给元素赋值，否则不行：

```c++
class StrVec
{
public:
    std::string& operator[](std::size_t n)
    { return elements[n]; }
    const std::string& operator[](std::size_t n) const
    { return elements[n]; }

private:
    std::string *elements;  // pointer to the first element in the array
}

//假设svec是StrVec对象
const StrVec cvec = svec;
//如果svec中含有元素，检查第一个元素是否为空
if(svec.size() && svec[0].empty()){
 		svec[0] = "zero";			//正确，下标运算符返回string的引用
  	cvec[0] = "Zip";			//错误，对cvec取下标返回的是常量引用
}
```

### 递增和递减运算符

定义递增和递减运算符的类应该同时定义前置和后置版本，因为它们会改变操作对象的状态，所以通常定义为成员函数。

为了与内置操作保持一致，**前置递增或递减运算符应该返回运算后对象的引用**。

```c++
// prefix: return a reference to the incremented/decremented object
StrBlobPtr& StrBlobPtr::operator++()
{
    ++curr;     // advance the current state
    return *this;
}
```

后置递增或递减运算符接受一个额外的（不被使用）`int` 类型形参，该形参的唯一作用就是区分运算符的前置和后置版本。

为了与内置操作保持一致，后置递增或递减运算符应该返回运算前对象的原值（返回类型建议设置为原对象的 `const` 类型）。

```c++
StrBlobPtr StrBlobPtr::operator++(int)		//因为int形参不会用到，所以无需命名
{
    StrBlobPtr ret = *this;    // save the current value
    ++*this;      // advance one element; prefix ++ checks the increment
    return ret;   // return the saved state
}
```

如果想通过函数调用的方式使用后置递增或递减运算符，则必须为它的整型参数传递一个值（不会被使用，仅用来指示调用后置版本）。

```c++
StrBlobPtr p(a1);   // p points to the vector inside a1
p.operator++(0);    // call postfix operator++
p.operator++();     // call prefix operator++
```

### 成员访问运算符

箭头运算符必须定义为成员函数，解引用运算符通常也是如此。

重载的箭头运算符必须返回类的指针或者自定义了箭头运算符的类的对象。

```c++
class StrBlobPtr
{
public:
    std::string& operator*() const
    {
        return (*p)[curr];   // (*p) is the vector to which this object points
    }
    std::string* operator->() const
    {   // delegate the real work to the dereference operator
        return & this->operator*();
    }
};
```

箭头运算符就是用来获取成员的，这个事实永远不变。

对于形如 `point->mem` 的表达式来说，*point* 必须是指向类对象的指针或者是一个重载了 `operator->` 的类的对象。*point* 类型不同，`point->mem` 的含义也不同。

- 如果 *point* 是指针，则调用内置箭头运算符，表达式等价于 `(*point).mem`。
- 如果 *point* 是重载了 `operator->` 的类的对象，则使用 `point.operator->()` 的结果来获取 *mem*，表达式等价于 `(point.operator->())->mem`。其中，如果该结果是一个指针，则执行内置操作，否则重复调用当前操作。

### 函数调用运算符

如果类重载了函数调用运算符，则我们可以像使用函数一样使用该类的对象，这非常灵活。

函数调用运算符必须定义为成员函数。一个类可以定义多个不同版本的调用运算符，相互之间必须在参数数量或类型上有所区别。

这种类的对象称作**函数对象（function object）**，这些对象”行为像函数一样“。

```c++
class PrintString
{
public:
    PrintString(ostream &o = cout, char c = ' '):
        os(o), sep(c) { }
    void operator()(const string &s) const
    {
        os << s << sep;
    }
    
private:
    ostream &os;   // stream on which to write
    char sep;      // character to print after each output
};

PrintString printer;  // uses the defaults; prints to cout
printer(s);     // prints s followed by a space on cout
PrintString errors(cerr, '\n');
errors(s);			// prints s followed by a \n on cerr
```

函数对象常常作为泛型算法的实参，比如下面的`for_each`的第三个实参是一个`PrintString`类的一个临时对象，程序调用`for_each`时，将会把`vs`中的每个元素依次打印到`cerr`中，元素之间用换行符分隔。

```c++
for_each(vs.begin(), vs.end(), PrintString(cerr, '\n'));    
```

#### lambda 是函数对象

编写一个 `lambda` 后，编译器会将该表达式转换成一个未命名类的未命名对象，类中含有一个重载的函数调用运算符。

```c++
// sort words by size, but maintain alphabetical order for words of the same size
stable_sort(words.begin(), words.end(),
    [](const string &a, const string &b) { return a.size() < b.size(); });

// acts like an unnamed object of a class that would look something like
class ShorterString
{
public:
    bool operator()(const string &s1, const string &s2) const
    {
        return s1.size() < s2.size();
    }
};
```

`lambda` 默认不能改变它捕获的变量。因此在默认情况下，由 `lambda` 产生的类中的函数调用运算符是一个 `const` 成员函数。如果 `lambda` 被声明为可变的，则调用运算符就不再是 `const` 函数了。

`lambda` 通过**引用捕获**变量时，由程序负责确保 `lambda` 执行时该引用所绑定的对象确实存在。因此编译器可以直接使用该引用而无须在 `lambda` 产生的类中将其存储为数据成员。相反，通过**值捕获**的变量被拷贝到 `lambda` 中，此时 `lambda` 产生的类必须为每个值捕获的变量建立对应的数据成员，并创建构造函数，用捕获变量的值来初始化数据成员。

```c++
// get an iterator to the first element whose size() is >= sz
auto wc = find_if(words.begin(), words.end(),
            [sz](const string &a) { return a.size() >= sz; });

// would generate a class that looks something like
class SizeComp
{
public:
    SizeComp(size_t n): sz(n) { }   // parameter for each captured variable
    // call operator with the same return type, parameters, and body as the lambda
    bool operator()(const string &s) const
    { 
        return s.size() >= sz; 
    }
    
private:
    size_t sz;   // a data member for each variable captured by value
};
```

`lambda` 产生的类不包含默认构造函数、赋值运算符和默认析构函数，它是否包含默认拷贝 / 移动构造函数则通常要视捕获的变量类型而定。

#### 标准库定义的函数对象

标准库在头文件 *functional* 中定义了一组表示算术运算符、关系运算符和逻辑运算符的类，每个类分别定义了一个执行命名操作的调用运算符。这些类都被定义为模板的形式，可以为其指定具体的应用类型（即调用运算符的形参类型）。

![14-2](https://tva1.sinaimg.cn/large/006y8mN6ly1g7itv1uxnaj30kz04qjs0.jpg)

```c++
plus<int> intAdd;
negate<int> intNegate;
int sum = intAdd(10, 20);					//等价于sum=30
sum = intNegate(intAdd(10, 20));	//等价于sum=30
sum = intAdd(10, intNegate(10));
```

关系运算符的函数对象类通常被用来替换算法中的默认运算符，这些类对于指针同样适用。

```c++
vector<string *> nameTable;    // vector of pointers
// error: the pointers in nameTable are unrelated, so < is undefined
sort(nameTable.begin(), nameTable.end(),
        [](string *a, string *b) { return a < b; });
// ok: library guarantees that less on pointer types is well defined
sort(nameTable.begin(), nameTable.end(), less<string*>());
```

#### 可调用对象与 function

调用形式指明了调用返回的类型以及传递给调用的实参类型。不同的可调用对象可能具有相同的调用形式。

标准库 `function` 类型是一个模板，定义在头文件 *functional* 中，用来表示对象的调用形式。

![14-3](https://tva1.sinaimg.cn/large/006y8mN6ly1g7ituxxppnj30kz0addhz.jpg)

创建一个具体的 `function` 类型时必须提供其所表示的对象的调用形式。

```c++
// ordinary function
int add(int i, int j) { return i + j; }
// function-object class
struct div
{
    int operator()(int denominator, int divisor)
    {
        return denominator / divisor;
    }
};

function<int(int, int)> f1 = add;      // function pointer
function<int(int, int)> f2 = div();    // object of a function-object class
function<int(int, int)> f3 = [](int i, int j) { return i * j; };  // lambda
                                   
cout << f1(4,2) << endl;   // prints 6
cout << f2(4,2) << endl;   // prints 2
cout << f3(4,2) << endl;   // prints 8
```

不能直接将重载函数的名字存入 `function` 类型的对象中，这样做会产生二义性错误。消除二义性的方法是使用 `lambda` 或者存储函数指针而非函数名字。

C++11 新标准库中的 `function` 类与旧版本中的 `unary_function` 和 `binary_function` 没有关系，后两个类已经被 `bind` 函数代替。

### 重载、类型转换与运算符

转换构造函数和类型转换运算符共同定义了类类型转换（class-type conversion）。

#### 类型转换运算符（Conversion Operators）

类型转换运算符是**类的一种特殊成员函数**，负责将一个类类型的值转换成其他类型。它不能声明返回类型，形参列表也必须为空，一般形式如下：

```c++
operator type() const;
```

类型转换运算符可以面向除了 `void` 以外的任意类型（该类型要能作为函数的返回类型）进行定义。

```c++
class SmallInt
{
public:
    SmallInt(int i = 0): val(i)
    {
        if (i < 0 || i > 255)
            throw std::out_of_range("Bad SmallInt value");
    }   
    operator int() const { return val; }
    
private:
    std::size_t val;
};
```

隐式的用户定义类型转换可以置于一个标准（内置）类型转换之前或之后，并与其一起使用。

```c++
// the double argument is converted to int using the built-in conversion
SmallInt si = 3.14;     // calls the SmallInt(int) constructor
// the SmallInt conversion operator converts si to int;
si + 3.14;     // that int is converted to double using the built-in conversion
```

**应该避免过度使用类型转换函数**。如果在类类型和转换类型之间不存在明显的映射关系，则这样的类型转换可能具有误导性。

C++11 引入了**显式的类型转换运算符（explicit conversion operator）**。和显式构造函数一样，编译器通常不会将显式类型转换运算符用于隐式类型转换。

```c++
class SmallInt
{
public:
    // the compiler won't automatically apply this conversion
    explicit operator int() const { return val; }
    // other members as before
};

SmallInt si = 3;    // ok: the SmallInt constructor is not explicit
si + 3;     // error: implicit is conversion required, but operator int is explicit
static_cast<int>(si) + 3;    // ok: explicitly request the conversion
```

如果表达式被用作条件，则编译器会隐式地执行显式类型转换。

- `if`、`while`、`do-while` 语句的条件部分。
- `for` 语句头的条件表达式。
- 条件运算符 `? :` 的条件表达式。
- 逻辑非运算符 `!`、逻辑或运算符 `||`、逻辑与运算符 `&&` 的运算对象。

> 建议：类类型向 `bool` 的类型转换通常用在条件部分，因此 `operator bool` 一般被定义为显式的。

#### 避免有二义性的类型转换（Avoiding Ambiguous Conversions）

在两种情况下可能产生多重转换路径：

- *A* 类定义了一个接受 *B* 类对象的转换构造函数，同时 *B* 类定义了一个转换目标是 *A* 类的类型转换运算符。

  ```c++
  // usually a bad idea to have mutual conversions between two class types
  struct B;
  struct A
  {
      A() = default;
      A(const B&); // converts a B to an A
      // other members
  };
  
  struct B
  {
      operator A() const; // also converts a B to an A
      // other members
  };
  
  A f(const A&);
  B b;
  A a = f(b);    // error ambiguous: f(B::operator A())
                 // or f(A::A(const B&))
  ```

- 类定义了多个类型转换规则，而这些转换涉及的类型本身可以通过其他类型转换联系在一起。

  ```c++
  struct A
  {
      A(int = 0);     // usually a bad idea to have two
      A(double);      // conversions from arithmetic types
      operator int() const;       // usually a bad idea to have two
      operator double() const;    // conversions to arithmetic types
      // other members
  };
  
  void f2(long double);
  A a;
  f2(a);    // error ambiguous: f(A::operator int())
            // or f(A::operator double())
  long lg;
  A a2(lg);   // error ambiguous: A::A(int) or A::A(double)
  ```

可以通过显式调用类型转换运算符或转换构造函数解决二义性问题，但不能使用强制类型转换，因为强制类型转换本身也存在二义性。

```c++
A a1 = f(b.operator A());    // ok: use B's conversion operator
A a2 = f(A(b));     // ok: use A's constructor
```

通常情况下，不要为类定义相同的类型转换，也不要在类中定义两个及两个以上转换源或转换目标都是算术类型的转换。

使用两个用户定义的类型转换时，如果转换前后存在标准类型转换，则由标准类型转换决定**最佳匹配**。

如果在调用重载函数时需要使用构造函数或者强制类型转换来改变实参的类型，通常意味着程序设计存在不足。

调用重载函数时，如果需要额外的标准类型转换，则该转换只有在所有可行函数都请求同一个用户定义类型转换时才有用。如果所需的用户定义类型转换不止一个，即使其中一个调用能精确匹配而另一个调用需要额外的标准类型转换，也会产生二义性错误。

```c++
struct C
{
    C(int);
    // other members
};

struct E
{
    E(double);
    // other members
};

void manip2(const C&);
void manip2(const E&);
// error ambiguous: two different user-defined conversions could be used
manip2(10);    // manip2(C(10) or manip2(E(double(10)))
manip2(C(10)); // OK
```

#### 函数匹配与重载运算符（Function Matching and Overloaded Operators）

表达式中运算符的候选函数集既包括成员函数，也包括非成员函数。

```c++
class SmallInt
{
    friend SmallInt operator+(const SmallInt&, const SmallInt&);
    
public:
    SmallInt(int = 0);    // conversion from int
    operator int() const { return val; }    // conversion to int
    
private:
    std::size_t val;
};

SmallInt s1, s2;
SmallInt s3 = s1 + s2;    // uses overloaded operator+
int i = s3 + 0;    // error: ambiguous, 先把0转换为SmallInt再加，还是把s3转换为int再加？二义性错误
```

如果类既定义了转换目标是算术类型的类型转换，也定义了重载的运算符，则会遇到重载运算符与内置运算符的二义性问题。

## Chapter15 面向对象程序设计

### OOP：概述

**面向对象程序设计（object-oriented programming）**的核心思想是数据抽象（封装）、继承和动态绑定（多态）。

通过**继承（inheritance）**联系在一起的类构成一种层次关系。通常在层次关系的根部有一个**基类（base class）**，其他类则直接或间接地从基类继承而来，这些继承得到的类叫做**派生类（derived class）**。基类负责定义在层次关系中所有类**共同**拥有的成员，而每个派生类定义**各自**特有的成员。

对于某些函数，基类希望它的派生类各自定义适合自身的版本（称之为覆盖override），此时基类应该将这些函数声明为**虚函数（virtual function）**。方法是在函数名称前添加 `virtual` 关键字。

```c++
class Quote
{
public:
    std::string isbn() const;
    virtual double net_price(std::size_t n) const;
};
```

派生类必须通过类派生列表（class derivation list）明确指出它是从哪个或哪些基类继承而来的。类派生列表的形式首先是一个冒号，后面紧跟以逗号分隔的基类列表，其中每个基类前面可以添加访问说明符。

```c++
class Bulk_quote : public Quote
{ // Bulk_quote inherits from Quote
public:
    double net_price(std::size_t) const override;
};
```

派生类必须在其内部对所有重新定义的虚函数进行声明。

使用基类的引用或指针调用一个虚函数时将发生**动态绑定（dynamic binding）**，也叫运行时绑定（run-time binding）。函数的运行版本将由实参决定。

### 定义基类和派生类（Defining Base and Derived Classes）

#### 定义基类（Defining a Base Class）

基类通常都应该定义一个虚析构函数，即使该函数不执行任何实际操作也是如此。

**除构造函数之外的任何非静态函数都能定义为虚函数**。`virtual` 关键字只能出现在类内部的声明语句之前而不能用于类外部的函数定义。如果基类把一个函数声明为虚函数，则该函数在派生类中隐式地也是虚函数。

成员函数如果没有被声明为虚函数，则其解析过程发生在编译阶段而非运行阶段。

派生类能访问基类的公有成员，不能访问私有成员。如果基类希望定义外部代码无法访问，但是派生类对象可以访问的成员，可以使用受保护的（protected）访问运算符进行说明。

#### 定义派生类（Defining a Derived Class）

类派生列表中的访问说明符用于控制派生类从基类继承而来的成员是否对派生类的用户可见，访问说明符是下面三者之一：public、protected、private。

如果派生类没有覆盖其基类的某个虚函数，则该虚函数的行为类似于其他的普通函数，派生类会直接继承其在基类中的版本。C++11新标准允许派生类显式地注明它使用某个成员函数覆盖了它继承的虚函数，加上`override`即可。

C++ 标准并没有明确规定派生类的对象在内存中如何分布，一个对象中继承自基类的部分和派生类自定义的部分不一定是连续存储的。

因为在派生类对象中含有与其基类对应的组成部分，所以能把派生类的对象当作基类对象来使用，也能将基类的指针或引用绑定到派生类对象中的基类部分上。这种转换通常称为**派生类到基类的（derived-to-base）**类型转换，编译器会隐式执行。

```c++
Quote item;         // object of base type
Bulk_quote bulk;    // object of derived type
Quote *p = &item;   // p points to a Quote object
p = &bulk;          // p points to the Quote part of bulk
Quote &r = bulk;    // r bound to the Quote part of bulk
```

**每个类控制它自己的成员初始化过程，派生类必须使用基类的构造函数来初始化它的基类部分。派生类的构造函数通过构造函数初始化列表来将实参传递给基类构造函数。**

```c++
Bulk_quote(const std::string& book, double p, 
            std::size_t qty, double disc) :
    Quote(book, p), min_qty(qty), discount(disc) { }
```

除非特别指出，否则派生类对象的基类部分会像数据成员一样执行默认初始化。

**派生类初始化时首先初始化基类部分（即`Quote(book, p)`，然后按照声明的顺序依次初始化派生类成员（即`min_qty`、`discount`）。**

派生类可以访问基类的公有成员和受保护成员。派生类的作用域嵌套在基类的作用域之内。

如果基类定义了一个静态成员，则在整个继承体系中只存在该成员的**唯一定义**。如果某静态成员是可访问的，则既能通过基类也能通过派生类使用它。

声明类时，不能包含派生列表。

```c++
class Bulk_quote : public Quote;	//错误，派生列表不能出现在类的声明中
class Bulk_quote;									//正确
```



已经**完整定义**的类才能被用作基类，所以一个类不能派生它本身。

```c++
class Base { /* ... */ } ;
class D1: public Base { /* ... */ };
class D2: public D1 { /* ... */ };
```

*Base* 是 *D1* 的直接基类（direct base），是 *D2* 的间接基类（indirect base）。最终的派生类将包含它直接基类的子对象以及每个间接基类的子对象。

C++11 中，在类名后面添加 `final` 关键字可以禁止其他类继承它。

```c++
class NoDerived final { /* */ };    // NoDerived can't be a base class
class Base { /* */ };
// Last is final; we cannot inherit from Last
class Last final : Base { /* */ };  // Last can't be a base class
class Bad : NoDerived { /* */ };    // error: NoDerived is final
class Bad2 : Last { /* */ };        // error: Last is final
```

#### 类型转换与继承（Conversions and Inheritance）

可以将基类的指针或引用绑定到派生类对象上。

和内置指针一样，智能指针类也支持派生类到基类的类型转换，所以可以将一个派生类对象的指针存储在一个基类的智能指针内。

表达式的静态类型（static type）在编译时总是已知的，它是变量声明时的类型或表达式生成的类型；动态类型（dynamic type）则是变量或表达式表示的内存中对象的类型，只有运行时才可知。

如果表达式既不是引用也不是指针，则它的动态类型永远与静态类型一致。

不存在从基类到派生类的隐式类型转换，即使一个基类指针或引用绑定在一个派生类对象上也不行，因为编译器只能通过检查指针或引用的静态类型来判断转换是否合法。

```c++
Quote base;
Bulk_quote* bulkP = &base;   // error: can't convert base to derived
Bulk_quote& bulkRef = base;  // error: can't convert base to derived
```

即使一个基类指针或引用绑定在一个派生类对象上，我们也不能执行从基类向派生类的转换

```c++
Bulk_quote bulk;
Quote *itemP = &bulk;					//正确，动态类型是Bulk_quote
Bulk_quote *bulkP = itemP;		//错误，不能将基类转换成派生类	
```

如果在基类中含有一个或多个虚函数，可以使用 `dynamic_cast` 运算符，用于将基类的指针或引用安全地转换成派生类的指针或引用，该转换的安全检查将在运行期间执行。

如果已知某个基类到派生类的转换是安全的，可以使用 `static_cast` 强制覆盖掉编译器的检查工作。

派生类到基类的自动类型转换只对指针或引用有效，在派生类类型和基类类型之间不存在这种转换。

派生类到基类的转换允许我们给基类的拷贝 / 移动操作传递一个派生类的对象，这些操作是基类定义的，只会处理基类自己的成员，派生类的部分被切掉（sliced down）了。

```c++
Bulk_quote bulk;    // object of derived type
Quote item(bulk);   // uses the Quote::Quote(const Quote&) constructor
item = bulk;        // calls Quote::operator=(const Quote&)
```

**用一个派生类对象为一个基类对象初始化或赋值时，只有该对象中的基类部分会被拷贝、移动或赋值，它的派生类部分会被忽略掉。**

### 虚函数（Virtual Functions）

当且仅当通过指针或引用调用虚函数时，才会在运行过程解析该调用，也只有在这种情况下对象的动态类型有可能与静态类型不同。

在派生类中覆盖某个虚函数时，可以再次使用 `virtual` 关键字说明函数性质，但这并非强制要求。因为一旦某个函数被声明为虚函数，则在所有派生类中它都是虚函数。

一个派生类的函数如果覆盖了某个继承而来的虚函数，则它的形参类型必须与被它覆盖的基类函数完全一致，同理，返回类型也必须匹配，但是有个例外，如果虚函数返回类型是类型本身的指针或引用，比如D由B派生而来，则基类的虚函数可以返回`B*`而派生类的对应函数可以返回`D*`，不过要求D到B的类型转换是可访问的。

C++11 允许派生类使用 `override` 关键字显式地注明虚函数。如果 `override` 标记了某个函数，但该函数并没有覆盖已存在的虚函数，编译器将报告错误。`override` 位于函数参数列表之后。

> 这么做的好处是是的程序员的意图更加清晰的同时让编译器可以为我们发现一些错误，后者在编程实践中显得更加重要。

```c++
struct B
{
    virtual void f1(int) const;
    virtual void f2();
    void f3();
};

struct D1 : B 
{
    void f1(int) const override;    // ok: f1 matches f1 in the base
    void f2(int) override;      // error: B has no f2(int) function
    void f3() override;     // error: f3 not virtual
    void f4() override;     // error: B doesn't have a function named f4
}
```

与禁止类继承类似，函数也可以通过添加 `final` 关键字来禁止覆盖操作。

```c++
struct D2 : B
{
    // inherits f2() and f3() from B and overrides f1(int)
    void f1(int) const final;   // subsequent classes can't override f1(int)
};
```

`final` 和 `override` 关键字出现在形参列表（包括任何 `const` 或引用修饰符）以及尾置返回类型之后。

虚函数也可以有默认实参，每次函数调用的默认实参值由本次调用的静态类型决定。如果通过基类的指针或引用调用函数，则使用基类中定义的默认实参，即使实际运行的是派生类中的函数版本也是如此。由此发现，如果派生类函数的默认实参与基类函数的默认实参不一致，则会引起混乱，故**如果虚函数使用默认实参，则基类和派生类中定义的默认实参值最好一致**。

使用作用域运算符`::` 可以强制执行虚函数的某个版本，不进行动态绑定。

```c++
// calls the version from the base class regardless of the dynamic type of baseP
double undiscounted = baseP->Quote::net_price(42);
```

通常情况下，只有成员函数或友元中的代码才需要使用作用域运算符来回避虚函数的动态绑定机制。

如果一个派生类虚函数需要调用它的基类版本，但没有使用作用域运算符，则在运行时该调用会被解析为对派生类版本自身的调用，从而导致无限递归。

### 抽象基类（Abstract Base Classes）

在类内部虚函数声明语句的分号前添加 `=0` 可以将一个虚函数声明为纯虚（pure virtual）函数。一个纯虚函数无须定义，但也可以为纯虚函数提供定义，这时函数体必须定义在类的外部。

```c++
double net_price(std::size_t) const = 0;
```

含有（或未经覆盖直接继承）纯虚函数的类是**抽象基类**。抽象基类负责定义接口，而后续的其他类可以覆盖该接口。

不能创建抽象基类的对象，抽象基类的作用就是用来继承（派生）的。

派生类构造函数只初始化它的直接基类。

**重构（refactoring）**负责重新设计类的体系以便将操作或数据从一个类移动到另一个类中。

### 访问控制与继承（Access Control and Inheritance）

访问说明符 (public,protected,private) 类型：

- 类成员访问说明符
- 继承（派生）访问说明符

##### 类成员访问说明符

每个类分别控制自己的成员初始化过程，与之类似，每个类还分别控制着其成员对于派生类来说是否**可访问（accessible）**。

一个类可以使用 `protected` 关键字来声明外部代码无法访问，但是派生类对象可���访问的成员。

派生类的成员或友元只能通过派生类对象来访问基类的 `protected` 成员。派生类对于一个基类对象中的 `protected` 成员没有任何访问权限。

```c++
class Base
{
protected:
    int prot_mem;   // protected member
};

class Sneaky : public Base
{
    friend void clobber(Sneaky&);   // can access Sneaky::prot_mem
    friend void clobber(Base&);     // can't access Base::prot_mem
    int j;   // j is private by default
};

// ok: clobber can access the private and protected members in Sneaky objects
void clobber(Sneaky &s) { s.j = s.prot_mem = 0; }
// error: clobber can't access the protected members in Base
void clobber(Base &b) { b.prot_mem = 0; }
```

##### 继承（派生）访问说明符

继承访问说明符说明了派生类中基类部分成员的继承方式。

- 通过 public 继承：派生类中基类部分成员的访问说明符在基类中为 public 或 protected 的，在派生类中类型保持不变，private 的成员不可访问。
- 通过 protected 继承：派生类中基类部分成员的访问说明符在基类中为 public 或 protected 的，在派生类中类型为 protected，private 的成员不可访问。
- 通过 private 继承：派生类中基类部分成员的访问说明符在基类中为 public 或 protected 的，在派生类中类型为 private，private 的成员不可访问。

派生类到基类转换的可访问性（假定 *D* 继承自 *B*）：

- 只有当 *D* 公有地继承 *B* 时，用户代码才能使用派生类到基类的转换。
- 不论 *D* 以什么方式继承 *B*，*D* 的成员函数和友元都能使用派生类到基类的转换。
- 如果 *D* 继承 *B* 的方式是公有的或者受保护的，则 *D* 的派生类的成员函数和友元可以使用 *D* 到 *B* 的类型转换；反之，如果 *D* 继承 *B* 的方式是私有的，则不能使用。

对于代码中的某个给定节点来说，如果基类的公有成员是可访问的，则派生类到基类的类型转换也是可访问的。

##### 类的设计与受保护的成员

一个类有三种用户：普通用户、类的实现者、派生类

- 普通用户编写的代码使用类的对象，这部分代码只能访问类的公有（接口）成员

- 实现者则负责编写类的成员和友元的代码，成员和友元既能访问类的公有部分，也能访问类的私有（实现）部分
- 考虑继承，基类把它希望派生类能够使用的部分声明成受保护的（protected），普通用户不能访问受保护成员，派生类及其友元可访问protected，但是不能访问private

故，基类应该将接口成员声明为公有的，同时将其实现部分分为两组：一组可供派生类访问，另一组只能由基类及基类的友元访问，前者应该是protected，后者应该是private。

##### 友元与继承

友元关系不能继承也不能传递，每个类负责控制各自成员的访问权限。基类的友元在访问派生类成员时不具有特殊性，同理，派生类的友元不能随意访问基类的成员，

```c++
class Base
{
    // added friend declaration; other members as before
    friend class Pal;   // Pal has no access to classes derived from Base
};

class Sneaky : public Base
{
	int j;		// j is private by default
};

class Pal
{
public:
    int f(Base b) { return b.prot_mem; }     // ok: Pal is a friend of Base
    int f2(Sneaky s) { return s.j; }         // error: Pal not friend of Sneaky
    // access to a base class is controlled by the base class, even inside a derived object
    int f3(Sneaky s) { return s.prot_mem; }  // ok: Pal is a friend
};
```

上面代码f3是正确的，因为基类的友元能访问派生类的基类部分的成员（自己总结的，有点拗口）

##### 改变个别成员的可访问性

使用 `using` 声明可以改变派生类继承的某个名字的访问级别。新的访问级别由该 `using` 声明之前的访问说明符决定。

```c++
class Base
{
public:
    std::size_t size() const { return n; }
protected:
    std::size_t n;
};

class Derived : private Base
{ // note: private inheritance
public:
    // maintain access levels for members related to the size of the object
    using Base::size;
protected:
    using Base::n;
};
```

注意，派生类只能为那些它可以访问的名字提供 `using` 声明。

##### 默认的继承保护级别（默认的派生访问说明符）

默认情况下，使用 `class` 关键字定义的派生类是私有继承的，而使用 `struct` 关键字定义的派生类是公有继承的。

```c++
class Base {/*...*/};
struct D1 : Base {/*...*/};		//默认public继承
class D2 : Base {/*...*/};		//默认private继承
```

人们往往有错觉，struct与class定义的类有差别，实际上，唯一的差别就是默认成员访问说明符及默认派生访问说明符，struct是public，class是private。

建议显式地声明派生类的继承方式，不要仅仅依赖于默认设置，这样继承关系更加清晰。

### 继承中的类作用域（Class Scope under Inheritance）

当存在继承关系时，派生类的作用域嵌套在其基类的作用域之内。如果一个名字在派生类的作用域内无法正确解析（即找不到这个名字），则编译器将继续在外层的基类作用域中寻找该名字的定义。

一个对象、引用或指针的静态类型决定了该对象的哪些成员是可见的。

派生类定义的成员会隐藏同名的基类成员。

```c++
struct Base
{
protected:
    int mem;
};

struct Derived : Base
{
    int get_mem() { return mem; }   // returns Derived::mem  
protected:
    int mem;    // hides mem in the base
};

```

可以通过作用域运算符`::` 来使用被隐藏的基类成员。

```c++
struct Derived : Base
{
    int get_base_mem() { return Base::mem; }
    // ...
};
```

> 建议：除了覆盖继承而来的虚函数之外，派生类最好不要重用其他定义在基类中的名字。

##### 名字查找与继承

当我们调用`p->mem()`或`obj.mem()`时，依次执行下面四个步骤：

1. 首先确定p或obj的静态类型，因为我们调用的是一个成员，所以该类型必须是类类型。
2. 在p或obj的静态类型对应的类中查找mem，如果找不到，则依次在直接基类中不断查找直至到达继承链的顶端，如果找遍该类及其基类都找不到，则编译器报错。
3. 一旦找到了mem，就进行常规的类型检查，以确认对于当前找到的mem，本地调用是否合法。
4. 假设调用合法，编译器将根据调用的是否是虚函数而产生不同的代码：
   - 如果mem是虚函数且我们是通过引用或指针进行的调用，则编译器产生的代码**在运行时**确定到底运行该虚函数的哪个版本，依据是对象的动态类型。
   - 反之，如果mem不是虚函数或者我们是通过对象（而非引用或指针）进行的调用，则编译器产生一个常规函数调用。

因为内层作用域的函数不会重载外层作用域的函数，所以派生类的函数也不会重载其基类的函数，即使形参列表不一致，基类成员也仍然会被隐藏掉。

当然，可以通过作用域运算符`::` 来使用被隐藏的基类成员。

现在就可以理解，为什么继承的虚函数一定要有相同的形参列表，加入基类与派生类的虚函数接受的实参不同，则无法用基类的指针或引用调用派生类的虚函数了。

和其他函数一样，成员函数无论是否是虚函数都能被重载。

派生类可以覆盖重载函数的 0 个或多个实例。如果派生类希望所有的重载版本对它来说都是可见的，那么它就需要覆盖所有版本，或者一个也不覆盖。

有时一个类仅需覆盖重载集合中的一些而非全部函数，此时如果我们不得不覆盖基类中的每一个版本的话，操作会极其繁琐。为了简化操作，可以为重载成员提供 `using` 声明。`using` 声明指定了一个函数名字但不指定形参列表，所以一条基类成员函数的 `using` 声明语句就可以把该函数的所有重载实例添加到派生类作用域中。

类内使用 `using` 声明改变访问级别的规则同样适用于重载函数的名字。

### 构造函数与拷贝控制（Constructors and Copy Control）

位于继承体系中的类也需要控制当其对象执行一系列操作时发生什么样的行为，这些操作包括创建、拷贝、移动、赋值和销毁。如果一个类（基类或派生类）没有定义拷贝控制操作，则编译器将为它合成一个版本，当然这个合成的版本也可以定义成被删除的函数。

#### 虚析构函数

一个指针指向继承体系中的某个类型，有可能出现指针的静态类型与动态类型不一致的情况，比如一个`Quote*`类型的指针，实际指向了`Bulk_quote`类型的对象（`Bulk_quote`继承自`Quote`），delete这样一个动态分配的指针，肯定要搞清楚到底执行哪个析构函数，所以析构函数一般都是虚函数。

基类通常应该定义一个虚析构函数。

```c++
class Quote
{
public:
    // virtual destructor needed if a base pointer pointing to a derived object is deleted
    virtual ~Quote() = default;   // dynamic binding for the destructor
};
```

如果基类的析构函数不是虚函数，则 delete 一个指向派生类对象的基类指针会产生未定义的结果。

```c++
Quote *itemP = new Quote;   // same static and dynamic type
delete itemP;     // destructor for Quote called
itemP = new Bulk_quote;     // static and dynamic types differ
delete itemP;     // destructor for Bulk_quote called
```

一般来说，如果一个类需要析构函数，那么它也需要拷贝和赋值操作。但基类的析构函数不遵循该规则。

虚析构函数会阻止编译器为类合成移动操作。

#### 合成拷贝控制与继承

派生类的默认构造函数会先运行其基类的默认构造函数，而该基类又会先运行它的基类的默认构造函数，依次直至继承链顶端，所以顶端的基类会最先执行默认构造函数，然后默认初始化其成员，再依次轮到下端的派生类默认初始化各自成员。

自己定义的构造函数也要遵循如上顺序。

同理，拷贝构造函数也是这样的。

对于派生类的析构函数来说，它除了销毁派生类自己的成员外，还负责销毁派生类直接基类的成员。该直接基类又销毁它自己的直接基类，以此类推直至继承链顶端。

派生类中删除的拷贝控制与基类的关系：

- 如果基类中的默认构造函数、拷贝构造函数、拷贝赋值运算符或析构函数是被删除的或者不可访问的函数，则派生类中对应的成员也会是被删除的。因为编译器不能使用基类成员来执行派生类对象中基类部分的构造、赋值或销毁操作。
- 如果基类的析构函数是被删除的或者不可访问的，则派生类中合成的默认和拷贝构造函数也会是被删除的。因为编译器无法销毁派生类对象中的基类部分。
编译器不会合成一个被删除的移动操作。当我们使用 =default 请求一个移动操作时，- - 如果基类中对应的操作是被删除的或者不可访问的，则派生类中的操作也会是被删除的。因为派生类对象中的基类部分不能移动。同样，如果基类的析构函数是被删除的或者不可访问的，则派生类的移动构造函数也会是被删除的。

在实际编程中，如果基类没有默认、拷贝或移动构造函数，则一般情况下派生类也不会定义相应的操作。

因为基类缺少移动操作会阻止编译器为派生类合成自己的移动操作，所以当我们确实需要执行移动操作时，应该首先在基类中进行定义。

#### 派生类的拷贝控制成员（Derived-Class Copy-Control Members）

当派生类定义了拷贝或移动操作时，该操作负责拷贝或移动包括基类成员在内的整个对象。

当为派生类定义拷贝或移动构造函数时，通常使用对应的基类构造函数初始化对象的基类部分。

```c++
class Base { /* ... */ } ;
class D: public Base
{
public:
    // by default, the base class default constructor initializes the base part of an object
    // to use the copy or move constructor, we must explicitly call that
    // constructor in the constructor initializer list
    D(const D& d): Base(d)   // copy the base members
    /* initializers for members of D */ { /* ... */ }
    D(D&& d): Base(std::move(d))    // move the base members
    /* initializers for members of D */ { /* ... */ }
};

// probably incorrect definition of the D copy constructor
// base-class part is default initialized, not copied
D(const D& d)   /* member initializers, but no base-class initializer */
{ /* ... */ }
```

在默认情况下，基类默认构造函数初始化派生类对象的基类部分。如果想拷贝或移动基类部分，则必须在派生类的构造函数初始化列表中显式地使用基类的拷贝或移动构造函数。

与拷贝和移动构造函数一样，派生类的赋值运算符必须显式地为其基类部分赋值。

```c++
// Base::operator=(const Base&) is not invoked automatically
D &D::operator=(const D &rhs)
{
    Base::operator=(rhs);   // assigns the base part
    // assign the members in the derived class, as usual,
    // handling self-assignment and freeing existing resources as appropriate
    return *this;
}
```

派生类的析构函数只负责销毁派生类自己分配的资源，基类的析构函数会自动执行。

对象销毁顺序与创建顺序正好相反：派生类析构函数首先执行，然后是基类的析构函数，以此类推直至继承链顶端。

```c++
class D: public Base
{
public:
    // Base::~Base invoked automatically
    ~D() { /* do what it takes to clean up derived members */ }
};
```

如果构造函数或析构函数调用了某个虚函数，则应该执行与构造函数或析构函数所属类型相对应的虚函数版本。

#### 继承的构造函数（Inherited Constructors）

C++11 新标准允许派生类**重用（非常规方式继承）**其直接基类定义的构造函数。继承方式是提供一条注明了直接基类名的 `using` 声明语句。

```c++
class Bulk_quote : public Disc_quote
{
public:
    using Disc_quote::Disc_quote;   // inherit Disc_quote's constructors
    double net_price(std::size_t) const;
};
```

通常情况下，`using` 声明语句只是令某个名字在当前作用域内可见。而作用于构造函数时，`using` 声明将令编译器产生代码。对于基类的每个构造函数，编译器都会生成一个与其形参列表完全相同的派生类构造函数。如果派生类含有自己的数据成员，则这些成员会被默认初始化。

构造函数的 `using` 声明不会改变该函数的访问级别，不能指定 `explicit` 或 `constexpr` 属性。

定义在派生类中的构造函数会替换继承而来的具有相同形参列表的构造函数。

派生类不能继承默认、拷贝和移动构造函数。如果派生类没有直接定义这些构造函数，则编译器会为其合成它们。

当一个基类构造函数含有默认实参时，这些默认值不会被继承。相反，派生类会获得多个继承的构造函数，其中每个构造函数分别省略掉一个含有默认值的形参。比如基类有一个接受两个形参的构造函数，其中第二个形参含有默认实参，则派生类获得两个构造函数：一个构造函数接受两个形参（都没有默认实参），另一个构造函数只接受一个形参，它对应于基类最左侧的那个没有默认值的形参。

除了以下两个例外情况，大多数时候派生类会继承基类所有的构造函数：

- 派生类可以继承一部分基类的构造函数，而为其他构造函数定义自己的版本，也就是覆盖（重写）。
- 默认、拷贝和移动构造函数不会被继承，它们按正常规则合成。继承的构造函数不算用于自己定义的构造函数，因此，如果一个类只含有继承的构造函数，则它也将拥有一个合成的默认构造函数。

### 容器与继承

因为容器中不能保存不同类型的元素，所以不能把具有继承关系的多种类型的对象直接存储在容器中。如果容器的元素定义为派生类，则基类无法添加；如果容器的元素定义为基类，则派生类的派生部分会被切掉。

```c++
vector<Quote> basket;
basket.push_back(Quote("0-201-82470-1", 50));
basket.push_back(Bulk_quote("0-201-54848-8", 50, 10, .25)); //正确，但是只能把Quote部分拷贝给basket
cout << basket.back().net_price(15) << endl;  //调用Quote定义的版本
```

警告⚠️：容器不能和存在继承关系的类型兼容。

如果想在容器中存储具有继承关系的对象，则应该存放基类的（智能）指针。

```
vector<shared_ptr<Quote>> basket;
basket.push_back(make_shared<Quote>("0-201-82470-1", 50));
basket.push_back(make_shared<Bulk_quote>("0-201-54848-8", 50, 10, .25)); //正确，但是只能把Quote部分拷贝给basket
cout << basket.back()->net_price(15) << endl;  //调用Quote定义的版本
```

