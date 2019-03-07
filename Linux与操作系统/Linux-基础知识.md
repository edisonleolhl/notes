本文包括：

> 1、Linux 系统概述

> 2、Linux 用户和用户组管理

> 3、Linux 文件和目录管理

> 4、Linux 文件系统管理

> 5、Linux 任务计划 crontab

> 6、Linux 命令执行顺序、管道、文本处理命令、I/O重定向

> 7、Linux 三剑客——grep、sed、awk

> 8、Linux 进程与任务管理

> 9、Linux 日志系统

> 10、Linux 文件系统管理

> 11、Linux LVM 配置

> 12、Linux 网络管理

> 13、Linux 系统监控

> 14、Linux 安装与管理软件

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

### root 用户

在 Linux 系统里， `root` 账户拥有整个系统至高无上的权利，比如 新建 / 添加 用户。

> root 权限，系统权限的一种，与 SYSTEM 权限可以理解成一个概念，但高于 Administrator 权限，root 是 Linux 和 UNIX 系统中的超级管理员用户帐户，该帐户拥有整个系统至高无上的权力，所有对象他都可以操作，所以很多黑客在入侵系统的时候，都要把权限提升到 root 权限，用 Wigroupndows 的方法理解也就是将自己的非法帐户添加到 Administrators 用户组。更比如安卓操作系统中（基于 Linux 内核）获得 root 权限之后就意味着已经获得了手机的最高权限，这时候你可以对手机中的任何文件（包括系统文件）执行所有增、删、改、查的操作。

### su && sudo

我们一般登录系统时都是以普通账户的身份登录的，要创建用户需要 root 权限，这里就要用到 `sudo` 这个命令了。不过使用这个命令有两个大前提，一是你要知道当前登录用户的密码，二是当前用户必须在 `sudo` 用户组。

`su <user>` 可以切换到用户 user，执行时需要输入目标用户的密码（注意**Linux 下密码输入是不显示任何内容的**），`sudo <cmd>` 可以以特权级别运行 cmd 命令，需要当前用户属于 sudo 组，且需要输入当前用户的密码。`su - <user>` 命令也是切换用户，同时环境变量也会跟着改变成目标用户的环境变量。

### Linux 的用户和用户组

在 Linux 操作系统中，Linux 用户会归属于用户组，那么归属于同一用户组的不同用户，它对一些公共文件具有相同的访问权限，每个用户对它所归属的文件具有其适用的访问权限。

Linux 通过 UID 和 GID 来管理用户和用户组

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

### 用户管理的常用命令

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

### 用户组管理

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
### Linux 的文件结构

类似于倒树形结构树的 root 是``` /``` 目录

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

### 绝对路径与相对路径

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

### 文件权限管理

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

### 文件和目录的基本操作

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

### 查看文件内容：

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

### 查看文件类型

在 Linux 中文件的类型不是根据文件后缀来判断的，我们通常使用 `file` 命令查看文件的类型：

```
$ file /bin/ls
```

![](http://ww1.sinaimg.cn/large/005GdKShly1g0nes2hu23j30g8046mz0.jpg)

说明这是一个可执行文件，运行在 64 位平台，并使用了动态链接文件（共享库）。

## 4、Linux 环境变量、文件查找、文件打包与解压缩、帮助命令

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

### 文件打包与解压缩

- 在讲 Linux 上的压缩工具之前，有必要先了解一下常见常用的压缩包文件格式。在 Windows 上最常见的不外乎这两种 `*.zip`，`*.7z` 后缀的压缩文件。而在 Linux 上面常见的格式除了以上两种外，还有 `.rar`，`*.gz`，`*.xz`，`*.bz2`，`*.tar`，`*.tar.gz`，`*.tar.xz`，`*.tar.bz2`，简单介绍如下：

  | 文件后缀名 | 说明                           |
  | ---------- | ------------------------------ |
  | `*.zip`    | zip 程序打包压缩的文件         |
  | `*.rar`    | rar 程序压缩的文件             |
  | `*.7z`     | 7zip 程序压缩的文件            |
  | `*.tar`    | tar 程序打包，未压缩的文件     |
  | `*.gz`     | gzip 程序（GNU zip）压缩的文件 |
  | `*.xz`     | xz 程序压缩的文件              |
  | `*.bz2`    | bzip2 程序压缩的文件           |
  | `*.tar.gz` | tar 打包，gzip 程序压缩的文件  |
  | `*.tar.xz` | tar 打包，xz 程序压缩的文件    |
  | `*tar.bz2` | tar 打包，bzip2 程序压缩的文件 |
  | `*.tar.7z` | tar 打包，7z 程序压缩的文件    |

  这么多个命令，不过我们一般只需要掌握几个命令即可，包括 `zip`，`tar`。

- 使用 zip 打包文件夹：

  ```
  $ cd /home/shiyanlou
  $ zip -r -q -o shiyanlou.zip /home/shiyanlou/Desktop
  $ du -h shiyanlou.zip
  $ file shiyanlou.zip
  ```

  上面命令将目录 /home/shiyanlou/Desktop 打包成一个文件，并查看了打包后文件的大小和类型。第一行命令中，`-r` 参数表示递归打包包含子目录的全部内容，`-q` 参数表示为安静模式，即不向屏幕输出信息，`-o`，表示输出文件，需在其后紧跟打包输出文件名。后面使用 `du` 命令查看打包后文件的大小（后面会具体说明该命令）。

- 设置压缩级别为 9 和 1（9 最大，1 最小），重新打包：

  ```
  $ zip -r -9 -q -o shiyanlou_9.zip /home/shiyanlou/Desktop -x ~/*.zip
  $ zip -r -1 -q -o shiyanlou_1.zip /home/shiyanlou/Desktop -x ~/*.zip
  ```

  这里添加了一个参数用于设置压缩级别 `-[1-9]`，1 表示最快压缩但体积大，9 表示体积最小但耗时最久。最后那个 `-x`是为了排除我们上一次创建的 zip 文件，否则又会被打包进这一次的压缩文件中，**注意：这里只能使用绝对路径，否则不起作用**。

  我们再用 `du` 命令分别查看默认压缩级别、最低、最高压缩级别及未压缩的文件的大小：

  ```
  $ du -h -d 0 *.zip ~ | sort
  ```

  通过 man 手册可知：

  - h， --human-readable（顾名思义，你可以试试不加的情况）
  - d， --max-depth（所查看文件的深度）。

- 创建加密 zip 包

  使用 `-e` 参数可以创建加密压缩包：

  ```
  $ zip -r -e -o shiyanlou_encryption.zip /home/shiyanlou/Desktop
  ```

  **注意：** 关于 `zip` 命令，因为 Windows 系统与 Linux/Unix 在文本文件格式上的一些兼容问题，比如换行符（为不可见字符），在 Windows 为 CR+LF（Carriage-Return+Line-Feed：回车加换行），而在 Linux/Unix 上为 LF（换行），所以如果在不加处理的情况下，在 Linux 上编辑的文本，在 Windows 系统上打开可能看起来是没有换行的。如果你想让你在 Linux 创建的 zip 压缩文件在 Windows 上解压后没有任何问题，那么你还需要对命令做一些修改：

  ```
  $ zip -r -l -o shiyanlou.zip /home/shiyanlou/Desktop
  ```

  需要加上 `-l` 参数将 `LF` 转换为 `CR+LF` 来达到以上目的。

- 将 `shiyanlou.zip` 解压到当前目录：

  ```
  $ unzip shiyanlou.zip
  ```

  使用安静模式，将文件解压到指定目录：

  ```
  $ unzip -q shiyanlou.zip -d ziptest
  ```

  上述指定目录不存在，将会自动创建。如果你不想解压只想查看压缩包的内容你可以使用 `-l` 参数：

  ```
  $ unzip -l shiyanlou.zip
  ```

  **注意：** 使用 unzip 解压文件时我们同样应该注意兼容问题，不过这里我们关心的不再是上面的问题，而是中文编码的问题，通常 Windows 系统上面创建的压缩文件，如果有有包含中文的文档或以中文作为文件名的文件时默认会采用 GBK 或其它编码，而 Linux 上面默认使用的是 UTF-8 编码，如果不加任何处理，直接解压的话可能会出现中文乱码的问题（有时候它会自动帮你处理），为了解决这个问题，我们可以在解压时指定编码类型。

  使用 `-O`（英文字母，大写 o）参数指定编码类型：

  ```
  unzip -O GBK 中文压缩文件.zip
  ```

- 在 Linux 上面更常用的是 `tar` 工具，tar 原本只是一个打包工具，只是同时还是实现了对 7z、gzip、xz、bzip2 等工具的支持，这些压缩工具本身只能实现对文件或目录（单独压缩目录中的文件）的压缩，没有实现对文件的打包压缩，所以我们也无需再单独去学习其他几个工具，tar 的解压和压缩都是同一个命令，只需参数不同，使用比较方便。

  下面先掌握 `tar` 命令一些基本的使用方式，即不进行压缩只是进行打包（创建归档文件）和解包的操作。

  - 创建一个 tar 包：

  ```
  $ cd /home/shiyanlou
  $ tar -cf shiyanlou.tar /home/shiyanlou/Desktop
  ```

  上面命令中，`-c` 表示创建一个 tar 包文件，`-f` 用于指定创建的文件名，注意文件名必须紧跟在 `-f` 参数之后，比如不能写成 `tar -fc shiyanlou.tar`，可以写成 `tar -f shiyanlou.tar -c ~`。你还可以加上 `-v` 参数以可视的的方式输出打包的文件。上面会自动去掉表示绝对路径的 `/`，你也可以使用 `-P` 保留绝对路径符。

  - 解包一个文件（`-x` 参数）到指定路径的**已存在**目录（`-C` 参数）：

  ```
  $ mkdir tardir
  $ tar -xf shiyanlou.tar -C tardir
  ```

  - 只查看不解包文件 `-t` 参数：

  ```
  $ tar -tf shiyanlou.tar
  ```

  - 保留文件属性和跟随链接（符号链接或软链接），有时候我们使用 tar 备份文件当你在其他主机还原时希望保留文件的属性（`-p` 参数）和备份链接指向的源文件而不是链接本身（`-h` 参数）：

  ```
  $ tar -cphf etc.tar /etc
  ```

  对于创建不同的压缩格式的文件，对于 tar 来说是相当简单的，需要的只是换一个参数，这里我们就以使用 `gzip` 工具创建 `*.tar.gz` 文件为例来说明。

  - 我们只需要在创建 tar 文件的基础上添加 `-z` 参数，使用 `gzip` 来压缩文件：

  ```
  $ tar -czf shiyanlou.tar.gz /home/shiyanlou/Desktop
  ```

  - 解压 `*.tar.gz` 文件：

  ```
  $ tar -xzf shiyanlou.tar.gz
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn0trf6ij30i1046taf.jpg)

  现在我们要使用其它的压缩工具创建或解压相应文件只需要更改一个参数即可：

  | 压缩文件格式 | 参数 |
  | ------------ | ---- |
  | `*.tar.gz`   | `-z` |
  | `*.tar.xz`   | `-J` |
  | `*tar.bz2`   | `-j` |

- 总结

  - zip：
    - 打包 ：zip something.zip something （目录请加 -r 参数）
    - 解包：unzip something.zip
    - 指定路径：-d 参数
  - tar：
    - 打包：tar -cf something.tar something
    - 解包：tar -xf something.tar
    - 指定路径：-C 参数

### 帮助命令

- Linux 的命令分为内建命令和外部命令，学习帮助命令必须要要搞懂这两者的区别，有一些查看帮助的工具在内建命令与外建命令上是有区别对待的

  > **内建命令**实际上是 shell 程序的一部分，其中包含的是一些比较简单的 Linux 系统命令，这些命令是写在 bash 源码的 builtins 里面的，由 shell 程序识别并在 shell 程序内部完成运行，通常在 Linux 系统加载运行时 shell 就被加载并驻留在系统内存中。而且解析内部命令 shell 不需要创建子进程，因此其执行速度比外部命令快。比如：history、cd、exit 等等。

  > **外部命令**是 Linux 系统中的实用程序部分，因为实用程序的功能通常都比较强大，所以其包含的程序量也会很大，在系统加载时并不随系统一起被加载到内存中，而是在需要时才将其调入内存。虽然其不包含在 shell 中，但是其命令执行过程是由 shell 程序控制的。外部命令是在 Bash 之外额外安装的，通常放在 /bin，/usr/bin，/sbin，/usr/sbin 等等。比如：ls、vi 等。

  简单来说就是：一个是天生自带的天赋技能，一个是后天得来的附加技能。我们可以使用 type 命令来区分命令是内建的还是外部的。例如这两个得出的结果是不同的

  ```
  type exit
  
  type vim
  ```

  得到的是两种结果，若是对 ls 你还能得到第三种结果

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn10k5k9j30nd04otam.jpg)

  ```
  #得到这样的结果说明是内建命令，正如上文所说内建命令都是在 bash 源码中的 builtins 的.def中
  xxx is a shell builtin
  #得到这样的结果说明是外部命令，正如上文所说，外部命令在/usr/bin or /usr/sbin等等中
  xxx is /usr/bin/xxx
  #若是得到alias的结果，说明该指令为命令别名所设定的名称；
  xxx is an alias for xx --xxx
  ```

- help 命令

  尝试下这个命令:

  ```
  help ls
  ```

  得到的结果如图所示，为什么是这样的结果？

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn1h26khj30nf02vmyk.jpg)

  因为 **help 命令是用于显示 shell 内建命令的简要帮助信息**。帮助信息中显示有该命令的简要说明以及一些参数的使用以及说明，一定记住 help 命令只能用于显示内建命令的帮助信息，不然就会得到你刚刚得到的结果。

  那如果是外部命令怎么办，不能就这么抛弃它呀。其实外部命令**基本**上都有一个参数 --help, 这样就可以得到相应的帮助，看到你想要的东西了。试试下面这个命令是不是能看到你想要的东西了。

  ```
  ls --help
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn16jle9j30ne0crtdw.jpg)

