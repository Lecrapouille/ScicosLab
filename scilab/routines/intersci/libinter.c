#include <string.h>
#include "../machine.h"

#include "../os_specific/men_Sutils.h"
#include "libinter.h"

extern int C2F(cvstr)  __PARAMS((integer *n, integer *line, char *str, integer *job, unsigned long str_len));

#include "sparse.h"

#ifdef _WIN32
#include "../os_specific/win_mem_alloc.h" /* MALLOC */
#else
#include "../os_specific/sci_mem_alloc.h" /* MALLOC */
#endif



extern void C2F(erro)();
extern void C2F(out)();

/*--------------------------------------------------------------
 * A set of functions used with intersci 
 *--------------------------------------------------------------*/

/*--------------------------------------------------------------
 * cchar : copy char ** to Scilab string code 
 *         converts ip      -> op    
 *                 char ** -> int * 
 *--------------------------------------------------------------*/

void C2F(cchar)(n,ip,op)
     int *n;
     char **ip;
     int *op;
{
  int i = 0;
  F2C(cvstr)(n,op,*ip,&i,*n);
}

/*--------------------------------------------------------------
 * ccharf : copy char ** to Scilab string code and ip is freed
 *         converts ip      -> op    
 *                 char ** -> int * 
 *--------------------------------------------------------------*/

void C2F(ccharf)(n,ip,op)
     int *n;
     char **ip;
     int *op;
{
  int i = 0;
  if (*n > 0) {
    F2C(cvstr)(n,op,*ip,&i,*n);
    FREE(*ip);
  }
}

/*--------------------------------------------------------------
 * cdouble  : copy double ** to double * 
 *--------------------------------------------------------------*/
   
void C2F(cdouble)(n,ip,op)
     int *n;
     double *ip[];
     double *op;
{
  int i;
  for (i = 0; i < *n; i++) op[i]=(*ip)[i];
}

/*--------------------------------------------------------------
 * cdoublef  : copy double ** to double *  and ip is freed
 *--------------------------------------------------------------*/

void C2F(cdoublef)(n,ip,op)
     int *n;
     double *ip[];
     double *op;
{
  int i;
  if ( *n >0 ) {
    for (i = 0; i < *n; i++)  op[i]=(*ip)[i];
    FREE((char *)(*ip));
  }
}

/*--------------------------------------------------------------
 * cint  : copy int ** to double * 
 *--------------------------------------------------------------*/

void C2F(cint)(n,ip,op)
     int *n;
     int *ip[];
     double *op;
{
  int i;
  for (i = 0; i < *n; i++)  op[i]=(double)(*ip)[i];
}

/*--------------------------------------------------------------
 * cintf  : copy int ** to double * + pointer is freed 
 *--------------------------------------------------------------*/

void C2F(cintf)(n,ip,op)
     int *n;
     int *ip[];
     double *op;
{
  int i;
  if ( *n > 0 ) {
    for (i = 0; i < *n; i++)
      op[i]=(double)(*ip)[i];
    FREE((char *)(*ip));
  }
}

/*--------------------------------------------------------------
 * cfloat  : copy float ** to double * 
 *--------------------------------------------------------------*/

void C2F(cfloat)(n,ip,op)
     int *n;
     float *ip[];
     double *op;
{
  int i;
  for (i = 0; i < *n; i++)  op[i]=(double)(*ip)[i];
}

/*--------------------------------------------------------------
 * cfloatf  : copy float ** to double * + pointer is freed 
 *--------------------------------------------------------------*/

void C2F(cfloatf)(n,ip,op)
     int *n;
     float *ip[];
     double *op;
{
  int i;
  if ( *n > 0 ) {
    for (i = 0; i < *n; i++)
      op[i]=(double)(*ip)[i];
    FREE((char *)(*ip));
  }
}

/*--------------------------------------------------------------
 * cbool  : copy int ** to int * 
 *--------------------------------------------------------------*/

void C2F(cbool)(n,ip,op)
     int *n;
     int *ip[];
     int *op;
{
  int i;
  for (i = 0; i < *n; i++)  op[i]= (*ip)[i];
}

/*--------------------------------------------------------------
 * cboolf : copy int ** to int * + pointer is freed 
 *--------------------------------------------------------------*/

void C2F(cboolf)(n,ip,op)
     int *n;
     int *ip[];
     int *op;
{
  int i;
  if ( *n > 0 ) {
    for (i = 0; i < *n; i++)
      op[i]= (*ip)[i];
    FREE((char *)(*ip));
  }
}


/*--------------------------------------------------------------
 * cerro : just call erro 
 *--------------------------------------------------------------*/

void cerro(str)
     char *str;
{
  C2F(erro)(str, strlen(str) + 1);
}

/*--------------------------------------------------------------
 * Cout : call to out 
 *--------------------------------------------------------------*/

void Cout(str)
     char *str;
{
  C2F(out)(str,strlen(str) + 1);
}

/*--------------------------------------------------------------
 * cstringf : copy char *** to int *  + pointer is freed 
 *         converts ip      -> op    
 *                 char **  -> int * 
 *     string array pointer -> Scilab code of string matrix in an int array       
 *--------------------------------------------------------------*/

