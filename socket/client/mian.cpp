#include<stdio.h>
#include<stdlib.h>
#include<WinSock2.h>
#include"util.h"
#include<iostream>
#pragma comment(lib,"ws2_32.lib")

int main()
{
	//初始化DLL
	WSADATA wsaData;
	//WSAStartup(MAKEWORD(2, 2), &wsaData);
	errif(WSAStartup(MAKEWORD(2, 2), &wsaData) != 0, "Winsock initialization failed!");

	// 创建套接字
	SOCKET sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	errif(sock == INVALID_SOCKET, "Socket creation failed!");
	
	//向服务器发起请求
	struct sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockAddr));
	
	sockAddr.sin_family = AF_INET;
	sockAddr.sin_addr.s_addr = inet_addr("192.168.0.148");
	sockAddr.sin_port = htons(1234);

	errif(connect(sock, (SOCKADDR*)&sockAddr, sizeof(SOCKADDR))== SOCKET_ERROR,"连接客户端失败！");
	
	printf("Server socket bind successful\n");
	// 接收服务器传回的数据	
	// char szBuffer[MAXBYTE] = { 0 };
	// recv(sock, szBuffer, MAXBYTE, NULL);

	// // 输出接收到的数据
	// printf("Message from server:%s\n", szBuffer);

	while(true){
        char buf[1024];
        memset(buf, 0x00,sizeof(buf));
		std::cin>>buf;
        ssize_t write_bytes = send(sock, buf, sizeof(buf),NULL);
        if(write_bytes == -1){
            printf("socket already disconnected, can't write any more!\n");
            break;
        }
        memset(buf, 0x00,sizeof(buf));
        ssize_t read_bytes = recv(sock, buf, sizeof(buf),NULL);
        if(read_bytes > 0){
            printf("message from server: %s\n", buf);
        }else if(read_bytes == 0){
            printf("server socket disconnected!\n");
            break;
        }else if(read_bytes == -1){
            closesocket(sock);
            errif(true, "socket read error");
        }
    }
	// 关闭套接字
	closesocket(sock);

	// 终止使用DLL
	WSACleanup();

	system("pause");

	return 0;
}

