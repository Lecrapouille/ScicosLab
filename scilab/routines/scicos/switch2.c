#include "scicos_block4.h"
#include <math.h>

void  switch2(scicos_block *block,int flag)
{
  double *_rpar=GetRparPtrs(block);
  int *_ipar=GetIparPtrs(block);
  int _ng=GetNg(block);
  double *_g=GetGPtrs(block);
  int *_mode=GetModePtrs(block);
  double *_y1=GetRealOutPortPtrs(block,1);
  double *_u2=GetRealInPortPtrs(block,2);
  double *uytmp;
  int i,j;
  // int phase=GetSimulationPhase(block);

  i=0;
  if (flag == 1) {
    if (!areModesFixed(phase) ||_ng==0){
      i=2;
      if (*_ipar==0){
	if (*_u2>=*_rpar) i=0;
      }else if (*_ipar==1){
	if (*_u2>*_rpar) i=0;
      }else {
	if (*_u2!=*_rpar) i=0;			     
      }
    }else{
      if(_mode[0]==1){
	i=0;
      }else if(_mode[0]==2){
	i=2;
      }
    }
    for (j=0;j<GetInPortRows(block,1);j++) {
      uytmp=GetRealInPortPtrs(block,i+1);
      _y1[j]=uytmp[j];
    }
  }else if(flag == 9){
    _g[0]=*_u2-(*_rpar);
    if (!areModesFixed(phase)){
      i=2;
      if (*_ipar==0){
	if (_g[0]>=0.0) i=0;
      }else if (*_ipar==1){
	if (_g[0]>0.0) i=0;
      }else {
	if (_g[0]!=0.0) i=0;			     
      }
      if(i==0) {
	_mode[0]=1;
      }else{
	_mode[0]=2;
      }
    }
  }
}
