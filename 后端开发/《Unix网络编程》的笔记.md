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

gethostbyname和gethostbyaddr在主机名字��**IPv4地址**之间进行转换

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

## 第14章 高级I/O函数

### 高级I/O函数小结

在**套接字操作上设置时间限制**的方法有三个：

1. 使用alarm函数和SIGALRM信号；
2. 使用由select提供的时间限制；
3. 使用较新的SO_RCVTIMEO和SO_SNDTIMEO套接字选项。

第一个方法易于使用，不过涉及信号处理，而信号处理正如我们将在20.5节看到的那样可能导致竞争条件。使用select意味着我们阻塞在指定过时间限制的这个函数上，而不是阻塞在read、write或connect调用上。第三个方法也易于使用，不过并非所有实现都提供。

**recvmsg和sendmsg是所提供的5组I/O函数中最为通用的**。它们组合了如下能力：指定MSG_xxx标志（出自recv和send），返回或指定对端的协议地址（出自recvfrom和sendto），使用多个缓冲区（出自readv和writev）。此外还增加了两个新的特性：给应用进程返回标志，接收或发送辅助数据。

**C标准I/O函数库**也可以用在套接字上，不过这么做将在已经由TCP提供的缓冲级别之上新增一级缓冲。实际上，对由标准I/O函数库执行的缓冲缺乏了解是使用这个函数库最常见的问题。既然套接字不是终端设备，这个潜在问题的常用解决办法就是把标准I/O流设置成不缓冲，或者干脆不要在套接字上使用标准I/O。

**T/TCP是对TCP的一个简单增强版本**，能够在客户和服务器近来彼此通信过的前提下避免三路握手，使得服务器对于客户的请求更快地给出应答。从编程角度看，客户通过调用sendto而不是通常的connect、write和shutdown调用序列发挥T/TCP的优势。

### 套接字超时

在涉及套接字的I/O操作上设置超时的方法有以下3种，第3种仅适用套接字描述符，前两种适合任何描述符。

1. 调用alarm，它在指定超时期满时产生SIGALRM信号。这个方法涉及信号处理，而信号处理在不同的实现上存在差异，而且可能干扰进程中现有的alarm调用。
2. 在select中阻塞等待I/O（select有内置的时间限制），以此代替直接阻塞在read或write调用上。
3. 使用较新的SO_RCVTIMEO和SO_SNDTIMEO套接字选项。这个方法的问题在于并非所有实现都支持这两个套接字选项。

#### 使用SIGALM为connect设置超时

我们的connect_timeo函数，它以由调用者指定的超时上限调用connect。它的前3个参数用于调用connect，第四个参数是等待的秒数，源码位于lib/connect_timeo.c

本技术无法延长内核现有的超时，比如Berkeley的内核中connect的超时通常为75s。

本技术还使用了系统调用（connect）的可中断能力，使得它们能够在内核超时发生之前返回，前提是能够直接处理由系统调用返回的EINTR错误。

尽管本例子相当简单，但在多线程化程序中正确使用信号却非常困难（见第26章）。因此我们建议只是在未线程化或单线程化的程序中使用本技术。

#### 使用SIGALRM为recvfrom设置超时

源码位于advio/dgclitimeo3.c

具体流程是：为SIGALRM建立信号处理函数，每次调用recvfrom前通过调用alarm设置一个5s的超时，如果5s还没接收到数据，则输出信息并继续执行，重新计时，如果收到数据，则关掉报警时钟并输出服务器的应答。

这个例子也很简单，但是它只能期待读取单个应答，多余多个应答，在事先计时就不知道是哪个应答

##### 使用select为recvfrom设置超时

源码位于lib/readable_timeo.c，该函数等待一个描述符最多在指定的描述内变为可读

```c++
/* include readable_timeo */
#include	"unp.h"

int
readable_timeo(int fd, int sec)
{
	fd_set			rset;
	struct timeval	tv;

	FD_ZERO(&rset);
	FD_SET(fd, &rset);

	tv.tv_sec = sec;
	tv.tv_usec = 0;

	return(select(fd+1, &rset, NULL, NULL, &tv));
		/* 4> 0 if descriptor is readable */
}
/* end readable_timeo */

int
Readable_timeo(int fd, int sec)
{
	int		n;

	if ( (n = readable_timeo(fd, sec)) < 0)
		err_sys("readable_timeo error");
	return(n);
}
```

该函数流程如下：

1. 首先在读描述符集中打开与调用者给定描述符对应的位，把调用者给定的等待秒数设置在一个timeval结构中。
2. select等待该描述符变为可读，或者发生超时。本函数的返回值就是select的返回值：出错时为-1，超时发生时为0，否则返回的正值给出已就绪描述符的数目。
3. 本函数不执行读操作，它只是等待给定描述符变为可读。因此本函数适用于任何类型的套接字，既可以是TCP也可以是UDP。我们可以轻而易举地创建等待描述符变为可写的名为writeable_timeo的类似函数。

下面的例子改编自第8章的dg_cli，这个新版本只是在readable_timeo返回一个正值时才调用recvfrom。直到readable_timeo告知所关注的描述符变为可读后我们才调用recvfrom，这一点保证recvfrom不会阻塞

源码位于advio/dgclitimeo1.c，setsockopt的第四个参数是指向某个timeval结构的指针，其中已填入期望的超时值，如果I/O操作超时，其函数（这里是recvfrom）将返回一个EWOULDBLOCK错误

```c++
#include	"unp.h"

void
dg_cli(FILE *fp, int sockfd, const SA *pservaddr, socklen_t servlen)
{
	int	n;
	char	sendline[MAXLINE], recvline[MAXLINE + 1];

	while (Fgets(sendline, MAXLINE, fp) != NULL) {

		Sendto(sockfd, sendline, strlen(sendline), 0, pservaddr, servlen);

		if (Readable_timeo(sockfd, 5) == 0) {
			fprintf(stderr, "socket timeout\n");
		} else {
			n = Recvfrom(sockfd, recvline, MAXLINE, 0, NULL, NULL);
			recvline[n] = 0;	/* null terminate */
			Fputs(recvline, stdout);
		}
	}
}
```

#### 使用SO_RCVTIMEO套接字选项为recvfrom设置超时

最后一个例子展示SO_RCVTIMEO套接字选项如何设置超时。本选项一旦设置到某个描述符（包括指定超时值），其超时设置将应用于该描述符上的所有读操作。**本方法的优势就体现在一次性设置选项上，而前两个方法总是要求我们在欲设置时间限制的每个操作发生之前做些工作**。本套接字选项仅仅应用于读操作，类似的SO_SNDTIMEO选项则仅仅应用于写操作，两者都不能用于为connect设置超时。

下面是使用SO_RCVTIMEO套接字选项的另一个版本的dg_cli函数，源码位于advio/dgclitimeo2.c

```c++
#include	"unp.h"

void
dg_cli(FILE *fp, int sockfd, const SA *pservaddr, socklen_t servlen)
{
	int				n;
	char			sendline[MAXLINE], recvline[MAXLINE + 1];
	struct timeval	tv;

	tv.tv_sec = 5;
	tv.tv_usec = 0;
	Setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

	while (Fgets(sendline, MAXLINE, fp) != NULL) {

		Sendto(sockfd, sendline, strlen(sendline), 0, pservaddr, servlen);

		n = recvfrom(sockfd, recvline, MAXLINE, 0, NULL, NULL);
		if (n < 0) {
			if (errno == EWOULDBLOCK) {
				fprintf(stderr, "socket timeout\n");
				continue;
			} else
				err_sys("recvfrom error");
		}

		recvline[n] = 0;	/* null terminate */
		Fputs(recvline, stdout);
	}
}
```

### recv和send函数（带flags参数的read和write函数）

这两个函数类似标准的read和write函数，不过需要一个额外的参数。

```c++
#include <sys/socket.h>

ssize_t recv(int sockfd, void *buff, size_t nbytes, int flags);

ssize_t send(int sockfd, const void *buff, size_t nbytes, int flags);
// 返回：若成功则为读入或写出的字节数，若出错则为-1
```

recv和send的前3个参数等同于read和write的3个参数。flags参数的值或为0，或为下面列出的一个或多个常值的逻辑或。

- MSG_DONTROUTE（仅send）：本标志告知内核目的主机在某个直接连接的本地网络上，因而**无需执行路由表查找**。
- MSG_DONTWAIT（both）：本标志在无需打开相应套接字的非阻塞标志的前提下，把单个I/O操作**临时指定为非阻塞**，接着执行I/O操作，然后关闭非阻塞标志。
- MSG_OOB（both）：对于send，本标志指明即将**发送带外数据**。正如我们将在第24章中讲述的那样，TCP连接上只有一个字节可以作为带外数据发送。对于recv，本标志指明**即将读入的是带外数据**而不是普通数据。
- MSG_PEEK（仅recv和recvfrom）：本标志适用于recv和recvfrom，它允许我们**查看已可读取的数据**，而且系统不在recv或recvfrom返回后丢弃这些数据。
- MSG_WAITALL（仅recv）：它告知内核**不要在尚未读入请求数目的字节之前让一个读操作返回**。即使指定了MSG_WAITALL，如果发生下列情况之一：(a)捕获一个信号，(b)连接被终止，(c)套接字发生一个错误，相应的读函数仍有可能返回比所请求字节数要少的数据。

### readv和writev函数（分散读，集中写）

这两个函数类似read和write，不过readv和writev允许单个系统调用读入到或写出自一个或多个缓冲区。这些操作分别称为**分散读（scatter read）和集中写（gather write）**，因为来自读操作的输入数据被分散到多个应用缓冲区中，而来自多个应用缓冲区的输出数据则被集中提供给单个写操作。

```c++
#include <sys/uio.h>
ssize_t readv(int filedes, const struct iovec *iov, int iovcnt);
ssize_t writev(int filedes, const struct iovec *iov, int iovcnt);
// 返回：若成功则为读入或写出的字节数，若出错则为-1
```

这两个函数的第二个参数都是指向某个iovec结构数组的一个指针，其中iovec结构在头文件`<sys/uio.h>`中定义：

```c++
struct iovec {
　void　 *iov_base;　　　　/* starting address of buffer */
　size_t　iov_len;　　　　　/* size of buffer */
};
```

**readv和writev这两个函数可用于任何描述符**，而不仅限于套接字。另外**writev是一个原子操作**，意味着对于一个基于记录的协议（例如UDP）而言，一次writev调用只产生单个UDP数据报。

我们在7.9节随TCP_NODELAY套接字选项提到过writev的一个用途。当时我们说一个4字节的write跟一个396字节的write可能触发Nagle算法，首选办法之一是针对这两个缓冲区调用writev。

### recvmsg和sendmsg函数（最通用的I/O函数）

两个函数是最通用的I/O函数。**实际上我们可以把所有read、readv、recv和recvfrom调用替换成recvmsg调用**。类似地，各种输出函数调用也可以替换成sendmsg调用。

```c++
#include <sys/socket.h>
ssize_t recvmsg(int sockfd, struct msghdr *msg, int flags);
ssize_t sendmsg(int sockfd, struct msghdr *msg, int flags);
// 返回：若成功则为读入或写出的字节数，若出错则为-1
```

