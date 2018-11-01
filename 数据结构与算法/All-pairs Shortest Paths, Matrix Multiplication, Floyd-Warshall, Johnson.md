## Recall Shortest paths

- Single-source shortest paths

  - Unweighted

    BFS: O(V+E)

  - Nonnegative edge weights

    Dijkstra’s algorithm: O(E + V lg V)

  - General

    Bellman-Ford: O(VE)

  - DAG
    One pass of Bellman-Ford: O(V + E)

- All-pairs shortest paths

  - Nonnegative edge weights

    Dijkstra's algorithm |V| times: O(VE+V^2lgV)

  - General

    Bellman-Ford |V| times: O(V^2E)

  **AND Three algorithms in this note**

## All-pairs shortest paths

- Input: Digraph G = (V, E), where V = {1, 2, …, n}, with edge-weight function w : E → R.
- Output: n × n matrix of shortest-path lengths δ(i, j) for all i, j ∈ V.

> The tabular output of the all-pairs shortest-paths algorithms presented in this chapter is an n×n matrix D = d(ij), where entry d(ij) contains the weight of a shortest path from vertex i to vertex j. 
>
> That is, if we let δ(i,j) denote the shortest-path weight from vertex i to vertex j (as in Chapter 24), then d(ij) = δ(i,j) at termination.

### First Try

- Run Bellman-Ford algorithm one from each vertices

- Time: O(V^2E)

- If dense graph(eg:e=n^2), time: O(n^4) in the worst case

### Dynamic Programming

Recap the steps of DP:

1. Characterize the structure of an optimal solution.
2. Recursively define the value of an optimal solution.
3. Compute the value of an optimal solution in a bottom-up fashion.

![Dynamic Programming](http://ooy7h5h7x.bkt.clouddn.com/blog/181030/2keecg2kK7.png?imageslim)

![Proof of claim](http://ooy7h5h7x.bkt.clouddn.com/blog/181030/l31Hilf1kg.png?imageslim)

- A path from vertex i to vertex j with more than n - 1 edges cannot have lower weight than a shortest path from i to j. The actual shortest-path weights are therefore given by: 

  δ(i, j) = dij^(n-1) = dij^(n) = dij^(n+1) =  ...

- Using Dynamic Programming, we can compute a ***series*** of matrices L^(1), L^(2), ..., L^(n-1). The final matrix L^(n-1) contains the actual shortest-path weights.（教材和notes中对于矩阵的命名是不一样的，一个是L，一个是D）

- Running time: O(V^4)

  No better than |V| tims Bellman-Ford algorithm O(V^4) in worst case.

### Matrix Multiplication

![Matrix Multiplication](http://ooy7h5h7x.bkt.clouddn.com/blog/181030/m12hJ6hA7J.png?imageslim)

![mark](http://ooy7h5h7x.bkt.clouddn.com/blog/181030/i8D6EAcGCE.png?imageslim)

![Repeated squaring](http://ooy7h5h7x.bkt.clouddn.com/blog/181030/BAImI5BKbf.png?imageslim)

> 扩展阅读：
>
> [Lecture 12: Chain Matrix Multiplication](https://home.cse.ust.hk/~dekai/271/notes/L12/L12.pdf)

### Floyd-Warshall algorithm

> 算法导论的推导很难理解，于是复习了一下以前的笔记和上网查找了一下资料

- Floyd-Warshall算法的原理是[动态规划](https://zh.wikipedia.org/wiki/%E5%8A%A8%E6%80%81%E8%A7%84%E5%88%92)[[4\]](https://zh.wikipedia.org/wiki/Floyd-Warshall%E7%AE%97%E6%B3%95#cite_note-4)。

- 设D{i,j,k}为从i到j的只以(1..k)集合中的节点为中间节点的最短路径的长度。
  - 若最短路径经过点k，则D_{i,j,k}  = D_{i,k,k-1}+D_{k,j,k-1}；

  - 若最短路径不经过点k，则D_{i,j,k} = D_{i,j,k-1}。

- 因此，D_{i,j,k}=min(D_{i,j,k-1}, D_{i,k,k-1}+D_{k,j,k-1})。

- 在实际算法中，为了节约空间，可以直接在原来空间上进行迭代，这样空间可降至二维。

![Floyd-Warshall algorithm](http://ph166fnv2.bkt.clouddn.com/blog/181031/FKB12C5l5E.png?imageslim)

![Pseudocode for Floyd-
Warshall](http://ph166fnv2.bkt.clouddn.com/blog/181031/4afLkjDhdi.png?imageslim)

### Johnson's algorithm

- 思考过程：

  - Dijkstra不能处理有负权重边的情况

  - Bellman-Ford可以处理有负权重边的情况，并且可以检测图是否含有负权重环

  - Johnson先构造一个虚拟的s，用权重为0的边连接s和原图G的各顶点

    用Bellman-Ford计算每个顶点的𝛿(s, v)，然后再reweight，得到𝛅(s, v)，对于任意v，𝛅(s, v)≥0恒成立

    最后再对|V|个顶点运行|V|次Dijkstra即可得到all-pairs shortest paths。

- Graph reweighting

  ![](https://ws1.sinaimg.cn/large/006tNbRwgy1fwsynzvhtbj319w0yak7h.jpg)

- How to reweight?

  ![](https://ws4.sinaimg.cn/large/006tNbRwgy1fwsypd93saj319w0yctlv.jpg)

- pseudocode

  ![](https://ws2.sinaimg.cn/large/006tNbRwgy1fwszmwn2raj315u0t47bp.jpg)

- Analysis

  ![](https://ws4.sinaimg.cn/large/006tNbRwgy1fwsyq1h2tgj319w0ya7le.jpg)