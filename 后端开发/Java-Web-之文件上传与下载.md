> 本文包括：
> 
> 1、文件上传概述
> 
> 2、利用 Commons-fileupload 组件实现文件上传
> 
> 3、核心API——DiskFileItemFactory
> 
> 4、核心API——ServletFileUpload
> 
> 5、核心API——FileItem
> 
> 6、拓展——使用 JavaScript 生成多个动态上传输入项
> 
> 7、文件上传的细节处理问题
> 
> 8、文件上传进度监听器——ProgressListener 
> 
> 9、文件下载概述
> 
> 10、深度优先搜索与广度优先搜索
> 
> 11、文件下载的细节处理问题

##1、文件上传概述
- 实现 web 开发中的文件上传功能，需完成如下两步操作：

	1. 在 jsp 页面中添加上传输入项
	
	2. 在servlet中读取上传文件的数据，并保存到服务器硬盘中

###第一步：

- 如何在 jsp 页面中添加上传输入项?
 
	- `<input type="file">`标签用于在 jsp 页面中添加文件上传输入项，设置文件上传输入项时须注意：

		1. 必须要设置 input 输入项的 name 属性，否则浏览器将不会发送上传文件的数据。
		
		2. 必须把 form 的 enctype 属性值设为 multipart/form-data 。其实 form 表单在你不写 enctype 属性时，也默认为其添加了 enctype 属性值，默认值是 `enctype="application/x- www-form-urlencoded"` 设置该值后，浏览器在上传文件时，将把文件数据附带在 http 请求消息体中，并使用 MIME 协议对上传的文件进行描述，以方便接收方对上传数据进行解析和处理。
		
			> 关于 MIME 协议请参考《Java Web之JavaMail》：http://www.jianshu.com/p/141c0f9b9c9e

		3. 表单的提交方式必须是post，因为上传文件可能较大。

			> get：以【明文】方式，通过URL提交数据，数据在URL中可以看到。提交数据最多不超过【2KB】。安全性较低，但效率比post方式高。适合提交数据量不大，且安全要求不高的数据：比如：搜索、查询等功能。
			> 
			> post：将用户提交的信息封装在HTML HEADER内，数据在URL中【不能看到】适合提交数据量大，安全性高的用户信息。如：注册、修改、上传等功能。
			> 
			> 区别：
			> 
			> 1. post隐式提交，get显式提交。
			> 
			> 2. post安全，get不安全。
			> 
			> 3. get提交数据的长度有限(255字符之内)，post无限。

	- 示例：

				<form action="xx.action" method="post" enctype="multipart/form-data">
	 			</form>