- man 命令

  尝试下这个命令

  ```
  man ls
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn1mscpqj30s60kytak.jpg)

  得到的内容比用 help 更多更详细，而且 **man 没有内建与外部命令的区分**，因为 man 工具是显示系统手册页中的内容，也就是一本电子版的字典，这些内容大多数都是对命令的解释信息，还有一些相关的描述。通过查看系统文档中的 man 也可以得到程序的更多相关信息和 Linux 的更多特性。

  是不是好用许多，当然也不代表 help 就没有存在的必要，当你非常紧急只是忘记该用哪个参数的时候，help 这种显示简单扼要的信息就特别实用，若是不太紧急的时候就可以用 man 这种详细描述的查询方式

  在尝试上面这个命令时我们会发现最左上角显示 “LS （1）”，在这里，“ LS ” 表示手册名称，而 “（1）” 表示该手册位于第一章节。这个章节又是什么？在 man 手册中一共有这么几个章节

  | 章节数 | 说明                                                |
  | ------ | --------------------------------------------------- |
  | `1`    | Standard commands （标准命令）                      |
  | `2`    | System calls （系统调用）                           |
  | `3`    | Library functions （库函数）                        |
  | `4`    | Special devices （设备说明）                        |
  | `5`    | File formats （文件格式）                           |
  | `6`    | Games and toys （游戏和娱乐）                       |
  | `7`    | Miscellaneous （杂项）                              |
  | `8`    | Administrative Commands （管理员命令）              |
  | `9`    | 其他（Linux 特定的）， 用来存放内核例行程序的文档。 |

  打开手册之后我们可以通过 pgup 与 pgdn 或者上下键来上下翻看，可以按 q 退出当前页面

- info 命令

  要是你觉得 man 显示的信息都还不够，满足不了你的需求，那试试 info 命令

  ```
  # 查看 ls 命令的 info
  $ info ls
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn1t0unij30sg0lc7cd.jpg)](https://camo.githubusercontent.com/da646639454deeae61a073b42b61ac9041466090/68747470733a2f2f646e2d73696d706c65636c6f75642e73686979616e6c6f752e636f6d2f313133353038313436383231303335383631332d776d)

  得到的信息是不是比 man 还要多了，info 来自自由软件基金会的 GNU 项目，是 GNU 的超文本帮助系统，能够更完整的显示出 GNU 信息。所以得到的信息当然更多。

  man 和 info 就像两个集合，它们有一个交集部分，但与 man 相比，info 工具可显示更完整的　GNU 工具信息。若 man 页包含的某个工具的概要信息在 info 中也有介绍，那么 man 页中会有 “请参考 info 页更详细内容” 的字样。

## 5、Linux 任务计划 crontab

### crontab 入门

- 我们时常会有一些定期定时的任务，如周期性的清理一下／tmp，周期性的去备份一次数据库，周期性的分析日志等等。而且有时候因为某些因素的限制，执行该任务的时间会很尴尬，这时就需要任务计划 crontab

- crontab 简介

  crontab 命令从输入设备读取指令，并将其存放于 crontab 文件中，以供之后读取和执行。通常，crontab 储存的指令被守护进程激活，crond 为其守护进程，crond 常常在后台运行，每一分钟会检查一次是否有预定的作业需要执行。

  通过 crontab 命令，我们可以在固定的间隔时间执行指定的系统指令或 shell　script 脚本。时间间隔的单位可以是分钟、小时、日、月、周的任意组合。

  这里我们看一看 crontab 的格式

  ```
  # Example of job definition:
  # .---------------- minute (0 - 59)
  # |  .------------- hour (0 - 23)
  # |  |  .---------- day of month (1 - 31)
  # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
  # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
  # |  |  |  |  |
  # *  *  *  *  * user-name command to be executed
  ```

- crontab 准备

  启动 rsyslog ，以便可以通过日志的信息来了解我们的任务是否真正的被执行了（一般 Ubuntu 会默认启动）

  ```
  sudo service rsyslog start
  ```

  启动 crontab （一般 Ubuntu 会默认启动）

  ```
  sudo cron －f &
  ```

- crontab 使用

  我们通过下面一个命令来添加一个计划任务

  ```
  crontab -e
  ```

  第一次启动会提示选择编辑工具，选择基本的 vim 即可

  而选择后我们会进入这样一个画面，这就是添加计划的地方了，与一般的配置文档相同，以 #号开头的都是注释，可以看看格式是怎样的

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn3tgxuwj30s60kyk4b.jpg)

  详细的格式可以使用上一节中学习到的 man 命令查看，每项工作（这里就是每行）都有六个栏目，分别为：

  | 代表意义 | 分钟 | 小时 | 日期 | 月份 | 周   | 指令         |
  | -------- | ---- | ---- | ---- | ---- | ---- | ------------ |
  | 数字范围 | 0-59 | 0-23 | 1-31 | 1-12 | 0-7  | 就是各种命令 |

  另外还有一些辅助字符

  | 特殊字符  | 代表意义                                                     |
  | --------- | ------------------------------------------------------------ |
  | *(星号)   | 代表任何时刻都接受的意思！举例来说，范例一内那个日、月、周都是 * ， 就代表着『不论何月、何日的礼拜几的 12:00 都执行后续指令』的意思！ |
  | ,(逗号)   | 代表分隔时段的意思。举例来说，如果要下达的工作是 3:00 与 6:00 时，就会是：0 3,6 * * * command 时间参数还是有五栏，不过第二栏是 3,6 ，代表 3 与 6 都适用！ |
  | -(减号)   | 代表一段时间范围内，举例来说， 8 点到 12 点之间的每小时的 20 分都进行一项工作：20 8-12 * * * command 仔细看到第二栏变成 8-12 喔！代表 8,9,10,11,12 都适用的意思！ |
  | /n (斜线) | 那个 n 代表数字，亦即是『每隔 n 单位间隔』的意思，例如每五分钟进行一次，则： */5 * * * * command 很简单吧！用 * 与 / 5 来搭配，也可以写成 0-59/5 ，相同意思！ |

  在了解命令格式之后，我们通过这样的一个例子来完成一个任务的添加，在文档的最后一排加上这样一排命令，该任务是每分钟我们会在 /home/shiyanlou 目录下创建一个以当前的年月日时分秒为名字的空白文件，别忘了保存并退出的命令`:wq`

  ```
  */1 * * * * touch /home/shiyanlou/$(date +\%Y\%m\%d\%H\%M\%S)
  ```

  > **注意** “%” 在 crontab 文件中，有结束命令行、换行、重定向的作用，前面加 ” \ ” 符号转义，否则，“ % ” 符号将执行其结束命令行或者换行的作用，并且其后的内容会被做为标准输入发送给前面的命令。

  添加成功后我们会得到最后一排 installing new crontab 的一个提示

  [![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn3dd30ij30s60kyacz.jpg)

  当然我们也可以通过这样的一个指令来查看我们添加了哪些任务

  ```
  crontab -l 
  ```

  通过图中的显示，我们也可以看出，我们正确的保存并且添加成功了该任务的

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn4p98bzj30s60kyacw.jpg)

  虽然我们添加了任务，但是如果 cron 的守护进程并没有启动，它根本都不会监测到有任务，当然也就不会帮我们执行，我们可以通过以下 2 种方式来确定我们的 cron 是否成功的在后台启动，默默的帮我们做事，若是没有就得执行上文准备中的第二步了

  ```
  ps aux | grep cron
  
  or
  
  pgrep cron
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn4w3obsj30n804bjtt.jpg)

  通过下图可以看到任务在创建之后，执行了几次，生成了一些文件，且每分钟生成一个：

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn514bjoj30n806j78a.jpg)

  我们通过这样一个命令可以查看到执行任务命令之后在日志中的信息反馈

  ```
  sudo tail -f /var/log/syslog
  ```

  从图中我们可以看到分别在 13 点 28、29、30 分的 01 秒为我们在 shiyanlou 用户的家目录下创建了文件

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn56jhlij30nh0do7cf.jpg)

  当我们并不需要这个任务的时候我们可以使用 -r 参数去删除所有例行性工作调度

  ```
  crontab -r
  ```

  如果只想删除某个任务，那么用 -e 参数去修改即可

  通过图中我们可以看出我们删除之后再查看任务列表，系统已经显示该用户并没有任务了

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn5cdbdbj30na01v3z1.jpg)

- 多用户使用 crontab

  每个用户使用 `crontab -e` 添加计划任务，都会在 `/var/spool/cron/crontabs` （这是个执行文件）中添加一个该用户自己的任务文档

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn5hwv59j30s60kydii.jpg)

  如果是系统级别的定时任务，应该如何处理？只需要以 sudo 权限编辑 `/etc/crontab` 文件就可以，有时 crontab 是读到内存当中的，编辑 `/etc/crontab` 之后可能不会立马生效，需要重新启动 crond 服务

  cron 服务监测时间最小单位是分钟，所以 cron 会每分钟去读取一次 `/etc/crontab` 与 `/var/spool/cron/crontabs` 里面的內容

  `/etc/crontab` 文件内容如下：

  ```
  `[root@study ~]# cat /etc/crontab  SHELL=/bin/bash                      <==使用哪种shell介面  PATH=/sbin:/bin:/usr/sbin:/usr/bin   <==执行档搜寻路径  MAILTO=root                          <==若有额外STDOUT，以email将资料送给谁  # Example of job definition: # .---------------- minute (0 - 59) # | .------------- hour (0 - 23) # | | .---------- day of month (1 - 31) # | | | .------- month (1 - 12) OR jan,feb,mar,apr ... # | | | | .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat # | | | | | # * * * * * user-name command to be executed`
  ```

  在 /etc 目录下，cron 相关的目录有下面几个：

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rn5tvybrj30s60kyq5e.jpg)

  每个目录的作用：

  1. /etc/cron.daily，目录下的脚本会每天执行一次，在每天的 6 点 25 分时运行；
  2. /etc/cron.hourly，目录下的脚本会每个小时执行一次，在每小时的 17 分钟时运行；
  3. /etc/cron.monthly，目录下的脚本会每月执行一次，在每月 1 号的 6 点 52 分时运行；
  4. /etc/cron.weekly，目录下的脚本会每周执行一次，在每周第七天的 6 点 47 分时运行；

  系统默认执行时间可以根据需求进行修改

### 挑战：备份日志

小明是一个服务器管理员，他需要每天备份论坛数据（这里我们用 `alternatives.log` 日志替代），备份当天的日志并删除之前的日志。而且备份之后文件名是 `年-月-日` 的格式。`alternatives.log` 在 `/var/log/` 下面。

#### 目标

1. 为 `shiyanlou` 用户添加计划任务
2. 每天凌晨 3 点的时候定时备份 `alternatives.log` 到 `/home/shiyanlou/tmp/` 目录
3. 命名格式为 `年-月-日`，比如今天是 2017 年 4 月 1 日，那么文件名为 `2017-04-01`

#### 提示语

- date
- crontab
- cp 命令
- 用一条命令写在 crontab 里面即可，不用写脚本

注意 crontab 的计划任务设定的用户：

```
$ crontab -e 表示为当前用户添加计划任务
$ sudo crontab -e 表示为root用户添加计划任务
```

注意使用下面的命令启动 crontab：

```
$ sudo cron －f &
```

#### 参考答案

注意：请务必自己独立思考解决问题之后再对照参考答案，一开始直接看参考答案收获不大。

```
sudo cron -f &
crontab -e 添加
0 3 * * * sudo rm /home/shiyanlou/tmp/*
0 3 * * * sudo cp /var/log/alternatives.log /home/shiyanlou/tmp/$(date +\%Y-\%m-\%d)
```

> 部分内容参考[鸟哥的 Linux 私房菜 - 例行性工作（crontab）](http://linux.vbird.org/linux_basic/0430cron.php)

## 6、Linux 命令执行顺序、管道、文本处理命令、I/O重定向

### 命令执行顺序

- 顺序执行

  以下三条命令逐条输入：

  ```
  $ sudo apt-get update
  # 等待——————————然后输入下面的命令
  $ sudo apt-get install some-tool //这里some-tool是指具体的软件包，例如：banner
  # 等待——————————然后输入下面的命令
  $ some-tool
  ```

  这时你可能就会想：要是我可以一次性输入完，让它自己去依次执行各命令就好了，你可以使用 `;` 来完成，比如上述操作你可以：

  ```
  $ sudo apt-get update;sudo apt-get install some-tool;some-tool
  # 让它自己运行
  ```

- 有选择的执行命令

  关于上面的操作，如果我们在让它自动顺序执行命令时，前面的命令执行不成功，而后面的命令又依赖于上一条命令的结果，那么就会造成花了时间，最终却得到一个错误的结果，而且有时候直观的看你还无法判断结果是否正确。

  我们需要能够有选择性的来执行命令，比如我们使用 `which` 来查找是否安装某个命令，如果找到就执行该命令，否则什么也不做：

  ```
  $ which cowsay>/dev/null && cowsay -f head-in ohch~
  ```

  你如果没有安装 `cowsay`，你可以先执行一次上述命令，你会发现什么也没发生，你再安装好之后你再执行一次上述命令，你也会发现一些惊喜。

  上面的 `&&` 就是用来实现选择性执行的，它表示如果前面的命令执行结果（不是表示终端输出的内容，而是表示命令执行状态的结果）返回 0 则执行后面的，否则不执行，你可以从 `$?` 环境变量获取上一次命令的返回结果：

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rnci2gb5j30lq0hhwh6.jpg)

  学习过 C 语言的用户应该知道在 C 语言里面 `&&` 表示逻辑与，而且还有一个 `||` 表示逻辑或，同样 Shell 也有一个 `||`，或的逻辑是：当前面不成功时，再判断（执行）后面，于是`||` 在这里就是与 `&&` 相反的控制效果，当上一条命令执行结果为≠0 ($?≠0) 时则执行它后面的命令：

  ```
  $ which cowsay>/dev/null || echo "cowsay has not been install, please run 'sudo apt-get install cowsay' to install"
  ```

  除了上述基本的使用之外，我们还可以结合着 `&&` 和 `||` 来实现一些操作，比如：

  ```
  $ which cowsay>/dev/null && echo "exist" || echo "not exist"
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rncn0ib7j30jw0540up.jpg)

  画个流程图来解释一下上面的流程：

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rncqvc0oj30660i9q34.jpg)

### 管道（pipeline）

- 管道是什么？管道是一种通信机制，通常用于进程间的通信（也可通过 socket 进行网络通信），它表现出来的形式就是将前面每一个进程的输出 (stdout) 直接作为下一个进程的输入 (stdin)。

  管道又分为匿名管道和具名管道（这里将不会讨论在源程序中使用系统调用创建并使用管道的情况，它与命令行的管道在内核中实际都是采用相同的机制）。我们在使用一些过滤程序时经常会用到的就是匿名管道，在命令行中由 `|` 分隔符表示，`|` 在前面的内容中我们已经多次使用到了。具名管道简单的说就是有名字的管道，通常只会在源程序中用到具名管道。

- 先试用一下管道，比如查看 `/etc` 目录下有哪些文件和目录，使用 `ls` 命令来查看：

  ```
  $ ls -al /etc
  ```

  有太多内容，屏幕不能完全显示，这时候可以使用滚动条或快捷键滚动窗口来查看。不过这时候可以使用管道：

  ```
  $ ls -al /etc | less
  ```

  通过管道将前一个命令 (`ls`) 的输出作为下一个命令 (`less`) 的输入，然后就可以一行一行地看。

  接下来通过一些文本处理命令来熟悉管道的操作。

### 文本处理命令：cut、grep、wc、sort、uniq、tr、col、join、paste

- cut 命令，打印每一行的某一字段

  cut 命令的 -d 参数传入分隔符，-f 参数传入要打印的第几个字段，比如打印 `/etc/passwd` 文件中以`:` 为分隔符的第 1 个字段和第 6 个字段分别表示用户名和其家目录：

  ```
  $ cut /etc/passwd -d ':' -f 1,6
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rngve0a4j30k80nbwjb.jpg)

  打印 `/etc/passwd` 文件中每一行的前 N 个字符：

  ```
  # 前五个（包含第五个）
  $ cut /etc/passwd -c -5
  # 前五个之后的（包含第五个）
  $ cut /etc/passwd -c 5-
  # 第五个
  $ cut /etc/passwd -c 5
  # 2到5之间的（包含第五个）
  $ cut /etc/passwd -c 2-5
  ```

- grep 命令，在文本中或 stdin 中查找匹配字符串

  `grep` 命令是很强大的，也是相当常用的一个命令，它结合正则表达式可以实现很复杂却很高效的匹配和查找

  `grep` 命令的一般形式为：

  ```
  grep [命令选项]... 用于匹配的表达式 [文件]...
  ```

  还是先体验一下，我们搜索 `/home/shiyanlou` 目录下所有包含 "shiyanlou" 的文本文件，并显示出现在文本中的行号：

  ```
  $ grep -rnI "shiyanlou" ~
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rniaxwayj30kb07qwi6.jpg)

  `-r` 参数表示递归搜索子目录中的文件，`-n` 表示打印匹配项行号，`-I` 表示忽略二进制文件

- wc 命令，简单小巧的计数工具

  wc 命令用于统计并输出一个文件中行、单词和字节的数目，比如输出 `/etc/passwd` 文件的统计信息：

  ```
  $ wc /etc/passwd
  ```

  分别只输出行数、单词数、字节数、字符数和输入文本中最长一行的字节数：

  ```
  # 行数
  $ wc -l /etc/passwd
  # 单词数
  $ wc -w /etc/passwd
  # 字节数
  $ wc -c /etc/passwd
  # 字符数
  $ wc -m /etc/passwd
  # 最长行字节数
  $ wc -L /etc/passwd
  ```

  **注意：对于西文字符来说，一个字符就是一个字节，但对于中文字符一个汉字是大于 2 个字节的，具体数目是由字符编码决定的**

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rnj4k0p0j30ka09en02.jpg)

  再来结合管道来操作一下，下面统计 /etc 下面所有目录数：

  ```
  $ ls -dl /etc/*/ | wc -l
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rnj8zo5lj30gc0243yb.jpg)

- sort 排序命令

  这个命令前面我们也是用过多次，功能很简单就是将输入按照一定方式排序，然后再输出，它支持的排序有按字典排序，数字排序，按月份排序，随机排序，反转排序，指定特定字段进行排序等等。

  默认为字典排序：

  ```
  $ cat /etc/passwd | sort
  ```

  反转排序：

  ```
  $ cat /etc/passwd | sort -r
  ```

  按特定字段排序：

  ```
  $ cat /etc/passwd | sort -t':' -k 3
  ```

  上面的 `-t` 参数用于指定字段的分隔符，这里是以 ":" 作为分隔符；`-k 字段号`用于指定对哪一个字段进行排序。这里 `/etc/passwd` 文件的第三个字段为数字，默认情况下是以字典序排序的，如果要按照数字排序就要加上 `-n` 参数：

  ```
  $ cat /etc/passwd | sort -t':' -k 3 -n
  ```

  注意观察第二个冒号后的数字： 

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rnp30cktj30k70h8agk.jpg)

- uniq 去重命令

  `uniq` 命令可以用于过滤或者输出重复行。

  - 过滤重复行

  我们可以使用 `history` 命令查看最近执行过的命令（实际为读取 ${SHELL}_history 文件，如我们环境中的～/.zsh_history 文件），不过你可能只想查看使用了哪个命令而不需要知道具体干了什么，那么你可能就会要想去掉命令后面的参数然后去掉重复的命令：

  ```
  $ history | cut -c 8- | cut -d ' ' -f 1 | uniq
  ```

  然后经过层层过滤，你会发现确是只输出了执行的命令那一列，不过去重效果好像不明显，仔细看你会发现它确实去重了，只是不那么明显，之所以不明显是**因为 uniq 命令只能去连续重复的行，不是全文去重**，所以要达到预期效果，我们先排序：

  ```
  $ history | cut -c 8- | cut -d ' ' -f 1 | sort | uniq
  # 或者$ history | cut -c 8- | cut -d ' ' -f 1 | sort -u
  ```

  这就是 Linux/UNIX 哲学吸引人的地方，大繁至简，一个命令只干一件事却能干到最好。

  - 输出重复行

  ```
  # 输出重复过的行（重复的只输出一个）及重复次数
  $ history | cut -c 8- | cut -d ' ' -f 1 | sort | uniq -dc
  # 输出所有重复的行
  $ history | cut -c 8- | cut -d ' ' -f 1 | sort | uniq -D
  ```

