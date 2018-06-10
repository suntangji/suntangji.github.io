---
title: Linux进程间通信之共享内存
date: 2018-03-30 21:31:56
tags: 学习笔记
category: Linux
---
共享内存是最高效的IPC机制，因为它不涉及进程之间的任何的数据传输。
<!--more-->
共享内存把一块内存映射到多个进程的虚拟地址空间，这些数据之间的传递将不用在涉及到内核。
共享内存的数据结构
``` c
struct shmid_ds {
struct ipc_perm shm_perm; /* operation perms */
int shm_segsz; /* size of segment (bytes) */
__kernel_time_t shm_atime; /* last attach time */
__kernel_time_t shm_dtime; /* last detach time */
__kernel_time_t shm_ctime; /* last change time */
__kernel_ipc_pid_t shm_cpid; /* pid of creator */
__kernel_ipc_pid_t shm_lpid; /* pid of last operator */
unsigned short shm_nattch; /* no. of current attaches */
unsigned short shm_unused; /* compatibility */
void *shm_unused2; /* ditto - used by DIPC */
void *shm_unused3; /* unused */
};
```
shmget系统调用，用来创建共享内存
``` c
#include <sys/ipc.h>
#include <sys/shm.h>
int shmget(key_t key, size_t size, int shmflg);
```
key和semget的参数相同是一个键值，用来标识唯一的共享内存，size表示共享内存的大小，shmflg除了支持semflag的参数，还支持两个额外的参数
- SHM_HUGETLB 系统使用大页面分配空间 
- SHM_NORESERVE 不为共享内存保留交换分区，物理内存不足将触发SIGSEGV信号

shmat和shmdt系统调用
这两个函数分别把共享内存关联到进程和把共享内存从进程中分离。
``` c
#include <sys/types.h>
#include <sys/shm.h>
void *shmat(int shmid, const void *shmaddr, int shmflg);
```
shmid:共享内存标识
shmaddr:共享内存关联到进程的哪块地址空间
- 如果shmaddr为NULL，操作系统选择进程关联的地址
- 如果shmaddr非NULL，SHM_RND未被设置，共享内存映射到shmaddr
- 如果shmaddr非NULL，shmflg设置为了SHM_RND,被关联的地址为shmaddr-shmaddr%SHMLBA(段低端边界地址倍数) 

shmflg: 
- SHM_RND表示圆整，将共享内存关联到离shmaddr最近的SHMLBA(段低端边界地址倍数)的整数倍处
- SHM_RDONLY 进程只能读取共享内存中的数据
- SHM_REMAP 如果shmaddr已经被关联到一段共享内存则重新关联
- SHM_EXEC 对共享内存的执行权限相当于读权限

``` c
#include <sys/types.h>
#include <sys/shm.h>
int shmdt(const void *shmaddr);
```
shmaddr需要取消关联的进程地址
shmctl系统调用
``` c
#include <sys/ipc.h>
#include <sys/shm.h>
int shmctl(int shmid, int cmd, struct shmid_ds *buf);
```
shmid：shmget返回的标识
cmd: 将要采取的动作

|命令|含义|成功时返回值|
|:----:|:----:|:----:|
|IPC_STAT|将共享内存相关数据结构复制到buf|0|
|IPC_SET|将buf中部分数据复制到共享内存相关的数据结构中，更新shmid_ds.shm_ctime|0|
|IPC_RMID|将共享内存打上删除标记，没有关联的进程就删除共享内存|0|
|SHM_INFO|获取共享内存资源配置信息存储到buf|共享内存信息数组已被使用的最大索引值|
|SHM_STAT|与IPC_STAT类似，shm_id此时表示共享内存信息数组索引|共享内存信息数组索引值为shm_id的标识符|
|SHM_LOCK|禁止共享内存被移至交换分区|0|
|SHN_UNLOCK|允许共享内存被移至交换分区|0|

POSIX方法
``` c
#include <sys/mman.h>
#include <sys/stat.h>        /* For mode constants */
#include <fcntl.h>           /* For O_* constants */
int shm_open(const char *name, int oflag, mode_t mode);
int shm_unlink(const char *name);
```
实例，利用共享内存进行客户端服务器通信
``` c
//commen.h
#ifndef __COMMEN_H__

#define __COMMEN_H__

#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <unistd.h>

#define PATHNAME "."
#define PROJ_ID 0x666

int CreateShm(int size);
int DestoryShm(int shmid);
int GetShm(int size);

#endif /* end of include guard: __COMMEN_H__ */
```
``` c
//commen.c
#ifndef __COMMEN_H__

#define __COMMEN_H__

#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <unistd.h>

#define PATHNAME "."
#define PROJ_ID 0x666

int CreateShm(int size);
int DestoryShm(int shmid);
int GetShm(int size);

#endif /* end of include guard: __COMMEN_H__ */
[stj@localhost shm]$ cat commen.c
#include "commen.h"

int CommenShm(int size, int flags) {
  key_t key = ftok(PATHNAME,PROJ_ID);
  if (key < 0) {
    perror("ftok");
    return -1;
  }
  int shmid = shmget(key,size,flags);
  if (shmid < 0) {
    perror("shmget");
    return -2;
  }
  return shmid;
}
int CreateShm(int size) {
  return CommenShm(size,IPC_CREAT | IPC_EXCL | 0666);
}
int DestoryShm(int shmid) {
  int ret = shmctl(shmid,IPC_RMID,NULL);
  if (ret < 0) {
    perror("shmctl");
    return -1;
  }
  return 0;
}
int GetShm(int size) {
  return CommenShm(size,IPC_CREAT);
}
```
``` c
//server.c
#include "commen.h"

int main() {
  int shmid = CreateShm(1024);
  if (shmid < 0) {
    shmid = GetShm(1024);
    if (shmid < 0) {
      return -1;
    }
  }
  char *addr = (char*)shmat(shmid,0,0);
  if (addr == (void*)-1) {
    perror("shmat");
  }
  /*char *addr =(char*)shmat(shmid,NULL,0);*/
  for (int i = 0; i < 10; i++) {
    printf("client: %s\n",addr);
    sleep(1);
  }
  shmdt(addr);
  sleep(1);
  DestoryShm(shmid);
  return 0;
}
```
``` c
//client.c
#include "commen.h"

int main() {
  int shmid = GetShm(1024);
  if (shmid < 0) {
    return -1;
  }
  char *addr = (char*)shmat(shmid,NULL,0);
  if (NULL == addr) {
    return -1;
  }
  for (int i = 0; i < 10; i++) {
    addr[i] = 'A' + i;
    addr[i+1] = 0;
    printf("%s\n",addr);
    sleep(1);
  }
  shmdt(addr);
  sleep(1);
  return 0;
}
```


