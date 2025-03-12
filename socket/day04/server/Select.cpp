#include"Select.h"
#include "util.h"
Select::Select():max_fd(INVALID_SOCKET)
{
	FD_ZERO(&readfds);		// 初始化集合
	setTimeout(1, 0);		// 默认超时1秒
}


Select::~Select()
{
}

void Select::setTimeout(int sec, int usec) // 设置超时
{
	timeout.tv_sec = sec;
	timeout.tv_usec = usec;
}
void Select::add(int sock) 
{
	errif(sock == INVALID_SOCKET, "Invalid socket");
	FD_SET(sock, &readfds);

	if (sock > max_fd)
	{
		max_fd = sock;  // 更新最大描述符
	}

}
void Select::remove(int sock) 
{
	FD_CLR(sock, &readfds);
	if (sock == max_fd) 
	{
		max_fd = INVALID_SOCKET;
	
		for (u_int i = 0; i < readfds.fd_count; ++i) {
			if (readfds.fd_array[i] > max_fd) {
				max_fd = readfds.fd_array[i];
			}
		}
	}
}
int Select::wait()
{
	fd_set tempfds = readfds;
	int activity = select(0, &tempfds, nullptr, nullptr, &timeout);
	errif(activity == SOCKET_ERROR, "Select call failed");

	readfds = tempfds;

	return activity;
}
bool Select::isset(int sock)
{
	return FD_ISSET(sock, &readfds) != 0;
}
void Select::clear()
{
	FD_ZERO(&readfds);
	max_fd = INVALID_SOCKET;
}
