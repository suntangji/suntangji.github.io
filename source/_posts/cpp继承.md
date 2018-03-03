---
title: c++继承
date: 2017-12-13 18:15:19
tags: 学习笔记
category: cpp
---
浅析c++中继承，以及菱形继承，虚拟继承，继承的内存布局
<!--more-->
### 什么是继承
继承(inheritance)机制是面向对象程序设计使代码可以复用的最重要的手段，它允许程序员在保持原有类特性的基础上进行扩展，增加功能。

### 继承的语法
在代码中和原来一样给出该类的名字，但在类的左括号前面，加上一个冒号和基类的名字（多重继承基类名用逗号分开）

### 继承的关系

继承方式 | 基类的public成员 |基类的protect成员 |基类的private成员
:----:|:------:|:----:|:---:
public | 仍为public成员  |仍为protected成员 |不可见
protected| 变为protected成员 | 仍为protected成员 |不可见
private(默认)| 变为private成员 | 变为private成员 |不可见

#### 对私有继承成员公有化
当私有继承时所有的public成员都变成了private，如果希望它们中任何一个是可视的，只需要用派生类的public部分生命他们的名字即可。

### c语言实现继承
```c
/// \file inherit.c
/// \brief
/// \author suntangji, suntangj2016i@gmail.com
/// \version 1.0
/// \date 2017-11-24
#include<stdio.h>
#include<malloc.h>
struct Base {
    int b;
    void (*pfb)();
    /*c语言不支持结构体内部定义函数，所以使用函数指针 */
};
struct Derived {
    int d;
    void (*pfd)();
    struct Base* base;
};
void FunBase() {
    printf("Base::FunBase");
}
void FunDerived() {
    printf("Derived::FunDerived");
}
struct Base* NewBase(){
    struct Base* pb = (struct Base*)(malloc(sizeof(struct Base)));
    pb->b = 0;
    pb->pfb = FunBase;
    return pb;
}
struct Derived* NewDerived(){
    struct Derived* pd = (struct Derived*)(malloc(sizeof(struct Derived)));
    pd->d = 0;
    pd->pfd = FunDerived;
    pd->base = NewBase(); 
    return pd;
}
int main() {
    struct Base * b = NewBase();
    struct Derived * d = NewDerived();
    b->pfb();
    d->pfd();
    d->base->pfb();
    return 0;
}
```
#### C语言实现的缺陷
-  没有继承关系
-  没有构造函数和析构函数容易造成内存泄露
-  函数调用比较麻烦

### 构造函数的调用顺序
先调用派生类的构造函数，在派生类构造函数参数列表中调用基类的构造函数，然后在构造派生类自己的成员。
### 析构函数的调用顺序
先调用派生类的析构函数，再调用基类的析构函数。
### 同名隐藏与重写
当基类的成员函数不是虚函数时，派生类和它有同名的函数时（函数原型可以不同）会隐藏基类的函数。当基类的成员函数是虚函数时，派生类有和基类同名的函数（函数原型需要相同）会发生重写。
### 向上类型转换
- 派生类对象可以赋值给基类对象
- 基类对象不可以赋值给派生类对象
- 基类对象的指针/引用可以指向派生类对象，但不能访问派生类对象可以访问基类对象
- 派生类对象的指针/引用不可以指向基类对象(强制类型转换后可以)
### 非自动继承的函数
- 构造函数
- 析构函数
- 赋值运算符重载

### 单继承的对象模型
基类的成员在上(低地址)，派生类的成员在下(高地址)
### 多继承的对象模型
最先继承的基类在上(低地址)，其次继承的基类在下(高地址)，派生类的成员在最下(低地址)
### 菱形继承的对象模型
``` cpp
class Base {
public:
	Base() {
		_b = 1;
	}
private:
	int _b;
};

class C1:public Base{
public:
	C1() {
		_c1= 2;
	}
private:
	int _c1;
};
class C2 :public Base{
public:
	C2() {
		_c2 = 3;
	}
private:
	int _c2;
};
class Derived :public C1,public C2{
public:
	Derived() {
		_d = 4;
	}
private:
	int _d;
};
```
这段代码在内存中存储是1   2   1   3   4
可以看出仍然是派生类的成员在下，基类的成员在上，只是基类又是其他基类的派生类。菱形继承对最上层的基类继承了2次，既造成了二义性又浪费了空间。
### 虚拟继承
虚拟继承可以解决菱形继承二义性的问题
``` cpp
class Base {
public:
	Base() {
		_b = 1;
	}
private:
	int _b;
};

class C1:virtual public Base{
public:
	C1() {
		_c1= 2;
	}
private:
	int _c1;
};
class C2 :virtual public Base{
public:
	C2() {
		_c2 = 3;
	}
private:
	int _c2;
};
class Derived :public C1,public C2{
public:
	Derived() {
		_d = 4;
	}
private:
	int _d;
};
```
对象d的内存布局
>  0x0115FD44  e8 8b db 00  
0x0115FD48  02 00 00 00  
0x0115FD4C   f0 8b db 00  
0x0115FD50   03 00 00 00  
0x0115FD54   04 00 00 00  
0x0115FD58   01 00 00 00  

虚拟继承解决了菱形继承的二义性问题，因为菱形继承不再保存两份基类的变量,在对象内存的最高地址保存虚拟继承的基类成员，原来保存成员的地方保存了一个虚基类表格地址，该地址存储了2个变量，分别是相对自己的偏移量0和相对别虚拟继承的基类成员的偏移量。有了这两个偏移量就可以找到唯一一个基类成员，继而解决了菱形继承的二义性问题。