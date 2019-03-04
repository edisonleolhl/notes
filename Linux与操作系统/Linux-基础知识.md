> 本文包括：

> 1、Linux 系统概述

> 2、Linux 用户和用户组管理

> 3、Linux 文件和目录管理

> 4、Linux 文件系统管理

> 5、Linux LVM 配置

> 6、Linux 网络管理

> 7、Linux 进程与任务管理

> 8、Linux 系统监控

> 9、Linux 管道与I/O重定向

> 10、Linux 安装与管理软件

##1、Linux 系统概述
1. Linux 的发展：离不开它的前身 Unix
  
	- Unix 的发展：

	    1970 年，Ken Thompson 研发出 Unix 内核；1970 年为Unix 元年

	    1973 年，Ritchie 用 C 语言编写了 Unix 内核，Unix 正式诞生；

	    1974 年，Unix 对外公布，开始广泛流行。

	- Linux 的产生和发展：

	    1986 年，Tanenbaum 研发出 MINIX，并于次年发布；

	    1991 年，Linus 研发出 Linux 内核的雏形；

	    1994 年，Linux 1.0 内核发布；

	    1995 年以后，各种不同的 Linux 发行版本相继出现。

	- Linux 发行版本（内核是一样的）：

	     Redhat 、SUSE Enterprise、CentOS：侧重于网络服务，企业管理

	     Debian、Stackware：侧重于服务器及其稳定性

	     Ubuntu、Fedora、Open SUSE：侧重于用户体验
  
	- Unix 和 Linux 的区别：

		|Unix|Linux|
		|--|--|
		|商业付费|免费开源|
		|与硬件配套|跨平台|
		|对硬件要求苛刻|对硬件要求很低|
		|安装复杂|安装简单|
		|使用复杂|使用简单|
		|稳定|次稳定（好于Windows）|

2. Linux 的结构：
  
	- 应用程序
  
	- 外壳（shell）：用户和内核之间的**命令解释器**，可以根据自己的需求更换 shell，shell 与 kernel 可分离

		> 常见的 shell 有：bash（Linux 默认的 shell），sh（Unix 默认的 shell），ksh（korn shell），c shell 等等，其中以 bash（Bourne-Again Shell）最为流行：它基于 Bourne shell，吸收了 C shell 和 Ksh 的一些特性。bash 完全兼容 sh，也就是说，用 sh 写的脚本可以不加修改的在 bash 中执行
  	
	- 内核（kernel）：Linux 操作系统的**核心**，直接控制计算机资源
  
	- 硬件

3. Linux 的特点：
  
	- 多任务，多用户：CPU 时间分片，分给不同的进程；允许多个用户同时登陆使用。
  
	- 管道：前一个程序的输出作为后一个程序的输入，看起来好像管道一样

	- 功能强大的 shell：shell 是一种解释型高级语言
  
	- 安全保护机制，稳定性好：防止系统及其数据未经许可而被非法访问，稳定性 Unix 好于 Linux，Linux 好于 Windows
  
	- 用户界面：常用命令行的方式，同时提供图形界面

	- 强大的网络支持：TCP/IP 协议就是 Linux 的缺省网络协议
  
	- 移植性好：源代码用 C 语言写成，便于移植到其它计算机上

##2、Linux 用户和用户组管理

1. root 用户

  在 Linux 系统里， `root` 账户拥有整个系统至高无上的权利，比如 新建 / 添加 用户。

  > root 权限，系统权限的一种，与 SYSTEM 权限可以理解成一个概念，但高于 Administrator 权限，root 是 Linux 和 UNIX 系统中的超级管理员用户帐户，该帐户拥有整个系统至高无上的权力，所有对象他都可以操作，所以很多黑客在入侵系统的时候，都要把权限提升到 root 权限，用 Wigroupndows 的方法理解也就是将自己的非法帐户添加到 Administrators 用户组。更比如安卓操作系统中（基于 Linux 内核）获得 root 权限之后就意味着已经获得了手机的最高权限，这时候你可以对手机中的任何文件（包括系统文件）执行所有增、删、改、查的操作。

2. su && sudo

   我们一般登录系统时都是以普通账户的身份登录的，要创建用户需要 root 权限，这里就要用到 `sudo` 这个命令了。不过使用这个命令有两个大前提，一是你要知道当前登录用户的密码，二是当前用户必须在 `sudo` 用户组。

   `su <user>` 可以切换到用户 user，执行时需要输入目标用户的密码（注意**Linux 下密码输入是不显示任何内容的**），`sudo <cmd>` 可以以特权级别运行 cmd 命令，需要当前用户属于 sudo 组，且需要输入当前用户的密码。`su - <user>` 命令也是切换用户，同时环境变量也会跟着改变成目标用户的环境变量。

3. Linux 的用户和用户组

  在 Linux 操作系统中，Linux 用户会归属于用户组，那么归属于同一用户组的不同用户，它对一些公共文件具有相同的访问权限，每个用户对它所归属的文件具有其适用的访问权限。

4. Linux 通过 UID 和 GID 来管理用户和用户组

  - UID（User ID）：通过配置文件 ```/etc/password```（或```/etc/passwd```） 储存，记录的是单个用户的登陆信息，比如在该文件中root用户的信息如下：

     ```root​:x:​0:0:root:/root:/bin/bash ```

     信息被冒号分成七个字段：分别为：用户名、密码、UID、GID、用户描述、用户家目录、用户的 shell 类型

     > 扩展阅读：
     >
     > Linux 系统中通常有三种类型的用户：超级用户（super user），常规用户（regular user）和系统用户（system user）。
     >
     > **超级用户的 UID 和 GID 都是 0**。不管系统中有多少个系统管理员，都只有一个超级用户帐号。超级用户帐号，通常指的是 root user，对系统拥有完全的控制权。超级用户是唯一的。
     >
     > **常规用户的 UID 500 - 60000**。指那些登陆到 Linux 系统，但不执行管理任务的用户，例如文字处理或者收发邮件等
     >
     > **系统用户的 UID 1 — 499**。**系统用户并不是一个人**，也被称为逻辑用户或伪用户。系统用户没有相应的 /home 目录和密码。系统帐号通常是 Linux 系统使用的一个管理日常服务的管理帐号

  - GID（Group ID）：通过配置文件 /etc/group 储存的，记录 GID 和用户组组名的对应关系

     root 用户组的 GID 为0：

     ```
     root:x:0:
     ```

     SMC 用户组的 GID 为1001：

     ```
     smc:!:1001:
     ```

     > 扩展阅读：
     > 
     > 没有 supergroup
     > Systemgroup：GID 0 - 499
     > 一般组：GID 500 - 60000

