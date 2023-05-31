## 背景

1. 在业务开发中，需要将一些图片mediaId批量调用多媒体服务的接口（FileService#copyMedia），从而实现图片替换的功能
2. 具体链路如下，客户端RT可认为从一个请求从发出到响应的经过时间：

```shell
用户客户端 --> MyService --> FileService#copyMedia
                 ↓
             LaterService
                 ↓
用户客户端 <--   ....
```

## 第一版代码

1. 因为项目工期较紧，第一版代码重点主要在功能完整性和准确性上，当时的做法是批量解析图片id，再批量调接口，再批量替换原位
2. 在跨团队的开发联调与端到端测试后，第一版代码发布上线了，功能符合预期，也没啥bug，就是我们的报警群经常报rpc timeout的报警，客户端接口的RT也涨了不少（特别是99分位RT）
3. 经过定位发现，copyMediaId接口会去访问oss生成新的mediaId，当资源跨地域时，RT显著增大，而且有些特定行业的用户（如电商）可能请求中有30、40张图片，这对copyMediaId接口造成极大的压力，RT增大是在所难免的，从而直接影响了客户端接口的RT，虽无用户直接反馈，但我们推测这个RT还是会或多或少地影响用户体验，所以要考虑如何优化RT

> 阿里云对象存储OSS介绍：https://help.aliyun.com/document_detail/31827.html

## 第二版代码

1. 我们的目标是优化客户端接口RT，而这次需求唯一引入的外部依赖就是copyMediaId接口，所以首先考虑的是copyMediaId接口的优化，但毕竟跨团队，优化意愿不强烈，于是就想着在我们内部闭环掉
2. 调研后发现，发现Java8的Parallel Stream可以很好地帮我们解决问题，Parallel Stream利用了Java自身的ForkJoin线程池，借助函数式编程思想做了非常强大的封装，使得开发者编写多线程并发代码就像编写单线程代码那样简单（至少给我的感觉是这样）
> ForkJoin：默认线程池是是CPU数量-1
The parallel streams use the default ForkJoinPool.commonPool which by default has one less threads as you have processors, as returned by Runtime.getRuntime().availableProcessors() (This means that parallel streams leave one processor for the calling thread).
https://stackoverflow.com/questions/45460577/default-forkjoinpool-executor-taking-long-time
3. 注意并发流不保证执行顺序，所以如果要保序的话得自己再弄一下（因为我得按顺序替换到原消息体的mediaId的位置，所以得保序），很快，就写出了第二版代码（省去无关代码）：

```java
   public MediaCopyResponse mediaCopy(..., List<String> validMediaIds) throws ServiceException {
        ext = .....
        // 并发调用
        MediaCopyResponse resp = concurrentCopyMedia(..., ext, validMediaIds);
        // 并发调用可能会乱序，最后要按原顺序排序，排序也可以在parallel stream中直接做掉
        resp.setModels(getSortedMediaIds(resp.getModels(), validMediaIds));
        return resp;
    }

    /**
     * @description 分批调用copyMedia接口缓解超时问题
     */
    private MediaCopyResponse concurrentCopyMedia(..., Map<String, String> ext, List<String> validMediaIds) {
        MediaCopyResponse resp = new MediaCopyResponse();
        int mediaIdBatchSize = ....
        List<MediaIdModel> mediaIdModels = Lists.partition(validMediaIds, mediaIdBatchSize)
                .stream()
                .parallel()
                .map(subList -> {
                    try {
                        MediaCopyRequest req = new MediaCopyRequest();
                        req.setMediaIds(subList);
                        req.set...

                        final ServiceResult<MediaCopyResponse> sr = fileService.copyMedia(req, null, null);
                    
                        // 注意对应关系：sublist -> List<MediaIdModel>，最后并发流会把所有的List<MediaIdModel>拼起来
                        return sr.getResult().getModels();
                    } finally {
                        // 务必清理 ThreadLocal 的上下文，避免异步线程复用时出现上下文互串的问题
                        EagleEye.clearRpcContext();
                    }
                })
                .flatMap(List::stream)
                .collect(Collectors.toList());
        resp.setModels(mediaIdModels);
        return resp;
    }
```

