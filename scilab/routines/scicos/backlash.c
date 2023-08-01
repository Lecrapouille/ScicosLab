
#include "scicos_block4.h"
#include <math.h>

#ifndef NULL
#define NULL    0
#endif

void backlash(scicos_block *block,int flag)
{ 
  void **_work=GetPtrWorkPtrs(block);
  double *_rpar=GetRparPtrs(block);
  double *_g=GetGPtrs(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  double* rw;
  double t=GetScicosTime(block);

  if (flag == 4){/* the workspace is used to store previous values */
    if ((*_work=	 scicos_malloc(sizeof(double)* 4))== NULL ) {
      set_block_error(-16);
      return;
    }
    rw=*_work; 
    rw[0]=t;
    rw[1]=t;
    rw[2]=_rpar[0];
    rw[3]=_rpar[0];
  }else  if (flag == 5){
    scicos_free(*_work);
  }else  if (flag == 1) {
    rw=*_work;
    if ( !isinTryPhase(block) ){
      if(t>rw[1]) {
	rw[0]=rw[1];
	rw[2]=rw[3];
      }
      rw[1]=t;
      if(_u1[0]>rw[2]+_rpar[1]/2){
	rw[3]=_u1[0]-_rpar[1]/2;
      } else if (_u1[0]<rw[2]-_rpar[1]/2){
	rw[3]=_u1[0]+_rpar[1]/2;
      } else {
	rw[3]=rw[2];
      }
    }
    _y1[0]=rw[3];
  }  else if (flag == 9) {
    rw=*_work;
    if(t>rw[1]){
      _g[0] = _u1[0]-_rpar[1]/2-rw[3];
      _g[1] = _u1[0]+_rpar[1]/2-rw[3];
    }else{
      _g[0] = _u1[0]-_rpar[1]/2-rw[2];
      _g[1] = _u1[0]+_rpar[1]/2-rw[2];
    }
    _g[0] = _u1[0]-_rpar[1]/2-rw[2];
    _g[1] = _u1[0]+_rpar[1]/2-rw[2];
  } 
}
