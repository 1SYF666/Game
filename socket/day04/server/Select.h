#pragma once
#include <winsock2.h>

class Select
{
private:
	fd_set readfds;
	int max_fd;         // 最大文件描述符（Windows 下不严格需要，但保留兼容性）
	timeval timeout;       // 超时设置
public:
    Select();              // 构造函数，初始化集合和超时
    ~Select();
    void setTimeout(int sec, int usec); // 设置超时
    void add(int sock); // 添加套接字到集合
    void remove(int sock); // 从集合中移除套接字
    int wait();            // 调用 select，等待事件
    bool isset(int sock); // 检查套接字是否就绪
    void clear();          // 清空集合

};


