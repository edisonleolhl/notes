## 背景

微服务架构下，自己负责的业务需要调用其他业务提供的服务，服务调用一般是通过RPC（Remote Procedure Call，远程过程调用）来完成的

根据业务复杂度，代码复杂度也可能比较高，函数层数可能会较深，纵观整个函数栈，可能会多次调用业务B提供的BService，甚至有可能入参都是一样的

假设互联网用户点外卖的场景，有这样的业务逻辑（仅作示例），整个流程的入口在OrderServiceImpl类的order方法：

```java
class OrderServiceImpl {
    
    // 假设BService提供用户的信息
    @Autowired
    BService bService;
    
    ...
    public Result order(String userId, Product product) throws ServiceException{
        // 判断用户是否年满18岁
        UserInfo userInfo = bService.getUserInfo(userId);
        if (userInfo.age < 18) {
            return Result(ErrorCode.Not18, "用户未满18岁");
        }
        ...
        return innerOrder(userId, product);
    }

    private Result innerOrder(...) {
        ...
        return innerinnerOrder(...);
    }

    ...

    private Result innerinnerOrder(String userId, Param1 param1, Param2 param2, ...) throws ServiceException {
        // 判断用户是否来自桦林市，有优惠
        UserInfo userInfo = bService.getUserInfo(userId);
        Discount discount = new Discount();
        if (userInfo.hometown == "桦林市") {
            discount = ...;
        } else {
            discount = ...;
        }
        ...
        return innerinnerinnerOrder(...);
    }

    private Result innerinnerinnerOrder(String userId, Param1 param1, Param2 param2, ...) throws ServiceException {
        // 发短信通知用户
        UserInfo userInfo = bService.getUserInfo(userId);
        cService.sendText(userInfo.telephone, "商家已接单");
        ...
        return innerinnerinnerinnerOrder(...);
    }
}
```

可以看到底层的函数中多次调用了BService来查询信息，其实这些数据在第一次调用时就已经知道了，这里多次调用会产生重复的RPC，入参还都是一样的，多次RPC调用带来了不必要的网络开销，也带来了多余的网络延时

底层的inner函数想要获取到上层的RPC结果，有两种方法：

1. 这些RPC结果作为参数层层下传，比如放到RequestContext结构体中，但这样写出来的代码就是像面条一样的代码，对业务代码入侵大，可读性差，扩展性差
2. 借助ThreadLocal，将RPC结果存于线程独立的缓存中，底层的inner函数读取ThreadLocal中对应的缓存即可，本文讨论的就是这种方案

## threadLocalRPCCache实现

还是以刚才点外卖为例，实际业务肯定比这个复杂，但不妨碍作为示例

首先定义RPCResultCacheDTO，该结构作为同一个线程中各RPC结果的缓存集合（简单起见，线程内对同个RPC的调用是幂等的）

```java
public class RPCResultCacheDTO {

    /*
     * BService的结果缓存
     */
    private UserInfo userInfo;

    /*
     * CService的结果缓存
     */
    private CResult cResult;

    /*
     * DService的结果缓存
     */
    private DResult dResult;

    ...
};
```

RPCResultCacheDTO作为ThreadLocal的value，在AServiceImpl中作为成员变量，初始化为null

```java
class AServiceImpl {
    @Autowired
    BService bService;

    // 线程私有变量，缓存RPC结果的缓存值，减少重复RPC调用，注意在切换线程（如并行流）时按需复制threadLocal变量，否则缓存失效
    ThreadLocal<RPCResultCacheDTO> threadLocalRPCCache = null;

    ...
    public Result order(String userId, Product product) throws ServiceException{
        // 判断用户是否年满18岁
        UserInfo userInfo = bService.getUserInfo(userId);
        if (userInfo.age < 18) {
            return Result(ErrorCode.Not18, "用户未满18岁");
        }
        ...
        return innerOrder(userId, product);
    }

}
```

AServiceImpl对外暴露的接口是order方法，所以threadLocalRPCCache的初始化order的入口即可

