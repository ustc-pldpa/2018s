#include <stdio.h>
#include <pthread.h>

typedef struct {
  int cash;
  pthread_mutex_t deposit_lock;
  pthread_mutex_t withdraw_lock;
} Bank;

static Bank the_bank;

void deposit(int n) {
  pthread_mutex_lock(&the_bank.deposit_lock);
  the_bank.cash += n;
  pthread_mutex_unlock(&the_bank.deposit_lock);
}

void withdraw(int n) {
  pthread_mutex_lock(&the_bank.withdraw_lock);
  if (the_bank.cash >= n) {
    the_bank.cash -= n;
  }
  pthread_mutex_unlock(&the_bank.withdraw_lock);
}

void* customer(void* args) {
  for (int i = 0; i < 100; ++i) {
    deposit(2);
  }

  for (int i = 0; i < 100; ++i) {
    withdraw(2);
  }

  return NULL;
}

int main() {
  int N = 32;

  pthread_mutex_init(&the_bank.deposit_lock, NULL);
  pthread_mutex_init(&the_bank.withdraw_lock, NULL);
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
