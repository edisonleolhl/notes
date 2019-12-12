# C++ Pirmer 中文版（第五版）——第5-7章笔记

第 5 章 语句 153
5.1 简单语句 154
5.2 语句作用域 155
5.3 条件语句 156
5.3.1 if 语句 156
5.3.2 switch 语句 159
5.4 迭代语句 165
5.4.1 while 语句 165
5.4.2 传统的 for 语句 166
5.4.3 范围 for 语句 168
5.4.4 do while 语句 169
5.5 跳转语句 170
5.5.1 break 语句 170
5.5.2 continue 语句 171
5.5.3 goto 语句 172
5.6 TRY 语句块和异常处理 172
5.6.1 throw 表达式 173
5.6.2 try 语句块 174
5.6.3 标准异常 176
小结 178
术语表 178
第 6 章 函数 181
6.1 函数基础 182
6.1.1 局部对象 184
6.1.2 函数声明 186
6.1.3 分离式编译 186
6.2 参数传递 187
6.2.1 传值参数 187
6.2.2 传引用参数 188
6.2.3 const 形参和实参 190
6.2.4 数组形参 193
6.2.5 main：处理命令行选项 196
6.2.6 含有可变形参的函数 197
6.3 返回类型和 return 语句 199
6.3.1 无返回值函数 200
6.3.2 有返回值函数 200
6.3.3 返回数组指针 205
6.4 函数重载 206
6.4.1 重载与作用域 210
6.5 特殊用途语言特性 211
6.5.1 默认实参 211
6.5.2 内联函数和 constexpr 函数 213
6.5.3 调试帮助 215
6.6 函数匹配 217
6.6.1 实参类型转换 219
6.7 函数指针 221
小结 225
术语表 225
第 7 章 类 227
7.1 定义抽象数据类型 228
7.1.1 设计 Sales_data 类 228
7.1.2 定义改进的 Sales_data 类 230
7.1.3 定义类相关的非成员函数 234
7.1.4 构造函数 235
7.1.5 拷贝、赋值和析构 239
7.2 访问控制与封装 240
7.2.1 友元 241
7.3 类的其他特性 243
7.3.1 类成员再探 243
7.3.2 返回 * this 的成员函数 246
7.3.3 类类型 249
7.3.4 友元再探 250
7.4 类的作用域 253
7.4.1 名字查找与类的作用域 254
7.5 构造函数再探 257
7.5.1 构造函数初始值列表 258
7.5.2 委托构造函数 261
7.5.3 默认构造函数的作用 262
7.5.4 隐式的类类型转换 263
7.5.5 聚合类 266
7.5.6 字面值常量类 267
7.6 类的静态成员 268

## Chapter5 语句

仅有顺序执行远远不够，C++提供了一组**控制流（flow-of-control）**语句以支持更复杂的执行路径

### 简单语句

**表达式语句（expression statement）**，作用是执行表达式并丢弃掉求值结果

```c++
ival + 5; //没什么实际作用
cout << ival; //有用
```

**空语句（null statement）**，只有一个单独的分号，最好加上注释，提醒该语句是有意省略的

```c++
//重复读入数据直到到达文件末尾或某次输入的值等于sought
while(cin >> && s != sought)
  ; //空语句
```

别漏写分号，**也别多写分号**

```c++
ival = v1 + v2;; //正确，第二个分号表示一条多余的空语句
while(iter != svec.end()) ; // while的循环体是一条空语句！这将无休止的循环下去
	++iter;										// 递增运算不属于while！
```

**复合语句（块）**是指用花括号括起来的（可能为空）语句的声明的序列，复合语句也被称作**块（block）**，一个块就是一个作用域，在块中引入的名字只能在块内部以及嵌套在块中的子块里访问

如果在程序某个地方，**语法上需要一条语句**，逻辑上需要多条语句，则应该使用复合语句，例如while和for的循环体必须是**一条语句**，但我们常常在循环体内做很多事情，因此就需要将多条语句用花括号括起来

```c++
while(val <= 10){
	sum += val;
	++val;
}

while(val <= 10)
  sum += val;
	++val;				//这条语句不在while循环里面！
```

空块就是指内部没有任何语句的一对花括号，作用等价于空语句

### 语句作用域

这里很简单，就是定义在if、switch、for、while内部的变量只在它们可见

### 条件语句

#### if语句（if statement）

可含else分支，也可以不含，condition一定要用圆括号括起来，可以是一个表达式，也可以是一个初始化了的变量生命，不管是表达式还是变量，**其类型都必须能转换成布尔类型**，通常下statement和statement2是块语句

```
if (condition)
	statement
	
if (condition)
	statement
else
	statement2
```

##### 悬垂else（dangling else）

既有if语句又有else语句时，有时候if分支会多余else分支，怎么知道某个else是与哪个if匹配的呢？

这个就是悬垂else，不同语言解决这个问题的思路也不同，C++规定**else与离它最近的尚未匹配的if匹配**，从而消除程序的二义性

C++不像Python对缩进那么敏感，有时从缩进格式上看，else是与某个if匹配，然而实际上是与另一个if匹配，这要非常小心

避免悬垂else相关的问题非常简单，**if、else后面都用花括号即可**

```c++
if(i > 10)
	if(i > 15)
		;
else						//else实际上与第二个if匹配，而不像缩进的那样与第一个if匹配
	;
	
if(i > 10){
	if(i > 15){
		;
	}						//第二个if在这里已经结束了
}else{				//确保else与第一个if匹配
	;
}
```

#### switch语句（switch statement）

```c++
switch(ch){
	case 'a':
		++acnt;
		break;
	case 'e':
		++ecnt;
		break;
	case 'i':
		++icnt;
		break;
}
```

switch语句首先对圆括号内的表达式求值，可以是一个初始化的变量声明，**表达式的值转换成整数类型**，然后与每个**case标签（case label）**的值进行比较，case标签必须是**整型常量表达式**，不能用逗号运算符，任何两个case标签不能相同

如果表达式和某个case标签匹配，则会从该标签之后的第一条语句开始执行，直到switch的结尾或遇到一条break语句

注意一定搞清楚要不要省略每个case标签的break语句，如果真的要几个标签同享一组操作，可以省略，如果分开操作，一定要记得写break！

> 建议：最后一个标签后面加上break，利于拓展

##### default标签（default label）

如果任何一个case标签没有匹配switch表达式的值，程序将执行default标签后面的语句

```c++
switch(ch){
	case 'a':
		++acnt;
		break;
	default:
		++otherCnt;
		break;
}
```

标签不应该孤零零出现，它后面必须跟上一条语句或者另外一个case标签，如果switch结构以一个空的default标签作为结束，则该default标签后面必须跟上一条空语句或一个空块

> 建议：即使不在default内做任何操作，写上default标签也有助于提高可读性

##### switch内部的变量定义

switch的控制流可能会跨过某些case标签，如果被跨过的标签中含有变量的定义，就需要格外小心

C++规定不允许跨过变量的初始化语句直接跳转到该变量作用域内的另一个位置

如果需要为某个case标签定义并初始化某个变量，应该把冰凉定义在块内，确保后面的case标签都位于变量的作用于之外

```c++
case true:
  {
    string file_name = get_file_name();
  }
  break;
case false:
	cout << file_name << endl;			//错误：file_name不在作用域内
```

### 迭代语句

#### while语句（while statement）

只要条件为真，while语句就重复地执行循环体，一般要在条件本身或者在循环体中设法改变表达式的值，否则无限循环，可以在condition中定义变量，前提是要能转换成布尔类型

```c++
while(condition)
	statement
```

#### 传统for语句

传统for语句的语法形式如下

```c++
for(init-statement; condition; expression)
	statement
```

关键字for及括号里的部分称作for语句头

init-statement必须是以下三种形式中的一种：声明语句、表达式语句或空语句

一般情况下，init-statement负责初始化一个值，这个值将随着循环的进行而改变，condition作为循环控制的条件，只要conditon为真，就执行一次statement，如果condition第一次求值的结果是false，则statement一次也不会执行，expression修改init-statement初始化的变量，这个变量正好就是condition检查的对象，修改发生在每次循环迭代之后，statement可以使一条单独语句也可以是一条复合语句

注意for语句头中定义的对象只在for循环体内可见

##### for语句头里的多重定义

因为init-statement只能有一条声明语句，所以若想定义多个变量，则所有变量的基础类型必须相同

##### 省略for语句头的某些部分

init-statement、condition、expression中的任何一个（或全部）都可以省略掉，但分号要保留

#### 范围for语句

C++11引入了范围for语句，可以遍历容器或其他序列的所有元素

```c++
for(declaration : expression)
	statement
```

expression表示的必须是个序列，如用花括号括起来的初始值列表，或vector或string等类型的对象，这些类型的共同特点是拥有能返回迭代器的begin和end成员

declaration定义一个变量，序列中的每个元素都得能转换成该变量的类型，确保类型相容最简单的方法就是使用auto关键字，如果要对序列中的元素进行写操作，循环变量必须声明成引用类型

范围for语句的定义来源于传统for语句，而传统for语句一般在condition处判断是否到达序列的结尾，所以范围for语句不应该添加or删除序列中的元素，有可能会出错

#### do while语句

do while语句与while语句非常相似，唯一的区别就是，do while先执行循环体再检查条件，所以不管条件如何，至少执行了一次循环体

```c++
do
	statement
while(conditon);
```

condition不能为空，conditon使用的变量必须定义在循环体之外，condition中不能定义变量

### 跳转语句

跳转语句中断当前的执行过程C++提供了4种跳转语句：break、continue、goto、return

#### break语句

break语句负责终止离它最近的while、do while、for或switch语句，并从这些语句之后的第一条语句开始继续执行

break语句只能出现在迭代语句或switch语句内部（包括嵌套在此类循环里的语句或块的内部），break语句的作用范围仅限于最近的循环或者switch

#### continue语句

continue语句终止最近的循环的当前迭代并立即开始下一次迭代，只能出现在for、while和do while循环的内部，或者嵌套在这些循环的语句里，仅作用于离它最近的循环，**注意continue对switch不起作用**

#### goto语句

警告⚠️：不要使用goto语句！完全不用！因为它使得程序既难理解又难修改

### try语句块和异常处理

异常是指存在于运行时的反常行为，这些行为超出了函数正常功能的范围

当程序的某部分检测到一个它无法处理的问题时，需要用到异常处理，此时，检测出问题的部分应该发出某种信号以表明程序遇到了故障，无法继续下去了，而且信号的发出方无须直到故障将在何处解决，一旦检测出异常，检测出问题的那部分也就完成了任务

C++异常处理机制包括

- throw表达式（throw expression），异常检测部分使用throw表达式来表示它遇到了无法处理的问题，我们说throw**引发（raise）了**异常

- try语句块（try block），异常处理部分使用try语句块处理异常，try语句块以关键字try开始，并以一个或多个**catch子句（catch clause）**结束，try语句块抛出的异常通常会被某个catch子句处理，catch子句也被称为**异常处理代码（exception handler）**

