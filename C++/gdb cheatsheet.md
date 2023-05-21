# gdb cheatsheet

## GDB

gdb调试中直接输入回车是重复上一步命令

start：临时断点打在main函数处，等候进一步指令

r(run)：从main函数处开始运行程序，直至程序结束/出错/到达断点

shell ls / !ls：在gdb中执行shell命令

set prompt (xxxx) ：修改命令提示符前缀，默认是(gdb)，多gdb调试时用来区分

$gdb -args ./a.out a b c / (gdb) set args a b c：指定程序的命令行参数，下次调用run时就会使用a b c参数，也可以(gdb) run a b c / (gdb) start a b c 

set logging on：将gdb调试的历史保存到日志中；set logging file xx.file：指定gdb调试日志名字，默认是gdb.txt；set logging overwrite on：覆盖之前的gdb调试日志，默认是追加写gdb调试日志

### 函数

info functions：列出可执行文件的所有函数名称

info functions regex：指定函数，使用正则表达式匹配

step（缩写为s）：可以进入函数（函数必须有调试信息）

next（缩写为n）：不进入函数，gdb会等函数执行完，再显示下一行要执行的程序代码

set step-mode on：设置步进模式，进入没有调试信息的函数

finish：执行完当前函数，并且打印返回值

return (expression)：当前函数不会继续执行，而是直接返回，可以指定返回值

call/print：直接调用函数执行

i frame：输出当前函数堆栈帧的地址，指令寄存器的值，局部变量地址及值等信息

i registers：输出当前寄存器中的值

disassemble fun：输出函数的汇编代码

f(frame) n：选择函数堆栈帧，n为层数，

f(frame) addr：选择函数堆栈帧，其中addr是堆栈地址

up n / down n：向上或向下选择函数堆栈帧，n为层数

up-silently n / down-silently n：与上面指令的区别在于，切换堆栈帧后，不会打印信息

### 断点

b Foo::foo / b (anonymous namespace)：命名空间/匿名空间打断点

b *address：当调试汇编程序，或者没有调试信息的程序时，在程序地址上打断点

b：在当前代码行打上断点

info b：输出当前所有断点，它们各自的bnum以及所在的相对路径文件与行号

disable <bnum>：关闭编号为bnum的断点；enable <bnum>：打开编号为bnum的断点；delete <bnum>：删除编号为bnum的断点

b 6：当前文件第6行打断点

b file.c:6：gdb会对所有匹配的文件（file.c)的第6行设置断点

b a/file.c:6：通过指定（部分）路径，来区分相同的文件名

b a/file.c:6 if i==100：设置条件断点

condition <bnum> (<condition>)：把bnum断点的条件修改为condition

ignore <bnum> count：接下来count次编号为bnum的断点触发都不会让程序中断

tb(tbreak) a/file.c:6：设置临时断点，断点只会生效一次，然后就会删除

rbreak regexp：在所有匹配regexp的函数名都设置断点，regexp与grep相同

在程序入口处打断点：当调试没有调试信息的程序时，直接运行start命令是没有效果的，如果不知道main在何处，那么可以在程序入口处打断点，两种方法：

```shell

# 方法一：从elf文件处获得程序入口（entry point）

$ strip a.out

$ readelf -h a.out

ELF Header:

  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 

  ...

  Entry point address:               0x400440

  ...

# 方法二：info files

$ gdb a.out 

(gdb) info files

# -------------------------------------------------------- #

(gdb) b *0x400440

```

### 观察点

watch(wa) a：当变量a的值发生变化，程序暂停

watch *(data type*)address：当类型为data type、地址为address的内存发生变化，程序暂停

info disable enable delete用法与断点类似

set can-use-hw-watchpoints：禁止硬件观察点，如果系统支持硬件观察点，设置观察点会有输出` Hardware watchpoint num: expr`，需要注意软件观察点会让程序很慢

watch expr thread threadnum：设置观察点只针对线程编号为threadnum的线程生效（只对硬件观察点生效

rwatch(rw) a：当读取变量a时，程序就会暂停住（只对硬件观察点生效

