#define _CRT_SECURE_NO_WARNINGS 1
#include "game.h"

//函数实现
void InitBoard(char board[ROW][COL], int row, int col) //此处传入数组不是很理解
{
	int i = 0;
	int j = 0;
	for (i = 0; i < row; i++)
	{
		for (j = 0; j < col; j++)
		{
			//初始化赋值为空格
			board[i][j] = ' ';
		}
	}

}

//void DisplayBoard(char board[ROW][COL], int row, int col)
//{
//	int i = 0;
//	//printf("---|---|---|\n");
//	for (i = 0; i < row; i++)
//	{
//		//打印数据
//		printf(" %c | %c | %c \n",board[i][0], board[i][1], board[i][2]);
//		//打印分割行
//		if (i < row-1)
//		{
//			printf("---|---|---\n");
//		}
//	}
//}
//优化程序
void DisplayBoard(char board[ROW][COL], int row, int col)
{
	int i = 0;
	int j = 0;

	for (i = 0; i < row; i++)
	{
		//打印数据
		for (j = 0; j < col; j++)
		{
			if (j < col - 1)
				printf(" %c |", board[i][j]);
			else
				printf(" %c \n", board[i][j]);
		}
		//打印分割线
		if (i < row - 1)
		{
			for (j = 0; j < col; j++)
			{
				if (j < col - 1)
					printf("---|");
				else
					printf("---\n");
			}
		}

	}
}

//玩家下用“*”做棋子
void Playmove(char board[ROW][COL], int row, int col)
{
	int x = 0;
	int y = 0;
	while (1)
	{
		printf("'*'玩家请输入（row col）：>");
		scanf("%d %d", &x,&y);
		if (x >= 1 && x <= row && y >= 1 && y <= col)
		{
			if (board[x - 1][y - 1] != ' ')
			{
				printf("该处已存在棋子,重新输入\n");
			}
			else
			{
				board[x - 1][y - 1] = '*';
				break;
			}
		}
		else
		{
			printf("输入非法，请重新输入\n");
		}

	}
}

//电脑随机下，用棋子“#”
void Computemove(char board[ROW][COL], int row, int col)
{
	int x = 0;
	int y = 0;
	printf("电脑随机下：>\n");
	while (1)
	{
		x = rand() % row;
		y = rand() % col;
		if (board[x][y] == ' ')
		{
			board[x][y] = '#';
			break;
		}

	}

}

char Iswin(char board[ROW][COL], int row, int col)
{
	int i = 0;
	int j = 0;
	int n = 0;

	//行
	for (i = 0; i < row; i++)
	{
		for (j = 0; j < col-1; j++)
		{
			if (board[i][j] == board[i][j+1]) 
				n++;
		}
		if (n == col - 1)
		{
			return board[i][j];
		}
		n = 0;
	}
    
	//列
	for (i = 0; i < col; i++)
	{
		for (j = 0; j < row - 1; j++)
		{
			if (board[j][i] == board[j+1][i])
				n++;
		}
		if (n == row - 1)
		{
			return board[i][j];
		}
		n = 0;
	}

	//主对角线
	for (j = 0; j < col-1 ; j++)
	{
		if (board[j][j] == board[j+1][j + 1])
			n++;
	}
	if (n == col - 1)
	{
		return board[0][0];
	}
	n = 0;
	
	//副对角线
	for (j = 0; j < col - 1; j++)
	{
		if (board[col-1-j][j] == board[col-2-j][j + 1])
			n++;
	}
	if (n == col - 1)
	{
		return board[0][col-1];
	}
	n = 0;

	//继续或平局
	
	for (i = 0; i < row; i++)
	{
		for (j = 0; j < col; j++)
		{
			if (board[i][j] ==' ')
				n++;
		}

	}
	if (n)
		return 'C';//继续游戏
	else
		return 'Q';//平局
}
