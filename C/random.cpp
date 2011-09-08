#include <time.h>
#include <stdio.h>
#include <stdlib.h>

int fillrandom(int *array, int len) {
	srand(time(NULL));
	for (int i=0; i < len; i++) {
		array[i] = rand() % 100;
	}
	return 0;
}

int main() {
	int numbers[100];
	fillrandom(numbers, sizeof(numbers) / sizeof(int));
	for (int i=0;i<100;i++) {
		printf("Numbers[%d] = %d\n", i, numbers[i]);
	}
	return 0;
}

