#include "SSNetService.h"
#include <iostream>

SSN_API ISSNetService *ssn_create_service()
{
	try {
		auto service = new SSNetService;
		return service;
	} catch (const std::exception& err) {
		std::cout << err.what() << std::endl;
		return nullptr;
	}
}

SSN_API void ssn_destory_service(ISSNetService *service)
{
	if (service) {
		delete service;
	}
}