这两个函数把大部分参数封装到一个msghdr结构中：

```c++
struct msghdr {
　void　　　　　　*msg_name;　　　　　　/* protocol address */
　socklen_t　　　 msg_namelen;　　　　　/* size of protocol address */
struct iovec　　*msg_iov;　　　　　　　/* scatter/gather array */
　int　　　　　　　msg_iovlen;　　　　　　/* # elements in msg_iov */
　void　　　　　　 *msg_control;　　　　　/* ancillary data (cmsghdr struct) */
　socklen_t　　　　msg_controllen;　　　　/* length of ancillary data */
　int　　　　　　　 msg_flags;　　　　　　 /* flags returned by recvmsg() */
};
```

msg_name和msg_namelen这两个成员用于套接字未连接的场合（譬如未连接UDP套接字）。它们类似recvfrom和sendto的第五个和第六个参数：msg_name指向一个套接字地址结构，调用者在其中存放接收者（对于sendmsg调用）或发送者（对于recvmsg调用）的协议地址。如果无需指明协议地址（例如对于TCP套接字或已连接UDP套接字），msg_name应置为空指针。msg_namelen对于sendmsg是一个值参数，对于recvmsg却是一个值—结果参数。

msg_iov和msg_iovlen这两个成员指定输入或输出缓冲区数组（即iovec结构数组），类似readv或writev的第二个和第三个参数。

msg_control和msg_controllen这两个成员指定可选的辅助数据的位置和大小。msg_controllen对于recvmsg是一个值—结果参数

我们必须区别它们的两个标志变量，一个是传递值的flags参数，另一个是所传递msghdr结构的msg_flags成员，它传递的是引用，因为传递给函数的是该结构的地址（具体用法太繁琐了，没细看）

### 辅助数据（在sendmsg、recvmsg函数中使用）

**辅助数据（ancillary data）**可通过调用sendmsg和recvmsg这两个函数，使用msghdr结构中的msg_control和msg_controllen这两个成员发送和接收。辅助数据的另一个称谓是**控制信息（control information）**

辅助数据由一个或多个辅助数据对象（ancillary data object）构成，每个对象以一个定义在头文件`<sys/socket.h>`中的cmsghdr结构开头。

```c++
struct cmsghdr {
　socklen_t　　　cmsg_len;　　　　 /* length in bytes, including this structure */
　int　　　　　　cmsg_level;　　　　/* originating protocol　*/
　int　　　　　　cmsg_type;　　　　 /* protocol-specific type　*/
　　　/* followed by unsigned char cmsg_data[] */
}；
```

msg_control指向第一个辅助数据对象，辅助数据的总长度则由msg_controllen指定。每个对象开头都是一个描述该对象的cmsghdr结构。在cmsg_type成员和实际数据之间可以有填充字节，从数据结尾处到下一个辅助数据对象之前也可以有填充字节。

### 排队的数据量

有时候我们想要在不真正读取数据的前提下知道一个套接字上已有多少数据排队等着读取。有3个技术可用于获悉已排队的数据量。

1. 如果获悉已排队数据量的目的在于避免读操作阻塞在内核中（因为没有数据可读时我们还有其他事情可做），那么可以使用非阻塞式I/O。我们将在第16章中讨论非阻塞式I/O。
2. 如果我们既想查看数据，又想数据仍然留在接收队列中以供本进程其他部分稍后读取，那么可以使用MSG_PEEK标志
3. 一些实现支持ioctl的FIONREAD命令。该命令的第三个ioctl参数是指向某个整数的一个指针，内核通过该整数返回的值就是套接字接收队列的当前字节数。

### 套接字和标准I/O

到目前为止的所有例子中，我们一直使用也称为**Unix I/O—**—包括read、write这两个函数及它们的变体（recv、send等等）——的函数执行I/O。这些函数围绕**描述符（descriptor）**工作，通常作为Unix内核中的**系统调用**实现。

执行I/O的另一个方法是使用**标准I/O函数库（standard I/O library）**。这个函数库由ANSI C标准规范，意在便于移植到支持ANSI C的非Unix系统上。标准I/O函数库处理我们直接使用Unix I/O函数时必须考虑的一些细节，譬如自动缓冲输入流和输出流。不幸的是，它对于流的缓冲处理可能导致我们同样必须考虑的一组新的问题。

标准I/O函数库可用于套接字，不过需要考虑以下几点。

1. 通过调用fdopen，可以从任何一个描述符创建出一个标准I/O流。类似地，通过调用fileno，可以获取一个给定标准I/O流对应的描述符。我们第一次遇到fileno是在第6章中，当时我们想在一个标准I/O流上调用select。select只能用于描述符，因此我们不得不获取那个标准I/O流的描述符。
2. TCP和UDP套接字是全双工的。标准I/O流也可以是全双工的：只要以r+类型打开流即可，r+意味着读写。然而在这样的流上，我们必须在调用一个输出函数之后插入一个fflush、fseek、fsetpos或rewind调用才能接着调用一个输入函数。类似地，调用一个输入函数后也必须插入一个fseek、fsetpos或rewind调用才能调用一个输出函数，除非输入函数遇到一个EOF。fseek、fsetpos和rewind这3个函数的问题是它们都调用lseek，而lseek用在套接字上只会失败。
3. 解决上述读写问题的最简单方法是为一个给定套接字打开两个标准I/O流：一个用于读，一个用于写。

例子：使用标准I/O的str_echo函数，源码位于advio/str_echo_stdio02.c，TCP回射服务器程序，调用fdopen创建两个标准I/O流，一个用于输入，一个用于输出。把原来的read和writen调用替换成fgets和fputs调用

```c++
#include	"unp.h"

void
str_echo(int sockfd)
{
	char		line[MAXLINE];
	FILE		*fpin, *fpout;

	fpin = Fdopen(sockfd, "r");
	fpout = Fdopen(sockfd, "w");

	while (Fgets(line, MAXLINE, fpin) != NULL)
		Fputs(line, fpout);
}
```

根据makefile，advio/tcpserv02.c服务器程序调用了这个str_echo函数，运行它，客户是advio/tcpcli02，我在mac上测试，跟书上的输出是一样的，输入好几行，但无回射输出，键入EOF后才回射那几行

服务器直到我们键入EOF字符才回射所有文本行的原因在于这里存在一个缓冲问题。以下是实际发生的**步骤**。

1. 我们键入第一行输入文本，它被发送到服务器。
2. 服务器用fgets读入本行，再用fputs回射本行。
3. 服务器的标准I/O流被标准I/O函数库完全缓冲。这意味着该函数库把回射行复制到输出流的标准I/O缓冲区，但是不把该缓冲区中的内容写到描述符，因为该缓冲区未满。
4. 我们键入第二行输入文本，它被发送到服务器。
5. 服务器用fgets读入本行，再用fputs回射本行。
6. 服务器的标准I/O函数库再次把回射行复制到输出流的标准I/O缓冲区，但是不把该缓冲区中的内容写到描述符，因为该缓冲区仍未满。
7. 同样的情形发生在我们键入的第三行文本上。
8. 我们键入EOF字符，致使我们的str_cli函数（图6-13）调用shutdown，从而发送一个FIN到服务器。
9. 服务器TCP收取这个FIN，它被fgets读入，致使fgets返回一个空指针。
10. str_echo函数返回到服务器的main函数（图5-12），子进程通过调用exit终止。
11. C库函数exit调用标准I/O清理函数。之前由我们的fputs调用填入输出缓冲区中的未满内容现被输出。
12. 服务器子进程终止，致使它的已连接套接字被关闭，从而发送一个FIN到客户，完成TCP的四分组终止序列。
13. 我们的str_cli函数收取并输出由服务器回射的三行文本。
14. str_cli接着在其套接字上收到一个EOF，客户于是终止。

这里的问题出在服务器中由标准I/O函数库自动执行的缓冲之上。标准I/O函数库执行以下**三类缓冲机制**。

1. 完全缓冲（fully buffering）意味着只在出现下列情况时才发生I/O：缓冲区满，进程显式调用fflush，或进程调用exit终止自身。标准I/O缓冲区的通常大小为8192字节。
2. 行缓冲（line buffering）意味着只在出现下列情况时才发生I/O：碰到一个换行符，进程调用fflush，或进程调用exit终止自身。
3. 不缓冲（unbuffering）意味着每次调用标准I/O输出函数都发生I/O。

标准I/O函数库的大多数Unix实现使用如下**规则**。

1. 标准错误输出总是不缓冲。
2. 标准输入和标准输出完全缓冲，除非它们指代终端设备（这种情况下它们行缓冲）。
3. 所有其他I/O流都是完全缓冲，除非它们指代终端设备（这种情况下它们行缓冲）。

既然套接字不是终端设备，上面的str_echo函数的上述问题就在于输出流（fpout）是完全缓冲的。本问题有两个解决办法。第一个办法是通过调用**setvbuf迫使这个输出流变为行缓冲**。第二个办法是在每次调用fputs之后通过调用**fflush强制输出**每个回射行。然而在现实使用中，这两种办法都易于犯错，与Nagle算法（如7.9节所述）的交互可能也成问题。大多数情况下，最好的解决办法是彻底避免在套接字上使用标准I/O函数库，并且如3.9节所述在缓冲区而不是文本行上执行操作。当标准I/O流的便利性大过对缓冲带来的bug的担忧时，在套接字上使用标准I/O流也可能可行，但这种情况很罕见。

### 高级轮询技术

#### /dev/poll接口

select和poll存在的一个问题是，每次调用它们都得传递待查询的文件描述符。

Solaris上名为/dev/poll的特殊情况提供给了一个可扩展的轮询大龄描述符的方法。轮询设备能在调用之间维持状态，因此轮询进程可以预先设置好待查询描述符的列表，然后进入一个循环等待事件发生，每次循环回来时不必再次设置该列表。

例子：使用/dev/poll的str_cli，源码位于str_cli_poll03.c

#### kqueue接口

FreeBSD随4.1版本引入了kqueue接口。本接口允许进程向内核注册描述所关注kqueue事件的事件过滤器（event filter）。事件除了与select所关注类似的文件I/O和超时外，还有异步I/O、文件修改通知（例如文件被删除或修改时发出的通知）、进程跟踪（例如进程调用exit或fork时发出的通知）和信号处理

### T/TCP：事务目的TCP

T/TCP是对TCP进行过略微修改的一个版本，能够**避免近来彼此通信过的主机之间的三路握手**

T/TCP能够把SYN、FIN和数据组合到单个分节中，前提是数据的大小小于MSS。图14-19展示最小T/TCP事务的时间线。第一个分节是由客户的单个sendto调用产生的SYN、FIN和数据。该分节组合了connect、write和shutdown共三个调用的功能。服务器执行通常的套接字函数调用步骤：socket、bind、listen和accept，其中后者在客户的分节到达时返回。服务器用send发回其应答并关闭套接字。这使得服务器在同一个分节中向客户发出SYN、FIN和应答。比较图14-19和图2-5，我们看到不仅需在网络中传输的分节有所减少（T/TCP需3个，TCP需10个，UDP需2个），而且客户从初始化连接到发送一个请求再到读取相应应答所花费的时间也减少了一个RTT。

![20200206215624.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200206215624.png)

