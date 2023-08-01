#include "scicos_block4.h"
#include <math.h>

void product(scicos_block *block,int flag)
{
  int *_ipar=GetIparPtrs(block);
  int _nin=GetNin(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  double *uytmp;
  int j,k;
  if(flag==1){
    if (_nin==1){
      _y1[0]=1.0;
      for (j=0;j<GetInPortRows(block,1);j++) {
	_y1[0]=_y1[0]*_u1[j];
      }
    }
    else {
      for (j=0;j<GetInPortRows(block,1);j++) {
	_y1[j]=1.0;
	for (k=0;k<_nin;k++) {
	  if(_ipar[k]>0){
	    uytmp=GetRealInPortPtrs(block,k+1);
	    _y1[j]=_y1[j]*uytmp[j];
	  }else{
	    uytmp=GetRealInPortPtrs(block,k+1);
	    if(uytmp[j]==0){
	      set_block_error(-2);
	      return;
	    }else{
	      uytmp=GetRealInPortPtrs(block,k+1);
	      _y1[j]=_y1[j]/uytmp[j];
	    }
	  }
	}
      }
    }
  }
}
