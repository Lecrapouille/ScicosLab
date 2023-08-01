#include "scicos_block4.h"
#include <math.h>
#include <memory.h>

void  switch2_m(scicos_block *block,int flag)
{
  int _ng=GetNg(block);
  double *_g=GetGPtrs(block);
  int *_mode=GetModePtrs(block);
  // int phase=GetSimulationPhase(block);
  int i=0;
  int ipar,mu,nu,so;
  int *iparptrs;
  double *rpar;
  double *u2;
  void *y,*u;
  iparptrs=GetIparPtrs(block);
  ipar=*iparptrs;
  rpar=GetRparPtrs(block);
  mu=GetInPortRows(block,1);
  nu=GetInPortCols(block,1);
  u2=GetRealInPortPtrs(block,2);
  y=GetOutPortPtrs(block,1);

  if (flag == 1) {
    if (!areModesFixed(phase)  || _ng==0){
      i=3;
      if (ipar==0){
	if (*u2>=*rpar) i=1;
      }else if (ipar==1){
	if (*u2>*rpar) i=1;
      }else {
	if (*u2!=*rpar) i=1; 
      }
    }else{
      if(_mode[0]==1){
	i=1;
      }else if(_mode[0]==2){
	i=3;
      }
    }
    u=GetInPortPtrs(block,i);
    so=GetSizeOfOut(block,1);
    memcpy(y,u,mu*nu*so);
  }else if(flag == 9){
    _g[0]=*u2-*rpar;
    if (!areModesFixed(phase)){
      _mode[0]=2;
      if (ipar==0){
	if (_g[0]>=0.0) _mode[0]=1;
      }else if (ipar==1){
	if (_g[0]>0.0) _mode[0]=1;
      }else {
	if (_g[0]!=0.0) _mode[0]=1;
      }
    }
  }
}
