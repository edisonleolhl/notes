# 不积跬步无以至千里

## 数组

### 第3题：数组中的重复数组

题目描述

在一个长度为 n 的数组里的所有数字都在 0 到 n-1 的范围内。 数组中某些数字是重复的，但不知道有几个数字是重复的。也不知道每个数字重复几次。请找出数组中任意一个重复的数字。 例如，如果输入长度为 7 的数组 {2,3,1,0,2,5,3}，那么对应的输出是第一个重复的数字 2

#### 第3题：数组中的重复数组的暴力解法

没啥好说的，双层循环，最直观的解法，时间复杂度：O(n^2)，空间复杂度：O(1)

```c++
class Solution {
public:
    // Parameters:
    //        numbers:     an array of integers
    //        length:      the length of array numbers
    //        duplication: (Output) the duplicated number in the array number
    // Return value:       true if the input is valid, and there are some duplications in the array number
    //                     otherwise false
    bool duplicate(int numbers[], int length, int* duplication) {
        if(numbers == nullptr || length <= 0) return false;
        for(int i = 0; i < length; ++i){
            for(int j = i + 1; j < length; ++j){
                if(numbers[i] == numbers[j]){
                    *duplication = numbers[i];
                    return true;
                }
            }
        }
        return false;
    }
};
```

#### 第3题：数组中的重复数组的排序解法

先把整个数组排序，然后依次比较相邻元素是否相等，因为有了排序，时间复杂度O(nlogn)，空间复杂度O(1)，代码就不放了

#### 第3题：数组中的重复数组的哈希解法

一次遍历即可，每次遍历在unordered_set（用哈希表实现）中寻找是否存在，若存在则重复，时间复杂度O(n)，空间复杂度O(n)

```c++
class Solution {
public:
    // Parameters:
    //        numbers:     an array of integers
    //        length:      the length of array numbers
    //        duplication: (Output) the duplicated number in the array number
    // Return value:       true if the input is valid, and there are some duplications in the array number
    //                     otherwise false
    bool duplicate(int numbers[], int length, int* duplication) {
        if(numbers == nullptr || length <= 0) return false;
        unordered_set<int> s;
        for(int i = 0; i < length; ++i){
            if(s.find(numbers[i]) == s.end()){
                s.insert(numbers[i]);
            }
            else{
                *duplication = numbers[i];
                return true;
            }
        }
        return false;
    }
};
```

#### 第3题：数组中的重复数组的交换解法

数组的长度为 n 且所有数字都在 0 到 n-1 的范围内，我们可以将每次遇到的数进行 "归位"，当某个数发现自己的 "位置" 被相同的数占了，则出现重复。

扫描整个数组，当扫描到下标为 i 的数字时，首先比较该数字（m）是否等于 i，如果是，则接着扫描下一个数字；如果不是，则拿 m 与第 m 个数比较。如果 m 与第 m 个数相等，则说明出现重复了；如果 m 与第 m 个数不相等，则将 m 与第 m 个数交换，将 m "归位"，再重复比较交换的过程，直到发现重复的数

尽管代码中有双重循环，但每个数字最多只要交换两次就能找到属于它的位置，因此总的时间复杂度：O(n)，空间复杂度：O(1)

```c++
class Solution {
public:
    // Parameters:
    //        numbers:     an array of integers
    //        length:      the length of array numbers
    //        duplication: (Output) the duplicated number in the array number
    // Return value:       true if the input is valid, and there are some duplications in the array number
    //                     otherwise false
    bool duplicate(int numbers[], int length, int* duplication) {
        if(numbers == nullptr || length <= 0) return false;
        for(int i = 0; i < length; ++i){
            if(i == numbers[i]) continue;
            while(i != numbers[i]){
                if(numbers[i] == numbers[numbers[i]]){
                    *duplication = numbers[i];
                    return true;
                }
                swap(numbers[i], numbers[numbers[i]]);
            }
        }
        return false;
    }
};
```

### 不修改数组找出重复的数字

题目：在一个长度为n+1的数组里的所有数字都在1到n的范围内，所以数组中至少有一个数字是重复的。请找出数组中任意一个重复的数字，但不能修改输入的数组。例如，如果输入长度为8的数组{2, 3, 5, 4, 3, 2, 6, 7}，那么对应的出是重复的数字2或者3。

思路：

用哈希表当然可以实现O(n)时间复杂度的算法，辅助空间为O(n)，但是没有充分考虑到数组的特点，实际上我们可以用O(n)的辅助空间数组来实现O(n)时间复杂度的算法，注意到值为1~n的数字存在于长度为n+1的数组中，对数组遍历，每次把当前元素m值复制到辅助空间下标为m的位置，这样很容易发现哪个数字是重复的。

但是如果题目要求辅助空间为O(1)怎么办呢？这里有个好方法，把1~n的数字从中间的数字m分为两部分，前面一半为1~m，后面一般为m+1~n，如果1~m的数字的数目超过m，那么这个区间里面一定包含重复元素，否则另一半m+1~n区间里面一定包含重复元素，继续把包含元素的区间一分为二，这个过程和二分查找很相似，只是多了一层统计区间里的数字数目。二分查找耗时O(logn)，每次统计需要O(n)，所以总的时间复杂度为O(nlogn)，但空间复杂度为O(1)，这种算法相当于以空间换时间。

