---
title: Linux进程控制之进程终止
date: 2018-03-19 07:46:22
tags: 学习笔记
category: linux
---
进程终止的情景
- 代码执行完毕，进程正常终止
- 代码异常终止

<!--more-->

### 常见进程终止的方法
正常终止
- 从main函数返回
- 调用了exit函数
- 调用了 _exit

异常终止
- 进程收到终止信号

exit函数
``` c
#include <stdlib.h>
void _exit(int status);
```
_exit函数
``` c
#include <unistd.h>
void _exit(int status);
```
> status只有低8位可用，用来表示退出状态

exit和_exit的区别
- _exit是系统调用，exit是库函数
- exit会调用-exit
- exit会执行用户通过atexit或on_exit定义的清理函数
- exit会关闭所有打开的流，刷新缓冲区

atexit和on_exit函数的区别
``` c
#include <stdlib.h>
int atexit(void (*function)(void));
```
``` c
#include <stdlib.h>
int on_exit(void (*function)(int , void *), void *arg);
```
atexit和on_exit都是清理函数，atexit函数没有参数，on_exit函数第一个参数是清理函数，第二个参数用于传给清理函数。清理函数第一个参数用来传给exit函数用于退出状态，第二个参数用于接收arg。

下面的代码用于展示exit和_exit的区别
``` c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

void Destory(){
	printf("Clean Function \n");
}
int main(){
	printf("before _exit");
	atexit(Destory);
	_exit(0);
	return 0;
}

```
运行结果：没有任何输出
``` c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

void Destory(){
	printf("Clean Function \n");
}
int main(){
	printf("before _exit");
	atexit(Destory);
	exit(0);
	return 0;
}
```
运行结果
> before _exitClean Function 

on_exit函数的用法
``` c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

void Destory(int status,void* arg){
	printf("\n");
	printf("exit status:%d\n",status);
	printf("arg = %s\n",arg);
}
int main(){
	printf("before exit");
	/*atexit(Destory);*/
	char* str = "hello on_exit";
	on_exit(Destory,str);
	exit(10);
	return 0;
}

```
运行结果
> before exit
exit status:10
arg = hello on_exit

使用echo $?查看上一个进程退出码
> 10