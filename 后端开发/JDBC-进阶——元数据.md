> 本文包括：
> 
> 1、元数据－ DatabaseMetaData
> 
> 2、元数据－ ParameterMetaData
> 
> 3、元数据－ ResultSetMetaData
> 
> 4、使用元数据简化JDBC代码

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/2106579-c7e4e970956fab09.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##1、元数据－ DatabaseMetaData
- 元数据：数据库、表、列的定义信息，关于数据库的整体综合信息。 

- 获得对象：Connection.getMetaData()

- DataBaseMetaData类常用方法

    - getURL()：返回一个String类对象，代表数据库的URL。
    - getUserName()：返回连接当前数据库管理系统的用户名。
    - getDriverName()：返回驱动驱动程序的名称。
    - getPrimaryKeys(String catalog, String schema, String table)：返回指定表主键的结果集，一般catalog、schema都传入null，得到一个结果集resultset，API文档中有详细描述：
        
        > getPrimaryKeys（FROM API DOCUMENT）
        > 
        > ResultSet getPrimaryKeys(String catalog,
        >                          String schema,
        >                          String table)
        >                          throws SQLException
        >                          
        > 获取对给定表的主键列的描述。它们根据 COLUMN_NAME 进行排序。 
        > 
        > 每个主键列描述都有以下列： 
        > 
        > - TABLE_CAT String =表类别（可为 null） 
        > - TABLE_SCHEM String =表模式（可为 null） 
        > - TABLE_NAME String =表名称 
        > - COLUMN_NAME String =列名称 
        > - KEY_SEQ short =主键中的序列号（值 1 表示主键中的第一列，值 2 表示主键中的第二列）。 
        > - PK_NAME String =主键的名称（可为 null） 
        > 
        > 参数：
        > - catalog - 类别名称；它必须与存储在数据库中的类别名称匹配；该参数为 "" 表示获取没有类别的那些描述；为 null 则表示该类别名称不应该用于缩小搜索范围
        > - schema - 模式名称；它必须与存储在数据库中的模式名称匹配；该参数为 "" 表示获取没有模式的那些描述；为 null 则表示该模式名称不应该用于缩小搜索范围
        > - table - 表名称；它必须与存储在数据库中的表名称匹配 
        > 
        > 返回：
        > 
        > ResultSet - 每一行都是一个主键列描述 
        > 
        > 抛出： 
        > 
        > SQLException - 如果发生数据库访问错误

    - demo：
        
            public void demo1() throws SQLException {
                // 通过Connection 获得 DataBaseMetaData
                Connection conn = JDBCUtils.getConnection();
                DatabaseMetaData databaseMetaData = conn.getMetaData();
        
                // 获得JDBC连接参数信息
                System.out.println(databaseMetaData.getURL());
                System.out.println(databaseMetaData.getDriverName());
                System.out.println(databaseMetaData.getUserName());
        
                // 获得table主键信息
                ResultSet rs = databaseMetaData.getPrimaryKeys(null, null, "users");
                while (rs.next()) {
                    System.out.println(rs.getString(3)); // 第三列，参照上问的描述，代表表名
                    System.out.println(rs.getString("TABLE_NAME"));
                    System.out.println(rs.getString(4));
                }
            }
##2、元数据－ ParameterMetaData 
- 获得代表PreparedStatement元数据的ParameterMetaData对象，简单来说： 获得预编译SQL语句中 “?” 信息。

        Select * from user where name=? And password=?

- 获得对象：PreparedStatement.getParameterMetaData() 

- ParameterMetaData类的常用方法：

    - getParameterCount() 
    获得指定参数的个数

    - getParameterType(int param) 
    获得指定参数的sql类型

        > 并不是所有数据库都支持，使用MySQL时，这个方法只会返回varchar的int值（即14）

    - getParameterTypeName(int param)  --- 参数类型名称

- getParameterType异常处理
    
        Parameter metadata not available for the given statement

    解决方法：url后面拼接参数

        ?generateSimpleParameterMetadata=true

