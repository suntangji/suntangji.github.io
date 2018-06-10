---
title: linux的进程控制块task_struct
date: 2017-12-18 23:06:21
tags: 学习笔记
category: Linux
---
Linux 中的每个进程由一个task_struct 数据结构来描述，在Linux 中，任务（Task）和进程（Process）是两个相同的术语，task_struct 其实就是通常所说的“进程控制块”即PCB。task_struct 容纳了一个进程的所有信息，是系统对进程进行控制的唯一手段，也是最有效的手段。
<!--more-->
### 按功能可做如下划分
- 进程状态（State）
- 进程调度信息（Scheduling Information）
- 各种标识符（Identifiers）
- 进程通信有关信息（IPC，Inter_Process Communication）
- 时间和定时器信息（Times and Timers）
- 进程链接信息（Links）
- 文件系统信息（File System）
- 虚拟内存信息（Virtual Memory）
- 页面管理信息（page）
- 对称多处理器（SMP）信息
- 和处理器相关的环境（上下文）信息（Processor Specific Context）
- 其他信息

#### 进程状态 
进程执行时，它会根据具体情况改变状态。进程状态是调度和对换的依据。Linux 中的进程主要有如下状态

内核表示 |含义
--------|-------
TASK_RUNNING |可运行
TASK_INTERRUPTIBLE |可中断的等待状态
TASK_UNINTERRUPTIBLE |不可中断的等待状态
TASK_ZOMBIE |僵死
TASK_STOPPED |暂停
TASK_SWAPPING |换入/换出
1. 可运行状态
处于这种状态的进程，要么正在运行、要么正准备运行。正在运行的进程就是当前进程（由current 所指向的进程），而准备运行的进程只要得到CPU 就可以立即投入运行，CPU 是这些进程唯一等待的系统资源。系统中有一个运行队列（run_queue），用来容纳所有处于可运行状态的进程，调度程序执行时，从中选择一个进程投入运行。在后面我们讨论进程调度的时候，可以看到运行队列的作用。当前运行进程一直处于该队列中，也就是说，current总是指向运行队列中的某个元素，只是具体指向谁由调度程序决定。
2. 等待状态
处于该状态的进程正在等待某个事件（Event）或某个资源，它肯定位于系统中的某个等待队列（wait_queue）中。Linux 中处于等待状态的进程分为两种：可中断的等待状态和不可中断的等待状态。处于可中断等待态的进程可以被信号唤醒，如果收到信号，该进程就从等待状态进入可运行状态，并且加入到运行队列中，等待被调度；而处于不可中断等待态的进程是因为硬件环境不能满足而等待，例如等待特定的系统资源，它任何情况下都不能被打断，只能用特定的方式来唤醒它，例如唤醒函数wake_up（）等。
3. 暂停状态
此时的进程暂时停止运行来接受某种特殊处理。通常当进程接收到SIGSTOP、SIGTSTP、SIGTTIN 或 SIGTTOU 信号后就处于这种状态。例如，正接受调试的进程就处于这种状态。
4. 僵死状态
进程虽然已经终止，但由于某种原因，父进程还没有执行wait()系统调用，终止进程的信息也还没有回收。顾名思义，处于该状态的进程就是死进程，这种进程实际上是系统中的垃圾，必须进行相应处理以释放其占用的资源。
#### 进程调度信息
调度程序利用这部分信息决定系统中哪个进程最应该运行，并结合进程的状态信息保证系统运转的公平和高效。这一部分信息通常包括进程的类别（普通进程还是实时进程）、进程的优先级等。

域名 |含义
------|------
need_resched| 调度标志
Nice |静态优先级
Counter| 动态优先级
Policy |调度策略
rt_priority |实时优先级
##### 进程的调度策略
名称|解释 |适用范围
-----|-----|------
SCHED_OTHER |其他调度| 普通进程
SCHED_FIFO |先来先服务调度|实时进程 
SCHED_RR| 时间片轮转调度|实时进程
> 只有root 用户能通过sched_setscheduler()系统调用来改变调度策略。

#### 标识符（Identifiers）
每个进程有进程标识符、用户标识符、组标识符，不管对内核还是普通用户来说，怎么用一种简单的方式识别不同的进程呢？这就引入了进程标识符（PID，process identifier），每个进程都有一个唯一的标识符，内核通过这个标识符来识别不同的进程，同时，进程标识符PID 也是内核提供给用户程序的接口，用户程序通过PID 对进程发号施令。PID 是32 位的无符号整数，它被顺序编号：新创建进程的PID通常是前一个进程的PID 加1。然而，为了与16 位硬件平台的传统Linux 系统保持兼容，在Linux 上允许的最大PID 号是32767，当内核在系统中创建第32768 个进程时，就必须重新开始使用已闲置的PID 号。

