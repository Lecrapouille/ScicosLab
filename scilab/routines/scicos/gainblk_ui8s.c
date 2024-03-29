#include <math.h>
#include "../machine.h"
#include "scicos_block4.h"

void gainblk_ui8s(scicos_block *block,int flag)
{
 if ((flag==1)|(flag==6)){
  int i,j,l,ji,jl,il;
  SCSUINT8_COP *u,*y;
  int mu,ny,my,mo,no;
  SCSUINT8_COP *opar;
  double k,D,C;

  mo=GetOparSize(block,1,1);
  no=GetOparSize(block,1,2);
  mu=GetInPortRows(block,1);
  my=GetOutPortRows(block,1);
  ny=GetOutPortCols(block,1);
  u=Getuint8InPortPtrs(block,1);
  y=Getuint8OutPortPtrs(block,1);
  opar=Getuint8OparPtrs(block,1);

  k=pow(2,8);
  if (mo*no==1){
    for (i=0;i<ny*mu;++i){
     D=(double)(opar[0])*(double)(u[i]);
     if (D>=k)  D=k-1;
     else if (D<0) D=0;
     y[i]=(SCSUINT8_COP)D;
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
		    if (D>=k)  D=k-1;
		    else if (D<0) D=0;
		    y[jl]=(SCSUINT8_COP)D;
		  }
	     }
  }
 }
}
