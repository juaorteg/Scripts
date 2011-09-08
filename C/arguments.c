#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
	/*while(argc--)
		printf("%s\n", *argv++);*/
	printf("%s\n", *(argv+5));
	exit(EXIT_SUCCESS);
}

