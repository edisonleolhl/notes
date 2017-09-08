> 本文包括：
> 
> 1、分页技术概述
> 
> 2、实现分页
> 
> 3、完善分业——分页工具条
> 
> 4、几种常见的分页工具条

##1、分页技术概述
1. 物理分页

    - 在SQL查询时，从数据库只查询分页需要的数据

    - 通常，对于不同数据库有不同的物理分页语句
    
        >MySQL 使用limit；
        >SQLServer 使用top；
        >Oracle使用rowNum 

    - 对于MySQL，采用limit关键字

    - 例如：查询第11-20条数据，SQL语句：

            select * from user limit 10,10;

    - demo：

            @Test
            public void demo2() throws SQLException {
                // 物理分页 ，根据数据库关键字 limit 查询需要数据 查询150-200条
                String sql = "select * from customer order by name limit ?,?";
                int start = 150 - 1; // 开始索引 开始条数-1
                int len = 200 - 150 + 1; // 结束条数-开始条数 +1
                QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                List<Customer> customers = queryRunner.query(sql,
                        new BeanListHandler<Customer>(Customer.class), start, len);
                System.out.println("size:" + customers.size());
                for (Customer customer : customers) {
                    System.out.println(customer.getName());
                }
            }

2. 逻辑分页

    - 在SQL查询时，先从数据库查询出所有数据的结果集
    - 在Java代码中通过逻辑语句获得分页需要的数据
    - 例如：查询第11-20条数据：
    
            userList.subList(10,20)

    - demo：

            @Test
            public void demo3() throws SQLException {
                // 逻辑分页 150 - 200
                String sql = "select * from customer order by name";
                QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
                List<Customer> customers = queryRunner.query(sql,
                        new BeanListHandler<Customer>(Customer.class));
        
                customers = customers.subList(150 - 1, 200);
                System.out.println("size:" + customers.size());
                for (Customer customer : customers) {
                    System.out.println(customer.getName());
                }
            }

3. 性能上，物理分页明显好于逻辑分页，尽量使用物理分页。

##2、实现分页

1. 分类查询UML图

    ![](http://upload-images.jianshu.io/upload_images/2106579-6386429967327fc6.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    >UML绘制软件：Jude（Java and UML Developer's Environment）
    >
    >Jude教程：http://blog.csdn.net/shesunshine/article/details/5670862

2. 在JSP页面新增a链接，其中pageQuery为PageQueryServlet的URL：

        <a href="XX/pageQuery?pNum=1">分页查询</a>

3. PageQueryServlet：

        public class PageQueryServlet extends HttpServlet {
        
            public void doGet(HttpServletRequest request, HttpServletResponse response)
                    throws ServletException, IOException {
                // 获得客户端提交页码
                String pNumStr = request.getParameter("pNum");
                int pNum = Integer.parseInt(pNumStr);// 如果不是数字报错
        
                // 将页码传递 业务层
                CustomerService customerService = new CustomerService();
                List<Customer> customers = customer Service.pageQuery(pNum);
        
                // 传递结果进行显示
                request.setAttribute("customers", customers); 
                request.getRequestDispatcher("/list.jsp").forward(request,
                        response);
            }
        
            public void doPost(HttpServletRequest request, HttpServletResponse response)
                    throws ServletException, IOException {
                doGet(request, response);
            }
        
        }

4. CustomerService中设置常量、新增pageQuery(int pNum)方法：

        public static final int NUMBERPAGE = 10; // 设置每页条数为常量
        public List<Customer> pageQuery(int pNum){
            // 根绝页码和每页条数计算开始索引
            int start = (pNum - 1) * NUMBERPAGE;
        
            // 调用DAO进行分页查询
            CustomerDAO customerDAO = new CustomerDAO();
            return customerDAO.findByPage(start, NUMBERPAGE);
        }

5. CustomerDAO中新增findByPage(int pNum, int numberPage)方法：

        public List<Customer> findByPage(int start, int numberPage){
            String sql = "select * from customer limit ?,?";
            QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource()); // 利用DBUtils开源工具进行JDBC编程
            try{
                return queryRunner.query(sql,new BeanListHandler<Customer>(Customer.class));
            } catch(SQLException e){
                e.printStackTrace();
            }
            return null;
        }

##3、完善分页——分页工具条
1. 实现分页中的虽然能提供分页，但是需要手动在地址栏输入第几页，这显然对用户极不友好，不过别急，上面只是实现了分页的效果。

