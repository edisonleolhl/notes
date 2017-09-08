#HTML基础
---
>本文包括
>
1. HTML基本知识与结构
2. HTML常见标签
3. 标签写法与嵌套的讨论

###HTML、CSS、javascript三者的关系
1. HTML是网页内容的载体。内容就是网页制作者放在页面上想要让用户浏览的信息，可以包含文字、图片、视频等。

2. CSS样式是表现。就像网页的外衣。比如，标题字体、颜色变化，或为标题加入背景图片、边框等。所有这些用来改变内容外观的东西称之为表现。

3. JavaScript是用来实现网页上的特效效果。如：鼠标滑过弹出下拉菜单。或鼠标滑过表格的背景颜色改变。还有焦点新闻（新闻图片）的轮换。可以这么理解，有动画的，有交互的一般都是用JavaScript来实现的。

>### <!DOCTYPE HTML> ###
>指示 web 浏览器关于页面使用哪个 HTML 版本进行编写,必须写在所有代码的第一行!
如果你的页面添加了<!DOCTYPE html>，那么就等同于开启了标准模式，那么浏览器就得老老实实的按照W3C的标准解析渲染页面，这样一来，你的页面在所有的浏览器里显示的就都是一个样子了。
这个属性会被浏览器识别并使用，但是如果你的页面没有DOCTYPE的声明，浏览器按照自己的方式解析渲染页面，那么，在不同的浏览器就会显示不同的样式。
这就是<!DOCTYPE html>的作用。

###文件固定结构
结构如下：

    <html>
        <head>...</head>
        <body>...</body>
    </html>

代码讲解：

1. `<html></html>`称为根标签，所有的网页标签都在<html></html>中。

2. <head> 标签用于定义文档的头部，它是所有头部元素的容器。头部元素有`<title>、<script>、 <style>、<link>、 <meta>`等标签，头部标签在下一小节中会有详细介绍。

3. 在<body>和</body>标签之间的内容是网页的主要内容，如`<h1>、<p>、<a>、<img>`等网页内容标签，在这里的标签中的内容会在浏览器中显示出来。

4. 为 html 文档加上使用的语言类型说明
在很多国际化的网站中会使用到！
        <html lang="zh-CN">
        </html>
告诉浏览器等设备，语言使用以中文为显示和阅读基础!
英文使用 en 

###head标签
下面我们来了解一下<head>标签的作用。文档的头部描述了文档的各种属性和信息，包括文档的标题等。绝大多数文档头部包含的数据都不会真正作为内容显示给读者。

下面这些标签可用在 head 部分：

    <head>
        <title>...</title>
        <meta>
        <link>
        <style>...</style>
        <script>...</script>
    </head>

1. `<title>`标签：在`<title>`和`</title>`标签之间的文字内容是网页的标题信息，它会出现在浏览器的标题栏中。网页的title标签用于告诉用户和搜索引擎这个网页的主要内容是什么，搜索引擎可以通过网页标题，迅速的判断出网页的主题。每个网页的内容都是不同的，每个网页都应该有一个独一无二的title。

###meta标签
- meta是html中的元标签，其中包含了对应html的相关信息，客户端浏览器或服务器端的程序会根据这些信息进行处理。
- HTTP-EQUIV类似于HTTP的头部协议，它回应给浏览器一些有用的信息，以帮助正确和精确地显示网页内容。
- content（内容类型）：重要！！这个网页的格式是文本的，网页模式
- charset（编码）：特别重要！！！这个网页的编码是utf-8，中文编码，需要注意的是这个是网页内容的编码，而不是文件本身的，其他类型的编码中文可能会出现乱码。
1. http-equiv="Content-Type" 表示描述文档类型
content="text/HTML;  文档类型，这里为html,如果JS就是text/javascript，
charset=utf-8 页面字符集，编码，eg:gb2312,iso-8859-1,utf-8
2. meta标签
meta是html语言head区的一个辅助性标签。几乎所有的网页里，我们可以看到类似下面这段的html代码：
        　<head> 
        　　<meta http-equiv="content-Type" content="text/html; charset=gb2312">
        　</head>
也许你认为这些代码可有可无。其实如果你能够用好meta标签，会给你带来意想不到的效果，例如加入关键字会自动被大型搜索网站自动搜集；可以设定页面格式及刷新等等。
3. meta标签的组成 
meta标签共有两个属性，它们分别是http-equiv属性和name属性，不同的属性又有不同的参数值，这些不同的参数值就实现了不同的网页功能。 
    1. name属性 
