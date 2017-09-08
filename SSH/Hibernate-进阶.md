> 本文包括：
> 	
> 1、Hibernate的持久化类
> 
> 2、Hibernate 持久化对象的三个状态（难点）
> 
> 3、Hibernate 的一级缓存
> 
> 4、Hibernate 中的事务与并发
> 
> 5、Hibernate 的查询方式（HQL：Hibernate Query Language）

##1、Hibernate的持久化类
- 什么是持久化类？
	
	持久化类：就是一个 Java 类（咱们编写的 JavaBean），这个 Java 类与表建立了映射关系就可以成为是持久化类。
	> **简单记：持久化类 = JavaBean + xxx.hbm.xml**
	
- 持久化类的编写规则：
	
	1. 提供一个无参数 public访问控制符的构造器				—— 底层需要进行反射。

	2. 提供一个标识属性，映射数据表主键字段					—— 唯一标识 OID，数据库中通过主键，Java 对象通过地址确定对象，持久化类通过唯一标识 OID 确定记录。

	> SQL 语句：`cust_id` bigint(32) NOT NULL AUTO_INCREMENT COMMENT '客户编号(主键)'

	>JavaBean 代码：private Long cust_id;

	>结论：JavaBean 中的 cust_id 即为唯一标识 OID。

	3. 所有属性提供 public 访问控制符的 set 和 get 方法。

	4. 标识属性应尽量使用基本数据类型的包装类型（默认值为 null）。
	
- 自然主键和代理主键的区别：
	
	* 自然主键：该主键是对象本身的一个属性。例如：创建一个人员表，每个人都有一个身份证号(唯一的)。使用身份证号作为表的主键，称为自然主键。（**开发中不会使用这种方式**）

	* 代理主键：该主键不是对象本身的一个属性。例如：创建一个人员表，为每个人员单独创建一个字段，用这个字段作为主键，称为代理主键。（**开发中推荐使用这种方式**）
	
	> 简单记：创建表时，新增一个毫无关系的字段，用该字段作为主键。

- 主键的生成策略：
	
	1. increment：适用于 short,int,long 作为主键，没有使用数据库的自动增长机制。

		* Hibernate 中提供的一种增长机制，具体步骤如下：

			* 先进行查询：select max(id) from user;

			* 再进行插入：获得最大值+1作为新的记录的主键。
		
		* 问题：不能在集群环境下或者有并发访问的情况下使用。
	
		> 分析：在查询时，有可能有两个用户几乎同时得到相同的 id，再插入时就有可能主键冲突！

	2. identity：适用于 short,int,long 作为主键。但是必须使用在有自动增长机制的数据库中，并且该数据库采用的是数据库底层的自动增长机制。

		* 底层使用的是数据库的自动增长(auto_increment)，像 Oracle 数据库没有自动增长机制，而MySql、DB2 等数据库有自动增长的机制。
	
	3. sequence：适用于 short,int,long 作为主键，底层使用的是序列的增长方式。

		* Oracle 数据库底层没有自动增长,若想自动增长需要使用序列。
	
	4. **uuid**：适用于 char,varchar 类型的作为主键。

		* 使用随机的字符串作为主键.
	
	5. **native**：本地策略。根据底层的数据库不同,自动选择适用于该种数据库的生成策略(short,int,long)。

		* 如果底层使用的 MySQL 数据库：相当于 identity.

		* 如果底层使用 Oracle 数据库：相当于 sequence.
	
	6. assigned：主键的生成不用 Hibernate 管理了，必须手动设置主键。	

	> **重点掌握：uuid（字符串）、native（数字）**

##2、Hibernate 持久化对象的三个状态（难点）
- 持久化对象的状态	
	1. Hibernate 的持久化类（前文已写）
	
	2. Hibernate 的持久化类的状态
		* Hibernate为了管理持久化类：将持久化类分成了三个状态
			1. 瞬时态:Transient  Object

				* 没有持久化标识 OID, 没有被纳入到 Session 对象的管理（即没有关系）

			2. 持久态:Persistent Object
	
				* 有持久化标识 OID,已经被纳入到 Session 对象的管理.
			
			3. 托管态:Detached Object

				* 有持久化标识 OID,没有被纳入到 Session 对象的管理.
	
