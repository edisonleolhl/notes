> 本文包括：

> 1、CRM 项目的整体介绍

> 2、Hibernate 框架概述

> 3、Hibernate 快速入门

> 4、Hibernate 常用的配置文件

> 5、Hibernate 常用的接口和类

##1、CRM 项目的整体介绍
1. 什么是 CRM
	
	* CRM（Customer Relationship Management）客户关系管理，是利用相应的信息技术以及互联网技术来协调企业与顾客间在销售、营销和服务上的交互，向客户提供创新式的个性化的客户交互和服务的过程
	
	* 其最终目标是将面向客户的各项信息和活动集成起来，组建一个以客户为中心的企业，实现对面向客户的活动的全面管理
	
2. CRM 的模块
	
	* CRM 系统实现了对企业销售、营销、服务等各阶段的客户信息、客户活动进行统一管理。
	
	* CRM 系统功能涵盖企业销售、营销、用户服务等各各业务流程，业务流程中与客户相关活动都会在 CRM 系统统一管理。
	
	* 下边列出一些基本的功能模块，包括：
	
		* 客户信息管理
	
		* 联系人管理
	
		* 商机管理
	
		* 统计分析等
	
3. 模块的具体功能
	
	* 客户信息管理
	
		* 对客户信息统一维护，客户是指存量客户或拟营销的客户，通过员工录入形成公司的“客户库”是公司最重要的数据资源。
		
	* 联系人管理
	
		* 对客户的联系人信息统一管理，联系人是指客户企业的联系人，即企业的业务人员和客户的哪些人在打交道。
		
	* 客户拜访管理
	
		* 业务员要开发客户需要去拜访客户，客户拜访信息记录了业务员与客户沟通交流方面的不足、采取的策略不当、有待改进的地方或值得分享的沟通技巧等方面的信息。
		
	* 综合查询
	
		* 客户相关信息查询，包括：客户信息查询、联系人信息查询、商机信息查询等
		
	* 统计分析
	
		* 按分类统计客户信息，包括：客户信息来源统计、按行业统计客户、客户发展数量统计等
		
	* 系统管理
	
		系统管理属于crm系统基础功能模块，包括：数据字典、账户管理、角色管理、权限管理、操作日志管理等
	
