#183. Customers Who Never Order

###Question:

---

Suppose that a website contains two tables, the Customers table and the Orders table. Write a SQL query to find all customers who never order anything.

Table: Customers.

    +----+-------+
    | Id | Name  |
    +----+-------+
    | 1  | Joe   |
    | 2  | Henry |
    | 3  | Sam   |
    | 4  | Max   |
    +----+-------+
Table: Orders.

    +----+------------+
    | Id | CustomerId |
    +----+------------+
    | 1  | 3          |
    | 2  | 1          |
    +----+------------+
Using the above tables as example, return the following:

    +-----------+
    | Customers |
    +-----------+
    | Henry     |
    | Max       |
    +-----------+

---

###分析：

1. 很明显这需要两张表的连接，这里用内连接更为合适，子查询的DISTINCT可有可无，对效率影响不大，利用NOT IN 的简单的Solution：
        
        SELECT Name as Customers
        FROM Customers c 
        WHERE c.Id NOT IN (
            SELECT DISTINCT CustomerId 
            FROM Orders o);

    - Runtime: 494 ms
    
    - Your runtime beats 43.75% of mysql submissions.

2. 另外一种Solution：

        SELECT c.Name as Customers FROM Customers c
        WHERE 0 = (
            SELECT COUNT(*) 
            FROM Orders o 
            WHERE o.customerId=c.id);

    - Runtime: 483 ms

    - Your runtime beats 58.33% of mysql submissions.

3. 还可以利用EXISTS：

        SELECT c.Name as Customers 
        FROM Customers c
        WHERE NOT EXISTS (
            SELECT 1 
            FROM Orders o 
            WHERE o.customerId=c.id);

    - Runtime: 483 ms

    - Your runtime beats 58.33% of mysql submissions.

#184. Department Highest Salary

传送门：https://leetcode.com/problems/department-highest-salary/

###Question：

---

The Employee table holds all employees. Every employee has an Id, a salary, and there is also a column for the department Id.

    +----+-------+--------+--------------+
    | Id | Name  | Salary | DepartmentId |
    +----+-------+--------+--------------+
    | 1  | Joe   | 70000  | 1            |
    | 2  | Henry | 80000  | 2            |
    | 3  | Sam   | 60000  | 2            |
    | 4  | Max   | 90000  | 1            |
    +----+-------+--------+--------------+
The Department table holds all departments of the company.

    +----+----------+
    | Id | Name     |
    +----+----------+
    | 1  | IT       |
    | 2  | Sales    |
    +----+----------+
Write a SQL query to find employees who have the highest salary in each of the departments. For the above tables, Max has the highest salary in the IT department and Henry has the highest salary in the Sales department.

    +------------+----------+--------+
    | Department | Employee | Salary |
    +------------+----------+--------+
    | IT         | Max      | 90000  |
    | Sales      | Henry    | 80000  |
    +------------+----------+--------+

---

###分析：

1. 这是个用到分组与聚合的很好的例子，首先内连接两张表，然后对Department进行分组，同时，在结果集中加入`MAX(e.Salary)`的列，这样就可以得到不同部门的最高薪水：

        SELECT d.Name as Department, e.Name as Employee, MAX(e.Salary) as Salary
        FROM Employee e INNER JOIN Department d
        ON e.DepartmentId = d.Id
        GROUP BY Department;

    然而，出错了！错误信息如下：

        Input:
                {"headers": {"Employee": ["Id"
                "Name"
                "Salary"
                "DepartmentId"]
                "Department": ["Id"
                "Name"]}
                "rows": {"Employee": [[1
                "Joe"
                60000
                1]
                [4
                "Max"
                60000
                1]]
                "Department": [[1
                "IT"]]}}
        Output:
                {"headers": ["Department", "Employee", "Salary"], "values": [["IT", "Joe", 60000]]}
        Expected:
                {"headers": ["Department", "Employee", "Salary"], "values": [["IT", "Joe", 60000], ["IT", "Max", 60000]]}

    继续分析，从Output和Expected可以看出，题目想要的结果是出现两个最高薪水，分别对应两个不同的Employee，然而我用GROUP BY和MAX只能得到每组的最高薪水。

2. 于是想到：那我先用GROUP BY和MAX找出每组最大的薪水，并把它作为子查询，主查询为WHERE来过滤，Employee和Department还是用内连接，结合讨论区的一些Solution，可以得到上点的改进方法：

        SELECT d.Name as Department, e.Name as Employee, t.Salary
        FROM 
            (
                SELECT DepartmentId, MAX(Salary) as Salary FROM Employee GROUP BY DepartmentId
            ) t,
            Employee e INNER JOIN Department d 
        ON e.DepartmentId = d.Id
        WHERE e.Salary = t.Salary AND e.DepartmentId = t.DepartmentId;

    - Runtime: 605 ms

    - Your runtime beats 99.86% of mysql submissions. 

    - 效率太棒了！（然而后来又submit多次，发现Runtime在600~700ms之间浮动，Rank差别较大，可能大部分的submission都落在这一区间）
    
