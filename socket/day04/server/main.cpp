#include <stdio.h>
#include <winsock2.h>
#include<iostream>
#include"util.h"
#include"Socket.h"
#include"InetAddress.h"
#include"Select.h"
#pragma comment(lib,"ws2_32.lib")

#define MAX_EVENTS 1024
#define READ_BUFFER 1024


//void handleReadEvent(int);

int main()
{
	// 初始化 DLL
	WSADATA wsaData;
	errif(WSAStartup(MAKEWORD(2, 2), &wsaData) != 0, "Winsock initialization failed!");

	Socket* serv_sock = new Socket();
	InetAddress* serv_addr = new InetAddress("192.168.0.126", 1234);
	serv_sock->bind(serv_addr);
	printf("Server socket bind successful\n");
	
	serv_sock->listen();
	printf("Socket starts listening...\n");

	serv_sock->setnonblocking();
	
	Select* ep = new Select();
	ep->add(serv_sock->getFd());

	while (true)
	{
		int activity = ep->wait();

		if (activity == 0)
		{
			printf("Timeout: No events occurred\n");
			continue;
		}

		if (ep->isset(serv_sock->getFd()))
		{
			InetAddress* clnt_addr = new InetAddress();
			Socket* clnt_sock = new Socket(serv_sock->accept(clnt_addr));

			if (clnt_sock->getFd() == INVALID_SOCKET)
			{
				printf("Accept failed.\n");
				continue;
			}

			printf("client IP address: %s,port: %d\n", inet_ntoa(clnt_addr->addr.sin_addr), ntohs(clnt_addr->addr.sin_port));

			clnt_sock->setnonblocking();// 设置新客户端套接字为非阻塞

			ep->add(clnt_sock->getFd());// 将新客户端添加到监听集合
		}
		
		// 处理所有可读的客户端套接字
		for (int i = 1; i < ep->getreadfds().fd_count; ++i)
		{
			SOCKET clntSock = ep->getreadfds().fd_array[i];
			if (ep->isset(clntSock))
			{
				char buf[READ_BUFFER];
				memset(buf, 0x00, sizeof(buf));
				int read_bytes = recv(clntSock, buf, sizeof(buf), 0);

				if (read_bytes > 0)
				{
					printf("Message from client %d : %s\n", clntSock,buf);
					send(clntSock, buf, read_bytes, 0); // 回显客户端消息
				}
				else if (read_bytes == 0)
				{
					printf("EOF,client fd %d isconnect\n", clntSock);
					closesocket(clntSock);
					ep->remove(clntSock);
				}
				else if (read_bytes == -1)
				{
					// 客户端正常中断，继续读取
					std::cout << "EOF,client fd " << clntSock << " disconnect" << std::endl;
					closesocket(clntSock);
					ep->remove(clntSock);
					continue;
				}
				else if (read_bytes == -1 && (errno == EINTR))
				{
					// 客户端正常中断，继续读取
					continue;
				}
				else if (read_bytes == -1 && (errno == EAGAIN || errno == EWOULDBLOCK))
				{
					// 非阻塞I/O，表示数据已经全部读取完毕
					break;
				}
			}
		}
	}

	// 关闭套接字
	closesocket(serv_sock->getFd());

	// 终止DLL的使用
	WSACleanup();

	return 0;
}







