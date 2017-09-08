#CSS基础
---
>本文包括
>1. CSS基础知识
>2. 选择器（重要！！！）
>3. 继承、特殊性、层叠、重要性
>4. CSS格式化排版
>5. 单位和值
>6. 盒模型
>7. 浮动
>8. 相对定位与绝对定位
>9. 布局初探

##CSS基础知识
###认识CSS样式
1. CSS全称为“层叠样式表 (Cascading Style Sheets)”，它主要是用于定义HTML内容在浏览器内的显示样式，如文字大小、颜色、字体加粗等。
如下列代码：
        <head>    
            <style type="text/css">
                p{
                   font-size:20px;/*设置文字字号*/
                   color:red;/*设置文字颜色*/
                   font-weight:bold;/*设置字体加粗*/
                }
            </style>
            ...
        </head>
2. 使用CSS样式的一个好处是通过定义某个样式，可以让不同网页位置的文字有着统一的字体、字号或者颜色等。
3. 如果你这个css样式是定义在某个html网页中的话，那其他网页是无法使用的，但可以把
把css代码写一个单独的外部文件中，这个css样式文件以“.css”为扩展名，在`<head>`内（不是在`<style>`标签内）使用`<link>`标签将css样式文件链接到HTML文件内。在head标签下添加如下代码
        <head>
            <link href="base.css" rel="stylesheet" type="text/css" />
            ...
        </head>