3. 如果不用内连接，直接使用多表查询：

        SELECT d.Name as Department, e.Name as Employee, t.Salary
        FROM 
            (
                SELECT DepartmentId, MAX(Salary) as Salary FROM Employee GROUP BY DepartmentId
            ) t,
            Employee e, Department d 
        WHERE e.Salary = t.Salary AND e.DepartmentId = t.DepartmentId
        AND e.DepartmentId = d.Id;

    - Runtime: 840 ms

    - Your runtime beats 38.65% of mysql submissions.

    - 效率果然降低了

4. 再来一个Solution，对于主查询的每个Employee，在子查询中都会查找：是否存在该Employee所在的部门（`A.DepartmentId = B.DepartmentId`）中比该Employee的Salary更大（`B.Salary > A.Salary`）的记录。

        SELECT D.Name as Department, A.Name as Employee, A.Salary 
        FROM 
            Employee A INNER JOIN Department D   
        ON A.DepartmentId = D.Id 
        WHERE NOT EXISTS 
          (SELECT 1 FROM Employee B WHERE B.Salary > A.Salary AND A.DepartmentId = B.DepartmentId) 

    - Runtime: 770 ms

    - Your runtime beats 40.62% of mysql submissions.

5. 再来个simple solution：

        SELECT D.Name as Department, A.Name as Employee, A.Salary 
        FROM 
            Employee A INNER JOIN Department D   
        ON A.DepartmentId = D.Id 
        WHERE (A.DepartmentId,A.Salary) in
        (
            SELECT DepartmentId, MAX(Salary) FROM Employee GROUP BY DepartmentId
        );

    - Runtime: 1278 ms

    - Your runtime beats 4.10% of mysql submissions.

#185. Department Top Three Salaries

传送门：    https://leetcode.com/problems/department-top-three-salaries/

###Question：

---

The `Employee` table holds all employees. Every employee has an Id, and there is also a column for the department Id.

    +----+-------+--------+--------------+
    | Id | Name  | Salary | DepartmentId |
    +----+-------+--------+--------------+
    | 1  | Joe   | 70000  | 1            |
    | 2  | Henry | 80000  | 2            |
    | 3  | Sam   | 60000  | 2            |
    | 4  | Max   | 90000  | 1            |
    | 5  | Janet | 69000  | 1            |
    | 6  | Randy | 85000  | 1            |
    +----+-------+--------+--------------+
The `Department` table holds all departments of the company.

+----+----------+
    | Id | Name     |
    +----+----------+
    | 1  | IT       |
    | 2  | Sales    |
    +----+----------+
Write a SQL query to find employees who earn the top three salaries in each of the department. For the above tables, your SQL query should return the following rows.

    +------------+----------+--------+
    | Department | Employee | Salary |
    +------------+----------+--------+
    | IT         | Max      | 90000  |
    | IT         | Randy    | 85000  |
    | IT         | Joe      | 70000  |
    | Sales      | Henry    | 80000  |
    | Sales      | Sam      | 60000  |
    +------------+----------+--------+

---

###分析：

1. 这题与Q184有点像，但是要求是每个部门的前三名，依照Q184的思路，子查询限制3行，然而用in来解决，有如下代码：
        
        SELECT d.Name as Department, e.Name as Employee, e.Salary as Salary
        FROM 
        Employee e INNER JOIN Department d
        ON e.DepartmentId = d.Id
        WHERE Salary in (
            SELECT Salary FROM Employee ee WHERE e.DepartmentId = ee.DepartmentId ORDER BY Salary DESC LIMIT 3
        )
        ORDER BY Department, Salary;

    然而出错了，出错信息如下：

        Runtime Error Message:
        This version of MySQL doesn't yet support 'LIMIT & IN/ALL/ANY/SOME subquery'

    想了很久，还是不得其解，转而求助讨论区:)

2. 先子查询得到每个部门的top3的思路行不通。转而一想，可以主查询中每个记录来执行：对于每个Salary，判断它在子查询是否在top3的记录中，所以有如下solution：

        SELECT d.Name as Department, e.Name as Employee, e.Salary 
        FROM Employee e INNER JOIN Department d  
        ON e.DepartmentId=d.Id 
        WHERE
        (
            SELECT COUNT(DISTINCT Salary) From Employee where DepartmentId=d.Id and Salary>e.Salary
        ) < 3

    - Runtime: 1057 ms

    - Your runtime beats 46.09% of mysql submissions.

#196. Delete Duplicate Emails

传送门：https://leetcode.com/problems/delete-duplicate-emails/

###Question：

---

Write a SQL query to delete all duplicate email entries in a table named `Person`, keeping only unique emails based on its smallest Id.

    +----+------------------+
    | Id | Email            |
    +----+------------------+
    | 1  | john@example.com |
    | 2  | bob@example.com  |
    | 3  | john@example.com |
    +----+------------------+
Id is the primary key column for this table.
For example, after running your query, the above `Person` table should have the following rows:

    +----+------------------+
    | Id | Email            |
    +----+------------------+
    | 1  | john@example.com |
    | 2  | bob@example.com  |
    +----+------------------+

---

###分析：

1. 
