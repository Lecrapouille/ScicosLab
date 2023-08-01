#include "scicos_block4.h"
#include <math.h>

void logicalop(scicos_block *block,int flag)
{
  int *_ipar=GetIparPtrs(block);
  int _nin=GetNin(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  double *uytmp;
  int i,j,k,l;
  i=_ipar[0];
  switch (i)
    {
    case 0:
      if (_nin==1)
        {
          _y1[0]=1.0;
          for (j=0;j<GetInPortRows(block,1);j++) {
            if(_u1[j]<=0)
              {
                _y1[0]=0.0;
                break;
              }
          }
        }
      else {
        for (j=0;j<GetInPortRows(block,1);j++) {
          _y1[j]=1.0;
          for (k=0;k<_nin;k++) {
            uytmp=GetRealInPortPtrs(block,k+1);
            if(uytmp[j]<=0) {
              _y1[j]=0.0;
              break;
            }
          }
        }
      }
      break;

    case 1:
      if (_nin==1)
        {
          _y1[0]=0.0;
          for (j=0;j<GetInPortRows(block,1);j++) {
            if(_u1[j]>0) {
              _y1[0]=1.0;
              break;
            }
          }
        }
      else {
        for (j=0;j<GetInPortRows(block,1);j++) {
          _y1[j]=0.0;
          for (k=0;k<_nin;k++) {
            uytmp=GetRealInPortPtrs(block,k+1);
            if(uytmp[j]>0) {
              _y1[j]=1.0;
              break;
            }
          }
        }
      }
      break;

    case 2:
      if (_nin==1)
        {
          _y1[0]=0.0;
          for (j=0;j<GetInPortRows(block,1);j++) {
            if(_u1[j]<=0)
              {
                _y1[0]=1.0;
                break;
              }
          }
        }
      else {
        for (j=0;j<GetInPortRows(block,1);j++) {
          _y1[j]=0.0;
          for (k=0;k<_nin;k++) {
            uytmp=GetRealInPortPtrs(block,k+1);
            if(uytmp[j]<=0) {
              _y1[j]=1.0;
              break;
            }
          }
        }
      }
      break;

    case 3:
      if (_nin==1)
        {
          _y1[0]=1.0;
          for (j=0;j<GetInPortRows(block,1);j++) {
            if(_u1[j]>0) {
              _y1[0]=0.0;
              break;
            }
          }
        }
      else {
        for (j=0;j<GetInPortRows(block,1);j++) {
          _y1[j]=1.0;
          for (k=0;k<_nin;k++) {
            uytmp=GetRealInPortPtrs(block,k+1);
            if(uytmp[j]>0) {
              _y1[j]=0.0;
              break;
            }
          }
        }
      }
      break;

    case 4:
      if (_nin==1)
        {
          l=0;
          for (j=0;j<GetInPortRows(block,1);j++) {
            if(_u1[j]>0) {
              l=(l+1)%2;
            }
          }
          _y1[0]=(double) l;
        }
      else {
        for (j=0;j<GetInPortRows(block,1);j++) {
          l=0;
          for (k=0;k<_nin;k++) {
            uytmp=GetRealInPortPtrs(block,k+1);
            if(uytmp[j]>0) {
              l=(l+1)%2;
            }
          }
          _y1[j]=(double) l;
        }
      }
      break;

    case 5:
      for (j=0;j<GetInPortRows(block,1);j++) {
        if(_u1[j]>0) {
          _y1[j]=0.0;
        }
        else{
          _y1[j]=1.0;
        }
      }
      break;

    case 6:
      if (_nin==1)
        {
          l=1;
          for (j=0;j<GetInPortRows(block,1);j++) {
            if(_u1[j]>0) {
              l=(l+1)%2;
            }
          }
          _y1[0]=(double) l;
        }
      else {
        for (j=0;j<GetInPortRows(block,1);j++) {
          l=1;
          for (k=0;k<_nin;k++) {
            uytmp=GetRealInPortPtrs(block,k+1);
            if(uytmp[j]>0) {
              l=(l+1)%2;
            }
          }
          _y1[j]=(double) l;
        }
      }
      break;

    }
}
