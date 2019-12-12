# 第 Ⅱ 部 C++ 标准库

第 8 章 IO 库 277
8.1 IO 类 278
8.1.1 IO 对象无拷贝或赋值 279
8.1.2 条件状态 279
8.1.3 管理输出缓冲 281
8.2 文件输入输出 283
8.2.1 使用文件流对象 284
8.2.2 文件模式 286
8.3 string 流 287
8.3.1 使用 istringstream 287
8.3.2 使用 ostringstream 289
小结 290
术语表 290
第 9 章 顺序容器 291
9.1 顺序容器概述 292
9.2 容器库概览 294
9.2.1 迭代器 296
9.2.2 容器类型成员 297
9.2.3 begin 和 end 成员 298
9.2.4 容器定义和初始化 299
9.2.5 赋值和 swap 302
9.2.6 容器大小操作 304
9.2.7 关系运算符 304
9.3 顺序容器操作 305
9.3.1 向顺序容器添加元素 305
9.3.2 访问元素 309
9.3.3 删除元素 311
9.3.4 特殊的 forward_list 操作 312
9.3.5 改变容器大小 314
9.3.6 容器操作可能使迭代器失效 315
9.4 vector 对象是如何增长的 317
9.5 额外的 string 操作 320
9.5.1 构造 string 的其他方法 321
9.5.2 改变 string 的其他方法 322
9.5.3 string 搜索操作 325
9.5.4 compare 函数 327
9.5.5 数值转换 327
9.6 容器适配器 329
小结 332
术语表 332
第 10 章 泛型算法 335
10.1 概述 336
10.2 初识泛型算法 338
10.2.1 只读算法 338
10.2.2 写容器元素的算法 339
10.2.3 重排容器元素的算法 342
10.3 定制操作 344
10.3.1 向算法传递函数 344
10.3.2 lambda 表达式 345
10.3.3 lambda 捕获和返回 349
10.3.4 参数绑定 354
10.4 再探迭代器 357
10.4.1 插入迭代器 358
10.4.2 iostream 迭代器 359
10.4.3 反向迭代器 363
10.5 泛型算法结构 365
10.5.1 5 类迭代器 365
10.5.2 算法形参模式 367
10.5.3 算法命名规范 368
10.6 特定容器算法 369第 11 章 关联容器 373
11.1 使用关联容器 374
11.2 关联容器概述 376
11.2.1 定义关联容器 376
11.2.2 关键字类型的要求 378
11.2.3 pair 类型 379
11.3 关联容器操作 381
11.3.1 关联容器迭代器 382
11.3.2 添加元素 383
11.3.3 删除元素 386
11.3.4 map 的下标操作 387
11.3.5 访问元素 388
11.3.6 一个单词转换的 map 391
11.4 无序容器 394
小结 397
术语表 397
第 12 章 动态内存 399
12.1 动态内存与智能指针 400
12.1.1 shared_ptr 类 400
12.1.2 直接管理内存 407
12.1.3 shared_ptr 和 new 结合使用 412
12.1.4 智能指针和异常 415
12.1.5 unique_ptr 417
12.1.6 weak_ptr 420
12.2 动态数组 423
12.2.1 new 和数组 423
12.2.2 allocator 类 427
12.3 使用标准库：文本查询程序 430
12.3.1 文本查询程序设计 430
12.3.2 文本查询程序类的定义 432
小结 436
术语表 436

## Chapter8 IO库

### IO类

IO操作不仅是标准输入输出，还包括文件的读写，或对string中字符的操作

iostream定义了用于读写流的基本类型，fstream定义了读写命名文件的类型，sstream定义了读写内存string对象的类型