- tr 命令，删除

  tr 命令可以用来删除一段文本信息中的某些文字。或者将其进行转换。

  #### 使用方式：

  ```
  tr [option]...SET1 [SET2]
  ```

  #### 常用的选项有：

  | 选项 | 说明                                                         |
  | ---- | ------------------------------------------------------------ |
  | `-d` | 删除和 set1 匹配的字符，注意不是全词匹配也不是按字符顺序匹配 |
  | `-s` | 去除 set1 指定的在输入文本中连续并重复的字符                 |

  #### 操作举例：

  ```
  # 删除 "hello shiyanlou" 中所有的'o','l','h'
  $ echo 'hello shiyanlou' | tr -d 'olh'
  # 将"hello" 中的ll,去重为一个l
  $ echo 'hello' | tr -s 'l'
  # 将输入文本，全部转换为大写或小写输出
  $ echo 'input some text here' | tr '[:lower:]' '[:upper:]'
  # 上面的'[:lower:]' '[:upper:]'你也可以简单的写作'[a-z]' '[A-Z]',当然反过来将大写变小写也是可以的
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rnv2sdetj30k805umyv.jpg)

- col 命令，转换 tab 与空格

  col 命令可以将 `Tab` 换成对等数量的空格键，或反转这个操作。

  #### 使用方式：

  ```
  col [option]
  ```

  #### 常用的选项有：

  | 选项 | 说明                           |
  | ---- | ------------------------------ |
  | `-x` | 将 `Tab` 转换为空格            |
  | `-h` | 将空格转换为 `Tab`（默认选项） |

  #### 操作举例：

  ```
  # 查看 /etc/protocols 中的不可见字符，可以看到很多 ^I ，这其实就是 Tab 转义成可见字符的符号
  $ cat -A /etc/protocols
  # 使用 col -x 将 /etc/protocols 中的 Tab 转换为空格,然后再使用 cat 查看，你发现 ^I 不见了
  $ cat /etc/protocols | col -x | cat -A
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rnvruoy5j30kc07z0vy.jpg)

- join 命令，将两个文件中包含相同内容的那一行合并在一起

  学过数据库的用户对这个应该不会陌生，这个命令就是用于将两个文件中包含相同内容的那一行合并在一起。

  #### 使用方式：

  ```
  join [option]... file1 file2
  ```

  #### 常用的选项有：

  | 选项 | 说明                                                 |
  | ---- | ---------------------------------------------------- |
  | `-t` | 指定分隔符，默认为空格                               |
  | `-i` | 忽略大小写的差异                                     |
  | `-1` | 指明第一个文件要用哪个字段来对比，默认对比第一个字段 |
  | `-2` | 指明第二个文件要用哪个字段来对比，默认对比第一个字段 |

  #### 操作举例：

  ```
  $ cd /home/shiyanlou
  # 创建两个文件，因为默认分隔符为空格，所以两个文件的第一行都有‘1’，故可以合并
  $ echo '1 hello' > file1
  $ echo '1 shiyanlou' > file2
  $ join file1 file2
  # 将/etc/passwd与/etc/shadow两个文件合并，指定以':'作为分隔符
  $ sudo join -t':' /etc/passwd /etc/shadow
  # 将/etc/passwd与/etc/group两个文件合并，指定以':'作为分隔符, 分别比对第4和第3个字段
  $ sudo join -t':' -1 4 /etc/passwd -2 3 /etc/group
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rnzjoumej30jq09mdjy.jpg)

- paste 命令，不对比数据，简单将多个文件合并

  `paste` 这个命令与 `join` 命令类似，它是在不对比数据的情况下，简单地将多个文件合并一起，以 `Tab` 隔开。

  #### 使用方式：

  ```
  paste [option] file...
  ```

  #### 常用的选项有：

  | 选项 | 说明                         |
  | ---- | ---------------------------- |
  | `-d` | 指定合并的分隔符，默认为 Tab |
  | `-s` | 不合并到一行，每个文件为一行 |

  #### 操作举例：

  ```
  $ echo hello > file1
  $ echo shiyanlou > file2
  $ echo www.shiyanlou.com > file3
  $ paste -d ':' file1 file2 file3
  $ paste -s file1 file2 file3
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0ro8wwdoij30k606a763.jpg)

- 字符转换

  Windows/dos 与 Linux/UNIX 文本文件一些特殊字符`不一致`，如断行符 Windows 为 CR+LF (`\r\n`)，Linux/UNIX 为 LF (`\n`)。使用 `cat -A 文本` 可以看到文本中包含的不可见特殊字符。Linux 的 `\n` 表现出来就是一个 `$`，而 Windows/dos 的表现为 `^M$`，可以直接使用 `dos2unix` 和 `unix2dos` 工具在两种格式之间进行转换，使用 `file` 命令可以查看文件的具体类型。

  > 回车”（Carriage Return）和 “换行”（Line Feed）这两个概念的来历和区别。
  >        在计算机还没有出现之前，有一种叫做电传打字机（Teletype Model 33，Linux/Unix 下的 tty 概念也来自于此）的玩意，每秒钟可以打 10 个字符。但是它有一个问题，就是打完一行换行的时候，要用去 0.2 秒，正好可以打两个字符。要是在这 0.2 秒里面，又有新的字符传过来，那么这个字符将丢失。
  >
  > ​         于是，研制人员想了个办法解决这个问题，就是在每行后面加两个表示结束的字符。一个叫做 “回车”，告诉打字机把打印头定位在左边界；另一个叫做 “换行”，告诉打字机把纸向下移一行。这就是 “换行” 和 “回车” 的来历，从它们的英语名字上也可以看出一二。
  >
  > ​        后来，计算机发明了，这两个概念也就被般到了计算机上。那时，存储器很贵，一些科学家认为在每行结尾加两个字符太浪费了，加一个就可以。于是，就出现了分歧。
  >
  > ​        Unix 系统里，每行结尾只有 “<换行>”，即 "\n"；Windows 系统里面，每行结尾是 “< 换行 >< 回车 >”，即 “\n\r”；Mac 系统里，每行结尾是 “< 回车 >”，即 "\n"；。一个直接后果是，Unix/Mac 系统下的文件在 Windows 里打开的话，所有文字会变成一行；而 Windows 里的文件在 Unix/Mac 下打开的话，在每行的结尾可能会多出一个 ^M 符号。 

  1. 利用 vim 编辑器

     利用 Linux 下的 vim 编辑器，可以方便的在 dos 文件、unix 文件之间进行切换，且可以便利的去除恼人的 `^M` 

     ```html
     vim file
     ```

     然后，在 vim 中使用以下命令用于查看当前文件是 dos 格式还是 unix 格式

     ```
     :set ff?
     ```

     在 vim 中强制切换为 unix/dos 格式，然后保存即可：

     ```
     :set ff=unix #转换为unix格式
     or
     :set ff=dos #转换为dos格式
     :wq #保存、退出
     ```

     ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rpd4z62bj30gh068757.jpg)

  2. 调用dos2unix中的两个命令：dos2unix、unix2dos

     格式：

     ```
     $ dos2unix [options] <files>
     ```

     - `-o <files>`：直接操作输入文件进行编码转换，此处的 `-o` 可以省略；
     - `-n <input> <output>`：转换输入文件，将操作结果输出至新的输出文件；
     - `-i <files>`：仅查看文件的格式信息，不对文件进行转换操作；
     - `-f`、`--force`：强制转换二进制文件，默认为跳过二进制文件；
     - `-k`、`--keep-date`：保持新文件的时间戳（修改时间）不变；

     ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rqi8v3ptj30gh06ngms.jpg)

  > Linux 提供了两种文本格式相互转化的命令：dos2unix 和 unix2dos，dos2unix 把 "\r\n" 转化成 "\n"，unix2dos 把 "\n" 转化成 "\r\n"。
  >
  > 注意下载时要下载 dos2unix 包：
  >
  > ```
  > sudo apt-get install dos2unix
  > ```

  3. 利用 tr 命令

     经过各种实践，利用 tr 命令去替换 `\r\n` 与 `\n` 或者去替换 `^M$` 与 `$`，会出现各种意想不到的结果，这里就不深究了，还是参考前两点吧。

### 重定向

- 前文已经多次见过 `>` 或 `>>` 操作了，分别是将标准输出导向一个文件或追加到一个文件中。这其实就是重定向，将原本输出到标准输出的数据重定向到一个文件中，因为标准输出 (`/dev/stdout`) 本身也是一个文件，我们将命令输出导向另一个文件自然也是没有任何问题的。

- 在更多了解 Linux 的重定向之前，我们需要先知道一些基本的东西，前面我们已经提到过 Linux 默认提供了三个特殊设备，用于终端的显示和输出，分别为 `stdin`（标准输入，对应于你在终端的输入），`stdout`（标准输出，对应于终端的输出），`stderr`（标准错误输出，对应于终端的输出）。

  | 文件描述符 | 设备文件      | 说明     |
  | ---------- | ------------- | -------- |
  | `0`        | `/dev/stdin`  | 标准输入 |
  | `1`        | `/dev/stdout` | 标准输出 |
  | `2`        | `/dev/stderr` | 标准错误 |

  > 文件描述符：文件描述符在形式上是一个非负整数。实际上，它是一个索引值，指向内核为每一个进程所维护的该进程打开文件的记录表。当程序打开一个现有文件或者创建一个新文件时，内核向进程返回一个文件描述符。在程序设计中，一些涉及底层的程序编写往往会围绕着文件描述符展开。但是文件描述符这一概念往往只适用于 UNIX、Linux 这样的操作系统。

  我们可以这样使用这些文件描述符：

  默认使用终端的标准输入作为命令的输入和标准输出作为命令的输出

  ```
  $ cat 
  （按Ctrl+C退出）
  ```

  将 cat 的连续输出（heredoc 方式）重定向到一个文件

  ```
  $ mkdir Documents
  $ cat > Documents/test.c <<EOF
  #include <stdio.h>
  
  int main()
  {
      printf("hello world\n");
      return 0;
  }
  
  EOF
  ```

  将一个文件作为命令的输入，标准输出作为命令的输出

  ```
  $ cat Documents/test.c
  ```

  将 echo 命令通过**管道传过来的数据作为 cat 命令的输入**，将标准输出作为命令的输出

  ```
  $ echo 'hi' | cat
  ```

- 标准输出重定向

  将 echo 命令的输出从默认的标准输出**重定向到一个普通文件**

  ```
  $ echo 'hello shiyanlou' > redirect
  $ cat redirect
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0rrf5x44wj30hs0gowic.jpg)

  初学者这里要注意不要将管道和重定向混淆，**管道默认是连接前一个命令的输出到下一个命令的输入**，而重定向通常是需要一个文件来建立两个命令的连接，你可以仔细体会一下上述第三个操作和最后两个操作的异同点。

- 标准错误重定向

  都被指向伪终端的屏幕显示，所以我们经常看到的一个命令的输出通常是同时包含了标准输出和标准错误的结果的。比如下面的操作：

  ```
  # 使用cat 命令同时读取两个文件，其中一个存在，另一个不存在
  $ cat Documents/test.c hello.c
  # 你可以看到除了正确输出了前一个文件的内容，还在末尾出现了一条错误信息，见下图
  # 那如果我们将输出重定向到一个文件呢？见下图
  $ cat Documents/test.c hello.c > somefile
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0s0160cq0j30fd06fgmb.jpg)

  遗憾的是，这里依然出现了那条错误信息，其实标准输出和标准错误虽然都指向终端屏幕，实际它们并不一样。

  但有时我们就是要隐藏某些错误或者警告，那又该怎么做呢？这就需要用到我们前面讲的文件描述符了：

  ```
  # 将标准错误（2）重定向到标准输出（1），再将标准输出重定向到文件（somefile），注意要将重定向到文件写到前面，且必须在文件描述符（1）前加上 & ，否则 shell 会当做重定向到一个文件名为 1 的文件中
  $ cat Documents/test.c hello.c >somefile  2>&1
  # 或者只用bash提供的特殊的重定向符号"&"将标准错误和标准输出同时重定向到文件
  $ cat Documents/test.c hello.c &>somefilehell
  ```

  效果如下：

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0s01a52iij30g90bzdfw.jpg)

- 使用 tee 命令同时重定向到多个文件

  你可能还有这样的需求，除了需要将输出重定向到文件，也需要将信息打印在终端。那么你可以使用 `tee` 命令来实现：

  ```
  $ echo 'hello shiyanlou' | tee hello
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0s0akrj0tj30hy04fwfs.jpg)

  tee 命令详解

  - tee：将上一个命令的STDOUT通过T管道重定向到该文件，再发送到另一个命令的STDIN

  - 举例：

    ifconfig eth0 | grep pattern | tee /root/interface-info | cut -f2 -d: | cut -f1 -d" "

  - 再举例：
    使用tee的示意图：ls -l的输出被导向 tee，并且复制到档案　file.txt 以及下一个命令 less。tee 的名称来自于这个图示，它看起来像是大写的字母 T。

  ![](https://upload.wikimedia.org/wikipedia/commons/2/24/Tee.svg)

- 使用 exec 命令永久重定向

  之前的例子中重定向都是临时性的，**如果我们想把标准输出永久重定向到某个文件（尤其是日志文件）中**，可以用 exec 命令

  `exec`命令的作用是使用指定的命令替换当前的 Shell，即使用一个进程替换当前进程，或者指定新的重定向：

  ```
  # 先开启一个子 Shell
  $ zsh
  # 使用exec替换当前进程的重定向，将标准输出（1）重定向到一个文件
  $ exec 1>somefile
  # 后面你执行的命令的“输出”都将被重定向到名为‘somefile’的文件中,直到你退出当前子shell，或取消exec的重定向（如何取消见后续操作）
  $ ls
  $ exit
  $ cat somefile
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0s0ejs2xtj30cy07dwed.jpg)

  可以看到，执行 ls 命令的输出并没有显示在终端上，查看 somefile 文件，可以看到其中的内容正是 ls 命令的输出

