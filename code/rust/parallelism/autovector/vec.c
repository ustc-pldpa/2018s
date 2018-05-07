void addvec(int* x, int* y) {
  for (int i = 0; i < 1024; ++i) {
    y[i] += x[i];
  }
}
