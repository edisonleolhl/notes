# C++查漏补缺

## 基本语言

### 说一说Static关键字的作用

1. 全局静态变量，存储在静态存储区，未经初始化的变量自动初始为0（对象的话是任意的），其他文件不可见
2. 局部静态变量，存储在静态存储区，未经初始化的变量自动初始为0（对象的话是任意的），作用域仍为局部作用域，当定义它的函数或语句块结束时，局部静态变量不销毁，而是驻留在内存中，只不过不能进行访问，当下次再进入函数或语句块时，局部静态变量的值不改变。
3. 静态函数，不能被其他文件所用，建议不要在头文件声明static全局函数，不要在cpp文件内声明非static全局函数，如果要在多个cpp文件内复用，就把声明放在头文件里面，否则cpp内部的声明需要加上static修饰
4. 类的静态成员，静态成员可以实现多个对象之间的数据共享，并且使用静态数据成员还不会破坏隐藏的原则，即保证了安全性。因此，静态成员是类的所有对象中共享的成员，而不是某个对象的成员，注意**不能在类中初始化，也不能在main函数中初始化（可以在main函数之前执行），如果类的静态成员是私有的，则要遵循私有访问限制的原则**。
5. 类的静态函数，同上，都属于类的静态成员，它们都不是对象成员。因此，对静态成员的引用不需要用对象名。在静态成员函数的实现中不能访问类的非静态成员，**可以访问类的静态成员**（这点非常重要）。如果静态成员函数中要引用非静态成员时，可通过对象来引用。从中可看出，调用静态成员函数使用如下格式：<类名>::<静态成员函数名>(<参数表>);

### 静态变量什么时候初始化

由于C++引入对象，对象生成必须调用构造函数，因此C++规定：**局部静态变量（一般是函数内的静态变量）在第一次使用时分配内存并初始化**，全局变量、文件域的静态变量和类的静态成员变量在main函数执行之前的静态初始化过程中分配内存并初始化

### 说一说volatile关键字的作用

- A situation that is volatile is likely to change suddenly and unexpectedly：被它修饰的对象出现任何情况都不要奇怪，我们不能对它们做任何假设。
- **提示编译器**紧随其后变量随时都可以变，要求每次读写这个变量时都要从地址读数据
- volatile 不能解决多线程中的问题

### 说一说extern关键字的作用

1. extern可以置于变量或者函数前，以标示变量或者函数的定义在别的文件中，提示编译器遇到此变量和函数时在其他模块中寻找其定义。
2. 在函数前加上`extern "C"`，告诉编译器要用C的规则去翻译函数名，因为C不支持函数重载而C++支持函数重载，所以C++会将函数名和参数联合起来生成一个中间的函数名称

### 说一说四种cast转换

1. const_cast，用于将const变量转化为非const变量

2. static_cast，用于各种隐式转换，基础类型转换，如非const转const，void*转指针，用于多态向上转换，如果向下转换能成功但不安全

3. dynamic_cast

    `dynamic_cast<type-id>(expression)`：动态类型转换。用于父子之间的转换，比static_cast要安全

    向上转换一定成功，只需用将子类的指针或引用赋给基类的指针或引用即可。

    向下转换检查type_id是否一致，而且必须要有虚函数，因为dynamic_cast执行RTTI

    **指针类型失败**，dynamic_cast返回0

    **引用类型失败**，则抛出bad_cast错误

4. reinterpret_cast，几乎什么都可以转，比如int转指针，但可能会出问题，尽量少用

### C++如何处理异常/构造函数、析构函数能不能抛出异常

try catch throw

1. 构造函数抛出异常，会导致析构函数不能被调用，但已经申请到的内存资源会依次调用其虚构函数

2. 类的析构函数不能抛出异常、也不应该抛出异常。

3. 如果对象在运行期间出现了异常，C++ 异常处理机制则有责任去清除那些由于出现异常而导致已经失效了的对象，并释放对象原来所分配的资源，这其实就是调用对象的析构函数来完成资源的释放任务，所以从这个意义上来讲，**析构函数已经变成了异常处理机制中的一部分**。

4. 如果在析构函数中发生了异常，极有可能导致内存泄漏。

### 指针和引用的区别

1. 引用可以说是**别名**，指针有自己的**存储空间**，里面存储的是所指对象的地址
2. 引用必须**初始化**，指针不必须初始化
3. 引用初始化后**不能更改**引用的对象，指针初始化后可以更改指向的对象
4. 两者在汇编层面没有区别
5. 使用sizeof运算符看指针是4字节（32位机器）或8字节（64位机器），而用sizeof运算符看引用则取决于被引用对象的大小
6. 指针可以进行自增或自减操作，可以访问原对象相邻存储空间的内容，引用只能固定引用
7. 返回动态内存分配的对象或内存，必须用指针，用引用有可能内存泄露
8. 从面向对象的角度，引用不是对象，指针是对象

### char*与char[]的区别

- char []定义的是一个字符数组，注意强调是数组，数组内容可以改变
- char * 定义的是一个字符串指针，注意强调是指针，指针内容是可以改变的，即可以指向其他地址，但不能改变指针所指向的内容！

关于它们的字节大小与相互之间的转换，仔细体会以下例子（已测试）：

```c++
    char* str = "hello there"; // "hello there"是字面值常量，不可修改！
    char carray[] = "hello again"; // "hello again"是字符数组，可以修改！

    // 下行输出：8, 11。在64位系统指针占8字节，strlen计算字符串长度时要除去末尾的`\0`，一共11字节
    cout << "sizeof(str): " << sizeof(str) << ", strlen(str): " << strlen(str) << endl;
    // 下行输出12, 11。末尾的`\0`也算作数组的长度
    cout << "sizeof(carray): " << sizeof(carray) << ", strlen(carray): " << strlen(carray) << endl;

    // *str = 'H';          // ERROR
    // carray = str;        // ERROR
    str = carray;           // carray是字符数组，数组名即指向数组首位的指针，可以赋值给str
    cout << str << endl;    // 输出：hello again
    *carray = 'H';          // carray是字符数组，数组名即指向数组首位的指针，可以通过指针修改数组内容
    cout << str << endl;    // 输出：Hello again
    carray[1] = 'E';        // carray是字符数组，可以通过数组offset修改数组内容
    cout << str << endl;    // 输出：HEllo again
```

```c++
const char * arr = "123";   // 字符串123保存在常量区，本来就是常亮，const加不加都可以
char * brr = "123";         // brr与arr指向的地址相同
const char crr[] = "123";   // 数组，在栈上，长度是4（包括结尾的空字符
char drr[] = "123";         // 另一个数组，drr与crr指向的地址不同，长度也是4
```

### union数据类型是什么

- union是C语言里面的共用体/联合体，这些数据共享同一段内存，以达到节省空间的目的
- union变量所占用的内存长度等于最长的成员的内存长度
- 因为union里面的变量共享内存，所以不能使用静态、引用
- C++中使用union时，尽量保持C语言中使用union的风格，尽量不要让union带有对象
- union可以用来测试CPU是大端模式还是小端模式

### 宏定义常量与const常量的区别/宏定义函数与内联函数的区别

`#define pi 3.1415926`

1. 编译器处理阶段不同：宏定义常量在**预处理阶段**展开；const常量在编译运行阶段使用
2. 类型和安全检查不同：宏定义常量**没有类型检查**，仅仅展开；const常量有具体类型，在编译阶段执行类型检查
3. 存储方式不同：宏定义常量**不分配内存**，仅仅是展开而已；const常量会在内存中分配，
4. 常量只在类中有效只能用const，而且const数据成员只在某个对象生存期内是常量，对于整个类而言是可变的，因为类可以有多个对象，每个对象的const成员值可以不同（不能在类中初始化const数据成员）

`define MAX(a, b) ((a)>(b)?(a):(b))`

1. 编译器处理阶段不同：宏定义是由预处理器进行宏展开，函数内联是通过编译器来控制实现
2. 类型和安全检查不同：宏定义函数没有类型检查
3. 存储方式不同：内联函数是代码段，直接嵌入，而宏函数是简单的替换
4. 内联函数在普通函数的前面加一个关键字 inline 来标识。编译器对内联函数会在编一阶段将其展开，而不会把它当做一个函数，这大大减少了**函数调用的开销**，因为函数调用需要函数栈、压栈blabla的

### printf和cout的区别

- cout时ostream类对象，prtinf是C语言函数
- cout有行缓冲（endl），printf没有
- cout对类型处理更加方便，printf要定义各种%s、%d，很麻烦

### RAII是什么（C++的重要思想！）

RAII，也称为**资源获取就是初始化（Resource Acquisition Is Initialization**，是c++等编程语言常用的管理资源、避免内存泄露的方法。它保证在任何情况下，使用对象时先构造对象，最后析构对象。**利用对象的生命周期来管理资源**。智能指针是最具代表的技术。

### 说一说智能指针

智能指针是一个类似指针的类，提供了内存管理的功能，当指针不再被使用时，它指向的内存会自动被释放，这就比原生指针要好，原生指针有可能会因为忘记释放所申请的空间，而造成内存泄漏，而用智能指针就没这个顾虑。C++11支持shared_ptr, weak_ptr, unique_ptr，auto_ptr（被弃用）。这些智能指针位于`<memory>`中

- auto_ptr采取所有权模式，可以被拷贝（构造or赋值）时，原auto_ptr指为nullptr，即auto_ptr被其他auto_ptr**剥夺**（转移），所以很容易引起内存泄露（粗心的程序员可能仍然会解引用原auto_ptr）
- unique_ptr是独占式拥有，解决了auto_ptr被剥夺的问题，**unique_ptr禁止了拷贝**（构造or赋值），保证同一时间内只有一个智能指针可以指向该对象，如果真的需要转移，可以使用**借助move实现移动构造**，原unique_ptr置为nullptr（但粗心的程序员可能仍然会解引用原来的unique_ptr）
- shared_ptr是共享，允许拷贝（构造or赋值），允许多个智能指针可以指向相同对象，每当，每次有一个shared_ptr关联到某个对象上时（拷贝构造or拷贝赋值），计数值就加上1；相反，每次有一个shared_ptr析构时，相应的计数值就减去1。当计数值减为0的时候，就执行对象的析构函数，此时该对象才真正被析构！如果用了移动（构造or赋值），那么原shared_ptr为空，并且指向对象的引用计数不会改变（相当于-1+1=0）
- weak_ptr是一种**弱引用**，指向shared_ptr（强引用）所管理的对象，可从一个shared_ptr或另一个weak_ptr来构造，它的构造和析构不会引起引用计数的增加或减少。weak_ptr并没有重载operator->和operator *操作符，因此**不可直接通过weak_ptr使用对象**。weak_ptr提供了expired()与lock()成员函数，前者用于判断weak_ptr指向的对象是否已被销毁，后者返回其所指对象的shared_ptr智能指针(对象销毁时返回”空”shared_ptr)

