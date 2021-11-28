# git cheatsheet

## 分支

### 与远程协作

#### 开始

git checkout -b feature/xxx：从当前分支创建出新分支，并切换到新分支上，新分支与当前分支是一样的

git checkout -b feature/xxx origin/eature/xxx：该命令可以将远程git仓库里的指定分支拉取到本地，这样就在本地新建了一个feature/xxx分支，并和指定的远程分支feature/xxx关联了起来，当前分支是什么对新分支不造成影响，最后会切换到新分支上，本地和远程分支的名称最好一致；

如果还碰到问题：fatal: 'origin/feature/xxx' is not a commit and a branch 'feature/xxx' cannot be created from it

解决：git fetch --all，再git checkout -b feature/xxx origin/eature/xxx

#### 反向开始

git push --set-upstream origin feature/xxx：在本地checkout新分支，然后想推到远程仓库，发现远程仓库没有设置上游，该命令可以设置上游

git branch -vv：查看当前分支的upstream

git push origin master:foo：意思就是把本地的 master branch 推送到远程的 foo branch。

#### 多人协作

多人协作的工作模式通常是这样：

1. 首先，可以试图用git push origin <branch-name>推送自己的修改；

2. 如果推送失败，则因为远程分支比你的本地更新，需要先用git pull试图合并；

3. 如果合并有冲突，则解决冲突，并在本地提交；

4. 没有冲突或者解决掉冲突后，再用git push origin <branch-name>推送就能成功！

如果git pull提示no tracking information，则说明本地分支和远程分支的链接关系没有创建，用命令git branch --set-upstream-to <branch-name> origin/<branch-name>。

### git cherry-pick

$ git cherry-pick <commitHash>：将指定的提交commitHash，应用于当前分支。这会在当前分支产生一个新的提交

$ git cherry-pick A..B ：将某分支的`(A, B]`这段提交应用到当前分支

$ git cherry-pick A^..B ：将某分支的`[A, B]`这段提交应用到当前分支

```shell
-e，--edit：打开外部编辑器，编辑提交信息。
-n，--no-commit：只更新工作区和暂存区，不产生新的提交。
-x：在提交信息的末尾追加一行(cherry picked from commit ...)，方便以后查到这个提交是如何产生的。
-s(--signoff)：在提交信息的末尾追加一行操作者的签名，表示是谁进行了这个操作。
-m(--mainline) parent-number：如果原始提交是一个合并节点，来自于两个分支的合并，那么 Cherry pick 默认将失败，因为它不知道应该采用哪个分支的代码变动。-m配置项告诉 Git，应该采用哪个分支的变动。它的参数parent-number是一个从1开始的整数，代表原始提交的父分支编号。
$ git cherry-pick -m 1 <commitHash>：上面命令表示，Cherry pick 采用提交commitHash来自编号1的父分支的变动。一般来说，1号父分支是接受变动的分支（the branch being merged into），2号父分支是作为变动来源的分支（the branch being merged from）。

```

$ git cherry-pick --continue：若产生代码冲突，解决完冲突，执行git add（不用git commit！），再执行continue即可继续cherry-pick

$ git cherry-pick --abort：发生代码冲突后，不解决冲突，执行abort回到cherry-pick之前的状态

这篇文章讲了cherry-pick，系列共10篇，需要一定功底才能看懂：https://devblogs.microsoft.com/oldnewthing/20180312-00/?p=98215

### git delete

git delete -d feature/xxx:

```shell
error: The branch 'feature/xxx' is not fully merged.
If you are sure you want to delete it, run 'git branch -D feature/xxx'.
```

git delete -D feature/xxx：如果要丢弃一个没有被合并过的分支，可以使用该命令强行删除

### git merge --squash <br>

我需要将一个分支合并成一个提交(commit)

(master)$ git merge --squash my-branch

## git add 

git add -A：all，会标记本地所有有改动（包括删除和修改）和新增的文件。将文件的修改，文件的删除，文件的新建，添加到暂存区。

