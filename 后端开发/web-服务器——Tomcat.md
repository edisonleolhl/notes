web开发 ------ 网站制作 

互联网上资源两类：静态、动态

静态资源：固定数据文件（图片、文本、音频、视频、静态网页文件 html）
动态资源：通过程序生成数据文件 

网页设计：
静态网页 ： HTML CSS JavaScript 静态网页开发技术

动态网页技术： 98前后 ASP PHP JSP
.net(微软技术集合 VB ASP C#) 、python、ruby(快速开发网页 语言 10分组开发一套博客系统【脚手架】)

当今网站开发 主流技术： ,net 和 php

学习javaweb ----- CRM 、ERP、OA 定制web界面

JVM支持多种脚本 语言： Jruby Groovy 

Web系统 采用 B/S结构 ：Browser -- Server 
1、浏览器向服务器发送访问目标资源请求 (请求)
2、服务器根据请求的目标资源路径，在服务器端进行查找 (请求处理)
3、服务器会将查找结果 返回给客户端浏览器 (响应)
* 在B/S系统中必须先产生请求，才会生成响应 ---- 请求和响应时成对出现的

什么是web服务器？ 
硬件环境、软件环境 
在网络中安装web服务软件的计算机 

web服务器软件环境搭建 
1、weblogic  BEA公司产品 ，随着BEA已经被oracle收购 ---- 全面支持JavaEE 所有规范 ，收费的
2、websphere IBM 公司产品，功能比weblogic更加强大和复杂 ----- 全面支持JavaEE 规范，收费
3、Apache Tomcat 免费、开源 Google 很多java开发web应用都是搭建tomcat环境上   ---- 在企业中小型java项目都是搭建tomcat上
* tomcat 不支持所有javaee规范，只支持 Servlet/JSP/JNDI/JavaMail 等JavaEE规范

JBOSS --- EJB服务器  JBOSS公司产品 

##Tomcat服务器

- Apache Tomcat下载主页：http://tomcat.apache.org/

- 获取Tomcat安装程序包

    - tar.gz（zip）文件是Linux操作系统下的安装版本

    - exe文件是Windows系统下的安装版本

    - zip文件是Windows系统下的压缩版本

- 解压缩Tomcat的目录不要含有空格或中文。

- 配置JAVA_HOME环境变量：配置JDK的安装路径，注意路径不要加分好结尾。

###启动Tomcat服务器

1. 在Tomcat的目录下，双击bin/startup.bat (如果使用linux 双击bin/startup.sh)。

2. 在浏览器地址栏输入 http://localhost:8080/ ，如果出现tomcat网站主页，则说明启动成功。 
    ![](http://upload-images.jianshu.io/upload_images/2106579-a89df2d9313c7bde.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###Tomcat启动问题

- 窗口一闪然后消失 ----- 记事本打开startup.bat 在文件末尾加入 pause指令，再次运行，读取错误原因，根据原因解决。
    >JAVA_HOME路径必须是JDK不可以是JRE

- 端口占用问题（Tomcat的默认端口号为8080）
    
    1. 发现端口被占用后，通过cmd命令行，查看占用端口进程，CMD命令：netstat -ano （xp win7 通用），找到8080端口号的进程，记住它的PID(进程标识符），然后在任务管理器中找到该PID，关闭该PID对应的进程。

    2. 如果在任务管理器发现该占用8080端口的进程的PID是4，映像名称是System，这个进程无法关闭，如果出现这种情况证明了一个服务占用端口。这时候通过services.msc关闭www服务即可。
    
- CATALINA_HOME环境变量
指定tomcat安装位置 （该环境变量可以不配置） ---- 但是如果配置出错，tomcat将无法启动

###Tomcat、Servlet/JSP、JavaEE、JDK版本之间的关系

Tomcat版本|    Servlet/JSP版本    |JavaEE版本|    运行环境|
---|---|---|---
4.1    |    2.3/1.2|        1.3|        JDK1.3
5.5    |    2.4/2.0|        1.4|        JDK1.4
6.0    |    2.5/2.1|        5.0|        JDK5.0
7.0    |    3.0/2.2|        6.0|        JDK6.0

Tomcat支持Servlet和JSP，Servlet属于JavaEE规范 

- 随着javaEE 版本提升 -- Servlet版本提升 --- 运行Servlet环境Tomcat版本提升 

- tomcat运行需要JDK 环境版本 

##Tomcat目录结构

bin ---- 存放tomcat启动关闭程序 

conf --- 存放tomcat 配置文件

lib --- tomcat运行需要jar包

logs ---- tomcat日志文件

webapps ----  网站发布目录 （所有网站可以发布到该目录）

work ----- 存放工程运行时，产生数据文件 (JSP翻译Servlet、Session持久化数据 )

###web应用程序

- web应用程序指供浏览器访问的程序，通常也简称为web应用。

- 一个web应用由多个静态web资源和动态web资源组成，如:

    - html css javascript 图片 音频 视频 文本 --静态web资源

    - 程序Servlet、JSP ---动态web资源

    - 配置文件等等

    - 组成web应用的这些文件通常我们会使用一个目录组织，这个目录称之为web应用所在目录（网站的根目录)

- web应用开发好后，若想供外界访问，需要把web应用所在目录交给web服务器管理（将网站发布到web服务器Tomcat上），这个过程称之为虚拟目录的映射。

###网站的标准目录结构

站点根目录：

    -------静态web资源、jsp

    -------WEB-INF目录
                  -------  classes目录 （保存.class文件）
                  --------  lib  目录 (当前网站需要jar包) 
                  -------- web.xml (网站配置文件)

- WEB-INF目录不是必须的，没有Java动态程序代码，可以没有WEB-INF目录。

- **WEB-INF目录下资源不能被浏览器直接访问！**
    >可以测试一下：在Tomcat的目录下的webapps中新建文件夹（即创建网站根目录），创建两个HTML文件，其中一个在网站根目录下，另外一个在WEB-INF目录下。打开服务器，打开浏览器，发现在WEB-INF目录下的HTML网页不能访问，在网站根目录的网页可以访问。

###tomcat发布web应用的三种方式
原理：配置`<Context>`元素

1. 配置tomcat/conf/server.xml 
 在标签`<Host name="localhost" >` 内部 添加 `<Context>` 元素。
`<Context path="/aa" docBase="C:\AA" />` ----- > 为网站配置虚拟目录 /aa ---- 映射到 c:\AA 目录
    >修改server.xml 重启tomcat

2. $CATALINA_HOME/conf/[enginename]/[hostname]/xxx.xml
tomcat/conf/Catalina/localhost/xxx.xml  
在conf下新建 Catalina 
在Catalina下新建 localhost
在localhost下 新建 bb.xml 
`<Context docBase="C:\BB" />` ------ 为什么不需要写path ---- 虚拟目录就是文件名bb path值 默认 `/bb`

    >1. 添加 bb.xml 不用重启tomcat

    >2. 推荐第二种写法（不需要重启服务器，而且出错不会影响其它工程运行），尽量不要使用第一种 

3. 将网站复制到tomcat/webapps，让tomcat自动映射：tomcat服务器会自动管理webapps目录下的所有web应用，并把它映射成虚拟目录。换句话说，tomcat服务器webapps目录中的web应用，外界可以直接访问。

    >1. 不用重启tomcat

    >2. tomcat 会根据文件夹名称，自动生成虚拟路径 CC文件夹 ---- 虚拟路径 /CC

>虚拟目录？ 
>
>- 浏览器访问网站采用访问路径 /aa /bb /abc ---- 这些路径不一定是服务器真实存在目录，只是浏览器在访问这些路径时，映射到指定网站根目录。

>WAR包制作 ? 
>
>- 当网站非常大，数据非常多，将开发平台网站发布到服务器运行环境 （在java发布便利性 war包 ）

>- 什么是war包？ zip格式应用数据压缩包  （不能是rar格式）

>- 先用压缩软件 将网站制作xx.zip  --- 重命名 xx.war --- 复制.war文件到tomcat/webapps