- 一套异常类（exception class），用于在throw表达式和相关的catch子句之间传递异常的具体信息

#### throw表达式

包含关键字throw和紧随其后的一个表达式，其中表达式的类型就是抛出的异常类型，最后加上分号构成一条表达式语句

这是代码主动引发的异常，当前函数被终止，并将控制权转移给能处理该异常的代码

#### try语句块

通用形式如下

```c++
try{
	program-statements
}catch(exception-declaration){
	handler-statements
}catch(exception-declaration){
	handler-statements
}
```

catch子句包括三部分：关键字，括号内一个对象的声明（称作**异常声明，exception declaration**）以及一个块，某个catch子句处理完异常后，跳过其后的catch子句，直接到达try-catch语句块下面的第一条语句

注意，program-statements一般是块，其中定义的变量在外部、甚至是catch子句内都无法访问

每个标准库异常类都定义了名为what的成员函数，这些函数没有参数，返回值是C风格字符串（const char*）

寻找处理代码的过程与函数调用链刚好相反，当异常被抛出时，首先搜索抛出该异常的函数，如果没有找到匹配的catch子句，终止该函数，并在调用该函数的函数中继续寻找，如果还是没有找到匹配的catch子句，这个新的函数也被终止，继续搜索调用它的函数，**直至找到适当类型的catch子句为止**，如果最终还是没找到任何匹配的catch子句，程序转到名为**terminate**的标准库函数，一般情况下该函数将导致程序非正常退出

如果没有定义try语句的地方发生了异常，也就相当于没有匹配的catch子句，这时系统调用terminate函数终止当前程序运行

> 建议：编写异常安全的代码非常困难
>
> 对于那些确实需要处理异常并继续执行的程序，要确保对象有效、资源无泄漏、程序处于合理状态等

#### 标准异常

C++标准库提供了一些异常类，它们被包含在4个头文件中

- exception头文件定义了最通用的异常类exception，它只报告异常的情况，不提供任何额外信息
- stdexcept头文件定义了集中常用的异常类
- new头文件定义了bad_alloc异常类型
- type_info头文件定义了bad_cast异常类型

| <stdexcept>定义的异常类 | 使用场景                                       |
| ----------------------- | ---------------------------------------------- |
| exception               | 最常见的问题                                   |
| runtime_error           | 只有在运行时才能检测出的问题                   |
| range_error             | 运行时错误：生成的结果超出了有意义的值域范围   |
| overflow_error          | 运行时错误：计算上溢                           |
| underflow_error         | 运行时错误：计算下溢                           |
| logic_error             | 程序逻辑错误                                   |
| domain_error            | 逻辑错误：参数对应的结果值不存在               |
| invalid_error           | 逻辑错误：无效参数                             |
| length_error            | 逻辑错误：试图创建一个超出该类型最大长度的对象 |
| out_of_range            | 逻辑错误：使用一个超出有效范围的值             |

## Chapter6 函数

函数是一个命名了的代码块，我们通过调用函数执行相应的代码，函数可以有0个或多个参数，通常会产生一个结果，可以重载函数，也就是说，一个函数名可以对应几个不同函数

### 函数基础

典型的函数（function）包括以下部分：返回类型（return type）、函数名字、形参（parameter）组成的列表以及函数体，其中形参以逗号隔开，形参的列表位于一对圆括号之内，函数执行的操作在语句块中说明，该语句块称为函数体（function body），**必须有花括号**

通过**调用运算符（call operator）**来执行函数，它是一对圆括号，作用于一个表达式，该表达式是函数或者指向函数的指针，圆括号内是一个用逗号隔开的实参（argument）列表，**用实参初始化函数的形参**，调用表达式的类型就是函数的返回类型

函数的调用完成两项工作：

- 用实参初始化函数对应的形参
- 将控制权转移给被调用函数，此时 **主调函数（calling function）**的执行被暂时中断，**被调函数（called function）**开始执行

执行函数的第一步是（隐式地）定义并初始化它的形参

实参是形参的初始值，虽然是是一一对应的，**但是并没有规定实参的求值顺序**，实参的类型必须与对应的形参类型匹配（允许合法转换），并且数量得相同

函数的形参列表可以为空，但不能省略，为了与C语言兼容，可以使用关键字void表示函数没有形参

```c++
void f1(){}					//隐式地定义空形参列表
void f2(void){}			//显式地定义空形参列表
```

形参列表中的形参通常用逗号隔开，每个形参都是含有一个声明符的声明，即使两个形参的类型一样，也不允许把两个类型都写出来

```c++
int f3(int v1, v2){}			//错误
int f4(int v1, int v2){}	//正确
```

任意两个形参不能同名，且函数最外层作用域中的局部变量也不能与函数形参同名

**函数的返回类型不能是数组或函数，但可以是指向数组或指向函数的指针**

#### 局部对象

C++中，名字有作用域，对象有生命周期

- 名字的作用域是程序文本的一部分，名字在其中可见
- 对象的生命周期是程序执行过程中该对象存在的一段时间

**局部变量（local variable）**：形参和函数体内定义的变量称为局部变量，它们对函数而言是局部的，仅在函数的作用域内可见，同时局部变量还会**隐藏（hide）**在外层作用域中同名的其他所有声明

在所有函数体之外定义的对象存在于程序整个执行过程，此类对象在程序启动时被创建，直到程序结束时才会销毁

**自动对象（automatic object）**：只存在于块执行期间的对象，当块执行结束时，自动对象的值就变成未定义，比如形参就是一种自动对象，函数终止时，形参被销毁

**局部静态对象（local static object）**：局部静态对象在在程序执行路径第一次经过对象定义语句时初始化，并且**直到程序终止才被销毁**，在此期间即使对象所在函数结束执行也不会对它有影响

```c++
//统计函数自身被调用了多少次
size_t count_calls(){
	static size_t ctr = 0;		//结束调用后，这个值仍然有效
	return ++ctr;
}
int main(){
	for(size_t i = 0; i != 10; ++i){
		cout << count_calls() << endl;
	}
	return 0;
}
```

#### 函数声明

和其他名字一样，函数的名字也必须在使用之前声明，类似于变量，函数只能定义一次，但可以声明多次，如果一个函数永远也不会被使用，可以只有声明而没有定义

函数的声明不包括函数体，所以也就无须形参的名字，但是加上形参名还是有好处的，有助于理解

函数的三要素：返回类型、函数名、形参类型，描述了函数的接口，说明调用该函数的全部信息，函数声明也称作**函数原型（function prototype）**

正如变量一样，函数也应该在头文件中声明，在源文件中定义，**定义函数的源文件把含有函数声明的头文件包含进来**，编译器负责验证函数的定义和声明是否匹配

#### 分离式编译（separate compilation）

C++支持分离式编译，允许我们把程序分割到几个文件中去，每个文件独立编译

### 参数传递

每次调用函数时会重新创建它的形参，并用传入的实参进行初始化

如果形参是引用类型，它将绑定到对应的实参上，否则，将实参的值拷贝后赋给形参

- 形参是引用类型，我们说它对应的实参被**引用传递（passed by reference）**或者函数被**传引用调用（called by reference）**，引用形参是它对应的实参的别名
- 形参不是引用类型，这时形参和实参是两个相互独立的对象，我们说这样的实参被**值传递（passed by value）**或者函数被**传值调用（called by value）**

#### 传值参数

初始化一个非引用类型的变量时，初始值被拷贝给变量，此时对变量的改动不会影响初始值

传值参数的原理完全相同，函数对形参的任何操作都不会影响实参

##### 指针形参

指针的行为和其他非引用类型一样，当执行指针拷贝操作时，拷贝的是指针的值，拷贝之后，两个指针是不同的指针，但是可以修改指针所指的对象

```c++
void reset(int *ip){
	*ip = 0; // 改变指针ip所指对象的值
	ip = 0;  // 只改变了ip的局部拷贝，实参未被改变
}
int i = 42;
reset(&i);					//改变i的值，而非i的地址
cout << i << endl;	//输出0
```

> 建议：熟悉C的程序员常常用指针类型的形参访问函数外部的对象，但在C++中，建议使用引用类型的形参替代指针

#### 传引用参数

通过引用形参，函数可以改变实参的值

```c++
void reset(int &i){		//i是传给reset函数的对象的另外一个名字
	i = 0;							//改变了i所引用对象的值
}
int j = 42;
reset(j);							//j采用传引用方式，它的值被改变
cout << j << endl;		//输出0
```

形参i仅仅j的另一个名字，所以在reset内部对形参i操作，实际上就是对实参j进行操作

**引用参数有一个好处**：拷贝大的类类型或容器时很低效，甚至有的类类型（比如IO类型）根本就不支持拷贝操作，所以传入引用参数效率很高，当然前提是不需要改变实参的值

> 建议：如果函数无须改变引用参数的值，最好将其声明为常量引用

**引用参数还有一个好处**：使用引用形参可以返回额外信息，因为函数的返回值只有一个值，如果有两个信息需要返回，一个方法是定义一个新的数据类型，让它包含两个信息，还有一种更简单的办法，那就是利用引用参数，给函数传入一个额外的引用实参，令其存储其中一个信息

#### const形参和实参

复习一下，顶层const作用于对象本身

```c++
const int ci = 42; // 不能改变ci，因为ci具有顶层const
int i = ci;				 // 正确，拷贝忽略了顶层const
int * const p = &i; // const是顶层的，不能给p赋值，即p永远指向i
*p = 0; 						// 正确，可以通过p改变所指对象i的值
```

和其他初始化过程一样，当用实参初始化形参时会忽略掉顶层const，所以形参的const被忽略掉了，传给它常量对象或非常量对象都是可以的

```c++
void fcn(const int i){
	//fcn能够读取i，但不能写i
}
```

注意：C++允许函数重载，但`void fcn(const int i) `与`void fcn(int i)`在编译器看来没什么不同，因为形参的const会被忽略掉！

##### 指针或引用形参与cosnt

形参的初始化方式和变量的初始化方式是一样的，可以用非常量初始化一个底层的const对象，但是反过来不行，同时一个普通的引用必须用同类型的对象初始化

```c++
int i = 42;
const int *cp = &i; //正确，但是cp不能改变i
const int &r = i;		//正确，但是r不能改变i
const int &r2 = 42; //正确，可以用一个字面值初始化一个常量引用
int *p = cp;				//错误，p与cp类型不匹配
int &r3 = 4;				//错误，同上
int &r4 = 42;				//错误：不能用一个字面值初始化一个非常量引用
```

同样的规则应用到参数传递上

```c++
int i = 0;
const int ci = i;
string::size_type ctr = 0;
reset(&i);			//调用形参类型是int*的reset函数
reset(&ci);			//错误，不能用指向const int对象的指针初始化int*
reset(i);				//调用形参类型是int&的reset函数
reset(ci);			//错误，不能把普通引用绑定到const对象ci上
reset(42);			//错误，不能把普通饮用绑定到字面值上
reset(ctr);			//错误，类型不匹配，ctr是无符号类型
find_char("Hello World!", 'o', ctr);		//正确，find_char的第一个形参是对常量的引用
```

