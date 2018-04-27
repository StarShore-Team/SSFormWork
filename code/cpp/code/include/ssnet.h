#pragma once

#define PROTOCOL_HEADER_LEN 8

extern "C" {

	class ISSNetClient
	{
	public:
		virtual ~ISSNetClient() {};

		// 与服务端建立连接
		virtual bool connect(const char *host, int port) = 0;

		// 与服务器断开连接
		virtual bool close() = 0;

		// 同步发送
		virtual int send(const char *buff, size_t len) = 0;

		// 同步接受
		virtual int recv(char *buff, size_t len) = 0;


		// 设置默认协议号
		virtual void apply_protocol(char prot) = 0;

		// 设置默认版本号
		virtual void apply_version(char ver) = 0;
	};

	// 接收消息回掉函数
	// [type] 类型
	// [version] 版本号
	// [buff:len] 接收到的数据
	// [retBuff:retLen] 需要反馈的数据，最大长度（65536-8）字节
	typedef void(*RecvCallBack)(char type, char version, const char *buff, int len, char *retBuff, int* retLen);

	class ISSNetService
	{
	public:
		virtual ~ISSNetService() {};

		// 初始化
		virtual void init(RecvCallBack pfnRecvCallBack, unsigned short port) = 0;

		// 启动服务
		virtual void start() = 0;

		// 关闭服务
		virtual void stop() = 0;

	};

#ifdef SSN_EXPORTS
# define SSN_API __declspec(dllexport)
#else
# define SSN_API __declspec(dllimport)
#endif

	SSN_API ISSNetService *ssn_create_service();
	SSN_API void ssn_destory_service(ISSNetService *service);
}