git add -u：update，只会标记本地有改动（包括删除和修改）的已经追踪的文件，不包括新文件。将文件的修改、文件的删除，添加到暂存区

git add .：提交所有新增、删除、修改的文件到暂存区。（git1.x版本中该命令不包括删除的文件！）

**git add --ignore-removal：提交所有新增与修改文件到暂存区，不包括删除的跟踪文件**（git2.x版本才支持）

git add -p：交互式选择hunks来add，可以将工作区的改动分为多次add，最终可以分为多次commit

## git diff

git diff ⽐较⼯作区和暂存区的修改。 Show unstaged changes between your index and working
directory.

git diff HEAD ⽐较⼯作区和上⼀次commit后的修改。 Show difference between working directory and last commit.

git diff --cached ⽐较暂存区和上⼀次commit后的修改。 Show difference between staged changes and last commit

git diff hash1 hash2 --stat：能够查看出两次提交之后，文件发生的变化。

git diff hash1 hash2 -- 文件名：具体查看两次commit提交之后某文件的差异：

git diff branch1 branch2：比较两个分支的所有有差异的文件的详细差异：

git diff branch1 branch2 文件名(带路径)：比较两个分支的指定文件的详细差异

git diff branch1 branch2 --stat：比较两个分支的所有有差异的文件列表

## git stash

三种使用场景：

1. 发现有一个类是多余的，想删掉它又担心以后需要查看它的代码，想保存它但又不想增加一个脏的提交。这时就可以考虑git stash。

2. 使用git的时候，我们往往使用分支（branch）解决任务切换问题，例如，我们往往会建一个自己的分支去修改和调试代码, 如果别人或者自己发现原有的分支上有个不得不修改的bug，我们往往会把完成一半的代码commit提交到本地仓库，然后切换分支去修改bug，改好之后再切换回来。这样的话往往log上会有大量不必要的记录。其实如果我们不想提交完成一半或者不完善的代码，但是却不得不去修改一个紧急Bug，那么使用git stash就可以将你当前未提交到本地（和服务器）的代码推入到Git的栈中，这时候你的工作区间和上一次提交的内容是完全一样的，所以你可以放心的修Bug，等到修完Bug，提交到服务器上后，再使用git stash apply将以前一半的工作应用回来。

3. 经常有这样的事情发生，当你正在进行项目中某一部分的工作，里面的东西处于一个比较杂乱的状态，而你想转到其他分支上进行一些工作。问题是，你不想提交进行了一半的工作，否则以后你无法回到这个工作点。解决这个问题的办法就是git stash命令。储藏(stash)可以获取你工作目录的中间状态——也就是你修改过的被追踪的文件和暂存的变更——并将它保存到一个未完结变更的堆栈中，随时可以重新应用。

git stash：把当前工作区所有未提交的修改（包括暂存的和非暂存的）都保存起来，用于后续恢复当前工作目录。

> stash是本地的，不会通过git push命令上传到git server上。

git stash save “Your stash message”：同上，但指定stash的信息

git stash list：查看stash区/栈

```shell
stash@{0}: WIP on master: 049d078 added the index file
stash@{1}: WIP on master: c264051 Revert "added file_size"
stash@{2}: WIP on master: 21d80a5 added number to log
```

git stash apply [stash@{1}]：从stash区获取最上面的stash恢复到工作区中，也可以通过stash id[stash@{1}]将指定stash恢复到工作区

git stash pop [stash@{1}]：从stash区获取最上面的stash恢复到工作区中，也可以通过stash id[stash@{1}]将指定stash恢复到工作区，**然后会删除这个stash**

git stash show [stash@{1}]：查看与最近的stash的文件差异，加上-p参数可看完整差异，也可以查看与指定stash的差异

git stash clear：删除所有stash

git stash drop：删除指定stash

## 变基(rebase)

