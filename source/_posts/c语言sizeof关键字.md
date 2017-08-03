---
title: c语言sizeof关键字
date: 2017-07-28 16:48:26
tags: 随笔
category: c 
---
The sizeof keyword gives the amount of storage, in bytes,associated with a variable or a type (including aggregate types). This keyword returns a value of type size_t.
<!--more-->
简言只，其作用就是返回一个对象或者类型所占的内存字节数。例如下面这段程序。
```c 
#include<stdio.h>
#include<stdlib.h>
int main()
{

	printf("%d\n", sizeof(char));//1
	printf("%d\n", sizeof(int));//4
	printf("%d\n", sizeof(double));//8
	printf("%d\n", sizeof(float));//4
	printf("%d\n", sizeof(1));//4
	system("pause");
	return 0;
}
```
当数组遇上sizeof。
>注意：sizeof的参数只有数组名时代表整个数组，其他情况不能代表整个数组。
 
```c 

#include<stdio.h>
#include<stdlib.h>
int main()
{
	char arr[] = "abcdef";
	printf("sizeof:%d\n", sizeof(arr));//7
	printf("sizeof *arr:%d\n", sizeof(*arr));//1
	printf("sizeof arr+1:%d\n", sizeof(arr+1));//4 地址
	printf("sizeof &arr:%d\n", sizeof(&arr));  //4
	printf("sizeof &arr+1:%d\n", sizeof(&arr+1)); //4
	printf("sizeof *&arr:%d\n", sizeof(*&arr));  //7 
	printf("sizeof *&arr+1:%d\n", sizeof(*&arr + 1));//4
	printf("sizeof *(&arr+1):%d\n", sizeof(*(&arr + 1)));//7
	system("pause");
	return 0;
}
```
>sizeof(arr)的结果为7。abcdef只有6个字符，但是却占用了7个字节，这是由于每个char类型的字符占用一个字节，但是字符串结束标志\0也要占用一个字节。
 
---
>sizeof(*arr)的结果为1。arr代表数组的首地址，*arr代表数组的第一个元素，相当于arr[0],也就是a,a的类型为char所以占用1个字节。

---
>sizeof(arr+1)的结果为4。arr代表数组的首地址,arr+1代表的是数组第二个元素的地址，每个地址占用4个字节，所以结果为4。
  
---
>sizeof(&arr)的结果为4，&arr代表的是整个数组的地址，在数值上等于数组的首地址，但是意思不同。&arr是一个地址，所以占用4个字节。
   
---
> sizeof(&arr+1)的结果为4。&arr代表的是整个数组的地址，&arr+1代表和数组arr同类型数组的地址，所以结果为4.
   
---
> sizeof(*&arr))的结果为7。这个表达式等价于sizeof(arr),所以结果为7.
   
---
> sizeof(*&arr + 1))的结果为4.它等价于sizeof(arr+1),所以结果为4.
   
---
>sizeof(*(&arr+1))的结果为7.它求得的是和数组arr同类型同大小的数组所占用的字节，这个数组可能不存在，sizeof并没有真正访问这块地址，而是判断这块地址存储的值类型。所以结果为7.
  