T/TCP的优势在于TCP的所有可靠性（序列号、超时、重传，等等）得以保留，而不像UDP那样把可靠性推给应用程序去实现。T/TCP同样维持TCP的慢启动和拥塞避免措施，UDP应用程序却往往缺乏这些特性。

为了处理T/TCP，套接字API需作些变动。我们指出，在提供T/TCP的系统上TCP应用程序无需任何改动，除非要使用T/TCP的特性。所有现有TCP应用程序继续使用我们已经讲述过的套接字API工作。

## 第15章 Unix域协议

**Unix域协议并不是一个实际的协议族，而是在单个主机上执行客户/服务器通信的一种方法**，所用API就是在不同主机上执行客户/服务器通信所用的API（套接字API）。Unix域协议因此可视为IPC方法之一。

Unix域提供两类套接字：字节流套接字（类似TCP）和数据报套接字（类似DUP）。

使用Unix域套接字有以下3个理由。

1. 在同一个主机上，Unix域套接字往往比TCP套接字快出一倍
2. Unix域套接字可用于在同一个主机上的不同进程之间传递描述符。
3. Unix域套接字较新的实现把客户的凭证（用户ID和组ID）提供给服务器，从而能够提供额外的安全检查措施。

Unix域中用于标识客户和服务器的协议地址是普通文件系统中的路径名。我们知道IPv4协议地址由一个32位地址和一个16位端口号构成，IPv6协议地址则由一个128位地址和一个16位端口号构成。这些路径名不是普通的Unix文件：除非把它们和Unix域套接字关联起来，否则无法读写这些文件。

### Unix域套接字地址结构

在头文件`<sys/un.h>`中定义的Unix域套接字地址结构

```c++
struct sockaddr_un{
    sa_family_t sun_family; // AF_LOCAL
    char sun_path[104];     // null-terminated pathname
};
```

应用进程应该在运行时刻使用sizeof运算符得出本结构的长度，再验证一个路径名是否适合存放到其中的sun_path数组。

存放在sun_path数组中的路径名必须以空字符结尾。实现提供的SUN_LEN宏以一个指向sockaddr_un结构的指针为参数并返回该结构的长度，其中包括路径名中非空字节数。未指定地址通过以空字符串作为路径名指示，也就是一个sun_path[0]值为0的地址结构。它等价于IPv4的INADDR_ANY常值以及IPv6的IN6ADDR_ANY_INIT常值。

POSIX把Unix域协议重新命名为“**本地IPC**”，以消除它对于Unix操作系统的依赖。历史性常值AF_UNIX变为AF_LOCAL。

例子：Unix域套接字的bind调用，命令行参数就是捆绑到套接字上的路径名，如果已存在该路径名，bind会失败，所以要先调用unlink删除它，乙方它已经存在，如果它不存在则无影响。我们使用strncpy复制命令行参数，以免路径名过长导致其溢出结构。既然我们已把该结构初始化为0，并且从sun_path数组的大小中减去1，可以肯定该路径名将以空字符结尾。之后调用bind，并使用SUN_LEN宏计算bind的长度参数。接着调用getsockname取得刚绑定的路径名并显示结果

源码位于unixdomain/unixbind.c

```c++
#include	"unp.h"

int
main(int argc, char **argv)
{
	int					sockfd;
	socklen_t			len;
	struct sockaddr_un	addr1, addr2;

	if (argc != 2)
		err_quit("usage: unixbind <pathname>");

	sockfd = Socket(AF_LOCAL, SOCK_STREAM, 0);

	unlink(argv[1]);		/* OK if this fails */

	bzero(&addr1, sizeof(addr1));
	addr1.sun_family = AF_LOCAL;
	strncpy(addr1.sun_path, argv[1], sizeof(addr1.sun_path)-1);
	Bind(sockfd, (SA *) &addr1, SUN_LEN(&addr1));

	len = sizeof(addr2);
	Getsockname(sockfd, (SA *) &addr2, &len);
	printf("bound name = %s, returned len = %d\n", addr2.sun_path, len);
	
	exit(0);
}
```

mac无法测试该程序

### socketpair函数（创建两个随后连接起来的套接字，仅用于Unix域套接字）

socketpair函数创建两个随后连接起来的套接字。本函数仅适用于Unix域套接字。

```c++
#include <sys/socket.h>
int socketpair(int family, int type, int protocol, int sockfd[2]);
// 返回：若成功则为非0，若出错则为-1
```

family参数必须为AF_LOCAL，protocol参数必须为0。type参数既可以是SOCK_STREAM，也可以是SOCK_DGRAM。新创建的两个套接字描述符作为sockfd[0]和sockfd[1]返回。

本函数类似Unix的pipe函数，会返回两个彼此连接的描述符。

这样创建的两个套接字不曾命名，也就是说其中没有涉及隐式的bind调用。
指定type参数为SOCK_STRAEM调用socketpair得到的结果称为**流管道（stream pipe）**。它与调用pipe创建的普通Unix管道类似，差别在于流管道是全双工的，即两个描述符都是既可读又可写。

### 套接字函数

存在一些差当用于Unix域套接字时，套接字函数存在一些差异和限制（应该是与TCP、UDP套接字函数相比）

- 由bind创建的路径名默认访问权限应为0777（属主用户、组用户和其他用户都可读、可写并可执行），并按照当前umask值进行修正。
- 与Unix域套接字关联的路径名应该是一个**绝对路径名**，而不是一个相对路径名。避免使用后者的原因是它的解析依赖于调用者的当前工作目录。也就是说，要是服务器捆绑一个相对路径名，客户就得在与服务器相同的目录中（或者必须知道这个目录）才能成功调用connect或sendto。
- **在connect调用中指定的路径名必须是一个当前绑定在某个打开的Unix域套接字上的路径名，而且它们的套接字类型（字节流或数据报）也必须一致**。出错条件包括：（a）该路径名已存在却不是一个套接字；（b）该路径名已存在且是一个套接字，不过没有与之关联的打开的描述符；（c）该路径名已存在且是一个打开的套接字，不过类型不符（也就是说Unix域字节流套接字不能连接到与Unix域数据报套接字关联的路径名，反之亦然）。
- 调用connect连接一个Unix域套接字涉及的权限测试等同于调用open以只写方式访问相应的路径名。
- Unix域字节流套接字类似TCP套接字：它们都为进程提供一个**无记录边界**的字节流接口。
- 如果对于某个Unix域字节流套接字的connect调用发现这个监听套接字的队列已满（4.5节），调用就**立即返回一个ECONNREFUSED错误**。这一点不同于TCP：如果TCP监听套接字的队列已满，TCP监听端就忽略新到达的SYN，而TCP连接发起端将数次发送SYN进行重试。
- Unix域数据报套接字类似于UDP套接字：它们都提供一个保留记录边界的不可靠的数据报服务。
- 在一个未绑定的Unix域套接字上发送数据报**不会自动给这个套接字捆绑一个路径名**，这一点不同于UDP套接字：在一个未绑定的UDP套接字上发送UDP数据报导致给这个套接字捆绑一个**临时端口**。这一点意味着除非数据报发送端已经捆绑一个路径名到它的套接字，否则数据报接收端无法发回应答数据报。类似地，对于某个Unix域数据报套接字的connect调用不会给本套接字捆绑一个路径名，这一点不同于TCP和UDP。

### Unix域字节流客户/服务器程序

改编自第5章的TCP回射客户/服务器程序，源码位于unixdomain/unixstrserv01.c，两个套接字地址结构的数据类型现在是sockaddr_un。socket的第一个参数是AF_LOCAL，用以创建一个Unix域字节流套接字。unp.h中定义的UNIXSTR_PATH常值为/tmp/unix.str。我们首先unlink该路径名，以防早先某次运行本程序导致该路径名已经存在；然后在调用bind前初始化套接字地址结构。unlink出错没有关系。
注意，这里的bind调用不同于图15-2中的调用。这里我们指定套接字地址结构的大小（bind的第三个参数）是sockaddr_un结构总的大小，而不是只把路径名占用的字节数计算在内。这两个长度都是有效的，因为路径名必须以空字符结尾。与第5章使用同样的str_echo函数。

```c++
#include	"unp.h"

int
main(int argc, char **argv)
{
	int					listenfd, connfd;
	pid_t				childpid;
	socklen_t			clilen;
	struct sockaddr_un	cliaddr, servaddr;
	void				sig_chld(int);

	listenfd = Socket(AF_LOCAL, SOCK_STREAM, 0);

	unlink(UNIXSTR_PATH);
	bzero(&servaddr, sizeof(servaddr));
	servaddr.sun_family = AF_LOCAL;
	strcpy(servaddr.sun_path, UNIXSTR_PATH);

	Bind(listenfd, (SA *) &servaddr, sizeof(servaddr));

	Listen(listenfd, LISTENQ);

	Signal(SIGCHLD, sig_chld);

	for ( ; ; ) {
		clilen = sizeof(cliaddr);
		if ( (connfd = accept(listenfd, (SA *) &cliaddr, &clilen)) < 0) {
			if (errno == EINTR)
				continue;		/* back to for() */
			else
				err_sys("accept error");
		}

		if ( (childpid = Fork()) == 0) {	/* child process */
			Close(listenfd);	/* close listening socket */
			str_echo(connfd);	/* process request */
			exit(0);
		}
		Close(connfd);			/* parent closes connected socket */
	}
}
```

下面是Unix域字节流协议的回射客户程序，同样改写自第5章，源码位于unixdomain/unixstrcli01.c，str_cli函数与之前一样

```c++
#include	"unp.h"

int
main(int argc, char **argv)
{
	int					sockfd;
	struct sockaddr_un	servaddr;

	sockfd = Socket(AF_LOCAL, SOCK_STREAM, 0);

	bzero(&servaddr, sizeof(servaddr));
	servaddr.sun_family = AF_LOCAL;
	strcpy(servaddr.sun_path, UNIXSTR_PATH);

	Connect(sockfd, (SA *) &servaddr, sizeof(servaddr));

	str_cli(stdin, sockfd);		/* do it all */

	exit(0);
}
```

### Unix域数据报客户/服务器程序

改编自第8章UDP回射服务器程序，源码位于unixdomain/unixdgserv01.c

两个套接字地址结构的数据类型现在是sockaddr_un。socket的第一个参数是AF_LOCAL，用于创建一个Unix域数据报套接字。unp.h中定义的UNIXDG_PATH常值为/tmp/unix.dg。我们首先unlink该路径名，以防早先某次运行本程序导致该路径名已经存在，然后在调用bind之前初始化套接字地址结构。unlink出错没有关系。使用同样的dg_echo函数。

改编自第8章UDP回射客户程序，源码位于unixdomain/unixdgcli01.c。

含有服务器地址的套接字地址结构现在是一个sockaddr_un结构。我们还分配这样的一个结构以存放客户的地址。socket的第一个参数是AF_LOCAL。
与UDP客户不同的是，当使用Unix域数据报协议时，我们必须显式bind一个路径名到我们的套接字，这样服务器才会有能回射应答的路径名。我们调用tmpnam赋值一个唯一的路径名，然后把它bind到该套接字。回顾15.4节，我们知道由一个未绑定的Unix域数据报套接字发送数据报不会隐式地给这个套接字捆绑一个路径名。因此要是我们省掉这一步，那么服务器在dg_echo函数中的recvfrom调用将返回一个空路径名，这个空路径名将导致服务器在调用sendto时发生错误。使用同样的的dg_cli函数。

