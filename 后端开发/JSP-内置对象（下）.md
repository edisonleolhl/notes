>本文包括
>
>1. session（常用）
>
>2. application（常用）
>
>3. page（不常用）
>
>4. pageContext（不常用）
>
>5. pageConfig（不常用）
>
>5. exception（不常用）

##1、session（常用）

###1.1、什么是session？

1. session表示客户端与服务器的一次**会话**。

2. Web中的session指：用户在浏览某个网站时，从进入网站到浏览器关闭所经过的这段时间，也就是用户浏览这个网站所花费的时间。

3. 从上述定义中可以看到，session实际是一个【特定的时间概念】。

4. 在服务器的内存中保存着不同用户的session。即session是保存在服务器的内存中，是与用户一一对应的。

###1.2、session对象

1. session对象简介

    ![](http://upload-images.jianshu.io/upload_images/2106579-efccc23e59ca02d2.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2. 常用方法

    ![](http://upload-images.jianshu.io/upload_images/2106579-9a40140068fe2c87.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3. 示例：

    ![](http://upload-images.jianshu.io/upload_images/2106579-9a40140068fe2c87.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###1.3、session对象的生命周期

session的生命周期大致可分为三个阶段：创建、活动、销毁。

1. 创建：

    ![](http://upload-images.jianshu.io/upload_images/2106579-768f8aab2946b4e5.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2. 活动：

    ![](http://upload-images.jianshu.io/upload_images/2106579-106827a112db87ed.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3. 销毁

    ![](http://upload-images.jianshu.io/upload_images/2106579-9e449c0a08c1f041.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    - session对象的超时时间
        
        ![](http://upload-images.jianshu.io/upload_images/2106579-4b0cc769f096e027.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##2、application（常用）

- **application对象属于服务器，不属于具体的某个项目。**

    ![](http://upload-images.jianshu.io/upload_images/2106579-e7778cf37ec6bc3d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 常用方法

    ![](http://upload-images.jianshu.io/upload_images/2106579-efc0815a1b94ce5c.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 示例：
    
    ![](http://upload-images.jianshu.io/upload_images/2106579-d22056e88b7f561f.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
    
    运行结果：

    ![](http://upload-images.jianshu.io/upload_images/2106579-e731eafcccf0e08e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##3、page（不常用）

- page对象简介与常用方法

    ![](http://upload-images.jianshu.io/upload_images/2106579-00cbf24336546bac.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    以上方法基本上就是object类的常用方法。

- 示例：
    
    ![](http://upload-images.jianshu.io/upload_images/2106579-6e24a98fe0331017.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    运行结果：

    ![](http://upload-images.jianshu.io/upload_images/2106579-e4cf990dacda038b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    分析：

    在apache-tomcat-6.0.37\work\Catalina\localhost\JspSessionLifeCycleDemo\org\apache\jsp\page_jsp.java文件中有个page_jsp类，@a010ba为HashCode码。

    page.toString()是将页面的类的位置加上它的hashcode打印出来

##4、pageContext（不常用）

- pageContext对象：

    ![](http://upload-images.jianshu.io/upload_images/2106579-666088325c852bb6.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 常用方法：

    ![](http://upload-images.jianshu.io/upload_images/2106579-d41e2e7e59e35084.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##5、pageConfig（不常用）
- 简介
    
    ![](http://upload-images.jianshu.io/upload_images/2106579-9e563de6b4824b9c.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##6、exception（不常用）

- 简介

    ![](http://upload-images.jianshu.io/upload_images/2106579-966c7781d30fe9da.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 使用方法
    
    1. 在可能会抛出异常的页面page指令里，设置errorPage="xxx.jsp"，表示出现异常将抛给xxx页面去处理
    
    2. 在xxx页面里，要使用Exception对象，需要把page指令里的isErrorPage属性设置为true。

    3. 比如：errorPage="exception.jsp";表示如果当前页面出现异常，交给exception.jsp页面处理异常，在exception.jsp中使用isErrorPage=“true” 来显示是处理异常页面。

    4. 常用方法：getMessage()和toString()方法

>本文参考：http://www.imooc.com/learn/166
