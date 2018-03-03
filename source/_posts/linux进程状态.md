---
title: linux进程状态
date: 2017-12-28 22:15:09
tags: 学习笔记
category: linux
---
进程执行时，它会根据具体情况改变状态。进程状态是调度和对换的依据。
<!--more-->
#### 进程状态
Linux 中的进程主要有如下状态
```bash
#define TASK_RUNNING        0
#define TASK_INTERRUPTIBLE    1
#define TASK_UNINTERRUPTIBLE    2
#define TASK_STOPPED        4
#define TASK_TRACED        8
#define EXIT_ZOMBIE        16
#define EXIT_DEAD        32
 
```
内核表示 |含义 |状态
--------|-------|------
TASK_RUNNING |可运行|R
TASK_INTERRUPTIBLE |可中断的等待状态|S
TASK_UNINTERRUPTIBLE |不可中断的等待状态|D
TASK_STOPPED |暂停|T
TASK_TRACED | 不能通过信号唤醒的暂停| t
EXIT_ZOMBIE |僵死|Z
EXIT_DEAD|退出|X



1. 可运行状态
处于这种状态的进程，要么正在运行、要么正准备运行。正在运行的进程就是当前进程（由current 所指向的进程），而准备运行的进程只要得到CPU 就可以立即投入运行，CPU 是这些进程唯一等待的系统资源。系统中有一个运行队列（run_queue），用来容纳所有处于可运行状态的进程，调度程序执行时，从中选择一个进程投入运行。
2. 等待状态
处于该状态的进程正在等待某个事件（Event）或某个资源，它肯定位于系统中的某个等待队列（wait_queue）中。Linux 中处于等待状态的进程分为两种：可中断的等待状态和不可中断的等待状态。处于可中断等待态的进程可以被信号唤醒，如果收到信号，该进程就从等待状态进入可运行状态，并且加入到运行队列中，等待被调度；而处于不可中断等待态的进程是因为硬件环境不能满足而等待，例如等待特定的系统资源，它任何情况下都不能被打断，只能用特定的方式来唤醒它，例如唤醒函数wake_up（）等。
3. 暂停状态
此时的进程暂时停止运行来接受某种特殊处理。通常当进程接收到SIGSTOP、SIGTSTP、SIGTTIN 或 SIGTTOU 信号后就处于这种状态。例如，正接受调试的进程就处于这种状态。
4. 僵死状态
进程虽然已经终止，但由于某种原因，父进程还没有执行wait()系统调用，终止进程的信息也还没有回收。顾名思义，处于该状态的进程就是死进程，这种进程实际上是系统中的垃圾，必须进行相应处理以释放其占用的资源。

#### kill命令
使用kill命令给进程发送信号可以改变进程状态，可以使用kill -l命令查看可以发送的状态。
```bash
 1) SIGHUP	 2) SIGINT	 3) SIGQUIT	 4) SIGILL	 5) SIGTRAP
 6) SIGABRT	 7) SIGBUS	 8) SIGFPE	 9) SIGKILL	10) SIGUSR1
11) SIGSEGV	12) SIGUSR2	13) SIGPIPE	14) SIGALRM	15) SIGTERM
16) SIGSTKFLT	17) SIGCHLD	18) SIGCONT	19) SIGSTOP	20) SIGTSTP
21) SIGTTIN	22) SIGTTOU	23) SIGURG	24) SIGXCPU	25) SIGXFSZ
26) SIGVTALRM	27) SIGPROF	28) SIGWINCH	29) SIGIO	30) SIGPWR
31) SIGSYS	34) SIGRTMIN	35) SIGRTMIN+1	36) SIGRTMIN+2	37) SIGRTMIN+3
38) SIGRTMIN+4	39) SIGRTMIN+5	40) SIGRTMIN+6	41) SIGRTMIN+7	42) SIGRTMIN+8
43) SIGRTMIN+9	44) SIGRTMIN+10	45) SIGRTMIN+11	46) SIGRTMIN+12	47) SIGRTMIN+13
48) SIGRTMIN+14	49) SIGRTMIN+15	50) SIGRTMAX-14	51) SIGRTMAX-13	52) SIGRTMAX-12
53) SIGRTMAX-11	54) SIGRTMAX-10	55) SIGRTMAX-9	56) SIGRTMAX-8	57) SIGRTMAX-7
58) SIGRTMAX-6	59) SIGRTMAX-5	60) SIGRTMAX-4	61) SIGRTMAX-3	62) SIGRTMAX-2
63) SIGRTMAX-1	64) SIGRTMAX	
```
例如kill-9 pid 就可以杀掉当前执行的进程。
#### R状态
先看下面的一段程序 
```cpp
#include<stdio.h>                                                        
#include<unistd.h>
int main(){
     while(1){
     }
     return 0;
 }
```
编译运行以上代码
```bash
gcc test.c -o test
./test
```
查看进程状态
```bash
ps aux|grep test
```
```bash
text     127655 96.8  0.0   4164   344 pts/0    R+   17:14   0:20 ./test
text     127657  0.0  0.0 112660   972 pts/2    R+   17:15   0:00 grep --color=auto test

```
可以看到进程处于R状态
#### T状态
可以使用kill -19 127655命令使进程处于T状态。
```bash
text     127655 91.2  0.0   4164   344 pts/0    T    17:14   0:45 ./test
text     127668  0.0  0.0 112660   968 pts/2    S+   17:15   0:00 grep --color=auto test
```
使用kill-18 127655 可以使进程恢复R状态
```bash
[text@localhost ~]$ ps aux|grep test
text     127655  9.4  0.0   4164   344 pts/0    R    17:14   0:48 ./test
text     127759  0.0  0.0 112660   972 pts/2    R+   17:23   0:00 grep --color=auto test
```
> t状态

