>本文包括：
>1. 枚举由来
>2. 如何使用？
>3. 枚举类特性
>4. 单例设计模式
>5. 定义特殊结构枚举
>6. 星期输出中文的案例
>7. 枚举类API




![Paste_Image.png](http://upload-images.jianshu.io/upload_images/2106579-8f08043a96e13fe1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)




##枚举（enum）

###1、枚举由来

- 定义一个仅容许特定数据类型值的有限集合。

- 例如，你可能需要一个称为“等级”，且仅可被赋值为“A”，“B”，“C”，“F”等值的类型，任何其他值在此类型中都是非法的，所以在Java5中产生了枚举。

###2、如何使用？

1. 如下使用关键字enum定义了一个简单的Grade对象，使用起来和其他的Java类型一样。

        public enum Grade {A, B, C, F}; //习惯全部大写！

2. 假设有一个员工类，在员工类定义角色属性，角色只有三个值：BOSS、MANAGER、WORKDER。

    - 第一次尝试：
    
            class Employee { // 员工类

                private String role1;

                public static void main(String[] args) {
                    Employee employee = new Employee();
                    employee.role1 = "BOSS";
                    employee.role1 = "MANAGER";
                    employee.role1 = "MANGAER";// 非法数据，但不会报错。如果不小心字符串拼错了，程序出问题,所以直接使用String类型作为角色属性，行不通！
                ｝
            ｝

    - 第二次尝试：

            class Employee { // 员工类

                private int role2; // 1 BOSS 2 MANAGE 3 WORKER

                public static void main(String[] args) {
                    Employee employee = new Employee();
                        employee.role2 = 1; // 可读性太差，如果角色有上十种，上百种呢？
                        employee.role2 = 4; // 非法数据，但不会报错。
                ｝
            ｝            

    - 第三次尝试：

            class Employee { // 员工类

                private int role2; // 1 BOSS 2 MANAGE 3 WORKER

                public static void main(String[] args) {
                    Employee employee = new Employee();
                    employee.role2 = Role2.BOSS; // 相比于第二次尝试，可读性好了很多
                    employee.role2 = -1; // 非法数据，但不会报错。
                ｝
            ｝    

            class Role2 {
                public static final int BOSS = 1;
                public static final int MANAGER = 2;
                public static final int WORKER = 3;
            }

    - 第四次尝试：

            private Role3 role3; // 在 JDK5 之前 没有枚举，通过自定义类 实现枚举功能

            class Employee { // 员工类

                private Role3 role3; // 在 JDK5 之前 没有枚举，通过自定义类 实现枚举功能

                public static void main(String[] args) {
                    Employee employee = new Employee();
                    //通过自定义Role3实现了枚举功能
                    employee.role3 = Role3.BOSS; // 可读性好
                    employee.role3 = 1; // 非法数据，但会报错！
                    employee.role3 = new Role3(); // 非法数据，但不会报错！检查不出来
                
                ｝
            ｝    

            class Role3 { // 枚举功能 类
                public static final Role3 BOSS = new Role3();
                public static final Role3 MANAGER = new Role3();
                public static final Role3 WORKER = new Role3();
            
                private Role3() {
                }
            }

    - 第五次尝试：

            class Employee { // 员工类

                private Role4 role4; // 在 JDK5 之后 引入枚举，使用枚举表示多个角色

                public static void main(String[] args) {
                    Employee employee = new Employee();
                    // 使用枚举之后
                    employee.role4 = Role4.MANAGER; // 可读性良好，阻止非法数据
                    employee.role4 = new Role4(); // 枚举具有私有构造方法，所以会报错！因此第五次尝试优于第四次尝试
                
                ｝
            ｝    

            enum Role4 { // JDK5 以后引用枚举技术 简化对象创建 ---- 功能等价于 Role3
                BOSS, MANAGER, WORKER;
            }

###3、枚举类特性

- 枚举类也是一种特殊形式的Java类。

- 枚举类中声明的每一个枚举值代表枚举类的一个实例对象。（可以查看.class文件，在里面明显有每一个枚举值的实例对象）

- 与Java类的普通类一样，在声明枚举类的同时，也可以声明属性、方法和构造函数，但**枚举类的构造函数必须是私有的**。（IDE中写构造器时会自动生成private，删除private也不会报错，默认就是private）

- 枚举类也可以实现接口，或继承抽象类。

- Java5中扩展了switch语句，它除了可以接受int、byte、chart、short外，还可以接受一
个枚举类型。（Java7 switch 可以接受六种 ： 多了一种String）

- 若枚举类只有一个值，则可以当作单例设计模式使用。（见4、单例设计模式）

###4、单例设计模式

1. 单例设计模式写法，必须包括以下三点，因此枚举类若只有一个值，则可以当作单例设计模式使用。

    1. 私有构造器

    2. private static 成员对象

    3. public static 获得成员对象方法

2. 懒汉式 和 饿汉式 
    
    - 饿汉：在创建对象时 直接进行初始化
    
    - 懒汉：在获取对象时 进行初始化

3. 示例：

        // 饿汉
        class B {
            // 1、私有构造器
            private B() {
            }
        
            // 2、private static 对象成员
            private static B b = new B();
        
            // 3、提供public static 获得成员方法 , 获得唯一实例
            public static B getInstance() {
                return b;
            }
        }
        
        // 懒汉
        class C {
            // 1、私有构造器
            private C() {
            }
        
            // 2、private static 对象成员
            private static C c;
        
            // 3、提供public static 获得成员方法 , 获得唯一实例
            public static C getInstance() {
                if (c == null) {
                    c = new C(); // 懒汉式
                }
                return c;
            }
        }
        
        enum A {
            TEST; // 该枚举中只有 TEST实例 ，相当于单例设计模式！
        }

###5、定义特殊结构枚举

- 在枚举实例定义过程中

    1. 向枚举构造器传入参数。

    2. 在枚举中定义方法。

    3. 通过匿名内部类实现枚举中抽象方法。

- . 示例：
        public enum EnumConstructorTest {
            A(10) { // 通过匿名内部类实现抽象方法
                @Override
                public void show() {
                }
        
            },
            B(20) {
                @Override
                public void show() {
        
                }
        
            }; // 创建枚举值时，传入构造方法参数
        
            // 构造方法 带有参数
            private EnumConstructorTest(int a) {
            }
        
            // 在枚举中定义方法
            @Override
            public String toString() {
                return super.toString();
            }
        
            public void print() {
                System.out.println("TEST");
            }
        
            // 在枚举中定义抽象方法
            public abstract void show();
        }

###6、星期输出中文的案例

- 加深印象：为什么要用枚举类，如何使用枚举类。

        public class WeekDayTest {
            public static void main(String[] args) {
                WeekDay1 day1 = WeekDay1.Fri;
                day1.show();
        
                WeekDay2 day2 = WeekDay2.Wed;
                day2.show();
            }
        }
        
        enum WeekDay2 {
            Mon {
                @Override
                public void show() {
                    System.out.println("星期一");
                }
            },
            Tue {
                @Override
                public void show() {
                    System.out.println("星期二");
                }
            },
            Wed {
                @Override
                public void show() {
                    System.out.println("星期三");
                }
            },
            Thu {
                @Override
                public void show() {
                    System.out.println("星期四");
                }
            },
            Fri {
                @Override
                public void show() {
                    System.out.println("星期五");
                }
            },
            Sat {
                @Override
                public void show() {
                    System.out.println("星期六");
                }
            },
            Sun {
                @Override
                public void show() {
                    System.out.println("星期日");
                }
            };
            public abstract void show();
        }
        
        enum WeekDay1 {
            Mon, Tue, Wed, Thu, Fri, Sat, Sun;
        
            // 编写方法 show
            public void show() {
                // 根据枚举对象 名字 返回响应中文星期
                if (this.name().equals("Mon")) {
                    System.out.println("星期一");
                } else if (this.name().equals("Tue")) {
                    System.out.println("星期二");
                } else if (this.name().equals("Wed")) {
                    System.out.println("星期三");
                } else if (this.name().equals("Thu")) {
                    System.out.println("星期四");
                } else if (this.name().equals("Fri")) {
                    System.out.println("星期五");
                } else if (this.name().equals("Sat")) {
                    System.out.println("星期六");
                } else if (this.name().equals("Sun")) {
                    System.out.println("星期日");
                }
            }
        }

###7、枚举类API

1. Java中声明的枚举类，均是java.lang.Enum类的子类，它继承了Enum类的所有方法。
常用方法：

    - name() 返回枚举对象名称

    - ordinal() 返回枚举对象下标

    - valueOf(Class enumClass, String name) 将String类型 枚举对象名称 转换为对应的Class类型枚举对象

2. 自定义的枚举类，在编译阶段自动生成下面方法（即在API中没有，在编译后的.class文件可以找到）：

    - valueOf(String name) 自定义枚举类的方法，转换枚举对象
        
    - values() 获得所有枚举对象实例数组
        
3. 五种方法示例：

        public enum Color {
            BLUE, RED, YELLOW;
            // public static final Color color = new Color();
        
            Color() {// 构造器默认private
            }
        }
        
        public class EnumAPITest {
            @Test
            public void demo1() {
                // 任何 enum 定义 枚举类 都是默认 继承 Enum 类 ，使用Enum 中方法
                Color color = Color.RED; // 枚举对象 不能 new 获得，使用已经创建好对象
        
                // name 方法返回 枚举 实例名称
                System.out.println(color.name());
        
                // ordinal 方法 返回 枚举对象 下标
                System.out.println(color.ordinal());
        
                // valueOf 方法 将 String 类型 枚举对象 名称 ----- 转换为相应枚举对象
                String name = "YELLOW";
                Color yellow = Enum.valueOf(Color.class, name); // 将 name 转换 成响应枚举对象
                System.out.println(yellow.ordinal());
        
                // 使用枚举类 编译后生成两个方法

                // values 获得 所有 枚举对象数组
                Color[] colors = Color.values();
                System.out.println(Arrays.toString(colors));
        
                // 生成valueOf 只接受String 类型枚举名称，将名称转换为当前枚举类对象
                String name2 = "BLUE";
                Color blue = Color.valueOf(name2); // 将name2 枚举对象名称 转换 Color对象枚举实例
                System.out.println(blue.ordinal());
            }
        }
    
4. 枚举对象、枚举对象下标、枚举对象名，三者之间的相互转换（用上五种方法，必须掌握！）：

        @Test
        // 枚举对象、枚举对象下标、枚举对象名称表示之间的转换
        public void demo2() {
            // 第一种 已知枚举对象 --- 获得下标和名称
            Color blue = Color.BLUE;
            // 获得下标
            System.out.println(blue.ordinal());
            // 获得名称
            System.out.println(blue.name());
    
            System.out.println("----------------------------------");
            // 第二种 已知枚举对象 下标 --- 获得枚举对象实例 和 名称
            int index = 1;
            // 获得枚举对象
            Color red = Color.values()[index];
            // 获得名称
            System.out.println(red.name());
    
            System.out.println("---------------------------------");
            // 第三种 已知枚举对象名称 ----- 获得枚举对象实录 和 下标
            String name = "YELLOW";
    
            // 获得实例
            Color c1 = Enum.valueOf(Color.class, name);
            Color c2 = Color.valueOf(name);
    
            // 获得下标
            System.out.println(c1.ordinal());
            System.out.println(c2.ordinal());
        }

>参考阅读：
>《Effective Java 中文版 第2版》chapter 6 
>《JAVA 5.0 TIGER程序高手秘籍》chapter 3
