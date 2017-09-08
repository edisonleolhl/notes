>本文包括：
>
>1、Filter简介
>
>2、Filter是如何实现拦截的？
>
>3、Filter开发入门
>
>4、Filter的生命周期
>
>5、FilterConfig接口
>
>6、配置Filter总结
>
>7、案例一：编码集统一处理
>
>8、案例二：禁用缓存过滤器
>
>9、案例三：高效的静态资源缓存过滤器
>
>10、案例四：实现用户自动登陆的过滤器
>
>11、案例五：使用Filter实现URL级别的权限认证

##1、Filter简介
- Filter也称之为过滤器，它是Servlet技术中最实用的技术，WEB开发人员通过Filter技术，对web服务器管理的所有web资源：例如Jsp，Servlet，静态图片文件或静态HTML文件等进行拦截，从而实现一些特殊的功能。

- 例如实现**URL级别的权限访问控制**（最常用）、过滤敏感词汇、压缩响应信息等一些高级功能。

- Servlet的API中提供了一个Filter接口，开发web应用时，如果编写的Java类实现了这个接口，则把这个java类称之为过滤器Filter。通过Filter技术，开发人员可以实现用户在访问某个目标资源之前，对访问的请求和响应进行拦截，如下所示：
![](http://upload-images.jianshu.io/upload_images/2106579-99dcf10e8082c4fb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##2、Filter是如何实现拦截的？
- Filter接口中有一个doFilter方法，当开发人员编写好Filter，并配置对哪个web资源(对应的URL)进行拦截后，WEB服务器每次在调用web资源之前，都会先调用一下filter的doFilter方法，因此，在Filter.doFilter()方法内编写代码一般分为三个步骤：

    1. 调用目标资源之前，让一段代码执行
    
    2. 是否调用目标资源（即是否让用户访问web资源）。
    
        - web服务器在调用doFilter方法时，会传递一个filterChain对象进来，filterChain对象是filter接口中最重要的一个对象，它也提供了一个doFilter方法，开发人员可以根据需求决定是否调用此方法。如果不调用FilterChain.doFilter()方法，即默认情况下，如下所示：

                @Override
                public void doFilter(ServletRequest request, ServletResponse response,
                        FilterChain chain) throws IOException, ServletException {

                    System.out.println("filter doFilter...");
                    // 默认：对目标资源进行了拦截，目标资源没有被访问
                }

        - 若开发人员调用filterChain的doFilter方法，则web服务器就会调用web资源的service方法，即web资源就会被访问，否则web资源不会被访问，如下所示：

                @Override
                public void doFilter(ServletRequest request, ServletResponse response,
                        FilterChain chain) throws IOException, ServletException {
                    System.out.println("filter doFilter...");
                    // 默认：对目标资源进行了拦截，目标资源没有被访问
            
                    // 如果访问请求调用链下一个资源，这样就不会拦截该web资源
                    chain.doFilter(request, response);
                }

    3. 调用目标资源之后，让一段代码执行

##3、Filter开发入门
- Filter开发分为三个步骤：

    - 编写java类实现（*implement*）Filter接口，并重写（*override*）其doFilter方法（也可以同时重写init方法与destroy方法）。

    - 在 web.xml 文件中使用`<filter>`和`<filter-mapping>`元素对编写的filter类进行注册，并设置它所能拦截的资源，代码如下所示：

              <!-- 对过滤器注册，为过滤器定义 name -->
              <filter>
                  <filter-name>Filter1</filter-name>
                  <filter-class>cn.itcast.filter.Filter1</filter-class>
              </filter>    
            
                <!-- 配置过滤器拦截哪个web 资源 -->
              <filter-mapping>
                  <filter-name>Filter1</filter-name>
                  <!-- 拦截路径 -->
                  <url-pattern>/hello.jsp</url-pattern>
              </filter-mapping>

        其实这与在web.xml文件中配置Servlet是一个道理：

              <servlet>
                <servlet-name>HelloServlet</servlet-name>
                <servlet-class>cn.itcast.servlet.HelloServlet</servlet-class>
              </servlet>
            
             <servlet-mapping>
                <servlet-name>HelloServlet</servlet-name>
                <url-pattern>/hello</url-pattern>
              </servlet-mapping>

    - 在java类中覆盖init、doFilter、destroy方法。
    
    > Filter开发步骤与Servlet开发步骤如出一辙,下面是Servlet的开发步骤:
    > 
    > 1、继承HttpServlet
    > 
    > 2、配置web.xml Servlet虚拟路径
    > 
    > 3、覆盖doGet 和 doPost

    - 代码如下：

            public class Filter1 implements Filter {
                public Filter1() {
                    System.out.println("创建了Filter1实例");
                }
            
                @Override
                public void destroy() {
                    System.out.println("filter destroy...");
                }
            
                @Override
                public void doFilter(ServletRequest request, ServletResponse response,
                        FilterChain chain) throws IOException, ServletException {
                    System.out.println("filter doFilter...");
                }
            
                @Override
                public void init(FilterConfig filterConfig) throws ServletException {
                    System.out.println("filter init...");
                }
            
            }

    
- Filter链 --- FilterChain（**难点**）

    - 在一个web应用中，可以开发编写多个Filter，这些Filter组合起来称之为一个Filter链。

    - web服务器根据多个Filter在web.xml文件中的注册顺序`<mapping>`，决定先调用哪个Filter，当第一个Filter的doFilter方法被调用时，web服务器会创建一个代表Filter链的FilterChain对象传递给该方法。(详见API文档)
    
    - 在Filter.doFilter()方法中，开发人员如果调用了FilterChain对象的doFilter方法，则web服务器会检查FilterChain对象中是否还有filter，如果有，则调用第2个filter，如果没有，则调用目标资源。

    - demo：

             <filter>
                  <filter-name>Filter1</filter-name>
                  <filter-class>cn.itcast.filter.Filter1</filter-class>
              </filter>    
                            
              <filter-mapping>
                  <filter-name>Filter1</filter-name>
                  <url-pattern>/hello.jsp</url-pattern>
              </filter-mapping>

              <filter>
                  <filter-name>Filter2</filter-name>
                  <filter-class>cn.itcast.filter.Filter2</filter-class>
                  </init-param>
              </filter>
              
              <filter-mapping>
                  <filter-name>Filter2</filter-name>
                  <url-pattern>/hello.jsp</url-pattern>
              </filter-mapping>

##4、Filter的生命周期
- init(FilterConfig filterConfig)throws ServletException：

    - 和我们编写的Servlet程序一样，Filter的创建和销毁由WEB服务器负责。 **web 应用程序启动时，web 服务器将创建Filter 的实例对象，并调用其init方法进行初始化（注：filter对象只会创建一次，init方法也只会执行一次)**
    
        >注意：在初始化（init）阶段，Servlet不一样，当第一次访问Servlet的时候web服务器才会创建Servlet的实例对象。

    - 开发人员通过init方法的参数，可获得代表当前filter配置信息的FilterConfig对象。(filterConfig对象见下文)

