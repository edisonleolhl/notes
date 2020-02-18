# Linux高性能服务器编程 by游双

## 第1章 TCP/IP协议族

学习网络协议，RFC是首选资料

TCP/IP协议族是一个四层协议系统，自底向上分别是数据链路层、网络层、传输层和应用层，上层协议使用下层协议使用的服务

四个层的简介blabla

封装：上层协议是如何使用下层协议提供的服务的呢？其实这是通过**封装（encapsulation**）实现的。应用程序数据在发送到物理网络上之前，将沿着协议栈**从上往下**依次传递。每层协议都将在上层数据的基础上加上自己的头部信息（有时还包括尾部信息），以实现该层的功能，这个过程就称为封装

TCP报文段封装过程

![20200217094611.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200217094611.png)

分用：当帧到达目的主机时，将沿着协议栈**自底向上**依次传递。各层协议依次处理帧中本层负责的头部数据，以获取所需的信息，并最终将处理后的帧交给目标应用程序。这个过程称为**分用（demultiplexing）**。分用是依靠头部信息中的类型字段实现的

## 第2章 IP协议详解

IP协议为上层协议提供无状态、无连接、不可靠的服务

IPv4头部固定部分20字节，IPv4地址为32位。IPv6固定部分为40字节，IPv6地址为128位

### IP分片

当IP数据报的长度超过帧的MTU时，它将被分片传输。分片可能发生在发送端，也可能发生在中转路由器上，而且可能在传输过程中被多次分片，但**只有在最终的目标机器上，这些分片才会被内核中的IP模块重新组装**。

IP头部中的如下三个字段给IP的分片和重组提供了足够的信息：数据报标识、标志和片偏移。一个IP数据报的每个分片都具有自己的IP头部，它们具有**相同的标识值**，但具有不同的**片偏移**。并且除了最后一个分片外，其他分片都将设置MF标志。此外，每个分片的IP头部的总长度字段将被设置为该分片的长度。

以太网帧的MTU是1500字节（可以通过ifconfig命令或者netstat命令查看），因此它携带的IP数据报的数据部分最多是1480字节（IP头部占用20字节）。考虑用IP数据报封装一个长度为1481字节的ICMP报文（包括8字节的ICMP头部，所以其数据部分长度为1473字节），则该数据报在使用以太网帧传输时必须被分片，第一个分片总长度为1500字节，第二个分片总长度为21字节，每个分片都包含自己的头部（20字节），且第一个分片设置了MF标志，而第二个分片没有设置MF标志，因为它已经是最后一个分片了。

### IP转发

前文提到，不是发送给本机的IP数据报将由数据报转发子模块来处理。路由器都能执行数据报的转发操作，而主机一般只发送和接收数据报。

数据转发子模块执行如下操作：

1. 检查数据报头部的TTL值。如果TTL值已经是0，则丢弃该数据报。
2. 如果有必要，则给源端发送一个ICMP重定向报文，以告诉它一个更合理的下一跳路由器。
3. 将TTL值减1。
4. 处理IP头部选项。
5. 如果有必要，则执行IP分片操作。

## 第3章 TCP协议详解

### TCP固定头部结构

16位源端口号    16位目的端口号
        32位序号
        32位确认号
一些字段        16位窗口大小
16位校验和      16位紧急指针（偏移量）

### TCP建立与关闭

### TCP有限状态机

很重要！

### 复位报文段

在某些特殊条件下，TCP连接的一端会向另一端发送携带RST标志的报文段，即复位报文段，以通知对方关闭连接或重新建立连接

- 访问不存在的端口
- 异常终止连接（用SO_LINGER发送RST）
- 处理半打开连接（一端发送FIN后重启，再接收会发送RST）

### 带外数据

带外数据比普通数据（也称为带内数据）有更高的优先级，它应该总是立即被发送，而不论发送缓冲区中是否有排队等待发送的普通数据。

UDP没有实现带外数据传输，TCP也没有真正的带外数据。不过TCP利用其头部中的**紧急指针标志（URG）和紧急指针**两个字段，给应用程序提供了一种紧急方式。

假设进程已经向缓冲区写入一些普通数据，在发送前又加入了几个字节的带外数据，这时会把**待发送的第一个TCP报文段的头部置为URG标志**，并且紧急指针指向最后一个带外数据的下一个字节。

### TCP超时重传

### 拥塞控制

- 四个机制

  - 慢启动（ssthresh）

  - 拥塞避免

  - 快重传（发送端连续收到三个重复的ACK就认为拥塞发生并重传） 

  - 快恢复（不用慢启动，而是从减半后的ssthresh开始直接进入拥塞避免）

拥塞控制的最终受控变量是**发送窗口（swnd）**

- 接收方可通过其**接收通告窗口（rwdn）**来控制发送窗口

  - 还引入了**拥塞窗口（cwnd）**作为状态变量

  - 这三个窗口关系满足：swnd = min ( rwdn, cwnd )

## 第4章 实例

## 第5章 Linux网络编程基础API

很多API若出错则返回-1，并设置errno

### socket地址API

#### 主机字节序与网络字节序

字节序分为：

- 大端字节序（将高序字节存储在起始地址）：网络字节序都是大端的

- 小端字节序（将低序字节存储在起始地址）：大部分PC

本机用大端还是小端可以用union判断

Linux提供四个函数完成主机字节序与网络字节序的转换

- htonl: host to network long
- htons
- ntohl
- ntohs

#### 通用socket地址

结构体sockaddr

更大的通用结构体sockaddr_storage（内存对齐）

#### 专用socket地址

unix本地域协议族使用sockaddr_un

IPv4协议族使用sockaddr_in

IPv6协议族使用sockaddr_in6

#### IP地址转换函数

通常人们习惯点分十进制表示IPv4地址，十六进制表示IPv6地址，但是编程要用整数（二进制）

点分十进制表示的IPv4地址 和 网络字节序整数表示的IPv4地址 的转换如下

- inet_addr
- inet_aton
- inet_ntoa

更新的函数如下

- inet_pton: presentation（点分十进制or十六进制） to numeric（网络字节序的整数表示）
- inet_ntop

### 创建socket

UNIX/Linux的一个哲学是：**所有东西都是文件**。socket也不例外，它就是可读、可写、可控制、可关闭的文件描述符。下面的socket系统调用可创建一个socket：

```c++
int socket(int domain,int type,int protocol);
```

- domain：底层协议族，如IPv4、IPv6、Unix
- type：服务类型，SOCK_STREAM(流服务)、SOCK_DGRAM(数据报服务)，如果TCP/IP协议族，这两个指的是TCP与UDP
- protocol：具体协议，因为前两个参数已经完全确定，所以该值一般设为0，表示默认

### bind

创建socket时，我们给它指定了地址族，但是并未指定使用该地址族中的哪个具体socket地址。将一个socket与socket地址绑定称为给socket命名。

在服务器程序中，我们通常要命名socket，因为只有命名后客户端才能知道该如何连接它。

客户端则通常不需要命名socket，而是采用匿名方式，即使用操作系统自动分配的socket地址

```c++
int bind(int sockfd,const struct sockaddr*my_addr,socklen_t addrlen);
```

bind有可能会返回错误，常见的两种是

- EACCESS：被绑定的地址是受保护的地址，如绑定到知名服务端口（0~1023)时，会返回EACCESS
- EADDRINUSE：被绑定的地址正在使用

### listen

socket被命名之后，还不能马上接受客户连接，我们需要使用如下系统调用来创建一个监听队列以存放待处理的客户连接：

```c++
int listen(int sockfd,int backlog);
```

sockfd参数指定被监听的socket。backlog参数提示**内核监听队列的最大长度**。监听队列的长度如果超过backlog，服务器将不受理新的客户连接，客户端也将收到ECONNREFUSED错误信息。backlog参数的典型值是5。

### accept

下面的系统调用从listen监听队列中接受一个连接：

```c++
int accept(int sockfd,struct sockaddr*addr,socklen_t*addrlen);
```

sockfd参数是执行过listen系统调用的监听socket。addr参数用来获取被接受连接的远端socket地址，该socket地址的长度由addrlen参数指出。

> 我们把执行过listen调用、处于LISTEN状态的socket称为监听socket，而所有处于ESTABLISHED状态的socket则称为连接socket

accept成功时返回一个新的连接socket，该socket唯一地标识了被接受的这个连接，服务器可通过读写该socket来与被接受连接对应的客户端通信。

**accept只是从监听队列中取出连接，而不论连接处于何种状态（如ESTABLISHED状态和CLOSE_WAIT状态），更不关心任何网络状况的变化**。

### connect

如果说服务器通过listen调用来被动接受连接，那么客户端需要通过如下系统调用来主动与服务器建立连接：

```c++
int connect(int sockfd,const struct sockaddr*serv_addr,socklen_t addrlen);
```

sockfd参数由socket系统调用返回一个socket。serv_addr参数是服务器监听的socket地址，addrlen参数则指定这个地址的长度。

connect成功时返回0。一旦成功建立连接，sockfd就唯一地标识了这个连接，客户端就可以通过读写sockfd来与服务器通信。

connect失败则返回-1并设置errno，常见的两种是

- ECONNREFUSED：目标端口不存在，被拒绝
- ETIMEOUT：连接超时（可能服务器繁忙）

### close与shutdown

关闭一个连接实际上就是关闭该连接对应的socket，这可以通过如下关闭普通文件描述符的系统调用来完成：

```c++
int close(int fd);
```

fd参数是待关闭的socket。不过，close系统调用并非总是立即关闭一个连接，而是将fd的**引用计数**减1。只有当fd的引用计数为0时，才真正关闭连接。多进程程序中，一次fork系统调用默认将使父进程中打开的socket的引用计数加1，因此我们必须在父进程和子进程中都对该socket执行close调用才能将连接关闭
。
如果无论如何都要立即终止连接（而不是将socket的引用计数减1），可以使用如下的**shutdown**系统调用（相对于close来说，它是专门为网络编程设计的）：

