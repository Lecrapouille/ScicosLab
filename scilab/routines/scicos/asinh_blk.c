#include "scicos_block4.h"
#include <math.h>

#if WIN32
extern double asinh(double x);
extern double acosh(double x);
extern double atanh(double x);
#endif

void asinh_blk(scicos_block *block,int flag)
{
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  int j;
  if(flag==1){
    for (j=0;j<GetInPortRows(block,1);j++) {
      _y1[j]=asinh(_u1[j]);
    }
  }
}