2. 很多网站都提供了分页功能，分页页面效果：

    >首页 上一页 1 2 3 4 5 6 7 下一页 尾页 

3. 上面的工具条只适用页数很少的业务，google查询的页数有上万页，不可能全部显示在页面上，也不可能提供“尾页”这个选项，所以以当前页为中心，提供前后5页的跳转链接，下面是一种可借鉴的分页工具条（假设当前页数为10）：

    >上一页 5 6 7 8 9 ***10*** 11 12 13 14 15 下一页

    >谷歌的分页工具条：
    ![](http://upload-images.jianshu.io/upload_images/2106579-02ed83a8a8140309.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

4. 现在一般的做法，分页查询都会用单独类来封装查询结果 
    
    PageBean ----- 在业务层返回数据返回PageBean对象

        public class PageBean {
            public static final int NUMPERPAGE = 10; // 每页多少条
            private int pNum; // 当前第几页
            private int totalPageNum; // 总页数
            private int totalRecordNum; // 总记录数
            private List<Customer> customers; // 结果数据
        
            public int getpNum() {
                return pNum;
            }
        
            public void setpNum(int pNum) {
                this.pNum = pNum;
            }
        
            public int getTotalPageNum() {
                return totalPageNum;
            }
        
            public void setTotalPageNum(int totalPageNum) {
                this.totalPageNum = totalPageNum;
            }
        
            public int getTotalRecordNum() {
                return totalRecordNum;
            }
        
            public void setTotalRecordNum(int totalRecordNum) {
                this.totalRecordNum = totalRecordNum;
            }
        
            public List<Customer> getCustomers() {
                return customers;
            }
        
            public void setCustomers(List<Customer> customers) {
                this.customers = customers;
            }
        
        }

5. 于是，在CustomerService修改pageQuery(int pNum)方法：

        public static final int NUMBERPAGE = 10; // 设置每页条数为常量
        public PageBean pageQuery(int pNum) {
            // 根据页码 和 每页条数 计算开始索引
            int start = (pNum - 1) * NUMPERPAGE;
    
            PageBean bean = new PageBean();
    
            // 封装当前页码
            bean.setpNum(pNum);
    
            // 调用DAO进行分页查询 --- 结果数据
            CustomerDAO customerDAO = new CustomerDAO();
            List<Customer> customers = customerDAO.findByPage(start,
                    PageBean.NUMPERPAGE);
            bean.setCustomers(customers);
    
            // 封装总记录条数，findTotalRecordNum()方法见下文
            int totalRecordNum = customerDAO.findTotalRecordNum();
            bean.setTotalRecordNum(totalRecordNum);
    
            // 计算总页数，很常用！！！
            int totalPageNum = (totalRecordNum + PageBean.NUMPERPAGE - 1)
                    / PageBean.NUMPERPAGE;
            bean.setTotalPageNum(totalPageNum);
    
            return bean;
        }

6. 在CustomerDAO中新增findTotalRecordNum()方法：

        // 查询总记录条数
        public int findTotalRecordNum() {
            String sql = "select count(*) from customer";
            QueryRunner queryRunner = new QueryRunner(JDBCUtils.getDataSource());
            // ScalarHandler
            try {
                // 因为结果集只有一行一列，所以这里应该用ScalarHandler
                long totalRecordNum = (Long) queryRunner.query(sql,
                        new ScalarHandler(1));
                return (int) totalRecordNum; // int表示的范围足够了
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return 0;
        }

7. 于是，在PageQueryServlet中修改：

    修改前：

        List<Customer> customers = customer Service.pageQuery(pNum);

        // 传递结果进行显示
        request.setAttribute("customers", customers); 
        request.getRequestDispatcher("/list.jsp").forward(request,
                response);

    修改后：

        PageBean pageBean = customerService.pageQuery(pNum);

        // 传递结果进行显示
        request.setAttribute("pageBean", pageBean); // ${pageBean}
        request.getRequestDispatcher("/page_list.jsp").forward(request,
                response);

8. 接下来就是编写JSP页面：

    - 预期效果：
        
        ![](http://i.imgur.com/6derC8y.png)

    - 实现*首页 上一页*

                <!-- 显示首页 -->
                <c:if test="${pageBean.pNum == 1}">
                    首页  上一页
                </c:if>
                <c:if test="${pageBean.pNum != 1}">
                    <a href="/pageQuery?pNum=1">首页</a>
                    <a href="/pageQuery?pNum=${pageBean.pNum-1 }">上一页</a>
                </c:if>

    - 实现*下一页 尾页*

                <!-- 显示尾页 -->
                <c:if test="${pageBean.pNum == pageBean.totalPageNum}">
                    下一页 尾页
                </c:if>
                <c:if test="${pageBean.pNum != pageBean.totalPageNum}">
                    <a href="/pageQuery?pNum=${pageBean.pNum + 1 }">下一页</a>
                    <a href="/pageQuery?pNum=${pageBean.totalPageNum}">尾页</a>
                </c:if>

    - 实现 *5 6 7 8 9 10 11 12 13 14 ***15*** 16 17 18 19 20 21 22 23 24 25*

                <!-- 当前页为中心前后各显示10页 -->
                <c:set var="begin" value="1" scope="page" />
                <c:set var="end" value="${pageBean.totalPageNum}" scope="page" />
                
                <!-- 判断前面有没有10页 -->
                <c:if test="${pageBean.pNum-10>0}">
                    <c:set var="begin" value="${pageBean.pNum-10}" scope="page" />
                </c:if>
                
                <!-- 判断后面有没有10页 -->
                <c:if test="${pageBean.pNum+10 < pageBean.totalPageNum}">
                    <c:set var="end" value="${pageBean.pNum + 10}" scope="page" />
                </c:if>

                <!-- 利用foreach循环输出 -->
                <c:forEach begin="${begin}" end="${end}" var="i">
                    <a href="/pageQuery?pNum=${i }">${i } </a>
                </c:forEach>

    - 至此基本功能完成，但是显示的效果很差：

        ![](http://upload-images.jianshu.io/upload_images/2106579-cde6537645e20d37.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    - 现在的问题是：根本不知道哪个是当前页，所以还要改进一下foreach中的代码：

                <!-- 当前页不显示链接，即可知道哪个是当前页 -->
                <!-- 利用foreach循环输出 -->
                <c:forEach begin="${begin}" end="${end}" var="i">
                    <c:if test="${pageBean.pNum==i}">
                        ${i }
                    </c:if>
                    <c:if test="${pageBean.pNum!=i}">
                        <a href="/pageQuery?pNum=${i }">${i } </a>
                    </c:if>    
                </c:forEach>

    - 现在即可清晰的显示当前页了（可用CSS/JavaScript进一步美化界面，功能实现到此为止）

        ![](http://upload-images.jianshu.io/upload_images/2106579-32a7b475b4000b7c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    - 实现输入页码跳转，在尾页代码的后面加入input：
    
                <input type="text" id="pNum" size="2"/><input type="button" value="go" onclick="jump();"/>

        对应的JavaScript代码：

            <script type="text/javascript">
                function jump(){
                    // 获得用户输入页码
                    var pNum = document.getElementById("pNum").value;
                    location.href="/pageQuery?pNum=" + pNum;
                }
            </script>

##4、几种常见的分页工具条
- 百度

    ![](http://upload-images.jianshu.io/upload_images/2106579-7bd1001830a49659.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
    ![](http://upload-images.jianshu.io/upload_images/2106579-b03142c5935e8912.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
    
    强迫症看着难受，为什么前面显示5页，后面显示4页？？？

- 必应

    ![](http://upload-images.jianshu.io/upload_images/2106579-ea4b7e7488536a58.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
    ![](http://upload-images.jianshu.io/upload_images/2106579-5bdc902141f6544a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    必应的分页工具条很简洁。

- CSDN博客：http://blog.csdn.net/

    ![](http://upload-images.jianshu.io/upload_images/2106579-dd5e863a2757a8e3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
    ![](http://upload-images.jianshu.io/upload_images/2106579-298bcc14857333c7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    这种分页工具栏比较有意思，我们来分析一下：

    - 利用Chrome浏览器的检查功能：

    ![](http://upload-images.jianshu.io/upload_images/2106579-e4a7d73f7351b3ce.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    - 它的分页工具条只显示5页，最左边的页码是`m*5+1 (m为非负整数)`，最右边的页码是`(m+1)*5`，点击左侧的`...`，上述的`m`变为`m-1`，点击右侧的`...`，上述的`m`变为`m+1`。

    - 它的重点在于计算当前页所属的`m`值，稍微思考一下，可以得出当前页`pNum`与当前页所属的`m`值的关系：

            int m = pNum/5;

    - 注意分页工具条左侧的`...`，当前页为6时，它会跳转到第1页，所以无论是左侧还是右侧的`...`，都将会跳转到对应`m`值的第1页。