- doFilter(ServletRequest,ServletResponse,FilterChain)

    - 每次filter进行拦截都会执行（每请求一次，执行一次）

    - 在实际开发中方法中参数request和response通常转换为HttpServletRequest和HttpServletResponse类型进行操作

- destroy()：

    - 在Web容器卸载 Filter 对象之前被调用。

##5、FilterConfig接口
- 在前文中，重写init方法时，观察到init方法需要FilterConfig对象的参数，接下来就谈谈FilterConfig这个接口。

- 用户在配置filter时，可以使用<init-param>为filter配置一些初始化参数，当web容器实例化Filter对象，调用其init方法时，会把封装了filter初始化参数的filterConfig对象传递进来。因此开发人员在编写filter时，通过filterConfig对象可调用如下方法：

    - String getFilterName()：得到filter的名称。
    
    - String **getInitParameter**(String name)： 返回在部署描述中指定名称的初始化参数的值，如果不存在返回null。
    - Enumeration getInitParameterNames()：返回过滤器的所有初始化参数的名字的枚举集合。
    
    - public ServletContext **getServletContext**()：返回Servlet上下文对象的引用。
    
        >关于ServletContext对象的用处可参考本人之前的一篇文章：[Java Web 之 Servlet](http://www.jianshu.com/p/60bad0a4a1af "http://www.jianshu.com/p/60bad0a4a1af")

- demo：

    - 配置web.xml文件：
    
              <filter>
                  <filter-name>Filter2</filter-name>
                  <filter-class>cn.itcast.filter.Filter2</filter-class>
                  <!-- 为过滤器配置初始化参数 -->
                  <init-param>
                      <param-name>company</param-name>
                      <param-value>谷歌</param-value>
                  </init-param>
              </filter>
              
              <filter-mapping>
                  <filter-name>Filter2</filter-name>
                  <url-pattern>/hello.jsp</url-pattern>
              </filter-mapping>

    - 实现Filter接口的自定义测试类：
    
            public class Filter2 implements Filter {
            
                @Override
                public void destroy() {
                }
            
                @Override
                public void doFilter(ServletRequest request, ServletResponse response,
                        FilterChain chain) throws IOException, ServletException {
                    System.out.println("filter2 doFilter...");
                    chain.doFilter(request, response);
                }
            
                @Override
                public void init(FilterConfig filterConfig) throws ServletException {
                    // 功能一 ：获得配置初始化参数
                    String company = filterConfig.getInitParameter("company");
                    System.out.println(company);
                    // 功能二 ：读取web资源文件
                    ServletContext servletContext = filterConfig.getServletContext();
                    // 读取web资源文件 必须获得绝对磁盘路径
                    String filePath = servletContext.getRealPath("/WEB-INF/info.txt"); 
                    try {
                        BufferedReader reader = new BufferedReader(new FileReader(filePath));
                        System.out.println(reader.readLine());
                        reader.close();
                    } catch (FileNotFoundException e) {
                        e.printStackTrace();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            
            }

##6、配置Filter总结
1. 对一个web资源可以配置多个过滤器

2. 一个过滤器可以用来过滤多个web 资源

3. 在`<filter-mapping>`中若想过滤Servlet时，可以通过Servlet对应的URL 或 Servlet的名字 两种方式配置：

    - Servlet对应的URL：

              <filter-mapping>
                  <filter-name>Filter1</filter-name>
                  <servlet-name>HelloServlet</servlet-name>
              </filter-mapping>

    - Servlet的名字：

              <filter-mapping>
                  <filter-name>Filter1</filter-name>
                <url-pattern>/hello</url-pattern>
              </filter-mapping>

    - 测试用的Servlet配置如下：

              <servlet>
                <servlet-name>HelloServlet</servlet-name>
                <servlet-class>cn.itcast.servlet.HelloServlet</servlet-class>
              </servlet>
            
              <servlet-mapping>
                <servlet-name>HelloServlet</servlet-name>
                <url-pattern>/hello</url-pattern>
              </servlet-mapping>

4. 关于`<url-pattern>`的写法Filter和Servlet相同，有三种方式，完全匹配、目录匹配、扩展名匹配，详解见：[Java Web 之 Servlet](http://www.jianshu.com/p/60bad0a4a1af "http://www.jianshu.com/p/60bad0a4a1af")

5. 在`<filter-mapping>`中提供了一个可选的标签`<dispatcher>`。

    - `<dispatcher>`标签指定过滤器所拦截的资源被 Servlet 容器调用的方式，可以是REQUEST,INCLUDE,FORWARD和ERROR之一。默认REQUEST会过滤，其他三种方式都不会过滤。

        - request ---在请求时过滤

        - forward ---在转发时过滤

        - include ---在包含时过滤

        - error --在错误页面跳转时过滤

    - 用户可以设置多个<dispatcher> 子元素用来指定 Filter 对资源的多种调用方式进行拦截。

    - demo：

              <filter-mapping>
                  <filter-name>Filter1</filter-name>
                  <servlet-name>HelloServlet</servlet-name>
                  <!-- 在转发以及请求时进行过滤 -->
                  <dispatcher>FORWARD</dispatcher>
                  <dispatcher>REQUEST</dispatcher>
              </filter-mapping>

##7、案例一：编码集统一处理

- 假设有一个功能：input.jsp 提供输入姓名的表单，提交表单后在Servlet获得表单数据，将数据打印页面上。

- 在Filter知识之前，我们通常要在Servlet的doPost方法中这样做：

        request.setCharacterEncoding("utf-8");// 解决请求post乱码
        response.setContentType("text/html;charset=utf-8"); // 解决响应响应乱码
    
- 这两行代码对于Java Web开发人员来说那是再熟悉不过了，很多Servlet中都需要这两行，那可不可以简化一下呢？

- 分析：**Filter在目标资源之前执行，而且Filter可以拦截多个目标资源**，所以：多个目标资源（多个Servlet）中相同代码，可以抽取到Filter对象的doFilter方法中：

        public class EncodingFilter implements Filter {
        
            @Override
            public void destroy() {
            }
        
            @Override
            public void doFilter(ServletRequest request, ServletResponse response,
                    FilterChain chain) throws IOException, ServletException {
                // 设置请求和响应字符集
                request.setCharacterEncoding("utf-8");// 解决请求post乱码
                response.setContentType("text/html;charset=utf-8"); // 响应乱码
        
                // 目标资源（Servlet）是可访问的，不能被真正过滤掉
                chain.doFilter(request, response);
            }
        
            @Override
            public void init(FilterConfig filterConfig) throws ServletException {
            }
        
        }

    在web.xml中配置这个Filter：

          <!-- 配置全站编码过滤器 -->
          <filter>
              <filter-name>EncodingFilter</filter-name>
              <filter-class>cn.itcast.demo1.EncodingFilter</filter-class>
          </filter>    
          <filter-mapping>
              <filter-name>EncodingFilter</filter-name>
            <!-- “过滤”该站所有URL资源 -->
              <url-pattern>/*</url-pattern>
          </filter-mapping>

- 至此，post请求的乱码解决，get请求的乱码解决方式有两种：

    1. 配置tomcat server.xml中的URIEncoding="utf-8" 

    2. new String(xxx.getBytes("ISO-8859-1"),"utf-8");

- 同样，还是仿照上文的思路，抽取相同代码放入Filter中，可以解决全站get/post请求乱码的问题，代码如下（会用就行）：

        package cn.itcast.filter;
        
        import java.io.IOException;
        import java.io.UnsupportedEncodingException;
        import java.util.Map;
        import java.util.Set;
        
        import javax.servlet.Filter;
        import javax.servlet.FilterChain;
        import javax.servlet.FilterConfig;
        import javax.servlet.ServletException;
        import javax.servlet.ServletRequest;
        import javax.servlet.ServletResponse;
        import javax.servlet.http.HttpServletRequest;
        import javax.servlet.http.HttpServletRequestWrapper;
        /**
        * 解决乱码通用的过滤器程序
        * @author seawind
        */
        public class EncodingFilter implements Filter {
        
            @Override
            public void destroy() {
            }
        
            @Override
            public void doFilter(ServletRequest request, ServletResponse response,
                    FilterChain chain) throws IOException, ServletException {
                // 解决post
                request.setCharacterEncoding("utf-8");
                // 解决get
                EncodingRequest encodingRequest = new EncodingRequest(
                        (HttpServletRequest) request);
                chain.doFilter(encodingRequest, response);
        
            }
        
            @Override
            public void init(FilterConfig filterConfig) throws ServletException {
            }
        
        }
        
        class EncodingRequest extends HttpServletRequestWrapper {
        
            private HttpServletRequest request;
        
            private boolean hasEncode = false;
        
            public EncodingRequest(HttpServletRequest request) {
                super(request);
                this.request = request;
            }
        
            @Override
            public String getParameter(String name) {
                // 通过getParameterMap方法完成
                String[] values = getParameterValues(name);
                if (values == null) {
                    return null;
                }
                return values[0];
            }
        
            @Override
            public String[] getParameterValues(String name) {
                // 通过getParameterMap方法完成
                Map<String, String[]> parameterMap = getParameterMap();
                String[] values = parameterMap.get(name);
                return values;
            }
        
            @Override
            public Map getParameterMap() {
                Map<String, String[]> parameterMap = request.getParameterMap();
                String method = request.getMethod();
                if (method.equalsIgnoreCase("post")) {
                    return parameterMap;
                }
        
                // get提交方式 手动转码 , 这里的转码只进行一次 所以通过 hasEncode 布尔类型变量控制
                if (!hasEncode) { 
                    Set<String> keys = parameterMap.keySet();
                    for (String key : keys) {
                        String[] values = parameterMap.get(key);
                        if (values == null) {
                            continue;
                        }
                        for (int i = 0; i < values.length; i++) {
                            String value = values[i];
                            // 解决get
                            try {
                                value = new String(value.getBytes("ISO-8859-1"),
                                        "utf-8");
                                // values是一个地址
                                values[i] = value;
                            } catch (UnsupportedEncodingException e) {
                                e.printStackTrace();
                            }
                        }
                        // 一次转码完成后，设置转码状态为true
                        hasEncode = true;
                    }
                }
                return parameterMap;
            }
        }

##8、案例二：禁用缓存过滤器
- 分析：在web开发中，存在很多动态web资源，经常需要更新，为了保证客户端第一时间获得更新后的结果，应该禁止动态web资源的缓存。

- 有 3 个 HTTP 响应头字段都可以禁止浏览器缓存当前页面，它们在 Servlet 中的示例代码如下：

        cache-control : no-cache  ---- 指浏览器不要缓存当前页面。
        expires : -1  ---- 值为GMT时间值，为-1指浏览器不要缓存页面
        pragma : no-cache

    >cache-control : max-age (xxx指浏览器缓存页面xxx秒)

    并不是所有的浏览器都能完全支持上面的三个响应头，因此最好是同时使用上面的三个响应头。

- 在自定义Servlet测试类中添加三行代码：

        public class ShowMessageServlet extends HttpServlet {
        
            public void doGet(HttpServletRequest request, HttpServletResponse response)
                    throws ServletException, IOException {

                // 禁止缓存
                response.setHeader("Cache-Control", "no-cache");
                response.setDateHeader("Expires", -1);
                response.setHeader("Pragma", "no-cache");
        
                response.getWriter().println("Message Servlet xxxx...");
            }
        
            public void doPost(HttpServletRequest request, HttpServletResponse response)
                    throws ServletException, IOException {
                doGet(request, response);
            }
        
        }

- 仿照案例一的思路，可不可以抽取相同代码放入Filter中呢？答案显然是可以的：

    - web.xml配置Filter：

              <!-- 禁止动态web资源缓存 -->
              <filter>
                  <filter-name>NoCacheFilter</filter-name>
                  <filter-class>cn.itcast.demo2.NoCacheFilter</filter-class>
              </filter>
              <filter-mapping>
                  <filter-name>NoCacheFilter</filter-name>
                  <!-- 禁用Servlet缓存 -->
                  <url-pattern>/showmsg</url-pattern>
                  <!-- 禁用所有JSP缓存 -->
                  <url-pattern>*.jsp</url-pattern>
              </filter-mapping>

    - NoCacheFilter：

            public class NoCacheFilter implements Filter {
            
                @Override
                public void destroy() {
                }
            
                @Override
                public void doFilter(ServletRequest request, ServletResponse response,
                        FilterChain chain) throws IOException, ServletException {
                    // 使用与HTTP协议相关 API，需要将参数转为子类型
                    HttpServletResponse httpServletResponse = (HttpServletResponse) response;
            
                    httpServletResponse.setHeader("Cache-Control", "no-cache");
                    httpServletResponse.setDateHeader("Expires", -1);
                    httpServletResponse.setHeader("Pragma", "no-cache");
            
                    chain.doFilter(request, httpServletResponse);
                }
            
                @Override
                public void init(FilterConfig filterConfig) throws ServletException {
                }
            
            }

##9、案例三：高效的静态资源缓存过滤器
- 目标：控制浏览器缓存中的静态资源的过滤器

- 场景：有些动态页面中引用了一些图片或css文件以修饰页面效果，这些图片和css文件经常是不变化的，所以为减轻服务器的压力，可以使用filter控制浏览器缓存这些文件，以提升服务器的性能。

- Tomcat缓存机制：

    ![](http://upload-images.jianshu.io/upload_images/2106579-e35a0140c115d1be.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 虽然Tomcat服务器内部对静态资源有一个缓存策略，但是客户端仍然需要与服务器进行通信，通信性能损失。如果一些图片永远不变，可以通过Expires字段，设置图片的缓存时间 （当缓存时间没有过期之前，客户端访问资源时，不会与服务器进行通信，这样就减轻了服务器的压力！）

- Expires对于经常不变文件，是一个比tomcat默认缓存策略更优的解决方案。

    - 设置Expires头信息：

              <!-- 图片过期时间过滤器 -->
              <filter>
                  <filter-name>ImageExpiresFilter</filter-name>
                  <filter-class>cn.itcast.demo3.ImageExpiresFilter</filter-class>
              </filter>
              <filter-mapping>
                  <filter-name>ImageExpiresFilter</filter-name>
                  <url-pattern>*.jpg</url-pattern>
                  <url-pattern>*.bmp</url-pattern>
                  <url-pattern>*.gif</url-pattern>
                  <url-pattern>*.png</url-pattern>
              </filter-mapping>

    - ImageExpiresFilter：
    
            public class ImageExpiresFilter implements Filter {
            
                @Override
                public void destroy() {
                }
            
                @Override
                public void doFilter(ServletRequest request, ServletResponse response,
                        FilterChain chain) throws IOException, ServletException {
                    // 设置图片过期时间 ，设置Expires头信息
                    HttpServletResponse httpServletResponse = (HttpServletResponse) response;
    
                    // 过期时间 = 当前时间 + 还有多久过期                
                    Calendar calendar = Calendar.getInstance();
                    calendar.set(Calendar.MONTH, calendar.get(Calendar.MONTH) + 1);
                
                    httpServletResponse
                            .setDateHeader("Expires", calendar.getTimeInMillis()); // 过期时间一个月
            
                    chain.doFilter(request, httpServletResponse);
                }
            
                @Override
                public void init(FilterConfig filterConfig) throws ServletException {
                }
            
            }

##10、案例四：实现用户自动登陆的过滤器
- 功能描述：在登陆界面，若用户勾选了“自动登录”，则在以后的一段时间内（可自行定义）再次访问这个网站的某些网页时，不需要到登陆界面登陆，实现自动登录。

- 编写一个过滤器，filter方法中检查cookie中是否带有用户名、密码信息，如果存在则调用业务层登陆方法，登陆成功后则向session中存入user对象（即用户登陆的标识），以实现程序完成自动登陆。

    >基础知识见：[JSP 会话管理](http://www.jianshu.com/p/6746ed189f5d)

- “记住用户名和密码”的原理是利用cookie存储user和password，“自动登陆”的原理是利用过滤器得到cookie中存储的user和password，直接进入业务层登陆，得到user对象存入session中，即实现了自动登陆。

- 图解：
    
    ![](http://upload-images.jianshu.io/upload_images/2106579-d4682fc069ba65f1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 通过以上的分析，可以开始编写代码：

    - web.xml配置：
    
             <!-- 配置自动登陆过滤器 -->
              <filter>
                  <filter-name>AutoLoginFilter</filter-name>
                  <filter-class>cn.itcast.demo4.AutoLoginFilter</filter-class>
              </filter>
              <filter-mapping>
                  <filter-name>AutoLoginFilter</filter-name>
                  <!-- 访问welcome.jsp 时完成自动登陆，最好别写'/*'， -->
                  <url-pattern>/demo4/welcome.jsp</url-pattern>
              </filter-mapping>

    - CookieUtils：

            public class CookieUtils {
                // 在cookies 数组中 查找指定name 的cookie
                public static Cookie findCookie(Cookie[] cookies, String name) {
                    if (cookies == null) {// cookie 不存在
                        return null;
                    } else {
                        // cookie 存在
                        for (Cookie cookie : cookies) {
                            if (cookie.getName().equals(name)) {
                                // 找到
                                return cookie;
                            }
                        }
            
                        // 没有找到
                        return null;
                    }
                }
            }
    
    - AutoLoginFilter:
    
            public class AutoLoginFilter implements Filter {
            
                @Override
                public void destroy() {
                }
            
                @Override
                public void doFilter(ServletRequest request, ServletResponse response,
                        FilterChain chain) throws IOException, ServletException {
                    // 1、判断当前用户是否已经登陆
                    HttpServletRequest httpServletRequest = (HttpServletRequest) request;
                    if (httpServletRequest.getSession().getAttribute("user") == null) {
                        // 未登录
                        // 2、判断autologin对应cookie 是否存在 ---- 将cookie 查询写为工具类
                        Cookie cookie = CookieUtils.findCookie(httpServletRequest
                                .getCookies(), "autologin");
                        if (cookie != null) {
                            // 找到了自动登陆cookie
                            String username = cookie.getValue().split("\\.")[0];
                            // 如果用户名中文，需要解密，详情见下文
                            username = URLDecoder.decode(username, "utf-8");
            
                            String password = cookie.getValue().split("\\.")[1];
            
                            // 登陆逻辑
                            String sql = "select * from user where username=? and password = ?";
                            Object[] args = { username, password };
                            QueryRunner queryRunner = new QueryRunner(JDBCUtils
                                    .getDataSource());
                            try {
                                User user = queryRunner.query(sql, new BeanHandler<User>(
                                        User.class), args);
                                if (user != null) {
                                    httpServletRequest.getSession().setAttribute("user",
                                            user);
                                }
                                chain.doFilter(httpServletRequest, response);
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
            
                        } else {
                            // 没有自动登陆信息
                            chain.doFilter(httpServletRequest, response);
                        }
            
                    } else {
                        // 已经登陆，不需要自动登陆
                        chain.doFilter(httpServletRequest, response);
                    }
                }
            
                @Override
                public void init(FilterConfig filterConfig) throws ServletException {
                }
            
            }

    - LoginServlet

            public class LoginServlet extends HttpServlet {
            
                public void doGet(HttpServletRequest request, HttpServletResponse response)
                        throws ServletException, IOException {
                    // 获得用户名和密码
                    String username = request.getParameter("username");
                    String password = request.getParameter("password");
            
                    // 查询数据库
                    String sql = "select * from user where username = ? and password= ?";
                    Object[] args = { username, password };
                    QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                    try {
                        User user = queryRunner.query(sql,
                                new BeanHandler<User>(User.class), args);
                        if (user == null) {
                            // 查询用户不存在，登陆失败
                            request.setAttribute("msg", "用户名或者密码错误");
                            request.getRequestDispatcher("/demo4/login.jsp").forward(
                                    request, response);
                        } else {
                            // 登陆成功
                            // 判断是否勾选自动登陆
                            if ("true".equals(request.getParameter("autologin"))) {
                                // 用户勾选了 自动登陆
                                // 将用户名和密码 以cookie形式写给客户端
                                Cookie cookie = new Cookie("autologin", URLEncoder.encode(
                                        username, "utf-8")
                                        + "." + password);
                                cookie.setMaxAge(60 * 60);
                                cookie.setPath("/day17");
                                response.addCookie(cookie);
                            }
            
                            // 将成功信息 保存Session
                            request.getSession().setAttribute("user", user); // 表示已经登陆
                            response.sendRedirect("/day17/demo4/welcome.jsp");
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            
                public void doPost(HttpServletRequest request, HttpServletResponse response)
                        throws ServletException, IOException {
                    doGet(request, response);
                }
            
            }

- 自动登陆案例问题：

    1. 如果用户名中文怎么办？

        解决方案：保存cookie时进行手动编码 URL编码 

        - 生成cookie时，new Cookie(URLEncoder.encode(用户名,"utf-8"));  ------ 写在LoginServlet

        - 读取cookie时，URLDecoder.decode(用户名,"utf-8");  ---- 写在AutoLoginFilter

    2. 中文名和密码安全问题

        -  cookie 是一个文本类型文件，内容非常容易泄露,实际开发中数据库中密码和cookie中密码都应该加密后保存  ---- 单向加密算法,如MD5

        -  MySQL 可以将数据进行md5 加密
        
                update user set password = md5(password) ;
    
        - Java也提供了MD5加密方式：

                public class DigestUtils {
                
                    /**
                     * 使用md5的算法进行加密
                     * @param plainText 加密原文
                     * @return 加密密文
                     */
                    public static String md5(String plainText) {
                        byte[] secretBytes = null;
                        try {
                            secretBytes = MessageDigest.getInstance("md5").digest(
                                    plainText.getBytes());
                        } catch (NoSuchAlgorithmException e) {
                            throw new RuntimeException("没有md5这个算法！");
                        }
                        return new BigInteger(1, secretBytes).toString(16);// 将加密后byte数组转换16进制表示
                    }
                
                }

        - 于是，在上文的LoginServlet中，当用户登陆时，就应该加密，所以存入cookie的就是加密后的密码，于是在LoginServlet中要加入一行代码：

                ...
                // 获得用户名和密码
                String username = request.getParameter("username");
                String password = request.getParameter("password");
                // MD5 加密
                password = DigestUtils.md5(password);
                ...
                Cookie cookie = new Cookie("autologin", URLEncoder.encode(username, "utf-8") + "." + password);

##11、案例五：使用Filter实现URL级别的权限认证
- 情景：在实际开发中我们经常把一些执行敏感操作的servlet映射到一些特殊目录中，并用filter把这些特殊目录保护起来，限制只能拥有相应访问权限的用户才能访问这些目录下的资源。从而在我们系统中实现一种URL级别的权限功能。

- 要求：为使Filter具有通用性，Filter保护的资源和相应的访问权限通过filter参数的形式予以配置。

- 假设：

        WebRoot/public/ 该目录下的资源所有身份都可以访问 ： 用户注册、用户登录
        WebRoot/user/ 该目录下的资源只有普通用户/超级管理员可以访问： 购买商品，查看购物车，订单支付
        WebRoot/admin/ 该目录下的资源只有超级管理员可以访问：查看商品销售情况，添加商品

- 新建JSP，在index.jsp页面提供八个链接，分别进入上文说的八个功能界面中（用户注册...添加商品）

    - web.xml配置：

              <filter>
                  <filter-name>PrivilegeFilter</filter-name>
                  <filter-class>cn.itcast.filter.PrivilegeFilter</filter-class>
              </filter>
              <filter-mapping>
                  <filter-name>PrivilegeFilter</filter-name>
                  <url-pattern>/*</url-pattern>
              </filter-mapping>    

    - PrivilegeFilter：
    
            public class PrivilegeFilter implements Filter {
            
                @Override
                public void destroy() {
                }
            
                @Override
                public void doFilter(ServletRequest request, ServletResponse response,
                        FilterChain chain) throws IOException, ServletException {
                    // 权限控制
                    // 1、获得当前请求访问资源路径
                    HttpServletRequest httpServletRequest = (HttpServletRequest) request;
                    String path = httpServletRequest.getRequestURI().substring(
                            httpServletRequest.getContextPath().length());
                    System.out.println(path);
                    // 2、如果路径 以/public/ 开始 ----- 游客就可以访问 无需登陆
                    if (path.startsWith("/public/")) {
                        chain.doFilter(httpServletRequest, response);
                        return;
                    } else {
                        // 需要 用户身份 或者 管理员 --- 需要登陆 ----- 判断是否登陆
                        User user = (User) httpServletRequest.getSession().getAttribute(
                                "user");
                        if (user == null) {
                            // 未登陆--- 没有权限 --- 跳转到登陆页面
                            request.setAttribute("msg", "您还没有登陆！");
                            request.getRequestDispatcher("/public/login.jsp").forward(
                                    httpServletRequest, response);
                            return;
                        } else {
                            // 已经登陆 --- 用户有身份
                            if (path.startsWith("/user/")) { // user 身份
                                // 需要 用户身份、管理员身份‘
                                if (user.getRole().equals("user")
                                        || user.getRole().equals("admin")) {
                                    // 权限满足
                                    chain.doFilter(httpServletRequest, response);
                                    return;
                                } else {
                                    throw new RuntimeException("对不起您的权限不足！");
                                }
                            }
            
                            if (path.startsWith("/admin/")) { // 管理员身份
                                // 需要管理员身份
                                if (user.getRole().equals("admin")) {
                                    // 权限满足
                                    chain.doFilter(httpServletRequest, response);
                                    return;
                                } else {
                                    throw new RuntimeException("对不起您的权限不足！");
                                }
                            }
                        }
                    }
            
                    chain.doFilter(httpServletRequest, response);
                }
            
                @Override
                public void init(FilterConfig filterConfig) throws ServletException {
                }
            
            }

    - index.jsp

            <%@ page language="java" contentType="text/html; charset=UTF-8"
                pageEncoding="UTF-8"%>
            <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
            <html>
            <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <title>Insert title here</title>
            </head>
            <body>
            <h1>商城主页</h1> <h2>${(empty user)?"您还未登录":user.username }</h2>
            <!-- 不登陆就可以访问 -->
            <a href="/day17privilege/public/login.jsp">用户登录</a><br/>
            <a href="/day17privilege/public/regist.jsp">用户注册</a><br/>
            <!-- 需要具有商品用户权限 -->
            <a href="/day17privilege/user/buyproduct.jsp">购买商品</a><br/>
            <a href="/day17privilege/user/showcart.jsp">查看购物车</a><br/>
            <a href="/day17privilege/user/pay.jsp">订单支付</a><br/>
            <!-- 需要具有管理员权限 -->
            <a href="/day17privilege/admin/addproduct.jsp">添加商品</a><br/>
            <a href="/day17privilege/admin/showsaleinfo.jsp">查看商品销售情况</a><br/>
            </body>
            </html>

- 注意：login.jsp需要放在public文件夹下面，LoginServlet需要将URL映射到public文件夹下面。

>Java Web 之 Servlet：http://www.jianshu.com/p/60bad0a4a1af
