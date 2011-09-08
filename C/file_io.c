#include <stdlib.h>
#include <stdio.h>

#define MAX_LINES 100
#define MAX_LINE_LENGTH 1024

void read_words(FILE *);

short int main(int argc, char **argv) {

	FILE *file;

	if((file = fopen(*(argv+1), "r")) == NULL) {
		perror(*(argv+1));
		return(EXIT_FAILURE);
	} else {read_words(file);}

	fclose(file);
	return(EXIT_SUCCESS);
}

void read_words(FILE *file) {

	union Words {
		short int number[MAX_LINES];
		const char *words[MAX_LINES];
	} lines;
	short int i, num=0;
	char buffer[MAX_LINE_LENGTH];
	while(fgets(buffer, MAX_LINE_LENGTH, file) != NULL) {
		lines.words[++num] = buffer;
	}
	


	num=0;
	for (i=0;i<MAX_LINE_LENGTH;i++) {
		for (j=0;j<num;j++) {
			if (strcmp(lines.words[i], lines.words[j]) == 0) {
				
			}
		}
	}


	//for (i=0;i<MAX_LINE_LENGTH;i++) {
	//	printf("%d\t%s", lines.number[i], lines.words[i]);
	//}

	/***
	int i, line=1, num=0, times[MAX_LINES]=0;
	const char *words[MAX_LINES];
	char buffer[MAX_LINE_LENGTH];

	while(fgets(buffer, MAX_LINE_LENGTH, file) != NULL) {
		for (i=0;i<line;i++) {
			if ((strcmp(words[i], buffer)) == 0) {
				times[num]++;
				break;continue;
			}
		}

		line++;

		
		words[++num] = buffer;
		printf("%s", words[num]);
	}
	***/
}

