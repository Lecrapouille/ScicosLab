/*------------------------------------------------------------------------
 *    Graphic library
 *    Copyright (C) 1998-2001 Enpc/Jean-Philippe Chancelier
 *    jpc@cermics.enpc.fr 
 --------------------------------------------------------------------------*/

#include <string.h> /* in case of dbmalloc use */
#include <math.h>
#include <stdio.h>
#include "Math.h"
#include "PloEch.h"
#include "GetProperty.h"
#include "SetProperty.h"
#include "DrawObjects.h"

#if WIN32
#include "../os_specific/win_mem_alloc.h" /* MALLOC */
#else
#include "../os_specific/sci_mem_alloc.h" /* MALLOC */
#endif

void wininfo  __PARAMS((char *fmt,...)); 

extern double C2F(dsort)();
extern char GetDriver(void);
extern int Check3DPlots(char *, integer *);
extern int version_flag();
extern int scilab_shade(integer *polyx, integer *polyy, integer *fill, integer polysize, integer flag);

/** PGEOX and PGEOY are like GEOX or GEOY in PloEch.h but we keep values in xx1 and yy1 for finite check **/
static double xx1,yy1;
#define PGEOX(x1,y1,z1) inint(xx1= Cscale.Wscx1*(TRX(x1,y1,z1)-Cscale.frect[0]) +Cscale.Wxofset1);
#define PGEOY(x1,y1,z1) inint(yy1= Cscale.Wscy1*(-TRY(x1,y1,z1)+Cscale.frect[3])+Cscale.Wyofset1);

static void C2F(plot3dg) __PARAMS(( char *name,int (*func)(), double *x, double *y,double *z,
				    integer *p, integer *q, double *teta,double *alpha,char *legend,
				    integer *flag,double *bbox));

static void C2F(fac3dg) __PARAMS(( char *name, int iflag, double *x, double *y, double *z, integer *cvect, integer *p, integer *q, double *teta, double *alpha, char *legend, integer *flag, double *bbox));

static void dbox __PARAMS((void));

/*-------------------------------------------------------------------------
 *
 *  3D Plotting of surfaces given by z=f(x,y)
 *  -->  Entry :
 *     x : vector of size *p
 *     y : vector of size *q
 *     z : vector of size (*p)*(*q) 
 *         z[i+(*p)j]=f(x[i],y[j])
 *     p,q 
 *     teta,alpha (spherical angle in degree of the observation point 
 *                 at infinity )
 *     flag[0]={ n1, n2 }
 *       n1 ==1  with hidden parts 
 *       n1 >=2 without hidden part, ( if flag > 2  the surface is grey )
 *       n1 <=0 only the shape of the surface is painted (with white if 0)
 *     flag[1]=0  ( the current scale are used, for superpose mode )
 *     flag[1]=1  ( bbox is used to fix the box of plot3d )
 *     flag[1]=3  ( isometric, bbox fixes the box of plot3d )
 *     flag[1]=4  ( isometric, bbox fixed by data )
 *     flag[1]=5  ( expanded isometric, bbox fixes the box of plot3d )
 *     flag[1]=6  ( expanded isometric, bbox fixed by data )
 *     flag[2]=0  ( No box around the plot3d )
 *     flag[2]=1  ( petit triedre ds un coin )
 *     flag[2]=2  ( juste triedre cache )
 *     flag[2]=3  ( toute la boite + legendes )
 *     flag[2]=4  ( toute la boite + legendes + axes )
 *     legend="x-legend@y-legend@z-legend"
 *     
 *  <-- The arguments are not modified 
 *-------------------------------------------------------------------------*/
int C2F(plot3d)(double *x, double *y, double *z, integer *p, integer *q, double *teta, double *alpha, char *legend, integer *flag, double *bbox, integer lstr)
{
  C2F(plot3dg)("plot3d",DPoints,x,y,z,p,q,teta,alpha,legend,flag,bbox);
  return(0);
}

int C2F(plot3d1)(double *x, double *y, double *z, integer *p, integer *q, double *teta, double *alpha, char *legend, integer *flag, double *bbox, integer lstr)
{
  C2F(plot3dg)("plot3d1",DPoints1,x,y,z,p,q,teta,alpha,legend,flag,bbox);
  return(0);
}

int C2F(fac3d)(double *x, double *y, double *z, integer *cvect, integer *p, integer *q, double *teta, double *alpha, char *legend, integer *flag, double *bbox, integer lstr)
{
  C2F(fac3dg)("fac3d",0,x,y,z,cvect,p,q,teta,alpha,legend,flag,bbox);
  return(0);
}

int C2F(fac3d1)(double *x, double *y, double *z, integer *cvect, integer *p, integer *q, double *teta, double *alpha, char *legend, integer *flag, double *bbox, integer lstr)
{
  C2F(fac3dg)("fac3d1",1,x,y,z,cvect,p,q,teta,alpha,legend,flag,bbox);
  return(0);
}

int C2F(fac3d2)(double *x, double *y, double *z, integer *cvect, integer *p, integer *q, double *teta, double *alpha, char *legend, integer *flag, double *bbox, integer lstr)
{
  C2F(fac3dg)("fac3d2",2,x,y,z,cvect,p,q,teta,alpha,legend,flag,bbox);
  return(0);
}

/* 
 * Current geometric transformation and scales 
 * which are used or set according to the value of flag[1]
 *
 */

