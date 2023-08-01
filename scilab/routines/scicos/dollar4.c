#include "scicos_block4.h"

void dollar4(scicos_block *block,int flag)
{
  double *_z=GetDstate(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  /* c     Copyright INRIA
     
  Scicos block simulator
  Ouputs delayed input */
  
  int i;
  for(i=0;i< GetInPortRows(block,1);i++){
    if (flag ==1 || flag ==6 || flag ==4)
      _y1[i]=_z[i];
    else if (flag == 2)
      _z[i]=_u1[i];
  }
}
