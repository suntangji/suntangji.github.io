---
title: c语言static关键字
date: 2017-07-28 16:45:36
tags: 随笔
category: c
---
c语言static关键字的用法
<!--more-->
下面这段程序的输出结果为10个2
```c 
#include<stdio.h>
#include<stdlib.h>
int main()
{
	int i = 0;
	for (i = 0; i < 10; i++)
	{
		int n = 1;
		n++;
		printf("%d ", n);//2
	}
	system("pause");
	return 0;
}
```
对这段程序稍加修改，输出结果为2-11
```c 
#include<stdio.h>
#include<stdlib.h>
int main()
{
	int i = 0;
	for (i = 0; i < 10; i++)
	{
		static int n = 1;
		n++;
		printf("%d ", n);//2 3 4 --11
	}
	system("pause");
	return 0;
}
```
通过对比可知，static关键字修饰局部变量，改变了它的生命周期。在没有加static关键字时，变量在执行for循环时创建，一次for循环结束后便销毁。但是加了static关键字之后，for循环结束后变量并没有销毁。所以才会输出2-11.
下面探讨static修饰全局变量。在同一工程下，新建两个文件test1.c和test2.c
test1.c 
```c
#include<stdio.h>
#include<stdlib.h>
extern int g_val;
int main()
{
	printf("%d", g_val);//2017
	system("pause");
	return 0;
} 
```
test2.c 
```c 
int g_val = 2017;
```
程序运行没有问题，输出2017.把test2.c 的代码修改为
```c 
static int g_val = 2017;
```
此时程序无法运行，错误提示为无法解析的外部符号_g_val.由此可知，当static修饰全局变量时，改变了全局变量的作用域。