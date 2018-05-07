#include <stdio.h>
#include <pthread.h>

typedef struct {
  int cash;
  pthread_mutex_t lock;
} Bank;

static Bank the_bank;

void deposit(int n) {
  pthread_mutex_lock(&the_bank.lock);
  int current_cash = the_bank.cash;
  the_bank.cash = current_cash + n;
  pthread_mutex_unlock(&the_bank.lock);
}

void withdraw(int n) {
  pthread_mutex_lock(&the_bank.lock);
  if (the_bank.cash >= n) {
    the_bank.cash -= n;
  }
  pthread_mutex_unlock(&the_bank.lock);
}

void* customer(void* args) {
  for (int i = 0; i < 100; ++i) {
    deposit(1);
  }

  for (int i = 0; i < 100; ++i) {
    withdraw(2);
  }

  return NULL;
}

int main() {
  int N = 300;

  pthread_mutex_init(&the_bank.lock, NULL);
  the_bank.cash = 0;

  pthread_t tids[N];
  for (int i = 0; i < N; ++i) {
    pthread_create(&tids[i], NULL, &customer, NULL);
  }

  for (int i = 0; i < N; ++i) {
    pthread_join(tids[i], NULL);
  }

  printf("Total: %d\n", the_bank.cash);

  return 0;
}
