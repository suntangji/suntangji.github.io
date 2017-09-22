---
title: 把c语言注释转换为cpp注释
date: 2017-09-22 17:15:48
tags: 项目
category: c语言
---
 主要知识点：有限状态机、文件读写
 <!--more-->
### comment.h
```c
#ifndef _COMMENT_H__
#define _COMMENT_H__
 
#include <stdio.h>
#include<stdlib.h>

enum Status
{
	NONE_STATUS,  //无状态
	C_STATUS,     //c状态
	CPP_STATUS,   //cpp状态
	END_STATUS    //结束状态
};

void doCppStatus(FILE* fpr, FILE* fpw, enum Status *status);//进入c注释状态
void doCStatus(FILE* fpr, FILE* fpw, enum Status *status);//进入cpp注释状态
void doNoneStatus(FILE* fpr, FILE* fpw, enum Status *status); //进入无状态
void doEndStatus(FILE* fpr, FILE* fpw, enum Status *status);//进入结束状态
void commentConvert();
#endif //_COMMENT_H__
```
### comment.c
```c
#define _CRT_SECURE_NO_WARNINGS 
#include"comment.h"

void commentConvert()
{
	FILE* fpread = NULL;
	FILE* fpwrite = NULL;
	int first = 0;
	int second = 0;
	enum Status status;

	fpread = fopen("input.c", "r");
	if (fpread ==NULL)
	{
		perror("open file error for read");
		getchar();
		exit(EXIT_FAILURE);
	}
	fpwrite = fopen("output.c", "w");
	if (fpwrite==NULL)
	{
		fclose(fpread);
		perror("opne file error for write");
		getchar();
		exit(EXIT_FAILURE);
	}
	first = fgetc(fpread);
	if(first != EOF)
	{
		switch (first)
		{
		case '/':
			second = fgetc(fpread);
			switch (second)
			{
			case '/':
				fputc(first, fpwrite);
				fputc(second, fpwrite);
				status = CPP_STATUS;
				doCppStatus(fpread,fpwrite,&status);
				break;
			case '*':
				fputc(first, fpwrite);
				fputc(first, fpwrite);
				status = C_STATUS;
				doCStatus(fpread, fpwrite, &status);
				break;
			default:
				fputc(first, fpwrite);
				fputc(second, fpwrite);
				doNoneStatus(fpread, fpwrite, &status);
				break;
			}
			break;
		default:
			fputc(first, fpwrite);
			doNoneStatus(fpread, fpwrite, &status);
			break;
		}
		//printf("%c", first);
		//fputc(first, fpwrite);
		//first = fgetc(fpread);

	}
	doEndStatus(fpread, fpwrite, &status);
}

```
### convert.c
```c
#define _CRT_SECURE_NO_WARNINGS 
#include"comment.h"

void doCppStatus(FILE* fpr, FILE* fpw, enum Status *status)
{
	int first = 0;
	int second = 0;
	first = fgetc(fpr);
	while (first != EOF)
	{
		if (first == '\n')
		{
			fputc(first, fpw);
			*status = NONE_STATUS;
			doNoneStatus(fpr, fpw, status);
		}
		fputc(first, fpw);
		first = fgetc(fpr);
	}
	if(first == EOF)
		doEndStatus(fpr, fpw, status);
}

void doCStatus(FILE* fpr, FILE* fpw, enum Status *status)
{
	int first = 0;
	int second = 0;
	int third = 0;
	first = fgetc(fpr);
	while(first != EOF)
	{
		switch (first)
		{
		case '*':
			second = fgetc(fpr);
			switch (second)
			{
			case '/':
				*status = NONE_STATUS;
				third = fgetc(fpr);
				while ((third != '\n')||(third ==EOF))
				{
					if (third == ' ')
					{
						fputc(third, fpw);
					}
					else
					{
						fputc('\n', fpw);
						break;
					}
				}
				
						
				ungetc(third, fpr);
				doNoneStatus(fpr, fpw, status);
				break;
			default:
				fputc(first, fpw);
				ungetc(second,fpr);
				break;
			}
			break;
		case '\n':
			fputc(first, fpw);
			fputc('/', fpw);
			fputc('/', fpw);
			break;
		default:
			fputc(first, fpw);
			break;
		}
		first = fgetc(fpr);
	}
}
void doNoneStatus(FILE* fpr, FILE* fpw, enum Status *status)
{
	int first = 0;
	int second = 0;
	first = fgetc(fpr);
	while (first != EOF)
	{
		switch (first)
		{
		case '/':
			second = fgetc(fpr);
			switch (second)
			{
			case'/':
				fputc(first, fpw);
				fputc(second, fpw);
				*status = CPP_STATUS;
				doCppStatus(fpr, fpw, status);
				break;
			case '*':
				fputc(first, fpw);
				fputc(first, fpw);
				*status = C_STATUS;
				doCStatus(fpr, fpw, status);
				break;
			case EOF:
				fputc(first, fpw);
				*status = END_STATUS;
				doEndStatus(fpr, fpw, status);
				break;
			default:
				fputc(first, fpw);
				fputc(second, fpw);
				break;
			}

			break;
		default:
			fputc(first, fpw);
			break;
		}
		first = fgetc(fpr);
	}
	//fputc(first, fpw);
	doEndStatus(fpr, fpw, status);

}
void doEndStatus(FILE* fpr, FILE* fpw, enum Status *status)
{
	fclose(fpr);
	fclose(fpw);
	exit(EXIT_SUCCESS);
}
```
### test.c
```c 
#define _CRT_SECURE_NO_WARNINGS 
#include"comment.h"

void test()
{
	commentConvert();
}
int main()
{
	test();
	//getchar();
	system("pause");
	return 0;
}
```