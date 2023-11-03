#pragma once
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define ROW	5
#define COL	5
void InitBoard(char board[ROW][COL], int row, int col);//函数声明
void DisplayBoard(char board[ROW][COL],int row,int col);
void Playmove(char board[ROW][COL], int row, int col);
void Computemove(char board[ROW][COL], int row, int col);

//判断胜负，四种状态
// 玩家赢——‘*’
// 电脑赢——‘#’
// 平局——‘Q’
// 继续——‘C’
//Iswin();
char Iswin(char board[ROW][COL], int row, int col);