- demo：

        public void demo2() throws SQLException {
            Connection conn = JDBCUtils.getConnection();
            String sql = "select * from users where id = ? and password=?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            // 通过ParameterMetaData 获得 ？ 相关信息
            ParameterMetaData parameterMetaData = stmt.getParameterMetaData();
            // 获得个数
            int count = parameterMetaData.getParameterCount();
            System.out.println(count);
    
            for (int i = 1; i <= count; i++) {
                // 该方法并不是所有数据库都支持 --- MySQL不支持（所有返回类型都是varchar）
                int type = parameterMetaData.getParameterType(i);
                System.out.println(type);
                System.out.println(parameterMetaData.getParameterTypeName(i));
            }
        }
##3、元数据－ ResultSetMetaData 
- 获得对象：ResultSet.getMetaData() 
    获得代表ResultSet对象元数据的ResultSetMetaData对象。 

- ResultSetMetaData类常用方法：

    - getColumnCount() 
        返回resultset对象的列数
    - getColumnName(int column) 
        获得指定列的名称
    - getColumnTypeName(int column)
        获得指定列的类型 

- demo：

        public void demo3() throws SQLException {
            Connection conn = JDBCUtils.getConnection();
            String sql = "select * from users";
            PreparedStatement stmt = conn.prepareStatement(sql);
    
            ResultSet rs = stmt.executeQuery();
            // 获得结果集元数据
            ResultSetMetaData resultSetMetaData = rs.getMetaData();
    
            int count = resultSetMetaData.getColumnCount();
            // 打印table 第一行
            for (int i = 1; i <= count; i++) {
                System.out.print(resultSetMetaData.getColumnName(i) + "\t");
            }
            System.out.println();
    
            // 打印每列类型
            for (int i = 1; i <= count; i++) {
                System.out.print(resultSetMetaData.getColumnTypeName(i) + "\t");
            }
            System.out.println();
    
            // 打印table数据
            while (rs.next()) {
                for (int i = 1; i <= count; i++) {
                    System.out.print(rs.getObject(i) + "\t");
                }
                System.out.println();
            }
        }

##4、使用元数据简化JDBC代码
- 业务背景：系统中所有实体对象都涉及到基本的CRUD（create、read、update、delete）操作：

    - 所有实体的CUD操作代码基本相同，仅仅发送给数据库的SQL语句不同而已，因此可以把CUD操作的所有相同代码抽取到工具类的一个update方法中，并定义参数接收变化的SQL语句。

    - 实体的R操作，除SQL语句不同之外，根据操作的实体不同，对ResultSet的映射也各不相同，因此可义一个query方法，除以参数形式接收变化的SQL语句外，可以使用策略模式由qurey方法的调用者决定如何把ResultSet中的数据映射到实体对象中。

- 写框架思路：

    - 将不变的内容留在框架内部

    - 将变的内容作为参数或者配置文件

