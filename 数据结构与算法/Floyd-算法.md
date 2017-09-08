# Floyd 算法

## 简介

- Floyd 算法又称为插点法，是一种利用动态规划的思想寻找给定的加权图中多源点之间最短路径的算法，与 Dijkstra 算法类似。

- 该算法名称以创始人之一、1978 年图灵奖获得者、斯坦福大学计算机科学系教授罗伯特 · 弗洛伊德命名。

## 核心思路

### 路径矩阵

- 通过一个图的权值矩阵求出它的每两点间的最短路径矩阵。
- 从图的带权邻接矩阵 A=[a(i,j)] n×n 开始，递归地进行 n 次更新，即由矩阵 D(0)=A，按一个公式，构造出矩阵 D(1)；又用同样地公式由 D(1) 构造出 D(2)；……；最后又用同样的公式由 D(n-1) 构造出矩阵 D(n)。矩阵 D(n) 的 i 行 j 列元素便是 i 号顶点到 j 号顶点的最短路径长度，称 D(n) 为图的距离矩阵，同时还可引入一个后继节点矩阵 path 来记录两点间的最短路径。
- 采用松弛技术（松弛操作），对在 i 和 j 之间的所有其他点进行一次松弛。所以时间复杂度为 O(n^3)。

### 状态转移方程

- `path[i,j]:=min{path[i,k]+path[k,j],path[i,j]}`

### 算法描述

1. 从任意一条单边路径开始。所有两点之间的距离是边的权，如果两点之间没有边相连，则权为无穷大。

1. 对于每一对顶点 u 和 v，看看是否存在一个顶点 w （一般称为中间点）使得从 u 到 w 再到 v 比已知的路径更短。如果是，更新它（专业术语为：*松弛*）。

1. 遍历直到结束，这时候存储图的数据结构就得到了多源最短路径。

## 优缺点分析

- Floyd 算法适用于 APSP(All Pairs Shortest Paths，多源最短路径)，是一种动态规划算法，稠密图效果最佳，边权可正可负。此算法简单有效，由于三重循环结构紧凑，对于稠密图，效率要高于执行 | V | 次 Dijkstra 算法，也要高于执行 | V | 次 SPFA 算法。

    > 稠密图定义：边的条数 | E | 接近 | V|²，称为稠密图（dense graph）

- 优点：容易理解，可以算出任意两个节点之间的最短距离，代码编写简单。

- 缺点：时间复杂度比较高，不适合计算大量数据。时间复杂度 O（n^3）,空间复杂度 O（n^2）。

## Python 代码实现

- 代码：

        import copy
        M=1000000
        def Floyd(G):
            n=len(G)
            path=copy.deepcopy(G)
            for k in range(0,n):
                for i in range(0,n):
                    for j in range(0,n):
                        print("Comparing path[%s][%s] and {path[%s][%s]+path[%s][%s]}"%(i,j,i,k,k,j))
                        print("Former path[%s][%s] = %s"%(i,j,path[i][j]))
                        path[i][j]=min(path[i][j],path[i][k]+path[k][j])
                        print("Present path[%s][%s] = %s\n"%(i,j,path[i][j]))
            return path

        if __name__=='__main__':
            G=[
                [0,30,15,M,M,M],
                [5,0,M,M,20,30],
                [M,10,0,M,M,15],
                [M,M,M,0,M,M],
                [M,M,M,10,0,M],
                [M,M,M,30,10,0]
                ]
            print("---------------Floyd----------------")
            path=Floyd(G)
            print("Graph = ")
            for i in range(0,len(G)):
                print (path[i])

## 代码详解

- 引入 copy ，定义无穷值，在 Python 里还有种写法： `M = float('inf')`

- 定义 Floyd 函数，参数为图的邻接矩阵 G，在里面首先利用 copy 函数复制一份，不复制的话，会导致两个变量指向同一个地址（邻接矩阵）

- 三重 for 循环，很容易理解

