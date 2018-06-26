---
title: Python中的实例方法、类方法和静态方法
date: 2018-06-12 16:04:24
tags: 学习笔记
category: Python
---
浅谈Python实例变量、类变量、实例方法、类方法和静态方法。
<!--more-->
在说说实例方法和类方法之前， 先说一下实例变量和类变量。

#### 实例变量

> 实例化后，每个实例单独拥有的变量

``` Python
class Person(object):
    name = "aaa"


p1 = Person()
p2 = Person()
p1.name = "bbb"
print(p1.name)  # bbb
print(p2.name)  # aaa
print(Person.name)  # aaa

```

#### 类变量

> 是可在类的所有实例之间共享的值(也就是说，它们不是单独分配给每个实例的)。

``` python
class Test(object):
    num_of_instance = 0

    def __init__(self, name):
        self.name = name
        Test.num_of_instance += 1


if __name__ == '__main__':
    print(Test.num_of_instance)  # 0
    t1 = Test('jack')
    print(Test.num_of_instance)  # 1
    t2 = Test('lucy')
    print(t1.name, t1.num_of_instance)  # jack 2
    print(t2.name, t2.num_of_instance)  # lucy 2

```

#### 实例方法

``` python
In [1]: class User(object):
   ...:         def get_id(self):
   ...:                     print(id(self))
   ...:                     

In [2]: u = User()

In [3]: u.get_id
Out[3]: <bound method User.get_id of <__main__.User object at 0x7f7b7470e860>>

In [4]: u.get_id()
140168211261536

In [5]: User.get_id
Out[5]: <function __main__.User.get_id(self)>

In [6]: User.get_id()
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
<ipython-input-6-66e488fc8feb> in <module>()
----> 1 User.get_id()

TypeError: get_id() missing 1 required positional argument: 'self'

In [7]: User.get_id(u)
140168211261536

```

从上⾯的代码可以看出实例方法的特殊性。当⽤实例调用时，它是个 bound method，动态绑定到对象实例。而当⽤类型调用时，是 function，必须显式传递 self 参数

#### 静态方法

``` python
In [1]: class User(object):
   ...:     @staticmethod
   ...:     def get_id():
   ...:         pass
   ...:     

In [2]: u = User()

In [3]: u.get_id
Out[3]: <function __main__.User.get_id()>

In [4]: u.get_id()

In [5]: User.get_id
Out[5]: <function __main__.User.get_id()>

In [6]: User.get_id()

```
静态方法没有了隐含的参数 self,可以使用实例去调用，同时也可以使用类去调用。

#### 类方法

``` python
In [1]: class User(object):
   ...:     @classmethod
   ...:     def get_id(cls):
   ...:         pass
   ...:     

In [2]: u = User()

In [3]: u.get_id
Out[3]: <bound method User.get_id of <class '__main__.User'>>

In [4]: u.get_id()

In [5]: User.get_id
Out[5]: <bound method User.get_id of <class '__main__.User'>>

In [6]: User.get_id()

In [7]: u.get_id(User)

```

我们声明类方法的本意是使用类去调用，但是也可以使用实例去调用。

#### 小结

- 实例方法有一个隐含的 self 参数，作用是和实例绑定
- 类方法有一个隐含的 cls 参数，作用是和类绑定 
- 静态方法没有隐含的参数

\\| 实例方法 | 类方法 | 静态方法 
 :---:|:---:|:---:|:---:
 a = A()|a.foo()|a.class_foo()|a.static_foo()
 A| 不可用 | A.class_foo()|A.static_foof()