要想调用引用形参的reset函数，只能使用int型对象，而不能使用字面值、求值结果为int的表达式、需要转换的对象或者const int型对象

要想调用指针形参的reset函数，只能使用int*型对象

##### 尽量使用常量引用

只要在函数中引用形参不会改变，那就应该使用**常量引用形参**，两个作用

- 这明确地告诉了调用者这个形参无法改变
- 使用常量引用参数打破了限制（可以传入字面值对象，需要转换的对象，const对象）

#### 数组形参

数组的两个特殊性质对我们定义和使用作用在数组上的函数有影响，那就是：**不允许拷贝数组**、**使用数组时会将其转换成指针**（特殊情况除外）

景观不能以值传递的方式传递数组，但是可以把形参写成类似数组的形式，但要注意函数重载时，会把下面三个函数看成等价的，编译器都会认为是const int*

```c++
void print(const int*);
void print(const int[]);		//可以看出来函数的意图是作用于一个数组
void print(const int[10]);	//期望有10个元素，但实际不一定
```

如果传给print函数一个数组，则实参自动转换执行数组首元素的指针，**所以数组的大小对函数的调用没什么影响**

那么如何完整地遍历整个数组呢？

一般管理指针形参有三种常用技术

- 使用标记指定数组长度

  如果数组本身有一个结束标记，那很容易判断，最典型的就是C风格字符串（相当于字符数组），它们都以一个空字符结尾，所以函数在处理C风格字符串时遇到空字符停止

  ```c++
  void print(const char *cp){
  	if(cp){						//保证cp非空
  		while(*cp){			//只要指针当前所指字符非空字符
  			cout << *cp++;//输出当前字符，并后移指针
  		}
  	}
  }
  ```

  但是这种方法仅限于明显结束标记与普通数据不同的数组，像那种元素全是int型的数组就行不通了

- 使用标准库规范

  传递指向数组首元素和尾元素的指针

  ```c++
  void print(const int *beg, const int *end){
  	while(beg != end){
  		cout << *beg++ << endl;
  	}
  }
  
  int j[2] = {0, 1};		//j转换成指向它首元素的指针
  print(begin(j), end(j));		//这里利用了C++11标准库的begin函数与end函数，前文有提到过
  ```

  

- 显式传递一个表示数组大小的形参

  专门定义一个表示数组大小的形参，在C与之前C++中经常使用这种方法

  ```c++
  void print(const int *ia, size_t size){
  	for(size_t i = 0; i != size; ++i){
  		cout << ia[i] << endl;
  	}
  }
  
  int j[] = {0, 1};
  print(j, end(j) - begin(j));
  ```

##### 数组形参和const

同样的，如果函数不需要对数组元素执行写操作，则定义为指向const的指针，如果需要，则普通指针

##### 数组引用形参

形参也可以是数组的引用，引用形参绑定到对应的实参（数组）上，因为数组大小构成数组类型的一部分，所以必不可少

```c++
void print(int (&arr)[10]){
	for(auto elem : arr){
		cout << elem << endl;
	}
}
```

警告⚠️：`int (&arr)[10]`中的括号必不可少，不加括号就变成含有10个int&的数组，而不是指向10个int的数组的引用

##### 传递多维数组

其实C++中没有多维数组，多维数组实际是数组的数组，将多维数组传给函数时，真正传递的是指向数组首元素的指针，也就是一个指向（子）数组的指针，数组第二维（包括后面的维度）都是数组类型的一部分，不能省略

```c++
void print(int (*matrix)[10]){
	//matrix指向数组的首元素，该数组的元素是由10个整数构成的数组
}
```

警告⚠️：括号必不可少，不加括号就变成了含有10个int*元素的数组

也可以用数组的语法定义函数，此时编译器会一如既往地忽略掉第一个维度，所以最好不要把它包括在形参列表内

```c++
void print(int matrix[][10]){} //matrix看起来像是个二维数组，但其实是个指向含有10个整数的数组的指针
```

练习6.22：交换两个int指针的所指的内存地址

```c++
//该参数是一个引用，引用的对象是一个int指针，可以把指针当做对象，交换指针本身的值
void swapPointer(int *&p, int *&q){ 	
    int *temp;
    temp = p;
    p = q;
    q = temp;
}

int main(){
    int i = 42, j = 43, *p = &i, *q = &j;
    swapPointer(p, q);
    cout << "p value: " << *p << endl;
    cout << "q value: " << *q << endl;
}
```

#### main：处理命令行选项

main函数也可以传入实参，常见的情况是用户通过设置一组选项来确定函数所要执行的操作，加入main函数位于可执行文件prog内，可以输入如下的命令

```c++
prog -d -o ofile data0
```

这些命令行选项通过两个（可选的）形参传递

```c++
int main(int argc, char *argv[]){}
```

第二个形参argv是一个数组，它的元素是指向C风格字符串的指针，第一个形参argc表示数组中字符串的数量，因为第二个形参是数组，所以也可以定义成下面这样

```c++
int main(int argc, char **argv){}
```

其中argv指向char*

当实参传给main函数后，argv的第一个元素指向程序的名字或第一个空字符串，接下来的元素依次传递命令行提供的实参，最后一个指针后的元素值保证为0，以上面的命令行为例，argc应该等于5，argv应该包含如下的C风格字符串

```c++
argv[0] = "prog";
argv[1] = "-d";		//可选的实参从argv[1]开始，记住！
argv[2] = "-o";
argv[3] = "ofile";
argv[4] = "data0";
argv[5] = 0；
```

#### 含有可变形参的函数

有时无法提前预知要想函数传递几个实参，C++11提供了两种方法：如果所有的实参类型相同，可以传递一个名为**initializer_list**的标准库类型；如果实参的类型不同，我们可以编写一种特殊的函数，也就是所谓的**可变参数模板**，以后再介绍第二种方法

C++还有一种特殊的形参类型，即省略符，但一般用于与C函数交互的接口程序

##### initializer_list

如果实参数量未知，但是实参类型全部相同，可以用这种类型的形参，它是一种标准库类型，用于表示某种特定类型的数组，initializer_list类定义在同名头文件里

与vector一样，initializer_list是模板类型，需要说明所含元素的类型

```c++
initializer_list<string> ls;
initializer_list<int> li;
```

与vector不同，**initializer_list里的元素永远是常量值**，所以无法改变initializer_list中元素的值，故在用范围for循环遍历initializer_list时可把循环变量定义为常量引用类型

遍历initializer_list和遍历vector差不多，**因为initializer_list也有begin()、end()成员函数**

```c++
void error_msg(initializer_list<string> il){
	for(auto beg = il.begin(); beg != il.end(); ++beg){
		cout << *beg << " ";
	}
	cout << endl;
}
```

向initializer_list形参传递序列，必须要用花括号

```c++
//调用error_msg函数
error_msg({"functionX", "some thing", "other thing"});
```

含有initializer_list形参的函数也可以拥有其他形参

```c++
void error_msg(ErrCode e, initializer_list<string> il){
	cout << e.msg() << ": ";
	for(auto beg = il.begin(); beg != il.end(); ++beg){
		cout << *beg << " ";
	}
	cout << endl;
}
```

##### 省略符形参

省略符是为了便于C++访问C代码而设置的，使用了名为varargs的C标准库功能

省略符形参只能出现在形参列表最后一个位置，逗号可省略，它的形式不外乎两种

```c++
void foo(parm_list, ...)；
void foo(...);
```

省略符形参对应的实参无须类型检查

### 返回类型和return语句

return 语句终止当前函数，并将控制权返回给调用该函数的地方

两种形式

```c++
return;
return expression;
```

#### 无返回值函数

没有返回值的return语句只能出现在返回类型是void的函数中，此时可省略return，因为会隐式执行，当expression是另一个返回void的函数时，也可以使用`return expression;`这种形式

#### 有返回值函数

return语句返回值类型必须与函数的返回类型，或者能隐式转换

一定要确保函数退出时有return语句，这就要求逻辑清晰、面面俱到

返回一个值的方式和初始化一个变量或形参的方式完全一样：**返回的值用于初始化调用点的一个临时量，该临时量就是函数调用的结果**

##### 不要返回局部对象的引用或指针

函数完成后，它所占用的存储空间也随之被释放，因此，函数终止意味着局部变量的引用将指向不再有效的内存区域，指针也是一样的

> 建议：要想确保返回值安全，不妨提问：引用所引的对象是否在函数之前就已经存在？

##### 调用运算符

调用运算符、点运算符、箭头运算符三者优先级相同，都符合左结合律（从左至右执行）

##### 引用返回左值

函数的返回类型如果是引用，返回类型得到左值，其他类型则为右值，我们能为返回类型是**非常量引用**的函数的结果赋值

```c++
char &get_val(string &str, string::size_type ix){		//返回类型是非常量引用，返回类型得到左值
	return str[ix];
}

int main(){
	string s("a value");
	cout << s << endl;			//输出a value
	get_val(s, 0) = 'A';		//将s[0]的值改为A
	cout << s << endl;			//输出A value
	get_val("apple", 0) = 'A'; //错误：形参为string&，但是传入了const string&
  return 0;
}
```

##### 列表初始化返回值

C++11规定，函数可以返回花括号包围的列表，这里的列表可以为返回的临时量进行初始化

```c++
vector<string> process(){
	return{"functionX", "okay"};
}
```

如果函数返回的是内置类型，则花括号包围的列表最多包含一个值，而且该值所占空间不应该大于目标类型的空间，如果返回的是类类型，由类本身定义初始值如何使用

##### 主函数main的返回值

主函数main是个特殊情况，允许主函数main没有return语句直接结束，编译器隐式地掺入一条返回0的return语句

main函数的返回值可以看作状态指示器，返回0表示执行成果，其他值表示执行失败，具体含义依机器而定，为了使返回值与机器无关，cstdlib头文件定义了两个预处理变量

```c++
int main(){
	if(fail){
		return EXIT_FAILURE;
	}else{
		return EXIT_SUCCESS;
	}
}
```

因为它们是预处理变量，所以既不能在前面加上std::，也不能在using声明中出现

##### 递归

函数调用了它本身，无论直接还是间接，都叫**递归函数（recursive function）**

在递归函数中，一定有某条路径不包含递归调用，否则函数将永远递归下去，函数将不断调用自身直到程序栈空间耗尽，称之为**递归循环（recursive loop）**

#### 返回数组指针

因为数组不能被拷贝，所以不能返回数组，但可以返回数组的指针或引用，从语法上来说有点繁琐，但可以用类型别名简化

```c++
typedef int arrT[10];			//arrT是类型别名，表示含有10个整数的数组
using arrT = int[10];			//arrT的等价声明
arrt* func(int i);				//func返回一个指向含有10个整数的数组的指针
```

