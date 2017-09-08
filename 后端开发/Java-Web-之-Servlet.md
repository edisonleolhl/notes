>本文包括：

>1. Servlet简介
>
>2. 关于Servlet的一些类

>3. Servlet生命周期

>4. ServletConfig获得初始化参数

>5. web引用对象——ServletContext（上下文）

>6. 缺省Servlet

##1、Servlet简介

- Servlet技术基于Request-Response编程模型 ---- HTTP协议也是基于此模型（请求-响应模型） 

- Sun公司在其API中提供了一个Servlet接口，用户若想开发一个动态web资源（即开发一个Java程序向浏览器输出数据），需要完成以下两个步骤：
    - 编写一个Java类，实现Servlet接口

    - 把开发好的Java类部署到web服务器中

- 快速入门，用Servlet向浏览器输出“hello servlet”

    - 使用MyEclipse创建web project

    - 通过向导创建Servlet继承HttpServlet，假设新建的Java文件为：cn.itcast.servlet.HelloServlet.java

    - 在web.xml配置Servlet程序，配置Servlet虚拟路径（用户通过这个虚拟路径访问Servlet程序）

    >        <!-- 为 HelloServlet 配置 浏览器可以访问虚拟 路径 -->    
            <servlet>
                <!-- 为 Servlet程序  命名 -->
                <servlet-name>HelloServlet</servlet-name>
                <!-- Servlet全路径 ： 包名.类名 -->
                <servlet-class>cn.itcast.servlet.HelloServlet</servlet-class>
            </servlet>
        
    >        <servlet-mapping>
                <!-- 为Servlet程序 指定 浏览器访问 虚拟路径 -->
                <servlet-name>HelloServlet</servlet-name>
                <!-- 用户 在 浏览器通过/hello 访问Servlet -->
                <url-pattern>/hello</url-pattern>
            </servlet-mapping>

    - 覆写（override）doGet或者doPost方法（一般修改为public），在里面撰写代码，进行输出

###执行过程

1. 用户在客户端发起url请求 ： http://localhost/day05/hello 
    >在当前项目下，服务器会找到 web.xml 中URL为hello的servlet-mapping，然后得到servlet-name，再找到servlet-class，即映射 HelloServlet程序

2. 用户提交请求时，若为get方式提交，则执行HelloServlet的doGet方法；若为post方式提交，则执行HelloServlet的doPost方法 

###Servlet程序在编写和运行时，需要javaee 类库 （API支持）

- 在学习javase时，想用List必须要import java.util.List，则需要JDK中jre/lib/rt.jar 

- MyEclipse创建webproject，则会自动导入 javaee5 liberary，其中存在 javaee.jar ，它提供 Servlet 所需要的API支持 （开发环境使Servlet程序正常编译）

- Serlvet程序运行tomcat环境中，webapps\项目名字\WEB-INF\lib中没有javaee.jar, 其实jar包在tomcat的根目录的lib中，，tomcat/lib/servlet-api.jar 提供了Servlet程序运行所需要的API支持 （运行环境需要的）

###手动编写Servlet运行

1. 在tomcat\webapps 新建 day05test目录 --- 虚拟应用

2. 在day05test 新建 WEB-INF\classes

3. 将编写Servlet的java源码文件放入 classes ，在 WEB-INF下配置web.xml 

4. 编译Servlet的 java程序 

        javac -classpath E:\apache-tomcat-6.0.14\lib\servlet-api.jar HelloServlet.java
    >通过 -classpath 参数指定 Servlet所需要的jar包，该jar包位于`E:\apache-tomcat-6.0.14\lib\servlet-api.jar `

    生成Servlet package结构 
        
        javac -d . -classpath E:\apache-tomcat-6.0.14\lib\servlet-api.jar HelloServlet.java
    >通过 `-d . `，可以自动生成package（根据java文件的首行代码：`package XX.XX.XX;`