```c++
int shutdown(int sockfd,int howto);
```

sockfd参数是待关闭的socket。howto参数决定了shutdown的行为

- SHUT_RD：关闭本机对于该套接字描述符的读，接收缓冲区的数据都被丢弃
- SHUT_WR：关闭本机对于该套接字描述符的写，发送缓冲区的数据会在真正关闭前发送出去。此时处于**半关闭状态（half-close）**
- SHUT_RDWR：同时关闭本机对于该套接字描述符的读和写

### 数据读写

#### TCP数据读写

对文件的读写操作read和write同样适用于socket。但是socket编程接口提供了几个专门用于socket数据读写的系统调用，它们增加了对数据读写的控制。其中用于TCP流数据读写的系统调用是：

```c++
ssize_t recv(int sockfd,void*buf,size_t len,int flags);
ssize_t send(int sockfd,const void*buf,size_t len,int flags);
```

recv读取sockfd上的数据，buf和len参数分别指定读缓冲区的位置和大小，flags参数通常设置为0即可（有需要的话也可以选择一个或几个的逻辑或）。**recv成功时返回实际读取到的数据的长度**，它可能小于我们期望的长度len。因此我们可能要多次调用recv，才能读取到完整的数据。**recv可能返回0，这意味着通信对方已经关闭连接了**。recv出错时返回-1并设置errno。

send往sockfd上写入数据，buf和len参数分别指定写缓冲区的位置和大小。**send成功时返回实际写入的数据的长度**，失败则返回-1并设置errno。

#### UDP数据读写

socket编程接口中用于UDP数据报读写的系统调用是：

```c++
ssize_t recvfrom(int sockfd,void*buf,size_t len,int flags,struct sockaddr*src_addr,socklen_t*addrlen);
ssize_t sendto(int sockfd,const void*buf,size_t len,int flags,const struct sockaddr*dest_addr,socklen_t addrlen);
```

recvfrom读取sockfd上的数据，buf和len参数分别指定读缓冲区的位置和大小。因为**UDP通信没有连接的概念，所以我们每次读取数据都需要获取发送端的socket地址**，即参数src_addr所指的内容，addrlen参数则指定该地址的长度。

sendto往sockfd上写入数据，buf和len参数分别指定写缓冲区的位置和大小。**dest_addr参数指定接收端的socket地址**，addrlen参数则指定该地址的长度。

这两个系统调用的flags参数以及返回值的含义均与send/recv系统调用的flags参数及返回值相同。

#### 通用数据读写函数

socket编程接口还提供了一对通用的数据读写系统调用。它们不仅能用于TCP流数据，也能用于UDP数据报：

```c++
ssize_t recvmsg(int sockfd,struct msghdr*msg,int flags);
ssize_t sendmsg(int sockfd,struct msghdr*msg,int flags);
```

sockfd参数指定被操作的目标socket。msg参数是msghdr结构体类型的指针

### 地址信息函数

我们想知道一个连接socket的本端socket地址，以及远端的socket地址。下面这两个函数正是用于解决这个问题：

```c++
int getsockname(int sockfd,struct sockaddr*address,socklen_t*address_len);
int getpeername(int sockfd,struct sockaddr*address,socklen_t*address_len);
```

getsockname获取sockfd对应的本端socket地址，并将其存储于address参数指定的内存中，该socket地址的长度则存储于address_len参数指向的变量中。如果实际socket地址的长度大于address所指内存区的大小，那么该socket地址将被截断。getsockname成功时返回0，失败返回-1并设置errno。

getpeername获取sockfd对应的远端socket地址，其参数及返回值的含义与getsockname的参数及返回值相同。

### socket选项

如果说fcntl系统调用是控制文件描述符属性的通用POSIX方法，那么下面两个系统调用则是专门用来读取和设置socket文件描述符属性的方法，成功返回0，失败返回-1并设置errno

```c++
int getsockopt(int sockfd,int level,int option_name,void*option_value,socklen_t*restrict option_len);
int setsockopt(int sockfd,int level,int option_name,const void*option_value,socklen_t option_len);
```

sockfd参数指定被操作的目标socket。level参数指定要操作哪个协议的选项（即属性），比如IPv4、IPv6、TCP等。option_name参数则指定选项的名字。我们在表5-5中列举了socket通信中几个比较常用的socket选项。option_value和option_len参数分别是被操作选项的值和长度。不同的选项具有不同类型的值，如表5-5中“数据类型”一列所示。!

[20200217132232.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200217132232.png)

对服务器而言，有部分socket选项只能在调用listen系统调用前针对监听socket设置才有效，**对监听socket设置这些选项，accept返回的连接socket将会自动继承这些选项**

#### SO_REUSEADDR选项

经过setsockopt的设置之后，即使sock处于TIME_WAIT状态，与之绑定的socket地址也可以立即被重用。进而允许应用程序立即重用本地的socket地址。

参考一个面试题：time_wait太多怎么办

1. 开启tcp_timestamps：在TCP可选选项(option)字段内记录最后一次发送时间和最后一次接收时间（这是time_wait重用和快速回收的保证），`net.ipv4.tcp_timestamps = 1`
2. 开启time_wait重用：因为time_wait是主动关闭方的状态，当发送方又有新的TCP连接想要发起时，可以直接**重用正在time_wait状态的TCP连接**，接收端收到数据报，可以**通过timestamp字段判断属于复用前的连接还是复用后的连接**，`net.ipv4.tcp_tw_reuse = 1`
3. 开启time_wait快速回收：不再等待2MSL，而是RTO（远小于2MSL），`net.ipv4.tcp_tw_recycle = 1`

简单来说，就是打开系统的**time_wait重用和快速回收**。

#### SO_RCVBUF和SO_SNDBUF选项

SO_RCVBUF和SO_SNDBUF选项分别表示TCP接收缓冲区和发送缓冲区的大小

系统会确保不得小于某个值，主要是为了一个TCP连接**拥有足够的空闲缓冲区来处理拥塞**

#### SO_RCVLOWAT和SO_SNDLOWAT选项

SO_RCVLOWAT和SO_SNDLOWAT选项分别表示TCP接收缓冲区和发送缓冲区的**低水位标记**。它们一般**被I/O复用系统调用（见第9章）用来判断socket是否可读或可写**。当TCP接收缓冲区中可读数据的总数大于其低水位标记时，I/O复用系统调用将通知应用程序可以从对应的socket上读取数据；当TCP发送缓冲区中的空闲空间（可以写入数据的空间）大于其低水位标记时，I/O复用系统调用将通知应用程序可以往对应的socke上写入数据。

默认情况下，TCP接收缓冲区的低水位标记和TCP发送缓冲区的低水位标记均为**1字节**。

#### SO_LINGER选项

SO_LINGER选项用于控制close系统调用在关闭TCP连接时的行为。默认情况下，当我们使用close系统调用来关闭一个socket时，close将立即返回，TCP模块负责把该socket对应的TCP发送缓冲区中残留的数据发送给对方。

```c++
struct linger{
    int l_onoff; // 非0表示开启
    int l_linger; // 滞留时间
}
```

根据linger结构体中两个成员变量的不同值，close系统调用可能产生如下3种行为之一：

- l_onoff等于0。此时SO_LINGER选项不起作用，close用默认行为来关闭socket。

- l_onoff不为0，l_linger等于0。此时close系统调用立即返回，TCP模块将丢弃被关闭的socket对应的TCP发送缓冲区中残留的数据，同时给对方发送一个RST。因此，这种情况给服务器提供了异常终止一个连接的方法。

- l_onoff不为0，l_linger大于0。此时close的行为取决于两个条件：一是被关闭的socket对应的TCP发送缓冲区中是否还有残留的数据；二是该socket是阻塞的，还是非阻塞的。

  - 对于阻塞的socket，close将等待一段长为l_linger的时间，直到TCP模块发送完所有残留数据并得到对方的确认。如果这段时间内TCP模块没有发送完残留数据并得到对方的确认，那么close系统调用将返回-1并设置errno为EWOULDBLOCK。

  - 如果socket是非阻塞的，close将立即返回，此时我们需要根据其返回值和errno来判断残留数据是否已经发送完毕。

### 网络信息API

socket地址的两个要素，即IP地址和端口号，都是用数值表示的。这不便于记忆，也不便于扩展（比如从IPv4转移到IPv6）。因此在前面的章节中，我们用主机名来访问一台机器，而避免直接使用其IP地址。同样，我们用服务名称来代替端口号。

#### gethostbyname和gethostbyaddr

gethostbyname函数根据主机名称获取主机的完整信息，gethostbyaddr函数根据IP地址获取主机的完整信息。gethostbyname函数通常先在本地的/etc/hosts配置文件中查找主机，如果没有找到，再去访问DNS服务器

```c++
struct hostent*gethostbyname(const char*name);
struct hostent*gethostbyaddr(const void*addr,size_t len,int type);
```

name参数指定目标主机的主机名，addr参数指定目标主机的IP地址，len参数指定addr所指IP地址的长度，type参数指定addr所指IP地址的类型，其合法取值包括AF_INET（用于IPv4地址）和AF_INET6（用于IPv6地址）。这两个函数返回的都是hostent结构体类型的指针。

####　getservbyname和getservbyport

getservbyname函数根据名称获取某个服务的完整信息，getservbyport函数根据端口号获取某个服务的完整信息。它们实际上都是通过读取/etc/services文件来获取服务的信息的。这两个函数的定义如下：

```c++
struct servent*getservbyname(const char*name,const char*proto);
struct servent*getservbyport(int port,const char*proto);
```

