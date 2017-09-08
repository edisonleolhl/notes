> 本文包括：
> 
> 1、如何在 Struts2 中使用 Servlet 的相关 API？
> 
> 2、分析 <result> 结果页面
> 
> 3、Struts2 的数据封装
> 
> 4、Struts2 拦截器（重难点）
> 
> 5、如何自定义一个 Struts2 拦截器？

![](http://upload-images.jianshu.io/upload_images/2106579-8e9acd6420c3da21.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##1、如何在 Struts2 中使用 Servlet 的相关 API？
1. 在 Action 类中也可以获取到 Servlet 一些常用的API
	
	* 需求：提供 JSP 的表单页面的数据，在 Action 中使用 Servlet 的 API 接收到，然后保存到三个域对象中，最后再显示到 JSP 的页面上。
	
		* 提供 JSP 注册的页面，演示下面这三种方式

				<h3>注册页面</h3>
				<form action="${ pageContext.request.contextPath }/xxx.action" method="post">
					姓名:<input type="text" name="username" /><br/>
					密码:<input type="password" name="password" /><br/>
					<input type="submit" value="注册" />
				</form>
	
2. 完全解耦合的方式（不推荐）
	
	* 如果使用该种方式，Struts2 框架中提供了一个类，ActionContext 类，该类中提供一些方法，通过方法获取 Servlet 的 API
	
	* 一些常用的方法如下
	
		* static ActionContext getContext()  										-- 获取 ActionContext 对象实例
	
		* java.util.Map<java.lang.String,java.lang.Object> getParameters()  		-- 获取请求参数，相当于 request.getParameterMap();
	
		* java.util.Map<java.lang.String,java.lang.Object> getSession()  			-- 获取的代表 session 域的 Map 集合，就相当于操作 session 域。
	
		* java.util.Map<java.lang.String,java.lang.Object> getApplication() 		-- 获取代表 application 域的Map集合
	
		* void put(java.lang.String key, java.lang.Object value)  					-- 注意：向 request 域中存入值。
    
	- demo:

			public class Demo1Action extends ActionSupport{
			
				private static final long serialVersionUID = -7255855724015241518L;
				
				public String execute() throws Exception {
					// 完全解耦合的方式
					ActionContext context = ActionContext.getContext();
					// 获取到请求的参数，封装所有请求的参数
					Map<String, Object> map = context.getParameters();
					// 遍历获取数据
					Set<String> keys = map.keySet();
					for (String key : keys) {
						// 通过key，来获取到值
						String [] vals = (String[]) map.get(key);
						System.out.println(key+" : "+Arrays.toString(vals));
					}
					
					// 如果向request对象中存入值
					context.put("msg", "小东东");
					// 获取其他map集合
					context.getSession().put("msg", "小苍");
					context.getApplication().put("msg", "小泽");
					
					return SUCCESS;
				}
			
			}

	- struts.xml 很简单，在这里就不给出了，然后在跳转页面 suc.jsp 中这样编写代码，最后浏览器页面依次显示：小苍 小东东 小泽

			<body>
			
			<h3>使用EL表达式获取值</h3>
			
			${ sessionScope.msg }
			${ requestScope.msg }
			${ applicationScope.msg }
			
			</body>

3. **使用原生 Servlet 的 API 的方式（推荐）**
	
	* Struts2 框架提供了一个类，ServletActionContext，该类中提供了一些静态的方法
	
	* 具体的方法如下
	
		* getPageContext()
	
		* getRequest()
	
		* getResponse()
	
		* getServletContext()

	- demo：
			
			public class Demo2Action extends ActionSupport{
				
				private static final long serialVersionUID = -864657857993072618L;
				
				public String execute() throws Exception {
					// 获取到request对象
					HttpServletRequest request = ServletActionContext.getRequest();
					request.setAttribute("msg", "小东东");
					request.getSession().setAttribute("msg", "美美");
					ServletActionContext.getServletContext().setAttribute("msg", "小凤");
					return SUCCESS;
				}
			}

	- 跳转页面和上面的一样，这次浏览器显示：美美 小东东 小凤

	- 还可以用输出流打印信息，在 return 前加入
					
			HttpServletResponse response = ServletActionContext.getResponse();
			...					

##2、分析 `<result>` 结果页面
1. 结果页面存在两种形式
	
	* 全局结果页面
	
		- 条件：如果 `<package>` 包中的一些 action 都返回 success，并且返回的页面都是同一个 JSP 页面，这样就可以配置全局的结果页面。
	
		- 全局结果页面针对的当前的包中的所有的 Action，但是如果局部还有结果页面，会优先跳转到局部的。

		- 全局结果页面配置代码如下，与 `<action>` 标签平行

				<global-results>
					<result>/demo3/suc.jsp</result>
				</global-results>
		
	* 局部结果页面

			<result>/demo3/suc.jsp</result>
	
	- demo：

			<package name="demo1" extends="struts-default" namespace="/">
					
				<!-- 配置全局的结果页面 -->
				<global-results>
					<result name="success" type="redirect">/demo1/suc.jsp</result>
				</global-results>
					
				<action name="demo1Action" class="com.itheima.demo1.Demo1Action">
					<result name="success">/demo1/suc.jsp</result>
				</action>
			</package>
		
2. 结果页面的类型
	
	* 结果页面使用 `<result>` 标签进行配置，包含两个属性
	
		- name	-- 逻辑视图的名称
	
		- type	-- 跳转的类型，需要掌握一些常用的类型。常见的结果类型在 struts-default.xml 中查找。
	
			* dispatcher		-- 转发，type 的默认值，Action--->JSP
	
			* redirect			-- 重定向，	Action--->JSP
	
			* chain				-- 多个 action 之间跳转.从一个 Action 转发到另一个Action.	Action---Action
	
			* redirectAction	-- 多个 action 之间跳转.从一个 Action 重定向到另一个 Action.	Action---Action
				
					<!-- 演示重定向到 Action -->
					<action name="demo3Action_*" class="com.itheima.demo1.Demo3Action" method="{1}">
						<result name="success" type="redirectAction">demo3Action_update</result>
					</action>
	
				上面的配置代码演示了如何编写 redirectAction 类型的结果页面，效果是：当访问 demo3Action 的任何方法时，若成功，则会再执行 update 方法，这个很常用。

			* stream			-- 文件下载时候使用的

##3、Struts2 的数据封装
1. 为什么要使用数据的封装呢？
	
	* 作为 MVC 框架，必须要负责解析 HTTP 请求参数，并将其封装到 Model 对象中
	
	* 封装数据为开发提供了很多方便
	
	* Struts2 框架提供了很强大的数据封装的功能，不再需要使用 Servlet 的 API 完成手动封装了！！
	
2. Struts2 中提供了两类数据封装的方式
	
	* 第一种方式：属性驱动（不推荐）
	
		- Action 类提供对应属性的 set 方法进行数据的封装。
	
			* 表单的哪些属性需要封装数据，那么在对应的 Action 类中提供该属性的 set 方法即可。
	
			* 表单中的数据提交，最终找到 Action 类中的 setXxx 的方法，最后赋值给全局变量。
	
			- demo：

					public class Regist1Action extends ActionSupport{
						
						private static final long serialVersionUID = -966487869258031548L;
						
						private String username;
						private String password;
						private Integer age;
						public void setUsername(String username) {
							this.username = username;
						}
						public void setPassword(String password) {
							this.password = password;
						}
						public void setAge(Integer age) {
							this.age = age;
						}
						
						public String execute() throws Exception {
							System.out.println(username+" "+password+" "+age);
							return NONE;
						}
					
					}

			> 注意：
			> 
			> * Struts2 采用的拦截器完成数据的封装。
			> 	
			> * 这种方式不是特别好：因为属性特别多，提供特别多的 set 方法，而且还需要手动将数据存入到对象中。
			> 	
			> * 这种情况下，Action 类就相当于一个 JavaBean，就没有体现出 MVC 的思想，Action 类又封装数据，又接收请求处理，耦合性较高。
			
		- 上面的代码不太合理，应该把那些属性封装到 JavaBean 中，所以首先创建 JavaBean ，如下：

				public class User {
					
					private String username;
					private String password;
					private Integer age;
					...//省略 get 和 set 方法
				}
		
			我们再创建 Regist2Action.java，代码如下:

					public class Regist2Action extends ActionSupport{
						
						private static final long serialVersionUID = 6556880331550390473L;
						
						// 注意二：属性驱动的方式，现在，要提供是get和set方法
						private User user;
						public User getUser() {
							System.out.println("getUser...");
							return user;
						}
						public void setUser(User user) {
							System.out.println("setUser...");
							this.user = user;
						}
						
						public String execute() throws Exception {
							System.out.println(user);
							return NONE;
						}
					
					}

		- 在 jsp 页面上，使用 OGNL 表达式进行数据封装。
	
			* 在页面中使用 OGNL 表达式进行数据的封装，就可以直接把属性封装到某一个 JavaBean 的对象中。
	
			* 页面中的编写发生了变化，需要使用 OGNL 的方式，jsp 如下：
			
					<h3>属性驱动的方式（把数据封装到JavaBean的对象中）</h3>
					<!-- 注意一：页面的编写规则，发生了变化，使用的OGNL表达式的写法 -->
					<form action="${ pageContext.request.contextPath }/regist2.action" method="post">
						姓名:<input type="text" name="user.username" /><br/>
						密码:<input type="password" name="user.password" /><br/>
						年龄:<input type="password" name="user.age" /><br/>
						<input type="submit" value="注册" />
					</form>
	
			* 注意：只提供一个 set 方法还不够，必须还需要提供 user 属性的 get 和 set 方法！！！
	
				> 原理过程：先调用 get 方法，判断一下是否有 user 对象的实例对象，如果没有，调用 set 方法把拦截器创建的对象注入进来，
		
	* **第二种方式：模型驱动（推荐）**
	
		- 使用模型驱动的方式，也可以把表单中的数据直接封装到一个 JavaBean 的对象中，并且 jsp 页面中表单的写法和之前的写法没有区别！
			
		- 模型驱动的编写步骤：
	
			* 手动实例化 JavaBean，即：
			
					private User user = new User();
	
			* 必须实现 `ModelDriven<T>` 接口，实现 `getModel()` 的方法，在 `getModel()` 方法中返回 user 即可！！

			- demo：

					/**
					 * 模型驱动的方式
					 * 	实现ModelDriven接口
					 *  必须要手动实例化对象（需要自己new好）
					 * @author Administrator
					 */
					public class Regist3Action extends ActionSupport implements ModelDriven<User>{
						
						private static final long serialVersionUID = 6556880331550390473L;
						
						// 必须要手动实例化
						private User user = new User();
						// 获取模型对象
						public User getModel() {
							return user;
						}
						
						public String execute() throws Exception {
							System.out.println(user);
							return NONE;
						}
					
					}

3. 数据封装到集合中
	
	1. 封装复杂类型的参数（集合类型 Collection 、Map接口等）

	2. 需求：页面中有可能想批量添加一些数据，那么现在就可以使用这种方法，把数据封装到集合中。

	3. 把数据封装到 Collection 中
	
		* 因为 Collection 接口都会有下标值，所有页面的写法会有一些区别，注意：

				<input type="text" name="products[0].name" />

		* 在 Action 中的写法，需要提供 products 的集合，并且提供 get 和 set 方法。
	
		- 以 list 为例：

			jsp：

				<h3>向List集合封装数据（默认情况下，采用是属性驱动的方式）</h3>
				<!-- 后台：List<User> list -->
				<form action="${ pageContext.request.contextPath }/regist4.action" method="post">
					姓名:<input type="text" name="list[0].username" /><br/>
					密码:<input type="password" name="list[0].password" /><br/>
					年龄:<input type="password" name="list[0].age" /><br/>
					
					姓名:<input type="text" name="list[1].username" /><br/>
					密码:<input type="password" name="list[1].password" /><br/>
					年龄:<input type="password" name="list[1].age" /><br/>
					<input type="submit" value="注册" />
				</form>

			Action：

				/**
				 * 属性驱动的方式，把数据封装到List集合中
				 * @author Administrator
				 */
				public class Regist4Action extends ActionSupport{
					
					private static final long serialVersionUID = 6556880331550390473L;
					
					private List<User> list;
					public List<User> getList() {
						return list;
					}
					public void setList(List<User> list) {
						this.list = list;
					}
					
					public String execute() throws Exception {
						for (User user : list) {
							System.out.println(user);
						}
						return NONE;
					}
				
				}
	
	4. 把数据封装到 Map 中

		* Map 集合是键值对的形式，页面的写法
			
				<input type="text" name="map['one'].name" />

		* Action 中提供 map 集合，并且提供 get 和 set 方法
	
		- jsp：
				
				<h3>向Map集合封装数据（默认情况下，采用是属性驱动的方式）</h3>
				<form action="${ pageContext.request.contextPath }/regist5.action" method="post">
					姓名:<input type="text" name="map['one'].username" /><br/>
					密码:<input type="password" name="map['one'].password" /><br/>
					年龄:<input type="password" name="map['one'].age" /><br/>
					
					姓名:<input type="text" name="map['two'].username" /><br/>
					密码:<input type="password" name="map['two'].password" /><br/>
					年龄:<input type="password" name="map['two'].age" /><br/>
					<input type="submit" value="注册" />
				</form>

		- Action：

				/**
				 * 属性驱动的方式，把数据封装到map集合中
				 * @author Administrator
				 */
				public class Regist5Action extends ActionSupport{
					
					private static final long serialVersionUID = 6556880331550390473L;
					
					private Map<String, User> map;
					public Map<String, User> getMap() {
						return map;
					}
					public void setMap(Map<String, User> map) {
						this.map = map;
					}
				
					public String execute() throws Exception {
						System.out.println(map);
						return NONE;
					}
				
				}

##4、Struts2 拦截器(重难点)
	
1. 拦截器的概述
	
	* 拦截器就是 AOP（Aspect-Oriented Programming）的一种实现。（AOP 是指用于在某个方法或字段被访问之前，进行拦截然后在之前或之后加入某些操作。）
	
	* 过滤器：过滤从客服端发送到服务器端请求的
	
	* 拦截器：拦截器不能拦截 JSP，只能拦截对目标 Action 中的某些方法进行拦截（进出 Action 时都进行拦截）
	
	![](http://upload-images.jianshu.io/upload_images/2106579-014fee7e44c41c8c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2. 拦截器和过滤器的区别
	
	1. 拦截器是基于 JAVA 反射机制的，而过滤器是基于函数回调的
	
	2. 过滤器依赖于Servlet容器，而拦截器不依赖于 Servlet 容器
	
	3. 拦截器只能对 Action 请求起作用（Action 中的方法），而过滤器可以对几乎所有的请求起作用（CSS JSP JS）
		
		* 拦截器 采用 责任链 模式，类似过滤器的过滤链

			1. 在责任链模式里,很多对象由每一个对象对其下家的引用而连接起来形成一条链

			2. 责任链每一个节点，都可以继续调用下一个节点，也可以阻止流程继续执行
		
		* 在struts2 中可以定义很多个拦截器，将多个拦截器按照特定顺序 组成拦截器栈 （顺序调用栈中的每一个拦截器 ）
	
3. Struts2 的核心是拦截器，看一下 Struts2 的运行流程

	![](http://upload-images.jianshu.io/upload_images/2106579-b07cd33be69b765f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
> 请求提交到服务器端，由 ActionMapper 解析，然后会先经过 Struts 2 的核心过滤器（StrutsPrepareAndExecuteFilter），通过源码可以发现，在这时会得到 namespace 、name、method，再根据 Configuration Manager 和 Struts.xml，它们是关于配置的信息，接着创建 ActionProxy，再由 ActionProxy 创建 ActionInvocation ，它负责调用所有的 Action，然后经过层层 Interceptor（拦截器）到达视图模版（JSP、FreeMarker、Velocity 等等），离开视图模版后又进入层层拦截器，最后作出响应，返回给客户端。

##5、如何自定义一个 Struts2 拦截器？
1. 编写拦截器，需要实现 Interceptor 接口，实现接口中的三个方法，或者也可以继承 Interceptor 接口的几个实现类，如下就继承了 AbstractInterceptor 类，Struts2 已经规定了该类拦截所有 Action 的所有方法：

		/**
		 * 编写简单的拦截器
		 * @author Administrator
		 */
		public class DemoInterceptor extends AbstractInterceptor{
		
			private static final long serialVersionUID = 4360482836123790624L;
			
			/**
			 * intercept用来进行拦截的
			 */
			public String intercept(ActionInvocation invocation) throws Exception {
				System.out.println("Action方法执行之前...");
				// 执行下一个拦截器
				String result = invocation.invoke();
				
				System.out.println("Action方法执行之后...");
				
				return result;
			}
		
		}

2. 需要在struts.xml中进行拦截器的配置，配置一共有两种方式

	- 第一种，定义拦截器：

			<!-- 第一种方式：定义拦截器 -->
			<interceptors>
				<interceptor name="DemoInterceptor" class="com.itheima.interceptor.DemoInterceptor"/>
			</interceptors>
	
			<action name="userAction" class="com.itheima.demo3.UserAction">
				<!-- 若是简单的引用自己的拦截器，那么默认栈（defaultStack）的拦截器就不执行了，必须要手动引入默认栈 -->	
				<interceptor-ref name="DemoInterceptor"/>
				<interceptor-ref name="defaultStack"/>
			</action>				
		
	- 第二种，定义拦截器栈：

			<!-- 第二种方式：定义拦截器栈 -->
			<interceptors>
				<interceptor name="DemoInterceptor" class="com.itheima.interceptor.DemoInterceptor"/>
				<!-- 定义拦截器栈 -->
				<interceptor-stack name="myStack">
					<interceptor-ref name="DemoInterceptor"/>
					<interceptor-ref name="defaultStack"/>
				</interceptor-stack>
			</interceptors>
			
			<action name="userAction" class="com.itheima.demo3.UserAction">
				
				<!-- 引入拦截器栈就OK -->
				<interceptor-ref name="myStack"/>
			</action>

3. 案例：使用拦截器判断用户是否已经登录

	- 首先自定义拦截器类：UserInterceptor，注意：在这里不能继承 AbstractInterceptor 类，因为该类拦截所有方法，若把登陆方法也拦截了，那永远也登陆不了了，在这里我们可以选择 MethodFilterInterceptor 类，它可以配置哪些拦截，哪些不拦截

			/**
			 * 自定义拦截器，判断当前系统是否已经登录，如果登录，继续执行。如果没有登录，跳转到登录页面
			 * @author Administrator
			 */
			public class UserInterceptor extends MethodFilterInterceptor{
			
				private static final long serialVersionUID = 335018670739692955L;
				
				/**
				 * 进行拦截的方法
				 */
				protected String doIntercept(ActionInvocation invocation) throws Exception {
					// 获取session对象
					User user = (User) ServletActionContext.getRequest().getSession().getAttribute("existUser");
					if(user == null){
						// 没有登录，直接返回一个字符串，后面就不会执行了
						return "login";
					}
					return invocation.invoke();
				}
			
			}

	- 然后配置 struts.xml，定义全局结果页面 login，然后在用户模块的登陆功能中，使拦截失效，注意失效是如何配置的

			<?xml version="1.0" encoding="UTF-8" ?>
			<!DOCTYPE struts PUBLIC
				"-//Apache Software Foundation//DTD Struts Configuration 2.3//EN"
				"http://struts.apache.org/dtds/struts-2.3.dtd">
			<struts>
				
				<package name="crm" namespace="/" extends="struts-default">
					
					<!-- 配置拦截器 -->
					<interceptors>
						<interceptor name="UserInterceptor" class="com.itheima.interceptor.UserInterceptor"/>
					</interceptors>
					
					<global-results>
						<result name="login">/login.htm</result>
					</global-results>
					
					<!-- 配置用户的模块 -->
					<action name="user_*" class="com.itheima.action.UserAction" method="{1}">
						<!-- <result name="login">/login.htm</result> -->
						<result name="success">/index.htm</result>
						<interceptor-ref name="UserInterceptor">
							<!-- login方法不拦截 -->
							<param name="excludeMethods">login</param>
						</interceptor-ref>
						<interceptor-ref name="defaultStack"/>
					</action>
					
					<!-- 客户模块 -->
					<action name="customer_*" class="com.itheima.action.CustomerAction" method="{1}">
						<interceptor-ref name="UserInterceptor"/>
						<interceptor-ref name="defaultStack"/>
					</action>
					
				</package>
			    
			</struts>

	- 之前在 Java web 阶段学习了过滤器（Filter），它也可以用来判断用户是否已经登陆，但是注意两者的区别，过滤器可以过滤所有的 URL，拦截器只能在访问与离开 Action 的时候进行拦截。
