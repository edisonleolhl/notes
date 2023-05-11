## perf

它是 Linux 系统原生提供的性能分析工具，会返回 CPU 正在执行的函数名以及调用栈（stack）。

通常，它的执行频率是 99Hz（每秒99次），如果99次都返回同一个函数名，那就说明 CPU 这一秒钟都在执行同一个函数，可能存在性能问题。

```bash
$sudo perf record -F 99 -p 13204 -g -- sleep 30 
```

上面的代码中，perf record表示记录，-F 99表示每秒99次，-p 13204是进程号，即对哪个进程进行分析，-g表示记录调用栈，sleep 30则是持续30秒。

为了便于阅读，perf record命令可以统计每个调用栈出现的百分比，然后从高到低排列。

```bash
$sudo perf report -n --stdio
```

# 将 perf.data 的内容 dump 到 out.perf

```bash
$sudo perf script > out.perf 
```

## 生成火焰图

```bash
git clone --depth 1 https://github.com/brendangregg/FlameGraph.git
# 折叠调用栈，位于FlameGraph/
sudo ./stackcollapse-perf.pl out.perf > out.folded
# 生成火焰图，位于FlameGraph/
sudo ./flamegraph.pl out.folded > test.svg
```

scp拷贝svg火焰图到本机，方便用Chrome查看

scp xx.xx.xx.xx:~/.test.svg Downloads

> 本文落笔于2021-09-09