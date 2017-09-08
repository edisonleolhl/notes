#JavaScript基础
---
>1. JavaScript简介
>2. JavaScript对象

##JavaScript简介
1. 为什么使用javaScript?
    - 在客户机验证，减轻服务器压力
    - 在网页上能展现各种动态效果

2. JavaScript是什么？
    - a.javaScript是脚本语言
    - 特点：
       - 在html页面添加交互效果
       - 语法与java类似
       - 解释性语言，无需编译

3. 如何使用javaScript?
    - 3-1:文档内部使用
            <head>
                <script type="text/javascript">
                  <!--
                     js代码
                  -->
                </script>
            </head>
    >` <script>…</script>`可以包含在文档中的任何地方，只要保证这些代码在被使用前已读取并加载到内存即可。

    - 3-2:文档外部使用
        a.建立*.js文件
        b.在html中引用js文件
             <script type="text/javascript" src="js路径"></script>
        c.外部文件不能包含`<script>`标签，通常将.js文件放到网站目录中单独存放脚本的子目录中（一般为js），这样容易管理和维护。
    
    - 3-3直接在HTML标签中
            <input name="btn" type="button" value="弹出消息框" onclick="javascript:alert('欢迎你');"/>

4. 核心语法
    1. 变量
    var——用于声明变量的关键字
        - 先声明变量再赋值
                var   width;
                width = 5;

        - 同时声明和赋值变量
                var catName= “皮皮”;
                var x, y, z = 10;

        - 不声明直接赋值
                width=5;

        - 变量可以不经声明而直接使用，但这种方法很容易出错，也很难查找排错，不推荐使用。
        - JavaScript区分大小写，特别是变量的命名、语句关键字等

    2. 数据类型
        - undefined
                var width;
                变量width没有初始值，将被赋予值undefined

        - null
            - 表示一个空值，与undefined值相等

        - number
                var iNum=23;   //整数
                var iNum=23.0;   //浮点数

        - boolean
            - true和false
            
        - string
            - 一组被引号（单引号或双引号）括起来的文本
                    var string1="This is a string";
    3. String对象
        - 属性
            字符串对象.length
                    var str="this is JavaScript";
                    var strLength=str.length;    //长度是18
        - 方法
            字符串对象.方法名();
                charAt(index)：返回在指定位置的字符
                indexOf(str，index)：查找某个指定的字符串在字符串中首次出现的位置
                substring(index1，index2)：返回位于指定索引index1和index2之间的字符串，并且包括索引index1对应的字符，不包括索引index2对应的字符
                split(str)：将字符串分割为字符串数组
    4. typeof运算符
        - typeof检测变量的返回值
        - typeof运算符返回值如下：
                undefined：变量被声明后，但未被赋值
                string：用单引号或双引号来声明的字符串
                boolean：true或false
                number：整数或浮点数
                object：javascript中的对象、数组和null
    5. 数组
        - 创建数组
                var  数组名称 = new Array(size);
        - 为数组元素赋值
                var fruit= new Array("apple", "orange", " peach","bananer");
        - 访问数组
                var fruit = new Array(4);
                fruit [0] = " apple ";
                fruit [1] = " orange ";
                fruit [2] = " peach ";
                fruit [3] = " bananer ";
        - 属性
                length：设置或返回数组中元素的数目
        - 方法
                join():把数组的所有元素放入一个字符串，通过一个的分隔符进行分隔
                sort():对数组排序
                push():向数组末尾添加一个或更多元素，并返回新的长度
    6. 运算符号
    7. 逻辑控制语句
    8. 循环中断
    9. 注释
    10. 常用的输入/输出
        - alert(“提示信息”);
        - prompt()
        prompt(“提示信息”, “输入框的默认信息”);
        prompt(“请输入姓名”, “张三”);
        prompt(“请输入姓名”);
        - document.write("内容");

