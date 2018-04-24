---
title: Linux进程控制之进程创建
date: 2018-03-18 14:47:24
tags: 学习笔记
category: linux
---
学习使用fork,vfork函数创建进程
<!--more-->
### 进程创建
使用fork函数创建进程，操作系统需要执行以下功能
- 为新进程在进程表中分配一个空项
- 为子进程赋一个唯一的进程标识号
- 做一个父进程上下文的逻辑副本，不包括共享内存区
- 增加父进程所拥有的所有文件的计数器，以表示有一个另外的进程现在也拥有这些文件
- 把子进程设置为就绪态
- 向父进程返回子进程的进程号，对子进程返回零

使用fork创建进程并获取进程id
``` c
 #include <stdio.h>                                                                                                
 #include <unistd.h>
 int main() {
 
   pid_t pid = fork();
   if (pid > 0) {
     //father
     printf("father:pid = %d,ppid = %d\n",getpid(),getppid());
   } else if (pid == 0) {
     //child
     printf("child:pid = %d,ppid = %d\n",getpid(),getppid());
   } else {
     perror("fork");
   }
   return 0;
 }

```
运行结果
> father:pid = 20720,ppid = 18506
child:pid = 20721,ppid = 20720

fork函数的特点
- 调用一次有两个返回值，父进程返回子进程pid,子进程返回0
- 父子进程都有自己的虚拟地址空间，子进程会进行写时拷贝
- 父子进程的执行顺序不确定，取决于操作系统的调度

fork函数创建进程失败的原因
- 内存不够无法分配内存给新进程
- 进程太多无法创建新进程

使用vfork函数创建新进程
``` c
#include <stdio.h>
#include <unistd.h>

int g_val = 2018;

int main(){

	int val = 2018;
	pid_t pid = vfork();
	if(pid > 0) {
		//father
		printf("farher:g_val = %d,val = %d\n",g_val,val);		
	} else if(pid == 0) {
	  //child
		g_val = 2017;
		val = 2017;
		printf("child:g_val = %d,val = %d\n",g_val,val);		
		_exit(0);
	} else {
		perror("vfork");
	}
	return 0;	
}

```
运行结果
> child:g_val = 2017,val = 2017
farher:g_val = 2017,val = 2017

vfork函数的特点
- 保证子进程先执行
- 父子进程共享虚拟地址空间
- 子进程必须调用exec/_exit/exit函数
- 若子进程依赖父进程的进一步动作会导致死锁

vfork函数没有调用exit/_exit/exec函数的后果

--------
如果vfork创建子进程后，子进程没有调用以上函数会发生不可预期行为，对用CentOS就是段错误。这是由于子进程先执行，子进程执行完毕退出会销毁函数栈帧，由于vfork创建的进程共享虚拟地址空间，父进程的函数栈帧也被销毁，此时再去执行父进程就会发生段错误。

#### 其他创建进程的方式
- clone函数
- system函数
- popen函数

clone函数允许子进程共享一部分父进程的数据。
system和popen是对fork的封装。二者主要区别是popen函数同时会打开一个管道用于进程间通信,system在等待命令终止时将忽略SIGINT 和SIGQUIT 信号，同时阻塞SIGCHLD 信号。如果这会导致应用程序错过一个终止它的信号，则应用程序应检查system的返回值；如果由于收到某个信号而终止了命令，应用程序应采取一切适当的措施。