```java
class AServiceImpl {
    @Autowired
    BService bService;

    // 线程私有变量，缓存RPC结果的缓存值，减少重复RPC调用，注意在切换线程（如并行流）时按需复制threadLocal变量，否则缓存失效
    ThreadLocal<RPCResultCacheDTO> threadLocalRPCCache = null;

    ...
    public Result order(String userId, Product product) throws ServiceException{
        // 线程入口创建threadLocal
        threadLocalRPCCache = ThreadLocal.withInitial(RPCResultCacheDTO::new);

        // 判断用户是否年满18岁
        UserInfo userInfo = bService.getUserInfo(userId);
        if (userInfo.age < 18) {
            return Result(ErrorCode.Not18, "用户未满18岁");
        }
        ...
        return innerOrder(userId, product);
    }
}
```

接下来考虑threadLocalRPCCache如何读和写

threadLocalRPCCache作为线程内RPC结果的缓存，读写的流程如下

1. 优先读threadLocalRPCCache中对应RPC的结果，若有，则直接返回
2. 若threadLocalRPCCache没有对应RPC结果，则调RPC
3. 将RPC结果写进threadLocalRPCCache

于是，可以考虑将各RPC的调用封装起来，比如，对`bService.getUserInfo(userId)`这行代码调用，封装成 `getUserInfoWithCache(userId)` 方法：

```java
    // 优先读缓存的封装，异常原样抛出
    public UserInfo getUserInfoWithCache(String userId) throws ServiceException {
        UserInfo userInfo;
        RPCResultCacheDTO cacheDTO = threadLocalRPCCache.get();
        if (cacheDTO != null && cacheDTO.getUserInfo() != null) {
            userInfo = cacheDTO.getUserInfo();
        } else {
            userInfo = bService.getUserInfo(userId);
            if (cacheDTO != null) {
                cacheDTO.setUserInfo(userInfo);
                threadLocalRPCCache.set(cacheDTO);
            }
        }
        return userInfo;
    }
```

其他的RPC读取代码，依葫芦画瓢，以CService返回的cResult为例

```java
    // 优先读缓存的封装，异常原样抛出
    public UserInfo getCResultWithCache(String userId) throws ServiceException {
        CResult cResult;
        RPCResultCacheDTO cacheDTO = threadLocalRPCCache.get();
        if (cacheDTO != null && cacheDTO.getCResult() != null) {
            cResult = cacheDTO.getCResult();
        } else {
            cResult = cService.getCResult(userId);
            if (cacheDTO != null) {
                cacheDTO.setCResult(cResult);
                threadLocalRPCCache.set(cacheDTO);
            }
        }
        return cResult;
    }
```

原来调用代码，通通换成新方法，可以看到，代码入侵极小，完全不用动业务代码

```java
class AServiceImpl {
    @Autowired
    BService bService;

    // 线程私有变量，缓存RPC结果的缓存值，减少重复RPC调用，注意在切换线程（如并行流）时按需复制threadLocal变量，否则缓存失效
    ThreadLocal<RPCResultCacheDTO> threadLocalRPCCache = null;

    ...
    public Result order(String userId, Product product) throws ServiceException{
        // 线程入口创建threadLocal
        threadLocalRPCCache = ThreadLocal.withInitial(RPCResultCacheDTO::new);

        // 判断用户是否年满18岁
        UserInfo userInfo = getUserInfoWithCache(userId);
        if (userInfo.age < 18) {
            return Result(ErrorCode.Not18, "用户未满18岁");
        }
        ...
        return innerOrder(userId, product);
    }

    private Result innerOrder(...) {
        ...
        return innerinnerOrder(...);
    }

    ...

    private Result innerinnerOrder(String userId, Param1 param1, Param2 param2, ...) throws ServiceException {
        // 判断用户是否来自桦林市，有优惠
        UserInfo userInfo = getUserInfoWithCache(userId);
        Discount discount = new Discount();
        if (userInfo.hometown == "桦林市") {
            discount = ...;
        } else {
            discount = ...;
        }
        ...
        return innerinnerinnerOrder(...);
    }

    private Result innerinnerinnerOrder(String userId, Param1 param1, Param2 param2, ...) throws ServiceException {
        // 发短信通知用户
        UserInfo userInfo = getUserInfoWithCache(userId);
        cService.sendText(userInfo.telephone, "商家已接单");
        ...
        return innerinnerinnerinnerOrder(...);
    }

    // 优先读缓存的封装，异常原样抛出
    public UserInfo getUserInfoWithCache(String userId) throws ServiceException {
        UserInfo userInfo;
        RPCResultCacheDTO cacheDTO = threadLocalRPCCache.get();
        if (cacheDTO != null && cacheDTO.getUserInfo() != null) {
            userInfo = cacheDTO.getUserInfo();
        } else {
            userInfo = bService.getUserInfo(userId);
            if (cacheDTO != null) {
                cacheDTO.setUserInfo(userInfo);
                threadLocalRPCCache.set(cacheDTO);
            }
        }
        return userInfo;
    }
}
```