```c++
int getDuplication(const int* numbers, int length)
{
    if(numbers == nullptr || length <= 0)
        return -1;

    int start = 1;
    int end = length - 1;
    while(end >= start)
    {
        int middle = ((end - start) >> 1) + start;
        int count = countRange(numbers, length, start, middle);
        if(end == start)
        {
            if(count > 1)
                return start;
            else
                break;
        }

        if(count > (middle - start + 1))
            end = middle;
        else
            start = middle + 1;
    }
    return -1;
}

int countRange(const int* numbers, int length, int start, int end)
{
    if(numbers == nullptr)
        return 0;

    int count = 0;
    for(int i = 0; i < length; i++)
        if(numbers[i] >= start && numbers[i] <= end)
            ++count;
    return count;
}
```

### 第4题：二维数组中的查找

在一个二维数组中（每个一维数组的长度相同），每一行都按照从左到右递增的顺序排序，每一列都按照从上到下递增的顺序排序。请完成一个函数，输入这样的一个二维数组和一个整数，判断数组中是否含有该整数。

首先选取右上角的数字，如果比target大，则最右列可以排除，列数减一，形成新二维数组，如果比target小，则最上行可以排除，行数加一，形成新二维数组，重复这个过程，直到找到与target同样的数字，或者行数or列数超过界限。这种方法也可以从左下角开始，但是不能从左上角or右下角开始，因为行列的排序关系。

时间复杂度：O(行+列)，空间复杂度O(1)

```c++
bool Find(int* matrix, int rows, int columns, int number)
{
    bool found = false;

    if(matrix != nullptr && rows > 0 && columns > 0)
    {
        int row = 0;
        int column = columns - 1;
        while(row < rows && column >=0)
        {
            if(matrix[row * columns + column] == number)
            {
                found = true;
                break;
            }
            else if(matrix[row * columns + column] > number)
                -- column;
            else
                ++ row;
        }
    }

    return found;
}
```

## 字符串

### 面试题5：替换空格

题目：请实现一个函数，把字符串中的每个空格替换成"%20"。例如输入“We are happy.”，则输出“We%20are%20happy.”。

朴素思路：原地操作，从前往后遍历，每次遇到空格则把后面的字符全部往后移两位，这样的时间效率很差，为O(n^2)

思路：原地操作，首先一次遍历统计字符串中的空格数量，可以知道每个空格需要增长两个单位的长度，计算新字符串的长度，双指针p、q，p指向原字符串末尾，q指向新字符串末尾，p、q同时向前移动，如果p所指字符不是空格，则直接复制给q所指位置，如果p所指字符是空格，则q依次赋值前移'0', '2', '%'（反向的），直至两个指针到头

注意：字符串是以'\0'结尾的，它是隐藏的，使得字符串长度+1

```c++
/*length 为字符数组str的总容量，大于或等于字符串str的实际长度*/
void ReplaceBlank(char str[], int length)
{
    if(str == nullptr && length <= 0)
        return;

    /*originalLength 为字符串str的实际长度*/
    int originalLength = 0;
    int numberOfBlank = 0;
    int i = 0;
    while(str[i] != '\0')
    {
        ++ originalLength;

        if(str[i] == ' ')
            ++ numberOfBlank;

        ++ i;
    }

    /*newLength 为把空格替换成'%20'之后的长度*/
    int newLength = originalLength + numberOfBlank * 2;
    if(newLength > length)
        return;

    int indexOfOriginal = originalLength;
    int indexOfNew = newLength;
    while(indexOfOriginal >= 0 && indexOfNew > indexOfOriginal)
    {
        if(str[indexOfOriginal] == ' ')
        {
            str[indexOfNew --] = '0';
            str[indexOfNew --] = '2';
            str[indexOfNew --] = '%';
        }
        else
        {
            str[indexOfNew --] = str[indexOfOriginal];
        }

        -- indexOfOriginal;
    }
}
```

#### 双指针的举一反三

如果有两个已排序的数组A1和A2，内存在A1的末尾有足够多的空余空间容纳A2，请实现一个函数，把A2中的所有数字插入到Al中并且所有的数字是排序的。和前面的例题一样，很多人首先想到的办法是在A1中从头到尾复制数字，但这样就会出现多次复制一个数字的情况。更好的办法是从尾到头比较A1和A2中的数字，并把较大的数字复制到A1的合适位置。

合并两个数组（包括字符串）时，如果从前往后复制每个数字（或字符）需要重复移动数字（或字符）多次，那么我们可以考虑从后往前复制，这样就能减少移动的次数，从而提高效率。

## 链表

链表应该是面试时被提及最频繁的数据结构。链表的结构很简单，它由指针把若干个结点连接成链状结构。链表的创建、插入结点、删除结点等操作都只需要20行左右的代码就能实现，其代码量比较适合面试。而像哈希表、有向图等复杂数据结构，实现它们的一个操作需要的代码量都较大，很难在几十分钟的面试中完成。另外，由于链表是一种动态的数据结构，其操作需要对指针进行操作，因此应聘者需要有较好的编程功底才能写出完整的操作链表的代码。而且链表这种数据结构很灵活，面试官可以用链表来设计具有挑战性的面试题。基于上述几个原因，很多面试官都特别青睐链表相关的题目。

```c++
struct ListNode [
    int m_nValue;
    ListNode* m_pNext;
};
```

