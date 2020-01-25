# 不积跬步无以至千里

## 数组

### 面试题3-1：数组中的重复数组

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

### 面试题3-2：不修改数组找出重复的数字

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

### 面试题4：二维数组中的查找

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

### 面试题8：二叉树的下一个节点

给定一个二叉树和其中的一个结点，请找出中序遍历顺序的下一个结点并且返回。注意，树中的结点不仅包含左右子结点，同时包含指向父结点的指针。

思路：如果当前节点有右子树，那么下一个节点就是其右子树整棵树中最左的节点；当前节点没有右子树，如果当前节点是左儿子，则下一个节点就是其父亲；如果当前节点是右儿子，则判断父亲是否为左儿子，若为左儿子，则返回父亲，若是右儿子，则把当前节点设为父亲节点，继续往上判断，若直到根节点还没找到，则当前节点没有下一个节点

```c++
class Solution {
public:
    TreeLinkNode* GetNext(TreeLinkNode* pNode)
    {
        TreeLinkNode* nextNode;
        if(pNode->right){
            nextNode = pNode->right;
            while(nextNode->left){
                nextNode = nextNode->left;
            }
            return nextNode;
        }
        // pNode is has no right subtree
        if(!pNode->next) return nullptr;
        nextNode = pNode->next;
        // if pNode is left child
        if(pNode == nextNode->left){
            return nextNode;
        }
        // if pNode is right child
        while(nextNode->next && nextNode == nextNode->next->right){
            nextNode = nextNode->next;
        }
        if(!nextNode->next){
            return nullptr; // now nextNode is root, so no next node
        }
        return nextNode->next;
    }
};
```

## 栈和队列

栈是一个非常常见的数据结构，它在计算机领域中被广泛应用，比如操作系统会给每个线程创建一个栈用来存储函数调用时各个函数的参数、返回地址及临时变量等。栈的特点是后进先出，即最后被压入（push）栈的元素会第一个被弹出（pop），在面试题22“栈的压入、弹出序列”中，我们再详细分析进栈和出栈序列的特点。

通常栈是一个不考虑排序的数据结构，我们需要O（m）时间才能找到栈中最大或者最小的元素。如果想要在O（1）时间内得到栈的最大或者最小值，我们需要对栈做特殊的设计，详见面试题21“包含min函数的栈”。

队列是另外一种很重要的数据结构。和栈不同的是，队列的特点是先进先出，即第一个进入队列的元素将会第一个出来。在2.3.4节介绍的树的宽度优先遍历算法中，我们在遍历某一层树的结点时，把结点的子结点放到一个队列里，以备下一层结点的遍历。详细的代码参见面试题23“从上

### 面试题9：用两个栈实现队列

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

### 面试题10-1：斐波那契数列

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

### 面试题10-2：跳台阶

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

### 面试题10-3：变态跳台阶

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

### 面试题18-1：删除链表的节点

题目：给定单向链表的头指针和一个结点指针，定义一个函数在0（1）时间删除该结点。

在单向链表中删除一个结点，最常规的做法无疑是从链表的头结点开始，顺序遍历查找要删除的结点，并在链表中删除该结点。

之所以需要从头开始查找，是因为我们需要得到将被删除的结点的前面一个结点。在单向链表中，结点中没有指向前一个结点的指针，所以只好从链表的头结点开始顺序查找。

那是不是一定需要得到被删除的结点的前一个结点呢？答案是否定的。我们可以很方便地得到要删除的结点的下一结点。如果我们把下一个结点的内容复制到需要删除的结点上覆盖原有的内容，再把下一个结点删除，那是不是就相当于把当前需要删除的结点删除了？

### 面试题18-2：删除链表中的重复节点

在一个排序的链表中，存在重复的结点，请删除该链表中重复的结点，重复的结点不保留，返回链表头指针。 例如，链表1->2->3->3->4->4->5 处理后为 1->2->5

第一次尝试理解错了题意，以为是重复的删除，还保留一项，所以代码是这样写的

```c++
/*
struct ListNode {
    int val;
    struct ListNode *next;
    ListNode(int x) :
        val(x), next(NULL) {
    }
};
*/
class Solution {
public:
    ListNode* deleteDuplication(ListNode* pHead)
    {
        if(pHead == nullptr) return pHead;
        ListNode* pCur = pHead;
        ListNode* pNext = pHead->next;
        ListNode* pTemp = nullptr;
        while(pNext != nullptr){
            if(pCur->val == pNext->val){
                pCur->next = pNext->next;
                pTemp = pNext;
                delete pTemp;
                pNext = pCur->next;
            }
            else{
                pCur = pNext;
                pNext = pNext->next;
            }
        }
        return pHead;
    }
};
```

没有通过测试用例

```c++
用例:
{1,2,3,3,4,4,5}

对应输出应该为:

{1,2,5}

你的输出为:

{1,2,3,4,5}
```

经过一些修改，代码如下，可通过，但感觉不够优美，链表的题目要考虑各种情况，需要很细心！

```c++
/*
struct ListNode {
    int val;
    struct ListNode *next;
    ListNode(int x) :
        val(x), next(NULL) {
    }
};
*/
class Solution {
public:
    ListNode* deleteDuplication(ListNode* pHead)
    {
        if(pHead == nullptr) return pHead;
        if(pHead->next == nullptr) return pHead;
        ListNode* pPre = nullptr;
        ListNode* pCur = pHead;
        ListNode* pNext = pHead->next;
        ListNode* pTemp = nullptr;
        while(pNext != nullptr){
            if(pCur->val == pNext->val){
                while(pCur->val == pNext->val){
                    pCur->next = pNext->next;
                    pTemp = pNext;
                    delete pTemp;
                    pNext = pCur->next;
                    if(pNext == nullptr){
                        if(pPre == nullptr){
                            pHead = nullptr;
                        }
                        else{
                            pPre->next = nullptr;
                        }
                        return pHead;
                    }
                }
                if(pPre == nullptr){
                    pHead = pNext;
                }
                else{
                    pPre->next = pNext;
                }
                pCur = pNext;
                pNext = pCur->next;
            }
            else{
                pPre = pCur;
                pCur = pNext;
                pNext = pNext->next;
            }
        }
        return pHead;
    }
};
```

### 面试题19：正则表达式匹配

请实现一个函数用来匹配包括'.'和'`*`'的正则表达式。模式中的字符'.'表示任意一个字符，而'`*`'表示它前面的字符可以出现任意次（包含0次）。 在本题中，匹配是指字符串的所有字符匹配整个模式。例如，字符串"aaa"与模式"a.a"和"`ab*ac*a`"匹配，但是与"aa.a"和"`ab*a`"均不匹配

第一次尝试：

```c++
class Solution {
public:
    bool match(char* str, char* pattern)
    {
        if(str == nullptr || pattern == nullptr) return false;
        if(*str == '\0' && *pattern == '\0') return true;
        while(*str != '\0' && *pattern != '\0'){
            if(*(pattern+1) == '*'){
                if(*pattern = '.' || *str == *pattern){
                    while(*str == *(str+1)){
                        ++str;
                    }
                    ++str;
                }
                ++++pattern;
            }
            else if(*pattern == '.'){
                ++str;
                ++pattern;
            }
            else if(*str != *pattern){
                return false;
            }
            else{
                ++str;
                ++pattern;
            }
        }
        if(*str == '\0' && *pattern == '\0'){
            return true;
        }
        return false;
    }
};
```

对于测试用例：`""`,`".*"`，没法通过，原因是我的代码让`*`把`'`匹配完了，而实际上`*`是可以匹配**任意**多个字符的，这个测试用例`*`匹配0个字符即可

看来自己想的还是有疏忽，关键在于`*`的匹配次数，很明显这里不能用线性的循环去做，应该要用迭代的方式去进行，应该用到了回溯法的思想

完整思路：

当模式中的第二个字符不是“*”时：

1、如果字符串第一个字符和模式中的第一个字符相匹配，那么字符串和模式都后移一个字符，然后匹配剩余的。match(str+1, pattern+1)

2、如果 字符串第一个字符和模式中的第一个字符相不匹配，直接返回false。

而当模式中的第二个字符是“*”时：如果字符串第一个字符跟模式第一个字符不匹配，则模式后移2个字符，继续匹配。如果字符串第一个字符跟模式第一个字符匹配，可以有3种匹配方式：

1、模式后移2字符，相当于x*被忽略；match(str, pattern+2)

2、字符串后移1字符，模式后移2字符；match(str+1, pattern+2)

3、字符串后移1字符，模式不变，即继续匹配字符下一位，因为*可以匹配多位；match(str+1, pattern)

注意到，第一个字符为空，第二个字符不空，还是可能匹配成功的，比如第二个字符串是`a*a*a*a*`”`,由于‘*’之前的元素可以出现0次，所以有可能匹配成功

```c++
class Solution {
public:
    bool match(char* str, char* pattern)
    {
        if(str == nullptr || pattern == nullptr) return false;
        if(*str == '\0' && *pattern == '\0') return true;
        if(*str != '\0' && *pattern == '\0') return false;
        if(*(pattern+1) == '*'){
            if((*str != '\0' && *pattern == '.') || *str == *pattern){
                return match(str, pattern+2) || match(str+1, pattern) || match(str+1, pattern+2);
            }
            else{
                return match(str, pattern+2);
            }
        }
        else{
            if((*str != '\0' && *pattern == '.') || *str == *pattern){
                return match(str+1, pattern+1);
            }
        }
        return false;
    }
};
```

### 面试题20：表示数值的字符串

请实现一个函数用来判断字符串是否表示数值（包括整数和小数）。例如，字符串"+100","5e2","-123","3.1416"和"-1E-16"都表示数值。 但是"12e","1a3.14","1.2.3","+-5"和"12e+4.3"都不是。

思路：首先要想到所有的情况，然后进行分类讨论。-123.45e-67

+-号后面必定为数字或后面为.（-.123 = -0.123）
+-号只出现在第一位或在eE的后一位
.后面必定为数字或为最后一位（233. = 233.0）
eE后面必定为数字或+-号

```c++
class Solution {
public:
    bool isNumeric(char* string)
    {
        if(string == nullptr || *string == '\0') return false;
        if(*string == '+' || *string == '-') ++string;
        bool isPreNum = scanUnsignedInterger(&string);
        // 小数部分
        if(*string == '.'){
            ++string;
            // 用|| 的原因
            // 1. 小数可以没有整数部分，.123
            // 2. 小数点后面可以没有数字， 233.
            // 3. 小数点前后都可以有数字
            isPreNum = scanUnsignedInterger(&string) || isPreNum;
        }
        // 指数部分
        if(*string == 'e' || *string == 'E'){
            ++string;
            // 用&&的原因
            // 1. e/E前面没有数字时，非法，.e1、e1
            // 2. e/E后面没有整数时，非法，12e、12e+5.4
            if(*string == '+' || *string == '-') ++string;
            isPreNum = isPreNum && scanUnsignedInterger(&string);
        }
        return isPreNum && *string == '\0';
    }
    bool scanUnsignedInterger(char** string){
        bool flag = false;
        while(**string != '\0' && **string >= '0' && **string <= '9'){
            ++(*string);
            flag = true;
        }
        return flag;
    }
};
```

### 面试题21：调整数组顺序使奇数位于偶数前面

输入一个整数数组，实现一个函数来调整该数组中数字的顺序，使得所有的奇数位于数组的前半部分，所有的偶数位于数组的后半部分，并保证奇数和奇数，偶数和偶数之间的相对位置不变。（书上的源尸体没有相对位置不变这个限制）

原题没有“并保证奇数和奇数，偶数和偶数之间的相对位置不变”这一限制，最好的方法就是用双指针法，类似快速排序中的partition的做法，两个指针一个从左往右，一个从右往左，都找到第一个需要调换的位置，如果两个指针交叉则结束，这种方法很容易扩展，只需要把判断奇偶性的做法单独拎出来成一个函数，可以实现各种效果，比如所有负数在前面，所有非负数在后面；比如能被3整除的在前面，能被3整除的在后面

```c++
class Solution {
public:
    void reOrderArray(vector<int> &array) {
        if(array.empty()) return;
        int len = array.size();
        int low = 0;
        int high = len - 1;
        while(low < high){
            while(low < high && (array[low] & 1) == 1){
                ++low;
            }
            while(low < high && (array[high] & 1) == 0){
                --high;
            }
            if(low >= high){
                break;
            }
            swap(array[low], array[high]);
            ++low;
            --high;
        }
    }
};

但是如果有了稳定性的限制，这种双指针法就不奏效了，这种类似快速排序的partition做法是典型的不稳定性的

针对牛客网的题目，第一次尝试，构建O(n)的辅助数组，把原数组复制进来，定义指针low与high，分别指向数组要存放的奇数和偶数，low从0开始，high从len-1开始，对辅助数组一次遍历，每次判断奇偶性，若为奇数，则放在array[low]，low自增，若为奇数，则放在array[high]，high自减，为了保持偶数之间的相对位置不变，最后需要对偶数翻转，这种做法空间复杂度为O(n)，时间复杂度为O(n)

```c++
class Solution {
public:
    void reOrderArray(vector<int> &array) {
        if(array.empty()) return;
        int len = array.size();
        vector<int> temp;
        for(int i = 0; i < len; ++i){
            temp.push_back(array[i]);
        }
        int low = 0;
        int high = len - 1;
        for(int i = 0; i < len; ++i){
            if((temp[i] & 1) == 0){ // 位运算求奇偶性，必须要有括号，否则先判断1==0
                array[high] = temp[i];
                --high;
            }
            else{
                array[low] = temp[i];
                ++low;
            }
        }
        reverse(array.begin()+low, array.end());
    }
};
```

还有一种方法，需要用时O(n^2)，但只需要O(1)辅助空间，一次遍历，每次碰到偶数，把它放到数组后面去，这样复杂度很高，vector数组需要借助erase和insert方法进行，由于时间复杂度很高，这种方法在牛客网超时了

```c++
class Solution {
public:
    void reOrderArray(vector<int> &array) {
        if(array.empty()) return;
        auto it = array.begin();
        auto end = array.end();
        int temp = 0;
        while(it != end){
            if((*it & 1) == 0){
                temp = *it;
                it = array.erase(it);
                array.push_back(temp);
                continue;
            }
            ++it;
        }
    }
};
```

仔细思考了一下原因，发现这里有个很常见的错误：**删除元素后迭代器失效**，while循环的判断条件应该改成`it != array.end()`才行

再提交了一下还是出错，在IDE里面debug时才发现，陷入了死循环！因为每次会把偶数插入在数组后面，迭代器又会访问它们，所以无穷无尽！

正确代码如下

```c++
class Solution {
public:
    void reOrderArray(vector<int> &array) {
        if(array.empty()) return;
        auto it = array.begin();
        int temp = 0;
        int count = array.size();
        while(count > 0 && it != array.end()){
            --count;
            if((*it & 1) == 0){
                temp = *it;
                it = array.erase(it);
                array.push_back(temp);
                continue;
            }
            ++it;
        }
    }
};
```

## 代码的鲁棒性

代码的鲁棒性鲁棒是英文Robust的音译，有时也翻译成健壮性。所谓的鲁棒性是指程序能够判断输入是否合乎规范要求，并对不合要求的输入予以合理的处理。

容错性是鲁棒性的一个重要体现。不鲁棒的软件在发生异常事件的时候，比如用户输入错误的用户名、试图打开的文件不存在或者网络不能连接，就会出现不可预见的诡异行为，或者干脆整个软件崩溃。这样的软件对于用户而言，不亚于一场灾难。

由于鲁棒性对软件开发非常重要，面试官在招聘的时候对应聘者写出的代码是否鲁棒也非常关注。提高代码的鲁棒性的有效途径是进行防御性编程。防御性编程是一种编程习惯，是指预见在什么地方可能会出现问题，并为这些可能出现的问题制定处理方式。比如试图打开文件时发现文件不存在，我们可以提示用户检查文件名和路径；当服务器连接不上时，我们可以试图连接备用服务器等。这样当异常情况发生时，软件的行为也尽在我们的掌握之中，而不至于出现不可预见的事情。

在面试时，最简单也最实用的防御性编程就是在函数入口添加代码以验证用户输入是否符合要求。通常面试要求的是写一两个函数，我们需要格外关注这些函数的输入参数。如果输入的是一个指针，那指针是空指针怎么办？如果输入的是一个字符串，那么字符串的内容为空怎么办？如果能把这些问题都提前考虑到，并做相应的处理，那么面试官就会觉得我们有防御性编程的习惯，能够写出鲁棒的软件。

当然并不是所有与鲁棒性相关的问题都只是检查输入的参数这么简单。我们看到问题的时候，要多问几个“如果不 那么。…”这样的问题。比如面试题15“链表中倒数第k个结点”，这里隐含着一个条件就是链表中结点的个数大于k。我们就要问如果链表中的结点的数目不是大于k个，那么代码会出什么问题？这样的思考方式能够帮助我们发现潜在的问题并提前解决问题。这比让面试官发现问题之后我们再去慌忙分析代码查找问题的根源要好得多。

### 面试题22：链表中倒数第k个结点

输入一个链表，输出该链表中倒数第k个结点。