警告：不要通过rebase对任何已经提交到公共仓库中的commit进行修改（你自己一个人玩的分支除外）

rebase与merge都可以用来合并，但是merge会将master分支合并到开发分支中并形成一次新commit（分叉后合拢，平行四边形），rebase会将开发分支上的新提交拷贝成副本放到master的前面，git rebase 会改写历史提交记录，这里的改写不仅限于树的结构，树上的节点的commit id也会别改写


```shell
git checkout mywork # 假设主分支叫origin
... # mywork有一系列提交，origin也有一系列提交
git rebase origin # 可能需要解决冲突，解决完冲突使用git add更新然后执行git rebase --continue，无需commit，在任何时候可以用git rebase --abort回到rebase前的状态  
```

### 交互式变基

git rebase -i  [startpoint]  [endpoint]：交互式界面修改commit；可以用来合并多个commit为一个完整commit，也可以将某一段commit粘贴到另一个分支上，endpoint可省略，默认到最近的commit，举例

```shell
pick a9c8a1d Some refactoring
pick 01b2fd8 New awesome feature
pick b729ad5 fixup
pick e3851e8 another fix

# Rebase 8074d12..b729ad5 onto 8074d12
#
# Commands:
#  p, pick = use commit
#  r, reword = use commit, but edit the commit message
#  e, edit = use commit, but stop for amending
#  s, squash = use commit, but meld into previous commit
#  f, fixup = like "squash", but discard this commit's log message
#  x, exec = run command (the rest of the line) using shell
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out
```

例如, 如果你想 单独保留最旧(first)的提交(commit),组合所有剩下的到第二个里面, 你就应该编辑第二个提交(commit)后面的每个提交(commit) 前的单词为 f:

```shell
pick a9c8a1d Some refactoring
pick 01b2fd8 New awesome feature
f b729ad5 fixup
f e3851e8 another fix
```

如果你想组合这些提交(commit) 并重命名这个提交(commit), 你应该在第二个提交(commit)旁边添加一个r，或者更简单的用s 替代 f:

```shell
pick a9c8a1d Some refactoring
pick 01b2fd8 New awesome feature
s b729ad5 fixup
s e3851e8 another fix
```

你可以在接下来弹出的文本提示框里重命名提交(commit)。

```shell
Newer, awesomer features

# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
# rebase in progress; onto 8074d12
# You are currently editing a commit while rebasing branch 'master' on '8074d12'.
#
# Changes to be committed:
#	modified:   README.md
#
```

如果成功了, 你应该看到类似下面的内容:

```shell
(master)$ Successfully rebased and updated refs/heads/master.
```

### 我只想组合(combine)未推送的提交(unpushed commit)

有时候，在将数据推向上游之前，你有几个正在进行的工作提交(commit)。这时候不希望把已经推(push)过的组合进来，因为其他人可能已经有提交(commit)引用它们了。

(master)$ git rebase -i @{u}

这会产生一次交互式的rebase(interactive rebase), 只会列出没有推(push)的提交(commit)， 在这个列表时进行reorder/fix/squash 都是安全的。

### 如果rebase第一次提交

默认情况下，第一次提交是作为后续提交的根，无法修改，比如该分支有如下两次提交

```shell
$git log
commit 16c5f5a (HEAD -> master)
Author: xxx
Date:   Mon Aug 30 14:45:37 2021 +0800

    first mod README

    second mod README

commit 461d67 (origin/master)
Author: xxx
Date:   Mon Aug 30 14:39:30 2021 +0800

    init README.md
```

执行git rebase -i 或 git rebase -i HEAD^/HEAD~/HEAD~1后，显示如下：

```shell
$git rebase -i HEAD~
hint: Waiting for your editor to close the file...
  1 pick 16c5f5a first mod README
  2
  3 # Rebase 461d67e..16c5f5a onto 461d67e (1 command)
```

此时如果想把16c5f5a的pick改为s或者f，会报错：

