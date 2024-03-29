#include "scicos_block4.h"
#include <math.h>
#if WIN32
#include <float.h>
#endif

#if defined(solaris)
#include <ieeefp.h>
int isinf(double x) { return !finite(x) && x==x; }
#endif
#if defined(__alpha)
int isinf(double x) { return !finite(x) && x==x; }
#endif

#ifndef min
#define min(a,b) ((a) <= (b) ? (a) : (b))
#endif

#ifndef max
#define max(a,b) ((a) >= (b) ? (a) : (b))
#endif

#if WIN32
/*
arcsinh z = log (z+sqrt(1+z2))
*/
double asinh(double x)
{
  return log(x+sqrt(x*x+1));
}

double acosh(double x)
{
  return log(x+sqrt(x*x-1));
}

/*
Inverse hyperbolic tangent (Atanh(x)) Log((1 + x) / (1 � x)) / 2 
*/
double atanh(double x)
{
	return (double)(log ((1.+x)/(1.-x))/2);
}
#endif

void evaluate_expr(scicos_block *block,int flag)
{
  double *_rpar=GetRparPtrs(block);
  int *_ipar=GetIparPtrs(block);
  int _nin=GetNin(block);
  int _ng=GetNg(block);
  double *_g=GetGPtrs(block);
  int *_mode=GetModePtrs(block);
  int _nipar=GetNipar(block);
  double *_u1=GetRealInPortPtrs(block,1);
  double *_y1=GetRealOutPortPtrs(block,1);
  double *uytmp;
  static double stack [1000];
  static int count,bottom,nzcr,i; 
  int j;  
  if (flag==1||flag==6||flag==9){

    bottom=-1;
    count=-1;
    nzcr=-1;
    while (count<_nipar-1){
      count=count+1;
      switch (_ipar[count]) {
      case 2:
	count=count+1;
	bottom=bottom+1;
	if(bottom>999){
	  set_block_error(-16);
	  return;
	}
	if (_nin>1){
	  uytmp=GetRealInPortPtrs(block,_ipar[count]-1+1);
	  stack[bottom]=uytmp[0];
	}else{
	  j=_ipar[count]-1;
	  if (j<GetInPortRows(block,1)){
	    stack[bottom]=_u1[_ipar[count]-1];
	  }else{
	    stack[bottom]=0.;
	  }
	}
	break;
      case 6:
	count=count+1;
	bottom=bottom+1;
	if(bottom>999){
	  set_block_error(-16);
	  return;
	}
	stack[bottom]=_rpar[_ipar[count]-1];
	break;
      case 5:
	count=count+1;
	switch (_ipar[count]) {
	case 1:
	  stack[bottom-1]=stack[bottom-1]+stack[bottom];
	  bottom=bottom-1;
	  break;
	case 2:
	  stack[bottom-1]=stack[bottom-1]-stack[bottom];
	  bottom=bottom-1;
	  break;
	case 3:
	  stack[bottom-1]=stack[bottom-1]*stack[bottom];
	  bottom=bottom-1;
	  break;
	case 7:
	  stack[bottom-1]=stack[bottom-1]/stack[bottom];
	  bottom=bottom-1;
	  break;
	case 15:
	  stack[bottom-1]=pow(stack[bottom-1],stack[bottom]);
	  bottom=bottom-1;
	  break;
	case 16: /* case == */
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    _g[nzcr]=stack[bottom-1]-stack[bottom];
	    if(!areModesFixed(block)) {
	      _mode[nzcr]=(stack[bottom-1]==stack[bottom]);
	    }
	  }
	  if(!areModesFixed(block)||_ng==0){
	    i=(stack[bottom-1]==stack[bottom]);
	  } else{
	    i=_mode[nzcr];
	  }
	  stack[bottom-1]=(double)i;
	  bottom=bottom-1;
	  break;

	case 17:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    _g[nzcr]=stack[bottom-1]-stack[bottom];
	    if(!areModesFixed(block)) {
	      _mode[nzcr]=(stack[bottom-1]<stack[bottom]);
	    }
	  }
	  if(!areModesFixed(block)||_ng==0){
	    i=(stack[bottom-1]<stack[bottom]);
	  } else{
	    i=_mode[nzcr];
	  }
	  stack[bottom-1]=(double)i;
	  bottom=bottom-1;
	  break;
	case 18:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    _g[nzcr]=stack[bottom-1]-stack[bottom];
	    if(!areModesFixed(block)) {
	      _mode[nzcr]=(stack[bottom-1]>stack[bottom]);
	    }
	  }
	  if(!areModesFixed(block)||_ng==0){
	    i=(stack[bottom-1]>stack[bottom]);
	  } else{
	    i=_mode[nzcr];
	  }
	  stack[bottom-1]=(double)i;
	  bottom=bottom-1;
	  break;
	case 19:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    _g[nzcr]=stack[bottom-1]-stack[bottom];
	    if(!areModesFixed(block)) {
	      _mode[nzcr]=(stack[bottom-1]<=stack[bottom]);
	    }
	  }
	  if(!areModesFixed(block)||_ng==0){
	    i=(stack[bottom-1]<=stack[bottom]);
	  } else{
	    i=_mode[nzcr];
	  }
	  stack[bottom-1]=(double)i;
	  bottom=bottom-1;
	  break;
	case 20:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    _g[nzcr]=stack[bottom-1]-stack[bottom];
	    if(!areModesFixed(block)) {
	      _mode[nzcr]=(stack[bottom-1]>=stack[bottom]);
	    }
	  }
	  if(!areModesFixed(block)||_ng==0){
	    i=(stack[bottom-1]>=stack[bottom]);
	  } else{
	    i=_mode[nzcr];
	  }
	  stack[bottom-1]=(double)i;
	  bottom=bottom-1;
	  break;
	case 21:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    _g[nzcr]=stack[bottom-1]-stack[bottom];
	    if(!areModesFixed(block)) {
	      _mode[nzcr]=(stack[bottom-1]!=stack[bottom]);
	    }
	  }
	  if(!areModesFixed(block)||_ng==0){
	    i=(stack[bottom-1]!=stack[bottom]);
	  } else{
	    i=_mode[nzcr];
	  }
	  stack[bottom-1]=(double)i;
	  bottom=bottom-1;
	  break;
	case 28:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    _g[nzcr]=stack[bottom-1]-stack[bottom];
	    if(!areModesFixed(block)) {
	      _mode[nzcr]=((int)stack[bottom-1]||(int)stack[bottom]);
	    }
	  }
	  if(!areModesFixed(block)||_ng==0){
	    i=((int)stack[bottom-1]||(int)stack[bottom]);
	  } else{
	    i=_mode[nzcr];
	  }
	  stack[bottom-1]=(double)i;
	  bottom=bottom-1;
	  break;
	case 29:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    _g[nzcr]=stack[bottom-1]-stack[bottom];
	    if(!areModesFixed(block)) {
	      _mode[nzcr]=((int)stack[bottom-1]&&(int)stack[bottom]);
	    }
	  }
	  if(!areModesFixed(block)||_ng==0){
	    i=((int)stack[bottom-1]&&(int)stack[bottom]);
	  } else{
	    i=_mode[nzcr];
	  }
	  stack[bottom-1]=(double)i;
	  bottom=bottom-1;
	  break;

	case 30:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    _g[nzcr]=stack[bottom];
	    if(!areModesFixed(block)) {
	      _mode[nzcr]=(0.0==stack[bottom]);
	    }
	  }
	  if(!areModesFixed(block)||_ng==0){
	    i=(stack[bottom]==0.0);
	  }else{
	    i=_mode[nzcr];
	  }
	  if (i){
	    stack[bottom]=1.0;
	  }else{
	    stack[bottom]=0.0;   
	  }
	  break;
	case 99:
	  stack[bottom]=-stack[bottom];
	  break;
	case 101:
	  stack[bottom]=sin(stack[bottom]);
	  break;
	case 102:
	  stack[bottom]=cos(stack[bottom]);
	  break;
	case 103:
	  stack[bottom]=tan(stack[bottom]);
	  break;
	case 104:
	  stack[bottom]=exp(stack[bottom]);
	  break;
	case 105:
	  stack[bottom]=log(stack[bottom]);
	  break;
	case 106:
	  stack[bottom]=sinh(stack[bottom]);
	  break;
	case 107:
	  stack[bottom]=cosh(stack[bottom]);
	  break;
	case 108:
	  stack[bottom]=tanh(stack[bottom]);
	  break;

	case 109:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    if (stack[bottom]>0) {
	      i=(int)floor(stack[bottom]);
	    }else{
	      i=(int)ceil(stack[bottom]);
	    }
	    if(i==0)  {
	      _g[nzcr]=(stack[bottom]-1)*(stack[bottom]+1);
	    }else if(i>0){
	      _g[nzcr]=(stack[bottom]-i-1.)*(stack[bottom]-i);
	    }else{
	      _g[nzcr]=(stack[bottom]-i)*(stack[bottom]-i+1);
	    }
	    if(i%2)  _g[nzcr]=-_g[nzcr];
	     if(!areModesFixed(block)) _mode[nzcr]=i;
	  }
	  if(!areModesFixed(block)||_ng==0){
	    if (stack[bottom]>0) {
	      stack[bottom]=floor(stack[bottom]);
	    }else{
	      stack[bottom]=ceil(stack[bottom]);
	    }
	  }else{
	    stack[bottom]=(double) _mode[nzcr];
	  }
	  break;
	  /*
	  if (stack[bottom]>0) {
	    stack[bottom]=floor(stack[bottom]);
	  }else{
	    stack[bottom]=ceil(stack[bottom]);
	    }*/
	  break;
	case 110:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    if (stack[bottom]>0) {
	      i=(int)floor(stack[bottom]+.5);
	    }else{
	      i=(int)ceil(stack[bottom]-.5);
	    }
	    _g[nzcr]=(stack[bottom]-i-.5)*(stack[bottom]-i+.5);
	    if(i%2)  _g[nzcr]=-_g[nzcr];
	    if(!areModesFixed(block))  _mode[nzcr]=i;
	  }
	  if(!areModesFixed(block)||_ng==0){
	    if (stack[bottom]>0) {
	      stack[bottom]=floor(stack[bottom]+.5);
	    }else{
	      stack[bottom]=ceil(stack[bottom]-.5);
	    }
	  }else{
	    stack[bottom]=(double) _mode[nzcr];
	  }
	  break;
	  /*  if (stack[bottom]>0) {
	    stack[bottom]=floor(stack[bottom]+.5);
	  }else{
	    stack[bottom]=ceil(stack[bottom]-.5);
	  }*/
	case 111:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    i=(int)ceil(stack[bottom]);
	    _g[nzcr]=(stack[bottom]-i)*(stack[bottom]-i+1);
	    if(i%2)  _g[nzcr]=-_g[nzcr];
	    if(!areModesFixed(block))_mode[nzcr]=i;
	  }
	  if(!areModesFixed(block)||_ng==0){
	    stack[bottom]=ceil(stack[bottom]);
	  }else{
	    stack[bottom]=(double) _mode[nzcr];
	  }
	  break;
	case 112:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    i=(int)floor(stack[bottom]);
	    _g[nzcr]=(stack[bottom]-i-1)*(stack[bottom]-i);
	    if(i%2)  _g[nzcr]=-_g[nzcr];
	    if(!areModesFixed(block))_mode[nzcr]=i;
	  }
	  if(!areModesFixed(block)||_ng==0){
	    stack[bottom]=floor(stack[bottom]);
	  }else{
	    stack[bottom]=(double) _mode[nzcr];
	  }
	  break;
	case 113:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    if (stack[bottom]>0) {
	      i=1;
	    }else if (stack[bottom]<0){
	      i=-1;
	    }else{
	      i=0;
	    }
	    _g[nzcr]=stack[bottom];
	    if(!areModesFixed(block))_mode[nzcr]=i;
	  }
	  if(!areModesFixed(block)||_ng==0){
	    if (stack[bottom]>0) {
	      stack[bottom]=1.0;
	    }else if(stack[bottom]<0){
	      stack[bottom]=-1.0;
	    }else{
	      stack[bottom]=0.0;
	    }
	  }else{
	    stack[bottom]=(double) _mode[nzcr];
	  }
	  break;
	  /* if (stack[bottom]>0) {
	    stack[bottom]=1.0;
	  }else if(stack[bottom]<0){
	    stack[bottom]=-1.0;
	  }else{
	    stack[bottom]=0.0;
	    }*/
	case 114:  /* abs */
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    if (stack[bottom]>0) {
	      i=1;
	    }else if (stack[bottom]<0){
	      i=-1;
	    }else{
	      i=0;
	    }
	    _g[nzcr]=stack[bottom];
	    if(!areModesFixed(block))_mode[nzcr]=i;
	  }
	  if(!areModesFixed(block)||_ng==0){
	    if (stack[bottom]>0) {
	      stack[bottom]=stack[bottom];
	    }else {
	      stack[bottom]=-stack[bottom];
	    }
	  }else{
	    stack[bottom]=stack[bottom]*(_mode[nzcr]);
	  }
	  break;
	  /* if (stack[bottom]>0) {
	    stack[bottom]=stack[bottom];
	  }else {
	    stack[bottom]=-stack[bottom];
	    }*/
	case 115:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    if (stack[bottom]>stack[bottom-1]) {
	      i=0;
	    }else {
	      i=1;
	    }
	    _g[nzcr]=stack[bottom]-stack[bottom-1];
	    if(!areModesFixed(block))_mode[nzcr]=i;
	  }
	  if(!areModesFixed(block)||_ng==0){
	    stack[bottom-1]=max(stack[bottom-1],stack[bottom]);
	  }else{
	    stack[bottom-1]=stack[bottom-_mode[nzcr]];
	  }
	  bottom=bottom-1;
	  break;
	case 116:
	  if(_ng>0) nzcr=nzcr+1;
	  if (flag==9) {
	    if (stack[bottom]<stack[bottom-1]) {
	      i=0;
	    }else {
	      i=1;
	    }
	    _g[nzcr]=stack[bottom]-stack[bottom-1];
	    if(!areModesFixed(block))_mode[nzcr]=i;
	  }
	  if(!areModesFixed(block)||_ng==0){
	    stack[bottom-1]=min(stack[bottom-1],stack[bottom]);
	  }else{
	    stack[bottom-1]=stack[bottom-_mode[nzcr]];
	  }
	  bottom=bottom-1;
	  break;
	case 117:
	  stack[bottom]=asin(stack[bottom]);
	  break;
	case 118:
	  stack[bottom]=acos(stack[bottom]);
	  break;
	case 119:
	  stack[bottom]=atan(stack[bottom]);
	  break;
	case 120:
	  stack[bottom]=asinh(stack[bottom]);
	  break;
	case 121:
	  stack[bottom]=acosh(stack[bottom]);
	  break;
	case 122:
	  stack[bottom]=atanh(stack[bottom]);
	  break;
	case 123:
	  stack[bottom-1]=atan2(stack[bottom-1],stack[bottom]);
	  bottom=bottom-1;
	  break;

	case 124:
	  stack[bottom]=log10(stack[bottom]);
	  break;
	}
      }
    }
    #if WIN32
    if(!_finite(stack[bottom])||_isnan(stack[bottom])){
    #else
     if(isinf(stack[bottom])||isnan(stack[bottom])){
    #endif
      if (flag==6) return;
      set_block_error(-2);
      return;
    }else{
      _y1[0]=stack[bottom];
    }
  }
}