4. SSH 框架

	![](http://upload-images.jianshu.io/upload_images/2106579-18d94dadfc55de6d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

5. Hibernate 的开发位置

	![](http://upload-images.jianshu.io/upload_images/2106579-f14cc5f8a0802da1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

	学习路线：
	
	* Hibernate 入门：主要是学习框架的入门，自己搭建框架，完成增删改查的操作
	
	* Hibernate 一级缓存：主要学习一级缓存、事务管理和基本的查询
	
	* Hibernate 进阶：主要学习一对多和多对多的操作等
	
	* Hibernate 查询优化：基本查询和查询的优化

##2、Hibernate 框架概述

1. Hibernate 框架的概述

	* Hibernate 是一个开放源代码的对象关系映射（ORM）框架，它对 JDBC 进行了非常轻量级的对象封装，使得 Java 程序员可以随心所欲的使用对象编程思维来操纵数据库。 
	
	* Hibernate 可以应用在任何使用 JDBC 的场合，既可以在 Java 的客户端程序使用，也可以在 Servlet/JSP 的 Web 应用中使用。
	
	* Hibernate 是轻量级 JavaEE 应用的持久层解决方案，是一个关系数据库ORM框架
	
2. **记住：Hibernate 是一个持久层的 ORM 框架**！！！

3. 什么是ORM（对象关系映射）
	
	- ORM映射：Object Relational Mapping
		* O：面向对象领域的 Object（JavaBean 对象）
		* R：关系数据库领域的 Relational（表的结构）
		* M：映射 Mapping（XML 的配置文件）
	
	- 简单一句话：Hibernate 使程序员通过操作对象的方式来操作数据库表记录
	
	![](http://upload-images.jianshu.io/upload_images/2106579-d51974ebf76b8cee.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

4. Hibernate 优点：
	
	* Hibernate 对 JDBC 访问数据库的代码做了封装，大大简化了数据访问层繁琐的重复性代码。
	
	* Hibernate 是一个基于 jdbc 的主流持久化框架，是一个优秀的 ORM 实现，它很大程度的简化了 DAO 层编码工作。
	
	* Hibernate 的性能非常好，因为它是一个轻量级框架。映射的灵活性很出色。它支持很多关系型数据库，从一对一到多对多的各种复杂关系。
	
##3、Hibernate 快速入门 
1. 下载Hibernate 5的运行环境
	
	- 下载相应的 jar 包等

		> http://sourceforge.net/projects/hibernate/files/hibernate-orm/5.0.7.Final/hibernate-release-5.0.7.Final.zip/download	
	
	- 解压后对目录结构有一定的了解

2. 创建表结构
	
	- 建表语句如下

			Create database hibernate_day01;
			Use hibernate_day01;
			CREATE TABLE `cst_customer` (
			  `cust_id` bigint(32) NOT NULL AUTO_INCREMENT COMMENT '客户编号(主键)',
			  `cust_name` varchar(32) NOT NULL COMMENT '客户名称(公司名称)',
			  `cust_user_id` bigint(32) DEFAULT NULL COMMENT '负责人id',
			  `cust_create_id` bigint(32) DEFAULT NULL COMMENT '创建人id',
			  `cust_source` varchar(32) DEFAULT NULL COMMENT '客户信息来源',
			  `cust_industry` varchar(32) DEFAULT NULL COMMENT '客户所属行业',
			  `cust_level` varchar(32) DEFAULT NULL COMMENT '客户级别',
			  `cust_linkman` varchar(64) DEFAULT NULL COMMENT '联系人',
			  `cust_phone` varchar(64) DEFAULT NULL COMMENT '固定电话',
			  `cust_mobile` varchar(16) DEFAULT NULL COMMENT '移动电话',
			  PRIMARY KEY (`cust_id`)
			) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8;

3. 搭建 Hibernate 的开发环境
	
	- 创建 WEB 工程，引入 Hibernate 开发所需要的 jar 包
	
		* MySQL的驱动jar包
		
		* Hibernate开发需要的jar包（资料/hibernate-release-5.0.7.Final/lib/required/所有jar包）
		
		* 日志jar包（资料/jar包/log4j/所有jar包）
		
		![](http://i.imgur.com/CXZwKcJ.png)

4. 编写 JavaBean 实体类
	
	- Customer 类的代码如下：

			public class Customer {
				// 以后都使用包装类，默认值为 null
				private Long cust_id;
				private String cust_name;
				private Long cust_user_id;
				private Long cust_create_id;
				private String cust_source;
				private String cust_industry;
				private String cust_level;
				private String cust_linkman;
				private String cust_phone;
				private String cust_mobile;
				// 省略get和set方法
			}

5. **创建 类与表结构的 映射**：
	
	1. 在 JavaBean 所在的包下创建映射的配置文件

		* 默认的命名规则为：实体类名.hbm.xml

		* 在 实体类名.hbm.xml 配置文件中引入约束（引入的是 hibernate3.0 的 dtd 约束，不要引入 4 的约束）

				<!DOCTYPE hibernate-mapping PUBLIC 
				    "-//Hibernate/Hibernate Mapping DTD 3.0//EN"
				    "http://www.hibernate.org/dtd/hibernate-mapping-3.0.dtd">
	
	2. 如果不能上网，编写配置文件是没有提示的，需要自己来配置

		> 复制 http://www.hibernate.org/dtd/hibernate-mapping-3.0.dtd --> window --> preferences --> 搜索 xml --> 选择 xml catalog --> 点击 add --> 选择 URI --> 粘贴复制的地址 --> 选择 location，选择本地的 DTD 的路径
	
	3. 编写映射的配置文件：实体类名.hbm.xml

			<?xml version="1.0" encoding="UTF-8"?>
			<!DOCTYPE hibernate-mapping PUBLIC 
			    "-//Hibernate/Hibernate Mapping DTD 3.0//EN"
			    "http://www.hibernate.org/dtd/hibernate-mapping-3.0.dtd">
			<hibernate-mapping>
			
				<!-- 配置类和表结构的映射 -->
				<class name="com.itheima.domain.Customer" table="cst_customer">
					<!-- 配置 id 
						见到 name 属性，JavaBean 的属性
						见到 column 属性，是表结构的字段
					-->
					<id name="cust_id" column="cust_id">
						<!-- 主键的生成策略 -->
						<generator class="native"/>
					</id>
					
					<!-- 配置其他的属性 -->
					<property name="cust_name" column="cust_name"/>
					<property name="cust_user_id" column="cust_user_id"/>
					<property name="cust_create_id" column="cust_create_id"/>
					<property name="cust_source" column="cust_source"/>
					<property name="cust_industry" column="cust_industry"/>
					<property name="cust_level" column="cust_level"/>
					<property name="cust_linkman" column="cust_linkman"/>
					<property name="cust_phone" column="cust_phone"/>
					<property name="cust_mobile" column="cust_mobile"/>
					
				</class>
				
			</hibernate-mapping>    
	
6. **编写 Hibernate 核心的配置文件**
	
	1. 在 src 目录下，创建名称为 hibernate.cfg.xml 的配置文件

	2. 在 XML 中引入 DTD 约束

			<!DOCTYPE hibernate-configuration PUBLIC
				"-//Hibernate/Hibernate Configuration DTD 3.0//EN"
				"http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd">
	
	3. 打开：资料/hibernate-release-5.0.7.Final/project/etc/hibernate.properties，可以查看具体的配置信息	

		* 必须配置的4大参数					

				#hibernate.connection.driver_class com.mysql.jdbc.Driver
				#hibernate.connection.url jdbc:mysql:///test
				#hibernate.connection.username gavin
				#hibernate.connection.password
		
		* 数据库的方言（必须配置的）

				#hibernate.dialect org.hibernate.dialect.MySQLDialect
		
		* 可选的配置

				#hibernate.show_sql true
				#hibernate.format_sql true
				#hibernate.hbm2ddl.auto update
		
		* 引入映射配置文件（一定要注意，要引入映射文件，框架需要加载映射文件，如果不引入，则需要在 Java 代码中手动加载）

				<mapping resource="com/itheima/domain/Customer.hbm.xml"/>				
	
	4. 具体的配置如下

			<?xml version="1.0" encoding="UTF-8"?>
			<!DOCTYPE hibernate-configuration PUBLIC
				"-//Hibernate/Hibernate Configuration DTD 3.0//EN"
				"http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd">
				
			<hibernate-configuration>
				
				<!-- 记住：先配置SessionFactory标签，一个数据库对应一个SessionFactory标签 -->
				<session-factory>
					
					<!-- 必须要配置的参数有5个，4大参数，数据库的方言 -->
					<property name="hibernate.connection.driver_class">com.mysql.jdbc.Driver</property>
					<property name="hibernate.connection.url">jdbc:mysql:///hibernate_day01</property>
					<property name="hibernate.connection.username">root</property>
					<property name="hibernate.connection.password">liaohaolin</property>
					
					<!-- 数据库的方言 -->
					<property name="hibernate.dialect">org.hibernate.dialect.MySQLDialect</property>
					
					<!-- 可选配置 -->
					<!-- 显示SQL语句，在控制台显示 -->
					<property name="hibernate.show_sql">true</property>
					<!-- 格式化SQL语句 -->
					<property name="hibernate.format_sql">true</property>
					<!-- 生成数据库的表结构 
						update：如果没有表结构，创建表结构。如果存在，不会创建，添加数据
					-->
					<property name="hibernate.hbm2ddl.auto">update</property>
					
					<!-- 映射配置文件，需要引入映射的配置文件 -->
					<mapping resource="com/itheima/domain/Customer.hbm.xml"/>
					
				</session-factory>
	
			</hibernate-configuration>	

7. 编写 Hibernate 入门代码

	- 具体的代码如下：

			/**
			 * 测试保存客户
			 */
			@Test
			public void testSave(){
				/**
				 * 	1. 先加载配置文件
				 * 	2. 创建SessionFactory对象，生成Session对象
				 *  3. 创建session对象
				 *  4. 开启事务
				 *  5. 编写保存的代码
				 *  6. 提交事务
				 *  7. 释放资源
				 */
				// 1. 先加载配置文件
				// 简写的方法，默认加载src目录下hibernate.cfg.xml的配置文件
				Configuration config = new Configuration().configure();
				
				// 2. 创建SessionFactory对象
				SessionFactory factory = config.buildSessionFactory();
				// 3. 创建session对象
				Session session = factory.openSession();
				// 4. 开启事务
				Transaction tr = session.beginTransaction();
				
				// 5. 编写保存的代码
				Customer c = new Customer();
				// c.setCust_id(cust_id);	// 主键是自动递增的，所以不用编写
				c.setCust_name("测试3");
				c.setCust_level("2");
				c.setCust_phone("110");
				
				// 保存数据，操作对象就相当于操作数据库的表结构
				session.save(c);
				
				// 6. 提交事务
				tr.commit();
				// 7. 释放资源
				session.close();
				factory.close();
			}

	- 如果在 hibernate.cfg.xml 中不引入映射配置文件，则需要在上述代码的第1点中这样编写：

			// 1. 先加载配置文件
			Configuration config = new Configuration();
			// 默认加载src目录下hibernate.cfg.xml的配置文件
			config.configure();
			// 手动加载（了解即可）
			config.addResource("com/itheima/domain/Customer.hbm.xml");
		 	

> **回忆：快速入门**
>
	1. 下载 Hibernate 框架的开发包
	2. 编写数据库和表结构
	3. 创建WEB的项目，导入了开发的 jar 包
		* MySQL 驱动包、Hibernate 开发的必须要有的 jar 包、日志的 jar 包
	4. 编写 JavaBean，以后不使用基本数据类型，使用包装类
	5. 编写映射的配置文件（核心），先导入开发的约束，里面正常配置标签
	6. 编写 hibernate 的核心的配置文件，里面的内容是固定的
	7. 编写代码，使用的类和方法

##4、Hibernate 常用的配置文件
1. 映射配置文件
	
	- 映射文件，即 Customer.hbm.xml 的配置文件

		* `<class>`标签		-- 用来将类与数据库表建立映射关系
			* name			-- 类的全路径
			* table			-- 表名(如果类名与表名一致,那么 table 属性也可以省略)
			* catalog		-- 数据库的名称，基本上都会省略不写
		
		* `<id>`标签			-- 用来将类中的属性与表中的主键建立映射，id 标签就是用来配置主键的。
			* name			-- 类中属性名
			* column 		-- 表中的字段名.(如果类中的属性名与表中的字段名一致,那么 column 可以省略.)
			* length		-- 字段的程度，如果数据库已经创建好了，那么 length 可以不写。如果没有创建好，生成表结构时，length 最好指定。
		
		* `<property>`		-- 用来将类中的普通属性与表中的字段建立映射.
			* name			-- 类中属性名
			* column		-- 表中的字段名.(如果类中的属性名与表中的字段名一致,那么 column 可以省略.)
			* length		-- 数据长度
			* type			-- 数据类型（一般都不需要编写，如果写需要按着规则来编写）
				* Hibernate的数据类型	 type="string"
				* Java的数据类型		type="java.lang.String"
				* 数据库字段的数据类型 	<column name="name" sql-type="varchar"/>

2. 核心配置文件
	
	- 核心配置文件的两种方式
		* 第一种方式是属性文件的形式，即properties的配置文件
			* hibernate.properties
				* hibernate.connection.driver_class=com.mysql.jdbc.Driver
			* 缺点
				* 不能加载映射的配置文件，需要手动编写代码去加载
		
		* 第二种方式是 XML 文件的形式，**开发基本都会选择这种方式**
			* hibernate.cfg.xml
				` <property name="hibernate.connection.driver_class" >com.mysql.jdbc.Driver</property>`
			* 优点
				* 格式比较清晰
				* 编写有提示
				* **可以在该配置文件中加载映射的配置文件（最主要的优点）**
	
	- 关于 hibernate.cfg.xml 的配置文件方式
		* 必须有的配置
			* 数据库连接信息:

				hibernate.connection.driver_class  			-- 连接数据库驱动程序
				hibernate.connection.url   					-- 连接数据库 URL
				hibernate.connection.username  				-- 数据库用户名
				hibernate.connection.password   			-- 数据库密码
			
			* 方言:

				hibernate.dialect   						-- 操作数据库方言
		
		* 可选的配置

			* hibernate.show_sql							-- 显示 SQL
			* hibernate.format_sql							-- 格式化 SQL
			* hibernate.hbm2ddl.auto						-- 通过映射转成 DDL 语句，**常用： update**
				* create				-- 每次都会创建一个新的表 --- 测试的时候
				* create-drop			-- 每次都会创建一个新的表，当执行结束之后，将创建的这个表删除 --- 测试的时候
				* **update				-- 如果有表,使用原来的表。没有表,创建一个新的表，同时更新表结构（比如新增一个字段，但是不能删除字段）**
				* validate				-- 如果有表,使用原来的表。同时校验映射文件与表中字段是否一致，如果不一致就会报错。
		
		* 加载映射
			* 如果XML方式：

					<mapping resource="cn/itcast/hibernate/domain/User.hbm.xml" />

##5、Hibernate 常用的接口和类
1. **Configuration 类和作用**
	
	- Configuration 类

		* Configuration 对象用于配置并且启动 Hibernate。

		* Hibernate 应用通过该对象来获得对象-关系映射文件中的元数据，以及动态配置 Hibernate 的属性，然后创建 SessionFactory 对象。
		
		* 简单一句话：加载 Hibernate 的配置文件，可以获取 SessionFactory 对象。
	
	- Configuration 类的其他应用（了解）
		* 加载配置文件的种类，Hibernate 支持 xml 和 properties 类型的配置文件，在开发中基本都使用 XML 配置文件的方式。
			* 如果采用的是 properties 的配置文件，那么通过：
	
					Configuration configuration = new Configuration();

				就可以自动配置文件，但是还需要自己手动加载映射文件（xxx.hbm.xml）：

					config.addResource("cn/itcast/domain/Student.hbm.xml");
			
			* 如果采用的XML的配置文件，通过：
			
					Configuration configuration = new Configuration().configure();

				加载配置文件。
	
2. **SessionFactory：重要**
	
	- SessionFactory 是工厂类，是生成 Session 对象的工厂类
	- SessionFactory 类的特点
		* 由 Configuration 通过加载配置文件创建该对象。
		* SessionFactory 对象中保存了当前的数据库配置信息和所有映射关系以及预定义的 SQL 语句。同时，SessionFactory 还负责维护 Hibernate 的二级缓存。
			* 预定义SQL语句
				* 使用 Configuration 类创建了 SessionFactory 对象是，已经在SessionFacotry 对象中缓存了一些 SQL 语句
				* 常见的 SQL 语句是增删改查（通过主键来查询）
				* 这样做的目的是效率更高
		
		* 一个 SessionFactory 实例对应一个数据库，应用从该对象中获得 Session 实例。

		* SessionFactory 是线程安全的，意味着它的一个实例可以被应用的多个线程共享。

		* SessionFactory 是重量级的，意味着不能随意创建或销毁它的实例。如果只访问一个数据库，只需要创建一个 SessionFactory 实例，且在应用初始化的时候完成。

		* SessionFactory 需要一个较大的缓存，用来存放预定义的SQL语句及实体的映射信息。另外可以配置一个缓存插件，这个插件被称之为 Hibernate 的二级缓存，被多线程所共享
	
	3. 总结

		* 一般应用使用一个 SessionFactory,最好是应用启动时就完成初始化。
	
	![](http://upload-images.jianshu.io/upload_images/2106579-f266207ea1e88680.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
	
3. **编写HibernateUtil的工具类**
	
	- 正因为 SessionFactory 比较特别，每次使用时都是固定的代码，所以可以把代码抽取出来，编写工具类。
	
	- 具体代码如下

			public class HibernateUtil {
				private static final Configuration cfg;
				private static final SessionFactory factory;
				static{
					// 给常量赋值 
					// 加载配置文件
					cfg = new Configuration().configure();
					// 生成factory对象
					factory = cfg.buildSessionFactory();
				}
				// 获取Session对象
				public static Session openSession(){
					return factory.openSession();
				}
			}
	
4. **Session 接口**
	
	- 概述

		* Session 是在 Hibernate 中使用最频繁的接口。也被称之为持久化管理器。它提供了和持久化有关的操作，比如添加、修改、删除、加载和查询实体对象

		* Session 是应用程序与数据库之间交互操作的一个单线程对象，是 Hibernate 运作的中心

		* Session是线程不安全的

		* 所有持久化对象必须在 session 的管理下才可以进行持久化操作

		* Session 对象有一个一级缓存，显式执行 flush 之前，所有的持久化操作的数据都缓存在 session 对象处

		* 持久化类与 Session 关联起来后就具有了持久化的能力
	
	- 特点

		* 不是线程安全的。应避免多个线程使用同一个 Session 实例

		* Session 是轻量级的，它的创建和销毁不会消耗太多的资源。应为每次客户请求分配独立的 Session 实例

		* Session 有一个缓存，被称之为 Hibernate 的一级缓存。每个 Session 实例都有自己的缓存
	
	- **常用的方法**

		* save(obj)
		
				/**
				 * 测试工具类
				 */
				@Test
				public void testSave2(){
					// 使用工具类简化代码
					Session session = HibernateUtils.getSession();
					Transaction tr = session.beginTransaction();

					Customer c = new Customer();
					c.setCust_name("小风");
					session.save(c);

					// 提交事务
					tr.commit();
					// 释放资源
					session.close();
				}

		* get(Class,id) 

			> 2个参数：class 表示要查询的 JavaBean 的 class 对象，id 为主键的值。

			例如，需要查 Customer 对应的表中主键值为7（Long 类型）的记录，代码如下：

				Customer c = session.get(Customer.class, 7L);

		* delete(obj)  
	
			> 注意：在这里是对数据库进行操作，所以删除的是数据库的表中的某一行记录，所以首先要调用上面的 get 方法，得到对象后，再删除。

				Customer c = session.get(Customer.class, 7L);
				
				// 删除客户
				session.delete(c);

		* update(obj)

				Customer c = session.get(Customer.class, 95L);
				
				// 设置客户的信息
				c.setCust_name("小苍");
				c.setCust_level("3");
				
				// 修改
				session.update(c);

		* saveOrUpdate(obj)					-- 保存或者修改（如果没有数据，保存数据。如果有，修改数据）

			- 保存
			
					Customer c = new Customer();
					// c.setCust_id(10L);	这是错误做法！千万不能自己设置主键去保存！
					c.setCust_name("测试");
					session.saveOrUpdate(c);
			
			- 修改

					// 先查询再改
					Customer c = session.get(Customer.class, 6L);
					c.setCust_name("小泽");
					session.saveOrUpdate(c);

		* createQuery() 					-- HQL语句的查询的方式
	
				// 创建查询的接口
				Query query = session.createQuery("from Customer");
				// 查询该表所有的数据
				List<Customer> list = query.list();
				for (Customer customer : list) {
					System.out.println(customer);
				}

5. **Transaction 接口**
	
	- Transaction 是事务的接口

	- 常用的方法

		* commit()				-- 提交事务

		* rollback()			-- 回滚事务
	
	- 特点

		* Hibernate 框架默认情况下事务不自动提交.需要手动提交事务

		* 如果没有开启事务，那么每个 Session 的操作，都相当于一个独立的事务

		> 在如上的代码中，都开启了事务，并且手动提交了事务。

	- 示例：

			/**
			 * 测试保存
			 */
			@Test
			public void testSave3(){
				Session session = null;
				Transaction tr = null;
				try {
					// 获取session
					session = HibernateUtils.getSession();
					// 开启事务
					tr = session.beginTransaction();
					// 执行代码
					Customer c = new Customer();
					c.setCust_name("哈哈");
					// 保存
					session.save(c);
					// 提交事务事务
					tr.commit();
				} catch (Exception e) {
					// 回滚事务
					tr.rollback();
					e.printStackTrace();
				}finally{
					// 释放资源
					session.close();
				}
			}
