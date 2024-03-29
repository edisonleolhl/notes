# Shell备忘录

shell是提供与内核沟通接口的命令解释器程序，但实际上shell是这种解释器的统称，Linux系统的shell种类很多，包括Bourne shell（简称sh）、Bourne Again shell（简称bash）、C shell（简称csh）、K shell（简称ksh）、Shell for Root等等。

sh和bash都是Linux系统shell的一种，其中bash命令是sh命令的超集，大多数sh脚本都可以在bash下运行。Linux系统中预设默认使用的就是bash。

## 基础

Linux提供的Shell解析器有：

```shell
[atguigu@hadoop101 ~]$ cat /etc/shells 
/bin/sh
/bin/bash
/sbin/nologin
/bin/dash
/bin/tcsh
/bin/csh
```

### 执行方式

shell脚本以`#!/bin/bash`开头（指定解析器）

```shell
# 创建脚本
[linux@localhost datas]$ cat helloworld.sh 
#!/bin/bash
echo "hello huangxb"

# 执行脚本方式1(显式调用bash解释器，sh会转而调用bash)
[linux@localhost datas]$ bash helloworld.sh 
hello huangxb
[linux@localhost datas]$ sh helloworld.sh 
hello huangxb

# 执行脚本方式2（隐式调用bash解释器，但需添加执行权限）
[linux@localhost datas]$ ./helloworld.sh
-bash: ./helloworld.sh: 权限不够
[linux@localhost datas]$ ll   
total 8
-rw-r--r--  1 apple  staff    31B  7  7 16:49 helloworld.sh
[linux@localhost datas]$ chmod 755 helloworld.sh # 改变为可执行
[linux@localhost datas]$ ll                     
total 8
-rwxr-xr-x  1 apple  staff    31B  7  7 16:49 helloworld.sh
[linux@localhost datas]$ ./helloworld.sh        
hello world
```

> python脚本以`#!/usr/bin/python`开头（指定python解析器）
> 执行python脚本只能显式调用python解释器：`[linux@localhost datas]$ python helloworld.py`

### screen后台管理

开启一个由screen管理的终端，此时出现一个新终端

```shell
[xxxxx]$ screen -S first
[xxxxx]$ do something
```

如果这个终端不小心关闭，这可以重新登录screen找到这个终端

```shell
[xxxxx]$ screen -list
There is a screen on:
        28025.first     (Detached)
1 Socket in /var/folders/bp/llgj_f3x2nq58g_1fqb8j0vr0000gn/T/.screen.
[xxxxx]$ screen -r 28025
# 又回到之前的终端信息
```

若想退出screen管理的这个这个终端，在该终端下键入`ctrl+d`即可

screen -S xxx -> 新建一个叫xxx的session

screen -ls -> 列出当前所有的session

screen -r xxx -> 回到xxx这个session

screen -d xxx -> 远程detach某个session

screen -R 　先试图恢复离线的作业。若找不到离线的作业，即建立新的screen作业。

screen -d -r xxx -> 结束当前session并回到xxx这个session

在每个screen session 下，所有命令都以 ctrl+a(C-a) 开始：

- `[` -> 进入 copy mode，在 copy mode 下可以回滚、搜索、复制就像用使用 vi 一样，ctrl+c退出该模式
- `n` -> Next，切换到下一个 window 
- `p` -> Previous，切换到前一个 window 

### tmux

> 摘自：https://pragmaticpineapple.com/gentle-guide-to-get-started-with-tmux/

ctrl+b：进入tmux命令模式，tmux的命令都要先加上ctrl+b

ctrl+b  +  ?：如果忘记了tmux命令，可以用该命令

#### pane management

ctrl+b  +  "：水平创建一个pane

ctrl+b  +  %：垂直创建一个pane

ctrl+b  +  LeftArrow/Right/Up/Down：在pane之间移动光标

ctrl+d：关闭pane

#### window management

ctrl+b  +  c：创建window

> 底部有各window的名称（默认是序号，从0开始）与该window正在运行的任务，带星号*的window是当前焦点所在window，带折号-的window是最后一个window

ctrl+b  +  0/1/2：前往第0/1/2号window

ctrl+b  +  p/n：前往previous window/前往next window

#### sessions

tmux ls：列出所有session

ctrl+b  +  d：退出tmux当前session

tmux new -s heythere：创建名为heythere的session

tmux  attach -t heythere：连接名为heythere的session

```shell
$ tmux ls
0: 4 windows (created Thu Aug 12 20:08:22 2021) (attached)
1: 1 windows (created Thu Aug 12 20:15:03 2021)


# The first session marked with 0 shows that we have four windows open, and we are attached to it. But the second session marked with 1 (one) is not attached
```

