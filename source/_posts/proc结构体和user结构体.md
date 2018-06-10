---
layout: unix
title: UNIX v6的进程控制块proc结构体和user结构体
date: 2017-12-18 17:38:39
tags: 学习笔记
category: Linux
---
进程的状态信息和控制信息等由 proc 结构体和 user 结构体管理。每个进程各自会被分配1 组上述结构体的实例。 proc 结构体常驻内存，而 user 结构体有可能被移至交换空间。
<!--more-->
### proc 结构体
由 proc 结构体构成的数组 proc[]中的每个元素分别对应一个进程。proc 结构体管理着在进程状态、执行优先级等与进程相关的信息中需要经常被内核访问的那部分信息。举例来说，内核在（进程切换过程中）选择下一个将被执行的进程时，会首先检查所有进程的状态。这种需要遍历所有进程的情况在其他处理中也会经常出现。由于 proc[] 常驻内存，因此内核可以在很短时间内完成对所有进程状态的检查。假如proc[] 能够被移至交换空间，内核必须访问交换空间才能取得相应数据，这会导致花费过多时间并引起性能下降。proc[] 的长度决定了在系统中可以同时存在的进程上限。 proc[] 的长度由常量NPROC 定义，其值为50
``` c
struct proc
{
 char p_stat;
 char p_flag;
 char p_pri;
 char p_sig;
 char p_uid;
 char p_time;
 char p_cpu;
 char p_nice;
 int p_ttyp;
 int p_pid;
 int p_ppid;
 int p_addr;
 int p_size;
 int p_wchan;
 int *p_textp;
 } proc[NPROC];

 /* stat codes */
 #define SSLEEP 1
 #define SWAIT 2
 #define SRUN 3
 #define SIDL 4
 #define SZOMB 5
 #define SSTOP 6

 /* flag codes */
 #define SLOAD 01
 #define SSYS 02
 #define SLOCK 04
 #define SSWAP 010
 #define STRC 020
 #define SWTED 040
```
成员 | 含义
----|-----
p_stat | 状态。等于NULL时意味着 proc[]数组中该元素为空。参见表进程的状态
p_flag |标志变量。参见表进程的标志常量
p_pri |执行优先级。数值越小优先级越高，下次被执行的可能性也就越大
p_sig |接收到的信号
p_uid |用户ID（整数）
p_time |在内存或交换空间内存在的时间（秒）
p_cpu |占用CPU的累计时间（时钟tick 数）
p_nice |用来降低执行优先级的补正系数。缺省值是0，通过系统调用nice可以设置成用户希望的数值
p_ttyp |正在操作进程的终端
p_pid |进程ID
p_ppid |父进程ID
p_addr |数据段的物理地址（单位为64字节）
p_size |数据段的长度（单位为64字节）
p_wchan |使进程进入休眠状态的原因
*p_textp |使用的代码段（text segment）

#### 进程的状态
状态|含义
-----|------
SSLEEP |高优先级休眠状态。执行优先级为负值
SWAIT |低优先级休眠状态。执行优先级为0 或正值
SRUN |可执行状态
SIDL |进程生成中
SZOMB |僵尸状态
SSTOP |等待被跟踪（trace）

### user结构体
user结构体用来管理进程打开的文件或目录等信息。由于内核只需要当前执行进程的user结构体，因此当进程被换出至交换空间时，对应的user 结构体也会被移出内存。
``` c
struct user
{
 int u_rsav[2];
 int u_fsav[25];
 char u_segflg;
 char u_error;
 char u_uid;
 char u_gid;
 char u_ruid;
 char u_rgid;
 int u_procp;
 char *u_base;
 char *u_count;
 char *u_offset[2];
 int *u_cdir;
 char u_dbuf[DIRSIZ];
 char *u_dirp;
 struct {
 int u_ino;
 char u_name[DIRSIZ];
 } u_dent;
 int *u_pdir;
 int u_uisa[16];
 int u_uisd[16];
 int u_ofile[NOFILE];
 int u_arg[5];
 int u_tsize;
 int u_dsize;
 int u_ssize;
 int u_sep;
 int u_qsav[2];
 int u_ssav[2];
 int u_signal[NSIG];
 int u_utime;
 int u_stime;
 int u_cutime[2];
 int u_cstime[2];
 int *u_ar0;
 int u_prof[4];
 char u_intflg;
 } u;

 /* u_error codes */
 #define EFAULT 106
 #define EPERM 1
 #define ENOENT 2
 #define ESRCH 3
 #define EINTR 4
 #define EIO 5
 #define ENXIO 6
 #define E2BIG 7
 #define ENOEXEC 8
 #define EBADF 9
 #define ECHILD 10
 #define EAGAIN 11
 #define ENOMEM 12
 #define EACCES 13
 #define ENOTBLK 15
 #define EBUSY 16
 #define EEXIST 17
 #define EXDEV 18
 #define ENODEV 19
 #define ENOTDIR 20
 #define EISDIR 21
 #define EINVAL 22
 #define ENFILE 23
 #define EMFILE 24
 #define ENOTTY 25
 #define ETXTBSY 26
 #define EFBIG 27
 #define ENOSPC 28
 #define ESPIPE 29
 #define EROFS 30
 #define EMLINK 31
 #define EPIPE 32
```