那么往该链表的末尾中添加一个结点的C语言代码如下：

```c++
void AddToTail (ListNode** pHead, int value){
    ListNode* pNew = new ListNode();
    pNew->m_nValue = value;
    pNew->m_pNext = NULL;
    if (*pHead == NULL)
        *pHead = pNew;
    else{
        ListNode* pNode = *pHead;
        while (pNode->m_pNext != NULL)
            pNode =pNode->m_pNext;
        pNode->m_pNext = pNew;
    }
}
```

在上面的代码中，我们要特别注意函数的第一个参数pHead是一个指向指针的指针。当我们往一个空链表中插入一个结点时，新插入的结点就是链表的头指针。**由于此时会改动头指针，因此必须把pHead参数设为指向指针的指针，否则出了这个函数pHead仍然是一个空指针**。

### 面试题6：从尾到头打印链表

输入一个链表，按链表从尾到头的顺序返回一个ArrayList。

书本上是使用栈，但牛客网的题目是返回一个vector，所以就不用栈了

```c++
/**
*  struct ListNode {
*        int val;
*        struct ListNode *next;
*        ListNode(int x) :
*              val(x), next(NULL) {
*        }
*  };
*/
class Solution {
public:
    vector<int> printListFromTailToHead(ListNode* head) {
        vector<int> vec;
        if(head == nullptr) return vec;
        while(head != nullptr){
            vec.push_back(head->val);
            head = head->next;
        }
        reverse(vec.begin(), vec.end());
        return vec;
    }
};
```

## 树

### 面试题7：重建二叉树

输入某二叉树的前序遍历和中序遍历的结果，请重建出该二叉树。假设输入的前序遍历和中序遍历的结果中都不含重复的数字。例如输入前序遍历序列{1,2,4,7,3,5,6,8}和中序遍历序列{4,7,2,1,5,3,8,6}，则重建二叉树并返回。

思路：在二叉树的前序遍历序列中，第一个数字总是树的根结点的值。但在中序遍历序列中，根结点的值在序列的中间，左子树的结点的值位于根结点的值的左边，而右子树的结点的值位于根结点的值的右边。因此我们需要扫描中序遍历序列，才能找到根结点的值。既然我们已经分别找到了左、右子树的前序遍历序列和中序遍历序列，我们可以用同样的方法分别去构建左右子树。也就是说，接下来的事情可以用递归的方法去完成。

```c++
/**
 * Definition for binary tree
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class Solution {
public:
    TreeNode* reConstructBinaryTree(vector<int> pre,vector<int> vin) {
        if(pre.empty() || vin.empty()) return nullptr;
        return helper(pre.begin(), pre.end()-1, vin.begin(), vin.end()-1);
    }

    TreeNode* helper(vector<int>::iterator pre_first, vector<int>::iterator pre_last,
                vector<int>::iterator vin_first, vector<int>::iterator vin_last){
        TreeNode* root = new TreeNode(*pre_first);
        if(pre_first == pre_last){
            return root;
        }
        auto root_inorder = find(vin_first, vin_last, root->val);
        auto left_len = root_inorder - vin_first; // nodes number in left subtree
        auto left_pre_last = pre_first + left_len;
        if((int)left_len > 0){ //  we do have several nodes in left subtree
            // construct left subtree
            root->left = helper(pre_first+1, left_pre_last, vin_first, root_inorder-1);
        }
        if(left_len < pre_last - pre_first){ // Do we have any nodes in right subtree?
            // construct right subtree
            root->right = helper(left_pre_last+1, pre_last, root_inorder+1, vin_last);
        }
        return root;
    }
};
```

## 栈和队列

栈是一个非常常见的数据结构，它在计算机领域中被广泛应用，比如操作系统会给每个线程创建一个栈用来存储函数调用时各个函数的参数、返回地址及临时变量等。栈的特点是后进先出，即最后被压入（push）栈的元素会第一个被弹出（pop），在面试题22“栈的压入、弹出序列”中，我们再详细分析进栈和出栈序列的特点。

通常栈是一个不考虑排序的数据结构，我们需要O（m）时间才能找到栈中最大或者最小的元素。如果想要在O（1）时间内得到栈的最大或者最小值，我们需要对栈做特殊的设计，详见面试题21“包含min函数的栈”。

队列是另外一种很重要的数据结构。和栈不同的是，队列的特点是先进先出，即第一个进入队列的元素将会第一个出来。在2.3.4节介绍的树的宽度优先遍历算法中，我们在遍历某一层树的结点时，把结点的子结点放到一个队列里，以备下一层结点的遍历。详细的代码参见面试题23“从上

### 面试题7：用两个栈实现队列

题目：用两个栈实现一个队列。队列的声明如下，请实现它的两个函数appendTail和deleteHead，分别完成在队列尾部插入结点和在队列头部删除结点的功能。

stack2作为辅助栈，每当要pop时，若为空，则把stack1倒腾过来，栈顶即为队列尾，弹出即可，若不为空，则栈顶为队列尾，弹出即可，注意C++的stack的pop没有返回值，需要先用top函数获取栈顶元素

```c++
class Solution
{
public:
    void push(int node) {
        stack1.push(node);
    }

    int pop() {
        int tail;
        if(!stack2.empty()){
            tail = stack2.top();
            stack2.pop();
        }
        else{
            while(!stack1.empty()){
                int temp = stack1.top();
                stack1.pop();
                stack2.push(temp);
            }
            tail = stack2.top();
            stack2.pop();
        }
        return tail;
    }

private:
    stack<int> stack1;
    stack<int> stack2;
};
```

