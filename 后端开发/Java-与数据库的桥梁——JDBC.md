>本人的环境为Myeclipse10、MySQL5.7.15

> 本文包括：
> 
> 1. 简介
> 1. JDBC编程步骤
> 1. 打通数据库
> 1. 程序详解—DriverManager
> 1. 程序详解—Connection
> 1. 程序详解—Statement
> 1. 程序详解—ResultSet
> 1. 进阶应用—ResultSet滚动结果集
> 1. 程序详解—释放资源
> 1. 编写工具类简化CRUD操作
> 1. PreparedStatement-防止SQL注入
> 1. 使用JDBC进行批处理
> 1. JavaEE体系结构


![Paste_Image.png](http://upload-images.jianshu.io/upload_images/2106579-593e1db657bb6d01.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##1、 简介
1. Java Data Base Connectivity(Java数据库连接)：是java与数据库的桥梁，提供读写操作。

2. 可以为多种数据库提供统一的访问，是一种统一标准。

3. 通过JDBC可以连接Oracle、MySql、Sql Server数据库。

##2、JDBC编程步骤
简单来说：

1. 加载驱动程序

2. 建立连接

3. 操作数据

4. 释放资源

具体而言：

1. 通过DriverManager加载驱动程序driver；

1. 通过DriverManager类获得表示数据库连接的Connection类对象；

1. 通过Connection对象绑定要执行的语句，生成Statement类对象；

1. 执行SQL语句，接收执行结果集ResultSet；

1. 可选的对结果集ResultSet类对象的处理；

1. 必要的关闭ResultSet、Statement和Connection

##3、打通数据库
1. 需要导入mysql-connector-java的jar包，如图所示：
    ![](http://upload-images.jianshu.io/upload_images/2106579-99765d74a4300238.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    注意：可以直接将数据库驱动的jar包复制到/WebRoot/WEB/INF/lib/目录下，这时候根目录的Referenced Libraries 中会直接出现这个jar包。如果像图示的这样操作，那么还需要在这个jar包上单击右键-build path，把它添加到path中。

2. 加载驱动程序： 

        Class.forName（driverClass）

    - 加载Mysql驱动：

            Class.forName("com.mysql.jdbc.Driver")
    - 加载Oracle驱动：

            Class.forName("oracle.jdbc.driver.OracleDriver")

    为什么要用反射技术来加载驱动程序呢？详情见下文DriverManager的介绍。

3. 获得数据库连接:

    - getConnection方法：
    
            DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/imooc", USER, PASSWORD);
    其中jdbc:mysql表示jdbc连接mysql，127.0.0.1:3306为服务器地址和端口，imooc为数据库名称，USER和PASSWORD分别为数据库的用户名和密码。

    - URL：

            jdbc:mysql://localhost:3306/test?key=value&key=value
    
        - 省略写法：

                jdbc:mysql:///test

        - URL中常用的参数：
            
                useUnicode=true&characterEncoding=UTF-8（注意：这里的字符集应该与客户端保持一致）

    

4. 通过数据库的连接操作数据库，创建Statement对象： 
        
        Statement stmt = conn.createStatement();

##4、程序详解—DriverManager

- Jdbc程序中的DriverManager用于加载驱动，并创建与数据库的链接，这个API的常用方法：

        DriverManager.registerDriver(new Driver())；
        DriverManager.getConnection(url, user, password)；

    **注意：在实际开发中并不推荐采用registerDriver方法注册驱动。**

    原因有二：

    1. 查看Driver的源代码可以看到，如果采用此种方式，会导致驱动程序注册两次，也就是在内存中会有两个Driver对象。
    
    2. 程序依赖mysql的api，脱离mysql的jar包，程序将无法编译，将来程序切换底层数据库将会非常麻烦。

- 推荐方式：

        Class.forName(“com.mysql.jdbc.Driver”);

    采用此种方式不会导致驱动对象在内存中重复出现，并且采用此种方式，程序仅仅只需要一个字符串，不需要依赖具体的驱动，即不需要import相关的包，使程序的灵活性更高。

    同样，在开发中也不建议采用具体的驱动类型指向getConnection方法返回的connection对象。

##5、程序详解—Connection    

- Jdbc程序中的Connection，它用于代表数据库的链接，Collection是数据库编程中最重要的一个对象，客户端与数据库所有交互都是通过connection对象完成的，这个对象的常用方法有两种：
    
    1. 获得操作数据库Statement对象
    
        - createStatement()：创建向数据库发送sql的statement对象
    
        1. prepareStatement(String sql) ：创建向数据库发送预编译sql的PrepareSatement对象，它是statement的子接口。
    
        1. prepareCall(sql)：创建执行存储过程的callableStatement对象，它是PrepareStatement的子接口。 --- 存储过程 
    
    2. 进行事务控制
    
        - setAutoCommit(boolean autoCommit)：设置事务是否自动提交。 
    
        1. commit() ：在链接上提交事务。 ---与事务相关！！
    
        1. rollback() ：在此链接上回滚事务。
    
- 示例：

        Statement stmt = conn.createStatement();

##6、程序详解—Statement

- Jdbc程序中的Statement对象用于向数据库发送SQL语句， Statement对象常用方法：

    - executeQuery(String sql) ：用于向数据发送查询语句。select语句，返回值ResultSet结果集。
    - executeUpdate(String sql)：用于向数据库发送insert、update或delete语句。返回值为int：受影响行数。
    - execute(String sql)：用于向数据库发送任意sql语句，返回值为boolean：如果第一个结果为 ResultSet 对象，则返回 true；如果其为更新计数或者不存在任何结果，则返回 false 。
    
        批处理：
    
    - addBatch(String sql) ：把多条sql语句放到一个批处理中。
    - executeBatch()：向数据库发送一批sql语句执行。 

- 示例：

        //executeQuery(String sql) 用法
        ResultSet rs = stmt.executeQuery("select * from users");

        //execute(String sql)用法
        stmt.execute("update a set name ='bbb' where id = 1");

        //executeUpdate(String sql)用法
        int row = stmt.executeUpdate(sql);
##7、程序详解—ResultSet

- Jdbc程序中的ResultSet用于代表Sql语句的执行结果。Resultset封装执行结果时，采用的类似于表格的方式。ResultSet 对象维护了一个指向表格数据行的**游标cursor**，初始的时候，游标在第一行之前，调用ResultSet.next() 方法，可以使游标指向具体的数据行，进而调用方法获取该行的数据。

- ResultSet既然用于封装执行结果的，所以该对象提供的大部分方法都是用于获取数据的get方法：
    
    - 获取任意类型的数据
    
        - getObject(int index)
    
        - getObject(string columnName)
    
    - 获取指定类型的数据，例如：
    
        - getString(int index)
    
        - getString(String columnName)
    
        - getInt(int index)

        - getInt(String columnNmae)

        - ...

    - 常用数据类型转换表
        ![](http://upload-images.jianshu.io/upload_images/2106579-b9968b3cc6d0ccca.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    - 遍历查询结果
        ![](http://upload-images.jianshu.io/upload_images/2106579-08ca1766ee7c53eb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 示例：

        ResultSet rs = stmt.executeQuery("select * from users");
        while (rs.next()) {
            System.out.println(rs.getInt("id"));
            System.out.println(rs.getString("name"));
            System.out.println(rs.getString("pwd"));
            System.out.println(rs.getString("email"));

            // 通过rs进行取值时，可以使用列名 或 索引 ---- 经常用列名，因为可读性更强
            System.out.println(rs.getInt(1));
            System.out.println(rs.getString(2));
            System.out.println(rs.getString(3));
            System.out.println(rs.getString(4));
            System.out.println("-----------------------------");
        }

- 思考：如果明知道某条SQL语句只返回一行数据，还用while？
    
        if(rs.next){ // 因为结果只有1行，存在，不存在
        }

##8、进阶应用—ResultSet滚动结果集

- ResultSet还提供了对结果集进行滚动和更新的方法。
若想设置可滚动的结果集，则在创建Statement对象时，不能像前文那样调用无参方法，而应该如下设置：

        Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,ResultSet.CONCUR_UPDATABLE);
    
    - next()：移动到下一行
    
    - previous()：移动到前一行
    
    - absolute(int row)：移动到指定行
    
    - beforeFirst()：移动resultSet的最前面
    
    - afterLast() ：移动到resultSet的最后面
    
    - updateString(int columnIndex, String x) ：用 String 值更新指定列。
    
    - updateString(String columnLabel, String x) ：用 String 值更新指定列。

    - ... 
    
    - updateRow() ：更新行数据，最后要调用这个方法来确认

- 示例：

        public void demo5() throws Exception {
            // 设置可滚动结果集
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql:///day13",
                    "root", "123");
            // 参数：TYPE_SCROLL_SENSITIVE 可滚动 、CONCUR_UPDATABLE 可修改
            Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
                    ResultSet.CONCUR_UPDATABLE);
            ResultSet rs = stmt.executeQuery("select * from users");
        
            // 游标移动到rs的第三行
            rs.absolute(3);
            System.out.println(rs.getString("name"));
            
            // 更新第四列的值
            rs.updateString(4, "def@itcast.cn");
        
            // 确认动作
            rs.updateRow();
    
            rs.close();
            stmt.close();
            conn.close();
        }

- 可以用以下两种方式使用更新方法： 

    - 更新当前行中的列值。在可滚动的 ResultSet 对象中，可以向前和向后移动光标，将其置于绝对位置或相对于当前行的位置。以下代码片段更新 ResultSet 对象 rs 第五行中的 NAME 列，然后使用方法 updateRow 更新导出 rs 的数据源表。 
    
               rs.absolute(5); // moves the cursor to the fifth row of rs
               rs.updateString("NAME", "AINSWORTH"); // updates the 
                  // NAME column of row 5 to be AINSWORTH
               rs.updateRow(); // updates the row in the data source
    
    - 将列值插入到插入行中。可更新的 ResultSet 对象具有一个与其关联的特殊行，该行用作构建要插入的行的暂存区域 (staging area)。以下代码片段将光标移动到插入行，构建一个三列的行，并使用方法 insertRow 将其插入到 rs 和数据源表中。 
    
               rs.moveToInsertRow(); // moves cursor to the insert row
               rs.updateString(1, "AINSWORTH"); // updates the 
                  // first column of the insert row to be AINSWORTH
               rs.updateInt(2,35); // updates the second column to be 35
               rs.updateBoolean(3, true); // updates the third column to true
               rs.insertRow();
               rs.moveToCurrentRow();
    
##9、程序详解—释放资源

- Jdbc程序运行完后，切记要释放程序在运行过程中，创建的那些与数据库进行交互的对象，这些对象通常是ResultSet, Statement和Connection对象。

- 特别是Connection对象，它是非常稀有的资源，用完后必须马上释放，如果Connection不能及时、正确的关闭，极易导致系统宕机。Connection的使用原则是尽量晚创建，尽量早的释放。

- **为确保资源释放代码能运行，资源释放代码也一定要放在finally语句中。**

- 释放资源的标准写法：

        public void demo6() throws ClassNotFoundException {
            // 释放资源 标准写法
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;
    
            try {
                conn = DriverManager.getConnection("jdbc:mysql:///day13", "root",
                        "123");
                stmt = conn.createStatement();
                rs = stmt.executeQuery("select * from users");
                while (rs.next()) {
                    System.out.println(rs.getString("name"));
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                
                //标准写法：先关rs、再stmt、最后conn
                if (rs != null) {
                    try {
                        rs.close();
                    } catch (SQLException sqlEx) {
                    }
                    rs = null;
                }
    
                if (stmt != null) {
                    try {
                        stmt.close();
                    } catch (SQLException sqlEx) {
                    }
    
                    stmt = null;
                }
    
                if (conn != null) {
                    try {
                        conn.close();
                    } catch (SQLException e) {
                    }
                    conn = null;
                }
            }
    
        }

##10、编写工具类简化CRUD操作

dbconfig.properties文件：

    DRIVERCLASS=com.mysql.jdbc.Driver
    URL=jdbc:mysql:///day14
    USER=root
    PWD=123
    
    #DRIVERCLASS=oracle.jdbc.driver.OracleDriver
    #URL=jdbc:oracle:thin:@localhost:1521:xe
    #USER=system
    #PWD=123

JDBCUtils文件：

    package cn.itcast.jdbc;
    
    import java.sql.Connection;
    import java.sql.DriverManager;
    import java.sql.ResultSet;
    import java.sql.SQLException;
    import java.sql.Statement;
    import java.util.ResourceBundle;
    
    /**
     * JDBC 工具类，抽取公共方法
     * 
     * @author seawind
     * 
     */
    public class JDBCUtils {
        private static final String DRIVERCLASS;
        private static final String URL;
        private static final String USER;
        private static final String PWD;
    
        //从dbconfig.properties文件中得到四个参数，方便切换数据库
        static {
            ResourceBundle bundle = ResourceBundle.getBundle("dbconfig");
            DRIVERCLASS = bundle.getString("DRIVERCLASS");
            URL = bundle.getString("URL");
            USER = bundle.getString("USER");
            PWD = bundle.getString("PWD");
        }
    
        // 建立连接
        public static Connection getConnection() throws Exception {
            loadDriver();
            return DriverManager.getConnection(URL, USER, PWD);
        }
    
        // 装载驱动
        private static void loadDriver() throws ClassNotFoundException {
            Class.forName(DRIVERCLASS);
        }
    
        // 释放资源
        public static void release(ResultSet rs, Statement stmt, Connection conn) {
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                rs = null;
            }
    
            release(stmt, conn);
        }
    
        public static void release(Statement stmt, Connection conn) {
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                stmt = null;
            }
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                conn = null;
            }
        }
    }

