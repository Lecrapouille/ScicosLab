#include "scicos_block4.h"
#include <math.h>
#include "../machine.h"

#ifndef NULL
#define NULL    0
#endif

extern void sciprint __PARAMS((char *fmt,...));

void time_delay(scicos_block *block,int flag)
{/*  rpar[0]=delay, rpar[1]=init value, ipar[0]=buffer length */
  void **_work=GetPtrWorkPtrs(block);
  double *_rpar=GetRparPtrs(block);
  int *_ipar=GetIparPtrs(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  double* pw,del,t,td,eps;
  int* iw;
  int i,j,k;

  if (flag == 4){/* the workspace is used to store previous values */
    if ((*_work=
	 scicos_malloc(sizeof(int)+sizeof(double)* 
		       _ipar[0]*(1+GetInPortRows(block,1))))== NULL ) {
      set_block_error(-16);
      return;
    }
    eps=1.0e-9; /* shift times to left to avoid replacing 0 */
    pw=*_work; 
    pw[0]=-_rpar[0]*(_ipar[0]-1)-eps;
    for(j=1;j< GetInPortRows(block,1)+1;j++){
	pw[_ipar[0]*j]=_rpar[1];
    }

    for(i=1;i< _ipar[0];i++){
      pw[i]=pw[i-1]+_rpar[0]-eps;
      for(j=1;j< GetInPortRows(block,1)+1;j++){
	pw[i+_ipar[0]*j]=_rpar[1];
      }
    }
    
    iw=(int *)(pw+_ipar[0]*(1+GetInPortRows(block,1)));
    *iw=0;
    for (k=0;k<GetInPortRows(block,1);k++){
	_y1[k]=_rpar[1];
    }
  }else  if (flag == 5){
    scicos_free(*_work);

  } else if (flag==0||flag==2) {
    if (flag==2) DoColdRestart(block);
    pw=*_work; 
    iw=(int *)(pw+_ipar[0]*(1+GetInPortRows(block,1)));
    t=GetScicosTime(block);
    td=t-_rpar[0];
    if(td<pw[*iw]){
      sciprint("delayed time=%f but last stored time=%f \r\n", td, pw[*iw]);
      sciprint("Consider increasing the length of buffer in delay block \r\n");
    }

    if (t>pw[(_ipar[0]+*iw-1)%_ipar[0]]){
      for(j=1;j< GetInPortRows(block,1)+1;j++){
	pw[*iw +_ipar[0]*j]=_u1[j-1];
      }
      pw[*iw]=t;
      /*sciprint("**time is %f. I put %f, in %d \r\n", t,_u1[0],*iw);*/
      *iw=(*iw+1)%_ipar[0];
 
    }else{
      for(j=1;j< GetInPortRows(block,1)+1;j++){
	pw[(_ipar[0]+*iw-1)%_ipar[0] +_ipar[0]*j]=_u1[j-1];
      }
      pw[(_ipar[0]+*iw-1)%_ipar[0]]=t;
      /*sciprint("**time is %f. I put %f, in %d \r\n", t,_u1[0],*iw);*/

    }

  } else if (flag==1) {
    pw=*_work; 
    iw=(int *) (pw+_ipar[0]*(1+GetInPortRows(block,1)));
    t=GetScicosTime(block);

    td=t-_rpar[0];

    i=0;j= _ipar[0]-1;

    while (j-i>1) {
      k=(i+j)/2;
      if (td<pw[(k+*iw)%_ipar[0]]) {
	j=k;
      }else if (td>pw[(k+*iw)%_ipar[0]]) {
	i=k;
      }else{
	i=k;
	j=k;
	break;
      }
    }
    i=(i+*iw)%_ipar[0];
    j=(j+*iw)%_ipar[0];
    del=pw[j]-pw[i];
    /*    sciprint("time is %f. interpolating %d and %d, i.e. %f, %f\r\n", t,i,j,pw[i],pw[j]);
	  sciprint("values are  %f   %f.\r\n",pw[i+_ipar[0]],pw[j+_ipar[0]]);*/
    if(del!=0.0){
      for (k=1;k<GetInPortRows(block,1)+1;k++){
	_y1[k-1]=((pw[j]-td)*pw[i+_ipar[0]*k] +
			       (td-pw[i])*pw[j+_ipar[0]*k])/del;
      }
    }else{
      for (k=1;k<GetInPortRows(block,1)+1;k++){
	_y1[k-1]=pw[i+_ipar[0]*k];
      }
    }
  }
}
