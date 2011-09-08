#include <stdio.h>

#define TRUE 1
#define FALSE -1

int find_char(char **strings, char value) {
	char *string;
	while ((string = *strings++) != NULL ) {
		printf("%s\n", *string);
		while(*string != '\0') {
			if (*string++ == value)
				return TRUE;
		}
	}
	return FALSE;
}

int main() {
	char *words[3] = {"iout", "whaxts", "up"};
	printf("%s\n%s\n%s\n", *words, *words+1, *words+2);
	char **ok = words;
	printf("%s\n%s\n%s\n", *ok, *ok+1, *ok+2);
	if (find_char(words, 'x'))
		printf("Found x\n");
	else
		printf("No x found\n");
	return(0);
}