##2、关于Servlet的一些类

- Servlet接口

    - 定义了所有Servlet需要实现的方法

    - 它定义了init destory service等方法

    - 为了解决基于请求-响应模型的数据处理（没有涉及与HTTP协议相关的API）
    
- GenericServlet抽象类

    - 它是Servlet接口的实现类

    - 它扩展了一些方法

    - 也没有涉及与HTTP协议相关的API
    
- HttpServlet抽象类

    - 它继承于GenericServlet

    - 它新增了一些与HTTP协议相关的方法，如doGet，doPost等等
    
    - HttpServlet在实现Servlet接口时，覆写了service方法，该方法内的代码会自动判断用户的请求方式，如为GET请求，则调用HttpServlet的doGet方法，如为Post请求，则调用doPost方法。**因此，程序员在编写Servlet时，通常只需要覆写doGet或doPost方法，而不要去覆写service方法**。

- HttpServlet比Servlet更为强大，也可以保护Servlet接口不被轻易改动，**所以程序员自己创建的Servlet都是继承于HttpServlet**，从而*间接地*实现了Servlet接口。

##3、Servlet生命周期 

- 生命周期

    1. 实例化：Servlet 容器创建 Servlet 的实例
    
    2. 初始化 ：该容器调用 init 方法
    
    3. 请求处理：如果请求 Servlet，则容器调用 service 方法
    
    4. 服务终止：销毁实例之前调用 destroy 方法

    >其中，init方法只有在Servlet第一次被请求加载时被调用一次，当有客户再请求Servlet服务时，**web服务器将启动一个新的线程**，在该线程中，调用service方法响应客户的请求。

- 常用方法

    - init(ServletConfig config)  初始化 
    
    - service(ServletRequest req, ServletResponse res)  提供服务方法
    
    - destroy()  销毁 

- 特征

    1. tomcat服务器启动时，没有创建Servlet对象
    
    2. 第一次访问时，tomcat构造Servlet对象（可以重写无参构造方法来测试），然后调用init方法，再执行service方法。 
    
    3. 从第二次以后访问 tomcat 不会重新创建Servlet对象，也不会调用init ---- 但每一次访问都会创建一个新的线程，线程中都会调用service方法。
    
    4. 当服务器重启或正常关闭时 调用destroy方法（正常关闭 shutdown.bat）

    >注意：
    >
    >- Servlet对象是tomcat创建的，tomcat服务器会在每次调用Servlet的service方法时，为该方法创建HttpServletRequest对象和HttpServletResponse对象。 
    >    
    >- 在JavaEE的API中没有Request和Response实现类 ----- **实现类由Servlet服务器提供**，即tomcat、weblogic等服务器提供这两个实现类。
    >
    >- service方法 和 HttpServlet doGet/doPost 关系区别？ ----- 必须阅读HttpServlet源代码。 
    在HttpServlet代码实现中，根据请求方式不同，调用相应doXXX方法：get方式请求 --- doGet ； post方式 --- doPost 。（**即service方法的作用是：判断请求方式，再根据请求方式执行HttpServlet的doGet或者doPost方法**）

###一个Servlet可以配置多个url-pattern 

- URL 配置格式 三种：

    1. 完全路径匹配  (以/开始 ) 例如：/hello/init 
    
        * 当前工程没有被正确发布，访问该工程所有静态资源、动态资源 发生404 ----- 工程启动时出错了 
    
        * 查看错误时 分析错误
    
            - 单一错误 ： 从上到下 查看第一行你自己写代码 （有的错误与代码无关，查看错误信息）
    
            - 复合错误 Caused by ---- 查看最后一个Caused by 
    
    2. 目录匹配 (以/开始) 例如：`/*` 、 `/abc/*`
     
        `/` 代表网站根目录 
    
        `/*`表示任何路径都可以匹配到这个Servlet
    
        `/abc/*`表示abc目录下的任何路径都可以匹配到这个Servlet
    
    3. 扩展名 (不能以/开始) 例如：`*.do`、 `*.action`
         
        典型错误： `/*.do` 

