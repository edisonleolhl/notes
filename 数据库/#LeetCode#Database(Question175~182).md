#175. Combine Two Tables

传送门：https://leetcode.com/problems/combine-two-tables/

###Question

---
Table: Person

    +-------------+---------+
    | Column Name | Type    |
    +-------------+---------+
    | PersonId    | int     |
    | FirstName   | varchar |
    | LastName    | varchar |
    +-------------+---------+

PersonId is the primary key column for this table.

Table: Address

    +-------------+---------+
    | Column Name | Type    |
    +-------------+---------+
    | AddressId   | int     |
    | PersonId    | int     |
    | City        | varchar |
    | State       | varchar |
    +-------------+---------+

AddressId is the primary key column for this table.

Write a SQL query for a report that provides the following information for each person in the Person table, regardless if there is an address for each of those people:

    FirstName, LastName, City, State

---

##分析：

###如何连接两张表？

1. 由Question中的`or each person in the Person table, regardless if there is an address for each of those people:`，可知，此时用外连接，如果用内连接则结果集不包含那些地址为空的Person，用外连接可以保证所有Person都在结果集中。

2. 由于结果集包含的列名都是不同的，所以可以省略alias（别名），如：

        SELECT FirstName, LastName, City, State 
        FROM Person LEFT OUTER JOIN Address 
        ON Person.PersonId = Address.PersonId;

3. 由于两张表连接的条件都是PersonId，所以可用USING关键字，如：

        SELECT FirstName, LastName, City, State 
        FROM Person LEFT OUTER JOIN Address 
        USING(PersonId);

###Solution:

- 比较常规的Solution：
    
        SELECT p.FirstName, p.LastName, a.City, a.State 
        FROM Person p LEFT OUTER JOIN Address a 
        ON p.PersonId = a.PersonId;

#176. Second Highest Salary

传送门：https://leetcode.com/problems/second-highest-salary/

###Question：

---

Write a SQL query to get the second highest salary from the Employee
 table.

    +----+--------+
    | Id | Salary |
    +----+--------+
    | 1  | 100    |
    | 2  | 200    |
    | 3  | 300    |
    +----+--------+

For example, given the above Employee table, the second highest salary is 200. If there is no second highest salary, then the query should return null.

---

##分析：

###1. second怎么实现？

- MySQL对于SQL语言的扩展中，添加了limit子句，当limit子句带两个参数时，就可以实现这样的功能。

- 传送门：http://www.jianshu.com/p/67a49b08b380

###2. null怎么实现？

- 第一次做题的时候，根本就没有想到null的问题，所以理所当然的错了，而且错的不知所措-_-，后来去讨论区看了看，原来是因为，empty和null是两个东西，必须要把结果集处理为null。发现有个方法可以解决，那就是UNION：

    ###Solution：
        SELECT distinct(Salary) as SecondHighestSalary FROM Employee
        UNION select null as SecondHighestSalary
        ORDER BY SecondHighestSalary DESC LIMIT 1,1;

- distinct关键字用来去除重复项，这个也是我之前没有考虑到的。

- 假设第一行的SELECT查询返回的结果集为空（empty）的话，那么最后结果集就为null。
 
###3. 取巧的办法

- 同样也是来自于讨论区：

    ###Solution：
        
        SELECT MAX(Salary) as SecondHighestSalary FROM Employee 
        WHERE Salary < (SELECT MAX(Salary) FROM Employee);

- 这种写法很巧妙，先用子查询返回原来结果集中最大（MAX）的记录，然后用过滤（WHERE）来得到第二大的记录。

###4. 比较

- 从runtime上看，显然取巧的方法要快，然而有局限性，只能得到第二大的记录，如果想要第三大、第四大的记录呢？

- 从拓展性来看，第一种方法显示更好，只需要修改limit子句的第一个参数作为偏移量即可。

#177. Nth Highest Salary

传送门：https://leetcode.com/problems/nth-highest-salary/

###Question：

---

Write a SQL query to get the nth highest salary from the Employee table.

    +----+--------+
    | Id | Salary |
    +----+--------+
    | 1  | 100    |
    | 2  | 200    |
    | 3  | 300    |
    +----+--------+
