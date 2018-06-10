---
title: 模拟实现库函数strcpy
date: 2017-08-02 15:53:46
tags: 学习笔记
category: C 
---
自己动手实现库函数strcpy的功能
<!--more-->
定义两个指针，指针dest指向需要进行拷贝的字符串，指针src指向被拷贝的字符串。如果指针src指向的内容不是'\0',把src所指的内容赋给dest所指的内容。然后把src和dest都加1。

函数名为my_strcpy,返回值为char* ,两个参数，分别为字符指针dest,常量字符指针src。该函数没有返回值也可以实现字符串的拷贝，但为了函数的链式访问，返回类型为char* ,指向拷贝后的字符串。函数第二个参数为const char* src定义为常量指针是为了防止书写错误，把dest 赋值给src。

代码如下
```c 
#include<stdio.h>
char* mystrcpy(char* dest, const char* src)
{
	char* ret = dest;
	while (*dest++ = *src++);
	return ret;
}
int main()
{
	char a[20] = { 0 };
	char* p = "hello world";
	printf("%s\n", mystrcpy(a, p));
	return 0;
}
```