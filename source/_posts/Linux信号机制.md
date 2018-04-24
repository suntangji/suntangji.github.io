---
title: Linux信号机制
date: 2018-04-16 12:54:07
tags: 学习笔记
category: linux
---
信号是由用户、系统或者进程发送给目标进程的信息，以通知目标进程某个状态的改变或系统异常。
<!--more-->
可以使用kill -l 命令查看所有信号

#### Linux信号可由如下条件产生
- 对于前台进程，用户可以通过输入特殊的终端字符来给它发送信号，比如输入Ctrl+C
- 硬件异常产生，比如除数为0产生CPU异常，解引用空指针产生MMU异常
- 一个进程调用kill给另一个进程发信号 
- 软件条件产生，例如闹钟函数alerm产生的SIGALRM信号，向已关闭的管道写数据时会产生SIGPIPE信号

##### 信号处理的常见方式
- 忽略该信号
- 捕捉信号
- 执行该信号的默认处理动作

##### 阻塞信号
- 实际执行信号的处理动作称为信号递打(Delivery)
- 信号从产生到递打之间的状态，称为信号未决(Pending)
- 进程可以选择阻塞某个信号
- 被阻塞的信号产生时讲保持再未决信号集，知道进程解除对此信号的阻塞，才执行递打动作
- 阻塞和忽略是不同的，只要信号被阻塞会不会递打，而忽略是递打之后可选的一种处理方式

##### 信号集
> 每个信号都用1个bit分别表示未决标志和阻塞标志，不记录该信号产生了多少次，他们可以使用相同的数据结构sigset_t信号集表示，阻塞信号集也成信号屏蔽字。

##### 信号集操作函数
``` c
#include <signal.h>
int sigemptyset(sigset_t *set);
int sigfillset(sigset_t *set);
int sigaddset(sigset_t *set, int signum);
int sigdelset(sigset_t *set, int signum);
int sigismember(const sigset_t *set, int signum);
```
> sigemptyset初始化set所指向的信号集，使其中所有信号的对用bit清零,表示不包含任何信号
> sigfillset初始化set所指向的信号集，使其信号的bit位置为1，表示包含所有信号
> sigaddset表示增加一个信号到信号集
> sigdelset表示删除一个信号从信号集中
> sigismember用来判断一个信号集中是否包含某种信号

##### sigprocmask函数
``` c
#include <signal.h>
int sigprocmask(int how, const sigset_t *set, sigset_t *oldset);
```
ssigprocmask可以读取或更改进程的信号屏蔽字。how表示如何修改，可选参数SIG_BLOCK,SIG_UNBLOCK,SIG_SETMASK.set不为空，把信号屏蔽字改为set中的信号，oldset用于备份。

##### sigpending函数
``` c
#include <signal.h>
int sigpending(sigset_t *set);
```
读取当前进程的未决信号集，通过set传出



##### signal系统调用
``` c
#include <signal.h>
typedef void (*sighandler_t)(int);
sighandler_t signal(int signum, sighandler_t handler);
```
signum表示要捕捉的信号，handler表示要进行信号处理的函数
成功时返回一个函数指针,该函数指针就是参数的函数指针，或者是信号对应的默认处理函数指针SIG_DEF
出错时返回SIG_ERR,并设置errno

##### sigaction系统调用
``` c
#include <signal.h>
int sigaction(int signum, const struct sigaction *act,
              struct sigaction *oldact);
```
signum表示要捕捉的信号，act指定新的信号处理方式，oldact输出先前的信号处理方式
sigaction结构体定义
``` c
struct sigaction {
               void     (*sa_handler)(int);
               void     (*sa_sigaction)(int, siginfo_t *, void *);
               sigset_t   sa_mask;
               int        sa_flags;
               void     (*sa_restorer)(void);
           };
```
sa_handler，sa_sigaction指定信号处理函数，sa_mask增加信号掩码，sa_flag设置程序收到信号的行为。

##### 信号捕捉的流程

#### pause
``` c
#include <unistd.h>
int pause(void);
```
pause函数使调用进程挂起直到有信号递达，如果信号的处理动作是终止程序，则进程终止，pause函数没有机会返回，如果信号的处理动作是忽略，则进程继续处于挂起状态，pause不返回。如果信号处理动作是捕捉，则调用信号处理函数后pause返回-1.


#include <stdio.h
#include <signal.h>
#include <unistd.h>

void PrintPendingSet(sigset_t* set) {
  for (int i = 1; i < 32; i++) {
    if (sigismember(set,i)) {
      printf("1");
    } else {
      printf("0");
    }   
  }
  printf("\n");
}
int main() {
  sigset_t s,p;
  sigemptyset(&s);
  sigaddset(&s,SIGINT);
  sigprocmask(SIG_BLOCK,&s,NULL);
  while (1) {
    sigpending(&p);
    PrintPendingSet(&p);
    sleep(1);
  }
  return 0;
}
```