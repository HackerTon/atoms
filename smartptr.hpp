#pragma once

namespace ptr
{
	template <class T> class uPtr {
	private:
		T* ptr = nullptr;
		T* tPtr = nullptr;
	public:
		uPtr(T*);
		~uPtr();
		T* operator *();
		T& operator[] (const int);
		bool check();
		void initialize(T* tPtr);
	};

	template <class T> bool uPtr<T>::check() {
		if (ptr != nullptr) {
			return true;
		} else {
			return false;
		}
	}

	template <class T> uPtr<T>::uPtr(T* tPtr) : ptr(tPtr) {};

	template <class T> uPtr<T>::~uPtr() {
		delete[] ptr;

		ptr = nullptr;
	}

	template <class T> T* uPtr<T>::operator *() {
		return ptr;
	}

	template <class T> T& uPtr<T>::operator[] (const int index) {
		return ptr[index];
	}

	template <class T> void uPtr<T>::initialize(T* tPtr) {

		ptr = tPtr;

	}
}



