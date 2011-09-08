#include <stdio.h>
#include <stdlib.h>

void sieve(int size) {
  int i, j;
  char *sieve = calloc(size, 1);
  for (i=2;i*i<=size;i++)
    if (!sieve[i])
      for (j=i+i;i<size;j+=i)
        sieve[j] = 1;

  for (i=2;i<size;i++)
    if (!sieve[i])
      printf("%d ", i);

  printf("\n");
  free(sieve);
}

int main() {
  sieve(100);
  return 0;
}