### wc

1. 命令格式：
wc [选项]文件...

2. 命令功能：
统计指定文件中的字节数、字数、行数，并将统计结果显示输出。该命令统计指定文件中的字节数、字数、行数。如果没有给出文件名，则从标准输入读取。wc同时也给出所指定文件的总统计数。

3. 命令参数：
-c 统计字节数。
-l 统计行数。
-m 统计字符数。这个标志不能与 -c 标志一起使用。
-w 统计字数。一个字被定义为由空白、跳格或换行字符分隔的字符串。
-L 打印最长行的长度。
--help 显示帮助信息
--version 显示版本信息

　　例子: 在文件a中统计 hello 出现的行数:
　　
grep hello a | wc -l
　　在文件a中统计hello出现的次数:

grep -o hello a | wc -l

### grep

```
grep xxx xxx.log     #文件查找
grep xxx xxx.log yyy.log #多文件查找
grep xxx /home/admin -r -n #目录下查找所有符合关键字的文件
grep xxx xxx.log -i  # 大小写不敏感搜索
grep xxx --include *.{vm,java} #指定文件后缀
grep xxx --exclude *.{vm,java} #反匹配
grep xxx xxx.log -C 3：打印匹配行，并打印上下各三行
```

日志文件很大，想从中grep某个字段耗时很久，这时可以用tac命令从后往前查：tac xxx.log | grep xxx

### cp

复制时自动创建不存在的子目录：http://www.dreamwu.com/post-1346.html

> cp: with --parents, the destination must be a directory

### du

du -h -d 1    展示当前目录所有文件及文件夹的大小，深度为1就是指当前目录

### tail

最常用的tail -f

```shell
tail -300f shopbase.log #倒数300行并进入实时监听文件写入模式
```

### find

```shell
find /home/admin -size +2500k # 搜索目录下超过2500k的文件，+号改-号就变成搜索小于2500k的文件
find /home/admin -atime -1  1天内访问过的文件
find /home/admin -ctime -1  1天内状态改变过的文件    
find /home/admin -mtime -1  1天内修改过的文件
find /home/admin -amin -1  1分钟内访问过的文件
find /home/admin -cmin -1  1分钟内状态改变过的文件    
find /home/admin -mmin -1  1分钟内修改过的文件
```

>  linux下文件的创建时间、访问时间、修改时间和改变时间：https://blog.csdn.net/zyz511919766/article/details/14452027

## 分析

### uptime 

- 最后三个数字是1、5、15分钟内的平均负载，可以通过这个变化趋势判断负载的变化
- 平均负载是指数衰减移动平均数
- 平均负载大于CPU数量，表示CPU不足以服务线程，有些线程在等待，一个有64颗CPU的系统的平均负载为128，这意味着平均每个CPU上有一个线程在运行，还有一个线程在等待

```shell
$uptime
17:25:02 up 304 days, 19:57,  1 user,  load average: 7.28, 7.34, 7.40
```

### vmstat

- 虚拟内存统计信息，第一行是系统启动启动以来的总结信息
  - swpd：交换出的内存量，单位KB，下同
  - free：空闲的可用内存
  - buff：用于缓冲缓存的内存
  - cache：用于页缓存的内存
  - **si：换入的内存（换页）**
  - **so：换出的内存（换页）**
  - r：运行队列长度——可运行线程总数
  - us：用户态时间
  - sy：系统态时间
  - id：空闲
  - wa：等待I/O，即线程被阻塞等待磁盘I/O的CPU空闲时间

- 如果si和so列一直非0，那么系统正存在内存压力，可以用其他工具研究什么在消耗内存
- vmstat参数-S可将输出设置为MB，这样会对齐方便阅读

```shell
$vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 7  0      0 46135660 1618864 58485956    0    0     5    62    0    0  6  0 93  0  0
 7  0      0 46135380 1618868 58485960    0    0     0   104 32964 49973 22  0 77  0  0
 7  0      0 46135420 1618868 58485960    0    0     0    12 32842 49997 22  0 77  0  0
 7  0      0 46135412 1618868 58485964    0    0     0     0 33431 50544 22  0 77  0  0
 7  0      0 46135436 1618868 58485968    0    0     0    16 33263 49721 22  0 77  0  0
```

### mpstat