awatch(aw) a：当发生读取变量a或改变变量a值的行为，程序就会暂停住（只对硬件观察点生效

使用数据断点时，需要注意：

- 当监控变量为局部变量时，一旦局部变量失效，数据断点也会失效
- 如果监控的是指针变量p，则watch *p监控的是p所指内存数据的变化情况，而watch p监控的是p指针本身有没有改变指向
- 最常见的数据断点应用场景：「定位堆上的结构体内部成员何时被修改」。由于指针一般为局部变量，为了解决断点失效，一般有两种方法。

```c++
命令 作用
print &variable 查看变量的内存地址
watch *(type *)address 通过内存地址间接设置断点
watch -l variable 指定location参数
watch variable thread 1 仅编号为1的线程修改变量var值时会中断
```

### catchpoint

简介：use catchpoints to cause the debugger to stop for certain kinds of program events, such as C++ exceptions or the loading of a shared library

catch fork：程序在调用fork系统调用时暂停

tcatch fork：程序只在第一次调用fork时暂停

catch syscall [name | number]：为指定的系统调用设定catchpoint，系统调用和编号的映射参考具体的xml文件，如果不指定具体的系统调用，则会为所有的系统调用设置catchpoint

### 打印

set print elements number-of-elements：打印大数组的元素时缺省最多200个，该命令可以修改该限制

p array[index]@num：打印数组中任意连续元素的值

set print array-indexes on：设置打印数组时同时打印索引下标

bt full：打印函数堆栈各自的局部变量

bt full n：从内向外打印n个栈帧的局部变量

bt full -n：从外向内打印n个栈帧的局部变量

info locals：打印当前函数局部变量的值

p 'stataic-1.c'::var：打印指定文件的静态变量的值

`print *(struct xxx*)ptr` ：查看指向的结构体的内容

whatis he：打印变量he的类型

ptype he：打印变量he的类型的详细信息

`info variable ^he$`：查看定义变量he的文件，`^he$`是正则完全匹配he，如果不完全匹配，可能会匹配到很多变量

x/s：打印ASCII字符串

x/nfu addr：以f格式打印从addr开始的n个长度单元为u的内存值。n：输出单元的个数。f：是输出格式。比如x是以16进制形式输出，o是以8进制形式输出。u：标明一个单元的长度。b是一个byte，h是两个byte（halfword），w是四个byte（word），g是八个byte（giant word）。

> 比如：打印内存地址0x00000001249e1000开始的725293568个字节的数据

l(list) [line_num / func_name]：打印源代码以及行号，可以指定行号与函数名

l -/+：指定打印源代码向前或向后打印

l 1,10：指定打印源代码范围

set print pretty on：设置打印的美化，每行只会显示结构体的一名成员，默认打印结构体是很紧凑的

set print object on：设置打印按照派生对象的类型，设置后会修改p/whatis/ptype的输出结果

p func_in_frame2::b：直接打印调用栈帧中的变量值，不需要先切换到对应栈帧再打印变量值

### 多进程

$ gdb programe -p / --pid：调试已经运行的进程

attach pid：gdb启动后，调用该命令调试已经运行的进程

detach：退出当前正在调试的进程

set follow-fork-mode parent：追踪父进程

set follow-fork-mode child：追踪子进城，父进程退出后程序会自动调试子进程

set detach-on-fork on：fork调用时只追踪其中一个进程

set detach-on-fork off：gdb默认只会跟踪父进程，子进程不受控制，该命令可以同时调试父子进程

set schedule-multiple on：默认情况下，除了当前调试的进程，其他进程都处于挂起状态，所以，如果需要在调试当前进程的时候，其他进程也能正常执行，则执行该命令

info inferiors：查看进程状态，显示*的是当前正在调试的进程

### 多线程

info threads [threadnum]：查看所有线程信息，LWP是lightweight process（轻量级进程）

thread <ID> 切换调试的线程为指定ID的线程。

break file.c:100 thread all  在file.c文件第100行处为所有经过这里的线程设置断点。

set scheduler-locking on：调试一个线程时，让其他线程暂停（默认是off，即不暂停，除了on/off，还有step模式：用step命令调试线程时，其他线程不会执行，但是用其他命令（如next）调试线程时，其他线程也许会执行

