#include "scicos_block4.h"
#include <math.h>



void ramp(scicos_block *block,int flag)
{double dt;
  double *_rpar=GetRparPtrs(block);
  double *_g=GetGPtrs(block);
  int *_mode=GetModePtrs(block);
  double *_y1=GetRealOutPortPtrs(block,1);

  switch(flag)
    {
      /*----------------------------------------*/      
    case 1:
      dt=GetScicosTime(block)-_rpar[1];
      if (!areModesFixed(block)) {
	if(dt>0) {
	  _y1[0]=_rpar[2]+_rpar[0]*dt;
	}else{
	  _y1[0]=_rpar[2];
	}
      }else{
	if(_mode[0]==1) {
	  _y1[0]=_rpar[2]+_rpar[0]*dt;
	}else {
	  _y1[0]=_rpar[2];
	}
      }
      break;
      /*----------------------------------------*/
    case 9:
      _g[0]=GetScicosTime(block)-(_rpar[1]);
      if (!areModesFixed(block)) {
	if (_g[0]>=0){
	  _mode[0]=1;
	}else{
	  _mode[0]=2;
	}
      }
      break;
      /*----------------------------------------*/
    default :
      break;
      /*----------------------------------------*/      
    }
}

