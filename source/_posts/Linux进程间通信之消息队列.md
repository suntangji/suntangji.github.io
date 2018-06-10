---
title: Linux进程间通信之消息队列
date: 2018-03-28 13:35:20
tags: 学习笔记
category: Linux
---
消息队列时操作系统内核为我们提供的一个链表，用于进程间通信。
<!--more-->
消息队列的结构/usr/include/linux/msg.h
``` c
struct msqid_ds {
struct ipc_perm msg_perm;
struct msg *msg_first; /* first message on queue,unused */
struct msg *msg_last; /* last message in queue,unused */
__kernel_time_t msg_stime; /* last msgsnd time */
__kernel_time_t msg_rtime; /* last msgrcv time */
__kernel_time_t msg_ctime; /* last change time */
unsigned long msg_lcbytes; /* Reuse junk fields for 32 bit */
unsigned long msg_lqbytes; /* ditto */
unsigned short msg_cbytes; /* current number of bytes on queue */
unsigned short msg_qnum; /* number of messages in queue */
unsigned short msg_qbytes; /* max number of bytes on queue */
__kernel_ipc_pid_t msg_lspid; /* pid of last msgsnd */
__kernel_ipc_pid_t msg_lrpid; /* last receive pid */
};
```
内核为IPC对象维护的数据结构/usr/include/linux/ipc.h
``` c
struct ipc_perm {
key_t __key; /* Key supplied to xxxget(2) */
uid_t uid; /* Effective UID of owner */
gid_t gid; /* Effective GID of owner */
uid_t cuid; /* Effective UID of creator */
gid_t cgid; /* Effective GID of creator */
unsigned short mode; /* Permissions */
unsigned short __seq; /* Sequence number */
};
```
msgget系统调用
``` c
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
int msgget(key_t key, int msgflg);
```
msgget创建一个消息队列或者获取一个已经存在的消息队列，key是一个键值，用来标识唯一的消息队列，msgflg用来表示权限，成功返回消息队列的标识码，失败返回-1.
可以使用ftok函数创建一个key
``` c
#include <sys/types.h>
#include <sys/ipc.h>
key_t ftok(const char *pathname, int proj_id);
```
pathname为路径名，proj_id为项目id
msgctl系统调用
``` c
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
int msgctl(int msqid, int cmd, struct msqid_ds *buf);
```
msgid:msgget返回的标识码
cmd:表示要执行的命令

|命令 | 含义 | 成功时返回值|
|--- | ---- | ---|
|IPC_STAT | 将消息队列关联的数据结构复制到buf | 0|
|IPC_SET | 将buf中的部分成员复制到消息队列关联的数据结构| 0|
|IPC_RMID | 立即移除消息队列，唤醒所有等待读消息和写消息的进程 | 0|
|IPC_INFO | 获取系统消息队列资源配置信息存储到buf中 | 内核中消息队列数组中已经被使用项的最大索引值|
|MSG_INFO | 与IPC_INFO类似，返回已经分配的消息队列占用资源信息 | 同IPC_INFO|
|MSG_STAT | 与IPC_STAT类似，msqid不再表示消息队列标识符，表示消息队列数组索引| 索引为msqid的消息队列标识符|

msgsnd/msgrcv系统调用
``` c
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
int msgsnd(int msqid, const void *msgp, size_t msgsz, int msgflg);
ssize_t msgrcv(int msqid, void *msgp, size_t msgsz, long msgtyp,int msgflg);
```
msgid:由msgget返回的消息队列标识符
msgp: 指向准备发送信息的指针
要发送的信息必须是如下类型
``` c
 struct msgbuf {
               long mtype;       /* message type, must be > 0 */
               char mtext[1];    /* message data */
           };
```
mtype是消息类型，mtext是消息数据
msgsz:消息的长度
msgtyp:指定接收哪种消息类型
> msgtype等于0：读取消息队列中的第一个消息
msgtype大于0：读取消息队列中第一个类型为msgtype的消息
msgtype小于0：读取消息队列中第一个类型小于msgtype绝对值的消息

msgflg:
- msgsnd

> 通常仅支持IPC_NOWAIT标志，即以非阻塞的方式发送消息

- msgrcv

