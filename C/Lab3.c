/**
 * Author : Juan Ortega
 * Date   : 6/4/2011
 * Purpose:
 *
 * Compile: ./Lab3
 *
 *
 *
 *
 * Info   : 
 *
**/

#include <stdio.h>
#include <stdlib.h>

#define MAX_STUDENTS 20

typedef struct student {
  char *name;
  char course[6][6];
} Student;

const char courses[6][6] = {"INT330", "INT200", "SPT430", "CSC100", "CSC540", "NTS340"};

void list_courses(void);

int main(int argc, char **argv) {

  int current=0, menu;
  short int j, i=0;
  char *buffer;
  Student students[MAX_STUDENTS];
  if (argc > 1) {
    FILE *cfPtr;
    if ((cfPtr = fopen(argv[1], "r")) == NULL)
      while (!feof(cfPtr)) {
        fscanf(cfPtr, "%s %s %s %s %s %s %s", students[i].name, students[i].course[0],
	       students[i].course[1], students[i].course[2], students[i].course[3],
	       students[i].course[4], students[i].course[5]);
	i++;
      }
    fclose(cfPtr);
  }
  else {
    printf("[New data] [To open a file ./%s <file>]\nEnter new Student Name: ", argv[0]);
    scanf("%s", students[0].name);
  }
  printf("[Courses]\n");
  list_courses();
  printf("\nCurrent Student: %s\n", students[current].name);
  while (!feof(stdin)) {
    printf("\n1 - List Courses\n"
           "2 - Courses current student enlisted in\n"
	   "3 - Add course to current student\n"
           "4 - Change current Student\n"
	   "5 - List all students and enlisted courses\n"
	   "6 - Save to a file\n"
	   "7 - Quit\n\n"
	   "[%s]-> ", students[current].name);
    scanf("%d", &menu);
    switch (menu) {
      case 1:
        list_courses();
        break;
      case 2:
        printf("%s -> ", students[current].name);
        for (i=0;i<6;i++)
	  if (students[current].course[i] != NULL)
	    for (j=0;j<6;j++)
	      if (strcmp(courses[j], buffer)==0) {
	        //students[i]
	        pritnf("[%s] ", students[current].course[i]);
	      }
	      else
	        printf("Course does not exist.");
        break;
      case 3:
        printf("Course: ");
	scanf("%s", buffer);
	for (i=0;i<6;i++)
	  if (students[current].course[i] == NULL)
	    students[current].course[i] = *buffer;
        break;
      case 4:
        printf("Students: ");
	for (i=0;i<MAX_STUDENTS;i++)
	  if (students[i].name != NULL)
	    printf("[%s] ", students[i].name);
        printf("\nEnter new current student: ");
	scanf("%s", &buffer);
	i=0;
	while (students[i].name != buffer) {
	  if (i>6) {
	    printf("[New student]\n");
	    break;
	  }
	  i++;
	}
	if (i<6)
	  for(j=0;j<6;j++)
	    if (students[j].name == buffer)
	      current = j;
	else
	  for (j=0;j<6;j++)
	    if (students[j].name == NULL) {
	      current = j;
	      break;
	    }
        break;
      case 5:
        for (i=0;i<MAX_STUDENTS<i++)
	  if (students[i].name != NULL) {
	  printf("Student: %s\nCourses: ", students[i].name);
	  for (j=0;j<6;j++)
	    printf("[%s] ", students[i].course[j]);
	  printf("\n");
	  }
        break;
      case 6:
        FILE *cfPtr;
	printf("Enter file to save: ");
	scanf("%s", &buffer);
	if ((cfPtr = fopen(buffer, "w")) != NULL) {
	  for (i=0;i<MAX_STUDENTS;i++)
	    fprintf(cfPtr, "%s %s %s %s %s %s %s\n", students[i].name, students[i].course[0],
	            students[i].course[1], students[i].course[2], students[i].course[3],
		    students[i].course[4], students[i].course[5]);
	  fclose(cfPtr);
	}
	else ferror(cfPtr);
        break;
      case 7:
        return (EXIT_SUCCESS);
        break;
    }
  }
  return (EXIT_FAILURE);
}

void list_courses(void) {
  short int i;
  for (i=0;i<6;i++)
    printf("[%s] ", courses[i]);
}

