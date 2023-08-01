#include "scicos_block4.h"

void delay4(scicos_block *block,int flag)
{
  
  /* Copyright INRIA
   
     Scicos block simulator
     Ouputs nx*dt delayed input */

  double* y=GetRealOutPortPtrs(block,1);
  double* z=GetDstate(block);
  int nz=GetNdstate(block);
  double* u=GetRealInPortPtrs(block,1);
  
  int i;
  
  if (flag ==1 || flag ==4 || flag ==6){
    y[0]=z[0];
  }else if (flag == 2){
    /*  shift buffer */
    for (i=0; i<=nz-2; i++){
      z[i]=z[i+1];
    }
    /* add new point to the buffer */
    z[nz-1]=u[0];
  }
}

    
