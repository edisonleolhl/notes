# 笔记

## Chapter3

### 尾递归（tail recursion）

阮一峰的文章：[《尾调用优化》](https://www.ruanyifeng.com/blog/2015/04/tail-call.html)
知乎上的[讨论](https://www.zhihu.com/question/20761771、https://www.zhihu.com/question/49368021)
知乎上的高赞回答：尾递归，比线性递归多一个参数，这个参数是上一次调用函数得到的结果；所以，关键点在于，尾递归每次调用都在收集结果，避免了线性递归不收集结果只能依次展开消耗内存的坏处

尾递归是指在函数的最后一行对函数自身进行的递归调用，注意这里不能有表达式，也就是说不能有`return f(x) + f(x-1)`或`return f(x)+1`这种形式

- 有些编译器能自动识别尾递归，避免保存多个栈帧，编译器会把尾递归换成循环，这就叫做**尾递归优化**
- 尾递归一般都可以改写成循环，很多人认为循环在大部分场景中递归更加自然，符合人类直觉逻辑
- 个人认为在编译器支持优化的前提下，尾递归和循环都可，程序员擅长哪个就用哪个（反正编译器会把尾递归优化成循环

## Chapter4 树

### 预备知识

二叉查找树(binary search tree)是C++中`set`和`map`实现的基础

树(ree)可以用几种方式定义。定义树的一种自然的方式是递归的方式。一棵树是一些节点(node)的集合。这个集合可以是空集;若不是空集,则树由称做根(root)的节点r以及0个或多个非空的(子)树T1,T2,…,Tk组成,这些子树中每一棵的根都被来自根r的一条有向的边(edge)所连接

每一颗子树的根叫做根r的儿子(child)，而r是每一颗子树的根的父亲(parent)

没有儿子的节点称为树叶(leaf)，具有相同父亲的节点称为兄弟(siblings)，祖父(grandparent)、孙子(grandchild)同理

对任意节点ni，ni的深度(depth)是从跟到ni的唯一路径(path)的长，根的深度为0，一棵树的深度等于其最深的树叶的深度

节点ni的高(height)是从ni到一片树叶的最长路径的长度，树叶的高为0，一棵树的高度等于其根的高度

不难发现，一棵树的深度等于这棵树的高度

如果存在一条从n1到n2的路径，那么n1是n2的一位祖先(ancestor)，n2是n1的一个后裔(descendant)，如果n1≠n2，则为真祖先、真后裔

#### 树的实现

因为每个节点的儿子树可以变化很大而且实现不知道，所以在数据结构中直接建立到各儿子节点直接的链接是不可行的，一般可以用第一儿子/下一兄弟表示法(First child/next sibling representation)

```c++
1 struct TreeNode
2 {
3   Object element;
4   TreeNode *firstChild;
5   TreeNode *nextSibling;
6 };
```

#### 树的遍历及其应用

UNIX文件系统就是用树来实现的（准确来说是类树(treelike)），比如`/usr/mark/book/ch1.r`中的第一个`/`后的每一个`/`都代表一条边，结果为一完整路径名(pathname)

![unixdirectory.png](http://ww1.sinaimg.cn/large/005GdKShly1g9vbnx0wfbj30r70b1dgy.jpg)

先序遍历(preorder traversal)，对节点的处理工作在它的儿子节点被处理之前(pre)进行的，比如下面的伪代码，将深度为di的文件用di次tab缩进输出，可以看到首先就输出了当前节点，然后再去对儿子节点进行操作

```c++
void FileSystem::listAll( int depth = 0 ) const
{
    printName( depth ); // Print the name of the object
    if( isDirectory( ) )
    for each file c in this directory (for each child)
    c.listAll( depth + 1 );
}
```

![directorylisting.png](http://ww1.sinaimg.cn/large/005GdKShly1g9vboh1d8pj309e0h2mxm.jpg)

后序遍历(postorder traversal)，对节点的处理工作在它的儿子节点被处理之后(post)进行的，比如UNIX文件系统中的每个文件（目录也算文件）都占用一定的磁盘区块(disk block)，我们想统计该树所有文件占用的磁盘区块的总数，可以用后序遍历的伪代码实现，首先判断当前节点是否为目录，如果是目录则先发现其儿子节点中的块总数，再加上当前节点的块数，如果不是目录则直接返回它本身的块数

![unixdirectorywithsize.png](http://ww1.sinaimg.cn/large/005GdKShly1g9vbp1ukkwj30h706w0tj.jpg)

```c++
int FileSystem::size( ) const
{
    int totalSize = sizeOfThisFile( );
    if( isDirectory( ) )
    for each file c in this directory (for each child)
    totalSize += c.size( );
    return totalSize;
}
```

![traceofthesizefunction.png](http://ww1.sinaimg.cn/large/005GdKShly1g9vbppfd34j308r0h2q3j.jpg)

中序遍历(inorder traversal)，顾名思义

### 二叉树

二叉树(binary tree)是一棵树，其中每个节点都不能有多于两个的儿子

二叉树平均深度为O(根号N)，二叉查找树(binary search tree)的平均深度O(logN)，而对于N个节点的二叉树，最大深度可以达到N-1

#### 实现

因为二叉树的每个节点的儿子数量最多为2，所以可以直接链接

```c++
struct BinaryNode
{
    Object element; // The data in the node
    BinaryNode *left; // Left child
    BinaryNode *right; // Right child
};
```

#### 例子——表达式树(expression tree)

表达式树是**分析树(parse tree)**的一个例子，分析树是更一般的结构，广泛应用于编译器设计中，是其中的核心数据结构

表达式树的树叶是操作数(operand)，如常数或变量名字，而其他的节点为操作符(operator)，如果操作符都是二元的，这就是一棵二叉树

![expressiontree.png](http://ww1.sinaimg.cn/large/005GdKShly1g9vcq87c7sj30hr07zq3n.jpg)

中序遍历对应中缀表达式，后序遍历对应后缀表达法，先序遍历对应前缀记法

后缀表达式转换为表达式树

### 查找树ADT——二叉查找树

二叉树在搜索中有很重要的应用

使二又树成为二又查找树的性质是,对于树中的每个节点X,它的左子树中所有项的值均小于X中的项,而它的右子树中所有项的值均大于X中的项。注意,这意味着,该树所有的元素可以用某种一致的方式排序

因为树的递归定义，所以对树的很多操作都可以迭代来实现，因为树的平均深度为O(logN)，一般不考虑栈空间被用尽

二叉搜索树类模板的接口如下

```c++
    1 template <typename Comparable>
    2 class BinarySearchTree
    3 {
        4 public:
            5 BinarySearchTree( );
            6 BinarySearchTree( const BinarySearchTree & rhs );
            7 BinarySearchTree( BinarySearchTree && rhs );
            8 ~BinarySearchTree( );
            9
            10 const Comparable & findMin( ) const;
            11 const Comparable & findMax( ) const;
            12 bool contains( const Comparable & x ) const;
            13 bool isEmpty( ) const;
            14 void printTree( ostream & out = cout ) const;
            15
            16 void makeEmpty( );
            17 void insert( const Comparable & x );
            18 void insert( Comparable && x );
            19 void remove( const Comparable & x );
            20
            21 BinarySearchTree & operator=( const BinarySearchTree & rhs );
            22 BinarySearchTree & operator=( BinarySearchTree && rhs );
        23
        24 private:
            25 struct BinaryNode
                26 {
                27 Comparable element;
                28 BinaryNode *left;
                29 BinaryNode *right;
                30
                31 BinaryNode( const Comparable & theElement, BinaryNode *lt, BinaryNode *rt )
                32 : element{ theElement }, left{ lt }, right{ rt } { }
                33
                34 BinaryNode( Comparable && theElement, BinaryNode *lt, BinaryNode *rt )
                35 : element{ std::move( theElement ) }, left{ lt }, right{ rt } { }
            36 };
        37
        38 BinaryNode *root;
        39
        40 void insert( const Comparable & x, BinaryNode * & t );
        41 void insert( Comparable && x, BinaryNode * & t );
        42 void remove( const Comparable & x, BinaryNode * & t );
        43 BinaryNode * findMin( BinaryNode *t ) const;
        44 BinaryNode * findMax( BinaryNode *t ) const;
        45 bool contains( const Comparable & x, BinaryNode *t ) const;
        46 void makeEmpty( BinaryNode * & t );
        47 void printTree( BinaryNode *t, ostream & out ) const;
        48 BinaryNode * clone( BinaryNode *t ) const;
    49 };
```

在这里用到了一个技巧；public成员函数调用private的递归函数，个人猜想这种风格更加健壮

#### contains 递归函数

public成员函数实现如下

```c++
    1 /**
    2 * Returns true if x is found in the tree.
    3 */
    4 bool contains( const Comparable & x ) const
    5 {
    6 return contains( x, root );
    7 }
```

private递归函数实现如下

```c++
    1 /**
    2 * Internal method to test if an item is in a subtree.
    3 * x is item to search for.
    4 * t is the node that roots the subtree.
    5 */
    6 bool contains( const Comparable & x, BinaryNode *t ) const
    7 {
        8 if( t == nullptr )
            9 return false;
        10 else if( x < t->element )
            11 return contains( x, t->left );
        12 else if( t->element < x )
            13 return contains( x, t->right );
        14 else
            15 return true; // Match
    16 }
```

注意测试的顺序，首先要对是否是空树进行判断，剩下的测试使得最不可能的情况安排在最后进行；还有，这里的两个递归调用都是尾递归，尾递归可以用while循环代替，在第三章详细说明了尾递归，不再赘述

#### findmax与findmin

由于二叉查找树的特殊性，从根开始只要有左儿子就向左查找，终止点就是最小的元素；从根开始只要有右儿子就向右查找，终止点就是最大的元素，这里给出findmin的递归实现与findmax的循环实现，注意空树的退化情况，对于递归程序尤其重要

```c++
    1 /**
    2 * Internal method to find the smallest item in a subtree t.
    3 * Return node containing the smallest item.
    4 */
    5 BinaryNode * findMin( BinaryNode *t ) const
    6 {
    7   if( t == nullptr )
    8       return nullptr;
    9   if( t->left == nullptr )
    10      return t;
    11  return findMin( t->left );
    12 }
```

```c++
    1 /**
    2 * Internal method to find the largest item in a subtree t.
    3 * Return node containing the largest item.
    4 */
    5 BinaryNode * findMax( BinaryNode *t ) const
    6 {
    7   if( t != nullptr )
    8       while( t->right != nullptr )
    9           t = t->right;
    10  return t;
    11 }
```

#### insert

public成员函数实现如下

```c++
9 /**
10 * Insert x into the tree; duplicates are ignored.
11 */
12 void insert( const Comparable & x )
13 {
14  insert( x, root );
15 }
```

private递归函数如下，与private版本的contains很像

```c++
1 /**
2 * Internal method to insert into a subtree.
3 * x is the item to insert.
4 * t is the node that roots the subtree.
5 * Set the new root of the subtree.
6 */
7 void insert( const Comparable & x, BinaryNode * & t )
8 {
9   if( t == nullptr )
10      t = new BinaryNode{ x, nullptr, nullptr };
11  else if( x < t->element )
12      insert( x, t->left );
13  else if( t->element < x )
14      insert( x, t->right );
15  else
16      ; // Duplicate; do nothing
17 }
18
19 /**
20 * Internal method to insert into a subtree.
21 * x is the item to insert by moving.
22 * t is the node that roots the subtree.
23 * Set the new root of the subtree.
24 */
25 void insert( Comparable && x, BinaryNode * & t )
26 {
27  if( t == nullptr )
28      t = new BinaryNode{ std::move( x ), nullptr, nullptr };
29  else if( x < t->element )
30      insert( std::move( x ), t->left );
31  else if( t->element < x )
32      insert( std::move( x ), t->right );
33  else
34      ; // Duplicate; do nothing
35 }
```

在上面代码中，对于重复元的操作是什么也不做，当然可以按需编写代码，比如在节点中添加一个附加域用来指示次数

#### remove

正如许多数据结构一样，删除是比较复杂的操作，有三种可能情况需要考虑

1. 如果待删除节点是一片树叶，直接删除即可，这是最简单的情况
2. 如果待删除节点只有一个儿子，则可以在待删除节点的父节点中调整它的链来绕过待删除节点，直达子节点
    ![deletenode2.png](http://ww1.sinaimg.cn/large/005GdKShly1g9ve9ke5qrj30md0a2dgm.jpg)
3. 如果待删除节点有两个儿子，一般的删除策略是用待删除节点的右子树的最小节点（很容易找到）来**代替**该节点并删除那个最小节点，因为最小节点的左子树肯定为空，所以其删除情况肯定是第一种或第二种，这就比较简单了
    ![deletenode3.png](http://ww1.sinaimg.cn/large/005GdKShly1g9ve9rninrj30mc0c80tp.jpg)

具体实现如下，这种实现进行了两趟搜索以查找和删除最小节点，通过一种特殊的removeMin方法可以很容易克服这种效率不高的实现方法，但这里略去

public成员函数实现如下

```c++
17 /**
18 * Remove x from the tree. Nothing is done if x is not found.
19 */
20 void remove( const Comparable & x )
21 {
22  remove( x, root );
23 }
```

private递归函数如下

```c++
1 /**
2 * Internal method to remove from a subtree.
3 * x is the item to remove.
4 * t is the node that roots the subtree.
5 * Set the new root of the subtree.
6 */
7 void remove( const Comparable & x, BinaryNode * & t )
8 {
9   if( t == nullptr )
10      return; // Item not found; do nothing
11  if( x < t->element )
12      remove( x, t->left );
13  else if( t->element < x )
14      remove( x, t->right );
15  else if( t->left != nullptr && t->right != nullptr ) // Two children
16  {
17      t->element = findMin( t->right )->element;
18      remove( t->element, t->right );
19  }
20  else
21  {
22      BinaryNode *oldNode = t;
23      t = ( t->left != nullptr ) ? t->left : t->right;
24      delete oldNode;
25  }
26 }
```

如果预计删除的次数不多，可以使用**懒惰删除(lazy deletion)**策略，当节点要被删除时，它仍留在树中，只是添加了一个“已删除”的标记，这种策略在允许重复项的树中特别有用，remove操作只会让次数-1

#### 析构函数与拷贝构造函数

public的makeEmpty（未给出）直接调用private递归版本的makeEmpty（如下），就像前面的contains等函数一样

```c++
1 /**
2 * Destructor for the tree
3 */
4 ~BinarySearchTree( )
5 {
6   makeEmpty( );
7 }
8 /**
9 * Internal method to make subtree empty.
10 */
11 void makeEmpty( BinaryNode * & t )
12 {
13  if( t != nullptr )
14  {
15      makeEmpty( t->left );
16      makeEmpty( t->right );
17      delete t;
18  }
19  t = nullptr;
20 }
```

拷贝构造函数遵循一般的过程，首先初始化root为nullptr，然后复制rhs的拷贝，这里用一个非常成熟的递归函数clone来处理这些苦力活

```c++
1 /**
2 * Copy constructor
3 */
4 BinarySearchTree( const BinarySearchTree & rhs ) : root{ nullptr }
5 {
6   root = clone( rhs.root );
7 }
8
9 /**
10 * Internal method to clone subtree.
11 */
12 BinaryNode * clone( BinaryNode *t ) const
13 {
14  if( t == nullptr )
15      return nullptr;
16  else
17      return new BinaryNode{ t->element, clone( t->left ), clone( t->right ) };
18 }
```

个人认为clone递归函数的实现非常优美，首先rhs.root被传入，非空返回一个新节点，新节点的值与rhs.root->element一样，新节点的左右儿子又与rhs.root的左右儿子的值一样，但是都是新节点，依次递归，最后达到树叶节点，再一层层返回，构造一个个节点，最后返回最外层的新的根节点

#### 平均情况分析

在所有的插入序列都是等可能的假设下，树的所有节点的平均深度为O(logN)

一棵树的所有节点的深度之和为内部路径长(internal path length)

如果向一棵树输入预先排序的数据,那么一连串 insert操作将花费二次的( quadratic)时间,而链表实现的代价会非常巨大,因为此时的树将只由那些没有左儿子的节点组成。一种解决办法就是要有一个称为平衡( balance)的附加结构条件:任何节点的深度均不得过深。下面要介绍的AVL树就是最老的一种平衡查找树

第二种方法就是放弃平衡条件，允许树有任意深度，但是在每次操作时候都要使用一个调整规则进行调整，使得后面的操作效率要高，这种一般属于自调整(self-adjusting)类结构，在任意单词操作我们不再保证O(logN)的时间界，但是可以证明任意连续M次操作在最坏的情形下花费时间O(MlogN)，这叫做伸展树(splay tree)，将在第11章介绍

### AVL树

AVL( Adelson- Jelskii和 Landis)树是带有平衡条件( balance condition)的二叉查找树，这个平衡条件必须保持，而且它保证树的深度是O(logN)，最简单的想法是要求左右子树具有相同的高度

一棵AVL树是其每个节点的左子树和右子树的高度最多差1的二叉查找树

空树的高度定义为-1

对AVL树的插入操作可能会破坏平衡条件，但是这总可以通过简单修正来继续保持平衡条件，称之为旋转(rotation)

在一次插入操作之后，只有那些从插入点到根节点的路径上的节点的平衡可能被改变，因为只有这些节点的子树可能发生变化

我们把必须重新平衡的节点叫做α，由于任意节点最多有两个儿子，因此出现高度不平衡就需要α点的两棵子树的高度差2，这种不平衡可能出现在下面4种情况中

1. 对α的左儿子的左子树进行一次插入
2. 对α的左儿子的右子树进行一次插入
3. 对α的右儿子的左子树进行一次插入
4. 对α的右儿子的右子树进行一次插入

case1和4、2和3是关于α点的镜像对称(mirror image symmetry)，从理论上来说只有两种情况，当然从编程的角度来说还是4种

若插入发生在“外边”（即左左或右右情况），可以通过对树的一次单旋转(single rotation)而完成调整；若插入发生在“内部”（即左右或右左情况），可以通过稍微复杂一些的双旋转(double rotation)来处理

#### 单旋转

下面来看看case1的旋转，本来X、Y是出于同一层的，Z是在上一层的，插入的新节点在X下面，这破坏了k2节点的平衡条件

![singlerotation1.png](http://ww1.sinaimg.cn/large/005GdKShly1g9vg72wuu4j30lx07st99.jpg)

本来k2>k1，变化仍满足，X仍是k1的左子树，Z仍是k2的右子树，Y本来就是介于k1与k2之间，旋转后仍满足

这样的操作只需要一部分指针的改变，X向上移动一层，Y不变，Z向下移动一层，整个树的新高度恰好与插入前的树高度一样

![singlerotation1example.png](http://ww1.sinaimg.cn/large/005GdKShly1g9vgc3yswhj30ly09mt9r.jpg)

case4的情况与case1一样，只是镜面对称罢了

![singlerotation4.png](http://ww1.sinaimg.cn/large/005GdKShly1g9vgg6ruo8j30ln07u74w.jpg)

### 双旋转

对于case2、3，单旋转无效，问题在于子树Y太深，单旋转并没有降低Y的深度，解决case2、3的方法是双旋转，比如对于case2

![singleanddoublerotationtofixcase2.png](http://ww1.sinaimg.cn/large/005GdKShly1g9vgj7bhsoj30ns0gv40b.jpg)

因为Y已经有一项插入其中，所以它肯定是非空的，可以假设Y有一个根和两棵子树（子树可以为空），于是可以把整棵树看成是4棵子树由3个节点连接，如图所示

为了重新平衡，只能让k2作根，所以k1是k2的左儿子，k3是k2的右儿子，B与C分别作为k1的右儿子与k3的左儿子，这样我们把树的高度也恢复到插入以前的水平

从下文的编程实现可以看出，双旋转就是两个单旋转的组合

case3的情况与case2一样

![doublerotation3.png](http://ww1.sinaimg.cn/large/005GdKShly1g9vguqf0s9j30me07ijs6.jpg)

#### 总结

为了将一个新节点插入到一棵AVL树T中，我们递归地将X插入到T的相应的子树（称为Tlr）中，如果Tlr的高度不变，那么插入完成，否则根据X以及T和Tlr的项做适当的单旋转或双旋转，更新这些高度并处理好与树的其余部分的链接，从而完成插入

由于一次旋转足以解决问题，对于现代编译器，编写递归比非递归更简便

AVL树的节点声明

```c++
1 struct AvlNode
2 {
3   Comparable element;
4   AvlNode *left;
5   AvlNode *right;
6   int height;
7
8   AvlNode( const Comparable & ele, AvlNode *lt, AvlNode *rt, int h = 0 )
9   : element{ ele }, left{ lt }, right{ rt }, height{ h } { }
10
11  AvlNode( Comparable && ele, AvlNode *lt, AvlNode *rt, int h = 0 )
12  : element{ std::move( ele ) }, left{ lt }, right{ rt }, height{ h } { }
13 };
```

计算AVL节点的高度的方法

```c++
1 /**
2 * Return the height of node t or -1 if nullptr.
3 */
4 int height( AvlNode *t ) const
5 {
6   return t == nullptr ? -1 : t->height;
7 }
```

向AVL树进行插入

```c++
1 /**
2 * Internal method to insert into a subtree.
3 * x is the item to insert.
4 * t is the node that roots the subtree.
5 * Set the new root of the subtree.
6 */
7 void insert( const Comparable & x, AvlNode * & t )
8 {
9   if( t == nullptr )
10      t = new AvlNode{ x, nullptr, nullptr };
11  else if( x < t->element )
12      insert( x, t->left );
13  else if( t->element < x )
14      insert( x, t->right );
15
16  balance( t );
17 }
18
19 static const int ALLOWED_IMBALANCE = 1;
20
21 // Assume t is balanced or within one of being balanced
22 void balance( AvlNode * & t )
23 {
24  if( t == nullptr )
25      return;
26
27  if( height( t->left ) - height( t->right ) > ALLOWED_IMBALANCE )
28      if( height( t->left->left ) >= height( t->left->right ) )
29          rotateWithLeftChild( t ); // case1
30      else
31          doubleWithLeftChild( t ); // case2
32  else
33  if( height( t->right ) - height( t->left ) > ALLOWED_IMBALANCE )
34      if( height( t->right->right ) >= height( t->right->left ) )
35          rotateWithRightChild( t ); // case3
36      else
37          doubleWithRightChild( t ); // case4
38
39  t->height = max( height( t->left ), height( t->right ) ) + 1;
40 }
```

```c++
1 /**
2 * Rotate binary tree node with left child.
3 * For AVL trees, this is a single rotation for case 1.
4 * Update heights, then set new root.
5 */
6 void rotateWithLeftChild( AvlNode * & k2 )
7 {
8   AvlNode *k1 = k2->left;
9   k2->left = k1->right;
10  k1->right = k2;
11  k2->height = max( height( k2->left ), height( k2->right ) ) + 1;
12  k1->height = max( height( k1->left ), k2->height ) + 1;
13  k2 = k1;
14 }
```

```c++
1 /**
2 * Double rotate binary tree node: first left child
3 * with its right child; then node k3 with new left child.
4 * For AVL trees, this is a double rotation for case 2.
5 * Update heights, then set new root.
6 */
7 void doubleWithLeftChild( AvlNode * & k3 )
8 {
9   rotateWithRightChild( k3->left );
10  rotateWithLeftChild( k3 );
11 }
```

二叉查找树的删除要比插入复杂，可想而知在AVL树中也是如此，但是保持平衡的旋转操作与之前叙述的一样

```c++
1 /**
2 * Internal method to remove from a subtree.
3 * x is the item to remove.
4 * t is the node that roots the subtree.
5 * Set the new root of the subtree.
6 */
7 void remove( const Comparable & x, AvlNode * & t )
8 {
9   if( t == nullptr )
10      return; // Item not found; do nothing
11
12  if( x < t->element )
13      remove( x, t->left );
14  else if( t->element < x )
15      remove( x, t->right );
16  else if( t->left != nullptr && t->right != nullptr ) // Two children
17  {
18      t->element = findMin( t->right )->element;
19      remove( t->element, t->right );
20  }
21  else
22  {
23      AvlNode *oldNode = t;
24      t = ( t->left != nullptr ) ? t->left : t->right;
25      delete oldNode;
26  }
27
28  balance( t );
29 }
```

### 伸展树(splay tree)

伸展树保证从空树开始任意连续M次对树的操作最多花费O(MlogN)时间，不过并不保证单次操作花费Θ(N)时间，一棵伸展树的每次操作的摊还代价是O(logN)

一般来说，当M次的操作序列总的最坏情况运行时间为O(Mf(N))时，我们就说它的**摊还运行时间(amortized running time)**为O(f(N))

伸展树的基本想法是,当一个节点被访问后,它就要经过一系列AVL树旋转向根推进。注意,如果一个节点很深,那么在其路径上就存在许多的节点也相对较深,通过重新构造可以使对所有这些节点的进一步访问所花费的时间变少。伸展树还不要求保留高度或平衡信息,因此它在某种程度上节省空间并简化代码

伸展树的节点可以达到任意深度，但是在每次访问后树又会被调整，总之会保证，任意连续M次的操作花费O(MlogN)时间

展开(splay)的思路类似旋转，只不过在旋转的实施上我们有选择的余地

### 树的遍历

因为二叉查找树对信息进行了排序，所以可以用中序遍历(inorder traversal)的方法按照信息的顺序进行遍历，因为每个节点只访问一次且是常数时间的，所以总的运行时间是O(N)

```c++
1 /**
2 * Print the tree contents in sorted order.
3 */
4 void printTree( ostream & out = cout ) const
5 {
6   if( isEmpty( ) )
7       out << "Empty tree" << endl;
8   else
9       printTree( root, out );
10 }
11
12 /**
13 * Internal method to print a subtree rooted at t in sorted order.
14 */
15 void printTree( BinaryNode *t, ostream & out ) const
16 {
17  if( t != nullptr )
18  {
19      printTree( t->left, out );
20      out << t->element << endl;
21      printTree( t->right, out );
22  }
23 }
```

如果要计算一个节点的高度，首先需要知道该节点的子树的高度，所以需要后序遍历，总的运行时间也是O(N)

```c++
1 /**
2 * Internal method to compute the height of a subtree rooted at t.
3 */
4 int height( BinaryNode *t )
5 {
6   if( t == nullptr )
7       return -1;
8   else
9       return 1 + max( height( t->left ), height( t->right ) );
10 }
```

如果想用深度标记树中的每个节点，则先序遍历是很有用的

还有一种遍历较少用到，叫做**层序遍历(lever-order traversal)**，所有深度为d的节点要在深度为d+1的节点之前进行处理，层序遍历与其他三种不同之处在于它是用队列而不是使用递归所默认的栈来实现的，感觉就像是广度优先搜索(Breadth First Search, BFS)

### B树

如果数据结构没法整个加载到内存中，那么就得放在磁盘中，而访问磁盘又是很慢的，所以需要一种能够减小访问磁盘次数的数据结构

一棵M叉查找树( M-ary search tree)可以有M路分支。随着分支增加，树的深度在减少。一棵完全二叉树( complete binary tree)的高度大约为log2N（2为底数），而一棵完全M叉树( complete M-ary tree)的高度大约是 logMN（M为底数）。这样,31个节点的理想二又树( perfect binary tree)有5层，而31个节点的5叉树则只有3层

建立二叉查找树需要一个关键字来确定当前选择哪个分支，所以建立M叉查找树需要M-1个关键字来决定选择哪个分支，并且为了使M叉查找树在最坏的情况下也有效，我们需要保证M叉查找树以某种方式取得平衡

**B树(B tree)**可以保证只有少数的磁盘访问，B树是一棵具有下列特性的（平衡）M叉树（这种描述通常叫做B+树）：

1. 数据项存储在树叶上
2. 非叶节点存储直到M-1个关键字以指示搜索的方向，关键字i代表子树i+1中的最小的关键字。
3. 树的根或者是一片树叶，或者其儿子数在2和M之间。
4. 除根外,所有非叶节点的儿子数在[M/2]和M之间。
5. 所有的树叶都在相同的深度上，  并且每片树叶拥有的数据项其个数在[L/2]和L之间，L的确定稍后描述。

A B-tree of order M is an M-ary tree with the following properties

1. The data items are stored at leaves
2. The nonleaf nodes store up to M-I keys to guide the searching; key i represents the
smallest key in subtree i+l
3. The root is either a leaf or has between two and m children
4. All nonleaf nodes(except the root) have between [M/2] and M children
5. All leaves are at the same depth and have between [L/2] and l data items, for some L
(the determination of l is described shortly)

> 注：为了兼容符号，上述定义中的方括号指的是对值取大于它的最近整数，如`[1.2]=2`

下图给出了5阶B树的一个例子，非叶节点的儿子数都在3和5之间（从而有2~4个关键字）；根可能只有两个儿子，这里让L=5，每片树叶有3~5个数据项

![5orderbtree.png](http://ww1.sinaimg.cn/large/005GdKShly1g9w5idmuinj30r10arjso.jpg)

#### B树中的insert

向B树中添加项稍微有点复杂，把一个项插入到树叶节点中，最好的情况是直接添加

![btreeinsertleafnosplit.png](http://ww1.sinaimg.cn/large/005GdKShly1g9w5ivpo3jj30kw08tq42.jpg)

把一个项插入到树叶节点中，也有可能会违反定义5，所以需要分裂

![btreeinsertleafsplitleaf.png](http://ww1.sinaimg.cn/large/005GdKShly1g9w5i5u044j30kg08dwfn.jpg)

当一个项插入到树叶节点中，不仅有可能违反定义5，还可能进一步违反定义4，所以对父节点也需要分裂

![btreeinsertleafsplitnonleaf.png](http://ww1.sinaimg.cn/large/005GdKShly1g9w5ia0ifzj30l50853zk.jpg)

正如这里的情形所示，当一个非叶节点分裂时，它的父节点得到了一个儿子。如果父节点的儿子个数已经达到规定的限度怎么办呢？在这种情况下，我们继续沿树向上分裂节点直到或者找到一个父节点它不需要再分裂，或者到达树根。如果分裂树根，那么就得到两个树根。显然这是不可接受的，但我们可以建立一个新的根，这个根以分裂得到的两个树根作为它的两个儿子。这就是为什么准许树根可以最少有两个儿子的特权的原因。**这也是B树增加高度的唯一的方式**。不用说，一路向上分裂直到根的情况是一种特别少见的异常事件，因为棵具有4层的树意味着其根在整个插入序列中已经被分裂了3次(假设没有删除发生)。事实上，任何非叶节点的分裂也是相当少见的。

还有其他一些方法处理儿子过多的情况。比如可以在相邻节点有空间时把一个儿子交给该邻节点领养。例如，为了把29插入到图4.66的B树中，可以把32移到下一片树叶而为29腾出一个空间。这种方法要求对父节点进行修改，可以使得节点更满从而在长时间运行中节省空间。

#### B树中的remove

最后是删除项的讨论，这里有几个问题：

- 如果被删元素所在的树叶的数据项数己经是最小值，那么删除后它的项数就低于最小值了。我们可以通过在相邻节点本身没有达到最小值时领养一个邻项来矫正这种状况。
- 如果邻节点也已达到最小值，那么可以与相邻节点联合以形成一片满叶。可是,这意味着其父节点失去一个儿子。
- 如果失去儿子的结果又引起父节点的儿子数低于最小值,那么我们使用相同的策略继续进行后面的工作。

这个过程可以一直上行到根。根不可能只有一个儿子。如果这个领养过程的结果使得根只剩下一个儿子，那么删除该根并让它的这个儿子作为树的新根。**这是B树降低高度的唯一方式**。

例如,假设我们想要从图4.66的B树中删除99。由于那片树叶只有两项而它的邻居已经是最小值3项了，因此我们把这些项合并成有5项的一片新的树叶。结果，它们的父节点只有两个儿子了。不过，该父节点可以从它的邻节点领养，因为邻节点有4个儿子。领养的结果使得双方都有3个儿子，结果如图4.67所示。

![btreeremove.png](http://ww1.sinaimg.cn/large/005GdKShly1g9w5ri3gzkj30qu08t42f.jpg)

### 标准库中的容器set和map

在第三章讨论过的STL容器vector与list对于查找操作效率很低，一般是O(N)，而set和map能够保证插入、查找、删除等基本操作的对数开销，即O(logN)

#### set和map

关于set、map的详细讨论参见C++ Primer

C++要求set和map以对数最坏情形时间支持基本的insert、erase和find操作，但是并不适用AVL树，而使用一些自顶向下的红黑树，红黑树将在第12章讨论

#### 拓展阅读——线索树

线索树(threaded tree)：一个二叉树通过如下的方法 “穿起来”：所有原本为空的右 (孩子) 指针改为指向该节点在中序序列中的后继，所有原本为空的左 (孩子) 指针改为指向该节点的中序序列的前驱。

线索二叉树能线性地遍历二叉树，从而比递归的中序遍历更快。使用线索二叉树也能够方便的找到一个节点的父节点，这比显式地使用父亲节点指针或者栈效率更高。这在栈空间有限，或者无法使用存储父节点的栈时很有作用（对于通过深度优先搜索来查找父节点而言)。

![threadedtree.png](http://ww1.sinaimg.cn/large/005GdKShly1g9wa44g9g0j30dj0bgdgl.jpg)

#### 使用多个map的示例

不同单词之间可以通过改变一个字母来转换，现在想要写出一个程序来找出通过单字母替换可以变成至少15个其他单词的单词，最简单的策略是使用一个map对象，其中的key是单词，而value是单字母替换后能得到的单词所组成的vector

假设已经得到这样的map，下面的程序可以打印所要求的的答案

```c++
1 void printHighChangeables( const map<string,vector<string>> & adjacentWords,
2 int minWords = 15 )
3 {
4   for( auto & entry : adjacentWords )
5   {
6       const vector<string> & words = entry.second;
7
8       if( words.size( ) >= minWords )
9       {
10          cout << entry.first << " (" << words.size( ) << "):";
11          for( auto & str : words )
12              cout << " " << str;
13          cout << endl;
14      }
15  }
16 }
```

然而问题是如何构建一个这样的map

首先可以构建如下的简单函数，它测试两个单词能否通过单字母变换而变成对方

```c++
1 // Returns true if word1 and word2 are the same length
2 // and differ in only one character.
3 bool oneCharOff( const string & word1, const string & word2 )
4 {
5   if( word1.length( ) != word2.length( ) )
6       return false;
7
8   int diffs = 0;
9
10  for( int i = 0; i < word1.length( ); ++i )
11      if( word1[ i ] != word2[ i ] )
12          if( ++diffs > 1 )
13              return false;
14
15  return diffs == 1;
16 }
```

借助简单的测试函数，可以编写一个蛮力构建这个map的算法

```c++
1 // Computes a map in which the keys are words and values are vectors of words
2 // that differ in only one character from the corresponding key.
3 // Uses a quadratic algorithm.
4 map<string,vector<string>> computeAdjacentWords( const vector<string> & words )
5 {
6   map<string,vector<string>> adjWords;
7
8   for( int i = 0; i < words.size( ); ++i )
9       for( int j = i + 1; j < words.size( ); ++j )
10          if( oneCharOff( words[ i ], words[ j ] ) )
11          {
12              adjWords[ words[ i ] ].push_back( words[ j ] );
13              adjWords[ words[ j ] ].push_back( words[ i ] );
14          }
15
16  return adjWords;
17 }
```

上述构建算法直白明了，并且保证了map.second的vector中的单词不重复，但是缺点是效率太慢了，一个明显的改进是避免比较不同长度的单词，我们可以通过将单词分组来做到这点，然后在每个分组上分别运行上述算法

为此，可以使用第二个map，key是一个代表单词长度的整数，value是一个vector，包含key长度的所有单词，虽然算法仍是二次方时间，但是比蛮力构建算法快大约6倍，实现如下

```c++
1 // Computes a map in which the keys are words and values are vectors of words
2 // that differ in only one character from the corresponding key.
3 // Uses a quadratic algorithm, but speeds things up a little by
4 // maintaining an additional map that groups words by their length.
5 map<string,vector<string>> computeAdjacentWords( const vector<string> & words )
6 {
7   map<string,vector<string>> adjWords;
8   map<int,vector<string>> wordsByLength;
9
10  // Group the words by their length
11  for( auto & thisWord : words )
12      wordsByLength[ thisWord.length( ) ].push_back( thisWord );
13
14  // Work on each group separately
15  for( auto & entry : wordsByLength )
16  {
17      const vector<string> & groupsWords = entry.second;
18
19      for( int i = 0; i < groupsWords.size( ); ++i )
20          for( int j = i + 1; j < groupsWords.size( ); ++j )
21              if( oneCharOff( groupsWords[ i ], groupsWords[ j ] ) )
22              {
23                  adjWords[ groupsWords[ i ] ].push_back( groupsWords[ j ] );
24                  adjWords[ groupsWords[ j ] ].push_back( groupsWords[ i ] );
25              }
26  }
27
28  return adjWords;
29 }
```

第三种构建方法更为复杂，举例说明，假设我们的工作对长度为4的单词进行。首先，要找出像wine和nine这样的单词对，它们除第1个字母外完全相同。
一种做法是：对于长度为4的每一个单词，删除第1个字母，剩下一个3字母单词代表( representative)。这样就形成一个map，其中的关键字为该代表，而值则是一个包含该代表的所有单词的vector。

例如，在考虑4字母单词组的第1个字母时，代表"ine"对应"dine"、"fine"、"wine"、"nine"、"mine"、"vine"、"pine"、"line"。代表"oot"对应"boot"、"foot"、"hoot"、"loot"、"soot"、"zoot"。每一个作为最新map的值的 vector对象形成单词的一个团 (clique)，其中任何一个单词均可以通过单字母替换变成另一个单词，因此在这个最新的map构成之后，遍历它以及添加一些项到正在被计算的原map中很容易。然后，我们再使用一个新的map来处理这个4字母单词组的第2个字母。此后处理第3个字母，最后处理第4个字母。

算法伪代码如下

```c++
for each group g, containing words of length len
    for each position p (ranging from 0 to len-1)
    {
        Make an empty map<string,vector<string>> repsToWords
        for each word w
        {
            Obtain w’s representative by removing position p
            Update repsToWords
        }
            Use cliques in repsToWords to update adjWords map
    }
```

C++实现如下，这种算法比第二种算法时间又快了几倍，但是没有利用到关键字是有序排列这一特点

```c++
1 // Computes a map in which the keys are words and values are vectors of words
2 // that differ in only one character from the corresponding key.
3 // Uses an efficient algorithm that is O(N log N) with a map
4 map<string,vector<string>> computeAdjacentWords( const vector<string> & words )
5 {
6   map<string,vector<string>> adjWords;
7   map<int,vector<string>> wordsByLength;
8
9   // Group the words by their length
10  for( auto & str : words )
11      wordsByLength[ str.length( ) ].push_back( str );
12
13  // Work on each group separately
14  for( auto & entry : wordsByLength )
15  {
16      const vector<string> & groupsWords = entry.second;
17      int groupNum = entry.first;
18
19      // Work on each position in each group
20      for( int i = 0; i < groupNum; ++i )
21      {
22          // Remove one character in specified position, computing representative.
23          // Words with same representatives are adjacent; so populate a map ...
24          map<string,vector<string>> repToWord;
25
26          for( auto & str : groupsWords )
27          {
28              string rep = str;
29              rep.erase( i, 1 );
30              repToWord[ rep ].push_back( str );
31          }
32
33          // and then look for map values with more than one string
34          for( auto & entry : repToWord )
35          {
36              const vector<string> & clique = entry.second;
37              if( clique.size( ) >= 2 ) // clique的大小大于等于2，里面的元素才有可能是邻接的
38                  for( int p = 0; p < clique.size( ); ++p )
39                      for( int q = p + 1; q < clique.size( ); ++q )
40                      {
41                          adjWords[ clique[ p ] ].push_back( clique[ q ] );
42                          adjWords[ clique[ q ] ].push_back( clique[ p ] );
43                      }
44          }
45      }
46  }
47  return adjWords;
48 }
```

C++的STL中有一种容器叫做unordered_map，不保证有序排列，但有可能会更快，这种**无序映射(unordered map)**技术在第五章讨论

## 散列（hash）

本章讨论散列表(hash table)ADT，散列表的实现通常叫做散列(hash)，散列是一种用于以常数时间执行插入、删除和查找的技术，并且元素是无序的

理想的散列表数据结构只不过是一个包含一些项(item)的具有固定大小的数组。第4章讨论过，查找一般是对项的某个部分(即数据域)进行。这部分就叫作关键字(key)。例如，一项可以由一个字符串(它可以作为关键字)和一些附加的数据成员(例如姓名，它是大型雇员结构的一部分)组成。我们把表的大小记作 TableSize，并将其理解为散列数据结构的一部分而不仅仅是浮动于全局的某个变量。通常的习惯是让表从0到 TableSize-1变化，稍后我们就会明白为什么要这样。

每个关键字被映射到从0到 TableSize-1这个范围中的某个数，并且被放到适当的单元中。这个映射就叫作**散列函数(hash function)**，理想情况下它应该算起来简单并且应该保证任何两个不同的关键字都要映射到不同的单元。但是，这显然是不可能的，因为单元的数目是有限的，而关键字实际上是用不完的。因此，我们寻找一个散列函数，该函数要在单元之间均匀地分配关键字。

关于 hash table 的一些概念：

- 散列表（Hash table，也叫哈希表），是根据关键码值(Key value)而直接进行访问的数据结构。也就是说，它通过把关键码值映射到表中一个位置来访问记录，以加快查找的速度。这个映射函数叫做散列函数，存放记录的数组叫做散列表。
- 给定表M，存在函数f(key)，对任意给定的关键字值key，代入函数后若能得到包含该关键字的记录在表中的地址，则称表M为哈希(Hash）表，函数f(key)为哈希(Hash) 函数。
- 哈希表是一种通过哈希函数将特定的键映射到特定值的一种数据结构，他维护者键和值之间一一对应关系。
- 键(key)：又称为关键字。唯一的标示要存储的数据，可以是数据本身或者数据的一部分。
- 槽(slot/bucket)：哈希表中用于保存数据的一个单元，也就是数   据真正存放的容器。
- 哈希函数(hash function)：将键(key)映射(map)到数据应该存放的槽(slot)所在位置的函数。
- 哈希冲突(hash collision)：哈希函数将两个不同的键映射到同一个索引的情况。

散列的基本想法就是这样，剩下的问题是：

- 如何选择散列函数
- 发生冲突(collision)时怎么办
- 如何确定TableSize

### 散列函数

如果关键字是整数，可以用key mod TableSize来确定要存放的单元，一般TableSize选择素数，各种整数关键字分配起来比较均匀

如果关键字是字符串，可以把字符串中所有字符的ASCII码值加起来，再对TableSize求模，但是当TableSize较大而字符串较小时，散列表后面的单元可能一直是空的，这也不是一个好选择，如果字符串是英文的，不同长度的字符串是有特点，散列起来效果也不是太好

下面的散列函数是个不错的选择，它涉及到关键字的所有字符，并且分布得很好，程序根据Horner法则计算一个37的多项式函数，并且程序是允许溢出的，同时用到unsigned int类型来避免出现负数

```c++
1 /**
2 * A hash routine for string objects.
3 */
4 unsigned int hash( const string & key, int TableSize )
5 {
6   unsigned int hashVal = 0;
7
8   for( char ch : key )
9       hashVal = 37 * hashVal + ch;
10
11  return hashVal % TableSize;
12 }
```

当然，这种散列函数不一定是最好的，比如如果关键字很长的话，计算散列值耗时良久，但可以只选择关键字一部分来加速计算，比如只选择奇数位置上的字符，这用到了一种思想：用计算散列函数节省下来的时间来补偿轻微不均匀分布的函数，这相当于一个速度和分布均匀程度的折中

总之，散列函数的设计至关重要，如果设计得非常糟糕，以致于大部分元素都被散列到同一槽时，这时散列表就退化成了链表，访问时间需要O(N)

### 分离链接法(separate chaining)

解决冲突的第一种方法就是分离链接法，将散列到同一单元的元素保留在一个链表(list)中，可以使用STL中的list实现

为执行一次 search，我们使用散列函数来确定究竟遍历哪个链表。然后再在适当的链表中执行一次查找。为执行 Insert，我们检查相应的链表看看该元素是否已经处在相应的位置(如果允许插入重复元，那么通常要留出一个额外的数据成员，当出现匹配事件时这个数据成员增1)。如果这个元素是个新的元素，那么它将被插入到链表的前端，这不仅因为方便，而且还因为常常发生这样的事实：新近插入的元素最有可能不久又被访问。

实现分离链接法的类接口如下，散列表存储一个list，它们在构造函数中被指定

```c++
1 template <typename HashedObj>
2 class HashTable
3 {
4   public:
5       explicit HashTable( int size = 101 );
6
7       bool contains( const HashedObj & x ) const;
8
9       void makeEmpty( );
10      bool insert( const HashedObj & x );
11      bool insert( HashedObj && x );
12      bool remove( const HashedObj & x );
13
14  private:
15      vector<list<HashedObj>> theLists; // The array of Lists
16      int currentSize;
17
18      void rehash( );
19      size_t myhash( const HashedObj & x ) const;
20 };
```

注意：C++11之前，`vector<list<HashedObj>>`得写成`vector<list<HashedObj> >`，因为`>>`是C++中已定义的符号

就像二叉査找树只对那些 Comparable的对象有效一样，本章中的散列表只对提供散列函数和等号操作符( equality operator)( operator==或 operator!=，或二者同时提供)的对象适用。

我们让散列函数只用对象作为参数并返回适当的整型量，而不再要求散列函数采用对象和表的大小同时作为参数。此时标准的做法是使用函数对象，以及在C++11中引进的散列表协议。特别地，在C++11中，散列函数可以通过函数对象模板来表示

```c++
template <>
class hash<string>
{
    public:
        size_t operator()( const string & key )
        {
            size_t hashVal = 0;
            for( char ch : key )
            hashVal = 37 * hashVal + ch;
            return hashVal;
    }
};
```

在我们的HashTable类接口中可以调用这个泛型散列函数对象，在private的成员函数myhash中实现

```c++
1 size_t myhash( const HashedObj & x ) const
2 {
3   static hash<HashedObj> hf;
4   return hf( x ) % theLists.size( );
5 }
```

makeEmpty、contains、remove函数实现如下

```c++
1 void makeEmpty( )
2 {
3   for( auto & thisList : theLists )
4   thisList.clear( );
5 }
6
7 bool contains( const HashedObj & x ) const
8 {
9   auto & whichList = theLists[ myhash( x ) ];
10  return find( begin( whichList ), end( whichList ), x ) != end( whichList );
11 }
12
13 bool remove( const HashedObj & x )
14 {
15  auto & whichList = theLists[ myhash( x ) ];
16  auto itr = find( begin( whichList ), end( whichList ), x );
17
18  if( itr == end( whichList ) )
19      return false;
20
21  whichList.erase( itr );
22  --currentSize;
23  return true;
24 }
```

插入函数实现如下，如果插入项已存在则什么也不做，该元素可以被放在list中任何地方，在不考虑下次被使用的情况下，用push_back是最方便的

```c++
1 bool insert( const HashedObj & x )
2 {
3   auto & whichList = theLists[ myhash( x ) ];
4   if( find( begin( whichList ), end( whichList ), x ) != end( whichList ) )
5       return false;
6   whichList.push_back( x );
7
8   // Rehash; see Section 5.5
9   if( ++currentSize > theLists.size( ) )
10      rehash( );
11
12  return true;
13 }
```

定义装填因子(load factor)λ为散列表中的元素个数对该散列表大小的比，链表的平均长度也为λ

散列表的大小实际上并不重要，装填因子才重要，分离链接散列法的一般法则是让表的大小大致与预料的元素个数差不多（也就是让λ≈1）

### 不用链表的散列表

分离链接需要一些链表，这可能会减慢速度，也有不用链表的散列表，一般来说它们更大一点，解决冲突的方法是尝试另外的单元（槽），直到找出空的为止，这种散列表叫做**探测散列表(probing hash table)**，一般如下探测，其中f是冲突解决方法

```math
hi(x) = (hash(x) + f(i)) mod TableSize, with f(0) = 0
```

#### 线性探测法

函数f是i的线性函数，典型的是`f(i)=i`，只要表足够大，总可以找到一个空位置，但是可能需要多次试探，更糟糕的是，即使表比较空，占据的位置也可能形成一些区块，这称为**一次聚集(primary clustering)**，分析表明，线性探测比随机探测性能要差，也就是探测次数更多

#### 平方探测法

平方探测可消除线性探测中一次聚集的问题，典型的是`f(i)=i^2`

对于线性探测，让散列表几乎填满元素并不是个好主意，因为此时表的性能会降低。对于平方探测情况甚至更糟：一旦表被填满超过一半，当表的大小不是素数时甚至在表被填满一半之前，就不能保证找到空的位置了。这是因为最多有表的一半可以用作解决冲突的备选位置。

定理：如果使用平方探测，且散列表的大小是素数，那么当表至少有一半是空的时候，总能够插入一个新的元素

哪怕表有一半多一个的位置被填满，都有可能导致插入失败（虽然很难实现），散列表的大小若不是素数，则能够插入的位置会锐减

因为探测散列表的槽可能产生过冲突，所以可能对应项存在了别处，因此探测散列表需要懒惰删除

下面是探测散列表的类接口实现，每一个槽都有info标记

```c++
1 template <typename HashedObj>
2 class HashTable
3 {
4   public:
5       explicit HashTable( int size = 101 );
6
7       bool contains( const HashedObj & x ) const;
8
9       void makeEmpty( );
10      bool insert( const HashedObj & x );
11      bool insert( HashedObj && x );
12      bool remove( const HashedObj & x );
13
14      enum EntryType { ACTIVE, EMPTY, DELETED };
15
16  private:
17      struct HashEntry
18      {
19          HashedObj element;
20          EntryType info;
21
22          HashEntry( const HashedObj & e = HashedObj{ }, EntryType i = EMPTY )
23          : element{ e }, info{ i } { }
24          HashEntry( HashedObj && e, EntryType i = EMPTY )
25          : element{ std::move( e ) }, info{ i } { }
26      };
27
28  vector<HashEntry> array;
29  int currentSize;
30
31  bool isActive( int currentPos ) const;
32  int findPos( const HashedObj & x ) const;
33  void rehash( );
34  size_t myhash( const HashedObj & x ) const;
35 };
```

散列表的构建如下

```c++
1 explicit HashTable( int size = 101 ) : array( nextPrime( size ) )
2 { makeEmpty( ); }
3
4 void makeEmpty( )
5 {
6   currentSize = 0;
7   for( auto & entry : array )
8   entry.info = EMPTY;
9 }
```

散列表实现contains方法还需要isActive和findPos两个方法，具体实现如下，由平方消解函数(quadratic resolution function)的定义可知，`f(i) = f(i − 1) + 2i − 1`，因此下一个要尝试的单元距离上一个被试过的单元有一段距离，而这个距离在连续探测中增2，如果新的定位越过数组，那么可以通过减去TableSize把它拉回到数组范围

```c++
1 bool contains( const HashedObj & x ) const
2 { return isActive( findPos( x ) ); }
3
4 int findPos( const HashedObj & x ) const
5 {
6   int offset = 1;
7   int currentPos = myhash( x );
8
9   while( array[ currentPos ].info != EMPTY &&
10      array[ currentPos ].element != x )
11  {
12      currentPos += offset; // Compute ith probe
13      offset += 2;
14      if( currentPos >= array.size( ) )
15      currentPos -= array.size( );
16  }
17
18  return currentPos;
19 }
20
21 bool isActive( int currentPos ) const
22 { return array[ currentPos ].info == ACTIVE; }
```

书中提到上面第9、10行的测试顺序很重要，不能改变，不能理解为什么，从逻辑上过来说调换顺序不影响正确的输出吧？

探测散列表的插入实现如下，与分离链接散列表一样，若x已经存在，则什么也不做，否则就把插入的元素放在findPos返回的地方，如果装填因子超过0.5，则表是满的，需要用**再散列(rehashing)**将散列表扩大，下面同样给出了删除的实现

```c++
1 bool insert( const HashedObj & x )
2 {
3 // Insert x as active
4   int currentPos = findPos( x );
5   if( isActive( currentPos ) )
6       return false;
7
8   array[ currentPos ].element = x;
9   array[ currentPos ].info = ACTIVE;
10
11  // Rehash; see Section 5.5
12  if( ++currentSize > array.size( ) / 2 )
13      rehash( );
14
15  return true;
16 }
17
18 bool remove( const HashedObj & x )
19 {
20  int currentPos = findPos( x );
21  if( !isActive( currentPos ) )
22      return false;
23
24  array[ currentPos ].info = DELETED;
25  return true;
26 }
```

总结：虽然平方探测消除了一次聚集，但是那些散列到同一位置的那些元素将探测相同的槽，这叫做**二次聚集(secondary clustering)**

#### 双散列(double hashing)

双散列的典型是`f(i) = i·hash2(x)`，其中hash2(x)的选择非常关键，可以选择`hash2(x) = R − (x mod R)`，R为小于TableSize的一个数（最好是素数）

### 再散列(rehashing)

对于平方探测的**开放地址散列法(open addressing hashing)**，如果散列表填的太满，那么操作的运行时间将消耗过长，且插入操作可能失败，一种解决方法是建立另外一个大约两倍大的散列表（一般取大于两倍的第一个素数），而且使用一个相关的新散列函数，把原散列表的所有未删除的元素散列到新散列表中，这就是再散列，显然运行时间为O(N)，不过由于不是经常发生，所以性能也能接受

再散列可以用平方探测的多种方法实现：

- 散列表满到一半时就再散列
- 当插入失败时再散列
- **途中策略(middle-of-the-road strategy)**：当散列表到达某一特定的装填因子时再散列

由于随着装载因子的增长散列表的性能的确在下降，所以第三种方法可能是最好的选择

下面给出探测散列表的再散射实现，对于分离链接散列表的再散射也是类似的（个人不是很理解currentSize的用法，似乎去掉也无影响  ）

```c++
1 /**
2 * Rehashing for quadratic probing hash table.
3 */
4 void rehash( )
5 {
6   vector<HashEntry> oldArray = array;
7
8   // Create new double-sized, empty table
9   array.resize( nextPrime( 2 * oldArray.size( ) ) );
10  for( auto & entry : array )
11      entry.info = EMPTY;
12
13      // Copy table over
14      currentSize = 0;
15      for( auto & entry : oldArray )
16          if( entry.info == ACTIVE )
17              insert( std::move( entry.element ) );
18 }
19
20 /**
21 * Rehashing for separate chaining hash table.
22 */
23 void rehash( )
24 {
25  vector<list<HashedObj>> oldLists = theLists;
26
27  // Create new double-sized, empty table
28  theLists.resize( nextPrime( 2 * theLists.size( ) ) );
29  for( auto & thisList : theLists )
30      thisList.clear( );
31
32  // Copy table over
33  currentSize = 0;
34  for( auto & thisList : oldLists )
35      for( auto & x : thisList )
36          insert( std::move( x ) );
37 }
```

### 标准库中的散列表——unordered_set和unordered_map

C++11中，标准库包括集合set与映射map的散列表实现，即unordered_set与unordered_map

unordered set中的项(或 unordered map中的key)必须提供一个重载的 operator==和一个hash函数。正如set和map模板也能够用一个提供(或重载一个默认的)比较函数的函数对象来实例化一样, unordered set和 unordered map可以用提供散列函数和等号运算符的函数对象来实例化。

下面创建一个对大小写不敏感的字符串的无序集合

```c++
1 class CaseInsensitiveStringHash
2 {
3   public:
4       size_t operator( ) ( const string & s ) const
5       {
6           static hash<string> hf;
7           return hf( toLower( s ) ); // toLower implemented elsewhere
8       }
9
10  bool operator( ) ( const string & lhs, const string & rhs ) const
11  {
12      return equalsIgnoreCase( lhs, rhs ); // equalsIgnoreCase is elsewhere
13  }
14 };
15
16 unordered_set<string,CaseInsensitiveStringHash,CaseInsensitiveStringHash> s;
```

如果表项是否依有序方式可见并不重要，那么这些无序类就可以被使用。例如前文提到的存在3种映射:

1. 其中关键字为单词长度，而对应的值是长为该单词长度的所有单词的集合的映射
2. 关键字是一个代表( representative)，而对应的值是拥有该代表的所有单词集合的映射
3. 关键字是一个单词，而对应的值是与该单词只有一个字母不同的所有单词集合的映射

因为单词长度被处理的顺序并不重要，所以第1个映射可以是 unordered map。而由于第2个映射建立以后甚至不需要代表，因此第2个映射可以是 unordered map。第3个映射也可以是 unordered map，除非我们想要 printHighChangeables依字母顺序列出那些可以被变换成大量其他单词的单词的子集

unordered map的性能常常可以超越map的性能，不过，若不按两种方式编写代码很难有把握肯定二者的优劣

### 以最坏情形O(1)访问的散列表

**完美散列(perfect hashing)**可以实现以最坏情形O(1)访问的散列表，杜鹃散列(cuckoo hashing)与跳房子散列(hopscotch hashing)也可以实现

设计完美散列的基本思想是利用两级的散列表，在每一级上都是用全域散列(universal hashing)，每个二级散列表都使用不同的散列函数，确保第二级不产生冲突

对于分离链接法，如果装填因子是1，那么这就是某种形式的经典球-箱问题( balls and bins problem)：设N个球被随机(均匀)地放入N个箱子里，则放球最多的箱子中球的期望个数是多少？答案即熟知的⊙(logN/log logN)，就是说，平均看来，我们预期某些查寻接近花费对数时间。对于探测散列表中最长的期望探测序列的长度，其类似类型的界也可观察到(或可证明)。

个人认为书本这部分内容讲得不好，于是我上网搜索了几篇不错的文章：[散列表之散列函数](https://blog.csdn.net/ii1245712564/article/details/46649157#%E4%B9%98%E6%B3%95%E6%95%A3%E5%88%97%E6%B3%95)、[全域哈希和完全哈希](https://blog.csdn.net/lzq20115395/article/details/80517225)

#### 杜鹃散列(cuckoo hashing)

从前面的讨论中我们可以知道，在球-箱问题中，如果将N项随机抛入N个箱子中，那么含球最多的箱子的期望球数为⊙(logN/log logN)。由于这个界早为人们所知，而且该问题已被数学家们透彻地研究过，因此当在20世纪90年代中期证明了下述结论时，该结果引起人们的惊奇：如果在每次投掷中随机选取两个箱子且将被投项投入(在那一刻)较空的箱子中，则最大箱子的球数只是⊙(log logN)，这是一个显著的更小的数。很快，许多可能的算法和数据结构从“双选威力( power of two choices)”的新概念中被激发出来。

其中的一种做法就是杜鹃散列( cuckoo hashing)。在杜鹃散列中，假设我们有N项。我们保持两个散列表，每个都多于半空，并且我们有两个独立的散列函数，它们可将每一项分配给每个表中的一个位置。杜鹃散列保持下述不变性：一项总是被存储在它的两个位置之一中。

个人感觉杜鹃散列不是很重要，代码实现就没细看了

下面摘自[Cuckoo hash 算法分析](https://www.cnblogs.com/bonelee/p/6409733.html)：

杜鹃散列是一种解决 hash 冲突的方法，其目的是使用简单的 hash 函数来提高 hash table 的利用率，同时保证 O (1) 的查询时间

基本思想是使用 2 个 hash 函数来处理碰撞，从而每个 key 都对应到 2 个位置，插入操作如下：

1. 对 key 值 hash，生成两个 hash key 值，hashk1 和 hashk2, 如果对应的两个位置上有一个为空，那么直接把 key 插入即可。
2. 否则，任选一个位置，把 key 值插入，把已经在那个位置的 key 值踢出来。
3. 被踢出来的 key 值，需要重新插入，直到没有 key 被踢出为止。

我们先来看看 cuckoo hashing 有什么特点，它的哈希函数是成对的（具体的实现可以根据需求设计），每一个元素都是两个，分别映射到两个位置，一个是记录的位置，另一个是 备用位置。这个备用位置是处理碰撞时用的，这就要说到 cuckoo 这个名词的典故了，中文名叫布谷鸟，这种鸟有一种即狡猾又贪婪的习性，它不肯自己筑巢， 而是把蛋下到别的鸟巢里，而且它的幼鸟又会比别的鸟早出生，布谷幼鸟天生有一种残忍的动作，幼鸟会拼命把未出生的其它鸟蛋挤出窝巢，今后以便独享 “养父 母” 的食物。借助生物学上这一典故，cuckoo hashing 处理碰撞的方法，就是把原来占用位置的这个元素踢走，不过被踢出去的元素还要比鸟蛋幸运，因为它还有一个备用位置可以安置，如果备用位置上 还有人，再把它踢走，如此往复。直到被踢的次数达到一个上限，才确认哈希表已满，并执行 rehash 操作。

#### 跳房子散列(hopscotch hashing)

跳房子散列是一个新算法，它尝试改进经典的线性探测算法。回忆在线性探测法中，单元从散列位置开始依序被尝试。由于一次聚集和二次聚集，尝试的序列随着散列表的负载增加可能平均很长，于是诸如平方探测、双散列等许多改进方法被提出，以减少冲突的次数。然而，对于某些现代体系结构，通过探测相邻单元而产生的局部性是比一些附加的探测更为重要的因素，线性探测可能仍然是实用的，甚至是最好的选择

跳房子散列法(hopscotch hashing)是对线性探测法的一种改进，其基本思路是：通过预先确定的、在计算机结构体系的基础上优化的常数，来为探测序列的最大长度定界。这么做将给出在最坏情形下常数时间的查找，并且像杜鹃散列一样，查找或许与同时检测可能位置的有界集是并行的。

​跳房子散列比较简单，是一种比较新的算法（2008年），但是初始的实验结果很有前途，特别是对那些使用多处理器并且需要大量并行和并发的应用而言

下面摘自[散列・跳房子散列](https://www.codetd.com/article/5603043)：

​要点：

- 依然是线性探测
- 探测长度有个上限
- 上限是提前定好的，跟计算机底层体系结构有关系

最大探测上界 MAX_DIST​ = 4, 散列位置 \(hash(x)\)，则探测位置为 \(hash(x)+0\)、\(hash(x)+1\)、\(hash(x)+2\)、\(hash(x)+3\)

![hopscotchhashing.png](http://ww1.sinaimg.cn/large/005GdKShly1g9xjnlmh12j31ey0gmwf5.jpg)

上图展示 A～G 的元素，右侧是他们的散列值。图表中的 Hop 表示探测位置是否被占用，比如 “0010”，说明 \(hash(x)+2\) 位置被使用。用四位码表示具体位置。

- 插入 A，A 的散列位置是 7，则 Hop [7] 的第 0 个位置被占用，记作 “1000”；
- 插入 B，B 的散列位置是 9，则 Hop [9] 的第 0 个位置被占用，记作 “1000”；
- 插入 C，C 的散列位置是 6，则 Hop [6] 的第 0 个位置被占用，记作 “1000”；以上未发生冲突。
- 插入 D，D 的散列位置是 7，发生冲突，位置 7 已经存在值 A，开始线性探测，探测下一个位置 \(hasx(x)+1 = 8\)，位置 8 未被占用，可插入，则 Hop [7] 的第 1 个位置被占用，将 Hop [7] 记作 “1100”；
- 插入 E，E 的散列位置是 8，发生冲突，位置 8 已经存在值 D，开始线性探测，探测下一个位置 $hasx (x)+1 =9 \(，位置 9 已经存在值 B，继续探测下一个位置 \)hasx (x)+2 = 10$，位置 10 未被占用，可插入，测试 Hop [8] 的第 2 个位置被占用，将 Hop 记作 “0010”；

- 插入 F、G。未发生冲突，同上插入。

问：如果线性探测，直到上界都无法插入呢？

答：选择一个踢到后面去，插入到这个位置，仍然满足探测长度符合不超过上界。例如：我们在上述例子中继续插入 H，散列值为 9。我们探测位置 9、10、11、12 都被占用，只能到 13，但是位置 13 明显超过上界，即 \(hash(x)+3\) 都未能找到可插入点。那我们将 找一个值 y 来替换掉。并把它重置到位置 13。可以去到位置 13 的值只有散列值为 10、11、12、13 的值。如果我们检查 Hop [10]，它的值为 “0000”，没有可以替换的候选项，于是我们检查 Hop [11], 它的值为 “1000”，其值为 G，可以被放到位置 13。于是我们将元素 G 放到位置 13，将 11 空出来，插入 H。

跳房子散列流程很简单，插入一个值，如果在它的 hash 位置发生冲突，即在上界范围内线性探测下一个位置，直到达到上界，如果有空位置则插入，如果到达上界还没插入，则选择一个踢出来，移到后面去

但是杜鹃散列和跳房子散列还处于实验室状态，能否在实际中代替线性探测法或者平方探测法，还有待验证。

### 通用散列/全域散列（universal hashing）

虽然散列表非常有效，并且在适当的装填因子的假设下每次操作花费常数平均开销，但是它们的分析和性能却依赖于具有如下两个基本性质的散列函数:

- 散列函数必须是常数时间内可计算的(即，与散列表中的项数无关)
- 散列函数必须在数组所包含的位置之间均匀地分布表项。

用M代表TableSize，一个典型的通用散列函数如下，它可以把非常大的整数映射到0~M-1的较小整数，其中p是一个比最大的输入关键字还大的整数，a、b随机挑选，共有`p(p-1)`个可能的通用散列函数

```math
H = {H a,b (x) = ((ax + b) mod p) mod M, where 1 ≤ a ≤ p − 1,0 ≤ b ≤ p − 1}
```

C++实现如下，为了防止溢出，必须提升到long long型计算，它至少是64位的

```c++
1 int universalHash( int x, int A, int B, int P, int M )
2 {
3   return static_cast<int>( ( ( static_cast<long long>( A ) * x ) + B ) % P ) % M;
4 }
```

素数p可任选，但是选择一个最利于计算的素数显然更有意义，p=2^31-1就是一个这样的数，这种形式的素数叫做**Mersenne素数(Mersenne prime)**，其他一些Mersenne素数包括2^5-1、2^61-1和2^89-1，它们可以通过一次移位和一次减法实现

Suppose r ≡ y (mod p). If we divide y by (p + 1), then y = q'(p + 1) + r' , where q'
and r' are the quotient and remainder, respectively. Thus, r ≡ q'(p+1)+r'(mod p).
And since (p + 1) ≡ 1 (mod p), we obtain r ≡ q'+ r'(mod p).

下面的通用散列函数实现了这个想法，它被称为**Carter-Wegman**技巧(trick)，在第8行上，移位操作计算用(p+1)去除所得的商，而按位与则计算它的余数。因为(p+1)是2的一个准确的幂，所以这些位操作能够得到所要的结果。由于余数可能几乎与p一样大，因此结果所得到的和可能比p还要大，于是我们在第9行和第10行可以再把它减下来。

```c++
1 const int DIGS = 31;
2 const int mersennep = (1<<DIGS) - 1;
3
4 int universalHash( int x, int A, int B, int M )
5 {
6   long long hashVal = static_cast<long long>( A ) * x + B;
7
8   hashVal = ( ( hashVal >> DIGS ) + ( hashVal & mersennep ) );
9   if( hashVal >= mersennep )
10      hashVal -= mersennep;
11
12  return static_cast<int>( hashVal ) % M;
13 }
```

### 可扩散列(Extendible Hashing)

本章最后的论题处理数据量太大以至于装不进主存的情况。正如我们在第4章看到的，此时主要的考虑是检索数据所需的磁盘存取次数。与前面一样，假设在任一时刻都有N个记录要存储，N的值随时间而变化。此外，最多可把M个记录放入一个磁盘区块。本节将设M=4。如果使用探测散列或分离链接散列，那么主要的问题在于，在一次查找操作期间冲突可能引起多个区块被考察，甚至对于理想分布的散列表也在所难免。不仅如此，当散列表变得过满的时候，必须执行代价极为巨大的**再散列**这一步，它需要O(M)次磁盘访问。

一种聪明的选择叫作**可扩散列(extendible hashing)**，可扩散列的一次查找仅需要两次访问磁盘。并且插入操作也需要很少的磁盘访问。

可扩散列与B树很像，根保存在内存中，用 D 代表根使用的位数， D 也称为目录，则目录中的项数为 2^D 。树叶的元素个数最多为 M， dL 为树叶 L 所有元素共有的最高位的位数， dL ≤ D。假设插入关键字100100，它将进入第三片树叶，但是已满，于是把第三片树叶分裂成两个树叶，它们由前三位确定，这需要将目录的大小增大到3，如下所示

![extendiblehashing.png](http://ww1.sinaimg.cn/large/005GdKShly1g9xplph4ecj30um0bxgqa.jpg)
 
未分裂的树叶由相邻的目录项共同指向，**可以看到尽管目录被重写，但其他树叶未被访问**。

需要注意的是，有可能一个树叶的元素有多于 D+1 个前导位相同时需要多次目录分裂，如上图 D=2 时，插入 111010 、 111011 后再插入 111100 ，目录大小必须增大到4以区分5个关键字；还有一个问题是重复的关键字，若存在超过 M 个重复的关键字，则算法无效。

可扩散列提供了对大型数据库插入和查找操作的快速存取

### 散列小结

- 散列表可以用来以常数平均时间实现 insert和 contains操作
- 要注意装载因子，否则时间界将不再有效。当关键字不是短的字符串或整数时，要仔细选择散列函数
- 对于分离链接散列法，虽然装填因子不是特别大时性能并不明显降低，但装填因子还是应该接近于1
- 对于探测散列算法，一般装填因子不应该超过0.5
- 如果使用线性探测，那么性能随着装填因子接近于1将急速下降
- 再散列算法可以通过使散列表增长(和收缩)来实现，这样将会保持一个合理的装填因子，这对于空间紧缺的散列表是很重要的手段
- 其他一些方法，诸如杜鹃散列和跳房子散列，也能够产生好的结果。因为所有这些算法都是常数时间的，所以强调哪个散列表的实现“最佳”是困难的。- 算法的性能可能严重依赖于所处理的项的类型、底层计算机硬件和程序设计语言。
- 散列表有很丰富的应用：编译器使用散列表跟踪代码中声明的变量，称之为符号表；图论问题；游戏编程中的置换表；在线拼写检验程序；互联网浏览器中的高速缓存(软件)；现代计算机中的内存高速缓冲区(硬件)；路由器的硬件实现