For example, given the above Employee table, the nth highest salary where n = 2 is `200`. If there is no nth highest salary, then the query should return `null`.

---

###分析：

1. 此题与176. Second Highest Salary中解法相同，因为MySQL指定第一个序号为0，所以第N个最高薪水对应从大到小的第N-1个记录，最开始我是这样写的：

        CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
        BEGIN
          RETURN (
              # Write your MySQL query statement below.
              SELECT DISTINCT Salary FROM Employee
              UNION SELECT null
              ORDER BY Salary DESC
              LIMIT N-1, 1
          );
        END

    然而会出现Runtime Error，查了一下才知道，LIMIT子句中不能出现表达式，必须接受numeric arguments。

    > The LIMIT clause can be used to constrain the number of rows returned by the SELECT statement. LIMIT takes one or two numeric arguments, which must both be nonnegative integer constants (except when using prepared statements).

2. 于是在自定义函数返回语句之前先转换一下，Solution：

        CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
        BEGIN
          SET N = N - 1;
          RETURN (
              # Write your MySQL query statement below.
              SELECT DISTINCT Salary FROM Employee
              UNION SELECT null
              ORDER BY Salary DESC
              LIMIT N, 1
          );
        END

3. 由于这时自定义函数，RETURN的要不就是结果集要不就是null，所以可以省略`UNION SELECT null`：
        
        CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
        BEGIN
          SET N = N - 1;
          RETURN (
              # Write your MySQL query statement below.
              SELECT DISTINCT Salary FROM Employee
              ORDER BY Salary DESC
              LIMIT N, 1
          );
        END

#178. Rank Scores

传送门：https://leetcode.com/problems/rank-scores/

###Question：

---

Write a SQL query to rank scores. If there is a tie between two scores, both should have the same ranking. Note that after a tie, the next ranking number should be the next consecutive integer value. In other words, there should be no "holes" between ranks.

    +----+-------+
    | Id | Score |
    +----+-------+
    | 1  | 3.50  |
    | 2  | 3.65  |
    | 3  | 4.00  |
    | 4  | 3.85  |
    | 5  | 4.00  |
    | 6  | 3.65  |
    +----+-------+
For example, given the above `Scores` table, your query should generate the following report (order by highest score):

    +-------+------+
    | Score | Rank |
    +-------+------+
    | 4.00  | 1    |
    | 4.00  | 1    |
    | 3.85  | 2    |
    | 3.65  | 3    |
    | 3.65  | 3    |
    | 3.50  | 4    |
    +-------+------+

---

###分析：

1. 很显然这要处理相等情况，并且后面的数字必须紧跟，不能出现“holes”，观察到：每个Score的Rank假设为x，那么x=当前记录之前的所有记录`COUNT(DISTINCT Score)`，于是有Solution：

        SELECT
          Score,
          (SELECT count(distinct Score) FROM Scores WHERE Score >= s.Score) Rank
        FROM Scores s
        ORDER BY Score desc 

    这里用到子查询（subquery）的概念，从主查询得到的每个记录，都会执行一遍子查询（所以效率较低），子查询的目的是得到当前记录的Rank，注意到`WHERE Score >= s.Score`，这里可以实现*当前记录之前的所有记录*，这种方法比较直观，缺点是效率较低。

2. 原理相同但更快的Solution：
        
        SELECT
          Score,
          (SELECT count(*) FROM (SELECT distinct Score s FROM Scores) tmp WHERE s >= Score) Rank
        FROM Scores
        ORDER BY Score desc

    不明白为什么，有大神解答一下吗 -_-

3. 在讨论区还有其他很多Solution，原理差不多，实现细节不一样而已。

#180. Consecutive Numbers

传送门：https://leetcode.com/problems/consecutive-numbers/

###Question：

---

Write a SQL query to find all numbers that appear at least three times consecutively.

    +----+-----+
    | Id | Num |
    +----+-----+
    | 1  |  1  |
    | 2  |  1  |
    | 3  |  1  |
    | 4  |  2  |
    | 5  |  1  |
    | 6  |  2  |
    | 7  |  2  |
    +----+-----+
For example, given the above `Logs` table, `1` is the only number that appears consecutively for at least three times.

---

###分析：