域名 |含义
-----|------
Pid |进程标识符
Uid、gid |用户标识符、组标识符
Euid、egid| 有效用户标识符、有效组标识符
Suid、sgid |备份用户标识符、备份组标识符
Fsuid、fsgid| 文件系统用户标识符、文件系统组标识符
#### 进程通信有关信息（IPC，Inter_Process Communication）
为了使进程能在同一项任务上协调工作，进程之间必须能进行通信即交流数据。Linux 支持多种不同形式的通信机制。它支持典型的UNIX 通信机制（IPC Mechanisms）：信号（Signals）、管道（Pipes），也支持System V 通信机制：共享内存（Shared Memory）、信号量和消息队列（Message Queues）

域名 | 含义
------|------
Spinlock_t sigmask_lock| 信号掩码的自旋锁
Long blocked |信号掩码
Struct signal *sig |信号处理函数
Struct sem_undo *semundo| 为避免死锁而在信号量上设置的取消操作
Struct sem_queue *semsleeping| 与信号量操作相关的等待队列
#### 进程链接信息（Links）
程序创建的进程具有父/子关系。因为一个进程能创建几个子进程，而子进程之间有兄弟关系，在task_struct 结构中有几个域来表示这种关系。
在Linux 系统中，除了初始化进程init，其他进程都有一个父进程（Parent Process）或称为双亲进程。可以通过fork（）或clone()系统调用来创建子进程，除了进程标识符（PID）等必要的信息外，子进程的task_struct 结构中的绝大部分的信息都是从父进程中拷贝，或说“克隆”过来的。系统有必要记录这种“亲属”关系，使进程之间的协作更加方便，例如父进程给子进程发送杀死（kill）信号、父子进程通信等，就可以用这种关系很方便地实现。
每个进程的task_struct 结构有许多指针，通过这些指针，系统中所有进程的task_struct结构就构成了一棵进程树，这棵进程树的根就是初始化进程init 的task_struct结构（init 进程是Linux 内核建立起来后人为创建的一个进程，是所有进程的祖先进程）。

名称 |英文解释 |中文解释 [指向哪个进程]
----|----|-----
p_opptr Original |parent |祖先
p_pptr |Parent| 父进程
p_cptr |Child| 子进程
p_ysptr Younger |sibling |弟进程
p_osptr Older |sibling |兄进程
Pidhash_next、Pidhash_pprev| |进程在哈希表中的链接
Next_task、 prev_task| | 进程在双向循环链表中的链接
Run_list | |运行队列的链表
#### 时间和定时器信息（Times and Timers）
一个进程从创建到终止叫做该进程的生存期（lifetime）。进程在其生存期内使用CPU的时间，内核都要进行记录，以便进行统计、计费等有关操作。进程耗费CPU 的时间由两部分组成：一是在用户模式（或称为用户态）下耗费的时间、一是在系统模式（或称为系统态）下耗费的时间。每个时钟滴答，也就是每个时钟中断，内核都要更新当前进程耗费CPU 的时间信息。
##### 与时间有关的域
域名 |含义
-----|-----
Start_time |进程创建时间
Per_cpu_utime| 进程在某个CPU 上运行时在用户态下耗费的时间
Per_cpu_stime |进程在某个CPU 上运行时在系统态下耗费的时间
Counter| 进程剩余的时间片
##### 进程的所有定时器
定时器类型 |解释 |什么时候更新 |用来表示此种定时器的域
-----|-----|------|-----
ITIMER_REAL| 实时定时器 |实时更新，即不论该进程是否运行|it_real_value it_real_incr real_timer
ITIMER_VIRTUAL |虚拟定时器 |只在进程运行于用户态时更新|it_virt_value it_virt_incr 
ITIMER_PROF |概况定时器 |进程运行于用户态和系统态时更新 |it_prof_value it_prof_incr

进程有3 种类型的定时器：实时定时器、虚拟定时器和概况定时器。这3 种定时器的特征共有3 个：到期时间、定时间隔和要触发的事件。到期时间就是定时器到什么时候完成定时操作，从而触发相应的事件；定时间隔就是两次定时操作的时间间隔，它决定了定时操作是否继续进行，如果定时间隔大于0，则在定时器到期时，该定时器的到期时间被重新赋值，使定时操作继续进行下去，直到进程结束或停止使用定时器，只不过对不同的定时器，到期时间的重新赋值操作是不同的
#### 文件系统信息（File System）
进程可以打开或关闭文件，文件属于系统资源，Linux 内核要对进程使用文件的情况进行记录。task_struct 结构中有两个数据结构用于描述进程与文件相关的信息。其中，fs_struct 中描述了两个VFS 索引节点（VFS inode），这两个索引节点叫做root 和pwd，分别指向进程的可执行映像所对应的根目录（Home Directory）和当前目录或工作目录。file_struct 结构用来记录了进程打开的文件的描述符（Descriptor）。