5. 函数
    - 函数的含义：类似于Java中的方法，是完成特定任务的代码语句块
    - 使用更简单：不用定义属于某个类，直接使用
    - 函数分类：系统函数和自定义函数
        - 常用系统函数
                parseInt ("字符串")
                    将字符串转换为整型数字 
                    如: parseInt ("86")将字符串“86”转换为整型值86
                parseFloat("字符串")
                    将字符串转换为浮点型数字 
                    如: parseFloat("34.45")将字符串“34.45”转换为浮点值34.45
                isNaN()
                    用于检查其参数是否是非数字
        - 自定义函数
            - 定义函数
                    function 函数名(参数1,参数2,参数3,…){ //可有参可无参
                         //JavaScript语句;
                         [return 返回值] //可有可无
                    }
            - 调用函数
                函数调用一般和表单元素的事件一起使用，调用格式：
                 事件名＝ "函数名( )" ;
                    function showHello(count)
                    {
                       for(var i=0;i<5;i++)
                          {
                             document.write("<h2>Hello World</h2>");         
                          }
                    }
                    ...
                    <input name="btn" type="button" value="显示10次HelloWorld" onclick="showHello(showHello(prompt('请输入显示HelloWorld的次数：',''))" />
        - 匿名函数
    
    - 例子：
            function showHello()
            {
                var count = prompt("请输入考试科目数量","0");
                count = parseInt(count);
                if(isNaN(count)){
                    alert("您输入的不是数字！");
                    return;
                }
                var num = new Array(count);
                var sum = 0;
                for (var i = 0; i < num.length; i++) {
                    num[i] = prompt("请输入考试成绩","0");
                    num[i] = parseInt(num[i]);
                    if(isNaN(num[i])){
                        alert("您输入的不是数字！");
                        i--;
                        continue;
                    }
                    if(num[i]<0){
                        alert("您输入的是负数！");
                        i--;
                        continue;
                    }
                    sum+=num[i];
                };
                alert(sum);
            }
            。。。
            <input name="btn" type="button" value="计算考试科目总成绩" onclick="showHello()" >
6.  变量的作用域
    1. 局部变量
    2. 全局变量

##JavaScript对象
1. BOM:浏览器对象模型：javascript对浏览器对象的描述，包含windw对象、history对象、docuemnt对象、location对象
    >上传JavaScript第二章ppt中的BOM模型图
    >8/22/2016 4:14:45 PM 
    
    BOM可实现的功能：
    1. 弹出新的浏览器窗口
    2. 移动、关闭浏览器窗口以及调整窗口的大小
    3. 页面的前进、后退
        
2. Window对象：window对象是整个BOM的核心
    - 常用属性：
    history :访问过的url记录
    location: 地址栏信息
            window.属性名= "属性值" 
            window.location="http://www.sohu.com" ;      

    - 常用方法：
    prompt()用户输入框
    alert()警告框，带有一个提示信息和一个确定按钮
    confirm()确认提示框，带有提示信息、确定和取消按钮
            var flag=confirm("确认要删除此条信息吗？");
            if(flag==true)
                alert("删除成功！");
            else
                alert("你取消了删除");

    open()打开新窗体
    close()关闭窗体
    setTimeout( )在指定的毫秒数后调用函数或计算表达式
    setInterval( )按照指定的周期（以毫秒计）来调用函数或表达式
    - 常用事件
    onload一个页面或一幅图像完成加载
    onmouseover鼠标移到某元素之上
    onclick当用户单击某个对象时调用的事件句柄
    onkeydown某个键盘按键被 按下
    onchange域的内容被改变

3. History对象和Location对象
    - history对象：history代表的是浏览器的历史对象。
        常用方法：
        - back()加载 history 对象列表中的前一个URL
        - forward()加载 history 对象列表中的下一个URL 
        - go()加载 history 对象列表中的某个具体URL

        - 浏览器中的“后退”
        `history.back()`等价`history.go(-1)`
        - 浏览器中的“前进”
        `history.forward()`等价`history.go(1) `

    - location对象：location对象代表浏览器的地址栏。
        - 常用属性
            - host设置或返回主机名和当前URL的端口号
            - hostname设置或返回当前URL的主机名
            - href设置或返回完整的URL

        - 常用方法
            - reload()重新加载当前文档
            - replace()用新的文档替换当前文档
            
