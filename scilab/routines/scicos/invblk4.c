#include "scicos_block4.h"
#include <stdio.h>

void invblk4(scicos_block *block,int flag)
{
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  /* Copyright INRIA
     
  Scicos block simulator
  Outputs the inverse of the input */
  
  int i;
  double ww;
  if (flag == 6){
    for(i=0;i< GetInPortRows(block,1);i++){
      ww=_u1[i];
      if (ww != 0.0)
	_y1[i]=1.0/ww;
    }
  }
  if (flag == 1){
    for(i=0;i< GetInPortRows(block,1);i++){
      ww=_u1[i];
      if (ww != 0.0)
	_y1[i]=1.0/ww;
      else{
	set_block_error(-2);
	return;
      }
    }
  } 
}
