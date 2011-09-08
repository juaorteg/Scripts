#include <stdio.h>
#include <cstring.h>

typedef char* string;

int main(void) {
  string s = "Hi!";
  mbstate_t t;
  memset(&t, '\0', sizeof(t));
  n = mbsrtowcs(NULL, &scopy, strlen(scopy), &t);
  printf("String = %s\nSize = %d\n", s, n);
}

