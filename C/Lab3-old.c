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
#include <readline/readline.h>
#include <readline/history.h>

static char** my_completion(const char*, int, int);
char* my_generator(const char*, int);
char *dupstr (char *);
void *xmalloc (int);

char* cmd[] = {"help", "course", "add", "del", "quit", "exit", " "};

void help();
void courses();

struct Student {
  char *name;
  char courses[6][6] = {"INT330", "INT200", "SPT430", "CSC100", "CSC540", "NTS340"};
};

int main(int argc, char **argv) {

  struct Student student;
  if (argc > 1)
    student.name = argv[1];
  else {
    printf("Enter student name: ");
    scanf("%s", student.name);
  }
  char *buf;
  rl_attempted_completion_function = my_completion;

  while((buf = readline("Students> "))!=NULL) {
    rl_bind_key('\t',rl_complete);
    if (strcmp(buf,cmd[0])==0) {help();}
    else if (strcmp(buf,cmd[1])==0) {courses();}
    else if (strcmp(buf,cmd[2])==0) {continue;}
    else if (strcmp(buf,cmd[3])==0) {continue;}
    else if (strcmp(buf,cmd[4])==0) {break;}
    else if (strcmp(buf,cmd[5])==0) {break;}
    if (buf[0]!=0) {add_history(buf);}
  }
  free(buf);
  return (EXIT_SUCCESS);
}

static char** my_completion(const char * text, int start, int end) {
  char **matches;
  matches = (char **)NULL;
  if(start == 0)
    matches = rl_completion_matches ((char*)text, &my_generator);
  else
    rl_bind_key('\t',rl_abort);
  return (matches);
}

char* my_generator(const char* text, int state) {
  static int list_index, len;
  char *name;

  if (!state) {
    list_index = 0;
    len = strlen (text);
  }
  while(name = cmd[list_index]) {
    list_index++;
    if (strncmp(name,text,len)==0)
      return (dupstr(name));
  }
  return ((char *)NULL);
}

char * dupstr (char* s) {
  char *r;

  r = (char*) xmalloc ((strlen(s)+1));
  strcpy(r,s);
  return (r);
}

void * xmalloc (int size) {
  void *buf;
  buf = malloc (size);
  if(!buf) {
    fprintf(stderr, "Error: Out of memory. Exiting.\n");
    exit (1);
  }
  return buf;
}

void help() {
  printf("courses      -- Get a list of Courses\n"
         "add [course] -- add yourself to the course\n"
	 "del [course] -- delete yourself from the course\n"
	 "quit         -- quit\n");
}

void courses() {
  printf("[Courses]\n"
         "INT330, INT200, SPT430, CSC100, CSC540, NTS340\n");

}

