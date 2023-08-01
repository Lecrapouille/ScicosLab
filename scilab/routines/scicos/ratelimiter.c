#include "scicos_block4.h"
#include <math.h>


#ifndef NULL
#define NULL    0
#endif

void ratelimiter(scicos_block *block,int flag)
{/*  rpar[0]=rising rate limit, rpar[1]=falling rate limit */
  void **_work=GetPtrWorkPtrs(block);
  double *_rpar=GetRparPtrs(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  double* pw;
  double rate=0.,t;
  int phase=GetSimulationPhase(block);

  if (flag == 4){/* the workspace is used to store previous values */
    if ((*_work=
	 scicos_malloc(sizeof(double)*4))== NULL ) {
      set_block_error(-16);
      return;
    }
    pw=*_work; 
    pw[0]=0.0;
    pw[1]=0.0;
    pw[2]=0.0;
    pw[3]=0.0;
  }else  if (flag == 5){
    scicos_free(*_work);
  } else if (flag==1) {
    if ( phase==1 ) do_cold_restart();
    pw=*_work; 
    t=GetScicosTime(block);
    if(t>pw[2]){
      pw[0]=pw[2];
      pw[1]=pw[3];
      rate=(_u1[0]-pw[1])/(t-pw[0]);
    }
    else if(t<=pw[2]){
      if(t>pw[0]){
	rate=(_u1[0]-pw[1])/(t-pw[0]);
      }else{
	rate=0.0;
      }
    }
    if(rate>_rpar[0]){
      _y1[0]=(t-pw[0])*_rpar[0]+pw[1];
    } else if(rate<_rpar[1]){
      _y1[0]=(t-pw[0])*_rpar[1]+pw[1];
    }else{
      _y1[0]=_u1[0];
    }
    pw[2]=t;
    pw[3]=_y1[0];
  }
}
