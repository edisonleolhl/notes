# ryu备忘录

## 官网资料

## 第四届 SDN 大赛比赛细节

- 为了方便管理网络拓扑，ryu 控制器里使用了开源的 networkx 模块，这个模块更新速度较快，文档也很全面，功能强大，地址：https://networkx.github.io

- nx 模块很多集成好的算法函数，直接调用即可，但是要注意，有些函数的返回值是生成器（generator），而不是字典（dict）。要用 dict() 转化。但是很奇怪，当时比赛的时候写的代码，没有加 dict() 也没报错，半年后重新搭了环境，移植项目再运行后，报错，猜想可能是 networkx 模块更新了。

    > self.shortest_paths = dict(nx.all_pairs_dijkstra_path(self.graph))

## 用户可定义网络

- 每个用户可以实时看到本机到达服务器的所有路径，可以从中选择一条路径，通知服务器，服务器为其选择路径上的所有交换机下发相应流表。

- 在 Ubuntu 操作系统上编写一个基于 Python 的界面程序。

- 实现原理：

    - 后端用定时器定时发送 REST API 给 ryu 控制器，ryu 通过 user_query_path_api 返回所有 available path。前端用列表形式显示这些 available path。

    - 用户选择一条路径，点击确定后，再发送 REST API 给 ryu，ryu 为这条路径上的交换机下发对应流表。

### 主机与控制器通信