- Hibernate 持久化对象的状态的转换
	
	1. 瞬时态	-- 没有持久化标识 OID, 没有被纳入到 Session 对象的管理
		* 获得瞬时态的对象
			
				User user = new User();

			> 创建了持久化类的对象，该对象还没有 OID，也和 Session 对象无关，所以是瞬时态。

		* 瞬时态对象转换持久态
			
				session.save(user); 或者 session.saveOrUpdate(user);

			> user对象进入缓存，且自动生成了 OID，故为持久态。

		* 瞬时态对象转换成托管态
			
				user.setId(1);
	
			> 手动设置了 OID，但没有和 Session 对象发生关系，故为托管态。

	2. 持久态	-- 有持久化标识OID,已经被纳入到Session对象的管理
		* 获得持久态的对象
				
				get()/load();

		* 持久态转换成瞬时态对象
			
				delete();  --- 比较有争议的，进入特殊的状态(删除态:Hibernate中不建议使用的)

		* 持久态对象转成脱管态对象
			
				session的close()/evict()/clear();
	
			> Session 对象被销毁，所以持久化类的对象没有被 session 管理，所以为托管态。

	3. 脱管态	-- 有持久化标识OID,没有被纳入到Session对象的管理

		* 获得托管态对象:*不建议直接获得脱管态的对象.*

				User user = new User();
				user.setId(1);

		* 脱管态对象转换成持久态对象

				update();/saveOrUpdate()/lock();

		* 脱管态对象转换成瞬时态对象

				user.setId(null);
	
	4. **注意：持久态对象有自动更新数据库的能力!!!**

		- 测试代码：
	
				/**
				 * 持久态的对象有自动更新数据库的能力
				 * session的一级缓存！！
				 */
				@Test
				public void run1(){
					Session session = HibernateUtils.getSession();
					Transaction tr = session.beginTransaction();
					
					// 获取到持久态的对象
					User user = session.get(User.class,1);
					// user是持久态，有自动更新数据库的能力
					System.out.println(user.getName());
					
					// 重新设置新的名称
					user.setName("隔离老王");
					
					// 正常编写代码
					// session.update(user);
					
					tr.commit();
					session.close();
				}
	
		- 执行后，控制台输出：

				Hibernate: 
				    select
				        user0_.id as id1_1_0_,
				        user0_.version as version2_1_0_,
				        user0_.name as name3_1_0_,
				        user0_.age as age4_1_0_ 
				    from
				        t_user user0_ 
				    where
				        user0_.id=?
				小风
				Hibernate: 
				    update
				        t_user 
				    set
				        version=?,
				        name=?,
				        age=? 
				    where
				        id=? 
				        and version=?

		- 从中可以发现，在测试代码中我们把 `session.update(user);` 注释掉了，但是在控制台中发现仍有 `update` 语句，这就是持久态有自动更新数据库的能力，具体原因是 Session 对象的一级缓存（见下节）。

