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
