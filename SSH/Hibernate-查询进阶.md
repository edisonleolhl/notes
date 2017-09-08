> 本文包括：
> 
> 1、Hibernate 的查询方式
> 
> 2、HQL (Hibernate Query Language) 查询
> 
> 3、HQL 的投影查询
> 
> 4、HQL 的聚合函数查询
> 
> 5、QBC (Query By Criteria ) 条件查询
> 
> 6、QBC 离线条件查询
> 
> 7、SQL查询方式（了解）
> 
> 8、HQL 多表查询
> 
> 9、延迟加载
> 
> 10、Hibernate 的查询策略

##1、Hibernate 的查询方式
	
1. 根据唯一标识 OID 的检索方式

	* session.get(XXX.class,OID)

	> 可利用断点调试观察，执行该行代码时的控制台输出为：
	>  
	>  select * from xx where id = ?

2. 对象的导航的方式

	- Customer.getLinkmans()
	
	> 执行该行代码时，控制台输出： 
	> 
	> select * from cst_linkmans where cust_id = ? 
	
3. HQL 的检索方式
	
	* Hibernate Query Language	-- Hibernate 的查询语言
	
4. QBC 的检索方式

	* Query By Criteria	-- 条件查询
	
5. SQL 检索方式（了解）
	
	* 本地的 SQL 检索 -- 较麻烦，在 Hibernate 中不推荐使用

##2、HQL (Hibernate Query Language) 查询
1. HQL 的介绍：
	
	* HQL(Hibernate Query Language) 是面向对象的查询语言, 它和 SQL 查询语言有些相似
	
	* 在 Hibernate 提供的各种检索方式中, HQL 是使用最广的一种检索方式
	
2. HQL 与 SQL 的关系：
	
	* HQL 查询语句是面向对象的，Hibernate 负责解析 HQL 查询语句, 然后根据对象-关系映射文件中的映射信息, 把 HQL 查询语句翻译成相应的 SQL 语句. 
	
	* HQL 查询语句中的主体是域模型中的类及类的属性
	
	* SQL 查询语句是与关系数据库绑定在一起的。SQL查询语句中的主体是数据库表及表的字段

1. HQL基本的查询格式：
	
	* 支持方法链的编程，即直接调用 `list()` 方法
	
	* 简单的代码如下
	
			session.createQuery("from Customer").list();
	
2. 使用别名的方式：
	
	* 可以使用别名的方式
		
			session.createQuery("from Customer c").list();
			session.createQuery("select c from Customer c").list();
	
3. 排序查询：
	
	* 排序查询和SQL语句中的排序的语法是一样的
	
		* 升序
	
				session.createQuery("from Customer order by cust_id").list();
			
		- 降序
					
				session.createQuery("from Customer order by cust_id desc").list();
	
4. 分页查询（不用管 DBMS 是 Oracle 还是 MySQL，Hibernate 自动帮我们完成分页）：
	
	* Hibernate 框架提供了分页的方法，咱们可以调用方法来完成分页
	
	* 两个方法如下
	
		* setFirstResult(a)		-- 从哪条记录开始，如果查询是从第一条开启，值是0
	
		* setMaxResults(b)		-- 每页查询的记录条数
			
	* 演示代码如下
		
			List<LinkMan> list = session.createQuery("from LinkMan").setFirstResult(0).setMaxResults().list();
	
	> MySQL 对于分页的实现：
	> 
	> limit ?,? （注意：参数的值 从 0 开始）
	> 
	> 第一个参数：该页从第几个记录开始，有公式：`(currentPage - 1) * pageSize`
	> 
	> 第二个参数：每页显示多少个记录，一般取个固定值，如 10

5. 带条件的查询：
	- Query.setString(0,"男");
	
	- Query.setLong(0,2L);
	
	* Query.setParameter("?号的位置，默认从0开始","参数的值");  -- 这个方法不用像上面两个方法一样考虑参数的具体类型
	
	* 按名称绑定参数的条件查询（HQL语句中的 ? 号换成 :名称 的方式）
	
			Query query = session.createQuery("from Customer where name = :aaa and age = :bbb");
			query.setString("aaa", "李健");
			query.setInteger("bbb", 38);
			List<Customer> list = query.list();

	> 对应 JDBC 的代码：
	> 
	> PreparedStatement.setString(1,"男");
	> 
	> 注意：JDBC 的查询从1开始！