###CSS代码语法
1. css 样式由选择符和声明组成，而声明又由属性和值组成，如下图所示：
![](http://upload-images.jianshu.io/upload_images/2106579-750e4125425f5d57.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
2. 选择符：又称选择器，指明网页中要应用样式规则的元素，如本例中是网页中所有的段（p）的文字将变成蓝色，而其他的元素（如ol）不会受到影响。
3. 声明：在英文大括号“｛｝”中的的就是声明，属性和值之间用英文冒号“：”分隔。当有多条声明时，中间可以英文分号“;”分隔，如下所示：
        p{font-size:12px;color:red;}
注意：
1、最后一条声明可以没有分号，但是为了以后修改方便，一般也加上分号。
2、为了使用样式更加容易阅读，可以将每条代码写在一个新行内，如下所示：
        p{
           font-size:12px;
           color:red;
        }

###CSS注释代码
1. Html中使用`<!--注释语句-->`。
2. 就像在Html的注释一样，在CSS中也有注释语句：用`/*注释语句*/`来标明。
3. 快捷键：Ctrl+/
3. 例子：
        <style type="text/css">
            p{
               font-size:12px;/*设置文字字号为12px*/
               color:red;/*设置文字颜色为红色*/
            }
        </style>

##三种样式
1. 内联式适用情况:局部特殊化

2. 嵌入式适用情况:统一标签样式格式

3. 外联式适用情况:方便代码重用和管理

4. 优先级：就近原则（离被设置元素越近优先级别越高）。
但注意上面所总结的优先级是有一个前提：内联式、嵌入式、外部式样式表中css样式是在的相同权值的情况下，

###内联式css样式，直接写在现有的HTML标签中
1. 内联式css样式表就是把css代码直接写在现有的HTML标签中，如下面代码：
        <p style="color:red">这里文字是红色。</p>
2. 注意要写在元素的开始标签里，下面这种写法是错误的：
        <p>这里文字是红色。</p style="color:red">
3. 并且css样式代码要写在style=""双引号中，如果有多条css样式代码设置可以写在一起，中间用分号隔开。如下代码：
        <p style="color:red;font-size:12px">这里文字是红色。</p>

###嵌入式css样式，写在当前的文件中
1. 现在有一任务，把右侧编辑器中的“超酷的互联网”、“服务及时贴心”、“有趣易学”这三个短词文字字号修改为18px。如果用上节课我们学习的内联式css样式的方法进行设置将是一件很头疼的事情（为每一个`<span>`标签加入sytle="font-size:18px"语句），本小节讲解一种新的方法嵌入式css样式来实现这个任务。
2. 嵌入式css样式，就是可以把css样式代码写在`<style type="text/css"></style>`标签之间。如下面代码实现把三个`<span>`标签中的文字设置为红色：
        <style type="text/css">
        span{
        color:red;
        }
        </style>
3. 嵌入式css样式必须写在`<style></style>`之间，并且一般情况下嵌入式css样式写在`<head></head>`之间。

###外部式css样式，写在单独的一个文件中
1. 外部式css样式(也可称为外联式)就是把css代码写一个单独的外部文件中，这个css样式文件以“.css”为扩展名，在`<head>`内（不是在`<style>`标签内）使用`<link>`标签将css样式文件链接到HTML文件内，如下面代码：
        <link href="base.css" rel="stylesheet" type="text/css" />
2. 注意：
1、css样式文件名称以有意义的英文字母命名，如 main.css。
2、rel="stylesheet" type="text/css" 是固定写法不可修改。
3、<link>标签位置一般写在<head>标签之内。

##选择器
1. 每一条css样式声明（定义）由两部分组成，形式如下：
        选择器{
            样式;
        }
2. 在{}之前的部分就是“选择器”，“选择器”指明了{}中的“样式”的作用对象，也就是“样式”作用于网页中的哪些元素。

###选择器种类
- 标签选择器，标签名{}，作用于所有此标签。

- 类选择器， .class{}，在标签内定义class=""，属图形结构。

- ID选择器，#ID{}, 在标签内定义id=""，有严格的一一对应关系。

- 子选择器， .span>li{}，作用于父元素span类下一层的li标签。

- 包含选择器，.span li{}，作用于父元素span下所有li标签。

- 通用选择器，*{}，匹配所有html的标签元素。

- 伪类选择符：它允许给html不存在的标签(标签的某种状态)设置样式，比如说我们给html中的一个标签元素的鼠标滑过的状态来设置字体颜色。

- 包含选择器作用于该标签下的子元素,不包含本身,标签选择器作用包含自己本身

###标签选择器
1. 标签选择器其实就是html代码中的标签。如右侧代码编辑器中的`<html>、<body>、<h1>、<p>、<img>`。例如下面代码：
        <style type="text/css">        
            p{
                font-size:12px;
                line-height:1.6em;
            }
            ...
        </style>
上面的css样式代码的作用：为p标签设置12px字号，行间距设置1.6em的样式。

2. px像素（Pixel）。相对长度单位。像素px是相对于显示器屏幕分辨率而言的。(引自CSS2.0手册)
em是相对长度单位。相对于当前对象内文本的字体尺寸。如当前对行内文本的字体尺寸未被人为设置，则相对于浏览器的默认字体尺寸。(引自CSS2.0手册)

###类选择器
1. 类选择器在css样式编码中是最常用到的，如右侧代码编辑器中的代码:可以实现为“胆小如鼠”、“勇气”字体设置为红色。

2. 语法：
        .类选器名称{css样式代码;}

3. 注意：
1、英文圆点开头
2、其中类选器名称可以任意起名（但不要起中文噢）

4. 使用方法：
第一步：使用合适的标签把要修饰的内容标记起来，如下：
        <span>胆小如鼠</span>
第二步：使用class="类选择器名称"为标签设置一个类，如下：
        <span class="stress">胆小如鼠</span>
第三步：设置类选器css样式，如下：
        .stress{color:red;}/*类前面要加入一个英文圆点*/

###ID选择器
在很多方面，ID选择器都类似于类选择符，但也有一些重要的区别：
1. 为标签设置id="ID名称"，而不是class="类名称"。

2. ID选择符的前面是井号（#）号，而不是英文圆点（.）。

3. 例子：
        <!DOCTYPE HTML>
        <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
            <title>认识html标签</title>
            <style type="text/css">
            #stress{
                color:red;
            }
            #setGreen{
               color:green;
            }
            </style>
            </head>
            <body>
                <h1>勇气</h1>
                <p>三年级时，我还是一个<span id="stress">胆小如鼠</span>的小女孩，上课从来不敢回答老师提出的问题，生怕回答错了老师会批评我。就一直没有这个勇气来回答老师提出的问题。学校举办的活动我也没勇气参加。</p>
                <p>到了三年级下学期时，我们班上了一节<span id="setGreen">公开课</span>，老师提出了一个很简单的问题，班里很多同学都举手了，甚至成绩比我差很多的，也举手了，还说着："我来，我来。"我环顾了四周，就我没有举手。</p>
            
            </body>
        </html>
4. 在同一个页面内，不允许有相同名字的id对象出现，但是允许相同名字的class。这样，一般网站分为头，体，脚部分，因为考虑到它们在同一个页面只会出现一次，所以用id，其他的，比如说你定义了一个颜色为red的class，在同一个页面也许要多次用到，就用class定义。另外，当页面中用到js或者要动态调用对象的时候，要用到id，所以要根据自己的情况运用。自己的语言。
但document的方法中有getElementById()这个方法倒是只能用id的.

