#pragma once

class ISSNetClient
{
public:
	virtual ~ISSNetClient() = 0;

	// �����˽�������
	virtual bool Connect(const char *host, int port) = 0;

	// ��������Ͽ�����
	virtual bool Close() = 0;

	// ͬ������
	virtual int Send(const char *buff, size_t len) = 0;

	// ͬ������
	virtual int Recv(char *buff, size_t len) = 0;

	// ����Ĭ��Э���
	virtual void SetProtocol(char prot) = 0;

	// ����Ĭ�ϰ汾��
	virtual void SetVersion(char ver) = 0;
};

typedef void(*RecvCallBack)(char *buff, int len);

class ISSNetService
{
public:
	virtual ~ISSNetService() = 0;

	// ��������
	virtual void Start() = 0;

	// �رշ���
	virtual void Stop() = 0;

	// ע�����ݴ���ص�
	virtual void RegisterRecvCallBack(RecvCallBack pfnRecvCallBack) = 0;

};