#pragma once

#include "smartptr.hpp"
#include <cstdio>

class storage {
public:
	storage(ptr::uPtr<unsigned int>&, int);
	void print(const int);
	void write_to_file(const char*);
	void read_from_file(const char*);
private:
	ptr::uPtr<unsigned int> storage_buffer = nullptr;
	int size = 0;
	FILE *file = nullptr;
};