```shell
error: cannot 'squash' without a previous commit
You can fix this with 'git rebase --edit-todo' and then run 'git rebase --continue'.
Or you can abort the rebase with 'git rebase --abort'.
```

这是因为没有前置提交，默认不会把第一次提交（根提交）作为前置提交，若想根据根提交变基，可以执行git rebase -i --root

```shell
git rebase -i --root
hint: Waiting for your editor to close the file...
  1 pick 461d67e init README.md
  2 s 16c5f5a first mod README
  3
  4 # Rebase 16c5f5a onto 21c7e3b (2 commands)
```

最后调用git log看看，确实把后置提交与根提交合在一起了

```shell
$git log
commit e8c570f9a8251eba3511a6eea658c020a8f59111 (HEAD)
Author: 镇珩 <zhenheng.lhl@alibaba-inc.com>
Date:   Mon Aug 30 14:39:30 2021 +0800

    init README.md

    first mod README

    second mod README
```

## 反悔与撤销

Git项目有3个区域：工作区、暂存区和Git仓库（分成本地仓库和远程仓库）。（总结自：https://segmentfault.com/a/1190000022951517

### 在未暂存前，撤销本地修改

git diff：在没有暂存之前（没有执行git add命令），该命令可以查看本地修改

git checkout -- ./[filename] ：一次性撤销所有本地修改/撤销指定文件的本地修改

> 注意：该命令不可二次“反悔”，本地操作一旦撤销，将无法通过Git找回。

### 在暂存之后，撤销暂存区的修改

git add：会将工作区的文件标记为已暂存，保存在暂存区。

git diff --staged：查看暂存区的修改

git reset . / [filename]：一次性撤销暂存区的全部修改/撤销暂存区指定文件的修改，**即该命令只是撤销git add这个命令，回到『已修改未暂存状态』**

> 注意：该命令可以二次“反悔”，通过git add .命令可以将文件再一次添加到暂存区。

get reset --hard：等同于git reset . + git checkout --.，即：如果已暂存，但未提交本地仓库之前，想把所有文件直接抛弃（而不是从暂存区删除），可以直接执行以上命令。

### 提交到本地仓库之后（但未推送到远程仓库），撤销本次提交

git commit -m "xxx"：将标记为已暂存的文件保存至本地Git仓库，并生成一个快照。

git log：查看本地git仓库的提交（commit）历史

git checkout [上一次commit id]：回到之前的提交（commit）

git reset --hard HEAD~1：效果同上

> 该命令是可以二次“反悔”的，找到被重置的提交 git reflog，发现是f8651ff，使用reset回到该提交 git reset --hard f8651ff

### 从上一次提交中签出指定文件

```shell
git checkout -- a.txt
```

**提示**：运行上面的命令后，将签出上次提交时a.txt文件。

### 从指定的提交历史中签出指定文件

附加上commit id，将会签出指定提交记录中的文件：

```shell
git checkout 830cf95f56ef9a7d6838f6894796dac8385643b7 -- a.txt
```

### 从其他分支签出指定文件

**背景**：一个仓库一般有一个master分支和其他多个brach。branch主要目的是为了某个功能开发，在开发期间 master 分支可能更新了核心模块，这时其他branch需要同步更新此模块。

**说明**：只需要签出时指定分支名称。

**命令**：

```shell
git checkout master -- a.txt
```

> 除了签出制定文件外，git还支持签出指定目录、制定后缀等等。
>
> ```shell
> git checkout -- *.txt
> git checkout -- css/
> ```
>
> 

## 2.2 从指定的提交历史中签出指定文件

附加上commit id，将会签出指定提交记录中的文件：

```
git checkout 830cf95f56ef9a7d6838f6894796dac8385643b7 
```

### reset再温习

git reset [HEAD]：撤销暂存区（stage）的修改，即撤销git add命令，其中HEAD可加可不加

git reset HEAD^：回退到上一commit版本

git reset [commit id]：回退到某一commit版本

