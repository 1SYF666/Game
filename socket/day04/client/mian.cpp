#include<stdio.h>
#include<stdlib.h>
#include<WinSock2.h>
#include<iostream>
#include"util.h"
#include"Socket.h"
#include"InetAddress.h"

#pragma comment(lib,"ws2_32.lib")

#define BUFFER_SIZE 1024

int main()
{
	//初始化DLL
	WSADATA wsaData;
	errif(WSAStartup(MAKEWORD(2, 2), &wsaData) != 0, "Winsock initialization failed!");

	Socket* sock_fd = new Socket();
	InetAddress* addr = new InetAddress("192.168.0.126", 1234);
	errif(connect(sock_fd->getFd(), (SOCKADDR*)&addr->addr, addr->addr_len) == SOCKET_ERROR, "Failed to connect to client!");
	printf("Server socket bind successful\n");

	int count = 0;
	while (true) {
		char buf[BUFFER_SIZE] ;
		memset(buf, 0x00,sizeof(buf));
		snprintf(buf, sizeof(buf), "%d", count++);
		int write_bytes = send(sock_fd->getFd(), buf, strlen(buf), 0);
		if (write_bytes == -1) {
			printf("socket already disconnected, can't write any more!\n");
			break;
		}
		memset(buf, 0x00, sizeof(buf));
		int read_bytes = recv(sock_fd->getFd(), buf, sizeof(buf), 0);
		if (read_bytes > 0) {
			printf("message from server: %s\n", buf);
		}
		else if (read_bytes == 0) {
			printf("server socket disconnected!\n");
			break;
		}
		else if (read_bytes == -1) {
			closesocket(sock_fd->getFd());
			errif(true, "socket read error");
		}
		Sleep(500); // 休眠 0.5 秒
	}


	// 关闭套接字
	closesocket(sock_fd->getFd());
	// 终止使用DLL
	WSACleanup();

	system("pause");

	return 0;
}

