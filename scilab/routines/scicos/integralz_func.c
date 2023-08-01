#include "scicos_block4.h"
#include <math.h>

void  integralz_func(scicos_block *block,int flag)
{
  double *_rpar=GetRparPtrs(block);
  double *_xd=GetDerState(block);
  double *_x=GetState(block);
  double *_g=GetGPtrs(block);
  double *ur=GetRealInPortPtrs(block,1);
  double *ui=GetImagInPortPtrs(block,1);
  double *yr=GetRealOutPortPtrs(block,1);
  double *yi=GetImagOutPortPtrs(block,1);
  int _nx=GetNstate(block);
  int _ng=GetNg(block);
  int *_mode=GetModePtrs(block);
  int _nevprt=GetNevIn(block);
  int i;

  switch(flag)
    {
      /*----------------------------------------*/      
    case 0:
      if(_ng>0){
	for(i=0;i<(_nx)/2;++i) {
	  if(_mode[i]==3){
	    _xd[i]=ur[i];
	    _xd[i+(_nx)/2]=ui[i];
	  }else{
	    _xd[i]=0.0;
	    _xd[i+(_nx)/2]=0.0;
	  }
	}
      }else{
	for(i=0;i<(_nx)/2;++i) {
	  _xd[i]=ur[i];
	  _xd[i+(_nx)/2]=ui[i];
	}
      }
      break;
      /*----------------------------------------*/
    case 1:
    case 6:
      for(i=0;i<(_nx)/2;++i) {
	yr[i]=_x[i];
	yi[i]=_x[i+(_nx)/2];
      }
      break;
      /*----------------------------------------*/
    case 2:      
      if (_nevprt==1){
	for(i=0;i<(_nx)/2;++i) {
	  _x[i]=ur[i];
	  _x[i+(_nx)/2]=ui[i];
	}
      } 
      break;
      /*----------------------------------------*/
    case 9:

      if (!areModesFixed(block)) {	  
	for(i=0;i<_nx/2;++i) {
	  if (ur[i]>=0&&_x[i]>=_rpar[i]&&ui[i>=0]&&_x[i+(_nx)/2]>=_rpar[i+(_nx)]){
	    _mode[i]=1;
	  }else if (ur[i]<=0&&_x[i]<=_rpar[(_nx)/2+i]&&ui[i]<=0&&_x[i+(_nx)/2]<=_rpar[3*(_nx)/2+i]){
	    _mode[i]=2;
	  }else {
	    _mode[i]=3;
	  }
	}
      }

      for(i=0;i<_nx/2;++i) {
	if (_mode[i]==3){
	  _g[i]=(_x[i]-(_rpar[i]))*(_x[i]-(_rpar[(_nx)/2+i]));
	  _g[i+(_nx)/2]=(_x[i+(_nx)/2]-(_rpar[i+(_nx)]))*(_x[i+(_nx)/2]-(_rpar[3*(_nx)/2+i]));
	} else {
	  _g[i]=ur[i];
	  _g[i+(_nx)/2]=ui[i];
	} 	
      }
      break;
      /*----------------------------------------*/
    default :
      break;
      /*----------------------------------------*/   
    }
}
