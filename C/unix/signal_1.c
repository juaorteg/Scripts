#include "apue.h"

static void sig_usr(int);

int main(void) {
  if (signal(SIGUSR1, sig_usr) == SIG_ERR)
    err_sys("can't catch SIGUSR1");
  if (signal(SIGINT, sig_usr) == SIG_ERR)
    err_sys("can't catch SIGINT");
  for (;;)
    pause();
  return 0;
}

static void sig_usr(int signo) {
  if (signo == SIGUSR1)
    printf("receive SIGUSR1\n");
  else if (signo == SIGINT)
    printf("received SIGINT\n");
  else
    err_dump("receive signal d\n", signo);
}

