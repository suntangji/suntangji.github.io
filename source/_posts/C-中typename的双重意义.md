---
title: C++中typename的双重意义
date: 2018-06-03 13:59:12
tags: 学习笔记
category: Cpp
---
了解typename的两种用法。
<!--more-->
typename的最多用法就是模板声明中,以下两种声明没有任何区别。
``` c++
template <class T>
class Test;

template <typename T>
class Test;

```
typename的另一个作用就是使用嵌套依赖类型(nested depended name)。
``` c++
#include <iostream>
#include <vector>
using namespace std;

int p = 10000;
class T {
 public:
  static int iterator;
};
int T::iterator = 1;
template <class T>
void Test(const T& t) {
  (void)t;
  T::iterator *p;
  cout << p << endl;
};

int main() {
  vector<int> v;
  Test(v);
  return 0;
}

```
这是一段有歧义的代码，模板类型恰好和类类型相同，类类型又有一个静态成员函数，又有一个全局变量和Test函数内部的变量相同。
这段代码的本意是类T的静态成员乘以全局变量，但是也可以理解为是定义一个模板类型的迭代器指针。
vs2015下可以编译通过，但是运行时把p当作指针，由于p没有初始化，程序崩溃。
由于代码有歧义gcc7.3.0/clang5.0.1编译失败,提示我使用typename
``` bash
test.cc:14:15: 错误：依赖名‘T:: iterator’被解析为非类型，但实例化却产生了一个类型
   T::iterator *p;
   ~~~~~~~~~~~~^~
test.cc:14:15: 附注：如果您想指定类型，请使用‘typename T:: iterator’

```
于是加上typename，声明T::iterator 是一个类型，把p当作指针变量

- gcc7.3.0 果然输出了一个地址，是我想要的结果
- clang 5.0.1 的结果是0，也是正确的。

小结

- typename用来声明模板类型
- typename用来指明一个类型，避免歧义
