#Servlet
---
>Servlet是一个Java程序，是在**服务器**上运行以处理客户端请求并做出响应的程序。

## 初识Servlet ##
- 步骤1：导入所需的包、处理请求的方法、将数据发送给客户端

        import java.io.*;
        import javax.servlet.*;
        import javax.servlet.http.*;
        //继承HttpServlet类
        public class HelloServletTest extends HttpServlet { 
          public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {          
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<html>");
            out.println("  <head><title>Servlet</title></head>");
            out.println("  <body>");
            out.println("你好，欢迎来到Servlet世界");
            out.println("  </body>");
            out.println("</html>");
            out.close();
         }
        }
- 步骤2：在web.xml文件中配置Servlet

        <web-app>
        <servlet>
            <servlet-name> HelloServlet </servlet-name> 
            <servlet-class> com.HelloServlet </servlet-class>
        </servlet>
        
        <servlet-mapping>
            <servlet-name> HelloServlet </servlet-name>
            <url-pattern> /HelloServlet </url-pattern>
        </servlet-mapping>
        </web-app>

    注意：
    - <servlet-name标签中的名称必须相同
        - 第一个是设定当前servlet的内部名称(对象名)
        - 第二个 通过servlet内部名把访问路径与Class绑定
    - <servlet-class标签中是完整的**包名+类名**，指定对应servlet内部相关类
    - <url-pattern标签中访问Servlet的URL，用户访问servlet时的路径名，一定要加上**” / ”**

##servlet的生命周期
1. 实例化：Servlet 容器创建 Servlet 的实例
2. 初始化 ：该容器调用 init() 方法
3. 请求处理：如果请求 Servlet，则容器调用 service() 方法
4. 服务终止：销毁实例之前调用 destroy() 方法

##servlet的相关类
Servlet 、 ServletConfig     ——接口
|
GenericServlet                ——抽象类
    |
HttpServlet                    ——抽象类

###Servlet接口
- 定义了所有Servlet需要实现的方法

###ServletConfig接口
- 在Servlet初始化过程中获取配置信息
- 一个Servlet只有一个ServletConfig对象

###GenericServlet抽象类
- 提供了Servlet与ServletConfig接口的默认实现方法

###HttpServlet概述
- 继承于GenericServlet
- 处理HTTP协议的请求和响应

###请求、响应相关接口   
请求：
    
    ServletRequest
        |
    HttpServletRequest

响应：

    ServletResponse
        |
    HttpServletResponse

**说明我们创建Servlet都是继承自HttpServlet**

---

###ServletRequest概述
- 获取客户端的请求数据
- ServletRequest的常用方法
    - public Object getAttribute(String name)：获取名称为name的属性值
    - public void setAttribute(String name, Object object)：在请求中保存名称为name的属性
    - public void removeAttribute(String name)：清除请求中名字为name的属性

###HttpServletRequest概述
- 除了继承ServletRequest接口中的方法，还增加了一些用于读取请求信息的方法
- HttpServletRequest的常用方法
    - public String getContextPath()：返回请求URI中表示请求上下文的路径，上下文路径是请求URI的开始部分
    - public Cookie[ ]  getCookies()：返回客户端在此次请求中发送的所有cookie对象
    - public HttpSession  getSession()：返回和此次请求相关联的session，如果没有给客户端分配session，则创建一个新的session
    - public String  getMethod()：返回此次请求所使用的HTTP方法的名字，如GET、POST

###ServletResponse概述
- 向客户端发送响应数据
- ServletResponse接口的常用方法
    - public PrintWriter  getWriter()：返回PrintWrite对象，用于向客户端发送文本
    - public String  getCharacterEncoding()：返回在响应中发送的正文所使用的字符编码
    - public void  setCharacterEncoding()：设置发送到客户端的响应的字符编码
    - public void  setContentType(String type)：设置发送到客户端的响应的内容类型，此时响应的状态属于尚未提交

###HttpServletResponse概述
- 除了继承ServletResponse接口中的方法，还增加了新的方法
- HttpServletResponse的常用方法
    - public void  addCookie(Cookie cookie)：增加一个cookie到响应中，这个方法可多次调用，设置多个cookie
    - public void  addHeader(String name,String value)：将一个名称为name，值为value的响应报头添加到响应中
    - public void  sendRedirect(String  location)：发送一个临时的重定向响应到客户端，以便客户端访问新的URL
    - public void  encodeURL(String url)：使用session ID对用于重定向的URL进行编码
