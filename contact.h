#pragma once
#define MAX 1000
#define NAME 20
#define SEX 5
#define TELE 12
#define ADDR 30

#include <string.h>
#include <stdio.h>

struct PeoInfo
{
	char name[NAME];
	char sex[SEX];
	char tele[TELE];
	char addr[ADDR];
	int age;
};

//通讯录信息
struct Contact
{
	//结构体嵌套
	struct PeoInfo data[MAX];		//存放一个信息
	int size;						//记录当前已经有的元素个数
};


//函数声明
void InitContact(struct Contact* ps);
void AddContact(struct Contact* ps);
void ShowContact(struct Contact* ps);





