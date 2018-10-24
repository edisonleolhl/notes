# Single-Source Shortest Paths

## MIT OCW NOTES

- Paths in graphs: Consider a digraph G = (V, E) with edge-weight function w : E → R . The weight of path p = v 1 →
  v 2 → ... → v k is defined to be 

  w(p) = ∑w(vi, vi+1)

- ***Shortest Path***: A shortest path from u to v is a path of
  minimum weight from u to v. The shortest-
  path weight from u to v is defined as 

  δ(u, v) = min{w(p) : p is a path from u to v}.

- Note: 

  δ(u, v) = ∞ if no path from u to v exists.

  There is no shortest paths from u to v  if there is a ***negative weight cycle***.

  In this case, shortest paths are ***well defined***.

### Optimal substructure

- Theorem. A subpath of a shortest path is a
  shortest path.
- Proof. Cut and Paste!

- [What is Cut and Paste?](http://ranger.uta.edu/~huang/teaching/CSE5311/CSE5311_Lecture16.pdf)
  - The "cut and paste" technique is a way to prove that a problem has the property.
    – In particular, you want to show that when you come up with an optimal solution to a problem, you have necessarily used optimal solutions to the constituent subproblems.
  - The proof is by contradiction.
    – Suppose you came up with an optimal solution to a problem by using suboptimal solutions to subproblems.
    – Then, if you were to replace ("cut") those suboptimal subproblem solutions with optimal subproblem solutions (by "pasting" them in), you would improve your optimal solution.
    – But, since your solution was optimal by assumption, you have a contradiction.

### Triangle inequality
- Theorem. For all u, v, x ∈ V, we have
  δ(u, v) ≤ δ(u, x) + δ(x, v).

### Single-source shortest paths

- Problem. From a given source vertex s ∈ V, find
  the shortest-path weights δ(s, v) for all v ∈ V.
  If all edge weights w(u, v) are nonnegative, all
  shortest-path weights must exist.

- IDEA : ***Greedy***.

  1. Maintain a set S of vertices whose shortest-
     path distances from s are known.
  2. At each step add to S the vertex v ∈ V – S
     whose distance estimate from s is minimal.
  3. Update the distance estimates of vertices
     adjacent to v.

- ***BFS*** is a shortest-paths algorithm that works on unweighted graphs!

- The algorithm for the single-source problem can
  solve many other problems, including the following variants.

  - **Single-destination shortest-paths problem**: Find a shortest path to a given destination vertex t from each vertex v. By reversing the direction of each edge in the graph, we can reduce this problem to a single-source problem.
  - **Single-pair shortest-path problem**: Find a shortest path from u to v for given vertices u and v. If we solve the single-source problem with source vertex u, we solve this problem also. Moreover, all known algorithms for this problem have the same worst-case asymptotic running time as the best single-source algorithms.

  - **All-pairs shortest-paths problem**: Find a shortest path from u to v for every pair of vertices u and v. Although we can solve this problem by running a single-source algorithm once from each vertex, we usually can solve it faster. Additionally, its structure is interesting in its own right. Chapter 25 addresses the all-pairs problem in detail.

- [***Shortest-paths tree***](https://en.wikipedia.org/wiki/Shortest-path_tree):  Given a connected, undirected graph G, a shortest-path tree rooted at vertex v is a spanning tree T of G, such that the path distance from root v to any other vertex u in T is the shortest path distance from v to u in G.

### Relaxation（重难点）

- The algorithms in this chapter use the technique of relaxation. For each vertex v∈ V , we maintain an attribute v.d, which is an upper bound on the weight of a shortest path from source s to v. We call v.d a shortest-path estimate. We initialize the shortest-path estimates and predecessors by the following O(V)-time procedure（v.π is the ***predecessor*** of v）:

  ```
  INITIALIZE SINGLE SOURCE(G,s)
  1 for each vertex v ∈ G.V
  2 	v.d = ∞
  3 	v.π = ∞
  4 s.d = 0
  ```

- The process of relaxing an edge (u, v) consists of testing whether we can improve the shortest path to found so far by going through u and, if so, updating v.d and v.π.

- A relaxation step may decrease the value of the shortest-path estimate v.d and update v’s predecessor attribute v.π. The following code performs a relaxation step on edge (u, v) in O(1) time:

  ```
  RELAX(u, v, w)
  1 if v.d > u.d + w(u, v)
  2 	v.d = u.d + w(u, v)
  3 	v.d = u
  ```

  > It may seem strange that the term “relaxation” is used for an operation that tightens an upper bound. 
  >
  > The outcome of a relaxation step can be viewed as a relaxation
  > of the constraint v.d ≤ u.d + w(u, v), which, by the triangle inequality (Lemma 24.10), must be satisfied if u.d = δ(s, u) and v.d = δ(s, v). 
  >
  > That is, if v.d ≤ u.d + w(u, v), there is no “pressure” to satisfy this constraint, so the constraint is “relaxed.”

- Each algorithm in this chapter calls INITIALIZE-SINGLE-SOURCE and then repeatedly relaxes edges. Moreover, relaxation is the only means by which shortest path estimates and predecessors change. 

  The algorithms in this chapter differ in how many times they relax each edge and the order in which they relax edges. 

  Dijkstra’s algorithm and the shortest-paths algorithm for directed acyclic graphs relax each edge exactly once. 

  The Bellman-Ford algorithm relaxes each edge |V|-1 times.

### Dijkstra's algorithm

- IDEA: 

  Dijkstra’s algorithm solves the single-source shortest-paths problem on a weighted, directed graph G = (V, E) for the case in which all edge weights are nonnegative. In this section, therefore, we assume that w(u, v)  ≥ 0 for each edge (u, v). 

  As we shall see, with a good implementation, the running time of Dijkstra’s algorithm is lower than that of the Bellman-Ford algorithm.

  Dijkstra’s algorithm maintains a set S of vertices whose final shortest-path weights from the source s have already been determined. The algorithm repeatedly selects the vertex u ∈ V-S with the minimum shortest-path estimate, adds u to S, and relaxes all edges leaving u. 

  In the following implementation, we use a min-priority queue Q of vertices, keyed by their d values.

- pseudocode

  ```
  d[s] ← 0
  for each v ∈ V – {s}
  	do d[v] ← ∞
  S ← ∅
  Q ← V 		// Q is a priority queue maintaining V – S
  while Q ≠ ∅
  	do u ← E XTRACT-MIN (Q)
  		S ← S ∪ {u}
  		for each v ∈ Adj[u]
  			do if d[v] > d[u] + w(u, v)    // RELAXATION
  				then d[v] ← d[u] + w(u, v)   // RELAXATION
  ```

- Analysis

  ![Analysis of Dijkstra](http://ooy7h5h7x.bkt.clouddn.com/blog/181024/B3aBLdidki.png?imageslim)

  ![Analysis of Dijkstra using different data structure](http://ooy7h5h7x.bkt.clouddn.com/blog/181024/DGk4FekG6F.png?imageslim)

  Same as Prim's algorithm!

### Breadth-First Search algorithm

- IDEA: 

  Given a graph G =(V, E) and a distinguished source vertex s, breadth-first
  search systematically explores the edges of G to “discover” every vertex that is reachable from s. It computes the ***distance*** (smallest number of edges) from s to each reachable vertex. 

  It also produces a “breadth-first tree” with root s that
  contains all reachable vertices. For any vertex reachable from s, the simple path in the breadth-first tree from s to corresponds to a “shortest path” from s to in G, that is, a path containing the smallest number of edges. 

  The algorithm works on both directed and undirected graphs.

- Why call it Breadth-first?

  Because it expands the frontier between discovered and undiscovered vertices uniformly across the breadth of the frontier. That is, the algorithm discovers all vertices at distance k from s before discovering any vertices at distance k + 1.

Relationship between Dijkstra and BFS:

- Suppose that w(u, v) = 1 for all (u, v) ∈ E. Can Dijkstra’s algorithm be improved?

  Use a simple FIFO queue instead of a priority queue.

- pseudocode

  ```
  while Q ≠ ∅
  	do u ← DEQUEUE (Q)
  		for each v ∈ Adj[u]
  			do if d[v] = ∞
  					then d[v] ← d[u] + 1
  						E0NQUEUE (Q, v)
  ```



---

> 以下是以前做的关于Dijkstra's algorithm的笔记

## 前言

- 为了达到任意两结点的最短路径，我们有几种算法可以实现：Dijkstra 算法、Floyd 算法等等。

- Floyd 算法虽然可以得到一幅图中任意两点的最小 cost，但是我们在本题重点关注最短路径 Shortest_path，若要采用 Floyd 算法来得到最短路径 Shortest_path 不太方便，所以我们决定采用 Dijkstra 算法。

- 该算法使用了广度优先搜索解决带权有向图的单源最短路径问题，算法最终得到一个最短路径树。该算法常用于路由算法或者作为其他图算法的一个子模块。Dijkstra 算法无法解决负权重的问题，但所幸在本题中不考虑负权重。

### 什么时候最短路径不存在？

- 只要图中存在总权重为负的环路，则最短路径不存在。

### 环路

- 一条最短路径不能包含环路，无论正或负。

- 反证法：假设包含环路，则删除这条环路，路径相同但权重更小的路径，所以这不是一条最短路径。

- 同样地，若图中某条环路权重为 0，则计算最短路径时可以不断删除这些环路，直到最短路径中没有环路。

## 准备工作

- 如何描述一幅图？

- 用Python的二维列表（2-D list）描述的图，这是邻接矩阵的经典表示方法，每行代表一个结点，每列代表一个结点，如果对应的值为1，则表示两个结点邻接，如果为 M 则不邻接，对于无向无权图，肯定对称。

        nodes = ['s1', 's2', 's3', 's4']
        M =  float("inf")   # M means a large number
        graph_list = [
        [M, 1, 1, 1],
        [1, M, M, 1],
        [1, M, M, 1],
        [1, 1, 1, M],
        ]

- 用 Python 的列表与元组（tuple）描述的图，这实际上存储的是每条边的信息，每个括号内的内容依次为：(tail,head,cost)。

        graph_edges = [
        (‘s1’, ‘s2’, 1), (‘s1’, ‘s3’, 1), (‘s1’, ‘s4’, 1),
        (‘s2’, ‘s1’, 1), (‘s2’, ‘s4’, 1),
        (‘s3’, ‘s1’, 1), (‘s3’, ‘s4’, 1),
        (‘s4’, ‘s1’, 1), (‘s4’, ‘s2’, 1), (‘s4’, ‘s3’, 1),
        ]

- 用 Python 的字典（dict）描述的图，这种表示方法很灵活，每个key代表一个结点，该结点作为tail，其邻接的head及它们之间的cost存储在value里，可想而知，对于每个 tail，可能有多个 head，所以 value 其实是一个列表，每个列表项是个两元组 (head, cost)。

        graph_dict = {
        ‘s1’:[(‘s2’,1),(‘s3’,1),(‘s4’,1)],
        ‘s2’:[(‘s1’,1), (‘s4’,1)],
        ‘s3’:[(‘s1’,1), (‘s4’,1)],
        ‘s4’:[(‘s1’,1),(‘s2’,1),(‘s3’,1)],
        }

- 在有些Python代码中，也有这样的形式：`‘s1’:{‘s2’:1,‘s3’:1,‘s4’:1}`，这和我们的 `‘s1’:[(‘s2’,1),(‘s3’,1),(‘s4’,1)]` 没什么差别，都是我们用来存储数据的数据结构。

- 这三种表示方法在是可以互相转化，在此我们给出 graph_list -> graph_edges 以及 graph_edges->graph_dict 的转化算法。

        # graph_list -> graph_edges
        graph_edges = []
        for i in nodes:
            for j in nodes:
                if i!=j and graph_list[nodes.index(i)][nodes.index(j)]!=M:
                    graph_edges.append((i,j,graph_list[nodes.index(i)][nodes.index(j)]))
        
        # graph_edges->graph_dict
        graph_dict = defaultdict(list)
        for tail,head,cost in graph_edges:
            graph_dict[tail].append((head,cost))

## Dijkstra 算法描述

- G=(V,E)
- 在运行时维持的关键信息是一组结点集合 S，它记录了从源结点 s 到该集合中每个结点之间的最短路径。

- 算法重复从结点集 V-S 中选择最短路径估计最小的路径 u，将 u 加入到集合 S ，然后对所有从 u 发出的边进行松弛（relaxation）。

## Python 实现 Dijkstra 算法

- 一般而言，若想寻找给定两点的最短路径，Dijkstra 算法必须传入三个参数，一个是图的描述 graph_dict，一个是源点 from_node，一个是终点 to_node。

- 核心代码如下：

        def dijkstra(graph_dict, from_node, to_node):
            cost = -1
            ret_path=[]
            q, seen = [(0,from_node,())], set()
            while q:
                (cost,v1,path) = heappop(q)
                if v1 not in seen:
                    seen.add(v1)
                    path = (v1, path)
                    if v1 == to_node: # Find the to_node!!!
                        break;
                    for v2,c in graph_dict.get(v1, ()):
                        if v2 not in seen:
                            heappush(q, (cost+c, v2, path))
        
            # Check the way to quit 'while' loop!!!
            if v1 != to_node:
                print("There is no node: " + str(to_node))
                cost = -1
                ret_path=[]
        
            # IF there is a path from from_node to to_node, THEN format the path!!!
            if len(path)>0:
                left = path[0]
                ret_path.append(left)
                right = path[1]
                while len(right)>0:
                    left = right[0]
                    ret_path.append(left)
                    right = right[1]
                ret_path.reverse()
        
            return cost,ret_path

## 算法详解

- 这里用到了堆排序的 heapq 模块，注意它的 heappop(q) 与heappush(q,item) 方法：

  - heapq.heappush(heap, item): 将 item 压入到堆数组 heap 中。如果不进行此步操作，后面的 heappop() 失效

  - heapq.heappop(heap): 从堆数组 heap 中取出最小的值，并返回。

### 思路：

1. q, seen = [(0,from_node,())], set()

    - q 记录了中间点 v 与 U 集合中哪些点邻接，这些邻接点为 k1、k2...，并且在 q 中的存储形式为：[(cost1,k1,path1),(cost2,k2,path2)...]

    - seen 就是算法描述部分提到的 V 集合，记录了所有已访问的点

1. (cost,v1,path) = heappop(q)

    - 这行代码会得到 q 中的最小值，也就是在算法描述部分提到的 k，用算法描述为：cost=min(cost1,cost2...)

1. seen.add(v1)

    - 这行代码对应算法描述的“ k 加到 V 集合中，将 k 从 U 集合删除”

    - 这个时候的 k 已经成为了中间点 v

1. 查找 U 集合中所有与中间点 v 邻接的点 k1、k2... ：

            for v2,c in graph_dict.get(v1, ()):
                if v2 not in seen:
                    heappush(q, (cost+c, v2, path))

    - 把 k1、k2... push 进入 q 中，回到第 2 点

## 测试

- 不失一般性，给定一个带权有向图：

        graph_list = [
        [0,30,15,M,M,M],
        [5,0,M,M,20,30],
        [M,10,0,M,M,15],
        [M,M,M,0,M,M],
        [M,M,M,10,0,M],
        [M,M,M,30,10,0]
        ]

- 其表示的图如下：

    ![graph](http://upload-images.jianshu.io/upload_images/2106579-793e70c5ec13c1d0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 测试一下 s1 到 s6 的最短路径：

    ![test](http://upload-images.jianshu.io/upload_images/2106579-5a18ce0df92b54cb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 可以看到，dijkstra 函数得到了正确的最短路径以及 cost 值。

## 利用 dijkstra 得到图中所有最短路径

- 我们准备在此基础上加以改进，利用 Dijkstra 算法得到任意两个结点之间的最短路径，为了达到这个目的，我们在算法的最后要有一个数据结构来存储这些最短路径，如果使用 Python，这个数据结构应该是像下面这样的：

        Shortest_path_dict = {
        's1': {'s2': ['s1', 's3', 's2'], 's3': ['s1', 's3'] },
        's2': {'s1': ['s2', 's1'], 's3': ['s2', 's1', 's3'},
        's3': {'s1': ['s3', 's2', 's1'], 's2': ['s3', 's2'] },
        }

- 它存储了下面这幅图的所有最短路径：

    ![graph2](http://upload-images.jianshu.io/upload_images/2106579-f60356d66feec49c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 我们要想得到任意两点的最短路径，要用 Shortest_path_dict 来存储所有可能的最短路径，于是再创建一个新的函数 dijkstra_all，该函数仅仅只需要接受一个参数：图的描述 graph_dict，然后返回 Shortest_path_dict，在 dijkstra_all 中需要循环调用 dijkstra 函数。

- 核心代码如下：

        def dijkstra_all(graph_dict):
            Shortest_path_dict = defaultdict(dict)
            for i in nodes:
                for j in nodes:
                    if i != j:
                        cost,Shortest_path = dijkstra(graph_dict,i,j)
                        Shortest_path_dict[i][j] = Shortest_path
        
            return Shortest_path_dict

- 不失一般性，我们采用带权有向图测试我们的算法，图的描述与前文测试 dijkstra 算法时一致，在此直接调用 dijkstra_all函数，传入 graph_dict，得到的结果截图如下：

    ![test2](http://upload-images.jianshu.io/upload_images/2106579-b954de949d3ab2c0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 看最后的输出，得到了我们想要的 Shortest_path_dict


> 源码：https://github.com/edisonleolhl/DataStructure-Algorithm/blob/master/Graph/ShortestPath/dijkstra.py
