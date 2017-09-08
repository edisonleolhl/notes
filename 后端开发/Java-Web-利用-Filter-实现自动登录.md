>本文包括：
>
>1、什么是自动登录？
>
>2、简书自动登录流程
>
>3、实现自动登录
>
>4、用户注销

##1、什么是自动登录？
-  就拿简书做例子吧，很多朋友为了快速打开简书，会把简书主页添加到浏览器书签中（譬如我），进入的界面如下：

    ![](http://upload-images.jianshu.io/upload_images/2106579-df5efbf15d9bd190.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 不知道大家发现了没有，每次进入都是登陆状态？看看右上角的头像，那不就是自己的简书帐号头像吗？这是如何办到的呢？这篇文章，我们来聊聊如何实现自动登录。

- 知识储备：

    - JSP会话管理：http://www.jianshu.com/p/6746ed189f5d

    - Java Web 之 Filter：http://www.jianshu.com/p/cd2b02ce9bee

##2、简书自动登录流程
- 第一次登陆时：
    ![](http://upload-images.jianshu.io/upload_images/2106579-2c1a83b2ea209ff7.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 下次登陆时：
    ![](http://upload-images.jianshu.io/upload_images/2106579-309ec93dad774726.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 首先要明白Cookie和Session的机制，Cookie是保存在客户端的文本信息，最常见的应用是：记住用户名和密码。Session是会话，在浏览网页时，页面经常跳来跳去，这时候就需要Session来保存用户对象。

    >具体见：[JSP 会话管理](http://www.jianshu.com/p/6746ed189f5d "JSP 会话管理")

- 如何在下次登陆时“自动地”完成*检查是否存在用户的Cookie，若有，则把用户对象存入Session中*呢？纵观Java Web相关知识，发现过滤器（Filter）有个特点很吸引人：在请求调用web资源之前执行，于是可以通过Filter来“自动”完成登陆操作。

    >具体见：[Java Web 之 Filter](http://www.jianshu.com/p/cd2b02ce9bee "Java Web 之 Filter")

##3、实现自动登录
- 正好拿我最近在重构代码的电商网站项目来测试吧。

- 登陆页面如下：

    ![](http://upload-images.jianshu.io/upload_images/2106579-fd22a59067445e12.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 首页如下：

    ![](http://upload-images.jianshu.io/upload_images/2106579-eec08211adda5328.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 思路：

    在登陆页面提供一个form，里面含有三个input，用户名输入框、密码输入框、自动登陆的勾选框，在UserLoginServlet干了两件事：

    1. 得到用户名和密码，判断是否存在该用户，存在则把用户对象放入Session中。

    2. 在第一点的基础上，判断勾选框是否被勾选中，若选中，则把当前的用户名和密码存入Cookie中，设置Cookie的过期时间为24小时之后。

    - UserLoginServlet：

            package com.shopping.Servlet;
            
            import java.io.IOException;
            import java.io.PrintWriter;
            import java.net.URLEncoder;
            import java.sql.SQLException;
            
            import javax.servlet.ServletException;
            import javax.servlet.http.Cookie;
            import javax.servlet.http.HttpServlet;
            import javax.servlet.http.HttpServletRequest;
            import javax.servlet.http.HttpServletResponse;
            import javax.servlet.http.HttpSession;
            
            import com.shopping.models.User;
            import com.shopping.service.UserService;
            
            @SuppressWarnings("serial")
            public class UserLoginServlet extends HttpServlet {
                UserService us = new UserService();
            
                public void doPost(HttpServletRequest request, HttpServletResponse response)
                        throws ServletException, IOException {
            
                    PrintWriter out=response.getWriter();
                    String userAccount = request.getParameter("userAccount");
                    String password = request.getParameter("password");
                    User u = null;
                    try {
                        u = us.loginByAccount(userAccount, password);
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    if(u==null){
                        try {
                            u = us.loginByPhone(userAccount, password);
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                    if(u==null){
                        out.write("<script>alert('用户名或密码错误！');history.go(-1);</script>");
                    }
                    if(u!=null){
                        String autoLogin=request.getParameter("autoLogin");
                        if("yes".equals(autoLogin)){
                            Cookie cookie1 = new Cookie("USERACCOUNT", URLEncoder.encode(u.getUserAccount(), "UTF-8"));
                            Cookie cookie2 = new Cookie("USERPWD", URLEncoder.encode(u.getPassword(), "UTF-8"));
                            cookie1.setMaxAge(24*60*60);
                            cookie2.setMaxAge(24*60*60);
                            response.addCookie(cookie1);
                            response.addCookie(cookie2);
                        }
                        HttpSession session=request.getSession();
                        session.setAttribute("USER", u);
                        response.sendRedirect("/JD/fristpage/search.jsp");
                    }
                    out.flush();
                    out.close();
                }
            
            }

- 好的，假设我们现在已经勾选了自动登录，并且登陆成功，这时候我们来到了主页，看到顶部的导航栏出现了用户名，说明Session中有用户对象了。

    ![](http://upload-images.jianshu.io/upload_images/2106579-db5c68294cd3a028.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 好，接下来检查一下Cookie中有没有保存成功，Cookie不是保存在客户端的文本信息吗？那我们可以直接查看：

    ![](http://upload-images.jianshu.io/upload_images/2106579-fb5753ca48829a8a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 很清晰的看到，在客户端已经保存成功了，并且过期时间正好是24小时之后。接下来，编写自动登录的代码：

    - AutoLoginFilter.java：

            package com.shopping.Filter;
            
            import java.io.IOException;
            import java.net.URLDecoder;
            import java.sql.SQLException;
            
            import javax.servlet.Filter;
            import javax.servlet.FilterChain;
            import javax.servlet.FilterConfig;
            import javax.servlet.ServletException;
            import javax.servlet.ServletRequest;
            import javax.servlet.ServletResponse;
            import javax.servlet.http.Cookie;
            import javax.servlet.http.HttpServletRequest;
            import javax.servlet.http.HttpSession;
            
            import com.shopping.models.User;
            import com.shopping.service.UserService;
            import com.shopping.utils.CookieUtils;
            
            public class AutoLoginFilter implements Filter {
            
                public void destroy() {
            
                }
            
                public void doFilter(ServletRequest request, ServletResponse response,
                        FilterChain chain) throws IOException, ServletException {
                 
                    // 1、判断当前用户是否已经登陆
                    HttpServletRequest httpServletRequest = (HttpServletRequest) request;
                    if (httpServletRequest.getSession().getAttribute("user") == null) {
                        // 未登录
                        // 2、判断对应cookie 是否存在 ---- 将cookie 查询写为工具类
                        Cookie cookie1 = CookieUtils.findCookie(httpServletRequest
                                .getCookies(), "USERACCOUNT");
                        Cookie cookie2 = CookieUtils.findCookie(httpServletRequest
                                .getCookies(), "USERPWD");
                        if (cookie1 != null && cookie2 != null) {
                            // 找到了自动登陆cookie
                            String userAccount = URLDecoder.decode(cookie1.getValue(), "utf-8");
                            String password = URLDecoder.decode(cookie2.getValue(), "utf-8");
            
                            User u = null;
                            UserService us = new UserService();
            
                            try {
                                u = us.loginByAccount(userAccount, password);
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                            if(u==null){
                                try {
                                    u = us.loginByPhone(userAccount, password);
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                }
                            }
                            if(u!=null){
                                HttpSession session=httpServletRequest.getSession();
                                session.setAttribute("USER", u);
                                System.out.println("AutoLoginFilter");
                            }
            
                        }
                    }
                    chain.doFilter(request, response);
                }
            
                public void init(FilterConfig filterConfig) throws ServletException {
            
                }
            
            }

    - 别忘了在web.xml中配置（假设只需要在fristpage文件夹中的网页实现自动登陆，主页也在fristpage文件夹中）：

            <!-- 配置自动登录过滤器 -->
            <filter>
                <filter-name>AutoLoginFilter</filter-name>
                <filter-class>com.shopping.Filter.AutoLoginFilter</filter-class>
            </filter>
            <filter-mapping>
                <filter-name>AutoLoginFilter</filter-name>
                <url-pattern>/fristpage/*</url-pattern>
            </filter-mapping>

- 完成上述步骤之后，关闭浏览器，再打开浏览器，进入主页，发现顶部的导航栏出现了用户名，说明已经是登陆状态，至此，自动登录功能实现。

    ![](http://upload-images.jianshu.io/upload_images/2106579-65acb04991d2382d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##4、用户注销
- 有用户登陆的地方就肯定有用户注销，简书也不例外：点击简书主页右上角的头像-登出，页面就会刷新，这时你就是一个“游客”的身份了，你会发现左边的导航栏和右上角的头像都有变化。

- 关闭浏览器，再打开浏览器-进入简书主页，你的头像当然不会出现在右上角，因为你已经登出了，接下来用图说话：

    ![](http://upload-images.jianshu.io/upload_images/2106579-cd96940030a8da63.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 点击登出按钮后，要完成两件事：

    1. Session失效（Session不失效怎么算用户注销呢？）
    
    2. Cookie失效（下次登陆时就不会自动登陆了）

- 于是写个UserLoginOutServlet.java：
        
        package com.shopping.Servlet;
        
        import java.io.IOException;
        import java.io.PrintWriter;
        
        import javax.servlet.ServletException;
        import javax.servlet.http.Cookie;
        import javax.servlet.http.HttpServlet;
        import javax.servlet.http.HttpServletRequest;
        import javax.servlet.http.HttpServletResponse;
        import javax.servlet.http.HttpSession;
        
        import com.shopping.utils.CookieUtils;
        
        public class UserLoginOutServlet extends HttpServlet {
        
            public void doGet(HttpServletRequest request, HttpServletResponse response)
                    throws ServletException, IOException {
                
                HttpSession session=request.getSession();
                session.invalidate();
                
                Cookie cookie1 = CookieUtils.findCookie(request.getCookies(), "USERACCOUNT");
                if(cookie1 != null){
                    cookie1.setMaxAge(0);
                    response.addCookie(cookie1);
                }
                Cookie cookie2 = CookieUtils.findCookie(request.getCookies(), "USERPWD");
                if(cookie2 != null){
                    cookie2.setMaxAge(0);
                    response.addCookie(cookie2);
                }
                
                System.out.println("注销成功");
                PrintWriter out=response.getWriter();
                out.write("<script>alert('注销成功!');location.href='/JD/fristpage/search.jsp';</script>");            
                out.flush();
                out.close();
            }
        
        }

- 至此，自动登录与注销的功能都实现了，结论：勤动脑，多动手，才能学习效果好。
