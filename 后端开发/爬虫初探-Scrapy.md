# 爬虫初探-Scrapy

## Scrapy 资料

- 官方文档永远是首选，建议把 tutorial 完整的过一遍。

- 网址：https://doc.scrapy.org/en/latest/intro/tutorial.html

## 爬取步骤

- 我们准备爬取宅男女神排行榜的所有女神相册，首先看看入口是怎么样的。

    ![20171024-goddessrank](http://ooy7h5h7x.bkt.clouddn.com/blog/image/20171024-goddessrank.png)

- 可以看到这里有5页，每页有20个女神，所以我们的爬虫逻辑应该是：

  - 遍历这20个女神，进入到各自的主页，获取它们主页的个人信息。

    - 从女神主页进入她的相册写真集页面（如果某女神写真集较少，则直接在主页进入相册），把各相册中图片下载下来，这里要注意某个写真相册有很多页，每页有好几张图片，在这里同样需要遍历每一页。

  - 遍历这5页，重复上述动作。

- 进入第一个女神：夏美酱的主页，可以看到有她的一些个人信息，以及写真集。

    ![20171024-xiameijiang](http://ooy7h5h7x.bkt.clouddn.com/blog/image/20171024-xiameijiang.png)

- 好的，大致信息已经知道了，我们从简单的个人信息爬取开始。

## 爬取个人信息

- 首先从简单的做起，爬取排行榜所有女神的个人信息，如姓名、生日、年龄、三围、出生，在女神的主页，通过谷歌浏览器的开发者工具，可以看到这样的代码：

    ![20171024-xiameijianginfo](http://ooy7h5h7x.bkt.clouddn.com/blog/image/20171024-xiameijianginfo.png)

- 于是 spider 中爬取女神个人信息的代码是这样的：

        import scrapy
        import re

        class GoddessSpider(scrapy.Spider):
            name = "goddess"
            start_urls = ['https://www.nvshens.com/rank/sum/']

            def parse(self, response):
                # follow links to goddess pages
                for href in response.css('div.rankli_imgdiv a::attr(href)'):
                    yield response.follow(href, self.parse_goddess)

                # follow pagination links
                # ...

            def parse_goddess(self, response):
                def util(self, l):
                    if l is not None and len(l) != 0:
                        return l[0]
                    else:
                        return None
                dic = dict(zip(response.css('div.infodiv td::text').extract()[0::2], response.css('div.infodiv td::text').extract()[1::2]))
                dic['姓名'] = response.css('div.div_h1 h1::text').extract()[0]
                yield dic

    > 解释：用 'div.infodiv td::text' 找到的既包含了“年龄”又包含了“20(属牛)”，而且是按顺序存储的，所以调用 extract() 方法把 Selector 对象变成列表后，把这个列表的奇数项作为 key （如：年龄、生日、星座...），偶数项作为 value （如：20(属牛)、1997-09-22、处女座）。然后再用 zip 函数，就可以做到两个列表转为字典。很实用的功能。
    > 姓名在女神主页的 h1 中可以找到，最后加进字典中即可。

- 输出类似下面这样：

        2017-10-24 13:43:16 [scrapy.core.scraper] DEBUG: Scraped from <200 https://www.nvshens.com/girl/24410/>
        {'年 龄：': '22 (属猪)', '生 日：': '1995-10-01', '星 座：': '天秤座', '身 高：': '165', '三 围：': 'B88 W60 H86', '出 生：': '中国 上海徐汇区', '职 业：': '平面模特、主播', '兴 趣：': '旅游、时尚、文艺、美食', '姓名': '周于希dummy(Dummy Zhou)'}
        2017-10-24 13:43:16 [scrapy.core.engine] DEBUG: Crawled (200) <GET https://www.nvshens.com/girl/19705/> (referer: https://www.nvshens.com/rank/sum/)
        2017-10-24 13:43:16 [scrapy.core.scraper] DEBUG: Scraped from <200 https://www.nvshens.com/girl/20440/>
        {'年 龄：': '22 (属狗)', '生 日：': '1994-12-24', '星 座：': '魔羯座', '身 高：': '165', '三 围：': 'B90(F75) W60 H88', '出 生：': '中国 浙江杭州', '职 业：': '钢管舞老师、模特', '兴 趣：': '舞蹈', '姓名': '于姬(Una)'}

- 刚才只爬取了第一页的女神主页，还有4页需要爬取，查看入口的分页器代码，并没有像 Scrapy 官方教程那么简单，在官方教程中，“下一页”的按钮有明确的 class 或者 id 唯一标识，但在这里没有，如下：

    ![20171024-goddesspages](http://ooy7h5h7x.bkt.clouddn.com/blog/image/20171024-goddesspages.png)

- 可以看到，“”的按钮并没有定义 class 或者 id，这就和其他的页数按钮混在一起了，那要怎么判断下一页呢？可以看到，当前页（图中也就是第1页）是比较特别的，因为它被 class='cur' 唯一标识了，而跳转第2页看看，class='cur' 就变成第二页的标识了，显然，这里就是突破口。

- 进入 Scrapy 的 shell 窗口，调试一下：

        ## 读取分页条的所有按钮（也就是 a 链接）
        >>> response.css('div.pagesYY a::attr(href)')
        [<Selector xpath="descendant-or-self::div[@class and contains(concat(' ', normalize-space(@class), ' '), ' pagesYY ')]/descendant-or-self::*/a/@href" data='1.ht
        ml'>, <Selector xpath="descendant-or-self::div[@class and contains(concat(' ', normalize-space(@class), ' '), ' pagesYY ')]/descendant-or-self::*/a/@href" data=
        '2.html'>, <Selector xpath="descendant-or-self::div[@class and contains(concat(' ', normalize-space(@class), ' '), ' pagesYY ')]/descendant-or-self::*/a/@href"
        data='3.html'>, <Selector xpath="descendant-or-self::div[@class and contains(concat(' ', normalize-space(@class), ' '), ' pagesYY ')]/descendant-or-self::*/a/@h
        ref" data='4.html'>, <Selector xpath="descendant-or-self::div[@class and contains(concat(' ', normalize-space(@class), ' '), ' pagesYY ')]/descendant-or-self::*
        /a/@href" data='5.html'>, <Selector xpath="descendant-or-self::div[@class and contains(concat(' ', normalize-space(@class), ' '), ' pagesYY ')]/descendant-or-se
        lf::*/a/@href" data='2.html'>, <Selector xpath="descendant-or-self::div[@class and contains(concat(' ', normalize-space(@class), ' '), ' pagesYY ')]/descendant-
        or-self::*/a/@href" data='5.html'>]

        ## 读取分页条的当前页数按钮

        >>> response.css('div.pagesYY a.cur::attr(href)')
        [<Selector xpath="descendant-or-self::div[@class and contains(concat(' ', normalize-space(@class), ' '), ' pagesYY ')]/descendant-or-self::*/a[@class and contai
        ns(concat(' ', normalize-space(@class), ' '), ' cur ')]/@href" data='1.html'>]

- 可以看到，当前页数的 Selector 对象并不与上面相同（因为选择器不同），即不能简单用 in 关键字判断（if 'a' in 'abc'），利用正则表达式来寻找 X.html，比较一下就行了，下面是代码：

        def parse(self, response):
            # follow links to goddess pages
            for href in response.css('div.rankli_imgdiv a::attr(href)'):
                yield response.follow(href, self.parse_goddess)

            # follow pagination links
            next_page = None
            L = len(response.css('div.pagesYY a::attr(href)'))
            for i in range(L):
                tmp_page = re.findall(r"[1-5].html", str(response.css('div.pagesYY a::attr(href)')[i]))
                print("tmp_page=", tmp_page)
                cur_page = re.findall(r"[1-5].html", str(response.css('div.pagesYY a.cur::attr(href)')))
                print("cur_page=", cur_page)
                if tmp_page == cur_page and cur_page != ['5.html']:
                    next_page = response.css('div.pagesYY a::attr(href)')[i+1] # Attention: next_page = cur_page + 1
                    print("next_page=", next_page)
                    break
            if next_page is not None:
                print("--------------------------------------------------------------------")
                yield response.follow(next_page, self.parse)

## 爬取图片

- 好了，前面把整个框架搭好了，现在要进入女神主页的相册，有点小兴奋呢:)

- 这里有个问题了，有些女神的相册很多，主页只能显示最近6个相册，在相册 div 的右下角有个按钮用来进入相册集页面（例如夏美酱的相册集 url ：'https://www.nvshens.com/girl/21501/album/'）：

        <span class='archive_more'><a style='text-decoration: none' href='/girl/21501/album/' title='全部图片' class='title'>共50册</a></span>

- 然而有些女神只有少数相册，甚至只有一个相册，右下角也没有上述按钮，如果在地址栏手动输入：XXXX/album/，那么会出现404错误，我们的爬虫当然要“智能”判断这两种情况，实现全部爬取。

- 用简单的 if 判断一下即可，在其中一个分支中要再开一个函数处理：

        def parse_goddess(self, response):
            # get goddess info, like name, age, birthday ...
            def util(self, l):
                if l is not None and len(l) != 0:
                    return l[0]
                else:
                    return None
            dic = dict(zip(response.css('div.infodiv td::text').extract()[0::2], response.css('div.infodiv td::text').extract()[1::2]))
            dic['姓名'] = response.css('div.div_h1 h1::text').extract()[0]
            yield dic

            # get to the album page (before photo page) or photo page directly
            if response.css('span.archive_more a::attr(href)') is not None:
                for archive_more in response.css('span.archive_more a::attr(href)'):
                    yield response.follow(archive_more, self.parse_goddess_album)
            else:
                for album_link in response.css('a.igalleryli_link::attr(href)'):
                    yield response.follow(album_link, self.parse_goddess_photo)

        def parse_goddess_album(self, response):
            for album_link in response.css('a.igalleryli_link::attr(href)'):
                yield response.follow(album_link, self.parse_goddess_photo)

- 好的，现在就要开始编写 parse_goddess_photo 函数了，我们随便打开一个女神相册进入，再调用检查工具，看一看从哪里突破。

    ![20171025-goddessphotohtml](http://ooy7h5h7x.bkt.clouddn.com/blog/image/20171025-goddessphotohtml.png)

- 图片的 url 地址一目了然，可以用选择器找到外部的 ul#hgallery 标签，然后加个 for 循环即可，注意到爬取图片下载到本地时有两点要注意：

  - 路径：在工程目录下创建一个文件夹，名字就是当前爬取的相册，里面储存该相册的所有图片，同时还可以爬取该相册的介绍信息，保存到相册文件夹的 txt 文件中。而且，要为每个本地图片指定名字，在这里用了正则表达式，把 url 最后的 http://../..//XX.jpg 中的 XX.jpg 作为本地图片的名字。

  - urllib 当前版本下载图片到本地要这样操作：

        import urllib.request
        with open(path + "".join(re.findall(r"..jpg", img_src)), 'wb+') as f_img:
            conn = urllib.request.urlopen(img_src)
            f_img.write(conn.read())

- 这个页面的“下一页”按钮是有 class 标识的，虽然“上一页”和“下一页”按钮的 class 都是 a1，但是无论当前打开哪一页，这两个按钮一直都存在，比如在第一页按上一页，还是第一页的地址，在最后一页按下一页，还是最后一页的地址，又因为 Scrapy 默认不会爬取重复的页面，所以这里很好编写代码。

- 结合下载图片的操作，新创建的 parse_goddess_photo 函数可以按葫芦画瓢写出：

        def parse_goddess_photo(self, response):
            # NOW U ARE IN PHOTO PAGE!
            # download photo
            album_title = response.css('h1#htilte::text').extract_first()
            album_desc = response.css('div#ddesc::text').extract_first()
            album_info = response.css('div#dinfo span::text').extract_first() + response.css('div#dinfo::text').extract()[1]
            path = 'goddess_photo/' + album_title + '/'
            if not os.path.exists(path):
                os.makedirs(path)
            with open(path + 'album_info.txt', 'a+') as f:
                f.write(album_desc)
                f.write(album_info)
            for img_src in response.css('ul#hgallery img::attr(src)').extract():
                with open(path + "".join(re.findall(r"[0-9]{1,4}.jpg", img_src)), 'wb+') as f_img:
                    f_img.write(urllib.request.urlopen(img_src).read())
                    print("DOWALOADING img_src:" + img_src)

            # follow pagination links
            next_page = response.css('a.a1::attr(href)')[1]
            if next_page is not None:
                print("".join(re.findall(r"..html", str(next_page))) + '--> next_page:' + album_title)
                yield response.follow(next_page, self.parse_goddess_photo)

## 最终效果

- 第一次写爬虫，也没考虑到效率问题，大概花了5个小时才爬取完，在下载图片时，不同的图片就放在不同的文件夹里，这样很好管理。

  ![20171025-xiaoguo](http://ooy7h5h7x.bkt.clouddn.com/blog/image/20171025-xiaoguo.png)

- 所有图片加起来总大小超过7G。

  ![20171025-goddessspace](http://ooy7h5h7x.bkt.clouddn.com/blog/image/20171025-goddessspace.png)

- 其实这篇笔记是我边撸代码边写的，写在这里的时候爬虫还在运行，因为之前我没注意要把 setting.py 中的 ROBOTSTXT_OBEY 的值改成 FALSE，所以在爬取到快结束时发现卡住了，后来重新运行，查了下原因才改过来的。

- 重新开始爬取，我是选择从排行榜第四页进入的，运行了挺久的了，还没爬到新的女神，一直在爬之前爬过的，所以下载的图片自然没有增长，因为 Scrapy 默认开启10个线程，所以那些没有爬过的女神并不是按顺序的。

- 总之，这篇笔记主要是记录了第一次爬虫的经历，挺好玩的，也有挺多需要注意的地方，下次想想怎么改进爬虫速度，再学习一下应对网站反爬虫的方法。