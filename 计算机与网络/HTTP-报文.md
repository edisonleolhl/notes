---
本文摘自《HTTP权威指南》
>看完这篇文章你会理解以下概念：
> - 报文是如何流动的
> - HTTP报文的三个组成部分（起始行、首部和实体的主体部分）；
> - 请求和响应报文之间的区别；
> - 请求报文支持的各种功能（语法）；
> - 和响应报文一起返回的各种状态码；
> - 各种各样的HTTP首部都是用来做什么的；

##报文流
---
HTTP报文是在HTTP应用程序之间发送的数据块。这些数据块以一些文本形式的*元信息*（meta-information）开头，这些信息描述了报文的内容及含义，后面跟着可选的数据部分。这些报文在客户端、服务器和代理之间流动。术语“流入”、“流出”、“上游”、及“下游”都是用来描述报文方向的。
###报文流入源端服务器
HTTP使用术语*流入*（inbound）和*流出*（outbound）来描述*事务处理*（transaction）的方向。报文流入源端服务器，工作完成之后，会流回用户的Agent代理中。
###报文向下游流动
HTTP报文会想河水一样流动。不管是请求报文还是响应报文，所有报文都会向*下游*（downstream）流动。所有报文的发送者都在接收者的*上游*（upstream）。
>注：上游、下游的概念是相对的。

##报文的组成部分
---
HTTP报文是简单的格式化数据块。它们由三个部分组成：对报文进行描述的*起始行*（start line）、包含属性的*首部*（header）块，以及可选的、包含数据的*主体*（body）部分。
###报文的语法
所有HTTP报文可分为两类：*请求报文*（request message）和*响应报文*（response message）。请求报文会向服务器请求一个动作。响应报文会将请求的结果返回给客户端。两者基本结构相同。

这是请求报文的格式：
        
    <method> <request-URL> <version>
    <header>
    <entity-body>
这是响应报文的格式（注意：只有起始行的语法有所不同）：
        
    <version> <status> <reason-phrase>
    <header>
    <entity-body>

###start line（起始行）
所有的HTTP报文都以一个起始行作为开始。请求报文的起始行说明了**要做些什么**。响应报文的起始行说明**发生了什么**。

- 请求行
请求报文请求服务器对资源进行一些操作。请求报文的起始行，或成为**请求行**，包含了一个方法和一个请求URL，这个方法描述了服务器应该执行的操作，请求URL描述了要对哪个资源执行这个方法。请求行中还包含HTTP的版本，用来告知服务器，客户端使用的是哪种HTTP。

- 响应行
响应报文承载了状态信息和操作产生的所有结果数据，将其返回给客户端。响应报文的起始行，或称为**响应行**，包含了响应报文使用的HTTP版本、数字状态码，以及描述操作状态的文本形式的原因短语。

