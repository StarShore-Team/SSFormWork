#include "SSNetService.h"

#include <iostream>


session::session(RecvCallBackFun pfnRecvCallBack, tcp::socket socket)
	:m_pfnRecvCallBack(pfnRecvCallBack), socket_(std::move(socket))
{
	auto ep = socket_.remote_endpoint();
	printf("建立【%s:%d】的会话.\n", ep.address().to_string().c_str(), ep.port());
}

session::~session()
{
	printf("回话关闭.\n");
}

void session::start()
{
	do_read_hreader();
}

void session::do_read_hreader()
{
	auto self(shared_from_this());
	asio::async_read(socket_, asio::buffer(data_, PROTOCOL_HEADER_LEN),
		[this, self](std::error_code ec, std::size_t length)
	{
		if (!ec) {
			int32_t magic_number;
			uint16_t msg_len;
			uint8_t msg_type, msg_version;

			// 魔数
			memcpy(&magic_number, data_, sizeof(magic_number));
			magic_number = ntohl(magic_number);

			if (0x133ED55 != magic_number) {
				printf("魔数校验错误\n");
				return;
			}

			// 数据包总长
			memcpy(&msg_len, data_ + sizeof(magic_number), sizeof(msg_len));
			msg_len = ntohs(msg_len);

			// 数据类型
			memcpy(&msg_type, data_ + sizeof(magic_number) + sizeof(msg_len),
				sizeof(msg_type));

			// 数据版本号
			memcpy(&msg_version, data_ + sizeof(magic_number) + sizeof(msg_len) + sizeof(msg_type),
				sizeof(msg_version));

			do_read_data(msg_len, msg_type, msg_version);
		}
	});
}

void session::do_read_data(size_t len, char type, char version)
{
	auto self(shared_from_this());
	asio::async_read(socket_, asio::buffer(data_ + PROTOCOL_HEADER_LEN, len - PROTOCOL_HEADER_LEN),
		[this, self, len, type, version](std::error_code ec, std::size_t length)
	{
		if (!ec) {
			do_process(len, type, version);
		}
		printf("%s", ec.message().c_str());
	});
}

void session::do_process(size_t len, char type, char version)
{
	// 处理接收到的消息
	int length;
	m_pfnRecvCallBack(type, version, data_ + PROTOCOL_HEADER_LEN, static_cast<int>(len - PROTOCOL_HEADER_LEN)
		, back_ + PROTOCOL_HEADER_LEN, &length);
	_package_back(length - PROTOCOL_HEADER_LEN, type, version);
	auto self(shared_from_this());
	asio::async_write(socket_, asio::buffer(back_, length + PROTOCOL_HEADER_LEN),
		[this, self](std::error_code ec, std::size_t /*length*/)
	{
		if (!ec) {
			do_read_hreader();
		}
	});
}

void session::_package_back(size_t len, char type, char version)
{
	int magic_number = 0x133ED55;
	uint16_t msg_len = static_cast<uint16_t>(len);
	uint8_t msg_type = type, msg_version = version;

	magic_number = htonl(magic_number);
	msg_len = htons(msg_len);

	memcpy(back_, &magic_number, sizeof(magic_number));
	memcpy(back_ + sizeof(magic_number), &msg_len, sizeof(msg_len));
	memcpy(back_ + sizeof(magic_number) + sizeof(msg_len),
		&msg_type, sizeof(msg_type));
	memcpy(back_ + sizeof(magic_number) + sizeof(msg_len) + sizeof(msg_type),
		&msg_version, sizeof(msg_version));
}

server::server(RecvCallBackFun pfnRecvCallBack, asio::io_context& io_service, short port)
	:m_pfnRecvCallBack(pfnRecvCallBack),
	acceptor_(io_service, tcp::endpoint(tcp::v4(), port)),
	socket_(io_service)
{
	do_accept();
}

void server::do_accept()
{
	acceptor_.async_accept(socket_,
		[this](std::error_code ec)
	{
		if (!ec) {
			std::make_shared<session>(m_pfnRecvCallBack, std::move(socket_))->start();
		}

		do_accept();
	});
}

SSNetService::SSNetService()
{
}

SSNetService::~SSNetService()
{
}

void SSNetService::init(RecvCallBack pfnRecvCallBack, unsigned short port)
{
	m_pServ = std::make_shared<asio::io_context>(port);
	m_s = std::make_shared<server>(pfnRecvCallBack, *m_pServ, 6688);
}

void SSNetService::start()
{
	m_pServ->run();
}

void SSNetService::stop()
{
	throw std::logic_error("The method or operation is not implemented.");
}