第一把就AC了！难得啊！这里用到了栈，辅助空间O(n)，

```c++
/*
struct ListNode {
    int val;
    struct ListNode *next;
    ListNode(int x) :
            val(x), next(NULL) {
    }
};*/
class Solution {
public:
    ListNode* FindKthToTail(ListNode* pListHead, unsigned int k) {
        if(pListHead == nullptr) return nullptr;
        if(k <= 0) return nullptr;
        stack<ListNode*> stack;
        ListNode* pCur = pListHead;
        while(pCur != nullptr){
            stack.push(pCur);
            pCur = pCur->next;
        }
        while(!stack.empty() && k > 0){
            if(k == 1){
                return stack.top();
            }
            stack.pop();
            --k;
        }
        return nullptr;
    }
};
```

但看了解答之后才发现，有一种更巧妙的快慢指针法。

为了实现只遍历链表一次就能找到倒数第k个结点，我们可以定义两个指针。第一个指针从链表的头指针开始遍历向前走k-1，第二个指针保持不动；从第k步开始，第二个指针也开始从链表的头指针开始遍历。由于两个指针的距离保持在k-1，当第一个（走在前面的）指针到达链表的尾结点时，第二个指针（走在后面的）指针正好是倒数第k个结点。

```c++
/*
struct ListNode {
    int val;
    struct ListNode *next;
    ListNode(int x) :
            val(x), next(NULL) {
    }
};*/
class Solution {
public:
    ListNode* FindKthToTail(ListNode* pListHead, unsigned int k) {
        if(pListHead == nullptr) return nullptr;
        if(k <= 0) return nullptr;
        ListNode* slow = pListHead;
        ListNode* fast = pListHead;
        int count = 0;
        while(fast != nullptr){
            fast = fast->next;
            ++count;
            if(count > k){
                slow = slow->next;
            }
        }
        if(count < k){
            return nullptr;
        }
        return slow;
    }
};
```

### 面试题23：链表中环的入口结点

给一个链表，若其中包含环，请找出该链表的环的入口结点，否则，输出null。

第一次尝试就AC了！不过用到了unordered_set这种哈希表结构，需要辅助空间O(n)，代码倒是非常简洁易懂

```c++
/*
struct ListNode {
    int val;
    struct ListNode *next;
    ListNode(int x) :
        val(x), next(NULL) {
    }
};
*/
class Solution {
public:
    ListNode* EntryNodeOfLoop(ListNode* pHead)
    {
        if(pHead == nullptr) return nullptr;
        unordered_set<ListNode*> set;
        ListNode* pCur = pHead;
        while(pCur != nullptr && set.find(pCur) == set.end()){
            set.insert(pCur);
            pCur = pCur->next;
        }
        if(pCur == nullptr){
            return nullptr;
        }
        else{
            return pCur;
        }
        return nullptr;
    }
};
```

接下来当然是考虑O(1)空间复杂度的解法，同样也可以用快慢指针做，具体分为以下三步：

1.判断链表中有环，利用两个指针，一块一慢，快指针每次走两步，最后相遇的节点一定在环中，若到末尾还不相遇，则没有环

2.得到环中节点的数目，相遇的节点在环中，从当前开始计数，走了多少步回来，就是环中节点的数目k

3.找到环中的入口节点，再让两个指针从头开始，其中一个指针先走k步（有点类似上一题链表倒数第k个节点），然后两者一起出发，相遇点即为环的入口

教材上的做法是把找逻辑分成两个函数，其中一个辅助函数用来返回快慢指针相遇的节点，如果不会相遇也就没环，则返回nullptr，然后针对是否有环执行上面的第2步、第3步，我这种做法放在一起了，更加紧凑，但也难懂一点

```c++
class Solution {
public:
    ListNode* EntryNodeOfLoop(ListNode* pHead)
    {
        if(pHead == nullptr) return nullptr;
        if(pHead->next == nullptr) return nullptr;
        ListNode* fast = pHead->next;
        ListNode* slow = pHead;
        int count = 0;
        bool hasMet = false;
        while(fast != nullptr && fast->next != nullptr){
            if(slow == fast){
                if(hasMet){
                    break;
                }
                else{
                    hasMet = true;
                }
            }
            slow = slow->next;
            if(hasMet){
                ++count;
            }
            else{
                fast = fast->next->next;
            }
        }
        if(hasMet){
            fast = pHead;
            slow = pHead;
            while(count > 0){
                fast = fast->next;
                --count;
            }
            while(slow != fast){
                slow = slow->next;
                fast = fast->next;
            }
            return slow;
        }
        return nullptr;
    }
};
```

### 面试题24：反转链表

输入一个链表，反转链表后，输出新链表的表头。

一次遍历就可以搞定吧，三个变量，next节点也必须知道，不然会断裂

```c++
/*
struct ListNode {
    int val;
    struct ListNode *next;
    ListNode(int x) :
            val(x), next(NULL) {
    }
};*/
class Solution {
public:
    ListNode* ReverseList(ListNode* pHead) {
        if(pHead == nullptr) return nullptr;
        if(pHead->next == nullptr) return pHead;
        ListNode* pPre = pHead;
        ListNode* pCur = pPre->next;
        ListNode* pNext = pCur->next;
        pPre->next = nullptr;
        while(pCur != nullptr){
            pCur->next = pPre;
            pPre = pCur;
            pCur = pNext;
            if(pCur == nullptr){
                break;
            }
            pNext = pCur->next;
        }
        return pPre;
    }
};
```

在面试的过程中，我们发现应聘者的代码中经常出现如下3种问题：

输入的链表头指针为NULL或者整个链表只有一个结点时，程序立即崩溃。

反转后的链表出现断裂。

返回的反转之后的头结点不是原始链表的尾结点。（第一次提交时就犯了这个错误，输出的是pCur，而pCur已经是nullptr了）

### 面试题25：合并两个排序的链表

输入两个单调递增的链表，输出两个链表合成后的链表，当然我们需要合成后的链表满足单调不减规则。

这是一个经常被各公司采用的面试题。在面试过程中，我们发现应聘者最容易犯两种错误：一是在写代码之前没有对合并的过程想清楚，最终合并出来的链表要么中间断开了要么并没有做到递增排序；二是代码在鲁棒性方面存在问题，程序一旦有特殊的输入（如空链表）就会崩溃。

我的做法是在while循环内判断，把小的接在cur后面，然后cur移到小的节点上去，pHeadx后移，直至到头，可以直接另一方剩下的接到cur后面，这种做法自认为还不错，书本用了递归，我觉得我的这种循环足够清晰了，没必要递归

```c++
/*
struct ListNode {
    int val;
    struct ListNode *next;
    ListNode(int x) :
            val(x), next(NULL) {
    }
};*/
class Solution {
public:
    ListNode* Merge(ListNode* pHead1, ListNode* pHead2)
    {
        if(pHead1 == nullptr) return pHead2;
        if(pHead2 == nullptr) return pHead1;
        ListNode* head = nullptr;
        ListNode* pCur = nullptr;
        if(pHead1->val < pHead2->val){
            head = pHead1;
            pCur = head;
            pHead1 = pHead1->next;
        }
        else{
            head = pHead2;
            pCur = head;
            pHead2 = pHead2->next;
        }
        while(pHead1 != nullptr && pHead2 != nullptr){
            if(pHead1->val < pHead2->val){
                pCur->next = pHead1;
                pCur = pHead1;
                pHead1 = pHead1->next;
            }
            else{
                pCur->next = pHead2;
                pCur = pHead2;
                pHead2 = pHead2->next;
            }
        }
        if(pHead1 != nullptr){
            pCur->next = pHead1;
        }
        if(pHead2 != nullptr){
            pCur->next = pHead2;
        }
        return head;
    }
};
```

### 面试题26：树的子结构

输入两棵二叉树A，B，判断B是不是A的子结构。（ps：我们约定空树不是任意一个树的子结构）

递归啊！！！！！！我这猪脑子怎么每次写不对递归！！！

```c++
/*
struct TreeNode {
    int val;
    struct TreeNode *left;
    struct TreeNode *right;
    TreeNode(int x) :
            val(x), left(NULL), right(NULL) {
    }
};*/
class Solution {
public:
    bool HasSubtree(TreeNode* pRoot1, TreeNode* pRoot2)
    {
        if(pRoot1 == nullptr || pRoot2 == nullptr) return false;
        bool flag = false;
        if(pRoot1->val == pRoot2->val){
            flag = DoesTree1HaveTree2(pRoot1, pRoot2);
        }
        if(!flag){
            flag = HasSubtree(pRoot1->left, pRoot2) || HasSubtree(pRoot1->right, pRoot2);
        }
        return flag;
    }
    bool DoesTree1HaveTree2(TreeNode* pRoot1, TreeNode* pRoot2){
        if(pRoot2 == nullptr) return true;
        if(pRoot1 == nullptr) return false;
        if(pRoot1->val == pRoot2->val){
            return DoesTree1HaveTree2(pRoot1->left, pRoot2->left) && DoesTree1HaveTree2(pRoot1->right, pRoot2->right);
        }
        return false;
    }
};
```

## 画图让抽象问题形象化

### 面试题27：二叉树的镜像

操作给定的二叉树，将其变换为源二叉树的镜像。

思路：交换左右儿子再左右递归即可，书上给的代码略微臃肿，我在牛客网的代码第一次就AC了，应该没问题

```c++
class Solution {
public:
    void Mirror(TreeNode *pRoot) {
        if(pRoot == nullptr) return;
        swap(pRoot->left, pRoot->right);
        Mirror(pRoot->left);
        Mirror(pRoot->right);
    }
};
```

如果不给用迭代要怎么办呢，单单只用一个while循环是没法做到的，因为二叉树不是线性的，要分叉，可以使用一个队列辅助完成，这有点像BFS的味道了

```c++
class Solution {
public:
    void Mirror(TreeNode *pRoot) {
        if(pRoot == nullptr) return;
        queue<TreeNode*> q;
        q.push(pRoot);
        TreeNode* tempNode;
        while(!q.empty()){
            tempNode = q.front();
            q.pop();
            swap(tempNode->left, tempNode->right);
            if(tempNode->left != nullptr){
                q.push(tempNode->left);
            }
            if(tempNode->right != nullptr){
                q.push(tempNode->right);
            }
        }
    }
};
```

当然也可以用栈来模拟DFS

```c++
class Solution {
public:
    void Mirror(TreeNode *pRoot) {
        if(pRoot == nullptr) return;
        stack<TreeNode*> s;
        s.push(pRoot);
        TreeNode* tempNode;
        while(!s.empty()){
            tempNode = s.top();
            s.pop();
            swap(tempNode->left, tempNode->right);
            if(tempNode->left != nullptr){
                s.push(tempNode->left);
            }
            if(tempNode->right != nullptr){
                s.push(tempNode->right);
            }
        }
    }
};
```

### 面试题28：对称的二叉树

请实现一个函数，用来判断一颗二叉树是不是对称的。注意，如果一个二叉树同此二叉树的镜像是同样的，定义其为对称的。

思路：画图观察对称的二叉树，发现稍稍改动遍历方法就可以实现要求，在这里选择前序遍历，遍历顺序是当前节点-左儿子-右儿子，而对称的前序遍历顺序是当前节点-右儿子-左儿子

书本代码并没有用到辅助数组空间，而是递归，，每次递归检查同样深度的对称的两项，这种思路我刚开始没想到，递归也可以传入两个节点，比较后再递归子节点

```c++
class Solution {
public:
    bool isSymmetrical(TreeNode* pRoot)
    {
        return helper(pRoot, pRoot);
    }
    bool helper(TreeNode* pRoot1, TreeNode* pRoot2){
        if(pRoot1 == nullptr && pRoot2 == nullptr) return true;
        if(pRoot1 == nullptr || pRoot2 == nullptr) return false;
        if(pRoot1->val != pRoot2->val) return false;
        return helper(pRoot1->left, pRoot2->right) && helper(pRoot1->right, pRoot2->left);
    }
};
```

同理这里也可以用queue模拟的BFS来做，这样就从迭代改为了循环，入队和出队都是两个元素一起

```c++
class Solution {
public:
    bool isSymmetrical(TreeNode* pRoot)
    {
        if(pRoot == nullptr) return true;
        queue<TreeNode*> q;
        q.push(pRoot->left);
        q.push(pRoot->right);
        TreeNode* temp1 = nullptr;
        TreeNode* temp2 = nullptr;
        while(!q.empty()){
            temp1 = q.front();
            q.pop();
            temp2 = q.front();
            q.pop();
            if(temp1 == nullptr && temp2 == nullptr) continue;
            if(temp1 == nullptr || temp2 == nullptr) return false;
            if(temp1->val != temp2->val) return false;
            q.push(temp1->left);
            q.push(temp2->right);
            q.push(temp1->right);
            q.push(temp2->left);
        }
        return true;
    }
};
```

### 面试题29：顺时针打印矩阵

输入一个矩阵，按照从外向里以顺时针的顺序依次打印出每一个数字，例如，如果输入如下4 X 4矩阵： 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 则依次打印出数字1,2,3,4,8,12,16,15,14,13,9,5,6,7,11,10.

思路：没别的，从外圈向内圈打印，注意边界情况！！！！

```c++
class Solution {
public:
    vector<int> printMatrix(vector<vector<int> > matrix) {
        vector<int> res;
        int row = matrix.size();
        if(row == 0) return res;
        int col = matrix[0].size();
        if(col == 0) return res;
        int left = 0;
        int right = col - 1;
        int up = 0;
        int down = row - 1;
        int i, j;
        while(left <= right && up <= down){
            for(i = up, j = left; i <= down && j <= right; ++j){
                res.push_back(matrix[i][j]);
            }
            ++up;
            for(i = up, j = right; i <= down && j >= left; ++i){
                res.push_back(matrix[i][j]);
            }
            --right;
            for(i = down, j = right; i >= up && j >= left; --j){
                res.push_back(matrix[i][j]);
            }
            --down;
            for(i = down, j = left; i >= up && j <= right; --i){
                res.push_back(matrix[i][j]);
            }
            ++left;
        }
        return res;
    }
};
```

### 面试题30：包含min函数的栈

定义栈的数据结构，请在该类型中实现一个能够得到栈中所含最小元素的min函数（时间复杂度应为O（1））。书上更要求min、push、pop的时间复杂度都为O(1)

首先想到，每压入一个元素就对所有元素排序，但是不符合栈的后进先出的原则；然后想到用一个变量来存储当前最小值，但是当恰好pop这个值时，没法直到次小值；于是我们要把次小值也存储起来，可以创建一个辅助栈，每当压入一个元素，辅助栈压入当前最小值（可能是新元素，也有可能是原来的辅助栈栈顶元素），每当弹出一个元素时，栈与辅助栈同步弹出

```c++
class Solution {
public:
    void push(int value) {
        s.push(value);
        if(aux_s.empty() || value < aux_s.top()){
            aux_s.push(value);
        }
        else{
            aux_s.push(aux_s.top());
        }
    }
    void pop() {
        if(s.empty()) return;
        s.pop();
        aux_s.pop();
    }
    int top() {
        return s.top();
    }
    int min() {
        return aux_s.top();
    }
private:
    stack<int> s, aux_s;
};
```

### 面试题31：栈的压入、弹出序列

输入两个整数序列，第一个序列表示栈的压入顺序，请判断第二个序列是否可能为该栈的弹出顺序。假设压入栈的所有数字均不相等。例如序列1,2,3,4,5是某栈的压入顺序，序列4,5,3,2,1是该压栈序列对应的一个弹出序列，但4,3,5,1,2就不可能是该压栈序列的弹出序列。（注意：这两个序列的长度是相等的）

发现：每次弹出某一元素，下次弹出的元素要么是正好在它之前压入的，要么是之后任意一次压入的，所以可以用pre_pop作为上次弹出的元素在压入序列中的序号，然后每次弹出时比较

```c++
class Solution {
public:
    bool IsPopOrder(vector<int> pushV,vector<int> popV) {
        if(pushV.empty() || popV.empty() || pushV.size() != popV.size()) return false;
        int pre_pop = -1; // small enough for the first time
        for(int i = 0; i < popV.size(); ++i){
            for(int j = 0; j < pushV.size(); ++j){
                if(popV[i] != pushV[j]) continue;
                if(j < pre_pop - 1) return false;
                pre_pop = j;
                pushV.erase(pushV.begin() + j);
                break;
            }
        }
        if(!pushV.empty()) return false;
        return true;
    }
};
```

书上的解答用到了辅助栈，把第一序列的元素依次压栈，但是并不是依次压完，压到第二序列首元素即可，然后按照第二序列的顺序依次从辅助栈中弹出元素：若下一个弹出的元素刚好是栈顶元素，则直接弹出，若不是，则把第一序列还未压完的元素顺序压栈，直到遇见要弹出的元素；如果所有元素压栈后还没遇见要弹出的元素，则说明不是弹出序列，返回false即可。但感觉书上的代码略微臃肿

