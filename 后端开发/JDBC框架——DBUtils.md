> 本文包括：
> 
> 1、DBUtils简介
> 
> 2、DbUtils类
> 
> 3、QueryRunner类
> 
> 4、ResultSetHandler接口
> 
> 5、使用步骤

##1、DbUtils简介
- commons-dbutils 是 Apache 组织提供的一个开源 JDBC工具类库，它是对JDBC的简单封装，学习成本极低，并且使用dbutils能极大简化jdbc编码的工作量，创建连接、结果集封装、释放资源，同时也不会影响程序的性能。创建连接、结果集封装、释放资源因此dbutils成为很多不喜欢hibernate的公司的首选。

- API介绍：

    - org.apache.commons.dbutils.QueryRunner --- 核心
    - org.apache.commons.dbutils.ResultSetHandler --- 结果集封装器
    - org.apache.commons.dbutils.DbUtils --- 工具类  

- 地址：http://commons.apache.org/proper/commons-dbutils/

- 学习重点：多看看API，多看看官网的example！

##2、DbUtils类
DbUtils ：提供如加载驱动、关闭连接、事务提交、回滚等常规工作的工具类，里面的所有方法都是静态的。主要方法如下：

- DbUtils类提供了三个重载的关闭方法。这些方法检查所提供的参数是不是NULL，如果不是的话，它们就关闭Connection、Statement和ResultSet。

        public static void close(…) throws java.sql.SQLException

- 这一类"quietly"方法不仅能在Connection、Statement和ResultSet为NULL情况下避免关闭，还能隐藏一些在程序中抛出的SQLException。

        public static void closeQuietly(…)

- 用来提交连接，然后关闭连接，并且在关闭连接时不抛出SQL异常。 

        public static void commitAndCloseQuietly(Connection conn)

- 装载并注册JDBC驱动程序，如果成功就返回true。使用该方法，你不需要捕捉这个异常ClassNotFoundException。
    
        public static boolean loadDriver(java.lang.String driverClassName)

##3、QueryRunner类 
- 该类简单化了SQL查询，它与ResultSetHandler组合在一起使用可以完成大部分的数据库操作，能够大大减少编码量。

