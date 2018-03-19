# ns-3 备忘录

> 个人学习笔记，记录一下，以防记忆走丢~

## 相关资料

- ns-3 官网：https://www.nsnam.org/

- ns-3 官方开放文档主页：https://www.nsnam.org/documentation/

    - ns-3 tutorial：ns-3 入门教程，包括安装、基本技术、关键概念等

    - ns3-3 manual：ns-3 手册，介绍 ns-3 软件的整体架构、核心模块技术等

    - ns-3 model library：ns-3 模型库，介绍 ns-3 中各个功能模块的具体细节

    - API Documentation：使用 Doxygen 文档话的 ns-3 API 文档，包括所有的模块、文件和类及其成员，类似 Visual studio 的 MSDN ，是阅读和编写 ns-3 代码的必不可少的资料

- FAQ：https://www.nsnam.org/support/faq/ ，可能会找到常见问题的答案，适合新手看一下

- 维基百科：https://www.nsnam.org/wiki/Main_Page ，能找到很多 Document 中没有提到的细节，进阶必备

- Mailing lists：https://www.nsnam.org/support/mailing-list ，加入讨论组中，和来自全世界各地的开发者一起交流成长！

- HOWTO configure Eclipse with ns-3：https://www.nsnam.org/wiki/HOWTO_configure_Eclipse_with_ns-3 ，官网中关于调试 eclipse 的指南，与 youtube 视频教程结合使用，效果更佳

- youtube 教程视频（by 
Hitesh Choudhary
）:https://www.youtube.com/watch?v=npv8gBoySyk&index=6&list=PLRAV69dS1uWQEbcHnKbLldvzrjdOcOIdY ，关于新手入门的绝佳视频

- OpenFlow 模块：http://www.lrc.ic.unicamp.br/ofswitch13/index.html ，ns-3 本身自带的 OpenFlow 模块版本太低，不足以满足仿真需求，这是一位来自巴西的博士生把 ofswitch13 （一个实现了 OF1.3 的项目）移植到 ns-3 平台中，ofswitch13 是由爱立信（Ericsson）公司的 CPqD 团队研究的

- 书籍： 《 ns-3 网络模拟器基础及应用》，作者：马春光、姚建盛，出版社：人民邮电出版社
## 下载安装

- 推荐官网的  Getting Started ：https://www.nsnam.org/docs/tutorial/html/getting-started.html

- 也可 Google ：install ns-3 in Ubuntu 16.04

- NOTE that don't add 'sudo' in front of './build' !!!

- 新 os 中可能没有 ns-3 所依赖的环境，可能需要在 terminal 中下载各种 package，在有些网游写的教程中，可能有些 package 可能过时了，把 error 拷贝下来再 Google 一下，即可找到解决方案

    > package 替换：libgsl0ldbl --> libgsl2

- 建议虚拟机分配至少 4G 内存给 Ubuntu 虚拟机，不然可能会很卡，第一次执行 waf 命令时可能要编译很久 -_-

## 新手上路

- 看 first.cc，网上有很多关于它的解释

- 然后看 second.cc 、third.cc 等等

## 必知概念

- Node

- Application

- Channels

- Net Device

- Topology Helper

## 目录结构

- waf ：基于 Python 开发的编译工具， ns-3 系统本身和将要写的仿真代码都由 waf 负责编译运行

- scratch ：一般存放用户的脚本文件，默认的，使用 waf 编译运行的脚本文件可以不加目录名 scratch，如在其他目录则要加，推荐把脚本文件移动或复制到 scratch 目录下

- doc ：帮助文档，通过 waf 可将 ns-3 在线帮助文档 doxygen 编译到本地 doc 目录下， ./waf-doxygen

- build ：编译目录，包含编译文件时使用的共享库和头文件

- src ：ns-3 源代码目录，基本和模块相对应

## 模块目录

- 一个模块目录的子结构是固定的，如下所示：

    - bingdings ：用来绑定 Python 语言

    - doc ：帮助文档

    - examples ：该模块的示例代码

    - helper ：模块对应的 helper 类的代码

    - model ：存放模块代码的 .cc 文件和 .h 文件

    - test ：存放设计者编写的模块测试代码

    - waf

    - wscript ：固定，用来注册模块的源代码和使用其他模块的情况

## 仿真流程

- 选择或开发相应模块

  - 有线 or 无线？ CSMA or Wi-Fi

  - 节电移动？ mobility

  - 何种应用程序？ application

  - 能量管理？ energy

  - 何种路由协议？ internet、aodv

- 编写网络仿真脚本（ C++ or Python ）

    - 生成节点：计算机空壳

    - 安装网络设备

    - 安装协议栈

    - 安装应用层协议

    - 其他配置：移动？能量？根据传输层协议选择相应的应用层协议

## 