5. 三个状态之间的转换图解：

	![](http://upload-images.jianshu.io/upload_images/2106579-7c29de2311cb5edd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##3、Hibernate 的一级缓存
- Session 对象的一级缓存
	
	1. 什么是缓存？
		* 其实就是一块内存空间，将数据源（数据库或者文件）中的数据存放到缓存中。再次获取的时候，直接从缓存中获取，可以提升程序的性能！
	
	2. Hibernate 框架提供了两种缓存
		* 一级缓存	-- 自带的不可卸载的。一级缓存的生命周期与 session 一致，一级缓存称为 session 级别的缓存.
		* 二级缓存	-- 默认没有开启，需要手动配置才可以使用的。二级缓存可以在多个 session 中共享数据,二级缓存称为是 sessionFactory 级别的缓存.
	
	3. Session 对象的缓存概述
		* Session 接口中，有一系列的 java 的集合,这些 java 集合构成了 Session 级别的缓存(一级缓存)。将对象存入到一级缓存中,session 没有结束生命周期,那么对象在 session 中存放着。
		* 内存中包含 Session 实例 --> Session 的缓存（一些集合） --> 集合中包含的是缓存对象！
	
	4. 证明一级缓存的存在，编写查询的代码即可证明
		* 在同一个 Session 对象中两次查询，可以证明使用了缓存。
	
		- 测试代码：

				@Test
				public void run3(){
					Session session = HibernateUtils.getSession();
					Transaction tr = session.beginTransaction();
					
					// 最简单的证明，查询两次
					User user1 = session.get(User.class, 1);
					System.out.println(user1.getName());
					
					User user2 = session.get(User.class, 1);
					System.out.println(user2.getName());
					
					tr.commit();
					session.close();
				}

		- 控制台只输出一次如下信息：

				Hibernate: 
				    insert 
				    into
				        t_user
				        (version, name, age) 
				    values
				        (?, ?, ?)

		- 进一步分析，若采用断点的方式 debug，发现在执行 `User user2 = session.get(User.class, 1);` 时，控制台不输出任何信息，所以证明了一级缓存的存在。

	5. Hibernate 框架是如何做到数据发生变化时进行同步操作的呢？
		- 实验步骤： 使用 get 方法查询 User 对象，然后设置 User 对象的一个属性，注意：没有做 update 操作。最后发现，数据库中的记录也改变了。
		* 原因：利用快照机制来完成的（SnapShot），且该特性正好和持久态拥有自动更新数据库能力相符合。
		- 快照机制：
			![](http://upload-images.jianshu.io/upload_images/2106579-ff731b29711da5ef.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
	
- 控制 Session 的一级缓存（了解）
	
	- 学习Session接口中与一级缓存相关的方法
		* Session.clear()						-- 清空缓存。

			- 测试代码：
			
					/**
					 * Session.clear()	-- 清空缓存。
					 */
					@Test
					public void run5(){
						Session session = HibernateUtils.getSession();
						Transaction tr = session.beginTransaction();
						
						// 最简单的证明，查询两次
						User user1 = session.get(User.class, 1);
						System.out.println(user1.getName());
						
						// 清空缓存
						session.clear();
						
						User user2 = session.get(User.class, 1);
						System.out.println(user2.getName());
						
						tr.commit();
						session.close();
					}
			
			- 控制台输出：
			
					Hibernate: 
					    select
					        user0_.id as id1_1_0_,
					        user0_.version as version2_1_0_,
					        user0_.name as name3_1_0_,
					        user0_.age as age4_1_0_ 
					    from
					        t_user user0_ 
					    where
					        user0_.id=?
					隔离老王
					Hibernate: 
					    select
					        user0_.id as id1_1_0_,
					        user0_.version as version2_1_0_,
					        user0_.name as name3_1_0_,
					        user0_.age as age4_1_0_ 
					    from
					        t_user user0_ 
					    where
					        user0_.id=?
					隔离老王

			- 由此可见，clear方法可以清除缓存。		

		* Session.evict(Object entity)			-- 从一级缓存中清除指定的实体对象。

			- 若把上面代码中的 `session.clear();`	改为	`session.evict(user1);`，则控制台输出仍如上。

		* Session.flush()						-- 刷出缓存

			- 在一般的快照机制中，是在事务提交时（`tr.commit()；`），比较缓存与快照的不同，然后 Hibernate 框架自动执行 `update` SQL 语句，再更新数据库。

			- 而如果调用 flush 方法，则在执行该方法时就比较缓存与快照的不同，然后 Hibernate 框架自动执行 `update` SQL 语句，最后在事务提交时更新数据库。

			> 上面两点的区别本人经过断点调试一一验证，以保证其正确性。

##4、Hibernate 中的事务与并发
- ###事务相关的概念
	
	1. 什么是事务
		* 事务就是逻辑上的一组操作，组成事务的各个执行单元，操作要么全都成功，要么全都失败.
		* 转账的例子：冠希给美美转钱，扣钱，加钱。两个操作组成了一个事情！
	
	2. 事务的特性
		* 原子性	-- 事务不可分割.
		* 一致性	-- 事务执行的前后数据的完整性保持一致.
		* 隔离性	-- 一个事务执行的过程中,不应该受到其他的事务的干扰.
		* 持久性	-- 事务一旦提交,数据就永久保持到数据库中.
	
	3. 如果不考虑隔离性:引发一些读的问题
		* 脏读			-- 一个事务读到了另一个事务未提交的数据（数据库隔离中最重要的问题）
		* 不可重复读	-- 一个事务读到了另一个事务已经提交的 update 数据,导致多次查询结果不一致.
		* 虚读			-- 一个事务读到了另一个事务已经提交的 insert 数据,导致多次查询结构不一致.
	
	4. 通过设置数据库的隔离级别来解决上述读的问题
		* 未提交读:以上的读的问题都有可能发生.
		* 已提交读:避免脏读,但是不可重复读，虚读都有可能发生.
		* 可重复读:避免脏读，不可重复读.但是虚读是有可能发生.
		* 串行化:以上读的情况都可以避免.
	
	5. 如果想在Hibernate的框架中来设置隔离级别，需要在 hibernate.cfg.xml 的配置文件中通过标签来配置
		* 通过：hibernate.connection.isolation = 4 来配置
		* 取值：
			* 1—Read uncommitted isolation
			* 2—Read committed isolation
			* 4—Repeatable read isolation
			* 8—Serializable isolation

- ###丢失更新的问题
	
	1. 如果不考虑隔离性，也会产生写入数据的问题，这一类的问题叫丢失更新的问题。

	2. 例如：两个事务同时对某一条记录做修改，就会引发丢失更新的问题。
		* A 事务和 B 事务同时获取到一条数据，同时再做修改
		* 如果 A 事务修改完成后，提交了事务
		* B 事务修改完成后，不管是提交还是回滚，如果不做处理，都会对数据产生影响
		![](http://upload-images.jianshu.io/upload_images/2106579-2c1b9535b6df3d58.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

	3. 解决方案有两种
		* 悲观锁

			* 采用的是数据库提供的一种锁机制，如果采用做了这种机制，在SQL语句的后面添加 for update 子句

				* 当A事务在操作该条记录时，会把该条记录锁起来，其他事务是不能操作这条记录的。

				* 只有当A事务提交后，锁释放了，其他事务才能操作该条记录
		
		* 乐观锁

			* 使用的不是数据库锁机制，而是采用版本号的机制来解决的。给表结构添加一个字段 `version=0`，默认值是0

				* 当 A 事务在操作完该条记录，提交事务时，会先检查版本号，如果发生版本号的值相同时，才可以提交事务。同时会更新版本号 `version=1`.

				* 当 B 事务操作完该条记录时，提交事务时，会先检查版本号，如果发现版本不同时，程序会出现错误。
	
	4. 使用 Hibernate 框架解决丢失更新的问题
		* 悲观锁（效率较低，不常见）
			* 使用 `session.get(Customer.class, 1,LockMode.UPGRADE);` 方法
		
		* 乐观锁
			* 在对应的 JavaBean 中添加一个属性，名称可以是任意的。例如：`private Integer version;` 提供 get 和 set 方法

			* 在映射的配置文件中，提供`<version name="version"/>`标签即可。
	
	> 附上本人以前学习的笔记，从 JDBC 角度分析事务、隔离级别、丢失更新问题：[http://www.jianshu.com/p/aacde54542b5](http://www.jianshu.com/p/aacde54542b5 "http://www.jianshu.com/p/aacde54542b5")

- ###绑定本地的 Session
	
	1. 在上文所附的文章里，讲解了 JavaWEB 的事务，需要在业务层使用 Connection 来开启事务。
		* 一种是通过参数的方式，一层一层的传递下去
		* 另一种是把 Connection 绑定到 ThreadLocal 对象中，因为 ThreadLocal 对于内通过 map 存储了 `key = 当前线程`, `value= Connection对象`

		> ThreadLocal 两个重要方法
		
		> - get
		> public T get()  返回此线程局部变量的当前线程副本中的值。如果变量没有用于当前线程的值，则先将其初始化为调用 initialValue() 方法返回的值。 
		> 返回：
		> 此线程局部变量的当前线程的值	
		
		> - set
		> public void set(T value)  将此线程局部变量的当前线程副本中的值设置为指定值。大部分子类不需要重写此方法，它们只依靠 initialValue() 方法来设置线程局部变量的值。
		> 参数：
		> value - 存储在此线程局部变量的当前线程副本中的值。

	2. 在 Hibernate 框架中，使用 session 对象开启事务，而 session 对象存在于业务层中，所以需要把 session 对象传递到持久层，在持久层使用 session 对象操作数数据对象，框架提供了 ThreadLocal 的方式：
		* 首先需要在 hibernate.cfg.xml 的配置文件中提供配置

				<property name="hibernate.current_session_context_class">thread</property>
		
		* 然后重写 HibernateUtil 的工具类，使用 SessionFactory 的 getCurrentSession( )方法，获取当前的 Session 对象。并且该 Session 对象不用手动关闭，线程结束了，会自动关闭。

			- HibernateUtil 工具类：
	
					package com.itheima.utils;
					
					import org.hibernate.Session;
					import org.hibernate.SessionFactory;
					import org.hibernate.cfg.Configuration;
					
					/**
					 * Hibernate框架的工具类
					 * @author Administrator
					 */
					public class HibernateUtils {
						
						// ctrl + shift + x
						private static final Configuration CONFIG;
						private static final SessionFactory FACTORY;
						
						// 编写静态代码块
						static{
							// 加载XML的配置文件
							CONFIG = new Configuration().configure();
							// 构造工厂
							FACTORY = CONFIG.buildSessionFactory();
						}
						
						/**
						 * 从工厂中获取Session对象
						 * @return
						 */
						public static Session getSession(){
							return FACTORY.openSession();
						}
						
						/**
						 * // 从ThreadLocal类中获取到session的对象
						 * @return
						 */
						public static Session getCurrentSession(){
							return FACTORY.getCurrentSession();
						}
						
					}

			- UserService 业务层：

					package com.itheima.service;
					
					import org.hibernate.Session;
					import org.hibernate.Transaction;
					
					import com.itheima.dao.UserDao;
					import com.itheima.domain.User;
					import com.itheima.utils.HibernateUtils;
					
					public class UserService {
						
						public void save(User u1,User u2){
							UserDao dao = new UserDao();
							// 获取session
							Session session = HibernateUtils.getCurrentSession();
							// 开启事务
							Transaction tr = session.beginTransaction();
							try {
								dao.save1(u1);
								int a = 10/0;
								dao.save2(u2);
								// 提交事务
								tr.commit();
							} catch (Exception e) {
								e.printStackTrace();
								// 出现问题：回滚事务
								tr.rollback();
							}finally{
								// 自己释放资源，现在，session不用关闭，线程结束了，自动关闭的！！
							}
						}
					}

			- UserDao 持久层：
					
					package com.itheima.dao;
					
					import org.hibernate.Session;
					
					import com.itheima.domain.User;
					import com.itheima.utils.HibernateUtils;
					
					public class UserDao {
						
						public void save1(User u1){
							Session session = HibernateUtils.getCurrentSession();
							session.save(u1);
							//不用写 session.close; 
						}
						
						public void save2(User u2){
							Session session = HibernateUtils.getCurrentSession();
							session.save(u2);
						}
					
					}

		* 注意：想使用 getCurrentSession() 方法，必须要先配置才能使用。

##5、Hibernate 的查询方式（HQL：Hibernate Query Language）
- ###Query 查询接口	
	- 具体的查询代码如下：

			// 1.查询所有记录
			/*Query query = session.createQuery("from Customer");
			List<Customer> list = query.list();
			System.out.println(list);*/
			
			// 2.条件查询（? 从0开始）
			/*Query query = session.createQuery("from Customer where name = ?");
			query.setString(0, "李健");
			List<Customer> list = query.list();
			System.out.println(list);*/
			
			// 3.条件查询（设置别名）
			/*Query query = session.createQuery("from Customer where name = :aaa and age = :bbb");
			query.setString("aaa", "李健");
			query.setInteger("bbb", 38);
			List<Customer> list = query.list();
			System.out.println(list);*/
	
			// 4.模糊查询（注意 % 要写在 setString 里面）
			/*Query query = session.createQuery("from User where name like ?");
			query.setString(0, "%老%");
			List<Customer> list = query.list();
			System.out.println(list);*/

		> 在 JDBC 中，记录从1开始！
		> 在 HQL 中，记录从0开始！

- ###Criteria 查询接口（做条件查询非常合适）

	- 完全面向对象，代码中基本不会体现 SQL 语言的特点	

	- Criterion 是 Hibernate 提供的条件查询的对象，如果想传入条件，可以使用工具类 Restrictions ，在其内部有许多静态方法可以用来描述条件

	- 具体的查询代码如下
	
			// 1.查询所有记录
			/*Criteria criteria = session.createCriteria(Customer.class);
			List<Customer> list = criteria.list();
			System.out.println(list);*/
			
			// 2.条件查询（查询 name 字段为李健的记录）
			/*Criteria criteria = session.createCriteria(Customer.class);
			criteria.add(Restrictions.eq("name", "李健"));
			List<Customer> list = criteria.list();
			System.out.println(list);*/
			
			// 3.条件查询（查询 name 字段为李健、age 字段为38的记录）
			/*Criteria criteria = session.createCriteria(Customer.class);
			criteria.add(Restrictions.eq("name", "李健"));
			criteria.add(Restrictions.eq("age", 38));
			List<Customer> list = criteria.list();
			System.out.println(list);*/
		
			// Restrictions 提供了许多静态方法来描述条件
			criteria.add(Restrictions.gt("age", 18)); // gt：大于
			criteria.add(Restrictions.like("name", "%小%")); // like：模糊查询