### 描述符传递（跨进程亲缘关系）

当考虑从一个进程到另一个进程传递打开的描述符时，我们通常会想到：

- fork调用返回之后，子进程共享父进程的所有打开的描述符；
- exec调用执行之后，所有描述符通常保持打开状态不变。

第一个例子中，进程先打开一个描述符，再调用fork，然后父进程关闭这个描述符，子进程则处理这个描述符。这样一个打开的描述符就从父进程传递到子进程。然而我们也可能想让子进程打开一个描述符并把它传递给父进程。
当前的Unix系统提供了用于从一个进程向任一其他进程传递任一打开的描述符的方法。也就是说，这两个进程之间无需存在亲缘关系，譬如父子进程关系。这种技术要求首先在这两个进程之间创建一个Unix域套接字，然后使用sendmsg跨这个套接字发送一个特殊消息。这个消息由内核来专门处理，会把打开的描述符从发送进程传递到接收进程。

流程如下：

1. 创建一个字节流的或数据报的Unix域套接字。
    1. 如果目标是fork一个子进程，让子进程打开待传递的描述符，再把它传递回父进程，那么父进程可以预先调用**socketpair**创建一个可用于在父子进程之间交换描述符的流管道。
    2. 如果进程之间没有亲缘关系，那么服务器进程必须创建一个**Unix域字节流套接字**（因为Unix域数据报套接字容易丢失），bind一个路径名到该套接字，以允许客户进程connect到该套接字。然后客户可以向服务器发送一个打开某个描述符的请求，服务器再把该描述符通过Unix域套接字传递回客户。
2. 发送进程调用以下函数打开描述符：open、pipe、mkfifo、socket和accept。可以**在进程之间传递的描述符不限类型**，这就是我们称这种技术为“描述符传递”而不是“文件描述符传递”的原因。
3. 发送进程创建一个msghdr结构（14.5节），其中含有待传递的描述符。发送进程调用sendmsg跨来自步骤1的Unix域套接字发送该描述符。至此我们说这个描述符“**在飞行中（in flight）**”。即使发送进程在调用sendmsg之后但在接收进程调用recvmsg（见下一步骤）之前关闭了该描述符，对于接收进程它仍然保持打开状态。发送一个描述符会使该描述符的引用计数加1。
4. 接收进程调用recvmsg在来自步骤1的Unix域套接字上接收这个描述符。这个描述符在接收进程中的描述符号不同于它在发送进程中的描述符号是正常的。**传递一个描述符并不是传递一个描述符号**，而是涉及在接收进程中创建一个新的描述。

例子：描述符传递，源码位于unixdomain/mycat.c，调用了my_open函数，位于unixdomain/myopen.c

我们现在给出一个描述符传递的例子。这是一个名为mycat的程序，它通过命令行参数取得一个路径名，打开这个文件，再把文件的内容复制到标准输出。该程序调用我们名为my_open的函数，而不是调用普通的Unix open函数。my_open创建一个流管道，并调用fork和exec启动执行另一个程序，期待输出的文件由这个程序打开。该程序随后必须把打开的描述符通过流管道传递回父进程。

![20200207123813.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200207123813.png)

myopen函数逻辑如下：

1. 通过调用socketpair创建一个流管道后的mycat进程。我们以[0]和[1]标示socketpair返回的两个描述符。
2. mycat进程接着调用fork，子进程再调用exec执行openfile程序。父进程关闭[1]描述符（流管道的两端之间没有差异，我们也可以让子进程关闭[1]，让父进程关闭[0]）。在子进程中，子进程关闭[0]描述符。流管道另一端的描述符号格式化输出到argsockfd字符数组，打开方式则格式化输出到argmode字符数组。这里调用snprintf进行格式化输出是因为exec的参数必须是字符串。子进程随后调用execl执行openfile程序。该函数不会返回，除非它发生错误。一旦成功，openfile 程序的main函数就开始执行。
3. 父进程必须给openfile程序传递三条信息：(1)待打开文件的路径名，(2)打开方式（只读、读写或只写），(3)流管道本进程端（图中标为[1]）对应的描述符号。我们选择将这三条信息作为命令行参数在调用exec时进行传递。当然我们也可以通过流管道将这三条信息作为数据发送。openfile程序在通过流管道发送回打开的描述符后便终止。该程序的退出状态告知父进程文件能否打开，若不能则同时告知发生了什么类型的错误。
4. 父进程关闭流管道的另一端并调用waitpid等待子进程终止。子进程的终止状态在status变量中返回，我们首先检查该程序是否正常终止（也就是说并非被某个信号终止），若正常终止则接着调用WEXITSTATUS宏把终止状态转换成退出状态，退出状态的取值在0～255之间。我们马上会看到，如果openfile程序在打开所请求文件时碰到一个错误，它将以相应的errno值作为退出状态终止自身。
5. 接着给出的read_fd函数通过流管道接收描述符。除了描述符外，我们还读取1个字节的数据，但不对数据进行任何处理。

myopen源码如下：

```c++
#include	"unp.h"

int
my_open(const char *pathname, int mode)
{
	int			fd, sockfd[2], status;
	pid_t		childpid;
	char		c, argsockfd[10], argmode[10];

	Socketpair(AF_LOCAL, SOCK_STREAM, 0, sockfd);

	if ( (childpid = Fork()) == 0) {		/* child process */
		Close(sockfd[0]);
		snprintf(argsockfd, sizeof(argsockfd), "%d", sockfd[1]);
		snprintf(argmode, sizeof(argmode), "%d", mode);
		execl("./openfile", "openfile", argsockfd, pathname, argmode,
			  (char *) NULL);
		err_sys("execl error");
	}

	/* parent process - wait for the child to terminate */
	Close(sockfd[1]);			/* close the end we don't use */

	Waitpid(childpid, &status, 0);
	if (WIFEXITED(status) == 0)
		err_quit("child did not terminate");
	if ( (status = WEXITSTATUS(status)) == 0)
		Read_fd(sockfd[0], &c, 1, &fd);
	else {
		errno = status;		/* set errno value from child's status */
		fd = -1;
	}

	Close(sockfd[0]);
	return(fd);
}
```

read_fd函数过于琐碎，不放源码了，它调用recvmsg在一个Unix域套接字上接收数据和描述符，它前三个参数和read函数一样，**第四格参数是指向某个整数的指针，用于返回收取的描述符**。

在openfile程序中调用了write_fd，它调用sendmsg跨一个Unix域套接字发送一个描述符，openfile程序把描述符传递回父进程后就终止了

通过执行另一个程序来打开文件的优势在于，另一个程序可以是一个setuid到root的程序，能够打开我们通常没有打开权限的文件。该程序能够把通常的Unix权限概念（用户、用户组和其他用户）扩展到它想要的任何形式的访问检查。

### 接收发送者的凭证

通过Unix域套接字作为辅助数据传递的另一种数据是**用户凭证（user credential）**。作为辅助数据的凭证其具体封装方式和发送方式往往特定于操作系统。

凭证传递仍然是一个尚未普及且无统一规范的特性，然而因为它是对Unix域协议的一个尽管简单却也重要的补充，所以我们还是要介绍一下它。当客户和服务器进行通信时，服务器通常需以一定手段获悉客户的身份，以便验证客户是否有权限请求相应服务。

## 第16章 非阻塞式I/O

### 关于阻塞式I/O与非阻塞式I/O的概述

套接字的默认状态是阻塞的。这就意味着当发出一个不能立即完成的套接字调用时，其进程将被**投入睡眠**，等待相应操作完成。可能阻塞的套接字调用可分为以下四类。

1. 输入操作，包括read、readv、recv、recvfrom和recvmsg共5个函数。
    - 如果某个进程对一个阻塞的TCP套接字（默认设置）调用这些输入函数之一，而且该套接字的接收缓冲区中没有数据可读，该进程将被投入睡眠，直到有一些数据到达。
      - 既然TCP是字节流协议，该进程的唤醒就是只要有一些数据到达，这些数据既可能是单个字节，也可以是一个完整的TCP分节中的数据。如果想等到某个固定数目的数据可读为止，那么可以调用我们的readn函数（第3章），或者指定MSG_WAITALL标志（第14章）。
      - 既然UDP是数据报协议，如果一个阻塞的UDP套接字的接收缓冲区为空，对它调用输入函数的进程将被投入睡眠，直到有UDP数据报到达。
    - 对于非阻塞的套接字，如果输入操作不能被满足（对于TCP套接字即至少有一个字节的数据可读，对于UDP套接字即有一个完整的数据报可读），相应调用将立即返回一个EWOULDBLOCK错误。
2. 输出操作，包括write、writev、send、sendto和sendmsg共5个函数。
    - 对于一个TCP套接字我们已在2.11节说过，内核将从应用进程的缓冲区到该套接字的发送缓冲区复制数据。对于阻塞的套接字，如果其发送缓冲区中没有空间，进程将被投入睡眠，直到有空间为止。
    - 对于一个非阻塞的TCP套接字，如果其发送缓冲区中根本没有空间，输出函数调用将立即返回一个EWOULDBLOCK错误。如果其发送缓冲区中有一些空间，返回值将是内核能够复制到该缓冲区中的字节数。这个字节数也称为**不足计数（short count）**。
    - 我们还在2.11节说过，**UDP套接字不存在真正的发送缓冲区**。内核只是复制应用进程数据并把它沿协议栈向下传送，渐次冠以UDP首部和IP首部。因此对一个阻塞的UDP套接字（默认设置），输出函数调用将不会因与TCP套接字一样的原因而阻塞，不过有可能会因其他的原因而阻塞。
3. 接受外来连接，即accept函数。
    - 如果对一个阻塞的套接字调用accept函数，并且尚无新的连接到达，调用进程将被投入睡眠。
    - 如果对一个非阻塞的套接字调用accept函数，并且尚无新的连接到达，accept调用将立即返回一个EWOULDBLOCK错误
4. 发起外出连接，即用于TCP的connect函数。（回顾一下，我们知道connect同样可用于UDP，不过它不能使一个“真正”的连接建立起来，它只是使内核保存对端的IP地址和端口号。）
    - TCP连接的建立涉及一个三路握手过程，而且connect函数一直要等到客户收到对于自己的SYN的ACK为止才返回。这意味着TCP的每个connect总会阻塞其调用进程至少一个到服务器的RTT时间。
    - 如果对一个非阻塞的TCP套接字调用connect，并且连接不能立即建立，那么连接的建立能照样发起（譬如送出TCP三路握手的第一个分组），不过会返回一个EINPROGRESS错误。注意这个错误不同于上述三个情形中返回的错误。另请注意有些连接可以立即建立，通常发生在服务器和客户处于同一个主机的情况下。因此即使对于一个非阻塞的connect，我们也得预备connect成功返回的情况发生。

### 非阻塞读和写：str_cli函数（修订版）