##### 声明一个返回数组指针的函数

要想在声明func时不用类型别名，必须牢记数组的维度

```c++
Type (*function(parameter_list)) [dimension]
```

Type表示元素类型，dimension表示数组大小，两对括号必须存在

比如，`int (*func(int i))[10]`没有使用类型别名，逐层理解如下

- `func(int i)`表示调用func函数是需要一个int型实参
- `(*func(int i))`表示我们可以对func函数的返回值执行**解引用**操作
- `(*func(int i ))[10]`表示解引用func后将得到一个大小为10的数组
- `int (*func(int i))[10]`表示数组的元素是int型

##### 使用尾置返回类型

C++11有新方法可以简化上述声明，即**尾置返回类型（trailing return type）**，任何函数的定义都能使用尾置返回，但这种形式对于返回类型比较复杂的函数最有效，比如返回类型是数组的指针或引用

尾置返回类型跟在形参列表后，并以`->`符号开头，并且在本应该出现返回类型的地方用auto替换

```c++
auto func(int i) -> int(*)[10];
```

这样可以清楚地看到，func的返回类型是一个指向10个int型元素的数组的指针

##### 使用decltype

如果我们知道函数返回的指针将指向哪个数组，可以用decltype关键字声明返回类型（也是C++11引入的）

```c++
int odd[] = {1, 3, 5, 7, 9};
int even[] = {0, 2, 4, 6, 8};
decltype(odd) *arrPtr(int i){
	return(i % 2) ? &odd : &even;		//返回一个指向数组的指针
}
```

因为odd是一个数组，所以arrPtr返回一个指向含有5个整数的数组的指针

decltype并不负责把数组类型转换成对应的指针，所以decltype的结果是数组，要想表示arrPtr返回指针，必须要加入`*`符号

练习6.36

```c++
//这个函数定义还真有点繁琐。。
//func的形参是一个指向10个string元素的数组的引用
//func的返回值是一个指向10个string元素的数组的引用
string (&func(string (&s)[10]))[10]{				
    return s;
}
int main(){
	  string arr[10] = {"0","1","2","3","4","5","6","7","8","9"};
    for (auto s : func(arr)){
        cout << s << endl;
    }
}
```

练习6.37

```c++
string arr[10] = {"0","1","2","3","4","5","6","7","8","9"};
using string_array = std::string[10];

string_array &funcUsingAlias(string (&s)[10]){
    return s;
}

auto funcUsingTrailing(string (&s)[10]) -> string(&)[10]{
    return s;
}

decltype(arr) &funcUsingDecltype(string (&s)[10]){
    return s;
}

for (auto s : funcUsingAlias(arr)){
    cout << s << endl;
}

for (auto s : funcUsingTrailing(arr)){
    cout << s << endl;
}

for (auto s : funcUsingDecltype(arr)){
    cout << s << endl;
}
```

### 函数重载（overloaded）

同一作用域内的几个函数名字相同但形参列表不同，称之为**重载（overloaded）**

形参的名字只是帮助记忆，并不影响形参列表的内容

如果形参列表完全相同，而返回类型不同，则仍是同一个函数，不能重载

函数的名字仅仅是让编译器知道它调用的是哪个函数，而函数重载可以在一定程度上减轻程序员起名字、记名字的负担

main函数不能重载

##### 重载和const形参

前文提到过，顶层const不影响传入的对象，所以一个拥有顶层const的形参无法和另一个没有顶层const的形参区分开了

```c++
//Record、Phone、Account是自定义的类
Record lookup(Phone);
Record lookup(const Phone);		//顶层const，重复声明了Record lookup(Phone)

Record lookup(Phone*);
Record lookup(Phone* const));	//顶层const，重复声明了Record lookup(Phone*)
```

底层const是可以区分的，也就是说通过区分其指向的是常量对象还是非常量对象可以实现重载

```c++
Record lookup(Account&);
Record lookup(const Account&);	//底层const，新函数

Record lookup(Account*);
Record lookup(const Account*);	//底层const，新函数
```

前文提到过，const不能转换成非const，所以只能把const对象（或指向const的指针）传递给const形参，所以传入const对象（或指向const的指针）时，**编译器只会选用上面的常量版本的函数**

因为非const可以转换成const，所有上面的四个函数都可以接收非常量对象（或指向非常量的指针），**编译器会优先选用非常量版本的函数**

> 建议：何时不应该重载函数？
>
> 重载那些确实非常相似的函数，而很多情况下，给函数起不同的名字有助于程序员理解，这时就不应该重载函数！

##### const_cast和重载

Chapter4讲过，**const_cast在重载函数时最有用**

```c++
const string &shortestString(const string &s1, const string &s2){
	return s1.size() > s2.size() ? s1 : s2;
}
```

shortestString函数的参数和返回类型都是const string的引用，但它可以接收两个非常量string，此时还是会输出const string的引用，因此我们需要一个新的shortestString函数，当它的实参不是常量时，得到的结果是一个普通的string的引用，使用const_cast即可

```c++
string &shortestString(string &s1, string &s2){
	auto &r = shortestString(const_cast<const string &>(s1), const_cast<const string &>(s2));
	return const_cast<string &>(r);
}
```

两个同名函数是重载的，当传入两个非常量string时，编译器会优先选择第二个版本的函数，首先将s1、s2强制转换成了const string的引用，然后调用该函数的const版本，返回const string的引用，最后再强制转换成一个普通string的引用，作为该函数的非const版本的输出

##### 函数匹配（function matching）/ 重载确定（overload resolution）

函数匹配/重载确定是一个过程，在这个过程中我们把函数调用与一组重载函数中的某一个关联起来，编译器将实参与重载函数中每一个函数的形参一一比较，最后决定调用哪个函数

调用重载函数时有三种可能

- 找到一个与实参**最佳匹配（best match）**的函数，调用它
- 找不到任何一个函数与调用实参匹配，此时发出**无匹配（no match）**的错误消息
- 不止一个函数可以匹配，但是都不是最佳选择，此时也将发生错误，称作**二义性调用（ambiguous call）**

#### 重载与作用域

重载对于作用域的一般性质并没有什么改变：如果在内层作用域中声明名字，它将隐藏外层作用域中声明的同名实体，**在不同的作用域中无法重载函数名**

C++中，名字查找发生在类型检查之前

### 特殊用途语言特性

#### 默认实参（default argument）

调用含有默认实参的函数时，可以包含该实参，也可以省略

**注意：一旦某个形参被赋予了默认值，其后的所有形参必须有默认值**

```c++
typedef string::size_type sz;
string screen(sz ht = 24, sz wid = 80, char backgrnd = ' '){};

string window;
window = screen();		//等价于screen(24,80,' ')
window = screen(66);	//等价于screen(66,80,' ')
window = screen(66,256); //等价于screen(66,256,' ')
window = screen(66,256,'#'); //等价于screeN(66,256,'#')

window = screen(, ,'?');	//错误：只能省略尾部的实参
window = screen('?');			//调用screen('?',80,' ')
```

最后一个不会报错，因为`?`是一个char，而string::size_type是一个无符号类型，char可以转换成string::size_type，

>  建议：尽量让不怎么使用默认值的形参出现在前面，经常使用默认值的形参出现在后面

##### 默认实参声明

在给定作用域中一个形参只能被赋予一次默认实参，多次声明一个函数是合法的，函数的后续声明只能为之前那些没有默认值的形参添加默认实参，而且该形参右侧的所有形参都必须有默认值

```c++
string screen(sz, sz, char = ' ');
string screen(sz, sz, char = '*');		//错误：重复声明
string screen(sz = 24, sz = 80, char);//正确：添加默认实参
```

> 建议：应该在函数声明中指定默认实参（一步到位），并将声明放在合适的头文件中

##### 默认实参初始值

局部变量不能作为默认实参，除此之外，只要表达式能转换成形参所需的类型，该表达式就能作为默认实参

```c++
sz wd = 80;
char def = ' ';
sz ht();
string screen(sz = ht(), sz = wd, char = def);
string window = screen();				//调用screen(ht(), 80, ' ')
```

用作默认实参的名字在函数声明所在的作用域内解析，而这些名字的求值过程发生在函数调用时

```c++
void f2(){
	def = '*';						//改变默认实参的值
	sz wd = 100;					//隐藏了外层定义的wd，但是没有改变默认值
	window = screen();		//调用screen(ht(), 80, '*')
}
```

> 为啥def表达式更新，而wd不更新呢？

**注意：默认实参写在函数声明里，而不是函数定义里！函数定义没有默认实参！**

#### 内联函数（inline）

调用函数包含着一系列工作：调用前要先保存寄存器，并在返回时恢复；可能需要拷贝实参；程序转向一个新的位置继续执行

将函数指定为**内联函数（inline）**，通常就是将它在每个调用点上"内联地”展开，用于优化规模较小、流程直接、频繁调用的函数，很多编译器都不支持内联函数，内联说明只是向编译器发起的一个请求，编译器可以选择忽略这个请求

```c++
inline const string &shortestString(const string &s1, const string &s2){
	return s1.size() > s2.size() ? s1 : s2;
}

cout << shortestString(s1, s2) << endl;								//调用函数
cout << (s1.size() > s2.size() ? s1 : s2) << endl;		//实际上编译过程会展开成这样
```

#### constexpr函数

constexpr函数是指能用于**常量表达式**（不能有函数调用符or比较符号等等）的函数，函数的返回类型及所有形参的类型都得是字面值类型，而且函数体中必须有且只有一条return语句

```c++
constexpr int new_sz(){ return 42;}
constexpr int foo = new_sz(); 			//正确，foo是一个常量表达式
```

编译器把constexpr函数的调用替换成其结果值，为了能在编译过程中随时展开，constexpr函数被隐式地指定为内联函数

constexpr函数可以包含其他语句，只要它们部执行任何操作就行，比如空语句、类型别名或using声明

允许constexpr函数的返回值非常量

内联函数与constexpr函数通常定义在头文件，因为它们定义不止一次，而必须在所有源文件中定义完全相同，把内联函数的定义放在头文件中可以确保这一点

#### 调试帮助

头文件保护，选择性地执行调试代码，这些代码在正式发布时要屏蔽，需要用到两项预处理功能：assert和NDEBUG

##### assert预处理宏（preprocessor marco）

所谓预处理宏就是一个预处理变量，行为有点类似于内联函数，assert宏使用一个表达式作为条件

```c++
assert(expr);
```

首先对expr求值，如果表达式为假（即0），assert输出信息并终止程序，如果为真，assert什么也不做

预处理名字由预处理器而非编译器管理，所以可以直接使用预处理名字而无须using声明

和预处理变量一样，宏名字在程序内必须唯一

assert宏常用于检查“不能发生”的条件，比如一个队输入文本进行操作的程序要求所有给定单词的长度都大于某个阈值，此时可以加入assert宏

```c++
assert(word.size() > threshold);
```

