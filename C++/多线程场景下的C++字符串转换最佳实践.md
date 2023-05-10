## 背景

前段时间发现在基础库中有一些字符串转化的性能问题，在读取某些字符串配置时，需要借助字符串这个中间变量进行转换，在多线程场景下效率很差，代码如下，成员变量m_data存储了所有的配置：

```c++
// SectionConfig.h
class SectionCfonig{
  ...
  GetInt()...
  GetDouble()...
  GetString()...
  ...
 private:
  std::map<std::string, std::map<std::string, std::string>> m_data;
}
```

```c++
// SectionConfig.cpp
...
// GetDouble等函数与GetInt类似
int SectionConfig::GetInt(
    const std::string &section,
    const std::string &key,
    int defaultValue) const {
  std::string stringValue = GetString(
      section,
      key,
      XXX::toString<int>(defaultValue));
  return XXX::fromString<int>(stringValue);
}

// 
std::string SectionConfig::GetString(
  const std::string &section,
  const std::string &key,
  const std::string &defaultValue) const {
  auto itSectionFound = m_data.find(section);
  if (itSectionFound != m_data.end()) {
    auto &sectionValue = itSectionFound->second;
    auto itFound = sectionValue.find(key);
    if (itFound != sectionValue.end()) {
      return itFound->second;
    }
  }
  return defaultValue;
}
```

XXX::toSring与XXX::fromString是模板函数，定义如下：

```c++
namespace XXX {
    template < typename T >
    extern T fromString(const std::string &s, const int radix = 10) {
        std::istringstream iss(s);
        T result;
        switch (radix) {
            case 10:
                iss >> result;
                break;
            case 16:
                iss >> std::hex >> result;
                break;
            case 8:
                iss >> std::oct >> result;
                break;
            default:
                iss >> result;
        }
        return result;
    }

    template < typename T >
    extern std::string toString(const T &t, const int radix = 10) {
        std::ostringstream oss;
        switch (radix) {
            case 10:
                oss << t;
                break;
            case 16:
                oss << std::hex << t;
                break;
            case 8:
                oss << std::oct << t;
                break;
            default:
                oss << t;
        }
        return oss.str();
    }
  }
```

## 多线程性能测试

### 测试代码

先不论把字符串作为中间量是否合理，我们先把重点放在字符串转换上，在多线程场景下，ostringstream与istringstream的性能比较差，测试代码如下：

