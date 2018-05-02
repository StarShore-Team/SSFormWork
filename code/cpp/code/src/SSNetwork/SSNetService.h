#pragma once
#include "ssnet.h"

#include <cstdlib>
#include <iostream>
#include <memory>
#include <utility>
#include <memory>
#include <functional>
#include <asio.hpp>

using asio::ip::tcp;

using RecvCallBackFun = std::function<void(char, char, const char *, int, char *, int *)>;

class session
	: public std::enable_shared_from_this<session>
{
public:
	session(RecvCallBackFun pfnRecvCallBack, tcp::socket socket);
	~session();

	void start();

private:
	RecvCallBackFun m_pfnRecvCallBack;

	void do_read_hreader();

	void do_read_data(size_t len, char type, char version);

	void do_process(size_t len, char type, char version);

	void _package_back(size_t len, char type, char version);

	tcp::socket socket_;
	enum { max_length = 65535 };
	char data_[max_length];
	char back_[max_length];
};

class server
{
public:
	server(RecvCallBackFun pfnRecvCallBack, asio::io_context& io_service, short port);

private:
	RecvCallBackFun m_pfnRecvCallBack;

	void do_accept();

	tcp::acceptor acceptor_;
	tcp::socket socket_;
};


class SSNetService :
	public ISSNetService
{
public:
	SSNetService();
	~SSNetService();

	virtual void init(RecvCallBack pfnRecvCallBack, unsigned short port) override;

	virtual void start() override;

	virtual void stop() override;

private:
	std::shared_ptr<asio::io_context> m_pServ;

	std::shared_ptr<server> m_s;
};

