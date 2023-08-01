/*
 * Copyright (c) 2004, Ernst Hairer
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are 
 * met:
 * 
 * - Redistributions of source code must retain the above copyright 
 * notice, this list of conditions and the following disclaimer.
 * 
 * - Redistributions in binary form must reproduce the above copyright 
 * notice, this list of conditions and the following disclaimer in the 
 * documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS 
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR 
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The DOPRI5 code was modified by Masoud NAAJFI Mars 2009
 * Copyright INRIA
 * New options in the code:
 *  a modular structured  code
 *  ZERO_Crossing
 *  TSTOP setting and dense output
 * 
 */

#include <math.h>
#include <stdio.h>

#ifdef __STDC__
#include <stdlib.h>
#else 
#ifndef WIN32
#include <malloc.h>
#endif
#endif 

#include <limits.h>
#include <memory.h>
#include "dopri5m.h"
#include <stdlib.h>

#define RTFOUND          +1
#define INITROOT         +2
#define CLOSERT          +3
#define ZERODETACHING    +4
#define MASKED           55

#define HUN    (100.0) 
#define ZERO    (0.0)  
#define ONE    (1.0)  
#define TWO    (2.0)  
#define HALF    (0.5)  
#define FIVE    (5.0)  
#define TENTH   (0.1)
#define FALSE 0
#define TRUE  1
#define booleantype int
#define abs(x) ((x) >= 0 ? (x) : -(x))

static double sign (double a, double b){ return (b > 0.0) ? fabs(a) : -fabs(a);} 
static double min_d (double a, double b){  return (a < b)?a:b;}
static double max_d (double a, double b){  return (a > b)?a:b;} 

/*
  #define rcont1 dopri5_mem->rcont1
  #define rcont2 dopri5_mem->rcont2
  #define rcont3 dopri5_mem->rcont3
  #define rcont4 dopri5_mem->rcont4
  #define rcont5 dopri5_mem->rcont5
  #define x      dopri5_mem->x 
  #define xstop  dopri5_mem->xstop 
  #define y      dopri5_mem->y 
  #define yy1    dopri5_mem->yy1 
  #define ysti   dopri5_mem->ysti 
  #define k1     dopri5_mem->k1 
  #define k2     dopri5_mem->k2 
  #define k3     dopri5_mem->k3 
  #define k4     dopri5_mem->k4 
  #define k5     dopri5_mem->k5 
  #define k6     dopri5_mem->k6 
  #define atoler dopri5_mem->atoler 
  #define rtoler dopri5_mem->rtoler 
  #define itoler dopri5_mem->itoler 
  #define h      dopri5_mem->h 
  #define hmax   dopri5_mem->hmax 
  #define facold dopri5_mem->facold 
  #define meth   dopri5_mem->meth 
  #define nstep  dopri5_mem->nstep 
  #define nfcn   dopri5_mem->nfcn 
  #define naccpt dopri5_mem->naccpt 
  #define nrejct dopri5_mem->nrejct 
  #define uround dopri5_mem->uround 
  #define n      dopri5_mem->n 
  #define fileout dopri5_mem->fileout 
  #define nmax   dopri5_mem->nmax 
  #define nstiff dopri5_mem->nstiff 
  #define nonsti dopri5_mem->nonsti 
  #define fcn    dopri5_mem->fcn 
  #define iasti  dopri5_mem->iasti 
  #define beta   dopri5_mem->beta 
  #define safe   dopri5_mem->safe 
  #define fac2   dopri5_mem->fac2 
  #define fac1   dopri5_mem->fac1 
*/

static int DP5Rootfind(DOPRI5_mem *dopri5_mem);

#if 0
static long nfcnRead (DOPRI5_mem *dopri5_mem)
{
  return dopri5_mem->nfcn;
}

static long nstepRead (DOPRI5_mem *dopri5_mem)
{
  return dopri5_mem->nstep;
}

static long naccptRead (DOPRI5_mem *dopri5_mem)
{
  return dopri5_mem->naccpt;
}

static long nrejctRead (DOPRI5_mem *dopri5_mem)
{
  return dopri5_mem->nrejct;
}

static double hRead (DOPRI5_mem *dopri5_mem)
{
  return dopri5_mem->h;
}

static double xRead (DOPRI5_mem *dopri5_mem)
{
  return dopri5_mem->x;
}
#endif

int DP5_set_tstop (DOPRI5_mem *dopri5_mem, double xstop)
{
  if (dopri5_mem==NULL) return -1;
  else {
    dopri5_mem->xstop=xstop;
    return 0;
  }
}

int DP5_Get_RootInfo (DOPRI5_mem *dopri5_mem, int *jroot)
{
    memcpy (jroot, dopri5_mem->iroots, dopri5_mem->ng * sizeof(int));
    return 0;
}

int DP5_Get_fcallerid(DOPRI5_mem *dopri5_mem,  int *fcallerid)
{
  if (dopri5_mem==NULL) return -1;
  else {
    (*fcallerid)=dopri5_mem->fcallerid;
    return 0;
  }
}

/********************************************************
**********************************************************/

static double hinit (DOPRI5_mem *dopri5_mem, int iord)
{
  double   dnf, dny, atoli, rtoli, sk, h, h1, der2, der12, sqr;
  unsigned i;

  dnf = 0.0;
  dny = 0.0;
  atoli = dopri5_mem->atoler[0];
  rtoli = dopri5_mem->rtoler;
  if (!dopri5_mem->itoler)
    for (i = 0; i < dopri5_mem->n; i++)
      {
	sk = atoli + rtoli * fabs(dopri5_mem->y[i]);
	sqr = dopri5_mem->k1[i] / sk;
	dnf += sqr*sqr;
	sqr = dopri5_mem->y[i] / sk;
	dny += sqr*sqr;
      }
  else
    for (i = 0; i < dopri5_mem->n; i++)
      {
	sk =dopri5_mem->atoler[i] + dopri5_mem->rtoler * fabs(dopri5_mem->y[i]);
	sqr = dopri5_mem->k1[i] / sk;
	dnf += sqr*sqr;
	sqr = dopri5_mem->y[i] / sk;
	dny += sqr*sqr;
      }

  if ((dnf <= 1.0E-10) || (dny <= 1.0E-10))
    h = 1.0E-6;
  else
    h = sqrt (dny/dnf) * 0.01;

  h = min_d (h, dopri5_mem->hmax);
  h = sign (h, dopri5_mem->posneg);

  /* perform an explicit Euler step */
  for (i = 0; i < dopri5_mem->n; i++)
    dopri5_mem->k3[i] =dopri5_mem->y[i] + h * dopri5_mem->k1[i];
  dopri5_mem->fcallerid=-2;
  dopri5_mem->fcn (dopri5_mem->n, dopri5_mem->x+h, dopri5_mem->k3, dopri5_mem->k2, dopri5_mem->udata);

  /* estimate the second derivative of the solution */
  der2 = 0.0;
  if (!dopri5_mem->itoler)
    for (i = 0; i <dopri5_mem-> n; i++)
      {
	sk = atoli + rtoli * fabs(dopri5_mem->y[i]);
	sqr = (dopri5_mem->k2[i] - dopri5_mem->k1[i]) / sk;
	der2 += sqr*sqr;
      }
  else
    for (i = 0; i <dopri5_mem-> n; i++)
      {
	sk = dopri5_mem->atoler[i] + dopri5_mem->rtoler * fabs(dopri5_mem->y[i]);
	sqr = (dopri5_mem->k2[i] - dopri5_mem->k1[i]) / sk;
	der2 += sqr*sqr;
      }
  der2 = sqrt (der2) / h;

  /* step size is computed such that h**iord * max_d(norm(k1),norm(der2)) = 0.01 */
  der12 = max_d (fabs(der2), sqrt(dnf));
  if (der12 <= 1.0E-15)
    h1 = max_d (1.0E-6, fabs(h)*1.0E-3);
  else
    h1 = pow (0.01/der12, 1.0/(double)iord);
  h = min_d (100.0 * h, min_d (h1, dopri5_mem->hmax));

  return sign (h, dopri5_mem->posneg);

} /* hinit */

