> 本文包括：
> 
> 1、OGNL 表达式概述（了解）
> 
> 2、值栈概述
> 
> 3、值栈的存值与取值
> 
> 4、EL 表达式也会获取到值栈中的数据
> 
> 5、总结 OGNL 表达式的特殊的符号

![](http://upload-images.jianshu.io/upload_images/2106579-0db67ea3979fc38c.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##1、OGNL 表达式概述（了解）
	
1. OGNL 是 Object Graphic Navigation Language（对象图导航语言）的缩写
	
	* 所谓对象图，即以任意一个对象为根，通过 OGNL 可以访问与这个对象关联的其它对象
	
	* 通过它简单一致的表达式语法，可以存取对象的任意属性，调用对象的方法，遍历整个对象的结构图，实现字段类型转化等功能。它使用相同的表达式去存取对象的属性
	
2. Struts2 框架使用 OGNL 作为默认的表达式语言
	
	* OGNL 是一种比 EL 强大很多倍的语言
	
	* xwork 提供 OGNL表达式
	
	* ognl-3.0.5.jar
	
3. OGNL 提供五大类功能
	
   * 支持对象方法调用
	
   * 支持类静态的方法调用和值访问
	
   * 访问 OGNL 上下文（OGNL context）和 ActionContext
	
   * 支持赋值操作和表达式串联
	
   * 操作集合对象
	
4. 测试的代码

		// 访问对象的方法
		@Test
		public void run1() throws OgnlException{
			OgnlContext context = new OgnlContext();
			// 获取对象的方法
			Object obj = Ognl.getValue("'helloworld'.length()", context, context.getRoot());
			System.out.println(obj);
		}
		
		// 获取 OGNL 上下文件的对象
		@Test
		public void run3() throws OgnlException{
			OgnlContext context = new OgnlContext();
			context.put("name", "美美");
			Object obj = Ognl.getValue("#name", context, context.getRoot());
			System.out.println(obj);
		}
		
		// 从 root 栈获取值
		@Test
		public void demo3() throws OgnlException{
			OgnlContext context = new OgnlContext();
			Customer c = new Customer();
			c.setCust_name("haha");
			context.setRoot(c);
			String name = (String) Ognl.getValue("cust_name", context, context.getRoot());
			System.out.println(name);
		}
	
###JSP 页面中使用 OGNL 表达式	

1. Struts2 引入了 OGNL 表达式，主要是在 JSP 页面中获取值栈中的值

2. 具体在 Struts2 中怎么使用呢？如下步骤：
	
	* 需要先引入 Struts2 的标签库
	
			<%@ taglib prefix="s" uri="/struts-tags" %>
		
	* 使用 Struts2 提供的标签中的标签，如下的 property 标签会从值栈中取值
	
			<s:property value="OGNL表达式"/>
	
3. 在 JSP 页面使用 OGNL 表达式
	
	* 访问对象方法
	
			<s:property value="'hello'.length()"/>

		网页会输出5，因为 'hello' 的长度为5

##2、值栈概述
- 什么是值栈？

	* 值栈就相当于 Struts2 框架的数据的中转站，可以向值栈存入一些数据，也可以从值栈中获取到数据。
		
	* ValueStack 是 struts2 提供一个接口，它有个实现类 OgnlValueStack ---- 值栈对象 （OGNL 是从值栈中获取数据的）
			
	* Action 是多例的，有一个请求，就会创建 Action 实例，然后创建一个 ActionContext 对象，代表的是 Action 的上下文对象，同时还会创建一个 ValueStack 对象。 每个 Action 实例都有一个 ValueStack 对象 （一个请求对应一个 ValueStack 对象 ），在其中保存当前 Action 对象和其他相关对象
			
	* Struts2 框架把 ValueStack 对象保存在名为 “struts.valueStack” 的请求属性中，request 中（值栈对象是 request 的一个属性）
				
			ValueStack vs = (ValueStack)request.getAttribute("struts.valueStack");
	
- 值栈的内部结构 ？

    * 值栈由两部分组成
			
		root		-- Struts2 把动作和相关对象压入 ObjectStack 中--List
			
		context  	-- Struts2 把各种各样的映射关系(一些 Map 类型的对象) 压入 ContextMap 中
		
	* Struts2 会默认把下面这些映射压入 Context（即压入 Map）中
	
		* 注意：request 代表的是 Map 集合的 key 值（实质就是一个字符串），value 的值其实也是一个 Map 集合。
			
			parameters: 该 Map 中包含当前请求的请求参数  ?name=xxx&password=123

			request: 该 Map 中包含当前 request 对象中的所有属性

			session: 该 Map 中包含当前 session 对象中的所有属性

			application:该 Map 中包含当前 application  对象中的所有属性

			attr: 该 Map 按如下顺序来检索某个属性: request, session, application
		
	* ValueStack 中存在 root 属性 (实质是 CompoundRoot 类型) 、 context 属性 （实质是 OgnlContext 类型）

		- CompoundRoot 就是 ArrayList（因为继承 ArrayList）

		- OgnlContext 就是 Map（因为继承 Map）
		
	* context 对应 Map 引入 root 对象 

		context 中还存在 request、session、application、attr、parameters 对象引用 

		- OGNL 表达式访问值栈中的数据

			* 访问 root 中数据时不需要 #

			* 访问 request、session、application、attr、parameters 对象数据时必须写 # 
			
		- 操作值栈默认操作 root 元素

	![](http://upload-images.jianshu.io/upload_images/2106579-83ba49d6760abff2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 值栈的创建和 ActionContext 对象的关系（从源代码分析）
	
	* 值栈对象是请求时创建的
	
	* ActionContext 是绑定到当前的线程上，那么在每个拦截器或者 Action 中获取到的 ActionContext 是同一个（ThreadLocal ，线程安全）
	
	* ActionContext 中存在一个 Map 集合，该 Map 集合和 ValueStack 的 context 是同一个地址。
	
	* ActionContext 中可以获取到 ValueStack 的引用，所以以后不用 request 来得到 ValueStack 对象，都使用 ActionContext 来获取到值栈对象

			ValueStack vs = ActionContext.getContext().getValueStack();

##3、值栈的存值与取值
- 向值栈保存数据 （主要针对 root 栈）

	* push 方法：底层调用 root 对象的 push 方法（把元素添加到 0 位置）

			valueStack.push(Object obj);
		
		root 对象继承 ArrayList，再往底层研究，发现其实调用了 ArrayList 的 add 方法，且把元素添加到了0的位置，0就是栈顶。
	
	* set 方法：底层获取一个 map 集合（该 map 有可能是已经存在的，有可能是新创建的），把 map 集合 push 到栈顶，再把数据存入到该 map 集合中。

			valueStack.set(String key, Object obj);

		> 在jsp中 通过 <s:debug /> 查看值栈的内容

- 从值栈中获取值
	
	- 在 JSP 中获取值栈的数据
	
		* 总结几个小问题：

		    1. 访问 root 中数据 不需要#
		     
		    2. 访问 context 其它对象数据 加 #
		    
		    3. 如果向 root 中存入对象的话，优先使用 push 方法。
		    
		    4. 如果向 root 中存入集合的话，优先要使用 set 方法。
		
		* 在 Context 中获取数据（context 栈）

			1. 在Action中向域对象中存入值

			2. request:

					<s:property value="#request.username"/>

			3. session:
			
					<s:property value="#session.username"/>

			4. application:
			
					<s:property value="#application.username"/>

			5. attr:
			
					<s:property value="#attr.username"/>

			6. parameters:
			
					<s:property value="#parameters.cid"/>
	
	- 存取示例代码如下（root 栈）

		- demo1：

				vs.push("美美");

				<s:property value="[0].top"/>
		
		- demo2：

				// 栈顶是map集合，通过key获取值
				vs.set("msg", "小凤");

				<s:property value="[0].top.msg"/>
		
		- demo3：

				// 栈顶放user对象
				vs.push(user);

				<s:property value="[0].top.username"/>
				<s:property value="[0].top.password"/>
				// [0].top 关键字是可以省略的，如下也是可行的
				<s:property value="username"/>
		
		- demo4:

				vs.set("user", user);
				<s:property value="[0].top.user.username"/>
				<s:property value="[0].top.user.password"/>
				// 省略关键字
				<s:property value="user.username"/>
		
		- demo5：

				// 若在ValueStack1Action中提供了成员的属性，Action进栈，则“小泽”也会入栈
					private User user = new User("小泽","456");
					public User getUser() {
						return user;
					}
					public void setUser(User user) {
						this.user = user;
					}
				
				// 在excute方法中再压入“小苍”
					User user = new User("小苍","123");
					vs.set("user", user);

				// 从栈顶开始查找，找user的属性username属性，因为省略了序号，所以默认是[0].top，又小苍后压入，应该返回小苍
				<s:property value="user.username"/>
				
				// [1].top获取ValueStack1Action 
				// [1].top.user返回user对象  即“小泽”对象
				// [1].top.user.username获取对象的属性名称，即小泽
				<s:property value="[1].top.user.username"/>
		
		- demo6：
	
				//栈顶是list集合
				vs.push(ulist);
				<s:property value="[0].top[0].username"/>
				<s:property value="[0].top[1].username"/>
		
		- demo7：

				vs.set("ulist", ulist);
				<s:property value="ulist[0].username"/>
		
		- demo8：

				属性
				* value	要迭代的集合，需要从值栈中获取
				* var	迭代过程中，遍历的对象
					* var有，把迭代产生的对象默认压入到context栈中，从context栈取值，加#号
					* var无，默认把迭代产生的对象压入到root栈中
			
				// 编写var的属性
				<s:iterator value="ulist" var="u">
					<s:property value="#u.username"/>
					<s:property value="#u.password"/>
				</s:iterator>
			
				// 没有编写var关键字
				<s:iterator value="ulist">
					<s:property value="username"/>
					<s:property value="password"/>
				</s:iterator>
		
		- demo9：

				//从context栈中获取值，加#号
				HttpServletRequest request = ServletActionContext.getRequest();
				request.setAttribute("msg", "美美");
				request.getSession().setAttribute("msg", "小风");
				
				<s:property value="#request.msg"/>
				<s:property value="#session.msg"/>
				<s:property value="#parameters.id"/>
				<s:property value="#attr.msg"/>
		
		- demo10：

				<!-- 在JSP页面上，查看值栈的内部结构 -->
				<s:debug></s:debug>
			
##4、EL表达式也会获取到值栈中的数据
- 为什么EL也能访问值栈中的数据？

	* StrutsPreparedAndExecuteFilter 的 doFilter() 方法代码中 
	
			request = prepare.wrapRequest(request); 	

		对 Request 对象进行了包装 ，StrutsRequestWrapper
		增强了request的 getAttribute() 方法：

			Object attribute = super.getAttribute(s);
			if (attribute == null) {
			   attribute = stack.findValue(s);
			}

		访问 request 范围的数据时，如果数据找不到，去值栈中找 
		 request 对象，所以具备访问值栈数据的能力（查找 root 的数据）。

##5、总结 OGNL 表达式的特殊的符号
1. `#` 符号的用法
	* 获得 contextMap 中的数据

			<s:property value="#request.name"/>
			<s:property value="#session.name"/>
			<s:property value="#application.name"/>
			<s:property value="#attr.name"/>
			<s:property value="#parameters.id"/>
			<s:property value="#parameters.name"/>
		
	* 构建一个map集合

		- 普通表单

				<form action="" method="post">
					性别：<input type="radio" name="sex" value="1"/>男<input type="radio" name="sex" value="2"/>女
				</form>

		- 使用 OGNL 标签

				<s:form action="" method="post">
					性别：<s:radio name="sex" list="{'男','女'}"/>
				</s:form>
			
			注意：这样的写法，若选择男，则 sex='男'

			若像下面这种写法，若选择男，则 sex='0'

				<s:radio name="sex" list="#{'0':'男','1':'女'}"></s:radio>
	
2. `%` 符号的用法
	
	* 强制字符串解析成 OGNL 表达式。
	
		例如：在 request 域中存入值，然后在文本框（`<s:textfield>`）中取值，现在到value上。
	
			<s:textfield value="%{#request.msg}"/>
		
	* { } 中值用`''`引起来，此时不再是 ognl 表达式，而是普通的字符串。
	
		例如：
			
			<s:property value="%{'#request.msg'}"/>
	
3. `$` 符号的用法
	
	* 在配置文件（struts.xml）中可以使用 OGNL 表达式，例如：文件下载的配置文件。

			<action name="download1" class="cn.itcast.demo2.DownloadAction">
				<result name="success" type="stream">
					<param name="contentType">${contentType}</param>
					<param name="contentDisposition">attachment;filename=${downFilename}</param>
				</result>
			</action>

> PS：学习值栈的时候感觉有点蒙，内部结构有点复杂，不太理解为什么在 Struts2 里面会有值栈这个东西存在，先学着怎么用吧 :)
