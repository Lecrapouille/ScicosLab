#include "scicos_block4.h"


#define DECLARA(type_uy)  \
void absolute_valuei_##type_uy (scicos_block *block,int flag) \
{ \
  type_uy *_u1=GetInPortPtrs(block,1);\
  type_uy *_y1=GetOutPortPtrs(block,1);\
  int i,nxm=GetInPortRows(block,1)*GetInPortCols(block,1);	\
  if (flag == 1) { \
      for(i=0;i<nxm;++i){\
	  if (_u1[i]<0){\
	    _y1[i]=-_u1[i]; \
	  } else{\
	    _y1[i]=_u1[i]; \
	  }\
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


void  absolute_valuei_SCSREAL_COP(scicos_block *block,int flag)
{
  int _ng=GetNg(block);
  double *_g=GetGPtrs(block);
  int *_mode=GetModePtrs(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  int i,side;
  int nxm=GetInPortRows(block,1)*GetInPortCols(block,1);

  switch(flag) 
    {/*----------------------*/
    case 1:
      for(i=0;i<nxm;++i){
	if (!areModesFixed(block) || _ng==0) {
	  if (_u1[i]<0){
	    side=2; 
	  } else{
	    side=1;
	  }
	}else {
	  side=_mode[i];
	}
	if (side==1){
	  _y1[i]=_u1[i];
	} else{
	  _y1[i]=-_u1[i];
	}
      }
      break;
      /*----------------------*/
    case 9:
      for(i=0;i<nxm;++i){
	_g[i]=_u1[i];
	if (!areModesFixed(block)) {
	  if(_g[i]<0){
	    _mode[i]=2;
	  }else{
	    _mode[i]=1;
	  }
	}
      }
    }
}
