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

	// 绑定套戒指





	return 0;
}






