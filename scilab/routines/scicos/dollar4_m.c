#include <string.h>
#include "scicos_block4.h"


void dollar4_m(scicos_block *block,int flag)
{
  /*Scicos block simulator
  Ouputs delayed input */

  double *y,*u,*oz;
  int m=GetInPortRows(block,1);
  int n=GetInPortCols(block,1);
  u=GetInPortPtrs(block,1);
  y=GetOutPortPtrs(block,1);
  oz=GetOzPtrs(block,1);

  if (flag ==1 || flag ==6) memcpy(y,oz,m*n*GetSizeOfOz(block,1));
  if (flag == 2) memcpy(oz,u,m*n*GetSizeOfOz(block,1));
}