name参数指定目标服务的名字，port参数指定目标服务对应的端口号。proto参数指定服务类型，给它传递“tcp”表示获取流服务，给它传递“udp”表示获取数据报服务，给它传递NULL则表示获取所有类型的服务。这两个函数返回的都是servent结构体类型的指针。

#### getaddrinfo

getaddrinfo函数既能通过主机名获得IP地址（内部使用的是gethostbyname函数），也能通过服务名获得端口号（内部使用的是getservbyname函数）

#### getnameinfo

getnameinfo函数能通过socket地址同时获得以字符串表示的主机名（内部使用的是gethostbyaddr函数）和服务名（内部使用的是getservbyport函数）

## 第6章 高级I/O函数

Linux提供了一些高级函数，虽不那么常用但提供了优异性能

### pipe函数

pipe创建一个管道以实现进程间通信

```c++
int pipe(int fd[2]);
```

pipe函数的参数是一个包含两个int型整数的数组指针。该函数成功时返回0，并将一对打开的文件描述符值填入其参数指向的数组。如果失败，则返回-1并设置errno。

通过pipe函数创建的这两个文件描述符fd[0]和fd[1]分别构成管道的两端，往**fd[1]写入**的数据可以从**fd[0]读出**。并且，fd[0]只能用于从管道读出数据，fd[1]则只能用于往管道写入数据，而不能反过来使用。如果要实现双向的数据传输，就应该使用两个管道。默认情况下，这一对文件描述符都是**阻塞**的。

如果管道的写端文件描述符fd[1]的**引用计数**减少至0，即没有任何进程需要往管道中写入数据，则针对该管道的读端文件描述符fd[0]的read操作将返回0，即读取到了文件结束标记（End Of File，EOF）；反之，如果管道的读端文件描述符fd[0]的**引用计数**减少至0，即没有任何进程需要从管道读取数据，则针对该管道的写端文件描述符fd[1]的write操作将失败，并引发**SIGPIPE**信号

socket的基础API提供的socketpair函数可以创建双向管道，这对描述符即可以读也可以写

```c++
int socketpair(int domain, int type, int protocol, int fd[2]);
```

### dup函数与dup2函数

有时我们希望把标准输入重定向到一个文件，或者把标准输出重定向到一个网络连接。这可以通过下面的用于复制文件描述符的dup或dup2函数来实现：

```c++
int dup(int file_descriptor);
int dup2(int file_descriptor_one,int file_descriptor_two);
```

dup函数创建一个新的文件描述符，该新文件描述符和原有文件描述符file_descriptor指向相同的文件、管道或者网络连接。并且dup返回的文件描述符总是取系统当前可用的最小整数值。dup2和dup类似，不过它将返回第一个不小于file_descriptor_two的整数值。dup和dup2系统调用失败时返回-1并设置errno。

注意：通过dup和dup2创建的文件描述符并**不继承原文件描述符的属性**，比如close-on-exec和non-blocking等。

### readv函数与writev函数（分散读集中写）

readv函数将数据从文件描述符读到分散的内存块中，即分散读；writev函数则将多块分散的内存数据一并写入文件描述符中，即集中写。

因为使用read()将数据读到不连续的内存、使用write()将不连续的内存发送出去，要经过**多次系统调用**。而readv、writev只需**一次系统调用**就可以实现在文件和进程的多个缓冲区之间传送数据，免除了多次系统调用或复制数据的开销

它们的定义如下：

```c++
ssize_t readv(int fd,const struct iovec*vector,int count)；
ssize_t writev(int fd,const struct iovec*vector,int count);
```

fd参数是被操作的目标文件描述符。vector参数的类型是iovec结构数组，该结构体描述一块内存区。count参数是vector数组的长度，即有多少块内存数据需要从fd读出或写到fd。readv和writev在成功时返回读出/写入fd的字节数，失败则返回-1并设置errno。它们相当于简化版的recvmsg和sendmsg函数。

### sendfile函数（零拷贝）

sendfile函数在两个文件描述符之间直接传递数据（**完全在内核中操作**），从而避免了内核缓冲区和用户缓冲区之间的数据拷贝，效率很高，这被称为零拷贝。sendfile函数的定义如下：

```c++
ssize_t sendfile(int out_fd,int in_fd,off_t*offset,size_t count);
```

in_fd参数是待读出内容的文件描述符，out_fd参数是待写入内容的文件描述符。offset参数指定从读入文件流的哪个位置开始读，如果为空，则使用读入文件流默认的起始位置。count参数指定在文件描述符in_fd和out_fd之间传输的字节数。sendfile成功时返回传输的字节数，失败则返回-1并设置errno。

该函数的man手册明确指出，in_fd必须是一个支持类似mmap函数的文件描述符，即它**必须指向真实的文件**，不能是socket和管道；而**out_fd则必须是一个socket**。由此可见，sendfile几乎是专门为在网络上传输文件而设计的

### mmap函数与munmap函数

**mmap函数用于申请一段内存空间**。我们可以将这段内存作为进程间通信的**共享内存**，也可以将文件直接映射到其中。**munmap函数则释放由mmap创建的这段内存空间**。它们的定义如下：

```c++
void* mmap(void*start,size_t length,int prot,int flags,int fd,off_t offset);
int munmap(void*start,size_t length);
```

start参数允许用户使用某个特定的地址作为这段内存的起始地址。如果它被设置成NULL，则系统自动分配一个地址。length参数指定内存段的长度。prot参数用来设置内存段的访问权限。它可以取以下几个值的按位或：

- PROT_READ，内存段可读。
- PROT_WRITE，内存段可写。
- PROT_EXEC，内存段可执行。
- PROT_NONE，内存段不能被访问。

flags参数控制内存段内容被修改后程序的行为，可被设置为下标中某些值的按位或（其中shared与private互斥，不能同时指定）：

- MAP_SHARED：进程间共享这段内存，对该内存段的修改将反映到被映射的文件上
- MAP_PRIVATE：内存段为调用进程私有，对该内存段的修改不会反映到被映射的文件上
- MAP_ANONYMOUS：内存段不是从文件映射而来，其内容初始化为0，mmap函数后面两个参数将被忽略
- MAP_FIXED：内存段必须位于start参数的指定的地址处，start必须是内存页面大小（4096字节）的整数倍
- MAP_HUGETLB：按照“大内存页面”来分配内存

**fd参数是被映射文件对应的文件描述符。它一般通过open系统调用获得。**

offset参数设置从文件的何处开始映射（对于不需要读入整个文件的情况）。
mmap函数成功时返回指向目标内存区域的指针，失败则返回MAP_FAILED（(void*)-1）并设置errno。munmap函数成功时返回0，失败则返回-1并设置errno。

### splice函数（零拷贝）

**splice函数用于在两个文件描述符之间移动数据**，也是零拷贝操作。splice函数的定义如下：

```c++
ssize_t splice(int fd_in,loff_t*off_in,int fd_out,loff_t*off_out,size_t len,unsigned int flags);
```

splice函数调用成功时返回移动字节的数量。它可能返回0，表示没有数据需要移动，这发生在从管道中读取数据（fd_in是管道文件描述符）而该管道没有被写入任何数据时。splice函数失败时返回-1并设置errno

### tee函数（零拷贝）

**tee函数在两个管道文件描述符之间复制数据**，也是零拷贝操作。它**不消耗数据**，因此源文件描述符上的数据仍然可以用于后续的读操作。tee函数的原型如下：

```c++
ssize_t tee(int fd_in,int fd_out,size_t len,unsigned int flags);
```

fd_in和fd_out必须都是管道文件描述符。tee函数成功时返回在两个文件描述符之间复制的数据数量（字节数）。返回0表示没有复制任何数据。tee失败时返回-1并设置errno。

### fcntl函数（file control）

fcntl函数，正如其名字（file control）描述的那样，提供了对文件描述符的各种控制操作。另外一个常见的控制文件描述符属性和行为的系统调用是ioctl，而且ioctl比fcntl能够执行更多的控制。但是，对于控制文件描述符常用的属性和行为，fcntl函数是由POSIX规范指定的首选方法。所以本书仅讨论fcntl函数。fcntl函数的定义如下：

```c++
int fcntl(int fd,int cmd,…);
```

fd参数是被操作的文件描述符，cmd参数指定执行何种类型的操作。根据操作类型的不同，该函数可能还需要第三个可选参数arg。fcntl函数支持的常用操作及其参数如表6-4所示。

fcntl最常用的用法是把文件描述符设置为**非阻塞**的

```c++
int setnonblocking(int fd)
{
    int old_option=fcntl(fd,F_GETFL);/*获取文件描述符旧的状态标志*/
    int new_option=old_option|O_NONBLOCK;/*设置非阻塞标志*/
    fcntl(fd,F_SETFL,new_option);
    return old_option;/*返回文件描述符旧的状态标志，以便*/
    /*日后恢复该状态标志*/
}
```

## Linux服务器程序规范

### 日志

Linux提供一个守护进程syslogd来处理系统日志，不过现在Linux系统上使用的都是它的升级版rsyslogd。

rsyslogd接收用户调用syslog函数生成的系统日志

### 用户信息

大部分服务器必须以root身份启动，但不能以root身份运行

总共8个get&set函数用来获取和设置用户的**真实ID（UID）、有效用户ID（EUID）、真实组ID（GID）、有效组ID（EGID）**

一个进程拥有两个用户ID：UID和EUID。EUID存在的目的是方便资源访问：**它使得运行程序的用户拥有该程序的有效用户的权限**。比如su程序，任何用户都可以使用它来修改自己的账户信息，但修改账户时su程序不得不访问/etc/passwd文件，而访问该文件是需要root权限的。那么以普通用户身份启动的su程序如何能访问/etc/passwd文件呢？窍门就在EUID。用ls命令可以查看到，su程序的所有者是root，并且它被设置了set-user-id标志。这个标志表示，任何普通用户运行su程序时，其有效用户就是该程序的所有者root。那么，根据有效用户的含义，任何运行su程序的普通用户都能够访问/etc/passwd文件。有效用户为root的进程称为**特权进程（privileged processes）**。EGID的含义与EUID类似：给运行目标程序的组用户提供有效组的权限。

