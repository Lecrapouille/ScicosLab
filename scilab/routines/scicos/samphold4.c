#include "scicos_block4.h"

void samphold4(scicos_block *block,int flag)
{
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  /* c     Copyright INRIA
     
  Scicos block simulator
  returns sample and hold  of the input */
  
  int i;
  if (flag ==1){
    for (i=0;i<GetInPortRows(block,1);i++) 
      _y1[i]=_u1[i];
  }
}