1. 首先先上一个自己写的ugly code：
        
        SELECT DISTINCT Num as ConsecutiveNums
        FROM Logs o
        WHERE 
        Num = ( 
                SELECT Num
                FROM Logs i 
                WHERE i.id = o.id-1
            )
        AND
        Num = (
                SELECT Num
                FROM Logs i 
                WHERE i.id = o.id-2
            )
        ;

    对于每个主查询，都会让当前记录的Num与前两个记录的Num相比较，相等则放入结果集中，最后用DINSTINCT关键字得到ConsecutiveNums。过程直观，但效率低下，Runtime Rank ： `You are here! 
    Your runtime beats 1.07% of mysql submissions.` -_-

2. 同样原理，但更快的Solution：

        SELECT DISTINCT l1.Num AS ConsecutiveNums
        FROM Logs l1, Logs l2, Logs l3 
        WHERE l1.Id=l2.Id-1 AND l2.Id=l3.Id-1 
        AND l1.Num=l2.Num AND l2.Num=l3.Num;

    注意：这里需要3个表。

#181. Employees Earning More Than Their Managers

传送门：https://leetcode.com/problems/employees-earning-more-than-their-managers/

###Question：

---

The Employee table holds all employees including their managers. Every employee has an Id, and there is also a column for the manager Id.

    +----+-------+--------+-----------+
    | Id | Name  | Salary | ManagerId |
    +----+-------+--------+-----------+
    | 1  | Joe   | 70000  | 3         |
    | 2  | Henry | 80000  | 4         |
    | 3  | Sam   | 60000  | NULL      |
    | 4  | Max   | 90000  | NULL      |
    +----+-------+--------+-----------+

Given the Employee table, write a SQL query that finds out employees who earn more than their managers. For the above table, Joe is the only employee who earns more than his manager.

    +----------+
    | Employee |
    +----------+
    | Joe      |
    +----------+

---

###分析：

1. 这是一个自内连接的典型例子：
        
        SELECT e.name as Employee 
        FROM Employee e INNER JOIN Employee m
        ON e.ManagerId = m.Id 
        WHERE e.Salary > m.Salary;

2. 首先连接条件ON可以得到Employee及其对应Manager，如果当前Employee没有Manager，则不会出现在结果集中（内连接的效果），然后用过滤条件WHERE可以得到工资大于上司的Employee。

#182. Duplicate Emails

传送门：https://leetcode.com/problems/duplicate-emails/

###Question：

---

Write a SQL query to find all duplicate emails in a table named `Person`.
    
    +----+---------+
    | Id | Email   |
    +----+---------+
    | 1  | a@b.com |
    | 2  | c@d.com |
    | 3  | a@b.com |
    +----+---------+
For example, your query should return the following for the above table:

    +---------+
    | Email   |
    +---------+
    | a@b.com |
    +---------+
Note: All emails are in lowercase.

---

###分析：

1. 这题是查找是否有重复的Email，首先我想到的是对于对于每个Email，在剔除掉它的记录中查找是否还有重复的Email，代码如下：

        SELECT DISTINCT Email
        FROM Person p1 
        WHERE Email in (
            SELECT Email FROM Person p2
            WHERE p1.Id <> p2.Id);

2. 代码通过，但是`You are here! 
Your runtime beats 2.51% of mysql submissions.` -_-

3. 还可以利用自内连接：

        SELECT DISTINCT p1.Email 
        FROM Person p1 INNER JOIN Person p2
        ON p1.Email = p2.Email
        WHERE p1.Id <> p2.Id;

    - Runtime: 751 ms

    - Your runtime beats 4.57% of mysql submissions.

4. 还有一种利用GROUP BY和HAVING的Solution，：

        SELECT Email FROM Person
        GROUP BY
            Email
        HAVING 
            COUNT(Email) > 1

    - Runtime: 811 ms

    - Your runtime beats 1.83% of mysql submissions.-_-

5. 利用EXISTS关键字，其中`LIMIT 1，1`的作用是跳过第0号记录，因为那是它自身：
        
         SELECT DISTINCT a.Email
         FROM Person a
         WHERE EXISTS(
             SELECT 1
             FROM Person b
             WHERE a.Email = b.Email
             LIMIT 1, 1
         )
