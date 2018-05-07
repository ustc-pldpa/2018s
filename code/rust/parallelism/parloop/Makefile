LLVM_DIR := /usr/local/Cellar/llvm/5.0.0
all:
	${LLVM_DIR}/bin/clang -fopenmp -L ${LLVM_DIR}/lib loop.c
	nvcc cudaloop.cu