##### NDEBUG预处理变量

assert的行为依赖于一个名为NDEBUG的预处理变量的状态，如果定义了NDEBUG，则assert什么也不做，默认状态下没有定义NDEBUG，此时assert将执行运行时检查

可以使用`# define`语句定义NDEBUG，从而关闭调试状态，许多编译器提供了命令行选项使我们可以定义预处理变量，该命令的作用等价于在main.c文件的一开始写`# define`

```c++
CC -D NDEBUG main.C # use /D with the Microsoft compiler
```

assert只能用于一种辅助手段，不能用它代替真正的运行时逻辑检查，也不能代替程序本身应该包含的错误检查

除了用于assert外，NDEBUG还可以用来编写条件调试代码，如果没有定义NDEBUG，则执行#ifndef与#endif之间的代码

```c++
#ifndef NDEBUG
	// _ _func_ _是编译器定义的一个局部静态变量，用于存放函数的名字
	cerr << _ _func_ _ << ": array size is " << size << endl;
#endif
```

| 预处理器定义的名字 | 作用                           |
| ------------------ | ------------------------------ |
| `_ _func_ _`       | 存放函数的名字                 |
| `_ _FILE_ _`       | 存放文件名的整型字面值         |
| `_ _LINE_ _`       | 存放文件编译时间的字符串字面值 |
| `_ _TIME_ _`       | 存放文件编译日期的字符串字面值 |
| `_ _DATE_ _`       | 存放文件编译日期的字符串字面值 |

### 函数匹配

假设有下面这组函数

```c++
void f();
void f(int);
void f(int, int);
void f(double, double = 3.14);
f(5.6);			//调用f(double,double)
```



##### 确定候选函数和可行函数

函数匹配的第一步是选定本次调用对应的重载函数集，集合中的函数称为**候选函数（candidate function）**，候选函数具备两个特征：一是与被调用的函数同名，二是其声明在调用点可见

第二部考察本次调用提供的实参，选出**可行函数（viable function）**，也有两个特征，一是其形参与提供的实参数量相等，二是每个实参的类型与对应的形参类型相同，或者可以转换成形参的类型

> 如果函数由默认实参，则函数的形参与提供的实参数量不同，该函数也可以是可行函数

如果没找到可行函数，编译器报无匹配函数的错误

##### 寻找最佳匹配

函数调用的第三步是从可行函数中选择最佳匹配，基本思想是，**实参与形参类型越接近，匹配度越高**，比如精确匹配比需要类型转换的匹配更好

上面的例子中，f(5.6)的可行函数是f(int, int)，f(double double)，但第二个更匹配

最佳匹配的条件

- 该函数每个实参的匹配都不劣于其他可行函数的匹配
- 至少有一个实参的匹配优于其他可行函数的匹配

如果检查了条件之后没有一个可行函数脱颖而出，则该调用是错误的，编译器将报告**二义性调用**的信息

比如调用f(42, 2.56)，f(int, int), f(double,double)是可行函数，但是它们都不满足最佳匹配的条件，所以编译器会报二义性调用的信息，在涉及良好的系统里，不应该对实参进行强制类型转换，在我的Xcode里，在调用时会在编辑器窗口提示“Call to 'f' is ambiguous”

#### 实参类型转换

为了确定精确匹配，编译器将实参类型转换划分成几个等级，排序如下

1. **精确匹配**
   - 实参类型与形参类型相同
   - 实参从数组类型或函数类型转换成对应的指针类型
   - 向实参添加顶层const或从实参中删除顶层const
2. 通过**const转换**实现的匹配（底层const）
3. 通过**类型提升**实现的匹配
4. 通过**算术类型转换**或指针转换实现的匹配
5. 通过**类类型转换**实现的匹配

##### 需要类型提升和算术类型转换的匹配

小整型一般会提升到int类型或更大的整数类型，假设有两个函数，一个是int，一个是short，只有当调用提供的是short类型时才会选择short版本，有时候，即使实参是个很小的整数，也会直接将它提升成int类型，此时用short反而会导致类型转换

```c++
void ff(int);
void ff(short);
ff('a');		//char提升成int，调用f(int)
```

所有算术类型的提升级别都一样 ，比如3.14既可以转换成long，也可以转换成float

```c++
void manip(long);
void manip(double);
manip(3.14);			//错误：二义性调用
```

##### 函数匹配和const实参

如果重载函数的区别在于它们的引用类型的形参是否引用了const，或者指针类型的形参是否指向了const，则当调用方式时，编译器通过实参是否是const来决定哪个函数

```c++
Record lookup(Account&);				//参数是Account的引用
Record lookup(const Account&);	//参数是常量引用
const Account a;
Account b;

lookup(a);											//调用lookup(const Account&)
lookup(b);											//调用lookup(Account&)
```

因为不能把普通引用绑定到常量对象上，所以第一个调用只有一个可行函数

因为常量引用可以绑定非常量对象，所以第二个调用有两个可行函数，但是显然非常量版本精确匹配，所以最佳匹配是是非常量版本

指针与引用类似

### 函数指针

函数指针指向的是函数而非对象，函数指针指向某种特定类型，函数的类型由它的返回类型与形参类型共同决定，**与函数名无关**

```c++
bool lengthCompare(const string &, const string &);
bool (*pf)(const string &, const string &);		//未初始化
```

我们从声明的名字开始观察，(*pf)表示是一个指针，右侧是形参列表，表示pf指向的是函数，左侧是返回类型，故pf就是一个指向函数的指针，该函数的参数是两个const string引用，返回值是布尔类型

> 括号必不可少，若不写括号，则pf是一个返回值为bool指针的函数！

##### 使用函数指针

把函数名当做一个值使用，该函数自动转换成指针

```c++
pf = lengthCompare;			//pf指向名为lengthCompare的函数
pf = &lengthCompare;		//取地址符是可选的
```

还可以用指向函数的指针调用该函数，无须解引用

```c++
bool b1 = pf("hello", "goodbye");
bool b2 = (*pf)("hello", "goodbye");
bool b3 = lengthCompare("hello", "goodbye");	//三者等价
```

给指针赋nullptr或0，该指针不指向任何一个函数

指向不同函数类型的指针不存在转换关系

##### 重载函数的指针

使用重载函数，必须明确到底用哪个函数，编译器通过指针类型决定选用的函数，指针类型必须与重载函数的某一个精确匹配**

##### 函数指针形参

与数组类似，函数的形参不能为函数，但可以为指向函数的指针

```c++
//第三个形参是函数类型，自动转换成指针
void useBigger(const string &s1, const string &s2, bool pf(const string &, const string &));
//等价声明，显式将形参定义成指向函数的指针
void useBigger(const string &s1, const string &s2, bool (*pf)(const string &, const string &));

//调用函数，第三个实参直接传入函数名即可
useBigger(s1, s2, lengthCompare):
```

函数指针冗长而繁琐，可以用类型别名简化

```c++
//Fun和Fun2是函数类型
typedef bool Func(const string &, const string &);
typedef decltype(lengthCompare) Func2;					//等价的类型
//FuncP和FuncP2是指向函数的指针
typedef bool (*FuncP)(const string &, const string &);
typedef decltype(lengthCompare) *FuncP2;				//等价的类型
```

其中，decltype返回函数类型，加上*才能表示函数指针

```c++
void useBigger(const string &, const string &, Func);			//等价声明，编译器自动将函数名转换为函数指针
void useBigger(const string &, const string &, FuncP2);		//等价声明
```

##### 返回指向函数的指针

和数组类似，函数不能返回一个函数，但可以返回一个指向函数的指针，**但是与指针不一样，将返回类型写成指针类型，编译器不会自动地将函数返回类型当成对应的指针类型处理**，此时最简单的方法是使用类型别名

```c++
using F = int(int *, int);				//F是函数类型，不是指针
using PF = int(*)(int *, int);		//PF是指针类型(函数指针)
```

调用函数时必须显示地指定返回类型为指针

```c++
PF f1(int);		//正确，PF是指向函数的指针，f1返回一个指向函数的指针
F f1(int);		//错误，F是函数类型，f1不能返回一个函数
F *f1(int);		//正确，显式地指定返回类型是指向函数的指针
```

直接声明f1非常繁琐

```c++
int (*f1(int))(int*, int);	//不用类型别名，直接声明，可以看到非常繁琐
```

按照由内向外的顺序阅读这条声明，看到`*f1(int)`，f1有形参列表，所以f1是个函数，f1前面有*，所以f1返回一个指针，进一步发现，指针的类型本身也包括形参列表，因此指针指向一个函数，该函数的返回值是int

C++11引入的尾置返回类型也可以声明一个返回函数指针的函数

```c++
auto f1(int) -> int (*)(int*, int);
```

##### decltype声明函数指针类型

上面的方法还是挺复杂的，当我们明确知道返回的函数是哪个时，可以用decltype简化书写函数指针返回类型的过程

```c++
string::size_type sumLength(const string &, const string &);
string::size_type largeLength(const string &, const string &);

decltype(sumLength) *getFcn(const string &);
```

注意：将decltype作用于某个函数，得到结果就是函数类型而非指针类型，所以必须要**显式**加上`*`以表明我们需要返回指针，而非函数本身

练习6.54

```c++
int f(int, int);

vector<int(*)(int, int)> pvec;	//直接表示元素的类型是int(*)(int,int)，即指向函数的指针
vector<decltype(f)*> pvec;			//利用decltype声明函数类型，别忘了显式加上*表示指针
```

练习6.55、6.56

```c++
int addition(int i, int j){
    return i + j;
}
int subtraction(int i, int j){
    return i - j;
}
int multiplication(int i, int j){
    return i * j;
}
int division(int i, int j){
    return i / j;
}
int computation(int i, int j, int (*p)(int, int)){
    return p(i, j);
}
vector<int(*)(int, int)> pvec;
decltype(addition) *psub = subtraction;	//psub是指向subtraction函数的指针
int (*pdiv)(int, int) = division;	//pdiv是指向division函数的指针
pvec.push_back(addition);					//函数名作实参时，可以直接转换成函数指针
pvec.push_back(psub);							//传入psub指针
pvec.push_back(multiplication);		//函数名作实参时，可以直接转换成函数指针
pvec.push_back(pdiv);							//传入pdiv指针
int i = 10, j = 5;
for (auto p : pvec){
    cout << computation(i, j, p) << endl;;
}
```

## Chapter7 类

类的基本思想是**数据抽象（data abstraction）和封装（encapsulation）**，数据抽象是一种依赖于**接口（interface）**和**实现（implementation）**分离的编程（以及设计）技术

类的接口包括用户所能执行的操作，类的实现则包括类的数据成员、负责接口实现的函数体以及定义类所需的各种私有函数

封装实现了类的接口和实现的分离，封装后的类隐藏了它的实现细节，也就是说，类的用户只能使用接口而无法访问实现部分

