#include <math.h>
#include "../machine.h"
#include "scicos_block4.h"

void gainblk_i32n(scicos_block *block,int flag)
{
 if ((flag==1)|(flag==6)){
  int i,j,l,ji,jl,il;
  SCSINT32_COP *u,*y;
  int mu,ny,my,mo,no;
  SCSINT32_COP *opar;
  double k,D,C,t;

  mo=GetOparSize(block,1,1);
  no=GetOparSize(block,1,2);
  mu=GetInPortRows(block,1);
  my=GetOutPortRows(block,1);
  ny=GetOutPortCols(block,1);
  u=Getint32InPortPtrs(block,1);
  y=Getint32OutPortPtrs(block,1);
  opar=Getint32OparPtrs(block,1);

  k=pow(2,32);
  if (mo*no==1){
    for (i=0;i<ny*mu;++i){
     D=(double)(opar[0])*(double)(u[i]);
     t=D-(double)((int)(D/(k)))*((k));
     if ((t>=k/2)|(-(t)>=k/2))
         {if (t>=0) (t)=(-((k/2))+fabs(t-(double)((int)((t)/((k/2))))*((k/2))));
	  else (t)=-(-((k/2))+fabs(t-(double)((int)((t)/((k/2))))*((k/2))));}
     y[i]=(SCSINT32_COP)t;
    }
  }else{
     for (l=0;l<ny;l++)
	 {for (j=0;j<my;j++)
	      {D=0;
               jl=j+l*my;
	       for (i=0;i<mu;i++)
		   {ji=j+i*my;
		    il=i+l*mu;
		    C=(double)(opar[ji])*(double)(u[il]);
		    D=D + C;}
		    t=D-(double)((int)(D/(k)))*((k));
		    if ((t>=k/2)|(-(t)>=k/2))
		       {if (t>=0) (t)=(-((k/2))+fabs(t-(double)((int)((t)/((k/2))))*((k/2))));
			else (t)=-(-((k/2))+fabs(t-(double)((int)((t)/((k/2))))*((k/2))));}
		    y[jl]=(SCSINT32_COP)t;
		  }
	     }
  }
 }
}
