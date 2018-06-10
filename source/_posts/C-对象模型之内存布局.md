---
title: C++对象模型之内存布局
date: 2018-06-03 14:11:30
tags: 学习笔记
category: Cpp
---

探讨单继承、多继承、虚拟继承、以及多态下的内存模型。
<!--more-->
本文将分别讨论

- 无继承下的内存布局
- 单继承下的内存布局
- 多继承下的内存布局
- 菱形继承下的内存布局
- 虚拟继承下的内存布局
- 多态下的内存布局


### 无继承下的内存布局
``` c++
class A {
 public:
  A():a(10) {}
  void A1() {}
  int a;
};
```
内存布局如图1,所有内存模型低地址在下，高地址在上。

### 单继承下的内存模型
``` c++
class B: public A {
 public:
  B():b(20) {}
  void B1() {}
  int b;
};
```
内存布局如图2

### 多继承下的内存模型
``` c++
class A {
 public:
  A():a(10) {}
  void A1() {}
  int a;
};
class C {
 public:
  C(): c(30) {}
  void C1() {}
  int c;
};
class B : public A, public C {
 public:
  B():b(20) {}
  void B1() {}
  int b;
};

```
内存布局如图3

### 菱形继承下的内存模型
``` c++
class A {
public:
	A() :a(10) {}
	void A1() {}
	int a;
};
class C : public A {
public:
	C() : c(30) {}
	void C1() {}
	int c;
};
class B : public A {
public:
	B() :b(20) {}
	void B1() {}
	int b;
};
class D : public B, public C {
public:
	D():d(40) {}
	int d;

};
```
内存布局如图4

### 虚拟继承下的内存模型
``` c++
class A {
public:
	A() :a(10) {}
	void A1() {}
	int a;
};
class C : virtual public A {
public:
	C() : c(30) {}
	void C1() {}
	int c;
};
class B : virtual public A {
public:
	B() :b(20) {}
	void B1() {}
	int b;
};
class D : public B, public C {
public:
	D():d(40) {}
	int d;

};
```
内存布局如图5

![内存模型](https://www.suntangji.me/hexo/image/内存布局图1.png)

### 多态下的内存模型
#### 含有虚函数，没有多态
``` c++
class A {
public:
	A() :a(10) {}
	virtual void A1() {}
	int a;
};
class B : public A {
public:
	B() :b(20) {}
	virtual void B1() {}
	int b;
};
```
内存模型如图6
#### 多态下内存布局
``` c++
class A {
public:
	A() :a(10) {}
	virtual void A1() {}
	int a;
};
class C : public A{
public:
	C() : c(30) {}
	virtual void C1() {}
	virtual void A1() {}
	int c;
};
```
内存模型如图7

#### 带有虚函数的虚拟继承
``` c++
class A {
public:
	A() :a(10) {}
	virtual void A1() {}
	int a;
};
class C : virtual public A{
public:
	C() : c(30) {}
	virtual void C1() {}
	int c;
};
```
内存模型如图8
#### 多态和虚拟继承下的内存模型
``` c++
class A {
public:
	A() :a(10) {}
	virtual void A1() {}
	int a;
};
class C : virtual public A{
public:
	C() : c(30) {}
	virtual void C1() {}
	virtual void A1() {}
	int c;
};
```
内存模型如图9
![内存模型2](https://www.suntangji.me/hexo/image/内存布局图2.png)

以上结论只适用于vs2015 X86下，其他平台略有差异，未作测试。
