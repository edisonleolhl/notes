> 本文包括：
> 
> 1、名词解释
> 
> 2、邮件收发过程
> 
> 3、JavaMail 知识概要
> 
> 4、发送一封符合 MIME 协议的 JavaMail
> 
> 5、总结
> 
> 6、MX记录与A记录

![](http://upload-images.jianshu.io/upload_images/2106579-fc13c61afb335599.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##1、名词解释
- 邮件服务器：

	- 类似于web服务器（如Tomcat）、数据库服务器（如MySql)，把一台邮件服务器端软件放在网络上，即可供广大网络用户使用。

	- 类似于邮局，用户发邮件时，邮件服务器处理，再投递给相应的邮箱地址。

	- 比如有sina、sohu、163、qq等等邮件服务器。

- 电子邮箱：邮件服务器中的账户，服务器会为每个邮箱账户分配地址和空间。

- 邮件收发协议：

	- SMTP（发送邮件协议，默认端口25）
	
	- POP3（收取邮件协议，默认端口110，**不能在线操作**）

	- IMAP（收取邮件协议，默认端口143，运行在TCP/IP协议之上，与POP3的主要区别：**可以在线操作**，用户可以不用把所有的邮件全部下载，可以通过客户端直接对服务器上的邮件进行操作）



	> IMAP是什么？
	> 
	> IMAP，即Internet Message Access Protocol（互联网邮件访问协议），您可以通过这种协议从邮件服务器上获取邮件的信息、下载邮件等。IMAP与POP类似，都是一种邮件获取协议。
 

	> IMAP和POP有什么区别？
	>
	> POP允许电子邮件客户端下载服务器上的邮件，但是您在电子邮件客户端的操作（如：移动邮件、标记已读等），这是不会反馈到服务器上的，比如：您通过电子邮件客户端收取了QQ邮箱中的3封邮件并移动到了其他文件夹，这些移动动作是不会反馈到服务器上的，也就是说，QQ邮箱服务器上的这些邮件是没有同时被移动的 。但是IMAP就不同了，电子邮件客户端的操作都会反馈到服务器上，您对邮件进行的操作（如：移动邮件、标记已读等），服务器上的邮件也会做相应的动作。也就是说，IMAP是“双向”的。
	> 
	> 同时，IMAP可以只下载邮件的主题，只有当您真正需要的时候，才会下载邮件的所有内容。

##2、邮件收发过程