##3、HQL 的投影查询
1. 投影查询就是想查询某一字段的值或者某几个字段的值

2. 投影查询的案例
	
	* 如果查询多个字段，返回的 list 中每个元素是对象数组（object[]）

			List<Object[]> list = session.createQuery("select c.cust_name,c.cust_level from Customer c").list();
			for (Object[] objects : list) {
				System.out.println(Arrays.toString(objects));
			}
		
	* 如果查询两个字段，也可以把这两个字段封装到对象中
	
		* 先在持久化类中提供对应字段的构造方法

				public class Customer {
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

					// 持久化类中一定要有无参的构造方法，所以需要手动重载
					public Customer(){};
		
					public Customer(cust_name,cust_level){};
			
				}

		* 然后使用下面这种 HQL 语句的方式： `select new Customer(c.cust_name,c.cust_level) from Customer c`

				List<Customer> list = session.createQuery("select new Customer(c.cust_name,c.cust_level) from Customer c").list();
				for (Customer customer : list) {
					System.out.println(customer);
				}

##4、HQL 的聚合函数查询
1. 聚合函数：count(),avg(),max(),min(),sum()，返回的是一个数值

2. 获取总的记录数

		Session session = HibernateUtils.getCurrentSession();
		Transaction tr = session.beginTransaction();
		List<Number> list = session.createQuery("select count(c) from Customer c").list();
		Long count = list.get(0).longValue();
		System.out.println(count);
		tr.commit();
	
	> Number 类是 Integer、Float、Double、Long 等等的父类，所以泛型写 Number 最省事，得到后可以转化为具体的子类，在上面的代码中，调用了 `Number.longValue()`，于是转为了 Long 类型。

3. 获取某一列数据的和

		Session session = HibernateUtils.getCurrentSession();
		Transaction tr = session.beginTransaction();
		List<Number> list = session.createQuery("select sum(c.cust_id) from Customer c").list();
		Long count = list.get(0).longValue();
		System.out.println(count);
		tr.commit();

#5、QBC (Query By Criteria ) 条件查询
1. 简单查询，使用的是 Criteria 接口

		List<Customer> list = session.createCriteria(Customer.class).list();
		for (Customer customer : list) {
			System.out.println(customer);
		}
	
2. 排序查询
	
	* 需要使用 `addOrder()` 的方法来设置参数，参数使用
			
			org.hibernate.criterion.Order 对象的 asc() or desc() 方法
		如：

			criteria.addOrder(Order.desc("lkm_id"));

	- 具体代码如下：

			Session session = HibernateUtils.getCurrentSession();
			Transaction tr = session.beginTransaction();
			Criteria criteria = session.createCriteria(Linkman.class);
			// 设置排序
			criteria.addOrder(Order.desc("lkm_id"));
			List<Linkman> list = criteria.list();
			for (Linkman linkman : list) {
				System.out.println(linkman);
			}
			tr.commit();
	
3. 分页查询
	
	* QBC 的分页查询也是使用两个方法，与 HQL 一样
	
		* setFirstResult();
	
		* setMaxResults();
		
	* 代码如下;

			Session session = HibernateUtils.getCurrentSession();
			Transaction tr = session.beginTransaction();
			Criteria criteria = session.createCriteria(Linkman.class);
			// 设置排序
			criteria.addOrder(Order.desc("lkm_id"));
			criteria.setFirstResult(0);
			criteria.setMaxResults(3);
			List<Linkman> list = criteria.list();
			for (Linkman linkman : list) {
				System.out.println(linkman);
			}
			tr.commit();
	