![8-1](https://tva1.sinaimg.cn/large/006y8mN6ly1g7001wr3y4j30kz071gmo.jpg)

为了支持使用宽字符的语言，标准库定义了一组类型和对象来操纵wchar_t类型的数据，以w开始，比如wcin、wcout、wcerr分别对应cin、cout、cerr的宽字符版对象，宽字符版对象与普通版对象在同一个头文件中

设备类型和字符大小都不会影响到IO操作，这是通过**继承机制（inheritance）**实现的，简单来说，我们可以将一个派生类（继承类）对象当做其基类（所继承的类）对象来使用

ifstream和istringstream都继承自istream，所以可以像使用istream对象一样来使用ifstream和ifstringstream，对于istream对象，我们可以用getline函数，可以用输入操作符>>，同理ifstream和ifstringstream也可以这样使用

#### IO对象无拷贝或赋值

以下代码是错误的

```c++
ofstream out1, out2;
out1 = out2;							//错误：不能对流对象赋值
ofstream print(ofstream); //错误：不能初始化ofstream参数
out2 = print(out2);				//错误：不能拷贝流对象
```

因为不能拷贝IO对象，所以不能将形参或返回类型设置为流类型，但是可以用**引用方式**传递和返回流类型，读写一个IO对象会改变其状态，因此传递和返回的**引用不能是const**

#### 条件状态（Condition States）

IO操作经常会发生错误，所以有必要定义一些函数和标志，这称之为条件状态

![8-2](https://tva1.sinaimg.cn/large/006y8mN6ly1g700ciugtjj30kz0dawh8.jpg)

流只有在无错状态时，才可以继续读写，确定一个流对象的状态的最简单的方法就是把它当做一个条件使用

```c++
while (cin >> word)
    // ok: read operation successful...
```

##### 查询流的状态

`iostate`是与机器无关的类型，它提供了表达流状态的完整功能

`badbit`表示系统级错误，如不可恢复的读写错误。通常情况下，一旦 `badbit` 被置位，流就无法继续使用了。在发生可恢复错误后，`failbit` 会被置位，如期望读取数值却读出一个字符。如果到达文件结束位置，`eofbit` 和 `failbit` 都会被置位。如果流未发生错误，则 `goodbit` 的值为 0。如果 `badbit`、`failbit` 和 `eofbit` 任何一个被置位，检测流状态的条件都会失败。

标准库还定义了一组函数来查询这些标志位的状态：`good` 函数在所有错误均未置位时返回 `true`。而 `bad`、`fail` 和 `eof` 函数在对应错误位被置位时返回 `true`。此外，在 `badbit` 被置位时，`fail` 函数也会返回 `true`。因此应该使用 `good` 或 `fail` 函数确定流的总体状态，`eof` 和 `bad` 只能检测特定错误。

##### 管理条件状态

流对象的 `rdstate` 成员返回一个 `iostate` 值，表示流的当前状态。`setstate` 成员用于将指定条件置位（叠加原始流状态）。`clear` 成员有两个版本：**无参版本清除所有错误标志**；含参版本接受一个 `iostate` 值，用于设置流的新状态（覆盖原始流状态）。

思考：什么时候`while (cin >> word)`循环会终止？

答：遇到文件结束符、遇到IO流错误、读入无效数据

#### 管理输出缓冲（Managing the Output Buffer）

每个输出流都管理一个缓冲区，用于保存程序读写的数据，操作系统可以将多个输出操作合成单一的系统级写操作，这样可以带来很大的性能提升

导致缓冲刷新（即数据真正写入输出设备或文件）的原因有很多：

- 程序正常结束。
- 缓冲区已满。
- 使用操纵符（如 `endl`）显式刷新缓冲区。
- 在每个输出操作之后，可以用 `unitbuf` 操纵符设置流的内部状态，从而清空缓冲区。默认情况下，对 `cerr` 是设置 `unitbuf` 的，因此写到 `cerr` 的内容都是立即刷新的。
- 一个输出流可以被关联到另一个流。这种情况下，当读写被关联的流时，关联到的流的缓冲区会被刷新。默认情况下，`cin` 和 `cerr` 都关联到 `cout`，因此，读 `cin` 或写 `cerr` 都会刷新 `cout` 的缓冲区。

##### 刷新输出缓冲区

`endl`我们很熟悉，刷新缓冲区并换行， `flush` 操纵符刷新缓冲区，但不输出任何额外字符，`ends` 向缓冲区插入一个空字符，然后刷新缓冲区。

```c++
cout << "hi!" << endl;   // writes hi and a newline, then flushes the buffer
cout << "hi!" << flush;  // writes hi, then flushes the buffer; adds no data
cout << "hi!" << ends;   // writes hi and a null, then flushes the buffer
```

##### unitbuf操纵符——每次写操作都刷新缓冲区

如果想在每次输出操作后都刷新缓冲区，可以使用 `unitbuf` 操纵符。它令流在接下来的每次写操作后都进行一次 `flush` 操作。而 `nounitbuf` 操纵符则使流恢复使用正常的缓冲区刷新机制。

```c++
cout << unitbuf;    // all writes will be flushed immediately
// any output is flushed immediately, no buffering
cout << nounitbuf;  // returns to normal buffering
```

警告⚠️：如果程序崩溃，输出缓冲区不会被刷新

##### tie函数——关联输入和输出流

当一个输入流被关联到一个输出流时，任何试图从输入流读取数据的操作都会先刷新关联的输出流。标准库将 `cout` 和 `cin` 关联在一起，因此下面的语句会导致 `cout` 的缓冲区被刷新：

```c++
cin >> ival;
```

> 建议：交互式系统通常应该关联输入流和输出流。这意味着包括用户提示信息在内的所有输出，都会在读操作之前被打印出来。

使用 `tie` 函数可以关联两个流。它有两个重载版本：无参版本返回指向输出流的指针。如果本对象已关联到一个输出流，则返回的就是指向这个流的指针，否则返回空指针。`tie` 的第二个版本接受一个指向 `ostream` 的指针，将本对象关联到此 `ostream`。

```c++
cin.tie(&cout);     // illustration only: the library has already 'tied' cin and cout for us
// old_tie points to the stream (if any) currently tied to cin
ostream *old_tie = cin.tie(nullptr); // cin is no longer tied
// ties cin and cerr; not a good idea because cin should be tied to cout
cin.tie(&cerr);     // reading cin flushes cerr, not cout
cin.tie(old_tie);   // reestablish normal tie between cin and cout
```

每个流同时最多关联一个流，但多个流可以同时关联同一个 `ostream`。向 `tie` 传递空指针可以解开流的关联。

### 文件输入输出

头文件 *fstream* 定义了三个类型来支持文件 IO：`ifstream` 从给定文件读取数据，`ofstream` 向指定文件写入数据，`fstream` 可以同时读写指定文件。

除了继承自iostream类型的行为之外，fstream中定义的类型还增加了一些**新的成员**来管理与流关联的文件

![8-3](https://tva1.sinaimg.cn/large/006y8mN6ly1g71f76oexzj30kz092mzd.jpg)

#### 使用文件流对象（Using File Stream Objects）

当我们想要读写一个文件的时候，可以定义一个文件流对象，**并将对象与文件关联起来**

每个文件流类型都定义了 `open` 函数，它完成一些系统操作，定位指定文件，并视情况打开为读或写模式。

创建文件流对象时，如果提供了文件名（可选），`open` 会被自动调用。

```c++
ifstream in(ifile);   // construct an ifstream and open the given file
ofstream out;   // output file stream that is not associated with any file
```

在 C++11 中，文件流对象的文件名可以是 `string` 对象或 C 风格字符数组。旧版本的标准库只支持 C 风格字符数组。

在要求使用基类对象的地方，可以用继承类型的对象代替。因此一个接受 `iostream` 类型引用或指针参数的函数，可以用对应的 `fstream` 类型来调用。

可以先定义空文件流对象，再调用 `open` 函数将其与指定文件关联。

```c++
ifstream in(ifile);   // construct an ifstream and open the given file
//与上面等价
ofstream out;   // output file stream that is not associated with any file
out.open(ifile +".copy");
```

如果 `open` 调用失败，`failbit` 会被置位，所以检查open是否成功的检测通常是一个好习惯

```c++
if(out)
```

对一个已经打开的文件流调用 `open` 会失败，并导致 `failbit` 被置位。随后试图使用文件流的操作都会失败。如果想将文件流关联到另一个文件，必须先调用 `close` 关闭当前文件，若成功关闭，再`open`新的文件

```c++
in.close();
in.open(ifile + "2");
```

当 `fstream` 对象被销毁时（比如局部变量退出局部作用域时），`close` 会自动被调用。

#### 文件模式（File Modes）

![8-4](https://github.com/czs108/Cpp-Primer-5th-Notes-CN/raw/master/Chapter-8%20The%20IO%20Library/Images/8-4.png)

- 只能对 `ofstream` 或 `fstream` 对象设定 `out` 模式。
- 只能对 `ifstream` 或 `fstream` 对象设定 `in` 模式。
- 只有当 `out` 被设定时才能设定 `trunc` 模式。
- 只要 `trunc` 没被设定，就能设定 `app` 模式。在 `app` 模式下，即使没有设定 `out` 模式，文件也是以输出方式打开。
- 默认情况下，即使没有设定 `trunc`，以 `out` 模式打开的文件也会被截断。如果想保留以 `out` 模式打开的文件内容，就必须同时设定 `app` 模式，这会将数据追加写到文件末尾；或者同时设定 `in` 模式，即同时进行读写操作。
- `ate` 和 `binary` 模式可用于任何类型的文件流对象，并可以和其他任何模式组合使用。

与 `ifstream` 对象关联的文件默认以 `in` 模式打开，与 `ofstream` 对象关联的文件默认以 `out` 模式打开，与 `fstream` 对象关联的文件默认以 `in` 和 `out` 模式打开。



### string流（string Streams）

头文件 *sstream* 定义了三个类型来支持内存 IO：`istringstream` 从 `string` 读取数据，`ostringstream` 向 `string` 写入数据，`stringstream` 可以同时读写 `string` 的数据。

![8-5](https://tva1.sinaimg.cn/large/006y8mN6ly1g72rx3ta1zj30kz04pdgi.jpg)

### 使用 istringstream（Using an istringstream）

```c++
// members are public by default
struct PersonInfo
{
    string name;
    vector<string> phones;
};

string line, word;   // will hold a line and word from input, respectively
vector<PersonInfo> people;    // will hold all the records from the input
// read the input a line at a time until cin hits end-of-file (or another error)
while (getline(cin, line))
{
    PersonInfo info;    // create an object to hold this record's data
    istringstream record(line);    // bind record to the line we just read
    record >> info.name;    // read the name
    while (record >> word)  // read the phone numbers
        info.phones.push_back(word);   // and store them
    people.push_back(info);    // append this record to people
}
```

### 使用 ostringstream（Using ostringstreams）

当我们逐步构造输出，希望最后一起打印的时候，ostringstream是很有用的

```c++
for (const auto &entry : people)
{ // for each entry in people
    ostringstream formatted, badNums;   // objects created on each loop
    for (const auto &nums : entry.phones)
    { // for each number
        if (!valid(nums))
        {
            badNums << " " << nums;  // string in badNums
        }
        else
            // ''writes'' to formatted's string
            formatted << " " << format(nums);
    }

    if (badNums.str().empty())   // there were no bad numbers
        os << entry.name << " "  // print the name
            << formatted.str() << endl;   // and reformatted numbers
    else  // otherwise, print the name and bad numbers
        cerr << "input error: " << entry.name
            << " invalid number(s) " << badNums.str() << endl;
}
```

## Chapter9 顺序容器

一个容器就是一些特定类型对象的集合，顺序容器（Sequential container）为程序员提供了控制元素存储和访问顺序进的能力。这种顺序不依赖于元素的值，而是与元素加入容器时的位置相对应，与之相对的，Ch11介绍的有序和无序关联容器根据关键字的值来存储元素

### 顺序容器概述

![9-1](https://tva1.sinaimg.cn/large/006y8mN6ly1g72s7yee7aj30kz07ptad.jpg)

| `vector`       | 可变大小数组。支持快速随机访问。在尾部之外的位置插入 / 删除元素可能很慢 |
| -------------- | ------------------------------------------------------------ |
| `deque`        | 双端队列。支持快速随机访问。在头尾位置插入 / 删除速度很快    |
| `list`         | 双向链表。只支持双向顺序访问。在任何位置插入 / 删除速度都很快 |
| `forward_list` | 单向链表。只支持单向顺序访问。在任何位置插入 / 删除速度都很快 |
| `array`        | 固定大小数组。支持快速随机访问。不能添加 / 删除元素          |
| `string`       | 类似 `vector`，但用于保存字符。支持快速随机访问。在尾部插入 / 删除速度很快 |

`forward_list` 和 `array` 是 C++11 新增类型。与内置数组相比，`array` 更安全易用。`forward_list` 没有 `size` 操作，因为保存或计算其大小需要额外的开销。对于其他容器而言，size保证是一个快速的常量时间的操作。

容器选择原则：

- 除非有合适的理由选择其他容器，否则应该使用 `vector`。
- 如果程序有很多小的元素，且空间的额外开销很重要，则不要使用 `list` 或 `forward_list`。
- 如果程序要求随机访问容器元素，则应该使用 `vector` 或 `deque`。
- 如果程序需要在容器头尾位置插入 / 删除元素，但不会在中间位置操作，则应该使用 `deque`。
- 如果程序只有在读取输入时才需要在容器中间位置插入元素，之后需要随机访问元素。则：
  - 先确定是否真的需要在容器中间位置插入元素。当处理输入数据时，可以先向 `vector` 追加数据，再调用标准库的 `sort` 函数重排元素，从而避免在中间位置添加元素。
  - 如果必须在中间位置插入元素，可以在输入阶段使用 `list`。输入完成后将 `list` 中的内容拷贝到 `vector` 中。
- 如果程序既需要随机访问元素，又需要在容器中间位置插入元素，那就需要考量在list/forward_list中访问元素与vector/deque中插入/删除元素的相对性能
- 不确定应该使用哪种容器时，可以先只使用 `vector` 和 `list` 的公共操作：使用迭代器，不使用下标操作，避免随机访问。这样在必要时选择 `vector` 或 `list` 都很方便。

### 容器库概览（Container Library Overview）

本节的操作对所有容器都适用，其他操作以后再讲，先讲最普遍的

一般来说，每个容器都定义在一个头文件中，文件名与类型名相同，大部分容器需要额外提供元素类型信息，如`vector<int>`

容器里的元素也可以是容器，嵌套尖括号即可，如`vector<vector<string> >`，较旧的编译器可能要求尾部的尖括号之间要有空格

![9-2](https://github.com/czs108/Cpp-Primer-5th-Notes-CN/raw/master/Chapter-9%20Sequential%20Containers/Images/9-2.png)

#### 迭代器

`forward_list` 的迭代器不支持递减运算符 `--`。

`list`的迭代器不支持`<`运算

以上两者的迭代器都不支持加减运算，因为链表中的元素在内存中不是连续存储，应多次使用`++`来代替迭代器加法操作

##### 迭代器范围

一个迭代器范围（iterator range）由一对迭代器表示。这两个迭代器通常被称为 `begin` 和 `end`，分别指向同一个容器中的元素或尾后地址。`end` 迭代器不会指向范围中的最后一个元素，而是指向尾元素之后的位置。这种元素范围被称为左闭合区间（left-inclusive interval），其标准数学描述为 `[begin，end）`。迭代器 `begin` 和 `end` 必须指向相同的容器，`end` 可以与 `begin` 指向相同的位置，但不能指向 `begin` 之前的位置（由程序员确保）。

左闭合范围是因为有如下性质，假定 `begin` 和 `end` 构成一个合法的迭代器范围，则：

- 如果 `begin` 等于 `end`，则范围为空。
- 如果 `begin` 不等于 `end`，则范围内至少包含一个元素，且 `begin` 指向该范围内的第一个元素。
- 可以递增 `begin` 若干次，令 `begin` 等于 `end`。

```c++
while (begin != end)			//范围不为空，则可以安全地解引用了
{
    *begin = val;   // ok: range isn't empty so begin denotes an element
    ++begin;    // advance the iterator to get the next element
}
```

#### 容器类型成员（Container Type Members）

size_type、iterator、const_iterator都是容器的类型成员

大多数容器还提供反向迭代器，对反向迭代器执行`++`操作，会得到上一个元素

通过类型别名，可以在不了解容器元素类型的情况下使用元素。如果需要元素类型，可以使用容器的 `value_type`。如果需要元素类型的引用，可以使用 `reference` 或 `const_reference`。这将在泛型编程中有用，Ch16会具体讲

#### begin 和 end 成员（begin and end Members）

`begin` 和 `end` 操作生成指向容器中第一个元素和尾后地址的迭代器。其常见用途是形成一个包含容器中所有元素的迭代器范围。

`begin` 和 `end` 操作有多个版本：带 `r` 的版本返回反向迭代器。以 `c` 开头的版本（C++11 新增）返回 `const` 迭代器。不以 `c` 开头的版本都是重载的，当对非常量对象调用这些成员时，返回普通迭代器，对 `const` 对象调用时，返回 `const` 迭代器。

```c++
list<string> a = {"Milton", "Shakespeare", "Austen"};
auto it1 = a.begin();    // list<string>::iterator
auto it2 = a.rbegin();   // list<string>::reverse_iterator
auto it3 = a.cbegin();   // list<string>::const_iterator
auto it4 = a.crbegin();  // list<string>::const_reverse_iterator
```

以c开头的版本是C++11引入的，用以支持auto与begin和end函数结合使用

当 `auto` 与 `begin` 或 `end` 结合使用时，返回的迭代器类型依赖于容器类型（只有当容器是const的，返回的迭代器也是const）。但调用以 `c` 开头的版本可以确保获得 `const` 迭代器，与容器是否是常量无关。

> 建议：当程序不需要写操作时，应该使用 `cbegin` 和 `cend`。

#### 容器定义和初始化（Defining and Initializing a Container）

每个容器都定义了一个默认构造函数，除array外，其他容器的默认构造函数都会创建一个指定类型的空容器，且都可以接受指定容器大小和元素初始值的参数

![9-3](https://tva1.sinaimg.cn/large/006y8mN6ly1g72vjhwwonj30kz0b5dl8.jpg)

将一个容器初始化为另一个容器的拷贝时，两个容器的容器类型和元素类型都必须相同。

传递迭代器参数来拷贝一个范围时，**不要求容器类型相同**，而且新容器和原容器中的元素类型也可以不同，但是要能进行类型转换，可以用`list<int>`拷贝给`vector<double>`，因为int和double是相容的（可类型转换的）

```c++
// each container has three elements, initialized from the given initializers
list<string> authors = {"Milton", "Shakespeare", "Austen"};
vector<const char*> articles = {"a", "an", "the"};
list<string> list2(authors);        // ok: types match
deque<string> authList(authors);    // error: container types don't match
vector<string> words(articles);     // error: element types must match
// ok: converts const char* elements to string
forward_list<string> words(articles.begin(), articles.end());
```

C++11 允许对容器进行列表初始化。如上面代码的第一二行，对于除array之外的容器类型，初始化列表还隐含地指定了容器的大小：容器将包含于初始值一样多的元素。

只有顺序容器的构造函数才接受大小参数，关联容器并不支持

```c++
vector<int> ivec(10, -1);	//10个元素，每个都为1
deque<string> svec(10);		//10个元素，每个都为空
```

##### 标准库array具有固定大小

定义和使用 `array` 类型时，需要同时指定元素类型和容器大小。

```c++
array<int, 42>      // type is: array that holds 42 ints
array<string, 10>   // type is: array that holds 10 strings
array<int, 10>::size_type i;   // array type includes element type and size
array<int>::size_type j;       // error: array<int> is not a type
```

对 `array` 进行列表初始化时，初始值的数量不能大于 `array` 的大小。如果初始值的数量小于 `array` 的大小，则只初始化靠前的元素，剩余元素会被值初始化。如果元素类型是类类型，则该类需要一个默认构造函数。

虽然我们不能对**内置数组**进行拷贝或对象赋值操作，但可以对 `array` 进行拷贝或赋值操作，这要求二者的元素类型和大小都相同。

#### 赋值和swap

容器赋值操作

![9-4](https://tva1.sinaimg.cn/large/006y8mN6ly1g72vy58szqj30kz0arjwq.jpg)

赋值运算符两侧的运算对象必须类型相同。顺序容器（array除外）还定义了名为`assign`的成员，`assign` 允许用不同但相容的类型赋值，或者用容器的子序列赋值。

```c++
list<string> names;
vector<const char*> oldstyle;
names = oldstyle;   // error: container types don't match
// ok: can convert from const char*to string
names.assign(oldstyle.cbegin(), oldstyle.cend());
```

警告⚠️：由于其旧元素被替换，因此传递给 `assign` 的迭代器不能指向调用 `assign` 的容器本身。

##### 使用swap

`swap` 交换两个相同类型容器的内容。除 `array` 外，`swap` 不对任何元素进行拷贝、删除或插入操作，只交换两个容器的内部数据结构，因此可以保证快速完成。

除`string`之外，`swap` 操作交换容器内容，不会导致迭代器、引用和指针失效。它们仍指向`swap`操作之前的那些元素，但是在`swap`之后，这些元素已经属于不同的容器了。比如，假定iter在`swap`之前指向svec1[3]，在`swap`之后它指向svec2[3]的元素。 

```c++
vector<int> a = { 1, 2, 3 };
vector<int> b = { 4, 5, 6 };
auto p = a.cbegin(), q = a.cend();
a.swap(b);
// 输出交换前的值，即1、2、3
while (p != q)
{
    cout << *p << endl;
    ++p;
}
```

对于 `array`，`swap` 会真正交换它们的元素。因此在 `swap` 操作后，指针、引用和迭代器所绑定的元素不变，但元素值已经被交换。

```c++
array<int, 3> a = { 1, 2, 3 };
array<int, 3> b = { 4, 5, 6 };
auto p = a.cbegin(), q = a.cend();
a.swap(b);
// 输出交换后的值，即4、5、6
while (p != q)
{
    cout << *p << endl;
    ++p;
}
```

`array` 不支持 `assign`，也不允许用花括号列表进行赋值（但可以初始化）。

```c++
array<int, 10> a1 = {0,1,2,3,4,5,6,7,8,9};
array<int, 10> a2 = {0};    // elements all have value 0
a1 = a2;    // replaces elements in a1
a2 = {0};   // error: cannot assign to an array from a braced list
```

在新标准库中，容器既提供成员函数版的`swap`，也提供非成员版本的`swap`，早期标准库版本只支持成员函数版的`swap`，非成员版的`swap`在泛型编程非常重要。**统一使用非成员函数版本的`swap`是一个好习惯**。

#### 容器大小操作（Container Size Operations）

`size` 成员返回容器中元素的数量；`empty` 当 `size` 为 0 时返回 `true`，否则返回 `false`；`max_size` 返回一个大于或等于该类型容器所能容纳的最大元素数量的值。`forward_list` 支持 `max_size` 和 `empty`，但不支持 `size`。

#### 关系运算符（Relational Operators）

每个容器类型都支持相等运算符（`==`、`!=`）。除无序关联容器外，其他容器都支持关系运算符（`>`、`>=`、`<`、`<=`）。关系运算符两侧的容器类型和保存元素类型都必须相同。

两个容器的比较实际上是元素的逐对比较，其工作方式与 `string` 的关系运算符类似：

- 如果两个容器大小相同且所有元素对应相等，则这两个容器相等。
- 如果两个容器大小不同，但较小容器中的每个元素都等于较大容器中的对应元素，则较小容器小于较大容器。
- 如果两个容器都不是对方的前缀子序列，则两个容器的比较结果取决于第一个不等元素的比较结果。

```c++
vector<int> v1 = { 1, 3, 5, 7, 9, 12 };
vector<int> v2 = { 1, 3, 9 };
vector<int> v3 = { 1, 3, 5, 7 };
vector<int> v4 = { 1, 3, 5, 7, 9, 12 };
v1 < v2     // true; v1 and v2 differ at element [2]: v1[2] is less than v2[2]
v1 < v3     // false; all elements are equal, but v3 has fewer of them;
v1 == v4    // true; each element is equal and v1 and v4 have the same size()
v1 == v2    // false; v2 has fewer elements than v1
```

容器的相等运算符实际上是使用元素的 `==` 运算符实现的，而其他关系运算符则是使用元素的 `<` 运算符。如果元素类型不支持所需运算符，则保存该元素的容器就不能使用相应的关系运算。

### 顺序容器操作（Sequential Container Operations）

顺序容器和关联容器的不同之处在于两者组织元素的方式

##### 向顺序容器添加元素（Adding Elements to a Sequential Container）

除 `array` 外，所有标准库容器都提供灵活的内存管理，在运行时可以动态添加或删除元素。

![9-5](https://tva1.sinaimg.cn/large/006y8mN6ly1g89ovn2hl9j30kz0fbdk2.jpg)

##### push_back

`push_back` 将一个元素追加到容器尾部，`push_front` 将元素插入容器头部。

```c++
// read from standard input, putting each word onto the end of container
string word;
while (cin >> word)
    container.push_back(word);
```

使用对象来初始化容器，或将对象插入到容器时，实际上放入的是对象的拷贝值，之后就没有任何关联了

##### push_front

除了`push_back`，`list`、`forward_list`和`deque`容器还支持名为`push_front`的类似操作，此操作将元素插入到容器头部

##### 特定位置添加元素——insert

`insert` 将元素插入到迭代器指定的位置**之前**。一些不支持 `push_front` 的容器可以使用 `insert` 将元素插入开始位置。

```c++
vector<string> svec;
list<string> slist;
// equivalent to calling slist.push_front("Hello!");
slist.insert(slist.begin(), "Hello!");
// no push_front on vector but we can insert before begin()
// warning: inserting anywhere but at the end of a vector might be slow
svec.insert(svec.begin(), "Hello!");
```

警告⚠️：将元素插入到 `vector`、`deque` 或 `string` 的任何位置都是合法的，但可能会很耗时。

在新标准库中，接受元素个数或范围的 `insert` 版本返回指向第一个新增元素的迭代器，而旧版本中这些操作返回 `void`。如果范围为空，不插入任何元素，`insert` 会返回第一个参数。

##### 插入范围内元素

`insert`函数可接受一个元素数目和一个值，它将指定数量的元素添加到指定位置之前，这些元素都是按给定值初始化。

```c++
svec.insert(svec.end(), 10, "Anna");
```

`insert`函数也可以接受一对迭代器或一个初始化列表的参数，将给定范围中的元素插入到指定位置前

```c++
slist.insert(slist.begin(), v.end()-2, v.end());
slist.insert(slist.end(), {"these", "words", "will", "go", "at", "the", "end"});
slist.insert(slist.begin(), slist.begin(), slist.end());	//错误：不能指向相同容器
```

##### 使用insert的返回值

通过`insert`的返回值，可以在容器一个特定位置上**反复**插入元素（详情请看上图的insert用法）

```c++
list<string> 1st;
auto iter = 1st.begin();
while (cin >> word)
    iter = 1st.insert(iter, word);  // same as calling push_front
```

在新标准下，元素个数或范围的 `insert` 版本返回指向第一个新增元素的迭代器，而旧版本中这些操作返回 `void`。如果范围为空，不插入任何元素，`insert` 会返回第一个参数。

##### 使用emplace操作

新标准库增加了三个直接构造而不是拷贝元素的操作：`emplace_front`、`emplace_back` 和 `emplace`，其分别对应 `push_front`、`push_back` 和 `insert`。当调用 `push` 或 `insert` 时，元素对象被拷贝到容器中。而调用 `emplace` 时，则是将参数传递给元素类型的构造函数，直接在容器的内存空间中构造元素。

```c++
// construct a Sales_data object at the end of c
// uses the three-argument Sales_data constructor
c.emplace_back("978-0590353403", 25, 15.99);
// error: there is no version of push_back that takes three arguments
c.push_back("978-0590353403", 25, 15.99);
// ok: we create a temporary Sales_data object to pass to push_back
c.push_back(Sales_data("978-0590353403", 25, 15.99));
```

传递给 `emplace` 的参数必须与元素类型的构造函数相匹配。

警告⚠️：向vector、string或deque插入元素会使所有指向容器的迭代器、引用和指针失效，如果想用指针遍历整个容器，同时也要插入元素，最好利用insert函数的返回值！

#### 访问元素（Accessing Elements）

每个顺序容器都有一个 `front` 成员函数，而除了 `forward_list` 之外的顺序容器还有一个 `back` 成员函数。这两个操作分别返回首元素和尾元素的引用。

在调用 `front` 和 `back` 之前，要确保容器非空。

![9-6](https://tva1.sinaimg.cn/large/006y8mN6ly1g73hjdxpkij30kz07pgp0.jpg)

##### 访问成员函数返回的是引用

在容器中访问元素的成员函数都返回引用类型。如果容器是 `const` 对象，则返回 `const` 引用，否则返回普通引用。

```c++
if(!c.empty()){
	c.front() = 42;				//将42赋值给c的第一个元素
	auto &v = c.back();		//获得指向c最后一个元素的引用
	v = 1024;							//改变c的元素
	auto v2 = c.back();		//v2不是一个引用，它是c.back()的一个拷贝
	v2 = 0;								//未改变c的元素
}
```

##### 下标操作和安全的随机访问

可以快速随机访问的容器（`string`、`vector`、`deque` 和 `array`）都提供下标运算符。保证下标有效是程序员的责任。如果希望确保下标合法，可以使用 `at` 成员函数。`at` 类似下标运算，但如果下标越界，`at` 会抛出 `out_of_range` 异常。

```c++
vector<string> svec;  // empty vector
cout << svec[0];      // run-time error: there are no elements in svec!
cout << svec.at(0);   // throws an out_of_range exception
```

#### 删除元素（Erasing Elements）

![9-7](https://tva1.sinaimg.cn/large/006y8mN6ly1g73ixvlfshj30kz0ann33.jpg)

删除 `deque` 中除首尾位置之外的任何元素都会使所有迭代器、引用和指针失效。删除 `vector` 或 `string` 的元素后，指向删除点之后位置的迭代器、引用和指针也都会失效。

删除元素前，程序员必须确保目标元素存在。

##### pop_front和pop_back成员函数

`pop_front` 和 `pop_back` 函数分别删除首元素和尾元素。`vector` 和 `string` 类型不支持 `pop_front`，`forward_list` 类型不支持 `pop_back`。`pop`返回为空。

##### 从容器内部删除一个元素

`erase` 函数删除指定位置的元素。可以删除由一个迭代器指定的单个元素，也可以删除由一对迭代器指定的范围内的所有元素。两种形式的 `erase` 都返回指向删除元素（最后一个）之后位置的迭代器。

```c++
list<int> lst = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
auto it = lst.begin();
while(it != lst.end()){
	if(*it % 2){
		it = lst.erase(it);
	}else{
		++it;
	}
}
```

##### 删除多个元素

使用一对迭代器删除一个范围内的元素，elem1指向删除的第一个元素，elem2指向删除的最后一个元素之后的位置

```c++
// delete the range of elements between two iterators
// returns an iterator to the element just after the last removed element
elem1 = slist.erase(elem1, elem2);  // after the call elem1 == elem2
```

可以用`clear`成员函数删除容器中所有元素，也可以用`begin`和`end`作为迭代器调用`erase`

```c++
slist.clear();
slist.erase(slist.begin(), slist.end());	//等价调用
```

#### 特殊的 forward_list 操作（Specialized forward_list Operations）

因为在单向链表中，没有简单的方法来获取一个元素的前驱，所以在 `forward_list` 中添加或删除元素的操作是通过改变给定元素之后的元素来完成的。

![9-8](https://tva1.sinaimg.cn/large/006y8mN6ly1g73xkuj4u9j30gh03kmx9.jpg)

`forward_list`并未定义`insert`、`emplace`和`erase`，而是定义了`insert_after`、`emplace_after`和`erase_after`的操作，例如，为了删除elem3，得用指向elem2的迭代器调用`erase_after`。因此`forward_list`也定义了`before_begin`，它返回一个**首前（off-the-beginning）**迭代器，这个迭代器允许我们在首元素之前并不存在的元素之后添加或删除元素（也就是在首元素之前添加删除元素）

![9-9](https://tva1.sinaimg.cn/large/006y8mN6ly1g73xl367k3j30kz0aydiv.jpg)

从`forward_list`中添加或删除元素时，必须关注两个迭代器——一个指向我们要处理的元素、一个指向其前驱，比如下面这个删除奇数元素的程序：

```c++
forward_list flst = {0,1,2,3,4,5,6,7,8,9};
auto prev = flst.before_begin();		//表示首前元素		
auto curr = flst.begin();						//表示首元素
while(curr != flst.end()){
	if(*curr % 2){
		curr = flst.erase_after(prev);	//删除prev指向的元素的下一个元素（也就是当前元素），返回被删元素的下一个元素，赋值给curr，这样就把当前值从前后给“抹去”了
	}else{
		prev = curr;
	}
	++curr;
}
```

#### 改变容器大小（Resizing a Container）

array不支持resize，如果当前大小大于所要求的大小，容器后部的元素会被删除；如果当前大小小于所要求的的大小，会将新元素添加到容器后部

![9-10](https://tva1.sinaimg.cn/large/006y8mN6ly1g73ysbovmpj30kz05nwh1.jpg)

`resize` 函数接受一个可选的元素值参数，用来初始化添加到容器中的元素，否则新元素进行值初始化。如果容器保存的是类类型元素，且 `resize` 向容器添加新元素，则必须提供初始值，或元素类型提供默认构造函数。

```c++
list<int> ilist(10, 42);//10个int，每个都是42
ilist.resize(15);				//将5个0添加到尾部
ilist.resize(25, -1);		//将10个-1添加到尾部
ilist.resize(5);				//从末尾删除20个元素
```

#### 容器操作可能使迭代器失效（Container Operations May Invalidate Iterators）

向容器中添加或删除元素可能会使指向容器元素的指针、引用或迭代器失效。失效的指针、引用或迭代器不再表示任何元素，使用它们是一种严重的程序设计错误。

- 向容器中添加元素后：
  - 如果容器是 `vector` 或 `string` 类型，且存储空间被重新分配，则指向容器的迭代器、指针和引用都会失效。如果存储空间未重新分配，指向插入位置之前元素的迭代器、指针和引用仍然有效，但指向插入位置之后元素的迭代器、指针和引用都会失效。
  - 如果容器是 `deque` 类型，添加到除首尾之外的任何位置都会使迭代器、指针和引用失效。如果添加到首尾位置，则迭代器会失效，而指针和引用不会失效。
  - 如果容器是 `list` 或 `forward_list` 类型，指向容器的迭代器、指针和引用仍然有效。
- 从容器中删除元素后，指向被删除元素的迭代器、指针和引用失效（显而易见）：
  - 如果容器是 `list` 或 `forward_list` 类型，指向容器其他位置的迭代器、指针和引用仍然有效。
  - 如果容器是 `deque` 类型，删除除首尾之外的任何元素都会使迭代器、指针和引用失效。如果删除尾元素，则尾后迭代器失效，其他迭代器、指针和引用不受影响。如果删除首元素，这些也不会受影响。
  - 如果容器是 `vector` 或 `string` 类型，指向删除位置之前元素的迭代器、指针和引用仍然有效。但尾后迭代器总会失效。（但前文的”从容器内部删除一个元素“是可以的）

必须保证在每次改变容器后都正确地重新定位迭代器（这对`vector`、`string`和`deque`尤为重要

如果在一个循环中需要插入/删除`deque`、`string`或`vector`中的元素，不要保存`container.end()`返回的迭代器，必须在每个插入/删除后重新调用end，而不能在循环开市起那保存它返回的迭代器

```c++
// safer: recalculate end on each trip whenever the loop adds/erases elements
while (begin != v.end())
{
    // do some processing
    ++begin;    // advance begin because we want to insert after this element
    begin = v.insert(begin, 42);    // insert the new value
    ++begin;    // advance begin past the element we just added
}
```



### vector对象是如何增长的（How a vector Grows）

为了支持快速随机访问，`vector`将元素连续存储——每个元素紧挨着前一个元素存储，添加元素时极其麻烦

所以，`vector` 和 `string` 的实现通常会分配比新空间需求更大的内存空间，容器预留这些空间作为备用，可用来保存更多新元素。

![9-11](https://tva1.sinaimg.cn/large/006y8mN6ly1g73z678d1uj30kz044mxt.jpg)

`capacity` 函数返回容器在不扩充内存空间的情况下最多可以容纳的元素数量。`reserve` 函数告知容器应该准备保存多少元素，它并不改变容器中元素的数量，仅影响容器预先分配的内存空间大小。

只有当需要的内存空间超过当前容量时，`reserve` 才会真正改变容器容量，分配不小于需求大小的内存空间（小于或等于时，`reserve`什么也不做）。当需求大小小于当前容量时，`reserve` 并不会退回内存空间。综上，在调用 `reserve` 之后，`capacity` 肯定会大于或等于传递给 `reserve` 的参数。

在 C++11 中可以使用 `shrink_to_fit` 函数来要求 `deque`、`vector` 和 `string` 退回不需要的内存空间（并不保证退回）。

##### capacity和size

容器的`size`是指它**已经保存**的元素数目，容器的`capacity`是在不分配新的内存空间的前提下它**最多**可以保存多少元素

![9-12](https://tva1.sinaimg.cn/large/006y8mN6ly1g73zd4gl87j30dw02lq35.jpg)

问：为什么`list`和`array`没有`capacity`成员函数？

答：`list`是链表，当有新元素加入时，会从内存空间中分配一个新节点保存它；当从链表中删除元素时，该节点占用的空间也会被立刻释放，因此一个链表的内存占用空间总是与它目前所保存的元素所需空间相等（即`capacity=size`）。而`array`是固定大小数组，内存一次性分配，大小不会变化，

### 额外的string操作（Additional string Operations）

#### 构造 string 的其他方法（Other Ways to Construct strings）

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g74lzbqiimj30kz06igmq.jpg" alt="9-13"  />

```c++
const char *cp = "Hello World!!"; //以空字符结束的数组
char noNull[] = {'H', 'i'};				//不是以空字符结束的
string s1(cp);										//拷贝cp中的字符直到遇到空字符，s1=="Hello World!!!"
string s2(noNull, 2);							//从noNull拷贝两个字符；s2=="Hi"
string s3(noNull);								//未定义，noNull不是以空字符结束的
string s4(cp + 6, 5);							//从cp[6]开始拷贝5个字符；s4=="World"
string s5(s1, 6, 5);							//从s1[6]开始拷贝5个字符；s5=="World"
string s6(s1, 6);									//从s1[6]开始拷贝直到s1末尾；s6=="World!!!"
string s7(s1, 6, 20);							//正确，只拷贝到s1的末尾；s7=="World!!!"
string s8(s1, 16);								//抛出一个out_of_range异常
```

从另一个 `string` 对象拷贝字符构造 `string` 时，如果提供的拷贝开始位置（可选）大于给定 `string` 的大小，则构造函数会抛出 `out_of_range` 异常。

##### substr操作

![9-14](https://tva1.sinaimg.cn/large/006y8mN6ly1g74m75vpt3j30kz02omxe.jpg)

```c++
string s("hello world");
string s2 = s.substr(0, 5);		//s2=hello
string s3 = s.substr(6);			//s3=world
string s4 = s.substr(6, 11);	//s3=world
string s5 = s.substr(12);			//抛出out_of_range异常
```

如果传递给 `substr` 函数的开始位置超过 `string` 的大小，则函数会抛出 `out_of_range` 异常。

#### 改变 string 的其他方法（Other Ways to Change a string）

`string`类型支持顺序容器的赋值运算以及`assign`、`insert`和`erase`操作，除此之外，它还定义了**额外**的`insert`和`erase`版本，insert`可以接收一个**下标**，插入到下标之前的位置，`erase`可以接收一个**下标**用来指示开始删除的位置`

`string`类定义了两个额外的成员函数：`append`和`replace`

`append` 函数是在 `string` 末尾进行插入操作的简写形式。

```c++
string s("C++ Primer"), s2 = s;     // initialize s and s2 to "C++ Primer"
s.insert(s.size(), " 4th Ed.");     // s == "C++ Primer 4th Ed."
s2.append(" 4th Ed.");     // equivalent: appends " 4th Ed." to s2; s == s2
```

`replace` 函数是调用 `erase` 和 `insert` 函数的简写形式。

```c++
// equivalent way to replace "4th" by "5th"
s.erase(11, 3);         // s == "C++ Primer Ed."
s.insert(11, "5th");    // s == "C++ Primer 5th Ed."
// starting at position 11, erase three characters and then insert "5th"
s2.replace(11, 3, "5th");   // equivalent: s == s2
```

![9-15](https://tva1.sinaimg.cn/large/006y8mN6ly1g74mko4eh7j30kz0kwq76.jpg)

#### string 搜索操作（string Search Operations）

`string` 的每个搜索操作都返回一个 `string::size_type` 值，**表示匹配位置的下标**。如果搜索失败，则返回一个名为 `string::npos` 的 `static` 成员。标准库将 `npos` 定义为 `const string::size_type` 类型，并初始化为 - 1。

不建议用 `int` 或其他带符号类型来保存 `string` 搜索函数的返回值。

![9-16](https://tva1.sinaimg.cn/large/006y8mN6ly1g74tqdsix9j30kz0ad0v7.jpg)

搜索以及其他`string`操作是对大小写敏感的

#### compare 函数（The compare Functions）

`string` 类型提供了一组 `compare` 函数进行字符串比较操作，类似 C 标准库的 `strcmp` 函数。

![9-17](https://tva1.sinaimg.cn/large/006y8mN6ly1g74v9bby08j30kz065gmn.jpg)

#### 数值转换（Numeric Conversions）

C++11 增加了 `string` 和数值之间的转换函数：

![9-18](https://github.com/czs108/Cpp-Primer-5th-Notes-CN/raw/master/Chapter-9%20Sequential%20Containers/Images/9-18.png)

进行数值转换时，**`string` 参数的第一个非空白字符必须是符号（`+` 或 `-`或`.`）或数字**。它可以以 `0x` 或 `0X` 开头来表示十六进制数。对于转换目标是浮点值的函数，`string` 参数也可以以小数点开头，并可以包含 `e` 或 `E` 来表示指数部分。

如果给定的 `string` 不能转换为一个数值，则转换函数会抛出 `invalid_argument` 异常。如果转换得到的数值无法用任何类型表示，则抛出 `out_of_range` 异常。

### 容器适配器（Container Adaptors）

标准库定义了 `stack`、`queue` 和 `priority_queue` 三种容器适配器。容器**适配器（adaptor）**可以改变已有容器的工作机制。

![9-19](https://tva1.sinaimg.cn/large/006y8mN6ly1g74yaaucabj30kz08udhn.jpg)

默认情况下，`stack` 和 `queue` 是基于 `deque` 实现的，`priority_queue` 是基于 `vector` 实现的。可以在创建适配器时将一个命名的顺序容器作为第二个类型参数，来重载默认容器类型。

队列适配器 `queue` 和 `priority_queue` 定义在头文件 *queue* 中，其支持的操作如下：

![9-21](https://tva1.sinaimg.cn/large/006y8mN6ly1g74yeqov9yj30jh06gjsu.jpg)

`queue` 使用先进先出（first-in，first-out，FIFO）的存储和访问策略。进入队列的对象被放置到队尾，而离开队列的对象则从队首删除。

## Chapter10 泛型算法

标准库定义的操作集合惊人地小，标准库并未给每个容器添加大量的功能，而是提供了一组算法，这些算法的大多数独立于任何特定的容器，是**通用的（generic，或称泛型的）**，它们可以作用于不同类型的容器和不同类型的元素

### 概述（Overview）

大多数算法都定义在头文件 *algorithm* 中，此外标准库还在头文件 *numeric* 中定义了一组数值泛型算法。一般情况下，**这些算法并不直接操作容器，而是遍历由两个迭代器指定的元素范围进行操作**。

比如`find` 函数将范围中的每个元素与给定值进行比较，返回指向第一个等于给定值的元素的迭代器。如果无匹配元素，则返回其第二个参数来表示搜索失败。

```c++
int val = 42;   // value we'll look for
// result will denote the element we want if it's in vec, or vec.cend() if not
auto result = find(vec.cbegin(), vec.cend(), val);
// report the result
cout << "The value " << val
    << (result == vec.cend() ? " is not present" : " is present") << endl;
```

**迭代器参数令算法不依赖于特定容器，但依赖于元素类型操作**。

泛型算法本身不会执行容器操作，它们只会运行于迭代器之上，执行迭代器操作。算法可能改变容器中元素的值，或者在容器内移动元素，但**永远不会改变底层容器的大小**。

有一种特殊的的迭代器，称为**插入器（inserter）**，它可以完成向容器中添加元素的效果，但算法自身不会进行这种操作。

### 初识泛型算法（A First Look at the Algorithms）

标准库提供了超过100个算法，与容器类似，它们有一致的结构，有很多共性，大多数算法都对一个范围内的元素进行操作，称之为**”输入范围“**，总是接收两个迭代器，一个是第一个元素的迭代器，一个是尾元素之后位置的迭代器。

理解算法的最基本方法就是了解它们是否读取元素、改变元素或重排元素顺序

#### 只读算法（Read-Only Algorithms）

`accumulate` 函数（定义在头文件 *numeric* 中）用于计算一个序列的和。它接受三个参数，前两个参数指定需要求和的元素范围，第三个参数是和的初值（决定加法运算类型和返回值类型）。

```c++
// sum the elements in vec starting the summation with the value 0
int sum = accumulate(vec.cbegin(), vec.cend(), 0);
string sum = accumulate(v.cbegin(), v.cend(), string(""));
// error: no + on const char*（错误：const char*上没有定义+运算符
string sum = accumulate(v.cbegin(), v.cend(), "");
```

> 建议：在只读算法中使用 `cbegin` 和 `cend` 函数。

`equal` 函数用于确定两个序列是否保存相同的值。它接受三个迭代器参数，前两个参数指定第一个序列范围，第三个参数指定第二个序列的首元素。`equal` 函数假定第二个序列至少与第一个序列一样长。

```c++
// roster2 should have at least as many elements as roster1
equal(roster1.cbegin(), roster1.cend(), roster2.cbegin());
```

警告⚠️：只接受单一迭代器表示第二个操作序列的算法都假定第二个序列至少与第一个序列一样长。

#### 写容器元素的算法（Algorithms That Write Container Elements）

因为算法不执行容器操作，因此它们本身不可能改变容器大小，那也就意味着：在执行写算法之前，必须确保**序列原大小至少不少于写入的元素数目**。

`fill` 函数接受两个迭代器参数表示序列范围，还接受一个值作为第三个参数，它将给定值赋予范围内的每个元素。

```c++
// reset each element to 0
fill(vec.begin(), vec.end(), 0);
```

`fill_n` 函数接受单个迭代器参数、一个计数值和一个值，它将给定值赋予迭代器指向位置开始的指定个元素。

```c++
// reset all the elements of vec to 0
fill_n(vec.begin(), vec.size(), 0);
```

向目的位置迭代器写入数据的算法都假定目的位置足够大，能容纳要写入的元素。

```c++
vector<int> vec;		//空向量
fill_n(vec.begin(), 10, 0);		//错误，写入10个元素，但vec中并没有元素！
```

##### back_inserter

**插入迭代器（insert iterator）**是一种向容器内添加元素的迭代器。通过插入迭代器赋值时，一个与赋值号右侧值相等的元素会被添加到容器中。

`back_inserter` 函数（定义在头文件 *iterator* 中）接受一个指向容器的引用，返回与该容器绑定的插入迭代器。通过此迭代器赋值时，赋值运算符会调用 `push_back` 将一个具有给定值的元素添加到容器中。

于是，我们可以在泛型算法中传入插入迭代器来给空向量赋值：

```c++
vector<int> vec;    // empty vector
auto it = back_inserter(vec);   // assigning through it adds elements to vec
*it = 42;   // vec now has one element with value 42
// ok: back_inserter creates an insert iterator that adds elements to vec
fill_n(back_inserter(vec), 10, 0);  // appends ten elements to vec
```

##### 拷贝算法

`copy` 函数接受三个迭代器参数，前两个参数指定输入序列，第三个参数指定目的序列的起始位置。它将输入序列中的元素拷贝到目的序列中，返回目的位置迭代器（递增后）的值。

**目的序列至少要包含于输入序列一样多的元素**。

此时`ret`指向a2尾元素之后的位置。

```c++
int a1[] = { 0,1,2,3,4,5,6,7,8,9 };
// a2 has the same size as a1
// sizeof(a1) returns byte number of a1, sizeof(*a1) returns byte number of a1[0]
// so, sizeof(a1)/sizeof(*a1) = element number of a1
int a2[sizeof(a1) / sizeof(*a1)];     
// ret points just past the last element copied into a2
auto ret = copy(begin(a1), end(a1), a2);    // copy a1 into a2
```

`replace` 函数接受四个参数，前两个迭代器参数指定输入序列，后两个参数指定要搜索的值和替换值。它将序列中所有等于第一个值的元素都替换为第二个值。

```c++
// replace any element with the value 0 with 42
replace(ilst.begin(), ilst.end(), 0, 42);
```

相对于 `replace`，`replace_copy` 函数可以保留原序列不变。它接受第三个迭代器参数，指定调整后序列的保存位置，执行完后，ivec包含ilst的一份拷贝，不过原来在ilst中值为0的元素在ivec中变为42。

```c++
// use back_inserter to grow destination as needed
replace_copy(ilst.cbegin(), ilst.cend(), back_inserter(ivec), 0, 42);
```

很多算法都提供 “copy” 版本，这些版本不会将新元素放回输入序列，而是创建一个新序列保存结果。

#### 重排容器元素的算法（Algorithms That Reorder Container Elements）

假设现在有个需求，需要确保文本中的单词只出现一次：

`sort` 函数接受两个迭代器参数，指定排序范围。它利用元素类型的 `<` 运算符重新排列元素。

`unique` 函数重排输入序列，消除相邻的重复项，返回指向不重复值范围末尾的迭代器，注意算法不会真正删除元素，此位置之后的元素仍然存在，但是不知道值是什么。

![10-1](https://tva1.sinaimg.cn/large/006y8mN6ly1g75s73ifipj30jr04wgmq.jpg)

最后必须调用容器的`erase`删除操作，把后面两个元素删除

```c++
void elimDups(vector<string> &words)
{
    // sort words alphabetically so we can find the duplicates
    sort(words.begin(), words.end());
    // unique reorders the input range so that each word appears once in the
    // front portion of the range and returns an iterator one past the unique range
    auto end_unique = unique(words.begin(), words.end());
    // erase uses a vector operation to remove the nonunique elements
    words.erase(end_unique, words.end());
}
```

### 定制操作（Customizing Operations）

默认情况下，很多比较算法使用元素类型的 `<` 或 `==` 运算符完成操作。可以为这些算法提供自定义操作来代替默认运算符。

#### 向算法传递函数（Passing a Function to an Algorithm）

**谓词（predicate）**是一个可调用的表达式，其返回结果是一个能用作条件的值。标准库算法使用的谓词分为一元谓词（unary predicate，接受一个参数）和二元谓词（binary predicate，接受两个参数）。接受谓词参数的算法会对输入序列中的元素调用谓词，因此元素类型必须能转换为谓词的参数类型。

```c++
// comparison function to be used to sort by word length
bool isShorter(const string &s1, const string &s2)
{
    return s1.size() < s2.size();
}

// sort on word length, shortest to longest
sort(words.begin(), words.end(), isShorter);
```

稳定排序函数 `stable_sort` 可以维持输入序列中相等元素的原有顺序。

#### lambda 表达式（Lambda Expressions）

对于一个对象或表达式，如果可以对其使用调用运算符 `()`，则称它为**可调用对象（callable object）**。

我们可以向算法传递任何类别的可调用对象。

之前学过的仅有的两种可调用对象是函数和函数指针，还有其他两种：重载了函数调用运算符的类，以及**lambda表达式**

一个 `lambda` 表达式表示一个可调用的代码单元，类似未命名的内联函数，但可以定义在函数内部。其形式如下：

```c++
[capture list] (parameter list) -> return type { function body }
```

其中，*capture list*（捕获列表）是一个由 `lambda` 所在函数定义的局部变量的列表（通常为空）。*return type*、*parameter list* 和 *function body* 与普通函数一样，分别表示返回类型、参数列表和函数体。但与普通函数不同，`lambda` 必须使用尾置返回类型，且不能有默认实参。

定义 `lambda` 时可以省略参数列表和返回类型，但必须包含捕获列表和函数体。省略参数列表等价于指定空参数列表。省略返回类型时，若函数体只是一个 `return` 语句，则返回类型由返回表达式的类型推断而来。否则返回类型为 `void`。

```c++
auto f = [] { return 42; };
cout << f() << endl;    // prints 42
```

`lambda` 可以使用其所在函数的局部变量，但必须先将其包含在捕获列表中。捕获列表只能用于局部非 `static` 变量，`lambda` 可以直接使用局部 `static` 变量和其所在函数之外声明的名字。

一个`lambda`只有在其捕获列表中捕获一个它所在函数中的局部变量，才能在函数体中使用该变量。

`find_if` 函数接受两个迭代器参数和一个谓词参数。迭代器参数用于指定序列范围，之后对序列中的每个元素调用给定谓词，并返回第一个使谓词返回非 0 值的元素。如果不存在，则返回尾迭代器。

`for_each` 函数接受一个输入序列和一个可调用对象，它对输入序列中的每个元素调用此对象。

```c++
// print words of the given size or longer, each one followed by a space
for_each(wc, words.end(),
            [] (const string &s) { cout << s << " "; });
```

#### lambda 捕获和返回（Lambda Captures and Returns）

##### 值捕获

类似参数传递，变量的捕获方式也可以是值或引用。

被 `lambda` 捕获的变量的值是在 `lambda` 创建时拷贝，而不是调用时拷贝。在 `lambda` 创建后修改局部变量不会影响 `lambda` 内对应的值。

```c++
size_t v1 = 42; // local variable
// copies v1 into the callable object named f
auto f = [v1] { return v1; };
v1 = 0;
auto j = f();   // j is 42; f stored a copy of v1 when we created it
```

`lambda` 可以以引用方式捕获变量，**但必须保证 `lambda` 执行时变量存在**。在 `lambda` 创建后修改局部变量会影响 `lambda` 内对应的值。

```c++
size_t v1 = 42; // local variable
// the object f2 contains a reference to v1
auto f2 = [&v1] { return v1; };
v1 = 0;
auto j = f2();  // j is 0; f2 refers to v1; it doesn't store it
```

> 建议：尽量保持`lambda`的变量捕获简单化，减少捕获指针或引用

##### 隐式捕获

可以让编译器根据 `lambda` 代码隐式捕获函数变量，方法是在捕获列表中写一个 `&` 或 `=` 符号。`&` 为引用捕获，`=` 为值捕获。

可以混合使用显式捕获和隐式捕获。混合使用时，捕获列表中的第一个元素必须是 `&` 或 `=` 符号，用于指定默认捕获方式。显式捕获的变量必须使用与隐式捕获不同的方式。

```c++
// os implicitly captured by reference; c explicitly captured by value
for_each(words.begin(), words.end(),
            [&, c] (const string &s) { os << s << c; });
// os explicitly captured by reference; c implicitly captured by value
for_each(words.begin(), words.end(),
            [=, &os] (const string &s) { os << s << c; });
```

捕获列表可选参数如下：

![10-2](https://tva1.sinaimg.cn/large/006y8mN6ly1g77fibjvttj30kz0ayacs.jpg)

默认情况下，对于值方式捕获的变量，`lambda` 不能修改其值。如果希望修改，就必须在参数列表后添加关键字 `mutable`。

```c++
size_t v1 = 42; // local variable
// f can change the value of the variables it captures
auto f = [v1] () mutable { return ++v1; };
v1 = 0;
auto j = f();   // j is 43
```

对于引用方式捕获的变量，`lambda` 是否可以修改依赖于此引用指向的是否是 `const` 类型。

##### 指定lambda返回类型

`transform` 函数接受三个迭代器参数和一个可调用对象。前两个迭代器参数指定输入序列，第三个迭代器参数表示目的位置。它对输入序列中的每个元素调用可调用对象，并将结果写入目的位置。

当`lambda`的函数体是单一的`return`语句时，我们无须指定返回类型，编译器可以通过条件运算符的类型推断出来：

```c++
transform(vi.begin(), vi.end(), vi.begin(),
            [](int i) { return i < 0 ? -i : i; });
```

但如果`lambda`函数体不止一条语句，而又没有指定返回类型，这时编译器就会默认它返回类型为void，比如下面的代码，它返回了int型，于是产生编译错误。

```c++
transform(vi.begin(), vi.end(), vi.begin(),
            [](int i) { if (i < 0) return -i; else return i; });
```

为 `lambda` 定义返回类型时，必须使用尾置返回类型，如下。

```c++
transform(vi.begin(), vi.end(), vi.begin(),
            [](int i) -> int { if (i < 0) return -i; else return i; });
```

#### 参数绑定（Binding Arguments）

`lambda`表达式适用于那些只在一两个地方使用的简单操作，如果多次使用，还是定义函数比较好

`bind` 函数定义在头文件 *functional* 中，相当于一个函数适配器，它接受一个可调用对象，生成一个新的可调用对象来适配原对象的参数列表。一般形式如下：

```c++
auto newCallable = bind(callable, arg_list);
```

其中，*newCallable* 本身是一个可调用对象，*arg_list* 是一个以逗号分隔的参数列表，对应给定的 *callable* 的参数。之后调用 *newCallable* 时，*newCallable* 会再调用 *callable*，并传递给它 *arg_list* 中的参数。*arg_list* 中可能包含形如`_n` 的名字，其中 *n* 是一个整数。这些参数是占位符，表示 *newCallable* 的参数，它们占据了传递给 *newCallable* 的参数的位置。数值 *n* 表示生成的可调用对象中参数的位置：`_1` 为 *newCallable* 的第一个参数，`_2` 为 *newCallable* 的第二个参数，依次类推。这些名字都定义在命名空间 *placeholders* 中，它又定义在命名空间 *std* 中，因此使用时应该进行双重限定。

```c++
using std::placeholders::_1;
using namespace std::placeholders;
bool check_size(const string &s, string::size_type sz);

// check6 is a callable object that takes one argument of type string
// and calls check_size on its given string and the value 6
auto check6 = bind(check_size, _1, 6);
string s = "hello";
bool b1 = check6(s);    // check6(s) calls check_size(s, 6)
```

`bind` 函数可以调整给定可调用对象中的参数顺序。

```c++
// sort on word length, shortest to longest
sort(words.begin(), words.end(), isShorter);
// sort on word length, longest to shortest
sort(words.begin(), words.end(), bind(isShorter, _2, _1));
```

默认情况下，`bind` 函数的非占位符参数被拷贝到 `bind` 返回的可调用对象中。但有些类型不支持拷贝操作。

如果希望传递给 `bind` 一个对象而又不拷贝它，则必须使用标准库的 `ref` 函数。`ref` 函数返回一个对象，包含给定的引用，此对象是可以拷贝的。`cref` 函数生成保存 `const` 引用的类。

```c++
ostream &print(ostream &os, const string &s, char c);
for_each(words.begin(), words.end(), bind(print, ref(os), _1, ' '));
```

### 再探迭代器（Revisiting Iterators）

除了为每种容器定义的迭代器之外，标准库还在头文件 *iterator* 中定义了另外几种迭代器。

- 插入迭代器（insert iterator）：该类型迭代器被绑定到容器对象上，可用来向容器中插入元素。
- 流迭代器（stream iterator）：该类型迭代器被绑定到输入或输出流上，可用来遍历所关联的 IO 流。
- 反向迭代器（reverse iterator）：该类型迭代器向后而不是向前移动。除了 `forward_list` 之外的标准库容器都有反向迭代器。
- 移动迭代器（move iterator）：该类型迭代器用来移动容器元素。

#### 插入迭代器（Insert Iterators）

插入器是一种迭代器适配器，它接受一个容器参数，生成一个插入迭代器。通过插入迭代器赋值时，该迭代器调用容器操作向给定容器的指定位置插入一个元素。

插入迭代器操作：

![10-3](https://tva1.sinaimg.cn/large/006y8mN6ly1g7970if4l1j30kz03vdgl.jpg)

插入器有三种类型，区别在于元素插入的位置：

- `back_inserter`：创建一个调用 `push_back` 操作的迭代器。
- `front_inserter`：创建一个调用 `push_front` 操作的迭代器。
- `inserter`：创建一个调用 `insert` 操作的迭代器。此函数接受第二个参数，该参数必须是一个指向给定容器的迭代器，元素会被插入到该参数指向的元素之前，插入完成后，迭代器仍然指向原来的元素。

假设it是由`inserter`生成的迭代器，则下面的赋值语句等价：

```c++
*it = val;
// equivalent
it = c.insert(it, val);
++it;			//递增it使它指向原来的元素
```

另外两种用法如下：

```c++
list<int> 1st = { 1,2,3,4 };
list<int> lst2, lst3;   // empty lists
// after copy completes, 1st2 contains 4 3 2 1
copy(1st.cbegin(), lst.cend(), front_inserter(lst2));
// after copy completes, 1st3 contains 1 2 3 4
copy(1st.cbegin(), lst.cend(), inserter(lst3, lst3.begin()));
```

#### iostream 迭代器（iostream Iterators）

虽然`iostream`类型不是容器，但标注库定义了可以用于这些IO类型兑现的迭代器，`istream_iterator` 从输入流读取数据，`ostream_iterator` 向输出流写入数据。这些迭代器将流当作特定类型的元素序列处理。

##### istream_iterator操作

创建流迭代器时，必须指定迭代器读写的对象类型。`istream_iterator` 使用 `>>` 来读取流，因此 `istream_iterator` 要读取的类型必须定义了 `>>` 运算符。创建 `istream_iterator` 时，可以将其绑定到一个流。如果默认初始化，则创建的是**尾后迭代器**。

```c++
istream_iterator<int> int_it(cin);  // reads ints from cin
istream_iterator<int> int_eof;      // end iterator value
ifstream in("afile");
istream_iterator<string> str_it(in);   // reads strings from "afile"
```

对于一个绑定到流的迭代器，一旦其关联的流遇到文件尾或 IO 错误，迭代器的值就与尾后迭代器相等。

```c++
istream_iterator<int> in_iter(cin);     // read ints from cin
istream_iterator<int> eof;      // istream ''end'' iterator
while (in_iter != eof)      // while there's valid input to read
    // postfix increment reads the stream and returns the old value of the iterator
    // we dereference that iterator to get the previous value read from the stream
    vec.push_back(*in_iter++);
```

可以直接使用流迭代器构造容器，这种方法更加体现了流迭代器的优势。

```c++
istream_iterator<int> in_iter(cin), eof;    // read ints from cin
vector<int> vec(in_iter, eof);      // construct vec from an iterator range
```

![10-4](https://tva1.sinaimg.cn/large/006y8mN6ly1g797oyg0rhj30kz07kwff.jpg)

##### 使用算法操作流迭代器

比如`accumulate`

```c++
istream_iterator<int> in(cin), eof;
cout << accumulate(in, eof, 0) << endl;
```

##### istream_iterator允许使用懒惰求值

当我们将一个`istream_iterator`绑定到一个流时，标准库并不保证迭代器立即从流读取数据，具体实现可以推迟从流中读取数据，直到我们使用迭代器时才真正读取，必须保证在第一次解引用流迭代器之前已经读取了数据

##### ostream_iterator操作

创建`ostream_iterator`时，可以提供（可选的）第二参数，它是一个字符串，在输出每个元素之后都会打印此字符串，此此字符串必须是C风格字符串（即一个字符串常量或一个指向以空字符结尾的字符数组的指针）

定义 `ostream_iterator` 对象时，必须将其绑定到一个指定的流。不允许定义空的或者表示尾后位置的 `ostream_iterator`。

![10-5](https://tva1.sinaimg.cn/large/006y8mN6ly1g797xsdmbzj30kz064ab5.jpg)

`*` 和 `++` 运算符实际上不会对 `ostream_iterator` 对象做任何操作，所以省略它们也行，但是还是建议代码写法与其他迭代器保持一致，即不省略这些符号。

```c++
ostream_iterator<int> out_iter(cout, " ");
for (auto e : vec)
    *out_iter++ = e;    // the assignment writes this element to cout
cout << endl;
```

可以通过调用`copy`来打印`vec`中的元素，这比循环来的简单，也更能体现流迭代器的优势。

```c++
copy(vec.begin(), vec.end(), out_iter);
cout << endl;
```

#### 反向迭代器（Reverse Iterators）

递增`++`反向迭代器会移动到前一个元素，递减`--`会移动到后一个元素。

![10-6.png](https://tva1.sinaimg.cn/large/006y8mN6ly1g79a0ekjk7j30cj03oglj.jpg)

不能从 `forward_list` 或流迭代器创建反向迭代器。

有时需要从反向迭代器的正常顺序，调用`reverse_iterator`的`base`成员函数即可获得其普通的迭代器

```c++
// find the last element in a comma-separated list
auto rcomma = find(line.crbegin(), line.crend(), ',');
// WRONG: will generate the word in reverse order
cout << string(line.crbegin(), rcomma) << endl;
// ok: get a forward iterator and read to the end of line
cout << string(rcomma.base(), line.cend()) << endl;
```

如果我们输入的是FIRST,MIDDLE,LAST，则第二行会输出TSAL，第三行才会输出LAST。

无论是普通迭代器还是反向迭代器都反映了**左闭合区间**，所以`[line.crbegin(), rcomma)`应该与`[rcomma.base(), line.cend())`指向相同的元素范围，所以`rcomma`和`rcomma.base()`必须生成**相邻位置**，`crbegin()`与`cend()`同理

![undefined](https://ws1.sinaimg.cn/large/005GdKShly1g79a8vu5d1j30er04kq32.jpg)

反向迭代器的目的是表示元素范围，而这些范围是不对称的。用普通迭代器初始化反向迭代器，或者给反向迭代器赋值时，结果迭代器与原迭代器指向的并**不是相同元素**。

为了更好地理解反向迭代器的原理，练习10.36，查找最后一个值为0的元素

```c++
// Exercise 10.36
// Return the index(starting from 0) of '0' founded in reverse order
void findLast(){
    list<int> il{0,1,2,3,4};
    auto des_rev_it = find(il.rbegin(), il.rend(), 0);
    cout << *des_rev_it << endl;
    auto des_it = des_rev_it.base();		//指向des_rev_it之后的的元素
    cout << *des_it << endl;
    --des_it;
    cout << *des_it << endl;
    int cnt = 0;
    for(auto it = il.begin() ; it != des_it; it++){
        ++cnt;
    }
    cout << cnt << endl;
    cout << *des_it << endl;
}
```

输出为：

```c++
0
1
0
0
0
```

### 泛型算法结构

任何算法的最基本的特性是它要求其迭代器提供哪些操作。

算法要求的迭代器操作可以分为 5 个迭代器类别（iterator category）：

![10-8](https://tva1.sinaimg.cn/large/006y8mN6ly1g79n9k5ba8j30kz03it9e.jpg)

#### 5 类迭代器（The Five Iterator Categories）

C++ 标准指定了泛型和数值算法的每个迭代器参数的最小类别。对于迭代器实参来说，其能力必须大于或等于规定的最小类别。向算法传递更低级的迭代器参数会产生错误（大部分编译器不会提示错误）。一个高层类别的迭代器支持底层类别迭代器的所有操作。

迭代器类别：

- 输入迭代器（input iterator）：可以读取序列中的元素，只能用于单遍扫描算法。必须支持以下操作：

  - 用于比较两个迭代器相等性的相等 `==` 和不等运算符 `!=`。

  - 用于推进迭代器位置的前置和后置递增运算符 `++`。
  - 用于读取元素的解引用运算符 `*`；解引用只能出现在赋值运算符右侧。
  - 用于读取元素的箭头运算符 `->`。
  - `istream_iterator`是一种输入迭代器

- 输出迭代器（output iterator）：可以读写序列中的元素，只能用于单遍扫描算法，通常指向目的位置。必须支持以下操作：

  - 用于推进迭代器位置的前置和后置递增运算符 `++`。

  - 用于读取元素的解引用运算符 `*`；解引用只能出现在赋值运算符左侧（向已经解引用的输出迭代器赋值，等价于将值写入其指向的元素）。
  - `ostream_iterator`是一种输出迭代器

- 前向迭代器（forward iterator）：可以读写序列中的元素。只能在序列中沿一个方向移动。**支持所有输入和输出迭代器的操作**，而且可以多次读写同一个元素。因此可以使用前向迭代器对序列进行多遍扫描。

- 双向迭代器（bidirectional iterator）：可以正向 / 反向读写序列中的元素。除了支持所有前向迭代器的操作之外，还支持前置和后置递减运算符 `--`。除 `forward_list` 之外的其他标准库容器都提供符合双向迭代器要求的迭代器。

- 随机访问迭代器（random-access iterator）：可以在常量时间内访问序列中的任何元素。除了支持所有双向迭代器的操作之外，还必须支持以下操作：

  - 用于比较两个迭代器相对位置的关系运算符 `<`、`<=`、`>`、`>=`。

  - 迭代器和一个整数值的加减法运算 `+`、`+=`、`-`、`-=`，计算结果是迭代器在序列中前进或后退给定整数个元素后的位置。
  - 用于两个迭代器上的减法运算符 `-`，计算得到两个迭代器的距离。
  - 下标运算符 `[]`。

比如算法`sort`要求随机访问迭代器，`array`、`deque`、`string`和`vector`的迭代器都是随机访问迭代器，用于访问内置数组元素的指针也是。

##### 算法形参模式（Algorithm Parameter Patterns）

大多数算法的形参模式是以下四种形式之一：

```c++
alg(beg, end, other args);
alg(beg, end, dest, other args);
alg(beg, end, beg2, other args);
alg(beg, end, beg2, end2, other args);
```

其中 *alg* 是算法名称，*beg* 和 *end* 表示算法所操作的输入范围。几乎所有算法都接受一个输入范围，是否有其他参数依赖于算法操作。*dest* 表示输出范围，*beg2* 和 *end2* 表示第二个输入范围。

##### 接受单个目标迭代器的算法

*dest*参数是一个表示算法可以写入的目的位置的迭代器，算法假定（assume）：按其需要写入数据，不管写入多少个元素都是安全的。

警告⚠️：向输出迭代器写入数据的算法都假定目标空间足够容纳要写入的数据。

如果*dest*是一个直接指向容器的迭代器，那么算法将输出数据写到容器中已存在的元素内，更常见的情况是，*dest*被绑定到一个插入迭代器或一个`ostream_iterator`。

##### 接受第二个输入序列的算法

单用beg2或beg2与end2的算法用这些迭代器来表示第二个输入范围，通常用第二个范围的元素与第一个输入范围结合起来进行一些运算。

接受单独一个迭代器参数beg2，表示第二个输入范围的算法都假定从迭代器参数beg2开始的序列至少与第一个输入范围一样大。

#### 算法命名规范（Algorithm Naming Conventions）

##### 一些算法使用重载形式传递一个谓词

```c++
unique(beg, end);		//使用==比较元素
unique(beg, end, comp); //使用comp比较元素
```

##### _if版本的算法

接受谓词参数的算法都有附加的`_if` 后缀，比如下面用pred（可能是函数可能是表达式）做一个判断

```c++
find(beg, end, val);       // find the first instance of val in the input range
find_if(beg, end, pred);   // find the first instance for which pred is true
```

##### 区分拷贝元素和不拷贝元素的版本

将执行结果**写入额外目的空间**的算法都有`_copy` 后缀。

```c++
reverse(beg, end);              // reverse the elements in the input range
reverse_copy(beg, end, dest);   // copy elements in reverse order into dest
```

一些算法同时提供`_copy` 和`_if` 版本。

### 特定容器算法（Container-Specific Algorithms）

与其他容器不同， `list` 和 `forward_list` 分别提供双向迭代器和前向迭代器，而通用算法里许多算法（如`sort`）要求随机访问迭代器，因此不能用于 `list` 和 `forward_list` 。

故，对于 `list` 和 `forward_list` 类型，应该优先使用**成员函数版本**的算法，而非通用算法。

`list` 和 `forward_list` 成员函数版本的算法：

![10-9](https://tva1.sinaimg.cn/large/006y8mN6ly1g79p0atiltj30kz08stao.jpg)

`list` 和 `forward_list` 的 `splice` 函数可以进行容器合并，此算法是链表数据结构所特有的，因此不需要通用版本，其参数如下：

![10-10](https://tva1.sinaimg.cn/large/006y8mN6ly1g79p73d53dj30kz07qdhk.jpg)

链表特有版本的算法操作会改变底层容器。

## Chapter11 关联容器（associative-container）

关联容器和顺序容器有着根本的不同：关联容器中的元素是按**关键字**来保存和访问的，而顺序容器中的元素是按它们在容器中的位置来顺序保存和访问的。

关联容器支持高效的关键字查找和访问操作。2 个主要的关联容器（associative-container）类型是 `map` 和 `set`。

- `map` 中的元素是一些键值对（key-value）：关键字起索引作用，值表示与索引相关联的数据。比如字典。
- `set` 中每个元素只包含一个关键字，支持高效的关键字查询操作：检查一个给定关键字是否在 `set` 中。比如文本处理中用`set`保存想要忽略的单词。

标准库提供了 8 个关联容器，它们之间的不同体现在三个方面：

- 是 `map` 还是 `set` 类型。
- 是否允许保存重复的关键字。
- 是否按顺序保存元素。

允许重复保存关键字的容器名字都包含单词 `multi`；无序保存元素的容器名字都以单词 `unordered` 开头。

![11-1](https://tva1.sinaimg.cn/large/006y8mN6ly1g79q8i7z90j30ji06twfn.jpg)

`map` 和 `multimap` 类型定义在头文件 *map* 中；`set` 和 `multiset` 类型定义在头文件 *set* 中；无序容器定义在头文件 *unordered_map* 和 *unordered_set* 中。

### 使用关联容器（Using an Associative Container）

`map` 类型通常被称为关联数组（associative array）。

从 `map` 中提取一个元素时，会得到一个 `pair` 类型的对象。`pair` 是一个模板类型，保存两个名为 `first` 和 `second` 的公有数据成员。`map` 所使用的 `pair` 用 `first` 成员保存关键字，用 `second` 成员保存对应的值。

比如下面的程序用`map`统计单词出现的次数：

```c++
// count the number of times each word occurs in the input
map<string, size_t> word_count;     // empty map from string to size_t
string word;
while (cin >> word)
    ++word_count[word];     // fetch and increment the counter for word
for (const auto &w : word_count)    // for each element in the map
    // print the results
    cout << w.first << " occurs " << w.second
        << ((w.second > 1) ? " times" : " time") << endl;
```

`set` 类型的 `find` 成员返回一个迭代器。如果给定关键字在 `set` 中，则迭代器指向该关键字，否则返回的是尾后迭代器。

对单词统计程序稍加修改，统计那些不在`set`集合里的单词出现次数：

```c++
if(exclude.find(word) == exclude.end())
    ++word_count[word];     // fetch and increment the counter for word
```

### 关联容器概述（Overview of the Associative Containers）

### 定义关联容器（Defining an Associative Container）

定义 `map` 时，必须指定关键字类型和值类型；定义 `set` 时，只需指定关键字类型，因为`set`中没有值。

初始化 `map` 时，提供的每个键值对用花括号 `{}` 包围。

在新标准下，可以对关联容器进行值初始化。

```c++
map<string, size_t> word_count;   // empty
// list initialization
set<string> exclude = { "the", "but", "and" };
// three elements; authors maps last name to first
map<string, string> authors =
{
    {"Joyce", "James"},
    {"Austen", "Jane"},
    {"Dickens", "Charles"}
};
```

`map` 和 `set` 中的关键字必须唯一，`multimap` 和 `multiset` 没有此限制。

#### 关键字类型的要求

对于有序容器 ——`map`、`multimap`、`set` 和 `multiset`，**关键字类型必须定义元素比较的方法**。默认情况下，标准库使用关键字类型的 `<` 运算符来进行比较操作。

##### 有序容器的关键字类型

可以向一个算法提供我们自己定义的比较操作，与之类似，也可以提供自己定义的操作来代替关键字上的`<`运算符，所提供的操作必须在关键字类型上定义一个**严格弱序（strict weak ordering）**，即小于等于，

##### 使用关键字类型的比较函数

用来组织容器元素的操作的类型也是该容器类型的一部分。如果需要使用自定义的比较操作，则必须在定义关联容器类型时提供此操作的类型。操作类型在尖括号中紧跟着元素类型给出。

```c++
bool compareIsbn(const Sales_data &lhs, const Sales_data &rhs)
{
    return lhs.isbn() < rhs.isbn();
}

// bookstore can have several transactions with the same ISBN
// elements in bookstore will be in ISBN order
multiset<Sales_data, decltype(compareIsbn)*> bookstore(compareIsbn);
```

此处，`compareIsbn`作为一个函数传入`decltype`，必须加入一个`*`来指出我们要使用一个给定函数类型的指针

#### pair类型

`pair` 定义在头文件 *utility* 中。一个 `pair` 可以保存两个数据成员，分别命名为 `first` 和 `second`，都是public的。

类似容器，`pair`是一个用来生成特定类型的模板，当创建一个`pair`时，我们必须提供两个类型名，`pair`的数据成员将具有对应的类型，两个类型不要求一样

```c++
pair<string, string> anon;        // holds two strings
pair<string, size_t> word_count;  // holds a string and an size_t
pair<string, vector<int>> line;   // holds string and vector<int>
```

`pair` 的默认构造函数对数据成员进行值初始化，也可以用列表显式初始化。

![11-2](https://tva1.sinaimg.cn/large/006y8mN6ly1g79tk2623bj30kz0b70xl.jpg)

在 C++11 中，如果函数需要返回 `pair`，可以对返回值进行列表初始化。早期 C++ 版本中必须显式构造返回值。

```c++
pair<string, int> process(vector<string> &v)
{
    // process v
    if (!v.empty())
        // list initialize，C++11才有的
        return { v.back(), v.back().size() };
  			// return pair<string, int>(v.back(), v.back().size());		//早期C++版本必须用这种显式构造返回值
  			// return make_pair(v.back(), v.back().size());						//也可以用make_pair函数生成pair对象
    else
        // 隐式构造返回值（空）
        return pair<string, int>();
}
```

### 关联容器操作（Operations on Associative Containers）

关联容器定义了类型别名来表示容器关键字和值的类型：

![11-3](https://tva1.sinaimg.cn/large/006y8mN6ly1g7acm6mh0jj30ji02x3yu.jpg)

对于 `set` 类型，`key_type` 和 `value_type` 是一样的。`set` 中保存的值就是关键字。对于 `map` 类型，元素是关键字 - 值对。即每个元素是一个 `pair` 对象，包含一个关键字和一个关联的值。由于元素关键字不能改变，因此 `pair` 的关键字部分是 `const` 的。

```c++
set<string>::value_type v1;        // v1 is a string
set<string>::key_type v2;          // v2 is a string
map<string, int>::value_type v3;   // v3 is a pair<const string, int>
map<string, int>::key_type v4;     // v4 is a string
map<string, int>::mapped_type v5;  // v5 is an int
```

#### 关联容器迭代器（Associative Container Iterators）

解引用关联容器迭代器时，会得到一个类型为容器的 `value_type` 的引用。对 `map` 而言，`value_type` 是 `pair` 类型，其 `first` 成员保存 `const` 的关键字，`second` 成员保存值。

因为`map`的`value_type`是一个`pair`，我们可以改变`pair`的值，但不能改变关键字成员的值。

```c++
// get an iterator to an element in word_count
auto map_it = word_count.begin();
// *map_it is a reference to a pair<const string, size_t> object
cout << map_it->first;          // prints the key for this element
cout << " " << map_it->second;  // prints the value of the element
map_it->first = "new key";      // error: key is const
++map_it->second;               // ok: we can change the value through an iterator
```

虽然 `set` 同时定义了 `iterator` 和 `const_iterator` 类型，但两种迭代器都只允许只读访问 `set` 中的元素。类似 `map`，`set` 中的关键字也是 `const` 的。

```c++
set<int> iset = {0,1,2,3,4,5,6,7,8,9};
set<int>::iterator set_it = iset.begin();
if (set_it != iset.end())
{
    *set_it = 42;       // error: keys in a set are read-only
    cout << *set_it << endl;    // ok: can read the key
}
```

`map` 和 `set` 都支持 `begin` 和 `end` 操作。使用迭代器遍历 `map`、`multimap`、`set` 或 `multiset` 时，迭代器按关键字升序遍历元素。

通常不对关联容器使用泛型算法。关联容器不支持写算法，因为关键字是不能改变的，而且对于许多只读算法，调用关联容器自己的成员函数算法会比泛型算法高效，但有时候可以使用泛型算法把关联容器当做源序列或目的位置。

#### 添加元素（Adding Elements）

使用 `insert` 成员可以向关联容器中添加元素。向 `map` 和 `set` 中添加已存在的元素对容器没有影响。

`set`的`insert`成员有两个版本，分别接受一对迭代器，或是一个初始化列表。

```c++
vector<int> ivec = {2,4,6,8,2,4,6,8};
set<int> set2;
set2.insert{ivec.cbegin(), ivec.cend()};
set2.insert{{1,3,5,7,1,3,5,7}};
```

通常情况下，对于想要添加到 `map` 中的数据，并没有现成的 `pair` 对象。可以直接在 `insert` 的参数列表中创建 `pair`。

```c++
// four ways to add word to word_count
word_count.insert({word, 1});
word_count.insert(make_pair(word, 1));
word_count.insert(pair<string, size_t>(word, 1));
word_count.insert(map<string, size_t>::value_type(word, 1));
```

关联容器的 `insert` 操作：

![11-4](https://tva1.sinaimg.cn/large/006y8mN6ly1g7adpxhdvlj30kz093dib.jpg)

`insert` 或 `emplace` 的返回值依赖于容器类型和参数：

- 对于不包含重复关键字的容器，添加单一元素的 `insert` 和 `emplace` 版本返回一个 `pair`，表示操作是否成功。`pair` 的 `first` 成员是一个迭代器，指向具有给定关键字的元素；`second` 成员是一个 `bool` 值。如果关键字已在容器中，则 `insert` 什么事情也不做，返回值中的`bool` 值为 `false`。如果关键字不存在，元素会被添加至容器中，`bool` 值为 `true`。
- 对于允许包含重复关键字的容器，添加单一元素的 `insert` 和 `emplace` 版本返回指向新元素的迭代器，无须`bool`值，因为插入总会生效。

#### 删除元素（Erasing Elements）

关联容器的删除操作：

![11-5](https://tva1.sinaimg.cn/large/006y8mN6ly1g7advxamifj30kz051wgk.jpg)

与顺序容器不同，关联容器提供了一个额外的 `erase` 操作。它接受一个 `key_type` 参数，删除所有匹配给定关键字的元素（如果存在），返回实际删除的元素数量。对于不包含重复关键字的容器，`erase` 的返回值总是 1 或 0。若返回值为 0，则表示想要删除的元素并不在容器中。对于`multset`或`multimap`，删除元素数量可能大于1。

#### map的下标操作（Subscripting a map）

`map` 下标运算符接受一个关键字，**获取与此关键字相关联的值**。如果关键字不在容器中，下标运算符会向容器中添加该关键字，并值初始化关联值。我们不能对`multimap`和`unordered_multimap`执行下标操作，因为可能会有多个值对应关键字。

由于下标运算符可能向容器中添加元素，所以只能对非 `const` 的 `map` 使用下标操作。顺序容器的下标操作则必须确保存在，否则会报错。

`set`类型不支持下标，因为只有关键字，没有值，下标没意义。

![11-6](https://github.com/czs108/Cpp-Primer-5th-Notes-CN/raw/master/Chapter-11%20Associative%20Containers/Images/11-6.png)

#### 访问元素（Accessing Elements）

关联容器的查找操作：

![11-7](https://tva1.sinaimg.cn/large/006y8mN6ly1g7aeauxi4yj30kz07d406.jpg)

对于`map`，直接使用下标操作，很有可能插入一个新值，若想检查某值是否存在，应该用`find`成员函数。

对于`multimap/set`，情况则复杂许多，因为可能有多个元素具有相同关键字，这里提供三种方法访问这些元素：

##### 相邻存储

如果 `multimap` 或 `multiset` 中有多个元素具有相同关键字，则这些元素在容器中会**相邻存储**，这给我们遍历这些同一关键字的元素带来了方便。

```c++
multimap<string, string> authors;
// adds the first element with the key Barth, John
authors.insert({"Barth, John", "Sot-Weed Factor"});
// ok: adds the second element with the key Barth, John
authors.insert({"Barth, John", "Lost in the Funhouse"});

string search_item("Alain de Botton");      // author we'll look for
auto entries = authors.count(search_item);  // number of elements
auto iter = authors.find(search_item);      // first entry for this author
// loop through the number of entries there are for this author
while(entries)
{
    cout << iter->second << endl;   // print each title
    ++iter;      // advance to the next title
    --entries;   // keep track of how many we've printed
}
```

##### lower_bound和upper_bound

用相邻存储的特性解决问题，看上去挺巧妙的，但是不是很直观，成员函数`lower_bound`和`upper_bound`使用了一种面向迭代器的方法访问`multiset/map`的同一关键字元素。

`lower_bound` 和 `upper_bound` 操作都接受一个关键字，返回一个迭代器。如果关键字在容器中，`lower_bound` 返回的迭代器会指向第一个匹配给定关键字的元素，而 `upper_bound` 返回的迭代器则指向最后一个匹配元素之后的位置。如果关键字不在 `multimap` 中，则 `lower_bound` 和 `upper_bound` 会**返回相等的迭代器**，指向一个不影响排序的关键字插入位置。因此用相同的关键字调用 `lower_bound` 和 `upper_bound` 会得到一个迭代器范围，表示所有具有该关键字的元素范围。

**于是可以通过递增迭代器来遍历这些元素**：

```c++
// definitions of authors and search_item as above
// beg and end denote the range of elements for this author
for (auto beg = authors.lower_bound(search_item),
        end = authors.upper_bound(search_item);
    beg != end; ++beg)
    cout << beg->second << endl;    // print each title
```

`lower_bound` 和 `upper_bound` 有可能返回尾后迭代器。如果查找的元素具有容器中最大的关键字，则 `upper_bound` 返回尾后迭代器。如果关键字不存在，且大于容器中任何关键字，则 `lower_bound` 也返回尾后迭代器。

##### equal_range

`equal_range` 操作接受一个关键字，返回一个迭代器 `pair`。若关键字存在，则第一个迭代器指向第一个匹配关键字的元素，第二个迭代器指向最后一个匹配元素之后的位置。若关键字不存在，则两个迭代器都指向一个不影响排序的关键字插入位置。

```c++
// definitions of authors and search_item as above
// pos holds iterators that denote the range of elements for this key
for (auto pos = authors.equal_range(search_item);
        pos.first != pos.second; ++pos.first)
    cout << pos.first->second << endl;  // print each title
```

### 无序容器（The Unordered Containers）

新标准库定义了 4 个无序关联容器（unordered associative container），这些容器使用**哈希函数（hash function）**和关键字类型的 `==` 运算符组织元素。在关键字类型的元素没有明显的序关系的情况下，无序容器是非常有用的，在某些应用中，维护元素的序的代价非常高，此时无序容器也很有用。

无序容器和对应的有序容器通常可以相互替换。但是由于元素未按顺序存储，使用无序容器的程序输出一般会与有序容器的版本不同。

##### 管理桶

无序容器在存储上组织为**一组桶**，每个桶保存零或多个元素。无序容器使用一个哈希函数将**元素映射到桶**。为了访问一个元素，容器首先计算元素的哈希值，它指出应该搜索哪个桶。容器将具有一个特定哈希值的所有元素都保存在相同的桶中。因此无序容器的性能依赖于哈希函数的质量和桶的数量及大小。

对于相同的参数，哈希函数总是产生相同的结果，允许将不同关键字的元素映射到相同的桶，当一个桶保存多个元素时，需要顺序搜索这些元素来查找我们想要的那个。如果在一个桶中保存了很多元素，那么查找一个特定元素就需要大量比较操作。

无序容器管理操作：

![11-8](https://tva1.sinaimg.cn/large/006y8mN6ly1g7atpjg953j30kz0bcwgz.jpg)

##### 无序容器对关键字类型的要求

默认情况下，无序容器使用关键字类型的 `==` 运算符比较元素，还使用一个 `hash<key_type>` 类型的对象来生成每个元素的哈希值。标准库为内置类型和一些标准库类型提供了 hash 模板。因此可以直接定义关键字是这些类型的无序容器，而不能直接定义关键字类型为自定义类类型的无序容器，必须先提供对应的 hash 模板版本。

## Chapter12 动态内存

除了自动和static对象外，C++还支持动态分配对象，动态分配的对象的生存期与它们在哪里创建是无关的，只有当被显式释放时，这些对象才会销毁。

- 静态内存用来保存局部static对象、类static对象成员，这些对象在使用之前分配，在程序结束时销毁。
- 而栈内存用来保存定义在函数内的非static对象，这些对象仅在程序块运行时才存在。

除此之外，程序用一个内存池，被称为**自由空间（free store）**或**堆（heap）**，来存储**动态分配（dynamically allocate）**的对象。动态对象的生存期由程序控制。

### 动态内存与智能指针（Dynamic Memory and Smart Pointers）

C++ 中的动态内存管理通过一对运算符完成：`new` 在动态内存中为对象分配空间并返回指向该对象的指针，可以选择对对象进行初始化；`delete` 接受一个动态对象的指针，销毁该对象并释放与之关联的内存。

动态内存的使用极易出问题，因为确保释放内存是很困难的，有时我们忘记释放内存，这称之为**内存泄漏**，有时在尚有指针引用内存的情况下我们就释放了它，这就会产生**引用非法内存的指针**。

新标准库提供了两种**智能指针（smart pointer）**类型来管理动态对象。智能指针的行为类似常规指针，但它自动释放所指向的对象。这两种智能指针的区别在于管理底层指针的方式：`shared_ptr` 允许多个指针指向同一个对象；`unique_ptr` 独占所指向的对象。标准库还定义了一个名为 `weak_ptr` 的伴随类，它是一种弱引用，指向 `shared_ptr` 所管理的对象。这三种类型都定义在头文件 *memory* 中。

#### shared_ptr类

类似`vector`，智能指针也是模板，因此必须要用尖括号指明指针指向的类型。默认初始化的智能指针中保存着一个空指针。

```c++
shared_ptr<string> p1;      // shared_ptr that can point at a string
shared_ptr<list<int>> p2;   // shared_ptr that can point at a list of ints
```

`shared_ptr` 和 `unique_ptr` 都支持的操作：

![12-1](https://tva1.sinaimg.cn/large/006y8mN6ly1g7awvwab41j30kz078jsd.jpg)

`shared_ptr` 独有的操作：

![12-2](https://github.com/czs108/Cpp-Primer-5th-Notes-CN/raw/master/Chapter-12%20Dynamic%20Memory/Images/12-2.png)

##### make_shared函数

最安全的分配和使用动态内存的方法：`make_shared` 函数（定义在头文件 *memory* 中）在动态内存中分配一个对象并初始化它，返回指向此对象的 `shared_ptr`。

```c++
// shared_ptr that points to an int with value 42
shared_ptr<int> p3 = make_shared<int>(42);
// p4 points to a string with value 9999999999
shared_ptr<string> p4 = make_shared<string>(10, '9');
// p5 points to an int that is value initialized
shared_ptr<int> p5 = make_shared<int>();
// p6指向一个动态分配的空vector<string>，用auto最简单
auto p6 = make_shared<vector<string>>();
```

类似顺序容器的`emplace`成员，`make_shared`用其参数来构造给定类型的对象，如果不传递任何参数，对象会值初始化。

##### shared_ptr的拷贝和赋值

进行拷贝或赋值操作时，每个 `shared_ptr` 会记录有多少个其他 `shared_ptr` 与其指向相同的对象。

```c++
auto p = make_shared<int>(42);  // object to which p points has one user
auto q(p);  // p and q point to the same object
            // object to which p and q point has two users
```

每个 `shared_ptr` 都有一个与之关联的计数器，通常称为**引用计数（reference count）**。拷贝 `shared_ptr` 时引用计数会递增。例如使用一个 `shared_ptr` 初始化另一个 `shared_ptr`，或将它作为参数传递给函数以及作为函数的返回值返回。给 `shared_ptr` 赋予新值或 `shared_ptr` 被销毁时引用计数会递减。例如一个局部 `shared_ptr` 离开其作用域。一旦一个 `shared_ptr` 的引用计数变为 0，它就会自动释放其所管理的对象。

```c++
auto r = make_shared<int>(42);  // int to which r points has one user
r = q;  // assign to r, making it point to a different address
        // increase the use count for the object to which q points
        // reduce the use count of the object to which r had pointed
        // the object r had pointed to has no users; that object is automatically freed
```

##### shared_ptr自动销毁所管理的对象

`shared_ptr` 的**析构函数（destructor）**会递减它所指向对象的引用计数。如果引用计数变为 0，`shared_ptr` 的析构函数会销毁对象并释放空间。

##### 动态生存期

如果将 `shared_ptr` 存放于容器中，而后不再需要全部元素，而只使用其中一部分，应该用 `erase` 删除不再需要的元素。

程序使用动态内存通常出于以下三种原因之一：

- 不确定需要使用多少对象。
- 不确定所需对象的准确类型。
- 需要在多个对象间共享数据。

#### 直接管理内存（Managing Memory Directly）

相对于智能指针，使用 `new` 和 `delete` 管理内存很容易出错。

##### 使用new动态分配和初始化对象

默认情况下，动态分配的对象是默认初始化的。所以内置类型或组合类型的对象的值将是未定义的，而类类型对象将用默认构造函数进行初始化。

```c++
string *ps = new string;    // initialized to empty string
int *pi = new int;     // pi points to an uninitialized int
```

可以使用值初始化方式、直接初始化方式、传统构造方式（圆括号 `()`）或新标准下的列表初始化方式（花括号 `{}`）初始化动态分配的对象。

```c++
int *pi = new int(1024);            // object to which pi points has value 1024
string *ps = new string(10, '9');   // *ps is "9999999999"
// vector with ten elements with values from 0 to 9
vector<int> *pv = new vector<int>{0,1,2,3,4,5,6,7,8,9};
string *ps1 = new string;     // default initialized to the empty string
string *ps = new string();    // value initialized to the empty string
int *pi1 = new int;      // default initialized; *pi1 is undefined
int *pi2 = new int();    // value initialized to 0; *pi2 is 0
```

只有当初始化的括号中仅有单一初始化器时才可以使用 `auto`。

```c++
auto p1 = new auto(obj);    // p points to an object of the type of obj
                            // that object is initialized from obj
auto p2 = new auto{a,b,c};  // error: must use parentheses for the initializer
```

##### 动态分配的const对象

可以用 `new` 分配 `const` 对象，返回指向 `const` 类型的指针。**动态分配的 `const` 对象必须初始化**。

```c++
//分配并初始化一个const int
const int *pci = new const int(1024);
//分配并默认初始化一个const的空string
const string *pcs = new const string;
```

##### 内存耗尽

默认情况下，如果 `new` 不能分配所要求的内存空间，会抛出 `bad_alloc` 异常。使用**定位 `new`（placement new）**可以阻止其抛出异常。定位 `new` 表达式允许程序向 `new` 传递额外参数。如果将 `nothrow` 传递给 `new`，则 `new` 在分配失败后会返回空指针。`bad_alloc` 和 `nothrow` 都定义在头文件 *new* 中。

```c++
// if allocation fails, new returns a null pointer
int *p1 = new int;            // if allocation fails, new throws std::bad_alloc
int *p2 = new (nothrow) int;  // if allocation fails, new returns a null pointer
```

##### 使用delete释放动态内存

通过**`delete`表达式**将内存动态归还给系统，其指向我们想要释放的对象。

使用 `delete` 释放一块并非 `new` 分配的内存，或者将相同的指针值释放多次的行为是未定义的。

```c++
int i, *pi1 = &i, *pi2 = nullptr;
double *pd = new double(33), *pd2 = pd;
delete i;			//错误，i不是指针
delete pi1;		//未定义，pi1指向一个局部变量（不是new出来的）
delete pd;		//正确
delete pd2;		//未定义，pd2指向的内存已经被释放了
delete pi2;		//正确，释放一个空指针总是没有错误的
const int *pci = new const int(1024);
delete pci;		//正确，释放一个const对象
```

##### 动态对象的生存期直到被释放时为止

返回指向动态内存的指针（不是智能指针）的函数给其调用者增加了一个额外负担——调用者必须记得释放内存

小心：动态内存的管理非常容易出错！

- 忘记`delete`内存
- 使用已经释放掉的对象
- 同一块内存释放两次

> 建议：坚持只使用智能指针，就可以避免所有这些问题，只有在没有任何智能指针指向它的情况下，智能指针才会自动释放它。

##### delete之后重置指针值

`delete` 一个指针后，指针值就无效了，称为**空悬指针（dangling pointer）**。为了防止后续的错误访问，应该在 `delete` 之后将指针值置空，赋予`nullptr`即可。

但是如果有多个指针同时指向了要`delete`的对象，往往只记得对其中一个指针重置空值，另外一个指针仍然悬空，在实际中，查找指向相同内存的所有指针是异常困难的。

#### shared_ptr和new结合使用

可以用 `new` 返回的指针初始化智能指针。该构造函数是 `explicit` 的，因此必须使用直接初始化形式。

```c++
shared_ptr<int> p1 = new int(1024);    // error: must use direct initialization
shared_ptr<int> p2(new int(1024));     // ok: uses direct initialization
```

默认情况下，用来初始化智能指针的内置指针必须指向动态内存，因为智能指针默认使用 `delete` 释放它所管理的对象。如果要将智能指针绑定到一个指向其他类型资源的指针上，就必须提供自定义操作来代替 `delete`。

![12-3](https://tva1.sinaimg.cn/large/006y8mN6ly1g7cpyqdakuj30kz09jacb.jpg)

```c++
// ptr is created and initialized when process is called
void process(shared_ptr<int> ptr)
{
    // use ptr
}   // ptr goes out of scope and is destroyed

int *x(new int(1024));   // dangerous: x is a plain pointer, not a smart pointer
process(x);     // error: cannot convert int* to shared_ptr<int>
process(shared_ptr<int>(x));    // legal, but the memory of int pointed by x will be deleted!
int j = *x;     // undefined: x is a dangling pointer!

shared_ptr<int> p(new int(42));   // reference count is 1
process(p);     // copying p increments its count; in process the reference count is 2, out process the reference count is 1
int i = *p;     // ok: reference count is 1
```

智能指针的 `get` 函数返回一个内置指针，指向智能指针管理的对象。主要用于向不能使用智能指针的代码传递内置指针。使用 `get` 返回指针的代码不能 `delete` 此指针。**永远不要用`get`初始化另一个只能指针或者为另一个智能指针赋值**。

```c++
shared_ptr<int> p(new int(42));    // reference count is 1
int *q = p.get();   // ok: but don't use q in any way that might delete its pointer
{   // new block
    // undefined: two independent shared_ptrs point to the same memory
    shared_ptr<int>(q);
} // block ends, q is destroyed, and the memory to which q points is freed
int foo = *p;   // undefined; the memory to which p points was freed
```

可以用 `reset` 函数将新的指针赋予 `shared_ptr`。与赋值类似，`reset` 会更新引用计数，如果需要的话，还会释放内存空间。`reset` 经常与 `unique` 一起使用，来控制多个 `shared_ptr` 共享的对象。

```c++
if (!p.unique())
    p.reset(new string(*p));   // we aren't alone; allocate a new copy
*p += newVal;   // now that we know we're the only pointer, okay to change this object
```

#### 智能指针和异常

如果使用智能指针，即使程序块过早结束，智能指针类也能确保在内存不再需要时将其释放。

```c++
void f()
{
    int *ip = new int(42);    // dynamically allocate a new object
    // code that throws an exception that is not caught inside f
    delete ip;     // free the memory before exiting
}

void f()
{
    shared_ptr<int> sp(new int(42));    // allocate a new object
    // code that throws an exception that is not caught inside f
} // shared_ptr freed automatically when the function ends
```

并不是所有类定义了析构函数，所以这些类都要求用户显式地释放资源，但用户经常忘记，这时使用`shared_ptr`是个很有效的方法，它会自动销毁对象。

默认情况下 `shared_ptr` 假定其指向动态内存，使用 `delete` 释放对象。创建 `shared_ptr` 时可以传递一个（可选）指向删除函数的指针参数，用来代替 `delete`。这个**删除器（deleter）**函数必须能够完成对`shared_ptr`中保存的指针进行释放的操作。

智能指针规范：

- 不使用相同的内置指针值初始化或 `reset` 多个智能指针。
- 不释放 `get` 返回的指针。
- 不使用 `get` 初始化或 `reset` 另一个智能指针。
- 使用 `get` 返回的指针时，如果最后一个对应的智能指针被销毁，指针就无效了。
- 使用 `shared_ptr` 管理并非 `new` 分配的资源时，应该传递删除函数。

#### unique_ptr

与 `shared_ptr` 不同，同一时刻只能有一个 `unique_ptr` 指向给定的对象。当 `unique_ptr` 被销毁时，它指向的对象也会被销毁。

`make_unique` 函数（C++14 新增，定义在头文件 *memory* 中）在动态内存中分配一个对象并初始化它，返回指向此对象的 `unique_ptr`。

初始化`unique_ptr`必须采用直接初始化形式，由于一个`unique_ptr`拥有它指向的对象，因此`unique_ptr`不支持普通的拷贝或赋值操作。

`unique_ptr` 操作：

![12-4](https://github.com/czs108/Cpp-Primer-5th-Notes-CN/raw/master/Chapter-12%20Dynamic%20Memory/Images/12-4.png)

`release` 函数返回 `unique_ptr` 当前保存的指针并将其置为空。**即放弃所有权，原来的内存不会被释放！**

`reset` 函数成员接受一个可选的指针参数，重新设置 `unique_ptr` 保存的指针。如果 `unique_ptr` 不为空，则它原来指向的对象会被释放。

利用这两个成员函数，可以实现`unique_ptr`的所有权转换到另一个`unique_ptr`上：

```c++
// transfers ownership from p1 (which points to the string Stegosaurus) to p2
unique_ptr<string> p2(p1.release());    // release makes p1 null
unique_ptr<string> p3(new string("Trex"));
// transfers ownership from p3 to p2
p2.reset(p3.release()); // reset deletes the memory to which p2 had pointed
```

调用 `release` 会切断 `unique_ptr` 和它原来管理的对象之间的联系。`release` 返回的指针通常被用来初始化另一个智能指针或给智能指针赋值。如果没有用另一个智能指针保存 `release` 返回的指针，程序就要负责资源的释放。

```c++
p2.release();   // WRONG: p2 won't free the memory and we've lost the pointer
auto p = p2.release();   // ok, but we must remember to delete(p)
```

不能拷贝 `unique_ptr` 的规则有一个例外：可以拷贝或赋值一个即将被销毁的 `unique_ptr`（移动构造、移动赋值）。

```c++
unique_ptr<int> clone(int p)
{
    unique_ptr<int> ret(new int (p));
    // . . .
    return ret;
}
```

老版本的标准库包含了一个名为 `auto_ptr` 的类，但现在应该用`unique_ptr`。

类似 `shared_ptr`，默认情况下 `unique_ptr` 用 `delete` 释放其指向的对象。`unique_ptr` 的删除器同样可以重载，但 `unique_ptr` 管理删除器的方式与 `shared_ptr` 不同。定义 `unique_ptr` 时必须在尖括号中提供删除器类型。创建或 `reset` 这种 `unique_ptr` 类型的对象时，必须提供一个指定类型的可调用对象（删除器）。

```c++
// p points to an object of type objT and uses an object of type delT to free that object
// it will call an object named fcn of type delT
unique_ptr<objT, delT> p (new objT, fcn);

void f(destination &d /* other needed parameters */)
{
    connection c = connect(&d);  // open the connection
    // when p is destroyed, the connection will be closed
    unique_ptr<connection, decltype(end_connection)*> p(&c, end_connection);
    // use the connection
    // when f exits, even if by an exception, the connection will be properly closed
}
```

##### weak_ptr

`weak_ptr` 是一种不控制所指向对象生存期的智能指针，它指向一个由 `shared_ptr` 管理的对象。将 `weak_ptr` 绑定到 `shared_ptr` 不会改变 `shared_ptr` 的引用计数。如果 `shared_ptr` 被销毁，即使有 `weak_ptr` 指向对象，对象仍然有可能被释放。

![12-5](https://github.com/czs108/Cpp-Primer-5th-Notes-CN/raw/master/Chapter-12%20Dynamic%20Memory/Images/12-5.png)

创建一个 `weak_ptr` 时，需要使用 `shared_ptr` 来初始化它。

```c++
auto p = make_shared<int>(42);
weak_ptr<int> wp(p);    // wp weakly shares with p; use count in p is unchanged
```

使用 `weak_ptr` 访问对象时，必须先调用 `lock` 函数。该函数检查 `weak_ptr` 指向的对象是否仍然存在。如果存在，则返回指向共享对象的 `shared_ptr`，否则返回空指针。

```c++
if (shared_ptr<int> np = wp.lock())
{ 
    // true if np is not null
    // inside the if, np shares its object with p
}
```

### 动态数组（Dynamic Arrays）

使用 `allocator` 类可以将内存分配和初始化过程分离，这通常会提供更好的性能和更灵活的内存管理能力。

大多数应用应该使用标准库容器而不是动态分配的数组，使用容器更为简单、更不容易出现内存管理错误并且可能有更好地性能。

#### new和数组

使用 `new` 分配对象数组时需要在类型名之后跟一对方括号，在其中指明要分配的对象数量（必须是整型，但不必是常量）。`new` 返回指向第一个对象的指针（元素类型）。

```c++
// call get_size to determine how many ints to allocate
int *pia = new int[get_size()];   // pia points to the first of these ints
```

虽然通常称使用`new`分配的内存为”动态数组“，但准确地说应该是返回一个元素类型的指针，由于 `new` 分配的内存并不是数组类型，因此不能对动态数组调用 `begin` 和 `end`，也不能用范围 `for` 语句处理其中的元素。

> 动态数组不是数组！

默认情况下，`new` 分配的对象是默认初始化的。可以对数组中的元素进行值初始化，方法是在大小后面跟一对空括号 `()`。在新标准中，还可以提供一个元素初始化器的花括号列表。如果初始化器数量大于元素数量，则 `new` 表达式失败，不会分配任何内存，并抛出 `bad_array_new_length` 异常。

```c++
int *pia = new int[10];     // block of ten uninitialized ints
int *pia2 = new int[10]();    // block of ten ints value initialized to 0
string *psa = new string[10];    // block of ten empty strings
string *psa2 = new string[10]();    // block of ten empty strings
// block of ten ints each initialized from the corresponding initializer
int *pia3 = new int[10] { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
// block of ten strings; the first four are initialized from the given initializers
// remaining elements are value initialized
string *psa3 = new string[10] { "a", "an", "the", string(3,'x') };
```

动态分配一个空数组是合法的，此时 `new` 会返回一个合法的非空指针。对于零长度的数组来说，该指针类似尾后指针，不能解引用。

使用 `delete[]` 释放动态数组，数组中的元素按逆序销毁，**方括号是必需的**。

```c++
delete p;       // p must point to a dynamically allocated object or be null
delete [] pa;   // pa must point to a dynamically allocated array or be null
```

如果在 `delete` 数组指针时忘记添加方括号，或者在 `delete` 单一对象时使用了方括号，编译器很可能不会给出任何警告，程序可能会在执行过程中行为异常。

`unique_ptr` 可以直接管理动态数组，定义时需要在对象类型后添加一对空方括号 `[]`，销毁时会自动调用`delete[]`。

```c++
// up points to an array of ten uninitialized ints
unique_ptr<int[]> up(new int[10]);
up.release();   // automatically uses delete[] to destroy its pointer
```

指向数组的 `unique_ptr`：

![12-6](https://tva1.sinaimg.cn/large/006y8mN6ly1g7d6m4gq6sj30kz053q3x.jpg)

与 `unique_ptr` 不同，`shared_ptr` 不直接支持动态数组管理。如果想用 `shared_ptr` 管理动态数组，必须提供自定义的删除器。下面是个常见的写法：

```c++
// to use a shared_ptr we must supply a deleter
shared_ptr<int> sp(new int[10], [](int *p) { delete[] p; });
sp.reset();    // uses the lambda we supplied that uses delete[] to free the array
```

`shared_ptr` 未定义下标运算符，智能指针类型也不支持指针算术运算。因此如果想访问 `shared_ptr` 管理的数组元素，必须先用 `get` 获取内置指针，再用内置指针进行访问。

```c++
// shared_ptrs don't have subscript operator and don't support pointer arithmetic
for (size_t i = 0; i != 10; ++i)
    *(sp.get() + i) = i;    // use get to get a built-in pointer
```

### allocator类

`new`不够灵活，它把内存分配和对象构造组合在一起，类似地，`delete`把对象析构和内存释放组合在了一起。当分配一大块内存时，我们通常计划在这块内存上按需构造对象。

标准库`allocator`类定义在头文件memory中，它帮助我们将内存分配和对象构造分离开来。它提供了一种类型感知的内存分配方法，它分配的内存是原始的、未构造的。

`allocator` 类是一个模板，定义时必须指定其可以分配的对象类型。

```c++
allocator<string> alloc;    // object that can allocate strings
auto const p = alloc.allocate(n);   // allocate n unconstructed strings
```

标准库 `allocator` 类及其算法：

![12-7](https://tva1.sinaimg.cn/large/006y8mN6ly1g7d8n8ianqj30kz0900uq.jpg)

`allocator` 分配的内存是未构造的，程序需要在此内存中构造对象。新标准库的 `construct` 函数接受一个指针和零或多个额外参数，在给定位置构造一个元素。额外参数用来初始化构造的对象，必须与对象类型相匹配。

```c++
auto q = p;     // q will point to one past the last constructed element
alloc.construct(q++);    // *q is the empty string
alloc.construct(q++, 10, 'c');  // *q is cccccccccc
alloc.construct(q++, "hi");     // *q is hi!
```

直接使用 `allocator` 返回的未构造内存是错误行为，其结果是未定义的。

对象使用完后，必须对每个构造的元素调用 `destroy` 进行销毁。`destroy` 函数接受一个指针，对指向的对象执行析构函数。

```c++
while (q != p)
    alloc.destroy(--q);  // free the strings we actually allocated
```

`deallocate` 函数用于释放 `allocator` 分配的内存空间。传递给 `deallocate` 的指针不能为空，它必须指向由 `allocator` 分配的内存。而且传递给 `deallocate` 的大小参数必须与调用 `allocator` 分配内存时提供的大小参数相一致。

```c++
alloc.deallocate(p, n);
```

`allocator` 算法：

![12-8](https://tva1.sinaimg.cn/large/006y8mN6ly1g7d8rmzc0wj30kz08xae3.jpg)

传递给 `uninitialized_copy` 的目的位置迭代器必须指向未构造的内存，它直接在给定位置构造元素。返回（递增后的）目的位置迭代器。

练习12.26：`allocator`类的典型用法

```c++
// 12.26
void allocate(){
    allocator<string> alloc;
    auto const p = alloc.allocate(100);
    string s;
    string *q = p;
    while(cin >> s && q != p + 100){
        alloc.construct(q++, s);
    }
    const size_t size = q - p;      // store the number of string read in cin
    for(size_t i = 0; i < size; i++){
        cout << p[i] << " " << endl;
    }
    while(q != p){
        alloc.destroy(--q);         // destroy string
    }
    alloc.deallocate(p, 100);       // free memory
}
```

#### 包扩展（Pack Expansion）

对于一个参数包，除了获取其大小外，唯一能对它做的事情就是**扩展（expand）**。当扩展一个包时，需要提供用于每个扩展元素的**模式（pattern）**。扩展一个包就是将其分解为构成的元素，对每个元素应用模式，获得扩展后的列表。通过在模式右边添加一个省略号`…` 来触发扩展操作。

包扩展工作过程：

```c++
template <typename T, typename... Args>
ostream& print(ostream &os, const T &t, const Args&... rest)   // expand Args
{
    os << t << ", ";
    return print(os, rest...);   // expand rest
}
```

- 第一个扩展操作扩展模板参数包，为 `print` 生成函数参数列表。编译器将模式 `const Args&` 应用到模板参数包 *Args* 中的每个元素上。因此该模式的扩展结果是一个以逗号分隔的零个或多个类型的列表，每个类型都形如 `const type&`。

  ```c++
  print(cout, i, s, 42);   // two parameters in the pack
  ostream& print(ostream&, const int&, const string&, const int&);
  ```

- 第二个扩展操作扩展函数参数包，模式是函数参数包的名字。扩展结果是一个由包中元素组成、以逗号分隔的列表。

  ```c++
  print(os, s, 42);
  ```

扩展操作中的模式会独立地应用于包中的每个元素。

```c++
// call debug_rep on each argument in the call to print
template <typename... Args>
ostream &errorMsg(ostream &os, const Args&... rest)
{
    // print(os, debug_rep(a1), debug_rep(a2), ..., debug_rep(an)
    return print(os, debug_rep(rest)...);
}

// passes the pack to debug_rep; print(os, debug_rep(a1, a2, ..., an))
print(os, debug_rep(rest...));   // error: no matching function to call
```

#### 转发参数包（Forwarding Parameter Packs）

在 C++11 中，可以组合使用可变参数模板和 `forward` 机制来编写函数，实现将其实参不变地传递给其他函数。

```c++
// fun has zero or more parameters each of which is
// an rvalue reference to a template parameter type
template<typename... Args>
void fun(Args&&... args)    // expands Args as a list of rvalue references
{
    // the argument to work expands both Args and args
    work(std::forward<Args>(args)...);
}
```

由于`fun`的参数是右值引用，因此我们可以传递给它任意类型的实参；由于我们使用`std::forward`传递这些实参，因此它们的所有类型信息在调用`work`时都会得到保持。

### 模板特例化（Template Specializations）

在某些情况下，通用模板的定义对特定类型是不合适的，可能编译失败或者操作不正确。如果不希望或不能使用模板版本时，可以定义类或函数模板的**特例化版本**。一个特例化版本就是模板的一个独立定义，其中的一个或多个模板参数被指定为特定类型。

特例化一个函数模板时，必须为模板中的每个模板参数都提供实参。为了指明我们正在实例化一个模板，应该在关键字 `template` 后面添加一个空尖括号对 `<>`。

```c++
// first version; can compare any two types
template <typename T> int compare(const T&, const T&);
// second version to handle string literals
template<size_t N, size_t M>
int compare(const char (&)[N], const char (&)[M]);

const char *p1 = "hi", *p2 = "mom";
compare(p1, p2);        // calls the first template
compare("hi", "mom");   // calls the template with two nontype parameters

// special version of compare to handle pointers to character arrays
template <>
int compare(const char* const &p1, const char* const &p2)
{
    return strcmp(p1, p2);
}
```

特例化的本质是实例化一个模板，而非重载它，因此，特例化不影响函数匹配。

将一个特殊版本的函数定义为特例化模板还是独立的非模板函数会影响到重载函数匹配。

模板特例化遵循普通作用域规则。为了特例化一个模板，原模板的声明必须在作用域中。而使用模板实例时，也必须先包含特例化版本的声明。

> 建议：通常，模板及其特例化版本应该声明在同一个头文件中。所有同名模板的声明放在文件开头，后面是这些模板的特例化版本。

类模板也可以特例化。与函数模板不同，类模板的特例化不必为所有模板参数提供实参，可以只指定一部分模板参数。一个类模板的**部分特例化（partial specialization）**版本本身还是一个模板，用户使用时必须为那些未指定的模板参数提供实参。

只能部分特例化类模板，不能部分特例化函数模板。

```c++
// 通用版本
template <typename T>
struct remove_reference
{
    typedef T type;
};

// 部分特例化版本
template <typename T>
struct remove_reference<T &>   // 左值引用
{
    typedef T type;
};

template <typename T>
struct remove_reference<T &&>  // 右值引用
{
    typedef T type;
};
```

类模板部分特例化版本的模板参数列表是原始模板参数列表的一个子集或特例化版本。

可以只特例化类模板的指定成员函数，而不用特例化整个模板。

```c++
template <typename T>
struct Foo
{
    Foo(const T &t = T()): mem(t) { }
    void Bar() { /* ... */ }
    T mem;
    // other members of Foo
};

template<>      // we're specializing a template
void Foo<int>::Bar()    // we're specializing the Bar member of Foo<int>
{
    // do whatever specialized processing that applies to ints
}

Foo<string> fs;     // instantiates Foo<string>::Foo()
fs.Bar();    // instantiates Foo<string>::Bar()
Foo<int> fi;    // instantiates Foo<int>::Foo()
fi.Bar();    // uses our specialization of Foo<int>::Bar()
```

