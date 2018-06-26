---
title: C++类的静态成员
date: 2018-06-10 17:38:09
tags: 学习笔记
category: Cpp
---
关键字static在C++中的作用
<!--more-->
C++ 是兼容 C 语言的语法的，static 在 C 语言中的作用，在 C++ 中同样适用。static 在 C 语言中的作用可以查看我的另一篇博客 [C语言static关键字](https://www.suntangji.me/2017/07/28/c%E8%AF%AD%E8%A8%80static%E5%85%B3%E9%94%AE%E5%AD%97/) 。
static 在 C++ 中修饰类的成员函数和类的成员变量还有其他作用。

#### 类的静态成员变量需要在类外初始化

``` C++
class Test {
 public:

 protected:
  static int m_val; /*!< Member description */
};

int Test::m_val = 100;

int main() {

  return 0;
}

```

#### 类的静态成员变量可以使用类名访问

``` C++
#include <iostream>
using namespace std;

class Test {
 public:
  static int m_val; /*!< Member description */
};

int Test::m_val = 100;

int main() {
  Test t;
  cout << t.m_val << endl; // 100
  t.m_val = 200;
  cout << Test::m_val << endl; // 200
  Test::m_val = 300;
  cout << t.m_val << endl; // 300

  return 0;
}

```

#### sizeof 不包括静态成员变量

``` C++
#include <iostream>
using namespace std;

class Test {
 public:
  static int m_val; /*!< Member description */
};

int Test::m_val = 100;

int main() {
  Test t;
  cout << sizeof(Test) << endl; // 1
  cout << sizeof(t) << endl; // 1

  return 0;
}

```

int 在64位系统下占4个字节，但是sizeof的结果只是1， 没有把静态成员包括在内。至于为什么是1，C++ 标准规定 “no object shall have the same address in memory as any other variable”，即任何不同的对象不能拥有相同的内存地址，为了保证这点，编译器使用1个字节填充用于标识不同的对象。

#### 静态成员函数不能访问类的非静态成员
无法访问类的成员变量和类的成员函数

#### 静态成员函数没有 this 指针

``` C++
#include <iostream>
using namespace std;

class Test {
 public:
  static int m_val; /*!< Member description */
  int m_val2;
  static void test() {
    //this->m_val = 4; 出错
    //this->m_val2 = 5; 出错
  }
  void test2() {
    this->m_val2 = 2;
    this->m_val = 3;
  }
};

int Test::m_val = 100;

int main() {

  return 0;
}
```

#### 小结

普通成员变量 | 静态成员变量 | 普通成员函数 | 静态成员函数
:---:|:---:|:---:|:---:
每个对象都有一份 | 所有对象共享 | 隐藏的 this 指针 | 没有 this 指针
sizeof 包括在内 | sizeof 不包括在内 | 可以访问静态成员 | 只能访问静态成员
在类内初始化 | 在类外初始化 | 使用对象调用 | 使用对象/类名调用
