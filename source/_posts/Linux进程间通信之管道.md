---
title: Linux进程间通信之管道
date: 2018-03-22 11:09:02
tags: 学习笔记
category: linux
---
管道是UNIX系统IPC的最古老形式，并且所有UNIX系统都提供此通信机制.
<!--more-->
#### 管道IPC原理
管道的本质是操作系统内核中的一段内存。管道能在有亲缘关系的进程间通信是因为fork之后子进程拥有和父进程相同的文件描述符，这样一对描述符只能保证一个方向的传输，父子进程一个需要关闭fd[0],一个关闭fd[1]。父子进程要双向传递数据要打开两个管道。
#### 管道的特点
- 管道是半双工的
- 只能在有亲缘关系的进程间使用
- 管道提供面向字节流的服务
- 管道的生命周期随进程，进程终止管道释放

#### 管道的读写规则
- 读管道时文件描述符被关闭，read返回0
- 写管道时文件描述符被关闭，write会产生SIGPIPE信号
- 当没有数据可读时，read调用阻塞，一直到有数据可读
- 当管道满时，write调用阻塞，直到有数据被读出
- 当要写入的数据量不大于PIPE_BUF时，将保证写入的原子性，大于PIPE_BUF时将不再保证

创建管道的系统调用pipe
``` c
#include <unistd.h>
int pipe(int pipefd[2]);
```
成功返回0，失败返回-1.
利用管道进行进程间通信
``` c
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>

int main(){
	int fd[2] = {0};
	int ret = pipe(fd);
	ret = fork();
	if (ret > 0){
		//father
		close(fd[0]);
		const char *str = "hello world";
		ssize_t write_size = write(fd[1],str,strlen(str));
		if(write_size < 0){
			perror("write");
		}
		close(fd[1]);
					
	} else if(ret == 0){
		close(fd[1]);
		char buf[1024] = {0};
		ssize_t read_size = read(fd[0],buf,sizeof(buf)-1);
		if(read_size == 0){
			printf("read end!");
		}else if(read_size < 0){
			perror("write");
		}
		close(fd[0]);
		printf("read:%s\n",buf);
	} else {
		perror("fork");
	}
	return 0;
}
```
#### popen/pclose函数
使用管道进行进程间通信的常见操作是创建一个管道，fork一个子进程，关闭不需要的管道文件描述符，替换子进程执行一个shell命令，等待进程结束。标准I/O库封装了popen函数实现了以上功能。
``` c
#include <stdio.h>
FILE *popen(const char *command, const char *type);
int pclose(FILE *stream);
```
该函数返回一个文件指针，command是一个shell命令，type是"r",文件指针连接到标准输出，type是"w",文件指针连接到标准输入
pclose用于关闭文件指针。
#### 文件指针和文件描述符
文件指针是一个结构体，它不仅包含文件描述符还提供了一个缓冲区。
``` c
typedef struct _iobuf FILE;
struct _iobuf {
        char *_ptr;          //缓冲区当前指针
        int   _cnt;
        char *_base;       //缓冲区基址
        int   _flag;          //文件读写模式
        int   _file;           //文件描述符
        int   _charbuf;     //缓冲区剩余自己个数
        int   _bufsiz;       //缓冲区大小
        char *_tmpfname;
        };
```
C语言文件指针域文件描述符之间可以相互转换
``` c
int fileno(FILE * stream)
FILE * fdopen(int fd, const char * mode)
```
popen函数实例
``` c
#include <stdio.h>
int main() {
  char buf[1024]= {0};
  FILE* out = popen("ls -a","r");
  while(fgets(buf,sizeof(buf),out))
    printf("%s",buf);
  pclose(out);
  return 0;
}
```
#### 命名管道FIFO
命名管道FIFO是一种特殊类型的文件，可以使用mkfifo命令或函数创建
``` c
#include <sys/types.h>
#include <sys/stat.h>
int mkfifo(const char *pathname, mode_t mode);
```
匿名管道和命名管道的区别
- 创建打开方式不同
- 命名管道可以用于任意进程，匿名管道只能用于有亲缘关系的进程

使用命名管道进行server&client通信
``` c
//server.c
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>

int main(){
	int ret = mkfifo("myfifo",0644);
	if(ret < 0 ){
		perror("mkfifo");
	}
	ret = open("myfifo",O_RDONLY);
	if(ret < 0){
		perror("open");
		return -1;
	}
	char buf[1024];
	while(1){
		ssize_t read_sz = read(ret,buf,sizeof(buf)-1);
		if(read_sz > 0){
			buf[read_sz] = '\0';
			printf("client:%s",buf);
		} else if(read_sz == 0){
				break;
		} else {
			perror("read");
			exit(-1);
		}
	}
	close(ret);
	return 0;
}
```
```c
//client.c
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>

int main(){
	int ret = open("myfifo",O_WRONLY);
	if(ret < 0){
		perror("open");
		exit(-1);
	}
	char buf[1024];
	while(1){
		printf(">");
		fflush(stdout);
		ssize_t read_sz = read(0,buf,sizeof(buf)-1);
		if(read_sz > 0){
			buf[read_sz] = '\0';
			ssize_t write_sz = write(ret,buf,strlen(buf));
			if(write_sz < 0){
				perror("write");
			}

		} else {
			perror("read");
			exit(-1);
		}
	}
	close(ret);
	return 0;
}
```