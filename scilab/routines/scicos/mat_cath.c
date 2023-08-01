# include "scicos_block4.h"
# include "../machine.h"
#include <stdio.h>
#include <memory.h>
extern void matz_cath();
void mat_cath(scicos_block *block,int flag)
{
 int mu,nu,nin,so,pointerposition,ot,i;
 ot=GetOutType(block,1);
 mu =GetInPortRows(block,1);
 if (ot== SCSCOMPLEX_N){
   matz_cath(block,flag);
 } 
 else{
   void *u,*y;
   y=GetOutPortPtrs(block,1);
   nin=GetNin(block);
   if ((flag==1) || (flag==6)) {
     pointerposition=0;
     for (i=0;i<nin;i++) { 
       u=GetInPortPtrs(block,i+1);
       nu=GetInPortCols(block,i+1);
       so=GetSizeOfIn(block,i+1);
       memcpy(y+pointerposition,u,mu*nu*so);
       pointerposition=pointerposition+mu*nu*so;
     }
   }
 }
}