add-inferior [ -copies n ] [ -exec executable ]：在gdb会话中调试另一个可执行文件，可同时调试多个可执行文件

### 为调试进程产生core dump文件

generate-core-file / gcore：为当前调试的进程产生core dump文件，default name is 'core.<process_id>'

$ gdb path/to/the/executable path/to/the/coredump：加载core dump文件

file <excutive file>：读取可执行文件的符号表信息

core <core file>：指定core dump文件位置

### 汇编

disassemble <func name>：显示函数的汇编指令

set disassembly-flavor intel：将汇编改为intel格式，gdb默认是AT&T，该命令只能用于intel x86处理器上

b *func：将断点设置在汇编指令层次函数的开头，如果仅用b func不会把断点设在汇编指令层次函数的开头

disassemble /m fun：将函数内所有代码与汇编指令映射起来

disassemble 0x4004e9, 0x40050c：只查看某条语句对应的汇编代码

> i line 13：Line 13 of "foo.c" starts at address 0x4004e9 <main+37> and ends at 0x40050c <main+72>.

display /ni $pc：当程序停止时，该指令可以显示将要执行的n行汇编指令

i registers：查看寄存器的值，不包含浮点寄存器与向量寄存器

i all-registers：查看所有寄存器的值

disassemble /r：用16进制显示程序的原始机器码

### 改变程序的执行

set main::p1="Jil"：更改字符串的值，一定要注意内存越界的问题

set {char [4] } 0x80477a4 = "Ace"：更改指定内存地址的字符串的值，更改字符串的值，一定要注意内存越界的问题

set var variable=expr：设置变量的值

set {type}address=expr：给存储地址在address、变量类型为type的变量赋值

set var $eax = 8：eax寄存器存储着函数的返回值，也可以通过这种方式修改函数的返回值

set var $pc=0x08050949：pc寄存器存储着接下来要执行的指令，可以通过这种方式更改程序的执行流程

> info line 7：Line 7 of "a.c" starts at address 0x8050949 <main+40> and ends at 0x805094e <main+45>.

jump [line_num]：调到第line_num行，该指令只改变pc的值，所以可能会出现不同的结果

command <break_num>（然后输入多行命令最后以end行结尾）：为断点break_num设置指令组合，当程序运行到断点处，会自动执行command 1的指令组合，然后继续执行

set write on：允许gdb修改二进制文件

set variable *(short*)0x400651=0x0ceb：修改二进制代码，注意大小端和指令长度

### 信号

info signals/handle：查看gdb如何处理进程收到的信号

handle SIGHUP nostop：设置当SIGHUP信号发生时，gdb不暂停程序，handle signal stop/nostop

handle SIGHUP noprint：设置当SIGHUP信号发生时，gdb不打印信号信息，handle signal print/noprint

handle SIGHUP nopass：设置当SIGHUP信号发生时，gdb不把信号丢给程序处理，handle signal pass(noignore)/nopass(ignore)

signal SIGHUP：gdb会直接将信号发送给程序处理，而且程序会继续运行

> 与在shell中使用kill发送信号给程序的区别是：kill发送信号，gdb会决定是否把信号发送给进程，而signal指令是直接发送信号

signal 0：程序重新运行，但不会收到SIGHUP信号

### 源文件

directory [path]：设置查找源文件的路径，有时gdb不能准确地定位到源文件的位置（比如文件被移走了，等等）

$gdb a.out -d /search/code/some：在gdb启动时指定搜索源文件的路径

set substitute-path [from] [to]：查看源代码时，用新的目录代替旧的目录

info source：显示当前源文件名

info sources：显示加载的symbols涉及的源文件

### 图形界面

$ gdb --tui / (gdb) (ctrl+X+A)：进入图形化调试界面

layout asm：进入图形化界面后，该命令显示汇编代码窗口

layout split：进入图形化洁面后，该命令同时显示源代码和汇编代码

layout regs：显示通用寄存器窗口

winheight <win_name> [+ | -] count：调整窗口大小，`winheight`缩写为`win`。`win_name`可以是`src`、`cmd`、`asm`和`regs。count是变化值`