## 算法和数据操作

和数据结构一样，考查算法的面试题也备受面试官的青睐，其中排序和查找是面试时考查算法的重点。在准备面试的时候，我们应该重点掌握二分查找、归并排序和快速排序，做到能随时正确、完整地写出它们的代码。

有很多算法都可以用递归和循环两种不同的方式实现。通常基于递归的实现方法代码会比较简洁，但性能不如基于循环的实现方法。在面试的时候，我们可以根据题目的特点，甚至可以和面试官讨论选择合适的方法编程。

如果面试题是求某个问题的最优解，而且该问题可以分为多个子问题，那么我们可以尝试用动态规划。

如果面试官还在提醒说在分解子问题时是不是存在某个特殊的选择，如果采用这样的特殊的选择将一定得到最优解，那么这就意味着这道题也可以用贪婪算法解决。

位运算可以看成是一类特殊的算法，它是把数字表示成二进制之后对0和1的操作。由于位运算的对象为二进制数字，所以不是很直观，但掌握它也不难，因为总共只有与、或、异或、左移和右移5种位运算。

## 递归和循环

如果我们需要重复地多次计算相同的问题，通常可以选择用递归或者循环两种不同的方法。递归是在一个函数的内部调用这个函数自身。而循环则是通过设置计算的初始值及终止条件，在一个范围内重复运算。

递归虽然有简洁的优点，但它同时也有显著的缺点。递归由于是函数调用自身，而函数调用是有时间和空间的消耗的：**每一次函数调用，都需要在内存栈中分配空间以保存参数、返回地址及临时变量，而且往栈里压入数据和弹出数据都需要时间**。

另外，递归中有可能很多计算都是重复的，从而对性能带来很大的负面影响。递归的本质是把一个问题分解成两个或者多个小问题。如果多个小问题存在相互重叠的部分，那么就存在重复的计算。在面试题9“斐波那契数列”及面试题43“n个骰子的点数”中我们将详细地分析递归和循环的性能区别。

除了效率之外，递归还有可能引起更严重的问题：**调用栈溢出**。前面分析中提到需要为每一次函数调用在内存栈中分配空间，而每个进程的栈的容量是有限的。当递归调用的层级太多时，就会超出栈的容量，从而导致调用栈溢出。

### 面试题10：斐波那契数列

大家都知道斐波那契数列，现在要求输入一个整数n，请你输出斐波那契数列的第n项（从0开始，第0项为0）。
n<=39

最朴素的递归，有很多不必要的重复计算，在牛客网超时了

```c++
class Solution {
public:
    int Fibonacci(int n) {
        if(n == 0) return 0;
        if(n == 1) return 1;
        return Fibonacci(n-1) + Fibonacci(n-2);
    }
};
```

循环解法，自下而上，还不错

```c++
class Solution {
public:
    int Fibonacci(int n) {
        if(n == 0) return 0;
        if(n == 1) return 1;
        int count = 2, prepre = 0, pre = 1, FibN;
        while(count <= n){
            FibN = prepre + pre;
            prepre = pre;
            pre = FibN;
            ++count;
        }
        return FibN;
    }
};
```

### 跳台阶

一只青蛙一次可以跳上1级台阶，也可以跳上2级。求该青蛙跳上一个n级的台阶总共有多少种跳法（先后次序不同算不同的结果）。

与第十题斐波那契数列一样，只不过初始值有变，这其实是一个动态规划的问题

```c++
class Solution {
public:
    int jumpFloor(int number) {
        if(number == 0) return 0;
        if(number == 1) return 1;
        if(number == 2) return 2;
        int prepre = 1, pre = 2, res = 0;
        for(int i = 3; i <= number; ++i){
            res = prepre + pre;
            prepre = pre;
            pre = res;
        }
        return res;
    }
};
```

### 变态跳台阶

一只青蛙一次可以跳上1级台阶，也可以跳上2级……它也可以跳上n级。求该青蛙跳上一个n级的台阶总共有多少种跳法。

这相当于f(n) = f(1) + ... + f(n-1)

```c++
class Solution {
public:
    int jumpFloorII(int number) {
        // f(n) = f(1) + .. + f(n)
        if(number == 1) return 1;
        if(number == 2) return 2;
        vector<int> dp;
        dp.push_back(1); // f(1), index = 0
        dp.push_back(2); // f(2), index = 1
        for(int i = 2; i < number; ++i){
            int sum = 0;
            for(int j = 0; j < i; ++j){
                sum += dp[j];
            }
            dp.push_back(sum);
        }
        return dp[number - 1];
    }
};
```

## 查找和排序

查找和排序都是在程序设计中经常用到的算法。查找相对而言较为简单，不外乎顺序查找、二分查找、哈希表查找和二叉排序树查找。在面试的时候，不管是用循环还是用递归，面试官都期待应聘者能够信手拈来写出完整正确的二分查找代码，否则可能连继续面试的兴趣都没有。面试题8“旋转数组的最小数字”和面试题38“数字在排序数组中出现的次数”都可以用二分查找算法解决。

