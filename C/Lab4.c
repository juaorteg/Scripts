#include <stdio.h>
#include <stdlib.h>

#define SIZE 11

float CalculateClassAverage(const short int*);
short int GetLowestClassGrade(const short int*);
short int GetHightestClassGrade(const short int*);
short int GetAverageClassGrade(const short int*);
/**
void DisplayClassRoster(const short int*);
**/

int main(int argc, char **argv) {
  short int i;
  const short int grades[SIZE] = {67, 89, 90, 89, 50, 65, 23, 89, 43, 89, 90};
  printf("Grades: ");
  for (i=0;i<SIZE;i++) {printf("[%d] ", grades[i]);}
  printf("\nClass Average: %.2f\nLowest Grade: %d\nHighest Grade: %d\n", (float)CalculateClassAverage(grades), GetLowestClassGrade(grades), GetHightestClassGrade(grades));
  return (EXIT_SUCCESS);
}

float CalculateClassAverage(const short int *grades) {
  short int i, add=0;
  for(i=0;i<SIZE;i++) {add += *(grades+i);}
  return (float)add/SIZE;

}

short int GetLowestClassGrade(const short int *grades) {
  short int i, low=*grades;
  for(i=1;i<SIZE;i++)
    if(low > *(grades+i))
      low=*(grades+i);
  return low;
}

short int GetHightestClassGrade(const short int *grades) {
  short int i, high=*grades;
  for(i=1;i<SIZE;i++)
    if(high < *(grades+i))
      high=*(grades+i);
  return high;
}

short int GetAverageClassGrade(const short int *grades) {
  short int i;
}

