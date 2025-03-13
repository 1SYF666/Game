#pragma once
#ifdef _WIN32
	#include <winsock2.h>
	typedef int addr_len_t; // Windows 使用 int
#else
	#include <arpa/inet.h>
	#include <sys/socket.h>
	typedef socklen_t addr_len_t; // POSIX 使用 socklen_t
#endif
#include <cstdint> // 包含 uint16_t
class InetAddress
{
public:

	struct sockaddr_in addr;
	addr_len_t addr_len;
	InetAddress();
	InetAddress(const char* ip, uint16_t port);
	~InetAddress();

private:

};