###类和ID选择器的区别
1. 相同点：可以应用于任何元素
2. 不同点：
    1. ID选择器只能在文档中使用一次。与类选择器不同，在一个HTML文档中，ID选择器只能使用一次，而且仅一次。而类选择器可以使用多次。如果单纯的在CSS里使用相同ID多次是可以的！但如果页面涉及到js，就不好了。因为js里获取DOM是通过getElementById，而如果页面出现同一个id几次，这样就获取不到了。所以id要有唯一性。成熟网站里，你很少看到css里用id选择器的，都是用class，id选择器留给写js的人用，这样避免冲突。
    下面代码是正确的：
            <span class="stress">胆小如鼠</span>
            <span class="stress">勇气</span>
    而下面代码是错误的：
            <span id="stress">胆小如鼠</span>
            <span id="stress">勇气</span>
    2. 可以使用**类选择器词列表方法**为一个元素同时设置多个样式。我们可以为一个元素同时设多个样式，但只可以用类选择器的方法实现，ID选择器是不可以的（不能使用 ID 词列表）。
        - 下面的代码是正确的(完整代码见右侧代码编辑器)
                .stress{
                    color:red;
                }
                .bigsize{
                    font-size:25px;
                }
                <p>到了<span class="stress bigsize">三年级</span>下学期时，我们班上了一节公开课...</p>
        代码的作用是为“三年级”三个文字设置文本颜色为红色并且字号为25px。
        
        - 下面的代码是不正确的(完整代码见右侧代码编辑器)
                #stressid{
                    color:red;
                }
                #bigsizeid{
                    font-size:25px;
                }
                <p>到了<span id="stressid bigsizeid">三年级</span>下学期时，我们班上了一节公开课...</p>
        代码不可以实现为“三年级”三个文字设置文本颜色为红色并且字号为25px的作用。

###交集选择器
- 一个标签选择器后边跟一个类选择器或者一个 ID 选择器，中间不能有空格。它要求必
须是属于某一个标签的，并且声明了类选择器或者 ID 选择器。
- 例如：
    div.mycolor{…} 类为 mycolor 的div标签才会被选中，应用该样式。
    div#mydiv{…} id 为 mydiv 的div标签才会被选中，应用该样式。

###并集选择器
- 就是多个选择器以逗号相连，只要满足其中之一它都会被选中！
- 我们上面学的选择器都可以被写入并集选择器
    div,p,h1,div.mycolor,div#mydiv {…}

###子选择器
1. 还有一个比较有用的选择器子选择器，即大于符号(>),用于选择指定标签元素的第一代子元素。代码：
        .food>li{border:1px solid red;}
这行代码会使class名为food下的子元素li（水果、蔬菜）加入红色实线边框。

2. 代码
        <ul class="food">
            <li>水果
                <ul>
                    <li>香蕉</li>
                    <li>苹果</li>
                    <li>梨</li>
                </ul>
            </li>
            <li>蔬菜
                <ul>
                    <li>白菜</li>
                    <li>油菜</li>
                    <li>卷心菜</li>
                </ul>
            </li>
        </ul>

3. 样式：
        border:1px solid red;
相当于
        border-width:1px;  //边框宽度
        border-style:solid;  //边框风格
        border-color:red;  //边框颜色

###包含(后代)选择器
1. 包含选择器，即加入空格,用于选择指定标签元素下的后辈元素。如右侧代码编辑器中的代码：
        .first  span{color:red;}
这行代码会使第一段文字内容中的“胆小如鼠”字体颜色变为红色。

2. 请注意这个选择器与子选择器的区别，子选择器（child selector）仅是指它的直接后代，或者你可以理解为作用于子元素的第一代后代。而后代选择器是作用于<span style="color:red">所有子后代元素</span>。后代选择器通过空格来进行选择，而子选择器是通过“>”进行选择。

3. 总结：>作用于元素的第一代后代，空格作用于元素的所有后代。

###通用选择器
- 通用选择器是功能最强大的选择器，它使用一个（*）号指定，它的作用是匹配html中所有标签元素，如下使用下面代码使用html中任意标签元素字体颜色全部设置为红色：
        * {color:red;}

###伪类选择符
1. 更有趣的是伪类选择符，为什么叫做伪类选择符，它允许给html不存在的标签（标签的某种状态）设置样式，比如说我们给html中一个标签元素的鼠标滑过的状态来设置字体颜色：
        a:hover{color:red;}

2. 上面一行代码就是为 a 标签鼠标滑过的状态设置字体颜色变红。这样就会使第一段文字内容中的“胆小如鼠”文字加入鼠标滑过字体颜色变为红色特效。