static void C2F(plot3dg)(char *name, int (*func) (/* ??? */), double *x, double *y, double *z, integer *p, integer *q, double *teta, double *alpha, char *legend, integer *flag, double *bbox)
{
  static integer InsideU[4],InsideD[4],fg,fg1,dc;
  /* solid = color of 3D frame */
  integer polysize, whiteid,verbose=0,narg;
  integer *polyx,*polyy,*fill;
  double xbox[8],ybox[8],zbox[8];
  static integer cache;
  static double zmin,zmax;
  integer i,j;
 
  /** If Record is on **/
  if (GetDriver()=='R' && version_flag() != 0) 
    StorePlot3D(name,x,y,z,p,q,teta,alpha,legend,flag,bbox);

  C2F(dr)("xget","foreground",&verbose,&fg,&narg, PI0, PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
 
  if (flag[1]!=0 && flag[1]!=1 && flag[1]!=3 && flag[1]!=5)
    {
      bbox[0]=x[0];bbox[1]=x[*p-1];
      bbox[2]=y[0];bbox[3]=y[*q-1];
      zmin=bbox[4]=(double) Mini(z,*p*(*q)); 
      zmax=bbox[5]=(double) Maxi(z,*p*(*q));
    }
  if ( flag[1]==1 || flag[1]==3 || flag[1]==5) 
    {
      zmin=bbox[4];
      zmax=bbox[5];
    }
 
  if ( flag[1] ==0)
    SetEch3d1(xbox,ybox,zbox,bbox,teta,alpha,0L);
  else
    SetEch3d1(xbox,ybox,zbox,bbox,teta,alpha,(long)(flag[1]+1)/2);
  /** Calcule l' Enveloppe Convex de la boite **/
  /** ainsi que les triedres caches ou non **/
  Convex_Box(xbox,ybox,InsideU,InsideD,legend,flag,bbox);
  /** Le triedre cach\'e **/
  C2F(dr)("xget","hidden3d",&verbose,&fg1,&narg, PI0, PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  if (fg1==-1) fg1=0;
  if (zbox[InsideU[0]] > zbox[InsideD[0]])
    {
      cache=InsideD[0];
      if (flag[2] >=2 )DrawAxis(xbox,ybox,InsideD,fg1);
    }
  else 
    {
      cache=InsideU[0]-4;
      if (flag[2] >=2 )DrawAxis(xbox,ybox,InsideU,fg1);
    }
 
  polyx = graphic_alloc(0,5*(*q),sizeof(int));
  polyy = graphic_alloc(1,5*(*q),sizeof(int));
  fill  = graphic_alloc(2,(*q),sizeof(int));
  if ( (polyx == NULL) || (polyy == NULL) || (fill  == NULL)) 
    {
      Scistring("plot3dg_ : malloc No more Place\n");
      return;
    }
 
  /** The 3d plot **/

  C2F(dr)("xget","lastpattern",&verbose,&whiteid,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  dc =  flag[0];
  C2F(dr)("xget","hidden3d",&verbose,&fg1,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  if (fg1==-1) fg1=0;   
  for ( i =0 ; i < (*q)-1 ; i++)   fill[i]= dc ;
  polysize=5;
  /* npoly= (*q)-1;  */
  /** Choix de l'ordre de parcourt **/
  switch (cache)
    {
    case 0 : 
      for ( i =0 ; i < (*p)-1 ; i++)
	{
	  int npolyok=0;
	  for ( j =0 ; j < (*q)-1 ; j++)
	    {
	      npolyok += (*func)(polyx,polyy,fill,whiteid,zmin,zmax,
				 x,y,z,i,j,npolyok,p,dc,fg1);
	    }
	  if ( npolyok != 0) 
	    C2F(dr)("xliness","str",polyx,polyy,fill,&npolyok,&polysize
		    ,PI0,PD0,PD0,PD0,PD0,0L,0L);
	}
      break;
    case 1 : 
      for ( i =0 ; i < (*p)-1 ; i++)
	{
	  int npolyok=0;
	  for ( j =0  ; j < (*q)-1  ; j++)
	    {
	      npolyok += (*func)(polyx,polyy,fill,whiteid,zmin,zmax,
				 x,y,z,i,(*q)-2-j,npolyok,p,dc,fg1);
	    }
	  if ( npolyok != 0) 
	    C2F(dr)("xliness","str",polyx,polyy,fill,&npolyok,&polysize
		    ,PI0,PD0,PD0,PD0,PD0,0L,0L);
	}
      break;
    case 2 : 
      for ( i =(*p)-2 ; i >=0  ; i--)
	{
	  int npolyok=0;
	  for ( j = 0 ; j < (*q)-1 ; j++)
	    {
	      npolyok +=     (*func)(polyx,polyy,fill,whiteid,zmin,zmax,
				     x,y,z,i,(*q)-2-j,npolyok,p,dc,fg1);
	    }
	  if ( npolyok != 0) 
	    C2F(dr)("xliness","str",polyx,polyy,fill,&npolyok,&polysize
		    ,PI0,PD0,PD0,PD0,PD0,0L,0L);
	}
      break;
    case 3 : 
      for ( i =(*p)-2 ; i >=0  ; i--)
	{
	  int npolyok=0;
	  for ( j =0 ; j < (*q)-1 ; j++)
	    {
	      npolyok += (*func)(polyx,polyy,fill,whiteid,zmin,zmax,
				 x,y,z,i,j,npolyok,p,dc,fg1);
	    }
	  if ( npolyok != 0) 
	    C2F(dr)("xliness","str",polyx,polyy,fill,&npolyok,&polysize
		    ,PI0,PD0,PD0,PD0,PD0,0L,0L);
	}
      break;
    }
  /* jpc   if (flag[1] != 0 && flag[2] >=3 ) */
  if ( flag[2] >=3 )
    {
      /** Le triedre que l'on doit voir **/
      if (zbox[InsideU[0]] > zbox[InsideD[0]])
	DrawAxis(xbox,ybox,InsideU,fg);
      else 
	DrawAxis(xbox,ybox,InsideD,fg);
    }



}


static void C2F(fac3dg)(char *name, int iflag, double *x, double *y, double *z, integer *cvect, integer *p, integer *q, double *teta, double *alpha, char *legend, integer *flag, double *bbox)
{
  static integer InsideU[4],InsideD[4],fg1;
  integer polysize,npoly,whiteid,verbose=0,narg;
  integer *polyx,*polyy,*locindex,fill[4]; /* Modified by polpoth 4/5/2000 fill[4] instead of fill[1] */
  double xbox[8],ybox[8],zbox[8],*polyz;
  /* static integer cache; */
  static double zmin,zmax;
  integer i,flag_det=0,flag_det0=0,flag_det1=0,flag_det2=0,flag_det3=0;
  /** If Record is on **/
  if (GetDriver()=='R' && version_flag() != 0) 
    StoreFac3D(name,x,y,z,cvect,p,q,teta,alpha,legend,flag,bbox);

  if (flag[1]!=1 && flag[1] != 0 && flag[1]!=3 && flag[1]!=5)
    {
      bbox[0]=(double) Mini(x,*p*(*q));
      bbox[1]=(double) Maxi(x,*p*(*q));
      bbox[2]=(double) Mini(y,*p*(*q)); 
      bbox[3]=(double) Maxi(y,*p*(*q));
      zmin=bbox[4]=(double) Mini(z,*p*(*q)); 
      zmax=bbox[5]=(double) Maxi(z,*p*(*q));
    }
  if ( flag[1]==1 || flag[1]==3|| flag[1]==5) 
    {
      zmin=bbox[4];
      zmax=bbox[5];
    }
  if ( flag[1]==0)
    SetEch3d1(xbox,ybox,zbox,bbox,teta,alpha,0L);
  else
    SetEch3d1(xbox,ybox,zbox,bbox,teta,alpha,(long)(flag[1]+1)/2);
  /** Calcule l' Enveloppe Convex de la boite **/
  /** ainsi que les triedres caches ou non **/
  Convex_Box(xbox,ybox,InsideU,InsideD,legend,flag,bbox);
  /** Le triedre cach\'e **/
  C2F(dr)("xget","hidden3d",&verbose,&fg1,&narg, PI0, PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  if (fg1==-1) fg1=0;  
  if (zbox[InsideU[0]] > zbox[InsideD[0]])
    {
      /* cache=InsideD[0]; */
      if (flag[2] >=2 )DrawAxis(xbox,ybox,InsideD,fg1);
    }
  else 
    {
      /* cache=InsideU[0]-4; */
      if (flag[2] >=2 )DrawAxis(xbox,ybox,InsideU,fg1);
    }
  polyz = graphic_alloc(5,(*q),sizeof(double));
  if ( (polyz == NULL) && (*q) != 0)
    {
      Scistring("plot3dg_ : malloc No more Place\n");
      return;
    }
  /** Allocation  **/
  polyx = graphic_alloc(0,(*p)+1L,sizeof(int));
  polyy = graphic_alloc(1,(*p)+1L,sizeof(int));
  locindex = graphic_alloc(2,(*q),sizeof(int));
  if ( ( polyx == NULL) ||  ( polyy== NULL) || ( locindex== NULL) )
    {
      Scistring("plot3dg_ : malloc No more Place\n");
      return;
    }

  C2F(dr)("xget","lastpattern",&verbose,&whiteid,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  fill[0]=  flag[0];
  C2F(dr)("xget","hidden3d",&verbose,&fg1,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  /** tri **/
  for ( i =0 ; i < *q ; i++)
    {
      double zdmin1, zdmin,xmoy=0.00,ymoy=0.00,zmoy=0.00;
      int j=0 ;
      zdmin1=  TRZ(x[ (*p)*i]  ,y[(*p)*i]  ,z[(*p)*i]);
      for ( j= 0 ; j < *p ; j++) 
	{
	  xmoy += x[ j +(*p)*i];  ymoy += y[ j +(*p)*i];  zmoy += z[ j +(*p)*i];
	  zdmin =  TRZ(x[ j +(*p)*i]  ,y[ j +(*p)*i]  ,z[ j +(*p)*i]);
	  if ( zdmin1 < zdmin ) zdmin1= zdmin;
	}
      /* polyz[i]= zdmin1 + TRZ(xmoy,ymoy,zmoy); */
      polyz[i]=  TRZ(xmoy,ymoy,zmoy);
    }
  C2F(dsort)(polyz,q,locindex); 
  for ( i =0 ; i < (*q) ; i++)
    {
      locindex[i] -= 1;  /* Fortran locindex -> C locindex */
      if ( locindex[i] >= *q) 
	sciprint (" index[%d]=%d\r\n",i,locindex[i]);
      locindex[i] = Min(Max(0,locindex[i]),*q-1);
    }
  polysize=(*p)+1; /* jpc : dec 1999 */
  npoly=1; 
  for ( i = (*q)-1 ; i>= 0 ; i--)
    {
      int j,nok=0;
      for ( j =0 ; j < (*p) ; j++)
	{
	  polyx[j]=PGEOX(x[(*p)*locindex[i]+j]  ,y[(*p)*locindex[i]+j]  ,z[(*p)*locindex[i]+j]);
	  if ( finite(xx1) ==0 ) 
	    {
	      nok=1;break;
	    }
	  polyy[j]=PGEOY(x[(*p)*locindex[i]+j]  ,y[(*p)*locindex[i]+j]  ,z[(*p)*locindex[i]+j]);
	  if ( finite(yy1)==0)
	    {
	      nok=1;break;
	    }
	}
      if ( nok == 0) 
	{
	  polyx[(*p)]=polyx[0];
	  polyy[(*p)]=polyy[0];

	  fill[0]=  flag[0];
	  /* Beginning of modified code by E. Segre 4/5/2000 : the call
	     to C2F(dr)("xliness" ... is now done in each if/else if block.
	     The case iflag==3 corresponds to the new case, where cvect points
	     to a (*p) times (*q) matrix, in order to do interpolated shading.
	     
	     The new added function are located at the end of thecurrent file (Plo3d.c) */
		 
	  if (*p > 2) { /* Detection of facet orientation,    */
	    double determ;     /* improved by Mottelet 25/01/2005    */ 
	    determ =         /* to take in account quadrilaterals. */
	      ((polyx[1] - polyx[0]) * (polyy[2] - polyy[0]) -
	       (polyy[1] - polyy[0]) * (polyx[2] - polyx[0]));
	    flag_det1 = (determ < 0); /* First test for a triangle */
	    if (*p > 3) { /* Second test for the quadrilateral case */
	      determ =
		((polyx[2] - polyx[0]) * (polyy[3] - polyy[0]) -
		 (polyy[2] - polyy[0]) * (polyx[3] - polyx[0]));
	      flag_det3 = (determ < 0);
	      determ =
		((polyx[2] - polyx[1]) * (polyy[3] - polyy[1]) -
		 (polyy[2] - polyy[1]) * (polyx[3] - polyx[1]));
	      flag_det2 = (determ < 0);
	      determ =
		((polyx[3] - polyx[1]) * (polyy[0] - polyy[1]) -
		 (polyy[3] - polyy[1]) * (polyx[0] - polyx[1]));
	      flag_det0 = (determ < 0);
	    }
	    /*        printf("%d %d %d %d\n",flag_det0,flag_det1,flag_det2,flag_det3); */
	  }
	  flag_det=flag_det0+flag_det1+flag_det2+flag_det3;
	  if ((flag_det > 3 || (flag_det==1 && (*p)==3)) && (fg1>=0)) {	      
	    fill[0] = (flag[0] > 0 ) ? fg1 : -fg1 ;
	    /* 
	       The following test fixes a bug : when flag[0]==0 then only the
	       wire frame has to be drawn, and the "shadow" of the surface does
	       not have to appear. polpoth 4/5/2000
	    */
	      
	    if (flag[0]==0) fill[0]=0;
	    /* modification du to E Segre to avoid drawing of hidden facets */
	    if (fg1>0)
	      C2F(dr)("xliness","str",polyx,polyy,fill,&npoly,&polysize,
		      PI0,PD0,PD0,PD0,PD0,0L,0L); 
	  }
	  else if ( iflag == 1) 
	    {
	      /* color according to z-level */
	      double zl=0;
	      int k;
	      for ( k= 0 ; k < *p ; k++) 
		zl+= z[(*p)*locindex[i]+k];
	      fill[0]=inint((whiteid-1)*((zl/(*p))-zmin)/(zmax-zmin))+1;
	      if ( flag[0] < 0 ) fill[0]=-fill[0];
	      C2F(dr)("xliness","str",polyx,polyy,fill,&npoly,&polysize ,PI0,PD0,PD0,PD0,PD0,0L,0L);
	    }
	  else if ( iflag == 2) 
	    {
	      /* colors are given by cvect */
	      fill[0]= cvect[locindex[i]];
	      if ( flag[0] < 0 ) fill[0]=-fill[0];
	      C2F(dr)("xliness","str",polyx,polyy,fill,&npoly,&polysize ,PI0,PD0,PD0,PD0,PD0,0L,0L);
	    }
	  else if (iflag ==3) { /* colors are given by cvect of size (*p) times (*q) */
	    int k;
              
	    if ( (*p) != 3 && (*p) !=4 ) {
	      Scistring("plot3d1 : interpolated shading is only allowed for polygons with 3 or 4 vertices\n");
	      return;
	    } else {
	      for ( k= 0 ; k < *p ; k++) fill[k]= cvect[(*p)*locindex[i]+k];
	      scilab_shade(polyx,polyy,fill,*p,flag[0]);
	      /** draw if requested but just check on the first color **/ 
	      /*		if ( cvect[(*p)*locindex[i]] <= 0 ) 
				{
				fill[0]=0;
				C2F(dr)("xliness","str",polyx,polyy,fill,&npoly,&polysize,PI0,PD0,PD0,PD0,PD0,0L,0L);
				}*/



	    }
	  }
	  else C2F(dr)("xliness","str",polyx,polyy,fill,&npoly,&polysize ,PI0,PD0,PD0,PD0,PD0,0L,0L);
	  /* End of modified code by polpoth 4/5/2000 */

	}
    } 
  if ( flag[2] >=3 )
    {
      integer fg;
      C2F(dr)("xget","foreground",&verbose,&fg,&narg, PI0, PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
      /** Le triedre que l'on doit voir **/
      if (zbox[InsideU[0]] > zbox[InsideD[0]])
	DrawAxis(xbox,ybox,InsideU,fg);
      else 
	DrawAxis(xbox,ybox,InsideD,fg);
    }
}

/*-------------------------------------------------------------------
 *  returns in (polyx, polyy) the polygon for one facet of the surface 
 *--------------------------------------------------------------------*/

int DPoints1(integer *polyx, integer *polyy, integer *fill, integer whiteid, double zmin, double zmax, double *x, double *y, double *z, integer i, integer j, integer jj1, integer *p, integer dc, integer fg)
{
  polyx[  5*jj1] =PGEOX(x[i]  ,y[j]  ,z[i+(*p)*j]);
  if ( finite(xx1)==0 )return(0);
  polyy[  5*jj1] =PGEOY(x[i]  ,y[j]  ,z[i+(*p)*j]);
  if ( finite(yy1)==0)return(0);
  polyx[1 +5*jj1]=PGEOX(x[i]  ,y[j+1],z[i+(*p)*(j+1)]);	
  if ( finite(xx1)==0 )return(0);
  polyy[1 +5*jj1]=PGEOY(x[i]  ,y[j+1],z[i+(*p)*(j+1)]);
  if ( finite(yy1)==0)return(0);
  polyx[2 +5*jj1]=PGEOX(x[i+1],y[j+1],z[(i+1)+(*p)*(j+1)]);
  if ( finite(xx1)==0 )return(0);
  polyy[2 +5*jj1]=PGEOY(x[i+1],y[j+1],z[(i+1)+(*p)*(j+1)]);
  if ( finite(yy1)==0)return(0);
  polyx[3 +5*jj1]=PGEOX(x[i+1],y[j]  ,z[(i+1)+(*p)*j]);
  if ( finite(xx1)==0 )return(0);
  polyy[3 +5*jj1]=PGEOY(x[i+1],y[j]  ,z[(i+1)+(*p)*j]);
  if ( finite(yy1)==0)return(0);
  polyx[4 +5*jj1]=PGEOX(x[i]  ,y[j]  ,z[i+(*p)*j]);
  if ( finite(xx1)==0 )return(0);
  polyy[4 +5*jj1]=PGEOY(x[i]  ,y[j]  ,z[i+(*p)*j]);
  if ( finite(yy1)==0)return(0);
  if (((polyx[1+5*jj1]-polyx[0+5*jj1])*(polyy[2+5*jj1]-polyy[0+5*jj1])-
       (polyy[1+5*jj1]-polyy[0+5*jj1])*(polyx[2+5*jj1]-polyx[0+5*jj1])) <  0)
    fill[jj1]= (dc < 0 ) ? -fg : fg ;
  else
    {
      fill[jj1]=inint((whiteid-1)*((1/4.0*( z[i+(*p)*j]+ z[i+1+(*p)*j]+
					    z[i+(*p)*(j+1)]+ z[i+1+(*p)*(j+1)])-zmin)
				   /(zmax-zmin)))+1;
      if ( dc < 0 ) fill[jj1]= -fill[jj1];  
     
    }
  return(1);
  
}

int DPoints(integer *polyx, integer *polyy, integer *fill, integer whiteid, double zmin, double zmax, double *x, double *y, double *z, integer i, integer j, integer jj1, integer *p, integer dc, integer fg)
{
#ifdef lint
  whiteid,fill[0],zmin,zmax;
#endif
  polyx[  5*jj1] =PGEOX(x[i]  ,y[j]  ,z[i+(*p)*j]);
  if ( finite(xx1)==0 )return(0);
  polyy[  5*jj1] =PGEOY(x[i]  ,y[j]  ,z[i+(*p)*j]);
  if ( finite(yy1)==0)return(0);
  polyx[1 +5*jj1]=PGEOX(x[i]  ,y[j+1],z[i+(*p)*(j+1)]);
  if ( finite(xx1)==0 )return(0);
  polyy[1 +5*jj1]=PGEOY(x[i]  ,y[j+1],z[i+(*p)*(j+1)]);
  if ( finite(yy1)==0)return(0);
  polyx[2 +5*jj1]=PGEOX(x[i+1],y[j+1],z[(i+1)+(*p)*(j+1)]);
  if ( finite(xx1)==0 )return(0);
  polyy[2 +5*jj1]=PGEOY(x[i+1],y[j+1],z[(i+1)+(*p)*(j+1)]);
  if ( finite(yy1)==0)return(0);
  polyx[3 +5*jj1]=PGEOX(x[i+1],y[j]  ,z[(i+1)+(*p)*j]);
  if ( finite(xx1)==0 )return(0);
  polyy[3 +5*jj1]=PGEOY(x[i+1],y[j]  ,z[(i+1)+(*p)*j]);
  if ( finite(yy1)==0)return(0);
  polyx[4 +5*jj1]=PGEOX(x[i]  ,y[j]  ,z[i+(*p)*j]);
  if ( finite(xx1)==0 )return(0);
  polyy[4 +5*jj1]=PGEOY(x[i]  ,y[j]  ,z[i+(*p)*j]);
  if ( finite(yy1)==0)return(0);
  if (((polyx[1+5*jj1]-polyx[0+5*jj1])*(polyy[2+5*jj1]-polyy[0+5*jj1])-
       (polyy[1+5*jj1]-polyy[0+5*jj1])*(polyx[2+5*jj1]-polyx[0+5*jj1])) <  0)
    fill[jj1]=  (dc != 0 ) ? fg : dc ;
  else
    fill[jj1]= dc;
  return(1);
}

/*-------------------------------------------------------------------
 * param3d function 
 *-------------------------------------------------------------------*/

int C2F(param3d)(double *x, double *y, double *z, integer *n, double *teta, double *alpha, char *legend, integer *flag, double *bbox, integer lstr)
{
  static integer InsideU[4],InsideD[4];
  static double xbox[8],ybox[8],zbox[8];
  integer style[1], npoly,j;
  static integer init;
  static integer *xm,*ym;
  integer verbose=0,xz[10],narg,fg1;
  /** If Record is on **/
  if (GetDriver()=='R' && version_flag() != 0) 
    StoreParam3D("param3d",x,y,z,n,teta,alpha,legend,flag,bbox);
  C2F(dr)("xget","dashes",&verbose,xz,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  style[0]= xz[0];
  if (flag[1]!=0 && flag[1]!=1 && flag[1]!=3 && flag[1]!=5)
    {
      bbox[0]=(double) Mini(x,*n);bbox[1]=(double) Maxi(x,*n);
      bbox[2]=(double) Mini(y,*n);bbox[3]=(double) Maxi(y,*n);
      bbox[4]=(double) Mini(z,*n);bbox[5]=(double) Maxi(z,*n);
    }
  if ( flag[1] !=0)
    SetEch3d1(xbox,ybox,zbox,bbox,teta,alpha,(long)(flag[1]+1)/2);
  else 
    SetEch3d1(xbox,ybox,zbox,bbox,teta,alpha,0L);
  /** Calcule l' Enveloppe Convexe de la boite **/
  /** ainsi que les triedres caches ou non **/
  Convex_Box(xbox,ybox,InsideU,InsideD,legend,flag,bbox);
  C2F(dr)("xget","hidden3d",&verbose,&fg1,&narg, PI0, PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  /** Le triedre cache **/
  if (zbox[InsideU[0]] > zbox[InsideD[0]])
    {
      /* cache=InsideD[0];*/
      if (flag[2] >=2 ) DrawAxis(xbox,ybox,InsideD,fg1);
    }
  else 
    {
      /* cache=InsideU[0]-4; */
      if (flag[2] >=2 ) DrawAxis(xbox,ybox,InsideU,fg1);
    }

  xm = graphic_alloc(0,(*n),sizeof(int));
  ym = graphic_alloc(1,(*n),sizeof(int));
  if ( ( (xm == NULL) && *n != 0 ) || ((ym == NULL) && *n != 0)) 
    {
      Scistring("Param3d : malloc  No more Place\n");
      return(0);
    }
  init = 0 ; 
  while (1) 
    {
      int nel = 0;
      for ( j =init ; j < (*n) ; j++)	 
	{
	  xm[  nel]=PGEOX(x[j],y[j],z[j]);
	  if ( finite(xx1) ==0 ) 
	    {
	      break;
	    }
	  ym[  nel]=PGEOY(x[j],y[j],z[j]);
	  if ( finite(yy1)==0)
	    {
	      break;
	    }
	  nel++;
	}
      if ( nel > 0 ) 
	C2F(dr)("xpolys","v",xm,ym,style,(npoly=1,&npoly),&nel,
		PI0,PD0,PD0,PD0,PD0,0L,0L);
      init = j+1;
      if ( init >= (*n)) break;
    }
  if (flag[2] >=3 ) 
    {
      integer fg;
      C2F(dr)("xget","foreground",&verbose,&fg,&narg, PI0, PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
      /** Le triedre que l'on doit voir **/
      if (zbox[InsideU[0]] > zbox[InsideD[0]])
	DrawAxis(xbox,ybox,InsideU,fg);
      else 
	DrawAxis(xbox,ybox,InsideD,fg);
    }
  return(0);
}


/*-------------------------------------------------------------------
 * param3d1 function 
 *-------------------------------------------------------------------*/

int C2F(param3d1)(double *x, double *y, double *z, integer *m, integer *n, integer *iflag, integer *colors, double *teta, double *alpha, char *legend, integer *flag, double *bbox, integer lstr)
{
  static integer InsideU[4],InsideD[4];
  static double xbox[8],ybox[8],zbox[8];
  integer style[1], npoly,j;
  static integer init;
  static integer *xm,*ym;
  integer verbose=0,xz[10],narg,fg1,cur;

  /** If Record is on **/
  if (GetDriver()=='R' && version_flag() != 0) 
    StoreParam3D1("param3d1",x,y,z,m,n,iflag,colors,teta,alpha,legend,flag,bbox);
  C2F(dr)("xget","dashes",&verbose,xz,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  style[0]= xz[0];
  if (flag[1]!=0 && flag[1]!=1 && flag[1]!=3 && flag[1]!=5)
    {
      int mn=*n*(*m);
      bbox[0]=(double) Mini(x,mn);bbox[1]=(double) Maxi(x,mn);
      bbox[2]=(double) Mini(y,mn);bbox[3]=(double) Maxi(y,mn);
      bbox[4]=(double) Mini(z,mn);bbox[5]=(double) Maxi(z,mn);
    }
  if ( flag[1] !=0)
    SetEch3d1(xbox,ybox,zbox,bbox,teta,alpha,(long)(flag[1]+1)/2);
  else 
    SetEch3d1(xbox,ybox,zbox,bbox,teta,alpha,0L);
  /** Calcule l' Enveloppe Convexe de la boite **/
  /** ainsi que les triedres caches ou non **/
  Convex_Box(xbox,ybox,InsideU,InsideD,legend,flag,bbox);
  C2F(dr)("xget","hidden3d",&verbose,&fg1,&narg, PI0, PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  /** Le triedre cache **/
  if (zbox[InsideU[0]] > zbox[InsideD[0]])
    {
      /* cache=InsideD[0];*/
      if (flag[2] >=2 ) DrawAxis(xbox,ybox,InsideD,fg1);
    }
  else 
    {
      /* cache=InsideU[0]-4; */
      if (flag[2] >=2 ) DrawAxis(xbox,ybox,InsideU,fg1);
    }

  xm = graphic_alloc(0,(*m),sizeof(int));
  ym = graphic_alloc(1,(*m),sizeof(int));
  if ( ( (xm == NULL) && *m != 0 ) || ((ym == NULL) && *m != 0)) 
    {
      Scistring("Param3d : malloc  No more Place\n");
      return(0);
    }
  for ( cur=0 ; cur < *n ; cur++)
    {
      init = 0 ; 
      if ( *iflag != 0 ) style[0]=  colors[cur];
      while (1) 
	{
	  int nel = 0,j1;
	  j1= (*m)*cur;
	  for ( j =init ; j < (*m) ; j++)	 
	    {
	      xm[  nel]=PGEOX(x[j+j1],y[j+j1],z[j+j1]);
	      if ( finite(xx1) ==0 ) 
		{
		  break;
		}
	      ym[  nel]=PGEOY(x[j+j1],y[j+j1],z[j+j1]);
	      if ( finite(yy1)==0)
		{
		  break;
		}
	      nel++;
	    }
	  if ( nel > 0 ) 
	    C2F(dr)("xpolys","v",xm,ym,style,(npoly=1,&npoly),&nel,
		    PI0,PD0,PD0,PD0,PD0,0L,0L);
	  init = j+1;
	  if ( init >= (*m)) break;
	}
    }
  if (flag[2] >=3 ) 
    {
      integer fg;
      C2F(dr)("xget","foreground",&verbose,&fg,&narg, PI0, PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
      /** Le triedre que l'on doit voir **/
      if (zbox[InsideU[0]] > zbox[InsideD[0]])
	DrawAxis(xbox,ybox,InsideU,fg);
      else 
	DrawAxis(xbox,ybox,InsideD,fg);
    }
  return(0);
}


/*-------------------------------------------------------------------
 * box3d 
 *-------------------------------------------------------------------*/

int C2F(box3d)(double *xbox, double *ybox, double *zbox)
{  
 
  static integer InsideU[4],InsideD[4],flag[]={1,1,3},verbose=0,fg,narg,fg1;
  static integer ixbox[4],iybox[4], n=2, m=1;
  char * legends = NULL;
  sciPointObj * psubwin = NULL;
  sciSubWindow * ppsubwin =  NULL;
  
  char * legx = NULL;
  char * legy = NULL;
  char * legz = NULL;
  /** Calcule l' Enveloppe Convexe de la boite **/
  /** ainsi que les triedres caches ou non **/


  if (version_flag() != 0)
    Convex_Box(xbox,ybox,InsideU,InsideD,"X@Y@Z",flag,Cscale.bbox1);
  else
    {
      psubwin = (sciPointObj *)sciGetSelectedSubWin (sciGetCurrentFigure ());
      ppsubwin = pSUBWIN_FEATURE (psubwin);

      legx = sciGetText(ppsubwin->mon_x_label);
      legy = sciGetText(ppsubwin->mon_y_label);
      legz = sciGetText(ppsubwin->mon_z_label);
                  
      if ((legends = MALLOC ((strlen(legx)+
			      strlen(legy)+
			      strlen(legz)+
			      7)*sizeof (char))) == NULL)
	Scistring("box3d : No more Place to store legends (3D labels)\n");

      if(legx == NULL)
	strcpy(legends,"");
      else
	strcpy(legends,legx);
      
      strcat(legends,"@"); 
      
      if(legy == NULL)
	strcat(legends,"");
      else
	strcat(legends,legy);

      strcat(legends,"@"); 

      if(legz == NULL)
	strcat(legends,"");
      else
	strcat(legends,legz);
      
      Convex_Box(xbox,ybox,InsideU,InsideD,legends,flag,Cscale.bbox1);
      FREE(legends); legends = NULL;
    }


  /**DJ.Abdemouche 2003**/
  if (version_flag() != 0) {
    /** le triedre vu **/
    C2F(dr)("xget","foreground",&verbose,&fg,&narg, PI0, PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
    if (zbox[InsideU[0]] > zbox[InsideD[0]])
      DrawAxis(xbox,ybox,InsideU,fg);
    else 
      DrawAxis(xbox,ybox,InsideD,fg);
    C2F(dr)("xget","hidden3d",&verbose,&fg1,&narg, PI0, PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
    if (fg1==-1) fg1=0;
    /** Le triedre cache **/
    if (zbox[InsideU[0]] > zbox[InsideD[0]])
      DrawAxis(xbox,ybox,InsideD,fg1);
    else 
      DrawAxis(xbox,ybox,InsideU,fg1);
  }
  else
    {
      C2F (dr) ("xset","thickness",&m,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);    
      if (zbox[InsideU[0]] > zbox[InsideD[0]])
	DrawAxis(xbox,ybox,InsideU,2);
      else 
	DrawAxis(xbox,ybox,InsideD,2);    
      if (zbox[InsideU[0]] > zbox[InsideD[0]])
	DrawAxis(xbox,ybox,InsideD,2);
      else 
	DrawAxis(xbox,ybox,InsideU,2);
    
      ixbox[0]=XScale(xbox[0]);ixbox[1]=XScale(xbox[2]);
      ixbox[2]=XScale(xbox[1]);ixbox[3]=XScale(xbox[3]);
      iybox[0]=YScale(ybox[0]); iybox[1]=YScale(ybox[2]);
      iybox[2]=YScale(ybox[1]); iybox[3]=YScale(ybox[3]);
      C2F(dr)("xpolys","v",ixbox,iybox,&n,&m,&n,PI0,PD0,PD0,PD0,PD0,0L,0L);  
      C2F(dr)("xpolys","v",ixbox+2,iybox+2,&n,&m,&n,PI0,PD0,PD0,PD0,PD0,0L,0L); 

    }

  return(0);
}


/*-------------------------------------------------------------------
 * 3d geometric transformation 
 *-------------------------------------------------------------------*/

int C2F(geom3d)(double *x, double *y, double *z, integer *n)
{
  integer j;

  if(version_flag() == 0){
    sciPointObj * psubwin = sciGetSelectedSubWin(sciGetCurrentFigure());
    sciSubWindow * ppsubwin = pSUBWIN_FEATURE(psubwin);
    
    if(ppsubwin->logflags[0] =='l')
      for ( j =0 ; j < (*n) ; j++) {
	if(x[j] <= 0.){
	  sciprint("geom3d error : Operation can not be performed because X axis is in logscale mode and the specified x vector has a negative value\n");
	  return -1;
	}
	x[j] = log10(x[j]);
      }

    if(ppsubwin->logflags[1] =='l')
      for ( j =0 ; j < (*n) ; j++) {
	if(y[j] <= 0.){
	  sciprint("geom3d error : Operation can not be performed because Y axis is in logscale mode and the specified y vector has a negative value\n");
	  return -1;
	}
	y[j] = log10(y[j]);
      }

    if(ppsubwin->logflags[2] =='l')
      for ( j =0 ; j < (*n) ; j++) {
	if(z[j] <= 0.){
	  sciprint("geom3d error : Operation can not be performed because Z axis is in logscale mode and the specified z vector has a negative value\n");
	  return -1;
	}
	z[j] = log10(z[j]);
      }
   
    if(ppsubwin->axes.reverse[0] == TRUE)
      for ( j =0 ; j < (*n) ; j++) x[j] = InvAxis(ppsubwin->FRect[0],ppsubwin->FRect[2],x[j]);
    
    if(ppsubwin->axes.reverse[1] == TRUE)
      for ( j =0 ; j < (*n) ; j++) y[j] = InvAxis(ppsubwin->FRect[1],ppsubwin->FRect[3],y[j]);
    
    if(ppsubwin->axes.reverse[2] == TRUE)
      for ( j =0 ; j < (*n) ; j++) z[j] = InvAxis(ppsubwin->FRect[4],ppsubwin->FRect[5],z[j]);

    for ( j =0 ; j < (*n) ; j++)
      {
	double x1,y1;
	x1=TRX(x[j],y[j],z[j]);
	y1=TRY(x[j],y[j],z[j]);
	z[j]=TRZ(x[j],y[j],z[j]);
	x[j]=x1;
	y[j]=y1;
      }
  }
  else{
    for ( j =0 ; j < (*n) ; j++)	 
      {
	double x1,y1;
	x1=TRX(x[j],y[j],z[j]);
	y1=TRY(x[j],y[j],z[j]);
	z[j]=TRZ(x[j],y[j],z[j]);
	x[j]=x1;
	y[j]=y1;
      }
  }
  return(0);
}



/*-------------------------------------------------------------------
 * functions for 3D scales 
 *-------------------------------------------------------------------*/

void SetEch3d(double *xbox, double *ybox, double *zbox, double *bbox, double *teta, double *alpha)
{
  SetEch3d1(xbox,ybox,zbox,bbox,teta,alpha,1L);
}

/* 
 * if flag==1,2,3  m and bbox and Cscale are  recomputed  
 * if flag==0      we only change m without changing scales 
 */

void SetEch3d1(double *xbox, double *ybox, double *zbox, double *bbox, double *teta, double *alpha, integer flag)
{
  double xmmin=0,ymmax=0,xmmax=0,ymmin=0,FRect[4],WRect[4],ARect[4];
  integer ib;
  static integer aaint[]={2,10,2,10};
  int verbose=0,wdim[2],narg;
  char logf[2];
  double R,xo,yo,dx,dy,dz,hx,hy,hx1,hy1,Teta,Alpha;
  integer wmax=0,hmax=0;
  static double cost=0.5,sint=0.5,cosa=0.5,sina=0.5;
  Teta=*teta;
  Alpha=*alpha;
  /*  if (flag==0) {
      Alpha=Cscale.alpha;
      Teta=Cscale.theta;
      }
      else {
      Cscale.alpha = Alpha;
      Cscale.theta = Teta;
      }*/
  Cscale.alpha = Alpha;
  Cscale.theta = Teta;
  cost=cos((Teta)*M_PI/180.0);
  sint=sin((Teta)*M_PI/180.0);
  cosa=cos((Alpha)*M_PI/180.0);
  sina=sin((Alpha)*M_PI/180.0);
  Cscale.m[0][0]= -sint    ;    Cscale.m[0][1]= cost      ;    Cscale.m[0][2]= 0;
  Cscale.m[1][0]= -cost*cosa;   Cscale.m[1][1]= -sint*cosa;    Cscale.m[1][2]= sina;
  Cscale.m[2][0]=  cost*sina;   Cscale.m[2][1]= sint*sina;     Cscale.m[2][2]= cosa;
  /* Coordonn\'ees apr\`es transformation g\'eometrique de la
   * boite qui entoure le plot3d                            
   * le plan de projection est defini par x et y            
   */
  for (ib=0;ib<6 ;ib++) 
    { 
      if (flag==0) 
	bbox[ib]=Cscale.bbox1[ib];
      else 
	Cscale.bbox1[ib]=bbox[ib];
    }
  xbox[0]=TRX(bbox[0],bbox[2],bbox[4]);
  ybox[0]=TRY(bbox[0],bbox[2],bbox[4]);
  zbox[0]=TRZ(bbox[0],bbox[2],bbox[4]);
  xbox[1]=TRX(bbox[0],bbox[3],bbox[4]);
  ybox[1]=TRY(bbox[0],bbox[3],bbox[4]);
  zbox[1]=TRZ(bbox[0],bbox[3],bbox[4]);
  xbox[2]=TRX(bbox[1],bbox[3],bbox[4]);
  ybox[2]=TRY(bbox[1],bbox[3],bbox[4]);
  zbox[2]=TRZ(bbox[1],bbox[3],bbox[4]);
  xbox[3]=TRX(bbox[1],bbox[2],bbox[4]);
  ybox[3]=TRY(bbox[1],bbox[2],bbox[4]);
  zbox[3]=TRZ(bbox[1],bbox[2],bbox[4]);
  xbox[4]=TRX(bbox[0],bbox[2],bbox[5]);
  ybox[4]=TRY(bbox[0],bbox[2],bbox[5]);
  zbox[4]=TRZ(bbox[0],bbox[2],bbox[5]);
  xbox[5]=TRX(bbox[0],bbox[3],bbox[5]);
  ybox[5]=TRY(bbox[0],bbox[3],bbox[5]);
  zbox[5]=TRZ(bbox[0],bbox[3],bbox[5]);
  xbox[6]=TRX(bbox[1],bbox[3],bbox[5]);
  ybox[6]=TRY(bbox[1],bbox[3],bbox[5]);
  zbox[6]=TRZ(bbox[1],bbox[3],bbox[5]);
  xbox[7]=TRX(bbox[1],bbox[2],bbox[5]);
  ybox[7]=TRY(bbox[1],bbox[2],bbox[5]);
  zbox[7]=TRZ(bbox[1],bbox[2],bbox[5]);
  /** Calcul des echelles en fonction de la taille du dessin **/
  if ( flag == 1 || flag == 3 )
    {
      xmmin=  (double) Mini(xbox,8L);xmmax= (double) Maxi(xbox,8L);
      ymmax=  (double) - Mini(ybox,8L);
      ymmin=  (double) - Maxi(ybox,8L);
    }
  /* code added by es: isoview scaling */
  if ( flag == 2 || flag == 3 )
    {
      /* get current window size */
      C2F(dr)("xget","wdim",&verbose,wdim,&narg, PI0,PI0,PI0,
              PD0,PD0,PD0,PD0,0L,0L);
      getscale2d(WRect,FRect,logf,ARect);
      wmax=linint((double)wdim[0] * WRect[2]);
      hmax=linint((double)wdim[1] * WRect[3]); 
    }
  if ( flag == 2 )
    {
      /* radius and center of the sphere circumscribing the box */
      dx=bbox[1]-bbox[0]; dy=bbox[3]-bbox[2]; dz=bbox[5]-bbox[4];
      R= (double) sqrt(dx*dx + dy*dy + dz*dz)/2;
      xo= (double) (xbox[0]+xbox[6])/2 ;
      yo= (double) (ybox[0]+ybox[6])/2 ;
      /* zo= (double) (zbox[0]+zbox[6])/2 ; */
      xmmin=  (double) xo - R ;
      xmmax=  (double) xo + R ;
      ymmax=  (double) -yo + R ;
      ymmin=  (double) -yo - R ;
    }
  if (flag==2 || flag==3)
    {
      /* adjust limits (code adapted from Plo2d.c & Stephane's patch) */
      hx=xmmax-xmmin;
      hy=ymmax-ymmin;
      if ( hx/(double)wmax  < hy/(double)hmax ) 
        {
          hx1=wmax*hy/hmax;
          xmmin=xmmin-(hx1-hx)/2.0;
          xmmax=xmmax+(hx1-hx)/2.0;
        }
      else 
        {
          hy1=hmax*hx/wmax;
          ymmin=ymmin-(hy1-hy)/2.0;
          ymmax=ymmax+(hy1-hy)/2.0;
        }
    }
  if (flag !=0 )
    {
      FRect[0]=xmmin;FRect[1]= -ymmax;FRect[2]=xmmax;FRect[3]= -ymmin;
      set_scale("tftttf",NULL,FRect,aaint,"nn",NULL);
      Cscale.metric3d=flag; /* the metric mode is stored into the
                             * List of Scales */
    }
  /* end of code added by es */
}

/*----------------------------------------------------------------
 *Trace un triedre : Indices[4] donne les indices des points qui 
 * constituent le triedre dans les tableaux xbox et ybox 
 *-----------------------------------------------------------------*/ 

void DrawAxis(double *xbox, double *ybox, integer *Indices, integer style)
{
  integer ixbox[6],iybox[6],npoly=6,lstyle[6],verbose=0,narg,hiddencolor;
  integer i, iflag=0, j=1;
  sciPointObj *psubwin;
  for ( i = 0 ; i <= 4 ; i=i+2)
    {
      ixbox[i]=XScale(xbox[Indices[0]]);iybox[i]=YScale(ybox[Indices[0]]);
    }
  ixbox[1]=XScale(xbox[Indices[1]]);iybox[1]=YScale(ybox[Indices[1]]);
  ixbox[3]=XScale(xbox[Indices[2]]);iybox[3]=YScale(ybox[Indices[2]]);
  ixbox[5]=XScale(xbox[Indices[3]]);iybox[5]=YScale(ybox[Indices[3]]);
  C2F(dr)("xget","line style",&verbose,lstyle,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L); 
  /**DJ.Abdemouche 2003**/
  if (version_flag() == 0) { 
    psubwin = sciGetSelectedSubWin (sciGetCurrentFigure ()); 
    hiddencolor = pSUBWIN_FEATURE (psubwin)->hiddencolor;    
    if (hiddencolor == style ) 
      j= 2;
    else
      j=sciGetLineStyle (psubwin);
  }	
  /***/  
  C2F(dr)("xset","line style",&j,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  C2F(dr)("xsegs","v",ixbox,iybox,&npoly,&style,&iflag,PI0,PD0,PD0,PD0,PD0,0L,0L);
  C2F(dr)("xset","line style",lstyle,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);

}

/*---------------------------------------------------------------------
 *Trace l'enveloppe convexe de la boite contenant le dessin 
 * et renvoit dans InsideU et InsideD les indices des points dans xbox et ybox
 * qui sont sur les 2 tri\`edres a l'interieur de l'enveloppe convexe
 *---------------------------------------------------------------------*/

void Convex_Box(double *xbox, double *ybox, integer *InsideU, integer *InsideD, char *legend, integer *flag, double *bbox)
{
  double xmaxi;
  integer ixbox[8],iybox[8];
  integer xind[8];
  integer ind2,ind3,ind;
  integer p,n,dvect[1],dash[6];
  integer verbose=0,narg,pat;
  integer i,j;
  /** dans xbox[8] se trouve l'abscisse des points successifs   **/
  /** de la boite qui continent la surface                      **/
  /** on stocke dans xind[8] les indices des points de la boite **/
  /** qui sont sur l'enveloppe convexe en partant du pointeger en haut **/
  /** a droite et en tournant ds le sens trigonometrique           **/
  /** par exemple avec : **/
  /*      4 ----- 5        */
  /*       /    /|         */
  /*     7----6  |         */
  /*      | 0 | / 1        */
  /*     3----- 2          */
  /** on doit trouver xind={5,4,7,3,2,1}; **/
  /** on en profite pour stocker aussi les points des triedres **/

  xmaxi=((double) Maxi(xbox,8L));
  ind= -1;
  for (i =0 ; i < 8 ; i++)
    {
      MaxiInd(xbox,8L,&ind,xmaxi);
      if ( ind > 3)
	{
	  xind[0]=ind;
	  break;
	}
    }
  if (ind < 0 || ind > 8) 
    {
      Scistring("xind out of bounds");
      xind[0]=0;
    }
  UpNext(xind[0],&ind2,&ind3);
  if (ybox[ind2] > ybox[ind3]) 
    {
      xind[1]=ind2;InsideU[0]=ind3;
    }
  else 
    {
      xind[1]=ind3;InsideU[0]=ind2;
    }
  UpNext(ind2,&ind2,&ind3); InsideU[1]=xind[0];
  InsideU[2]=ind2; InsideU[3]=InsideU[0]-4;
  xind[2]=ind2;
  /* le pointeger en bas qui correspond */
  xind[3]=ind2-4;
  DownNext(xind[3],&ind2,&ind3);
  if (ybox[ind2] < ybox[ind3]) 
    {
      xind[4]=ind2;InsideD[0]=ind3;
    }
  else  
    {
      xind[4]=ind3;InsideD[0]=ind2;
    }
  DownNext(ind2,&ind2,&ind3);
  InsideD[1]=xind[3];
  InsideD[2]=ind2;
  InsideD[3]=InsideD[0]+4;
  xind[5]=ind2;
  for (i=0; i < 6 ; i++)
    {
      ixbox[i]=XScale(xbox[xind[i]]);
      iybox[i]=YScale(ybox[xind[i]]);
    }
  ixbox[6]=ixbox[0];iybox[6]=iybox[0];
  p=7,n=1;
  /**DJ.Abdemouche 2003**/
  if (version_flag() != 0) 
    C2F(dr)("xget","foreground",&verbose,dvect,&narg, PI0, PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  else
    dvect[0]=2;       
  /** On trace l'enveloppe cvxe **/
  C2F(dr)("xget","line style",&verbose,dash,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  C2F(dr)("xset","line style",(j=1,&j),PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  C2F (dr) ("xset","thickness",(j=1,&j),PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);     /**DJ.Abdemouche 2003**/	   
  if (flag[2]>=3){
    C2F(dr)("xpolys","v",ixbox,iybox,dvect,&n,&p
	    ,PI0,PD0,PD0,PD0,PD0,0L,0L);
  }
  C2F(dr)("xget","pattern",&verbose,&pat,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  C2F(dr)("xset","pattern",dvect,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L); 
  if (flag[2]>=3)
    AxesStrings(flag[2],ixbox,iybox,xind,legend,bbox);
  C2F(dr)("xset","pattern",&pat,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  C2F(dr)("xset","line style",dash,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);

}

/** rajoute des symboles x,y,z : sur les axes     **/
/** et une graduation sur les axes **/
/** (ixbox,iybox) : Coordonnees des points de l'envelloppe cvxe en pixel **/
/** xind : indices des points de l'enveloppe cvxe ds xbox et ybox **/

void AxesStrings(integer axflag, integer *ixbox, integer *iybox, integer *xind, char *legend, double *bbox)
{
  integer verbose=0,narg,xz[2];
  integer iof;
  char *loc = NULL;
  /*   char * buff = NULL; */
  char * legx = NULL;
  char * legy = NULL;
  char * legz = NULL;
  integer rect[4],flag=0,x,y;
  double ang=0.0;

  loc=(char *) MALLOC( (strlen(legend)+1)*sizeof(char));
  if ( loc == NULL)
    {
      Scistring("AxesString : No more Place to store Legends\n");
      return;
    }
  
  strcpy(loc,legend);
  /*   legx=strtok_r(loc,"@",&buff); */
  /*   legy=strtok_r(NULL,"@",&buff); */
  /*   legz=strtok_r(NULL,"@",&buff); */
 
  legx=strtok(loc,"@");
  legy=strtok(NULL,"@");
  legz=strtok(NULL,"@");

  /** le cot\'e gauche ( c'est tjrs un axe des Z **/
  C2F(dr)("xget","wdim",&verbose,xz,&narg, PI0, PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  iof = (xz[0]+xz[1])/50;
  if (version_flag() != 0) 
    {x=ixbox[2]-iof ;y=iybox[2]-iof;}
  else
    {x = (integer) (ixbox[2]-(xz[0]+xz[1])/20) ; y = (integer) (0.5*iybox[3]+0.5*iybox[2]);}
  /*** le z scaling ***/
  if ( axflag>=4)
    {
      double fx,fy,fz,lx,ly,lz;
      integer LPoint[2],FPoint[2],Ticsdir[2],xnax[2];
      xnax[0]=5;xnax[1]=2;
      FPoint[0]=ixbox[2];FPoint[1]=iybox[2];
      LPoint[0]=ixbox[3];LPoint[1]=iybox[3];
      Ticsdir[0]= -1;
      Ticsdir[1]=0;
      BBoxToval(&fx,&fy,&fz,xind[2],bbox);
      BBoxToval(&lx,&ly,&lz,xind[3],bbox);
      TDAxis(1L,fz,lz,xnax,FPoint,LPoint,Ticsdir);
    }
  if (legz != NULL)
    {
      C2F(dr)("xstringl",legz,&x,&y,rect,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
      C2F(dr)("xstring",legz,(x=x - rect[2],&x),&y,PI0,&flag
	      ,PI0,PI0,&ang,PD0,PD0,PD0,0L,0L);
    }
  /** le cot\^e en bas \`a gauche **/
  if (version_flag() != 0) {
    x=inint((ixbox[3]+ixbox[4])/2.0 -iof);
    y=inint((1/3.0)*iybox[3]+(2/3.0)*iybox[4]+iof);}
  else{
    x=inint((ixbox[3]+ixbox[4])/2.0 -iof);
    y=inint((1/3.0)*iybox[3]+(2/3.0)*iybox[4]+(xz[0]+xz[1])/30);}
  if ( xind[3]+xind[4] == 3)
    {
      if ( axflag>=4)
	{
	  double fx,fy,fz,lx,ly,lz;
	  integer LPoint[2],FPoint[2],Ticsdir[2],xnax[2];
	  xnax[0]=5;xnax[1]=2;
	  FPoint[0]=ixbox[3];FPoint[1]=iybox[3];
	  LPoint[0]=ixbox[4];LPoint[1]=iybox[4];
	  Ticsdir[0]=ixbox[4]-ixbox[5];
	  Ticsdir[1]=iybox[4]-iybox[5];
	  BBoxToval(&fx,&fy,&fz,xind[3],bbox);
	  BBoxToval(&lx,&ly,&lz,xind[4],bbox);
	  TDAxis(2L,fx,lx,xnax,FPoint,LPoint,Ticsdir);
	}
      if (legx != NULL)
	{

	  C2F(dr)("xstringl",legx,&x,&y,rect,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
	  C2F(dr)("xstring",legx,(x=x-rect[2],&x),&y,PI0,&flag
		  ,PI0,PI0,&ang,PD0,PD0,PD0,0L,0L);
	}
    }
  else 
    {
      if ( axflag>=4)
	{
	  double fx,fy,fz,lx,ly,lz;
	  integer LPoint[2],FPoint[2],Ticsdir[2],xnax[2];
	  xnax[0]=5;xnax[1]=2;
	  FPoint[0]=ixbox[3];FPoint[1]=iybox[3];
	  LPoint[0]=ixbox[4];LPoint[1]=iybox[4];
	  Ticsdir[0]=ixbox[4]-ixbox[5];
	  Ticsdir[1]=iybox[4]-iybox[5];
	  BBoxToval(&fx,&fy,&fz,xind[3],bbox);
	  BBoxToval(&lx,&ly,&lz,xind[4],bbox);
	  TDAxis(2L,fy,ly,xnax,FPoint,LPoint,Ticsdir);
	}
      if (legy != NULL)
	{

	  C2F(dr)("xstringl",legy,&x,&y,rect,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
	  C2F(dr)("xstring",legy,(x=x-rect[2],&x),&y,PI0,&flag
		  ,PI0,PI0,&ang,PD0,PD0,PD0,0L,0L);
	}
    }
  /** le cot\'e en bas a droite **/
  if (version_flag() != 0) {
    x=inint((ixbox[4]+ixbox[5])/2+iof);
    y=inint(((2/3.0)*iybox[4]+(1/3.0)*iybox[5])+iof); }
  else{
    x=inint((ixbox[4]+ixbox[5])/2+(xz[0]+xz[1])/30);
    y=inint(((2/3.0)*iybox[4]+(1/3.0)*iybox[5])+iof); }
  if ( xind[4]+xind[5] == 3)
    {
      if ( axflag>=4)
	{
	  double fx,fy,fz,lx,ly,lz;
	  integer LPoint[2],FPoint[2],Ticsdir[2],xnax[2];
	  xnax[0]=5;xnax[1]=2;
	  FPoint[0]=ixbox[4];FPoint[1]=iybox[4];
	  LPoint[0]=ixbox[5];LPoint[1]=iybox[5];
	  Ticsdir[0]=ixbox[4]-ixbox[3];
	  Ticsdir[1]=iybox[4]-iybox[3];
	  BBoxToval(&fx,&fy,&fz,xind[4],bbox);
	  BBoxToval(&lx,&ly,&lz,xind[5],bbox);
	  TDAxis(3L,fx,lx,xnax,FPoint,LPoint,Ticsdir); 
	}
      if (legx != NULL) 
	{
	  C2F(dr)("xstring",legx,&x,&y,PI0,&flag,PI0,PI0,&ang,PD0,PD0,PD0,0L,0L);
	}
    }
  else 
    {
      if ( axflag>=4)
	{
	  double fx,fy,fz,lx,ly,lz;
	  integer LPoint[2],FPoint[2],Ticsdir[2],xnax[2];
	  xnax[0]=5;xnax[1]=2;
	  FPoint[0]=ixbox[4];FPoint[1]=iybox[4];
	  LPoint[0]=ixbox[5];LPoint[1]=iybox[5];
	  Ticsdir[0]=ixbox[4]-ixbox[3];
	  Ticsdir[1]=iybox[4]-iybox[3];
	  BBoxToval(&fx,&fy,&fz,xind[4],bbox);
	  BBoxToval(&lx,&ly,&lz,xind[5],bbox);
	  TDAxis(3L,fy,ly,xnax,FPoint,LPoint,Ticsdir); 
	}
      if (legy != NULL) 
	{
	  C2F(dr)("xstring",legy,&x,&y,PI0,&flag,PI0,PI0,&ang,PD0,PD0,PD0,0L,0L);
	}
    }  
  FREE(loc);
}


void MaxiInd(double *vect, integer n, integer *ind, double maxi)
{
  integer i ;
  if ( *ind+1 < n)
    for (i = *ind+1 ; i < n ; i++)
      if ( vect[i] >= maxi)
	{ *ind=i; break;}
}

/* renvoit les indices des points voisins de ind1 sur la face haute 
   de la boite  */

void UpNext(integer ind1, integer *ind2, integer *ind3)
{
  *ind2 = ind1+1;
  *ind3 = ind1-1;
  if (*ind2 == 8) *ind2 = 4;
  if (*ind3 == 3) *ind3 = 7;
}

void DownNext(integer ind1, integer *ind2, integer *ind3)
{
  *ind2 = ind1+1;
  *ind3 = ind1-1;
  if (*ind2 == 4) *ind2 = 0;
  if (*ind3 == -1) *ind3 = 3;
}

void TDAxis(integer flag, double FPval, double LPval, integer *nax, integer *FPoint, integer *LPoint, integer *Ticsdir)
{
  char fornum[100];
  integer i,barlength;
  double xp, dx,dy,ticsx,ticsy,size;
  integer verbose=0,narg,xz[2];
  C2F(dr)("xget","wdim",&verbose,xz,&narg, PI0, PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  size = xz[0]>=xz[1] ? xz[1]/50.0 : xz[0]/50.0; 
  C2F(TDdrawaxis)(size,FPval,LPval,nax,FPoint,LPoint,Ticsdir) ;
  ChoixFormatE(fornum,Min(FPval,LPval),Max(LPval,FPval),
	       Abs((LPval-FPval))/nax[1]);
  xp= FPval;
  barlength=inint(1.2*size);
  dx= ((double) LPoint[0]-FPoint[0])/((double)nax[1]);
  dy= ((double) LPoint[1]-FPoint[1])/((double)nax[1]);
  if ( Ticsdir[0] == 0 && Ticsdir[1] == 0) 
    {
      ticsx= ticsy = 0;
    }
  else 
    {
      ticsx= barlength*( Ticsdir[0])/
	sqrt((double) Ticsdir[0]*Ticsdir[0]+Ticsdir[1]*Ticsdir[1]);
      ticsy= barlength*( Ticsdir[1])/
	sqrt((double) Ticsdir[0]*Ticsdir[0]+Ticsdir[1]*Ticsdir[1]);
    }
  for (i=0; i <= nax[1];i++)
    { double angle=0.0;
    integer flag1=0;
    integer xx=0,yy=0, posi[2],rect[4];
    char foo[100];/*** JPC : must be cleared properly **/
    double lp;
    lp = xp + i*(LPval-FPval)/((double)nax[1]);
    sprintf(foo,fornum,lp);   
    C2F(dr)("xstringl",foo,&xx,&yy,rect,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
    posi[0]=inint(FPoint[0]+ i*dx + 2*ticsx );
    posi[1]=inint(FPoint[1]+ i*dy + 2*ticsy +rect[3]/2 );
    switch ( flag)
      {
      case 1: posi[0] -= rect[2];
	/** pour separer ;e 1er arg de l'axe des z de l'axe voisin **/
	if ( i== nax[1]) posi[1] -= rect[3]/2;
	break;
      case 2: posi[0] -= rect[2];break;
      }
    C2F(dr)("xstring",foo,&(posi[0]),&(posi[1]),PI0,&flag1,PI0,PI0,&angle,PD0,PD0,PD0,0L,0L);
    } 
}


void C2F(TDdrawaxis)(double size, double FPval, double LPval, integer *nax, integer *FPoint, integer *LPoint, integer *Ticsdir)
{ 
  integer i;
  double dx,dy,ticsx,ticsy;
  dx= ((double) LPoint[0]-FPoint[0])/((double)nax[1]*nax[0]);
  dy= ((double) LPoint[1]-FPoint[1])/((double)nax[1]*nax[0]);
  if ( Ticsdir[0] == 0 && Ticsdir[1] == 0) 
    {
      ticsx= ticsy = 0;
    }
  else 
    {
      ticsx= ( Ticsdir[0])/
	sqrt((double) Ticsdir[0]*Ticsdir[0]+Ticsdir[1]*Ticsdir[1]);
      ticsy= ( Ticsdir[1])/
	sqrt((double) Ticsdir[0]*Ticsdir[0]+Ticsdir[1]*Ticsdir[1]);
    }
  for (i=0; i <= nax[1]*nax[0];i++)
    {       
      integer siz=2,x[2],y[2],iflag=0,style=0;
      x[0] =linint(FPoint[0]+ ((double)i)*dx );
      y[0] =linint(FPoint[1]+ ((double)i)*dy );
      x[1] =linint(x[0]+ ticsx*size);
      y[1] =linint(y[0]+ ticsy*size);
      C2F(dr)("xsegs","v",x,y,&siz,&style,&iflag,PI0,PD0,PD0,PD0,PD0,0L,0L);
    }
}


/** Returns the [x,y,z] values of a pointeger given its xbox or ybox indices **/

void BBoxToval(double *x, double *y, double *z, integer ind, double *bbox)
{
  switch ( ind)
    {
    case 0:	*x=bbox[0],*y=bbox[2],*z=bbox[4];break;
    case 1:	*x=bbox[0],*y=bbox[3],*z=bbox[4];break;
    case 2:	*x=bbox[1],*y=bbox[3],*z=bbox[4];break;
    case 3:	*x=bbox[1],*y=bbox[2],*z=bbox[4];break;
    case 4:	*x=bbox[0],*y=bbox[2],*z=bbox[5];break;
    case 5:	*x=bbox[0],*y=bbox[3],*z=bbox[5];break;
    case 6:	*x=bbox[1],*y=bbox[3],*z=bbox[5];break;
    case 7:	*x=bbox[1],*y=bbox[2],*z=bbox[5];break;
    }
}

/*-------------------------------------
 *  interactive rotation of a 3d plot 
 *--------------------------------------*/

/** Changement interactif de 3d **/
static double theta,alpha;
/* return 1 if figure has been close during rotation */
int I3dRotation(void)
{
  char driver[4];
  integer flag[3],pixmode,alumode,verbose=0,narg,ww;
  static integer iflag[]={0,0,0,0};
  double xx,yy;
  double theta0,alpha0;
  static int one=1;

  static integer modes[]={1,0};/* for xgemouse only get mouse mouvement*/ 
  sciSons *psonstmp;
  sciPointObj *psubwin= NULL, *tmpsubwin=NULL;
  sciPointObj *pold = NULL;
  /*  sciPointObj *psurface; */
  integer xr, yr;

  BOOL cube_scaling; /* TEST F.Leray 22.04.04 */


  C2F(dr1)("xget","window",&verbose,&ww,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  if (version_flag() != 0) {
    if ( Check3DPlots("v",&ww) == 0) 
      {
	wininfo("No 3d recorded plots in your graphic window");
	return 0;
      }
  }

  /**DJ.Abdemouche 2003**/
  C2F(dr)("xget","pixmap",&verbose,&pixmode,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  C2F(dr)("xget","alufunction",&verbose,&alumode,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);

  GetDriver1(driver,PI0,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0);
  if (strcmp("Rec",driver) != 0 && version_flag() !=0) 
    {
      wininfo("Use the Rec driver for 3d Rotation" );
      return 0;
    }
  else 
    {
      integer ibutton,in,iwait=0,istr=0;
      integer verbose=0,ww,narg;
      double x0,yy0,x,y,xl,yl,bbox[4];
#ifdef WIN32
      SetWinhdc();
      SciMouseCapture();
      if (version_flag() != 0)
	C2F(SetDriver)("Int",PI0,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0);
#else
      if (version_flag() != 0)
	C2F(SetDriver)("X11",PI0,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0);
#endif
      C2F(dr)("xclick","one",&ibutton,&xr,&yr,&iwait,&istr,PI0,PD0,PD0,PD0,PD0,0L,0L);
      /*C2F(dr1)("xclick","one",&ibutton,&iwait,&istr,PI0,PI0,PI0,&x0,&yy0,PD0,PD0,0L,0L);*/
      if (version_flag() != 0)
	C2F(dr1)("xclear","v",PI0,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
#ifdef WIN32
      ReleaseWinHdc();
      SciMouseRelease();
#endif
      theta=Cscale.theta ;
      alpha=Cscale.alpha ;
      theta0=theta;
      alpha0=alpha;

      ibutton=-1;
      if (version_flag() == 0)
	{
	  tmpsubwin = (sciPointObj *) sciGetSelectedSubWin (sciGetCurrentFigure ());   
          if (pFIGURE_FEATURE((sciPointObj *)sciGetCurrentFigure())->rotstyle == 0)    
	    {
	      psubwin = (sciPointObj *)CheckClickedSubwin(xr,yr);
	      /**DJ.Abdemouche 2003**/
	      if((sciPointObj *) psubwin != NULL)
		{
		  sciSetSelectedSubWin (psubwin);

		  theta0 =  pSUBWIN_FEATURE (psubwin)-> theta; 
		  alpha0 =  pSUBWIN_FEATURE (psubwin)-> alpha;
		  pSUBWIN_FEATURE (psubwin)-> is3d = TRUE;
		  Cscale.metric3d = (long)(pSUBWIN_FEATURE (psubwin)->axes.flag[1]+1)/2; 

		  /* Modif. HERE F.Leray 24.05.04 : we take advantage of update_specification_bounds and update_3dbounds previous call */
		  /* brect variable should not exist any more.*/
		  Cscale.bbox1[0] = pSUBWIN_FEATURE (psubwin)->FRect[0]; 
		  Cscale.bbox1[1] = pSUBWIN_FEATURE (psubwin)->FRect[2];
		  Cscale.bbox1[2] = pSUBWIN_FEATURE (psubwin)->FRect[1];
		  Cscale.bbox1[3] = pSUBWIN_FEATURE (psubwin)->FRect[3];
		  Cscale.bbox1[4] = pSUBWIN_FEATURE (psubwin)->FRect[4];
		  Cscale.bbox1[5] = pSUBWIN_FEATURE (psubwin)->FRect[5];
		  
		  cube_scaling =  pSUBWIN_FEATURE (psubwin)->cube_scaling;
		  if(cube_scaling == TRUE)
		    {
		      Cscale.bbox1[0] =  0.; 
		      Cscale.bbox1[1] =  1.;
		      Cscale.bbox1[2] =  0.;
		      Cscale.bbox1[3] =  1.;
		      Cscale.bbox1[4] =  0.;
		      Cscale.bbox1[5] =  1.;
		    }
		}
	      else
		{
		  wininfo("No 3d object selected");
		  return 0;
		}
	    }
          else
	    {                  
	      psonstmp = sciGetLastSons (sciGetCurrentFigure());  
	      while (psonstmp != (sciSons *) NULL)
		{  
		  if(sciGetEntityType (psonstmp->pointobj) == SCI_SUBWIN) 
		    break;   
		  psonstmp = psonstmp->pnext;
		} 
	      sciSetSelectedSubWin (psonstmp->pointobj);
	    } 
	}
      xx=1.0/Abs(Cscale.frect[0]-Cscale.frect[2]);
      yy=1.0/Abs(Cscale.frect[1]-Cscale.frect[3]);

      C2F(echelle2d)(&x0,&yy0,&xr,&yr,&one,&one,"i2f",3L);
      x0=(x0-Cscale.frect[0])*xx;
      yy0=(yy0-Cscale.frect[1])*yy;
      x=x0;y=yy0;

#ifdef WIN32
      SetWinhdc();
      SciMouseCapture();
#endif
      if (version_flag() != 0)
	C2F(dr1)("xclear","v",PI0,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
      if ( pixmode == 0 ) C2F(dr1)("xset","alufunction",(in=6,&in),PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
    
      while ( ibutton == -1 ) 
	{
	  /* dessin d'un rectangle */
	  theta= ((int)(theta0 - 180.0*(x-x0)) % 360);
	  alpha= ((int)(alpha0 + 180.0*(y-yy0)) % 360);
	  wininfo("alpha=%.1f,theta=%.1f",alpha,theta); 
	  if ( pixmode == 1) C2F(dr1)("xset","wwpc",PI0,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
	  dbox();
	  if ( pixmode == 1) C2F(dr1)("xset","wshow",PI0,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
	  C2F(dr1)("xgetmouse","one",&ibutton,&iwait,PI0,PI0,modes,PI0,&xl, &yl,PD0,PD0,0L,0L);
	  if (ibutton==-100) return 1;/* window has been closed */
	  /* effacement du rectangle */
	  dbox();
	  xx=1.0/Abs(Cscale.frect[0]-Cscale.frect[2]);
	  yy=1.0/Abs(Cscale.frect[1]-Cscale.frect[3]);
	  x=(xl-Cscale.frect[0])*xx;
	  y=(yl-Cscale.frect[1])*yy;
	}
      if ( pixmode == 0) C2F(dr1)("xset","alufunction",(in=3,&in),PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
      C2F(SetDriver)(driver,PI0,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0);
      if (version_flag() != 0)
	C2F(dr1)("xclear","v",PI0,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
      C2F(dr1)("xget","window",&verbose,&ww,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
      C2F(dr1)("xset","alufunction",&alumode,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
#ifdef WIN32
      ReleaseWinHdc();
      SciMouseRelease();
#endif
      if (version_flag() != 0)
	Tape_ReplayNewAngle("v",&ww,PI0,PI0,iflag,flag,PI0,&theta,&alpha,bbox,PD0);
      else
	{  
          if (pFIGURE_FEATURE((sciPointObj *)sciGetCurrentFigure())->rotstyle == 0){
	    pold = (sciPointObj *)sciGetSelectedSubWin (sciGetCurrentFigure ());
	    sciSetSelectedSubWin(psubwin);
	    Obj_RedrawNewAngle(psubwin,theta,alpha);
	    sciSetSelectedSubWin(pold);
	  }
	  else
            { 
	      psonstmp = sciGetSons (sciGetCurrentFigure());  
	      while (psonstmp != (sciSons *) NULL)	
		{  
		  if(sciGetEntityType (psonstmp->pointobj) == SCI_SUBWIN){
		    pold = (sciPointObj *)sciGetSelectedSubWin (sciGetCurrentFigure ());
		    sciSetSelectedSubWin(psonstmp->pointobj);
		    Obj_RedrawNewAngle(psonstmp->pointobj,theta,alpha);
		    sciSetSelectedSubWin(pold);
		  }
		  psonstmp = psonstmp->pnext;
		} 
            }
	  sciRedrawFigure(); 
	  sciSetSelectedSubWin (tmpsubwin);
	}
    }
  return 0;
}

/*
 * Win32, warning when using xor mode
 * colors are changed and black is turned to white
 * so we must use an other pattern than the black one
 * inside dbox
 */

static void dbox(void)
{
  double xbox[8],ybox[8],zbox[8];
#ifdef WIN32
  integer verbose=0,pat,pat1=3,narg,un=1;
  C2F(dr)("xget","pattern",&verbose,&pat,&narg,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  C2F(dr)("xset","pattern",&pat1,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
  C2F (dr) ("xset", "line style",&un,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
#endif/**DJ.Abdemouche 2003**/
  SetEch3d1(xbox,ybox,zbox,Cscale.bbox1,&theta,&alpha,Cscale.metric3d);
  C2F(box3d)(xbox,ybox,zbox);
#ifdef WIN32
  C2F(dr)("xset","pattern",&pat,PI0,PI0,PI0,PI0,PI0,PD0,PD0,PD0,PD0,0L,0L);
#endif
}

/**************** New functions for interpolated shading **********************
 *
 *  Added by polpoth 4/5/2000
 *
 *******************************************************************************/

int C2F(fac3d3)(double *x, double *y, double *z, integer *cvect, integer *p, integer *q, double *teta, double *alpha, char *legend, integer *flag, double *bbox, integer lstr)
{
  C2F(fac3dg)("fac3d3",3,x,y,z,cvect,p,q,teta,alpha,legend,flag,bbox);
  return(0);
}

/*---------------------------------------------------------------------------------
 *This function sorts the vertices such that the color value is in decreasing order
 *---------------------------------------------------------------------------------*/

int  triangleSort(integer *polyxin, integer *polyyin, integer *fillin, integer *polyx, integer *polyy, integer *fill)
{ 
  integer tmp,k;
  for (k=0;k<3;k++) {polyx[k]=polyxin[k]; polyy[k]=polyyin[k]; fill[k]=Abs(fillin[k]);}
      
  if (fill[0]<fill[1]) {  
    tmp=fill[0]; fill[0]=fill[1]; fill[1]=tmp;
    tmp=polyx[0]; polyx[0]=polyx[1]; polyx[1]=tmp;
    tmp=polyy[0]; polyy[0]=polyy[1]; polyy[1]=tmp;
  }
  if (fill[0]<fill[2]) {  
    tmp=fill[0]; fill[0]=fill[2]; fill[2]=tmp;
    tmp=polyx[0]; polyx[0]=polyx[2]; polyx[2]=tmp;
    tmp=polyy[0]; polyy[0]=polyy[2]; polyy[2]=tmp;
  }
  if (fill[1]<fill[2]) {  
    tmp=fill[1]; fill[1]=fill[2]; fill[2]=tmp;
    tmp=polyx[1]; polyx[1]=polyx[2]; polyx[2]=tmp;
    tmp=polyy[1]; polyy[1]=polyy[2]; polyy[2]=tmp;
  }
  return 0;
}


/*-----------------------------------------------------------------------
 * This is the main shading function. When the polygone has 4 vertices, it
 * is splitted in two triangles and shade() is recursively called twice.
 * Author : mottelet 2000 
 * XXXX: remplacer les malloc par graphic_alloc pour uniformiser avec les autres 
 *       routines 
 *-----------------------------------------------------------------------*/

int scilab_shade(integer *polyx, integer *polyy, integer *fill, integer polysize, integer flag)
{
  integer px[5],py[5],fil[4],is[3],ie[3],n[3];
  integer npoly=1,k,col,cols,psize,i,s,e;
  integer polyxs[4],polyys[4],fills[4],*x[3],*y[3];
  double dx,dy;

  if (polysize == 3) { /* The triangle case */
 
    triangleSort(polyx,polyy,fill,polyxs,polyys,fills);
  
    is[0]=0; ie[0]=1;
    is[1]=1; ie[1]=2;
    is[2]=0; ie[2]=2;
     
    /* Computation of coordinates of elementary polygons for each side */
     
    for(i=0;i<3;i++) {

      s=is[i];
      e=ie[i];
      n[i]=fills[s]-fills[e];

      if (n[i]) {
	
	x[i]=(integer *)MALLOC((n[i]+2)*sizeof(integer));
	y[i]=(integer *)MALLOC((n[i]+2)*sizeof(integer)); 
	if (x[i]==NULL || y[i]==NULL) {
	  Scistring("shade : MALLOC No more Place\n");
	  return 0;
	}
		
	dx=((double)(polyxs[e]-polyxs[s]))/(double)n[i];
	dy=((double)(polyys[e]-polyys[s]))/(double)n[i];

	x[i][0]=polyxs[s];
	y[i][0]=polyys[s];
	   
	for(k=0;k<n[i];k++) {
	  x[i][k+1]=linint((double)polyxs[s] + (0.5+k)*dx);
	  y[i][k+1]=linint((double)polyys[s] + (0.5+k)*dy);
	}
	   
	x[i][n[i]+1]=polyxs[e];
	y[i][n[i]+1]=polyys[e];
      }
    }
     
    /* Fill the whole triangle with color fill[1] if all colors are equal */
         
    if (!n[0] && !n[1]) {

      psize=3;
      col=fills[0];
      C2F(dr)("xliness","str",polyxs,polyys,(cols=-Abs(col),&cols),&npoly,&psize ,PI0,PD0,PD0,PD0,PD0,0L,0L);
      /*          return(0);*/
    }
     
    if (n[0]) {
      psize=4;
      col=fills[0];  
      for(i=0;i<=n[0];i++) {
	px[0]=x[2][i]; px[1]=x[0][i]; px[2]=x[0][i+1]; px[3]=x[2][i+1];
	py[0]=y[2][i]; py[1]=y[0][i]; py[2]=y[0][i+1]; py[3]=y[2][i+1];
	C2F(dr)("xliness","str",px,py,(cols=-Abs(col),&cols),&npoly,&psize ,PI0,PD0,PD0,PD0,PD0,0L,0L);
	col--;
      }
      FREE(x[0]);
      FREE(y[0]);
    }
     
    if (n[1]) {
      psize=4;
      col=fills[1];
      for(i=0;i<=n[1];i++) {
	px[0]=x[2][n[0]+i]; px[1]=x[1][i]; px[2]=x[1][i+1]; px[3]=x[2][n[0]+i+1];
	py[0]=y[2][n[0]+i]; py[1]=y[1][i]; py[2]=y[1][i+1]; py[3]=y[2][n[0]+i+1];
	C2F(dr)("xliness","str",px,py,(cols=-Abs(col),&cols),&npoly,&psize ,PI0,PD0,PD0,PD0,PD0,0L,0L);
	col--;
      }
      FREE(x[1]);
      FREE(y[1]);  
    }

    if (n[2]) {
      FREE(x[2]);
      FREE(y[2]);
    }

  }
   
  else { /* The 4 vertices case  */
     
    px[0]=polyx[0]; px[1]=polyx[1]; px[2]=polyx[2];
    py[0]=polyy[0]; py[1]=polyy[1]; py[2]=polyy[2];
    fil[0]=fill[0]; fil[1]=fill[1]; fil[2]=fill[2];
    scilab_shade(px,py,fil,3,-1);

    px[0]=polyx[0]; px[1]=polyx[2]; px[2]=polyx[3];
    py[0]=polyy[0]; py[1]=polyy[2]; py[2]=polyy[3];
    fil[0]=fill[0]; fil[1]=fill[2]; fil[2]=fill[3];
    scilab_shade(px,py,fil,3,-1);
  }
   
  /* If flag>0 then the contour is drawn */
   
  if (flag > 0) { 
    fil[0]=0;
    polysize+=1;
    C2F (dr) ("xliness", "str", polyx, polyy, fil, &npoly,
	      &polysize, PI0, PD0, PD0, PD0, PD0, 0L, 0L);
  }
  return 0;
}     


