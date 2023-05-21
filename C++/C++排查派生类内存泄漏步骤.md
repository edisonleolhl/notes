### 1、pmap命令找出最大块内存区域
pmap [pid]，找出最大块内存区域，一般即为堆内存区域，根据内存地址也可以知道这是64位机器，为 32 位进程地址是从 0 到 0xffffffff (4G)，两者的范围不同

```bash
pmap -x [pid]  # `-x`表示要显示扩展信息
```

![2023-05-11T175058](2023-05-11T175058.png)

### 2、gcore产生core文件

```bash
$gcore [pid]
```

### 3、获取内存空间

64bit下，一个指针占8字节，5666356*1024/8=725293568，此为这块内存区域的字节数

0x00000001249e1000是这块内存区域的起始地址

于是用gdb打印内存空间

```bash
$gdb [binfile] [corefile]

(gdb) set height 0
(gdb) set logging on
(gdb) x/725293568a 0x00000001249e1000
```

上述命令，会把内存中的内容，按照指针进行解读，保存在gdb.txt文件中。

等一会，此时gdb.txt
![2023-05-11T175127](2023-05-11T175127.png)


此时gdb.txt不太好看出来类名是什么，可以用c++filt命令转换一下

```bash
cat gdb.txt|c++filt > demo.txt 
```

### 4、统计输出内容

根据demo.txt第五列（即类名）进行统计排序

```bash
cat demo.txt | awk '{print $5}'|sort|uniq -c | sort -nr | head -10
```

![2023-05-11T175136](2023-05-11T175136.png)

此时大概率是metaq内存泄露

> 本文落笔于 2022-04-14

> 一篇好文：https://panzhongxian.cn/cn/2020/12/memory-leak-problem-1/