Ctrl + L：刷新窗口

### 命令的缩写

```shell
b -> break
c -> continue
d -> delete
f -> frame
i -> info
j -> jump
l -> list
n -> next
p -> print
r -> run
s -> step
u -> until
```

```shell
aw -> awatch
bt -> backtrace
dir -> directory
disas -> disassemble
fin -> finish
ig -> ignore
ni -> nexti
rw -> rwatch
si -> stepi
tb -> tbreak
wa -> watch
win -> winheight
```

另外，如果直接按回车键，会重复执行上一次的命令。

## 原理

by <https://mp.weixin.qq.com/s/-6cM77W85IF-MuRvXGBTMQ>

### ptrace

- gdb 通过系统调用 ptrace 来接管一个进程的执行。ptrace 系统调用提供了一种方法使得父进程可以观察和控制其它进程的执行，检查和改变其核心映像以及寄存器。它主要用来实现断点调试和系统调用跟踪。

- ptrace系统调用定义如下：

```c++
# include <sys/ptrace.h>
long ptrace(enum __ptrace_request request, pid_t pid, void *addr, void *data)
```

- pid_t pid：指示 ptrace 要跟踪的进程
- void *addr：指示要监控的内存地址
- enum__ptrace_request request：决定了系统调用的功能，几个主要的选项：
  - PTRACE_TRACEME：表示此进程将被父进程跟踪，任何信号（除了 SIGKILL）都会暂停子进程，接着阻塞于 wait() 等待的父进程被唤醒。子进程内部对 exec() 的调用将发出 SIGTRAP 信号，这可以让父进程在子进程新程序开始运行之前就完全控制它
  - PTRACE_ATTACH：attach 到一个指定的进程，使其成为当前进程跟踪的子进程，而子进程的行为等同于它进行了一次 PTRACE_TRACEME 操作。但需要注意的是，虽然当前进程成为被跟踪进程的父进程，但是子进程使用 getppid() 的到的仍将是其原始父进程的pid
  - PTRACE_CONT：继续运行之前停止的子进程。可同时向子进程交付指定的信号

### 调试原理

运行并调试新进程，步骤如下：

- 运行gdb exe
- 输入run命令，gdb执行以下操作：
  - 通过fork()系统调用创建一个新进程
  - 在新创建的子进程中执行ptrace(PTRACE_TRACEME, 0, 0, 0)操作
  - 在子进程中通过execv()系统调用加载指定的可执行文件

gdb attach pid来调试一个运行的进程，gdb将对指定进程执行ptrace(PTRACE_ATTACH, pid, 0, 0)操作。

### 断点原理

- 实现原理：当被调试的程序运行到断点的时候，产生SIGTRAP信号。该信号被gdb捕获并 进行断点命中判断。
- 设置原理：在程序中设置断点，就是先在该位置保存原指令，然后在该位置写入int 3。当执行到int 3时，发生软中断，内核会向子进程发送SIGTRAP信号。当然，这个信号会转发给父进程。然后用保存的指令替换int 3并等待操作恢复。
- 命中判断：gdb将所有断点位置存储在一个链表中。命中判定将被调试程序的当前停止位置与链表中的断点位置进行比较，以查看断点产生的信号。

## 其他工具

### pstack

此命令可显示每个进程的栈跟踪，经常用来排查死锁问题，pstack $pid即可，pstack命令须由$pid进程的属主或者root运行

这个命令在排查进程问题时非常有用，比如我们发现一个服务一直处于work状态（如假死状态，好似死循环），使用这个命令就能轻松定位问题所在；可以在一段时间内，多执行几次pstack，若发现代码栈总是停在同一个位置，那个位置就需要重点关注，很可能就是出问题的地方；

### strace

strace常用来跟踪进程执行时的系统调用和所接收的信号。 在Linux世界，进程不能直接访问硬件设备，当进程需要访问硬件设备(比如读取磁盘文件，接收网络数据等等)时，必须由用户态模式切换至内核态模式，通过系统调用访问硬件设备。strace可以跟踪到一个进程产生的系统调用,包括参数，返回值，执行消耗的时间。

