---
title: 通讯录c语言实现
date: 2017-09-22 16:48:39
tags: 项目
category: c语言
---
数据结构顺序表，动态内存开辟，文件读写
<!--more-->
### contact.h
```c
#ifndef __CONTACT_H_
#define __CONTACT_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#define ADD 2 //每次增加的容量

typedef struct peoinfo
{
	char name[20];
	int age;
	char sex[5];
	char tele[12];
	char addr[30];
}peoinfo;

typedef struct contact
{
	//peoinfo data[MAX];
	peoinfo *data;
	int sz; //当前人数
	int cap; //当前容量
}contact, *pContact;
contact con;
void init(pContact pCon); //初始化函数
void add_cap(pContact pCon); //增加容量
void menu();
void add(pContact pCon); //增加联系人
void search(pContact pCon); //搜索联系人
void rm(pContact pCon); //删除联系人
void rewrite(pContact pCon); //修改联系人
void print(pContact pCon); //打印联系人
void DestroyContact(pContact pCon); //回收动态内存
void loadfile(pContact pCon); //载入文件中的联系人
void savefile(pContact pCon); //把联系人保存到文件中
#endif //__CONTACT_H_
```
### contact.c
```c
#define _CRT_SECURE_NO_WARNINGS
#include"contact.h"
char name[20];
int age;
char sex[5];
char tele[12];
char addr[30];
void init(pContact pCon)
{
	pCon->sz = 0;
	pCon->data = calloc(ADD,sizeof(peoinfo));
	if (pCon->data == NULL) //判断内存是否开辟成功
	{
		perror("use calloc");
		exit(EXIT_FAILURE);
	}
	pCon->cap = ADD;
	loadfile(pCon);
}
void add_cap(pContact pCon)
{
	if (pCon->sz == pCon->cap) //增容
	{
		peoinfo* ptr = realloc(pCon->data, (pCon->cap + ADD)*sizeof(peoinfo)); 
		if (ptr == NULL)//判断增容是否成功
		{
			perror("realloc");
			exit(EXIT_FAILURE);
		}
		else
		{
			pCon->data = ptr;
			ptr = NULL;
			pCon->cap += ADD;
		}
	}
	
}
void add(pContact pCon)
{
	//pCon->data[(pCon->sz)++] ;
	assert(pCon->data);
	add_cap(pCon);//增容
	printf("请输入姓名：\n");
	scanf("%s", name);
	printf("请输入年龄：\n");
	scanf("%d", &age);
	printf("请输入性别：\n");
	scanf("%s", sex);
	printf("请输入电话号码：\n");
	scanf("%s", tele);
	printf("请输入地址:\n");
	scanf("%s", addr);
	strcpy(pCon->data[(pCon->sz)].name,name);
	pCon->data[(pCon->sz)].age =  age;
	strcpy(pCon->data[(pCon->sz)].sex, sex);
	strcpy(pCon->data[(pCon->sz)].tele, tele);
	strcpy(pCon->data[(pCon->sz)].addr, addr);
	//printf("test add\n");
	pCon->sz++;
}
void rm(pContact pCon)
{
	int i = 0;
	printf("请输入要删除的姓名:\n");
	scanf("%s", name);
	for (i = 0; i < pCon->sz; i++)
	{
		if (strcmp(pCon->data[i].name, name) == 0)
		{
			int j = 0;
			for (j = i; j < pCon->sz; j++)
				pCon->data[i] = pCon->data[i + 1];
			pCon->sz--;
			printf("删除成功\n");
			return;
		}
	}
	printf("查无此人\n");
	//printf("test rm\n");
}
void search(pContact pCon)
{
	int i = 0;
	printf("请输入要查找的姓名:\n");
	scanf("%s", name);
	for (i = 0; i < pCon->sz; i++)
	{
		if (strcmp(pCon->data[i].name, name) == 0)
		{
			printf("姓名：%s\n", pCon->data[i].name);
			printf("年龄：%d\n", pCon->data[i].age);
			printf("性别：%s\n", pCon->data[i].sex);
			printf("电话：%s\n", pCon->data[i].tele);
			printf("地址：%s\n", pCon->data[i].addr);
			return;
		}
	}
	printf("查无此人\n");
}
void rewrite(pContact pCon)
{
	//pCon->sz--;
	printf("请输入要修改的姓名:\n");
	scanf("%s", name);
	//char* n = &name;
	int i = 0;
	for (i = 0; i < pCon->sz; i++)
	{
		if (strcmp(pCon->data[i].name, name) == 0)
		{
			printf("请输入修改后的姓名:\n");
			scanf("%s", name);
			printf("请输入年龄：\n");
			scanf("%d", &age);
			printf("请输入性别：\n");
			scanf("%s", sex);
			printf("请输入电话号码：\n");
			scanf("%s", tele);
			printf("请输入地址:\n");
			scanf("%s", addr);
			strcpy(pCon->data[i].name, name);
			pCon->data[i].age = age;
			strcpy(pCon->data[i].sex, sex);
			strcpy(pCon->data[i].tele, tele);
			strcpy(pCon->data[i].addr, addr);
			return;
		}
	
	}
	
	printf("查无此人\n");
	//printf("test rewrite\n");
}
void print(pContact pCon)
{
	int i = 0;
	for (i = 0; i < pCon->sz; i++)
	{
		printf("姓名：%s\n", pCon->data[i].name);
		printf("年龄：%d\n", pCon->data[i].age);
		printf("性别：%s\n", pCon->data[i].sex);
		printf("电话：%s\n", pCon->data[i].tele);
		printf("地址：%s\n", pCon->data[i].addr);
		printf("-----------\n");
	}
}
void DestroyContact(pContact pCon)//回收动态开辟的空间
{
	free(pCon->data);
	pCon->data = NULL;
	pCon->sz = 0;
	pCon->cap = 0;
}
void savefile(pContact pCon)
{
	FILE * fpsave = NULL;
	fpsave = fopen("contact.txt", "w+");
	if (fpsave == NULL)
	{
		perror("open file error for save");
		exit(EXIT_FAILURE);
	}
	int i = 0;
	for (i = 0; i < pCon->sz; i++)
	{
		fprintf(fpsave,"姓名：%s\n", pCon->data[i].name);
		fprintf(fpsave, "年龄：%d\n", pCon->data[i].age);
		fprintf(fpsave, "性别：%s\n", pCon->data[i].sex);
		fprintf(fpsave, "电话：%s\n", pCon->data[i].tele);
		fprintf(fpsave, "地址：%s\n", pCon->data[i].addr);
		//fprintf(fpsave, "-----------\n");
	}
	fclose(fpsave);
}
void loadfile(pContact pCon)
{
	FILE * fpload = NULL;
	unsigned int count = 0;
	fpload = fopen("contact.txt", "r");
	if (fpload == NULL)
	{
		//perror("open file error for load");
		//exit(EXIT_FAILURE);
		return;
	}
	int i = 0;
	while (feof(fpload) == 0)
	{
		add_cap(pCon);
		fscanf(fpload, "姓名：%s\n", &pCon->data[i].name);
		fscanf(fpload, "年龄：%d\n", &pCon->data[i].age);
		fscanf(fpload, "性别：%s\n", &pCon->data[i].sex);
		fscanf(fpload, "电话：%s\n", &pCon->data[i].tele);
		fscanf(fpload, "地址：%s\n", &pCon->data[i].addr);
		i++;
		pCon->sz++;
	}
	fclose(fpload);
}
```
### main.c
```c
#define _CRT_SECURE_NO_WARNINGS
#include "contact.h"

int main()
{
	int n = 0;
	init(&con);
	do
	{
		
		menu();
		scanf("%d", &n);
		switch (n)
		{
		case 0:
			break;
		case 1:
			add(&con);
			break;
		case 2:
			rm(&con);
			break;
		case 3:
			search(&con);
			break;
		case 4:
			rewrite(&con);
			break;
		case 5:
			print(&con);
			break;
		default:
			printf("无效选项");
				break;
		}
	} while (n);
	savefile(&con);
	DestroyContact(&con);
	system("pause");
	return 0;
}
```
### menu.c
```c
#define _CRT_SECURE_NO_WARNINGS
#include "contact.h"
void menu()
{
	printf("******************  1.add     ***********************\n");
	printf("******************  2.remove  ***********************\n");
	printf("******************  3.search  ***********************\n");
	printf("******************  4.rewrite ***********************\n");
	printf("******************  5.print   ***********************\n");
	printf("******************  0.exit    ***********************\n");
	printf("请选择：\n");
}
```