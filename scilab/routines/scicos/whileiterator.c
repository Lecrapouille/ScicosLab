#include "scicos_block4.h"
#include <memory.h>
/*typedef struct{
  int so;
  void **mem;
  }foriter;*/

void whileiterator(scicos_block *block,int flag)
{ 
  void *y,*z;
  int so;
  z=GetOzPtrs(block,1);
  so=GetSizeOfOut(block,1);
  if (flag==1) {
    y=GetOutPortPtrs(block,1);
    memcpy(y,z,so);
  }else if (flag==2){
    if (so==1){
      char *inp;
      inp=(char *)z;
      *inp=*inp+1;
    }else if (so==2){
      SCSINT16_COP *inp;
      inp=(SCSINT16_COP *)z;
      *inp=*inp+1;
    }else if (so==4){
      SCSINT32_COP *inp;
      inp=(SCSINT32_COP *)z;
      *inp=*inp+1;
    }else if (so==8){
      double *inp;
      inp=(double *)z;
      *inp=*inp+1;
    }
  }
}



  
