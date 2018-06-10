---
title: Linux进程间通信之信号量
date: 2018-03-30 21:32:06
tag: 学习笔记
category: Linux
---
信号量是另一种IPC机制，它只要用于进程之间的同步互斥。
<!--more-->
#### 信号量和P、V原语
信号量
- 同步：P、V在不同进程
- 互斥：P、V在同一进程中

信号量值的含义
- S>0:可用资源的个数
- S=0:无资源可用，无等待进程
- S<0:等待队列中进程的个数

信号量集结构
``` c
struct semid_ds {
  struct ipc_perm sem_perm;  /* Ownership and permissions */     time_t       sem_otime; /* Last semop time */
  time_t       sem_ctime; /* Last change time */
  unsigned short  sem_nsems; /* No. of semaphores in set */
};
```
semget系统调用,用来创建一个新的信号量集或者获取一个已经存在的信号量集
``` c
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>
int semget(key_t key, int nsems, int semflg);
```
key是一个键值用来标识全局唯一的信号量集。
nsems指定要创建/获取的信号量集中信号量的数目，如果创建信号量该值必须被指定，如果是获取已经存在的信号量可以设置为0.
semflg指定一组标志，低9位是信号量的权限。
成功返回一个正整数，失败返回-1并设置错误码。

semop系统调用可以改变信号量的值进行P、V操作
``` c
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>
int semop(int semid, struct sembuf *sops, unsigned nsops);
```
semid是semget返回的信号量集标识符
sops指向一个结构体类型的数组
``` c
struct sembuf{
  unsigned short sem_num;  /* semaphore number */
  short sem_op;   /* semaphore operation */
  short sem_flg;  /* operation flags */
}
```
sem_num表示信号量的编号，从0开始
sem_op表示操作类型
sem_flg可选值IPC_NOWAIT,SEM_UNDO分别表示无论信号量是否操作成功都立即返回和进程退出时取消sem_op操作。

semctl系统调用
``` c
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>
int semctl(int semid, int semnum, int cmd, ...);
```
semid是semget返回的信号量标识，semum表示信号量编号，cmd表示要执行的命令
常用的命令

命令| 含义
---|---
SETVAL|设置信号量集中信号量的计数
SGETVAL|获取信号量集中信号量的计数
IPC_STAT|把内核中和信号量相关的数据结构semid_ds设置为当前关联值
IPC_SET|把信号量集的关联值设置为semid_ds中的值
IPC_RMID| 删除信号量集

当需要第四个参数值时需要定义成一个枚举类型
``` c
union semun {
  int val;    /* Value for SETVAL */
  struct semid_ds *buf;    /* Buffer for IPC_STAT, IPC_SET */
  unsigned short  *array;  /* Array for GETALL, SETALL */
  struct seminfo  *__buf;  /* Buffer for IPC_INFO
                                           (Linux-specific) */
  };
```
实例
``` c
//commen.h
#ifndef __COMMEN_H__
#define __COMMEN_H__

#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <unistd.h>

#define PATHNAME "."
#define PROJ_ID 0x666

union semun {
  int              val;    /* Value for SETVAL */
  struct semid_ds *buf;    /* Buffer for IPC_STAT, IPC_SET */
  unsigned short  *array;  /* Array for GETALL, SETALL */
  struct seminfo  *__buf;  /* Buffer for IPC_INFO
                              (Linux-specific) */
};

int CreateSem(int nums);
int InitSem(int semid, int nums, int val);
int GetSem(int nums);
int P(int semid, int who);
int V(int semid, int who);
int DestorySem(int semid);


#endif /* end of include guard: __COMMEN_H__ */

```
``` c
//commen.c
#include "commen.h"

static int CommenSem(int nums,int flags) {
  key_t key = ftok(PATHNAME, PROJ_ID);
  if (key < 0) {
    perror("ftok");
    return -1;
  }
  int semid = semget(key,nums,flags);
  if(semid < 0) {
    perror("semid");
    return -2;
  }
  return semid;
}
int CreateSem(int nums) {
  return CommenSem(nums,IPC_CREAT | IPC_EXCL | 0666);
}
int InitSem(int semid, int nums, int val) {
  union semun un;
  un.val = val;
  if (semctl(semid,nums,SETVAL,un) < 0) {
    perror("semctl");
    return -1;
  }
  return 0;
}
int GetSem(int nums) {
  return CommenSem(nums,IPC_CREAT);
}
static int CommenPV(int semid, int who,int op) {
  struct sembuf sf;
  sf.sem_num = who;
  sf.sem_op = op;
  sf.sem_flg = 0;
  if(semop(semid, &sf, 1) < 0) {
    perror("semop");
    return -1;
  }
  return 0;
}
int P(int semid, int who) {
  return CommenPV(semid,who,-1);
}
int V(int semid, int who) {
  return CommenPV(semid,who,1);
}
int DestorySem(int semid) {
  if (semctl(semid,0,IPC_RMID) < 0) {
    perror("semctl");
    return -1;
  }
  return 0;
}

```
``` c
//sem.c
#include "commen.h"

int main() {
  int semid = CreateSem(1);
  if (semid < 0) {
    semid = GetSem(1);
  }
  InitSem(semid,0,1);
  pid_t pid = fork();
  if (pid == 0) {
    int child_semid = GetSem(0);
    while (1) {
      P(child_semid,0);
      printf("A");
      fflush(stdout);
      usleep(123456);
      printf("A ");
      fflush(stdout);
      usleep(345123);
      V(child_semid,0);
    }
  }
  return 0;
}

```