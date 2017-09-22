---
title: c语言实现文件拷贝命令
date: 2017-09-22 17:47:04
tags: 随笔
category: c语言
---
主要知识：main函数参数、文件读写
<!--more-->
```c
#define _CRT_SECURE_NO_WARNINGS
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
int main(int argc, char* argv[])
{
    FILE *fpread = NULL;
    FILE *fpwrite = NULL;
    int ch = 0;
    if (argc != 3)
    {
        printf("请输入 cp 被拷贝的文件名 拷贝后的文件名\n");
        //getchar();
        exit(EXIT_FAILURE);
    }
    fpread = fopen(argv[1], "r");
    if (fpread == NULL)
    {
        perror("opne file error for read");
        exit(EXIT_FAILURE);
    }
    fpwrite = fopen(argv[2], "w");
    if (fpwrite == NULL)
    {
        fclose(fpread);
        perror("opne file error for write");
        exit(EXIT_FAILURE);
    }
    ch = fgetc(fpread);
    while ( ch!= EOF)
    {
        fputc(ch, fpwrite);
        ch = fgetc(fpread);
    }
    fclose(fpread);
    fclose(fpwrite);
}
````