　　    name属性主要用于描述网页，与之对应的属性值为content，content中的内容主要是便于搜索引擎机器人查找信息和分类信息用的。 
　　    meta标签的name属性语法格式是：
            <meta name="参数" content="具体的参数值"> 。 
　　其中name属性主要有以下几种参数： 
　　A、Keywords(关键字) 
　　说明：keywords用来告诉搜索引擎你网页的关键字是什么。 
　　举例：
            <meta name ="keywords" content="science, education,culture,politics,ecnomics，relationships, entertaiment, human"> 
　　B、description(网站内容描述) 
　　说明：description用来告诉搜索引擎你的网站主要内容。 
　　举例：
            <meta name="description" content="This page is about the meaning of science, education,culture."> 
　　C、robots(机器人向导) 
　　说明：robots用来告诉搜索机器人哪些页面需要索引，哪些页面不需要索引。 
　　content的参数有all,none,index,noindex,follow,nofollow。默认是all。 
　　举例：
            <meta name="robots" content="none"> 
　　D、author(作者) 
　　说明：标注网页的作者 
　　举例：
            <meta name="author" content="root,root@21cn.com">
    2. http-equiv属性 
　　http-equiv顾名思义，相当于http的文件头作用，它可以向浏览器传回一些有用的信息，以帮助正确和精确地显示网页内容，与之对应的属性值为content，content中的内容其实就是各个参数的变量值。 
　　meta标签的http-equiv属性语法格式是：
            <meta http-equiv="参数" content="参数变量值"> 
    其中http-equiv属性主要有以下几种参数： 
　　A、Expires(期限) 
　　说明：可以用于设定网页的到期时间。一旦网页过期，必须到服务器上重新传输。 
　　用法：
            <meta http-equiv="expires" content="Fri, 12 Jan 2001 18:18:18 GMT"> 
　　注意：必须使用GMT的时间格式。 
　　B、Pragma(cache模式) 
　　说明：禁止浏览器从本地计算机的缓存中访问页面内容。 
　　用法：
            <meta http-equiv="Pragma" content="no-cache"> 
　　注意：这样设定，访问者将无法脱机浏览。 
　　C、Refresh(刷新) 
　　说明：自动刷新并指向新页面。 
　　用法：
            <meta http-equiv="Refresh" content="2;URL=http://www.root.net">(注意后面的引号，分别在秒数的前面和网址的后面) 
　　注意：其中的2是指停留2秒钟后自动刷新到URL网址。 
　　D、Set-Cookie(cookie设定) 
　　说明：如果网页过期，那么存盘的cookie将被删除。 
　　用法：
            <meta http-equiv="Set-Cookie" content="cookievalue=xxx; expires=Friday, 12-Jan-2001 18:18:18 GMT； path=/"> 
　　注意：必须使用GMT的时间格式。 
　　E、Window-target(显示窗口的设定) 
　　说明：强制页面在当前窗口以独立页面显示。 
　　用法：
            <meta http-equiv="Window-target" content="_top"> 
　　注意：用来防止别人在框架里调用自己的页面。 
　　F、content-Type(显示字符集的设定) 
　　说明：设定页面使用的字符集。 
　　用法：
            <meta http-equiv="content-Type" content="text/html; charset=gb2312"> 
　　G、content-Language（显示语言的设定） 
　　用法：
            <meta http-equiv="Content-Language" content="zh-cn" />
4. meta标签的功能
1、帮助主页被各大搜索引擎登录；
2、定义页面的使用语言
3、自动刷新并指向新的页面
4、实现网页转换时的动画效果
5、控制页面缓冲
6、控制网页显示的窗口

###style中的属性
font-size:数值px; 文字大小控制
color:#六进制的颜色值; 文字颜色控制
text-align:left/center/right; 文字的居左、居中、居右控制。

