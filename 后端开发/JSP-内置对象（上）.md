>本文包括：
>
>1. out（常用）
>
>2. request（重点）
>
>3. response（重点）
>
>4. get与post（难点）
>
>5. 请求重定向与请求转发（难点）

#JSP内置对象简介
1. JSP内置对象是Web容器创建的一组对象，【不使用new关键字】就可以使用的内置对象。
    - 例如：
        
        ![](http://upload-images.jianshu.io/upload_images/2106579-d2435b627ffee5c6.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2. JSP九大内置对象：

    - out、request、response、session、application（五大常用对象）

    - Page、pageContext、exception、config（四个不太常用对象）

##1、out（常用）

###1.1、什么是缓冲区？

- 缓冲区：Buffer，所谓缓冲区就是内存的一块区域用来保存临时数据。

- 比如：IO输出最原始的就是一个字节一个字节输出，就像一粒一粒吃一样，效率太差。缓冲区可以先将多个字节读出来，再一次性的输出，提高效率。

###1.2、out对象
1. out对象是JspWriter类的实例，是向客户端（这里指浏览器）输出内容的常用对象。

2. 常用方法：

    ![](http://upload-images.jianshu.io/upload_images/2106579-12f61e6e82d0fb32.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##2、request（重点）

###2.1、request对象

- 介绍与方法
    
    ![](http://upload-images.jianshu.io/upload_images/2106579-89b13888cf579bcc.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
    
    ![](http://upload-images.jianshu.io/upload_images/2106579-c070f67276e518bc.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
    

###2.2、示例：String[] getParameterValues(String name)

- 方法比较：
    - String getParameter(String name)//获取单个参数值

    - String[] getParameterValues(String name)//获取多个参数值（获得提交参数具有相同名称的集合），如获取checkbox的值

- 比如这个注册表单：

    ![](http://upload-images.jianshu.io/upload_images/2106579-8fe639ef9fb63e8a.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 数据提交到request.jsp页面：

    ![](http://upload-images.jianshu.io/upload_images/2106579-e9a1e6a05f7eaf58.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 运行结果：

    ![](http://upload-images.jianshu.io/upload_images/2106579-5fd0fe76c3bccc28.gif?imageMogr2/auto-orient/strip)

###2.3、示例：setAttribute()\getAttribute()

- 方法比较：
    
    - setAttribute()设置属性时是以键值对的形式

    - getAttribute()获取属性只需要输入键的值，就可以获得属性的值。

- 示例：

    ![](http://upload-images.jianshu.io/upload_images/2106579-daf9211894be5f17.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###2.4、示例：其他参数
- 方法：
    - 请求体的MIME类型：<%=request.getContentType() %><br>
    
    - 协议类型及版本号：<%=request.getProtocol() %><br>
    
    - 服务器主机名：<%=request.getServerName() %><br>
    
    - 服务器端口号：<%=request.getServerPort() %><br>
    
    - 请求文件的长度：<%=request.getContentLength() %><br><!--单位是字节-->
    
    - 请求客户端的IP地址：<%=request.getRemoteAddr() %><br><!--//只能获取静态的IP地址，动态的话获取不到-->
    
    - 请求的真实路径：<%=request.getRealPath("request.jsp") %><br>
    
    - 请求的上下文路径：<%=request.getContextPath() %><br><!--是项目的虚拟路径-->

- 运行结果
    
    ![](http://upload-images.jianshu.io/upload_images/2106579-7be98d3fa92944fd.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###2.5、解决url传中文参数出现乱码问题:

- 表单post方式：

    ![](http://upload-images.jianshu.io/upload_images/2106579-9d051376ac7d10a7.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 解决措施：

        request.setCharacterEncoding(“utf-8”);//解决post请求传递中文参数的乱码问题，设置的编码要与发送请求的页面的编码设置的一致。但是无法解决URL链接传递中文参数的乱码问题。

- URL传值（get）方式：

    ![](http://upload-images.jianshu.io/upload_images/2106579-738f86bb0081767e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 解决措施：
    URL传中文参数不能用setCharacterEncoding("utf-8")解决，可通过修改TOMCAT的conf文件夹下server.xml解决，在connector标签添加属性**URIEncoding="utf-8**"。
    
    tomcat > conf> server.xml
        
        <Connector port="8080" protocol="HTTP/1.1"
        connectionTimeout="20000"
        redirectPort="8443" URIEncoding="utf-8"
        />

##3、response（重点）

###3.1、response对象

- response对象具有页面作用域，即访问一个页面时，该页面的response对象只对本次访问有效，其他页面的response对象对当前页面无效。
- 常用方法
    
    - String setCharacterEncoding()//设置响应字符编码格式
    
    - String getCharacterEncoding()//获取响应字符编码格式
    
    - void setContentType(String type)//设置响应MIME类型
    
    - **sendRedirect(java.lang.String location)//请求重定向**
    
    - PrintWriter getWriter()//获取打印输出对象

    >注意：PrintWriter对象的输出先于内置out对象
    >解决方法：
        out.println();
        out.flush();//清空缓冲区并将缓冲区内容输出到浏览器，这样就可以先输出out，再输出PrintWriter（即按照代码顺序执行）
        PrintWriter outer=response.getWriter();
        outer.println();

##4、get与post（难点）

###表单有两种提交方式：get与post。
- 定义方式如下所示：
    
        <form action="dologin.jsp" name="loginForm" method="提交方式***"></form>

- 特点：
    - get：以【**明文**】方式，通过URL提交数据，数据在URL中**可以看到**。提交数据最多不超过【**2KB**】。**安全性较低**，但效率比post方式高。适合提交**数据量不大**，且**安全要求不高**的数据：比如：搜索、查询等功能。

    - post：将用户提交的信息封装在HTML HEADER内，数据在URL中【**不能看到**】适合提交**数据量大，安全性高**的用户信息。如：注册、修改、上传等功能。

###区别：

1. post隐式提交，get显示提交

2. post安全，get不安全

3. get提交数据的长度有限(255字符之内)，post无限
    
###什么情况下是GET提交，什么情况下又是POST提交呢？

1. GET提交：
    1)、默认的表单提交方法

    2)、以“<A（括回）”链接的方法提交数据

    3)、直接在地址栏的URL中追加数据

    4)、js中使用location.href='xxxxx';

2. POST提交：

    1)、显示指定表单的method为POST，绝大多数的表单都采用POST提交，只有向Baidu、Google这样的搜索引擎才采用GET方法提交
    
###编码格式转换

- post请求编码格式转换:
     
        request.setCharacterEncoding("utf-8");

- get请求编码格式转换:
    
        String s=request.getParament(“stu”);
         String str=new String(s.getBytes(“iso8859-1”),“utf-8”);

##5、请求重定向与请求转发（难点）
1. 请求重定向：
        
        response.sendRedirect("xx.jsp");//重定向
    【客户端行为】：即客户端会访问两次，第一次访问后会立即跳转到第二个重定向页面上，【从本质上讲等于两次请求】，而前一次的请求封装的request对象不会保存，地址栏的**URL地址会改变**。
2. 请求转发：
    
        request.getRequestDispatcher("xx.jsp").forward(request,response);//请求转发
    forward(request,response)用于保存内置对象request和response。
    【服务器行为】：服务器会代替客户端去访问转发页面，【从本质是一次请求】，转发后请求对象会保存，地址栏的**URL地址不会改变**。

3. 区别

    - 请求重定向从本质上讲等于两次请求，而请求转发从本质上将等于一次请求。
    
    - 转发是在服务器端发挥作用，通过forward方法将提交信息在多个页面间进行传递。
    
    - 转发是在服务器内部控制权的转移，客户端浏览器的地址栏不会显示出转向后的地址，即地址栏URL不变。
    
    - 重定向是通过浏览器重新请求地址，在地址栏中可以显示转向后的地址，即地址栏URL会变。

4. 形象解释：

    ![](http://upload-images.jianshu.io/upload_images/2106579-2957f038f870f2b8.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

>本文参考：http://www.imooc.com/learn/166
