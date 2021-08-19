#!/bin/bash
subtree_path=数据结构与算法/leetcode
repo=https://github.com/edisonleolhl/LeetCode.git
ref=$1

echo "merging lc ref [$ref] into subtree"
git subtree pull --prefix=$subtree_path $repo $ref --squash