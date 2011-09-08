#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define MAXNUM 10000000

int main(int argc, char *argv[]) {
  
  uint32_t i, j, k, g, prime[MAXNUM];

  // 2-2
  for (i=0;i<MAXNUM;i++)
    prime[i] = i;
  for (i=2,j=3,k=5,g=7;i<MAXNUM ,j<MAXNUM ,k<MAXNUM ,g<MAXNUM;i+=2,j+=3,k+=5,g+=7) {
    prime[i] = 1;
    prime[j] = 1;
    prime[k] = 1;
    prime[g] = 1;
  }
  for (i=0;i<MAXNUM;i++) {
    if (prime[i] == 1)
      break;
    else
      printf("%uld ", prime[i]);
  }
  exit(0);
}

