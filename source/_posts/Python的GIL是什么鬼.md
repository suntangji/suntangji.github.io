---
title: Python的GIL是什么鬼
date: 2018-06-10 08:50:46
tags: 学习笔记
category: Python
---
GIL并不是Python的特性，它是在实现Python解析器(CPython)时所引入的一个概念。并不是所有的解释器都有GIL，Cpython、Pypy使用了GIL，Jython就没有GIL机制。
<!--more-->

### Python多线程伪并行?
作为一门优秀的语言，python 为我们提供了操纵线程的库 threading。使用threading，我们可以很方便地进行并行编程。但下面的例子可能会让你对“并行”的真实性产生怀疑。
启用n个线程分别计算斐波那契, 我的电脑配置4核，Python解释器Cpython

``` python
from time import time
from threading import Thread


def spawn_n_threads(n, target):
    """
   启动 n 个线程并行执行 target 函数
   """
    threads = []
    for _ in range(n):
        thread = Thread(target=target)
        thread.start()
        threads.append(thread)
    for thread in threads:
        thread.join()


def fib():
    a = b = 1
    for i in range(1000000): # 为了忽略线程调度时间，使用了较大的数
        a, b = b, a + b


def test(n=1, target=fib):
    start_time = time()
    spawn_n_threads(n, target)
    end_time = time()
    print('Time {:.6f} s'.format(end_time - start_time))


if __name__ == '__main__':
    test()

```
直接结果让我们大吃一惊
1个线程
> Time 10.831081 s

2个线程
> Time 21.491747 s

4个线程
> Time 42.506053 s

我们使用多线程就是为了利用CPU的多核资源，但是CPU的多核资源明显没有被充分利用，这就是GIL搞得鬼。

### GIL是什么鬼
GIL全称Global Interpreter Lock (全局解释锁), 是部分解释器的核心部件，官方的解释
> The Python interpreter is not fully thread-safe. In order to support multi-threaded Python programs, there’s a global lock, called the global interpreter lock or GIL, that must be held by the current thread before it can safely access Python objects.

可见，Python解释器不是线程安全的，这是一个用于保护Python对象的全局锁，用于保证解释器的线程安全。

### 如何解决GIL
既然GIL使多线程效率低下，我们可以使用以下方法降低GIL的影响

- 使用多进程
线程间会竞争资源是因为它们共享同一个进程空间，但进程的内存空间是独立的，自然也就没有必要使用全局解释锁了。但是进程创建、切换的开销比较大，此时可以使用进程池减少创建进程的开销。

使用多进程进行计算
``` python
from multiprocessing import Process
from time import time


def spawn_n_processes(n, target):
    threads = []
    for _ in range(n):
        thread = Process(target=target)
        thread.start()
        threads.append(thread)
    for thread in threads:
        thread.join()


def fib():
    a = b = 1
    for i in range(1000000):
        a, b = b, a + b


def test(n=1, target=fib):
    start_time = time()
    spawn_n_processes(n, target)
    end_time = time()
    print('Time {:.6f} s'.format(end_time - start_time))


if __name__ == '__main__':
    test(4)

```
4个进程
> Time 22.125205 s

使用多进程才真正实现了并行，与多线程相比时间显著减少。

- 使用C扩展
GIL 并不是完全的黑箱，CPython 在解释器层提供了控制 GIL 的开关, 这就是 Py_BEGIN_ALLOW_THREADS 和 Py_END_ALLOW_THREADS 宏。这一对宏允许你在自定义的 C 扩展中释放 GIL，从而可以重新利用多核的优势。

### GIL的第二种释放时机
除了调用 Py_BEGIN_ALLOW_THREADS，解释器还会在发生阻塞 IO（如网络、文件）时释放 GIL。发生阻塞 IO 时，调用方线程会被挂起，无法进行任何操作，直至内核返回；IO 函数一般是原子性的，这确保了调用的线程安全性。因此在大多数阻塞 IO 发生时，解释器没有理由加锁。

### 小结
- GIL其实是功能和性能之间权衡后的产物，它尤其存在的合理性
- 由于 GIL 的存在，大多数情况下 Python 多线程无法利用多核优势。
- C 扩展中可以接触到 GIL 的开关，从而规避 GIL，重新获得多核优势。
- IO 阻塞时，GIL 会被释放。