4. 条件查询（Criterion 是查询条件的接口，Restrictions 类是 Hibernate 框架提供的工具类，使用该工具类来设置查询条件）
	
	* 条件查询使用 Criteria 接口的 add 方法，用来传入条件。
	
	* 使用 Restrictions 的添加条件的方法，来添加条件，例如：
	
		* Restrictions.eq			-- 相等
	
		* Restrictions.gt			-- 大于号
	
		* Restrictions.ge			-- 大于等于
	
		* Restrictions.lt			-- 小于
	
		* Restrictions.le			-- 小于等于
	
		* Restrictions.between		-- 在之间，闭区间
	
		* Restrictions.like			-- 模糊查询
	
		* Restrictions.in			-- 范围
	
		* Restrictions.and			-- 并且
	
		* Restrictions.or			-- 或者
	
		- Restrictions.isNull       -- 判断某个字段是否为空

	- Restrictions.in 示例：

		首先看参数类型：

			Restrictions.in(String propertyName, Collection values)

		发现，应该在第二个参数传入 Collection ，于是可以这样演示：
		
			Criteria criteria = session.createCriteria(Linkman.class);
			
			List<Long> params = new ArrayList<Long>();
			params.add(1L);
			params.add(2L);
			params.add(7L);
			
			// 使用in 方法查询
			criteria.add(Restrictions.in("lkm_id", params));
	
		SQL：

			select * from cst_linkman 
			where lkm_id in (1,2,7);

	* Restrictions.or 示例：

		首先看参数类型，发现有两种重载方法：

			Restrictions.or(Criterion lhs, Criterion rhs)
			Restrictions.or(Criterion... predicates)

		很明显，第一个是两个条件，第二个是可变参数，所以条件数量不定，但是可以发现，参数类型都是 Criterion ，故都应该传入 `Restrictions.XX()`。

			Session session = HibernateUtils.getCurrentSession();
			Transaction tr = session.beginTransaction();
			Criteria criteria = session.createCriteria(Linkman.class);
			// 设置排序
			criteria.addOrder(Order.desc("lkm_id"));
			// 设置查询条件
			criteria.add(Restrictions.or(Restrictions.eq("lkm_gender", "男"), Restrictions.gt("lkm_id", 3L)));
			List<Linkman> list = criteria.list();
			for (Linkman linkman : list) {
				System.out.println(linkman);
			}
			tr.commit();
	
		SQL：

			select * from Linkman 
			where lkm_gender='男' or lkm_id=3 
			order by lkm_id desc;

5. 聚合函数查询（Projection 的聚合函数的接口，而 Projections 是 Hibernate 提供的工具类，使用该工具类设置聚合函数查询）
	
	* 使用 QBC 的聚合函数查询，需要使用 `criteria.setProjection()` 方法
	
		如：

			criteria.setProjection(Projections.rowCount());

		又如：

			criteria.setProjection(Projections.count("lkm_id"));

	* 具体的代码如下：

			Session session = HibernateUtils.getCurrentSession();
			Transaction tr = session.beginTransaction();
			Criteria criteria = session.createCriteria(Linkman.class);
			criteria.setProjection(Projections.rowCount());
			List<Number> list = criteria.list();
			Long count = list.get(0).longValue();
			System.out.println(count);
			tr.commit();

	- 注意，如果想先执行 `select count(*) from xxx` ，再执行 `select * from xxx`，不能直接在后面执行编写 QBC 语句，应该先“恢复” Projection

			// 创建QBC查询接口
			Criteria criteria = session.createCriteria(Linkman.class);
			// 设置聚合函数的方式  select count(lkm_id) from 表;  5
			criteria.setProjection(Projections.count("lkm_id"));
			List<Number> list = criteria.list();
			Long count = list.get(0).longValue();
			System.out.println(count);
			
			criteria.setProjection(null);
			
			// 继续查询所有的联系人  select * from 表
			List<Linkman> mans = criteria.list();

##6、QBC 离线条件查询
1. 离线条件查询使用的是 DetachedCriteria 接口进行查询，离线条件查询对象在**创建**的时候不需要使用 Session 对象，在**添加条件** 时也不需要 Session 对象，只有在**查询**的时候使用 Session 对象即可，所以叫做离线条件查询。

	> 为什么要有离线条件查询？
	> 
	> 一般情况下，在业务层开启 Session 后，在持久层对数据进行操作，而在 web 层需要接收条件查询的若干条件，所以在 web 层就设置条件会很方便，又因为 Criteria 需要由 Session 创建，所以无法在 web 层设置条件，于是离线条件查询出现了。

2. 创建离线条件查询对象
	
		DetachedCriteria criteria = DetachedCriteria.forClass(Linkman.class);
	