再次回到第5章和第6章的str_cli函数。6.4节讲过的使用了select的版本仍使用阻塞式I/O。这是有缺陷的，比如，如果在标准输入有一行文本可读，我们就调用read读入它，再调用writen把它发送给服务器。然而如果套接字发送缓冲区已满，writen调用将会阻塞。在进程阻塞于writen调用期间，可能有来自套接字接收缓冲区的数据可供读取。类似地，如果从套接字中有一行输入文本可读，那么一旦标准输出比网络还要慢，进程照样可能阻塞于后续的write调用。

不幸的是，非阻塞式I/O的加入让本函数的缓冲区管理显著地复杂化了，因此我们将分片介绍这个函数。我们已在第6章和第14章中讨论过在套接字上使用标准I/O的潜在问题和困难，它们在非阻塞式I/O操作中显得尤为突出。本例子中继续避免使用标准I/O。

我们维护着两个缓冲区：to容纳从标准输入到服务器去的数据，fr容纳自服务器到标准输出来的数据。图16-1展示了to缓冲区的组织和指向该缓冲区中的指针。

![20200207145032.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200207145032.png)

其中toiptr指针指向从标准输入读入的数据可以存放的下一个字节。tooptr指向下一个必须写到套接字的字节。有（toiptr-tooptr）个字节需写到套接字。可从标准输入读入的字节数是（&to［MAXLINE］-toiptr）。一旦tooptr移动到toiptr，这两个指针就一起恢复到缓冲区开始处。

![20200207145050.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200207145050.png)

str_cli源码位于nonblock/strclinonb.c，先给出第一部分的逻辑与源码

1. 使用fcntl把所用3个描述符都设置为非阻塞，包括连接到服务器的套接字、标准输入和标准输出。
2. 初始化指向两个缓冲区的指针，并把最大的描述符号加1，以用作select的第一个参数。
3. 主循环，两个描述符集都先清零再打开最多2位。
    - 如果在标准输入上尚未读到EOF，而且在to缓冲区中有至少一个字节的可用空间，那就打开读描述符集中对应标准输入的位。
    - 如果在fr缓冲区中有至少一个字节的可用空间，那就打开读描述符集中对应套接字的位。
    - 如果在to缓冲区中有要写到套接字的数据，那就打开写描述符集中对应套接字的位。
    - 如果在fr缓冲区中有要写到标准输出的数据，那就打开写描述符集中对应标准输出的位。
4. 调用select，等待4个可能条件中任何一个变为真。我们没有为本select调用设置超时。

```c++
#include	"unp.h"

void
str_cli(FILE *fp, int sockfd)
{
	int			maxfdp1, val, stdineof;
	ssize_t		n, nwritten;
	fd_set		rset, wset;
	char		to[MAXLINE], fr[MAXLINE];
	char		*toiptr, *tooptr, *friptr, *froptr;

	val = Fcntl(sockfd, F_GETFL, 0);
	Fcntl(sockfd, F_SETFL, val | O_NONBLOCK);

	val = Fcntl(STDIN_FILENO, F_GETFL, 0);
	Fcntl(STDIN_FILENO, F_SETFL, val | O_NONBLOCK);

	val = Fcntl(STDOUT_FILENO, F_GETFL, 0);
	Fcntl(STDOUT_FILENO, F_SETFL, val | O_NONBLOCK);

	toiptr = tooptr = to;	/* initialize buffer pointers */
	friptr = froptr = fr;
	stdineof = 0;

	maxfdp1 = max(max(STDIN_FILENO, STDOUT_FILENO), sockfd) + 1;
	for ( ; ; ) {
		FD_ZERO(&rset);
		FD_ZERO(&wset);
		if (stdineof == 0 && toiptr < &to[MAXLINE])
			FD_SET(STDIN_FILENO, &rset);	/* read from stdin */
		if (friptr < &fr[MAXLINE])
			FD_SET(sockfd, &rset);			/* read from socket */
		if (tooptr != toiptr)
			FD_SET(sockfd, &wset);			/* data to write to socket */
		if (froptr != friptr)
			FD_SET(STDOUT_FILENO, &wset);	/* data to write to stdout */

		Select(maxfdp1, &rset, &wset, NULL, NULL);
```

下面是str_cli函数的第二部分（下载的源码多了ifdef的内容，书上没有ifdef），包含select返回后执行的4个测试中的前两个。第一个if（标准输入可读）内的逻辑如下，第二个if（套接字可读）的分析类似。

1. 如果标准输入可读，那就调用read。指定的第三个参数是to缓冲区中的可用空间量。
2. 如果发生一个EWOULDBLOCK错误，我们就忽略它。通常情况下这种条件“不应该发生”，因为这种条件意味着，select告知我们相应描述符可读，然而read该描述符却返回EWOULDBLOCK错误，不过我们无论如何还是处理这种条件。
3. 如果read返回0，那么输出一行文本到标准错误输出以表示这个EOF，同时输出当前时间。我们还设置stdineof标志。如果在to缓冲区中不再有数据要发送（即tooptr等于toiptr），那就调用shutdown发送FIN到服务器。如果在to缓冲区中仍有数据要发送，FIN的发送就得推迟到缓冲区中数据已写到套接字之后。
4. 当read返回数据时，我们相应地增加toiptr。我们还打开写描述符集中与套接字对应的位，使得以后在本循环内对该位的测试为真，从而导致调用write写到套接字。

```c++
		if (FD_ISSET(STDIN_FILENO, &rset)) {
			if ( (n = read(STDIN_FILENO, toiptr, &to[MAXLINE] - toiptr)) < 0) {
				if (errno != EWOULDBLOCK)
					err_sys("read error on stdin");

			} else if (n == 0) {
#ifdef	VOL2
				fprintf(stderr, "%s: EOF on stdin\n", gf_time());
#endif
				stdineof = 1;			/* all done with stdin */
				if (tooptr == toiptr)
					Shutdown(sockfd, SHUT_WR);/* send FIN */

			} else {
#ifdef	VOL2
				fprintf(stderr, "%s: read %d bytes from stdin\n", gf_time(), n);
#endif
				toiptr += n;			/* # just read */
				FD_SET(sockfd, &wset);	/* try and write to socket below */
			}
		}

		if (FD_ISSET(sockfd, &rset)) {
			if ( (n = read(sockfd, friptr, &fr[MAXLINE] - friptr)) < 0) {
				if (errno != EWOULDBLOCK)
					err_sys("read error on socket");

			} else if (n == 0) {
#ifdef	VOL2
				fprintf(stderr, "%s: EOF on socket\n", gf_time());
#endif
				if (stdineof)
					return;		/* normal termination */
				else
					err_quit("str_cli: server terminated prematurely");

			} else {
#ifdef	VOL2
				fprintf(stderr, "%s: read %d bytes from socket\n",
								gf_time(), n);
#endif
				friptr += n;		/* # just read */
				FD_SET(STDOUT_FILENO, &wset);	/* try and write below */
			}
		}
```

本函数最后一部分是另外两个if分支，分别对应于标准输出可写、套接字可写，第一个if分支逻辑如下：

1. 如果标准输出可写而且要写的字节数大于0（`friptr-froptr>0`），那就调用write。如果返回EWOULDBLOCK错误，那么不做任何处理。注意这种条件完全可能发生，因为本函数第二部分末尾的代码在不清楚write是否会成功的前提下就打开了写描述符集中与标准输出对应的位。
2. 如果write成功，froptr就增以写出的字节数。如果输出指针（froptr）追上输入指针（friptr），这两个指针就同时恢复为指向缓冲区开始处。

第二个if分支类似于刚才讲解的处理标准输出可写条件的if语句。唯一的差别是当输出指针追上输入指针时，不仅这两个指针同时恢复到缓冲区开始处，而且如果已经在标准输入上遇到EOF就要发送FIN到服务器。

```c++
		if (FD_ISSET(STDOUT_FILENO, &wset) && ( (n = friptr - froptr) > 0)) {
			if ( (nwritten = write(STDOUT_FILENO, froptr, n)) < 0) {
				if (errno != EWOULDBLOCK)
					err_sys("write error to stdout");

			} else {
#ifdef	VOL2
				fprintf(stderr, "%s: wrote %d bytes to stdout\n",
								gf_time(), nwritten);
#endif
				froptr += nwritten;		/* # just written */
				if (froptr == friptr)
					froptr = friptr = fr;	/* back to beginning of buffer */
			}
		}

		if (FD_ISSET(sockfd, &wset) && ( (n = toiptr - tooptr) > 0)) {
			if ( (nwritten = write(sockfd, tooptr, n)) < 0) {
				if (errno != EWOULDBLOCK)
					err_sys("write error to socket");

			} else {
#ifdef	VOL2
				fprintf(stderr, "%s: wrote %d bytes to socket\n",
								gf_time(), nwritten);
#endif
				tooptr += nwritten;	/* # just written */
				if (tooptr == toiptr) {
					toiptr = tooptr = to;	/* back to beginning of buffer */
					if (stdineof)
						Shutdown(sockfd, SHUT_WR);	/* send FIN */
				}
			}
		}
```

按照书上的方法测试，我们从这幅时间线图可以看出客户/服务器数据交换的动态性。使用非阻塞式I/O使程序能**发挥动态性的优势**，只要I/O操作有可能发生，就执行合适的读操作或写操作。通过使用select函数，我们让内核可以告诉我们何时某个I/O操作可以发生。

![20200207161548.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200207161548.png)

#### str_cli的较简单版本

考虑到代码的复杂性，把程序编写成非阻塞式I/O的努力是否值得呢？回答是否定的。每当我们发现需要使用非阻塞式I/O时，更简单的办法通常是把应用程序任务划分到多个进程（使用fork）或多个线程（第26章）。

下面是str_cli函数的另一个版本，该函数使用fork把当前进程划分成两个进程。子进程把来自服务器的文本行复制到标准输出，父进程把来自标准输入的文本行复制到服务器，**TCP是全双工的**，如下所示

![20200207162033.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200207162033.png)

源码位于nonblock/strclifork.c，我们在图中明确地指出所用TCP连接是全双工的，而且**父子进程共享同一个套接字：父进程往该套接字中写，子进程从该套接字中读**。尽管套接字只有一个，其接收缓冲区和发送缓冲区也分别只有一个，然而这个套接字却有两个描述符在引用它：一个在父进程中，另一个在子进程中。

我们同样需要考虑进程终止序列。正常的终止序列从在标准输入上遇到EOF之时开始发生。父进程读入来自标准输入的EOF后调用shutdown发送FIN。（父进程不能调用close，见习题15.1。）但当这发生之后，子进程需继续从服务器到标准输出执行数据复制，直到在套接字上读到EOF。

服务器进程过早终止也有可能发生（5.12节）。要是发生这种情况，子进程将在套接字上读到EOF。这样的子进程必须告知父进程停止从标准输入到套接字复制数据（见习题16.2）。在图16-10中，子进程向父进程发送一个SIGTERM信号，以防父进程仍在运行（见习题16.3）。如此处理的另一个手段是子进程无为地终止，使得父进程（如果仍在运行的话）捕获一个SIGCHLD信号。

