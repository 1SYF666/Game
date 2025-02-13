#include<stdio.h>
#include<stdlib.h>
#include<WinSock2.h>

#pragma comment(lib,"ws2_32.lib")

int main()
{
	//初始化DLL
	WSADATA wsaData;
	WSAStartup(MAKEWORD(2, 2), &wsaData);

	// 创建套接字
	SOCKET sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	//向服务器发起请求
	struct sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockAddr));
	
	sockAddr.sin_family = AF_INET;
	sockAddr.sin_addr.s_addr = inet_addr("192.168.1.102");
	sockAddr.sin_port = htons(1234);

	connect(sock, (SOCKADDR*)&sockAddr, sizeof(SOCKADDR));

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