##11、PreparedStatement-防止SQL注入

- SQL注入是用户利用某些系统没有对输入数据进行充分的检查，从而进行恶意破坏的行为。

    ![](http://upload-images.jianshu.io/upload_images/2106579-8a69940306a1283d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- PreparedStatement是Statement的子接口，它的实例对象可以通过调用Connection.preparedStatement()方法获得，相对于Statement对象而言：

    - PreperedStatement可以避免SQL注入的问题。
    
    - Statement会使数据库频繁编译SQL，可能造成数据库缓冲区溢出。PreparedStatement 可对SQL进行预编译，从而提高数据库的执行效率。
    
    - PreperedStatement对于sql中的参数，允许使用占位符的形式进行替换，简化sql语句的编写。

- 示例：

        public User login(User user) {
            // JDBC查询
            User existUser = null;
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            try {
                conn = JDBCUtils.getConnection();
                String sql = "select * from users where name = ? and pwd = ?"; // 数据库编译时
                stmt = conn.prepareStatement(sql); // 将sql 发送给数据库进行编译
                // 设置参数
                stmt.setString(1, user.getName()); // or -- 传入数据值，不会作为关键字 --防止注入
                stmt.setString(2, user.getPwd());
    
                // 因为之前 将sql 传递数据库
                rs = stmt.executeQuery();
                // 如果登陆成功 只有一条记录
                if (rs.next()) {
                    existUser = new User();
                    existUser.setId(rs.getInt("id"));
                    existUser.setName(rs.getString("name"));
                    existUser.setPwd(rs.getString("pwd"));
                    existUser.setEmail(rs.getString("email"));
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
    
            return existUser;
        }

##12、使用JDBC进行批处理

- 业务场景：当需要向数据库发送一批SQL语句执行时，应避免向数据库一条条的发送执行，而应采用JDBC的批处理机制，以提升执行效率。

- 实现批处理有两种方式

- 第一种方式，Statement.addBatch(sql)：

    - executeBatch()方法：执行批处理命令，将这组sql一次性发送数据库

    - clearBatch()方法：清除批处理命令

    - 示例：
            
            Connection conn = null;
            Statement st = null;
            ResultSet rs = null;
            try {
                conn = JdbcUtil.getConnection();
                String sql1 = "insert into person(name,password,email,birthday) 
                    values('kkk','123','abc@sina.com','1978-08-08')";
                String sql2 = "update user set password='123456' where id=3";
                st = conn.createStatement();
                st.addBatch(sql1);  //把SQL语句加入到批命令中
                st.addBatch(sql2);  //把SQL语句加入到批命令中
                st.executeBatch();
            } finally{
                JdbcUtil.free(conn, st, rs);
            }

    - 采用Statement.addBatch(sql)方式实现批处理：
    
        - 优点：可以向数据库发送多条不同的ＳＱＬ语句。
    
        - 缺点：
    
            - SQL语句没有预编译。
            
            - 当向数据库发送多条语句相同，但仅参数不同的SQL语句时，需重复写上很多条SQL语句，会导致数据库编译sql语句四次 ---- 性能比较差
。例如：
    
                    Insert into user(name,password) values(‘aa’,’111’);
                    Insert into user(name,password) values(‘bb’,’222’);
                    Insert into user(name,password) values(‘cc’,’333’);
                    Insert into user(name,password) values(‘dd’,’444’);

- 第二种方式，PreparedStatement.addBatch()：

    - 如果连续执行多条结构相同sql --- 采用预编译 ---- SQL只需要编译一次

    - 向数据库插入50000条数据示例：
    
            conn = JdbcUtil.getConnection();
            String sql = "insert into person(name,password,email,birthday) values(?,?,?,?)";
            st = conn.prepareStatement(sql);
            for(int i=0;i<50000;i++){
                st.setString(1, "aaa" + i);
                st.setString(2, "123" + i);
                st.setString(3, "aaa" + i + "@sina.com");
                st.setDate(4,new Date(1980, 10, 10));
            
                st.addBatch(); 
                if(i%1000==0){
                    st.executeBatch();
                    st.clearBatch();
                }
            }
            st.executeBatch();

    - 采用PreparedStatement.addBatch()实现批处理

        - 优点：发送的是预编译后的SQL语句，执行效率高。

        - 缺点：只能应用在SQL语句相同，但参数不同的批处理中。因此此种形式的批处理经常用于在同一个表中批量插入数据，或批量更新表的数据。

##13、JavaEE体系结构

- MVC 和 JavaEE经典三层结构 由两拨人分别提出的

    - 三层结构中业务层、数据持久层 ---Model

    - 三层结构中web层 Servlet ---Controller

    - 三层结构中web层 JSP ---View

    ![](http://upload-images.jianshu.io/upload_images/2106579-462a5ffacc89eec4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- JavaEE模式-DAO（Data Access Object）模式：

    - 封装对于数据源的操作

    - 数据源可能是文件（如xml）、数据库等任意存储方式

    - 负责管理与数据源的连接

    - 负责数据的存取（CRUD)

    ![](http://upload-images.jianshu.io/upload_images/2106579-b294c88ac57df510.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- DAO 模式中的对象

    - Business Object：代表数据的使用者（业务层程序）

    - DataAccessObject：抽象并封装了对底层数据源的操作（数据层程序）

    - DataSource：数据源（mysql数据库）

    - TransferObject：表示数据的Java Bean

    - BussinessObject 通过 将transferObject 传递 DataAccessObject 完成对DataSource的增删改查 

    ![](http://upload-images.jianshu.io/upload_images/2106579-df859a9da45d0748.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> JDBC文集：
> 
> 1. Java 与数据库的桥梁——JDBC：http://www.jianshu.com/p/c0acbd18794c
> 
> 2. JDBC 进阶——连接池：http://www.jianshu.com/p/ad0ff2961597
> 
> 3. JDBC 进阶——元数据：http://www.jianshu.com/p/36d5d76342f1
> 
> 4. JDBC框架——DBUtils：http://www.jianshu.com/p/10241754cdd7
