## 背景

某次在写完业务代码后，我习惯性地把单测补齐（团队要求单测增量覆盖率80%，发布会检测这一指标进行卡点），我们的C++代码使用的是gmock+gtest这套框架，https://google.github.io/googletest/gmock_for_dummies.html

增量代码的单测一般流程是这样的：假设A类某函数foo中，新增了几行代码，其中调用了B类的testMethod函数，

1. 使用gmock_gen.py脚本（gmock提供），根据B.h文件生成B.mock文件
2. 新建或打开A_test.cpp单测文件，在其中编写A类的单测代码
3. mock掉testMethod函数，使用Assert_xx来判断foo函数的执行流是否符合预期、关键出参入参是否符合预期

## 现象

这次改动，我需要在B类的testMethod中新增了一个参数param11，测试代码如下：

```c++
class B {
    ...
  virtual bool testMethod(const std::string &param1, const std::string &param2, const std::string &param3, const std::string &param4, const std::string &param5, const std::string &param6, const std::string &param7, const std::string &param8, const std::string &param9, const std::string &param10, const std::string &param11) {
      return true;
  }
};
```

生成的B_mock.h文件如下：

```c++
class BMock : B {
    ...
  MOCK_METHOD11(testMethod,
      bool(const std::string & param1, const std::string & param2, const std::string & param3, const std::string & param4, const std::string & param5, const std::string & param6, const std::string & param7, const std::string & param8, const std::string & param9, const std::string & param10, const std::string & param11));

}

编译时报错，复现的报错信息如下：

```bash
./utest/mock/b_mock.h: At global scope:
./utest/mock/b_mock.h:59:17: error: ‘testMethod’ is not a type
   MOCK_METHOD11(testMethod,
                 ^~~~~~~~~~
```

C++的报错就是这么让人摸不着头脑，代码仔细走查了一下，没啥问题，于是上网搜索，Google+ChatGPT，最开始我的重点放在了`‘testMethod’ is not a type`，但是这个不是根因，根因其实是这个因为我们使用的gmock是1.7版本，低版本的gmock不支持mock大于10个参数的方法，参考

https://stackoverflow.com/questions/12543274/gmock-error-is-mock-method11-not-allowed

问了下ChatGPT

```bash
Me:
which version of gmock support mock function over 10 arguments?

ChatGPT3.5
As an AI language model, I do not have access to the current status of gmock. However, according to the official documentation of Google Test, the latest version of gmock (at the time of writing this) is version 1.10.0, which supports mocking of functions with up to 10 arguments using the gmock-generated function mockers. However, it is possible to write custom matchers and action templates to support more than 10 arguments.
```

github上也有人扩展了gmock，可支持最多15个参数的mock：[gmock-more-args](https://github.com/apriorit/gmock-more-args)

## 思考

一个业务函数真的需要10个参数吗？过长的参数列会让代码可读性急剧下降，且扩展性很差

思考了业务场景，这个testMethod函数是用来查数据的，增加的这个参数param11是用来增加一个查询条件，前10个参数中也有几个参数是用来表达查询条件的，于是可以考虑合成结构体：

```c++
// B.h
struct AdditionalQueryParams {
    std::string param9;
    std::string param10;
    std::string param11;
};

class B {
    ...
    virtual bool testMthod(const std::string &param1, const std::string &param2, const std::string &param3, const std::string &param4, const std::string &param5, const std::string &param6, const std::string &param7, const std::string &param8, const AdditionalQueryParams &query_params);
};
```

Long Parameter List(过长参数列)是代码的坏味道，我们需要对其进行重构，《重构 改善既有代码的设计》这本书给了很好的解决办法，我这种重构方法是Introduce Param Object，当一组数据项总是结伴而行，出没于一个又一个函数，这样的一组数据称为数据泥团，通常用一个数据结构来代替它们。

> 参考这个博客的笔记：https://blog.csdn.net/qq_42604176/article/details/120199151

总结：遇到问题时停下脚步审视自己是不是走在正确的道路上，为何gmock不多支持几个参数？其实这样的设计是合理的，不愧是发布了 [C++风格指南](https://google.github.io/styleguide/cppguide.html) 的Google