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

### 面试题18：删除链表的节点

题目：给定单向链表的头指针和一个结点指针，定义一个函数在0（1）时间删除该结点。

在单向链表中删除一个结点，最常规的做法无疑是从链表的头结点开始，顺序遍历查找要删除的结点，并在链表中删除该结点。

之所以需要从头开始查找，是因为我们需要得到将被删除的结点的前面一个结点。在单向链表中，结点中没有指向前一个结点的指针，所以只好从链表的头结点开始顺序查找。

那是不是一定需要得到被删除的结点的前一个结点呢？答案是否定的。我们可以很方便地得到要删除的结点的一下结点。如果我们把下一个结点的内容复制到需要删除的结点上覆盖原有的内容，再把下一个结点删除，那是不是就相当于把当前需要删除的结点删除了？

### 删除链表中的重复节点

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

### 面试23：链表中环的入口结点

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

### 面试题32：从上到下打印二叉树

#### 题目一：不分行从上到下打印二叉树

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

#### 题目二：分行从上到下打印二叉树

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

#### 题目三：之字形打印二叉树

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