- 创建输出文件描述符

  在 Shell 中有 9 个文件描述符。上面我们使用了也是它默认提供的 0,1,2 号文件描述符。另外我们还可以使用 3-8 的文件描述符，只是它们默认没有打开而已。你可以使用下面命令查看当前 Shell 进程中打开的文件描述符：

  ```
  $ cd /dev/fd/;ls -Al
  ```

  同样使用 `exec` 命令可以创建新的文件描述符：

  ```
  $ zsh
  $ exec 3>somefile
  # 先进入目录，再查看，否则你可能不能得到正确的结果，然后再回到上一次的目录
  $ cd /dev/fd/;ls -Al;cd -
  # 把字符串重定向到文件描述符3，而3会重定向到somefile文件，注意下面的命令>与&之间不应该有空格
  $ echo "this is test" >&3
  $ cat somefile
  $ exit
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0s0j683p7j30k20bwdjv.jpg)

- 关闭文件描述符

  EASY，如上面我们打开的 3 号文件描述符，可以使用如下操作将它关闭：

  ```
  $ exec 3>&-
  $ cd /dev/fd;ls -Al;cd -
  ```

- 完全屏蔽命令的输出

  在 Linux 中有一个被称为 “黑洞” 的设备文件，所有导入它的数据都将被 “吞噬”。

  > 在类 UNIX 系统中，/dev/null，或称空设备，是一个特殊的设备文件，它通常被用于丢弃不需要的输出流，或作为用于输入流的空文件，这些操作通常由重定向完成。读取它则会立即得到一个 EOF。

  我们可以利用设个 `/dev/null` 屏蔽命令的输出：

  ```
  $ cat Documents/test.c nefile 1>/dev/null 2>&1
  ```

  上面这样的操作将使你得不到任何输出结果，也可以叫它“垃圾箱”

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

- 使用 xargs 命令分割参数列表

  > xargs 是一条 UNIX 和类 UNIX 操作系统的常用命令。它的作用是将参数列表转换成小块分段传递给其他命令，以避免参数列表过长的问题。

  这个命令在有些时候十分有用，特别是当用来处理产生大量输出结果的命令如 find，locate 和 grep 的结果，详细用法请参看 man 文档。

  ```
  $ cut -d: -f1 < /etc/passwd | sort | xargs echo
  ```

  上面这个命令用于将 `/etc/passwd` 文件按`:` 分割取第一个字段排序后，使用 `echo` 命令生成一个列表

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0s0s6rd7gj30gh02l0ta.jpg)

- 比较

  - 标准的命令用法：

    grep root /etc/passwd

  - 重定向：

    grep root < /etc/passwd

  - 管道：

    cat /etc/passwd | grep root

  - 三种原理不一样，但结果一样

### 挑战：历史命令

在 Linux 中，对于文本的处理和分析是极为重要的，现在有一个文件叫做 data1，可以使用下面的命令下载：

```
$ cd /home/shiyanlou
$ wget http://labfile.oss.aliyuncs.com/courses/1/data1
```

data1 文件里记录是一些命令的操作记录，现在需要你从里面找出出现频率次数前 3 的命令并保存在 `/home/shiyanlou/result`。

目标

1. 处理文本文件 `/home/shiyanlou/data1`
2. 将结果写入 `/home/shiyanlou/result`
3. 结果包含三行内容，每行内容都是出现的次数和命令名称，如 “100 ls”

提示

1. cut 截取 (参数可以使用 `-c 8-`，使用 man cut 可以查看含义)
2. `uniq -dc` 去重
3. sort 的参数选择 `-k1 -n -r`
4. 操作过程使用管道，例如：

```
$ cd /home/shiyanlou
$ cat data1 |....|....|....   >  /home/shiyanlou/result
```

来源：2016 年百度校招面试题

我的答案

```
shiyanlou:~/ $ cut data1 -c 8- | cut -d ' ' -f 1 | sort | uniq -dc | sort -rn | head -n 3
```

思考

- 题目要求统计整条命令的频次，而我只截取了命令名称计数，按题目的意思 `cd .` 与 `cd ..` 是两条命令，而在我的方法下会认为是同一条命令
- 文件中有些命令占据两行，无论是我的答案还是参考答案都没考虑这个

参考答案

```
cat data1 |cut -c 8-|sort|uniq -dc|sort -rn -k1 |head -3 > /home/shiyanlou/result
```

## 7、Linux 三剑客——grep、sed、awk

### 正则表达式

- 什么是正则表达式呢？

> **正则表达式**，又称正规表示式、正规表示法、正规表达式、规则表达式、常规表示法（英语：Regular Expression，在代码中常简写为 regex、regexp 或 RE），计算机科学的一个概念。正则表达式使用单个字符串来描述、匹配一系列符合某个句法规则的字符串。在很多文本编辑器里，正则表达式通常被用来检索、替换那些符合某个模式的文本。

> 许多程序设计语言都支持利用正则表达式进行字符串操作。例如，在 Perl 中就内建了一个功能强大的正则表达式引擎。正则表达式这个概念最初是由 UNIX 中的工具软件（例如 `sed` 和 `grep`）普及开的。正则表达式通常缩写成 “regex”，单数有 regexp、regex，复数有 regexps、regexes、regexen。

​	简单的说形式和功能上正则表达式和我们前面讲的通配符很像，不过它们之间又有很大差别，特别在于一些特殊的匹配字符的含义上

- 一个正则表达式通常被称为一个模式（**pattern**），为用来描述或者匹配一系列符合某个句法规则的字符串。

  #### 选择

  `|` 竖直分隔符表示选择，例如 "boy|girl" 可以匹配 "boy" 或者 "girl"

  #### 数量限定

  数量限定除了我们举例用的 `*`, 还有 `+` 加号，`?` 问号，如果在一个模式中不加数量限定符则表示出现一次且仅出现一次：

  - `+` 表示前面的字符必须出现至少一次 (1 次或多次)，例如，"goo+gle", 可以匹配 "gooogle","goooogle" 等；
  - `?` 表示前面的字符最多出现一次 (0 次或 1 次)，例如，"colou?r", 可以匹配 "color" 或者 "colour";
  - `*` 星号代表前面的字符可以不出现，也可以出现一次或者多次（0 次、或 1 次、或多次），例如，“0*42” 可以匹配 42、042、0042、00042 等。

  #### 范围和优先级

  `()` 圆括号可以用来定义模式字符串的范围和优先级，这可以简单的理解为是否将括号内的模式串作为一个整体。例如，"gr (a|e) y" 等价于 "gray|grey"，（这里体现了优先级，竖直分隔符用于选择 a 或者 e 而不是 gra 和 ey），"(grand)?father" 匹配 father 和 grandfather（这里体验了范围，`?` 将圆括号内容作为一个整体匹配）。

  #### 语法（部分）

  正则表达式有多种不同的风格，下面列举一些常用的作为 PCRE 子集的适用于 `perl` 和 `python` 编程语言及 `grep` 或 `egrep` 的正则表达式匹配规则：

  > PCRE（Perl Compatible Regular Expressions 中文含义：perl 语言兼容正则表达式）是一个用 C 语言编写的正则表达式函数库，由菲利普。海泽 (Philip Hazel) 编写。PCRE 是一个轻量级的函数库，比 Boost 之类的正则表达式库小得多。PCRE 十分易用，同时功能也很强大，性能超过了 POSIX 正则表达式库和一些经典的正则表达式库。

  | 字符      | 描述                                                         |
  | --------- | ------------------------------------------------------------ |
  | \         | **将下一个字符标记为一个特殊字符、或一个原义字符。**例如，“n” 匹配字符 “n”。“\n” 匹配一个换行符。序列 “\\” 匹配 “\” 而 “\(” 则匹配 “(”。 |
  | ^         | **匹配输入字符串的开始位置。**                               |
  | $         | **匹配输入字符串的结束位置。**                               |
  | {n}       | n 是一个非负整数。**匹配确定的 n 次**。例如，“o {2}” 不能匹配 “Bob” 中的 “o”，但是能匹配 “food” 中的两个 o。 |
  | {n,}      | n 是一个非负整数。**至少匹配 n 次**。例如，“o {2,}” 不能匹配 “Bob” 中的 “o”，但能匹配 “foooood” 中的所有 o。“o {1,}” 等价于 “o+”。“o {0,}” 则等价于 “o*”。 |
  | {n,m}     | m 和 n 均为非负整数，其中 n<=m。**最少匹配 n 次且最多匹配 m 次。**例如，“o {1,3}” 将匹配 “fooooood” 中的前三个 o。“o {0,1}” 等价于 “o?”。请注意在逗号和两个数之间不能有空格。 |
  | *         | **匹配前面的子表达式零次或多次**。例如，zo * 能匹配 “z”、“zo” 以及 “zoo”。* 等价于 {0,}。 |
  | +         | **匹配前面的子表达式一次或多次**。例如，“zo+” 能匹配 “zo” 以及 “zoo”，但不能匹配 “z”。+ 等价于 {1,}。 |
  | ?         | **匹配前面的子表达式零次或一次**。例如，“do (es)?” 可以匹配 “do” 或 “does” 中的 “do”。? 等价于 {0,1}。 |
  | ?         | 当该字符紧跟在任何一个其他限制符（*,+,?，{n}，{n,}，{n,m}）后面时，匹配模式是非贪婪的。非贪婪模式尽可能少的匹配所搜索的字符串，而默认的贪婪模式则尽可能多的匹配所搜索的字符串。例如，对于字符串 “oooo”，“o+?” 将匹配单个 “o”，而 “o+” 将匹配所有 “o”。 |
  | .         | **匹配除 “\n” 之外的任何单个字符**。要匹配包括 “\n” 在内的任何字符，请使用像 “(.\|\n)” 的模式。 |
  | (pattern) | **匹配 pattern 并获取这一匹配的子字符串**。该子字符串用于向后引用。要匹配圆括号字符，请使用 “\(” 或 “\)”。 |
  | x\|y      | **匹配 x 或 y**。例如，“z\|food” 能匹配 “z” 或 “food”。“(z\|f) ood” 则匹配 “zood” 或 “food”。 |
  | [xyz]     | 字符集合（character class）。**匹配所包含的任意一个字符**。例如，“[abc]” 可以匹配 “plain” 中的 “a”。其中特殊字符仅有反斜线 \ 保持特殊含义，用于转义字符。其它特殊字符如星号、加号、各种括号等均作为普通字符。脱字符 ^ 如果出现在首位则表示负值字符集合；如果出现在字符串中间就仅作为普通字符。**连字符 -如果出现在字符串中间表示字符范围描述；如果出现在首位则仅作为普通字符。** |
  | [^xyz]    | 排除型（negate）字符集合。**匹配未列出的任意字符。**例如，`[^abc]`可以匹配 “plain” 中的 “plin”。 |
  | [a-z]     | 字符范围。**匹配指定范围内的任意字符。**例如，“[a-z]” 可以匹配 “a” 到 “z” 范围内的任意小写字母字符。 |
  | [^a-z]    | 排除型的字符范围。**匹配任何不在指定范围内的任意字符**。例如，`[^a-z]`”可以匹配任何不在 “a” 到 “z” 范围内的任意字符。 |

  #### 优先级

  优先级为从上到下从左到右，依次降低：

  | 运算符                    | 说明         |
  | ------------------------- | ------------ |
  | \                         | 转义符       |
  | (), (?:), (?=), []        | 括号和中括号 |
  | *、+、?、{n}、{n,}、{n,m} | 限定符       |
  | ^、$、\ 任何元字符        | 定位点和序列 |
  | \|                        | 选择         |

  更多正则表达式的内容可以参考以下链接：

  - [正则表达式 wiki](http://zh.wikipedia.org/wiki/%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F)
  - [几种正则表达式引擎的语法差异](http://www.greenend.org.uk/rjk/tech/regexp.html)
  - [各语言各平台对正则表达式的支持](http://en.wikipedia.org/wiki/Comparison_of_regular_expression_engines)

  regex 的思导图：

  ![img](https://doc.shiyanlou.com/linux_base/RegularExpression.png/wm)

### grep 模式匹配命令

- `grep` 命令用于打印输出文本中匹配的模式串，它使用正则表达式作为模式匹配的条件。`grep` 支持三种正则表达式引擎，分别用三个参数指定：

  | 参数 | 说明                      |
  | ---- | ------------------------- |
  | `-E` | POSIX 扩展正则表达式，ERE |
  | `-G` | POSIX 基本正则表达式，BRE |
  | `-P` | Perl 正则表达式，PCRE     |

  一般没学 perl 语言，只会用到 `ERE` 和 `BRE`, 所以不讨论 PCRE 中特有的一些正则表达式语法（它们之间大部分内容是存在交集的，所以你不用担心会遗漏多少重要内容）

  在通过 `grep` 命令使用正则表达式之前，先介绍一下它的常用参数：

  | 参数           | 说明                                                         |
  | -------------- | ------------------------------------------------------------ |
  | `-b`           | 将二进制文件作为文本来进行匹配                               |
  | `-c`           | 统计以模式匹配的数目                                         |
  | `-i`           | 忽略大小写                                                   |
  | `-n`           | 显示匹配文本所在行的行号                                     |
  | `-v`           | 反选，输出不匹配行的内容                                     |
  | `-r`           | 递归匹配查找                                                 |
  | `-A n`         | n 为正整数，表示 after 的意思，除了列出匹配行之外，还列出后面的 n 行 |
  | `-B n`         | n 为正整数，表示 before 的意思，除了列出匹配行之外，还列出前面的 n 行 |
  | `--color=auto` | 将输出中的匹配项设置为自动颜色显示                           |

  > 注：在大多数发行版中是默认设置了 grep 的颜色的，你可以通过参数指定或修改 `GREP_COLOR` 环境变量。

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0t3nytohhj30jy0hb778.jpg)

- #### 使用基本正则表达式，BRE

  - 位置

  查找 `/etc/group` 文件中以 "shiyanlou" 为开头的行

  ```
  $ grep 'shiyanlou' /etc/group
  $ grep '^shiyanlou' /etc/group
  ```

  - 数量

  ```
  # 将匹配以'z'开头以'o'结尾的所有字符串
  $ echo 'zero\nzo\nzoo' | grep 'z.*o'
  # 将匹配以'z'开头以'o'结尾，中间包含一个任意字符的字符串
  $ echo 'zero\nzo\nzoo' | grep 'z.o'
  # 将匹配以'z'开头,以任意多个'o'结尾的字符串
  $ echo 'zero\nzo\nzoo' | grep 'zo*'
  ```

  注意：其中 `\n` 为换行符

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0t46ow8w8j30k208bdhm.jpg)

  - 选择

  ```
  # grep默认是区分大小写的，这里将匹配所有的小写字母
  $ echo '1234\nabcd' | grep '[a-z]'
  # 将匹配所有的数字
  $ echo '1234\nabcd' | grep '[0-9]'
  # 将匹配所有的数字
  $ echo '1234\nabcd' | grep '[[:digit:]]'
  # 将匹配所有的小写字母
  $ echo '1234\nabcd' | grep '[[:lower:]]'
  # 将匹配所有的大写字母
  $ echo '1234\nabcd' | grep '[[:upper:]]'
  # 将匹配所有的字母和数字，包括0-9,a-z,A-Z
  $ echo '1234\nabcd' | grep '[[:alnum:]]'
  # 将匹配所有的字母
  $ echo '1234\nabcd' | grep '[[:alpha:]]'
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0t46zccpbj30jv0da0wb.jpg)

  下面包含完整的特殊符号及说明：

  | 特殊符号     | 说明                                                         |
  | ------------ | ------------------------------------------------------------ |
  | `[:alnum:]`  | 代表英文大小写字母及数字，亦即 0-9, A-Z, a-z                 |
  | `[:alpha:]`  | 代表任何英文大小写字母，亦即 A-Z, a-z                        |
  | `[:blank:]`  | 代表空白键与 [Tab] 按键两者                                  |
  | `[:cntrl:]`  | 代表键盘上面的控制按键，亦即包括 CR, LF, Tab, Del.. 等等     |
  | `[:digit:]`  | 代表数字而已，亦即 0-9                                       |
  | `[:graph:]`  | 除了空白字节 (空白键与 [Tab] 按键) 外的其他所有按键          |
  | `[:lower:]`  | 代表小写字母，亦即 a-z                                       |
  | `[:print:]`  | 代表任何可以被列印出来的字符                                 |
  | `[:punct:]`  | 代表标点符号 (punctuation symbol)，亦即：" ' ? ! ; : # $...  |
  | `[:upper:]`  | 代表大写字母，亦即 A-Z                                       |
  | `[:space:]`  | 任何会产生空白的字符，包括空白键，[Tab], CR 等等             |
  | `[:xdigit:]` | 代表 16 进位的数字类型，因此包括： 0-9, A-F, a-f 的数字与字节 |

  > **注意**：之所以要使用特殊符号，是因为上面的 [a-z] 不是在所有情况下都管用，这还与主机当前的语系有关，即设置在 `LANG` 环境变量的值，zh_CN.UTF-8 的话 [a-z]，即为所有小写字母，其它语系可能是大小写交替的如，"a A b B...z Z"，[a-z] 中就可能包含大写字母。所以在使用 [a-z] 时请确保当前语系的影响，使用 [:lower:] 则不会有这个问题。

  ```
  # 排除字符
  $ $ echo 'geek\ngood' | grep '[^o]'
  ```

  > **注意:** 当 `^` 放到中括号内为排除字符，否则表示行首。

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0t4l4fj0jj30jv05ymym.jpg)

