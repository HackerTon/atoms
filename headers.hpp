#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "curand.h"

#include <iostream>

//Emulation data
enum TYPE_ERROR {
	CUDA = 0,
	CUBLAS = 1,
	CURAND = 2
};

class Exception : public std::exception {
public:
	Exception(const int, const cudaError_t);
	Exception(const int, const cublasStatus_t);
	Exception(const int, const curandStatus_t);
	Exception(const int);

	int Line = 0;
	TYPE_ERROR type = (TYPE_ERROR)0;
private:
	int error = 0;
};

#define cuda(error) cuda_error(error, __LINE__)
#define crand(error) curand_error(error, __LINE__)

inline void cuda_error(const cudaError_t problem, const short int line) {

	if (problem != 0) {
		throw Exception(line, problem);
	}
}

inline void curand_error(const curandStatus_t problem, const short int line) {

	if (problem != 0) {
		throw Exception(line, problem);
	}
}

//Exception Handling CLASS
Exception::Exception(const int LINE, const cudaError_t ERROR) : Line(LINE), error(ERROR), type((TYPE_ERROR)CUDA) {};
Exception::Exception(const int LINE, const cublasStatus_t ERROR) : Line(LINE), error(ERROR), type((TYPE_ERROR)CUBLAS) {};
Exception::Exception(const int LINE, const curandStatus_t ERROR) : Line(LINE), error(ERROR), type((TYPE_ERROR)CURAND) {};
Exception::Exception(const int LINE) : Line(LINE) {};
