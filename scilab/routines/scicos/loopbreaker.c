#include "scicos_block4.h"
#include <math.h>

void loopbreaker(scicos_block *block, int flag)
{
  int i;
  int nx=GetNstate(block);
  double *res=GetResState(block);
  /*double *xd=GetDerState(block);*/
  double *x=GetState(block);
  double *u=GetRealInPortPtrs(block,1);
  double *y=GetRealOutPortPtrs(block,1);

  if (flag==0){
      for(i=0;i<nx;++i) {
	 res[i]=x[i]-u[i];
      }
  }else if (flag==1||flag==6){
      for(i=0;i<nx;++i) {
         y[i]=x[i];
      }
  }
    
}