父进程完成数据复制后调用pause让自己进入睡眠状态，直到捕获一个信号（子进程来的SIGTERM信号），尽管它不主动捕获任何信号。SIGTERM信号的默认行为是终止进程，这对于本例子是合适的。我们让父进程等待子进程的目的在于精确测量调用此版str_cli函数的TCP客户程序的执行时钟时间。正常情况下子进程在父进程之后结束，然而我们用于测量时钟时间的是shell内部命令time，它要求父进程持续到测量结束时刻。

注意该版本相比本节前面给出的非阻塞版本体现的简单性。非阻塞版本同时管理4个不同的I/O流，而且由于这4个流都是非阻塞的，我们不得不考虑对于所有4个流的部分读和部分写问题。然而在fork版本中，每个进程只处理2个I/O流，从一个复制到另一个。**这里不需要非阻塞式I/O，因为如果从输入流没有数据可读，往相应的输出流就没有数据可写**。

```c++
#include	"unp.h"

void
str_cli(FILE *fp, int sockfd)
{
	pid_t	pid;
	char	sendline[MAXLINE], recvline[MAXLINE];

	if ( (pid = Fork()) == 0) {		/* child: server -> stdout */
		while (Readline(sockfd, recvline, MAXLINE) > 0)
			Fputs(recvline, stdout);

		kill(getppid(), SIGTERM);	/* in case parent still running */
		exit(0);
	}

		/* parent: stdin -> server */
	while (Fgets(sendline, MAXLINE, fp) != NULL)
		Writen(sockfd, sendline, strlen(sendline));

	Shutdown(sockfd, SHUT_WR);	/* EOF on stdin, send FIN */
	pause();
	return;
}
```

#### str_cli执行时间

354.0秒，停等版本（图5-5）。
12.3秒，select加阻塞式I/O版本（图6-13）。
6.9秒，非阻塞式I/O版本（图16-3）。
8.7秒，fork版本（图16-10）。
8.5秒，线程化版本（图26-2）。

非阻塞版本几乎比select加阻塞式I/O版本快出一倍。fork版本比非阻塞版本稍慢，然而考虑到非阻塞版本代码相比fork版本代码的复杂性，我们推荐简单得多的fork版本。

### 非阻塞connect

当在一个非阻塞的TCP套接字上调用connect时，connect将立即返回一个EINPROGRESS错误，不过已经发起的TCP三路握手继续进行。我们接着使用select检测这个连接或成功或失败的已建立条件。非阻塞的connect有三个用途。

1. 我们可以把**三路握手叠加在其他处理上**。完成一个connect要花一个RTT时间（2.5节），而RTT波动范围很大，从局域网上的几个毫秒到几百个毫秒甚至是广域网上的几秒。这段时间内也许有我们想要执行的其他处理工作可执行。
2. 我们可以使用这个技术**同时建立多个连接**。这个用途已随着Web浏览器变得流行起来，我们将在16.5节给出这样的一个例子。
3. 既然使用select等待连接的建立，我们可以给select指定一个时间限制，使得我们能够缩短connect的超时。许多实现有着从75秒钟到数分钟的connect超时时间。应用程序有时想要一个更短的超时时间，实现方法之一就是使用非阻塞connect。我们已在14.2节讨论过在套接字操作上设置超时时间的其他方法。

非阻塞connnct虽然听似简单，却有一些我们必须处理的细节。

1. 尽管套接字是非阻塞的，如果连接到的服务器在同一个主机上，那么当我们调用connect时，连接通常立刻建立。我们必须处理这种情形。
2. 源自Berkeley的实现（和POSIX）有关于select和非阻塞connect的以下两个规则：（1）当连接成功建立时，描述符变为可写（TCPv2第531页）；（2）当连接建立遇到错误时，描述符变为既可读又可写（TCPv2第530页）。

### 非阻塞connect：时间获取客户程序

客户程序源码位于lib/connect_nonb.c，使用时把普通的connect函数改为connect_nonb，前三个参数一样，第四个参数是等待连接完成的描述，值为0即不设置超时。

connect_nonb函数逻辑如下：

1. 调用fcntl把套接字设置为非阻塞。
2. 发起非阻塞connect。期望的错误是EINPROGRESS，表示连接建立已经启动但是尚未完成（TCPv2第466页）。connect返回的任何其他错误返回给本函数的调用者。
3. 然后我们可以在等待连接建立完成期间做任何我们想做的事情。
4. 如果非阻塞connect返回0，那么连接已经建立。我们已经说过，当服务器处于客户所在主机时这种情况可能发生。
5. 调用select等待套接字变为可读或可写。我们清零rset，打开这个描述符集中对应sockfd的位，然后将rset复制到wset。复制描述符集的赋值可能是一个结构赋值，因为描述符集通常作为结构表示。我们还初始化timeval结构，然后调用select。如果调用者把第四个参数指定为0（表示使用默认超时时间），那么我们必须把select的最后一个参数指定为一个空指针，而不是一个值为0的timeval结构（后者意味着根本不等待）。
6. 如果select返回0，那么超时发生，我们于是返回ETIMEOUT错误给调用者。我们还要关闭套接字，以防止已经启动的三路握手继续下去。
7. 如果描述符变为可读或可写，我们就调用getsockopt取得套接字的待处理错误（使用SO_ERROR套接字选项）。如果连接成功建立，该值将为0。如果连接建立发生错误，该值就是对应连接错误的errno值（譬如ECONNREFUSED、ETIMEDOUT等）。
8. 恢复套接字的文件状态标志并返回。如果自getsockopt返回的error变量为非0值，我们就把该值存入errno，函数本身返回-1。

注意：非阻塞connect是非常不易移植的（具体实现与特定操作系统相关），较简单的技术是为每个连接创建一个线程

```c++
#include	"unp.h"

int
connect_nonb(int sockfd, const SA *saptr, socklen_t salen, int nsec)
{
	int				flags, n, error;
	socklen_t		len;
	fd_set			rset, wset;
	struct timeval	tval;

	flags = Fcntl(sockfd, F_GETFL, 0);
	Fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);

	error = 0;
	if ( (n = connect(sockfd, saptr, salen)) < 0)
		if (errno != EINPROGRESS)
			return(-1);

	/* Do whatever we want while the connect is taking place. */

	if (n == 0)
		goto done;	/* connect completed immediately */

	FD_ZERO(&rset);
	FD_SET(sockfd, &rset);
	wset = rset;
	tval.tv_sec = nsec;
	tval.tv_usec = 0;

	if ( (n = Select(sockfd+1, &rset, &wset, NULL,
					 nsec ? &tval : NULL)) == 0) {
		close(sockfd);		/* timeout */
		errno = ETIMEDOUT;
		return(-1);
	}

	if (FD_ISSET(sockfd, &rset) || FD_ISSET(sockfd, &wset)) {
		len = sizeof(error);
		if (getsockopt(sockfd, SOL_SOCKET, SO_ERROR, &error, &len) < 0)
			return(-1);			/* Solaris pending error */
	} else
		err_quit("select error: sockfd not set");

done:
	Fcntl(sockfd, F_SETFL, flags);	/* restore file status flags */

	if (error) {
		close(sockfd);		/* just in case */
		errno = error;
		return(-1);
	}
	return(0);
}
```

### 非阻塞connect：Web客户程序（可以打开多个TCP连接来加速，但是对网络不利）

客户先建立一个与某个Web服务器的HTTP连接，再获取一个主页（homepage）。该主页往往含有多个对于其他网页（Web page）的引用。客户可以使用非阻塞connect同时获取多个网页，以此取代每次只获取一个网页的串行获取手段。

在处理Web客户时，第一个连接独立执行，来自该连接的数据含有多个引用，随后用于访问这些引用的多个连接则并行执行。

既然准备同时处理多个非阻塞connect，我们就不能使用图16-11中的connect_nonb函数，因为它直到连接已经建立才返回。我们必须自行管理这些（可能尚未成功建立的）连接。

我们的程序最多读20个来自Web服务器的文件。最大并行连接数、服务器的主机名以及要从服务器获取的每个文件的文件名都会作为命令行参数指定。

nonblocl/web.h是每个文件都包含的头文件，本程序最多读MAXFILES个来自Web服务器的文件。file结构包含关于每个文件的信息：文件名（复制自命令行参数）、文件所在服务器主机名或IP地址、用于读取文件的套接字描述符以及用于指定准备对文件执行什么操作（连接、读取或完成）的一组标志。

```c++
#include	"unp.h"

#define	MAXFILES	20
#define	SERV		"80"	/* port number or service name */

struct file {
  char	*f_name;			/* filename */
  char	*f_host;			/* hostname or IPv4/IPv6 address */
  int    f_fd;				/* descriptor */
  int	 f_flags;			/* F_xxx below */
} file[MAXFILES];

#define	F_CONNECTING	1	/* connect() in progress */
#define	F_READING		2	/* connect() complete; now reading */
#define	F_DONE			4	/* all done */

#define	GET_CMD		"GET %s HTTP/1.0\r\n\r\n"

			/* globals */
int		nconn, nfiles, nlefttoconn, nlefttoread, maxfd;
fd_set	rset, wset;

			/* function prototypes */
void	home_page(const char *, const char *);
void	start_connect(struct file *);
void	write_get_cmd(struct file *);
```

main函数源码位于nonblock/web.c，逻辑如下（把书上的两部分结合在一起了），home_page、start_connect、write_get_cmd函数附后：

1. 首先以命令行参数填写file结构数组
2. 接着给出的home_page函数创建一个TCP连接，发出一个命令到服务器，然后读取主页。这是第一个连接，需在我们开始并行建立多个连接之前独自完成。
3. 初始化读与写描述符集，maxfd是select需要的最大描述符（我们把它初始化成-1，因为描述符都是非负的），nlefttoread是仍待读取的文件数（当它到达0时程序任务完成），nlefttoconn是尚无TCP连接的文件数，nconn是当前打开着的连接数（它不能超过第一个命令行参数）。
4. 主循环；只要还有文件要处理（nlefttoread大于0）就循环，如果没有到达最大并行连接数而且另有连接需要建立，那就找到一个尚未处理的文件（由值为0的f_flags指示），然后调用start_connect发起另一个连接。活跃连接数（nconn）增1，仍待建立连接数（nlefttoconn）减1。
5. select等待的不是可读条件就是可写条件。有一个非阻塞connect正在进展的描述符可能会同时开启这两个描述符集，而连接建立完毕并正在等待来自服务器的数据的描述符只会开启读描述符集。
6. 遍查file结构数组中的每个元素，确定哪些描述符需要处理。对于设置了F_CONNECTING标志的一个描述符，如果它在读描述符集或写描述符集中对应的位已打开，那么非阻塞connect已经完成。正如我们随图16-11讲述的那样，我们调用getsockopt获取该套接字的待处理错误。如果该值为0，那么连接已经成功建立。这种情况下我们关闭该描述符在写描述符集中对应的位，然后调用write_get_cmd发送HTTP请求到服务器。
7. 对于设置了F_READING标志的一个描述符，如果它在读描述符集中对应的位已打开，我们就调用read。如果相应连接被对端关闭，我们就关闭该套接字，并设置F_DONE标志，然后关闭该描述符在读描述符集中对应的位，把活动连接数和要处理的连接总数都减1。

本程序还有两个优化手段（但因避免复杂而没有采用）：

