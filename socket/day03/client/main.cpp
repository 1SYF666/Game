#include<stdio.h>
#include<stdlib.h>
#include<WinSock2.h>
#include"util.h"
#include<iostream>
#pragma comment(lib,"ws2_32.lib")

#define BUFFER_SIZE 1024
int main()
{
	//初始化DLL
	WSADATA wsaData;
	errif(WSAStartup(MAKEWORD(2, 2), &wsaData) != 0, "Winsock initialization failed!");

	// 创建套接字
	SOCKET sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	errif(sock == INVALID_SOCKET, "Socket creation failed!");
	
	//向服务器发起请求
	struct sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockAddr));
	
	sockAddr.sin_family = AF_INET;
	sockAddr.sin_addr.s_addr = inet_addr("192.168.137.41");
	sockAddr.sin_port = htons(1234);
	errif(connect(sock, (SOCKADDR*)&sockAddr, sizeof(SOCKADDR))== SOCKET_ERROR,"Failed to connect to client!");
	printf("Server socket bind successful\n");
	int count = 0;
	while (true) {
		char buf[BUFFER_SIZE] ;
		memset(buf, 0x00,sizeof(buf));
		snprintf(buf, sizeof(buf), "%d", count++);
		int write_bytes = send(sock, buf, strlen(buf), 0);
		if (write_bytes == -1) {
			printf("socket already disconnected, can't write any more!\n");
			break;
		}
		memset(buf, 0x00, sizeof(buf));
		int read_bytes = recv(sock, buf, sizeof(buf), 0);
		if (read_bytes > 0) {
			printf("message from server: %s\n", buf);
		}
		else if (read_bytes == 0) {
			printf("server socket disconnected!\n");
			break;
		}
		else if (read_bytes == -1) {
			closesocket(sock);
			errif(true, "socket read error");
		}
		Sleep(500); // 休眠 0.5 秒
	}


	// 关闭套接字
	closesocket(sock);
	// 终止使用DLL
	WSACleanup();

	system("pause");

	return 0;
}