```c++
class Solution {
public:
    bool IsPopOrder(vector<int> pushV,vector<int> popV) {
        if(pushV.empty() || popV.empty() || pushV.size() != popV.size()) return false;
        stack<int> s;
        s.push(pushV[0]);
        int i = 1, j = 0;
        while(j < popV.size()){
            while(s.top() != popV[j]){
                if(i == pushV.size()) return false;
                s.push(pushV[i]);
                ++i;
            }
            s.pop();
            ++j;
        }
        return true;
    }
};
```

### 面试题32-1：不分行从上到下打印二叉树

从上到下，从左到右打印二叉树，同一层节点按照从左到右的顺序打印，不分行

思路：很明显，这就是一个层序遍历，因为不分行，所以不用管当前是在第几层，可以用queue模拟BFS解决，因牛客网没题目，我自己造了测试用例，完成效果

```c++
void LayerTraversal(TreeNode* root){
    if(root == nullptr) return;
    queue<TreeNode*> q;
    q.push(root);
    TreeNode* temp;
    while(!q.empty()){
        temp = q.front();
        q.pop();
        if(temp->left != nullptr) q.push(temp->left);
        if(temp->right != nullptr) q.push(temp->right);
        cout << temp->val << " ";
    }
}
```

### 面试题32-2：分行从上到下打印二叉树

在题目一的基础上拓展，要求每一层打印一行

思路：队列中还保存当前节点在第几层，用到了stl中的pair，从队列头部取出元素时，判断是否和上次打印的元素在不同层，若是则打印换行，我发现我比较喜欢用这种“上一个”的思想。书上是用到了两个变量，一个表示当前层还未打印的节点数，另一个表示下一层的节点数，感觉拓展性没有我的好

```c++
void LayerTraversalWithNewline(TreeNode* root){
    if(root == nullptr) return;
    queue<pair<TreeNode*, int>>q;
    int layer = 0;
    q.push(make_pair(root, layer));
    TreeNode* tempNode = nullptr;
    int pre_layer = 0;
    while(!q.empty()){
        tempNode = q.front().first;
        layer = q.front().second;
        if(layer != pre_layer){
            pre_layer = layer;
            cout << endl;
        }
        q.pop();
        if(tempNode->left != nullptr) q.push(make_pair(tempNode->left, layer+1));
        if(tempNode->right != nullptr) q.push(make_pair(tempNode->right, layer+1));
        cout << tempNode->val << " ";
    }
}
```

### 面试题32-3：之字形打印二叉树

在题目二的基础上拓展，要求按照之字形换行打印二叉树，也就是第一行按照从左到右打印，换行，第二行从右往左打印，换行，以此类推

思路：用双端队列即可解决，每次换行时，对一个标志位取反，这个标志位决定了后面的操作是前向队列还是后向队列。书上用了两个栈，倒腾来倒腾去，正好符合之字形，也是一个很巧妙的解法

```c++
void LayerTraversalWithZigzag(TreeNode* root){
    if(root == nullptr) return;
    deque<pair<TreeNode*, int>> dq;
    int cur_layer = 0;
    int pre_layer = 0;
    dq.push_back(make_pair(root, cur_layer));
    TreeNode* tempNode = nullptr;
    bool isFromLeft = true;
    while(!dq.empty()){
        if(isFromLeft){
            cur_layer = dq.front().second;
        }
        else{
            cur_layer = dq.back().second;
        }
        if(cur_layer != pre_layer){
            pre_layer = cur_layer;
            cout << endl;
            isFromLeft = !isFromLeft;
        }
        if(isFromLeft){
            tempNode = dq.front().first;
            dq.pop_front();
            if(tempNode->left != nullptr) dq.push_back(make_pair(tempNode->left, cur_layer+1));
            if(tempNode->right != nullptr) dq.push_back(make_pair(tempNode->right, cur_layer+1));
            cout << tempNode->val << " ";
        }
        else{
            tempNode = dq.back().first;
            dq.pop_back();
            if(tempNode->right != nullptr) dq.push_front(make_pair(tempNode->right, cur_layer+1));
            if(tempNode->left != nullptr) dq.push_front(make_pair(tempNode->left, cur_layer+1));
            cout << tempNode->val << " ";
        }

    }
}
```

### 面试题33：二叉搜索树的后序遍历序列

输入一个整数数组，判断该数组是不是某二叉搜索树的后序遍历的结果。如果是则输出Yes,否则输出No。假设输入的数组的任意两个数字都互不相同。

思路：自己举了个例子，发现只需要用分治法即可，根节点是数组最后一个元素，先从数组倒数第二个元素开始，从后往前依次比较与数组最后一个元素，找到第一个小于它的序号i，从0到i这段序列是根节点的左子树后序遍历序列，从i+1到size()-2这段序列是根节点的右子树后序遍历序列，递归这两个子序列即可。那什么时候是要直接返回false呢？那就是从后往前遍历当前序列时，找到了i之后，再往前又发现了大于当前节点的值，很明显这违反BST的性质（左子树都小于当前节点，右子树都大于当前节点）

```c++
class Solution {
public:
    bool VerifySquenceOfBST(vector<int> sequence) {
        if(sequence.empty()) return false;
        if(sequence.size() == 1) return true;
        bool flag = true;
        int i = sequence.size() - 2;
        while(i >= 0 && sequence[i] > sequence[sequence.size()-1]) --i;
        for(int j = i-1; j >= 0; --j){
            if(sequence[j] > sequence[sequence.size()-1]){
                return false;
            }
        }
        return helper(sequence, 0, i) && helper(sequence, i+1, sequence.size()-2);
    }
    bool helper(vector<int>& sequence, int start, int finish){
        if(start >= finish) return true;
        bool flag = true;
        int i = finish - 1;
        while(i >= start && sequence[i] > sequence[finish]) --i;
        for(int j = i-1; j >= start; --j){
            if(sequence[j] > sequence[finish]){
                return false;
            }
        }
        return helper(sequence, start, i) && helper(sequence, i+1, finish-1);
    }
};
```

### 面试题34：二叉树中和为某一值的路径

输入一颗二叉树的根节点和一个整数，打印出二叉树中结点值的和为输入整数的所有路径。路径定义为从树的根结点开始往下一直到叶结点所经过的结点形成一条路径。(注意: 在返回值的list中，数组长度大的数组靠前，书上没这个要求)

思路：直接AC？？？我根本没想到。。可能越做越顺手了，但是我没有管数组长度大的更靠前诶。可能没检查这项，毕竟书上没这个要求。借用helper函数递归左右子树，helper函数还需要传入从根节点到当前节点的路径，每次递归时期待和都会减去当前值，所以代码还算精简。

```c++
class Solution {
public:
    vector<vector<int> > FindPath(TreeNode* root,int expectNumber) {
        vector<vector<int> > res;
        if(root == nullptr) return res;
        vector<int> path;
        path.push_back(root->val);
        if(!root->left && !root->right && root->val == expectNumber){
            res.push_back(path);
        }
        if(root->left) helper(root->left, expectNumber - root->val, path, res);
        if(root->right) helper(root->right, expectNumber - root->val, path, res);
        return res;
    }
    void helper(TreeNode* root, int expectNumber, vector<int> path, vector<vector<int> >& res){
        path.push_back(root->val);
        if(!root->left && !root->right && root->val == expectNumber){
            res.push_back(path);
        }
        if(root->left) helper(root->left, expectNumber - root->val, path, res);
        if(root->right) helper(root->right, expectNumber - root->val, path, res);
    }
};
```

## 分解让复杂问题简单化

### 面试题35：复杂链表的复制

输入一个复杂链表（每个节点中有节点值，以及两个指针，一个指向下一个节点，另一个特殊指针指向任意一个节点），返回结果为复制后复杂链表的head。（注意，输出结果中请不要返回参数中的节点引用，否则判题程序会直接返回空）

思路：两个辅助vector，分别存储origin和clone节点，按单向链表的顺序复制一遍，每次复制时也在辅助vector中添加，复制完后，再从头开始，为每一个节点寻找random节点，时间复杂度O(n^2)，空间复杂度O(n)。

```c++
/*
struct RandomListNode {
    int label;
    struct RandomListNode *next, *random;
    RandomListNode(int x) :
            label(x), next(NULL), random(NULL) {
    }
};
*/
class Solution {
public:
    RandomListNode* Clone(RandomListNode* pHead)
    {
        if(!pHead) return nullptr;
        RandomListNode* newHead = new RandomListNode(pHead->label);
        RandomListNode* cur_origin = pHead;
        RandomListNode* cur_clone = newHead;
        vector<RandomListNode*> vec_origin;
        vector<RandomListNode*> vec_clone;
        vec_origin.push_back(cur_origin);
        vec_clone.push_back(cur_clone);
        while(cur_origin->next){
            cur_clone->next = new RandomListNode(cur_origin->next->label);
            cur_origin = cur_origin->next;
            cur_clone = cur_clone->next;
            vec_origin.push_back(cur_origin);
            vec_clone.push_back(cur_clone);
        }
        int len = vec_origin.size();
        cur_origin = pHead;
        cur_clone = newHead;
        while(cur_origin){
            if(cur_origin->random){
                for(int i = 0; i < len; ++i){
                    if(cur_origin->random == vec_origin[i]){
                        cur_clone->random = vec_clone[i];
                    }
                }
            }
            cur_origin = cur_origin->next;
            cur_clone = cur_clone->next;
        }
        return newHead;
    }
};
```

看到书上的方法，这种思路还可以进一步优化，不用辅助空间，时间复杂度O(1)，每次为当前节点寻找其random节点都从头遍历origin，记下从头节点开始的第几步到达其random节点，然后用同样的步数得到clone链表的节点，复制给cur_clone的random指针

但是时间复杂度还是O(n^2)，想想哪里可以改进，发现在寻找random节点时效率太低，都是从头开始遍历，可以考虑用哈希表，具体来说用unordered_map，构建一个cur_origin到cur_clone的映射，这样寻找random节点的时间为O(1)，总的时间复杂度为O(n)，空间复杂度为O(n)

书上最优方法，时间复杂度都为O(n)，空间复杂度为O(1)，分为三步来做：