/********************************************************
**********************************************************/

/* dense output function */
static double contd5 (DOPRI5_mem *dopri5_mem, unsigned i, double x, double xold, double h_old)
{
  double   theta, theta1;

  theta = (x - xold) / h_old;
  theta1 = 1.0 - theta;

  return   dopri5_mem->rcont1[i] + theta*(dopri5_mem->rcont2[i] + theta1*(dopri5_mem->rcont3[i] + theta*(dopri5_mem->rcont4[i] + theta1*dopri5_mem->rcont5[i])));

} /* contd5 */

static int DP5Rcheck1(DOPRI5_mem *dopri5_mem)
{
  int  retval;
  unsigned i;
  /* booleantype zroot; */
  for (i = 0; i < dopri5_mem->ng; i++) dopri5_mem->iroots[i] = 0;

  dopri5_mem->tlo = dopri5_mem->x;
  dopri5_mem->ttol = (abs(dopri5_mem->x) + abs(dopri5_mem->h))*(dopri5_mem->uround)*HUN;
  dopri5_mem->irfnd = 0;
  /* Evaluate g at initial t and check for zero values. */
  retval = dopri5_mem->gcn(dopri5_mem->ng, dopri5_mem->tlo, dopri5_mem->y, dopri5_mem->glo,dopri5_mem->udata);
  if (retval != 0) return(DP5_RTFUNC_FAIL);

  /* zroot = FALSE; */
  for (i = 0; i < dopri5_mem->ng; i++) {
    if (abs(dopri5_mem->glo[i]) == ZERO)
      dopri5_mem->iroots[i] =MASKED; /* arbitrary choice*/
    else 
      dopri5_mem->iroots[i] =0;
  }
  return(DP5_SUCCESS);
  /* Some g_i is zero at t0; look at g at t0+(small increment). */
} 


static int DP5Rcheck2(DOPRI5_mem *dopri5_mem)
{
  int  retval;
  unsigned i;

  if (dopri5_mem->irfnd == 0) return(DP5_SUCCESS);/* No sign change in glo=> no need to update glo*/

  if (dopri5_mem->n>0){
    for (i = 0; i < dopri5_mem->n; i++)
      dopri5_mem->tmp[i]=contd5(dopri5_mem, i, dopri5_mem->tlo, dopri5_mem->x_old, dopri5_mem->h_old);
  }
  retval = dopri5_mem->gcn(dopri5_mem->ng, dopri5_mem->tlo, dopri5_mem->tmp, dopri5_mem->glo, dopri5_mem->udata);
  if (retval != 0) return(DP5_RTFUNC_FAIL);
   
  for (i = 0; i < dopri5_mem->ng; i++) {
    if (abs(dopri5_mem->glo[i]) == ZERO) 
      dopri5_mem->iroots[i] =MASKED; /* arbitrary choice*/
    else 
      dopri5_mem->iroots[i] =0;
  }
  return(DP5_SUCCESS);

}

static int DP5Rcheck3(DOPRI5_mem *dopri5_mem, double toutc)
{
  int  retval;
  unsigned i;

  /* Set thi = tn or tout, whichever comes first; set y = y(thi). */
  
  if ( (toutc - dopri5_mem->x)*dopri5_mem->h >= ZERO) {
    dopri5_mem->thi = dopri5_mem->x; 
  } else {
    dopri5_mem->thi = toutc;
   }
  for (i = 0; i < (dopri5_mem->n); i++)
    dopri5_mem->tmp[i]=contd5(dopri5_mem, i, dopri5_mem->thi, dopri5_mem->x_old, dopri5_mem->h_old);

  /* Set ghi = g(thi) and call CVRootfind to search (tlo,thi) for roots. */
  retval = dopri5_mem->gcn(dopri5_mem->ng, dopri5_mem->thi, dopri5_mem->tmp, dopri5_mem->ghi, dopri5_mem->udata);
  if (retval != 0) return(DP5_RTFUNC_FAIL);

  dopri5_mem->ttol = (abs(dopri5_mem->x) + abs(dopri5_mem->h_old))*(dopri5_mem->uround)*HUN;

  retval = DP5Rootfind(dopri5_mem);

  dopri5_mem->tlo = dopri5_mem->trout;
  memcpy (dopri5_mem->glo, dopri5_mem->grout, (dopri5_mem->ng) * sizeof(double));
  /* If no root found, return CV_SUCCESS. */  
  if (retval == DP5_SUCCESS) return(DP5_SUCCESS);

  /* If a root was found, interpolate to get y(trout) and return.  */
  for (i = 0; i < (dopri5_mem->n); i++)
    dopri5_mem->tmp[i]=contd5(dopri5_mem, i, dopri5_mem->trout, dopri5_mem->x_old, dopri5_mem->h_old);

  if (retval == RTFOUND)
    return(RTFOUND);
  else
    return(ZERODETACHING);
}

