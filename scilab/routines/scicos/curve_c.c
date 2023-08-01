#include "scicos_block4.h"

/*    Masoud Najafi, August 2007 */
/*    Copyright INRIA
 *    Scicos block simulator
 *    Signal builder block
 */

#ifndef NULL
#define NULL    0
#endif

int Myevalhermite(double *t, double *xa, double *xb, double *ya, double *yb, double *da, double *db, double *h, double *dh, double *ddh, double *dddh, int *i);

void curve_c(scicos_block *block,int flag)
{
  void **_work=GetPtrWorkPtrs(block);
  double *_rpar=GetRparPtrs(block);
  int *_ipar=GetIparPtrs(block);
  double *_evout= GetNevOutPtrs(block);
  double t,a,b,c,y1,y2,t1,t2;
  int *ind,i,inow;
  double *y;
  double  d1,d2,h, dh, ddh, dddh;
  double *rpar,T;
  int nPoints,Order,Periodic;
  
  rpar= _rpar;
  nPoints=  _ipar[0];
  Order=    _ipar[1];
  Periodic= _ipar[2];
  T= rpar[nPoints-1]-rpar[0];


  switch(flag)
  {
   /* init */
   case 4  : {/* the workspace is used to store discrete counter value */
              if ((*_work=scicos_malloc(4*sizeof(int)))==NULL) {
                set_block_error(-16);
                return;
              }
              ind=*_work;
	      ind[0]=nPoints-1;
	      ind[1]=nPoints;
	      for (i=0;i<nPoints;i++){
		if (rpar[i]>=0 ) {
		  ind[0]=i-1;
		  ind[1]=i;
		  break;
		}
	      }
	      ind[0]=-1;
	      ind[1]=0;
	      ind[2]=0; /* event index */
	      ind[3]=0; /* event counter */
	      return;

              break;
             }
   /* event date computation */
  case 1  : { 
              y=GetRealOutPortPtrs(block,1);
              ind=*_work;
	      t=GetScicosTime(block);

	      if (Periodic==1) {
		if (ind[3]>0)
		  t=t-(ind[3]-1)*T;
	      }
	      
	      if(areModesFixed(block)) {
		inow=ind[1];
	      }else{
		inow=nPoints-1;
		for (i=ind[0];i<nPoints;i++){		
		  if (i==-1) continue;
		  if (t<rpar[i]) {
		    inow=i-1;
		    if (inow>=ind[1]){
		      ind[0]=ind[1];
		    }
		    break;
		  }
		}
		ind[1]=inow;
	      }

	      if (inow<0) {y[0]=0.0;	break;}
	      if (inow>=nPoints-1) {y[0]=rpar[nPoints*2-1];break;}
	      if (Order==0) {
		y[0]=rpar[nPoints+inow];
		break;
	      }
	      if(Order==1) {
		t1=rpar[inow];
		t2=rpar[inow+1];
		y1=rpar[nPoints+inow];
		y2=rpar[nPoints+inow+1];
		y[0]=(y2-y1)*(t-t1)/(t2-t1)+y1;
		break;
	      }

	      if((Order==2)&&(nPoints>2)) {
		t1=rpar[inow];
		a=rpar[2*nPoints+inow];
		b=rpar[2*nPoints+inow+nPoints-1];
		c=rpar[2*nPoints+inow+2*nPoints-2];
		y[0]=a*(t-t1)*(t-t1)+b*(t-t1)+c;
		break;
	      }	     

	      if((Order>=3)) {
		t1=rpar[inow];
		t2=rpar[inow+1];
		y1=rpar[nPoints+inow];
		y2=rpar[nPoints+inow+1];
		d1=rpar[2*nPoints+inow];
		d2=rpar[2*nPoints+inow+1];
		Myevalhermite(&t, &t1,&t2, &y1,&y2, &d1,&d2, &h, &dh, &ddh, &dddh, &inow);
		y[0]=h;
		break;
	      }

              break;
             }
   /* event date computation */
  case 3  : {
              ind=*_work;

	      /*---------*/
	      if ((Order==1)||(Order==0)){
		i=ind[2];
		if (i==nPoints-1){ 
		  if (Periodic==1) {
		    i=0;
		    ind[0]=-1;
		    ind[1]=0;
		  }
		}
		if (i<nPoints-1) {
		  _evout[0]=rpar[i+1]-rpar[i];

		  ind[2]=i+1;
		}
		if (ind[2]==1)  ind[3]++;
	      }
	      /*-------------------*/
	      if (Order>=2){
		if ( Periodic) {
		  _evout[0]=T;
		}else{
		  if (ind[3]==0) {
		    _evout[0]=T;
		  }
		}
		ind[3]++;
		ind[0]=-1;
		ind[1]=0;
		    
	      }
	      break;
             }
  case 2:
	     break;
    /* finish */
   case 5  : {
              scicos_free(*_work); /*free the workspace*/
              break;
             }

   default : break;
  }
}

int Myevalhermite(double *t, double *x1, double *x2, double *y1, double *y2, double *d1, double *d2, double *z, double *dz, double *ddz, double *dddz, int *k)
{
  double Temp, p, p2, p3, D;
  Temp = *t - *x1;
  D = 1.0 / (*x2 - *x1);
  p = (*y2 - *y1) * D;
  p2 = (p - *d1) * D;
  p3 = (*d2 - p + (*d1 - p)) * (D * D);
  *z = p2 + p3 * (*t - *x2);
  *dz = *z + p3 * Temp;
  *ddz = (*dz + p3 * Temp) * 2.;
  *dddz = p3 * 6.0;
  *z = *d1 + *z * Temp;
  *dz = *z + *dz * Temp;
  *z = *y1 + *z * Temp;
  return 0; 
}  