如果面试题是要求在排序的数组（或者部分排序的数组）中查找一个数字或者统计某个数字出现的次数，我们都可以尝试用二分查找算法。
哈希表和二叉排序树查找的重点在于考查对应的数据结构而不是算法。哈希表最主要的优点是我们利用它能够在0（1）时间查找某一元素，是效率最高的查找方式。但其缺点是需要额外的空间来实现哈希表。面试题35“第一个只出现一次的字符”就是用哈希表的特性来高效查找。与二叉排序树查找算法对应的数据结构是二叉搜索树，我们将在面试题24“二叉搜索树的后序遍历序列”和面试题27“二叉搜索树与双向链表”中详细介绍二叉搜索树的特点。

排序比查找要复杂一些。面试官会经常要求应聘者比较插入排序、冒泡排序、归并排序、快速排序等不同算法的优劣。强烈建议应聘者在准备面试的时候，一定要对各种排序算法的特点烂熟于胸，能够从额外空间消耗、平均时间复杂度和最差时间复杂度等方面去比较它们的优缺点。需要特别强调的是，很多公司的面试官喜欢在面试环节中要求应聘者写出快速排序的代码。应聘者不妨自己写一个快速排序的函数并用各种数据作测试。
当测试都通过之后，再和经典的实现做比较，看看有什么区别。

### 面试题11：旋转数组的最小值

把一个数组最开始的若干个元素搬到数组的末尾，我们称之为数组的旋转。输入一个非递减排序的数组的一个旋转，输出旋转数组的最小元素。例如数组{3,4,5,1,2}为{1,2,3,4,5}的一个旋转，该数组的最小值为1。NOTE：给出的所有元素都大于0，若数组大小为0，请返回0。

最朴素的解法当然是一次完整遍历，用时O(n)

考虑到这是一个旋转数组，可以先用O(logn)的时间找出旋转点，旋转点即为最小值，注意题目说了非递减，所以是有可能有相同元素的，所以要判断，有些测试用例非常坑，1 0 1 1 1 / 1 1 1 0 1

```c++
class Solution {
public:
    int minNumberInRotateArray(vector<int> rotateArray) {
        if(rotateArray.empty()) return 0;
        int len = rotateArray.size();
        int mid = 0, low = 0, high = len - 1;
        while(low < high){
            mid = (low + high) / 2;
            // 子数组是非递减的数组，10111
            if(rotateArray[low] < rotateArray[high]) return rotateArray[low];
            if(rotateArray[mid] > rotateArray[low]){
                low = mid + 1;
            }
            else if(rotateArray[mid] < rotateArray[high]){
                high = mid;
            }
            else{
                ++low;
            }
        }
        return rotateArray[low];
    }
};
```

## 回溯法

回溯法相当于暴力法的升级版

### 面试题12：矩阵中的路径

请设计一个函数，用来判断在一个矩阵中是否存在一条包含某字符串所有字符的路径。路径可以从矩阵中的任意一个格子开始，每一步可以在矩阵中向左，向右，向上，向下移动一个格子。如果一条路径经过了矩阵中的某一个格子，则该路径不能再进入该格子。 例如 a b c e s f c s a d e e 矩阵中包含一条字符串"bcced"的路径，但是矩阵中不包含"abcb"路径，因为字符串的第一个字符b占据了矩阵中的第一行第二个格子之后，路径不能再次进入该格子。

这题其实也算DFS，设置visited矩阵，当走过i，j点时，将此点设置为1，因为不能重复进入一个格子；如果第ij个点与path中的字符一样且未走过，则暂时进入这个格子；向四周搜寻下一步的走法，若无解，则证明上一个path路径不对，退回到前一个字符；若正确，则重复上述过程，返回haspath

```c++
class Solution {
public:
    bool hasPath(char* matrix, int rows, int cols, char* str)
    {
        if(matrix == nullptr || rows < 1 || cols < 1 || str == nullptr) return false;
        bool* visited = new bool[rows*cols];
        for(int i = 0; i < rows*cols; ++i){
            visited[i] = 0;
        }
        int pathLength = 0;
        for(int row = 0; row < rows; ++row){
            for(int col = 0; col < cols; ++col){
                if(hasPathCore(matrix, rows, cols, row, col, str, pathLength, visited)){
                    return true;
                }
            }
        }
        delete[] visited;
        return false;
    }
    bool hasPathCore(char* matrix, int rows, int cols, int row, int col, char* str, int& pathLength, bool* visited){
        if(str[pathLength] == '\0'){
            return true;
        }
        bool hasPath = false;
        if(row >= 0 && row < rows && col >= 0 && col < cols &&
           !visited[row*cols + col] && str[pathLength] == matrix[row*cols + col]){
            ++pathLength;
            visited[row*cols + col] = true;
            hasPath = hasPathCore(matrix, rows, cols, row-1, col, str, pathLength, visited) ||
                hasPathCore(matrix, rows, cols, row+1, col, str, pathLength, visited) ||
                hasPathCore(matrix, rows, cols, row, col-1, str, pathLength, visited) ||
                hasPathCore(matrix, rows, cols, row, col+1, str, pathLength, visited);
            if(!hasPath){
                --pathLength;
                visited[row*cols + col] = false;
            }
        }
        return hasPath;
    }
};
```

### 面试题13：机器人的运动范围