生成带有调试信息的程序,并进行调试
```bash
gcc -g test.c -o test
gdb test
l
b 4
r
```
此时查看进程状态是t状态
```bash
[text@localhost process]$ ps aux|grep test
text     127851  0.0  1.0 172544 20520 pts/2    S+   17:29   0:00 gdb test
text     127895  0.0  0.0   4164   356 pts/2    t    17:31   0:00 /home/text/code/linux/process/test
text     127900  0.0  0.0 112660   972 pts/0    S+   17:31   0:00 grep --color=auto test
```
#### S状态
更改程序源代码
```cpp
#include<stdio.h>                                                        
#include<unistd.h>
int main(){
     while(1){
     sleep(1);
     }
     return 0;
 }
```
再次查看进程状态为S状态
```bash
[text@localhost process]$ ps aux|grep test
text     128048  0.0  0.0   4164   344 pts/0    S+   17:36   0:00 ./test
text     128050  0.0  0.0 112660   976 pts/2    S+   17:37   0:00 grep --color=auto test
```
#### D状态
使用vfork函数可以使父进程进入D状态，更改源代码
```cpp
 #include<stdio.h>                                        
 #include<unistd.h>
 int main() {
     if(!vfork())
         sleep(100);
     return 0;
 }
```
编译运行并查看进程状态
```bash
[text@localhost process]$ ps aux|grep test
text     128559  0.0  0.0   4164   348 pts/0    D+   17:49   0:00 ./test
text     128560  0.0  0.0   4164   348 pts/0    S+   17:49   0:00 ./test
text     128562  0.0  0.0 112660   976 pts/2    S+   17:49   0:00 grep --color=auto test
```
#### Z状态
更改源代码
```cpp
#include<stdio.h>        
#include<unistd.h>
int main() {
     pid_t ret = fork();
     if(ret>0) {
         printf("father[%d]\n",getpid());
         while(1)
             sleep(1);
     }
     else if(ret == 0){
         printf("child[%d]\n",getpid());
     }
     return 0;
 }
```
编译运行查看进程状态
```bash
text     128762  0.0  0.0   4168   348 pts/0    S+   17:58   0:00 ./test
text     128763  0.0  0.0      0     0 pts/0    Z+   17:58   0:00 [test] <defunct>
text     128765  0.0  0.0 112660   976 pts/2    S+   17:58   0:00 grep --color=auto test
```
可以看到子进程已处于Z状态，执行kill -9 128763,再次查看进程状态
```bash
text     128762  0.0  0.0   4168   348 pts/0    S+   17:58   0:00 ./test
text     128763  0.0  0.0      0     0 pts/0    Z+   17:58   0:00 [test] <defunct>
text     128767  0.0  0.0 112660   972 pts/2    S+   17:58   0:00 grep --color=auto test
```
可以看到僵尸进程并没有被杀死，执行kill -9 128762去杀死他的父进程，再次查看进程状态
```bash
[text@localhost process]$ ps aux|grep test
text     128769  0.0  0.0 112660   976 pts/2    S+   17:59   0:00 grep --color=auto test
```
由此可知要杀死僵尸进程必须杀死他的父进程。杀死他的父进程后，僵尸进程变成了孤儿进程，由1号进程回收。僵尸进程是由于子进程已经结束，父进程没有读取子进程的状态，子进程的进程描述符仍然保存在系统中，所以变成了僵死状态。
僵尸进程危害，由于进程号是有限的，当产生了大量僵尸进程，会造成无法创建新进程。为了避免僵尸进程，可以使用信号处理机制，子进程退出时向父进程发送SIGCHILD信号，父进程处理SIGCHILD信号。在信号处理函数中调用wait进行处理僵尸进程。或者fork()两次来避免。
#### 孤儿进程
更改源代码
```cpp
 #include<stdio.h>                                                                         
 #include<unistd.h>
 int main() {
     pid_t ret = fork();
     if(ret>0) {
         printf("father[%d,%d]\n",getpid(),getppid());
		 sleep(1);
     }
     else if(ret == 0){
         printf("child[%d,%d]\n",getpid(),getppid());
         sleep(2);//保证父进程先退出
         printf("child[%d,%d]\n",getpid(),getppid());
     }
     return 0;
}
```
程序运行结果
```bash
father[2704,2553]
child[2705,2704]
[text@localhost process]$ child[2705,1]
```
由于父进程先退出，子进程没有结束，子进程变成了孤儿进程，在子进程成为孤儿进程进程之前，他的父进程是创建他的进程，一旦创建他的进程先退出，子进程会被1号进程init领养，由一号进程结束孤儿进程。