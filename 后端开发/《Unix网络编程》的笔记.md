# Unix网络编程

陈硕

[谈一谈网络编程学习经验(06-08更新)](csdn.net/Solstice/article/details/6527585)

[c++高性能服务器网络编程(陈硕)](https://www.bilibili.com/video/av40870266?p=1)

[Practical Network Programming](http://chenshuo.com/practical-network-programming/)

[发布一个基于 Reactor 模式的 C++ 网络库](https://blog.csdn.net/Solstice/article/details/5848547)

[muduo网络库源码](https://github.com/chenshuo/muduo)

## 第6章 I/O复用：select和poll函数

进程可能正阻塞于某个I/O操作（例如标准输入上的fgets），这时网络I/O就没法进行，这样的进程就需要一种预先告知内核的能力，使得内核一旦发现进程指定的一个或多个I/O条件就绪（也就是说输入已准备好被读取，或者描述符已能承接更多的输出），它就通知进程。这个能力称为**I/O复用（I/O multiplexing）**，是由select和poll这两个函数支持的

I/O复用典型使用在下列网络应用场合

1. 当客户处理多个描述符（通常是交互式输入和网络套接字）时，必须使用I/O复用。这是我们早先讲述过的场合。
2. 客户同时处理多个套接字是可能的，不过比较少见。
3. TCP服务器既要处理监听套接字，又要处理已连接套接字
4. 服务器既要处理TCP，又要处理UDP
5. 服务器要处理多个服务或多个协议

还有很多重要的应用程序也用了I/O复用技术

### 5种I/O模型

1. 阻塞式I/O：最简单的模型，默认所有的套接字都是阻塞的
2. 非阻塞式I/O：I/O操作不会把当前进程投入睡眠，而是返回一个错误，通常需要**轮询（polling）**，耗费大量CPU时间，在专门提供某一种功能的系统中常见
3. I/O复用（select和poll）：阻塞于多个系统调用中某一个之上，注意要与“多线程中使用阻塞式I/O”相区别，select阻塞在多个文件描述符上，而多线程中每个文件描述符一个线程，所以可以自由地使用阻塞式I/O
4. 信号驱动式I/O（SIGIO）：让内核在描述符就绪时发送SIGIO信号通知进程，优势在于进程不被阻塞，主循环可继续执行
5. 异步I/O（POSIX的aio_系列函数）：进程告知内核启动某个操作，操作完成后，内核通知进程操作完成。区别在于，信号驱动式I/O是由内核通知我们何时可以**启动**一个I/O操作，而异步I/O模型是由内核通知我们I/O操作何时**完成**。支

前四种I/O模型都可算作**同步I/O模型**，支持异步I/O模型的操作系统较少见，

### select函数

该函数允许进程指示内核等待多个事件中的任何一个发生，并只在有一个或多个事件发生或经历一段指定的时间后才唤醒它。

```c
#include <sys/select.h>
#include <sys/time.h>
int select(int maxfdp1, fd_set *readset, fd_set *writeset,  fd_set *exceptset, const struct timeval *timeout);
// 返回：若有就绪描述符则为就绪描述符的数目，若超时则为0，若出错则为-1
```

#### timeout参数

最后一个参数timeout告知内核等待所指定描述符中的任何一个就绪可花多长时间，

```c
struct timeval {
  long   tv_sec;　　/* seconds */
  long   tv_usec;　　/* microseconds */
};
```

这个参数有以下三种可能。

1. 永远等待下去：仅在有一个描述符准备好I/O时才返回。为此，我们把该参数设置为空指针。
2. 等待一段固定时间：在有一个描述符准备好I/O时返回，但是不超过由该参数所指向的timeval结构中指定的秒数和微秒数。
3. 根本不等待：**检查描述符后立即返回，这称为轮询（polling）**。为此，该参数必须指向一个timeval结构，而且其中的定时器值（由该结构指定的秒数和微秒数）必须为0。

#### 描述符集fd_set参数

中间的三个参数readset、writeset和exceptset指定我们要让内核测试读、写和异常条件的描述符，它们是**描述符集**，通常是一个整数数组，其中每个整数中的每一**位**对应一个描述符。

用下面四个函数操作描述符集

```c
void FD_ZERO(fd_set *fdset);　　　　　　　　/* clear all bits in fdset */
void FD_SET(int fd, fd_set *fdset);　　　　/* turn on the bit for fd in fdset */
void FD_CLR(int fd, fd_set *fdset);　　　　/* trun off the bit for fd in fdset */
int  FD_ISSET(int fd, fd_set *fdset);　　　/* is the bit for fd on in fdset_? */
```

举个例子，以下代码用于定义一个fd_set类型的变量，然后打开描述符1、4和5的对应位：

```c
fd_set  rset;
FD_ZERO(&rset);　　　　　　/* initialize the set: all bits off */
FD_SET(1, &rset);　　　　　/* turn on bit for fd 1 */
FD_SET(4, &rset);　　　　　/* turn on bit for fd 4 */
FD_SET(5, &rset);　　　　　/* turn on bit for fd 5 */
```

描述符集的初始化非常重要，因为作为自动变量分配的一个描述符集如果没有初始化，那么可能发生不可预期的后果。

它们三个都是**值-结果参数**，当某个/些描述符就绪后，函数返回，描述符集内就绪描述符的对应位置为1，其他位置0。函数返回后可以用FD_ISSET测试哪些位就绪了，而且下次再用select函数之前，别忘了再次把所有描述符集重新初始化。

select函数的中间三个参数readset、writeset和exceptset中，如果我们对某一个的条件不感兴趣，就可以把它设为空指针。事实上，如果这三个指针均为空，我们就有了一个比Unix的sleep函数更为精确的定时器（sleep睡眠以秒为最小单位）

#### maxfdp1参数

maxfdp1参数指定待测试的描述符个数，它的值是待测试的最大描述符加1（因此我们把该参数命名为maxfdp1），描述符0, 1, 2, …，一直到maxfdp1-1均将被测试。该参数纯粹是为了效率原因。每个fd_set都有表示大量描述符（典型数量为1024）的空间，然而一个普通进程所用的数量却少得多。内核正是通过在进程与内核之间不复制描述符集中不必要的部分，从而不测试总为0的那些位来提高效率的

#### 描述符就绪条件

套接字准备好读的最典型条件是：该套接字接收缓冲区中的数据字节数大于等于套接字**接收缓冲区低水位标记**的当前大小

套接字准备好写的最典型条件是：该套接字发送缓冲区中的可用空间字节数大于等于套接字**发送缓冲区低水位标记**的当前大小，并且或者该套接字已连接，或者该套接字不需要连接（如UDP套接字）

接收低水位标记和发送低水位标记的目的在于：**延迟就绪**（自己总结的）。举例来说，如果我们知道除非至少存在64个字节的数据，否则我们的应用进程没有任何有效工作可做，那么可以把接收低水位标记设置为64，以防少于64个字节的数据准备好读时select唤醒我们。

#### 例子

fileno函数把标准I/O文件指针转换为对应的描述符。select（和poll）只工作在描述符上

计算出两个描述符中的较大值后，调用select。在该调用中，写集合指针和异常集合指针都是空指针。最后一个参数（时间限制）也是空指针，因为我们希望本调用阻塞到某个描述符就绪为止

```c++
#include "unp.h"
void str_cli(FILE *fp, int sockfd)
{
    int maxfdp1;
    fd_set rset;
    char sendline[MAXLINE], recvline[MAXLINE];

    FD_ZERO(&rset);
    for ( ; ; ) {
        FD_SET(fileno(fp), &rset);
        FD_SET(sockfd, &rset);
        maxfdp1 = max(fileno(fp), sockfd) + 1;
        Select(maxfdp1, &rset, NULL, NULL, NULL);

        if (FD_ISSET(sockfd, &rset)) { /* socket is readable */
            if (Readline(sockfd, recvline, MAXLINE) == 0)
                err_quit("str_cli: server terminated prematurely");
            Fputs(recvline, stdout);
        }

        if (FD_ISSET(fileno(fp), &rset)) {  /* input is readable */
            if (Fgets(sendline, MAXLINE, fp) == NULL)
                return; /* all done */
            Writen(sockfd, sendline, strlen(sendline));
        }
    }
}
```

我们只需要一个用于检查可读性的描述符集。该集合由FD_ZERO初始化，并用FD_SET打开两位：一位对应于标准I/O文件指针fp，一位对应于套接字sockfd。fileno函数把标准I/O文件指针转换为对应的描述符。select（和poll）只工作在描述符上。

计算出两个描述符中的较大值后，调用select。在该调用中，写集合指针和异常集合指针都是空指针。最后一个参数（时间限制）也是空指针，因为我们希望本调用阻塞到某个描述符就绪为止。

如果在select返回时套接字是可读的，那就先用readline读入回射文本行，再用fputs输出它。

如果标准输入可读，那就先用fgets读入一行文本，再用writen把它写到套接字中。

这个例子有个bug，如果在标准输入中输入EOF，则str_cli就此返回，但这时套接字的读入并没有完成，所以这就需要用一种方法来关闭TCP连接其中一半，也就是下面的shutdown函数，它会给服务器发送FIN，说明自己已完成数据发送，但仍然保持套接字打开以便读取。

值得一提的是，混合使用stdio和select非常容易犯错误，必须极其小心

### shutdown函数

close有两个限制可以用shutdown函数避免

1. close把描述符的引用计数减1，仅在该计数变为0时才关闭套接字，当有父子进程共享套接字描述符时，得所有进程都close后才会使得引用计数为0，才会发送FIN。使用shutdown可以不管引用计数就激发TCP的正常连接终止序列（TCP四次挥手）。
2. close终止读和写两个方向的数据传送。既然TCP连接是全双工的，有时候我们需要告知对端我们已经完成了数据发送，即使对端仍有数据要发送给我们

```c
#include <sys/socket.h>
int shutdown(int sockfd, int howto);
// 返回：若成功则为0，若出错则为-1
```

该函数的行为依赖于howto参数的值，0（关闭读半部）、1（关闭写半部）和2（读半部和写半部都关闭）
。

1. SHUT_RD　关闭连接的读这一半——套接字中不再有数据可接收，而且套接字接收缓冲区中的现有数据都被丢弃。进程不能再对这样的套接字调用任何读函数。对一个TCP套接字这样调用shutdown函数后，由该套接字接收的来自对端的任何数据都被确认，然后悄然丢弃。
2. SHUT_WR　关闭连接的写这一半——对于TCP套接字，这称为半关闭（half-close，见TCPv1的18.5节）。当前留在套接字发送缓冲区中的数据将被发送掉，后跟TCP的正常连接终止序列（应该就是FIN吧）。不管套接字描述符的引用计数是否等于0，这样的写半部关闭照样执行。进程不能再对这样的套接字调用任何写函数。
3. SHUT_RDWR　连接的读半部和写半部都关闭——这与调用shutdown两次等效：第一次调用指定SHUT_RD，第二次调用指定SHUT_WR。

#### 修改版的例子

```c++
#include "unp.h"

void
str_cli(FILE *fp, int sockfd)
{
    int maxfdp1, stdineof;
    fd_set rset;
    char buf[MAXLINE];
    int n;

    stdineof = 0;
    FD_ZERO(&rset);
    for ( ; ; ) {
        if (stdineof == 0)
            FD_SET(fileno(fp), &rset);
        FD_SET(sockfd, &rset);
        maxfdp1 = max(fileno(fp), sockfd) + 1;
        Select(maxfdp1, &rset, NULL, NULL, NULL);

        if (FD_ISSET(sockfd, &rset)) { /* socket is readable */
            if ( (n = Read(sockfd, buf, MAXLINE)) == 0) {
                if (stdineof == 1)
                    return; /* normal termination */
                else
                    err_quit("str_cli: server terminated prematurely");
            }

            Write(fileno(stdout), buf, n);
        }

        if (FD_ISSET(fileno(fp), &rset)) {  /* input is readable */
            if ( (n = Read(fileno(fp), buf, MAXLINE)) == 0) {
                stdineof = 1;
                Shutdown(sockfd, SHUT_WR); /* send FIN */
                FD_CLR(fileno(fp), &rset);
                continue;
            }

            Writen(sockfd, buf, n);
        }
    }
}
```

stdineof是一个初始化为0的新标志。只要该标志为0，每次在主循环中我们总是select标准输入的可读性。

当我们在套接字上读到EOF时，如果我们已在标准输入上遇到EOF，那就是正常的终止，于是函数返回；但是如果我们在标准输入上没有遇到EOF，那么服务器进程已过早终止。我们改用read和write对缓冲区而不是文本行进行操作，使得select能够如期地工作。

当我们在标准输入上碰到EOF时，我们把新标志stdineof置为1，并把第二个参数指定为SHUT_WR来调用shutdown以发送FIN。这儿我们也改用read和write对缓冲区而不是文本行进行操作

### 使用select的TCP回射服务器程序

unpv13e/tcpcliserv/tcpservselect01.c

![code.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/code.png)

如果监听套接字变为可读，那么已建立了一个新的连接。我们调用accept并相应地更新数据结构，使用client数组中的第一个未用项记录这个已连接描述符。就绪描述符数目减1，若其值变为0，就可以避免进入下一个for循环。这样做让我们可以使用select的返回值来避免检查未就绪的描述符

对于每个现有的客户连接，我们要测试其描述符是否在select返回的描述符集中。如果是就从该客户读入一行文本并回射给它。如果该客户关闭了连接，那么read将返回0，我们于是相应地更新数据结构。
我们从不减少maxi的值，不过每次有客户关闭其连接时，我们可以检查是否存在这样的可能性。

该程序避免了为每个客户创建一个新进程的所有开销，因而是一个使用select的精彩例子

当一个服务器在处理多个客户时，它绝对不能阻塞于只与单个客户相关的某个函数调用。否则可能导致服务器被挂起，拒绝为所有其他客户提供服务。这就是所谓的**拒绝服务（denial of service）型攻击**。它就是针对服务器做些动作，导致服务器不再能为其他合法客户提供服务。可能的解决办法包括：使用非阻塞式I/O；让每个客户由单独的控制线程提供服务（例如创建一个子进程或一个线程来服务每个客户）；对I/O操作设置一个超时。

### pselect函数

```c
#include <sys/select.h>
#include <signal.h>
#include <time.h>
int pselect(int maxfdp1, fd_set *readset, fd_set *writeset, fd_set *exceptset,
　　　　　　 const struct timespec *timeout, const sigset_t *sigmask);
// 返回：若有就绪描述符则为其数目，若超时则为0，若出错则为-1
```

增加了第六个参数：一个指向信号掩码的指针。该参数允许程序先禁止递交某些信号，再测试由这些当前被禁止信号的信号处理函数设置的全局变量，然后调用pselect，告诉它重新设置信号掩码

以后再详细讨论

### poll函数

poll提供的功能与select类似，不过在处理流设备时，它能够提供额外的信息。

```c
#include <poll.h>
int poll(struct pollfd *fdarray, unsigned long nfds, int timeout);
// 返回：若有就绪描述符则为其数目，若超时则为0，若出错则为-1
```

第一个参数fdarray是指向一个结构数组第一个元素的指针。每个数组元素都是一个pollfd结构，用于指定测试某个给定描述符fd的条件。

```c
struct pollfd {
　　int    fd;　　　　　　 /* descriptor to check */
　　short  events;　　　　 /* events of interest on fd */
　　short  revents;　　　　/* events that occurred on fd */
};
```

要测试的条件由events成员指定，函数在相应的revents成员中返回该描述符的状态。（每个描述符都有两个变量，一个为调用值，另一个为返回结果，从而避免使用值—结果参数。回想select函数的中间三个参数都是值—结果参数。）这两个成员中的每一个都由指定某个特定条件的一位或多位构成

poll识别三类数据：普通（normal）、优先级带（priority band）和高优先级（high priority）。这些术语均出自基于流的实现

POLLIN可被定义为POLLRDNORM和POLLRDBAND的逻辑或。类似地，POLLOUT等同于POLLWRNORM，前者早于后者

第二个参数nfds指定了结构数组中元素的个数

第三个参数timeout指定poll函数返回前等待多长时间，毫秒数，为0的话则立即返回不阻塞进程，为INFTIM（已经定义好的一个负值）的话永远等待，其他等待指定的毫秒数

当发生错误时，poll函数的返回值为-1，若定时器到时之前没有任何描述符就绪，则返回0，否则返回**就绪描述符的个数，即revents成员值非0的描述符个数**。

### 使用poll的TCP回射服务器程序

unpv13e/tcpcliserv/tcpservpoll01.c

![tcpservpoll01.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/tcpservpoll01.png)

我们把client数组的第一项用于监听套接字，并把其余各项的描述符成员置为-1。我们还给第一项设置POLLRDNORM事件，这样当有新的连接准备好被接受时poll将通知我们。maxi变量含有client数组当前正在使用的最大下标值

我们调用poll以等待新的连接或者现有连接上有数据可读。当一个新的连接被接受后，我们在client数组中查找第一个描述符成员为负的可用项。注意，我们从下标1开始搜索，因为client[0]固定用于监听套接字。找到一个可用项之后，我们把新连接的描述符保存到其中，并设置POLLRDNORM事件。

我们检查的两个返回事件是POLLRDNORM和POLLERR。其中我们并没有在event成员中设置第二个事件，因为它在条件成立时总是返回。我们检查POLLERR的原因在于：有些实现在一个连接上接收到RST时返回的是POLLERR事件，而其他实现返回的只是POLLRDNORM事件。不论哪种情形，我们都调用read，当有错误发生时，read将返回这个错误。当一个现有连接由它的客户终止时，我们就把它的fd成员置为-1

## 第7章 套接字选项

### getsockopt和sesockopt函数

这两个函数仅用于套接字。

```c
#include <sys/socket.h>
int getsockopt(int sockfd, int level, int optname, void *optval, socklen_t *optlen);
int setsockopt(int sockfd, int level, int optname, const void *optval,
　　　　　　　　socklen_t optlen);
// 均返回：若成功则为0，若出错则为-1
```

其中sockfd必须指向一个打开的套接字描述符，level（级别）指定系统中解释选项的代码或为通用套接字代码，或为某个特定于协议的代码（例如IPv4、IPv6、TCP或SCTP）。

optval是一个指向某个变量（`*optval`）的指针，setsockopt从`*optval`中取得选项待设置的新值，getsockopt则把已获取的选项当前值存放到*optval中。`*optval`的大小由最后一个参数指定，它对于setsockopt是一个值参数，对于getsockopt是一个值—结果参数。

套接字选项粗分为两大基本类型：一是启用或禁止某个特性的二元选项（称为标志选项），二是取得并返回我们可以设置或检查的特定值的选项（称为值选项）。标有“标志”的列指出一个选项是否为标志选项。当给这些标志选项调用getsockopt函数时，`*optval`是一个整数。`*optval`中返回的值为0表示相应选项被禁止，不为0表示相应选项被启用。类似地，setsockopt函数需要一个不为0的`*optval`值来启用选项，一个为0的`*optval`值来禁止选项。如果“标志”列不含有“· ”，那么相应选项用于在用户进程与系统之间传递所指定数据类型的值。

unpv13e/sockopt/checkopts.c文件检查当前系统对于这些选项是否支持，若是则输出它们的默认值

### 通用套接字选项

#### SO_BROADCAST套接字选项

本选项开启或禁止进程发送广播消息的能力。只有数据报套接字支持广播，并且还必须是在支持广播消息的网络上（例如以太网、令牌环网等）。我们不可能在点对点链路上进行广播，也不可能在基于连接的传输协议（例如TCP和SCTP）之上进行广播。

由于应用进程在发送广播数据报之前必须设置本套接字选项，因此它能够有效地防止一个进程在其应用程序根本没有设计成可广播时就发送广播数据报。举例来说，一个UDP应用程序可能以命令行参数的形式取得目的IP地址，不过它并不期望用户键入一个广播地址。处理方法并非让应用进程来确定一个给定地址是否为广播地址，而是在内核中进行测试：如果该目的地址是一个广播地址且本套接字选项没有设置，那么返回EACCES错误

#### SO_DEBUG套接字选项

本选项仅由TCP支持。当给一个TCP套接字开启本选项时，内核将为TCP在该套接字发送和接收的所有分组保留详细跟踪信息。这些信息保存在内核的某个环形缓冲区中，并可使用trpt程序进行检查。

####　SO_DONTROUTE套接字选项

本选项规定外出的分组将绕过底层协议的正常路由机制。举例来说，在IPv4情况下外出分组将被定向到适当的本地接口，也就是由其目的地址的网络和子网部分确定的本地接口。如果这样的本地接口无法由目的地址确定（譬如说目的地主机不在一个点对点链路的另一端，也不在一个共享的网络上），那么返回ENETUNREACH错误。

路由守护进程（routed和gated）经常使用本选项来绕过路由表（路由表不正确的情况下），以强制将分组从特定接口送出。

#### SO_ERROR套接字选项（常用）

当一个套接字上发生错误时，该套接字的名为so_error的变量设为标准的Unix Exxx值中的一个，我们称它为该套接字的**待处理错误（pending error）**。内核能够以下面两种方式之一立即通知进程这个错误。

1. 如果进程阻塞在对该套接字的select调用上，那么无论是检查可读条件还是可写条件，select均返回并设置其中一个或所有两个条件。
2. 如果进程使用信号驱动式I/O模型（第25章），那就给进程或进程组产生一个SIGIO信号。进程然后可以通过访问SO_ERROR套接字选项获取so_error的值。由getsockopt返回的整数值就是该套接字的待处理错误。so_error随后由内核复位为0

SO_ERROR是可以获取但不能设置的套接字选项

#### SO_KEEPALIVE套接字选项（常用）

给一个TCP套接字设置**保持存活（keep-alive）**选项后，如果2小时内在该套接字的任一方向上都没有数据交换，TCP就自动给对端发送一个**保持存活探测分节/探针（keep-alive probe）**。这是一个对端必须响应的TCP分节，它会导致以下三种情况之一。

1. 对端以期望的ACK响应。本端进程无变化。在又经过仍无动静的2小时后，TCP将发出另一个探测分节。
2. 对端以RST响应，它告知本端TCP：对端已崩溃且已重新启动。该套接字的待处理错误被置为ECONNRESET，套接字本身则被关闭。
3. 对端对保持存活探测分节没有任何响应。该套接字的待处理错误就被置为ETIMEOUT，套接字本身被关闭。源自Berkeley的TCP将另外发送8个探测分节，两两相隔75秒，试图得到一个响应。TCP在发出第一个探测分解后11分15秒内若没有得到任何响应则放弃。

keep-alive最主要的功能是其实不是keep-alive，而是切断（make-dead），因为它有可能终止存活的连接

本选项一般由服务器使用，因为客户有可能主机掉线、断电或系统崩溃，而服务器永远也不知道，这种情况叫**半开连接**，本选项可以检测出这些半开连接并终止它们

SCTP有与TCP保持存活机制类似的**心跳（heartbeat）机制**

#### SO_LINGER套接字选项——控制close函数返回时机

本选项指定close函数对面向连接的协议（例如TCP和SCTP，但不是UDP）如何操作。默认操作是close立即返回，但是如果有数据残留在套接字发送缓冲区中，系统将试着把这些数据发送给对端。

SO_LINGER套接字选项使得我们可以改变这个默认设置。本选项要求在用户进程与内核间传递如下结构，它在头文件`<sys/socket.h>`中定义：

```c
struct linger {
　int　 l_onoff;　　　　/* 0=off, nonzero=on */
　int　 l_linger;　　　　/* linger time, POSIX specifies units as seconds */
};
```

对setsockopt的调用将根据其中两个结构成员的值形成下列3种情形之一。

1. 如果l_onoff为0，那么关闭本选项。l_linger的值被忽略，先前讨论的TCP默认设置生效，即close立即返回。
2. 如果l_onoff为非0值且l_linger为0，那么当close某个连接时TCP将中止该连接。这就是说TCP将丢弃保留在套接字发送缓冲区中的任何数据，并发送一个RST给对端，而没有通常的四分组连接终止序列（不是正常四次挥手）
3. 如果l_onoff为非0值且l_linger也为非0值，那么当套接字关闭时内核将拖延一段时间。这就是说如果在套接字发送缓冲区中仍残留有数据，那么进程将被投入睡眠，直到（a）所有数据都已发送完且均被对方确认或（b）延滞时间到。

当关闭连接的本地端（客户端）时，根据所调用的函数（close或shutdown）以及是否设置了SO_LINGER套接字选项，可在以下3个不同的时机返回。

1. close立即返回，根本不等待（默认状况）。
2. close一直拖延到接收了对于客户端FIN的ACK才返回（设置SO_LINGER套接字选项，指定一个正的延滞时间）。
3. 后跟一个read调用的shutdown一直等到接收了对端的FIN才返回（调用shutdown并设置它的第二个参数为SHUT_WR）。

本地虽然收到了对端的ACK，但是不知道对端是否已读取完毕，这可以用**应用级确认**完成。在下面的例子中，客户在向服务器发送数据后调用read来读取1个字节的数据：

```c
char ack;
Write(sockfd, data, nbytes);　　　　　/* data from client to server */
n = Read(sockfd, &ack, 1);　　　　　　/* wait for application-level ACK */
```

服务器读取来自客户的数据后发回1个字节的应用级ACK：

```c
nbytes = Read(sockfd, buff, sizeof(buff));　　/* data from client */
　　　　 /* server verifies it received correct
　　　　　　amount of data from the client */
Write(sockfd, "", 1);　　　　　　　　/* server's ACK back to client */
```

当客户的read返回时，我们可以保证服务器进程已读完了我们所发送的所有数据。（假设服务器知道客户要发送多少数据，或者由应用程序定义了某个记录结束标志，不过这儿没有给出。）本例子的应用级ACK是值为0的1个字节，不过该字节的内容可以用来从服务器向客户指示其他的条件

#### SO_OOBINLINE套接字选项

#### SO_RCVBUF和SO_SNDBUF套接字选项（常用）

每个套接字都有一个发送缓冲区和一个接收缓冲区

接收缓冲区用来保存接收到的数据，直到应用进程来读取。对于TCP，TCP套接字接收缓冲区不可能溢出，因为不允许对端发出超过本端所通告窗口大小的数据。这就是TCP的流量控制，如果对端无视窗口大小而发出了超过该窗口大小的数据，本端TCP将丢弃它们。然而对于UDP来说，当接收到的数据报装不进套接字接收缓冲区时，该数据报就被丢弃。回顾一下，UDP是没有流量控制的：较快的发送端可以很容易地淹没较慢的接收端，导致接收端的UDP丢弃数据报。

这两个套接字选项允许我们改变这两个缓冲区的默认大小。对于不同的实现，默认值的大小可以有很大的差别。

设置缓冲区大小时，函数调用顺序很重要，这是因为TCP的窗口规模选项是在建立连接时用SYN分节与对端互换得到的。对于客户，这意味着SO_RCVBUF选项必须在调用connect之前设置；对于服务器，这意味着该选项必须在调用listen之前给监听套接字设置。**给已连接套接字设置该选项对于可能存在的窗口规模选项没有任何影响，套接字缓冲区大小总是由新创建的已连接套接字从监听套接字继承而来**

#### SO_RCVLOWAT和SO_SNDLOWAT套接字选项

每个套接字还有一个接收低水位标记和一个发送低水位标记。它们由select函数使用。这两个套接字选项允许我们修改这两个低水位标记。

接收低水位标记是让select触发（原文是返回，我觉得不好）“可读”时套接字接收缓冲区中所需的数据量。对于TCP、UDP和SCTP套接字，其默认值为1。发送低水位标记是让select（原文是返回，我觉得不好）“可写”时套接字发送缓冲区中所需的可用空间。对于TCP套接字，其默认值通常为2048。UDP也使用发送低水位标记，然而由于UDP并不为由应用进程传递给它的数据报保留副本，即没有缓冲区，但是有缓冲区大小，只要发送缓冲区大小大于该套接字的低水位标记，UDP套接字就总是可写的。

#### SO_RCVTIMEO和SO_SNDTIMEO套接字选项

这两个选项允许我们给套接字的接收和发送设置一个超时值。注意，访问它们的getsockopt和setsockopt函数的参数是指向timeval结构的指针，与select所用参数相同。这可让我们用秒数和微秒数来规定超时。我们通过设置其值为0s和0s来禁止超时。默认情况下这两个超时都是禁止的。

接收超时影响5个输入函数：read、readv、recv、recvfrom和recvmsg。发送超时影响5个输出函数：write、writev、send、sendto和sendmsg。

#### SO_REUSEADDR（常用）和SO_REUSEPORT套接字选项

SO_REUSEADDR套接字选项能起到以下4个不同的功用。

1. SO_REUSEADDR允许启动一个监听服务器并捆绑其众所周知端口，即使以前建立的将该端口用作它们的本地端口的连接仍存在。设想这样一个场景：子进程还在继续为客户提供服务时，监听服务器终止，重启后要重新bind连接，如果没有开启SO_REUSEADDR，bind失败。**所有TCP服务器都应该开启SO_REUSEADDR套接字选项**
2. SO_REUSEADDR允许在同一端口上启动同一服务器的多个实例，只要每个实例捆绑一个不同的本地IP地址即可。对于TCP，我们绝不可能启动捆绑相同IP地址和相同端口号的多个服务器：这是**完全重复的捆绑（completely duplicate binding）**
3. SO_REUSEADDR允许单个进程捆绑同一端口到多个套接字上，只要每次捆绑指定不同的本地IP地址即可
4. SO_REUSEADDR允许**完全重复的捆绑**：当一个IP地址和端口已绑定到某个套接字上时，如果传输协议支持，同样的IP地址和端口还可以捆绑到另一个套接字上。一般来说，本特性仅支持UDP套接字。

#### SO_TYPE套接字选项

本选项返回套接字的类型，返回的整数值是一个诸如SOCK_STREAM或SOCK_DGRAM之类的值。本选项通常由启动时继承了套接字的进程使用。

#### SO_USELOOPBACK套接字选项

### IPv4套接字选项

#### IP_HDRINCL套接字选项

如果本选项是给一个原始IP套接字设置的，那么我们必须为所有在该原始套接字上发送的数据报构造自己的IP首部。一般情况下，在原始套接字上发送的数据报其IP首部是由内核构造的，不过有些应用程序（特别是路由跟踪程序traceroute）需要构造自己的IP首部以取代IP置于该首部中的某些字段

#### IP_OPTIONS套接字选项

本选项允许我们在IPv4首部中设置IP，这要求我们熟悉IP的格式

#### IP_REDVDSTADDR套接字选项

#### IP_RECVIF套接字选项

#### IP_TOS套接字选项

本套接字选项允许我们为TCP、UDP或SCTP套接字设置IP首部中的服务类型字段

#### IP_TTL套接字选项

我们可以使用本选项设置或获取系统用在从某个给定套接字发送的单播分组上的默认TTL值。多播TTL值使用IP_MULTICAST_TTL套接字选项设置。TCP、UDP套接字的默认值是64，原始套接字使用的默认值则是255

### ICMPv6套接字选项——ICMP6_FILTER

这个唯一的套接字选项由ICMPv6处理，它的级别（即getsockopt和setsockopt函数的第二个参数）为IPPROTO_ICMPV6。

本选项允许我们获取或设置一个icmp6_filter结构，该结构指出256个可能的ICMPv6消息类型中哪些将经由某个原始套接字传递给所在进程。

### IPv6套接字选项

这些套接字选项由IPv6处理，它们的级别（即getsockopt和setsockopt函数的第二个参数）为IPPROTO_IPV6

#### IPV6_CHECKSUM套接字选项

本选项指定用户数据中校验和所处位置的字节偏移。如果该值为非负，那么内核将：（i）给所有外出分组计算并存储校验和；（ii）验证外来分组的校验和，丢弃所有校验和无效的分组。如果指定本选项的值为-1（默认值），那么内核不会在相应的原始套接字上计算并存储外出分组的校验和，也不会验证外来分组的校验和。

#### IPV6_DONTFRAG套接字选项

开启本选项将禁止为UDP套接字或原始套接字自动插入分片首部，外出分组中大小超过发送接口MTU的那些分组将被丢弃。发送分组的系统调用不会为此返回错误，因为已发送出去仍在途中的分组也可能因为超过路径MTU而被丢弃

#### IPV6_NEXTHOP套接字选项

本选项将外出数据报的下一跳地址指定为一个套接字地址结构。这是一个特权操作。

#### IPV6_PATHMTU套接字选项

本选项不能设置，只能获取。获取本选项时，返回值为由路径MTU发现功能确定的当前MTU。

#### IPV6_RECVDSTOPTS套接字选项

开启本选项表明，任何接收到的IPv6目的地选项都将由recvmsg作为辅助数据返回。本选项默认为关闭。

#### IPV6_RECVHOPLIMIT套接字选项

开启本选项表明，任何接收到的跳限字段都将由recvmsg作为辅助数据返回。本选项默认为关闭。对IPv4而言，没有办法可以获取接收到的TTL字段。

#### IPV6_RECVHOPOPTS套接字选项

开启本选项表明，任何接收到的IPv6步跳选项都将由recvmsg作为辅助数据返回。本选项默认为关闭。

#### IPV6_RECVPATHMTU套接字选项

#### blablabla

### TCP套接字选项

级别为IPPROTO_TCP

#### TCP_MAXSEG套接字选项

本选项允许我们获取或设置TCP连接的最大分节大小（MSS）。返回值是我们的TCP可以发送给对端的最大数据量，它通常是由对端使用SYN分节通告的MSS，除非我们的TCP选择使用一个比对端通告的MSS小些的值

#### TCP_NODELAY套接字选项——禁止Nagle算法

开启本选项将禁止TCP的**Nagle算法**。默认情况下该算法是启动的。

Nagle算法的目的在于减少广域网（WAN）上小分组的数目（即**糊涂窗口综合征**）。该算法指出：如果某个给定连接上有**待确认数据**（outstanding data，即已发送但未确认的数据），那么原本应该作为用户写操作之响应的在该连接上立即发送相应小分组的行为就不会发生，直到现有数据被确认为止。这里“小”分组的定义就是小于MSS的任何分组。TCP总是尽可能地发送最大大小的分组，Nagle算法的目的在于防止一个连接在任何时刻有多个小分组待确认。

> 拓展：Nagle算法的基本定义是任意时刻，最多只能有一个未被确认的小段。 所谓“小段”，指的是小于MSS尺寸的数据块，所谓“未被确认”，是指一个数据块发送出去后，没有收到对方发送的ACK确认该数据已收到。

Nagle算法常常与另一个TCP算法联合使用：**ACK延滞算法（delayed ACK algorithm）**。该算法使得TCP在接收到数据后不立即发送ACK，而是等待一小段时间（典型值为50～200ms），然后才发送ACK。TCP期待在这一小段时间内自身有数据发送回对端，被延滞的ACK就可以由这些数据捎带，从而省掉一个TCP分节。

然而对于其服务器不在相反方向产生数据以便携带ACK的客户来说，ACK延滞算法存在问题。这些客户可能觉察到明显的延迟，因为客户TCP要等到服务器的ACK延滞定时器超时才继续给服务器发送数据。这些客户需要一种禁止Nagle算法的方法，TCP_NODELAY选项就能起到这个作用。

### SCTP套接字选项

数目相对较多的SCTP套接字选项（编写本书时为17个）反映出SCTP为应用程序开发人员提供了较细粒度的控制能力。它们的级别（即getsockopt和setsockopt函数的第二个参数）为IPPROTO_SCTP

SCTP提供了17个应用程序用来控制传输的套接字选项。SCTP_NODELAY和SCTP_MAXSEG选项与TCP_NODELAY和TCP_MAXSEG选项类似，并有着相同的功能。而其他15个选项为应用程序带来了对SCTP栈的更佳控制

blablabla

### fdntl函数

与代表“file control”（文件控制）的名字相符，fcntl函数可执行各种描述符控制操作，提供了与网络编程相关的如下特性。

1. 非阻塞式I/O。通过使用F_SETFL命令设置O_NONBLOCK文件状态标志，我们可以把一个套接字设置为非阻塞型。
2. 信号驱动式I/O。通过使用F_SETFL命令设置O_ASYNC文件状态标志，我们可以把一个套接字设置成一旦其状态发生变化，内核就产生一个SIGIO信号。
3. F_SETOWN命令允许我们指定用于接收SIGIO和SIGURG信号的套接字属主（进程ID或进程组ID）。其中SIGIO信号是套接字被设置为信号驱动式I/O型后产生的，SIGURG信号是在新的带外数据到达套接字时产生的。F_GETOWN命令返回套接字的当前属主。

术语“**套接字属主**”由POSIX定义。历史上源自Berkeley的实现称之为“套接字的进程组ID”，因为存放该ID的变量是socket结构的so_pgid成员。
使用socket函数新创建的套接字并没有属主。然而如果一个新的套接字是从一个监听套接字创建来的，那么套接字属主将由已连接套接字从监听套接字继承而来

```c
#include <fcntl.h>
int fcntl(int fd, int cmd, ... /* int arg */ );
// 返回：若成功则取决于cmd，若出错则为-1
```

每种描述符（包括套接字描述符）都有一组由F_GETFL命令获取或由F_SETFL命令设置的文件标志。其中影响套接字描述符的两个标志是：
O_NONBLOCK——非阻塞式I/O；
O_ASYNC——信号驱动式I/O。

设置某个文件状态标志的唯一正确的方法是：先取得当前标志，与新标志逻辑或后再设置标志。使用fcntl开启非阻塞式I/O的典型代码将是：

```c++
int　　flags;
　　/* Set a socket as nonblocking */
if ( (flags = fcntl(fd, F_GETFL, 0)) < 0)
　　err_sys("F_GETFL error");
flags ｜= O_NONBLOCK;
if (fcntl(fd, F_SETFL, flags) < 0)
　　err_sys("F_SETFL error");
```

而下面这段代码在设置非阻塞标志的同时也清除了所有其他文件状态标志，所以是错的。

```c++
　　/* Wrong way to set a socket as nonblocking */
if (fcntl(fd, F_SETFL, O_NONBLOCK) < 0)
　　err_sys("F_SETFL error");
```

以下代码关闭非阻塞标志，其中假设flags是由上面所示的fcntl调用来设置的：

```c++
flags &= ~O_NONBLOCK;
if (fcntl(fd, F_SETFL, flags) < 0)
　　err_sys("F_SETFL error");
```

## 第8章 基本UDP套接字编程

在使用TCP编写的应用程序和使用UDP编写的应用程序之间存在一些本质差异，其原因在于：UDP是无连接不可靠的数据报协议，非常不同于TCP提供的面向连接的可靠字节流。然而相比TCP，有些场合确实更适合使用UDP：DNS（域名系统）、NFS（网络文件系统）和SNMP（简单网络管理协议）。

客户不与服务器建立连接，而是只管使用sendto函数给服务器发送数据报，其中必须指定目的地（即服务器）的地址作为参数。类似地，服务器不接受来自客户的连接，而是只管调用recvfrom函数，等待来自某个客户的数据到达。客户发送完后调用recvfrom等待响应，服务器接收到客户的数据后处理请求，然后调用sendto发送响应

### UDP中的recvfrom和sendto函数

这两个函数类似于标准的read和write函数，不过需要三个额外的参数。

```c
#include <sys/socket.h>
ssize_t recvfrom(int sockfd, void *buff, size_t nbytes, int flags, struct sockaddr *from, socklen_t *addrlen);
ssize_t sendto(int sockfd, const void *buff, size_t nbytes, int flags, const struct sockaddr *to, socklen_t *addrlen); // 书本这里是不是写错了？最后一个参数应该是int型吧
// 均返回：若成功则为读或写的字节数，若出错则为-1
```

前三个参数sockfd、buff和nbytes等同于read和write函数的三个参数：描述符、指向读入或写出缓冲区的指针和读写字节数。

flags参数将在第14章中讨论recv、send、recvmsg和sendmsg等函数时再介绍，本章中重写简单的UDP回射客户/服务器程序用不着它们。时下我们总是把flags置为0。

sendto的to参数指向一个含有数据报接收者的协议地址（例如IP地址及端口号）的套接字地址结构，其大小由addrlen参数指定。recvfrom的from参数指向一个将由该函数在返回时填写数据报发送者的协议地址的套接字地址结构，而在该套接字地址结构中填写的字节数则放在addrlen参数所指的整数中返回给调用者。注意，sendto的最后一个参数是一个整数值(书本中上面的例子是不是写错了，我在网上查阅资料发现sendto的最后一个参数是一个int型)，而recvfrom的最后一个参数是一个指向整数值的指针（即值-结果参数）。

recvfrom的最后两个参数类似于accept的最后两个参数：返回时其中套接字地址结构的内容告诉我们是谁发送了数据报（UDP情况下）或是谁发起了连接（TCP情况下）。sendto的最后两个参数类似于connect的最后两个参数：调用时其中套接字地址结构被我们填入数据报将发往（UDP情况下）或与之建立连接（TCP情况下）的协议地址

这两个函数都把**所读写数据的长度作为函数返回值**。在recvfrom使用数据报协议的典型用途中，返回值就是所接收数据报中的用户数据量。

**写一个长度为0的数据报是可行的**。在UDP情况下，这会形成一个只包含一个IP首部（对于IPv4通常为20个字节，对于IPv6通常为40个字节）和一个8字节UDP首部而没有数据的IP数据报。这也意味着对于数据报协议，**recvfrom返回0值是可接受的**：它并不像TCP套接字上read返回0值那样表示对端已关闭连接。既然UDP是无连接的，因此也就没有诸如关闭一个UDP连接之类事情。

如果recvfrom的from参数是一个空指针，那么相应的长度参数（addrlen）也必须是一个空指针，表示我们并**不关心数据发送者的协议地址**。当然sendto的to参数必须要有效。

recvfrom和sendto都可以用于TCP，尽管通常没有理由这样做。

### UDP回射服务器程序

现在用UDP重新编写第五章的简单回射客户/服务器程序

```c++
#include "unp.h"

int
main(int argc, char **argv)
{
    int sockfd;
    struct sockaddr_in servaddr, cliaddr;

    sockfd = Socket(AF_INET, SOCK_DGRAM, 0);

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family      = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port        = htons(SERV_PORT);

    Bind(sockfd, (SA *) &servaddr, sizeof(servaddr));

    dg_echo(sockfd, (SA *) &cliaddr, sizeof(cliaddr));
}
```

将socket函数的第二个参数指定为SOCK_DGRAM（IPv4协议中的数据报套接字）创建一个UDP套接字。正如TCP服务器程序的例子，用于bind的服务器IPv4地址被指定为INADDR_ANY，而服务器的众所周知端口是头文件`<unp.h>`中定义的SERV_PORT常值。

接着，调用函数dg_echo来执行服务器的处理工作。

```c++
#include "unp.h"

void
dg_echo(int sockfd, SA *pcliaddr, socklen_t clilen)
{
    int n;
    socklen_t len;
    char mesg[MAXLINE];

    for ( ; ; ) {
        len = clilen;
        n = Recvfrom(sockfd, mesg, MAXLINE, 0, pcliaddr, &len);

        Sendto(sockfd, mesg, n, 0, pcliaddr, len);
    }
}
```

该函数是一个简单的循环，它使用recvfrom读入下一个到达服务器端口的数据报，再使用sendto把它发送回发送者。

尽管这个函数很简单，不过也有许多细节问题需要考虑。首先，该函数永不终止，因为UDP是一个无连接的协议，它没有像TCP中EOF之类的东西。

其次，该函数提供的是一个**迭代服务器（iterative server）**，而不是像TCP服务器那样可以提供一个并发服务器。其中没有对fork的调用，因此单个服务器进程就得处理所有客户。**一般来说，大多数TCP服务器是并发的，而大多数UDP服务器是迭代的**。

对于本套接字，**UDP层中隐含有排队发生**。事实上每个UDP套接字都有一个接收缓冲区，到达该套接字的每个数据报都进入这个套接字接收缓冲区。当进程调用recvfrom时，缓冲区中的下一个数据报以FIFO（先入先出）顺序返回给进程。这样，在进程能够读该套接字中任何已排好队的数据报之前，如果有多个数据报到达该套接字，那么相继到达的数据报仅仅加到该套接字的接收缓冲区中。然而这个缓冲区的大小是有限的。我们已在第7章的SO_RCVBUF套接字选项讨论了这个大小以及如何增大它。

服务器端的main函数是协议相关的（它创建一个AF_INET协议的套接字，分配并初始化一个IPv4套接字地址结构），而dg_echo函数是协议无关的。dg_echo协议无关的理由如下：调用者（在我们的例子中为main函数）必须分配一个正确大小的套接字地址结构，且指向该结构的指针和该结构的大小都必须作为参数传递给dg_echo。dg_echo绝不查看这个协议相关结构的内容，而是简单地把一个指向该结构的指针传递给recvfrom和sendto。recvfrom返回时把客户的IP地址和端口号填入该结构，而随后作为目的地址传递给sendto的又是同一个指针（pcliaddr），这样所接收的任何数据报就被回射给发送该数据报的客户

### UDP回射服务器客户程序

客户main函数没什么好说的，最后调用dg_cli函数

```c++
#include "unp.h"

int
main(int argc, char **argv)
{
    int sockfd;
    struct sockaddr_in servaddr;

    if (argc != 2)
        err_quit("usage: udpcli <IPaddress>");

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(SERV_PORT);
    Inet_pton(AF_INET, argv[1], &servaddr.sin_addr);

    sockfd = Socket(AF_INET, SOCK_DGRAM, 0);

    dg_cli(stdin, sockfd, (SA *) &servaddr, sizeof(servaddr));

    exit(0);
}
```

```c++
#include "unp.h"

void
dg_cli(FILE *fp, int sockfd, const SA *pservaddr, socklen_t servlen)
{
    int n;
    char sendline[MAXLINE], recvline[MAXLINE + 1];

    while (Fgets(sendline, MAXLINE, fp) != NULL) {

        Sendto(sockfd, sendline, strlen(sendline), 0, pservaddr, servlen);

        n = Recvfrom(sockfd, recvline, MAXLINE, 0, NULL, NULL);

        recvline[n] = 0; /* null terminate */
        Fputs(recvline, stdout);
    }
}
```

客户处理循环中有四个步骤：

1. 使用fgets从标准输入读入一个文本行
2. 使用sendto将该文本行发送给服务器
3. 使用recvfrom读回服务器的回射
4. 使用fputs把回射的文本行显示到标准输出。

客户未请求内核给它的套接字指派一个临时端口。（对于TCP客户而言，我们说过**首次调用connect**时正是这种指派发生之处。）对于一个UDP套接字，如果其进程**首次调用sendto**时它没有绑定一个本地端口，那么内核就在此时为它选择一个临时端口。跟TCP一样，客户可以显式地调用bind，不过很少这样做。

注意，调用recvfrom指定的第五和第六个参数是空指针。这告知内核我们并不关心应答数据报由谁发送。这样做存在一个风险：任何进程不论是在与本客户进程相同的主机上还是在不同的主机上，都可以向本客户的IP地址和端口发送数据报，这些数据报将被客户读入并被认为是服务器的问答，第8章将会解决这个问题

与服务器的dg_echo函数一样，客户的dg_cli函数也是协议无关的，不过客户的main函数是协议相关的。main函数分配并初始化一个某个协议类型的套接字地址结构，并把指向该结构的指针及该结构的大小传递给dg_cli。

### 数据报的丢失

刚才UDP客户/服务器是非常不可靠的，假设客户数据报丢失，则客户将永远阻塞于recvfrom，等待一个永远不可能到达的服务器应答。类似的，如果服务器的应答丢失了，客户也还是会永远阻塞于recvfrom。

最简单的方法是设置超时。但是这个超时无法判别是客户数据丢失还是服务器应答丢失，如果这个客户的请求是“从A账户转账一笔钱给B账户”，那这种丢失是极不相同的。

### 验证接收到的响应（有缺陷）

知道客户临时端口号的任何进程都可往客户发送数据报，而且这些数据报会与正常的服务器应答混杂。我们的解决办法是修改recvfrom调用以返回数据报发送者的IP地址和端口号，保留来自数据报所发往服务器的应答，而忽略任何其他数据报。然而这样做照样存在一些缺陷，我们马上就会看到。

```c++
#include "unp.h"

void
dg_cli(FILE *fp, int sockfd, const SA *pservaddr, socklen_t servlen)
{
    int n;
    char sendline[MAXLINE], recvline[MAXLINE + 1];
    socklen_t len;
    struct sockaddr *preply_addr;

    preply_addr = Malloc(servlen);

    while (Fgets(sendline, MAXLINE, fp) != NULL) {

        Sendto(sockfd, sendline, strlen(sendline), 0, pservaddr, servlen);

        len = servlen;
        n = Recvfrom(sockfd, recvline, MAXLINE, 0, preply_addr, &len);
        if (len != servlen || memcmp(pservaddr, preply_addr, len) != 0) {
            printf("reply from %s (ignored)\n",
                    Sock_ntop(preply_addr, len));
            continue;
        }

        recvline[n] = 0; /* null terminate */
        Fputs(recvline, stdout);
    }
}
```

我们调用malloc来分配另一个套接字地址结构。注意dg_cli函数仍然是协议无关的，因为我们并不关心所处理套接字地址结构的类型，而只是在malloc调用中使用其大小。

在recvfrom的调用中，我们通知内核返回数据报发送者的地址。我们首先比较由recvfrom在值-结果参数中返回的长度，然后用memcmp比较套接字地址结构本身。

即使套接字地址结构包含一个长度字段，我们也不必设置或检查它。然而此处memcmp比较两个套接字地址结构中的每个数据字节，而内核返回套接字地址结构时，其中长度字段是设置的；因此对于本例，与之比较的另一个套接字地址结构也必须预先设置其长度字段。否则，memcmp将比较一个值为0的字节（因为没有设置长度字段）和一个值为16的字节（假设具体为sockaddr_in结构），结果自然不匹配。

如果服务器运行在一个只有单个IP地址的主机上，那么这个新版本的客户工作正常。**然而如果服务器主机是多宿的，该客户就有可能失败**（我在我的mac上测试，客户可以得到服务器的回射，mac仅用wifi联网），这就是缺陷

### 服务器进程未运行

我们下一个要检查的情形是在不启动服务器的前提下启动客户。如果我们这么做后在客户上键入一行文本，那么什么也不发生。客户永远阻塞于它的recvfrom调用，等待一个永不出现的服务器应答

客户数据报发出，服务器主机响应的是一个"port unreach-able"（端口不可达）ICMP消息。不过这个ICMP错误不返回给客户进程，其原因我们稍后讲述。客户永远阻塞于recvfrom调用。

我们称这个ICMP错误为**异步错误（asynchronous error）**。该错误由sendto引起，但是sendto本身却成功返回。我们知道从UDP输出操作成功返回仅仅表示在接口输出队列中具有存放所形成IP数据报的空间。该ICMP错误直到后来才返回，这就是称其为异步的原因。

一个基本规则是：**对于一个UDP套接字，由它引发的异步错误并不返回给它，除非它已连接（调用connect）**，因为客户可能发送多个数据报，未连接的UDP套接字没法判别异步错误指的是哪个数据报ICMP错误，所以仅在进程已将其UDP套接字连接到恰恰一个对端后，这些异步错误才返回给进程

### UDP程序例子小结

客户必须给sendto调用指定服务器的IP地址和端口号。一般来说，客户的IP地址和端口号都由内核自动选择（第一次调用sendto时，不能改变），客户也可以调用bind指定它们。如果客户主机是多宿的，客户有可能在两个IP之间交替选择（假设未bind具体的IP）。如果客户捆绑了一个IP地址到其套接字上，但是内核决定外出数据报必须从另一个数据链路发出，IP数据报将包含一个不同于外出链路IP地址的源IP地址。

对于UDP套接字，目的IP地址只能通过为IPv4设置IP_RECVDSTADDR套接字选项（或为IPv6设置IPV6_PKTINFO套接字选项）然后调用recvmsg（而不是recvfrom）取得。由于UDP是无连接的，因此目的IP地址可随发送到服务器的每个数据报而改变。UDP服务器也可接收目的地址为服务器主机的某个广播地址或多播地址的数据报。

### UDP的connect函数

除非套接字已连接，否则异步错误是不会返回到UDP套接字的。我们确实可以给UDP套接字调用connect，然而这样做的结果却与TCP连接大相径庭：没有三路握手过程。内核只是检查是否存在立即可知的错误（例如一个显然不可达的目的地），记录对端的IP地址和端口号（取自传递给connect的套接字地址结构），然后立即返回到调用进程。

对于已连接UDP套接字，与默认的未连接UDP套接字相比，发生了三个变化。

1. 我们再也不能给输出操作指定目的IP地址和端口号。也就是说，我们不使用sendto，而改用write或send。写到已连接UDP套接字上的任何内容都自动发送到由connect指定的协议地址（例如IP地址和端口号）
2. 我们不必使用recvfrom以获悉数据报的发送者，而改用read、recv或recvmsg。并且该套接字只能接收特定对端的数据报，其他对端（IP或port不一致）的数据报可能会投递到同主机其他UDP套接字，如果没有匹配的，则丢弃它们并生成相应的ICMP端口不可达错误。
3. 由已连接UDP套接字引发的异步错误会返回给它们所在的进程，而未连接UDP套接字不接收任何异步错误

小结：UDP客户进程或服务器进程只在使用自己的UDP套接字与确定的唯一对端进行通信时，才可以调用connect。调用connect的通常是UDP客户，不过有些网络应用中的UDP服务器会与单个客户长时间通信（如TFTP），这种情况下，客户和服务器都可能调用connect。

#### 给一个UDP套接字多次调用connect

拥有一个已连接UDP套接字的进程可出于下列两个目的之一再次调用connect：

1. 指定新的IP地址和端口号：不同于TCP套接字中connect只使用一次，UDP的connect可以多次调用，这样可以改变对端
2. 断开套接字：为了断开一个已连接UDP套接字，我们再次调用connect时把套接字地址结构的地址族成员（对于IPv4为sin_family，对于IPv6为sin6_family）设置为AF_UNSPEC。这么做可能会返回一个EAFNOSUPPORT错误，不过没有关系。使套接字断开连接的是在已连接UDP套接字上调用connect的进程。

#### 性能

当应用进程在一个未连接的UDP套接字上调用sendto时，源自Berkeley的内核暂时连接该套接字，发送数据报，然后断开该连接当应用进程知道自己要给同一目的地址发送多个数据报时，显式连接套接字效率更高。

另一个考虑是搜索路由表的次数。第一次临时连接需为目的IP地址搜索路由表并高速缓存这条信息。第二次临时连接不必再次查找路由表（假设目的相同）。

### dg_cli函数（修订版）

unpv13e/udpcliserv/dgcliconnect.c

```c++
#include "unp.h"

void
dg_cli(FILE *fp, int sockfd, const SA *pservaddr, socklen_t servlen)
{
    int n;
    char sendline[MAXLINE], recvline[MAXLINE + 1];

    Connect(sockfd, (SA *) pservaddr, servlen);

    while (Fgets(sendline, MAXLINE, fp) != NULL) {

        Write(sockfd, sendline, strlen(sendline));

        n = Read(sockfd, recvline, MAXLINE);

        recvline[n] = 0; /* null terminate */
        Fputs(recvline, stdout);
    }
}
```

所做的修改是调用connect，并以read和write调用代替sendto和recvfrom调用。该函数不查看传递给connect的套接字地址结构的内容，因此它仍然是协议无关的。图8-7中的客户程序main函数保持不变。

### UDP缺乏流量控制

现在查看无任何流量控制的UDP对数据报传输的影响。

把dg_cli修改为发送固定数目的数据报，它写2000个1400字节大小的UDP数据报给服务器。

unpv13e/udpcliserv/dgcliloop1.c

```c++
#include "unp.h"

#define NDG 2000 /* datagrams to send */
#define DGLEN 1400 /* length of each datagram */

void
dg_cli(FILE *fp, int sockfd, const SA *pservaddr, socklen_t servlen)
{
    int i;
    char sendline[DGLEN];

    for (i = 0; i < NDG; i++) {
        Sendto(sockfd, sendline, DGLEN, 0, pservaddr, servlen);
    }
}
```

然后，我们把服务器程序修改为接收数据报并对其计数，并不再把数据报回射给客户。下面是所示为新的dg_echo函数。当我们用终端中断键终止服务器时（相当于向它发送SIGINT信号），服务器会显示所接收到数据报的数目并终止。

unpv13e/udpcliserv/dgecholoop1.c

```c++
#include "unp.h"

static void recvfrom_int(int);
static int count;

void
dg_echo(int sockfd, SA *pcliaddr, socklen_t clilen)
{
    socklen_t len;
    char mesg[MAXLINE];

    Signal(SIGINT, recvfrom_int);

    for ( ; ; ) {
        len = clilen;
        Recvfrom(sockfd, mesg, MAXLINE, 0, pcliaddr, &len);

        count++;
    }
}

static void
recvfrom_int(int signo)
{
    printf("\nreceived %d datagrams\n", count);
    exit(0);
}
```

利用netstat -s -p udp命令查询数据报，书上说的慢速工作站只收到2000个中的30个，我用mac测试全都收到了，这个取决于机器性能

可以用SO_RCVBUF套接字选项修改UDP套接字接收缓冲区大小，这样在慢速工作站上也许丢失率会降低

unpv13e/udpcliserv/dgecholoop2.c

```c++
#include "unp.h"

static void recvfrom_int(int);
static int count;

void
dg_echo(int sockfd, SA *pcliaddr, socklen_t clilen)
{
    int n;
    socklen_t len;
    char mesg[MAXLINE];

    Signal(SIGINT, recvfrom_int);

    n = 220 * 1024;
    Setsockopt(sockfd, SOL_SOCKET, SO_RCVBUF, &n, sizeof(n));

    for ( ; ; ) {
        len = clilen;
        Recvfrom(sockfd, mesg, MAXLINE, 0, pcliaddr, &len);

        count++;
    }
}

static void
recvfrom_int(int signo)
{
    printf("\nreceived %d datagrams\n", count);
    exit(0);
}
```

### UDP中外出接口的确定

UDP调用connect函数后，可以通过getsockname得到本地IP地址和端口号，在多宿主机上尤为有用

### 使用select函数的TCP和UDP回射服务器程序（综合这几章的知识）

把第5章中的并发TCP回射服务器程序与本章中的迭代UDP回射服务器程序组合成单个使用select来复用TCP和UDP套接字的服务器程序

unpv13e/udpcliserv/udpservselect01.c

```c++
/* include udpservselect01 */
#include	"unp.h"

int
main(int argc, char **argv)
{
    int listenfd, connfd, udpfd, nready, maxfdp1;
    char mesg[MAXLINE];
    pid_t childpid;
    fd_set rset;
    ssize_t n;
    socklen_t len;
    const int on = 1;
    struct sockaddr_in cliaddr, servaddr;
    void sig_chld(int);

    /* 4create listening TCP socket */
    listenfd = Socket(AF_INET, SOCK_STREAM, 0);

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family      = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port        = htons(SERV_PORT);

    Setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
    Bind(listenfd, (SA *) &servaddr, sizeof(servaddr));

    Listen(listenfd, LISTENQ);

    /* 4create UDP socket */
    udpfd = Socket(AF_INET, SOCK_DGRAM, 0);

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family      = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port        = htons(SERV_PORT);

    Bind(udpfd, (SA *) &servaddr, sizeof(servaddr));
/* end udpservselect01 */

/* include udpservselect02 */
    Signal(SIGCHLD, sig_chld); /* must call waitpid() */

    FD_ZERO(&rset);
    maxfdp1 = max(listenfd, udpfd) + 1;
    for ( ; ; ) {
        FD_SET(listenfd, &rset);
        FD_SET(udpfd, &rset);
        if ( (nready = select(maxfdp1, &rset, NULL, NULL, NULL)) < 0) {
            if (errno == EINTR)
                continue; /* back to for() */
            else
                err_sys("select error");
        }

        if (FD_ISSET(listenfd, &rset)) {
            len = sizeof(cliaddr);
            connfd = Accept(listenfd, (SA *) &cliaddr, &len);

            if ( (childpid = Fork()) == 0) { /* child process */
                Close(listenfd); /* close listening socket */
                str_echo(connfd); /* process the request */
                exit(0);
            }
            Close(connfd); /* parent closes connected socket */
        }

        if (FD_ISSET(udpfd, &rset)) {
            len = sizeof(cliaddr);
            n = Recvfrom(udpfd, mesg, MAXLINE, 0, (SA *) &cliaddr, &len);

            Sendto(udpfd, mesg, n, 0, (SA *) &cliaddr, len);
        }
    }
}
/* end udpservselect02 */
```

创建一个监听TCP套接字并捆绑服务器的众所周知端口，设置SO_REUSEADDR套接字选项以防该端口上已有连接存在。

还创建一个UDP套接字并捆绑与TCP套接字相同的端口。这里无需在调用bind之前设置SO_REUSEADDR套接字选项，因为TCP端口是独立于UDP端口的。

给SIGCHLD建立信号处理程序，因为TCP连接将由某个子进程处理。我们已在第5章中给出了这个信号处理函数。

我们给select初始化一个描述符集，并计算出我们等待的两个描述符的较大者。

调用select只是为了等待监听TCP套接字的可读条件或UDP套接字的可读条件。既然我们的sig_chld信号处理函数可能中断我们对select的调用，我们于是需要处理EINTR错误。

当监听TCP套接字可读时，我们accept一个新的客户连接，fork一个子进程，并在子进程中调用str_echo函数。这与第5章中采取的步骤相同。

如果UDP套接字可读，那么已有一个数据报到达。我们使用recvfrom读入它，再使用sendto把它发回给客户。

## 第9章 基本SCTP套接字编程（好像不重要）

SCTP是一个较新的传输协议，于2000年在IETF得到标准化（而TCP是在1981年标准化的）。它最初是为满足不断增长的IP电话市场设计的，具体地说就是穿越因特网传输电话信令。SCTP是一个可靠的面向消息的协议，在端点之间提供多个流，并为多宿提供传输级支持

## 第10章 SCTP客户/服务器程序例子

## 第11章 名字与地址转换

到目前为止，本书中所有例子都用数值地址来表示主机（如206.6.226.33），用数值端口号来标识服务器（例如端口13代表标准的daytime服务器，端口9877代表我们的回射服务器）。

然而我们应该使用名字而不是数值：名字比较容易记住；数值地址可以变动而名字保持不变；IPv6输入数值地址很容易出错。

本章讲述在名字和数值地址间进行转换的函数：

gethostbyname和gethostbyaddr在主机名字与**IPv4地址**之间进行转换

getservbyname和getservbyport在服务名字和端口号之间进行转换。

两个协议无关的转换函数：getaddrinfo和getnameinfo，分别用于主机名字和IP地址之间以及服务名字和端口号之间的转换。

### 域名系统DNS（基于UDP）

域名系统（Domain Name System，DNS）主要用于主机名字与IP地址之间的映射。主机名既可以是一个简单名字（simple name），例如solaris或bsdi，也可以是一个**全限定域名（Fully Qualified Domain Name，FQDN）**，例如`solaris.unpbook.com`。

#### 资源记录

DNS中的条目称为**资源记录（resource record，RR）**。我们感兴趣的RR类型只有若干个。

A：A记录把一个主机名映射成一个32位的IPv4地址。举例来说，以下是`unpbook.com`域中关于主机freebsd的4个DNS记录，其中第一个是一个A记录：

AAAA：称为“四A”（quad A）记录的AAAA记录把一个主机名映射成一个128位的IPv6地址。选择“四A”这个称呼是由于128位地址是32位地址的四倍。

CNAME：CNAME代表“canonical name”（规范名字），它的常见用法是为常用的服务（例如ftp和www）指派CNAME记录。如果人们使用这些服务名而不是真实的主机名，那么相应的服务挪到另一个主机时他们也不必知道。举例来说，我们名为linux的主机有以下2个CNAME记录：

```vim
ftp　　IN　　CNAME　linux.unpbook.com.
www　　IN　　CNAME　linux.unpbook.com.
```

#### 解析器和名字服务器

每个组织机构往往运行一个或多个**名字服务器（name server）**。

客户和服务器等应用程序通过调用称为**解析器（resolver）**的函数库中的函数接触DNS服务器。

常见的解析器函数是gethostbyname和gethostbyaddr，前者把主机名映射成IPv4地址，后者则执行相反的映射。

解析器代码通过读取其系统相关配置文件确定名字服务器们（处于可靠和冗余的考虑不止一个）的所在位置。文件`/etc/resolv.conf`通常包含本地名字服务器主机的IP地址。

既然名字要比地址好记易配，要是能够在`/etc/resolv.conf`文件中也使用名字服务器主机的名字该有多好，然而这样做会引入一个鸡与蛋的问题：名字服务器主机自身的名字到地址转换由谁执行呢？

解析器使用UDP向本地名字服务器发出查询。如果本地名字服务器不知道答案，它通常就会使用UDP在整个因特网上查询其他名字服务器。如果答案太长，超出了UDP消息的承载能力，本地名字服务器和解析器会自动切换到TCP。

#### DNS的替代方法

静态主机文件：通常是/etc/hosts文件

blablabla

### gethostbyname函数（根据主机名找主机，仅限于IPv4）

查找主机名最基本的函数是gethostbyname。如果调用成功，它就返回一个指向hostent结构的指针，该结构中含有所查找主机的所有IPv4地址。这个函数的局限是只能返回IPv4地址，而getaddrinfo函数能够同时处理IPv4地址和IPv6地址

```c
#include <netdb.h>
struct hostent *gethostbyname(const char * hostname );
// 返回：若成功则为非空指针，若出错则为NULL且设置h_errno
```

本函数返回的非空指针指向如下的hostent结构。

```c++
struct hostent {
　char　*h_name;　　　　　　/* official (canonical) name of host */
　char **h_aliases;　　　　/* pointer to array of pointers to alias names */
　int　　h_addrtype;　　　　/* host address type: AF_INET */
　int　　h_length;　　　　　/* length of address: 4 */
　char **h_addr_list;　　　/* ptr to array of ptrs with IPv4 addrs */
};
```

下图所示为hostent结构和它所指向的各种信息之间的关系，其中假设所查询的主机名有2个别名和3个IPv4地址。在这些字段中，所查询主机的正式主机名（official host）和所有别名（alias）都是以空字符结尾的C字符串。返回的h_name称为所查询主机的**规范（canonical）名字**。以上一节的CNAME记录例子为例，主机`ftp.unpbook.com`的规范名字是`linux.unpbook.com`。

![Snipaste_2020-02-05_11-55-39.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/Snipaste_2020-02-05_11-55-39.png)

gethostbyname与我们介绍过的其他套接字函数的不同之处在于：当发生错误时，它不设置errno变量，而是将全局整数变量h_errno设置为在头文件`<netdb.h>`中定义的下列常值之一：

1. HOST_NOT_FOUND；
2. TRY_AGAIN；
3. NO_RECOVERY；
4. NO_DATA（等同于NO_ADDRESS）：NO_DATA错误表示指定的名字有效，但是它没有A记录

如今多数解析器提供名为hstrerror的函数，它以某个h_errno值作为唯一的参数，返回的是一个const char *指针，指向相应错误的说明

下面的程序读取命令行参数，给每个命令行参数调用gethostbyname，注意argv是一个指向char型指针的指针，所以`*argv`代表某个命令行参数（字符串）的首位，然后输出规范主机名，输出别名列表，最后调用Inet_ntop函数输出地址列表中的每个IPv4地址

```c++
#include "unp.h"

int
main(int argc, char **argv)
{
    char *ptr, **pptr;
    char str[INET_ADDRSTRLEN];
    struct hostent *hptr;

    while (--argc > 0) {
        ptr = *++argv;
        if ( (hptr = gethostbyname(ptr)) == NULL) {
            err_msg("gethostbyname error for host: %s: %s",
                    ptr, hstrerror(h_errno));
            continue;
        }
        printf("official hostname: %s\n", hptr->h_name);

        for (pptr = hptr->h_aliases; *pptr != NULL; pptr++)
            printf("\talias: %s\n", *pptr);

        switch (hptr->h_addrtype) {
        case AF_INET:
            pptr = hptr->h_addr_list;
            for ( ; *pptr != NULL; pptr++)
                printf("\taddress: %s\n",
                    Inet_ntop(hptr->h_addrtype, *pptr, str, sizeof(str)));
            break;

        default:
            err_ret("unknown address type");
            break;
        }
    }
    exit(0);
}
```

### gethostbyaddr（根据二进制地址找主机）

gethostbyaddr函数试图由一个二进制的IP地址找到相应的主机名，与gethostbyname的行为刚好相反。

```c++
#include <netdb.h>
struct hostent *gethostbyaddr(const char * addr , socklen_t len, int family);
// 返回：若成功则为非空指针，若出错则为NULL且设置h_errno
```

本函数返回一个指向与之前所述同样的hostent结构的指针。我们感兴趣的字段通常是存放规范主机名的h_name。

addr参数实际上不是char *类型，而是一个指向存放IPv4地址的某个in_addr结构的指针；len参数是这个结构的大小：对于IPv4地址为4。family参数为AF_INET。

### getservbyname和getservbyport函数

#### getservbyname

像主机一样，服务也通常靠名字来认知。如果我们在程序代码中通过其名字而不是其端口号来指代一个服务，而且从名字到端口号的映射关系保存在一个文件中（通常是`/etc/services`），那么即使端口号发生变动，我们需修改的仅仅是`/etc/services`文件中的某一行，而不必重新编译应用程序。getservbyname函数用于根据给定名字查找相应服务。

```c++
#include <netdb.h>
struct servent *getservbyname(const char * servname , const char * protoname );
// 返回：若成功则为非空指针，若出错则为NULL
```

本函数返回的非空指针指向如下的servent结构。

```c++
struct servent {
　char　*s_name;　　　　　/* official service name */
　char **s_aliases;　　　/* alias list */
　int　　s_port;　　　　　/* port number, network byte order */
　char　*s_proto;　　　　/* protocol to use */
};
```

服务名参数servname必须指定。如果同时指定了协议（即protoname参数为非空指针），那么指定服务必须有匹配的协议。有些因特网服务既用TCP也用UDP提供（例如DNS），其他因特网服务则仅仅支持单个协议（例如FTP要求使用TCP）。如果protoname未指定而servname指定服务支持多个协议，那么返回哪个端口号取决于实现。通常情况下这种选择无关紧要，因为支持多个协议的服务往往使用相同的TCP端口号和UDP端口号，不过这点并没有保证。

servent结构中我们关心的主要字段是端口号。**既然端口号是以网络字节序返回的，把它存放到套接字地址结构时绝对不能调用htons**。

本函数的典型调用如下：

```c++
struct servent *sptr;
sptr = getservbyname("domain", "udp");　　 /* DNS using UDP */
sptr = getservbyname("ftp", "tcp");　　　　/* FTP using TCP */
sptr = getservbyname("ftp", NULL);　　　　 /* FTP using TCP */
sptr = getservbyname("ftp", "udp");　　　　/* this call will fail */
```

#### getservbyport

getservbyport函数用于根据给定端口号和可选协议查找相应服务。

```c++
“#include <netdb.h>
struct servent *getservbyport(int port, const char *protoname);
// 返回：若成功则为非空指针，若出错则为NULL
```

port参数的值必须为网络字节序。本函数的典型调用如下，因为UDP上没有服务使用端口21，所以最后一个调用将失败

```c++
struct servent *sptr;
sptr = getservbyport(htons(53),"udp");　　 /* DNS using UDP */
sptr = getservbyport(htons(21), "tcp");　　/* FTP using TCP */
sptr = getservbyport(htons(21), NULL);　　 /* FTP using TCP */
sptr = getservbyport(htons(21), "udp");　　/* this call will fail */
```

**有些端口号在TCP上用于一种服务，在UDP上却用于完全不同的另一种服务**。比如下面端口514在TCP上由shell占用，在UDP上由守护进程syslog占用

```shell
 ~  cat /etc/services | grep 514
shell           514/tcp     # cmd
syslog          514/udp #
```

#### 使用gethostbyname与getservbyname的例子（已测试）

unpv13e/names/daytimetcpcli1.c，服务器程序可以运行同目录下的daytimetcpsrv1

```c++
#include	"unp.h"

int
main(int argc, char **argv)
{
    int					sockfd, n;
	char				recvline[MAXLINE + 1];
	struct sockaddr_in	servaddr;
	struct in_addr		**pptr;
	struct in_addr		*inetaddrp[2];
	struct in_addr		inetaddr;
	struct hostent		*hp;
	struct servent		*sp;

	if (argc != 3)
		err_quit("usage: daytimetcpcli1 <hostname> <service>");

	if ( (hp = gethostbyname(argv[1])) == NULL) {
		if (inet_aton(argv[1], &inetaddr) == 0) {
			err_quit("hostname error for %s: %s", argv[1], hstrerror(h_errno));
		} else {
			inetaddrp[0] = &inetaddr;
			inetaddrp[1] = NULL;
			pptr = inetaddrp;
		}
	} else {
		pptr = (struct in_addr **) hp->h_addr_list;
	}

	if ( (sp = getservbyname(argv[2], "tcp")) == NULL)
		err_quit("getservbyname error for %s", argv[2]);

	for ( ; *pptr != NULL; pptr++) {
		sockfd = Socket(AF_INET, SOCK_STREAM, 0);

		bzero(&servaddr, sizeof(servaddr));
		servaddr.sin_family = AF_INET;
		servaddr.sin_port = sp->s_port;
		memcpy(&servaddr.sin_addr, *pptr, sizeof(struct in_addr));
		printf("trying %s\n",
			   Sock_ntop((SA *) &servaddr, sizeof(servaddr)));

		if (connect(sockfd, (SA *) &servaddr, sizeof(servaddr)) == 0)
			break;		/* success */
		err_ret("connect error");
		close(sockfd);
	}
	if (*pptr == NULL)
		err_quit("unable to connect");

	while ( (n = Read(sockfd, recvline, MAXLINE)) > 0) {
		recvline[n] = 0;	/* null terminate */
		Fputs(recvline, stdout);
	}
	exit(0);
}
```

第一个命令行参数是主机名，我们把它作为参数传递给gethostbyname，第二个命令行参数是服务名，我们把它作为参数传递给getservbyname。假设我们的代码使用TCP，我们把它作为getservbyname的第二个参数。

> argv[0]是当前工作目录到该可执行文件的相对路径

如果gethostbyname名字查找失败，我们就尝试使用inet_aton函数（3.6节），确定其参数是否已是ASCII格式的地址，若是则构造一个由相应的地址构成的单元素列表（之所以要放进列表里是为了编程风格一致）。

我们把对socket和connect的调用放在一个循环中，该循环为服务器主机的每个地址执行一次，直到connect成功或IP地址列表试完为止。如果connect成功，则终止循环，否则输出出错消息并关闭套接字。如果for循环没有被break，那么说明地址列表的每个地址都没connect成功，输出错误消息并终止程序。

最后读取服务器的应答，并且在服务器关闭后(服务器发送FIN，Read返回0）终止客户端

### getaddrinfo函数（同时支持IPv4与IPv6）

**getaddrinfo函数能够处理名字到地址以及服务到端口这两种转换**，返回的是一个sockaddr结构而不是一个地址列表。这些sockaddr结构随后可由套接字函数直接使用。如此一来，getaddrinfo函数把协议相关性完全隐藏在这个库函数内部。应用程序只需处理由getaddrinfo填写的套接字地址结构

```c++
#include <netdb.h>
int getaddrinfo(const char *hostname , const char *service, const struct addrinfo *hints , struct addrinfo **result );
// 返回：若成功则为0，若出错则为非0（见图11-7）
```

本函数通过result指针参数返回一个指向addrinfo结构链表的指针，而addrinfo结构定义在头文件`<netdb.h>`中。

```c++
struct addrinfo {
　int　　　　　ai_flags;　　　　　　　　 /* AI_PASSIVE, AI_CANONNAME */
　int　　　　　ai_family;　　　　　　　　/* AF_xxx */
　int　　　　　ai_socktype;　　　　　　　/* SOCK_xxx */
　int　　　　　ai_protocol;　　　　　　　/* 0 or IPPROTO_xxx for IPv4 and IPv6 */
　socklen_t　ai_addrlen;　　　　　　　　 /* length of ai_addr */
　char　　　　 *ai_canonname;　　　　　　/* ptr to canonical name for host */
　struct sockaddr　*ai_addr;　　　　　　 /* ptr to socket address structure */
　struct addrinfo　　*ai_next;　　　　　 /* ptr to next structure in linked list */
};
```

其中hostname参数是一个主机名或地址串（IPv4的点分十进制数串或IPv6的十六进制数串）。service参数是一个服务名或十进制端口号数串。

hints参数可以是一个空指针，也可以是一个指向某个addrinfo结构的指针，调用者在这个结构中填入关于期望返回的信息类型的暗示。举例来说，如果指定的服务既支持TCP也支持UDP（例如指代某个DNS服务器的domain服务），那么调用者可以把hints结构中的ai_socktype成员设置为SOCK_DGRAM，使得返回的仅仅是适用于数据报套接字的信息。

hints结构中调用者可以设置的成员有：

- ai_flags（零个或多个或在一起的AI_xxx值）；
- ai_family（某个AF_xxx值）；
- ai_socktype（某个SOCK_xxx值）；
- ai_protocol。

result是指向链表的指针，可能不止一个addrinfo，这是因为：与hostname参数关联的地址有多个；service参数指定的服务支持多个套接字类型。比如，如果没有hints，请求查找有2个IP地址的某主机上的domain服务，返回4个addrinfo结果。IP1+TCP, IP1+UDP, IP2+TCP, IP2+UDP

addrinfo结构返回的地址可以用于socket调用，随后给客户的connect或sendto调用，或给服务器的bind调用

### gai_strerror函数

getaddrinfo发生错误返回非0值。gai_strerror以非0值为它的唯一参数，返回一个指向对应的出错信息串的指针。

### freeaddrinfo函数

由getaddrinfo返回的所有存储空间都是动态获取的（譬如来自malloc调用），包括addrinfo结构、ai_addr结构和ai_canonname字符串。这些存储空间通过调用freeaddrinfo返还给系统。

如果对addrinfo复制后通过副本对内存进行回收，要注意深拷贝和浅拷贝的问题

### 使用getaddrinfo函数的例子

### host_serv函数

lib/host_serv.c

### tcp_connect函数（创建一个TCP套接字并连接到指定服务器）

源码位于lib/tcp_connect.c，在该函数中调用getaddrinfo，然后尝试每个addrinfo结构socket和connect，直至某个成功或到达链表尾，如果getaddrinfo失败或者connect调用一直没成功，函数将终止

```c++
int tcp_connect(const char *host, const char *serv)
// 成功则返回已连接套接字描述符，若出错则不返回
```

下面是使用了tcp_connect函数的时间获取客户程序，names/daytimetcpcli.c，服务器程序可以用names/daytimetcpsrv1.c。运行该程序，需要传入主机名和服务名（或端口号），尝试tcp_connect后，调用getpeername获取服务器的协议地址并打印出来，在我的mac上测试如下

```shell
% ./daytimetcpcli lhlMac.local daytime
connected to 192.168.2.101
Wed Feb  5 20:33:53 2020
```

```c++
#include	"unp.h"

int
main(int argc, char **argv)
{
	int				sockfd, n;
	char			recvline[MAXLINE + 1];
	socklen_t		len;
	struct sockaddr_storage	ss;

	if (argc != 3)
		err_quit("usage: daytimetcpcli <hostname/IPaddress> <service/port#>");

	sockfd = Tcp_connect(argv[1], argv[2]);

	len = sizeof(ss);
	Getpeername(sockfd, (SA *)&ss, &len);
	printf("connected to %s\n", Sock_ntop_host((SA *)&ss, len));

	while ( (n = Read(sockfd, recvline, MAXLINE)) > 0) {
		recvline[n] = 0;	/* null terminate */
		Fputs(recvline, stdout);
	}
	exit(0);
}
```

### tcp_listen函数（创建一个TCP套接字，捆绑到服务器众所周知端口，并监听）

源码位于lib/tcp_listen.c，host可以为空，创建hints，调用getaddrinfo，循环对于每个addrinfo结构调用socket和bind，若成功则跳出循环，对于TCP服务器总是设置SO_REUSEADDR套接字选项，最后调用listen。若addrlenp非空，则这个指针会返回协议地址的大小

```c++
int tcp_listen(const char *host, const char *serv, socklen_t *addrlenp)
// 若成功则返回已连接套接字描述符，若出错则不返回
```

下面是使用了tcp_listen函数的时间获取服务器程序，位于names/daytimetcpsrv1.c。提供一个命令行参数指定服务名或端口，tcp_listen创建监听套接字，addrlenp为空说明我们不关心地址结构有多大，我们将使用sockaddr_storage，然后服务器循环accept等待客户连接，无论是IPv4还是IPv6，sock_ntop会输出客户的地址，与刚才的daytimetcpcli客户程序配合，在我的mac测试如下

```shell
% ./daytimetcpsrv1 daytime
connection from [::ffff:192.168.2.101]:63904
```

```c++
#include	"unp.h"
#include	<time.h>

int
main(int argc, char **argv)
{
	int				listenfd, connfd;
	socklen_t		len;
	char			buff[MAXLINE];
	time_t			ticks;
	struct sockaddr_storage	cliaddr;

	if (argc != 2)
		err_quit("usage: daytimetcpsrv1 <service or port#>");

	listenfd = Tcp_listen(NULL, argv[1], NULL);

	for ( ; ; ) {
		len = sizeof(cliaddr);
		connfd = Accept(listenfd, (SA *)&cliaddr, &len);
		printf("connection from %s\n", Sock_ntop((SA *)&cliaddr, len));

		ticks = time(NULL);
		snprintf(buff, sizeof(buff), "%.24s\r\n", ctime(&ticks));
		Write(connfd, buff, strlen(buff));

		Close(connfd);
	}
}
```

names/daytimetcpsrv2.c在当前代码上升级为协议无关的

### udp_client函数（创建未连接的UDP套接字）

源码位于lib/udp_client.c

```c++
#include "unp.h"
int udp_client(const char *hostname, const char *service,
　　　　　　　　struct sockaddr **saptr, socklen_t *lenp);
// 返回：若成功则为未连接套接字描述符，若出错则不返回
```

本函数创建一个未连接UDP套接字，并返回三项数据。首先，返回值是该套接字的描述符。其次，saptr是指向某个（由udp_client动态分配的）套接字地址结构的（由调用者自行声明的）一个指针的地址，本函数把目的IP地址和端口存放在这个结构中，用于稍后调用sendto。最后，这个套接字地址结构的大小在lenp指向的变量中返回。lenp这个结尾参数不能是一个空指针（而tcp_listen允许其结尾参数是一个空指针），因为任何sendto和recvfrom调用都需要知道套接字地址结构的长度

names/daytimeudpcli1.c是一个使用udp_client的协议无关的UDP时间获取客户程序

### udp_connect函数（创建已连接的UDP套接字，类似tcp_connect）

源码位于lib/udp_connect.c

```c++
#include "unp.h"
int udp_connect(const char *hostname, const char *service);
// 返回：若成功则为已连接套接字描述符，若出错则不返回
```

有了已连接UDP套接字后，udp_client必需的结尾两个参数就不再需要了。调用者可改用write代替sendto，因此本函数不必返回一个套接字地址结构及其长度。**本函数几乎等同于tcp_connect**，两者的差别是UDP套接字的connect调用不会发送任何东西到对端

### udp_server函数（类似tcp_listen）

源码位于lib/udp_server.c，除了没有调用listen外，几乎等同于tcp_listen，首先调用getaddrinfo，然后socket，bind

```c++
int udp_server(const char *host, const char *serv, socklen_t *addrlenp)
// 若成功则为未连接套接字描述符，若出错则不返回
```

names/daytimeudpsrv2.c是使用了udp_server函数的协议无关的时间获取服务器程序

### getnameinfo函数（getaddrinfo的互补，比sock_ntop多了DNS）

该函数以一个套接字地址为参数，返回描述其中的主机的一个字符串和描述其中的服务的另一个字符串。本函数以协议无关的方式提供这些信息，也就是说，调用者不必关心存放在套接字地址结构中的协议地址的类型，因为这些细节由本函数自行处理。

```c++
#include <netdb.h>
int getnameinfo(const struct sockaddr \*sockaddr, socklen_t addrlen,
　　　　　　　　　char \*host, socklen_t hostlen,
　　　　　　　　　char \*serv, socklen_t servlen, int flags);
// 返回：若成功则为0，若出错则为非0（见图11-7）
```

sockaddr指向一个套接字地址结构，其中包含待转换成直观可读的字符串的协议地址，addrlen是这个结构的长度。该结构及其长度通常由accept、recvfrom、getsockname或getpeername返回。

待返回的2个直观可读字符串由调用者预先分配存储空间，host和hostlen指定主机字符串，serv和servlen指定服务字符串。如果调用者不想返回主机字符串，那就指定hostlen为0。同样，把servlen指定为0就是不想返回服务字符串。

**sock_ntop和getnameinfo的差别在于，前者不涉及DNS，只返回IP地址和端口号的一个可显示版本；后者通常尝试获取主机和服务的名字。**

### 可重入函数（gethostbyname、gethostbyaddr不是可重入的）

gethostbyname与gethostbyaddr函数不是**可重入的（re-entrant)**，探究源码可以发现，host是一个static的hostent结构，所以在普通的UNIX进程有可能发生重入问题：主控制流和信号处理函数同时调用gethostbyname或gethostbyaddr，如果主控制流在gethostbyname函数填写好了host变量并准备返回时暂停，而信号处理函数调用gethostbyname会重新填写host变量并返回，此时主控制流填写的host就被覆盖了，只能得到信号处理函数填写的host变量

```c++
static struct hostent　　host;　　　　/* result stored here */
struct hostent *
gethostbyname(const char *hostname)
{
　　return(gethostbyname2(hostname, family));
}
struct hostent *
gethostbyname2(const char *hostname, int family)
{
　　/* call DNS functions for A or AAAA query */
　　/* fill in host structure */
　　return(&host);
}
struct hostent *
gethostbyaddr(const char *addr, socklen_t len, int family)
{
　　/* call DNS functions for PTR query in in-addr.arpa domain */
　　/* fill in host structure */
    return(&host);
}
```

支持线程的一些实现可以提供gethostbyname、gethostbyaddr的可重入版本

### gethostbyname_r和gethostbyaddr_r函数（可重入版本）

把由不可重入函数填写并返回静态结构的做法改为由调用者分配再由可重入函数填写结构。但这种方法较复杂，需要调用者提供待填写的hostent结构。

调用malloc动态分配内存，但别忘了调用freeaddrinfo释放内存，如果忘了则会引起**内存泄漏**

### 作废的IPv6地址解析函数

### 其他网络相关信息

应用进程可能想要查找四类与网络相关的信息：主机、网络、协议和服务。大多数查找针对的是主机（gethostbyname和gethostbyaddr），一小部分查找针对的是服务（getservbyname和getservbyport），更小一部分查找针对的是网络和协议。

- 主机：`/etc/hosts`，hostent结构，键值查找函数gethostbyaddr、gethostbyname
- 网络：`/etc/networks`，netent结构，键值查找函数getnetbyaddr、getnetbyname
- 协议：`/etc/protocols`，protoent结构，键值查找函数getprotobyname、getprotobynumber
- 服务：`/etc/services`，servent结构，键值查找函数getservbyname、getservbyport

## 第12章 IPv4与IPv6的互操作性

**双栈（dual stacks）**主机上的IPv6服务器既能服务于IPv4客户，又能服务于IPv6客户。IPv4客户发送给这种服务器的仍然是IPv4数据报，不过服务器的协议栈会把客户主机的地址转换成一个IPv4映射的IPv6地址，因为IPv6服务器仅仅处理IPv6套接字地址结构。

类似地，双栈主机上的IPv6客户能够和IPv4服务器通信。客户的解析器会把服务器主机所有的A记录作为IPv4映射的IPv6地址返回给客户，而客户指定这些地址之一调用connect将会使双栈发送一个IPv4 SYN分节。只有少量特殊的客户和服务器需要知道对端使用的具体协议（例如FTP），而IN6_IS_ADDR_V4MAPPED宏可用于判定对端是否在使用IPv4。

## 第13章 守护进程和inetd超级服务器

**守护进程（daemon）**是在后台运行且不与任何控制终端关联的进程。Unix系统通常有很多守护进程在后台运行（约在20～50个的量级），执行不同的管理任务。许多网络服务器也作为守护进程运行。

守护进程没有控制终端通常源于它们由系统初始化脚本启动。然而守护进程也可能从某个终端由用户在shell提示符下键入命令行启动，这样的守护进程必须亲自脱离与控制终端的关联，从而避免与作业控制、终端会话管理、终端产生信号等发生任何不期望的交互，也可以避免在后台运行的守护进程非预期地输出到终端。

守护进程有多种启动方法。

1. 在系统启动阶段，许多守护进程由系统初始化脚本启动，这些守护进程一开始就拥有超级用户特权。
2. 许多网络服务器由**inetd超级服务器**启动。inetd自身由上一条中的某个脚本启动。inetd监听网络请求（Telnet、FTP等），每当有一个请求到达时，启动相应的实际服务器（Telnet服务器、FTP服务器等）。
3. **cron守护进程按照规则定期执行一些程序**，而由它启动执行的程序同样作为守护进程运行。cron自身由第1条启动方法中的某个脚本启动。
4. **at命令用于指定将来某个时刻的程序执行**。这些程序的执行时刻到来时，通常由cron守护进程启动执行它们，因此这些程序同样作为守护进程运行。
5. 守护进程还可以从用户终端或在前台或在后台启动。

因为守护进程没有控制终端，所以当有事发生时它们得寻找一个发出消息的机制。syslog函数是输出这些消息的标准方法，它把这些消息发送给syslogd守护进程。

### syslogd守护进程（系统日志）

UNIX系统的syslogd守护进程通常由系统初始化脚本启动，它在启动时会读取`/etc/syslog.conf`配置文件，这样它就知道了该如何处理日志消息，syslogd守护进程在系统工作期间一直运行

### syslog函数

既然守护进程没有控制终端，它们就不能把消息fprintf到stderr上。从守护进程中登记消息的常用技巧就是调用syslog函数。

```c++
#include <syslog.h>
void syslog(int priority, const char *message, ... );
```

priority参数是**级别（level）**和**设施（facility）**的结合，level从0（最高）到7（最低），默认是LOG_NOTICE，facility默认是LOG_USER

message参数是类似printf的格式串，它将被替换为对应当前errno值的出错消息

### daemon_init函数（把普通进程转为守护进程）

daemon_init函数源码位于lib/daemon_init.c，我就不放出细节了

例子：作为守护进程运行的时间获取服务器程序，源码位于/inetd/daytimetcpsrv2.c

改动的地方只有两个，在程序开始执行处尽早调用我们的daemon_init函数，再把输出客户IP地址和端口号的printf改为调用我们的err_msg函数。

注意在调用daemon_init之前要检查argc。

调用daemon_init之后，所有后续出错消息进入syslog，不再有作为标准错误输出的控制终端可用。

```c++
#include	"unp.h"
#include	<time.h>

int
main(int argc, char **argv)
{
	int listenfd, connfd;
	socklen_t addrlen, len;
	struct sockaddr	*cliaddr;
	char buff[MAXLINE];
	time_t ticks;

	if (argc < 2 || argc > 3)
		err_quit("usage: daytimetcpsrv2 [ <host> ] <service or port>");

	daemon_init(argv[0], 0);

	if (argc == 2)
		listenfd = Tcp_listen(NULL, argv[1], &addrlen);
	else
		listenfd = Tcp_listen(argv[1], argv[2], &addrlen);

	cliaddr = Malloc(addrlen);

	for ( ; ; ) {
		len = addrlen;
		connfd = Accept(listenfd, cliaddr, &len);
		err_msg("connection from %s", Sock_ntop(cliaddr, len));

		ticks = time(NULL);
		snprintf(buff, sizeof(buff), "%.24s\r\n", ctime(&ticks));
		Write(connfd, buff, strlen(buff));

		Close(connfd);
	}
}
```

如果先在主机linux上运行本程序，再从同一个主机进行连接（譬如指定连接到localhost），然后检查/var/adm/messages文件（设施为LOG_USER的消息都发送到该文件），就可能找到类似如下的日志消息（已折行）：

```vim
Jun 10 09:54:37 linux daytimetcpsrv2[24288]:
connection from 127.0.0.1.55862
```

在mac上测试，能建立TCP连接，但是找不到类似的日志文件

### inetd守护进程（超级服务器守护进程）

典型的Unix系统可能存在许多服务器，这些服务器都有一个守护进程与之关联，但1）这些守护进程的启动代码几乎相同（既要创建套接字，又要调用daemon_init函数），2）而又经常处于睡眠状态，所以出现了**inetd守护进程**，inetd简化了程序，又减少了进程数量，它的配置文件是`/etc/inetd.conf`，读取后inetd就知道了要处理哪些服务以及请求到达时要怎么做

inetd守护进程的工作流程如下

1. 启动阶段，读入`/etc/inetd.conf`配置文件，给文件中每个服务创建指定的TCP或UDP套接字，然后都加入描述符集，以供后面的select调用
2. 为每个套接字调用bind，捆绑相应的众所周知端口（可由getservbyname获得）和通配地址
3. 对于每个TCP，调用listen，UDP跳过该步骤
4. 调用select等待任何一个套接字可读，**inetd大部分时间阻塞于此**
5. 当某个套接字可读，如果是TCP则调用accept函数，UDP跳过该步骤
6. inetd守护进程调用fork派生进程，TCP与UDP都由子进程处理服务请求，**这里很像标准的并发服务器**。然后，子进程关闭除要处理的套接字描述符之外的所有描述符，然后调用dup2三次，把待处理套接字描述符复制到描述符0、1和2（标准输入、标准输出和标准错误输出），然后关闭原套接字描述符。子进程打开的描述符于是只有0、1和2。**子进程自标准输入读实际是从所处理的套接字读，往标准输出或标准错误输出写实际上是往所处理的套接字写**。最后调用exec执行指定程序，也就是打开对应服务器程序，**描述0、1、2跨exec保持打开**。
7. 如果是TCP，第6步fork后父进程会close该已连接套接字（就像并发服务器那样），然后再次调用select，等待下一个变为可读的套接字

因为服务器程序是通过fork和exec后执行的，所以知悉客户身份的唯一方法就是getpeername

由于inetd要fork加上exec，所以不适合服务密集型服务器，比如web服务器则使用多种技术将进程控制开销降到最低

> 根据习题13.2：对于由inetd内部处理的5个服务（图2-18），考虑每个服务各有一个TCP版本和一个UDP版本，这样总共10个服务器的实现中，哪些用到了fork调用，哪些不需要fork调用？
>
> TCP版本的echo、discard和chargen服务器由inetd派生出来之后作为子进程运行，因为它们需要运行到客户终止连接为止。另外2个TCP服务器time和daytime并不需要inetd派生子进程，因为它们的服务极易实现（即取得当前时间和日期，把它格式化后写出，再关闭连接），于是由inetd直接处理。所有5个UDP服务的处理都不需要inetd派生子进程，因为每个服务对于引发它的任一客户数据报所作的响应只是最多产生一个数据报。因此这5个服务也由inetd直接处理。
>
> 我猜测：是不是UDP就不需要inetd工作流程中的fork了？？？因为UDP只需要返回一个数据报，直接返回即可？？？

### deamon_inetd函数（不重要）

可用于已知由inetd启动的服务器程序中

本函数与daemon_init相比显得微不足道，因为所有守护进程化步骤已由inetd在启动时执行。本函数的任务仅仅是为错误处理函数（图D-3）设置daemon_proc标志，并以与图13-4中的调用相同的参数调用openlog。

例子：由inetd作为守护进程启动的时间获取服务器程序，源码位于inetd/daytimetcpsrv3.c

```c++
#include	"unp.h"
#include	<time.h>

int
main(int argc, char **argv)
{
	socklen_t		len;
	struct sockaddr	*cliaddr;
	char			buff[MAXLINE];
	time_t			ticks;

	daemon_inetd(argv[0], 0);

	cliaddr = Malloc(sizeof(struct sockaddr_storage));
	len = sizeof(struct sockaddr_storage);
	Getpeername(0, cliaddr, &len);
	err_msg("connection from %s", Sock_ntop(cliaddr, len));

    ticks = time(NULL);
    snprintf(buff, sizeof(buff), "%.24s\r\n", ctime(&ticks));
    Write(0, buff, strlen(buff));

	Close(0);	/* close TCP connection */
	exit(0);
}
```

这个程序有两个大的改动。首先，所有套接字创建代码（即对tcp_listen和accept的调用）都消失了。这些步骤改由inetd执行，我们使用描述符0（标准输入）指代已由inetd接受的TCP连接。其次，无限的for循环也消失了，因为本服务器程序将针对每个客户连接启动一次。服务完当前客户后进程就终止。

既然未曾调用tcp_listen，我们不知道由它返回的套接字地址结构的大小，而且既然未曾调用accept，我们也不知道客户的协议地址。我们于是使用sizeof (struct sockaddr_storage)给套接字地址结构分配一个缓冲区，并以描述符0为第一个参数调用getpeername

为了在我们的Solaris系统上运行本例子程序，我们首先赋予本服务一个名字和一个端口，将把如下行加到`/etc/services文件中：

```vim
mydaytime　　　　9999/tcp
```

接着把如下行加到`/etc/inetd.conf`文件中：

```vim
mydaytime　stream　tcp　nowait　 andy
　　　/home/andy/daytimetcpsrv3　 daytimetcpsrv3
```

（本行太长已做折行处理。）把可执行文件放到指定的位置后，我们给inetd发送一个SIGHUP信号，告知它重新读入其配置文件。紧接着我们执行netstat命令验证inetd已在TCP端口9999上创建了一个监听套接字：

```shell
solaris % netstat -na | grep 9999
　　　*.9999　　　　　　　*.*　　　　　 0　　　　　0 49152　　　　　0 LISTEN
```

然后从另一个主机访问这个服务器：

```shell
linux % telnet solaris 9999
Trying 192.168.1.20...
Connected to solaris.
Escape character is '^]'.
Tue Jun 10 11:04:02 2003
Connection closed by foreign host.
```

`/var/adm/messages`文件（这是根据/etc/syslog.conf文件，将LOG_USER设施的消息登记到其中的文件）中有如下的日志消息：

```vim
Jun 10 11:04:02 solaris daytimetcpsrv3[28724]: connection from
192.168.1.10.58145
```

因为我的mac找不到inetd以及其配置文件，所以没法测试