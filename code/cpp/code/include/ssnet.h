#pragma once

class ISSNetClient
{
public:
	virtual ~ISSNetClient() = 0;

	// 与服务端建立连接
	virtual bool Connect(const char *host, int port) = 0;

	// 与服务器断开连接
	virtual bool Close() = 0;

	// 同步发送
	virtual int Send(const char *buff, size_t len) = 0;

	// 同步接受
	virtual int Recv(char *buff, size_t len) = 0;

	// 设置默认协议号
	virtual void SetProtocol(char prot) = 0;

	// 设置默认版本号
	virtual void SetVersion(char ver) = 0;
};

typedef void(*RecvCallBack)(char *buff, int len);

class ISSNetService
{
public:
	virtual ~ISSNetService() = 0;

	// 启动服务
	virtual void Start() = 0;

	// 关闭服务
	virtual void Stop() = 0;

	// 注册数据处理回掉
	virtual void RegisterRecvCallBack(RecvCallBack pfnRecvCallBack) = 0;

};