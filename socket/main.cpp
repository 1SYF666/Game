#include <stdio.h>
#include <winsock2.h>
#pragma comment(lib,"ws2_32.lib")

int main()
{
	// 初始化 DLL
	WSADATA wsaData;
	WSAStartup(MAKEWORD(2, 2), &wsaData);

	// 创建套接字
	SOCKET servSock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	// 绑定套接字
	struct sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockAddr));
	sockAddr.sin_family = AF_INET;
	sockAddr.sin_addr.s_addr = inet_addr("192.168.1.102");
	sockAddr.sin_port = htons(1234);
	bind(servSock, (SOCKADDR*)&sockAddr, sizeof(SOCKADDR));

	// 进入监听状态
	listen(servSock, 20);

	// 接受客户端请求
	SOCKADDR clntAddr;
	int nSize = sizeof(SOCKADDR);
	SOCKET clntSock = accept(servSock, (SOCKADDR*)&clntAddr, &nSize);

	// 向客户端请求：
	const char* str = "hello world!";
	send(clntSock, str, strlen(str) + sizeof(char), NULL);

	// 关闭套接字
	closesocket(clntSock);
	closesocket(servSock);


	// 终止DLL的使用

	WSACleanup();

	return 0;
}






