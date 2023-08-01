#include "scicos_block4.h"

/*     February 2008 */
/*    Copyright INRIA
 *    Scicos block simulator
 */

void diffblk_c(scicos_block *block,int flag)
{
  double *_xd=GetDerState(block);
  double *_x=GetState(block);
  double *_res=GetResState(block);
  double *y,*u;
  int i;
  int* property=GetXpropPtrs(block);
  int nx=GetNstate(block);
    switch(flag)
      {
      case 4  : {
        for (i=0;i<nx;i++) property[i]=-1; /* xproperties*/
        break;
      }

      case 6  : { 
	u=GetRealInPortPtrs(block,1);
	//	for (i=0;i<nx;i++)  _x[i]=u[i];
	break;	
      }

      case 7  : {
	for (i=0;i<nx;i++) property[i]=-1; /* xproperties*/
	break;
      }

      case 0  : {
	u=GetRealInPortPtrs(block,1);
	for (i=0;i<nx;i++) _res[i]=u[i]-_x[i];
	break;
      }

      case 1  : {
	y=GetRealOutPortPtrs(block,1);
	for (i=0;i<nx;i++)  y[i]=_xd[i];
	break;	
      }

      default : break;
      }
}