地上有一个m行和n列的方格。一个机器人从坐标0,0的格子开始移动，每一次只能向左，右，上，下四个方向移动一格，但是不能进入行坐标和列坐标的数位之和大于k的格子。 例如，当k为18时，机器人能够进入方格（35,37），因为3+5+3+7 = 18。但是，它不能进入方格（35,38），因为3+5+3+8 = 19。请问该机器人能够达到多少个格子？

仿照上题的回溯法或者叫DFS，几乎一样

```c++
class Solution {
public:
    int movingCount(int threshold, int rows, int cols)
    {
        if(threshold < 0 || rows < 1 || cols < 1) return 0;
        bool* visited = new bool[rows*cols];
        int number = rows*cols;
        for(int i = 0; i < number; ++i){
            visited[i] = false;
        }
        int count = 0;
        helper(threshold, rows, cols, 0, 0, &count, visited);
        delete[] visited;
        return count;
    }
    void helper(int threshold, int rows, int cols, int row, int col, int* count, bool* visited){
        if(row >= 0 && row < rows && col >=0 && col < cols &&
           !visited[row*cols+col]){
            if(!isOver(threshold, row, col)){
                visited[row*cols+col] = true;
                ++(*count);
                helper(threshold, rows, cols, row+1, col, count, visited);
                helper(threshold, rows, cols, row-1, col, count, visited);
                helper(threshold, rows, cols, row, col+1, count, visited);
                helper(threshold, rows, cols, row, col-1, count, visited);
            }
        }
    }
    bool isOver(int threshold, int row, int col){
        int sum = 0;
        while(row != 0){
            sum += row % 10;
            row = row / 10;
        }
        while(col != 0){
            sum += col % 10;
            col = col / 10;
        }
        return sum > threshold ? true : false;
    }
};
```

## 动态规划和贪婪算法

动态规划四大特点：

1. 求一个问题的最优解
2. 整体问题的最优解是依赖各个子问题的最优解
3. 把大问题分解成若干个小问题，这些小问题还有相互重叠的更小的子问题
4. 由于子问题重复出现，为避免重复运算，可以从下往上求解问题（大部分题目可以放在一维或二维数组里面），而从上往下分析问题

贪婪算法每一步都可以做出一个贪婪的选择，但是为什么这样的贪婪选择可以得到最优解，是需要用数学方式证明的

### 面试题14：剪绳子

给你一根长度为n的绳子，请把绳子剪成整数长的m段（m、n都是整数，n>1并且m>1），每段绳子的长度记为k[0],k[1],...,k[m]。请问k[0]xk[1]x...xk[m]可能的最大乘积是多少？例如，当绳子的长度是8时，我们把它剪成长度分别为2、3、3的三段，此时得到的最大乘积是18。