1. 当select告知已经就绪的那么多描述符被处理完之后，我们可以终止select之后的for循环。
2. 如果可能的话我们可以减小maxfd的值，省得select检查那些不再设置的描述符位。

```c++
/* include web1 */
#include	"web.h"

int
main(int argc, char **argv)
{
	int		i, fd, n, maxnconn, flags, error;
	char	buf[MAXLINE];
	fd_set	rs, ws;

	if (argc < 5)
		err_quit("usage: web <#conns> <hostname> <homepage> <file1> ...");
	maxnconn = atoi(argv[1]);

	nfiles = min(argc - 4, MAXFILES);
	for (i = 0; i < nfiles; i++) {
		file[i].f_name = argv[i + 4];
		file[i].f_host = argv[2];
		file[i].f_flags = 0;
	}
	printf("nfiles = %d\n", nfiles);

	home_page(argv[2], argv[3]);

	FD_ZERO(&rset);
	FD_ZERO(&wset);
	maxfd = -1;
	nlefttoread = nlefttoconn = nfiles;
	nconn = 0;
/* end web1 */
/* include web2 */
	while (nlefttoread > 0) {
		while (nconn < maxnconn && nlefttoconn > 0) {
				/* 4find a file to read */
			for (i = 0 ; i < nfiles; i++)
				if (file[i].f_flags == 0)
					break;
			if (i == nfiles)
				err_quit("nlefttoconn = %d but nothing found", nlefttoconn);
			start_connect(&file[i]);
			nconn++;
			nlefttoconn--;
		}

		rs = rset;
		ws = wset;
		n = Select(maxfd+1, &rs, &ws, NULL, NULL);

		for (i = 0; i < nfiles; i++) {
			flags = file[i].f_flags;
			if (flags == 0 || flags & F_DONE)
				continue;
			fd = file[i].f_fd;
			if (flags & F_CONNECTING &&
				(FD_ISSET(fd, &rs) || FD_ISSET(fd, &ws))) {
				n = sizeof(error);
				if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &error, &n) < 0 ||
					error != 0) {
					err_ret("nonblocking connect failed for %s",
							file[i].f_name);
				}
					/* 4connection established */
				printf("connection established for %s\n", file[i].f_name);
				FD_CLR(fd, &wset);		/* no more writeability test */
				write_get_cmd(&file[i]);/* write() the GET command */

			} else if (flags & F_READING && FD_ISSET(fd, &rs)) {
				if ( (n = Read(fd, buf, sizeof(buf))) == 0) {
					printf("end-of-file on %s\n", file[i].f_name);
					Close(fd);
					file[i].f_flags = F_DONE;	/* clears F_READING */
					FD_CLR(fd, &rset);
					nconn--;
					nlefttoread--;
				} else {
					printf("read %d bytes from %s\n", n, file[i].f_name);
				}
			}
		}
	}
	exit(0);
}
/* end web2 */

```

home_page函数位于nonblock/home_page.c，tcp_connect会建立一个与服务器的连接，发出一个HTTP GET命令以获取主页（文件名经常是/）。读取应答（我们不对应答做任何操作），然后关闭连接。

```c++
#include	"web.h"

void
home_page(const char *host, const char *fname)
{
	int		fd, n;
	char	line[MAXLINE];

	fd = Tcp_connect(host, SERV);	/* blocking connect() */

	n = snprintf(line, sizeof(line), GET_CMD, fname);
	Writen(fd, line, n);

	for ( ; ; ) {
		if ( (n = Read(fd, line, MAXLINE)) == 0)
			break;		/* server closed connection */

		printf("read %d bytes of home page\n", n);
		/* do whatever with data */
	}
	printf("end-of-file on home page\n");
	Close(fd);
}
```

start_connect函数位于nonblock/start_connect.c，逻辑如下：

1. 调用我们的host_serv函数（图11-9）查找并转换主机名和服务名，它返回指向某个addrinfo结构数组的一个指针。我们只使用其中第一个结构。创建一个TCP套接字并利用fcntl把它设置为非阻塞。
2. 发起非阻塞connect，并把相应文件的标志设置为F_CONNECTING。在读描述符集和写描述符集中对应的位打开套接字描述符，因为select将等待其中任何一个条件变为真作为连接已建立完毕的指示。我们还根据需要更新maxfd的值。
3. 如果connect成功返回，那么连接已经建立，于是调用write_get_cmd函数（接着给出）发送一个命令到服务器。

```c++
#include	"web.h"

void
start_connect(struct file *fptr)
{
	int				fd, flags, n;
	struct addrinfo	*ai;

	ai = Host_serv(fptr->f_host, SERV, 0, SOCK_STREAM);

	fd = Socket(ai->ai_family, ai->ai_socktype, ai->ai_protocol);
	fptr->f_fd = fd;
	printf("start_connect for %s, fd %d\n", fptr->f_name, fd);

		/* 4Set socket nonblocking */
	flags = Fcntl(fd, F_GETFL, 0);
	Fcntl(fd, F_SETFL, flags | O_NONBLOCK);

		/* 4Initiate nonblocking connect to the server. */
	if ( (n = connect(fd, ai->ai_addr, ai->ai_addrlen)) < 0) {
		if (errno != EINPROGRESS)
			err_sys("nonblocking connect error");
		fptr->f_flags = F_CONNECTING;
		FD_SET(fd, &rset);			/* select for reading and writing */
		FD_SET(fd, &wset);
		if (fd > maxfd)
			maxfd = fd;

	} else if (n >= 0)				/* connect is already done */
		write_get_cmd(fptr);	/* write() the GET command */
}
```

write_get_cmd函数位于nonblock/write_get_cmd.c，它发送一个HTTP GET命令到服务器，首先构造命令并写出到套接字（fptr->f_fd)，设置相应文件的F_READING标志，它同时清除F_CONNECTING标志（如果设置了的话）。该标志向main函数主循环指出，本描述符已经准备好提供输入。在读描述符集中打开与本描述符对应的位，并根据需要更新maxfd。


```c++
#include	"web.h"

void
write_get_cmd(struct file *fptr)
{
	int		n;
	char	line[MAXLINE];

	n = snprintf(line, sizeof(line), GET_CMD, fptr->f_name);
	Writen(fptr->f_fd, line, n);
	printf("wrote %d bytes for %s\n", n, fptr->f_name);

	fptr->f_flags = F_READING;			/* clears F_CONNECTING */

	FD_SET(fptr->f_fd, &rset);			/* will read server's reply */
	if (fptr->f_fd > maxfd)
		maxfd = fptr->f_fd;
}
```

### 非阻塞accept（解决定时问题）

第6章中陈述过，当有一个已完成的连接准备好被accept时，select将作为可读描述符返回该连接的监听套接字。因此，如果我们使用select在某个监听套接字上等待一个外来连接，那就没有必要把该监听套接字设置为非阻塞，这是因为如果select告诉我们该套接字上已有连接就绪，那么随后的accept调用不应该阻塞。

不幸的是，这里存在一个可能让我们掉入陷阱的**定时问题**

下面位于nonblock/tcpcli03.c的程序把第5章的TCP回射客户程序改写成建立连接后发送一个RST到服务器，它使用了SO_LINGER套接字选项，把l_onoff标志设置为1，把l_linger时间设置为0，这样会导致调用close时会在TCP套接字上发送一个RST。

```c++
#include	"unp.h"

int
main(int argc, char **argv)
{
	int					sockfd;
	struct linger		ling;
	struct sockaddr_in	servaddr;

	if (argc != 2)
		err_quit("usage: tcpcli <IPaddress>");

	sockfd = Socket(AF_INET, SOCK_STREAM, 0);

	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_port = htons(SERV_PORT);
	Inet_pton(AF_INET, argv[1], &servaddr.sin_addr);

	Connect(sockfd, (SA *) &servaddr, sizeof(servaddr));

	ling.l_onoff = 1;		/* cause RST to be sent on close() */
	ling.l_linger = 0;
	Setsockopt(sockfd, SOL_SOCKET, SO_LINGER, &ling, sizeof(ling));
	Close(sockfd);

	exit(0);
}
```

在第6章的TCP回射服务器程序也稍作修改（下面两行带星号的是新增行），在select返回监听套接字的可读条件后但在调用accept前暂停，这是在模拟一个繁忙的服务器

```c++
　　 if (FD_ISSET(listenfd, &rset)) {　　　　/* new client connection */
+　　　　printf("listening socket readable\n");
+　　　　sleep(5);
　　　　 clilen = sizeof(cliaddr);
　　　　 connfd = Accept(listenfd, (SA *) &cliaddr, &clilen);
```

这样有可能会进入这样的场景：

1. 客户调用刚才的tcpcli03所示建立一个连接并随后中止它。
2. select向服务器进程返回可读条件，不过服务器要过一小段时间才调用accept（比如延后5秒）。
3. 在服务器从select返回到调用accept期间，服务器TCP收到来自客户的RST。
4. 这个已完成的连接被服务器TCP驱除出队列，我们假设队列中没有其他已完成的连接。
5. 服务器调用accept（sleep完毕），但是由于没有任何已完成的连接，服务器于是阻塞。

服务器会一直阻塞在accept调用上，直到其他某个客户建立一个连接为止。但是在此期间，就以图6-22给出的服务器程序为例，服务器单纯阻塞在accept调用上，无法处理任何其他已就绪的描述符。

本问题和6.8节讲述的拒绝服务攻击多少有些类似，不过对于这个新的缺陷，一旦另有客户建立一个连接，服务器就会脱出阻塞中的accept。

本问题的解决方法如下：

1. 当使用select获悉某个监听套接字上何时有已完成连接准备好被accept时，总是把这个监听套接字设置为非阻塞。
2. 在后续的accept调用中忽略以下错误：EWOULDBLOCK（源自Berkeley的实现，客户中止连接时）、ECONNABORTED（POSIX实现，客户中止连接时）、EPROTO（SVR4实现，客户中止连接时）和EINTR（如果有信号被捕获）。

## 第17章 ioctl操作

ioctl函数是那些不好分类的系统接口，很多取决于具体实现，很多网络程序经常在程序启动后使用ioctl获取所在主机全部网络接口的信息，用于网络编程的ioctl命令可划分为6类：

1. 套接字操作（是否位于带外标记等）；
2. 文件操作（设置或清除非阻塞标志等）；
3. 接口操作（返回接口列表，获取广播地址等）；
4. ARP表操作（创建、修改、获取或删除）；
5. 路由表操作（增加或删除）；
6. 流系统（第31章）。

## 第18章 路由套接字(AF_ROUTE域)

内核中的Unix路由表传统上一直使用ioctl命令访问。我们在17.9节讲解了用于增加或删除路径的2个ioctl请求：SIOCADDRT和SIOCDELRT。我们还提到没有ioctl命令可以倾泻出整个路由表，相反，诸如**netstat等程序通过读取内核的内存获取路由表的内容**。

路由套接字AF_ROUTE域定义了访问内核中路由子系统的接口，在路由域中唯一支持的套接字就是原始套接字。路由套接字支持三种操作：

1. 进程可以通过写出到路由套接字而往内核发送消息。路径的增加和删除采用这种操作实现（需要超级用户权限）。
2. 进程可以通过从路由套接字读入而自内核接收消息（需要超级用户权限）
3. 进程可以使用sysctl函数倾泻出路由表、列出所有已配置的接口、请写出ARP告诉缓存（不需要超级用户权限）。

