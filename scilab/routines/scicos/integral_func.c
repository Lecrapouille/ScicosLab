#include "scicos_block4.h"
#include <math.h>

void  integral_func(scicos_block *block,int flag)
{
  double *_rpar=GetRparPtrs(block);
  double *_xd=GetDerState(block);
  double *_x=GetState(block);
  double *_g=GetGPtrs(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  double *_u2=GetRealInPortPtrs(block,2);
  int *_mode=GetModePtrs(block);
  int _nevprt=GetNevIn(block);
  int _nx=GetNstate(block);
  int _ng=GetNg(block);
  int i;

  switch(flag)
    {
      /*----------------------------------------*/      
    case 0:
      if (_ng>0) {
	for(i=0;i<_nx;++i) {
	  if(_mode[i]==3){
	    _xd[i]=_u1[i];
	  }else{
	    _xd[i]=0.0;
	  }
	}
      }else{
	for(i=0;i<_nx;++i) {
	  _xd[i]=_u1[i];
	}
      }
      break;
      /*----------------------------------------*/
    case 1:
    case 6:
      for(i=0;i<_nx;++i) 
	_y1[i]=_x[i];
      break;
      /*----------------------------------------*/
    case 2:      
      if (_nevprt==1){
	for(i=0;i<_nx;++i) 
	  _x[i]=_u2[i];
      }
      break;
      /*----------------------------------------*/
    case 9:
      
      if (!areModesFixed(block)) {
	for(i=0;i<_nx;++i) {
	  if (_u1[i]>=0 && _x[i]>=_rpar[i]){
	    _mode[i]=1;
	  }else if (_u1[i]<=0 && _x[i]<=_rpar[_nx+i]){
	    _mode[i]=2;
	  }else {
	    _mode[i]=3;
	  }
	}
      }

      for(i=0;i<_nx;++i) {
	if (_mode[i]==3){
	  _g[i]=(_x[i]-(_rpar[i]))*(_x[i]-(_rpar[_nx+i]));
	} else {
	  _g[i]=_u1[i];
	}	
      }

      break;
      /*----------------------------------------*/
    default :
      break;
      /*----------------------------------------*/      
    }
}
