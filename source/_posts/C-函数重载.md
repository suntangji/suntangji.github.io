---
title: C++函数重载、重写与隐藏
date: 2018-06-04 20:53:24
tags: 学习笔记
category: cpp
---
深入浅出函数重载、重写与隐藏。
<!--more-->
#### 什么是函数重载
函数重载是指在同一作用域内，拥有两个或两个以上函数名相同、参数列表不同的函数，根据参数列表不同调用不同的函数。需要注意，函数返回值、关键字不构成重载条件。
``` c++
int Add(int x, int y) {
  return x + y;
}
float Add(float x, float y) {
  return x + y;
}
int Add(int x) {
  return x + 1;
}
```
以上函数构成了函数重载

#### 为什么需要函数重载
在C语言中，不存在函数重载，要想设计一个接口可以处理不同类型的参数，必须要每种类型设计一个函数。比如这样。
``` c
int add_int_int(int x, int y) {
  return x + y;
}
float add_float_float(float x, float y) {
  return x + y;
}
float add_int_float(int x, int float) {
  return x + y;
}
```
或者使用宏，但是宏有副作用，无法调试，不会检查参数合法性.
在C语言中不同参数列表都需要重新定义一个函数，函数命名就是个大问题，同时不同类型需要调用不同名称的函数。函数重载可以减少函数命名的烦恼避免名称污染，同时减小函数调用出错的概率，也大大提高了程序的可读性。

#### 为什么函数可以重载
在C语言中不支持函数重载，有相同名称的函数会链接出错。在C++中怎么就支持了呢?
把刚才的代码用g++编译，使用objdump -d a.out查看汇编代码
``` asm
0000000000400547 <_Z3Addii>:
  400547:	55                   	push   %rbp
  400548:	48 89 e5             	mov    %rsp,%rbp
  40054b:	89 7d fc             	mov    %edi,-0x4(%rbp)
  40054e:	89 75 f8             	mov    %esi,-0x8(%rbp)
  400551:	8b 55 fc             	mov    -0x4(%rbp),%edx
  400554:	8b 45 f8             	mov    -0x8(%rbp),%eax
  400557:	01 d0                	add    %edx,%eax
  400559:	5d                   	pop    %rbp
  40055a:	c3                   	retq   

000000000040055b <_Z3Addff>:
  40055b:	55                   	push   %rbp
  40055c:	48 89 e5             	mov    %rsp,%rbp
  40055f:	f3 0f 11 45 fc       	movss  %xmm0,-0x4(%rbp)
  400564:	f3 0f 11 4d f8       	movss  %xmm1,-0x8(%rbp)
  400569:	f3 0f 10 45 fc       	movss  -0x4(%rbp),%xmm0
  40056e:	f3 0f 58 45 f8       	addss  -0x8(%rbp),%xmm0
  400573:	5d                   	pop    %rbp
  400574:	c3                   	retq   

```
可以看出函数int Add(int x, int y)的函数签名变为了_Z3Addii,flaot(float x, float y)的函数签名变为了_Z3Addff。其本质上还是函数每个不同的名字，只是编译器帮助我们改变了函数签名，函数名中包含了参数的类型而已。这种技术叫命名修饰。不同编译器的命名修饰规则略有区别！g++和clang++基本相同，msvs和g++区别较大。

#### extern "C"的作用
在C++中函数是需要进行命名修饰的，如果我们想在C++中使用C语言的库,就有链接错误，我们声明printf函数，然后在C++中使用。
``` C++
int printf(const char * format,...);

#include <stdio.h>
int main() {
  printf("Hello world!");

  return 0;
}

```
``` bash
In file included from test2.cc:3:
/usr/include/stdio.h:362:12: error: declaration of 'printf' has a different language linkage
extern int printf (const char *__restrict __format, ...);
           ^
test2.cc:1:5: note: previous declaration is here
int printf(const char * format,...);
    ^
1 error generated.

```
我们没有自己声明printf时可以使用，声明后反而用不了了。这是由于stdio.h内部已经使用extern "C"声明过了，我们重新声明没有使用extern "C"。它的声明类似这样
``` C
#if __cplusplus
define EXTERN extern "C"
#else
define EXTERN
#endif
```
按照提示使用extern "C"关键字
``` C++
extern "C" {
  int printf(const char * format,...);
}

#include <stdio.h>
int main() {
  printf("Hello world!");

  return 0;
}

```
编译通过。通过以上测试可以得出:extern "C"的作用就是告诉编译器这是一段C语言代码不要进行命名修饰。

#### 函数重写(覆盖)
重写是继承体系中，派生类重新实现基类的方法
构成重写的条件

- 派生类和基类拥有相同名称的成员函数(不同作用域)
- 参数列表相同,返回值相同(协变除外)
- 基类必须是虚函数(有virtual关键字)

协变：在C++中，只要原来的返回类型是指向类的指针或引用，新的返回类型是指向派生类的指针或引用，覆盖的方法就可以改变返回类型。这样的类型称为协变返回类型（Covariant returns type).

#### 同名隐藏
1. 如果派生类和基类的函数名相同，参数列表不同，无论基类是否是虚函数，都要被隐藏
2. 如果派生类和基类函数名相同，参数列表相同，基类不是虚函数，基类的函数要被隐藏

#### 总结

同一作用域|返回值相同|参数列表相同|是虚函数|结果
:---:|:---:|:---:|:---:|:---:
是|是/否|否|是/否|重载
否|是/协变|是|基类是|重写
否|是/否|是/否|否|隐藏
否|是/否|否|基类是|隐藏
