#include <stdio.h>
#include <winsock2.h>
#include"util.h"
#pragma comment(lib,"ws2_32.lib")

int main()
{
	// 初始化 DLL
	WSADATA wsaData;
	//WSAStartup(MAKEWORD(2, 2), &wsaData);
	errif(WSAStartup(MAKEWORD(2, 2), &wsaData) != 0, "Winsock 初始化失败!");

	// 创建套接字
	SOCKET servSock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	errif(servSock == INVALID_SOCKET, "套接字创建失败!");

	// 绑定套接字
	struct sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockAddr));
	sockAddr.sin_family = AF_INET;
	sockAddr.sin_addr.s_addr = inet_addr("192.168.1.102");
	sockAddr.sin_port = htons(1234);
	//bind(servSock, (SOCKADDR*)&sockAddr, sizeof(SOCKADDR));
	errif(bind(servSock, (SOCKADDR*)&sockAddr, sizeof(sockAddr)) == SOCKET_ERROR, "套接字绑定失败!");
	
	printf("服务器绑定套接字成功\n");

	// 进入监听状态
	//listen(servSock, 20);
	errif(listen(servSock, 20) == SOCKET_ERROR, "监听失败!");

	printf("套接字开始监听...\n");
	
	// 接受客户端请求
	struct sockaddr_in clntAddr;
	int nSize = sizeof(SOCKADDR);
	SOCKET clntSock = accept(servSock, (SOCKADDR*)&clntAddr, &nSize);
	errif(clntSock == INVALID_SOCKET, "接受客户端连接失败!");

	printf("接受客户端连接成功！\n");

	char* clientIP = inet_ntoa(clntAddr.sin_addr); // 获取客户端 IP 地址
	unsigned short clientPort = ntohs(clntAddr.sin_port); // 获取客户端端口号
	printf("客户端 IP 地址: %s,客户端端口号: %d\n", clientIP, clientPort);

	// 向客户端请求：
	const char* str = "hello world!";
	int bytesSent = send(clntSock, str, strlen(str) + sizeof(char), NULL);

	if (bytesSent == SOCKET_ERROR) {
		printf("发送数据失败，错误代码：%d\n", WSAGetLastError());
	}
	else {
		printf("成功发送 %d 字节的数据给客户端：%s\n", bytesSent, str);
	}





	// 关闭套接字
	closesocket(clntSock);
	closesocket(servSock);


	// 终止DLL的使用

	WSACleanup();

	return 0;
}