- 具体步骤：

    1. 通用CUD方法设计
        
        ![](http://upload-images.jianshu.io/upload_images/2106579-c56b8209527d3025.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

        - framework代码：
        
                /**
                 * 通用insert update delete方法
                 * 
                 * @param sql
                 *            预编译需要SQL
                 * @param args
                 *            根据SQL中? 准备参数
                 */
                public static void update(String sql, Object... args) {
                    Connection conn = null;
                    PreparedStatement stmt = null;
            
                    try {
                        conn = JDBCUtils.getConnection();
            
                        stmt = conn.prepareStatement(sql);
                        // 设置参数 --- 根据？设置参数
                        ParameterMetaData parameterMetaData = stmt.getParameterMetaData();
                        int count = parameterMetaData.getParameterCount();
                        for (int i = 1; i <= count; i++) {
                            stmt.setObject(i, args[i - 1]);
                        }
            
                        stmt.executeUpdate();
            
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        JDBCUtils.release(stmt, conn);
                    }
                }

        - DAO代码：
        
                public void updateUser(User user) {
                    String sql = "update users set username=?,password=?,email=? where id =?";
                    Object[] params = { user.getUsername(), user.getPassword(),
                            user.getEmail(), user.getId() };
                    JDBCFramework.update(sql, params);
                }

                public void deleteAccount(Account account) {
                    String sql = "delete from account where id = ?";
                    JDBCFramework.update(sql, account.getId());
                }
                
    2. 通用R方法设计

        ![](http://upload-images.jianshu.io/upload_images/2106579-5d00b15a301fefbc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

        - 接口代码：

                public interface MyResultSetHandler<T> {
                    // 将rs中数据封装对象
                    public T handle(ResultSet rs);
                }

        - framework代码：
        
                /**
                 * 通用select方法
                 */
                public static <T> T query(String sql, MyResultSetHandler<T> handler,
                        Object... args) {
                    T obj = null;
            
                    Connection conn = null;
                    PreparedStatement stmt = null;
                    ResultSet rs = null;
            
                    try {
                        conn = JDBCUtils.getConnection();
                        stmt = conn.prepareStatement(sql);
            
                        // 设置参数
                        ParameterMetaData parameterMetaData = stmt.getParameterMetaData();
                        int count = parameterMetaData.getParameterCount();
                        for (int i = 1; i <= count; i++) {
                            stmt.setObject(i, args[i - 1]);
                        }
            
                        rs = stmt.executeQuery();
                        obj = handler.handle(rs);
            
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        JDBCUtils.release(rs, stmt, conn);
                    }
                    return obj;
                }

        - DAO代码；

                public Account findById(int id) {
                    // 使用自定义框架
                    String sql = "select * from account where id = ?";
                    MyResultSetHandler handler = new MyResultSetHandler() { //匿名内部类
                        @Override
                        public Object handle(ResultSet rs) {
                            try {
                                if (rs.next()) {
                                    Account account = new Account();
                                    account.setId(rs.getInt("id"));
                                    account.setName(rs.getString("name"));
                                    account.setMoney(rs.getDouble("money"));
                                    return account;
                                }
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                            return null;
                        }
                    };
            
                    return (Account) JDBCFramework.query(sql, handler, id);
                }

    3. 通用R方法设计——拓展：
        - 上面第2点的通用R方法设计，通过实现MyResultSetHandler接口，来实现rs的封装，但从DAO代码中可以看出并没有省略很多代码，不同的业务还是需要进行**手动封装**。
        - 所以，现在考虑设计一个通用接口，来实现**自动封装**rs。

        - 框架实现（通用handler，处理将所有rs第一行数据 转换指定 JavaBean对象）：
        
                public class MyBeanHandler<T> implements MyResultSetHandler<T> {
                
                    private Class<T> domainClass; 
                
                    public MyBeanHandler(Class<T> domainClass) {
                        this.domainClass = domainClass; //通过字节码文件
                    }
                
                    @Override
                    public T handle(ResultSet rs) {
                        try {
                            ResultSetMetaData resultSetMetaData = rs.getMetaData();// 结果集元数据
                            int count = resultSetMetaData.getColumnCount();
                
                            BeanInfo beanInfo = Introspector.getBeanInfo(domainClass);
                            PropertyDescriptor[] descriptors = beanInfo
                                    .getPropertyDescriptors();//属性描述器
                            if (rs.next()) {
                                T t = domainClass.newInstance(); //因为不能通过泛型获得T的实例，所以通过反射技术来获得T的实例！！！
                                for (int i = 1; i <= count; i++) {
                                    String columnName = resultSetMetaData.getColumnName(i);
                                    // 获得列名 --- 需要去查找匹配属性
                                    for (PropertyDescriptor propertyDescriptor : descriptors) {
                                        if (columnName.equals(propertyDescriptor.getName())) {
                                            // 列名 存在 同名属性 ---- 列值 存到属性里
                                            Method writeMethod = propertyDescriptor
                                                    .getWriteMethod(); // 得到属性的写方法，如同setName、setMoney等方法
                                            writeMethod.invoke(t, rs.getObject(columnName));
                                        }
                                    }
                                }
                                return t;
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        return null;
                    }
                
                }

        - 接口代码：
                
                public interface MyResultSetHandler<T> {
                    // 将rs中数据封装对象
                    public T handle(ResultSet rs);
                }

        - DAO代码：

                public User findById(int id) {
                    String sql = "select * from users where id = ?";
                    return JDBCFramework
                            .query(sql, new MyBeanHandler<User>(User.class), id);
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