void C2F(cstringf)(ip,sciptr,m,n,max,ierr)
     char ***ip;
     int *sciptr;
     int *m, *n, *max,*ierr;
{
  int i,j,l,ie;
  int job=0;
  int *chars;
  *ierr=0;
  if (5 + *m * *n > *max) {
    *ierr = 1;
    return;
  }
  sciptr[0]=10;
  sciptr[1]=*m;
  sciptr[2]=*n;
  sciptr[3]=0;
  sciptr[4]=1;
  chars=&(sciptr[5 + *m * *n]);
  ie=0;
  for (j = 0; j < *n; j++) {
    for (i = 0; i < *m; i++) {
      l=strlen((*ip)[ie]);
      sciptr[ie+5]=sciptr[ie+4]+l;
      if (5 + *m * *n + sciptr[ie+5] > *max) {
        *ierr = 1;
        return;
      }
      F2C(cvstr)(&l,&(chars[sciptr[ie+4]-1]),(*ip)[ie],&job,l);
      FREE((*ip)[ie]);
      ie++;
    }
  }
  FREE((char *)*ip);
}


/*--------------------------------------------
 * stringc : fill *cptr with 
 *      a converted Scilab string matrix 
 *      *cptr is allocated 
 *--------------------------------------------*/

int C2F(stringc)(sciptr,cptr,ierr)
     int *sciptr;
     char ***cptr;
     int *ierr;
{
  char **strings,*p;
  int li,ni,*SciS,i,nstring,*ptrstrings;
  
  *ierr=0;
  nstring=sciptr[1]*sciptr[2];
  strings=(char **) MALLOC((unsigned) (nstring * sizeof(char *)));
  if (strings==0) {
    *ierr=1; return 0;
  }
  li=1;
  ptrstrings=&(sciptr[4]);
  SciS=&(sciptr[5+nstring]);
  for ( i=1 ; i<nstring+1 ; i++) 
    {
      ni=ptrstrings[i]-li;
      li=ptrstrings[i];
      ScilabStr2C(&ni,SciS,&p,ierr);
      strings[i-1]=p;
      if ( *ierr == 1) return 0;
      SciS += ni;
    }
  *cptr=strings;
  return 0;
}

/*--------------------------------------------------------------
 * dbl2cdbl  : fill *ip with contents of double array op 
 *--------------------------------------------------------------*/

void C2F(dbl2cdbl)(n,ip,op)
     int *n;
     double *ip[];
     double *op;
{
  int i;
  for (i = 0; i < *n; i++)  (*ip)[i]=op[i];
}

/*--------------------------------------------------------------
 * freeptr : free ip pointer 
 *--------------------------------------------------------------*/

void C2F(freeptr)(ip)
     double *ip[];
{ 
  FREE((char *)(*ip));
}

/*--------------------------------------------------------------
 * int2cint  : fill *ip with contents of int array op 
 *--------------------------------------------------------------*/

void C2F(int2cint)(n,ip,op)
     int *n;
     integer *ip[];
     integer *op;
{
  int i;
  for (i = 0; i < *n; i++)  (*ip)[i]=op[i];
}

/*--------------------------------------------------------------
 * New Sparse matrix 
 *--------------------------------------------------------------*/

SciSparse *NewSparse(it,m,n,nel)
     int *m,*n,*nel,*it;
{
  SciSparse *loc;
  loc = (SciSparse *) MALLOC((unsigned) sizeof(SciSparse));
  if ( loc == (SciSparse *) 0)
    {
      return((SciSparse *) 0);
    }
  loc->m = *m;
  loc->n = *n;
  loc->it = *it;
  loc->nel = *nel;
  loc->mnel = (int*) MALLOC((unsigned) (*m)*sizeof(int));
  if ( loc->mnel == (int *) 0)
    {
      FREE(loc);
      return((SciSparse *) 0);
    }
  loc->icol = (int*) MALLOC((unsigned) (*nel)*sizeof(int));
  if ( loc->icol == (int *) 0)
    {
      FREE(loc->mnel);
      FREE(loc);
      return((SciSparse *) 0);
    }
  loc->R =  (double*) MALLOC((unsigned) (*nel)*sizeof(double));
  if ( loc->R == (double *) 0)
    {
      FREE(loc->icol);
      FREE(loc->mnel);
      FREE(loc);
      return((SciSparse *) 0);
    }

  if ( *it == 1) 
    {
      loc->I =  (double*) MALLOC((unsigned) (*nel)*sizeof(double));
      if ( loc->I == (double *) 0)
	{
	  FREE(loc->R);
	  FREE(loc->icol);
	  FREE(loc->mnel);
	  FREE(loc);
	  return((SciSparse *) 0);
	}
    }
  return(loc);
}

/*-------------------------------------------------
 * FreeSparse : free memory  associated to a sparse 
 *-------------------------------------------------*/

void FreeSparse(x)
     SciSparse *x;
{
  if ( x->it == 1 ) FREE(x->I);
  FREE(x->R);
  FREE(x->icol);
  FREE(x->mnel);
  FREE(x);
}

/*--------------------------------------------
 * intersci external function for sparse 
 *--------------------------------------------*/

int C2F(csparsef)(x,mnel,icol,R,I)
     SciSparse **x;
     int *mnel,*icol;
     double *R,*I;
{
  int i;
  for ( i=0 ; i < (*x)->m ; i++) 
    mnel[i] = (*x)->mnel[i];
  for ( i=0 ; i < (*x)->nel ; i++) 
    {
      icol[i] = (*x)->icol[i];
      R[i] = (*x)->R[i];
      if ( (*x)->it == 1 )I[i] = (*x)->I[i];
    }
  FreeSparse(*x);
  return 0;
}