3. 具体的代码如下，注意顺序，这样是可行的

		DetachedCriteria criteria = DetachedCriteria.forClass(Linkman.class);
		// 设置查询条件
		criteria.add(Restrictions.eq("lkm_gender", "男"));
		
		Session session = HibernateUtils.getCurrentSession();
		Transaction tr = session.beginTransaction();

		// 查询数据
		List<Linkman> list = criteria.getExecutableCriteria(session).list();
		for (Linkman linkman : list) {
			System.out.println(linkman);
		}
		tr.commit();

##7、SQL查询方式（了解）
1. 基本语法

		Session session = HibernateUtils.getCurrentSession();
		Transaction tr = session.beginTransaction();
		
		SQLQuery sqlQuery = session.createSQLQuery("select * from cst_linkman where lkm_gender = ?");
		sqlQuery.setParameter(0,"男");
		sqlQuery.addEntity(Linkman.class);
		List<Linkman> list = sqlQuery.list();
		System.out.println(list);
		tr.commit();

##8、HQL 多表查询
1. 多表查询使用 HQL 语句进行查询，HQL 语句和 SQL 语句的查询语法比较类似
	
	* 内连接查询
	
		* 显示内连接
	
				select * from customers c inner join orders o on c.cid = o.cno;
	
		* 隐式内连接
	
				select * from customers c,orders o where c.cid = o.cno;
		
	* 外连接查询
	
		* 左外连接
	
				select * from customers c left join orders o on c.cid = o.cno;
	
		* 右外连接
	
				select * from customers c right join orders o on c.cid = o.cno;
	
2. HQL 多表查询时的两种方式
	
	* 迫切和非迫切：
	
		* 非迫切返回结果是 Object[]
	
		* 迫切连接返回的结果是对象，把客户的信息封装到客户的对象中，把订单的信息封装到客户的 Set 集合中
	
	* 非迫切内连接使用 inner join ，默认返回的是 Object 数组

			Session session = HibernateUtils.getCurrentSession();
			Transaction tr = session.beginTransaction();
			List<Object[]> list = session.createQuery("from Customer c inner join c.linkmans").list();
			for (Object[] objects : list) {
				System.out.println(Arrays.toString(objects));
			}
			tr.commit();
		
	* 迫切内连接使用 inner join fetch ，返回的是实体对象

			Session session = HibernateUtils.getCurrentSession();
			Transaction tr = session.beginTransaction();
			List<Customer> list = session.createQuery("from Customer c inner join fetch c.linkmans").list();
			Set<Customer> set = new HashSet<Customer>(list);
			for (Customer customer : set) {
				System.out.println(customer);
			}
			tr.commit();
	
		> 把 List 转为 Set 集合，可以消除重复的数据

4. 左外连接查询
	
	* 非迫切左外连接：封装成List<Object[]>
		
	* 迫切左外连接：

			Session session = HibernateUtils.getCurrentSession();
			Transaction tr = session.beginTransaction();
			List<Customer> list = session.createQuery("from Customer c left join fetch c.linkmans").list();
			Set<Customer> set = new HashSet<Customer>(list);
			for (Customer customer : set) {
				System.out.println(customer);
			}
			tr.commit();

##9、延迟加载
1. 原理：先获取到代理对象，当真正使用到该对象中的属性的时候，才会发送 SQL 语句，是 Hibernate 框架提升性能的方式

