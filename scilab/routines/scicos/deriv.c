#include "scicos_block4.h"
#include <math.h>
#include <stdio.h>

#ifndef NULL
#define NULL    0
#endif

void deriv(scicos_block *block,int flag)
{ 
  void **_work=GetPtrWorkPtrs(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  /* int  nevprt=GetNevIn(block);*/
  double* rw;
  double a0,b0,a1,b1,d,x0,x1,x2,u0,u1,u2;
  int i;
  int nx=GetInPortRows(block,1)*GetInPortCols(block,1);
  double t=GetScicosTime(block);

  if (flag == 4){/* the workspace is used to store previous values */
    if ((*_work= scicos_malloc(sizeof(double)*2*(1+nx)))== NULL ) {
      set_block_error(-16);
      return;
    }
    rw=*_work; 
    rw[0]=t;
    rw[1]=t;
    for(i=0;i<nx;++i){
      rw[2+2*i]=0;
      rw[3+2*i]=0;
    }
  }else  if (flag == 5){
    scicos_free(*_work);
  }else  if (flag == 1 ) {
    rw=*_work;
    x0=rw[0];
    x1=rw[1];
    x2=t;
    for(i=0;i<nx;++i){
      u0=rw[2+2*i];
      u1=rw[3+2*i];
      u2=_u1[i];
      d=(x1-x2)*(x0-x2)*(x1-x0);
      if( d!=0){
	a0=((u2-u1)*(x1-x0)-(x2-x1)*(u1-u0))/d;	    
	a1=a0;
	b0=(u1-u0)/(x1-x0)-a0*(x1-x0);
	b1=2*a0*(x1-x0)+b0;
	_y1[i]=2*a1*(x2-x1)+b1;
      }else{
	if(x2-x1!=0.0) {
	  _y1[i]=(u2-u1)/(x2-x1);
	}else{
	  if(x2-x0!=0.0) {
	    _y1[i]=(u2-u0)/(x2-x0);
	  }else{
	    _y1[i]=0.0;
	  }
	}
      }
    }/* for loop */
    /*fprintf(stderr, "\n\r OUt  =%g", _y1[0]);*/

  } /*  if (flag == 1)  */
  else if (flag == 2 ) { /* called by odoit/ddoit & nevprt <=0 */
    rw=*_work;
    x0=rw[0];
    x1=rw[1];
    x2=t;
    for(i=0;i<nx;++i){
      u0=rw[2+2*i];
      u1=rw[3+2*i];
      u2=_u1[i];

      if (!isinTryPhase(block)){
	  /*--------- memory shifting ------------*/
	  /*fprintf(stderr, "\n\r update  t=%g", t);*/
	  if (x2>=x1){
	    if (x2>x1){
	      rw[0]=x1;
	      rw[2+2*i]=u1;
	    }
	    rw[1]=x2;
	    rw[3+2*i]=u2;
	  }
	}
      /*---------- memory shifting ------------*/
    }
  } /*  if (flag == 2)  */
} 
  
/*
  cubic interpolation "natural"
s0(x)=a0*(x-x0)^3+b0*(x-x0)^2+c0*(x-x0)+u0;
s1(x)=a1*(x-x1)^3+b1*(x-x1)^2+c1*(x-x1)+u1;

constraints:
s0(x1)   = s1(x1)
sp0(x1)  = sp1(x1)
spp0(x1) = spp1(x1)

s1(x2)=u2
Natural method:
spp0(x0) = 0
spp1(x2) = 0

d=2*(x0-x2)*(x0-x1)*(x2-x1)*(x1-x0);
a0=(u2*(x1-x0)+u0*(x2-x1)+u1*(x0-x2))/d;
a1=a0*(x1-x0)/(x1-x2);
b1=3*a0*(x1-x0);
c1=(u2-u1)/(x2-x1)+2*a0*(x1-x2)*(x1-x0);
_y1[i]=3*a1*(x2-x1)*(x2-x1)+2*b1*(x2-x1)+c1;

*/


/*
  squre interpolation "natural"
s0(x)=a0*(x-x0)^2+b0*(x-x0)+u0;
s1(x)=a1*(x-x1)^2+b1*(x-x1)+u1;

constraints:
s0(x1)   = s1(x1)
sp0(x1)  = sp1(x1)
spp0(x1) = spp1(x1)
s1(x2)   = u2

d=(x1-x2)*(x0-x2)*(x1-x0);
a0=((u2-u1)*(x1-x0)-(x2-x1)*(u1-u0))/d;	    
a1=a0;
b0=(u1-u0)/(x1-x0)-a0*(x1-x0);
b1=2*a0*(x1-x0)+b0;
_y1[i]=2*a1*(x2-x1)+b1;
*/