- 多处理器统计信息，报告每个CPU的统计信息
  - CPU：逻辑CPU ID，或者ALL表示总结信息
  - **%usr：用户态时间**
  - %nice：以nice优先级运行的进程用户态时间
  - **%sys：系统态时间（内核）**
  - %iowait：I/O等待
  - %irq：硬件中断CPU用量
  - %soft：软件中断CPU用量
  - %quest：花在访客虚拟机的时间
  - **%idle：空闲**

- %usr+%sys达到100%，则说明跑满！

```shell
$mpstat -P ALL
05:35:23 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
05:35:23 PM  all    6.45    0.00    0.38    0.07    0.00    0.01    0.00    0.00    0.00   93.08
05:35:23 PM    0    7.95    0.00    0.80    1.03    0.00    0.29    0.00    0.00    0.00   89.94
05:35:23 PM    1    7.82    0.00    0.32    0.02    0.00    0.00    0.00    0.00    0.00   91.83
05:35:23 PM    2    6.69    0.00    0.51    0.27    0.00    0.00    0.00    0.00    0.00   92.53
05:35:23 PM    3    6.39    0.00    0.29    0.02    0.00    0.00    0.00    0.00    0.00   93.30
...
```

### sar

- 系统活动报告，system activity information



### ps

- 进程状态

- 源于BSD的风格

  - a：所有用户
  - u：扩展信息
  - x：没有终端的进程

- 源于SVR4

  - -e：所有进程
  - -f：完整信息

- TIME：进程自创建开始消耗的CPU总时间（用户态+系统态），小时:分钟:秒

- %MEM：主存使用（物理内存、RSS）占总内存的百分比

- RSS：常驻集合大小（KB）

  > 包括系统库在内的映射共享段，如果把所有RSS列求和，可能会超过系统的内存总和，这是因为重复计算了这部分共享内存

- VSZ：虚拟内存大小（KB）

```shell
$ps aux
$ps aux  | head
USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root          1  0.0  0.0 199236  5076 ?        Ss    2021  57:21 /usr/lib/systemd/systemd --switched-root --system --deserialize 21
root          2  0.0  0.0      0     0 ?        S     2021   0:14 [kthreadd]
root          3  0.0  0.0      0     0 ?        S     2021  11:11 [ksoftirqd/0]
root          5  0.0  0.0      0     0 ?        S<    2021   0:00 [kworker/0:0H]
root          7  0.1  0.0      0     0 ?        S     2021 502:21 [rcu_sched]
root          8  0.0  0.0      0     0 ?        S     2021   2:44 [rcu_bh]
root          9  0.0  0.0      0     0 ?        S     2021 116:51 [rcuos/0]
root         10  0.0  0.0      0     0 ?        S     2021   0:54 [rcuob/0]
root         11  0.0  0.0      0     0 ?        S     2021   0:26 [migration/0]
```

### top

- 最消耗CPU的任务，默认按照CPU用量排序

- TIME+：1:36.53代表在CPU上的时间总计为1分36.53秒

  ```shell
  $top
  top - 17:58:46 up 304 days, 20:31,  1 user,  load average: 7.45, 7.46, 7.53
  Tasks: 518 total,   8 running, 494 sleeping,   0 stopped,  16 zombie
  %Cpu(s): 22.3 us,  0.3 sy,  0.0 ni, 77.4 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
  KiB Mem : 13146870+total, 46123176 free, 25231976 used, 60113548 buff/cache
  KiB Swap:        0 total,        0 free,        0 used. 10480180+avail Mem
  
     PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
  ```

  > 注意top命令本身也是非常消耗CPU的！

### time

- 用来运行命令并报告CPU用量

  ```shell
  $time echo "hello"
  hello
  
  real	0m0.000s
  user	0m0.000s
  sys	0m0.000s
  ```

### perf

- 原名为Linux性能计数器，现在是Linux性能事件

### iostat

- 汇总单个磁盘的统计信息，通常是调查磁盘IO问题使用的第一个命令

- -c：显示CPU报告

- -d：显示磁盘报告

- -k/-m：以KB/MB显示

- -x：输出扩展信息

  ```shell
  $iostat
  [内核版本 主机名 日期 架构 CPU数量]
  
  avg-cpu:  %user   %nice %system %iowait  %steal   %idle
             6.49    0.00    0.39    0.07    0.00   93.04
  
  Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
  vda              18.83         7.56       258.81  199523373 6833818632
  vdb              15.41       159.75      1708.72 4218061185 45118703004
  ```

  

### netstat

- 网络统计书许
  - 默认：列出连接socket的信息
  - -a：列出所有socket的信息
  - -s：网络栈统计信息
  - -i：网络接口信息
  - -r：列出路由表
  - -n：不解析IP地址为主机名
  - -c：连续模式，每秒输出最新的统计信息到终端

