>本文包括
>
>1. 传统JDBC的缺点
>
>2. 连接池原理
>
>3. 自定义连接池
>
>4. 开源数据库连接池
>
>5. DBCP连接池
>
>6. C3P0连接池
>
>7. Tomcat内置连接池

##1、传统JDBC的缺点
- 用户每次请求都需要向数据库获得链接，而数据库创建连接通常需要消耗相对较大的资源，创建时间也较长。

- 假设网站一天10万访问量，数据库服务器就需要创建10万次连接，极大的浪费数据库的资源，并且极易造成数据库服务器内存溢出、拓机。

##2、连接池原理
- 在服务器端一次性创建多个连接，将多个连接保存在一个**连接池对象**中，当应用程序的请求需要操作数据库时，不会为请求创建新的连接，而是直接从连接池中获得一个连接，操作数据库结束之后，并不需要真正关闭连接，而是将连接放回到连接池中。

- 节省创建连接、释放连接 资源

##3、自定义连接池
- 编写连接池需实现javax.sql.DataSource接口。DataSource接口中定义了两个重载的getConnection方法：

        Connection.getConnection() 
    
        Connection.getConnection(String username, String password) 

- 自定义一个类，实现DataSource接口，并实现连接池功能的步骤：

    - 在自定义类的构造函数中批量创建Connection，并把创建的连接保存到一个集合对象中（LinkedList）。
    
    - 在自定义类中实现Connection.getConnection方法，让getConnection方法每次调用时，**从集合对象中取出一个Connection返回给用户**。
    
    - 当用户使用完Connection，不能调用Connection.close()方法，而要使用连接池提供关闭方法，**即将Connection放回到连接池之中（把Connection存入集合对象中）**。
        >Connection对象应保证将自己返回到连接池的集合对象中，而不要把Connection还给数据库。

    - 如果用户习惯调用Connection.close()方法，则可以使用动态代理来增强原有方法。

