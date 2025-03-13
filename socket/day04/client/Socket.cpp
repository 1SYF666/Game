#include <winsock2.h>
#include "Socket.h"
#include "util.h"
#include "InetAddress.h"
#pragma comment(lib,"ws2_32.lib")

Socket::Socket():fd(-1)
{
	// 创建套接字
	fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	errif(fd == INVALID_SOCKET, "Socket creation failed!");
}
Socket::Socket(int _fd) :fd(_fd)
{
	errif(fd == INVALID_SOCKET, "Socket creation failed!");
}


Socket::~Socket()
{
	if (fd != -1)
	{
		closesocket(fd);
		fd = -1;
	}
}

void Socket::bind(InetAddress* addr)
{
	//::bind：
	//使用全局作用域运算符::，显式调用系统函数 bind（避免与类中可能的同名方法冲突）。
	errif(::bind(fd, (SOCKADDR*)&addr->addr, addr->addr_len) == SOCKET_ERROR, "Socket bind failed!");
}

void Socket::listen()
{
	errif(::listen(fd, 20) == SOCKET_ERROR, "Listen failed!");
}

void Socket::setnonblocking()
{
	u_long mode = 1;  // 1表示非阻塞模式，0表示阻塞模式
	int result = ioctlsocket(fd, FIONBIO, &mode); // FIONBIO是设置非阻塞模式的控制命令
	errif(result != 0, "failed to set non-blocking mode");
}

int Socket::accept(InetAddress*addr)
{
	int clntSock = ::accept(fd, (SOCKADDR*)&addr->addr, &addr->addr_len);
	errif(clntSock == -1, "socket accept error");
	return clntSock;
}

int Socket::getFd()
{
	return fd;
}