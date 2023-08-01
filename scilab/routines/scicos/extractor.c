#include "scicos_block4.h"
#include <math.h>

void extractor(scicos_block *block,int flag)
{
  int *_ipar=GetIparPtrs(block);
  int _nipar=GetNipar(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  int i,j;
  if(flag==1){
    for(i=0;i<_nipar;++i){
      j=_ipar[i]-1;
      if(j<0) j=0;
      if(j>=GetInPortRows(block,1)) j=GetInPortRows(block,1)-1;
      _y1[i]=_u1[j];
    }
  }
}
