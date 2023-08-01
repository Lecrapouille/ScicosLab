# include "scicos_block4.h"
# include "../machine.h"
# include <math.h>

void shift_32_RC(scicos_block *block,int flag)
{
  SCSINT32_COP *u,*y,v; 
  int *ipar;
  int mu,nu,i,j;
  SCSUINT32_COP k;
  mu=GetInPortRows(block,1);
  nu=GetInPortCols(block,1);
  u=Getint32InPortPtrs(block,1);
  y=Getint32OutPortPtrs(block,1);
  ipar=GetIparPtrs(block);
  k=(SCSUINT32_COP)pow(2,32-1);
  for (i=0;i<mu*nu;i++)
      { v=u[i];
	for(j=0;j<-ipar[0];j++)
	     {
	       y[i]=v&1;
               if (y[i]==0)  
		     {y[i]=v>>1;
		      y[i]=y[i]&(k-1);}
	       else {
	             y[i]=v>>1;
	             y[i]=(y[i])|(k);
	            }
	       v=y[i];
	      }
       }
}
