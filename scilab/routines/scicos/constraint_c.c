#include "scicos_block4.h"

/*     February 2008 */
/*    Copyright INRIA
 *    Scicos block simulator
 */

void constraint_c(scicos_block *block,int flag)
{
  double *_xd=GetDerState(block);
  double *_x=GetState(block);
  double *_res=GetResState(block);
  int *_ipar=GetIparPtrs(block);
  double *y,*y2,*u;
  int i;
  int* property=GetXpropPtrs(block);
  int outsz0=GetOutPortRows(block,1);
    switch(flag)
      {
      case 4  : {
	for (i=0;i<outsz0;i++) property[i]=-1; /* xproperties*/
 	break;
      }

      case 7  : {
	for (i=0;i<outsz0;i++){
	  property[i] = _ipar[i];
	}
	break;
      }

      case 0  : {/* the workspace is used to store discrete counter value */
	u=GetRealInPortPtrs(block,1); 	
	for (i=0;i<outsz0;i++) _res[i]=u[i];	
	break;
      }

      case 1  : { 
	y=GetRealOutPortPtrs(block,1);
	for (i=0;i<outsz0;i++)  y[i]=_x[i];	

	if (GetNout(block)==2) {
	  y2=GetRealOutPortPtrs(block,2);
	  for (i=0;i<outsz0;i++)  y2[i]=_xd[i];
	}
	break;	
      }

      default : break;
      }
}
