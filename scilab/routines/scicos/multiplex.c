#include "scicos_block4.h"
#include <memory.h>

void multiplex(scicos_block *block,int flag)
{
  int _nin=GetNin(block);
  int _nout=GetNout(block);
  char *_u1;
  char *_y1;
  char *uytmp;
  int i,k,nui;
  if (_nin==1){
    k=0;
    _u1=GetInPortPtrs(block,1);
    for (i=0;i<_nout;++i){
      nui=GetOutPortRows(block,i+1)*GetSizeOfOut(block,i+1);
      uytmp=GetOutPortPtrs(block,i+1);
      memcpy(uytmp,_u1+k,nui);
      k=k+nui;
    }
  }else {
    k=0;
    _y1=GetOutPortPtrs(block,1);
    for (i=0;i<_nin;++i){
     nui=GetInPortRows(block,i+1)*GetSizeOfIn(block,i+1);
     uytmp=GetInPortPtrs(block,i+1);
     memcpy(_y1+k,uytmp,nui);
     k=k+nui;
    }
  }
}
