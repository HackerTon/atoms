
//CUDA Library
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <cublas_v2.h>
#include <curand.h>

//C++ Library
#include <stdio.h>
#include <cstdio>
#include <iostream>
#include <fstream>

//Personal Library
#include "headers.hpp"
#include "smartptr.hpp"
#include "storage.h"

//OPENCV Library
#include <opencv2/core/core.hpp>

using namespace std;
using namespace cv;

//MACRO
#define SIZEOF(width, height, typevariable) sizeof(typevariable)*(width*height)
#define LOC(width, height, widthOfMat) (height*widthOfMat) + width
#define POW(width, height) width * height

//DEFINITION
const int SIZE = 2<<27;

//Prototype Function Declaration
template <unsigned int convWidth, unsigned  int widthofmat> __global__ void Map_Gather(int*, int*, int*);
__host__ void map_gather();
void curand_function();

class image_config{
public:
	image_config() = delete;
	void read_image(string fileName = "");
private:

};

class deepLearning{
public:
	void display(int width, int height, int* ptr);
private:
	int* dMem = nullptr;
	int* OdMem = nullptr;
	int* OhMem = nullptr;
	int* ConvdMem = nullptr;
	int* ConvhMem = nullptr;
	int* hMem = nullptr;

	//TEST PARM
	int print;

	const int imageSize = 10;
	const int convSize = imageSize - 2;
};


int main(int argc, char* argv[]) {

	try
	{
		map_gather();
//		curand_function();

		cout << "PROGRAM FINISHED" << endl;
	}
	catch (const Exception& excep) {
		cerr << "Error found at line " << excep.Line << " with error code " << excep.type << " and error type " << excep.type << endl;;
		return -1;
	}

	cin.get();
}

template <unsigned int convWidth, unsigned  int widthofmat> __global__ void Map_Gather(int* input, int* output, int* convlayer) {

	int loResult = 0;

	const int ix = threadIdx.x;
	const int iy = threadIdx.y;

	for (int i_y = 0; i_y < 3; ++i_y) {

		for (int i_x = 0; i_x < 3; ++i_x) {

			loResult += convlayer[LOC(i_x, i_y, 3)] * input[LOC((ix + i_x), (iy + i_y), widthofmat)];

		}

	}

	output[LOC(ix, iy, convWidth)] = loResult;

}

__host__ void map_gather() {

	cout << "RUNNING 'Map and Gather Function'" << endl;

	const int imageSize = 10;
	const int convSize = imageSize - 2;

	int* dMem = nullptr;
	int* OdMem = nullptr;
	int* OhMem = nullptr;
	int* ConvdMem = nullptr;
	int* ConvhMem = nullptr;
	int* hMem = nullptr;

	cuda(cudaMalloc(&dMem, SIZEOF(imageSize, imageSize, int)));
	cuda(cudaMalloc(&OdMem, SIZEOF(convSize, convSize, int)));
	cuda(cudaHostAlloc(&OhMem, SIZEOF(convSize, convSize, int), cudaHostAllocDefault));
	cuda(cudaMalloc(&ConvdMem, SIZEOF(3, 3, int)));
	cuda(cudaHostAlloc(&hMem, SIZEOF(imageSize, imageSize, int), cudaHostAllocDefault));
	cuda(cudaHostAlloc(&ConvhMem, SIZEOF(3, 3, int), cudaHostAllocDefault));

	for (int i = 0; i < POW(imageSize, imageSize); ++i) {
		hMem[i] = 0;
	}

	hMem[LOC(1, 1, imageSize)] = 1;
	hMem[LOC(1, 2, imageSize)] = 1;
	hMem[LOC(1, 3, imageSize)] = 1;

	hMem[LOC(5, 1, imageSize)] = 1;
	hMem[LOC(4, 2, imageSize)] = 1;
	hMem[LOC(3, 3, imageSize)] = 1;

	ConvhMem[0] = 0;
	ConvhMem[1] = 0;
	ConvhMem[2] = 9;
	ConvhMem[3] = 0;
	ConvhMem[4] = 9;
	ConvhMem[5] = 0;
	ConvhMem[6] = 9;
	ConvhMem[7] = 0;
	ConvhMem[8] = 0;

	cout << "IMAGE LAYER" << endl;
//	display(imageSize, imageSize, hMem);

	cout << "CONV LAYER" << endl;
//	display(3, 3, ConvhMem);

	cuda(cudaMemcpy(dMem, hMem, SIZEOF(imageSize, imageSize, int), cudaMemcpyHostToDevice));
	cuda(cudaMemcpy(ConvdMem, ConvhMem, SIZEOF(3, 3, int), cudaMemcpyHostToDevice));

	dim3 threads(convSize, convSize);

	Map_Gather<convSize, imageSize><<< 1, threads>>>(dMem, OdMem, ConvdMem);

	cuda(cudaMemcpy(OhMem, OdMem, SIZEOF(convSize, convSize, int), cudaMemcpyDeviceToHost));

	cout << "ACTIVATION LAYER 1" << endl;

//	display(convSize, convSize, OhMem);

	cuda(cudaFree(dMem));
	cuda(cudaFree(ConvdMem));
	cuda(cudaFree(OdMem));
	cuda(cudaFreeHost(OhMem));
	cuda(cudaFreeHost(hMem));
	cuda(cudaFreeHost(ConvhMem));

	dMem = nullptr;
	OdMem = nullptr;
	OhMem = nullptr;
	ConvdMem = nullptr;
	ConvhMem = nullptr;
	hMem = nullptr;

}

void curand_function() {

	//Declare CURAND Generator
	curandGenerator_t generator;

	//Create CURAND Generator
	crand(curandCreateGenerator(&generator, CURAND_RNG_PSEUDO_DEFAULT));

	//Set CURAND Seed
	crand(curandSetPseudoRandomGeneratorSeed(generator, 8888LL));

	//Declare GPU MEM
	unsigned int* memNumber = nullptr;

	//Declare CPU MEM
	ptr::uPtr<unsigned int> cpuMem(new unsigned int[SIZE]);

	cuda(cudaMalloc(&memNumber, sizeof(int) * SIZE));

	crand(curandGenerate(generator, memNumber, SIZE));

	cuda(cudaMemcpy(*cpuMem, memNumber, sizeof(unsigned int)* SIZE, cudaMemcpyDeviceToHost));

	storage st(cpuMem, SIZE);

	st.print(SIZE);

	//FREE MEMORY
	crand(curandDestroyGenerator(generator));
	cuda(cudaFree(memNumber));

	//Initialize To NULL
	generator = nullptr;
	memNumber = nullptr;
}

void image_config::read_image(string fileName = ""){
	Mat image;
}

void deepLearning::display(int width, int height, int* ptr) {
	for (int y = 0; y < height; ++y) {
		for (int x = 0; x < width; ++x) {
			cout << ptr[LOC(x, y, width)] << ",";
		}

		cout << endl;
	}
}
