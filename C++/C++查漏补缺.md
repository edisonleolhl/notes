# C++查漏补缺

## 基本语言

### 浮点数

- 无论是整型、浮点型还是字符等等数据类型在计算机底层都是以二进制的方式存储的。
- 浮点数在内存中的存储和整数不同，因为整数都可以转换为一一对应的二进制数据。而浮点数的存储是由符号位 (sign) + 指数位 (exponent) + 小数位 (fraction) 组成。
- int 和 float 同样占据四个字节的内存，但是 float 所能表示的最大值比 int 大得多，其根本原因是**浮点数在内存中是以指数的方式存储**。

浮点数转换到内存中存储的步骤分为如下三步：

1. 将浮点数转换成二进制
2. 用科学计数法表示二进制浮点数
3. 计算指数偏移后的值( float 偏移量值为 127 ，double 偏移量值为 1023)

float：1bit（符号位） 8bits（指数位） 23bits（尾数位）

double：1bit（符号位） 11bits（指数位） 52bits（尾数位）

浮点数19.625用float是如何存储的：

- 将浮点数转换成二进制：10011.101（将 19.625 整数部分采用除 2 取余，小数部分采用乘 2 取整法）；
- 用科学计数法表示二进制浮点数：1.0011101*2^4；
- 计算指数偏移后的值：127 + 4 = 131  （10000011）；
- 拼接综上所述，float 类型的 19.625 在内存中的值为：0 - 10000011 - 001 1101 0000 0000 0000 0000。

为什么要用偏移量的方式来计算指数？

如果不采用偏移量的方式：有两个 0 ，一个正 0 和一个负 0。

### 说一说const关键字

- 常量（变量or对象），值不能被更新，必须初始化
- const对象默认为文件局部变量，而非const变量默认为extern。要使const变量能够在其他文件中访问，必须在文件中显式地指定它为extern。

const与指针

- 指向常量的指针（底层指针），`const int *ptr;`
  - 不必初始化
  - 不能通过指针来修改对象的值
  - 允许把非const对象的地址赋给指向const对象的指针。
- 常指针（顶层指针），`int num=0; int * const ptr=&num;`
  - const指针必须初始化
  - 不能把一个const对象的地赋给常指针
- 指向常量的常指针，`const int p = 3; const int * const ptr = &p;`

const与函数

- 修饰函数返回值
  - `const int func1();`，无意义，因为本身函数的返回值就是个int型变量，是个临时值，在这种情况下，**不会影响重载**，编译时会报错重定义！
  - `const int* func2();`，指针指向的内容不变
  - `int *const func3();`，指针本身不可变
- 修饰函数参数
  - 常量or常指针，传递过来的参数及指针本身在函数内不可变，所以顶层const无意义

    ```c++
    void func(const int var); // 传递过来的参数不可变
    void func(int *const var); // 指针本身不可变
    ```

  - 指向常量的指针，参数指针所指内容为常量不可变，`void StringCopy(char *dst, const char *src);`，不允许修改src
  - const引用，增加效率（避免复制开销）以及防止被修改，`void func(const A &a)`

const与类

- 修饰成员函数：不会修改成员变量的成员函数都应该声明为const类型，如果不慎修改数据成员或调用其他非const成员函数，则会编译出错
- 修饰成员变量：const成员变量必须通过初始化列表进行初始化
- 修饰类对象：const对象只能访问const成员函数，而非const对象可以访问任意的成员函数，包括const成员函数
- const影响成员函数重载，可以定义一个const版本，一个非const版本

const与迭代器

- iterator可以看做是指针的一种实现，即`T*`，const iterator即为该指针为const，即`T* const`，所以it++会出错
- 如果要表示迭代器所指的内容是常量，需要用const_iterator，即`const T*`

### 说一说static关键字

1. 全局静态变量，存储在静态存储区，未经初始化的变量自动初始为0（对象的话是任意的），其他文件不可见
2. 局部静态变量，存储在静态存储区，未经初始化的变量自动初始为0（对象的话是任意的），作用域仍为局部作用域，当定义它的函数或语句块结束时，局部静态变量不销毁，而是驻留在内存中，只不过不能进行访问，当下次再进入函数或语句块时，局部静态变量的值不改变。
3. 静态函数，不能被其他文件所用，建议不要在头文件声明static全局函数，不要在cpp文件内声明非static全局函数，如果要在多个cpp文件内复用，就把声明放在头文件里面，否则cpp内部的声明需要加上static修饰
4. 类的静态成员，静态成员可以实现多个对象之间的数据共享，并且使用静态数据成员还不会破坏隐藏的原则，即保证了安全性。因此，静态成员是类的所有对象中共享的成员，而不是某个对象的成员，注意**不能在类中初始化，也不能在main函数中初始化（可以在main函数之前执行），如果类的静态成员是私有的，则要遵循私有访问限制的原则**。
5. 类的静态函数，同上，都属于类的静态成员，它们都不是对象成员。因此，对静态成员的引用不需要用对象名。在静态成员函数的实现中不能访问类的非静态成员，**可以访问类的静态成员**（这点非常重要）。如果静态成员函数中要引用非静态成员时，可通过对象来引用。从中可看出，调用静态成员函数使用如下格式：<类名>::<静态成员函数名>(<参数表>);

静态变量什么时候初始化

由于C++引入对象，对象生成必须调用构造函数，因此C++规定：**局部静态变量（一般是函数内的静态变量）在第一次使用时分配内存并初始化**，全局变量、文件域的静态变量和类的静态成员变量在main函数执行之前的静态初始化过程中分配内存并初始化

### 说一说this关键字

对于Python来说有self，类比到C++中就是this指针

- 一个对象的this指针并不是对象本身的一部分，不会影响sizeof(对象)的结果
- this作用域是在类内部，当在类的非静态成员函数中访问类的非静态成员的时候，编译器会自动将对象本身的地址作为一个隐含参数传递给函数。也就是说，即使你没有写上this指针，编译器在编译的时候也是加上this的，它作为非静态成员函数的隐含形参，对各成员的访问均通过this进行。
- 在类的非静态成员函数中返回类对象本身的时候，直接使用 return *this。
- 当参数与成员变量名相同时，如`this->n = n` （不能写成n = n)。
- this指针具体类型为：`A * const`

### 说一说volatile关键字的作用

- A situation that is volatile is likely to change suddenly and unexpectedly：被它修饰的对象出现任何情况都不要奇怪，我们不能对它们做任何假设。
- **提示编译器**紧随其后变量随时都可以变，要求每次读写这个变量时都要从内存地址读数据，而不是经过优化后，从一个暂存的寄存器中取值
- **提示编译器**不要优化
- volatile不能解决多线程中的问题
- 指针可以是 volatile
- 可以同时使用const与volatile，比如只读的状态寄存器，volatile因为它可能被意想不到地改变，const因为程序不应该试图去修改它

```c++
    const volatile int local = 10;
    int *ptr = (int*) &local;

    printf("Initial value of local : %d \n", local); // 输出10

    *ptr = 100;

    printf("Modified value of local: %d \n", local); // 若不加volatile，输出10；若加volatile，输出100

    return 0;
```

### 说一说ASSERT断言

- **ASSERT（断言）是宏**，而非函数，其作用是如果它的条件表达式为false，则终止程序执行。
- 可以通过定义 NDEBUG 来关闭 ASSERT，但是需要在源代码的开头，include 之前。
- 断言主要用于检查逻辑上不可能的情况。例如，它们可用于检查代码在开始运行之前所期望的状态，或者在运行完成后检查状态。与正常的错误处理不同，断言通常在运行时被禁用。
- ASSERT()只在debug版本有、**assert()是函数**，功能类似，可以用在release中。

```c++
# define NDEBUG
#include<assert.h>
int main(){
    int x=7;
    assert(x==5);
    return 0;
}
```

### 说一说friend友元

友元提供了一种 普通函数或者类成员函数 访问另一个类中的私有或保护成员 的机制，缺点是破坏了封装性

- 友元函数：普通函数对一个访问某个类中的私有或保护成员。定义在类外
- 友元类：类A中的成员函数访问类B中的私有或保护成员，类A为类B的友元。类B定义在类A外
- 友元关系没有继承性：假如类B是类A的友元，类C继承于类A，那么友元类B是没办法直接访问类C的私有或保护成员
- 友元关系不可传递：假如类B是类A的友元，类C是类B的友元，那么友元类C是没办法直接访问类A的私有或保护成员，也就是不存在“友元的友元”这种关系
- 友元关系的单向性：类A为类B的友元，类B不是类A的友元
- 友元声明的形式及数量不受限制

### 说一说using关键字

- 指定使用哪个作用域：可以在全局和局部作用域之间切换，`using <namespace>`
- 改变访问性：派生类私有继承了基类，它是无法访问基类的成员变量的，但如果使用using语句，可以改变访问性
- 取代typedef，给某个类型一个别名

```c++
typedef vector<int> V1;
using V2 = vector<int>;
```

### 说一说extern关键字的作用

1. extern可以置于变量或者函数前，以标示变量或者函数的定义在别的文件中，提示编译器遇到此变量和函数时在其他模块中寻找其定义。
2. 头文件中应使用extern关键字声明全局变量（不定义），比如在A.h中声明外部变量`extern int a;`，而在A.cpp文件中去定义`int a;`。如果在头文件中定义全局变量，虽然在编译阶段可能能通过，但是在链接的时候就会出现**重复定义**的错误
3. 在函数前加上`extern "C"`，告诉编译器要用C的规则去翻译函数名，因为C不支持函数重载而C++支持函数重载，所以C++会将函数名和参数联合起来生成一个中间的函数名称，也可以用`extern "C"`指定一个块，里面所有语句都按C的规则编译。C语言中不支持extern "C"声明，在.c文件中包含了extern "C"时会出现编译语法错误

### union数据类型是什么

- union是C语言里面的共用体/联合体，这些数据**共享同一段内存**，以达到节省空间的目的
- union变量所占用的内存长度等于**最长**的成员的内存长度（但需要满足最长的成员的倍数，字节对齐）
- 因为union里面的变量共享内存，所以不能使用静态、引用
- C++中使用union时，尽量保持C语言中使用union的风格，尽量不要让union带有对象
  - 默认访问控制符为 public
  - 可以含有构造函数、析构函数
  - 不能含有引用类型的成员
  - 不能继承自其他类，不能作为基类
  - 不能含有虚函数
- union可以用来测试CPU是大端模式（big endian, 所见即所得，高字节放低地址）还是小端模式（little endian, 低字节放低地址）

union字节数：

```c++
union A{
    int a[5];
    char b;
    double c;
};
sizeof(A) = ?
// 答案是24
// 最长的成员是int a[5]，所以5*4=20byte，但是需要内存字节对齐，最长的数据类型是double（8byte）
// 所以字节对齐后的字节数是24byte
```

面试题：x86机器输出什么

```c++
#include <stdio.h>
typedef union un{
 int i;
 char ch[2];
} un;
int main()
{
    un u;
    u.ch[0] = 10;
    u.ch[1] = 1;
    printf("%d", (short)u.i);   //原题没有强转为short，题是错误的，因为另外两个字节是垃圾数
    return 0;
}
```

10 相当于 0000 1010     低地址
1   相当于 0000 0001     高地址
如果是小端模式，低地址存放高位，高地址存放低位，那么该值按照正常顺序书写就是： 0000 0001 0000 1010，结果为266。
由于X86都是小端，所以在计算机上运行输出266；

### struct位域是什么

关于struct的大小：在默认情况下，为了方便对结构体内元素的访问和管理，当结构体内的元素长度都小于处理器的位数的时候，便以结构体里面**最长的元素为对其单位**，即结构体的长度一定是最长的数据元素的整数倍；如果有结构体内存长度大于处理器位数的元素，那么就以**处理器的位数为对齐单元**。

有些信息在存储时，并不需要占用一个完整的字节，而只需占**若干个二进制位**。所谓“位域”是把一个字节中的二进位划分为几个不同的区域，并说明每个区域的位数。每个域有一个域名，允许在程序中按域名进行操作。

```c++
struct bs
{
　　int a:8;
　　int b:2;
　　int c:6;
} data;
```

说明data为bs变量，共占两个字节。其中位域a占8位，位域b占2位，位域c占6位。该结构体用sizeof运算符是4（字节）

对于位域的定义尚有以下几点说明：

1. **一个位域必须存储在同一个字节**中，不能跨两个字节，若不够当前字节的剩余位，则要从下一单元开始存放
2. 由于**位域不允许跨两个字节**，因此位域的长度不能大于一个字节的长度
3. 位域可以无位域名，这时它只用来作**填充或调整位置**。无名的位域是不能使用的。

### 柔性数组

柔性数组成员（flexible array member）也叫伸缩性数组成员，这种代码结构产生于对动态结构体的需求。

- 柔性数组成员必须定义在结构体里面且为最后元素；
- 结构体中不能单独只有柔性数组成员；
- 柔性数组不占空间（不算作sizeof(struct)里面）
- 柔性数组的存储地址接在结构体地址的后面
- 如果修改柔性数组（增长长度），可能会造成后面数据丢失

```c++
struct test {
    short len;  // 必须至少有一个其它成员
    char arr[]; // 柔性数组必须是结构体最后一个成员（也可是其它类型，如：int、double、...）
};
// 申请内存
if ((softbuffer = (struct soft_buffer *)malloc(sizeof(struct soft_buffer) + sizeof(char) * CUR_LENGTH)) != NULL){
    softbuffer->len = CUR_LENGTH;
    memcpy(softbuffer->data, "softbuffer test", CUR_LENGTH);
    printf("%d, %s\n", softbuffer->len, softbuffer->data);
}
// 释放内存
free(softbuffer);
softbuffer = NULL;
```

在平时的开发会用到缓冲区，在C99标准以前，如果用定长，则会浪费空间也会浪费网络流量；如果用指针数据包，需要两次分配内存，且是不连续的。C99标准引入了柔性数组

```c++
//  定长缓冲区
struct max_buffer
{
    int   len;
    char  data[MAX_LENGTH];
};
// 内存申请：
if ((m_buffer = (struct max_buffer *)malloc(sizeof(struct max_buffer))) != NULL) {
    m_buffer->len = CUR_LENGTH;
    memcpy(m_buffer->data, "max_buffer test", CUR_LENGTH);
    printf("%d, %s\n", m_buffer->len, m_buffer->data);
}
// 内存释放：
free(m_buffer);
m_buffer = NULL;

// 指针缓冲区
struct point_buffer
{
    int   len;
    char  *data;
};
// 内存申请：
if ((p_buffer = (struct point_buffer *)malloc(sizeof(struct point_buffer))) != NULL) {  // 1. 需为结构体分配一块内存空间;
    p_buffer->len = CUR_LENGTH;
    if ((p_buffer->data = (char *)malloc(sizeof(char) * CUR_LENGTH)) != NULL) { // 2. 为结构体中的成员变量分配内存空间;
        memcpy(p_buffer->data, "point_buffer test", CUR_LENGTH);
        printf("%d, %s\n", p_buffer->len, p_buffer->data);
    }
}
// 内存释放：
free(p_buffer->data); // 1. 释放成员变量空间
free(p_buffer); // 2. 释放结构体空间
p_buffer = NULL;
```

### enum数据类型是什么

```c++
enum 枚举类型名 {枚举常量列表};

enum weekday {sun, mon, tue, wed, thu, fri, sat};// 先声明后定义
enum weekday a, b, c;

enum weekday {sun, mon, tue, wed, thu, fri, sat} a, b, c;// 同时声明定义

sun = 5; // 错误，枚举值是常量
sun = mon; // 错误，同上
a = sum; // 正确
b = mon; // 正确
a = 0; // 错误
b = 1; // 错误
a = (enum weekday)2; // 正确，强转，相当于 a = tue;


enum weather {sunny, cloudy, rainy, windy}; // 默认赋值，sunny = 0, ...
enum fruits {apple=3, orange, banana=7, bear}; // 显式赋值，每个枚举子取值是前一个加一，orange=4, bear=8
enum big_cities{guangzhou=1, shenzhen=3, beijing=1, shanghai=2}; // 枚举值取值可以重复
```

传统方法有三个特点，或者说缺点

- 会隐式转换为int
- 用来表征枚举变量的实际类型不能明确指定，从而无法支持枚举类型的前向声明
- 传统做法因为作用域不受限，可能会引起命名冲突，`enum Color {RED,BLUE};enum Feeling {EXCITED,BLUE};`，两个`Blue`冲突了，会报错

传统方法只能解决作用域不受限带来的命名冲突问题，有以下三种方法

- 所有常量统一加上不同前缀（不好）
- enum外部包裹一个命名空间（一般）
- 用struct来包裹enum枚举类（推荐）

C++11引入的枚举类可以解决所有问题

- 新的enum的作用域不在是全局的
- 不能隐式转换成其他类型
- 可以指定用特定的类型来存储enum

```c++
// enum class
enum class EntityType {
    Ground = 0,
    Human,
    Aerial,
    Total
};
void foo(EntityType entityType)
{
    if (entityType == EntityType::Ground) {
        /*code*/
    }
}
```

类中的枚举类型可以提供**所有类对象中都恒定的常量**，而const只是对于某个类对象而言是常量，该类不同的可能有不同的const变量

### nullptr与NULL的区别

NULL在C语言里是指针，C++里面是0；

```c++
#if defined(__cplusplus)  
# define NULL 0    // C++中使用0作为NULL的值  
#else  
# define NULL ((void *)0)    // C中使用((void *)0)作为NULL的值  
#endif
```

为了避免函数重载时的二义性，C++引入了nullptr

举个例子：

```c++
#include <stddef.h>  
void foo(int) {}     // #1  
void foo(char*) {}   // #2  
int main() {  
    foo(NULL); // 调用#1还是#2，会报错，error: call to 'f' is ambiguous
    foo(nullptr); // 调用#2
}
```

### 说一说四种cast转换

1. const_cast，用于将const变量转化为非const变量

2. static_cast，用于各种基础类型转换，如非const转const，void*转指针，不执行RTTI，所以安全性不如dynamic_cast

3. dynamic_cast

    `dynamic_cast<type-id>(expression)`：动态类型转换。用于父子之间的转换，**提供了运行时类型检查RTTI**，比static_cast要安全

    向上转换一定成功，只需用将子类的指针或引用赋给基类的指针或引用即可。

    向下转换检查type_info是否一致，而且必须要有虚函数，因为dynamic_cast执行RTTI

    **指针类型失败**，dynamic_cast返回0

    **引用类型失败**，则抛出bad_cast错误

4. reinterpret_cast，几乎什么都可以转，比如int转指针，但可能会出问题，尽量少用

### C++如何处理异常/构造函数、析构函数能不能抛出异常

try catch throw

1. 构造函数抛出异常，会导致析构函数不能被调用，但已经申请到的内存资源会依次调用其虚构函数

2. 类的析构函数不能抛出异常、也不应该抛出异常。

3. 如果对象在运行期间出现了异常，C++ 异常处理机制则有责任去清除那些由于出现异常而导致已经失效了的对象，并释放对象原来所分配的资源，这其实就是调用对象的析构函数来完成资源的释放任务，所以从这个意义上来讲，**析构函数已经变成了异常处理机制中的一部分**。

4. 如果在析构函数中发生了异常，极有可能导致内存泄漏。

### C++传参方式

值传递、引用传递（、指针/指针传递）

- C 和 Java 都只有一种传参方式，那就是按值传参。
- 引用传递还分为左值引用传递，右值引用传递
- 若又想避免拷贝的开销，又不想修改原数据，可以用常量引用传递（既不会拷贝、又不会修改）
- 指针传递也可以认为是值传递的一种，传递的是数据的地址

### 指针和引用的区别

1. 引用可以说是**别名**，指针有自己的**存储空间**，里面存储的是所指对象的地址
2. 引用必须**初始化**，指针不必须初始化
3. 引用初始化后**不能更改**引用的对象，指针初始化后可以更改指向的对象
4. 两者在汇编层面没有区别
5. 使用sizeof运算符看指针是4字节（32位机器）或8字节（64位机器），而用sizeof运算符看引用则取决于被引用对象的大小
6. 指针可以进行自增或自减操作，可以访问原对象相邻存储空间的内容，引用只能固定引用
7. 返回动态内存分配的对象或内存，必须用指针，用引用有可能内存泄露
8. 从面向对象的角度，引用不是对象，指针是对象

### 数组和指针的联系、区别

1. 指针是单个空间，存储的是所指对象的地址；数组可以有若干单位的空间，存储对象本身；可以有指向数组的指针，也可以有每个单元都是指针的数组
2. 指针间接访问对象，得先解引用，指针可以直接访问
3. 当指针指向数组时，可以用自增自减在数组元素上移动，但若要访问还是需要解引用
4. 当数组作为函数参数传入时，会自动变化为指针，指向数组首位
5. 不能对数组名直接复制，但可以对指针直接复制
6. 用运算符sizeof可以得到数组字节数（数组大小），但只能得到指针类型本身的字节数

```c++
void testArray(int a[]) {
    cout << *(a) << endl;   // 输出1
    cout << *(a+1) << endl; // 输出2
    cout << *(a+2) << endl; // 输出3
    cout << *(a+3) << endl; // 输出任意值
}
int a[3] = {1,2,3};
testArray(a);
```

### 函数指针

- 函数指针是指向函数的指针，声明如：`int (*p)(int a, int b);`
- 每个函数在编译时都有一个**入口地址**，这在汇编代码里面看的十分清楚，函数指针存储的就是这种入口地址的值，可以直接用函数指针调用函数
- 声明：`int (*a)();`，注意不能写成`int *a();`，否则编译器会认为一个名为a的函数的返回值是int*
- 赋值：直接将一个已经定义的函数名，赋值给函数指针就可以：`a = function;`
- 调用：`a();`，不能直接像定义一个函数一样定义一个函数指针，必须先声明，再给它赋值一个已经定义好的函数名
- 函数名传递作为函数参数时，会自动退化成一个函数指针
- 示例：精准解析，在命令行工具如sed、awk中，为了精准解析命令，在结构体里面搞一个函数指针，匹配不同参数，就找不同的函数来执行不同的功能，这比大段的ifelse优雅多了
- 示例：回调函数，如linux下的signal函数，捕捉某个信号，执行某个信号处理函数，这里要执行的信号处理函数就是用的函数指针
- 示例：反射，通过字符串直接调用函数，提高代码灵活性和扩展性，Java提供，C++本身不提供，一些类库可能会提供，比如Qt的`QMetaObject::invokeMethod("function_name");`
- C++11后多用`std::function`，可读性大大提升
- C++11可以直接用auto关键字来声明函数指针，`auto f = funcname`

```c++
int function() { // 正确的函数声明
    return 0;
}
int (*a)() { // 错误：这是一个变量，不能当函数一样定义
    return 0;
}
int main() {
    a = function;
    int (*a)(); // 声明一个函数指针变量a，
    a(); // 通过函数指针调用
    int (*b)() = function; // 直接把声明和赋值写在一起
}
```

函数指针有可能会出现很复杂的情况，循序渐进的理解一下

```c++
// 最简单的函数及其对应的函数指针：
void f();
void (*f_ptr)();
// 复杂点的，带返回值和参数列表，但都是基本类型
int f(double b, int i);
int (*f_ptr)(double b, int i);
// 返回值和参数带上指针，再加上几个const混淆一下
const double * f(const double * b2, int m);
const double * (*f_ptr)(const double * b2, int m);
// 再复杂一点点，参数里加个函数指针 也不是很复杂，基本只要把函数名换成(*函数名) 就可以了
int f(int (*fp)(),int a );
int (*f_ptr)(int (*fp)(),int a );
// 稍微再复杂一点点，返回值是一个函数指针：(光是普通函数返回函数指针，语法就有点费劲。我们一步一步来：)
//// 首先搞一个返回void的普通函数：
void f();
//// 假设返回一个函数指针，这个函数指针返回值和参数都为空。我们用一个函数指针替换掉返回值void就可以了
//// 感觉应该写成这样：void (*fp)() f();
//// 但是这个样子显然过不了编译的，得要变一下：
void (* f())();         //这就是一个参数为空，返回函数指针的函数。
void (*(*f_ptr)())();    //把f替换成(*f_ptr)，这就成了返回函数指针的函数指针。
```

这样显然太过抽象，还好我们可以用typedef关键字把函数指针简化，像普通的int double那样去操作

```c++
void (*f_ptr)(); // 这是定义了一个名为f_ptr的函数指针「变量」
typedef void (*f_ptr)(); // 这是定义了一个名为f_ptr的函数指针「类型」，这个类型代表返回值为空，参数为空的函数指针类型。

void (*fp)() = func; // 将函数名func『赋值』给fp这个函数指针
f_ptr fp = func; // 化简写法

int f(int (*fp)(), int a); // 函数参数是函数指针的写法
int f(f_ptr fp, int a); // 化简写法

void (*(*f_ptr)())() = f; // 将函数名f『赋值』给f_ptr，f_ptr是返回函数指针的函数指针
f_ptr (*ff)() = f; // 化简写法
```

再把数组扯进来

```c++
void (*f_ptr[10])();    // 定义一个长度为10的数组，数组中的元素类型是函数指针
f_ptr[3] = function;    // 每一个元素都可以指向一个函数，我们赋值给第数组中的第四个元素函数function的地址
f_ptr[3]();             // 通过数组下标拿到函数指针，通过函数指针调用函数。 这里相当于调用了function();

typedef void (*f_ptr)();
f_ptr f_tpr_arrya[10];      //把f_ptr当做一种类型后，声明函数指针数组，就可声明普通的int数组看上去没啥区别了。
f_tpr_arrya[3] = function;
f_tpr_arrya[3]();
```

类的静态成员函数指针，因为静态成员函数存储方式与普通函数一样，可以取得该函数在内存中的实际地址

- 声明：`void (*static_fptr)();`
- 调用：`static_fptr();`
- 赋值：`void (*static_fptr)() = &Test::staticFunc;`

类的成员函数指针，普通成员函数必须提供this指针

- 声明：`void (Test::*fptr)();`，类成员函数指针的声明，就必须加上类名限定，这就声明了一个函数指针变量fptr，他只能指向Test类的成员函数。
- 赋值：`fptr = &Test::function`
- 调用：类的成员函数是无法直接调用的，必须要使用对象或者对象指针调用（这样函数才能通过对象获取到this指针）。
  - `(t.*fptr)();`，t是Test类的一个实例，通过对象调用。
  - `(pt->*fptr)()`;，pt是一个指向Test类对象的指针，通过指针调用。

虚函数指针，同上，但是虚函数是面向多态的，所以基类的成员函数指针可以赋值给派生类的成员函数指针，坑很多，详见[虚函数指针揭秘](https://blog.csdn.net/ym19860303/article/details/8586971)

没法搞出**指向构造函数和析构函数的函数指针**，因为构造和析构函数不能被取地址

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

### 预处理

#### 宏定义

只是替换文本，需要加上括号，这里很容易掉入坑中，因为**先替换后计算**

```c++
// 变量case
#define N 2+9
int a = N*N; // 预期输出121
cout << a << endl; // 输出29，因为a=2+9*2+9=29，可见只是简单的替换，应更改为#define N (2+9)

// 函数case
#define area(x) x*x
int y = area(2+2); // 预期输出16
cout << y << endl; // 输出8，因为y=2+2*2+2=8

// 尝试解决函数case
#define area(x) (x)*(x)
int yy = area(2+2); // 预期输出16
cout << yy << endl; // 输出16，因为yy=(2+2)*(2+2)=16
int yyy = area(2+2)/area(2+2); // 预期输出1
cout << yyy << endl; // 输出16，因为yyy=(2+2)*(2+2)/(2+2)*(2+2)=16

// 唯一解
#define area(x) ((x)*(x))
int yyyy = area(2+2)/area(2+2); // 预期输出1
cout << yyyy << endl; // 输出1，因为yyyy=((2+2)*(2+2))/((2+2)*(2+2))
```

#### do...while(0)

用来让多行语句变成非复合语句

```c++
// do...while(0)
#define Foo(x) do {\
    statement one;\
    statement two;\
}while(0) // 没有分号

// 宏定义函数
#define Foo(x) {\
    statement one;\
    statement two;\
}

if (condition)
    Foo(x); // 如果是宏定义函数，one two有两个分号，而if没有花括号，所以会导致编译错误
else
    ...;
```

#### 条件编译

```c++
#ifdef 标识符 // 当标识符被定义过（一般用#define定义），则编译1，否则编译2，#else部分也可以没有
    程序段1
#else
    程序段2
#endif

#if 表达式 // 表达式为真，编译1
    程序段1
#else
    程序段2
#endif
```

调试代码巧用条件编译

```c++
#include <iostream>
using namespace std;
#define _DEBUG_ // 目的在于定义_DEBUG_标识符，后面写什么字符串都无所谓，甚至可以不写字符串
int main() {
    int x = 10;
#ifdef _DEBUG_
    cout << "File:"<<__FILE__<<",Line:"<<__LINE__<<",x:"<<x<<endl;
#else
    printf("x = %d\n", x);
    cout << x << endl;
#endif
    return 0;
}
```

extern "C"块与条件编译结合，在C/C++混合编程的环境，extern "C"就是告诉编译器按C编译（比如没有C++的函数重载等等），所以这种方法可以保证C/C++的兼容性

```c++
#ifdef __cplusplus
    extern "C" {
#endif

    ...

#ifdef __cplusplus
    }
#endif
```

#### 宏定义常量与const常量的区别

`#define pi 3.1415926`

1. 编译器处理阶段不同：宏定义常量在**预处理阶段**展开；const常量在编译运行阶段使用
2. 类型和安全检查不同：宏定义常量**没有类型检查**，仅仅展开；const常量有具体类型，在编译阶段执行类型检查
3. 存储方式不同：宏定义常量**不分配内存**，仅仅是展开而已；const常量会在内存中分配，
4. 常量只在类中有效只能用const，而且const数据成员只在某个对象生存期内是常量，对于整个类而言是可变的，因为类可以有多个对象，每个对象的const成员值可以不同（不能在类中初始化const数据成员）

#### 宏定义函数与内联函数的区别

`define MAX(a, b) ((a)>(b)?(a):(b))`

1. 编译器处理阶段不同：宏定义是由预处理器进行宏展开，函数内联是通过编译器来控制实现
2. 类型和安全检查不同：宏定义函数没有类型检查
3. 存储方式不同：内联函数是代码段，直接嵌入，而宏函数是简单的替换
4. 内联函数在普通函数的前面加一个关键字 inline 来标识。编译器对内联函数会在编一阶段将其展开，而不会把它当做一个函数，这大大减少了**函数调用的开销**，因为函数调用需要函数栈、压栈blabla的

添加inline关键字只是向编译器建议内联，具体是否内联还要看编译器的想法，如果函数内有循环体或switch或代码很长，则很可能不内联

添加inline必须要在定义前，只在声明前添加inline不会内联

### 定义常量/常量存放在哪

- 常量在C++里的定义就是一个 top-level const 加上对象类型，常量定义必须初始化。
- 对于**局部对象**，常量存放在栈区
- 对于**全局对象**，常量存放在全局/静态存储区
- 对于**字面值常量**，常量存放在常量存储区。

### printf和cout的区别

- cout是ostream类对象，prtinf是C语言函数
- cout有行缓冲（endl），printf没有
- cout对类型处理更加方便，printf要定义各种%s、%d，很麻烦

### 异常/noexcept关键字

[C++异常机制的实现方式和开销分析](http://baiy.cn/doc/cpp/inside_exception.htm)

- 异常处理并不意味着需要写显式的 try 和 catch。异常安全的代码，可以没有任何 try 和 catch。
- 利用好RAII是个处理异常的好方法，因为异常发生后，会自动调用析构函数
- C++处理异常，底层使用了栈回退机制
- 有些对实时性有很高要求的场景，编码规范里面就要求禁用异常，比如美国国防项目，或者有些游戏场景，但那些是很大的项目，现代编译器对于异常
- 举例：vector对于访问容器内的元素提供下标操作，如果下标超出容器范围，则会发生意想不到的额结果，所以vector提供at()方法，如果下标超出范围，则会报错，这时就是可以捕捉异常

noexcept

- 举例：vector 通常保证强异常安全性，如果元素类型没有提供一个保证不抛异常的移动构造函数，vector 通常会使用拷⻉构造函数。因此，对于拷⻉代价较高的自定义元素类型，我们应当定义移动构造函数，并标其为 noexcept，或只在容器中放置对象的智能指针。
- 如果一个函数声明了不会抛出异常、结果却抛出了异常，C++ 运行时会调用std::terminate 来终止应用程序。不管是程序员的声明，还是编译器的检查，都不会告诉你哪些函数会抛出哪些异常。

### 编译防火墙-pimpl

Pimpl(pointer to implementation, 指向实现的指针)，公有类拥有一个私有指针，该指针指向隐藏的实现类

用途：将类的private属性隐藏进一个内部类，然后通过一个指针访问（提前声明）它的接口。在头文件中只暴露出应该暴露的功能，然后持有一个Impl的指针，而Impl则具体在MyClass.cc中定义，用户什么都看不到。然后所有的功能都通过Impl完成

```c++
// 需要暴露头文件，但private数据成员与成员函数不想对外开房
// MyClass.h
class MyClass {
public:
    void func1();    
    void func2();
    
private:    
    void func3();    
    void func4();
    
    int a;
    int b;
};


// pimpl模式
class MyClass {
public:    
    void func1();
    void func2();
private:    
    class impl;    
    impl* pimpl; // 也可以通过智能指针来管理，这不是重点
};

// MyClass.cc
class MyClass::impl {
public:    
    void func1();    
    void func2();
    
private:
    void func3();    
    void func4();
    int a;    
    int b;
};

MyClass::MyClass() {
    pimpl = new impl;
}

void MyClass::func1() {    
    pimpl->func1();
}

```

优点如下：

- 降低耦合
- 信息隐藏(具体见下)
- 降低编译依赖，提高编译速度
  - C++普通的编译：如果头文件里的某些内容变更了，意味着所有引用该头文件的代码都要被重新编译，即使变更的是无法被用户类访问的私有成员。
  - 通过pimpl技术，这部分私有成员可以移到只被引用编译一次的源文件中，所以可以加快编译速度
- 接口与实现分离

最主要的缺点是，必须为你创建的每个对象分配并释放实现对象

### RAII是什么（C++的重要思想！）

RAII，也称为**资源获取就是初始化（Resource Acquisition Is Initialization**，是c++等编程语言常用的管理资源、避免内存泄露的方法。它保证在任何情况下，使用对象时先构造对象，最后析构对象。**利用对象的生命周期来管理资源**。智能指针是最具代表的技术。std::lock_gaurd也是一个例子。

C++没有严格的垃圾收集（GC）机制，而C语言又容易产生内存泄漏，所以用好RAII思想，可以避免内存泄漏

### 智能指针

#### 总体介绍

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

#### 最佳实践

- 这个对象在对象或方法内部使用时优先使用unique_ptr

- 这个对象需要被多个 Class 同时使用的时候优先使用shared_ptr

- 当出现循环引用的时候，用weak_ptr代替一个类中对其他类的shared_ptr引用

#### 错误用法

- 使用智能指针托管的对象，尽量不要再使用原生指针（容易造成二次释放）

- 不要把一个原生指针交给多个智能指针管理（会导致多次销毁）

- 尽量不要使用 get()获取原生指针

- 不要将 this 指针直接托管智能指针(造成二次释放)

- 智能指针只能管理堆对象，不能管理栈上对象（造成二次释放）

#### make_shared的优缺点

```c++
auto p = new widget();
shared_ptr sp1{ p }, sp2{ sp1 }; // 分配两次内存，异常不安全
auto sp1 = make_shared<widge>(), sp2{ sp1 }; // 分配一次内存，异常安全
```

缺点：

- 构造函数是保护或私有时,无法使用make_shared
- 对象的内存可能无法及时回收，用shared_ptr时，当强引用为0自动回收，用make_shared时，当强引用与弱引用都为0才自动回收

#### 智能指针也会发生内存泄漏吗；如果是，有什么手段避免

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

#### 手动实现引用计数型智能指针

这里简单地把引用计数设为int*，其实也可以构造一个类来代替int，在类中会有一个int成员变量

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

### move/右值/右值引用

std::move原理

- C++11引入的std::move并不能移动任何东西（可理解为“使其可移动movable”），它唯一的功能是**将一个左值引用强制转化为右值引用**，继而可以通过右值引用使用该值，以用于移动语义
- std::move是将对象的状态或者所有权从一个对象转移到另一个对象，只是**转移**，没有内存的搬迁或者内存拷贝，所以可以提高利用效率

值类别(value categories)不是值类型(value type)，表达式分为glvalue, rvalue, glvalue又分为lvalue与xvalue，rvalue又分为xvalue与prvalue

左值：能对表达式取地址、或具名对象/变量。一般指表达式结束后依然存在的**持久对象**。

- 变量、函数或数据成员的名字
- 返回左值引用的表达式，如++x、x=1、cout<< ' '
- 字符串字面值，如"hello world"，其实是`const char[N]`，在内存中有明确地址

右值：不能对表达式取地址，或匿名对象。一般指表达式结束就不再存在的**临时对象**。

- 返回非引用类型的表达式，如x++、x+1、`make_shared<int>(42)`
- 除字符串字面值之外的字面值，如42、true

将亡值与纯右值：

- xvalue是**将亡值**，可以看作**有名字的右值**
- prvalue是**纯右值**，可以看作**无名的右值**
- xvalue与prvalue都是右值rvalue

纯右值prvalue（临时对象）的生命周期

- 一个临时对象会在包含这个临时对象的完整表达式估值完成后、按生成顺序的逆序被销毁，除非有生命周期延⻓发生
- 如果一个 prvalue 被绑定到一个引用上，它的生命周期则会延⻓到跟这个引用变量一样⻓。

右值引用和左值引用的区别：

1. 左值可以寻址，而右值不可以。
2. 左值可以被赋值，右值不可以被赋值，但可以用来给左值赋值。
3. 左值可变，右值不可变

右值引用是C++11中引入的新特性, 它实现了**转移语义**和**精确传递**。右值的主要目的有两个方面：

1. **消除两个对象交互时不必要的对象拷贝**，节省运算存储资源，提高效率。
2. 能够更简洁明确地定义泛型函数。

> ++++i不会报错，i++++/++i++/会报错，因为因为**后置递增会返回一个右值**（联想一下后置递增的原理，是一个临时值），没法对一个右值再执行递增操作

### 引用折叠与完美转发

对于T&，可以肯定它就是左值引用

对于T&&，不一定它就是右值引用

- 对于`template <typename T> foo(T&&)`这样的代码，如果传递过去的参数是左值，T的推导结果是左值引用;
- 如果传递过去的参数是右值，T的推导结果是参数的类型本身。
- 如果T是左值引用，那T&&的结果仍然是左值引用⸺即type& &&坍缩成了type&。 如果T是一个实际类型，那 T&& 的结果自然就是一个右值引用。

事实上，很多标准库里的函数，连目标的参数类型都不知道，但我们仍然需要能够保持参数的值类别：**左值的仍然是左值，右值的仍然是右值**。这个功能在 C++ 标准库中已经提供了，叫std::forward。它和 std::move 一样都是利用引用坍缩/引用折叠机制来实现。

```c++
template <typename T>
void bar(T&& s){
    foo(std::forward<T>(s));
}
```

因为在 T 是模板参数时，T&& 的作用主要是保持值类别进行转发，它有个名字就叫“转发引用”(forwarding reference)。因为既可以是左值引用，也可以是右值引用，它也曾经被叫做“万能引用”(universal reference)。

### 返回值优化NRVO

在 C++11 之前，返回一个本地对象意味着这个对象会被拷⻉，除非编译器发现可以做返回值优化(named return value optimization，或 NRVO)，能把对象直接构造到调用者的栈上。

从 C++11 开始，返回值优化仍可以发生，但在没有返回值优化的情况下，编译器将试图把本地对象移动出去，而不是拷⻉出去。这一行为不需要程序员手工用 std::move 进行干预⸺使用std::move 对于移动行为没有帮助，反而会影响返回值优化。

所以可以考虑在函数返回中返回对象而不是引用

### std::bind与std::ref(C++11起)

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

考虑到函数式编程（如std::bind）在使用时，是对参数直接拷贝，而不是引用。所以引入std::ref对对象施加引用

### 函数对象/lambda表达式

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

mutable标记使捕获的内容可更改(缺省不可更改捕获的值，相当于定义了`operator()(...) const)`

### 匿名函数的捕获

值捕获是不改变原有变量的值，引用捕获是可以在Lambda表达式中**改变原有变量的值**，而且避免复制的开销

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

auto关键字：编译器根据初始值自动推导出类型，但是不能用于函数传参以及数组类型的推导，这是编译器在**编译阶段**完成的，没有改变C++是静态语言的事实。

- auto 是值类型
- auto& 是左值引用类型
- auto&& 是转发引用(可以是左值引用，也可以是右值引用)
- 但如果想根据表达式获得对应的值类别，C++14可以使用`decltype(auto) a = expr;`，之前只能使用啰嗦地`decltyp(expr) a = expr;`

nullptr：一种特殊的空指针类型，能转换成其他任意类型的指针，而NULL一般被宏定义为0，遇到重载时可能会出现问题

decltype：查询表达式的类型，不会对表达式求值，经常与auto配合追踪函数的返回值类型

no except：对于某个函数，保证不抛出异常，可以给编译器更大的优化空间。

基于范围的for循环: `for(auto &v : vec){...}`

初始化列表：使用初始化列表来对类进行初始化，initializer_list

类成员默认初始化，`class A int m_data{0}; ...}`

constexpr，constexpr表示编译期常量，const用来表示一个运行时常量

匿名函数 Lambda: `[capture list] (params list) mutable exception-> return type { function body }`，值捕获、引用捕获、隐式捕获

智能指针：新增了shared_ptr、unique_ptr、weak_ptr，用于解决内存管理的问题

可变参数模板：对参数进行了高度泛化，能表示0到任意个数、任意类型的参数，`template <class... T> void f(T... args);`

右值引用：基于右值引用可以实现移动语义和完美转发，消除两个对象交互时不必要的对象拷贝，节省运算存储资源，提高效率

新增正则表达式库

新增STL容器array以及tuple

新增自定义字面量，以前只能是原生类型的字面值常量，现在可以用operator""后缀

### C++20有什么新特性

Concepts，概念，对模板进行约束

Coroutine，协程，协作式的交叉调度执行，场景：生成器、异步I/O、惰性求值、事件驱动应用

Ranges，范围，不用begin()与end()来包围了

目的是使C++语言对于开发者友好，开发者可以把更多的经历投入到其他开发领域去，而不是纠结编写晦涩难懂的或者是炫技般的C++代码

### 基本误区

[C++编程新手容易犯的 10 种编程错误](https://mp.weixin.qq.com/s/tiA57wnvWeE-rO3IyWf_Hg)

1. 有些关键字在 cpp 文件中多写了，比如 virtual. static 等
2. 函数参数的默认值写到函数实现中了，为了方便看代码，可以在函数实现中用注释
 ```c++
 BOOL CreateConf( const CString& strConfName, const BOOL bAudio = FALSE );
 在函数实现处的参数中不用添加默认值：
 BOOL CreateConf( const CString& strConfName, const BOOL bAudio/* = FALSE*/ );
 {
     // ......
 }
 ```
3. 在编写类的时候，在类的结尾处忘记添加 ";" 分号了
4. 只添加了函数声明，没有函数实现，链接时会报unresolved external symbol错误
5. cpp 文件忘记添加到工程中，导致没有生成供链接使用的 obj 文件，也会报unresolved external symbol错误
6. 函数中返回了一个局部变量的地址或者引用
7. 忘记将父类中的接口声明 virtual 函数，导致多态没有生效
8. 该使用双指针的地方，却使用了单指针，二级指针又叫双指针。C语言中不存在引用，所以当你试图改变一个指针的值的时候必须使用二级指针。而C++中可以使用引用类型来实现。
9. 发布 exe 程序时，忘记将 exe 依赖的 C 运行时库和 MFC 库带上
10. 应该使用深拷贝，却使用了浅拷贝


## 类和数据抽象

### struct和class的区别

struct与class一样，可以包括成员函数，可以实现继承，可以实现多态。不同点在于

1. 默认的继承访问权。class默认的是private，struct默认的是public，继承访问权取决于子类而不是基类，比如struct继承class则默认是public继承
2. 默认访问权限：struct作为数据结构的实现体，它默认的成员访问控制是public的，而class作为对象的实现体，它默认的成员变量访问控制是private的。
3. “class”这个关键字还用于定义模板参数，就像“typename”。但关建字“struct”不用于定义模板参数

最好的建议就是：当你觉得你要做的更像是一种数据结构的话，那么用struct，如果你要做的更像是一种对象的话，那么用class。

对于C语言，struct就是个数据结构，里面没有访问修饰符，不能有函数，没有继承，

### C++中类的成员访问限定符

分为private、public、protected，控制成员变量和成员函数的访问权限，C++类本身没有公私之分

在类的内部（定义类的代码内部），无论成员被声明为 public、protected 还是 private，都是可以互相访问的，没有访问权限的限制。

在类的外部（定义类的代码之外），只能通过对象访问成员，并且通过对象只能访问 public 属性的成员，不能访问 private、protected 属性的成员，但是protected属性的成员在派生类内部可以访问

### C++中的三种继承方式

继承方式是为了控制子类(也称派生类)的调用方(也叫用户)对父类(也称基类)的访问权限。

1. 使用private继承,父类的所有方法在子类中变为private;
2. 使用protected继承,父类的protected和public方法在子类中变为protected，private方法不变;
3. 使用public继承,父类中的方法属性不发生改变;

### C++中继承和组合的区别

“继承”特性可以提高程序的可复用性，但是需要防止乱用

- 如果类A与类B毫不相关，不能让类B拥有更多功能而继承类A
- 如果类B有必要使用类A的功能，则要分两种情况讨论
  - B是A的一种（a kind of）：允许继承
  - A是B的一部分（a part of）：不允许继承，只能**组合**

### 重载、重写与重定义

重载（overload）：同范围内，多个同名函数之间的一种关系，需满足：这些同名函数在参数列表上有所不同（个数、类型、顺序），调用函数时，编译器会选择匹配的函数执行，仅有返回值不同的两个同名函数不能重载，const和非const也可以重载，

重写/覆盖（override）：发生在子类继承父类的情况下，被重写函数不能static，**必须虚函数**，重写函数必须有相同的类型、名称、参数列表，访问修饰符不必相同

重定义/隐藏（redefining)：子类隐藏了父类的同名函数，其规则如下

- 如果派生类的函数与基类的函数同名，但是参数不同。此时，不论有无virtual关键字，基类的函数将被隐藏（注意别与重载混淆，仅同名就可以）。
- 如果派生类的函数与基类的函数同名，并且参数也相同，但是基类函数没有virtual 关键字。此时，基类的函数被隐藏（注意别与覆盖混淆）

### C++11的final与override

- 这两个不是关键字，而是说明符，我们也可以取相同名字的变量
- 把类声明为final，可以防止该类被继承（继承时编译出错），把基类的成员函数声明为final，可以防止该成员函数被重载（重载时会编译出错）

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

    // 另一个文件
    struct Base final
    {
    };

    struct Derived : public Base // 编译出错，Base已被声明为final
    {
    };
    ```

- C++重写还有个特点，父类声明的虚函数，**子类都不需要声明virtual**，而且还可以“跨层”，没有在父类声明的接口可能是祖先的虚函数接口，这就为阅读带来了障碍。所以C++11引入了override关键字，如果派生类在虚函数声明时使用了override，则该函数必须重写父类的虚函数，如果没有重写，或者重写的不是虚函数，则编译出错

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

### 子类如何执行覆写后的父类方法

```c++
#include <stdio.h>

class A{
public:
    void func() {
        printf("a func");
    }
};
class B : public A{
public:
     void func() {
        printf("b func");
    }
};
int main () {
    A *a = new B;
    a->func();
}
```

### 对象切片是什么

函数声明的返回值是基类对象，但是返回的是派生类对象，虽然不会报错，但是对象会被**切片（sliced）**，这不是编码错误，而是一种语义错误，是C++特有的一个陷阱

在函数传参处理多态性时，如果一个派生类对象在UpCasting时，用的是传值的方式，而不是指针和引用，那么，这个派生类对象在UpCasting以后，将会被slice（切分）成基类对象，也就是说，**派生类中独有的成员变量和方法都被slice掉了**，只剩下和基类相同的成员变量和属性。这个派生类对象被切成了一个基类对象。

有个很好的方法能防止对象切片带来的潜在危害，那就是把基类的某个成员函数声明为**纯虚函数**，因为纯虚函数不能实例化，所以对象切片后，尝试得到一个基类对象，这时会报错

### 用C模拟出C++的多态

C++三大特性：封装、继承、多态，都需要C模拟

- 封装：C语言中是没有class类这个概念的，但是有struct结构体，我们可以考虑使用struct来模拟；使用函数指针把属性与方法封装到结构体中。
- 继承：结构体嵌套即可
- 多态：在C语言的结构体内部是没有成员函数，但可以用函数指针来模拟，但有一个缺点：父子各自的函数指针之间指向的不是类似C++中维护的虚函数表，而是一块物理内存，如果模拟的函数过多的话就会不容易维护了

### 虚函数

1. 多态，是指在继承层次中，父类的指针可以具有多种形态，当它指向某个子类对象时，通过它能够调用到子类的函数（必须是重写本父类的虚函数），而非父类的函数
2. 每一个具有虚函数的类都有一个虚函数表，里面按在类中声明的虚函数的顺序存放着虚函数的地址，这个虚函数表是这个类的所有对象所共有的，只有一个。
3. 虚函数表只是编译器在编译时设置的**静态数组**。虚拟表包含可由类的对象调用的每个虚函数的一个条目。此表中的每个条目只是一个**函数指针**，指向该类可访问的**最派生**函数。
4. 为每个有虚函数的类插入一个指针（vptr），这个指针指向该类的虚函数表，一般为了效率考虑，指针位于该类的头部
5. 子类继承父类时也会继承虚函数表/虚函数指针（都是新的），但是当子类**重写**继承的虚函数时，子类的虚函数表中的对应虚函数地址会**替换**为重写的虚函数地址。
6. 如果有多继承，子类的vfptr虚函数指针不止一个，虚函数表也不止一个，子类自己定义的虚函数会放在继承自第一个（按照继承声明顺序）父类的虚函数表后面，若重写多个父类的同名虚函数，则继承自对应父类的虚函数表也会修改
7. **默认参数是静态绑定的**，虚函数是动态绑定的。默认参数的使用需要看指针或者引用本身的类型，而不是对象的类型，即不会体现多态性。
8. 虚函数可以是私有的，但是必须在在类中声明`friend int main();`

### 纯虚函数是什么

- 纯虚函数是在基类中声明的虚函数，它在基类中没有定义，但要求任何派生类都要对于这个同名函数定义自己的实现方法（重写）。
- 在基类中实现纯虚函数的方法是在函数原型后加“=0”，`virtual void funtion1()=0`
- 定义纯虚函数的目的在于，使派生类仅仅只是继承函数的接口，
- 包含纯虚函数的类就是抽象类
- 派生类如果不覆盖纯虚函数，那么派生类也是抽象类

### 虚继承/菱形继承

- 虚继承（Virtual Inheritance）/虚基类解决了从不同途径继承来的同名的数据成员在内存中有不同的拷贝造成数据不一致问题，将共同基类设置为虚基类。这时从不同的路径继承过来的同名数据成员在内存中就只有一个拷贝，同一个函数名也只有一个映射
- 当在多条继承路径上有一个公共的基类，在这些路径中的某几条汇合处，这个公共的基类就会产生多个实例(或多个副本)，若只想保存这个基类的一个实例，可以将这个公共基类说明为虚基类。
- 虚继承一般通过**vbptr虚基类指针**和vb虚基类表实现，每个虚继承的子类都有一个虚基类指针（占用一个指针的存储空间，放在虚函数表指针的后面，如果没有虚函数表指针，那就放在类实例的头部）和虚基类表（不占用类对象的存储空间）；当虚继承的子类被当做父类继承时，虚基类指针也会被继承。
- 解决了二义性问题，解决了钻石继承/菱形继承/重复继承问题，也节省了内存，避免了数据不一致的问题。

### 为什么虚函数表中有两个析构函数

虚函数表中有两个析构函数，一个标志为deleting，一个标志为complete，因为对象有两种构造方式，**栈构造和堆构造**，所以对应的实现上，对象也有两种析构方式，其中堆上对象的析构和栈上对象的析构不同之处在于，栈内存的析构不需要执行 delete 函数，会自动被回收。

### 构造函数/析构函数的执行顺序

- 首先执行**虚基类的构造函数**，多个虚基类的构造函数按照被继承的顺序构造（若没有虚基类，则略过这条）；
- 执行**基类成员对象的构造函数**，多个成员对象的构造函数按照声明的顺序构造；
- 执行**基类的构造函数**，多个基类的构造函数按照被继承的顺序构造；
- **初始化vptr**；
- 执行**派生类成员对象的构造函数**，多个成员对象的构造函数按照声明的顺序构造；
- 执行**派生类自己的构造函数**，数据成员的初始化顺序按照它们在类中声明的顺序（见下一条笔记）

析构以与构造**相反顺序**执行

### 初始化列表成员初始化顺序

- const成员的初始化只能在构造函数初始化列表中进行
- 引用成员的初始化也只能在构造函数初始化列表中进行
  - 因此不能用默认的构造函数，必须自己设计构造函数
  - 且构造函数**的形参必须为引用类型**，引用型数据成员必须在**初始化列表**里初始化，不能在函数体里初始化，因为在函数体内修改引用型数据成员，相当于赋值，而**引用不能赋值**
- 对象成员（对象成员所对应的类没有默认构造函数）的初始化，也只能在构造函数初始化列表中进行
- 类成员是按照它们在类里被声明的顺序进行初始化的，**和它们在成员初始化列表中列出的顺序没一点关系**。
- 对一个对象的所有成员来说，它们的**析构函数**被调用的顺序总是和它们在构造函数里被创建的**顺序相反**。
- 类如果有类对象成员，则初始化列表里会调用类对象成员的拷贝构造函数，而不是拷贝赋值函数
- 构造函数的函数体中**都是赋值，而不是初始化**

```c++
class A{
    int a;
    string b;
    A(const int aa, const string &bb): a(aa), b(bb) {} // 调用一次拷贝构造函数即可
};
class A{
    int a;
    string b;
    A(const int aa, const string &bb) {
        a = aa;
        b = bb; // 先调用default构造函数，再调用拷贝赋值函数
    }
};
```

### C++虚函数的内存模型

[《深度探索C++对象模型》笔记汇总](http://www.roading.org/develop/cpp/%E3%80%8A%E6%B7%B1%E5%BA%A6%E6%8E%A2%E7%B4%A2c%E5%AF%B9%E8%B1%A1%E6%A8%A1%E5%9E%8B%E3%80%8B%E7%AC%94%E8%AE%B0%E6%B1%87%E6%80%BB.html)

[图说C++对��模型：对象内存布局详解](https://www.cnblogs.com/QG-whz/p/4909359.html)、[C++ 虚函数详解（虚函数表、vfptr）——带虚函数表的内存分布图](https://blog.csdn.net/anlian523/article/details/90083205)

假设A是一个有虚函数的类，定义`A* obj = new A;`，则：

1. 对象指针obj位于栈区（结束自动收回）
2. A对象实例存放于堆区（必须要显式new和delete，结束不自动收回），虚函数表指针就在A对象实例的头部，指向虚函数表（这是为了在继承时最高效率获取到虚函数表）
3. Linux/Unix将虚函数表存储于只读数据段(.rodata)。虚函数指针存在于虚函数表里面，指向虚函数的地址。
4. 虚函数代码存在于代码段/代码区(.text)中

![C++查漏补缺-20200110160457.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/C%2B%2B%E6%9F%A5%E6%BC%8F%E8%A1%A5%E7%BC%BA-20200110160457.png)

```c++
typedef void (*Fun)();

class Base
{
    public:
        Base(){};
        virtual void fun1()
        {
            cout << "Base::fun1()" << endl;
        }
        virtual void fun2()
        {
            cout << "Base::fun2()" << endl;
        }
        virtual void fun3(){}
        ~Base(){};
};

class Derived: public Base
{
    public:
        Derived(){};
        void fun1()
        {
            cout << "Derived::fun1()" << endl;
        }
        void fun2()
        {
            cout << "DerivedClass::fun2()" << endl;
        }
        ~Derived(){};
};
/**
 * 获取vptr地址与func地址,vptr指向的是一块内存，这块内存存放的是虚函数地址，这块内存就是我们所说的虚表
 */
Fun getAddr(void* obj,unsigned int offset)
{
    cout<<"======================="<<endl;
    void* vptr_addr = (void *)*(unsigned long *)obj;  //64位操作系统，占8字节，通过*(unsigned long *)obj取出前8字节，即vptr指针
    printf("vptr_addr:%p\n",vptr_addr);

    /**
     * 通过vptr指针访问virtual table，因为虚表中每个元素(虚函数指针)在64位编译器下是8个字节，因此通过*(unsigned long *)vptr_addr取出前8字节，
     * 后面加上偏移量就是每个函数的地址！
     */
    void* func_addr = (void *)*((unsigned long *)vptr_addr+offset);
    printf("func_addr:%p\n",func_addr);
    return (Fun)func_addr;
}
int main(void)
{
    Base ptr;
    Derived d;
    Base *pt = new Derived(); // 基类指针指向派生类实例
    Base &pp = ptr; // 基类引用指向基类实例
    Base &p = d; // 基类引用指向派生类实例
    cout<<"基类对象直接调用"<<endl;
    ptr.fun1();
    cout<<"基类对象调用基类实例"<<endl;
    pp.fun1();
    cout<<"基类指针指向派生类实例并调用虚函数"<<endl;
    pt->fun1();
    cout<<"基类引用指向派生类实例并调用虚函数"<<endl;
    p.fun1();

    // 手动查找vptr 和 vtable
    Fun f1 = getAddr(pt, 0);
    (*f1)();
    Fun f2 = getAddr(pt, 1);
    (*f2)();
    delete pt;
    return 0;
}
```

运行结果：

```shell
基类对象直接调用
Base::fun1()
基类引用指向派生类实例
Base::fun1()
基类指针指向派生类实例并调用虚函数
Derived::fun1()
基类引用指向基类实例并调用虚函数
Derived::fun1()
=======================
vptr_addr:0x401130
func_addr:0x400ea8
Derived::fun1()
=======================
vptr_addr:0x401130
func_addr:0x400ed4
DerivedClass::fun2()
```

### sizeof(类对象)/字节对齐

类型对齐方式（变量存放的起始地址相对于结构的起始地址的偏移量）

- Char 偏移量必须为sizeof(char)即1的倍数
- int 偏移量必须为sizeof(int)即4的倍数
- float 偏移量必须为sizeof(float)即4的倍数
- double 偏移量必须为sizeof(double)即8的倍数
- Short 偏移量必须为sizeof(short)即2的倍数

各成员变量在存放的时候根据在结构中出现的顺序依次申请空间，同时按照上面的对齐方式调整位置，空缺的字节编译器会自动填充，最后在根据最大空间类型所占类型自动填充末尾的空间，比如计算完了之后是21字节，但是内部有duoble（占8字节），所以末尾填充3个字节，得到24字节。可以通过`#pragma pack(n)`告知编译器字节对齐的大小

```c++
struct s
{
    int a;
    double d;
    short b; // 占两个字节
    char c;
}; // sizeof(s) == 24
struct s
{
    int a;
    short b;
    char c;
    double d;
}; // sizeof(s) == 16
struct s
{
    char c;
    int a;
    short b;
    double d;
}; // sizeof(s) == 24
struct Obj {
    char a;
    uint32_t b;
    uint8_t c;
    uint64_t d[0];
};
// sizeof(Obj) = 16
// 如果没有第四个字段，应该是4+4+4=12，加上第四个字段是16，第四个字段不占空间，但会告诉编译器要按8字节对齐
//这种用法在内核里经常用到，比如下面可以直接用下标访问
Obj o1;
uint64_t array[1024]; // 在内存中，array紧跟o1后面
o1.d[123]; // 可以访问array的元素
```

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

- sizeof(b)=1：编译器为空类安插1字节的char，使该类对象**在内存配置一个地址**，这样两个类对象的地址就是不同的，若两个类对象地址相同，则指针与引用会使它们混乱
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

- 内联函数在编译时就会展开函数体，而虚函数在运行时才有实体，**但是使用了不会报错，只是虚函数不会有多态性**

- 编译器需要在编译时确定虚函数表大小，而模板可能会有多个实例化，如果模板成员函数为虚函数，那会造成虚函数表大小不确定

### 为什么析构函数必须是虚函数；为什么C++默认的析构函数不是虚函数

如果基类的析构函数不是虚的，那么以一个基类指针指向其派生类，删除这个基类指针**只能删除基类对象部分**，而不能删除整个派生类对象。

如果基类的析构函数是虚的，那么派生类的析构函数也必然是虚的，删除基类指针时，它就会**通过虚函数表找到正确的派生类析构函数**并调用它，从而正确析构整个派生类对象。

C++默认的析构函数不是虚函数，是因为虚函数需要额外的虚函数表和虚表指针，占用额外的内存。而对于不会被继承的类来说，其析构函数如果是虚函数，就会**浪费内存**。因此C++默认的析构函数不是虚函数，而是只有当需要当作父类时，设置为虚函数。

### 构造/析构函数可以调用虚函数吗

可以，但没法达到预期效果，因为这时调用的虚函数是基类对象的实体，不是派生类对象的实体

由于类的构造顺序是先基类再派生类，所以在基类的构造函数中调用虚函数，派生类还没构造，所以没法呈现多态性

由于类的析构顺序是先派生类再基类，所以在在基类的析构函数中调用虚函数，派生类已经析构完了，所以没法呈现多态性

### 为什么重载流操作符时用友元函数

- 如果把重载流操作符定义为成员函数，那么只能通过`complex1.operator<<(complex2)`这样去调用，这都没法与istream与ostream连接起来。
- 因为流操作符左侧必须为cin或cout，即istream或ostream类，不是我们所能修改的类；或者说因为流操作符具有方向性。
- 而流操作符又需要访问类的私有成员，所以得用友元函数，然后在类外重载。

典型用法：

```c++
class complex{
public:
    complex(int x, int y): real(x), imag(y){}
    complex():complex(0,0){}
    ~complex(){}
    friend ostream& operator << (ostream& cout, complex& par)；
private:
    int real;
    int imag;
}
ostream& operator << (ostream& cout, complex& par)；{
    cout << par.real << "+" << par.imag << "i" << endl;
    return cout;
}
```

但是使用友元函数会**破坏类的封装性**，因此好的解决方法是：使用一些成员函数来暴露对类成员的访问，然后使用类外的普通函数重载来进行类成员的输入输出。

```c++
class complex{
public:
    complex(int x, int y): real(x), imag(y){}
    complex():complex(0,0){}
    ~complex(){}
    int getReal(){ return real;}
    int getImag(){ return imag;}
    void setReal(int parm){ real = parm;}
    void setImag(int parm){ imag = parm;}
private:
    int real;
    int imag;
}
ostream& operator << (ostream& cout, complex& par){
    cout << par.getReal() << " + " << par.getImag() << "i" << endl;
    return cout;
}
```

### 模板元编程(Template Meta Programming)

- 利用模板来编写那些在编译时运行的C++程序，又称编译器计算
- 要进行编译期编程，最主要的一点，是需要把计算转变成类型推导
- 模板分为函数模板与类模板两类。
- 模板实例化(instantiation)：具体类型代替模板参数的过程。
- 模板参数推导/推演(deduction)：由模板实参类型确定模板形参的过程。
- std::enable_if，经常用于偏特化中
- SFINAE：模板实例化失败不是错误，进行决议的时候，总会去选择那个正确的模板，避免失败，注意这里的失败仅指函数模板的原型声明，即参数和返回值，如果函数体的在实例化的过程中出错，仍然会得到一个编译错误

```c++
template <int n>
struct factorial {
    static const int value =
        n * factorial<n - 1>::value;
};
template <>
struct factorial<0> {
    static const int value = 1;
};
```

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

### 模板的实例化时机/重载决议

- 模板只有在被使用到才会实例化
- 对于一个实例化后的模板来说，成员函数只有在被使用时才会实例化
- 这都是出于时间和空间效率考虑的

函数模板的重载决议

- 根据名称找出所有适用的函数和函数模板
- 对于适用的函数模板，要根据实际情况对模板形参进行替换；替换过程中如果发生错误，这个模板会被丢弃
- 在上面两步生成的可行函数集合中，编译器会寻找一个最佳匹配，产生对该函数的调用
- 如果没有找到最佳匹配，或者找到多个匹配程度相当的函数，则编译器需要报错

### 可变参数怎么实现

C语言提供了可变参数var_list，在printf函数中有应用，其实是利用了函数压栈从后往前的特点，以**保证第一个参数在栈顶**。

C++11提供了可变参数模板/可变模板

- 用于在通用工具模板中转发参数到另外一个函数
- 用于在递归的模板中表达通用的情况(另外会有至少一个模板特化来表达边界情况)

```c++
template <typename T, typename... Args>
inline unique_ptr<T> make_unique(Args&&... args) {
    return unique_ptr<T>(
        new T(forward<Args>(args)...));
}
```

- `typename... Args`声明了一系列的类型⸺class...或typename...表示后面的标识符代表了一系列的类型。
- `Args&&... args`声明了一系列的形参args，其类型是Args&&。
- `forward<Args>(args)...`会在编译时实际逐项展开 Args 和 args ，参数有多少项，展开后就是多少项。

展开包中的参数比较麻烦，主要有递归展开和逗号表达式展开两种方法

递归展开（可用于编译器递归）

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

大牛的建议：**对函数使用重载，对类模板进行特化**

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

### 定义一个不能被拷贝的类

老派做法：拷贝构造与拷贝赋值定义为private

```c++
class noncopyable  
{  
protected:  
    noncopyable() {}  
    ~noncopyable() {}  
private:  
    noncopyable( const noncopyable& );  
    noncopyable& operator=( const noncopyable& );  
};
```

C++11做法：拷贝构造与拷贝赋值定义为=delete

```c++
class noncopyable  
{  
protected:  
    //constexpr noncopyable() = default;  
   // ~noncopyable() = default;  
    noncopyable( const noncopyable& ) = delete;  
    noncopyable& operator=( const noncopyable& ) = delete;  
};  
```

boost::noncopyable在muduo网络库中经常使用，它是老派做法，如果想定义一个不可被拷贝的类，只需继承boost::noncopyable即可，因为想要拷贝派生类，得先调用基类的拷贝函数（拷贝赋值、拷贝构造）

### 定义一个不能被继承的类

最简单的方式：把它的构造函数和析构函数都定义为私有函数。

那么当一个类试图从它那继承的时候，必然会由于试图调用构造函数、析构函数而导例致编译错误。

但是这样的话，通过private的构造函数与析构函数无法得到该类的实例。我们可以对外提供一个公有的静态函数来创建和释放类的实例（有点像单例模式的做法），但是这样就只能在堆上创建对象，而不能在栈上创建对象（这也是“定义一个只能在栈上创建对象的类”的解答之一）。

C++11前最好的方法：

- 定义一个私有构造与析构的基类MakeFinal，其中声明FinalClass为友元（FinalClass就可以使用MakeFinal的私有构造函数和析构函数）
- FinalClass虚继承MakeFinal
  - 虚继承迫使虚基类的任何层次的子孙都要**先调用虚基类的构造函数**
  - 如果某个类试图继承FinalClass，编译不会报错，在创建该类实例时，因为虚继承，会先调用MakeFinal的构造函数，而它是私有的，所以会运行报错，这样的FinalClass就是不能继承的类
  - FinalClass的构造和析构是public的，可以在堆或栈上构造

C++11提供的final关键字

- 用来修饰成员函数，则该成员函数不能被重写，否则会报错
- 用来修饰类，则该类不能被继承，否则会报错，可以在继承体系中间的类加入final关键字

```c++
struct Base final
{
};

struct Derived : public Base // 编译报错，Base被声明为final了
{
};
```

### 定义一个只能在堆/栈上创建的类

定义一个只能在堆上创建的类

- 将析构函数设为private，类对象就无法建立在栈上了。
- 类对象只能创建在堆上，就是**不能静态创建类对象**，即**不能直接调用类的构造函数**，即`A a;`时会报错
- 因为当对象建立在栈上面时，是由编译器分配内存空间的，调用构造函数来构造栈对象。当对象使用完后，编译器会调用析构函数来释放栈对象所占的空间。编译器管理了对象的整个生命周期，如果析构函数是私有的，则编译器无法调用析构函数，所以类对象无法在栈上创建。
- 如果将析构函数设为protected，则解决了private不能继承的问题。因为protected，编译器无法调用析构函数，但是子类可以调用基类的析构函数

定义一个只能在栈上创建的类

仅当使用new运算符，对象才会建立在堆上。因此，只要禁用new运算符就可以实现类对象只能建立在栈上。将operator new()设为私有即可，即`A* a = new A;`会报错

## 内存分配/编译/底层

### Linux虚拟地址空间

Linux 使用虚拟地址空间，大大增加了进程的寻址空间，由高地址到低地址分别为：

- 内核虚拟空间（内核态）：用户代码不可见的内存区域，由内核管理(页表就存放在内核虚拟空间)。
- 栈：用于维护函数调用的上下文空间，堆的末端由break指针标识，当堆管理器需要更多内存时，可通过系统调用brk()和sbrk()来移动break指针以扩张堆，一般由系统自动调用。
- 内存映射区域（mmap）：内核将硬盘文件的内容直接映射到内存，一般是mmap系统调用所分配的，当malloc超过128KB时，不在堆上分配内存，而在内存映射区分配内存，既可以用于装载动态库，也可以用于匿名内存映射，没有指定文件，所以可以用来存放数据
- 堆：就是平时所说的动态内存， malloc/new 大部分都来源于此。其中堆顶的位置可通过函数brk和sbrk进行动态调整。
- BSS段（.bss）：未初始化的全局变量或者静态局部变量
- 数据段（.data）：已初始化的全局变量或静态局部变量
- 代码段（.text）：保存代码（CPU执行的机器码）

![linuxprocessmemory](../image/linuxprocessmemory.png)

32位OS的虚拟地址空间为32位即4GB，用户空间占3GB，内核空间占1GB

64位OS的虚拟地址空间为48位即256T，用户空间占128T

### C++内存分配（管理）方式

[C++ 自由存储区是否等价于堆？](https://www.cnblogs.com/qg-whz/p/5060894.html)

栈：就是那些由编译器在需要的时候分配，在不需要的时候自动清除的变量的存储区。里面的变量通常是局部变量、函数参数等。在一个进程中，位于用户虚拟地址空间顶部的是用户栈，编译器用它来实现函数的调用。操作方式类似于数据结构里的栈。向下增长。

堆：malloc在堆上分配的内存块，使用free释放内存。如果程序员没有释放掉，那么在程序结束后，操作系统会自动回收。操作方式类似于数据结构里的链表。向上增长。可以说堆是操作系统维护的一块内存（物理上的）。

自由存储区（C++特有概念）：new所申请的内存则是在自由存储区上，使用delete来释放。自由存储区是C++通过new与delete动态分配和释放对象的抽象概念（逻辑上的），有可能是由堆实现的，可以说new所申请的内存在堆上（这点和很多网络上的文章不一致，本人选择与上面的博客文章一致，在极客时间现代C++实战30讲中也是这样的观点）

全局/静态存储区：全局变量和静态变量的存储是放在一块的，**初始化**的全局变量和静态变量在一块区域，**未初始化**的全局变量和未初始化的静态变量在相邻的另一块区域。程序结束后由系统释放。

常量存储区：存放字面值常量（如字符串常量），不建议修改，程序结束后由系统释放。

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

### malloc/calloc/free/realloc

堆的管理：堆分为映射区(mapped region)和未映射区(unmapped region)，从堆开始的地方~break指针为映射区（通过MMU映射虚拟地址到物理地址），break往上是未映射区。当映射区不够时，break指针上移，扩大映射区，但是不能无限扩大，有rlimit限制。

`void *malloc(size_t size)`在堆区分配一块大小为至少为size（可能要字节对齐）的连续内存，返回指向这块**未初始化**内存的起始位置的指针，分配失败返回NULL

- malloc函数用于动态分配内存。为了减少内存碎片和系统调用的开销，malloc其采用**内存池**的方式，先申请大块内存作为堆区，然后将堆区分为多个内存块（block），以块作为内存管理的基本单位。当用户申请内存时，直接从堆区分配一块合适的空闲块。
- malloc采用隐式链表结构将堆区分成连续的、大小不一的块，包含已分配块和未分配块；同时malloc采用**双向链表来管理所有的空闲块**，双向链表将空闲块连接起来，每一个空闲块记录了一个连续的、未分配的地址。
- malloc在申请内存时，一般会通过brk或者mmap系统调用进行申请。其中当申请内存小于128K时，会使用系统调用**brk在堆区**中分配；而当申请内存大于128K时，会使用系统调用**mmap在内存映射区**分配。mmap有一种用法是映射磁盘文件到内存中（进程间通信），如果是匿名映射，就不指定磁盘文件，也就相当于开辟了一块内存。

`void *calloc(size_t numitems, size_t size)`给一组对象分配内存并且**初始化为0**，底层会调用malloc

`void *free(void *p)`验证传入地址是否有效（是否是malloc开辟的），然后合并空闲的相邻内存块

`void *realloc(void *ptr, size_t size)`调整（通常是增加）一块内存的大小，若增加了已分配内存块大小，则额外内存是未初始化的，并且调整内存大小要考虑内存块block的关系，有可能需要分裂内存块split block，也有可能需要合并后面的空闲块，还有可能调用malloc重新分配再复制

### malloc最多能分配多少内存

[malloc最多能分配多少内存](http://fallincode.com/blog/2020/01/malloc%E6%9C%80%E5%A4%9A%E8%83%BD%E5%88%86%E9%85%8D%E5%A4%9A%E5%B0%91%E5%86%85%E5%AD%98/)

一次malloc：取决于OS内核文件的策略，**启发式分配**最多能分配接近物理内存上限，**超额分配**能分配虚拟地址空间的上限（64位OS是2^47位的内存）

多次malloc：无论是启发式还是超额，最终都能分配到虚拟地址空间的上限

malloc()成功返回，OS已经分配相应内存给该进程了吗

答：不是的，这是虚拟内存，但可能会分配4K（一页的大小）的物理内存，用来增加页表项

### new/delete与malloc/free的区别是什么

new和malloc

- malloc需要给定申请内存的大小，返回的是void*，一般需要强制类型转化；new会调用构造函数，不用指定内存大小，返回的指针不用强转。
- malloc失败返回空，**new失败抛bad_malloc异常**，在catch捕捉之前，所有的栈上对象都会被析构，资源全都回收了，而且释放资源的范围由栈帧限定了
- malloc分配的内存不够时，可以使用realloc扩容，而new没有这种操作

delete和free

- free会释放内存空间，对于类类型的对象，不会调用析构函数；
- delete会释放内存空间，而且还会调用析构函数

new[]和delete[]

- 申请数组时，`new[]`一次分配所有内存，多次调用构造函数，搭配使用`delete[]`，`delete[]`多次调用析构函数，销毁数组中的每个对象，而malloc只能接收类似`sizeof(int)*n`这样的参数形式来开辟能容纳n个int型元素的数组空间
- `delete[]`操作符释放空间，而且会调用由`new[]`创建的一组对象的析构函数
- 由`new[]`创建的内存空间，如果由delete释放，则编译器只会释放第一个对象的内存空间，后面的内存空间没法释放，于是产生内存泄漏
- 编译器怎么知道`delete[]`要销毁多少个对象呢，关键在于`new[]`时会把instance的数量存在开头，编译器遇到`delete[]`时就会寻找这个字段值，所以建议：用delete删除new的空间，用`delete[]`删除`new[]`的空间

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

### operator new 的异常处理

- 避免使用nothrow new,因为它如今并不能提供任何显著的优点，而且其特性通常要比简单new(可能抛出异常)的还差。
- 记住，无论如何，检查new是否失败几乎是没什么意义的，原因有若干。
- 如果你理当关心内存耗尽的话，请确保你正在检查的是你所认为你正在检查的，因为：
  - 在那些直到内存被用到时才去提交实际内存的系统之上，检查new失败通常是没有意义的。
  - 在拥有虚拟内存的系统上，new失败几乎不会发生，因为早在虚拟内存耗尽之前，系统
  - 通常就已经开始颠簸了，而此时系统管理员自然会杀掉一些进程。
  - 除了一些特殊情况之外，通常即便你检测到了ew失败，要是真的没内存剩下了的话，那么你也就做不了什么了。

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

### 手撕C库函数

- strcpy只提供了字符串的复制，不指定长度（没有第三个size_t参数），遇到空字符即结束，结尾的空字符也复制
- strncpy函数用于将指定长度的字符串复制到字符数组中
- strcmp返回值分为正数、负数、零是那种情况
- strcat注意空字符的判断
- strstr返回字符串中首次出现子串的地址
- memcpy提供一般的内存复制，对内容没有限制，需要指定长度，但**不检查内存重叠**
- memmove比memcpy多了个一个重叠区域检查的步骤，如果检查出有重叠，则反向拷贝
- memcmp返回值分为正数、负数、零是那种情况
- memset注意是把第二参数转为char后再赋给第一参数char*指针
- atoi

```c++
// 到\0停止
char* strcpy(char *dst, char *src){
    if(dst == src) return dst;
    char *address = dst; // 以供返回
    while((*dst++ = *src++) != '\0'); // src最后的空字符也会赋值给dst
    return address;
}

char* strncpy(char *dst, char *src, unsigned int count){
    char *address = dst;
    while(count-- && *src != '\0'){
        *dst++ = *src++;
    }
    *dst = '\0'; // 别忘加空字符
    return address;
}

// 大于则返回正数，小于则返回负数，等于返回0
int strcmp(char *s, char *t){
    while(*s && *t && *s == *t){
        ++s;
        ++t;
    }
    return *s - *t;
}

char* strcat(char *dst, char *src){
    char *address = dst;
    while(*dst != '\0') ++dst;
    while((*dst++ = *src++) != '\0');
    return address;
}

int strlen(char *str){
    int len = 0;
    while(*str++ != '\0') ++len;
    return len;
}

char *strstr(char *s1, char *s2){
    int len2;
    if(!(len2=strlen(s2)))//此种情况下s2不能指向空，否则strlen无法测出长度，这条语句错误
　      return(char*)s1;
    for(; *s1 != '\0' ; ++s1){
        if(*s1 == *s2 && strncmp(s1, s2, len2)==0) return(char*)s1;
    }
    return NULL;
}

// 默认的memcpy是存在内存重叠的问题的
void* memcpy(void *dst, void* src, size_t size){
    if(dst == nullptr || src == nullptr){
        return nullptr;
    }
    void *result = dst;
    while(size--){
        *(char*)dst = *(char*)src;
        dst = (char*)dst+1; // 移动一个字节，关于mem都这样
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
        // 有内存重叠，反向拷贝
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

// memcmp函数本身就是带第三个参数长度
int memcmp(void *s, void *t, unsigned int count){
    while(*(char *)s && *(char *)t && (*(char *)s == *(char *)t) && count--){
        s = (char *)s + 1;
        t = (char *)t + 1;
    }
    return *(char *)s - *(char *)t;
}

void* memset(void *dst, int val, unsigned int count){
    void *address = dst;
    while(count--){
        *(char *)dst = (char)val;
        dst = (char *)dst + 1;
    }
    return address;
}


// 稍稍改动豪哥的代码，加了flag
   int atoiFlag;
1. int atoi(const char* str)  
2. {  
3.     int result = 0;  
4.     int sign = 0;  
5.     assert(str != NULL);  
6.     atoiFlag = false;
7.     while (*str==' ' || *str=='\t' || *str=='\n')  
8.         ++str;  
9.     // proc sign character  
10.     if (*str=='-')  
11.     {  
12.         sign = 1;  
13.         ++str;  
14.     }  
15.     else if (*str=='+')  
16.     {  
17.         ++str;  
18.     }  
19.     // proc numbers
20.     while (*str>='0' && *str<='9')  
21.     {  
22.         if (result >= (INT_MAX - (*str - '0')) / 10) {
23.             return sign == -1 ? INT_MIN : INT_MAX;//overflow
24.         }
25.         result = result*10 + *str - '0';  
26.         ++str;  
27.     }  
28.     atoiFlag = true;
29.     if (sign==1)  
30.        return -result;  
31.     //
32.     return result;  
33. }  
```

split的函数的一种优雅实现

```c++
void split(const string& s, vector<string>& tokens, const string& delimiters = " ")
{
    string::size_type lastPos = s.find_first_not_of(delimiters, 0);
    string::size_type pos = s.find_first_of(delimiters, lastPos);
    while (string::npos != pos || string::npos != lastPos) {
        tokens.push_back(s.substr(lastPos, pos - lastPos)); //use emplace_back after C++11
        lastPos = s.find_first_not_of(delimiters, pos);
        pos = s.find_first_of(delimiters, lastPos);
    }
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

### main函数之前和之后做了什么

main函数之前，执行了堆栈配置（栈指针）、初始化静态和全局变量（即data段）、未初始化部分的赋初值：数值型short，int，long等为0，bool为FALSE，指针为NULL，等等，即.bss段的内容、运行全局构造器（C++构造函数）、传递参数给main（argc、argv）。

main函数之后，或者执行onexit或atexit注册的函数，再执行析构函数。

如果想让函数在main函数之前执行，有两种方法：

- 全局变量的构造函数、赋值函数、lambda表达式
- 如果是GCC的编译器，方法前加上__attribute((constructor))

### 栈溢出的原因

(stack overflow)

1. 局部数组过大。当函数内部的数组过大时，有可能导致堆栈溢出，因为局部变量是存储在栈中的
2. 递归调用层次太多。递归函数在运行时会执行压栈操作，当压栈次数太多时，也会导致堆栈溢出。
3. 指针或数组越界。这种情况最常见，例如进行字符串拷贝，或处理用户输入等等。

### 段错误

段错误应该就是访问了不可访问的内存，这个内存区要么是不存在的（数组越界、类型不一致），要么是受到系统保护的（内核或其他程序正在使用）。

### 什么是内存泄漏

内存泄漏(memory leak)是指由于疏忽或错误造成了程序未能释放掉不再使用的内存情况。内存泄漏并非指内存在物理上的消失，而是应用程序分配某段内存后，由于设计错误，失去了对该段内存的控制，因而造成了内存的浪费。

C++内存泄漏分类：

1. 堆内存泄漏 （Heap leak）。对内存指的是程序运行中根据需要分配通过malloc,realloc new等从堆中分配的一块内存，再是完成后必须通过调用对应的 free或者delete 删掉。如果程序的设计的错误导致这部分内存没有被释放，那么此后这块内存将不会被使用，就会产生Heap Leak.
2. 系统资源泄露（Resource Leak）。主要指程序使用系统分配的资源比如Bitmap,handle,SOCKET等没有使用相应的函数释放掉，导致系统资源的浪费，严重可导致系统效能降低，系统运行不稳定。
3. 没有将基类的析构函数定义为虚函数。当基类指针指向子类对象时，如果基类的析构函数不是virtual，那么delete基类指针只会能调用基类的析构函数，不会调用子类的析构函数，子类的资源没有正确释放，因此造成内存泄露。

mtrace是用来检查内存泄露的C函数，其原理是记录每一对malloc和free，其他类型的内存泄漏没法找出

程序异常退出时, 由操作系统把程序当前的内存状况存储在一个core文件，这就是core dump，可以用gdb分析core文件

Valgrind是个强大的调试工具，其中包括memcheck，可以发现访问未初始化的内存、访问数组时越界、忘记释放动态内存等问题，更为强大，注意在编译时要加上产生调试信息的命令行参数-g，然后输入`valgrind --tool=memcheck --leak-check=full  ./main_c`

still reachable 是内存泄漏吗？

- 其实，这种场景下的泄漏在严格意义上来讲也许并不能称之为内存泄漏，因为在进程运行过程中并没有泄漏问题。
- 虽然内存在进程结束之前确实未被释放, 但是指向这块内存的指针是 reachable 的，操作系统会获取这些指针并帮助我们释放内存。
- 但是，请注意，**still reachable 可能会掩盖真正的内存泄漏 definitely lost**，这就是作者为何强烈建议开启 reachable 命令行选项的原因。

[使用 Valgrind 检测 C++ 内存泄漏](http://senlinzhan.github.io/2017/12/31/valgrind/)

### 野指针是什么/空悬指针是什么

指向的位置是不可知的，随机的，没有限制的，不可预测的

1. 未初始化的指针
2. 指针释放后（`delete ptr;`)
3. 指针操作超越边界，如访问数组时

连续delete两次同一个指针，会出现double free的错误

delete空指针是安全的，意义明确

在delete一个指针时，判断指针是否非空是无意义的。假如空指针，delete空指针是no-op，假如非空指针，则总会释放的。所以加上判断多此一举

### 函数调用

编译器会为当前调用栈里的每个函数建立一个**栈帧(stack frame)**，栈帧保存函数的返回地址，栈指针，传递的参数，以及局部变量

**栈回退(stack unwind)**机制确保在异常被抛出、捕获并处理后，所有生命期已结束的对象都会被正确地析构，它们所占用的空间会被正确地回收

函数调用时，

- ebp总是指向栈底（高地址），esp总是指向栈顶（地地址），移动esp指针，就可以开辟新函数空间
- 依次把参数压栈，函数参数入栈顺序为**从右到左**，这样保证了第一个参数是栈顶（可以提及一下可变参数模板）。
- **调用前，先把返回地址压入栈**，这样执行完函数之后，弹出即可获得返回地址。
- 栈的增长由高地址往低地址的方向。

![stackframe](../image/stackframe.png)

函数栈提供了多任务支持，CPU可以根据调度算法切换任务，只需把当前任务的栈帧保存下来

函数栈默认大小Windows 1MB、Linux 8MB或10MB（取决于发行版），我的mac是8MB，可以通过ulimit临时修改（只对当前登录会话有效），或者修改内核文件永久修改

### RTTI

- RTTI(Run Time Type Identification)即通过**运行时类型识别**，程序能够使用基类的指针或引用来检查这些指针或引用所指的对象的实际派生类型，**必须定义虚函数**，实际上是通过vptr获取存储在**虚函数表的type_info**，type_info 类描述编译器在程序中生成的**类型信息**
- C++是一种静态类型语言。其数据类型是在编译期就确定的，不能在运行时更改，然而C++又有多态性的需求，所以需要RTTI在运行时进行类型识别
- RTTI提供了两个工具：
  - **type_id**：操作符，用来返回type_info对象的引用
  - **dynamic_cast**：模板，将基类类型的指针或引用安全地转换为其派生类类型的指针或引用。

### GCC编译

gcc -o 与gcc -c 的区别。

- gcc –o将.c源文件编译成为一个**可执行的二进制代码**，这包括调用作为 GCC 内的一部分真正的 C 编译器（ ccl ），以及调用GNU C编译器的输出中实际可执行代码的外部 GNU 汇编器和连接器工具。
- gcc -c是使用GNU汇编器将源文件转化为**目标代码**之后就结束，在这种情况下连接器并没有被执行，所以输出的目标文件不会包含作为 Linux 程序在被装载和执行时所必须的包含信息，但它可以在以后被连接到一个程序)
- 简单来说，-o就是包含了链接，-c就是不包含链接

gcc与g++的区别

GCC是GNU Compiler Collection(GUN 编译器集合)，

最开始的gcc是GNU C Compiler，后来gcc就变成了**驱动程序**，根据后缀判断调用c编译器还是c++编译器（g++）

1. 对于`*.c`和`*.cpp`文件，gcc分别当做c和cpp文件编译（c和cpp的语法强度是不一样的）
2. 对于`*.c`和`*.cpp`文件，g++则统一当做cpp文件编译
3. 使用g++编译文件时，g++会自动链接标准库STL，而gcc不会自动链接STL，需要加上`gcc -lstdc++`

[linux下生成静态库和动态库](https://blog.csdn.net/Ddreaming/article/details/53096411?depth_1-utm_source=distribute.pc_relevant.none-task&utm_source=distribute.pc_relevant.none-task)

假设main.c想调用hello.c的函数，hello.h中有该函数的声明，总共有三种方法：

- 通过编译多个源文件，直接将目标代码合成一个.o 文件。

```c++
//hello.h
#ifndef HELLO_H
#define HELLO_H
void hello(const char* name);
#endif

//hello.c
#include <stdio.h>
void hello(const char* name){
    printf("hello %s! \n",name);
}

//main.c
#include "hello.h"
int main(){
    hello("everyone");
    return 0;
```

```c++
// shell命令，两种编译方式
// 方法1
gcc -o hello hello.c main.c // 一步到位，预处理、编译、汇编、链接
./hello // 运行可执行目标文件
// 方法2
gcc -c hello.c main.c // 默认生成hello.o与main.o，两者是可重定位目标文件
gcc -o hello hello.o main.o // 两个可重定位目标文件链接成可执行目标文件
./hello
```

- 通过创建静态链接库libmyhello.a ，使得main函数调用hello函数时可调用静态链接库。
  - Linux静态库命名规范，必须是`lib[your_library_name].a`。
  - linux下通过ar工具生成静态链接库
  - 静态链接时，指定静态库名（不需要lib前缀和.a后缀，-l选项），如果静态链接库不在`/lib`和`/usr/lib`和`/usr/local/lib`里，需要指定静态链接库的搜索路径（-L选项，也可以用`-L.`来指定当前目录），经测试，-L后必须有空格，-l可有可没有。
  - 把libmyhello.a删除，运行hello仍然有效，说明静态链接库已经嵌入可执行文件中

```shell
[root@vultr learning]# gcc -c hello.c
[root@vultr learning]# ls
hello.c  hello.h  hello.o  main.c
[root@vultr learning]# ar crv libmyhello.a hello.o
a - hello.o
[root@vultr learning]# ls
hello.c  hello.h  hello.o  libmyhello.a  main.c
[root@vultr learning]# gcc -o hello main.c -L ~/learning -lmyhello
[root@vultr learning]# ls
hello  hello.c  hello.h  hello.o  libmyhello.a  main.c
[root@vultr learning]# ./hello
hello everyone!

[root@vultr learning]# rm libmyhello.a
rm：是否删除普通文件 "libmyhello.a"？y
[root@vultr learning]# ls
hello  hello.c  hello.h  hello.o  main.c
[root@vultr learning]# ./hello
hello everyone!
```

- 通过创建动态链接库libmyhello.so ，使得main函数调用hello函数时可调用静态链接库。
  - 动态链接库的名字形式为libxxx.so，前缀是lib，后缀名为“.so”。
  - 针对于实际库文件，每个共享库都有个特殊的名字“soname”。在程序启动后，程序通过这个名字来告诉动态加载器该载入哪个共享库。
  - 在文件系统中，soname仅是一个链接到实际动态库的链接。对于动态库而言，每个库实际上都有另一个名字给编译器来用。它是一个指向实际库镜像文件的链接文件（lib+soname+.so）。
  - -fPIC是创建与地质无关的编译程序，是为了能够在多个应用程序间共享（经测试，这两个命令得分开）
  - -shared是指定生成动态链接库

这里的测试翻车了，centOS与博客中的mac不一致，会找不到，即使把libmyhello.so拷贝到/usr/lib/中也无济于事

### GDB调试

在编译时就要把调试信息加入可执行文件中，如果没有-g参数，函数名、变量名全都看不到，全是内存地址

```shell
g++ -g hello.cpp -o hello
gdb ./hello -tui
```

基本命令

- 开启hello文件的gdb调试命令：`gdb hello`
- 调试一个正在运行的程序：`gdb attach <pid>`
- 列出源码命令：`1`
- 设置断点命令：`break 16`（源程序第16行）、`break func`（函数func入口处）
- 查看断点命令：`info break`
- 运行程序：`r`（run的简写）
- 单步运行：`n`（next的简写）
- 继续运行：`c`（continue的简写）
- 打印变量i的值：`p i`（print的简写）
- 退出gdb：`q`

函数栈

- 查看函数栈：`bt`
- 查看函数调用顺序：`backtrace`
- 切换到栈编号为N的上下文中：`frame N`
- 在栈上移/下移一层orn层：`up/down (n)`

多进程/多线程

- 查看所有进程：`info inferiors`
- 查看所有线程：`info threads`
- 切换当前调试线程：`thread <id>`
- 某线程单步运行：`thread apply <id> n`

用gdb调试时想打印变量值，结果出现了**optimized out**，可能是编译器把变量的值优化到了寄存器中而不是内存中，将编译命令中-O3优化改为-O0取消优化即可

### Linux core dump(核心转储)

如果进程在运行期间发生奔溃，操作系统会为进程生成一个快照文件，这个文件就叫做 core dump。之后我们可以对 core dump 文件进行分析，弄清楚进程为什么会奔溃。

- 产生一个core dump文件：`gcore <pid>`，原理是sigstop+gdb attach+dump memory state
- 查看core文件来自于哪个可执行文件：`file <core file>`

由于 core dump 文件会占据一定的磁盘空间，默认情况下，**Linux 不允许生成 core dump 文件**。如果想要开启，在shell中如下设置

```shell
#设置core大小为无限
ulimit -c unlimited
#设置文件大小为无限
ulimit unlimited
```

设置完了后，查看当前Linux允许core文件大小：

```shell
[root@vultr learning]# ulimit -a | grep core
core file size          (blocks, -c) unlimited
```

我们可以对core文件进行分析，用gdb调试，举个例子，先编写一个会产生错误的代码

```c++
#include<iostream>
using namespace std;

void dummy_function()
{
    unsigned char* ptr = 0x00; //试图访问地址0x00
    *ptr = 0x00;
}

int main()
{
    dummy_function();
    return 0;
}
```

开启core dump后，编译运行它，可以看到吐核两字，然后调用gdb调试（core.9977是core文件名）：

```shell
$ g++ -g -o test test.cpp
$ ./test
段错误 (吐核)
$ gdb ./test core.9977
...
Core was generated by `./test'.
Program terminated with signal 11, Segmentation fault.
#0  0x000000000040065d in dummy_function () at test.cpp:5
5       *ptr = 0x00;
Missing separate debuginfos, use: debuginfo-install glibc-2.17-292.el7.x86_64 libgcc-4.8.5-39.el7.x86_64 libstdc++-4.8.5-39.el7.x86_64
```

然后可以查看堆栈等信息

```c++
(gdb) bt //显示函数调用堆栈，显然是main函数调用dummy_function函数
#0  0x000000000040065d in dummy_function () at test.cpp:5
#1  0x000000000040066b in main () at test.cpp:8
```

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

1. 预处理阶段：对源代码文件中文件包含关系（头文件）、预编译语句（宏定义）进行分析和替换，过滤注释，添加行号和文件名标识，保留#pragma编译器指令，生成**预编译文件**。
2. 编译阶段：语法分析、优化手段、内联函数展开，生成**汇编文件**
3. 汇编阶段：将汇编代码转为机器码，只需要根据汇编指令与机器码指令对照表一一翻译即可，生成**可重定位目标文件**
4. 链接阶段：将多个目标文件及所需要的库链接成最终的**可执行目标文件**，包括符号解析

### 如何避免同一个文件被include多次

- #ifndef + #define + #include + #endif：这是基于**宏**的，宏名冲突就失效了

- #pragma once：只能保证**物理（磁盘）文件**，但如果有拷贝的话没法保证

### 为什么模板的声明和定义都是放在同一个h文件中

模板只有在实例化的时候才会生成实体（生成机器码），如果把模板声明与定义在分离，会导致找不到具体定义

普通函数只需要声明即可编译，链接器会根据函数名找到对应的函数入口

普通的类只需要知道类的定义（不需要类的实现）即可编译

### 共享库(shared library)是什么

共享库是解决静态库缺陷的现代产物，它是一个目标模块，在运行或加载时可以加载到任意内存地址，并和一个在内存中的程序链接起来，这就是动态链接，这是由动态链接器实现的

共享库也叫做共享目标，在Linux中通常以.so后缀来表示，在微软的操作系统中叫做DLL(动态链接库)

Linux中，想知道一个可执行文件所链接的动态链接库，`ldd example.out`，下面的libmyhello.so已经删了，所以提示not found

```shell
[root@vultr learning]# ldd a.out
    linux-vdso.so.1 =>  (0x00007fff55bfe000)
    libmyhello.so => not found
    libc.so.6 => /lib64/libc.so.6 (0x00007f80294b7000)
    /lib64/ld-linux-x86-64.so.2 (0x00007f802988c000)
```

### 静态链接与动态链接(dynamic linking)的区别

链接技术将多个目标文件以及所需的库链接成最终的可执行目标文件

静态链接器从库中复制这些函数和数据并把它们和应用程序的其它模块组合起来创建最终的可执行文件；动态链接器把程序按照模块拆分成各个相对独立部分，在程序运行时才将它们链接在一起形成一个完整的程序

静态链接浪费了空间，可能同一份目标文件有多个副本；动态链接节省了空间，多个程序共享同一份副本

静态链接更新困难，每当库函数代码修改，需要重新编译链接形成可执行程序；动态链接更新方便，只需要替换原来的目标文件即可，程序运行时自动加载新目标文件到内存并链接起来，这就完成了更新

静态链接运行速度快，因为可执行程序已经具备了所有东西；动态链接运行速度较慢，因为每次执行时还需要链接

只有第一次执行动态链接库里的函数，才知道该函数的地址，这叫lazy bind

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

![STL](https://ws1.sinaimg.cn/large/005GdKShgy1gcsf7s1hw0j30u20ndq89.jpg)

### STL的六大组件

空间分配器、迭代器、容器、泛型算法、仿函数（作为泛型算法的comparable参数）、配接器（迭代器适配器inserter、容器适配器queue和stack）

分配器给容器分配存储空间，算法通过迭代器获取容器中的内容，仿函数可以协助算法完成各种操作，配接器用来套接适配仿函数

### 介绍一下STL的allocator

allocator是C++中的空间配置器，用于封装STL容器在内存管理上的底层细节，注意不是内存配置器，因为内存是空间的一部分。

其内存配置和释放如下：new运算分两个阶段：(1)调用new操作符配置内存;(2)调用对象构造函数构造对象内容。delete运算分两个阶段：(1)调用对象析构函数；(2)调用delete操作符释放内存

为了减小内存碎片问题，SGI STL采用了两级配置器：

- 当分配的空间大小超过128 bytes时，会使用第一级空间配置器。第一级空间配置器直接使用malloc()、realloc()、free()函数进行内存空间的分配和释放。
- 当分配的空间小于128 Bytes时，将使用第二级空间配置器。第二级空间配置器采用了**内存池**技术，通过**空闲链表**来管理内存，初始配置一大块内存，并维护对应不同内存空间大小的的16个空闲链表，它们管理的内存块大小是8、16、24、...、128 bytes，如果有内存需求，直接在空闲链表中取，如果有内存释放，则归还到空闲链表中。

### 迭代器的作用/指针与迭代器的区别

迭代器类型：

- input：支持++，支持解引用，支持比较
- output：解引用只能用来写，不能用来读
- forward：支持多次++，可保存该迭代器来重新遍历对象，比如forward_list的迭代器
- bidirection：还支持--，比如list的迭代器
- random：还支持在整数类型上+、-、+=、-=，跳跃式的移动迭代器，还支持[]下标式访问，deque可以满足
- contiguous(C++20)：保证迭代器所指对象在内存中是连续的，vector和array满足

指针与迭代器的区别/迭代器的特点

- 迭代器**封装了指针**，它可以**顺序地访问**容器内的对象，而又**不暴露对象的具体实现**
- 迭代器不是指针，它是类模板，一般里面会有指针成员，模拟指针功能，重载了`++ -- * ->`等操作符
- 迭代器作为一种**粘合剂**，在容器和泛型算法中广泛使用

注意：迭代器的解引用操作返回的是对象引用而不是对象的值，因为可以通过迭代器的解引用去修改原对象

C++17之前，container.begin()与container.end()返回的类型必须相同，从C++17开始，两者可以返回不同的类型

常见的输出迭代器包括back_insert返回的类型back_inserter_iterator，可以方便地在尾部进行插入；还有ostream_iterator，方便把容器内容“拷贝”到输出流

### string

string类似一个容器（但严格不算容器，是模板basic_string对于char的特化）还需要包括begin与end，为了与C字符串兼容，end指向末尾的\0字符

c_str与data的争执：

- `const char* string::c_str () const`：返回string存储的C风格的字符串，末尾有'\0`，注意返回值是string拥有的，所以调用者不能修改或者释放返回值
- `const char* string::data () const`：返回string存储的字符串，末尾没有'\0'，所以不是严格意义上的C风格字符串，注意返回值是string拥有的，所以调用者不能修改或者释放返回值。
- 但是C++11之后，data()也会保证是以'\0'结尾的，所以c_str()与data()的效果是一样的

### vector

resize(size_type n)：改变当前容器内**含有元素的数量**，后面可以用vec.size()获取n。如果原来vec.size()小于n，那么容器会新增（n-原size）个元素，新元素调用默认构造函数（该函数也可接受第二个参数用来确定新增元素的初始值）；如果原来vec.size()大于n，则会删除n之后的所有元素。

reserve(size_type n)：改变当前容器的**最大容量（capacity）**,它不会生成元素，只是确定这个容器允许放入多少对象，如果reserve(len)的值大于当前的capacity()，那么会重新分配一块能存len个对象的空间，然后把之前v.size()个对象通过copy construtor复制过来，销毁之前的内存；

vector::capacity()返回容器当前的容量，初始vector为空时，capacity为0，添加元素后，每次扩容时乘以2（GCC编译器），所以是0、1、2、4、8

vector::max_size()返回容器的最大可以存储多少个元素，这个数很大很大，一般用不到这么大的

vector::clear()函数的作用是清空容器中的内容，但如果是指针对象的话，并不能清空其内容，必须要像以下方法一样才能达到清空指针对象的内容：

```c++
vector<int*> xx;
for(int it=0;it!=xx.size();++it)
{
    delete xx[it];
}
xx.clear();
```

但你可以通过swap()函数来巧妙的达到回收内存的效果：

```c++
xx.clear();
xx.swap(vector<int>());
```

vector::erase()用于清空容器中的某个（传入position）或某部分内容（传入first与last）以及释放内存，并返回**指向删除元素的下一个元素的迭代器**。

vector::remove()将等于value的元素**放到vector的尾部**，但并不减少vector的size。若要真正移除，需要搭配使用erase()，删除vector中值为x的元素

```c++
vec.erase(remove(vec.begin(),vec.end(),x),vec.end());
```

vector::emplace是为了提升性能而设计的，它在指定位置上直接构造元素，如果用push，则需要生成一个临时对象再销毁，emplace可以避免生成临时对象，少了一次构造和销毁

push_back可能需要扩容，但是摊还分析后push_back的时间复杂度还是O(1)

C++11引入的vector::data

- 返回指向底层元素存储的指针（可以认为是C数组）。
- 对于非空容器，返回的指针与首元素地址相等。
- 对于空容器，返回0x0，不能解引用！
- 给你机会在特殊情况下直接读取或者操作底层数组。比如有个函数接口是`void Foo(const int* arr, int len);`，但现在只有一个`vector<int> a`，就可以直接用这个方法：`Foo(a.data(), a.size())`

vector为什么不能存引用类型数据

1. 引用不满足值语义，而vector内元素一定要可以被赋值，可以被
2. 引用必须初始化，且不能改变引用指向新的对象，而vector执行的时候是需要执行copy的，把以前的对象放在vector开辟的内存中，这就相当于因果顺序调换了，原对象是因，引用才是果，不能先有果再有因。这就像房子（容器）还没建好，门牌号（引用）是没有意义的

### 数组与链表的比较

- 两者都是线性表
- 从内存结构来看，数组的内存结构是紧凑的，链表的内存结构是不连续的内存空间，是将一组零散的内存块串联起来，用指针连接
- 数组插入删除O(n)，下标访问O(1)，注意这里是下标访问，不是查询，最快的查询是二分查找，也有O(logn)；链表：插入、删除O(1)(只需更改指针指向即可)，随机访问O(n)(需要从链头至链尾进行遍历)
- 单链表的插入与删除需要前驱节点，这需要O(n)的遍历

CPU在从内存读取数据的时候，会先把读取到的数据加载到CPU的缓存中。而CPU每次从内存读取一块数据，存到CPU的缓存中，下次访问可以先从CPU缓存中寻找，这样就实现了比内存访问速度更快的机制，也就是CPU缓存存在的意义：为了弥补内存访问速度过慢与CPU执行速度快之间的差异而引入。

### list/forward_list(C++11)

虽然 list 提供了任意位置插入新元素的灵活性，但由于每个元素的内存空间都是单独分 配、不连续，它的遍历性能比 vector 和 deque 都要低。

如果你不太需要遍历容器、又需要在中间频繁插入或删除元素，可以考虑使用 list。

另外一个需要注意的地方是，因为某些标准算法在 list 上会导致问题，**list 提供了成员函数作为替代**，包括下面几个: merge remove remove_if reverse sort unique

```c++
list<int> lst{1, 7, 2, 8, 3}; vector<int> vec{1, 7, 2, 8, 3};
sort(vec.begin(), vec.end()); // 正常
lst.sort(); // 正常
sort(lst.begin(), lst.end()); // 会出错
```

C++11提供了单向链表forward_list

- 单向链表对于insert操作比较麻烦，因为要找到前驱节点得从头开始遍历，所以forward_list提供了一个insert_after
- 相比于list，forward_list还提供了back(), size(), push_back(), emplace_back(), pop_back()方法
- 在元素较小的情况下，单向链表能节约内存，这牺牲了双向查找的遍历

### deque

- deque支持push_front, push_back, emplace_front, emplace_back, pop_front, pop_back，没有reserve
- deque是双向开口的**分段连续线性空间**(简单理解为：双端队列)，可以在头尾端进行元素的插入和删除
- 用户看起来deque使用的是连续空间，实际上是分段连续线性空间。为了管理分段空间deque容器引入了map，称之为**中控器**，map是一块连续的空间，其中每个元素是指向缓冲区的指针，缓冲区才是deque存储数据的主体。
- deque不像vector，vector内存不够时需要重新分配内存-复制数据-释放原空间
- deque的迭代器比vector复杂很多，除了一个指向具体数据的原生指针外，还有指向buffer头元素的指针，指向buffer尾元素的指针，指向中控器的指针，这样才能让operator++与--正常工作

deque头文件只包含deque

queue头文件包含deque、queue、priority_queue

stack头文件包含deque、stack

![dequeiterator](../image/dequeiterator.png)

### queue、stack

- queue、stack、priority_queue**不是容器，而是容器适配器，都没有迭代器**
- queue与stack底层使用了deque，但也可以用list

queue缺省用deque实现，FIFO，具有如下特点：

- 不能按下标访问
- 没有begin()与end()
- 唯一的访问接口是front()
- 用emplace代替emplace_back，用push代替push_back，用pop代替pop_back，没有insert和erase

stack缺省用deque实现，LIFO，具有如下特点：

- 不能按下标访问
- 没有begin()与end()，没有迭代器
- 唯一的访问接口是top()
- 用emplace代替emplace_back，用push代替push_back，用pop代替pop_back，没有insert和erase

queue与stack的pop()的**返回值是void**，而top()/front()可以返回**指定元素的引用**

- 这样设计可以减少pop的开销，如果要返回指定元素，因为要删除它，所以不能是引用，所以得拷贝构造一个，这就有开销了
- 在pop时构造的元素需要分配内存，可能会产生异常，而此时元素已经删除了，所以会导致得不到想要的元素，所以在C++98的设计中，就让pop返回空，这样是异常安全的
- 若要做到并发安全，得用wait_and_pop与try_pop，用锁或者原子量来做，可以参考无锁队列的实现，本篇中有对于陈皓博客的总结

### priority_queue

- priority_queue底层支持vector、deque容器，但不支持list、map、set
- 默认最大堆：使用缺省的less作为其Compare模板参数时，最大的数值会出现在容器的“顶部”。
- 如果需要最小的数值出现在容器顶部，则可以传递greater函数对象作为其Compare模板参数。
- pq是个模板，模板里的第一个类型时存储元素的类型，第二个类型时底层容器（默认用vector），第三个类型是compare类型，默认是less
- 若要自定义比较函数，必须把容器也写上

```c++
template <class T, class Sequence = vector<T>, class Compare = less<typename Sequence::value_type> >

// 声明示例
priority_queue<pair<int, int>,vector<pair<int, int>>,greater<pair<int, int>>> q;

// 声明示例
auto my_comp = [](const ListNode* a, const ListNode* b){
    return a->val > b->val;
}
priority_queue<ListNode *, vector<ListNode*>, decltype(my_cmp)> q(my_cmp); // 构建最小堆

struct cmp{  //对新的数据类型的<进行重写
    bool operator()(ListNode *a,ListNode *b){
        return a->val > b->val;
    }
};
priority_queue<ListNode*, vector<ListNode*>, cmp> q; // 构建最小堆
```

### set

set/multiset以rb_tree为底层结构，因此有元素自动排序特性

set的key是value,value也是key。

无法使用set/multiset的iterators改变元素值(因为key有其严谨排列规则)。 set/multiset的iterator是其底部RB tree的const-iterator，就是为了禁止用户对元素赋值。

关联容器提供有序区间查找

- `lower_bound(first, last, k)`找到第一个不小于查找键k的元素(!(x < k))
  - 如果存在这样的元素，则指向其中第一个元素
  - 如果没有这样的元素存在，便返回"假设这样的元素存在时应该出现的位置"。也就是返回第一个"不小于value"的元素
  - 如果value大于范围内任何一个元素,则返回last
- `upper_bound(first, last, k)`找到第一个大于查找键k的元素(k < x)
  - 因为C++的区间是左闭右开的，所以upper_bound有些不同
  - 如果value存在，那么它返回的迭代器将指向value的下一位置，而非指向value本身
- `binary_search(first, last, k)`在已排序的区间内寻找元素value。
  - 如果存在则返回true，如果不存在则返回false。
  - 事实上binary_search便是利用lower-bound先找出"假设value存在的话应该出现的位置"，然后再对比该位置上的值是否为我们所要查找的目标，并返回对比结果。

### map的一些问题/map底层为什么要用红黑树实现

[关于 std::set/std::map 的几个为什么-陈硕](https://blog.csdn.net/Solstice/article/details/8521946)

红黑树是一种二叉查找树，但在每个节点增加一个存储位表示节点的颜色，可以是红或黑（非红即黑）。

红黑树是一种**弱平衡**二叉树，相对于要求严格的AVL树来说，它的旋转次数少，所以插入删除要比AVL快，O(logn)，性能稳定，所以用红黑树。插入的节点都是红色的，高度只比AVL树多一倍，插入/删除后最多三次旋转即可保持平衡

红黑树性质：

1. 每个节点非红即黑
2. 根节点是黑的;
3. 每个叶节点（叶节点即树尾端NULL指针或NULL节点）都是黑的;
4. 如果一个节点是红色的，则它的子节点必须是黑色的。
5. 对于任意节点而言，其到叶子点树NULL指针的每条路径都包含相同数目的黑节点;

### array（C++11起）

定义于头文件`<array>`中

```c++
template<
    class T,
    std::size_t N>
struct array;
//(C++11 起)
```

- std::array是封装**固定大小**数组的容器。
- 此容器是一个聚合类型，其语义等同于保有一个C风格数组`T[N]`作为其唯一非静态数据成员的结构体。
- 不同于C风格数组，**它不会自动退化成 `T*`**，在传入函数参数，C风格数组会退化为指针。
- 作为聚合类型，它能聚合初始化，只
要有至多 N 个能转换成 T 的初始化器： `std::array<int, 3> a = {1,2,3};`
- 该结构体结合了C风格数组的性能和可访问性和容器的优点，譬如知晓其大小、支持赋值、随机访问等。
- 对于零长array，array.begin()==array.end()
- 对于零长array，调用front()或back()的效应是未定义的。
- array亦可用作拥有 N个同类型元素的元组。

C风格获取数组长度，一般会定义为宏，但是在数组退化成指针时不会报错（毕竟指针也可以sizeof），所以在运行时会产生错误的结果

```c++
#define ARRAY_LEN(a) (sizeof(a) / sizeof((a)[0]))

void test(int a[8]){
    cout << ARRAY_LEN(a) << endl;
}
```

C++17提供了std::size()方法，可以提供数组长度，并且在数组退化成指针时编译失败（可以在编译阶段发现错误）

用std::array，可以直接调用size成员函数，而且也不会退化成指针，这样更方便

### tuple(C++11起)

用一个变量来表达多个值，相当于C++98里的pair类型的一般化

```c++
tuple<int, string, string> tp = {1, "one", "un"};
get<0>(tp); // 得到1
get<int>(tp); // 得到1
get<1>(tp); // 得到"one"
get<2>(tp); // 得到"un"
```

- tuple 的成员数量由尖括号里写的类型数量决定。
- 可以使用 get 函数对 tuple 的内容进行读和写。(当一个类型在 tuple 中出现正好一次时，我们也可以传类型取内容，即，对我们上面的三元组，`get<int>`是合法的，`get<string>`则不是，编译报错。)
- 可以用 tuple_size_v (在编译期)取得多元组里面的项数。

### 为什么容器不继承一个共同的基类

在stackoverflow上看到的帖子，现代C++实战30讲中也有这样的思考题

主要是从性能上考虑的，虽然可以用一个基类实现如size这样的通用接口，看上去容器的实现要更简单，但是有了继承，就很有会有多态，那就需要运行时去查找虚函数表，这是有内存开销的

### STL迭代器失效总结

vector

1. 插入（push_back）一个元素后，插入前end()操作返回的迭代器肯定失效，常见的错误做法如下：

    ```c++
    auto end = vec.end();
    for(it = vec.begin(); it != end; ++it){
        vec.push_back(0);
    }
    ```

2. 插入一个元素，有可能vector的capacity发生了变化（这里牵涉到vectora的动态扩容），那么原来所有的迭代器都失效

3. 当进行删除操作（erase，pop_back）后，指向删除点的迭代器全部失效；指向删除点后面的元素的迭代器也将全部失效。一般可以利用erase()的返回值得到删除点后面的那个元素

    ```c++
    vector<int> vec = {0,1,2,3};
    auto it = vec.begin();
    it = vec.erase(it); // now it points to 1
    ```

4. 如果想通过迭代器循环删除vector，可以利用vector.erase返回下一个元素的特性（其他STL容器也可以这样做）

   ```c++
      vector<int> vec = {0,1,2,3};
      for (auto it = vec.begin(); it != vec.end();) {
        it = vec.erase(it);
      }
      cout << vec.size() << endl; // 输出0
      cout << vec.capacity() << endl; // 输出4
      vec.shrink_to_fit();
      cout << vec.size() << endl; // 输出0
      cout << vec.capacity() << endl; // 输出0
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

### traits萃取

typename告诉编译器：这是一个类型，typedef为这个类型定义别名

```c++
template<typename _Iterator>
struct iterator_traits
{
  typedef typename _Iterator::iterator_category iterator_category;
  typedef typename _Iterator::value_type        value_type;
  typedef typename _Iterator::difference_type   difference_type;
  typedef typename _Iterator::pointer           pointer;
  typedef typename _Iterator::reference         reference;
};
```

traits萃取，就是一台特性萃取机，榨取各个迭代器的特性（相应型别）

中间层iterator_traits可以接受各种迭代器，如int*, const int*, `list<int>::iterator`, `deque<int>::iterator`等等

对于int*、const int*需要特化

萃取机包含下面5种

```c++
template<typename _Iterator>
struct iterator_traits
{
  typedef typename _Iterator::iterator_category iterator_category;
  typedef typename _Iterator::value_type        value_type;
  typedef typename _Iterator::difference_type   difference_type;
  typedef typename _Iterator::pointer           pointer;
  typedef typename _Iterator::reference         reference;
};
```

![iteratortraits](../image/iteratortraits.png)

### EBO(空基类优化)

对于一个空类，编译器会自动插入一个字节，使类对象有地址，sizeof(A)=1

而如果一个类想获得另一个类的功能，可以声明成员对象，也可以用继承，但是从空间上考虑，用继承更好，看下面的例子

```c++
class Empty{
public:
    void print() {
        std::cout<<"I am Empty class"<<std::endl;
    }
};
class notEbo  {
    int i;
    Empty e;
    // do other things
};
class ebo:public Empty {
    int i;
    // do other things
};
std::cout<<sizeof(notEbo)<<std::endl; // 输出8，4+1=5，因为字节对齐，扩充到4的倍数，最后就是8字节
std::cout<<sizeof(ebo)<<std::endl; // 输出4，没有额外空间
```

而在STL的容器中，不管是deque、rb_tree、list等容器，都离不开内存管理，内存管理是由某个特定的allocator类实现的，而这些容器都是继承这些。

所以STL的内存管理就是通过采用继承的方式，使用空基类优化，来达到尽量降低容器所占的大小。

### std::sort

STL的sort算法是内省排序

- 三数中值法选择pivot
- 快排需要递归，当递归深度超过某阈值时，转为堆排序
- 当子区间小于某阈值时，直接用插入排序

## 操作系统

操作系统其实就像一个软件外包公司，其内核就相当于这家外包公司的老板

CPU包括三个部分，运算单元（ALU）、数据单元（各种数据寄存器）和控制单元（指令指针寄存器，段寄存器：代码段、数据段、栈段）

CPU启动，从实模式（只能寻址1M）到保护模式（32位可以寻址4G）

在Linux下面，二进制的程序也要有严格的格式，这个格式我们称为ELF，下面是几种合法的ELF格式

- 可重定位文件(.o)，里面包含数据段、代码段、只读段等等
- 可执行文件，可重定位文件经过链接后形成了可执行文件
- 共享库/共享对象文件，最后的程序文件并不包括动态链接库中的代码，而仅仅包括对动态链接库的引用

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

1. 加载内核：打开电源后，加载BIOS（只读，在主板的ROM里），硬件自检，读取MBR（主引导记录），运行Boot Loader，内核就启动了，这里还有从实模式到保护模式的切换
2. 进程：内核启动后，先启动**第0号进程init_task**，然后在内核运行init()函数，**1号进程**进入用户态变为init进程，init进程是所有用户态进程的老祖宗，其配置文件是/etc/inittab，通过该文件设置运行等级：根据/etc/inittab文件设置运行等级，比如有无网络
3. 系统初始化：启动第一个用户层文件/etc/rc.d/rc.sysinit，然后激活交换分区、检查磁盘、加载硬件模块等
4. 建立终端：系统初始化后返回init，这时守护进程也启动了，init接下来打开终端以供用户登录

init_task是第0号进程，唯一一个没有通过fork或kernel_thread产生的进程，是进程列表的第一个。它比init进程产生还早。

init是第1号进程，会成为用户态，是所有用户态进程的祖先

kthreadd是第2号进程，会成为内核态，是所有内核态进程的祖先

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

- 查看磁盘使用情况以及容量

    `df -h`

- 查看端口号

    `lsof -i : <pid>`

    `netstat | grep <pid>`

- 查看一个文件的第100行到200行

    `cat <filename> | awk 'NR >= 100 && NR <=200'`

- 修改最大文件句柄（也就是文件描述符）数量

    用户级（仅对当前进程有效）：ulimit -n 65536

    系统级：`/etc/security/limits.conf`

### 目录与文件权限的意义区别（鸟哥的Linux私房菜

见Linux-基础知识

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

### Linux文件系统

这篇文章讲文件系统比较通俗形象，由浅入深讲述了inode与block的概念，直接索引与多级索引寻址能力，为什么ext2文件系统最大单文件大小是4T，稀疏文件的概念，还不错：[深度剖析 Linux cp 命令的秘密](https://mp.weixin.qq.com/s/HkFz0F0A3WhebNgJBC7-Tg)

#### 基础

Linux 文件系统会为每个文件分配两个数据结构：索引节点（index node）和目录项（directory entry），它们主要用来记录文件的元信息和目录层次结构。

- 索引节点(inode)：用来记录文件的**元信息**，比如 inode 编号、文件大小、访问权限、创建时间、修改时间、数据在磁盘的位置等等。索引节点是文件的唯一标识，它们之间一一对应，也同样都会被**存储在硬盘**中，所以索引节点同样占用磁盘空间。
- 目录项(dentry)：用来记录文件的名字、索引节点指针以及与其他目录项的层级关联关系。多个目录项关联起来，就会形成目录结构，但它与索引节点不同的是，目录项是由内核维护的一个数据结构，不存放于磁盘，而是**缓存在内存**。

目录与目录项：

- **目录也是文件**，也是用索引节点唯一标识，和普通文件不同的是，普通文件在磁盘里面保存的是文件数据，而目录文件在磁盘里面保存子目录或文件。
- 目录持久化**存储在磁盘**，而目录项是内核一个数据结构，**缓存在内存**

磁盘被分成三个存储区域，分别是超级块、索引节点区和数据块区。

- 超级块，用来存储文件系统的详细信息，比如块个数、块大小、空闲块等等（当文件系统挂载时进入内存）
- 索引节点区，用来存储索引节点（当文件被访问时进入内存）
- 数据块区，用来存储文件或目录数据；

/etc/passwd的权限为 `-rw-r--r--` 也就是说：

- 该文件的所有者拥有读写的权限
- 用户组成员只有查看权限
- 其它成员只有查看的权限。

#### VFS

VFS（Virtual File System）虚拟文件系统扮演着文件系统管理者的角色，与它相关的数据结构只存在于物理内存当中。它的作用是：屏蔽下层具体文件系统操作的差异，为上层的操作提供一个统一的接口。

Linux 支持的文件系统也不少，根据存储位置的不同，可以把文件系统分为三类：

- 磁盘的文件系统，它是直接把数据存储在磁盘中，比如 Ext 2/3/4、XFS 等都是这类文件系统。
- 内存的文件系统，这类文件系统的数据不是存储在硬盘的，而是占用内存空间，我们经常用到的 /proc 和 /sys 文件系统都属于这一类，读写这类文件，实际上是读写内核中相关的数据数据。
- 网络的文件系统，用来访问其他计算机主机数据的文件系统，比如 NFS、SMB 等等。

#### 文件的使用

系统调用：open系统调用打开文件返回fd，write向fd写数据，最后close这个fd

用户空间write()--》虚拟文件系统sys_write()--》文件系统的写方法--》磁盘

fd是文件描述符，操作系统会跟踪进程打开的所有文件

#### 文件的存储

连续空间存放方式：

- 优点：读写效率高，文件头需要指定起始块位置与长度，linux的inode就支持
- 缺点：磁盘碎片、文件长度不易扩展

非连续空间存放方式：

- 链表：可消除磁盘碎片，文件长度可扩展。
  - 隐式链接：文件头包含第一个数据块和最后一个数据块，缺点是得遍历查找以及指针也占空间
  - 显式链接：取出每个数据块的指针，存放在内存的**文件分配表**里，缺点是不适合大磁盘
- 索引：可消除磁盘碎片，文件长度可扩展，也适合大磁盘
  - 为每个文件创建一个「索引数据块」，里面存放的是指向文件数据块的指针列表，就想书的目录一样
  - 文件头需要包含指向『索引数据块』的指针
  - 创建文件时，索引块的所有指针都设为空。当首次写入第 i 块时，先从空闲空间中取得一个块，再将其地址写到索引块的第 i 个条目。
  - 优点：文件的创建、增大、缩小很方便；不会有碎片问题；支持随机读写
- 链表+索引：『链式索引块』
  - 在索引数据块留出一个存放下一个索引数据块的指针，，于是当一个索引数据块的索引信息用完了，就可以通过指针的方式，找到下一个索引数据块的信息（感觉有点像跳表）
- 索引+索引：『多级索引块』
  - 通过一个索引块来存放多个索引数据块，一层套一层索引，像极了俄罗斯套娃

#### 空闲空间管理

空闲表法就是为所有空闲空间建立一张表，表内容包括空闲区的第一个块号和该空闲区的块个数，注意，这个方式是连续分配的，缺点也是显而易见的，如果有大量的小的空闲区，则空闲表就会变得很大

空闲链表可以应付连续的小空闲区，但是不能随机访问

位图是利用二进制的一位来表示磁盘中一个盘块的使用情况，磁盘上所有的盘块都有一个二进制位与之对应。当值为 0 时，表示对应的盘块空闲，值为 1 时，表示对应的盘块已分配。

Linux 文件系统就采用了位图的方式来管理空闲空间，不仅用于数据空闲块的管理，还用于 inode 空闲块的管理

#### Page Cache 层

- 引入 Cache 层的目的是为了提高 Linux 操作系统对磁盘访问的性能。Cache 层在内存中缓存了磁盘上的部分数据。
- 在 Linux 的实现中，文件 Cache 分为两个层面，Page Cache主要是对文件的缓存；Buffer Cache则主要是对块设备的缓存，
- cache两大功能：预读（局部性原理）和回写（数据暂存buffer，然后统一异步落盘）

#### 软链接与硬链接

**为解决文件的共享使用**，Linux系统引入了两种链接：硬链接与软链接（又称符号链接）。链接为Linux系统解决了文件的共享使用，还带来了隐藏文件路径、增加权限安全及节省存储等好处。

- 若一个inode号对应多个目录项的『索引节点』，则称这些文件为硬链接。
  - 文件有相同的inode及data block；
  - **只能对已存在的文件进行创建**；
  - 不能对目录进行创建，只可对文件创建；
  - 删除一个硬链接文件并不影响其他有相同 inode 号的文件。

- 若文件用户数据块中存放的内容是**另一文件的路径名的指向**（类似于windows的快捷方式），则该文件就是软连接。软链接就是一个普通文件，只是数据块内容有点特殊。
  - 软链接有着自己的inode号以及data block
  - 可对不存在的文件或目录创建软链接；
  - 软链接可对文件或目录创建；
  - 删除软链接并不影响被指向的文件，但若被指向的原文件被删除，则相关软连接被称为**死链接**（即 dangling link，若被指向路径文件被重新创建，死链接可恢复为正常的软链接）。

发现：硬链接和软链接有点像引用和指针的差别，

- 引用必须初始化（硬链接只能对已存在的文件），指针可以不初始化（软链接课对不存在的文件）
- 引用就是别名（硬链接也是别名），指针是对象的地址（软链接是另一文件的路径名的指向）
- 引用不是对象（硬链接的inode与data block相同），指针是对象（软链接的inode独立）

`ln -s / /home/good/linkname`：链接根目录到 `/home/good/linkname`

加参数-s就是软链接，不加参数-s就是硬链接

#### 文件IO

标准库缓冲

- 缓冲IO：利用的是标准库的缓存实现文件的加速访问，而标准库再通过系统调用访问文件。
- 非缓冲 I/O，直接通过系统调用访问文件，不经过标准库缓存。
- 缓冲特指**标准库**内部实现的缓冲，程序遇到换行才输出，这就是被标准库暂时缓存了起来，这样可以减少系统调用的次数

操作系统缓冲

- 直接 I/O，不会发生内核缓存和用户程序之间数据复制，而是直接经过文件系统访问磁盘。
- 非直接 I/O，读操作时，数据从内核缓存中拷贝给用户程序，写操作时，数据从用户程序拷贝给内核缓存，再由内核决定什么时候写入数据到磁盘。
- 我们都知道磁盘 I/O 是非常慢的，所以 Linux 内核为了减少磁盘 I/O 次数，在系统调用后，会把用户数据拷贝到内核中缓存起来，这个内核缓存空间也就是「**页缓存**」，只有当缓存满足某些条件的时候，才发起磁盘 I/O 的请求。
- 如果你在使用文件操作类的系统调用函数时，指定了 O_DIRECT 标志，则表示使用直接 I/O。如果没有设置过，默认使用的是非直接 I/O。
- 以下几种场景会触发内核缓存的数据写入磁盘：
  - 在调用 write 的最后，当发现内核缓存的数据太多的时候，内核会把数据写到磁盘上；
  - 用户主动调用 sync，内核缓存会刷到磁盘上；
  - 当内存十分紧张，无法再分配页面时，也会把内核缓存的数据刷到磁盘上；
  - 内核缓存的数据的缓存时间超过某个时间时，也会把数据刷到磁盘上；

阻塞与非阻塞

- 阻塞 I/O，例如当用户程序执行 read ，线程会被阻塞，一直等到内核数据准备好，并把数据从内核缓冲区拷贝到应用程序的缓冲区中，当拷贝过程完成，read 才会返回。（注意，阻塞等待的是「内核数据准备好」和「数据从内核态拷贝到用户态」这两个过程
- 非阻塞 I/O，非阻塞的 read 请求在数据未准备好的情况下立即返回，可以继续往下执行，此时应用程序不断轮询内核，直到数据准备好，内核将数据拷贝到应用程序缓冲区，read 调用才可以获取到结果
- 每次轮询有点低效，IO多路复用的技术就出来了，当内核数据准备好时，再以事件通知应用程序进行操作，可以极大地改善CPU的利用率，应用进程可以使用CPU做其他事

同步与异步

- 之前说的都是同步，因为在最后一次read系统调用时，应用进程必须等待内核将数据从内核空间拷贝到进程自己的虚拟地址空间，这个过程是**同步**的
- 真正的异步：『内核数据准备好」和「数据从内核态拷贝到用户态」这两个过程都不用等待，当发起aio_read，立即返回，内核自动将数据从内核空间拷贝到应用程序空间，这个拷贝过程同样是异步的，内核自动完成的，和前面的同步操作不一样，应用程序并不需要主动发起拷贝动作

#### 预读

- readahead，检查当前IO与上个IO的文件偏移量，判断当前是否是顺序读，如果是的话，就执行额外的读请求，填充进缓存中

### 进程与线程

进程（process）是运行程序的一个实例，是程序运行的所有资源的总和，是操作系统进行资源调度和分配的最小单位。

线程（thread）是轻量级的进程，每个线程完成不同的任务，但是共享同一地址空间和全局变量，是CPU调度的最小单位

#### 区别

1. 进程可以有一个或多个线程，线程只能属于一个进程
2. 进程在执行过程中拥有独立的虚拟地址空间，资源分配给进程，同一进程的所有线程共享该进程的所有资源，包括地址空间、代码段（代码和常量）、数据段（全局变量和静态变量）、堆，但是**每个线程拥有自己的栈段以及寄存器**
3. 进程是资源分配的最小单位，线程是CPU调度的最小单位
4. 系统开销：创建或销毁进程时，系统要为之分配或回收资源，因此开销比线程更大；类似地，进程切换涉及到整个进程CPU环境的保存以及新被调度运行的进程的CPU环境的设置。而线程切换只须保存和设置少量寄存器的内容，所以进程切换的开销也远大于线程切换的开销。
5. 通信：由于同一进程中的多个线程具有相同的地址空间，所以它们之间的同步和通信的实现也变得比较容易
6. 进程间不会相互影响 ；线程一个线程挂掉将导致整个进程挂掉

相同点：Linux中，无论进程线程，在内核中都叫**任务(task)**，统一由task_struct管理，底层用到了链表（为了方便进程的插入和删除），链表的每个节点就是一个task_struct，其中包含了信号处理相关的操作，进程调度牵涉到优先级与调度策略等等

#### 有了进程为什么还有线程

- 并行实体共享同一个地址空间和所有可用数据的能力，线程间通信非常方便
- 线程比进程更轻量级，所以它们比进程更容易、更快创建，也更容易撤销，从资源上来说，线程更加节俭
- 拥有多个线程允许这样活动彼此重叠进行，从而会加快应用程序执行速度，从切换效率上来说，线程更快

#### 进程状态与进程分类

1. 创建状态：进程正在被创建
2. 就绪状态：进程被加入到就绪队列中等待CPU调度运行
3. 执行状态：进程正在被运行
4. 阻塞状态：进程因为某种原因，比如等待I/O，等待设备，而暂时不能运行。
5. 终止状态：进程运行完毕

Linux进程分类

1. 交互进程——由一个shell启动的进程。交互进程既可以在前台运行，也可以在后台运行。
2. 批处理进程——这种进程和终端没有联系，是一个进程序列。
3. 监控进程（也称守护进程）——Linux系统启动时启动的进程，并在后台运行。

#### 多进程与多线程的使用场景

多进程适用于**CPU密集型**，或者**多机分布式**场景中, 易于多机扩展

多线程模型的优势是线程间切换代价较小, 因此适用于**I/O密集型**的工作场景, 因此I/O密集型的工作场景经常会由于I/O阻塞导致频繁的切换线程。同时, 多线程模型也适用于**单机多核**分布式场景

#### 为什么要多线程

[面试问我，创建多少个线程合适？我该怎么说](https://mp.weixin.qq.com/s/tKgNE7jGG87koDWaw4dRJQ)

- 低级答案：因为快
- 优秀答案：充分利用CPU的利用率与多核优势
- 【单核CPU处理CPU密集型程序】不适合多线程，因为每个线程都在等待CPU的计算资源，白白多了上下文切换的开销
- 【多核CPU处理CPU密集型程序】适合多线程，最佳线程数量 = CPU核数（逻辑）+1，额外的一个线程充当备胎，确保CPU不会因某个线程产生错误而停止工作
- 【单核或多核CPU处理IO密集型程序】适合多线程，因为在进行 I/O 操作时，CPU是空闲状态，线程等待时间所占比例越高，需要越多线程；线程CPU时间所占比例越高，需要越少线程。`最佳线程数 = CPU核心数 *  (1/CPU利用率) =  CPU核心数 * (1 + (IO耗时/CPU耗时))`

APM （Application Performance Manager）工具：SkyWalking、CAT、zipkin，可以用来查看CPU利用率

#### 增加CPU核数一定可以提高性能吗

不能，根据阿姆达尔定律，S = 1/(1-p + p/n)，n是核数，p是程序并行百分比，1-p是程序串行百分比，当1-p=5%、n趋向于无穷，S的极限是20，也就是说如果串行率是5%，无论采用什么优化手段，程序性能最多也只能提高20倍。

串行百分比 = 单线程执行临界区的时间 / 单线程执行(临界区+非临界区)的时间

所以要**缩小临界区**

### Linux中的进程管理

摘自：Linux内核设计与实现

进程是运行中的程序以及与该运行程序相关的资源的总合

Linux对线程和进程并不特别区分，对于Linux而言，线程只是一种特殊的进程罢了

#### 进程描述符及其任务结构

任务队列与task_struct: Linux中的进程又叫做任务，内核把进程列表放在叫做**任务队列(task list)**的双向循环链表中，链表中的每一项都是task_struct，称为**进程描述符(process descriptor)**，其包含的数据能够完整地描述一个正在执行的程序：打开的文件，进程的地址空间，挂起的信号，进程的状态等等

```c++
struct task_struct {
    unsigned long state;
    int prio;
    unsigned long policy;
    struct task struct *parent; // 当前进程的父进程
    struct list_head tasks; // 当前进程的子进程链表
    pid_t pid;
    // 链表中的下一节点
    // 链表中的前一节点
    ...
}
```

thread_info: Linux通过**slab分配器**分配task_struct结构，这样能达到**对象复用和缓存着色**（cache coloring）的目的。由于现在用slab分配器动态生成task_struct，所以只需在栈底（对于向下增长的栈来说）或栈顶（对于向上增长的栈来说）创建一个新的结构 struct thread_info。thread_info中有一个指向tast_struct（进程描述符）的指针。

```c++
struct thread_info {
    struct task_struct *task;
    struct exec domain *exec domain;
    _u32 flags;
    _u32 status;
    _u32 cpu;
    int preempt_count;
    mm_segment_t addr_limit;
    struct restart block restart block;
    void *sysenter_return;
    int uaccess_err;
};
```

PID: 内核通过一个唯一的进程标识值PID来标识每个进程。PID是一个数，实际上就是一个int类型。为了与老版本的Unix和Linux兼容，PID的最大值默认设置为32768（short int短整型的最大值），尽管这个值也可以增加到高达400万（这受`<linux/threads.h>`中所定义PID最大值的限制）。内核把每个进程的PID存放在它们各自的进程描述符中。

进程状态：

- TASK_RUNNING（运行）——进程是可执行的；它或者正在执行，或者在运行队列中等待执行。这是进程在用户空间中执行的唯一可能的状态；这种状态也可以应用到内核空间中正在执行的进程。
- TASK_INTERRUPTIBLE（可中断）——进程正在睡眠（也就是说它被阻塞），等待某些条件的达成。一旦这些条件达成，内核就会把进程状态设置为运行。处于此状态的进程也会因为接收到信号而提前被唤醒并随时准备投入运行。
- TASK_UNINTERRUPTIBLE（不可中断）——除了就算是接收到信号也不会被唤醒或准备投入运行外，这个状态与可打断状态相同。这个状态通常在进程必须在等待时不受干扰或等待事件很快就会发生时出现。由于处于此状态的任务对信号不做响应，所以较之可中断状态，使用得较少。
- _TASK_TRACED——被其他进程跟踪的进程，例如通过ptrace对调试程序进行跟踪。
- _TASK_STOPPED（停止）——进程停止执行；进程没有投入运行也不能投入运行。通常这种状态发生在接收到SIGSTOP、SIGTSTP、SIGTTIN、SIGTTOU等信号的时候。此外，在调试期间接收到任何信号，都会使进程进入这种状态。

#### 进程创建

- 写时拷贝
- fork
- vfork

#### 进程终结

在调用了do_exit()之后，尽管线程已经僵死不能再运行了，但是系统还保留了它的进程描述符

wait()这一族函数都是通过唯一的一个系统调用wait4()来实现的。它的标准动作是挂起调用它的进程，直到其中的一个子进程退出，此时函数会返回该子进程的PID。此外，调用该函数时提供的指针会包含子函数退出时的退出代码。

当最终需要释放进程描述符时，release_task()会被调用，release_task()调用put_task_struct()释放进程内核栈和thread_info结构所占的页，并释放tast_struct所占的slab高速缓存。

### Linux中的进程调度

调度程序负责决定将哪个进程投入运行，何时运行以及运行多长时间。进程调度程序（常常简称调度程序）可看做在可运行态进程之间分配有限的处理器时间资源的内核子系统。绝大多数操作系统都是采取抢占式的多任务模式。

O1已经是上一代调度器了，由于其对多核、多CPU系统的支持性能并不好，并且内核功能上要加入cgroup等因素，Linux在2.6.23之后开始启用CFS作为对一般优先级(SCHED_OTHER)进程调度方法。

Linux实现了**CFS(完全公平调度)**，CPU提供的时钟tick，为每一个进程安排一个vruntime，运行得越久，vruntime越大，没有得到执行的进程vruntime很小，所以让CPU去执行vuntime很小的进程。**时间片，动态、静态优先级以及IO消耗，CPU消耗的概念都不再重要**。优先级是以**时间消耗(vruntime增长)的快慢**来决定的。**vruntime用红黑树存储**，平衡了查询与更新的时间。Linux独一无二的公平调度程序并没有采取时间片来达到公平调度。

#### 进程优先级NI和PR

NICE值反应一个进程**优先级状态**的值，其取值范围是-20至19，一共40个级别。这个值越小，表示进程”优先级”越高，而值越大“优先级”越低。nice值虽然不是priority，但是它确实可以影响进程的优先级。它是**静态优先级**。形象解释：越nice的人抢占资源的能力就越差，而越不nice的人抢占能力就越强。这就是nice值大小的含义，nice值越低，说明进程越不nice，抢占cpu的能力就越强，优先级就越高。nice值在SCHED_NORMAL（普通的、非实时的）有意义

priority的值在之前内核的O1调度器（Linux2.6之后内核调度算法替换为了CFS）上表现是会变化的，所以也叫做**动态优先级**，priority范围从0到MAX_RT_PRIO减1。默认情况下，MAX_RT_PRIO为100——所以默认的实时优先级范围是从0到99。SCHED_NORMAL级进程的nice值共享了这个取值空间；它的取值范围是从MAX_RT_PRIO到（MAX_RT_PRIO+40）。也就是说，在默认情况下，nice值从-20到+19直接对应的是从100到139的实时优先级范围。priority在两种实时调度策略：SCHED_FIFO和SCHED_RR中有意义

#### 时间片

时间片是一个数值，它表明进程在被抢占前所能持续运行的时间。调度策略必须规定一个默认的时间片，但这并不是件简单的事。时间片过长会导致系统对交互的响应表现欠佳；时间片太短会明显增大进程切换带来的处理器耗时

此外，I/O消耗型和处理器消耗型的进程之间的矛盾在这里也再次显露出来：I/O消耗型不需要长的时间片，而处理器消耗型的进程则希望越长越好（比如这样可以让它们的高速缓存命中率更高）。

任何长时间片都将导致系统交互表现欠佳，所以默认的时间片很短，如10ms。但是Linux的CFS调度器并没有直接分配时间片到进程，它是将处理器的使用比划分给了进程。这样一来，**进程所获得的处理器时间其实是和系统负载密切相关的**。这个比例进一步还会受进程nice值的影响，nice值作为权重将调整进程所使用的处理器时间使用比。具有更高nice值（更低优先权）的进程将被赋予低权重，从而丧失一小部分的处理器使用比；而具有更小nice值（更高优先级）的进程则会被赋予高权重，从而抢得更多的处理器使用比。

像前面所说的，Linux系统是抢占式的。当一个进程进入可运行态，它就被准许投入运行。在多数操作系统中，是否要将一个进程立刻投入运行（也就是抢占当前进程），是完全由进程优先级和是否有时间片决定的。而在Linux中使用新的CFS调度器，其抢占时机取决于**新的可运行程序消耗了多少处理器使用比**。如果消耗的使用比比当前进程小，则新进程立刻投入运行，抢占当前进程。否则，将推迟其运行。

#### Unix的进程调度

在Unix系统上，优先级以nice值形式输出给用户空间。这点听起来简单，但是在现实中，却会导致许多反常的问题，我们下面具体讨论。

- nice单位值要对应到处理器的绝对时间，这会导致进程切换无法最优化进行，比如nice=0分配100ms，nice=20分配5ms，假设只有两个nice=20的进程，他们各自运行5ms就要换位
- 相对nice值的问题，假设nice=0分配100ms，nice=1分配95ms，它们的差距只差5%，但如果nice=18分配10ms，nice=19分配5ms，它们差距100%
- 时间片得是定时器节拍的整数倍，而且时间片还会随着定时器节拍改变
- 为了优化交互任务而唤醒相关进程，得提升待唤醒进程的优先级，即便它们的时间片已用尽，但这会打破公平原则

上述问题中的绝大多数都可以通过对传统Unix调度器进行改造解决，虽然这种改造修改不小，但也并非是结构性调整。比如，将nice值呈几何增加而非算数增加的方式解决第二个问题；采用一个新的度量机制将从nice值到时间片的映射与定时器节拍分离开来，以此解决第三个问题。但是这些解决方案都回避了实质问题——即分配绝对的时间片引发的固定的切换频率，给公平性造成了很大变数。CFS采用的方法是对时间片分配方式进行根本性的重新设计（就进程调度器而言）：完全摒弃时间片而是分配给进程一个处理器使用比重。通过这种方式，CFS确保了进程调度中能有恒定的公平性，而将切换频率置于不断变动中。

#### CFS

完全公平调度（CFS）是一个针对普通进程的调度类，在Linux中称为SCHED_NORMAL

CFS的出发点基于一个简单的理念：进程调度的效果应如同系统具备一个理想中的完美多任务处理器。在这种系统中，每个进程将能获得1/n的处理器时间——n是指可运行进程的数量。

CFS的做法是允许每个进程运行一段时间、循环轮转、选择运行最少的进程作为下一个运行进程，而不再采用分配给每个进程时间片的做法了，CFS在所有可运行进程总数基础上计算出一个进程应该运行多久，而不是依靠 nice值来计算时间片。nice值在CFS中被作为进程获得的处理器运行比的权重：越高的nice值（越低的优先级）进程获得更低的处理器使用权重，更低的nice值（越高的优先级）的讲程获得更高的处理器使用权重。

每个进程都按其权重在全部可运行进程中所占比例的“时间片”来运行，为了计算准确的时间片，CFS为完美多任务中的无限小调度周期的近似值设立了一个目标。而这个目标称作“目标延迟”，越小的调度周期将带来越好的交互性，同时也更接近完美的多任务。但是你必须承受更高的切换代价和更差的系统总吞吐能力。

总结一下，任何进程所获得的处理器时间是由**它自己和其他所有可运行进程nice值的相对差值**决定的。nice值对时间片的作用不再是算数加权，而是几何加权。任何nice值对应的绝对时间不再是一个绝对值，而是处理器的使用比。CFS称为公平调度器是因为**它确保给每个进程公平的处理器使用比**。正如我们知道的，CFS不是完美的公平，它只是近乎完美的多任务。但是它确实在多进程环境下，降低了调度延迟带来的不公平性。

CFS不再有时间片的概念，但是它也必须维护每个进程运行的时间记账，因为它需要确保每个进程只在公平分配给它的处理器时间内运行。CFS使用调度器实体结构（定义在文件`<linux/sched.h>`的struct_sched_entity中）来追踪进程运行记账，sched_entity作为一个名为se的成员变量，嵌入在进程描述符struct task_struct中

**vruntime变量存放进程的虚拟运行时间**，该运行时间（花在运行上的时间和）的计算是经过了所有可运行进程总数的标准化（或者说是被**加权**的）。虚拟时间是以ns为单位的，所以vruntime和定时器节拍不再相关。虚拟运行时间可以帮助我们逼近CFS模型所追求的“理想多任务处理器”。CFS使用vruntime变量来记录一个程序到底运行了多长时间以及它还应该再运行多久。

vruntime的更新：系统定时器周期性调用update_curr()函数来更新sched_enetity的vruntime，update_curr()计算了当前进程的执行时间，并且将其存放在变量delta_exec中。然后它又将运行时间传递给了__update_curr()，由后者再根据**当前可运行进程总数对运行时间进行加权计算**。最终将上述的权重值加在当前运行进程的vruntime上。

CFS调度算法的核心：选择具有最小vruntime的任务。而为了加速这个寻找最小vruntime的过程，CFS使用**红黑树**来组织所有可运行进程，在Linux中，红黑树简称rbtree，它是自平衡二叉搜索树，rbtree最左边叶子节点就是最小vruntime。在进程变为可运行状态（被唤醒）或者是通过fork()调用第一次创建进程时，CFS将进程加入rbtree；进程堵塞（变为不可运行态）或者终止时（结束运行）时，CFS将进程从rbtree中删除

#### 实时调度策略

Linux 提供了两种实时调度策略：SCHED_FIFO和SCHED_RR。而普通的、非实时的调度策略是SCHED_NORMAL（CFS使用）。

SCHED_FIFO实现了一种简单的、先入先出的调度算法：它不使用时间片。处于可运行状态的SCHED_FIFO级的进程会比任何SCHED_NORMAL级的进程都先得到调度。一旦一个SCHED_FIFO级进程处于可执行状态，就会一直执行，直到它自己受阻塞或显式地释放处理器为止；它不基于时间片，可以一直执行下去。只有更高优先级的SCHED_FIFO或者SCHED_RR任务才能抢占SCHED_FIFO任务。如果有两个或者更多的同优先级的SCHED_FIFO级进程，它们会轮流执行，但是依然只有在它们愿意让出处理器时才会退出。只要有SCHED_FIFO级进程在执行，其他级别较低的进程就只能等待它变为不可运行态后才有机会执行。

SCHED_RR是带有时间片的 SCHED_FIFO——这是一种实时轮流调度算法。当SCHED_RR任务耗尽它的时间片时，在同一优先级的其他实时进程被轮流调度。对于SCHED_FIFO进程，高优先级总是立即抢占低优先级，但低优先级进程决不能抢占SCHED_RR任务，即使它的时间片耗尽。

这两种实时算法实现的都是静态优先级。内核不为实时进程计算动态优先级。

调度程序没有太复杂的原理。最大限度地利用处理器时间的原则是，只要有可以执行的进程，那么就总会有进程正在执行。但是只要系统中可运行的进程的数目比处理器的个数多，就注

### Linux中的定时器与时间管理

#### 时间概念

周期性产生的事件——比如每10ms一次——都是由系统定时器驱动的。系统定时器是一种**可编程硬件芯片**，它能以固定频率产生中断。该中断就是所谓的**定时器中断**，它所对应的中断处理程序负责更新系统时间，也负责执行需要周期性运行的任务。

内核知道连续两次时钟中断的间隔时间，这个间隔时间就称为节拍（tick），它等于节拍率分之一(1/(tick rate))秒。内核就是靠这种已知的时钟中断间隔来计算墙上时间和系统运行时间的。**墙上时间（也就是实际时间）**对用户空间的应用程序来说是最重要的。内核通过控制时钟中断维护实际时间，另外内核也为用户空间提供了一组系统调用以获取实际日期和实际时间。**系统运行时间（自系统启动开始所经的时间）**对用户空间和内核都很有用，因为许多程序都必须清楚流逝的时间。通过两次（现在和以后）读取运行时间再计算它们的差，就可以得到相对的流逝的时间了。

#### 节拍率

**系统定时器频率（节拍率）**是通过静态预处理定义的，也就是HZ（赫兹），在系统启动时按照HZ值对硬件进行设置。体系结构不同，HZ的值也不同，大部分是100HZ，又有1000HZ。编写内核代码时，不要认为HZ值是一个固定不变的值。

提高节拍率意味着时钟中断产生得更加频繁，所以中断处理程序也会更频繁地执行。如此一来会给整个系统带来如下好处：

- 更高的时钟中断**解析度（resolution）**可提高时间驱动事件的解析度。100HZ的时钟的执行粒度为10ms，周期事件最快为每10ms运行一次，而不可能有更高的精度，但是1000HZ的解析度就是1ms，精细了十倍。
- 提高了时间驱动事件的**准确度（accuracy）**。假定内核在某个随机时刻触发定时器，而它可能在任何时间超时，但由于只有在时钟中断到来时才可能执行它，**所以平均误差大约为半个时钟中断周期**。比如说，如果时钟周期为HZ=100，那么事件平均在设定时刻的+/-5ms内发生，所以平均误差为5ms。如果HZ=1000，那么平均误差可降低到0.5ms——准确度提高了10倍。

节拍率越高，意味着时钟中断频率越高，也就意味着系统负担越重。因为处理器必须花时间来执行时钟中断处理程序，所以节拍率越高，中断处理程序占用的处理器的时间越多。这样不但减少了处理器处理其他工作的时间，而且还会更频繁地打乱处理器高速缓存并增加耗电。最后的结论是：至少在现代计算机系统上，时钟频率为1000HZ不会导致难以接受的负担，并且不会对系统性能造成较大的影响，尽管如此，2.6版本的内核还是允许在编译内核时选定不同的HZ值

#### jiffies

全局变量jiffies用来记录自系统启动以来产生的节拍的总数。启动时，内核将该变量初始化为0，此后，每次时钟中断处理程序就会增加该变量的值。因为一秒内时钟中断的次数等于HZ，所以jiffies一秒内增加的值也就为HZ。系统运行时间以秒为单位计算，就等于jiffies/HZ。

jiffies定义于文件`<linux/jiffes.h>`中：

```c++
extern unsigned long volatile jiffies;
```

关键字volatile指示编译器在每次访问变量时都重新从主内存中获得，而不是通过寄存器中的变量别名来访问

jiffies变量总是**无符号长整数（unsigned long）**，因此，在32位体系结构上是32位，在64位体系结构上是64位。由于性能与历史的原因，主要还考虑到与现有内核代码的兼容性，内核开发者希望jiffies依然为unsigned long。内核用了很巧妙的链接程序，用jiffies_64变量的初值覆盖了jiffies变量，jiffies取整个64位jiffies_64变量的低32位。

和任何C整型一样，当jiffies变量的值超过它的最大存放范围后就会发生溢出。如果节拍计数达到了最大值后还要继续增加的话，它的值会**回绕（wrap around）**到0。

考虑下面的代码，如果jiffies重新回绕为0，那么timeout永远都比jiffies大，这明显不是我们希望的

```c++
unsigned long timeout = jiffies + HZ/2;/*0.5秒后超时*/
/*执行一些任务..*/
/*然后查看是否花的时间过长*/
if（timeout>jiffies）{
    /*没有超时，很好..*/
} else {
    /*超时了，发生错误...*/
```

幸好，内核提供了四个宏来帮助比较节拍计数，它们能正确地处理节拍计数回绕情况。这些宏定义在文件`<linux/jiffies.h>`中，这里列出的去是简化版，其中unkown参数通常是jifies，known参数是需要对比的值

```c++
#define time_after(unknown，known)((long)(known)-(long)(unknown)<0)
#define time_before(unknown，known)((long)(unknown)-(long)(known)<0)
#define time_after_eq(unknown，known)((long)(unknown)-(long)(known)>=0)
#define time_before_eg(unknown，known)((long)(knowm)-(long)(unknown)>=0)
```

> 为了便于说明，我们假设jiffies是单字节的无符号数，范围为0~255。假如jiffies开始为250，由于是无符号数据，那么它在机器中实际存储的补码为11111010，记为J1；timeout如果被设为252，实际存储为11111100；而过了一会jiffies发生回绕编变成了1，实际存储变为00000001，记为J2。 那么此时如果按照无符号数比较其大小关系，有： `J1<timeout & J2 <timeout`，这样的结果与实际的时间节拍统计是不符的，但是如果我们按照有符号数来比较会有什么结果呢？J1如果按照有符号数读取，首先从补码转换成原码：10000110，转换成十进制为－6；timeout按照有符号数读取，首先从补码转换成原码：10000100，转换成十进制为－4；J2按照有符号数读取，首先从补码转换成原码：00000001，转换成十进制为1；这样它们的大小关系为：`J1<timeout<J2` 。 这与实际的节拍计数就吻合了，以上内核定义的几个宏就是通过这种方式巧妙解决jiffies回绕问题的。

#### 硬时钟和定时器

**实时时钟（RTC）**是用来持久存放系统时间的设备，即便系统关闭后，它也可以靠主板上的微型电池提供的电力保持系统的计时。在PC体系结构中，RTC和CMOS集成在一起，而且RTC的运行和BIOS的保存设置都是通过同一个电池供电的。当系统启动时，内核通过读取RTC来初始化墙上时间，该时间存放在xtime变量中。

**系统定时器**是内核定时机制中最为重要的角色。尽管不同体系结构中的定时器实现不尽相同，但是系统定时器的根本思想并没有区别——提供一种周期性触发中断机制。有些体系结构是通过对**电子晶振**进行分频来实现系统定时器，还有些体系结构则提供了一**个衰减测量器（decrementer）**——衰减测量器设置一个初始值，该值以固定频率递减，当减到零时，触发一个中断。无论哪种情况，其效果都一样。

#### 时钟中断处理程序

- 获得xtime_lock锁，以便对访问jiffies_64和墙上时间xtime进行保护。
- 需要时应答或重新设置系统时钟。
- 周期性地使用墙上时间更新实时时钟。
- 调用体系结构无关的时钟例程：tick periodic()。
- 给jiffies_64变量增加1（这个操作即使是在32位体系结构上也是安全的，因为前面已经获得了xtime_lock锁）。
- 更新资源消耗的统计值，比如当前进程所消耗的系统时间和用户时间。
- 执行已经到期的动态定时器（11.6节将讨论）。
- 执行第4章曾讨论的sheduler_tick）函数。
- 更新墙上时间，该时间存放在xtime变量中。
- 计算平均负载值。

#### 实际时间

当前实际时间（墙上时间）定义在文件`kernel/time/timekeeping.c`中：xtime，timespec数据结构定义在文件`<linux/time.h>`中，形式如下：

```c++
struct timespec xtime;
struct timespec{
    kernel_time_t tv_sec；/*秒*/
    long tv_nsec；/*ns*/
};
```

xtime.tv_sec以秒为单位，存放着自1970年1月1日（UTC）以来经过的时间，1970年1月1日被称为纪元，多数Unix系统的墙上时间都是基于该纪元而言的。xtime.v_nsec记录自上一秒开始经过的ns数。

读写xtime变量需要使用xtime_lock锁，该锁不是普通自旋锁而是一个**seq锁**

从用户空间取得墙上时间的主要接口是gettimeofday()，在内核中对应系统调用为sys_gettimeofday()，定义于`kernel/time.c`：

#### 定时器

定时器（有时也称为动态定时器或内核定时器）是管理内核流逝的时间的基础。

定时器的使用很简单。你只需要执行一些初始化工作，设置一个超时时间，指定超时发生后执行的函数，然后激活定时器就可以了。指定的函数将在定时器到期时自动执行。注意定时器并不周期运行，它在超时后就自行撤销，这也正是这种定时器被称为动态定时器e的一个原因；动态定时器不断地创建和撤销，而且它的运行次数也不受限制。定时器在内核中应用得非常普遍。

定时器由结构timer_list表示，定义在文件`<linux/timer.h>`中。

```c++
struct timer_list{
    struct list_head entry;/*定时器链表的入口*/
    unsigned long expires;/*以jiffies为单位的定时值*/
    void (*function) (unsigned long);/*定时器处理函数*/
    unsigned long data;./*传给处理函数的长整型参数*/
    struct tvec_t_base_s*base;/*定时器内部值，用户不要使用*/
};
```

Linux的定时器机制（时间轮与红黑树）

前提：Linux根据时钟源设备启动tick中断，用tick计时，基于Hz，精度是1/Hz

低精度：用**时间轮（timing wheel）**机制维护定时事件，时间轮的触发基于tick，**周期触发**，内核根据时间轮处理超时事件

高精度：hrtimer（high resolution），**基于事件触发**，基于**红黑树**，将高精度时钟硬件的下次中断触发设置为红黑树最早到期的时间，到期后又取得下一个最早到期时间（类似于最小堆）

#### 延迟执行

忙等待，最笨的方法

```c++
unsigned long timeout=jiffies+10;/*10个节拍*/
while(time_before(jiffies，timeout))
    ...
```

更好的方法应该是在代码等待时，允许内核重新调度执行其他任务，cond_resched0函数将调度一个新程序投入运行：

```c++
unsigned long delay=jiffies +5*HZ;
while(time_before(jiffies，timeout))
    cond_resched();
```

对于短延迟，内核提供了三个可以处理ms、ns和ms级别的延迟函数，它们定义在文件`<linux/delay.h>`和`<asm/delay.h>`中，可以看到它们并不使用jiffies：

```c++
void udelay(unsigned long usecs) // 利用忙循环将任务延迟指定的ms数后运行，后者延迟指定的ms数。
void ndelay(unsigned long nsecs)
void mdelay(unsigned long msecs)
```

udelay())函数依靠执行数次循环达到延迟效果，而mdelay()函数又是通过udelay()函数实现的。因为内核知道处理器在1秒内能执行多少次循环（BogoMIPS值记录处理器在给定时间内忙循环执行的次数），所以udelay()函数仅仅需要根据指定的延迟时间在1秒中占的比例，就能决定需要进行多少次循环即可达到要求的推迟时间。

### fork,wait,exec,vfork

fork

1. 父进程使用fork拷贝出来一个父进程的副本，只拷贝了父进程的地址空间，两个进程都读同一块内存，当有进程写的时候使用**写时拷贝**机制分配内存
2. fork从父进程返回子进程的pid，从子进程返回0.
3. 具体流程：为子进程开辟一块新的用户空间的进程描述符，复制父进程的虚拟地址空间。为这个子进程分配一个 PID，设置其内存映射，赋予它访问父进程文件的权限，注册并启动
4. 现代Linux内核中，fork()一般由clone()系统调用实现

wait

1. 调用了wait的父进程将会发生阻塞，直到有子进程状态改变,执行成功返回0，错误返回-1。

exec函数族

- 总共6个
  - 后缀包含p的函数会在PATH路径下寻找程序
  - 后缀不包含p的需要输入程序的绝对路径
  - 后缀包含v的以数组形式接受参数
  - 后缀包含l的以列表形式接受参数
  - 后缀包含e的接收环境变量
- exec函数可以加载一个elf文件去替换当前进程，一个进程一旦调用exec类函数，它本身就"死亡"了，系统把代码段替换成新的程序的代码，废弃原有的数据段和堆栈段，并为新程序分配新的数据段与堆栈段，唯一留下的，就是进程号，也就是说，对系统而言，还是同一个进程，不过已经是另一个程序了
- exec执行成功则子进程从新的程序开始运行，无返回值，执行失败返回-1

vfork

1. fork()会复制父进程的虚拟地址空间，而vfork()不会复制，直接让子进程**共用**父进程的虚拟地址空间
2. fork()的父子进程的执行次序不确定；vfork()保证子进程先运行，在调用exec或exit之前与父进程数据是共享的，在它调用exec或exit之后父进程才可能被调度运行，如果调用exec或exit之前子进程依赖于父进程的某些动作，则会导致死锁
3. vfork的出现原因：在实现写时复制之前，为了避免fork后立刻执行exec所造成的地址空间的浪费

### 孤儿进程&僵尸进程

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

### 写时复制是什么

1. 写时复制（Copy-On-Write, COW）是一种惰性优化方法，以减少fork时对父进程空间进程整体复制带来的开销
2. 如果有多个进程要读取同一资源的副本，那么复制是不必要的，每个进程只要保存一个指向这个资源的指针就可以了，这样就存在着幻觉：每个进程好像独占那个资源，从而避免复制的开销
3. 如果一个进程要修改自己的那份资源“副本”，那么就会复制那份资源，并把复制的那份提供给进程，复制过程对于进程来说是透明的。这个进程就可以修改复制后的资源了，同时其他的进程仍然共享那份没有修改过的资源
4. 如果进程从来就不需要修改资源，则不需要进行复制。惰性算法的好处就在于它们尽量推迟代价高昂的操作，直到必要的时刻才会去执行
5. 在使用虚拟内存的情况下，写时复制是以页为基础进行的
6. 在fork()结束后，父进程和子进程都相信它们有一个自己的地址空间，但实际上它们共享了父进程的原始页
7. 在内核实现中，写时复制触发**缺页中断**，处理缺页中断的方法是对该页进行一次透明复制

### 协程是什么

协程（coroutine）又叫微线程、纤程，完全位于用户态，一个程序可以有多个协程

协程的执行过程类似于子例程，允许子例程在特定地方挂起和恢复

协程是一种伪多线程，在一个线程内执行，**由用户切换**，由**用户选择切换时机**，**没有进入内核态**，只涉及CPU上下文切换，所以切换效率很高

最大的优点：如果是多线程，可能会因为单个线程处理很久而耗尽线程池资源，而协程理论上有**无限并发**，还可以有新的请求进来

缺点：协程适用于IO密集型，不适用于CPU密集型

libco是微信后台大规模使用的c/c++协程库。libco采用**epoll多路复用**使得一个线程处理多个socket连接，采用钩子函数hook住socket族函数，采用时间轮盘处理等待超时事件，采用协程栈保存、恢复每个协程上下文环境。

### 进程间通信IPC

每个进程都有独立的虚拟地址空间，任何一个进程的全局变量在另一个进程中都看不到，所以进程之间要交换数据必须通过内核,在内核中开辟一块缓冲区，进程A把数据从用户空间拷到内核缓冲区，进程B再从内核缓冲区把数据读走，内核提供的这种机制称为进程间通信。

- 管道：通信必须FIFO，包括匿名管道和有名管道，匿名管道只能用于具有亲缘关系的父子进程间的通信，有名管道还允许无亲缘关系进程间的通信，生命周期随进程
  - 所谓的管道，就是内核里面的一串缓存。从管道的一段写入的数据，实际上是缓存在内核中的，另一端读取，也就是从内核中读取这段数据。另外，管道传输的数据是无格式的流且大小受限。
  - shell的`|`就是创建了一个匿名管道，`int pipe(int fd[2])`
  - 管道传输是单向的，如果想双向就得创建两个管道
  - 为了IPC，可以用fork创建子进程，创建的子进程会复制父进程的文件描述符，两个进程各有两个「fd[0] 与 fd[1]」，因为父子进程可以同时写入读取，所以最好一个关闭fd[0]只保留写入的fd[1]，另一个关闭fd[1]只保留读取的fd[0]，
- 消息队列：消息的链表，存放在内核中并由消息队列标识符标识，生命周期随内核。消息队列传递的信息比信号要多，但还是不适合大数据传输，通信不必FIFO
  - msgget创建一个新的队列
  - msgsnd将消息发送到消息队列，
  - 而消息接收方可以使用msgrcv从队列中取消息。
- 信号量：它是一个计数器，可以用来控制多个进程对共享资源的访问，主要用于实现进程间的互斥与同步，而不是用于存储进程间通信数据
- 信号：可用做**异常事件**的通信，用于通知接收进程某个事件已经发生。主要作为进程间以及同一进程不同线程之间的同步手段。
  - 用`kill -l`命令可以知道所有信号，`kill -9 xx`可以产生SIGKILL信号，杀死pid为xx的信号；Ctrl+C 产生 SIGINT 信号，表示终止该进程；
  - Linux 对每种信号都规定了默认操作，也可以编写信号处理函数捕捉信号，还可以选择忽略信号
  - 有两种信号不能忽略：SIGSTOP 和 SIGKILL 信号。SIGSTOP 信号会通知当前正在运行的进程执行关闭操作，SIGKILL 信号会通知当前进程应该被杀死。
- **共享内存（最快的）**：多个进程可以访问同一块内存空间（减少了数据从用户态到内核态的拷贝），不同进程可以及时看到对方进程中对共享内存中数据的更新。实质上是**同一块物理内存被映射到进程A、B各自的虚拟地址空间**。这种方式需要依靠某种同步操作，如互斥锁和信号量等。
  - 最大共享内存32MB，可通过内核文件修改
  - shmget创建一个共享内存块
  - shmat将共享内存映射到自己的内存空间
  - shmdt将已连接的共享内存段分离进程
  - shmct控制共享内存段
  - 可以用mmap系统调用实现共享内存
- **套接字socket**：可用于不同机器间的进程通信，根据陈硕的建议，进程间通信只用TCP

```c
//管道
#include <unistd.h>
int pipe(int pipedes[2]) // 无名管道
int mkfifo(const char *pathname, mode_t mode) // 有名管道

// 消息队列
#include <sys/msg.h>
int msgget(key_t key, int msgflg) //创建
int msgctl(int msqid, int cmd, struct msqid_ds *buf) //设置/获取消息队列的属性值
int msgsnd(int msqid, const void *msgp, size_t msgsz, int msgflg) //发送消息到消息队列(添加到尾端)
ssize_t msgrcv(int msqid, void *msgp, size_t msgsz, long msgtyp, int msgflg) //接收消息

// 共享内存
#include <sys/shm.h>
int shmget(key_t key, size_t size, int shmflg) //创建一个共享内存空间
int shmctl(int shmid, int cmd, struct shmid_ds *buf) //对共享内存进程操作，包括：读取/设置状态，删除操作
void *shmat(int shmid, const void *shmaddr, int shmflg) //将共享内存空间挂载到进程中
int shmdt(const void *shmaddr) //将进程与共享内存空间分离 **(只是与共享内存不再有联系，并没有删除共享内存)**

// 信号
#include</usr/include/bits/signum.h>
```

### 线程间通信/同步

因为线程共享同一地址空间，所以线程间的通信目的主要是用于线程同步，所以线程没有像进程通信中的用于数据交换的通信机制。

各个线程可以访问进程中的公共变量，资源，所以使用多线程的过程中需要注意的问题是如何防止两个或两个以上的线程同时访问同一个数据，以免破坏数据的完整性。

1. 锁机制：包括互斥锁、条件变量、读写锁
    - 互斥锁提供了以排他方式防止数据结构被并发修改的方法。
    - 读写锁允许多个线程同时读共享数据，而对写操作是互斥的。
    - 条件变量可以以原子的方式阻塞进程，直到某个特定条件为真为止。对条件的测试是在互斥锁的保护下进行的。**条件变量始终与互斥锁一起使用**。
2. 信号量机制：包括无名线程信号量和命名线程信号量
3. 信号机制：类似进程间的信号处理

```c++
pthread_create();
pthread_join();
pthread_exit();

pthread_mutex_t my_lock;
pthread_mutex_init(&my_lock);
pthread_mutex_lock(&my_lock);
pthread_mutex_trylock (&my_lock);
pthread_mutex_unlock(&my_lock);
pthread_mutex_destroy(&my_lock);

pthread_cond_t my_cond;
pthread_cond_init(&my_cond);
pthread_cond_wait(&my_cond, &my_lock); // 等待条件变量通知
pthread_cond_signal(&my_cond); // 条件变量通知至少一个线程
pthread_cond_broadast(&my_cond); // 条件变量通知所有线程
pthread_cond_destroy(&my_cond);


sem_wait（sem_t *sem）//以原子操作的方式将信号量减1，如果信号量值为0，则sem_wait将被阻塞，直到这个信号量具有非0值。即P操作
sem_post（sem_t *sem) //以原子操作将信号量值+1。当信号量大于0时，其他正在调用sem_wait等待信号量的线程将被唤醒。即V操作
```

### 线程局部存储

**线程局部存储**/线程私有变量（Thread Local Storage，TLS）或线程私有数据（Thread Specific Data，TSD）用来将数据与一个正在执行的指定线程关联起来。

起因：进程中的全局变量与函数内定义的静态(static)变量，是各个线程都可以访问的共享变量。在一个线程修改的内存内容，对所有线程都生效。这是一个优点也是一个缺点。说它是优点，线程的数据交换变得非常快捷。说它是缺点，一个线程死掉了，其它线程也性命不保; 多个线程访问共享数据，需要昂贵的同步开销，也容易造成同步相关的BUG。

如果需要在一个线程内部的各个函数调用都能访问、但其它线程不能访问的变量，这就可以用TLS实现。

TLS实现：

- **一键多值**，即一个键对应多个数值。访问数据时都是通过键值来访问，多个线程好像在访问同一个键，其实访问不同的值。
- 创建一个键，所有线程共用，在各个线程内部，都使用这个**公用的键**来指代自己的线程数据，但是在不同的线程中，值时不同的，这就是线程局部存储。

```c++
pthread_key_create
pthread_key_delete
pthread_setspecific
pthread_getspecific
```

### 哲学家进餐问题

重点解决哲学家进餐的死锁问题以及饥饿问题

每次试探左右两个叉子，如果两个都空闲，则拿起来，这相当于加大锁的粒度

即让偶数编号的哲学家「先拿左边的叉子后拿右边的叉子」，奇数编号的哲学家「先拿右边的叉子后拿左边的叉子」。

破坏占有和等待，设置超时时间，时间一到，拿起的一个叉子必须放下，消除了死锁，但有可能产生活锁

破坏资源环路等待，给资源的分配排序，必须按一定顺序拿起叉子

### 信号量与互斥锁的区别

二进制信号量与互斥锁在实现上很像，但是在设计上细微差别。

互斥锁强调**对资源的保护**，锁只能由当前线程释放，**只能用来构造临界区**。可以认为是二值信号量/互斥信号量

- 任何时刻中只有一个任务可以持有mutex，也就是说，mutex的使用计数永远是1。
- 给mutex 上锁者必须负责给其再解锁——你不能在一个上下文中锁定一个mutex，而在另一个上下文中给它解锁。这个限制使得mutex不适合内核同用户空间复杂的同步场景。最常使用的方式是：在同一上下文中上锁和解锁。
- 递归地上锁和解锁是不允许的。也就是说，你不能递归地持有同一个锁，同样你也不能再去解锁一个已经被解开的mutex.
- 当持有一个mutex时，进程不可以退出。

信号量强调**调度线程**，通过P(down)V(up)操作让线程在临界区内的执行顺序合理，

- Linux中的信号量是一**种睡眠锁**。如果有一个任务试图获得一个不可用（已经被占用）的信号量时，信号量会将其推进一个等待队列，然后让其睡眠。这时处理器能重获自由，从而去执行其他代码。
- 当持有的信号量可用（被释放）后，处于等待队列中的那个任务将被唤醒，并获得该信号量。

最佳实践：建议首选互斥锁mutex。当你写新代码时，只有碰到特殊场合（一般是很底层代码）才会需要使用信号量。

### Linux内核的锁机制

1. 互斥锁：mutex，用于保证在任何时刻，都只能有一个线程访问该对象。当获取锁操作失败时，线程会进入**睡眠**，等待锁释放时被唤醒
2. 读写锁：rwlock，也叫**共享互斥锁**，读模式共享和写模式互斥，可以允许多个线程同时获得读操作。但是同一时刻**只有一个线程可以获得写锁**。写锁会阻塞其它读写锁。
   - 读优先（默认模式）：写者、读者互斥访问文件资源，任何线程都可以对其进行读加锁操作，但是所有试图进行写加锁操作的线程都会被阻塞，直到所有的读线程都解锁，因此读写锁很适合读次数远远大于写的情况。这种情况需要考虑写饥饿问题，也就是大量的读一直轮不到写，因此需要设置公平的读写策略
   - 写优先：写者线程的优先级高于读者线程，**唤醒时优先考虑写者**。适用于读取数据的频率远远大于写数据的频率的场合。
   - 写优先的实现：读的请求发生时，不先去试图获得读锁，而是去检查有没有写的请求正在等待，如果有写的请求正在等待，则读的请求必须先处于等待状态。让写的请求完成之后，发现已经没有写的请求在等待了，才去试图获得读的锁。
3. 自旋锁：spinlock，**轮询忙等待**，在任何时刻同样只能有一个线程访问对象。但是当获取锁操作失败时，不会进入睡眠，而是会在原地自旋，直到锁被释放。这样节省了线程从睡眠状态到被唤醒期间的消耗，在加锁时间短暂的环境下会极大的提高效率。但如果加锁时间过长，则会非常浪费CPU资源。**Linux自旋锁是不可递归的**
    > 问：两个进程访问临界区资源，会不会出现都获得自旋锁的情况？
    > 答：单核CPU且开了抢占可以
4. RCU：即read-copy-update，**支持多读多写同时加锁**，在修改数据时，首先需要读取数据，然后生成一个副本，对副本进行修改。修改完成后，再将老数据update成新的数据（感觉有点像写时复制）。使用RCU时，**读者几乎不需要开销**，既不需要获得锁，也不使用原子指令，不会导致锁竞争，因此就不用考虑死锁问题了。而**写者开销较大**，它需要复制被修改的数据，还必须使用锁机制同步并行其它写者的修改操作。在有大量读操作，少量写操作的情况下效率非常高。
5. BKL：大内核锁，全局自旋锁。持有BKL的任务仍然可以睡眠。因为当任务无法被调度时，所加锁会自动被丢弃；当任务被调度时，锁又会被重新获得。当然，这并不是说，当任务持有BKL时，睡眠是安全的，仅仅是可以这样做，因为睡眠不会造成任务死锁。**BKL是一种递归锁**。一个进程可以多次请求一个锁，并不会像自旋锁那样产生死锁现象。
6. 顺序锁：通常简称seq锁，是在2.6版本内核中才引入的一种新型锁。这种锁提供了一种很简单的机制，用于读写共享数据。实现这种锁主要依靠一个**序列计数器**。当有疑义的数据被写入时，会得到一个锁，并且序列值会增加。在读取数据之前和之后，序列号都被读取。如果读取的序列号值相同，说明在读操作进行的过程中没有被写操作打断过。此外，如果读取的值是偶数，那么就表明写操作没有发生（要明白因为锁的初值是0，所以写锁会使值成奇数，释放的时候变成偶数）。使用seq锁中最有说服力的是jiffies。该变量存储了**Linux机器启动到当前的时间**。如果你有以下需求，seq锁是最佳选择：
    - 你的数据存在很多读者。
    - 你的数据写者很少。
    - 虽然写者很少，但是你希望写优先于读，而且不允许读者让写者饥饿。
    - 你的数据很简单，如简单结构，甚至是简单的整型——在某些场合，你是不能使用原子量的。

Windows下的Mutex和Critical Section是可递归的。Linux下的pthread_mutex_t锁默认是非递归的。在Linux中可以显式设置PTHREAD_MUTEX_RECURSIVE属性，将pthread_mutex_t设为递归锁避免这种场景。**不用递归锁通常被认为是一件好事**，虽然递归锁缓和了自死锁问题，但它们很容易使加锁逻辑变得杂乱无章。

同一个线程可以多次获取同一个递归锁，不会产生死锁。而如果一个线程多次获取同一个非递归锁，则会产生死锁。

#### 互斥锁与信号量的区别

二进制信号量与互斥锁在实现上很像，但是在设计上细微差别。

互斥锁强调**对资源的保护**，锁只能由当前线程释放，**只能用来构造临界区**。

信号量强调**调度线程**，通过PV操作让线程在临界区内的执行顺序合理，

#### 互斥锁与自旋锁的区别

- 互斥锁加锁失败后，线程会释放 CPU ，给其他线程；
  - 互斥锁加锁失败时，有两次CPU上下文切换的成本：加锁失败的线程从运行变为睡眠；解锁时，之前睡眠线程变为就绪，合适的时间，CPU会切换给就绪线程运行
  - 场景：如果你能确定被锁住的代码执行时间很短，不应该用互斥锁，否则上下文切换的开销很大
- 自旋锁加锁失败后，线程会忙等待，直到它拿到锁；
  - 自旋锁是通过 CPU 提供的 **CAS 函数（Compare And Swap）**，在「用户态」完成加锁和解锁操作，不会主动产生线程上下文切换，所以相比互斥锁来说，会快一些，开销也小一些。
  - 使用自旋锁的时候，当发生多线程竞争锁的情况，加锁失败的线程会「忙等待」，直到它拿到锁。这里的「忙等待」可以用 while 循环等待实现，不过最好是使用 CPU 提供的 PAUSE 指令来实现「忙等待」，因为可以减少循环等待时的耗电量。
  - 注意，单核CPU必须开启抢占，否则自旋的线程永远不会放弃 CPU。
  - 场景：自旋锁开销少，在多核系统下一般不会主动产生线程切换，适合异步、协程等在用户态切换请求的编程方式，但如果被锁住的代码执行时间过长，自旋的线程会长时间占用 CPU 资源，

顺序和屏障：在执行程序时，为了提高性能，编译器和处理器常常会对指令做重排序。但是我们希望程序代码以指定顺序读写

- rmb()方法提供了一个“读”内存屏障，它确保跨越rmb()的载入动作不会发生重排序。也就是说，在rmb()之前的载入操作不会被重新排在该调用之后，同理，在rmb()之后的载入操作不会被重新排在该调用之前。
- wmb()方法提供了一个“写”内存屏障，这个函数的功能和rmb()类似，区别仅仅是它是针对存储而非载入——它确保跨越屏障的存储不发生重排序。
- mb()方法既提供了读屏障也提供了写屏障。载入和存储动作都不会跨越屏障重新排序。这是因为一条单独的指令（通常和rmb0使用同一个指令）既可以提供载入屏障，也可以提供存储屏障。
- barrier()方法可以防止**编译器**跨屏障对载入或存储操作进行优化。。前面讨论的内存屏障可以完成编译器屏障的功能，但是编译器屏障要比内存屏障轻量（它实际上是轻快的）得多。实际上，编译器屏障几乎是空闲的，因为它只防止编译器可能重排指令。

#### 自适应mutex锁

- 自旋锁与mutex锁的混合，如果锁持有者当前正运行在另一个CPU上，线程会自旋，否则线程会阻塞

- 自适应mutex锁支持低延时访问又不浪费CPU资源，2009年应用到Linux上，叫做自适应自旋mutex（adaptive spinning mutex）

### 磁盘IO

- 寻道时间Tseek：是指将读写磁头移动至正确的磁道上所需要的时间。寻道时间越短，I/O 操作越快，目前磁盘的平均寻道时间一般在 3-15ms。
- 旋转延迟Trotation：是指盘片旋转将请求数据所在的扇区移动到读写磁盘下方所需要的时间。旋转延迟取决于磁盘转速，通常用磁盘旋转一周所需时间的 1/2 表示。
- IOPS：每秒读写次数，即指每秒内系统能处理的 I/O 请求数量。随机读写频繁的应用，如小文件存储等，关注随机读写性能，IOPS 是关键衡量指标。可以推算出磁盘的 IOPS = 1000ms / (Tseek + Trotation + Transfer)，如果忽略数据传输时间，理论上可以计算出随机读写最大的 IOPS。
> IOPS并不平等，对于机械磁盘，5000IOPS的连续负载可能比1000IOPS的随机负载快得多
- 吞吐量（Throughput），指单位时间内可以成功传输的数据数量。顺序读写频繁的应用，如视频点播，关注连续读写性能、数据吞吐量是关键衡量指标。

在许多的开源框架如 Kafka、HBase 中，都通过**追加写**的方式来尽可能的将随机 I/O 转换为顺序 I/O，以此来降低寻址时间和旋转延时，从而最大限度的提高 IOPS。

### 磁盘寻道算法

各个进程可能会不断提出不同的对磁盘进行读/写操作的请求。由于有时候这些进程的发送请求的速度比磁盘响应的还要快，因此我们有必要为每个磁盘设备建立一个等待队列，常用的磁盘调度算法有以下四种：

- 先来先服务算法（FCFS）
  - 根据进程请求访问磁盘的先后次序进行调度。
  - 此算法的优点是公平、简单
  - 未优化，吞吐量小，平均寻道时间长
- 最短寻道时间优先算法（SSTF）
  - 优先访问与当前磁头最近的磁道
  - 吞吐量大
  - 但不一定保证平均寻道时间小
  - 不均匀，两侧磁道频率低于重甲磁道
- **电梯算法**/扫描算法（SCAN）
  - 不仅考虑到欲访问的磁道与当前磁道的距离，更优先考虑的是磁头的当前移动方向
  - 避免饥饿
  - 克服了最短寻道时间优先算法的不均匀以及平均响应时间变化幅度大的缺点
- 循环扫描算法（CSCAN）
  - 对扫描算法的改进，原扫描算法当磁头到达磁盘端头，会反向移动，很大可能扫过的是刚才已经访问过的，所以浪费时间
  - 循环扫描算法规定**磁头只能单向移动**，当磁头到达磁盘端头，会立即移动到另一端，再单向扫描

在Linux中，除了电梯算法（Linus的第一版IO调度算法），还有**最终期限I/O调度**、**预测I/O调度**、**完全公正的排队I/O调度**、**空操作**

### CPU调度算法

以下概念指操作系统的**宏观概念**，而Linux内核调度器的CFS算法是**工程化落地**

对于单处理器系统，每次只允许一个进程运行，任何其他进程必须等待，直到CPU空闲能被调度为止，**多道程序**的目的是在任何时候都有某些进程在运行，以使CPU使用率最大化。

- 先到先服务FCFS，用了FIFO队列，非抢占
- 轮转法调度Round Robin，就绪队列作为循环队列，按**时间片（Quantum）**切换，一般20ms~50ms
- 最短作业优先调度SJF，先处理短进程，平均等待时间最小，所以是**最佳**的，但是很难知道每个作业要多少实现，所以不太现实
- 优先级调度，每个进程都被赋予一个优先级，优先级高的进程优先运行，会有**饥饿**现象，低优先级的进程永远得不到调度
- 彩票调度，为进程提供各种系统资源（例如 CPU 时间）的彩票，当做出一个调度决策的时候，就随机抽出一张彩票，拥有彩票的进程将获得该资源
- 多级队列调度，根据进程的属性（如内存大小、类型、优先级）分到特定队列，不同队列执行不同的调度算法
- 多级反馈队列调度，允许进程在队列之间移动
  - 如果进程使用过多的CPU时间，那么它会被移到更低的优先级队列。
  - 这种方案将I/O密集型和交互进程放在更高优先级队列上。
  - 此外，在较低优先级队列中等待过长的进程会被移到更高优先级队列。这种形式的老化可阻止饥饿的发生。

**饥饿(starvation)**是指某进程因为优先级的关系一直得不到CPU的调度，可能永远处于等待/就绪状态；定期提升进程的优先级

### CPU上下文切换

上下文包括

- CPU寄存器：CPU内置,容量小,速度极快的内存
- 程序计数器：CPU正在执行指令的位置）。

上下文切换

- 把前一个任务的CPU上下文(寄存器和程序计数器)**保存**起来,然后**加载**新任务的上下文到寄存器和程序计数器，最后**跳**到程序计数器指向的新位置,运行新任务。
- 而这些保存下来的上下文，会存储在系统内核中，并在任务重新调度执行时**再次加载**进来。这样就能保证任务原来的状态不受影响，让任务**看起来还是连续运行**。

根据任务的不同，上下文切换可以分为以下三种类型

- 进程上下文切换
  - 进程的运行空间分为用户空间和内核空间
  - 进程是由内核来管理和调度的，进程的切换只能发生在内核态
  - 进程的上下文切换就比系统调用时多了一步：在保存内核态资源（当前进程的内核状态和 CPU 寄存器）之前，需要先把该进程的用户态资源（虚拟内存、栈等）保存下来；而加载了下一进程的内核态后，还需要刷新进程的虚拟内存和用户栈。
- 线程上下文切换
  - 线程与进程最大的区别在于：**线程是调度的基本单位**，而**进程则是资源拥有的基本单位**。说白了，所谓内核中的任务调度，实际上的调度对象是线程；而进程只是给线程提供了虚拟内存、全局变量等资源。
- 中断上下文切换
  - 为了快速响应硬件的事件，中断处理会打断进程的正常调度和执行，转而调用中断处理程序，响应设备事件。而在打断其他进程时，就需要将进程当前的状态保存下来，这样在中断结束后，进程仍然可以从原来的状态恢复运行。
  - 跟进程上下文不同，中断上下文切换并不涉及到进程的用户态。
  - 中断上下文，其实只包括内核态中断服务程序执行所必需的状态，包括 CPU 寄存器、内核堆栈、硬件中断参数等。

一次系统调用的过程，其实是发生了两次 CPU 上下文切换（用户态-内核态-用户态）

一次上下文切换的时间大概是若干微秒

### 系统调用

- 系统调用是处于用户态的程序向内核请求更高权限的资源的服务，提供了用户程序与内核之间的接口
- 系统调用过程中，并不会涉及到虚拟内存等进程用户态的资源，也不会切换进程
- 系统调用过程通常称为特权模式切换，而不是上下文切换。系统调用属于同进程内的 CPU 上下文切换
- 对文件进行写操作, c语言的open, write, fork, vfork，socket系列等等都是系统调用
- strace是Linux环境下的一款程序调试工具，用来监察一个应用程序所使用的系统调用及它所接收的系统信息
- ptrace是在Unix和一些类Unix操作系统中发现的系统调用。通过使用ptrace，一个进程可以控制另一个进程，从而使控制器能够检查和操纵其目标的内部状态

#### 系统调用处理程序

用户空间的程序无法直接执行内核代码。它们不能直接调用内核空间中的函数，因为内核驻留在受保护的地址空间上。如果进程可以直接在内核的地址空间上读写的话，系统的安全性和稳定性将不复存在。

通知内核的机制是靠**软中断**实现的：通过引发一个**异常**来促使系统切换到内核态去**执行异常处理程序**。此时的异常处理程序实际上就是系统调用处理程序。在x86系统上预定义的软中断是**中断号128**，通过int $0x80指令触发该中断。这条指令会触发一个异常导致系统切换到内核态并执行第128号异常处理程序，而该程序正是系统调用处理程序。这个处理程序名字起得很贴切，叫**system_call()**。它与硬件体系结构紧密相关。

因为所有的系统调用陷入内核的方式都一样，所以必须将**系统调用号**一并传给内核，在x86上，系统调用号是用eax寄存器传递给内核的，system_call()函数检验合法性后就执行相应的系统调用。除了系统调用号以外，大部分系统调用都还需要一些外部的参数输入，这些参数也放在寄存器里传递给内核，如果寄存器不够装入所有参数，则用一个单独的寄存器存放指向所有这些参数在用户地址空间的指针。

给用户空间的返回值也通过寄存器传递。在x86系统上，它存放在eax寄存器中。

#### 实现系统调用

检验合法性必不可少！

为了同用尸空同与入数话，内核提供了copy_to_user()，它需要三个参数。第一个参效是进程空间中的目的内存地址，第二个是内核空间内的源地址，最后一个参数是需要拷贝的数据长度（字节数）。

为了从用户空间读取数据，内核提供了copy_from_user()，它和copy_to_user()相似。该函数把第二个参数指定的位置上的数据拷贝到第一个参数指定的位置上，拷贝的数据长度由第三个参数决定。

下面是一个简单的例子，调用这两个系统调用把用户空间的数据从一个位置复制到另一个位置，内核只是作为中转站而已

```c
/*
*si1ly_copy没有实际价值的系统调用，它把1en字节的数据从'src’拷贝到’dst'，毫无理由地让内核空
*间作为中转站。但这的确是个好例子
*/
SYSCALL_DEFINE3(silly_copy，unsigned long *src, unsigned long *dst, unsigned long len)
{
    unsigned long buf；
    /*将用户地址空间中的src拷贝进buf*/
    if（copy_from_user（&buf，src，len））
    return-EFAULT；
    /*将buf拷贝进用户地址空间中的dst*/
    if（copy_to_user（dst，&buf，len））
    return-EFAULT；
    /*返回拷贝的数据量*/
    return len；
}
```

### 硬中断与软中断

硬中断

1. 硬中断是由硬件产生的，比如，像磁盘，网卡，键盘，时钟等
2. 处理硬中断的处理程序是需要运行在CPU上的，因此，当中断产生的时候，CPU会中断当前正在运行的任务，来处理中断
3. 硬中断可以直接中断CPU。它会引起内核中相关的代码被触发。中断代码本身也可以被其他的硬中断中断

软中断

1. 软中断的处理非常像硬中断。然而，它们仅仅是由当前正在运行的进程所产生的。
2. 通常，软中断是一些对I/O的请求。这些请求会调用内核中可以调度I/O发生的程序
3. 软中断并不会直接中断CPU，**只有当前正在运行的代码（或进程）才会产生软中断**

用于延迟Linux内核工作的三种机制：软中断、tasklet和工作队列。

### 零拷贝技术

[深入剖析Linux IO原理和几种零拷贝机制的实现](https://juejin.im/post/5d84bd1f6fb9a06b2d780df7#heading-3)

- 零拷贝机制可以减少数据在**内核缓冲区和用户进程缓冲区**之间反复的 I/O 拷贝操作。

- 零拷贝机制可以减少用户进程地址空间和内核地址空间之间因为**上下文切换**而带来的开销。

- 实现零拷贝用到的最主要技术是 DMA 数据传输技术和内存区域映射技术。DMA 的全称叫**直接内存存取**（Direct Memory Access），是一种允许IO设备直接访问内存的机制。整个数据传输操作在一个**DMA控制器**的控制下进行的，CPU只需要在开始和结束参与IO操作，**大大降低了CPU的负担**。

- Linux中几种常见的零拷贝机制
  - 使用 mmap 的目的是将内核中读缓冲区的地址与用户空间的缓冲区进行映射，从而实现内核缓冲区与应用程序内存的共享，省去了将数据从内核读缓冲区拷贝到用户缓冲区的过程，然而内核读缓冲区仍需将数据到内核写缓冲区（socket buffer）
  - 通过 sendfile 系统调用，数据可以直接**在内核空间内部进行I/O传输**，从而**省去了数据在用户空间和内核空间之间的来回拷贝**，用户完全不可见，但是sendfile 只适用于将数据从硬盘拷贝到 socket 套接字上，同时需要硬件的支持，这也限定了它的使用范围
  - splice 系统调用，不仅不需要硬件支持，还实现了两个文件描述符之间的数据零拷贝
  - 写时复制

- RocketMQ 选择了 mmap + write 这种零拷贝方式，适用于业务级消息这种小块文件的数据持久化和传输；而 Kafka 采用的是 sendfile 这种零拷贝方式，适用于系统日志消息这种高吞吐量的大块文件的数据持久化和传输。但是值得注意的一点是，Kafka 的索引文件使用的是 mmap + write 方式，数据文件使用的是 sendfile 方式。

### 交换技术是什么

把所有进程一直保存在内存需要巨大的内存，有两种处理内存超载的方法：

1. 交换（swapping）技术，将内存**暂时不能运行**的进程换出到磁盘上，来腾出足够的内存空间给**具备运行条件**的进程，空闲进程主要存储在磁盘上
2. 虚拟内存：每个进程只装入一部分在内存

于是在交换技术下，进程状态有了动态与静态之分：

1. 活动阻塞：进程在内存，但是由于某种原因被阻塞了。
2. 静止阻塞：进程在外存，同时被某种原因阻塞了。
3. 活动就绪：进程在内存，处于就绪状态，只要给CPU和调度就可以直接运行。
4. 静止就绪：进程在外存，处于就绪状态，只要调度到内存，给CPU和调度就可以运行。

> 这个内存交换空间，在 Linux 系统里，也就是我们常看到的 Swap 空间，这块空间是从硬盘划分出来的，用于内存与硬盘的空间交换。

### 地址空间是什么

1. 地址空间是一个进程可用于寻址内存的一套地址集合
2. 地址空间为程序创造了一种抽象的内存
3. 每个进程都有一个自己的地址空间，并且这个地址空间独立于其他进程的地址空间
4. 物理地址空间对应物理内存的字节，虚拟地址空间是从物理地址空间中生成的，一个包含2^n个地址的虚拟地址空间就叫做一个n位地址空间，现代操作系统一般支持32位虚拟地址空间或64位虚拟地址空间，也就是有2^32个或2^64个虚拟地址
5. 但是一般不会全部用来作为地址空间，32位总共4G，3G是用户空间，1G是内核空间。而64位中只有48位用来作为虚拟地址空间

### 虚拟内存

[真棒！ 20 张图揭开内存管理的迷雾，瞬间豁然开朗 by 小林coding](https://mp.weixin.qq.com/s/HJB_ATQFNqG82YBCRr97CA)

虚拟内存的优势

1. 提供**缓存**，加速运行
2. 扩大地址空间，通过内存交换
3. 每个进程都有自己的虚拟地址空间，互不影响，也不需要关心物理地址

#### 分段（一般不单独使用）

- **段选择子**就保存在**段寄存器**里面。段选择子里面最重要的是段号，用作段表的索引。段表里面保存的是这个段的基地址、段的界限和特权等级等。
- 虚拟地址中的段内偏移量应该位于 0 和段界限之间，如果段内偏移量是合法的，就将段基地址加上段内偏移量得到物理内存地址。
- 虚拟地址是通过**段表**与物理地址进行映射的

缺点：

- 第一个就是内存碎片的问题。
- 第二个就是内存交换的效率低的问题。

对于多进程的系统来说，用分段的方式，内存碎片是很容易产生的，产生了内存碎片，那不得不重新 Swap 内存区域，这个过程会产生性能瓶颈。所以内存交换的效率也很低

#### 分页（推荐）

分段的好处就是能产生连续的内存空间，但是会出现内存碎片和内存交换的空间太大的问题。要解决这些问题，那么就要想出能少出现一些内存碎片的办法。另外，当需要进行内存交换的时候，让需要交换写入或者从磁盘装载的数据更少一点，这样就可以解决问题了。这个办法，也就是内存分页（Paging）。

1. 每个进程拥有自己的虚拟地址空间，这个空间被分割成多个**页面**(page)/虚拟页，页面存放于磁盘中，这些页面通过**页表**（存于MMU中）被映射到物理内存中的**页框**/物理页，页面与页框大小一般相等（4KB）
2. **页表(page table)**负责把操作系统虚拟内存映射为物理内存，页表存放于物理内存中的MMU中，页表中有若干页表项(page table entry)，每个页表项对应虚拟内存的每个页面，页面被分为三种：
    1. 已缓存：磁盘中的页面有对应的页框
    2. 未缓存：磁盘中的页面没有对应的页框
    3. 未分配：磁盘中的页面还没有被页表记录
3. 页命中：CPU想要读已缓存的页面，翻译成物理地址访问页框，这样非常快
4. 缺页(page fault)：CPU想要读的页面未缓存或未分配，则产生缺页，从缓存的角度来说是内存缓存不命中，这就需要缺页置换算法（在内存中选择合适的页面换出）

分页相比分段，减少内存碎片，那么释放的内存都是以页为单位释放的，也就不会产生无法给进程使用的小内存。

#### MMU/TLB

MMU（内存管理单元）位于CPU，将进程的虚拟地址转换为物理地址，输入进程的页表与虚拟地址，输出物理地址。虚拟地址分为两部分，**页号**和**页内偏移**。页号作为页表的索引，页表包含物理页每页所在物理内存的基地址，这个基地址与页内偏移的组合就形成了物理内存地址

TLB（快表）存于CPU的L1 Cache，用来缓存已经找到的虚拟地址到物理地址的映射，这样不用去内存去找页表，特别是在多级页表的场景下，**加快了虚拟地址到物理地址的映射速度**。MMU会先查询TLB再查页表

CPU L1 L2 L3 cache，体现**局部性（locality）**。L1/L2 Cache通常都是每个CPU核心一个，L3 Cache通常都是各个核心共享的

#### 多级页表

简单分页的缺点：**每个进程都是有自己的虚拟地址空间的**，也就说都有自己的页表，那页表本身所需的内存空间就很大了

解决办法：**二级页表**即是对页表本身采用分页式管理，对页表本身增加了一层页表管理。页的大小就是一个页表的大小，一个页表只能装在一个页中。

单级页表：在 32 位的环境下，虚拟地址空间共有 4GB，假设一个页的大小是 4KB（2^12），那么就需要大约 100 万 （2^20） 个页，每个「页表项」需要 4 个字节大小来存储，那么整个 4GB 空间的映射就需要有 4MB 的内存来存储页表。这 4MB 大小的页表，看起来也不是很大。但是要知道每个进程都是有自己的虚拟地址空间的，也就说都有自己的页表。那么，100 个进程的话，就需要 400MB 的内存来存储页表，这是非常大的内存了，更别说 64 位的环境了。

多级页表：我们把这个 100 多万个「页表项」的单级页表再分页，将页表（一级页表）分为 1024 个页表（二级页表），每个表（二级页表）中包含 1024 个「页表项」，形成二级分页。

为什么多级页表更省空间？

- 当然，如果 4GB 的虚拟地址全部都映射到了物理内上的，二级分页占用空间确实是更大了，**但是，我们往往不会为一个进程分配那么多内存**。
- 究其原因，一级页表可以覆盖整个 4GB 虚拟地址空间，但如果某个一级页表的页表项没有被用到，也就**不需要创建这个页表项对应的二级页表**了，即可以在需要时才创建二级页表

为什么单级页表不能省？

- 保存在内存中的页表承担的职责是将虚拟地址翻译成物理地址。假如虚拟地址在页表中找不到对应的页表项，计算机系统就不能工作了。
- 所以**页表一定要覆盖全部虚拟地址空间**，不分级的页表就需要有 100 多万个页表项来映射，而二级分页则只需要 1024 个页表项（此时一级页表覆盖到了全部虚拟地址空间，二级页表在需要时创建）

多级页表的缺点？

多了一次寻址时间

#### 段页式内存管理

内存分段和内存分页并不是对立的，它们是可以组合起来在同一个系统中使用的，那么组合起来后，通常称为**段页式内存管理**。

实现的方式：

- 先将程序划分为多个有逻辑意义的段，也就是前面提到的分段机制；
- 接着再把每个段划分为多个页，也就是对分段划分出来的连续空间，再划分固定大小的页；
- 这样，地址结构就由段号、段内页号和页内位移三部分组成。

**Linux 内存主要采用的是页式内存管理**，但同时也不可避免地涉及了段机制（因为intel处理器的历史缘故）。

Linux 系统中的每个段都是从 0 地址开始的整个 4GB 虚拟空间（32 位环境下），也就是所有的段的起始地址都是一样的。这意味着，Linux 系统中的代码，包括操作系统本身的代码和应用程序代码，所面对的地址空间都是线性地址空间（虚拟地址），这种做法相当于屏蔽了处理器中的逻辑地址概念，段只被用于访问控制和内存保护。

#### Linux的虚拟地址空间

在 Linux 操作系统中，虚拟地址空间的内部又被分为内核空间和用户空间两部分，不同位数的系统，地址空间的范围也不同。比如最常见的 32 位和 64 位系统，32 位系统的内核空间占用 1G，位于最高处，剩下的 3G 是用户空间；64 位系统的内核空间和用户空间都是 128T，分别占据整个内存空间的最高和最低处，剩下的中间部分是未定义的（一般很少有进程需要那么大的内存）。

虽然每个进程都各自有独立的虚拟内存，但是每个虚拟内存中的内核地址，其实关联的都是相同的物理内存。这样，进程切换到内核态后，就可以很方便地访问内核空间内存。

用户空间内存，从低到高分别是 7 种不同的内存段：

- 程序文件段，包括二进制可执行代码；
- 已初始化数据段，包括静态常量；
- 未初始化数据段，包括未初始化的静态变量；
- 堆段，包括动态分配的内存，从低地址开始向上增长，使用 C 标准库的 malloc()在这里动态分配
- 文件映射段，包括动态库、共享内存等，从低地址开始向上增长（跟硬件和内核版本有关），使用系统调用mmap()在这里动态分配
- 栈段，包括局部变量和函数调用的上下文等。栈的大小是固定的，一般是 8 MB。当然系统也提供了参数，以便我们自定义大小；

#### 缺页中断

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

#### 页面置换算法

[页面置换算法](https://mp.weixin.qq.com/s?__biz=MzU2NDg0OTgyMA==&mid=2247491583&idx=1&sn=f36d5b9b605c52546045cf250849dfcf&chksm=fc45e20ccb326b1aebdb087d0252320812c8a441b134725d2923d936c3562c0a9a6f9ac8a903&scene=21#wechat_redirect)

如果发生缺页中断，为了能够把所缺的页面装入内存，系统必须从内存中选择一页将其换出，选择哪个页面调出就取决于页面置换算法。如果一个被频繁使用地页面被置换出内存，那么它很快又要被调入内存，这就造成了不必要的开销，所以一个好的页面置换算法至关重要。最常用的是LRU算法。

PS：如果要换出的页面在驻留内存期间已经被修改过，就必须把它写回磁盘以更新该页面在磁盘上的副本，如果该页面没有被修改过，那么就不需要写回磁盘，

1. 最佳/最优置换（Optimal）：被置换的页面以后不再被访问，或者在将来最迟才回被访问的页面，缺页中断率最低，但这种算法**无法实现**，但仍可以作为衡量其他页面置换算法的标准
2. 最近未使用（NRU）：在一个时钟内（约 20 ms）淘汰一个已修改但是没有被访问的页面要比一个大量引用的未修改页面好，LRU的很粗糙的近似，主要优点是易于理解并且能够有效的实现
3. 先进先出置换（FIFO）：置换最先调入内存的页面，即置换在内存中驻留时间最久的页面，一般按照进入内存的先后次序排列成队列，但是该算法会淘汰经常访问的页面，不适合进程实际运行规律，很少使用纯粹的FIFO置换算法
4. 第二次机会(second chance)：解决FIFO可能会把经常使用的页面换出的问题，当需要出队列时，检查最老页面的R位，如果是0，则该页是最老的且没有被使用，直接换出；如果是1，则清除此位，把该页放在链表尾部，修改它的装入时间就好像它刚放进来一样
5. 时钟页面置换算法（clock）：解决第二次机会经常要在链表中移动页面从而降低效率的问题，把所有的页面都保存在一个类似钟面的环形链表中，一个表针指向最老的页面
6. **最近最少使用置换（Least Recently Used, LRU）**：置换最近一段时间以来最长时间未访问过的页面。根据程序局部性原理，刚被访问的页面，可能马上又要被访问；而较长时间内没有被访问的页面，可能最近不会被访问。LRU置换算法效率不粗破，适用于各种类型的程序，但是系统要时时刻刻对各页的访问历史情况加以记录和更新，开销太大，因此LRU置换算法必须要有硬件的支持
7. 最近最不常用页面置换算法(Least Frequently Used)，也就是淘汰**一定时期内被访问次数最少的页**
8. 最不经常使用（NFU）：LRU的相对粗略近似
9. **老化算法**：非常近似LRU的有效算法，很好的选择
10. 工作集算法：开销很大
11. **工作集时钟算法**：好的有效算法。

#### 页回写

读缓存可以通过cache实现，写缓存主要有三种策略：

- 不缓存nowrite，也就是说高速缓存不去缓存任何写操作。当对一个缓存中的数据片进行写时，将直接跳过缓存，写到磁盘，同时也使缓存中的数据失效。几乎不用
- 写透缓存(write-through cache），写操作将自动更新内存缓存，同时也更新磁盘文件。这种策略对一致性有好处，缓存与磁盘时刻保持同步，实现也最简单
- 回写（write-back），程序执行写操作直接写到缓存中，后端存储不会立刻直接更新，而是将页高速缓存中被写入的页面标记成“脏”，并且被加入到脏页链表中。然后由一个进程（**回写进程**）周期行将脏页链表中的页写回到磁盘，从而让磁盘中的数据和内存中最终一致。最后清理“脏”页标识。注意这里“脏页”这个词可能引起混淆，因为实际上脏的并非页高速缓存中的数据（它们是干干净净的），而是磁盘中的数据（它们已过时了）。也许更好的描述应该是“未同步”吧。实现比较复杂，但是Linux就是使用的这种

缓存回收，Linux实现的是一个修改过的LRU，也称为双链策略，Linux维护两个链表：活跃链表和非活跃链表。**处于活跃链表上的页面被认为是“热”的且不会被换出，而在非活跃链表上的页面则是可以被换出的**。在活跃链表中的页面必须在其被访问时就处于非活跃链表中。两个链表都被伪LRU规则维护：页面从尾部加入，从头部移除，如同队列。两个链表需要维持平衡——如果活跃链表变得过多而超过了非活跃链表，那么活跃链表的头页面将被重新移回到非活跃链表中，以便能再被回收。双链表策略解决了传统LRU算法中对仅一次访问的窘境。而且也更加简单的实现了伪LRU语义。这种双链表方式也称作LRU/2。更普遍的是n个链表，故称LRU/n。

#### 内存描述符

内核使用内存描述符结构体表示**进程的地址空间**，该结构包含了和进程地址空间有关的全部信息。内存描述符由mm_struct结构体表示，定义在文件`<linux/sched.h>`中。

所有的mm_struct结构体都通过自身的mmlist域连接在一个双向链表中

#### 虚拟内存区域

内存区域由vm_area_struct结构体描述，定义在文件`<linux/mm_types.h>`中。内存区域在Linux内核中也经常称作虚拟内存区域（virtual memoryAreas，VMAs）。

vm_area_struct 结构体描述了指定地址空间内连续区间上的一个独立内存范围。内核将每个内存区域作为一个单独的内存对象管理，每个内存区域都拥有一致的属性，比如访问权限等，另外，相应的操作也都一致。按照这样的方式，每一个VMA就可以代表不同类型的内存区域（比如内存映射文件或者进程用户空间栈），这种管理方式类似于使用VFS层的面向对象方法（请看

#### mmap和unmmap

内核使用do_mmap()函数创建一个新的线性地址区间，会将一个地址区间加入到进程的地址空间中——无论是扩展已存在的内存区域还是创建一个新的区域。

在用户空间可以通过mmap()系统调用获取内核函数do_mmap()的功能。

do_mummap()函数从特定的进程地址空间中删除指定地址区间

在用户空间可以通过munmap()系统调用获取内核函数do_mummap()的功能

### 内存分配算法：伙伴(buddy)/slab

进程申请内存大小是任意的，如果malloc用法不对，会产生**内存碎片**，它们小而且不连续，不满足malloc申请连续内存的要求

**内存碎片**存在的方式有两种：a. 内部碎片  b. 外部碎片

- **内部**碎片的产生：因为所有的内存分配需要满足**字节对齐**，所以通常会多分配一点不需要的多余内存空间，造成内部碎片。如：申请43Byte，因为没有合适大小的内存，会分配44Byte或48Byte，就会存在1Byte或3Byte的多余空间。
- **外部**碎片的产生：频繁的分配与回收物理页面会导致大量的、连续且小的页面块**夹杂**在已分配的页面中间，从而产生外部碎片。比如有一块共有100个单位的连续空闲内存空间，范围为0~99，如果从中申请了一块10 个单位的内存块，那么分配出来的就是0~9。这时再继续申请一块 5个单位的内存块，这样分配出来的就是 10~14。如果将第一块释放，此时整个内存块只占用了 10~14区间共 5个单位的内存块。然后再申请20个单位的内存块，此时只能从 15开始，分配15~24区间的内存块，如果以后申请的内存块都大于10个单位，那么 0~9 区间的内存块将不会被使用，变成外部碎片。

**伙伴算法**就是将内存分成若干块，然后尽可能以最适合的方式满足程序内存需求的一种内存管理算法，内存释放后，检查与该内存相邻的内存是否是同样大小并且同样处于空闲的状态，如果是，则将这两块内存合并，然后程序递归进行同样的检查。

- 伙伴算法的优点是能够**完全避免外部碎片的产生**。
- 申请时，伙伴算法会给程序分配一个较大的内存空间，即保证所有大块内存都能得到满足。
- 伙伴算法的缺点是**会产生内部碎片**，当分配比需求还大的内存空间，就会产生内部碎片。

**slab allocation**的基本原理：将分配的内存分割成各种尺寸的块，并把相同尺寸的块分成组。当要释放已分配到的内存时，**只会回收、不会释放**，返回到对应的组重复利用。下次分配对象时，会使用最近释放的对象的内存块，因此其驻留在cpu高速缓存中的概率会大大提高。

- 对从Buddy拿到的内存进行二次管理，以**更小的单位**进行分配和回收(注意，是回收而不是释放)，防止了空间的浪费。
- 让频繁使用的对象尽量分配在**同一块内存区间**并**保留基本数据结构**，提高程序效率。

最佳实践：如果你要创建和撤销很多大的数据结构，那么考虑建立slab高速缓存。slab层会给每个处理器维持一个对象高速缓存（空闲链表），这种高速缓存会极大地提高对象分配和回收的性能。slab层不是频繁地分配和释放内存，而是为你把事先分配好的对象存放到高速缓存中。当你需要一块新的内存来存放数据结构时，slab层一般无须另外去分配内存，而只需要从高速缓存中得到一个对象就可以了。

伙伴算法与slab算法的关系：

- slab与Buddy都是内存分配器。
- slab的内存来自Buddy
- slab与Buddy在算法上级别对等。Buddy把内存条 当作一个池子来管理，slab是把从Buddy拿到的内存当作一个池子来管理的。

kmalloc()函数与用户空间的malloc()一族函数非常类似，只不过它多了一个gfp_t类型的flags参数。flags参数指定了内存分配器的行为。与kmalloc对应的就是kfree。

vmalloc()函数类似kmalloc，只是vmalloc分配的内存虚拟地址是连续的，而物理地址则无须连续。尽管在某些情况下才需要物理上连续的内存块，但是出于性能考虑，很多内核代码都用kmalloc()来获得内存，而不是vmalloc()。而且vmalloc需要一个个映射不连续的物理页，导致更大的TLB抖动

每个进程的内核栈大小既依赖体系结构，也与编译时的选项有关。历史上，每个进程都有两页的内核栈。因为32位和64位体系结构的页面大小分别是4KB和8KB，所以通常它们的内核栈的大小分别是8KB和16KB。

### 死锁/银行家算法/活锁

死锁(deadlock)/是指两个或两个以上进程在执行过程中，因争夺资源而造成的下相互等待的现象

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

最简单的死锁例子是**自死锁**：如果一个执行线程试图去获得一个自己已经持有的锁，它将不得不等待锁被释放，但因为它正在忙着等待这个锁，所以自己永远也不会有机会释放锁，最终结果就是死锁

同样道理，考虑有n个线程和n个锁，如果每个线程都持有一把其他进程需要得到的锁，那么所有的线程都将阻塞地等待它们希望得到的锁重新可用。最常见的例子是有两个线程和两把锁，它们通常被叫做**ABBA死锁**。

银行家算法：迪杰斯特拉提出的解决死锁的算法，当一个进程申请使用资源的时候，银行家算法通过先试探分配给该进程资源，然后通过安全性算法判断分配后的系统是否处于安全状态，若不安全则试探分配作废，让该进程继续等待。

关于最少资源数量的死锁问题

问：某系统有n台互斥使用的同类设备，3个并发进程需要3,4,5台设备，可确保系统不发生死锁的设备数n最小为：10台

答：假设进程1得到2台，进程2得到3台，进程3得到4台，总共安排9台，这样会产生死锁。只要再加1台变成10台，那么分配给任意进程，都可以完成任务，从而释放资源，从而避免死锁

活锁(livelock)是什么，死锁与活锁的区别

活锁是指线程1可以使用资源，但它很礼貌，让其他线程先使用资源，线程2也可以使用资源，但它很绅士，也让其他线程先使用资源。这样你让我，我让你，最后两个线程都无法使用资源。

关于“死锁与活锁”的比喻：

死锁：迎面开来的汽车A和汽车B过马路，汽车A得到了半条路的资源（满足死锁发生条件1：资源访问是排他性的，我占了路你就不能上来，除非你爬我头上去），汽车B占了汽车A的另外半条路的资源，A想过去必须请求另一半被B占用的道路（死锁发生条件2：必须整条车身的空间才能开过去，我已经占了一半，尼玛另一半的路被B占用了），B若想过去也必须等待A让路，A是辆兰博基尼，B是开奇瑞QQ的屌丝，A素质比较低开窗对B狂骂：快给老子让开，B很生气，你妈逼的，老子就不让（死锁发生条件3：在未使用完资源前，不能被其他线程剥夺），于是两者相互僵持一个都走不了（死锁发生条件4：环路等待条件），而且导致整条道上的后续车辆也走不了。

活锁：马路中间有条小桥，只能容纳一辆车经过，桥两头开来两辆车A和B，A比较礼貌，示意B先过，B也比较礼貌，示意A先过，结果两人一直谦让谁也过不去。

### Linux内核数据结构

#### 双向循环链表

Linux的双向循环链表代码在头文件`<linux/list.h>`中声明，它与众不同，它不是将数据结构塞入链表，而是将链表节点塞入数据结构！

```c++
struct list_head{
    struct list_head *next;
    struct list_head *prev;
};
```

next 指针指向下一个链表节点，prev指针指向前一个，其实关键在于理解 list_head结构是如何使用的，它是嵌入结构体中的

```c++
struct fox{
    unsigned long tail_length; /*尾巴长度，以厘米为单位*/.
    unsigned long weight; /*重量，以千克为单位*/
    bool is fantastic; /*这只狐狸奇妙吗？*/
    struct list_head 1ist; /*所有fox结构体形成链表*/
};
```

使用宏container_of()我们可以很方便地从链表指针找到父结构中包含的任何变量。这是因为在C语言中，一个给定结构中的变量偏移在编译时地址就被ABI固定下来了。

```c++
#define container_of(ptr，type，member) ({ \
    const typeof(( (type *) 0)->member) *_mptr = (ptr); \
    (type*)( (char*) _mptr - offsetof(type, member) );})
```

使用container_of()宏，我们定义一个简单的函数便可返回包含list_head的父类型结构体：

```c++
#define list_entry(ptr，type，member)\
    container_of(ptr，type，member)
```

#### Linux内核的队列

Linux内核通用队列实现称为kfifo。它实现在文件`kernel/kfifo.c`中，声明在文件`<linux/kfifo.h>`中。

Linux的kfifo和多数其他队列实现类似，提供了两个主要操作：enqueue（入队列）和dequeue（出队列）。kfifo对象维护了两个偏移量：入口偏移和出口偏移。入口偏移是指下一次入队列时的位置，出口偏移是指下一次出队列时的位置。出口偏移总是小于等于入口偏移，否则无意义，因为那样说明要出队列的元素根本还没有入队列。

enqueue操作拷贝数据到队列中的入口偏移位置。当上述动作完成后，入口偏移随之加上推入的元素数目。dequeue操作从队列中出口偏移处拷贝数据，当上述动作完成后，出口偏移随之减去摘取的元素数目。当出口偏移等于入口偏移时，说明队列空了：在新数据被推入前，不可再摘取任何数据了。当入口偏移等于队列长度时，说明在队列重置前，不可再有新数据推入队列。

#### 映射

一个映射，也常称为关联数组，其实是一个由唯一键组成的集合，而每个键必然关联一个特定的值。这种键到值的关联关系称为映射。

虽然散列表是一种映射，但并非所有的映射都需要通过散列表实现。除了使用散列表外，映射也可以通过自平衡二又搜索树存储数据。虽然散列表能提供更好的平均的渐近复杂度，但是二叉搜索树在最坏情况下能有更好的表现（即对数复杂性相比线性复杂性）。二叉搜索树同时满足顺序保证，这将给用户的按序遍历带来很好的性能。二又搜索树的最后一个优势是它不需要散列函数，需要的键类型只要可以定义<=操作算子便可以。

Linux内核提供了简单、有效的映射数据结构。但是它并非一个通用的映射。因为它的目标是：**映射一个唯一的标识数（UID）到一个指针**。除了提供三个标准的映射操作外，Linux还在add操作基础上实现了allocate操作。这个allocate操作不但向map中加入了键值对，而且还可产生UID。

**idr数据结构用于映射用户空间的UID**，比如将inodify watch的描述符或者POSIX的定时器ID映射到内核中相关联的数据结构上，如inotify_watch或者kitimer结构体。其命名仍然沿袭了内核中有些含混不清的命名体系，这个映射被命名为idr。

#### 二叉树

红黑树是一种自平衡二叉搜索树。Linux主要的平衡二叉树数据结构就是红黑树。Linux 实现的红黑树称为rbtree。其定义在文件`lib/rbtree.c`中，声明在文件`<linux/rbtree.h>`

rbtree的实现并没有提供搜索和插入例程，这些例程希望由rbtree的用户自己定义。这是因为C语言不大容易进行泛型编程，同时Linux内核开发者们相信最有效的搜索和插入方法需要每个用户自己去实现。你可以使用rbtree提供的辅助函数，但你自己要实现比较操作算子。

## 网络编程/并发编程

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

### 可重入/线程安全

CSAPP的解释

线程安全：一个函数被称为线程安全的，当且仅当被多个并发线程反复的调用时，它会一直产生正确的结果。
可重入性：有一类重要的线程安全函数，叫做可重入函数，其特点在于它们具有一种属性：当它们被多个线程调用时，**不会引用任何共享的数据**。

尽管线程安全和可重入有时会（不正确的）被用做同义词，但是它们之间还是有清晰的技术差别的。**可重入函数是线程安全函数的一个真子集**。

Linux库函数只有一小部分是不可重入的，也提供了对应的可重入版本（函数名加上_r后缀），在多线程环境下一定要用可重入版本

BUT，如果一个函数是线程安全的，并不能说明对**信号处理程序**来说该函数也是可重入的，如果函数对异步信号处理程序的重入是安全的，那么就可以说函数是"异步-信号安全"的。

### c++11线程

[c++11新特性之线程相关所有知识点 by 程序喵大人](https://mp.weixin.qq.com/s/k_MiJav5PG4amFxSIIUgTw)

#### std::thread

- thread 的构造函数的第一个参数是函数(对象)，后面跟的是这个函数所需的参数。
- thread 要求在析构之前要么 join(阻塞直到线程退出)，要么 detach(放弃对线程的管理)，否则程序会异常退出。
- 只有joinable(已经join的、已经detach的或者空的线程对象都不满足joinable)的thread才可以对其调用 join 成员函数，否则会引发异常
- c++11还提供了获取线程id，或者系统cpu个数，获取thread native_handle，使得线程休眠等功能

下面的代码执行如下流程：

1. 传递参数，起两个线程
2. 两个线程分别休眠100毫秒
3. 使用互斥量(mutex)锁定cout，然后输出一行信息
4. 主线程等待这两个线程退出后程序结束
5. 用lambda匿名函数

```c++
#include <chrono>
#include <iostream>
#include <mutex>
#include <thread>
using namespace std;
mutex mtx;
void func(const char *name)
{
    this_thread::sleep_for(100ms);
    lock_guard<mutex> guard(mtx);
    cout << "I am thread " << name << '\n';
}
int main()
{
    thread t1(func, "A");
    thread t2(func, "B");
    t1.join();
    t2.join();
    auto func1 = [](int k) {
        for (int i = 0; i < k; ++i) {
            cout << i << " ";
        }
        cout << endl;
    };
    std::thread tt(func1, 20);
    if (tt.joinable()) { // 检查线程可否被join
        tt.join();
    }
    cout << "当前线程ID " << tt.get_id() << endl;
    cout << "当前cpu个数 " << std::thread::hardware_concurrency() << endl;
    auto handle = tt.native_handle();// handle可用于pthread相关操作
    std::this_thread::sleep_for(std::chrono::seconds(1));
}
```

thread不能在析构时自动join，感觉不是很自然，但是在C++20的jthread到来之前，只能这样用着，附近的笔记参考现代C++实战30讲，用到了自定义的scoped_thread，可以简单认为更智能的std::thread

#### std::mutex

std::mutex是一种线程同步的手段，用于保存多线程同时操作的共享数据。mutex分为四种：

- std::mutex：独占的互斥量，不能递归使用，不带超时功能
- std::recursive_mutex：递归互斥量，可重入，不带超时功能
- std::timed_mutex：带超时的互斥量，不能递归
- std::recursive_timed_mutex：带超时的互斥量，可以递归使用

std::mutex不允许拷贝构造，初始是unlock状态

三个函数

1. lock()：三种情况
    1. 如果该mutex没有被锁，则上锁
    2. 如果该mutex被其他线程锁住，则**当前线程阻塞**，直至其他线程解锁
    3. 如果该mutex被当前线程锁住（递归上锁），则产生死锁
2. unlock()：只允许在已获得锁时调用
3. try_lock()：相当于**非阻塞**的加锁，三种情况
    1. 如果该mutex没有被锁，则上锁
    2. 如果该mutex被其他线程锁住，则**当前线程返回false**，直至其他线程解锁
    3. 如果该mutex被当前线程锁住（递归上锁），则产生死锁

```c++
#include <iostream>
#include <mutex>
#include <thread>
#include <chrono>

using namespace std;
std::timed_mutex timed_mutex_;

int main() {
   auto func1 = [](int k) {
       timed_mutex_.try_lock_for(std::chrono::milliseconds(200));
       for (int i = 0; i < k; ++i) {
           cout << i << " ";
      }
       cout << endl;
       timed_mutex_.unlock();
  };
   std::thread threads[5];
   for (int i = 0; i < 5; ++i) {
       threads[i] = std::thread(func1, 200);
  }
   for (auto& th : threads) {
       th.join();
  }
   return 0;
}
```

#### unique_lock与lock_guard区别

两者都包含于头文件`<mutex>`中，C++11

这两个都是类模板，用RAII的思想来处理锁，不用手动mutex.lock()、mutex.unlock()

- lock_guard只有构造函数，直接构造即可，在整个区域内有效，在块内`{}`作为局部变量，自动析构
- unique_lock更加灵活，还提供lock()、try_lock()、unlock()等函数，所以可以在必要时加锁和解锁，不必像lock_guard一样非得在构造和析构时加锁和解锁
- unique_lock在效率上差一点，内存占用多一点。
- 条件变量cond_variable的接收参数是unique_lock

```c++
std::mutex mtx;
void some_func() {
    std::lock_guard<std::mutex> guard(mtx);
    // 做需要同步的工作
    // 函数结束时，自动释放局部对象lock_guard
}
```

#### std::atomic

头文件`<atomic>`定义了原子量和内存序(C++11起)，用atomic_int/atomic_bool/...代替int/bool/...，即可保证这些操作都是原子性的，比mutex对资源加锁解锁要快

编译器提供了一个原子对象的成员函数 is_lock_free，可以检查这个原子对象上的操作是否是无锁的

atomic规定了内存序，这样就有了内存屏障，防止编译器优化

原子操作有三类:

- 读：在读取的过程中，读取位置的内容不会发生任何变动。
- 写：在写入的过程中，其他执行线程不会看到部分写入的结果。
- 读‐修改‐写：读取内存、修改数值、然后写回内存，整个操作的过程中间不会有其他写入操作插入，其他执行线程不会看到部分写入的结果。

可以用于单例模式中双检锁失效的问题

```c++

struct OriginCounter { // 普通的计数器
   int count;
   std::mutex mutex_;
   void add() {
       std::lock_guard<std::mutex> lock(mutex_);
       ++count;
  }

   void sub() {
       std::lock_guard<std::mutex> lock(mutex_);
       --count;
  }

   int get() {
       std::lock_guard<std::mutex> lock(mutex_);
       return count;
  }
};

struct NewCounter { // 使用原子变量的计数器
   std::atomic<int> count;
   void add() {
       ++count;
       // count.store(++count);这种方式也可以
  }

   void sub() {
       --count;
       // count.store(--count);
  }

   int get() {
       return count.load();
  }
};
```

#### std::callonce

c++11提供了std::call_once来保证某一函数在多线程环境中只调用一次，它需要配合std::once_flag使用，直接看使用代码吧：

```c++
std::once_flag onceflag;
void CallOnce() {
   std::call_once(onceflag, []() {
       cout << "call once" << endl;
  });
}

int main() {
   std::thread threads[5];
   for (int i = 0; i < 5; ++i) {
       threads[i] = std::thread(CallOnce);
  }
   for (auto& th : threads) {
       th.join();
  }
   return 0;
}
```

#### std::condition_variable与虚假唤醒

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

在正常情况下，wait类型函数返回时要不是因为被唤醒，要不是因为超时才返回，但是在实际中发现，因处理器的原因，多个线程可能都会被唤醒（即使用的是pthread_cond_signal()或notify_one()），那我们要让虚假唤醒的线程睡回去，所以一般都是使用带有谓词参数的wait函数，

```c++
cond.wait(lock, [](){return status});
```

因为这种(xxx, Predicate pred)类型的函数等价于：

```c++
while (!pred()) //while循环，解决了虚假唤醒的问题
{
    wait(lock);
}
```

“惊群效应”。有人觉得此处既然是被唤醒的，肯定是满足条件了，其实不然。如果是多个线程都在等待这个条件，而同时只能有一个线程进行处理，此时就必须要再次条件判断，以使只有一个线程进入临界区处理。

pthread_cond_signal()也可能唤醒多个线程，而如果你同时只允许一个线程访问的话，就必须要使用while来进行条件判断，以保证临界区内只有一个线程在处理。

为什么条件变量需要和锁配合使用？

因为内部是通过判断及修改某个全局变量来决定线程的阻塞与唤醒，多线程操作同一个变量肯定需要加锁来使得线程安全。同时，一个简单的wait函数调用内部会很复杂的，有可能线程A调用了wait函数但是还没有进入到wait阻塞等待前，另一个线程B在此时却调用了notify函数，此时nofity的信号就丢失啦，如果加了锁，线程B必须等待线程A释放了锁并进入了等待状态后才可以调用notify，继而防止信号丢失。

#### std::future/std::promise/std::packaged_task/std::async/std::shared_future

- 头文件`<future>`就包括了这五者，C++11

##### std::future 与 std::promise

- std::future作为异步结果的传输通道，通过get()可以很方便的获取线程函数的返回值，std::promise用来包装一个值，将数据和future绑定起来，而std::packaged_task则用来包装一个调用对象，将函数和future绑定起来，方便异步调用。而std::future是不可以复制的，如果需要复制放到容器中可以使用std::shared_future。

```c++
#include <functional>
#include <future>
#include <iostream>
#include <thread>
using namespace std;
void func(std::future<int>& fut) {
    int x = fut.get(); // 阻塞直到源 promise 调用了 set_value
    cout << "value: " << x << endl;
}
int main() {
    std::promise<int> prom;
    std::future<int> fut = prom.get_future();
    std::thread t(func, std::ref(fut));
    prom.set_value(144);
    t.join();
    return 0;
}
```

##### std::packaged_task

- std::packaged_task则用来包装一个调用对象，将函数和future绑定起来，方便异步调用。
- 理解：
  - std::future用于访问异步操作的结果，而std::promise和std::packaged_task在future高一层，它们内部都有一个future，promise包装的是一个值，packaged_task包装的是一个函数
  - packaged_task ≈ promise + function

```c++
#include <future>
#include <iostream>
#include <thread>
int main() {
 std::packaged_task<int(int, int)> task([](int a, int b) { return a + b; });
 auto f = task.get_future();
 std::thread t(std::move(task), 1, 2);
 std::cout << f.get() << std::endl;
 if (t.joinable()) t.join();
}
```

- 注意一个future上只能调用一个get函数，**第二次会导致程序崩溃**，所以要想在多线程调用future，得用future.share()方法生成shared_future，当然底层还是只用了一次get函数。

##### std::async

- future与async配合使用,可以从**异步任务**中获取结果，std::async用于创建异步任务，实际上就是创建一个线程执行相应任务，返回的结果会保存在 future 中，不需要像 packaged_task 和 promise 那么麻烦，线程操作应优先使用 async
- async ≈ thread + packaged_task

```c++
// 没有future与async的做法，非常冗余，定义了一堆变量
void work(condition_variable& cv, int& result)
{
    // 假装我们计算了很久
    this_thread::sleep_for(2s); result = 42;
    cv.notify_one();
}
int main(){
    condition_variable cv;
    mutex cv_mut;
    int result;
    scoped_thread th{work, ref(cv), ref(result)};
    cout << "I am waiting now\n"; unique_lock lock{cv_mut};
    cv.wait(lock);
    cout << "Answer: " << result;
}

// 引入future与async，非常简单
int work() {
    // 假装我们计算了很久
    this_thread::sleep_for(2s); return 42;
}
int main() {
    auto fut = async(launch::async, work); // 调用 async 可以获得一个未来量 
    cout << "I am waiting now\n";
    cout << "Answer: " << fut.get(); // 在未来量上调用 get 成员函数可以获得其结果
}


// 第一个参数是创建策略：
// std::launch::async表示任务执行在另一线程
// std::launch::deferred表示延迟执行任务，调用get或者wait时才会执行，不会创建线程，惰性执行在当前线程。
async(std::launch::async | std::launch::deferred, func, args...);
```
 
##### future与promise可以实现多线程同步

线程1初始化一个promise对象和一个future对象，promise传递给线程2，相当于线程2对线程1的一个**承诺**；future相当于一个**接受一个承诺**，用来获取未来线程2传递的值。线程2获取到promise后，需要对这个promise传递有关的数据，之后线程1的future就可以获取数据了。一组promise和future只能使用一次，既不能重复设，也不能重复取。

比如下面的例子，promise和future在这里成对出现，可以看作是一个**一次性管道**：有人需要**兑现承诺**，往promise里放东西(set_value)；有人就像收期货一样，到时间去future里拿(get)就行了。我们把prom移动给新线程，这样老线程就完全不需要管理它的生命周期了。

```c++
void work(promise<int> prom) {
    // 假装我们计算了很久
    this_thread::sleep_for(2s); prom.set_value(42);
}
int main() {
    promise<int> prom;
    auto fut = prom.get_future(); scoped_thread th{work, move(prom)};
    cout << "I am waiting now\n"; cout << "Answer: " << fut.get();
```

##### std::shared_future

- 普通的future有个特点，它不能拷贝，只能移动，这就意味着只能有一个线程一个实例可以通过get()拿到对应的结果。
- 如果想要多个线程多个实例拿到结果，就可以使用shared_future，调用普通 future 的 shared()方法

```c++
#include <future>
#include <iostream>
#include <thread>
int main() {
 std::promise<int> prom;
 auto fu = prom.get_future();
 auto shared_fu = fu.share();
 auto f1 = std::async(std::launch::async, [shared_fu]() { std::cout << shared_fu.get() << std::endl; });
 auto f2 = std::async(std::launch::async, [shared_fu]() { std::cout << shared_fu.get() << std::endl; });
 prom.set_value(102);
 f1.get();
 f2.get();
}
```

### 手撕两个线程交替打印

用到了unique_lock来管理mutex，还有条件变量condition_variable来通知另一个线程，

```c++
#include <iostream>
#include <thread>
#include <mutex>
#include <condition_variable>
using namespace std;  
mutex mtx;
condition_variable cond_var;
bool flag = true;
int maxIter = 10;
void printA(){
    while(1){
        unique_lock<std::mutex> ulock(mtx);
        cond_var.wait(ulock, []{return flag;});
        cout << "threadA: " << flag << endl;
        flag = false;
        cond_var.notify_one();
        if (--maxIter <= 0) break;
    }
}
void printB(){
    while(1){
        unique_lock<std::mutex> ulock(mtx);
        cond_var.wait(ulock, []{return !flag;});
        cout << "threadB: " << flag << endl;
        flag = true;
        cond_var.notify_one();
        if (--maxIter <= 0) break;
    }
}
int main()  
{  
    thread t1(printA);
    thread t2(printB);
    t1.join();
    t2.join();
}
```

### 手撕生产者消费者模型

多生产者多消费者，利用互斥锁、条件变量、阻塞队列实现

```c++
#include <iostream>
#include <queue>
#include <thread>
#include <mutex>
#include <condition_variable>
using namespace std;
mutex mtx;
condition_variable produce, consume; // 条件变量是一种同步机制，要和mutex以及lock一起使用
queue<int> q; // shared value by producers and consumers, which is the critical section
int maxSize = 20;
int maxConsume = 100;
int maxProduce = 100;
void consumer() {
    while (true) {
        unique_lock<mutex> lck(mtx); // RAII
        consume.wait(lck, [] {return q.size() != 0; }); // wait(block) consumer until q.size() != 0 is true
        cout << "consumer " << this_thread::get_id() << ": ";
        q.pop();
        cout << q.size() << '\n';
        produce.notify_all(); // notify(wake up) producer when q.size() != maxSize is true
        if (--maxConsume <= 0) break;
    }
}

void producer(int id) {
    while (true) {
        unique_lock<mutex> lck(mtx);
        produce.wait(lck, [] {return q.size() != maxSize; }); // wait(block) producer until q.size() != maxSize is true
        cout << "-> producer " << this_thread::get_id() << ": ";
        q.push(id);
        cout << q.size() << '\n';
        consume.notify_all(); // notify(wake up) consumer when q.size() != 0 is true
        if (--maxProduce <= 0) break;
    }
}
int main()
{
    thread consumers[2], producers[2];
    for (int i = 0; i < 2; ++i) {
        consumers[i] = thread(consumer);
        producers[i] = thread(producer, i + 1);
    }
    // 结束时必须要调用join，不然会异常退出
    for (int i = 0; i < 2; ++i) {
        producers[i].join();
        consumers[i].join();
    }
}
```

### 手撕线程池

线程池中线程，在线程池中等待并执行分配的任务，用条件变量实现等待与通知机制

[基于C++11实现线程池的工作原理](https://www.cnblogs.com/ailumiyana/p/10016965.html)

```c++
class ThreadPool{
public:
  static const int kInitThreadsSize = 3;
  enum taskPriorityE { level0, level1, level2, }; // 优先级
  typedef std::function<void()> Task;
  typedef std::pair<taskPriorityE, Task> TaskPair;

private:
  typedef std::vector<std::thread*> Threads;
  typedef std::priority_queue<TaskPair, std::vector<TaskPair>, TaskPriorityCmp> Tasks;

  Threads m_threads;
  Tasks m_tasks;

  std::mutex m_mutex;
  Condition m_cond;
  bool m_isStarted;

public:
  ThreadPool() : m_mutex(), m_cond(m_mutex), m_isStarted(false) {}
  ~ThreadPool() { if(m_isStarted) stop();}

  void start() {
    m_isStarted = true;
    m_threads.reserve(kInitThreadsSize);
    for (int i = 0; i < kInitThreadsSize; ++i) {
      m_threads.push_back(new std::thread(std::bind(&threadLoop, this)));
    }
  }
  void stop() {
    {
      std::unique_lock<std::mutex> lock(m_mutex);
      m_isStarted = false;
      m_cond.notifyAll();
    }
    for (auto it = m_threads.begin(); it != m_threads.end(); ++it) {
      (*it)->join();
      delete *it;
    }
    m_threads.clear();
  }
  void addTask(const Task&) {
    std::unique_lock<std::mutex> lock(m_mutex);
    TaskPair taskPair(level2, task);
    m_tasks.push(taskPair);
    m_cond.notify();
  }

private:
  ThreadPool(const ThreadPool&);//禁止复制拷贝.
  const ThreadPool& operator=(const ThreadPool&);

  struct TaskPriorityCmp {
    bool operator() (const ThreadPool::TaskPair p1, const ThreadPool::TaskPair p2) {
        return p1.first > p2.first; // first的小值优先
    }
  };

  void threadLoop() {
    while (m_isStarted) {
      Task task = take();
      if (task) {
        task();
      }
    }
  }
  Task take() {
    std::unique_lock<std::mutex> lock(m_mutex);
    while(m_tasks.empty() && m_isStarted) { // 避免虚假唤醒
      m_cond.wait(lock);
    }
    Task task;
    auto size = m_tasks.size();
    if (!m_tasks.empty() && m_isStarted) {
      task = m_tasks.top().second;
      m_tasks.pop();
    }
    return task;
  }
};
```

### Linux内核原子操作

32位整数：针对整数的原子操作只能对atomic_t类型的数据进行处理。在这里之所以引入了一个特殊数据类型，而没有直接使用C语言的int类型，主要是出于两个原因：首先，让原子函数只接收atomic_t类型的操作数，可以确保原子操作只与这种特殊类型数据一起使用。同时，这也保证了该类型的数据不会被传递给任何非原子函数。Atomic_t类型定义在文件`<linux/types.h>`中：

```c++
typedef struct{
    volatile int counter;
} atomic_t;
atomic_t v; /*定义v*/
atomic_t u = ATOMIC_INIT(0); /*定义u并把它初始化为0*/
atomic_set(&v，4); /*v=4(原子地)*/
atomic_add(2，&v); /*v=v+2=6(原子地)*/
atomic_inc(&v); /*v=v+1=7(原子地)*/
printk("&d\n"，atomic_read(&v)); /*转为int，会打印“7”*/
```

64位整数：随着64位体系结构越来越普及，内核开发者确实在考虑原子变量除32位atomic_t类型外，也应引入64位的atomic64_t。因为移植性原因，atomic_t变量大小无法在体系结构之间改变。所以，atomic_t类型即便在64位体系结构下也是32位的，若要使用64位的原子变量，则要使用atomic64_t类型——其功能和其32位的兄弟无异，使用方法完全相同，不同的只有整型变量大小

原子位操作：位操作函数是对**普通的内存地址**进行操作的。它的参数是一个指针和一个位号，第0位是给定地址的最低有效位。在32位机上，第31位是给定地址的最高有效位而第32位是下一个字的最低有效位。虽然使用原子位操作在多数情况下是对一个字长的内存进行访问，因而位号应该位于0~31（在64位机器中是0~63），但是，对位号的范围并没有限制。

```c++
unsigned long word = 0;
set_bit(0，&word); /*第0位被设置(原子地)*/
set_bit(1，&word); /*第1位被设置(原子地)*/
printk("ul\n"，word); /*打印3*/
clear_bit(1，&word);/*清空第1位*/
change_bit(0，&word);/*翻转第0位的值，这里它被清空*/
/*原子地设置第0位并且返回设置前的值(0)*/
if(test_and_set_bit(0，&word){
    /*永远不为真*/
}
/*下面的语句是合法的;你可以把原子位指令与一般的C语句混在一起*/
word = 7;
```

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

解决ABA问题，可以用版本号（或者叫引用计数）

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

Reactor模式

- 网络框架大多数都是基于Reactor模式进行设计和开发，Reactor模式基于**事件驱动**，特别适合处理海量的I/O事件，Reactor模式也叫Dispatcher模式
- Reactor模型要求**主线程只负责监听**文件描述符上是否有事件发生，有的话就立即将该事件通知工作线程，除此之外，主线程不做任何其他实质性的工作，读写数据、接受新的连接以及处理客户请求均在工作线程中完成。
- Reactor模式中有2个关键组成：
  - Reactor：Reactor在一个单独的线程中运行，负责监听和分发事件，分发给适当的处理程序来对IO事件做出反应。 它就像公司的电话接线员，它接听来自客户的电话并将线路转移到适当的联系人；
  - Handlers：处理程序执行I/O事件要完成的实际事件，类似于客户想要与之交谈的公司中的实际官员。Reactor通过调度适当的处理程序来响应I/O事件，处理程序执行非阻塞操作。
- Reactor等待某个事件或者可应用或者操作的状态发生（比如文件描述符可读写，或者是Socket可读写）。然后把这个事件传给事先注册的Handler（事件处理函数或者回调函数），由后者来做实际的读写操作。其中的读写操作都需要应用程序同步操作，所以Reactor是**非阻塞同步**网络模型。
- 单Reactor单线程
  - 接待员和侍应生是同一个人，全程为顾客服务；
  - Reactor监听请求，通过Dispatcher分发事件，通过Handler处理请求
  - 优点：简单，没有多线程/多进程通信与竞争问题
  - 缺点：性能不够，无法发挥多核CPU性能，不是很可靠
  - 场景：客户端数量有限，需要快速响应，比如Redis
- 单Reactor多线程
  - 1个接待员，多个侍应生，接待员只负责接待；
  - Reactor监听请求，通过Dispatcher分发事件，Handler不直接处理业务，而是分发给**Worker线程池**处理，处理完后返回给Handler，Handler再响应给客户端
  - 优点：可以充分利用多核CPU的处理能力。
  - 缺点：多线程数据共享和访问比较复杂；Reactor承担所有事件的监听和响应，可能会成为性能瓶颈
- 主从Reactor多线程
  - 多个接待员，多个侍应生。
  - MainReactor监听，然后分给SubReactor处理，**SubReactor监听**，如果有新事件发生，SubReactor会调用对应的Handler进行处理，Handler同样是不处理业务，而是分发给Worker线程池处理，处理后返回给Handler，Handler再响应给客户端
  - 优点：父子线程交互简单，MainReactor只需要把新连接传给SubReactor，而SubReactor无需返回数据
  - 场景：Nginx、Memcached、Netty

Proactor模式

- 将**所有I/O操作都交给主线程和内核来处理**，工作线程仅仅负责业务逻辑。
- Proactor模式是**异步**网络模型
- 创建Proactor与Handler对象，都注册到内核，内核发现新事件到来，自动完成后，**通知Proactor**，Proactor根据事件类型回调不同的Handler进行业务处理
- 缺点
  - 编程复杂性，由于异步操作流程的事件的初始化和事件完成在时间和空间上都是相互分离的，因此开发异步应用程序更加复杂。应用程序还可能因为反向的流控而变得更加难以Debug；
  - 内存使用，缓冲区在读或写操作的时间段内必须保持住，可能造成持续的不确定性，并且每个并发操作都要求有独立的缓存，相比 Reactor模式，在 Socket 已经准备好读或写前，是不要求开辟缓存的；
  - 操作系统支持，异步IO不算特别成熟的技术

### Muduo/WebServer

multiple reactors + thread pool

- 这种方案的特点是**one loop per thread**，有一个main Reactor负责accept(2)连接，然后把连接挂在某个sub Reactor中（muduo采用round-robin的方式来选择sub Reactor），**这样该连接的所有操作都在那个sub Reactor所处的线程中完成**。多个连接可能被分派到多个线程中，以充分利用CPU。
- muduo采用的是**固定大小的Reactor pool**，池子的大小通常根据CPU数目确定

[MultipleReactors](https://raw.githubusercontent.com/wu0hgl/note_pic/master/%E7%BD%91%E7%BB%9CIO_multiple_reactors_thread_pool_pre.png)

关键结构

- EventLoop: one loop per thread顾名思义每个线程只能有一个EventLoop对象。EventLoop的构造函数会记住本对象所属的线程（threadId_）。创建了EventLoop对象的线程是IO线程，其主要功能是运行事件循环EventLoop:: loop()。EventLoop即是时间循环，每次从poller里拿活跃事件，并给到Channel里分发处理。EventLoop对象的生命期通常和其所属的线程一样长，它不必是heap对象。
- Channel: 每个Channel对象自始至终只属于一个EventLoop，因此每个Channel对象都只属于某一个IO线程。每个Channel对象自始至终只负责一个文件描述符（fd）的IO事件分发，但它并不拥有这个fd，也不会在析构的时候关闭这个fd。Channel会把不同的IO事件分发为不同的回调，例如ReadCallback、WriteCallback等，用户无须继承Channel，Channel不是基类。当IO事件发生时，最终会调用到Channel类中的回调函数。因此，程序中所有带有读写时间的对象都会和一个Channel关联，包括loop中的eventfd，listenfd，HttpData等.
- EventLoopThread: 会启动自己的线程，并在其中运行EventLoop::loop()。其中关键的startLoop()函数会返回新线程中EventLoop对象的地址，因此用条件变量来等待线程的创建与运行。
- 定时器：(from [WebServer](https://github.com/linyacool/WebServer))每个SubReactor持有一个定时器，用于处理超时请求和长时间不活跃的连接。muduo中介绍了时间轮的实现和用stl里set的实现，这里我的实现直接使用了stl里的priority_queue，底层是小根堆，并采用惰性删除的方式，时间的到来不会唤醒线程，而是每次循环的最后进行检查，如果超时了再删，因为这里对超时的要求并不会很高，如果此时线程忙，那么检查时间队列的间隔也会短，如果不忙，也给了超时请求更长的等待时间。
- 日志：用一个**背景线程**负责收集日志消息，并写入日志文件，其他业务线程只管往这个“日志线程”发送日志消息，这称为“**异步日志**”，使用异步日志可以防止多线程中的某个现成阻塞或者多线程锁争用问题。muduo日志库采用的是**双缓冲（double buffering）**技术，基本思路是准备两块buffer：A和B，前端负责往buffer A填数据（日志消息），后端负责将buffer B的数据写入文件。当buffer A写满之后，交换A和B，让后端将buffer A的数据写入文件，而前端则往buffer B填入新的日志消息，如此往复。用两个buffer的好处是在新建日志消息的时候不必等待磁盘文件操作，也避免每条新日志消息都触发（唤醒）后端日志线程。换言之，前端不是将一条条日志消息分别传送给后端，而是将多条日志消息拼成一个大的buffer传送给后端，相当于批处理，减少了线程唤醒的频度，降低开销。另外，为了及时将日志消息写入文件，即便buffer A未满，日志库也会每3秒执行一次上述交换写入操作。实际实现采用了**四个缓冲区**，这样可以进一步减少或避免日志前端的等待。

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

### accept

从**已完成连接队列**取得首部的套接字描述符

### listen

socket被命名之后，还不能马上接受客户连接，我们需要使用如下系统调用来创建一个监听队列以存放待处理的客户连接：

```c++
int listen(int sockfd,int backlog);
```

sockfd参数指定被监听的socket。backlog参数提示**内核监听队列的最大长度**。监听队列的长度如果超过backlog，服务器将不受理新的客户连接，客户端也将收到ECONNREFUSED错误信息。backlog参数的典型值是5。

### IO多路复用

IO 复用技术就是协调多个可释放资源的 FD 交替共享任务处理线程完成通信任务，实现多个 fd 对应 1个任务处理线程的复用场景。

IO多路复用可以用来监听多种描述符，如果任一描述符出于就绪状态，它就通知对应进程，然后采取下一步操作

优点：无需开启线程，减少系统开销，比多线程要好很多

Linux中主要有三个API：select、poll、epll

### select原理

```c++
int select(int nfds, fd_set* readfds,fd_set* writefds,fd_set* exceptfds, struct timeval* timeout);
```

select函数返回产生事件的描述符的数量，如果为-1表示产生错误

其中有一个很重要的结构体fd_set，表示描述符的集合，可以将fd_set看作类似操作系统中的位图，其中每个整数的每一bit代表一个描述符

select 函数监视的文件描述符分3类，分别是writefds、readfds、和exceptfds。调用后select函数会阻塞，直到有描述符就绪（有数据可读、可写、或者有except），或者超时（timeout指定等待时间，如果立即返回设为null即可），函数返回。当select函数返回后，可以通过遍历fdset，来找到就绪的描述符，所以**内核会修改fdset，监听和返回集合是同一个**

fd默认大小是1024个，有大小限制。对socket进行扫描时是**线性扫描**，即采用**轮询**的方法，效率较低

### poll原理

```c++
int poll(struct pollfd* fds, nfds_t nfds, int timeout);
```

poll本质上和select没有区别，**每次都会把用户传入的数组拷贝到内核空间**，然后查询每个fd对应的设备状态，如果设备就绪则在设备等待队列中加入一项并继续遍历，如果遍历完所有fd后没有发现就绪设备，则挂起当前进程，直到设备就绪或者主动超时，被唤醒后它又要再次遍历fd。这个过程经历了多次无谓的遍历。

与select的最大区别，监听和返回集合分离，这样不用调用完后不用再

优点：没有最大连接数的限制，因为它是基于**链表**存储的

### epoll原理(仅linux)

epoll将感兴趣的事件**注册到内核的一个事件表**中，当某个fd上事件就绪时，通过**回调函数**在在epoll_wait中返回对应的结构体

epoll没有使用mmap，而是使用的`copy_from_user`与`__put_user`进行内核与用户的交互

调用顺序：

```c++
int epoll_create(int size); // 在内核中创建epfd，返回句柄fd给用户
int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event); // 将fd增删于epfd，epoll_event中定义了用户态关心的epoll_data
int epoll_wait(int epfd, struct epoll_event *events,int maxevents, int timeout); // events是个结构体数组指针存储epoll_event
```

Linux epoll机制是通过**红黑树和双向链表**实现的。

- epoll_create用来创建**红黑树来存储socket**，还会建立一个**双向链表存储就绪事件**
- epoll_ctl在红黑树添加、修改、删除socket，非常快速
- epoll_wait只需要检查list即可

优点：

1. 没有最大并发连接的限制（仅取决于OS的fd数量限制）
2. 效率提升，**不是轮询，而是回调**，不会随着FD数目的增加效率下降；
3. 用红黑树，插入修改删除事件很方便
4. 不像select与poll需要往内核拷贝整个结构体，**增量拷贝**

> [epoll源码分析](https://icoty.github.io/2019/06/03/epoll-source/)
> FreeBSD推出了kqueue，Linux推出了epoll，Windows推出了IOCP，Solaris推出了/dev/poll。这些操作系统提供的功能就是为了解决C10K问题
> libevent跨平台，封装底层平台的调用，提供统一的 API，但底层在不同平台上自动选择合适的调用
> btw, 解决c10m问题，应该从操作系统入手，将控制层交给Linux，应用程序管理数据，应用程序与内核之间没有交互、没有线程调度、没有系统调度、没有中断，什么都没有

### select，poll，epoll比较

- 事件
  - select使用的是fd_set，它没有将fd与事件绑定，所以需要提供三个fd_set（可读、可写、异常）来传入特定事件。而且内核会修改fd_set，所以下次使用时需要**重置**。
  - poll使用的是poll_fd，把**fd与事件绑定**在一起，比select更简洁，监听事件通过events注册，就绪事件通过revents返回，**两者分离**，内核不会修改events，无须重置。
  - epoll在内核**维护了一个事件表**，独立的函数epoll_ctnl往里面增加、修改、删除事件，这样每次epoll_wait调用都可以直接从内核中获得具体事件。

- 数量
  - select有最大数量的限制，1024，可以通过修改内核达到65536个
  - poll、epoll_wait能监听的最大fd数量取决于OS，一般很大，如65535

- 工作模式
  - select、poll只能在LT
  - epoll还能ET，并且支持oneshot

- 时间复杂度
  - select、poll用的是**轮询**，每次调用要扫描整个注册fd集合，返回其中就绪的fd。所以，**索引就绪fd需要O(n)**
  - epoll_wait则不同，采用的是**回调**，直接将就绪事件拷贝到用户空间，**索引就绪fd只需要O(1)**

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

Q1: epoll的ET模式为什么一定要使用**非阻塞IO**

A1:

- ET模式下每次write或read需要循环write或read直到返回EAGAIN错误。以读操作为例，这是因为ET模式只在socket描述符状态发生变化时才触发事件，如果不一次把socket内核缓冲区的数据读完，会导致socket内核缓冲区中即使还有一部分数据，该socket的可读事件也不会被触发
- 所以ET必须结合非阻塞IO使用，如果结合阻塞IO，那么ET模式必然会阻塞在最后一次write/read操作

Q2：使用 Linux epoll 模型的 LT 水平触发模式，当 socket 可写时，会不停的触发 socket 可写的事件，如何处理？

A2：

- 普通做法
  - 当需要向 socket 写数据时，将该 socket 加入到 epoll 等待可写事件
  - 接收到 socket 可写事件后，调用 write 或 send 发送数据，当数据全部写完后， 将 socket 描述符移出 epoll 列表，**这种做法需要反复添加和删除**。
- 改进做法
  - 向 socket 写数据时直接调用 send 发送，当 send 返回错误码 EAGAIN，才将 socket 加入到 epoll，等待可写事件后再发送数据，全部数据发送完毕，再移出 epoll 模型，改进的做法相当于认为 socket 在大部分时候是可写的，不能写了再让 epoll 帮忙监控。

Q3: 在多进程/多线程中，即使epoll使用ET模式，还是有可能触发多次。比如一个进程/线程正在处理某个socket上的事件，而这时该socket又有新事件就绪，此时另外一个进程/线程会被唤醒来处理新事件，这当然不是我们期望的。

A3: 可以开启**epoll oneshot**（确保一个socket只被一个进程/线程使用）

### 线程池怎么实现/线程池的大小一般怎么设置

1. 设置一个**生产者消费者队列**, 作为临界资源
2. 开启n个线程, 加锁去队列取任务运行
3. 当任务队列为空的时候, 所有线程阻塞
4. 当生产者队列来了一个任务后, 先对队列加锁, 把任务挂在到队列上, 然后使用条件变量去通知阻塞中的一个线程

线程池大小的经验公式T=C/P，C是CPU数量，P是密集计算时间占（密集计算时间+IO时间）的估计比例

- 假设C=8, P=1.0, 线程池的任务完全密集计算, 只要8个活动线程就能让cpu饱和
- 假设C=8, P=0.5, 线程池的任务有一半是计算, 一半是IO, 那么T=16, 也就是16个"50%繁忙的线程能让8个cpu忙个不停"

[C++线程池的实现之格式修订版](https://mp.weixin.qq.com/s/1ZAR-0qyTEqscpbLob0toA)

[C++定时器的实现之格式修订版](https://mp.weixin.qq.com/s/PxpzIXfURJTP-JvklhSC0Q)

TODO

### 死循环+来连接时新建线程的方法效率有点低，怎么改进

提前创建好一个**线程池**，用**生产者消费者模型**，创建一个**任务队列**，队列作为临界资源，有了新连接，就挂在到任务队列上，队列为空所有线程睡眠，队列不为空就唤醒线程池中的线程去处理。

改进死循环：使用I/O复用，select/poll/epoll

### 惊群问题

当多个进程和线程在同时阻塞等待同一个事件时，如果这个事件发生，**会唤醒所有的进程**，但**最终只可能有一个进程/线程对该事件进行处理**，其他进程/线程会在失败后重新休眠，这种性能浪费就是惊群。

举例：当一个fd的事件被触发时，所有等待这个fd的线程或进程都被唤醒。假设很多个进程都block在server socket的accept()，一但有客户端进来，**所有进程的accept()都会返回，但是只有一个进程会读到数据，这就是惊群**。实际上现在的Linux内核实现中不会出现惊群了，只会有一个进程被唤醒（Linux2.6内核已实现）。

在Linux3.9之前，epoll也有进群问题。Nginx作为知名使用者采用**全局锁**来限制每次可监听fd的进程数量，使用mutex锁住多个线程是不会惊群的，在某个线程解锁后，只会有一个线程会获得锁，其它的继续等待。

后来在 Linux 3.9 内核中增加了 SO_REUSEPORT 选项实现了内核级的负载均衡，Nginx1.9.1 版本支持了 reuseport 这个新特性，从而解决惊群问题。

使用pthread_cond_signal不会有“惊群现象”产生，他最多只给一个线程发信号。假如有多个线程正在阻塞等待着这个条件变量的话，那么是根据各等待线程优先级的高低确定哪个线程接收到信号开始继续执行。

使用pthread_cond_broadcast/C++11的condition_variable.notify_all会有惊群现象，

### 单台服务器并发TCP连接数到底可以有多少

换个问法：有一个 IP 的服务器监听了一个端口，它的 TCP 的最大连接数是多少？

文件句柄限制

- ulimit -n 输出 1024，说明对于一个进程而言最多只能打开1024个文件，所以你要采用此默认配置最多也就可以并发上千个TCP连接。
- 可以在当前会话临时修改，也可以通过内核文件永久修改。

端口号范围限制

- 操作系统上端口号1024以下是系统保留的，从1024-65535是用户使用的。由于每个TCP连接都要占一个端口号，所以我们最多可以有60000多个并发连接（错！！！！！）
- 一个TCP连接是靠一个四元组构成的，{local ip, local port,remote ip,remote port}，不考虑地址重用（unix的SO_REUSEADDR选项）的情况下，即使server端有多个ip，本地监听端口也是独占的，因此server端tcp连接4元组中只有remote ip（也就是client ip）和remote port（客户端port）是可变的，因此最大tcp连接为客户端ip数×客户端port数，对IPV4，不考虑ip地址分类等因素，最大tcp连接数约为2的32次方（ip数）×2的16次方（port数），也就是server端单机最大tcp连接数约为2的48次方。

上面两点只是理论上的单机TCP并发连接数，实际上单机并发连接数肯定要受硬件资源（内存）、网络资源（带宽）的限制

### Java网络编程模型

- 1）Java BIO ： 同步并阻塞，服务器实现模式为一个连接一个线程，即客户端有连接请求时服务器端就需要启动一个线程进行处理，如果这个连接不做任何事情会造成不必要的线程开销，当然可以通过线程池机制改善；
  - BIO方式适用于连接数目比较小且固定的架构，这种方式对服务器资源要求比较高，并发局限于应用中，JDK1.4以前的唯一选择，但程序直观简单易理解；
- 2）Java NIO ： 同步非阻塞，服务器实现模式为一个请求一个线程，即客户端发送的连接请求都会注册到多路复用器上，多路复用器轮询到连接有I/O请求时才启动一个线程进行处理；
  - NIO方式适用于连接数目多且连接比较短（轻操作）的架构，比如聊天服务器，并发局限于应用中，编程比较复杂，JDK1.4开始支持；
- 3）Java AIO(NIO.2) ： 异步非阻塞，服务器实现模式为一个有效请求一个线程，客户端的I/O请求都是由OS先完成了再通知服务器应用去启动线程进行处理。
  - AIO方式使用于连接数目多且连接比较长（重操作）的架构，比如相册服务器，充分调用OS参与并发操作，编程比较复杂，JDK7开始支持。

## 计算机网络

### OSI有几层协议，TCP/IP有几层协议

OSI具有七层协议，但复杂且不实用，从上到下分别是：应用层、表示层、会话层、运输层、网络层、数据链路层、物理层

TCP/IP具有四层协议，广泛应用，从上到下分别是：应用层，运输层，网络层，网络接口层

谢希仁的《计算机网络》为了把概念解释清楚，把计算机网络分为：应用层（FTP,HTTP,DNS），运输层(TCP,UDP)，网络层(IP,ARP,ICMP)，数据链路层(MAC,VLAN,PPP)，物理层(IEEE802.3)

### ARP/DHCP/NAT/打洞

ARP：在传输一个IP数据报的时候，确定了源IP地址和目标IP地址后，就会通过主机「路由表」确定IP数据包下一跳。然而，网络层的下一层是数据链路层，所以我们还要知道「下一跳」的 MAC 地址。由于主机的路由表中可以找到下一跳的IP地址，所以可以通过 ARP 协议

- 主机会通过广播发送 ARP 请求，这个包中包含了想要知道的 MAC 地址的主机 IP 地址。
- 当同个链路中的所有设备收到 ARP 请求时，会去拆开 ARP 请求包里的内容，如果 ARP 请求包中的目标 IP 地址与自己的 IP 地址一致，那么这个设备就将自己的 MAC 地址塞入 ARP 响应包返回给主机。
- 操作系统通常会把第一次通过 ARP 获取的 MAC 地址缓存起来，以便下次直接从缓存中找到对应 IP 地址的 MAC 地址。

RARP：ARP 协议是已知 IP 地址求 MAC 地址，那 RARP 协议正好相反，它是已知 MAC 地址求 IP 地址。例如将打印机服务器等小型嵌入式设备接入到网络时就经常会用得到。

- 通常这需要架设一台 RARP 服务器，在这个服务器上注册设备的 MAC 地址及其 IP 地址。
- 设备入网时会发送一条「我的 MAC 地址是XXXX，请告诉我，我的IP地址应该是什么」的请求信息。
- RARP 服务器接到这个消息后返回「MAC地址为 XXXX 的设备，IP地址为 XXXX」的信息给这个设备。
- 最后，设备就根据从 RARP 服务器所收到的应答信息设置自己的 IP 地址。

DHCP：动态分配IP地址，我们的电脑一般就是这样的，对不同网段的 IP 地址分配也可以由一个 DHCP 服务器统一进行管理，用到了**中继代理**。

- 客户端首先发起 **DHCP 发现报文（DHCP DISCOVER）** 的 IP 数据报，由于客户端没有 IP 地址，也不知道 DHCP 服务器的地址，所以使用的是 UDP 广播通信，其使用的广播目的地址是255.255.255.255（端口 67） 并且使用 0.0.0.0（端口 68） 作为源 IP 地址。
- DHCP 客户端将该IP 数据报传递给链路层，链路层然后将帧广播到所有的网络中设备。DHCP 服务器收到 DHCP 发现报文时，用 **DHCP 提供报文（DHCP OFFER）** 向客户端做出响应。该报文仍然使用 IP 广播地址 255.255.255.255，该报文信息携带服务器提供可租约的 IP 地址、子网掩码、默认网关、DNS 服务器以及 IP 地址租用期。
- 客户端收到一个或多个服务器的 DHCP 提供报文后，从中选择一个服务器，并向选中的服务器发送 **DHCP 请求报文（DHCP REQUEST）**进行响应，回显配置的参数。
- 最后，服务端用 **DHCP ACK 报文**对 DHCP 请求报文进行响应，应答所要求的参数。

NAT：简单的来说 NAT 就是同个公司、家庭、教室内的主机对外部通信时，把私有 IP 地址转换成公有 IP 地址。一般可以把 IP 地址 + 端口号一起进行转换，这就是网络地址与端口转换 NAPT。

NAT的问题：

- 外部无法主动与 NAT 内部服务器建立连接，因为 NAPT 转换表没有转换记录。
- 转换表的生成与转换操作都会产生性能开销。
- 通信过程中，如果 NAT 路由器重启了，所有的 TCP 连接都将被重置。

解决：

- IPv6：IPv6 可用范围非常大，以至于每台设备都可以配置一个公有 IP 地址
- **NAT穿越**：能够让网络应用程序主**主动**获得 NAT 设备的公有 IP，并为自己建立端口映射条目，注意这些都是藏在NAT设备后的应用程序自动完成的。换句话说，是应用程序主动从 NAT 设备获取公有 IP 地址，然后自己建立端口映射条目，然后用这个条目
对外通信，就不需要 NAT 设备来进行转换了。

NAT打洞：如果终端A要访问终端B。A先给B发送数据需经过NAT B，NAT B打开数据包看来源IP是100.10.10.10，但是NAT B发现自己内部并没有设备请求过这个IP，于是NAT B会认为这个数据包是“不请自来”的。对待这种“不请自来”的数据包，大多数路由器出于安全性的考虑，都选择丢弃包，NAT B也是如此，因此这条请求被抛弃，并没有传达到终端B。反过来终端B访问终端A也是如此。这样看来，终端A和终端B永远都不能通信，这是就需要有第三方介入，完成消息的传达，而这个过程就成为“打洞”。

### ICMP协议/ping命令/trecerout命令/IGMP

IP协议并不是一个可靠的协议，它不保证数据被送达，而ICMP(网络控制报文)协议就是用来保证数据送达的。当传送IP数据包发生错误－－比如主机不可达，路由不可达等等，ICMP协议将会把错误信息封包，然后传送回给主机。给主机一个处理错误的机会。

ICMP 大致可以分为两大类：

- 一类是用于诊断的查询消息，也就是「查询报文类型」
- 另一类是通知出错原因的错误消息，也就是「差错报文类型」

ping：用来探测主机到主机之间是否可通信，如果不能ping到某台主机，表明不能和这台主机建立连接。ping 使用的是ICMP协议，它发送ICMP回送请求消息给目的主机。ICMP协议规定：**目的主机必须返回ICMP回送应答消息给源主机**。如果源主机在一定时间内收到应答，则认为主机可达。
> 接收端ICMP echo请求通常做中断处理并且立即返回，这尽可能减少内核代码运行的时间。发送端，由于时间戳由用户层测量，存在内核上下文切换和内核代码路径时间

Traceroute是用来侦测**主机到目的主机之间所经路由情况**的重要工具

- 它收到目的主机的IP后，首先给目的主机发送一个**TTL=1的UDP数据包**，而经过的第一个路由器收到这个数据包以后，就自动把TTL减1，而TTL变为0以后，路由器就把这个包给抛弃了，并同时产生一个**时间超时**的ICMP差错报文给主机。
- 主机收到这个数据报以后再发一个TTL=2的UDP数据报给目的主机，然后刺激第二个路由器给主机发ICMP数据报。
- 如此往复直到到达目的主机。这样，traceroute就拿到了所有的路由器ip。
- ping 127.0.0.1是测试本机是否安装了TCP/IP协议，不会经过本机网卡的，当然抓包是看不到的

Traceroute还有一个作用是故意设置不分片，从而确定路径的MTU

- 首先在发送端主机发送 IP 数据报时，将 IP 包首部的分片禁止标志位设置为 1。根据这个标志位，途中的路由器不会对大数据包进行分片，而是将包丢弃。
- 随后，通过一个 ICMP 的不可达消息将数据链路上 MTU 的值一起给发送主机，不可达消息的类型为「需要进行分片但设置了不分片位」
- 发送主机端每次收到 ICMP 差错报文时就减少包的大小，以此来定位一个合适的 MTU 值，以便能到
达目标主机。

IGMP：IGMP是因特网组管理协议，工作在主机（组播成员）和最后一跳路由之间

### IP

### IP分类

IP地址由两部分组成，即网络地址/网络号（属于互联网的哪一个网络）和主机地址/主机号（属于该网络中的哪一台主机）

分为A、B、C三类及特殊地址D、E。全0和全1的都保留不用。

![IP分类](https://img-blog.csdnimg.cn/20190108180005960.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2t6YWRteHo=,size_16,color_FFFFFF,t_70)

IP分类

- A类：前1个字节(8位)为网络号，后3个字节(24位)为主机号，而且网络号的第一位固定为0
- B类：前2个字节(16位)为网络号，后2个字节(16位)为主机号。而且网络号的前两位固定为10
- C类：前3个字节(24位)为网络号，后1个字节(8位)为主机号。而且网络号的前三位固定为110
- D类：多播地址，网络号前四位固定为1110，后面28位是多播的组编号，所以用点分十进制的开头是224~239之间
- E类：保留地址，网络号前四位固定为1111，所以地址的网络号取值于240~255之间

> 为啥要把A设为0，B设为10，C设为110这样分类？
> 原因：无前缀码，判断第一位为0就知道是A，第一位为1第二位为0就知道是B，加快寻址

特殊地址

- 0.0.0.0：表示当前主机，在路由中，0.0.0.0是默认路由
- 127.x.x.x：本地环回地址，用来测试本机通信，并不代表本机
- 255.255.255.255：当前子网的广播地址
- ABC类地址主机号位数n，最大主机数为：2^(n-1)，主机号全1用于广播，主机号全0用于指定某个网络

1）问题1：127.0.0.1 本机网络 IO 需要经过网卡吗？

通过本文的叙述，我们确定地得出结论，不需要经过网卡。即使了把网卡拔了本机网络是否还可以正常使用的。

2）问题2：数据包在内核中是个什么走向，和外网发送相比流程上有啥差别？

总的来说，本机网络 IO 和跨机 IO 比较起来，确实是节约了一些开销。发送数据不需要进 RingBuffer 的驱动队列，直接把 skb 传给接收协议栈（经过软中断）。

但是在内核其它组件上可是一点都没少：系统调用、协议栈（传输层、网络层等）、网络设备子系统、邻居子系统整个走了一个遍。连“驱动”程序都走了（虽然对于回环设备来说只是一个纯软件的虚拟出来的东东）。所以即使是本机网络 IO，也别误以为没啥开销。

3）问题3：使用 127.0.0.1 能比 192.168.x 更快吗？

先说结论：我认为这两种使用方法在性能上没有啥差别。

我觉得有相当大一部分人都会认为访问本机 Server 的话，用 127.0.0.1 更快。原因是直觉上认为访问 IP 就会经过网卡。

其实内核知道本机上所有的 IP，只要发现目的地址是本机 IP 就可以全走 loopback 回环设备了。本机其它 IP 和 127.0.0.1 一样，也是不用过物理网卡的，所以访问它们性能开销基本一样！

[不为人知的网络编程(十三)：深入操作系统，彻底搞懂127.0.0.1本机网络通信](http://www.52im.net/thread-3600-1-1.html)

#### 无分类地址CIDR与子网掩码

IP分类缺点：

- 同一网络下没有地址层次
- 不能很好的与现实网络匹配，C类地址最大主机数太少，只有256，而A类又太多，6w+

**无分类地址**不再有分类地址的概念，32 比特的 IP 地址被划分为两部分，前面是网络号，后面是主机号。表示形式 a.b.c.d/x ，其中 /x 表示前 x 位属于网络号， x 的范围是 0 ~ 32 ，这就使得 IP 地址更加灵活

还有另一种划分网络号与主机号形式，那就是**子网掩码**，掩码的意思就是掩盖掉主机号，剩余的就是网
络号。将子网掩码和 IP 地址按位计算 AND，就可得到网络号。

子网掩码还有一个作用，那就是**划分子网**。子网划分实际上是将主机地址分为两个部分：子网网络地址和子网主机地址。

- 未做子网划分的 ip 地址：网络地址＋主机地址
- 做子网划分后的 ip 地址：网络地址＋（子网网络地址＋子网主机地址

假设对 C 类地址进行子网划分，网络地址 192.168.1.0，使用子网掩码 255.255.255.192 对其进行子网
划分。C 类地址中前 24 位是网络号，最后 8 位是主机号，根据子网掩码可知从 8 位主机号中借用 2 位作为子
网号。由于子网网络地址被划分成 2 位，那么子网地址就有 4 个，分别是 00、01、10、11。这四个子网的主机号全0用来指定网络，全1用来这个子网的广播

#### IPv6

IPv6 相比 IPv4 的首部改进：

- 取消了首部校验和字段。 因为在数据链路层和传输层都会校验，因此 IPv6 直接取消了 IP 的校验。
- 取消了分片/重新组装相关字段。 分片与重组是耗时的过程，IPv6 不允许在中间路由器进行分片与重组，这种操作只能在源与目标主机，这将大大提高了路由器转发的速度。
- 取消选项字段。 选项字段不再是标准 IP 首部的一部分了，但它并没有消失，而是可能出现在IPv6 首部中的「下一个首部」指出的位置上。删除该选项字段使的 IPv6 的首部成为固定长度的40 字节。

### TCP和UDP的区别

1. 连接：TCP是面向连接的，即传输数据之前必须先建立好连接；UDP无连接
2. 服务对象：TCP是点对点的两点间服务，即一条TCP连接只能有两个端点；UDP支持一对一，一对多，多对一，多对多的交互通信
3. 可靠性：TCP是可靠交付：无差错，不丢失，不重复，按序到达；UDP是尽最大努力交付，不保证可靠交付。
4. 拥塞控制：TCP有慢开始、拥塞避免、快重传和快恢复；UDP没有拥塞控制，网络拥塞不会影响源主机的发送速率
5. 首部开销：TCP首部开销20字节；UDP首部开销8字节
6. 穿书方式：面向报文（UDP），面向字节流（TCP），TCP的消息是「没有边界」的，所以无论我们消息有多大都可以进行传输。并且消息是「有序的」，当「前一个」消息没有收到的时候，即使它先收到了后面的字节，那么也不能扔给应用层去处理，同时对「重复」的报文会自动丢弃。
7. 分片不同：TCP 的数据大小如果大于 MSS 大小，则会在传输层进行分片，目标主机收到后，也同样在传输层组装 TCP 数据包，如果中途丢失了一个分片，只需要传输丢失的这个分片。UDP 的数据大小如果大于 MTU 大小，则会在 IP 层进行分片，目标主机收到后，在 IP 层组装完数据，接着再传给传输层，但是如果中途丢了一个分片，则就需要重传所有的数据包，这样传输效率非常差，所以通常 UDP 的报文应该小于 MTU。

看重数据完整性选择TCP，看重通信实时性选择UDP

TCP与UDP同时发送可能会互相影响，TCP的流量控制可能会影响UDP的丢包率，而UDP的发包率有可能影响TCP的滑动窗口大小

**TCP与UDP能访问同一个端口**，因为当主机收到一个以太网帧时，从协议栈自底向上解析，每层都会检查首部的协议标识，这就是**分用（Demultiplexing）**，所以即使端口相同，但是TCP与UDP是独立的

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

#### 三次握手交换了什么数据

除了序列号，第一次还包括client通告server的接收窗口大小以及本方的MSS，第二次还包括server通告client的接收窗口大小以及本方的MSS

#### 三次握手为什么两次不可以，为什么四次没必要

三次握手的首要原因是为了**防止旧的重复连接初始化造成混乱**。如果是历史连接（序列号过期或超时），则第三次握手发送的报文是 RST 报文，以此中止历史连接；如果不是历史连接，则第三次发送的报文是 ACK 报文，通信双方就会成功建立连接；

还有一个原因是因为有可能Client的第一个SYN报文段长时间滞留在网络中，Client一直等不到回应就释放了连接，但Server收到这个滞后的SYN报文段会向Client发送确认，并且同意建立连接，Client此时已经释放连接了，对Server的连接确认不予理睬，于是Server空空等待Client发来数据，浪费资源！

第二次与第三次可以合并在一起，所以四次没必要

#### 三次握手的第三次丢失怎么办

server没有收到ACK，超时重传，一定次数还没收到则关闭连接

第二次握手，client就已经进入established状态，若第三次丢失，则发送数据给server时，server还未建立连接，会返回RST报文，这时client就能感知到了

#### 有可能四次握手吗

有可能。当两端**同时**发起 SYN 来建立连接的时候，就出现了四次握手

#### 有可能三次挥手吗

如果 Server 在收到 Client 的 FIN 包后，在也没数据需要发送给 Client 了，那么对 Client 的 ACK 包和 Server 自己的 FIN 包就可以合并成为一个包发送过去，这样四次挥手就可以变成三次了(似乎 linux 协议栈就是这样实现的)

#### 初始序列号ISN为什么是随机的，怎么随机

1. 如果不是随机产生初始序列号，黑客将会以很容易的方式获取到你与其他主机之间通信的初始化序列号，并且**伪造序列号进行攻击**
2. 在网络不好的场景中，TCP连接可能不停地断开，若用固定ISN，很可能新连接建立后，之前在网络中延迟的数据报才到达，这就**乱套**了
3. 不同OS的ISN生成算法不一样，就是随机数生成算法，比如RFC文档推荐：`ISN = M + F(localhost, localport, remotehost, remoteport)`，M是个计时器，每隔 4 毫秒加 1，F是个哈希算法，一般用MD5比较安全
4. ISN是32位的

#### socket编程

- 客户端 connect 成功返回是在第二次握手成功
- 服务端 accept 成功返回是在三次握手成功

为了方便调试服务器程序，一般会在服务端设置 SO_REUSEADDR 选项，这样服务器程序在重启后，可以立刻使用。这里设置SO_REUSEADDR 是不是就等价于对这个 socket 设置了内核中 的 net.ipv4.tcp_tw_reuse=1 这个选项？

- tcp_tw_reuse 是内核选项，主要用在连接的发起方（客户端）。TIME_WAIT 状态的连接创建时间超过 1 秒后，新的连接才可以被复用，注意，这里是「连接的发起方」；
- SO_REUSEADDR 是用户态的选项，用于「连接的服务方」，用来告诉操作系统内核，如果端口已被占用，但是 TCP 连接状态位于 TIME_WAIT ，可以重用端口。如果端口忙，而 TCP 处于其他状态，重用会有 “Address already in use” 的错误信息。
- tcp_tw_reuse 是为了**缩短 time_wait 的时间**，避免出现大量的 time_wait 连接而占用系统资源，解决的是 accept 后的问题。
- SO_REUSEADDR 是为了**解决 time_wait 状态带来的端口占用问题**，以及支持同一个 port 对应多个ip，解决的是 bind 时的问题。

#### FIN包如何断开连接

- 客户端调用 close ，表明客户端没有数据需要发送了，则此时会向服务端发送 FIN 报文，进入FIN_WAIT_1 状态；
- 服务端接收到了 FIN 报文，TCP 协议栈会为 FIN 包**插入一个文件结束符 EOF 到接收缓冲区**中，应用程序可以通过 read 调用来感知这个 FIN 包。这个 EOF 会被放在已排队等候的其他已接收的数据之后，这就意味着服务端需要处理这种异常情况，因为 EOF 表示在该连接上再无额外数据到达。此时，服务端进入 CLOSE_WAIT 状态；
- 接着，当处理完数据后，自然就会读到 EOF ，于是也调用 close 关闭它的套接字，这会使得客户端会发出一个 FIN 包，之后处于LAST_ACK 状态；
- 客户端接收到服务端的 FIN 包，并发送 ACK 确认包给服务端，此时客户端将进入 TIME_WAIT 状态；
- 服务端收到 ACK 确认包后，就进入了最后的 CLOSE 状态；
- 客户端经过 2MSL 时间之后，也进入 CLOSE 状态

#### 为什么A在TIME-WAIT状态必须等待2*MSL时间

1. 第四次挥手的ACK报文可能丢失，B如没有收到ACK报文，则会不断重复发送FIN报文，所以A不能立即关闭，必须确认B收到了ACK，`2*MSL`正好是一个发送和一个回复的最大时间，如果A直到`2*MSL`还没收到B的重复FIN报文，则说明第四次挥手的ACK已经成功接收，于是可以放心的关闭TCP连接了。
2. 第四次挥手的ACK报文之后，再经过2*MSL的时间，就是本次连接持续时间内产生的所有报文都从网络中消失，这样下一个新的TCP连接就不会出现旧的连接请求报文了。
3. 2MSL 的时间是从客户端接收到 FIN 后发送 ACK 开始计时的。如果在 TIME-WAIT 时间内，因为客户端的 ACK 没有传输到服务端，客户端又接收到了服务端重发的 FIN 报文，那么 2MSL 时间将重新计时。
4. **在 Linux 系统里 2MSL 默认是 60 秒**，那么一个 MSL 也就是 30 秒。Linux 系统停留在TIME_WAIT 的时间为固定的 60 秒��

[TCP漫谈之keepalive和time_wait](https://mp.weixin.qq.com/s/8wAjPNQGC_l4p-j8OIbPNQ)

#### time_wait状态太多如何处理

1. 开启tcp_timestamps：在TCP可选选项(option)字段内记录最后一次发送时间和最后一次接收时间（这是time_wait重用和快速回收的保证），`net.ipv4.tcp_timestamps = 1`
2. 开启time_wait重用：因为time_wait是主动关闭方的状态，当客户端发送方又有新的TCP连接想要发起时，可以直接**重用正在time_wait状态的TCP连接**，接收端收到数据报，可以**通过timestamp字段判断属于复用前的连接还是复用后的连接**，`net.ipv4.tcp_tw_reuse = 1`
3. 开启time_wait快速回收：不再等待2MSL，而是RTO（远小于2MSL），`net.ipv4.tcp_tw_recycle = 1`，但time_wait不等待2MSL的话会出现之前的问题，所以Linux4.12版本后就废弃这个参数了，NAT也不好处理time_wait
4. tcp_max_tw_buckets 控制并发的 TIME_WAIT 的数量，默认值是 180000。如果超过默认值，内核会把多的 TIME_WAIT 连接清掉，然后在日志里打一个警告。官网文档说这个选项只是为了阻止一些简单的 DoS 攻击，平常不要人为的降低它。
5. 简单来说，就是打开系统的**time_wait重用和快速回收**。但是这是非常危险的，因为这两个参数违反了TCP协议，而且time_wait状态只有主动发起FIN的那方才会有的，服务器一般不会主动断连，特别是HTTP服务器会设置KeepAlive保持连接

#### close_wait状态太多如何处理

在服务器与客户端通信过程中，因服务器发生了socket未关导致的closed_wait发生，致使监听port打开的句柄数到了1024个，且均处于close_wait的状态，最终造成配置的port被占满出现“Too many open files”，无法再进行通信。

close_wait状态出现的原因是被动关闭方未关闭socket造成，更多是由于程序编写不当造成的，比如被动关闭方没有检测到关闭socket，或者程序忘记要关闭socket，所以需要修改程序的逻辑

#### 往close的TCP连接发送数据会发生什么？

Linux下显示32: Broken pipe

- 1）当TCP连接的对端进程已经关闭了Socket的情况下，本端进程再发送数据时，第一包可以发送成功（但会导致对端发送一个RST包过来）：之后如果再继续发送数据会失败，错误码为“10053: An established connection was aborted by the software in your host machine”（Windows下）或“32: Broken pipe，同时收到SIGPIPE信号”（Linux下）错误；之后如果接收数据，则Windows下会报10053的错误，而Linux下则收到正常关闭消息；
- 2）TCP连接的本端接收缓冲区中还有未接收数据的情况下close了Socket，则本端TCP会向对端发送RST包，而不是正常的FIN包，这就会导致对端进程提前（RST包比正常数据包先被收到）收到“10054: An existing connection was forcibly closed by the remote host”（Windows下）或“104: Connection reset by peer”（Linux下）错误。

[不为人知的网络编程(四)：深入研究分析TCP的异常关闭](http://www.52im.net/thread-1014-1-1.html)

### 半连接队列与全连接队列

[TCP 半连接队列和全连接队列满了会发生什么？又该如何应对？](https://mp.weixin.qq.com/s/2qN0ulyBtO2I67NB_RnJbg)

#### 定义

在 TCP 三次握手的时候，Linux 内核会维护两个队列，分别是：

- 半连接队列（SYN队列）：服务端收到客户端发起的 SYN 请求并向客户端响应 SYN+ACK后，内核会把该连接存储到半连接队列
- 全连接队列（accept队列）：服务端收到第三次握手的 ACK 后，内核会把连接从半连接队列移除，并将其添加到 accept 队列，等待进程调用 accept 函数时把连接取出来。

不管是半连接队列还是全连接队列，都有最大长度限制，超过限制时，内核会直接丢弃，或返回 RST 包。

在 linux kernel 2.2 之前 backlog 指的是syn和accept两个队列的和。而 2.2 以后，就指的是accept的大小

#### 实战——TCP全连接队列溢出

查看全连接队列：在服务端可以使用 ss 命令，来查看 TCP 全连接队列的情况

但需要注意的是 ss 命令获取的 Recv-Q/Send-Q 在「LISTEN 状态」和「非 LISTEN 状态」所表达的含义是不同的。从下面的内核代码可以看出区别：

在「LISTEN 状态」时，Recv-Q/Send-Q 表示的含义如下：

- Recv-Q：当前全连接队列的大小，也就是当前已完成三次握手并等待服务端 accept() 的 TCP 连接个数；
- Send-Q：当前全连接最大队列长度，上面的输出结果说明监听 8088 端口的 TCP 服务进程，最大全连接长度为 128；

在「非 LISTEN 状态」时，Recv-Q/Send-Q 表示的含义如下：

- Recv-Q：已收到但未被应用进程读取的字节数；
- Send-Q：已发送但未收到确认的字节数；

如果全连接队列满了，系统内核的默认行为是**丢弃连接**（丢弃client发过来的ack），也可以修改为发送RST复位报文，告诉客户端连接已经建立失败

TCP 全连接队列的最大值取决于 somaxconn 和 backlog 之间的最小值，也就是 **min(somaxconn, backlog)**，somaxconn是Linux系统内核的参数，默认是128，backlog是listen函数的参数

#### 实战 - TCP 半连接队列溢出

查看半连接队列：服务端处于 SYN_RECV 状态的 TCP 连接，就是在 TCP 半连接队列，命令

模拟 TCP 半连接溢出场景不难，实际上就是对服务端一直发送 TCP SYN 包，但是不回第三次握手 ACK，这样就会使得服务端有大量的处于 SYN_RECV 状态的 TCP 连接。这其实也就是所谓的 SYN 洪泛、SYN 攻击、DDos 攻击。

半连接队列最大值不是单单由 **max_syn_backlog** 决定，还跟 **somaxconn 和 backlog** 有关系。

### SYN flood是什么

DDOS，控制很多客户端向服务器发送SYN包，服务器会发送SYN+ACK，而客户端不作响应，服务器会重传SYN+ACK，造成大量浪费

解决方法：

- 增大半连接队列：不能只单纯增大 tcp_max_syn_backlog 的值，还需一同增大 somaxconn 和 backlog，也就是**增大全连接队列**
- 减少 SYN+ACK 重传次数：当服务端受到 SYN 攻击时，就会有**大量处于 SYN_REVC 状态的 TCP 连接**，处于这个状态的 TCP 会重传 SYN+ACK ，当重传超过次数达到上限后，就会断开连接。那么针对 SYN 攻击的场景，我们可以减少 SYN+ACK 的重传次数，以加快处于 SYN_REVC 状态的 TCP 连接断开。参数是：tcp_synack_retries
- 处理不过来的直接丢弃了，参数是：tcp_abort_on_overflow
- **开启 tcp_syncookies**：tcp_syncookies是一个开关，是否打开SYN Cookie功能，**完成三次握手前不为任何一个连接分配任何资源**，具体做法是：
  - 在TCP服务器接收到TCP SYN包并返回TCP SYN + ACK包时，不分配一个专门的数据区（暂时不分配资源），而是根据这个SYN包计算出一个cookie值。
  - 这个cookie作为将要返回的SYN ACK包的初始序列号。
  - 当客户端返回一个ACK包时，根据包头信息计算cookie，与返回的确认序列号(初始序列号 + 1)进行对比，如果相同，则是一个正常连接，**跳过【SYN】队列直接放入到「 Accept 队列」**,然后，分配资源，建立连接。
  - 实现的关键在于cookie的计算，cookie的计算应该包含本次连接的状态信息，使攻击者不能伪造。

### TCP的序列号、确认号

- 每一个包都包含一个32位序列号，用来跟踪该端发送的数据量
- 每一个包还有一个32位的确认好，用来通知对端接收成功的数据量。
- 序列号为当前端成功发送的数据位数，确认号为当前端成功接收的数据位数，SYN标志位和FIN标志位也要占1位
- wireshark可以显示**相对**序列号/相对确认号，它们的值是相对于TCP三次握手的第一个数据报的序列号确定的，下面例子的序列号与确认号就是相对的

假设有一个web客户端向web服务器端发送请求

![tcp stream](https://img-blog.csdn.net/20140725104320005?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvYTE5ODgxMDI5/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

- 包1：TCP会话的每一端的序列号都从0开始（其实是ISN随机生成，这里用**相对**序列号方便理解），同样的，确认号也从0开始，因为此时通话还未开始，没有通话的另一端需要确认
- 包2：服务端响应客户端的请求，响应中附带序列号0（由于这是服务端在该次TCP会话中发送的第一个包，所以序列号为0）和相对确认号1（表明服务端收到了客户端发送的包1中的SYN）
    需要注意的是，尽管客户端没有发送任何有效数据，确认号还是被加1，这是因为接收的包中包含SYN或FIN标志位，SYN或FIN会**消耗一个序列号**
- 包3：和包2中一样，客户端使用确认号1响应服务端的序列号0，同时响应中也包含了客户端自己的序列号（由于服务端发送的包中确认收到了客户端发送的SYN，故客户端的序列号由0变为1）

此时，通信的两端的序列号都为1，通信两端的序列号增1发生在所有TCP会话的建立过程中

- 包4：客户端向服务器发送，这是流中第一个携带有效数据的包（确切的说，是客户端发送的HTTP请求），序列号依然为1，因为到上个包为止，还没有发送任何数据，确认号也保持1不变，因为客户端没有从服务端接收到任何数据，这个包中有效数据的长度为725字节
- 包5：服务器接收到包4，向客户端回复确认，确认号的值增加了725（725是包4中有效数据长度），变为726，简单来说，服务端以此来告知客户端端，**目前为止，我总共收到了726字节的数据**，服务端的序列号保持为1不变，因为自己还没发送数据
- 包6：服务器向客户端回复响应，序列号依然为1，因为服务端在该包之前返回的包中都不带有有效数据，该包带有1448字节的有效数据
- 包7：客户端再发送，TCP客户端的序列号增长至726，又因为从服务端接收了1448字节的数据，客户端的确认号由1增长至1449

在抓包文件的主体部分，我们可以看到上述过程的不断的重复，客户端的序列号一直是726，因为客户端除了最初的725字节数据没有再向服务端发送数据，服务端的序列号则与此相反，由于服务端不断的发送HTTP响应，故其序列号一直在增长

![tcp close](https://img-blog.csdn.net/20140725125056842?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvYTE5ODgxMDI5/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

- 包38：客户端发送FIN包，其确认号和之前的包37一样，FIN包要消耗一个序列号
- 包39：服务端通过将确认号加1的方式回应客户端期望关闭连接的请求（这里和包2中确认SYN标志位时所作的操作是一样的），同时设置当前包的FIN标志位，这里的**第二次挥手与第三次挥手合二为一**了！
- 包40：客户端发送最终序列号727，通过将确认号加1的方式确认服务端的FIN包

此时，通信双方都终结了会话并且可以释放用于维持会话所占用的资源

### 重传机制

#### 超时重传

- 重传机制的其中一个方式，就是在发送数据时，设定一个定时器，当超过指定的时间后，没有收到对方的 ACK 确认应答报文，就会重发该数据，也就是我们常说的超时重传。
- RTT 就是数据从网络一端传送到另一端所需的时间，也就是包的往返时间。超时重传时间是以 RTO （Retransmission Timeout 超时重传时间）表示。精确的测量超时时间 RTO 的值是非常重要的，这可让我们的重传机制更高效。超时重传时间 RTO 的值应该略大于报文往返 RTT 的值。
- 算RTO需要平滑测量RTT，每当遇到一次超时重传的时候，都会将下一次超时时间间隔设为先前值的两倍。两次超时，就说明网络环境差，不宜频繁反复发送。

```shell
# Jacobson / Karels 算法
SRTT = SRTT + α (RTT – SRTT) ：计算平滑RTT；
DevRTT = (1-β)*DevRTT + β*(|RTT-SRTT|) ：计算平滑RTT和真实的差距（加权移动平均）；
RTO= μ * SRTT + ∂ *DevRTT ： 神一样的公式。
```

#### 快速重传

- TCP 还有另外一种快速重传（Fast Retransmit）机制，它不以时间为驱动，而是以数据驱动重传。
- 当收到三个连续相同的ACKx时，直接重传SEQx，快速重传在TCP拥塞控制中广泛使用
- 问题：重传的时候，是重传之前的一个SEQ，还是重传包括那个SEQ之后的所有SEQ，由SACK解决

#### SACK选择确认

- 解决了快速重传不知道重传哪个的问题。
- 这种方式需要在 TCP 头部「选项」字段里加一个 SACK 的东西，它可以将已经接收到的数据发给发送方，这样发送方就可以知道哪些数据收到了，哪些数据没收到，知道了这些信息，就可以只重传丢失的 数据。
- 如果要支持 SACK ，必须双方都要支持。在 Linux 下，可以通过 net.ipv4.tcp_sack 参数打开这个功能(Linux 2.4 后默认打开)。

```shell
send 100-299
ack 300
send 300-499 (lost)
send 500-699
ack 300, sack 500-700
(now client knows 500-700 lost)
```

#### Duplicate SACK

Duplicate SACK 又称 D-SACK ，其主要使用了 SACK 来告诉「发送方」有哪些数据被重复接收了。

D-SACK使用了SACK的第一个段来做标志：

- 如果SACK的第一个段的范围被ACK所覆盖，那么就是D-SACK
- 如果SACK的第一个段的范围被SACK的第二个段覆盖，那么就是D-SACK

D-SACK 有这么几个好处:

1. 可以让「发送方」知道，是发出去的包丢了，还是接收方回应的 ACK 包丢了
2. 可以知道是不是「发送方」的数据包被网络延迟了;
3. 可以知道网络中是不是把「发送方」的数据包给复制了;

在 Linux 下可以通过 net.ipv4.tcp_dsack 参数开启/关闭这个功能(Linux 2.4 后默认打开)。

```shell
# 例子1：ACK丢包
send 3000-3499, ack 3500(lost)
send 3500-3999, ack 4000(lost)
(now client received ack for 3000-3499, so he decide to retransmit)
send 3000-3499, ack 4000, sack 3000-3500
(now client knows server received 3000~3999, and received 3000-3500 twice)
# 例子2：网络延迟
Transmitted    Received    ACK Sent
Segment        Segment     (Including SACK Blocks)
  
500-999        500-999     1000
1000-1499      (delayed)
1500-1999      1500-1999   1000, SACK=1500-2000
2000-2499      2000-2499   1000, SACK=1500-2500
2500-2999      2500-2999   1000, SACK=1500-3000
1000-1499      1000-1499   3000
                       1000-1499   3000, SACK=1000-1500
(now client knows 1000-1500)
                                      ---------
```

### TCP Fast Open（TFO）

一句话总结：在TCP的三次握手过程中就开始传输数据

实现原理：它通过握手开始时的SYN包中的**TFO cookie（一个TCP选项）**来验证一个**之前连接过的客户端**。如果验证成功，它可以在三次握手最终的ACK包收到**之前**就开始发送数据，这样便跳过了一个RTT，更在传输开始时就降低了延迟。这个加密的Cookie被存储在客户端，在一开始的连接时被设定好。然后每当客户端连接时，这个Cookie被重复返回。

**请求**Fast Open Cookie

1. 客户端发送SYN数据包，该数据包包含Fast Open选项，且该选项的Cookie为空，这表明客户端请求Fast Open Cookie;
2. 支持TCP Fast Open的服务器生成Cookie,并将其置于SYN-ACK数据包中的Fast Open选项以发回客户端;
3. 客户端收到SYN- -ACK后，缓存Fast Open选项中的Cookie。

**实施**TCP Fast Open（假定客户端在此前的TCP连接中已完成请求Fast Open Cookie的过程并存有有效的Fast Open Cookie。

1. 客户端发送SYN数据包，该数据包**包含数据**(对于非TFO的普通TCP握手过程，SYN数据包中不包含数据)以及此前记录的Cookie;
2. 支持TCP Fast Open的服务器会对收到Cookie进行校验：如果Cookie有效，服务器将在SYN-ACK数据包中对SYN和数据进行确认，服务器随后将数据递送至相应的应用程序；否则，服务器将丢弃SYN数据包中包含的数据，发送普通第二次握手;
3. 如果服务器接受了SYN数据包中的数据，服务器可在握手完成之前发送数据;
4. 客户端将发送ACK确认服务器发回的SYN以及数据，但如果客户端在初始的SYN数据包中发送的数据未被确认，则客户端将重新发
送数据;
5. 此后的TCP连接和非TFO的正常情况一-致。

在 Linux 3.7 内核版本中，提供了 TCP Fast Open 功能，可以通过设置 net.ipv4.tcp_fastopn 内核参数，来打开 Fast Open 功能。

### TCP的4种定时器(Timer)

1. 重传计时器(Retransmission Timer)：在2*RTT时间内收不到确认则重传
2. 持续计时器(Persistent Timer)：专门为对付零窗口通知而设立的。
   1. 零窗口通知是指告诉对方，本地的接收窗口为0，所以不能发送，需要等待本地发送非0窗口通知，但如果这个非0窗口通知在网络中丢失，双方都会等待对方通信，这就会产生**死锁**。
   2. 所以TCP协议规定在接收到零窗口通知后，开启一个持续计时器。如果持续计时器超时，则会发送**窗口探测报文**，对方确认探测报文后，会回复现在的接收窗口大小
3. 保活计时器(Keeplive Timer)：每当服务器收到客户的信息，就将keeplive timer复位，若保活定时器超时（一般设为2h）则间隔75秒发送10个探测报文段，若还没响应则关闭连接；如果对端正处于崩溃或者已重启，会发送RST报文，服务端则直接终止该连接
   1. 但我们还是需要应用层的保活机制：因为TCP KeepAlive超时时间太长，为提高无线网络资源利用率， 运营商长则几分钟短则数十秒就会回收空闲的网络连接；
   2. 而且TCP长连接可能因为弱网问题
4. 时间等待计时器(Time_Wait Timer)：TCP关闭连接时使用，2*MSL

### 数据包/报文段大小

- UDP报文段：首部固定8字节+数据部分
- TCP报文段：首部固定20字节+首部可变部分字节+数据部分
- IP数据包：首部固定20字节+首部可变部分字节+数据部分（可能是一个完整UDP/TCP报文段）

Q1：为什么 UDP 头部没有「首部长度」字段，而 TCP 头部有「首部长度」字段呢？

A1：原因是 TCP 有可变长的「选项」字段，而 UDP 头部长度则是不会变化的，无需多一个字段去记录
UDP 的首部长度。

Q2：为什么 UDP 头部有「包长度」字段，而 TCP 头部则没有「包长度」字段呢？

A2：因为有`TCP数据长度 = IP总长度 - IP首部长度 - TCP首部长度`，所以包长度是冗余的；而UDP可能为了4字节的对齐而添加的包长度

### MTU/MSS/分片

MTU是Maximum Transimission Unit，是数据链路层对于数据帧的限制，所以IP层会根据MTU来进行分片，局域网一般是1500字节，因特网一般是576字节，只有「第一个分片」才具有 TCP 头部，后面的分片则没有 TCP 头部，因为这是IP层的嘛

```shell
$ netstat -i
Kernel Interface table
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
eth0      1500   514689      0      0 0        342063      0      0      0 BMRU
lo       65536    89294      0      0 0         89294      0      0      0 LRU
```

> 丢包了，需要重发一个包的字节。以太网就规定了最大为1500，就是权衡了能传输数据段的大小，和丢包带来的损失。

MSS是Maximum Segment Size，是TCP对于段的限制，TCP报文段长度大于MSS时要分段传输，MSS值一般在双方建立连接时协商，双方发送SYN报文的同时会把期望接收的MSS，所以一般`MSS=MTU-IP首部-TCP首部`，对于局域网`1500-20-20=1460字节`，对于因特网`576-20-20=536字节`。所有「分片都具有 TCP 头部」，因为每个 MSS 分片的是具有 TCP 头部的TCP报文

> 注意：如果是UDP，那首部消耗是8字节，所以局域网的UDP的MSS为1500-8-20=1472，因特网的UDP的MSS为576-8-20=548字节

结论：TCP会避免在IP层分片（因为如果一个IP分片包丢失，会重传整个IP报文所有分片包），于是在传输层根据MSS分片，这样重传只会重传TCP分片报文。UDP没有TCP的MSS，所以UDP报文段在IP层可能会根据MSS分片！

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

大部分人就会开始说丢包重传、接收确认之类的东西，但这些都扯偏了，只有少数人能够正确回答题目要问的问题：**首部校验**。

对于能答上这个问题的人，我会进一步问，这个校验机制能够确保数据传输不会出错吗？

答案：**不能**

TCP的首部字段中有一个字段是校验和，发送方将伪首部、TCP首部、TCP数据使用累加和校验的方式计算出一个数字，然后存放在首部的校验和字段里，接收者收到TCP包后重复这个过程，然后将计算出的校验和和接收到的首部中的校验和比较，如果不一致则说明数据在传输过程中出错。可以想到，万一有两个首尾两个bit翻转了，这是错误信息，但是没法检测出来

最好是在应用层重新建立一套数据校验机制，如MD5校验

### 流量控制是什么/滑动窗口是什么/窗口过大或者过小有什么不好

流量控制只涉及发送端和接收端（拥塞控制是全局链路），防止发送方发的太快，而接收方来不及处理

TCP滑动窗口基于**确认应答**，可以提供**可靠性**以及**流控特性**，体现了**面向字节流**

TCP的发送缓冲区的数据包括

1. 已经发送并且已经ACK的
2. 已经发送但没ACK的（即**发送窗口**
3. 未发送但对端允许发送（即**可用窗口**
4. 未发送且对端不允许发送

TCP的接收缓冲区的数据包括

1. 已成功接收并确认的数据，等待应用进程读取
2. 未收到数据但可以接收的数据;（即**接收窗口**
3. 未收到数据并不可以接收的数据;

TCP是全双工协议，双方都有发送窗口和接收窗口，**接收窗口取决于系统**，**发送窗口取决于对端通告的接收窗口**，要求相同，但是因为传输过程存在延迟，所以接收窗口与发送窗口是**约等于**的关系

发送窗口只有在收到对端对于本端发送窗口内字节的ACK确认，才会往前移动（这就是滑动的意思），接收窗口只有在前面的数据都收到的情况下才会往前移动。

- 窗口太大：发送的数据太多，产生网络拥塞，所以需要拥塞控制
- 窗口太小：糊涂窗口综合征，每次只发送一字节，只确认一字节，效率非常低

### 零窗口/糊涂窗口综合征/Nagle算法/TCP_NODELAY/延迟确认

零窗口（zero window）

- 如果server处理缓慢，接受窗口越来越小，不一会就成了零窗口（zero window），因为client无法发TCP数据报，那client要如何知道server的窗口可用了呢？
- TCP使用了Zero Window Probe技术(ZWP)，发送端在窗口变成0后，会发ZWP的包给接收方，让接收方来ack他的Window尺寸，一般这个值会设置成3次，第次大约30-60秒（不同的实现可能会不一样）。如果3次过后还是0的话，有的TCP实现就会发RST把链接断了。
- 有等待的地方就会有DDoS攻击，一些攻击者会在和HTTP建好链发完GET请求后，就把Window设置为0，然后服务端就只能等待进行ZWP，于是攻击者会并发大量的这样的请求，把服务器端的资源耗尽

糊涂窗口综合症(Silly Window Syndrome)

- 接收方窗口太小，通知发送方后，发送方也会义无反顾的填充这几个字节，导致负荷比很低
- MTU是1500字节，除去TCP+IP头的40个字节，真正的数据传输可以有1460字节
- 如果每次为了发1个字节的数据，需要消耗40字节，得不偿失

David D Clark’s 方案（receiver端解决）

- 在receiver端，如果收到的数据导致window size小于某个值，可以直接ack(0)回sender，这样就把window给关闭了，也阻止了sender再发数据过来，等到receiver端处理了一些数据后windows size 大于等于了MSS，或者，receiver buffer有一半为空，就可以把window打开让send 发送数据过来。

Nagle算法(sender端解决)。规则如下：

1. 如果长度达到MSS，则允许发送
2. 包含FIN，则允许发送
3. 设置了TCP_NODELAY套接字选项，则允许发送
4. 超时，则允许发送

启用TCP_NODELAY选项可以禁止Nagle算法，减少时延

- 关闭Nagle算法没有全局参数，需要每个应用手动关闭。
- 比如像telnet或ssh这样的交互性比较强的程序，你需要关闭这个Nagle算法
- 现在局域网、广域网带宽资源相对以前较充裕，不需要Nagle算法了，所以TCP_NODELAY是默认打开的

延迟确认也可以解决糊涂窗口综合征，事实上当没有携带数据的 ACK，它的网络效率也是很低的，因为它也有 40 个字节的 IP 头 和 TCP 头，但却没有携带数据报文。为了解决 ACK 传输效率低问题，所以就衍生出了 TCP 延迟确认。

- 当有响应数据要发送时，ACK 会随着响应数据一起立刻发送给对方
- 当没有响应数据要发送时，ACK 将会延迟一段时间，以等待是否有响应数据可以一起发送
- 如果在延迟等待发送 ACK 期间，对方的第二个数据报文又到达了，这时就会立刻发送 ACK

### 拥塞控制算法/BBR

关于BBR的好文（面试向）：[面试热点 | 浅谈 TCP/IP 传输层 TCP BBR 算法](https://mp.weixin.qq.com/s/3mojmiW8JPq1_3bnBu-_-w)

关于BIC与CUBIC的好文：[TCP拥塞控制算法-从BIC到CUBIC](https://blog.csdn.net/dog250/article/details/53013410)

关于BBR的好文（较深度，未仔细研读）：[来自Google的TCP BBR拥塞控制算法解析](https://blog.csdn.net/dog250/article/details/52830576)、[Google BBR拥塞控制算法背后的数学解释](https://blog.csdn.net/dog250/article/details/82892267)

拥塞控制不仅属于计算机网络，还属于**控制论**范畴，需要权衡与取舍

拥塞控制定义：是防止过多的数据注入网络，使得网络中的路由器或者链路过载。流量控制是点对点的通信量控制，而拥塞控制是全局的网络流量整体性的控制。发送双方都有一个拥塞窗口——cwnd。

AIMD：**线性增加乘性减少算法**是一个反馈控制算法，因其在TCP拥塞控制中的使用而广为人知，AIMD将线性增加拥塞窗口和拥塞时乘性减少窗口相结合，基于AIMD的多个连接理想状态下会达到**最终收敛**，共享相同数量的网络带宽，与其相关的乘性增乘性减MIMD策略和增性加增性减少AIAD都无法保证稳定性。

拥塞窗口cwnd：

1. Congestion Window (cwnd) is a TCP state variable that limits the amount of data the TCP can send into the network before receiving an ACK.
2. The Receiver Window (rwnd) is a variable that advertises the amount of data that the destination side can receive.
3. cwnd是在发送方维护的，cwnd和rwnd并不冲突，发送方需要结合rwnd和cwnd两个变量来发送数据，wnd_mind = min{rwnd, cwnd}

四个重要阶段（Tahoe之后，BBR之前）

1. 慢开始：最开始发送方的拥塞窗口为1，每经过一个传输伦次，cwnd加倍，当cwnd超过慢开始门限ssthresh，进入拥塞避免
2. 拥塞避免：每经过一个传输轮次，cwnd加1。一旦发现网络拥塞（超时），就把ssthresh降为原来的一半，从cwnd=1开始慢开始（加法增大乘法减小,AIMD）
3. 快重传：接收方每次收到一个失序的报文就立即发送重复确认，发送方收到三个重复确认就立即重传（不用考虑重传计时器RTO，所以是快重传）
4. 快恢复：与快重传配合，发送方收到三个重复确认后，就把ssthresh降为原来的一半，从cwnd=新ssthresh开始拥塞避免（不用慢开始，所以是快恢复），采用快恢复算法时，慢开始只在建立连接和网络超时才使用。

BBR是Google2016年开源的拥塞控制算法，已在Linux 4.9内核中支持

- 以前的拥塞控制算法（Reno、Cubic等）都是以**丢包**作为拥塞发生的信号（被动），而BBR以**网络中包数>带宽时延积**作为拥塞发生的信号（主动）
- 以前的拥塞控制算法只关注cwnd，而BBR还关注cwnd内的数据以多少的pacing rate发送出去（传统算法不关注pacing rate，可能会造成RTT抖动）
- 在**有一定丢包率**的网络链路上充分利用带宽。
- 降低网络链路上的buffer占用率，从而降低延迟。
- 因此，即使网络状况次优，BBR也能提供持续的高吞吐量

拥塞控制算法历史：

- 以前都是慢启动、拥塞避免、快重传、快恢复，如Tahoe（还未支持快恢复）、Reno、New Reno（改进了Reno的快重传）
- Vegas**基于RTT延时策略**进行拥塞控制，在发包速率上不够激进，竞争性不如其他算法，但是**曲线平衡**
- BIC通过二分搜索寻找最佳的拥塞窗口cwnd，在Linux2.6的版本中作为Linux默认拥塞控制算法
- CUBIC通过一个三次函数（包含凹与凸部分）来调整拥塞窗口大小，在BIC之后作为Linux默认拥塞控制算法
- PRR尝试将**恢复后的拥塞窗口大小尽可能接近慢启动阈值**，在Linux3.2之后作为默认拥塞控制算法
- 总之，以前的算法大多以丢包作为拥塞发生的信号。这是有道理的，因为以前的有线网络中丢包较少，所以把丢包作为网络拥堵的一个特征也很正常。但是无线网络中环境复杂，丢包不一定是由于网络拥塞，有可能是由于基础通信设备，所以**网络带宽的利用率**大大下降。而且，无线网络的时延可能很大，而拥塞窗口的大小根据传输轮次（也就是RTT，其中包括无线网络部分的时延）而改变，所以在慢开始阶段很长时间都是空闲的，所以发包的加速度大大降低，吞吐量下降明显。
- TCP Westwood改良自New Reno，不同于以往其他拥塞控制算法使用丢包来测量，其通过对确认包测量来确定一个合适的发送速度（主动），并以此调整拥塞窗口和慢启动阈值。其改良了慢启动阶段算法为敏捷探测和设计了一种持续探测拥塞窗口的方法来控制进入敏捷探测，使链接尽可能地使用更多的带宽。

### P2P

为什么p2p用udp/为什么p2p的tunnel用udp？（转自知乎车大）

- UDP隧道，所有底层封装都不对用户的数据进行控制，所有的控制都留给用户控制，这样可以给用
  户最大的灵活空间。.
  - 用户用UDP隧道来传输UDP报文，呈现的是UDP特征。
  - 用户用UDP隧道来传输TCP报文，呈现的是TCP特征。
- 如果用TCP隧道，底层的TCP封装会对用户数据进行控制，用户将失去了灵活的空间。
  - 用户用TCP隧道来传输UDP报文，呈现的是TCP特征。
  - 用户用TCP隧道来传输TCP报文，呈现的还是TCP特征。
- 如果用TCP，一旦发生丢包，不知道上层TCP丢还是下层TCP丢，TCP over TCP没有任何优点，还会导致网路不稳定

分布式哈希表（DHT）

[分布式哈希表(DHT)和P2P技术](https://luyuhuang.github.io/2020/03/06/dht-and-p2p.html)

在一个有n个节点的分布式哈希表中, 每个节点仅需存储O(logn)个其他节点, 查找资源时仅需请求O(logn)个节点, 并且无需中央服务器, 是一个完全自组织的系统.

### DNS/HTTP DNS

**DNS同时占用UDP和TCP端口53**，这种单个应用协议同时使用两种传输协议的情况在TCP/IP栈也算是个另类。

DNS在进行区域传输的时候使用TCP协议，其它时候（如常见的域名解析）则使用UDP协议

DNS的规范规定了2种类型的DNS服务器，一个叫主DNS服务器，一个叫辅助DNS服务器。在一个区中主DNS服务器从自己本机的数据文件中读取该区的DNS数据信息，而辅助DNS服务器则从区的主DNS服务器中读取该区的DNS数据信息。当一个辅助DNS服务器启动时，它需要与主DNS服务器通信，并加载数据信息，这就叫做**区传送（zone transfer）**

区域传送时使用TCP，主要有一下两点考虑：

1. 辅域名服务器会定时（一般时3小时）向主域名服务器进行查询以便了解数据是否有变动。如有变动，则会执行一次区域传送，进行数据同步。区域传送将使用TCP而不是UDP，因为数据同步传送的数据量比一个请求和应答的数据量要多得多。
2. TCP是一种可靠的连接，保证了数据的准确性。

域名解析携带的数据很少，用UDP更快

HTTPDNS 利用 HTTP 协议与 DNS 服务器交互，代替了传统的基于 UDP 协议的 DNS 交互，绕开了运营商的 Local DNS，有效**防止域名劫持**，提高域名解析效率。另外，由于 DNS 服务器端获取的是真实客户端 IP 而非 Local DNS 的 IP，能够精确定位客户端地理位置、运营商信息，从而有效改进调度精确性。

HttpDns 主要解决的问题

- Local DNS 劫持：由于 HttpDns 是通过 IP 直接请求 HTTP 获取服务器 A 记录地址，不存在向本地运营商询问 domain 解析过程，所以从根本避免了劫持问题。
- 平均访问延迟下降：由于是 IP 直接访问省掉了一次 domain 解析过程，通过智能算法排序后找到最快节点进行访问。
- 用户连接失败率下降：通过算法降低以往失败率过高的服务器排序，通过时间近期访问过的数据提高服务器排序，通过历史访问成功记录提高服务器排序。

### SSH/如何免密登录远程服务器

SSH（Secure Shell）是一种通信加密协议，加密算法包括：RSA、DSA等。

在本地用ssh-keygen生成公钥和私钥，公钥发给远程服务器存储，以后通信就

1. 在A上生成公钥私钥。
2. 将公钥拷贝给server B，要重命名成authorized_keys(从英文名就知道含义了)
3. Server A向Server B发送一个连接请求。
4. Server B得到Server A的信息后，在authorized_key中查找，如果有相应的用户名和IP，则随机生成一个字符串，并用Server A的公钥加密，发送给Server A。
5. Server A得到Server B发来的消息后，使用私钥进行解密，然后将解密后的字符串发送给Server B。Server B进行和生成的对比，如果一致，则允许免密登录。

### 四层负载均衡/七层负载均衡

- 二层负载均衡：负载均衡服务器对外依然提供一个VIP（虚IP），集群中**不同的机器采用相同的IP地址**，但是机器的**MAC地址不一样**。当负载均衡服务器接受到请求之后，通过改写报文的目标MAC地址的方式将请求转发到目标机器实现负载均衡。
- 三层负载均衡：负载均衡服务器对外依然提供一个VIP（虚IP），集群中**不同的机器采用不同的IP地址**，当负载均衡服务器接受到请求之后，根据不同的负载均衡算法，通过IP将请求转发至不同的真实服务器。
- 四层负载均衡：四层负载均衡工作在OSI模型的**传输层**，由于在传输层，只有TCP/UDP协议，这两种协议中除了包含源IP、目标IP以外，还包含源端口号及目的端口号。四层负载均衡服务器在接受到客户端请求后，以后通过修改数据包的地址信息（IP+端口号）将流量转发到应用服务器。
- 七层负载均衡：七层负载均衡工作在OSI模型的**应用层**，可根据七层的URL、浏览器类别、语言来决定是否要进行负载均衡。 

### HTTP代理服务器的分类与工作原理

在HTTP通信链上，客户端和目标服务器之间通常存在某些中转代理服务器，它们提供对目标资源的**中转访问**。一个HTTP请求可能被多个代理服务器转发，后面的服务器称为前面服务器的上游服务器。代理服务器按照其使用方式和作用，分为正向代理服务器、反向代理服务器和透明代理服务器。

- **正向代理要求客户端自己设置代理服务器的地址**。客户的每次请求都将直接发送到该代理服务器，并由代理服务器来请求目标资源。比如处于防火墙内的局域网机器要访问Internet，或者要访问一些被屏蔽掉的国外网站，就需要使用正向代理服务器。例如shadowsocks

- **反向代理则被设置在服务器端**，因而客户端无须进行任何设置。反向代理是指用代理服务器来接收Internet上的连接请求，然后将请求转发给内部网络上的服务器，并将从内部服务器上得到的结果返回给客户端。这种情况下，代理服务器对外就表现为一个真实的服务器。各大网站一般设了多个代理服务器。

- 透明代理只能设置在网关上。用户访问Internet的数据报必然都经过网关，如果在网关上设置代理，则该代理对用户来说显然是透明的。透明代理可以看作正向代理的一种特殊情况。

### HTTP

#### HTTPS、SSL/TLS握手过程

HTTPS = HTTP over TLS

1. HTTP协议是以明文的方式在网络中传输数据，而HTTPS协议传输的数据则是经过**TLS加密**后的，HTTPS具有更高的安全性
2. HTTPS在TCP三次握手阶段之后，还需要进行**TLS**的handshake，协商加密使用的对称加密密钥
3. HTTPS协议需要服务端申请**证书**，浏览器端**安装**对应的根证书
4. HTTP协议端口是80，HTTPS协议端口是443

HTTPS缺点：

1. 握手时延增加：TLS握手才能HTTP会话
2. 部署成本高：需要购买CA证书；加解密计算消耗资源

TLS（Transportation Layer Security，安全传输层）的**前身**是SSL（Secure Socket Layer，安全套接层）

TLS握手过程

1. client发送hello，包括TLS版本号、client产生的随机数random1、加密方法（如RSA公钥加密）
2. server发送hello，包括TLS版本号、server产生的随机数random2、certificate（证书）、确认的加密方法（如RSA公钥加密）
3. client验证证书是否合法，然后计算**pre-master secret（预主秘钥）**，通过公钥加密后发送
4. server通过私钥解密预主秘钥，然后根据random1、random2以及预主秘钥计算生成本次会话用的“会话秘钥”
5. 至此，client和server都知道了会话秘钥，可以安全的通信了

为什么需要三次：不信任每个主机都能产生随机数，如果随机数不随机，预主秘钥就有可能被猜出，所以三个随机数一起计算，更随机

#### HTTP/1.0、HTTP/1.1、HTTP/2.0、HTTP/3

HTTP/1.0：

1. 每个TCP链接只能发送一个请求
2. 无状态、无连接的

HTTP/1.1的改进：

1. 缓存处理更多，通过头部字段Cache-Control
2. 减少带宽，客户端先询问服务器端能否接收大实体
3. 关于错误的状态码更多
4. **支持长连接**，Connection字段设置keep-alive值
5. 缺点：存在队头阻塞的问题

HTTP/2.0做了更多的改进：

1. 二进制分帧协议：数据分解为更小的帧，如同高速公路上川流不息的车辆，而1.x是文本协议
2. **完全多路复用**：不是有序并阻塞的，基于二进制分帧，能够将多条请求在同一条TCP连接上同时发送，`一条TCP链接 包含 双向数据流 包含 消息 包含 帧`
3. **header压缩**：因为HTTP协议无状态，header的很多字段重复发送了，HTTP2.0使用HPACK算法来减少传输的header的大小，HPACK算法是双方共同维护一个头部表，增量更新即可
4. 服务器端推送，服务器可主动向客户发送资源
5. 用了TLS，更加安全
6. 缺点：还是存在队头阻塞。多个HTTP请求在复用一个TCP连接，下层的TCP协议是不知道有多少HTTP请求的。所以一旦发生了丢包现象，就会触发TCP的重传机制，这样在一个TCP连接中的所有的HTTP请求都必须等待这个丢了的包被重传回来。

SPDY与HTTP2.0相互促进：

SPDY是Google开发的**基于TCP的会话层协议**，用以最小化网络延迟，提升网络速度，优化用户的网络使用体验。SPDY并不是一种用于替代HTTP的协议，而是对HTTP协议的增强。

HTTP/3使用的传输层协议是Quic协议，而非TCP协议，具体介绍见下文

#### HTTP请求头部的常见字段

cache-control : no-cache no-store max-age
connection: keep-alive close 是否开启长连接
if-modified-since：与304状态码结合使用
Refer：从哪个页面跳转的
User-agent：向服务器发送浏览器的版本、系统、应用程序的信息。

#### HTTP为什么是无状态的

- 无状态是指协议对于事务处理没有记忆能力，服务器不知道客户端是什么状态。即我们给服务器发送 HTTP 请求之后，服务器根据请求，会给我们发送数据过来，但是，发送完，不会记录任何信息。
- HTTP 是一个无状态协议，这意味着每个请求都是独立的，Keep-Alive 没能改变这个结果。
- 缺少状态意味着如果后续处理需要前面的信息，则它必须重传，这样可能导致每次连接传送的数据量增大。另一方面，在服务器不需要先前信息时它的应答就较快。
- HTTP 协议这种特性有优点也有缺点，优点在于解放了服务器，每一次请求“点到为止”不会造成不必要连接占用，缺点在于每次请求会传输大量重复的内容信息。
- 所以有Cookie和Session机制，用来保存HTTP连接状态的一些信息

#### HTTP长连接与短连接的区别

短连接：即浏览器和服务器每进行一次HTTP操作，就会建立一次连接，任务结束就断开连接。通常用于大型网站的访问。

长连接：用以保持连接特性（加上keep-alive）。使用长连接的情况下，当某个网页打开完毕之后，客户端和服务器之间的TCP连接不会立即关闭，如果客户端再次访问该服务器上的网页，会使用上一次已经建立的连接。长连接不是永久保持连接，它有一个保持时间。实现长连接的前提是客户端和服务器端都需要支持长连接。通常用于**操作频繁**，点对点的通信，且**连接数不太多**的情况。如数据库的连接使用长连接

#### 为什么QQ用的是UDP协议而不是TCP协议

其实QQ里既有UDP也有TCP，UDP用来发送消息，TCP连接用来保持在线状态

UDP协议是无连接方式的协议，它的效率高，速度快，占资源少，但是其传输机制为不可靠传送，必须依靠辅助的算法来完成传输控制。QQ采用的通信协议以UDP为主，辅以TCP协议。由于QQ的服务器设计容量是海量级的应用，一台服务器要同时容纳十几万的并发连接，因此服务器端只有采用UDP协议与客户端进行通讯才能保证这种超大规模的服务。

QQ客户端之间的消息传送也采用了UDP模式，因为国内的网络环境非常复杂，而且很多用户采用的方式是通过代理服务器共享一条线路上网的方式，在这些复杂的情况下，客户端之间能彼此建立起来TCP连接的概率较小，严重影响传送信息的效率。而UDP包能够穿透大部分的代理服务器，因此QQ选择了UDP作为客户之间的主要通信协议。

UDP是不可靠的，所以需要上层协议来保证可靠传输：如果客户端使用UDP协议发出消息后，服务器收到该包，需要使用UDP协议发回一个应答包。如此来保证消息可以无遗漏传输。之所以会发生在客户端明明看到“消息发送失败”但对方又收到了这个消息的情况，就是因为客户端发出的消息服务器已经收到并转发成功，但客户端由于网络原因没有收到服务器的应答包引起的。

最本质上UDP的优势还是带宽的利用

#### HTTP状态码

HTTP协议的响应报文由状态行、响应头和响应体组成，其响应状态码总体描述如下：

1. 1xx：指示信息--表示请求已接收，继续处理。
2. 2xx：成功--表示请求已被成功接收、理解、接受。
    - 200 OK：客户端请求成功。
    - 204 No Content：表示请求已成功处理，但是没有内容返回
3. 3xx：重定向--要完成请求必须进行更进一步的操作。
    - 301 Moved Permanently：永久重定向，表示请求的资源已经永久的搬到了其他位置
    - 302 Moved Temporarily：该资源原本确实存在，但已经被临时改变了位置
    - 303 See Other：由于请求对应的资源存在着另一个URI，应使用GET方法定向获取请求的资源
4. 4xx：客户端错误--请求有语法错误或请求无法实现。
    - 400 Bad Request ：请求报文中存在语法错误，服务器不理解
    - 401 Unauthorized：发送的请求需要有HTTP认证信息或者是认证失败了
    - 403 Forbidden：服务器收到请求，但是拒绝提供服务。
    - 404 not Found：请求资源不存在
5. 5xx：服务器端错误--服务器未能实现合法的请求。
    - 500 Inter Server Error：服务器在执行请求时发生了错误，可能是服务器有bug
    - 502 Bad Gateway：错误网关，无效网关；在互联网中表示一种网络错误。
    - 503 Server Unavailable：服务器暂时处于超负载或正在进行停机维护，无法处理请求；

### Quic与BBR（都是Google提出的）

Quic（Quick UDP Internet Connection）是**基于UDP**实现的支持**多路并发传输**的协议，Quic相比于广泛应用**HTTP2+TCP+TLS**有以下优势：

- 减少握手时间
  - TCP三次握手（1个RTT时间，第三次握手可以携带数据）与TLS握手时间（TLS1.3之前都是2个RTT时间，TLS1.3只需要0个RTT，但还未普及），虽然有TCP fast open，但是它需要端到端的操作系统协议栈，还未普及
  - QUIC：在客户端保存配置信息的前提下可以实现**0RTT**，牵涉到一些DH算法的细节
- QUIC在用户空间实现，TCP是在内核实现的，所以改善了拥塞控制
  - TCP的拥塞控制需要端到端的网络协议栈的支持，部署和升级成本太高
  - QUIC支持**可插拔**，在应用程序层面就能实现不同的拥塞控制算法，不需要操作系统支持
  - QUIC默认使用了Cubic，还支持其他的拥塞控制算法如Reno、BBR
  - **单调递增的Packet Number**，解决了TCP的Sequence Number重传后的seq一样产生的歧义问题，这会导致RTO采样不准
- **避免队头阻塞的多路复用**：
  - HTTP/2的多路复用允许一条TCP连接发送多个请求（或Stream），而TCP不直到上层是用HTTP协议，TCP只会根据序列号顺序处理，所以有队头阻塞的问题
  - HTTP强制使用的TLS按照record处理数据，必须通过数据一致性校验才能加解密，也有队头阻塞的问题
  - QUIC是通过packet传输的，不会超过MTU，加密和认证过程都是基于Packet的，不会跨越多个Packet，所以没有队头阻塞
  - QUIC各Stream之间独立，所以没有队头阻塞
- 流量控制
  - TCP用seq/ack机制还有滑动窗口协议
  - UDP没有流量控制，由于QUIC的多路复用机制（多条请求共用一个QUIC连接），其流量控制分为Stream和Connection两种级别的控制。这里Connection就是QUIC握手后建立的连接，Stream可以理解为链路上的请求。
- 连接迁移
  - TCP通过`(源IP、源端口、目的IP、目的端口)`的四元组唯一表示一条TCP连接，因为客户端的IP可能会变化（WiFi到4G），所以很难迁移
  - QUIC通过一个由客户端生成的**64位随机数**来标识QUIC连接，冲突概率非常低
- 前向冗余纠错
  - 在重要的包比如握手消息发生丢失时，能够根据冗余信息**还原**出握手消息。

腾讯的安全云、黄钻业务、手机QQ会员业务，阿里的AliQUIC

### TCP KeepAlive与HTTP的Keep-Alive

- 在HTTP/1.0中，默认使用的是短连接。也就是说，浏览器和服务器每进行一次HTTP操作，就建立一次连接，但任务结束就中断连接;但从 HTTP/1.1起，默认使用长连接，用以保持连接特性。使用长连接的HTTP协议，会在响应头加上Connection:Keep-Alive字段。
- HTTP的Keep-Alive是为了让TCP连接活得更久一点，在发起多个http请求时能复用同一个连接，提高通信效率；
- TCP的KeepAlive机制意图在于探测连接的对端是否存活，是一种检测TCP连接状况的保鲜机制。

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
2. 浏览器先解析URL得到域名，组装header生成HTTP请求，然后通过域名找IP地址，这需要域名解析系统**DNS**，DNS是基于UDP的，首先会查浏览器的DNS缓存，然后查本机的DNS缓存(hosts文件），再然后查ISP域名服务器，这里的查询方式分为**迭代查询**和**递归查询**，迭代：ISP域名服务器--根域名服务器--ISP域名服务器--顶级域名服务器--权威域名服务器，递归：ISP域名服务器--根域名服务器--顶级域名服务器--权威域名服务器
3. 本机（客户端）得到IP后，向IP所在的HTTP服务器发起TCP连接（TCP三次握手），然后生成一个**GET请求报文**，交给TCP层处理，如果是HTTPS还需要**TLS加密**，传输层可能会根据MSS对报文**分片**，然后到达IP层，数据链路层和物理层
4. 通过网络中的路由器，牵涉到OSPF、BGP协议等等，最终IP数据包到达服务器，服务器重组数据包，恢复成原GET请求报文
5. 服务器收到GET请求，把本地的HTML返回给客户端
6. 客户端的浏览器得到HTML文档，**解析**CSS、Javascript文件，**渲染**在浏览器上
7. 连接断开，TCP四次挥手

### RDMA

- 远程直接内存访问(即RDMA)是一种直接内存访问技术，它将数据直接从一台计算机的内存传输到另一台计算机，无需双方操作系统的介入
- 传统的 TCP/IP 软硬件架构及应用存在着网络传输和数据处理的延迟过大、存在多次数据拷贝和中断处理、复杂的 TCP/IP 协议处理等问题。RDMA(Remote Direct Memory Access，远程直接内存访问)是一种为了解决网络传输中服务器端数据处理延迟而产生的技术。
- RDMA 无需操作系统和 TCP/IP 协议的介入，可以轻易的实现超低延时的数据处理、超高吞吐量传输，不需要远程节点 CPU 等资源的介入，不必因为数据的处理和迁移耗费过多的资源。

## 数据库

### 局部性原理

计算机科学中著名的局部性原理: 当一个数据被用到时, 其附近的数据也通常会马上被使用。

程序运行期间所需要的数据通常比较集中。由于磁盘顺序读取的效率很高(不需要寻道时间, 只需很少的旋转时间），因此对于具有局部性的程序来说, 预读可以提高I/O效率。

而类似于B+树这样的结构，可以明显减少磁盘IO，一次读一块区域的内容，所以一般用B+树作为数据库索引

### 三范式

- 第一范式（1NF）：列的原子性，列不能再分成其他几列

    考虑这样一个表：`【联系人】（姓名, 性别, 电话）`。如果在实际场景中, 一个联系人有家庭电话和公司电话, 那么这种表结构设计就没有达到 1NF。要符合 1NF 我们只需把列(电话)拆分, 即：`【联系人】（姓名, 性别, 家庭电话, 公司电话）`。

- 第二范式：当存在多个主键时，不能有某个非关键字段**部分依赖**于某个主键。第二范式就是在第一范式的基础上属性完全依赖于主键。

    考虑一个订单明细表：`【OrderDetail】（OrderID, ProductID, UnitPrice, Discount, Quantity, ProductName）`。

    因为我们知道在一个订单中可以订购多种产品, 所以单单一个 OrderID 是不足以成为主键的, 主键应该是`(OrderID, ProductID）`。显而易见 Discount(折扣），Quantity(数量)完全依赖(取决)于主键(OderID, ProductID），而 UnitPrice, ProductName 只依赖于 ProductID. 所以 OrderDetail 表不符合 2NF. 不符合 2NF 的设计容易产生冗余数据。 可以把【OrderDetail】表拆分为`【OrderDetail】（OrderID, ProductID, Discount, Quantity)`和`【Product】（ProductID, UnitPrice, ProductName)`来消除原订单表中UnitPrice, ProductName多次重复的情况。

- 第三范式：非主键列必须**直接依赖**于主键，**不能存在传递依赖**，是第二范式的子集。

    考虑一个订单表`【Order】(OrderID, OrderDate, CustomerID, CustomerName, CustomerAddr, CustomerCity)`主键是(OrderID)

    其中OrderDate, CustomerID, CustomerName, CustomerAddr, CustomerCity等非主键列都完全依赖于主键(OrderID），所以符合 2NF. 不过问题是 CustomerName, CustomerAddr, CustomerCity 直接依赖的是 CustomerID(非主键列），而不是直接依赖于主键, 它是通过传递才依赖于主键, 所以不符合3NF。

    通过拆分【Order】为`【Order】（OrderID, OrderDate, CustomerID)`和`【Customer】（CustomerID, CustomerName, CustomerAddr, CustomerCity)`从而达到 3NF。

### UNION/JOIN

UNION与UNION ALL的区别：

- UNION操作符用于合并两个或多个 SELECT语句的结果集，会筛选掉重复的记录
- 如果允许重复的值，使用UNION ALL，效率高于UNION
- 注意，UNION 内部的 SELECT 语句必须拥有相同数量的列。列也必须拥有相似的数据类型。同时，每条 SELECT 语句中的列的顺序必须相同。

JOIN的分类：

- 有时为了得到完整的结果，我们需要从两个或更多的表中获取结果。我们就需要执行 JOIN
- INNER（默认可省略） JOIN: 如果表中有至少一个匹配，则返回行（INNER JOIN 与 JOIN），取两个表的交集
- LEFT JOIN: 即使右表中没有匹配，也从左表返回所有的行，产生左表的完全集，右表没有的用null代替
- RIGHT JOIN: 即使左表中没有匹配，也从右表返回所有的行，产生右表的完全集，左表没有的用null代替
- FULL JOIN: 只要其中一个表中存在匹配，就返回行，取两个表的并集（MySQL不支持，可以使用UNION ALL模拟）
- CROSS JOIN：产生笛卡尔积，若左表M条记录而右表N条记录，则结果有M*N条记录

![C++查漏补缺-20200112152804.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/C%2B%2B%E6%9F%A5%E6%BC%8F%E8%A1%A5%E7%BC%BA-20200112152804.png)

### MySQL基础

#### 端口号

MySQL的端口号是多少，如何修改这个端口号

端口号3306，修改`my.cnf`（Linux）or `my.ini`（Windows）

#### 字符集与字符序

字符集(character set)：给定一系列字符并赋予对应的编码后，所有这些“字符和编码对”组成的集合就是字符集。如latin1、utf8、gbk、big5等

字符序(collation)：在同一字符集内字符之间的比较规则，每个字符序唯一对应一种字符集。以字符集开头，中间是国家名，结尾是cs或ci或bin，cs是大小写敏感的意思，ci是大小写不敏感，bin是二进制编码。例如，latin1字符集有latin1_swedish_ci、 latin1_general_cs、latin1_bin等字符序，其中在字符序latin1_swedish_ci 规则中，字符'a'和'A'是等价的。

- 一个字节可以表示所有latin1字符（西欧、希腊字符）
- 两个字节可以表示所有gbk字符（包括中文简体（
- 三个字节可以表示所有utf字符（几乎涵盖了世界上所有国家的所有字符）

#### 数据类型

- 数值类型：整数类型（tinyint、smallint、mediumint、int和 bigint）+小数类型（精确or浮点）
  - 精确小数（小数点位数确定）
  - 浮点数类型（小数点位数不确定），浮点数又分为单精度（float）or双精度（double）
  - 默认有符号，可以用unsigned指定无符号，取值必须为0或正数
- 字符串类型：固定长度+可变长度（varchar or text）
  - 对于固定长度char(255)，里面无论存多少，都占255个字符长度的存储空间（具体字节数取决于字符集），对于可变长度varchar(255)，根据实际存储的字符来计算存储空间
  - char(n)的n最大值为255，可变长度的最大n值与字符集有关
- 日期类型：以下5种，日期也可以参与简单的算术运算
  - date：YYYY-MM-DD
  - time：HH:ii:ss
  - year：YYYY
  - datetime：YYYY-MM-DD HH:ii:ss，取值范围远远大于timestamp
  - timestamp：YYYY-MM-DD，HH:ii:ss
    - 将NULL插入timestamp字段后，该字段的值实际上是MySQL服务器当前的日期和时间
    - 对于同一个timestamp类型的日期或时间，不同的**时区**显示结果不同
    - 当对**包含timestamp数据的记录**进行修改时，该timestamp会自动更新为MySQL服务器当前的日期与事件
- 符合类型：enum类型+set类型
  - enum：只允许从一个集合中取得某一个值
  - set：允许从一个集合中取得多个值
  - 使用复合数据类型可以实现简单的**字符串类型数据的检查约束**。
- 二进制类型：binary、varbinary、bit、 tinyblob、blob、mediumblob和longblob
  - 二进制类型的数据是一种特殊格式的字符串
  - 字符串类型的数据**按字符为单位**进行存储，因此存在多种字符集、多种字符序
  - 除了bit数据类型按位为单位进行存储，其他二进制类型的数据**按字节为单位**进行存储，仅存在二进制字符集binary

特殊的字符

```sql
`\"` --转义后代表双引号"
`\'` --单引号'
`\\` --反斜线\
`\n` --换行符
`\r` --回车符
`\t` --制表符
`\0` --ASCII 0（NUL)
`\b` --退格符
`\_` --转义后代表下划线_
`\%` --转义后代表百分号%
```

- NULL与空字符串是两个不同的概念。
- NULL与整数零以及空格字符`' '`的概念也不相同。
- NULL与NUL（`\0`）不同
  - `\0`可以与数值进行算术运算，此时当做整数0处理
  - '\0`可以与其他字符串拼接，此时当做空字符串处理
  - NULL与其他数据运算时，结果永远为NULL

变量分为系统变量(以@@开头)以及用户自定义变量。

- 系统变量分为**会话系统变量**（或称为local变量、系统会话变量）以及**全局系统变量**（或称为全局变量），静态变量属于特殊的全局系统变量。
- 用户自定义变量分为**用户会话变量**(以@开头)以及**局部变量**(不以@开头)
  - 用户会话变量名以“@”开头，而局部变量名前面没有“@”符 号。
  - 局部变量使用declare命令定义(存储过程参数、函数参数除 外)，定义时必须指定局部变量的数据类型。局部变量定义后，才可以使用set命令或者select语句为其赋值。
  - 用户会话变量的作用范围与生存周期大于局部变量。局部变量仅在当前begin-end语句块内有效。

#### 内置数据库

MySQL内置的几个数据库，可以用命令查看

```shell
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| test               |
+--------------------+
4 rows in set (0.00 sec)
```

- information_schema数据库存储了所有数据库的**元数据**。元数据是关于数据的数据，如数据库名或表名，列的数据类型，或访问权限等。
- mysql：这个是mysql的核心数据库，存储数据库的用户、权限设置、关键字等。不可以删除。
- performance_schema：主要用于收集数据库服务器性能参数。提供进程等待的详细信息，包括锁、互斥变量、文件信息。
- test：没有任何东西，没有任何表，可以删除。

#### 基础命令

在进行数据库操作前，**必须指定操作的是哪个数据库**。在 MySQL 命令提示符窗口中，使用SQL语句`use database_name;`

删除名为database_name的数据库：`drop database database_name;`

修改当前数据库默认存储引擎：`set default_storage_engine=InnoDB;`

创建表：`create table my_table(today datetime, name char(20));`

快速创建一个类似表：`create table new_table like old_table;`

查看当前数据库的所有表：`show tables;`

查看某个表（详细描述）：`desc my_table;`

删除表字段：`alter table 表名 drop 字段名;`

添加新字段（通常需要指定新字段在表中的位置）：`alter table 表名 add 新字段名 数据类型 [约束条件] [ first | after旧字段名];`

修改表的字段名及数据类型：`alter table 表名 change 旧字段名 新字段名 数据类型;`

修改数据类型：`alter table 表名 modify 字段名 数据类型;`

添加约束条件给某字段(约束类型为唯一性约束、主键约束、外键约束等，表的已有记录需要满足新约束条件的要求，否则会报错)：`alter table 表名 add constraint 自定义的约束名 约束类型 (字段名);`

删除约束条件：`alter table 表名 drop 约束类型;`

删除索引：`drop index 索引名 on 表名;`

修改表名：`rename table 旧表名 to 新表名;`，或者，`alter table 旧表名 rename 新表名;`

删除名为table_name的表（但要注意外键约束，必须先删除父子之间的外键约束再删除父表）：`drop table table_name;`

#### MySQL编程

begin-end语句块

- 为了完成某个功能，多条MySQL表达式密不可分，可以使用“begin”和“end;”将这些表达式包含起来形成语句块，语句块中表达式之间使用“;”隔开，一个begin-end语句块可以包含新的begin-end语句块。
- 在每一个begin-end语句块中声明的局部变量，仅在当前的begin-end
语句块内有效
- 允许在一个begin-end语句块内使用leave语句跳出该语句块

```sql
[开始标签:] begin
[局部]变量的声明; 错误触发条件的声明;   /*在MySQL存储过程与游标章节中
进行详细讲解*/
游标的声明;    /*在MySQL存储过程与游标章节中进行详 细讲解*/
错误处理程序的声明;   /*在MySQL存储过程与游标章节中 进行详细讲解*/
业务逻辑代码;
end[结束标签];
```

重置命令结束标记

- 由于 begin-end 语句块中的多条 MySQL 表达式密不可分，为了避免这些MySQL表达式被拆开，需要重置MySQL客户机的命令结束标记 (delimiter)。

```sql
delimiter $$
select * from student where student_name like '张_'$$

delimiter ;
select * from student where student_name like '张_';
```

条件控制与循环语句

```sql
-- if语句
if 条件表达式1 then 语句块1;
[elseif 条件表达式2 then 语句块2]
...
[else 语句块n]
end if;

-- case语句
case 表达式
when value1 then 语句块1;
when value2 then 语句块2;
when value3 then 语句块3;
...
else语句块n;
end case;

-- while语句：当条件表达式的值为true时，反复执行循环体，直到条件表达式的 值为false
[循环标签:]while 条件表达式 do
循环体;
end while [循环标签];

-- leave语句：用于跳出当前的循环语句(例如while语句)，类似C++的break
leave 循环标签;

-- iterate语句：用于跳出本次循环，继而进行下次循环，类似C++的continue
iterate 循环标签;

-- repeat语句：当条件表达式的值为false时，反复执行循环，直到条件表达式的值为true
[循环标签:]repeat
循环体;
until 条件表达式
end repeat [循环标签];

-- loop语句：本身没有停止循环的语句，因此loop通常借助leave语句跳出loop循环
[循环标签:] loop 循环体;
if 条件表达式 then
    leave [循环标签];
end if;
end loop;
```

自定义函数

- 自定义函数是数据库的对象，因此，创建自定义函数时，需要指定该自定义函数隶属于哪个数据库。
- 同一个数据库内，自定义函数名不能与已有的函数名(包括系统函数名)重名。建议在自定义函数名中统一添加前缀“fn_”或者后 缀“_fn”。
- 函数的参数无需使用declare命令定义，但它仍然是**局部变量**，且必须提供参数的数据类型。自定义函数如果没有参数，则使用空参数“()”即可。
- 函数必须指定返回值数据类型，且须与return语句中的返回值的数 据类型相近(长度可以不同)。
- 函数选项可以指定该函数是否使用了SQL读或写、调用者的权限、注释等
- 由于函数保存的仅仅是函数体，而函数体实际上是一些MySQL表达式，因此函数自身不保存任何用户数据
- 当函数的函数体需要更改时，可以使用`drop function func_name;`语句暂时将函数的定义删除，然后使用 create function 语句重新创建相同名字的函数即可。这种方法对于存储过程、视图、触发器的修改同样适用。

```sql
create function 函数名(参数1，参数2，...)returns返回值的数据类
型
[函数选项]
begin 函数体; return语句; end;
```

比如下面的自定义函数为查询结果集添加行号：

```sql
delimiter $$
create function row_no_fn() returns int no sql
begin
set @row_no = @row_no + 1;

return @row_no; end;
$$
delimiter ;

-- row_no_fn()函数体内定义了一个用户会话变量@row_no，该变量在本次MySQL服务器的连接一直生效，从而实现会话期间的累加功能。

set @row_no=0;
select row_no_fn() 行号,student_no,student_name from student;
```

比如下面的自定义函数根据学生学号返回该生选修了几门课程：

```sql
delimiter $$
create function get_choose_number_fn(student_no1 int) returns int reads sql data
begin
declare choose_number int;
select count(*) into choose_number from choose where student_no=student_no1;
return choose_number; end;
$$
delimiter ;

-- 自定义函数的函数体使用select语句时，该select语句不能产生结果集（所以要用select ... into ...)，否则将产生编译错误。

select get_choose_number_fn('2012001');
```

#### 视图

- 视图也是由若干个字段以及若干条记录构成的，它也可以作为select语句的数据源。
- 视图中的数据并不像表、索引那样需要占用存储空间，**视图中保存的仅仅是一条select语句**，其源数据都来自于数据库表，数据库表称为基本表或者基表，视图称为**虚表**。
- 基表的数据发生变化时，虚表的数据也会随之变化。
- 视图是数据库的对象，因此创建视图时，需要指定该视图隶属于哪个数据库。
- 对于经常使用的结构复杂的select语句，建议将其**封装**为视图。
- 优点：操作简单、避免数据冗余、增强安全性、提高数据的逻辑独立性
- MySQL将视图分为普通视图（不可修改数据表）与检查视图（可修改数据表），其中检查视图又分为local视图（满足了视图检查条件的更新语句才能执行）与级联视图（在视图的基础上再创建另一个视图，只有满足针对该视图的所有视图的检查条件的更新语句才能执行）

```sql
-- 根据select语句创建视图
create view 视图名[ (视图字段列表) ]
as
select 语句；


-- 视图作为select的数据源
select * from available_course_view;

-- 删除视图
drop view 视图名；
```

#### 触发器

- 触发器定义了一系列操作，这一系列操作称为触发程序，当触发事件发生时，触发程序会自动运行。
- 触发器用于监视某个表的insert、update以及delete等更新操作，这些操作可以分别激活该表的insert、update或者delete类型的触发程序运行
- 触发器是数据库的对象，因此创建触发器时，需要指定该触发器隶属于哪个数据库。
- 触发器基于表(严格地说是基于表的记录)，这里的表是基表，不是临时表(temporary)，也不是视图。
- 触发器的触发时间有两种：before（在触发事件发生之前执行触发程序）与after（在触发事件发生之后执行触发程序）。严格意义上讲，一个数据库表最多有6种类型的触发器，建议命名：`表名 _insert_before_trigger`(或者`表名_before_insert_trigger`)
- MySQL仅支持行级触发器，不支持语句级别的触发器，所以`for each row`表示更新操作影响每一条记录都会执行一次触发程序
- InnoDB支持**外键约束**，所以通过级联删除选项直接做到**级联删除**，但MyISAM不支持，但可以通过触发器间接实现级联删除
- InnoDB支持**事务**，所以可以保证更新操作与触发程序的原子性，只需要把更新操作与触发程序放在同一个事务中完成即可。
- 触发程序中可以使用old关键字与new关键字
  - 当向表插入新记录时，在触发程序中可以使用 new 关键字表示新记录。当需要访问新记录的某个字段值时，可以使用“new.字段名”的方式访问。
  - 当从表中删除某条旧记录时，在触发程序中可以使用old关键字表示旧记录。当需要访问旧记录的某个字段值时，可以使用“old.字段名”的方式访问。
  - 当修改表的某条记录时，在触发程序中可以使用old关键字表示修改前的旧记录，使用new关键字表示修改后的新记录。当需要访问旧记录的某个字段值时，可以使用“old.字段名”的方式访问。当需要访问修改后的新记录的某个字段值时，可以使用“new.字段名”的方式访问。
  - old记录是只读的，可以引用它，但不能更改它。在before触发程序中，可使用“set new.col_name = value”更改new记录的值。但在after触发程序中，不能使用“set new.col_name = value”更改new记录的值。

```sql
-- 添加触发器
create trigger 触发器名 触发时间 触发事件 on 表名 for each row
begin
触发程序
end;

-- 删除触发器
drop trigger organization_delete_before_trigger;

-- 修改触发器：由于触发器保存的是一条触发程序，没有保存用户数据，当触发器 的触发程序需要修改时，可以使用drop trigger语句暂时将该触发器删除，然后使用create trigger语句重新创建触发器即可。
```

#### 临时表

- 当“主查询”中包含派生表，或者当select语句中包含union子句，或 者当select语句中包含对一个字段的order by子句(对另一个字段的group by子句)时，MySQL 为了完成查询，则需要自动创建临时表存储临时结果集，这种临时表由MySQL自行创建、自行维护，称为**自动创建的临时表**
- 由于内存临时表的性能更为优越，MySQL 总是首先使用内存临时表，而当内存临时表变得太大，达到某个阈值的时候，内存临时表被转存为外存临时表
- 手动创建临时表时，临时表与基表的使用方法基本上没有区别，它们之间的不同之处在于，临时表的生命周期类似于会话变量的生命周期，临时表**仅在当前MySQL会话中生效**
- 临时表是数据库的对象，因此创建临时表时，需要指定该临时表隶属于哪个数据库。

```sql
create temporary table temp(name char(100));

drop temporary table 临时表表名;

insert into temp values('test');

select * from temp;
```

#### 派生表

- 派生表类似于临时表，但与临时表相比，派生表的性能更优越。派生表与视图一样，一般在from子句中使用。
- 而派生表的生命周期仅在本次select语句执行 的过程中有效，本次select语句执行结束，派生表立即清除
- 派生表必须是一个有效的表。每个派生表必须有自己的表名。派生表中的所有字段必须要有名称，字段名必须唯一。

```sql
....from (select 子句) 派生表名....

-- 教师teacher表中password字段的初始化，派生表u
update teacher s set s.password =( select md5(u.teacher_no)
from
(select teacher_no from teacher) u where s.teacher_no=u.teacher_no
);
```

#### 存储过程与函数的比较

相同：

- 应用程序调用存储过程或者函数时，只需要提供存储过程名或者函数名，以及参数信息，不需要若干SQL命令，节省了网络开销
- 存储过程或者函数可以重复使用
- 使用存储过程或者函数可以增强数据的安全访问控制

不同：

- **函数必须有且仅有一个返回值**，且必须指定返回值的数据类型 (返回值的类型目前仅仅支持字符串、数值类型)。存储过程可以没有返回值，也可以有返回值，甚至可以有多个返回值，所有的返回值需要 使用out或者inout参数定义。
- 在函数体内可以使用select...into语句为某个变量赋值，但不能使用select语句返回结果(或者结果集);存储过程则没有这方面的限制
- 函数可以直接嵌入到SQL语句(例如select语句中)或者MySQL表达式中，存储过程的调用需要call关键字
- 函数体内不能显式或隐式地打开、开始或结束事务，但存储过程则没有这个限制

#### 表记录的插入

插入记录：`insert into 表名[(字段列表)] values(值列表)`

批量插入：`insert into 表名[(字段列表)] values (值列表1), (值列表2), ... (值列表n);`

把查询结果插入（注意字段列表1与2的个数要相同）：`insert into 目标表名 [(字段列表1)] select (字段列表2) from 源表 where 条件表达式;`

- (字段列表)是可选项，字段列表由若干个要插入数据的字段名组
成，各字段使用“,”隔开。若省略了(字段列表)，则表示需要为表的所有字段插入数据。
- (值列表)是必选项，值列表给出了待插入的若干个字段值，各字段值使用“,”隔开，并与字段列表形成一一对应关系。
- 向char、varchar、text以及日期型的字段插入数据时，字段值要用**单引号**括起来。
- 向自增型auto_increment字段插入数据时，**建议插入NULL值**，此时将向自增型字段插入下一个编号。**如果本次插入失败（可能是因为约束条件），则自增型字段仍会递增**
- 向默认值约束字段插入数据时，字段值可以使用default关键字，表示插入的是该字段的默认值。
- 插入新记录时，需要注意表之间的外键约束关系，原则上先给父表插入数据，然后再给子表插入数据。

举例：

```sql
insert into my_table values(now(),'a');
insert into my_table values(now(),'');
insert into classes(class_no,class_name,department_name) values(null,'2012 自动化 1 班', '机电工程');
insert into course values(null,'java语言程序设计',default,'暂无','已审核','001'); -- 第一个是主键

-- MySQL中的now()函数返回MySQL服务器的当前日期以及时间。
-- NULL与空字符串是两个不同的概念。例如，查询 name 值为NULL的记录，需要使用“name is null”;而查询name值为空字符串“''”的 记录，需要使用“name = ''”。类似地，NULL 与整数零以及空格字符“' '”的概念也不相同。
```

replace插入：`replace into 表名[(字段列表)] values (值列表);`

replace把查询结果插入：`replace [into] 目标表名[(字段列表1)] select (字段列表2) from 源表 where 条件表达式`

replace修改字段值（与update类似）：`replace [into]表名 set 字段1=值1, 字段2=值2;`

- replace很像insert，不同之处在于，使用replace语句向表插入新记录时，如果新记录的唯一性约束的字段值与旧记录相同（主键约束是也是唯一性约束），则旧记录先被删除(注意：旧记录删除时也不 能违背外键约束条件)，然后再插入新记录。
- replace将delete和insert合二为一，形成一个**原子操作**，这样就无需将delete操作与insert操作置于事务中了
- 在执行replace后，系统返回所影响的行数。
  - 如果返回1，说明在表中并没有重复的记录，此时replace语句与insert语句的功能相同
  - 如果返回2，说明有一条重复记录，系统自动先调用delete删除这条重复记录，然后再用insert来插入新记录。
  - 如果返回的值大于2，说明有多个唯一索引，有多条记录被删除。

#### 表记录的修改

根据where表达式指定表中哪些记录需要修改（若省略where，则所有记录都会被修改）：`update 表名 set 字段名1=值1, 字段名2=值2,...,字段名n=值n [where条件表达式];`

#### 表记录的删除

删除某条或某些记录（如果省略where，则该表所有记录都被删除，但表结构还在；还需要注意表之间的外键约束关系以及级联选项的设置）：`delete from 表名 [where条件表达式];`

truncate完全清空表：`truncate [table]表名;`

- 从逻辑上说，该语句与“delete from表名”语句的作用相同，但有些差别
- 如果清空记录的表是父表，那么truncate命令将永远执行失败。
- 如果使用truncate table成功清空表记录，那么会**重新设置自增型字段**的计数器。truncate table语句**不支持事务的回滚**，并且不会触发触发器程序的运行。

#### 表记录的检索

```sql
select 字段列表
from 数据源
[ where条件表达式]
[ group by分组字段[ having 条件表达式] ]
[ order by排序字段[ asc | desc ] ];
```

使用谓词distinct过滤结果集中的重复记录：`select distinct department_name from classes;`

使用谓词limit查询某几行记录（第一行记录的start是0而不是1）：`select 字段列表 from 数据源 limit [start,]length;`

- 字段列表用于指定检索字段。
- as代表别名，强烈建议加上，增加可读性（本笔记有的地方没有加，注意甄别）
- from子句用于指定检索的数据源(可以是表或者视图)。
- where子句用于指定记录的过滤条件。
- group by子句用于对检索的数据进行分组。
- having子句通常和group by子句一起使用，用于过滤分组后的统计信息。
- order by子句用于对检索的数据进行排序处理，默认为升序asc。
- 注意：如果select查询语句中包含中文简体字符(例如where子句中包含中文简体字符)，或者查询结果集中包含中文简体字符，则需要进行相应的字符集设置，否则将可能导致查询结果失败，或者查询结果以 乱码形式显示。

字段列表：

- 字段列表可以包含字段名，也可以包含表达式，字段名之间使用逗号分隔，并且顺序可以根据需要任意指定。
- 可以为字段列表中的字段名或表达式指定别名，中间使用 as 关键 字分隔即可(as关键字可以省略)。
- 多表查询时，同名字段前必须添加表名前缀，中间使用“.”分隔。

```sql
select version(), now(),pi(),1+2,null=null,null!=null,null is null;
--version()返回MySQL服务器的版本
--now()返回MySQL服务器的当前时间
--null与null比较，结果为null
--null is null，返回真
```

from子句指定数据源：

- 多个表（或视图）合成一个结果集时，需要**连接条件**
- 连接条件的最常见用法就是使用连接运算（join）
- 连接类型分为inner和outer，outer又分为left, right, full
- 连接条件还可以通过**where子句**中体现

两个表连接：`from 表名1 [连接类型] join 表名2 on 表1和表2之间的连接条件`

三个表连接：`from 表1 [连接类型] join 表2 on 表1和表2之间的连接条件 [连接类型] join 表3 on 表2和表3之间的连接条件;`

where子句过滤结果集：

- 使用单一的条件：`表达式1 比较运算符 表达式2`，可以是= < >等等
- 使用`is [not] NULL`运算符
- 使用逻辑运算符：如! and or
- 使用`[not] in`运算符
- 使用`[not] like`进行模糊查询（`%`匹配零个或多个字符，`_`匹配任意一个字符）：`select * from student where student_name like '张_';`

orderby子句对结果集排序：

- 在order by子句中，可以指定多个字段作为排序的关键字，其中第一个字段为排序主关键字，第二个字段为排序次关键字，以此类推。
- 排序时，MySQL总是将NULL当作“最小值”处理。
- 默认的排序方式为升序asc。
- 对字符串排序时，字符序collation的设置会影响排序结果。

`order by 字段名1 [asc|desc] [... , 字段名n [asc|desc] ];`

聚合函数汇总结果集：

- 聚合函数用于对一组值进行计算并返回一个汇总值
- count()函数用于统计结果集中记录的行数：`select count(*) 学生人数 from student;`
- sum()函数用于对数值型字段的值累加求和：`select sum(score) 总成绩 from choose;`
- avg()函数用于对数值型字段的值求平均值：`select student.student_no,student_name 姓名, avg(score) 平均成绩 from student left join choose on choose.student_no=student.student_no where student_name='张三';`
- max()与min()函数用于统计数值型字段值的最大值与最小值：select max(score) 最高分,min(score) 最低分 from choose;

groupby子句对记录分组统计：

- 将查询结果按照某个字段(或多个字段)进行分组 (字段值相同的记录作为一个分组)：`group by 字段列表[ having条件表达式] [ with rollup ];`
- 单独使用group by子句对记录进行分组时，仅仅显示分组中的某一条记录(字段值相同的记录作为一个分组)。
- 所以groupby一般与聚合函数一起使用

```sql
select class_name,count(student_no)
from classes left join student on student.class_no=classes.class_no group by classes.class_no;
```

having 子句

- 用于设置分组或聚合函数的过滤筛选条件，通常与 group by子句一起使用
- 与where子句使用类似：`having 条件表达式`

```sql
select choose.student_no,student_name,avg(score)
from choose join student on choose.student_no=student.student_no group by student.student_no
having avg(score)>70;
```

子句顺序：**首先where子句对结果集进行过滤筛选，接着group by子句对where子句的输出分组，最后having子句从分组的结果中再进行筛选。**

子查询

- 如果一个select语句能够返回单个值或者一列值，且该select语句嵌 套在另一个SQL语句(例如select语句、insert语句、update语句或者 delete语句)中，那么该select语句称为“子查询”(也叫内层查询))，包含子查询的SQL语句称为“主查询”(也叫外层查询)。
- 为了标记子查询 与主查询之间的关系，通常将子查询写在小括号内
- 子查询一般用在主查询的where子句或having子句中，与比较运算符或者逻辑运算符一起构 成where筛选条件或having筛选条件
- 若子查询仅仅使用自己定义的数据源，则是**非相关子查询**，独立于外部查询
- 若子查询使用了主查询的数据源，则是**相关子查询**，相互依赖
- 子查询可以用比较运算符、in运算符以及如下几个
  - exists逻辑运算符：如果结果集中至少包含一条记录，则exists的结果为true，否则为false。在exists前面加上not时，与上述结果恰恰相反。
  - any运算符：当比较运算符为大于号(>)时，“表达式 > any(子查询)”表示至少大于子查询结果集中的某一个值(或者说大于结果集中的最小值)，那么整个表达式的结果为true。
  - all运算符：通过比较运算符将一个表达式的值与子查询返回的一列值逐一进行比较，若每次 的比较结果都为 true，则整个表达式的值为 true，否则为false

```sql
select class_name,student.student_no, student_name,course_name,score from classes join student on student.class_no=classes.class_no
join choose on choose.student_no=student.student_no
join course on choose.course_no=course.course_no
where score>( select avg(score)
from choose
where student.student_no=choose.student_no and student_name='张 三'
);
```

正则表达式

```sql
--字段名 [not] regexp [binary] '正则表达式'
select * from course where course_name regexp 'java';
select * from course where course_name regexp '^j.*程序设计$';
select * from student where student_contact regexp '^1[58][0-9]{9}';
```

全文索引

- 使用特定的分词技术，利用查询关键字和查询字段内容之间的相关度进行检索
- 通过全文索引可以提高 文本匹配的速度
- 在使用全文检索前，须先创建全文索引。
- 中文全文索引比较麻烦，因为西文有空格作为单词分割
- 常用的 全文检索方式有3种：
  - 自然语言检索：默认的，只能单表，有阈值限制
  - 布尔检索：可多表，没有阈值限制，还可以包含特定一一的操作符，如+-<>
  - 查询扩展检索：查询扩展检索是对自然语言检索的一种改动(自动关联度反馈)，当查询短语很短时有用。先自然语言检索，再查询扩展检索

```sql
select 字段列表
from 表名
where match (全文索引字段1,全文索引字段2,...) against (搜索关键
字[全文检索方式]);
```

#### distinct与groupby的区别

GROUP BY lets you use aggregate functions, like AVG, MAX, MIN, SUM, and COUNT. On the other hand DISTINCT just removes duplicates.

### 索引

#### B树与B+树

[https://mp.weixin.qq.com/s/y3vDkEQfR5Pv1-rcWRZ7nQ](https://mp.weixin.qq.com/s/y3vDkEQfR5Pv1-rcWRZ7nQ)

不想看文章的可以看视频，说的很浅显易懂：[深入剖析Mysql优化底层核心技术](https://www.bilibili.com/video/BV1t4411574y)

一个B+树需要说明是m阶的，其特点如下

- 每个节点的子节点的个数不能超过m，也不能小于m/2;
- 根节点的子节点个数可以不超过m/2，这是一个例外;
- m叉树只存储索引，并不真正存储数据，这个有点类似跳表;
- 通过链表将叶子节点串联在一起，这样可以方便按区间查找，为了升序和降序，一般是**双向链表**

B+树作为数据库索引，主要是为了**减少磁盘IO次数**，根据著名的局部性原理，每次可预读很多附近的记录

B树也就是B-树（不是减号，是连接符），B树与B+树的差别如下

1. B+树的中间节点**关键字**只是起到索引的作用，并不存储数据本身
2. B+树的**数据都存储在叶子节点**上，B树的数据存储在每个节点上，可能会增加B树的层数，从而增大搜索时间，所以对于同样数量的记录，B+树更加“矮胖”，磁盘IO更少
3. B+树支持**区间访问**，底层叶子节点会按大小顺序建立**双向链表**
4. 一般情况，根节点会被存储在内存中，其他节点存储在磁盘中
5. B+树对于每次查询的磁盘IO次数都是固定的，即树的高度（因为要走到叶子节点），**B+树查询性能是稳定的**，而B树有可能只需要一次磁盘IO（只需要访问存储在根节点的数据），也有可能需要树的高度的磁盘IO次数，所以**B树的查询性能并不稳定**

对于B+树而言，每个节点的大小一般是16KB，对于中间节点能存放1000多个关键字（起索引作用）以及下一层对应的指针，树的高度一般不超过4层，就已经能存放千万级别的记录了

#### 索引常见数据结构

哈希表增删改查操作的性能非常好，时间复杂度是O(1)。一些键值数据库，比如Redis、Memcache，就是使用哈希表来构建索引的。这类索引，一般都构建在**内存**中。但是MySQL一般不用哈希表作为索引数据结构，因为即使某个字段col是索引，但是当它指定范围查找，比如col > xx，没法走哈希表的索引；如果是B+树，底层叶子节点支持范围查找，可以走B+树索引

红黑树作为一种常用的平衡二叉查找树，数据插入、删除、查找的时间复杂度是O(logn)，也非常适合用来构建**内存索引**。Ext文件系统中，对磁盘块的索引，用的就是红黑树。

B+树比起红黑树来说，更加适合构建存储在磁盘中的索引。B+树是一个多叉树，所以，对相同个数的数据构建索引，**B+树的高度要低于红黑树**。当借助索引查询数据的时候，读取B+树索引，**需要的磁盘IO次数非常更少**。所以，大部分关系型数据库的索引，比如MySQL、Oracle，都是用B+树来实现的。

跳表也支持快速添加、删除、查找数据。而且，我们通过灵活调整索引结点个数和数据个数之间的比例，可以很好地平衡索引对内存的消耗及其查询效 率。**Redis中的有序集合**，就是用跳表来构建的。

位图和布隆过滤器，也可以用于索引中，**辅助**存储在磁盘中的索引，加速数据查找的效率，比如去磁盘查询前，先通过布隆过滤器判定数据是否存在，若不存在，则直接返回空即可

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

MySQL的索引按应用层次分类：

- 普通索引：最基本的索引，没有任何限制
- 唯一索引(unique key)：索引列的值必须唯一，允许有空值，允许创建多个，不能被其他表引用为外键
- 主键索引(primary key)：特殊的唯一索引，索引列的值必须唯一，**不允许有空值**，**一个表最多一个主键**，主键可以被其他表引用为**外键**，适合唯一标识，如自动递增咧、身份证
- 全文索引：针对较大的数据（如char、varchar或text），不支持前缀索引，生成全文索引很耗时耗空间。搜索引擎一般使用全文索引，但需要分词技术
- 联合/复合索引：指两个或更多列上的索引，遵循**最左匹配原则**，比大小时，第一个列相同再比较第二个

聚簇索引与非聚簇索引：

- 最主要的区别：表记录的排列顺序和与索引的排列顺序是否一致
- 聚簇索引：唯一，**一般是主键**，InnoDB自动使用主键作为聚簇索引。用来加快查询速度。
- 非聚簇索引/普通索引/二级索引：InnoDB的普通索引叶子节点存储的是主键（聚簇索引）的值，而MyISAM的普通索引存储的是记录指针。
- 聚簇索引的叶节点就是数据节点，而非聚簇索引的叶节点仍然是索引节点，并保留一个链接指向对应数据块。
- MyISAM的是非聚簇索引，B+Tree的叶子节点上的data，并不是数据本身，而是数据存放的地址
- InnoDB使用的是聚簇索引，将主键组织到一棵B+树中，而行数据就储存在叶子节点上

#### 回表查询与索引覆盖

回表查询：先通过普通索引的值定位聚簇索引得值，再通过聚簇索引的值定位行记录数据，需要扫描两次索引B+树，它的性能较扫一遍索引树更低。

索引覆盖：只需要在一棵索引树上就能获取SQL所需的所有列数据，无需回表，速度更快。比如id是索引，`select id from table where id = xx`

#### 为什么官方建议使用自增长主键作为索引

结合B+Tree的特点，**自增主键是连续的**, 在插入过程中尽量减少页分裂, 即使要进行页分裂, 也只会分裂很少一部分. 并且能减少数据的移动, 每次插入都是插入到最后。 总之就是减少分裂和移动的频率。

整型容易比大小，在B+树上依次往下索引快，而且整型占用空间小，所以不用字符串型的uuid。

#### 索引与约束的关系

总共有6个约束，其中主键约束、唯一性约束、外键约束与索引的联系较为紧密

- 约束主要用于保证数据的完整性；而索引则是将关键字数据以某种数据结构的方式存储到外存，用于提升数据的检索性能
- 约束是逻辑层面的概念；而索引既有逻辑上的概念，更是一种物理存储方式，且事实存在，需要耗费一定的存储空间。
- 对于MySQL表，**主键约束、唯一性约束、外键约束是基于索引实现的**，所以创建三个约束中的任何一个，会自动创建一个对应的索引，主键约束--主键索引，唯一性约束--唯一性索引，外键约束--普通索引

#### 创建索引

```sql
--在已有表上创建索引
create [ unique | fulltext ] index 索引名 on 表名 (字段名[(长度)])

--修改表结构的方式添加索引
alter table 表名 add [ unique | fulltext ] index 索引名 ( 字段名[(长度)])

--删除索引
drop index 索引名 on 表名

--创建表的时候同时创建索引
create table表名(
    字段名1数据类型 [约束条件],
    字段名2数据类型 [约束条件],
    ...
    [其他约束条件],
    [其他约束条件],
    ...
    [ unique | fulltext ] index [索引名] ( 字段名[(长度)] )
) engine=存储引擎类型default charset=字符集类型

--举例
create table book(
    isbn char(20) primary key,
    name char(100) not null,
    brief_introduction text not null,
    price decimal(6,2),
    publish_time date not null,
    unique index isbn_unique (isbn),
    index name_index (name (20)),
    fulltext index brief_fulltext (name,brief_introduction),
    index complex_index (price,publish_time)
) engine=MyISAM default charset=gbk;
```

### 一条MySQL语句的执行过程

[步步深入：MySQL架构总览->查询执行流程->SQL解析顺序](https://www.cnblogs.com/annsshadow/p/5037667.html)

连接器：身份认证和权限相关
分析器：词法分析（提出关键字、表、条件等）+语法分析（判断合法性）
优化器：MySQL认为最优方案执行
执行器：执行语句，从存储引擎返回。如果是更新语句，还要修改与binlog（归档日志，所有引擎可用）、redo log（重做日志，InnoDB特有）

解析过程：from .. on .. join .. where .. group by .. having .. select .. order by .. limit

### SQL优化

1. 经常使用的列使用索引
2. 多次查询同样的数据，考虑缓存改组数据
3. select * from tables，真的需要所有列数据吗？
4. 切分查询，大查询切分为小查询
5. 分解关联查询，单表查询，在应用程序中进行关联，避免锁争用

explain执行计划：

很好的视频教程：[SQL优化](https://www.bilibili.com/video/BV1es411u7we?p=8)

- id：id值相同，从上往下，顺序执行；id值不同，id越大的表越优先查询；嵌套子查询时，先执行子查询。**小表驱动大表**，优化器可能会优先执行小表，因为连表查询会出现笛卡尔积
- select_type：simple是简单查询（不包含子查询与union），derived是衍生查询（用到了临时表），如果查询语句包含子查询，则primary是主查询，subquery是子查询
- table：表名
- type：类型，system(系统表)>const（仅仅能查到一条数据，仅用于主键索引和唯一索引）>eq_ref（唯一性索引，结果多条，但是每条数据是唯一的）>ref（非唯一性索引，结果多条，但是每条数据是零条或多条)>range（检索指定范围的行，where后面是个范围查询）>index（查询索引中的全部数据）>all（查询全部数据，没有走索引，**全表扫描**)，越往左性能越高，自己优化**一般最多只能达到ref或range**
- possible keys：可能用到的键
- key：实际使用到的索引
- key_len：索引的长度，判断复合索引是否完全被使用
- ref：当前表所参照的字段（不是type段的ref）
- rows：被索引优化查询的行数
  - Extra：其他项目，比如using filesort（说明当前性能消耗大，需要额外的查询or排序，一般出现在order by），using temporary（说明当前性能孙好大，需要额外的临时表，一般出现在group by），using index（**性能提升**，出现这个字段说明SQL优化得不错，索引覆盖，不读取源文件，只需要从索引文件种获取事件（即**不需要回表查询**），using where（执行了where过滤），impossible where（where子句永远为false）

SQL优化最佳实践：

- 根据SQL实际解析的顺序，调整（复合）索引的顺序
- 连接时，小表放左边，小表驱动大表
- 复合索引，不要跨列使用或无序使用，最佳左前缀，否则索引失效
- 复合索引，尽量使用全索引匹配
- 复合索引，不能使用不等于或is null，否则列自身和右侧索引全部失效
- 不要在索引列上进行计算操作，否则索引失效
- 模糊查询like，尽量以常亮开头如果用%开头，则索引失效。如果必须使用，则可以使用索引覆盖挽救一部分
- 尽量不要使用类型转换，否则索引失效
- 尽量不要使用or，否则索引失效
- order by（using filesort），单路排序，一次性把所有字段读到buffer里，在buffer里排序，buffer要求空间较大，但是不一定是真的单路排序，因为数据量可能很大，可能会读取多次，可以考虑**增大buffer的容量大小**
- 慢查询日志，MySQL会把大于阈值的SQL语句记录下来，阈值默认是10s。建议在开发调试时开启，在部署上线时关闭。通过mysqldumpslow工具查看慢SQL
- 分析海量数据，开启profiles，之后的所有SQL语句都会记录下来，并且会记录这条SQL执行的一些负载信息，比如CPU、block

### 页结构

一个表空间存在多个段，其中一个段包含多个区，一个区存在多个页，每个页多行记录

- 区：在Innodb中，一个区分配64连续的页，页大小默认为16KB,所以一个区大小为64*16KB=1MB
- 段：段是由多个区组成，不同数据库对象不同段。创建一张表的时候创建一个表段。创建索引则为索引段。
- 表空间：逻辑容器。其中包含很多段，但是一个段只能属于一个表空间。一个数据库由多个表空间组成，其中包含系统表空间，用户表空间等。
- 页：数据库IO操作最小单位为页，各个页通过链表连接在一起

在页中记录按照单链表的方式存储。我们知道单链表的插入和删除方便，但是查找就不是很有好了。所以在此引入**页目录**，页目录提供**二分查找**的方式提高记录的检索效率

### 主键/外键/约束条件/自增型字段

关系数据库中的表必须存在**关键字(key)**，用以唯一标识表中的每行记录，关键字实际上是能够唯一标识表记录的字段或字段组合。

建议从所有关键字中选择一个作为表的**主键**，主键具有如下特征：

- 表的主键可以是一个字段，也可以是多个字段的组合
- 主键的值具有唯一性且不能取空值（NULL）

如果表A中的一个字段a对应于表B的主键b，则字段a称为表A的**外键(foreign key)** ，此时存储在表A中字段a的值，要么是NULL，要么是来自于表B主键b的值。通过外键可以表示实体间的关系。

总共有六大约束：

- 主键(primary key) 约束：设计数据库时，建议为所有的数据库表都定义一个主键，用于保证数据库表中记录的唯一性。**一张表中只允许设置一个主键**，当然这个主键可以是一个字段，也可以是一个字段组合(不建议使用复合主键)。在录入数据的过程中，必须在所有主键字段中输入数据，即任何**主键字段的值不允许为NULL**。
- 外键(foreign key) 约束：用于保证外键字段值与主键字段值的一致性，外键字段值**要么是NULL**，**要么是主键字段值的“复制”**。外键字段所在的表称为子表，主键字段所在的表称为父表。父表与子表通过外键字段建立起了外键约束关系。MySQL的MyISAM引擎不支持外键，InnoDB引擎支持外键。
- 唯一性(unique) 约束：如果希望表中的某个字段值不重复，可以考虑为该字段添加唯一性约束。与主键约束不同，**一张表中可以存在多个唯一性约束**，并且**满足唯一性约束的字段可以取NULL值**。
- 非空(not NULL)约束：如果希望表中的**字段值不能取NULL值**，可以考虑为该字段添加非空约束。
- 检查(check) 约束：检查约束用于检查字段的输入值**是否满足指定的条件**。输入(或者修改)数据时，若字段值不符合检查约束指定的条件，则数据不能写入该字段。**MySQL暂时还不支持检查约束**。
- 默认值(default) 约束:默认值约束用于指定一个字段的默认值。如果没有在该字段填写数据，则该字段将自动填入这个默认值。

自增：

- 必须将自增型字段设置为主键，否则创建数据库表将会失败
- 默认情况下，MySQL自增型字段的值从1开始递增，且步长为1。
- 向自增型字段插入一个 NULL值(推荐)或0时，该字段值会被自动设置为比上一次插入值更大的值
- 如果删除某条记录，这个自增字段可能会出现断层

### 事务/ACID特性/四种隔离级别

[Mysql事务实现原理](https://juejin.im/post/5cb2e3b46fb9a0686e40c5cb#heading-0)

- 事务是指作为单个逻辑工作单元执行的**一系列操作**，要么完全地执行，要么完全地不执行

- 必须满足ACID（原子性、一致性、隔离性和持久性）

    1. 原子性（Atomicity）：事务包含的所有操作要么全部成功，要么全部失败回滚
    2. 一致性（Consistency）：事务必须使数据库从一个一致性状态变换到另一个一致性状态，比如A与B账户的钱加起来是5000，那么无论如何转账，最后还是5000
    3. 隔离性（Isolation）：当多个用户并发访问数据库时，比如操作同一张表时，数据库为每一个用户开启的事务，不能被其他事务的操作所干扰，多个并发事务之间要相互隔离，有4种隔离级别
    4. 持久性（Durability）：一个事务一旦被提交了，那么对数据库中的数据的改变就是永久性的，即便是在数据库系统遇到故障的情况下也不会丢失提交事务的操作。

事务的恢复机制（REDO日志和UNDO日志）

- Undo Log
  - Undo Log是为了实现事务的原子性，在MySQL数据库InnoDB存储引擎中，还用了Undo Log来实现MVCC。
  - **事务的原子性**：事务中的所有操作，要么全部完成，要么不做任何操作，不能只做部分操作。如果在执行的过程中发生了错误，要回滚(Rollback)到事务开始前的状态，就像这个事务从来没有执行过。
  - 原理：Undo Log的原理很简单，为了满足事务的原子性，在操作任何数据之前，首先**将数据备份**到一个地方（这个存储数据备份的地方称为Undo Log）。然后进行数据的修改。如果出现了错误或者用户执行了ROLLBACK语句，系统可以利用Undo Log中的备份将数据恢复到事务开始之前的状态。为了保证持久性，必须将数据在事务提交前写到磁盘。只要事务成功提交，数据必然已经持久化。
  - 缺陷：每个事务提交前将数据和Undo Log写入磁盘，这样会导致大量的磁盘IO，因此性能很低。
  - 如果能够将数据缓存一段时间，就能减少IO提高性能。但是这样就会丧失事务的持久性。因此引入了另外一种机制来实现持久化，即Redo Log。
- Redo Log
  - 原理和Undo Log相反，Redo Log记录的是**新数据的备份**。
  - 在事务提交前，只要将Redo Log持久化即可，不需要将数据持久化。
  - 当系统崩溃时，虽然数据没有持久化，但是Redo Log已经持久化。系统可以根据Redo Log的内容，将所有数据恢复到最新的状态。

MySQL的4种事务隔离级别

隔离级别的分类是数据的**可靠性与性能之间的权衡**。

- 未提交读(read uncommitted)：一个事务在提交之前，对其他事务是可见的，即事务可以读取未提交的数据。
  - 存在**脏读**（对要写的数据没有加锁，其他事物读到了某事物修改后但未提交的数据）
  - 但可以**读写并行**，性能高。
- 提交读(read committed)：事务在提交之前，对其它事务是不可见的。
  - 解决了脏读问题（对要写的数据加了排他锁）
  - 存在**不可重复读**（对要读的数据没有加锁，事务内两次查询的得到的结果可能不同，即可能在查询的间隙，有事务提交了修改）
- 可重复读(repeatable read)：在同一事务中多次读取的数据是一致的。
  - 解决了脏读和不可重复读问题（对要读or要写的数据都加了排他锁，或者用MVCC机制实现）
  - 存在**幻读**（在事务两次查询间隙，有其他事务又插入或删除了新的记录）。
  - **MySQL默认隔离级别**，因为InnoDB可以通过间隙锁防止幻读，其他存储引擎在这一层可能还是会有幻读
- 串行(serializable)：强制事务串行化执行。即一个事物一个事物挨个来执行，可以解决上述所有问题。

### MVCC

- 并发控制最简单的方法是加锁，让所有的读者等待写者工作完成，但是这样**效率**会很差。
- MVCC(多版本并发控制)将同一份数据保留多个副本，添加不同的**版本号**。事务开启时看到的是哪个版本，就是哪个版本。
- 最大的好处：**读写不冲突**

版本链

InnoDB中，每行记录实际上都包含了两个隐藏字段：事务 id(trx_id) 和回滚指针 (roll_pointer)。

- trx_id：事务 id。每次修改某行记录时，都会把该事务的事务 id 赋值给trx_id隐藏列。
- roll_pointer：回滚指针。每次修改某行记录时，都会把undo日志地址赋值给roll_pointer隐藏列。

由于每次变动都会先把undo日志记录下来，并用roll_pointer指向undo日志地址。因此可以认为，对该条记录的修改日志串联起来就形成了一个版本链，版本链的头节点就是当前记录最新的值。

### 存储引擎

- InnoDB：默认的存储引擎，最为通用/推荐的一种引擎，专注于事务，在**并发**上占优势，系统资源**占用多**。
- MyISAM：专注于**性能**，查询速度块，系统资源**占用少**。
- MyISAM把索引和数据**分离**，InnoDB把索引和数据**结合**，B+树底层的叶子节点直接存储数据，索引即数据，数据即索引
- InnoDB支持**事务**, MyISAM不支持；
- InnoDB支持**MVCC（多版本并发控制）**，MyISAM不支持
- InnoDB支持**行级锁、表锁**；MyISAM只支持表锁；
- InnoDB支持**外键**；MyISMA不支持外键
- InnoDB支持**聚簇索引**，MyISAM不支持
- MyISAM实现了**前缀压缩**技术，占用存储空间更小（但会影响查找），InnoDB是原始数据存储，占用存储更大。

InnoDB打开了自动提交（auto commit），所以每条更新语句都自动开始事务和提交事务，可以将多条更新语句合并在一个事务里，可以提高速度。

InnoDB提供两种数据库表的存储方式：

- 共享表空间：整个数据库的表数据和索引存储在一个文件中
- 独占表空间（默认开启）：**每个表都有自已独立的表空间物理文件**，数据存储清晰，灾难恢复相对容易，不会影响其他表。可以实现单表在不同的数据库中移动。空间更容易回收。

PS：大部分情况下，InnoDB都是正确的选择。---《高性能MySQL》

存储引擎是针对数据库还是针对数据库表？数据库表

为什么InnoDB表必须要有主键？因为InnoDB用B+树索引组织起所有数据，必须要有主键才能查询到数据。

MySQL在使用!=或<>不会走索引，会导致全表扫描

### 锁机制

- 从**加锁时机**分为悲观锁和乐观锁
- 从**锁的粒度**分为表锁、(页锁)、行锁（InnoDB独有）
  - 表锁：锁住整张表，读锁互不阻塞，写锁阻塞其他所有读写锁（同一张表）。开销最小。
  - 行级锁（InnoDB独有）：**针对索引加的锁**，不是针对记录加的锁。**并且该索引不能失效，否则都会从行锁升级为表锁**。开销大，并发程度高。
  - 锁粒度的影响：锁定的数据量越少（粒度越小），并发程度越高，但相应的加锁、检测锁、释放锁用的系统开销也随之增大。
- 从**锁的类型**分为共享锁和排它锁
  - 共享锁/读锁：互不阻塞，优先级低，`lock in share mode`
  - 排他锁/写锁：阻塞其他锁，优先级高，即确保在一个事务写入时不受其他事务的影响。在InnoDB中，对于update,insert,delete语句会自动加**排它行锁**, 在查询语句后添加`for update`也可以加排它锁，这是**间隙锁**的用法

意向锁

- InnoDB表既支持行级锁，又支持表级锁。
- 引入意向锁的目的是为了**快速判断表中是否有记录被上锁**
- **意向锁是隐式的表级锁**，向InnoDB表的某些记录施加行级锁时，InnoDB存储引擎首先会**自动地向该表施加意向锁**，然后再施加行级锁，意向锁无需手动维护，生命周期非常短暂，**语句执行完就解锁**。
- 意向锁虽是表级锁，但是却表示事务正在查询或更新某一行记录，而不是整个表，因此意向锁之间不会产生冲突。
- 考虑如下场景：MySQL客户机A获得了某个InnoDB表中若干条记录的行级锁，此时，MySQL客户机B想要加表锁，它会逐行检查是否有行锁，而这种检测需要耗费大量的服务器资源。如果有意向锁，B只需要检测自己的表锁与该意向锁是否兼容即可，大大减少了资源消耗。
- MySQL提供了两种意向锁：
  - 意向共享锁(IS)：向InnoDB表的某些记录施加行级共享锁时
  - 意向排他锁(IX)：向InnoDB表的某些记录施加行级排他锁时

间隙锁

- 必须要有索引
- 防止间隙内有新数据被插入
- MySQL默认的事务隔离级别是repeatable read，但可能发生幻读，如果想保持repeatable read的并发度，又不想幻读，可以使用间隙锁，对查询结果集加共享锁（lock in share mode）或排它锁（for update）

![MySQL的各种锁](https://raw.githubusercontent.com/IMWYY/AboutMyself/master/picBed/Screenshot1520500121.png)

乐观锁与悲观锁

- 乐观锁（适用于多读，写时检查，需要用户实现）
  - 总是假设最好的情况，每次去拿数据的时候都认为别人不会修改，所以不会上锁，但是在更新的时候会判断一下在此期间别人有没有去更新这个数据，可以使用**版本号机制**和**CAS算法**实现。
  - 乐观锁适用于**冲突概率非常低且加锁成本非常高**的场景的应用类型，这样可以提高吞吐量，像数据库提供的类似于write_condition机制，其实都是提供的乐观锁。还有在线文档也是个乐观锁的场景，git也是这个思想
- 悲观锁（适用于多写，读时加锁）
  - 总是假设最坏的情况，每次去拿数据的时候都认为别人会修改，所以每次在拿数据的时候都会上锁，这样别人想拿这个数据就会阻塞直到它拿到锁（共享资源每次只给一个线程使用，其它线程阻塞，用完后再把资源转让给其它线程）。
  - 传统的关系型数据库里边就用到了很多这种锁机制，比如行锁，表锁等，读锁，写锁等，都是在做操作之前先上锁。

- 两种锁的使用场景
  - 乐观锁适用于写比较少的情况下（多读场景），即冲突真的很少发生的时候，这样可以省去了锁的开销，加大了系统的整个吞吐量。
  - 但如果是多写的情况，一般会经常产生冲突，这就会导致上层应用会不断的进行retry，这样反倒是降低了性能，所以一般多写的场景下用悲观锁就比较合适。

- 乐观锁的版本号机制
  - 一般是在数据表中加上一个数据**版本号version字段**，表示数据被修改的次数，当数据被修改时，version值会加一。
  - 当线程A要更新数据值时，在读取数据的同时也会读取version值，在提交更新时，若刚才读取到的version值为当前数据库中的version值相等时才更新，否则重试更新操作，直到更新成功。

- CAS算法
  - 即compare and swap（比较与交换），是一种有名的无锁算法。无锁编程，即不使用锁的情况下实现多线程之间的变量同步，也就是在没有线程被阻塞的情况下实现变量的同步，所以也叫非阻塞同步（Non-blocking Synchronization）。CAS算法涉及到三个操作数：需要读写的内存值 V，进行比较的值 A，拟写入的新值 B。当且仅当 V 的值等于 A时，CAS通过原子方式用新值B来更新V的值，否则不会执行任何操作（**比较和替换是一个原子操作**）。一般情况下是一个自旋操作，即不断的重试。

- 乐观锁的缺点
    1. **ABA 问题（常见）**：如果一个变量V初次读取的时候是A值，并且在准备赋值的时候检查到它仍然是A值，那我们就能说明它的值没有被其他线程修改过了吗？很明显是不能的，因为在这段时间它的值可能被改为其他值，然后又改回A，那CAS操作就会误认为它从来没有被修改过。这个问题被称为CAS操作的 "ABA"问题。
    2. 自旋CAS循环时间长开销大
    3. CAS 只对单个共享变量有效，当操作涉及跨多个共享变量时 CAS 无效

### 分库分表

[数据库分库分表(sharding)系列(五) 一种支持自由规划无须数据迁移和修改路由代码的Sharding扩容方案](https://blog.csdn.net/bluishglc/article/details/7970268)

拆分

- 垂直拆分：按照字段(或者列)进行拆分，其实就是把组成一行的多个列分开，放到不同的表中
  - 优点：一个数据块(Block)就可以存放更多行的记录，对频繁访问的字段执行select语句，硬盘I/O次数也会相应减少
  - 缺点：需要冗余数据，需要join
- 水平拆分：按照记录(或者行)进行拆分，其实就是把一个表分成几个表，这些表具有相同的列，但是存放更少的数据（比如按照时间维度拆分）
  - 优点：将维度作为查询条件执行select语句时，如果维度范围很小(例如查询12月份的销售记录)，可以有效降低需要扫描的数据和索引的数据块数，加快查询速度。
  - 缺点：需要union

分区

- 实质是一种水平拆分
- 是按照指定的规则，**跨文件系统**分配单个表的多个部分。

### 分页查询

分页查询时建议不要用limit + offset，因为可能会产生全量扫描，需要大量的IO次数，导致慢SQL

最好使用基于游标的分页，每次分页时记录上一次主键的值（通常是自增id列或连续递增的timestamp）与limit大小，这样下次查询时可以直接从上次查询的末尾开始(通过主键索引，加快速度)

```sql
select * from table limit 10 offset 10
select * from table where id > 10 limit 10
```

### MySQL三大日志

[必须了解的 MySQL 三大日志：binlog、redo log 和 undo log](https://juejin.im/post/6860252224930070536)

#### binlog

binlog 用于记录数据库执行的写入性操作 (不包括查询) 信息，以二进制的形式保存在磁盘中。binlog 是 mysql 的逻辑日志，并且由 Server 层进行记录，使用任何存储引擎的 mysql 数据库都会记录 binlog 日志。binlog是追加写，通过`max_binlog_size`参数设置每个binlog文件的大小。

binlog主要用于**主从复制**（master将binlog发给各slave，slave重放binlog从而达到主从数据一致）以及**数据恢复**（通过mysqlbinlog工具来恢复数据）

binlog刷盘时机：`sync_binlog`参数控制刷盘时机，取值范围时0-N：

- 0：不去强制要求，由系统自行判断何时写入磁盘；
- 1：每次 commit 的时候都要将 binlog 写入磁盘（**MySQL5.7.7之后默认值**，但为了性能考虑，可以增大）
- N：每 N 个事务，才会将 binlog 写入磁盘。

binlog日志格式，通过`binlog-format`指定：

- 基于语句(statement)，在主服务器上执行的SQL语句，在从服务器上执行同样的语句。优点：日志量很小；缺点：某些情况下主从不一致
- 基于行的复制(row)：把改变的内容复制过去，而不是把命令在从服务器上执行一遍。优点：复制一致；缺点：日志量很大
- 混合类型的复制(mix): 默认采用基于语句的复制，一旦发现基于语句的无法精确的复制时，就会采用基于行的复制。

#### redo log

- 当事物持久化成功，数据页需要刷盘，可能会出现性能问题，比如：以页为单位刷盘，只修改几个字节也需要写整个数据页；不同数据页内存不连续，需要随机写IO。因此 mysql 设计了redo log，具体来说就是**只记录事务对数据页做了哪些修改**，这样就能完美地**解决性能问题**了 (相对而言文件更小并且是顺序 IO)。
- redo log包括两个部分：一个是内存中的日志缓冲 (redo log buffer)，另一个是磁盘上的日志文件 (redo log file)
- mysql 每执行一条 DML 语句，先将记录写入 redo log buffer，后续某个时间点再一次性将多个操作记录写到 redo log file。这种先写日志，再写磁盘的技术就是 MySQL 里经常说到的**WAL(Write-Ahead Logging)**技术。
- redo log 实际上记录数据页的变更，而这种变更记录是没必要全部保存，因此实现上采用了大小固定，循环写入的方式，当写到结尾时，会回到开头循环写日志。

#### redo log 与 binlog 区别

- binlog 日志只用于归档，只依靠 binlog 是没有 crash-safe 能力的。
- 但只有 redo log 也不行，因为 redo log 是 InnoDB 特有的，且日志上的记录落盘后会被覆盖掉。
- 因此需要 binlog 和 redo log 二者同时记录，才能保证当数据库发生宕机重启时，数据不会丢失。

#### undo log

- 原子性底层就是通过 undo log 实现的。- undo log 主要记录了数据的逻辑变化，比如一条 INSERT 语句，对应一条 DELETE 的 undo log，对于每个 UPDATE 语句，对应一条相反的 UPDATE 的 undo log，这样在发生错误时，就能回滚到事务之前的数据状态

### 数据库连接池怎么设计

- 限制连接池中最多、可以容纳的连接数目，避免过度消耗系统资源。
- 当客户请求连接，而连接池中所有连接都已被占用时，该如何处理呢？一种方式是让客户一直等待，直到有空闲连接，另一种方式是为客户分配一个新的临时连接。
- 当客户不再使用连接，需要把连接重新放回连接池。
- 连接池中允许处于空闲状态的连接的最大项目。假定允许的最长空闲时间为十分钟，并且允许空闲状态的连接最大数目为5，
- 那么当连接池中有n个(n>5)连接处于空闲状态的时间超过十分钟时，就应该把n-5个连接关闭，并且从连接池中删除，这样才能更有效的利用系统资源。

### 主从架构/复制

[高性能Mysql主从架构的复制原理及配置详解](https://blog.csdn.net/hguisu/article/details/7325124)

- 按照备份后产生的副本文件是否可以编辑，逻辑备份（SQL脚本）以及物理备份（二进制数据）。
- 按照是否需要停止MySQL服务实例，冷备份、温备份（加上锁，不允许写数据）以及热备份
- 按照副本文件的缺失程度，完全备份（完整的，可以恢复出数据库）以及增量备份（对更新的数据进行备份，需要借助完全备份）。
- mysqlhotcopy用于热备份、mysqldump是常用的备份工具、mysqlbinlog通过二进制日志文件恢复出数据库
- MySQL复制基于二进制日志机制，至少需要开启两个MySQL服务

复制过程：

- master将改变记录到二进制日志(binary log)中
- slave用**IO thread**将master的bin log拷贝到它的**中继日志(relay log)**，中继日志一般在OS的缓存中，开销很小
- slave用**SQL thread**重做中继日志中的事件，使其与master中的数据一致

复制常用的拓扑结构：

- 单一master和多slave，slave之间不通信，适合读多写少的场景，可以将读操作分散到其他slave
- 主动模式的Master-Master，两台机器又是master又是slave，最大的问题使更新冲突
- 主动-被动模式的Master-Master，基于上个的改进，其中一个服务只能提供读服务
- 级联复制架构 Master –Slaves - Slaves，适合读压力特别大的场景，因为如果单一master多slave会消耗master的复制资源
- 带从服务器的Master-Master结构，提供了冗余，也可以将读密集型的请求放到slave上

### Redis是什么

- Redis是一个基于内存的键值型数据库，**数据全部存在内存中**（所以高效），**定期写入磁盘**（提供持久化），当内存不够时，可以选择指定的LRU算法删除数据，Redis是单进程单线程的
- Redis支持多种数据结构，如string、hash、set、list等
- 主要有点是速度快，因为在内存中，类似于hash
- 主要缺点是容量受到内存的限制，不支持海量数据

#### Redis应用场景

1. 会话缓存：相比于memcached，Redis提供持久化
2. 全页缓存：因为有磁盘的持久化
3. 队列：提供list和set，可以当做消息队列平台
4. 排行榜/计数器：Redis对数字的递增或递减的实现非常高效
5. 发布/订阅

#### Redis里有1亿个key，如何找出其中10w个以某个固定前缀开头的可以

用keys指令可以扫除指定模式的key列表

追问：但如果是线上业务，这样会有问题吗？

回答：redis是单进程单线程的，keys指令会导致阻塞，影响线上服务。这时应该用scan指令，scan指令可以无阻塞的提取出指定模式的key列表，但是会有一定的重复概率，在客户端做一次去重就可以了，但是整体所花费的时间会比直接用keys指令长

### Redis和MySQL数据怎么保持数据一致的

起因：高并发时，Redis做缓存，MySQL做数据持久化。有请求的时候从Redis中获取缓存的用户数据，有修改则同时修改MySQL和Redis中的数据。所以产生了一致性问题

解决：读Redis（热数据基本都在Redis），写MySQL（增删改都是在MySQL），更新Redis数据（先写入MySQL，再更新到Redis）

#### Redis和Memcached的区别

- 数据类型：Redis支持String、List、Set等等；Memcached只支持简单数据类型
- 持久性：Redis可以将内存中的数据定期存入磁盘，有持久性；Memcached不支持持久性
- 分布式存储：Redis支持主从复制模式；Memcached本身不支持分布式，但可以使用一致性hash

#### Redis 演进架构

[一文搞懂 Redis 架构演化之路
](https://mp.weixin.qq.com/s/QssILJLna_v7XQWtV5UMzA)

## 数据结构与算法

均摊时间复杂度其实就是特殊的平均时间复杂度，有一组操作，它们有前后连贯的执行顺序，可以把它们放在一起考虑，如果其中只有一次操作的时间复杂度较高，那它的耗时可以均摊到其他操作上去，这就是摊还分析

均摊时间复杂度一般都等于最好情况时间复杂度

### 排序总结

![sortsummary](../image/sortsummary.png)

1、堆排序、快速排序、希尔排序、直接选择排序不是稳定的排序算法；

2、基数排序、冒泡排序、直接插入排序、折半插入排序、归并排序是稳定的排序算法

快排最坏退化成冒泡O(n^2)，平均时间证明：设快排复杂度是T(n)，由于一次Partition的复杂度是O(n)，有T(n)=2T(n/2)+O(n)

冒泡、选择、插入是**就地的**、**基于比较的**、**稳定的（除了选择排序是不稳定）**、时间复杂度是O(n^2)的排序算法，可以用有序度的思想来不严格证明冒泡的平均时间复杂度是O(n^2)。

插入排序比冒泡排序更好点，因为赋值操作更好，插入排序也有很多优化手段，比如希尔排序

```c++
vector<int> bubbleSort(vector<int> vec){
    for (int i = 0; i < vec.size(); ++i){
        for (int j = 0; j < vec.size() - 1 - i; ++j){
            if(vec[j] > vec[j + 1]){
                swap(vec[j], vec[j + 1]);
            }
        }
    }
    return vec;
}

vector<int> insertSort(vector<int> vec){
    for (int i = 1; i < vec.size(); ++i){
        int temp = vec[i];
        int j = i - 1;
        for(; j >= 0; --j){
            if(vec[j] > temp){
                vec[j + 1] = vec[j];
            }
            else{
                break;
            }
        }
        vec[j + 1] = temp;
    }
    return vec;
}

vector<int> selectSort(vector<int> vec){
    for (int i = 0; i < vec.size(); ++i){
        int min_index = i;
        for (int j = i + 1; j < vec.size(); ++j){
            min_index = vec[j] < vec[min_index] ? j : min_index;
        }
        swap(vec[i], vec[min_index]);
    }
    return vec;
}
```

归并排序是稳定的，不是原地排序的，，比较次数几乎是最优的，空间复杂度O(n)，任何情况的时间复杂度都是O(nlogn)

快排是一种原地、不稳定的，最坏情况的时间复杂度从O(nlogn)退化成了O(n2)，但是概率很低，所以平均时间复杂度就是O(nlogn)

堆排序是非稳定的，原地排序的，时间复杂度为O(nlogn)

桶排序、计数排序、基数排序时间复杂度为O(n)，非原地排序，不是基于比较的排序，对数据有一定要求

桶排序：

- 时间复杂度为O(n)
- 如果要排序的数据有n个，我们把它们均匀地划分到m个桶内，每个桶里就有k=n/m个元素。每个桶内部使用快速排序（但快排不是稳定的，若要求稳定则用归并排序），时间复杂度为`O(k * logk)`。m个桶排序的时间复杂度就是`O(m * k * logk)`，因为k=n/m，所以整个桶排序的时间复杂度就是`O(n*log(n/m))`。当桶的个数m接近数据个数n时，log(n/m)就是一个非常小的常量，这个时候桶排序的时间复杂度接近O(n)。
- 桶排序的限制：数据能够平均分到m个桶里，并且桶之间有天然的大小顺序
- 桶排序的场景：比较适合用在外部排序中，适用于内存不够的情况

计数排序

- 时间复杂度O(n+k)，k是数据范围
- 计数排序其实是桶排序的一种特殊情况。
- 当要排序的n个数据，所处的范围并不大的时候，比如最大值是k，我们就可以把数据划分成k个桶。每个桶内的数据值都是相同的，省掉了桶内排序的时间
- 计数排序的限制：数据范围不大，只能排非负整数，如果是其他类型，则要保证相对大小不变转为非负整数
- 计数排序的场景：高考考生排名，年龄排序

基数排序

- 时间复杂度O(dn)，d是维度
- 每次排序必须是稳定，不然低位的排序就没意义了，如果是根据数字的某位排序，则可以用桶排序或者计数排序
- 排序的数据如果不是等长的，可以补0
- 基数排序的限制：每个数据可以分割出独立的“位”来比较，且位之间有递进的关系，而且每位的数据范围不能太大，否则就不能用桶排序or计数排序，那样时间复杂度就达不到O(n)了
- 基数排序的场景：手机号排序

### 二分查找

- 查找任意一个等于给定值的元素
- 查找第一个等于给定值的元素

```c++
int binarySearchFirstEqual(vector<int>& vec, int target){
    int low = 0;
    int high = vec.size() - 1;
    while(low <= high){
        int mid = low + (high - low) / 2;
        if(vec[mid] > target){
            high = mid - 1;
        }
        else if(vec[mid] < target){
            low = mid + 1;
        }
        else{
            if (mid == 0 || vec[mid - 1] != target){ // 如果到头或者前面一位不是target，则当前的mid就是答案
                return mid;
            }
            else{
                high = mid - 1; // 与target相等，但不是第一个，往前查找
            }
        }
    }
    return -1;
}
```

- 查找最后一个等于给定值的元素

```c++
int binarySearchLastEqual(vector<int>& vec, int target){
    int low = 0;
    int high = vec.size() - 1;
    while(low <= high){
        int mid = low + (high - low) / 2;
        if(vec[mid] > target){
            high = mid - 1;
        }
        else if(vec[mid] < target){
            low = mid + 1;
        }
        else{
            if (mid == vec.size() - 1 || vec[mid + 1] != target){ // 如果到尾或者后面一位不是target，则当前的mid就是答案
                return mid;
            }
            else{
                low = mid + 1; // 与target相等，但不是最后一个，往后查找
            }
        }
    }
    return -1;
}
```

- 查找第一个大于等于给定值的元素

```c++
int binarySearchFirstNotLess(vector<int>& vec, int target){
    int low = 0;
    int high = vec.size() - 1;
    while(low <= high){
        int mid = low + (high - low) / 2;
        if(vec[mid] >= target){
            if(mid == 0 || vec[mid - 1] < target){  // 这里不能用不等号，必须用小于号
                return mid;
            }
            else{
                high = mid - 1;
            }
        }
        else{
            low = mid + 1;
        }
    }
    return -1;
}
```

- 查找最后一个小于等于给定值的元素

```c++
int binarySearchLastNotGreater(vector<int>& vec, int target){
    int low = 0;
    int high = vec.size() - 1;
    while(low <= high){
        int mid = low + (high - low) / 2;
        if(vec[mid] > target){
            high = mid - 1;
        }
        else{
            if(mid == vec.size() - 1 || vec[mid + 1] > target){ // 这里不能用不等号，必须用大于号
                return mid;
            }
            else{
                low = mid + 1;
            }
        }
    }
    return -1;
}
```

### 队列

非循环队列，得有搬移数据的特殊操作，但是均摊下来，时间复杂度仍为O(1)

循环队列可以不用搬移数据，但是在判断队列满和队列空的时候要注意区分

**阻塞队列**：就是在队列为空的时候，从队头取数据会被阻塞，如果队列已经满了，那么插入数据的操作就会被阻塞。用阻塞队列可以实现生产者-消费者模型

**并发队列**：**线程安全**的队列。最简单直接的实现方式是直接在enqueue()、dequeue()方法上**加锁**，但是锁粒度大并发度会比较低，同一时刻仅允许一个存或者取操作。实际上，基于数组的循环队列，利用**CAS**原子操作，可以实现非常高效的并发队列。这也是循环队列比链式队列应用更加广泛的原因

### 栈

- 函数调用：
  - 我们不一定非要用栈来保存临时变量，只不过如果这个函数调用符合后进先出的特性，用栈这种数据结构来实现，是最顺理成章的选择。
  - 从调用函数进入被调用函数，对于数据来说，变化的是作用域。所以根本上，只要能保证每进入一个新的函数，都是一个新的作用域就可以。而要实现这个，用栈就非常方便。在进入被调用函数的时候，分配一段栈空间给这个函数的变量，在函数结束的时候，将栈顶复位，正好回到调用函数的作用 域内
- 表达式求值：
  - 利用两个栈，其中一个用来保存操作数，另一个用来保存运算符。
  - 我们从左向右遍历表达式，当遇到数字，我们就直接压入操作数栈；当遇到运算符，就与运算符栈的栈顶元素进行比较，若比运算符栈顶元素优先级高，就将当前运算符压入栈，若比运算符栈顶元素的优先级低或者相同，从运算符栈中取出栈顶运算符，从操作数栈顶取出2个操作数，然后进行计算，把计算完的结果压入操作数栈，继续比较。
- 括号匹配

### 堆

堆是一个完全二叉树：除了最后一层，其他层的节点个数都是满的，最后一层的节点 都靠左排列。

每个节点都必须大于等于（或小于等于）其子树中每个节点的值。

由于二叉堆的性质，可以用数组实现，数组第0位置空，那么数组中下标为i的节点的左子节点就是2i，右子节点就是2i+1，父节点是i/2

- insert，先插入数组尾部，对其进行**空穴上滤**，最坏O(logn)，平均O(1)
- delete(min or max)，先把堆顶元素和数组尾部元素交换，然后删除数组尾部元素，对堆顶元素进行**空穴下滤**，最坏O(logn)，平均O(logn)，堆顶元素与数组尾部元素交换的意义在于避免**数组空洞（即不满足完全二叉树）**
- 建堆
  - 自顶向下的建堆方式：O(nlogn)，从根结点开始，然后一个一个的把结点插入堆中。
  - 自下向上的建堆方式：O(n)，从第一个非叶子结点开始进行判断该子树是否满足堆的性质。如果满足就继续判断下一个点。否则，如果子树里面某个子结点有最大元素，则交换他们，并依次递归判断其子树是否仍满足堆性质。

堆排序（非稳定，原地）：

二叉堆的建堆需要O(N)时间，然后再执行N次deleteMin操作，每次deleteMin操作为O(logN)，将这些元素记录到另一个数组然后再复制回来(二叉堆本来底层也是用数组实现的)，复制用时O(N)，于是就得到了N个元素的排序，用时O(N+NlogN+N)，故**堆排序的时间复杂度为O(NlogN)**

priority_queue默认最大堆，若想用最小堆，传入仿函数`greater<T>`底层用的是build_heap，push_heap，pop_heap，sort_heap的函数，底层用的容器是vector

应用：定时器、合并k个有序链表、合并k个文件

### TopK/海量数据下的TopK

1. 直接全部排序（O(nlogn)，只适用于内存够的情况）：将数据全部排序，然后取排序后的数据中的第K个。

2. 局部排序（O(nk)，只适用于内存够的情况）：不再全局排序，只对前k个数排序，可以选择冒泡排序，冒k个泡即可

3. 最小堆法（一次插入O(lgk)，最差情况n个元素都插入堆，所以时间复杂度为O(nlogk)，可适用于内存不够的情况）：这是一种局部淘汰法。先读取前K个数，建立一个最小堆。然后将剩余的所有数字依次与最小堆的堆顶进行比较，如果小于或等于堆顶数据，则继续比较下一个；否则，删除堆顶元素，并将新数据插入堆中，重新调整最小堆。当遍历完全部数据后，最小堆中的数据即为最大的K个数。

4. 快速选择算法（O(n)，只使用于内存够的情况）：类似于快速排序，首先选择一个划分元，将比这个划分元大的元素放到它的前面，比划分元小的元素放到它的后面，此时完成了一趟排序。如果此时这个划分元的序号index刚好等于K，那么这个划分元以及它左边的数，刚好就是前K个最大的元素；如果index > K，那么前K大的数据在index的左边，那么就继续递归的从index-1个数中进行一趟排序；如果index < K，那么再从划分元的右边继续进行排序，直到找到序号index刚好等于K为止。这种方法就避免了对除了Top K个元素以外的数据进行排序所带来的不必要的开销，是分治法中的减治法（Reduce&Conquer），把大问题分成若干小问题，只需要解决一个小问题就可以解决大问题了。

partition时间复杂度为O(n)的证明（等比数列求和）：T = O(n)+O(n/2)+O(n/4)+...=O(2n)=O(n)

lc 215:

```c++
 int findKthLargest(vector<int>& nums, int k) {
     if (nums.empty()) return 0;
     int left = 0, right = nums.size() - 1;
     while (true) {
         int position = partition(nums, left, right);
         if (position == k - 1) return nums[position]; //每一轮返回当前pivot的最终位置，它的位置就是第几大的，如果刚好是第K大的数
         else if (position > k - 1) right = position - 1; //二分的思想
         else left = position + 1;
     }
 }

 int partition(vector<int>& nums, int left, int right) {
     int pivot = left;
     int l = left + 1; //记住这里l是left + 1
     int r = right;
     while (l <= r) {
         while (l <= r && nums[l] >= nums[pivot]) l++; //从左边找到第一个小于nums[pivot]的数
         while (l <= r && nums[r] <= nums[pivot]) r--; //从右边找到第一个大于nums[pivot]的数
         if (l <= r && nums[l] < nums[pivot] && nums[r] > nums[pivot]) {
             swap(nums[l++], nums[r--]);
         }
     }
     swap(nums[pivot], nums[r]); //交换pivot到它所属的最终位置，也就是在r的位置，因为此时r的左边都比r大，右边都比r小
     return r; //返回最终pivot的位置
 }
```

海量数据下的TopK变形问题

Hash法：如果这些数据中有很多重复的数据，可以先通过hash法，把重复的数去掉，这样可以大大减少运算量，但有可能会产生**数据倾斜问题**：有些数据重复很大，即使Hash过也没法一次性读入内存，则需要把这个Hash文件单独拎出来随即拆分，所以可以用**哈希算法分片**

如果允许分布式，可以把数据分发给多台机器，每台机器并行计算各自的TopK，最后再汇总，得到最终的TopK，比如MapReduce分布式计算框架

### 找中位数

思考快排算法，我们可以在O(n)复杂度内，得到任意元素在数组中的位置。那么任取一个数，我们可以得到有a个数大于它，有b个数小于它，如果恰好a=b，则找到中位数就是该数，这里用到的就是partition的思想，而且这是分治法中的减治法。

如果有`a<b`，则筛去所有大于等于该数的数，中位数必定位于剩下的数中，并且记录筛去了sa+=a+1个数。

如果有`a>b`，则筛去所有小于等于该数的数，中位数必定位于剩下的数中，并且记录筛去了sb+=b+1个数。

在剩余的b个数中，再任取一个数，可以得到有a个数大于它，有b个数小于它，如果恰好a+sa=b+sb，则找到中位数就是该数。

扩展：海量数据/数据流情况下怎么求中位数

维护两个堆，一个大顶堆，一个小顶堆。大顶堆中存储前半部分数据，小顶堆中存储后半部分数据，且小顶堆中的数据都大于大顶堆中的数据。

无论partition还是堆，都可以扩展到数据的x%位。比如求99%的响应时间，我们维护两个堆，一个大顶堆，一个小顶堆。假设当前总数据的个数是n，大顶堆中保存`n*99%`个数据，小顶堆中保存`n*1%`个数据。大顶堆堆顶的数据就是我们要 找的99%响应时间。

### 海量数据处理面试总结

[十道海量数据处理面试题与十个方法大总结](https://blog.csdn.net/v_JULY_v/article/details/6279498?spm=a2c4e.10696291.0.0.66b019a4vIayRB)

大哈希表扩容后很浪费空间，可以先分治，只对某个小哈希表扩容

海量数据找中位数：在一个文件中有 10G 个整数,乱序排列,要求找出中位数(内存限制为 2G)

首要思想：整数是32位的，按32位划分区间，统计各个区间的出现次数，然后定位中位数的区间，最后再定位中位数

1. 确定计数值的位数：最少需要一个64位的整数来给区间计数，因为如果10G个整数都是1，全部会映射到第一个空间，所以要存储这个出现次数需要64位
2. 确定区间数量：2G的内存，能够表示多少个64bit，就能分多少个区间。区间数位：2G / 64bit = 256M 个区间。
3. 确定区间表示范围：32bit的整数最大值为2^32-1,所以区间的范围是2^32 / 256M = 16。即这256M个区间的是：[0~15], [16~31], ... （总共256M个这样的区间）
4. 区间统计：遍历10G个整数。每读取一个整数就将此整数对应的区间+1。
5. **定位中位数区间**：从前到后对每一段的计数累加，当累加的和超过5G时停止，找出这个区段（即累加停止时达到的区段，也是中位数所在的区段）的数值范围，设为[a，a+15]，同时记录累加到前一个区段的总数，设为m。然后，释放除这个区段占用的内存。
6. **单独统计中位数区间**：再次遍历10G个整数，统计出现在区间[a,a+15]中每个值的计数，有16个数值，按照a到a+15排序。计数值变量设为n0,n1,n2,...n15
7. **定位中位数**：从中位数区间n0开始累加和，设累加和位n，当`m+n`首次大于5G时，此时定位到的[a,a+15]中a+x就是中位数

### 位图/布隆过滤器

用一个bit，0或者1来表示一个数字是否存在，如果用散列表存储1千万的数据，数据是32位的整型数，也就是需要4个字节的存储空间，那总共至少需要40MB的存储空间。如果我们用位图，数字范围在1到1亿之间，只需要1亿个二进制位，也就是12MB左右的存储空间就够了。但是数字所在的范围不能太大，否则空间消耗更大。

如果位图不开辟大空间，那就用哈希，但是有可能会哈希冲突，可以用多个哈希函数来减小冲突，但是会有误判，这就是布隆过滤器

布隆过滤器本身就是基于位图的，是对位图的一种改进。高效插入与查询，支持计数才能删除，可以用来告诉你 “**某样东西一定不存在或者可能存在**”，本质是**允许一定误差的查询**。

布隆过滤器其实是二进制向量（或者说bit数组）

- 插入时，通过k个不同的哈希函数生成多个哈希值，并对每个生成的哈希值指向的bit位置1（如果已经是1了就覆盖）
- 查询时，数据通过k个不同的哈希函数得到多个哈希值，依次判断这多个哈希值所指的bit位是否与bit数组上的对应位相同，
  - 如果有至少一位不同，则肯定不存在
  - 如果完全相同，则可能存在
- 哈希函数个数、布隆过滤器长度都需要权衡，不停加入数据后，误判率会越来越高，可能需要新开辟位图

应用场景：

- 反垃圾邮件，从数十亿个垃圾邮件列表中判断某邮箱是否垃圾邮箱；
- Google Chrome 使用布隆过滤器识别恶意 URL；
- 网页爬虫的URL去重
- Medium 使用布隆过滤器避免推荐给用户已经读过的文章；
- Google BigTable，Apache HBbase 和 Apache Cassandra 使用布隆过滤器减少对不存在的行和列的查找。
- 解决**缓存穿透**的问题。所谓的缓存穿透就是服务调用方**每次都是查询不在缓存中的数据**，这样每次服务调用都会到数据库中进行查询，如果这类请求比较多的话，就会导致数据库压力增大，这样缓存就失去了意义。

如何改进布隆过滤器的假阳性误判率？

- [scalable bloomfilter](https://haslab.uminho.pt/cbm/files/dbloom.pdf?spm=ata.21736010.0.0.71f62d5fNUA3zz&file=dbloom.pdf)
- 最开始SBF与普通的BF一样，但当插入的数据越来越多，误判率不满足用户需求时，开辟新的一层BF，后续的插入都在新层操作，如果新层插入的过多，又会再开辟一层，每一层的长度与k的值都比前一层大很多
- 查询的过程是从最新层开始的，如果最新层查到了，那么可以肯定该数据已存在，如果最新层没查到，则到次新层查找，以此类推
- 根据论文推导，从不浪费内存角度考虑，层数最好选择2

### 多阶哈希

多阶hash表实际上是一个锯齿数组，每一行是一阶，上面的元素个数多，下面的元素个数依次减少。每一行的元素个数都是素数的。

创建多阶HASH的时候，用户通过参数来指定有多少阶，每一阶最多多少个元素。采用了素数集中原理的算法来查找的。例如，假设每阶最多1000个元素，一共10阶，则算法选择十个比1000小的最大素数，从大到小排列，以此作为各阶的元素个数。通过素数集中的算法得到的10个素数分别是：997 991 983 977 971 967 953 947 941 937。可见，虽然是锯齿数组，各层之间的差别并不是很多。

先将key在第一阶内取模，看是否是这个元素，如果这个位置为空，直接返回不存在；如果是这个KEY，则返回这个位置。如果这个位置有元素，但是又不是这个key，则说明hash冲突，再到第二阶去找。循环往复。

好处：

1. hash冲突的处理非常简单；
2. 有多个桶，使得空间利用率很高，你并不需要一个很大的桶来减少冲突。
3. 可以考虑动态增长空间，不断加入新的一阶，且对原来的数据没影响。

### 倒排索引

倒排索引是一种索引方法，被用来存储在全文搜索下某个单词在一个文档或者一组文档中的存储位置的映射，常被应用于**搜索引擎**和**关键字查询**的问题中。

以英文为例，下面是要被索引的文本：

T0 = "it is what it is"  
T1 = "what is it"  
T2 = "it is a banana"  

我们就能得到下面的反向文件索引：

"a":      {2}
"banana": {2}
"is":     {0, 1, 2}
"it":     {0, 1, 2}
"what":   {0, 1}

### 跳表

跳表(skip list)类似于单链表的二分查找，有些情况甚至可以代替红黑树，因为跳表还支持**范围查找**，Redis中的有序集合就是基于跳表实现的（但有些扩展）。很多编程语言的map类型都是用红黑树实现的，跳表在标准库中还没有广泛应用。

假设单链表有n个节点，那么首先第1级索引构造一个步长为2的链表，其中每个节点除了指向后面步长为2的那个节点，也指向向下“down”的原始链表，第2级索引构造一个步长为4的链表，其中每个节点除了指向后面步长为4的那个节点，也指向向下“down”的第1级索引

![20200317221654.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200317221654.png)

跳表可以加快查询速率，查询任意数据的时间复杂度就是O(logn)，但是索引是需要空间，对于长度为n的单链表，需要再消耗O(n)的空间构造跳表，但是实际上索引只是一些指针而已，如果数据是很大的对象的话，用空间换时间还是很划算的

而且跳表的插入、删除操作的时间复杂度也是O(logn)，跳表可以用O(logn)找到待插入/删除的位置，然后用O(1)完成插入/删除

可以想象，往跳表中不断地插入/删除，跳表可能会退化为单链表，所以要及时**更新索引**。类似红黑树/AVL树的平衡操作，更新索引就是维护索引和原始链表大小之间的平衡。跳表是通过**随机函数**来维护“平衡性”。往跳表中插入数据的时候，可以选择同时将这个数据插入到某个索引层中，随机函数决定到底是哪个索引层

### 线索二叉树

一个二叉树通过如下的方法 “穿起来”：所有原本为空的右 (孩子) 指针改为指向该节点在中序序列中的后继，所有原本为空的左 (孩子) 指针改为指向该节点的中序序列的后继

线索二叉树能**线性地遍历**二叉树，从而**比递归的中序遍历更快**。使用线索二叉树也能够方便的找到一个节点的父节点，这比显式地使用父亲节点指针或者栈效率更高。这在栈空间有限，或者无法使用存储父节点的栈时很有作用（对于通过深度优先搜索来查找父节点而言)

总之，线索二叉树既可以利用空指针，又可以加快特定顺序的遍历速度。如果所用的二叉树经常需要遍历或查找节点时需要某种遍历序列中的前驱和后继，那么线索二叉树是个不错的选择

### 伸展树

伸展树保证从空树开始任意连续M次对树的操作最多花费O(MlogN)时间，不过并不保证单次操作花费Θ(N)时间，一棵伸展树的每次操作的摊还代价是O(logN)

伸展树的基本想法是,当一个节点被访问后,它就要经过一系列AVL树旋转向根推进。注意,如果一个节点很深,那么在其路径上就存在许多的节点也相对较深,通过重新构造可以使对所有这些节点的进一步访问所花费的时间变少。伸展树还不要求保留高度或平衡信息,因此它在某种程度上节省空间并简化代码

### Trie树

在计算机科学中，trie，又称前缀树或字典树，是一种有序树，用于保存关联数组，其中的键通常是字符串，属于**多模式串匹配算法**

- 根节点不包含字符，除根节点意外每个节点只包含一个字符。
- 从根节点到某一个节点，路径上经过的字符连接起来，为该节点对应的字符串。
- 每个节点的所有子节点包含的字符串不相同。

限制：

- 字符串的字符集不能太大，否则空间消耗大
- 字符串的前缀要尽量重合，否则空间消耗大

使用场景：Trie树只是**不适合精确匹配查找**，这种问题更适合用散列表或者红黑树来解决。Trie树比较适合的是**查找前缀匹配的字符串**。比如**搜索引擎**的搜索关键词提示

1、自动补全（单词自动补全）
2、拼写检查（检查单词是否拼写正确）
3、IP路由（最长前缀匹配）
4、九宫格打字预测（根据前缀预测单词）

```c++
class Trie {
public:
    Trie() {}

    void insert(string word) {
        auto root = this;
        for (const char &w : word) {
            if (!root->next[w-'a']) root->next[w-'a'] = new Trie();
            root = root->next[w-'a'];
        }
        root->is_end = true; // 最后一个节点的标记
    }

    bool search(string word) {
        auto root = this;
        for (const char &w : word) {
            if (!root->next[w-'a']) return false;
            root = root->next[w-'a'];
        }
        return root->is_end;
    }

    bool startsWith(string prefix) {
        auto root = this;
        for (const char &w : prefix) {
            if (!root->next[w-'a']) return false;
            root = root->next[w-'a'];
        }
        return true;
    }
private:
    Trie* next[26] = {nullptr};
    bool is_end = false;
};
```

### LSM树

LSM树（Log-Structured-Merge-Tree）是一种采用追加写、数据有序以及将随机 I/O 转换为**顺序 I/O**的延迟更新，批量写入硬盘的数据结构

**牺牲了小部分读性能**，而**大幅度提高了写性能**，所以很适合**写多读少**的场景，已经用于LevelDB等开源产品中。

LSM树会将所有的数据**插入、修改、删除等操作保存在内存中**，当此类操作达到一定的数据量后，再批量地写入到磁盘当中。而在写入磁盘时，会和以前的数据做**合并**。在合并过程中，并不会像B+树一样，在原数据的位置上修改，而是直接插入新的数据，从而避免了随机写。

LSM树的结构是横跨内存和磁盘的，包含memtable、immutable memtable、SSTable等多个部分。

- memtable
  - memtable是在内存中的数据结构，用以保存最近的一些更新操作，当写数据到memtable中时，会先通过WAL的方式备份到磁盘中，以防数据因为内存掉电而丢失。
  - **预写式日志（Write-ahead logging，缩写 WAL）**是关系数据库系统中用于提供原子性和持久性（ACID属性中的两个）的一系列技术。在使用WAL的系统中，所有的修改在提交之前都要先写入log文件中。
  - memtable可以使用跳跃表或者搜索树等数据结构来组织数据以保持数据的有序性。当memtable达到一定的数据量后，memtable会转化成为immutable memtable，同时会创建一个新的memtable来处理新的数据。
- immutable memtable
  - immutable memtable在内存中是不可修改的数据结构，它是将memtable转变为SSTable的一种中间状态。
  - 目的是为了在转存过程中不阻塞写操作。写操作可以由新的memtable处理，而不用因为锁住memtable而等待。
- SSTable
  - **SSTable(Sorted String Table)即为有序键值对集合**，是LSM树组在磁盘中的数据的结构。如果SSTable比较大的时候，还可以根据键的值建立一个索引来加速SSTable的查询

CRUD

- 增/写：首先需要通过WAL将数据写入到磁盘Log中，防止数据丢失，然后数据会被写入到内存的memtable中，这样一次写操作即已经完成了，只需要1次磁盘IO，再加1次内存操作。相较于B+树的多次磁盘随机IO，大大提高了效率。随后这些在memtable中的数据会被批量的合并到磁盘中的SSTable当中，将随机写变为了顺序写。
- 删：并不需要像B+树一样，在磁盘中的找到相应的数据后再删除，只需要在memtable中插入一条数据当作标志，如delKey:1933，当读操作读到memtable中的这个标志时，就会知道这个key已被删除。随后在日志合并中，这条被删除的数据会在合并的过程中一起被删除。
- 改：与删除操作类似，都是只操作memtable，写入一个标志，随后真正的更新操作被延迟在合并时一并完成。
- 查：相较于B+树慢很多，读操作需要依次读取memtable、immutable memtable、SSTable0、SSTable1......。需要反序地遍历所有的集合，又因为写入顺序和合并顺序的缘故，序号小的集合中的数据一定会比序号大的集合中的数据新。所以在这个反序遍历的过程中一旦匹配到了要读取的数据，那么一定是最新的数据，只要返回该数据即可。但是如果一个数据的确不在所有的数据集合中，则会白白得遍历一遍。可用布隆过滤器加速查询，也可以用索引加速查询

合并方式

- size-tiered策略：是HBase采用的合并策略，具体内容是当某个规模的集合达到一定的数量时，将这些集合合并为一个大的集合。比如有5个50个数据的集合，那么就将他们合并为一个250个数据的集合。这种策略有一个缺点是当集合达到一定的数据量后，合并操作会变得十分的耗时。
- leveled策略：是LevelDB和RocksDB采用的合并策略，size-tiered策略因为会产生大数据量的集合，所以会造成**突发的IO和CPU资源的消耗**，所以leveled策略使用了分层的数据结构来代替原来的大数据集合。leveled策略将集合的大小限制在一个小的范围内如5MB，而且将集合划分为不同的层级。每一个层级的集合总大小是固定且递增的。如第一层为50MB，第二层为500MB...。当某一层的数据集合大小达到上限时，就会从这一层中选出一个文件和下一层合并，或者直接提升到下一层。如果在合并过程中发现了数据冲突，则丢弃下一层的数据，因为低层的数据总是更新的。同时leveled策略会限制，除第一层外。其他的每一层的键值都不会重复。这是通过合并时剔除冗余数据实现的，以此来加速在同一层内数据的线性扫描速度。

### AC自动机

Trie树跟AC自动机之间的关系，就像单串匹配中朴素的串匹配算法，跟KMP算法之间的关系一样，只不过前者针对的是多模式串而已

### AVL树与红黑树

两者都是BST的变形，把插入和删除的复杂度降低到了O(logn)，最坏情况下也是，这样就避免了BST的插入和删除退化到O(n)

AVL树保证任意节点的子树高度差不大于1，是严格平衡的，而红黑树放弃了这个严格平衡的条件，只追求大致平衡，每次插入时**最多只需要三次旋转**即可达到平衡，更加高效。红黑树的高度只比AVL树的高度(logn)仅仅大了一倍

AVL树在查找上的效率可能要快于红黑树，但是红黑树在插入和删除上在统计意义上优于AVL树，**AVL树为了维持严格平衡，可能需要大量的计算**

Treap、Splay Tree也是平衡二叉查找树，但是性能不稳定

### 一致性哈希算法

普通哈希算法负载均衡，key % 节点总数 = Hash节点下标，最大的弊端是当节点数量变化时，需要数据搬迁，扩展性与容错能力不佳

一致性哈希将整个哈希值空间组织成一个虚拟的**圆环**，如假设某哈希函数H的值空间为0-2^32-1（即哈希值是一个32位无符号整形）

将各个服务器使用Hash进行一个哈希，具体可以选择服务器的ip或主机名作为关键字进行哈希，这样每台机器就能确定其在哈希环上的位置

将数据key使用相同的函数Hash计算出哈希值，并确定此数据在环上的位置，从此位置沿环顺时针“行走”，第一台遇到的服务器就是其应该定位到的服务器。

![一致性哈希算法](https://user-gold-cdn.xitu.io/2018/4/26/162ffff01dde9b2b?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

某服务器节点失效（容错能力提升）：只会影响此节点到前一台节点（逆时针行走）之间的数据，这些数据会被**重定位**到顺时针下一个节点

插入某服务器节点（扩展能力提升）：只会影响此节点到前一台节点（逆时针行走）之间的数据，这些数据会被**重定位**到此节点

解决**数据倾斜**问题：节点分布不均匀会造成数据倾斜，进而可能引起**缓存雪崩**，把集群所有节点一一打垮，造成**节点雪崩**，所以引入**虚拟节点**机制，对每个服务节点计算多个哈希，这样节点分布更加均匀，数据哈希也更均匀

Google 的论文实现了**带有负载边界**的一致性 Hash 算法：简单来说，就是在一致性哈希算法的基础上，把每个处理节点看成一个桶，并设置一个负载边界，当处理的请求大于桶的负载边界时，当前请求按顺时针方向顺延至下个处理节点（桶），以此类推

### 二叉树三种遍历方式的非递归实现

二叉树的前序遍历非递归实现

- 根据前序遍历访问的顺序，优先访问根结点，然后再分别访问左孩子和右孩子。
- 即对于任一结点，其可看做是根结点，因此可以直接访问，访问完之后，若其左孩子不为空，按相同规则访问它的左子树；当访问其左子树时，再访问它的右子树。因此其处理过程如下：
- 对于任一结点P：
  - 1)访问结点P，并将结点P入栈;
  - 2)判断结点P的左孩子是否为空，若为空，则取栈顶结点并进行出栈操作，并将栈顶结点的右孩子置为当前的结点P，循环至1);若不为空，则将P的左孩子置为当前的结点P;
  - 3)直到P为NULL并且栈为空，则遍历结束。

```c++
vector<int> preorderTraversal(TreeNode *root)
{
    if (root == nullptr)
        return vector<int>();
    vector<int> res;
    stack<TreeNode *> s;
    TreeNode *cur = root;
    while (cur || !s.empty())
    {
        while (cur)
        {
            res.push_back(cur->val);
            s.push(cur);
            cur = cur->left;
        }
        if (!s.empty())
        {
            cur = s.top();
            s.pop();
            cur = cur->right;
        }
    }
    return res;
}
```

二叉树的中序遍历非递归实现

- 根据中序遍历的顺序，对于任一结点，优先访问其左孩子，而左孩子结点又可以看做一根结点，然后继续访问其左孩子结点，直到遇到左孩子结点为空的结点才进行访问，然后按相同的规则访问其右子树。因此其处理过程如下：
- 对于任一结点P，
  - 1)若其左孩子不为空，则将P入栈并将P的左孩子置为当前的P，然后对当前结点P再进行相同的处理；
  - 2)若其左孩子为空，则取栈顶元素并进行出栈操作，访问该栈顶结点，然后将当前的P置为栈顶结点的右孩子；
  - 3)直到P为NULL并且栈为空则遍历结束

```c++
vector<int> inorderTraversal(TreeNode *root)
{
    if (root == nullptr)
        return vector<int>();
    vector<int> res;
    stack<TreeNode *> s;
    TreeNode *cur = root;
    while (cur || !s.empty())
    {
        while (cur)
        {
            s.push(cur);
            cur = cur->left;
        }
        cur = s.top();
        res.push_back(cur->val);
        s.pop();
        cur = cur->right;
        }
    }
    return res;
}
```

二叉树的后序遍历是最难的，取巧的方法是先做前序遍历，然后把输出数组翻转即可，还有一种方法是记录上个访问的节点

仿照上面的写法：

```c++
vector<int> postorderTraversal(TreeNode *root)
{
    if (root == nullptr)
        return vector<int>();
    vector<int> res;
    stack<TreeNode *> s;
    TreeNode *cur = root;
    TreeNode *pre = nullptr;
    while (cur || !s.empty())
    {
        while (cur)
        {
            s.push(cur);
            cur = cur->left;
        }
        cur = s.top();
        if (!cur->right || pre == cur->right)
        {
            res.push_back(cur->val);
            pre = cur;
            cur = nullptr;
            s.pop();
        }
        else
        {
            cur = cur->right;
        }
    }
    return res;
}
```

感觉更好理解的写法：

- 要保证根结点在左孩子和右孩子访问之后才能访问，因此对于任一结点P，先将其入栈。
- 如果P不存在左孩子和右孩子，则可以直接访问它；
- 或者P存在左孩子或者右孩子，但是其左孩子和右孩子都已被访问过了，则同样可以直接访问该结点。因为访问顺序一定是：左（如果有的话）-右（如果有的话）-根。
- 若非上述两种情况，则将P的右孩子和左孩子依次入栈，这样就保证了每次取栈顶元素的时候，左孩子在右孩子前面被访问，左孩子和右孩子都在根结点前面被访问。

```c++
class Solution {
public:
    vector<int> postorderTraversal(TreeNode *root){
        vector<int> ans;
        if (root == nullptr) return ans;
        stack<TreeNode *> s;
        TreeNode *cur;
        TreeNode *pre = nullptr;
        s.push(root);
        while (!s.empty()){
            cur = s.top();
            if ((!cur->left && !cur->right) ||
                (pre && (pre == cur->left || pre == cur->right))) {
                ans.push_back(cur->val);
                pre = cur;
                s.pop();
            } else {
                if (cur->right) s.push(cur->right);
                if (cur->left) s.push(cur->left);
            }
        }
        return ans;
    }
};
```

### 汉诺塔问题

[汉诺塔的图解递归算法](https://www.cnblogs.com/dmego/p/5965835.html)

实现这个算法可以简单分为三个步骤：

　　　　（1）     把n-1个盘子由A 移到 B；

　　　　（2）     把第n个盘子由 A移到 C；

　　　　（3）     把n-1个盘子由B 移到 C；

从这里入手，在加上上面数学问题解法的分析，我们不难发现，移到的步数必定为奇数步：

　　　　（1）中间的一步是把最大的一个盘子由A移到C上去；

　　　　（2）中间一步之上可以看成把A上n-1个盘子通过借助辅助塔（C塔）移到了B上，

　　　　（3）中间一步之下可以看成把B上n-1个盘子通过借助辅助塔（A塔）移到了C上；

```c++
int cnt = 0;
void hanoi(int n, char A, char B, char C) {
    if (n == 1) { // 当前最大的圆盘，从A移动到C
        cout << "The " << ++cnt << "th move: plate " << n << ", from " << A << ", to " << C << endl;
    } else {
        hanoi(n-1, A, C, B); // 递归，把n-1个圆盘移动到B上，B是辅助塔
        cout << "The " << ++cnt << "th move: plate " << n << ", from " << A << ", to " << C << endl; // 把A塔上编号为n的圆盘移动到C上
        hanoi(n-1, B, A, C); // 递归，把B塔上n-1个圆盘移动到C上，A是辅助塔
    }
}
int main() {
    hanoi(3, 'A', 'B', 'C');
}
```

### 数学算法

#### 试除法判定质数

```c++
bool is_prime(int x)
{
    if (x < 2) return false;
    for (int i = 2; i <= x / i; i ++ )
        if (x % i == 0)
            return false;
    return true;
}
```

#### 快速计算的素数

筛选法：先确定一个范围，然后把2的所有倍数去掉、把3的所有倍数去掉...、

```c++
int primes[N], cnt;     // primes[]存储所有素数
bool st[N];         // st[x]存储x是否被筛掉

void get_primes(int n)
{
    for (int i = 2; i <= n; i ++ )
    {
        if (st[i]) continue;
        primes[cnt ++ ] = i;
        for (int j = i + i; j <= n; j += i)
            st[j] = true;
    }
}
```

#### 将一个正整数分解质因数

```c++
#include <stdio.h>

int main()
{
    int n; // 用户输入的整数
    int i; // 循环标志
    printf("输入一个整数：");
    scanf("%d", &n);
    printf("%d=", n);
    // n>=2才执行下面的循环
    for (i = 2; i <= n; i++)
    {
        while (n != i)
        {
            if (n % i == 0)
            {
                printf("%d*", i);
                n = n / i;
            }
            else
                break;
        }
    }
    printf("%d\n", n);
    return 0;
}
```

#### 最大公约数/gcd/欧几里得算法

```c++
int gcd(int a, int b)
{
    return b ? gcd(b, a % b) : a;
}
```

#### 求一个数的平方根

给定一个数x，求满足`x-xn^2 < eps`的xn

二分法，没啥好说的，注意fabs需要`#include <cmath>`

```c++
double sqrt_binary(double k, double eps){
    if(k < 0) return -1;
    if(k == 0) return 0;
    double left = 0.0;
    double mid = 0.0;
    double right = k > 1 ? k : 1; // 如果要开方数小于1，则right置为1
    while(fabs(left*left - k) > eps){
    // while(fabs(left - k / left) > eps){
        // 这里的判断条件是xn - x/xn < eps，而不是用xn^2 - x < eps，看文章说是可以防止数值溢出，但我不确定这样会不会损失精度？
        mid = (left + right) / 2;
        if (mid < k / mid) // 防止数值溢出
            left = mid;
        else right = mid;
    }
    return left;
}
```

牛顿法

令`f(x)=x^2-k`，这是个二次函数，与x轴的交点即为最准确的根号值，可以在不断迭代的过程中，（从右往左）慢慢逼近这个值，前一个值(x0,x0^2)的切线与x轴的交点即为x1，满足x0-x1 = f(x0)/f'(x0)，而f(x0)=x0^2-k，f'(x0)=2x0，整理得`x1=0.5*(x0+k/x0)`

```c++
double sqrt_newton(double k, double eps){
    if(k < 0) return -1;
    if(k == 0) return 0;
    double temp = k > 1 ? k/2 : 1;
    while(fabs(temp*temp - k) > eps){
    // while(fabs(left - k / left) > eps){
        // 这里的判断条件是xn - x/xn < eps，而不是用xn^2 - x < eps，看文章说是可以防止数值溢出，但我不确定这样会不会损失精度？
        temp = (temp + k / temp) * 0.5; // x1=0.5*(x0+k/x0)
    }
    return temp;
}
```

#### 位运算

- 利用或操作 `|` 和空格将英文字符转换为小写
- 利用与操作 `&` 和下划线将英文字符转换为大写
- 利用异或操作 `^` 和空格进行英文字符大小写互换

```c++
('a' | ' ') = 'a'
('A' | ' ') = 'a'

('b' & '_') = 'B'
('B' & '_') = 'B'

('d' ^ ' ') = 'D'
('D' ^ ' ') = 'd'
```

以上操作能够产生奇特效果的原因在于 ASCII 编码。字符其实就是数字

判断两个数是否异号

```c++
int x = -1, y = 2;
bool f = ((x ^ y) < 0); // true

int x = 3, y = 2;
bool f = ((x ^ y) < 0); // false
```

n&(n-1) 这个操作是算法中常见的，作用是消除数字 n 的二进制表示中的最后一个 1。其核心逻辑就是，n - 1 一定可以消除最后一个 1，同时把其后的 0 都变成 1，这样再和 n 做一次 & 运算，就可以仅仅把最后一个 1 变成 0 了。

计算汉明权重（Hamming Weight）：就是让你返回 n 的二进制表示中有几个 1。因为 n & (n - 1) 可以消除最后一个 1，所以可以用一个循环不停地消除 1 同时计数，直到 n 变成 0 为止。

```c++
int hammingWeight(uint32_t n) {
    int res = 0;
    while (n != 0) {
        n = n & (n - 1);
        res++;
    }
    return res;
}
```

判断一个数是2的幂

因为2的幂在32个bit（int型）上只有一个是1，所以和x-1与一下即可

```c++
bool isPowerOfTwo(int n) {
    if (n <= 0) return false;
    return (n & (n - 1)) == 0;
}
```

#### 判断n!末尾有多少个0

- 从"那些数相乘可以得到10"这个角度，问题就变得比较的简单了。
- 如果N的阶乘为K和10的M次方的乘积，那么N!末尾就有M的0。
- 只有偶数和5相乘才能得到10，所以考察有多少个5
- `n!=1*2*3*4*5*6*7*8*9*(5*2)*....*24*(5*5)*...`
  - 能被5（5^1）整除的提供1个0
  - 能被25（5^2）整除的提供2个0
  - 能被125（5^3）整除的提供3个0
  - 能被625（5^4）整除的提供4个0
  - ....
  - 所以 结果= n/5 + n/25 + n/125 + n/625

```c++
int tailZero(int n){
    int cnt = 0;
    while(n /= 5){
        cnt += n;
    }
    return cnt;
}
```

#### 洗牌算法

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

#### 蓄水池算法

给出一个海量数据流，这个数据流的长度很大或者未知。并且对该数据流中数据只能访问一次。请写出一个随机选择算法，使得数据流中所有数据被选中的概率相等。或者也可以这么说：
要求从N个元素中随机的抽取k个元素，其中N的大小未知且很大

编程珠玑里面有这个题，这里给个容易理解的伪代码

```c++
array S[n];    //source, 0-based
array R[k];    // result, 0-based
integer i, j;

// fill the reservoir array
for each i in 0 to k - 1 do
        R[i] = S[i]

// replace elements with gradually decreasing probability
for each i in k to n do
        j = random(0, i);   // important: inclusive range
        if j < k then
                R[j] = S[i]
```

可以用数学归纳法证明正确性

假设**当前**数据序列的规模为n，需要采样的数量为k，算法思路大致如下：

1. 首先构建一个可容纳k个元素的数组，将序列的前k个元素放入数组中。
2. 然后从第k+1个元素开始，以k/n的概率来决定该元素是否被替换到数组中，数组中的元素被替换的概率是相同的（对于数据流，n是逐步增大的）。
    具体做法：在[0, n]范围内取以随机数d，若d的落在[0, k-1]范围内，则用第n个数据替换蓄水池中的第d个数据。（从第0个数据开始）
3. 当遍历完所有元素之后，数组中剩下的元素即为所需采取的样本。

算法的精妙之处在于：当处理完所有的数据时，蓄水池中的每个数据都是以k/N的概率获得的。

#### 如何等概率挑出大文件中的一行

Amazon: 一个文件中有很多行，不能全部放到内存中，如何等概率的随机挑出其中的一行？

答案：先将第一行设为候选的被选中的那一行，然后一行一行的扫描文件。假如现在是第 K 行，那么第 K 行被选中踢掉现在的候选行成为新的候选行的概率为 1/K。用一个随机函数看一下是否命中这个概率即可。命中了，就替换掉现在的候选行然后继续，没有命中就继续看下一行

#### 如何等概率挑选大文件中的N行中文

问题：给你一个 Google 搜索日志记录，存有上亿挑搜索记录（Query）。这些搜索记录包含不同的语言。随机挑选出其中的 100 万条中文搜索记录。假设判断一条 Query 是不是中文的工具已经写好了。

答案：其实是上题的变形，假设你一共要挑选 N 个 Queries，设置一个 N 的 Buffer，用于存放你选中的 Queries。对于每一条飞驰而过的
Query，按照如下步骤执行你的算法：

1. 如果非中文，直接跳过
2. 如果 Buffer 不满，将这条 Query 直接加入 Buffer 中
3. 如果 Buffer 满了，假设当前一共出了过 M 条中文 Queries，用一个随机函数，以 N / M 的概率来决定这条 Query 是否能被选中留下。
    1. 如果没有选中，则跳过该 Query，继续处理下一条 Query
    2. 如果选中了，则用一个随机函数，以 1 / N 的概率从 Buffer 中随机挑选一个 Query 来丢掉，让当前的 Query 放进去。

#### 如何判断一个点P是否在三角形ABC内

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

#### rand7构造rand5/rand5构造rand7

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

#### 抛硬币问题

一硬币，一面向上概率0.7，一面0.3，如何公平？

抛两次，正反A胜，反正B胜。

两个人轮流抛硬币，先抛到正面的赢，问先抛的人赢的概率

2/3。每一轮抛硬币，A先抛赢得概率是1/2，B后抛赢得概率是（1/2）*（1/2）= 1/4。那么每一轮A赢得概率都是B赢得概率的2倍，总概率为1,所以A赢的概率是2/3。

两个人坐在一张桌子的两边，轮流往桌子上放硬币，硬币不能重叠，谁放不下谁就输了。问先手有办法获胜吗？

如果硬币足够大，一个硬币就盖住桌子，那么先手必赢。现在进一步，硬币小了，一个硬币不能盖住桌子了，只要桌子是对称的，不管桌子大小，也不管桌子是什么形状的，先手只要先占住了对称中心，以后每次放硬币的地方都是对手所放的地方的对称点，那么对手有地方放时先手一定有地方放硬币，先手就能保证胜券在握

#### 烧香

两根香，一根烧完1小时，如何测量15分钟

开始时一根香两头点着，一根香只点一头，两头点着的香烧完说明过去了半小时，这时将只点了一头的香另一头也点着，从这时开始到烧完就是15分钟。

#### 博弈论——海盗分金币

[博弈论之五个海盗分金币的问题(以及推广到更多的海盗)](https://www.jianshu.com/p/ab2f71802733)

5个海盗抢得100枚金币，他们按抽签的顺序依次提方案：首先由1号提出分配方案，然后所有5人表决(包括自己)，超过半数同意方案才被通过，否则他将被扔入大海喂鲨鱼，依此类推

两个海盗--毫无悬念：很显然,当只有两个海盗的时候,一号一定会死,因为首先只要第一个海盗死了,剩下的一个便能获得全部的金币，所以分配方案是[0, 100]

三个海盗--无奈的选择：当存在三个海盗的时候,原来的两个海盗时的一号变成了二号,此时二号知道了,如果一号被投死,那么毫无悬念的,他没有任何活路,所以他一定会同意一号的选择，一号为了利益最大化，分配方案是[100, 0, 0]

四个海盗--稍稍讨好就可以：四个海盗时,此时的一号明白了此时的二号是讨好不了的.因为自己死了二号就一定能得到全部100枚金币,所以干脆不讨好,给他0枚金币吧.而此时除了自己的票还差两票,那么只要讨好三号和四号获得这两票就好,三号和四号相当容易讨好的,因为一号死了,他们就只能得到空气(三个海盗的结果为(100, 0, 0)),那么给他一块金币就好啦，所以分配方案是[98, 0, 1, 1]

五个海盗--照本宣科：相同的原理,现在的一号需要2票就能保证存活,首先二号是不考虑了给金币了,不管给多少都反对的,三号给一个金币就行,然后还差一票,只要给==四号或五号==其中一个两枚金币,另一个不给,就可以.如果都给1个的话，他俩获得的金币就与四个海盗一样了，他们是心狠手辣的，在利益最大化的情况下希望更多人死，所以第一个海盗一定不能选择11，而应该20或02，但这里要注意一下,此时的分歧已经产生,后面的推广推理中会用到，结果: (97, 0, 1, 2, 0)或(97, 0, 1, 0, 2)

#### 赛马

64匹马，8个跑道，选跑最快的4匹马至少需要比赛多少次。

锦标赛排序：sum = 11

第一步：首先每8匹马跑一次，总共需要8次，假设结果中A1>A2>A3>......,B1>B2>B3>....等。 sum=8；
第二步：这8组中的第一名拉出来跑一次，那么这次最快的是总的第一名，假设是A1，同时假设B1>C1>D1。这时还要角逐2,3,4名，那这一轮中的第五到第八组都可以直接舍弃，因为他们所有的马一定进不了前4名。sum=9。
第三步：从A组中选A2，A3，A4，B组中B1，B2，B3，C组中C1，C2，D组中D1，这些才有资格角逐2,3,4名。总共9匹马，这时需要再比赛两次。 sum=11。

（但是如果第10轮选择A4不上场，而A3获得了第4名，那么A4就不需要比赛了，这样sum=10）。

#### 砝码称重

有一个天平，九个砝码，一个轻一些，用天平至少几次能找到轻的？

至少2次：第一次，一边3个，哪边轻就在哪边，一样重就是剩余的3个；第二次，一边1个，哪边轻就是哪个，一样重就是剩余的那个；

有十组砝码每组十个，每个砝码重10g，其中一组每个只有9g，有能显示克数的秤最少几次能找到轻的那一组砝码？

将砝码分组1~10，第一组拿一个，第二组拿两个以此类推。。第十组拿十个放到秤上称出克数x，则y = 550 - x，第y组就是轻的那组

#### 药瓶毒白鼠

有1000个一模一样的瓶子，其中有999瓶是普通的水，有1瓶是毒药。任何喝下毒药的生命都会在一星期之后死亡。现在你只有10只小白鼠和1个星期的时间，如何检验出哪个瓶子有毒药？

首先一共有1000瓶，2的10次方是1024，刚好大于1000，也就是说，1000瓶药品可以使用10位二进制数就可以表示。从第一个开始：

第一瓶 ：       00 0000 0001

第二瓶：        00 0000 0010

第三瓶：        00 0000 0011

……

第999瓶：       11 1111 0010

第1000瓶：     11 1111 0011

需要十只老鼠，如果按顺序编号，ABCDEFGHIJ分别代表从低位到高位每一个位。 每只老鼠对应一个二进制位，如果该位上的数字为1，则给老鼠喝瓶里的药。

观察，若死亡的老鼠编号为：ACFGJ，一共死去五只老鼠，则对应的编号为  10 0110 0101，则有毒的药品为该编号的药品，转为十进制数为：613号。

#### 犯人猜颜色

一百个犯人站成一纵列，每人头上随机带上黑色或白色的帽子，各人不知道自己帽子的颜色，但是能看见自己前面所有人帽子的颜色．
然后从最后一个犯人开始，每人只能用同一种声调和音量说一个字：”黑”或”白”，
如果说中了自己帽子的颜色，就存活，说错了就拉出去斩了，
说的答案所有犯人都能听见，
是否说对，其他犯人不知道，
在这之前，所有犯人可以聚在一起商量策略，
问如果犯人都足够聪明而且反应足够快，100个人最大存活率是多少？

最大存活率的策略如下：

- 最后一个人如果看到奇数顶黑帽子报“黑”否则报“白”，他死的概率是50%，这个没办法
- 其他人记住这个值（实际是黑帽奇偶数），在此之后当再听到黑时，黑帽数量减一
- 从倒数第二人开始，就有两个信息：记住的值与看到的值，相同报“白”，不同报“黑”
- 最后：99人能100%存活，1人50%能活

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
            // 如果当前记录已存在，则先删除，最后再添加到链表头部
            recent.erase(position[key]); // 从链表中删除
        }
        if(recent.size() >= capacity){
            // 超过缓存，删除最老的记录
            position.erase(recent.back().first); // 按照pair.first，即hash的key来删除pair
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
    cout << cache.get(1) << ", isFound:" << cache.isFound << endl;
    cout << cache.get(5) << ", isFound:" << cache.isFound << endl;

}
```

### 四大算法

贪心算法

- 很符合直觉
- 正确性证明很复杂，需要大量数学推导，但无需那么严格

分治算法

- 统计数组中的逆序对（剑指offer第51题）
- 二维平面上有n个点，如何快速计算出两个距离最近的点对?
- 有两个`n*n`的矩阵A，B，如何快速求解两个矩阵的乘积`C=A*B`?
- 分治思想在海量数据上有很大应用价值，MapReduce的本质就是分治思想

回溯算法

数独、八皇后（剑指offer第38题）、0-1背包、图的着色、旅行商问题、全排列、正则表达式（剑指offer第19题）

动态规划

阶段、决策、最优子结构、无后效性

适合用来求解最优问题，比如求最大值、最小值等等。它可以非常显著地降低时间复杂度，提高代码的执行效率

### 图论

拓扑排序，从入度为0的顶点开始，然后减少当前定点相连顶点的入度，用队列

dijkstra，实际上是动态规划，时间复杂度就是O(E*logV)，用斐波那契堆更快，也要用最小堆

### 闫式dp分析法

![yandp](../image/yandp.jpg)

![yanDP](../image/yanDP.png)

动态规划其实是在有限集中寻找最值问题（max、min、count）

状态表示：化零为整

状态计算：化整为零，每一步都很严谨

集合划分依据：寻找最后一个不同点

集合划分原则：不重复（如果是求最值，可以允许重复）、不漏

所有dp的优化，都是对代码做等价变形

### 石子合并问题

设有N堆石子排成一排，其编号为1，2，3，…，N。

每堆石子有一定的质量，可以用一个整数来描述，现在要将这N堆石子合并成为一堆。

每次只能合并相邻的两堆，合并的代价为这两堆石子的质量之和，合并后与这两堆石子相邻的石子将和新堆相邻，合并时由于选择的顺序不同，合并的总代价也不相同。

例如有4堆石子分别为 1 3 5 2， 我们可以先合并1、2堆，代价为4，得到4 5 2， 又合并 1，2堆，代价为9，得到9 2 ，再合并得到11，总代价为4+9+11=24；

如果第二步是先合并2，3堆，则代价为7，得到4 7，最后一次合并代价为11，总代价为4+7+11=22。

问题是：找出一种合理的方法，使总的代价最小，输出最小代价。

输入格式
第一行一个数N表示石子的堆数N。

第二行N个数，表示每堆石子的质量(均不超过1000)。

输出格式
输出一个整数，表示最小代价。

数据范围
1≤N≤300
输入样例：
4
1 3 5 2
输出样例：
22

![stonemergeyandp](../image/stonemergeyandp.png)

集合：将[i,j]合并成一堆的方案的集合

属性：min

集合划分：左边i，右边j-i，i可以取1~j-1

区间的最小值=左边最小值+右边最小值

状态转移：f[i][j] = f[i][k] + f[k+1][j] + s[j] - S[i-1]，S为前缀和，这样省掉了中间遍历子区间

区间dp问题一般是先枚举长度，再枚举左端点

```c++
#include <iostream>
using namespace std;
const int N = 310;
int n;
int s[N]; // 前缀和
int f[N][N];
int main(){
    cin >> n;
    for(int i = 1; i <= n; ++i) cin >> s[i], s[i] +=s[i-1];
    for(int len = 2; len <= n; ++len){ // 枚举所有区间长度，所以从2开始
        for(int i = 1; i + len - 1 <= n; ++i){// 再枚举左端点
            int j = i + len - 1; // 右端点
            f[i][j] = 1e8;
            for(int k = i; k < j; ++k){
                f[i][j] = min(f[i][j], f[i][k] + f[k+1][j] + s[j] - s[i-1]);
            }
        }
    }
    cout << f[1][n] << endl;
    return 0;
}
```

### 鹰蛋问题

### 背包问题

[额，没想到，背包问题解题也有套路。。。](https://mp.weixin.qq.com/s/FQ0LCROtEQu3iBZiJb0VBw)

[背包九讲专题](https://www.bilibili.com/video/av33930433/)

#### 01背包问题：每件物品只能用一次

有 N 件物品和一个容量是 V 的背包。每件物品只能使用一次。

第 i 件物品的体积是 vi，价值是 wi。

求解将哪些物品装入背包，可使这些物品的总体积不超过背包容量，且总价值最大。
输出最大价值。

输入格式
第一行两个整数，N，V，用空格隔开，分别表示物品数量和背包容积。

接下来有 N 行，每行两个整数 vi,wi，用空格隔开，分别表示第 i 件物品的体积和价值。

输出格式
输出一个整数，表示最大价值。

数据范围
0 < N,V≤1000
0 < vi,wi≤1000

输入样例
4 5
1 2
2 4
3 4
4 5

输出样例：
8

物品数量n，背包总容量m，v是关于物品的volumn数组，w是关于物品的worth数组，

二维状态f[i][j]指前i个物品放入体积j的背包的最大价值，最后输出f[n][m]

如果不装下当前物品，那么前i个物品的最佳组合和前i-1个物品的最佳组合是一样的

如果装下当前物品，那么是前i-1个物品的最佳组合加上第i个物品的价值

转移方程：`f[i][j] = max{f[i-1][j], f[i-1][j-v[i]] + w[i]}`

闫式dp分析法：

- 问题描述：01背包问题的所有空间是2^n，现在要找最大价值的方案，所以是有限集的最值问题，当然这可以用dfs来做，但是指数级别不现实
- 状态表示：对于如01背包问题这种选择问题，f(i,j)第一维一般是前i个物品，第二维是限制
  - 集合：所有只考虑前i个物品，且总体积不超过j的选法集合
  - 属性：max
- 状态计算：最后一个不同点就是**选不选第i物品**

![01packyandp](../image/01packyandp.png)

二维空间的版本：

```c++
#include <iostream>
using namespace std;
const int N = 1010;
int n, m;
int v[N];
int w[N];
int f[N][N];
int main(){
    cin >> n >> m;
    for(int i = 1; i <= n; ++i) cin >> v[i] >> w[i];
    for(int i = 1; i <= n; ++i){
        for(int j = 0; j <= m; ++j){
            f[i][j] = f[i-1][j];    // 左半边子集
            if(j >= v[i]){          // 右半边子集是选择第i件物品，肯定得小于当前容量j
                f[i][j] = max(f[i][j], f[i-1][j-v[i]] + w[i]);
            }
        }
    }
    cout << f[n][m] << endl;
    return 0;
}
```

优化空间

- f[i][]只与f[i-1][]有关，所以可以用滚动数组，空间降为一维，所以是`f[j]=f[j]`，可省略
- 但是要从后往前（从大到小），因为当循环到f[j]时，f[j-v[i]]是更小的状态，此时没有被更新，所以正好表示**上一层的状态f[i-1][j-v[i]]**
- 如果从前往后，当循环到f[j]时，此时的f[j-v[i]]是当前层的，已经被更新了，所以是**这层的状态f[i][j-v[i]]**，所以不满足转移方程，所以必须从后往前
- 于是`for(int j = m; j >= v[i]; --j)`，其中把if放在了for判断中

```c++
#include <iostream>
using namespace std;
const int N = 1010;
int n, m;
int v[N];
int w[N];
int f[N];
int main(){
    cin >> n >> m;
    for(int i = 1; i <= n; ++i) cin >> v[i] >> w[i];
    for(int i = 1; i <= n; ++i){
        for(int j = m; j >= v[i]; --j){
            f[j] = max(f[j], f[j-v[i]] + w[i]);
        }
    }
    cout << f[m] << endl;
    return 0;
}
```

为什么最后f[m]即为答案？初始化时把f[i]都置为0，f[i]的状态一定从f[i-1]转移而来，如果n个物品用了k体积（`k<m`)时总价值最大，那么f[m]=f[m-1]=...=f[k]，故为最大

如果题目要求体积恰为m时，只需要初始化时令f[0]=0，其他f[i]=-INF，这样可以保证从f[0]转移过来

#### 完全背包问题：每件物品可以用无限次

闫式dp分析法

01背包问题的f(i,j)的集合划分：不选它（0）、选它（1）

完全背包问题的f(i,j)的集合划分：不选它（0）、选它一次（1）、选它两次（2）、...

这也满足不重复不漏的

![fullpackyandp](../image/fullpackyandp.png)

状态转移方程：

`f[i][j]=max(f[i-1][j], f[i-1][j-v[i]]+w[i], f[i-1][j-2*v[i]]+2*w[i], ....)`

根据图中的推导后，可以化简为：

`f[i][j]=max(f[i-1][j], f[i][j-v[i]]+w[i])`

于是二维空间的代码如下：

```c++
#include <iostream>
using namespace std;
const int N = 1010;
int n, m;
int v[N], w[N];
int f[N][N];
int main(){
    cin >> n >> m;
    for(int i = 1; i <= n; ++i) cin >> v[i] >> w[i];
    for(int i = 1; i <= n; ++i){
        for(int j = v[i]; j <= m; ++j){
            f[i][j] = f[i-1][j];
            if(j >= v[i]) f[i][j] = max(f[i][j], f[i][j-v[i]] + w[i]);
        }
    }
    cout <<  f[n][m];
    return 0;
}
```

再优化成一维数组：

`f[j]=max(f[j], f[j-v[i]])`

注意，优化后的状态转移和01背包问题的顺序相反，f[i][j]与f[i][j-v[i]]有关，所以得从前往后遍历

```c++
#include <iostream>
using namespace std;
const int N = 1010;
int n, m;
int v[N], w[N];
int f[N];
int main(){
    cin >> n >> m;
    for(int i = 1; i <= n; ++i) cin >> v[i] >> w[i];
    for(int i = 1; i <= n; ++i){
        for(int j = v[i]; j <= m; ++j){
            f[j] = max(f[j], f[j-v[i]] + w[i]);
        }
    }
    cout << f[m];
    return 0;
}
```

### MapReduce

## 设计模式

### 单例模式

- 单例模式主要解决一个全局使用的类频繁的创建和销毁的问题。
- 单例模式下可以确保某一个类只有一个实例（该类不能被复制、拷贝），而且是自行实例化（构造函数是私有的），并向整个系统提供这个实例。
- 使用场景：设备管理器，驱动程序；创建的对象消耗资源过多，比如 I/O 与数据库的连接等。
- 优点：减少了内存的开销；避免对资源的多重占用
- 缺点：没有接口，不能继承

#### 懒汉式

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
2. 可能由于编译器的优化或操作系统的问题，双检锁会失效！C++11的atomic可以解决双检锁失效的问题，原子操作，获得和释放，内存屏障

#### 局部静态变量（懒汉式最佳版本）

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
        static Singleton t;
        return t;
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

这是Effective C++作者Meyers提出的，Meyers' Singleton，如果变量在初始化时，并发线程进入了声明语句，并发线程将会阻塞等待初始化结束。这是**C++11的Magic Static**的特性。

所以既解决了线程不安全的问题，又不需要智能指针。

局部静态变量保证了类的实例只有一个，**静态成员的生命期是从第一次声明到程序结束**，从第一次声明开始，所以是懒汉式的，自动析构，所以内存安全。

有可能C++11以前的编译器上线程不安全，因为用编译器用一个**全局标识**判断静态成员是否已初始化，这相当于先if再初始化，多线程可能就会在这里造成竞争条件。

#### 饿汉式

直接加载唯一实例，定义单例类时就进行实例化，所以天生没有多线程的问题，但是可能单例对象依赖另一个单例对象时就会有问题

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

缺点：**如果存在多个单例模式互相依赖，则会程序崩溃**

why:

1. C++只能保证在同一个文件中声明的static变量的初始化顺序与其变量声明的顺序一致。但是不能保证不同的文件中的static变量的初始化顺序。
2. Meyers' Singleton写法中，单例对象是第一次访问的时候（也就是第一次调用getInstance()函数的时候）才初始化的，局部static变量能保证通过函数来获取static变量的时候，该函数返回的对象是肯定完成了初始化的！
3. 在这种饿汉式初始化，可能某个单例对象依赖另一个单例对象。比如我有一个单例，存储了程序启动时加载的配置文件的内容。另外有一个单例，掌管着一个全局唯一的日志管理器。在日志管理初始化的时候，要通过配置文件的单例对象来获取到某个配置项，实现日志打印。因为C++不能保证不同文件的static变量的初始化顺序，所以有可能日志管理初始化的时候，配置文件的static单例还未初始化。
4. 当然，C++能保证main函数运行之后所有文件（非函数内）的static变量都能初始化，所以如果能保证日志管理单例在main函数运行之后再使用配置文件单例，那饿汉式也行，但是Meyers' Singleton还有另一个优势，那就是在单例模式有继承关系时也可以使用，而饿汉式会共享static成员变量，可能会有问题

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

#### 懒汉式与并发访问

使用锁机制，防止多次访问。具体做法，第一次判断为空不加锁，若为空，再进行加锁判断是否为空，若为空则生成对象。这叫double checked locking，但是双检锁在有些平台也会失效！

### 工厂模式

- 工厂模式主要解决接口选择的问题。
- 创建对象时不向外部暴露创建逻辑，通过一个共同的接口指向新创建的对象，通过面向对象的**多态**，**将创建对象的工作延迟到子类执行**，由子类决定实例化哪个对象
- 解耦，代码复用，更改功能容易。

```c++
class Game {
  public:
    Game() {}
    virtual ~Game() {}
    virtual void Play() {
      std::cout << "play game" << std::endl;
    }
};
class BasketBall : public Game {
    void Play() override { std::cout << "play basketball" << std::endl; }
};
class SocketBall : public Game {
    void Play() override { std::cout << "play socketball" << std::endl; }
};
class GameFactory {
    public:
    GameFactory() {}
    virtual ~GameFactory() {}
    virtual Game* CreateGame() = 0;
};
class BasketBallFactory : public GameFactory {
   public:
    Game* CreateGame() override{
        return new BasketBall();
    };
};
class SocketBallFactory : public GameFactory {
   public:
    Game* CreateGame() override{
        return new SocketBall();
    };
};

int main() {
    GameFactory* factory = new BasketBallFactory();
    Game* game = factory->CreateGame();
    game->Play(); // play basketball
    delete factory;
    delete game;

    factory = new SocketBallFactory();
    game = factory->CreateGame();
    game->Play(); // play socketball
    delete factory;
    delete game;
    return 0;
}
```

### 观察者模式

- 定义对象间的一种**一对多**的依赖关系
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
- 对于C++代码，当发现一个类**既继承了父类同时又持有父类的对象指针**，那这基本上就是装饰器模式
- 使用场景：扩展一个类的功能；动态增加功能，动态撤销。
- 优点：更加灵活，同时避免类型体系的快速膨胀。
- 缺点：多层装饰比较复杂。

### 适配器模式

举例：STL中的容器适配器

### 迭代器模式

举例：iterator

### 代理模式

举例：智能指针

### 策略模式

定义一系列的算法，将它们一个个封装，使得他们可以相互替换，一般为了解决多个if-else带来的复杂性，在多种算法相似的情况下，通过策略模式可减少if-else带来的复杂性和难以维护性，一般在项目中发现多个if-else并且预感将来还会在此增加if-else分支，那基本上就需要使用策略模式。

先举一个不使用策略模式的例子，拿计算来说，下面代码定义了加法操作和减法操作，以后如果需要增加乘法除法等计算，那就需要在枚举里添加新类型，并且增加if-else分支，这违反了开放关闭原则。

```c++
enum class CalOperation {
    add,
    sub
};
int NoStragegy(CalOperation ope) {
    if (ope == CalOperation::add) {
        std::cout << "this is add operation" << std::endl;
    } else if (ope == CalOperation::sub) {
        std::cout << "this is sub operation" << std::endl;
    } // 如何将来需要增加乘法或者除法或者其它运算，还需要增加if-else
    return 0;
}
```

下例为使用策略模式，定义一个基类Calculation，包含虚函数operation()，若想增加运算操作，直接继承基类，然后重写operation()即可

```c++
class Calculation {
   public:
    Calculation() {}
    virtual ~Calculation() {}
    virtual void operation() { std::cout << "base operation" << std::endl; }
};
class Add : public Calculation {
    void operation() override { std::cout << "this is add operation" << std::endl; }
};
class Sub : public Calculation {
    void operation() override { std::cout << "this is sub operation" << std::endl; }
};
// 可以继续添加各种运算操作，定义新类然后继承Calculation重写operation()即可
int Stragegy() {
    Calculation *cal = new Add();
    cal->operation();
    delete cal;
    Calculation *cal2 = new Sub(); // 这里将来都可以用工厂模式改掉，不会违反开放封闭原则
    cal2->operation();
    delete cal2;
    return 0;
}
```

### 原型模式

- 用于创建重复的对象，定义一个clone接口，通过调用clone接口创建出与原来类型相同的对象
- 比如下面的例子，单纯看game不知道它是什么类型，它可能是篮球游戏也可能是足球游戏等，可以使用原型模式实现
- 当然，拷贝构造函数也可以实现，但如果拷贝构造函数比较复杂或者程序员不想使用拷贝构造函数就可以使用原型模式

```c++
class Game {
    public:
      virtual Game* clone() = 0;

      virtual void Play() = 0;
};
class BasketBall : public Game {
    virtual Game* clone() override {
        return new BasketBall();
    }
    virtual void Play() override {
      std::cout << "basketball" << std::endl;
    }
};
int main() {
    Game *game = new BasketBall();
    game->Play();
    Game* new_game = game->clone();
    new_game->Play();

    delete game;
    delete new_game;
    return 0;
}
```

### 领域驱动模型DDD

- DDD是把业务模型翻译成系统架构设计的一种方式, 领域模型是对业务模型的抽象。
不是所有的业务服务都合适做DDD架构，DDD合适产品化，可持续迭代，业务逻辑足够复杂的业务系统，小规模的系统与简单业务不适合使用，毕竟相比较于MVC架构，认知成本和开发成本会大不少

- 贫血模型：

    - 对象只有数据没有行为，只有getter/setter方法
    - 基于贫血模型的传统开发模式，将数据与业务逻辑分离，违反了 OOP 的封装特性，实际上是一种面向过程的编程风格。但是，现在几乎所有的 Web 项目，都是基于这种贫血模型的开发模式，甚至连 Java Spring 框架的官方 demo，都是按照这种开发模式来编写的。
    - 面向过程编程风格有种种弊端，比如，数据和操作分离之后，数据本身的操作就不受限制了。任何代码都可以随意修改数据。

- 充血模型

    - 充血模型是一种有行为的模型，模型中状态的改变只能通过模型上的行为来触发，同时所有的约束及业务逻辑都收敛在模型上。

- 两种的区别

    - 贫血模型是事务脚本模式：贫血模型相对简单，模型上只有数据没有行为，业务逻辑由xxxService、xxxManger等类来承载，相对来说比较直接，针对简单的业务，贫血模型可以快速的完成交付，但后期的维护成本比较高，很容易变成我们所说的面条代码
    - 充血模型是领域模型模式：充血模型的实现相对比较复杂，但所有逻辑都由各自的类来负责，职责比较清晰，方便后期的迭代与维护。

- MVC有三层，DDD有四层

    - User Interfaces：负责对外交互, 提供对外远程接口

    - application：应用程序执行其任务所需的代码。它协调域层对象以执行实际任务。该层适用于跨事务、安全检查和高级日志记录。

    - domain：负责表达业务概念。对业务的分解，抽象，建模 。业务逻辑、程序的核心。。防腐层接口放在这里

    infrastucture：为其他层提供通用的技术能力。如repository的implementation（ibatis，hibernate, nosql），中间件服务等。防腐层实现放在这里。


### 建造者模式

用于构建一个复杂的大的对象，一个复杂的对象通常需要一步步才可以构建完成，建造者模式强调的是**一步步创建对象**，并通过相同的构建过程可以获得不同的结果对象，一般来说建造者对象不是直接返回的，与抽象工厂方法区别是抽象工厂方法用于创建多个系列的对象，而建造者模式强调一步步构建对象，并且构建步骤固定

## 其他

### 函数式编程

传统上C++属于命令式编程，只能啰嗦地看到代码怎么做，而不懂做什么和为什么这么做

说明式编程则相反。以数据库查询语言 SQL 为例，SQL 描述的是类似于下面的操作：你想从什么地方 (from)选择(select)满足什么条件(where)的什么数据，并可选指定排序(order by)或分组 (group by)条件。

函数式编程期望函数的行为像数学上的函数，而非一个计算机上的子程序。这样的函数一般被称为**纯函数(pure function)**，要点在于:
会影响函数结果的只是函数的参数，没有对环境的依赖返回的结果就是函数执行的唯一后果，不产生对环境的其他影响。这样的代码的最大好处是易于理解和易于推理，在很多情况下也会使代码更简单。函数式编程强调不可变性(immutability)、无副作用，天然就适合并发。

高阶函数在函数式编程中经常出现，在C++中，有如下几个函数对应着高阶函数

- Map 在 C++ 中的直接映射是 transform(在`<algorithm>`头文件中提供)。它所做的事情也是数学上的映射，把一个范围里的对象转换成相同数量的另外一些对象。这个函数的基本实现非常简单，但这是一种强大的抽象，在很多场合都用得上。
- Reduce 在 C++ 中的直接映射是 accumulate(在`<numeric>`头文件中提供)。它的功能是在指定的范围里，使用给定的初值和函数对象，从左到右对数值进行归并。在不提供函数对象作为第四个参数时，功能上相当于默认提供了加法函数对象;这时相当于做累加。提供了其他函数对象时，那当然就是使用该函数对象进行归并了。
- Filter 的功能是进行过滤，筛选出符合条件的成员。

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

### Python闭包

概念：在一个内部函数中，对外部作用域的变量进行引用，并且一般外部函数的返回值为内部函数，那么内部函数就被认为是闭包

作用：闭包可以保存当前的运行环境，闭包在爬虫以及web应用中都有很广泛的应用，并且闭包也是装饰器的基础

理解：闭包=函数块+定义函数时的环境，inner就是函数块，x就是环境

注意：闭包无法修改外部函数的局部变量

举个例子：

在函数startAt中定义了一个incrementBy函数，incrementBy访问了外部函数startAt的变量，并且函数返回值为incrementBy函数（注意python是可以返回一个函数的，这也是python的特性之一）

```python
>>> def startAt(x):
...     def incrementBy(y):
...             return x+y
...     return incrementBy
>>> a = startAt(1) # a是函数incrementBy而不是startAt
>>> a
<function startAt.<locals>.incrementBy at 0x107c8e290>
>>> a(1)
2
```

### Python装饰器

装饰器本质上是一个Python函数，它可以让其他函数在不需要做任何代码变动的前提下增加额外功能，装饰器的返回值也是一个函数对象

本质上，decorator就是一个返回函数的高阶函数。

假设我们要定义一个能打印日志的decorator，代码如下：

log是一个decorator，接受一个函数作为参数，并返回一个函数。

```python
def log(func):
    def wrapper(*args, **kw):
        print('call %s():' % func.__name__)
        return func(*args, **kw)
    return wrapper

@log  # 借助Python的@语法，把decorator置于函数的定义处：
def now():
    print('2015-3-25')
```

调用now()函数，不仅会运行now()函数本身，还会在**运行now()函数前**打印一行日志：

```shell
>>> now()
call now():
2015-3-25
```

### Python生成器

列表生成式：Python提供了生成器，使用`()`，**列表元素可以按照某种算法推算出来**，相比于列表`[]`，节省了大量空间

带有yield的函数：如果一个函数定义中包含yield关键字，那么这个函数就不再是一个普通函数，而是一个generator

generator保存的是算法，每次调用next(g)，就计算出g的下一个元素的值，直到计算到最后一个元素，没有更多的元素时，抛出StopIteration的错误。

但是每次都调用next太麻烦，可以用for循环

```python
>>> L = [x * x for x in range(10)]
>>> L
[0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
>>> g = (x * x for x in range(10))
>>> g
<generator object <genexpr> at 0x1022ef630>
>>> next(g)
0
>>> next(g)
1
>>> g = (x * x for x in range(10))
>>> for n in g:
...     print(n)
...
0
1
4
9
16
```

### shell编程

#### shell变量

- 定义变量时，变量名不加美元符号$
- 定义变量时，**变量名和等号之间不能有空格**
- 使用一个定义过的变量只要在变量名加上美元符号$即可
- shell变量分为局部变量（变量前面加local）和全局变量（变量前面不添加），局部变量的可见范围是代码块或函数内，全局变量则全局可见，和别的语言类似。

```shell
name=chenying
echo $name
echo ${name}
```

#### shell字符串

- 字符串可以用单引号，也可以用双引号。
- 单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的，也不能出现单独一个的单引号（对单引号使用转义符后也不行），但可成对出现，作为字符串拼接使用。
- 双引号里可以有变量，双引号里可以出现转义字符。

```shell
name='Isabella'
str="Hello, I know you are \"$name\"! \n"
echo -e $str # echo -e 表示使用转义功能，如果不加-e，则不会输出换行符，会直接输出\n
# Hello, I know you are "Isabella"
```

##### 拼接字符串

```shell
name='Isabella'
#使用双引号拼接
a="hello, "$name" !"
b="hello, ${name} !"
echo $a $b
# hello, Isabella ! hello, Isabella !
#使用单引号拼接
a1='hello, '$name' !'
b1='hello, ${name} !'
echo $a1 $b1
# hello, Isabella ! hello, ${name} !
```

##### 获取字符串长度

```shell
string="Isabella"
echo ${#string} #输出 8
```

##### 截取字符串

此栗子从字符串第 3 个字符开始截取 6 个字符：

```shell
string="abcdefghijklmn"
echo ${string:2:6} # 输出 cdefgh
```

#### 数组

用括号来表示数组，数组元素用"空格"符号分割开，既可以一次性定义，也可以一个个定义，可以使用不连续的下标，下标范围也没有限制

```shell
#定义数组name
name=(name1 name2 name3)
#定义数组ary
ary[0]=name1
ary[1]=name2
ary[3]=name3

#读取格式：${数组名[下标]}
#读取name的第0个元素
echo ${name[0]}
#使用@符号可以获取数组中的所有元素
echo ${name[@]}
```

##### 获取数组长度

```shell
# 取得数组元素的个数
length=${#name[@]}
echo $length

# 或者
length=${#name[*]}
echo $length

# 取得数组单个元素的长度
lengthn=${#name[n]}
echo $length
```

#### 传递参数

脚本内获取参数的格式为：$n。n 代表一个数字，1 为执行脚本的第一个参数，2 为执行脚本的第二个参数，以此类推。

```shell
#!/bin/bash
echo "第一个参数为：$1";
echo "第二个参数为：$2";
echo "第三个参数为：$3";
```

执行./test.sh a b c，输出结果为：

```shell
第一个参数为：a
第二个参数为：b
第三个参数为：c
```

#### 使用expr表达式计算

- 加+ 减- 乘* 除/ 取余% 赋值= 相等== 不相等!=
- 表达式和运算符之间要有空格，例如 1+1 是不对的，必须写成1 + 1；
- 整个表达式要被 `` 包含；

```shell
#!/bin/bash

a=10
b=20

val=`expr $a + $b`
echo "a + b : $val"

val=`expr $a - $b`
echo "a - b : $val"

val=`expr $a \* $b`
echo "a * b : $val"

val=`expr $b / $a`
echo "b / a : $val"

val=`expr $b % $a`
echo "b % a : $val"

if [ $a == $b ]
then
   echo "a 等于 b"
fi
if [ $a != $b ]
then
   echo "a 不等于 b"
fi
```

输出结果：

```shell
a + b : 30
a - b : -10
a * b : 200
b / a : 2
b % a : 0
a 不等于 b
```

#### 流程控制

##### if-else条件分支

```shell
#判断两个变量是否相等
a=10
b=20
if [ $a == $b ]
then
   echo "a 等于 b"
elif [ $a -gt $b ]
then
   echo "a 大于 b"
elif [ $a -lt $b ]
then
   echo "a 小于 b"
else
   echo "没有符合的条件"
fi # a 小于 b
```

##### for循环

```shell
#1
for((i=1;i<=10;i++));  
do
echo $(expr $i \* 3 + 1);  
done
#2
for i in $(seq 1 10)  
do
echo $(expr $i \* 3 + 1);  
done
#3
for i in `seq 10`  
do
echo $(expr $i \* 3 + 1);  
done
#4
for i in {1..10}  
do  
echo $(expr $i \* 3 + 1);  
done
```

```shell
#遍历当前文件目录中的所有文件
for i in `ls`;  
do
echo $i is file name\! ;  
done
#遍历字符串中每个单词（默认以空格分隔）
list="corgi is so cute !"  
for i in $list;  
do  
echo $i is block ;  
done
```

##### while循环

```shell
while condition
do
    command
done
```

##### until循环

until 循环执行一系列命令直至条件为 true 时停止，与 while 循环在处理方式上刚好相反。

```shell
until condition
do
    command
done
```

##### case

shell case语句为多选择语句。可以用case语句匹配一个值与一个模式，如果匹配成功，执行相匹配的命令，语法格式：

```shell
case 值 in
模式1)
    command1
    command2
    ...
    commandN
    ;;
模式2）
    command1
    command2
    ...
    commandN
    ;;
esac #需要一个esac（就是case反过来）作为结束标记，每个case分支用右圆括号，用两个分号表示break
```

##### 跳出循环

在循环过程中，有时候需要在未达到循环结束条件时强制跳出循环，Shell使用两个命令来实现该功能：break和continue。

#### shell函数

简化写法中function可以不写，语法格式

```shell
function name() {
    statements
    [return value]
}
```

#### grep——擅长查找

这里的模式，要么是字符（串），要么是正则表达式。

```shell
grep [OPTIONS] PATTERN [FILE...]
```

grep常用选项如下：

- -c：仅列出文件中包含模式的行数。
- -i：忽略模式中的字母大小写。
- -l：列出带有匹配行的文件名。
- -n：在每一行的最前面列出行号。
- -v：列出没有匹配模式的行。
- -w：把表达式当做一个完整的单字符来搜寻，忽略那些部分匹配的行。

#### sed——擅长取行和替换

```shell
sed [option]... 'script' inputfile
```

sed常用选项如下：

- -e：可以在同一行里执行多条命令
- -f：后跟保存了sed指令的文件
- -i：直接对内容进行修改，**不加-i时默认只是预览，不会对文件做实际修改**
- -n：sed默认会输出所有文本内容，使用-n参数后只显示处理过的行

sed常用操作：

- a：向匹配行后面插入内容
- i：向匹配行前插入内容
- c：更改匹配行的内容
- d：删除匹配的内容
- s：替换掉匹配的内容
- p：打印出匹配的内容，通常与-n选项一起使用
- w：将匹配内容写入到其他地方。

```shell
#输出长度不小于50个字符的行
sed -n '/^.{50}/p'

#统计文件中有每个单词出现了多少次
sed 's/ /\n/g' file | sort | uniq -c

#在第2行后添加hello
sed '2ahello' data.js

#向匹配内容123后面添加hello，如果文件中有多行包括123，则每一行后面都会添加
sed '/123/ahello' data.js

#最后一行添加hello
sed '$ahello' data.js

#在匹配内容之前插入只需把a换成i

#把文件的第1行替换为hello
sed '1chello' data.js

#删除第2行
sed '2d' data.js

#从第一行开始删除，每隔2行就删掉一行，即删除奇数行
sed '1~2d' data.js
#删除1~2行
sed '1,2d' data.js
#删除1~2之外的行
sed '1,2!d' data.js
#删除不匹配123或abc的行，/123\|abc/ 表示匹配123或abc ，！表示取反
sed '/123\|abc/!d' data.js

#替换每行第1个123为hello
sed 's/123/hello/' data.js
#替换每行第2个123为hello
sed 's/123/hello/2' data.js
```

替换模式（操作为s）：

![sedsub](https://user-gold-cdn.xitu.io/2019/5/22/16adeea79e660e4e?imageslim)

- g 默认只匹配行中第一次出现的内容，加上g，就可以全文替换了。常用。
- p 当使用了-n参数，p将仅输出匹配行内容。
- w 和上面的w模式类似，但是它仅仅输出有变换的行。
- i 这个参数比较重要，表示忽略大小写。
- e 表示将输出的每一行，执行一个命令。不建议使用，可以使用xargs配合完成这种功能。

```shell
# 一行命令替换多处内容，不加-e只能替换第一处的内容
sed -e 's/abc/qqq/g' -e 's/123/999/g' data.js

#替换，后面的内容为空
sed 's/,.*//g' data.js

#把文件中的每一行，使用引号包围起来。&是替位符
sed 's/.*/"&"/' file
```

#### awk——擅长取列

awk支持用户自定义函数和动态正则表达式等先进功能，是linux/unix下的一个强大编程工具

```shell
awk [options] 'script' var=value file(s)
awk [options] -f scriptfile var=value file(s)
```

- -F fs：fs 指定输入分隔符，fs可以时字符串或正则表达式
- -v var=value：赋值一个用户定义变量，将外部变量传递给awk
- -f scriptfile：从脚本文件中读取awk命令

一般的开发语言，数组下标是以0开始的，但awk的列$是以1开始的，而0指的是原始字符串。

```shell
#对于csv这种文件来说，分隔的字符是,。AWK使用-F参数去指定。以下代码打印csv文件中的第1和第2列。
awk -F ","  '{print $1,$2}' file
```

#### 使用sh -x调试shell脚本

sh -x的作用：

- "-x"选项可用来跟踪脚本的执行，是调试shell脚本的强有力工具。
- “-x”选项使shell在执行脚本的过程中把它实际执行的每一个命令行显示出来，并且在行首显示一个"+"号。
- "+"号后面显示的是经过了变量替换之后的命令行的内容，有助于分析实际执行的是什么命令。

利用shell内置的环境变量调试：

- $LINENO：代表shell脚本的当前行号，类似于C语言中的内置宏__LINE__
- $FUNCNAME：函数的名字，类似于C语言中的内置宏__func__,但宏__func__ 只能代表当前所在的函数名，而$FUNCNAME的功能更强大，它是一个数组变量，其中包含了整个调用链上所有的函数的名字，故变量${FUNCNAME [0]}代表shell脚本当前正在执行的函数的名字，而变量${FUNCNAME[1]}则代表调用函数${FUNCNAME[0]}的函数的名字，余者可以依此类推。
- $PS4：主提示符变量$PS1和第二级提示符变量$PS2比较常见，而$PS4的值将被显示在“-x”选项输出的每一条命令的前面。在Bash Shell中，缺省的$PS4的值是"+"号。
- 利用$PS4这一特性，通过使用一些内置变量来重定义$PS4的值，我们就可以增强"-x"选项的输出信 息。例如先执行export PS4='+{$LINENO:${FUNCNAME[0]}} ', 然后再使用“-x”选项来执行脚本，就能在每一条实际执行的命令前面显示其行号以及所属的函数名。

### RPC&&序列化

远程过程调用协议RPC（Remote Procedure Call Protocol)，比如Java的Netty框架，它封装了底层的（序列化、网络传输等）细节

首先搞清楚本地过程（函数）调用，传入的参数要压栈再出栈，执行函数体，再将返回值压栈，函数返回后从栈中取得返回值

1. **CALL ID**：远程过程调用时调用远程机器（服务器）上的函数，因为双方进程地址空间完全不一样，所以光靠函数名、函数指针是没法调用的，得有唯一的CALL ID
2. **序列化和反序列化**：双方的语言可能都不同，所以要转为字节流传输
3. **网络传输**：负责传输字节流，一般用TCP

Dubbo是一款高性能、轻量级的开源Java RPC框架，它提供了三大核心能力：

1. 面向接口的远程方法调用
2. 智能容错和负载均衡
3. 以及服务自动注册和发现。

序列化简单来说，是将内存中的对象转换成可以传输和存储的数据，而这个过程的逆向操作就是反序列化。序列化 && 反序列化技术可以实现将内存对象在本地和远程计算机上搬运。好比把大象关进冰箱门分三步：

1. 将本地内存对象编码成数据流
2. 通过网络传输上述数据流
3. 将收到的数据流在内存中构建出对象

三大序列化框架：protobuf（谷歌开源）、thrift（facebook开源）、avro（hadoop生态，对动态性支持最好）

### SSH三大框架

Spring，最核心的概念就两个：AOP（切面编程���和DI（依赖注入）。而DI又依赖IoC。通过IoC，所有的对象都可以从“第三方”**Spring容器**中得到，并由Spring注入到它应该去的地方。这种由原先的“对象管理对象”切换到“Spring管理对象”的方式，就是所谓的**IoC（控制反转）**，因为创建、管理对象的角色反过来了，有每个对象自主管理变为Spring统一管理。而且，只有通过IoC先让Spring创建对象后，才能进行下一步对象注入（DI），所以说DI依赖IoC

struts是一个MVC的web层框架，底层是对servlet的大量封装，拥有强大的拦截器机制，主要负责调用业务逻辑Service层。

Hibernate是一个持久层框架，轻量级(性能好)，orm映射灵活，对表与表的映射关系处理的很完善，对jdbc做了良好的封装，使得我们开发时与数据库交互不需要编写大量的SQL语句。

三大框架的大致流程jsp->struts->service->hibernate。因为struts 负责调用Service从而控制了Service的生命周期，使得层次之间的依赖加强，也就是耦合。所以我们引用了spring, spring在框架中充当容器的角色，用于维护各个层次之间的关系。通过IoC反转控制DI依赖注入完成各个层之间的注入，使得层与层之间实现完全脱耦，增加运行效率利于维护。

并且spring的AOP面向切面编程，实现在不改变代码的情况下完成对方法的增强。比较常用的就是spring的声明式事务管理，底层通过AOP实现，避免了我们每次都要手动开启事物，提交事务的重复性代码，使得开发逻辑更加清晰。

### 高并发

在开发高并发系统时有三把利器用来保护系统：缓存、降级和限流。**缓存**的目的是提升系统访问速度和增大系统能处理的容量，可谓是抗高并发流量的银弹；而**降级**是当服务出问题或者影响到核心流程的性能则需要暂时屏蔽掉，待高峰或者问题解决后再打开；而有些场景并不能用缓存和降级来解决，比如稀缺资源（秒杀、抢购）、写服务（如评论、下单）、频繁的复杂查询（评论的最后几页），因此需有一种手段来限制这些场景的并发/请求量，即**限流**。

限流的目的是通过对并发访问/请求进行**限速**或者一个时间窗口内的的请求进行限速来保护系统，一旦达到限制速率则可以拒绝服务（定向到错误页或告知资源没有了）、排队或等待（比如秒杀、评论、下单）、降级（返回兜底数据或默认数据，如商品详情页库存默认有货）。

一般开发高并发系统常见的限流有：限制总并发数（比如数据库连接池、线程池）、限制瞬时并发数、限制时间窗口内的平均速率；其他还有如限制远程接口调用速率、限制MQ的消费速率。另外还可以根据网络连接数、网络流量、CPU或内存负载等来限流。

一般使用**令牌桶**、**漏桶**算法

### 容器与虚拟化

**虚拟化是指硬件虚拟化**，也就是在操作系统（OS）中创建**虚拟机（virtual machine）**。虚拟化允许您将操作系统与底层硬件分开，这意味着您可以在单个物理计算机上同时运行多个操作系统，如Windows和Linux。这些操作系统称为虚拟系统（操作系统）。

- 灵活性：在同一硬件上同时运行多个操作系统
- 敏捷性：移动操作系统的方式与将文件或图片从一台物理服务器移动到另一台物理服务器的方式相同。
- 容错：当物理服务器出现故障时，管理软件会自动将实例迁移到可用服务器，以至于您甚至无法意识到物理硬件出现故障。
- 降低成本：您不再需要过多的物理服务器，因此您的电费、以及操作和维护所需的费用也随之减少。

**容器化是应用程序级别的虚拟化**，允许单个内核上有多个独立的用户空间实例。这些实例称为容器。容器提供了将应用程序的代码、运行时、系统工具、系统库和配置打包到一个实例中的标准方法。容器共享一个内核（操作系统），它安装在硬件上。

- 轻便：容器占用的服务器空间比虚拟机少，通常只需几秒钟即可启动。
- 弹性：容器具有高弹性，不需要分配给定数量的资源。这意味着容器能够更有效地动态使用服务器中的资源。当一个容器上的需求减少时，释放额外的资源供其他容器使用。
- 密度：密度是指一次可以运行单个物理服务器的对象数。容器化允许创建密集的环境，其中主机服务器的资源被充分利用但不被过度利用。与传统虚拟化相比，容器化允许更密集的环境容器不需要托管自己的操作系统。
- 性能：当资源压力很大时，应用程序的性能远远高于使用虚拟机管理程序的容器。因为使用传统的虚拟化，客户操作系统还必须满足其自身的内存需求，从主机上获取宝贵的RAM。
- 维护效率：只有一个操作系统内核，操作系统级别的更新或补丁只需要执行一次，以使更改在所有容器中生效。这使得服务器的操作和维护更加高效。

支持应用程序的容器的部署和组织称为容器编排，这是通过容器编排工具完成的。一些流行的开源容器编排工具包括Kubernetes、Docker Swarm和LXC（Linux Containers）。**Kubernetes（k8s）**是自动化容器操作的开源平台，这些操作包括部署，调度和节点集群间扩展。

**Docker** 属于 Linux 容器的一种封装，提供简单易用的容器使用接口。它是目前最流行的 Linux 容器解决方案。Docker 将应用程序与该程序的依赖，打包在一个文件里面。运行这个文件，就会生成一个虚拟容器。程序在这个虚拟容器里运行，就好像在真实的物理机上运行一样。有了 Docker，就不用担心环境问题。

- 提供一次性的环境。比如，本地测试他人的软件、持续集成的时候提供单元测试和构建的环境。
- 提供弹性的云服务。因为 Docker 容器可以随开随关，很适合动态扩容和缩容。
- 组建微服务架构。通过多个容器，一台机器可以跑多个服务，因此在本机就可以模拟出微服务架构。

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

### 缓存与Redis

缓存在计算机系统是无处不在，在CPU层面有L1-L3的Cache，在Linux中有TLB加速虚拟地址和物理地址的转换，在浏览器有本地缓存、手机有本地缓存等。缓存在计算机系统中有非常重要的地位，其主要作用是提高响应速度、减少磁盘访问等，本文主要讨论在高并发系统中的缓存系统。

一般来说，缓存由三座大山需要跨越，雪崩、穿透、击穿

#### 缓存雪崩 Cache Avalanche

理解：系统像雪崩一样崩了

问题：如果缓存系统故障，大量的请求无法从缓存完成数据请求，就全量汹涌冲向磁盘数据库系统，导致数据库被打死，整个系统彻底崩溃。比如由于大量的热数据设置了**相同或接近的过期时间**，导致缓存在某一时刻密集失效，大量请求全部转发到 DB，或者是某个冷数据瞬间涌入大量访问，这些查询在缓存 MISS 后，并发的将请求透传到 DB，DB 瞬时压力过载从而**拒绝服务**。

解决方案：目前常见的预防缓存雪崩的解决方案，主要是通过对 key 的 TTL 时间加随机数，打散 key 的淘汰时间来尽量规避，但是不能彻底规避。

#### 缓存穿透 Cache Penetration

理解：请求过来了 转了一圈 一无所获 就像穿过透明地带一样。其实就是指查询一个一定不存在的数据

问题：如果某时段有大量恶意的不存在的key的集中请求，那么服务将一直处理这些根本不存在的请求，导致正常请求无法被处理，从而出现问题。

解决方案：有效甄别是否存在这个key再决定是否读取很重要，一般可以用**布隆过滤器**，布隆过滤器是个好东西，有非常多的用途，包括：垃圾邮件识别、搜索蜘蛛爬虫url去重等，主要借助K个哈希函数和一个超大的bit数组来降低哈希冲突本身带来的误判，从而提高识别准确性。

布隆过滤器也存在一定的误判，假如判断存在可能不一定存在，但是假如判断不存在就一定不存在，因此刚好用在解决缓存穿透的key查找场景，事实上很多系统都是基于布隆过滤器来解决缓存穿透问题的。

#### 缓存击穿  Hotspot Invalid

理解：击穿是一人的雪崩，雪崩是一群人的击穿

问题：由于缓存系统中的热点数据都有过期时间，如果没有过期时间就造成了主存和缓存的数据不一致，因此过期时间一般都不会太长。设想某时刻一批热点数据同时在缓存系统中过期失效，那么这部分数据就都将请求磁盘数据库系统。

解决方案：

- 在设置**热点数据过期时间时尽量分散**，比如设置100ms的基础值，在此基础上正负浮动10ms，从而降低相同时刻出现CacheMiss的key的数量。
- 另外一种做法是**多线程加锁**，其中第一个线程发现CacheMiss之后进行加锁，再从数据库获取内容之后写到缓存中，其他线程获取锁失败则阻塞数ms之后再进行缓存读取，这样可以降低访问数据数据库的线程数，需要注意在单机和集群需要使用不同的锁，集群环境使用分布式锁来实现，但是由于锁的存在也会影响并发效率。
- 一种方法是在业务层对使用的热点数据查看是否即将过期，如果即将过期则去数据库获取最新数据进行更新并延长该热点key在缓存系统中的时间，从而避免后面的过期CacheMiss，相当于把事情提前解决了。

#### 缓存更新

我们把常见的缓存更新方案总结为两大类，业务层更新和外部组件更新，比较常见的是通过业务更新的方案。

缓存更新的问题是：先更新缓存还是先更新存储，缓存的处理是通过删除来实现还是通过更新来实现

业务层缓存更新的推荐方案：

- Step1：先更新存储，保证数据可靠性；
- Step2：再更新缓存，2个策略怎么选：
  - **惰性更新**：删除缓存，等待下次读 MISS 再缓存（推荐方案）；
  - 积极更新：将最新的值更新到缓存（不推荐）；

外部组件更新缓存的推荐方案（较复杂，先不做笔记了）

#### 缓存淘汰

缓存的作用是将热点数据缓存到内存实现加速，内存的成本要远高于磁盘，因此我们通常仅仅缓存热数据在内存，冷数据需要定期的从内存淘汰，数据的淘汰通常有两种方案：

- 主动淘汰，这是推荐的方式，我们通过对 Key 设置 TTL 的方式来让 Key 定期淘汰，以保障冷数据不会长久的占有内存。TTL 的策略可以保证冷数据一定被淘汰，但是没有办法保障热数据始终在内存，这个我们在后面会展开；
- 被动淘汰，这个是保底方案，并不推荐，Redis 提供了一系列的 Maxmemory 策略来对数据进行驱逐，触发的前提是内存要到达 maxmemory（内存使用率 100%），在 maxmemory 的场景下缓存的质量是不可控的，因为每次缓存一个 Key 都可能需要去淘汰一个 Key。

### 消息中间件/消息队列

消息中间件经常用来解决内部服务之间的异步调用问题

请求服务方把请求放到队列中，服务提供方去队列中获取请求进行处理，然后通过**回调**机制把结果返回

场景与好处：

1. 通过异步提高系统性能，如削峰处理秒杀
2. 降低系统耦合性，基于发布/订阅，类似生产者与消费者，事件驱动

producer和broker之间一般都是推的方式，即Producer 将消息推送给 Broker，而不是 Broker 主动去拉取消息。

broker和consumer之间有推拉两种模式：

- 推模式：消息实时性高，对于消费者使用来说更简单；但是，**推送速率难以适应消费速率**；适合消息量不大、消费能力强要求实时性高的情况下
- 拉模式：消费者可以根据自身的情况来发起拉取消息的请求；缺点是**消息延迟和消息忙请求**
- RocketMQ和Kafka都选择了拉模式，利用**长轮询**来实现拉模式，RocketMQ后台有个线程定时向broker请求消息，用户看起来像是直接推消息下来的。具体的做法都是通过消费者等待消息，当有消息的时候 Broker 会直接返回消息，如果没有消息都会采取**延迟处理**的策略，并且为了保证消息的及时性，在对应队列或者分区有新消息到来的时候都会提醒消息来了，及时返回消息。
- 总结：consumer 和 Broker 相互配合，拉取消息不满足条件时 hold 住，避免了多次频繁的拉取动作，当消息一到就提醒返回。

RocketMQ就是阿里借鉴Kafka用Java开发出来的

Kafka分布式、可分区、可复制、基于发布/订阅

[Producer Performance Tuning for Apache Kafka](https://www.slideshare.net/JiangjieQin/producer-performance-tuning-for-apache-kafka-63147600?qid=84026ff8-243f-49a7-a4d0-69976cf317b7&v=&b=&from_search=9)

Filebeat用于收集本地文件的日志数据。 它监视日志目录或特定的日志文件，尾部文件，并将它们转发到Elasticsearch或Logstash进行索引。
logstash 和filebeat都具有日志收集功能，filebeat更轻量，使用go语言编写，占用资源更少，可以有很高的并发，但logstash 具有filter功能，能过滤分析日志。一般结构都是filebeat采集日志，然后发送到消息队列，如redis，kafka。然后logstash去获取，利用filter功能过滤分析，然后存储到elasticsearch中。

Kafka是LinkedIn开源的分布式发布-订阅消息系统，目前归属于Apache顶级项目。Kafka主要特点是基于Pull的模式来处理消息消费，追求高吞吐量，一开始的目的就是用于日志收集和传输。0.8版本开始支持复制，不支持事务，对消息的重复、丢失、错误没有严格要求，适合产生大量数据的互联网服务的数据收集业务。

### CAP理论、PACELC理论、BASE理论

CAP理论：

- 第一版定义：对于一个分布式计算系统，不可能同时满足一致性（Consistence）、可用性（Availability）、分区容错性（Partition Tolerance）三个设计约束。
    - 一致性：在分布式环境下，数据在多个副本之间能否保持一致的特性
    - 可用性：系统提供的服务必须一直处于可用的状态，有限时间内，返回结果
    - 分区容错性：分布式系统在遇到任何网络分区故障的时候，仍然需要能够保证对外提供满足一致性和可用性的服务，除非是整个网络环境都发生了故障。
- 第二版定义：在一个分布式系统（指互相连接并共享数据的节点的集合）中，当涉及读写操作时，只能保证一致性（Consistence）、可用性（Availability）、分区容错性（Partition Tolerance）三者中的两个，另外一个必须被牺牲。
    - 一致性：对某个指定的客户端来说，读操作保证能够返回最新的写操作结果。
    - 可用性：非故障的节点在合理的时间内返回合理的响应（不是错误和超时的响应）。
    - 分区容错性：当出现网络分区后，系统能够继续“履行职责”。
- CAP关注的是对数据的读写操作，而不是分布式系统的所有功能。例如，ZooKeeper的选举机制就不是CAP探讨的对象。
- 虽然CAP理论定义是三个要素中只能取两个，但放到分布式环境下来思考，我们会发现必须选择P（分区容忍）要素，因为网络本身无法做到100%可靠，有可能出故障，所以分区是一个必然的现象。如果我们选择了CA而放弃了P，那么当发生分区现象时，为了保证C，系统需要禁止写入，当有写入请求时，系统返回error（例如，当前系统不允许写入），这又和A冲突了，因为A要求返回no error和no timeout。因此，分布式系统理论上不可能选择CA架构，只能选择CP或者AP架构。
- CAP关注的**粒度**是数据，而不是整个系统。
- CAP忽略网络延迟
- 正常运行情况下，不存在CP和AP的选择，可以同时满足CA。这就要求架构设计的时候既要考虑分区发生时选择CP还是AP，也要考虑分区没有发生时如何保证CA
- 当分区发生，需要牺牲C or A的时候，并不是什么也不做，需要为分区恢复后做准备，最典型的就是记录日志

PACELC理论：

- 在分布式系统中，我们使用PACELC理论比CAP理论更加合适，因为PACELC理论是CAP理论的扩展，简单来说PACELC理论的表述是这样的：
- 如果分区partition (P)存在，分布式系统就必须在availability (A) 和consistency (C)之间取得平衡作出选择，否则else (E) 当系统运行在无分区P情况下,系统需要在 latency (L) 和 consistency (C)之间取得平衡。
- PACELC理论比CAP理论更适合分布式系统，它完全展现了出现网络分区和正常情况下的取舍平衡问题，特别地引入了L时延因素，来对一致性C进行说明，也就是我们常说的强一致性和弱一致性。

BASE理论：

- 核心思想是即使无法做到强一致性（CAP的一致性就是强一致性），但应用可以采用适合的方式达到最终一致性。
- BASE理论本质上是对CAP的延伸和补充，更具体地说，是对CAP中AP方案的一个补充，分区期间会牺牲一致性，但是分区故障恢复后，系统应该达到**最终一致性**
- BA基本可用（Basically Available）是指:系统在绝大部分时间应处于可用状态,允许出现故障损失部分可用性,但保证核心可用。
- S软状态（Soft state）是指:数据状态不要求在任何时刻都保持一致,允许存在中间状态,而该状态不影响系统可用性。
- E最终一致性（Eventually consistent）是指:软状态前提下，经过一定时间后,这些数据最终能达到一致性状态。

### 高性能负载均衡

- 单服务器会面临性能天花板，高性能集群通过增加更多的服务器来提升整体系统性能，复杂性主要体现在**任务分配器**，以及合适的任务分配算法
- 负载均衡这个名词有误导性，负载均衡的工作不仅是为了使负载达到均衡状态

#### 负载均衡系统

- 常见的负载均衡系统包括3种：DNS负载均衡、硬件负载均衡和软件负载均衡。
  - DNS是最简单也是最常见的负载均衡方式，一般用来实现地理级别的均衡。实现简单、成本低，但也存在粒度太粗、更新不及时、扩展性差（控制全在域名商）等问题。有些公司自己实现了HTTP-DNS功能，和通用的DNS优缺点正好相反
  - 硬件负载均衡是通过单独的硬件设备来实现负载均衡功能，如F5、A10，性能非常强大，支持百万并发，稳定且安全，但非常贵
  - 软件负载均衡：常见的有Nginx（7层）和LVS（Linux内核的4层），性能只有万级别的并发，但很便宜，部署运维简单，而且非常灵活

#### 负载均衡算法

- 任务平分类：负载均衡系统将收到的任务平均分配给服务器进行处理，这里的“平均”可以是绝对数量的平均，也可以是比例或者权重上的平均。
- 负载均衡类：负载均衡系统根据服务器的负载来进行分配，这里的负载并不一定是通常意义上我们说的“CPU负载”，而是系统当前的压力，可以用CPU负载来衡量，也可以用连接数、I/O使用率、网卡吞吐量等来衡量系统的压力。
- 性能最优类：负载均衡系统根据服务器的响应时间来进行任务分配，优先将新任务分配给响应最快的服务器。
- Hash类：负载均衡系统根据任务中的某些关键信息进行Hash运算，将相同Hash值的请求分配到同一台服务器上。常见的有源地址Hash、目标地址Hash、session id hash、用户ID Hash等。

### 高性能数据库集群

#### 读写分离

- 将数据库读写操作分散到不同的节点上，需要搭建数据库服务器主从集群，一主一从or一主多从均可
- 数据库主机负责读写操作，从机只负责读操作。
- 数据库主机通过复制将数据同步到从机，每台数据库服务器都存储了所有的业务数据。
- 引入两个复杂点：主从复制延迟与分配机制

解决主从复制延迟

1. 写操作后的读操作指定发给数据库主服务器，对业务侵入和影响较大，不推荐
2. 读从机失败后再读一次主机，俗称二次读取，可能会放大读压力
3. 关键业务读写操作全部指向主机，非关键业务采用读写分离，推荐

解决分配机制

- 程序代码封装，抽象在数据访问层，如Taobao Distributed Data Layer（TDDL），实现简单，可定制化，但是各编程语言都需要实现一遍
- 中间件封装，独立一套系统出来，实现读写操作分离和数据库服务器连接的管理，比程序代码封装更复杂，如MySQL Router

#### 分库分表

- 业务分库：指的是按照业务模块将数据分散到不同的数据库服务器，会产生无法join的问题、事务问题、成本问题
- 业务分表：同一业务的单表数据也会达到单台数据库服务器的处理瓶颈，可分为垂直分表与水平分表
  - 垂直分表：适合将表中某些不常用且占了大量空间的列拆分出去，引入的复杂性主要是表操作次数增加
  - 水平分表：适合表行数特别大的表，比如1000w

水平分表相比垂直分表，会引入更多的复杂性，主要表现在下面几个方面：

- 路由：水平分表后，某条数据具体属于哪个切分后的子表，需要增加路由算法进行计算
  - 范围路由：选取有序的数据列（例如，整形、时间戳等）作为路由的条件，不同分段分散到不同的数据库表中
    - 优点：平滑扩充新表
    - 缺点：分布不均匀
  - Hash路由：选取某个列（或者某几个列组合也可以）的值进行Hash运算，然后根据Hash结果分散到不同的数据库表中。
    - 优点：扩充新表比较麻烦，所有数据都要重分布
    - 缺点：分布均匀
  - 配置路由就是用一张路由表来维护关系，需要多查询一次
- join操作：水平分表后，数据分散在多个表中，如果需要与其他表进行join查询，需要在业务代码或者数据库中间件中进行多次join查询，然后将结果合并。
- count()操作：在逻辑上用`count(*)`一次查询即可，但是分表后需要`count(*)`相加，为了减少`count(*)`耗时，可以再开一张表来记录『总行数』，每次插入or删除都更新这个表，对于那些对实时精准性不高的业务，可以后台定时更新总行数表
- orderby操作：需要分别查询子表的数据后，再汇总进行排序

### 高性能存储架构：双机架构

- 存储高可用方案的本质都是通过将数据复制到多个存储设备，通过数据冗余的方式来实现高可用，其复杂性主要体现在如何应对复制延迟和中断导致的数据不一致问题。

#### 复杂性

- 数据如何复制？
- 各个节点的职责是什么？
- 如何应对复制延迟？
- 如何应对复制中断？

#### 主备复制

- 最常见也是最简单的一种存储高可用方案，几乎所有的存储系统都提供了主备复制的功能，例如MySQL、Redis、MongoDB等。
- 优点就是非常简单，客户端无需感知备机的存在，只需要数据复制即可，不需要状态判断与主备切换等复杂操作
- 缺点是备机仅做备份，且故障后需要人工干预
- 适用场景：内部的后台管理系统，**变更频率低**，丢数据可以通过人工追回

#### 主从复制

- 与主备复制架构比较类似，主要的差别点在于从机正常情况下也是要提供读的操作。
- 优点是发挥了从机的性能，主机故障时从机也能提供读能力
- 缺点：客户端需要感知主备关系；如果主从复制延迟大，则业务会出现数据不一致问题
- 适用场景：**写少读多**的业务，如论坛、BBS

#### 双机切换

- 解决了主备复制与主从复制的问题，角色可以切换，但复杂性会大大增加
- 主备间状态判断、切换决策、数据冲突解决
- 互联式：主备机直接建立状态传递的渠道
- 中介式：引入第三方中介，主备机之间不直接连接，看上去比互联式要复杂，但其实在状态传递与决策更为简单，在工程实践中推荐基于ZooKeeper搭建中介式切换架构
- 模拟式：主备机之间并不传递任何状态数据，而是备机模拟成一个客户端，向主机发起模拟的读写操作，根据读写操作的响应情况来判断主机的状态。优点是实现简单，省去状态通道的建立，但是获得信息有限（404、超时等），无法像互联式那样获得精细的性能指标（如CPU负载、吞吐量等）

#### 主主复制

- 两台机器都是主机，互相将数据复制给对方，客户端可以任意挑选其中一台机器进行读写操作
- 如果采取主主复制架构，必须保证数据能够双向复制
- 主主复制架构对数据的设计有严格的要求，一般适合于那些临时性、可丢失、可覆盖的数据场景。例如，用户登录产生的session数据（可以重新登录生成）、用户行为的日志数据（可以丢失）、论坛的草稿数据（可以丢失）等

### 异地多活

- 同城异区：同城的两个机房，距离上一般大约就是几十千米，通过搭建高速的网络，同城异区的两个机房能够实现和同一个机房内几乎一样的网络传输速度
- 跨城异地：跨城异地距离较远带来的网络传输延迟问题，给异地多活架构设计带来了复杂性，肯定会导致数据的不一致，对于数据一致性要求不高的数据（如用户登录：重新登录即可、新闻类：一天很少变动、微博：不一致影响不大），可以设计成跨城异地多活，像支付宝余额这种要用同城异区，以减少数据不一致的可能性
- 跨国异地：为不同地区用户提供服务，如亚马逊中国、亚马逊美国，或者是为只读性业务做多活，比如谷歌搜索的资料都在谷歌的搜索引擎上，英国谷歌和美国谷歌差别不大
- **优先实现核心业务的异地多活架构**，比如，登录就比注册、修改头像要核心的多，第一日活大，第二社会舆情大
- **保证核心数据最终一致性**，取舍
- **采用多种手段同步数据**，不仅借助于存储系统本身的同步功能，还可以用多重手段如消息队列等去同步
- **只保证绝大部分用户的异地多活**，取舍

### 分布式系统

#### 分布式一致性

分布式一致性最终的问题就是**分布式数据的一致性**

数据一致性的理解：

- 在分布式系统中数据存储是**多节点主从备份**的，一般做成**读写分离**，当客户端将数据通过主库的代理写入之后，在极其短暂的瞬间，主节点的数据是无法复制到从节点的，这个瞬间其他客户端读取到的从库数据都是旧数据。
- Redis主从节点之间的数据复制分为：**同步复制和异步复制**，一般来说，为了保证服务的高可用，主从节点的数据复制是异步的，因为同步复制**延时**无法保证。
- 其实只有两类数据一致性，**强一致性与弱一致性**。强一致性也叫做线性一致性，除此以外，所有其他的一致性都是弱一致性的特殊情况。所谓强一致性，即复制是同步的，弱一致性，即复制是异步的。
- 强一致性可以保证从库有与主库一致的数据。如果主库突然宕机，我们仍可以保证数据完整。但如果从库宕机或网络阻塞，主库就无法完成写入操作。
- 在实践中，我们通常使一个从库是同步的，而其他的则是异步的。如果这个同步的从库出现问题，则使另一个异步从库同步。这可以确保永远有两个节点拥有完整数据：主库和同步从库。这种配置称为**半同步**。
- 弱一致性中的**最终一致性**：等待一段时间，从库会赶上并于主库保持一致
- 弱一致性中的**读写一致性**：可以认为是**读己之写一致性**，最简单的实现方案是对于那些需要保证读写一致性的内容**都从主库读**，更好的实现方案是客户端**在本地记住最近一次写入的时间戳**，发起读请求时附带此时间戳，从库提供任何查询服务前，需确保该时间戳前的变更都已经同步到了本从库中。如果当前从库不够新，则可以从另一个从库读，或者等待从库追赶上来。
- 弱一致性中的**单调读**：比强一致性弱，比最终一致性强，单调读意味着一个用户不会读到更旧的数据，实现方案是确保每个用户总是从**同一个节点**进行读取（不同的用户可以从不同的节点读取），比如可以基于用户ID的哈希值来选择节点，而不是随机选择节点。

CAP理论

PACELC理论

#### 2PC（两阶段提交，Two-Phase Commit）

事务是一组原子操作，要么全成功要么全失败 All or Nothing，**单机事务**具备ACID特性，但**分布式事务**的各个子服务部署在不同的物理节点，需要分布式一致性协议和算法来解决分布式事务问题保证数据一致性。2PC和3PC就是这样的协议。

2PC协议将节点分为：协调者和参与者

2PC协议分为：准备阶段和提交阶段

准备阶段：

- 询问环节：协调者向参与者询问，是否准备好可以执行事务，之后协调者开始等待各参与者的响应，这个环节协调者处于阻塞等待状态。
- 处理环节：参与者收到协调者的询问后根据自身情况来决定是否执行事务操作，如果参与者执行事务成功，将Undo和Redo信息记入事务日志，**但不提交事务**；否则直接返回失败。
- 响应环节：当参与者成功执行了事务操作，就反馈yes给协调者，表示事务在本地执行；当参与者没有成功执行事务，就反馈no给协调者，表示事务不可以执行提交。

提交阶段：

- 提交事务：如果在准备阶段结束时，协调者收到了来自**所有参与者的yes反馈**，接下来协调者就会向所有参与者发送提交事务指令，具体的过程如下：
  - 步骤1. 协调者向所有参与者发送事务提交消息Commit命令
  - 步骤2. 参与者在收到来自协调者的Commit命令之后，执行事务提交动- 作，并释放事务期间所有持有的锁和资源，这一步很重要
  - 步骤3. 所有参与者在执行本地事务且释放资源完成后，向协调者发送事务提交确认消息ACK
  - 步骤4. 协调者在收到所有参与者的ACK消息后确认完成本次事务
- 回滚事务：如果在准备阶段结束时，协调者**没有**收到来自所有参与者的yes反馈，接下来协调者就会向所有参与者发送回滚事务指令，具体的过程如下：
  - 步骤1. 协调者向所有参与者发送事务回滚消息Rollback
  - 步骤2. 参与者收到Rollback回滚指令后，根据本地的回滚日志来撤销阶段一执行的事务，并释放事务期间所有持有的锁和资源
  - 步骤3. 所有参与者在完成指令后向协调者回复反馈ACK
  - 步骤4. 协调者在收到所有参与者的ACK确认消息后撤销该事务

最极端的异常情况：协调者和**唯一接收指令的参与者**都出现不可恢复宕机时，即使后面选举了新的协调者，仍然可能出现数据的不一致性

- 假定在协调者发送第一条指令之后挂掉，此时只有一个参与者接收到了指令并执行后也挂掉了，其他参与者并没有收到指令。
- 新选举出来的协调者询问所有参与节点状态时，如果已经挂掉的参与者恢复了，那么状态就明确了commit或者rollback，如果挂掉的参与者并没有恢复并且已经执行了commit/rollback操作，那么将会出现数据不一致，并且新的协调者由于没有获得足够的信息无法明确当前的状态，其他的参与者在阶段一执行后产生阻塞。

2PC协议的原理简单，实现方便，但是有以下缺点：

- 同步阻塞：准备阶段等待参与者的响应反馈是同步阻塞的，可能会因为网络问题而长时间阻塞
- 单点问题：一旦出现协调者故障，所有的参与者都将处于阻塞资源无法释放的情况，从而影响其他操作的进行
- 网络分区脑裂、极端情况数据不一致的问题：2PC协议整个过程中基于所有参与者的反馈，但是由于异常情况的存在，在一些时候很难达成一致从而回滚事务，整个策略容错性不强，并且网络分区的存在可能产生脑裂造成分区数据不一致

#### 3PC（三阶段提交，Three-Phase Commit）

3PC协议 Three-Phase-Commit 又称三阶段提交协议，相比 2PC 协议增加了一个阶段，因此我们普遍把 3PC 协议看作是 2PC 协议的改进版本。

3PC 协议将 2PC 协议的准备阶段一分为二，从而形成了三个阶段：

- CanCommit阶段：这个阶段参与者并不真实获取锁占用资源，只是对自身执行事务状态的检查，查看是否具备执行事务的条件，进而回复询问。
- PreCommit阶段：具体动作取决CanCommit阶段的结果，
  - 若所有参与者都Ready，则协调者就会向参与者发送本地执行的相关指令，这和2PC的准备阶段相似，参与者收到指令后进行本地事务执行，并记录日志，并将处理结果返回给协调者（可能都成功，也可能不都成功）；
  - 若有参与者不Ready，那么协调者就会发送信号给所有参与者，告知本次事务取消了，因为参与者没有执行事务也没有获取锁等资源，所以没什么消耗
- DoCommit阶段：该阶段和2PC的提交阶段类似，该阶段执行的动作取决于第二阶段PreCommit的结果，
  - PreCommit阶段一致通过，都给协调者回复ACK，于是协调者向所有参与者发送提交指令，所有参与者收到之后开始**执行本地提交**，并反馈结果，最终完成事务!
  - PreCommit阶段存在分歧，协调者发现部分参与者无法执行事务，于是决定告诉其他参与者**本地回滚**，**释放资源**，**取消本次事务**。

3PC的超时策略：

- 参与者等待 PreCommit 超时：参与者中断事务
- **参与者等待 DoCommit 超时**：参与者提交事务、释放资源（参与者认为大家都对齐了，只是等不到协调者的DoCommit指令，于是就都本地提交）
- 协调者等待反馈超时：协调者执行abort或者rollback

但是超时策略引入了数据不一致的问题，如果协调者在DoCommit阶段发送的是rollback指令，但有个参与者A等待DoCommit超时，于是执行了本地事务提交，从而和其他收到指令执行rollback的参与者的数据不一致。

总结：

- 经过CanCommit和PreCommit阶段后，参与者之间对齐并保留了决策结果，避免2PC协议极端情况决策结果的错误缺失，是个比较好的做法。
- 2PC协议只有协调者有超时机制，3PC协议对参与者也引入了超时机制，在不同的阶段进行不同的超时处理，但是由于网络波动和网络分区存在让参与者的超时处理带来新的不确定性，甚至可能出现数据不一致。
- 3PC协议增加一轮询问阶段所以整个交互过程比2PC更长了，**性能相比2PC是有一些下降**，但是3PC协议对于网络分区等情况也并没有处理地很好。

#### Paxos

Paxos算法是基于消息传递的分布式一致性算法，具有高度容错性，但不容易理解

- 基于二阶段提交协议与过半理论
- 第一个被证明的共识算法
- 是目前公认解决分布式一致性问题最有效的算法之一

系统一共有几个角色：Proposer（提出提案）、Acceptor（参与决策）、Learner（不参与提案，只负责接收已确定的提案，一般用于提高集群对外提供读服务的能力

Paxos算法流程：

阶段一：提交事务请求

- Proposer选择一个提案编号n，向所有的Acceptor广播Prepare（n）请求。
- Acceptor接收到Prepare（n）请求，若提案编号n比之前接受的Prepare请求都要大，则承诺将不会接受编号比n小的提案，并且带上之前Accept的提案中编号小于n的最大的提案（如果有），否则不予理会。

阶段二：执行事务提交

- Proposer得到了大多数（多于一半）Acceptor的承诺后，如果发现没有一个Acceptor接受过一个值，那么把自己的值作为提案值；否则从所有接受过的提案中选择对应编号最大的值作为提案值。提案编号与提案值组成提案，向所有的Acceptor广播。
- Acceptor收到提案后，只要其未对编号大于该提案编号的提案作出相应，则接受该提案，对Proposer返回接受。
- Proposer得到过半Acceptor的接受后，该提案值被选定，达成共识。

阶段三：Learn阶段（本阶段不属于选定提案的过程）

- Proposer将通过的提案同步到所有的Learner

Paxos细节问题：

- Learner的作用？（学习被确定提案的值，Acceptor宕机恢复后可以从learner处获取提案值）
- 为什么提案需要被多数派接受？（多数派之间必有交集）
- 为什么第一阶段需要承诺？（保证Proposer提交的值不会被未来提案干扰，同时保证Acceptor处理提案的顺序）
- 活锁问题？（主leader进行propose -> Multi-paxos）

#### Raft

Raft协议对标Paxos，容错性和性能都是一致的，但是Raft比Paxos更易理解和实施。系统分为几种角色： Leader（发出提案）、Follower（参与决策）、Candidate（Leader选举中的临时角色）。

- **选主**：在刚开始所有节点都是Follower状态，如果一个Follower一段时间没接收到Leader（heartbeat timeout），则成为Candidates，发起投票，如果其他节点回复过半数则成为Leader（其他节点会重置election timeout），如果被告知有新Leader则退回Follower，否则保持Candidate
- **日志复制**：Leader接受所有客户端请求，然后把日志entry发给所有Follower，当收到过半节点的回复就可以返回成功，所以满足最终一致性
- Leader与Follower利用心跳（heartbeat timeout）传输新的日志，超时了则Follower重新开始选主，向其他节点拉票，成为candidate
- Leader负责接受客户端请求并管理到Follower的**日志复制**。
- 数据只在一个方向流动：从Leader到Follower。

Raft协议把**Leader选举**、**日志复制**等功能分离并模块化，使其更易理解和工程实现。

Raft把时间切割为任意长度的任期，每个任期都有一个任期号，采用连续的整数。每个任期都由一次选举开始，若选举失败则这个任期内没有Leader；如果选举出了Leader则这个任期内有Leader负责集群状态管理。每个任期内，每个节点只能投票一次，并且只会投给日志比自己新的Candidate

解决网络分区（脑裂）：根据谁的term的index更新，决定谁的领导地位更高，另一个自动退化为follower；也可以通过lease租约解决

#### NWR机制

首先看看这三个字母在分布式系统中的含义：

N：有多少份数据副本
W：一次成功的写操作至少有w份数据写入成功
R：一次成功的读操作至少有R份数据读取成功

NWR值的不同组合会产生不同的一致性效果，

- 当W+R>N的时候，读取操作和写入操作成功的数据一定会有交集，这样就可以保证一定能够读取到最新版本的更新数据，数据的**强一致性**得到了保证
- 如果R+W<=N，则无法保证数据的强一致性，因为成功写和成功读集合可能不存在交集，这样读操作无法读取到最新的更新数值，也就无法保证数据的强一致性。

版本的新旧需要版本控制算法来判别，比如向量时钟。

当然R或者W不能太大，因为越大需要操作的副本越多，耗时越长。

#### Quorum机制

Quorom机制，是一种分布式系统中常用的，用来保证数据冗余和最终一致性的投票算法，主要思想来源于鸽巢原理。在有冗余数据的分布式存储系统当中，冗余数据对象会在不同的机器之间存放多份拷贝。但是同一时刻一个数据对象的多份拷贝只能用于读或者用于写。
分布式系统中的每一份数据拷贝对象都被赋予一票。每一个操作必须要获得最小的读票数（Vr）或者最小的写票数(Vw）才能读或者写。如果一个系统有V票（意味着一个数据对象有V份冗余拷贝），那么这最小读写票必须满足：

Vr + Vw > V
Vw > V/2

第一条规则保证了一个数据不会被同时读写。当一个写操作请求过来的时候，它必须要获得Vw个冗余拷贝的许可。而剩下的数量是V-Vw 不够Vr，因此不能再有读请求过来了。同理，当读请求已经获得了Vr个冗余拷贝的许可时，写请求就无法获得许可了。
第二条规则保证了数据的串行化修改。一份数据的冗余拷贝不可能同时被两个写请求修改。

Quorum机制其实就是NWR机制。

#### Lease机制(解决脑裂！)

master给各个slave分配不同的数据，每个节点的数据都具有有效时间比如1小时，在lease时间内，客户端可以直接向slave请求数据，如果超过时间客户端就去master请求数据。一般而言，slave可以定时主动向master要求续租并更新数据，master在数据发生变化时也可以主动通知slave，不同方式的选择也在于可用性与一致性之间进行权衡。

租约机制也可以**解决主备之间网络不通导致的双主脑裂问题**，亦即：主备之间本来心跳连线的，但是突然之间网络不通或者暂停又恢复了或者太繁忙无法回复，这时备机开始接管服务，但是主机依然存活能对外服务，这是就发生争夺与分区，但是引入lease的话，老主机颁发给具体server的lease必然较旧，请求就失效了，老主机自动退出对外服务，备机完全接管服务。

#### 分布式id生成器

snowflake方案：

snowflake是Twitter开源的分布式ID生成算法，结果是一个long型的ID。其核心思想是：使用41bit作为毫秒数，10bit作为机器的ID（5个bit是数据中心，5个bit的机器ID），12bit作为毫秒内的流水号（意味着每个节点在每毫秒可以产生 4096 个 ID），最后还有一个符号位，永远是0。

优点：

1. 毫秒数在高位，自增序列在低位，整个ID都是趋势递增的。
2. 不依赖数据库等第三方系统，以服务的方式部署，稳定性更高，生成ID的性能也是非常高的。
3. 可以根据自身业务特性分配bit位，非常灵活。

缺点：强依赖**机器时钟**，如果机器上时钟回拨，会导致发号重复或者服务会处于不可用状态。

解决办法：1）如果时间很短，那就等待再生成；2）NTP服务器保证集群机器的时钟同步

用Redis生成ID：

因为Redis是单线程的，也可以用来生成全局唯一ID。可以用Redis的原子操作INCR和INCRBY来实现。此外，可以使用Redis集群来获取更高的吞吐量。假如一个集群中有5台Redis，可以初始化每台Redis的值分别是1,2,3,4,5，步长都是5，各Redis生成的ID如下：

```shell
A：1,6,11,16
B：2,7,12,17
C：3,8,13,18
D：4,9,14,19
E：5,10,15,20
```

这种方式是负载到哪台机器提前定好，未来很难做修改。3~5台服务器基本能够满足需求，都可以获得不同的ID，但步长和初始值一定需要事先确定，使用Redis集群也可以解决单点故障问题。

#### 分布式锁

陈皓分享：https://youtu.be/VnbC5RG1fEo

### Elasticsearch

[Elasticsearch搜索引擎汇总](https://www.cnblogs.com/jajian/category/1280015.html)

Elasticsearch是一个高度可扩展的、开源的、基于 Lucene 的全文搜索和分析引擎

[Linux安装Elasticsearch](https://juejin.im/post/5bc69e2ce51d450e6548ce77)

#### 集群(Cluster)

- 集群(cluster)是一组具有相同cluster.name的节点集合，他们协同工作，共享数据并提供故障转移和扩展功能，当然一个节点也可以组成一个集群。
- 集群由唯一名称标识，默认情况下为“elasticsearch”。此名称很重要，因为如果节点设置为按名称加入集群的话，则该节点只能是集群的一部分。
- 确保不同的环境中使用不同的集群名称，否则最终会导致节点加入错误的集群。

集群状态通过 绿，黄，红 来标识

- 绿色 - 一切都很好（集群功能齐全）。
- 黄色 - 所有数据均可用，但尚未分配一些副本（集群功能齐全）。
- 红色 - 某些数据由于某种原因不可用（集群部分功能）。

#### 节点(Node)

- 节点，**一个运行的 ES 实例就是一个节点**，节点存储数据并参与集群的索引和搜索功能。
- 就像集群一样，节点由名称标识，默认情况下，该名称是在启动时分配给节点的**随机通用唯一标识符（UUID）**。如果不需要默认值，可以定义所需的任何节点名称。此名称对于管理目的非常重要，您可以在其中识别网络中哪些服务器与 Elasticsearch 集群中的哪些节点相对应。
- 可以将节点配置为按集群名称加入特定集群。默认情况下，每个节点都设置为加入一个名为 cluster 的 elasticsearch 集群，这意味着如果您在网络上启动了许多节点并且假设它们可以相互发现 - 它们将自动形成并加入一个名为 elasticsearch 的集群。
- 与其他组件集群(mysql，redis)的 master-slave模式一样，ES集群中也会选举一个节点成为**主节点**，主节点它的职责是维护全局集群状态，在节点加入或离开集群的时候重新分配分片

#### 索引(Index)

- 索引是具有某些类似特征的文档集合
- 这个索引不是关系型数据库中的索引，更像是数据库表
- 索引由名称标识（必须全部小写），此名称用于在对其中的文档执行索引，搜索，更新和删除操作时引用索引。

索引（名词）：一个索引(index)就像是传统关系数据库中的数据库，它是相关文档存储的地方，index的复数是 indices 或 indexes。

倒排索引：传统数据库为特定列增加一个索引，例如B-Tree索引来加速检索。Elasticsearch和Lucene使用一种叫做倒排索引(inverted index)的数据结构来达到相同目的。

Elasticsearch 是面向文档的，意味着它存储整个对象或文档。Elasticsearch 不仅存储文档，而且每个文档的内容可以被检索。在 Elasticsearch 中，你对文档进行索引、检索、排序和过滤而不是对行列数据。这是一种完全不同的思考数据的方式，也是 Elasticsearch 能支持复杂全文检索的原因。

#### 文档(Document)

- 文档是可以建立索引的基本信息单元。例如，您可以为单个客户提供文档，为单个产品提供一个文档，为单个订单提供一个文档。该文档以JSON（JavaScript Object Notation）表示，JSON是一种普遍存在的互联网数据交换格式。

#### 索引映射

字段类型：

- 核心数据类型：字符串、数字、日期、布尔、二进制、范围
- 复杂数据类型：数组、对象、嵌套
- Geo(地理)数据类型
- 专用数据类型：IP、Completion、令牌计数...
- 多字段：可以为字段指定多个数据类型

字符串类型中text与keyword的区别：

- text 用于**索引全文值**的字段，例如电子邮件正文或产品说明。通过分词器传递。文本字段不用于排序，很少用于聚合。
- keyword 用于**索引结构化内容**的字段，例如电子邮件地址，主机名，状态代码，邮政编码或标签。它们通常用于过滤，排序，和聚合。keyword字段只能按其**确切值**进行搜索。

映射：

- 映射是定义一个文档及其包含的字段如何存储和索引的过程
- 动态映射，即不事先指定映射类型(Mapping)，文档写入ElasticSearch时，ES会根据文档字段**自动识别类型**，这种机制称之为动态映射。
- 静态映射，即人为事先定义好映射，包含文档的各个字段及其类型等，这种方式称之为静态映射，亦可称为显式映射。可用json格式定义映射

#### 分片(Shards)

- 索引可能存储大量数据，从而超过单个节点的硬件限制，于是es将索引细分为多个分片，多个分片可以存储在不同节点上
- 创建索引时，只需定义所需的分片数即可。每个分片本身都是一个功能齐全且独立的“索引”，可以托管在集群中的任何节点上。
- 类似于MySql的分库分表
- 分片可以水平拆分/缩放内容量
- 分片可以跨分片（可能在多个节点上）分布和并行化操作，从而**提高性能/吞吐量**
- 分片的分布方式以及如何将其文档聚合回搜索请求的机制完全由 Elasticsearch 管理，对用户而言是透明的。

主分片的数目在索引创建时就已经确定了下来。实际上，这个数目定义了这个索引能够储的最大数据量。（实际大小取决于你的数据、硬件和使用场景。） 但是，读操作——搜索和返回数据——可以同时被主分片或副本分片所处理，所以当你**拥有越多的副本分片时，也将拥有越高的吞吐量**。

#### 副本(Replicas)

- 副本，是对分片的复制。目的是为了当分片/节点发生故障时提供高可用性，它允许您扩展搜索量/吞吐量，因为可以在所有副本上并行执行搜索。
- 总而言之，每个索引可以拆分为多个分片。索引也可以复制为零次（表示没有副本）或更多次。复制之后，每个索引将具有主分片和复制分片(主分片的副本)。
- 可以在创建索引时为每个索引定义分片和副本的数量，也可以创建后再修改，但很麻烦。
- 默认情况下，Elasticsearch 中的每个索引都分配了5个主分片和1个副本（1个副本的意思是每个主分片都有1个副本），这意味着如果集群中至少有两个节点，则索引将包含5个主分片和另外5个副本分片（1个完整副本），总计为每个索引10个分片。

索引的主分片数这个值在索引创建后就不能修改了（默认值是 5），因为分布式文档路由要求主分片是定值，但是每个主分片的副本数（默认值是 1）是可以随时修改的。

#### 分片与副本的关系

我们假设有一个集群由三个节点组成(Node1 , Node2 , Node3)。 它有两个主分片(P0 , P1)，每个主分片有两个副本分片(R0 , R1)。相同分片的副本不会放在同一节点，所以我们的集群看起来如下图所示 “有三个节点和一个索引的集群”。

![threenodeoneindexcluster](https://img2018.cnblogs.com/blog/1162587/201811/1162587-20181106221534193-554135498.png)

副本与分片的关系：**副本是乘法，越多越浪费，但也越保险。分片是除法，分片越多，单分片数据就越少也越分散。**

#### 为什么es快

[Elasticsearch－基础介绍及索引原理分析](https://www.cnblogs.com/dreamroute/p/8484457.html)

1. es建立倒排索引，生成term与对应的posting list，会对term进行排序，然后通过二分查找形成term dictionary
2. 为了减少磁盘IO，需要将一些数据缓存到内存中，但因为term dictionary太大，于是根据term dictionary建立term index，**term index在内存中是以FST形式保存的**，大大节省了空间
3. 对posting list也可以进一步压缩，**增量编码压缩**，将大数变小数，按字节存储
4. 对posting list还可以用**roaring bitmap**压缩
5. 如果是联合索引，用**跳表**检索posting list会更快
6. MySQL只有term dictionary这一层，是以B+树存储的，检索一个term需要若干次random access的磁盘IO，而Lucene在term dictionary的基础上添加了term index来加速检索

### RAID

RAID是英文Redundant Array of Independent Disks的缩写，中文简称为独立冗余磁盘阵列。简单的说，RAID是一种把多块独立的硬盘（物理硬盘）按不同的方式组合起来形成一个硬盘组（逻辑硬盘），从而提供比单个硬盘更高的**存储性能**和提供**数据备份**技术。

组成磁盘阵列的不同方式称为RAID级别（RAID Levels）。在用户看起来，组成的磁盘组就像是一个硬盘，用户可以对它进行分区，格式化等等。总之，对磁盘阵列的操作与单个硬盘一模一样。

RAID 0代表**最高的存储性能**。RAID 0提高存储性能的原理是**把连续的数据分散到多个磁盘上存取**，这种数据上的**并行操作可以充分利用总线的带宽**，显著提高磁盘整体存取性能。磁盘空间率是100%，是**成本最低的**。RAID 0的缺点是不提供数据冗余**，因此一旦用户数据损坏，损坏的数据将无法得到恢复。RAID0运行时只要其中任一块硬盘出现问题就会导致整个数据的故障。

RAID1是将一个两块硬盘所构成RAID磁盘阵列，其容量仅等于一块硬盘的容量，因为另一块只是当作数据“镜像”，磁盘空间使用率只有50%，是**成本最高的**。RAID1磁盘阵列显然是**最可靠**的一种阵列，因为它总是保持一份完整的数据备份。它的性能自然没有RAID0磁盘阵列那样好，但其数据读取确实较单一硬盘来的快，因为数据会从两块硬盘中较快的一块中读出。RAID1磁盘阵列主要用在数据安全性很高，而且要求能够快速恢复被破坏的数据的场合。

RAID 5是RAID 0和RAID 1的折中方案。RAID 5具有和RAID0相近似的数据读取速度，只是多了一个奇偶校验信息，写入数据的速度比对单个磁盘进行写入操作稍慢。同时由于多个数据对应一个奇偶校验信息，RAID5的磁盘空间利用率要比RAID 1高，存储成本相对较低，是目前运用较多的一种解决方案。磁盘空间利用率：(N-1)/N，即只浪费一块磁盘用于奇偶校验。冗余：只允许一块磁盘损坏。

### SSD技术

SSD（Solid state disk）固态硬盘

HDD机械硬盘有马达、机械臂等机械部件，所以读写很慢，SSD使用的存储元件是NAND是一种场效晶体管（电子元件），不需要花费时间在操作机械上，所以很快。

相比HDD，SSD还有如下优点：没有噪音、工作温度范围更大、抗震。

向NAND闪存中写入数据前都需要擦除存储单元，写入的最小单位是页（page），擦除的最小单位是块（block），一个块可能有128~256页。

LBA，全称为Logical Block Address，是PC数据存储装置上用来表示数据所在位置的通用机制，我们最常见到使用它的装置就是硬盘。LBA可以指某个数据区块的地址或者某个地址上所指向的数据区块。打个比方来说，LBA就等于我们平常使用的门牌地址。

PBA全称为Physics Block Address，相对于LBA来说，它就如GPS定位所使用的经纬度。

FTL（Flash translation layer，闪存转换层）：闪存的读写单位为页，而页的大小一般为4KB或8KB，但我们的操作系统读写数据是按HDD的扇区尺寸进行的（512Byte），更麻烦的是闪存擦除以块作单位，而且未擦除就无法写入，这导致操作系统现在使用的文件系统根本无法管理SSD。SSD采用软件的方式把闪存的操作虚拟成磁盘的独立扇区操作，这就是FTL。因FTL存在于文件系统和物理介质（闪存）之间，操作系统只需跟原来一样操作LBA即可，而LBA到PBA的所有转换工作，就全交由FTL负责。

WL（Wear leveling，磨损平衡）：WL是确保闪存内每个块被写入的次数大致相等的一种机制，这样可以延长SSD寿命。WL算法有动态及静态两种，简单来说动态WL是每次都挑最年轻的闪存块使用，老闪存块尽量不用。静态WL就是把长期没有修改的老数据从年轻的闪存块里搬出来，重新找个最老的闪存块存放，这样年轻的闪存块就能再次被经常使用。

GC（Garbage Collection，垃圾回收）：WL的执行需要有“空白”块来写入更新后的数据。当可以直接写入数据的备用“空白块”数量低于一个阈值，那么SSD主控就会把包含“无效”数据的块里所有“有效”数据合并起来放到新的“空白”块里，并删除“无效”数据块来增加备用的“空白块”数量。这个操作就是SSD的GC机制。

BBM（Bad Block Management）坏块管理

ECC（Error Checking and Correction）校验和纠错

OP（Over-provisioning，预留空间）： SSD上的OP指的是用户不可操作的容量，大小为实际容量减去用户可用容量，OP区域一般被用于优化操作如：WL，GC和坏块映射等。

Trim：

- 当我们在操作系统中删除一个文件时，系统并没有真正删掉这个文件的数据，它只是把这些数据占用的地址标记为‘空’，即可以覆盖使用。但这只是在文件系统层面的操作，硬盘本身并不知道那些地址的数据已经‘无效’，除非系统通知它要在这些地址写入新的数据。在HDD上本无任何问题，因为HDD允许覆盖写入，但到SSD上问题就来了，我们都已知道闪存不允许覆盖，只能先擦除再写入，要得到‘空闲’的闪存空间来进行写入，SSD就必须进行GC操作。在没有Trim的情况下，SSD无法事先知道那些被‘删除’的数据页已经是‘无效’的，必须到系统要求在相同的地方写入数据时才知道那些数据可以被擦除，这样就无法在最适当的时机做出最好的优化，既影响GC的效率（间接影响性能），又影响SSD的寿命。
- Trim只是一个指令，它让操作系统通知SSD主控某个页的数据已经‘无效’后，任务就已完成，并没有更多的操作。Trim指令发送后，实际工作的是GC机制。Trim可减少WA的原因在于主控无需复制已被操作系统定义为‘无效’的数据（Trim不存在的话，主控就不知道这些数据是无效的）到‘空闲’块内，这代表要复制的‘有效’数据减少了，GC的效率自然也就提高了，SSD性能下降的问题也就减弱了。其实Trim的意义在于它能大量减少“有效”页数据的数量，大大提升GC的效率。

WA（Write Amplification，写入放大）：

- WA是闪存及SSD相关的一个极为重要的属性。由于闪存必须先擦除才能再写入的特性，在执行这些操作时，数据都会被移动超过1次。这些重复的操作不单会增加写入的数据量，还会减少闪存的寿命，更吃光闪存的可用带宽而间接影响随机写入性能。
- 举个最简单的例子：当要写入一个4KB的数据时，最坏的情况是一个块里已经没有干净空间了，但有无效的数据可以擦除，所以主控就把所有的数据读到缓存，擦除块，缓存里更新整个块的数据，再把新数据写回去，这个操作带来的写入放大就是: 实际写4K的数据，造成了整个块（共1024KB）的写入操作，那就是放大了256倍。同时还带来了原本只需要简单一步写入4KB的操作变成：闪存读取 (1024KB)→缓存改（4KB）→闪存擦除（1024KB）→闪存写入（1024KB），共四步操作，造成延迟大大增加，速度变慢。所以说WA是影响 SSD随机写入性能和寿命的关键因素。
- 降低WA：
  1. 优先顺序写：顺序写(sequential write)可以减少SSD内部垃圾回收(garbage collection)数据的移动量，降低写放大。
  2. 大数据块传输：相比小数据块传输，大数据块写有更小的写放大。
  3. IU（Indirection Unit）对齐: 没有对齐IU的写操作会使SSD进行“read-modify-write”操作并导致写放大，影响SSD性能和寿命。为了避免这一现象，尽量将写操作时放在IU的整数倍逻辑地址上进行
  4. 启用TRIM：TRIM功能开启后，host删除的数据会被及时擦除从而产生更多的可用空间，降低写放大

Aligned clusters and sectors格式化对齐

### 持久内存

- Intel中文官方命名为“英特尔傲腾持久内存”，简称为“持久内存”，Intel Optane Persistent Memory（PMem）
- 存储金字塔中，持久内存处于外存（HDD或者SSD）以及内存DRAM之间
- 特征：
  - 大：目前持久内存**单条**内存容量最大可以达到 512 GB，而目前服务器单条内存一般最多到 32/64 GB，
  - 快：较于普通 SSD 有1-2个数量级的延迟性能优势，较于硬盘优势更大，当然对比DRAM性能有差距
  - 持久性：断电重启数据依然存在，这项特性秒杀内存
- 场景：
  - 大内存低成本解决方案：如为了性能考虑必须使用内存，比如内存数据库Redis
  - 高性能持久化需求的应用：如消息队列需要持久化，吞吐最终卡在磁盘IO上，可以使用持久内存来提高吞吐

### 加密与安全

[图解 | 数字签名和数字证书的前世今生](https://mp.weixin.qq.com/s/Y4rC3IeRyOSpJRsjRBLhqw)

哈希算法、对称加密与非对称加密

**哈希算法**/摘要算法（Digest），对任意一组输入数据进行计算，得到一个**固定长度**的输出摘要。

- 主要用来**验证原始数据是否被篡改**。
- 主要有MD5（现在可破解了）、SHA算法。
- 很多文件下载时都会提供MD5，防止下载过程中被人篡改。

1. 相同的输入一定得到相同的输出；
2. 不同的输入大概率得到不同的输出。

分辨数据编码技术是否是加密算法，一个区分的简单方法就是看编码后的数据是否还能还原，能还原的是加密。MD5 实际上是对数据进行**有损压缩**，无论数据有多长，1KB、1Mb 还是 1G，都会生成固定 128 位的散列值，并且 MD5 理论上是不可能对编码后的数据进行还原的，即不可逆。

**对称加密**就是用一个密码进行加密和解密，如DES、AES

**非对称加密**就是加密和解密使用的不是相同的密钥只有同一个**公钥-私钥对**才能正常加解密。因此，如果小明要加密一个文件发送给小红，他应该首先向小红索取她的公钥，然后，他用小红的公钥加密，把加密文件发送给小红，此文件只能由小红的私钥解开，因为小红的私钥在她自己手里，所以，除了小红，没有任何人能解开此文件。公钥和私钥是相对的，可以互相转换。如RSA

**数字签名**用私钥加密消息，其他人用公钥验证**确认是自己发出**，正好与非对称加密相反

- 一般而言，我们不会直接对数据本身直接计算数字签名
- 因为数字签名属于非对称加密，非对称加密依赖于复杂的数学运算，包括大数乘法、大数模等等，耗时比较久。
- 如果数据量大的时候计算数字签名将会比较耗时，所以一般做法是先将原数据进行 Hash 运算，得到的 Hash 值就叫做「摘要」。

**数字证书**可以实现公钥防篡改，解决了如何安全分发公钥的问题，也奠定了信任链的基础。

**数字证书（Certificate Authority）**就是集合了多种密码学算法，实现了数据加解密、身份认证、签名等多种功能的一种安全标准。HTTPS就用了数字证书，建立TCP连接后，会安装服务器发来的数字证书

### 网络攻击

XSS(Cross Site Scipting)攻击，通过注入恶意指令代码到网页，用户访问网页就会并执行攻击者恶意制造的代码。这些恶意网页程序通常是JavaScript，也可以包括Java、Flash甚至是普通的HTML。

在留言板中输入`<script>alert(“hey!you are attacked”)</script>·

危害：

- 窃取网页浏览中的cookie值
- 劫持流量实现恶意跳转

SQL注入：将恶意的SQL查询或添加语句插入到应用的输入参数中，后台会访问SQL数据库，从而造成攻击

危害：

- 猜解后台数据库，这是利用最多的方式，盗取网站的敏感信息。
- 绕过认证，列如绕过验证登录网站后台。
- 注入可以借助数据库的存储过程进行提权等操作

### IM(Instant Messaging，即时通讯)架构

[表格存储Tablestore权威指南（持续更新）](https://yq.aliyun.com/articles/699676?spm=a2c4e.11153940.0.0.fd972d96rTfaw6)

IM系统中最核心的部分是消息系统，消息系统中最核心的功能是消息的**同步（在线&离线&多端同步）**、**存储（消息漫游）**和**检索（在线检索）**

Tablestore是阿里云自主研发的分布式NoSQL数据库

Timeline模型，消息队列，每条消息对应一个ID，保证新消息的ID**严格递增**，还支持自定义索引，支持布隆过滤器

![Timeline](https://yqfile.alicdn.com/88ce41f615e110588bc481e6d59e61eb0b43cfed.png)

- 消息同步就用到了Timeline模型，每个接收端同步完毕后，都会在本地记录下最新同步消息的ID，称为位点，作为下次同步的起始位点，所以各接收端可以在任意时间从任意点开始拉去消息
- 消息存储也是基于Timeline实现，每个对话都对应一个独立的Timeline，服务器端对每个消息队列进行持久化，这样就支持**消息漫游**了
- 消息检索基于Timeline提供的消息索引实现，支持多字段索引

消息同步模型分为：**读扩散**与**写扩散**

[消息同步之读扩散与写扩散](https://yqfile.alicdn.com/bc6dd8da57be5f785c1ab07c384daa77eb0af724.png)

- 读扩散：每个Timeline保存这个会话的全量消息，新消息只需要写一次到用于存储的Timeline中，接收端从这个Timeline拉去消息。
    优点：只需要一次写。存储空间更少
    缺点：需要读多次，对于每个会话都要拉去一次才能获得全部消息，可能有的是空的。
- 写扩散：每个接收端都有一个**额外的Timeline**专门用来消息同步（又叫收件箱），除消息除了写入用来存储的Timeline，还要写入同步接收端的收件箱。
    优点：减少读压力
    缺点：写次数会增加，特别是多人群的场景，如果是N人群，那每条消息都会额外写N次
- IM场景一般读多写少，所以一般**用写扩散来平衡读写**，但是也有混合模式，来适应万人大群这种极端情况

为了减少网络IO，接收端不可能周期性拉取同步库的消息，一般用**会话池**来实现

[如何设计一个亿级消息量的 IM 系统](https://xie.infoq.cn/article/19e95a78e2f5389588debfb1c)

### 多人对战情况下如何设计数据传输

- - - - - - - - - - - - - - -
记得是帧同步还是状态同步  做游戏好像都会问
TODO

### 微博粉丝关注的场景设计题

场景题：需求：谁关注了我，我关注了谁，谁与我互相关注。表该如何设计，索引怎么建。查询语句怎么写

粉丝关注表使用四列，主键id，userId，fansId，是否互相关注。用两行数据来保存互相的关注关系，这样查询起来更方便，用空间换时间。

主键有主键索引，剩下的字段不适合建索引，因为字段重复太多。

### 扫码登录

网页端+服务器

- 二维码的生成：用户打开网站，首先会自动发送获得二维码的请求，服务器随机生成一个uuid，将这个id设为key存入redis，同时设置一个过期时间，同时服务器会把uuid和本公司的验证字符串合在一起，调用生成二维码的api返回给用户
- 用户未扫码登录：浏览器拿到二维码和uuid，定时发送登录与否的事件给服务器，如果这段时间用户没有扫码登录，则需要再重新生成一个二维码（重复刚才的步骤）。
- 用户扫码：用户扫描二维码可以获得uuid，然后手机端就可以发送一个扫码的请求给服务器，服务器确认扫码，返回成功，用户的手机即可显示『扫码成功』
- 用户确认登录：用户选择确认登录，发送登录请求给服务器，服务器确认登录，返回成功，用户的手机即可显示『登录成功』
- 浏览器刷新：浏览器的定时事件可以知道服务器的登录信息已经更新了，于是登录进去；也可以由服务端主动推送登录成功的事件，浏览器收到事件然后登录进去

### 短url

可以通过发号器的方式正确的生成短地址，生成算法设计要点如下：

- 利用放号器，初始值为0，对于每一个短链接生成请求，都**递增**放号器的值，再将此值转换为62进制（a-zA-Z0-9），比如第一次请求时放号器的值为0，对应62进制为a，第二次请求时放号器的值为1，对应62进制为b，第10001次请求时放号器的值为10000，对应62进制为sBc。
- 将短链接服务器域名与放号器的62进制值进行字符串连接，即为短链接的URL，比如：t.cn/sBc。
- 重定向过程：生成短链接之后，需要存储短链接到长链接的映射关系，即sBc -> URL，浏览器访问短链接服务器时，根据URL Path取到原始的链接，然后进行**302重定向**。映射关系可使用**K-V存储**，比如Redis或Memcache。

具体的流程细节如下：

- 用户访问短链接：t.cn/RuPKzRW；
- 短链接服务器t.cn收到请求，根据URL路径RuPKzRW获取到原始的长链接（KV缓存数据库中去查找）：`blog.csdn.net/xlgen157387…`
- 服务器返回302状态码，将响应头中的Location设置为：blog.csdn.net/xlgen157387…
- 浏览器重新向`https://blog.csdn.net/xlgen157387/article/details/79863301`发送请求；
- 返回响应；

采用以上算法，如果不加判断，那么即使对于同一个原始URL，每次生成的短链接也是不同的，这样就会浪费存储空间（因为需要存储多个短链接到同一个URL的映射），如果能将相同的URL映射成同一个短链接，这样就可以节省存储空间了。主要的思路有如下两个：

- 方案1：**查表**，每次生成短链接时，先在映射表中查找是否已有原始URL的映射关系，如果有，则直接返回结果。很明显，这种方式效率很低。
- 方案2：使用**LRU本地缓存**，空间换时间，使用固定大小的LRU缓存，存储最近N次的映射结果，这样，如果某一个链接生成的非常频繁，则可以在LRU缓存中找到结果直接返回，这是存储空间和性能方面的折中。

分布式解决方案：在以上描述的系统架构中，如果发号器用Redis实现，则Redis是系统的瓶颈与单点，因此，利用数据库分片的设计思想，可部署多个发号器实例，每个实例负责特定号段的发号，比如部署10台Redis，每台分别负责号段尾号为0-9的发号，注意此时发号器的步长则应该设置为10（实例个数）。

### 链路跟踪

Google Dapper是在生产环境下的分布式跟踪系统，**低损耗、应用透明的、大范围部署**。

植入点是少量通用组件库的改造

低采样率可能会丢弃掉部分追踪信息。不过由于动态采样机制，低采样率对应的是高频的服务，所以一些标志性的事件在高频率访问的情况下仍然会反复出现而被捕捉到。

日志系统主要分为三大类tracing、logging、Metrics。集团内EagleEye就是Dapper在阿里的实现，主要定位在tracing。

### 搜索引擎

[图解 | 通用搜索引擎背后的技术点](https://mp.weixin.qq.com/s/p238OC_sr9C2vf5v3pSKbQ)

- 网络爬虫模块：搜索引擎中的网络爬虫就是网页的搬运工，负责将互联网上允许被抓取的网页进行下载，遍历策略有：DFS、BFS、部分pagerank等等，爬虫需要遵守Robots协议，有些是不能抓的，而且抓取频率不能对网站造成影响
- 内容处理模块：负责将网络爬虫下载的页面进行内容解析、内容清洗、主体抽取、建立索引、链接分析、反作弊等环节。
- 内容存储模块：存储模块是搜索引擎的坚强后盾，将抓取的原始网页、处理后的中间结果等等进行存储，这个存储规模也是非常大的，可能需要几万台机器。
- 用户解析模块：用户模块负责接收用户的查询词、分词、同义词转换、语义理解等等，去揣摩用户的真实意图、查询重点才能返回正确的结果。
- 内容排序模块：结合用户模块解析的查询词和内容索引生成用户查询结果，并对页面进行排序，是搜索引擎比较核心的部分。基于词频和位置权重的排序（早期）；基于链接分析的排序（PageRank）；

### 日志

[日志：每个软件工程师都应该知道的有关实时数据的统一概念](https://www.oschina.net/translate/log-what-every-software-engineer-should-know-about-real-time-datas-unifying?lang=chs&p=1)

[简版](https://mp.weixin.qq.com/s/RJzd9ZfqxCPo89CYOb37WQ)

[笔记](https://www.cnblogs.com/foreach-break/p/notes_about_distributed_system_and_The_log.html)

这里讨论的是**结构化的提交日志** (commit log/journal/WAL)，这些日志通常是只往后**追加写**数据，这里的序号暗含着逻辑时间，是给机器看的。与之相对的，是cout, print等应用日志记录，应用日志记录是给人看的。

数据库中的日志：

- 故障恢复：**WAL落盘**便可告诉客户端提交成功，即使数据库故障，也能从WAL恢复
- 数据复制：日志 (如 BinLog) 的 pub/sub 机制可以用来在主节点与复制节点之间同步数据，通过日志还可以知道同步进度
- 最终一致性：日志的逻辑顺序保证了主节点与复制节点之间数据的一致性

分布式系统中的日志：

- **以日志为中心**：数据库利用日志来解决的问题，也是所有分布式系统需要解决的根本问题，如刚才提到的故障恢复、数据同步、数据一致性等等，可以称之为以日志为中心 (log-centric) 的解决方案。
- **状态机复制原则**：如果两个相同的 (identical)、确定 (deterministic) 的进程以相同的状态启动，按相同的顺序获取相同的输入，它们将最终达到相同的状态

日志为中心的设计：

- 主备：**主节点接收所有的读写请求**，每条写入的数据被记录到日志中，从节点通过订阅日志、执行操作来同步数据状态。如果主节点发生故障，就在从节点中选择一个作为新的主节点
- 状态机复制：不存在主节点，所有的**写操作先进入日志**，所有节点都通过订阅日志，执行操作来生成本地状态

数据库与日志是**对偶**的，日志记录着数据表的变化，数据表记录着数据的最新状态。完整的操作日志可以让我们做时空穿梭，回溯到数据的任何一个历史状态。