#### 操作系统层面分析

这里每一行都是一条系统调用，等号左边是系统调用的函数名及其参数，右边是该调用的返回值。 strace 显示这些调用的参数并返回符号形式的值。

```bash
strace cat /dev/null 
```

#### 跟踪可执行程序

-f -F选项告诉strace同时跟踪fork和vfork出来的进程，-o选项把所有strace输出写到~/straceout.txt里 面，myserver是要启动和调试的程序。

```bash
strace -f -F -o ~/straceout.txt myserver 
```

#### 跟踪服务程序

跟踪2313进程的所有系统调用(-e trace=all)，并统计系统调用的花费时间，以及开始时间(并以可视化的时分秒格式显示)，最后将记录结果存在output.txt文件里面。

```bash
strace -o output.txt -T -tt -e trace=all -p 2313 
```

### ldd

在我们编译过程中通常会提示编译失败，通过输出错误信息发现是找不到函数定义，再或者编译成功了，但是运行时候失败(往往是因为依赖了非正常版本的lib库导致)，这个时候，我们就可以通过ldd来分析该可执行文件依赖了哪些库以及这些库所在的路径。

```shell
ldd -r ./test_thread
 linux-vdso.so.1 =>  (0x00007ffde43bc000)
 libpthread.so.0 => /lib64/libpthread.so.0 (0x00007f8c5e310000)
 libstdc++.so.6 => /lib64/libstdc++.so.6 (0x00007f8c5e009000)
 libm.so.6 => /lib64/libm.so.6 (0x00007f8c5dd07000)
 libgcc_s.so.1 => /lib64/libgcc_s.so.1 (0x00007f8c5daf1000)
 libc.so.6 => /lib64/libc.so.6 (0x00007f8c5d724000)
 /lib64/ld-linux-x86-64.so.2 (0x00007f8c5e52c000)
```

在上述输出中：

- 第一列：程序需要依赖什么库
- 第二列：系统提供的与程序需要的库所对应的库
- 第三列：库加载的开始地址

如果提示某个库找不到，有两种方法

- 临时方法：LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to/libxx.so
- 永久方法：修改/etc/ld.so.conf，在该文件的后面加上需要的路径

```shell
include ld.so.conf.d/*.conf
/path/to/

#通过以下命令永久生效
/sbin/ldconfig
```

### c++filt

因为c++支持重载，也就引出了编译器的name mangling机制，对函数进行重命名。

我们通过strings命令查看test_thread中的函数信息(仅输出fun等相关)

```shell
strings test_thread | grep fun_
in fun_int n =
in fun_string s =
_GLOBAL__sub_I__Z7fun_inti
_Z10fun_stringRKSs
```

可以看到_Z10fun_stringRKSs这个函数，如果想知道这个函数定义的话，可以使用c++filt命令，如下：

```shell
 c++filt _Z10fun_stringRKSs
fun_string(std::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)
```

### AddressAsan

#### 基础检测场景

-  heap/stack/global out-of-bound
-  heap use-after-free
-  stack use-after-return

#### 使用

可以使用GCC & Clang编译，可能会与tcmalloc的一些特性冲突，需关闭

In order to use AddressSanitizer you will need to compile and link your program using clang with the -fsanitize=address switch. To get a reasonable performance add -O1 or higher. To get nicer stack traces in error messages add -fno-omit-frame-pointer

#### 示例

编写程序，并编译链接

```bash
% cat tests/use-after-free.c
#include <stdlib.h>
int main() {
  char *x = (char*)malloc(10 * sizeof(char*));
  free(x);
  return x[5];
}
% ../clang_build_Linux/Release+Asserts/bin/clang -fsanitize=address -O1 -fno-omit-frame-pointer -g   tests/use-after-free.c
```

运行二进制文件，asan会报告错误

