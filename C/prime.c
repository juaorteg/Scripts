#include <stdio.h>

int main(int argc, char **argv) {
	long number = atoi(argv[1]);
        long divisor = 3;

	if (number < 2)
		printf("Illegal input: %d\n", number);
	else if (number == 2)
		printf("Number %d is prime\n", number);
	else if (number%2 == 0)
		printf("Number %d is NOT prime\n", number);
	else {
		do {
			if ((divisor*divisor > number) || (number%divisor == 0))
					break;
			divisor+=2;
		} while (1);
		if (divisor * divisor > number)
			printf("Number %d is a prime\n", number);
		else
			printf("Number %d is NOT a prime\n", number);
	}
	return (0);
}

