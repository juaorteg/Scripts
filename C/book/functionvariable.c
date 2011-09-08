#include <stdio.h>
#include <string.h>

#define MAXLINES 5000 // max lines to be sorted
char *lineptr[MAXLINES];

int readlines(char *lineptr[], int nlines);
void writelines(char *lineptr[], int nlines);

void qsort(void *lineptr[], int left, int right,
		int (*comp)(void *, void *));
int numcmp(char *, char *);

// sort input lines
int main(int argc, char *argv[]) {
	int nlines;       // number if input lines read
	int numeric = 0;  // 1 if numberic sort
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		qsort((void **) lineptr, 0, nlines-1, (int (*)(void*,void*))(numeric ? numcmp : strcmp));
		writelines(lineptr, nlines);
		return 0;
	} else {
		printf("input too big to sort\n");
		return 1;
	}
}

