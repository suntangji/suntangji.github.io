---
title: c语言实现动态顺序表
date: 2017-09-22 17:54:36
tags: 随笔
category: c语言
---
c语言实现动态内存开辟的顺序表
<!--more-->
### seqlist.h
```c
#ifndef __SEQLIST_H__ 
#define __SEQLIST_H__ 

#include <stdio.h>
#include <stdlib.h>
//#include 
//#include 

#define DEFAULT_SZ 3 
#define DEFAULT_INC 2 

typedef int DataType;
typedef struct SeqList
{
	DataType *data;//数据区 
	int sz;//有效个数 
	int capacity;//容量 
}SeqList, *pSeqList;

//静态顺序表 
//typedef struct SeqList 
//{ 
//	DataType data[MAX]; 
//	int sz;  
//}SeqList, *pSeqList; 

void InitSeqList(pSeqList ps);
void Addcapacity(pSeqList ps);
void DestroySeqList(pSeqList ps);
void PushBack(pSeqList ps, DataType d);
void PrintSeqList(const pSeqList ps);
void PopBack(pSeqList ps);
void PushFront(pSeqList ps, DataType d);
void PopFront(pSeqList ps);
void Insert(pSeqList ps, int pos, DataType d);
void Sort(pSeqList ps);
int BinarySearch(pSeqList ps, DataType d);
int Find(pSeqList ps, DataType d);
void Remove(pSeqList ps, DataType d);
void RemoveAll(pSeqList ps,DataType d); 
#endif //__SEQLIST_H__ 
```
### seqlist.c
```c
#define _CRT_SECURE_NO_WARNINGS
#include "seqlist.h"

void InitSeqList(pSeqList ps)
{
	ps->sz = 0;
	DataType* ptmp = NULL;
	ptmp= (DataType *)malloc(2 * sizeof(ps->data));
	if (ptmp == NULL)
	{
		perror("malloc error:");
		exit(EXIT_FAILURE);
	}
	ps->data = ptmp;
	//memset(ps->data, 0,sizeof(ps->data));
	ps->capacity = DEFAULT_INC;
}
void Addcapacity(pSeqList ps)
{
	if (ps->sz == ps->capacity)
	{
		DataType* ptmp = (DataType *)realloc(ps->data, (ps->capacity + DEFAULT_INC)*sizeof(ps->data));
		if (ptmp == NULL)
		{
			perror("realloc error:");
			exit(EXIT_FAILURE);
		}
		ps->data = ptmp;
		ps->capacity += DEFAULT_INC;
	}
}
void PushBack(pSeqList ps, DataType d)
{
	Addcapacity(ps);
	ps->data[ps->sz] = d;
	ps->sz++;
}
void PrintSeqList(const pSeqList ps)
{
	int i = 0;
	for (i = 0; i < ps->sz; i++)
	{
		printf("%d", ps->data[i]);
	}
	printf("\n");
}
void PopBack(pSeqList ps)
{
	if (ps->sz == 0)
		return;
	ps->sz--;
}
void PushFront(pSeqList ps, DataType d)
{
	Addcapacity(ps);
	int i = 0;
	for (i = ps->sz-1; i>=0; i--)
	{
		ps->data[i+1] = ps->data[i];
	}
	ps->data[0] = d;
	ps->sz++;
}
void PopFront(pSeqList ps)
{
	if (ps->sz == 0)
		return;
	int i = 0;
	for (i = 0; i < ps->sz-1; i++)
	{
		ps->data[i] = ps->data[i + 1];
	}
	ps->sz--;
}
int Find(pSeqList ps, DataType d)
{
	int i = 0;
	for (i = 0; i < ps->sz; i++)
	{
		if (d == ps->data[i])
			return i;
	}
	return -1;
}
void Insert(pSeqList ps, int pos, DataType d)
{
	if (pos > ps ->sz || pos < 0)
		return;
	Addcapacity(ps);
	int i = 0;
	for (i = ps->sz-1; i >= pos; i--)
	{
		ps->data[i+1] = ps->data[i];
	}
	ps->data[pos] = d;
	ps->sz++;
}
void Remove(pSeqList ps, DataType d)
{
	int ret = Find(ps, d);
	int i = 0;
	if (ret == -1)
		return;
	for (i = ret; i < ps->sz-1; i++)
		ps->data[i] = ps->data[i + 1];
	ps->sz--;
}
void RemoveAll(pSeqList ps, DataType d)
{
	int ret = 0;
	while ((ret = Find(ps, d)) != -1)
	{
		Remove(ps, d);
	}
}
void Sort(pSeqList ps)
{
	int i = 0, j = 0;
	for (i = 0; i < ps->sz-1; i++)
		for (j = 0; j < ps->sz -1- i; j++)
		{
			int tmp = 0;
			if (ps->data[i]>ps->data[i + 1])
			{
				tmp = ps->data[i];
				ps->data[i] = ps->data[i + 1];
				ps->data[i + 1] = tmp;
			}
		}
}
int BinarySearch(pSeqList ps, DataType d)
{
	int left = 0;
	int right = ps->sz - 1;
	int mid = 0;
	while (left <= right)
	{
		mid = left + ((right - left) >> 1);
		if (d == ps->data[mid])
			return mid;
		else if (d > ps->data[mid])
		{
			left = mid + 1;
		}
		else
			right = mid - 1;
	}
	return -1;
}
```
### test.c
```c
#define _CRT_SECURE_NO_WARNINGS
#include "seqlist.h"

int main()
{
	SeqList ps;
	InitSeqList(&ps);
	PushBack(&ps, 1);
	PushBack(&ps, 2);
	PushBack(&ps, 3);
	//PopBack(&ps);
	PrintSeqList(&ps);
	//PushFront(&ps, 2);
	//PrintSeqList(&ps);
	//PopFront(&ps);
	//PrintSeqList(&ps);
	//int ret = Find(&ps, 5);
	//printf("%d\n", ret);
	Insert(&ps, 2, 4);
	PrintSeqList(&ps);
	//Remove(&ps, 2);
	//PrintSeqList(&ps);

	//RemoveAll(&ps, 2);

	//PrintSeqList(&ps);
	Sort(&ps);
	PrintSeqList(&ps);
	int ret = BinarySearch(&ps, 2);
	printf("%d", ret);
	system("pause");
	return 0;
}
```