> IPC_NOWAIT,如果消息队列中没有消息，则msgrcv调用立即返回并设置errno
MSG_EXCEPT,如果msgtype大于0，则接收消息队列中第一个非msgtype类型的消息
MSG_NOERROR,如果消息队列的长度超过了msgsz就将它截断

成功返回0，失败返回-1，成功时也会修改内核数据结构msgid_ds的部分字段
> msgsnd
- msgsnd将msg_qnum加1
- 将msg_lspid设置为调用进程的PId
- 将msg_stime设置为当前时间


> msgrcv
- 将msg_qnum减1
- 将msg_lrpid设置为调用进程的pid
- 将msg_rtime设置为当前的时间

IPC命令
> ipcs命令可以查看当前的消息队列、共享内存、信号量
ipcrm -q/m/s命令可以按id删除消息队列/共享内存/信号量
ipcrm -Q/M/S命令可以按键值删除消息队列/共享内存/信号量

实例
``` c
//commen.h
#ifndef __COMMEN_H__
#define __COMMEN_H__
#include <sys/msg.h>
#include <sys/ipc.h>
#include <sys/types.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

#define PROJ_ID 0x1234
#define PATHNAME "."
#define SERVER_TYPE 1
#define CLIENT_TYPE 2

struct Msgbuf {
  long mtype;
  char mtext[1024];
};
int CreateMsg();
int GetMsg();
int DestoryMsg(int msgid);
int SendMsg(int msgid,long type,char* msg);
int RecvMsg(int msgid,int type,char out[]) ;

#endif // __COMMEN_H__
```
``` c
//commen.c
#include "commen.h"

int Commen(int flag) {
  key_t key = ftok(PATHNAME,PROJ_ID);
  if(key < 0) {
    perror("ftok");
    return -1;
  }
  int msgid = msgget(key,flag);
  if(msgid < 0) {
    perror("msgget");
    /*return -1;*/
  }
  return msgid;
}

int CreateMsg() {
  int ret =  Commen(IPC_CREAT | IPC_EXCL | 0666) ;
  if(-1 == ret) {
    return Commen(IPC_CREAT);
  } else
    return ret;
}

int GetMsg() {
  return Commen(IPC_CREAT | 0666);
}

int DestoryMsg(int msgid) {
  if(msgctl(msgid,IPC_RMID,NULL) < 0) {
    perror("msgctl_ipcrmid");
    return -1;
  }
  return 0;
}
int SendMsg(int msgid,long type,char* msg) {
  struct Msgbuf buf;
  buf.mtype = type;
  strcpy(buf.mtext,msg);
  int ret = msgsnd(msgid,&buf,sizeof(buf.mtext),0);
  if(ret < 0) {
    perror("msgsnd");
    return -1;
  }
  return 0;
}
int RecvMsg(int msgid,int type,char out[]) {
  struct Msgbuf buf[1];
  int ret = msgrcv(msgid,&buf,sizeof(buf[0].mtext),type,0);
  if(ret < 0) {
    perror("msgrcv");
    return -1;
  }
  strcpy(out,buf[0].mtext);
  return 0;
}

```
``` c
//server.c
#include "commen.h"

int main() {
  int msgid = CreateMsg();
  if(msgid < 0) {
    perror("CreateMsg");
    return -1;
  }
  char buf[1024];
  while(1) {
    RecvMsg(msgid,CLIENT_TYPE,buf);
    printf("client: %s\n",buf);
    printf("server enter#");
    fflush(stdout);
    ssize_t read_sz = read(0,buf,sizeof(buf));
    if(read_sz > 0) {
      buf[read_sz -1] = 0;
      SendMsg(msgid,SERVER_TYPE,buf);
    }
  }



  return 0;
}

```
``` c
//client.c
#include "commen.h"
int main() {
  int msgid = GetMsg();
  if(msgid < 0) {
    perror("msgget");
  }
  char buf[1024];
  while(1) {
    printf("clent enter#");
    fflush(stdout);
    ssize_t read_sz = read(0,buf,sizeof(buf));
    if(read_sz > 0) {
      buf[read_sz - 1] = 0;
      SendMsg(msgid,CLIENT_TYPE,buf);
    }
    RecvMsg(msgid,SERVER_TYPE,buf);
    printf("server: %s\n",buf);
  }
  return 0;
}

```