## 完善

threadLocalRPCCache从功能上来说已经实现了，但是不能就这样上线了，非出故障不可，threadLocal这个东西的使用一定要小心

贴一段ChatGPT的提示

```bash

threadlocal在什么地方容易踩坑？

ChatGPT3.5
静态变量和单例模式
在使用 ThreadLocal 进行线程隔离时，要注意静态变量和单例模式的使用。如果静态变量或单例模式对象中使用 ThreadLocal，那么所有线程都会共享这个对象，从而失去了 ThreadLocal 的隔离作用。

内存泄漏
ThreadLocal 对象在使用完毕后需要及时清理，否则会导致内存泄漏。由于 ThreadLocal 存在于 ThreadLocalMap 中，因此需要在线程结束时手动清理 ThreadLocalMap 中的数据，否则可能会导致内存泄漏。

循环引用
由于 ThreadLocal 对象是弱引用，因此在使用时要注意循环引用。如果线程中的对象引用了 ThreadLocal 对象，而 ThreadLocal 对象又引用了线程中的对象，就会导致循环引用，从而失去了垃圾回收的效果。

继承问题
如果在父线程中设置了 ThreadLocal 值，而在子线程中没有重新设置，那么子线程中的 ThreadLocal 值仍然是父线程中的值。这种情况可能会导致程序出现问题，因此要注意在子线程中重新设置 ThreadLocal 值。

线程池问题
在使用线程池时，由于线程可能会被重用，因此需要注意清除 ThreadLocal 中的值。否则可能会出现线程间数据混淆的问题。一般可以在线程池中的任务执行前后清除 ThreadLocal 中的值，以确保数据隔离的正确性。


如何清理threadlocal对象

ChatGPT3.5
清理 ThreadLocal 对象需要分别从两个方面考虑：

清理当前线程中的 ThreadLocalMap 中的数据
每个线程都有自己的 ThreadLocalMap 对象，其中存储了该线程中的所有 ThreadLocal 变量及其对应的值。在当前线程中，如果不再需要使用某个 ThreadLocal 变量时，需要手动调用 ThreadLocal 的 remove() 方法来清除对应的值，以避免内存泄漏。

例如：

ThreadLocal<String> threadLocal = new ThreadLocal<>();
threadLocal.set("value");
// do something
threadLocal.remove(); // 清除值
清理已经结束的线程中的 ThreadLocalMap 中的数据
在一些场景下，线程的生命周期可能比较短，可能出现线程结束了但是 ThreadLocalMap 中的数据没有被清理的情况。为了避免这种情况，可以使用 ThreadLocal 的静态方法 ThreadLocal.remove() 来清除已经结束的线程中的 ThreadLocalMap 中的数据。

例如：

ThreadLocal<String> threadLocal = new ThreadLocal<>();
threadLocal.set("value");
Thread thread = new Thread(() -> {
    // do something
});
thread.start();
thread.join();
threadLocal.remove(); // 清除已经结束的线程中的 ThreadLocalMap 中的数据
需要注意的是，ThreadLocal 的 remove() 方法只能清理当前线程中的 ThreadLocalMap 中的数据，不能清理其他线程中的数据。因此，如果一个 ThreadLocal 变量在多个线程中都有使用，需要每个线程中都调用 remove() 方法来清理对应的值。
```

