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

### 难点：主机与控制器通信

- ryu 与 mininet 连接，如想在 ryu 控制器端开启 REST API 服务，在 mininet 中创建的某台主机 h1，若想主机与控制器通信（通过REST API），试了很多次，总是失败：

    ![2018326-curlfail](http://ooy7h5h7x.bkt.clouddn.com/blog/image/2018326-curlfail.png)


- 后来经过查询资料，为了实现 h1 与 ryu 控制器的通信，则需要加入 nat 技术，虚拟创建了 nat0 节点，让 h1 与 nat0 互相访问通信，从而使得 h1 可以与 ryu 可以通信，步骤如下：

    在 mininet 创建拓扑命令时，记得加入 --nat 参数，比如：

    ```shell
    sudo mn --custom sw5host3.py --topo mytopo --controller=remote --mac --switch ovs,protocols=OpenFlow13 --link tc --nat
    ```

    此时用 ifconfig 命令可以看到 nat0 的 IP 地址：

    ![2018326-natip](http://ooy7h5h7x.bkt.clouddn.com/blog/image/2018326-natip.png)

    终端上输入：
    ​    
    ```
    mininet> xterm h1
    ```

    在打开的 h1 终端上输入，可以清楚地看到有返回值，即 5 台交换机：
    ​    
    ![2018326-h1rest](http://ooy7h5h7x.bkt.clouddn.com/blog/image/2018326-h1rest.png)

    IP 地址是 nat0 的 IP 地址，这里不能填 localhost ，也不能填 0.0.0.0，也不能填 127.0.0.0，也不能填本机 IP 地址 192.168.2.140。    

    wsgi 监听 8080 端口，可以在 ryu/ryu/app/wsgi.py 中修改默认端口。

### 重点：控制器知道哪台主机发送 REST API

- 控制器端的 wsgi server 需要分辨是哪台主机发送了 REST API 请求，默认情况下，终端输出了发起请求的客户端的 IP 和 port，如下：

    ```shell
    (64375) accepted ('10.0.0.1', 40584)
    ```

    但，如何在代码中找到并且使用呢？

    为了研究 wsgi 的原理，自己创建一个 wsgi test 文件，用本地浏览器测试，打印 environ 变量，部分字段值如下：

    ```shell
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
    ```

    嗯，好像 environ 这个东西挺有用的，回到我们的 app，自定义 REST API，命名为：user_query_path_api，先测试一下 req 这个对象中是否包含 REST 请求的来源 IP ：

    ```python
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
    ```

    利用 Firefox 浏览器的 HttpRequest 插件发起 GET 请求，ryu 终端输出如下：

    ```shell
    GET /network/path HTTP/1.0
    Accept: */*
    Accept-Encoding: gzip, deflate
    Accept-Language: en-US,en;q=0.5
    Connection: keep-alive
    Content-Type: text/plain
    Host: localhost:8080
    User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:54.0) Gecko/20100101 Firefox/54.0
    127.0.0.1 - - [26/Mar/2018 00:55:10] "GET /network/path HTTP/1.1" 500 158 0.000706
    ```

    好像这个 req 和 environ 不太一样，属性少了很多（后来才发现很多属性都是作为属性方法存在的），但，可以注意到中间的 Host 字段，也许是我们要找的，接下来，用 mininet 中的 h1 发起 curl 命令，构造同样的 GET 请求，ryu 终端输出如下：

    ```shell
    (64375) accepted ('10.0.0.1', 40584)
    GET /network/path HTTP/1.0
    Accept: */*
    Content-Type: text/plain
    Host: 10.0.0.4:8080
    User-Agent: curl/7.47.0
    10.0.0.1 - - [26/Mar/2018 00:55:35] "GET /network/path HTTP/1.1" 500 134 0.002788
    ```

    新的问题又出现了，上述步骤的确可以知道 req 的来源 IP，但是用 h1(10.0.0.1) 发起 REST API 请求，请求转发给了 nat0(10.0.0.4)，于是 req 的 host 字段是 10.0.0.4，我们是想知道 h1 的 IP 地址呀。

    但是监听端口又可以知道是 10.0.0.1，这两行很奇怪：

    ```shell
    (65716) accepted ('10.0.0.1', 49472)
    10.0.0.4 (1, 5)
    ```

    也许，我们得找第一行的代码出现在哪，下次再找吧，吃饭去。。

---

- 紧接前文，在研究 req 对象时，我们直接把它放在 print 中输出，结果如下：

    ```shell
    GET /network/path HTTP/1.0
    Accept: */*
    Accept-Encoding: gzip, deflate
    Accept-Language: en-US,en;q=0.5
    Connection: keep-alive
    Content-Type: text/plain
    Host: localhost:8080
    User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:54.0) Gecko/20100101 Firefox/54.0
    ```

    当时看到只有这些字段，就没深究了，其实 req 对象还有很多属性方法，源码追溯，来到了 webob/request.py ，在这里有一个 BaseRequest 类，其实 req 类就是来自于这里，在这个类中找到了如下属性方法：

    ```python
    class BaseRequest(object):
    
        ...
    
        @property
        def client_addr(self):
    			 ...
            e = self.environ
            xff = e.get('HTTP_X_FORWARDED_FOR')
            if xff is not None:
                addr = xff.split(',')[0].strip()
            else:
                addr = e.get('REMOTE_ADDR')
            return addr
    
        ...
    ```

    在自定义 app 中输出 req.client_addr 试试吧，发现就是这个！

    ```shell
    (115045) accepted ('10.0.0.1', 59900)
    10.0.0.1
    10.0.0.1 - - [26/Mar/2018 19:34:37] "GET /network/path HTTP/1.1" 200 124 0.015283
    ```
### 重点：开发两个 API

- 于是着手开发两个 API ，已经成功了，根据官网的教程，需要引入两个新的文件 rest_qos.py 和 rest_conf_switch.py，为了调试方便，需要引入 ofctl_rest.py 启动应用的命令为：

    ```shell
    lhl@ubuntu:~/Desktop/network$ ryu-manager network.py rest_qos.py rest_conf_switch.py ofctl_rest.py --observe-links --weight=hop
    ```

- xterm h1，输入以下命令调用用户查路 API：

    ```shell
    root@ubuntu:/home/lhl/Desktop/network# curl -X GET http://10.0.0.4:8080/network
    /querypath
    {"10.0.0.1-10.0.0.3": [[1, 2, 5], [1, 3, 4, 5]], "10.0.0.1-10.0.0.2": [[1]]}
    ```

- 默认情况下，h1 到 h3 肯定是走 [1,2,5] 的路径，所以调用用户选路 API，走 [1,3,4,5] 的路径：

    ```
    curl -X PUT -d '{"dst_ip":"10.0.0.3", "path":"[1,3,4,5]"}' http://10.0.0.4:8080/network/choosepath

    ```

- 于是开发出了用户查路 API 以及用户选路 API，放个缩写代码：

    ```python
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
    ```

    既然已经拿到了客户的 IP 地址，也就是知道了哪个用户需要自定义路由，这个 API 返回的是到其他主机的所有路径。

  > 因为在 access_table 中有 nat0 的 IP 地址，所以要去除掉，req.host 返回的就是 nat0 的 IP 地址，正好可以用到。

  	用到了 networkx 模块的 shortest_simple_paths(G, source, target, weight=None) 函数，介绍：https://networkx.github.io/documentation/stable/reference/algorithms/generated/networkx.algorithms.simple_paths.shortest_simple_paths.html#networkx-algorithms-simple-paths-shortest-simple-paths

---

- 用户选路的问题解决了，但是如何用 QOS 限流？ example 跑的结果符合预期，但是放在自己的 app 和 topo 中，一直没有体现出 example 里的效果，肯定是哪里没有理解对，需要小小的修改一些地方。


    而且，在使用qos之前，要先开启 ovsdb ，连接 OpenFlow 交换机到 ovsdb， 设定 queue 等操作，集成在了 enable_qos.sh 中，在命令行直接打开即可：

    ```shell
    lhl@ubuntu:~/Desktop/network$ sudo ./enable_qos.sh 
    ```

    为了调试方便，也集成了关闭操作，打开 remove_qos.sh 文件即可：

    ```shell
    lhl@ubuntu:~/Desktop/network$ sudo ./remove_qos.sh 
    ```

- ryu book: https://osrg.github.io/ryu-book/en/html/rest_qos.html

---
4.4 开工，发现ping不通，查询，发现packet_in_handler根本没有输出，也就是说没有进入到packet_in_handler函数里面，mininet无论是自定拓扑（sw5h3.py），还是默认拓扑（sw1host2），都无法进入packet_in_handler函数，然而运行ryu的example是可以进入packet_in_handler的。

傍晚发现，packet_in_handler可以使用了，真是玄学。
但是h3与h1、h2隔离了，是因为不在同一个交换机上的缘故吗

---
4.8 开工
重新按照复赛报告书的流程重新修改了 ryu 的源码， 重新安装 ryu，再运行，加了 --nat 后的 mininet 拓扑 h1 h2 h3 nat0 两两可通！
用户查询路径的 API 测试还是可用的，但是有点小问题，h1 到 h3 的路径为空？

```shell
root@ubuntu:~/Desktop/network# curl -X GET http://10.0.0.4:8080/network/querypath
{"10.0.0.1-10.0.0.3": [], "10.0.0.1-10.0.0.2": [[1]]}
```

先去吃个晚饭，下次再干。

---
4.9 开工
虽然查路 API 中没法显示 h1 - h3，但是选路 API 却是可以可用的，也就是说，本来根据最短路径算法 h1 - h3 的最短路径是交换机 1 2 5，现在选路为 1 3 4 5，同时在 s2 s3 s4 上利用 tcpdump 命令抓包，发现本来是只有 s2 抓到了包，用户选路后只有 s3 s4 抓到了包，这证明选路 API 运行良好。

看来问题出现在选路 API 中的 get_all_path 函数中。

经过不断 debug 后，发现当 weight=hop 时，就会出现 empty list，而 weight=bandwidth 时，就会完整的出现 available_paths。

解决方案：在 weight=hop 时 调用默认权重，即可解决 empty list 的问题，具体原理未知

```python
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
```


总算回到之前的进度了，接下来继续干 qos 限速的问题吧！

---
4.11 
因为研究 qos 无进展，打算重启虚拟机试试，又出现了之前的 packet_in 都无法执行的问题了，这下学聪明了，先运行 ryu/app/simple_switch_13.py ，即

    ryu-manager ryu.app.rest_qos ryu.app.qos_simple_switch_13 ryu.app.rest_conf_switch

连接 mininet 后，有很多的 packet in 消息，关闭后再打开 network.py，一切正常。继续干 qos

---

5.14返工

撸完毕设论文，继续工作，第一次进入还是全都ping不通，运行示例ryu/app/simple_switch_13.py，再重新安装后就解决这个问题了。

经验证， 两个API都运行成功。

但是，pingall中h3被隔离了，似乎和之前的现象一样，后来解决了，过程如下：刚才重新安装ryu后，mininet并没有重启，发现pingall中h3被隔离后，重启了mininet，在启动network应用时加上了 --weight=hop 的参数，重新运行发现全都可以了！回到以前的工作进度了。

---

9.17返工

刚开始又碰到了ping不通的问题，把所有模块重新启动后又可以了。
查路、选路API均可用

好了，又到了晚饭时间了，等会撸铁去，下次再干！

---

9.18返工

network app 中若 verifying the setting 中的 REST API，则会报错，原因未知，跟着官方的例子跑跑试试看。

照着example跑了一下，有点问题，5002端口竟然也是限速500kb/s以内，而不是期望的大于800kb/s。

还注意到，此时跟着example中“verifying the setting”这节，调用curl命令返回的数据中竟然nw_dst为10.0.0.2？前面的步骤一模一样，特别是“Qos Setting”这节，仔细检查了，为10.0.0.1，真奇怪。

---

11.8返工

先运行一下官方example试试：

```
lhl@ubuntu:~/ryu/ryu/app$ ryu-manager ryu.app.rest_qos ryu.app.qos_simple_switch_13 ryu.app.rest_conf_switch
```

在verifying the setting这节，输出与预期的一样。

在Measuring the bandwidth这节，输出与预期一样！一个的带宽最大值限制在500Kb/s，一个的带宽最小值限制在800Kb/s。因为在xterm上iperf测量TCP带宽为500Mb/s，所以上述两次测量同时进行好像也没什么影响。

接下来运行自己的app：

```
lhl@ubuntu:~/Desktop/network$ ryu-manager network.py rest_qos.py rest_conf_switch.py ofctl_rest.py --observe-links --weight=hop
```

在verifying the setting这节，报错：

```
(14441) accepted ('127.0.0.1', 42964)
awareness: Exception occurred during handler processing. Backtrace from offending handler [_flow_stats_reply_handler] servicing event [EventOFPFlowStatsReply] follows.
Traceback (most recent call last):
  File "/usr/local/lib/python2.7/dist-packages/ryu/base/app_manager.py", line 290, in _event_loop
    handler(ev)
  File "/home/lhl/Desktop/network/network.py", line 312, in _flow_stats_reply_handler
    self.stats['flow'][dpid] = body
KeyError: 'flow'
Traceback (most recent call last):
...
127.0.0.1 - - [07/Nov/2018 22:26:54] "GET /qos/rules/0000000000000001 HTTP/1.1" 500 1663 0.148330

```

看上去好像 self.stats的flow属性没有定义？查看了一下network app，这个属性定义有个前提条件，那就是在路由规则为bandwidth，运行时是用hop的，改一下路由规则试试。

没想到一进入就报错了，在verifying the setting这节也是报错了，但是flow没有报错，两者都是在in_port报错的：

``` 
(15062) accepted ('127.0.0.1', 43048)
awareness: Exception occurred during handler processing. Backtrace from offending handler [_flow_stats_reply_handler] servicing event [EventOFPFlowStatsReply] follows.
Traceback (most recent call last):
  File "/usr/local/lib/python2.7/dist-packages/ryu/base/app_manager.py", line 290, in _event_loop
    handler(ev)
  File "/home/lhl/Desktop/network/network.py", line 318, in _flow_stats_reply_handler
    key = (stat.match['in_port'], stat.match['ipv4_dst'],
  File "/usr/local/lib/python2.7/dist-packages/ryu/ofproto/ofproto_v1_3_parser.py", line 902, in __getitem__
    return dict(self._fields2)[key]
KeyError: 'in_port'
Traceback (most recent call last):

```

试试不用rest qos的app，换回毕设的app，发现in_port那还是一样的报错，试试看print这个stat结构：

``` 
OFPFlowStats(byte_count=2546208,cookie=1,duration_nsec=583000000,duration_sec=8239,flags=0,hard_timeout=0,idle_timeout=0,instructions=[OFPInstructionActions(actions=[OFPActionSetQueue(len=8,queue_id=1,type=21)],len=16,type=4), OFPInstructionGotoTable(len=8,table_id=1,type=1)],length=104,match=OFPMatch(oxm_fields={'ip_proto': 17, 'udp_dst': 5002, 'eth_type': 2048, 'ipv4_dst': '10.0.0.1'}),packet_count=1684,priority=1,table_id=0)

```

根本就没有in_port这个结构，我记得以前是肯定有的，muzixing那也是这样做的，肯定没问题，突然想到我现在mininet拓扑结构是默认的h1-s1-h2，会不会直接把端口给省略了？

好，现在试试重启Mininet，然后发现ping不通了。

如果发现ping不通的玄学问题，run一遍官方example即可！

``` 
lhl@ubuntu:~/ryu/ryu/app$ ryu-manager simple_switch_13.py --observe-links
```

好的，现在换回自己的app，启动默认mininet，发现现在报错的是ipv4_dst：

``` 
OFPFlowStats(byte_count=714,cookie=0,duration_nsec=514000000,duration_sec=272,flags=0,hard_timeout=0,idle_timeout=0,instructions=[OFPInstructionActions(actions=[OFPActionOutput(len=16,max_len=65509,port=2,type=0)],len=24,type=4)],length=104,match=OFPMatch(oxm_fields={'eth_src': '00:00:00:00:00:01', 'eth_dst': '00:00:00:00:00:02', 'in_port': 1}),packet_count=9,priority=1,table_id=0)
awareness: Exception occurred during handler processing. Backtrace from offending handler [_flow_stats_reply_handler] servicing event [EventOFPFlowStatsReply] follows.
Traceback (most recent call last):
  File "/usr/local/lib/python2.7/dist-packages/ryu/base/app_manager.py", line 290, in _event_loop
    handler(ev)
  File "/home/lhl/Desktop/network/network.py", line 319, in _flow_stats_reply_handler
    key = (stat.match['in_port'], stat.match['ipv4_dst'],
  File "/usr/local/lib/python2.7/dist-packages/ryu/ofproto/ofproto_v1_3_parser.py", line 902, in __getitem__
    return dict(self._fields2)[key]
KeyError: 'ipv4_dst'

```

可以看到OFPFlowStats数据结构中有in_port而没有ipv4_dst！！！

查了一下4.2的git记录，diff，现在的代码和上次提交的代码是有不同，但是不同之处应该对这个报错没有影响，现在重启ubuntu试试...

没有in_port or ipv4_dst报错！

**现在尝试用自己的app，默认的mininet，测试一下能否限流！**

还是出现了找不到in_port...

现在路由规则转回hop，不会出现in_port or ipv4_dst的错误了，但是不会初始化stats，所以在"Verifying the Setting"时会在[EventOFPFlowStatsReply] 报错，但问题是为何会执行这个函数？

好吧， 暂时不执行verifying the setting了，看能否跳过这个步骤，看看能不能限流，发现自己的app+sw5host3拓扑没法限流。。

---

11.13返工

11.8中的"Verifying the Setting"这节的报错，全文如下：

```
(9515) accepted ('127.0.0.1', 44326)
awareness: Exception occurred during handler processing. Backtrace from offending handler [_flow_stats_reply_handler] servicing event [EventOFPFlowStatsReply] follows.
Traceback (most recent call last):
  File "/usr/local/lib/python2.7/dist-packages/ryu/base/app_manager.py", line 290, in _event_loop
    handler(ev)
  File "/home/lhl/Desktop/network/network.py", line 312, in _flow_stats_reply_handler
    self.stats['flow'][dpid] = body
KeyError: 'flow'
Traceback (most recent call last):
  File "/usr/lib/python2.7/dist-packages/eventlet/wsgi.py", line 481, in handle_one_response
    result = self.application(self.environ, start_response)
  File "/usr/local/lib/python2.7/dist-packages/ryu/app/wsgi.py", line 236, in __call__
    return super(wsgify_hack, self).__call__(environ, start_response)
  File "/usr/lib/python2.7/dist-packages/webob/dec.py", line 130, in __call__
    resp = self.call_func(req, *args, **self.kwargs)
  File "/usr/lib/python2.7/dist-packages/webob/dec.py", line 195, in call_func
    return self.func(req, *args, **kwargs)
  File "/usr/local/lib/python2.7/dist-packages/ryu/app/wsgi.py", line 290, in __call__
    return controller(req)
  File "/usr/local/lib/python2.7/dist-packages/ryu/app/wsgi.py", line 160, in __call__
    return getattr(self, action)(req, **kwargs)
  File "/home/lhl/Desktop/network/rest_qos.py", line 459, in get_qos
    'get_qos', self.waiters)
  File "/home/lhl/Desktop/network/rest_qos.py", line 527, in _access_switch
    msg = function(rest, vid, waiters)
  File "/home/lhl/Desktop/network/rest_qos.py", line 650, in _rest_command
    key, value = func(*args, **kwargs)
  File "/home/lhl/Desktop/network/rest_qos.py", line 814, in get_qos
    rule = self._to_rest_rule(flow_stat)
  File "/home/lhl/Desktop/network/rest_qos.py", line 954, in _to_rest_rule
    rule.update(Match.to_rest(flow))
  File "/home/lhl/Desktop/network/rest_qos.py", line 1112, in to_rest
    match.setdefault(key, conv[value])
KeyError: 35020
```

谷歌查询“KeyError： 35020”时，有[惊喜](https://sourceforge.net/p/ryu/mailman/message/35802930/)！

``` 
The cause is that rest_pos.py does not support LLDP(ether_type: 88cc).
The quick fix is making rest_qos.py to support LLDP, so:

diff --git a/ryu/app/rest_qos.py b/ryu/app/rest_qos.py
index 9fe72ed..6e750e6 100644
--- a/ryu/app/rest_qos.py
+++ b/ryu/app/rest_qos.py
@@ -211,6 +211,7 @@ REST_DL_TYPE = 'dl_type'
  REST_DL_TYPE_ARP = 'ARP'
  REST_DL_TYPE_IPV4 = 'IPv4'
  REST_DL_TYPE_IPV6 = 'IPv6'
+REST_DL_TYPE_LLDP = 'lldp'
  REST_DL_VLAN = 'dl_vlan'
  REST_SRC_IP = 'nw_src'
  REST_DST_IP = 'nw_dst'
@@ -946,7 +947,8 @@ class Match(object):
      _CONVERT = {REST_DL_TYPE:
                  {REST_DL_TYPE_ARP: ether.ETH_TYPE_ARP,
                   REST_DL_TYPE_IPV4: ether.ETH_TYPE_IP,
-                 REST_DL_TYPE_IPV6: ether.ETH_TYPE_IPV6},
+                 REST_DL_TYPE_IPV6: ether.ETH_TYPE_IPV6,
+                 REST_DL_TYPE_LLDP: ether.ETH_TYPE_LLDP},
                  REST_NW_PROTO:
                  {REST_NW_PROTO_TCP: inet.IPPROTO_TCP,
                   REST_NW_PROTO_UDP: inet.IPPROTO_UDP,

```

先吃个中饭，等会再来解决问题！

照着大神的操作，加入了lldp的支持，运行成功，“Verifying the Setting”通过，但是注意返回的body中还有lldp的信息。

![mark](http://ph166fnv2.bkt.clouddn.com/blog/181113/H6gcfLGhg2.png?imageslim)

但是flow那里还是报错了，先不管了，试试能不能限流，发现用network app + sw5host3拓扑无法限流，但是用network app+默认mininet拓扑可以限流（即使有flow报错），如下：

![mark](http://ph166fnv2.bkt.clouddn.com/blog/181113/bB9CAa34a9.png?imageslim)


---

2.24返工

尝试把sw5host拓扑中的五个switch xterm终端都打开，分别输入[教程中的指令](http://osrg.github.io/ryu-book/en/html/rest_qos.html#example-of-the-operation-of-the-per-flow-qos)。顺序严格按照教程中的来，先打开mininet，再打开五个终端，再分别输入命令，最后再开启ryu应用。

 > 运行.sh文件，可以在终端键入:
 > 
 > sh xx.sh

有很多命令需要在c0终端输入，所以创建了几个sh文件供c0终端执行，最后的结果：verifying the setting通过，但是ryu应用终端还是在flow那里报错了，最后也没法限流，两个端口的流量都是1Mbit/s，很奇怪，因为这个是execute setting of queue那节中给s1-eth1的最大速率，那也就是说，queue实现了基础的最大速率限制，但没有queue0和queue1的QoS保障？

查看rest_qos.py，发现有许多地方都牵涉到了REST_DL_TYPE，而mailing list中给的解决方案并没有在所有REST_DL_TYPE的地方添加lldp变量，难道flow仍然报错是因为这个原因吗？退一万步讲，如果我不做时延检测了，那也就不需要修改lldp了，是否可以不报错而成功实现QoS限流呢？不急，教程中还有其他两个QoS实现手段：[using-diffserv](http://osrg.github.io/ryu-book/en/html/rest_qos.html#example-of-the-operation-of-qos-by-using-diffserv)、[using-meter-table](http://osrg.github.io/ryu-book/en/html/rest_qos.html#example-of-the-operation-of-qos-by-using-meter-table)，而且example中有多个switch，正好与sw5host拓扑类似。

---

2.25返工
尝试using-diffserv，先模仿官方example跑一遍，它是基于qos_rest_router.py的应用，修改源码太过麻烦，就不用这种方法了。
运行ryu应用以及执行curl指令直接在ubuntu终端进行，example中都是在xterm c0中执行的，有点麻烦了。成功地把using-diffserv跑了一遍了。
看了一下using-meter-table，它是基于qos_simple_switch_13.py的应用，拓扑倒是有点弄得花里胡哨，晚点再看

---

2.26返工

复现原来的场景：network app + sw5host3，发现h1-h2ping不通，但h1-h3能ping通，估计又是玄学bug，总结一下解决流程：
    
  - 关闭mininet，清除缓存

        root@ubuntu:/home/lhl/Desktop/network# mn -c

  - 删除所有qos设置

        lhl@ubuntu:~/Desktop/network$ sudo ./remove_qos.sh 

  - 运行官方example（不带qos也可）

        ryu-manager ryu.app.rest_qos ryu.app.qos_simple_switch_13 ryu.app.rest_conf_switch

为了让开发脉络更加清晰，从现在开始用git同步，rest_qos.py重新导入，提交init版本，这样修改源码时就有底气了。

回到11.13返工的进度，当时按照惊喜对rest_qos.py添加了两处lldp代码，network app + sw5host3 无法限流，报flow错，network app + 默认拓扑（sw1host2且带nat参数）:

    sudo mn --controller=remote --mac --switch ovs,protocols=OpenFlow13 --link tc --nat

 即使报flow错也可以限流.

---
5.8 fa

---


2020.12.28复现环境记录

1. 安装
	- ryu4.23：用git方式安装，checkout v4.23，再安装
	- 用户可定义网络平台服务端代码在ryu控制器上，是基于python2.7写的，所以ryu-manager也是基于python2.7运行，所以安装时注意python版本，特别是pip2和pip3的区别
	- 安装ryu以及运行ryu可能会有很多报错，大概率是cannot import module "xxx"，主要原因在各种依赖库的版本不对劲
2. 修改源码
	- flags文件
	- switch
3. ryu-manager network.py rest_qos.py rest_conf_switch.py ofctl_rest.py --observe-links --weight=hop
4. sudo mn --custom sw5host3.py --topo mytopo --controller=remote --mac --switch ovs,protocols=OpenFlow13 --link tc --nat

---

1.5 尝试pod=4，density=2的fattree拓扑，但是还没有和ryu连接起来，还需要修改一下李呈大神的fattree源码

1.6 

1. 修改了fattree的switch与host的命名，导致ryu报错：multiple connections from [dpid]，查阅资料发现是因为mininet没法猜测出节点命名，所以还是按原来的命名方式
2. 发现fattree如果四元太复杂，二元太简单，最后选择了叶脊网络，两个脊，四个叶，各下挂一个主机
3. 又遇到了ping不通的玄学问题，mn -c/杀进程/运行官方拓扑/运行官方应用都试过了，最后重新进入了vscode与xshell就可以了
4. 叶脊网络有好几个环，发现只有h3 ping h4可以通，监听s1的端口发现一直在arp泛洪，保持mininet不动，把ryu app重新启动就可以全部ping通了！
5. 注意，因为是ssh登陆到服务器上，无论是ryu还是mininet都是命令行运行的，所以如果ssh断掉连接，并不代表服务器上的程序停止了，得kill重启
6. 在mininet做了iperfleafspine命令，测试iperf，h1-h9, h2-h10, ..., h8-h16，最后在服务端(h1~h16)记录下来数据，发现weight=hop是正好打满了各自的最大带宽，h9~h12四台服务端iperf加起来的带宽为40Mb/s，这正好与设置的链路带宽参数吻合，比如h1-h9的路径是：h1-s3-s1-s5-h9，叶子交换机南向带宽为20Mb/s，北向带宽为40Mb/s，所以正好打满

1.7

1. 为network app新增weight=ratio，`cost = alpha*delay - beta*utilization`，设置alpha=10，beta=1，utilization=used_bandwidth / 40

4.3

不需要做流量调度，参照lhl硕士毕业论文，修改了一点客户端GUI，修改mininet的指令，方便测试ping与iperf