通过setgid函数可以将以root身份启动的进程切换成以普通用户身份运行

### 进程间关系

#### 进程组

Linux下每个进程都隶属于一个进程组，因此它们除了PID信息外，还有**进程组ID（PGID）**。我们可以用以下函数来获取指定进程的PGID

```c++
pid_t getpgid(pid_t);
```

该函数成功时返回进程pid所属进程组的PGID，失败则返回-1并设置errno。

每个进程组都有一个首领进程，**首领进程的PGID和PID相同**。进程组将一直存在，直到其中所有进程都退出，或者加入到其他进程组。

下面的函数用于设置PGID：

```c++
int setpgid(pid_t pid,pid_t pgid);
```

该函数将PID为pid的进程的PGID设置为pgid。如果pid和pgid相同，则由pid指定的进程将被设置为进程组首领；如果pid为0，则表示设置当前进程的PGID为pgid；如果pgid为0，则使用pid作为目标PGID。setpgid函数成功时返回0，失败则返回-1并设置errno。

一个进程只能设置自己或子进程的PGID，当子进程调用exec系列函数后，父进程不能再设置子进程的PGID

#### 会话

一些有关联的进程组将形成一个会话，sid即为会话id，同样提供setsid与getsid函数

#### 用ps命令查看进程关系

### 系统资源限制

### 改变工作目录和根目录

下面两个函数用于获取当前工作目录和改变当前工作目录

```c++
char* getcwd(char* buf, size_t size);
int chdir(const char* path);
```

改变进程根目录的函数是chroot

```c++
int chroot(const char* path);
```

**chroot并不改变进程的当前工作目录**，所以调用chroot之后，我们仍然需要使用chdir(“/”)来将工作目录切换至新的根目录。改变进程的根目录之后，**程序可能无法访问类似/dev的文件（和目录）**，因为这些文件（和目录）并非处于新的根目录之下。不过好在调用chroot之后，进程原先打开的文件描述符依然生效，所以我们可以利用这些早先打开的文件描述符来访问调用chroot之后不能直接访问的文件（和目录），尤其是一些日志文件。此外，只有特权进程才能改变根目录。

### 服务器程序后台化

Linux提供库函数deamon将一个程序以守护进程方式运行

```c++
int daemon(int nochdir, int noclose);
```

## 第8章 高性能服务器程序框架（重点）

按照服务器程序的一般原理，将服务器解构为如下三个主要模块：

- I/O处理单元。本章将介绍I/O处理单元的四种I/O模型和两种高效事件处理模式。
- 逻辑单元。本章将介绍逻辑单元的两种高效并发模式，以及高效的逻辑处理方式——有限状态机。
- 存储单元。本书不讨论存储单元，因为它只是服务器程序的可选模块，而且其内容与网络编程本身无关。

### 服务器模型

#### C/S模型

Client/Server

C/S模型非常适合资源相对集中的场合，并且它的实现也很简单，但其缺点也很明显：服务器是通信的中心，**当访问量过大时，可能所有客户都将得到很慢的响应**。下面讨论的P2P模型解决了这个问题。

#### P2P模型

P2P（Peer to Peer，点对点）模型比C/S模型更符合网络通信的实际情况。它摒弃了以服务器为中心的格局，让网络上所有主机重新回归对等的地位。

P2P模型使得每台机器在消耗服务的同时也给别人提供服务，这样资源能够充分、自由地共享。云计算机群可以看作P2P模型的一个典范。但P2P模型的缺点也很明显：当**用户之间传输的请求过多时，网络的负载将加重**。而且还需要一个专门的发现服务器。

### 服务器编程框架

- 单台服务器：

    I/O处理单元  --请求队列--  逻辑单元  --请求队列--  网络存储单元（可选）

- 服务器集群：

    接入服务器（负载均衡）  --TCP连接--  逻辑服务器  --TCP连接--  数据库服务器

### I/O模型

阻塞和非阻塞的概念适用于所有文件描述符

可能被阻塞的系统调用包括send（write）、recv（read）、accept、connect

针对非阻塞I/O执行的系统调用则**总是立即返回**，而不管事件是否已经发生。如果事件没有立即发生，这些系统调用就返回-1，errno设置为EWOULDBLOCK

非阻塞I/O与I/O几乎形影不离

I/O复用是最常使用的I/O通知机制。它指的是，应用程序通过I/O复用函数向内核**注册一组事件**，内核通过I/O复用函数把其中就绪的事件通知给应用程序。Linux上常用的I/O复用函数是select、poll和epoll_wait，我们将在第9章详细讨论它们。需要指出的是，**I/O复用函数本身是阻塞的**，它们能提高程序效率的原因在于它们具有同时监听多个I/O事件的能力。

SIGIO信号也可用来报告I/O事件，当有事件发生时，SIGIO信号的信号处理函数将被触发。

阻塞式I/O、非阻塞式I/O、I/O复用、信号驱动式I/都可以算作同步I/O，I/O的读写操作都是在事件发生后**由应用程序完成的**，通知的是**I/O就绪事件**

异步I/O（一般用aio_read和aio_write）**由内核完成I/O操作**，完成后通知用户，通知的是**I/O完成事件**

书里面定义的4种I/O模型（把非阻塞I/O放进I/O复用里了），与UNP定义的5种略有出入，还是按照UNP的来吧

### 两种高效的事件处理模式

服务器程序通常需要处理三类事件：I/O事件、信号及定时事件。

随着网络设计模式的兴起，Reactor和Proactor事件处理模式应运而生。**同步I/O模型通常用于实现Reactor模式，异步I/O模型则用于实现Proactor模式**。不过后面我们将看到，如何使用同步I/O方式模拟出Proactor模式。

#### Reactor模式

Reactor是这样一种模式，它要求**主线程（I/O处理单元）**只负责监听文件描述上是否有事件发生，有的话就立即将该事件通知**工作线程（逻辑单元）**。除此之外，主线程不做任何其他实质性的工作。读写数据，接受新的连接，以及处理客户请求均在工作线程中完成。

使用同步I/O模型（以epoll_wait为例）实现的Reactor模式的工作流程是：

1. 主线程往epoll内核事件表中注册socket上的读就绪事件。
2. 主线程调用epoll_wait等待socket上有数据可读。
3. 当socket上有数据可读时，epoll_wait通知主线程。主线程则将socket可读事件放入请求队列。
4. 睡眠在请求队列上的某个工作线程**被唤醒**，它从socket读取数据，并处理客户请求，然后往epoll内核事件表中注册该socket上的写就绪事件。
5. 主线程调用epoll_wait等待socket可写。
6. 当socket可写时，epoll_wait通知主线程。主线程将socket可写事件放入请求队列。
7. 睡眠在请求队列上的某个工作线程被唤醒，它往socket上写入服务器处理客户请求的结果。

图8-5总结了Reactor模式的工作流程。

![20200218083356.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200218083356.png)

#### Proactor模式

与Reactor模式不同，Proactor模式将**所有I/O操作都交给主线程和内核来处理**，工作线程仅仅负责业务逻辑。

使用**异步I/O模型（以aio_read和aio_write为例）**实现的Proactor模式的工作流程是：

1. 主线程调用aio_read函数向内核注册socket上的读完成事件，并告诉内核用户读缓冲区的位置，以及读操作完成时如何通知应用程序（这里以信号为例，详情请参考sigevent的man手册）。
2. 主线程继续处理其他逻辑。
3. 当socket上的数据被读入用户缓冲区后，内核将向应用程序发送一个信号，以通知应用程序数据已经可用。
4. 应用程序预先定义好的信号处理函数选择一个工作线程来处理客户请求。工作线程处理完客户请求之后，调用aio_write函数向内核注册socket上的写完成事件，并告诉内核用户写缓冲区的位置，以及写操作完成时如何通知应用程序（仍然以信号为例）。
5. 主线程继续处理其他逻辑。
6. 当用户缓冲区的数据被写入socket之后，内核将向应用程序发送一个信号，以通知应用程序数据已经发送完毕。
7. 应用程序预先定义好的信号处理函数选择一个工作线程来做善后处理，比如决定是否关闭socket。

图8-6总结了Proactor模式的工作流程。

![20200218083959.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200218083959.png)

在图8-6中，连接socket上的读写事件是通过aio_read/aio_write向内核注册的，因此内核将通过信号来向应用程序报告连接socket上的读写事件。所以，主线程中的epoll_wait调用仅能用来检测监听socket上的连接请求事件，而不能用来检测连接socket上的读写事件。

#### 模拟Proactor模式

可以使用同步I/O方式模拟出Proactor模式。其原理是：主线程执行数据读写操作，读写完成之后，主线程向工作线程通知这一“完成事件”。那么从工作线程的角度来看，它们就直接获得了数据读写的结果，接下来要做的只是对读写的结果进行逻辑处理。

使用同步I/O模型（仍然以epoll_wait为例）模拟出的Proactor模式的工作流程如下：

1. 主线程往epoll内核事件表中注册socket上的读就绪事件。
2. 主线程调用epoll_wait等待socket上有数据可读。
3. 当socket上有数据可读时，epoll_wait通知主线程。主线程从socket循环读取数据，直到没有更多数据可读，然后将读取到的数据封装成一个请求对象并插入请求队列。
4. 睡眠在请求队列上的某个工作线程被唤醒，它获得请求对象并处理客户请求，然后往epoll内核时间表中注册socket上的写就绪事件
5. 主线程调用epoll_wait等待socket可写。
6. 当socket可写时，epoll_wait通知主线程。主线程往socket上写入服务器处理客户请求的结果。

