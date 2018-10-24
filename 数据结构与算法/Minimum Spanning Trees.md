# 最小生成树

本文大部分笔记来自于MIT公开课的笔记，教材为Introduction to Algorithm(Third Edition)，根据四位作者姓名首字母大写常称作CLRS，以下是一些资源：

- MIT OCW COURSE HOME: https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-046j-introduction-to-algorithms-sma-5503-fall-2005/index.htm
- MIT OCW video: https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-046j-introduction-to-algorithms-sma-5503-fall-2005/video-lectures
- ppt: download links are just under the video frame
- khan academy: https://www.khanacademy.org/computing/computer-science/algorithms （brief and easy）
- book: Introduction to Algorithms ( known as CLRS)
- official exercises solution to CLRS: http://mitp-content-server.mit.edu:18180/books/content/sectbyfn?collid=books_pres_0&fn=Intro_to_Algo_Selected_Solutions.pdf&id=8030
- inofficial exercises solution to CLRS(github): https://github.com/gzc/CLRS

## 图的表示

- Definition.
  - A directed graph (digraph)G= (V, E)is an ordered pair consisting of
    •a set V of vertices(singular: vertex),
    •a set E⊆V×Vof edges.
  - In an undirected graph G= (V, E),the edge set E consists of unordered pairs of vertices.
  - In either case, we have |E|= O(V^2). Moreover, if G is connected, then |E|≥|V|–1, which implies that lg|E|= Θ(lgV).
- 稠密（dense）图：边的数量 远大于 顶点数量的平方 |E| >> |V|^2
- 稀疏（sparse）图：边的数量 接近于 顶点数量的平方
- 邻接（adjacent）列表：稀疏图一般用列表（list）形式表示

  - An adjacency list of a vertex v∈V is the list Adj[v] of vertices adjacent to v
  - For undirected graphs, |Adj[v]| = degree(v).
    For digraphs, |Adj[v]| = out-degree(v).
  - 缺点：查询某条边(u, v)是否存在于图G中，必须在列表Adj[u]中查找是否存在v，时间上较慢
- 邻接矩阵：稠密图一般用矩阵（matrix）形式表示
  - The adjacency matrix of a graph G = (V, E), where V = {1, 2, …, n}, is the matrix A[1 . . n, 1 . . n] given by A[i, j] =
    1 if (i, j) ∈ E,
    0 if (i, j) ∉ E.
  - 缺点：对于n个顶点的图G，需要n^2的空间，比列表要多，但是查询起来比列表快
- Handshaking Lemma: ∑v∈V = 2|E| for undirected graphs 
  - 因为对于无向图，每条边使两个顶点关联
