---
title: Python可变与不可变对象
date: 2018-04-24 13:15:17
tags: 学习笔记
category: python
---
Python的变量实际上对内存值(内存上存放的数据)的引用，根据内存值是否可变，把对象分为可变和不可变对象。
<!--more-->
- 不可变
  数值类型(int和float等)、str(字符串)、tuple(元组)
- 可变
  list(列表)、dict(字典)、自定义的类

根据可变对象和不可变对象Python的工作方式是不同的
- 对于不可变对象
1. 首先在内存中找相同的内存值，若没有则开辟新内存存放内存值。
2. 然后把变量引用到内存。
- 对于可变对象
1. 直接开辟内存保存内存值
2. 把变量引用到内存

做一个小实验
``` python
In [1]: a = 1

In [2]: b = 1

In [3]: a is b
Out[3]: True

In [4]: id(a)
Out[4]: 9330048

In [5]: id(b)
Out[5]: 9330048

In [6]: a == b
Out[6]: True

In [7]: la = [1]

In [8]: lb = [1]

In [9]: la == lb
Out[9]: True

In [10]: la is lb
Out[10]: False

In [11]: id(la)
Out[11]: 140540456082760

In [12]: id(lb)
Out[12]: 140540394530056

```
> id查看的是它们在内存中的id值,也就是内存中的位置
> is关键字是比较它们的id
> ==比较的是它们的值，也就是内存中的数据

可变对象与不可变对象的赋值
``` python
In [13]: lc = lb

In [14]: lc == lb
Out[14]: True

In [15]: lc is lb
Out[15]: True

In [16]: lc.append(2)

In [17]: lc == lb
Out[17]: True

In [18]: lc is lb
Out[18]: True

In [19]: lb
Out[19]: [1, 2]

In [20]: c = b

In [21]: c
Out[21]: 1

In [22]: c = 2

In [23]: b
Out[23]: 1

In [24]: c is b
Out[24]: False

```
可以得到这样一个表格

变量 | a is b | a == b
:---:|:---:|:---:
a = 1; b = 1 | True | True
a = 1; b = a | True | True
a = [1]; b = [1] | False | True
a = [1]; b = a | True | True

小结
- 两个不可变对象初始化时的值相同时，引用同一块内存
- 两个可变对象初始化时的值相同时，引用不同的内存
- 一个不可变对象拷贝时使用写时拷贝，所以id是相同的，改变该对象后会重新开辟内存所以id又变为不同
- 一个可变对象拷贝后就是一个以前对象的引用，该对象改变后id也不再变化

可变对象和不可变对象作为函数参数
``` python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

a = 1


def fun(arg):
    print(arg is a)
    arg = 2
    print(arg is a)


fun(a)
print(a)


```
运行结果为
> True
False
1

``` python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

a = [1]


def fun(arg):
    print(arg is a)
    arg.append(2)
    print(arg is a)


fun(a)
print(a)

```
运行结果为
> True
True
[1, 2]

