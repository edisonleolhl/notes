>本文包括：
>
>1、Listener简介
>
>2、Servlet监听器
>
>3、监听三个域对象创建和销毁的事件监听器
>
>4、监听三个域对象的属性(Attribute)的变化的事件监听器
>
>5、监听绑定到 HttpSession 域中的某个对象的状态的事件监听器

##1、Listener简介
- Listener（监听器）就是一个实现特定接口的普通java程序，这个程序专门用于监听另一个java对象的方法调用或属性改变，当被监听对象发生上述事件后，监听器某个方法将立即被执行。

    ![](http://upload-images.jianshu.io/upload_images/2106579-0b9155f5408b1340.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 为了加深理解，自定义监听器来练练手，假设现在有个体重100的人要吃饭了，要监听他吃饭的动作，捕捉到了之后再打印它的体重，具体思路如下；
    
    1. 事件源类：
    
            public class Person {
                private String name;
                private int weight;// 体重
                public String getName() {
                    return name;
                }
            
                public void setName(String name) {
                    this.name = name;
                }
            
                public int getWeight() {
                    return weight;
                }
            
                public void setWeight(int weight) {
                    this.weight = weight;
                }
            
            }
    
    2. 监听器接口：
    
            public interface PersonListener {
                public void personeating(PersonEvent event);// 监听方法，需要一个事件对象作为参数
            }
            
    3. 事件类：
    
            public class PersonEvent {
                private Object source;// 事件源
            
                public Object getSource() {
                    return source;
                }
            
                public void setSource(Object source) {
                    this.source = source;
                }
            
                // 提供一个这样的构造方法：构造事件对象时，接收事件源（Person）
                public PersonEvent(Person person) {
                    this.source = person;
                }
            
            }
    
    4. 在事件源中注册监听器：
    
            public class Person {
                private String name;
                private int weight;// 体重
                private PersonListener listener;
            
                // 注册监听器
                public void addPersonListener(PersonListener listener) {
                    this.listener = listener;
                }
                public String getName() {
                    return name;
                }
            
                public void setName(String name) {
                    this.name = name;
                }
            
                public int getWeight() {
                    return weight;
                }
            
                public void setWeight(int weight) {
                    this.weight = weight;
                }
            
            }
    
    5. 操作事件源 ----- 在事件源方法中，构造事件对象，参数为当前事件源（this），传递事件对象给监听器的监听方法：
    
            public class Person {
                private String name;
                private int weight;// 体重
                private PersonListener listener;
            
                // 注册监听器
                public void addPersonListener(PersonListener listener) {
                    this.listener = listener;
                }
            
                // 吃饭
                public void eat() {
                    // 体重增加
                    weight += 5;
                    // 调用监听器监听方法
                    if (listener != null) {
                        // 监听器存在
                        // 创建事件对象 --- 通过事件对象可以获得事件源
                        PersonEvent event = new PersonEvent(this);
            
                        listener.personeating(event);
                    }
                }
            
                public String getName() {
                    return name;
                }
            
                public void setName(String name) {
                    this.name = name;
                }
            
                public int getWeight() {
                    return weight;
                }
            
                public void setWeight(int weight) {
                    this.weight = weight;
                }
            
            }
    
    6. 测试：
    
            public class PersonTest {
                public static void main(String[] args) {
                    // 步骤一 创建事件源
                    Person person = new Person();
                    person.setName("小明");
                    person.setWeight(100);
            
                    // 步骤二 给事件源注册监听器（该监听器由匿名内部类创建）
                    person.addPersonListener(new PersonListener() {
                        @Override
                        public void personeating(PersonEvent event) {
                            System.out.println("监听到了，人正在吃饭！");
                            
                            // 在监听方法中可以获得事件源对象，进而可以操作事件源对象
                            Person person = (Person) event.getSource();
                            System.out.println(person.getName());
                            System.out.println(person.getWeight());
                        }
                    });
            
                    // 步骤三 操作事件源
                    person.eat();// 结果监听方法被调用
                }
            }

##2、Servlet监听器
- 在Servlet规范中定义了多种类型的监听器，它们用于监听的**事件源**是三个域对象，分别为：

    - ServletContext

    - HttpSession

    - ServletRequest

- Servlet规范针对这三个域对象上的操作，又把这多种类型的监听器划分为三种类型：

    - 监听三个域对象的创建和销毁的事件监听器

    - 监听三个域对象的属性(Attribute)的增加和删除的事件监听器

    - 监听绑定到 HttpSession 域中的某个对象的状态的事件监听器。（查看API文档）

- 编写 Servlet 监听器：

    - 和编写其它事件监听器一样，编写Servlet监听器也需要实现一个**特定**的接口，并针对相应动作覆盖接口中的相应方法。
    
    - 和其它事件监听器略有不同的是，Servlet监听器的注册不是直接注册在事件源上，而是由WEB容器负责注册，开发人员只需**在web.xml文件中使用`<listener>`标签配置好监听器**，web容器就会自动把监听器注册到事件源中。
    
    - 一个 web.xml 文件中可以配置多个 Servlet 事件监听器，web 服务器按照它们在 web.xml 文件中的注册顺序来加载和注册这些 Serlvet 事件监听器。配置代码如下所示：

            <!-- 对监听器进行注册 -->
            <!-- 监听器和Servlet、Filter不同，不需要url配置，监听器执行不是由用户访问的，监听器 是由事件源自动调用的 -->
            <listener>
                <listener-class>cn.itcast.servlet.listener.MyServletContextListener</listener-class>
            </listener>

##3、监听三个域对象创建和销毁的事件监听器
###3.1、ServletContextListener
- ServletContextListener 接口用于监听 ServletContext 对象的创建和销毁事件。

    - 当 ServletContext 对象被创建时，调用接口中的方法：
    
            ServletContextListener.contextInitialized (ServletContextEvent sce)
    
    - 当 ServletContext 对象被销毁时，调用接口中的方法：
    
            ServletContextListener.contextDestroyed(ServletContextEvent sce)

- ServletContext域对象何时创建和销毁：

    - 创建：服务器启动时，针对每一个web应用创建Servletcontext
    
    - 销毁：服务器关闭前，先关闭代表每一个web应用的ServletContext

- ServletContext主要用来干什么？

    1. 保存全局应用数据对象
    
        - 在服务器启动时，对一些对象进行初始化，并且将对象保存ServletContext数据范围内 —— 实现全局数据
    
        - 例如：创建数据库连接池
    
    2. 加载框架配置文件
    
        - Spring框架(配置文件随服务器启动加载) org.springframework.web.context.ContextLoaderListener 
    
    3. 实现任务调度（定时器），启动定时程序 
    
        - java.util.Timer：一种线程设施，用于安排以后在后台线程中执行的任务，可安排任务执行一次，或者定期重复执行。

        - Timer提供了启动定时任务方法 Timer.schedule()，其中有两种方法需要记住：
    
            1. 在指定的一个时间时启动定时器，定期执行一次

                     Timer.schedule(TimerTask task, Date firstTime, long period)  

            2. 在当前时间延迟多少毫秒后启动定时器，定期执行一次
            
                     Timer.schedule(TimerTask task, long delay, long period)  

        - 停止定时器，取消任务

                Timer.cancel() 

- demo：

        package cn.itcast.servlet.listener;
        
        import java.text.DateFormat;
        import java.text.ParseException;
        import java.text.SimpleDateFormat;
        import java.util.Date;
        import java.util.Timer;
        import java.util.TimerTask;
        
        import javax.servlet.ServletContext;
        import javax.servlet.ServletContextEvent;
        import javax.servlet.ServletContextListener;
        
        /**
         * 自定义 Context监听器
         * 
         * @author seawind
         * 
         */
        public class MyServletContextListener implements ServletContextListener {
        
            @Override
            public void contextDestroyed(ServletContextEvent sce) {
                System.out.println("监听ServletContext对象销毁了...");
            }
        
            @Override
            public void contextInitialized(ServletContextEvent sce) {
                System.out.println("监听ServletContext对象创建了...");
                // 获得事件源
                ServletContext servletContext = sce.getServletContext();
                // 向ServletContext 中保存数据
        
                // 启动定时器
                final Timer timer = new Timer();
                // 启动定时任务
        
                // timer.schedule(new TimerTask() {
                // @Override
                // // 这就是一个线程
                // public void run() {
                // System.out.println("定时器执行了...");
                // }
                // }, 0, 3000); // 马上启动 每隔3秒重复执行
        
                // 指定时间启动定时器
                DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
                try {
                    Date first = dateFormat.parse("2012-08-07 10:42:00");
                    timer.schedule(new TimerTask() {
                        int i;
        
                        @Override
                        public void run() {
                            i++;
                            System.out.println("从10点40分开始启动程序，每隔3秒重复执行");
                            if (i == 10) {
                                timer.cancel();// 取消定时器任务
                            }
                        }
                    }, first, 3000);
                } catch (ParseException e) {
                    e.printStackTrace();
                }
            }
        
        }

###3.2、HttpSessionListener
- HttpSessionListener接口用于监听HttpSession的创建和销毁

    - 创建一个Session时，接口中的该方法将会被调用：

            HttpSessionListener.sessionCreated(HttpSessionEvent se) 
    
    - 销毁一个Session时，接口中的该方法将会被调用：

            HttpSessionListener.sessionDestroyed (HttpSessionEvent se) 

- Session域对象创建和销毁：

    - 创建：浏览器访问服务器时，服务器为每个浏览器创建不同的 session 对象，服务器创建session
    
    - 销毁：如果用户的session的30分钟没有使用，session就会过期，我们在Tomcat的web.xml里面也可以配置session过期时间。

- demo：
        
        package cn.itcast.servlet.listener;
        
        import javax.servlet.http.HttpSession;
        import javax.servlet.http.HttpSessionEvent;
        import javax.servlet.http.HttpSessionListener;
        
        public class MyHttpSessionListener implements HttpSessionListener {
        
            @Override
            public void sessionCreated(HttpSessionEvent se) {
                // 通过事件对象获得session 的id 
                System.out.println("session被创建了");
                HttpSession session = se.getSession();
                System.out.println("id:" + session.getId());
            }
        
            @Override
            public void sessionDestroyed(HttpSessionEvent se) {
                System.out.println("session被销毁了");
                HttpSession session = se.getSession();
                System.out.println("id:" + session.getId());
            }
        
        }

>关于HttpSession的生命周期、具体描述详见：[JSP 会话管理](http://www.jianshu.com/p/6746ed189f5d "JSP 会话管理")

###3.3、ServletRequestListener（很少用）
- ServletRequestListener 接口用于监听ServletRequest 对象的创建和销毁：

    - ServletRequest对象被创建时，监听器的requestInitialized方法将会被调用。

    - ServletRequest对象被销毁时，监听器的requestDestroyed方法将会被调用。

- ServletRequest域对象创建和销毁的时机：

    - 创建：用户每一次访问，都会创建一个reqeust
    
    - 销毁：当前访问结束，request对象就会销毁

- 这个监听器最需要注意的：

    - 使用forward ---- request创建销毁一次 （因为转发本质是一次请求）

    - 使用sendRedirect ---- request创建销毁两次 （因为重定向本质是两次请求）

>关于ServletRequest详见：[http://www.jianshu.com/p/7e2e3fd58e91](http://www.jianshu.com/p/7e2e3fd58e91 "ServletRequest")

###3.4、案例：统计在线人数
- 图解：

    ![](http://upload-images.jianshu.io/upload_images/2106579-b3495eb9b9275e7d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 首先，初始化在线人数，根据前文，ServletContextListener可以监听ServletContext对象的创建，所以新建一个实现监听器接口的类：

        package cn.itcast.servlet.listener.demo2;
        
        import javax.servlet.ServletContext;
        import javax.servlet.ServletContextEvent;
        import javax.servlet.ServletContextListener;
        
        public class OnlineCountServletContextListener implements
                ServletContextListener {
        
            @Override
            public void contextDestroyed(ServletContextEvent sce) {
            }
        
            @Override
            public void contextInitialized(ServletContextEvent sce) {
                // 初始化在线人数为0
                ServletContext context = sce.getServletContext();
                context.setAttribute("onlinenum", 0);
            }
        
        }

- 利用HttpSessionListener监听HttpSession对象的创建和销毁，可以统计在线人数：

        package cn.itcast.servlet.listener.demo2;
        
        import javax.servlet.ServletContext;
        import javax.servlet.http.HttpSession;
        import javax.servlet.http.HttpSessionEvent;
        import javax.servlet.http.HttpSessionListener;
        
        public class OnlineCountHttpSessionListener implements HttpSessionListener {
        
            @Override
            public void sessionCreated(HttpSessionEvent se) {
                // 当Session对象被创建时，在线人数 +1
                HttpSession session = se.getSession();
                ServletContext context = session.getServletContext();
        
                int onlinenum = (Integer) context.getAttribute("onlinenum");
                context.setAttribute("onlinenum", onlinenum + 1);
        
                System.out.println(session.getId() + "被创建了...");
            }
        
            @Override
            public void sessionDestroyed(HttpSessionEvent se) {
                // 当Session对象被销毁时，在线人数 - 1
                HttpSession session = se.getSession();
                ServletContext context = session.getServletContext();
        
                int onlinenum = (Integer) context.getAttribute("onlinenum");
                context.setAttribute("onlinenum", onlinenum - 1);
        
                System.out.println(session.getId() + "被销毁了 ...");
            }
        
        }

- 别忘了在web.xml中配置：

        <listener>
            <listener-class>cn.itcast.servlet.listener.demo2.OnlineCountServletContextListener</listener-class>
        </listener>
        <listener>
            <listener-class>cn.itcast.servlet.listener.demo2.OnlineCountHttpSessionListener</listener-class>
        </listener>

- 简单创建一个JSP页面（注意，JSP作用域中applicationScope的范围是整个服务器，所以可以得到ServletContext对象中存储的值）：

        <%@ page language="java" contentType="text/html; charset=UTF-8"
            pageEncoding="UTF-8"%>
        <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
        <html>
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Insert title here</title>
        </head>
        <body>
        <h1>显示在线人数</h1>
        ${applicationScope.onlinenum }
        </body>
        </html>

###3.5、案例：利用定时器定时销毁Session
- 图解：

    ![](http://upload-images.jianshu.io/upload_images/2106579-4f9b3b2e0d149a25.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- ScannerServletContextListener干了两件事：初始化List<HttpSession>；启动定时器，每隔20秒执行一次。
    
    注意：

    因为要从List中删除元素，所以循环用Iterator而不用foreach。
    
    在使用扫描删除Session对象时，要保证Session的List集合长度不能改变（即此时此刻不能添加新的Session） ---- 利用同步解决 synchronized

        package cn.itcast.servlet.listener.demo3;
        
        import java.util.ArrayList;
        import java.util.Iterator;
        import java.util.List;
        import java.util.Timer;
        import java.util.TimerTask;
        
        import javax.servlet.ServletContext;
        import javax.servlet.ServletContextEvent;
        import javax.servlet.ServletContextListener;
        import javax.servlet.http.HttpSession;
        
        public class ScannerServletContextListener implements ServletContextListener {
        
            @Override
            public void contextDestroyed(ServletContextEvent sce) {
            }
        
            @Override
            public void contextInitialized(ServletContextEvent sce) {
                // 第一件事，创建Session的List集合
                final List<HttpSession> sessionList = new ArrayList<HttpSession>();
                // 将集合保存ServletContext对象
                ServletContext servletContext = sce.getServletContext();
                servletContext.setAttribute("sessionList", sessionList);
        
                // 第二件事，启动定时器，每隔20秒执行一次
                Timer timer = new Timer();
                timer.schedule(new TimerTask() {
                    @Override
                    public void run() {
                        System.out.println("定时session扫描器执行了....");
                        // 扫描Session的List集合，看哪个Session已经1分钟没用了
                        // 发现Session1分钟没有使用，销毁Session 从集合移除
                        synchronized (sessionList) {
                            Iterator<HttpSession> iterator = sessionList.iterator();
                            while (iterator.hasNext()) {
                                HttpSession session = iterator.next();
                                if (System.currentTimeMillis()
                                        - session.getLastAccessedTime() > 1000 * 60) {
                                    System.out.println(session.getId()
                                            + "对象已经1分钟没有使用，被销毁了...");
                                    // 销毁Session
                                    session.invalidate();
                                    // 从集合移除Session
                                    iterator.remove();
        
                                }
                            }
                        }
                    }
                }, 0, 20000);
            }
        
        }

- ScannerHttpSessionListener：    

        package cn.itcast.servlet.listener.demo3;
        
        import java.util.List;
        
        import javax.servlet.ServletContext;
        import javax.servlet.http.HttpSession;
        import javax.servlet.http.HttpSessionEvent;
        import javax.servlet.http.HttpSessionListener;
        
        public class ScannerHttpSessionListener implements HttpSessionListener {
        
            @Override
            public void sessionCreated(HttpSessionEvent se) {
                // 在创建Session对象时，将Session对象加入集合
                HttpSession httpSession = se.getSession();
                ServletContext context = httpSession.getServletContext();
        
                List<HttpSession> sessionList = (List<HttpSession>) context
                        .getAttribute("sessionList");
                synchronized (sessionList) {
                    sessionList.add(httpSession);
                }
        
                // 还是否需要context.setAttribute？ ---- 不需要：因为之前得到的是List的地址
                context.setAttribute("sessionList", sessionList); // 这行代码写不写无所谓
        
                System.out.println(httpSession.getId() + "被创建了...");
            }
        
            @Override
            public void sessionDestroyed(HttpSessionEvent se) {
            }
        
        }

- 配置：

        <listener>
            <listener-class>cn.itcast.servlet.listener.demo3.ScannerServletContextListener</listener-class>
        </listener>
        <listener>
            <listener-class>cn.itcast.servlet.listener.demo3.ScannerHttpSessionListener</listener-class>
        </listener>

##4、监听三个域对象的属性(Attribute)的变化的事件监听器
- Servlet规范定义了监听 ServletContext, HttpSession, HttpServletRequest 这三个对象中的属性(Attribute)变更信息事件的监听器。

- 这三个监听器接口分别是

    - ServletContextAttributeListener
    
    - HttpSessionAttributeListener
    
    - ServletRequestAttributeListener

- 这三个接口中都定义了三个方法来处理被监听对象中的属性的增加，删除和替换的事件，同一个事件在这三个接口中对应的方法名称完全相同，只是接受的参数类型不同

- XXListener.attributeAdded(XXEvent) 

    - 当向被监听器对象中增加一个属性时，web容器就调用事件监听器的 attributeAdded 方法进行相应，这个方法接受一个事件类型的参数，监听器可以通过这个参数来获得正在增加属性的域对象和被保存到域中的属性对象
    
    - 各个域属性监听器中的完整语法定义为：
    
            public void attributeAdded(ServletContextAttributeEvent scae)
            public void attributeAdded (HttpSessionBindingEvent  hsbe) 
            public void attributeAdded(ServletRequestAttributeEvent srae)

- XXListener.attributeRemoved(XXEvent)

    - 当删除被监听对象中的一个属性时，web 容器调用事件监听器的这个方法进行相应
    
    - 各个域属性监听器中的完整语法定义为：
    
            public void attributeRemoved(ServletContextAttributeEvent scae) 
            public void attributeRemoved (HttpSessionBindingEvent  hsbe) 
            public void attributeRemoved (ServletRequestAttributeEvent srae)

- XXListener.attributeReplaced(XXEvent)
    
    - 当监听器的域对象中的某个属性被替换时，web容器调用事件监听器的这个方法进行相应
    
    - 各个域属性监听器中的完整语法定义为：

            public void attributeReplaced(ServletContextAttributeEvent scae) 
            public void attributeReplaced (HttpSessionBindingEvent  hsbe) 
            public void attributeReplaced (ServletRequestAttributeEvent srae)

- 由于这三个监听器用法极其相似，所以只用一个例子来演示具体用法：

- 新建有一个JSP页面：

        <%@ page language="java" contentType="text/html; charset=UTF-8"
            pageEncoding="UTF-8"%>
        <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
        <html>
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Insert title here</title>
        </head>
        <body>
        <%
            // 向Session数据范围 保存名称为"name"，值为"张三"的属性(Attribute)
            session.setAttribute("name","张三"); // 触发attributeAdd

            // 将session中属性(Attribute)名为"name"的值替换为"李四"
            session.setAttribute("name","李四"); // 触发attributeReplaced

            // 移除名为"name"的属性
            session.removeAttribute("name");// 触发attributeRemoved
        %>
        </body>
        </html>
    

- MyHttpSessionAttributeListener：

        package cn.itcast.servlet.listener;
        
        import javax.servlet.http.HttpSession;
        import javax.servlet.http.HttpSessionAttributeListener;
        import javax.servlet.http.HttpSessionBindingEvent;
        
        public class MyHttpSessionAttributeListener implements
                HttpSessionAttributeListener {
        
            @Override
            public void attributeAdded(HttpSessionBindingEvent se) {
                // 属性添加
                System.out.println("向session添加了一个属性...");
                HttpSession session = se.getSession();
        
                System.out.println("属性名称：" + se.getName());
                System.out.println("属性值：" + session.getAttribute(se.getName())); // se.getValue ：这个方法不会返回当前属性(Attribute)的值
            }
        
            @Override
            public void attributeRemoved(HttpSessionBindingEvent se) {
                // 属性移除
                System.out.println("从session移除了一个属性....");
        
                System.out.println("属性名称：" + se.getName());
        
            }
        
            @Override
            public void attributeReplaced(HttpSessionBindingEvent se) {
                // 属性替换
                System.out.println("将session中一个属性值替换为其他值...");
        
                HttpSession session = se.getSession();
                System.out.println("属性名称：" + se.getName());
                System.out.println("属性值：" + session.getAttribute(se.getName()));
            }
        
        }

##5、监听绑定到 HttpSession 域中的某个对象的状态的事件监听器
- 保存在 Session 域中的对象可以有多种状态：

    - 绑定到  Session 中；
    
    - 从 Session 域中解除绑定；
    
    - 随 Session 对象持久化到一个存储设备中(钝化)；
    
    - 随 Session 对象从一个存储设备中恢复（活化）

- Servlet 规范中定义了两个特殊的监听器接口来帮助 JavaBean 对象了解自己在 Session 域中的这些状态：HttpSessionBindingListener 接口和 HttpSessionActivationListener 接口，**实现这两个接口的类不需要 web.xml 文件中注册**，因为监听方法调用，都是由Session自主完成的

    - HttpSessionBindingListener 
     
        实现该接口的 Java 对象，可以感知自己被绑定到 Session 或者从 Session 中解除绑定

    - HttpSessionActivationListener 
    
        实现该接口的 Java 对象，可以感知自己从内存被钝化硬盘上，或者从硬盘被活化到内存中

###5.1、HttpSessionBindingListener接口

- 实现了 HttpSessionBindingListener 接口的 JavaBean 对象可以感知自己被绑定到 Session 中和从 Session 中删除的事件
    
    - 绑定：当对象被绑定到 HttpSession 对象中时，web 服务器调用该 JavaBean 对象的  valueBound 方法

            public void valueBound(HttpSessionBindingEvent event)
        
    - 解绑：当对象从 HttpSession 对象中解除绑定时，web 服务器调用该 JavaBean 对象的 valueUnbound 方法

            public void valueUnbound(HttpSessionBindingEvent event)
    
- demo：

    - 实现 HttpSessionBindingListener 接口的 JavaBean ：

            package cn.itcast.domain;
            
            import javax.servlet.http.HttpSessionBindingEvent;
            import javax.servlet.http.HttpSessionBindingListener;
            
            /**
             * 使Bean1对象感知 自我被绑定Session中，感知自我被Session解除绑定
             * 
             * @author seawind
             * 
             */
            public class Bean1 implements HttpSessionBindingListener {
                private int id;
                private String name;
            
                public int getId() {
                    return id;
                }
            
                public void setId(int id) {
                    this.id = id;
                }
            
                public String getName() {
                    return name;
                }
            
                public void setName(String name) {
                    this.name = name;
                }
            
                @Override
                public void valueBound(HttpSessionBindingEvent event) {
                    System.out.println("Bean1对象被绑定了...");
                    // 当前对象，操作对象
                    System.out.println("绑定对象name:" + this.name);
                }
            
                @Override
                public void valueUnbound(HttpSessionBindingEvent event) {
                    System.out.println("Bean1对象被解除绑定了...");
                    System.out.println("解除绑定对象name:" + this.name);
                }
            
            }

    - 新建一个JSP页面，里面有如下代码：

            <%@ page language="java" contentType="text/html; charset=UTF-8"
                pageEncoding="UTF-8"%>
            <%@page import="cn.itcast.domain.Bean1"%>
            <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
            <html>
            <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <title>Insert title here</title>
            </head>
            <body>
            <%
                Bean1 bean_Susan = new Bean1();
                bean_Susan.setId(100);
                bean_Susan.setName("Susan");
                
                // 将bean_Susan对象以“bean1”为名，绑定到Session中
                session.setAttribute("bean1",bean_Susan);
                
                Bean1 bean_Mary = new Bean1();
                bean_Mary.setId(200);
                bean_Mary.setName("Mary");
    
                // 将bean_Susan对象以“bean1”为名，绑定到Session中
                session.setAttribute("bean1",bean_Mary);
            %>
            ${bean1.name }
            </body>
            </html>

    - 此时若开启服务器，打开这个JSP页面，控制台会输出什么呢？

            Bean1对象被绑定了...
            绑定对象name:bean_Susan
            Bean1对象被绑定了...
            绑定对象name:bean_Mary
            Bean1对象被解除绑定了...
            解除绑定对象name:bean_Susan

    - 注意陷阱：当 Session 绑定的 JavaBean 对象替换时，会让新对象绑定，旧对象解绑

###5.2、HttpSessionActivationListener接口
- 实现了HttpSessionActivationListener接口的 JavaBean 对象可以感知自己被活化和钝化的事件

    - 当绑定到 HttpSession 对象中的 JavaBean 对象将要随 HttpSession 对象被钝化之前，web 服务器调用该 JavaBean 对象的 void sessionWillPassivate(HttpSessionBindingEvent event) 方法

    - 当绑定到 HttpSession 对象中的 JavaBean 对象将要随 HttpSession 对象被活化之后，web 服务器调用该 JavaBean 对象的 void sessionDidActive(HttpSessionBindingEvent event) 方法

- **使用场景：Session保存数据，很长一段时间没用，但是不能销毁Session对象，又不想占用服务器内存资源 ----- 钝化（将服务器内存中数据序列化硬盘上）**

- 钝化和活化应该由 Tomcat 服务器 自动进行，所以应该配置 Tomcat ：

        <Context>
            <!-- 1分钟不用 进行钝化  表示1分钟 -->
            <Manager className="org.apache.catalina.session.PersistentManager" maxIdleSwap="1">
                <!-- 钝化后文件存储位置  directory="it315" 存放到it315目录-->
                <Store className="org.apache.catalina.session.FileStore" directory="it315"/>
            </Manager>
        </Context>

    >配置context有几个位置？
    >
    >1、tomcat/conf/context.xml 对所有虚拟主机 所有web工程生效
    >
    >2、tomcat/conf/Catalina/localhost/context.xml 对当前虚拟主机所有web工程生效
    >
    >3、当前工程/META-INF/context.xml 对当前工程有效

- demo：

    - write.jsp：
    
            <%@ page language="java" contentType="text/html; charset=UTF-8"
                pageEncoding="UTF-8"%>
            <%@page import="cn.itcast.domain.Bean2"%>
            <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
            <html>
            <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <title>Insert title here</title>
            </head>
            <body>
            <!-- 将javabean 对象保存Session中 -->
            <%
                Bean2 bean2 = new Bean2();
                bean2.setName("联想笔记本");
                bean2.setPrice(5000);
                
                session.setAttribute("bean2",bean2);
            %>
            </body>
            </html>

    - read.jsp：
                
            <%@ page language="java" contentType="text/html; charset=UTF-8"
                pageEncoding="UTF-8"%>
            <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
            <html>
            <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <title>Insert title here</title>
            </head>
            <body>
            <!-- 读取javabean对象的数据 -->
            读取bean2的数据： ${bean2.name } , ${bean2.price }
            </body>
            </html>

    - Bean2.java：
            
            package cn.itcast.domain;
            
            import javax.servlet.http.HttpSessionActivationListener;
            import javax.servlet.http.HttpSessionEvent;
            
            /**
             * 感知钝化和活化
             * 
             * @author seawind
             * 
             */
            public class Bean2 implements HttpSessionActivationListener {
                private String name;
                private double price;
            
                public String getName() {
                    return name;
                }
            
                public void setName(String name) {
                    this.name = name;
                }
            
                public double getPrice() {
                    return price;
                }
            
                public void setPrice(double price) {
                    this.price = price;
                }
            
                @Override
                public void sessionDidActivate(HttpSessionEvent se) {
                    System.out.println("bean2对象被活化...");
                }
            
                @Override
                public void sessionWillPassivate(HttpSessionEvent se) {
                    System.out.println("bean2对象被钝化...");
                }
            
            }
    
    - 配置Tomcat后，开启服务器，打开write.jsp，等待一分钟，在这一分钟内，打开read.jsp是可以读取到bean2对象的。一分钟过后，read.jsp读取不到bean2对象了，同时控制台输出：
    
            bean2对象被钝化...
    
    - 这时候就实现了钝化的效果。好，接下来按照步骤走，钝化后it315目录在哪里？ 在项目文件夹是找不到这个目录的，得去Tomcat服务器的目录去找：
    
            tomcat/work/Catalina/localhost/项目工程名/
    
    - 在it315目录中的确可以看到一个XXXXXX.session的文件，其中XXXXXX就是SessionId，打开这个文件，却没有发现 JavaBean 的任何信息，这是为什么呢？
    
    - 回顾JavaSE的知识，可以发现 JavaBean 没有序列化。Java对象如果想被序列化，必须实现Serializable接口 ---- Bean2 实现该接口：
    
            import java.io.Serializable;
            ...
            public class Bean2 implements HttpSessionActivationListener, Serializable {
            ...
            ｝
    
    - 接下来，重启服务器，打开write.jsp，一分钟后，控制台照旧输出bean2对象被钝化的消息，再进去XXXXXX.session文件中，发现可以找到 JavaBean 对象的相关信息（虽然是乱码）。接下来再打开read.jsp，发现可以读取到 JavaBean 对象了，并且此时控制台输出：
    
            bean2对象被活化...

    - 这就是一种对于Session的优化策略

###5.3、案例：在线用户列表和踢人功能
- 图解：

    ![](http://upload-images.jianshu.io/upload_images/2106579-4df66bc5bf2a68b9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    ![](http://upload-images.jianshu.io/upload_images/2106579-26cd37d47dc29c40.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- demo：

    - MyServletContextListener：
            
            package cn.itcast.listener;
            
            import java.util.HashMap;
            import java.util.Map;
            
            import javax.servlet.ServletContext;
            import javax.servlet.ServletContextEvent;
            import javax.servlet.ServletContextListener;
            import javax.servlet.http.HttpSession;
            
            import cn.itcast.domain.User;
            
            /**
             * 完成全局数据对象初始化
             * 
             * @author seawind
             * 
             */
            public class MyServletContextListener implements ServletContextListener {
            
                @Override
                public void contextDestroyed(ServletContextEvent sce) {
                }
            
                @Override
                public void contextInitialized(ServletContextEvent sce) {
                    // 所有在线用户数据集合
                    Map<User, HttpSession> map = new HashMap<User, HttpSession>();
                    // 将集合保存ServletContext 数据范围
                    ServletContext servletContext = sce.getServletContext();
            
                    servletContext.setAttribute("map", map);
                }
            
            }

    - JavaBean：

            package cn.itcast.domain;
            
            import java.util.Map;
            
            import javax.servlet.ServletContext;
            import javax.servlet.http.HttpSession;
            import javax.servlet.http.HttpSessionBindingEvent;
            import javax.servlet.http.HttpSessionBindingListener;
            
            /**
             * User对象自我感知，绑定Session和解除绑定
             */
            public class User implements HttpSessionBindingListener {
                private int id;
                private String username;
                private String password;
                private String role;
            
                public int getId() {
                    return id;
                }
            
                public void setId(int id) {
                    this.id = id;
                }
            
                public String getUsername() {
                    return username;
                }
            
                public void setUsername(String username) {
                    this.username = username;
                }
            
                public String getPassword() {
                    return password;
                }
            
                public void setPassword(String password) {
                    this.password = password;
                }
            
                public String getRole() {
                    return role;
                }
            
                public void setRole(String role) {
                    this.role = role;
                }
            
                @Override
                public void valueBound(HttpSessionBindingEvent event) {
                    // 将新建立Session 和 用户 保存ServletContext 的Map中
                    HttpSession session = event.getSession();
                    ServletContext servletContext = session.getServletContext();
            
                    Map<User, HttpSession> map = (Map<User, HttpSession>) servletContext
                            .getAttribute("map");
            
                    // 将新用户加入map
                    map.put(this, session);
                }
            
                @Override
                public void valueUnbound(HttpSessionBindingEvent event) {
                    // 根据user对象，从Map中移除Session
                    HttpSession session = event.getSession();
                    ServletContext servletContext = session.getServletContext();
            
                    Map<User, HttpSession> map = (Map<User, HttpSession>) servletContext
                            .getAttribute("map");
            
                    // 从map移除
                    map.remove(this);
                }
            
            }
    
    - LoginServlet：
    
            package cn.itcast.servlet;
            
            import java.io.IOException;
            import java.sql.SQLException;
            import java.util.Map;
            
            import javax.servlet.ServletException;
            import javax.servlet.http.HttpServlet;
            import javax.servlet.http.HttpServletRequest;
            import javax.servlet.http.HttpServletResponse;
            import javax.servlet.http.HttpSession;
            
            import org.apache.commons.dbutils.QueryRunner;
            import org.apache.commons.dbutils.handlers.BeanHandler;
            
            import cn.itcast.domain.User;
            import cn.itcast.utils.JDBCUtils;
            
            /**
             * 登陆
             * 
             * @author seawind
             * 
             */
            public class LoginServlet extends HttpServlet {
            
                public void doGet(HttpServletRequest request, HttpServletResponse response)
                        throws ServletException, IOException {
                    request.setCharacterEncoding("utf-8");
            
                    String username = request.getParameter("username");
                    String password = request.getParameter("password");
            
                    String sql = "select * from user where username = ? and password = ?";
                    Object[] args = { username, password };
            
                    QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                    try {
                        User user = queryRunner.query(sql,
                                new BeanHandler<User>(User.class), args);
                        // 判断登陆是否成功
                        if (user == null) {
                            // 失败
                            request.setAttribute("msg", "用户名或者密码错误！");
                            request.getRequestDispatcher("/login.jsp").forward(request,
                                    response);
                        } else {
                            // 成功
                            request.getSession().invalidate();// 销毁之前状态
            
                            // 先判断该用户是否已经登陆，如果已经登陆，将Session销毁
                            Map<User, HttpSession> map = (Map<User, HttpSession>) getServletContext()
                                    .getAttribute("map");
                            for (User hasLoginUser : map.keySet()) {
                                if (hasLoginUser.getUsername().equals(user.getUsername())) {
                                    // 此用户之前登陆过 --- 消灭Session
                                    HttpSession hasLoginSession = map.get(hasLoginUser);
                                    hasLoginSession.invalidate();// session 被摧毁，移除所有对象
                                    // 若不使用break，则会调用map的remove方法（invalidate -> valueUnbound），发生并发异常
                                    break; 
                                }
                            }
            
                            request.getSession().setAttribute("user", user); // 将user对象绑定到Session，触发valueBound
                            response.sendRedirect("/day18kick/list.jsp");
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

    - KickServlet：
            
            package cn.itcast.servlet;
            
            import java.io.IOException;
            import java.util.Map;
            
            import javax.servlet.ServletException;
            import javax.servlet.http.HttpServlet;
            import javax.servlet.http.HttpServletRequest;
            import javax.servlet.http.HttpServletResponse;
            import javax.servlet.http.HttpSession;
            
            import cn.itcast.domain.User;
            
            /**
             * 接收被踢id
             * 
             * @author seawind
             * 
             */
            public class KickServlet extends HttpServlet {
            
                public void doGet(HttpServletRequest request, HttpServletResponse response)
                        throws ServletException, IOException {
                    String id = request.getParameter("id");// 被踢人 id
            
                    Map<User, HttpSession> map = (Map<User, HttpSession>) getServletContext()
                            .getAttribute("map");
                    // 查找目标id
                    for (User hasLoginUser : map.keySet()) {
                        if (hasLoginUser.getId() == Integer.parseInt(id)) {
                            // 找到被踢用户记录
                            HttpSession hasLoginSession = map.get(hasLoginUser);
                            hasLoginSession.invalidate();
                            break;
                        }
                    }
                    // 跳转回 列表页面
                    response.sendRedirect("/day18kick/list.jsp");
                }
            
                public void doPost(HttpServletRequest request, HttpServletResponse response)
                        throws ServletException, IOException {
                    doGet(request, response);
                }
            
            }

    - list.jsp：

            <%@ page language="java" contentType="text/html; charset=UTF-8"
                pageEncoding="UTF-8"%>
            <%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
            <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
            <html>
            <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <title>Insert title here</title>
            </head>
            <body>
            <h1>在线用户列表</h1>
            <h2>当前用户 ${user.username }</h2>
            <!-- 将ServletContext中 map 数据显示出来 -->
            <c:forEach items="${map}" var="entry">
                <!-- 只有管理员可以踢人 -->
                <!-- 管理员不能被踢 -->
                ${entry.key.username } 
                <c:if test="${user.role == 'admin' && entry.key.role != 'admin' }">
                    <a href="/day18kick/kick?id=${entry.key.id}">踢下线</a> 
                </c:if>
                <br/>
            </c:forEach>
            </body>
            </html>
