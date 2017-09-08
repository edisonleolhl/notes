#Java 中的 static 使用之静态变量#
---
大家都知道，我们可以基于一个类创建多个该类的对象，每个对象都拥有自己的成员，互相独立。然而在某些时候，我们更希望该类所有的对象共享同一个成员。此时就是 static 大显身手的时候了！！

Java 中被 static 修饰的成员称为静态成员或类成员。它属于整个类所有，而不是某个对象所有，即被类的所有对象所共享。静态成员可以使用类名直接访问，也可以使用对象名进行访问。当然，鉴于他作用的特殊性更推荐用类名访问~~

使用 static 可以修饰变量、方法和代码块。

例如，我们在类中定义了一个 静态变量 hobby ，操作代码如下所示：

![](http://upload-images.jianshu.io/upload_images/2106579-a12c61dfebad61cd.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

运行结果：

![](http://upload-images.jianshu.io/upload_images/2106579-68a20fd58fe64a2f.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> 要注意哦：静态成员属于整个类，当系统第一次使用该类时，就会为其分配内存空间直到该类被卸载才会进行资源回收！~~

---
# Java 中的 static 使用之静态方法 #
---

与静态变量一样，我们也可以使用 static 修饰方法，称为静态方法或类方法。其实之前我们一直写的 main 方法就是静态方法。静态方法的使用如：

![](http://upload-images.jianshu.io/upload_images/2106579-5b6f5bf1edff67df.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

运行结果：

![](http://upload-images.jianshu.io/upload_images/2106579-d527ebcee7832ea9.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 需要注意： ###

1. **静态方法中可以直接调用同类中的静态成员，但不能直接调用非静态成员**。如：
![](http://upload-images.jianshu.io/upload_images/2106579-d9022d39dc57426a.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
如果希望在静态方法中调用非静态变量，可以通过创建类的对象，然后通过对象来访问非静态变量。如：
![](http://upload-images.jianshu.io/upload_images/2106579-a124b4134a980814.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
1. **在普通成员方法中，则可以直接访问同类的非静态变量和静态变量**，如下所示：
![](http://upload-images.jianshu.io/upload_images/2106579-a2cadb144425e6a7.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
1. **静态方法中不能直接调用非静态方法，需要通过对象来访问非静态方法**。如：
![](http://upload-images.jianshu.io/upload_images/2106579-7d401b2783aebb65.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

---
# Java 中的 static 使用之静态初始化块 #
---
Java 中可以通过初始化块进行数据赋值。如：

![](http://upload-images.jianshu.io/upload_images/2106579-6dd1703e3b140f0b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> 在类的声明中，可以包含多个初始化块，当创建类的实例时，就会依次执行这些代码块。如果使用 static 修饰初始化块，就称为静态初始化块。

需要特别注意：**静态初始化块只在类加载时执行，且只会执行一次，同时静态初始化块只能给静态变量赋值，不能初始化普通的成员变量。**

我们来看一段代码：

![](http://upload-images.jianshu.io/upload_images/2106579-4ebdb80922041909.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

运行结果：

![](http://upload-images.jianshu.io/upload_images/2106579-af4a7f5950b13069.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

通过输出结果，我们可以看到，程序运行时静态初始化块**最先被执行**，然后执行**普通初始化块**，**最后才执行构造方法**。由于**静态初始化块只在类加载时执行一次**，所以当再次创建对象 hello2 时并未执行静态初始化块。