成员 | 含义
-----|-----
u_rsav[] |进程切换时用来保存r5 和r6的当前值
u_fsav[] |处理器为PDP-11/40时不使用
u_segflg |读写文件时使用的标志变量
u_error |出错时用来保存错误代码。
u_uid |实效用户（ effective user）①ID
u_gid |实效组（effective group）ID
u_ruid |实际用户（real user）ID
u_rgid |实际组（real group）ID
*u_procp| 此user结构体对应的数组proc[]的元素
*u_base |读写文件时用于传递参数
*u_count |读写文件时用于传递参数
*u_offset[]| 读写文件时用于传递参数
*u_cdir| 当前目录对应的数组inode[]的元素
u_dbuf[]| 供函数namei()使用的临时工作变量，用来存放文件和目录名
*u_dirp |在读取由用户程序或内核程序传来的文件的路径名时使用
u_dent |供函数namei()使用的临时工作变量，用来存放目录数据。u_ino存放inode编号，u_name存放文件和目录名
*u_pdir |供函数namei()存放对象文件和目录的父目录
u_uisa[] |用户PAR的值
u_uisd[] |用户PDR的值
u_ofile[]|由进程打开的文件
u_arg[] |用户程序向系统调用传递参数时使用
u_tsize |代码段的长度（单位为64字节）
u_dsize |数据区域的长度（单位为64字节）
u_ssize |栈区域的长度（单位为64字节）
u_sep |处理器为PDP-11/40时此项基本为0
u_qsav[] |在系统调用处理中处理信号时用来保存r5和r6 的当前值
u_ssav[] |当进程被换出至交换空间，导致user.u_rsav[]的值不再有效时，用于保存r5 和r6 的当前值
u_signal[] |用于设置收到信号后的动作
u_utime |用户模式下占用CPU的时间（时钟tick 数）
u_stime |内核模式下占用CPU的时间（时钟tick 数）
u_cutime[]| 子进程在用户模式下占用CPU的时间（时钟tick 数）
u_cstime[] |子进程在内核模式下占用CPU的时间（时钟tick 数）
*u_ar0 |系统调用处理中，操作用户进程的通用寄存器或PSW 时使用
u_prof[]| 用于统计，本书不做说明
u_intflg |标志变量，用于判断系统调用处理中是否发生了对信号的处理

#### 错误代码
错误代码 | 含义
-----|-----
EFAULT |在用户空间和内核空间之间传送数据失败等
EPERM |当前用户不是超级用户
ENOENT |指定文件不存在
ESRCH |信号的目标进程不存在，或者已结束
EINTR |系统调用处理中对信号做了处理
EIO |I/O 错误
ENXIO |设备编号所示设备不存在
E2BIG |通过系统调用exec向待执行程序传送了超过512字节的参数
ENOEXEC| 无法识别待执行程序的格式（魔术数字，magic number）
EBADF |试图操作未打开的文件，或者试图写入用只读模式打开的文件，或者试图读出用只写模式打开的文件
ECHILD |执行系统调用wait时，无法找到子进程
EAGAIN |执行系统调用fork时，无法在数组proc[]中找到空元素
ENOMEM |试图向进程分配超过可使用容量以上的内存
EACCES |没有对文件或目录的访问权限
ENOTBLK |不是代表块设备的特殊文件
EBUSY |执行系统调用mount、umount时，作为对象的挂载点仍在使用中
EEXIST |执行系统调用link时该文件已经存在
EXDEV |试图对其他设备上的文件创建连接
ENODEV |设备编号所示设备不存在
ENOTDIR |不是目录
EISDIR |试图对目录进行写入操作
EINVAL |参数有误
ENFILE |数组file[]溢出
EMFILE |数组user.u_ofile[]溢出
ENOTTY |不是代表终端的特殊文件
ETXTBSY |准备加载至代码段的程序文件曾被其他进程当做数据文件使用。或者对准备加载至代码段的程序文件进行了写入操作
EFBIG |文件尺寸过大
ENOSPC |块设备的容量不足
ESPIPE |对管道文件执行了系统调用seek
EROFS |试图更新只读块设备上的文件或目录
EMLINK |文件连接数过多
EPIPE |损坏的管道文件

### 参考书籍
- Unix内核源码剖析