#include "scicos_block4.h"
#include <math.h>

void relational_op_i8(scicos_block *block,int flag)
{
  int _ng=GetNg(block);
  double *_g=GetGPtrs(block);
  int *_mode=GetModePtrs(block);
  char *u1,*u2,*y;
  int *ipar;
  int k,i,m,n;
  m=GetInPortRows(block,1);
  n=GetInPortCols(block,1);
  u1=Getint8InPortPtrs(block,1);
  u2=Getint8InPortPtrs(block,2);
  y=Getint8OutPortPtrs(block,1);
  ipar=GetIparPtrs(block);
  if (flag==1)
  {
      if ( _ng!=0 && areModesFixed(block) ) 
	{for(i=0;i<m*n;i++) *(y+i)=_mode[i]-1;}
   else{
	for(i=0;i<m*n;i++) y[i]=0;
	k=ipar[0];
   	switch(k)
		{case 0:
			for(i=0;i<m*n;i++)
			     {if (u1[i]==u2[i]) y[i]=1;}
	 	break;
		case 1:
			for(i=0;i<m*n;i++)
			     {if (u1[i]!=u2[i]) y[i]=1;}
		break;
		case 2:
			for(i=0;i<m*n;i++)
			     {if (u1[i]<u2[i]) y[i]=1;}
		break;
		case 3:
			for(i=0;i<m*n;i++)
			     {if (u1[i]<=u2[i]) y[i]=1;}
		break;
		case 4:
			for(i=0;i<m*n;i++)
			     {if (u1[i]>u2[i]) y[i]=1;}
		break;
		case 5:
			for(i=0;i<m*n;i++)
			     {if (u1[i]>=u2[i]) y[i]=1;}
		break;
		}
	}
  }
  else if (flag==9)
  {for(i=0;i<m*n;i++) _g[i]=*(u1+i)-*(u2+i);
     if (! areModesFixed(block) ) 
	{for(i=0;i<m*n;i++) _mode[i]=(int)1;
	k=ipar[0];
   	switch(k)
		{case 0:
			for(i=0;i<m*n;i++)
			    {if (u1[i]==u2[i]) _mode[i]=(int)2;}
	 	break;
		case 1:
			for(i=0;i<m*n;i++)
			    {if (u1[i]!=u2[i]) _mode[i]=(int)2;}
		break;
		case 2:
			for(i=0;i<m*n;i++)
			    {if (u1[i]<u2[i]) _mode[i]=(int)2;}
		break;
		case 3:
			for(i=0;i<m*n;i++)
			    {if (u1[i]<=u2[i]) _mode[i]=(int)2;}
		break;
		case 4:
			for(i=0;i<m*n;i++)
			    {if (u1[i]>u2[i]) _mode[i]=(int)2;}
		break;
		case 5:
			for(i=0;i<m*n;i++)
			    {if (u1[i]>=u2[i]) _mode[i]=(int)2;}
		break;
		}
	}
  }

}
