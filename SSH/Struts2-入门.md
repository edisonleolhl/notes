> 本文包括：

> 1、Struts 2 概述
> 
> 2、Struts 2 快速入门
> 
> 3、Struts 2 的执行流程
> 
> 4、配置 struts.xml 时的问题与解决方法
> 
> 5、Struts 2 各配置文件加载的顺序

> 6、struts.xml 如何配置？

> 7、Struts 2 如何配置常量？

> 8、引入多个 struts 的配置文件（了解）

> 9、Action 类的三种写法

> 10、Action 的访问（重难点）

![](http://upload-images.jianshu.io/upload_images/2106579-79eb6361e34d8248.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##1、Struts 2 概述
1. 什么是 Struts 2 的框架
	
	* Struts 2 是 Struts 1 的下一代产品，是在 struts 1和 WebWork 的技术基础上进行了合并的全新的 Struts 2框架。
		
	* 其全新的 Struts 2 的体系结构与 Struts 1 的体系结构差别巨大。
		
	* Struts 2 以 WebWork 为核心，采用拦截器的机制来处理用户的请求，这样的设计也使得业务逻辑控制器能够与ServletAPI完全脱离开，所以 Struts 2 可以理解为 WebWork 的更新产品。
		
	* 虽然从 Struts 1 到 Struts 2 有着太大的变化，但是相对于 WebWork，Struts 2 的变化很小。

2. Struts 2 是一个基于 MVC 设计模式的 Web 层框架
		
	* MVC 和 JavaEE 的三层结构
			 
		* MVC 设计模式:是由一些网站的开发人员提出来的
			
		* JavaEE 三层结构:SUN公司为 JavaEE 开发划分的结构

	3. 常见的 Web 层的框架
		
		* Struts 1
		
		* Struts 2
		
		* Webwork
		
		* SpringMVC
	
	4. Web 层框架的特点

		* 都是一个特点，前端控制器模式

		* 记住：前端控制器（核心的控制器）

		* Struts 2 框架前端控制器就是过滤器（Filter）

3. 前端控制器模式

![](http://upload-images.jianshu.io/upload_images/2106579-01bceba1556a8994.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##2、Struts 2 快速入门

1. 环境搭建

	- 下载 jar 包，最好不要选择最新的，尽量选择较稳定的版本

		> https://struts.apache.org/		-- 官网地址

		- 若解压 struts-2.3.24-all.zip 包

			* 解压后会看到 jar 包和一些文件，大家需要掌握包相关的信息
	
				* apps	-- Struts2框架提供了一些应用

				* libs	-- Struts2框架开发的 jar 包

				* docs	-- Struts2框架开发文档

				* src	-- Struts2框架源码

		- 若解压 struts-2.3.24-apps / libs / docs / src .zip ，则会得到如上所述的各自内容，官网为了下载方便，各有所需

	- 引入需要开发的 jar 包

		* Struts 2 框架的开发 jar 包非常多，但是不是所有都是必须要引入的，有一些必须要导入的 jar 包，这些 jar 包可以从 Struts 2 框架提供的应用中找到。

		* 大家可以打开 apps 目录，然后找到 struts2-blank.war 应用（blank 是空模版，所以这个包含了最基本的 jar 包）。war 包和 zip 包的压缩格式是一样的，所以可以自己修改后缀名为 zip 再解压之。

		* 找到解压后的应用，打开 WEB-INF/lib 目录下所有的 jar 包。并且把这些 jar 包复制到工程中就可以了。

	- 配置 Struts 2 的前端控制器，**注意：这一步是必须要做的操作，这是 Struts 2 核心的控制器**。

		* Struts 2 的前端控制器就是一个过滤器，那么过滤器相关知识咱们都学习过，需要在 web.xml 中进行配置。

		* 前端控制器的类的路径和名称：

			> org.apache.struts2.dispatcher.ng.filter.StrutsPrepareAndExecuteFilter

		* 具体配置代码如下：

				  <filter>
				  	<filter-name>struts2</filter-name>
				  	<filter-class>org.apache.struts2.dispatcher.ng.filter.StrutsPrepareAndExecuteFilter</filter-class>
				  </filter>
				  <filter-mapping>
				  	<filter-name>struts2</filter-name>
				  	<url-pattern>/*</url-pattern>
				  </filter-mapping>

2. 编写 jsp 文件，添加一个超链接，用来执行 Action 类
	
		<%@ page language="java" contentType="text/html; charset=UTF-8"
		    pageEncoding="UTF-8"%>
		<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
		<html>
		<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>Insert title here</title>
		</head>
		<body>
		
		<h3>快速入门</h3>
		
		<a href="${ pageContext.request.contextPath }/hello.action">快速入门按钮</a>
		
		</body>
		</html>

3. 编写 Action 类

	- Action 类是动作类，是 Struts 2 处理请求，封装数据，响应页面的核心控制器，需要自己编写，Action 类中的方法有如下要求：

		- 控制权限为 public
		
		- 返回值为 String 类型，且**返回值指明了要跳转的页面地址，默认是转发**
		
		- 名称任意（但最好有意义）
		
		- 没有参数列表

	- 代码如下：
	
			package com.itheima.action;
			
			/**
			 * Stuts2框架都使用Action类处理用户的请求
			 * @author Administrator
			 */
			public class HelloAction {
				
				/**
				 * Action类中的方法签名有要求的，必须这么做
				 * public 共有的
				 * 必须有返回值，必须String类型
				 * 方法名称可以是任意的，但是不能有参数列表
				 * 页面的跳转：
				 * 	1. return "字符串"
				 * 	2. 需要在strtus.xml配置文件中，配置跳转的页面
				 */
				public String sayHello(){
					// 编写代码 接收请求的参数
					System.out.println("Hello Struts2!!");
					return "ok";
				}
				
				/**
				 * 演示的method方法的默认值
				 * @return
				 */
				public String execute(){
					System.out.println("method方法的默认值是execute");
					return null;
				}
				
			}

4. 编写 Struts.xml 配置文件

	- 配置文件名称是 struts.xml（名称必须是 struts.xml）

	- 在 src 下引入 struts.xml 配置文件（配置文件的路径必须是在 src 的目录下）

	- struts.xml 配置如下：

			<?xml version="1.0" encoding="UTF-8" ?>
			<!DOCTYPE struts PUBLIC
				"-//Apache Software Foundation//DTD Struts Configuration 2.3//EN"
				"http://struts.apache.org/dtds/struts-2.3.dtd">
			
			<struts>
			    <package name="default" namespace="/" extends="struts-default">
					<action name="hello" class="com.itheima.action.HelloAction" method="sayHello">
						<!-- 配置跳转的页面，路径的写法：在Struts2框架中，不管是转发还是重定向，都不用写项目名 -->
						<result name="ok">/demo1/suc.jsp</result>
					</action>
			    </package>
			</struts>

	> **注意：在 jsp 页面中的路径写法为： `/工程名/hello.action`，其中`xx`与 struts.xml 中的 action 的名字一致： `action name="hello"`。**

##3、Struts 2 的执行流程

1. 执行的流程
	
	* 编写的页面，点击超链接，请求提交到服务器端。
	
	* 请求会先经过 Struts 2 的核心过滤器（StrutsPrepareAndExecuteFilter）

		* 过滤器的功能是完成了一部分代码功能。

		* 就是一系列的拦截器执行了，进行一些处理工作。
			
		* 咱们可以在 struts-default.xml 配置文件中看到有很多的拦截器，可以通过断点的方式来演示。
		
		* 拦截器执行完后，会根据 struts.xml 的配置文件找到请求路径，找到具体的类，通过**反射**的方式让方法执行。
	
2. 总结

	> JSP 页面-->StrutsPrepereAndExecuteFilter 过滤器-->执行一系列拦截器（完成了部分代码）-->执行到目标 Action-->返回字符串-->结果页面（result）-->页面跳转

3. 执行流程图解：

	![](http://upload-images.jianshu.io/upload_images/2106579-e417df26eb6cf35b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##4、配置 struts.xml 时的问题与解决方法
1. 先找到struts.xml的配置文件，复制 http://struts.apache.org/dtds/struts-2.3.dtd，注意，不要有双引号。
		
	> http://struts.apache.org/dtds/struts-2.3.dtd
	
2. MyEclipse工具栏 -- window -- preferences -- 搜索 -- 输入xml -- 选择 xml Catalog
	
3. 选择添加按钮（add按钮）
		
	* key type 要选择URI
	
	* key的位置把刚才复制的路径拷贝进去。http://struts.apache.org/dtds/struts-2.3.dtd
	
	* Location 要在本地能找到struts2-2.3.dtd的真实文件，即点击 File System，去资料中找到它。
		
4. 如果想查看源代码
	
	> attachsource：选择资料/struts2/struts-2.3.24-all.zip

##5、Struts 2 各配置文件加载的顺序
1. 首先要需要掌握：
	
	* 加载了哪些个配置文件（重点的）
	
	* 配置文件的名称是什么
	
	* 配置文件的位置
	
	* 配置文件的作用

2. Struts2 框架的核心是 StrutsPrepareAndExecuteFilter 过滤器，该过滤器有两个功能
	
	* Prepare		-- 预处理，加载核心的配置文件
	
	* Execute		-- 执行，让部分拦截器执行

3. StrutsPrepareAndExecuteFilter 过滤器会加载哪些配置文件呢？
	
	* 通过源代码可以看到具体加载的配置文件和加载配置文件的顺序，从上到下依次加载：
	
		* init_DefaultProperties(); 				
			> 加载： org/apache/struts2/default.properties
	
	    * init_TraditionalXmlConfigurations();		
			> 加载： struts-default.xml,struts-plugin.xml,struts.xml
    
    	* init_LegacyStrutsProperties();			
			> 加载：**自定义**的 struts.properties.
    
    	* init_CustomConfigurationProviders();		
			> 加载：用户自定义配置提供者
  
      	* init_FilterInitParameters() ;				
			> 加载： web.xml
	
4. 重点了解的配置文件
	
	* default.properties		

		> 在 org/apache/struts2/ 目录下，代表的是配置的是 Struts 2 框架各种常量的值
	
	* struts-default.xml		

		> 在 Struts 2 的核心包下，代表的是 Struts 2 核心功能的配置（Bean、拦截器、结果类型等）
	
	* struts.xml				

		> **重点中的重点配置，代表 WEB 应用的默认配置，在工作中，基本都是配置它就！！（可以配置常量）**
	
	* web.xml					

		> 配置前端控制器（可以配置常量）
	
5. 配置文件加载顺序总结
	
	* 先加载 default.properties 文件，位于 org/apache/struts2/default.properties ，都是常量。
	
	* 又加载 struts-default.xml 配置文件，在核心的 jar 包最下方，struts2 框架的核心功能都是在该配置文件中配置的。
	
	* 再加载 struts.xml 的配置文件，在 src 的目录下，代表用户自己配置的配置文件
	
	* 最后加载 web.xml 的配置文件
		
	
	* 后加载的配置文件会覆盖掉之前加载的配置文件（在这些配置文件中可以配置常量）
	
6. 注意一个问题
	
	* 哪些配置文件中可以配置常量？
	
		* default.properties		

			> 默认值，咱们是不能修改的！！
	
		* struts.xml				

			> 可以配置，**开发中基本上都在该配置文件中配置常量**
	
		* struts.properties			

			> 可以配置，但**基本不会**在该配置文件中配置
	
		* web.xml					

			> 可以配置，但**基本不会**在该配置文件中配置
		
	* 后加载的配置文件会覆盖掉之前加载的配置！！

##6、struts.xml 如何配置？
	
1. `<package>`标签，如果要配置`<Action>`的标签，那么必须要先配置`<package>`标签，代表的包的概念
	
	* 包含的属性
	
		* name					

			> 包的名称，要求是唯一的，管理action配置
	
		* extends				

			> 继承，可以继承其他的包，只要继承了，那么该包就包含了其他包的功能，一般都是继承struts-default
	
		* namespace				

			> 名称空间，一般与<action>标签中的name属性共同决定访问路径（通俗话：怎么来访问action），常见的配置如下
	
			* namespace="/"		

				> 根名称空间
	
			* namespace="/aaa"	

				> 带有名称的名称空间
	
		* abstract				

			> 抽象的。这个属性基本很少使用，值如果是true，那么编写的包是被继承的
	
2. `<action>`标签
	
	* 代表配置 action 类，包含的属性
	
		* name			

			> 和<package>标签的 namespace 属性一起来决定访问路径的
	
		* class			

			> 配置Action类的全路径（默认值是 ActionSupport 类）
	
		* method		

			> Action类中执行的方法，如果不指定，默认值是 execute
	
3. `<result>`标签
	
	* action 类中方法执行，返回的结果跳转的页面
	
		* name		-- 结果页面逻辑视图名称
	
		* type		-- 结果类型（默认值是转发，也可以设置其他的值）

##7、Struts 2 如何配置常量

1. 可以在 Struts 2 框架中的哪些配置文件中配置常量？
	
	* struts.xml（必须要掌握，开发中基本上就在该配置文件中编写常量）
			
			<?xml version="1.0" encoding="UTF-8" ?>
			<!DOCTYPE struts PUBLIC
			    "-//Apache Software Foundation//DTD Struts Configuration 2.3//EN"
			    "http://struts.apache.org/dtds/struts-2.3.dtd">
			
			<struts>
				<!-- 配置常量 -->
				<constant name="key" value="value"></constant>
				<package name="default" namespace="/" extends="struts-default">
					<action name="hello" class="com.itheima.action.HelloAction" method="sayHello">
						<!-- 配置跳转的页面，路径的写法：在Struts2框架中，不管是转发还是重定向，都不用写项目名 -->
						<result name="ok">/demo1/suc.jsp</result>
					</action>
				</package>
			</struts>	

	* web.xml
	
		在 StrutsPrepareAndExecuteFilter 配置文件中配置初始化参数(init-param)
	
			  <filter>
			  	<filter-name>struts2</filter-name>
			  	<filter-class>org.apache.struts2.dispatcher.ng.filter.StrutsPrepareAndExecuteFilter</filter-class>
				<init-param>
					<param-name>key</param-name>
					<param-value>value</param-value>
				</init-param>
			  </filter>
			  <filter-mapping>
			  	<filter-name>struts2</filter-name>
			  	<url-pattern>/*</url-pattern>
			  </filter-mapping>

	* 注意：后加载的配置的文件的常量会覆盖之前加载的常量！！
	
2. 需要了解的常量：
	
	* struts.i18n.encoding=UTF-8			

		> 指定默认编码集,作用于HttpServletRequest的setCharacterEncoding方法 
	* struts.action.extension=action,,		
	
		> 该属性指定需要Struts 2处理的请求后缀，该属性的默认值是action，即所有匹配*.action的请求都由Struts2处理。如果用户需要指定多个请求后缀，则多个后缀之间以英文逗号（,）隔开
	
	* struts.serve.static.browserCache=true		

		> 设置浏览器是否缓存静态内容,默认值为true(生产环境下使用),开发阶段最好关闭 
	
	* struts.configuration.xml.reload=false		

		> 当struts的配置文件修改后,系统是否自动重新加载该文件,默认值为false(生产环境下使用) 
	
	* struts.devMode = false					

		> 开发模式下使用,这样可以打印出更详细的错误信息 

##8、引入多个 struts 的配置文件（了解）
	
1. 在大部分应用里，随着应用规模的增加，系统中 Action 的数量也会大量增加，导致 struts.xml 配置文件变得非常臃肿。
	
	为了避免 struts.xml 文件过于庞大、臃肿，提高 struts.xml 文件的可读性，我们可以将一个 struts.xml 配置文件分解成多个配置文件，然后在 struts.xml 文件中包含其他配置文件。
	
2. 可以在`<package>`标签中，使用`<include>`标签来引入其他的 struts_xx.xml 的配置文件。例如：
	
		<struts>
			...
			<include file="struts-part1.xml"/>
			<include file="struts-part2.xml"/>
		</struts>
	
3. **注意格式**：

		<include file="cn/itcast/demo2/struts-part1.xml"/>

##9、Action 类的三种写法
- 配置文件学习完成，下面的重点是 Action 类的三种写法：
	
	1. 不继承、不实现接口，此时该 Action 类就是一个 POJO 类
	
		* 什么是POJO类，POJO（Plain Ordinary Java Object）简单的 Java 对象。

			> 简单记：没有继承某个类，没有实现接口，就是 POJO 的类。

		- 代码：

				package com.itheima.action1;
				
				/**
				 * 就是POJO类：没有任何继承和实现
				 * @author Administrator
				 */
				public class Demo1Action {
					
					/**
					 * execute是默认方法
					 * return null; 不会进行跳转
					 * @return
					 */
					public String execute(){
						System.out.println("Demo1Action就是POJO类...");
						return null;
					}
				
				}

	2. Action 类实现 Action 接口
	
		* Action 接口中定义了5个常量，5个常量的值对应的是5个逻辑视图跳转页面（跳转的页面还是需要自己来配置），还定义了一个方法，execute 方法。
	
		* 需要掌握5个逻辑视图的常量
	
			* SUCCESS		-- 成功.
	
			* INPUT			-- 用于数据表单校验.如果校验失败,跳转 INPUT 视图.
	
			* LOGIN			-- 登录.
	
			* ERROR			-- 错误.
	
			* NONE			-- 页面不转向.
		
		- 代码：

				package com.itheima.action1;
				
				import com.opensymphony.xwork2.Action;
				
				/**
				 * 实现Action的接口，Action是框架提供的接口
				 * @author Administrator
				 */
				public class Demo2Action implements Action{
				
					public String execute() throws Exception {
						System.out.println("Demo2Action实现了Action的接口");
						
						// return "success";
						// return LOGIN;
						
						// 表示页面不跳转
						return NONE;
					}
				
				}

	3. Action 类可以去继承 ActionSupport 类（开发中这种方式使用最多）
	
		* 设置错误信息

		- ActionSupport 也实现了 Action 接口

		- ActionSupport 中已经有了 excuete 方法，所以继承时需要 override 父类的方法来实现开发者希望的逻辑功能

		- 代码：

				package com.itheima.action1;
				
				import com.opensymphony.xwork2.ActionSupport;
				
				/**
				 * 编写Action类继承ActionSupport类，ActionSupport类已经实现了Action和一些其他接口
				 * @author Administrator
				 */
				public class Demo3Action extends ActionSupport{
					
					private static final long serialVersionUID = 2183101963251216722L;

					@override
					public String execute() throws Exception {
						System.out.println("Demo3Action继承了ActionSupport类...");
						return NONE;
					}
				
				}
	
- 在 struts.xml 中如下配置：

			<?xml version="1.0" encoding="UTF-8" ?>
			<!DOCTYPE struts PUBLIC
				"-//Apache Software Foundation//DTD Struts Configuration 2.3//EN"
				"http://struts.apache.org/dtds/struts-2.3.dtd">
			<struts>
				
				<!-- 包结构 -->
			    <package name="demo1" namespace="/" extends="struts-default">
					
					<!-- POJO类的方式 -->
					<action name="demo1Action" class="com.itheima.action1.Demo1Action"/>
					
					<!-- 实现Action接口的方式 -->
					<action name="demo2Action" class="com.itheima.action1.Demo2Action">
						<result name="login">/demo1/suc.jsp</result>
					</action>
					
					<!-- 继承ActionSupport类的方式 -->
					<action name="demo3Action" class="com.itheima.action1.Demo3Action"/>
			    </package>
			</struts>

##10、Action 的访问（重难点）

1. 传统配置方式：通过`<action>`标签中的 method 属性，可以 访问到 Action 中的具体的方法。
	
	* 传统配置方式：配置清晰、容易理解，但是扩展时需要修改配置文件等等，较麻烦。
	
	* 具体的实例如下：
	
		* 页面代码
	
				<h3>传统的配置文件的方式</h3>
				<a href="${ pageContext.request.contextPath }/saveCust.action">保存客户</a>
				<a href="${ pageContext.request.contextPath }/delCust.action">删除客户</a>
			
	
		* struts.xml 配置文件的代码

			    <!-- 演示Action的访问 -->
			    <package name="demo2" namespace="/" extends="struts-default">
				   	<!-- 传统方式 -->
				    <action name="saveCust" class="com.itheima.action2.CustomerAction" method="save"/>
				    <action name="delCust" class="com.itheima.action2.CustomerAction" method="delete"/>
			    </package>
			
	
		* Action 的代码
	
				public class CustomerAction extends ActionSupport{
				
					private static final long serialVersionUID = 7307785750944680651L;
					
					public String save(){
						System.out.println("保存客户...");
						return NONE;
					}
					
					public String delete(){
						System.out.println("删除客户...");
						return NONE;
					}
				
				}
	
2. 通配符的访问方式：通配符就是 * ，代表任意的字符
	
	* 通配符的访问方式：可以简化配置文件的代码编写，而且扩展和维护比较容易。
	
	* **前提：访问的路径和方法的名称必须要有某种联系**

	* 具体实例如下：
	
		* 页面代码
	
				<h3>通配符的方式（应用比较多）</h3>
				<a href="${ pageContext.request.contextPath }/linkman_save.action">保存联系人</a>
				<a href="${ pageContext.request.contextPath }/linkman_delete.action">删除联系人</a>
			
	
		* struts.xml 配置文件代码
	
			    <!-- 演示Action的访问 -->
			    <package name="demo2" namespace="/" extends="struts-default">
			    	<!-- 通配符的方式 -->
			    	<action name="linkman_*" class="com.itheima.action2.LinkmanAction" method="{1}">
			    		<result name="saveOK">/demo1/suc.jsp</result>
			    		<result name="delOK">/demo1/suc.jsp</result>
			    	</action>
			    </package>
			
	
		* Action的代码
		
				public class LinkmanAction extends ActionSupport{
				
					private static final long serialVersionUID = -6462671346088624621L;
					
					public String save(){
						System.out.println("保存联系人...");
						return "saveOK";
					}
					
					public String delete(){
						System.out.println("删除联系人...");
						return "delOK";
					}
				
				}
			
	* **具体理解**：在 JSP 页面发送请求，http://localhost/struts2_01/linkman_save.action，配置文件中的 linkman_* 可以匹配该请求，method 属性的值使用{1}来代替，{1}就表示的是第一个*号的位置！！所以 method 的值就等于 add ，那么就找到 LinkmanAction 类中的 save 方法，所以 save 方法就执行了！
	
		> 	<action name="linkman_*_*" class="" method="{2}">
		> 	如果配置文件如上所示，那么匹配的是第二个*号的位置

3. 动态方法访问的方式（有的开发中也会使用这种方式）
	
	* 如果想完成动态方法访问的方式，需要开启一个常量，struts.enable.DynamicMethodInvocation ，把值设置成 true。
	
		* 注意：不同的 Struts 2 框架的版本，该常量的值不一定是 true 或者 false ，需要自己来看一下。如果是 false ，需要自己开启。
	
		* 在 struts.xml 中配置该常量（具体做法见本文第7点）。
	
				<constant name="struts.enable.DynamicMethodInvocation" value="true"></constant>
		
	* 具体代码如下
	
		* 页面的代码（注意请求时的路径！）
		
				<h3>动态方法访问的方式</h3>
				<a href="${ pageContext.request.contextPath }/user!save.action">保存用户</a>
				<a href="${ pageContext.request.contextPath }/user!delete.action">删除用户</a>
	
		* struts.xml 配置文件代码

			    <!-- 演示Action的访问 -->
			    <package name="demo2" namespace="/" extends="struts-default">	
			    	<!-- 配置动态方法访问 -->
			    	<action name="user" class="com.itheima.action2.UserAction"/>
			    </package>
			
		* Action 的类的代码

				public class UserAction extends ActionSupport{
				
					private static final long serialVersionUID = 4818164363592527550L;
					
					public String save(){
						System.out.println("保存用户...");
						return NONE;
					}
					
					public String delete(){
						System.out.println("删除用户...");
						return NONE;
					}
				
				}
