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

###### linux下文件的创建时间、访问时间、修改时间和改变时间：https://blog.csdn.net/zyz511919766/article/details/14452027