2. **类级别**的延迟加载
	
	* Session 对象的 load 方法默认就是延迟加载，例如：

			Customer c = session.load(Customer.class, 1L);
	
		断点调试，发现，执行该行代码时，控制台输出为空，即没有发送 SQL 语句，再执行下面这行代码：

			System.out.println(c.getCust_name);
		
		此时发现，控制台输出对应的 SQL 语句。
	
		> Session.get(Class,id) 没有延迟加载

	* 使类级别的延迟加载失效（一般情况下使用默认的延迟加载）
	
		* 在映射配置文件的 `<class>` 标签上配置 `lazy="false"`
	
				<?xml version="1.0" encoding="UTF-8"?>
				<!DOCTYPE hibernate-mapping PUBLIC 
				    "-//Hibernate/Hibernate Mapping DTD 3.0//EN"
				    "http://www.hibernate.org/dtd/hibernate-mapping-3.0.dtd">
				<hibernate-mapping>
					
					<class name="com.itheima.domain.Customer" table="cst_customer" lazy="false">
						<id name="cust_id" column="cust_id">
							<generator class="native"/>
						</id>
						
						<property name="cust_name" column="cust_name"/>
						<property name="cust_user_id" column="cust_user_id"/>
						<property name="cust_create_id" column="cust_create_id"/>
						<property name="cust_source" column="cust_source"/>
						<property name="cust_industry" column="cust_industry"/>
						<property name="cust_level" column="cust_level"/>
						<property name="cust_linkman" column="cust_linkman"/>
						<property name="cust_phone" column="cust_phone"/>
						<property name="cust_mobile" column="cust_mobile"/>
						
						<!-- 配置一方 -->
						<!--
							set标签name属性：表示集合的名称
						-->
						<set name="linkmans" inverse="true">
							<!-- 需要出现子标签 -->
							<!-- 外键的字段 -->
							<key column="lkm_cust_id"/>
							<one-to-many class="com.itheima.domain.Linkman"/>
						</set>
						
					</class>
					
				</hibernate-mapping>    

	    * Hibernate.initialize(Object proxy);
	
3. **关联级别**的延迟加载（查询某个客户，当查看该客户下的所有联系人是是否是延迟加载）
	
	- 代码：

			Session session = HibernateUtils.getCurrentSession();
			Transaction tr = session.beginTransaction();
			Customer c = session.get(Customer.class, 1L);
			System.out.println("=============");
			System.out.println(c.getLinkmans().size());
			tr.commit();

		最后在控制台上发现，在执行第二个输出语句时，控制台才会输出如下类似语句，所以关联级别的延迟加载也是默认的

			 select * from Linkmans where cust_id = ?

##10、Hibernate 的查询策略
1. 查询策略：使用 Hibernate 查询一个对象的关联对象时，应该如何查询，这是 Hibernate 的一种优化手段!!!	
	
2. Hibernate 查询策略要解决的问题：
	
	* 查询的时机

			Customer c1 = (Customer) session.get(Customer.class, 1);
			System.out.println(c1.getLinkmans().size());
			
		> lazy 属性解决查询的时机的问题，配置是否该持久化类是否采用延迟加载
		
	* 查询的语句形式

			List<Customer> list = session.createQuery("from Customer").list();
			for(Customer c : list){
				System.out.println(c.getLinkmans());
			}
			
		> fetch 属性就可以解决查询语句的形式的问题，具体见下文

###在 `<set>` 标签上配置策略
1. 在 `<set>` 标签上使用 fetch 和 lazy 属性
	
	* fetch 的取值				-- 控制 SQL 语句生成的格式
	
		* select				-- 默认值，发送普通的查询语句
	
		* join					-- 连接查询，发送的是一条迫切左外连接，配置了join，lazy 无论取哪种值都是同一个效果
	
		* subselect				-- 子查询，发送一条子查询查询其关联对象（需要使用 `list()` 方法进行测试）
		
	* lazy 的取值				-- 查找关联对象的时候是否采用延迟
	
		* true					-- 默认值，延迟加载
	
		* false					-- 不延迟
	
		* extra					-- 极其懒惰
	
2. `<set>` 标签上的默认值是 `fetch="select"` 和 `lazy="true"`
	
###在 `<many-to-one>` 标签上配置策略
1. 在<many-to-one>标签上使用fetch和lazy属性
	
	* fetch 的取值		-- 控制SQL的格式
	
		* select		-- 默认值，发送基本的查询查询
	
		* join			-- 发送迫切左外连接查询
		
	* lazy 的取值		-- 控制加载关联对象是否采用延迟
	
		* false			-- 不采用延迟加载.
	
		* proxy			-- 默认值，代理，现在是否采用延迟加载，由另一端（即一对多的一方）的 `<class>` 上的 lazy 确定
		
			- 如果一方的 `<class>` 上的`lazy="true"`，proxy 的值就是 true (延迟加载)
	
			* 如果一方的 `<class>` 上的 `lazy="false"`，proxy的值就是 false (不采用延迟.)	

2. 在 `<many-to-one>` 标签上的默认值是 `fetch="select"` 和 `lazy="proxy"`

###总结：Hibernate 框架都采用了默认值，开发中基本上使用的都是默认值。
