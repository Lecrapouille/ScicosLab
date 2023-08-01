#include "scicos_block4.h"
#include <math.h>

void 
modulo_count(scicos_block *block,int flag)
{
  int *_ipar=GetIparPtrs(block);
  double *_z=GetDstate(block);
  double *_y1=GetRealOutPortPtrs(block,1);
  if(flag == 1) {
    *_y1=_z[0];
  }else if (flag == 2){
    _z[0]=(1+(int)_z[0])%(_ipar[0]);
   }
}

