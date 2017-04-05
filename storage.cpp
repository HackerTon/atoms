#include "storage.h"
#include <cstdio>
#include <iostream>

using namespace std;

storage::storage(ptr::uPtr<unsigned int>& buffer, int nSize) : storage_buffer(buffer), size(nSize) {};

void storage::print(const int size) {
	if (storage_buffer.check()) {
		for (size_t i = 0; i < size; i++)
		{
			cout << storage_buffer[i] << endl;
		}
	}
}

void storage::write_to_file(const char* name) {
	if (name != "") {
		FILE *file = nullptr;

		file = fopen(name, "wb");

		if (file != NULL) {
			fwrite(*storage_buffer, size, sizeof(int), file);

			fclose(file);
		}
	}
}

void storage::read_from_file(const char* name) {
	if (name != "") {
		FILE* file = nullptr;

		file = fopen(name, "rb");

		if (file != NULL) {
			if (storage_buffer.check()) {

				cout << "BUFFER ALLOCATED";

				fclose(file);

				return;
			}
			else {
				fread(*storage_buffer, size, sizeof(int), file);

				fclose(file);
			}
		}

	}
}