```c++
#include <string>
#include <sstream>
#include <iostream>
#include <sys/time.h>
#include <pthread.h>
#include <stdlib.h>

const int LOOPS = 1000000;

// int转字符串
std::string use_snprintf(int a) {
  char buf[64];
  snprintf(buf, sizeof(buf), "%d", a);
  return buf;
}

std::string use_ostringstream(int a) {
  std::ostringstream oss;
  oss << a;
  return oss.str();
}

std::string use_stringstream(int a) {
  std::stringstream ss;
  ss << a;
  return ss.str();
}

std::string use_std_to_string(int a) {
  std::string s = std::to_string(a);
  return s;
}

// 字符串转int
int use_c_atoi(const std::string &s) { // C语言风格
  int result = atoi(s.c_str());
  return result;
}

int use_std_stoi(const std::string &s) { // C++语言风格
  int result = std::stoi(s);
  return result;
}

int use_istringstream(const std::string &s) {
  std::istringstream iss(s);
  int result;
  iss >> result;
  return result;
}

int use_stringstream(const std::string &s) {
  std::stringstream ss(s);
  int result;
  ss >> result;
  return result;
}

void *thread_int_to_string(void *p) {
  std::string result;
  std::string (*foo)(int) = (std::string (*)(int))p;
  for (int i = 0; i < LOOPS; ++i)
    result = foo(i + 1);
  std::cout << "thread complete" << std::endl;
  return p;
}

double run_with_threads_int_to_string(int threads, std::string (*foo)(int)) {
  timeval start, end;
  gettimeofday(&start, nullptr);

  pthread_t *tids = new pthread_t[threads];
  for (int i = 0; i < threads; ++i)
    pthread_create(&tids[i], nullptr, thread_int_to_string, (void *)foo);
  for (int i = 0; i < threads; ++i)
    pthread_join(tids[i], nullptr);
  delete[] tids;

  gettimeofday(&end, nullptr);

  return (end.tv_sec - start.tv_sec) + (end.tv_usec - start.tv_usec) * 1e-6;
}

void *thread_string_to_int(void *p) {
  std::string str(10, '1');
  std::string result;
  int (*foo)(const std::string &) = (int (*)(const std::string &))p;
  for (int i = 0; i < LOOPS; ++i)
    result = foo(str);
  std::cout << "thread complete" << std::endl;
  return p;
}

double run_with_threads_string_to_int(int threads, int (*foo)(const std::string &)) {
  timeval start, end;
  gettimeofday(&start, nullptr);

  pthread_t *tids = new pthread_t[threads];
  for (int i = 0; i < threads; ++i)
    pthread_create(&tids[i], nullptr, thread_string_to_int, (void *)foo);
  for (int i = 0; i < threads; ++i)
    pthread_join(tids[i], nullptr);
  delete[] tids;

  gettimeofday(&end, nullptr);

  return (end.tv_sec - start.tv_sec) + (end.tv_usec - start.tv_usec) * 1e-6;
}

void test_with_threads(int threads) {
  printf("%d threads:\n", threads);
  std::cout << "-----------int转字符串-----------"  << std::endl;
  // std::cout << "snprintf test"  << std::endl;
  // double time_snprintf = run_with_threads_int_to_string(threads, use_snprintf);
  // std::cout << "std::to_string test"  << std::endl;
  // double time_std_to_string = run_with_threads_int_to_string(threads, use_std_to_string);
  // std::cout << "ostringstream test"  << std::endl;
  // double time_ostringstream = run_with_threads_int_to_string(threads, use_ostringstream);
  // std::cout << "stringstream test"  << std::endl;
  // double time_stringstream = run_with_threads_int_to_string(threads, use_stringstream);
  std::cout << "-----------字符串转int-----------"  << std::endl;
  std::cout << "c_atoi test"  << std::endl;
  double time_c_atoi = run_with_threads_string_to_int(threads, use_c_atoi);
  std::cout << "std::stoi test"  << std::endl;
  double time_std_stoi = run_with_threads_string_to_int(threads, use_std_stoi);
  std::cout << "istringstream test"  << std::endl;
  double time_istringstream = run_with_threads_string_to_int(threads, use_istringstream);
  std::cout << "stringstream test"  << std::endl;
  double time_stringstream_string_to_int = run_with_threads_string_to_int(threads, use_stringstream);
  printf("-------------\n");
  // printf("int转字符串\n");
  // printf("snprintf:        %f\n", time_snprintf);
  // printf("std_to_string:   %f\n", time_std_to_string);
  // printf("ostringstream:    %f\n", time_ostringstream);
  // printf("stringstream:    %f\n", time_stringstream);
  printf("字符串转int\n");
  printf("atoi:   %f\n", time_c_atoi);
  printf("std::stoi:   %f\n", time_std_stoi);
  printf("istringstream:   %f\n", time_istringstream);
  printf("stringstream:   %f\n", time_stringstream_string_to_int);
  printf("\n");
}

int main(int argc, char *argv[]) {
  int threads = argc > 1 ? atoi(argv[1]) : 10; // 默认10个线程
  std::cout << "threads number: " << threads << std::endl;
  test_with_threads(threads);
  return 0;
}
```

编译命令如下：

```bash
g++ -lpthread -Wall -g -std=c++11 string_test.cpp -o string_test
```

运行时可以传入数字，指定线程数量（默认10个线程）

```bash
./string_test 10
```

### 测试结果

不同线程下，int转字符串的性能测试表格如下：

| 拼接方法 | 1线程 | 2线程 | 4线程 | 10线程 | 20线程 | 40线程 | 100线程 |
| :------: | :----: | :----: | :----: | :-----: | :-----: | :-----: | :------: |
| snprintf | 0.23   | 0.12   | 0.12   | 0.15    | 0.21    | 0.41    | 0.94     |
| std::to_string | 0.26   | 0.17   | 0.16   | 0.16    | 0.31    | 0.51    | 1.13     |
| ostringstream | 0.79   | 1.18   | 2.33   | 6.43    | 12.13   | 20.72   | 49.70    |
| stringstream | 1.01   | 1.45   | 3.17   | 8.72    | 16.55   | 29.08   | 68.88？  |

不同线程下，字符串转int的性能测试表格如下：