[话说智能指针发展之路](https://blog.csdn.net/Jacketinsysu/article/details/53343534)（为了取消歧义，把复制都改为了拷贝，并且确定了是拷贝构造还是拷贝赋值）

```c++
{
    auto_ptr<string> ps1(new string("Hello, auto_ptr!"));
    auto_ptr<string> ps2;
    ps2 = ps1;
    //【E1】下面这行注释掉才可正确运行，因为ps1被ps2剥夺，ps1此时指向null，解引用当然会报错
    //cout << "ps1: " << *ps1 << endl;
    cout << "ps2: " << *ps2 << endl;
}

{
    unique_ptr<string> ps1(new string("Hello, unique_ptr!"));
    // unique_ptr<string> ps2(ps1);// 编译将会出错！因为禁止拷贝构造
    // unique_ptr<string> ps2 = ps1;// 编译将会出错！因为禁止拷贝赋值
    unique_ptr<string> ps2 = move(ps1); //编译通过，ps1被转移了，此时ps1指向null
}

{
    shared_ptr<string> ps1(new string("Hello, shared_ptr!"));
    shared_ptr<string> ps3(ps1);    // 允许拷贝构造
    shared_ptr<string> ps2 = ps1;   // 允许拷贝赋值
    cout << "Count is: " << ps1.use_count() << ", " << ps2.use_count() << ", " << ps3.use_count() << endl;  // Count is: 3, 3, 3
    cout << "ps1 is: " << *ps1 << ", ptr value is: " << ps1.get() << endl;
    cout << "ps2 is: " << *ps2 << ", ptr value is: " << ps2.get() << endl;
    cout << "ps3 is: " << *ps3 << ", ptr value is: " << ps3.get() << endl;

    shared_ptr<string> ps4 = move(ps1); // 注意ps1在move之后，就“失效”了
    cout << "Count is: " << ps1.use_count() << ", " << ps2.use_count() << ", " << ps3.use_count() << ", " << ps4.use_count() << endl;   // Count is: 0, 3, 3, 3
    cout << "ps1 is: " << ps1.get() << endl;
    cout << "ps4 is: " << *ps4 << ", ptr value is: " << ps4.get() << endl;
}
```

### 智能指针也会发生内存泄漏吗；如果是，有什么手段避免

两个shared_ptr相互引用时会发生循环引用(“你中有我，我中有你”)，使引用计数失效，从而导致内存泄露

weak_ptr弱指针可以解决这个问题，weak_ptr的构造和析构不会影响引用计数，它指向shared_ptr所管理的对象，也可以检测到所管理的对象是否已经被释放，从而避免非法访问。

weak_ptr也可以调用lock()函数，如果管理对象没有被释放，则提升为shared_ptr，如果管理对象已经释放，调用lock()函数也不会有异常

#### shared_ptr循环引用导致内存泄漏

考虑下面的例子，A类与B类都有一个指向对方的shared_ptr成员，创建a_obj与b_obj，首先把if语句块注释掉，先测试它们不循环引用的情况

```c++
#include <iostream>
#include <memory>
class B;
class A
{
public:
    // weak_ptr<B> pb;
    shared_ptr<B> pb;
    ~A()
    {
        cout << "kill A\n";
    }
};

class B
{
public:
    // weak_ptr<A> pa;
    shared_ptr<A> pa;
    ~B()
    {
        cout <<"kill B\n";
    }
};
int main()
{
    A* a_obj = new A();
    B* b_obj = new B();
    shared_ptr<A> sa(a_obj);
    shared_ptr<B> sb(b_obj);
    cout<<"sa use count:"<<sa.use_count()<<endl;
    // if(sa && sb)
    // {
    //     ;
    // }
    cout<<"sa use count:"<<sa.use_count()<<endl;
```

没有循环引用，通过下面的输出，可以看到a_obj与b_obj都已经正确地调用了析构函数。

```shell
sa use count:1
sa use count:1
kill B
kill A
```

为了探究use count的返回情况，修改if语句：

```c++
    if(sa && sb)
    {
        shared_ptr<A> tempsa(sa);
        cout<<"sa use count:"<<sa.use_count()<<endl;
    }
```

输出如下，证实了局部引用在退出作用域时取消引用，use count会减1。

```shell
sa use count:1
sa use count:2
sa use count:1
kill B
kill A
```

接下来修改if语句，探究a_obj与b_obj的shared_ptr互相引用对方时的场景

```c++
    if(sa && sb)
    {
        sa->pb=sb;
        sb->pa=sa;
        cout<<"sa use count:"<<sa.use_count()<<endl;
    }
```

输出如下，结束if语句块时，use count没有-1，证明了引用计数失效；程序结束时也没有kill B、kill A的输出，说明a_obj与b_obj没有正确析构

```shell
sa use count:1
sa use count:2
sa use count:2
```

总结：**循环引用导致引用计数失效，最后导致无法正确析构，造成内存泄漏**

#### weak_ptr解决循环引用

只需要把class A与class B中的成员类型改为`weak_ptr<B>`与`weak_ptr<A>`即可，输出如下，引用计数正常工作，两个对象也正确析构了

```shell
sa use count:1
sa use count:1
sa use count:1
kill B
kill A
```

### 手动实现引用计数型智能指针

```c++
#include <iostream>
using namespace std;

template<class T>
class SmartPtr
{
public:
    SmartPtr(T *p) {
        ptr = p;
        use_count = new int(1);
    }
    ~SmartPtr(){
        // 只在最后一个对象引用ptr时才释放内存
        if (--(*use_count) == 0)
        {
            delete ptr;
            delete use_count;
            ptr = nullptr;  // delete指针后要让指针置空，不然就成了空悬指针/野指针
            use_count = nullptr;
        }
    }
    SmartPtr(const SmartPtr<T> &orig){ // 浅拷贝
        ptr = orig.ptr;
        use_count = orig.use_count; // 浅拷贝，指向同一块内存（同一个int型变量）
        ++(*use_count);
    }
    SmartPtr<T>& operator=(const SmartPtr<T> &rhs){ // 浅拷贝
        // 必须先递增rhs的引用计数，为了防止自赋值时把自己给释放掉了
        ++(*rhs.use_count);
        // 将左操作数对象的使用计数减1，若该对象的使用计数减至0，则删除该对象
        if (--(*use_count) == 0)
        {
            delete ptr;
            delete use_count;
        }
        ptr = rhs.ptr;
        use_count = rhs.use_count;
        return *this;
    }
    T& operator*(const SmartPtr<T> &rhs){ // 重载解引用操作符，注意返回引用，因为返回左值可修改
        return *ptr;
    }
private:
    T *ptr; // 原始指针
    int *use_count; // 为了方便对其的递增或递减操作
};
```

### 数组和指针的联系、区别

1. 指针是单个空间，存储的是所指对象的地址；数组可以有若干单位的空间，存储对象本身；可以有指向数组的指针，也可以有每个单元都是指针的数组
2. 指针间接访问对象，得先解引用，指针可以直接访问
3. 当指针指向数组时，可以用自增自减在数组元素上移动，但若要访问还是需要解引用
4. 当数组作为函数参数传入时，会自动变化为指针，指向数组首位
5. 不能对数组名直接复制，但可以对指针直接复制
6. 用运算符sizeof可以得到数组字节数（数组大小），但只能得到指针类型本身的字节数

### 函数指针与指针函数的区别

函数指针是指向函数的指针，声明如：`int (*p)(int a, int b);`，每个函数在编译时都有一个入口地址，这在汇编代码里面看的十分清楚，函数指针存储的就是这种入口地址的值，可以直接用函数指针调用函数

指针函数是返回指针的函数

### 右值引用是什么，跟左值引用又有什么区别

左值：能对表达式取地址、或具名对象/变量。一般指表达式结束后依然存在的**持久对象**。

右值：不能对表达式取地址，或匿名对象。一般指表达式结束就不再存在的**临时对象**。

右值引用和左值引用的区别：

1. 左值可以寻址，而右值不可以。
2. 左值可以被赋值，右值不可以被赋值，但可以用来给左值赋值。
3. 左值可变，右值不可变

右值引用是C++11中引入的新特性, 它实现了转移语义和精确传递。右值的主要目的有两个方面：

1. **消除两个对象交互时不必要的对象拷贝**，节省运算存储资源，提高效率。
2. 能够更简洁明确地定义泛型函数。

> ++++i不会报错，i++++/++i++/会报错，因为因为**后置递增会返回一个右值**（联想一下后置递增的原理，是一个临时值），没法对一个右值再执行递增操作

### std::bind

bind可以看做函数适配器，它接受一个可调用对象callable，返回一个新的newcallable，在中间，bind可以将newcallable的某些参数绑定到给定变量上

网络编程中，经常要使用到**回调函数**。当底层的网络框架有数据过来时，往往通过回调函数来通知业务层。这样可以使网络层只专注于 数据的收发，而不必关心业务

```c++
// 这个using是为了使用 _1, _2, _3,...
using namespace std::placeholders;

double my_divide (double x, double y) {return x/y;}
struct MyPair {
  double a,b;
  double multiply() {return a*b;}
};

auto fn_five = std::bind (my_divide,10,2); // 返回 10/2
std::cout << fn_five() << '\n'; // 输出 5

auto fn_half = std::bind (my_divide,_1,2); // 返回 x/2
std::cout << fn_half(10) << '\n'; // 输出 5

auto fn_invert = std::bind (my_divide,_2,_1); // 返回 y/x
std::cout << fn_invert(10,2) << '\n'; // 输出 0.2

auto fn_rounding = std::bind<int> (my_divide,_1,_2); // 返回 int(x/y)
std::cout << fn_rounding(10,3) << '\n'; // 输出 3

// 捆绑成员函数
// 如果回调函数是一个类的成员函数。这时想把成员函数设置给一个回调函数指针往往是不行的，因为类的成员函数，多了一个隐含的参数this。 所以直接赋值给函数指针肯定会引起编译报错
auto bound_member_fn = std::bind (&MyPair::multiply,_1); // 返回 x.multiply()
std::cout << bound_member_fn(ten_two) << '\n'; // 输出 20

auto bound_member_data = std::bind (&MyPair::a,ten_two); // 返回 ten_two.a
std::cout << bound_member_data() << '\n'; // 输出 10
```

### std::future/std::async/std::promise

future与async配合使用,可以从**异步任务**中获取结果，std::async用于创建异步任务，实际上就是创建一个线程执行相应任务。

future与promise可以实现多线程同步，线程1初始化一个promise对象和一个future对象，promise传递给线程2，相当于线程2对线程1的一个**承诺**；future相当于一个**接受一个承诺**，用来获取未来线程2传递的值。线程2获取到promise后，需要对这个promise传递有关的数据，之后线程1的future就可以获取数据了。

### std::move原理

- C++11引入的std::move并不能移动任何东西（可理解为“使其可移动movable”），它唯一的功能是将一个左值强制转化为右值引用，继而可以通过右值引用使用该值，以用于移动语义
- std::move是将对象的状态或者所有权从一个对象转移到另一个对象，只是**转移**，没有内存的搬迁或者内存拷贝，所以可以提高利用效率

### std::atomic

用atomic_int/atomic_bool/...代替int/bool/...，即可保证这些操作都是原子性的

比mutex对资源加锁解锁要快

### std::mutex

std::mutex是C++11中最基本的互斥量，std::mutex 对象提供了**独占所有权**的特性——即不支持递归地对 std::mutex 对象上锁，而 std::recursive_lock 则可以递归地对互斥量对象上锁。

std::mutex不允许拷贝构造，初始是unlock状态

三个函数

1. lock()：三种情况
    1. 如果该mutex没有被锁，则上锁
    2. 如果该mutex被其他线程锁住，则**当前线程阻塞**，直至其他线程解锁
    3. 如果该mutex被当前线程锁住（递归上锁），则产生死锁
2. unlock()
3. try_lock()：相当于**非阻塞**的加锁，三种情况
    1. 如果该mutex没有被锁，则上锁
    2. 如果该mutex被其他线程锁住，则**当前线程返回false**，直至其他线程解锁
    3. 如果该mutex被当前线程锁住（递归上锁），则产生死锁

### unique_lock与lock_guard区别（C++11）

这两个都是类模板，用RAII的思想来处理锁，不用手动mutex.lock()、mutex.unlock()

- lock_guard只有构造函数，直接构造即可，在整个区域内有效，在块内`{}`作为局部变量，自动析构

- unique_lock更加灵活，还提供lock()、try_lock()、unlock()等函数，所以可以在必要时加锁和解锁，不必像lock_guard一样非得在构造和析构时加锁和解锁

- unique_lock在效率上差一点，内存占用多一点。

### 条件变量与虚假唤醒（C++11）

当条件不满足时，相关线程被一直阻塞，直到某种条件出现，这些线程才会被唤醒

条件变量一般与互斥锁结合，通常与unique_lock类模板结合使用

- wait：当前线程阻塞直至条件变量被通知或被虚假唤醒，若用版本二，则唤醒必须满足谓词函数（还有指定时长的wait_for和指定截止时间的wait_until）

    ```c++
    // 版本一：因为存在虚假唤醒，所以没有谓词函数的版本一般不用！
    void wait( std::unique_lock<std::mutex>& lock );
    // 版本二：Predicate 谓词函数，可以普通函数或者lambda表达式
    template< class Predicate >
    void wait( std::unique_lock<std::mutex>& lock, Predicate pred );
    ```

- notify_all/notify_one：通知

    ```c++
    // 若任何线程在 *this 上等待，则调用 notify_one 会解阻塞(唤醒)等待线程之一。
    void notify_one() noexcept;
    // 若任何线程在 *this 上等待，则解阻塞（唤醒)全部等待线程。
    void notify_all() noexcept;
    ```

虚假唤醒：

在正常情况下，wait类型函数返回时要不是因为被唤醒，要不是因为超时才返回，但是在实际中发现，因此操作系统的原因，wait类型在不满足条件时，它也会返回，这就导致了虚假唤醒。因此，我们一般都是使用带有谓词参数的wait函数，因为这种(xxx, Predicate pred )类型的函数等价于：

```c++
while (!pred()) //while循环，解决了虚假唤醒的问题
{
    wait(lock);
}
```

### 两个线程交替打印（C++11）

用到了unique_lock来管理mutex，还有条件变量condition_variable来通知另一个线程，注意下面的代码会一直循环下去

```c++
#include <iostream>
#include <thread>
#include <mutex>
#include <condition_variable>
using namespace std;  
mutex mtx;
condition_variable cond_var;
bool flag = true;
void printA(){
    while(1){
        unique_lock<std::mutex> ulock(mtx);
        cond_var.wait(ulock, []{return flag;});
        cout << "threadA: " << flag << endl;
        flag = false;
        cond_var.notify_one();
    }
}
void printB(){
    while(1){
        unique_lock<std::mutex> ulock(mtx);
        cond_var.wait(ulock, []{return !flag;});
        cout << "threadB: " << flag << endl;
        flag = true;
        cond_var.notify_one();
    }
}
int main()  
{  
    thread t1(&printA);
    thread t2(&printB);
    t1.join();
    t2.join();
  
    return 0;  
}  
```

### 函数对象与lambda表达式

[C++拾遗--lambda表达式原理](https://blog.csdn.net/zhangxiangDavaid/article/details/44064765)

函数对象的本质是**重载了函数调用运算符的、行为类似函数的类对象**。当一个类重载了函数调用运算符`()`后，它的对象就成了函数对象，也叫仿函数(functor)，举例如下

```c++

class MyClass{
public:
    int operator()(int i) return i;
};
int main()
{
    MyClass my;
    int i = my(1); //本质是调用 my.operator()(1)，调用行为类似函数
    cout << "i = " << i << endl;
    return 0;
```

编译器会把一个lambda表达式生成**一个匿名类的匿名对象**，并在类中重载函数调用运算符。

```c++
auto print = []{cout << "zhangxiang" << endl; };
```

编译器会把这一句翻译成如下情形(类名任意)：

```c++
//用给定的lambda表达式生成相应的类
class print_class
{
public:
    void operator()(void) const
    {
        cout << "zhangxiang" << endl;
    }
};
//用构造的类创建对象，print此时就是一个函数对象
auto print = print_class();
```

### 匿名函数的捕获

值捕获是不改变原有变量的值，引用捕获是可以在Lambda表达式中改变原有变量的值

[捕获值列表]:

1. 空。没有使用任何函数对象参数。

2. =。函数体内可以使用Lambda所在作用范围内所有可见的局部变量（包括Lambda所在类的this），并且是值传递方式（相当于编译器自动为我们按值传递了所有局部变量）。

3. &。函数体内可以使用Lambda所在作用范围内所有可见的局部变量（包括Lambda所在类的this），并且是引用传递方式（相当于编译器自动为我们按引用传递了所有局部变量）。

4. this。函数体内可以使用Lambda所在类中的成员变量。

5. a。将a按值进行传递。按值进行传递时，函数体内不能修改传递进来的a的拷贝，因为默认情况下函数是const的。要修改传递进来的a的拷贝，可以添加mutable修饰符。

6. &a。将a按引用进行传递。

7. a, &b。将a按值进行传递，b按引用进行传递。

8. =，&a, &b。除a和b按引用进行传递外，其他参数都按值进行传递。

9. &, a, b。除a和b按值进行传递外，其他参数都按引用进行传递。

### C++11有哪些新特性

auto关键字：编译器根据初始值自动推导出类型，但是不能用于函数传参以及数组类型的推导

nullptr：一种特殊的空指针类型，能转换成其他任意类型的指针，而NULL一般被宏定义为0，遇到重载时可能会出现问题

decltype：查询表达式的类型，不会对表达式求值，经常与auto配合追踪函数的返回值类型

基于范围的for循环: `for(auto &v : vec){...}`

匿名函数 Lambda: `[capture list] (params list) mutable exception-> return type { function body }`，值捕获、引用捕获、隐式捕获

智能指针：新增了shared_ptr、unique_ptr、weak_ptr，用于解决内存管理的问题

初始化列表：使用初始化列表来对类进行初始化

可变参数模板：对参数进行了高度泛化，能表示0到任意个数、任意类型的参数，`template <class... T> void f(T... args);`

右值引用：基于右值引用可以实现移动语义和完美转发，消除两个对象交互时不必要的对象拷贝，节省运算存储资源，提高效率

新增正则表达式库

新增STL容器array以及tuple

## 类和数据抽象

### struct和class的区别

struct与class一样，可以包括成员函数，可以实现继承，可以实现多态。不同点在于

1. 默认的继承访问权。class默认的是private，strcut默认的是public，继承访问权取决于子类而不是基类，比如struct继承class则默认是public继承
2. 默认访问权限：struct作为数据结构的实现体，它默认的成员访问控制是public的，而class作为对象的实现体，它默认的成员变量访问控制是private的。
3. “class”这个关键字还用于定义模板参数，就像“typename”。但关建字“struct”不用于定义模板参数

最好的建议就是：当你觉得你要做的更像是一种数据结构的话，那么用struct，如果你要做的更像是一种对象的话，那么用class。

### C++中类的成员访问限定符

分为private、public、protected，控制成员变量和成员函数的访问权限，C++类本身没有公私之分

在类的内部（定义类的代码内部），无论成员被声明为 public、protected 还是 private，都是可以互相访问的，没有访问权限的限制。

在类的外部（定义类的代码之外），只能通过对象访问成员，并且通过对象只能访问 public 属性的成员，不能访问 private、protected 属性的成员，但是protected属性的成员在派生类内部可以访问

### C++中的三种继承方式

继承方式是为了控制子类(也称派生类)的调用方(也叫用户)对父类(也称基类)的访问权限。

1. 使用private继承,父类的所有方法在子类中变为private;
2. 使用protected继承,父类的protected和public方法在子类中变为protected，private方法不变;
3. 使用public继承,父类中的方法属性不发生改变;

### 重载、重写与重定义

重载（overload）：同范围内，多个同名函数之间的一种关系，需满足：这些同名函数在参数列表上有所不同（个数、类型、顺序），调用函数时，编译器会选择匹配的函数执行，仅有返回值不同的两个同名函数不能重载，const和非const也可以重载，

重写/覆盖（override）：发生在子类继承父类的情况下，被重写函数不能static，**必须虚函数**，重写函数必须有相同的类型、名称、参数列表，访问修饰符不必相同

重定义/隐藏（redefining)：子类重新定义父类中同名的**非虚**函数 (参数列表可以不同)或父类中同名的虚函数（但参数列表不同），此时基类的函数被隐藏

### C++11的final与override

- 把类声明为final，可以防止该类被继承（编译出错），把基类的成员函数声明为final，可以防止该成员函数被重载（重载时会编译出错）

    ```c++
    struct Object{
        virtual void fun() = 0;
    };

    struct Base : public Object {
        void fun() final;   // 可以在继承体系的中途声明为final
    };

    struct Derived : public Base {
        void fun();     // 无法通过编译
    };
    ```

- C++重写还有个特点，父类声明的虚函数，**子类都不需要声明virtual**，而且还可以“跨层”，没有在父类声明的接口可能是祖先的虚函数接口，这就为阅读带来了障碍。所以C++11引入了override关键字，如果派生类在虚函数声明时使用了override，则该函数必须重写父类的虚函数，否则编译出错

### 类内可以定义引用数据成员吗

1. 可以，但必须在定义时初始化
2. 因此不能用默认的构造函数，必须自己设计构造函数
3. 且构造函数**的形参必须为引用类型**，引用型数据成员必须在**初始化列表**里初始化，不能在函数体里初始化，因为在函数体内修改引用型数据成员，相当于赋值，而**引用不能赋值**

### 拷贝构造函数的调用时机

1. 显式地以一个类对象作为另一个类对象的初值，形如`X xx = x`
2. 当类对象被作为参数传入函数时
3. 当函数返回类对象时

### 析构函数的作用

1. 析构函数与构造函数对应，当对象结束其生命周期时，会自动执行析构函数
2. 如果用户没有定义析构函数，则编译器会自动生成一个合成的/缺省的析构函数，即使用户自定义了析构函数，合成的析构函数还是有的
3. 如果类中有指针，并且在使用的过程中动态申请了内存，那么最好就应该显式定义析构函数，在其中释放申请的内存空间
4. 析构顺序（正好与构造相反）：子类析构函数-》对象成员析构函数-》父类析构函数

### 手动实现一个String类

[C++面试中STRING类的一种正确写法](https://coolshell.cn/articles/10478.html)

必须：普通构造，拷贝构造，析构，赋值

移动：移动构造、移动赋值

拓展：比较，字符串相加，获取长度及子串等方法

```c++
class String{
public:
    // 普通构造函数
    String(const char* str){// 参数必须要用const，这样const和非const都可以传入
        if(str == NULL){
            m_data = new char[1];
            m_data[0] = '\0'; // 空字符串也要放入空字符
            m_size = 0;
        }
        else{
            int length = strlen(str);
            m_data = new char[length + 1];
            strcpy(m_data, str);
        }
    }

    // 析构函数
    ~String(){
        delete[] m_data; // delete m_data也可以，但是没那么清晰
    }

    // 拷贝构造函数
    // 参数一定是引用传递，不能值传递，否则实参传进来要调用拷贝构造函数，而现在就正在定义拷贝构造函数，这构成了悖论
    String(const String &rhs){ // 参数必须const 引用
        m_data = new char[strlen(rhs.m_data) + 1];
        strcpy(m_data, rhs.m_data);
    }

    // 拷贝赋值函数
    // 必须解决自赋值与内存泄漏的问题
    // 返回引用，不会调用类的拷贝构造函数，而且连续赋值的时候可以减少拷贝次数
    // 版本一：手动检查自赋值
    String& operator=(const String &rhs){ // 引用传递，返回引用
        if(this != &rhs){ // 检查自赋值，this是本对象的地址
            delete[] m_data;    // 得分点：释放原有的内存资源，避免内存泄漏
            m_data = new char[strlen(rhs)] + 1];
            strcpy(m_data, rhs.m_data);
        }
        return *this;   // 得分点：返回对本对象的引用
    }
    // 版本二：拷贝并交换，正确处理自赋值且是异常安全的，rhs在函数结束后会自动析构
    String& operator=(const String rhs){ // 值传递，返回引用
        swap(*this, rhs);
        return *this;   // 得分点：返回对本对象的引用
    }

    // 移动构造函数
    String(String &&rhs){
        m_data = rhs.m_data;
        rhs.m_data = nullptr;
    }

    // 移动赋值函数
    String& operator=(String &&rhs){
        if(this != rhs){
            delete[] m_data;
            m_data = rhs.m_data;
            rhs.m_data = nullptr;
        })
    }

    String operator+(const String &rhs){ // 返回的是值！
        String newStr;
        delete[] newStr.m_data; // 释放原有空间
        int left_len = strlen(m_data);
        int right_len = strlen(rhs.m_data);
        newStr.m_data = new char[left_len + right_len + 1];
        strcpy(newStr.m_data, m_data);
        strcpy(newStr.m_data + left_len, rhs.m_data); // 偏移量
        return newStr;
    }
    bool operator==(const String &rhs){
        return strcmp(m_data, rhs.m_data);
    }
    int length(){
        return strlen(m_data);
    }
    String substr(int start, int n){ // 返回的是值！
        String newStr;
        delete[] newStr.m_data; // 释放原有空间
        newStr.m_data = new char[n + 1];
        int total_len = strlen(m_data);
        for(int i = 0; i < n && start + i < total_len; ++i){
            newStr.m_data[i] = m_data[start + i];
        }
        newStr.m_data[n] = '\0';
        return newStr;
    }
    friend ostream& operator<<(ostream &o, const String &rhs){
        o << rhs.m_data;
        return o;
    }
private:
    char* m_data;
}
```

### C++多态怎么理解

主要分为编译时多态（静态/早绑定）和运行时多态（动态/晚绑定），编译时多态通过模板和重载实现，运行时多态通过虚函数实现

看看下面这个例子，看看静态绑定与动态绑定的区别

```c++
class B {
public:
    void foo() { cout << "B foo " << endl; }
};

int main()
{
    B *somenull = NULL;
    somenull->foo(); // 能正常输出！
    somenull->foo2();// 报错！Segmentation Fault!
    return 0;
}
```

解释：关键在于foo成员函数没有对this指针的解引用，所以不用管this（当前对象）是否为空

- foo是非虚函数，C++对于非虚函数是静态绑定，foo函数内没有对类对象this指针的解引用，所以可以直接用somenull调用foo成员函数。
- foo2是虚函数，C++对于虚函数是动态绑定，虚函数内肯定有对类对象this指针的解引用，所以不能用somenull调用foo2成员函数

### 虚函数是什么，虚函数怎么实现运行时多态的

1. 多态，是指在继承层次中，父类的指针可以具有多种形态，当它指向某个子类对象时，通过它能够调用到子类的函数（必须是重写本父类的虚函数），而非父类的函数

2. 每一个具有虚函数的类都有一个虚函数表，里面按在类中声明的虚函数的顺序存放着虚函数的地址，这个虚函数表是这个类的所有对象所共有的，只有一个。

3. 为每个有虚函数的类插入一个指针（vptr），这个指针指向该类的虚函数表，一般为了效率考虑，指针位于该类的头部

4. 子类继承父类时也会继承虚函数表/虚函数指针（都是新的），但是当子类**重写**继承的虚函数时，子类的虚函数表中的对应虚函数地址会替换为重写的虚函数地址。

5. 如果有多继承，子类的vfptr虚函数指针不止一个，虚函数表也不止一个，子类自己定义的虚函数会放在继承自第一个（按照继承声明顺序）父类的虚函数表后面，若重写多个父类的同名虚函数，则继承自对应父类的虚函数表也会修改

### 成员函数有哪几种

1. 非静态（普通）成员函数：编译器会保证类的普通成员函数与普通非成员函数效率一致，会经过名字修饰/编排/mangling，生成独一无二的名字
2. 虚函数：通过vptr查找虚函数表，找到对应的虚函数，在运行时决定
3. 静态成员函数：不能有非静态的数据成员or非静态的成员函数，可直接通过类名调用

### 纯虚函数是什么

- 纯虚函数是在基类中声明的虚函数，它在基类中没有定义，但要求任何派生类都要对于这个同名函数定义自己的实现方法。
- 在基类中实现纯虚函数的方法是在函数原型后加“=0”，`virtual void funtion1()=0`
- 定义纯虚函数的目的在于，使派生类仅仅只是继承函数的接口，

### 虚继承/虚基类是什么，为什么可以解决菱形继承问题

- 虚继承（Virtual Inheritance）/虚基类解决了从不同途径继承来的同名的数据成员在内存中有不同的拷贝造成数据不一致问题，将共同基类设置为虚基类。这时从不同的路径继承过来的同名数据成员在内存中就只有一个拷贝，同一个函数名也只有一个映射
- 当在多条继承路径上有一个公共的基类，在这些路径中的某几条汇合处，这个公共的基类就会产生多个实例(或多个副本)，若只想保存这个基类的一个实例，可以将这个公共基类说明为虚基类。
- 虚继承一般通过**vbptr虚基类指针**和vb虚基类表实现，每个虚继承的子类都有一个虚基类指针（占用一个指针的存储空间，4字节，放在虚函数表指针的后面，如果没有虚函数表指针，那就放在类实例的头部）和虚基类表（不占用类对象的存储空间）；当虚继承的子类被当做父类继承时，虚基类指针也会被继承。
- 解决了二义性问题，解决了钻石继承/菱形继承/重复继承问题，也节省了内存，避免了数据不一致的问题。

### 构造函数/析构函数的执行顺序

- 首先执行**虚基类的构造函数**，多个虚基类的构造函数按照被继承的顺序构造（若没有虚基类，则略过这条）；
- 执行**基类的构造函数**，多个基类的构造函数按照被继承的顺序构造；
- 正确初始化vptr
- 执行**成员对象的构造函数**，多个成员对象的构造函数按照声明的顺序构造；
- 执行**派生类自己的构造函数**，数据成员的初始化顺序按照它们在类中声明的顺序（见下一条笔记）

析构以与构造**相反顺序**执行

### 类的初始化列表顺序

类成员是按照它们在类里被声明的顺序进行初始化的，**和它们在成员初始化列表中列出的顺序没一点关系**。

对一个对象的所有成员来说，它们的**析构函数**被调用的顺序总是和它们在构造函数里被创建的**顺序相反**。

### sizeof(类对象)

转自：[图说C++对象模型：对象内存布局详解](https://www.cnblogs.com/QG-whz/p/4909359.html)、[C++中虚函数工作原理和(虚)继承类的内存占用大小计算](https://blog.csdn.net/Hackbuteer1/article/details/7883531)

```c++
class B{};
class B1 :public virtual  B{};
class B2 :public virtual  B{};
class D : public B1, public B2{};

int main()
{
    B b;
    B1 b1;
    B2 b2;
    D d;
    cout << "sizeof(b)=" << sizeof(b)<<endl;
    cout << "sizeof(b1)=" << sizeof(b1) << endl;
    cout << "sizeof(b2)=" << sizeof(b2) << endl;
    cout << "sizeof(d)=" << sizeof(d) << endl;
    getchar();
}
```

输出与解释：

- sizeof(b)=1：编译器为空类安插1字节的char，使该类对象**在内存配置一个地址**
- sizeof(b1)=8：b1虚继承于b，编译器为其安插一个8字节的虚基类表指针（64位机器），此时b1已不为空，编译器不再为其安插1字节的char（有些编译器做不到这样的优化，字节对齐后也有可能类对象的大小为16字节）
- sizeof(b2)=8：b2同理
- sizeof(d)=16：d含有来自b1与b2两个父类的两个虚基类表指针，加起来大小为16字节

新增：类对象的大小=各**非静态数据成员**（包括父类的非静态数据成员但都不包括所有的成员函数）的总和+ vfptr指针(多继承下可能不止一个)+vbptr指针(多继承下可能不止一个)+编译器额外增加的字节（补齐padding），其中补齐操作跟编译器有关，暂时不用深究。

```c++
class A
{
};

class B
{
    char ch;
    virtual void func0() {}
};

class C
{
    char ch1;
    char ch2;
    virtual void func() {}
    virtual void func1() {}
};

class D : public A, public C
{
    int d;
    virtual void func() {}
    virtual void func1() {}
};

class E : public B, public C
{
    int e;
    virtual void func0() {}
    virtual void func1() {}
};

int main(void)
{
    cout << "A=" << sizeof(A) << endl;
    cout << "B=" << sizeof(B) << endl;
    cout << "C=" << sizeof(C) << endl;
    cout << "D=" << sizeof(D) << endl;
    cout << "E=" << sizeof(E) << endl;
    return 0;
}
```

输出：

- A=1：空类，编译器自动安插一个char型大小，1个字节
- B=16：B类有虚函数，会产生虚函数表指针，大小为8字节，char型数据为1字节，8+1=9字节，编译器自动补齐为16个字节
- C=16：C类有虚函数，会产生虚函数表指针，大小为8字节，char型数据为1字节，8+2*1=10字节，编译器自动补齐为16个字节
- D=16：D继承自A与C，A没有虚函数，C有虚函数，所以D有一个虚函数指针，D重写了继承自C的两个虚函数，D的虚函数表只有两个虚函数（即重写后的），int型占4字节，再加上继承自C的两个char型数据成员，8+4+2*1=14字节，编译器自动补齐为16字节
- E=32：E继承自B与C，继承两个虚函数表，所以有两个虚函数指针，B有一个char型数据成员，C有两个char型数据成员，E还有一个int型数据成员，`2*8+3*1+4=20`字节，编译器自动补齐为32字节

### 静态函数和虚函数的区别

静态函数在编译的时候就已经确定运行时机，虚函数在运行的时候动态绑定。虚函数因为用了虚函数表机制，调用的时候会增加一次内存开销

### 为什么构造函数/静态函数/内联函数/模板成员函数不能是虚函数

- 从存储空间角度：**虚函数需要通过查找虚函数表访问**，而此时对象还没有实例化，没有虚函数表，如果构造函数是虚的，则没法调用
- 从使用角度：虚函数主要用于在**信息不全**的情况下能够使得重写函数得到调用，构造函数本身就是要实例化的，所以没必要虚函数

- **静态函数属于类**，不属于特定对象，本身就是一个实体，而虚函数需要在类对象的虚函数表中去查找

- 内联函数在编译时就会展开函数体，而虚函数在运行时才有实体

- 编译器需要在编译时确定虚函数表大小，而模板可能会有多个实例化，如果模板成员函数为虚函数，那会造成虚函数表大小不确定

### 构造/析构函数可以调用虚函数吗

可以，但没法达到预期效果，因为这时调用的虚函数是基类对象的实体，不是派生类对象的实体

由于类的构造顺序是先基类再派生类，所以在基类的构造函数中调用虚函数，派生类还没构造，所以没法呈现多态性

由于类的析构顺序是先派生类再基类，所以在在基类的析构函数中调用虚函数，派生类已经析构完了，所以没法呈现多态性

### 为什么析构函数必须是虚函数；为什么C++默认的析构函数不是虚函数

如果基类的析构函数不是虚的，那么以一个基类指针指向其派生类，删除这个基类指针**只能删除基类对象部分**，而不能删除整个派生类对象。

如果基类的析构函数是虚的，那么派生类的析构函数也必然是虚的，删除基类指针时，它就会**通过虚函数表找到正确的派生类析构函数**并调用它，从而正确析构整个派生类对象。

C++默认的析构函数不是虚函数，是因为虚函数需要额外的虚函数表和虚表指针，占用额外的内存。而对于不会被继承的类来说，其析构函数如果是虚函数，就会**浪费内存**。因此C++默认的析构函数不是虚函数，而是只有当需要当作父类时，设置为虚函数。

### 拷贝赋值函数的形参能否进行值传递

不能，因为如果要进行值传递，这又得调用拷贝赋值函数，也就是依赖于其本身，这就会产生一个无限循环，无法完成拷贝，栈也会满

### 模板元编程(Template Meta Programming)

- 利用模板来编写那些在编译时运行的C++程序
- 模板分为函数模板与类模板两类。
- 模板实例化(instantiation)：具体类型代替模板参数的过程。
- 模板参数推导/推演(deduction)：由模板实参类型确定模板形参的过程。
- std::enable_if，经常用于偏特化中
- SFINAE：代替失败不是错误，进行模板特化的时候，总会去选择那个正确的模板，避免失败

### typename与class关键字的区别

- 声明模板类型参数时，两者没区别

    ```c++
    typename <typename T> ...
    typename <class T> ...
    ```

- 使用**嵌套依赖类型**时，必须用typename，告知编译器这是一个类型名称，而不是成员函数或成员变量，否则编译不通过（在迭代器萃取经常用到）

```c++
template <class T>
void foo(){
    typename T::iterator iter;
}
```

### 模板的实例化时机/模板的成员函数的实例化时机

模板只有在被使用到才会实例化

对于一个实例化后的模板来说，成员函数只有在被使用时才会实例化

这都是处于时间和空间效率考虑的

### 可变参数怎么实现

C语言提供了可变参数var_list，在printf函数中有应用，其实是利用了函数压栈从后往前的特点，以**保证第一个参数在栈顶**。

C++11提供了可变参数模板，但是展开包中的参数比较麻烦，主要有递归展开和逗号表达式展开两种方法

递归展开

```c++
// 用于终止迭代的基函数，必须要有
template<typename T>
void processValues(T arg)
{
    handleValue(arg);
}

// 可变参数函数模板
template<typename T, typename ... Ts>
void processValues(T arg, Ts ... args)
{
    handleValue(arg);
    processValues(args ...); // 解包，然后递归
}
```

逗号表达式展开

```c++
template <class T>
void printarg(T t)
{
   cout << t << endl;
}

template <class ...Args>
void expand(Args... args)
{
   int arr[] = {(printarg(args), 0)...}; // 结合初始化列表，arr没什么用，纯粹是为了展开包
}

expand(1,2,3,4);
```

### 模板的全特化与偏特化是什么，有什么区别

全特化对全部模板参数进行特化，全特化的模板参数列表应当是空的，并且应当给出”模板实参”列表，类模板需要给出模板实参，函数模板不需要给出模板实参

```c++
// 全特化类模板
template <>
class A<int, double>{
    int data1;
    double data2;
};

// 函数模板
template <>
int max(const int lhs, const int rhs){
    return lhs > rhs ? lhs : rhs;
}
```

偏特化对部分模板参数进行特化，函数模板不允许偏特化

```c++
template <class T2>
class A<int, T2>{
    ...
};
```

## 内存分配/编译/底层

### C++内存分配（管理）方式

[C++ 自由存储区是否等价于堆？](https://www.cnblogs.com/qg-whz/p/5060894.html)

栈：就是那些由编译器在需要的时候分配，在不需要的时候自动清除的变量的存储区。里面的变量通常是局部变量、函数参数等。在一个进程中，位于用户虚拟地址空间顶部的是用户栈，编译器用它来实现函数的调用。操作方式类似于数据结构里的栈。向下增长。

堆：malloc在堆上分配的内存块，使用free释放内存。如果程序员没有释放掉，那么在程序结束后，操作系统会自动回收。操作方式类似于数据结构里的链表。向上增长。可以说堆是操作系统维护的一块内存（物理上的）。

自由存储区：new所申请的内存则是在自由存储区上，使用delete来释放。自由存储区是C++通过new与delete动态分配和释放对象的抽象概念（逻辑上的），有可能是由堆实现的，可以说new所申请的内存在堆上（这点和很多网络上的文章不一致，本人选择与上面的博客文章一致）

全局/静态存储区：全局变量和静态变量的存储是放在一块的，**初始化**的全局变量和静态变量在一块区域，**未初始化**的全局变量和未初始化的静态变量在相邻的另一块区域。程序结束后由系统释放。

常量存储区：存放字面值常量，不建议修改，程序结束后由系统释放。

例子：

```c++
//main.cpp
int a = 0; 全局初始化区
char *p1; 全局未初始化区
main()
{
    int a; //栈
    char s[] = "abc"; //栈
    char *p2; //栈
    char *p3 = "123456"; //123456\0在常量区，p3在栈上。
    static int c =0； //全局（静态）初始化区
    p1 = (char *)malloc(10);
    p2 = (char *)malloc(20);//分配得来得10和20字节的区域就在堆区。
    strcpy(p1, "123456"); //123456\0放在常量区，编译器可能会将它与p3所指向的"123456",优化成一个地方。
}
```

### 堆和栈的区别

1. 管理方式：栈是用数据结构栈实现的，由系统分配，速度较快，但不受程序员控制，不够则报栈溢出的错误；**堆是由（空闲）链表实现的**，由程序员手动配置（new和delete），速度较慢，也容易产生内存泄露，但使用灵活
2. 生长方向：栈向下生长，内存地址由高到低；堆向上生长，内存地址由低到高
3. 分配效率：**栈由操作系统自动分配**，硬件层面有支持；堆是由C的库函数（malloc）、C++的操作符（new）来完成申请的，实现复杂，频繁的申请容易产生**内存碎片**，效率更低
4. 存放内容：栈存放函数返回地址、相关参数、局部变量和寄存器内容；堆的内容由程序员自己决定

### 请你回答一下malloc的原理，另外brk系统调用和mmap系统调用的作用分别是什么

malloc函数用于动态分配内存。为了减少内存碎片和系统调用的开销，malloc其采用**内存池**的方式，先申请大块内存作为堆区，然后将堆区分为多个内存块，以块作为内存管理的基本单位。当用户申请内存时，直接从堆区分配一块合适的空闲块。

malloc采用隐式链表结构将堆区分成连续的、大小不一的块，包含已分配块和未分配块；同时malloc采用**显式链表结构来管理所有的空闲块**，即使用一个双向链表将空闲块连接起来，每一个空闲块记录了一个连续的、未分配的地址。

malloc在申请内存时，一般会通过brk或者mmap系统调用进行申请。其中当申请内存小于128K时，会使用系统调用**brk在堆区**中分配；而当申请内存大于128K时，会使用系统调用**mmap在映射区**分配。

### 野指针是什么/空悬指针是什么

指向的位置是不可知的，随机的，没有限制的，不可预测的

1. 未初始化的指针
2. 指针释放后未置空（`delete ptr; ptr = nullptr`）
3. 指针操作超越边界，如访问数组时

### new/delete与malloc/free的区别是什么

malloc需要给定申请内存的大小，返回的是void*，一般需要强制类型转化；new会调用构造函数，不用指定内存大小，返回的指针不用强转。

malloc失败返回空，new失败抛bad_malloc异常

malloc分配的内存不够时，可以使用realloc扩容，而new没有这种操作

free会释放内存空间，对于类类型的对象，不会调用析构函数；delete也会释放内存空间，对于类类型对象会执行析构函数

申请数组时，`new[]`一次分配所有内存，多次调用构造函数，搭配使用`delete[]`，`delete[]`多次调用析构函数，销毁数组中的每个对象，而malloc只能接收类似`sizeof(int)*n`这样的参数形式来开辟能容纳n个int型元素的数组空间

### 三个“妞”：new operator、operator new、placement new

[](https://www.cnblogs.com/slgkaifa/p/6887887.html)

- new operator：我们最常用的new操作符，内置的，**无法重载**，它只干两件事：（根据operator new函数）分配内存+调用构造函数

- operator new：**是new函数**（最容易引起歧义的地方），**可以重载**，重载时可以添加额外参数，但第一个参数必须是size_t用来确定分配的内存，仅干一件事：分配内存

    ```c++
    void* operator new(size_t size); // 返回指针，指向一块size大小的内存
    void* rawMemory = operator new(sizeof(string)); // 直接调用new函数创建原始内存，这就跟调用malloc差不多
    ```

- placement new：在指定地址上创建对象，不分配内存，它只干一件事：调用构造函数

    ```c++
    A *ptr2 = new(ptr) A();
    ```

new一个类A的对象分为二步：

1. 调用operator new分配内存（通常在堆中），`void* operator new (size_t);`，这里会把`sizeof(A)`传入size_t型参数中
2. 调用构造函数生成类对象，`A::A()`

三种delete与三种new正好对应

### 定义一个只能new出来的类/定义一个不能new的类

在C++中，类的对象建立分为两种，一种是静态建立，如`A a`；另一种是动态建立，如`A* ptr=new A`；这两种方式是有区别的。

1. 静态建立类对象：是由编译器为对象在栈空间中分配内存，再调用类的构造函数。
2. 动态建立类对象，是使用new运算符将对象建立在堆空间中。这个过程分为两步，第一步是执行operator new()函数，在堆空间中搜索合适的内存并进行分配；第二步是调用构造函数构造对象，初始化这片内存空间。

- 答案1：**将析构函数设为私有**，类对象就无法建立在栈上了，也就只能new出来了

    编译器在为类对象分配栈空间时，会先检查类的析构函数的访问性，其实不光是析构函数，只要是非静态的函数，编译器都会进行检查。如果类的析构函数是私有的，则编译器不会在栈空间上为类对象分配内存。

    这样的类只能new出来，但是不能直接调用析构函数回收，类必须定义一个public的destroy函数，**类对象用完后必须调用destroy回收**

    ```c++
    class A{
    public:
        A(){};
        void destroy(){delete this;}
    private:
        ~A();
    }
    ```

    若要解决继承问题，则把析构函数设为protected

- 答案2：**重载operator new设为private**，因为new operator总是先调用operator new，而设为私有后就不能调用new了，故类对象只能建立在栈上，无法建立在堆上

    ```c++
    class A  
    {  
    private:  
        void* operator new(size_t t){}     // 注意函数的第一个参数和返回值都是固定的  
        void operator delete(void* ptr){} // 重载了new就需要重载delete  
    public:  
        A(){}  
        ~A(){}  
    };
    ```

### C++中delete和delete[]的区别是什么

delete操作符释放空间，而且会调用由new创建的单个对象的析构函数

`delete[]`操作符释放空间，而且会调用由`new[]`创建的一组对象的析构函数

由`new[]`创建的内存空间，如果由delete释放，则编译器只会释放第一个对象的内存空间，后面的内存空间没法释放，于是产生内存泄漏

编译器怎么知道`delete[]`要销毁多少个对象呢，关键在于`new[]`时会把instance的数量存在开头，编译器遇到`delete[]`时就会寻找这个字段值，所以建议：用delete删除new的空间，用`delete[]`删除`new[]`的空间

### strcpy、strncpy、memcpy、memmove的区别

- strcpy只提供了字符串的复制，不指定长度（没有第三个size_t参数），遇到空字符即结束，结尾的空字符也复制
- strncpy函数用于将指定长度的字符串复制到字符数组中
- memcpy提供一般的内存复制，对内容没有限制，需要指定长度，但**不检查内存重叠**
- memmove比memcpy多了个一个重叠区域检查的步骤，如果检查出有重叠，则反向拷贝

```c++
// 默认的memcpy是存在内存重叠的问题的
void* memcpy(void *dst, void* src, size_t size){
    if(dst == nullptr || src == nullptr){
        return nullptr;
    }
    void *result = dst;
    while(size--){
        *(char*)dst = *(char*)src;
        dst = (char*)dst+1;
        src = (char*)src+1;
    }
    return result;
}

// memmove没有内存重叠问题，会判断
void* memmove(void *dst, void *src, size_t size){
    if(dst == nullptr || src == nullptr){
        return nullptr;
    }
    void *result = dst;
    if(dst < src || (char*)src+size < (char*)dst){
        // 没有内存重叠
        while(size--){
            *(char*)dst = *(char*)src;
            dst = (char*)dst+1;
            src = (char*)src+1;
        }
    }
    else{
        // 没有内存重叠
        dst = (char*)dst+size-1;
        src = (char*)dst+size-1;
        while(size--){
            *(char*)dst = *(char*)src;
            dst = (char*)dst-1;
            src = (char*)src-1;
        }
    }
    return result;
}
```

### 深拷贝和浅拷贝

当没有定义拷贝构造函数时，编译器自动合成默认拷贝构造函数，假设A类有指针数据成员，调用默认拷贝构造函数后，两个类对象的指针数据成员指向同一块内存空间，这就是**浅拷贝**。

下面的代码执行后，会对同一块内存空间执行两次析构：

```c++
{
    A a1;
    A a2(a1);
}
```

浅拷贝的问题本质：**析构函数会多次释放堆内存，造成内存泄漏！**

可以查看本篇手动实现String类的代码，String的拷贝构造函数就是用的深拷贝：new一块新的内存空间，指针指向新的内存空间，实现内存分离

也可以查看本篇手动实现SmartPtr类模板的代码，shared_ptr的拷贝构造函数就是用的浅拷贝。

### 栈溢出(stack overflow)的原因

1. 局部数组过大。当函数内部的数组过大时，有可能导致堆栈溢出，因为局部变量是存储在栈中的
2. 递归调用层次太多。递归函数在运行时会执行压栈操作，当压栈次数太多时，也会导致堆栈溢出。
3. 指针或数组越界。这种情况最常见，例如进行字符串拷贝，或处理用户输入等等。

### 什么是内存泄漏

内存泄漏(memory leak)是指由于疏忽或错误造成了程序未能释放掉不再使用的内存情况。内存泄漏并非指内存在物理上的消失，而是应用程序分配某段内存后，由于设计错误，失去了对该段内存的控制，因而造成了内存的浪费。

C++内存泄漏分类：

1. 堆内存泄漏 （Heap leak）。对内存指的是程序运行中根据需要分配通过malloc,realloc new等从堆中分配的一块内存，再是完成后必须通过调用对应的 free或者delete 删掉。如果程序的设计的错误导致这部分内存没有被释放，那么此后这块内存将不会被使用，就会产生Heap Leak.
2. 系统资源泄露（Resource Leak）。主要指程序使用系统分配的资源比如 Bitmap,handle,SOCKET等没有使用相应的函数释放掉，导致系统资源的浪费，严重可导致系统效能降低，系统运行不稳定。
3. 没有将基类的析构函数定义为虚函数。当基类指针指向子类对象时，如果基类的析构函数不是virtual，那么delete基类指针只会能调用基类的析构函数，不会调用子类的析构函数，子类的资源没有正确释放，因此造成内存泄露。

mtrace是用来检查内存泄露的C函数，其原理是记录每一对malloc和free，其他类型的内存泄漏没法找出

Valgrind是专门检查内存泄漏的工具，可以发现访问未初始化的内存、访问数组时越界、忘记释放动态内存等问题，更为强大

### 什么是段错误

段错误应该就是访问了不可访问的内存，这个内存区要么是不存在的（数组越界、类型不一致），要么是受到系统保护的（内核或其他程序正在使用）。

### C++虚函数的内存模型

TODO
[《深度探索C++对象模型》笔记汇总](http://www.roading.org/develop/cpp/%E3%80%8A%E6%B7%B1%E5%BA%A6%E6%8E%A2%E7%B4%A2c%E5%AF%B9%E8%B1%A1%E6%A8%A1%E5%9E%8B%E3%80%8B%E7%AC%94%E8%AE%B0%E6%B1%87%E6%80%BB.html)

[图说C++对��模型：对象内存布局详解](https://www.cnblogs.com/QG-whz/p/4909359.html)、[C++ 虚函数详解（虚函数表、vfptr）——带虚函数表的内存分布图](https://blog.csdn.net/anlian523/article/details/90083205)

假设A是一个有虚函数的类，定义`A* obj = new A;`，则：

1. 对象指针obj位于栈区（结束自动收回）
2. A对象实例存放于堆区（必须要显式new和delete，结束不自动收回），虚函数表指针就在A对象实例的头部，指向虚函数表（这是为了在继承时最高效率获取到虚函数表）
3. Linux/Unix将虚函数表存储于只读数据段(.rodata)。虚函数指针存在于虚函数表里面，指向虚函数的地址。
4. 虚函数代码存在于代码段/代码区(.text)中

![C++查漏补缺-20200110160457.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/C%2B%2B%E6%9F%A5%E6%BC%8F%E8%A1%A5%E7%BC%BA-20200110160457.png)

### 如何进行函数调用，参数压栈顺序是怎样的，返回

函数调用时，依次把参数压栈，栈的增长由高地址往低地址的方向，**调用前，先把返回地址压入栈**，这样执行完函数之后，弹出即可获得返回地址

函数参数入栈顺序为**从右到左**，这样保证了第一个参数是栈顶（可以提及一下可变参数模板）

函数栈默认大小Windows 1Mb、Linux 8Mb或10Mb（取决于发行版），可以调整

### RTTI是什么

- RTTI(Run Time Type Identification)即通过**运行时类型识别**，程序能够使用基类的指针或引用来检查这些指针或引用所指的对象的实际派生类型，**必须定义虚函数**，实际上是通过vptr获取存储在虚函数表的type_info
- C++是一种静态类型语言。其数据类型是在编译期就确定的，不能在运行时更改，然而C++又有多态性的需求，所以需要RTTI在运行时进行类型识别
- RTTI提供了两个非常有用的操作符：**typeid**（存放于虚函数表的头部）和**dynamic_cast（**将基类类型的指针或引用安全地转换为其派生类类型的指针或引用）。

### GDB调试

在编译时就要把调试信息加入可执行文件中，如果没有-g参数，函数名、变量名全都看不到，全是内存地址

```shell
g++ -g hello.cpp -o hello
```

- 启动命令：`gdb hello`
- 调试一个正在运行的程序：`gdb attach <pid>`
- 列出源码命令：`1`
- 设置断点命令：`break 16`（源程序第16行）、`break func`（函数func入口处）
- 查看断点命令：`info break`
- 运行程序：`r`（run的简写）
- 单步运行：`n`（next的简写）
- 继续运行：`c`（continue的简写）
- 打印变量i的值：`p i`（print的简写）
- 查看函数栈：`bt`
- 退出gdb：`q`

多进程/多线程

- 查看所有进程：`info inferiors`
- 查看所有线程：`info threads`
- 切换当前调试线程：`thread <id>`
- 某线程单步运行：`thread apply <id> n`

### 性能调优方法知道哪些

- 减少冗余变量拷贝，当然不能丧失易读性
- 减少频繁的内存申请与释放，可能造成内存碎片，造成性能下降
- 提前计算，特别是多次计算的
- 空间换时间
- 内联小函数
- 位运算代替乘除法
- 编译优化，GCC开启O2优化

### C++源文件从文本到可执行文件经历的过程

一般需要四个过程：

1. 预处理阶段：对源代码文件中文件包含关系（头文件）、预编译语句（宏定义）进行分析和替换，生成预编译文件。
2. 编译阶段：语法分析、优化手段、内联函数展开，生成汇编文件
3. 汇编阶段：将汇编代码转为机器码，只需要根据汇编指令与机器码指令对照表一一翻译即可，生成可重定位目标文件
4. 链接阶段：将多个目标文件及所需要的库链接成最终的可执行目标文件，包括符号解析

### 如何避免同一个文件被include多次

- #ifndef + #define + #include + #endif：宏名冲突就失效了

- #pragma once：只能保证物理文件，但如果有拷贝的话没法保证

### 为什么模板的声明和定义都是放在同一个h文件中

模板只有在实例化的时候才会生成实体（生成机器码），如果把模板声明与定义在分离，会导致找不到具体定义

普通函数只需要声明即可编译，链接器会根据函数名找到对应的函数入口

普通的类只需要知道类的定义（不需要类的实现）即可编译

### 共享库(shared library)是什么

共享库是解决静态库缺陷的现代产物，它是一个目标模块，在运行或加载时可以加载到任意内存地址，并和一个在内存中的程序链接起来，这就是动态链接，这是由动态链接器实现的

共享库也叫做共享目标，在Linux中通常以.so后缀来表示，在微软的操作系统中叫做DLL(动态链接库)

### 静态链接与动态链接(dynamic linking)的区别

链接技术将多个目标文件以及所需的库链接成最终的可执行目标文件

静态链接器从库中复制这些函数和数据并把它们和应用程序的其它模块组合起来创建最终的可执行文件；动态链接器把程序按照模块拆分成各个相对独立部分，在程序运行时才将它们链接在一起形成一个完整的程序

静态链接浪费了空间，可能同一份目标文件有多个副本；动态链接节省了空间，多个程序共享同一份副本

静态链接更新困难，每当库函数代码修改，需要重新编译链接形成可执行程序；动态链接更新方便，只需要替换原来的目标文件即可，程序运行时自动加载新目标文件到内存并链接起来，这就完成了更新

静态链接运行速度快，因为可执行程序已经具备了所有东西；动态链接运行速度较慢，因为每次执行时还需要链接

### C++库的发布发布方式——源码库才是王道

动态库更新后，之前运行正常的程序使用的将不再是当初build和测试的代码，程序的结果变得不可预期

静态库可能会有重复链接（x依赖y与z，y也依赖z）和版本冲突（a依赖b与c，b依赖旧d，c依赖新d）的危害

每个应用程序自己选择要用到的库，并自行编译为单个可执行文件。彻底避免头文件与库文件之间的时间差，确保整个项目的源文件采用相同的编译选项，也不用为库的版本搭配操心。这么做的缺点是编译时间很长，因为把各个库的编译任务从库文件的作者转嫁到了每个应用程序的作者。

### 库打桩技术什么

Linux链接器支持库打桩（library interpositioning），它允许用户截获对共享库函数的调用，取而代之执行自己的代码

编译时打桩、链接时打桩、运行时打桩

### include头文件的顺序

对于include的头文件来说，如果在文件a.h中声明一个在文件b.h中定义的变量，而不引用b.h。那么要在a.c文件中引用b.h文件，并且要先引用b.h，后引用a.h,否则汇报变量类型未声明错误。

google C++编程风格的建议，为了加强可读性和避免隐含依赖，应使用下面的顺序：C标准库、C++标准库、其它库的头文件、你自己工程的头文件。不过这里最先包含的是首选的头文件，即例如a.cpp文件中应该优先包含a.h。首选的头文件是为了减少隐藏依赖，同时确保头文件和实现文件是匹配的

### include头文件双引号""和尖括号<>的区别

编译器预处理阶段查找头文件的路径不一样。

对于双引号：当前头文件目录、编译器设置的头文件路径（编译器可使用-I显式指定搜索路径）、系统变量CPLUS_INCLUDE_PATH/C_INCLUDE_PATH指定的头文件路径

对于尖括号：编译器设置的头文件路径（编译器可使用-I显式指定搜索路径）、系统变量CPLUS_INCLUDE_PATH/C_INCLUDE_PATH指定的头文件路径

### 前向声明(forward declaration)

前向声明：**声明一个类而不定义它**

在声明后定以前，这个类是**不完全类型(incomplete type)**，编译器只知道它是个类，但不知道有什么成员。

不完全类型只能以有限方式使用，**不能定义该类型的对象**，不完全类型只能用于定义指向该类型的**指针或引用**，或者用于声明(而不是定义)使用该类型作为形参类型或返回类型的函数。

```c++
class A;
class B
{
  public:
  A* m_a; //（不能A m_a）
}
```

也可以用include，这个时候编译器就知道了A有哪些成员，就可以定义A的对象了，可以看到前向声明可以减少include的时间损耗

```c++
#include "A.h"
class B
{
  public:
  A* m_a; //(可以A m_a)
}
```

### Qt信号槽机制原理以及优缺点

信号槽是Qt的精髓，实际就是**观察者模式**。当某个事件发生之后，比如，按钮检测到自己被点击了一下，它就会发出一个**信号（signal）**。这种发出是没有目的的，类似广播。如果有对象对这个信号感兴趣，它就会使用**连接（connect）**函数，意思是，将想要处理的信号和自己的一个函数（称为槽（slot））绑定来处理这个信号。也就是说，当信号发出时，被连接的槽函数会**自动被回调**。

用于对象间的通信，如果不用信号槽机制的话，得用**回调函数**，但有两个缺点：

1. 它们并**不是类型安全**，我们永远都不能确定调用者是否将通过正确的参数来调用“回调函数”
2. 回调函数与处理函数是**紧耦合（strongly coupled）**的，因为调用者必须知道应该在什么时候调用哪个回调函数。

主要优点如下：

1. 信号槽是**类型安全**：信号的参数必须与接收槽匹配
2. 信号槽是**松耦合**：激发信号的Qt对象无需知道哪个对象的哪个槽接收信号
3. 信号槽加强了对象通信的**灵活性**：一个信号可以关联多个槽，一个槽也可以关联多个信号
4. 建立和绑定非常**方便**

信号槽的缺点也是有的：

信号槽机制**运行速度较慢**

## STL

### STL的六大组件

空间分配器、迭代器、容器、泛型算法、仿函数（作为泛型算法的comparable参数）、配接器（迭代器适配器inserter、容器适配器queue和stack）

分配器给容器分配存储空间，算法通过迭代器获取容器中的内容，仿函数可以协助算法完成各种操作，配接器用来套接适配仿函数

### 迭代器的作用/指针与迭代器的区别

迭代器类型：input output forward(写回) bidirection random

迭代器**封装了指针**，它可以**顺序地访问**容器内的对象，而又**不暴露对象的具体实现**

迭代器作为一种**粘合剂**，在容器和泛型算法中广泛使用

迭代器不是指针，它是类模板，一般里面会有指针成员，模拟指针功能，重载了`++ -- * ->`等操作符

注意：迭代器的解引用操作返回的是对象引用而不是对象的值

### 简单实现String

[C++面试中STRING类的一种正确写法-陈硕](https://coolshell.cn/articles/10478.html)

### map的一些问题/map底层为什么要用红黑树实现

[关于 std::set/std::map 的几个为什么-陈硕](https://blog.csdn.net/Solstice/article/details/8521946)

红黑树是一种二叉查找树，但在每个节点增加一个存储位表示节点的颜色，可以是红或黑（非红即黑）。

红黑树是一种**弱平衡**二叉树，相对于要求严格的AVL树来说，它的旋转次数少，所以插入删除要比AVL快，O(logn)，性能稳定，所以用红黑树。

红黑树性质：

1. 每个节点非红即黑
2. 根节点是黑的;
3. 每个叶节点（叶节点即树尾端NULL指针或NULL节点）都是黑的;
4. 如果一个节点是红色的，则它的子节点必须是黑色的。
5. 对于任意节点而言，其到叶子点树NULL指针的每条路径都包含相同数目的黑节点;

### 介绍一下STL的allocator

allocator是C++中的空间配置器，用于封装STL容器在内存管理上的底层细节，注意不是内存配置器，因为内存是空间的一部分。

其内存配置和释放如下：new运算分两个阶段：(1)调用new操作符配置内存;(2)调用对象构造函数构造对象内容。delete运算分两个阶段：(1)调用对象希构函数；(2)调用delete操作符释放内存

为了减小内存碎片问题，SGI STL采用了两级配置器，当分配的空间大小超过128 bytes时，会使用第一级空间配置器；当分配的空间大小小于128 Bytes时，将使用第二级空间配置器。

第一级空间配置器直接使用malloc()、realloc()、free()函数进行内存空间的分配和释放。

而第二级空间配置器采用了**内存池**技术，通过**空闲链表**来管理内存，初始配置一大块内存，并维护对应不同内存空间大小的的16个空闲链表，如果有内存需求，直接在空闲链表中取，如果有内存释放，则归还到空闲链表中。

### STL迭代器失效总结

vector

1. 插入（push_back）一个元素后，插入前end()操作返回的迭代器肯定失效，常见的错误做法如下：

    ```c++
    auto end = vec.end();
    for(it = vec.begin(); it != end; ++it){
        vec.push(back(0));
    }
    ```

2. 插入一个元素，有可能vector的capacity发生了变化（这里牵涉到vectora的动态扩容），那么原来所有的迭代器都失效

3. 当进行删除操作（erase，pop_back）后，指向删除点的迭代器全部失效；指向删除点后面的元素的迭代器也将全部失效。一般可以利用erase()的返回值得到删除点后面的那个元素

    ```c++
    vector<int> vec = {0,1,2,3};
    auto it = vec.begin();
    it = vec.erase(it); // now it points to 1
    ```

list

1. 插入（insert）和接合（splice）都不会使原有的list迭代器失效，链表只需要改变指针就好，内存没有发生变化，所以迭代器也不会失效
2. 删除操作（erase）也只有指向被删除元素的那个迭代器失效，其他迭代器不受影响。

deque

1. 在队前或队后插入元素时（push_back(),push_front()）,由于可能缓冲区的空间不够，需要增加map中控器，而中控器的个数也不够，所以新开辟更大的空间来容纳中控器，而deque迭代器中有四个指针，分别指向当前节点、当前缓冲区头、当前缓冲区尾、中控器，指向中控器的那个指针肯定失效了，所以deque迭代器也会失效！但是指针和引用不会失效，因为缓冲区已有的元素并没有重新分配内存！
2. 其他位置插入元素时，由于会造成缓冲区的一些元素的移动（源码中执行copy()来移动数据），所以肯定会造成迭代器的失效
3. 删除队头或队尾的元素时，由于只是对当前的元素进行操作，所以其他元素的迭代器不会受到影响，所以一定不会失效，而且指针和引用也都不会失效；
4. 删除其他位置的元素时，也会造成元素的移动，所以其他元素的迭代器、指针和引用都会失效。

queue和stack严格来说是容器适配器，底层用的容器还是deque，又因为它们不提供遍历行为，所以压根就没有迭代器！

priority_queue是用堆（heap）实现的，默认最大堆，只有最顶端的元素才有机会被外界使用，所以不提供遍历行为，所以压根就没有迭代器！

set和map底层是以红黑树结构来实现的，而父子节点的连接只需要指针就好了，插入一个元素不会使任何迭代器失效，删除当前的迭代器，仅仅会使当前的迭代器失效，但是erase()操作返回值是void，所以想要遍历的话只能通过erase(iter++)实现

unordered_set和unordered_map底层是用哈希表实现的，而一般哈希表是用开链法解决哈希冲突的，即散列到同一个bucket/slot上的元素，通过链表连接起来，所以这两个容器的迭代器，插入不影响其他迭代器，删除只影响删除节点的迭代器；但有一个例外，如果哈希表中元素过多，需要再散列（rehashing），所有原来的迭代器都会失效

### vector的resize和reserve的区别

resize(size_type n)：改变当前容器内**含有元素的数量**，后面可以用vec.size()获取n。如果原来vec.size()小于n，那么容器会新增（n-原size）个元素，新元素调用默认构造函数（该函数也可接受第二个参数用来确定新增元素的初始值）；如果原来vec.size()大于n，则会删除n之后的所有元素。

reserve(size_type n)：改变当前容器的**最大容量（capacity）**,它不会生成元素，只是确定这个容器允许放入多少对象，如果reserve(len)的值大于当前的capacity()，那么会重新分配一块能存len个对象的空间，然后把之前v.size()个对象通过copy construtor复制过来，销毁之前的内存；

### vector为什么不能存引用类型数据

引用必须初始化，且不能改变引用指向新的对象，而vector执行的时候是需要执行copy的，把以前的对象放在vector开辟的内存中，这就相当于因果顺序调换了，原对象是因，引用才是果，不能先有果再有因

## 操作系统

### 请你说一说用户态和内核态区别

用户态和内核态是操作系统的两种**运行权限级别**，内核态拥有的权限更高，运行在用户态的进程不能访问内核态的资源

两者之间的转换方式主要包括：

1. 系统调用：处于用户态的进程主动请求切换到内核态，其核心仍是使用了操作系统为用户特别开发的中断机制来实现的
2. 异常：CPU执行用户态的进程时发生了事先不可知的错误，由此切换到内核态去处理异常
3. 中断：外设发出中断信号给CPU，CPU把正在运行的处于用户态的进程暂停，切换到中断处理程序上去，这就实现了用户态到内核态的转换

### 微内核和宏内核

宏内核/单内核：把进程、线程管理、内存管理、文件系统，驱动，网络协议等等都集成在内核里面，例如linux内核。

优点：**效率高**；
缺点：**稳定性差**，开发过程中的bug经常会导致整个系统挂掉。

微内核：内核中只有**最基本的调度、内存管理**。驱动、文件系统等都是用户态的守护进程去实现的。

优点：**稳定性高**，驱动等的错误只会导致相应进程死掉，不会导致整个系统都崩溃；
缺点：**效率低**。

### Linux启动过程

1. 加载内核：打开电源后，加载BIOS引导，硬件自检，读取MBR（主引导记录），运行Boot Loader，内核就启动了
2. init：内核启动后，第一个运行init进程，init进程是所有进程的老祖宗，其配置文件是/etc/inittab，通过该文件设置运行等级：根据/etc/inittab文件设置运行等级，比如有无网络
3. 系统初始化：启动第一个用户层文件/etc/rc.d/rc.sysinit，然后激活交换分区、检查磁盘、加载硬件模块等
4. 建立终端：系统初始化后返回init，这时守护进程也启动了，init接下来打开终端以供用户登录

### Linux命令

- 查看线程

    `ps -T`

    `top -H`（或者在top运行时输入H查看线程）

    以上两个命令都可以指定特定进程的线程，加上`-p <pid>`即可

- 解释一下top命令右上角三个数字的意思

    表示CPU的平均负载，分别表示最近1分钟、最近5分钟、最近15分钟的平均负载。一般是0~1之间

- 按照内存使用情况对进程排序

    `ps aux --sort -rss`

    VSZ是虚拟内存，rss是物理内存

- 查看一个文件的第100行到200行

    `cat <filename> | awk 'NR >= 100 && NR <=200'`

- 修改最大文件句柄（也就是文件描述符）数量

    用户级（仅对当前进程有效）：ulimit -n 65536

    系统级：`/etc/security/limits.conf`

### Linux日志系统

syslog是Linux的守护进程，rsyslog是加强版，配置文件位于`/etc/syslog.conf`

syslog可以根据日志的类别和优先级将日志保存到不同的文件中。

```c++
#include <syslog.h>
int main(int argc, char **argv)
{
   openlog("MyMsgMARK", LOG_CONS | LOG_PID, 0); // "MyMsgMARK"将被加至每则记录消息中，
   syslog(LOG_DEBUG,
          "This is a syslog test message generated by program '%s'\n",
          argv[0]);
   closelog();
   return0;
}
```

### 进程与线程的概念、区别

进程（process）是运行程序的一个实例，是程序运行的所有资源的总和，是操作系统进行资源调度和分配的最小单位。

线程（thread）是轻量级的进程，每个线程完成不同的任务，但是共享同一地址空间和全局变量，是CPU调度的最小单位

区别：

1. 一个线程只能属于一个进程，而一个进程可以至少有一个线程，可以有多个线程。线程依赖于进程而存在
2. 进程在执行过程中拥有独立的内存单元，资源分配给进程，同一进程的所有线程共享该进程的所有资源，包括地址空间、代码段（代码和常量）、数据段（全局变量和静态变量）、堆，但是**每个线程拥有自己的栈段以及寄存器**
3. 进程是资源分配的最小单位，线程是CPU调度的最小单位
4. 系统开销：创建或销毁进程时，系统要为之分配或回收资源，因此开销比线程更大；类似地，进程切换涉及到整个进程CPU环境的保存以及新被调度运行的进程的CPU环境的设置。而线程切换只须保存和设置少量寄存器的内容，所以进程切换的开销也远大于线程切换的开销。
5. 通信：由于同一进程中的多个线程具有相同的地址空间，所以它们之间的同步和通信的实现也变得比较容易
6. 进程间不会相互影响 ；线程一个线程挂掉将导致整个进程挂掉

### 有了进程为什么还有线程

并行实体共享同一个地址空间和所有可用数据的能力，线程间通信非常方便

线程比进程更轻量级，所以它们比进程更容易、更快创建，也更容易撤销，从资源上来说，线程更加节俭

拥有多个线程允许这样活动彼此重叠进行，从而会加快应用程序执行速度，从切换效率上来说，线程更快

### 多进程与多线程的使用场景

多进程适用于**CPU密集型**，或者**多机分布式**场景中, 易于多机扩展

多线程模型的优势是线程间切换代价较小, 因此适用于**I/O密集型**的工作场景, 因此I/O密集型的工作场景经常会由于I/O阻塞导致频繁的切换线程。同时, 多线程模型也适用于**单机多核**分布式场景

### 协程是什么

协程（coroutine）又叫微线程、纤程，完全位于用户态，一个程序可以有多个协程

协程的执行过程类似于子例程，允许子例程在特定地方挂起和恢复

协程是一种伪多线程，在一个线程内执行，**由用户切换**，由**用户选择切换时机**，**没有进入内核态**，只涉及CPU上下文切换，所以切换效率很高

缺点：协程适用于IO密集型，不适用于CPU密集型

libco是微信后台大规模使用的c/c++协程库。libco采用**epoll多路复用**使得一个线程处理多个socket连接，采用钩子函数hook住socket族函数，采用时间轮盘处理等待超时事件，采用协程栈保存、恢复每个协程上下文环境。

### 进程状态与进程分类

1. 创建状态：进程正在被创建
2. 就绪状态：进程被加入到就绪队列中等待CPU调度运行
3. 执行状态：进程正在被运行
4. 阻塞状态：进程因为某种原因，比如等待I/O，等待设备，而暂时不能运行。
5. 终止状态：进程运行完毕

Linux进程分类

1. 交互进程——由一个shell启动的进程。交互进程既可以在前台运行，也可以在后台运行。
2. 批处理进程——这种进程和终端没有联系，是一个进程序列。
3. 监控进程（也称守护进程）——Linux系统启动时启动的进程，并在后台运行。

### 进程间通信

每个进程各自有不同的用户地址空间，任何一个进程的全局变量在另一个进程中都看不到，所以进程之间要交换数据必须通过内核,在内核中开辟一块缓冲区，进程A把数据从用户空间拷到内核缓冲区，进程B再从内核缓冲区把数据读走，内核提供的这种机制称为进程间通信。

1. 管道：通信必须FIFO，包括匿名管道和有名管道，匿名管道只能用于具有亲缘关系的父子进程间的通信，有名管道还允许无亲缘关系进程间的通信
2. 消息队列：消息的链表，存放在内核中并由消息队列标识符标识。消息队列传递的信息比信号要多，通信不必FIFO
3. 信号量：它是一个计数器，可以用来控制多个进程对共享资源的访问，主要用于实现进程间的互斥与同步，而不是用于存储进程间通信数据
4. 信号：信号是一种比较复杂的通信方式，用于通知接收进程某个事件已经发生。主要作为进程间以及同一进程不同线程之间的同步手段。
5. 共享内存（最快的）：多个进程可以访问同一块内存空间，不同进程可以及时看到对方进程中对共享内存中数据得更新。这种方式需要依靠某种同步操作，如互斥锁和信号量等
6. **套接字socket**：可用于不同机器间的进程通信，根据陈硕的建议，进程间通信只用TCP

### 线程间通信/同步方式

因为线程共享同一地址空间，所以线程间的通信目的主要是用于线程同步，所以线程没有像进程通信中的用于数据交换的通信机制。

各个线程可以访问进程中的公共变量，资源，所以使用多线程的过程中需要注意的问题是如何防止两个或两个以上的线程同时访问同一个数据，以免破坏数据的完整性。

1. 锁机制：包括互斥锁、条件变量、读写锁
    - 互斥锁提供了以排他方式防止数据结构被并发修改的方法。
    - 读写锁允许多个线程同时读共享数据，而对写操作是互斥的。
    - 条件变量可以以原子的方式阻塞进程，直到某个特定条件为真为止。对条件的测试是在互斥锁的保护下进行的。**条件变量始终与互斥锁一起使用**。
2. 信号量机制：包括无名线程信号量和命名线程信号量
3. 信号机制：类似进程间的信号处理

### 互斥锁与读写锁的区别

互斥锁：mutex，用于保证在任何时刻，都只能有一个线程访问该对象。当获取锁操作失败时，线程会进入睡眠，等待锁释放时被唤醒。

读写锁：rwlock，分为读锁和写锁。处于读操作时，可以允许多个线程同时获得读操作。但是同一时刻只能有一个线程可以获得写锁。其它获取写锁失败的线程都会进入睡眠状态，直到写锁释放时被唤醒。 注意：写锁会阻塞其它读写锁。当有一个线程获得写锁在写时，读锁也不能被其它线程获取；写者优先于读者（一旦有写者，则后续读者必须等待，唤醒时优先考虑写者）。适用于读取数据的频率远远大于写数据的频率的场合。

### 信号量与互斥锁的区别

二进制信号量与互斥锁在实现上很像，但是在设计上细微差别。

互斥锁强调**对资源的保护**，锁只能由当前线程释放，**只能用来构造临界区**。

信号量强调**调度线程**，通过PV操作让线程在临界区内的执行顺序合理，

### Linux内核的锁机制

1. 互斥锁：mutex，用于保证在任何时刻，都只能有一个线程访问该对象。当获取锁操作失败时，线程会进入睡眠，等待锁释放时被唤醒
2. 读写锁：rwlock，分为读锁和写锁。处于读操作时，可以允许多个线程同时获得读操作。但是同一时刻只能有一个线程可以获得写锁。其它获取写锁失败的线程都会进入睡眠状态，直到写锁释放时被唤醒。 注意：写锁会阻塞其它读写锁。当有一个线程获得写锁在写时，读锁也不能被其它线程获取；写者优先于读者（一旦有写者，则后续读者必须等待，唤醒时优先考虑写者）。适用于读取数据的频率远远大于写数据的频率的场合。
3. 自旋锁：spinlock，**轮询忙等待**，在任何时刻同样只能有一个线程访问对象。但是当获取锁操作失败时，不会进入睡眠，而是会在原地自旋，直到锁被释放。这样节省了线程从睡眠状态到被唤醒期间的消耗，在加锁时间短暂的环境下会极大的提高效率。但如果加锁时间过长，则会非常浪费CPU资源。
    > 问：两个进程访问临界区资源，会不会出现都获得自旋锁的情况？
    > 答：单核CPU且开了抢占可以
4. RCU：即read-copy-update，在修改数据时，首先需要读取数据，然后生成一个副本，对副本进行修改。修改完成后，再将老数据update成新的数据（感觉有点像写时复制）。使用RCU时，**读者几乎不需要开销**，既不需要获得锁，也不使用原子指令，不会导致锁竞争，因此就不用考虑死锁问题了。而**写者开销较大**，它需要复制被修改的数据，还必须使用锁机制同步并行其它写者的修改操作。在有大量读操作，少量写操作的情况下效率非常高。

### 单核机器上写多线程程序，是否需要加锁，为什么

仍然需要线程锁。线程锁通常用来实现线程的同步和通信，在单核机器上的多线程程序，仍然存在线程同步的问题

考虑一个抢占式操作系统，每个线程分配一个时间片，如果两个线程共享某些数据，而其中一个线程被抢占，则会引起冲突，所以需要线程同步

### CPU调度方法有哪些

对于单处理器系统，每次只允许一个进程运行，任何其他进程必须等待，直到CPU空闲能被调度为止，**多道程序**的目的是在任何时候都有某些进程在运行，以使CPU使用率最大化。

- 先到先服务FCFS，用了FIFO队列，非抢占
- 最短作业优先调度SJF，先处理短进程，平均等待时间最小，所以是**最佳**的
- 优先级调度，会有**饥饿**现象，低优先级的进程永远得不到调度
- 轮转法调度Round Robin，就绪队列作为循环队列，按**时间片**切换，
- 多级队列调度，根据进程的属性（如内存大小、类型、优先级）分到特定队列，不同队列执行不同的调度算法
- 多级反馈队列调度，允许进程在队列之间移动

### 系统调用是什么，你用过哪些系统调用

系统调用是处于用户态的程序向内核请求更高权限的资源的服务，提供了用户程序与内核之间的接口

对文件进行写操作, c语言的open, write, fork, vfork，socket系列等等都是系统调用

### 说一说fork,wait,exec函数

fork

1. 父进程使用fork拷贝出来一个父进程的副本，只拷贝了父进程的页表，两个进程都读同一块内存，当有进程写的时候使用写时拷贝机制（见下点）分配内存
2. fork从父进程返回子进程的pid，从子进程返回0.
3. fork(2)是内核调用,fork(3)是posix库调用

wait

1. 调用了wait的父进程将会发生阻塞，直到有子进程状态改变,执行成功返回0，错误返回-1。

exec函数族，主要有execve()、execl、execlp等等

1. exec函数可以加载一个elf文件去替换当前进程，一个进程一旦调用exec类函数，它本身就"死亡"了，系统把代码段替换成新的程序的代码，废弃原有的数据段和堆栈段，并为新程序分配新的数据段与堆栈段，唯一留下的，就是进程号，也就是说，对系统而言，还是同一个进程，不过已经是另一个程序了
2. exec执行成功则子进程从新的程序开始运行，无返回值，执行失败返回-1

### 什么孤儿进程，什么是僵尸进程，其危害是什么，如何处理

孤儿进程：

- 一个父进程退出，而它的一个或多个子进程还在运行，那么那些子进程将成为孤儿进程。
- 孤儿进程将被init进程(进程号为1)所收养，并由init进程对它们完成状态收集工作。

僵尸进程：

- 一个进程使用fork创建子进程，如果子进程退出，而父进程并没有调用wait或waitpid获取子进程的状态信息，那么子进程的**进程描述符**仍然保存在系统中。
- 僵尸进程是一个进程必然会经过的过程，这是每个子进程在结束时都要经过的阶段。
- 使用ps命令，状态为Z的即为僵尸进程。

一个进程是有可能又是孤儿进程又是僵尸进程，这时init进程会以父进程的身份对僵尸进程进行处理。

危害：

如果进程不调用wait / waitpid的话， 那么它所占据的资源就不会释放（如**进程控制块PCB**），比如其进程号就会一直被占用，但是系统所能使用的进程号是有限的，如果大量的产生僵死进程，将因为没有可用的进程号而导致系统不能产生新的进程。（我有感触，我当时在mac电脑测试多进程程序，忘记回收子进程了，导致电脑卡死，只能重启，再复现一次场景后，我想到可能是有大量僵尸进程）

外部消灭僵尸进程可以用kill命令，内部解决可以在子进程退出时向父进程发送SIGCHILD信号，父进程在处理信号函数中调用wait处理僵尸进程

waitpid第一个参数指定要回收进程的PID，传入-1就和wait一样。第二个参数指定选项，一般用NOHANG，表示不阻塞

### vfork是什么，请你回答一下fork和vfork的区别

1. fork()会复制父进程的页表，而vfork()不会复制，直接让子进程共用父进程的页表
2. fork()的父子进程的执行次序不确定；vfork()保证子进程先运行，在调用exec或exit之前与父进程数据是共享的，在它调用exec或exit之后父进程才可能被调度运行，如果调用exec或exit之前子进程依赖于父进程的某些动作，则会导致死锁
3. vfork的出现原因：在实现写时复制之前，为了避免fork后立刻执行exec所造成的地址空间的浪费

### 写时复制（Copy-On-Write, COW）是什么

1. 写时复制是一种惰性优化方法，以减少fork时对父进程空间进程整体复制带来的开销
2. 如果有多个进程要读取同一资源的副本，那么复制是不必要的，每个进程只要保存一个指向这个资源的指针就可以了，这样就存在着幻觉：每个进程好像独占那个资源，从而避免复制的开销
3. 如果一个进程要修改自己的那份资源“副本”，那么就会复制那份资源，并把复制的那份提供给进程，复制过程对于进程来说是透明的。这个进程就可以修改复制后的资源了，同时其他的进程仍然共享那份没有修改过的资源
4. 如果进程从来就不需要修改资源，则不需要进行复制。惰性算法的好处就在于它们尽量推迟代价高昂的操作，直到必要的时刻才会去执行
5. 在使用虚拟内存的情况下，写时复制是以页为基础进行的
6. 在fork()结束后，父进程和子进程都相信它们有一个自己的地址空间，但实际上它们共享了父进程的原始页
7. 在内核实现中，写时复制触发缺页中断，处理缺页中断的方法是对该页进行一次透明复制

### 交换技术是什么

把所有进程一直保存在内存需要巨大的内存，有两种处理内存超载的方法：

1. 交换（swapping）技术，将内存**暂时不能运行**的进程换出到磁盘上，来腾出足够的内存空间给**具备运行条件**的进程，空闲进程主要存储在磁盘上
2. 虚拟内存：每个进程只装入一部分在内存

于是在交换技术下，进程状态有了动态与静态之分：

1. 活动阻塞：进程在内存，但是由于某种原因被阻塞了。
2. 静止阻塞：进程在外存，同时被某种原因阻塞了。
3. 活动就绪：进程在内存，处于就绪状态，只要给CPU和调度就可以直接运行。
4. 静止就绪：进程在外存，处于就绪状态，只要调度到内存，给CPU和调度就可以运行。

### 地址空间是什么

1. 地址空间是一个进程可用于寻址内存的一套地址集合
2. 地址空间为程序创造了一种抽象的内存
3. 每个进程都有一个自己的地址空间，并且这个地址空间独立于其他进程的地址空间
4. 物理地址空间对应物理内存的字节，虚拟地址空间是从物理地址空间中生成的，一个包含2^n个地址的虚拟地址空间就叫做一个n位地址空间，现代操作系统一般支持32位虚拟地址空间或64位虚拟地址空间，也就是有2^32个或2^64个虚拟地址

### Linux虚拟地址空间

Linux 使用虚拟地址空间，大大增加了进程的寻址空间，由低地址到高地址分别为：

1. 只读段：该部分空间只能读，不可写；(包括：代码段、rodata 段(C常量字符串和#define定义的常量) )
2. 数据段：保存全局变量、静态变量的空间；
3. 堆 ：就是平时所说的动态内存， malloc/new 大部分都来源于此。其中堆顶的位置可通过函数 brk 和 sbrk 进行动态调整。
4. 文件映射区域 ：如动态库、共享内存等映射物理空间的内存，一般是 mmap 函数所分配的虚拟地址空间。
5. 栈：用于维护函数调用的上下文空间，Linux一般为8M或10M，可通过 ulimit –s 查看。
6. 内核虚拟空间：用户代码不可见的内存区域，由内核管理(页表就存放在内核虚拟空间)。

![C++查漏补缺-20200110153235.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/C%2B%2B%E6%9F%A5%E6%BC%8F%E8%A1%A5%E7%BC%BA-20200110153235.png)

### 虚拟内存是什么

1. 每个进程拥有自己的虚拟地址空间，这个空间被分割成多个页面(page)/虚拟页，页面存放于磁盘中，这些页面被映射到物理内存中的页框/物理页，页面与页框大小一般相等
2. 页表(page table)负责把操作系统虚拟内存映射为物理内存，页表存放于物理内存中，页表中有若干页表项(page table entry)，每个页表项对应虚拟内存的每个页面，页面被分为三种：
    1. 已缓存：磁盘中的页面有对应的页框
    2. 未缓存：磁盘中的页面没有对应的页框
    3. 未分配：磁盘中的页面还没有被页表记录
3. 页命中：CPU想要读已缓存的页面，翻译成物理地址访问页框，这样非常快
4. 缺页(page fault)：CPU想要读的页面未缓存或未分配，则产生缺页，从缓存的角度来说是内存缓存不命中，这就需要缺页置换算法（在内存中选择合适的页面换出）

虚拟内存的优势

1. 提供**缓存**，加速运行
2. 扩大地址空间
3. 每个进程都有自己的虚拟地址空间，互不影响

缺点：

1. 频繁地换入换出需要磁盘I/O
2. 页表查询需要时间

### 缺页中断是怎么回事

缺页中断指的是当进程试图访问已映射在虚拟地址空间，但并未被加载在物理内存中的一个分页时，由CPU所触发的中断。

缺页中断会使进程陷入内核，然后执行以下操作：

1. 检查要访问的虚拟地址是否合法
2. 查找/分配一个物理页
3. 填充物理页内容（读取磁盘，或者直接置0，或者啥也不干）
4. 建立映射关系（虚拟地址到物理地址）

与普通的中断的区别在于：

1. 在指令执行期间产生和处理缺页中断信号
2. 一条指令在执行期间，可能产生多次缺页中断
3. 缺页中断返回时，执行产生中断的那一条指令，而一般的中断返回时，执行下一条指令

### 页面置换算法有哪些，优缺点是什么

如果发生缺页中断，为了能够把所缺的页面装入内存，系统必须从内存中选择一页将其换出，选择哪个页面调出就取决于页面置换算法。如果一个被频繁使用地页面被置换出内存，那么它很快又要被调入内存，这就造成了不必要的开销，所以一个好的页面置换算法至关重要。最常用的是LRU算法。

PS：如果要换出的页面在驻留内存期间已经被修改过，就必须把它写回磁盘以更新该页面在磁盘上的副本，如果该页面没有被修改过，那么就不需要写回磁盘，

1. 最佳/最优置换（Optimal）：被置换的页面以后不再被访问，或者在将来最迟才回被访问的页面，缺页中断率最低，这是不切实际的，但仍可以作为衡量其他页面置换算法的标准
2. 先进先出置换（FIFO）：置换最先调入内存的页面，即置换在内存中驻留时间最久的页面，一般按照进入内存的先后次序排列成队列，但是该算法会淘汰经常访问的页面，不适合进程实际运行规律，很少使用纯粹的FIFO置换算法
3. 最近最少使用置换（Least Recently Used, LRU）：置换最近一段时间以来最长时间未访问过的页面。根据程序局部性原理，刚被访问的页面，可能马上又要被访问；而较长时间内没有被访问的页面，可能最近不会被访问。LRU置换算法效率不粗破，适用于各种类型的程序，但是系统要时时刻刻对各页的访问历史情况加以记录和更新，开销太大，因此LRU置换算法必须要有硬件的支持
4. 时钟页面置换算法（clock）：现实的
5. 最近未使用（NRU）：LRU的很粗糙的近似
6. 最不经常使用（NFU）：LRU的相对粗略近似
7. 老化算法：非常近似LRU的有效算法
8. 工作集算法：开销很大
9. 工作集时钟算法：好的有效算法。

### Linux的定时器机制（时间轮与红黑树）

前提：Linux根据时钟源设备启动tick中断，用tick计时，基于Hz，精度是1/Hz

低精度：用**时间轮（timing wheel）**机制维护定时事件，时间轮的触发基于tick，**周期触发**，内核根据时间轮处理超时事件

高精度：hrtimer（high resolution），**基于事件触发**，基于**红黑树**，将高精度时钟硬件的下次中断触发设置为红黑树最早到期的时间，到期后又取得下一个最早到期时间（类似于最小堆）

### 死锁(deadlock)发生的条件以及解决方法

死锁是指两个或两个以上进程在执行过程中，因争夺资源而造成的下相互等待的现象

四个必要条件：

1. 互斥条件：进程对所分配到的资源不允许其他进程访问，若其他进程访问该资源，只能等待，直至占有该资源的进程使用完成后释放该资源；
2. 占有和等待条件：进程获得一定的资源后，又对其他资源发出请求，但是该资源可能被其他进程占有，此时请求阻塞，但该进程不会释放自己已经占有的资源
3. 不可抢占条件：进程已获得的资源，在未完成使用之前，不可被剥夺，只能在使用后自己释放
4. 环路等待条件：进程发生死锁后，必然存在一个进程-资源之间的环形链（一般用资源分配图表示）

解决死锁的方法即破坏上述四个条件之一，主要方法如下：

1. 破坏互斥条件
2. 破坏占有和等待条件：**资源一次性分配**；或者当有进程要请求资源时，先暂时释放其当前所占有的所有资源，再尝试一次性分配资源
3. 破坏不可抢占条件：当进程新资源未获得满足时，释放已占有的资源
4. 破坏环路等待条件：操作系统**给所有资源统一编号，**每个进程按照编号递增地请求资源，释放则相反

### 关于最少资源数量的死锁问题

某系统有n台互斥使用的同类设备，3个并发进程需要3,4,5台设备，可确保系统不发生死锁的设备数n最小为：10台

计算：

假设进程1得到2台，进程2得到3台，进程3得到4台，总共安排9台，这样会产生死锁。

只要再加1台变成10台，那么分配给任意进程，都可以完成任务，从而释放资源，从而避免死锁

### 活锁(livelock)是什么，死锁与活锁的区别

活锁是指线程1可以使用资源，但它很礼貌，让其他线程先使用资源，线程2也可以使用资源，但它很绅士，也让其他线程先使用资源。这样你让我，我让你，最后两个线程都无法使用资源。

关于“死锁与活锁”的比喻：

死锁：迎面开来的汽车A和汽车B过马路，汽车A得到了半条路的资源（满足死锁发生条件1：资源访问是排他性的，我占了路你就不能上来，除非你爬我头上去），汽车B占了汽车A的另外半条路的资源，A想过去必须请求另一半被B占用的道路（死锁发生条件2：必须整条车身的空间才能开过去，我已经占了一半，尼玛另一半的路被B占用了），B若想过去也必须等待A让路，A是辆兰博基尼，B是开奇瑞QQ的屌丝，A素质比较低开窗对B狂骂：快给老子让开，B很生气，你妈逼的，老子就不让（死锁发生条件3：在未使用完资源前，不能被其他线程剥夺），于是两者相互僵持一个都走不了（死锁发生条件4：环路等待条件），而且导致整条道上的后续车辆也走不了。

活锁：马路中间有条小桥，只能容纳一辆车经过，桥两头开来两辆车A和B，A比较礼貌，示意B先过，B也比较礼貌，示意A先过，结果两人一直谦让谁也过不去。

### 饥饿(starvation)是什么

饥饿是指某进程因为优先级的关系一直得不到CPU的调度，可能永远处于等待/就绪状态

### 简单说说Windows消息机制

当用户有操作(鼠标，键盘等)时，系统会将这些时间转化为消息。

每个打开的进程系统都为其维护了一个消息队列，系统会将这些消息放到进程的消息队列中，而应用程序会循环从消息队列中取出来消息，完成对应的操作。

## 网络编程

### 并发(concurrency)与并行(parallelism)的区别

并发：指宏观上看起来两个程序在同时运行，比如说在单核cpu上的多任务。但是从微观上看两个程序的指令是交织着运行的，在单个周期内只运行了一个指令

并行：指严格物理意义上的同时运行，比如多核cpu，两个程序分别运行在两个核上，两者之间互不影响，单个周期内每个程序都运行了自己的指令，也就是运行了两条指令。并行的确提高了计算机的效率。所以现在的cpu都是往多核方面发展。

### 同步和异步以及阻塞和非阻塞

要了解各种并发模型思想，首先要了解什么是同步，什么是异步？什么是阻塞，什么是非阻塞？

举一个例子来说明上面的概念，小明去买自己爱吃的烧鸡

- 同步阻塞的做法是小明付帐后一直盯着老板制作烧鸡，直到完成才高兴的办其它事了。
- 同步非阻塞的做法是小明付帐后不会一直盯着老板，而是做其它事了，每隔一会来看看老板做好了没。
- 异步阻塞的做法是小明付帐以后，不会盯着老板做了，也不干其它事，老板做好了通知小明。
- 异步非阻塞指的是小明付帐以后，干自己的事去了，老板做好了通知小明。

同步和异步的本质是我轮询你还是你回调我；阻塞和非阻塞的本质是当发生等待的时候我能不能干其它的事

### 可重入函数是什么意思

如果一个函数能被多个线程同时调用且不发生竞态条件，则我们称它是**线程安全的（thread safe）**，或者说它是可重入函数。Linux库函数只有一小部分是不可重入的，也提供了对应的可重入版本（函数名加上_r后缀），在多线程环境下一定要用可重入版本

### 如何采用单线程的方式处理高并发

可以采用I/O复用来提高单线程处理多个请求的能力，然后再采用事件驱动模型，基于异步回调来处理事件

### 字节序

- 大端字节序（将高序字节存储在起始地址）：网络字节序都是大端的

- 小端字节序（将低序字节存储在起始地址）：大部分PC

本机用大端还是小端可以用union判断

### socket开发基本步骤

基于TCP

- 服务器端：创建socket()---绑定IP地址、端口等信息bind()---设置允许的最大连接数listen()---接受来自于客户端的连接accept()
- 客户端：创建socket()---设置IP地址、端口等信息连接服务器connect()
- 收发数据，用函数send()和recv()，或者read()和write()

基于UDP

- 服务器端：生成套接字描述符函数socket()---设置服务器地址和监听端口bind()---接收客户端的数据recvfrom()---向客户端发数据sendto()
- 客户端：socket()---sendto()---recvfrom()---close()

### Unix五种I/O模型

[IO模型浅析-阻塞、非阻塞、IO复用、信号驱动、异步IO、同步IO](https://segmentfault.com/a/1190000016359495)

1. 阻塞式I/O模型：最流行，默认情况下套接字都是该模型
2. 非阻塞式I/O模型：通知内核，轮询，耗费大量CPU时间，一般是专门提供某一种功能的系统才用
3. I/O复用（select、poll、epoll）：进程阻塞在select系统调用上，直到数据可读，系统调用recvfrom，优势在于等待多个描述符就绪
4. 信号驱动I/O模型：在描述符就绪时发送SIGIO信号通知我们，该模型优势是在等待数据报到达期间进程不阻塞
5. 异步I/O模型：POSIX规范定义的。告知内核启动某操作，并让内核在整个操作（包括数据从内核复制到进程缓冲区）完成才通知我们。

异步I/O模型与信号驱动I/O主要区别是：前者是内核通知我们何时启动一个I/O操作，而后者是由内核通知何时I/O操作完成，信号在操作完成才产生。

前四种都是同步的，因为真正的I/O操作会阻塞进程；第五种是异步的。

### Reactor模型与Proactor模型

网络框架大多数都是基于Reactor模式进行设计和开发，Reactor模式基于**事件驱动**，特别适合处理海量的I/O事件

- Reactor模型要求**主线程只负责监听**文件描述符上是否有事件发生，有的话就立即将该事件通知工作线程，除此之外，主线程不做任何其他实质性的工作，读写数据、接受新的连接以及处理客户请求均在工作线程中完成。

- Proactor模式将**所有I/O操作都交给主线程和内核来处理**，工作线程仅仅负责业务逻辑。

### Muduo的多线程模型是怎么样的

multiple reactors + thread pool

- 这种方案的特点是**one loop per thread**，有一个main Reactor负责accept(2)连接，然后把连接挂在某个sub Reactor中（muduo采用round-robin的方式来选择sub Reactor），**这样该连接的所有操作都在那个sub Reactor所处的线程中完成**。多个连接可能被分派到多个线程中，以充分利用CPU。
- muduo采用的是**固定大小的Reactor pool**，池子的大小通常根据CPU数目确定

[MultipleReactors](https://raw.githubusercontent.com/wu0hgl/note_pic/master/%E7%BD%91%E7%BB%9CIO_multiple_reactors_thread_pool_pre.png)

### shutdown函数是干什么的

两个作用：**忽略引用计数**、**按需关闭**

我们一般用close函数关闭socket。不过，close函数并非总是立即关闭一个连接，而是将fd的**引用计数**减1。只有当fd的引用计数为0时，才真正关闭连接。多进程程序中，一次fork系统调用默认将使父进程中打开的socket的引用计数加1，因此我们必须在父进程和子进程中都对该socket执行close调用才能将连接关闭。

如果想不管引用计数就完全关闭socket，可以使用如下的shutdown函数：

```c++
int shutdown(int sockfd,int howto);
```

sockfd参数是待关闭的socket。howto参数决定了shutdown的行为

- SHUT_RD：关闭本机对于该套接字描述符的读，接收缓冲区的数据都被丢弃
- SHUT_WR：关闭本机对于该套接字描述符的写，发送缓冲区的数据会在真正关闭前发送出去。此时处于**半关闭状态（half-close）**
- SHUT_RDWR：同时关闭本机对于该套接字描述符的读和写

### IO多路复用

IO多路复用可以用来监听多种描述符，如果任一描述符出于就绪状态，它就通知对应进程，然后采取下一步操作

优点：无需开启线程，减少系统开销，比多线程要好很多

Linux中主要有三个API：select、poll、epll

### select原理

select函数返回产生事件的描述符的数量，如果为-1表示产生错误

其中有一个很重要的结构体fd_set，表示描述符的集合，可以将fa_set看作类似操作系统中的位图，其中每个整数的每一bit代表一个描述符

select 函数监视的文件描述符分3类，分别是writefds、readfds、和exceptfds。调用后select函数会阻塞，直到有描述符就绪（有数据可读、可写、或者有except），或者超时（timeout指定等待时间，如果立即返回设为null即可），函数返回。当select函数返回后，可以通过遍历fdset，来找到就绪的描述符，所以**内核会修改fdset，监听和返回集合是同一个**

对socket进行扫描时是**线性扫描**，即采用**轮询**的方法，效率较低

### poll原理

poll本质上和select没有区别，**每次都会把用户传入的数组拷贝到内核空间**，然后查询每个fd对应的设备状态，如果设备就绪则在设备等待队列中加入一项并继续遍历，如果遍历完所有fd后没有发现就绪设备，则挂起当前进程，直到设备就绪或者主动超时，被唤醒后它又要再次遍历fd。这个过程经历了多次无谓的遍历。

与select的最大区别，监听和返回集合分离，这样不用调用完后不用再

优点：没有最大连接数的限制，因为它是基于**链表**存储的

### epoll原理

epoll将感兴趣的事件**注册到内核的一个事件表**中，当某个fd上事件就绪时，通过**回调函数**在在epoll_wait中返回对应的结构体

调用顺序：

```c++
int epoll_create(int size);
int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
int epoll_wait(int epfd, struct epoll_event *events,int maxevents, int timeout);
```

Linux epoll机制是通过**红黑树和双向链表**实现的。

- epoll_create用来创建红黑树来存储socket，还会建立一个双向链表，用来存储就绪的事件
- epoll_ctl在红黑树添加、修改、删除socket，非常快速
- epoll_wait只需要检查list即可

优点：

1. 没有最大并发连接的限制（仅取决于OS的fd数量限制）
2. 效率提升，**不是轮询，而是回调**，不会随着FD数目的增加效率下降；
3. 用红黑树，插入修改删除事件很方便
4. 共享内存（mmap），不像select与poll需要往内核拷贝

### select，poll，epoll比较

- 事件
  - select使用的是fd_set，它没有将fd与事件绑定，所以需要提供三个fd_set（可读、可写、异常）来传入特定事件。而且内核会修改fd_set，所以下次使用时需要**重置**。
  - poll使用的是poll_fd，把**fd与事件绑定**在一起，比select更简洁，监听事件通过events注册，就绪事件通过revents返回，**两者分离**，内核不会修改events，无须重置。
  - epoll在内核**维护了一个事件表**，独立的函数epoll_ctnl往里面增加、修改、删除事件，这样每次epoll_wait调用都可以直接从内核中获得具体事件。

- 数量
  - select有最大数量的限制，一般较小
  - poll、epoll_wait能监听的最大fd数量取决于OS，一般很大，如65535

- 工作模式
  - select、poll只能在LT
  - epoll还能ET，并且支持oneshot

- 时间复杂度
  - select、poll用的是**轮询**，每次调用要扫描整个注册fd集合，返回其中就绪的fd。所以，**索引就绪fd需要O(n)**
  - epoll_wait则不同，采用的是**回调**，直接将就绪事件拷贝到用户控件，**索引就绪fd只需要O(1)**

### epoll的LT和ET模式（非常重要，笔记已结合网上资料）

epoll对文件描述符的操作有两种模式，根据数字电子电路的电平触发与边沿触发区分：

- LT（Level Trigger，电平触发）：**默认模式**，符合select/poll的习惯，不易出错，但可能效率较低（busy-loop）
  - socket接收缓冲区不为空，有数据可读，读事件**一直触发**
  - socket发送缓冲区不， 可以继续写入数据，写事件**一直触发**
  - **状态满足就一直触发**

- ET（Edge Trigger，边沿触发）：更简洁，某些场景下更高效，但**容易遗漏事件（需要一直读写）**，当往epoll内核事件表中注册一个文件描述符上的**EPOLLET事件**时，转为ET
  - socket的接收缓冲区状态变化时触发读事件，即空的接收缓冲区刚接收到数据时触发读事件
  - socket的发送缓冲区状态变化时触发写事件，即满的缓冲区刚空出空间时触发读事件
  - **仅在状态变化时触发事件**

### 线程池怎么实现/线程池的大小一般怎么设置

1. 设置一个**生产者消费者队列**, 作为临界资源
2. 开启n个线程, 加锁去队列取任务运行
3. 当任务队列为空的时候, 所有线程阻塞
4. 当生产者队列来了一个任务后, 先对队列加锁, 把任务挂在到队列上, 然后使用条件变量去通知阻塞中的一个线程

线程池大小的经验公式T=C/P，C是CPU数量，P是密集计算时间占（密集计算时间+IO时间）的估计比例

- 假设C=8, P=1.0, 线程池的任务完全密集计算, 只要8个活动线程就能让cpu饱和
- 假设C=8, P=0.5, 线程池的任务有一半是计算, 一半是IO, 那么T=16, 也就是16个"50%繁忙的线程能让8个cpu忙个不停"

### 死循环+来连接时新建线程的方法效率有点低，怎么改进

提前创建好一个**线程池**，用**生产者消费者模型**，创建一个**任务队列**，队列作为临界资源，有了新连接，就挂在到任务队列上，队列为空所有线程睡眠，队列不为空就唤醒线程池中的线程去处理。

改进死循环：使用I/O复用，select/poll/epoll

### 惊群问题

当多个进程和线程在同时阻塞等待同一个事件时，如果这个事件发生，**会唤醒所有的进程**，但**最终只可能有一个进程/线程对该事件进行处理**，其他进程/线程会在失败后重新休眠，这种性能浪费就是惊群。

Linux内核已经解决accept的惊群问题，交给休眠队列的第一个线程

epoll_wait部分解决惊群问题，因为epoll_wait监听的事件可能就是要被几个线程处理的

解决办法：互斥锁（如Nginx）

### 无锁队列怎么实现

[无锁队列的实现by陈皓](https://coolshell.cn/articles/8239.html)

主要用到了**CAS（compare&swap）**原子操作，汇编指令是CMPXCHG，大部分编译器都支持，C++11还有atomic类函数，CAS用C语言描述如下：

```c++
bool compare_and_swap (int *addr, int oldval, int newval)
{
  if ( *addr != oldval ) {
      return false;
  }
  *addr = newval;
  return true;
}
```

所以就可以实现无锁队列，下面的实现几乎就是Java中的ConcurrentLinkedQueue（甚至还更好一点by陈皓）

```c++
EnQueue(Q, data) //进队列改良版 v2
{
    n = new node();
    n->value = data;
    n->next = NULL;

    while(TRUE) {
        //先取一下尾指针和尾指针的next
        tail = Q->tail;
        next = tail->next;

        //如果尾指针已经被移动了，则重新开始
        if ( tail != Q->tail ) continue;

        //如果尾指针的 next 不为NULL，则 fetch 全局尾指针到next
        if ( next != NULL ) {
            CAS(Q->tail, tail, next);
            continue;
        }

        //如果加入结点成功，则退出
        if ( CAS(tail->next, next, n) == TRUE ) break;
    }
    CAS(Q->tail, tail, n); //置尾结点
}
DeQueue(Q) //出队列，改进版
{
    while(TRUE) {
        //取出头指针，尾指针，和第一个元素的指针
        head = Q->head;
        tail = Q->tail;
        next = head->next;

        // Q->head 指针已移动，重新取 head指针
        if ( head != Q->head ) continue;

        // 如果是空队列
        if ( head == tail && next == NULL ) {
            return ERR_EMPTY_QUEUE;
        }

        //如果 tail 指针落后了
        if ( head == tail && next == NULL ) {
            CAS(Q->tail, tail, next);
            continue;
        }

        //移动 head 指针成功后，取出数据
        if ( CAS( Q->head, head, next) == TRUE){
            value = next->value;
            break;
        }
    }
    free(head); //释放老的dummy结点
    return value;
}
```

解决ABA问题，可以用版本号（或者叫引用计数）

## 计算机网络

### OSI有几层协议，TCP/IP有几层协议

OSI具有七层协议，但复杂且不实用，从上到下分别是：应用层、表示层、会话层、运输层、网络层、数据链路层、物理层

TCP/IP具有四层协议，广泛应用，从上到下分别是：应用层，运输层，网络层，网络接口层

谢希仁的《计算机网络》为了把概念解释清楚，把计算机网络分为：应用层（FTP,HTTP,DNS），运输层(TCP,UDP)，网络层(IP,ARP,ICMP)，数据链路层(MAC,VLAN,PPP)，物理层(IEEE802.3)

### TCP和UDP的区别和各自适用的场景

1. 连接：TCP是面向连接的，即传输数据之前必须先建立好连接；UDP无连接
2. 服务对象：TCP是点对点的两点间服务，即一条TCP连接只能有两个端点；UDP支持一对一，一对多，多对一，多对多的交互通信
3. 可靠性：TCP是可靠交付：无差错，不丢失，不重复，按序到达；UDP是尽最大努力交付，不保证可靠交付。
4. 拥塞控制：TCP有慢开始、拥塞避免、快重传和快恢复；UDP没有拥塞控制，网络拥塞不会影响源主机的发送速率
5. 首部开销：TCP首部开销20字节；UDP首部开销8字节

看重数据完整性选择TCP，看重通信实时性选择UDP

### TCP与UDP能否访问同一个端口及原因

可以，因为当主机收到一个以太网帧时，从协议栈自底向上解析，每层都会检查首部的协议标识，这就是**分用（Demultiplexing）**，所以即使端口相同，但是TCP与UDP是独立的

### TCP怎么保证可靠性

1. 序列号、确认应答、超时重传
2. 滑动窗口控制、重复确认应答
3. 拥塞控制：前期是慢开始+拥塞避免（加法增大）+拥塞时门限减半（乘法减小），后期加入了快重传（连续收到三个重复确认就重传）+快恢复（收到三个重复确认时拥塞窗口减半并进入拥塞避免阶段），在采用快恢复算法时，慢开始算法只在TCP连接建立时和网络超时时才使用到

### UDP如何实现可靠传输

模仿TCP即可

- 超时重传：加发送缓冲区与定时器
- 应答确认：Seq/Ack
- 滑动窗口

比如UDT，完全基于UDP，它解决了TCP在**高带宽长距离**网络上性能很差的问题

### TCP三次握手与四次挥手

![C++查漏补缺-20200111170149.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/C%2B%2B%E6%9F%A5%E6%BC%8F%E8%A1%A5%E7%BC%BA-20200111170149.png)

#### 三次握手

B的TCP服务器进程先创建传输控制块TCB，准备接受客户进程的连接请求。然后服务器进程就处于LISTEN状态，等待客户的连接请求。

1. A首先创建传输控制块TCB，然后向B发出连接请求报文段，SYN=1，初始序号seq=x（随机，SYN=1的报文段不能携带数据，但要消耗掉一个序号），此时TCP客户进程进入**SYN-SENT**状态

2. B收到连接请求报文段后，如同意建立连接，则向A发送确认，SYN=1，ACK=1，确认号ack=x+1，初始序号seq=y（随机，SYN=1的报文段不能携带数据，但要消耗掉一个序号），TCP服务器进程进入**SYN-RCVD**状态

3. A收到B的确认后，要向B给出确认报文段，ACK=1，确认号ack=y+1，seq=x+1（初始为seq=x，第二个报文段所以要+1），ACK报文段可以携带数据，不携带数据则不消耗序号。TCP连接已经建立，A进入**ESTABLISHED**，B收到后也进入**ESTABLISHED**状态

-----------数据传输阶段----------

![C++查漏补缺-20200111170205.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/C%2B%2B%E6%9F%A5%E6%BC%8F%E8%A1%A5%E7%BC%BA-20200111170205.png)

#### 四次挥手

由于TCP连接时全双工的，因此，每个方向都必须要单独进行关闭，这一原则是当一方完成数据发送任务后，发送一个FIN来终止这���方向的连接，但是另一方扔仍然能够发送数据，直到另一方向也发送了FIN。首先进行关闭的一方将执行主动关闭，而另一方则执行被动关闭。

1. A发出连接释放报文段，FIN=1，序号seq=u（之前最后一次传送的序号加1），并停止再发送数据，主动关闭TCP连接，进入**FIN-WAIT-1**状态，等待B的确认。

2. B收到连接释放报文段后即发出确认报文段，ACK=1，确认号ack=u+1，序号seq=v（之前最后一次传送的序号加1），B进入**CLOSE-WAIT**状态，此时的TCP处于半关闭状态，A到B的这个方向的连接已释放。A收到确认报文段后进入**FIN-WAIT2**状态

    -----------可能这时Server还有数据要发送给Client-----------------

3. B没有要向A发出的数据，B发出连接释放报文段，FIN=1，ACK=1，序号seq=w（之前最后一次传送的序号加1），确认号ack=u+1，B进入**LAST-ACK**（最后确认）状态，等待A的确认。

4. A收到B的连接释放报文段后，对此发出确认报文段，ACK=1，seq=u+1，ack=w+1，A进入**TIME-WAIT**（时间等待）状态。此时TCP未释放掉，需要经过时间等待计时器设置的时间2*MSL（最长报文段寿命）后，A才进入**CLOSED**状态。B在收到确认报文段后就进入了**CLOSED**状态。

#### 三次握手为什么两次不可以，为什么四次没必要

因为有可能Client的第一个SYN报文段长时间滞留在网络中，Client一直等不到回应就释放了连接，但Server收到这个滞后的SYN报文段会向Client发送确认，并且同意建立连接，Client此时已经释放连接了，对Server的连接确认不予理睬，于是Server空空等待Client发来数据，浪费资源！

第三次握手就可以携带客户端的数据了，所以不需要四次

#### 为什么A在TIME-WAIT状态必须等待2*MSL时间

1. 第四次挥手的ACK报文可能丢失，B如没有收到ACK报文，则会不断重复发送FIN报文，所以A不能立即关闭，必须确认B收到了ACK，`2*MSL`正好是一个发送和一个回复的最大时间，如果A直到`2*MSL`还没收到B的重复FIN报文，则说明第四次挥手的ACK已经成功接收，于是可以放心的关闭TCP连接了。
2. 第四次挥手的ACK报文之后，再经过2*MSL的时间，就是本次连接持续时间内产生的所有报文都从网络中消失，这样下一个新的TCP连接就不会出现旧的连接请求报文了。

#### 为什么连接的时候是三次握手，关闭的时候却是四次握手

因为当Server端收到Client端的SYN连接请求报文后，可以直接发送SYN+ACK报文。其中ACK报文是用来应答的，SYN报文是用来同步的。但是关闭连接时，当Server端收到FIN报文时，很可能并不会立即关闭SOCKET，所以只能先回复一个ACK报文，告诉Client端，"你发的FIN报文我收到了"。只有等到我Server端所有的报文都发送完了，我才能发送FIN报文，因此不能一起发送。故需要四步握手。

争论：我在晚上查阅了很多资料（知乎、stackoverflow、大学课件、论文插图，很多地方说可以把四次握手的中间两次合二为一，即server端发送的是FIN+ACK，也有人通过抓包证明了这一结论。

#### time_wait状态太多如何处理

1. 开启tcp_timestamps：在TCP可选选项(option)字段内记录最后一次发送时间和最后一次接收时间（这是time_wait重用和快速回收的保证），`net.ipv4.tcp_timestamps = 1`
2. 开启time_wait重用：因为time_wait是主动关闭方的状态，当发送方又有新的TCP连接想要发起时，可以直接**重用正在time_wait状态的TCP连接**，接收端收到数据报，可以**通过timestamp字段判断属于复用前的连接还是复用后的连接**，`net.ipv4.tcp_tw_reuse = 1`
3. 开启time_wait快速回收：不再等待2MSL，而是RTO（远小于2MSL），`net.ipv4.tcp_tw_recycle = 1`

简单来说，就是打开系统的**time_wait重用和快速回收**。

### TCP初始序列号ISN为什么是随机的，怎么随机

1. 如果不是随机产生初始序列号，黑客将会以很容易的方式获取到你与其他主机之间通信的初始化序列号，并且**伪造序列号进行攻击**
2. 在网络不好的场景中，TCP连接可能不停地断开，若用固定ISN，很可能新连接建立后，之前在网络中延迟的数据报才到达，这就**乱套**了
3. 不同OS的ISN生成算法不一样，就是随机数生成算法，比如RFC文档推荐：`ISN = M + F(localhost, localport, remotehost, remoteport)`，M是个计时器，F是个哈希算法，一般用MD5比较安全

### TCP的4种定时器(Timer)

1. 重传计时器(Retransmission Timer)：在2*RTT时间内收不到确认则重传
2. 坚持计时器(Persistent Timer)：专门为对付零窗口通知而设立的。
3. 保活计时器(Keeplive Timer)：每当服务器收到客户的信息，就将keeplive timer复位，若超时（一般设为2h）则发送10个探测报文段，若还没响应则关闭连接
4. 时间等待计时器(Time_Wait Timer)：TCP关闭连接时使用，2*MSL

### 数据包/报文段大小

- UDP报文段：首部固定8字节+数据部分
- TCP报文段：首部固定20字节+首部可变部分字节+数据部分
- IP数据包：首部固定20字节+首部可变部分字节+数据部分（可能是一个完整UDP/TCP报文段）

### MTU/MSS/分片

MTU是Maximum Transimission Unit，是数据链路层对于数据帧的限制，所以IP层会根据MTU来进行分片，局域网一般是1500字节，因特网一般是576字节

MSS是Maximum Segment Size，是TCP对于段的限制，TCP报文段长度大于MSS时要分段传输，MSS值一般在双方建立连接时协商，双方发送SYN报文的同时会把期望接收的MSS，所以一般`MSS=MTU-IP首部-TCP首部`，对于局域网`1500-20-20=1460字节`，对于因特网`576-20-20=536字节`

结论：TCP会避免在IP层分片（为了减少分片包丢失重传的影响），于是在传输层根据MSS分片。UDP没有TCP的MSS，所以UDP报文段在IP层可能会根据MSS分片！

### 粘包是什么/如何解决粘包问题

[TCP新手误区--粘包的处理](https://blog.csdn.net/bjrxyz/article/details/73351248)

UDP不会出现粘包，因为它有消息边界，发送端每发一个数据报接收端就要收一个数据报。

而TCP是基于字节流的传输，从缓冲区看，发送端发送次数与接收端接收次数不一致（因为socket缓存或MTU分包），接收端分不清这几个包是粘在一起的（接收端可以一次性全读完，也可以分多次读取）。所以会造成粘包。

“在TCP这种字节流协议上做**应用层分包**是网络编程的**基本需求**。分包指的是在发生一个消息（message）或一帧（frame）数据时，通过一定的处理，让接收方能从字节流中识别并截取（还原）出一个个消息。“粘包问题”是个伪问题。”
摘录来自: 陈硕. “Linux多线程服务端编程:使用muduo C++网络库。”

建立短连接（如daytime服务器）是没有粘包问题的，对于长连接有以下解决方法：

1. 发送固定长度的消息
2. 在消息的头部加一个长度字段，与消息一块发送（最常见的做法）
3. 使用特殊标记来区分消息间隔，比如HTTP协议的heads以"\r\n"为字段的分隔符

### TCP心跳是什么/TCP连接建立后一方断电对方能收到通知吗

问：TCP连接建立后一方断电对方能收到通知吗

答：**不会**

TCP连接是虚拟的连接，**不是实际的电路**，双方只是保存着关于这个连接的状态，如套接字描述符。所以，**不发送数据是不会断开连接的**

解决办法很简单，就是用心跳机制，每隔一段时间向对方发送探测报文

1. TCP本身就有keep alive套接字选项
2. 应用层还应该设计心跳机制，还可以携带一些数据，当然开销比TCP心跳大

### TCP如何保证数据的正确性

大部分人就会开始说丢包重传、接收确认之类的东西，但这些都扯偏了，只要少数人能够正确回答题目要问的问题:**首部校验**。

对于能答上这个问题的人，我会进一步问，这个校验机制能够确保数据传输不会出错吗？

答案：**不能**

TCP的首部字段中有一个字段是校验和，发送方将伪首部、TCP首部、TCP数据使用累加和校验的方式计算出一个数字，然后存放在首部的校验和字段里，接收者收到TCP包后重复这个过程，然后将计算出的校验和和接收到的首部中的校验和比较，如果不一致则说明数据在传输过程中出错。可以想到，万一有两个首尾两个bit翻转了，这是错误信息，但是没法检测出来

最好是在应用层重新建立一套数据校验机制，如MD5校验

### 流量控制是什么/滑动窗口是什么/窗口过大或者过小有什么不好

流量控制只涉及发送端和接收端（拥塞控制是全局链路），防止发送方发的太快，而接收方来不及处理

TCP滑动窗口基于**确认应答**，可以提供**可靠性**以及**流控特性**，体现了**面向字节流**

TCP的发送缓冲区的数据包括

1. 已经发送并且已经ACK的
2. 已经发送但没ACK的（包含于发送窗口
3. 未发送但对端允许发送（包含于发送窗口
4. 未发送且对端不允许发送

TCP是全双工协议，双方都有发送窗口和接收窗口，接收窗口取决于系统，发送窗口取决于对端通告的接收窗口

发送窗口只有在收到对端对于本端发送窗口内字节的ACK确认，才会往前移动（这就是滑动的意思），接收窗口只有在前面的数据都收到的情况下才会往前移动。

- 窗口太大：发送的数据太多，产生网络拥塞，所以需要拥塞控制
- 窗口太小：糊涂窗口综合征，每次只发送一字节，只确认一字节，效率非常低

### 糊涂窗口综合征/Nagle算法/TCP_NODELAY套接字选项

Nagle算法的目的在于减少广域网（WAN）上小分组的数目（即**糊涂窗口综合征**）。规则如下：

1. 如果长度达到MSS，则允许发送
2. 包含FIN，则允许发送
3. 设置了TCP_NODELAY套接字选项，则允许发送
4. 超时，则允许发送

TCP_NODELAY选项可以禁止Nagle算法，减少时延

### TCP拥塞控制

拥塞控制是防止过多的数据注入网络，使得网络中的路由器或者链路过载。流量控制是点对点的通信量控制，而拥塞控制是全局的网络流量整体性的控制。发送双方都有一个拥塞窗口——cwnd。

1. 慢开始：最开始发送方的拥塞窗口为1，每经过一个传输伦次，cwnd加倍，当cwnd超过慢开始门限ssthresh，进入拥塞避免
2. 拥塞避免：每经过一个传输伦次，cwnd加1。一旦发现网络拥塞（超时），就把ssthresh降为原来的一半，从cwnd=1开始慢开始（加法增大乘法减小,AIMD）
3. 快重传：接收方每次收到一个失序的报文就立即发送重复确认，发送方收到三个重复确认就立即重传（不用考虑重传计时器，所以是快重传）
4. 快恢复：与快重传配合，发送方收到三个重复确认后，就把ssthresh降为原来的一半，从cwnd=新ssthresh开始拥塞避免（不用慢开始，所以是快恢复），采用快恢复算法时，慢开始只在建立连接和网络超时才使用。

### HTTP代理服务器的分类与工作原理

在HTTP通信链上，客户端和目标服务器之间通常存在某些中转代理服务器，它们提供对目标资源的**中转访问**。一个HTTP请求可能被多个代理服务器转发，后面的服务器称为前面服务器的上游服务器。代理服务器按照其使用方式和作用，分为正向代理服务器、反向代理服务器和透明代理服务器。

- **正向代理要求客户端自己设置代理服务器的地址**。客户的每次请求都将直接发送到该代理服务器，并由代理服务器来请求目标资源。比如处于防火墙内的局域网机器要访问Internet，或者要访问一些被屏蔽掉的国外网站，就需要使用正向代理服务器。例如shadowsocks

- **反向代理则被设置在服务器端**，因而客户端无须进行任何设置。反向代理是指用代理服务器来接收Internet上的连接请求，然后将请求转发给内部网络上的服务器，并将从内部服务器上得到的结果返回给客户端。这种情况下，代理服务器对外就表现为一个真实的服务器。各大网站一般设了多个代理服务器。

- 透明代理只能设置在网关上。用户访问Internet的数据报必然都经过网关，如果在网关上设置代理，则该代理对用户来说显然是透明的。透明代理可以看作正向代理的一种特殊情况。

### HTTP长连接与短连接的区别

短连接：即浏览器和服务器每进行一次HTTP操作，就会建立一次连接，任务结束就断开连接。通常用于大型网站的访问。

长连接：用以保持连接特性（加上keep-alive）。使用长连接的情况下，当某个网页打开完毕之后，客户端和服务器之间的TCP连接不会立即关闭，如果客户端再次访问该服务器上的网页，会使用上一次已经建立的连接。长连接不是永久保持连接，它有一个保持时间。实现长连接的前提是客户端和服务器端都需要支持长连接。通常用于**操作频繁**，点对点的通信，且**连接数不太多**的情况。如数据库的连接使用长连接

### HTTPS、SSL/TLS握手过程

HTTPS = HTTP over TLS

1. HTTP协议是以明文的方式在网络中传输数据，而HTTPS协议传输的数据则是经过**TLS加密**后的，HTTPS具有更高的安全性
2. HTTPS在TCP三次握手阶段之后，还需要进行**TLS**的handshake，协商加密使用的对称加密密钥
3. HTTPS协议需要服务端申请**证书**，浏览器端**安装**对应的根证书
4. HTTP协议端口是80，HTTPS协议端口是443

HTTPS缺点：

1. 握手时延增加：TLS握手才能HTTP会话
2. 部署成本高：需要购买CA证书；加解密计算消耗资源

TLS（Transportation Layer Security，安全传输层）的**前身**是SSl（Secure Socket Layer，安全套接层）

TLS握手过程

1. client发送hello，包括TLS版本号、client产生的随机数random1、加密方法（如RSA公钥加密）
2. server发送hello，包括TLS版本号、server产生的随机数random2、certificate（证书）、确认的加密方法（如RSA公钥加密）
3. client验证证书是否合法，然后计算**pre-master secret（预主秘钥）**，通过公钥加密后发送
4. server通过私钥解密预主秘钥，然后根据random1、random2以及预主秘钥计算生成本次会话用的“会话秘钥”
5. 至此，client和server都知道了会话秘钥，可以安全的通信了

为什么需要三次：不信任每个主机都能产生随机数，如果随机数不随机，预主秘钥就有可能被猜出，所以三个随机数一起计算，更随机

### HTTP1.0、HTTP1.1、HTTP2.0、HTTP3

1. 缓存处理更多
2. 减少带宽
3. 关于错误的状态码更多
4. 支持长连接，keep-alive

HTTP2.0做了更多的改进

1. 二进制格式：方便、健壮
2. **完全多路复用**：不是有序并阻塞的，基于**流（stream）**，能够将多条请求在同一条TCP连接上同时发送
3. **header压缩**：因为HTTP协议无状态，header的很多字段重复发送了，HTTP2.0使用头信息压缩机制来减少传输的header的大小，双方各自cache一份header
4. 服务器端推送

HTTP3使用的是Quic协议，而非TCP协议

### 扩展：Quic与BBR（都是Google提出的）

Quic（Quick UDP Internet Connection）是基于UDP实现的支持**多路并发传输**的协议，Quic相比于广泛应用HTTP2+TCP+TLS有以下优势：

1. 减少TCP三次握手与TLS握手时间
2. 改善了拥塞控制：**可插拔**，在应用程序层面就能实现不同的拥塞控制算法，不需要操作系统支持
3. 避免队头阻塞的多路复用：stream之间独立
4. 连接迁移：不再以`(源IP、源端口、目的IP、目的端口)`的四元组唯一表示一条TCP连接，因为客户端的IP可能会变化（WiFi到4G），而是用一个由客户端生成的64位随机数来标识
5. 前向冗余纠错

BBR是拥塞控制算法，已在Linux内核中支持

- 在有一定丢包率的网络链路上充分利用带宽。
- 降低网络链路上的 buffer 占用率，从而降低延迟。
- 以前的拥塞控制算法（Reno、Cubic等）都是以**丢包**作为拥塞发生的信号，而BBR以**网络中包数>带宽时延积**作为拥塞发生的信号

### 说一说HTTP状态码

HTTP协议的响应报文由状态行、响应头和响应体组成，其响应状态码总体描述如下：

1. 1xx：指示信息--表示请求已接收，继续处理。
2. 2xx：成功--表示请求已被成功接收、理解、接受。
    - 200 OK：客户端请求成功。
    - 204 No Content：表示请求已成功处理，但是没有内容返回
3. 3xx：重定向--要完成请求必须进行更进一步的操作。
    - 301 Moved Permanently：永久重定向，表示请求的资源已经永久的搬到了其他位置
4. 4xx：客户端错误--请求有语法错误或请求无法实现。
    - 400 Bad Request ：请求报文中存在语法错误，服务器不理解
    - 401 Unauthorized：发送的请求需要有HTTP认证信息或者是认证失败了
    - 403 Forbidden：服务器收到请求，但是拒绝提供服务。
    - 404 not Found：请求资源不存在
5. 5xx：服务器端错误--服务器未能实现合法的请求。
    - 500 Inter Server Error：服务器在执行请求时发生了错误，可能是服务器有bug
    - 503 Server Unavailable：服务器暂时处于超负载或正在进行停机维护，无法处理请求；

### Session与Cookie的比较

- Session在**服务器端保**存用户信息，保存的是**对象**，随会话结束而关闭，可保存重要信息。
- Cookie在**客户端保**存用户信息，保存的是**字符串**，可长期保存在客户端，保存不重要信息。
- 典型例子：Cookie记住了用户名和密码，在网站中跳来跳去需要用Session保存用户信息。

### GET与POST

- GET：读取，不修改，幂等，通过URL传递参数/query string（但也看到有人通过请求体传递参数，不建议这么做），GET提交的数据大小受限于URL，而HTTP并没有对URL长度进行规定，这要看浏览器与操作系统的支持。
- POST：表单提交，可修改，不幂等，请求数据放入请求体里（但URL也可以带参数）。HTTP也没有对POST进行大小限制，这要看服务器处理程序的限制。
- 一般来说，POST比GET相对安全。GET在URL明文传输，这个角度来看更容易引起不怀好意的人的注意。POST在地址栏不可见，相对安全。从HTTP协议的定义中，GET是幂等的，POST不是幂等，所以GET是安全方法。
- 但是因为HTTP本身是明文协议，从这个角度来说GET/POST都不安全，所以推荐使用HTTPS——SSL加密明文的HTTP。

### 从输入网址到显示网页的全过程分析

1. 键盘是I/O设备，产生**I/O中断**，CPU执行中断处理，数据缓冲区读入数据至通用寄存器，再到内存，再输出到屏幕(I/O设备)的浏览器地址栏中
2. 浏览器线解析URL得到域名，通过域名找IP地址，这需要域名解析系统**DNS**，DNS是基于UDP的，首先会查浏览器的DNS缓存，然后查本机的DNS缓存(hosts文件），再然后查ISP域名服务器，这里的查询方式分为**迭代查询**和**递归查询**，迭代：ISP域名服务器--根域名服务器--ISP域名服务器--顶级域名服务器--权限域名服务器，递归：ISP域名服务器--根域名服务器--顶级域名服务器--权限域名服务器
3. 本机（客户端）得到IP后，向IP所在的HTTP服务器发起TCP连接（TCP三次握手），然后生成一个**GET请求报文**，交给TCP层处理，如果是HTTPS还需要**TLS加密**，传输层可能对报文**分片**，然后到达IP层，数据链路层和物理层
4. 通过网络中的路由器，牵涉到OSPF、BGP协议等等，最终IP数据包到达服务器，服务器重组数据包，恢复成原GET请求报文
5. 服务器收到GET请求，把本地的HTML返回给客户端
6. 客户端的浏览器得到HTML文档，**解析**CSS、Javascript文件，**渲染**在浏览器上
7. 连接断开，TCP四次挥手

## 数据库

### 局部性原理

计算机科学中著名的局部性原理: 当一个数据被用到时, 其附近的数据也通常会马上被使用。

程序运行期间所需要的数据通常比较集中。由于磁盘顺序读取的效率很高(不需要寻道时间, 只需很少的旋转时间），因此对于具有局部性的程序来说, 预读可以提高I/O效率。

而类似于B+树这样的结构，可以明显减少磁盘IO，一次读一块区域的内容，所以一般用B+树作为数据库索引

### 三范式

- 第一范式（1NF）：列的原子性，列不能再分成其他几列

    考虑这样一个表：`【联系人】（姓名, 性别, 电话）`。如果在实际场景中, 一个联系人有家庭电话和公司电话, 那么这种表结构设计就没有达到 1NF。要符合 1NF 我们只需把列(电话)拆分, 即：`【联系人】（姓名, 性别, 家庭电话, 公司电话）`。

- 第二范式：表必须有一个主键，没有包含在主键的列必须**完全依赖**于主键。第二范式就是在第一范式的基础上属性完全依赖于主键。

    考虑一个订单明细表：`【OrderDetail】（OrderID, ProductID, UnitPrice, Discount, Quantity, ProductName）`。

    因为我们知道在一个订单中可以订购多种产品, 所以单单一个 OrderID 是不足以成为主键的, 主键应该是`(OrderID, ProductID）`。显而易见 Discount(折扣），Quantity(数量)完全依赖(取决)于主键(OderID, ProductID），而 UnitPrice, ProductName 只依赖于 ProductID. 所以 OrderDetail 表不符合 2NF. 不符合 2NF 的设计容易产生冗余数据。 可以把【OrderDetail】表拆分为`【OrderDetail】（OrderID, ProductID, Discount, Quantity)`和`【Product】（ProductID, UnitPrice, ProductName)`来消除原订单表中UnitPrice, ProductName多次重复的情况。

- 第三范式：非主键列必须**直接依赖**于主键，不能存在传递依赖，是第二范式的子集。

    考虑一个订单表`【Order】(OrderID, OrderDate, CustomerID, CustomerName, CustomerAddr, CustomerCity)`主键是(OrderID)

    其中OrderDate, CustomerID, CustomerName, CustomerAddr, CustomerCity等非主键列都完全依赖于主键(OrderID），所以符合 2NF. 不过问题是 CustomerName, CustomerAddr, CustomerCity 直接依赖的是 CustomerID(非主键列），而不是直接依赖于主键, 它是通过传递才依赖于主键, 所以不符合3NF。

    通过拆分【Order】为`【Order】（OrderID, OrderDate, CustomerID)`和`【Customer】（CustomerID, CustomerName, CustomerAddr, CustomerCity)`从而达到 3NF。

### MySQL的端口号是多少，如何修改这个端口号

端口号3306，修改/etc/my.cnf

### UNION/JOIN

UNION与UNION ALL的区别：

- UNION 操作符用于合并两个或多个 SELECT 语句的结果集。如果允许重复的值，使用 UNION ALL.
- 注意，UNION 内部的 SELECT 语句必须拥有相同数量的列。列也必须拥有相似的数据类型。同时，每条 SELECT 语句中的列的顺序必须相同。

JOIN的分类：

- 有时为了得到完整的结果，我们需要从两个或更多的表中获取结果。我们就需要执行 JOIN
- INNER（默认可省略） JOIN: 如果表中有至少一个匹配，则返回行（INNER JOIN 与 JOIN），取两个表的交集
- LEFT JOIN: 即使右表中没有匹配，也从左表返回所有的行，产生左表的完全集，右表没有的用null代替
- RIGHT JOIN: 即使左表中没有匹配，也从右表返回所有的行，产生右表的完全集，左表没有的用null代替
- FULL JOIN: 只要其中一个表中存在匹配，就返回行，取两个表的并集（MySQL不支持，可以使用UNION ALL模拟）
- CROSS JOIN：产生笛卡尔积，若左表M条记录而右表N条记录，则结果有M*N条记录

![C++查漏补缺-20200112152804.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/C%2B%2B%E6%9F%A5%E6%BC%8F%E8%A1%A5%E7%BC%BA-20200112152804.png)

### 索引

#### 索引优缺点

索引是对数据库表中一列或多列的值进行排序的一种结构，使用索引可快速访问数据库表中的特定信息。索引相当于一本书的目录，目录当然不是越多越好的，目录需要占纸张（索引占磁盘空间）

优点：

1. 通过创建唯一性索引，可以保证数据库表中每一行数据的唯一性。
2. 可以大大加快数据的检索速度，这也是创建索引的最主要的原因。
3. 可以加速表和表之间的连接，特别是在实现数据的参考完整性方面特别有意义。
4. 通过使用索引，可以在查询的过程中，使用优化隐藏器，提高系统的性能。

缺点：

1. 创建索引和维护索引要**耗费时间**，这种时间随着数据量的增加而增加。
2. 索引需要**占物理空间**，除了数据表占数据空间之外，每一个索引还要占一定的物理空间，如果要建立聚簇索引，那么需要的空间就会更大。
3. 当对表中的数据进行增加、删除和修改的时候，索引也要**动态的维护**，这样就降低了数据的维护速度。

#### 什么时候不该用索引

1. 在查询中很少使用的列不应该创建索引，浪费物理空间也降低了系统维护速度
2. 只有很少数据值的列也不应该增加索引，如人事表的性别列
3. 当修改性能远远大于检索性能时，不应该创建索引

#### 索引的分类

哈希索引比较少用，查找**单条**记录的速度非常快，但**不支持范围查找和排序**，需要处理哈希冲突，需要全值精确匹配

为了减少**磁盘IO**，索引底层使用了B+树

1. B+树的**关键字**只是起到索引的作用
2. B+树的**数据都存储在叶子节点**上，B树的数据存储在每个节点上，所以需要遍历才能找到
3. B+树支持**区间访问**，叶子节点会按顺序建立指针

Mysql各种索引区别：

- 普通索引：最基本的索引，没有任何限制
- 唯一索引(unique key)：索引列的值必须唯一，允许有空值，允许创建多个，不能被其他表引用为外键
- 主键索引(primary key)：特殊的唯一索引，索引列的值必须唯一，**不允许有空值**，**一个表最多一个主键**，主键可以被其他表引用为**外键**，适合唯一标识，如自动递增咧、身份证
- 全文索引：仅可用于MyISAM表，针对较大的数据，生成全文索引很耗时耗空间。
- 联合/组合索引：指两个或更多列上的索引，遵循**最左匹配原则**，

#### 为什么官方建议使用自增长主键作为索引

结合B+Tree的特点，**自增主键是连续的**, 在插入过程中尽量减少页分裂, 即使要进行页分裂, 也只会分裂很少一部分. 并且能减少数据的移动, 每次插入都是插入到最后。 总之就是减少分裂和移动的频率。

#### 创建索引

```sql
--直接创建索引
CREATE [UNIQUE|FULLLTEXT] INDEX index_name ON table_name(column_name(length))

--修改表结构的方式添加索引
ALTER TABLE table_name ADD [UNIQUE|FULLLTEXT] INDEX index_name (column(length))

--创建表的时候同时创建索引
CREATE TABLE `table` (
    `id` int(11) NOT NULL AUTO_INCREMENT ,
    `title` char(255) CHARACTER NOT NULL ,
    PRIMARY KEY (`id`),
    [UNIQUE|FULLLTEXT] INDEX index_name (title(length))
)
```

### 事务是什么/事务隔离是什么/事务怎么实现的

[Mysql事务实现原理](https://juejin.im/post/5cb2e3b46fb9a0686e40c5cb#heading-0)

- 事务是指作为单个逻辑工作单元执行的**一系列操作**，要么完全地执行，要么完全地不执行

- 必须满足ACID（原子性、一致性、隔离性和持久性）

    1. 原子性（Atomicity）：事务包含的所有操作要么全部成功，要么全部失败回滚
    2. 一致性（Consistency）：事务必须使数据库从一个一致性状态变换到另一个一致性状态，比如A与B账户的钱加起来是5000，那么无论如何转账，最后还是5000
    3. 隔离性（Isolation）：当多个用户并发访问数据库时，比如操作同一张表时，数据库为每一个用户开启的事务，不能被其他事务的操作所干扰，多个并发事务之间要相互隔离，有4种隔离级别
    4. 持久性（Durability）：一个事务一旦被提交了，那么对数据库中的数据的改变就是永久性的，即便是在数据库系统遇到故障的情况下也不会丢失提交事务的操作。

- 事务最终要实现：

    1. 事务的原子性是通过 undo log 来实现的（回滚日志，用来回滚数据，未提交事务的原子性）
    2. 事务的持久性性是通过 redo log 来实现的重做日志，用来恢复数据，已提交事务的持久化特性）
    3. 事务的隔离性是通过 (读写锁+MVCC)来实现的
    4. 而事务的终极大 boss 一致性是通过原子性，持久性，隔离性来实现的！！！

### MySQL的4种事务隔离级别

隔离级别的分类是数据的**可靠性与性能之间的权衡**。

- 未提交读(read uncommitted)：一个事务在提交之前，对其他事务是可见的，即事务可以读取未提交的数据。

    存在**脏读**（对要写的数据没有加锁，其他事物读到了某事物修改后但未提交的数据）

    但可以**读写并行**，性能高。

- 提交读(read committed)：事务在提交之前，对其它事务是不可见的。

    解决了脏读问题（对要写的数据加了排他锁）

    存在**不可重复读**（对要读的数据没有加锁，事务内两次查询的得到的结果可能不同，即可能在查询的间隙，有事务提交了修改）

- 可重复读(repeatable read)：在同一事务中多次读取的数据是一致的。

    解决了脏读和不可重复读问题（对要读or要写的数据都加了排他锁，或者用MVCC机制实现）

    存在**幻读**（在事务两次查询间隙，有其他事务又插入或删除了新的记录）。

    **MySQL默认隔离级别**。

- 串行(serializable)：强制事务串行化执行。即一个事物一个事物挨个来执行，可以解决上述所有问题。

### MVCC（多版本并发控制）是什么

并发控制最简单的方法是加锁，让所有的读者等待写者工作完成，但是这样**效率**会很差。

MVCC将同一份数据保留多个副本，添加不同的**版本号**。

事务开启时看到的是哪个版本，就是哪个版本。

最大的好处：读写不冲突

### MySQL存储引擎简介

- InnoDB：最为通用/推荐的一种引擎，专注于事务，在**并发**上占优势，系统资源**占用多**。
- MyISAM：默认的存储引擎（MySQL5.1之前），专注于**性能**，查询速度块，系统资源**占用少**。
- InnoDB支持事务, MyISAM不支持；
- InnoDB支持**MVCC（多版本并发控制）**，MyISAM不支持
- InnoDB支持**行级锁、表锁**；MyISAM只支持表锁；
- InnoDB不支持**全文索引**，MyISAM支持全文索引；
- InnoDB和MyISAM都支持B+树索引，InnoDB还支持哈希索引
- MyISAM实现了**前缀压缩**技术，占用存储空间更小（但会影响查找），InnoDB是原始数据存储，占用存储更大。

其他存储引擎如Memory、CSV

PS：大部分情况下，InnoDB都是正确的选择。---《高性能MySQL》

### 锁

- 从**加锁时机**分为悲观锁和乐观锁

- 从**锁的范围**分为表锁、(页锁)、行锁，（InnoDB独有）

    表锁：锁住整张表，读锁互不阻塞，写锁阻塞其他所有读写锁（同一张表）。开销最小。

    行级锁（InnoDB独有）：**针对索引加的锁**， 不是针对记录加的锁。并且该索引不能失效，否则都会从行锁升级为表锁。开销大，并发程度高。

- 从**锁的粒度**分为共享锁和排它锁

    共享锁/读锁：互不阻塞，优先级低

    排他锁/写锁：阻塞其他锁，优先级高，即确保在一个事务写入时不受其他事务的影响。对于update,insert,delete语句会自动加排它锁, 在执行语句后添加`for update`

    锁粒度的影响：锁定的数据量越少（粒度越小），并发程度越高，但相应的加锁、检测锁、释放锁用的系统开销也随之增大。

![MySQL的各种锁](https://raw.githubusercontent.com/IMWYY/AboutMyself/master/picBed/Screenshot1520500121.png)

### 乐观锁与悲观锁

- 乐观锁（适用于多读，写时检查，需要用户实现）

    总是假设最好的情况，每次去拿数据的时候都认为别人不会修改，所以不会上锁，但是在更新的时候会判断一下在此期间别人有没有去更新这个数据，可以使用**版本号机制**和**CAS算法**实现。乐观锁适用于**多读**的应用类型，这样可以提高吞吐量，像数据库提供的类似于write_condition机制，其实都是提供的乐观锁。

- 悲观锁（适用于多写，读时加锁）

    总是假设最坏的情况，每次去拿数据的时候都认为别人会修改，所以每次在拿数据的时候都会上锁，这样别人想拿这个数据就会阻塞直到它拿到锁（共享资源每次只给一个线程使用，其它线程阻塞，用完后再把资源转让给其它线程）。传统的关系型数据库里边就用到了很多这种锁机制，比如行锁，表锁等，读锁，写锁等，都是在做操作之前先上锁。

- 两种锁的使用场景

    从上面对两种锁的介绍，我们知道两种锁**各有优缺点**，不可认为一种好于另一种，像乐观锁适用于写比较少的情况下（多读场景），即冲突真的很少发生的时候，这样可以省去了锁的开销，加大了系统的整个吞吐量。但如果是多写的情况，一般会经常产生冲突，这就会导致上层应用会不断的进行retry，这样反倒是降低了性能，所以一般多写的场景下用悲观锁就比较合适。

- 乐观锁的版本号机制

    一般是在数据表中加上一个数据**版本号version字段**，表示数据被修改的次数，当数据被修改时，version值会加一。当线程A要更新数据值时，在读取数据的同时也会读取version值，在提交更新时，若刚才读取到的version值为当前数据库中的version值相等时才更新，否则重试更新操作，直到更新成功。

- CAS算法

    即compare and swap（比较与交换），是一种有名的无锁算法。无锁编程，即不使用锁的情况下实现多线程之间的变量同步，也就是在没有线程被阻塞的情况下实现变量的同步，所以也叫非阻塞同步（Non-blocking Synchronization）。CAS算法涉及到三个操作数：需要读写的内存值 V，进行比较的值 A，拟写入的新值 B。当且仅当 V 的值等于 A时，CAS通过原子方式用新值B来更新V的值，否则不会执行任何操作（**比较和替换是一个原子操作**）。一般情况下是一个自旋操作，即不断的重试。

- 乐观锁的缺点
    1. **ABA 问题（常见）**：如果一个变量V初次读取的时候是A值，并且在准备赋值的时候检查到它仍然是A值，那我们就能说明它的值没有被其他线程修改过了吗？很明显是不能的，因为在这段时间它的值可能被改为其他值，然后又改回A，那CAS操作就会误认为它从来没有被修改过。这个问题被称为CAS操作的 "ABA"问题。
    2. 自旋CAS循环时间长开销大
    3. CAS 只对单个共享变量有效，当操作涉及跨多个共享变量时 CAS 无效

### MySQL死锁原因和解决办法

先答操作系统中死锁的四个产生原因

- 例子：一个用户先锁住A想访问B，另一个先锁住B想访问A，这种情况下，只能调整程序逻辑，顺序进行
- 共享锁、独占锁
- 乐观锁（版本号机制）、悲观锁（总是加锁）

解决办法：终止进程、抢占资源

### SQL优化

1. 经常使用的列使用索引
2. 多次查询同样的数据，考虑缓存改组数据
3. select * from tables，真的需要所有列数据吗？
4. 切分查询，大查询切分为小查询
5. 分解关联查询，单表查询，在应用程序中进行关联，避免锁争用

### CAP定理是什么

一个分布式系统不可能同时满足一致性（C：Consistency）、可用性（A：Availability）和分区容错性（P：Partition tolerance）这三个基本需求，最多只能同时满足其中两项

- 一致性：在分布式环境下，数据在多个副本之间能否保持一致的特性
- 可用性：系统提供的服务必须一直处于可用的状态，有限时间内，返回结果
- 分区容错性：分布式系统在遇到任何网络分区故障的时候，仍然需要能够保证对外提供满足一致性和可用性的服务，除非是整个网络环境都发生了故障。

所以必须抛弃一个

- CA：抛弃分区容错性，这就是传统的单机数据库
- AP：放弃一致性，这是很多分布式系统设计的选择，例如很多NoSQL系统
- CP：放弃可用性，基本不会这样选择，系统不可用那还要系统干什么

### MongoDB是什么

- MongoDB 是一个基于分布式文件存储的数据库。由 C++ 语言编写。旨在为 WEB 应用提供可扩展的高性能数据存储解决方案。
- MongoDB 是一个介于关系数据库和非关系数据库之间的产品

### Redis是什么

- Redis是一个基于内存的键值型数据库，**数据全部存在内存中**（所以高效），**定期写入磁盘**（提供持久化），当内存不够时，可以选择指定的LRU算法删除数据，Redis是单进程单线程的
- Redis支持多种数据结构，如string、hash、set、list等
- 主要有点是速度快，因为在内存中，类似于hash
- 主要缺点是容量受到内存的限制，不支持海量数据

### Redis应用场景

1. 会话缓存：相比于memcached，Redis提供持久化
2. 全页缓存：因为有磁盘的持久化
3. 队列：提供list和set，可以当做消息队列平台
4. 排行榜/计数器：Redis对数字的递增或递减的实现非常高效
5. 发布/订阅

### Redis分布式锁是怎么回事

先调用setnx（set if not exist）来争抢锁，抢到之后，再用expire给锁设置一个过期时间以防忘记释放

追问：但如果在setnx与expire之间程序崩溃或断电重启了，那怎么办？

回答：那这个锁就不会释放了！好像有个很复杂的指令可以让setnx与expire是原子操作的

### Redis里有1亿个key，如何找出其中10w个以某个固定前缀开头的可以

用keys指令可以扫除指定模式的key列表

追问：但如果是线上业务，这样会有问题吗？

回答：redis是单进程单线程的，keys指令会导致阻塞，影响线上服务。这时应该用scan指令，scan指令可以无阻塞的提取出指定模式的key列表，但是会有一定的重复概率，在客户端做一次去重就可以了，但是整体所花费的时间会比直接用keys指令长

### Redis和MySQL数据怎么保持数据一致的

起因：高并发时，Redis做缓存，MySQL做数据持久化。有请求的时候从Redis中获取缓存的用户数据，有修改则同时修改MySQL和Redis中的数据。所以产生了一致性问题

解决：读Redis（热数据基本都在Redis），写MySQL（增删改都是在MySQL），更新Redis数据（先写入MySQL，再更新到Redis）

### Redis和Memcached的区别

- 数据类型：Redis支持String、List、Set等等；Memcached只支持简单数据类型
- 持久性：Redis可以将内存中的数据定期存入磁盘，有持久性；Memcached不支持持久性
- 分布式存储：Redis支持主从复制模式；Memcached本身不支持分布式，但可以使用一致性hash

## 数据结构与算法

### AVL树与红黑树

AVL树保证任意节点的子树高度差不大于1，是严格平衡的，而红黑树放弃了这个严格平衡的条件，只追求大致平衡，每次插入时**最多只需要三次旋转**即可达到平衡，更加高效

AVL树在查找上的效率可能要快于红黑树，但是红黑树在插入和删除上完爆AVL树，**AVL树为了维持严格平衡，可能需要大量的计算**

### B树与B+树

1. B+树的**关键字**只是起到索引的作用
2. B+树的**数据都存储在叶子节点**上，B树的数据存储在每个节点上
3. B+树支持**区间访问**，叶子节点会按顺序建立指针

### 堆

由于二叉堆的性质，可以用数组实现，

- insert，空穴上滤，最坏O(logn)，平均O(1)
- delete(min or max)，空穴下滤，最坏O(logn)，平均O(logn)
- 建堆，若用自下而上的方法，平均O(n)

堆排序：

二叉堆的建堆需要O(N)时间，然后再执行N次deleteMin操作，每次deleteMin操作为O(logN)，将这些元素记录到另一个数组然后再复制回来(二叉堆本来底层也是用数组实现的)，复制用时O(N)，于是就得到了N个元素的排序，用时O(N+NlogN+N)，故**堆排序的时间复杂度为O(NlogN)**

### Top(K)

1. 直接全部排序（O(nlogn)，只适用于内存够的情况）：将数据全部排序，然后取排序后的数据中的第K个。

2. 局部排序（O(nk)，只适用于内存够的情况）：不再全局排序，只对前k个数排序，可以选择冒泡排序，冒k个泡即可

3. 最小堆法（一次插入O(lgk)，最差情况n个元素都插入堆，所以时间复杂度为O(nlogk)，可适用于内存不够的情况）：这是一种局部淘汰法。先读取前K个数，建立一个最小堆。然后将剩余的所有数字依次与最小堆的堆顶进行比较，如果小于或等于堆顶数据，则继续比较下一个；否则，删除堆顶元素，并将新数据插入堆中，重新调整最小堆。当遍历完全部数据后，最小堆中的数据即为最大的K个数。

4. 快速选择算法（O(n)，只使用于内存够的情况）：类似于快速排序，首先选择一个划分元，将比这个划分元大的元素放到它的前面，比划分元小的元素放到它的后面，此时完成了一趟排序。如果此时这个划分元的序号index刚好等于K，那么这个划分元以及它左边的数，刚好就是前K个最大的元素；如果index > K，那么前K大的数据在index的左边，那么就继续递归的从index-1个数中进行一趟排序；如果index < K，那么再从划分元的右边继续进行排序，直到找到序号index刚好等于K为止。这种方法就避免了对除了Top K个元素以外的数据进行排序所带来的不必要的开销，是分治法中的减治法（Reduce&Conquer），把大问题分成若干小问题，只需要解决一个小问题就可以解决大问题了。

### 海量数据下的TopK变形问题

Hash法：如果这些数据中有很多重复的数据，可以先通过hash法，把重复的数去掉，这样可以大大减少运算量，但有可能会产生**数据倾斜问题**：有些数据重复很大，即使Hash过也没法一次性读入内存，则需要把这个Hash文件单独拎出来随即拆分

如果允许分布式，可以把数据分发给多台机器，每台机器并行计算各自的TopK，最后再汇总，得到最终的TopK，比如MapReduce分布式计算框架

### 找中位数

思考快排算法，我们可以在O(n)复杂度内，得到任意元素在数组中的位置。那么任取一个数，我们可以得到有a个数大于它，有b个数小于它，如果恰好a=b，则找到中位数就是该数，这里用到的就是partition的思想，而且这是分治法中的减治法。

如果有`a<b`，则筛去所有大于等于该数的数，中位数必定位于剩下的数中，并且记录筛去了sa+=a+1个数。

如果有`a>b`，则筛去所有小于等于该数的数，中位数必定位于剩下的数中，并且记录筛去了sb+=b+1个数。

在剩余的b个数中，再任取一个数，可以得到有a个数大于它，有b个数小于它，如果恰好a+sa=b+sb，则找到中位数就是该数。

### 海量数据处理面试总结

[十道海量数据处理面试题与十个方法大总结](https://blog.csdn.net/v_JULY_v/article/details/6279498?spm=a2c4e.10696291.0.0.66b019a4vIayRB)

### 快速计算的素数

筛选法：先确定一个范围，然后把2的所有倍数去掉、把3的所有倍数去掉...、

### 手撕LRU

运用你所掌握的数据结构，设计和实现一个 LRU (最近最少使用) 缓存机制。它应该支持以下操作： 获取数据 get 和 写入数据 put。

解答：双链表 + 哈希表

可以使用 HashMap 存储 key，这样可以做到 save 和 get key 的时间都是 O(1)，而 HashMap 的 Value 指向双向链表实现的 LRU 的 Node 节点

- 用队列可以吗

    不行，队列只能做到先进先出，但是重复用到中间的数据时无法把中间的数据移动到顶端。

- 用单链表不行吗

    单链表能实现新来的放头部，最久不用的在尾部删除。但删除的时候需要遍历到尾部，因为单链表只有头指针。在用到已经用到过的数据时，还要遍历整合链表，来确定是否用过，然后再遍历到响应位置来剔除的节点，并重新放在头部

```c++
#include <list>
#include <iostream>
#include <unordered_map>
using namespace std;

class LRUCache{
public:
    LRUCache(int cap){
        capacity = cap;
    }
    int get(int key){
        // 只需要O(1)时间
        if(position.find(key) != position.end()){
            // 找到
            put(key, position[key]->second);
            isFound = true;
            return position[key]->second;
        }
        isFound = false;
        return -1;
    }
    void put(int key, int value){
        if(position.find(key) != position.end()){
            recent.erase(position[key]); // 从链表中删除
        }
        if(recent.size() >= capacity){
            // 超过缓存，删除最老的记录
            position.erase(recent.back().first);
            recent.pop_back();
        }
        recent.push_front(pair<int, int>(key, value));
        position[key] = recent.begin();
    }
    bool isFound; // get返回-1时，检查该变量即可知道是否得到相应缓存
private:
    int capacity;
    list<pair<int, int>> recent; // 用链表记录最近
    unordered_map<int, list<pair<int, int>>::iterator> position; // 用哈希表记录位置
};

int main(){
    LRUCache cache (3);
    cache.put(1, 1);
    cache.put(2, 2);
    cache.put(3, 3);
    cache.put(4, 4);
    cout << cache.get(1) << ", isFound:" << cache.isFound << endl;
    cout << cache.get(1) << ", isFound:" << cache.isFound << endl;
    cout << cache.get(2) << ", isFound:" << cache.isFound << endl;
    cout << cache.get(3) << ", isFound:" << cache.isFound << endl;
    cout << cache.get(4) << ", isFound:" << cache.isFound << endl;
    cout << cache.get(5) << ", isFound:" << cache.isFound << endl;

}
```

### 如何判断一个点P是否在三角形ABC内

面积法：

1. 计算三角形ABP、ACP、BCP面积之和是否等于三角形ABC面积
2. 要求三角形面积，可以先计算两个边的**叉乘**得到平行四边形的面积，再除以2即可

同向法：

1. 发现规律：顺时针沿着ABC走时，若P在三角形内，则肯定在行走方向的右侧，所以只需要判断P是否在AB、BC、CA边的右侧即可
2. 判断右侧：注意到，在AB上走时，C也是在AB的右侧，所以只需要判断P是否与C在AB的同侧即可
3. 判断同侧：连接PA，将PA与AB做叉乘（得到向量M），再将CA与AB做叉乘（得到向量N），所以只需要M与N的方向是否一致即可
4. 判断方向：M与N做点乘，若大于0则方向一致，若小于则方向相反，=0则垂直

叉乘解释：

在三维几何中，向量a和向量b的叉乘结果是一个向量，更为熟知的叫法是**法向量**，该向量垂直于a和b向量构成的平面。

### rand7构造rand5/rand5构造rand7

- 如果输入随机数发生器的范围要比输出随机数发生器的范围大，比如rand7构造rand5，那么很简单，当产生6或7时，**重新**产生随机数，直到输出1~5中的某个数。
- 这个叫做rejection sampling，不满足则**重新取样**。
- 当然，如果两个范围差得很大，可以先取余，比如。
- 重新取样的可行性是可以证明的，输出随机数发生器下次生成1的概率=第一次产生1的概率+第一次产生6or7*第二次产生1的概率+....=1/5

    `P(x=1) = 1/7 + (2/7)*(1/7) + (2/7)^2*(1/7) + (2/7)^3*(1/7) + ... = 1/5`

rand5构造rand7如果也能用刚才的思想就好了！

- 如何从小范围的数构造更大范围的数呢？同时满足这个更大范围的数出现概率是相同的，可以想到的运算包括两种：加法和乘法
- 首先考虑：用`rand5+rand5-1`可以吗？**当然不行**，虽然输出范围是1~10，但是只有输出1只有一个可能：两次rand5都是1，但是输出2有两种可能：1和2、2和1，所以不能用加法的结合
- 所以考虑：乘法结合加法，`5*(rand5-1)+rand5`，这样可以产生1~25的随机数，而且都是平均的，那么为了得到1~7的随机，可以把1~25分为几段映射，1~3映射到1，4~6映射到2，7~9映射到3，10~12映射到4，13~15映射到5，16~18映射到6，19~21映射到7，多余的22~25可以舍去，这不就是**rejection sampling**吗

```c++
int Rand7()
{
    int n ,tmp1 ,tmp2;
    do
    {
        tmp1 = Rand5();
        tmp2 = Rand5();
        n = (tmp1-1)*5+tmp2;//n是可以取1~25的随机的数。
    } while (n>21);//当n>21舍去，这样n只能取1~21，对7取模就能取1~7之间的随机数
    return 1+n%7;
```

将这个问题进一步抽象，已知random_m()随机数生成器的范围是[1, m] 求random_n()生成[1, n]范围的函数，m < n && n <= m *m
一般解法：

```c++
int random_n()
{
    int val = 0 ;
    int t; // t为n最大倍数，且满足 t <= m * m
    do {
        val = m * (random_m() - 1) + random_m();
    } while (val > t);
    return val;
}
```

### 洗牌算法

摘自[三种洗牌算法shuffle](https://blog.csdn.net/qq_26399665/article/details/79831490)

Fisher–Yates洗牌算法：从原始数组中随机取一个之前没取过的数字到新的数组中，时间O(n)，空间O(1)，不会出现**浪费次数**，保持`n!`的样本空间

```shell
To shuffle an array a of n elements (indices 0..n-1):
  for i from n - 1 downto 1 do
       j = random integer with 0 <= j <= i
       exchange a[j] and a[i]
```

下面证明其随机性，即每个元素在位置1~n上的概率都是1/n：

- 对于原数组任意第r个元素

  - 它在第n个位置的概率是`1/n`（第n个元素与第r个元素交换的概率）

  - 它在第n-1个位置的概率是`[(n-1)/n]*[1/(n-1)]=1/n`（第n个元素不与第r个元素交换的概率 x 第n-1个元素与第r个元素交换的概率）

  - 它在第n-2个位置的概率是`[(n-1)/n]*[(n-2)/(n-1)]*[1/(n-2)]=1/n`（第n个元素不与第r个元素交换的概率 x 第n-1个元素不与第r个交换的概率 x 第n-2个元素与第r个元素交换的概率）

  - 它在第n-k个位置的概率是`[(n-1)/n]*[(n-2)/(n-1)]* ... [1/(n-k)]=1/n`（第n个元素不与第r个元素交换的概率 x 第n-1个元素不与第r个元素交换的概率 x 第n-2个元素不与第r个元素交换的概率 x ... x 第n-k个元素与第r个元素交换的概率）

### 如何等概率挑出大文件中的一行

Amazon: 一个文件中有很多行，不能全部放到内存中，如何等概率的随机挑出其中的一行？

答案：先将第一行设为候选的被选中的那一行，然后一行一行的扫描文件。假如现在是第 K 行，那么第 K 行被选中踢掉现在的候选行成为新的候选行的概率为 1/K。用一个随机函数看一下是否命中这个概率即可。命中了，就替换掉现在的候选行然后继续，没有命中就继续看下一行

### 如何等概率挑选大文件中的N行中文

问题：给你一个 Google 搜索日志记录，存有上亿挑搜索记录（Query）。这些搜索记录包含不同的语言。随机挑选出其中的 100 万条中文搜索记录。假设判断一条 Query 是不是中文的工具已经写好了。

答案：其实是上题的变形，假设你一共要挑选 N 个 Queries，设置一个 N 的 Buffer，用于存放你选中的 Queries。对于每一条飞驰而过的
Query，按照如下步骤执行你的算法：

1. 如果非中文，直接跳过
2. 如果 Buffer 不满，将这条 Query 直接加入 Buffer 中
3. 如果 Buffer 满了，假设当前一共出了过 M 条中文 Queries，用一个随机函数，以 N / M 的概率来决定这条 Query 是否能被选中留下。
    1. 如果没有选中，则跳过该 Query，继续处理下一条 Query
    2. 如果选中了，则用一个随机函数，以 1 / N 的概率从 Buffer 中随机挑选一个 Query 来丢掉，让当前的 Query 放进去。

## 设计模式

### 单例模式

- 单例模式主要解决一个全局使用的类频繁的创建和销毁的问题。
- 单例模式下可以确保某一个类只有一个实例（该类不能被复制、拷贝），而且是自行实例化（构造函数是私有的），并向整个系统提供这个实例。
- 使用场景：设备管理器，驱动程序；创建的对象消耗资源过多，比如 I/O 与数据库的连接等。
- 优点：减少了内存的开销；避免对资源的多重占用
- 缺点：没有接口，不能继承

### 单例模式的懒汉式

[C++ 单例模式总结与剖析](https://www.cnblogs.com/sunchaothu/p/10389842.html)

延迟加载唯一实例，第一次使用实例时才会加载

线程不安全、有内存泄漏的懒汉式单例模式程序：

```c++
#include <iostream>
using namespace std;
class Singleton{
public:
    ~Singleton(){
        cout << "d-tor called" << endl;
    }
    static Singleton* getInstance(){
        // 临界区！
        if(instance_ptr == nullptr){
            instance_ptr = new Singleton();
        }
        return instance_ptr;
    }
private:
    // 构造函数、拷贝赋值、拷贝构造函数都是私有的
    Singleton(){
        cout << "c-tor called" << endl;
    }
    Singleton(const Singleton&) = delete;
    Singleton& operator=(const Singleton& rhs) = delete;
    // 唯一实例是私有的，且是静态的
    static Singleton* instance_ptr;
};
// 类的静态成员（无论公私）都要在main函数之外初始化
Singleton* Singleton::instance_ptr = nullptr;
int main()  
{  
    Singleton* instance = Singleton::getInstance();  
    Singleton* instance2 = Singleton::getInstance();  
    return 0;  
}  
```

main函数中获取了两次类的实例，但只会有一次"c-tor called"的输出，看似实现了单例模式，但有两个问题：

1. **线程不安全**：当多线程获取单例时有可能引发竞态条件：第一个线程在getInstance的if中判断是空的，于是开始实例化单例；同时第二个线程在getInstance的if中判断是空的（实例还未创建出来），于是也开始实例化单例；这样就会实例化出两个对象。解决办法：**加锁**
2. **内存泄漏**：注意到类中只负责new出对象，却没有负责delete对象，因此只有构造函数被调用，析构函数却没有被调用；因此会导致内存泄漏。解决办法：使用**智能指针**

线程安全（加锁）、内存安全（智能指针）的懒汉式单例模式程序：

```c++
#include <iostream>
#include <memory>
#include <mutex>
using namespace std;
mutex mtx;
class Singleton{
public:
    typedef shared_ptr<Singleton> Ptr; // 变量定义
    ~Singleton(){
        cout << "d-tor called" << endl;
    }
    static Ptr getInstance(){ // 返回智能指针
        // 双检锁（double checked lock）
        if(instance_ptr == nullptr){
            lock_guard<mutex> lockg(mtx);
            if(instance_ptr == nullptr){
                instance_ptr = shared_ptr<Singleton>(new Singleton()); // 构造智能指针
            }
        }
        return instance_ptr;
    }
private:
    Singleton(){
        cout << "c-tor called" << endl;
    }
    Singleton(const Singleton&) = delete;
    Singleton& operator=(const Singleton& rhs) = delete;
    static Ptr instance_ptr;
};
Singleton::Ptr Singleton::instance_ptr = nullptr;
int main()  
{  
    Singleton::Ptr instance_sp = Singleton::getInstance();  
    Singleton::Ptr instance2_sp = Singleton::getInstance();  
    return 0;  
}
```

main函数输出"c-tor called \n d-tor called"，达到了智能指针自动析构的目的，没有内存泄漏。使用了双检锁，好处是**只有在实例为空时才会上锁，减少锁的开销**

不足之处：

1. 单例类用了智能指针，用户（main函数）也得使用智能指针，这样比较繁琐
2. **在某些平台下双检锁会失效！**

懒汉式最佳版本——使用**局部静态变量**：

```c++
#include <iostream>
using namespace std;
class Singleton{
public:
    ~Singleton(){
        cout << "d-tor called" << endl;
    }
    static Singleton& getInstance(){ // 注意返回引用！
        static Singleton instance_ptr;
        return instance_ptr;
    }
private:
    Singleton(){
        cout << "c-tor called" << endl;
    }
    Singleton(const Singleton&) = delete;
    Singleton& operator=(const Singleton& rhs) = delete;
    // static Ptr instance_ptr; // 没有静态成员实例了！
};
int main()  
{  
    Singleton& instance = Singleton::getInstance(); // 注意用引用！
    Singleton& instance2 = Singleton::getInstance();  
    return 0;  
}
```

这是Effective C++作者Meyers提出的，如果变量在初始化时，并发线程进入了声明语句，并发线程将会阻塞等待初始化结束。这是**C++11的Magic Static**的特性。

所以既解决了线程不安全的问题，又不需要智能指针。

局部静态变量保证了类的实例只有一个，**静态成员的生命期是从第一次声明到程序结束**，从第一次声明开始，所以是懒汉式的，自动析构，所以内存安全。

有可能C++11以前的编译器上线程不安全，因为用编译器用一个**全局标识**判断静态成员是否已初始化，这相当于先if再初始化，多线程可能就会在这里造成竞争条件。

### 单例模式的饿汉式

直接加载唯一实例，定义单例类时就进行实例化，所以天生没有多线程的问题

直接定义静态对象的饿汉式单例模式程序：

```c++
#include <iostream>
using namespace std;
class Singleton{
public:
    ~Singleton(){
        cout << "d-tor called" << endl;
    }
    static Singleton& getInstance(){ // 返回静态对象的引用
        return instance;
    }
private:
    Singleton(){
        cout << "c-tor called" << endl;
    }
    Singleton(const Singleton&) = delete;
    Singleton& operator=(const Singleton& rhs) = delete;
    static Singleton instance; // 直接定义静态对象
};
Singleton Singleton::instance; // main函数外初始化静态对象,因为instance是对象不是指针，所以不用new
int main()  
{  
    Singleton& instance = Singleton::getInstance();  // 用引用
    Singleton& instance2 = Singleton::getInstance();  
    return 0;  
}
```

优点：实现简单，多线程安全

缺点：如果存在多个单例模式互相依赖，则会程序崩溃

静态指针+类外初始化时new空间实现的饿汉式单例模式：

```c++
#include <iostream>
using namespace std;
class Singleton{
public:
    ~Singleton(){
        cout << "d-tor called" << endl;
    }
    static Singleton* getInstance(){
        return instance_p;
    }
private:
    Singleton(){
        cout << "c-tor called" << endl;
    }
    Singleton(const Singleton&) = delete;
    Singleton& operator=(const Singleton& rhs) = delete;
    static Singleton* instance_p;
};
Singleton* Singleton::instance_p = new Singleton();
int main()  
{  
    Singleton* instance = Singleton::getInstance();  
    Singleton* instance2 = Singleton::getInstance();  
    return 0;  
}  
```

### 单例模式的懒汉式加载，如果并发访问怎么办

使用锁机制，防止多次访问。具体做法，第一次判断为空不加锁，若为空，再进行加锁判断是否为空，若为空则生成对象。这叫double checked locking，但是双检锁在有些平台也会失效！

### 工厂模式

- 工厂模式主要解决接口选择的问题。
- 该模式下定义一个创建对象的接口，让其子类自己决定实例化哪一个工厂类，使其创建过程延迟到子类进行。
- 解耦，代码复用，更改功能容易。

### 观察者模式

- 定义对象间的一种一对多的依赖关系
- 当一个对象的状态发生改变时，所有依赖于它的对象都得到通知并被自动更新。
- 完美地将观察者与被观察者分离开

```c++
class Observer{
    void update();
}
class Subject{
    void attach(Observer* ob){
        observers.push_back(ob);
    }
    void detach(Observer* ob){
        auto it = find(observers.begin(), observers.end(), ob);
        if(it != observers.end(){
            observers.erase(it);
        }
    }
    void notify(){
        auto it = observers.begin();
        while(it != observers.end()){
            (*it)->update();
        }
    }
    list<Observer*> observers;
}
```

### 装饰器模式

- 对**已经存在**的某些类进行装饰，以此来扩展一些功能，从而动态的为一个对象增加新的功能。
- 装饰器模式是一种用于**代替继承**的技术，无需通过继承增加子类就能扩展对象的新功能。
- 使用场景：扩展一个类的功能；动态增加功能，动态撤销。
- 优点：更加灵活，同时避免类型体系的快速膨胀。
- 缺点：多层装饰比较复杂。

## 其他语言

### 强类型与弱类型、静态类型与动态类型

- 强类型语言：不允许改变变量的数据类型，除非进行强制类型转换。如Python、Java
- 弱类型语言：允许改变变量的数据类型，即使没有进行强制类型转换。
- 静态类型语言：在编译阶段确定所有变量的类型。
- 动态类型语言：在执行阶段确定所有变量的类型。

在 Python 中执行 test = '666' / 3 你会在运行时得到一个 TypeError 错误，相当于运行时排除了 untrapped error，因此 Python 是动态类型，强类型语言。

C++相对于C是强类型的

![ProgrammingLanguage](https://user-gold-cdn.xitu.io/2019/10/14/16dc80a311cf2fcd?imageslim)

### 面向对象（C++、Python、Java）

- 封装

    隐藏内部实现
    private、public，getter和setter

- 继承

    复用功能、扩展功能
    体现类之间的关系

- 多态

    重载（只有Python不支持，因为Python的函数参数本来就不需要指定类型）

    重写

### Java的多态与Java独有的抽象类概念

从C++虚函数观点来看，Java所有的非private成员函数都是虚的，子类重写父类的同名函数，会直接重写

纯虚函数是让子类必须重写的虚函数，这个在Java里面叫做抽象（abstract）方法，包含抽象方法的Java类必须是抽象类（C++没这个规定）

### C++、Python、Java继承体系

Java不支持多继承，C++和Python支持

c++首先引入的多重继承带来了诸如**菱形继承**一类的问题，而后为了解决这个问题又不得不引入了虚继承这种概念。然而在实际的应用中人们发现继承更多的只被用在两种场合：扩充/改善基类，以及实现多态。对于前者，单继承足以；而对于后者，则真正需要的其实是纯抽象类，即只包含纯虚函数的基类。而对于这一种基类，由于其目的和普通的实例类已经有所不同，因此在java中将其改称为**interface**，即接口加以明确区分。一个类可以**实现（implement）**多个接口（interface），这与多继承功能相当

Python继承体系包括：单继承、多继承、多级继承、混合继承（两种或多种类型的混合）

### RPC是什么

远程过程调用协议RPC（Remote Procedure Call Protocol)，比如Java的Netty框架，它封装了底层的（序列化、网络传输等）细节

首先搞清楚本地过程（函数）调用，传入的参数要压栈再出栈，执行函数体，再将返回值压栈，函数返回后从栈中取得返回值

1. **CALL ID**：远程过程调用时调用远程机器（服务器）上的函数，因为双方进程地址空间完全不一样，所以光靠函数名、函数指针是没法调用的，得有唯一的CALL ID
2. **序列化和反序列化**：双方的语言可能都不同，所以要转为字节流传输
3. **网络传输**：负责传输字节流，一般用TCP

### SSH三大框架

Spring，最核心的概念就两个：AOP（切面编程���和DI（依赖注入）。而DI又依赖IoC。通过IoC，所有的对象都可以从“第三方”**Spring容器**中得到，并由Spring注入到它应该去的地方。这种由原先的“对象管理对象”切换到“Spring管理对象”的方式，就是所谓的**IoC（控制反转）**，因为创建、管理对象的角色反过来了，有每个对象自主管理变为Spring统一管理。而且，只有通过IoC先让Spring创建对象后，才能进行下一步对象注入（DI），所以说DI依赖IoC

struts是一个MVC的web层框架，底层是对servlet的大量封装，拥有强大的拦截器机制，主要负责调用业务逻辑Service层。

Hibernate是一个持久层框架，轻量级(性能好)，orm映射灵活，对表与表的映射关系处理的很完善，对jdbc做了良好的封装，使得我们开发时与数据库交互不需要编写大量的SQL语句。

三大框架的大致流程jsp->struts->service->hibernate。因为struts 负责调用Service从而控制了Service的生命周期，使得层次之间的依赖加强，也就是耦合。所以我们引用了spring, spring在框架中充当容器的角色，用于维护各个层次之间的关系。通过IoC反转控制DI依赖注入完成各个层之间的注入，使得层与层之间实现完全脱耦，增加运行效率利于维护。

并且spring的AOP面向切面编程，实现在不改变代码的情况下完成对方法的增强。比较常用的就是spring的声明式事务管理，底层通过AOP实现，避免了我们每次都要手动开启事物，提交事务的重复性代码，使得开发逻辑更加清晰。

### Dubbo是什么

Dubbo是一款高性能、轻量级的开源Java RPC框架，它提供了三大核心能力：

1. 面向接口的远程方法调用
2. 智能容错和负载均衡
3. 以及服务自动注册和发现。

### 微服务

特点：

1. 单独的进程
2. 粒度小，只负责一种服务
3. 轻量级通讯，通常是REST接口
4. 松耦合，可部署

优点：

1. 服务独立测试、部署、升级
2. 提高容错性
3. 可定制

缺点：

1. 系统复杂度提高
2. 分布式通信问题
3. 服务的编排

Kubenetes容器平台

### 消息中间件/消息队列

消息中间件经常用来解决内部服务之间的异步调用问题

请求服务方把请求放到队列中，服务提供方去队列中获取请求进行处理，然后通过**回调**机制把结果返回

Kafka分布式、可分区、可复制、基于发布/订阅

RocketMQ就是阿里借鉴Kafka用Java开发出来的

场景与好处：

1. 通过异步提高系统性能，如削峰处理秒杀
2. 降低系统耦合性，基于发布/订阅，类似生产者与消费者，事件驱动

### 分布式算法Paxos与Raft

Paxos算法是基于消息传递的分布式一致性算法，具有高度容错性，但不容易理解

Raft算法比Paxos更容易理解，更容易实现。

- 在集群中选举一个领导者。
- 领导者负责接受客户端请求并管理到其他服务器的**日志复制**。
- 数据只在一个方向流动：从领导者到其他服务器。

ZooKeeper分布式协调框架

### Python装饰器

装饰器本质上是一个Python函数，它可以让其他函数在不需要做任何代码变动的前提下增加额外功能，装饰器的返回值也是一个函数对象

### 加密与安全

哈希算法、对称加密与非对称加密

**哈希算法**/摘要算法（Digest），对任意一组输入数据进行计算，得到一个**固定长度**的输出摘要。

- 主要用来**验证原始数据是否被篡改**。
- 主要有MD5（现在可破解了）、SHA算法。
- 很多文件下载时都会提供MD5，防止下载过程中被人篡改。

1. 相同的输入一定得到相同的输出；
2. 不同的输入大概率得到不同的输出。

**对称加密**就是用一个密码进行加密和解密，如DES、AES

**非对称加密**就是加密和解密使用的不是相同的密钥只有同一个**公钥-私钥对**才能正常加解密。因此，如果小明要加密一个文件发送给小红，他应该首先向小红索取她的公钥，然后，他用小红的公钥加密，把加密文件发送给小红，此文件只能由小红的私钥解开，因为小红的私钥在她自己手里，所以，除了小红，没有任何人能解开此文件。公钥和私钥是相对的，可以互相转换。如RSA

**签名算法**用私钥加密消息，其他人用公钥验证**确认是自己发出**，正好与非对称加密相反

**数字证书（Certificate Authority）**就是集合了多种密码学算法，实现了数据加解密、身份认证、签名等多种功能的一种安全标准。HTTPS就用了数字证书，建立TCP连接后，会安装服务器发来的数字证书
