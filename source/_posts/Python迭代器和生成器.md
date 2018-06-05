---
title: Python迭代器和生成器
date: 2018-05-02 20:37:03
tags: 学习笔记
category: python
---
首先我们要理解迭代器(iterators)。根据维基百科，迭代器是一个让程序员可以遍历一个容器
的对象。
<!--more-->
生成器(generators)是一种特殊的迭代器，要理解生成器需要了解
- 可迭代对象(Iterable)
- 迭代器(Iterator)
- 迭代(Iteration)

#### 可迭代对象
Python中的任意对象，只要它定义了一个可以返回一个迭代器的__iter__方法，或者定义了可以支持下标索引的__getitem__方法，那么它就是一个可迭代对象。可迭代对象就是能提供迭代器的任意对象。

#### 迭代器
任意对象只要定义了__iter__() 和 next() 两个方法就是迭代器。前者返回迭代器对象，后者依次返回数据，直
到引发 StopIteration 异常结束。

#### 迭代
从某个容器取出元素的过程，当我们用循环遍历一个列表时这个过程就叫迭代。

#### 生成器
生成器也是一种迭代器，但是只能对它迭代一次，这是因为它并没有把所有的值存储在内存中，而是在运行时动态的生成一个值。
``` python
In [1]: L = [x*x for x in range(10)]

In [2]: L
Out[2]: [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

In [3]: g = (x*x for x in range(10))

In [4]: g
Out[4]: <generator object <genexpr> at 0x7f5c1365e888>

In [5]: next(g)
Out[5]: 0

In [6]: next(g)
Out[6]: 1

In [7]: next(g)
Out[7]: 4

```
创建L和g的区别仅仅是最外层的是列表和元组，L是一个列表，g是一个生成器。我们可以使用next(g)去遍历生成器，但是这样元素过多太麻烦了，而且没有元素时会抛出一个StopIteration异常。我们可以使用for循环去遍历生成器，因为生成器也是可迭代对象。
``` python
In [9]: for x in g:
   ...:     print(x)
   ...:     
9
16
25
36
49
64
81

```
复杂的生成器使用for循环无法生成，我们需要使用yield关键字。
使用生成器实现斐波那契数列
``` python
In [10]: def fib(max):
    ...:     n, a, b = 0, 0, 1
    ...:     while n < max:
    ...:         yield b
    ...:         a, b = b,a + b
    ...:         n = n + 1
    ...:     return 'done'
    ...: 
    ...: 

In [11]: f = fib(6)

In [12]: f
Out[12]: <generator object fib at 0x7f5c1365ea40>
In [14]: f.__next__()
Out[14]: 1

In [15]: f.__next__()
Out[15]: 1

In [16]: f.__next__()
Out[16]: 2

In [17]: f.__next__()
Out[17]: 3

In [18]: f.__next__()
Out[18]: 5

In [19]: f.__next__()
Out[19]: 8

In [20]: f.__next__()
---------------------------------------------------------------------------
StopIteration                             Traceback (most recent call last)
<ipython-input-20-dcf180275632> in <module>()
----> 1 f.__next__()

StopIteration: done

```
编译器魔法会将包含 yield 的⽅方法 (或函数) 重新打包，使其返回 Generator 对象。这样⼀一来，就
⽆无须废⼒力⽓气维护额外的迭代器类型了。

#### 协程
yield 为何能实现这样的魔法？这涉及到协程 (coroutine) 的工作原理。
协程，又称微线程。协程看上去也是子程序，但执行过程中，在子程序内部可中断，然后转而执行别的子程序，在适当的时候再返回来接着执行。协程最大的优势就是极高的执行效率。因为子程序切换不是线程切换，而是由程序自身控制，因此，没有线程切换的开销，和多线程比，线程数量越多，协程的性能优势就越明显。第二大优势就是不需要多线程的锁机制，因为只有一个线程，也不存在同时写变量冲突，在协程中控制共享资源不加锁，只需要判断状态就好了，所以执行效率比多线程高很多。
``` python
In [21]: def coroutine():
    ...:     print("coroutine start")
    ...:     result = None
    ...:     while True:
    ...:         s = yield result
    ...:         result = s.split(",")
    ...:         

In [22]: c = coroutine()

In [23]: next(c)
coroutine start

In [24]: c.send("a,b")
Out[24]: ['a', 'b']

In [25]: c.close()

In [26]: c.send("c,d")
---------------------------------------------------------------------------
StopIteration                             Traceback (most recent call last)
<ipython-input-26-5903fab599a9> in <module>()
----> 1 c.send("c,d")

StopIteration: 

```
协程的执行流程
- 创建协程对象后，必须使用send(None)或next()启动
- 协程在运行yield result后让出执行绪，等待消息
- 调用方发送send("a,b")消息，协程恢复执行将接收到的数据保存到s,执行后续流程

虽然⽣生成器 yield 能轻松实现协程机制，但离真正意义上的⾼高并发还有不⼩小的距离。可以考虑使⽤用
成熟的第三⽅方库，⽐比如 gevent/eventlet，或直接⽤用 greenlet。

#### 利用协程实现生产者消费者模型
``` python
def consumer():
    r = ''
    while True:
        n = yield r
        if not n:
            return
        print('consumeing %s' % n)
        r = '200 ok'


def procude(c):
    c.send(None)
    n = 0
    while n < 5:
        n = n + 1
        print('procuding %s' % n)
        r = c.send(n)
        print('consumer return: %s' % r)
    c.close()


c = consumer()
procude(c)

```
运行结果
> procuding 1
consumeing 1
consumer return: 200 ok
procuding 2
consumeing 2
consumer return: 200 ok
procuding 3
consumeing 3
consumer return: 200 ok
procuding 4
consumeing 4
consumer return: 200 ok
procuding 5
consumeing 5
consumer return: 200 ok