3. 关于伪选择符：
 关于伪类选择符，到目前为止，可以兼容所有浏鉴器的“伪类选择符”就是 a 标签上使用 :hover 了（其实伪类选择符还有很多，尤其是 css3 中，但是因为不能兼容所有浏览器，本教程只是讲了这一种最常用的）。其实 :hover 可以放在任意的标签上，比如说 p:hover，但是它们的兼容性也是很不好的，所以现在比较常用的还是 a:hover 的组合。

4. 什么时候使用伪类选择符
当用户和网站交互的时候一般使用伪类选择器，，如“:hover”,":active"和":focus"。常用的伪类有：
        .demo a:link {color:gray;}/*链接没有被访问时前景色为红色*/ 
        .demo a:visited{color:yellow;}/*链接被访问过后前景色为黄色*/ 
        .demo a:hover{color:green;}/*鼠标悬浮在链接上时前景色为绿色*/ 
        .demo a:active{color:blue;}/*鼠标点中激活链接那一下前景色为蓝色*/ 

###分组选择符
- 当你想为html中多个标签元素设置同一个样式时，可以使用分组选择符（，），如下代码为右侧代码编辑器中的h1、span标签同时设置字体颜色为红色：
        h1,span{color:red;}
它相当于下面两行代码：
        h1{color:red;}
        span{color:red;}

##CSS继承、特殊性、层叠、重要性
###CSS继承
1. CSS的某些样式是具有继承性的，那么什么是继承呢？继承是一种规则，它允许样式不仅应用于某个特定html标签元素，而且应用于其后代。比如下面代码：如某种颜色应用于p标签，这个颜色设置不仅应用p标签，还应用于p标签中的所有子元素文本，这里子元素为span标签。
        p{color:red;}
        <p>三年级时，我还是一个<span>胆小如鼠</span>的小女孩。</p>

2. 可见右侧结果窗口中p中的文本与span中的文本都设置为了红色。但注意有一些css样式是不具有继承性的。如border:1px solid red;
        p{border:1px solid red;}
        <p>三年级时，我还是一个<span>胆小如鼠</span>的小女孩。</p>
在上面例子中它代码的作用只是给p标签设置了边框为1像素、红色、实心边框线，而对于子元素span是没用起到作用的。

3. 那么，哪些属性是可以继承的呢？css样式表属性可以继承的有如下：
*azimuth, border-collapse, border-spacing,
caption-side, color, cursor, direction, elevation,
empty-cells, font-family, font-size, font-style,
font-variant, font-weight, font, letter-spacing,
line-height, list-style-image, list-style-position,
list-style-type, list-style, orphans, pitch-range,
pitch, quotes, richness, speak-header, speaknumeral,
speak-punctuation, speak, speechrate,
stress, text-align, text-indent, texttransform,
visibility, voice-family, volume, whitespace,
widows, word-spacing *

