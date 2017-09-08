##启动与停止MySQL服务
在cmd界面中启动与停止mysql服务：
1. net start mysql
2. net stop mysql
3. 在windows服务列表中中找到MySQL服务就可以启动或停止MySQL服务。所有的Windows服务都可以通过它们来启动、关闭。
4. 我的mysql版本是5.7，在开始菜单中可以找到如下图所示的界面，打开command line client（图中有两个命令行工具，其中一个是utf-8模式，另外一个是unicode模式）
    ![](http://upload-images.jianshu.io/upload_images/2106579-e9c2b34bc7be01de.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

>关于cmd界面无法启动mysql（提示mysql不是有效命令）的原因：
1. 必须要使用管理员身份运行cmd程序。
2. 如果下载MySQL5.7版本的，在windows服务上MySQL的名字默认是MySQL57，因此在cmd运行 net start/stop mysql 是无效的，必须改成 net start/stop mysql57才行。（有点坑，我是进入windows的服务界面，看到服务名称叫做mysql57，网上寻找答案才知道的）

##登陆与退出
还是在cmd界面：
1. mysql的登陆：
    - mysql -uroot -p
    - mysql -uroot -pXXX
    - 第一种方法是安全的做法，输入命令回车后会提示输入密码，输入的时候是加密的
    - 第二种方法中XXX即超级用户（名为root）的密码，这是可见的
    - 登陆时还有其他参数可以写，比如：
        - -P参数是当前端口号3306；
        - -h参数是服务器名称，如果要连接到本地服务器是127.0.0.1(本地回环地址)；
        - 当默认端口号没有被修改-P可以不写，如果实用的是本地服务器-h也可以不用加；

2. mysql的退出:
    - exit
    - quit
    - \q

##修改MySQL提示符
1. 方式一：连接客户端时通过参数指定
        ...>mysql -uroot -pXXX --prompt 提示符

2. 方式二：连接上客户端后， 通过prompt命令修改
        mysql>prompt 提示符

3. 例如：
        ...>mysql -uroot -p. --prompt \h
        ...
        ...
        localhost 
    输入完上面的命令后，光标闪烁在localhost后面，紧接着再输入`prompt mysql>`：
        localhostprompt mysql>
        PROMPT set to 'mysql>'
        mysql>prompt \u@\h \d>
        PROMPT set to '\u@\h \d>' //设置格式
        root@localhost (none)>
    这时候的MySQL提示符就比较直观友好了，格式为：用户名@主机名 数据库名，显而易见，这时因为没有选择数据库，所以显示none。

##MySQL语句规范：
1. 关键字和函数名称全部大写
2. 数据库名称、表名称、字段名称全部小写
3. SQL语句必须以分号结尾
4. 常用语句
    - SELECT VERSION(); 查询当前服务器版本
    - SELECT NOW(); 查询当前日期时间
    - SELECT USER(); 查询当前用户

##操作数据库
1. 数据库创建：CREATE
    -  语法：
            CREATE {DATABASE | SCHEMA} [IF NOT EXISTS] db_name [DEFAULT] CHARACTER SET [=] charset_name.
    -  中括号内的是可省略的关键字,花括号内的是必须选择其一的一些关键字 
    -  DATABASE和SCHEMA是相同的，任选其一
    -  IF NOT EXISTS:如果没有这个关键字且创建的数据库存在，则会报错；若有这个关键字且创建的数据库存在，则只报出warning，不写会报错，然后可借助以下语法来得到想要的信息：
            show warnings;  --展示警告信息
    -  CHRARCTER SET gbk:为表设置编码方式，如果不设置则用mysql默认的编码方式
    -  
2. 查看数据库列表：SHOW
    - 语法：
            SHOW { DATABASE | SCHEMAS } [LIKE 'pattern' | WHERE expr]
            SHOW CREATE DATABASE xx
    - 第二种为显示xx数据库信息
    - 
3. 数据库的修改：ALTER
    - 修改数据库编码方式语法：
            ALTER { DATABASE | SCHEMAS } [db_name][DEFAULT] CHARACTER SET [=] charset_name 

4. 删除数据库：DROP
    - 删除数据库语法：
            DROP { DATABASE | SCHEMAS } [IF EXISTS] db_name;
