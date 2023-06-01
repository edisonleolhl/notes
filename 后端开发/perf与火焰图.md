## perf

它是 Linux 系统原生提供的性能分析工具，会返回 CPU 正在执行的函数名以及调用栈（stack）。

```bash
sudo yum install perf-3.10.0
```

通常，它的执行频率是 99Hz（每秒99次），如果99次都返回同一个函数名，那就说明 CPU 这一秒钟都在执行同一个函数，可能存在性能问题。

```bash
sudo perf record -F 99 -p 1921 -g -o perf.data -- sleep 60
```

上面的代码中，perf record表示记录，-F 99表示每秒99次，-p 1921是进程号，即对哪个进程进行分析，-g表示记录调用栈，sleep 30则是持续30秒。-o表示输出到哪个文件中

> 如果一台服务器有16个 CPU，每秒抽样99次，持续30秒，就得到 47,520 个调用栈，长达几十万甚至上百万行。

为了便于阅读，perf record命令可以统计每个调用栈出现的百分比，然后从高到低排列。

```bash
$sudo perf report -n --stdio
```

## 火焰图

火焰图是基于 perf 结果产生的 SVG 图片，用来展示 CPU 的调用栈。

```bash
git clone --depth 1 https://github.com/brendangregg/FlameGraph.git
# 先折叠调用栈，再生成火焰图，两个脚本都位于FlameGraph/
sudo perf script -i perf.data | ./FlameGraph/stackcollapse-perf.pl | ./FlameGraph/flamegraph.pl > out.svg
```

y 轴表示调用栈，每一层都是一个函数。调用栈越深，火焰就越高，顶部就是正在执行的函数，下方都是它的父函数。

x 轴表示抽样数，如果一个函数在 x 轴占据的宽度越宽，就表示它被抽到的次数多，即执行的时间长。注意，x 轴不代表时间，而是所有的调用栈合并后，按字母顺序排列的。

火焰图就是看顶层的哪个函数占据的宽度最大。只要有"平顶"（plateaus），就表示该函数可能存在性能问题。

颜色没有特殊含义，因为火焰图表示的是 CPU 的繁忙程度，所以一般选择暖色调。

## 其他

Chrome 浏览器可以生成页面脚本的火焰图，用来进行 CPU 分析。

打开开发者工具，切换到 Performance 面板。然后，点击"录制"按钮，开始记录数据。这时，可以在页面进行各种操作，然后停止"录制"。

这时，开发者工具会显示一个时间轴。它的下方就是火焰图。

scp拷贝svg火焰图到本机，方便用Chrome查看

scp xx.xx.xx.xx:~/.out.svg Downloads

## L1 cache miss

Perf可以基于各种Event对目标进行测样。如基于时间点(tick)采样，可以得到程序运行时间的分布，即程序中哪些函数最耗时。基于cache miss采样，可以得到程序的cache miss分布，即cache失效经常发生在哪些代码中。通过perf list可以Perf支持的各种Event:

```shell
$ sudo perf list                                                                                                                                                             List of pre-defined events (to be used in -e):

 cpu-cycles OR cycles                       [Hardware event]
 instructions                               [Hardware event]
 cache-references                           [Hardware event]
 cache-misses                               [Hardware event]
 branch-instructions OR branches            [Hardware event]
 branch-misses                              [Hardware event]
 bus-cycles                                 [Hardware event]

 cpu-clock                                  [Software event]
 task-clock                                 [Software event]
 page-faults OR faults                      [Software event]
 minor-faults                               [Software event]
 major-faults                               [Software event]
 context-switches OR cs                     [Software event]
 cpu-migrations OR migrations               [Software event]
 alignment-faults                           [Software event]
 emulation-faults                           [Software event]

 [...]

 sched:sched_stat_runtime                   [Tracepoint event]
 sched:sched_pi_setprio                     [Tracepoint event]
 syscalls:sys_enter_socket                  [Tracepoint event]
 syscalls:sys_exit_socket                   [Tracepoint event]

 [...]
 ```

 可以用于分析代码的局部性缓存友好性

> 本文落笔于2021-09-09