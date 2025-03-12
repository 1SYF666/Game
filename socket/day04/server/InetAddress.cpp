#include"InetAddress.h"

InetAddress::InetAddress():addr_len(sizeof(addr))
{
	memset(&addr, 0, sizeof(addr));
}
InetAddress::InetAddress(const char* ip, uint16_t port):addr_len(sizeof(addr))
{
	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = inet_addr(ip);
	addr.sin_port = htons(port);
	addr_len = sizeof(addr);
}

InetAddress::~InetAddress()
{

}