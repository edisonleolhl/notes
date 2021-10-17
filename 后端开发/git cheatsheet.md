# git cheatsheet

## subtree

简介：git subtree会将某个子仓库合并到项目中的子目录中，主要用来多个项目共用某一段代码，或者希望把一部分代码独立出去成为一个新的git repo，同时又希望能保留历史提交记录

关联subtree：git subtree add --prefix=$subtree_relative_path $repo $ref --squash

解释：--squash意思是把subtree的改动合并成一次commit，这样就不用拉取子项目完整的历史记录。--prefix之后的=等号也可以用空格。

git subtree push --prefix=$subtree_relative_path $repo $ref

用法：项目里各种提交commit，其中有些commit会涉及到子目录的更改，该命令会遍历项目中的所有commit，从中找到涉及子目录中的更改，将这些更改从提取出来单独推到子项目的远程仓库中

git subtree pull --prefix=$subtree_relative_path $repo $ref --squash

用法：将子项目远程仓库的最新版本pull到本项目的子目录中

这些命令要在项目的根目录中执行，subtree_relative_path是子目录的相对路径，注意subree add前可能需要在项目中添加子项目的远程分支，即git remote add xxx https://github.com/bob/xxx.git