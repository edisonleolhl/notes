>本人的环境为Myeclipse10、MySQL5.7.15

##简介
1. Java Data Base Connectivity(Java数据库连接)：是java与数据库的桥梁，提供读写操作。

2. 可以为多种数据库提供统一的访问，是一种统一标准。

3. 通过JDBC可以连接Oracle、MySql、Sql Server数据库。

##打通数据库
1. 需要导入mysql-connector-java的jar包，如图所示：
    ![](http://upload-images.jianshu.io/upload_images/2106579-926efcc37efec8f4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2. 加载驱动程序： Class.forName（driverClass）
    - 加载Mysql驱动：
            Class.forName("com.mysql.jdbc.Driver")
    - 加载Oracle驱动：
            Class.forName("oracle.jdbc.driver.OracleDriver")

3. 获得数据库连接:
        DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/imooc", USER, PASSWORD);
    其中jdbc:mysql表示jdbc连接mysql，127.0.0.1:3306为服务器地址和端口，imooc为数据库名称，USER和PASSWORD分别为数据库的用户名和密码。

4. 通过数据库的连接操作数据库，创建Statement对象： 
        Statement stmt = conn.createStatement();

##JDBC各种连接方式的对比：
1. JDBC + ODBC桥的方式。特点：需要数据库的ODBC驱动，仅适用于微软的系统
这种方式，JDBC将调用传递给ODBC，然后ODBC再调用本地的数据库驱动代码。

2. JDBC + 厂商API的形式。特点：厂商API一般使用C编写
这种方式，JDBC将调用直接传递给厂商API的服务，然后在调用本地的数据库驱动。

3. JDBC + 厂商Database Connection Server + DataBase的形式。
特点：在JAVA与DATABASE之间架起了一台专门用于数据库连接的服务器（一般有数据库厂商提供）
这种方式，JDBC将调用传递给中间服务器，中间服务器再将调用转换成数据库能够被调用的形式，在调用数据库服务器。中间增设数据库服务器能够提升效率，但不如直接操作数据库便捷。

4. JDBC + DATABASE的连接方式。
特点：这使得Application与数据库分开，开发者只需关心内部逻辑的实现而不需注重数据库连接的具体实现。（没有中间环节，是推荐方式！）

##常见问题
- 当Myeclipse与MySQL连接时，控制台有可能产生如下错误：
    Wed Sep 21 20:22:12 CST 2016 WARN: Establishing SSL connection without server's identity verification is not recommended. According to MySQL 5.5.45+, 5.6.26+ and 5.7.6+ requirements SSL connection must be established by default if explicit option isn't set. For compliance with existing applications not using SSL the verifyServerCertificate property is set to 'false'. You need either to explicitly disable SSL by setting useSSL=false, or set useSSL=true and provide truststore for server certificate verification.

- 原因：
    造成这个问题的原因是你用的Mysql版本过高，mysql在高版本中增加了数据加密技术，也就是SSL协议，在用户通过第三方软件连接时需要对连接信息进行SSL转换加密，而你提供的地址如果没有申明SSL转换，就会导致新版mysql无法识别，相当于你提供了错误的地址。解决方法是在url后面加上SSL申明useSSL=true。（注意URL传参数的方法，先加问号，再给某个参数名赋值，多个参数用'&'连起来，如`...?useUnicode=true&useSSL=true`
    >参考来源：http://www.imooc.com/qadetail/159702

- 具体代码如下：
        private static final String URL = "jdbc:mysql://127.0.0.1:3306/imooc?useSSL=true";