- 优先级：完全匹配>目录匹配 > 扩展名匹配 

###相对路径与绝对路径的区别

- 前提：某Servlet在web.xml中的url-pattern的内容一般为`/myServlet`，其中，`/`表示根目录，假设项目名字为MyProject，则该Servlet的URL为：`http://localhost:8080/MyProject/myServlet`.

- 在JSP或者HTML页面中的form表单中的action属性需填写Servlet的URL，这里就牵涉到了相对路径与绝对路径的问题。
    
    - 若采用相对路径
        - 假设该JSP或者HTML页面位于网站根目录，而从“前提”可知Servlet也位于根目录，则直接在action中填写`myServlet`即可。
        
        - 假设该JSP或者HTML页面位于网站根目录的aaa文件夹中，则需要在action中填写`../myServlet`
    
    - 若采用绝对路径（绝对路径 以`/`开始，`/`访问服务器根目录） 
        - 不管该JSP或者HTML页面位于网站哪个地方，在action中填写`MyProject/myServlet`即可。

##4、ServletConfig获得初始化参数

- init方法中的ServletConfig对象

    - 在Servlet的配置文件中，可以使用一个或多个<init-param>标签为servlet配置一些初始化参数。
    
    - 当Servlet配置了初始化参数后，web容器在创建Servlet实例对象时，会自动将这些初始化参数封装到ServletConfig对象中，并在调用Servlet的init方法时，将ServletConfig对象传递给Servlet。进而，程序员通过ServletConfig对象就可以得到当前Servlet的初始化参数信息。

- 获取ServletConfig

    1. 创建一个Servlet
    
    2. 在web.xml 中 `<servlet>` 标签内 通过 `<init-param>` 标签 为Servlet配置初始化参数

            <init-param>
                <param-name>itcast</param-name>
                <param-value>传智播客</param-value>
            </init-param>

    3. 在Servlet程序中通过ServletConfig对象 获得itcast对应数据，ServletConfig有两个方法如下：

        - getInitParameter（String） ------ 通过name获得value
    
        - getInitParameterNames()  ----- 获得所有name 

- 思考 ：如何在doGet或doPost方法中获得Servlet初始化参数？ 

    将ServletConfig对象保存实例成员变量：

    GenericServlet已经将ServletConfig保存为成员变量   -----故在子类中通过getServletConfig方法获得初始化参数即可

- 结论：子类Servlet不需要覆写init(ServletConfig), 只需要通过GenericServlet中 getServletConfig()方法来获得ServletConfig对象。

>ServletConfig 配置初始化数据，只能在配置Servlet获得，其它Servlet无法获得  ----- 每个Servlet程序都对应一个ServletConfig对象 

##5、web引用对象——ServletContext（上下文）

- web容器在启动时，它会为每一个web应用创建一个ServletContext对象，这个对象代表当前web应用。

- 操作ServletContext必须通过ServletConfig获得对象。可以通过ServletConfig.getServletContext方法来获得ServletContext对象。

- 由于一个web应用中的所有Servlet共享同一个ServletContext对象，因此Servlet对象之间可以通过ServletContext对象来实现通讯。ServletContext对象通常也被称之为context**域**对象。

