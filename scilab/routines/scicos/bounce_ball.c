
#include <math.h>
#include "../machine.h"
#include "scicos_block4.h"

void 
bounce_ball(scicos_block *block,int flag)
{
  double *_rpar=GetRparPtrs(block);
  int _nx=GetNstate(block);
  double *_xd=GetDerState(block);
  double *_x=GetState(block);
  int *_ipar=GetIparPtrs(block);
  int *_jroot=GetJrootPtrs(block);
  int _ng=GetNg(block);
  double *_g=GetGPtrs(block);
  int _nevprt=GetNevIn(block);
  double *_y1=GetRealOutPortPtrs(block,1);
  double *_y2=GetRealOutPortPtrs(block,2);

     int nevprt,nx,*ipar;
     double *x,*xd,*rpar;
     double *g;
     int ng;
     int *jroot;
     
     
  int i1;
  double d1, d2, d3;
  
  static double a, b, c;
  static int i, j, k, n;
  static double s1, s2, s3, s4, xsi,*y1,*y2;
  
  /*     Scicos block simulator */
  /*     bouncing ball */
  /*     rpar(i): mass of ball i */
  /*     rpar(i+n): radius of ball i */
  /*     rpar(2n+1:2n+4); [xmin,xmax,ymin,ymax] */
  /*     x: [x1,x1',y1,y1',x2,x2',y2,y2',...,yn'] */
  /*     n:number of ball=ny1=ny2 */
  /*     y1: x-coord des balles */
  /*     y2: y-coord des balles */
  /*     ipar: storage de taille [nx(n-1)/2=ng]*2 */
  nevprt=_nevprt;
  nx=_nx;
  ipar=_ipar;
  x=_x;
  xd=_xd;
  rpar=_rpar;

  g=_g;
  ng=_ng;
  jroot=_jroot;
  /* Parameter adjustments to index vectors as in Scilab (fortran)*/
  --g;
  --ipar;
  --rpar;
  --x;
  --xd;
  y1=_y1;
  y2=_y2;
  --y2;
  --y1;
  --jroot;
  
  n = GetOutPortRows(block,1);
  if (flag == 0) {
    c = rpar[(n << 1) + 6];
    i1 = n;
    for (i = 1; i <= i1; ++i) {
      xd[((i - 1) << 2) + 1] = x[((i - 1) << 2) + 2];
      xd[((i - 1) << 2) + 3] = x[((i - 1) << 2) + 4];
      xd[((i - 1) << 2) + 2] = -c * x[((i - 1) << 2) + 2];
      xd[((i - 1) << 2) + 4] = -rpar[(n << 1) + 5] ;
    }
    
  } else if (flag == 1) {
    i1 = n;
    for (i = 1; i <= i1; ++i) {
      y1[i] = x[((i - 1) << 2) + 1];
      y2[i] = x[((i - 1) << 2) + 3];
    }
  } else if (flag == 9) {
    i1 = ng - (n << 2);
    for (k = 1; k <= i1; ++k) {
      i = ipar[((k - 1) << 1) + 1];
      j = ipar[((k - 1) << 1) + 2];
      d1 = x[((i - 1) << 2) + 1] - x[((j - 1) << 2) + 1];
      d2 = x[((i - 1) << 2) + 3] - x[((j - 1) << 2) + 3];
      d3 = rpar[i + n] + rpar[j + n];
      g[k] = d1 * d1 + d2 * d2 - d3 * d3;
    }
    k = ng - (n << 2) + 1;
    i1 = n;
    for (i = 1; i <= i1; ++i) {
      g[k] = x[((i - 1) << 2) + 3] - rpar[i + n] - rpar[(n << 1) + 3];
      ++k;
      g[k] = rpar[(n << 1) + 4] - x[((i - 1) << 2) + 3] - rpar[i + n];
      ++k;
      g[k] = x[((i - 1) << 2) + 1] - rpar[(n << 1) + 1] - rpar[i + n];
      ++k;
      g[k] = rpar[(n << 1) + 2] - rpar[i + n] - x[((i - 1) << 2) + 1];
      ++k;
    }
    
  } else if (flag == 2 && nevprt < 0) {
    i1 = ng - (n << 2);
    for (k = 1; k <= i1; ++k) {
      if (jroot[k] < 0) {
	i = ipar[((k - 1) << 1) + 1];
	j = ipar[((k - 1) << 1) + 2];
	s1 = x[((j - 1) << 2) + 1] - x[((i - 1) << 2) + 1];
	s2 = -rpar[i] * s1 / rpar[j];
	s3 = x[((j - 1) << 2) + 3] - x[((i - 1) << 2) + 3];
	s4 = -rpar[i] * s3 / rpar[j];
	a = rpar[i] * (s1 * s1 + s3 * s3) + rpar[j] * (s2 * s2 + s4 
						       * s4);
	b = rpar[i] * (s1 * x[((i - 1) << 2) + 2] + s3 * x[((i - 1 )
							  << 2) + 4]) + rpar[j] * (s2 * x[((j - 1) << 2) + 2] + 
										   s4 * x[((j - 1) << 2) + 4]);
	xsi = -(b * 2. / a);
	x[((i - 1) << 2) + 2] += s1 * xsi;
	x[((j - 1) << 2) + 2] += s2 * xsi;
	x[((i - 1) << 2) + 4] += s3 * xsi;
	x[((j - 1) << 2) + 4] += s4 * xsi;
      }
    }
    k = ng - (n << 2) + 1;
    i1 = n;
    for (i = 1; i <= i1; ++i) {
      if (jroot[k] < 0) {
	x[((i - 1) << 2) + 4] = -x[((i - 1) << 2) + 4];
      }
      ++k;
      if (jroot[k] < 0) {
	x[((i - 1) << 2) + 4] = -x[((i - 1) << 2) + 4];
      }
      ++k;
      if (jroot[k] < 0) {
	x[((i - 1) << 2) + 2] = -x[((i - 1) << 2) + 2];
      }
      ++k;
      if (jroot[k] < 0) {
	x[((i - 1) << 2) + 2] = -x[((i - 1) << 2) + 2];
      }
      ++k;
    }
  }
} 