图8-7总结了用同步I/O模型模拟出的Proactor模式的工作流程。

![20200218084610.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200218084610.png)

### 两种高效的并发模式

并发编程的目的是让程序“同时”执行多个任务。

如果程序是计算密集型，并发编程没有优势，反而由于切换任务使效率降低。但如果程序是I/O密集型，比如经常读写文件、访问数据库等，由于I/O操作远没有CPU计算速度块，所以让程序阻塞于I/O操作将浪费大量CPU时间。

#### 半同步/半异步模式

#### 领导者/追随者模式

### 有限状态机

有限状态机是逻辑单元内部高效的编程方法

### 提高服务器性能的其他建议

#### 池（pool）

因为服务器的硬件资源较为充裕，所以可以以空间换时间

**池是一组资源的集合**，这组资源在服务器启动之初就被完全创建好并初始化，这称为**静态资源分配**。当服务器进入正式运行阶段，即开始处理客户请求的时候，如果它需要相关的资源，就可以直接从池中获取，无须动态分配。很显然，直接从池中取得所需资源比动态分配资源的速度要快得多，因为分配系统资源的系统调用都是很耗时的。当服务器处理完一个客户连接后，可以把相关的资源放回池中，无须执行系统调用来释放资源。

池的大小如何设计，如果资源真的很充裕那可以分配足够大的池，也可以先分配一定的资源，如果发现资源不够再动态分配一些加入池中

常见的

- **内存池**：通常用于socket的接收缓存和发送缓存。对于某些长度有限的客户请求，比如HTTP请求，预先分配一个大小足够（比如5000字节）的接收缓存区是很合理的。当客户请求的长度超过接收缓冲区的大小时，我们可以选择丢弃请求或者动态扩大接收缓冲区。
- **进程池和线程池**：都是并发编程常用的“伎俩”。当我们需要一个工作进程或工作线程来处理新到来的客户请求时，我们可以直接从进程池或线程池中取得一个执行实体，而无须动态地调用fork或pthread_create等函数来创建进程和线程。
- **连接池**：通常用于服务器或服务器机群的内部永久连接。图8-4中，每个逻辑单元可能都需要频繁地访问本地的某个数据库。简单的做法是：逻辑单元每次需要访问数据库的时候，就向数据库程序发起连接，而访问完毕后释放连接。很显然，这种做法的效率太低。一种解决方案是使用连接池。连接池是服务器预先和数据库程序建立的一组连接的集合。当某个逻辑单元需要访问数据库时，它可以直接从连接池中取得一个连接的实体并使用之。待完成数据库的访问之后，逻辑单元再将该连接返还给连接池。

#### 数据复制（零拷贝）

高性能服务器应该避免不必要的数据复制，尤其是当数据复制发生在**用户代码和内核之间**的时候。如果内核可以直接处理从socket或者文件读入的数据，则应用程序就没必要将这些数据从内核缓冲区复制到应用程序缓冲区中。这里说的“直接处理”指的是应用程序不关心这些数据的内容，不需要对它们做任何分析。可以直接用sendfile函数。

#### 上下文切换和锁

进程or线程的切换称为**上下文切换（context switch）**，即使是I/O密集型的服务器，也不应该有太多的工作进程or线程，否则上下文切换开销太大。所以，**每个连接or请求都创建一个工作进程or线程是不可取的**，比如muduo网络库每个工作线程就可以处理多个连接。

并发程序需要考虑的另外一个问题是共享资源的加锁保护。锁通常被认为是导致服务器效率低下的一个因素，因为由它引入的代码不仅不处理任何业务逻辑，而且需要访问内核资源。因此，服务器如果有更好的解决方案，就应该避免使用锁。（本书作者说为了减小锁的粒度可以用读写锁，而陈硕推荐不用读写锁只用mutex）

## 第9章 I/O复用

I/O复用使得程序能同时监听多个文件描述符，但它本身是阻塞的，要结合多进程or线程一起使用（一般要与非阻塞I/O一起使用）

Linux下实现I/O复用的系统调用主要有select、poll和epoll

### select系统调用

select系统调用的用途是：在一段指定时间内，监听用户感兴趣的文件描述符上的可读、可写和异常等事件。本节先介绍select系统调用的API，然后讨论select判断文件描述符就绪的条件，最后给出它在处理带外数据中的实际应用。

####　select API

select系统调用的原型如下：

```c++
int select(int nfds, fd_set* readfds,fd_set* writefds,fd_set* exceptfds, struct timeval* timeout);
```

1. nfds参数指定被监听的文件描述符的总数。它通常被设置为select监听的**所有文件描述符中的最大值加1**，因为文件描述符是从0开始计数的。

2. readfds、writefds和exceptf参数分别指向可读、可写和异常等时间对应的文件描述符集合。一般用下面函数来操作fd_set结构里的位：

    ```c++
    FD_ZERO(fd_set*fdset);/*清除fdset的所有位*/
    FD_SET(int fd,fd_set*fdset);/*设置fdset的位fd*/
    FD_CLR(int fd,fd_set*fdset);/*清除fdset的位fd*/
    int FD_ISSET(int fd,fd_set*fdset);/*测试fdset的位fd是否被设置*/
    ```

3. timeout参数用来设置select函数的超时时间。它是一个timeval结构类型（内含tv_sec与tv_usec成员）的指针，采用指针参数是因为内核将修改它以告诉应用程序select等待了多久。**微妙级**定时.如果tv_sec与tv_usec都是0，则立即返回；如果给timeout是null，则select将一直阻塞直至某文件描述符就绪

select成功时返回就绪（可读、可写和异常）文件描述符的总数。如果在超时时间内没有任何文件描述符就绪，select将返回0。select失败时返回-1并设置errno。如果在select等待期间，程序接收到信号，则select立即返回-1，并设置errno为EINTR。

#### 文件描述符就绪条件

哪些情况下文件描述符可以被认为是可读、可写或者出现异常，对于select的使用非常关键。在网络编程中，下列情况下socket可读：

- socket内核接收缓存区中的字节数大于或等于其低水位标记SO_RCVLOWAT。此时我们可以无阻塞地读该socket，并且读操作返回的字节数大于0。
- socket通信的对方关闭连接。此时对该socket的读操作将返回0。
- 监听socket上有新的连接请求。
- socket上有未处理的错误。此时我们可以使用getsockopt来读取和清除该错误。

下列情况下socket可写：

- socket内核发送缓存区中的可用字节数大于或等于其低水位标记SO_SNDLOWAT。此时我们可以无阻塞地写该socket，并且写操作返回的字节数大于0。
- socket的写操作被关闭。对写操作被关闭的socket执行写操作将触发一个SIGPIPE信号。
- socket使用非阻塞connect连接成功或者失败（超时）之后。
- socket上有未处理的错误。此时我们可以使用getsockopt来读取和清除该错误。

网络程序中，select能处理的异常情况只有一种：socket上接收到带外数据。

####　处理带外数据

### poll系统调用

poll系统调用和select类似，也是在指定时间内轮询一定数量的文件描述符，以测试其中是否有就绪者。poll的原型如下：

```c++
int poll(struct pollfd* fds, nfds_t nfds, int timeout);
```

1. fds参数是一个pollfd结构类型的数组，它指定所有我们感兴趣的文件描述符上发生的可读、可写和异常等事件。pollfd结构体的定义如下：

    ```c++
    struct pollfd
    {
    int fd;/*文件描述符*/
    short events;/*注册的事件*/
    short revents;/*实际发生的事件，由内核填充*/
    };
    ```

2. nfds参数指定被监听集合事件fds的大小

3. timeout参数指定poll的超时值，**单位是毫秒**。当timeout为-1时，poll调用将永远阻塞，直到某个事件发生；当timeout为0时，poll调用将立即返回。（注意与select的timeval结构体区别）

poll系统调用的返回值的含义与select相同。

### epoll系列系统调用（重要）

####　内核事件表

**epoll是Linux特有的I/O复用函数**。它在实现和使用上与select、poll有很大差异。首先，epoll使用**一组**函数来完成任务，而不是单个函数。其次，epoll把用户关心的文件描述符上的事件放在内核里的一个**事件表**中，从而无须像select和poll那样每次调用都要重复传入文件描述符集或事件集。但epoll需要使用一个**额外**的文件描述符，来唯一标识内核中的这个事件表。这个文件描述符使用如下epoll_create函数来创建：

```c++
int epoll_create(int size)
```

size参数现在并不起作用，只是给内核一个提示，告诉它事件表需要多大。该函数返回的文件描述符将用作其他所有epoll系统调用的第一个参数（epfd），以指定要访问的内核事件表。

下面的函数用来操作epoll的内核事件表：

```c++
int epoll_ctl(int epfd,int op,int fd,struct epoll_event*event)
```

- epfd是epoll_create创建的描述符，标识内核中的epoll事件表

- fd参数是要操作的文件描述符

- op参数则指定操作类型。操作类型有如下3种：

  - EPOLL_CTL_ADD，往事件表中注册fd上的事件。
  - EPOLL_CTL_MOD，修改fd上的注册事件。
  - EPOLL_CTL_DEL，删除fd上的注册事件。

- event参数指定事件，它是epoll_event结构指针类型。epoll_event的定义如下：

    ```c++
    struct epoll_event
    {
        __uint32_t events;  /*epoll事件*/
        epoll_data_t data;  /*用户数据*/
    };
    ```

    其中events成员描述事件类型。epoll支持的事件类型和poll基本相同。表示epoll事件类型的宏是在poll对应的宏前加上“E”，比如epoll的数据可读事件是EPOLLIN。但**epoll有两个额外的事件类型——EPOLLET和EPOLLONESHOT**。它们对于epoll的高效运作非常关键。data成员用于存储用户数据，其类型epoll_data_t是个联合体union。

