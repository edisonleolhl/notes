# Dijkstra 算法

## 前言

- 为了达到任意两结点的最短路径，我们有几种算法可以实现：Dijkstra 算法、Floyd 算法等等。

- Floyd 算法虽然可以得到一幅图中任意两点的最小 cost，但是我们在本题重点关注最短路径 Shortest_path，若要采用 Floyd 算法来得到最短路径 Shortest_path 不太方便，所以我们决定采用 Dijkstra 算法。

- 该算法使用了广度优先搜索解决带权有向图的单源最短路径问题，算法最终得到一个最短路径树。该算法常用于路由算法或者作为其他图算法的一个子模块。Dijkstra 算法无法解决负权重的问题，但所幸在本题中不考虑负权重。

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

## 算法描述

- 将图所有点的集合 S 分为两部分，V 和 U。

- V 集合是已经得到最短路径的点的集合，在初始情况下 V 中只有源点 s，U 是还未得到最短路径点的集合，初始情况下是除 s 的所有点。因为每次迭代需要指明当前正在迭代的 V 集合中的某点，所以将该点设为中间点。自然，首先应将 s 设为中间点 k，然后开始迭代。

- 在每一次迭代过程中，取得 U 中距离 k 最短的点 k，将 k 加到 V 集合中，将 k 从 U 集合删除，再将 k 设为中间点 v。重复此过程直到 U 集合为空。

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
