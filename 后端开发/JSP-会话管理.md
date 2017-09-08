>本文包括：
> 1. HttpSession对象
> 
> 2. session内置对象
> 
> 3. 使用session实现访问控制
> 
> 4. JSP作用域
> 
> 5. Cookie
> 
> 6. session与Cookie的比较
> 
> 7. 小试牛刀：简化用户登录

---

>**会话**：当前浏览器与服务器间多次的请求、响应关系，被称作一个会话

##1、HttpSession对象

###1.1、HttpSession对象简介

- 服务器为每个会话创建一个HttpSession对象

- 每个会话对象都有一个唯一的ID

- 把用户的数据保存在相应的HttpSession对象内

- 第一次请求时，服务器创建一个HttpSession对象，并把该对象的ID返回给用户。同时，服务器在内存中开辟一空间，用来保存该对象数据。

- 第二次请求把ID一起发送给服务器，服务器根据ID号寻找内存中相应的数据。

###1.2、HttpSession对象的存在周期

- session的创建

    浏览器访问服务器时，服务器为每个浏览器创建不同的session对象

    >严格描述：
    >
    >当服务器端调用 HttpServletRequest.getSession() 时，没有当前session，这时候才会创建一个session对象，注意，JSP本质是Servelt， JSP 文件在编译成 Servlet 时将会自动加上这样一条语句：
    >
    >HttpSession session = HttpServletRequest.getSession(true); 
    >
    >这也是 JSP 中隐含的 session 对象的来历。

- session的关闭

    1. 调用session. invalidate()方法，使session对象失效。

    1. 访问时间间隔大于非活动时间间隔， session对象失效。

        >换种说法：
        >
        >Session 超时：超时指的是连续一定时间服务器没有收到该 Session 所对应客户端的请求，并且这个时间超过了服务器设置的 Session 超时的最大时间。

    1. 关闭服务器时，session对象失效

    >注意：关闭浏览器时，**session对象不会马上失效**。