#### epoll_wait函数（主要接口）

epoll系列系统调用的主要接口是epoll_wait函数。它在一段超时时间内等待一组文件描述符上的事件，其原型如下：

```c++
int epoll_wait(int epfd, struct epoll_event* events,int  maxevents,int timeout);
```

该函数成功时返回就绪的文件描述符的个数，失败时返回-1并设置errno。
关于该函数的参数，我们从后往前讨论。

- timeout参数的含义与poll接口的timeout参数相同。

- maxevents参数指定最多监听多少个事件，它必须大于0。

- epoll_wait函数如果检测到事件，就将所有就绪的事件从内核事件表（由epfd参数指定）中复制到它的第二个参数events指向的数组中。**这个数组只用于输出epoll_wait检测到的就绪事件**，而不像select和poll的数组参数那样既用于传入用户注册的事件，又用于输出内核检测到的就绪事件。这就**极大地提高了索引就绪文件描述符的效率**。

poll和epoll在使用上的差别，可以看到**poll需要一次遍历**，epoll直接把就绪事件复制到events数组中，所以**epoll不需要遍历**

```c++
/*如何索引poll返回的就绪文件描述符*/
int ret=poll(fds,MAX_EVENT_NUMBER,-1);
/*必须遍历所有已注册文件描述符并找到其中的就绪者（当然，可以利用ret来稍做优化）*/
for(int i=0;i＜MAX_EVENT_NUMBER;++i)
{
    if(fds[i].revents＆POLLIN)/*判断第i个文件描述符是否就绪*/
    {
        int sockfd=fds[i].fd;
        /*处理sockfd*/
    }
}
/*如何索引epoll返回的就绪文件描述符*/
int ret=epoll_wait(epollfd,events,MAX_EVENT_NUMBER,-1);
/*仅遍历就绪的ret个文件描述符*/
for(int i=0;i＜ret;i++)
{
    int sockfd=events[i].data.fd;
    /*sockfd肯定就绪，直接处理*/
}

```

#### LT和ET模式（非常重要，笔记已结合网上资料）

epoll对文件描述符的操作有两种模式，根据数字电子电路的电平触发与边沿触发区分：

- **LT（Level Trigger，电平触发）**：默认模式，符合select/，不易出错

    socket接收缓冲区不为空，有数据可读，读事件**一直触发**

    socket发送缓冲区不， 可以继续写入数据，写事件**一直触发**

    **状态满足就一直触发**

    [x] 当epoll_wait检测到其上有事件发生并将此事件通知应用程序后，应用程序可以不立即处理该事件。这样，当应用程序下一次调用epoll_wait时，epoll_wait还会再次向应用程序通告此事件，直到该事件被处理。

- **ET（Edge Trigger，边沿触发）**：更简洁，某些场景下更高效，但**容易遗漏事件（需要一直读写）**当往epoll内核事件表中注册一个文件描述符上的**EPOLLET事件**时，转为ET

    socket的接收缓冲区状态变化时触发读事件，即空的接收缓冲区刚接收到数据时触发读事件

    socket的发送缓冲区状态变化时触发写事件，即满的缓冲区刚空出空间时触发读事件

    **仅在状态变化时触发事件**

    [x] 当epoll_wait检测到其上有事件发生并将此事件通知应用程序后，应用程序必须立即处理该事件，因为后续的epoll_wait调用将不再向应用程序通知这一事件。可见，ET模式在很大程度上降低了同一个epoll事件被重复触发的次数，因此效率要比LT模式高。

代码清单9-3　LT和ET模式

```c++
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <assert.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/epoll.h>
#include <pthread.h>

#define MAX_EVENT_NUMBER 1024
#define BUFFER_SIZE 10

// 文件描述符设置为非阻塞
int setnonblocking( int fd )
{
    int old_option = fcntl( fd, F_GETFL );
    int new_option = old_option | O_NONBLOCK;
    fcntl( fd, F_SETFL, new_option );
    return old_option;
}

// 将文件描述符fd上的EPOLLIN注册到epollfd指示的epoll内核事件表中，参数enable_et指定是否对fd启用ET模式
void addfd( int epollfd, int fd, bool enable_et )
{
    epoll_event event;
    event.data.fd = fd;
    event.events = EPOLLIN;
    if( enable_et )
    {
        event.events |= EPOLLET;
    }
    epoll_ctl( epollfd, EPOLL_CTL_ADD, fd, &event );
    setnonblocking( fd );
}

void lt( epoll_event* events, int number, int epollfd, int listenfd )
{
    char buf[ BUFFER_SIZE ];
    for ( int i = 0; i < number; i++ )
    {
        int sockfd = events[i].data.fd;
        if ( sockfd == listenfd )
        {
            struct sockaddr_in client_address;
            socklen_t client_addrlength = sizeof( client_address );
            int connfd = accept( listenfd, ( struct sockaddr* )&client_address, &client_addrlength );
            addfd( epollfd, connfd, false );
        }
        else if ( events[i].events & EPOLLIN )
        {
            // 只要socket读缓存还有未读出的数据，这段代码就触发
            printf( "event trigger once\n" );
            memset( buf, '\0', BUFFER_SIZE );
            int ret = recv( sockfd, buf, BUFFER_SIZE-1, 0 );
            if( ret <= 0 )
            {
                close( sockfd );
                continue;
            }
            printf( "get %d bytes of content: %s\n", ret, buf );
        }
        else
        {
            printf( "something else happened \n" );
        }
    }
}

void et( epoll_event* events, int number, int epollfd, int listenfd )
{
    char buf[ BUFFER_SIZE ];
    for ( int i = 0; i < number; i++ )
    {
        int sockfd = events[i].data.fd;
        if ( sockfd == listenfd )
        {
            struct sockaddr_in client_address;
            socklen_t client_addrlength = sizeof( client_address );
            int connfd = accept( listenfd, ( struct sockaddr* )&client_address, &client_addrlength );
            addfd( epollfd, connfd, true );
        }
        else if ( events[i].events & EPOLLIN )
        {
            // 这段代码不会重复触发，所以我们循环读取数据，确保读缓存中的所有数据读出
            printf( "event trigger once\n" );
            while( 1 )
            {
                memset( buf, '\0', BUFFER_SIZE );
                int ret = recv( sockfd, buf, BUFFER_SIZE-1, 0 );
                if( ret < 0 )
                {
                    // 对于非阻塞IO，下面条件成立表示数据已全部读取完毕，此后epoll就能再次触发sockfd上的EPOLLIN事件，以驱动下一次读操作
                    if( ( errno == EAGAIN ) || ( errno == EWOULDBLOCK ) )
                    {
                        printf( "read later\n" );
                        break;
                    }
                    close( sockfd );
                    break;
                }
                else if( ret == 0 )
                {
                    close( sockfd );
                }
                else
                {
                    printf( "get %d bytes of content: %s\n", ret, buf );
                }
            }
        }
        else
        {
            printf( "something else happened \n" );
        }
    }
}

int main( int argc, char* argv[] )
{
    if( argc <= 2 )
    {
        printf( "usage: %s ip_address port_number\n", basename( argv[0] ) );
        return 1;
    }
    const char* ip = argv[1];
    int port = atoi( argv[2] );

    int ret = 0;
    struct sockaddr_in address;
    bzero( &address, sizeof( address ) );
    address.sin_family = AF_INET;
    inet_pton( AF_INET, ip, &address.sin_addr );
    address.sin_port = htons( port );

    int listenfd = socket( PF_INET, SOCK_STREAM, 0 );
    assert( listenfd >= 0 );

    ret = bind( listenfd, ( struct sockaddr* )&address, sizeof( address ) );
    assert( ret != -1 );

    ret = listen( listenfd, 5 );
    assert( ret != -1 );

    epoll_event events[ MAX_EVENT_NUMBER ];
    int epollfd = epoll_create( 5 );
    assert( epollfd != -1 );
    addfd( epollfd, listenfd, true );

    while( 1 )
    {
        int ret = epoll_wait( epollfd, events, MAX_EVENT_NUMBER, -1 );
        if ( ret < 0 )
        {
            printf( "epoll failure\n" );
            break;
        }

        lt( events, ret, epollfd, listenfd );
        //et( events, ret, epollfd, listenfd );
    }

    close( listenfd );
    return 0;
}
```

#### epoll oneshot（确保一个socket只被一个进程/线程使用）

在多进程/多线程中，即使epoll使用ET模式，还是有可能触发多次。比如一个进程/线程正在处理某个socket上的事件，而这时该socket又有新事件就绪，此时另外一个进程/线程会被唤醒来处理新事件，这当然不是我们期望的。

我们期望的是**一个socket只被一个进程/线程处理**，这可以用epoll的EPOLLONESHOT事件实现。

对于注册了EPOLLONESHOT事件的文件描述符，操作系统最多触发其上注册的一个可读、可写或者异常事件，且只触发一次，除非我们使用epoll_ctl函数重置该文件描述符上注册的EPOLLONESHOT事件。这样，当一个线程在处理某个socket时，其他线程是不可能有机会操作该socket的。**避免了竞态条件**。

注意，注册了EPOLLONESHOT事件的socket一旦被某个线程处理完毕，该线程就应该**立即重置这个socket上的EPOLLONESHOT事件**，以确保这个socket下一次可读时，其EPOLLIN事件能被触发，进而让其他工作线程有机会继续处理这个socket。

代码清单9-4　使用EPOLLONESHOT事件