- 树（Tree）
  - **树**（英语：Tree）是一种[无向图](https://zh.wikipedia.org/wiki/%E7%84%A1%E5%90%91%E5%9C%96)（undirected graph），其中任意两个[顶点](https://zh.wikipedia.org/wiki/%E9%A1%B6%E7%82%B9_(%E5%9B%BE%E8%AE%BA))间存在唯一一条[路径](https://zh.wikipedia.org/wiki/%E8%B7%AF%E5%BE%84_(%E5%9B%BE%E8%AE%BA))。或者说，只要没有[回路](https://zh.wikipedia.org/w/index.php?title=%E5%9B%9E%E8%B7%AF_(%E5%9B%BE%E8%AE%BA)&action=edit&redlink=1)的[连通图](https://zh.wikipedia.org/wiki/%E8%BF%9E%E9%80%9A%E5%9B%BE)就是树
  - 树图广泛应用于[计算机科学](https://zh.wikipedia.org/wiki/%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%A7%91%E5%AD%A6)的[数据结构](https://zh.wikipedia.org/wiki/%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84)中，比如[二叉查找树](https://zh.wikipedia.org/wiki/%E4%BA%8C%E5%8F%89%E6%9F%A5%E6%89%BE%E6%A0%91)，[堆](https://zh.wikipedia.org/wiki/%E5%A0%86_(%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84))，[Trie树](https://zh.wikipedia.org/wiki/Trie)以及[数据压缩](https://zh.wikipedia.org/wiki/%E6%95%B0%E6%8D%AE%E5%8E%8B%E7%BC%A9)中的[霍夫曼树](https://zh.wikipedia.org/wiki/%E9%9C%8D%E5%A4%AB%E6%9B%BC%E7%BC%96%E7%A0%81)等等。

## 最小生成树（Minimum Spanning Trees）

- Input: A connected, undirected graph G= (V, E) with weight function w: E→R.

  -  For simplicity, assume that all edge weights are distinct. 

- Output: A spanning tree T — a tree that connects all vertices — of minimum weight: 

  w(T) = ∑w(u,v)

  ![Example of MST](http://ooy7h5h7x.bkt.clouddn.com/blog/181023/a8liKa6IJ0.png?imageslim)

### 预备知识

- 通过贪婪算法可以得到求最小生成树的一般方法（generic MST method）

- generic MST method维持了一个树A，A从一个顶点开始，直到长成MST，generic MST method每次会使A生长一条边，但会保持一个不变量：每次生长后得到的树A肯定是MST的一部分（***invariant Property***），把满足不变量条件的生长的这条边称为A的一条安全的边（***safe edge***）

- 割（cut）与割集（cut-set）[Wikipedia](https://en.wikipedia.org/wiki/Cut_(graph_theory))：

  - A **cut** ![C=(S,T)](https://wikimedia.org/api/rest_v1/media/math/render/svg/39f463f6fea5189e2f05b24e0d5d34f50ffb869e) is a partition of  of a graph  into two subsets *S* and *T*. 
  - The **cut-set** of a cut  is the set ![{\displaystyle \{(u,v)\in E\mid u\in S,v\in T\}}](https://wikimedia.org/api/rest_v1/media/math/render/svg/aeedca7e7de51a614040312156966062fdbed5f0) of edges that have one endpoint in *S* and the other endpoint in *T*. 
  - If *s* and *t* are specified vertices of the graph *G*, then an **s–t cut** is a cut in which *s* belongs to the set *S* and *t* belongs to the set *T*.

  - In an unweighted undirected graph, the *size* or *weight* of a cut is the number of edges crossing the cut. In a [weighted graph](https://en.wikipedia.org/wiki/Graph_(discrete_mathematics)#Weighted_graph), the **value** or **weight** is defined by the sum of the weights of the edges crossing the cut.

  - Minimum cut：A cut is *minimum* if the size or weight of the cut is not larger than the size of any other cut.

    ![img](https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Min-cut.svg/220px-Min-cut.svg.png)

  - Maximum cut：A cut is *maximum* if the size of the cut is not smaller than the size of any other cut. 、

    ![img](https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Max-cut.svg/220px-Max-cut.svg.png)

- We say a cut ***respects*** a set A of edges if no edge in A crosses the cut.

- An edge ***crosses*** the cut (S,V-S) if one of its endpoints is in S and the other is in V-S.

- An edge is a ***light edge*** crossing a cut if its weight is the minimum of any edge crossing the cut.

>  Bottleneck spanning tree:  
>
>  ​	A spanning tree of G whose largest edge weight is minimum over all spanning trees of G. The value of the bottleneck spanning tree is the weight of the maximum-weight edge in T.
>
>  Theorem:         
>
>  ​	A minimum spanning tree is also a bottleneck spanning tree. (Challenge problem)

### 最佳子结构（Optimal Substructure）

- Given MST T: Remove any edge (u, v) ∈T. . Then, Tis partitioned into two subtrees T1 and T2.

- Theorem: The subtree T1 is an MST of G1= (V1, E1), and G1 is the subgraph of G induced by the vertices of T1:

  V1=vertices of T1,

  E1= {(x, y) ∈E: x, y∈V1}.

- Proof: Cut and paste:

  w(T) = w(u, v) + w(T1) + w(T2).

  If T1′ were a lower-weight spanning tree than T1 for G1, then T′= {(u, v)} ∪T1′∪T2 would be a lower-weight spanning tree than T for G, WHICH WILL VIOLATE '*T IS A MST*'.

- 这也具有overlapping subproblems的性质，把最小生成树切成两个子树，他们都具有最小生成树的性质，问题可以转化为求解子树的最小生成树，可以使用动态规划（Dynamic Programming）求解

### Hallmark for “greedy” algorithms

![Greedy-choice property](http://ooy7h5h7x.bkt.clouddn.com/blog/181023/e4DF8C6FcB.png?imageslim)

![Proof](http://ooy7h5h7x.bkt.clouddn.com/blog/181023/lie9ALI49i.png?imageslim)

- ***Greedy-choice property***： A locally optimal choice is globally optimal.
- Theorem: Let T be the MST of G= (V, E), and let A⊆V. Suppose that(u, v) ∈E is the least-weight edge connecting A to V–A. Then, (u, v) ∈T.
- **Prim's algorithm and Kruskal's algorithm are greedy algorithms!**

### 普利姆算法（Prim’s algorithm）

- IDEA:Maintain V –A as a priority queue Q. Key each vertex in Q with the weight of the least-weight edge connecting it to a vertex in A.

- pseudocode:

  ```
  Q←V
  key[v] ← ∞ for all v∈V
  key[s] ← 0 for some arbitrary s∈V
  while Q ≠ ∅
    do u ← EXTRACT-MIN(Q)
    	for each v ∈ Adj[u]
    		do if v ∈ Q and w(u, v) < key[v]
    			then key[v] ← w(u, v)      // DECREASE-KEY
    				π[v] ← u
  
  ```

  ​	

- example:

  ![Example of Prim's algorithm](http://ooy7h5h7x.bkt.clouddn.com/blog/181023/3bDC7AIh0H.png?imageslim)

- 理解：

  - 把顶点集合V分为两部分，A和V-A，V-A是一个优先队列Q，初始时把V赋值给Q，每个顶点维持一个key值，用来在DECREASE-KEY时进行比较，初始时除了某特定点为0，其余全为∞
  - 每次根据key值从Q中取出一个最小值u（显然，第一次是从key=0的特定点开始的），根据u的邻接边decrease u的邻接点的key值，并且用方向映射（π）记录decrease operation
  - 继续根据key值从Q中取出一个最小值，操作同上，直到Q为空，算法结束

- Analysis:

  ![Analysis of Prim](http://ooy7h5h7x.bkt.clouddn.com/blog/181023/be1IfCiLhB.png?imageslim)

  - 每个顶点都要从Q中Extract出来，所以是O(V) * Time of Extract_Min

  - 对于邻接列表，边的总数是2|E|，故for循环需要执行O(E)次，DECREASE-KEY operation在for循环中，所以是O(E) * Time of DECREASE-KEY

  - 于是总时间 Time=O(V) * Time of Extract_min + O(E) * Time of DECREASE-KEY

  ![Time Analysis of Prim](http://ooy7h5h7x.bkt.clouddn.com/blog/181023/8ADaFJJ458.png?imageslim)
  - 对于binary min-heap，可以使用BUILD-MIN-HEAP procedure进行初始化操作，用时O(V)，while循环|V|次，而Extract-Min的时间仅需要O(lgV)，所以Extract-Min的总调用时间为O(VlgV)，DECREASE-KEY的时间也仅需要O(lgV)，所以DECREASE-KEY的总调用时间为O(ElgV)，于是Time=O(VlgV)+O(ElgV)=O(ElgV)

  - 对于Fibonacci heap，Extract-Min的平摊时间为O(lgV)，而实现DECREASE-KEY仅需要O(1)的平摊时间
  - 总结：使用binary heap可以改进Prim's algorithm的时间复杂度到O(ElgV)，而使用Fibonacci heap可以改进到O(E+VlgV)，这对于E>>V的图而言，大有改进

### 克鲁斯克尔算法（Kruskal's Algorithm）

- IDEA: 
  - Kruskal's algorithm finds a ***safe edge*** to add to the growing ***forest*** by finding, of all the edges that connect any two trees in the forest, an edge(u, v) of least weight. 
  - It uses a ***disjoint-set*** data structure to maintain several disjoint sets of elements. Each set contains the ***vertices in one tree*** of the current forest.
  - FIND_SET(u) returns a particular set which contains u. Thus, we can determine whether two vertices u and v belong to the ***same*** tree by testing whether FIND_SET(u) ***equals*** FIND_SET(v).
  - The ***combining*** of trees is accomplished by the ***UNION*** procedure.

- pseudocode:

  ```
  MST_KRUSKAL(G,w)
  A:={}
  for each vertex v in V[G]
  	do MAKE_SET(v)
  sort the edges of E by nondecreasing weight w
  for each edge (u,v) in E,taken in nondecreasing order
  	do if FIND_SET(u) != FIND_SET(v)7			
  		then	A:=A∪{(u,v)}
  			UNION(u,v)
  return A
  ```

- analysis:

  - Running time depends on how to ***implement*** the disjoint-set data structure. Assume union-by-rank and path-compression heuristics, since it is the ***fastest*** implementation known.
  - In brief, running time of Kruskal's algorithm is O(ElgV).

### Comparison of Prim and Kruskal

- The two algorithms are elaborations of the generic algorithm.
- They each use a specific rule to determine ***a safe edge***.
- In Kruskal's algorithm, 
  - The set A is a ***forest***.
  - The safe edge added to A is always a least-weight edge in the graph that connects ***two distinct components***.
- In Prim's algorithm, 
  - The set A forms a single ***tree***.
  - The safe edge added to A is always a least-weight edge connecting the tree to ***a vertex not in the tree***.

### CSLR Exercises: 

- 23.1-7

  - Argue that if all edge weights of a graph are positive, then any subset of edges that connects all vertices and has minimum total weight must be a tree. Give an example to show that the same conclusion does not follow if we allow some weights to be nonpositive.

  - Solution:

    假设边的子集 T 中存在环, 则某两点之间存在多条通路, 移除其中一条通路, 子集 A' 仍然连通所有点. 因为边的权重为正, 既 w(A') < w(A), 结论与条件矛盾, 所以 T 是树.

    如果边的权重为负，那么对于一个环形结构，把所有的顶点依次连接起来，总权重最小，但不是一个最小生成树（树不能有环）

- 23.1-8

  - Let T be a minimum spanning tree of a graph G, and let L be the sorted list of the edge weights of T. Show that for any other minimum spanning tree T′ of G, the list L is also the sorted list of edge weights of T′.

  - [First Solution](https://walkccc.github.io/CLRS/Chap23/23.1/#231-8):

    设L'是T'的排序列表，用反证法证明L=L'，首先假设L'≠L。

    因为L'≠L，所以在T或T'中一定存在一条边(u, v)，它要小于另一个集合的对应边。不失一般性，假设这个边(u, v)在T中，它小于T'中的对应边。

    令C=T'∪(u, v)，可知C一定是一个带环的图，在这个环中如果有某边大于(u, v)，则可以移除这条边得到树C'，这样C'就是一个最小生成树，而且其权重还小于T'，这会与T'是最小生成树矛盾所以，环中的每条边都必须≤(u, v)。

    继续用反证法，假设每条边都是严格小于的，在T中移除(u, v)可得到两个子图，在环中一定存在除了(u, v)之外的某边连接这两个子图，又由于这条边是严格小于(u, v)的，我们可以用它来构造比T权重更小的最小生成树，矛盾，所以不是每条边都严格小于(u, v)的。

    *所以，环中一定存在某边=(u, v)，用(u, v)代替那条边，对应的列表L和L'会保持不变，但是T和T'的共同边数目会增加1。*

    *如果我们继续这种操作，最终T和T'会完全相等，L'=L，这与假设矛盾，于是得证。*

    > 原文中的斜体字部分看不懂，待研究这个解法的正确性

  - [Second Solution](http://www.math.purdue.edu/~sbasu/teaching/fall06/cs3510/sol3.pdf)：

    假设最小生成树有 n 条边, 存在两个最小生成树 T 和 T', 用 w(e) 表示边的权值. T 权值递增排列 w(a1) <= w(a2) <= ... w(an) T' 权值递增排列 w(b1) <= w(b2) <= ... w(bn) 假设 i 是两个列表中, 第一次出现边不同的位置, 既 ai ≠ bi, 先假定 w(ai) >= w(bi).

    情况1, 如果 T 中含有边 bi, 由于 ai 和 bi 在列表 i 位置之前都是相同的, 若含有 bi 则一定在 i 位置后, 既有 j > i 使得 w(aj) = w(bi). 得到 w(bi) = w(aj) >= w(ai) >= w(bi), 既 w(bi) = w(aj) = w(ai), 故 i 位置处边的权值相同.

    情况2, 如果 T 不包含边 bi, 则把 bi 加到 T 中, 会在某处形成一个圈. 由于 T 是最小生成树, 圈内任何一条边的权值都小于等于 w(bi), 另外这个圈中必定存在 aj 不在 T' 中, 得出 w(aj) <= w(bi) 且 j > i. 因此 w(bi) <= w(ai) <= w(aj) <= w(bi), 既 w(bi) = w(aj) = w(ai), 故 i 位置处边的权值仍相同.

    > 这种解法更让人摸不着头脑。。

  - [Third Solution](http://www.math.purdue.edu/~sbasu/teaching/fall06/cs3510/sol3.pdf)：

    L和L'从小到大排列，令k为L和L'第一次产生不同的位数，不失一般性，令L[k]<L'[k]。

    现在考虑前k-1个相同权重的边，在T'中会形成森林F'，把T中前k条边的任意一个加入到F'，可能会形成环，当且仅当这条边的两个顶点在F'的同一个子图中。

    同样地，F'的一个m条边的子图最多有m条T中的k条边，不然T中就有环。但是F'总共只有k-1条边，所以它最多占T的k-1条边。所以，**在T的前k条边中，一定存在至少一条边，当它加入到F'时不会形成环，这条边设为e**。

    把这条边e加入到T'，会形成环，而且进一步地，这个环中的有些边不在F'中，于是它们的权重大于等于L'[k]。

    但是e严格小于L'[k]，所以我们可以移除比e更大的边，从而减小T'的权重，这与T'是最小生成树矛盾！

    > 这个解法看起来很高级，但是没看懂。。

  - My Solution：

    如果图G是无环的，那么MST唯一，T=T'，所有L=L'，所以现在仅考虑图G有环的情况。

    对图进行切割（cut），要求切割后图G被分为两个子图G1和G2，对于同为MST的T和T'，它们必须选择这个切割对应割集中的一条边来连接G1和G2。根据MST的定义，有以下两种情况：

    ​	1. 若两条边权重不相等，则T和T'选择较小权重的那条边；

    ​	2. 若两条边权重相等，则T和T'随即选择其中一条边。

    根据以上知识，对于MST的生成，有以下两种对立的情况：

    ​	1. 对于所有的这种切割，若两条边权重都不相等，那么T和T'每次都会做出相同的选择，最后T=T'。

    ​	2. 对于所有的这种切割，若两条边权重不都相等，即存在两条边权重相等的情况，T和T'会随机选择其中一条，那么最后T≠T'。

    综上，构成T和T'的边集合中，要么是相同的边，要么是权重相同的边。所以，按照T和T'的边集合的权重排序，L=L'。

- 23.1-11 *

  - Given a graph G and a minimum spanning tree T , suppose that we decrease the weight of one of the edges not in T . Give an algorithm for finding the minimum spanning tree in the modified graph.

  - Solution：

    假设 (u, v) 不在最小生成树 T 中, 减小 (u, v) 权值后, 形成新的最小生成树 T'. 可能的情况是 T' =T - 某边 +  (u, v)， 或者 T' = T 保持不变。

    在T中寻找 u -> v 的路径path，可用 BFS/DFS 算法求得, 从 u 开始 v 结束. 因为 T 是最小生成树, 所以路径唯一, 时间 O(V+E)。

    若path中有某条边大于(u, v)，则去除这条边、加入(u, v)形成T'。

    若path中所有边均小于等于(u, v)，则T=T'。

### CSLR Problems: 23-4 Alternative minimum-spanning-tree algorithms

In this problem, we give pseudocode for three different algorithms. Each one takes a connected graph and a weight function as input and returns a set of edges T. For each algorithm, either prove that T is a minimum spanning tree or prove that T is not a minimum spanning tree. Also describe the most efficient implementation of each algorithm, whether or not it computes a minimum spanning tree.

- a

  ```
  MAYBE-MST-A(G, w)
      sort the edges into nonincreasing order of edge weights w
      T = E
      for each edge e, taken in nonincreasing order by weight
          if T - {e} is a connected graph
              T = T - {e}
      return T
  ```

- b

  ```
  MAYBE-MST-B(G, w)
      T = Ø
      for each edge e, taken in arbitrary order
          if T ∪ {e} has no cycles
              T = T ∪ {e}
      return T
  ```

- c

  ```
  MAYBE-MST-C(G, w)
      T = Ø
      for each edge e, taken in arbitrary order
          T = T ∪ {e}
          if T has a cycle c
              let e' be a maximum-weight edge on c
              T = T - {e}
      return T
  ```

Solution:

- a
  能正确计算出MST，在T每次缩减的过程中，总是保持连通的，并且减掉的边是nonincreasing order的，最后得到的tree一定是MST。

  对边进行排序需要O(ElgE)，对于每条边都得检查T-e是否是连通的，所以可以用DFS，每次检查耗时O(V+E)，那么总共检查需要O(E(V+E))，于是总时间为O(E^2)。

  **个人理解：这个算法其实就是Kruskal's algorithm的逆版本！**

- b

  不能正确计算出MST，随便找个反例即可。

- c

  能正确计算出MST，对于图G，生成树必须通过某个特定边才能连通两个子图，这种边可以称作桥（bridge），而有时不止一个边可以连通两个子图，这时就会出现环（cycle）。

  对于c算法而言，每当出现环时，删除环中最大权重的边，这样可以保证T在生长过程中一定是tree，并且当所有的边都考虑了一遍后，最后生成的一定是MST。