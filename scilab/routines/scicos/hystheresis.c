#include "scicos_block4.h"
#include <math.h>

void  hystheresis(scicos_block *block,int flag)
{
  double *_rpar=GetRparPtrs(block);
  int _ng=GetNg(block);
  double *_g=GetGPtrs(block);
  int *_mode=GetModePtrs(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);

  switch(flag)
    {/*----------------------*/
    case 1:
      if (!areModesFixed(block)||_ng==0) {
	if (_u1[0]>=_rpar[0]){
	  _y1[0]=_rpar[2];
	}else if (_u1[0]<=_rpar[1]){
	  _y1[0]=_rpar[3];
	}else if ((_y1[0]!=_rpar[3])&&(_y1[0]!=_rpar[2])){
	  _y1[0]=_rpar[3];
	}
      }else{
	if (_mode[0]==2){
	  _y1[0]=_rpar[2];
	}else{
	  _y1[0]=_rpar[3];
	}
      } 
      break;
      /*----------------------*/
    case 9:
      _g[0]=_u1[0]-(_rpar[0]);
      _g[1]=_u1[0]-(_rpar[1]);
      if (!areModesFixed(block)) {
	if (_g[0]>=0){
	  _mode[0]=2;
	}else if (_g[1]<=0){
	  _mode[0]=1;
	}
      }
      break;
      /*----------------------*/
    default : 
      break;
    }
}
