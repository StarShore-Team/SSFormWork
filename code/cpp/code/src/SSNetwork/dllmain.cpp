#include "SSNetService.h"
#include <iostream>

void fnRecvCallBack(char type, char version, const char *buff, int len, char *retBuff, int* retLen)
{
	*retLen = len;
	memcpy(retBuff, buff, *retLen);
/*	printf("recv: %s\n", retBuff);*/
}

int main(int argc, char *argv[])
{
	SSNetService server;
	server.init(fnRecvCallBack, 6688);
	server.start();
}