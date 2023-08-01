#include <math.h>
#include "scicos_block4.h"
#include <stdio.h>

#ifndef min
#define min(a,b) ((a) <= (b) ? (a) : (b))
#endif

#ifndef max
#define max(a,b) ((a) >= (b) ? (a) : (b))
#endif

void minmax(scicos_block *block,int flag)
{ /*ipar[0]=1 -> min,  ipar[0]=2 -> max */
  int *_ipar=GetIparPtrs(block);
  int _nin=GetNin(block);
  int _ng=GetNg(block);
  double *_g=GetGPtrs(block);
  int *_mode=GetModePtrs(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  double *_u2=GetRealInPortPtrs(block,2);
  double *uytmp;
  int i;
  double maxmin;

  switch(flag)
    {
      /*----------------------------------------*/      
    case 1:
      switch(_nin)
	{ 
	  /*------------------------*/
	case 1:
	  if( _ng==0 || !areModesFixed(block)){
	    maxmin=_u1[0];
	    for (i=1;i<GetInPortRows(block,1);++i){
	      if(_ipar[0]==1){
		if(_u1[i]<maxmin)  maxmin=_u1[i];
	      } else {
		if(_u1[i]>maxmin)  maxmin=_u1[i];
	      }
	    }
	  }else{
	    maxmin=_u1[_mode[0]-1];
	  }

	  _y1[0]=maxmin;
	  break;
	  /*------------------------*/
	case 2:
	  for (i=0;i<GetInPortRows(block,1);++i){
	    if( _ng==0 || !areModesFixed(block)){
	      if(_ipar[0]==1){
		_y1[i]=min(_u1[i],_u2[i]);
	      } else {
		_y1[i]=max(_u1[i],_u2[i]);
	      }
	    }else{
	      uytmp=GetRealInPortPtrs(block,_mode[0]-1+1);
	      _y1[i]=uytmp[i];
	    }
	  }
	  break;
	    /*------------------------*/
	default: break;
	}
      break;
      /*----------------------------------------*/
    case  9:
      switch(_nin)
	{ 
	  /*------------------------*/
	case 1:
	  if (areModesFixed(block)){
	    for (i=0;i<GetInPortRows(block,1);++i){
	      if(i!=_mode[0]-1){
		_g[i]=_u1[i]-_u1[_mode[0]-1];
	      }else{
		_g[i]=1.0;
	      }
	    }
	  } else {
	    maxmin=_u1[0];
	    _mode[0]=1;
	    for (i=1;i<GetInPortRows(block,1);++i){
	      if(_ipar[0]==1){
		if(_u1[i]<maxmin) {
		  maxmin=_u1[i];
		  _mode[0]=i+1;
		}
	      } else {
		if(_u1[i]>maxmin) {
		  maxmin=_u1[i];
		  _mode[0]=i+1;
		}
	      }
	    }
	  }
	  break;
	  /*------------------------*/
	case 2:
	  for (i=0;i<GetInPortRows(block,1);++i){
	    _g[i]=_u1[i]-_u2[i];
	    if (!areModesFixed(block)){
	      if(_ipar[0]==1){
		if(_g[i]>0) {
		  _mode[i]=2;
		}else{
		  _mode[i]=1;
		}
	      }else{
		if(_g[i]<0) {
		  _mode[i]=2;
		}else{
		  _mode[i]=1;
		}
	      }
	    }
	  }
	  break;
	  /*------------------------*/
	default : 
	  break;
	}
      break;
      /*----------------------------------------*/
    default: 
      break;      
    }
}