```bash
% ./a.out
==9901==ERROR: AddressSanitizer: heap-use-after-free on address 0x60700000dfb5 at pc 0x45917b bp 0x7fff4490c700 sp 0x7fff4490c6f8
READ of size 1 at 0x60700000dfb5 thread T0
    #0 0x45917a in main use-after-free.c:5
    #1 0x7fce9f25e76c in __libc_start_main /build/buildd/eglibc-2.15/csu/libc-start.c:226
    #2 0x459074 in _start (a.out+0x459074)
0x60700000dfb5 is located 5 bytes inside of 80-byte region [0x60700000dfb0,0x60700000e000)
freed by thread T0 here:
    #0 0x4441ee in __interceptor_free projects/compiler-rt/lib/asan/asan_malloc_linux.cc:64
    #1 0x45914a in main use-after-free.c:4
    #2 0x7fce9f25e76c in __libc_start_main /build/buildd/eglibc-2.15/csu/libc-start.c:226
previously allocated by thread T0 here:
    #0 0x44436e in __interceptor_malloc projects/compiler-rt/lib/asan/asan_malloc_linux.cc:74
    #1 0x45913f in main use-after-free.c:3
    #2 0x7fce9f25e76c in __libc_start_main /build/buildd/eglibc-2.15/csu/libc-start.c:226
SUMMARY: AddressSanitizer: heap-use-after-free use-after-free.c:5 main
```

#### 原理

-  地址毒剂法：
    - 不可用的内存标记为被下毒的地址
    - 访问到被下毒的地址时报告内存错误

具体实现

-  将每8byte的应用地址空间映射到1个byte的shadow地址空间上，记录这个8byte是否被下毒(值为负数)

  ```shll
      +--------+
      |        |
      | Memory | --+
      |        |   |
      +--------+   |
  +-- | Shadow | <-+
  |   +--------+
  +-> | Bad    |
  |   +--------+
  +-- | Shadow | <-+
      +--------+   |
      |        |   |
      | Memory | --+
      |        |
      +--------+
  ```

-  每次地址操作前，先检查待操作的地址是否被下毒(对应的shadow为负数)

```c++
// Before
*addr = xxx; // or: xxx = *addr;

// After:
if (IsPoisoned(addr)) {
    ReportError(addr);
}
*addr = xxx; // or: xxx = *addr;
```

#### 错误检测

- malloc时，在内存前后额外申请一部分内存作为Redzone，这部分直接标记为被下毒(检测heap out-of-bound)

```shell
+-----+------+-----+------+-----+
| rz1 | mem1 | rz2 | mem2 | rz3 |
+-----+------+-----+------+-----+
```

- free时，将归还的内存全部标记为被下毒，置入隔离区（暂不归还给系统，检测heap use-ofter-free以及double free）

- 在栈上内存前后额外申请内存作为Redzone，标记为被下毒(检测stack/global out-of-bound以及stack use-after-return)

#### 性能影响

- Slowdown: 1.93x (1.12x ~ 3.79x, 内存分配 & 小内存访问 影响较大)
- Memory usage: 3.37x (1.4x ~ 19.84x)
- Stack increase: 大部分低于10% (1.02x ~ 3.06x)
- Binary size: 2.5x

#### 检测不到的场景 (检测假阴性 False Negatives)

- 部分越界的未对齐访问

  ```c++
  //                  buffer                 out-of-bound
  // [-------------------------------------] [xxxxxxx]
  // 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0xff 0xff
  // [-----------------]           [-----------------]
  //        int *a                        int *u
  int *a = new int[2];
  int *u = (int*)((char*)a + 6);
  *u = 1; // out-of-bound
  ```

- 恰巧落在其他buffer的访问

  ```c++
  char *a = new char[100];
  char *b = new char[500];
  a[500] = 0; // a out-of-bound, 恰巧落在b
  ```

- 大内存分配后的heap use-after-free

  ```c++
  char *a = new char[1 << 20]; // 申请1MB
  deleta [] a;                 // a置入隔离区
  char *b = new char[1 << 28]; // 申请256MB
  deleta [] b;                 // b置入隔离区，达到隔离区最大值，a从隔离区归还至系统
  char *c = new char[1 << 20]; // 1MB

  a[0] = 1;                    // a use-after-free, 恰巧落在c
  ```

> 与之对应的，asan具有的特性是：Zero false positives（检测出阳性就肯定是真实的阳性）