static int DP5Rootfind(DOPRI5_mem *dopri5_mem)
{
  double alpha, tmid, gfrac, maxfrac, fracint, fracsub;
  int  retval, imax, side, sideprev;
  int istuck,iunstuck,imaxold;
  unsigned i;

  booleantype zroot, umroot, sgnchg;

  imax = -1;
  istuck=-1;
  iunstuck=-1;
  maxfrac = ZERO;

  /* First check for change in sign in ghi or for a zero in ghi. */
  zroot = FALSE;

  for (i = 0;  i < dopri5_mem->ng; i++) {
    if ((abs(dopri5_mem->ghi[i])==ZERO)&& ((dopri5_mem->iroots)[i]!=MASKED))  istuck=i;
    if ((abs(dopri5_mem->ghi[i])> ZERO)&& ((dopri5_mem->iroots)[i]==MASKED))  iunstuck=i;
    if ((abs(dopri5_mem->ghi[i])> ZERO)&& (dopri5_mem->glo[i]*dopri5_mem->ghi[i] <= ZERO)) {
      gfrac = abs(dopri5_mem->ghi[i]/(dopri5_mem->ghi[i] - dopri5_mem->glo[i]));
      if (gfrac > maxfrac) { /* finding the very first root*/
	maxfrac = gfrac;
	imax = i;
      }      
    }
  }

  if (imax>=0)
    sgnchg=TRUE;
  else if (istuck>=0) {
    sgnchg=TRUE;
    imax=istuck;
  }else  if (iunstuck>=0) {
    sgnchg=TRUE;
    imax=iunstuck;
  }else
    sgnchg = FALSE;
  
  if (!sgnchg) {
    dopri5_mem->trout = dopri5_mem->thi;
    for (i = 0; i < dopri5_mem->ng; i++) dopri5_mem->grout[i] = dopri5_mem->ghi[i];
    return(DP5_SUCCESS);
  }

  /* Initialize alpha to avoid compiler warning */
  alpha = ONE;

  /* A sign change was found.  Loop to locate nearest root. */

  side = 0;  sideprev = -1;
  while(1) {                                    /* Looping point */
    
    /* Set weight alpha.
       On the first two passes, set alpha = 1.  Thereafter, reset alpha
       according to the side (low vs high) of the subinterval in which
       the sign change was found in the previous two passes.
       If the sides were opposite, set alpha = 1.
       If the sides were the same, then double alpha (if high side),
       or halve alpha (if low side).
       The next guess tmid is the secant method value if alpha = 1, but
       is closer to tlo if alpha < 1, and closer to thi if alpha > 1.    */

    if (sideprev == side) {
      alpha = (side == 2) ? alpha*TWO : alpha*HALF;
    } else {
      alpha = ONE;
    }
    /* Set next root approximation tmid and get g(tmid).
       If tmid is too close to tlo or thi, adjust it inward,
       by a fractional distance that is between 0.1 and 0.5.  */
    if ((abs(dopri5_mem->ghi[imax])==ZERO)||(abs(dopri5_mem->glo[imax])==ZERO)){
      tmid=((dopri5_mem->tlo)+alpha*(dopri5_mem->thi))/(1+alpha);
    }else{
      tmid = (dopri5_mem->thi) - ((dopri5_mem->thi) - (dopri5_mem->tlo))*dopri5_mem->ghi[imax]/(dopri5_mem->ghi[imax] - alpha*dopri5_mem->glo[imax]);
    }

    if (tmid+1 ==tmid) {
      if (dopri5_mem->fileout){
	fprintf (dopri5_mem->fileout, "tmid is nan\n\r");
	return(DP5_RTFUNC_FAIL);
      }
    }
    if (abs(tmid - (dopri5_mem->tlo)) < HALF*dopri5_mem->ttol) {
      fracint = abs((dopri5_mem->thi) - (dopri5_mem->tlo))/dopri5_mem->ttol;
      fracsub = (fracint > FIVE) ? TENTH : HALF/fracint;
      tmid = (dopri5_mem->tlo) + fracsub*((dopri5_mem->thi) - (dopri5_mem->tlo));
    }

    if (abs((dopri5_mem->thi) - tmid) < HALF*dopri5_mem->ttol) {
      fracint = abs((dopri5_mem->thi) - (dopri5_mem->tlo))/dopri5_mem->ttol;
      fracsub = (fracint > FIVE) ? TENTH : HALF/fracint;
      tmid = (dopri5_mem->thi) - fracsub*((dopri5_mem->thi) - (dopri5_mem->tlo));
    }

    for (i = 0; i < (dopri5_mem->n); i++)
      dopri5_mem->tmp[i]=contd5(dopri5_mem, i, tmid, dopri5_mem->x_old, dopri5_mem->h_old);    
    /* Set dopri5_mem->ghi = g(thi) and call CVRootfind to search (tlo,thi) for roots. */
    retval = dopri5_mem->gcn(dopri5_mem->ng, tmid, dopri5_mem->tmp, dopri5_mem->grout, dopri5_mem->udata);
    if (retval != 0) return(DP5_RTFUNC_FAIL);

    /* Check to see in which subinterval g changes sign, and reset imax.
       Set side = 1 if sign change is on low side, or 2 if on high side.  */  
  
  /* First check for change in sign in dopri5_mem->ghi or for a zero in dopri5_mem->ghi. */
  zroot = FALSE;
  sideprev = side;
  imaxold=imax;
  imax = -1;
  istuck=-1;iunstuck=-1;
  maxfrac = ZERO;
  for (i = 0;  i < dopri5_mem->ng; i++) {
    if ((abs(dopri5_mem->grout[i])==ZERO)&& ((dopri5_mem->iroots)[i]!=MASKED))  istuck=i;
    if ((abs(dopri5_mem->grout[i])> ZERO)&& ((dopri5_mem->iroots)[i]==MASKED))  iunstuck=i;
    if ((abs(dopri5_mem->grout[i])> ZERO)&& (dopri5_mem->glo[i]*dopri5_mem->grout[i] <= ZERO)) {
      gfrac = abs(dopri5_mem->grout[i]/(dopri5_mem->grout[i] - dopri5_mem->glo[i]));
      if (gfrac > maxfrac) { /* finding the very first root*/
	maxfrac = gfrac;
	imax = i;
      }      
    }
  }

  if (imax>=0)
    sgnchg=TRUE;
  else if (istuck>=0) {
    sgnchg=TRUE;
    imax=istuck;
  }else  if (iunstuck>=0) {
    sgnchg=TRUE;
    imax=iunstuck;
  }else{
    sgnchg = FALSE;
    imax=imaxold;
  }

    if (sgnchg) {
      /* Sign change found in (tlo,tmid); replace thi with tmid. */
      (dopri5_mem->thi) = tmid;
      for (i = 0; i < dopri5_mem->ng; i++) dopri5_mem->ghi[i] = dopri5_mem->grout[i];
      side = 1;
      /* Stop at root thi if converged; otherwise loop. */
      if (abs((dopri5_mem->thi) - (dopri5_mem->tlo)) <= dopri5_mem->ttol) break;
      continue;  /* Return to looping point. */
    }

    /* here, either (abs(thi - tlo) <= ttol) or NO SIGN CHANGE */

    /* No sign change in (tlo,tmid), and no zero at tmid.
       Sign change must be in (tmid,thi).  Replace tlo with tmid. */
    (dopri5_mem->tlo) = tmid;
    for (i = 0; i <dopri5_mem->ng; i++) dopri5_mem->glo[i] = dopri5_mem->grout[i];
    side = 2;
    /* Stop at root thi if converged; otherwise loop back. */
    if (abs((dopri5_mem->thi) - (dopri5_mem->tlo)) <= dopri5_mem->ttol) break;

  } /* End of root-search loop */

  /* Reset trout and grout, set iroots, and return RTFOUND. */
  zroot = FALSE;
  umroot = FALSE;
  dopri5_mem->trout = dopri5_mem->thi;
  for (i = 0; i < dopri5_mem->ng; i++) {
    dopri5_mem->grout[i] = dopri5_mem->ghi[i];
    if ((dopri5_mem->iroots)[i]==MASKED){
      if (abs(dopri5_mem->ghi[i]) != ZERO){ 
	(dopri5_mem->iroots)[i] = (dopri5_mem->ghi[i]> ZERO) ? 2 : -2;
	umroot=TRUE;
      }else{
	(dopri5_mem->iroots)[i]=0;
      }
    }else{
      if (abs(dopri5_mem->ghi[i])== ZERO){ 
	(dopri5_mem->iroots)[i] = (dopri5_mem->glo[i]> ZERO) ? -1 : 1;
	zroot = TRUE;
      }else{
	if (dopri5_mem->glo[i]*dopri5_mem->ghi[i] < ZERO){
	  (dopri5_mem->iroots)[i] = (dopri5_mem->ghi[i]>dopri5_mem->glo[i]) ? 1 : -1;
	  zroot = TRUE;
	}else
	  (dopri5_mem->iroots)[i]=0;
      }
    }    
  }
  if (zroot) {
    for (i = 0; i < dopri5_mem->ng; i++) {
      if (((dopri5_mem->iroots)[i]==2)|| ((dopri5_mem->iroots)[i]==-2))  (dopri5_mem->iroots)[i]=0;
    }
    return(RTFOUND);
  }
  if (umroot) return(ZERODETACHING);
  return(DP5_SUCCESS);
}