- **使用扩展正则表达式，ERE**

  要通过 `grep` 使用扩展正则表达式需要加上 `-E` 参数，或使用 `egrep`。

  - 数量

  ```
  # 只匹配"zo"
  $ echo 'zero\nzo\nzoo' | grep -E 'zo{1}'
  # 匹配以"zo"开头的所有单词
  $ echo 'zero\nzo\nzoo' | grep -E 'zo{1,}'
  ```

  > **注意：**推荐掌握 `{n,m}` 即可，`+`,`?`,`*`，这几个不太直观，且容易弄混淆。

  - 选择

  ```
  # 匹配"www.shiyanlou.com"和"www.google.com"
  $ echo 'www.shiyanlou.com\nwww.baidu.com\nwww.google.com' | grep -E 'www\.(shiyanlou|google)\.com'
  # 或者匹配不包含"baidu"的内容
  $ echo 'www.shiyanlou.com\nwww.baidu.com\nwww.google.com' | grep -Ev 'www\.baidu\.com'
  ```

  > **注意：**因为`.` 号有特殊含义，所以需要转义。

  ![此处输入图片的描述](https://doc.shiyanlou.com/document-uid735639labid354timestamp1532415579510.png/wm)

### sed 流编辑器

- `sed` 工具在 man 手册里面的全名为 "sed - stream editor for filtering and transforming text "，意即，用于过滤和转换文本的流编辑器。

- 在 Linux/UNIX 的世界里敢称为编辑器的工具，大都非等闲之辈，比如前面的 "vi/vim (编辑器之神)","emacs (神的编辑器)","gedit" 这些个编辑器。`sed` 与上述的最大不同之处在于它是一个非交互式的编辑器，下面我们就开始介绍 `sed` 这个编辑器。

- sed 命令基本格式：

  ```
  sed [参数]... [执行命令] [输入文件]...
  # 形如：
  $ sed -i 's/sad/happy/' test # 表示将test文件中的"sad"替换为"happy"
  ```

  | 参数          | 说明                                                         |
  | ------------- | ------------------------------------------------------------ |
  | `-n`          | 安静模式，只打印受影响的行，默认打印输入数据的全部内容       |
  | `-e`          | 用于在脚本中添加多个执行命令一次执行，在命令行中执行多个命令通常不需要加该参数 |
  | `-f filename` | 指定执行 filename 文件中的命令                               |
  | `-r`          | 使用扩展正则表达式，默认为标准正则表达式                     |
  | `-i`          | 将直接修改输入文件内容，而不是打印到标准输出设备             |

- sed 执行命令格式：

  ```
  [n1][,n2]command
  [n1][~step]command
  # 其中一些命令可以在后面加上作用范围，形如：
  $ sed -i 's/sad/happy/g' test # g表示全局范围
  $ sed -i 's/sad/happy/4' test # 4表示指定行中的第四个匹配字符串
  ```

  其中 n1,n2 表示输入内容的行号，它们之间为 `,` 逗号则表示从 n1 到 n2 行，如果为`～`波浪号则表示从 n1 开始以 step 为步进的所有行；command 为执行动作，下面为一些常用动作指令：

  | 命令 | 说明                                 |
  | ---- | ------------------------------------ |
  | `s`  | 行内替换                             |
  | `c`  | 整行替换                             |
  | `a`  | 插入到指定行的后面                   |
  | `i`  | 插入到指定行的前面                   |
  | `p`  | 打印指定行，通常与 `-n` 参数配合使用 |
  | `d`  | 删除指定行                           |

- sed 操作举例

  我们先找一个用于练习的文本文件：

  ```
  $ cp /etc/passwd ~
  ```

  #### 打印指定行

  ```
  # 打印2-5行
  $ nl passwd | sed -n '2,5p'
  # 打印奇数行
  $ nl passwd | sed -n '1~2p'
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0t536sro0j30k10j2q9i.jpg)

  #### 行内替换

  ```
  # 将输入文本中"shiyanlou" 全局替换为"hehe",并只打印替换的那一行，注意这里不能省略最后的"p"命令
  $ sed -n 's/shiyanlou/hehe/gp' passwd
  ```

  > **注意：** 行内替换可以结合正则表达式使用。

  #### 行间替换

  ```
  $ nl passwd | grep "shiyanlou"
  # 删除第21行
  $ sed -n '21c\www.shiyanlou.com' passwd
  （这里我们只把要删的行打印出来了，并没有真正的删除，如果要删除的话，请使用-i参数）
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0t545sw3lj30h303o3yf.jpg)

  关于 sed 命令就介绍这么多，你如果希望了解更多 sed 的高级用法，你可以参看如下链接：

  - [sed 简明教程](http://coolshell.cn/articles/9104.html)
  - [sed 单行脚本快速参考](http://sed.sourceforge.net/sed1line_zh-CN.html)
  - [sed 完全手册](http://www.gnu.org/software/sed/manual/sed.html)

### awk 文本处理工具

- `AWK` 是一种优良的文本处理工具，Linux 及 Unix 环境中现有的功能最强大的数据处理引擎之一。其名称得自于它的创始人 Alfred Aho（阿尔佛雷德・艾侯）、Peter Jay Weinberger（彼得・温伯格）和 Brian Wilson Kernighan（布莱恩・柯林汉) 姓氏的首个字母.AWK 程序设计语言，三位创建者已将它正式定义为 “样式扫描和处理语言”。它允许您创建简短的程序，这些程序读取输入文件、为数据排序、处理数据、对输入执行计算以及生成报表，还有无数其他的功能。最简单地说，AWK 是一种用于处理文本的编程语言工具。

- 在大多数 linux 发行版上面，实际我们使用的是 gawk（GNU awk，awk 的 GNU 版本），在我们的环境中 ubuntu 上，默认提供的是 mawk，不过我们通常可以直接使用 awk 命令（awk 语言的解释器），因为系统已经为我们创建好了 awk 指向 mawk 的符号链接。

  ```
  $ ll /usr/bin/awk
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0t5gzhklnj30jt04omyl.jpg)

  > nawk： 在 20 世纪 80 年代中期，对 awk 语言进行了更新，并不同程度地使用一种称为 nawk (new awk) 的增强版本对其进行了替换。许多系统中仍然存在着旧的 awk 解释器，但通常将其安装为 oawk (old awk) 命令，而 nawk 解释器则安装为主要的 awk 命令，也可以使用 nawk 命令。Dr. Kernighan 仍然在对 nawk 进行维护，与 gawk 一样，它也是开放源代码的，并且可以免费获得； gawk： 是 GNU Project 的 awk 解释器的开放源代码实现。尽管早期的 GAWK 发行版是旧的 AWK 的替代程序，但不断地对其进行了更新，以包含 NAWK 的特性； mawk 也是 awk 编程语言的一种解释器，mawk 遵循 POSIX 1003.2 （草案 11.3）定义的 AWK 语言，包含了一些没有在 AWK 手册中提到的特色，同时 mawk 提供一小部分扩展，另外据说 mawk 是实现最快的 awk

- awk 所有的操作都是基于 pattern (模式)—action (动作) 对来完成的，如下面的形式：

  ```
  $ pattern {action}
  ```

  你可以看到就如同很多编程语言一样，它将所有的动作操作用一对 `{}` 花括号包围起来。其中 pattern 通常是表示用于匹配输入的文本的 “关系式” 或 “正则表达式”，action 则是表示匹配后将执行的动作。在一个完整 awk 操作中，这两者可以只有其中一个，如果没有 pattern 则默认匹配输入的全部文本，如果没有 action 则默认为打印匹配内容到屏幕。

  `awk` 处理文本的方式，是将文本分割成一些 “字段”，然后再对这些字段进行处理，默认情况下，awk 以空格作为一个字段的分割符，不过这不是固定的，你可以任意指定分隔符，下面将告诉你如何做到这一点。

- awk 命令基本格式

  ```
  awk [-F fs] [-v var=value] [-f prog-file | 'program text'] [file...]
  ```

  其中 `-F` 参数用于预先指定前面提到的字段分隔符（还有其他指定字段的方式） ，`-v` 用于预先为 `awk` 程序指定变量，`-f`参数用于指定 `awk` 命令要执行的程序文件，或者在不加 `-f`参数的情况下直接将程序语句放在这里，最后为 `awk` 需要处理的文本输入，且可以同时输入多个文本文件。现在我们还是直接来具体体验一下吧。

  先用 vim 新建一个文本文档

  ```
  $ vim test
  ```

  包含如下内容：

  ```
  I like linux
  www.shiyanlou.com
  ```

  - 使用 awk 将文本内容打印到终端

  ```
  # "quote>" 不用输入
  $ awk '{
  > print
  > }' test
  # 或者写到一行
  $ awk '{print}' test
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0t5t926x1j30k3076dhh.jpg)

  说明：在这个操作中我是省略了 `pattern`，所以 `awk` 会默认匹配输入文本的全部内容，然后在 "{}" 花括号中执行动作，即 `print` 打印所有匹配项，这里是全部文本内容

  - 将 test 的第一行的每个字段单独显示为一行

  ```
  $ awk '{
  > if(NR==1){
  > print $1 "\n" $2 "\n" $3
  > } else {
  > print}
  > }' test
  
  # 或者
  $ awk '{
  > if(NR==1){
  > OFS="\n"
  > print $1, $2, $3
  > } else {
  > print}
  > }' test
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0t5tgsenmj30jw08gmyt.jpg)

  说明：你首先应该注意的是，这里我使用了 `awk` 语言的分支选择语句 `if`, 它的使用和很多高级语言如 `C/C++` 语言基本一致，如果你有这些语言的基础，这里将很好理解。另一个你需要注意的是 `NR` 与 `OFS`，这两个是 `awk` 内建的变量，`NR` 表示当前读入的记录数，你可以简单的理解为当前处理的行数，`OFS` 表示输出时的字段分隔符，默认为 " " 空格，如上图所见，我们将字段分隔符设置为 `\n` 换行符，所以第一行原本以空格为字段分隔的内容就分别输出到单独一行了。然后是 `$N` 其中 N 为相应的字段号，这也是 `awk` 的内建变量，它表示引用相应的字段，因为我们这里第一行只有三个字段，所以只引用到了 `$3`。除此之外另一个这里没有出现的 `$0`，它表示引用当前记录（当前行）的全部内容。

  - 将 test 的第二行的以点为分段的字段换成以空格为分隔

  ```
  $ awk -F'.' '{
  > if(NR==2){
  > print $1 "\t" $2 "\t" $3
  > }}' test
  
  # 或者
  $ awk '
  > BEGIN{
  > FS="."
  > OFS="\t"  # 如果写为一行，两个动作语句之间应该以";"号分开  
  > }{
  > if(NR==2){
  > print $1, $2, $3
  > }}' test
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0t5v7nqk7j30k307utac.jpg)

  说明：这里的 `-F` 参数，前面已经介绍过，它是用来预先指定待处理记录的字段分隔符。我们需要注意的是除了指定 `OFS` 我们还可以在 `print` 语句中直接打印特殊符号如这里的 `\t`，**print 打印的非变量内容都需要用 "" 一对引号包围起来**。上面另一个版本，展示了实现预先指定变量分隔符的另一种方式，即使用 `BEGIN`，就这个表达式指示了，其后的动作将在所有动作之前执行，这里是 `FS` 赋值了新的 "." 点号代替默认的 " " 空格

  **注意**: 首先说明一点，我们在学习和使用 awk 的时候应该尽可能将其作为一门程序语言来理解，这样将会使你学习起来更容易，所以初学阶段在练习 `awk` 时应该尽量按照我那样的方式分多行按照一般程序语言的换行和缩进来输入，而不是全部写到一行（当然这在你熟练了之后是没有任何问题的）。