思路转载自：[动态规划or贪心算法--剪绳子/切割杆](https://blog.csdn.net/upupday19/article/details/79315885)

#### 剪绳子的动态规划

思路：

设f(n)代表长度为n的绳子剪成若干段的最大乘积，如果第一刀下去，第一段长度是i，那么剩下的就需要剪n-i，那么f(n)=max{f(i)f(n-i)}。而f(n)的最优解对应着f(i)和f(n-i)的最优解，假如f(i)不是最优解，那么其最优解和f(n-i)乘积肯定大于f(n)的最优解，和f(n)达到最优解矛盾，所以f(n)的最优解对应着f(i)和f(n-i)的最优解。首先，剪绳子是最优解问题，其次，大问题包含小问题，并且大问题的最优解包含着小问题的最优解，所以可以使用动态规划求解问题，并且从小到大求解，把小问题的最优解记录在数组中，求大问题最优解时就可以直接获取，避免重复计算。

n<2时，由于每次至少减一次，所以返回0。n=2时，只能剪成两个1，那么返回1。n=3时，可以剪成3个1，或者1和2，那么最大乘积是2。当n>3时，就可以使用公式进行求解。

f(4)=max{f(1)f(3), f(2)f(2)}
f(5)=max{f(1)f(4), f(2)f(3)}
...
f(n)=max{f(1)f(n-1), f(2)f(n-2), f(3)f(n-3), ..., f(i)(fn-i), ...}

因为需要保证f(i)f(n-i)不重复，就需要保证i<=n/2，这是一个限制条件，求1～n/2范围内的乘积，得到最大值

```c++
class Solution {
public:
    int cutRope(int number) {
        if(number == 2) return 1;
        if(number == 3) return 2;
        vector<int> dp = {0, 1, 2, 3};
        int cur_max = 0;
        int temp_product = 0;
        for(int i = 4; i <= number; ++i){
            int cur_max = 0;
            for(int j = 1; j < (i-j)/2 ; ++j){
                temp_product = dp[j] * dp[i-j];
                if(temp_product > cur_max){
                    cur_max = temp_product;
                }
            }
            dp[i] = cur_max; // 书本参考答案把这行放在了内层for循环里面，我觉得有点浪费，只需要在外层循环最后赋值即可
        }
        return dp[number];
    }
};
```

#### 剪绳子的贪婪算法

n<2时，返回0；n=2时，返回1；n=3时，返回2

根据数学计算，当n>=5时，2(n-2)>n，3(n-3)>n，这就是说，将绳子剪成2和(n-2)或者剪成3和(n-3)时，乘积大于不剪的乘积，因此需要把绳子剪成2或者3。并且3(n-3)>=2(n-2)，也就是说，当n>=5时，应该剪尽量多的3，可以使最后的乘积最大。对于长度是n的绳子，我们可以剪出n/3个3，剩余长度是1或者2，如果余数是1，就可以把1和最后一个3合并成4，那么4剪出两个2得到的乘积是4，比1*3大，因此这种情况下，需要将3的个数减少1，变成两个2；如果余数是2，那么无需做修改。

3^timesOf3 * 2^timesOf2

相比动态规划，计算更简便，但是需要一定的数学技巧。

```c++
class Solution {
public:
    int cutRope(int number) {
        if(number == 2) return 1;
        if(number == 3) return 2;
        int timesOf3 = number / 3;
        int timesOf2 = 0;
        int remainder = number % 3;
        if(remainder == 1){
            --timesOf3;
            ++++timesOf2;
        }
        else if(remainder == 2){
            ++timesOf2;
        }
        return pow(3, timesOf3) * pow(2, timesOf2);
    }
};
```

## 位运算

其实二进制的位运算并不是很难掌握，因为位运算总共只有五种运算：与、或、异或、左移和右移。

右移运算符m>>n表示把m右移n位。右移n位的时候，最右边的n位将被丢弃。但右移时处理最左边位的情形要稍微复杂一点。如果数字是一个无符号数值，则用0填补最左边的n位。如果数字是一个有符号数值，则用数字的符号位填补最左边的n位。也就是说如果数字原先是一个正数，则右移之后在最左边补n个0；如果数字原先是负数，则右移之后在最左边补n个1，C++编译器会自动根据是否带符号来决定是逻辑左移还是算术左移。下面是对两个8位有符号数作右移的例子：

```c++
00001010 >> 2 = 00000010
10001010 >> 3 = 11110001
```

面试题10“二进制中1的个数”就是直接考查位运算的例子，而面试题40“数组中只出现一次的数字”、面试题47“不用加减乘除做加法”等都是根据位运算的特点来解决问题。

### 面试题15：二进制中1的个数

输入一个整数，输出该数二进制表示中1的个数。其中负数用补码表示。

思路：

int型变量是32位的，当flag左移32次后会变为0，正好跳出循环，在循环内，每次判断n的二进制位上是否为1，结果存在count中，这样总共需要循环32次

```c++
class Solution {
public:
     int NumberOf1(int n) {
         if(n == 0) return 0;
         int count = 0;
         unsigned int flag = 1;
         while(flag){
             if(n & flag){
                 ++count;
             }
             flag = flag << 1;
         }
        return count;
     }
};
```

快速解法：

如果一个整数不为0，那么这个整数至少有一位是1。如果我们把这个整数减1，那么原来处在整数最右边的1就会变为0，原来在1后面的所有的0都会变成1(如果最右边的1后面还有0的话)。其余所有位将不会受到影响。

举个例子：一个二进制数1100，从右边数起第三位是处于最右边的一个1。减去1后，第三位变成0，它后面的两位0变成了1，而前面的1保持不变，因此得到的结果是1011.我们发现减1的结果是把最右边的一个1开始的所有位都取反了。这个时候如果我们再把原来的整数和减去1之后的结果做与运算，从原来整数最右边一个1那一位开始所有位都会变成0。如1100&1011=1000.也就是说，把一个整数减去1，再和原整数做与运算，会把该整数最右边一个1变成0.那么一个整数的二进制有多少个1，就可以进行多少次这样的操作。

与之前的解法相比，循环次数大大减少，有多少个1就有多少次循环

```c++
class Solution {
public:
     int NumberOf1(int n) {
         if(n == 0) return 0;
         int count = 0;
         while(n){
             ++count;
             n = (n-1) & n;
         }
        return count;
     }
};
```

结论：把一个整数减去1之后再和原来的整数做位与运算，得到的结果相当于是把整数的二进制表示中的最右边一个1变成0，很多二进制的问题都可以用这个思路解决。

## 高质量的代码

### 面试题16：数值的整数次方

给定一个double类型的浮点数base和int类型的整数exponent。求base的exponent次方。保证base和exponent不同时为0

我发现牛客网的测试用例竟然直接用pow函数就可以通过了。。

按照书上的要求：不能使用库函数，同时也不需要考虑大数的问题

要考虑exponent为负数和0的情况，也要考虑base为负数和0的情况，这里要搞清楚0的倒数怎么定义，0的0次方怎么定义，还有一个很容易忽视的点：**由于base是double型，不能直接用==判断**！牛客网的测试用例好像不需要检查这个，讨论区也没人提到这回事，最好的比较double/float的方法是这样的：

```c++
#include <math.h>
...
if(fabs(a - b) <= epsilon * fabs(a))
```

这里可以使用快速幂算法，当n为偶数，`a^n =（a^n/2）*（a^n/2）`，当n为奇数，`a^n = a^[(n-1)/2] * a^[(n-1)/2] * a`，时间复杂度O(logn)

```c++
class Solution {
public:
    double Power(double base, int exponent){
        if(exponent == 0) return 1.0;
        if(exponent == 1) return base;
        if(base == 0) return 0;
        double result = 0;
        if(exponent < 0){
            exponent = -exponent;
            result = PowerWithUnsignedExponent(base, exponent);
            result = 1.0 / result;
        }
        else{
            result = PowerWithUnsignedExponent(base, exponent);
        }
        return result;
    }
    double PowerWithUnsignedExponent(double base, int exponent) {
        if(exponent == 0){
            return 1.0;
        }
        if(exponent == 1){
            return base;
        }
        double result = Power(base, exponent >> 1);
        result *= result;
        if(exponent & 0x1){
            result *= base;
        }
        return result;
    }
};
```

快速幂的不用递归，用循环的方式也可以，毕竟递归用时更久

```c++
    double PowerWithUnsignedExponent(double base, int exponent) {
        int n = 1;
        double result = base;
        while(n < exponent-1){
            result *= result;
            n = n << 1;
        }
        for(int i = 0; i < exponent - n; ++i){
            result *= base;
        }
        return result;
    }
```

### 面试题17：打印从1到最大的n位数

题目：输入数字n，按顺序打印出从1最大的n位十进制数。比如输入3，则打印出1、2、3一直到最大的3位数即999

这个题目看起来很简单。我们看到这个问题之后，最容易想到的办法是先求出最大的n位数，然后用一个循环从1开始逐个打印。初看之下好像没有问题，但如果仔细分析这个问题，我们就能注意到面试官没有规定n的范围。当输入的n很大的时候，我们求最大的n位数是不是用整型（int）或者长整型（long long）都会溢出？也就是说我们需要考虑大数问题。这是面试官在这道题里设置的一个大陷阱。

经过前面的分析，我们很自然地想到解决这个问题需要表达一个大数。最常用也是最容易的方法是用字符串或者数组表达大数。接下来我们用字符串来解决大数问题。用字符串表示数字的时候，最直观的方法就是字符串里每个字符都是0‘到9，之间的某一个字符，用来表示数字中的一位。因为数字最大是n位的，因此我们需要一个长度为n+1的字符串（字符串中最后一个是结束符号“0‘）。当实际数字不够n位的时候，在字符串的前半部分补0。

首先我们把字符串中的每一个数字都初始化为0‘，然后每一次为字符串表示的数字加1，再打印出来。因此我们只需要做两件事：**一是在字符串表达的数字上模拟加法，二是把字符串表达的数字打印出来**。

我们注意到只有对“999。。99”1的时候，才会在第一个字符（下标为0）的基础上产生进位，而其他所有情况都不会在第一个字待上产生进位。
因此当我们发现在加1时第一个字符产生了进位，则已经是最大的n位数，此时Increment返回true，因此函数Print1 ToMaxONDigits中的while循环终止。如何在每一次增加1之后快速判断是不是到了最大的n位数是本题的一个小陷阱。下面是Increment函数的参考代码，它实现了用0（1）时间判断是不是已经到了最大的n位数：

接下来我们再考虑如何打印用字符串表示的数字。虽然库函数printf可以很方便就能打印一个字符串，但在本题中调用printf并不是最合适的解决方案。前面我们提到，当数字不够n位的时候，我们在数字的前面补0，打印的时候这些补位的0不应该打印出来。比如输入3的时候，数字98用字符串表示成“098”，如果直接打印出098，就不符合我们的习惯。为此我们定义了函数PrintNumber，在这个函数里，我们只有在碰到第一个非0的字符之后才开始打印，直至字符串的结尾。

```c++
bool IncrementWithoutOverflow(char *number, int n)
{
    bool carry = true;
    for (int i = n - 1; i >= 0; --i)
    {
        if (carry)
        {
            if (number[i] == '9')
            {
                if (i == 0)
                    return false;
                carry = true;
                number[i] = '0';
            }
            else
            {
                carry = false;
                ++number[i];
            }
        }
        if (!carry)
            break;
    }
    return true;
}

void PrintNumber(char *number)
{
    bool isBeginning0 = true;
    for (int i = 0; number[i] != '\0'; ++i)
    {
        if (isBeginning0 && number[i] == '0')
            continue;
        if (isBeginning0)
            isBeginning0 = false;
        cout << number[i];
    }
    cout << endl;
}

void Print1ToMaxOfNDigits(int n){
    char* number = new char[n+1];
    for(int i = 0; i < n; ++i){
        number[i] = '0';
    }
    number[n] = '\0';
    while(IncrementWithoutOverflow(number, n)){
        PrintNumber(number);
    }
}
```

上述思路虽然比较直观，但由于模拟了整数的加法，代码有点长。要在面试短短几十分钟时间里完整正确地写出这么长的代码，对很多应聘者而言不是一件容易的事情。接下来我们换一种思路来考虑这个问题。如果我们在数字前面补0的话，就会发现n位所有十进制数其实就是n个从0到9的全排列。也就是说，我们把数字的每一位都从0到9排列一遍，就得到了所有的十进制数。只是我们在打印的时候，数字排在前面的0我们不打印出来罢了。

全排列用递归很容易表达，数字的每一位都可能是0~9中的一个数，然后设置下一位。递归结束的条件是我们已经设置了数字的最后一位。

```c++
void helper(char* number, int n, int index){
    if(index + 1 == n){
        PrintNumber(number);
        return;
    }
    ++index;
    for(int i = 0; i < 10; ++i){
        number[index] = '0' + i;
        helper(number, n, index);
    }
}

void Print1ToMaxOfNDigits(int n){
    char* number = new char[n+1];
    for(int i = 0; i < n; ++i){
        number[i] = '0';
    }
    number[n] = '\0';
    for(int i = 0; i < 10; ++i){
        number[0] = '0' + i;
        helper(number, n, 0);
    }
}
```