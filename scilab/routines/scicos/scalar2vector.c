#include "scicos_block4.h"
#include <math.h>

void scalar2vector(scicos_block *block,int flag)
{
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  int i;
  if(flag==1){
    for(i=0;i<GetOutPortRows(block,1);++i){
      _y1[i]=_u1[0];
    }
  }
}
