> 本文包括：
> 
> 1、一对多结构的准备
> 
> 2、双向关联与单向关联
> 
> 3、级联保存
> 
> 4、级联删除
> 
> 5、cascade 属性——级联
> 
> 6、inverse 属性——放弃外键的维护
> 
> 7、多对多结构的准备
> 
> 8、多对多结构的级联

##1、一对多结构的准备
- 需求分析：假设客户和联系人是一对多的关系，所以要在有客户的情况下，要完成联系人的添加保存操作。

- 回想数据库相关的知识，在建表的时候要注意客户与联系人的关系，一个客户可以有多个联系人，而联系人必须依赖客户而存在，所以客户是“一”方，联系人是“多”方。相应地，在数据库中的“联系人”表中，应增加一个字段，并且设为“客户”表的外键。

	- 客户表：

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
			) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
	
	- 联系人表：

			CREATE TABLE `cst_linkman` (
			  `lkm_id` bigint(32) NOT NULL AUTO_INCREMENT COMMENT '联系人编号(主键)',
			  `lkm_name` varchar(16) DEFAULT NULL COMMENT '联系人姓名',
			  `lkm_cust_id` bigint(32) NOT NULL COMMENT '客户id',
			  `lkm_gender` char(1) DEFAULT NULL COMMENT '联系人性别',
			  `lkm_phone` varchar(16) DEFAULT NULL COMMENT '联系人办公电话',
			  `lkm_mobile` varchar(16) DEFAULT NULL COMMENT '联系人手机',
			  `lkm_email` varchar(64) DEFAULT NULL COMMENT '联系人邮箱',
			  `lkm_qq` varchar(16) DEFAULT NULL COMMENT '联系人qq',
			  `lkm_position` varchar(16) DEFAULT NULL COMMENT '联系人职位',
			  `lkm_memo` varchar(512) DEFAULT NULL COMMENT '联系人备注',
			  PRIMARY KEY (`lkm_id`),
			  KEY `FK_cst_linkman_lkm_cust_id` (`lkm_cust_id`),
			  CONSTRAINT `FK_cst_linkman_lkm_cust_id` FOREIGN KEY (`lkm_cust_id`) REFERENCES `cst_customer` (`cust_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
			) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;


- JavaBean 代码（省略 get 和 set 方法）：

	* 客户的 JavaBean 如下

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
				// 注意：在“一”方的 JavaBean 中要添加 set 集合！
				private Set<Linkman> linkmans = new HashSet<Linkman>();

			}
		
	* 联系人的 JavaBean 如下：

			public class Linkman {
				private Long lkm_id;
				private String lkm_name;
				private String lkm_gender;
				private String lkm_phone;
				private String lkm_mobile;
				private String lkm_email;
				private String lkm_qq;
				private String lkm_position;
				private String lkm_memo;
				// 注意：这里不写外键字段而写 Customer 对象，方便访问客户对象，而且是 Hibernate 要求的！
				private Customer customer; // 注意：千万不要 new！
				
			}

- 编写客户和联系人的映射配置文件（注意一对多的配置编写）

	* 客户的映射配置文件如下：

			<class name="com.itheima.domain.Customer" table="cst_customer">
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
				<!-- set标签name属性：表示集合的名称 -->			
				<set name="linkmans">
					<key column="lkm_cust_id"/>
					<one-to-many class="com.itheima.domain.Linkman"/>
				</set>
			</class>
		
	* 联系人的映射配置文件如下：

			<class name="com.itheima.domain.Linkman" table="cst_linkman">
				<id name="lkm_id" column="lkm_id">
					<generator class="native"/>
				</id>
				<property name="lkm_name" column="lkm_name"/>
				<property name="lkm_gender" column="lkm_gender"/>
				<property name="lkm_phone" column="lkm_phone"/>
				<property name="lkm_mobile" column="lkm_mobile"/>
				<property name="lkm_email" column="lkm_email"/>
				<property name="lkm_qq" column="lkm_qq"/>
				<property name="lkm_position" column="lkm_position"/>
				<property name="lkm_memo" column="lkm_memo"/>

				<!-- 先配置多方 
					name	当前JavaBean中的属性
					class	属性的全路径
					column	外键的字段
				-->
				<many-to-one name="customer" class="com.itheima.domain.Customer" column="lkm_cust_id"/>
			</class>

##2、双向关联与单向关联
- 双向关联：

	- 假设现在要保存一个客户，而且需要同时保存联系人字段，假设代码如下：

			Customer c1 = new Customer();
			c1.setCust_name("美美");
			
			Linkman l1 = new Linkman();
			l1.setLkm_name("熊大");
			Linkman l2 = new Linkman();
			l2.setLkm_name("熊二");
			
			// 演示双向关联
			c1.getLinkmans().add(l1);
			c1.getLinkmans().add(l2);
			
			l1.setCustomer(c1);
			l2.setCustomer(c1);
			
			session.save(l1);
			session.save(l2);
			session.save(c1);

	- 执行代码，程序正常运行，查询数据库，客户表新增一条记录，联系人表新增两条记录。

	- 注意：c1 一定要最后保存，否则会报错，因为瞬时态 c1 持有瞬时态 l1、l2，必须要 l1、l2 转变为持久态，c1 才能转变为持久态。

		> 关于持久化类的三种状态（瞬时态、持久态、托管态）及其之间的相互转化参考：[http://www.jianshu.com/p/1a6ca1993b16](http://www.jianshu.com/p/1a6ca1993b16 "http://www.jianshu.com/p/1a6ca1993b16")

	- 由此可见，双向关联是最浅显易懂的，但代码也最复杂。

- 单向关联：

	- 如果只想在客户表新增记录，而联系人表不变，这就叫单向关联。

			Customer c1 = new Customer();
			c1.setCust_name("美美");
			
			// 创建2个联系人
			Linkman l1 = new Linkman();
			l1.setLkm_name("熊大");
			Linkman l2 = new Linkman();
			l2.setLkm_name("熊二");
			
			// 单向关联
			c1.getLinkmans().add(l1);
			c1.getLinkmans().add(l2);
			
			// 保存数据
			session.save(c1);

	- 如果不配置级联保存（见下节），则程序出现异常，异常第一行如下：

			org.hibernate.TransientObjectException: 
				object references an unsaved transient instance - 
					save the transient instance before flushing: 
						com.itheima.domain.Linkman
			
	- 简单分析：在调用 save 方法时，c1 要由瞬时态转变为持久态，而 l1、l2仍然是瞬时态，而 c1 持有 l1、l2，所以程序出错。
		
##3、级联保存
- 级联保存
	1. 测试：如果现在代码只插入其中的一方的数据（单向关联）

		* 如果只保存其中的一方的数据，那么程序会抛出异常。

		* 如果想完成只保存一方的数据，并且把相关联的数据都保存到数据库中，那么需要配置级联！！
		
		* 级联保存是方向性
	
	2. 级联保存效果

		* 级联保存：保存一方同时可以把关联的对象也保存到数据库中！！

		* 使用 `cascade="save-update"`

	3. 客户级联联系人

		- 如果想在保存客户时，同时也保存联系人，在客户的配置文件中这样编写：
		
				<set name="linkmans" cascade="save-update">
					<!-- 需要出现子标签 -->
					<!-- 外键的字段 -->
					<key column="lkm_cust_id"/>
					<one-to-many class="com.itheima.domain.Linkman"/>
				</set>

		- 再执行如下代码，正常运行，客户表新增一条记录，联系人表新增两条记录。

				Customer c1 = new Customer();
				c1.setCust_name("美美");
				
				// 创建2个联系人
				Linkman l1 = new Linkman();
				l1.setLkm_name("熊大");
				Linkman l2 = new Linkman();
				l2.setLkm_name("熊二");
				
				// 单向关联
				c1.getLinkmans().add(l1);
				c1.getLinkmans().add(l2);
				
				// 保存数据
				session.save(c1);

	- 联系人级联客户

		- 同样地，如果想在保存联系人时，同时也保存客户，在联系人的配置文件中这样编写：

				<!-- 先配置多方 
							name	当前JavaBean中的属性
							class	属性的全路径
							column	外键的字段
						-->
				<many-to-one name="customer" class="com.itheima.domain.Customer" column="lkm_cust_id" cascade="save-update"/>

		- 再执行如下代码，正常运行，客户表新增一条记录，联系人表新增两条记录。

				Customer c1 = new Customer();
				c1.setCust_name("美美");
				
				// 创建2个联系人
				Linkman l1 = new Linkman();
				l1.setLkm_name("熊大");
				Linkman l2 = new Linkman();
				l2.setLkm_name("熊二");
				
				// 使用联系人关联客户
				l1.setCustomer(c1);
				l2.setCustomer(c1);
				
				// 保存
				session.save(l1);
				session.save(l2);

	- 客户与联系人互相级联保存 

		- 如果在两个配置文件中都配置 ` cascade="save-update"` ，那么两者互相级联。

		- 测试如下代码，发现程序正常运行，客户表新增一条记录，联系人表新增两条记录。

				Customer c1 = new Customer();
				c1.setCust_name("美美");
				
				// 创建2个联系人
				Linkman l1 = new Linkman();
				l1.setLkm_name("熊大");
				Linkman l2 = new Linkman();
				l2.setLkm_name("熊二");
				
				l1.setCustomer(c1);
				c1.getLinkmans().add(l2);
				session.save(l1);

##4、级联删除
- 级联删除
	1. 假设现在要删除某个客户，在含有外键约束的情况下，是不会成功的。
		
			delete from customers where cid = 1;
			
		error:

			[Err] 1451 - Cannot delete or update a parent row: a foreign key constraint fails (`hibernate_day03`.`cst_linkman`, CONSTRAINT `FK_cst_linkman_lkm_cust_id` FOREIGN KEY (`lkm_cust_id`) REFERENCES `cst_customer` (`cust_id`) ON DELETE NO ACTION ON UPDATE NO ACTION)

	2. 如果使用 Hibernate 直接删除客户的时候，测试发现是可以删除的，这是为什么呢？我们直接看控制台的输出：
	
			Hibernate: 
			    select
			        customer0_.cust_id as cust_id1_0_0_,
			        customer0_.cust_name as cust_nam2_0_0_,
			        customer0_.cust_user_id as cust_use3_0_0_,
			        customer0_.cust_create_id as cust_cre4_0_0_,
			        customer0_.cust_source as cust_sou5_0_0_,
			        customer0_.cust_industry as cust_ind6_0_0_,
			        customer0_.cust_level as cust_lev7_0_0_,
			        customer0_.cust_linkman as cust_lin8_0_0_,
			        customer0_.cust_phone as cust_pho9_0_0_,
			        customer0_.cust_mobile as cust_mo10_0_0_ 
			    from
			        cst_customer customer0_ 
			    where
			        customer0_.cust_id=?
			Hibernate: 
			    update
			        cst_linkman 
			    set
			        lkm_cust_id=null 
			    where
			        lkm_cust_id=?
			Hibernate: 
			    delete 
			    from
			        cst_customer 
			    where
			        cust_id=?
			
		注意：Hibernate 自动执行了3条 SQL 语句，其中第2条尤其值得一看，它把联系人表中与该客户有关的外键的值设为 null，也就是说：这个客户没有联系人了，自然也就可以删除了。
	
	3. 上述的删除是普通的删除，那么也可以使用级联删除，级联删除有个好处：当我们把这个客户删除了，那这个客户的联系人自然也就没什么意义了。

	4. **注意：级联删除也是有方向性的！！**

		* 假设在删除客户时，要删除该客户所对应的联系人，则应该在客户的配置文件中这样配置：

				<set name="linkmans" cascade="save-update,delete">
					<!-- 需要出现子标签 -->
					<!-- 外键的字段 -->
					<key column="lkm_cust_id"/>
					<one-to-many class="com.itheima.domain.Linkman"/>
				</set>

		- 相反地，若要在删除联系人时，同时删除对应的客户，则在联系人的配置文件中这样配置：

				<many-to-one name="customer" class="com.itheima.domain.Customer" column="lkm_cust_id" cascade="save-update,delete"/>

		- 也可以像级联保存那样，互相级联，那样就可以实现：删除一个联系人 - 删除对应的客户 - 删除该客户所对应的所有联系人

		- **注意：级联删除要慎重！在实际情况中，很多时候是假删除，即添加一个字段，用该字段来表示这条记录是否删除了，多用 update ，而不会真正的 delete ！**

##5、cascade 属性——级联
- 之前的级联保存、级联删除，都是在配置文件中配置这样一个属性 `cascade`，接下来探讨一下这个属性的取值。

- 级联的取值
	- 需要掌握的取值如下：
		* none						-- 不使用级联
		* save-update				-- 级联保存或更新
		* delete					-- 级联删除
		* delete-orphan				-- 孤儿删除.(注意：只能应用在一对多关系)
		* all						-- 除了delete-orphan的所有情况.（包含save-update,delete）
		* all-delete-orphan			-- 包含了delete-orphan的所有情况.（包含save-update,delete,delete-orphan）

- 孤儿删除

	- 孤儿删除（孤子删除），只有在一对多的环境下才有孤儿删除
		* 在一对多的关系中,可以将“一”的一方认为是父方，将“多”的一方认为是子方。孤儿删除：当解除了父子关系的时候，将子方记录就直接删除。

		- 若想在解除关系时，把联系人的记录从数据库删除，则应该在客户的配置文件中中这样编写：

				<!-- 配置一方 -->
				<!--
					set标签name属性：表示集合的名称
				-->
				<set name="linkmans" cascade="delete-orphan">
					<!-- 需要出现子标签 -->
					<!-- 外键的字段 -->
					<key column="lkm_cust_id"/>
					<one-to-many class="com.itheima.domain.Linkman"/>
				</set>

		- 解除父子关系的代码：

				// 先获取到客户
				Customer c1 = session.get(Customer.class, 1L);
				Linkman l1 = session.get(Linkman.class, 1L);
				// 解除
				c1.getLinkmans().remove(l1);

		- 最后查询数据库，发现联系人表中 id 为1的记录被删除了。

##6、inverse 属性——放弃外键的维护
1. 在之前的例子中，默认双方都维护外键，会产生多余的SQL语句。

	* 现象：想修改客户和联系人的关系，进行双向关联，双方都会维护外键，会产生多余的SQL语句。
		
	* 原因：session 的一级缓存中的快照机制，会让双方都更新数据库，产生了多余的 SQL 语句。
	
2. 如果不想产生多余的SQL语句，那么需要一方来放弃外键的维护，通常是“一”方来放弃外键的维护，于是在“一”方的配置文件中这样编写：
	
	* 在<set>标签上配置一个 `inverse="true"` ：true:放弃；false:不放弃；默认值是 false

			<inverse="true">

	> **注意：在一对多的情况下，可以不放弃外键的维护，但是下节开始的多对多表结构必须有一方放弃外键的维护。**

4. cascade 和 inverse 的区别

	- cascade 用来级联操作（保存、修改和删除）
	
	- inverse 用来维护外键
		
		> 举例：若 Customer 同时配置 `cascade="save-update"`、`<inverse="true">`，当保存一个 Customer 对象时，数据库也会同时保存 Linkman 对象（级联保存的功劳），但是该 Linkman 对象的外键是空的。
	
	> **注意：在实际情况中，大部分情况是：“一”方配置 `<inverse="true">` ，“多”方配置 `cascade="save-update"`**。

##7、多对多结构的准备
- 需求分析：用户与角色是多对多的关系，一个用户可能有多种角色，而某种角色可能被多个用户共享。

- 数据库知识回顾：在之前的 Java web 学习中，对于多对多的情况，要创建一个中间表，这个中间表通过外键联系了两张表，而在 Hibernate 中，不需要手动创建中间表，只需要按照 Hibernate 的规范编写 JavaBean 和其对应的配置文件即可。

	![](http://upload-images.jianshu.io/upload_images/2106579-1e0718441456554b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- JavaBean 代码（省略 set 和 get 方法）：

	- 用户：

			public class User {
				
				private Long uid;
				private String username;
				private String password;
				
				// 编写都是集合
				private Set<Role> roles = new HashSet<Role>();
			
			}

	- 角色：

			public class Role {
				
				private Long rid;
				private String rname;
				
				private Set<User> users = new HashSet<User>();
			
			｝

- 用户与角色的配置文件编写：

	* 用户的映射配置文件如下

			<class name="com.itheima.domain.User" table="sys_user">
				<id name="user_id" column="user_id">
					<generator class="native"/>
				</id>
				<property name="user_code" column="user_code"/>
				<property name="user_name" column="user_name"/>
				<property name="user_password" column="user_password"/>
				<property name="user_state" column="user_state"/>
				
				<set name="roles" table="sys_user_role">
					<key column="user_id"/>
					<many-to-many class="com.itheima.domain.Role" column="role_id"/>
				</set>
			</class>
		
		> 中间表的名字就叫做 sys_user_role

	* 角色的映射配置文件如下

			<class name="com.itheima.domain.Role" table="sys_role">
				<id name="role_id" column="role_id">
					<generator class="native"/>
				</id>
				<property name="role_name" column="role_name"/>
				<property name="role_memo" column="role_memo"/>
				
				<set name="users" table="sys_user_role">
					<key column="rid"/>
					<many-to-many class="com.itheima.domain.User" column="uid"/>
				</set>
			</class>
	
		> 中间表的名字就叫做 sys_user_role

	- **多对多进行双向关联的时候：必须有一方去放弃外键维护权，如果不放弃中间表会被更新两次，不允许！**

		故，可选择角色的映射配置文件，改为：

			<!-- 多对多必须要有一方放弃外键的维护的 -->
			<set name="users" table="sys_user_role" inverse="true">
				<key column="rid"/>
				<many-to-many class="com.itheima.domain.User" column="uid"/>
			</set>

##8、多对多结构的级联
- 关于级联的各种取值、概念在前文已有，在此不再赘述。

- 级联保存：save-update ，大部分情况下都是这个取值。

	以下是一个示例，角色放弃外键的维护，用户级联角色：

		// 模拟多对多，双向的关联
		User u1 = new User();
		u1.setUsername("张三");
		User u2 = new User();
		u2.setUsername("赵四");
		
		// 创建角色
		Role r1 = new Role();
		r1.setRname("经理");
		Role r2 = new Role();
		r2.setRname("演员");
		
		u1.getRoles().add(r1);
		u1.getRoles().add(r2);
		u2.getRoles().add(r1);
		
		// 保存数据
		session.save(u1);
		session.save(u2);

- 级联删除：在多对多情况下，极少使用。