类要想实现数据抽象和封装，需要首先定义一个**抽象数据类型（abstract data type）**，在抽象数据类型中，由类的设计者负责考虑类的实现过程，使用该类的程序员只需要抽象地思考类型做了什么，而无需了解类型的工作细节

### 定义抽象数据类型

#### 定义改进的Sales_data类

成员函数的**声明**必须在类的内部，它的**定义**则既可以在类的内部也可以在类的外部

定义在类内部的函数时隐式的inline函数

##### this——这个（对象）

使用点运算符执行对类的成员函数的调用，实际上是调用了**某个对象**的成员函数

成员函数通过一个名为**this**的额外的**隐式参数**来访问调用它的那个对象，当我们调用一个成员函数时，用请求该函数的对象地址初始化this，例如调用下面的成员函数时

```c++
total.isbn();
```

编译器负责把total的地址传递给isbn的隐式形参this，可以等价地认为编译器将该调用重写成了如下的形式

```c++
Sales_data::isbn(&total);		//伪代码，用于说明调用isbn成员时传入了total的地址
```

其中调用Sales_data的isbn成员时传入了total的地址

在成员函数内部，可以直接使用调用该函数的对象，而无需通过成员访问运算符来做到这一点，因为this所指的正是这个对象，任何对类成员的直接访问都被看作this的隐式引用，也就是说，当isbn使用bookNo（Sales_data类的成员变量），它隐式地使用this指向的成员，就像使用了`this->bookNo`

因为this总是指向“这个”对象，所以this是一个常量指针，不允许改变this保存的地址

##### 引入const成员函数

默认情况下，this的类型是指向非常量类类型的常量指针，所以不能把this绑定到一个常量对象上，同时我们也不能在常量对象上使用普通函数

因此，把this设置为指向常量的（常量）指针有助于提高函数的灵活性，this可以指向常量也可以指向非常量了

但是，this是隐式的，C++允许把const关键字放在成员函数的参数列表之后，此时的const就表示this是一个指向常量的（常量）指针，像这样的成员函数叫做**常量成员函数（const member function）**

```c++
//常量成员函数实例
std::string isbn() const {
	return bookNo;
}

//伪代码，帮助理解
//因为不能显式地定义this，所以下面代码非法
std::string Sales_data::isbn(const Sales_data *const this){
	return this->bookNo;
}
```

因为this 是指向常量的指针，所以常量成员函数不能改变调用它的对象的内容，所以isbn可以读取调用它的对象的成员（如bookNo），但是不能写入新值

注意：常量对象、常量对象的引用或指针都只能调用常量成员函数

##### 类作用域的成员函数
类本身就是一个作用域，类的成员函数的定义嵌套在类的定义域之内

编译器分两步处理类：首先编译成员的声明，然后才轮到成员函数体（如果有的话），因此成员函数体可以随意使用类的其他成员，而无须在意这些成员出现的次序

##### 在类的外部定义成员函数
成员函数的外部定义必须与类内的声明保持一致，且必须包含所属的类名

##### 定义一个返回this对象的成员
函数combine的设计初衷类似于复合赋值运算符`+=`，调用该函数的对象代表的是赋值运算符左侧的运算对象，右侧运算对象则通过显式的实参被传入函数，combine函数定义如下

```c++
Sales_data& Sales_data::combine(const Sales_data &rhs){
	units_sold += rhs.units_sold;		//把rhs的成员加到this对象的成员上
	revenue += rhs.revenue;
	return *this;									//返回调用该函数的对象
}
```

当调用如下这个成员函数时

```c++
total.combine(trans);		//更新变量total当前的值
```

total的地址被绑定到隐式的this参数上，而rhs绑定到了trans上，因此，当combine执行下面的语句时

```c++
units_sold += rhs.units_sold;		//把rhs的成员添加到this对象的成员中
```

效果等同于求total.units_sold和trans.units_sold的和，然后把结果保存到total.units_sold中

值得注意的是函数的返回类型与返回语句，一般来说，当定义某个函数类似于某个内置运算符，最好尽可能模仿这个运算符，内置的复合赋值运算符把它左侧运算当做左值返回，所以combine函数也应该返回一个左值，故返回类型为Sales_data&

最后的return语句解引用this指针以获得执行该函数的对象，也就是说，上面的这个调用返回total的引用

#### 定义类相关的非成员函数

类还需要一些辅助函数需，从概念上来属于类的接口的组成部分，但是它们实际上并不属于这个类本身，比如add、print、read等等

这就叫定义类相关的非成员函数，通常把函数的声明和定义分离开，把该函数的声明与类声明（而非定义）放在同一个头文件，这样只需要引入一个头文件即可

> 建议：如果非成员函数是类接口的组成部分，则这些函数的声明应该与类在同一个头文件内

#### 构造函数

每个类都分别定义了它的对象被初始化的方式，类通过一个或几个特殊的成员函数来控制其对象的初始化过程，这些函数就叫做**构造函数（constructor）**，构造函数的任务是初始化类对象的数据成员

构造函数的名字与类名相同，和其他函数不同的是，构造函数没有返回类型，类可以包括多个构造函数，和其他重载函数差不多，必须要在形参数量或类型上有所差别

注意，构造函数不能被声明成const（即上文的常量成员函数），因为在构造函数里面要对类对象进行初始化的操作，需要写操作

##### 合成的默认构造函数（synthesized default constructor）
**默认构造函数（default constructor）**无需任何实参，如果我们没有显式地定义构造函数，那么编译器会隐式地帮我们定义一个默认构造函数，这就叫做合成的默认构造函数

合成的默认构造函数初始化类的数据成员时有两种情况

- 如果存在类内的初始值，则用它来初始化成员
- 否则，默认初始化该成员

##### 某些类不能依赖于合成的默认构造函数

原因有三：

- 编译器只有在发现类没有任何构造函数时才会生成合成的默认构造函数，一旦我们定义了一个构造函数，最好考虑所有情况，重载构造函数
- 对某些类来说，合成的默认构造函数可能会执行错误的操作，如果类包含有**内置类型或者复合类型**的成员，若它们被默认初始化，则它们的值将是未定义的！所以，只有当确定所有这些类型的值都赋予了类内的初始值时，这个类才适用于合成的默认构造函数
- 有时候编译器无法为某些类合成默认的构造函数，比如类中包含了另一个其他类类型的成员，并且该成员的类型没有默认构造函数，那么编译器将无法初始化该成员

既然我们定义了其他构造函数，就必须定义一个默认构造函数

```c++
Struct Sales_data{
    Sales_data() = default;
    Sales_data(const std::string &s): bookNo(s){}
    Sales_data(const std::string &s, unsigned n, double p): bookNo(s), units_sold(n), revenue(p*n){}
    Sales_data(std::istream &);
    //...
}
```

=default就是默认构造函数，不接受任何实参

##### 构造函数初始值列表（constructor initialize list）
第二、第三个构造函数出现了新的东西，即冒号以及冒号和花括号之间的代码，其中花括号定义了空的函数体，新出现的部分叫做构造函数初始值列表，负责为新创建的对象一个或几个数据成员赋初值，构造函数初始值时成员名字的一个列表

因为初始化已经在初始值列表处完成了，所以函数体为空即可

`Sales_data(const std::string &s): bookNo(s){}`这个构造函数没有初始化units_sold和revenue，它们将隐式初始化，比如类内初始值初始化，**但有的编译器不支持类内初始值**，所以所有构造函数都应该显式地初始化每个内置类型的成员

##### 在类的外部定义构造函数
构造函数也可以定义在类的外部，但是声明当然得在类内部，

```c++
//构造函数在类内声明
    Sales_data(const std::string &);

//构造函数在类外定义
Sales_data::Sales_data(const std::string &s): bookNo(s){}
```

#### 拷贝、赋值和析构
除了初始化，类还需要控制拷贝、赋值和销毁对象时发生的行为，如果不主动定义这些操作，编译器会默认合成它们

##### 某些类不能依赖于合成的版本
当类需要分配类对象之外的资源时，合成的版本常常会失效

很多需要动态内存的类能（也应该）使用vector对象或string对象管理必要的存储空间，能避免复杂性

### 访问控制与封装
**访问说明符（access specifiers）**加强类的封装性

- 定义在public说明符之后的成员在整个程序内可被访问，public成员定义类的接口
- 定义在private说明符之后的成员可以被类的成员函数访问，但是不能被该类的代码访问，private部分封装了（即隐藏了）类的实现细节

```c++
class Sales_data {
public:
	// constructors
	Sales_data() = default;
	Sales_data(const std::string &s): bookNo(s) { }
	Sales_data(const std::string &s, unsigned n, double p):
	           bookNo(s), units_sold(n), revenue(p*n) { }
	Sales_data(std::istream &);

	// operations on Sales_data objects
	std::string isbn() const { return bookNo; }
	Sales_data& combine(const Sales_data&);
private:
	double avg_price() const {return units_sold ? revenue / units_sold : 0;}
	std::string bookNo;
	unsigned units_sold = 0;
	double revenue = 0.0;
};
```

作为接口的一部分，构造函数与部分成员函数（即isbn和combine）紧跟在public说明符之后，而数据成员和实现部分的函数则跟在private说明符后面

一个类可以包含0个或多个访问说明符，而且可以出现多次，记住，每个访问说明符的有效范围，是从该访问说明符的出现直到下一个访问说明符的说先或到达了类的结尾

##### 使用class 或struct关键字
class和struct都可以定义类，**唯一区别是这两者的默认访问权限不一样**

类可以再第一个访问说明符（如果有的话）之前定义成员，如果使用struct关键字，则这些成员是public的，如果使用class关键字，则这些成员是private的

出于统一变成风格的考虑，当我们希望类所有的成员是public的时候，使用struct，当我们希望类所有的成员是private的时候，使用class

#### 友元
因为有些数据成员是private的，那么一些不是类的成员函数也就无法调用它们，比如read、print、add这些非类成员的函数，但又的确需要访问数据成员，**友元（friend）**可以允许其他类或者函数访问**非公有成员**

使用友元很简单，在类内使用friend关键字声明那些非成员函数即可

```c++
class Sales_data {
friend Sales_data add(const Sales_data&, const Sales_data&);
friend std::ostream &print(std::ostream&, const Sales_data&);
friend std::istream &read(std::istream&, Sales_data&);
public:
	// constructors
	Sales_data() = default;
	Sales_data(const std::string &s): bookNo(s) { }
	Sales_data(const std::string &s, unsigned n, double p):
	           bookNo(s), units_sold(n), revenue(p*n) { }
	Sales_data(std::istream &);

	// operations on Sales_data objects
	std::string isbn() const { return bookNo; }
	Sales_data& combine(const Sales_data&);
	double avg_price() const;
private:
	std::string bookNo;
	unsigned units_sold = 0;
	double revenue = 0.0;
};

// nonmember Sales_data interface functions
Sales_data add(const Sales_data&, const Sales_data&);
std::ostream &print(std::ostream&, const Sales_data&);
std::istream &read(std::istream&, Sales_data&);
```