1. 复制每个结点，放在原结点的后面，复制结点的next指向=原结点的指向（相当于插入到原节点的后面），这时链表总长度扩大一倍，用时O(n)
2. 复制任意指向的结点，例如A指向C，则A'指向C'，因为A'在A后面，C'在C后面，所以只需要O(n）时间
3. 链表拆分，偶数位的结点是原结点，奇数位的结点是新结点，也只需要O(n)时间，注意这里写代码时要非常注意断裂的情况！

```c++
class Solution {
public:
    RandomListNode* Clone(RandomListNode* pHead)
    {
        if(!pHead) return nullptr;
        RandomListNode* cur = pHead;
        RandomListNode* newHead;
        RandomListNode* cur_new;
        RandomListNode* temp;
        while(cur){
            temp = new RandomListNode(cur->label);
            temp->next = cur->next;
            cur->next = temp;
            cur = cur->next->next;
        }
        cur = pHead;
        while(cur){
            if(cur->random){
                cur->next->random = cur->random->next;
            }
            cur = cur->next->next;
        }
        newHead = pHead->next;
        cur = pHead;
        cur_new = newHead;
        temp = pHead->next->next;
        while(temp){
            cur_new->next = temp->next;
            cur_new = cur_new->next;
            cur->next = temp;
            cur = cur->next;
            temp = cur->next->next;
        }
        cur->next = nullptr; // now cur is the last node of the original list
        return newHead;
    }
};
```

### 面试题36：二叉搜索树与双向链表

输入一棵二叉搜索树，将该二叉搜索树转换成一个排序的双向链表。要求不能创建任何新的结点，只能调整树中结点指针的指向。

思路：

1. 画图举例时发现一个规律，当前节点转换后的节点的前驱是BST中的左子树的最右节点，后驱是BST中的右子树的最左节点，那么只需要递归即可，每次递归时找到当前节点的前驱和后继，转换成双向链表；
2. 注意：对左右儿子的递归一定要放在双向链表的转换之前，不然会产生死循环，因为双向链表的转换会使得某个叶子节点的left/right指向非空；
3. 转换后，节点的left指前驱，right指后驱；
4. 这题的思想其实是中序遍历，每个节点的前驱就是在中序遍历序列其前驱

这题是自己想的，第一次把左右儿子的递归放在了后面，牛客网提交超时，在本地debug时才发现，不然就一次AC了！

书上的代码怪怪的，还双重指针，用了引用，我觉得是多此一举的，明显我的代码可读性更佳

```c++
class Solution {
public:
    TreeNode* Convert(TreeNode* pRootOfTree)
    {
        if(!pRootOfTree) return nullptr;
        helper(pRootOfTree);
        TreeNode* listHead = pRootOfTree;
        while(listHead->left){
            listHead = listHead->left;
        }
        return listHead;
    }
    void helper(TreeNode* root){
        if(!root) return;
        TreeNode* leftChild = root->left;
        TreeNode* rightChild = root->right;
        TreeNode* temp;
        helper(leftChild);
        helper(rightChild);
        if(leftChild){
            temp = leftChild;
            while(temp->right){
                temp = temp->right;
            }
            temp->right = root;
            root->left = temp;
        }
        if(rightChild){
            temp = rightChild;
            while(temp->left){
                temp = temp->left;
            }
            temp->left = root;
            root->right = temp;
        }
    }
};
```

### 面试题37：序列化二叉树

请实现两个函数，分别用来序列化和反序列化二叉树

二叉树的序列化是指：把一棵二叉树按照某种遍历方式的结果以某种格式保存为字符串，从而使得内存中建立起来的二叉树可以持久保存。序列化可以基于先序、中序、后序、层序的二叉树遍历方式来进行修改，序列化的结果是一个字符串，序列化时通过 某种符号表示空节点（#），以 ！ 表示一个结点值的结束（value!）。

二叉树的反序列化是指：根据某种遍历顺序得到的序列化字符串结果str，重构二叉树。

思路：这题就是考字符串，牛客网的是char*字符串，太老派，搞了半天没写出来，书上又不一样，所以直接扎进评论区看答案了

[代码链接](https://www.nowcoder.com/questionTerminal/cf7e25aa97c04cc1a68c8f040e71fb84?f=discussion)，来源：牛客网

```c++
/*
 1. 对于序列化：使用前序遍历，递归的将二叉树的值转化为字符，并且在每次二叉树的结点
不为空时，在转化val所得的字符之后添加一个' ， '作为分割。对于空节点则以 '#' 代替。
 2. 对于反序列化：按照前序顺序，递归的使用字符串中的字符创建一个二叉树(特别注意：
在递归时，递归函数的参数一定要是char ** ，这样才能保证每次递归后指向字符串的指针会
随着递归的进行而移动！！！)
*/
class Solution {  
public:
    char* Serialize(TreeNode *root) {
       if(root == NULL)
           return NULL;
        string str; // string更好拼接
        Serialize(root, str);
        char *ret = new char[str.length() + 1];
        int i;
        for(i = 0; i < str.length(); i++){
            ret[i] = str[i];
        }
        ret[i] = '\0';
        return ret;
    }
    void Serialize(TreeNode *root, string& str){
        if(root == NULL){
            str += '#'; // 原作者的序列化对于空节点就用'#'代替，而没有逗号分割
            return ;
        }
        string r = to_string(root->val);
        str += r;
        str += ',';
        Serialize(root->left, str);
        Serialize(root->right, str);
    }

    TreeNode* Deserialize(char *str) {
        if(str == NULL)
            return NULL;
        TreeNode *ret = Deserialize(&str);
        return ret;
    }
    TreeNode* Deserialize(char **str){//由于递归时，会不断的向后读取字符串
        if(**str == '#'){  //所以一定要用**str,
            ++(*str);         //以保证得到递归后指针str指向未被读取的字符
            return NULL;
        }
        int num = 0;
        while(**str != '\0' && **str != ','){
            num = num*10 + ((**str) - '0');
            ++(*str);
        }
        TreeNode *root = new TreeNode(num);
        if(**str == '\0')
            return root;
        else
            (*str)++;
        root->left = Deserialize(str);
        root->right = Deserialize(str);
        return root;
    }
};
```

### 面试题38-1：字符串的排列

输入一个字符串,按字典序打印出该字符串中字符的所有排列。例如输入字符串abc,则打印出由字符a,b,c所能排列出来的所有字符串abc,acb,bac,bca,cab和cba。

输入描述:
输入一个字符串,长度不超过9(可能有字符重复),字符只包括大小写字母。

题目说要按字典序，这其实就是next_permutation的算法，寻找一个数的下一个排列分为三步：

1. 从右向左找到第一个正序对（array[i] < array[i+1]，因为没有等号，所以可以完美去掉重复的排列）
2. 从i开始向右搜索，找到比array[i]大的字符中最小的那个，记为array[j]
3. 交换array[i]和array[j]
4. 将i后面的字符反转(reverse)

直接用STL的泛型算法可以清楚的阐释这个算法，但是这肯定不是出题人想要的，出题人肯定是想答题者手写出next_permutation算法，之前写过关于数字的，下次再复习吧

```c++
class Solution {
public:
    vector<string> Permutation(string str) {
        if (str.empty()) return {};
        sort(str.begin(), str.end());
        vector<string> ans;
        ans.push_back(str);
        while (next_permutation(str.begin(), str.end()))
            ans.push_back(str);
        return ans;
    }
};
```

当然也可以用递归，固定第一个字符，对后面的进行全排列，盗下图，但是最后不是**全排列**，需要再对`vector<string>`进行排序

以下代码配合这个递归树会更加清晰易懂

![20200121123847.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200121123847.png)

```c++
class Solution {
public:
    vector<string> Permutation(string str)
    {
        vector<string> result;
        if(str.empty()) return result;
        Permutation(str,result,0);
        // 此时得到的result中排列并不是字典顺序，可以单独再排下序
        sort(result.begin(),result.end());
        return result;
    }

    void Permutation(string& str,vector<string> &result,int begin)
    {
        if(begin == str.size()-1) // 递归结束条件：索引已经指向str最后一个元素时
        {
            if(find(result.begin(),result.end(),str) == result.end())
            {
                // 如果result中不存在str，才添加；避免aa和aa重复添加的情况
                result.push_back(str);
            }
        }
        else
        {
            // 第一次循环i与begin相等，相当于第一个位置自身交换，关键在于之后的循环，
            // 之后i != begin，则会交换两个不同位置上的字符，直到begin==str.size()-1，进行输出；
            for(int i=begin;i<str.size();++i)
            {
                swap(str[i],str[begin]);
                Permutation(str,result,begin+1);
                swap(str[i],str[begin]); // 复位，用以恢复之前字符串顺序，达到第一位依次跟其他位交换的目的
            }
        }
    }
};
```

### 面试题38-2：正方体顶点

现有8个数字的数组，把这8个数字放在正方体的8个顶点上，能否使得正方体上三组相对的面上的4个顶点的和都相等

思路：输入的8个数字设为a1到a8，要求在a1~a8的全排列中找到一种排列使得，`a1+a2+a3+a4 == a5+a6+a7+a8 && a1+a3+a5+a7 == a2+a4+a6+a8 && a1+a2+a5+a6 == a3+a4+a7+a8`

以下代码是自己测试的，整体思路与面试题38相差不大，最后返回的res是满足条件的所有排列

```c++
class Solution {
public:
    vector<vector<int>> judge(vector<int> vec){
        vector<vector<int>> res;
        if(vec.empty() || vec.size() != 8) return res;
        helper(vec, res, 0);
        return res;
    }
    bool isCubicNode(vector<int>& vec){
        if(vec[0]+vec[1]+vec[2]+vec[3] == vec[4]+vec[5]+vec[6]+vec[7] &&
            vec[0]+vec[2]+vec[4]+vec[6] == vec[1]+vec[3]+vec[5]+vec[7] &&
            vec[0]+vec[1]+vec[4]+vec[5] == vec[2]+vec[3]+vec[6]+vec[7]){
                return true;
            }
        return false;
    }
    void helper(vector<int>& vec, vector<vector<int>>& res, int begin){
        if(begin == vec.size() - 1){
            if(isCubicNode(vec) && find(res.begin(), res.end(), vec) == res.end()){
                res.push_back(vec);
            }
        }
        else{
            for(int i = begin; i < vec.size(); ++i){
                swap(vec[i], vec[begin]);
                helper(vec, res, begin+1);
                swap(vec[i], vec[begin]);
            }
        }
    }
};
```

### 面试题38-3：n皇后问题

如何能够在 8×8 的国际象棋棋盘上放置八个皇后，使得任何一个皇后都无法直接吃掉其他的皇后？为了达到此目的，任两个皇后都不能处于同一条横行、纵行或斜线上

给定一个整数 n，返回所有不同的 n 皇后问题的解决方案。

每一种解法包含一个明确的 n 皇后问题的棋子放置方案，该方案中 'Q' 和 '.' 分别代表了皇后和空位。

示例:

输入: 4
输出: [
 [".Q..",  // 解法 1
  "...Q",
  "Q...",
  "..Q."],

 ["..Q.",  // 解法 2
  "Q...",
  "...Q",
  ".Q.."]
]
解释: 4 皇后问题存在两个不同的解法

来源：力扣（LeetCode），
[链接](https://leetcode-cn.com/problems/n-queens)，著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。

解法：既然皇后不能处于同一行，那么就定义一个数组，第i个数字表示位于第i行的皇后的列号，然后对数组初始化为0，1，... n-1，这样可以保证皇后在行上不冲突、在列上不冲突，然后进行全排列，只需要判断是否在同一对角线上即可。在力扣上提交发现时间比较慢，可能是因为我的方法没有剪枝吧，力扣官网题解的做法是一个个摆上棋盘，这样每放一个皇后都缩小了下一步皇后的可选位置

```c++
class Solution {
public:
    vector<vector<string>> solveNQueens(int n) {
        // vec的第i个数字表示位于第i行的皇后的列号
        vector<int> vec;
        // 先把vec初始化为0，1，... n-1，这样可以保证皇后在行上不冲突、在列上不冲突
        for(int i = 0; i < n; ++i){
            vec.push_back(i);
        }
        vector<vector<string>> res;
        // 然后把vec全排列，对于每次排列，判断它们在对角线上是否冲突，若不冲突，则为N皇后的一个解法
        helper(vec, res, 0);
        return res;
    }
    void helper(vector<int>& vec, vector<vector<string>>& res, int begin){
        if(begin == vec.size() - 1){
            // 判断在对角线上是否冲突
            bool isConflict = false;
            for(int i = 0; i < vec.size(); ++i){
                for(int j = i + 1; j < vec.size(); ++j){
                    if(i - j == vec[i] - vec[j] || i - j == vec[j] - vec[i]){
                        isConflict = true;
                        break;
                    }
                }
                if(isConflict) break;
            }
            if(!isConflict){
                // 找到一个解法啦！格式化输出要小心点哦
                vector<string> sol;
                string row;
                for(int i = 0; i < vec.size(); ++i){
                    row = "";
                    for(int j = 0; j < vec.size(); ++j){
                        if(j == vec[i]){
                            row += 'Q';
                        }
                        else{
                            row += '.';
                        }
                    }
                    sol.push_back(row);
                }
                // 判断当前解是否已经在结果集中
                if(find(res.begin(), res.end(), sol) == res.end()){
                    res.push_back(sol);
                }
            }
        }
        else{
            for(int i = begin; i < vec.size(); ++i){
                // 这里可以执行剪枝操作，即判断对角线是否冲突，若冲突则直接continue
                swap(vec[i], vec[begin]);
                helper(vec, res, begin+1);
                swap(vec[i], vec[begin]);
            }
        }
    }
};
```

总结：在力扣上看到有人总结回溯法的框架，写的非常精炼，正好与我的代码一致

```python
result = []
def backtrack(路径, 选择列表):
    if 满足结束条件:
        result.add(路径)
        return

    for 选择 in 选择列表:
        做选择
        backtrack(路径, 选择列表)
        撤销选择
```

作者：labuladong
，[链接](https://leetcode-cn.com/problems/n-queens/solution/hui-su-suan-fa-xiang-jie-by-labuladong/)
，来源：力扣（LeetCode）。著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

## 优化时间和空间效率

### 面试题39：数组中出现次数超过一半的数字

数组中有一个数字出现的次数超过数组长度的一半，请找出这个数字。例如输入一个长度为9的数组{1,2,3,2,2,2,5,4,2}。由于数字2在数组中出现了5次，超过数组长度的一半，因此输出2。如果不存在则输出0。

给定一个大小为 n 的数组，找到其中的多数元素。多数元素是指在数组中出现次数大于 ⌊ n/2 ⌋ 的元素。

你可以假设数组是非空的，并且给定的数组总是存在多数元素。

示例 1:

输入: [3,2,3]
输出: 3
示例 2:

输入: [2,2,1,1,1,2,2]
输出: 2

来源：力扣（LeetCode）第169题   ，[链接](https://leetcode-cn.com/problems/majority-element)，著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。

一次性AC，用哈希表存储数字-出现次数的映射，一次遍历搞定，时间和空间复杂度都是O(n)

```c++
class Solution {
public:
    int MoreThanHalfNum_Solution(vector<int> numbers) {
        unordered_map<int, int> map;
        for(int i = 0; i < numbers.size(); ++i){
            ++map[numbers[i]];
            if(map[numbers[i]] > numbers.size() / 2){
                return numbers[i];
            }
        }
        return 0;
    }
};
```

优化：根据这个数组的特点，如果有某数字出现次数超过一半数组长度，那么这个数组的中位数也必然是这个数字，所以问题可以转化为求中位数，拿到中位数后再检查这个中位数的数值是否在数组中出现过半即可。求中位数可以用快速选择算法，类似于快速排序的partition操作，减治法，使得时间为O(n)。这个算法花费了我很久的时间，主要是边界情况要非常小心谨慎地处理。这个解法需要改变原数组。

```c++
class Solution {
public:
    int MoreThanHalfNum_Solution(vector<int> numbers) {
        if(numbers.empty()) return 0;
        if(numbers.size() == 1) return numbers[0];
        if(numbers.size() == 2) return 0;
        int median = MedianByPartition(numbers, 0, numbers.size() - 1);
        if(CheckMoreThanHalf(numbers, median)){
            return median;
        }
        return 0;
    }
    bool CheckMoreThanHalf(vector<int>& numbers, int number){
        int times = 0;
        int len = numbers.size();
        for(int i = 0; i < len; ++i){
            if(numbers[i] == number){
                ++times;
                if(times > len / 2){
                    return true;
                }
            }
        }
        return false;
    }
    // 中位数在闭区间[low, high]中
    int MedianByPartition(vector<int>& numbers, int low, int high){
        if(low >= high) return numbers[low];
        int pivot = numbers[high];
        int i = low;
        int j = high - 1;
        while(i < j){
            while(i < j && numbers[i] < pivot) ++i;
            while(i < j && numbers[j] > pivot) --j;
            if(i == j) break;
            swap(numbers[i], numbers[j]);
            ++i;
            --j;
        }
        swap(numbers[i], numbers[high]);
        if(i > (numbers.size() - 1) / 2){ // 左边部分查找
            return MedianByPartition(numbers, low, i-1);
        }
        else if(i < (numbers.size() - 1) / 2){ // 右边部分查找
            return MedianByPartition(numbers, i+1, high);
        }
        return numbers[i]; // 恰为中位数
    }
};
```

最好的解法：Boyer-Moore 投票算法（时间O(n),空间O(1))

我们假设这样一个场景，在一个游戏中，分了若干个队伍，有一个队伍的人数超过了半数。所有人的战力都相同，不同队伍的两个人遇到就是同归于尽，同一个队伍的人遇到当然互不伤害。

这样经过充分时间的游戏后，最后的结果是确定的，一定是超过半数的那个队伍留在了最后。

而对于这道题，我们只需要利用上边的思想，把数组的每个数都看做队伍编号，然后模拟游戏过程即可。

candidate 记录当前队伍的人数，count 记录当前队伍剩余的人数。如果当前队伍剩余人数为 0，记录下次遇到的人的所在队伍号。

配合gif图，更易理解

![20200122122539.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200122122539.png)

```c++
class Solution {
public:
    int MoreThanHalfNum_Solution(vector<int>& nums) {
        if(nums.empty()) return 0;
        int candidate = nums[0];
        int count = 1;
        for(int i = 1; i < nums.size(); ++i){
            if(nums[i] == candidate){
                ++count;
            }
            else{
                --count;
                if(count == 0){
                    candidate = nums[i];
                    count = 1;
                }
            }
        }
        if(CheckMoreThanHalf(nums, candidate)){
            return candidate;
        }
        return 0;
    }
    bool CheckMoreThanHalf(vector<int>& numbers, int number){
        int times = 0;
        int len = numbers.size();
        for(int i = 0; i < len; ++i){
            if(numbers[i] == number){
                ++times;
                if(times > len / 2){
                    return true;
                }
            }
        }
        return false;
    }
};
```

### 面试题40：最小的k个数

输入n个整数，找出其中最小的K个数。例如输入4,5,1,6,2,7,3,8这8个数字，则最小的4个数字是1,2,3,4,。书上的代码和牛客网都没有对最小k个数排序

基于partition的快速选择算法，可以得到最小的k个数，用时O(n)，但不适合海量数据（无法一次性装入内存），而且这种算法需要修改原数组，且这k个数还未排序

基于最大堆的算法，时间复杂度为O(nlogk)，适合海量数据，并且是联机的，不用修改原数组

#### 利用STL的堆操作实现最大堆

STL 堆操作，头文件是#include `<algorithm>`，一般用到这四个：make_heap()、pop_heap()、push_heap()、sort_heap();

（1）make_heap()构造堆
void make_heap(first_pointer,end_pointer,compare_function);
默认比较函数是(<)，即最大堆。
函数的作用是将[begin,end)内的元素处理成堆的结构

（2）push_heap()添加元素到堆
void push_heap(first_pointer,end_pointer,compare_function);
新添加一个元素在末尾，然后重新调整堆序。该算法必须是在一个已经满足堆序的条件下。
先在vector的末尾添加元素，再调用push_heap

（3）pop_heap()从堆中移出元素
void pop_heap(first_pointer,end_pointer,compare_function);
把堆顶元素取出来，放到了数组或者是vector的末尾。
要取走，则可以使用底部容器（vector）提供的pop_back()函数。
先调用pop_heap再从vector中pop_back元素

（4）sort_heap()对整个堆排序
排序之后的元素就不再是一个合法的堆了。

```c++
class Solution {
public:
    vector<int> GetLeastNumbers_Solution(vector<int> input, int k) {
        if(input.empty() || k <= 0 || k > input.size()) return vector<int>();
        int len=input.size();
        vector<int> res(input.begin(),input.begin()+k);
        make_heap(res.begin(),res.end());
        for(int i=k;i<len;i++)
        {
            if(input[i]<res[0])
            {
                //先pop_heap,然后在容器中删除
                pop_heap(res.begin(),res.end());
                res.pop_back();
                //先在容器中加入，再push_heap
                res.push_back(input[i]);
                push_heap(res.begin(),res.end());
            }
        }
        sort_heap(res.begin(),res.end());
        return res;
    }
};
```

#### 利用STL容器multiset（底层红黑树）实现最大堆

注意multiset的默认排序都是从小到大的，这个必须用仿函数，注意返回值并没有排序，但是牛客网也没有检查是否排序

```c++
class Solution {
public:
    vector<int> GetLeastNumbers_Solution(vector<int> input, int k) {
        if(input.empty() || k <= 0 || k > input.size()) return vector<int>();
        int len=input.size();
        multiset<int, greater<int>> set; //仿函数中的greater<T>模板，从大到小排序
        for(int i = 0; i < len; ++i){
            if(i < k){
                set.insert(input[i]);
            }
            else{
                if(input[i] < *set.begin()){
                    set.erase(*set.begin());
                    set.insert(input[i]);
                }
            }
        }
        return vector<int>(set.begin(), set.end());
    }
};
```

### 面试题41：数据流中的中位数

如何得到一个数据流中的中位数？如果从数据流中读出奇数个数值，那么中位数就是所有数值排序之后位于中间的数值。如果从数据流中读出偶数个数值，那么中位数就是所有数值排序之后中间两个数的平均值。我们使用Insert()方法读取数据流，使用GetMedian()方法获取当前读取数据的中位数。

思路：这明显是个联机算法，而且在任何时刻调用GetMedian()时都要返回当前已读的数据的中位数，我用multiset的红黑树底层来实现，插入操作只需要logm(m为当前已读数据长度)，而获得中位数需要遍历一半的数据，所以也需要O(n)

```c++
class Solution {
public:
    multiset<int> order;
    void Insert(int num)
    {
        order.insert(num);
    }

    double GetMedian()
    {
        if(order.empty()) return 0.0;
        int len = order.size();
        auto it = order.begin();
        if(len % 2 == 1){
            for(int i = 0; i < len / 2; ++i){
                ++it;
            }
            return (double) *it;
        }
        for(int i = 0; i < len / 2 - 1; ++i){
            ++it;
        }
        return ((double)(*it) + double(*(++it))) / 2;
    }
};
```

优化：multiset的确不错，但是刚才算法中寻找中位数的时间复杂度不是O(1)，如果用两个迭代器指向multiset的中间的节点（若长度为奇数，则指向同一个节点），那么寻找中位数是可以达到O(1)的。

两个迭代器/指针 lo_median 和 hi_median，它们在 multiset上迭代 data。添加数字 num 时，会出现三种情况：

1. 容器当前为空。因此，我们只需插入 num 并设置两个指针指向这个元素。
2. 容器当前包含奇数个元素。这意味着两个指针当前都指向同一个元素。
    - 如果 num 不等于当前的中位数元素，则 num 将位于元素的任一侧。无论哪一边，该部分的大小都会增加，因此相应的指针会更新。例如，如果 num 小于中位数元素，则在插入 num 时，输入的较小半部分的大小将增加 11。
    - 如果 num 等于当前的中位数元素，那么所采取的操作取决于 num 是如何插入数据的（multiset会把重复项添加到equal_range的末尾）
3. 容器当前包含偶数个元素。这意味着指针当前指向连续的元素。
    - 如果 num 是两个中值元素之间的数字，则 num 将成为新的中值。两个指针都必须指向它。
    - 否则，num 会增加较小或较高一半的大小。我们相应地更新指针。必须记住，两个指针现在必须指向同一个元素。

找到中间值很容易！它只是两个指针 lo_median 和 hi_median 所指元素的平均值。

```c++
class Solution {
public:
    multiset<int> order;
    multiset<int>::iterator it1, it2;
    void Insert(int num)
    {
        int n = order.size();
        order.insert(num);
        if(order.size() == 1){
            it1 = order.begin();
            it2 = order.begin();
            return;
        }
        if((n & 1) == 1){ // 奇数个，两个迭代器指向同一个
            if(num < *it1){
                --it1;
            }
            else{
                ++it2; // 这里也包含了相等的情况，multiset会把重复项添加到equal_range的末尾，所以自增it2即可
            }
        }
        else{ // 偶数个，两个迭代器指向连续的两个
            if(num > *it1 && num < *it2){ // 新插入的在两个迭代器之间
                ++it1;
                --it2;
            }
            else if(num >= *it2){
                ++it1;;
            }
            else{
                --it2;
                 // 这里很重要，当1 2 3 4再插入2时变为1 2 2 3 4，
                 // it1指向第一个2，it2指向3，it1和it2之间还多了新插入的2，一定要让it1变为与it2相等。
                 // 这与multiset的实现机制有关，从迭代器的角度来看，新重复项添加到重复项的后面
                it1 = it2;
            }
        }
    }

    double GetMedian()
    {
        return ((double) *it1 + (double) *it2) / 2;
    }
};
```

书上总结的非常好，摘抄如下

1. 数据从数据流中读出来，而且数目随时间变化，所以需要一个容器来保存
2. 数组是最简单的容器，如果数组没有排序，则可以用基于partition的快速选择算法找出数组中的中位数（第39题），在没有排序的数组中插入一个数耗时O(1)，获取中位数耗时O(n)
3. 如果在插入使让数组保持有序，耗时O(n),获取中位数就很快了，直接下标访问即可，耗时O(1)
4. 排序的链表也可以，在已排序的链表中插入一个数耗时O(n)，定义两个指针指向链表中间的节点（如果链表的节点数是奇数，那么这两个指针指向同一个节点），每次插入时，这两个指针也会变动，使自己保持指向链表中间的节点，这样获取中位数的时间也只要O(1)
5. 二叉搜索树平均插入时间是O(logn)，但是如果极度不平衡时，插入新数据的时间仍为O(n)，为了得到中位数，可以在节点中插入一个字段用来表示子树节点的数目，这样可以在平均O(logn)的时间内得到中位数，但是最差情况仍为O(n)
6. AVL树可以在O(logn)的时间内插入新节点，同时用O(1)的时间得到中位数，虽然时间效率很高，但是得自己实现，太麻烦了

巧妙利用两个堆的解法：

1. 用于存储输入数字中较小一半的最大堆（最大堆中的所有数字都小于或等于最大堆的top元素）
2. 用于存储输入数字的较大一半的最小堆（最小堆中的所有数字都大于或等于最小堆的顶部元素）
3. 当插入的数是第偶数个时，让最大堆增加，否则让最小堆增加
4. 插入的新数据不是直接加入最大堆，而是先比较当前数是否小于最小堆，如果满足，才能加入到最大堆（较小一半）中，如果不满足，则把把最大堆的堆顶元素插入到最小堆中，最大堆删除原来的堆顶元素，然后再插入新读的数
5. 只要这两个堆是平衡的（即这两个堆的数量相等或相差1），那么中位数就可以通过这两个堆的堆顶元素获得

```c++
class Solution {
public:
    multiset<int> min_heap;
    multiset<int, greater<int>> max_heap;
    int k = 0; // record how many numbers are inserted
    void Insert(int num)
    {
        if((k & 1) == 0){
            if(!min_heap.empty() && num > *min_heap.begin()){
                max_heap.insert(*min_heap.begin());
                min_heap.erase(min_heap.begin());
                min_heap.insert(num);
            }
            else{
                max_heap.insert(num);
            }
        }
        else{
            if(!max_heap.empty() && num < *max_heap.begin()){
                min_heap.insert(*max_heap.begin());
                max_heap.erase(max_heap.begin());
                max_heap.insert(num);
            }
            else{
                min_heap.insert(num);
            }
        }
        ++k;
    }
    double GetMedian()
    {
        if(min_heap.empty()){
            return (double) *max_heap.begin();
        }
        if(min_heap.size() < max_heap.size()){
            return (double) *max_heap.begin();
        }
        else if(min_heap.size() > max_heap.size()){
            return (double) *min_heap.begin();
        }
        return ((double)(*min_heap.begin()) + (double)(*max_heap.begin())) / 2;
    }
};
```

中位数是有序列表中间的数。如果列表长度是偶数，中位数则是中间两个数的平均值。

例如，

[2,3,4] 的中位数是 3

[2,3] 的中位数是 (2 + 3) / 2 = 2.5

设计一个支持以下两种操作的数据结构：

void addNum(int num) - 从数据流中添加一个整数到数据结构中。
double findMedian() - 返回目前所有元素的中位数。
示例：

addNum(1)
addNum(2)
findMedian() -> 1.5
addNum(3)
findMedian() -> 2
进阶:

如果数据流中所有整数都在 0 到 100 范围内，你将如何优化你的算法？
如果数据流中 99% 的整数都在 0 到 100 范围内，你将如何优化你的算法？
在真实的面试中遇到过这道题？

来源：力扣（LeetCode），[链接](https://leetcode-cn.com/problems/find-median-from-data-stream)，著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。

### 面试题42：连续子数组的最大和

HZ偶尔会拿些专业问题来忽悠那些非计算机专业的同学。今天测试组开完会后,他又发话了:在古老的一维模式识别中,常常需要计算连续子向量的最大和,当向量全为正数的时候,问题很好解决。但是,如果向量中包含负数,是否应该包含某个负数,并期望旁边的正数会弥补它呢？例如:{6,-3,-2,7,-15,1,2,2},连续子向量的最大和为8(从第0个开始,到第3个为止)。给一个数组，返回它的最大连续子序列的和，你会不会被他忽悠住？(子向量的长度至少是1)

时间复杂度要求为O(n)，明显不能用暴力法O(n^2)，仔细观察数组的特点，可以用两个变量记录已知的最大子数组sum和以及当前的子数组和cur_sum，cur_sum<=0时，后面任意一个整数都会比它大，所以可以直接舍弃掉cur_sum，这其实就是动态规划的思想

用f(i)表示以第i个数字结尾的子数组的最大和，那么需要求出max{f(i)}，观察发现有如下递推公式

f(i)=f(i-1)+array[i], if f(i-1) > 0
f(i)=array[i], if f(i-1) <= 0

```c++
class Solution {
public:
    int FindGreatestSumOfSubArray(vector<int> array) {
        int sum = array[0];
        int cur_sum = array[0];
        int len = array.size();
        for(int i = 1; i < len; ++i){
            if(cur_sum <= 0){
                cur_sum = array[i];
            }
            else{
                cur_sum += array[i];
            }
            if(cur_sum > sum){
                sum = cur_sum;
            }
        }
        return sum;
    }
};
```

### 面试题43：1~n整数中1出现的次数

输入一个整数，求1~n这n个整数的十进制表示中1的次数。例如，输入12，1~12这些整数中包含1的数字有1、10、11、12，共5次

暴力法，一次性AC，时间复杂度为O(nlogn)（以10为底），效率不高

```c++
class Solution {
public:
    int NumberOf1Between1AndN_Solution(int n)
    {
        int count = 0;
        int j = 0;
        for(int i = 1; i <= n; ++i){
            j = i;
            while(j != 0){
                if(j % 10 == 1){
                    ++count;
                }
                j /= 10;
            }
        }
        return count;
    }
};
```

数学归纳法，有点难以理解，书上给的解法其实并不直观，我找到一个博客写的还不错，[link](https://blog.csdn.net/yi_Afly/article/details/52012593)，round*base很好理解，若当前位为1，则需要知道former，因为base每次自乘10，所以当前位的former可以用n%base算出，时间复杂度O(logn)（以10为底）

```c++
class Solution {
public:
    int NumberOf1Between1AndN_Solution(int n)
    {
        if(n < 1) return 0;
        int count = 0;
        int base = 1;
        int round = n;
        while(round > 0){
            int weight = round % 10;
            round /= 10;
            count += round * base;
            if(weight==1)
                count += (n % base) + 1;
            else if(weight > 1)
                count += base;
            base *= 10;
        }
        return count;
    }
};
```

给定一个整数 n，计算所有小于等于 n 的非负整数中数字 1 出现的个数。

示例:

输入: 13
输出: 6
解释: 数字 1 出现在以下数字中: 1, 10, 11, 12, 13 。

来源：力扣（LeetCode），[链接](https://leetcode-cn.com/problems/number-of-digit-one)
著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。

### 面试题44：数字序列中某一位的数字

数字以01234567891011121314...的格式序列化到一个字符序列中，在这个序列中，第5位（从0开始计数）是5，第13位是1，第19位是4，等等，请写一个函数，求任意第n位对应的数字

在无限的整数序列 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, ...中找到第 n 个数字。

注意:
n 是正数且在32为整形范围内 ( n < 231)。

示例 1:

输入:
3

输出:
3
示例 2:

输入:
11

输出:
0

说明:
第11个数字在序列 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, ... 里是0，它是10的一部分。

来源：力扣（LeetCode），[链接](https://leetcode-cn.com/problems/nth-digit)，著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。

思路：直接用string存起来，虽然能完成效果，但效率是不高的

```c++
class Solution {
public:
    int NthNumber(int n)
    {
        string str = "";
        for(int i = 0; str.size() <= n; ++i){
            str += to_string(i);
        }
        return str[n] - '0';
    }
};
```

优化：数学方法

1. 发现长度为1的数：1-9有9个数，长度为2的数：10-99组成的字符串长度为2x90，长度为3的数：100-999组成的字符串长度为3x900，长度为4的数：1000-9999组成的字符串长度为4x9000；以此类推，长度为n的数，`[pow(10, len - 1),  pow(10, len)]`，一共 `9 * pow(10, len - 1)`个数，组成的字符串长度为 `9 * pow(10, len - 1) * len`
2. 设置一个标志位i，每一个区间都有固定的标志位，例如1-9是1，10--99是2，以此类推；
3. 然后用n减去每个区间的值，知道确定n在哪个区间；
4. 再得到区间中确定的数字，将其变为string型，然后就可以得到确定的数字。

这个代码应该是最简洁易懂的了，转自[[LeetCode] Nth Digit 第N位](https://www.cnblogs.com/grandyang/p/5891871.html)

我们可以定义个变量cnt，初始化为9，然后每次循环扩大10倍，再用一个变量len记录当前循环区间数字的位数，另外再需要一个变量start用来记录当前循环区间的第一个数字，我们n每次循环都减去len*cnt (区间总位数)，当n落到某一个确定的区间里了，那么(n-1)/len就是目标数字在该区间里的坐标，加上start就是得到了目标数字，然后我们将目标数字start转为字符串，(n-1)%len就是所要求的目标位，最后别忘了考虑int溢出问题，我们干脆把所有变量都申请为长整型的好了

```c++
class Solution {
public:
    int findNthDigit(int n) {
        if (n < 10){
            return n;
        }
        long long len = 1, cnt = 9, start = 1;
        while (n > len * cnt) {
            n -= len * cnt;
            ++len;
            cnt *= 10;
            start *= 10;
        }
        start += (n - 1) / len;
        string t = to_string(start);
        return t[(n - 1) % len] - '0';
    }
};
```

### 面试题45：把数组排成最小的数

牛客网：输入一个正整数数组，把数组里所有数字拼接起来排成一个数，打印能拼接出的所有数字中最小的一个。例如输入数组{3，32，321}，则打印出这三个数字能排成的最小数字为321323。

力扣：给定一组非负整数，重新排列它们的顺序使之组成一个最大的整数。说明: 输出结果可能非常大，所以你需要返回一个字符串而不是整数。

来源：力扣（LeetCode），[链接](https://leetcode-cn.com/problems/largest-number)，著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。

思路：二次AC，第一次犯了低级错误，找出全排列，然后参照之前的回溯模板，非常快就可以解决，n个数字总共有n!个排列

```c++
class Solution {
public:
    string PrintMinNumber(vector<int> numbers) {
        if(numbers.empty()) return "";
        string minstr = "";
        for(int i = 0; i < numbers.size(); ++i){
            minstr += to_string(numbers[i]);
        }
        helper(numbers, minstr, 0);
        return minstr;
    }
    void helper(vector<int>& numbers, string& minstr, int start){
        if(start == numbers.size() - 1){
            string tempstr = "";
            for(int i = 0; i < numbers.size(); ++i){
                tempstr += to_string(numbers[i]);
            }
            if(tempstr < minstr){
                minstr = tempstr;
            }
        }
        else{
            for(int i = start; i < numbers.size(); ++i){
                swap(numbers[i], numbers[start]);
                helper(numbers, minstr, start + 1);
                swap(numbers[i], numbers[start]);
            }
        }
    }
};
```

优化：这题主要考察比较的问题，只需要按照某种规则将这个数组中的数字全部排序,之后再转换成为字符串加起来，就可以得到最小数（最大数）

sort中的比较函数compare要声明为静态成员函数或全局函数，不能作为普通成员函数，否则会报错。因为：非静态成员函数是依赖于具体对象的，而std::sort这类函数是全局的，因此无法再sort中调用非静态成员函数。静态成员函数或者全局函数是不依赖于具体对象的, 可以独立访问，无须创建任何对象实例就可以访问。同时静态成员函数不可以调用类的非静态成员。

```c++
class Solution {
public:
    string PrintMinNumber(vector<int> numbers) {
        if(numbers.empty()) return "";
        string minstr = "";
        vector<string> str_numbers;
        for(int i = 0; i < numbers.size(); ++i){
            str_numbers.push_back(to_string(numbers[i]));
        }
        sort(str_numbers.begin(), str_numbers.end(), comp);
        for(int i = 0; i < str_numbers.size(); ++i){
            // 如果原数组有0的话，会排在minstr的开头，所以要跳过
            if(str_numbers[i] != "0"){
                minstr += str_numbers[i];
            }
        }
        return minstr;
    }
    static bool comp(const string& str_a, const string& str_b){
        string s1 = str_a + str_b;
        string s2 = str_b + str_a;
        return s1 < s2;
    }
};
```

### 面试题46：把数字翻译成字符串

一条包含字母 A-Z 的消息通过以下方式进行了编码：

'A' -> 1
'B' -> 2
...
'Z' -> 26
给定一个只包含数字的非空字符串，请计算解码方法的总数。

示例 1:

输入: "12"
输出: 2
解释: 它可以解码为 "AB"（1 2）或者 "L"（12）。
示例 2:

输入: "226"
输出: 3
解释: 它可以解码为 "BZ" (2 26), "VF" (22 6), 或者 "BBF" (2 2 6) 。

来源：力扣（LeetCode）,[链接](https://leetcode-cn.com/problems/decode-ways)，著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。

思路：回溯法，遍历字符串，编码当前数字的方法数+编码当前数字与之后数字的方法数，但是效率很慢，在力扣上用时1000ms，只击败5%的cpp

定义函数f(i)表示从第i位开始的不同翻译的数目，那么f(i)=f(i+1)+g(i,i+1)xf(i+2)，如果第i与第i+1位拼接起来在10~26的范围内，函数g(i,i+1)的值为1，否则为0

```c++
class Solution {
public:
    int numDecodings(string s) {
        if(s.empty()) return 0;
        int ways = helper(s, 0);
        return ways;
    }
    int helper(string& s, int start){
        if(start > s.size() - 1){
            return 1;
        }
        if(start == s.size() - 1){
            if(s[start] != '0'){
                return 1;
            }
            else{
                return 0;
            }
        }
        else{
            if((s[start] == '1') || (s[start] == '2' && s[start+1] <= '6')){
                return helper(s, start+1) + helper(s, start+2);
            }
            else if(s[start] == '0'){
                return 0;
            }
        }
        // only decode current number
        return helper(s, start+1);

    }
};
```

优化：尽管我们用递归的思路可以解决，但是递归是从最大的问题开始自上而下解决问题，**存在重复的子问题**，可以考虑动态规划，可以做到一次遍历，设dp[i]为s[0~i]的翻译方法数，可以发现以下规律，

1. s[i] = 0，若s[i-1] == 1 or 2，则只有一种翻译方法，dp[i] = dp[i-1]；若s[i-1] 不等于 1 也不等于 2，则没法翻译，返回0
2. s[i] ≠ 0，若s[i-1] == 1 or 1 <= s[i] <= 6，则有两种翻译方法，可以单独译码当前位，也可以与之前位联合译码，dp[i] = dp[i-1]+dp[i-2]
3. 剩余情况就是当前位只能单独译码，dp[i]=dp[i-1]

因为只需要记录前面两位，所以可以不用辅助数组，只需要变量即可，空间复杂度降为O(1)，这样的一次遍历只需要时间O(n)

```c++
class Solution {
public:
    int numDecodings(string s) {
        if (s[0] == '0') return 0;
        int pre = 1, curr = 1; //dp[-1] = dp[0] = 1
        for (int i = 1; i < s.size(); i++) {
            int tmp = curr;
            if (s[i] == '0')
                if (s[i - 1] == '1' || s[i - 1] == '2') curr = pre;
                else return 0;
            else if (s[i - 1] == '1' || (s[i - 1] == '2' && s[i] >= '1' && s[i] <= '6'))
                curr = curr + pre;
            pre = tmp;
        }
        return curr;
    }
};
```

### 面试题47：礼物的最大价值

在一个 m×n 的棋盘的每一格都放有一个礼物，每个礼物都有一定的价值（价值大于0）。

你可以从棋盘的左上角开始拿格子里的礼物，并每次向右或者向下移动一格直到到达棋盘的右下角。

给定一个棋盘及其上面的礼物，请计算你最多能拿到多少价值的礼物？

注意：

m,n>0
样例：

输入： [ [2,3,1], [1,7,1], [4,6,1] ]

输出：19

解释：沿着路径 2→3→7→6→1 可以得到拿到最大价值礼物。

思路：动态规划，二维数组dp，先初始化第一行与第一列，它们只能从左往右和从上往下得到，然后双层循环，每次更新dp[i][j]时，将grid[i][j]加上dp[i-1][j]与dp[i][j-1]的较大值，最后返回dp[rows-1][cols-1]即可

```c++
class Solution {
public:
    int getMaxValue(vector<vector<int>> grid) {
        if(grid.empty() || grid[0].empty()) return 0;
        int rows = grid.size();
        int cols = grid[0].size();
        vector<vector<int>> dp (rows, vector<int>(cols)); // 初始化dp[][]
        // 初始化dp[][]的第一行，它们只能从左到右依次得到
        dp[0][0] = grid[0][0];
        for(int i = 1; i < cols; ++i){
            dp[0][i] = dp[0][i-1] + grid[0][i];
        }
        // 初始化dp[][]的第一列，它们只能从上到下依次得到
        for(int i = 1; i < rows; ++i){
            dp[i][0] = dp[i-1][0] + grid[i][0];
        }
        for(int i = 1; i < rows; ++i){
            for(int j = 1; j < cols; ++j){
                if(dp[i-1][j] > dp[i][j-1]){
                    dp[i][j] = dp[i-1][j] + grid[i][j];
                }
                else{
                    dp[i][j] = dp[i][j-1] + grid[i][j];
                }
            }
        }
        return dp[rows-1][cols-1];
    }
};
```

但继续分析，每次更新dp[i][j]时，只与dp[i-1][j]与dp[i][j-1]有关，也就是说之前的最大值没必要保存下来，这样我们可以节省为一个辅助数组，空间复杂度降为O(n)，一位数组长度为n，计算到坐标为(i,j)的格子时能够得到礼物的最大价值f(i,j)，数组中前j个数字分别是f(i,0),f(i,1),...,f(i,j-1)，数组从下标为j的数字开始到最后一个数字，分别是f(i-1,j),f(i-1,j+2),...,f(i-1,n-1)，也就是说，数组前j个数字分别是当前第i行前面j个格子礼物的最大价值，而之后的数字分别保存前面第i-1行n-j个格子礼物的最大价值

```c++
class Solution {
public:
    int getMaxValue(vector<vector<int>>& grid) {
        if(grid.empty() || grid[0].empty()) return 0;
        int rows = grid.size();
        int cols = grid[0].size();
        vector<int> dp (cols); // 初始化dp[]
        // 初始化dp[]的第一行，它们只能从左到右依次得到
        dp[0] = grid[0][0];
        for(int i = 0; i < rows; ++i){
            for(int j = 0; j < cols; ++j){
                if(i==0 && j==0){
                    continue;
                }
                else if(i == 0){
                    dp[j] = dp[j-1] + grid[i][j];
                }
                else if(j == 0){
                    dp[j] = dp[j] + grid[i][j];
                }
                else{
                    dp[j] = max(dp[j], dp[j-1]) + grid[i][j];
                }
            }
        }
        return dp[cols-1];
    }
};
```

### 面试题48：最长不重复字符串的子字符串

请从字符串中找出一个最长的不包含重复字符的子字符串，计算该最长子字符串的长度。

假设字符串中只包含从’a’到’z’的字符。

样例：

输入："abcabc"

输出：3

[AcWing OJ](https://www.acwing.com/problem/content/57/)

暴力法一次性AC，，时间O(n^2), 因为哈希表最多存储26项，所以当字符串比较长时，可以认为空间复杂度为O(1)，之所以用哈希表，是因为在哈希表中查找值只需要O(1)时间，不然要把新读入的数在已读子字符串中顺序扫描，又得花费O(n)时间，总的时间上升到O(n^3)

```c++
class Solution {
public:
    int longestSubstringWithoutDuplication(string s) {
        int len = 0;
        unordered_set<int> hash;
        for(int i = 0; i < s.size(); ++i){
            hash.clear();
            for(int j = i; j < s.size(); ++j){
                if(hash.find(s[j]) != hash.end()){
                    break;
                }
                hash.insert(s[j]);
                if(hash.size() > len){
                    len = hash.size();
                }
            }
        }
        return len;
    }
};
```

优化（自己想的）：之前的暴力版本，发现有重复的字母则最外层后移一位，但其实可以跳到重复字母那位的后面，比如abcdefc，第一次进入到了abcdef，得到最长len=6，然后再读一位发现与字符串第2位（从0开始）的c重复了，这时外层指针可以直接跳到字符串第3位，因为第1位和第2位开始的最长子字符串肯定会小于之前得到6

```c++
class Solution {
public:
    int longestSubstringWithoutDuplication(string s) {
        int len = 0;
        unordered_map<int, int> hash;
        int i = 0;
        int j = 0;
        int jumpFlag = false;
        while(i < s.size()){
            hash.clear();
            for(j = i; j < s.size(); ++j){
                if(hash.find(s[j]) != hash.end()){
                    jumpFlag = true;
                    break;
                }
                hash.insert(make_pair(s[j], j));
                if(hash.size() > len){
                    len = hash.size();
                }
            }
            if(jumpFlag){
                i = hash.find(s[j])->second + 1;
                jumpFlag = false;
            }
            else{
                ++i;
            }
        }
        return len;
    }
};
```

动态规划：

定义dp[i]表示以第i个字符结尾的不包含重复字符的子字符串的最长长度，我们从左到右逐一扫描字符串每个字符，如果第i个字符之前没出现过，则f(i)=f(i-1)+1，如果第i个字符之前出现过，找到最近那个，与i的距离为d。

如果d小于等于f(i-1)，则此时第i个字符上次出现在f(i-1)对应的最长子字符串中，因此f(i)=d，同时这也意味着在第i个字符出现两次所夹的字符串中再也没有其他重复的字符了

如果d大于f(i-1)，则此时第i个字符上次出现在f(i-1)对应的最长子字符串之前，因此仍然有f(i)=f(i-1)+1

```c++
class Solution {
public:
    int longestSubstringWithoutDuplication(string s) {
        if(s.empty()) return 0;
        if(s.size() == 1) return 1;
        vector<int> dict(26, -1); // 26个字母，每个元素上次出现的位置
        int cur = 1; // dp[0] = 1
        dict[s[0] - 'a'] = 0;
        int longest = 1;
        for(int i = 1; i < s.size(); ++i){
            int pre_index = dict[s[i] - 'a'];
            if(pre_index < 0 || i - pre_index > cur){
                ++cur;
            }
            else{
                cur = i - pre_index;
            }
            dict[s[i] - 'a'] = i;
            if(cur > longest) longest = cur;
        }
        return longest;
    }
};
```

### 面试题49：丑数

把只包含质因子2、3和5的数称作丑数（Ugly Number）。例如6、8都是丑数，但14不是，因为它包含质因子7。 习惯上我们把1当做是第一个丑数。求按从小到大的顺序的第N个丑数。

从1开始一个个判断显然时间复杂度太大，仔细观察发现，每个丑数肯定是另一个丑数乘以2or3or5得到的，所以可以创建一个数组，数组里面是排好序的丑数，现在主要问题是如何得到下一个丑数

我自己想的，效率很低，没有及时跳出来

```c++
class Solution {
public:
    int GetUglyNumber_Solution(int index) {
        if(index <= 0) return 0;
        vector<int> vec = {1};
        int pre_ugly = 1;
        int temp = 0;
        int closest = INT_MAX;
        for(int i = 1; i < index; ++i){
            for(int j = i - 1; j >= 0; --j){
                if(vec[j]*2 > pre_ugly && vec[j]*2 - pre_ugly < closest){
                    temp = vec[j]*2;
                    closest = vec[j]*2 - pre_ugly;
                }
                if(vec[j]*3 > pre_ugly && vec[j]*3 - pre_ugly < closest){
                    temp = vec[j]*3;
                    closest = vec[j]*3 - pre_ugly;
                }
                if(vec[j]*5 > pre_ugly && vec[j]*5 - pre_ugly < closest){
                    temp = vec[j]*5;
                    closest = vec[j]*5 - pre_ugly;
                }
                //if(vec[j]*5 <= pre_ugly) break; // 前面的丑数更小，不可能是下一个丑数
            }
            vec.push_back(temp);
            closest = INT_MAX;
            pre_ugly = temp;
        }
        return vec[vec.size()-1];
    }
};
```

参考书上的答案，感觉怪怪的，书上的三个指针没有重置的操作，我在每次循环时重置到头，在牛客网OJ上运行时间明显降低

```c++
class Solution {
public:
    int GetUglyNumber_Solution(int index) {
        if(index <= 0) return 0;
        vector<int> vec = {1};
        auto multiply2 = vec.begin();
        auto multiply3 = vec.begin();
        auto multiply5 = vec.begin();
        int pre_ugly = 1;
        for(int i = 1; i < index; ++i){
            multiply2 = vec.begin();
            multiply3 = vec.begin();
            multiply5 = vec.begin();
            while(*multiply2 * 2 <= pre_ugly) ++multiply2;
            while(*multiply3 * 3 <= pre_ugly) ++multiply3;
            while(*multiply5 * 5 <= pre_ugly) ++multiply5;
            pre_ugly = Min3(*multiply2 * 2, *multiply3 * 3, *multiply5 * 5);
            vec.push_back(pre_ugly);
        }
        return vec[vec.size()-1];
    }
    int Min3(int a, int b, int c){
        int min = (a < b) ? a : b;
        return (min < c) ? min : c;
    }
};
```

后来看了[解答](https://www.acwing.com/video/186/)，终于知道了为什么，这其实就是三路归并，跟排序有关

```c++
class Solution {
public:
    int GetUglyNumber_Solution(int index) {
        if(index <= 0) return 0;
        int p1=0,p2=0,p3=0;
        vector<int> vec;
        vec.push_back(1);
        int minv;
        while(vec.size() < index){
            minv=min(vec[p1]*2,min(vec[p2]*3,vec[p3]*5));
            if(vec[p1]*2==minv) p1++;
            if(vec[p2]*3==minv) p2++;
            if(vec[p3]*5==minv) p3++;
            vec.push_back(minv);
        }
        return vec.back();
    }
};
```

### 面试题50-1：第一个只出现一次的字符

牛客网的题目出的太烂了，找到[AcWing](https://www.acwing.com/problem/content/description/59/)上的

在字符串中找出第一个只出现一次的字符。

如输入"abaccdeff"，则输出b。

如果字符串中不存在只出现一次的字符，返回#字符。

样例：
输入："abaccdeff"

输出：'b'

用两个哈希表存储，一个存储出现过的字符(set)，一个存储只出现一次的字符以及其位置(map)

```c++
class Solution {
public:
    char firstNotRepeatingChar(string s) {
        unordered_map<char, int> hash;
        unordered_set<char> appeared;
        int first = s.size();
        for(int i = 0; i < s.size(); ++i){
            if(appeared.find(s[i]) == appeared.end()){
                hash[s[i]] = i;
                appeared.insert(s[i]);
            }
            else if(hash.find(s[i]) != hash.end()){
                hash.erase(hash.find(s[i]));
            }
        }
        // 现在hash保存只出现一次的字符
        for(auto it = hash.begin(); it != hash.end(); ++it){
            if(it->second < first) first = it->second;
        }
        if(first != s.size()){
            return s[first];
        }
        // 没有只出现一次的字符
        return '#';
    }
};
```

后来发现有点麻烦，因为char只需要256个字符，所以创建长度为256的数组即可，数组的元素记录了当前字符的出现次数

```c++
class Solution {
public:
    char firstNotRepeatingChar(string s) {
        vector<int> count(256);
        int first = s.size();
        for(int i = 0; i < s.size(); ++i){
            ++count[s[i]];
        }
        for(int i = 0; i < s.size(); ++i){
            if(count[s[i]] == 1) return s[i];
        }
        return '#';
    }
};
```

### 面试题50-2：字符流中第一个只出现一次的字符

[AcWing](https://www.acwing.com/problem/content/60/)，[nowcoder](https://www.nowcoder.com/practice/00de97733b8e4f97a3fb5c680ee10720?tpId=13&tqId=11207&tPage=1&rp=1&ru=/ta/coding-interviews&qru=/ta/coding-interviews/question-ranking)

请实现一个函数用来找出字符流中第一个只出现一次的字符。例如，当从字符流中只读出前两个字符"go"时，第一个只出现一次的字符是"g"。当从该字符流中读出前六个字符“google"时，第一个只出现一次的字符是"l"。
输出描述:
如果当前字符流没有存在出现一次的字符，返回#字符。

因为是字符流很长，不能全部存储下来，不过没关系，就像上题我自己想的那样，用哈希表（实际上用长度为256的数组表示），一个哈希表count表示出现次数，另外一个哈希表first表示只出现一次的字符出现的位置pos，在查找函数中，遍历first，在有效元素中（pos不等于-1）中查找最小的pos

注意ASCII中为0的字符是空字符，而'0'是序号为48的字符，`char(48)`返回`'0'`，`int('0')`返回`48`

```c++
class Solution{
public:
    vector<int> count;
    vector<int> first;
    int k = 0;
    //Insert one char from stringstream
    void insert(char ch){
        if(count.empty()){
            for(int i = 0; i < 256; ++i){
                count.push_back(0);
                first.push_back(-1);
            }
        }
        if(count[ch] == 0){
            first[ch] = k;
        }
        else{
            first[ch] = -1; // 之前出现过，-1失效
        }
        ++count[ch];
        ++k;
    }
    //return the first appearence once char in current stringstream
    char firstAppearingOnce(){
        int index = k;
        char ch = '0';
        for(int i = 0; i < first.size(); ++i){
            if(first[i] != -1 && first[i] < index){
                index = first[i];
                ch = i;
            }
        }
        if(index != k){
            return ch;
        }
        return '#';
    }
};
```

### 面试题51：数组中的逆序对

[AcWing](https://www.acwing.com/problem/content/61/)，牛客网的题目很奇怪

在数组中的两个数字如果前面一个数字大于后面的数字，则这两个数字组成一个逆序对。

输入一个数组，求出这个数组中的逆序对的总数。

样例
输入：[1,2,3,4,5,6,0]

输出：6

暴力，时间O(n^2)

```c++
class Solution {
public:
    int inversePairs(vector<int>& nums) {
        int count = 0;
        for(int i = 0; i < nums.size(); ++i){
            for(int j = i; j < nums.size(); ++j){
                if(nums[i] > nums[j]){
                    ++count;
                }
            }
        }
        return count;
    }
};
```

优化：归并排序的典型应用。归并排序的基本思想是分治，在治的过程中有前后数字的大小对比，此时就是统计逆序对的最佳时机。归并排序的时间复杂度为O(nlogn)，空间复杂度为O(n)

(a) 把长度为4的数组分解成两个长度为2的子数组；
(b) 把长度为2的数组分解成两个成都为1的子数组；
(c) 把长度为1的子数组 合并、排序并统计逆序对 ；
(d) 把长度为2的子数组合并、排序，并统计逆序对；

![20200124154056.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/20200124154056.png)

在上图（a）和（b）中，我们先把数组分解成两个长度为2的子数组，再把这两个子数组分别拆成两个长度为1的子数组。接下来一边合并相邻的子数组，一边统计逆序对的数目。在第一对长度为1的子数组{7}、{5}中7大于5，因此（7,5）组成一个逆序对。同样在第二对长度为1的子数组{6}、{4}中也有逆序对（6,4）。由于我们已经统计了这两对子数组内部的逆序对，因此需要把这两对子数组 排序 如上图（c）所示， 以免在以后的统计过程中再重复统计。

接下来我们统计两个长度为2的子数组子数组之间的逆序对。合并子数组并统计逆序对的过程如下图如下图所示。

我们先用两个指针分别指向两个子数组的末尾，并每次比较两个指针指向的数字。如果第一个子数组中的数字大于第二个数组中的数字，则构成逆序对，并且逆序对的数目等于第二个子数组中剩余数字的个数，如下图（a）和（c）所示。如果第一个数组的数字小于或等于第二个数组中的数字，则不构成逆序对，如图b所示。每一次比较的时候，我们都把较大的数字从后面往前复制到一个辅助数组中，确保 辅助数组（记为copy） 中的数字是递增排序的。在把较大的数字复制到辅助数组之后，把对应的指针向前移动一位，接下来进行下一轮比较。当前merge的最后，把辅助数组覆盖原数组的对应位置

过程：先把数组分割成子数组，先统计出子数组内部的逆序对的数目，然后再统计出两个相邻子数组之间的逆序对的数目。在统计逆序对的过程中，还需要对数组进行排序。如果对排序算法很熟悉，我们不难发现这个过程实际上就是归并排序

```c++
链接：https://www.nowcoder.com/questionTerminal/96bd6684e04a44eb80e6a68efc0ec6c5?f=discussion
来源：牛客网

    int InversePairs(vector<int> data) {
        int length  = data.size();
        return mergeSort(data, 0, length-1);
    }
    int mergeSort(vector<int>& data, int start, int end) {
        // 递归终止条件
        if(start >= end) {
            return 0;
        }
        // 递归
        int mid = (start + end) / 2;
        int leftCounts = mergeSort(data, start, mid); // 返回左半部分的逆序对
        int rightCounts = mergeSort(data, mid+1, end); // 返回右半部分的逆序对
        // 归并排序，并计算本次逆序对数
        vector<int> copy(data); // 数组副本，用于归并排序
        int foreIdx = mid;      // 前半部分的指标
        int backIdx = end;      // 后半部分的指标
        int counts = 0;         // 记录本次逆序对数
        int idxCopy = end;      // 辅助数组的下标
        while(foreIdx>=start && backIdx >= mid+1) {
            if(data[foreIdx] > data[backIdx]) {
                copy[idxCopy--] = data[foreIdx--];
                // mid~end已排序，backIdx遍历它的的指针，既然data[foreIdx]>data[backIdx]，那么data[foreIdx]也肯定大于data[mid+1] ... data[backIdx-1]，所以count加上backIdx到mid的距离即可
                counts += backIdx - mid;
            } else {
                copy[idxCopy--] = data[backIdx--];
            }
        }
        while(foreIdx >= start) {
            copy[idxCopy--] = data[foreIdx--];
        }
        while(backIdx >= mid+1) {
            copy[idxCopy--] = data[backIdx--];
        }
        // 覆盖原数组
        for(int i=start; i<=end; i++) {
            data[i] = copy[i];
        }
        return (leftCounts+rightCounts+counts);
    }
```

### 面试题52：两个链表的第一个公共结点

[AcWing](https://www.acwing.com/problem/content/62/)

输入两个链表，找出它们的第一个公共结点。

当不存在公共节点时，返回空节点。

样例
给出两个链表如下所示：

```c++
A：        a1 → a2
                   ↘
                     c1 → c2 → c3
                   ↗
B:     b1 → b2 → b3
```

输出第一个公共节点c1

暴力，在AcWing上超时了，时间复杂度为O(mn)

```c++
class Solution {
public:
    ListNode *findFirstCommonNode(ListNode *headA, ListNode *headB) {
        if(headA == nullptr || headB == nullptr) return nullptr;
        ListNode* nodeA = headA;
        ListNode* nodeB = headB;
        while(nodeA != nullptr){
            while(nodeB != nullptr){
                if(nodeA == nodeB){
                    return nodeA;
                }
                nodeB = nodeB->next;
            }
            nodeB = headB;
            nodeA = nodeA->next;
        }
        return nullptr;
    }
};
```

小优化：利用哈希表，用空间换时间，时间复杂度为O(m+n)，空间复杂度为O(m)，没超时

```c++
class Solution {
public:
    ListNode *findFirstCommonNode(ListNode *headA, ListNode *headB) {
        if(headA == nullptr || headB == nullptr) return nullptr;
        unordered_set<ListNode*> hash;
        ListNode* nodeA = headA;
        while(nodeA != nullptr){
            hash.insert(nodeA);
            nodeA = nodeA->next;
        }
        ListNode* nodeB = headB;
        while(nodeB != nullptr){
            if(hash.find(nodeB) != hash.end()){
                return nodeB;
            }
            nodeB = nodeB->next;
        }
        return nullptr;
    }
};
```

另一种小优化：因为两个链表若有重合，形状会像Y一样，我们可以对两个链表从头开始压入栈中，最后，两个栈顶元素是链表尾部元素，如果不同，则说明两个链表没有公共节点，如果相同，则两个栈同时弹出一个，比较次顶元素是否相同，按照这样的操作直到找到最后一个相同的节点，输出即可

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    ListNode *findFirstCommonNode(ListNode *headA, ListNode *headB) {
        if(headA == nullptr || headB == nullptr) return nullptr;
        stack<ListNode*> sa, sb;
        ListNode* nodeA = headA;
        ListNode* nodeB = headB;
        ListNode* same;
        while(nodeA != nullptr){
            sa.push(nodeA);
            nodeA = nodeA->next;
        }
        while(nodeB != nullptr){
            sb.push(nodeB);
            nodeB = nodeB->next;
        }
        if(sa.top() != sb.top()) return nullptr;
        while(!sa.empty() && !sb.empty() && sa.top() == sb.top()){
            same = sa.top();
            sa.pop();
            sb.pop();
        }
        return same;
    }
};
```

最优化：先把两个链表遍历完，记录各自长度len1,len2，让更长的链表先走`step=abs(len1-len2)`步，然后同步步进，每次判断是否相同，若相同则直接输出；若直到尾部都没有公共节点，则说明没有公共节点。该方法不需要辅助空间，只需要多遍历几次即可，时间复杂度仍为O(1)

```c++
class Solution {
public:
    ListNode *findFirstCommonNode(ListNode *headA, ListNode *headB) {
        if(headA == nullptr || headB == nullptr) return nullptr;
        ListNode* nodeA = headA;
        ListNode* nodeB = headB;
        int len1 = 0;
        int len2 = 0;
        int step = 0;
        while(nodeA != nullptr){
            nodeA = nodeA->next;
            ++len1;
        }
        while(nodeB != nullptr){
            nodeB = nodeB->next;
            ++len2;
        }
        nodeA = headA;
        nodeB = headB;
        if(len1 > len2){
            step = len1 - len2;
            while(step > 0){
                nodeA = nodeA->next;
                --step;
            }
            while(nodeA != nullptr && nodeB != nullptr){
                if(nodeA == nodeB){
                    return nodeA;
                }
                nodeA = nodeA->next;
                nodeB = nodeB->next;
            }
        }
        else{
            step = len2 - len1;
            while(step > 0){
                nodeB = nodeB->next;
                --step;
            }
            while(nodeA != nullptr && nodeB != nullptr){
                if(nodeA == nodeB){
                    return nodeA;
                }
                nodeA = nodeA->next;
                nodeB = nodeB->next;
            }
        }
        return nullptr;
    }
};
```

### 面试题53-1：统计一个数字在排序数组中出现的次数

例如输入排序数组[1, 2, 3, 3, 3, 3, 4, 5]和数字3，由于3在这个数组中出现了4次，因此输出4。

样例
输入：[1, 2, 3, 3, 3, 3, 4, 5] ,  3

输出：4

暴力只需要O(n)时间，一次遍历即可，但这显然不是面试官想要的答案

因为数组已排序，所以可以用二分查找，但是这里要找上下界，最开始我的思路是，先普通的二分查找找到target的某个下标i，再往左往右找到上下界，这个往左往右的逻辑搞晕了我，因为还需要这个方向还需要反向的。

后来看了书上的思路，先找二分查找数组的第一个k，当某次递归找到k时，设当前下标为i，如果i为0或nums[i-1]!=k，则直接返回i即可，此时i就是第一个k的下标，否则再往前二分查找，这样getFirstK的结果就是第一个k的下标first。然后二分查找最后一个k，当某次递归找到k时，设当前下标为i，如果i为nums.size()-1或nums[i+1]!=k，则直接返回i即可，此时i就是最后k的下标，否则再往后二分查找，这样getLastK的结果就是最后k的下标last。最后计算last-frist+1即可

```c++
class Solution {
public:
    int getNumberOfK(vector<int>& nums, int k) {
        if(nums.empty()) return 0;
        int first = getFirskK(nums, k, 0, nums.size()-1);
        if(first == -1) return 0;
        int last = getLastK(nums, k, 0, nums.size()-1);
        return last-first+1;
    }
    int getLastK(vector<int>& nums, int k, int low, int high){
        if(low > high) return -1;
        int mid = (low + high) / 2;
        if(nums[mid] == k){
            if(mid == nums.size()-1 || (mid < nums.size()-1 && nums[mid+1] != k)){
                return mid;
            }
            else{
                low = mid + 1;
            }
        }
        else if(nums[mid] > k){
            high = mid - 1;
        }
        else{
            low = mid + 1;
        }
        return getLastK(nums, k, low, high);
    }
    int getFirskK(vector<int>& nums, int k, int low, int high){
        if(low > high) return -1;
        int mid = (low + high) / 2;
        if(nums[mid] > k){
            high = mid - 1;
        }
        else if(nums[mid] < k){
            low = mid + 1;;
        }
        else if(mid == 0 || (mid > 0 && nums[mid-1] != k)){
            return mid;
        }
        else{
            high = mid - 1;
        }
        return getFirskK(nums, k, low, high);
    }
};
```

### 面试题53-2：到n-1中缺失的数字

[AcWing](https://www.acwing.com/problem/content/64/)

一个长度为n-1的递增排序数组中的所有数字都是唯一的，并且每个数字都在范围0到n-1之内。

在范围0到n-1的n个数字中有且只有一个数字不在该数组中，请找出这个数字。

样例
输入：[0,1,2,4]

输出：3

自己想的二分查找，发现该数组形如0 1 2 3（返回4），0 1 2 4（返回3），1 2 3 4（返回0），所以在二分查找时，判断mid是否等于nums[mid]即可，若等于，则往后查找，若不等于，则往前查找，注意mid等于0或nums.size()-1的情况

其实二分查找就是要找第一个值与下标不相等的元素

```c++
class Solution {
public:
    int getMissingNumber(vector<int>& nums) {
        if(nums.empty()) return 0;
        // eg: nums = {0,1,2,4}, {0,1,2,3,4,5,7,8,9}
        return binarySearch(nums, 0, nums.size()-1);
    }
    int binarySearch(vector<int>& nums, int low, int high){
        if(low > high) return -1;
        int mid = (low + high) / 2;
        if(nums[mid] == mid){
            // 形如0 1 2 3，当前mid=3，发现nums[mid]==mid&&mid==size()-1，所以返回mid+1
            // 或者形如0 1 2 4 5，当前mid=2，发现nums[mid]==mid&&nums[mid+1]!=mid+1，所以返回mid+1
            if(mid == nums.size()-1 || nums[mid+1] != mid+1) return mid + 1; 
            else low = mid + 1;
        }
        else{
            // 形如1 2 3 4，当前mid=0，发现nums[mid]!=mid&&mid==0，所以返回mid
            // 或者形如 0 2 3 4，当前mid=1，发现nums[mid]!=mid且nums[mid-1]==mid-1，所以返回mid
            if(mid == 0 || nums[mid-1] == mid-1) return mid;
            else high = mid - 1;
        }
        return binarySearch(nums, low, high);
    }
};
```

### 面试题53-3：数组中数值和下标相等的元素

假设一个单调递增的数组里的每个元素都是整数并且是唯一的。

请编程实现一个函数找出数组中任意一个数值等于其下标的元素。

例如，在数组[-3, -1, 1, 3, 5]中，数字3和它的下标相等。

样例
输入：[-3, -1, 1, 3, 5]

输出：3
注意:如果不存在，则返回-1。

二分查找一次性AC，这就很舒服诶！

```c++
class Solution {
public:
    int getNumberSameAsIndex(vector<int>& nums) {
        if(nums.empty()) return -1;
        return binarySearch(nums, 0, nums.size()-1);
    }
    int binarySearch(vector<int>& nums, int low, int high){
        if(low > high) return -1;
        int mid = (low + high) / 2;
        if(nums[mid] > mid){
            high = mid - 1;
        }
        else if(nums[mid] < mid){
            low = mid + 1;
        }
        else{
            return mid;
        }
        return binarySearch(nums, low, high);
    }
};
```

### 面试题54：二叉搜索树的第k个结点

给定一棵二叉搜索树，请找出其中的第k小的结点。

你可以假设树和k都存在，并且1≤k≤树的总结点数。

样例
输入：root = [2, 1, 3, null, null, null, null] ，k = 3

```c++
    2
   / \
  1   3
```

输出：3

第一次尝试，用中序遍历，存入vector中，当vector长度达到k时结束，但是需要O(n)的空间

```c++
class Solution {
public:
    TreeNode* kthNode(TreeNode* root, int k) {
        // 这不就是中序遍历序列的第k个节点（从1开始）吗
        if(root == nullptr || k < 1) return nullptr;
        vector<TreeNode*> vec;
        InOrderTraversal(root, vec, k);
        return vec[k-1];
    }
    void InOrderTraversal(TreeNode* root, vector<TreeNode*>& vec, int& k){
        if(root == nullptr) return;
        if(vec.size() == k) return;
        InOrderTraversal(root->left, vec, k);
        vec.push_back(root);
        InOrderTraversal(root->right, vec, k);
    }
};
```

后来想着，在递归时计数，书上的递归有点复杂，我把ans放在函数体外面，这样会容易理解一点

```c++
class Solution {
public:
    TreeNode* ans;
    TreeNode* kthNode(TreeNode* root, int k) {
        if(root == nullptr || k < 1) return nullptr;
        InOrderTraversal(root, k);
        return ans;
    }
    void InOrderTraversal(TreeNode* root, int& k){
        if(root == nullptr) return;
        InOrderTraversal(root->left, k);
        if(k == 1) ans = root;
        --k;
        InOrderTraversal(root->right, k);
    }
};
```

### 面试题55-1：二叉树的深度

[AcWing](https://www.acwing.com/problem/content/67/)

输入一棵二叉树的根结点，求该树的深度。

从根结点到叶结点依次经过的结点（含根、叶结点）形成树的一条路径，最长路径的长度为树的深度。

样例
输入：二叉树[8, 12, 2, null, null, 6, 4, null, null, null, null]如下图所示：
    8
   / \
  12  2
     / \
    6   4

输出：3

第一次尝试：之间递归遍历左右子树，递归函数的参数一个是当前深度cur，一个是已记录的最大深度depth，注意depth要用引用，这样可以修改实参的值

```c++
class Solution {
public:
    int treeDepth(TreeNode* root) {
        if(root == nullptr) return 0;
        int cur = 1;
        int depth = 1;
        treeDepthCore(root, cur, depth);
        return depth;
    }
    void treeDepthCore(TreeNode* root, int cur, int& depth){
        if(root == nullptr) return;
        if(cur > depth) depth = cur;
        treeDepthCore(root->left, cur+1, depth);
        treeDepthCore(root->right, cur+1, depth);
    }
};
```

书上的代码思路也很有借鉴意义，十分精简，可以不需要递归函数，如果一棵树只有一个节点，则它的深度为1，如果它只有左子树没有右子树，则它的深度为左子树深度+1，如果它只有右子树没有左子树，则它的深度为右子树深度+1，如果左右子树都有，则它的深度为左右子树深度的较大值+1

```c++
class Solution {
public:
    int treeDepth(TreeNode* root) {
        if(root == nullptr) return 0;
        int leftDepth = treeDepth(root->left);
        int rightDepth = treeDepth(root->right);
        return leftDepth > rightDepth ? leftDepth+1 : rightDepth+1;
    }
};
```

### 面试题55-2：平衡二叉树

输入一棵二叉树的根结点，判断该树是不是平衡二叉树。

如果某二叉树中任意结点的左右子树的深度相差不超过1，那么它就是一棵平衡二叉树。

注意：

规定空树也是一棵平衡二叉树。
样例
输入：二叉树[5,7,11,null,null,12,9,null,null,null,null]如下所示，
    5
   / \
  7  11
    /  \
   12   9

输出：true

首先想到，从根节点开始，依次往左右子树递归，比较左右子树深度之差是否大于1，但这样有很多重复的递归！

想了一会，一次性AC，诶嘿，很舒服，用上题的框架，如果不平衡则返回-1，如果平衡，则返回左右子树的深度差

```c++
class Solution {
public:
    bool isBalanced(TreeNode* root) {
        if(root == nullptr) return true;
        if(treeDepth(root) == -1){
            return false;
        }
        return true;
    }
    // returning -1 means unbalanced
    int treeDepth(TreeNode* root){
        if(root == nullptr) return 0;
        int leftDepth = treeDepth(root->left);
        int rightDepth = treeDepth(root->right);
        if((leftDepth == -1 || rightDepth == -1) || (leftDepth - rightDepth > 1 || rightDepth - leftDepth > 1)){
            return -1;
        }
        return leftDepth > rightDepth ? leftDepth+1 : rightDepth+1;
    }
};
```

### 面试题56-1：数组中只出现一次的两个数字

[AcWing](https://www.acwing.com/problem/content/69/)

一个整型数组里除了两个数字之外，其他的数字都出现了两次。

请写程序找出这两个只出现一次的数字。

你可以假设这两个数字一定存在。

样例
输入：[1,2,3,3,4,4]

输出：[1,2]

第一次尝试：用哈希表存储访问过的数字，若出现过，则删除掉，若没出现，则加入。这种方法没有用到数组的特点，时空都是O(n)，第二次AC

```c++
class Solution {
public:
    vector<int> findNumsAppearOnce(vector<int>& nums) {
        if(nums.empty()) return vector<int>();
        vector<int> vec;
        unordered_set<int> hash;
        for(int i = 0; i < nums.size(); ++i){
            if(hash.find(nums[i]) == hash.end()){
                hash.insert(nums[i]);
            }
            else{
                hash.erase(hash.find(nums[i]));
            }
        }
        for(auto it = hash.begin(); it != hash.end(); ++it){
            vec.push_back(*it);
        }
        return vec;
    }
};
```

优化：数字的异或，时间复杂度为O(n)，空间复杂度为O(1)

因为以前做过只有一个数字出现过一次，其他数字都出现过两次的题目，那个题目可以用异或操作，把数组所有数字异或，最后的结果就是那个只出现过一次的数字，其他成对出现的数字都抵消了。那对于这题，可以把数组分成两个子数组，如果恰好把这两个只出现一次的数字各自分到这两个子数组中，而其他成对出现的数字也是成对的放入两个子数组中，那么问题就可以转换为之前那题的做法，这里的问题是如何划分这两个非常有特点的子数组

可以这样操作，设这两个只出现一次的数字是a与b，先把所有数字异或一遍，得到的结果sum=a xor b，sum肯定不为0，sum的二进制表示肯定有某位是1，根据该位是不是1来区分子数组，a与b肯定会划分到不同的子数组，而其他的成对的数字肯定会成对的进入其中一个子数组

但注意`&`是按位与操作符，例如`5&1=1, 5&4=4, 5&2=0`，所以在判断某个数字num第i位（从0开始）是否为1时，不能直接与2的i次方比较，而应该右移i位，再&1

```c++
class Solution {
public:
    vector<int> findNumsAppearOnce(vector<int>& nums) {
        if(nums.empty()) return vector<int>();
        int xorsum = 0;
        int digit = 0;
        int num1 = 0;
        int num2 = 0;
        for(int i = 0; i < nums.size(); ++i){
            xorsum ^= nums[i];
        }
        while((xorsum & 1) == 0){
            xorsum = xorsum >> 1;
            ++digit;
        }
        // 根据二进制的第i位是否为1来划分两个子数组，子数组中只有一个只出现一次的数字，异或后的结果就是它自己
        for(int i = 0; i < nums.size(); ++i){
            if(isKthBit1(nums[i], digit)) num1 ^= nums[i];
            else num2 ^= nums[i];
        }
        vector<int> vec {num1, num2};
        return vec;
    }
    bool isKthBit1(int num, int digit){
        while(digit > 0){
            num = num >> 1;
            --digit;
        }
        if((num & 1) == 1) return true;
        return false;
    }
};
```

### 面试题56-2：数组中唯一只出现一次的数字

在一个数组中除了一个数字只出现一次之外，其他数字都出现了三次。

请找出那个只出现一次的数字。

你可以假设满足条件的数字一定存在。

思考题：

如果要求只使用 O(n) 的时间和额外 O(1) 的空间，该怎么做呢？
样例
输入：[1,1,1,2,2,2,3,4,4,4]

输出：3

思路：

1. 这道题中数字出现了三次，无法像数组中只出现一次的两个数字一样通过利用异或位运算进行消除相同个数字。但是仍然可以沿用位运算的思路。
2. 将所有数字的二进制表示的对应位都加起来，如果某一位能被三整除，那么只出现一次的数字在该位为0；反之，为1。
3. 一个int型有32位，每一位不是0就是1。对于三个相同的数，统计每一位出现的频率（可以用一个长度为32的数组记录），那么每一位的频率的和一定能被3整除，
4. 也就是说频率和不是3就是0。如果有多组三个相同的数，统计的结果也是类似：频率和不是0就是3的倍数。现在其中混进了一个只出现一次的数，没关系也统计到频率和中。
5. 如果第n位的频率和还是3的倍数，说明只出现一次的这个数第n位是0；如果不能被3整除了，说明只出现一次的这个数第n位是1。由此可以确定这个只出现一次的数的二进制表示，进而求出该数据。

```c++
class Solution {
public:
    int findNumberAppearingOnce(vector<int>& nums) {
        vector<int> bitSum (32); // int型有32位，统计每一位上出现1的次数
        int bit = 0;
        int num = 0;
        int ans = 0;
        for(int i = 0; i < nums.size(); ++i){
            bit = 0;
            num = nums[i];
            while(bit < 32){
                if(num & 1){
                    ++bitSum[bit];
                }
                num = num >> 1;
                ++bit;
            }
        }
        for(int i = 0; i < 32; ++i){
            // 当前位的频率和不是3的倍数，说明ans在这位肯定是1
            if(bitSum[i] % 3 != 0){
                ans += pow(2, i);
            }
        }
        return ans;
    }
};
```

### 面试题57-1：和为S的两个数字

[AcWing](https://www.acwing.com/problem/content/71/)

输入一个数组和一个数字s，在数组中查找两个数，使得它们的和正好是s。

如果有多对数字的和等于s，输出任意一对即可。

你可以认为每组输入中都至少含有一组满足条件的输出。

样例
输入：[1,2,3,4] , sum=7

输出：[3,4]

用哈希表存储已经出现过的数字，一次遍历即可，每次遍历时有当前值nums[i]，判断哈希表是否有target-nums[i]，若有则直接返回，若没有则再判断哈希表是否有nums[i]，若没有则nums[i]加入哈希表

```c++
class Solution {
public:
    vector<int> findNumbersWithSum(vector<int>& nums, int target) {
        unordered_set<int> hash;
        vector<int> ans;
        for(int i = 0; i < nums.size(); ++i){
            if(hash.find(target-nums[i]) == hash.end()){
                if(hash.find(nums[i]) == hash.end()){
                    hash.insert(nums[i]);
                }
            }
            else{
                ans.push_back(nums[i]);
                ans.push_back(target-nums[i]);
                break;
            }
        }
        return ans;
    }
};
```

书本上的题目和AcWing的不一样，输入的数组是递增排序的，这其实很简单，不用辅助空间可以实现O(n)，只需要双指针low与high，开始时一个指向头一个指向尾，若nums[low]+nums[high] = target，直接返回nums[low]与nums[high]；若大于，--high；若小于，++low

### 面试题57-2：和为S的连续正数序列

输入一个正数s，打印出所有和为s的连续正数序列（至少含有两个数）。

例如输入15，由于1+2+3+4+5=4+5+6=7+8=15，所以结果打印出3个连续序列1～5、4～6和7～8。

样例
输入：15

输出：[[1,2,3,4,5],[4,5,6],[7,8]]

自己想的，全都在注释里面了，主要思想是判断每个len是否可能是序列的长度，需要根据len的奇偶性与avg的值来判断，感觉也还不错

```c++
class Solution {
public:
    vector<vector<int> > findContinuousSequence(int sum) {
        // 这种连续正数序列vec肯定满足：vec.avg()*vec.size()=sum
        // 而vec.avg()肯定是0.5的倍数
        // vec.avg()-vec.size()/2 肯定要大于0，也就是序列开头肯定要大于0
        if(sum < 3) return vector<vector<int> >();
        vector<vector<int> > ans;
        vector<int> vec;
        int len = 3;
        if(sum % 2){
            ans.push_back(vector<int>{sum/2, sum/2+1});
        }
        while(len < sum/2){
            // 如果avg是整数
            if((double) sum/len == sum/len){
                // 如果len是奇数且序列开头大于0
                if(len&1 && sum/len-len/2 > 0){
                    for(int num = sum/len-len/2; num <= sum/len+len/2; ++num){
                        vec.push_back(num);
                    }
                    ans.push_back(vec);
                    vec.clear();
                }
            }
            // 如果avg不是整数但是是0.5的倍数
            else if((double) sum*2/len == sum*2/len){
                // 如果len是偶数且序列开头大于0
                if(!(len&1) && sum/len+1-len/2 > 0){
                    for(int num = sum/len+1-len/2; num <= sum/len+len/2; ++num){
                        vec.push_back(num);
                    }
                    ans.push_back(vec);
                    vec.clear();
                }
            }
            ++len;
        }
        return ans;
    }
};
```

看了书上的解答，巧妙运用双指针，应该比我的更简洁，这其实就是滑动窗口的思想，窗口的左右指针只能往后移动

1. 设置两个指针i和j，分别指向连续正数序列的起始和终止
2. 用tempSum表示当前连续正数序列的和，即tempSum=i+(i+1)+…+j
3. 以i递增的方式遍历前半个数列(1到(sum+1)/2)，代表查找以i开头的时候结尾j应该是多少。当`tempSum<sum`时，说明当前窗口太小，j应该往后移动；当`tempSum==sum`说明满足题意；当`tempSum>sum`，说明窗口太小，i向后走即可。
4. 每次移动时，窗口的和只需要加一项或者减一项，所以每次移动可以顺便记录，满足题意时直接加入

注意上述遍历过程中，s=sums=sum的情况下不需要把j往前移动，原因是当进入下一个循环前s−=is−=i，即(i+1)到j的和肯定小于sum。

```c++
class Solution {
public:
    vector<vector<int> > findContinuousSequence(int sum) {
        if(sum < 3) return vector<vector<int> >();
        vector<vector<int> > ans;
        vector<int> vec;
        int low = 1;
        int high = 2;
        int tempSum = low + high;
        while(low <= (sum+1)/2){
            if(tempSum == sum){
                for(int num = low; num <= high; ++num){
                    vec.push_back(num);
                }
                ans.push_back(vec);
                vec.clear();
                ++high;
                tempSum +=high;
            }
            else if(tempSum > sum){
                tempSum -= low;
                ++low;
            }
            else{
                ++high;
                tempSum +=high;
            }
        }
        return ans;
    }
};
```

### 面试题58-1：翻转字符串

输入一个英文句子，翻转句子中单词的顺序，但单词内字符的顺序不变。

为简单起见，标点符号和普通字母一样处理。

例如输入字符串"I am a student."，则输出"student. a am I"。

样例
输入："I am a student."

输出："student. a am I"

第一次尝试：先把整个字符串翻转，然后用空格分开，碰到下一个空格时翻转前面的子字符串，指向当前子字符串头部的迭代器需要在翻转之后重置，并且还需要在上一个是空格，当前不是空格时重置，注意别忘了当跳出for循环时，最后一个单词还没有翻转

```c++
class Solution {
public:
    string reverseWords(string s) {
        if(s.empty()) return "";
        if(s.size() == 1) return s;
        reverse(s.begin(), s.end());
        auto first = s.begin();
        for(auto it = s.begin()+1; it != s.end(); ++it){
            if(*it == ' '){
                reverse(first, it);
                first = it;
            }
            else if(*(it-1) == ' '){
                first = it;
            }
        }
        reverse(first, s.end());
        return s;
    }
};
```

如果面试官要求自己写出reverse函数，还可以证明自己会模板元编程

```c++
    template <class iterator>
    void reverse(iterator first, iterator last){
        int len = 0;
        iterator cur = first;
        while(cur != last){
            ++cur;
            ++len;
        }
        for(int i = 0; i < len/2; ++i){
            swap(*(first+i), *(last-1-i));
        }
    }
```

### 题目58-2：左旋转字符串

[AcWing](https://www.acwing.com/problem/content/74/)

字符串的左旋转操作是把字符串前面的若干个字符转移到字符串的尾部。

请定义一个函数实现字符串左旋转操作的功能。

比如输入字符串"abcdefg"和数字2，该函数将返回左旋转2位得到的结果"cdefgab"。

注意：

数据保证n小于等于输入字符串的长度。
样例
输入："abcdefg" , n=2

输出："cdefgab"

一次性AC没压力，但用到了辅助空间，我觉得这题实际上考的是原地修改数组，不用额外辅助空间

```c++
class Solution {
public:
    string leftRotateString(string str, int n) {
        if(n == 0) return str;
        n = n % len;
        string leftStr (str.begin(), str.begin()+n);
        string rightStr (str.begin()+n, str.end());
        return rightStr + leftStr;
    }
};
```

用三次旋转可以不需要辅助空间，先翻转整个字符串，再翻转前size-n长度的子字符串，再翻转后n长度的字符串

```c++
class Solution {
public:
    string leftRotateString(string str, int n) {
        if(n == 0) return str;
        int len = str.size();
        n = n % len;
        reverse(str.begin(), str.end());
        reverse(str.begin(), str.begin()+len-n);
        reverse(str.begin()+len-n, str.end());
        return str;
    }
};
```

### 面试题59-1：滑动窗口的最大值

[AcWing](https://www.acwing.com/problem/content/75/)

给定一个数组和滑动窗口的大小，请找出所有滑动窗口里的最大值。

例如，如果输入数组[2, 3, 4, 2, 6, 2, 5, 1]及滑动窗口的大小3,那么一共存在6个滑动窗口，它们的最大值分别为[4, 4, 6, 6, 6, 5]。

注意：

数据保证k大于0，且k小于等于数组长度。
样例
输入：[2, 3, 4, 2, 6, 2, 5, 1] , k=3

输出: [4, 4, 6, 6, 6, 5]

暴力双层循环，时间复杂度O(mn)，一次性AC

```c++
class Solution {
public:
    vector<int> maxInWindows(vector<int>& nums, int k) {
        if(nums.empty() || k < 1) return vector<int>();
        vector<int> maxVec;
        int curMax = 0;
        for(int i = 0; i < nums.size()-k+1; ++i){
            curMax = nums[i];
            for(int j = i+1; j < i+k; ++j){
                if(nums[j] > curMax) curMax = nums[j];
            }
            maxVec.push_back(curMax);
        }
        return maxVec;
    }
};
```

想着进一步优化，看能不能加快窗口内取最大值的效率，但发现得用额外的辅助空间来操作，比如用红黑树，插入删除O(logn)，查找最大值O(1)，但这还不是最优的

优化：时间复杂度为O(n)，空间复杂度为O(1)，用到了双端队列（STL容器deque）

1. 窗口向右滑动的过程实际上就是将处于窗口的第一个数字删除，同时在窗口的末尾添加一个新的数字，这就可以用双向队列来模拟，每次把尾部的数字弹出，再把新的数字压入到头部，然后找队列中最大的元素即可。
2. 为了更快地找到最大的元素，我们可以在队列中只保留那些可能成为窗口最大元素的数字，去掉那些不可能成为窗口中最大元素的数字。考虑这样一个情况，如果队列中进来一个较大的数字，那么队列中比这个数更小的数字就不可能再成为窗口中最大的元素了，因为这个大的数字是后进来的，一定会比之前早进入窗口的小的数字要晚离开窗口，那么那些早进入且比较小的数字就“永无出头之日”，所以就可以弹出队列。
3. 于是我们维护一个双向单调队列，队列放的是元素的下标。我们假设该双端队列的队头是整个队列的最大元素所在下标，至队尾下标代表的元素值依次降低。初始时单调队列为空。随着对数组的遍历过程中，每次插入元素前，首先需要看队头是否还能留在队列中，如果当前下标距离队头下标超过了k，则应该出队。同时需要维护队列的单调性，如果nums[i]大于或等于队尾元素下标所对应的值，则当前队尾再也不可能充当某个滑动窗口的最大值了，故需要队尾出队，直至队列为空或者队尾不小于nums[i]。
4. 始终保持队中元素从队头到队尾单调递减。依次遍历一遍数组，每次队头就是每个滑动窗口的最大值所在下标。

```c++
class Solution {
public:
    vector<int> maxInWindows(vector<int>& nums, int k) {
        if(nums.empty() || k < 1) return vector<int>();
        vector<int> maxVec;
        deque<int> dq;
        dq.push_back(0);
        for(int i = 1; i < k; ++i){
            while(!dq.empty() && nums[i] > nums[dq.back()]){
                dq.pop_back();
            }
            dq.push_back(i);
        }
        maxVec.push_back(nums[dq.front()]);
        for(int i = k; i < nums.size(); ++i){
            if(!dq.empty() && i - dq.front() >= k){
                dq.pop_front();
            }
            while(!dq.empty() && nums[i] > nums[dq.back()]){
                dq.pop_back();
            }
            dq.push_back(i);
            maxVec.push_back(nums[dq.front()]);
        }
        return maxVec;
    }
};
```

### 面试题59-2：队列的最大值

定义一个队列并实现函数max得到队列里的最大值，要求max、push_back、pop_front的时间复杂度都为O(1)

没有OJ，我自己想的是用两个队列来模拟。每当插入一个元素，其中一个队列就如普通队列一样先进先出，另一个队列则比较最后一个元素与插入元素的大小，若大于插入元素，则插入该元素到队尾；若小于插入元素，则把队尾修改成新插入元素，再往前如果还是大于插入元素，继续修改，直到队头或者有数大于插入元素，最后再插入新插入元素。每当删除一个元素，两个队列直接pop队头即可

书上说这题可以用滑动窗口的思想来做，但是代码写的太特殊了，还定义了结构体，而且在push_back时也像我一样需要从队尾往前修改