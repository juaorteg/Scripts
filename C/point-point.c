#include <stdio.h>

int main() {
	int a = 12;
	int *b = &a;
	printf("a = %d\n&a = %p\nb = %p\n*b = %d\n&b = %p", a, &a, b, *b, &b);
	int **c = &b;
	printf("\n\nb = %p\n*b = %d\nc = %p\n*c = %p\n**c = %d\n&c = %p\n", b, *b, c, *c, **c, &c);
	int ***d = &c;
	printf("\n\nd = %p\n*d = %p\n**d = %p\n***d = %d\n&d = %p\n", d, *d, **d, ***d, &d);
	return(0);
}