4. 调了会参，决定了每批分批的数量，arthas帮了很大的忙

    > arthas: https://github.com/alibaba/arthas

5. 嗯，代码看上去很完美了，也没有bug，经过测试也不会有mediaId乱序的问题，上线！
6. 上线一切岁月静好，但在后来的一次排查问题时，发现traceid断了，这会对我们的后期运维会带来极大的麻烦

> 阿里巴巴Eagleeye，一款分布式追踪工具，与Google的Dapper很像，能够把微服务架构中的各个服务串联起来，参考：https://www.alibabacloud.com/blog/alibaba-eagleeye-ensuring-business-continuity-through-link-monitoring_594157
> 美团技术团队的这篇文章很完整地描述了traceid丢失的现象与本质：https://mp.weixin.qq.com/s/T7P2-tiroXWI9xd8FhsuFA

## 第三版代码
1. traceid信息其实放在ThreadLocal里面，写Java的同学或多或少都了解过，经过搜索，发现Eagleeye已有对策
2. 『异步线程时需要手动传递上下文，当业务逻辑转移到异步线程时，需要先备份 EagleEye 的调用上下文到异步任务中，保证链路的正确性。』
3. 加几行代码，收工！

```java
    private MediaCopyResponse concurrentCopyMedia(..., Map<String, String> ext, List<String> validMediaIds) {
        MediaCopyResponse resp = new MediaCopyResponse();
        int mediaIdBatchSize = xxx
        Object ctx = EagleEye.getRpcContext();
        List<MediaIdModel> mediaIdModels = Lists.partition(validMediaIds, mediaIdBatchSize)
                .stream()
                .parallel()
                .map(subList -> {
                    EagleEye.setRpcContext(ctx);
                    try {
                        MediaCopyRequest req = new MediaCopyRequest();
                        req.setMediaIds(subList);
                        req.setxxx
                        final ServiceResult<MediaCopyResponse> sr = fileService.copyMedia(req, null, null);
                      
                        return sr.getResult().getModels();
                    } finally {
                        // 务必清理 ThreadLocal 的上下文，避免异步线程复用时出现上下文互串的问题
                        EagleEye.clearRpcContext();
                    }
                })
                .flatMap(List::stream)
                .collect(Collectors.toList());
        // forkjoin线程池可能复用主线程，在主线程中执行EagleEye.clearRpcContext()，所以这里需要恢复
        EagleEye.setRpcContext(ctx);
        resp.setModels(mediaIdModels);
        return resp;
    }
```

## 结果

优化RT：


串联traceid：

## 后记——优化

parallelStream默认使用全局的ForkJoinPool，这可能会影响其他任务，最好是一个业务自己维护一个ForkJoinPool

在spring boot框架中，可以通过bean注入很方便地管理ForkJoinPool的生命周期

```java
@Configuration
class BeanConfiguration {
    // 通过bean管理，自动销毁，forJoinPool默认线程池数量为CPU数量-1
    @Bean
    public ForkJoinPool customForkJoinPool() {
        return new ForkJoinPool();
    }
};

class MyService {
    @Autowired
    private ForkJoinPool customForkJoinPool;

        private MediaCopyResponse concurrentCopyMedia(..., Map<String, String> ext, List<String> validMediaIds) {
        MediaCopyResponse resp = new MediaCopyResponse();
        int mediaIdBatchSize = xxx
        Object ctx = EagleEye.getRpcContext();
        try {
            customForkJoinPool.submit(() -> {
                List<MediaIdModel> mediaIdModels = Lists.partition(validMediaIds, mediaIdBatchSize)
                        .stream()
                        .parallel()
                        .map(subList -> {
                            EagleEye.setRpcContext(ctx);
                            try {
                                MediaCopyRequest req = new MediaCopyRequest();
                                req.setMediaIds(subList);
                                req.setxxx
                                final ServiceResult<MediaCopyResponse> sr = fileService.copyMedia(req, null, null);
                            
                                return sr.getResult().getModels();
                            } finally {
                                // 务必清理 ThreadLocal 的上下文，避免异步线程复用时出现上下文互串的问题
                                EagleEye.clearRpcContext();
                            }
                        })
                        .flatMap(List::stream)
                        .collect(Collectors.toList());
                resp.setModels(mediaIdModels);
            });
        } finally {
            // forkjoin线程池可能复用主线程，在主线程中执行EagleEye.clearRpcContext()，所以这里需要恢复
            EagleEye.setRpcContext(ctx);
        }
        return resp;
    }
}

如果想设置超时时间，可以调用在submit后调用get(time, timeunit)

```java
        try {
            customForkJoinPool.submit(() -> {

            }).get(3, TimeUnit.SECONDS);
        } catch (ExecutionException | InterruptedException | TimeoutException e) {
            log.error("customForkJoinPool error", e);
        } finally {
            // forkjoin线程池可能复用主线程，在主线程中执行EagleEye.clearRpcContext()，所以这里需要恢复
            EagleEye.setRpcContext(ctx);
        }