/********************************************************
**********************************************************/
/* core integrator */

int dopri5_solve (DOPRI5_mem *dopri5_mem,double *xio, double xout, double* yio, int hot_start)
{
	
  double   expo1, fac, facc1, facc2, fac11, xph;
  double   hlamb, err, sk, hnew, yd0, ydiff, bspl;
  double   stnum, stden, sqr;
  int      iasti, iord, reject, last, res;
  unsigned i;
  double   c2, c3, c4, c5, e1, e3, e4, e5, e6, e7, d1, d3, d4, d5, d6, d7;
  double   a21, a31, a32, a41, a42, a43, a51, a52, a53, a54;
  double   a61, a62, a63, a64, a65, a71, a73, a74, a75, a76;
  unsigned N; 
  /* initialisations */
  switch (dopri5_mem->meth)
    {
    case 1:

      c2=0.2, c3=0.3, c4=0.8, c5=8.0/9.0;
      a21=0.2, a31=3.0/40.0, a32=9.0/40.0;
      a41=44.0/45.0, a42=-56.0/15.0; a43=32.0/9.0;
      a51=19372.0/6561.0, a52=-25360.0/2187.0;
      a53=64448.0/6561.0, a54=-212.0/729.0;
      a61=9017.0/3168.0, a62=-355.0/33.0, a63=46732.0/5247.0;
      a64=49.0/176.0, a65=-5103.0/18656.0;
      a71=35.0/384.0, a73=500.0/1113.0, a74=125.0/192.0;
      a75=-2187.0/6784.0, a76=11.0/84.0;
      e1=71.0/57600.0, e3=-71.0/16695.0, e4=71.0/1920.0;
      e5=-17253.0/339200.0, e6=22.0/525.0, e7=-1.0/40.0;
      d1=-12715105075.0/11282082432.0, d3=87487479700.0/32700410799.0;
      d4=-10690763975.0/1880347072.0, d5=701980252875.0/199316789632.0;
      d6=-1453857185.0/822651844.0, d7=69997945.0/29380423.0;

      break;
    }
  
  N=dopri5_mem->n;
  expo1 = 0.2 - dopri5_mem->beta * 0.75;
  facc1 = 1.0 / dopri5_mem->fac1;
  facc2 = 1.0 / dopri5_mem->fac2;
  last  = 0;
  hlamb = 0.0;
  iord = 5;
  reject=0;
  if (!hot_start) {
    dopri5_mem->posneg = sign (1.0, dopri5_mem->xstop - *xio);
    memcpy (dopri5_mem->y, yio, N * sizeof(double));
    dopri5_mem->x=*xio;
    dopri5_mem->fcallerid=1;    
    dopri5_mem->fcn (N, dopri5_mem->x, dopri5_mem->y, dopri5_mem->k1, dopri5_mem->udata);
    dopri5_mem->h = hinit (dopri5_mem,iord);
    dopri5_mem->nfcn ++;
    dopri5_mem->facold = 1.0E-4;
    dopri5_mem->nstep=0;
    dopri5_mem->naccpt=0;
    dopri5_mem->iasti=0;
    dopri5_mem->nonsti=0;
  }

  if (dopri5_mem->ng > 0) {
    if (!hot_start) {
      res = DP5Rcheck1(dopri5_mem);
      if (res == INITROOT)     return(DP5_BAD_INIT_ROOT);
      if (res ==DP5_RTFUNC_FAIL)  return(DP5_RTFUNC_FAIL);                 

    }else{    

      res = DP5Rcheck2(dopri5_mem);      
      if (res == CLOSERT)     return(DP5_CLOSE_ROOTS);
      if (res == DP5_RTFUNC_FAIL) return(DP5_RTFUNC_FAIL);
      if (res == RTFOUND) {
	dopri5_mem->tretlast = *xio = dopri5_mem->tlo;
        return(DP5_ROOT_RETURN);
      }

    }
  }

  /******** Interpolation  *********************************************/
  if (xout <= dopri5_mem->x) { /* Just do an interpolation and return*/


	  if (dopri5_mem->ng > 0) {
	    res = DP5Rcheck3(dopri5_mem,xout);
	    if (res == RTFOUND) {  /* A new root was found */
	      dopri5_mem->irfnd = 1;
	      dopri5_mem->tretlast = *xio = dopri5_mem->tlo;
	      //memcpy (yio,dopri5_mem->tmp,N * sizeof(double));
	      return DP5_ROOT_RETURN;
	    }else if (res == ZERODETACHING) {  /* Zero detaching */
	      dopri5_mem->irfnd = 1;
	      dopri5_mem->tretlast = *xio = dopri5_mem->tlo;
	      memcpy (yio,dopri5_mem->tmp,N * sizeof(double));
	      return DP5_ZERO_DETACH_RETURN;
	    } else if (res == DP5_RTFUNC_FAIL) { /* g failed */
	      return DP5_RTFUNC_FAIL;
	    }
	      dopri5_mem->irfnd = 0;
	  }

    for (i = 0; i < N; i++)
      yio[i]=contd5(dopri5_mem, i, xout, dopri5_mem->x_old, dopri5_mem->h_old);
    *xio=xout;
    return 1;   
  }
  /*********************************************************************/
  dopri5_mem->x_old = dopri5_mem->x;  

  /* basic integration step */
  while (1)
    {
      if (dopri5_mem->nstep > dopri5_mem->nmax)
	{
	  if (dopri5_mem->fileout)
	    fprintf (dopri5_mem->fileout, "Exit of dopri5 at x = %.16e, more than nmax = %li are needed\r\n", dopri5_mem->x, dopri5_mem->nmax);
	  *xio = dopri5_mem->x;
	  return DP5_TOO_MUCH_WORK;
	}

      if (0.1 * fabs(dopri5_mem->h) <= fabs(dopri5_mem->x) * dopri5_mem->uround)
	{
	  if (dopri5_mem->fileout)
	    fprintf (dopri5_mem->fileout, "Exit of dopri5 at x = %.16e, step size too small h = %.16e\r\n", dopri5_mem->x, dopri5_mem->h);
	  *xio = dopri5_mem->x;
	  return DP5_CONV_FAILURE;
	}

      if ((dopri5_mem->x + 1.01*dopri5_mem->h - dopri5_mem->xstop) * dopri5_mem->posneg > 0.0)
	{
	  dopri5_mem->h = dopri5_mem->xstop - dopri5_mem->x;
	  last = 1;
	}

      dopri5_mem->nstep++;

      /* the first 6 stages */
      for (i = 0; i < N; i++)
	dopri5_mem->yy1[i] = dopri5_mem->y[i] + dopri5_mem->h * a21 * dopri5_mem->k1[i];
      dopri5_mem->fcallerid=-3;    
      dopri5_mem->fcn (N, dopri5_mem->x+c2*dopri5_mem->h, dopri5_mem->yy1, dopri5_mem->k2, dopri5_mem->udata);
      
      for (i = 0; i < N; i++)
	dopri5_mem->yy1[i] = dopri5_mem->y[i] + dopri5_mem->h * (a31*dopri5_mem->k1[i] + a32*dopri5_mem->k2[i]);
      dopri5_mem->fcallerid=4;    
      dopri5_mem->fcn (N, dopri5_mem->x+c3*dopri5_mem->h, dopri5_mem->yy1, dopri5_mem->k3, dopri5_mem->udata);
    
      for (i = 0; i < N; i++)
	dopri5_mem->yy1[i] = dopri5_mem->y[i] + dopri5_mem->h * (a41*dopri5_mem->k1[i] + a42*dopri5_mem->k2[i] + a43*dopri5_mem->k3[i]);
      dopri5_mem->fcallerid=-5;    
      dopri5_mem->fcn (N, dopri5_mem->x+c4*dopri5_mem->h, dopri5_mem->yy1, dopri5_mem->k4, dopri5_mem->udata);
      
      for (i = 0; i <N; i++)
	dopri5_mem->yy1[i] = dopri5_mem->y[i] + dopri5_mem->h * (a51*dopri5_mem->k1[i] + a52*dopri5_mem->k2[i] + a53*dopri5_mem->k3[i] + a54*dopri5_mem->k4[i]);
      dopri5_mem->fcallerid=-6;    
      dopri5_mem->fcn (N, dopri5_mem->x+c5*dopri5_mem->h, dopri5_mem->yy1, dopri5_mem->k5, dopri5_mem->udata);
      
      for (i = 0; i < N; i++)
	dopri5_mem->ysti[i] = dopri5_mem->y[i] + dopri5_mem->h * (a61*dopri5_mem->k1[i] + a62*dopri5_mem->k2[i] + a63*dopri5_mem->k3[i] + a64*dopri5_mem->k4[i] + a65*dopri5_mem->k5[i]);
      xph = dopri5_mem->x + dopri5_mem->h;
      dopri5_mem->fcallerid=-7;    
      dopri5_mem->fcn (N, xph, dopri5_mem->ysti, dopri5_mem->k6, dopri5_mem->udata);
      
      for (i = 0; i < N; i++)
	dopri5_mem->yy1[i] = dopri5_mem->y[i] + dopri5_mem->h * (a71*dopri5_mem->k1[i] + a73*dopri5_mem->k3[i] + a74*dopri5_mem->k4[i] + a75*dopri5_mem->k5[i] + a76*dopri5_mem->k6[i]);
      dopri5_mem->fcallerid=-18;    
      dopri5_mem->fcn (N, xph, dopri5_mem->yy1, dopri5_mem->k2, dopri5_mem->udata);
      
      for (i = 0; i < N; i++){
	dopri5_mem->rcont5[i] = dopri5_mem->h * (d1*dopri5_mem->k1[i] + d3*dopri5_mem->k3[i] + d4*dopri5_mem->k4[i] + d5*dopri5_mem->k5[i] + d6*dopri5_mem->k6[i] + d7*dopri5_mem->k2[i]);
      }

      for (i = 0; i < N; i++)
	dopri5_mem->k4[i] = dopri5_mem->h * (e1*dopri5_mem->k1[i] + e3*dopri5_mem->k3[i] + e4*dopri5_mem->k4[i] + e5*dopri5_mem->k5[i] + e6*dopri5_mem->k6[i] + e7*dopri5_mem->k2[i]);
      dopri5_mem->nfcn += 6;

      /* error estimation */
      err = 0.0;
      if (!dopri5_mem->itoler) /*Scalar ATOL*/ 
	for (i = 0; i < N; i++)
	  {
	    sk = dopri5_mem->atoler[0] + dopri5_mem->rtoler * max_d (fabs(dopri5_mem->y[i]), fabs(dopri5_mem->yy1[i]));
	    sqr = dopri5_mem->k4[i] / sk;
	    err += sqr*sqr;
	  }
      else
	for (i = 0; i < N; i++)
	  {
	    sk = dopri5_mem->atoler[i] + dopri5_mem->rtoler * max_d (fabs(dopri5_mem->y[i]), fabs(dopri5_mem->yy1[i]));
	    sqr = dopri5_mem->k4[i] / sk;
	    err += sqr*sqr;
	  }
      if (N>0) err = sqrt (err / (double)N); else err=0;

      /* computation of hnew */
      fac11 = pow (err, expo1);
      /* Lund-stabilization */
      fac = fac11 / pow(dopri5_mem->facold,dopri5_mem->beta);
      /* we require fac1 <= hnew/h <= fac2 */
      fac = max_d (facc2, min_d (facc1, fac/dopri5_mem->safe));
      hnew = dopri5_mem->h / fac;

      if (err <= 1.0)
	{
	  /* step accepted */

	  dopri5_mem->facold = max_d (err, 1.0E-4);
	  dopri5_mem->naccpt++;

	  /* stiffness detection */
	  if (!(dopri5_mem->naccpt % dopri5_mem->nstiff) || (iasti > 0))
	    {
	      stnum = 0.0;
	      stden = 0.0;
	      for (i = 0; i < N; i++)
		{
		  sqr = dopri5_mem->k2[i] - dopri5_mem->k6[i];
		  stnum += sqr*sqr;
		  sqr = dopri5_mem->yy1[i] - dopri5_mem->ysti[i];
		  stden += sqr*sqr;
		}
	      if (stden > 0.0)
		hlamb = dopri5_mem->h * sqrt (stnum / stden);
	      if (hlamb > 3.25)
		{
		  dopri5_mem->nonsti = 0;
		  dopri5_mem->iasti++;
		  if (dopri5_mem->iasti == 15){
		    if (dopri5_mem->fileout)
		      fprintf (dopri5_mem->fileout, "The problem seems to become stiff at x = %.16e\r\n", dopri5_mem->x);
		    else
		      {
			*xio = dopri5_mem->x;
			return -4;
		      }
		  }
		}
	      else
		{
		  dopri5_mem->nonsti++;
		  if (dopri5_mem->nonsti == 6)
		    iasti = 0;
		}
	    }
	  
	  for (i = 0; i < N; i++)
	    {
	      yd0 = dopri5_mem->y[i];
	      ydiff = dopri5_mem->yy1[i] - yd0;
	      bspl = dopri5_mem->h * dopri5_mem->k1[i] - ydiff;
	      dopri5_mem->rcont1[i] = dopri5_mem->y[i];
	      dopri5_mem->rcont2[i] = ydiff;
	      dopri5_mem->rcont3[i] = bspl;
	      dopri5_mem->rcont4[i] = -dopri5_mem->h * dopri5_mem->k2[i] + ydiff - bspl;
	    }

	  memcpy (dopri5_mem->k1, dopri5_mem->k2, N * sizeof(double)); 
	  memcpy (dopri5_mem->y, dopri5_mem->yy1, N * sizeof(double));

	  if (fabs(hnew) > dopri5_mem->hmax)
	    hnew = dopri5_mem->posneg * dopri5_mem->hmax;
	  if (reject)
	    hnew = dopri5_mem->posneg * min_d (fabs(hnew), fabs(dopri5_mem->h));
	  reject = 0;

	  dopri5_mem->x_old = dopri5_mem->x;
	  dopri5_mem->h_old=dopri5_mem->h;
	  dopri5_mem->x = xph;
	  dopri5_mem->h = hnew;


	  if (dopri5_mem->ng > 0) {
	    res = DP5Rcheck3(dopri5_mem,xout);
	    
	    if (res == RTFOUND) {  /* A new root was found */
	      dopri5_mem->irfnd = 1;
	      dopri5_mem->tretlast = *xio = dopri5_mem->thi;
	      for (i = 0; i < N; i++)
		yio[i]=contd5(dopri5_mem, i, *xio, dopri5_mem->x_old, dopri5_mem->h_old);
	      return DP5_ROOT_RETURN;
	    }else
	      if (res == ZERODETACHING) {  /* Zero lifting */
	      dopri5_mem->irfnd = 1;
	      dopri5_mem->tretlast = *xio = dopri5_mem->thi;
	      for (i = 0; i < N; i++)
		yio[i]=contd5(dopri5_mem, i, *xio, dopri5_mem->x_old, dopri5_mem->h_old);
	      return DP5_ZERO_DETACH_RETURN;
	      } else 
	      if (res == DP5_RTFUNC_FAIL) { /* g failed */
	      return DP5_RTFUNC_FAIL;
	      }
	  }

	  if (dopri5_mem->x >= xout)
	    {
	      for (i = 0; i < N; i++)
		yio[i]=contd5(dopri5_mem, i, xout, dopri5_mem->x_old, dopri5_mem->h_old);
	      *xio=xout;
	      return 1;
	    }  
	  /* normal exit */
	  if (last)
	    {
	      memcpy (yio, dopri5_mem->y, N * sizeof(double));
	      *xio = dopri5_mem->x;
	      return 1;
	    }

	}else{
	  /* step rejected */
	  hnew = dopri5_mem->h / min_d (facc1, fac11/dopri5_mem->safe);
	  dopri5_mem->h = hnew;
	  reject = 1;
	  if (dopri5_mem->naccpt >= 1)
	    dopri5_mem->nrejct++;
	  last = 0;
	} /*  if err<1 */

     
    } /* while loop*/

} /* dopcor */


