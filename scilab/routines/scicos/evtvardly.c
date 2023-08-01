#include "scicos_block4.h"
#include <math.h>

void evtvardly(scicos_block *block,int flag)
{ 
  double *_evout= GetNevOutPtrs(block);
  double *_u1=GetRealInPortPtrs(block,1);
  if (flag==3){
    _evout[0]=_u1[0];
  }
}

