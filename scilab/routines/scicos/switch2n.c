#include "scicos_block4.h"


#define DECLARA(type_u2)				\
  void switch2_##type_u2 (scicos_block *block,int flag)	\
  {						      	\
    int i=0,k,l;					       	\
    int ipar,mu,nu,so,mu2,nu2,j;				\
    int *iparptrs;						\
    type_u2 *thres;						\
    type_u2 *u2;						\
    char *y,*u;							\
    iparptrs=GetIparPtrs(block);				\
    ipar=*iparptrs;						\
    thres=GetOparPtrs(block,1);					\
    mu=GetInPortRows(block,1);					\
    nu=GetInPortCols(block,1);					\
    mu2=GetInPortRows(block,2);					\
    nu2=GetInPortCols(block,2);					\
    u2=GetInPortPtrs(block,2);					\
    y=GetOutPortPtrs(block,1);					\
    so=GetSizeOfOut(block,1);					\
    if (flag == 1) {						\
      if (mu2*nu2==1) so=so*mu*nu;				\
      k=0;							\
      for (j=0;j<mu2*nu2;j++) {				\
	i=3;						\
	if (ipar==0){					\
	  if (u2[j]>=thres[j]) i=1;			\
	}else if (ipar==1){				\
	  if (u2[j]>thres[j]) i=1;			\
	}else {						\
	  if (u2[j]!=thres[j]) i=1;			\
	}						\
	u=GetInPortPtrs(block,i);			\
	for (l=0;l<so;l++){				\
	  y[k+l]=u[k+l];				\
	}						\
	k=k+l;						\
      }\
    }\
  }


 DECLARA(SCSINT32_COP)
 DECLARA(SCSINT16_COP)
 DECLARA(SCSINT8_COP)
 DECLARA(SCSUINT32_COP)
 DECLARA(SCSUINT16_COP)
 DECLARA(SCSUINT8_COP)


#undef DECLARA


void  switch2_SCSREAL_COP(scicos_block *block,int flag)
{
  int _ng=GetNg(block);
  double *_g=GetGPtrs(block);
  int *_mode=GetModePtrs(block);
  // int phase=GetSimulationPhase(block);
  int i=0,j,k,l;
  int ipar,mu,nu,so,mu2,nu2;
  int *iparptrs;
  double *rpar;
  double *u2;
  char *y,*yc=NULL,*u;
  iparptrs=GetIparPtrs(block);
  ipar=*iparptrs;
  rpar=GetRparPtrs(block);
  mu=GetInPortRows(block,1);
  nu=GetInPortCols(block,1);
  mu2=GetInPortRows(block,2);
  nu2=GetInPortCols(block,2);
  u2=GetRealInPortPtrs(block,2);
  y=GetOutPortPtrs(block,1);
  so=GetSizeOfOut(block,1);

  if (flag == 1) {
    if (GetInType(block,1) == SCSCOMPLEX_N)   yc=(char *) GetImagOutPortPtrs(block,1); 
    if (mu2*nu2==1) so=so*mu*nu; /* scalar control input */
    k=0;
    for (j=0;j<mu2*nu2;j++) {
      if (!areModesFixed(phase)  || _ng==0){
	i=3;
	if (ipar==0){
	  if (u2[j]>=rpar[j]) i=1;
	}else if (ipar==1){
	  if (u2[j]>rpar[j]) i=1;
	}else {
	  if (u2[j]!=rpar[j]) i=1; 
	}
      }else{
	if(_mode[j]==1){
	  i=1;
	}else if(_mode[j]==2){
	  i=3;
	}
      }
      u=GetInPortPtrs(block,i);
      for (l=0;l<so;l++){
	y[k+l]=u[k+l];
      }
      if (GetInType(block,1) == SCSCOMPLEX_N) {
        u=(char *) GetImagInPortPtrs(block,i);
	for (l=0;l<so;l++){
	  yc[k+l]=u[k+l];
	}		
      }
      k=k+l;
    }
  }else if(flag == 9){
    for (j=0;j<mu2*nu2;j++) {
      _g[j]=u2[j]-rpar[j];
      if (!areModesFixed(phase)){
	_mode[j]=2;
	if (ipar==0){
	  if (_g[j]>=0.0) _mode[j]=1;
	}else if (ipar==1){
	  if (_g[j]>0.0) _mode[j]=1;
	}else {
	  if (_g[j]!=0.0) _mode[j]=1;
	}
      }
    }
  }
}
