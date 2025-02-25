#include <stdio.h>
#include <winsock2.h>
#include"util.h"
#pragma comment(lib,"ws2_32.lib")

int main()
{
	// 初始化 DLL
	WSADATA wsaData;
	//WSAStartup(MAKEWORD(2, 2), &wsaData);
	errif(WSAStartup(MAKEWORD(2, 2), &wsaData) != 0, "Winsock initialization failed!");

	// 创建套接字
	SOCKET servSock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	errif(servSock == INVALID_SOCKET, "Socket creation failed!");

	// 绑定套接字
	struct sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockAddr));
	sockAddr.sin_family = AF_INET;
	sockAddr.sin_addr.s_addr = inet_addr("192.168.0.148");
	sockAddr.sin_port = htons(1234);
	//bind(servSock, (SOCKADDR*)&sockAddr, sizeof(SOCKADDR));
	errif(bind(servSock, (SOCKADDR*)&sockAddr, sizeof(sockAddr)) == SOCKET_ERROR, "Socket bind failed!");
	
	printf("Server socket bind successful\n");

	// 进入监听状态
	//listen(servSock, 20);
	errif(listen(servSock, 20) == SOCKET_ERROR, "Listen failed!");

	printf("Socket starts listening...\n");
	
	// 接受客户端请求
	struct sockaddr_in clntAddr;
	int nSize = sizeof(SOCKADDR);
	SOCKET clntSock = accept(servSock, (SOCKADDR*)&clntAddr, &nSize);
	errif(clntSock == INVALID_SOCKET, "Failed to accept client connection!");

	printf("Successfully accepted client connection\n");

	char* clientIP = inet_ntoa(clntAddr.sin_addr); // 获取客户端 IP 地址
	unsigned short clientPort = ntohs(clntAddr.sin_port); // 获取客户端端口号
	printf("client IP address: %s,port: %d\n", clientIP, clientPort);

	// 向客户端请求：

	// const char* str = "hello world!";
	// int bytesSent = send(clntSock, str, strlen(str) + sizeof(char), NULL);
	// if (bytesSent == SOCKET_ERROR) {
	// 	printf("Failed to send data, error code: %d\n", WSAGetLastError());
	// }
	// else {
	// 	printf("Successfully sent  %d bytes of data to the client:%s\n", bytesSent, str);
	// }

	while (true)
	{
		char buf[1024];
		memset(buf,0x00,sizeof(buf));
		size_t read_bytes = recv(clntSock,buf,sizeof(buf),NULL);
		if (read_bytes>0)
		{
			printf("message from client fd %d: %s\n", clntSock, buf);
            send(clntSock, buf, sizeof(buf),NULL);
		}
		else if (read_bytes==0)
		{
			printf("client fd %d disconnected\n", clntSock);
            closesocket(clntSock);
            break;
		} else if(read_bytes == -1){
            closesocket(clntSock);
            errif(true, "socket read error");
        }
		
		
	}

	// 关闭套接字
	closesocket(servSock);

	// 终止DLL的使用

	WSACleanup();

	return 0;
}