虽然友元在类内出现的具体位置不受限制，也不受访问说明符的约束，但是最好还是在类定义开始或结束时集中声明友元，易读性！

友元仅仅指定了访问的权限，使用友元的非成员函数还是需要函数声明的，正如前文所述，一般在同一个头文件中：定义类，**在类外声明类的非成员函数**，在类内用友元声明了类的非成员函数

友元不能随意设置，否则会破坏类的封装性

封装的益处

- 确保用户代码不会无意间破坏封装对象的状态
- 被封装的类具体实现细节可以随时改变，而无须调整用户级别的代码
- 把数据成员的访问权限设为private还有一个好处，这么做能防止由于用户的原因造成数据被破坏

### 类的其他特性
#### 类成员再探
##### 定义一个类型成员
在类的public访问说明符中使用类型别名（typedef或using均可），这样用户就可以使用类型别名，而对用户隐藏了实现细节（到底是用哪种类型存放数据的）

```c++
class Screen {
public:
    typedef std::string::size_type pos;
private:
    pos cursor = 0;
    pos height = 0, width = 0;
    std::string contents;
};
```

用来定义类型的成员必须先定义后使用，这与普通成员有所不同

##### 令成员作为内联函数
之前说过，定义在类内部的成员是自动内联（inline）的，如果类内部的成员只有一句声明，而成员函数的定义在外部，则我们可以显式地在类内声明处（或在类外定义处）用inline修饰成员函数，最好在类内声明和类外定义都加上inline，有助于理解

##### 成员函数也可以重载

##### 可变数据成员（mutable data member）
偶尔需要修改类的某个数据成员，即使是在一个const成员函数内，可以在变量声明中加入mutable关键字做到这点

一个可变数据成员永远不会是const，即使它是const对象的成员，所以即使它在const对象内也能被修改

```c++
class Screen {
public:
    void some_member() const;
private:
    mutable size_t access_ctr;
    //其他成员与之前一致
};
void Screen::some_member() const{
	++access_ctr;						//保存一个计数值，用于记录成员函数被调用的次数
}
```

##### 类数据成员的初始值
定义好Screen类后，需要定义一个窗口管理类，这个类将包含一个Screen类型的vector，每个元素表示一个特定的Screen，默认情况下，希望Window_mgr类总是拥有一个默认初始化的Screen，在C++11中，最好把这个默认值声明成类内初始值

```c++
class Window_mgr {
private:
	// Screens which this Window_mgr is tracking
	// by default, a Window_mgr has one standard sized blank Screen 
	std::vector<Screen> screens{Screen(24, 80, ' ')};
};
```

这里声明类内初始值使用了花括号的形式，也可以用`=`的形式

#### 返回*this的成员函数
继续添加函数，可以负责设置光标所在位置的字符或其他任一给定位置的字符

```c++
class Screen {
public:
    Screen &set(char);
    Screen &set(pos, pos, char);
};

inline Screen &Screen::set(char c) 
{ 
    contents[cursor] = c; // set the new value at the current cursor location
    return *this;         // return this object as an lvalue
}
inline Screen &Screen::set(pos r, pos col, char ch)
{
	contents[r*width + col] = ch;  // set specified location to given value
	return *this;                  // return this object as an lvalue
}
```

两个内联函数，返回值都是Screen的引用，所以返回的是对象本身而非对象的副本，于是可以把这些操作连接在同一个表达式中

```c++
myScreen.move(4,0).set('#');
```

如果返回值不是Screen的引用，则会等价于

```c++
Screen temp = myScreen.move(4,0);		//对返回值进行拷贝
temp.set('#');						//不会改变myScreen的contents
```

这就是函数返回类型定义为引用的好处，操作完之后仍然返回对象本身，可以连续操作！

##### 从const成员返回*this
一个const成员若要返回*this，则this将是一个指向const的指针，而*this是一个const对象，所以无法在操作序列中接着操作

```c++
myScreen.display(cout).set('#'); 			//如果display返回常量引用，则调用set会报错
```

##### 基于const的重载
通过区分成员函数时否是const的，可以对其进行重载

因为非常量版本的函数对于常量对象是不可用的，所以我们只能在一个常量对象上调用const成员函数，另一方面，可以在非常量对象上调用常量版本或非常量版本的成员函数，显然非常量版本是更好的匹配

#### 类类型
每个类定义了唯一的类型，即使两个类的成员完全一样，这两个类也是不同的类型，它们之间的成员没有任何关系

##### 类的声明
就像可以把函数的声明和定义分离开一样，我们也可以仅仅声明类而不定义它

```c++
class Screen;
```

这种声明有时被称作**前向声明（forward declaration）**，在类还未定义之前，它是一种**不完全类型（incomplete type）**，此时我们仅仅知道它是一个类类型，但它到底包含哪些成员还不知道

不完全类型只能在非常有限的情况下使用：可以定义指向这种类型的指针或引用，也可以声明（但不能定义）以不完全类型作为参数的或者返回类型的函数

一个类的名字一旦出现，就相当于声明过了，但此时未定义

练习7.31：定义一对类X和Y，X包含指向Y的指针，而Y包含一个类型为X的对象

```c++
class X;		//声明X
class Y{		//定义Y
	X* x;
};
class X{		//定义X
	Y y;			//此时Y已有定义，所以可以创建Y的对象
};
```

#### 友元再探
除了可以把普通的非成员函数定义成友元，还可以把其他类定义成友元，也可以把其他类的成员函数定义成友元

友元函数还可以定义在类的内部，这样的函数是隐式内联的

##### 把类定义成友元
如果一个类指定了友元类，则友元类的成员函数可以访问此类包括非公有成员在内的所有成员

```c++
class Screen{
	friend class Window_mgr;
}
```

**友元不存在传递性**，每个类负责控制自己的友元类或友元函数

##### 把函数定义成友元
当把一个成员函数声明成友元时，必须明确指出该成员函数属于哪个类

```c++
class Screen{
	friend void Window_mgr::clear(ScreenIndex);		//Window_mgr::clear必须在Screen类之前被声明
}
```

要想令某个成员函数作为友元，必须仔细组织程序的结构以满足声明和定义的彼此依赖关系，这里应该按如下方式设计程序（其中步骤1和2可以互换）：

- 首先定义Window_mgr类，其中声明clear函数，但是不能定义它，因为clear要使用Screen的成员，但此时我们还没有声明Screen的
- 接下来定义Screen，其中声明Window_mgr::clear为友元
- 最后定义clear，此时它才可以使用Screen的成员

##### 函数重载与友元
想把一组重载函数定义成友元，就必须对这组函数中的每一个分别声明友元

##### 友元声明和作用域
类和非成员函数的声明不是必须在它们的友元声明之前（上面的步骤1和2可以互换）

要理解友元声明的作用是影响作用域，**友元声明本身并非普通意义上的声明**

在类的内部定义友元函数，也必须在类外提供相应的声明从而使得函数可见（这有点反直觉，记着吧）

```c++
struct X{
	friend void f(){}	//友元函数可以定义在类的内部
	X(){f();}
	void g();
	void h();
}
void X::g(){ return f();}		//错误：f还未声明
void f();								//声明f
void X::h(){ return f();}   	//正确，现在f在作用域中了
```

### 类的作用域
类的作用域之外，普通的数据和函数成员只能由对象、引用或指针使用成员访问运算符来访问，对于类类型成员则使用作用域运算符访问，

这也是为什么有些成员函数定义在类的外部（当然，声明在类的内部）的时候，这些成员函数前面需要提供类名，再加上作用域运算符`::`，如`Window_mgr::clear`

若类外定义的成员函数的返回类型是类特有的，比如在类中用了类型别名定义过的类型，那么在类外定义的成员函数的返回类型也要加上类名与作用域运算符

```c++
Window_mgr::ScreenIndex							
Window_mgr::addScreen(const Screen &s){		//ScreenIndex是定义在Window_mgr中的类型别名
	/...
}
```

#### 名字查找与类的作用域
**名字查找（name lookup）**是寻找所用名字最匹配的声明的过程

在一般的程序中（不在类内），名字查找的过程直截了当

- 在名字所在的块中找，只考虑在名字使用之前出现的声明
- 如果没找到，继续查找外层作用域
- 如果最终没有找到匹配的声明，则程序报错

在类的成员函数中，名字查找比较特殊，分两步

- 首先，编译成员的**声明**
- 直到类全部可见后，再编译**函数体**（即成员函数的**定义**）

这样做有个好处：我们可以在成员函数的函数体中自由地使用类中定义的任何名字

##### 用于类成员声明的名字查找
声明中使用的名字，包括返回类型或者参数列表中使用的名字，都必须在使用前确保可见，如果找不到，则到类的外层作用域中查找

##### 类型名要特殊处理
一般来说，内层作用域可以重新定义外层作用域的名字，即使该名字已经在内层作用域中，但是这个名字不能是一个类型，比如在类外定义了`typedef double Money`，在类内就不能重新定义Money，甚至重复它都不行

> 建议：类型名的定义通常在类的开始出，这样能确保所有使用该类型的成员都出现在类名的定义之后

##### 成员定义中的普通块作用域的名字查找
成员函数中使用的名字按照如下方式解析
- 在成员函数中查找该名字的声明，和前面一样，只有在函数使用之前出现的声明才被考虑
- 如果在成员函数内没有找到，则在类内继续查找，这时类的所有成员都可以被考虑
- 如果类内也没找到该名字的声明，在成员函数定义之前的作用域中继续查找

有时成员函数的同名参数隐藏了类的某些数据成员（不提倡这样做），可在成员名前加上类的名字或显式使用this指针来强制访问成员

```c++
void dummy_fcn(string height){
	cursor = width * this -> height;	//成员height
	cursor = width * Screen::height;	//成员height
}
```

##### 在类外作用域中查找
有时成员函数的同名参数隐藏了类外作用域的某些名字，可以通过全局作用域运算符来访问类外的名字

```c++
void dummy_fcn(string height){
	cursor = width * ::height;	//类外的height
}
```

### 构造函数再探
#### 构造函数初始值列表
我们定义变量时习惯立即对其初始化，而非先定义、再赋值，有时候这两种方法都可以，但是有时候不行，如果成员是const或者是引用的话，它们必须被初始化，所以先定义、再赋值就行不通了

而且，**随着构造函数一开始执行，初始化就完成了**，所以初始化const或者引用类型的数据成员的唯一机会就是通过函数初始值，因此应该用**构造函数初始值列表**来为这些成员提供初始值

> 建议：使用构造函数初始值
> 初始化和赋值关系到效率问题，而且一些数据成员必须被初始化，所以建议养成构造函数初始值的习惯
> 

##### 成员初始化的顺序
构造函数初始值列表只说明用于初始化成员的值，而不限定具体执行顺序

实际上，**成员的初始化顺序与他们在类中定义的出场顺序一致**，构造函数初始值列表的出场顺序完全无关！