- 应用：

    1. 获得整个web应用初始化参数
    
        - 和ServletConfig对象有什么不同？
        
            如果用ServletConfig对象配置参数，只对配置的Servlet有效，如果通过ServletContext对象配置参数，所有的Servlet都可以访问。

        - 配置方法，在web.xml中添加如下格式的代码：

                <!-- 配置全局初始化参数，所有Servlet都可以 访问 -->
                <context-param>
                    <param-name>hobby</param-name>
                    <param-value>唱儿歌</param-value>    
                </context-param>

        - 获得 hobby 全局参数：

                // 通过ServletConfig 获得 ServletContext
                ServletContext context = getServletConfig().getServletContext();
        
                // 上面写法可以简化一下
                ServletContext context = getServletContext();
        
                // 读取全局初始化参数
                System.out.println(context.getInitParameter("hobby"));

    2. 实现全局数据共享
    
        - 预期效果：在ServletContext中 保存站点访问次数 ，每当一个用户访问站点，将访问次数+1。所有Servlet都可以获得该数据

        - 在CountServlet 初始化过程中，向ServletContext 保存访问次数为0。
        利用`ServletContext.setAttribute("KEY","VALUE");` 

        - 代码实现(只显示init方法和doGet方法：

                public void init() throws ServletException {
                    // 向ServletContext 保存访问次数 0
                    // 获得ServletContext对象
                    ServletContext context = getServletContext();
                    // 保存数据 setAttribute
                    context.setAttribute("visittimes", 0);
                }
            
                public void doGet(HttpServletRequest request, HttpServletResponse response)
                        throws ServletException, IOException {
                    // 每次访问 执行 doGet --- 将visittimes 次数 +1
            
                    // 1、从ServletContext中获得 访问次数
                    ServletContext context = getServletContext();
                    int times = (Integer) context.getAttribute("visittimes");
            
                    // 2、访问次数 +1
                    times++;
            
                    // 3、将访问次数更新回去 ServletContext
                    context.setAttribute("visittimes", times);
            
                    System.out.println("网站被访问了一次！");
                }

    3. 实现服务器端转发功能（少见，现在多用request、response）
    
         - 某Servlet的doGet中：

                // 交给下一个Servlet显示 ，将统计结果保存ServletContext
                ServletContext context = getServletContext();
                //times是int型数组
                context.setAttribute("times", times);
        
                // 转发跳转 另一个Servlet
                RequestDispatcher dispatcher = context
                        .getRequestDispatcher("/servlet/result"); // 这里面就是另一个Servlet的URL，绝对地址
                dispatcher.forward(request, response);

        - 在另一个Servlet的doGet中：

                ServletContext context = getServletContext();
                int[] times = (int[]) context.getAttribute("times");
                ...

    4. 读取web工程资源文件（必须使用绝对磁盘路径）

        - 使用java application 读取文件，读取当前工程下所有文件  ----- 使用相对路径读取文件。

        - 使用Servlet读取文件只能读取WebRoot下所有文件(注意Servlet是运行在tomcat中的）  ---- **必须使用绝对磁盘路径读取文件**。

            - 如何获得绝对磁盘路径？
            
                - 通过站点根目录绝对路径获得磁盘绝对路径 ------ `getServletContext().getRealPath("/WEB-INF/XXX.txt")`

                - 因为 WEB-INF/classes 非常特殊 （存放.class文件目录），被类加载器加载，可以通过Class类对象读取该目录下文件（假设该Servlet名字叫做ReadFileServlet）。
                
                        Class c = ReadFileServlet.class; // 通过Class对象读取文件                
                        String filename3 = c.getResource("/a1.txt").getFile(); // 这里的"/" 等价于 "/WEB-INF/classes"

##6、缺省Servlet

- 如果某个Servlet的映射路径仅仅为一个正斜杠“/”，那么这个Servlet就成为当前web应用的缺省Servlet。

- 凡是在web.xml文件中找不到匹配的URL，它们的访问请求都将交给缺省Servlet处理，也就是说，缺省Servlet用于处理其他Servlet都不处理的访问请求。

- 在<tomcat的安装目录>\conf\web.xml文件中，注册了一个名称为org.apache.catalina.servlets.DefaultServlet的Servlet，并将这个Servlet设置为了缺省Servlet。

- **当访问tomcat服务器中的某个静态HTML和图片时，实际上是在访问这个缺省的Servlet**。