```c++
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <assert.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/epoll.h>
#include <pthread.h>

#define MAX_EVENT_NUMBER 1024
#define BUFFER_SIZE 1024
struct fds
{
   int epollfd;
   int sockfd;
};

int setnonblocking( int fd )
{
    int old_option = fcntl( fd, F_GETFL );
    int new_option = old_option | O_NONBLOCK;
    fcntl( fd, F_SETFL, new_option );
    return old_option;
}

// 将fd上的EPOLLIN和EPOLLET事件注册到epollfd指示的epoll内核事件表中，参数oneshot指定是否注册fd上的EPOLLONESHOT事件
void addfd( int epollfd, int fd, bool oneshot )
{
    epoll_event event;
    event.data.fd = fd;
    event.events = EPOLLIN | EPOLLET;
    if( oneshot )
    {
        event.events |= EPOLLONESHOT;
    }
    epoll_ctl( epollfd, EPOLL_CTL_ADD, fd, &event );
    setnonblocking( fd );
}

// 重置fd上的事件。这样操作之后，尽管fd上的EPOLLONESHOT事件被注册，但是操作系统仍然会触发fd上的EPOLLIN事件，且只触发一次
void reset_oneshot( int epollfd, int fd )
{
    epoll_event event;
    event.data.fd = fd;
    event.events = EPOLLIN | EPOLLET | EPOLLONESHOT;
    epoll_ctl( epollfd, EPOLL_CTL_MOD, fd, &event );
}

void* worker( void* arg )
{
    int sockfd = ( (fds*)arg )->sockfd;
    int epollfd = ( (fds*)arg )->epollfd;
    printf( "start new thread to receive data on fd: %d\n", sockfd );
    char buf[ BUFFER_SIZE ];
    memset( buf, '\0', BUFFER_SIZE );
    // 循环读取sockfd上的数据，直到遇到EAGAIN错误
    while( 1 )
    {
        int ret = recv( sockfd, buf, BUFFER_SIZE-1, 0 );
        if( ret == 0 )
        {
            close( sockfd );
            printf( "foreiner closed the connection\n" );
            break;
        }
        else if( ret < 0 )
        {
            if( errno == EAGAIN )
            {
                reset_oneshot( epollfd, sockfd );
                printf( "read later\n" );
                break;
            }
        }
        else
        {
            printf( "get content: %s\n", buf );
            // 休眠5s，模拟数据处理过程
            sleep( 5 );
        }
    }
    printf( "end thread receiving data on fd: %d\n", sockfd );
}

int main( int argc, char* argv[] )
{
    if( argc <= 2 )
    {
        printf( "usage: %s ip_address port_number\n", basename( argv[0] ) );
        return 1;
    }
    const char* ip = argv[1];
    int port = atoi( argv[2] );

    int ret = 0;
    struct sockaddr_in address;
    bzero( &address, sizeof( address ) );
    address.sin_family = AF_INET;
    inet_pton( AF_INET, ip, &address.sin_addr );
    address.sin_port = htons( port );

    int listenfd = socket( PF_INET, SOCK_STREAM, 0 );
    assert( listenfd >= 0 );

    ret = bind( listenfd, ( struct sockaddr* )&address, sizeof( address ) );
    assert( ret != -1 );

    ret = listen( listenfd, 5 );
    assert( ret != -1 );

    epoll_event events[ MAX_EVENT_NUMBER ];
    int epollfd = epoll_create( 5 );
    assert( epollfd != -1 );
    // 注意，监听socket listenfd上是不能注册EPOLLONESHOT事件的，否则应用程序只能处理一个客户连接！因为后续的客户连接请求将不再触发listenfd上的EPOLLIN事件
    addfd( epollfd, listenfd, false );

    while( 1 )
    {
        int ret = epoll_wait( epollfd, events, MAX_EVENT_NUMBER, -1 );
        if ( ret < 0 )
        {
            printf( "epoll failure\n" );
            break;
        }

        for ( int i = 0; i < ret; i++ )
        {
            int sockfd = events[i].data.fd;
            if ( sockfd == listenfd )
            {
                struct sockaddr_in client_address;
                socklen_t client_addrlength = sizeof( client_address );
                int connfd = accept( listenfd, ( struct sockaddr* )&client_address, &client_addrlength );
                // 对每个非监听文件描述符都注册EPOLLONESHOT事件
                addfd( epollfd, connfd, true );
            }
            else if ( events[i].events & EPOLLIN )
            {
                pthread_t thread;
                fds fds_for_new_worker;
                fds_for_new_worker.epollfd = epollfd;
                fds_for_new_worker.sockfd = sockfd;
                pthread_create( &thread, NULL, worker, ( void* )&fds_for_new_worker );
            }
            else
            {
                printf( "something else happened \n" );
            }
        }
    }

    close( listenfd );
    return 0;
}
```

### select，poll，epoll比较

- 事件

    select使用的是fd_set，它没有将fd与事件绑定，所以需要提供三个fd_set（可读、可写、异常）来传入特定事件。而且内核会修改fd_set，所以下次使用时要**重置**。

    poll使用的是poll_fd，把fd与事件放在一起处理，比select更简洁，监听事件通过events注册，就绪事件通过revents返回，**两者分离**，内核不会修改events，无须重置。

    epoll在内核**维护了一个事件表**，独立的函数epoll_ctnl往里面增加、修改、删除事件，这样每次epoll_wait调用都可以直接从内核中获得具体事件。

- 数量

    select有最大数量的限制，一般较小

    poll、epoll_wait能监听的最大fd数量取决于OS，一般很大，如65535

- 工作模式

    select、poll只能在LT

    epoll还能ET，并且支持oneshot

- 时间复杂度

    select、poll用的是轮询，每次调用要扫描整个注册fd集合，返回其中就绪的fd。所以，**索引就绪fd需要O(n)**

    epoll_wait则不同，采用的是回调，直接将就绪事件拷贝到用户控件，**索引就绪fd只需要O(1)**

### I/O复用的高级应用一：非阻塞connect

### I/O复用的高级应用二：聊天室程序

### I/O复用的高级应用三：同时处理TCP和UDP服务

### 超级服务inetd

## 第10章 信号

### Linux信号概述

#### 发送信号

当前进程用kill函数给另一个进程（用pid参数指示）发送特定信号（用sig指示）

```c++
int kill(pid_t pid, int sig);
```

- pid>0: 发送给pid进程
- pid=0: 发送给本进程组其他进程
- pid=-1:发送给除init进程外的所有进程，但要有相应权限
- pid<-1:发送给组ID为-pid的进程组中所有进程

Linux定义的信号值都大于0，如果sig取值为0，则kill函数不发送任何信号，但可以检查目标进程是否存在（但是不可靠）

kill函数成功返回0，失败返回-1并设置errno

- EINVAL：无效信号
- EPERM：无权限
- ESRCH：目标不存在

注意：此kill非shell命令kill（杀死进程）

#### 信号处理方式

#### Linux信号

#### 中断系统调用

程序在执行系统调用中接收到信号，则系统调用会被打断，errno置为EINTR

### 信号函数

#### signal系统调用

用来设置信号处理函数，**sig指出要捕获的信号类型**，**_handler指定信号sig的信号处理函数**

```c++
_sighandler_t signal(int sig, _sighandler_t _handler);
```

#### sigaction系统调用

也可以设置信号处理函数，**sigaction比signal更健壮一点**

### 信号集

sigset_t表示一组信号

setprocmask函数用于设置信号掩码

sigpending挂起信号

### 统一事件源（I/O复用可以同时监听IO与信号）

信号是一种异步事件：信号处理函数和程序的主循环是两条不同的执行路线。很显然，信号处理函数需要尽可能快地执行完毕，以确保该信号不被屏蔽（前面提到过，为了避免一些竞态条件，信号在处理期间，系统不会再次触发它）太久。

一种典型的解决方案是：把信号的主要处理逻辑放到程序的主循环中，当信号处理函数被触发时，它只是简单地通知主循环程序接收到信号，并把信号值传递给主循环，主循环再根据接收到的信号值执行目标信号对应的逻辑代码。信号处理函数通常使用管道来将信号“传递”给主循环：信号处理函数往管道的写端写入信号值，主循环则从管道的读端读出该信号值。

那么主循环怎么知道管道上何时有数据可读呢?这很简单，我们只需要使用I/O复用系统调用来监听管道的读端文件描述符上的可读事件。如此一来，信号就能和其他I/O事件一样被处理，即统一事件源

### 网络编程相关信号

#### SIGHUP

当挂起进程的控制终端时，SIGHUP信号将被触发。对于没有控制终端的网络后台程序而言，它们通常利用SIGHUP信号来**强制服务器重读配置文件**

#### SIGPIPE

默认情况下，往一个读端关闭的管道或socket连接中写数据将引发SIGPIPE信号。我们需要在代码中捕获并处理该信号，或者至少忽略它，因为程序接收到SIGPIPE信号的**默认行为是结束进程**，而我们绝对不希望因为错误的写操作而导致程序退出。

#### SIGURG

Linux内核通知程序带外数据到达有两种方法

- I/O复用，select等系统调用接收到带外数据报告**异常事件**

- 使用SIGURG信号

## 第11章 定时器

Linux提供了三种定时方法，它们是：

- socket选项SO_RCVTIMEO和SO_SNDTIMEO。
- SIGALRM信号。
- I/O复用系统调用的超时参数。

### socket选项SO_RCVTIMEO和SO_SNDTIMEO

仅适用于数据发送和接收的socket API，如send、sendmsg、recv、recvmsg、accept、connect这些系统调用

超时后，A系统调用返回-1并设置errno为EAGAIN或EWOULDBLOCK

### SIGALRM信号

### I/O复用系统调用的超时参数

### 高性能定时器

#### 时间轮（time wheel）

![20200218120147.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200218120147.png)

