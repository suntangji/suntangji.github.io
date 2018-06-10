---
title: C语言可变参数列表
date: 2017-08-08 20:17:36
tags: 学习笔记
category: C 
---
在计算机程序设计，一个可变参数函数是指一个函数拥有不定引数，即是它接受一个可变数目的参数。
<!--more-->
在C语言中，C标准函式库的stdarg.h标头档定义了提供可变参数函数使用的宏。要创建一个可变参数函数，必须把省略号（...）放到参数列表后面。函数内部必须定义一个va_list变数。然后使用宏va_start、va_arg和va_end来读取。例如：
>以下代码运行在vs2015开发环境下，可能和标准c语言有些差异

```c 
#include<stdio.h>
#include<stdarg.h>
#include <stdlib.h>
int Max(int n,...)
{
	va_list arg;
	__crt_va_start(arg, n);
	int max = __crt_va_arg(arg, int);
	int i = 0;
	for (i = 1; i < n; i++)
	{
		int tmp = __crt_va_arg(arg, int);
		if (tmp > max)
			max = tmp;
		//__crt_va_arg(arg, int);
	}
	__crt_va_end(arg);
	return max;
}
int main()
{
	int ret = Max(7,1,3,5,7,8,4,9);
	printf("%d", ret);
	system("pause");
	return 0;
}
```
这是一段计算n个数最大值的程序，其中函数Max是可变参数函数，该函数的第一个参数是除了它本身其他参数的个数。
这段代码中va_list是一个类型重定义，它的定义是
>typedef char* va_list;

__crt_va_start是一个宏定义，他的定义是
>  #define __crt_va_start(ap, x) __crt_va_start_a(ap, x)

而__crt_va_start_a又是一个宏定义，它的内容为
>  #define __crt_va_start_a(ap, v) ((void)(ap = (va_list)_ADDRESSOF(v) + _INTSIZEOF(v)))

这个宏定义中又包含两个宏定义，其中宏_ADDRESSOF(v)的内容为
>  #define _ADDRESSOF(v) (&(v))

另一个宏定义_INTSIZEOF(v)的内容为
>   #define _INTSIZEOF(n)          ((sizeof(n) + sizeof(int) - 1) & ~(sizeof(int) - 1))

这段宏定义的作用是如果n占1-4个字节，则返回4.占用5-8个字节则返回8.现在可以推断出宏__crt_va_start的功能就是用v的地址去初始化ap.

宏 __crt_va_arg(ap, t)的内容
  >  #define __crt_va_arg(ap, t)     (*(t*)((ap += _INTSIZEOF(t)) - _INTSIZEOF(t)))
  
  该宏的作用是把ap 加上一个t类型大小的空间，然后又减去t类型大小的空间,这么做的用意是获取下一个参数的地址，返回当前参数的地址。

宏 __crt_va_end(ap)的定义为
>  #define __crt_va_end(ap)        ((void)(ap = (va_list)0))

该定义的内容为把指针va_list置空。

根据函数[栈帧](https://www.suntangji.me/2017/08/05/运行时堆栈/)原理,可以知道函数的参数是由右向左分别入栈的，最左边的参数一定是所有参数中最低的地址，由于第一个参数就是除了它本身其他参数的数量，那就可以根据第一个参数的地址找到其他参数的地址，进而找到其他参数。