- 起始行中各部分介绍：
    - method（方法）
        - 客户端希望服务器对资源执行的动作。是一个单独的词，比如`GET /specials/saw-blade.gif HTTP/1.0`,方法就是GET。
        - 根据HTTP标准，HTTP请求可以使用多种请求方法。 
        HTTP1.0定义了三种请求方法： GET, POST 和 HEAD方法。 
        HTTP1.1新增了五种请求方法：OPTIONS, PUT, DELETE, TRACE 和 CONNECT 方法。
        - 具体方法如下：
            1.    GET    请求指定的页面信息，并返回实体主体。
            2.    HEAD    类似于get请求，但只返回首部，不会返回实体的主体部分。这就允许客户端在为获取实际资源的情况下，对资源的首部进行检查。
            使用HEAD，可以：
                - 在不获取资源的情况下了解资源的情况（比如，判断其类型）；
                - 通过查看响应中的状态码，看看某个对象是否存在；
                - 通过查看首部，测试资源是否被修改了。
            3.    POST    向指定资源提交数据进行处理请求（例如提交表单或者上传文件）。数据被包含在请求体中。POST请求可能会导致新的资源的建立和/或已有资源的修改。
            4.    PUT    从客户端向服务器传送的数据取代指定的文档的内容（即向服务器上的资源中存储数据）。
            5.    DELETE    请求服务器删除指定的页面。
            6.    CONNECT    HTTP/1.1协议中预留给能够将连接改为管道方式的代理服务器。
            7.    OPTIONS    允许客户端查看服务器的性能。
            8.    TRACE    回显服务器收到的请求，主要用于测试或诊断。
    - request-URL（请求URL）
    命名了所请求的资源，或者URL路径组件的完整URL。如果直接与服务器进行对话，只要URL的路径组件是资源的绝对路径，通常就不会有什么问题——服务器可以假定自己是URL的主机/端口。
    - version（版本）
    报文所使用的HTTP版本，其格式看起来是这样的：
    
            HTTP/<major>.<minor>
    其中*主要版本号*（major）和*次要版本号*（minor）都是整数。
    版本号说明了应用程序支持的最高HTTP版本。
    >注意：版本号不会被当作小数来处理，比较时要依次比较主要版本号和次要版本号的大小。
    - status-code（状态码）
    方法是用来告诉服务器做什么事情的，状态码则用来告诉客户端，发生了什么事情。
    比如，在行`HTTP/1.0 200 OK`中，状态码就是200。
    这三位数字描述了请求过程中所发生的情况。每个状态码的第一位数字都用于描述状态的一般类别（“成功”、“出错”等）。
    HTTP状态码由三个十进制数字组成，第一个十进制数字定义了状态码的类型，后两个数字没有分类的作用。
    
        - HTTP状态码共分为5种类型：
            - 1XX.  信息，服务器收到请求，需要请求者继续执行操作
            - 2XX. 成功，操作被成功接收并处理
            - 3XX.    重定向，需要进一步的操作以完成请求
            - 4XX.    客户端错误，请求包含语法错误或无法完成请求
            - 5XX.    服务器错误，服务器在处理请求的过程中发生了错误
            
        - HTTP常用状态码：
            - 200 成功。请求的所有数据都在响应主体中。 
            - 301 资源（网页等）被永久转移到其它URL
            - 401 需要输入用户名和密码。
            - 404 NOT FOUND 服务器无法找到所请求URL对应的资源。（**最常见**）
            - 500 内部服务器    错误
     
    >相关链接：[HTTP状态码大全](http://tools.jb51.net/table/http_status_code "HTTP状态码大全")
    >
    - reason-phrase（原因短语）
    数字状态码的可读版本，包含行终止序列之前的所有文本。原因短语只对人类有意义，比如`HTTP/1.0 200 NOT OK`和`HTTP/1.0 200 OK`中原因短语`NOT OK`和`OK`含义不同，但都会被计算机当作成功指示处理。HTTP规范并没有提供任何硬性规定要求原因短语以何种形式出现。

###header（首部）
1. 可以有零个或多个首部，每个首部包含一个名字，后面跟着冒号（:），然后是一个可选的空格，接着是一个值，最后是一个CRLF。首部是由由一个空行(CRLF）结束的，这个空行(CRLF)表示了首部列表的结束和实体主体部分的开始。
2. HTTP首部字段向请求和响应报文中添加了一些附加信息。本质上说，它们只是一些名/值对的列表。
3. 例如：

        HTTP/1.1 200 OK
        Server: nginx
        Date: Tue, 06 Sep 2016 08:56:08 GMT
        Content-Type: text/xml; charset=utf-8
        Vary: Accept-Encoding
        Content-Language: zh-CN
        Content-Encoding: gzip
4. 可以将首部分为五个主要的类型。
    - 通用首部
    有些首部提供了与报文相关的最基本的信息，无论报文是什么类型都可以为其提供一些有用信息，它们被称为通用首部。
    例如：
            Date: Tue, 06 Sep 2016 08:56:08 GMT
    >通用缓存首部：
    >1. Cache-Control    指定请求和响应遵循的缓存机制    
                Cache-Control: no-cache
    >2. Pragma    用来包含实现特定的指令    
                Pragma: no-cache
    
    >从技术角度来看，Pragma是一种请求首部，但经常被错误地用于响应首部，在任何情况下Cache-Control的使用都优于Pragma。
    - 请求首部
    只在请求报文中有意义的首部。用于说明是谁或什么在发送请求、请求源自何处，或者客户端的喜好及能力。服务器可以根据请求首部给出的客户端信息，试着为客户端提供更好的响应。
        请求的信息性首部：
        - From    发出请求的用户的Email    
                From: user@email.com
        - Host    指定请求的服务器的域名和端口号    
                Host: www.zcmhi.com
        - Referer    先前网页的地址，当前请求网页紧随其后,即来路
                Referer: http://www.zcmhi.com/archives/71.html
        - User-Agent    User-Agent的内容包含发出请求的用户信息
                User-Agent: Mozilla/5.0 (Linux; X11)
        
        1. Accept首部
        为客户端提供了一种将其喜好和能力告知服务器的方式，包括它们想要什么，可以使用什么，以及最重要的，它们不想要什么。这样服务器就可以根据这些额外信息，对要发送的内容作出更明智的决定。Accept首部会使连接的两端都收益。客户端会得到它们想要的内容，服务器则不会浪费其时间和带宽来发送客户端无法使用的东西。
            下面列出各种Accept首部：
            - Accept    指定客户端能够接收的内容类型    
                    Accept: text/plain, text/html
            - Accept-Charset    浏览器可以接受的字符编码集。
                    Accept-Charset: iso-8859-5
            - Accept-Encoding    指定浏览器可以支持的web服务器返回内容压缩编码类型。    
                    Accept-Encoding: compress, gzip
            - Accept-Language    浏览器可接受的语言    
                    Accept-Language: en,zh
            - Accept-Ranges    可以请求网页实体的一个或者多个子范围字
                    Accept-Ranges: bytes
            - TE    客户端愿意接受的传输编码，并通知服务器接受接受尾加头信息    
                    TE: trailers,deflate;q=0.5
        2. 条件请求首部
        有时客户端希望为请求加上某些限制。比如，如果客户端已经有了一份文档副本，就希望只在服务器上的文档与客户端拥有的副本有所区别时，才请求服务器传输文档。
            - Expect    请求的特定的服务器行为    
                    Expect: 100-continue
            - If-Match    只有请求内容与实体相匹配才有效    
                    If-Match: “737060cd8c284d8af7ad3082f209582d”
            - If-Modified-Since    如果请求的部分在指定时间之后被修改则请求成功，未被修改则返回304代码    
                    If-Modified-Since: Sat, 29 Oct 2010 19:43:31 GMT
            - If-None-Match    如果内容未改变返回304代码，参数为服务器先前发送的Etag，与服务器回应的Etag比较判断是否改变    
                    If-None-Match: “737060cd8c284d8af7ad3082f209582d”
            - If-Range    如果实体未改变，服务器发送客户端丢失的部分，否则发送整个实体。参数也为Etag    
                    If-Range: “737060cd8c284d8af7ad3082f209582d”
            - If-Unmodified-Since    只在实体在指定时间之后未被修改才请求成功    
                    If-Unmodified-Since: Sat, 29 Oct 2010 19:43:31 GMT
            - Range    只请求实体的一部分，指定范围    
                    Range: bytes=500-999
        3. 安全请求首部
        HTTP本身就支持一种简单的机制，可以对请求进行质询/响应认证。这种机制要求客户端在获取特定的资源之前，先对自身进行认证，这样就可以使事务稍微安全一些。
            - Authorization    HTTP授权的授权证书    
                    Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
            - Cookie    HTTP请求发送时，会把保存在该请求域名下的所有cookie值一起发送给web服务器。    
                    Cookie: $Version=1; Skin=new;
        4. 代理请求首部
        随着因特网上代理的普遍应用，人们定义了几个首部来协助其更好地工作。
            - Max-Forwards    限制信息通过代理和网关传送的时间    Max-Forwards: 10
            - Proxy-Authorization    连接到代理的授权证书    Proxy-Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
    - 响应首部
    响应首部为客户端提供了一些额外信息，比如谁在发送响应、响应者的功能，甚至于响应相关的一些特殊指令。这些首部有助于客户端处理响应，并在将来发起更好的请求。
        响应的信息性首部
        - Age    从原始服务器到代理缓存形成的估算时间（以秒计，非负）
                Age: 12
        - Retry-After    如果实体暂时不可取，通知客户端在指定时间之后再次尝试    
                Retry-After: 120
        - Server    web服务器软件名称    
                Server: Apache/1.3.27 (Unix) (Red-Hat/Linux)
        - Warning    警告实体可能存在的问题    
                Warning: 199 Miscellaneous warning
        1. 协商首部
        如果资源有多种表示方法——比如，如果服务器上有某文档的法语和德语译稿，HTTP/1.1可以为服务器和客户端提供对资源进行协商能力。
            - Accept-Ranges    表明服务器是否支持指定范围请求及哪种类型的分段请求    
                    Accept-Ranges: bytes
            - Vary    告诉下游代理是使用缓存响应还是从原始服务器请求
                    Vary: *
        2. 安全响应首部
        即HTTP的质询/响应认证机制的响应侧。现在介绍一些基本的质询首部。
            - Proxy-Authenticate    它指出认证方案和可应用到代理的该URL上的参数    
                    Proxy-Authenticate: Basic
            - Set-Cookie    设置Http Cookie    
                    Set-Cookie: UserID=JohnDoe; Max-Age=3600; Version=1
            - WWW-Authenticate    表明客户端请求实体应该使用的授权方案    
                    WWW-Authenticate: Basic
    - 实体首部
    有很多首部可以用来描述HTTP报文的负荷（即entity-body）。由于请求和响应报文中都可能包含实体部分，所以在这两类类型的报文中都有可能出现实体首部。
    实体的信息性首部
        - Allow    对某网络资源的有效的请求行为，不允许则返回405    
                Allow: GET, HEAD
        - Location    用来重定向接收方到非请求URL的位置来完成请求或标识新的资源    
                Location: http://www.zcmhi.com/archives/94.html
        1. 内容首部
        内容首部提供了与实体内容有关的特定信息，说明了其类型、尺寸以及处理它所需的其他有用信息。
            - Content-Encoding    web服务器支持的返回内容压缩编码类型。
                    Content-Encoding: gzip
            - Content-Language    响应体的语言    
                    Content-Language: en,zh
            - Content-Length    响应体的长度    
                    Content-Length: 348
            - Content-Location    请求资源可替代的备用的另一地址    
                    Content-Location: /index.htm
            - Content-MD5    返回资源的MD5校验值    
                    Content-MD5: Q2hlY2sgSW50ZWdyaXR5IQ==
            - Content-Range    在整个返回体中本部分的字节位置    
                    Content-Range: bytes 21010-47021/47022
            - Content-Type    返回内容的MIME类型    
                    Content-Type: text/html; charset=utf-8
        2. 实体缓存首部
        通用的缓存首部说明了如何或什么时候进行缓存。实体的缓存首部提供了与背缓存实体有关的信息——比如，验证已缓存的资源副本是否仍然有效所需的信息，以及更好地估计已缓存资源何时失效所需的线索。
            - ETag    请求变量的实体标签的当前值    
                    ETag: “737060cd8c284d8af7ad3082f209582d”
            - Expires    响应过期的日期和时间    
                    Expires: Thu, 01 Dec 2010 16:00:00 GMT
            - Last-Modified    请求资源的最后修改时间    
                    Last-Modified: Tue, 15 Nov 2010 12:45:26 GMT
    - 扩展首部
    扩展首部是非标准的首部，由应用程序开发者创建，但还未添加到已批准的HTTP规范中去。即使不知道这些扩展首部的含义，HTTP程序也要接受它们并对其进行转发。
>相关链接：[HTTP响应头和请求头信息对照表](http://tools.jb51.net/table/http_header "HTTP响应头和请求头信息对照表")
>注意：因为协议不同，有的首部没有给出。

###entity-body（实体的主体部分）
1. 包含一个由任意数据组成的数据块。并不是所有报文都包含实体的主体部分。
实体的主体是HTTP报文的负荷。就是HTTP要传输的内容。
2. HTTP报文可以承载很多类型的数字数据：图片、视频、HTML文档、软件应用程序、信用卡事物、电子邮件等。

##如何查看HTTP报文？
---
- 打开Chrome浏览器，点击右上角“三”按钮。
- 点击工具-----再点击开发者工具
- 找到Network选项框。
- 点击你所需要查看的请求流即可。
相关链接：[如何查看HTTP请求头](http://jingyan.baidu.com/article/a3761b2b8458321576f9aaf8.html)
