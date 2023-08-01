#include "scicos_block4.h"
#include <math.h>

extern void sciprint();

void edgetrig(scicos_block *block,int flag)
{
  int *_ipar=GetIparPtrs(block);
  double *_z=GetDstate(block);
  int _ng=GetNg(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  double z= _z[0],u=_u1[0];
  if(flag==2||flag==6){
    _z[0]=u;
  }else if(flag==1){
    if(_ipar[0]!=0){
      z=z*_ipar[0];
      u=u*_ipar[0];
      if(((z<=0)&(u>0))||((z<0)&(u>=0))) {
	_y1[0]=1.;
      }else{
	_y1[0]=0.;
      }
    } else{ /* rising and falling edge */
      if(((z<=0)&(u>0))||((z<0)&(u>=0))||((z>0)&(u<=0))||((z>=0)&(u<0))){
	_y1[0]=1.;
      }else{
	_y1[0]=0.;
      }
    }
  }else if (flag==4) {
    if (_ng>0){
      set_block_error(-1);
      sciprint("Trigger block must have discrete time input.");
      return;
    }
  }
}
