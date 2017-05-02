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

class errorExcept : public std::exception {
public:
	errorExcept(const int, const cudaError_t);
	errorExcept(const int, const cublasStatus_t);
	errorExcept(const int, const curandStatus_t);
	errorExcept(const int);

	int Line = 0;
	TYPE_ERROR type = (TYPE_ERROR)0;
private:
	int error = 0;
};

#define cuda(error) cuda_error(error, __LINE__)
#define crand(error) curand_error(error, __LINE__)

inline void cuda_error(const cudaError_t problem, const short int line) {

	if (problem != 0) {
		throw errorExcept(line, problem);
	}
}

inline void curand_error(const curandStatus_t problem, const short int line) {

	if (problem != 0) {
		throw errorExcept(line, problem);
	}
}

//errorExcept Handling CLASS
errorExcept::errorExcept(const int LINE, const cudaError_t ERROR) : Line(LINE), error(ERROR), type((TYPE_ERROR)CUDA) {};
errorExcept::errorExcept(const int LINE, const cublasStatus_t ERROR) : Line(LINE), error(ERROR), type((TYPE_ERROR)CUBLAS) {};
errorExcept::errorExcept(const int LINE, const curandStatus_t ERROR) : Line(LINE), error(ERROR), type((TYPE_ERROR)CURAND) {};
errorExcept::errorExcept(const int LINE) : Line(LINE) {};
