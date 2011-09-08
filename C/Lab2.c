/***
 * Author  : Juan Ortega
 * Date    : 6/4/2011
 * Purpose : Define Professor, Course, and Students inside structures.
 *           Each Professor have their own Courses, each Course have their own Students.
 * Compile : gcc -o Lab2 Lab2.c
 *
 * Output : ./Lab2
 * [Professor]
 *   [Course]
 *     [Student]
 *
 * Professor0
 *   NTS300
 *         Student0
 *         Student1
 *         Student2
 *   SPT430
 *         Student0
 *         Student1
 *         Student2
 *   MAT340
 *         Student0
 *         Student1
 *         Student2
 *
 * Professor1
 *   ...
 *      ...
 *
 * Info  : No arguments needed
 *
**/

//
// Standard Libraries
//
#include <stdio.h>
#include <stdlib.h>

//
// Preprocessors defining the maximun
//
#define MAX_PROF 10
#define MAX_COURSES 10
#define MAX_STUDENTS 15

/**
 *   [How the structure will be set up]
 *
 *   prof[0]->name
 *   prof[0]->course[0]->name
 *   prof[0]->course[0]->students[0]->name
 *
**/

struct Prof {
  char * name;
  struct Course {
    char * name;
    struct Student {
      char * name;
    } student[MAX_STUDENTS];
  } course[MAX_COURSES];
};

//
// Main Function
//
int main(int argc, char **argv) {
  
  //
  // Declaration and Population
  //
  struct Prof prof[MAX_PROF] = {"Professor0",
                                       {"NTS300", 
				                 {"Student0", "Student1", "Student2"},
					"SPT430",
					         {"Student0", "Student1", "Student2"},
					"MAT340",
					         {"Student0", "Student1", "Student2"},
					},

				"Professor1",
				        {"CSC340",
					          {"Student0", "Student1", "Student2"},
					 "NTW300",
					          {"Student0", "Student1", "Student2"},
					 "SPT200",
					          {"Student0", "Student1", "Student2"},
					},

				"Professor2",
				        {"PSY230",
					          {"Student0", "Student1", "Student2"},
					 "ENG230",
					          {"Student0", "Student1", "Student2"},
					 "CSC504",
					          {"Student0", "Student1", "Student2"},
					}
				};

  //
  // Output of the structure
  //
  printf("%s\n%10s\n%16s\n", "[Professor]", "[Course]", "[Student]");
  int i, j, e;
  for (i=0;i<MAX_PROF;i++) {
    if (prof[i].name != NULL) {printf("\n%s\n", prof[i].name);}
    else continue;
    for (j=0;j<MAX_COURSES;j++) {
      if (prof[i].course[j].name != NULL) {printf("%8s\n", prof[i].course[j].name);}
      else continue;
      for (e=0;e<MAX_STUDENTS;e++) {
        if (prof[i].course[j].student[e].name != NULL)
	  printf("%16s\n", prof[i].course[j].student[e].name);
	else continue;
      }
    }
  }

  //
  // Exit Successfully
  //
   return (EXIT_SUCCESS);
}