/********************************************************
**********************************************************/

int  Setup_dopri5(DOPRI5_mem **dopri5_mem, unsigned n,FcnEqDiff fcn, double xstart,
		  double xend, double rtoler, double* atoler, int itoler,  double hmax,
		  unsigned ng, FcnZeroC gcn, User_DP5_data **dopri5_udata) {
  
  int  arret=0;
  /* *************************** */
  double uround=0.0,safe=0.0,fac1=0.0,fac2=0.0, beta=0.0;  
  long nmax=0,meth=0, nstiff=0;  
  /* *************************** */

  *dopri5_mem=malloc(sizeof(DOPRI5_mem));
  if (*dopri5_mem==NULL) {return -1;};		

  (*dopri5_mem)->nfcn=0;
  (*dopri5_mem)->fileout=stdout;
  (*dopri5_mem)->nstep =0;
  (*dopri5_mem)->naccpt =0;
  (*dopri5_mem)->nrejct = 0;
  (*dopri5_mem)->fcallerid=-1;    /*initializer fcallerid*/

  if (n == UINT_MAX)
    {
      if ((*dopri5_mem)->fileout)
    	fprintf ((*dopri5_mem)->fileout, "System too big, max. n = %u\r\n", UINT_MAX-1);
      arret = 1;
    }else {(*dopri5_mem)->n=n;}

  if (fcn == NULL){
      if ((*dopri5_mem)->fileout)
    	fprintf ((*dopri5_mem)->fileout, "Derivative function is not defined.\r\n");
      arret = 1;
  }  else {
    (*dopri5_mem)->fcn=fcn;
  }
  
  if (*dopri5_udata==NULL) {
    *dopri5_udata=malloc(sizeof(User_DP5_data));
    if (*dopri5_udata==NULL) {
      arret=1;
    } else{
      (*dopri5_udata)->dopri5_mem=(*dopri5_mem);
    }
  }   
  (*dopri5_mem)->udata=(*dopri5_udata);

  /* nmax, the maximal number of steps */
  if (!nmax)
    (*dopri5_mem)->nmax = 100000;
  else if (nmax <= 0)
    {
      if ((*dopri5_mem)->fileout)
	fprintf ((*dopri5_mem)->fileout, "Wrong input, nmax = %li\r\n", nmax);
      arret = 1;
    }

  /* meth, coefficients of the method */
  if (!meth)
    (*dopri5_mem)->meth = 1;
  else if ((meth <= 0) || (meth >= 2))  {
      if ((*dopri5_mem)->fileout)
	fprintf ((*dopri5_mem)->fileout, "Curious input, meth = %li\r\n", meth);
      arret = 1;
  }

  if ((itoler < 0) || (itoler > 1)) {
    if ((*dopri5_mem)->fileout)
      fprintf ((*dopri5_mem)->fileout, "Curious itoler = %i\r\n", itoler);
    arret = 1;
  }else{
    (*dopri5_mem)->itoler=itoler;    
    (*dopri5_mem)->rtoler=rtoler;
    (*dopri5_mem)->atoler=atoler;
  }
  
  /* nstiff, parameter for stiffness detection */
  if (!nstiff)
    (*dopri5_mem)->nstiff = 1000;
  else if (nstiff < 0)
    (*dopri5_mem)->nstiff = (*dopri5_mem)->nmax + 10;
  //=========================================
  /* is there enough memory to allocate rcont12345&indir ? */
  (*dopri5_mem)->rcont1 = NULL;
  (*dopri5_mem)->rcont2 = NULL;
  (*dopri5_mem)->rcont3 = NULL;
  (*dopri5_mem)->rcont4 = NULL;
  (*dopri5_mem)->rcont5 = NULL;
  if (n>0) {
    (*dopri5_mem)->rcont1 = (double*) malloc (n*sizeof(double));
    (*dopri5_mem)->rcont2 = (double*) malloc (n*sizeof(double));
    (*dopri5_mem)->rcont3 = (double*) malloc (n*sizeof(double));
    (*dopri5_mem)->rcont4 = (double*) malloc (n*sizeof(double));
    (*dopri5_mem)->rcont5 = (double*) malloc (n*sizeof(double));
    if (!(*dopri5_mem)->rcont1 || !(*dopri5_mem)->rcont2 || !(*dopri5_mem)->rcont3 || !(*dopri5_mem)->rcont4 || !(*dopri5_mem)->rcont5 )
      {
	if ((*dopri5_mem)->fileout)
	  fprintf ((*dopri5_mem)->fileout, "Not enough free memory for rcont12345\r\n");
	arret = 1;
      }
  }
  
  /* uround, smallest number satisfying 1.0+uround > 1.0 */
  if (uround == 0.0) {
    (*dopri5_mem)->uround = UNIT_ROUNDOFF;
  }else if ((uround <= 1.0E-35) || (uround >= 1.0))
    {
      if ((*dopri5_mem)->fileout)
	fprintf ((*dopri5_mem)->fileout, "Which machine do you have ? Your uround was : %.16e\r\n", uround);
      arret = 1;
    }

  /* safety factor */
  if (safe == 0.0)
    (*dopri5_mem)->safe = 0.9;
  else if ((safe >= 1.0) || (safe <= 1.0E-4))
    {
      if ((*dopri5_mem)->fileout)
	fprintf ((*dopri5_mem)->fileout, "Curious input for safety factor, safe = %.16e\r\n", safe);
      arret = 1;
    }

  /* fac1, fac2, parameters for step size selection */
  if (fac1 == 0.0)
    (*dopri5_mem)->fac1 = 0.2;
  if (fac2 == 0.0)
    (*dopri5_mem)->fac2 = 10.0;

  /* beta for step control stabilization */
  if (beta == 0.0)
    (*dopri5_mem)->beta = 0.04;
  else if (beta < 0.0)
    (*dopri5_mem)->beta = 0.0;
  else if (beta > 0.2)
    {
      if ((*dopri5_mem)->fileout)
	fprintf ((*dopri5_mem)->fileout, "Curious input for beta : beta = %.16e\r\n", beta);
      arret = 1;
    }

  /* maximal step size */
  if (hmax == 0.0)
    (*dopri5_mem)->hmax = fabs(xend - xstart);

  /* is there enough free memory for the method ? */
  (*dopri5_mem)->y  = NULL;
  (*dopri5_mem)->tmp= NULL;
  (*dopri5_mem)->yy1= NULL;
  (*dopri5_mem)->k1 = NULL;
  (*dopri5_mem)->k2 = NULL;
  (*dopri5_mem)->k3 = NULL;
  (*dopri5_mem)->k4 = NULL;
  (*dopri5_mem)->k5 = NULL;
  (*dopri5_mem)->k6 = NULL;
  (*dopri5_mem)->ysti = NULL;
  (*dopri5_mem)->ghi  = NULL;
  (*dopri5_mem)->glo  = NULL;
  (*dopri5_mem)->grout  = NULL;
  (*dopri5_mem)->iroots = NULL;

  if (n>0) {
    (*dopri5_mem)->y =  (double*) malloc (n*sizeof(double));
    (*dopri5_mem)->tmp= (double*) malloc (n*sizeof(double));
    (*dopri5_mem)->yy1= (double*) malloc (n*sizeof(double));
    (*dopri5_mem)->k1 = (double*) malloc (n*sizeof(double));
    (*dopri5_mem)->k2 = (double*) malloc (n*sizeof(double));
    (*dopri5_mem)->k3 = (double*) malloc (n*sizeof(double));
    (*dopri5_mem)->k4 = (double*) malloc (n*sizeof(double));
    (*dopri5_mem)->k5 = (double*) malloc (n*sizeof(double));
    (*dopri5_mem)->k6 = (double*) malloc (n*sizeof(double));
    (*dopri5_mem)->ysti= (double*) malloc (n*sizeof(double));
    if (!(*dopri5_mem)->y || !(*dopri5_mem)->yy1 || !(*dopri5_mem)->k1 || !(*dopri5_mem)->k2 ||
	!(*dopri5_mem)->k3 || !(*dopri5_mem)->k4 || !(*dopri5_mem)->k5 || !(*dopri5_mem)->k6 ||
	!(*dopri5_mem)->ysti || !(*dopri5_mem)->tmp )
      {
	if ((*dopri5_mem)->fileout)
	  fprintf ((*dopri5_mem)->fileout, "Not enough free memory for the method\r\n");
	arret = 1;
      }
  }

  (*dopri5_mem)->ng = ng;
  (*dopri5_mem)->irfnd = 0;
  if (ng>0) {
    (*dopri5_mem)->ghi = (double*) malloc (ng*sizeof(double));
    (*dopri5_mem)->glo = (double*) malloc (ng*sizeof(double));
    (*dopri5_mem)->grout = (double*) malloc (ng*sizeof(double));
    (*dopri5_mem)->iroots = (int*) malloc  (ng*sizeof(int));
    if (!(*dopri5_mem)->ghi || !(*dopri5_mem)->glo  || !(*dopri5_mem)->grout || !(*dopri5_mem)->iroots)
      arret=1;

    if (gcn == NULL){
      if ((*dopri5_mem)->fileout)
    	fprintf ((*dopri5_mem)->fileout, "Root function is not defined.\r\n");
      arret = 1;
    }  else {
      (*dopri5_mem)->gcn=gcn;
    }

  }

 
  /* when a failure has occured, we return -1 */
  if (arret){
    dopri5_free(*dopri5_mem);
    return -1;
  } else {
    return 0;
  }
  
} /* dopri5 */