###第二步
- 如何在 Servlet 中读取文件上传数据，并保存到本地硬盘中?

	- Request 对象提供了一个 getInputStream 方法，通过这个方法可以读取到客户端提交过来的数据（具体来说是 http 的请求体 entity）。但由于用户可能会同时上传多个文件，在 Servlet 端编程直接读取上传数据，并分别解析出相应的文件数据是一项非常麻烦的工作。
	
	- 具体工作：假设我们获取了 http 的请求体，如何得到上传的文件呢？如图：左边是 http 的请求体，右边是步骤：

		![文件上传原理思想](http://upload-images.jianshu.io/upload_images/2106579-6d19e1e57c679d30.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

	- 我们来实际操作一下到底是怎么工作的：
		
		1. 首先我们先写个简单的JSP页面，代码如下：

				 <form action="/day20/upload" method="post" enctype="multipart/form-data">
				 	用户名 <input type="text" name="username"/><br/>
				 	上传文件 <input type="file" name="upload"/><br/>
				 	<input type="submit" name="submit" value="提交"/>
				 </form>
		2. 然后打开 Tomcat ，填写用户名，选择上传一个 md 文件，如下图所示：
	
			![](http://upload-images.jianshu.io/upload_images/2106579-58e63b7a97719dc1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

		3. md 文件内容如图所示：

			![](http://upload-images.jianshu.io/upload_images/2106579-b940c74db6326da1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

		4. 在 Servlet 中的代码如下：

				public class UploadServlet extends HttpServlet {
				
					public void doGet(HttpServletRequest request, HttpServletResponse response)
							throws ServletException, IOException {
						 request.setCharacterEncoding("utf-8");// 没法解决乱码，因为这是针对URL编码 解决乱码
						 // request提供 getInputStream方法，用来获得请求体信息
						 InputStream in = request.getInputStream();
						 int temp;
						 while ((temp = in.read()) != -1) {
						 System.out.write(temp);
						 }
						 System.out.flush();
						 in.close();
					}
				
					public void doPost(HttpServletRequest request, HttpServletResponse response)
							throws ServletException, IOException {
						doGet(request, response);
					}
				
				}

		5. 点击提交按钮，在控制台可以看到如下输出内容：

			<pre>
			------WebKitFormBoundaryRdlJBEfBAruajkfg
			Content-Disposition: form-data; name="username"
			
			edisonleolhl
			------WebKitFormBoundaryRdlJBEfBAruajkfg
			Content-Disposition: form-data; name="upload"; filename="milk.md"
			Content-Type: application/octet-stream
			
			|鍝佺墝|铔嬬櫧璐ㄥ惈閲忥紙g/100mL锛墊鑴傝偑鍚噺锛坓/100mL锛墊瑙勬牸|浠烽挶锛堝厓锛墊杩愯垂锛堝厓锛墊鎶樺悎姣忕洅鍗曚环锛堝厓/鐩掞級|鎶樺悎姣?00mL鍗曚环锛堝厓/100mL锛墊
			|---|---|---|---|---|---|---|---|
			|涓婅川 EULAUD娆у矚|3.3|3.5|200mL x 30|69|0|2.3|1.15|
			|Arla鐖辨皬鏅ㄦ洣|3.4|3.6|200ml x 24|49|6|2.29|1.15|
			|绾介害绂忥紙Meadow fresh锛墊3.5|3.5|250ml x 24|64.9|6|2.95|1.18|
			|缁寸函锛坴italife锛墊3.32|1.52|250ml x 24|49.9 + 6.65锛堢◣璐癸級|6|2.61|1.04|
			------WebKitFormBoundaryRdlJBEfBAruajkfg
			Content-Disposition: form-data; name="submit"
			
			鎻愪氦
			------WebKitFormBoundaryRdlJBEfBAruajkfg--
			</pre>
	
		6. 对照《文件上传原理思想》图，可以很清晰的找到上传的文件内容在 http 请求体中的位置。

##2、利用 Commons-fileupload 组件实现文件上传

- 为方便用户处理文件上传数据，Apache 开源组织提供了一个用来处理表单文件上传的一个开源组件（ Commons-fileupload ），该组件性能优异，并且其 API 使用极其简单，可以让开发人员轻松实现 web 文件上传功能，因此在 web 开发中实现文件上传功能，通常使用 Commons-fileupload 组件实现。

- 使用 Commons-fileupload 组件实现文件上传，需要导入该组件相应的支撑 jar 包： Commons-fileupload 和 commons-io。commons-io 不属于文件上传组件的开发 jar 文件，但 Commons-fileupload 组件从1.1 版本开始，它工作时需要 commons-io 包的支持。

	> Commons-fileupload 官网介绍&文档&下载：http://commons.apache.org/proper/commons-fileupload/
	> 
	> 注意：下载 jar 包时，请仔细阅读版本号与所需 JDK 版本之间的关系，比如 commons-io-2.5 最低要求 JDK 1.6+，这个 JDK 1.6+ 对应 JavaEE 6.0，也就是说在 MyEclipse 10 新建工程时，需要选择 JavaEE 6.0。

- 导入 jar 包后，在处理表单的 Servlet 中应该按如下步骤使用 API，**四个步骤很重要**：

	1. **创建 DiskFileItemFactory 对象，设置缓冲区大小和临时文件目录。**
	
	2. **使用 DiskFileItemFactory 对象创建 ServletFileUpload 对象，并设置上传文件的大小限制。**
	
	3. **调用 ServletFileUpload.parseRequest() 方法解析 request 对象，得到一个保存了所有上传内容的 List 对象。**
	
	4. **对 List 进行遍历，每遍历一个 FileItem 对象，调用其 FileItem.isFormField() 方法判断该对象是否是上传文件对象，该方法的返回值具体含义为：**
	
		- True 为普通表单字段，则调用 getFieldName() 获得 name 属性、getString() 方法获得 value 属性。
	
		- False 为上传文件，则调用 getInputStream() 方法得到文件内容、getName() 方法获得文件名。

			> 注意：对于得到的文件名，不同的浏览器有不同的结果，比如使用 IE 6 得到的文件名包含上传文件所在的原来客户端的路径，通用解决办法如下：
			
			>		String filename = fileItem.getName(); // 文件名
					// 解决老版本浏览器IE6 文件路径存在问题
					if (filename.contains("\\")) {
						filename = filename.substring(filename.lastIndexOf("\\")+ 1);
					}

##3、核心API——DiskFileItemFactory
- 在前文已经描述了处理表单的 Servlet 应该如何编写，其步骤的第一点就是要先创建一个 DiskFileItemFactory 对象，接下来就详细讲讲 DiskFileItemFactory 该怎么使用，首先创建对象：

		DiskFileItemFactory factory = new DiskFileItemFactory();

- DiskFileItemFactory 是创建 FileItem 对象的工厂，这个工厂类常用方法：

	- public DiskFileItemFactory(int sizeThreshold, java.io.File repository) ：构造函数
	
	- public void setSizeThreshold(int sizeThreshold) ：
	设置内存缓冲区的大小，默认值为 10K。当上传文件大于缓冲区大小时， fileupload 组件将使用临时文件缓存上传文件。

			// 设置缓冲区大小和临时目录
			factory.setSizeThreshold(1024 * 1024 * 8);// 8M 临时缓冲区（上传文件不大于8M
			// 不会产生临时文件）
	
	- public void setRepository(java.io.File repository) ：
	指定临时文件目录，默认值为 System.getProperty("java.io.tmpdir").

			File repository = new File(getServletContext().getRealPath(
					"/WEB-INF/tmp"));
			factory.setRepository(repository);// 当上传文件超过8M 会在临时目录中产生临时文件，临时文件与源文件内容相同。
	
	> 原理：上传文件优先保存内存缓冲区，当内存缓存区不够用，在硬盘上产生临时文件，临时文件保存指定临时文件目录中。
	> 临时文件耗费空间资源，应该在上传结束之后把 fileItem 删除。具体做法为：先关闭 FileItem 的输入流，再调用 FileItem.delete() 方法删除文件。

##4、核心API——ServletFileUpload
- 在步骤二中，通过 DiskFileItemFactory 对象创建 ServletFileUpload 对象。而ServletFileUpload 负责处理上传的文件数据，并将表单中每个输入项封装成一个 FileItem 对象中。

- 常用方法：

	- boolean isMultipartContent(HttpServletRequest request) ：
	判断表单是否为 multipart/form-data 类型（即判断表单是否含有上传文件项，项，如果没有，那当然就不用去考虑文件上传的事情），
	
	- List parseRequest(HttpServletRequest request) ：
	解析request对象，并把表单中的每一个输入项包装成一个fileItem 对象，并返回一个保存了所有FileItem的list集合。 
	
	- setFileSizeMax(long fileSizeMax) ：
	设置单个上传文件的最大值
	
	- setSizeMax(long sizeMax) ：
	设置上传文件总量的最大值
	
	- setHeaderEncoding(java.lang.String encoding) ：
	设置编码格式

		> 乱码解决问题一：默认情况下，上传文件名如果含有中文，则上传后的文件名会变成乱码，为了解决，必须在步骤二中调用该方法，并把编码格式设置 " utf-8"。

		>		ServletFileUpload.upload.setHeaderEncoding("utf-8");

	- **setProgressListener(ProgressListener pListener) ：
	实时监听文件上传状态，典型应用是文件上传的进度条（重难点）**

##5、核心API——FileItem
- 在步骤二中，ServletFileUpload 的作用是将表单的每个输入项封装成一个 FileItem 对象，这里就着重讲讲 FileItem 要怎么用。

- 常用方法：

	- isFormField() ：是否为文件上传域，true不是文件上传，false是文件上传 
	
	- （对于非文件上传域）getFieldName ：获得表单的 name 属性
	
	- （对于非文件上传域）getString ：获得表单中该输入项的值（value） 

		> 乱码解决问题二：文件上传表单中request.setCharacterEncoding 不能使用，同样 request.getParameter 不能使用，所以如果表单某个输入框中有中文，要解决乱码问题，可以传入一个编码类型的参数：
			
		>		String value = fileItem.getString("utf-8"); // 得到某个表单输入项的值

	- （对于文件上传域）getName ：获得文件名
	
	- （对于文件上传域）getInputStream ： 获得文件内容

##6、拓展——使用 JavaScript 生成多个动态上传输入项
- 功能需求：每次动态增加一个文件上传输入框，都把它和删除按纽放置在一个单独的 div 中，并对删除按纽的 onclick 事件进行响应，使之删除删除按纽所在的 div 。

- 代码：

		this.parentNode.parentNode.removeChild(this.parentNode);
	
		<%@ page language="java" contentType="text/html; charset=UTF-8"
			pageEncoding="UTF-8"%>
		<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
		<html>
		<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>Insert title here</title>
		<script type="text/javascript">
			function addAttach() {
				// 在div中添加 文件上传框
				var attachments = document.getElementById("attachments");
				attachments.innerHTML += "<div><input type='file' /><input type='button' value='删除' onclick='delAttach(this);' /></div>";
			}
		
			function delAttach(btn) {
				// 传入参数 当前点击按钮
				//alert(btn.nodeName);
		
				// 先获得删除 div
				var wantDelDiv = btn.parentNode;
		
				// 用要删除div找到父亲，杀死
				wantDelDiv.parentNode.removeChild(wantDelDiv);
		
			}
		</script>
		</head>
		<body>
			<!-- JS 编写动态文件上传框 -->
			<input type="button" value="添加附件" onclick="addAttach();" />
			<div id="attachments"></div>
		</body>
		</html>

- 效果：

	![](http://upload-images.jianshu.io/upload_images/2106579-adfd941280d79a30.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##7、文件上传的细节处理问题
- 乱码问题

	- 上传文件名乱码：servletFileupload.setHeaderEncoding("utf-8") —— 乱码解决问题一

	- 表单普通项乱码：fileItem.getString("utf-8") —— 乱码解决问题二

- 临时文件删除

	必须先关闭 FileItem 的输入流，再调用 FileItem.delete ()方法 删除临时文件。

- 上传文件保存目录

	首先应该明白一个概念：web 工程中 WEB-INF 在浏览器端不允许通过 URL 直接访问。

	- WEB-INF内 ：必须通过服务器端程序去访问，Servlet ---- getRealPath(/WEB-INF) ---------------- 需要权限，需要身份认证
	
	- WEB-INF外 ：浏览器直接通过URL访问  ------------------ 任何人都可以访问

	- 思考：假设有个电影会员点播网站，可以付费在线看电影。那么上传电影应该放到哪里？ 答案：WEB-INF 里面，客户端不能直接访问。再分析：淘宝里的商家上传商品图片，商品图片应该放在哪里？答案： WEB-INF 外面，客户端可以直接访问。

- 文件覆盖

	假设客户端上传的所有文件都放到同一个目录中，当文件名重名时，会发生文件覆盖，如何解决？答案：文件名唯一。

		// 保证上传文件名唯一
		filename = UUID.randomUUID().toString() + filename;

- 多目录分散

	当上传文件很多时，如果不对文件分散到不同目录去，那就会集中在同一个目录中，这样访问某个文件需要很长时间，甚至不响应，查找困难，所以应该采用目录分散算法，有如下几种目录分散算法：

	- 按时间 —— 比如一天一个目录
		
	- 按用户 —— 比如淘宝某个商家上传的所有商品图片都放在一个单独目录
		
	- 每个目录存放固定数量文件 —— 每个目录存放1000个文件，每次上传文件时判断目录中文件是否超过1000，若超过则新建一个目录，保存在新目录中
		
	- **哈希目录分散算法** —— 对于一个对象，它会有一个 32 位的 hashcode ，这个 hashcode 通过一定的哈希算法生成，允许重复。把 32 位的 hashcode 分成 `4*8`，每次与 1111 进行“位与”运算，得到一个 4 位的值（0~15），然后右移 4 位，继续“位与”运算，每右移一次，目录就会增加一个层级，可根据不同的业务要求决定具体的目录层级数目，对于小型项目而言，2 级目录即可满足需求（总共有`(2^4)^2=256`个文件夹）。具体如图所示：
		
		![](http://upload-images.jianshu.io/upload_images/2106579-9615b86ffadd831f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

		对于图中数据来说，它的 1 级目录号为 12，它 2 级目录号为 14，故这个文件位于12号文件夹的14号文件夹里面。

		- 可编写一个工具类：
 
				public class UploadUtils {
					// 获得随机目录
					public static String generateRandomPath(String fileName) {
						int hashcode = fileName.hashCode();
						int d1 = hashcode & 0xf;
						int d2 = (hashcode >> 4) & 0xf;
						return "/" + d1 + "/" + d2;
					}
				}

		- 然后在 Servlet 中这样调用：

				// 生成随机目录
				String randomPath = UploadUtils
						.generateRandomPath(filename);// 生成目录不一定存在 ---创建
				File path = new File(getServletContext().getRealPath(
								"/WEB-INF/upload" + randomPath));
				path.mkdirs();

##8、文件上传进度监听器——ProgressListener 
- 官方API ： public interface ProgressListener -- The ProgressListener may be used to display a progress bar or do stuff like that.

- 最重要的 update 方法： 

		void update(long pBytesRead,
            long pContentLength,
            int pItems)
 -- Updates the listeners status information.

	Parameters:
	
	- pBytesRead - The total number of bytes, which have been read so far.
	
	- pContentLength - The total number of bytes, which are being read. May be -1, if this number is unknown.
	
	- pItems - The number of the field, which is currently being read. (0 = no item so far, 1 = first item is being read, ...)

- 使用代码：

			// 设置文件上传监听器
			ProgressListener listener = new ProgressListener() {
				
				// 在文件上传过程中，文件上传程序，会自动调用update方法，而且不只一次调用，通过该方法，获得文件上传进度信息
				// pBytesRead 已经上传字节数量
				// pContentLength 上传文件总大小
				// pItems 表单项中第几项
				public void update(long pBytesRead, long pContentLength,
						int pItems) {
					System.out.println("上传文件总大小：" + pContentLength + "，已经上传大小："
							+ pBytesRead + ", form第几项：" + pItems);
				}
			};

- 为了更友好的用户体验，页面应该实时显示上传的速度、剩余时间甚至用进度条美化。接下来就探讨一下如何实现，稍微思考下可以得到下面两个公式，其中`已经使用时间=现在时间-起始时间`。

	- `平均传输速率 = 已经上传大小/已经使用时间`;
	
	- `剩余时间 = 剩余大小/平均传输速率`;

	- 于是在步骤二中，这样编写代码：

			// 步骤二 获得解析器
			ServletFileUpload upload = new ServletFileUpload(factory);
			final long start = System.currentTimeMillis();

			// 设置文件上传监听器
			ProgressListener listener = new ProgressListener() {
				// 在文件上传过程中，文件上传程序，会自动调用update方法，而且不只一次调用，通过该方法，获得文件上传进度信息
				// pBytesRead 已经上传字节数量
				// pContentLength 上传文件总大小
				// pItems 表单项中第几项
				public void update(long pBytesRead, long pContentLength,
						int pItems) {
					System.out.println("上传文件总大小：" + pContentLength + "，已经上传大小："
							+ pBytesRead + ", form第几项：" + pItems);
					// 通过运算获得其它必要信息：传输速度、剩余时间
					long currentTime = System.currentTimeMillis();
					// 已经使用时间
					long hasUseTime = currentTime - start;
					// 速率
					// 字节/毫秒 = x/1024*1000 KB/S
					long speed = pBytesRead / hasUseTime;
					// 剩余时间
					long restTime = (pContentLength - pBytesRead) / speed;// 毫秒
					System.out.println("传输速度：" + speed + "字节每毫秒，剩余时间"
							+ restTime + "毫秒");
					try {
						Thread.sleep(1);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			};
			upload.setProgressListener(listener); // 注册监听器

	- 当然，这里考虑的是平均传输速度，也可以改为瞬时传输速度：每过一秒，计算在这一秒中上传的字节。

##9、文件下载概述

- web 应用中实现文件下载的两种方式：

	- 方式一：超链接直接指向下载资源
 
		这时将使用 DefaultServlet ，它会将资源返回，如果浏览器对该资源不支持直接打开（比如说 Excel 文档），则会询问用户是否下载，如果浏览器识别下载文件格式，则会自动打开（比如说图片）
	
	- 方式二：编写程序实现下载，这时这时需设置两个响应头，需要要符合 Mime 协议
	
		设置 Content-Type 的值为：下载文件所对应 MIME 类型、	web 服务器希望浏览器不直接处理相应的实体内容，而是由用户选择将相应的实体内容保存到一个文件中，这就需要设置 Content-Disposition （以附件形式传输），在设置 Content-Dispostion 之前一定要指定 Content-Type。

		注意：ServletContext.getMimeType(file) 可以得到下载资源所对应的 Mime 类型，你也可以在 tomcat/conf/web.xml 文件中查询各种 MIME 类型。

			// 获得客户端提交file 参数
			String file = request.getParameter("file");
			// 下载文件，从服务器端读取文件，将文件内容写回客户端
			String serverFilePath = getServletContext().getRealPath(
					"/download/" + file);
			
			// 设置响应头，等效于于 response.setHeader("Content-Type",getServletContext().getMimeType(file));
			response.setContentType(getServletContext().getMimeType(file));// 根据文件扩展名获得MIME类型

			response.setHeader("Content-Disposition", "attachment;filename=" + file);// 以附件下载

	- 方式二的代码实现：

		- jsp 页面：

				<%@ page language="java" contentType="text/html; charset=UTF-8"
				    pageEncoding="UTF-8"%>
				<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
				<html>
				<head>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
				<title>Insert title here</title>
				</head>
				<body>
				<h1>使用链接方式实现资源下载</h1>
				<a href="/day20/download/1.jpg">1.jpg</a><br/>
				<a href="/day20/download/2.xls">2.xls</a><br/>
				<a href="/day20/download/3.rar">3.rar</a><br/>
				<a href="/day20/download/4.txt">4.txt</a><br/>
				<h1>通过Servlet完成资源下载</h1>
				<a href="/day20/downloadFile?file=1.jpg">1.jpg</a><br/>
				<a href="/day20/downloadFile?file=2.xls">2.xls</a><br/>
				<a href="/day20/downloadFile?file=3.rar">3.rar</a><br/>
				<a href="/day20/downloadFile?file=4.txt">4.txt</a><br/>
				</body>
				</html>

		- Servlet ：

				public class DownloadFileServlet extends HttpServlet {
					public void doGet(HttpServletRequest request, HttpServletResponse response)
							throws ServletException, IOException {
						// 获得客户端提交file 参数
						String file = request.getParameter("file");
						// 下载文件，从服务器端读取文件，将文件内容写回客户端
						String serverFilePath = getServletContext().getRealPath(
								"/download/" + file);
				
						// 设置响应头
						response.setContentType(getServletContext().getMimeType(file));// 根据文件扩展名获得MIME类型
						// 等级于 response.setHeader("Content-Type",xxx);
						response
								.setHeader("Content-Disposition", "attachment;filename=" + file);// 以附件下载
				
						InputStream in = new BufferedInputStream(new FileInputStream(
								serverFilePath));
						// 需要浏览器输出流
						OutputStream out = response.getOutputStream();
						int temp;
						while ((temp = in.read()) != -1) {
							out.write(temp);
						}
						out.close();
						in.close();
					}
				
					public void doPost(HttpServletRequest request, HttpServletResponse response)
							throws ServletException, IOException {
						doGet(request, response);
					}
				}

##10、深度优先搜索与广度优先搜索
- 目录就是树形结构，根目录代表根节点，每个子节点代表一个子目录，直到端节点，端节点就代表各种文件。在遍历树形结构时，有两种主要方法，深度优先搜索(depth first search)与广度优先搜索（breadth first search)。其区别如图所示：

	![](http://upload-images.jianshu.io/upload_images/2106579-d80fd06202b835ee.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 假设现在有个需求：将某目录中所有 mp3 文件显示在浏览器上，并提供下载功能，而这些 mp3 文件可能在不同的子目录下，这时要怎么做呢？

- 若想实现广度优先搜索，这时可利用 LinkedList 来解决问题，jsp 文件如下：

		<%@ page language="java" contentType="text/html; charset=UTF-8"
		    pageEncoding="UTF-8"%>
		<%@page import="java.util.LinkedList"%>
		<%@page import="java.io.File"%>
		<%@page import="java.net.URLEncoder"%>
		<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
		<html>
		<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>Insert title here</title>
		</head>
		<body>
		<h1>文件下载列表</h1>
		<!-- 将D:\CloudMusic 中所有音乐文件，显示列表，允许用户下载 -->
		<%
			// 遍历指定目录 --- 非递归广度
			File root = new File("D:\\CloudMusic");
		    LinkedList<File> list = new LinkedList<File>();// 存储
		    list.add(root);// 集合中存在一个目录
		    
		    while(!list.isEmpty()){
		    	// 集合不为空
		    	File currentDir = list.removeFirst();// 返回目录对象
		    	File[] files = currentDir.listFiles();// 获得目录下所有文件
		    	for(File f : files){
		    		if(f.isDirectory()){
		    			// 将未遍历目录 加入集合
		    			list.add(f);
		    		}else{
		    			// 是一个文件
		    			// get 、post 提交中文，使用URL编码
		    			String args = URLEncoder.encode(f.getCanonicalPath(),"utf-8");// 这个本来是浏览器默认动作，只是手动执行
		    			out.println("<a href='/day20/downloadMusic?path="+args+"'>"+f.getName()+"</a><br/>");
		    		}
		    	}
		    }
		%>
		</body>
		</html>

##11、文件下载的细节处理问题
- 为了获得服务器的资源，应该提供资源的绝对磁盘路径，这里有两种方式：

	- File.getAbsolutePath() --返回此抽象路径名的绝对路径名字符串，**不唯一**。
	
	- FIle.getCanonicalPath() -- 返回返回此抽象路径名的**规范路径**名字符串，**唯一**。

	- 通过比较可以发现，下面一种写法更加符合规范，推荐使用。

- 请求的乱码问题

	在深度优先搜索的 jsp 示例中，注意如下的写法：

		String args = URLEncoder.encode(f.getCanonicalPath(),"utf-8");

	意义：get、post 方式访问，会使用 URL 编码，而目录有可能含有中文，如果不进行 utf-8 编码，则可能会根据不同的浏览器而报错。

- 响应的乱码问题

	在文件下载时，点击链接会弹出下载框，如果不进行处理，则资源名存在乱码问题，在本文的《9、文件下载概述》中有如下代码：

        // 设置响应头
        response.setContentType(getServletContext().getMimeType(file));// 根据文件扩展名获得MIME类型
        // 等级于 response.setHeader("Content-Type",xxx);
        response
                .setHeader("Content-Disposition", "attachment;filename=" + file);// 以附件下载

	**注意：不同的浏览器对于响应的编码方式有所不同，比如 IE 采用 URL 编码，火狐采用该 base64 编码。**

	再思考，如何根据不同的浏览器选择合适的编码方式呢？很显然，只要我们知道了当前客户端是什么浏览器就可以 if - else 判断，然后执行不同的编码方式。

	答案：在请求的头信息中，两个浏览器在 User-Agent 中有不同的值，IE 浏览器多了 MSIE 这个信息，IE 和火狐都有 Mozilla 这个信息，所以可以做如下判断（这段代码可重用）：

		String agent = request.getHeader("User-Agent");
		if (agent.contains("MSIE")) {
			// IE 浏览器 采用URL编码
			filename = URLEncoder.encode(filename, "utf-8");
			response.setHeader("Content-Disposition", "attachment;filename="
					+ filename);
		} else if (agent.contains("Mozilla")) {
			// 火狐浏览器 采用Base64编码
			// filename = MimeUtility.encodeText(filename);// 调用这个方法时，如果参数为全英文，则不编码，所以不能简单调用该方法，应该如下手动编码
			BASE64Encoder base64Encoder = new BASE64Encoder();
			filename = "=?UTF-8?B?"
					+ new String(base64Encoder.encode(filename
							.getBytes("UTF-8"))) + "?=";

			response.setHeader("Content-Disposition", "attachment;filename="
					+ filename);
		} else {
			// 默认 不编码
			response.setHeader("Content-Disposition", "attachment;filename="
					+ filename);
		}
