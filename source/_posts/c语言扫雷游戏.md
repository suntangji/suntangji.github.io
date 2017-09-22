---
title: c语言扫雷游戏
date: 2017-09-22 17:59:06
tags: 随笔
category: c语言
---
c语言实现简易版扫雷游戏
<!--more-->
### mine.h
```c

#ifndef __MINE_H__
#define __MINE_H__

#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<string.h>

#define ROW 9 
#define COL 9
#define ROWS 7
#define COLS 7
#define MINECOUNT 8

extern char board[ROW][COL];
extern char show[ROWS][COLS];
extern int count;

void menu();
void game();
void init(char board[ROW][COL] ,char ch,int len);
void init_show(char show[ROWS][COLS], char ch, int len);
void display(char show[ROWS][COLS]);
void display_board(char board[ROW][COL]);
void set_mine(char board[ROW][COL]);
char is_mine(char board[ROW][COL],int x,int y);
void set_show(char show[ROWS][COLS],int x,int y,char ch);
int is_win(char board[ROW][COL], int x, int y);
#endif // __MINE_H__
```
### game.c
```c
#define _CRT_SECURE_NO_WARNINGS
#include "mine.h"
int count = 0;
void menu()
{
	printf("******************      1.play      *********************\n");
	printf("******************      0.exit      *********************\n");
	printf("请选择：\n");
}

void init(char board[ROW][COL],char ch,int len)
{
	memset(board, ch, len);
}
void init_show(char show[ROWS][COLS], char ch, int len)
{
	memset(show, ch, len);
}

void display(char show[ROWS][COLS])
{
	for (int i = 0; i < ROWS; i++)
	{
		for (int j = 0; j < COLS; j++)
		{
			printf(" %c", show[i][j]);
		}
		printf("\n");
	}
}
void display_board(char board[ROW][COL])
{
	for (int i = 0; i < ROW; i++)
	{
		for (int j = 0; j < COL; j++)
		{
			printf(" %c", board[i][j]);
		}
		printf("\n");
	}
}

void set_mine(char board[ROW][COL])
{
	
    int x = 0;
	int y = 0;
	int i = 0;
	for (i = 0; i < MINECOUNT; i++)
	{
		do
		{
			x = (rand() % ROWS)+1 ;
			y = (rand() % COLS)+1 ;

		} while (board[x][y] != '0');
		board[x][y] = '1';
	}	
}

char is_mine(char board[ROW][COL],int x,int y)
{
	

	if (board[x][y] == '1')
	{
		return 'y';
	}
	else
	{
	return  board[x - 1][y - 1] +
			board[x - 1][y] +
			board[x - 1][y + 1] +
			board[x][y - 1] +
			board[x][y + 1] +
			board[x + 1][y - 1] +
			board[x + 1][y] +
			board[x + 1][y + 1] - 7 * '0';

	}
}

void set_show(char show[ROWS][COLS],int x,int y,char ch)
{
	show[x-1][y-1] = ch;
}
int is_win(char board[ROW][COL],int x,int y)
{
    count--;
	if (count == 0)
		return 1;
	else 
		return 0;
	
}
void game()
{
	srand((unsigned int)time(NULL));
	char board[ROW][COL] = { 0 };
	char show[ROWS][COLS] = { 0 };
	int len_board = sizeof(board) / sizeof(board[0][0]);
	int len_show = sizeof(show) / sizeof(show[0][0]);
	int x = 0;
	int y = 0;
	init(board,'0',len_board);
	init_show(show, '*', len_show);
	set_mine(board);
	
	do
	{
		system("cls");
		display(show);
		display_board(board);
		printf("请输入你要选择的坐标\n");
		scanf("%d%d", &x, &y);
		if ((x<=0) || (x>ROWS) || (y<=0) || (y>COLS))
			printf("坐标无效，请重新输入\n");
		else
		{
			char ch = is_mine(board, x, y);
			if (ch == 'y')
			{
				printf("你踩雷了\n");
				break;
			}
			else
			{
				set_show(show, x, y, ch);
				if (is_win(board, x, y) == 1)
				{
					printf("you win \n");
					break;
				}
			}
				
			//break;
		}
	} while (1);



	//display(show);
//	display(board);
	

	//printf("game");
}
```
### main.c
```c
#define _CRT_SECURE_NO_WARNINGS
#include "mine.h"
int main()
{
	int input = 0;
	
	do
	{
		count = ROW * COL - MINECOUNT;
		menu();
		scanf("%d", &input);
		switch (input)
		{
		case 0:
			break;
		case 1:
			game();
			break;
		default:
			printf("无效操作\n");
			break;
		}
	} while (input);

	system("pause");
	return 0;
}
```