- ryu 与 mininet 连接，如想在 ryu 控制器端开启 REST API 服务，在 mininet 中创建的某台主机 h1，若想主机与控制器通信（通过REST API），试了很多次，总是失败：

    ![2018326-curlfail](http://ooy7h5h7x.bkt.clouddn.com/blog/image/2018326-curlfail.png)


- 后来经过查询资料，为了实现 h1 与 ryu 控制器的通信，则需要加入 nat 技术，虚拟创建了 nat0 节点，让 h1 与 nat0 互相访问通信，从而使得 h1 可以与 ryu 可以通信，步骤如下：

    在 mininet 创建拓扑命令时，记得加入 --nat 参数，比如：

        sudo mn --custom sw5host3.py --topo mytopo --controller=remote --mac --switch ovs,protocols=OpenFlow13 --link tc --nat

    此时用 ifconfig 命令可以看到 nat0 的 IP 地址：

    ![2018326-natip](http://ooy7h5h7x.bkt.clouddn.com/blog/image/2018326-natip.png)


    终端上输入：

        mininet> xterm h1

    在打开的 h1 终端上输入，可以清楚地看到有返回值，即 5 台交换机：

    ![2018326-h1rest](http://ooy7h5h7x.bkt.clouddn.com/blog/image/2018326-h1rest.png)

    IP 地址是 nat0 的 IP 地址，这里不能填 localhost ，也不能填 0.0.0.0，也不能填 127.0.0.0，也不能填本机 IP 地址 192.168.2.140。

    wsgi 监听 8080 端口，可以在 ryu/ryu/app/wsgi.py 中修改默认端口。

### 控制器知道哪台主机发送 REST API

- 控制器端的 wsgi server 需要分辨是哪台主机发送了 REST API 请求，默认情况下，终端输出了发起请求的客户端的 IP 和 port，如下：

        (64375) accepted ('10.0.0.1', 40584)

    但，如何在代码中找到并且使用呢？

    为了研究 wsgi 的原理，自己创建一个 wsgi test 文件，用本地浏览器测试，打印 environ 变量，部分字段值如下：

        {
            'HTTP_ACCEPT': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'HTTP_ACCEPT_ENCODING': 'gzip, deflate',
            'HTTP_ACCEPT_LANGUAGE': 'en-US,en;q=0.5',
            'HTTP_CONNECTION': 'keep-alive',
            'HTTP_HOST': 'localhost:8080',
            'HTTP_UPGRADE_INSECURE_REQUESTS': '1',
            'HTTP_USER_AGENT': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:54.0) Gecko/20100101 Firefox/54.0',
            ...
            'REMOTE_ADDR': '127.0.0.1',
            'REMOTE_HOST': 'localhost',
            'REQUEST_METHOD': 'GET',
            'SERVER_NAME': 'localhost',
            'SERVER_PORT': '8080',
        }

    嗯，好像 environ 这个东西挺游泳的，回到我们的 app，自定义 REST API，命名为：user_query_path_api，先测试一下 req 这个对象中是否包含 REST 请求的来源 IP ：

        class NetworkController(ControllerBase):
            def __init__(self, req, link, data, **config):
                super(NetworkController, self).__init__(req, link, data, **config)
                self.network_app = data[network_instance_name]

            @route('network', '/network/path', methods=['GET'])
            def user_query_path_api(self, req, **kwargs):
                network = self.network_app
                try:
                    print(req)
                    body = json.dumps()
                    return Response(content_type='application/json', body=body)
                except Exception as e:
                    return Response(status=500)

    利用 Firefox 浏览器的 HttpRequest 插件发起 GET 请求，ryu 终端输出如下：

        GET /network/path HTTP/1.0
        Accept: */*
        Accept-Encoding: gzip, deflate
        Accept-Language: en-US,en;q=0.5
        Connection: keep-alive
        Content-Type: text/plain
        Host: localhost:8080
        User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:54.0) Gecko/20100101 Firefox/54.0
        127.0.0.1 - - [26/Mar/2018 00:55:10] "GET /network/path HTTP/1.1" 500 158 0.000706

    好像这个 req 和 environ 不太一样，属性少了很多（后来才发现很多属性都是作为属性方法存在的），但，可以注意到中间的 Host 字段，也许是我们要找的，接下来，用 mininet 中的 h1 发起 curl 命令，构造同样的 GET 请求，ryu 终端输出如下：

        (64375) accepted ('10.0.0.1', 40584)
        GET /network/path HTTP/1.0
        Accept: */*
        Content-Type: text/plain
        Host: 10.0.0.4:8080
        User-Agent: curl/7.47.0
        10.0.0.1 - - [26/Mar/2018 00:55:35] "GET /network/path HTTP/1.1" 500 134 0.002788

    新的问题又出现了，上述步骤的确可以知道 req 的来源 IP，但是用 h1(10.0.0.1) 发起 REST API 请求，请求转发给了 nat0(10.0.0.4)，于是 req 的 host 字段是 10.0.0.4，我们是想知道 h1 的 IP 地址呀。

    但是监听端口又可以知道是 10.0.0.1，这两行很奇怪：

        (65716) accepted ('10.0.0.1', 49472)
        10.0.0.4 (1, 5)

    也许，我们得找第一行的代码出现在哪，下次再找吧，吃饭去。。

---

- ### 踩坑预警 （这节内容可以跳过，因为最后没有用到）

    上文提到到了，ryu 的服务器端使用了 wsgi，其实 wsgi 里面又使用了 eventlet 模块，看介绍：

    > Eventlet is a concurrent networking library for Python that allows you to change how you run your code, not how you write it.
    >
    > It uses epoll or kqueue or libevent for highly scalable non-blocking I/O.
    Coroutines ensure that the developer uses a blocking style of programming that is similar to threading, but provide the benefits of non-blocking I/O.
    > 
    > The event dispatch is implicit, which means you can easily use Eventlet from the Python interpreter, or as a small part of a larger application.

    现在的思路就是顺着 wsgi 的启动去找输出嘛，通过这篇博文 http://www.muzixing.com/pages/2015/05/13/ryuzhong-wsgixue-xi-bi-ji-yu-restapikai-fa.html 。顺着思路，先从 ryu/ryu/app/wsgi.py 找到了  ryu/lib/hub.py 再继续找到了 eventlet/wsgi.py，在 server 函数中找到了这样一行代码：

            serv.log.info("(%s) wsgi starting up on %s" % (

    是不是很熟悉的感觉？这就是 ryu 启动 wsgi 服务的时候，终端输出的内容，一般情况是这样的：

        lhl@ubuntu:~/Desktop/network$ ryu-manager network.py /home/lhl/ryu/ryu/app/ofctl_rest.py --observe-links --weight=bw
        loading app network.py
        loading app /home/lhl/ryu/ryu/app/ofctl_rest.py
        loading app ryu.topology.switches
        loading app ryu.controller.ofp_handler
        instantiating app None of DPSet
        creating context dpset
        creating context wsgi
        instantiating app network.py of NetworkAwareness
        instantiating app ryu.topology.switches of Switches
        instantiating app ryu.controller.ofp_handler of OFPHandler
        instantiating app /home/lhl/ryu/ryu/app/ofctl_rest.py of RestStatsApi
        (114397) wsgi starting up on http://0.0.0.0:8080
        ...

    再往下看，发现了 accepted 字符串：

        serv.log.info("(%s) wsgi starting up on %s" % (
            serv.pid, socket_repr(sock)))
        while is_accepting:
            try:
                client_socket = sock.accept()
                client_socket[0].settimeout(serv.socket_timeout)
                serv.log.debug("(%s) accepted %r" % (
                    serv.pid, client_socket[1]))
                try:
                    pool.spawn_n(serv.process_request, client_socket)
                except AttributeError:
                    warnings.warn("wsgi's pool should be an instance of "
                                  "eventlet.greenpool.GreenPool, is %s. Please convert your"
                                  " call site to use GreenPool instead" % type(pool),
                                  DeprecationWarning, stacklevel=2)
                    pool.execute_async(serv.process_request, client_socket)
            except ACCEPT_EXCEPTIONS as e:
                if support.get_errno(e) not in ACCEPT_ERRNO:
                    raise
            except (KeyboardInterrupt, SystemExit):
                serv.log.info("wsgi exiting")
                break

    很好，接下来就是在自己开发的 app 中访问这里的 client_socket 。

--- 

- 前文，在研究 req 对象时，我们直接把它放在 print 中输出，结果如下：

        GET /network/path HTTP/1.0
        Accept: */*
        Accept-Encoding: gzip, deflate
        Accept-Language: en-US,en;q=0.5
        Connection: keep-alive
        Content-Type: text/plain
        Host: localhost:8080
        User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:54.0) Gecko/20100101 Firefox/54.0

    当时看到只有这些字段，就没深究了，其实 req 对象还有很多属性方法，源码追溯，来到了 webob/request.py ，在这里有一个 BaseRequest 类，其实 req 类就是来自于这里，在这个类中找到了如下属性方法：

        class BaseRequest(object):

            ...

            @property
            def client_addr(self):
                """
                The effective client IP address as a string.  If the
                ``HTTP_X_FORWARDED_FOR`` header exists in the WSGI environ, this
                attribute returns the client IP address present in that header
                (e.g. if the header value is ``192.168.1.1, 192.168.1.2``, the value
                will be ``192.168.1.1``). If no ``HTTP_X_FORWARDED_FOR`` header is
                present in the environ at all, this attribute will return the value
                of the ``REMOTE_ADDR`` header.  If the ``REMOTE_ADDR`` header is
                unset, this attribute will return the value ``None``.

                .. warning::

                It is possible for user agents to put someone else's IP or just
                any string in ``HTTP_X_FORWARDED_FOR`` as it is a normal HTTP
                header. Forward proxies can also provide incorrect values (private
                IP addresses etc).  You cannot "blindly" trust the result of this
                method to provide you with valid data unless you're certain that
                ``HTTP_X_FORWARDED_FOR`` has the correct values.  The WSGI server
                must be behind a trusted proxy for this to be true.
                """
                e = self.environ
                xff = e.get('HTTP_X_FORWARDED_FOR')
                if xff is not None:
                    addr = xff.split(',')[0].strip()
                else:
                    addr = e.get('REMOTE_ADDR')
                return addr

            ...

    在自定义 app 中输出 req.client_addr 试试吧，结果符合预期：

        (115045) accepted ('10.0.0.1', 59900)
        10.0.0.1
        10.0.0.1 - - [26/Mar/2018 19:34:37] "GET /network/path HTTP/1.1" 200 124 0.015283

- 两个 API 已经开发好了：

        # only for user(host terminal)
        # curl -X GET http://<nat0ip>:8080/network/querypath
        # no parameters, easy to use
        @route('network', '/network/querypath', methods=['GET'])
        def user_query_path_api(self, req, **kwargs):
            ...
            
        # only for user(host terminal)
        # curl -X -PUT -d '{"dst_ip":"10.0.0.3", "path":"[1,3,4,5]"}' http://<nat0ip>:8080/network/choosepath
        # notice that there is no blank space in [1,3,4,5],
        # otherwise decode error, status code 404
        @route('network', '/network/choosepath', methods=['PUT'])
        def user_choose_path_api(self, req, **kwargs):
            ...

- 既然已经拿到了客户的 IP 地址，也就是知道了哪个用户需要自定义路由，这个 API 返回的是到其他主机的所有路径。

    > 因为在 access_table 中有 nat0 的 IP 地址，所以要去除掉，req.host 返回的就是 nat0 的 IP 地址，正好可以用到。

    用到了 networkx 模块的 shortest_simple_paths(G, source, target, weight=None) 函数，介绍：https://networkx.github.io/documentation/stable/reference/algorithms/generated/networkx.algorithms.simple_paths.shortest_simple_paths.html#networkx-algorithms-simple-paths-shortest-simple-paths

---
- 用户选路的问题解决了，但是如何用 QOS 限流？ example 跑的结果符合预期，但是放在自己的 app 和 topo 中，一直没有体现出 example 里的效果，肯定是哪里没有理解对，需要小小的修改一些地方。

---
4.4 开工，发现ping不通，查询，发现packet_in_handler根本没有输出，也就是说没有进入到packet_in_handler函数里面，mininet无论是自定拓扑（sw5h3.py），还是默认拓扑（sw1host2），都无法进入packet_in_handler函数，然而运行ryu的example是可以进入packet_in_handler的。

傍晚发现，packet_in_handler可以使用了，真是玄学。
但是h3与h1、h2隔离了，是因为不在同一个交换机上的缘故吗

---
4.8 开工
重新按照复赛报告书的流程重新修改了 ryu 的源码， 重新安装 ryu，再运行，加了 --nat 后的 mininet 拓扑 h1 h2 h3 nat0 两两可通！
用户查询路径的 API 测试还是可用的，但是有点小问题，h1 到 h3 的路径为空？

        root@ubuntu:~/Desktop/network# curl -X GET http://10.0.0.4:8080/network/querypath
        {"10.0.0.1-10.0.0.3": [], "10.0.0.1-10.0.0.2": [[1]]}

先去吃个晚饭，下次再干。

---
4.9 开工
虽然查路 API 中没法显示 h1 - h3，但是选路 API 却是可以可用的，也就是说，本来根据最短路径算法 h1 - h3 的最短路径是交换机 1 2 5，现在选路为 1 3 4 5，同时在 s2 s3 s4 上利用 tcpdump 命令抓包，发现本来是只有 s2 抓到了包，用户选路后只有 s3 s4 抓到了包。

看来问题出现在选路 API 中的 get_all_path 函数中。

经过不断 debug 后，发现当 weight=hop 时，就会出现 empty list，而 weight=bandwidth 时，就会完整的出现 available_paths。

解决方案：在 weight=hop 时 调用默认权重，即可解决 empty list 的问题，具体原理未知

    def get_shortest_simple_paths(self, src, dst):
        simple_paths = []
        try:
            if self.weight == self.WEIGHT_MODEL['hop']:
                simple_paths = list(nx.shortest_simple_paths(self.graph, src, dst))
            elif self.weight == self.WEIGHT_MODEL['bandwidth']:
                simple_paths = list(nx.shortest_simple_paths(self.graph, src, dst, weight='bandwidth'))
            elif self.weight == self.WEIGHT_MODEL['delay']:
                simple_paths = list(nx.shortest_simple_paths(self.graph, src, dst, weight='delay'))
        except Exception as e:
            print e
        return simple_paths 


总算回到之前的进度了，接下来继续干 qos 限速的问题吧！

---
4.11 
因为研究 qos 无进展，打算重启虚拟机试试，又出现了之前的 packet_in 都无法执行的问题了，这下学聪明了，先运行以下 ryu/app/simple_switch_13.py ，连接 mininet 后，有很多的 packet in 消息，关闭后再打开 network.py，一切正常。继续干 qos