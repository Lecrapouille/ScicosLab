#include "scicos_block4.h"
#include <math.h>


void relationalop(scicos_block *block,int flag)
{
  int *_ipar=GetIparPtrs(block);
  int _ng=GetNg(block);
  double *_g=GetGPtrs(block);
  int *_mode=GetModePtrs(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  double *_u2=GetRealInPortPtrs(block,2);
  int i;

  i=_ipar[0];
  if(flag==1){
    if ( _ng!=0 && areModesFixed(block) )  {
      _y1[0]=_mode[0]-1.0;
    }else {
      switch (i)
	{
	case 0:
	  if(_u1[0]==_u2[0]) {
	    _y1[0]=1.0;
	  }else{
	    _y1[0]=0.0;
	  }
	  break;
	  
	case 1:
	  if(_u1[0]!=_u2[0]) {
	    _y1[0]=1.0;
	  }else{
	    _y1[0]=0.0;
	  }
	  break;
	case 2:
	  if(_u1[0]<_u2[0]) {
	    _y1[0]=1.0;
	  }else{
	    _y1[0]=0.0;
	  }
	  break;    
	case 3:
	  if(_u1[0]<=_u2[0]) {
	    _y1[0]=1.0;
	  }else{
	    _y1[0]=0.0;
	  }
	  break;   
	case 4:
	  if(_u1[0]>=_u2[0]) {
	    _y1[0]=1.0;
	  }else{
	    _y1[0]=0.0;
	  }
	  break;   
	case 5:
	  if(_u1[0]>_u2[0]) {
	    _y1[0]=1.0;
	  }else{
	    _y1[0]=0.0;
	  }
	  break;
	}
    }

  }else if(flag==9){
    _g[0]=_u1[0]-_u2[0];
    if (! areModesFixed(block) )  {
      switch (i)
	{
	case 0:
	  if(_u1[0]==_u2[0]) {
	    _mode[0]=(int)2.0;
	  }else{
	    _mode[0]=(int)1.0;
	  }
	  break;
	  
	case 1:
	  if(_u1[0]!=_u2[0]) {
	    _mode[0]=(int)2.0;
	  }else{
	    _mode[0]=(int)1.0;
	  }
	  break;
	case 2:
	  if(_u1[0]<_u2[0]) {
	    _mode[0]=(int)2.0;
	  }else{
	    _mode[0]=(int)1.0;
	  }
	  break;    
	case 3:
	  if(_u1[0]<=_u2[0]) {
	    _mode[0]=(int)2.0;
	  }else{
	    _mode[0]=(int)1.0;
	  }
	  break;   
	case 4:
	  if(_u1[0]>=_u2[0]) {
	    _mode[0]=(int)2.0;
	  }else{
	    _mode[0]=(int)1.0;
	  }
	  break;   
	case 5:
	  if(_u1[0]>_u2[0]) {
	    _mode[0]=(int)2.0;
	  }else{
	    _mode[0]=(int)1.0;
	  }
	  break;
	}
    }
  }
}
