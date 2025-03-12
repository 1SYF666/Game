#pragma once

/*
	前置声明 class InetAddress;
	作用：声明了一个类 InetAddress，但未定义其具体内容。
	目的：允许 Socket 类使用 InetAddress 的指针（如 InetAddress*），而无需在头文件中包含 InetAddress 的完整定义。
*/

class InetAddress;

class Socket
{
private:
	int fd;
public:
	Socket();
	Socket(int);
	~Socket();

	void bind(InetAddress*);
	void listen();
	void setnonblocking();
	int accept(InetAddress*);

	int getFd();
};