5. 用户管理的常用命令

  - 用户查询命令：

    who am i：查询当前登录用户的用户名

    id：查询当前登陆用户的 GID 和 UID。

    finger：查询当前用户的属性信息，包含家目录和 shell 类型。

  - 新增用户：```useradd[参数][用户名]```

     ``` 
     linux: ~ # useradd -d /home/ipcc -m -u 2000 -g mms -s /bin/csh ipcc
     ```

     > -d：设置用户的家目录
     > 
     > -m：设置的家目录不存在时自动创建

     > -u：设置用户的 UID

     > -g：设置初始 GID 或组名

     > -s：设置用户的shell，如：/bin/csh
     > 
     > 上例最后的 ipcc 指的是该用户的用户名

     	linux: ~ # useradd ipcc

     > 这个例子中没有参数，直接创建用户名为 ipcc 的用户，如果在新增用户时没有指定参数信息，系统就会去读取 /etc/default/useradd 配置文件，它规定了默认的初始用户组和 shell 等。

     	linux: ~ # useradd lilei -p xxxxxx

     > -p：直接设置用户的密码，但必须是加密的密码，故不太方便

     **经过实践，发现adduser更方便，密码输入，用户家目录默认创建**

     ![](http://ww1.sinaimg.cn/large/005GdKShly1g0n4wu51v0j30gl0bdq5g.jpg)

     > #### `adduser` 和 `useradd` 的区别是什么？
     >
     > 答：useradd 只创建用户，创建完了用 passwd lilei 去设置新用户的密码。adduser 会创建用户，创建目录，创建密码（提示你设置），做这一系列的操作。其实 useradd、userdel 这类操作更像是一种命令，执行完了就返回。而 adduser 更像是一种程序，需要你输入、确定等一系列操作。

  - 删除用户：```userdel [参数] [用户名]```

     >  删除 ipcc 用户

     	linux:~ # userdel -r iptv 

     >  加上 -r，会将用户的家目录一起删除。

  - 新增完用户后，需要设置和修改用户密码：```passwd[用户名]```。常规用户只能不输入用户名，修改当前用户的密码，超级用户可以加上用户名修改其他用户的密码。输入正确后，这个新口令被加密并放入 /etc/shadow 文件

  - 修改用户属性：```usermod[参数][用户名]   ```

     参数 -d 修改用户家目录：

     ```
     linux:~ # usermod -d /opt/ipcc ipcc 
     ```

     参数 -G 修改用户所属的用户组（这样可以为lilei用户添加到sudo用户组里面，**只有lilei才可以使用sudo命令**）：

     ```
     $ sudo usermod -G sudo lilei
     ```

     > 扩展阅读：su 命令用于变更为其他使用者的身份，除 root 外，需要键入该使用者的密码
     > http://www.runoob.com/linux/linux-comm-su.html

6. 用户组管理

  - /etc/group 文件格式说明

    /etc/group 的内容包括用户组（Group）、用户组口令、GID 及该用户组所包含的用户（User），每个用户组一条记录。格式如下：

    ```
    group_name:password:GID:user_list
    ```

    你看到上面的 password 字段为一个 `x` 并不是说密码就是它，只是表示密码不可见而已。

    这里需要注意，如果用户主用户组，即用户的 GID 等于用户组的 GID，那么最后一个字段 `user_list` 就是空的，比如 shiyanlou 用户，在 `/etc/group` 中的 shiyanlou 用户组后面是不会显示的。lilei 用户，在 `/etc/group` 中的 lilei 用户组后面是不会显示的。

  - 查看用户组：`groups [用户组]`

  - 新增用户组：`groupadd [用户组]`

     ```
     linux:~ # groupadd ipcc
     ```

     	linux:~ # groupadd -g 2000 iptv

     > -g 指定组 ID

  - 删除用户组：`groupdel [用户名]`

     ``` 
     linux:~ # groupdel iptv
     ```

  - 修改用户组：`groupmod [参数] [用户名]` 

     ```
     linux:~ # groupmod -g 2500 -n ipcc1 ipcc
     ```

     > g 修改组 ID  -n 修改组名

##3、Linux 文件和目录管理
1. Linux 的文件结构类似于倒树形结构，树的 root 是``` /``` 目录

  - Linux 与 Windows 的目录虽然看起来很像，但在实现机制上是有差别的。

    一种不同是体现在目录与存储介质（磁盘，内存，DVD 等）的关系上，以往的 Windows 一直是以存储介质为主的，主要以盘符（C 盘，D 盘...）及分区来实现文件管理，然后之下才是目录，目录就显得不是那么重要，除系统文件之外的用户文件放在任何地方任何目录也是没有多大关系。所以通常 Windows 在使用一段时间后，磁盘上面的文件目录会显得杂乱无章（少数善于整理的用户除外吧）。

    然而 UNIX/Linux 恰好相反，UNIX 是以目录为主的，Linux 也继承了这一优良特性。 Linux 是以树形目录结构的形式来构建整个系统的，可以理解为树形目录是一个用户可操作系统的骨架。虽然本质上无论是目录结构还是操作系统内核都是存储在磁盘上的，但从逻辑上来说 Linux 的磁盘是 “挂在”（挂载在）目录上的，每一个目录不仅能使用本地磁盘分区的文件系统，也可以使用网络上的文件系统。举例来说，可以利用网络文件系统（Network File System，NFS）服务器载入某特定目录等。

  - Linux 中大部分目录结构是规定好了的，即 FHS 标准

    FHS（英文：Filesystem Hierarchy Standard 中文：文件系统层次结构标准），多数 Linux 版本采用这种文件组织形式，FHS 定义了系统中每个区域的用途、所需要的最小构成的文件和目录同时还给出了例外处理与矛盾处理。

    > [FHS_2.3 标准文档](http://refspecs.linuxfoundation.org/FHS_2.3/fhs-2.3.pdf)

    FHS 定义了两层规范，第一层是， `/` 下面的各个目录应该要放什么文件数据，例如 `/etc` 应该放置设置文件，`/bin` 与 `/sbin` 则应该放置可执行文件等等。

    第二层则是针对 `/usr` 及 `/var` 这两个目录的子目录来定义。例如 `/var/log` 放置系统日志文件，`/usr/share` 放置共享数据等等。

    ![](http://ww1.sinaimg.cn/large/005GdKShly1g0nc70mr05j30yn12kq85.jpg)

    FHS 是根据以往无数 Linux 用户和开发者的经验总结出来的，并且会维持更新，FHS 依据文件系统使用的频繁与否以及是否允许用户随意改动（注意，不是不能，学习过程中，不要怕这些），将目录定义为四种交互作用的形态，如下表所示：

    ![](http://ww1.sinaimg.cn/large/005GdKShly1g0nc7gvgxzj30sx061abf.jpg)

    

  - 如果你觉得看这个不明白，那么可以试试最真实最直观的方式，执行如下命令：

    ```
    $ tree /
    ```

    如果提示“common not found”，就先安装：

    ```
    sudo apt-get install tree
    sudo apt-get update
    ```

    根目录下包含了所有的目录以及各自的子文件，数量巨大，可选择较少的目录执行查看 tree 命令的效果

2. 绝对路径与相对路径

  绝对路径与相对路径

  - 绝对路径：由根目录（/）开始写起的文件名或者目录名，例如： /home/student/file.txt

    - 相对路径：基于当前路径的的文件名或者目 录名写法，`.` 代表当前目录  `..` 代表上一级目录

    举例：假如目前在 /home/smc 目录下，想要切换到 /home/smc/bin/smc 目录下，首先可以使用绝对路径，命令如下：

    	cd /home/smc/bin/smc

    操作完成后，想要回到刚才的 /home/smc 目录下，可以使用相对路径，命令如下；

    	cd ../..

    再举例：目前在 /tmp，想要去 /home/student/file.txt

    	../home/student/file.txt

    再举例：目前在 /home，想要去 /home/student/file.txt

    	student/file.txt

3. 文件权限管理

  - 显示当前目录下的所有文件：ls (list segment)

    ls -l ：显示出详细信息

    ![](http://ww1.sinaimg.cn/large/005GdKShly1g0n3f9up9ij30hx04sabv.jpg)

    分析各部分的内容

    ![](http://ww1.sinaimg.cn/large/005GdKShly1g0n3ga1u6cj30o704kjrz.jpg)

    ![](http://ww1.sinaimg.cn/large/005GdKShly1g0n3gewd4xj30eo0a3mxy.jpg)

  - 读权限，表示你可以使用 `cat <file name>` 之类的命令来读取某个文件的内容；

    写权限，表示你可以编辑和修改某个文件；

    执行权限，通常指可以运行的二进制程序文件或者脚本文件，如同 Windows 上的 `exe` 后缀的文件，不过 Linux 上不是通过文件后缀名来区分文件的类型。

  - 你需要注意的一点是，**一个目录同时具有读权限和执行权限才可以打开并查看内部文件，而一个目录要有写权限才允许在其中创建其它文件**，这是因为目录文件实际保存着该目录里面的文件的列表等信息。

  - 所有者权限，是指你所在的用户组中的所有其它用户对于该文件的权限，比如，你有一个 iPad，那么这个用户组权限就决定了你的兄弟姐妹有没有权限使用它破坏它和占有它。

  - 链接数，链接到该文件所在的 inode 结点的文件名数目，见下文文件系统章节

  - 文件大小，以 inode 结点大小为单位来表示的文件大小，你可以给 ls 加上 `-lh` 参数来更直观的查看文件的大小。

  - 修改文件所有者，假设想更改a用户创建的X文件的所有者为b：

    ```
    sudo chown b X
    ```

  - 修改文件权限

    每个文件的三组权限（拥有者，所属用户组，其他用户，**记住这个顺序是一定的**）对应一个 "rwx"，也就是一个 “7”

    ![](http://ww1.sinaimg.cn/large/005GdKShly1g0n68x1y1qj310j0bzmyt.jpg)

    比如，600就意味着拥有者有读（r）写（w）权限，所属用户组、其他用户没有任何权限

    ``` 
    $ chmod 600 X
    ```

4. 文件和目录的基本操作

  

  - 显示当前目录下的所有文件：ls (list segment)

    `ls -l` ：显示出详细信息

    `ls -a`：显示所有文件，包括隐藏文件，隐藏文件名称以```.```开头，如```.local```

    `ls -A`：显示所有文件，包括隐藏文件，还包括当前目录```.```和上级目录```..```

    `ls -s`：显示文件大小

  - 显示当前的工作目录：pwd (print working directory)

     ```
     $ pwd
     ```

  - 变更工作目录：cd  

     ```
     	cd ../..
     	cd /home/smc/bin/smc
     ```

     > 第一条指令，cd 后面不跟任何路径，则是回到主目录

  - 新增目录（必须具备写权限）：mkdir[-m 模式][-p] 目录名

     ```
     mkdir temp
     mkdir -m 777 temp/abc
     mkdir -p father/son/grandson
     ```

     > -m 指定目录权限，设置为777，所有文件可读可写可执行
     > -p 建立目录时建立其所有不存在的父目录

  - 删除目录（对父目录具备写权限）：rmdir [-p] 目录名 

    用于删除空目录，如果删除非空目录，则使用 rm 再加上参数即可 

    > –p 删除目录及父目录

  - 复制文件或目录（对父目录具备写权限） ：

    `cp [源文件或目录] [目的文件或目录]`

    - `cp /etc/passwd /tmp/passwd` ：绝对路径是最标准的写法
    - `cp /etc/passwd /tmp` ：相同文件名称拷贝
    - `cp /etc/passwd /tmp/.` ：在/tmp目录下，相同名称拷贝，与上结果一样
    - `cp /etc/passwd .` ：在当前文件夹下，相同名称拷贝一份
    - `cp -r father family`：把 father 目录复制到 family 目录中，复制目录要加参数 `-r`

  - 移动文件或目录（对父目录具备写权限）：mv 源文件或目录 目的文件或目录
    - `mv /tmp/passwd /tmp/abc` ：这种写法用来更改文件名称
    - `mv /tmp/passwd /var/tmp/passwd` ：移动文件，名称不变
    - `mv /tmp/passwd /var/tmp/abc`：移动文件并更改文件名称
    - 注意 SELinux security context

  - 删除文件或目录（对父目录具备写权限）：`rm[-ir] 文件或目录`

    > -name 以指定字符串开头的文件名  
    >
    > -user 查找指定用户所拥有的文件。

    `rm -r family`：删除目录要加参数 `-r

5. 查看文件内容：

  - cat：直接查阅文件内容，不能翻页，正序

    可以加上 `-n` 参数显示行号：

    ```
    $ cat -n passwd
    ```

  - `nl` 命令，添加行号并打印，这是个比 `cat -n` 更专业的行号打印命令。

    这里简单列举它的常用的几个参数：

    ```
    -b : 指定添加行号的方式，主要有两种：
        -b a:表示无论是否为空行，同样列出行号("cat -n"就是这种方式)
        -b t:只列出非空行的编号并列出（默认为这种方式）
    -n : 设置行号的样式，主要有三种：
        -n ln:在行号字段最左端显示
        -n rn:在行号字段最右边显示，且不加 0
        -n rz:在行号字段最右边显示，且加 0
    -w : 行号字段占用的位数(默认为 6 位)
    ```

  - more：翻页查看文件内容，只能向一个方向滚动

    打开后默认只显示一屏内容，终端底部显示当前阅读的进度。可以使用 `Enter` 键向下滚动一行，使用 `Space` 键向下滚动一屏，按下 `h` 显示帮助，`q` 退出。

  - less：翻页阅读，和 more 类似，但操作按键比 more 更加弹性，`less` 是基于 `more` 和 `vi` （一个强大的编辑器，我们有单独的课程来让你学习）开发，功能更强大。

  - head：查看文档的头部几行内容，默认为 10 行，可用`-数字` 来查看特定行数，效果等同于 `-n 数字`

  - tail：查看文件的尾部几行内容，默认为 10 行，可用`-数字` 来查看特定行数，效果等同于 `-n 数字

    ```
    $ tail -n 1 /etc/passwd
    ```

    关于 `tail` 命令，不得不提的还有它一个很牛的参数 `-f`，这个参数可以实现不停地读取某个文件的内容并显示。这可以让我们动态查看日志，达到实时监视的目的。

  > 标准输入输出：当我们执行一个 shell 命令行时通常会自动打开三个标准文件，即标准输入文件（stdin），默认对应终端的键盘、标准输出文件（stdout）和标准错误输出文件（stderr），后两个文件都对应被重定向到终端的屏幕，以便我们能直接看到输出内容。进程将从标准输入文件中得到输入数据，将正常输出数据输出到标准输出文件，而将错误信息送到标准错误文件中。

6. 查看文件类型

   在 Linux 中文件的类型不是根据文件后缀来判断的，我们通常使用 `file` 命令查看文件的类型：

   ```
   $ file /bin/ls
   ```

   ![](http://ww1.sinaimg.cn/large/005GdKShly1g0nes2hu23j30g8046mz0.jpg)

   说明这是一个可执行文件，运行在 64 位平台，并使用了动态链接文件（共享库）。

## 4、Linux 环境变量与文件查找

### 环境变量

- 在所有的 UNIX 和类 UNIX 系统中，每个进程都有其各自的环境变量设置，且默认情况下，当一个进程被创建时，除了创建过程中明确指定的话，它将继承其父进程的绝大部分环境设置。Shell 程序也作为一个进程运行在操作系统之上，而我们在 Shell 中运行的大部分命令都将以 Shell 的子进程的方式运行。

- 通常我们会涉及到的变量类型有三种：

  - 当前 Shell 进程私有用户自定义变量，如上面我们创建的 tmp 变量，只在当前 Shell 中有效。
  - Shell 本身内建的变量。
  - 从自定义变量导出的环境变量。

- 也有三个与上述三种环境变量相关的命令：`set`，`env`，`export`。这三个命令很相似，都是用于打印环境变量信息，区别在于涉及的变量范围不同。详见下表：

  |  命 令   |                            说 明                             |
  | :------: | :----------------------------------------------------------: |
  |  `set`   | 显示当前 Shell 所有变量，包括其内建环境变量（与 Shell 外观等相关），用户自定义变量及导出的环境变量。 |
  |  `env`   | 显示与当前用户相关的环境变量，还可以让命令在指定环境中运行。 |
  | `export` | 显示从 Shell 中导出成环境变量的变量，也能通过它将自定义变量导出为环境变量。 |

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0qrof3kqtj30b007ot94.jpg)

- 关于哪些变量是环境变量，可以简单地理解成在当前进程的子进程有效则为环境变量，否则不是（有些人也将所有变量统称为环境变量，只是以全局环境变量和局部环境变量进行区分，我们只要理解它们的实质区别即可）。我们这里用 `export` 命令来体会一下，先在 Shell 中设置一个变量 `temp=shiyanlou`，然后再新创建一个子 Shell 查看 `temp` 变量的值：

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0qrqszmiwj30i10ekad0.jpg)

  **注意：为了与普通变量区分，通常我们习惯将环境变量名设为大写。**

- 若仅仅按照 export 命令导出环境变量，当关闭当前 shell 或关机后，环境变量就消失了，**若想永久保存**，则需要修改配置文件，有以下三种：`/etc/bashrc`（有的 Linux 没有这个文件） 和 `/etc/profile` ，它们分别存放的是 shell 变量和环境变量。还有要注意区别的是每个用户目录下的一个隐藏文件：`.profile`，这个 `.profile` 只对当前用户永久生效，而写在 `/etc/profile` 里面的是对所有用户永久生效。

  | 文件                  | 作用                                    |      |
  | --------------------- | --------------------------------------- | ---- |
  | `/etc/bashrc`         | 存放shell 变量，有些 Linux 系统无此文件 |      |
  | `/etc/profile`        | 存放环境变量，对所有用户永久生效        |      |
  | `[用户目录]/.profile` | 对某用户永久生效                        |      |

- 我们在 Shell 中输入一个命令，Shell 是怎么知道去哪找到这个命令然后执行的呢？这是通过环境变量 `PATH` 来进行搜索的，熟悉 Windows 的用户可能知道 Windows 中的也是有这么一个 PATH 环境变量。这个 `PATH` 里面就保存了 Shell 中执行的命令的搜索路径。

  查看 `PATH` 环境变量的内容：

  ```
  $ echo $PATH
  ```

  默认情况下会看到如下输出：

  ```
  /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
  ```

  根据3、Linux 文件和目录管理，通常这一类目录下放的都是可执行文件，当我们在 Shell 中执行一个命令时，系统就会按照 PATH 中设定的路径按照顺序依次到目录中去查找，如果存在同名的命令，则执行先找到的那个。

### 自定义环境变量

- 应该注意到 `PATH` 里面的路径是以 `:` 作为分割符的，所以我们可以这样添加自定义路径：

  ```
  $ PATH=$PATH:/home/shiyanlou/mybin
  ```

  **注意这里一定要使用绝对路径。**

- 但是，这样给 PATH 环境变量追加一个路径，它也只是在当前 shell 有效，退出 shell 后，再打开就发现失效了，解决方法是：每次启动 shell 时自动执行上面添加自定义路径到 PATH 的命令。

- 在每个用户的 home 目录中有一个 Shell 每次启动时会默认执行一个配置脚本，以初始化环境，包括添加一些用户自定义环境变量等等。zsh 的配置文件是 `.zshrc`，相应 Bash 的配置文件为 `.bashrc` 。它们在 `etc` 下还都有一个或多个全局的配置文件，不过我们一般只修改用户目录下的配置文件。

  我们可以简单地使用下面命令直接添加内容到 `.zshrc` 中：

  ```
  $ echo "PATH=$PATH:/home/shiyanlou/mybin" >> .zshrc
  ```

  **上述命令中 >> 表示将标准输出以追加的方式重定向到一个文件中，注意前面用到的 > 是以覆盖的方式重定向到一个文件中，使用的时候一定要注意分辨。在指定文件不存在的情况下都会创建新的文件。**

### 修改和删除已有变量

- 变量的修改有以下几种方式：

  变量的修改有以下几种方式：

  | 变量设置方式                   | 说明                                         |
  | ------------------------------ | -------------------------------------------- |
  | `${变量名#匹配字串}`           | 从头向后开始匹配，删除符合匹配字串的最短数据 |
  | `${变量名##匹配字串}`          | 从头向后开始匹配，删除符合匹配字串的最长数据 |
  | `${变量名%匹配字串}`           | 从尾向前开始匹配，删除符合匹配字串的最短数据 |
  | `${变量名%%匹配字串}`          | 从尾向前开始匹配，删除符合匹配字串的最长数据 |
  | `${变量名/旧的字串/新的字串}`  | 将符合旧字串的第一个字串替换为新的字串       |
  | `${变量名//旧的字串/新的字串}` | 将符合旧字串的全部字串替换为新的字串         |

  比如要修改我们前面添加到 PATH 的环境变量。为了避免操作失误导致命令找不到，我们先将 PATH 赋值给一个新的自定义变量 path：

  ```
  $ path=$PATH
  $ echo $path
  $ path=${path%/home/shiyanlou/mybin}
  # 或使用通配符,*表示任意多个任意字符
  $ path=${path%*/mybin}
  ```

  #### 变量删除

  可以使用 `unset` 命令删除一个环境变量：

  ```
  $ unset temp
  ```

> 前面我们在 Shell 中修改了一个配置脚本文件之后（比如 zsh 的配置文件 home 目录下的 `.zshrc`），每次都要退出终端重新打开甚至重启主机之后其才能生效，很是麻烦，我们可以使用 `source` 命令来让其立即生效，如：
>
> ```
> $ cd /home/shiyanlou
> $ source .zshrc
> ```
>
> `source` 命令还有一个别名就是 `.`，上面的命令如果替换成 `.` 的方式就该是：
>
> ```
> $ . ./.zshrc
> ```
>
> 在使用`.` 的时候，需要注意与表示当前路径的那个点区分开。
>
> 注意第一个点后面有一个空格，而且后面的文件必须指定完整的绝对或相对路径名，source 则不需要。

### 搜索文件

- 与搜索相关的命令常用的有 `whereis`，`which`，`find` 和 `locate` 。

  **whereis 简单快速**

  ```
  $ whereis who
  $ whereis find
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0qt5vhf28j30i204c760.jpg)

  你会看到 `whereis find` 找到了三个路径，两个可执行文件路径和一个 man 在线帮助文件所在路径，这个搜索很快，因为它并没有从硬盘中依次查找，而是直接从数据库中查询。

  `whereis` 只能搜索二进制文件 (-b)，man 帮助文件 (-m) 和源代码文件 (-s)。如果想要获得更全面的搜索结果可以使用 `locate` 命令。

  **locate 快而全**

  通过 “/var/lib/mlocate/mlocate.db” 数据库查找，不过这个数据库也不是实时更新的，系统会使用定时任务每天自动执行 `updatedb` 命令更新一次，所以有时候你刚添加的文件，它可能会找不到，需要手动执行一次 `updatedb` 命令（在我们的环境中必须先执行一次该命令）。它可以用来查找指定目录下的不同文件类型，如查找 /etc 下所有以 sh 开头的文件：

  ```
  $ sudo apt-get update
  $ sudo apt-get install locate
  $ locate /etc/sh
  ```

  > **注意，它不只是在 /bin 目录下查找，还会自动递归子目录进行查找。**

  查找 /usr/share/ 下所有 jpg 文件：

  ```
  $ locate /usr/share/\*.jpg
  ```

  > **注意要添加 \* 号前面的反斜杠转义，否则会无法找到。**

  如果想只统计数目可以加上 `-c` 参数，`-i` 参数可以忽略大小写进行查找，whereis 的 `-b`、`-m`、`-s` 同样可以使用。

  **which 小而精**

  `which` 本身是 Shell 内建的一个命令，我们通常使用 `which` 来确定是否安装了某个指定的软件，因为它只从 `PATH` 环境变量指定的路径中去搜索命令：

  ```
  $ which man
  ```

  **find 精而细**

  `find` 应该是这几个命令中最强大的了，它不但可以通过文件类型、文件名进行查找而且可以根据文件的属性（如文件的时间戳，文件的权限等）进行搜索。`find` 命令强大到，要把它讲明白至少需要单独好几节课程才行，我们这里只介绍一些常用的内容。

  这条命令表示去 /etc/ 目录下面 ，搜索名字叫做 interfaces 的文件或者目录。这是 find 命令最常见的格式，千万记住 find 的第一个参数是要搜索的地方：

  ```
  $ sudo find /etc/ -name interfaces
  ```

  > **注意 find 命令的路径是作为第一个参数的， 基本命令格式为 find [path] [option] [action] 。**

  与时间相关的命令参数：

  | 参数     | 说明                   |
  | -------- | ---------------------- |
  | `-atime` | 最后访问时间           |
  | `-ctime` | 最后修改文件内容的时间 |
  | `-mtime` | 最后修改文件属性的时间 |

  下面以 `-mtime` 参数举例：

  - `-mtime n`：n 为数字，表示为在 n 天之前的 “一天之内” 修改过的文件
  - `-mtime +n`：列出在 n 天之前（不包含 n 天本身）被修改过的文件
  - `-mtime -n`：列出在 n 天之内（包含 n 天本身）被修改过的文件
  - `-newer file`：file 为一个已存在的文件，列出比 file 还要新的文件名

  ![img](https://doc.shiyanlou.com/linux_base/5-8.png/wm)

  列出 home 目录中，当天（24 小时之内）有改动的文件：

  ```
  $ find ~ -mtime 0
  ```

  列出用户家目录下比 Code 文件夹新的文件：

  ```
  $ find ~ -newer /home/shiyanlou/Code
  ```

##4、Linux 文件系统管理

1. 文件系统的概念：操作系统用于明确存储和组织计算机数据的方法，使得对数据的查找和访问变得更加容易。用户不需要关心文件位于d硬盘的数据块地址。

2. 存储在介质中数据的三个因素
  
	文件名：定位存储的位置
  
	数据：文件的具体内容
  
	元数据 meta-data：文件有关的信息。例如文件的权限、所有者、文件的修   改时间等。

	Linux 支持的文件系统类型可查看 /etc/filesystems

3. 文件系统的分类

	- 根据是否有日志？

		- 传统型文件系统：写入文件内容的时候，先写数据，再写元数据，若写元数据前断电，则会造成文件不一致。典型的：ext2（Linux 默认的文件系统）
  
		- 日志型文件系统：写入文件内容的时候，先写日志记录文件（更安全）。典型的：ext3 = ext2 + 日志  ，ReiserFS （基于平衡树，搜索快，节约空间）

	- 根据如何查找数据？

		- 索引式文件系统：文件属性数据和实际内容放在不同的区块，例如 Linux 中默认的 ext2 文件系统中，文件属性数据存放在 inode（类似于指针），实际内容放在 block。ext2 一开始就规划好了 inode 与 block ，所以数量庞大，不容易管理，所以有分组
  
			![](http://upload-images.jianshu.io/upload_images/2106579-b71e3f2eb47dbf42.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

		- 非索引式文件系统：只有 block，数据需要一个 block 接一个 block 读取（下一个 block 位置存放在上一个 block 中），效率低。 典型的：FAT（Windows 的文件系统）

			![](http://upload-images.jianshu.io/upload_images/2106579-c0507b51e0e4840d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

			> 碎片整理：写入的数据的 block 太过分散，此时读取的效率会很低。磁盘整理的目的，就是将这些分散的 block 尽量的集中起来。

4. 配置文件系统分区

	- 创建分区：fdisk + 设备名，输入完该命令之后，可以通过参数 m 查看按键操作说明，通过参数 p 可以得到本磁盘的相关信息，输入 n 命令可以新建一个分区。使用完 n 命令之后，新建分区的步骤如下：
  
		选择分区类型
	
		选择分区开始的磁柱
	
		决定分区的大小
	
		保存新建的分区 （w 命令）
  
		通过重启服务器或使用 partprobe 命令通知内核

	- 创建文件系统：mkfs [参数] 设备名。-t 指定文件系统类型，如 ext3。  -b 指定 block 大小，单位 bytes，ext2 和 ext3 仅支持 1024/2048/4096 三种。

	- 挂载文件系统：mount + 设备名 + 挂载点。挂载的过程就是将文件系统和目录树上的某一个目录结合。  -t  -b 同上。

			mount /dev/sda6/root/testmount

5. 管理 Linux 文件系统

	- 查看分区使用情况：

		- df：查看文件系统的磁盘空间占用情况，参数 –h 以容易理解的格式打印出文件系统大小，参数 –i 显示 inode 信息而非块使用量。

		- du：查看文件或目录的磁盘使用空间，参数 –a 显示目录下的每个文件所占的磁盘空间，参数 –s 只显示大小的总和，参数 -h 以容易理解的格式输出文件大小值，如多少 Mb

	- 查看系统打开的文件：lsof

		Isof filename 显示打开指定文件的所有进程

		Isof –c string 显示以指定字符开头的进程所有打开的文件

		Isof –u username 显示所属 username 相关进程打开的文件

6. 修复文件系统：
  
	- fsck 参数 设备名：检查文件系统并尝试修复错误。执行 fsck 时，必须首先要将修复的设备进行umount 后，再执行 fsck 命令。
  
	- e2fsck：检查和修复 ext2 和 ext3 文件系统

##5、Linux LVM 配置
LVM：Logical Volume Manager

- 传统：文件系统构建在物理分区（PP：physical partition）之上，物理分区的大小直接决定了文件系统的容量。LVM：使文件系统的调节更简便，搭配 RAID 做容错

- LVM 结构：

	![](http://upload-images.jianshu.io/upload_images/2106579-2c5ca1a7e33f6cf9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

	PP：physical partition 物理分区，LVM 最底层
	
	PV：physical volume 物理卷，一个 PP 对应一个 PV
	
	PE：physical extends 物理扩展单元，组成PV的最小单元，也是的最小区块，类似于文件系统的 block
	
	VG：volume group 卷组，可以看出由 LVM 组成的大磁盘
	
	LE：logical extends 逻辑扩展单元，组成LV的最小单元，对应一个PE
	
	LV：logical volume 逻辑卷， VG之上，文件系统之下，文件系统是基于逻辑卷的

- VG、LV 和 PE 的关系

	LV 通过交换 PE 来实现弹性改变文件系统大小的效果，LV 移除一些 PE，文件系统大小即减小，VG 把一些 PE 给LV，文件系统大小即增加

	![](http://upload-images.jianshu.io/upload_images/2106579-2bc6a3b02784a97e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240) 

	最多65534个PE，PE的大小可以影响到VG的容量

	LV与磁盘分区类似，能够格式化

- LVM 的优点：

	- 通过LVM，文件系统可以跨越多个磁盘
	
	- 动态地扩展文件系统的大小
	
	- 增加新磁盘到 LVM 的存储池中

- LVM 使用要点：

	- 按需分配文件系统大小

	- 把不同的数据放在不同的卷组中

- LVM 配置步骤，创建逻辑卷的步骤

- 物理卷管理命令

	- pvcreate 将普通的分区加上 PV 属性
	- pvscan 查看物理卷信息
	- pvdisplay 查看各个物理卷的详细参数
	- pvremve

- 卷组管理

	- vgcreate vgname /dev/sdaN
		- vgname：卷组名称
		- /dev/sdaN：要加入卷组的物理卷
	- vgscan
	- vgdisplay
	- vgreduce 缩小卷组，把物理卷从卷组中删除
	- vgextend 扩展卷组，把某个物理卷添加到卷组中
	- vgremove

- 逻辑卷管理命令

	- lvcreate -n lvname -L 2G vgname
		- lvname：逻辑卷名称
		- -L 2G:逻辑卷大小
		- vgname：从卷组分配空间给逻辑卷
	- lvscan
	- lvdisplay
	- lvextend
	- lvreduce
	- lvrmove

- 扩展卷组
	- 可在线扩展卷组
	- 不一定可以所见卷组
	- 命令：vgextend vgname /dev/sdaN
		- 将物理卷 /dev/sdaN，加到vgname
	- 必须要有未使用的物理卷
		- 必须先有未使用的分区或硬盘

- 管理文件系统的空间（增大或减小）

	- 增大（ 卷组必须要有足够空间）

		- 先卸载逻辑卷
		- 然后通过vgextend、lvextend等命令增大LV的空间
		
			- lvextend -l +128 /dev/vgname/lvname
				- 再加大128个LE
			- lvextend -L +128M /dev/vgname/lvname
				- 再加大128 Mb
		- resize2fs -p /dev/vgname/lvname
			- 再使用resize2fs将逻辑卷容量增加，扩展文件系统
			- -p：显示操作期间的进度
		- 最后将逻辑卷挂载到目录树

	- 减小

		- 先卸载逻辑卷
		- resize2fs -p /dev/vgname/lvname 512M
			- 再使用resize2fs将逻辑卷容量减小，文件系统调整为512MB
		- lvreduce -L 512M /dev/vgname/lvname
			- 再通过lvreduce将逻辑卷容量减小，逻辑卷减小到512MB
		- 最后将逻辑卷挂载到目录树

	> 注意 lvextend -l +128 与 lvextend -L +128M 的区别。一个是增加128个PE，一个是增加128MB

##6、Linux 网络管理
- ifconfig [接口]：查看IP地址，广播地址，网口掩码

	> windowns 中用 ipconfig

	- ifconfig 网口[参数]：设置网口的参数，如IP地址，广播地址，网口掩码等，重启网络或系统后失效

			ifconfig eth3 192.168.100.128 broadcast 192.168.100.255 netmask 255.255.255.0

	- 若想修改一直有效，则需要去修改配置文件：/etc/sysconfig/network/ifcfg-网口
	
		编辑配置文件：
	
			vi ifcfg-eth4
	
		使用ifup命令，启动网口:
	
			ifup ifcfg-eth4

- route：查询本机路由表

	Destination 目的地
	Gateway 网管
	Genmask
	Flags 标记，为U：可用
	Iface 该路由的网络出口

- 新增路由：通过命令方式新建路由，会保存在内存中，重启无效，若想持久保存，通过配置文件 /etc/sysconfig/network/routes 静态保存路由信息，重启网络服务才能生效

- 检测本地端口

		netstat -tupln | grep:25

	- 	t：TCP仅显示tcp相关选项
	- 	u：UDP仅显示udp相关选项
	- 	p：Procedure显示建立相关连接的程序名
	- 	l：List仅列出正在Listen（监听）的服务
	- 	n：拒绝显示别名，能显示数字的全部转化为数字

- 检测远程服务

	- nmap软件包
	
	- 可以单独检测服务器
		- 如：nmap 192.168.0.101

	- 可检测整个class C
		- 如：nmap 192.168.0.0/24
		- 不支持255.255.255.0的语法
	- 如果没有防火墙干扰，结果应该与netstat一致

- IP别名
	- 在相同的网卡以及MAC地址之下，配置不同的IP地址
	- 命名原则
		- eth0
		- eth0:0
		- eth0:1 ...
	- 哪些不支持IP别名
		- DHCP不支持别名
		- NetworkManager不支持别名
			- NetworkManager也不支持网卡绑定
			- service NetworkManager stop
			- chkconfig NetworkManager Off
- **ping -c 次数**

- **traceroute 目的地址或主机名：追踪包源到目的所经过的路由**

- 配置FTP服务，通过yast命令，yast界面可以修改网络信息

- 配置Telnet服务，进入yast界面

##7、Linux 进程与任务管理
- 概念

	- 程序：文件中保存的一系列可执行的命令
	
	- 进程：加载到内存中的程序,由CPU执行，由PID 标识
	
	- 守护进程：常驻内存，与终端无关的系统进程
	
	- 用户进程：用户通过终端加载的进程

- **查看进程**

	- ps 静态查看某一时间点进程信息
		- a 显示现行终端机下所有程序
		- x 显示所有程序，不分终端机
		- u 以用户为主的格式来显示程序状况
		- f 用ASCII字符显示树状结构
		- l 显示进程的详细信息，例如优先级（NI）

	- top 动态观察进程动态，每三秒刷新一次（默认按CPU的使用率降序排列）
		- 热键；
			- P：按处理器使用率排列进程
			- M：按内存使用率排列
			- d：控制即时显示秒差
			- h：显示更多热键的用法
			- q：离开top
			- k：杀死某个进程，需要再输入PID好

	- pstree 用ASCII字符显示树状结构，-p 显示进程ID，-u 显示用户名

- 管理进程
	- Linux进程调度是CPU分为时间片，每个进程将依次在CPU上运行，优先级高的先执行
	- 用户可通过设置进程的 niceness(NI）值来影响进程的优先级。niceness值范围：-20到+19，数字越小，优先级越高
	- root用户（超级用户）可调整优先级到-20，而非超级用户只能把进程的优先级调低（即往+19调整），常规用户所启用的进程的niceness默认值为0
	- 用法：
		- nice -n 1 ls：将 ls 的优先序加 1 并执行
		- nice ls：将 ls 的优先序加 10 并执行
		- renice +1 987 -u daemon root -p 32：将进程 id 为 987 及 32 的进程与进程拥有者为 daemon 及 root 的优先序号码加 1

- **结束进程**

	- kill PID：结束进程和进程号PID，系统可能不响应
	- kill -9 PID：强制终止进程，一般不适用
	- killall PID：终止同一进程组内的所有进程

- 任务管理

	- 任务：登录系统取得shell后，再单一终端接口下启动的进程

	- 前台：在终端接口上，可以出现提示符让用户操作的环境

	- 后台：不显示再终端接口的环境

- 任务管理相关命令

	- & 直接将程序放入后台处理

			find /-name smcapp &

	- jobs 查看当前shell的后台任务

	- ctrl+z 将正在运行的任务放入后台暂停

		在vi命令编辑文件内容时，可以暂停（suspended）

	- fg %[job ID] 任务放入前台，如果不加job ID，则默认把当前任务

	- bg %[job ID] 任务放入后台

- 管理周期计划任务：crontab [-u user] [-e] -l [-r]。-u指定用户，-e编辑crontab任务内容，-l查阅crontab任务内容，-r移除所有crontab的任务内容
	
	> 当用-e编辑时，程序会直接调用vi接口
	> 
	> 系统计划任务保存在/etc/crontab文件中

- 管理定时任务：at 安排一个任务在未来执行，必须先启用atd进程
	- at -l：相当于atq，列出当前at任务
	- at -d[job ID]：相当于atrm，删除一个at任务 
	- at -c[job ID]：查看任务具体内容
	
	![](http://upload-images.jianshu.io/upload_images/2106579-7879c6c3f7771854.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

	> at 与 crontab的用法，from 鸟哥的linux私房菜：http://cn.linux.vbird.org/linux_basic/0430cron.php

##8、Linux 系统监控
- 监控系统启动日志

	想要查看启动信息，调用命令 dmesg|less，或者查看 /var/log/boot.msg 日志

- 监控系统运行状况
	
	- cat /proc/..

		/proc/cpuinfo

		/proc/bus

		/proc/scsi
		
	- fdisk 硬盘信息

		-l：查看服务器所挂硬盘个数及分区情况

	- lspci PCI信息

		-v：显示PCI接口装置的详细信息

		-vv：更详细的信息

	- iostat CPU和I/O信息

		-c：仅显示CPU统计信息

		-d：仅显示磁盘统计信息

		-k：以k为单位显示每秒磁盘的请求数
	- hwinfo 设备信息

		--disk 显示磁盘信息

		--cpu 显示CPU信息

		--memory 显示内存信息

		--network 显示网卡信息

		--short 显示硬件的摘要信息

- 监控系统和进程
	
	- top 进程的动态信息，CPU、内存信息
	
	- ps 静态
	
	- uptime 系统开机时间以及系统平均负载
	
	- uname 查看系统版本信息，加 -a 会由更详细的信息
	
	- netstat 显示与IP、TCP、UDP相关的信息

- 监控用户登录
	
	- who -H -m：查看当前登录系统地用户。-H：显示各栏位的标题信息列，-m：效果等同于who am i，显示出自己再系统地用户名，登录终端，登录时间

	- w[参数][用户]：查看当前登录的用户及用户当前的工作。-u：后面接user，查看具体用户信息，比who更详细

	- finger[参数][用户]：查看用户详细信息。-s：短格式显示用户信息，-l：长格式显示用户信息

	- last[参数]：查看曾经登录过系统的用户。-n num：设置列出名单的显示列数，-F：显示登录和登出的详细信息

	- lastlog[参数][用户]：查看用户前一次登录信息。-t days：查看距今n天内登录了系统的用户的最近一次登录信息，-u显示登录与登出的详细信息
	
##9、Linux 管道与I/O重定向
-  命令行功能最强大的两个功能：管道与I/O重定向

- I/O重定向可将命令行的执行的输出或错误消息重定向至文件，方便当下保存或稍后分析

- 输入输出流

	- 标准输入
		- 0:键盘默认
		- 又称 STDIN
	- 标准输出
		- 1:终端默认
		- 又称STDOUT
	- 标准错误
		- 2:终端默认
		- 又称STDERR
	
- 重定向运算符号

	- `>` ：将STDOUT重定向到文件
		- 文件内容会被覆盖
		- 举例：

				ls -Ra /etc > root/backup/config-file-lists

	- `>>` ：将STDOUT重定向到文件
		- 文件内容会被添加
		- 举例：
	
				(date;who -l) >> /root/monitor/who-online

	- `<` ：重定向STDIN
		- 将键盘输入改由读入文件提供
		- 举例：

				mail -s "Warning" root < /root/mail/record/alert-notify

	> Shell 输入 / 输出重定向：http://www.runoob.com/linux/linux-shell-io-redirections.html

- 管道使用

	- 运算符管道
		- |：将一个命令的STDOUT发送到另一个命令的STDIN
		- 举例：

				grep pattern /var/log/messages | mail -s "Issue notify" root

	- 命令行T管道
		- tee：将上一个命令的STDOUT通过T管道重定向到该文件，再发送到另一个命令的STDIN
		- 举例：

				ifconfig eth0 | grep pattern | tee /root/interface-info | cut -f2 -d: | cut -f1 -d" "

		- 再举例：
		使用tee的示意图：ls -l的输出被导向 tee，并且复制到档案　file.txt 以及下一个命令 less。tee 的名称来自于这个图示，它看起来像是大写的字母 T。

		![](https://upload.wikimedia.org/wikipedia/commons/2/24/Tee.svg)

- 比较

	- 标准的命令用法：

			grep root /etc/passwd

	- 重定向：

			grep root < /etc/passwd

	- 管道：

			cat /etc/passwd | grep root

	- 三种原理不一样，但结果一样

##10、Linux 安装与管理软件
- RPM：redhat package manager
	- redhat 提出
	- 将源码先编程完RPM软件包，类似于Windows中的setup文件
	- 安装时，只需要解开软件包，复制到适当地址
	- 容易管理
	- 方便更新、移除

- RHEL 软件的命名原则：A-B-C.D.E
	- A：软件名
	- B：版本
	- C：发行次数，RHEL习惯加上 el# 字样，#代表RHELv#
	- D：搭配规格，有 noarch
	- E：后缀，.rpm 或者 .src.rpm

	- 例如：
		- 	gimp-2.6.9-4.el6_1.1.x86_64.rpm
		- 	zsh-4.3.10-4.1.el6.x86_64.rpm
		- 	apache-1.3.23-11.i386.rpm

- RPM 软件包相依性
	- 有些 RPM 软件包不能单独安装，必须先安装别的 RPM 软件包才能安装，称之为 RPM软件包相依性

	- 不是所有的都有相依性需求

	- rpm 命令安装时，不检查相依性问题

	- yum 命令安装时，自动解决相依性问题

- rpm 查询

	rpm -qa ：查询所有
	
	rpm -q mysql ：查询软件包是否安装
	
	rpm -qi mysql ：查询软件包信息
	
	rpm -ql mysql ：查询软件包中的文件
	
	rpm -qf /etc/passwd ：查询该文件所属的软件包
	
- rpm 安装

	rpm -i RPM包全路径 ：安装某个RPM包

	rpm -ivh RPM包全路径 ：加上提示信息和进度条

- rpm 删除

	rpm -e jdk ：删除 jdk 的RPM包 

	> 如果其他软件包依赖于 jdk ，则删除时会报错

- rpm 升级
	
	rpm -U RPM包全路径
