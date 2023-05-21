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

为了便于阅读，perf record命令可以统计每个调用栈出现的百分比，然后从高到低排列。

```bash
$sudo perf report -n --stdio
```

```bash
git clone --depth 1 https://github.com/brendangregg/FlameGraph.git
# 先折叠调用栈，再生成火焰图，两个脚本都位于FlameGraph/
sudo perf script -i perf.data | ./FlameGraph/stackcollapse-perf.pl | ./FlameGraph/flamegraph.pl > out.svg
```

scp拷贝svg火焰图到本机，方便用Chrome查看

scp xx.xx.xx.xx:~/.out.svg Downloads

> 本文落笔于2021-09-09