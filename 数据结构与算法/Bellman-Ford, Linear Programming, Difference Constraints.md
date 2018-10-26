## Bellman-Ford algorithm

- IDEA: Finds all shortest-path lengths from a source s ∈ V to all v ∈ V or determines that a ***negative-weight cycle*** exists.

  The algorithm relaxes edges, progressively decreasing an estimate v.d on the weight of a shortest path from the source s to each vertex v∈V until it achieves the actual shortest-path weight δ(s, v). 

- pseudocode

  ```
  d[s] ← 0									 // initialization
  for each v ∈ V – {s}			 // initialization
  	do d[v] ← ∞              // initialization
  for i ← 1 to |V|–1
  	do for each edge (u, v) ∈ E
  		do if d[v] > d[u] + w(u, v)     // relaxation
  			then d[v] ← d[u] + w(u, v)    // relaxation
  for each edge (u, v) ∈ E
  	do if d[v] > d[u] + w(u, v)
  		then report that a negative-weight cycle exists
  ```

- Anylysis

  At the end, for any vertices v, d[v] = δ(s, v), if no negative-weight cycles.
  Time = O(VE)

- Detection of negative-weight cycles

  - Corollary. If a value d[v] fails to ***converge*** after |V| – 1 passes, there exists a negative-weight cycle in G reachable from s.
- Why use Bellman-Ford instead of Dijkstra?
  - Bellman-Ford could tell whether the graph has negative-weight cycle, but Dijkstra couldn't.
  - Bellman-Ford could run on ***distrbuted*** environment, which means that each vertices could stand for a machine which could constantly ***relax*** its edges according to the information already known by itself.

### CLRS Exercises

- 24.1-3

  - Given a weighted, directed graph G=(V,E)G=(V,E) with no negative-weight cycles, let mm be the maximum over all vertices v∈V of the minimum number of edges in a shortest path from the source s to v. (Here, the shortest path is by weight, not the number of edges.) Suggest a simple change to the Bellman-Ford algorithm that allows it to terminate in m+1 passes, even if mm is not known in advance.

  - Solution:

    Bellman-Ford算法在m次迭代后，所有的v.d已经是最优的了，无法再进行relax，故m+1不会有v.d变化，因为事先不知道m的值是多少，但是只要当算法检测出v.d不再变化后，那次的迭代就是第m+1次，于是算法即停止。

### Linear Programming

- Shortest path problem originates from linear programming.

- What is linear programming

  ![inear programming](http://ooy7h5h7x.bkt.clouddn.com/blog/181026/HkahA40i4k.png?imageslim)

- Solving a system of difference constraints:

  ![Solving a system of difference constraints](http://ooy7h5h7x.bkt.clouddn.com/blog/181026/mg0302f0EG.png?imageslim)

- Theorem. If the constraint graph contains a negative-weight cycle, then the system of differences is unsatisfiable. 

  Theorem. Suppose no negative-weight cycle exists in the constraint graph. Then, the constraints are satisfiable.

- Proof:

  ![Proof](http://ooy7h5h7x.bkt.clouddn.com/blog/181026/9L2fiD9Eem.png?imageslim)

- Bellman-Ford and linear programming:

  ![Bellman-Ford and linear programming](http://ooy7h5h7x.bkt.clouddn.com/blog/181026/HGjiDfDB60.png?imageslim)

### Bellman-Ford and linear programming

- Corollary. The Bellman-Ford algorithm can solve a system of m difference constraints on n variables in O(mn) time. 
- Single-source shortest paths is a simple LP problem.