- 邮件收发过程图解：

	![邮件收发过程图解](http://upload-images.jianshu.io/upload_images/2106579-9a5422818698387d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 手动收发邮件：

	1. 在sina和sohu 分别注册两个邮箱账户
	
		sina:  yuyang94895@sina.com / 1qaz2wsx

		sohu: yuyang94895@sohu.com /1qaz2wsx

	2. 用sina向sohu发送一封邮件，通过telnet（socket程序） 手动根据smtp协议发送邮件

	3. 安装telnet

	4. 使用SMTP协议发送邮件，以新浪为例（以下命令需要逐行输入）：
	
			连接新浪smtp服务器 ： telnet stmp.sina.com 25
	
			ehlo xxx   ----- SMTP 1代用的是helo，SMTP 2代用的是ehlo
			auth login   ----- 注意：必须使用base64编码后的用户名和密码
			
			eXV5YW5nOTQ4OTU=   ----- 经过base64编码后的用户名
			MXFhejJ3c3g=  -----经过base64编码后的密码
			
			mail from:<yuyang94895@sina.com>  ----- 发件人
			rcpt to:<yuyang94895@sohu.com>    ----- 收件人
			
			data   ------ 邮件正文
						
			from:<yuyang94895@sina.com>
			to:<yuyang94895@sohu.com>
			subject:第一封0713测试邮件
			
			这是一封测试邮件，哈哈~~~~
			.   
			
			quit  ----- 退出客户端

		> RFC822文档规定了如何编写一封简单邮件（邮件正文）：
		> 
		> - 邮件头
		> 	- from字段（发件人）
		> 	- to字段（收件人）
		> 	- subject字段（邮件标题）
		> 	- cc字段（抄送） / bcc字段（暗送）
		> - 邮件体
		> 	- 邮件内容
		> 
		> 抄送：A 发给B ，选择抄送给C ， B可以看见邮件抄送给 C （邮件是给B的，需要让C知道B已经收到邮件）
		> 
		> 暗送：A 发给B，选择暗送给C ，B可以看见邮件，但是不能看到邮件发给C （邮件给B，也想给C一份，但不想让B知道）

	5. 除了使用网络邮件服务器之外，还可以使用本地邮件服务器，如易邮，首先安装易邮：

		- 工具 --- 服务器设置 ---- 修改单域名,如：estore.com     	
		
		- 账户 --- 新建账户  aaa/111 和 bbb/111
	
		- 用aaa@estore.com 向 bbb@estore.com 发送一封邮件

	6. smtp连接易邮发件，即以易邮本地服务器为例：

			连接易邮smtp服务器：telnet localhost 25
			
			ehlo xxx   ----- SMTP2代
			auth login   ----- 发邮件时，发给服务器用户名和密码必须使用base64编码
			
			YWFh   ----- aaa经过base64编码后的字符
			MTEx   ----- 111经过base64编码后的字符
			
			mail from:<aaa@estore.com>  ----- 发件人
			rcpt to:<bbb@estore.com>    ----- 收件人
			
			data   ------ 邮件内容
			
			from:<aaa@estore.com>
			to:<bbb@estore.com>
			subject:第一封0713测试邮件
			
			这是一封测试邮件，哈哈~~~~
			.   
			
			quit  ----- 退出客户端

	7.  pop3连接易邮收取邮件

			连接易邮pop3服务器 ： telnet localhost 110
			user bbb
			pass 111
			
			stat ----- 返回邮箱的统计信息
			list 邮件号 ------  邮件信息 
			retr 邮件号 ------ 收取邮件内容
			
			quit

	> putty：
	>
	> telnet 在 win7 环境下输入中文显示乱码,因 telnet 客户端本身问题，无法解决。
	>
	>可选择 putty 代替，putty 可以解决乱码问题。
	>
	>putty 模拟客户端，采用多种连接协议连接服务器 ------  企业使用远程连接操作 linux
	>
	>对 putty 设置： 
	>
	>window --- Translation (Use font encoding)  -------- font encoding就是系统默认编码集 gbk ，可以将字符集设为 utf-8 , 但对于 windows 不需要，对于 linux才需要
	>
	> window --- appearance ---- change 把字体改为支持中文的字体（如新宋体），再把字符集改为支持中文的字符集，如 gb2312
	>
	> Session 中对 ip port 和协议进行配置

- 冒名邮件问题：

	- RFC822 文档规定一封简单邮件如何编写，但本身存在漏洞：
	
	- 发邮件过程中 mail from 字段 和 RFC822 文档中 from 字段不同会出现什么问题？ 冒名邮件问题
	- 对方收取邮件时，只能看到 from 字段内容，无法得知 mail from 地址，这样就可以随意更改。


##3、JavaMail 知识概要
1. JavaMail 是一套邮件收发程序 API，编写 JavaMail 程序就是编写邮件客户端程序（类似于 outlook、foxmail 等邮件客户端）。

2. JavaMail 开发需要类库 javamail 的API,还需要 Java Activation Framework (jaf) ，JavaMail 依赖于 jaf ，但在 MyEclipse 10 的环境下，不需要弄 jaf ，详情见下一点。

3. 导入 jar 包

	mail.jar ( JDK6.0 以后官方 API 自带)

	* JDK6.0 以后开发，不需要导入 mail.jar 。
	* JDK5.0（包括） 之前开发，需要导入 mail.jar ，如果出现了问题，解决措施见下方。 

	> 如果出现了如下问题：
	> 
	> java.lang.NoClassDefFoundError: 
	> 
	> com/sun/mail/util/LineInputStream 异常
	> 
	> 原因： MyEclipse 新建工程自带的 javaee.jar 提供的 javaMail API 与 JavaMail的 jar 包发生冲突
	> 
	> 解决 ：删除 javaee.jar 里面的 mail 目录和 activation 目录（如果想一劳永逸，去 javaee.jar 所在的硬盘位置把这两个目录删掉。

4. JavaMail 邮件收发四个核心类

	1. Message 邮件

	2. Session 连接会话

	3. Transport 发送邮件

	4. Store 收取邮件

5. 发送邮件编程

	1. 创建与邮件发送服务器连接Session

	2. 编写邮件内容 Message

		符合邮件内容格式RFC822文档 setFrom , setRecipients , setSubject , setText 

	3. 使用 Transport 工具类 发送邮件

	4. demo :

			public void demo2() throws AddressException, MessagingException {
				// 步骤一 创建与邮件服务器连接会话
				Properties properties = new Properties();// 配置与服务器连接参数
				// 设置properties 属性
				properties.put("mail.transport.protocol", "smtp");
				properties.put("mail.smtp.host", "localhost"); // localhost是易邮邮件服务器的本地主机
				properties.put("mail.smtp.auth", "true");// 连接认证
				properties.put("mail.debug", "true");// 在控制台显示连接日志信息
				Session session = Session.getInstance(properties);// 与邮件服务器连接会话
		
				// 步骤二 编写Message
				MimeMessage message = new MimeMessage(session);// 代表一封邮件
				// from字段
				message.setFrom(new InternetAddress("aaa@estore.com"));
				// to 字段
				message.setRecipients(Message.RecipientType.TO, "bbb@estore.com");
				// subject字段
				message.setSubject("javamail发送简单邮件");
				// 邮件正文内容
				message.setText("使用javamail 可以发送简单邮件 ...");
		
				// 步骤三 使用Transport发送邮件
				Transport transport = session.getTransport();
				// 发邮件前进行身份校验
				transport.connect("aaa", "111");
				transport.sendMessage(message, message.getAllRecipients());
			}

##4、发送一封符合 MIME 协议的 JavaMail
1. MIME协议的引入：
	
	RFC822 文档只定义简单邮件格式，没有定义复杂邮件如何编写（前文的demo中邮件只包含简单的文本信息）。而 MIME 协议是 RFC822 文档的升级补充，完全支持 RFC822 文档。

2. MIME协议的用法：

	对于一封复杂邮件，如果包含了多个不同的数据（例如图片、附件等等），MIME 协议规定：要将邮件体分成多个部分，每个部分使用分隔线进行分隔，并使用 Content-Type 头字段对数据的类型以及多个数据之间的关系进行描述。

3. Content-Type 头字段（每段数据都需要）

	- 数据类型：
		
		- 格式：主类型/子类型。

		- 主类型包括：text、image、audio、video、application、message等。
		
		- 每个主类型下面又有多个子类型，例如text主类型包含plain、html、css、xml等子类型。

	- 数据的关系：

		1. multipart/mixed 用于携带附件

		2. multipart/related 内嵌图片，音乐 

		3. multipart/alternative 防止兼容问题

			> 发送简历时，将简历文件与邮件正文关系设置为alternative，当邮件客户端如果支持简历格式，简历会显示在正文中，如果不支持简历格式，简历会以附件携带

4. Content-Disposition 头字段（附件才需要）

	该头字段用于指定邮件阅读程序处理数据内容的方式。如果发送复杂邮件时需要携带附件，必须在附件部分，设置 Content-Disposition 头字段，它的值应该为 attachment 。

		Content-Dispostion : attachment;filename="1.bmp"

5. Content-ID 头字段（内嵌图片、音乐才需要）

	该头字段为 "multipart/related" 组合消息中的内嵌资源指定一个唯一标识号。在邮件正文中通过 

		![](cid:唯一标识)

	 引用内嵌图片和资源。

6. 图解：

	![](http://upload-images.jianshu.io/upload_images/2106579-29ec0cd265a1216e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)	

7. JavaMail API中与MIME协议相关的类：

	- MimeMessage 类 ----- 代表整封邮件，包括MIME对象的消息头与MimeMultipart对象
	
	- MimeBodyPart 类 ---- 代表邮件中一个MIME消息
	
	- MimeMultiPart 类 ---- 代表一个或多个MIME消息组合而成的组合MIME消息

8. JavaMail 怎样描述一封复杂邮件？

	- 判断邮件由几个部分组成，为每个部分设计 BodyPart （ MIME 消息）。
	
	- 将所有 BodyPart 组合起来变为 Multipart (**注意：只有 BodyPart 与 BodyPart 之间才可以组合，MultiPart 不可以直接和 BodyPart 组合，需要将 MultiPart 转换为 BodyPart 后，再与 BodyPart 组合**)。
	
	- 将最后合成的 MultiPart 交给 MimeMessage 对象。

9. 内嵌图片的邮件 demo :

		// 内嵌图片邮件
		public void demo3() throws Exception {
			// 发送邮件需要三个步骤
			// 步骤一：创建Session
			Properties properties = new Properties();
			properties.put("mail.transport.protocol", "smtp");
			properties.put("mail.smtp.host", "localhost");
			properties.put("mail.smtp.auth", "true");// 连接认证
			properties.put("mail.debug", "true");// 在控制台显示连接日志信息
			Session session = Session.getInstance(properties);// 与邮件服务器连接会话
			// 步骤二：创建Message
			MimeMessage message = new MimeMessage(session);
			// 设置邮件头（简单邮件和复杂邮件相同
			message.setFrom(new InternetAddress("aaa@estore.com"));
			message.setRecipients(Message.RecipientType.TO, "bbb@estore.com");
			message.setSubject("javamail发送内嵌图片邮件");
			// 设置邮件体（简单邮件和复杂邮件区别 就在于邮件体）
			MimeBodyPart pic = new MimeBodyPart();// 图片
			// 链接数据文件
			pic.setDataHandler(new DataHandler(new FileDataSource("beauty.jpg")));

			// 也可以用下面三行代码代替“链接数据文件”的操作，但明显更繁琐
			// DataSource dataSource = new FileDataSource("beauty.jpg");
			// DataHandler dataHandler = new DataHandler(dataSource);
			// pic.setDataHandler(dataHandler);
	
			// 设置一个唯一标识(用于在正文中引入)
			pic.setContentID("mypic");
	
			MimeBodyPart content = new MimeBodyPart(); // 邮件正文
			content.setContent("<h1>美女图片</h1>![](cid:mypic)",
					"text/html;charset=utf-8");
	
			// 将两个BodyPart整合
			MimeMultipart mimeMultipart = new MimeMultipart();
			mimeMultipart.addBodyPart(pic);
			mimeMultipart.addBodyPart(content);
	
			// 设置关系
			mimeMultipart.setSubType("related");
			
			// 将MimeMultiPart发给MimeMessage
			message.setContent(mimeMultipart);
			// message.writeTo(System.out); // 将该邮件所包含的信息打印到控制台
	
			// 步骤三：Transport发送邮件
			Transport transport = session.getTransport();
			transport.connect("aaa", "111");
			transport.sendMessage(message, message.getAllRecipients());
		}

10. 包含附件的邮件 demo :

		// 携带附件邮件
		public void demo4() throws Exception {
			// 步骤一：创建Session
			Properties properties = new Properties();
			properties.put("mail.transport.protocol", "smtp");
			properties.put("mail.smtp.host", "localhost");
			properties.put("mail.smtp.auth", "true");// 连接认证
			properties.put("mail.debug", "true");// 在控制台显示连接日志信息
			Session session = Session.getInstance(properties);// 与邮件服务器连接会话
	
			// 步骤二：创建Message
			MimeMessage message = new MimeMessage(session);
			// 设置邮件头（简单邮件和复杂邮件相同
			message.setFrom(new InternetAddress("aaa@estore.com"));
			message.setRecipients(Message.RecipientType.TO, "bbb@estore.com");
			message.setSubject("javamail发送携带附件邮件");
			// 设置邮件体
			MimeBodyPart attachment = new MimeBodyPart();
			// 链接数据文件
			attachment.setDataHandler(new DataHandler(new FileDataSource(
					"大嘴巴 - maybe的机率.mp3")));

			// 因中文附件名编码的问题，会产生乱码，必须使用 JavaMail 提供的工具类 MimeUtility 来包装中文字符
			// 设置 filename 可自动生成： Content-Disposition:attachment;filename=xxx 
			attachment.setFileName(MimeUtility.encodeText("大嘴巴 - maybe的机率.mp3")); 
	
			MimeBodyPart content = new MimeBodyPart();
			content.setContent("<h1>附件是首好听的歌曲！</h1>", "text/html;charset=utf-8");
	
			MimeMultipart mimeMultipart = new MimeMultipart();
			mimeMultipart.addBodyPart(attachment);
			mimeMultipart.addBodyPart(content);
			mimeMultipart.setSubType("mixed");
	
			message.setContent(mimeMultipart);
	
			// 步骤三：Transport发送邮件
			Transport transport = session.getTransport();
			transport.connect("aaa", "111");
			transport.sendMessage(message, message.getAllRecipients());
		}

11. 既内嵌图片又包含附件的邮件 demo （工具类 MailUtils.java 见 第12 点）：

		// 编写最复杂一封邮件，既要内嵌图片，也要携带附件
		public void demo5() throws Exception {
			// 步骤一 创建Session
			Session session = MailUtils.createSession();
	
			// 步骤二 编写邮件Message
			MimeMessage message = new MimeMessage(session);
			// 设置邮件头（简单邮件和复杂邮件相同
			message.setFrom(new InternetAddress("aaa@estore.com"));
			message.setRecipients(Message.RecipientType.TO, "bbb@estore.com");
			message.setSubject("javamail发送最复杂邮件");
	
			// 设置邮件体
			MimeBodyPart pic = new MimeBodyPart();
			pic.setDataHandler(new DataHandler(new FileDataSource("beauty.jpg")));
			pic.setContentID("myimg");// 内嵌图片唯一标识
	
			MimeBodyPart attachment = new MimeBodyPart();
			attachment.setDataHandler(new DataHandler(new FileDataSource(
					"大嘴巴 - maybe的机率.mp3")));
			attachment.setFileName(MimeUtility.encodeText("大嘴巴 - maybe的机率.mp3"));// 附件解决中文路乱码
	
			MimeBodyPart content = new MimeBodyPart();
			content.setContent("<h1>最复杂邮件，有图片，有附件</h1>![](cid:myimg)",
					"text/html;charset=utf-8");
	
			// 整合
			MimeMultipart mp1 = new MimeMultipart();
			mp1.addBodyPart(pic);
			mp1.addBodyPart(content);
			mp1.setSubType("related");
	
			MimeBodyPart temp = new MimeBodyPart();// 将multipart转换bodypart可以和其它bodypart一起合并
			temp.setContent(mp1);
	
			MimeMultipart mp2 = new MimeMultipart();
			mp2.addBodyPart(attachment);
			mp2.addBodyPart(temp);
			mp2.setSubType("mixed");
	
			message.setContent(mp2);
	
			// 步骤三 发送邮件 Transport
			MailUtils.sendMail(session, message);
		}

12. MailUtils.java （抽出公共代码，编写成为一个工具类，很实用的思想）：

		public class MailUtils {
			private static String targetSMTP = "localhost";// SMTP服务器地址
			private static String user = "aaa"; // 发件账户
			private static String pass = "111"; // 发件密码
		
			// 创建邮件服务器链接会话
			public static Session createSession() {
				Properties properties = new Properties();
				properties.put("mail.transport.protocol", "smtp");
				properties.put("mail.smtp.host", targetSMTP);
				properties.put("mail.smtp.auth", "true");// 连接认证
				properties.put("mail.debug", "true");// 在控制台显示连接日志信息
				Session session = Session.getInstance(properties);// 与邮件服务器连接会话
		
				return session;
			}
		
			// 发送邮件
			public static void sendMail(Session session, Message message)
					throws Exception {
				Transport transport = session.getTransport();
				transport.connect(user, pass);
				transport.sendMessage(message, message.getAllRecipients());
			}
		}

##5、总结
- 至此，JavaMail 的基础知识就差不多写完了，通过学习 JavaMail ，可以了解电子邮件（E-Mail）的基本知识。

- 在使用 telnet 的时候，我想用我的 QQ 邮箱发邮件，测试一下能否成功，然而 QQ 邮箱的安全权限比较高，在第三方登陆的时候需要开通 POP3/SMTP 服务，而且每次第三方登陆的时候还需要一个验证码，这个验证码得去 QQ 邮箱（网页版）那里生成，而生成一次就需要验证密保，总之非常麻烦。

- 而用163邮箱的时候就不需要验证码，但是 SSL 加密时（端口465/587），总是会出现各种错误，不用 SSL 加密（端口25）就可以正常发送，

- 之前说过了 telnet 不能解决中文乱码问题，putty 可以，但是这两个工具的命令行终端都十分丑陋，而且打错了字后想要退格（Backspace），命令行终端上仍然显示之前字符，只是光标退格了而已，不知道怎么解决。顺便求推荐好用的终端工具 :)

- JavaMail 官网介绍： http://www.oracle.com/technetwork/java/javamail/index.html

- JavaMail 官方文档：http://www.oracle.com/technetwork/java/providers-150193.pdf

##6、MX 记录与 A 记录
- MX 与 A 记录(配置邮件服务器相关的信息)

- MX 记录：在 DNS 中进行注册，目的让其它服务器找到该服务器地址。

	- 查询 MX 记录
			
			> set type=mx
			> sina.com
			
			非权威应答:
			sina.com        MX preference = 5, mail exchanger = freemx1.sinamail.sina.com.cn
			
			sina.com        MX preference = 10, mail exchanger = freemx3.sinamail.sina.com.c
			n
			sina.com        MX preference = 10, mail exchanger = freemx2.sinamail.sina.com.c
			n

	- 从上面的非权威应答（ Non-authoritative answer ）中可以看到有3个 mx 记录，比如：
	
			freemx.sinamail.sina.com.cn
	
		然而它与 
	
			smtp.sina.com 
	
		有什么区别呢？

		- freemx.sinamail.sina.com.cn  DNS 中查询得到 MX 记录 （发信不需要登陆）
	
		- smtp.sina.com 从网站上获得地址 (发信需要先登陆)
	
	- 用处：但我们登陆 sina 邮箱，向 sohu 邮箱发邮件时，从图中可以看到，我们同时也要访问 sohu 的 smtp 服务器，然而我们是怎么知道 sohu 的 smtp 服务器的呢？这肯定是网络中有个东西在背后帮我们完成了，这个东西就是 MX 记录。

- A 记录：当别人以邮箱服务器身份连接不要认证的 mx 记录时候，需要从 DNS 中获得对方 A 记录，与来访者 IP 进行比较，进行身份验证。

	- 查询 A 记录

			set type=a
			sohu.com
			
			Non-authoritative answer:
			Name:    sohu.com
			Addresses:  61.135.181.175, 61.135.181.176

- 图解：

	![](http://upload-images.jianshu.io/upload_images/2106579-209d9bcc59537362.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- **总结：自己搭建一个邮件服务器，千万不要忘记去 DNS 上注册 MX 记录和 A 记录。**