/********************************************************
**********************************************************/

int dopri5_free (DOPRI5_mem *dopri5_mem) {
 
  if (dopri5_mem->ng>0) {
    if (dopri5_mem->iroots)  free (dopri5_mem->iroots);
    if (dopri5_mem->grout)	  free (dopri5_mem->grout);
    if (dopri5_mem->glo)	  free (dopri5_mem->glo);
    if (dopri5_mem->ghi)	  free (dopri5_mem->ghi);
  }
  if (dopri5_mem->ysti)	  free (dopri5_mem->ysti);
  if (dopri5_mem->k6)	  free (dopri5_mem->k6);
  if (dopri5_mem->k5)	  free (dopri5_mem->k5);
  if (dopri5_mem->k4)	  free (dopri5_mem->k4);
  if (dopri5_mem->k3)	  free (dopri5_mem->k3);
  if (dopri5_mem->k2)	  free (dopri5_mem->k2);
  if (dopri5_mem->k1)	  free (dopri5_mem->k1);
  if (dopri5_mem->yy1)	  free (dopri5_mem->yy1);
  if (dopri5_mem->tmp)	  free (dopri5_mem->tmp);
  if (dopri5_mem->y)	  free (dopri5_mem->y);
  if (dopri5_mem->rcont5) free (dopri5_mem->rcont5);
  if (dopri5_mem->rcont4) free (dopri5_mem->rcont4);
  if (dopri5_mem->rcont3) free (dopri5_mem->rcont3);
  if (dopri5_mem->rcont2) free (dopri5_mem->rcont2);
  if (dopri5_mem->rcont1) free (dopri5_mem->rcont1);
  if (dopri5_mem)         free (dopri5_mem);
  return 0;
}

