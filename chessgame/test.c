#define _CRT_SECURE_NO_WARNINGS 1
			//官方头文件用<>;自己写的用“”
#include "game.h"				//下面ROW,COL在.h文件中定义的，故需要调用.h文件

//测试三子棋游戏
void menu()
{
	printf("####################画直线游戏####################\n");
	printf("###############1.play       0.exit################\n");
	printf("####################画直线棋游戏####################\n");
}

void game()
{
	//把棋盘信息存放在一个数组中,一开始是都是空（可认为是“空格”）
	//下棋存放的是棋子可认为是“*”
	char board[ROW][COL] = { 0 };
	char ret = 0;
	//初始化棋盘
	InitBoard(board,ROW,COL);//把数组传过去，需要传行与列

	//打印棋盘
	DisplayBoard(board,ROW,COL);
	
	//开始下棋
	while (1)
	{
		//玩家下
		Playmove(board, ROW, COL);
		DisplayBoard(board, ROW, COL);
		
		//判断胜负
		ret=Iswin(board, ROW, COL);
		if (ret == '*')
		{
			printf("玩家赢\n");
			break;
		}
		
		if (ret == '#')
		{
			printf("电脑赢\n");
			break;
		}

		if (ret == 'Q')
		{
			printf("平局\n");
			break;
		}
		
		if (ret == 'C')
		{
			//printf("请继续游戏\n");
		}
		
		//电脑下
		Computemove(board, ROW, COL);
		DisplayBoard(board, ROW, COL);

		//判断胜负
		ret=Iswin(board, ROW, COL);

		if (ret == '*')
		{
			printf("玩家赢\n");
			break;
		}

		if (ret == '#')
		{
			printf("电脑赢\n");
			break;
		}

		if (ret == 'Q')
		{
			printf("平局\n");
			break;
		}

		if (ret == 'C')
		{
			//printf("请继续游戏\n");
		}
	}
}

void test()
{
	int input = 0;
	do 
	{
		menu();
		printf("请输入：>");
		scanf("%d", &input);
		switch (input)
		{
		case 1:
			//printf("开始游戏\n");
			game();
			break;
		case 0:
			printf("退出游戏\n");
			break;
		default:
			printf("输入有误，请重新输入\n");
			break;
		}

	} while (input);
}
int main()
{
	srand((unsigned int)time(NULL));
	test();

	return 0;
}



