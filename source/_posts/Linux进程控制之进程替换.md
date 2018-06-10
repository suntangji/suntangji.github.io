---
title: Linux进程控制之进程替换
date: 2018-03-19 09:09:35
tags: 学习笔记
category: Linux
---
当父进程fork一个子进程之后往往需要执行exec函数去执行另一个程序。
<!--more-->

当进程调用一种exec函数时，该进程执行的程序完全被新进程替换，exec并不创建新进程，所以进程id并没有改变，只替换了当前进程的正文、数据段、堆栈。

进程替换函数
``` c
#include <unistd.h>
extern char **environ;
int execl(const char *path, const char *arg, ...);
int execlp(const char *file, const char *arg, ...);
int execle(const char *path, const char *arg, ..., char * const envp[]);
int execv(const char *path, char *const argv[]);
int execvp(const char *file, char *const argv[]);
int execvpe(const char *file, char *const argv[], char *const envp[]);
```
> l(list):参数采用列表
v(vector):参数采用数组
p(path):搜索环境变量
e(env):自定义环境变量

只有execve是系统调用，其他函数是对它的封装
实例
``` c
#include <stdio.h>
#include <unistd.h>

int main(){
	pid_t pid = fork();
	if(pid > 0){
	
		printf("father:\n");
	} else if (pid == 0){
		printf("child:\n");
		/*execl("/usr/bin/ls","ls","-a",NULL);	*/
		/*execlp("ls","ls","-a",NULL);*/
		char* envp[] = {"ST=/usr/bin",NULL};
		/*execle("/usr/bin/ls","ls","-a",NULL,envp);*/
		char *arg[] = {"ls","-a",NULL};
		/*execv("/usr/bin/ls",arg);*/
		/*execvp("ls",arg);*/
		execve("/usr/bin/ls",arg,envp);
	} else {
		perror("fork");
	}
	return 0;
}
```
模拟shell
``` c
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>
#include <ctype.h>
#include <stdlib.h>

char* argv[8];
int argc = 0;
void do_parser(char* buf) {
  int i = 0;
  int status = 0;
  for(argc = i = 0; buf[i]; ++i) {
    if(!isspace(buf[i]) && status == 0) {
      argv[argc++] = buf +i;
      status = 1;
    } else if(isspace(buf[i])) {
      status = 0;
      buf[i] = 0;
    }
  }
  argv[argc] = NULL;
}
void do_execute() {
	pid_t pid = fork();
	if(pid > 0){
		int st = 0;
		while(wait(&st) != pid);	
	} else if(pid == 0){
		execvp(argv[0],argv);	
		perror("exec");
		exit(1);
	} else {
		perror("fork");
	}
}
int main() {
  char buf[1024];
  while(1) {
    printf("myshell>");
    scanf("%[^\n]%*c",buf);
    /*gets(buf);*/
    do_parser(buf);
    do_execute();
  }
  return 0;
}

```
运行结果
> myshell>ls -a
.  ..  ctl  ctl.c  exec  exec.c  exit_pro  exit_pro.c  Makefile  myshell  myshell.c  vfork  vfork.c  wait  wait