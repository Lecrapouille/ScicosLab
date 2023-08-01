#include "scicos_block4.h"
#include <math.h>
#include <memory.h>

#define max(a,b) ((a) >= (b) ? (a) : (b))
#define min(a,b) ((a) <= (b) ? (a) : (b))

void  mswitch(scicos_block *block,int flag)
{
  if ((flag==1)||(flag==6)){
    int i,j,nin,so,my,ny;
    int mu,nu;
    int *ipar;
    double *u1;
    void *uj;    
    void *y;
    j=0;
    y=GetOutPortPtrs(block,1);
    so=GetSizeOfOut(block,1);
    my=GetOutPortRows(block,1);
    ny=GetOutPortCols(block,1);
    u1=GetRealInPortPtrs(block,1);
    ipar=GetIparPtrs(block);
    nin=GetNin(block);
    i=*(ipar+1);
    if (i==0) {
      if (*u1>0) {
	j=(int)floor(*u1);
      }else{
	j=(int)ceil(*u1);
      }
    }else if (i==1) {
      if (*u1>0) {
	j=(int)floor(*u1+.5);
      }else{
	j=(int)ceil(*u1-.5);
      }
    }else if (i==2) {
      j=(int)ceil(*u1);
    }else if (i==3) {
      j=(int)floor(*u1);
    }
    j=j+1-*ipar;
    j=max(j,1);
    if (nin==2) {
      mu=GetInPortRows(block,2);
      nu=GetInPortCols(block,2);
      uj=GetInPortPtrs(block,2);
      j=min(j,mu*nu);
      memcpy(y,uj+(j-1)*my*ny*so,my*ny*so);
    } else{
      j=min(j,nin-1);
      uj=GetInPortPtrs(block,j+1);
      memcpy(y,uj,my*ny*so);
    }
  }
}
