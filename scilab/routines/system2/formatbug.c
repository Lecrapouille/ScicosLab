#include <stdio.h>
#include <string.h>
#include "../machine.h"

int C2F(formatpatch)(char *dest,int *fl, int *n2,double *a,long int ndest)
{
  /* the string built here should not be null terminated 
   * but terminated by ' ' ' ' to mimic fortran.
   */
  snprintf(dest,ndest,"%#*.*f",*fl,*n2,*a);
  dest[*fl]=' ';
  dest[*fl+1]=' ';
  return 0;
}



