# cache

[cache概览](http://tva1.sinaimg.cn/large/005GdKShly1gut5q1n2hnj60os0of41v02.jpg)

Cache是为了给CPU提供高速存储访问，利用数据局部性而设计的小存储单元。

[cache种类](http://tva1.sinaimg.cn/large/005GdKShly1gut5viizdlj60t40ak77y02.jpg)

整个系统的存储架构包括了 CPU 的寄存器，L1/L2/L3 CACHE，DRAM 和硬盘。数据访问时先找寄存器，寄存器里没有找 L1 Cache, L1 Cache 里没有找 L2 Cache 依次类推，最后找到硬盘中。容量越小，访问速度越快！