### 关于单双引号、转义字符等基本知识 ###
[纯html标签下单引号和双引号以及html和JS混编下单引号和双引号](http://blog.csdn.net/jielione/article/details/8007875)

###标题标签
文章的段落用`<p>`标签，那么文章的标题用什么标签呢？在本节我们将使用`<hx>`标签来制作文章的标题。
标题标签一共有6个，h1、h2、h3、h4、h5、h6分别为一级标题、二级标题、三级标题、四级标题、五级标题、六级标题。并且依据重要性递减。`<h1>`是最高的等级。
语法：
`<hx>标题文本</hx>` (x为1-6)
文章的标题前面已经说过了，可以使用标题标签，另外网页上的各个栏目的标题也可使用它们。
例如：

    <body>
        <h1>一级标题</h1>
        <h2>二级标题</h2>
        <h3>三级标题</h3>
        <h4>四级标题</h4>
        <h5>五级标题</h4>
    </body>

### HTML注释 ###
代码注释的作用是帮助程序员标注代码的用途，过一段时间后再看你所编写的代码，就能很快想起这段代码的用途。代码注释不仅方便程序员自己回忆起以前代码的用途，还可以帮助其他程序员很快的读懂你的程序的功能，方便多人合作开发网页代码。    
    
    <!--注释文字 -->

###语义化
标签的用途：我们学习网页制作时，常常会听到一个词，语义化。那么什么叫做语义化呢，说的通俗点就是：明白每个标签的用途（在什么情况下使用此标签合理）比如，网页上的文章的标题就可以用标题标签，网页上的各个栏目的栏目名称也可以使用标题标签。文章中内容的段落就得放在段落标签中，在文章中有想强调的文本，就可以使用 em 标签表示强调等等。

讲了这么多语义化，但是语义化可以给我们带来什么样的好处呢？

1. 更容易被搜索引擎收录。

2. 更容易让屏幕阅读器读出网页内容。

在后面的章节会带领大家学习了解html中每个标签的语义（用途）。

#常见标签
---
1. 段落标签`<p>`
    -  `<p>`标签的默认样式，段前段后都会有空白，如果不喜欢这个空白，可以用css样式来删除或改变它。
    -  改变CSS样式删除段前段后空白处。
  
             <style>
            p{margin:0px;}
            </style>

2. 斜体标签`<em>`

        <em>斜体</em>

3. 粗体标签`<strong>`

        <strong>加粗</strong>

4. `<span> `标签
被用来组合文档中的行内元素。使用 `<span>` 来组合行内元素，以便通过样式来格式化它们。
`<span>` 在CSS定义中属于一个行内元素,在行内定义一个区域，也就是一行内可以被 `<span> `划分成好几个区域，从而实现某种特定效果。 
`<span> `本身没有任何属性。 
`<div> `在CSS定义中属于一个块级元素` <div> `可以包含段落、标题、表格甚至其它部分。这使DIV便于建立不同集成的类，如章节、摘要或备注。在页面效果上，使用` <div>` 会自动换行，使用` <span>` 就会保持同行。
例如：

          <style>
             span{
            color:blue;
            }
         </style>
这样，`<span>`标签包含的文本就变成了蓝色的字体。

5. `<q>`标签
作用：段文本引用
例如：
`<p>`最初知道庄子，是从一首诗`<q>`庄生晓梦迷蝴蝶。望帝春心托杜鹃。`</q>`开始的。虽然当时不知道是什么意思，只是觉得诗句挺特别。后来才明白这个典故出自是庄子的《逍遥游》，《逍遥游》代表了庄子思想的最高境界，是对世俗社会的功名利禄及自己的舍弃。`</p>`
在上面的例子中，“庄生晓梦迷蝴蝶。望帝春心托杜鹃。” 这是一句诗歌，出自晚唐诗人李商隐的《锦瑟》 。因为不是作者自己的文字，所以需要使用`<q></q>`实现引用。
注意要引用的文本不用加双引号，浏览器会对q标签自动添加双引号。
这里用`<q>`标签的真正关键点不是它的默认样式双引号（如果这样我们不如自己在键盘上输入双引号就行了），而是它的**语义**：引用别人的话。
>补充知识：语义化网页结构有助于搜索引擎的收录。同一个效果可以用很多钟方式实现，但这只方便了浏览者，而搜索引擎不知道这里到底是什么内容，这里如果你使用<q>标签，那么就告诉浏览器这里是引用的话。而且在手持设备或移动设备不能很好支持css的基础上，浏览器会使用默认的效果，因而提供较好可读性。

6. `<blockquote>`标签
作用：长文本引用
例如：
`<blockquote>`明月出天山，苍茫云海间。长风几万里，吹度玉门关。汉下白登道，胡窥青海湾。由来征战地，不见有人还。 戍客望边色，思归多苦颜。高楼当此夜，叹息未应闲。`</blockquote>`
>注意：浏览器对`<blockquote>`标签的解析是缩进样式

7. `<br>`标签
怎么可以让每一句诗词后面加入一个折行呢？那就可以用到`<br />`标签了，在需要加回车换行的地方加入`<br />`，`<br />`标签作用相当于word文档中的回车。 
语法：
xhtml1.0写法：
        <br />
html4.01写法：
        <br>
现在一般使用 xhtml1.0 的版本的写法（其它标签也是），**这种版本比较规范。**
与以前我们学过的标签不一样，`<br />`标签是一个空标签，没有HTML内容的标签就是空标签，空标签只需要写一个开始标签，这样的标签有`<br />`、`<hr />`和`<img />`。
讲到这里，你是不是有个疑问，想折行还不好说嘛，就像在 word 文件档或记事本中，在想要折行的前面输入回车不就行了吗？很遗憾，在 html 中是忽略回车和空格的，你输入的再多回车和空格也是显示不出来的。

8. `<hr>`标签
在信息展示时，有时会需要加一些用于分隔的横线，这样会使文章看起来整齐些。
语法：
html4.01版本 
`<hr>`
xhtml1.0版本 
`<hr />`
> 注意：
> 1. `<hr />`标签和`<br />`标签一样也是一个空标签，所以只有一个开始标签，没有结束标签。
> 2. `<hr />`标签的在浏览器中的默认样式线条比较粗，颜色为灰色，可能有些人觉得这种样式不美观，没有关系，这些外在样式在我们以后学习了css样式表之后，都可以对其修改。
> 
> 3. 大家注意，现在一般使用 xhtml1.0 的版本（其它标签也是），**这种版本比较规范**。

9. `<address>`标签
一般网页中会有一些网站的联系地址信息需要在网页中展示出来，这些联系地址信息如公司的地址就可以`<address>`标签。也可以定义一个地址（比如电子邮件地址）、签名或者文档的作者身份。
语法：
    `<address>`联系地址信息`</address>`
如：
`<address>`文档编写：lilian 北京市西城区德外大街10号`</address>`

10. `<code>`标签
在介绍语言技术的网站中，避免不了在网页中显示一些计算机专业的编程代码，当代码为一行代码时，你就可以使用`<code>`标签了，如下面例子：
        <code>var i=i+300;</code>
注意：在文章中一般如果要插入多行代码时不能使用`<code>`标签了。
语法：
`<code>`代码语言`</code>`
>注：如果是多行代码，可以使用`<pre>`标签。

11. `<pre>`标签
主要作用:预格式化的文本。被包围在 pre 元素中的文本通常会保留空格和换行符。
语法：
    `<pre>`语言代码段`</pre>`
如下代码：

        <pre>
            var message="欢迎";
            for(var i=1;i<=10;i++)
            {
                alert(message);
            }
        </pre>
效果如下：
    ![](http://upload-images.jianshu.io/upload_images/2106579-84a8d5b6fee5e05e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    >注意：`<pre>` 标签不只是为显示计算机的源代码时用的，在你需要在网页中预显示格式时都可以使用它，只是`<pre>`标签的一个常见应用就是用来展示计算机的源代码。

12. `<ul>`标签
ul-li是没有前后顺序的信息列表。
    - 语法：
    
            <ul>
              <li>信息</li>
              <li>信息</li>
               ......
            </ul>
    - 举例：
    
            <ul>
              <li>精彩少年</li>
              <li>美丽突然出现</li>
              <li>触动心灵的旋律</li>
            </ul>

    - ul-li在网页中显示的默认样式一般为：每项li前都自带一个圆点
        - 这样是空心圆，
                ul{
                    list-style:circle;
               }
        - 这个就是去除前面的点
                ul{
                    list-style:none
                }

13. `<ol>`标签
ol-li是有前后顺序的信息列表
    - 语法：
        
            <ol>
               <li>信息</li>
               <li>信息</li>
               ......
            </ol>
    - 举例：
    
            <ol>
               <li>前端开发面试心法 </li>
               <li>零基础学习html</li>
               <li>JavaScript全攻略</li>
            </ol>
    `<ol>`在网页中显示的默认样式一般为：每项`<li>`前都自带一个序号，序号默认从1开始。

14. `<div>`标签
    - `<div>` 可定义文档中的分区或节（division/section）。
    - `<div> `标签可以把文档分割为独立的、不同的部分。它可以用作严格的组织工具，并且不使用任何格式与其关联。
    - 如果用 id 或 class 来标记 `<div>`，那么该标签的作用会变得更加有效。
    - `<div> `是一个块级元素。这意味着它的内容自动地开始一个新行。实际上，换行是 `<div> `固有的唯一格式表现。可以通过` <div>` 的 class 或 id 应用额外的样式。不必为每一个 `<div>` 都加上类或 id，虽然这样做也有一定的好处。
    - 可以对同一个 `<div> `元素应用 class 或 id 属性，但是更常见的情况是只应用其中一种。这两者的主要差异是，**class 用于元素组**（类似的元素，或者可以理解为某一类元素），而id 用于标识单独的唯一的元素。

15. `<table>`标签
    - 常用属性
    1）属性：border
    作用：规定表格边框的宽度
    2）属性：cellpadding
    作用：单元格中的文本与单元格边框的间距
    3）属性：cellspacing
    作用：单元格之间的间距

    - 创建表格的四个元素：
    table、tbody、tr、th、td
        1、`<table>…</table>`：整个表格以`<table>`标记开始、`</table>`标记结束。
        
        2、`<tbody>…</tbody>`：当表格内容非常多时，表格会下载一点显示一点，但如果加上<tbody>标签后，这个表格就要等表格内容全部下载完才会显示。如右侧代码编辑器中的代码。
        
        3、`<tr>…</tr>`：表格的一行，所以有几对tr 表格就有几行。
        
        4、`<td>…</td>`：表格的一个单元格，一行中包含几对`<td>...</td>`，说明一行中就有几列。
            - 常用属性：
            colspan：规定单元格可横跨的列数，值为数字
            rowspan：规定单元格可横跨的行数，值为数字
        
        5、`<th>…</th>`：表格的头部的一个单元格，表格表头。
        
        6、表格中列的个数，取决于一行中数据单元格的个数。
    >总结：
    1、表头，也就是th标签中的文本默认为粗体并且居中显示
    2、table表格在没有添加css样式之前，在浏览器中显示是没有表格线的
    3、用css样式，为表格加入边框Table 表格在没有添加 css 样式之前，是没有边框的。

16. `<caption>`标签
    表格还是需要添加一些标签进行优化，可以添加标题和摘要。
    - 摘要
    摘要的内容是不会在浏览器中显示出来的。它的作用是增加表格的可读性(语义化)，使搜索引擎更好的读懂表格内容，还可以使屏幕阅读器更好的帮助特殊用户读取表格内容。
    语法：
            <table summary="表格简介文本">
    - 标题
    用以描述表格内容，标题的显示位置：表格上方。
    语法：
            <table>
                <caption>标题文本</caption>
                <tr>
                    <td>…</td>
                    <td>…</td>
                    …
                </tr>
            …
            </table>

17. `<a>`标签
    - href：Hypertext Reference的缩写。意思是超文本引用。
    - 使用`<a>`标签可实现超链接，它在网页制作中可以说是无处不在，只要有链接的地方，就会有这个标签。
    语法：

            <a  href="目标网址"  title="鼠标滑过显示的文本">链接显示的文本</a>
    例如：

            <a  href="http://www.imooc.com"  title="点击进入慕课网">click here!</a>
    上面例子作用是单击click here!文字，网页链接跳转到http://www.imooc.com这个网页。
    - <`a>`标签在默认情况下，链接的网页是在当前浏览器窗口中打开，有时我们需要在新的浏览器窗口中打开。
    如下代码：
            <a href="目标网址" target="_blank">click here!</a>
        
        -         _blank --在新窗口中打开链接 
        -         _parent --在父窗体中打开链接 
        -         _self --在当前窗体打开链接,此为默认值 
        -         _top --在当前窗体打开链接，并替换当前的整个窗体(框架页) 
        -         一个对应的框架页的名称 -在对应框架页中打开
    - title属性的作用，鼠标滑过链接文字时会显示这个属性的文本内容。这个属性在实际网页开发中作用很大，主要方便搜索引擎了解链接地址的内容（语义化更友好）。
    - 注意：还有一个有趣的现象不知道小伙伴们发现了没有，只要为文本加入a标签后，文字的颜色就会自动变为蓝色（被点击过的文本颜色为紫色），颜色很难看吧，不过没有关系后面我们学习了css样子就可以设置过来（a{color:#000}),后面会详细讲解。
    - 使用mailto在网页中链接Email地址
    `<a>`标签还有一个作用是可以链接Email地址，使用mailto能让访问者便捷向网站管理者发送电子邮件。
    > 注意：如果mailto后面同时有多个参数的话，第一个参数必须以“?”开头，后面的参数每一个都以“&”分隔。引号只有一对！
    > 例子：`<a href="mailto:yy@qq.com? cc=xx@qq.com & bcc=aa@qq.com & subject=邮件主题 & body=邮件内容">`
        1. 邮箱地址 
        mailto: `<a href="mailto:qiujie@staff.weibo.com">发送</a>`
        2. 抄送地址 
        cc: `<a href="mailto:qiujie@staff.weibo.com?cc=zz@sina.com">发送</a>`
        3. 密件抄送地址 
        用分号分隔: `<a href="mailto:qiujie@staff.weibo.com?bcc=zz@sina.com">发送</a>`
        4. 多个收件人、抄送人、密送人 ; 
        bcc: `<a href="mailto:qiujie@staff.weibo.com;zz@sina.com">发送</a>`
        5. 邮件主题 
        subject: `<a href="mailto:qiujie@staff.weibo.com？subject=邮件主题">发送</a>`
        6. 邮件内容 
        body: ` <a href="mailto:qiujie@staff.weibo.com？body=邮件正文">发送</a>`
        7. 例子
        `<a href="mailto:yy@imooc.com;10001@qq.com?cc=10002@qq.com&bbc=madanteng@qqhelp.com&subject=观了不起的盖茨比有感。&body=你好，对此评论有些想法。">对此影评有何感想，发送邮件给我</a>`
    - 如果：A 发送邮件给B1、B2、B3，抄送给C1、C2、C3，密送给D1、D2、D3。
    那么：
        1. A知道自己发送邮件给了B1、B2、B3，并且抄送给了C1、C2、C3，密送给了D1、D2、D3。
        2. B1知道这封是A发送给B1、B2、B3的邮件，并且抄送给了C1、C2、C3，但不知道密送给了D1、D2、D3。
        3. C1知道这封是A发送给B1、B2、B3的邮件，并且抄送给了C1、C2、C3，但不知道密送给了D1、D2、D3。
        4. D1知道这封是A发送给B1、B2、B3的邮件，并且抄送给了C1、C2、C3，而且密送给了自己，但不知道密送给了D2、D3。
        
18. `<img>`标签
在网页的制作中为使网页炫丽美观，肯定是缺少不了图片，可以使用<img>标签来插入图片。
    - 语法：
            [站外图片上传中……(2)]
            <img src = "myimage.gif" alt = "My Image" title = "My Image" />
    - 讲解：
    1、src：标识图像的位置；
    2、alt：指定图像的描述性文本，当图像不可见时（下载不成功时），可看到该属性指定的文本；
    3、title：提供在图像可见时对图像的描述(鼠标滑过图片时显示的文本)；
    4、图像可以是GIF，PNG，JPEG格式的图像文件。
    5、路径有两种填写方式：绝对路径、相对路径
    6、相对路径：相对于我们当前 html 文件的位置来写路径即可！
    7、./表示当前目录，../表示上一级目录
19. `<form>`标签
    - 网站怎样与用户进行交互？答案是使用HTML表单(form)。表单是可以把浏览者输入的数据传送到服务器端，这样服务器端程序就可以处理表单传过来的数据。
语法：
        <form   method="传送方式"   action="服务器文件">
    - 讲解：
        1. `<form>` ：`<form>`标签是成对出现的，以`<form>`开始，以`</form>`结束。
        2. action ：浏览者输入的数据被传送到的地方,比如一个PHP页面(save.php)。
        3. method ： 数据传送的方式（get/post）。
                <form    method="post"   action="save.php">
                    <label for="username">用户名:</label>
                    <input type="text" name="username" />
                    <label for="pass">密码:</label>
                    <input type="password" name="pass" />
                </form>

    注意:
    1、所有表单控件（文本框、文本域、按钮、单选框、复选框等）都必须放在<form></form>标签之间（否则用户输入的信息可提交不到服务器上哦！）。
    2、method:post/get的区别这一部分内容属于后端程序员考虑的问题。

20. `<input>`标签
    - 当用户要在表单中键入字母、数字等内容时，就会用到文本输入框。文本框也可以转化为密码输入框。
    - 语法：
            <form>
               <input type="text/password" name="名称" value="文本" />
            </form>
    - 属性：
        1. type：
            当type="text"时，输入框为文本输入框;
            当type="password"时, 输入框为密码输入框。
            hidden    定义隐藏输入字段
            image    定义图像作为提交按钮
            number    定义带有 spinner 控件的数字字段
            password    定义密码字段。字段中的字符会被遮蔽
            radio    定义单选按钮
            checkbox 定义复选框按钮
            range    定义带有 slider 控件的数字字段
            reset    定义重置按钮。重置按钮会将所有表单字段重置为初始值
            search    定义用于搜索的文本字段
            submit    定义提交按钮。提交按钮向服务器发送数据
            text    默认。定义单行输入字段，用户可在其中输入文本。默认是 20 个字符
            url    定义用于 URL 的文本字段
        2. name：为文本框命名，以备后台程序ASP 、PHP使用。
        3. value：为文本输入框设置默认值。(一般起到提示作用)
    - 举例：
            <form>
              姓名：
              <input type="text" name="myName"/>
              <br/>
              密码：
              <input type="password" name="pass"/>
            </form>
    - value="xxx" 替换为 placeholder="xxx" 的体验更好一些，placeholder属性为 HTML 5 的新属性。placeholder 属性提供可描述输入字段预期值的提示信息（hint）。该提示会在输入字段为空时显示，并会在字段获得焦点时消失。
    语法：
            <input placeholder="text"/>    
    >注释：placeholder 属性适用于以下的 `<input>` 类型：text, search, url, telephone, email 以及 password。

    - **注意**:同一组的单选按钮，name 取值一定要一致，比如上同一个名称“gender”，这样同一组的单选按钮才可以起到单选的作用！
    >知识扩展：[表单提交中的input、button、submit的区别](http://www.cnblogs.com/shytong/p/5087147.html)
    
21. `<textarea>`标签
    - 当用户需要在表单中输入大段文字时，需要用到文本输入域。
    - 语法：
            <textarea  rows="行数" cols="列数">文本</textarea>
    1、`<textarea>`标签是成对出现的，以`<textarea>`开始，以`</textarea>`结束。
    2、cols ：多行输入域的列数。
    3、rows ：多行输入域的行数。
    4、在`<textarea></textarea>`标签之间可以输入默认值。
    举例：
            <form  method="post" action="save.php">
                    <label>联系我们</label>
                    <textarea cols="50" rows="10" >在这里输入内容...</textarea>
            </form>

22. `<select>`标签
    - 使用下拉列表框，节省空间。下拉列表在网页中也常会用到，它可以有效的节省网页空间。既可以单选、又可以多选。
    - 语法：
            <select>
                <option value="提交的值">显示的值</option>
                ...
            </select>
        设置selected="selected"属性，则该选项就被默认选中。    
            selected="selected"
    - 若想实现多选
    `<select multiple="multiple">`  然后选择时候按ctrl点鼠标选中
    - 若想让某个选项不可选
    `<option disabled="disabled">`
    - optgroup 标签
    把相关的选项组合在一起
    属性 label：给选项组命名
    属性 disabled：禁用该选项组

23. `<label>`标签
    - label标签不会向用户呈现任何特殊效果，它的作用是为鼠标用户改进了可用性。如果你在 label 标签内点击文本，就会触发此控件。就是说，当用户单击选中该label标签时，浏览器就会自动将焦点转到和标签相关的表单控件上（就自动选中和该label标签相关连的表单控件上）。

    - 语法：
            <label for="控件id名称">
    注意：标签的 for 属性中的值应当与相关控件的 id 属性值一定要相同。
    - 例子：
            <form>
              <label for="male">男</label>
              <input type="radio" name="gender" id="male" />
              <br />
              <label for="female">女</label>
              <input type="radio" name="gender" id="female" />
              <label for="email">输入你的邮箱地址</label>
              <input type="email" id="email" placeholder="Enter email">
            </form>

24. `<map>`标签
- 使用 map 标签可以给图片某块区域加超链接
- 使用方法：
1）为 map 标签首先加上 id 属性用来为 map 标签定义一个唯一的名称
2）为了保证兼容性再加上 name 属性，属性值与 id 的值相同
3）为 map 标签所作用的图片加上 usemap 属性，属性值为 #id 名称
4）在 map 标签内嵌套 area 标签来实现给指定区域加链接
        <area shape="" coords="" href ="" alt="" />
    shape 属性：定义链接区域的形状，常用值 rect、circle
    coords 属性：确定区域的精确位置。填写坐标即可，以父元素左上角为原点，可借助qq截图来得到想要的坐标
    href 属性：填写链接地址即可
    alt 属性：给链接加一些说明信息
- 例子
        <map id="img1" name="img1">
            <area shape="rect" coords="184,33,391,258" href="http:www.baidu.com" alt="百度一下" target="_blank" />
            <area shape="circle" coords="507,287,20" href="http://www.sifangku.com" alt="私房库我的博客" target="_blank" />
        </map>
    >注意：
    >第一个coords的四个参数中，前两个参数为矩形的接近原点的顶角的坐标，后两个参数为对角的坐标。
    >第二个coords的三个参数中，前两个为圆心坐标，第三个参数为圆的半径。

25. `<iframe>`标签
- 创建包含另外一个文档的内联框架（即行内框架）
- 属性：
    - frameborder
    值：1、0
    作用：规定是否显示框架周围的边框。
    - width值：以像素计的宽度值、以包含元素百分比计的宽度值
    作用：定义 iframe 的宽度
    - height
    作用：定义高度
    - name
    作用：给 iframe 命名
    - scrolling
    值：yes、no、auto
    作用：规定是否在 iframe 中显示滚动条
    - src
    作用：规定在 iframe 中显示的文档的 URL
    可以是本地的 html 文件，也可以是远程的 html 文件

##标签写法与嵌套的讨论
###标签写法
1. 元素标记的省略（在 html5 里面有的标记是可以省略不写的）
    1）不允许写结束标签的元素
    area,base,br,col,command,embed,hr,img,input,keygen,link,meta,paran,source,track,wbr。
    这些标签都是单标签例如：br 标签，不可以这样`<br></br>`，只能`<br />`这样来关闭
    标签。
    2）可以省略结束标记的元素有：
    li,dt,dd,p,rt,rp,optgroup,option,colgroup,thead,tbody,tfoot,tr,td,th。
    3）可以省略全部标记的元素有
    html,head,body,colgroup,tbody
2. 具有 boolean 值得属性
    例如：disabled,readonly，checked 等只写属性而不写属性值得时候当做 ture
    不写属性表示 false
3. 属性值的引号可以省略
    要求：属性值不包含 空字符串，<，>，=， ‘

###标签嵌套探讨
1. html 规定我们必须要嵌套着写的标签
    例如：页面头部是嵌套在 head 标签里面的，主体内容都是嵌套在 body 标签里面的表单的内容是嵌套在 form 标签里面的，dt、dd 是嵌套在 dl 标签里面的，li 是嵌套到ul 标签里面的，等等...
2. 块级元素可以嵌套内联元素，但是**内联元素不能包含块元素**
        <div><span>我是一个 span 元素</span></div> —— 对
        <span><div>div 元素</div></span> —— 错
3. 内联元素可以嵌套内联元素
        <a href="#"><span></span></a> —— 对
4. 块级元素与块级元素嵌套注意点
    - **div 块级元素是一个容器，几乎可以存放任何常用标签**，包括自己，我们为什么要使用 div 来嵌套标签？这个问题可以用用我们国家的省份划分来解释，国家需要划分不同的省份来利于管理，那么我们 html 页面也是的，整个 html 文档元素太多，我们需要使用 div 标签将页面划分成不同的块，这样可以对每块进行分开管理，学完 css 我们就知道怎么进行管理了。
    - **块级元素不能放在 p 标签里面**
            <p><ol><li></li></ol></p> —— 错
            <p><div></div></p> —— 错
    -  **li 内可以包含 div 标签**，li 和 div 标签都是装载内容的容器，地位平等，没有级别之分（例如：h1、h2 这样森严的等级制度） ，要知道 li 标签连它的父级 ul 或者是 ol 都可以容纳的