/********************************************************
**********************************************************/

#ifdef USE_MAIN 
static void faren (unsigned n, double x, double *y, double *f, void *udata)
{
  double amu, amup, r1, r2, sqr;

  amu = 0.012277471;
  amup = 1.0 - amu;
  f[0] = y[2];
  f[1] = y[3];
  sqr = y[0] + amu;
  r1 = sqr*sqr + y[1]*y[1];
  r1 = r1 * sqrt(r1);
  sqr = y[0] - amup;
  r2 = sqr*sqr + y[1]*y[1];
  r2 = r2 * sqrt(r2);
  f[2] = y[0] + 2.0 * y[3] - amup * (y[0]+amu) / r1 - amu * (y[0]-amup) / r2;
  f[3] = y[1] - 2.0 * y[2] - amup * y[1] / r1 - amu * y[1] / r2;
  /* f[0]=f[1]=f[2]=f[3]=1; */
}

static int garen(unsigned n, double x, double *y, double *g, void *udata)
{  
  //g[0]=x-16.91;
  g[0]=y[0];
  return 0;
}

int mainx (void)
{
  int   N=4;
  double   *yio;
  int      res,/* iout,*/ itoler;
  double   xio, xstart, xend, atoler, rtoler,xout,hmax;
  DOPRI5_mem *dopri5_mem=NULL;
  int hot=0;
 
  yio=malloc(N*sizeof(double));

  yio[0] = 0.994;
  yio[1] = 0.0;
  yio[2] = 0.0;
  yio[3] = -2.00158510637908252240537862224;
  xend = 17.0652165601579625588917206249;
  //xend=16;
  rtoler = 1.0E-7;
  itoler=0;
  atoler = 1e-7;
  /* iout=2; */
  xout=0;
  hmax=0.0;
  xstart=0.0;

  res=Setup_dopri5(&dopri5_mem, N, faren, xstart, xend, rtoler, &atoler,itoler,hmax, 1,garen,NULL);
  DP5_set_tstop(dopri5_mem, xend);
  xio=0.0;
  xout=2.0;
  hot=0;
  while (xio < xend){
     res=dopri5_solve (dopri5_mem, &xio,  xout, yio, hot);
    if (res<0) break;
    if (res==DP5_ROOT_RETURN || res==DP5_ZERO_DETACH_RETURN){
    }
    hot=1;
    printf("\n\r Xout=%12.10f  y=%12.10f gxlo=  RES=%d ", xio, yio[0], res);
    if (xio>=xout)
      xout += 2.0e-2;
  }
  printf ("\r\n res=%d rtol=%12.10f   fcn=%li   step=%li   accpt=%li   rejct=%li\r\n",res, rtoler, nfcnRead(dopri5_mem),
	  nstepRead(dopri5_mem), naccptRead(dopri5_mem), nrejctRead(dopri5_mem));

  dopri5_free (dopri5_mem);
  return 0;
}
#endif

