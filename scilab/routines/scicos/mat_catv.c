# include "scicos_block4.h"
# include "../machine.h"
#include <stdio.h>
#include <memory.h>
extern void matz_catv();
void mat_catv(scicos_block *block,int flag)
{
  int mu,nu,nin,so,pointerposition,ot,i,j;
 ot=GetOutType(block,1);
 nu =GetInPortCols(block,1);
 if (ot== SCSCOMPLEX_N){
   matz_catv(block,flag);
 } 
 else{
   void *u,*y;
   y=GetOutPortPtrs(block,1);
   nin=GetNin(block);
   if ((flag==1) || (flag==6)) {
     pointerposition=0;
     for (j=0;j<nu;j++) {
       for (i=0;i<nin;i++) { 
	 u=GetInPortPtrs(block,i+1);
	 mu=GetInPortRows(block,i+1);
	 so=GetSizeOfIn(block,i+1);
	 memcpy(y+pointerposition,u+j*mu*so,mu*so);
	 pointerposition=pointerposition+mu*so;
       }
     }
   }
 }
}