```

更特别地，如果在内部的业务代码中有自定义的业务异常需要向上层抛出，这种写法是抛不出去的，因为内层的ServiceException被包裹在了ExecutionException中，需要单独判断

Exception包裹有两种方法：
1. 要么是通过RuntimeException中包裹进来，再特殊判断（下文ChatGPT的做法）
2. 或者如果业务代码中有实现SneakyThrow注解，就不需要用RuntimeException包裹，代码如下

```java
        try {
            customForkJoinPool.submit(() -> {

            }).get(3, TimeUnit.SECONDS);
        } catch (ExecutionException | InterruptedException | TimeoutException e) {
            // 捕获线程池相关exception，内部的业务异常ServiceException被包裹在了ExcutionException，仍然按原逻辑往上层抛出
            Throwable cause = e.getCause();
            if (cause instanceof ServiceException) {
                throw (ServiceException) cause;
            } else {
                log.error(getLogMsg("customForkJoinPool error"), e);
            }
        } finally {
            // forkjoin线程池可能复用主线程，在主线程中执行EagleEye.clearRpcContext()，所以这里需要恢复
            EagleEye.setRpcContext(ctx);
        }
```

附：询问ChatGPT的回答

Q:

what about using my self-defined forkjoinpool?

ChatGPT3.5:

If you're using a custom ForkJoinPool, you can still propagate a ServiceException from a parallel stream operation by using a similar approach. Here's an example:

```java
ForkJoinPool customPool = new ForkJoinPool(4); // create a custom pool with 4 threads
List<MyObject> myList = ...; // your list of objects
try {
    customPool.submit(() -> {
        myList.parallelStream().forEach(obj -> {
            try {
                // your parallel stream operation here
                if (obj.someCondition()) {
                    throw new ServiceException("Some error occurred."); // throw a ServiceException if needed
                }
            } catch (ServiceException e) {
                throw new RuntimeException(e); // wrap the ServiceException in a RuntimeException and throw it
            }
        });
    }).get(); // wait for the task to complete
    // handle successful completion
} catch (InterruptedException | ExecutionException e) {
    Throwable cause = e.getCause();
    if (cause instanceof RuntimeException && cause.getCause() instanceof ServiceException) {
        throw (ServiceException) cause.getCause(); // propagate the ServiceException to the calling method
    } else {
        // handle other exceptions
    }
} finally {
    customPool.shutdown(); // shutdown the pool
}
```

In this example, we create a custom ForkJoinPool object with 4 threads, and submit a Runnable task to it that executes a parallel stream operation on the myList collection. Inside the lambda expression, we handle any ServiceException that may be thrown by the operation by wrapping it in a RuntimeException and re-throwing it.

We then use the get() method of the Future returned by the submit() method to wait for the task to complete. If any exception was thrown during processing, the get() method will throw an ExecutionException that wraps the original exception.

We handle the ExecutionException by getting the cause of the exception using the getCause() method. If it is an instance of RuntimeException and its cause is an instance of ServiceException, we propagate the ServiceException to the calling method using the throw statement. Otherwise, we handle it as an other exception.

Finally, we shutdown the custom pool in the finally block to release resources.


> 原文发表于 2023-02-19