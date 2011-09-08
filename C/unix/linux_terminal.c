#include "apue.h"
#include <fcntl.h>

#ifndef _HAS_OPENPT
int posix_openpt(int oflag) {
  int fdm;
  fdm = open("/dev/ptmx", oflag);
  return(fdm);
}
#endif

#ifndef _HAS_PTSNAME
char * ptsname(int fdm) {
  int sminor;
  static char pts_name[16];
  if (ioctl(fdm, TIOCGPTN, &sminor) < 0)
    return(NULL);
  snprintf(pts_name, sizeof(pts_name), "/dev/pts/%d", sminor);
  return(pts_name);
}
#endif

#ifndef _HAS_GRANTPT
