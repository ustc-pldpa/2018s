int main() {
  int x[] = {1, 2, 3, 4, 5};

  #pragma omp parallel for
  for (int i = 0; i < 5; ++i) {
    x[i] = x[i] + 1;
  }
}