4. Document对象
    - 常用属性：    
        - referrer:返回载入当前文档的文档的URL
        - URL:返回当前文档的URL
        - 语法：
        document.referrer
        document.URL
        - 例子：
                var preUrl=document.referrer;  //载入本页面文档的地址
                if(preUrl==""){    
                      document.write("<h2>您不是从领奖页面进入，5秒后将自动 
                                         跳转到登录页面</h2>");
                      setTimeout("javascript:location.href='login.html'",5000);
                }
    - 常用方法：
        - 根据指定id查找元素（对象的id唯一
        document.getElementById("元素的id");
        返回的是一个对象
                document.getElementById("node").innerHTML="搜狐";

        - 根据元素的名字查找元素（相同name属性
        document.getELementsByName("元素名字");
        返回的是数组对象
                var aInput=document.getElementsByName("season");
                var sStr="";
                for(var i=0;i<aInput.length;i++){
                    sStr+=aInput[i].value+"<br />";
                }
                document.getElementById("s").innerHTML=sStr;

        - 根据标签名字查找元素
        document.getElementsByTagName("标签名");
        返回的是数组对象
                var aInput=document.getElementsByTagName("input");
                var sStr="";
                for(var i=0;i<aInput.length;i++){
                      sStr+=aInput[i].value+"<br />";
                }
                document.getElementById("s").innerHTML=sStr;

        - write() 向文档写文本、HTML表达式或JavaScript代码
        
5. JavaScript内置对象
    - Array：用于在单独的变量名中存储一系列的值。
        length        数组长度     Var arr = new Array(3);  arr.length
        constructor    数组对象的函数原型    alert(arr.constructor);
        prototype    添加数组对象的属性    Array.prototype.show = function() { …}
        concat()    合并数组            c.concat(a, b);
        join()    将数组转换为字符串        S = arr.join(“-”);
        pop()    删除并返回最后一个元素        r = arr.pop();
        push()    添加元素并返回数组的长度        N = arr.push(50, 60); 
        shift()    删除并返回第一个元素        S = arr.shift();
        unshift()    添加元素至数组开始处    arr.unshift(8, 9); 
        slice()    取数组中的一部分重组新数组    var e = arr.slice(1, 3);
        splice()    从数组中删除或替换元素    arr.splice(1, 2);
        sort()        排序数组            arr.sort();
        reverse()    倒序数组            arr.reverse();
    - String：用于支持对字符串的处理。
        1. String对象的属性
        length    获取字符串字符的个数
        2. String对象的常用方法
        ========================================处理字串方法
        fromCharCode(65)    数字－>字符  ASCII码转换
        charCodeAt(位置)        字串对象在指定位置的字符编码
        charAt(位置)        字串对象在指定位置处的字符
        indexOf(字符)        字符所处位置
        lastIndexOf(字符)    从后往前查询字符
        substr(开始位置[，长度])    取子字串
        subString(开始，结束)    取子字串
        split([分隔符])        分隔字串到一个数组中
        replace(旧字串，新字串)    替换字串
        toLowerCase()        变为小写字母
        toUpperCase()        变为大写字母
        =========================================字串显示方法
        bold( )        加粗    
        italics()    斜体    
        big()        变大    
        small()        变小    
        sub()        上标    
        sup()        下标    
        strike()    删除线    
        fontcolor(颜色)    改变字串颜色    
        fontsize(大小)    改变字串大小    
        link(url)    产生HTML的链接字符    str.link("www.163.com")
    - Math：用于执行常用的数学任务，它包含了若干个数字常量和函数。
        1. Math对象的常用属性与方法
            - PI        3.1415    
            - abs(x)        返回X的绝对值    
            -     max(x,y)    两者最大值    
            -     min(x,y)    两者最小值    
            -     pow(x, y)    返回x的y次方    
            -     sqrt(x)        返回x的平方根    
            -     toFixed(x)    返回四舍五入后保留x位小数的数    
            -     toPrecision(x)    返回四舍五入后保留x位字符的数    
            - ceil()对数进行上舍入
                    Math.ceil(25.5);返回26
                    Math.ceil(-25.5);返回-25
        
            - floor()对数进行下舍入
                    Math.floor(25.5);返回25
                    Math.floor(-25.5);返回-26
        
            - round()把数四舍五入为最接近的数
                    Math.round(25.5);返回26
                    Math.round(-25.5);返回-26
        
            - random()返回0~1之间的随机数
                    Math.random();例如：0.6273608814137365
            - 如何实现返回的整数范围为2~99？
                    var iNum=Math.floor(Math.random()*98+2);
        2. 常数 NaN 和函数 isNaN(x)
        在使用数学对象的过程中，当得到一个无意义的结果时，将返回一个特殊的值”NaN”,表示“不是一个数”。
                var a = parseInt("xx"); alert(a);
                if(isNaN(a))  alert(“A不是一个数字”);

        3. 无穷大 Infinity 和函数 isFinite(x)
        当除数为零时结果会得到一个“无穷大”的值 。
                var x = 10/0;  alert(x);
                if(!isFinite(x)) { alert("by zero div");}

    - Date：用于操作日期和时间。
        - 语法：   var 日期对象=new Date(参数)
         参数格式：MM  DD,YYYY,hh:mm:ss
        
        - 常用方法：
            - getDate()返回 Date 对象的一个月中的每一天，其值介于1～31之间
            - getDay()返回 Date 对象的星期中的每一天，其值介于0～6之间。
            
            >getDay()：0－表示周日，1－表示周1，6－表示周6。
            - getHours()返回 Date 对象的小时数，其值介于0～23之间
            - getMinutes()返回 Date 对象的分钟数，其值介于0～59之间
            - getSeconds()返回 Date 对象的秒数，其值介于0～59之间
            - getMilliseconds()    获得豪秒数
            - getTime()        获得自1970年1月1日来的毫秒数
            - getMonth()返回 Date 对象的月份，其值介于0～11之间
    
            >getMonth()：0－11，0表示1月分，11表示12月份。
            - getFullYear()返回 Date 对象的年份，其值为4位数
            - getTime()返回自某一时刻（1970年1月1日）以来的毫秒数
        
        - 使用Date对象的方法显示当前时间的小时、分钟和秒。（<span style="color:red;font-weight:bold;">静态</span>！）
                function disptime(){ 
                    var today = new Date(); //获得当前时间
                    var hh = today.getHours(); 
                    var mm = today.getMinutes();
                    var ss = today.getSeconds();
                    document.getElementById("myclock").innerHTML=
                                                                                                   hh+":"+mm+":"+ss;
                }
                ...
                <body onload="disptime()">
                <div id="myclock"></div>
        - var  myTime＝setTimeout("disptime() ", 1000 );
        1秒(1000毫秒)之后执行函数disptime()一次
        - var  myTime＝setInterval("disptime() ", 1000 );
        每隔1秒(1000毫秒)执行函数disptime()一次
        - 如果要多次调用，使用setInterval()或者让disptime()自身再次调用setTimeout()
        - 若要清除：
                clearTimeout(setTimeOut()返回的ID值)
                clearInterval(setInterval()返回的ID值)
        - 例子：
            function disptime(){
                var today = new Date();          //获得当前时间
                var hh = today.getHours();    //获得小时、分钟、秒
                var mm = today.getMinutes();
                var ss = today.getSeconds();
                /*设置div的内容为当前时间*/
                document.getElementById("myclock").innerHTML="现在是:<h1>"+hh
                +":"+mm+": "+ss+"<h1>";
            }
            /*使用setInterval()每间隔指定毫秒后调用disptime()*/
            var myTime = setInterval("disptime()",1000);
