---
title: Python函数参数
date: 2018-04-24 14:25:09
tags: 学习笔记
category: Python
---
Python的函数参数分为，位置参数、默认参数、可变参数、关键字参数
<!--more-->
### 位置参数
位置参数就是按照一定顺序传递的参数
求平方的函数
``` python
In [10]: def power(x):
    ...:     return x * x
    ...: 
    ...: 

In [11]: power(3)
Out[11]: 9

```
参数x就是一个位置参数

### 默认参数
现在我不想仅仅求平方啦，想让该函数默认求平方，也可以传一个参数表示几次方
``` python
In [14]: def power(x,n=2):
    ...:     s = 1
    ...:     while n > 0:
    ...:         n = n - 1
    ...:         s = s * x
    ...:     return s
    ...: 
    ...: 

In [15]: power(3)
Out[15]: 9

In [16]: power(3,3)
Out[16]: 27

```
2就是n的默认参数，如果我们不传n就是2,如果我们传了就是我们传递的参数
> 使用默认参数时，需要必选参数在前，默认参数在后

默认参数的坑
``` python
In [1]: def add_one(L=[]):
   ...:     L.append(1)
   ...:     return L
   ...: 
   ...: 

In [2]: L = []

In [3]: L = add_one(L)

In [4]: L = add_one(L)

In [5]: L
Out[5]: [1, 1]

In [6]: L = add_one()

In [7]: L
Out[7]: [1]

In [8]: L = add_one()

In [9]: L
Out[9]: [1, 1]

In [10]: L2 = add_one()

In [11]: L2
Out[11]: [1, 1, 1]

```
当我们传递了一个参数时没有任何问题，当我们使用默认参数时问题就出现了，我们调用一次add_one只想加一个1，但是默认参数好像记住了上次的值，为我们添加了不止一个1.
这是由于list是一个可变对象，Python每个对象的值都是内存上的引用，默认参数在函数定义时就已经绑定，每次调用改变的就是默认参数，默认参数可以理解为函数的成员变量每次调用都可以修改。
要解决这个问题，默认参数需要是一个不可变对象
``` c
In [14]: def add_one(L=None):
    ...:     if L is None:
    ...:         L = []
    ...:     L.append(1)
    ...:     return L
    ...: 
    ...: 

In [15]: L = add_one()

In [16]: L
Out[16]: [1]

In [17]: L = add_one()

In [18]: L
Out[18]: [1]

```
### 可变参数
可变参数就是参数是不确定的
求几个数的和
``` python
In [25]: def my_sum(*args):
    ...:     sum = 0
    ...:     for n in args:
    ...:         sum = sum + n
    ...:     return sum
    ...: 
    ...: 

In [26]: s = my_sum(1,2,3)

In [27]: s
Out[27]: 6

```
可变参数args是一个元组，无论多少个参数代码都无需改变

##### 如果已经有了一个list或者tuple,想要使用可变参数
1. 使用列表/元组索引一个个传递
2. 使用 *args(args表示list或者tuple)

``` c
In [32]: L = [1,2,3,4]

In [33]: s = my_sum(*L)

In [34]: s
Out[34]: 10

```
### 关键字参数
关键字参数接收带有参数名的参数，在函数内部组成一个字典，用**kwargs表示
``` python
In [37]: def info(**kwargs):
    ...:     for key, value in kwargs.items():
    ...:         print("{0}, {1}".format(key,value))
    ...:      

In [38]: info(a = 1, b = 2)
a, 1
b, 2

```
关键字参数也可以使用一个字典作为参数
``` python
In [40]: kw = {"a":1,"b":2}

In [41]: info(**kw)
a, 1
b, 2

```
### 命名关键字参数
有时候我们需要使用特定命名的参数，就可以使用命名关键字参数，命名关键字参数需要一个特殊的分隔符*，*后面的参数是关键字参数。使用关键字参数时必须传入特定的关键字
``` python
In [42]: def info(*,a,b):
    ...:     print(a,b)
    ...:     

In [43]: info(a = 1,b = 2)
1 2

```
