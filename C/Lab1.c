/**
 * Author : Juan Ortega
 * Date   : 6/9/2011
 * Purpose: User is asked to enter numbers to sort. Max input is MAX_NUM.
 *          Bubble sort algorithm is used. Dynamic arrays are used.
 * Compile: gcc -o Lab1 Lab1.c
 *
 * Output : ./Lab1 ## ## ## ## ##
 *
 *   [Sorted Numbers Entered]
 *   [] ## ## ## ## ## []
 *
 * Info   : User may enter numbers as arguments to be sorted.
 *          Only the first 10 numbers entered will be sorted.
 *
 * Second Output : ./Lab1
 *  [Enter numbers] [Use '-1' to finish] [Max = (MAX_NUM)]
 *  [0] = ##
 *  [1] = ##
 *  [2] = ##
 *  [3] = ##
 *  ...
 *
 *  [Sorted Numbers Entered]
 *  [] ## ## ## ## ## []
 *
 * Info   : Without arguments, the user may enter numbers using -1 to finish.
 *          If the Max number of elements are entered, the program stops and sorts.
 *
**/

//
// Library Declarations
//
#include <stdio.h>
#include <stdlib.h>

//
// Define the max number of enteries
//
#define MAX_NUM 10

//
// Initialization of the sort function
//
void bubbleSort(int * const array, const int size);

//
// Main Function
//
int main(int argc, char *argv[]) {

  //
  // Declaration of Dynamic Array using calloc
  //
  int *numbers = (int *) calloc(MAX_NUM, sizeof(int));

  //
  // Declarations for loops
  //
  int i, j;
  

  //
  // If arguments are specified, the first 10 numbers are filled
  // into the dynamic array.
  //
  if (argc > 1) {
    if (argc > MAX_NUM+1) {
      printf("%d numbers entered, but Max = %d, only the first %d will be used\n",
             argc-1, MAX_NUM, MAX_NUM);
      argc = MAX_NUM+1;
    }
    for (i=0,j=1;i<argc,j<argc;i++,j++) {numbers[i] = atoi(argv[j]);}
  }

  //
  // If no arguments are specified the user must enter them one by one
  // using '-1' to finish or until the Max enteries have been entered
  //
  else {
    printf("[Enter numbers] [Use \'-1\' to finish] [Max = %d]\n\n", MAX_NUM);
    for (i=0;i<MAX_NUM;i++)  {
      printf("[%d] = ", i);
      scanf("%d", &numbers[i]);
      if (numbers[i] == -1) {break;}
    }
  }

  //
  // Set the next element to '\0' stating its the last
  //
  numbers[i] = '\0';

  //
  // Shrink the Dynamic array if lower than 10 elements
  //
  numbers = (int*) realloc(numbers, i * sizeof(int));

  //
  // Initialize the function to sort the dynamic elements
  //
  bubbleSort(numbers, i);

  //
  // Proceed to the output of the sorted elements
  //
  printf("\n[Sorted Numbers Entered]\n[] ");
  for (j=0;j<(i);j++) {printf("%d ", numbers[j]);}
  printf("[]\n");

  //
  // Free up the memory allocation
  //
  free(numbers);

  //
  // Exit successfully
  //
  return (EXIT_SUCCESS);
}

//
// Sort the elements using the bubble algorithm
//
void bubbleSort(int * const array, const int size) {
  void swap(int *element1Ptr, int *element2Ptr);
  short int pass, j;

  for (pass=0;pass<size-1;pass++)
    for (j=0;j<size-1;j++)
      if (array[j]>array[j+1])
        swap(&array[j], &array[j+1]);
}

//
// Used by the bubble function to swap elements
//
void swap(int *element1Ptr, int *element2Ptr) {
  int hold = *element1Ptr;
  *element1Ptr = *element2Ptr;
  *element2Ptr = hold;
}

