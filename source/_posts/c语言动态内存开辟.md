---
title: C语言动态内存开辟
date: 2017-09-02 19:49:37
tags: 学习笔记
category: C
---
&emsp;&emsp;所谓动态内存分配(Dynamic Memory Allocation)就是指在程序执行的过程中动态地分配或者回收存储空间的分配内存的方法。动态内存分配不象数组等静态内存分配方法那样需要预先分配存储空间，而是由系统根据程序的需要即时分配，且分配的大小就是程序要求的大小。
<!--more-->
&emsp;&emsp;我们在定义数组时，需要知道数组的大小，当我们不确定数组大小时需要定义足够大的数组来存放数据，这样造成了空间的浪费，一旦空间不够用时又要重新修改程序，这样的方式是静态内存分配，使用动态内存分配可以很好的解决这一问题。
#### 动态内存分配的优点
- 不需要预先分配存储空间；
- 分配的空间可以根据程序的需要扩大或缩小。

要实现动态内存分配，需要使用以下几个函数。

 - malloc
 - calloc
 - realloc
 - free

>malloc函数的原型是void* malloc (size_t size);该函数的功能是开辟一块内存，返回开辟后内存块的起始地址。如果开辟内存失败返回一个空指针。

>calloc函数的原型是void* calloc (size_t num, size_t size);该函数的功能和malloc函数类似，但是calloc函数会把开辟的内存初始化为0.

>realloc函数的原型是void* realloc (void* ptr, size_t size);该函数接收一个需要重新分配内存的地址，可能在原来的起始地址更改内存的大小，也有可能重新开辟一块内存，但是原来的数据不会丢失，原来空间也无需手动释放。该函数返回的是重新开辟的内存起始地址。

>free函数的原型是void free (void* ptr);该函数的功能是释放由malloc、calloc函数动态开辟的内存，或者释放realloc函数修改过的内存。如果ptr没有指向上述函数分配的内存块，会导致未定义行为。如果ptr是空指针，不会执行任何操作。

动态内存分配可以让程序员更自由的管理内存，但是如果分配不合理会导致错误。
#### 常见的内存分配错误
- 开辟内存后不进行释放，造成内存泄漏
- 对动态开辟的内存进行多次释放
- 对动态开辟的内存进行部分释放
- 释放并非动态开辟的内存
- 对动态开辟的内存进行越界访问
- 对空指针进行解引用操作
- 对已经释放的内存进行二次访问

结合动态内存开辟和结构体相关知识，我们可以定义一个柔性数组(0长度的数组），也就是先不声明数组的长度，内存空间进行动态分配。
```c
#include <stdlib.h>
#include <string.h>
struct line {
   int length;
   char contents[0]; // C99的玩法是：char contents[]; 没有指定数组长度
};
 
int main(){
    int this_length=10;
    struct line *thisline = (struct line *)
					 malloc (sizeof (struct line) + this_length);
    thisline->length = this_length;
    memset(thisline->contents, 'a', this_length);
    return 0;
}
```
这段代码就实现了一个柔性数组，可以动态分配数组大小。但是这完全可以用一个指针来实现，为什么还要柔性数组呢？
```c
#include <stdlib.h>
#include <string.h>
struct line {
   int length;
   char *contents;
};
 
int main(){
    int this_length=10;
    struct line *thisline = (struct line *)
					 malloc (sizeof (struct line) + this_length);
    thisline->length = this_length;
    memset(thisline->contents, 'a', this_length);
    return 0;
}
```

这段代码的功能和用柔性数组一模一样，使用柔性数组是因为

- 柔性数组在结构体内分配的是一段连续的内存，这有利于内存的释放
-  有利于访问速度

#### 参考文章 [C语言结构体里的成员数组和指针||酷壳-CoolShell](https://coolshell.cn/articles/11377.html)