- awk 常用的内置变量

  | 变量名     | 说明                                                         |
  | ---------- | ------------------------------------------------------------ |
  | `FILENAME` | 当前输入文件名，若有多个文件，则只表示第一个。如果输入是来自标准输入，则为空字符串 |
  | `$0`       | 当前记录的内容                                               |
  | `$N`       | N 表示字段号，最大值为 `NF` 变量的值                         |
  | `FS`       | 字段分隔符，由正则表达式表示，默认为 " " 空格                |
  | `RS`       | 输入记录分隔符，默认为 "\n"，即一行为一个记录                |
  | `NF`       | 当前记录字段数                                               |
  | `NR`       | 已经读入的记录数                                             |
  | `FNR`      | 当前输入文件的记录数，请注意它与 NR 的区别                   |
  | `OFS`      | 输出字段分隔符，默认为 " " 空格                              |
  | `ORS`      | 输出记录分隔符，默认为 "\n"                                  |

  参看一下链接内容：

  - [awk 程序设计语言](http://awk.readthedocs.org/en/latest/chapter-one.html)
  - [awk 简明教程](http://coolshell.cn/articles/9070.html)
  - [awk 用户指南](http://www.gnu.org/software/gawk/manual/gawk.html)

### 挑战：数据提取

介绍

小明在做数据分析的时候需要提取文件中关于数字的部分，同时还要提取用户的邮箱部分，但是有的行不是数组也不是邮箱，现在需要你在 data2 这个文件中帮助他用正则表达式匹配出数字部分和邮箱部分。

数据文件可以使用以下命令下载：

```
$ cd /home/shiyanlou
$ wget http://labfile.oss.aliyuncs.com/courses/1/data2
```

下载后的数据文件路径为 `/home/shiyanlou/data2`。

目标

1. 在文件 `/home/shiyanlou/data2` 中匹配数字开头的行，将所有以数字开头的行都写入 `/home/shiyanlou/num` 文件。
2. 在文件 `/home/shiyanlou/data2` 中匹配出正确格式的邮箱，将所有的邮箱写入 `/home/shiyanlou/mail` 文件，注意该文件中每行为一个邮箱。

提示

1. 邮箱的格式匹配
2. 注意符号 `.` 的处理

来源：2016 年 TapFun 校招面试题

我的答案

```
shiyanlou:~/ $ cat data2 | grep '^[0-9]' > num
shiyanlou:~/ $ cat data2 | grep -E '@.{1,}\.com' > mail
shiyanlou:~/ $ cat data2 | grep -E '@.+\.com' > mail
```

​	思考：邮箱的匹配有点问题，`@`前一定要有东西，`.`hou的域名不一定非要是com

参考答案

```
grep '^[0-9]' /home/shiyanlou/data2 > /home/shiyanlou/num

grep -E '^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(.[a-zA-Z0-9_-]+)+$' /home/shiyanlou/data2 > /home/shiyanlou/mail
```

## 8、Linux 进程与任务管理

### 程序、进程、线程傻傻分不清楚？

- 程序（procedure）：文件中保存的一系列可执行的命令

- 进程（process）：进程是程序在一个数据集合上的一次执行过程

  >  在早期的 UNIX、Linux 2.4 及更早的版本中，它是系统进行资源分配和调度的独立基本单位。进程也可以看做加载到内存中的程序，由CPU执行，由PID 标识

- 线程（thread）：操作系统能够进行运算调度的最小单位

  > 当代多数操作系统、Linux 2.6 及更新的版本中，进程本身不是基本运行单位，而是线程的容器。每个进程可分为几个线程，线程需要的资源需要向上级（进程）申请。
  >
  > 线程它被包含在进程之中，是进程中的实际运作单位。一条线程指的是进程中一个单一顺序的控制流，一个进程中可以并发多个线程，每条线程并行执行不同的任务。因为线程中几乎不包含系统资源，所以执行更快、更有效率。

- 简而言之，一个程序至少有一个进程，一个进程至少有一个线程。线程的划分尺度小于进程，使得多线程程序的并发性高。另外，进程在执行过程中拥有独立的内存单元，而多个线程共享内存，从而极大地提高了程序的运行效率。就如下图所示：

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tdri17osj30sg0lcae8.jpg)

### 进程分类

可以从两个角度来分：

- 以进程的功能与服务的对象来分；
- 以应用程序的服务类型来分；

第一个角度来看，我们可以分为用户进程与系统进程：

- 用户进程：通过执行用户程序、应用程序或称之为内核之外的系统程序而产生的进程，此类进程可以在**用户的控制**下运行或关闭。
- 系统进程：通过执行系统**内核程序**而产生的进程，比如可以执行内存资源分配和进程切换等相对底层的工作；而且该进程的运行**不受用户的干预**，即使是 root 用户也不能干预系统进程的运行。

第二角度来看，我们可以将进程分为交互进程、批处理进程、守护进程

- 交互进程：由一个 shell 终端启动的进程，在执行过程中，需要与用户进行**交互操作**，可以运行于前台，也可以运行在后台。
- 批处理进程：该进程是一个**进程集合**，负责按顺序启动其他的进程。
- 守护进程：守护进程是**一直运行**的一种进程，在 Linux 系统启动时启动，在系统关闭时终止。它们独立于控制终端并且周期性的执行某种任务或等待处理某些发生的事件。例如 httpd 进程，一直处于运行状态，等待用户的访问。还有经常用的 cron（在 centOS 系列为 crond）进程，这个进程为 crontab 的守护进程，可以周期性的执行用户设定的某些任务。

### 进程的【衍生/产生/繁衍】与【消亡/消失/销毁】

- 进程有这么多的种类，那么进程之间定是有相关性的，而这些有关联性的进程又是如何产生的，如何衍生的？

  就比如我们启动了终端，就是启动了一个 bash 进程，我们可以在 bash 中再输入 bash 则会再启动一个 bash 的进程，此时第二个 bash 进程就是由第一个 bash 进程创建出来的，他们之间又是个什么关系？

  我们一般称呼第一个 bash 进程是第二 bash 进程的父进程，第二 bash 进程是第一个 bash 进程的子进程，这层关系是如何得来的呢？

  关于父进程与子进程便会提及这两个系统调用 `fork()` 与 `exec()`

  > **fork-exec** 是由 Dennis M. Ritchie 创造的

  > **fork()** 是一个系统调用（system call），它的主要作用就是为当前的进程创建一个新的进程，这个新的进程就是它的子进程，这个子进程除了父进程的返回值和 PID 以外其他的都一模一样，如进程的执行代码段，内存信息，文件描述，寄存器状态等等

  > **exec()** 也是系统调用，作用是切换子进程中的执行程序也就是替换其从父进程复制过来的代码段与数据段

  子进程就是父进程通过系统调用 `fork()` 而产生的复制品，`fork()` 就是把父进程的 PCB 等进程的数据结构信息直接复制过来，只是修改了 PID，所以一模一样，只有在执行 `exec()` 之后才会不同，而早先的 `fork()` 比较消耗资源后来进化成 `vfork()`, 效率高了不少，感兴趣的同学可以查查为什么。

  这就是子进程产生的由来。简单的实现逻辑就如下方所示

  ```
  pid_t p;
  
  p = fork();
  if (p == (pid_t) -1)
          /* ERROR */
  else if (p == 0)
          /* CHILD */
  else
          /* PARENT */
  ```

  既然子进程是通过父进程而衍生出来的，那么子进程的退出与资源的回收定然与父进程有很大的相关性。当一个子进程要正常的终止运行时，或者该进程结束时它的主函数 `main()`会执行 `exit(n);` 或者 `return n`，这里的返回值 n 是一个信号，系统会把这个 SIGCHLD 信号传给其父进程，当然若是异常终止也往往是因为这个信号。

- 僵尸进程

  在将要结束时的子进程代码执行部分已经结束执行了，系统的资源也基本归还给系统了。

  - 正常情况下，父进程会收到两个返回值：exit code（SIGCHLD 信号）与 `reason for termination` 。然后，父进程会使用 `wait(&status)` 系统调用以获取子进程的退出状态，于是内核就可以从内存中释放已结束的子进程的 PCB。

  - 但若是其进程的**进程控制块**（PCB）仍驻留在内存中，那么进程还算存在（因为 PCB 就是进程存在的唯一标志，里面有 PID 等消息），并没有消亡，这样的进程称之为**僵尸进程**（Zombie）。

  虽然僵尸进程是已经放弃了几乎所有内存空间，没有任何可执行代码，也不能被调度，在进程列表中保留一个位置，记载该进程的退出状态等信息供其父进程收集，从而释放它。但是 Linux 系统中能使用的 PID 是有限的，如果系统中存在有大量的僵尸进程，系统将会因为没有可用的 PID 从而导致不能产生新的进程。

- 孤儿进程

  另外如果父进程结束（非正常的结束），未能及时收回子进程，子进程仍在运行，这样的子进程称之为孤儿进程。在 Linux 系统中，孤儿进程一般会被 init 进程所 “收养”，成为 init 的子进程。由 init 来做善后处理，所以它并不至于像僵尸进程那样无人问津，不管不顾，大量存在会有危害。

- 开天辟地的守护进程——进程0

  进程 0 是系统引导时创建的一个特殊进程，也称之为内核初始化，其最后一个动作就是调用 `fork()` 创建出一个子进程运行 `/sbin/init` 可执行文件，而该进程就是 PID=1 的进程 1，而进程 0 就转为交换进程（也被称为空闲进程），进程 1 （init 进程）是第一个用户态的进程，再由它不断调用 `fork ()` 来创建系统里其他的进程，所以它是所有进程的父进程或者祖先进程。同时它是一个守护程序，直到计算机关机才会停止。

  通过以下的命令我们可以很明显的看到这样的结构

  ```
  pstree
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tefapnpsj30s60kyjsy.jpg)

- 用户进程的祖先——进程1（init 进程）

  我们还可以使用这样一个命令来看，其中 pid 就是该进程的一个唯一编号，ppid 就是该进程的父进程的 pid，command 表示的是该进程通过执行什么样的命令或者脚本而产生的

  ```
  ps －fxo user,ppid,pid,pgid,command
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tegau73vj30s60kyjw0.jpg)

  可以在图中看见我们执行的 ps 就是由 zsh 通过 fork-exec 创建的子进程而执行的。 init进程是由进程 0 这个初始化进程来创建出来的子进程，而其他的进程基本是由 init 创建的子进程，或者是由它的子进程创建出来的子进程。所以 init 是用户进程的第一个进程也是所有用户进程的**父进程**或者**祖先进程**。这就像一个树状图，而 init 进程就是这棵树的根，其他进程由根不断的发散，开枝散叶

### 进程组与 Sessions

- 每一个进程都会是一个进程组的成员，而且这个进程组是唯一存在的，他们是依靠 PGID（process group ID）来区别的，而每当一个进程被创建的时候，它便会成为其父进程所在组中的一员。

- 一般情况，进程组的 PGID 等同于进程组的第一个成员的 PID，并且这样的进程称为该进程组的领导者，也就是**领导进程**，进程一般通过使用 `getpgrp()` 系统调用来寻找其所在组的 PGID，领导进程可以先终结，此时进程组依然存在，并持有相同的 PGID，直到进程组中最后一个进程终结。

- 与进程组类似，每当一个进程被创建的时候，它便会成为其父进程所在 Session 中的一员，每一个进程组都会在一个 Session 中，并且这个 Session 是唯一存在的。

- Session 主要是针对一个 tty 建立，Session 中的每个进程都称为一个工作 (job)。每个会话可以连接一个终端 (control terminal)。当控制终端有输入输出时，都传递给该会话的前台进程组。Session 意义在于将多个 jobs 囊括在一个终端，并取其中的一个 job 作为前台，来直接接收该终端的输入输出以及终端信号。 其他 jobs 在后台运行。

  > **前台**（foreground）就是在终端中运行，能与你有交互的

  > **后台**（background）就是在终端中运行，但是你并不能与其任何的交互，也不会显示其执行的过程

### 工作管理

- bash (Bourne-Again shell) 支持工作控制（job control）, 而 sh（Bourne shell）并不支持。

  并且每个终端或者说 bash 只能管理当前终端中的 job，不能管理其他终端中的 job。比如我当前存在两个 bash 分别为 bash1、bash2，bash1 只能管理其自己里面的 job 并不能管理 bash2 里面的 job

  我们都知道当一个进程在前台运作时我们可以用 `ctrl + c`来终止它，但是若是在后台的话就不行了。

  我们可以通过 `&` 这个符号，让我们的命令在后台中运行

  ```
  shiyanlou:~/ $ ls &                                   
  [2] 6650
  anaconda3  Code  Desktop  emacs24_24.5+1-6ubuntu1.1_amd64.deb                   
  [2]  + 6650 done       ls --color=tty
  shiyanlou:~/ $
  ```

  

  图中所显示的 `[2] 6650` 分别是该 job 的 job number 与该进程的 PID，而最后一行的 Done 表示该命令已经在后台执行完毕。

  我们还可以通过 `ctrl + z` 使我们的当前工作停止并丢到后台中去

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tey5vg4fj30s60kygm9.jpg)

  被停止并放置在后台的工作我们可以使用这个命令来查看

  ```
  jobs
  ```

  ![实验楼](https://dn-simplecloud.shiyanlou.com/1135081469037134869-wm)

  其中第一列显示的为被放置后台 job 的编号，而第二列的 `＋`表示最近被放置后台的 job，同时也表示**预设工作**，也就是若是有什么针对后台 job 的操作，首先对预设的 job，`-` 表示倒数第二（也就是在预设之前的一个）被放置后台的工作，倒数第三个（再之前的）以后都不会有这样的符号修饰，第三列表示它们的状态，而最后一列表示该进程执行的命令

  我们可以通过这样的一个命令将后台的工作拿到前台来:

  ```
  #后面不加参数提取预设工作，加参数提取指定工作的编号
  #ubuntu 在 zsh 中需要 %，在 bash 中不需要 %
  fg [%jobnumber]
  ```

  ![实验楼](https://dn-simplecloud.shiyanlou.com/1135081469037555070-wm)

  之前我们通过 `ctrl + z` 使得工作停止放置在后台，若是我们想让其在后台运作我们就使用这样一个命令

  ```
  #与fg类似，加参数则指定，不加参则取预设工作
  bg [%jobnumber]
  ```

  ![实验楼](https://dn-simplecloud.shiyanlou.com/1135081469037983282-wm)

  既然有方法将被放置在后台的工作提至前台或者让它从停止变成继续运行在后台，当然也有方法删除一个工作，或者重启等等

  ```
  #kill的使用格式如下
  kill -signal %jobnumber
  
  #signal从1-64个信号值可以选择，可以这样查看
  kill －l
  ```

  其中常用的有这些信号值

  | 信号值 | 作用                             |
  | ------ | -------------------------------- |
  | -1     | 重新读取参数运行，类似与 restart |
  | -2     | 如同 ctrl+c 的操作退出           |
  | -9     | 强制终止该任务                   |
  | -15    | 正常的方式终止该任务             |

  ![实验楼](https://dn-simplecloud.shiyanlou.com/1135081469038840624-wm)

  > **注意**

  > 若是在使用 kill＋信号值然后直接加 pid，你将会对 pid 对应的进程进行操作

  > 若是在使用 kill + 信号值然后 `％jobnumber`，这时所操作的对象是 job，这个数字就是就当前 bash 中后台的运行的 job 的 ID

### **查看进程**——ps、top、pstree

- ps 命令，静态查看当前进程信息（snapchat）

  使用 `-l` 参数可以显示自己**这次登陆的 bash** 相关的进程信息罗列出来

  ```
  shiyanlou:~/ $ ps -l                                 
  F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
  0 S  5000   148   142  0  80   0 - 12056 sigsus pts/0    00:00:01 zsh
  0 R  5000  6850   148  0  80   0 -  7514 -      pts/0    00:00:00 ps
  
  ```

  相对来说，罗列出**所有的**进程信息更常用

  ```
  ps aux
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tfy0qx3ij30s60ky440.jpg)

  若是查找其中的某个进程的话，我们还可以配合着 grep 和正则表达式一起使用

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tg18s2qbj30s60ky0tu.jpg)

  此外我们还可以查看时，将连同部分的进程呈树状显示出来

  ```
  ps axjf
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tfyuqe5gj30s60kyn1e.jpg)

  当然如果你觉得使用这样的此时没有把你想要的信息放在一起，我们也可以是用这样的命令，来自定义我们所需要的参数显示

  ```
  ps -afxo user,ppid,pid,pgid,command
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tfz89f97j30s60kyjw0.jpg)

  打印出来的信息各个字段的意义参考下表

  | 内容      | 解释                                                         |
  | --------- | ------------------------------------------------------------ |
  | F         | 进程的标志（process flags），当 flags 值为 1 则表示此子程序只是 fork 但没有执行 exec，为 4 表示此程序使用超级管理员 root 权限 |
  | USER      | 进程的拥有用户                                               |
  | PID       | 进程的 ID                                                    |
  | PPID      | 其父进程的 PID                                               |
  | SID       | session 的 ID                                                |
  | TPGID     | 前台进程组的 ID                                              |
  | %CPU      | 进程占用的 CPU 百分比                                        |
  | %MEM      | 占用内存的百分比                                             |
  | NI        | 进程的 NICE 值                                               |
  | VSZ       | 进程使用虚拟内存大小                                         |
  | RSS       | 驻留内存中页的大小                                           |
  | TTY       | 终端 ID                                                      |
  | S or STAT | 进程状态                                                     |
  | WCHAN     | 正在等待的进程资源                                           |
  | START     | 启动进程的时间                                               |
  | TIME      | 进程消耗 CPU 的时间                                          |
  | COMMAND   | 命令的名称和参数                                             |

  > **TPGID** 栏写着 - 1 的都是没有控制终端的进程，也就是守护进程

  **STAT** 表示进程的状态，而进程的状态有很多，如下表所示

  | 状态 | 解释                                |
  | ---- | ----------------------------------- |
  | R    | Running. 运行中                     |
  | S    | Interruptible Sleep. 等待调用       |
  | D    | Uninterruptible Sleep. 不可中断睡眠 |
  | T    | Stoped. 暂停或者跟踪状态            |
  | X    | Dead. 即将被撤销                    |
  | Z    | Zombie. 僵尸进程                    |
  | W    | Paging. 内存交换                    |
  | N    | 优先级低的进程                      |
  | <    | 优先级高的进程                      |
  | s    | 进程的领导者                        |
  | L    | 锁定状态                            |
  | l    | 多线程状态                          |
  | +    | 前台进程                            |

  > 其中的 D 是不能被中断睡眠的状态，处在这种状态的进程不接受外来的任何 signal，所以无法使用 kill 命令杀掉处于 D 状态的进程，无论是 `kill`，`kill -9` 还是 `kill -15`，一般处于这种状态可能是进程 I/O 的时候出问题了。

- top 命令，动态观察进程动态，每三秒刷新一次（默认按CPU的使用率降序排列）

  `top` 工具是我们常用的一个查看工具，能实时的查看我们系统的一些关键信息的变化:

  ```
  top
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tf66ln78j30s60kyjvv.jpg)

  top 是一个在**前台**执行的程序，所以执行后便进入到这样的一个**交互界面**，正是因为交互界面我们才可以实时的获取到系统与进程的信息。在交互界面中我们可以通过一些指令来操作和筛选。在此之前我们先来了解显示了哪些信息。

  我们看到 top 显示的第一排，

  | 内容                         | 解释                                    |
  | ---------------------------- | --------------------------------------- |
  | top                          | 表示当前程序的名称                      |
  | 11:05:18                     | 表示当前的系统的时间                    |
  | up 8 days,17:12              | 表示该机器已经启动了多长时间            |
  | 1 user                       | 表示当前系统中只有一个用户              |
  | load average: 0.29,0.20,0.25 | 分别对应 1、5、15 分钟内 cpu 的平均负载 |

  load average 在 wikipedia 中的解释是 the system load is a measure of the amount of work that a computer system is doing 也就是对当前 CPU 工作量的度量，具体来说也就是指运行队列的平均长度，也就是等待 CPU 的平均进程数相关的一个计算值。

  我们该如何看待这个 load average 数据呢？

  假设我们的系统是单 CPU、单内核的，把它比喻成是一条单向的桥，把 CPU 任务比作汽车。

  - load = 0 的时候意味着这个桥上并没有车，cpu 没有任何任务；
  - load < 1 的时候意味着桥上的车并不多，一切都还是很流畅的，cpu 的任务并不多，资源还很充足；
  - load = 1 的时候就意味着桥已经被车给占满了，没有一点空隙，cpu 的已经在全力工作了，所有的资源都被用完了，当然还好，这还在能力范围之内，只是有点慢而已；
  - load > 1 的时候就意味着不仅仅是桥上已经被车占满了，就连桥外都被占满了，cpu 已经在全力工作，系统资源的用完了，但是还是有大量的进程在请求，在等待。若是这个值大于２、大于３，表示进程请求超过 CPU 工作能力的 2 到 ３ 倍。而若是这个值 > 5 说明系统已经在超负荷运作了。

  这是单个 CPU 单核的情况，而实际生活中我们需要将得到的这个值除以我们的核数来看。我们可以通过以下的命令来查看 CPU 的个数与核心数

  ```
  #查看物理CPU的个数
  #cat /proc/cpuinfo |grep "physical id"|sort |uniq|wc -l
  
  #每个cpu的核心数
  cat /proc/cpuinfo |grep "physical id"|grep "0"|wc -l
  ```

  通过上面的指数我们可以得知 load 的临界值为 1 ，但是在实际生活中，比较有经验的运维或者系统管理员会将临界值定为 0.7。这里的指数都是除以核心数以后的值，不要混淆了

  - 若是 load < 0.7 并不会去关注他；
  - 若是 0.7< load < 1 的时候我们就需要稍微关注一下了，虽然还可以应付但是这个值已经离临界不远了；
  - 若是 load = 1 的时候我们就需要警惕了，因为这个时候已经没有更多的资源的了，已经在全力以赴了；
  - 若是 load > 5 的时候系统已经快不行了，这个时候你需要加班解决问题了

  通常我们都会先看 15 分钟的值来看这个大体的趋势，然后再看 5 分钟的值对比来看是否有下降的趋势。

  查看 busybox 的代码可以知道，数据是每 5 秒钟就检查一次活跃的进程数，然后计算出该值，然后 load 从 `/proc/loadavg` 中读取的。而这个 load 的值是如何计算的呢，这是 load 的计算的源码

  ```
  #define FSHIFT      11          /* nr of bits of precision */
  #define FIXED_1     (1<<FSHIFT) /* 1.0 as fixed-point(定点) */
  #define LOAD_FREQ   (5*HZ)      /* 5 sec intervals，每隔5秒计算一次平均负载值 */
  #define CALC_LOAD(load, exp, n)     \
           load *= exp;               \
           load += n*(FIXED_1 - exp); \
           load >>= FSHIFT;
  
  unsigned long avenrun[3];
  
  EXPORT_SYMBOL(avenrun);
  
  /*
  * calc_load - given tick count, update the avenrun load estimates.
  * This is called while holding a write_lock on xtime_lock.
  */
  static inline void calc_load(unsigned long ticks)
  {
          unsigned long active_tasks; /* fixed-point */
          static int count = LOAD_FREQ;
          count -= ticks;
          if (count < 0) {
                  count += LOAD_FREQ;
                  active_tasks = count_active_tasks();
                  CALC_LOAD(avenrun[0], EXP_1, active_tasks);
                  CALC_LOAD(avenrun[1], EXP_5, active_tasks);
                  CALC_LOAD(avenrun[2], EXP_15, active_tasks);
          }
  }
  ```

  > 有兴趣的朋友可以研究一下，是如何计算的。代码中的后面这部分相当于它的计算公式

  我们回归正题，来看 top 的第二行数据，基本上第二行是进程的一个情况统计

  | 内容            | 解释                 |
  | --------------- | -------------------- |
  | Tasks: 26 total | 进程总数             |
  | 1 running       | 1 个正在运行的进程数 |
  | 25 sleeping     | 25 个睡眠的进程数    |
  | 0 stopped       | 没有停止的进程数     |
  | 0 zombie        | 没有僵尸进程数       |

  来看 top 的第三行数据，这一行基本上是 CPU 的一个使用情况的统计了

  | 内容           | 解释                                                         |
  | -------------- | ------------------------------------------------------------ |
  | Cpu(s): 1.0%us | 用户空间进程占用 CPU 百分比                                  |
  | 1.0% sy        | 内核空间运行占用 CPU 百分比                                  |
  | 0.0%ni         | 用户进程空间内改变过优先级的进程占用 CPU 百分比              |
  | 97.9%id        | 空闲 CPU 百分比                                              |
  | 0.0%wa         | 等待输入输出的 CPU 时间百分比                                |
  | 0.1%hi         | 硬中断 (Hardware IRQ) 占用 CPU 的百分比                      |
  | 0.0%si         | 软中断 (Software IRQ) 占用 CPU 的百分比                      |
  | 0.0%st         | (Steal time) 是 hypervisor 等虚拟服务中，虚拟 CPU 等待实际 CPU 的时间的百分比 |

  CPU 利用率是对一个时间段内 CPU 使用状况的统计，通过这个指标可以看出在某一个时间段内 CPU 被占用的情况，而 Load Average 是 CPU 的 Load，它所包含的信息不是 CPU 的使用率状况，而是在一段时间内 CPU 正在处理以及等待 CPU 处理的进程数情况统计信息，这两个指标并不一样。

  来看 top 的第四行数据，这一行基本上是内存的一个使用情况的统计了：

  | 内容           | 解释                 |
  | -------------- | -------------------- |
  | 8176740 total  | 物理内存总量         |
  | 8032104 used   | 使用的物理内存总量   |
  | 144636 free    | 空闲内存总量         |
  | 313088 buffers | 用作内核缓存的内存量 |

  > **注意**

  > 系统中可用的物理内存最大值并不是 free 这个单一的值，而是 free + buffers + swap 中的 cached 的和

  来看 top 的第五行数据，这一行基本上是交换区的一个使用情况的统计了

  | 内容   | 解释                                                         |
  | ------ | ------------------------------------------------------------ |
  | total  | 交换区总量                                                   |
  | used   | 使用的交换区总量                                             |
  | free   | 空闲交换区总量                                               |
  | cached | 缓冲的交换区总量，内存中的内容被换出到交换区，而后又被换入到内存，但使用过的交换区尚未被覆盖 |

  再下面就是进程的一个情况了

  | 列名    | 解释                                         |
  | ------- | -------------------------------------------- |
  | PID     | 进程 id                                      |
  | USER    | 该进程的所属用户                             |
  | PR      | 该进程执行的优先级 priority 值               |
  | NI      | 该进程的 nice 值                             |
  | VIRT    | 该进程任务所使用的虚拟内存的总数             |
  | RES     | 该进程所使用的物理内存数，也称之为驻留内存数 |
  | SHR     | 该进程共享内存的大小                         |
  | S       | 该进程进程的状态: S=sleep R=running Z=zombie |
  | %CPU    | 该进程 CPU 的利用率                          |
  | %MEM    | 该进程内存的利用率                           |
  | TIME+   | 该进程活跃的总时间                           |
  | COMMAND | 该进程运行的名字                             |

  > **注意**

  > **NICE 值**叫做静态优先级，是用户空间的一个优先级值，其取值范围是 - 20 至 19。这个值越小，表示进程” 优先级” 越高，而值越大 “优先级” 越低。nice 值中的 -20 到 19，中 -20 优先级最高， 0 是默认的值，而 19 优先级最低

  > **PR 值**表示 Priority 值叫动态优先级，是进程在内核中实际的优先级值，进程优先级的取值范围是通过一个宏定义的，这个宏的名称是 MAX_PRIO，它的值为 140。Linux 实际上实现了 140 个优先级范围，取值范围是从 0-139，这个值越小，优先级越高。而这其中的 0 - 99 是实时进程的值，而 100 - 139 是给用户的。

  > 其中 PR 中的 100 to 139 值部分有这么一个对应 `PR = 20 + (-20 to +19)`，这里的 -20 to +19 便是 nice 值，所以说两个虽然都是优先级，而且有千丝万缕的关系，但是他们的值，他们的作用范围并不相同

  > ** VIRT ** 任务所使用的虚拟内存的总数，其中包含所有的代码，数据，共享库和被换出 swap 空间的页面等所占据空间的总数

  在上文我们曾经说过 top 是一个前台程序，所以是一个可以交互的

  | 常用交互命令 | 解释                                                         |
  | ------------ | ------------------------------------------------------------ |
  | q            | 退出程序                                                     |
  | I            | 切换显示平均负载和启动时间的信息                             |
  | P            | 根据 CPU 使用百分比大小进行排序                              |
  | M            | 根据驻留内存大小进行排序                                     |
  | i            | 忽略闲置和僵死的进程，这是一个开关式命令                     |
  | k            | 终止一个进程，系统提示输入 PID 及发送的信号值。一般终止进程用 15 信号，不能正常结束则使用 9 信号。安全模式下该命令被屏蔽。 |

  好好的利用 top 能够很有效的帮助我们观察到系统的瓶颈所在，或者是系统的问题所在。

  

- pstree 命令，查看当前活跃进程的树形结构，用ASCII字符显示树状结构

  通过 pstree 可以很直接的看到相同的进程数量，最主要的还是我们可以看到所有进程之间的相关性

  ```
  pstree
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tg2v9xehj30s60ky409.jpg)

  ```
  pstree -up
  
  #参数选择：
  #-A  ：各程序树之间以 ASCII 字元來連接；
  #-p  ：同时列出每个 process 的 PID；
  #-u  ：同时列出每个 process 的所属用户名称。
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tg2yh6esj30s60kyjv2.jpg)

### 管理进程

- kill 命令，杀死 job or process

  我们来回顾一下，当一个进程结束的时候或者要异常结束的时候，会向其父进程返回一个或者接收一个 SIGHUP 信号而做出的结束进程或者其他的操作，这个 SIGHUP 信号不仅可以由系统发送，我们可以使用 kill 来发送这个信号来操作进程的结束或者重启等等。

  - kill PID：结束进程和进程号PID，系统可能不响应
  - kill -9 PID：强制终止进程，一般不适用
  - killall PID：终止同一进程组内的所有进程



- 进程的执行顺序

  Linux进程调度是CPU分为时间片，每个进程将依次在CPU上运行，优先级高的先执行，通过PR与nice值来修改优先级

  用户可通过设置进程的 niceness(NI）值来影响进程的优先级。niceness值范围：-20到+19，数字越小，优先级越高

  root用户（超级用户）可调整优先级到-20，而非超级用户只能把进程的优先级调低（即往+19调整），常规用户所启用的进程的niceness默认值为0

  用法：

  - nice -n 1 ls：将 ls 的优先序加 1 并执行
  - nice ls：将 ls 的优先序加 10 并执行
  - renice +1 987 -u daemon root -p 32：将进程 id 为 987 及 32 的进程与进程拥有者为 daemon 及 root 的优先序号码加 1

## 9、Linux 日志系统

### 为什么日志重要？

- 日志数据可以是有价值的信息宝库，也可以是毫无价值的数据泥潭。它可以记录下系统产生的所有行为，并按照某种规范表达出来。我们可以使用日志系统所记录的信息为系统进行排错，优化系统的性能，或者根据这些信息调整系统的行为。收集你想要的数据，分析出有价值的信息，可以提高系统、产品的安全性，还可以帮助开发完善代码，优化产品。日志会成为在事故发生后查明 “发生了什么” 的一个很好的 “取证” 信息来源。日志可以为审计进行审计跟踪。
- 日志是一个系统管理员，一个运维人员，甚至是开发人员不可或缺的东西，系统用久了偶尔也会出现一些错误，我们需要日志来给系统排错，在一些网络应用服务不能正常工作的时候，我们需要用日志来做问题定位，日志还是过往时间的记录本，我们可以通过它知道我们是否被不明用户登录过等等。

### 常见的日志

- 在 Linux 中大部分的发行版都内置使用 syslog 系统日志，那么通过前期的课程我们了解到常见的日志一般存放在 `/var/log` 中，我们来看看其中有哪些日志

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tgq7g5lfj30s60ky78h.jpg)

  根据图中所显示的日志，我们可以根据服务对象粗略的将日志分为两类

  - 系统日志
  - 应用日志

  系统日志主要是存放系统内置程序或系统内核之类的日志信息如 `alternatives.log` 、`btmp` 等等，应用日志主要是我们装的第三方应用所产生的日志如 `tomcat7` 、`apache2` 等等。

  接下来我们来看看常见的系统日志有哪些，他们都记录了怎样的信息

  | 日志名称           | 记录信息                                                     |
  | ------------------ | ------------------------------------------------------------ |
  | alternatives.log   | 系统的一些更新替代信息记录                                   |
  | apport.log         | 应用程序崩溃信息记录                                         |
  | apt/history.log    | 使用 apt-get 安装卸载软件的信息记录                          |
  | apt/term.log       | 使用 apt-get 时的具体操作，如 package 的下载、打开等         |
  | auth.log           | 登录认证的信息记录                                           |
  | boot.log           | 系统启动时的程序服务的日志信息                               |
  | btmp               | 错误的信息记录                                               |
  | Consolekit/history | 控制台的信息记录                                             |
  | dist-upgrade       | dist-upgrade 这种更新方式的信息记录                          |
  | dmesg              | 启动时，显示屏幕上内核缓冲信息，与硬件有关的信息             |
  | dpkg.log           | dpkg 命令管理包的日志。                                      |
  | faillog            | 用户登录失败详细信息记录                                     |
  | fontconfig.log     | 与字体配置有关的信息记录                                     |
  | kern.log           | 内核产生的信息记录，在自己修改内核时有很大帮助               |
  | lastlog            | 用户的最近信息记录                                           |
  | wtmp               | 登录信息的记录。wtmp 可以找出谁正在进入系统，谁使用命令显示这个文件或信息等 |
  | syslog             | 系统信息记录                                                 |

  而在本实验环境中没有 apport.log 是因为 apport 这个应用程序需要读取一些内核的信息来收集判断其他应用程序的信息，从而记录应用程序的崩溃信息。而在本实验环境中我们没有这个权限，所以将 apport 从内置应用值剔除，自然而然就没有它的日志信息了。

- 只闻其名，不见其人，我们并不能明白这些日志记录的内容。首先我们来看 `alternatives.log` 中的信息，在本实验环境中没有任何日志输出是因为刚刚启动的系统中并没有任何的更新迭代。我可以看看从其他地方截取过来的内容

  ```
  update-alternatives 2016-07-02 13:36:16: run with --install /usr/bin/x-www-browser x-www-browser /usr/bin/google-chrome-stable 200
  update-alternatives 2016-07-02 13:36:16: run with --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/google-chrome-stable 200
  update-alternatives 2016-07-02 13:36:16: run with --install /usr/bin/google-chrome google-chrome /usr/bin/google-chrome-stable 200
  ```

  我们可以从中得到的信息有程序作用，日期，命令，成功与否的返回码

  我们用这样的命令来看看 `auth.log` 中的信息

  ```
  less auth.log
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tgqf6rn2j30sg0lcn1e.jpg)

  我们可以从中得到的信息有日期与 ip 地址的来源以及的用户与工具

- 在 apt 文件夹中的日志信息，其中有两个日志文件 `history.log` 与 `term.log`，两个日志文件的区别在于 `history.log`主要记录了进行了哪个操作，相关的依赖有哪些，而 `term.log` 则是较为具体的一些操作，主要就是下载包，打开包，安装包等等的细节操作。

  我们通过这样的例子就可以很明显的看出区别，在本实验环境中因为是刚启动的环境，所以两个日志中的信息都是空的

  ```
  less /var/log/apt/history.log
  
  less /var/log/apt/term.log
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tgql8mkkj30sg0lc75a.jpg)

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tgqz5wk8j30sg0lcab2.jpg)

  然后我们来安装 git 这个程序，因为本实验环境中本有预装 git ，所以这里真正执行的操作是一个更新的操作，但这并不影响

  ```
  sudo apt-get install git
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tgr5vae7j30sg0lcten.jpg)

  成功的执行之后我们再来查看两个日志的内容变化

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tgrr3f7cj30sg0lcdh8.jpg)

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tgrycp9vj30sg0lcacv.jpg)

  其他的日志格式也都类似于之前我们所查看的日志，主要便是时间，操作。

- 但要注意有两个比较特殊的日志，其查看的方式比较与众不同，因为这两个日志并不是 ASCII 文件而是被编码成了二进制文件，所以我们并不能直接使用 less、cat、more 这样的工具来查看，这两个日志文件是 wtmp，lastlog

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tgs85nx5j30sg0lcn0d.jpg)

  我们查看的方法是使用 last 与 lastlog 工具来提取其中的信息

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tgsf5cetj30sg0lcwhu.jpg)

### 配置的日志

- 这些日志是如何产生的？通过上面的例子我们可以看出大部分的日志信息似乎格式都很类似，并且都出现在这个文件夹中。

  这样的实现可以通过两种方式：

  - 一种是由软件开发商自己来自定义日志格式然后指定输出日志位置；
  - 一种方式就是 Linux 提供的日志服务程序，而我们这里系统日志是通过 syslog 来实现，提供日志管理服务。

- syslog 是一个系统日志记录程序，在早期的大部分 Linux 发行版都是内置 syslog，让其作为系统的默认日志收集工具，虽然随着时代的进步与发展，syslog 已经年老体衰跟不上时代的需求，所以他被 rsyslog 所代替了，较新的 Ubuntu、Fedora 等等都是默认使用 rsyslog 作为系统的日志收集工具

  rsyslog 的全称是 rocket-fast system for log，它提供了高性能，高安全功能和模块化设计。rsyslog 能够接受各种各样的来源，将其输入，输出的结果到不同的目的地。rsyslog 可以提供超过每秒一百万条消息给目标文件。

  这样能实时收集日志信息的程序是有其守护进程的，如 rsyslog 的守护进程便是 rsyslogd。

  我们可以手动开启这项服务，然后来查看

  ```
  sudo apt-get update
  sudo apt-get install -y rsyslog
  sudo service rsyslog start
  ps aux | grep syslog
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tgx063mlj30sg0lcjtu.jpg)

  既然它是一个服务，那么它便是可以配置，首先我们来看 rsyslog 的配置文件是什么样子的，而 rsyslog 的配置文件有两个，

  - 一个是 `/etc/rsyslog.conf`
  - 一个是 `/etc/rsyslog.d/50-default.conf`。

  第一个主要是配置的环境，也就是 rsyslog 加载什么模块，文件的所属者等；而第二个主要是配置的 Filter Conditions

  ```
  vim /etc/rsyslog.conf 
  
  vim /etc/rsyslog.d/50-default.conf
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tgxi4wuej30sg0lcdj3.jpg)

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tgxlezavj30s60kydi4.jpg)

  看上去有点复杂，我们还是来看看 rsyslog 的结构框架

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tgyqwww1j30sg0lcwf3.jpg)

  （图片来源于 <http://www.rsyslog.com/doc/queues_analogy.html>）

  Rsyslog 架构如图中所示，从图中我们可以很清楚的看见，rsyslog 还有一个核心的功能模块便是 Queue，也正是因为它才能做到如此高的并发。

  第一个模块便是 Input，该模块的主要功能就是从各种各样的来源收集 messages，通过这些接口实现：

  | 接口名    | 作用                                              |
  | --------- | ------------------------------------------------- |
  | im3195    | RFC3195 Input Module                              |
  | imfile    | Text File Input Module                            |
  | imgssapi  | GSSAPI Syslog Input Module                        |
  | imjournal | Systemd Journal Input Module                      |
  | imklog    | Kernel Log Input Module                           |
  | imkmsg    | /dev/kmsg Log Input Module                        |
  | impstats  | Generate Periodic Statistics of Internal Counters |
  | imptcp    | Plain TCP Syslog                                  |
  | imrelp    | RELP Input Module                                 |
  | imsolaris | Solaris Input Module                              |
  | imtcp     | TCP Syslog Input Module                           |
  | imudp     | UDP Syslog Input Module                           |
  | imuxsock  | Unix Socket Input                                 |

  而 Output 中也有许多可用的接口，可以通过 man 或者官方的文档查看

- 这些模块接口的使用需要通过 $ModLoad 指令来加载，那么返回上文的图中，配置生效的头两行可以看懂了，默认加载了 imklog、imuxsock 这两个模块。

  在配置中 rsyslog 支持三种配置语法格式：

  - sysklogd
  - legacy rsyslog
  - **RainerScript**

  sysklogd 是老的简单格式，一些新的语法特性不支持。而 legacy rsyslog 是以 dollar 符 (`$`) 开头的语法，在 v6 及以上的版本还在支持，就如上文所说的 `​$ModLoad` 还有一些插件和特性只在此语法下支持。而以 `$` 开头的指令是全局指令，全局指令是 rsyslogd 守护进程的配置指令，每行只能有一个指令。 RainnerScript 是最新的语法。在官网上 rsyslog 大多推荐这个语法格式来配置.

  老的语法格式（sysklogd & legacy rsyslog）是以行为单位;新的语法格式（RainnerScript）可以分割多行。

  注释有两种语法:

  - 井号 #
  - C-style `/* .. */`

  执行顺序：指令在 rsyslog.conf 文件中是从上到下的顺序执行的。

- 模板是 rsyslog 一个重要的属性，它可以控制日志的格式，支持类似 template () 语句的基于 string 或 plugin 的模板，通过它我们可以自定义日志格式。

  > legacy 格式使用 $template 的语法，不过这个在以后要移除，所以最好使用新格式 template ():，以免未来突然不工作了也不知道为什么

  模板定义的形式有四种，适用于不同的输出模块，一般简单的格式，可以使用 string 的形式，复杂的格式，建议使用 list 的形式，使用 list 的形式，可以使用一些额外的属性字段（property statement）

  如果不指定输出模板，rsyslog 会默认使用 RSYSLOG_DEFAULT。若想更深入的学习可以查看[官方文档](http://www.rsyslog.com/doc/v8-stable/configuration/index.html)

- 了解了 rsyslog 环境的配置文件之后，我们看向 `/etc/rsyslog.d/50-default.conf` 这个配置文件，这个文件中主要是配置的 Filter Conditions，也就是我们在流程图中所看见的 `Parser & Filter Engine`, 它的名字叫 Selectors 是过滤 syslog 的传统方法，他主要由两部分组成，`facility` 与 `priority`，其配置格式如下

  ```
  facility.priority　　　　　log_location
  ```

  其中一个 priority 可以指定多个 facility，多个 facility 之间使用逗号 `,` 分割开

  rsyslog 通过 Facility 的概念来定义日志消息的来源，以便对日志进行分类，Facility 的种类有：

  | 类别     | 解释             |
  | -------- | ---------------- |
  | kern     | 内核消息         |
  | user     | 用户信息         |
  | mail     | 邮件系统消息     |
  | daemon   | 系统服务消息     |
  | auth     | 认证系统         |
  | authpriv | 权限系统         |
  | syslog   | 日志系统自身消息 |
  | cron     | 计划安排         |
  | news     | 新闻信息         |
  | local0~7 | 由自定义程序使用 |

- 而另外一部分 priority 也称之为 serverity level，除了日志的来源以外，对统一源产生日志消息还需要进行优先级的划分，而优先级的类别有以下几种：

  | 类别          | 解释                           |
  | ------------- | ------------------------------ |
  | emergency     | 系统已经无法使用了             |
  | alert         | 必须立即处理的问题             |
  | critical      | 很严重了                       |
  | error         | 错误                           |
  | warning       | 警告信息                       |
  | notice        | 系统正常，但是比较重要         |
  | informational | 正常                           |
  | debug         | debug 的调试信息               |
  | panic         | 很严重但是已淘汰不常用         |
  | none          | 没有优先级，不记录任何日志消息 |

- 我们来看看系统中的配置

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0th2etnp3j30s60kydi4.jpg)

  ```
  auth,authpriv.*       /var/log/auth.log
  ```

  这里的意思是 auth 与 authpriv 的所有优先级的信息全都输出于 `/var/log/auth.log` 日志中

  而其中有类似于这样的配置信息意思有细微的差别

  ```
  kern.*      -/var/log/kern.log
  ```

  `-` 代表异步写入，也就是日志写入时不需要等待系统缓存的同步，也就是日志还在内存中缓存也可以继续写入无需等待完全写入硬盘后再写入。通常用于写入数据比较大时使用。

  到此我们对 rsyslog 的配置就有了一定的了解，若想更深入学习模板，队列的高级应用，大家可去查看[官网的文档](http://www.rsyslog.com/doc/v8-stable/index.html) , 需要注意的是 rsyslog 每个版本之间差异化比较大，学习之前先查看自己所使用的版本，再去查看相关的文档

- 与日志相关的还有一个还有常用的命令 `logger`,logger 是一个 shell 命令接口，可以通过该接口使用 Syslog 的系统日志模块，还可以从命令行直接向系统日志文件写入信息。

  ```
  #首先将syslog启动起来
  sudo service rsyslog start
  
  #向 syslog 写入数据
  ping 127.0.0.1 | logger -it logger_test -p local3.notice &
  
  #查看是否有数据写入
  sudo tail -f /var/log/syslog
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0th2ine2dj30s60kytdk.jpg)

  从图中我们可以看到我们成功的将 ping 的信息写入了 syslog 中，格式也就是使用的 rsyslog 的默认模板

  我们可以通过 man 来查看 logger 的其他用法，

  | 参数 | 内容                            |
  | ---- | ------------------------------- |
  | -i   | 在每行都记录进程 ID             |
  | -t   | 添加 tag 标签                   |
  | -p   | 设置日志的 facility 与 priority |

