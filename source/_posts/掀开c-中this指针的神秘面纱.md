---
title: 掀开c++中this指针的神秘面纱
date: 2017-10-24 20:27:55
tags: 学习笔记
category: Cpp
---
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;我们都知道类的不同实例都可以调用成员函数，那么成员函数如何知道哪个实例要被操作呢，原因在于每个对象都拥有一个指针：this指针，通过this指针来访问自己的地址。
<!--more-->
```cpp
#include <iostream>
using namespace std;

class Date
{
public:
	void SetDate(int year,int month,int day)
	{
		_year = year;
		_month = month;
		_day = day;
	}
private:
	int _year;
	int _month;
	int _day;
};
int main()
{
	Date d1,d2;
	d1.SetDate(2017, 10, 22);
	d2.SetDate(2017, 10, 23);
	return 0;
}
```
以上代码是一个日期类，创建了2个对象d1和d2，都调用了成员函数SetDate()。成员函数是如何知道哪个对象要调用它呢？如果用c语言去实现以上功能，代码如下。
```c
#define _CRT_SECURE_NO_WARNINGS
typedef struct Date
{
	int _year;
	int _month;
	int _day;
}Date,*pdate;

void SetDate(pdate this,int year,int month,int day)
{
	this->_year = year;
	this->_month = month;
	this->_day = day;
}

int main()
{
	Date d1, d2;
	SetDate(&d1, 2017, 10, 22);
	SetDate(&d2, 2017, 10, 23);

	return 0;
}
```
创建了Date类型的变量d1,d2后，要想调用SetDate()函数去设置日期，参数除了年月日之外，还必须要传一个当前对象的地址才可以。而在cpp中，我们并没有显式的去传一个当前对象的地址，而是用当前对象加上成员选择符去调用成员函数，那编译器会不会帮我们隐式的传了当前对象的地址呢？
```cpp
d1.setdate(2017, 10, 22);
00C7177E  push        16h  
00C71780  push        0Ah  
00C71782  push        7E1h  
00C71787  lea         ecx,[d1]  
00C7178A  call        date::setdate (0C7101Eh)  
```
以上代码是SetDate()函数的汇编代码，显而易见，该函数除了的参数除了我们显式定义的参数，编译器还使用ecx寄存器传递了实例d1的地址。
```cpp
void setdate(int year, int month, int day)
	{
00C71700  push        ebp  
00C71701  mov         ebp,esp  
00C71703  sub         esp,0CCh  
00C71709  push        ebx  
00C7170A  push        esi  
00C7170B  push        edi  
00C7170C  push        ecx  
00C7170D  lea         edi,[ebp-0CCh]  
00C71713  mov         ecx,33h  
00C71718  mov         eax,0CCCCCCCCh  
00C7171D  rep stos    dword ptr es:[edi]  
00C7171F  pop         ecx  
00C71720  mov         dword ptr [this],ecx  
		_year = year;
00C71723  mov         eax,dword ptr [this]  
00C71726  mov         ecx,dword ptr [year]  
00C71729  mov         dword ptr [eax],ecx  
		_month = month;
00C7172B  mov         eax,dword ptr [this]  
00C7172E  mov         ecx,dword ptr [month]  
00C71731  mov         dword ptr [eax+4],ecx  
		_day = day;
00C71734  mov         eax,dword ptr [this]  
00C71737  mov         ecx,dword ptr [day]  
00C7173A  mov         dword ptr [eax+8],ecx  
	}
```
进入SetDate()函数内部，根据汇编代码可知，ecx寄存器把它的内容交给了this指针，这就可以解释不同实例为什么可以调用同一个成员函数。
## this指针是什么类型呢？
类类型*const,我们无法改变this指针的指向，所以是const.
## 为什么叫this指针，而不是引用？
首先应该明确的是指针和引用在底层的实现是相同的，之所以叫this指针，是因为最开始将C++称作带类的C，而引用则是在C++1.0版才加入使用的，因此叫做this指针。
## this指针可不可能指向NULL？
```cpp
#define _CRT_SECURE_NO_WARNINGS
#include <iostream>
using namespace std;

class date
{
public:
	void setdate(int year, int month, int day)
	{
		cout << this << endl;
	//	_year = year;
	//	_month = month;
	//	_day = day;
		
	}
private:
	int _year;
	int _month;
	int _day;
};
int main()
{
	date d1, d2;
	date *p = &d1;
	d1.setdate(2017, 10, 22);
	p->setdate(2017, 10, 22);
	p = NULL;
	p->setdate(2017, 10, 22);

	//d2.setdate(2017, 10, 23);
	return 0;
}
```
以上代码的运行结果为

> 00AFFD20
00AFFD20
00000000

根据运行结果可知，this指针是可能为空的。只是无法在成员函数内部置空，this为空时不能调用成员变量。
## 成员函数调用约定
当函数参数确定时，使用_thiscalll 调用约定
- _thiscall只能够用在类的成员函数上。
- 参数从右向左压栈。this指针通过ecx寄存器传递给被调用者
- 函数自己清理堆栈

当函数参数不确定时，使用_cdecl调用约定
- 参数从右向左压栈，this指针在所有参数被压栈后压入堆栈。
- 调用者清理堆栈