时间轮的（实线）指针指向轮子上的一个槽（slot）。它以恒定的速度顺时针转动，每转动一步就指向下一个槽（虚线指针指向的槽），每次转动称为一个滴答（tick）。一个滴答的时间称为时间轮的槽间隔si（slot interval），它实际上就是心搏时间。该时间轮共有N个槽，因此它运转一周的时间是N*si

基于排序链表的定时器使用唯一的一条链表来管理所有定时器，所以插入操作的效率随着定时器数目的增多而降低。而时间轮使用哈希表的思想，将定时器散列到不同的链表上。这样每条链表上的定时器数目都将明显少于原来的排序链表上的定时器数目，插入操作的效率基本不受定时器数目的影响。

#### 时间堆（最小堆）

前面讨论的定时方案都是以固定的频率调用心搏函数tick，并在其中依次检测到期的定时器，然后执行到期定时器上的回调函数。设计定时器的另外一种思路是：**将所有定时器中超时时间最小的一个定时器的超时值作为心搏间隔**。这样，一旦心搏函数tick被调用，超时时间最小的定时器必然到期，我们就可以在tick函数中处理该定时器。然后，再次从剩余的定时器中找出超时时间最小的一个，并将这段最小时间设置为下一次心搏间隔。如此反复，就实现了较为精确的定时。

最小堆很适合处理这种定时方案

## 第12章 高性能I/O框架库Libevent

各种I/O框架库的实现原理基本相似，要么以Reactor模式实现，要么以Proactor模式实现，要么同时以这两种模式实现。举例来说，基于Reactor模式的I/O框架库包含如下几个组件：句柄（Handle）、事件多路分发器（EventDemultiplexer）、事件处理器（EventHandler）和具体的事件处理器（ConcreteEventHandler）、Reactor。这些组件的关系如图12-1所示。

![20200218120823.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200218120823.png)

### Libevent源码分析

异步事件、跨平台、统一事件源、线程安全、基于Reactor

libevent 库实际上没有更换 select()、poll() 或其他机制的基础。而是使用对于每个平台最高效的高性能解决方案在实现外加上一个包装器。

为了实际处理每个请求，libevent 库提供一种事件机制，它作为底层网络后端的包装器。事件系统让为连接添加处理函数变得非常简便，同时降低了底层 I/O 复杂性。这是 libevent 系统的核心。

libevent 库的其他组件提供其他功能，包括缓冲的事件系统（用于缓冲发送到客户端/从客户端接收的数据）以及 HTTP、DNS 和 RPC 系统的核心实现。

创建 libevent 服务器的基本方法是，注册当发生某一操作（比如接受来自客户端的连接）时应该执行的函数，然后调用主事件循环 event_dispatch()。执行过程的控制现在由 libevent 系统处理。注册事件和将调用的函数之后，事件系统开始自治；在应用程序运行时，可以在事件队列中添加（注册）或删除（取消注册）事件。事件注册非常方便，可以通过它添加新事件以处理新打开的连接，从而构建灵活的网络处理系统。

## 第13章 多进程编程

### fork

创建新进程

```c++
pid_t fork(void);
```

该函数**调用一次返回两次**，父进程返回的是子进程的PID，子进程返回0

fork函数在内核进程表创建新的进程表项

复制父进程的资源（如堆指针、栈指针、fd、标志寄存器等）

复制父进程的数据（堆数据、栈数据、静态数据等），但采用的是**写时复制（copy-on-write）**技术，父子进程指向同一内存，子进程读没关系，当子进程要写时，才会真正复制一块新的内存，先产生**缺页中断**，操作系统给子进程分配内存，把父进程的数据复制过来，再对数据写。

子进程继承父进程的fd，并且引用计数加1

### exec系列

替换当前进程映像

```c++
extern char**environ;
int execl(const char*path,const char*arg,...);
int execlp(const char*file,const char*arg,...);
int execle(const char*path,const char*arg,...,char*const envp[]);
int execv(const char*path,char*const argv[]);
int execvp(const char*file,char*const argv[]);
int execve(const char*path,char*const argv[],char*const envp[]);
```

exec系列有6个函数，可用于不同场景，参数各有差别，例如：指定可执行文件的完整路径path、指定文件名file、指定可变参数arg、指定环境变量envp等等

一般情况下，exec函数是不返回的，除非出错。它出错时返回-1，并设置errno。如果没出错，则原程序中exec调用之后的代码都不会执行，因为此时原程序已经被exec的参数指定的程序完全替换（包括代码和数据）。

exec函数不会关闭原程序打开的文件描述符，除非该文件描述符被设置了类似SOCK_CLOEXEC的属性

### 处理僵尸进程——wait/waitpid与SIGCHLD信号

对于多进程程序而言，父进程一般需要跟踪子进程的退出状态。因此，当子进程结束运行时，内核不会立即释放该进程的进程表表项，以满足父进程后续对该子进程退出信息的查询（如果父进程还在运行）。

两种情况导致僵尸进程：

1. **子进程结束运行，父进程未回收（未调用wait）**

2. **父进程结束或者异常终止，而子进程继续运行**。此时子进程的父进程ID设为1，即init进程。init进程接管了该子进程，并等待它结束。

僵尸进程占据着内核资源。这是绝对不能容许的，毕竟内核资源有限。下面这对函数在父进程中调用，以等待子进程的结束，并获取子进程的返回状态：

```c++
pid_t wait(int* stat_loc);
pid_t waitpid(pid_t pid, int* stat_loc, int options);
```

wait函数将**阻塞**进程，直到该进程的某个子进程结束，它返回子进程的PID，并且将退出状态存储于stat_loc。

waitpid函数只等待由pid指定的子进程，如果pid=-1，则waitpid与wait相同，options参数可以控制waitpid函数的行为。该参数最常用的取值是WNOHANG。当options的取值是WNOHANG时，waitpid调用将是**非阻塞**的：如果pid指定的目标子进程还没有结束或意外终止，则waitpid立即返回0；如果目标子进程确实正常退出了，则waitpid返回该子进程的PID。waitpid调用失败时返回-1并设置errno。

**在事件已经发生的情况下执行非阻塞调用才能提高程序的效率**。对waitpid函数而言，我们最好在某个子进程退出之后再调用它。那么父进程从何得知某个子进程已经退出了呢？这正是SIGCHLD信号的用途。**当一个进程结束时，它将给其父进程发送一个SIGCHLD信号**。因此，我们可以在父进程中捕获SIGCHLD信号，并在信号处理函数中调用waitpid函数以“彻底结束”一个子进程。

代码清单13-1　SIGCHLD信号的典型处理函数

```c++
static void handle_child(int sig)
{
    pid_t pid;
    int stat;
    while((pid=waitpid(-1,＆stat,WNOHANG))＞0)
    {
        /*对结束的子进程进行善后处理*/
    }
}
```

### 管道（匿名与命名）

（匿名）管道能在父子进程之间传递数据，父进程调用pipe函数创建管道，fork后子进程继承父进程的管道，fd[0]和fd[1]都保持打开，但双方必须一个关闭fd[0]，另一个关闭fd[1]，这样就不会有干扰。

管道只能单向传输，若想双向，则创建两个管道

socket基础API中的socketpair可以创建双向管道

**命名管道**可以用于无关联进程之间的通信，但在网络编程中使用不多

### 信号量

当多个进程同时访问系统上的某个资源的时候，比如同时写一个数据库的某条记录，或者同时修改某个文件，就需要考虑进程的同步问题，以确保任一时刻只有一个进程可以拥有对资源的独占式访问。通常，程序对共享资源的访问的代码只是很短的一段，但就是这一段代码引发了进程之间的竞态条件。我们称这段代码为**临界区**。对进程同步，也就是确保任一时刻只有一个进程能进入临界区。

Dijkstra提出的**信号量（Semaphore）**概念是并发编程领域迈出的重要一步。信号量是一种特殊的变量，只有两种操作：P、V。这两个字母来自于荷兰语单词passeren（**传递**，就好像进入临界区）和vrijgeven（**释放**，就好像退出临界区）。

假设有信号量SV，则对它的P、V操作含义如下：

- P(SV)，如果SV的值大于0，就将它减1；如果SV的值为0，则挂起进程的执行。
- V(SV)，如果有其他进程因为等待SV而挂起，则唤醒之；如果没有，则将SV加1。

信号量的取值一般就用二进制信号量0和1，，使用一个普通变量来模拟二进制信号量是行不通的，因为所有高级语言都没有一个**原子操作**来完成比较与赋值

![20200218125630.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200218125630.png)

### 共享内存

共享内存是最高效的IPC机制，因为它不涉及进程之间的任何数据传输。这种高效率带来的问题是，我们必须用其他辅助手段来同步进程对共享内存的访问，否则会产生竞态条件。因此，共享内存通常和其他进程间通信方式（如互斥量和信号量）一起使用。

### 消息队列

消息队列是在两个进程之间传递二进制块数据的一种简单有效的方式。每个数据块都有一个特定的类型，接收方可以根据类型来有选择地接收数据，而不一定像管道和命名管道那样必须以先进先出的方式接收数据。

### IPC命令(ipcs)

Linux提供了ipcs命令，以观察当前系统上拥有哪些共享资源实例

还提供了ipcrm命令，用来删除遗留在系统中的共享资源

### 在进程间传递文件描述符（Unix域套接字）

由于fork调用之后，父进程中打开的文件描述符在子进程中仍然保持打开，所以文件描述符可以很方便地从父进程传递到子进程。需要注意的是，传递一个文件描述符并不是传递一个文件描述符的值，而是要在接收进程中创建一个新的文件描述符，并且该文件描述符和发送进程中被传递的文件描述符指向内核中相同的文件表项。

那么如何把子进程中打开的文件描述符传递给父进程呢？或者更通俗地说，如何在两个不相干的进程之间传递文件描述符呢？在Linux下，我们可以利用UNIX域socket在进程间传递特殊的辅助数据，以实现文件描述符的传递
