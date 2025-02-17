#include<stdio.h>
#include<stdlib.h>
#include<WinSock2.h>
#include"util.h"
#pragma comment(lib,"ws2_32.lib")

int main()
{
	//初始化DLL
	WSADATA wsaData;
	//WSAStartup(MAKEWORD(2, 2), &wsaData);
	errif(WSAStartup(MAKEWORD(2, 2), &wsaData) != 0, "Winsock 初始化失败!");

	// 创建套接字
	SOCKET sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	errif(sock == INVALID_SOCKET, "套接字创建失败!");
	
	//向服务器发起请求
	struct sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockAddr));
	
	sockAddr.sin_family = AF_INET;
	sockAddr.sin_addr.s_addr = inet_addr("192.168.1.101");
	sockAddr.sin_port = htons(1234);

	errif(connect(sock, (SOCKADDR*)&sockAddr, sizeof(SOCKADDR))== SOCKET_ERROR,"连接客户端失败！");
	
	printf("客户端连接服务器成功\n");
	// 接收服务器传回的数据
	char szBuffer[MAXBYTE] = { 0 };
	recv(sock, szBuffer, MAXBYTE, NULL);

	// 输出接收到的数据
	printf("Message from server:%s\n", szBuffer);

	// 关闭套接字
	closesocket(sock);

	// 终止使用DLL
	WSACleanup();

	system("pause");

	return 0;
}

