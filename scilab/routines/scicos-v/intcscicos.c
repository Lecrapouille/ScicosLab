
#include <string.h>
#include <stdio.h>
#include <math.h>
#undef Top
#include "../stack-c.h"
#define Top C2F(vstk).top


int intendscicosim( char *fname,unsigned long fname_len)
{
  CheckRhs(-1,0);
  Scierror(999,"%s: This version do not contain scicos code.\r\n",fname);
  return 0;
}

int inttimescicos( char *fname,unsigned long fname_len)
{
  Scierror(999,"%s: This version do not contain scicos code.\r\n",fname);
  return 0;
}

int intduplicate ( char *fname,unsigned long fname_len)
{
  Scierror(999,"%s: This version do not contain scicos code.\r\n",fname);
  return 0;
}

int intdiffobjs( char *fname,unsigned long fname_len)
{
  int i,j,l3,k;
  int size1;int size2;
  int *header1;int *header2;
  CheckRhs(2,2);
  CheckLhs(1,1);
  header1 = GetData(1);
  header2 = GetData(2);
  CreateVar(3,"d",(i=1,&i),(j=1,&j),&l3);
  LhsVar(1) = 3;
  size1=2*(*Lstk(Top-Rhs+2)-*Lstk(Top-Rhs+1));
  size2=2*(*Lstk(Top-Rhs+3)-*Lstk(Top-Rhs+2));

  if (size1 != size2) {
    *stk(l3)=1;
    return 0;
  }
  for (k=0; k<size1; k++) {
    if (header1[k] != header2[k]) {
      *stk(l3)=1;
      return 0;
    }
    *stk(l3)=0;

  }
  return 0;
}

int inttree2( char *fname,unsigned long fname_len)
{
  return 0;
}

int inttree3( char *fname,unsigned long fname_len)
{
  return 0;
}

int inttree4(char *fname,unsigned long fname_len)
{
  return 0;
}

int intxproperty(char *fname,unsigned long fname_len)
{
  return 0;
}

int intphasesim(char *fname,unsigned long fname_len)
{
  return 0;
}

int intsetxproperty(char *fname,unsigned long fname_len)
{
  return 0;
}


int intsetblockerror(char *fname,unsigned long fname_len)
{
  return 0;
}


int intcoserror(char *fname,unsigned long fname_len)
{
  return 0;
}



int intscicosimc(char *fname,unsigned long fname_len)
{
 return 0;
}

int intbuildouttb(char *fname,unsigned long fname_len)
{
 return 0;
}

int intpermutobj_c(char *fname,unsigned long fname_len)
{
 return 0;
}

int intscixstringb(char *fname,unsigned long fname_len)
{
  return 0;
}