一般来说，顺序没什么要求，但是如果用一个成员来初始化另一个成员，这个顺序就很关键了

> 建议：最好保持构造函数初始值顺序与成员声明的顺序保持一致，而且尽可能避免用某些成员初始化其他成员
> 

##### 默认实参和构造函数
假设有下面两个构造函数

```c++
    Sales_data() = default;
    Sales_data(const std::string &s): bookNo(s){}
```

则它们可以通过默认实参简化为一个构造函数

```c++
    Sales_data(std::string s = " "): bookNo(s){}
    //下面这样写也对
    //Sales_data(const std::string &s = " "): bookNo(s){}
```

实际上，如果一个构造函数为所有的参数都提供了默认实参（包括为只接受一个形参的构造函数提供默认实参），则它实际上也定义了默认构造函数，因为只要不传入实参，就相当于默认构造函数

#### 委托构造函数
C++11扩展了构造函数初始值列表的功能，使得可以定义**委托构造函数（delegating constructor）**，一个委托构造函数使用它所属类的其他构造函数来执行它自己的初始化过程，或者说它把它自己的一些（或者全部）职责委托给了其他构造函数

可以定义若干个委托构造函数，其中还可以嵌套委托，只有当内层委托执行完了之后，才会执行外层委托的函数体

```c++
class Sales_data{
public:
	Sales_data(std::string s, unsigned cnt, double price):
		bookNo(s), units_sold(cnt), revenue(cnt*price){}
	//其余构造函数都委托给第一个构造函数
	Sales_data(): Sales_data("", 0, 0){}
	Sales_data(std::string s): Sales_data(s, 0, 0){}
	Sales_data(std::istream &is): Sales_data(){
		read(is, *this);
	}
}
```

除了第一个是普通构造函数之外，其余三个都是委托构造函数，第二个（默认构造函数）、第三个构造函数委托了第一个构造函数，第四个构造函数委托了第二个（默认构造函数），所以这是嵌套的

#### 默认构造函数的作用（感觉这个小节总结得怪怪的）
当对象被默认初始化或值初始化时自动执行默认构造函数

默认初始化在以下情况下发生
- 当我们在块作用域内不适用任何初始值定义一个非静态变量或者数组时
- 当一个类本身含有类类型的成员且使用合成的默认构造函数时
- 当类类型的成员没有在构造函数初始值列表中显式地初始化时

值初始化在以下情况发生
- 在数组初始化时我们提供的初始值数量少于数组的大小时
- 当我们不使用初始值定义一个局部静态变量时
- 当我们书写形如T( )的表达式显式地请求值初始化时，其中T是类型名，比如`vector<int> ivec(10);`，但如果我们定义的类NoDefault没有默认构造函数，则`vector<NoDefault>  vec(10);`会报错

#### 隐式的类类型转换
如果构造函数只接受一个实参，则它实际上定义了转换为此类类型的隐式转换机制，有时我们把这种构造函数称作**转换构造函数（converting constructor）**

在Sales_data类中，接受string的构造函数和接受istream的构造函数分别定义了从这两种类型向Sales_data隐式转换的规则，也就是说，在需要使用Sales_data的地方，可以用string或者istream作为替代

```c++
string null_book = "9-999-99999-9";
//构造一个临时的Sales_data对象
//该对象的units_sold=0, revenue=0,bookNo=null_book
item.combine(null_book);
```

编译器**只允许一步类类型转换**

```c++
item.combine(null_book);
item.combine("9-999-99999-999-9");	//错误，要先把字符串字面值（C风格字符串）转换为string，再从string转换为Sales_data
item.combine(string("9-999-99999-999-9"));	//正确，显式转换为string，隐式转换为Sales_data
item.combine(Sales_data("9-999-99999-999-9"));	//正确，隐式转换为string，显式转换为Sales_data
```

##### 抑制构造函数定义的隐式转换——explicit
在不允许隐式转换时，可以将构造函数声明为explicit加以阻止

```c++
class Sales_data{
public:
	Sales_data() = default;
	Sales_data(const std::string &s, unsigned n, double p): bookNo(s), units_sold(n), revenue(p*n){}
	explicit Sales_data(const std::string &s): bookNo(s){}
	explicit Sales_data(std::istream&);
}

item.combine(null_book);		//错误：string构造函数是explicit的
item.combine(cin);					//错误：istream构造函数是explicit的
```

**关键字explicit只对一个实参的构造函数有效**，需要多个实参的构造函数不能执行隐式转换，所以无须将它们指定为explicit，只能在类内声明构造函数时使用explicit，在类外定义时不应重复

##### explicit构造函数只能用于直接初始化
假设string构造函数是explicit的

```c++
Sales_data item1(null_book);		//正确，直接初始化
Sales_data item2 = null_book;		//错误，不能将explicit构造函数用于拷贝形式的初始化过程
```

##### 显式地使用转换构造函数
尽管编译器不会将explicit的构造函数用于隐式转换过程，但是可以显式地强制进行转换

```c++
item.combine(Sales_data(null_book));			/正确，实参是一个显式构造的Sales_data对象
item.combine(static_cast<Sales_data>(cin)); //正确，static_cast可以使用explicit的构造函数
```

##### 标准库中含有显式构造函数的类
接受一个单参数的const char*的string构造函数不是explicit的

```c++
string s3("Value"); 		//正确
string s3 = "value";		//正确
```

接受一个带容量参数的vector构造函数是explicit的

```c++
vector<T> v1;
vector<T> v2 = v1;
vector<T> v3(n, val);
vector<T> v4(n);
```

#### 聚合类（aggregate class）
聚合类使得用户可以直接访问其成员，并且具有特殊的初始化语法形式

当一个类满足下列条件时，我们说它是聚合的：
- 所有成员都是public
- 没有定义任何构造函数
- 没有类内初始值
- 没有基类，也没有virtual函数（以后会学）

聚合类的初始化很简单，可以用花括号括起来的成员初始值列表

```c++
struct Data{
	int ival;
	string s;
};
Data val1 = {0, "Anna"}; //正确，顺序一致
Data val2 = {"Anna", 1024}; //错误，不能用"Anna"初始化ival，不能用1024初始化s
```
与初始化数组元素的规则一样，如果初始值列表中的元素个数少于类的成员数量，则靠后的成员被**值初始化**，初始值列表的元素个数绝对不能超过类的成员数量

显式地初始化类的对象的成员存在三个明显的缺点：
- 要求类所有成员都是public的
- 将正确初始化每个对象的每个成员的重任交给类的用户（而非类的作者），因为用户很容易忘掉某个初始值或提供一个不恰当的初始值，所以这种初始化过程极易出错
- 添加或删除一个成员后，所有的初始化语句都要更新

#### 字面值常量类（这节感觉用的比较少，用到时候再看吧）
之前提过，constexpr函数的参数和返回值必须是字面值类型，除了算数类型、引用和指针外，某些类也是字面值类型，这些类有可能含有constexpr函数成员（普通类没有），这样的成员必须符合constexpr函数的所有要求，它们是隐式const的

**数据成员都是字面值类型的聚合类是字面值常量类**，如果一个类不是聚合类，但是满足以下要求，它也是一个字面值常量类
- 数据成员都是字面值类型
- 至少含有一个constexpr构造函数
- 如果一个数据含有类内初始值，则内置类型成员的初始值必须是一条常量表达式；如果成员属于某种类类型，则初始值必须使用成员自己的constexpr构造函数
- 类必须使用析构函数的默认定义，该成员负责销毁类的对象

#### constexpr构造函数
尽管构造函数不能是const的，但是字面值常量类的构造函数可以是constexpr函数，字面值常量类也必须至少有一个constexpr构造函数

constexpr构造函数必须初始化所有的数据成员，初始值或者使用constexpr构造函数，或者是一条常量表达式

constexpr构造函数用于生成constexpr对象以及constexpr函数的参数或返回类型

### 类的静态成员
有时类需要一些成员与类本身相关，而不是与类的对象相关，通过关键字static可以使得成员与类关联在一起，静态成员可以是public也可以是private，其类型可以是常量、引用、指针、类类型等等

比如银行账户类中的基准利率与银行账户对象无关，所以可以被声明成静态的

```c++
class Account {
public:
    void calculate() { amount += amount * interestRate; }
    static double rate() { return interestRate; }
    static void rate(double);   
private:
    std::string owner; 
    double amount;
    static double interestRate; 
    static double initRate() {}
};
```

类的静态成员不专属于某个对象，对象中不包含任何与静态数据成员有关的数据

静态成员函数也不可与任何对象绑定在一起，它们不能包含this指针，作为结果，静态成员函数不能声明成const的，因为我们也不能在static函数体内使用this指针

使用作用域运算符可以直接访问静态成员，也可以通过类的对象、引用或指针来访问静态成员

```c++
double r;
r = Account::rate();

Account ac1;
Account *ac2 = &ac1;
//调用静态成员函数rate的等价形式
r = ac1.rate();				//通过Account的对象或引用
r = ac2->rate();			//通过指向Account对象的指针，相当于(*ac2).rate()
```

##### 定义静态成员
和其他成员函数一样，我们既可以在类内部也可以在类外部定义静态成员函数（当然声明得在类内），在类外定义时，**不能重复static关键字**，static关键字只出现在类内声明中

因为静态成员不属于任何对象，所以不是在类的构造函数里初始化的，**必须在类的外部定义和初始化每个静态成员**，一个静态数据成员只能被定义一次

类似全局变量，静态数据成员定义在任何函数之外，因此它一旦被定义，就贯穿于程序的整个生命周期

> 建议：要想确保对象只被定义一次，最好的办法是把静态数据成员的定义于其他非内联函数的定义放在同一个文件中

##### 静态成员的类内初始化
通常情况下，静态成员不应该类内初始化，然而，我们可以为静态成员提供const整数类型的类内初始值，不过要求静态成员必须是字面值常量类型的constexpr，初始值必须是常量表达式，因为这些成员本身就是常量表达式，所以它们能用在任何适合于常量表达式的地方

比如用初始化了的静态数据成员指定数组成员的维度

```c++
class Account{
	static constexpr int period = 30;
	double daily_tbl[period];
}
```

如果在类的内部提供了一个初始值，则成员在类外定义就不能再指定初始值了，但是最好还是在类外定义一下

```c++
constexpr int Account::period;	//静态成员变量的初始值在类内提供，这里是类外定义，不能有初始值
```

##### 静态成员能用于某些场景，而普通成员则不能
静态成员独立于任何对象

静态数据成员可以是不完全类型，静态数据成员的类型可以就是它所属的类类型，而非静态数据成员则受到限制，只能声明成它所属的类的指针或引用

```c++
class Bar{
public:
	//...
private:
	static Bar mem1;		//正确：静态成员可以是不完全类型
	Bar *mem2;				//正确：指针成员可以是不完全类型
	Bar mem3;					//错误：数据成员必须是完全类型
}
```

**静态成员可以作为默认实参**，而普通成员不行，因为它的值本身属于对象的一部分