| 拼接方法 | 1线程 | 2线程 | 4线程 | 10线程 | 20线程 | 40线程 | 100线程 |
| :------: | :----: | :----: | :----: | :-----: | :-----: | :-----: | :------: |
| atoi（C语言） | 0.19   | 0.20   | 0.17   | 0.20    | 0.21    | 0.25    | 0.39     |
| std::stoi | 0.27   | 0.20   | 0.25   | 0.27    | 0.28    | 0.36    | 0.52     |
| istringstream | 2.12   | 2.28   | 3.68   | 7.88    | 15.05   | 27.56   | 58.17    |
| stringstream | 2.33   | 3.36   | 4.61   | 10.52   | 19.80   | 36.80   | 78.79？  |

### 结论
● int转字符串的性能排序：snprintf > std::to_string >> ostringstream > stringstream
● 字符串转int的性能排序：atoi > std::stoi >> istringstream > stringstream
● 可以看到ostringstream/ostringstream在多线程场景下性能会急剧退化

## 剖析各种不同方法的比较

### ostringstream/istringstream

C++ 有两个类，ostringstream 和 istringstream，可以用来对内存中的值执行字符串/数字转换。

#### 简介

ostringstream 类是 ostream 的子类（cout 也属于该类），并使用流插入运算符 << 将数值转换为字符串。ostringstream 类型对象的工作方式与cout和文件对象的工作方式相同，但它不是将数据写入屏幕或文件，而是写入它所包含的字符串对象中。

#### 堆内存

ostringstream使用的是堆内存，多线程共用进程的堆资源，从而造成申请内存的时候互斥。

#### 锁

● ostringstream在解释一些宽字符串（如汉字）的时候，依赖执行环境的本地化策略，一个可执行文件在运行前是无法确定这些转换策略的，所以ostringstream在构造的时候需要通过 std::locale()来获取本地化策略，std::locale()内其实是拷贝了全局的本地化策略，同时系统允许对本地化策略进行更改和重新设置，例如：std::locale::global(std::local(myloc));
● 显然需要对全局的本地化策略进行保护。所以ostringstream 构造时就有加锁行为（引用计数的原子+1/-1操作），这个在多线程环境下锁争用就比较突出了，特别是使用ostringstream比较频繁的代码而言，性能损耗会比较大。

| 描述 | 示例 |
| :---: | :---: |
| istringstream(string s) | istringstream istr("50 64 28"); |
| ostringstream(string s) | ostringstream ostr("50 64 28"); |
| string str() | string is = istr.str();<br>string os = ostr.str (); |
| void str(string &s) | ostr.str("50 64 28");<br>istr.str("50 64 28");？ |

参考资料：https://chys.info/blog/2017-11-06-ostringstream-performance

### snprintf

而snprintf使用的是栈，多线程的栈独立使用，所以线程变多对性能几乎没什么影响
所以，多线程下，使用ostringstream会造成性能下降

### std::to_string(C++11)

C++ 11 提供了若干 to_string(T value) 函数来将 T 类型的数字值转换为字符串形式。以下是几个 to_string() 函数的列表：

```c++
string to_string(int value)
string to_string(long value)
string to_string(double value)
```

to_string() 函数无法处理非十进制整数的转换。如果需要该功能，则应该使用 ostringsteam 对象来完成该转换。

### std::stio

字符串到数字的转换可以通过 stoX() 系列函数来执行。该系列函数的成员可以将字符串转换为 int、long、float 和 double 类型的数字。具体语法如下所示：

```c++
int stoi(const strings str, size_t* pos = 0, int base = 10)
long stol(const strings str, size_t* pos = 0, int base = 10)
float stof(const strings str, size_t* pos = 0)
double stod(const strings str, size_t* pos = 0)
```
https://en.cppreference.com/w/cpp/string/basic_string/stol

## 基础库修改建议

1. 从字符串转换效率的角度出发，可以换用snprintf/atoi提高多线程下的性能
2. 从基础库设计的角度来考虑，因为section_config持有的是一张大map，kv都是string，可以考虑在读取配置时就存进几个不同的map中，比如string类型的配置放在map_string中，int类型的配置放在map_int中，这样可以从源头上解决每次读取配置时都要字符串转换的问题，这样虽然代码会啰嗦点，但是性能会更好

> 原文发表于 2022-03-30