>[原始出处：深入理解 HTTP Session](http://lavasoft.blog.51cto.com/62575/275589 "原始出处：深入理解 HTTP Session")

##2、session内置对象

###2.1、session内置对象简介

1. session表示客户端与服务器的一次会话

2. Web中的session指：用户在浏览某个网站时，从进入网站到浏览器关闭所经过的这段时间，也就是用户浏览网站所花费的时间。

3. 从上述定义中可以看到，session实际是一个【特定的时间概念】

4. 服务器的内存中，保存着同用户的session。

###2.2、内置对象session的常用方法

- void setAttribute(String key,Object value)：以key/value的形式保存对象值

- Object getAttribute(String key)：通过key获取对象值 

- void invalidate()：设置session对象失效

- String getId()：获取sessionid

- void setMaxInactiveInterval(int interval)：设定session的非活动时间

- int getMaxInactiveInterval()：获取session的有效非活动时间(以秒为单位)

- void removeAttribute(String key)：从session中删除指定名称(key)所对应的对象

###2.3、session与窗口的关系

- 每个session对象都与浏览器一一对应，重新开启一个浏览器，相当于重新创建一个session对象。

- 通过超链接打开的新窗口，新窗口的session与其父窗口的session相同

##3、使用session实现访问控制

###3.1、需求说明：

- 新闻发布系统只允许管理员能够进入后台操作页面

- 普通用户只有浏览新闻和发布评论的权限

###3.2、业务分析：

1. 登录处理页面

2. 获得登录信息

3. 查询数据库，判断该用户是否注册

4. 如果该用户已注册，在session中保存该用户的登录信息

5. 如果用户是管理员就跳转到管理员界面；否则跳转到新闻发布系统的首页。

6. 管理员界面
    - 从session中提取该用户信息

    - 如果用户信息存在，显示管理员界面内容

    - 如果用户信息不存在，跳转到登录页面

###3.3、代码实现：

1. 在控制页面获取用户请求的登录信息进行验证

        <%
        if ("admin".equals(name)&&"admin".equals(pwd){  //如果是已注册用户
            //在session中存放用户登录信息    
            session.setAttribute("login", name);
            //设置session过期时间
            session.setMaxInactiveInterval(10*60);
            //请求转发
            request.getRequestDispatcher("admin.jsp") .forward(request,response);
        } else {
        response.sendRedirect("index.jsp");}
        %>

2. 在新闻发布系统新闻发布页面增加登录验证

        <%
        //session.getAttribute(String key)方法的返回值是一个Object，必须进行强制类型转换
        String login = (String) session.getAttribute("login");
            if (login == null){
                //如果session中不存在该用户的登录信息，转入登录页面
                response.sendRedirect("index.jsp");
        } %>    

###3.4、优化访问控制：

1. 除了首页面，其它页面中同样需要加入登录验证，有没有办法避免冗余代码的出现？可以将一些共性的内容写入一个单独的文件中，然后通过include指令引用该文件。

2. 创建登录验证文件 loginControl.jsp
        
        <%
        String login = (String) session.getAttribute("login");
        if (login == null)
        　　response.sendRedirect("index.jsp");
        %>

    在后台首页面中使用include指令引用登录验证文件
        
        <%@ include file="loginControl.jsp"    %>
    
    >注意：重复定义变量。

##4、JSP作用域

>作用域：信息共享的范围

###4.1、常用作用域存/取值方法

- setAttribute(String key,Object value)：采用键/值对方式在当前作用域中储存数据

- getAttribute(String key)：以键（key）方式取出当前作用域储存的值

###4.2、内置对象名称

1. page作用域指本JSP页面的范围

    - pageContext.setAttribute(键,值)

    - pageContext.getAttribute(键)

2. request作用域内的对象则是与客户端的请求绑定在一起

3. session对象作用域：一次会话

4. application的作用域：面对整个Web应用程序

##5、cookie
>cookie是Web服务器保存在**客户端**的一系列文本信息

###5.1、cookie的作用：

1. 对特定对象的追踪

    
2. 统计网页浏览次数

    
3. 简化登录

###5.2、安全性能：容易信息泄露

###5.3、语法：

- 创建cookie对象
        
        Cookie newCookie = new Cookie(String key,String value);

- 写入cookie

        response.addCookie(newCookie);

- 读取cookie

        Cookie[] cookies = request.getCookies();

###5.4、常用方法：

- void setMaxAge(int expiry)：设置cookie的有效期，以秒为单位

- void setValue(String value)：在cookie创建后，对cookie进行赋值 

- String getName()：获取cookie的名称

- String getValue()：获取cookie的值

###5.5、Cookie的中文传值问题

- 解答：
    
    Version 0 cookie values are restrictive in allowed characters. It only allows URL-safe characters. This covers among others the alphanumeric characters (a-z, A-Z and 0-9) and only a few lexical characters, including -, _, ., ~ and %. All other characters are invalid in version 0 cookies.
    
    Your best bet is to URL-encode those characters. This way every character which is not allowed in URLs will be percent-encoded in this form %xx which is valid as cookie value.
    
    So, when creating the cookie do:
    
    Cookie cookie = new Cookie(name, URLEncoder.encode(value, "UTF-8"));
    // ...
    And when reading the cookie, do:
    
    String value = URLDecoder.decode(cookie.getValue(), "UTF-8");
    // ...

- 具体做法：
    
    在JSP文件中
    
        <%@page import="java.net.URLEncoder"%>

        ...

        //创建Cookie时
        Cookie cookie = new Cookie(name, URLEncoder.encode(value, "UTF-8"));
        
        ...

        //读取Cookie时    
        String value = URLDecoder.decode(cookie.getValue(), "UTF-8");

##6、session与cookie的比较

- session是在**服务器**端保存用户信息，Cookie是在**客户端**保存用户信息

- session中保存的是**对象**，Cookie保存的是**字符串**

- session随会话结束而关闭，Cookie可以长期保存在客户端

- 不重要的信息使用**cookie**保存，重要的信息使用**session**保存

##7、小试牛刀：简化用户登录

###7.1、需求说明：

- 用户第一次登录时需要输入用户名和密码

- 在5分钟内，无需再次登录则直接显示欢迎页面

###7.2、实现思路：

1. 用户登录后，创建cookie保存用户信息

2. 设置cookie的有效期为5分钟

3. 在登录页循环遍历cookie数组，判断是否存在指定名称的cookie，若存在则直接跳转至欢迎页面

>提示：使用setMaxAge(5*60)设置cookie的有效期