### 转储的日志

- 在本地的机器中每天都有成百上千条日志被写入文件中，更别说是我们的服务器，每天都会有数十兆甚至更多的日志信息被写入文件中，如果是这样的话，每天看着我们的日志文件不断的膨胀，那岂不是要占用许多的空间，所以有个叫 logrotate 的东西诞生了。

- logrotate 程序是一个日志文件管理工具。用来把旧的日志文件删除，并创建新的日志文件。我们可以根据日志文件的大小，也可以根据其天数来切割日志、管理日志，这个过程又叫做 “转储”。

  大多数 Linux 发行版使用 logrotate 或 newsyslog 对日志进行管理。logrotate 程序不但可以压缩日志文件，减少存储空间，还可以将日志发送到指定 E-mail，方便管理员及时查看日志。

- 显而易见，logrotate 是基于 CRON 来运行的，其脚本是 /etc/cron.daily/logrotate；同时我们可以在 `/etc/logrotate`中找到其配置文件

  ```
  cat /etc/logrotate.conf
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0th8091hyj30s60ky40c.jpg)

  这其中的具体意思是什么呢？

  ```
  # see "man logrotate" for details  //可以查看帮助文档
  # rotate log files weekly
  weekly                             //设置每周转储一次(daily、weekly、monthly当然可以使用这些参数每天、星期，月 )
  # keep 4 weeks worth of backlogs
  rotate 4                           //最多转储4次
  # create new (empty) log files after rotating old ones
  create                             //当转储后文件不存在时创建它
  # uncomment this if you want your log files compressed
  compress                          //通过gzip压缩方式转储（nocompress可以不压缩）
  # RPM packages drop log rotation information into this directory
  include /etc/logrotate.d           //其他日志文件的转储方式配置文件，包含在该目录下
  # no packages own wtmp -- we'll rotate them here
  /var/log/wtmp {                    //设置/var/log/wtmp日志文件的转储参数
      monthly                        //每月转储
      create 0664 root utmp          //转储后文件不存在时创建它，文件所有者为root，所属组为utmp，对应的权限为0664
      rotate 1                       //最多转储一次
  }
  ```

  当然在 /etc/logrotate.d/ 中有各项应用的 logrotate 配置，还有更多的配置参数，可以参考 man 帮助文档

##10、Linux 文件系统管理

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

##11、Linux LVM 配置
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

##12、Linux 网络管理
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

- - 

##13、Linux 系统监控
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
	



## 14、Linux 安装与管理软件

- 通常 Linux 上的软件安装主要有四种方式：

  - 在线安装
  - 从磁盘安装 deb 软件包
  - 从二进制软件包安装
  - 从源代码编译安装

  这几种安装方式各有优劣，而大多数软件包会采用多种方式发布软件，所以我们常常需要全部掌握这几种软件安装方式，以便适应各种环境。下面将介绍前三种安装方式，从源码编译安装你将在 Linux 程序设计中学习到。

### 在线安装软件的方式——apt

- 在学习这种安装方式之前有一点需要说明的是，在不同的 linux 发行版上面在线安装方式会有一些差异包括使用的命令及它们的包管理工具，因为我们的开发环境是基于 ubuntu 的，所以这里我们涉及的在线安装方式将只适用于 ubuntu 发行版，或其它基于 ubuntu 的发行版如国内的 ubuntukylin (优麒麟)，ubuntu 又是基于 debian 的发行版，它使用的是 debian 的包管理工具 dpkg，所以一些操作也适用与 debian。而在一些采用其它包管理工具的发行版如 redhat，centos，fedora 等将不适用 (redhat 和 centos 使用 rpm)。

- 比如我们想安装一个软件，名字叫做 `w3m`(w3m 是一个命令行的简易网页浏览器)，那么输入如下命令：

  ```
  $ sudo apt-get install w3m
  ```

  ```
  $ w3m www.shiyanlou.com/faq
  ```

  **注意**: 如果你在安装一个软件之后，无法立即使用 `Tab` 键补全这个命令，你可以尝试先执行 `source ~/.zshrc`，然后你就可以使用补全操作。

- apt 工具是什么？

  > APT 是 Advance Packaging Tool（高级包装工具）的缩写，是 Debian 及其派生发行版的软件包管理器，APT 可以自动下载，配置，安装二进制或者源代码格式的软件包，因此简化了 Unix 系统上管理软件的过程。APT 最早被设计成 dpkg 的前端，用来处理 deb 格式的软件包。现在经过 APT-RPM 组织修改，APT 已经可以安装在支持 RPM 的系统管理 RPM 包。这个包管理器包含以 `apt-` 开头的多个工具，如 `apt-get` `apt-cache` `apt-cdrom` 等，在 Debian 系列的发行版中使用。

  当你在执行安装操作时，首先 `apt-get` 工具会在**本地**的一个数据库中搜索关于 `w3m` 软件的相关信息，并根据这些信息在相关的服务器上下载软件安装，这里大家可能会一个疑问：既然是在线安装软件，为啥会在本地的数据库中搜索？要解释这个问题就得提到几个名词了：

  - **软件源镜像服务器**
  - **软件源**

  我们需要定期从服务器上下载一个软件包列表，使用 `sudo apt-get update` 命令来保持本地的软件包列表是最新的（有时你也需要手动执行这个操作，比如更换了软件源），而这个表里会有**软件依赖**信息的记录，对于软件依赖，我举个例子：我们安装 `w3m` 软件的时候，而这个软件需要 `libgc1c2`这个软件包才能正常工作，这个时候 `apt-get` 在安装软件的时候会一并替我们安装了，以保证 `w3m` 能正常的工作。

- `apt-get`——软件安装卸载

  `apt-get` 是用于处理 `apt` 包的公用程序集，我们可以用它来在线安装、卸载和升级软件包等，下面列出一些 `apt-get`包含的常用的一些工具：

  | 工具           | 说明                                                         |
  | -------------- | ------------------------------------------------------------ |
  | `install`      | 其后加上软件包名，用于安装一个软件包                         |
  | `update`       | 从软件源镜像服务器上下载 / 更新用于更新本地软件源的软件包列表 |
  | `upgrade`      | 升级本地可更新的全部软件包，但存在依赖问题时将不会升级，通常会在更新之前执行一次 `update` |
  | `dist-upgrade` | 解决依赖关系并升级 (存在一定危险性)                          |
  | `remove`       | 移除已安装的软件包，包括与被移除软件包有依赖关系的软件包，但不包含软件包的配置文件 |
  | `autoremove`   | 移除之前被其他软件包依赖，但现在不再被使用的软件包           |
  | `purge`        | 与 remove 相同，但会完全移除软件包，包含其配置文件           |
  | `clean`        | 移除下载到本地的已经安装的软件包，默认保存在 /var/cache/apt/archives/ |
  | `autoclean`    | 移除已安装的软件的旧版本软件包                               |

  下面是一些 `apt-get` 常用的参数：

  | 参数                 | 说明                                                         |
  | -------------------- | ------------------------------------------------------------ |
  | `-y`                 | 自动回应是否安装软件包的选项，在一些自动化安装脚本中使用这个参数将十分有用 |
  | `-s`                 | 模拟安装                                                     |
  | `-q`                 | 静默安装方式，指定多个 `q` 或者 `-q=#`,# 表示数字，用于设定静默级别，这在你不想要在安装软件包时屏幕输出过多时很有用 |
  | `-f`                 | 修复损坏的依赖关系                                           |
  | `-d`                 | 只下载不安装                                                 |
  | `--reinstall`        | 重新安装已经安装但可能存在问题的软件包                       |
  | `--install-suggests` | 同时安装 APT 给出                                            |