参数--hard：reset回退版本时默认会将暂存区/原来commit的变动文件回退到修改状态，只是操作了暂存区，不影响工作区的，--hard一步到位，相当于reset后再执行git checkout .
dd 
参数--mixed：默认模式

参数--soft：保留working Tree工作目录和index暂存区的内容，只让repository中的内容和 reset 目标节点保持一致。适用于需要将多个commit合并简化成一个commit的情况。

### 修改提交(ammend)

git commit --amend：上次commit所包括的文件不全，这个命令可以将新的暂存区的文件添加至上此commit，而不会产生新的commit id与msg

git commit --amend -m "xxxx"：上次commit的提交信息有误（比如单词拼错），该命令可以修改上次commit的提交信息，而不会产生新的commit id与msg

如果已经提交到了远程仓库，amend后的新提交在push时会被拒绝，可以使用git push -f

### 撤销提交历史中的某一次指定的提交(revert)

git revert 711bb0b：撤销commit id为711bb0b的提交（将提交的内容“反操作”），生成一个新的commit放在git log的最前面

### 合并出现冲突时，撤销合并操作(merge --abort)

git merge --abort：在执行git merge [branch]时产生了冲突，如果不想解决这个冲突/不想合并，使用该命令可以回到合并前的状态

### 以脚本方式改写提交

git filter-branch --tree-filter 'rm -f passwords.txt' HEAD

> 考虑以下场景，在一次很早的提交中，将一个储存密码的文件passwords.txt提交到了远程仓库，这时如果只是从远程仓库中删除该文件，别人依然可以通过提交历史找到这个文件。因此我们需要从每一个快照中移除该密码文件，该命令执行完会将提交历史中所有提交的passwords.txt文件彻底删除，永远没法通过Git找回。--tree-filter 选项在检出项目的每一个提交后运行指定的命令然后重新提交结果

## subtree

简介：git subtree会将某个子仓库合并到项目中的子目录中，主要用来多个项目共用某一段代码，或者希望把一部分代码独立出去成为一个新的git repo，同时又希望能保留历史提交记录

关联subtree：git subtree add --prefix=$subtree_relative_path $repo $ref --squash

> 解释：--squash意思是把subtree的改动合并成一次commit，这样就不用拉取子项目完整的历史记录。--prefix之后的=等号也可以用空格。

git subtree push --prefix=$subtree_relative_path $repo $ref

> 用法：项目里各种提交commit，其中有些commit会涉及到子目录的更改，该命令会遍历项目中的所有commit，从中找到涉及子目录中的更改，将这些更改从提取出来单独推到子项目的远程仓库中

git subtree pull --prefix=$subtree_relative_path $repo $ref --squash

> 用法：将子项目远程仓库的最新版本pull到本项目的子目录中

> 这些命令要在项目的根目录中执行，subtree_relative_path是子目录的相对路径，注意subtree add前可能需要在项目中添加子项目的远程分支，即git remote add xxx https://github.com/bob/xxx.git

## 未暂存的内容/工作区

### 把未暂存的内容移动到一个新分支

git checkout -b new_branch

### 把未暂存的内容移动到一个已存在的分支

git stash

git checkout exist_branch

git stash pop

### 丢弃某些未暂存的内容

git checkout -p：交互式选择hunks去检出

## 二分法定位问题

git bisect是一个很有用的命令，用来查找哪一次代码提交引入了错误。

$ git bisect start [终点] [起点]："终点"是最近的提交，"起点"是更久以前的提交。它们之间的这段历史，就是差错的范围。该命令会checkout到这段范围最中间的commit

$ git bisect good：检查完当前commit后，确定该commit功能正常，执行该命令可以二分法缩小到前半段范围

$ git bisect bad：检查完当前commit后，确定该commit功能不正常，执行该命令可以二分法缩小到后半段范围

$ git bisect reset：当二分法定位到问题后，可以检查当时的代码提交，然后执行该命令回到最初的提交，进行代码修改
