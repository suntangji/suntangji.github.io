---
title: C++类型转换
date: 2018-06-13 14:28:17
tags: 学习笔记
category: Cpp
---
所谓类型转换，其含义是改变一个变量的类型为别的类型从而改变该变量的表示方法。
<!--more-->

### C风格类型转换

C++ 是兼容 C 语言的，自然也支持 C 语言的强制类型转换、和隐式类型转换

``` C
#include <stdio.h>

int main() {
  int a1, a2;
  double b = 1.2;
  a1 = b;
  a2 = (int)b;
  printf("%d %d\n", a1, a2);  // 1 1
  return 0;
}

```

### C++新式类型转换

标准C++为了加强类型转换的可视性，引入了四种命名的强制类型转换操作符：

- static_cast
- reinterpret_cast
- const_cast
- dynamic_cast

#### static_cast

static_cast 允许执行任意的隐式转换和相反转换的动作(即使它是不允许隐式的)。也就是说它允许子类类型的指针转换为父类类型的指针(这是一个有效的隐式转换)，同时也允许父类类型的指针转换为子类的指针。

``` C++
class Base {
};
class Derived : public Base {
};
Base* b = new Base();
Derived* d = new  Derived();
//Derived* d_b2 = new Base();  // 编译出错
Base* b2 = new Derived();
Base* b3 = static_cast<Base*>(d);
Derived* d2 = static_cast<Derived*>(b);

```

static_cast 除了操作类型指针，也能用于执行类型定义的显示转换，以及基础类型之间的标准转换。

``` C++
double d = 3.14;
int i = static_cast<int>(d);

```

static_cast不能用于两个不相关类型之间的转换。

#### dynamic_cast

dynamic_cast 用于将一个父类对象的指针或引用转换为子类对象的指针或引用.

``` C++
class Base {
 public:
  virtual void foo() {}
};
class Derived : public Base {
};
Base* b = new Base();
Derived* d = new  Derived();
Base* b2 = dynamic_cast<Base*>(d);
Derived* d2 = dynamic_cast<Derived*>(b);

```

dynamic_cast 只能用于含有虚函数的类
dynamic_cast 会先检查是否能转换成功，能成功则转换，不能成功则返回0

#### const_cast

const_cast 最常用的用途就是删除变量的 const 属性，方便赋值。

``` C++
int main() {
  const int a = 10;
  //int* p = &a;  // 编译错误
  int* p = const_cast<int*>(&a);
  *p = 20;
  return 0;
}

```

#### reinterpret_cast

reinterpret_cast 是一种高度危险的转换，这种转换仅仅是对二进制位的重新解释。这个操作符能够在非相关的类型之间转换。操作结果只是简单的从一个指针到别的指针的值的二进制拷贝，在类型之间指向的内容不做任何类型的检查和转换。

``` C++
class A {};
class B {};
A*a = new A;
B* b = reinterpret_cast<B*>(a);

```

#### explicit 关键字

explicit 关键字阻止单参构造函数进行隐式类型转换

``` C++
#include <iostream>
using namespace std;
class A {
 public:
  A(int a) : m_a(a) {
  }
 private:
  int m_a;
};

int main() {
  A a = 10;
  return 0;
}

```

A a = 10 会进行隐式转换，转换为 A a(10) 然后调用构造函数。使用 explicit 可以阻止这种转换。
使用 explicit 修饰构造函数之后，不再支持 A a = 10 的用法，避免了构造函数的隐式转换。
