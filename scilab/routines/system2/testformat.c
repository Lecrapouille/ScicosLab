#include <stdio.h>
#include <string.h>
#include "../machine.h"

void C2F(formatnumberc)(double *x,int *n1,int *n2, char *str)
{
  snprintf(str,*n1+1,"%#*.*f",*n1,*n2,*x);
  /* sciprint("number [%f %d.%df {%s}]\r\n",*x,*n1,*n2,str); */
}
