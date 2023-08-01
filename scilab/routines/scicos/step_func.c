#include "scicos_block4.h"
#include <math.h>

void  step_func(scicos_block *block,int flag)
{
  double *_rpar=GetRparPtrs(block);
  int _nevprt=GetNevIn(block);
  double *_y1=GetRealOutPortPtrs(block,1);
  int i;
  if (flag==1&&_nevprt==1) {
    for (i=0;i<GetOutPortRows(block,1);++i) {
      _y1[i]=_rpar[GetOutPortRows(block,1)+i];
    } 
  }else if (flag==4) {
    for(i=0;i<GetOutPortRows(block,1);++i) {
      _y1[i]=_rpar[i];
    }
  }
}

