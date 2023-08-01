#include <memory.h>
#include "scicos_block4.h"

void cstblk4(scicos_block *block,int flag)
{ 
  double *_rpar=GetRparPtrs(block);
  int _nrpar=GetNrpar(block);
  double *_y1=GetRealOutPortPtrs(block,1);
  /* Copyright INRIA
     
  Scicos block simulator
  output a vector of constants out(i)=rpar(i)
  rpar(1:nrpar) : given constants */
  
  memcpy(_y1,_rpar,_nrpar*sizeof(double));    
}