4. [CSS样式表继承详解](http://www.cnphp.info/css-style-inheritance.html "CSS样式表继承详解")

###特殊性(specificity)/权值/优先级
1. 有的时候我们为同一个元素设置了不同的CSS样式代码，那么元素会启用哪一个CSS样式呢?我们来看一下面的代码：
        p{color:red;}
        .first{color:green;}
        <p class="first">三年级时，我还是一个<span>胆小如鼠</span>的小女孩。</p>
p和.first都匹配到了p这个标签上，那么会显示哪种颜色呢？green是正确的颜色，那么为什么呢？是因为浏览器是根据权值来判断使用哪种css样式的，权值高的就使用哪种css样式。

2. 下面是权值的规则：
标签的权值为1，类选择符的权值为10，ID选择符的权值最高为100。例如下面的代码：
        p{color:red;} /*权值为1*/
        p span{color:green;} /*权值为1+1=2*/
        .warning{color:white;} /*权值为10*/
        p span.warning{color:purple;} /*权值为1+1+10=12*/
        #footer .note p{color:yellow;} /*权值为100+10+1=111*/
4个等级的定义如下：
    1. 第一等：代表内联样式，如: style=””，权值为1000。
    2. 第二等：代表ID选择器，如：#content，权值为100。
    3. 第三等：代表类，伪类和属性选择器，如.content，权值为10。
    4. 第四等：代表类型选择器和伪元素选择器，如div p，权值为1。
    5. <span style="color:red">**注意**</span>：通用选择器（*），子选择器（>）和相邻同胞选择器（+）并不在这四个等级中，所以他们的权值都为0。

3. <span style="color:red">**注意**</span>：还有一个权值比较特殊--继承也有权值但很低，有的文献提出它只有0.1，所以可以理解为继承的权值最低。

4. 最后一个影响特殊性的声明:!important
    
    例:
        h1{ color:red!important;}
    !important被称为重要声明,被标记为!important的属性其特殊性最高,当出现有冲突的重要声明时,同样安照出现的先后顺序决定最后的显示。
    
    例:
        h1{color:red!important;}
        h1{color:blue!important;}
    最后h1文字为蓝色

    !important要写在分号的前面，每次针对一个属性(即想将样式中的多个属性都提高权限，就要多次添加)。
        p{color:red!important;font-size:14px!important}
    
    这里注意当网页制作者不设置css样式时，浏览器会按照自己的一套样式来显示网页。并且用户也可以在浏览器中设置自己习惯的样式，比如有的用户习惯把字号设置为大一些，使其查看网页的文本更加清楚。这时注意样式优先级为：浏览器默认的样式 < 网页制作者样式 < 用户自己设置的样式，但记住!important优先级样式是个例外，权值高于用户自己设置的样式。

5. 例子：
        <!DOCTYPE HTML>
        <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
            <title>特殊性</title>
            <style type="text/css">
            p{color:red;}
            .first{color:green;}/*因为权值高显示为绿色*/
        
            span{color:pink;}/*设置为粉色*/
            p span{color:purple};

            </style>
        </head>
        <body>
            <h1>勇气</h1>
            <p class="first">三年级时，我还是一个<span>胆小如鼠</span>的小女孩，上课从来不敢回答老师提出的问题，生怕回答错了老师会批评我。就一直没有这个勇气来回答老师提出的问题。学校举办的活动我也没勇气参加。</p>
            <p id="second">到了三年级下学期时，我们班上了一节公开课，老师提出了一个很简单的问题，班里很多同学都举手了，甚至成绩比我差很多的，也举手了，还说着："我来，我来。"我环顾了四周，就我没有举手。</p>
        </body>
        </html>

    结果：
    <span style="color:green">三年级时，我还是一个<span style="color:purple">胆小如鼠</span>的小女孩，上课从来不敢回答老师提出的问题，生怕回答错了老师会批评我。就一直没有这个勇气来回答老师提出的问题。学校举办的活动我也没勇气参加。</span>

    解释：
    第七行    p{color:red;}  对于p来说，这条语句的权值为 1 ；而对于p中的span胆小如鼠来说，因为继承性，这条语句对于胆小如鼠来说只有 0.1 的权值。
    第八行    .first{color:green;} 对于first来说，这条语句的权值为 10 ；而对于first中的span胆小如鼠来说，因为继承性，这条语句对于胆小如鼠来说只有 0.1 的权值。
    第十行    span{color:pink;} 对于span胆小如鼠来说，这条语句的权值为 1 。
    所以对于整段话来说（除了胆小如鼠外），执行第八行语句（即段落显示绿色），因为第八行具有的权值最高为10>第七行的权值1，；而对于胆小如鼠来说，执行第十行语句（即显示粉色），因为第十行语句具有的权值为1>第七行的权值0.1（第八行的权值）。
    第十一行   p span{color:purple;}  对于p和span来说，这条语句的权值为1+1=2。那么现在对于p来说，就执行第十一行语句（即显示紫色）（第十一行权值为2>第十行的权值1）。

5. 相关阅读：
[CSS选择器的权重与优先规则](http://www.nowamagic.net/csszone/css_SeletorPriorityRules.php)
[玩转CSS选择器（一）之使用方法](https://segmentfault.com/a/1190000003088878#articleHeader5)

###层叠
1. 我们来思考一个问题：如果在html文件中对于同一个元素可以有多个css样式存在并且这多个css样式具有相同权重值怎么办？好，这一小节中的层叠帮你解决这个问题。

2. 层叠就是在html文件中对于同一个元素可以有多个css样式存在，当有相同权重的样式存在时，会根据这些css样式的前后顺序来决定，处于最后面的css样式会被应用。

3. 如下面代码:
        p{color:red;}
        p{color:green;}
        <p class="first">三年级时，我还是一个<span>胆小如鼠</span>的小女孩。</p>
最后 p 中的文本会设置为green，这个层叠很好理解，理解为后面的样式会覆盖前面的样式。

##CSS格式化排版
###字体
1. 我们可以使用css样式为网页中的文字设置字体、字号、颜色等样式属性。下面我们来看一个例子，下面代码实现：为网页中的文字设置字体为宋体。
        body{font-family:"宋体";}

2. 这里注意不要设置不常用的字体，因为如果用户本地电脑上如果没有安装你设置的字体，就会显示浏览器默认的字体。（因为用户是否可以看到你设置的字体样式取决于用户本地电脑上是否安装你设置的字体。）
 
3. 现在一般网页喜欢设置“微软雅黑”，如下代码：
        body{font-family:"Microsoft Yahei";}
或
        body{font-family:"微软雅黑";}
>注意：第一种方法比第二种方法兼容性更好一些。
因为这种字体即美观又可以在客户端安全的显示出来（用户本地一般都是默认安装的）。

###文字排版
- font-family:设置字体；多个字体用逗号隔开
        font-family:"Times New Roman",Georgia,Serif;
- font-size:字体大小；
    可以使用下面代码设置网页中文字的字号为12像素，并把字体颜色设置为#666(灰色)：
        body{font-size:12px;color:#666}    
    >注意：这里font-size一定要带单位px或者em或者%！！！
- font-weight:bold：设置为粗体样式；

- font-style:italic：设置为斜体样式；
        normal(标准) italic(斜体) oblique(倾斜)

- text-decoration:underline：文字设置下划线；

- text-decoration:line-through：删除线；   
        h1{text-decoration:overline}
         其他值
            underline    定义文本下的一条线。
            overline    定义文本上的一条线。
            line-through    定义穿过文本下的一条线。
            blink    定义闪烁的文本。（经本人测试失效？？？）

- 设置多种字体属性
    语法：{font:字体风格 字体粗细字体大小 字体类型;}
        span{font:oblique bold 12px "楷体";}

-  鼠标形状
    语法：标签选择器{cursor:cursor属性;}(鼠标形状 )
    css：
        span{cursor:pointer;}
    html：
        <span>...(内容)...</span>
    cursor属性：
    cursor(鼠标形状) default(默认) pointer(超链接指针) wait(忙) help(帮助) 
     text(指示文本) crosshair(十字状)

###段落排版
- text-indent:2em：缩进；中文文字中的段前习惯空两个文字的空白。
（**注意**：2em的意思就是文字的2倍大小。    这里可带单位，也可不带单位，当不带单位时，默认单位为em！）
    >在中文里，文字输入分为全角和半角，
    (中文输入法里，按shift+空格 切换全角半角状态）
    全角，段落中所有字符（包括文字和其它符号：逗号、顿号、句号等），
    都是占用一个字的位置，这样排版的时候，上下文字能对齐；
    半角，段落中所有除文字外的符号，只占用半个字的位置；
    打字时，默认是半角，按空格最明显，只有前一个字的一半宽度；
    切换全角后，空格刚好是一个字宽度（段落中最明显，上下对齐）
    em 就是一个全角占位符；

- line-height:2em：行间距（行高）；
    设置高度与行高一样，可以实现垂直居中效果！
    >注意：必须带单位px或em或者%！！！

- word-spacing:50px：英文单词间距；（仅包括英文）

- letter-spacing:20px：字符间距；（包括中文和英文）
    >1. 在中英文混排的文章中，要注意的一点是，中文对word-spacing属性是没有反应的，而使用letter-spacing调整中文字间距的时候，会同时拉开英文字母的距离，使得在中文排版页面中的英文显得不美观；
    >（经本人测试，中文字之间加空格之后，会对word-spacing产生反应！）
    >2. 中英文混排时，可以对不同的语言添加<span>标签，分开调整；

- text-align:属性规定元素中的文本的水平对齐方式; 
        text-align:center/right/left（默认）/justify（两端对齐）
    
    例子：
        <div>[站外图片上传中……(3)]</div>
    此时在嵌入式样式中应这样写：
        div{
            text-align:xxx;
        }
    
    解释：
    1. 该属性通过指定行框与哪个点对齐，从而设置块级元素内文本的水平对齐方式。其目的是设置文本或img标签等一些内联对象（或与之类似的元素）的居中。
    2. text-align可以对一个块使用，对这个块里的所有内容都会生效，不管块里包含的是图片还是文字。然而如果一个块内包含着子元素的块，那么对这个子元素所占的空间并不生效，只对块内所有的文字和图片生效而已。
    
    扩展阅读：
    [margin:0 auto 与 text-align:center 的区别](http://www.cnblogs.com/zhwl/p/3529473.html)

- vertical-align:文本的垂直对齐方式;
        middle/top/bottom

- float：浮动方式（元素会紧贴到父元素的左边/右边/默认，注意很有可能挤压在浮动元素之前的元素）
    left/right/none(默认)

- border
    设置左/右/上/下边框：
        border-left/right/top/bottom: 1px solid red;
    实线：solid
    虚线：dashed

- border-radius
    设置边框的边角为圆形
        border-radius:XXpx;

- 元素性质相互转化：
    display:block; （变成块级元素）
    display:inline;    （变成内联元素)
    display:inline-block;    (仍以块级元素展示，但是并不独占一行）
    display:none;（在页面不显示！）

###后代元素长度大于祖辈元素的大小时候的处理方法：
overflow:visible
可能的值：
visible：默认，内容不会被修剪，会呈现在元素框之外。
hidden：超出的内容会被修剪掉，直接不现实。
scroll：超出内容会被修剪，但是浏览器会显示滚动条以便查看其余的内容。
auto：如果内容被超出，则浏览器会显示滚动条以便查看其余的内容。
inherit：规定应该从父元素继承 overflow 属性的值。

###背景
- background-color
    元素的背景颜色默认为 transparent
    background-color 不会被后代继承。

- background-image
    使用 background-image 属性默认值为 none 表示背景上没有放置任何图像
    如果需要设置一个背景图像，必须为这个属性设置一个 url 值
    background-image: url(bg.gif);
    注意图片的位置引入方法!

- background-repeat
    使用background-img时，背景图片重复的问题
    使用 background-repeat 来解决，可以的值：repeat-x(只在x轴)，repeat-y，no-repeat

- background-position
    前提：背景图片一定不重复（no-repeat）
    1. 可以使用一些关键字：top、bottom、left、right 和 center 通常，这些关键字会成对出现。注意：第一个值是y轴（垂直方向），第二个值是x轴（水平方向）
        top left
        top center
        top right
        center left
        center center
        center right
        bottom left
        bottom center
        bottom right
    2. 也可以用百分比:`background:50% 50%;`第一个表示水平方向，第二个表示垂直方向
    3. 当然更可以用数值，以 px 单位：`background:40px 10px;`第一个表示水平第二个表示垂直
    4. 也可以混用

- background-attachment
    背景关联：background-attachment:fixed 
    用滚动条滚动时，背景图片不变

- 总结写法
    background: #00FF00 url(bg.gif) no-repeat fixed center left;

##单位和值
###颜色值
在网页中的颜色设置是非常重要，有字体颜色（color）、背景颜色（background-color）、边框颜色（border）等，设置颜色的方法也有很多种：
1. 英文命令颜色
前面几个小节中经常用到的就是这种设置方法：
        p{color:red;}
2. RGB颜色
这个与 photoshop 中的 RGB 颜色是一致的，由 R(red)、G(green)、B(blue) 三种颜色的比例来配色。
        p{color:rgb(133,45,200);}
每一项的值可以是 0~255 之间的整数，也可以是 0%~100% 的百分数。如：
        p{color:rgb(20%,33%,25%);}
    即
        rgb(20%,33%,25%)=rgb(20%*255,33%*255,25%*255)
3. 十六进制颜色
这种颜色设置方法是现在比较普遍使用的方法，其原理其实也是 RGB 设置，但是其每一项的值由 0-255 变成了十六进制 00-ff。
        p{color:#00ffff;}
4. 配色表
    ![](http://upload-images.jianshu.io/upload_images/2106579-cbcce45cdc093c80.jpg?imageMogr2/auto-orient/strip)

###长度值
长度单位总结一下，目前比较常用到px（像素）、em、% 百分比，要注意其实这三种单位都是相对单位。
1. 像素
像素为什么是相对单位呢？因为像素指的是显示器上的小点（CSS规范中假设“90像素=1英寸”）。实际情况是浏览器会使用显示器的实际像素值有关，在目前大多数的设计者都倾向于使用像素（px）作为单位。

2. em
就是本元素给定字体的 font-size 值，如果元素的 font-size 为 14px ，那么 1em = 14px；如果 font-size 为 18px，那么 1em = 18px。如下代码：
        p{font-size:12px;text-indent:2em;}
上面代码就是可以实现段落首行缩进 24px（也就是两个字体大小的距离）。
<span style="color:red">**下面注意一个特殊情况：**</span>
当给 font-size 设置单位为 em 时，此时计算的标准以父元素p的 font-size 为基础。如下代码：
html:
        <p>以这个<span>例子</span>为例。</p>
css:
        p{font-size:14px}
        span{font-size:0.8em;}
结果 span 中的字体“例子”字体大小就为 11.2px（14 * 0.8 = 11.2px）。

3. 百分比
        p{font-size:12px;line-height:130%}
设置行高（行间距）为字体的130%（12 * 1.3 = 15.6px）。

##盒模型
- CSS 盒模型 (Box Model) 规定了元素框处理元素内容、内边距、边框和
的方式,页面中的所有标记都可以看成是一个盒子，盒模型是我们对网页
行定位的基础，而定位是我们对网页元素进行位置固定的重点知识！

- 内边距：边框和内容区之间的距离，通过 padding 属性设置

- 内边距设置方法：
    padding-top:10px;
    padding-right:10px;
    padding-bttom:10px;
    padding-left:10px;
    - 简写：
    padding:上 右 左 下;
    padding:10px 20px 40px 30px;

- 外边距：元素边框的外围空白区域是外边距，通过 margin 属性设置

- 外边距设置方法：margin:;用法同上！

- 一般来说，把各个元素的内边距和外边距

##浮动
- 因为 div 元素是块级元素，独占一行的。如何在一行显示多个 div 元素？显然默认的标准流已经无法满足需求，这就要用到浮动。 
- 浮动可以理解为让某个 div元素（或者其他块级元素）脱离标准流，漂浮在标准流之上。
- 假设div2设置浮动，那么它将脱离标准流，但 div1、div3、div4 仍然在标
准流当中，所以 div3 会自动向上移动，占据 div2 的位置，重新组成一个流。
- 浮动的设置方法：
    float:left;
    float:right;
- 让标准流中的元素不受到浮动的影响
    clear:both;
    none:默认值。允许两边都可以有浮动对象
    left:不允许左边有浮动对象
    right:不允许右边有浮动对象
    both:不允许有浮动对象
- 如果连续多个元素设置浮动呢？
结论：被设置浮动的元素会组成一个流，并且会横着紧挨着排队，直到父元素的
宽度不够才会换一行排列。

##相对定位与绝对定位
1. 相对定位
    - 元素相对于原来的位置（也就是不加相对定位时，应该位于的位置）
    - 语法：
            div{
                position:relative;
                left:XXpx;
                right:XXpx;
                top:XXpx;
                bottom:XXpx;
            }
    - 为元素设置相对定位之后，元素依然会占据原来的空间，依然在标准流中！
    - 设置了left就不要设置right，设置了top就不要设置值bottom，这是矛盾的！

2. 绝对定位
    - position:absolute;
    left:;
    right:;
    top:;
    bottom:;
    - 为元素设置绝对定位之后，元素不会占据原来的空间，脱离了原来的队伍
    - 为元素设置了左右之后，元素就会脱离水平方向的标准流，为元素设置了上下之后，元素就会脱离竖直方向的标准流；脱离之后，会根据父元素的位置来确定当前元素的位置。

3. 固定定位
    - position:fixed;
    left:;
    right:;
    top:;
    bottom:;
    - 相对于浏览器的窗口进行定位，不会随着页面的滚动条而动！

4. 重叠元素的堆叠顺序设置
使用 z-index:;对设置了相对或绝对或固定定位的元素进行堆叠顺序的设置，设置的数值越
大即堆叠在越上层，该属性可以是负值。

##布局初探
- 布局是我们书写整个网页的基本，就是把整个页面的框架先打好，例如我们现实生活中房子
装潢的时候就有布局的概念，我们网页也是的，一个网页可以看成是由几个不同，这些组成部分我们可以使用 div 容器去存放他们（这也是 div 叫做容器的原因），布局有多种方式，这节课我们重点讲解下最常用的布局方式，固定浮动布局！

- 固定浮动布局
固定浮动布局即是用固定的值将元素的长度设置为固定不变， 然后配合浮动的技术实现整个页面的一个布局。
网页的主要内容一般都是在我们浏览器的中间位置展示的， 固定浮动布局会将中间的内
容整体长度使用固定的值定死， 因为是固定死的所以中间主要内容占用浏览器的长度空间是有讲究的，这个需要跟我们的用户的屏幕分辨率对应起来，不要超过大多数的人屏幕分辨率的长度。（一般设置为1000px）

- 块级元素怎么相对于父元素居中？
元素需要设置长度，元素左右的外边距设置为 auto 即可！

- 元素都可以看成是一个盒子，这些盒子很多都有一个自己默认的内边距或者外
边距，并且每个浏览器默认的距离还有可能不太一样，这样对于我们页面布局或者具体
的细节的定位产生影响，那么我们应该怎么办？
上下外边距为0，左右外边距自动居中。
margin:0 auto;