定义形式 |解释
-------|-------
Sruct fs_struct *fs| 进程的可执行映像所在的文件系统
Struct files_struct *files| 进程打开的文件

在文件系统中，每个VFS 索引节点唯一描述一个文件或目录，同时该节点也是向更低层的文件系统提供的统一的接口。
#### 虚拟内存信息（Virtual Memory）
除了内核线程（Kernel Thread），每个进程都拥有自己的地址空间（也叫虚拟空间），用mm_struct 来描述。另外Linux 2.4 还引入了另外一个域active_mm，这是为内核线程而引入的。因为内核线程没有自己的地址空间，为了让内核线程与普通进程具有统一的上下文切换方式，当内核线程进行上下文切换时，让切换进来的线程的active_mm 指向刚被调度出去的进程的active_mm（如果进程的mm 域不为空，则其active_mm 域与mm 域相同）

定义形式 |解释
--------|--------
Struct mm_struct *mm| 描述进程的地址空间
Struct mm_struct *active_mm| 内核线程所借用的地址空间

#### 页面管理信息
当物理内存不足时，Linux 内存管理子系统需要把内存中的部分页面交换到外存，其交换是以页为单位的。

定义形式 |解释
------|------
Int swappable |进程占用的内存页面是否可换出
Unsigned long min_flat,maj_flt,nswap |进程累计的次（minor）缺页次数、主(major)次数及累计换出、换入页面数
Unsigned long cmin_flat,cmaj_flt,cnswap |本进程作为祖先进程，其所有层次子进程的累计的次（minor）缺页次数、主(major)次数及累计换出、换入页面数
#### 对称多处理机（SMP）信息
定义形式 |解释
------|-----
Int has_cpu |进程当前是否拥有CPU
Int processor| 进程当前正在使用的CPU
Int lock_depth |上下文切换时内核锁的深度

#### 和处理器相关的环境（上下文）信息（Processor Specific Context）
这里要特别注意标题：和“处理器”相关的环境信息。进程作为一个执行环境的综合，当系统调度某个进程执行，即为该进程建立完整的环境时，处理器（Processor）的寄存器、堆栈等是必不可少的。因为不同的处理器对内部寄存器和堆栈的定义不尽相同，所以叫做“和处理器相关的环境”，也叫做“处理机状态”。当进程暂时停止运行时，处理机状态必须保存在进程的task_struct 结构中，当进程被调度重新运行时再从中恢复这些环境，也就是恢复这些寄存器和堆栈的值

定义形式 |解释
------|-----
Struct thread_struct *tss |任务切换状态
#### 其他
1. struct wait_queue *wait_chldexit
在进程结束时,或发出系统调用wait4 时，为了等待子进程的结束，而将自己（父进程）睡眠在该等待队列上，设置状态标志为TASK_INTERRUPTIBLE，并且把控制权转给调度程序。
2. Struct rlimit rlim[RLIM_NLIMITS]
每一个进程可以通过系统调用setlimit 和getlimit 来限制它资源的使用。
3. Int exit_code exit_signal
程序的返回代码以及程序异常终止产生的信号，这些数据由父进程（子进程完成后）轮
流查询。
4. Char comm[16]
这个域存储进程执行的程序的名字，这个名字用在调试中。
5. Unsigned long personality
Linux 可以运行X86 平台上其他UNIX 操作系统生成的符合iBCS2 标准的程序,personality 进一步描述进程执行的程序属于何种UNIX 平台的“个性”信息。通常有PER_Linux,PER_Linux_32BIT,PER_Linux_EM86,PER_SVR4,PER_SVR3,PER_SCOSVR3,PER_WYSEV386,PER_ISCR4,PER_BSD,PER_XENIX 和PER_MASK 等，参见include／Linux/personality.h>。
6. int did_exec:1
按POSIX 要求设计的布尔量，区分进程正在执行老程序代码，还是用系统调用execve（）装入一个新的程序。
7. struct linux_binfmt *binfmt
指向进程所属的全局执行文件格式结构，共有a.out、script、elf、java 等4 种。

#### 参考
- 《深入分析Linux内核源代码》陈莉君
- [task_struct源码](http://elixir.free-electrons.com/linux/latest/source/include/linux/sched.h#L519)