```shell
# 网络接口、MTU、接收（RX-）、传输（TX-）指标
# OK成功传输包，ERR错误数据包，DRP丢包，OVR超限
$netstat -i
Kernel Interface table
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
docker0   1500        0      0      0 0             0      0      0      0 BMU
eth0      1500 1041533454      0      0 0      1046421328      0      0      0 BMRU
lo       65536 298561690      0      0 0      298561690      0      0      0 LRU
```

### ifconfig

- 即能手动设置网络接口，也可以列出所有网络接口的当前配置，数据与netstat -i一致
- ifconfig已经被ip命令淘汰

### ip

- 配置网络接口和路由，并且观测它们的状态和统计信息，数据与netstat -i一致

### lsof

- 按进程ID列出包括socket细节在内的打开文件

### ss

- socket统计信息

ddddddddd

dd

d



d

d

d

d

dd

d

d



d

d

d

d




## shell编程

### shell变量

- 定义变量时，变量名不加美元符号$
- 定义变量时，**变量名和等号之间不能有空格**
- 使用一个定义过的变量只要在变量名加上美元符号$即可
- shell变量分为局部变量（变量前面加local）和全局变量（变量前面不添加），局部变量的可见范围是代码块或函数内，全局变量则全局可见，和别的语言类似。

```shell
name=chenying
echo $name
echo ${name}
```

### shell字符串

- 字符串可以用单引号，也可以用双引号。
- 单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的，也不能出现单独一个的单引号（对单引号使用转义符后也不行），但可成对出现，作为字符串拼接使用。
- 双引号里可以有变量，双引号里可以出现转义字符。

```shell
name='Isabella'
str="Hello, I know you are \"$name\"! \n"
echo -e $str # echo -e 表示使用转义功能，如果不加-e，则不会输出换行符，会直接输出\n
# Hello, I know you are "Isabella"
```

#### 拼接字符串

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

#### 获取字符串长度

```shell
string="Isabella"
echo ${#string} #输出 8
```

#### 截取字符串

此栗子从字符串第 3 个字符开始截取 6 个字符：

```shell
string="abcdefghijklmn"
echo ${string:2:6} # 输出 cdefgh
```

### 数组

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

#### 获取数组长度

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

### 传递参数

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

### 使用expr表达式计算

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

### 流程控制

#### if-else条件分支

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

#### for循环

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

#### while循环

```shell
while condition
do
    command
done
```

#### until循环

until 循环执行一系列命令直至条件为 true 时停止，与 while 循环在处理方式上刚好相反。

```shell
until condition
do
    command
done
```

#### case

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

#### 跳出循环

在循环过程中，有时候需要在未达到循环结束条件时强制跳出循环，Shell使用两个命令来实现该功能：break和continue。

### shell函数

简化写法中function可以不写，语法格式

```shell
function name() {
    statements
    [return value]
}
```

### grep——擅长查找

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

### sed——擅长取行和替换

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

### awk——擅长取列

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

### 使用sh -x调试shell脚本

sh -x的作用：

- "-x"选项可用来跟踪脚本的执行，是调试shell脚本的强有力工具。
- “-x”选项使shell在执行脚本的过程中把它实际执行的每一个命令行显示出来，并且在行首显示一个"+"号。
- "+"号后面显示的是经过了变量替换之后的命令行的内容，有助于分析实际执行的是什么命令。

利用shell内置的环境变量调试：

- $LINENO：代表shell脚本的当前行号，类似于C语言中的内置宏__LINE__
- $FUNCNAME：函数的名字，类似于C语言中的内置宏__func__,但宏__func__ 只能代表当前所在的函数名，而$FUNCNAME的功能更强大，它是一个数组变量，其中包含了整个调用链上所有的函数的名字，故变量${FUNCNAME [0]}代表shell脚本当前正在执行的函数的名字，而变量${FUNCNAME[1]}则代表调用函数${FUNCNAME[0]}的函数的名字，余者可以依此类推。
- $PS4：主提示符变量$PS1和第二级提示符变量$PS2比较常见，而$PS4的值将被显示在“-x”选项输出的每一条命令的前面。在Bash Shell中，缺省的$PS4的值是"+"号。
- 利用$PS4这一特性，通过使用一些内置变量来重定义$PS4的值，我们就可以增强"-x"选项的输出信 息。例如先执行export PS4='+{$LINENO:${FUNCNAME[0]}} ', 然后再使用“-x”选项来执行脚本，就能在每一条实际执行的命令前面显示其行号以及所属的函数名。