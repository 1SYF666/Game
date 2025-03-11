#include <stdio.h>
#include <winsock2.h>
#include<iostream>
#include"util.h"
#pragma comment(lib,"ws2_32.lib")

#define MAX_EVENTS 1024
#define READ_BUFFER 1024


// 设置套接字为非阻塞模式
void setnonblocking(SOCKET sock)
{
	u_long mode = 1;  // 1表示非阻塞模式，0表示阻塞模式
	int result = ioctlsocket(sock,FIONBIO,&mode); // FIONBIO是设置非阻塞模式的控制命令
	errif(result!=0,"failed to set non-blocking mode");
}

int main()
{
	// 初始化 DLL
	WSADATA wsaData;
	errif(WSAStartup(MAKEWORD(2, 2), &wsaData) != 0, "Winsock initialization failed!");

	// 创建套接字
	SOCKET servSock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	errif(servSock == INVALID_SOCKET, "Socket creation failed!");

	// 绑定套接字
	struct sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockAddr));
	sockAddr.sin_family = AF_INET;
	sockAddr.sin_addr.s_addr = inet_addr("192.168.137.41");
	sockAddr.sin_port = htons(1234);
	errif(bind(servSock, (SOCKADDR*)&sockAddr, sizeof(sockAddr)) == SOCKET_ERROR, "Socket bind failed!");
	
	printf("Server socket bind successful\n");

	// 进入监听状态
	errif(listen(servSock, 20) == SOCKET_ERROR, "Listen failed!");

	printf("Socket starts listening...\n");

	// set the socket to non-blocking mode 
	setnonblocking(servSock);
	
	// set up the fd_set for select
	fd_set readfds;
	FD_ZERO(&readfds);
	FD_SET(servSock,&readfds);

	// set up timeout for select
	timeval timeout;
	timeout.tv_sec = 1;
	timeout.tv_usec = 0;

	while (true)
	{
		fd_set tempfds = readfds;
		// wait for events on the socket using select
		int activity = select(0, &tempfds, nullptr, nullptr, &timeout);
		errif(activity == SOCKET_ERROR,"Select call failed");

		if (activity == SOCKET_ERROR)
		{
			printf("Select call failed\n");
			break;
		}
		//std::cout<<activity<<std::endl;
		if (activity == 0)
		{
			printf("Timeout: No events occurred\n");
			continue;
		}
		
		// 监听到新的客户端连接
		if (FD_ISSET(servSock,&tempfds))
		{
			sockaddr_in clntAddr;

			int clntAddrlen = sizeof(clntAddr);
			SOCKET clntSock = accept(servSock, (SOCKADDR*)&clntAddr, &clntAddrlen);

			if (clntSock == INVALID_SOCKET)
			{
				printf("Accept failed.\n");
				continue;
			}

			char* clientIP = inet_ntoa(clntAddr.sin_addr); // 获取客户端 IP 地址
			unsigned short clientPort = ntohs(clntAddr.sin_port); // 获取客户端端口号
			printf("client IP address: %s,port: %d\n", clientIP, clientPort);

			// 设置新客户端套接字为非阻塞
			setnonblocking(clntSock);

			// 将新客户端添加到监听集合
			FD_SET(clntSock, &readfds);

		}
		
		// 处理所有可读的客户端套接字
		for (int i = 1; i < readfds.fd_count; ++i)
		{
			SOCKET clntSock =  readfds.fd_array[i];
			if (FD_ISSET(clntSock,&tempfds))
			{
				char buf[READ_BUFFER];
				memset(buf, 0x00, sizeof(buf));
				int read_bytes = recv(clntSock, buf, sizeof(buf), 0);

				if (read_bytes>0)
				{
					printf("Message from client %d : %s\n", clntSock,buf);
					send(clntSock, buf, read_bytes, 0); // 回显客户端消息
				}
				else if (read_bytes == 0)
				{
					printf("EOF,client fd %d isconnect\n", clntSock);
					closesocket(clntSock);
					FD_CLR(clntSock,&readfds);      // 从集合中移除该客户端
				}
				else if (read_bytes == -1)
				{
					// 客户端正常中断，继续读取
					printf("EOF,client fd %d isconnect\n", clntSock);
					closesocket(clntSock);
					FD_CLR(clntSock,&readfds);      // 从集合中移除该客户端
					continue;
				}
				else if (read_bytes == -1 && (errno == EINTR))
				{
					// 客户端正常中断，继续读取
					continue;
				}
				else if (read_bytes == -1 &&(errno == EAGAIN||errno == EWOULDBLOCK))
				{
					// 非阻塞I/O，表示数据已经全部读取完毕
					break;
				}
			}
		}
	}
	
	// 关闭套接字
	closesocket(servSock);

	// 终止DLL的使用
	WSACleanup();

	return 0;
}