- demo:
    
        public class MyDataSource implements DataSource {
        
            // 链表 --- 实现 栈结构 、队列 结构
            private LinkedList<Connection> dataSources = new LinkedList<Connection>();
        
            public MyDataSource() {
                // 一次性创建10个连接
                for (int i = 0; i < 10; i++) {
                    try {
                        Connection conn = JDBCUtils.getConnection();
                        // 将连接加入连接池中
                        dataSources.add(conn);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        
            @Override
            public Connection getConnection() throws SQLException {
                // 取出连接池中一个连接
                final Connection conn = dataSources.removeFirst(); // 删除第一个连接返回
                System.out.println("取出一个连接剩余 " + dataSources.size() + "个连接！");
                // 将目标Connection对象进行增强
                Connection connProxy = (Connection) Proxy.newProxyInstance(conn
                        .getClass().getClassLoader(), conn.getClass().getInterfaces(),
                        new InvocationHandler() {
                            // 执行代理对象任何方法 都将执行 invoke
                            @Override
                            public Object invoke(Object proxy, Method method,
                                    Object[] args) throws Throwable {
                                if (method.getName().equals("close")) {
                                    // 需要加强的方法
                                    // 不将连接真正关闭，将连接放回连接池
                                    releaseConnection(conn);
                                    return null;
                                } else {
                                    // 不需要加强的方法
                                    return method.invoke(conn, args); // 调用真实对象方法
                                }
                            }
                        });
                return connProxy;
            }
        
            // 将连接放回连接池
            public void releaseConnection(Connection conn) {
                dataSources.add(conn);
                System.out.println("将连接 放回到连接池中 数量:" + dataSources.size());
            }
        
            @Override
            public Connection getConnection(String username, String password)
                    throws SQLException {
                return null;
            }
        
            @Override
            public PrintWriter getLogWriter() throws SQLException {
                // TODO Auto-generated method stub
                return null;
            }
        
            @Override
            public int getLoginTimeout() throws SQLException {
                // TODO Auto-generated method stub
                return 0;
            }
        
            @Override
            public void setLogWriter(PrintWriter out) throws SQLException {
                // TODO Auto-generated method stub
        
            }
        
            @Override
            public void setLoginTimeout(int seconds) throws SQLException {
                // TODO Auto-generated method stub
        
            }
        
            @Override
            public boolean isWrapperFor(Class<?> iface) throws SQLException {
                // TODO Auto-generated method stub
                return false;
            }
        
            @Override
            public <T> T unwrap(Class<T> iface) throws SQLException {
                // TODO Auto-generated method stub
                return null;
            }
        
        }

##4、开源数据库连接池
- 现在很多WEB服务器(Weblogic, WebSphere, Tomcat)都提供了DataSoruce的实现，即连接池的实现。通常我们把DataSource的实现，按其英文含义称之为数据源，数据源中都包含了数据库连接池的实现。

- 也有一些开源组织提供了数据源的独立实现：

    - Apache commons-dbcp 数据库连接池 
    
    - C3P0 数据库连接池
    
    - Apache Tomcat内置的连接池（apache dbcp）

- 实际应用时不需要编写连接数据库代码，直接从数据源获得数据库的连接。程序员编程时也应尽量使用这些数据源的实现，以提升程序的数据库访问性能。

- 原来由jdbcUtil创建连接，现在由dataSource创建连接，为实现不和具体数据绑定，因此datasource也应采用配置文件的方法获得连接。

- 在Apache官网下载时，注意这些开源连接池的版本，要与本地JDK与JDBC版本对应！
    >比如说：Apache Commons DBCP 2.1.1 for JDBC 4.1 (Java 7.0+)
    
    >我在MyEclipse创建工程时设置JAVASE-1.6，而现在最新的DBCP版本为2.1.1，它要求的是Java 7.0+，所以在import相关包时，会报错，提示需要configure build path。

    >解决方法：下载低版本的两个jar包即可。

##5、DBCP连接池
- DBCP 是 Apache 软件基金组织下的开源连接池实现，使用DBCP连接池，需要在build path中增加如下两个 jar 文件：

    - Commons-dbcp.jar：连接池的实现
    
    - Commons-pool.jar：连接池实现的依赖库

- Tomcat 的连接池正是采用该连接池来实现的。该数据库连接池既可以与应用服务器整合使用，也可由应用程序独立使用。

- 使用DBCP连接池，需要有driverclass、url、username、password，有两种方法配置：

    - 使用BasicDataSource.setXXX(XXX)方法手动设置四个参数

            @Test
            public void demo1() throws SQLException {
                // 使用BasicDataSource 创建连接池
                BasicDataSource basicDataSource = new BasicDataSource();
                // 创建连接池 一次性创建多个连接池
        
                // 连接池 创建连接 ---需要四个参数
                basicDataSource.setDriverClassName("com.mysql.jdbc.Driver");
                basicDataSource.setUrl("jdbc:mysql:///day14");
                basicDataSource.setUsername("root");
                basicDataSource.setPassword("123");
        
                // 从连接池中获取连接
                Connection conn = basicDataSource.getConnection();
                String sql = "select * from account";
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery();
        
                while (rs.next()) {
                    System.out.println(rs.getString("name"));
                }
        
                JDBCUtils.release(rs, stmt, conn);
            }

    - 编写properties配置文件，在测试代码中创建Properties对象加载文件

        dbcp.properties文件：

            driverClassName=com.mysql.jdbc.Driver
            url=jdbc:mysql:///day14
            username=root
            password=123

        测试代码：

            @Test
            public void demo2() throws Exception {
                // 读取dbcp.properties ---- Properties
                Properties properties = new Properties();
                properties.load(new FileInputStream(this.getClass().getResource(
                        "/dbcp.properties").getFile()));
        
                DataSource basicDataSource = BasicDataSourceFactory
                        .createDataSource(properties);
        
                // 从连接池中获取连接
                Connection conn = basicDataSource.getConnection();
                String sql = "select * from account";
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery();
        
                while (rs.next()) {
                    System.out.println(rs.getString("name"));
                }
        
                JDBCUtils.release(rs, stmt, conn);
        
            }

##6、C3P0连接池
- 使用C3P0连接池，需要在build path中添加一个jar包：c3p0-版本号.jar

- Basic Pool Configuration 基本属性

    - acquireIncrement  当连接池连接用完了，根据该属性决定一次性新建多少连接 
    
    - initialPoolSize  初始化一次性创建多少个连接 
    
    - maxPoolSize 最大连接数 
    
    - maxIdleTime 最大空闲时间，当连接池中连接经过一段时间没有使用，根据该数据进行释放
    
        > maxIdleTime
        > 
        > Default: 0
        > 
        > Seconds a Connection can remain pooled but unused before being discarded. Zero means idle connections never expire. [See "Basic Pool Configuration"]

    -     minPoolSize 最小连接池尺寸

    - 总而言之：当创建连接池时，一次性创建initialPoolSize 个连接，当连接使用完一次性创建 acquireIncrement  个连接，连接最大数量 maxPoolSize ，当连接池连接数量大于 minPoolSize ，经过maxIdleTime 连接没有使用， 该连接将被释放。

- 使用C3P0连接池，同样有两种方法配置

    - 手动配置（除了设置四个必须的参数，还可以设置Basic Pool Configuration）

            @Test
            public void demo1() throws Exception {
                // 创建一个连接池
                ComboPooledDataSource dataSource = new ComboPooledDataSource();
                // 手动设置四个参数
                dataSource.setDriverClass("com.mysql.jdbc.Driver");
                dataSource.setJdbcUrl("jdbc:mysql:///day14");
                dataSource.setUser("root");
                dataSource.setPassword("123");

                //dataSource.setMaxPoolSize(40); // 手动设置Basic Pool Configuration

                Connection conn = dataSource.getConnection();
                String sql = "select * from account";
                PreparedStatement stmt = conn.prepareStatement(sql);
        
                ResultSet rs = stmt.executeQuery();
        
                while (rs.next()) {
                    System.out.println(rs.getString("name"));
                }
        
                JDBCUtils.release(rs, stmt, conn);
            }

    - 使用c3p0-config.xml配置：

        c3p0-config.xml文件：

            <?xml version="1.0" encoding="UTF-8"?>
            <c3p0-config>
                <default-config> <!-- 默认配置 -->
                    <property name="driverClass">com.mysql.jdbc.Driver</property>
                    <property name="jdbcUrl">jdbc:mysql:///day14</property>
                    <property name="user">root</property>
                    <property name="password">123</property>
                    
                    <property name="acquireIncrement">10</property>
                    <property name="initialPoolSize">10</property>
                    <property name="maxPoolSize">100</property>
                    <property name="maxIdleTime">60</property>
                    <property name="minPoolSize">5</property>
                </default-config>
                <named-config name="itcast">   <!-- 自定义配置 -->
                    <property name="driverClass">com.mysql.jdbc.Driver</property>
                    <property name="jdbcUrl">jdbc:mysql:///day14</property>
                    <property name="user">root</property>
                    <property name="password">123</property>
                    
                    <property name="acquireIncrement">10</property>
                    <property name="initialPoolSize">10</property>
                    <property name="maxPoolSize">100</property>
                    <property name="maxIdleTime">60</property>
                    <property name="minPoolSize">5</property>
                </named-config>
            </c3p0-config>

        测试代码：
        
            @Test
            public void demo2() throws SQLException {
                // 使用c3p0配置文件
                // 自动加载src/c3p0-config.xml，不需要像前文的dbcpconfig.properties那样加载配置文件！
            
                // ComboPooledDataSource dataSource = new ComboPooledDataSource(); // 使用默认配置
                ComboPooledDataSource dataSource = new ComboPooledDataSource("itcast"); // 使用自定义配置
        
                Connection conn = dataSource.getConnection();
                String sql = "select * from account";
                PreparedStatement stmt = conn.prepareStatement(sql);
        
                ResultSet rs = stmt.executeQuery();
        
                while (rs.next()) {
                    System.out.println(rs.getString("name"));
                }
        
                JDBCUtils.release(rs, stmt, conn);
            }

##7、Tomcat内置连接池
- 因为Tomcat和 dbcp 都是Apache公司项目，Tomcat内部连接池就是dbcp。

- Tomcat支持Servlet、JSP等，类似于容器，但并不支持所有JavaEE规范，JNDI就是JavaEE规范之一。

- 开发者通过JNDI方式可以访问Tomcat内置连接池。

###使用Tomcat内置连接池的前提
- 将web工程部署到Tomcat三种方式： 配置server.xml <Context> 元素、配置独立xml文件 <Context> 元素 、直接将网站目录复制Tomcat/webapps
虚拟目录 ---- <Context> 元素

- 若想使用Tomcat内置连接池，必须要在Context元素中添加Resource标签，具体代码如下：

        <Context>
            <Resource name="jdbc/TestDB" auth="Container" type="javax.sql.DataSource"
                       maxActive="100" maxIdle="30" maxWait="10000"
                       username="root" password="123" driverClassName="com.mysql.jdbc.Driver"
                       url="jdbc:mysql://localhost:3306/day14"/>
        </Context>

- 在哪里配置元素？有三个位置可以配置：

    1. tomcat安装目录/conf/context.xml --------- 对当前Tomcat内部所有虚拟主机中任何工程都有效

    2. tomcat安装目录/conf/Catalina/虚拟主机目录/context.xml -------- 对当前虚拟主机任何工程都有效

    3. 在web工程根目录/META-INF/context.xml ------- 对当前工程有效 **（常用！）**

        具体做法：MyEclipse中，在项目根目录的WebRoot/META-INF中，新建context.xml文件，配置代码如下：

            <?xml version="1.0" encoding="UTF-8"?>
            <!-- tomcat启动时，加载该配置文件，创建连接池，将连接池保存tomcat容器中 -->
            <Context>
            <Resource name="jdbc/TestDB" auth="Container" type="javax.sql.DataSource"
                           maxActive="100" maxIdle="30" maxWait="10000"
                           username="root" password="123" driverClassName="com.mysql.jdbc.Driver"
                           url="jdbc:mysql://localhost:3306/day14"/>
            </Context>
            
###JNDI技术简介
- JNDI(Java Naming and Directory Interface)，Java命名和目录接口，它对应于J2SE中的javax.naming包，

- 这套API的主要作用在于：它可以把Java对象放在一个容器中（支持JNDI容器 Tomcat），并为容器中的java对象取一个名称，以后程序想获得Java对象，只需通过名称检索即可。

- 其核心API为Context，它代表JNDI容器，其lookup方法为检索容器中对应名称的对象。

###使用JNDI访问Tomcat内置连接池
1. 将数据库驱动的jar包复制到Tomcat安装目录/lib中，这样Tomcat服务器才能找到数据库驱动。

2. 编写访问JNDI程序，运行在Tomcat内部，所以通常是运行在Servlet、JSP中。

3. 在Tomcat启动时，自动加载配置文件（context.xml），创建数据库连接池，该连接池由Tomcat管理。

  ![JNDI原理.jpg](http://upload-images.jianshu.io/upload_images/2106579-d5a96429fbe510c4.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

4. demo：

        public class TomcatServlet extends HttpServlet {
        
            public void doGet(HttpServletRequest request, HttpServletResponse response)
                    throws ServletException, IOException {
                try {
                    // 创建检索对象
                    Context initCtx = new InitialContext();
                    // 默认查找顶级java，名称串固定：java:comp/env
                    Context envCtx = (Context) initCtx.lookup("java:comp/env");
                    // 根据设置的名称查找连接池对象
                    DataSource ds = (DataSource) envCtx.lookup("jdbc/TestDB");
        
                    // 获得连接池中一个连接，接下来的代码和连接池无关
                    Connection conn = ds.getConnection();
                    String sql = "select * from account";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    ResultSet rs = stmt.executeQuery();
        
                    while (rs.next()) {
                        System.out.println(rs.getString("name"));
                    }
        
                    JDBCUtils.release(rs, stmt, conn);
                } catch (NamingException e) {
                    e.printStackTrace();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        
            }
        
            public void doPost(HttpServletRequest request, HttpServletResponse response)
                    throws ServletException, IOException {
                doGet(request, response);
            }
        
        }

> JDBC文集：
> 
> 1. Java 与数据库的桥梁——JDBC：http://www.jianshu.com/p/c0acbd18794c
> 
> 2. JDBC 进阶——连接池：http://www.jianshu.com/p/ad0ff2961597
> 
> 3. JDBC 进阶——元数据：http://www.jianshu.com/p/36d5d76342f1
> 
> 4. JDBC框架——DBUtils：http://www.jianshu.com/p/10241754cdd7
