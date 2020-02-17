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