- `if __name__=='__main__'`
    > 不理解的复制这段代码，百度谷歌

## 测试

- 还是拿我的另一篇文章 [Dijkstra 算法](http://www.jianshu.com/p/8ba71199a65f) 中的测试用例

- 邻接矩阵：

            G=[
                [0,30,15,M,M,M],
                [5,0,M,M,20,30],
                [M,10,0,M,M,15],
                [M,M,M,0,M,M],
                [M,M,M,10,0,M],
                [M,M,M,30,10,0]
                ]

- 表示的图如下：

    ![test](http://upload-images.jianshu.io/upload_images/2106579-793e70c5ec13c1d0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 输出：

    ![floydtest](http://upload-images.jianshu.io/upload_images/2106579-0468d9484a441485.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 小结

- 从上面的输出结果可以看到 G 矩阵已经被更新了

- 有些走不通的路径现在可以走通了，因为原来是邻接矩阵：两个顶点有邻接边，邻接矩阵对应点才有值；现在是整个网络，顶点 i 到顶点 j 如果可达，那么 `G[i][j]` 就有值。

- 但是，我们是得到了两个点的最小 cost，最短路径要怎么得到呢？可以再借助一个 path 矩阵，它记录了中间点的信息，我们可以在最后根据更新后的 G 矩阵回溯 path 矩阵得到最短路径。

## 全局最短路径的数据结构


    ShortestPath_dict = {
        0: {1: [0, 2, 1], 2: [0, 2], 3: [0, 2, 5, 4, 3], 4: [0, 2, 5, 4], 5: [0, 2, 5]},
        1: {0: [1, 0], 2: [1, 0, 2], 3: [1, 4, 3], 4: [1, 4], 5: [1, 5]}, 2: {0: [2, 1, 0],
        1: [2, 1], 3: [2, 5, 4, 3], 4: [2, 5, 4], 5: [2, 5]},
        3: {0: [], 1: [], 2: [], 4: [], 5: []},
        4: {0: [], 1: [], 2: [], 3: [4, 3], 5: []},
        5: {0: [], 1: [], 2: [], 3: [5, 4, 3], 4: [5, 4]}
        }

- 这个数据结构利用了字典与列表，其中每两个顶点的最短路径用列表表示，如顶点 0 到顶点 1 ：`0: {1: [0, 2, 1]`，其中的`[0, 2, 1]`就是最短路径。

## 利用 Floyd 得到全局最短路径

- 代码：

        # ------------------函数-------------------
        def back_path(path,i,j,shortestPath):            #递归回溯
            print ("path[%s][%s] = "%(i,j),path[i][j])
            if -1 != path[i][j]:
                shortestPath = back_path(path,i,path[i][j],shortestPath)
                shortestPath = back_path(path,path[i][j],j,shortestPath)
            if j not in shortestPath:
                shortestPath.append(j)
            return shortestPath

        def getShortestPath(graph,path,i,j):
            shortestPath = []
            if graph[i][j] == float('inf') or i == j:
                print("顶点%s 不能到达 顶点%s！"%(i,j))
                return shortestPath
            elif path[i][j] == -1:
                shortestPath.append(i)
                shortestPath.append(j)
            else :
                shortestPath.append(i)
                shortestPath = back_path(path,i,j,shortestPath)
            print("顶点%s 到 顶点%s 的路径为："%(i,j),shortestPath)
            return shortestPath

        def getAllShortestPath(graph,path):
            print("------正在生成全局最短路径------")
            ShortestPath_dict = {}
            for i in range(N):
                ShortestPath_dict[i] = {}
                for j in range(N):
                    print("尝试生成顶点%s到顶点%s的最短路径..."%(i,j))
                    if i !=j :
                        shortestPath = getShortestPath(graph,path,i,j)
                        ShortestPath_dict[i][j] = shortestPath
                    print("--------------------------------")
            return ShortestPath_dict

        # ----------------------定义--------------------
        M=float('inf')      #无穷大
        graph = [
                [0,30,15,M,M,M],
                [5,0,M,M,20,30],
                [M,10,0,M,M,15],
                [M,M,M,0,M,M],
                [M,M,M,10,0,M],
                [M,M,M,30,10,0]
                ]
        N = len(graph)
        path = []
        for i in range(N):
            path.append([])
            for j in range(N):
                path[i].append(-1)

        print ("Original Graph:\n",graph)
        # -----------------Floyd Algorithm----------------
        for k in range(N):
            for i in range(N):
                for j in range(N):
                    if graph[i][j] > graph[i][k] + graph[k][j]:
                        graph[i][j] = graph[i][k] + graph[k][j]
                        path[i][j] = k

        print ("Shortest Graph:\n",graph)
        print ("Path:\n",path)

        print("ShortestPath =\n",getAllShortestPath(graph,path))

## 测试2

- 邻接矩阵如上所示

- 表示的图也如上所示

- 截图

    ![test3](http://upload-images.jianshu.io/upload_images/2106579-9095d22c75f1ad1c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
    ![last](http://upload-images.jianshu.io/upload_images/2106579-3af6c2fe30537ab0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 代码详解2

- 在三重循环阶段，与前文第一种做法不同的是：每次还加入了`path[i][j] = k`，这样每次松弛，都会被记录在 path 矩阵中

- path 矩阵完成后，如测试2中的截图所示

- `getAllShortestPath` 函数

  - 构造字典 ShortestPath_dict
  - 两两遍历图中各点，循环调用 `getShortestPath` 函数

- `getShortestPath` 函数

  - 如果两个顶点不可达或者这两个顶点为同一个顶点，那么直接说明不可达，且返回值为空列表：`[]`
  - 如果两个顶点不需要松弛就可以得到最短路径，那么在 path 矩阵中对应点的值就为初始值 -1，这代表了这两个顶点邻接，在 `getShortestPath` 函数中是需要判断的
  - 如果两个顶点需要松弛才能得到最短路径，那么在 path 矩阵中对应点的值就不为 -1，那么需要递归调用 `back_path` 函数

- `back_path` 函数

  - 之前说了，path 矩阵中记录的是每次松弛操作时的中间点，所以在函数中前后两次调用本身

- 举例说明
  - 以测试2的截图为例，尝试顶点0到顶点3的最短路径：
    - 进入 `getShortestPath(graph,path,i,j)` ，调用 `back_path(path,0,3,[0])`
    - 首先调用 `back_path(path,0,3,[0])` ，发现 path[0][3]=5，说明需要顶点5的中转
    - 于是调用 `back_path(path,0,5,[0])` ，发现 path[0][5]=2，说明需要顶点2的中转
    - 继续调用 `back_path(path,0,2,[0])` ，发现到头了，顶点0和顶点2直接邻接，于是不再递归下去了，添加顶点2到最短路径 shortestPath，此时 [0,2]
    - 返回上层，调用 `back_path(path,2,5,[0,2])` ，发现到头了，顶点2和顶点5直接邻接，于是不再递归下去了，添加顶点5到最短路径 shortestPath，此时 [0,2,5]
    - 返回上层，调用 `back_path(path,5,3,[0,2,5])`，发现需要顶点4的中转
    - 于是调用 `back_path(path,5,4,[0,2,5])`，发现到头了，不再递归，添加顶点4到最短距离，此时 [0,2,5,4]
    - 返回上层，调用 `back_path(path,4,3,[0,2,5,4])`，发现到头了，不再递归，添加顶点3到最短距离，此时 [0,2,5,4,3] 已经是最短距离了
    - 注意：因为只要调用 `back_path` 就会添加顶点进入最短路径 shortestPath，为了避免重复，加入了 if 判断，直接过滤掉重复的顶点，因为最短路径不可能绕圈子。

> 源码地址：https://github.com/edisonleolhl/DataStructure-Algorithm/blob/master/Graph/ShortestPath/floyd.py
