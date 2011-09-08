#include <stdio.h>
#include <stdlib.h>

size_t strlen(char *string) {
	int length = 0;

	while (*string++ != '\0')
		length += 1;
	return length;
}

int main() {
	char *name = "Juan";
	printf("Length is: %d\n", strlen(name));
	return(0);
}