- 重新安装

  很多时候我们需要重新安装一个软件包，比如你的系统被破坏，或者一些错误的配置导致软件无法正常工作。

  你可以使用如下方式重新安装：

  ```
  $ sudo apt-get --reinstall install w3m
  ```

- 软件升级

  ```
  # 更新软件源
  $ sudo apt-get update
  # 升级没有依赖问题的软件包
  $ sudo apt-get upgrade
  # 升级并解决依赖关系
  $ sudo apt-get dist-upgrade
  ```

- 卸载软件

  如果你现在觉得 `w3m` 这个软件不合自己的胃口，或者是找到了更好的，你需要卸载它，那么简单！同样是一个命令加回车 `sudo apt-get remove w3m` ，系统会有一个确认的操作，之后这个软件便 “滚蛋了”。

  执行了 `remove` 前，使用`whereis w3m`命令，发现：

  ```
  shiyanlou:~/ $ whereis w3m                           
  w3m: /usr/bin/w3m /usr/lib/w3m /etc/w3m /usr/share/w3m /usr/share/man/man1/w3m.1.gz
  
  ```

  执行了 `remove` 后，使用`whereis w3m`命令，发现：

  ```
  shiyanlou:~/ $ whereis w3m                           
  w3m: /etc/w3m
  ```

  这时可以执行`purge`命令：

  ```
  # 不保留配置文件的移除
  $ sudo apt-get purge w3m
  ```

  再执行`whereis w3m`命令，发现：

  ```
  shiyanlou:~/ $ whereis w3m                           
  w3m:
  ```

  移除不需要的被依赖的软件包：

  ```
  # 移除不再需要的被依赖的软件包
  $ sudo apt-get autoremove
  ```

- `apt-cache` ——软件搜索

  当自己刚知道了一个软件，想下载使用，需要确认软件仓库里面有没有，就需要用到搜索功能了，命令如下：

  ```
  sudo apt-cache search softname1 softname2 softname3……
  ```

  `apt-cache` 命令则是针对本地数据进行相关操作的工具，`search` 顾名思义在本地的数据库中寻找有关 `softname1` `softname2` …… 相关软件的信息。现在我们试试搜索一下之前我们安装的软件 `w3m` ：

  ```
  shiyanlou:~/ $ sudo apt-cache search w3m             
  w3m - WWW browsable pager with excellent tables/frames support
  w3m-el - simple Emacs interface of w3m
  w3m-el-snapshot - simple Emacs interface of w3m (development version)
  w3m-img - inline image extension support utilities for w3m
  ```

  结果显示了 4 个 `w3m` 相关的软件，并且有相关软件的简介。

  关于在线安装的的内容我们就介绍这么多，想了解更多关于 APT 的内容，你可以参考：

  - [APT HowTo](http://www.debian.org/doc/manuals/apt-howto/index.zh-cn.html#contents)

### 本地磁盘安装deb软件包——dpkg

- dpkg 介绍

  > dpkg 是 Debian 软件包管理器的基础，它被伊恩・默多克创建于 1993 年。dpkg 与 RPM 十分相似，同样被用于安装、卸载和供给和 .deb 软件包相关的信息。

  > dpkg 本身是一个底层的工具。上层的工具，像是 APT，被用于从远程获取软件包以及处理复杂的软件包关系。"dpkg" 是 "Debian Package" 的简写。

  我们经常可以在网络上见到以 `deb` 形式打包的软件包，就需要使用 `dpkg` 命令来安装。

  `dpkg` 常用参数介绍：

  | 参数 | 说明                                              |
  | ---- | ------------------------------------------------- |
  | `-i` | 安装指定 deb 包                                   |
  | `-R` | 后面加上目录名，用于安装该目录下的所有 deb 安装包 |
  | `-r` | remove，移除某个已安装的软件包                    |
  | `-I` | 显示 `deb` 包文件的信息                           |
  | `-s` | 显示已安装软件的信息                              |
  | `-S` | 搜索已安装的软件包                                |
  | `-L` | 显示已安装软件包的目录信息                        |

- 使用 dpkg 安装 deb 软件包

  我们先使用 `apt-get` 加上 `-d` 参数只下载不安装，下载 emacs 编辑器的 deb 包，下载完成后，我们可以查看 /var/cache/apt/archives/ 目录下的内容，如下图：

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tcytez1pj30kk0f4q5t.jpg)

  然后我们将第一个 `deb` 拷贝到 /home/shiyanlou 目录下，并使用 `dpkg` 安装

  ```
  $ cp /var/cache/apt/archives/emacs24_24.5+1-6ubuntu1.1_amd64.deb ~
  # 安装之前参看deb包的信息
  $ sudo dpkg -I emacs24_24.5+1-6ubuntu1.1_amd64.deb
  ```

  如你所见，这个包还额外依赖了一些软件包，这意味着，如果主机目前没有这些被依赖的软件包，直接使用 dpkg 安装可能会存在一些问题，因为 `dpkg` 并不能为你解决依赖关系。

  ```
  # 使用dpkg安装
  $ sudo dpkg -i emacs24_24.5+1-6ubuntu1.1_amd64.deb
  ```

  跟前面预料的一样，这里你可能出现了一些错误：

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0tcz1c9zaj30ke0ge455.jpg)

  我们将如何解决这个错误呢？这就要用到 `apt-get` 了，使用它的 `-f` 参数了，修复依赖关系的安装

  ```
  $ sudo apt-get update
  $ sudo apt-get -f install
  ```

  没有任何错误，这样我们就安装成功了，然后你可以运行 emacs 程序了

  ```
  shiyanlou:~/ $ emacs24    
  ```

- 查看已安装软件包的安装目录，使用 `dpkg -L` 查看 `deb` 包目录信息

  ```
  $ sudo dpkg -L emacs24
  ```

  ![](http://ww1.sinaimg.cn/large/005GdKShly1g0td15m9haj30kl0hu78q.jpg)

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