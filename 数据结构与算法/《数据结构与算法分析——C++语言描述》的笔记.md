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

个人感觉杜鹃散列不是很重要，代码实现就没细看了，底层是用vector存储的，通过下标实现O(1)时间的访问

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

## 优先队列（堆）

很多时候，队列这种先进先出的数据结构并不能体现某些优先级更高的作业，所以需要**优先队列(priority queue)**

优先队列是允许至少下列两种操作的数据结构: insert(插入)以及 deleteMin(删除最小者)，deleteMin的工作是找出、返回并删除优先队列中最小的元素。insert操作等价于 enqueue(入队)，而 deleteMin则是队列运算 dequeue(出队)在优先队列中的等价操作。

### 优先队列的实现

链表实现：

- 我们可以使用一个简单链表(list)在表头以O(1)执行插入操作，并且遍历该链表以删除最小元，但这需要O(N)时间
- 始终让链表保持排序状态，这使得插入代价高昂(即O(N))而 deleteMin花费低廉(即O(1))，但因为插入一般比删除开销小，所以第一种方法更好

二叉查找树：

尽管插入是随机的，删除不是随机，二叉查找树对这两种操作的平均运行时间都是O(logN)。记住我们删除的唯一元素是最小元。反复除去左子树中的节点似乎损害树的平衡，使得右子树加重。然而，右子树是随机的。在最坏的情形，即deleteMin将左子树删空的情形下，右子树拥有的元素最多也就是它应具有的元素数的两倍。这只是在它的期望深度上加了一个小常数。注意，通过使用平衡树，可以把这个界变成最坏情形的界，这将防止出现坏的插入序列

使用查找树可能有些过头，因为它支持许许多多并不需要的操作。我们下面将要使用的二叉堆不需要链，它以最坏情形时间O(logN)支持上述两种操作。插入操作实际上将平均花费常数时间，若无删除操作的干扰，该结构的实现将以线性时间建立一个具有N项的优先队列。

### 二叉堆(binary heap)

一般说到堆这种数据结构，就是指的本节所要介绍的优先队列的实现，类似二叉查找树，堆也有两个性质，即结构性(structure property)与堆序性(heap-order property)，类似AVL树，对堆的一次操作可能会破坏其中一个性质，所以必须要要有补救措施

堆是一种完全二叉树(complete binary tree)，即每层节点都是完全填满的，唯一允许最下一层的节点不满，但只准缺少右边的节点，下图是个例子

