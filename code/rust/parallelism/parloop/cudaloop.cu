__global__ void add_one(int *x) {
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  x[index] = x[index] + 1;
}

int main() {
  int x[256];
  int* x_gpu;
  cudaMalloc(&x_gpu, 256 * sizeof(int));
  cudaMemcpy(x_gpu, x, 256 * sizeof(int), cudaMemcpyHostToDevice);

  add_one<<<1, 256>>>(x_gpu);
}
