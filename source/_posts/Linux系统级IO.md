---
title: Linux系统级IO
date: 2018-03-21 13:27:17
tags: 学习笔记
category: linux
---
输入/输出(I/O)是在主存和外部设备之间拷贝数据的过程，所有语言都提供了较高级别的I/O函数，有时我们也需要使用系统级I/O.
<!--more-->
#### 文件描述符
Linux下一切皆文件，操作系统把所有设备都抽象成文件，当进程打开或创建一个文件，在进程的PCB结构中都会有对应的文件描述符，所有文件相关操作都需要该文件描述符。
PCB中的file_struct结构体
```
struct files_struct {
  atomic_t count; /* 共享该表的进程数 */
  rwlock_t file_lock; /* 保护以下的所有域,以免在tsk->alloc_lock中的嵌套*/
  int max_fds; /*当前文件对象的最大数*/
  int max_fdset; /*当前文件描述符的最大数*/
  int next_fd; ／*已分配的文件描述符加1*/
  struct file ** fd; /* 指向文件对象指针数组的指针 */
  fd_set *close_on_exec; /*指向执行exec( )时需要关闭的文件描述符*/
  fd_set *open_fds; /*指向打开文件描述符的指针*/
  fd_set close_on_exec_init;/* 执行exec( )时需要关闭的文件描述符的初 值集合*/
  fd_set open_fds_init; /*文件描述符的初值集合*/
  struct file * fd_array[32];/* 文件对象指针的初始化数组*/
};
```
#### I/O相关系统调用
open/creat函数
```
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int open(const char *pathname, int flags);
int open(const char *pathname, int flags, mode_t mode);
int creat(const char *pathname, mode_t mode);
```

pathname是要打开或创建的文件路径，flags是打开方式
- O_RDONLY:只读
- O_WRONLY:只写
- O_RDWR:可读可写

打开一个文件时必须从以上参数中选择一个，以下是可选参数
- O_CREAT:如果文件不存在创建一个新的空文件
- O_TRUNC:如果文件已存，以只写或读写方式打开就截断它的长度为0
- O_APPEND:每次写操作前，设置文件位置到结尾处
- O_EXCL: 如果同时指定了O_CREAT,而文件已存在则出错
- O_NOCTTY:如果pathname是终端设备，则不将该设备设置为控制终端
- O_NONBLOCK:特殊文件设置为非阻塞模式

以下的参数也是可选的
- O_DSYNC
- O_RSYNC
- O_SYNC

mode是设置该文件的权限，文件的权限为mode&(~umask),可以使用umask函数设置umask的值。
open/creat函数的返回值是当前没有使用的文件描述符的最小值，出错返回-1
close函数
``` c
#include <unistd.h>
int close(int fd);
```
close函数用来关闭一个文件描述符，成功返回0，失败返回-1。关闭一个已经关闭的文件描述符会失败。
lseek函数
``` c
#include <sys/types.h>
#include <unistd.h>
off_t lseek(int fd, off_t offset, int whence);
```
lseek显示的为一个打开的文件设置其偏移量
read/write函数
``` c
#include <unistd.h>
ssize_t read(int fd, void *buf, size_t count);
```
fd是文件描述符，buf是接收数据的缓冲区，count是一次读的数据大小
read函数成功返回读到的数据大小，0表示读到了文件结尾，出错返回-1。
``` c
#include <unistd.h>
ssize_t write(int fd, const void *buf, size_t count);
```
fd是文件描述符，buf是要写的数据，count是一次写的大小.
write函数的返回值成功返回写的数据大小，0表示什么也没写，-1表示出错

使用read/write读写文件
``` c
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

int main(){
	/*umask(0);*/
	int fd = open("text.txt",O_RDWR|O_CREAT,0644);
	char buf[1024] = {0};
	const char* write_buf = "hello write!";
	ssize_t write_size = write(fd,write_buf,strlen(write_buf));
	if(write_size < 0)
		perror("write");
	lseek(fd,0,SEEK_SET);
	ssize_t read_size = read(fd,buf,sizeof(buf)-1);
	if(read_size < 0)
		perror("read");
	buf[read_size] = '\0';
	write(1,buf,strlen(buf));
	close(fd);
		
	return 0;
}
```
#### 重定向
重定向函数
``` c
#include <unistd.h>
int dup(int oldfd);
int dup2(int oldfd, int newfd);
#include <fcntl.h>              /* Obtain O_* constant definitions */
#include <unistd.h>
int dup3(int oldfd, int newfd, int flags);
```
dup函数会关闭oldfd,打开当前最小的文件描述符
使用dup重定向标准输出
``` c
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

int main(){
	int fd = open("text.txt",O_WRONLY,0644);
	close(1);
	int new_fd = 	dup(fd);
	const char* buf = "hello stdout!";
	write(1,buf,strlen(buf));
	/*printf("hello stdout!");*/
	close(new_fd);
		
	return 0;
}

```
dup2函数拷贝描述符表表项oldfd到newfd,覆盖oldfd以前的内容，如果newfd已经打开，dup2会在拷贝oldfd之前关闭newfd。
使用dup2函数进行标准输出重定向
``` c
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

int main(){
	int fd = open("text.txt",O_WRONLY,0644);
	int new_fd = 	dup2(fd,1);
	const char* buf = "hello stdout!";
	write(1,buf,strlen(buf));
	close(new_fd);
		
	return 0;
}
```