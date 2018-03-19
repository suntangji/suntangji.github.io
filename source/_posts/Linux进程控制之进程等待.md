---
title: Linux进程控制之进程等待
date: 2018-03-18 16:42:55
tags: 学习笔记
categor: linux
---
学习进程等待函数wait、waitpid的用法。
<!--more-->
#### 进程等待的必要性
- 如果父进程不理会子进程的状态，子进程可能变成僵尸进程，造成内存泄漏
- 若父进程先退出，子进程会变成孤儿进程
- 父进程往往需要知道子进程的运行结果

#### 进程等待的方法
wait函数
```
#include <sys/types.h>
#include <sys/wait.h>
pid_t wait(int *status);
```
返回值：成功返回被等待进程的id,失败返回-1
参数： 输出型参数，用于获取子进程退出状态，不关心可设置为NULL
waitpid函数
```
#include <sys/types.h>
#include <sys/wait.h>
pid_t waitpid(pid_t pid, int *status, int options);
```
返回值：正常返回收集到的子进程id
如果设置了WNOHANG,而调用waitpid发现没有退出的子进程可收集，则返回0
如果调用出错，返回-1，errno会被设置对应的值
参数： 
pid = -1,等待任何一个子进程，与wait等效
pid > 0,等待该进程
options = WNOHANG，若pid指定的子进程没有结束，函数返回0，不予以等待。若正常结束返回该进程id
- 如果子进程已退出，调用wait/waitpid时，函数会立即返回，并且释放资源，获得子进程退出信息
- 如果在任意时刻调用wait/waitpid,子进程存在且正常运行，则进程可能阻塞。
- 如果不存在该子进程，则立即出错返回

#### 获取进程退出状态
wait/waitpid函数的参数status是一个位图，用它的低16位来表示进程状态。当进程正常终止时status的低8位为0，高8位为退出状态。当进程被信号终止时，低7位表示终止信号，第8位为core dump标志，高8为没有使用。

```
#include <stdio.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>

int main(){
	pid_t pid = fork();
	if(pid > 0){
		int st = 0;
		int ret = wait(&st);
		if(ret > 0 && (st & 0xff) == 0)
			printf("exit status:%d",(st>>8) & 0xff);	
		else if(ret > 0 )
			printf("sig:%d",st&0x7f);

	} else if(pid == 0){
		sleep(15);
		exit(10);
	} else {
		perror("fork");
	}
	return 0;
}

```
程序正常终止运行结果
> exit status:10

子进程被信号杀死运行结果
> sig:9

使用宏WIFEXITED 可以方便的获取进程是否正常退出,如果进程正常退出，可以使用宏WEXITSTATUS获取退出状态。
#### 阻塞式等待
```
#include <stdio.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>

int main(){
	pid_t pid = fork();
	if(pid > 0){
		int st = 0;
		pid_t ret = waitpid(-1,&st,0);
		if(WIFEXITED(st) && ret == pid){
			printf("wait success,child return code:%d\n",WEXITSTATUS(st));
		} else {
			printf("wait failed!\n");
			return 1;
		}

	} else if(pid == 0){
		printf("child is run!\n");
		sleep(5);
		exit(0);
	} else {
		perror("fork");
	}
	return 0;
}


```
运行结果
> child is run!
wait success,child return code:0

#### 非阻塞式等待
```
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>

int main() {
  pid_t pid = fork();
  if(pid > 0) {
    int st = 0;
    pid_t ret;
    do {
      ret = waitpid(-1,&st,WNOHANG);
			if(ret == 0)
				printf("child is running,wait\n");
			sleep(1);

    } while(ret == 0);
		if(WIFEXITED(st) && ret == pid){
			printf("wait end,child return code:%d\n",WEXITSTATUS(st));
		}

  } else if(pid == 0) {
    printf("child is run!\n");
    sleep(5);
    exit(0);
  } else {
    perror("fork");
  }
  return 0;
}

```
运行结果
> child is running,wait
child is run!
child is running,wait
child is running,wait
child is running,wait
child is running,wait
wait end,child return code:0
