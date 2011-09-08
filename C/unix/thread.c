#include "apue.h"
#include <pthread.h>

pthread_t ntid;

void printids(const char *s) {
  pid_t     pid;
  pthread_t tid;

  pid = getpid();
  tid = pthread_self();
  printf("%s pid %u tid Z%u (0x%x)\n", s, (unsigned int)pid, (unsigned int)tid, (unsigned int)tid);
}

void *thr_fn(void *arg) {
  int ok=5;
  ok=ok*555;
  printf("%d\n", ok);
  printids("new thread: ");
  return((void *)0);
}

int main(void) {
  int err;
  err = pthread_create(&ntid, NULL, thr_fn, NULL);
  if (err!=0)
    err_quit("can't create thread: %s\n", strerror(err));
  int ko=5;
  ko=ko*9999;
  printf("%d\n", ko);
  printids("main thread:");
  //sleep(1);
  exit(0);
}

