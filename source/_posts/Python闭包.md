---
title: Python闭包
date: 2018-04-24 19:50:28
tags: 学习笔记
category: python
---
在计算机科学中，闭包（英语：Closure），又称词法闭包（Lexical Closure）或函数闭包（function closures），是引用了自由变量的函数。这个被引用的自由变量将和这个函数一同存在，即使已经离开了创造它的环境也不例外。
[维基百科::闭包（计算机科学）]
<!--more-->
闭包就是函数离开创建环境后依然持有其上下文信息。
创建一个闭包的必要条件
1. 必须有一个内嵌函数
2. 内嵌函数必须引用外部函数中的变量
3. 外部函数的返回值必须是内嵌函数

### 命名空间与作用域
我们可以把命名空间看做一个大型的字典类型（Dict），里面包含了所有变量的名字和值的映射关系。在Python中，作用域实际上可以看做是在当前上下文的位置，获取命名空间变量的规则。在Python代码执行的任意位置，都至少存在三层嵌套的作用域：
1. local namespace: 作用范围为当前函数，包含所有局部变量
2. global namespace: 作用范围当前模块，包含全局变量
3. build-in namespace: 作用范围为所有模块

如果存在内嵌函数，搜索范围是
1. local
2. encloseing locals
3. global
4. built-in
``` python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

a = 1


def fun():
    b = 2
    return a + b


ret = fun()
print(ret)

```
当在local作用域没有找到变量a,就会从global作用域寻找。
### 闭包
``` python
#!/usr/bin/env python
# -*- coding: utf-8 -*-


def outer():
    x = 1

    def inner():
        y = 2
        return x + y

    return inner


fun = outer()
ret = fun()
print(ret)

```
闭包函数都有__closure__属性，包含它所引用的上层作用域中的变量
``` python
print(fun.__closure__[0].cell_contents)
```
结果为1