回头看看点外卖的业务代码，order方法会对上层抛出ServiceException，假设这个异常是由bService抛出的，我们引入threadLocalRPCCache的目的是：在变更任何业务逻辑情况下，缓存重复RPC的结果，所以封装方法`getUserInfoWithCache`得原样抛出异常

假设在调用CService（代码中并未给出）时抛异常了，threadLocalRPCCache中已保存BService的UserInfo，这部分内存会被泄露，具体可参考[探秘Java中的ThreadLocal](./探秘Java中的ThreadLocal.md)

所以别忘了在线程结束前清理threadLocal，因为threadLocalRPCCache是AServiceImpl的成员，所以在order方法最后用finally确保threadLocalRPCCache已remove即可

```java
    public Result order(String userId, Product product) throws ServiceException{
        try {
            // 线程入口创建threadLocal
            threadLocalRPCCache = ThreadLocal.withInitial(RPCResultCacheDTO::new);

            // 判断用户是否年满18岁
            UserInfo userInfo = getUserInfoWithCache(userId);
            if (userInfo.age < 18) {
                return Result(ErrorCode.Not18, "用户未满18岁");
            }
            ...
            return innerOrder(userId, product);
        } finally {
            // 无论是否抛异常，线程结束前需要清理threadLocal
            threadLocalRPCCache.remove();
        }
    }
```

## 切换线程后如何保证threadlocal一致？

即使确保threadLocal最后能正确remove防止内存泄漏，但还是有坑需要注意，那就是在业务线程中切换线程后，threadLocal会变成新的，之前的缓存值无法读取到

典型的例子就是在内部的业务代码中使用了parallel stream，它会默认从 ForkJoinPool 线程池中选取新的线程，并行地执行业务代码，见：

[微服务架构下的Java Parallel Stream实践——优化RT与串联traceid](./微服务架构下的Java Parallel Stream实践——优化RT与串联traceid.md)

traceid也是存放于threadLocal中的，RPC结果缓存其实与traceid一样，其实复用同种处理方法即可

> 『异步线程时需要手动传递上下文，当业务逻辑转移到异步线程时，需要先备份 EagleEye 的调用上下文到异步任务中，保证链路的正确性。』

示例如下：

```java
    private void handleXXX(List<Data> datas) throws ServiceException {
        Object ctx = EagleEye.getRpcContext();
        // 并行流中调用会创建新线程处理数据，所以需要拷贝threadLocal变量
        RPCResultCacheDTO currentCache = threadLocalRPCCache.get();
        try {
            datas.parallelStream()
                .forEach(data -> {
                    EagleEye.setRpcContext(ctx);
                    threadLocalRPCCache.set(currentCache);
                    try {
                        innerHandleXXX(data);
                    } catch (ServiceException e) {
                        // 若出现异常则向上层抛出
                        Asserts.assertThat(false, ExceptionType.CLIENT_ERROR, e.getErrorCode(), e.getMessage());
                    } finally {
                        // 务必清理 ThreadLocal 的上下文，避免异步线程复用时出现上下文互串的问题
                        EagleEye.clearRpcContext();
                        threadLocalRPCCache.remove();
                    }
                });
        } finally {
            // forkjoin线程池可能复用主线程，在主线程中执行EagleEye.clearRpcContext()，所以这里需要恢复
            EagleEye.setRpcContext(ctx);
        }
    }
```

内层的try catch finally，是为了确保异常能向上层抛出，并且每个并行线程在结束的时候都要调用threadLocalRPCCache防止内存泄漏

外层try finally，是为了恢复eagleeye的上下文信息