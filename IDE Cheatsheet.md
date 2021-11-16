# IDE Cheatsheet

## Vscode

### VsCode通用快捷键

#### 跳转

Ctrl+ 返回光标上次停留位置

Ctrl + Tab 列出最近打开的文件，按住Ctrl连按Tab再放手可以跳转到文件

Command + P 搜索文件，且支持 `:行号` 或者 `@符号`

F12 跳转到函数或符号的定义

#### 查看

option+F12 预览函数或符号的定义，与单纯的F12区别是在当前文件开启一个小浮窗查看

shift+F12 预览光标所在函数/变量在所有文件的引用，同上

shift+command+O：查看当前文件所有符号

Option + Command + [ 括号收缩

Option + Command + ] 括号展开

#### 格式

ctrl + ] 行增加缩进: 

ctrl + [ 行减少缩进: 

#### 插件

VsCode插件——Bookmarks：

option+command + L 添加/删除书签

opiton+command + J 上一个书签

opiton+command + L 下一个书签

## IDEA

## 导航（Navigation）

主要是以Command开头的

- ⇧⇧: 万能搜索
- ⌘L: Go to line
- ⌘⌥F7 /⌥F7 : Show usages，前者在底部窗口打开适合多次查看，后者在浮窗打开适合临时查看
- ⌘O : Go to class，全局搜索，打开后还可以通过tab键搜索Files/Symbols等
- ⌘U : Go to super-method/super-class，直接跳转到父类的覆写的方法/父类
- ⌘⌥B : Go to implementation(s)，查看interface的所有实现类并可跳转
- ⌘E : Recent files popup，高频使用！
- ⌘⌥T : Go to test，直接跳转到相应的测试类（以及从测试类返回对应的类），好用！
- ⌘⇧+Backspace : Navigate to last edit location，跳转到上一次编辑的地点

## 编辑（Editing）

- ⌃O: Override methods，查看所有可Override的方法并可按需添加，适用于继承某个父类的子类
- ⌃I: Implement methods，查看所有可实现的方法并可按需添加，适用于实现某个接口的类
- ⌘N: Generate code，生成代码，如构造方法/getter&setter/equals/toString等
- ⌃⌥O: Optimize imports，优化代码，如去除无引用的包
- ⌘⌥L: Reformat code，优化代码格式
- ⌘D: Duplicate current line or selected block，复制当前行或选中的块
- ⌥⇧↑，⌥⇧↓: Move line，上下移动当前行
- ⌥↑ / ⌥↓: Extend/shrink selection，光标扩大选择范围
- ⌘⇧U: Toggle case for word at caret or selected block，大小写互相转换

## 代码自动完成（Code Completion）

### 后缀代码完成（Postfix Code Completion）

输入`.后缀`后，浮窗会提示，上下移动再回车即可

- xxx.notnull: Checks expression to be not-null，非空判断
- xxx.fori: Iterates with index over collection，正序遍历集合
- xxx.forr: Iterates with index in reverse order，逆序遍历集合

### 代码模板（Live Templates）

输入后，浮窗会提示后，回车即可创建一个模板

- fori: Create Iteration Loop，创建一个循环
- sout: Prints a string to System.out，打印一个字符串到系统标准输出中