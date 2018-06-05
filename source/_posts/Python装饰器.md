---
title: Python装饰器
date: 2018-05-25 20:58:16
tags: 学习笔记
category: python
---
装饰器是修改其他函数功能的函数，通过返回包装对象实现间接调用，以此来插入额外的逻辑。
<!--more-->
### 要理解装饰器需要先了解Python的几个特性
-  一切皆对象，函数也是对象

``` python
In [1]: def say_hello():
   ...:     print("hello world")
   ...:     

In [2]: say_hello()
hello world

In [3]: func_obj = say_hello

In [4]: func_obj
Out[4]: <function __main__.say_hello()>

In [5]: del say_hello

In [6]: say_hello
---------------------------------------------------------------------------
NameError                                 Traceback (most recent call last)
<ipython-input-6-b5d8479d2c29> in <module>()
----> 1 say_hello

NameError: name 'say_hello' is not defined

In [7]: func_obj
Out[7]: <function __main__.say_hello()>

In [8]: func_obj()
hello world

```
函数可以赋值给另一个对象，函数也可以删除
- 函数中可以定义函数

``` python
In [9]: def outer():
   ...:     def inner():
   ...:         print("inner")
   ...:     print("outer")
   ...:     

In [10]: outer()
outer

In [11]: inner()
---------------------------------------------------------------------------
NameError                                 Traceback (most recent call last)
<ipython-input-11-bc10f1654870> in <module>()
----> 1 inner()

NameError: name 'inner' is not defined

```
- 函数可以返回函数

``` python
In [12]: def outer():
    ...:     def inner():
    ...:         print("inner")
    ...:     return inner
    ...: 
    ...: 

In [13]: outer
Out[13]: <function __main__.outer()>

In [14]: outer()
Out[14]: <function __main__.outer.<locals>.inner()>

In [15]: outer()()
inner

```
- 函数可以作为参数

``` python
In [16]: def outer(func):
    ...:     func()
    ...:     

In [17]: def func():
    ...:     print("func")
    ...:     

In [18]: outer(func)
func

```
### 实现一个装饰器
在函数执行前后分别打印日志
``` python
In [3]: def wrapper(func):
   ...:     def inner():
   ...:         print("before func exec")
   ...:         func()
   ...:         print("after func exec")
   ...:     return inner
   ...: 
   ...: 

In [4]: @wrapper
   ...: def test():
   ...:     print("test")
   ...:     

In [5]: test()
before func exec
test
after func exec

```
@是装饰器的语法糖
> @wrapper
> def test():
 
等价于
> test = wrapper(test)

### 装饰器有什么用
1. 代码复用
比如打印日志的函数，不再需要为每一个函数设计日志逻辑，只需要加上一个装饰器就可以了
2. 不需要修改调用者的代码
如果一个函数被调用了很多次，不使用装饰器就需要每调用一次就修改一处代码，使用装饰器只需要在定义处修改一次，调用者完全不用关心。

### 装饰器的使用场景
装饰器可以用于认证、日志等，Flask框架使用装饰器来装饰路由

### 带参数的装饰器
``` python
def log(log_file='1.log'):
    def wrapper(func):
        def inner(*args, **kwargs):
            log = func.__name__ + " was called"
            print(log)
            with open(log_file, 'a') as opened_file:
                opened_file.write(log + '\n')
            return func(*args, **kwargs)

        return inner

    return wrapper


@log()
def test():
    pass


test()

```
带参数的装饰器本质上就是又加了一层函数，该函数返回一个包裹函数
> @log()
> def test():

等价于
> test = log()(test)

所以特别需要注意，尽管log使用了默认参数，也必须加上括号，这样才会执行三层函数。不加括号，test作为log的参数，wrapper函数就没有参数从而出错。

### 类装饰器
函数装饰器是将函数作为参数，类装饰器就是把类对象作为函数参数
使用类装饰器实现单例模式
``` python
def singleton(cls):
    class wrap(cls):
        def __new__(cls, *args, **kwargs):
            o = getattr(cls, "__instance__", None)
            if not o:
                o = object.__new__(cls)
                cls.__instance__ = o

            return o

    return wrap


@singleton
class A(object):
    pass


class B(object):
    pass


a = A()
b = A()
print(a is b)  # True
c = B()
d = B()
print(c is d)  # False

```

### functools.wraps
functools.wraps 是装饰器的装饰器，它的作⽤用是将原函数对象的指定属性复制给包装函数对象,默认有 __module__、__name__、__doc__，或者通过参数选择。
``` python
def wrapper(func):
    def inner():
        print("before func exec")
        func()
        print("after func exec")

    return inner


@wrapper
def test():
    print("test")


def test2():
    pass


print(test2.__name__)  # test2
print(test.__name__)  # inner

```
我们使用装饰器装饰过的函数不想改变函数的属性，但是现在已经改变了，还好有functools.wraps
``` python
from functools import wraps


def wrapper(func):
    @wraps(func)
    def inner():
        print("before func exec")
        func()
        print("after func exec")

    return inner


@wrapper
def test():
    print("test")


def test2():
    pass


print(test2.__name__)  # test2
print(test.__name__)  # test

```