- QueryRunner类提供了两个构造方法：

    - 默认的构造方法：QueryRunner()

    - 需要一个 javax.sql.DataSource 来作参数的构造方法：QueryRunner(DataSource ds)
        
        >注意：构造器需要传入DataSource参数，所以必须要用到连接池，关于JDBC连接池可参考我之前的一篇文章：[《JDBC进阶——连接池》](http://www.jianshu.com/p/ad0ff2961597 "JDBC进阶——连接池")。在那篇文章中的JDBCUtils类中没有相应的方法来获得DataSource对象，所以应该在JDBCUtils类中加入如下代码：
    
        >     // 返回数据库连接池
        >     public static DataSource getDataSource() {
        >         return dataSource;
        >     }

- 常用方法（分为两种情况）：
    
    - 批处理
    
            batch(Connection conn, String sql, Object[][] params)  // 传递连接批处理
            batch(String sql, Object[][] params)  // 不传递连接批处理
    
    - 查询操作
    
            public Object query(Connection conn, String sql, ResultSetHandler<T> rsh, Object... params)
            public Object query(String sql, ResultSetHandler<T> rsh, Object... params) 
    
    - 更新操作
    
            public int update(Connection conn, String sql, Object... params)
            public int update(String sql, Object... params)

##4、ResultSetHandler接口 
- 该接口用于处理 java.sql.ResultSet，将数据按要求转换为另一种形式。

- ResultSetHandler 接口提供了一个单独的方法：

        Object handle(ResultSet rs){}

- ResultSetHandler 接口的实现类（构造方法不唯一，在这里只用最常见的构造方法）：

    - ArrayHandler()：把结果集中的第一行数据转成对象数组（存入Object[]）。

    - ArrayListHandler()：把结果集中的每一行数据都转成一个对象数组，再存放到List中。

    - **BeanHandler(Class`<T>` type)**：将结果集中的第一行数据封装到一个对应的JavaBean实例中。

    - **BeanListHandler(Class`<T>` type)**：将结果集中的每一行数据都封装到一个对应的JavaBean实例中，存放到List里。

        >Parameters:
        >
        >type - The Class that objects returned from handle() are created from.

    - **ColumnListHandler(String columnName/int columnIndex)**：将结果集中某一列的数据存放到List中。

    - MapHandler()：将结果集中的第一行数据封装到一个Map里，key是列名，value就是对应的值。

    - MapListHandler()：将结果集中的每一行数据都封装到一个Map里，然后再将所有的Map存放到List中。

    - KeyedHandler(String columnName)：将结果集每一行数据保存到一个“小”map中,key为列名，value该列的值，再将所有“小”map对象保存到一个“大”map中 ， “大”map中的key为指定列，value为“小”map对象

    - **ScalarHandler(int columnIndex)**：通常用来保存只有一行一列的结果集。    
    > 注意：DBUtils-1.4版本中的 ScalarHandler, ColumnHandler, and KeyedHandler没有泛型！要使用1.5以上的版本。
    > 
    > Release Notes Address : http://commons.apache.org/proper/commons-dbutils/changes-report.html

##5、使用步骤
1. 将DBUtils的jar包加入到项目工程的build path中。

2. 对于CUD，有两种不同的情况：

    - 情况一：
    
        如果使用 QueryRunner(DataSource ds) 构造器创建QueryRunner对象，需要使用连接池，如DBCP、C3P0等等，数据库事务交给DBUtils框架进行管理 ---- **默认情况下每条SQL语句单独一个事务**。

        - 在这种情况下，使用如下方法：
    
                batch(String sql, Object[][] params)
            
                query(String sql, ResultSetHandler<T> rsh, Object... params) 
        
                update(String sql, Object... params) 

        - demo：
        
                @Test
                public void testDelete() throws SQLException {
                    QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                    String sql = "delete from users where id = ?";
                    queryRunner.update(sql, 3);
                }
            
                @Test
                public void testUpdate() throws SQLException {
                    QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                    String sql = "update users set password = ? where username = ?";
                    Object[] param = { "nihao", "小明" };
                    queryRunner.update(sql, param);
                }
            
                @Test
                public void testInsert() throws SQLException {
                    // 第一步 创建QueryRunner对象
                    QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
            
                    // 第二步 准备方法参数
                    String sql = "insert into users values(null,?,?,?)";
                    Object[] param = { "小丽", "qwe", "xiaoli@itcast.cn" };
            
                    // 第三步 调用 query / update
                    queryRunner.update(sql, param);
                }

    - 情况二：
    
        如果使用 QueryRunner() 构造器创建QueryRunner对象 ，**需要自己管理事务**，因为框架没有连接池无法获得数据库连接。
    
        - 在这种情况下，要使用传入Connection对象参数的方法：

                query(Connection conn, String sql, ResultSetHandler<T> rsh, Object... params)
        
                update(Connection conn, String sql, Object... params) 

        - demo:

                // 事务控制
                @Test
                public void testTransfer() throws SQLException {
                    double money = 100;
                    String outAccount = "aaa";
                    String inAccount = "bbb";
                    String sql1 = "update account set money = money - ? where name= ?";
                    String sql2 = "update account set money = money + ? where name= ?";
            
                    // 传入DataSource的构造器，默认每条SQL语句一个单独事务，而在这里要自己管理业务，所以不合适！
                    // QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
        
                    QueryRunner queryRunner = new QueryRunner();// 不要传递连接池 --- 手动事务管理
                    Connection conn = JDBCUtils.getConnection();
                    conn.setAutoCommit(false);
                    try {
                        queryRunner.update(conn, sql1, money, outAccount); // 注意要传入Connection对象的方法
                        // int d = 1 / 0;
                        queryRunner.update(conn, sql2, money, inAccount);
            
                        System.out.println("事务提交！");
                        DbUtils.commitAndCloseQuietly(conn);
                    } catch (Exception e) {
                        System.out.println("事务回滚！");
                        DbUtils.rollbackAndCloseQuietly(conn);
                        e.printStackTrace();
                    }
                }

3. 对于R，需要用到ResultSetHandler接口，该接口有9大实现类，

        public class ResultSetHandlerTest {
            // ScalarHandler 通常用于保存只有一行一列的结果集，例如分组函数
            @Test
            public void demo9() throws SQLException {
                QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                String sql = "select count(*) from account";
        
                long count = (Long) queryRunner.query(sql, new ScalarHandler(1)); // 得到结果集的第1列
                System.out.println(count);
            }
        
            // KeyedHandler 将结果集每一行数据保存到一个“小”map中,key为列名，value该列的值，再将所有“小”map对象保存到一个“大”map中 ， “大”map中的key为指定列，value为“小”map对象
            @Test
            public void demo8() throws SQLException {
                QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                String sql = "select * from account";
        
                Map<Object, Map<String, Object>> map = queryRunner.query(sql,
                        new KeyedHandler("id"));
                System.out.println(map);
            }
        
            // MapListHandler 将结果集每一行数据保存到map中，key列名 value该列的值 ---- 再将所有map对象保存到List集合中
            @Test
            public void demo7() throws SQLException {
                QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                String sql = "select * from account";
                List<Map<String, Object>> list = queryRunner.query(sql,
                        new MapListHandler());
                for (Map<String, Object> map : list) {
                    System.out.println(map);
                }
            }
        
            // MapHander 将结果集第一行数据封装到Map集合中，key是列名，value为该列的值
            @Test
            public void demo6() throws SQLException {
                QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                String sql = "select * from account";
                Map<String, Object> map = queryRunner.query(sql, new MapHandler()); // 列名为String类型，该列的值为Object类型
                System.out.println(map);
            }
        
            // ColumnListHandler 获得结果集的某一列，将该列的所有值存入List<Object>中
            @Test
            public void demo5() throws SQLException {
                QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                String sql = "select * from account";
        
                // 因为每列类型都不一样，所以用List<Object>存储
                // List<Object> list = queryRunner.query(sql,
                // new ColumnListHandler("name")); // 得到表列名为name的列
                List<Object> list = queryRunner.query(sql, new ColumnListHandler(2)); // 得到结果集的第2列
                System.out.println(list);
            }
        
            // BeanListHander 将结果集每一条数据，转为JavaBean对象，再保存到list集合中
            @Test
            public void demo4() throws SQLException {
                QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                String sql = "select * from account";
                List<Account> accounts = queryRunner.query(sql,
                        new BeanListHandler<Account>(Account.class));
        
                for (Account account : accounts) {
                    System.out.println(account.getId());
                    System.out.println(account.getName());
                    System.out.println(account.getMoney());
                    System.out.println("----------------");
                }
            }
        
            // BeanHandler 将结果集第一行数据封装到JavaBean对象中
            @Test
            public void demo3() throws SQLException {
                QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                String sql = "select * from account";
        
                // 传入 Account.class字节码文件：为了在方法中 通过反射构造Account对象
                // 使用BeanHandler注意事项 ：数据库中的表列名 与 Bean类中属性 名称一致！！！
                Account account = queryRunner.query(sql, new BeanHandler<Account>(
                        Account.class));
                System.out.println(account.getId());
                System.out.println(account.getName());
                System.out.println(account.getMoney());
            }
        
            // ArrayListHandler 将结果集每一行数据保存到List<Object[]>中
            @Test
            public void demo2() throws SQLException {
                QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                String sql = "select * from account";
                List<Object[]> list = queryRunner.query(sql, new ArrayListHandler());
        
                for (Object[] objects : list) {
                    System.out.println(Arrays.toString(objects));
                }
            }
        
            // ArrayHandler 将结果集第一行数据保存到Object[]中
            @Test
            public void demo1() throws SQLException {
                // 使用DBUtils
                QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                String sql = "select * from account";
        
                // 对象数组存储rs第一行数据的所有列
                Object[] values = queryRunner.query(sql, new ArrayHandler());
                System.out.println(Arrays.toString(values));
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