sysctl的手册页面详细叙述了可使用该函数获取的各种系统信息，有文件系统、虚拟内存、内核限制、硬件等各方面的信息。

通过路由套接字返回的结构是sockaddr_dl结构地址，它是一种可变长度的数据链路套接字地址结构。源自Berkeley的内核把它们和接口联系起来，以便返回接口索引、名字和硬件地址。

## 第19章 密钥管理套接字（PF_KEY域）

RFC介绍了一个通用密钥管理API，可用于IPsec和其他网络安全服务，与路由域套接字类似，该API也创建了一个新的协议族即PF_KEY域（有些系统也叫AF_KEY。同样地，唯一支持的一种套接字是原始套接字。

IPsec基于**安全关联（security association，SA）**为分组提供安全服务。SA描述了源地址与目的地址（加上可选的传输协议和端口）、机制（例如认证）以及密钥素材的组合。单个分组交通流上每个方向都可以应用不止一个SA（例如一个用于认证，一个用于加密）。存放在一个系统中的所有SA构成的集合称为**安全关联数据库（security association database，SADB）**。

密钥管理套接字上支持3种类型的操作。

1. 通过写出到密钥管理套接字，进程可以往内核以及打开着密钥管理套接字的所有其他进程发送消息。
2. 通过从密钥管理套接字读入，进程可以自内核（或其他进程）接收消息。内核可以采用这种操作请求某个密钥管理守护进程为依照策略需受保护的一个新的TCP会话安装一个SA。
3. 进程可以往内核发送一个**倾泻（dumping）**请求消息，内核作为应答倾泻出当前的SADB。这是一个调试功能，并非所有系统上都一定可用。

密钥管理套接字用于在内核、密钥管理守护进程以及诸如路由守护进程等安全服务消费进程之间交换SA。SA既可以手工静态安装，也可以使用密钥协商协议自动动态安装。动态密钥有关联的生命期。当软生命期结束时，密钥管理守护进程得到通知。这样的SA如果在硬生命期结束前未被新的SA替换，那就不能再使用。

## 第20章 广播（子网所有主机都接收，有可能成为缺点）

之前的例子都是**单播（unicasting）**：一个进程只与另一个进程通信，TCP只支持单播，UDP和原始IP还支持其它寻址类型

单播

任播（IPv6引进）

多播

广播

广播的用途之一是**在本地子网定位一个服务器主机**，前提是已知或认定这个服务器主机位于本地子网，但是不知道它的单播IP地址。这种操作也称为**资源发现（resource discovery）**。另一个用途是在有多个客户主机与单个服务器主机通信的局域网环境中尽量**减少分组流通**。多播也有这两个功能。

1. ARP（Address Resolution Protocol，地址解析协议）。ARP并不是一个用户应用，而是IPv4的基本组成部分之一。ARP在本地子网上广播一个请求说“IP地址为a.b.c.d的系统亮明身份，告诉我你的硬件地址”。ARP使用链路层广播而不是IP层广播。
2. DHCP（Dynamic Host Configration Protocol，动态主机配置协议）。在认定本地子网上有一个DHCP服务器主机或中继主机的前提下，DHCP客户主机向广播地址（通常是255.255.255.255，因为客户还不知道自己的IP地址、子网掩码以及本子网的受限广播地址）发送自己的请求。
3. NTP（Network Time Protocol，网络时间协议）。NTP的一种常见使用情形是客户主机配置上待使用的一个或多个服务器主机的IP地址，然后以某个频度（每隔64秒钟或更长时间一次）轮询这些服务器主机。根据由服务器返送的当前时间和到达服务器主机的RTT，客户使用精妙的算法更新本地时钟。然而在一个广播局域网上，服务器主机却可以为本地子网上的所有客户主机每隔64秒钟广播一次当前时间，免得每个客户主机各自轮询这个服务器主机，从而减少网络分组流通量。
4. 路由守护进程。routed是最早实现且最常用的路由守护进程之一，它在一个局域网上广播自己的路由表。这么一来连接到该局域网上的所有其他路由器都可以接收这些路由通告，而无须事先为每个路由器配置其邻居路由器的IP地址。这个特性也能被该局域网上的主机用于[…]

### 广播地址

我们可以使用记法{子网ID，主机ID}表示一个IPv4地址，其中子网ID表示由子网掩码（或CIDR前缀）覆盖的连续位，主机ID表示以外的位。如此表示的广播地址有以下两种，其中-1表示所有位均为1的字段。

1. 子网定向广播地址：{子网ID，-1}。作为指定子网上所有接口的广播地址。举例来说，如果我们有一个192.168.42/24子网，那么192.168.42.255就是该子网上所有接口的子网定向广播地址。通常情况下路由器不转发这种广播，否则会造成放大攻击（**amplification**）的一类拒绝服务攻击。
2. 受限广播地址：{-1，-1}或255.255.255.255。路由器从不转发目的地址为255.255.255.255的IP数据报。诸如BOOTP和DHCP等应用在自举过程中把255.255.255.255用作目的地址，因为此时客户主机还不知道服务器主机的IP地址。

### 单播和广播的比较

首先看一个单播的例子（非常详细），以太网上有三个主机，

![20200208113031.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200208113031.png)

1. 图中以太网子网地址为192.168.42/24，其中24位作为子网ID，剩下8位作为主机ID。左侧的应用进程在一个UDP套接字上调用sendto往IP地址192.168.42.3端口7433发送一个数据报。UDP层对它冠以一个UDP首部后把UDP数据报传递到IP层。IP层对它冠以一个IPv4首部，确定其外出接口，在以太网情况下还激活ARP把目的IP地址映射成相应的48位以太网地址：00::95:79:bc:b4。该分组然后作为一个目的以太网地址为这个48位地址的以太网帧发送出去。该以太网帧的帧类型字段值为表示IPv4分组的0x0800。IPv6分组的帧类型为0x86dd。
2. 中间主机的以太网接口看到该帧后把它的目的以太网地址与自己的以太网地址（00:04:ac:17:bf:38）进行比较。既然它们不一致，该接口于是忽略这个帧。可见**单播帧不会对该主机造成任何额外开销**，因为忽略它们的是接口而不是主机。
3. 右侧主机的以太网接口也看到该帧，当它比较该帧的目的以太网地址和自己的以太网地址时，会发现它们相同。该接口于是读入整个帧，读入完毕后可能产生一个硬件中断，致使相应设备驱动程序从接口内存中读取该帧。既然帧类型为0x0800，该帧承载的分组于是被置于IP的输入队列。
4. 当IP层处理该分组时，它首先比较该分组的目的IP地址（192.168.42.3）和自己所有的IP地址。（我们知道主机可以多宿，另外回顾一下我们在8.8节就强端系统模型和弱端系统模型进行的讨论。）既然这个目的地址是本主机自己的IP地址之一，该分组于是被接受（弱端模型）。
5. IP层接着查看该分组IPv4首部中的协议字段，其值为表示UDP的17。该分组承载的UDP数据报于是被传递到UDP层。
6. UDP层检查该UDP数据报的目的端口（如果其UDP套接字已经连接，那么还检查源端口），接着在本例子中把该数据报置于相应套接字的接收队列。必要的话UDP层作为内核一部分唤醒阻塞在相应输入操作上的进程，由该进程读取这个新收取的数据报。

本例子的关键点是单播IP数据报仅由通过目的IP地址指定的单个主机接收。**子网上的其他主机都不受任何影响**。

接着考虑广播，还是同样的子网，只不过发送的是目的地址为子网定向广播地址192.168.42.255的数据报

![20200208113444.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200208113444.png)

1. 当左侧的主机发送该数据报时，它注意到目的IP地址是所在以太网的子网定向广播地址，于是把它映射成48位全为1的以太网地址：ff:ff:ff:ff:ff:ff。这个地址使得该子网上的**每一个以太网接口**都接收该帧，图中右侧两个运行IPv4的主机自然都接收该帧。既然以太网帧类型为0x0800，这两个主机于是都把该帧承载的分组传递到IP层。既然该分组的目的IP地址匹配两者的广播地址，并且协议字段为17（UDP），这两个主机于是都把该分组承载的UDP数据报传递到UDP。
2. 右侧的那个主机把该UDP数据报传递给绑定端口520的应用进程。一个应用进程无需就为接收广播UDP数据报而进行任何特殊处理：它只需要创建一个UDP套接字，并把应用的端口号捆绑到其上。（我们假设捆绑的IP地址是典型的INADDR_ANY。）
3. 然而中间的那个主机没有任何应用进程绑定UDP端口520。该主机的UDP代码于是丢弃这个已收取的数据报。该主机**绝不能发送一个ICMP端口不可达消息**，因为这么做可能产生**广播风暴（broadcast storm）**，即子网上大量主机几乎同时产生一个响应，导致网络在一段时间内不可用。另外发送该数据报的主机如何处理这些ICMP出错消息也成问题：有的接收主机报告了错误，有的未报告，那得怎么办？
4. 我们还在图中表示出由左侧主机发送的数据报也被递送给自己。这是广播的一个属性，根据定义，**广播分组去往子网上的所有主机，包括发送主机自身**。我们假设发送应用进程还绑定自己要发送到的端口（520），这样它将收到自己发送的每个广播数据报的一个副本。（然而一般说来，发送UDP广播数据报的应用进程并不需要捆绑这些数据报的目的端口。）
5. 我们在图中展示了由IP层或数据链路层执行的一个逻辑回馈，通过这个回馈，每个数据报被复制一份并沿协议栈向上传送。网络子系统也可以使用物理回馈，不过这么做在网络存在故障条件下（例如没有终结的以太网）会导致问题。

本例展示了**广播根本问题**：子网上未参加相应广播应用的所有主机也不得不沿协议栈一路向上完整地处理收取的UDP广播数据报，直到该数据报历经UDP层时被丢弃为止。

### 广播的例子与竞争状态

UDP时间获取客户程序改写成向标准daytime服务器发送一个广播请求，然后显示在5秒钟内收到的所有应答。位于bcast/dgclibcast1.c的dg_cli使用了广播，bcast/udgcli01.c使用了这个函数，注意要想接收目的地址为广播地址的数据报，必须要求广播数据报设置了SO_BROADCAST套接字选项

我们通过这个例子展示由SIGALRM信号引起的竞争状态。因为使用alarm函数和SIGALRM信号是对读操作设置超时的一个常用方法，这个微妙的错误在网络应用程序中比较常见。我们给出了解决这个问题的一个不正确办法和以下三个正确办法：

1. 使用pselect；
2. 使用sigsetjmp和siglongjmp；
3. 使用从信号处理函数到主循环的IPC（典型为管道）。

竞争状态：当有多个进程访问共享的数据，而正确结果取决于进程的执行顺序时，我们称这些进程处于**竞争状态（race condition）**。由于在典型的Unix系统中进程的执行顺序取决于每回都会发生变化的众多因素，因此处于竞争状态的进程有时产生正确的结果，有时产生不正确的结果。最难调试的一类竞争状态是通常情况下结果正确，偶尔才发生结果不正确现象的那些。

