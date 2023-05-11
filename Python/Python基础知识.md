

## Python闭包

概念：在一个内部函数中，对外部作用域的变量进行引用，并且一般外部函数的返回值为内部函数，那么内部函数就被认为是闭包

作用：闭包可以保存当前的运行环境，闭包在爬虫以及web应用中都有很广泛的应用，并且闭包也是装饰器的基础

理解：闭包=函数块+定义函数时的环境，inner就是函数块，x就是环境

注意：闭包无法修改外部函数的局部变量

举个例子：

在函数startAt中定义了一个incrementBy函数，incrementBy访问了外部函数startAt的变量，并且函数返回值为incrementBy函数（注意python是可以返回一个函数的，这也是python的特性之一）

```python
>>> def startAt(x):
...     def incrementBy(y):
...             return x+y
...     return incrementBy
>>> a = startAt(1) # a是函数incrementBy而不是startAt
>>> a
<function startAt.<locals>.incrementBy at 0x107c8e290>
>>> a(1)
2
```

## Python装饰器

装饰器本质上是一个Python函数，它可以让其他函数在不需要做任何代码变动的前提下增加额外功能，装饰器的返回值也是一个函数对象

本质上，decorator就是一个返回函数的高阶函数。

假设我们要定义一个能打印日志的decorator，代码如下：

log是一个decorator，接受一个函数作为参数，并返回一个函数。

```python
def log(func):
    def wrapper(*args, **kw):
        print('call %s():' % func.__name__)
        return func(*args, **kw)
    return wrapper

@log  # 借助Python的@语法，把decorator置于函数的定义处：
def now():
    print('2015-3-25')
```

调用now()函数，不仅会运行now()函数本身，还会在**运行now()函数前**打印一行日志：

```shell
>>> now()
call now():
2015-3-25
```

## Python生成器

列表生成式：Python提供了生成器，使用`()`，**列表元素可以按照某种算法推算出来**，相比于列表`[]`，节省了大量空间

带有yield的函数：如果一个函数定义中包含yield关键字，那么这个函数就不再是一个普通函数，而是一个generator

generator保存的是算法，每次调用next(g)，就计算出g的下一个元素的值，直到计算到最后一个元素，没有更多的元素时，抛出StopIteration的错误。

但是每次都调用next太麻烦，可以用for循环

```python
>>> L = [x * x for x in range(10)]
>>> L
[0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
>>> g = (x * x for x in range(10))
>>> g
<generator object <genexpr> at 0x1022ef630>
>>> next(g)
0
>>> next(g)
1
>>> g = (x * x for x in range(10))
>>> for n in g:
...     print(n)
...
0
1
4
9
16
```