![completebinarytree.png](http://ww1.sinaimg.cn/large/005GdKShly1g9yeoa4wqfj30gf0bbdgk.jpg)

因为完全二叉树非常有规律，所以它可以用一个数组来表示，如下所示，对于任意未知i的元素，其左儿子在2i上，右儿子在2i+1上，父亲在[i/2]上（向下取整），注意我们需要事先确定堆的大小，但是这不是问题（甚至还可以重新调整），还需要注意这里位置0为空，后文解释原因

![arraycompletebinarytree.png](http://ww1.sinaimg.cn/large/005GdKShly1g9yev2mruhj30l903v74i.jpg)

于是，堆结构可以由一个(Comparable对象的)数组和一个代表当前堆的大小的整数组成，下面展示了一个优先队列接口

```c++
1 template <typename Comparable>
2 class BinaryHeap
3 {
4   public:
5       explicit BinaryHeap( int capacity = 100 );
6       explicit BinaryHeap( const vector<Comparable> & items );
7
8       bool isEmpty( ) const;
9       const Comparable & findMin( ) const;
10
11      void insert( const Comparable & x );
12      void insert( Comparable && x );
13      void deleteMin( );
14      void deleteMin( Comparable & minItem );
15      void makeEmpty( );
16
17  private:
18      int currentSize; // Number of elements in heap
19      vector<Comparable> array; // The heap array
20
21      void buildHeap( );
22      void percolateDown( int hole );
23 };
```

#### 堆序性

堆序性可以保证操作被快速执行，假设我们要找最小元，最小元在根上查找起来最快，这就叫**最小堆(min heap)**，考虑任意子树也是一个堆，那么任意节点都应该小于它的后裔

应用这个逻辑,我们得到堆序性质。在一个堆中，对于每一个节点X，X的父亲中的关键字小于(或等于)X中的关键字，根节点除外(它没有父亲)。在下图中左边的树是一个堆但是，右边的树则不是(虚线表示堆的有序性被破坏)

![heaporderproperty.png](http://ww1.sinaimg.cn/large/005GdKShly1g9yk2cebxdj30mm096dh1.jpg)

于是堆的findMin只需要O(1)时间

注意：在堆中查找其他元素，最坏情况需要O(N)

#### 基本堆操作

堆操作必须要保证堆序性

##### 堆insert

为将一个元素X插入到堆中，我们在最后一个位置的后面创建一个空穴(hole)，以保证完全二叉树。如果X可以放在该空穴中而并不破坏堆的序，那么插入完成。否则，我们把空穴的父节点上的元素移入该空穴中，父节点变为空穴（也可认为交换空穴与其父节点），这样，空穴好像就朝着根的方向上移动一步。继续该过程直到X能被放入空穴中为止。下图举例说明，为了插入14，我们在堆的下一个可用位置建立个空穴。由于将14插入空穴破坏了堆序性质，因此将空穴的父节点31移入该空穴，空穴上移。继续这种策略，直到找出置入14的正确位置。

![heapinsert.png](http://ww1.sinaimg.cn/large/005GdKShly1g9yk6gjf03j30mv0ipwhe.jpg)

这种策略叫做**上滤(percolate up/up heap)**，用下面的代码很容易实现上滤insert

```c++
1 /**
2 * Insert item x, allowing duplicates.
3 */
4 void insert( const Comparable & x )
5 {
6   if( currentSize == array.size( ) - 1 )
7       array.resize( array.size( ) * 2 );
8
9   // Percolate up
10  int hole = ++currentSize;
11  Comparable copy = x;
12
13  array[ 0 ] = std::move( copy );
14  for( ; x < array[ hole / 2 ]; hole /= 2 )   // x < array[hole/2]与父节点比较，每次for循环后hole /= 2递归访问父节点
15      array[ hole ] = std::move( array[ hole / 2 ] );
16  array[ hole ] = std::move( array[ 0 ] );    // 最后把待插入元素放在hole里
17 }
```

如果要插入的元素是新的最小值，那么它将一直被推向顶端。这样在某一时刻hole将是1，并且程序跳出循环。我们选择把X放到位置0处。如果欲插入的元素是新的最小元从而一直上滤到根处，那么这种插入的时间将长达O(logN),所以**堆insert最坏运行时间为O(logN)**。平均看来，上滤终止得要早。业已证明，执行一次插入平均需要2.507次比较，因此平均 insert将元素上移1.607层，故**堆insert平均运行时间为O(1)**。

##### 堆deleteMin

找出deleteMin是容易的，但是删除它比较繁琐，删除最小元时要在根节点建立一个空穴，因为堆少了一个元素，所以最后一个元素X必须移动到该堆的某个地方，首先比较X与空穴，若X≤空穴，则把X置入空穴，完成deleteMin操作，否则把空穴的两个儿子中的较小者与空穴交换，这样空穴就下移了一层，重复该步骤直至空穴没有儿子了，最后再把X放入空穴中，以保证完全二叉树。

下图中左边的图显示 deleteMin之前的堆。删除13后，我们必须试图正确地将31放到堆中。31不能放在空穴中，因为这将破坏堆序性质。于是，我们把较小的儿子14置入空穴,同时空穴下移一层。重复该过程，由于31大于19，因此把19置入空穴，在更下一层上建立一个新的空穴。然后，因为31还是太大，于是再把26置入空穴，在底层又建立一个新的空穴。最后，我们得以将31置入空穴中。这种一般的策略叫作**下滤(percolate down)**

![heapdeletemin.png](http://ww1.sinaimg.cn/large/005GdKShly1g9ykv0h8fpj30hh0lgq5p.jpg)

堆deleteMin的代码实现如下，注意第40行处理了堆元素为偶数的时候，此时最后一个树叶没有兄弟节点，该算法把每个节点都看成有两个儿子，不用管是否存在右儿子，这里需要仔细想想

```c++
1 /**
2 * Remove the minimum item.
3 * Throws UnderflowException if empty.
4 */
5 void deleteMin( )
6 {
7   if( isEmpty( ) )
8       throw UnderflowException{ };
9
10  array[ 1 ] = std::move( array[ currentSize-- ] );
11  percolateDown( 1 );
12 }
13
14 /**
15 * Remove the minimum item and place it in minItem.
16 * Throws UnderflowException if empty.
17 */
18 void deleteMin( Comparable & minItem )
19 {
20  if( isEmpty( ) )
21      throw UnderflowException{ };
22
23  minItem = std::move( array[ 1 ] );
24  array[ 1 ] = std::move( array[ currentSize-- ] );
25  percolateDown( 1 );
26 }
27
28 /**
29 * Internal method to percolate down in the heap.
30 * hole is the index at which the percolate begins.
31 */
32 void percolateDown( int hole )
33 {
34  int child;
35  Comparable tmp = std::move( array[ hole ] );
36
37  for( ; hole * 2 <= currentSize; hole = child )
38  {
39      child = hole * 2;
40      if( child != currentSize && array[ child + 1 ] < array[ child ] )
41          ++child;
42      if( array[ child ] < tmp )
43          array[ hole ] = std::move( array[ child ] );    // 把空穴的小儿子与空穴交换
44      else
45          break;
46  }
47  array[ hole ] = std::move( tmp );
48 }
```

这种操作最坏情形运行时间为O(logN)。平均而言，被放到根处的元素几乎下滤到堆的底层(即它所来自的那层)，因此平均运行时间为O(logN)。

#### 其他的堆操作

之前讨论的是最小堆，查找最小值只需要O(1)时间，但是最小堆查找最大元比较困难，唯一肯定的是最大元应该在树叶上，但是整个堆差不多一般的元素都在树叶上，这个信息没有太大帮助

下面几种操作均以对数最坏情形时间运行

##### decreaseKey(降低关键字的值)

decreasekey(p,Δ)操作降低在位置p处的项的值，降值的幅度为正的量Δ。由于这可能破坏堆序性质，因此必须通过**上滤**对堆进行调整。该操作对系统管理程序是有用的：系统管理程序能够使它们的程序以最高的优先级来运行。

##### increaseKey(增加关键字的值)

increasekey(p,Δ)操作增加在位置p处的项的值，增值的幅度为正的量Δ。这可以用**下滤**来完成。许多调度程序自动地降低正在过多地消耗CPU时间的进程的优先级

##### remove(删除)

remove(p)操作删除堆中位置p上的节点。该操作通过首先执行 decreasekey(p,∞)（待删除节点会移动到根节点处，为当前最小堆的最小值）。然后再执行 deleteMin()来完成。当一个进程被用户中止(而不是正常终止)时，它必须从优先队列中被除去。

##### build Heap(构建堆)

有时二叉堆是由一些项的一个初始集合构造而得的，这种构造函数以N项作为输入，并把它们放到一个堆中。显然，这可以使用N个相继的 insert操作来完成。由于每个 insert将花费O(1)平均时间以及O(logN)的最坏情形时间，因此该算法的总的运行时间平均是O(N)时间，而最坏情形则是O(logN)时间。由于这是一种特殊的指令，没有其他操作干扰，而且我们已经知道该指令能够以线性平均时间实施，因此，期望能够保证线性时间界的考虑是合乎情理的

一般的算法考虑这N项是任意顺序插入的，下面的构造函数可以用来构造一棵堆序的树，这差不多要O(N)时间，**属于自下向上的建堆方式**

```c++
1   explicit BinaryHeap( const vector<Comparable> & items )
2   : array( items.size( ) + 10 ), currentSize{ items.size( ) }
3   {
4       for( int i = 0; i < items.size( ); ++i )
5           array[ i + 1 ] = items[ i ];
6           buildHeap( );
7   }
8
9   /**
10  * Establish heap order property from an arbitrary
11  * arrangement of items. Runs in linear time.
12  */
13  void buildHeap( )
14  {
15      for( int i = currentSize / 2; i > 0; --i )
16          percolateDown( i );
17 }
```

下面展示了从一棵无序的树到最小堆的过程

![buildheap.png](http://ww1.sinaimg.cn/large/005GdKShly1g9ymf8acyij30hb0kg77q.jpg)

还有一种是自顶向下的建堆方式，具有O(NlogN)的时间复杂度，这种方式就是从根节点开始，一个一个地把点insert进入堆中，显然自下而上的建堆更快

关于二叉树建堆的时间复杂度分析，这里有篇知乎可以继续深入：[为什么建立一个二叉堆的时间为 O (N) 而不是 O (Nlog (N))?](https://www.zhihu.com/question/264693363)

#### 理想二叉树(perfect binary tree)

For the perfect binary tree of height h containing `2^(h+1)−1` nodes, the sum of the heights of the nodes is `2^(h+1)−1−(h+1)`.

注意：**一棵完全二叉树不是理想二叉树**

### 优先队列的应用

#### 选择问题

我们将要考察的第一个问题是来自第1章1.1节的选择问题( selection problem)。回忆当时的输入是N个元素以及一个整数k，这N个元素可以是全序的( totally ordered)。该选择问题是要找出第k个最大的元素。在第1章中给出了两个算法，不过它们都不是很有效的算法。第一个算法我们将称其为1A，是把这些元素读入数组并将它们排序，返回适当的元素。假设使用的是简单的排序算法(如冒泡排序)，则运行时间为O(N^2)。另一个算法叫作1B，是将k个元素读入一个数组并将其排序。这些元素中的最小者在第k个位置上。我们一个一个地处理其余的元素。当一个元素被读入时，它先与数组中第k个元素比较，如果该元素大，那么将第k个元素除去，而这个新元素则被放在其余k-1个元素间的正确的位置上。当算法结束时，第k个位置上的元素就是问题的解答。该方法的运行时间为O(Nk)（因为总共要处理N个元素，每个元素要与前k个元素比较）。如果k=[N/2]（向上取整），那么这两种算法都是O(N^2)。注意，对于任意的k，我们可以求解对称的问题：找出第(N-k+1)个最小的元素，从而k=[N/2]（向上取整）。实际上是这两个算法最困难的情况。这刚好也是最有趣的情形，因为k的这个值称为中位数( median)。

我们在这里给出两个基于（最小）堆的算法，在k=[N/2]（向上取整）的极端情形它们均以O(NogN)运行，这是明显的改进

##### 算法6A

为了简单起见，假设只考虑找出第k个最小的元素。该算法很简单。我们将N个元素读入一个数组。然后对该数组应用 buildHeap算法。最后，执行k次 deletemin操作。从该堆最后提取的元素就是我们的答案。显然，用最大堆可以使用此算法找出第k个最大的元素。如果使用 buildHeap，构造堆的最坏情形用时是O(N)，而每次 deleteMin用时O(logN)。由于有k次 deleteMin，因此得到总的运行时间为O(N+klogN)。如果k=O(N/logN)，那么运行时间取决于 buildHeap操作，即O(N)。对于大的k值，运行时间为O(klogN)。如果k=[N/2]（向上取整），那么运行时间则为θ(NlogN)。

注意，如果对k=N运行该程序并在元素离开堆时记录它们的值，那么实际上已经对输入文件以时间O(NlogN)做了排序。在第7章，我们将细化该想法，得到一种快速的排序算法，叫作**堆排序(heapsort)**。

##### 算法6B

关于第2个算法，我们回到原始问题，找出第k个最大的元素。我们使用算法1B的思路。在任一时刻我们都将保留k个最大元素的集合S。在前k个元素读入以后，当再读入一个新的元素时，该元素将与第k个最大元素进行比较，记这第k个最大的元素为Sk。注意，Sk是S中最小的元素。如果新的元素更大，那么用新元素代替S中的Sk。此时，S将有一个新的最小元素，它可能是新添加进的元素，也可能不是。在输入终了时，我们找到S中最小的元素，将其返回，它就是答案。

这基本上与第1章中描述的算法相同。不过，**这里使用一个堆来实现S**。前k个元素通过调用一次 buildHeap以总时间O(k)被置入堆中。处理每个其余的元素的时间为O(1)，用于检测是否元素进入S，再加上时间O(logk)，用于在必要时删除Sk并插入新元素。因此，总的时间是O(k+(N-k)logk)=O( Nlogk)。该算法也给出找出中位数的时间界θ(NlogN)

在第7章，我们将看到如何以平均时间O(N)解决这个问题。在第10章，我们将看到个以O(N)最坏情形时间求解该问题的算法，虽然不实用但却很精妙。

#### 事件模拟

不懂作者在写什么-_-

看到一篇还不错的讲堆的应用的文章：[堆的应用：如何快速获取到 Top 10 最热门的搜索关键词](https://shouliang.github.io/2018/11/28/%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E4%B8%8E%E7%AE%97%E6%B3%95/29%20%7C%20%E5%A0%86%E7%9A%84%E5%BA%94%E7%94%A8%EF%BC%9A%E5%A6%82%E4%BD%95%E5%BF%AB%E9%80%9F%E8%8E%B7%E5%8F%96%E5%88%B0Top%2010%E6%9C%80%E7%83%AD%E9%97%A8%E7%9A%84%E6%90%9C%E7%B4%A2%E5%85%B3%E9%94%AE%E8%AF%8D/)

### d堆(d heap)

d堆就是二叉堆的推广，所有节点都有d个儿子，所以二叉堆可以看成d堆的特例，二叉堆是2堆

一般d堆比二叉堆浅得多，它将insert操作改进到了O(log d N)，然而对于大的d，deleteMin操作费时得多，因为d个儿子的最小值是必须要找出来的

当优先队列太大以致于不能装入内存，d堆也是很有用的，d堆能够以与B树大致相同的方式发挥作用

最后有证据显示，在实践中，4堆可以胜过二叉堆

### 左式堆(leftist heap)

二叉堆底层是用数组实现的，如果想把两个堆合并起来，想要在o(N)时间内完成似乎很困难，故所有支持高效合并的高级数据结构都需要使用链式数据结构，但是这又有可能导致其他操作变慢

**左式堆(leftist heap)**也是一种二叉堆，也有结构性和堆序性，区别在于：左式堆不是理想平衡的(perfectly balanced)，而实际上是趋向于非常的不平衡

合并两个左式堆的时间界为O(logN)

#### 左式堆的性质

我们把任一节点X的零路径长(null path length)，npl(X)，定义为从X到一个不具有两个儿子的节点的最短路径的长。因此，具有0个或1个儿子的节点的npl为0，而npl(nullptr)=-1。在下图给出的树中，零路径长标记在树的节点内。

![leftisttreeexample.png](http://ww1.sinaimg.cn/large/005GdKShly1g9yp7th2tlj30k208vmxv.jpg)

注意，任一节点的零路径长比它的诸儿子节点的零路径长的最小值多1。这个结论也适用少于两个儿子的节点，因为nu1ptr的零路径长是-1。

左式堆性质是：对于堆中的每一个节点X，左儿子的零路径长至少与右儿子的零路径长一样。所以，上图只有左边的那棵树满足该性质，它才是左式堆

这个性质使堆偏向于向左增加深度，于是我们就有了名称**左式堆(leftist heap)**

因为左式堆趋向于加深左路径，所以右路径应该短。

#### 左式堆操作

注意，插入只是合并的特殊情形，因为可以把插入看成是单节点堆与一个更大的堆的 merge。

我们的输入是两个左式堆H1和H2，最小的元素在根处。除数据、左指针和右指针所用空间外，每个节点还要有一个指示零路径长的项。首先可比较它们的根。首先，我们递归地将具有较大的根值的堆与具有较小的根值的堆的右子堆合并。在本例中这就是说，我们递归地将H2与H1的根在8处的右子堆合并，得到图6.22中的堆。递归描述暂时先不细讲。然后让这个新的堆成为H1的根的右儿子，如图6.23所示，但因为这违反了左式堆的性质，所以把根的左右儿子调换即可，新的零路径长是新的右儿子的零路径长加1，最后得到图2.3的左式堆

![mergeleftisttree.png](http://ww1.sinaimg.cn/large/005GdKShly1g9yr7x2gkwj30980fiaaz.jpg)

执行合并所用的时间与右路径的长的和成正比，因为在调用期间对每个访问节点花费常数时间，所以合并两个左式堆的时间界为O(logN)

下面给出了左式堆的类接口以及合并操作的实现

```c++
1 template <typename Comparable>
2 class LeftistHeap
3 {
4   public:
5       LeftistHeap( );
6       LeftistHeap( const LeftistHeap & rhs );
7       LeftistHeap( LeftistHeap && rhs );
8
9       ~LeftistHeap( );
10
11      LeftistHeap & operator=( const LeftistHeap & rhs );
12      LeftistHeap & operator=( LeftistHeap && rhs );
13
14      bool isEmpty( ) const;
15      const Comparable & findMin( ) const;
16
17      void insert( const Comparable & x );
18      void insert( Comparable && x );
19      void deleteMin( );
20      void deleteMin( Comparable & minItem );
21      void makeEmpty( );
22      void merge( LeftistHeap & rhs );
23
24  private:
25      struct LeftistNode
26      {
27          Comparable element;
28          LeftistNode *left;
29          LeftistNode *right;
30          int npl;
31
32           LeftistNode( const Comparable & e, LeftistNode *lt = nullptr,
33          LeftistNode *rt = nullptr, int np = 0 )
34          : element{ e }, left{ lt }, right{ rt }, npl{ np } { }
35
36          LeftistNode( Comparable && e, LeftistNode *lt = nullptr,
37          LeftistNode *rt = nullptr, int np = 0 )
38          : element{ std::move( e ) }, left{ lt }, right{ rt }, npl{ np } { }
39      };
40
41      LeftistNode *root;
42
43      LeftistNode * merge( LeftistNode *h1, LeftistNode *h2 );
44      LeftistNode * merge1( LeftistNode *h1, LeftistNode *h2 );
45
46      void swapChildren( LeftistNode *t );
47      void reclaimMemory( LeftistNode *t );
48      LeftistNode * clone( LeftistNode *t ) const;
49 };
```

```c++
1 /**
2 * Merge rhs into the priority queue.
3 * rhs becomes empty. rhs must be different from this.
4 */
5 void merge( LeftistHeap & rhs )
6 {
7   if( this == &rhs ) // Avoid aliasing problems
8       return;
9
10  root = merge( root, rhs.root );
11  rhs.root = nullptr;
12 }
13
14 /**
15 * Internal method to merge two roots.
16 * Deals with deviant cases and calls recursive merge1.
17 */
18 LeftistNode * merge( LeftistNode *h1, LeftistNode *h2 )
19 {
20  if( h1 == nullptr )
21      return h2;
22  if( h2 == nullptr )
23      return h1;
24  if( h1->element < h2->element )
25      return merge1( h1, h2 );
26  else
27      return merge1( h2, h1 );
28 }
```

```c++
1 /**
2 * Internal method to merge two roots.
3 * Assumes trees are not empty, and h1’s root contains smallest item.
4 */
5 LeftistNode * merge1( LeftistNode *h1, LeftistNode *h2 )
6 {
7   if( h1->left == nullptr ) // Single node
8       h1->left = h2; // Other fields in h1 already accurate
9   else
10  {
11      h1->right = merge( h1->right, h2 );
12      if( h1->left->npl < h1->right->npl )
13          swapChildren( h1 );
14      h1->npl = h1->right->npl + 1;
15  }
16   return h1;
17 }
```

插入可以看做一个单节点的堆与另一个堆合并，而为了执行deleteMin，我们只需除掉根而得到两个堆，然后再将这两个堆合并即可，用时O(logN)，两者实现如下

```c++
1 /**
2 * Remove the minimum item.
3 * Throws UnderflowException if empty.
4 */
5 void deleteMin( )
6 {
7   if( isEmpty( ) )
8       throw UnderflowException{ };
9
10  LeftistNode *oldRoot = root;
11  root = merge( root->left, root->right );
12  delete oldRoot;
13 }
14
15 /**
16 * Remove the minimum item and place it in minItem.
17 * Throws UnderflowException if empty.
18 */
19 void deleteMin( Comparable & minItem )
20 {
21  minItem = findMin( );
22  deleteMin( );
23 }
```

### 斜堆(skew heap)

斜堆( skew heap)是左式堆的自调节形式，实现起来极其简单。斜堆和左式堆间的关系类似于伸展树和AVL树间的关系。斜堆是具有堆序的二叉树，但是不存在对树的结构限制。不同于左式堆，关于任意节点的零路径长的任何信息都不再保留。斜堆的右路径在任何时刻都可以任意长，因此，所有操作的最坏情形运行时间均为O(M)。然而，正如同伸展树，可以证明(见第11章)对任意M次连续操作，总的最坏情形运行时间是O(MlogN)。因此，斜堆每
次操作的**摊还开销(amortized cost)**为O(logN)。

### 二项队列（binomial queue）

二项队列( binomial queue)不同于我们已经看到的所有优先队列的实现之处在于，一个二项队列不是**一棵**堆序的树，而是**一组**堆序树(heap- ordered tree)，称为森林(forest)。堆序树中的每一棵都是有约束的形式，叫作二项树(binomial tree)。每一个高度上至多存在一棵二项树。高度为0的二项树是一棵单节点树，高度为k的二项树Bk通过将一棵二项树Bk-1附接到另一棵二项树Bk-1的根上而构成。图6.34显示出二项树B0、B1、B2、B3以及B4

![binomialtrees.png](http://ww1.sinaimg.cn/large/005GdKShly1g9ysu4f43lj30hh0cl3ze.jpg)

从图中看到，二项树Bk由一个带有儿子B0,B1,…,Bk-1的根组成。高度为k的二项树恰好有2个节点，而在深度d处的节点个数是二项系数Ckd(k为下标，d为上标，即排列组合中的记法)，如果把堆序施加到二项树上并允许任意高度上最多一棵二项树，那么我们就能够用二项树的集合表示任意大小的优先队列。

#### 二项队列操作

最小元可以通过搜索所有的树的根来找出。由于最多有logN棵不同的树，因此最
小元可以时间O(logN)找到。另外，如果我们记住当最小元在其他操作期间变化时更新它，那么也可以保留最小元的信息并以O(1)时间执行这种操作。

##### 二项队列merge

考虑两个二项队列H1和H2，它们分别具有6个和7个元素，见图6.36。合并操作基本上是通过将两个队列加到一起来完成的。令H3是新的二项队列。由于H1没有高度为0的二项树而H2有，因此我们就用H2中高度为0的二项树作为H3的一部分。然后，将两个高度为1的二项树相加。由于H1和H2都有高度为1的二项树，因此可以将它们合并，让大的根成为小的根的子树，从而建立高度为2的二项树，见图6.37。这样，H3将没有高度为1的二项树。现在存在3棵高度为2的二项树，即H1和H2原有的两棵二项树以及由上一步形成的一棵二项树。我们将一棵高度为2的二项树放到H3中，并合并其他两棵二项树，得到一棵高度为3的二项树。由于H和H2都没有高度为3的二项树，因此该二项树就成为H3的一部分，合并结束。最后得到的二项队列如图6.38所示

![binomialqueuemerge.png](http://ww1.sinaimg.cn/large/005GdKShly1g9yt2fjdcxj30h30gwabm.jpg)

总结：合并两棵二项树花费O(1)时间，而总共存在O(log)棵二项树，因此**合并操作在最坏情形下花费时间O(logN)**。为使该操作更有效，需要将这些树放到按照高度排序的二项队列中，当然这做起来是件简单的事情

##### 二项队列insert

插入实际上就是特殊情形的合并，因为我们只要创建一棵单节点树并执行一次合并即可，这种操作的最坏情形运行时间也是O(logN)。更准确地说，如果在优先队列中不存在的最小的二项树是Bi，那么将元素插入其中的运行时间与i+1成正比。例如，H2(见图6.38)缺少高度为1的二项树，因此插入将进行两步终止。由于二项队列中的每棵树均以概率1/2出现，于是我们预计插入在两步后终止，因此，平均时间是O(1)。不仅如此，分析将指出，对一个初始为空的二项队列进行N次 insert将花费O(N)最坏情形时间。事实上，只用N-1次比较就有可能进行该操作

作为一个例子，我们用图6.39~图6.45演示通过依序插入1~7来构成一个二项队列。4的插入展现一种坏的情形。我们把4与B0合并，得到一棵新的高度为1的树。然后将该树与B1合并，得到一棵高度为2的树，它是新的优先队列。我们把这些算作3步(两次树的合并再加上终止情形)。在插入7以后的下一次插入又是一个坏情形，需要3次树的合并操作。

![binomialqueueinsert.png](http://ww1.sinaimg.cn/large/005GdKShly1g9yt46txe0j307p0kz3zl.jpg)

总结：**二项队列insert，最坏情况O(logN)，平均O(1)**

##### 二项队列deleteMin

deleteMin可以通过首先找出一棵具有最小根的二项树来完成。令该树为Bk，并令原始的优先队列为H。我们从H的树的森林中删除二项树Bk，形成新的二项队列H'。再在Bk中删除它的根，得到二项树B0,B1,…,Bk-1，它们形成优先队列H''。合并H'和H''，操作结束。

作为例子，设对3执行一次 deleteMin，它也在图6.46中给出。最小的根是12，因此得到图6.47和图6.48中的两个优先队列H'和H''，合并H'和H''后得到的二项队列是最后的答案，如图6.49所示。

![binomialqueuedeletemin.png](http://ww1.sinaimg.cn/large/005GdKShly1g9yuoistvyj30gu0k80up.jpg)

总结：为了分析，首先注意，deleteMin操作将原二项队列一分为二。找出含有最小元素的树并创建队列H和H"，花费时间O(logN)。合并这两个队列又花费O(logN)时间，因此，**整个deleteMin操作花费时间O(logN)**

#### 二项队列的实现

deleteMin操作需要快速找出根的所有子树的能力,因此,需要一般树的标准表示:每个节点的儿子都留在一个链表中,而且每个节点都有一个指针指向它的第一个儿子(如果有的话)。该操作还要求诸儿子按照它们子树的大小排序。我们还需要保证合并两棵树容易。当两棵树被合并时,其中的一棵树作为儿子被加到另一棵树上。由于这棵新树将是最大的子树,因此,以大小递减的方式保持这些子树是有意义的。只有这时才能够有效地合并两棵二项树从而合并两个二项队列。二项队列将是二项树的数组。总而言之,二项树的每一个节点都将包含数据、第一个儿子以及右兄弟。二项树中的诸儿子以递减次序排列。

下图的数组包含了二项队列的根节点

![binomialqueueimplementation.png](http://ww1.sinaimg.cn/large/005GdKShly1g9yvmc12y2j30kr0dawg1.jpg)

二项队列的类接口如下

```c++
1 template <typename Comparable>
2 class BinomialQueue
3 {
4   public:
5       BinomialQueue( );
6       BinomialQueue( const Comparable & item );
7       BinomialQueue( const BinomialQueue & rhs );
8       BinomialQueue( BinomialQueue && rhs );
9
10      ~BinomialQueue( );
11
12      BinomialQueue & operator=( const BinomialQueue & rhs );
13      BinomialQueue & operator=( BinomialQueue && rhs );
14
15      bool isEmpty( ) const;
16      const Comparable & findMin( ) const;
17
18      void insert( const Comparable & x );
19      void insert( Comparable && x );
20      void deleteMin( );
21      void deleteMin( Comparable & minItem );
22
23      void makeEmpty( );
24      void merge( BinomialQueue & rhs );
25
26  private:
27      struct BinomialNode
28      {
29          Comparable element;
30          BinomialNode *leftChild;
31          BinomialNode *nextSibling;
32
33          BinomialNode( const Comparable & e, BinomialNode *lt, BinomialNode *rt )
34          : element{ e }, leftChild{ lt }, nextSibling{ rt } { }
35
36          BinomialNode( Comparable && e, BinomialNode *lt, BinomialNode *rt )
37          : element{ std::move( e ) }, leftChild{ lt }, nextSibling{ rt } { }
38      };
39
40      const static int DEFAULT_TREES = 1;
41
42      vector<BinomialNode *> theTrees; // An array of tree roots
43      int currentSize; // Number of items in the priority queue
44
45      int findMinIndex( ) const;
46      int capacity( ) const;
47      BinomialNode * combineTrees( BinomialNode *t1, BinomialNode *t2 );
48      void makeEmpty( BinomialNode * & t );
49      BinomialNode * clone( BinomialNode * t ) const;
50 };
```

合并二项队列的底层是合并两棵同样大小的二项树，如下图所示

![binomialtreesmerge.png](http://ww1.sinaimg.cn/large/005GdKShly1g9yvu4gozpj30k406kaas.jpg)

合并二项树的代码如下，if语句保证了当前`t1->element <= t2->element`，对于图6.53， 左边为t1，右边为t2

```c++
1 /**
2 * Return the result of merging equal-sized t1 and t2.
3 */
4 BinomialNode * combineTrees( BinomialNode *t1, BinomialNode *t2 )
5 {
6   if( t2->element < t1->element )
7       return combineTrees( t2, t1 );
8   t2->nextSibling = t1->leftChild;
9   t1->leftChild = t2;
10  return t1;
11 }
```

合并二项队列的实现如下，这里代码量较大，carry是从上一步得来的树，相当于加法里的进位

```c++
1 /**
2 * Merge rhs into the priority queue.
3 * rhs becomes empty. rhs must be different from this.
4 * Exercise 6.35 needed to make this operation more efficient.
5 */
6 void merge( BinomialQueue & rhs )
7 {
8   if( this == &rhs ) // Avoid aliasing problems
9       return;
10
11  currentSize += rhs.currentSize;
12
13  if( currentSize > capacity( ) )
14  {
15      int oldNumTrees = theTrees.size( );
16      int newNumTrees = max( theTrees.size( ), rhs.theTrees.size( ) ) + 1;
17      theTrees.resize( newNumTrees );
18      for( int i = oldNumTrees; i < newNumTrees; ++i )
19          theTrees[ i ] = nullptr;
20  }
21
22  BinomialNode *carry = nullptr;
23  for( int i = 0, j = 1; j <= currentSize; ++i, j *= 2 )
24  {
25      BinomialNode *t1 = theTrees[ i ];
26      BinomialNode *t2 = i < rhs.theTrees.size( ) ? rhs.theTrees[ i ]
27      : nullptr;
28      int whichCase = t1 == nullptr ? 0 : 1;
29      whichCase += t2 == nullptr ? 0 : 2;
30      whichCase += carry == nullptr ? 0 : 4;
31
32      switch( whichCase )
33      {
34          case 0: /* No trees */
35          case 1: /* Only this */
36              break;
37          case 2: /* Only rhs */
38              theTrees[ i ] = t2;
39              rhs.theTrees[ i ] = nullptr;
40              break;
41          case 4: /* Only carry */
42              theTrees[ i ] = carry;
43              carry = nullptr;
44              break;
45          case 3: /* this and rhs */
46              carry = combineTrees( t1, t2 );
47              theTrees[ i ] = rhs.theTrees[ i ] = nullptr;
48              break;
49          case 5: /* this and carry */
50              carry = combineTrees( t1, carry );
51              theTrees[ i ] = nullptr;
52              break;
53          case 6: /* rhs and carry */
54              carry = combineTrees( t2, carry );
55              rhs.theTrees[ i ] = nullptr;
56              break;
57          case 7: /* All three */
58              theTrees[ i ] = carry;
59              carry = combineTrees( t1, t2 );
60              rhs.theTrees[ i ] = nullptr;
61              break;
62      }
63  }
64
65  for( auto & root : rhs.theTrees )
66      root = nullptr;
67  rhs.currentSize = 0;
68 }

二项队列的deleteMin实现如下

```c++
1 /**
2 * Remove the minimum item and place it in minItem.
3 * Throws UnderflowException if empty.
4 */
5 void deleteMin( Comparable & minItem )
6 {
7   if( isEmpty( ) )
8       throw UnderflowException{ };
9
10  int minIndex = findMinIndex( );
11  minItem = theTrees[ minIndex ]->element;
12
13  BinomialNode *oldRoot = theTrees[ minIndex ];
14  BinomialNode *deletedTree = oldRoot->leftChild;
15  delete oldRoot;
16
17  // Construct H’’
18  BinomialQueue deletedQueue;
19  deletedQueue.theTrees.resize( minIndex + 1 );
20  deletedQueue.currentSize = ( 1 << minIndex ) - 1;
21  for( int j = minIndex - 1; j >= 0; --j )
22  {
23      deletedQueue.theTrees[ j ] = deletedTree;
24      deletedTree = deletedTree->nextSibling;
25      deletedQueue.theTrees[ j ]->nextSibling = nullptr;
26  }
27
28  // Construct H’
29  theTrees[ minIndex ] = nullptr;
30  currentSize -= deletedQueue.currentSize + 1;
31
32  merge( deletedQueue );
33 }
34
35 /**
36 * Find index of tree containing the smallest item in the priority queue.
37 * The priority queue must not be empty.
38 * Return the index of tree containing the smallest item.
39 */
40 int findMinIndex( ) const
41 {
42  int i;
43  int minIndex;
44
45  for( i = 0; theTrees[ i ] == nullptr; ++i )
46      ;
47
48  for( minIndex = i; i < theTrees.size( ); ++i )
49      if( theTrees[ i ] != nullptr &&
50          theTrees[ i ]->element < theTrees[ minIndex ]->element )
51          minIndex = i;
52
53  return minIndex;
54 }

### 标准库中的优先队列——priority_queue

STL中的二叉堆是通过priority_queue的类模板实现的，可以在标准头文件queue中找到它，必须要注意：**STL中priority_queue实现的是最大堆**，其核心成员函数是：

```c++
void push( const Object & x );
const Object & top( ) const; // 返回最大元素
void pop( ); // 删除最大元素
bool empty( );
void clear( );
```

当然，priority_queue也可以作为最小堆使用，在类模板实例化时传入greater函数对象作为比较器即可，只是默认情况下是最大堆，下面是个例子，展示了priority_queue如何实现最大堆与最小堆，priority_queue类模板中的容器类型参数也允许默认值，几乎总是用vector作为容器的

```c++
1 #include <iostream>
2 #include <vector>
3 #include <queue>
4 #include <functional>
5 #include <string>
6 using namespace std;
7
8 // Empty the priority queue and print its contents.
9 template <typename PriorityQueue>
10 void dumpContents( const string & msg, PriorityQueue & pq )
11 {
12  cout << msg << ":" << endl;
13  while( !pq.empty( ) )
14  {
15      cout << pq.top( ) << endl;
16      pq.pop( );
17  }
18 }
19
20 // Do some inserts and removes (done in dumpContents).
21 int main( )
22 {
23  priority_queue<int> maxPQ;
24  priority_queue<int,vector<int>,greater<int>> minPQ;
25
26  minPQ.push( 4 ); minPQ.push( 3 ); minPQ.push( 5 );
27  maxPQ.push( 4 ); maxPQ.push( 3 ); maxPQ.push( 5 );
28
29  dumpContents( "minPQ", minPQ ); // 3 4 5
30  dumpContents( "maxPQ", maxPQ ); // 5 4 3
31
32  return 0;
33 }
```

## 排序(Sorting)

### 排序预备知识

推荐可视化学习排序的资源，当然也有其他算法：[visualgo](http://visualgo.net/sorting)

本章例子假设只包含整数，并且排序能在主存中完成，而在本章末尾讨论了对于大量元素的排序，它们没法放入主存，得放在磁盘中完成，这叫**外部排序(external sorting)**

任何通用的算法均需要Ω(NlogN)次比较

这里的接口不同于STL中的排序算法。在STL中，排序是通过使用函数模板sort完成的。sort的参数代表容器(中某个范围)的开始和终端标记(endmarker)以及一个可选的比较器

```c++
void sort( Iterator begin, Iterator end );
void sort( Iterator begin, Iterator end, Comparator cmp );
```

迭代器必须支持随机访问。sort算法并不保证相等的项保持它们原有的顺序(若这很重要，则可使用stable_sort而不用sort)。例如，在

```c++
std::sort( v.begin( ), v.end( ) );
std::sort( v.begin( ), v.end( ), greater<int>{ } );
std::sort( v.begin( ), v.begin( ) + ( v.end( ) - v.begin( ) ) / 2 );
```

中第一个调用是将整个容器v以非降顺序排序，第二个调用是将整个容器以非增顺序排序，第三个调用则将容器的前半部分以非降顺序排序。

排序算法的稳定与否，在于原来相等的项在排序后是否仍然保持原有的顺序

### 插入排序(insertion sort)

插入排序是最简单的排序算法之一

插入排序由N-1趟排序组成。对于p=1到N-1趟，插入排序保证从位置0到位置p上的元素为已排序状态。插入排序利用了这样的事实；已知位置0到位置p-1上的元素已经处于排过序的状态。图7.1显示一个数组样例在每一趟插入排序后的情况。

![insertionsort.png](http://ww1.sinaimg.cn/large/005GdKShly1g9zq1jczhcj30hi06kwf4.jpg)

#### 简单的插入排序实现

个人先写了个交换版本的插入排序实现

```c++
template <typename Comparable>
void insertionSort(vector<Comparable> &a)
{
    for (int i = 1; i < a.size(); ++i)
    {
        for (int j = i; j > 0; --j)
        {
            if (a[j] < a[j - 1])
            {
                swap(a[j], a[j - 1]);
            }
            else
            {
                break;
            }
        }
    }
}
```

书中使用了**移动(move)**，这比**交换(swap)**更快，每次内层循环之前把待排元素用tmp变量暂存起来，然后每个大于tmp的元素后移一位

```c++
1 /**
2 * Simple insertion sort.
3 */
4 template <typename Comparable>
5 void insertionSort( vector<Comparable> & a )
6 {
7   for( int p = 1; p < a.size( ); ++p )
8   {
9       Comparable tmp = std::move( a[ p ] );
10
11      int j;
12      for( j = p; j > 0 && tmp < a[ j - 1 ]; --j )
13          a[ j ] = std::move( a[ j - 1 ] );
14      a[ j ] = std::move( tmp );
15  }
16 }
```

#### STL中的插入排序

在预备知识小节，我们知道STL中的sort函数模板接受一对迭代器作为参数，并且还支持第三个比较器参数

这里有个问题，模板类型参数（即泛型类型）都是Iterator；可是Object不是一个泛型类型参数，在C++11之前要额外的工作来解决这个问题，但C++11引入了decltpye，实现如下

```c++
1 /*
2 * The two-parameter version calls the three-parameter version,
3 * using C++11 decltype
4 */
5 template <typename Iterator>
6 void insertionSort( const Iterator & begin, const Iterator & end )
7 {
8   insertionSort( begin, end, less<decltype(*begin)>{ } );
9 }
```

```c++
1 template <typename Iterator, typename Comparator>
2 void insertionSort( const Iterator & begin, const Iterator & end,
3 Comparator lessThan )
4 {
5   if( begin == end )
6       return;
7
8   Iterator j;
9
10  for( Iterator p = begin+1; p != end; ++p )
11  {
12      auto tmp = std::move( *p );
13      for( j = p; j != begin && lessThan( tmp, *( j-1 ) ); --j )
14          *j = std::move( *(j-1) );
15      *j = std::move( tmp );
16  }
17 }
```

#### 插入排序的分析

由于嵌套循环中的每一个都可能用到N次迭代，因此插入排序为O(N^2)，而且这个界还是精确的，因为以反序的输入可以达到该界

另一方面，如果输入数据已预先排序，那么运行时间为O(N)，因为内层for循环中的检测总是立即失败而使下一语句得不到执行。事实上，如果输入几乎被排序(该术语将在下节更严格地定义)，那么插入排序将运行得很快。由于这种变化差别很大，因此值得我们去分析该算法平均情形的行为。实际上，和各种其他排序算法一样，插入排序的平均情形也是θ(N^2)，详见下节的分析。

### 一些简单排序算法的下界

成员为数的数组的一个**逆序(inversion)**即具有性质`i<j`但`a[i]>a[j]`的序偶( ordered pair)`(a[i],a[j])。在上节的例子中，输入数据34,8,64,51,32,21有9个逆序，即(34,8),(34,32),(34,21),(64,51),(64,32),(64,21),(51,32),(51,21),以及(32,21)。注意，这正好是
需要由插入排序(隐含)执行的交换次数。情况总是这样，因为交换两个不按顺序排列的相邻元素恰好消除一个逆序，而一个排过序的数组没有逆序。由于算法中还有O(N)项其他的工作，因此插入排序的运行时间是O(I+M)，其中I为原始数组中的逆序数。于是，若逆序数是O(N)，则插入排序以线性时间运行。

定理：N个互异元素的数组的平均逆序数是N(N-1)/4

定理：通过交换相邻元素进行排序的任何算法平均都需要Ω(N^2)时间

### 希尔排序

上节所提到的，它通过比较相距一定间隔的元素来工作。各趟比较所用的距离随着算法的进行而减小，直到只比较相邻元素的最后一趟排序为止。由于这个原因，希尔排序有时也叫作缩减增量排序(diminishing increment sort)。

希尔排序使用一个序列h1,h2,…,hk，叫作增量序列(increment sequence)。只要h1=1，任何增量序列都是可行的，但有些增量序列性能更好。在使用增量hk的一趟排序之后，对于每一个i我们都有`a[i]≤a[i+hk]`，所有相隔hk的元素都被排序。此时称文件是hk排序的(hk-sorted)。实际上，增量为hk的子数组的排序方式为插入排序，故**希尔排序的底层是用插入排序实现的**

![shellsort.png](http://ww1.sinaimg.cn/large/005GdKShly1g9zszjtqlyj30kf0530tc.jpg)

增量序列的一个流行（但不是很好）的选择是使用Shell建议的序列：hk初始为[N/2]，hk=[hk/2]（都是向下取整）

#### 希尔排序的实现

下面给出了希尔排序的实现，它的增量序列是按照Shell建议那样的，书上的外层for循环缺少花括号，这里补上了，这段代码初看有问题，但经我检验是可行的，内层for循环的逻辑需要搞清楚，序号为0~gap的元素是各子数组的首元素，默认已经排好序了，当考察a[i]时，进行插入排序，从所属子数组的最后一个元素开始依次往前比较，直至找到a[i]应该插入的位置，然后i增大直至遍历后面所有待排元素

```c++
1 /**
2 * Shellsort, using Shell’s (poor) increments.
3 */
4 template <typename Comparable>
5 void shellsort( vector<Comparable> & a )
6 {
7   for( int gap = a.size( ) / 2; gap > 0; gap /= 2 )
    {
8       for( int i = gap; i < a.size( ); ++i )
9       {
10          Comparable tmp = std::move( a[ i ] );
11          int j = i;
12
13          for( ; j >= gap && tmp < a[ j - gap ]; j -= gap )
14              a[ j ] = std::move( a[ j - gap ] );
15          a[ j ] = std::move( tmp );
16      }
    }
17 }
```

#### 希尔排序的分析

使用希尔增量时希尔排序的最坏情形运行时间为θ(N^2)

使用 Hibbard增量的希尔排序的最坏情形运行时间为θ(N^(3/2))。

最优时间复杂度根据增量不同而不同

希尔排序是不稳定的

### 堆排序(heapsort)

之前提到过，二叉堆的建堆需要O(N)时间，然后再执行N次deleteMin操作，每次deleteMin操作为O(logN)，将这些元素记录到另一个数组然后再复制回来（二叉堆本来底层也是用数组实现的），复制用时O(N)，于是就得到了N个元素的排序，用时O(N+NlogN+N)，故**堆排序的时间复杂度为O(NlogN)**

用另外一个数组作为中间暂存，看上去挺费空间的，这可以改进，因为每次deleteMin之后，二叉堆的元素-1，需要进行下滤（percolate down），所以数组后部的某个位置就空出来了，可以把刚得到的min放入，这样就有效地利用了空间。

例如，设我们有个堆，它含有6个元素。第一次deleteMin产生个a1。现在该堆只有5个元素，因此可以把a1放在位置6上。下一次deleteMin产生个a2，由于该堆现在只有4个元素，因此把a2放在位置5上

![heapsort.png](http://ww1.sinaimg.cn/large/005GdKShly1g9zvn8j7h4j30m1096gmw.jpg)

#### 堆排序的实现

堆排序的实现代码如下，不需要额外空间，最大堆，得到非递减排序，注意这里与二叉堆有点不同，二叉堆的数组里的元素是从下标1开始的，而这里的元素是从下标0开始的

```c++
1 /**
2 * Standard heapsort.
3 */
4 template <typename Comparable>
5 void heapsort( vector<Comparable> & a )
6 {
7   for( int i = a.size( ) / 2 - 1; i >= 0; --i ) /* buildHeap */
8       percDown( a, i, a.size( ) );
9   for( int j = a.size( ) - 1; j > 0; --j )
10  {
11      std::swap( a[ 0 ], a[ j ] ); /* deleteMax */
12      percDown( a, 0, j );
13  }
14 }
15
16 /**
17 * Internal method for heapsort.
18 * i is the index of an item in the heap.
19 * Returns the index of the left child.
20 */
21 inline int leftChild( int i )
22 {
23  return 2 * i + 1;
24 }
25
26 /**
27 * Internal method for heapsort that is used in deleteMax and buildHeap.
28 * i is the position from which to percolate down.
29 * n is the logical size of the binary heap.
30 */
31 template <typename Comparable>
32 void percDown( vector<Comparable> & a, int i, int n )
33 {
34  int child;
35  Comparable tmp;
36
37  for( tmp = std::move( a[ i ] ); leftChild( i ) < n; i = child )
38  {
39      child = leftChild( i );
40      if( child != n - 1 && a[ child ] < a[ child + 1 ] )
41          ++child;
42      if( tmp < a[ child ] )
43          a[ i ] = std::move( a[ child ] );
44      else
45          break;
46  }
47  a[ i ] = std::move( tmp );
48 }
```

#### 堆排序的分析

经验指出，堆排序的性能极其稳定：平均它使用的比较只比最坏情形界指出的略少，**堆排序的时间复杂度为O(NlogN)**

### 归并排序(mergesort)

**归并排序的最坏运行时间跟堆排序一样，也是O(NlogN)**，而所使用的的比较次数几乎是最优的，它是递归算法的一个很好的实例

归并算法的基本操作是合并两个已排好序的数组，结果输出到第三个数组中，可以一趟排序完成，时间是O(N)，取两个数组A和B，以及三个计数器Actr，Bctr，Cctr，初始置于对应数组的头部，A[Actr]和B[Bctr]的较小者被复制到C中的下一个位置，相关计数器前进一步，当两个输入数组有一个用完时，把另一个数组剩余部分复制到C中，下图说明了这样的过程

![mergesort.png](http://ww1.sinaimg.cn/large/005GdKShly1g9zwo4e4ifj30ff0hsdgp.jpg)

因此，归并排序算法很容易描述。如果N=1，那么只有一个元素需要排序，答案是显然的。否则，递归地将前半部分数据和后半部分数据各自归并排序，得到排序后的两部分数据，然后使用上面描述的合并算法再将这两部分合并到一起。例如，欲将8元素数组24,13,26,1,2,27,38,15排序，我们递归地将前4个数据和后4个数据分别排序，得到1,13,24,26,2,15,27,38。然后，像上面那样将这两部分合并，得到最后的表1,2,13,15,24,26,27,38。该算法是经典的**分治(divide-and-conquer)**策略，它将问题**分(divide)**成一些小的问题然后递归求解，而**治(conquer)**的阶段则将分的阶段解得的各答案修补在一起。分治是递归非常有效的用法，我们将会多次遇到。

#### 归并排序的实现

如果对merge的每个递归调用均局部声明一个临时数组，那么在任一时刻就可能有logN个临时数组处在活动期。通过仔细思考，**由于merge是mergesort的最后一行，因此在任一时刻只需要一个临时数组在活动**，而且这个临时数组可以在public的mergeSort驱动程序中创建，而且我们可以使用该临时数组的任意部分，我们将使用与输入数组a相同的部分这是非常巧妙的，有效地节约了空间

```c++
1 /**
2 * Mergesort algorithm (driver).
3 */
4 template <typename Comparable>
5 void mergeSort( vector<Comparable> & a )
6 {
7   vector<Comparable> tmpArray( a.size( ) );
8
9   mergeSort( a, tmpArray, 0, a.size( ) - 1 );
10 }
11
12 /**
13 * Internal method that makes recursive calls.
14 * a is an array of Comparable items.
15 * tmpArray is an array to place the merged result.
16 * left is the left-most index of the subarray.
17 * right is the right-most index of the subarray.
18 */
19 template <typename Comparable>
20 void mergeSort( vector<Comparable> & a,
21 vector<Comparable> & tmpArray, int left, int right )
22 {
23  if( left < right )
24  {
25      int center = ( left + right ) / 2;
26      mergeSort( a, tmpArray, left, center );
27      mergeSort( a, tmpArray, center + 1, right );
28      merge( a, tmpArray, left, center + 1, right );
29  }
30 }
```

merge的实现如下

```c++
1 /**
2 * Internal method that merges two sorted halves of a subarray.
3 * a is an array of Comparable items.
4 * tmpArray is an array to place the merged result.
5 * leftPos is the left-most index of the subarray.
6 * rightPos is the index of the start of the second half.
7 * rightEnd is the right-most index of the subarray.
8 */
9 template <typename Comparable>
10 void merge( vector<Comparable> & a, vector<Comparable> & tmpArray,
11 int leftPos, int rightPos, int rightEnd )
12 {
13  int leftEnd = rightPos - 1;
14  int tmpPos = leftPos;
15  int numElements = rightEnd - leftPos + 1;
16
17  // Main loop
18  while( leftPos <= leftEnd && rightPos <= rightEnd )
19      if( a[ leftPos ] <= a[ rightPos ] )
20          tmpArray[ tmpPos++ ] = std::move( a[ leftPos++ ] );
21      else
22          tmpArray[ tmpPos++ ] = std::move( a[ rightPos++ ] );
23
24  while( leftPos <= leftEnd ) // Copy rest of first half
25      tmpArray[ tmpPos++ ] = std::move( a[ leftPos++ ] );
26
27  while( rightPos <= rightEnd ) // Copy rest of right half
28      tmpArray[ tmpPos++ ] = std::move( a[ rightPos++ ] );
29
30  // Copy tmpArray back
31  for( int i = 0; i < numElements; ++i, --rightEnd )
32      a[ rightEnd ] = std::move( tmpArray[ rightEnd ] );
33 }
```

#### 归并排序的分析

虽然归并排序的运行时间是O(NlogN)，但是它有一个明显的问题，即合并两个已排序的表用到线性附加内存。在整个算法中还要花费将数据复制到临时数组再复制回来这样一些附加的工作，它明显地减慢了排序的速度。这种复制可以通过在递归的那些交替层次上审慎地交换a和tmpArray的角色得以避免。归并排序也可以非递归地实现，暂时不讨论

与其他的O(NlogN)排序算法比较，归并排序的运行时间严重依赖于比较元素和在数组(以及临时数组)中移动元素的相对开销。这些开销是与语言相关的

例如，在Java中，当执行一次范型排序(使用 Comparator)时，进行一次元素比较可能是昂贵的(因为比较可能不容易内联( inlined)使用，从而动态调度的开销可能会减慢执行的速度)，但是移动元素则是省时的(因为它们是引用的赋值，而不是庞大对象的拷贝)。归并排序使用所有流行的排序算法中最少的比较次数，因此它是Java通用排序算法中的上好选择。事实上，**归并排序就是标准Java库中范型排序所使用的算法**。

另一方面，在传统C++的范型排序中，如果对象庞大，那么拷贝对象可能要昂贵，而由于编译器主动执行内联( inline)优化的能力，因此对象比较常常是相对省时的。在这种情形下，如果还能够使用少得多的数据移动，那么有理由让一个算法使用更多一些比较。我们将在下节讨论的快速排序达到了这种权衡，**快速排序是C++库中通常一直在使用的排序实现**。如今，新的C++11移动语义可能改变这种动态，于是剩下的就要看快速排序是否还将继续作为C++库中使用的排序算法了。

### 快速排序

顾名思义，对于C++，快速排序(quicksort)历史上一直是实践中已知最快的泛型排序算法，它的平均运行时间是O(NlogN)。该算法之所以特别快，主要是由于非常精练和高度优化的内部循环。它的最坏情形性能为O(N)，但经过稍许努力可使这种情形极难出现。通过将快速排序和堆排序结合，由于堆排序的最坏情形运行时间是O(NlogN)，因此可以对几乎所有的输入都能达到快速排序的快速运行时间。

像归并排序一样，快速排序也是种**分治的递归算法**。

现在我们描述快速排序最普通的实现—“经典快速排序”，此时的输入是一个数组，而且该算法并没有创建任何附加的数组，将数组S排序的经典快速排序算法由下列简单的4步组成:

1. 如果S中元素个数是0或1，则返回
2. 取S中任一元素ν，称之为枢纽元(pivot)
3. 将S-{}(即S中其余元素)划分成两个不相交的集合:S1={x∈S-{v}|x≤v}，S2={x∈S-{v}|x≥v}
4. 返回{quicksort(S1)，后跟v，继而再 quicksort(S2)}

第3步的分割(partition)可以有很多种方法，最好的方法是尽可能让这两个集合大致相等，这很像我们希望二叉查找树保持平衡的情形

快速排序比归并排序更快的原因关键在于：**在恰当位置上分割会使算法非常有效**，接下来就来讨论如何选择枢纽元

#### 选取枢纽元

虽然无论选择哪个元素作为枢纽元都能完成排序工作，但是有些选择是非常低效的

最常见的是把第一个元素作为枢纽元，如果输入是随机的，这样做还可以接受，但是如果输入是顺序或者反序的，这就将产生一个劣质的分割，所有元素不是划入S1就是划入S2，并且后续的递归也是这样，**这将产生O(N^2)的运行时间**

更安全的方法是随机选择枢纽元，这样大概率不会出现连续的劣质分割，但是生成随机数也是需要开销的，所以也不好

推荐的做法是**三数中值分割法(Median-of-Three Partition)**，一组N个数的中值(median)是第[N/2]（向上取整）个最大的数。枢纽元的最好的选择是数组的中值。遗憾的是，这很难算出且明显减慢快速排序的速度。该中值一个比较好的估计值可以通过随机选取三个元素并用它们的中值作为枢纽元而得到。事实上，随机性并没有太大的帮助，因此一般的做法是使用左端、右端和中心位置上的三个元素的中值作为枢纽元。例如，输入为
8,1,4,9,6,3,7,5,2,0,它的左端元素是8，右端元素是0，中心位置(left+ right)/2)上的元素是6。于是枢纽元则是ν=6。显然使用三数中值分割法消除了预排序输入的坏情形(在这种情形下，这些分割都是一样的)，并且实际减少了14%比较次数。

#### 分割策略

推荐做法：**第一步将枢纽元与最后的元素交换使得枢纽元离开要被分割的数据段，i从第一个元素开始而j从倒数第二个元素开始**。

如果原始输入与前面一样，那么下面的图表示当前的状态，当i在j的左边时，我们将i右移，移过那些小于枢纽元的元素，并将j左移，移过那些大于枢纽元的元素。当i和j停止时，i指向一个大元索而j指向一个小元素。如果i在j的左边，那么将这两个元素互换，其效果是把一个大元素推向右边而把一个小元素推向左边。在上面的例子中，i不移动，而j滑过一个位置。然后我们交换由i和j指向的元素，重复该过程直到1和j彼此交错为止。此时，i和已经交错，故不再交换。分割的最后一步是将枢纽元与主所指向的元素交换

![quicksort.png](http://ww1.sinaimg.cn/large/005GdKShly1ga04k1w85pj306n0bt0sy.jpg)

在最后一步当枢纽元与i所指向的元素交换时，我们知道在位置`p<i`的每一个元素都必然是小元素，这是因为或者位置p包含一个从它开始移动的小元素，或者位置p上原来的大元素在交换期间被置换了。类似的论断指出，在位置`p>i`上的元素必然都是大元素。

我们必须考虑的一个重要的细节是如何处理那些等于枢纽元的元素。问题在于当i遇到个等于枢纽元的元素时是否应该停止以及当j遇到一个等于枢纽元的元素时是否应该停止。直观地看，i和j应该做相同的工作，因为否则分割将出现偏向一方的倾向。例如，如果i停止而j不停，那么所有等于枢纽元的元素都将被分到S2中。

If neither i nor j stops, and code is present to prevent them from running off the end of the array, no swaps will be performed. Although this seems good, a correct implementation would then swap the pivot into the last spot that i touched, which would be the next-to-last position (or last, depending on the exact implementation). This would create very uneven subarrays. If all the elements are identical, the running time is O(N 2 ). The effect is the same as using the first element as a pivot for presorted input. It takes quadratic time to do nothing!

Thus, we find that it is better to do the unnecessary swaps and create even subarrays than to risk wildly uneven subarrays. Therefore, we will have both i and j stop if they encounter an element equal to the pivot. This turns out to be the only one of the four possibilities that does not take quadratic time for this input.

总之：**如果i和j遇到等于枢纽元的关键字，就让i和j都停止**

#### 小数组

对于很小的数组(N≤20)，快速排序不如插入排序好。不仅如此，因为快速排序是递归的，所以这样的情形还经常发生。通常的解决方法是对于小的数组不递归地使用快速排序，而代之以诸如插入排序这样的对小数组有效的排序算法。使用这种策略实际上可以节省大约15%(对于不用截止的做法而自始至终使用快速排序时)的运行时间。一种好的截止范围(cutoff range)是N=10，不过在5~20之间任一截止范围都有可能产生类似的结果。这种做
法也避免了一些有害的退化情形，比如当只有一个或两个元素时却取3个元素的中值这样的情况

#### 实际的快速排序

快速排序的驱动程序如下

```c++
1 /**
2 * Quicksort algorithm (driver).
3 */
4 template <typename Comparable>
5 void quicksort( vector<Comparable> & a )
6 {
7   quicksort( a, 0, a.size( ) - 1 );
8 }
```

在我们的实现中，快速排序函数的一般形式将是传递数组以及被排序数组的范围(1eft和 right)。要处理的第一个函数是枢纽元的选取。选取枢纽元最容易的方法是对a[1eft]、a[right]、a[center]适当地排序。这种方法还有额外的好处，即该三元素中的最小者被分在a[1eft]，而这正是
分割阶段应该将它放到的位置。三元素中的最大者被分在a[ right]，这也是正确的位置，因为它大于枢纽元。因此，我们可以把枢纽元放到a[ right-1]并在分割阶段将i和j初始化到1eft+1和 right-2。因为a[1eft]比枢纽元小，所以将它用作j的警戒标记，这是另一个好处。此时，我们不必担心j跑过端点。由于i将停在那些等于枢纽元的元素处，故将枢纽元存储在a[ right-1]则为主提供了一个警戒标记，下面提供了一个三数中值分割的实现代码

```c++
1 /**
2 * Return median of left, center, and right.
3 * Order these and hide the pivot.
4 */
5 template <typename Comparable>
6 const Comparable & median3( vector<Comparable> & a, int left, int right )
7 {
8   int center = ( left + right ) / 2;
9
10  if( a[ center ] < a[ left ] )
11      std::swap( a[ left ], a[ center ] );
12  if( a[ right ] < a[ left ] )
13      std::swap( a[ left ], a[ right ] );
14  if( a[ right ] < a[ center ] )
15      std::swap( a[ center ], a[ right ] );
16
17  // Place pivot at position right - 1
18  std::swap( a[ center ], a[ right - 1 ] );
19  return a[ right - 1 ];
20 }
```

接下来就是快速排序的核心代码，包括分割和递归调用，注意第16行将i和j初始化为比它们的正确值均越过1个位置，这样就需要考虑特殊情况

```c++
1 /**
2 * Internal quicksort method that makes recursive calls.
3 * Uses median-of-three partitioning and a cutoff of 10.
4 * a is an array of Comparable items.
5 * left is the left-most index of the subarray.
6 * right is the right-most index of the subarray.
7 */
8 template <typename Comparable>
9 void quicksort( vector<Comparable> & a, int left, int right )
10 {
11  if( left + 10 <= right )
12  {
13      const Comparable & pivot = median3( a, left, right );
14
15      // Begin partitioning
16      int i = left, j = right - 1;
17      for( ; ; )
18      {
19          while( a[ ++i ] < pivot ) { }
20          while( pivot < a[ --j ] ) { }
21          if( i < j )
22              std::swap( a[ i ], a[ j ] );
23          else
24          break;
25      }
26
27      std::swap( a[ i ], a[ right - 1 ] ); // Restore pivot
28
29      quicksort( a, left, i - 1 ); // Sort small elements
30      quicksort( a, i + 1, right ); // Sort large elements
31  }
32  else // Do an insertion sort on the subarray
33      insertionSort( a, left, right );
34 }
```

#### 快速排序的分析

最坏运行时间：O(N^2)
最好运行时间：θ(NlogN)
平均运行时间：O(NlogN)

#### 选择问题的线性期望时间算法

通过快速排序，我们可以解决**选择问题(selection problem)**，这个问题已经在第1章和第6章见到过，在第6章，通过优先队列（堆），可以通过时间O(N+klogN)找到第k个最大(最小)元，这里O(N)为建堆时间，k为k个元素，deleteMin/deleteMax耗时O(logN)。

对于查找中值的特殊情形，这里给出一个O(NlogN)算法，这种算法叫做**快速选择(quickselect)**，它与快速排序非常像，前3步是一样的，令|Si|为Si中元素的个数，算法步骤如下

1. 如果|S|=1，那么k=1并将S中的元素作为答案返回。如果正在使用小数组的截止( cutoff)方法且|S|≤CUTOFF，则将S排序并返回第k个最小元素。
2. 选取一个枢纽元v∈S。
3. 将集合S-{v}分割成S1和S2，就像我们在快速排序中所做的那样
4. 如果k≤|S1|，那么第k个最小元必然在S中。在这种情况下，返回 quickselect(S1,k)。如果k=1+|Si|，那么枢纽元就是第k个最小元，我们将它作为答案返回。否则，这第k个最小元就在S2中，它是S2中的第(k-|S1|-1)个最小元。我们进行一次递归调用并返回 quickselect(S2,k-|S1|-1)

与快速排序对比，快速选择只做一次递归调用而不是两次。快速选择的最坏情况和快速排序的相同，也是O(N^2)。直观看来，这是因为快速排序的最坏情况是在S1和S2有一个是空的时候的情况，于是，快速选择也就不是真的节省一次递归调用。不过，它的平均运行时间是O(N)。

快速选择的实现如下，当算法终止时，第k个最小元就在位置k-1上(因为数组开始于下标0)。算法破坏了数组原来的排序;如果不希望这样，那么必须要做一份拷贝。

```c++
1 /**
2 * Internal selection method that makes recursive calls.
3 * Uses median-of-three partitioning and a cutoff of 10.
4 * Places the kth smallest item in a[k-1].
5 * a is an array of Comparable items.
6 * left is the left-most index of the subarray.
7 * right is the right-most index of the subarray.
8 * k is the desired rank (1 is minimum) in the entire array.
9 */
10 template <typename Comparable>
11 void quickSelect( vector<Comparable> & a, int left, int right, int k )
12 {
13  if( left + 10 <= right )
14  {
15      const Comparable & pivot = median3( a, left, right );
16
17      // Begin partitioning
18      int i = left, j = right - 1;
19      for( ; ; )
20      {
21          while( a[ ++i ] < pivot ) { }
22          while( pivot < a[ --j ] ) { }
23          if( i < j )
24              std::swap( a[ i ], a[ j ] );
25          else
26              break;
27      }
28
29      std::swap( a[ i ], a[ right - 1 ] ); // Restore pivot
30
31      // Recurse; only this part changes
32      if( k <= i )
33          quickSelect( a, left, i - 1, k );
34      else if( k > i + 1 )
35          quickSelect( a, i + 1, right, k );
36  }
37  else // Do an insertion sort on the subarray
38      insertionSort( a, left, right );
39 }
```

使用三数中值选取枢纽元，可以使得最坏情形发生的几率很小很小

### 排序算法的一般下界

总结：**任何只用到比较的排序算法在最坏情形下都需要Ω(NlogN)次比较，从而需要Ω(NlogN)时间**

#### 决策树(decision tree)

决策树是一棵二叉树，每个节点代表在元素之间一组可能的排序，比较的结果是边

图7.20中的决策树表示将3个元素a,b和c排序的算法。算法的初始状态在根处。（我们将可互换地使用术语状态（state）和节点（node））。由于尚未进行比较，因此所有的顺序都是合法的。这个特定的算法进行的第一次比较是比较a和b。两种比较的结果导致两种可能的状态。如果`a<b`，那么只有3种可能性被保留。如果算法到达节点2，那么它将比较a和c。其他算法所做的工作可能会有所不同，不同的算法可能有不同的决策树。若`a>c`，则算法进入状态5.由于只存在一种相容的顺序，因此算法可以终止并报告它已经完成了排序。若`a<c`，则算法尚不能终止，因为存在两种可能的顺序，它还不能肯定哪种是正确的。在这种情况下，算法还将再需要一次比较。

![《数据结构与算法分析——C++语言描述》的笔记-decisiontree.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8A%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E4%B8%8E%E7%AE%97%E6%B3%95%E5%88%86%E6%9E%90%E2%80%94%E2%80%94C%2B%2B%E8%AF%AD%E8%A8%80%E6%8F%8F%E8%BF%B0%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-decisiontree.png)

只使用比较进行排序的每一种算法都可以用决策树表示。当然，只有输入数据非常少的情况画决策树才是可行的。排序算法所使用的比较次数等于最深的树叶的深度。在我们的例子中，该算法在最坏的情况下使用3次比较。所使用的比较的平均次数等于树叶的平均深度。由于决策树很大，因此必然存在一些长的路径。为了证明下界，所有需要证明的就是树的某些基本性质。

引理7.1：令T是深度为d的二叉树，则T最多有2^d片树叶

引理7.2：具有L片树叶的二叉树的深度至少是[logL]（向上取整）

定理7.6：只使用元素间比较的任何排序算法在最坏情况下至少需要[log(N!)]（向上取整）次比较

定理7.7：只使用元素间比较的任何排序算法均需要Ω(NlogN)次比较

### 选择问题的决策树下界

任何基于比较的排序算法必然使用大约O(logN)次比较。

1. 找出最小项需要N-1次比较。
2. 找出两个最小项需要[N+logN]（向上取整）-2次比较
3. 找出中位数（median）需要[3N/2]（向上取整）-O(logN)次比较

### 对手下界(adversary lower bound)

4.同时找出最小项和最大项需要[3N/2]（向上取整）-2次比较。

### 线性时间排序：桶排序(bucket sort)和基数排序(radix sort)

推荐文章：[三种线性排序算法 计数排序、桶排序与基数排序](https://www.byvoid.com/zhs/blog/sort-radix)，本节部分内容摘自该文章

本节要介绍的都是**非基于比较的排序**，如计数排序，桶排序，和在此基础上的基数排序，则可以突破 O(NlogN) 时间下限。但要注意的是，非基于比较的排序算法的使用都是有条件限制的，例如**元素的大小限制**，相反，基于比较的排序则没有这种限制 (在一定范围内)。但并非因为有条件限制就会使非基于比较的排序算法变得无用，对于特定场合有着特殊的性质数据，非基于比较的排序算法则能够非常巧妙地解决。

#### 计数排序

首先从计数排序 (Counting Sort) 开始介绍起，假设我们有一个待排序的整数序列 A，其中元素的最小值不小于 0，最大值不超过 K。**建立一个长度为 K 的线性表 C**，用来记录不大于每个值的元素的个数，还需要一个数组B，作为最后的排序输出。

算法思路如下：

1. 扫描序列 A，以 A 中的每个元素的值为索引，把出现的个数填入 C 中。此时 C [i] 可以表示 A 中值为 i 的元素的个数。
2. 对于 C 从头开始累加，使 C [i] = C [i] + C [i-1]。这样，C [i] 就表示 A 中值不大于 i 的元素的个数。
3. 反向填充目标数组B，从A的末尾开始把每个元素t放在目标数组的第C[t]项，每放一个元素就令C[t]-1，直至A反向遍历完成

图示如下：

![《数据结构与算法分析——C++语言描述》的笔记-coutingsort.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8A%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E4%B8%8E%E7%AE%97%E6%B3%95%E5%88%86%E6%9E%90%E2%80%94%E2%80%94C%2B%2B%E8%AF%AD%E8%A8%80%E6%8F%8F%E8%BF%B0%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-coutingsort.png)

显然地，计数排序的时间复杂度为 O (N+K)，K为待排序列中的最大值，空间复杂度为 O (N+K)。当 K 不是很大时，这是一个很有效的线性排序算法。更重要的是，它是一种稳定排序算法，即排序后的相同值的元素原有的相对位置不会发生改变 (表现在 Order 上)，这是计数排序很重要的一个性质，就是根据这个性质，我们才能把它应用到基数排序。

#### 桶排序

可能你会发现，计数排序似乎饶了点弯，比如当我们刚刚统计出 C，C [i] 可以表示 A 中值为 i 的元素的个数，此时我们直接顺序地扫描 C，就可以求出排序后的结果。的确是这样，不过这种方法不再是计数排序，而是**桶排序 (Bucket Sort)**，确切地说，是桶排序的一种特殊情况。

假设待排序列最大值不超过K，则桶排序使用一个大小为K的叫做count的数组，它被初始化为全0。于是，count有K个单元或称桶（bucket），初始时这些桶均为空。当读入A1时，count[A]+1。在所有的输入数据读入后，扫描桶count，输出排序后的数据，这种实现的方式**时间复杂度为 O (N+K)，空间复杂度也为 O (N+K)**，同样要求每个元素都要在 K 的范围内。

拓展思考：如果待排序列的最大值很大呢？无法开辟出O(K)的空间怎么办？

解答：这时桶数量肯定是有限的，**每个桶内放置一定范围内的元素**，首先定义桶，桶为一个数据容器，每个桶存储一个区间内的数。依然有一个待排序的整数序列 A，元素的最小值不小于 0，最大值不超过 K。假设我们有 M 个桶，第 i 个桶 Bucket [i] 存储 iK/M 至 (i+1)K/M 之间的数，有如下桶排序的一般方法：

1. 扫描序列 A，根据每个元素的值所属的区间，放入指定的桶中 (顺序放置)。
2. 对每个桶中的元素进行排序，什么排序算法都可以，例如快速排序。
3. 依次收集每个桶中的元素，顺序放置到输出序列中。

对该算法简单分析，如果数据是期望平均分布的，则每个桶中的元素平均个数为 N/M。如果对每个桶中的元素排序使用的算法是快速排序，每次排序的时间复杂度为 O (N/Mlog (N/M))。则总的时间复杂度为 O (N)+O (M)O(N/Mlog(N/M)) = O(N+ Nlog(N/M)) = O(N + NlogN - NlogM)。 当 M 接近于 N 是，桶排序的时间复杂度就可以近似认为是 O (N) 的。于是有结论：**桶越多，时间效率就越高，而桶越多，空间却就越大，由此可见时间和空间是一个矛盾**。

#### 基数排序

**基数排序（radix sort）**有时候也称为**卡片排序（card sort）**，因为在现代计算机出现之前它一直用于分类老式穿孔卡片。假设有10个在0~999范围内的数，我们想要对它们排序。显然不能用桶排序，那样的话桶就太多了，基数排序的诀窍在于使用几趟桶排序，趟数取决于最大数的位数，一般从最低有效为开始进行桶排序，一般来说，在第k趟排序后，各项按照第k最低有效位被排序

与计数排序和桶排序只研究一个关键字的排序相比，基数排序讨论了**多个关键字的排序问题**，假设我们有一些二元组 (a,b)，要对它们进行以 a 为首要关键字，b 的次要关键字的排序。我们可以先把它们先按照首要关键字排序，分成首要关键字相同的若干堆。然后，在按照次要关键值分别对每一堆进行单独排序。最后再把这些堆串连到一起，使首要关键字较小的一堆排在上面。按这种方式的基数排序称为 MSD(Most Significant Dight) 排序。第二种方式是从最低有效关键字开始排序，称为 LSD(Least Significant Dight) 排序。首先对所有的数据按照次要关键字排序，然后对所有的数据按照首要关键字排序。要注意的是，**使用的排序算法必须是稳定的，否则就会取消前一次排序的结果**，通常使用计数排序或者桶排序。由于不需要分堆对每堆单独排序，LSD 方法往往比 MSD 简单而开销小。所以一般用LSD方法。

下面的例子说明这一过程

```c++
INITIAL ITEMS:          064, 008, 216, 512, 027, 729, 000, 001, 343, 125
SORTED BY 1’s digit:    000, 001, 512, 343, 064, 125, 216, 027, 008, 729
SORTED BY 10’s digit:   000, 001, 008, 512, 216, 125, 027, 729, 343, 064
SORTED BY 100’s digit:  000, 001, 008, 027, 064, 125, 216, 343, 512, 729
```

基数排序算法的运行时间为O(p(N+b))，其中，p是排序进行的趟数，N是被排序的元素的个数，而b则为桶的个数。

基数排序的一个应用是字符串的排序。如果所有的字符串长度相同，均为L，那么通过对每个字符使用桶式排序，我们可以以O（NL）时间实现基数排序。进行这种排序最直接的方式如图7.25所示。在我们的程序中，假设所有的字符均为ASCII码，位于 Unicode字符集的前256个位置。在每一趟排序中，我们添加一项到相应的桶中，当所有的桶被填入相应的字符串之后，我们走遍各桶，将桶中内容全部倒回到数组中。注意，当一个桶被填入相应的项并在下一趟被清空时，当前趟的序是被保留的。

```c++
1 /*
2 * Radix sort an array of Strings
3 * Assume all are all ASCII
4 * Assume all have same length
5 */
6 void radixSortA( vector<string> & arr, int stringLen )
7 {
8   const int BUCKETS = 256;
9   vector<vector<string>> buckets( BUCKETS );
10
11  for( int pos = stringLen - 1; pos >= 0; --pos )
12  {
13      for( string & s : arr )
14          buckets[ s[ pos ] ].push_back( std::move( s ) );
15
16      int idx = 0;
17      for( auto & thisBucket : buckets )
18      {
19          for( string & s : thisBucket )
20              arr[ idx++ ] = std::move( s );
21
22          thisBucket.clear( );
23      }
24  }
25 }
```

#### 三种线性排序算法的比较

从整体上来说，计数排序，桶排序都是非基于比较的排序算法，而其时间复杂度依赖于数据的范围，桶排序还依赖于空间的开销和数据的分布。而基数排序是一种对多元组排序的有效方法，具体实现要用到计数排序或桶排序。

相对于快速排序等基于比较的排序算法，计数排序、桶排序和基数排序限制较多，不如快速排序、堆排序等算法灵活性好。但反过来讲，这三种线性排序算法之所以能够达到线性时间，是因为**充分利用了待排序数据的特性（如数据范围很小）**，如果生硬得使用快速排序、堆排序等算法，就相当于浪费了这些特性，因而达不到更高的效率。

在实际应用中，基数排序可以用于后缀数组的倍增算法，使时间复杂度从 O(NlogNlogN) 降到 O (N*logN)。线性排序算法使用最重要的是，充分利用数据特殊的性质，以达到最佳效果。

**计数基数排序（counting radix sort）**是基数排序的另一种实现，避免使用vector对象来表示桶，而是保留进入每一个桶有多少项的计数

### 外部排序（external sorting）

迄今为止，我们考查过的所有算法都需要将输入数据装入内存。然而，存在一些应用程序，它们的输入数据量太大装不进内存。本节将讨论一些外部排序算法（external sorting algorithm），它们是被设计用来处理数据量很大的输入的。

#### 简单算法（两路合并）

基本的外部排序算法使用归并排序中的**合并算法(merging)**。设我们有4盘磁带，Ta,Ta,Tb1,Tb2，它们是两盘输入磁带和两盘输出磁带。根据算法的特点，磁带a和磁带b或者用作输入磁带，或者用作输出磁带。设数据最初在Ta1上，并设内存可以一次容纳（和排序）M个记录。一种自然的第一步做法是从输入磁带一次读入M个记录，在内部将这些记录排序，然后再把这些排过序的记录交替地写到Tb1或T2上。我们将把每组排过序的记录叫作一个顺串（run）。做完这些之后，倒回所有的磁带。设我们的输入与希尔排序的例子中的输入数据相同

现在Tb1和Tb2包含一组顺串。我们将每个磁带的第一个顺串取出并将二者合并，把结果写到Ta1上，该结果是一个2倍长的顺串。注意，合并两个排过序的表是简单的操作，我们几乎不需要内存，因为合并是在Tb1和Tb2**前进时**进行的。然后，再从每盘磁带取出下一个顺串，合并，并将结果写到Ta上。继续这个过程，交替使用Ta和Ta，直到Tb1或Tb2为空。此时，或者Tb1和Tb2均为空，或者剩下一个顺串。对于后者，我们把剩下的顺串复制到适当的磁带上。将全部4盘磁带倒回，并重复相同的步骤，这一次用两盘a磁带作为输入，两盘b磁带作为输出，结果得到一些4M的顺串。我们继续这个过程直到得到长为N的一个顺串。

![《数据结构与算法分析——C++语言描述》的笔记-externalsortingsimplemerge.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8A%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E4%B8%8E%E7%AE%97%E6%B3%95%E5%88%86%E6%9E%90%E2%80%94%E2%80%94C%2B%2B%E8%AF%AD%E8%A8%80%E6%8F%8F%E8%BF%B0%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-externalsortingsimplemerge.png)

总结：该算法将需要[log(N/M)]（向上取整）趟进行合并

#### 多路合并

如果我们有额外的磁带，则可以减少将输入数据排序所需要的趟数，通过将基本的（2路）合并扩充为**k路合并（k-way merge）**就能做到这一点，**k路合并需要2k个磁盘**。两个顺串的合并操作通过将每一个输入磁带转到每个顺串的开头来进行。此时，找到较小的元素，把它放到输出磁带上，并将相应的输入磁带向前推进。我们可以通过使用一个**优先队列**找出这些元素中的最小元。为了得出下一个写到输出磁带上的元素，我们执行一次 deletemin操作。将相应的输入磁带向前推进，如果在输入磁带上的顺串尚未完成，则将新元素 insert到优先队列中。

![《数据结构与算法分析——C++语言描述》的笔记-three-waymerging.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8A%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E4%B8%8E%E7%AE%97%E6%B3%95%E5%88%86%E6%9E%90%E2%80%94%E2%80%94C%2B%2B%E8%AF%AD%E8%A8%80%E6%8F%8F%E8%BF%B0%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-three-waymerging.png)

在初始顺串构造阶段之后，使用k路合并所需要的趟数为[logk N/M]（向上取整），因为在每趟合并中顺串达到k倍大小。

#### 多相合并（Polyphase merge）

上一节讨论的k路合并方案需要使用2k盘磁带，这对某些应用极为不便。通过只使用k+1盘磁带也有可能完成排序的工作。作为例子，我们阐述只用3盘磁带如何完成2路合并。

设有3盘磁带T1、T2和T3，在T1上有一个输入文件，它将产生34个顺串。一种做法是在T2和T3的每一盘磁带中放入17个顺串。然后可以将结果合并到T1上，得到一盘有17个顺串的磁带。由于所有的顺串都在一盘磁带上，因此现在必须把其中的一些顺串放到T2上以进行另一次合并。执行该合并的逻辑方式是将前8个顺串从T1复制到T2然后进行合并。**这样的效果是对于我们所做的每一趟合并又附加了另外的半趟工作，因为要分割**。

另一种做法是把原始的34个顺串**不均衡地分成两份**。设我们把21个顺串放到T2上而把13个顺串放到T3上。然后，将13个顺串合并到T1上之后磁带T3就变成了空磁带。此时，可以倒回磁带T1和T3，然后将具有13个顺串的T1和8个顺串的T2合并到T3上。此时，我们合并8个顺串直到T2用完为止，这样，在T1上将留下5个顺串而在T3上则有8个顺串。然后，再合并T1和T3，以此类推。下面的图表显示在每趟合并之后每盘磁带上的顺串的个数

![《数据结构与算法分析——C++语言描述》的笔记-polyphasemerge.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8A%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E4%B8%8E%E7%AE%97%E6%B3%95%E5%88%86%E6%9E%90%E2%80%94%E2%80%94C%2B%2B%E8%AF%AD%E8%A8%80%E6%8F%8F%E8%BF%B0%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-polyphasemerge.png)

顺串最初的分配对于效率有很大影响。例如，若22个顺串放在T2上，12个在T1上，则第一趟合并后得到T3上12个顺串以及T2上的10个顺串。在下一次合并后，T1上有10个顺串而T3上有2个顺串。此时，进展的速度慢了下来，因为在T3用完之前我们只能合并两组顺串。这时T1有8个顺串而T2有两个顺串。同样，我们只能合并两组顺串，结果T1有6个顺串且T3有2个顺串。再经过3趟合并之后，T2还有2个顺串而其余磁带均已没有任何内容。我们必须将个顺串复制到另外一盘磁带上，然后结束合并。

事实上，我们给出的第一次分配是最优的。**如果顺串的个数是一个斐波那契数（Fibonacci number）FN，那么分配这些顺串最好的方式是把它们分裂成两个斐波那契数FN-1和FN-2。否则，为了将顺串

#### 替换选择（Replacement Selection）

最后我们将要考虑的是顺串的构造。迄今已经用到的策略是所谓的最简可能（the simplepossible）：读入尽可能多的记录并将它们排序，再把结果写到某个磁带上。这看起来像是可能的最佳处理，可是，**只要第一个记录被写到输出磁带上，它所使用的内存就可以被另外的记录使用**。如果输入磁带上的下一个记录比我们刚刚输出的记录大，那么它就可以被放入顺串中。

利用这种想法，我们可以给出产生顺串的一个算法，该方法通常称为**替换选择（replacement selection）**。开始时，M个记录被读入内存并被放到一个优先队列中。我们执行次 deleteMin，把最小（值）的记录写到输出磁带上，再从输入磁带读入下一个记录。如果它比刚刚写出的记录大，那么可以把它添加到优先队列中，否则，它不能进入当前的顺串。由于优先队列少一个元素，因此，可以把这个新元素存入优先队列的**死区（dead space）**，直到顺串完成构建，而用这个元素作为下一个顺串的成员。将一个元素存入死区的做法类似于在堆排序中的做法（为了节省空间）。我们继续这样的步骤直到优先队列的大小为零，此时该顺串已经用完。我们使用死区中的所有元素通过建立一个新的优先队列开始构建一个新的顺串。图7.28解释了我们一直在使用的这个小例子的顺串构建过程，其中M=3.死元素以星号标示。

![《数据结构与算法分析——C++语言描述》的笔记-runconstruction.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8A%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E4%B8%8E%E7%AE%97%E6%B3%95%E5%88%86%E6%9E%90%E2%80%94%E2%80%94C%2B%2B%E8%AF%AD%E8%A8%80%E6%8F%8F%E8%BF%B0%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-runconstruction.png)

## 小结

排序是计算技术中最古老和得到充分研究的问题之一。对于最一般的内部排序应用，插入排序、希尔排序、归并排序或快速排序是经常选用的方法。究竟使用哪个方法依赖于输入的大小和底层的环境。

- 插入排序适用于非常少量的输入，所以当序列基本有序或者n较小时，插入排序是好方法，因此经常把插入排序与其他排序方法，如快速排序结合在一起使用。
- 对于适量输入的排序，希尔排序是上佳选择，对于适当的增量序列，它表现出极好的性能且只有几行的代码。
- 归并排序具有O(Nlog)最坏情形性能，但是需要额外的空间。然而，其所使用的**比较次数几乎是最优的**，因为任何只使用元素比较的排序算法必然至少要用到对输入序列的[log(N!)]（向上比较）次比较。
- 快速排序本身并不提供这种最坏情形的性能保证，但算法的编码非常巧妙。然而，它具有几乎是必然的O(NlogN)性能，并且能够与堆排序结合而给出O(NlogN)的最坏情形性能保证（为啥与堆排序结合？）。
- 基数排序提供了**多个关键字的比较**，字符串可以通过使用基数排序而以线性时间完成排序，对在一些实例中基于比较的排序方案这可能是一种实用性的选择

一般在面试中最常考的是快速排序和归并排序，甚至需要现场手写

所有时间复杂度为 O (n^2) 的简单排序也是稳定的。但是快速排序、堆排序、希尔排序等时间性能较好的排序方法都是不稳定的。稳定性需要根据具体需求选择。

![《数据结构与算法分析——C++语言描述》的笔记-sortingconclusion.png](https://raw.githubusercontent.com/edisonleolhl/PicBed/master/%E3%80%8A%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E4%B8%8E%E7%AE%97%E6%B3%95%E5%88%86%E6%9E%90%E2%80%94%E2%80%94C%2B%2B%E8%AF%AD%E8%A8%80%E6%8F%8F%E8%BF%B0%E3%80%8B%E7%9A%84%E7%AC%94%E8%AE%B0-sortingconclusion.png)