#!bin/bash
subtree_path=数据结构与算法/leetcode
repo=https://github.com/edisonleolhl/LeetCode.git
ref=$1

echo "merging lc ref [$ref] into subtree"
git subtree pull --prefix=$subtree_path $repo $ref --squash

# 假设P1项目、P2项目共用S项目
# 1. 关联Subtree
# '' cd P1项目的路径
# '' git subtree add --prefix=<S项目的相对路径> <S项目git地址> <分支> --squash
# 
# 解释：--squash意思是把subtree的改动合并成一次commit，这样就不用拉取子项目完整的历史记录。--prefix之后的=等号也可以用空格。
# 
# 2. 更新代码
# P1、P2项目里各种提交commit，其中有些commit会涉及到S目录的更改，但是没关系
# 
# 3. 提交更改到子项目
# '' cd P1项目的路径
# '' git subtree push --prefix=<S项目的相对路径> <S项目git地址> <分支>
# Git 会遍历步骤2中所有的commit，从中找出针对S目录的更改，然后把这些更改记录提交到S项目的Git服务器上，并保留步骤2中的相关S的提交记录到S仓库中
# 
# 4. 更新子目录
# ''cd P2项目的路径
# ''git subtree pull --prefix=<S项目的相对路径> <S项目git地址> <分支> --squash
