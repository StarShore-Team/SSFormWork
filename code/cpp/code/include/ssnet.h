#pragma once

#define PROTOCOL_HEADER_LEN 8

extern "C" {

	class ISSNetClient
	{
	public:
		virtual ~ISSNetClient() {};

		// �����˽�������
		virtual bool connect(const char *host, int port) = 0;

		// ��������Ͽ�����
		virtual bool close() = 0;

		// ͬ������
		virtual int send(const char *buff, size_t len) = 0;

		// ͬ������
		virtual int recv(char *buff, size_t len) = 0;


		// ����Ĭ��Э���
		virtual void apply_protocol(char prot) = 0;

		// ����Ĭ�ϰ汾��
		virtual void apply_version(char ver) = 0;
	};

	// ������Ϣ�ص�����
	// [type] ����
	// [version] �汾��
	// [buff:len] ���յ�������
	// [retBuff:retLen] ��Ҫ���������ݣ���󳤶ȣ�65536-8���ֽ�
	typedef void(*RecvCallBack)(char type, char version, const char *buff, int len, char *retBuff, int* retLen);

	class ISSNetService
	{
	public:
		virtual ~ISSNetService() {};

		// ��ʼ��
		virtual void init(RecvCallBack pfnRecvCallBack, unsigned short port) = 0;

		// ��������
		virtual void start() = 0;

		// �رշ���
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