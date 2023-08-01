#include "scicos_block4.h"
#include <math.h>

void  signum(scicos_block *block,int flag)
{
  int _ng=GetNg(block);
  double *_g=GetGPtrs(block);
  int *_mode=GetModePtrs(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  // int phase= GetSimulationPhase(block);

  int i,j;
  if (flag==1){
    for(i=0;i<GetInPortRows(block,1);++i){
      if ( !areModesFixed(phase) || _ng==0 ) {
	if (_u1[i]<0){
	  j=2;
	} else if (_u1[i]>0){
	  j=1;
	}else{
	  j=0;
	}
      }else {
	j=_mode[i];
      }
      if (j==1){
	_y1[i]=1.0;
      } else if(j==2){
	_y1[i]=-1.0;
      }else{
	_y1[i]=0.0;
      }
    }
  }else if (flag==9){
    for(i=0;i<GetInPortRows(block,1);++i){
      _g[i]=_u1[i];
      if (!areModesFixed(phase)) {
	if(_g[i]<0){
	  _mode[i]=2;
	}else{
	  _mode[i]=1;
	}
      }
    }
  }
}

