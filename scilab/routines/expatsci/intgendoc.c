#include <string.h>
#include <stdio.h>
/* */
#include "../stack-c.h"
#include "../mex.h"
/* */

extern int C2F(cvstr)  __PARAMS((integer *,integer *,char *,
                                 integer *,unsigned long int));

/* Remove blanks and tabulations at the
 * beginning of character string
 */
int intstripblanks_begin_c(char *fname)
{
  /* */
  static int *il_str;
  static int n,m;
  /* */
  int i,j,k,pos;
  int sz_str;
  char **name;

  /*begins that work with GetData*/
  il_str=(int *)GetData(1);
  /* */
  if(il_str[0]!=10)
  {
   /*empty object case*/
   if(il_str[0]==1)
   {
    //sciprint("n=%d,m=%d\n",il_str[1],il_str[2]);
    if ((il_str[1]==0)&&(il_str[2]==0))
    {
     LhsVar(1)=1;
     return 0;
    }
   }
   Scierror(55,"%s : "
               "First argument must be a string.\n",
               fname);
   return 0;
  }
  /* */
  n=il_str[1];
  m=il_str[2];

  /* */
  name=malloc(n*m*sizeof(char*));
  pos=n*m+5;

  /* */
  for (i=0;i<n*m;i++)
  {
    sz_str=il_str[5+i]-il_str[4+i];
//     sciprint("sz_str(%d)=%d\n",i,sz_str);
    C2F(cha1).buf[0]=' ';
    C2F(cvstr)(&sz_str,&il_str[pos],&C2F(cha1).buf[0],
               (j=1,&j),sz_str);
    C2F(cha1).buf[sz_str]='\0';
    /* */
    k=0;
    if (sz_str!=0)
    {
      while ((C2F(cha1).buf[k]==' ')||
             (C2F(cha1).buf[k]=='\t'))
               k++;
    }
    /* */
    name[i]=malloc((sz_str-k)*sizeof(char*));
    strcpy(name[i],&C2F(cha1).buf[k]);
    /* */
    pos=pos+sz_str;
  }
  /* */
  CreateVarFromPtr(2,"S",&n,&m,name);
  /* */
  LhsVar(1)=2;

  /* */
  for (i=0;i<n*m;i++) free(name[i]);
  free(name);

  return 0;
}

/* Remove blanks and tabulations at the
 * end of character string
 */
int intstripblanks_end_c(char *fname)
{
  /* */
  static int *il_str;
  static int n,m;
  /* */
  int i,j,k,pos;
  int sz_str;
  char **name;

  /*begins that work with GetData*/
  il_str=(int *)GetData(1);
  /* */
  if(il_str[0]!=10)
  {
   /*empty object case*/
   if(il_str[0]==1)
   {
    //sciprint("n=%d,m=%d\n",il_str[1],il_str[2]);
    if ((il_str[1]==0)&&(il_str[2]==0))
    {
     LhsVar(1)=1;
     return 0;
    }
   }
   Scierror(55,"%s : "
               "First argument must be a string.\n",
               fname);
   return 0;
  }
  /* */
  n=il_str[1];
  m=il_str[2];

  /* */
  name=malloc(n*m*sizeof(char*));
  pos=n*m+5;

  /* */
  for (i=0;i<n*m;i++)
  {
    sz_str=il_str[5+i]-il_str[4+i];
    C2F(cha1).buf[0]=' ';
    C2F(cvstr)(&sz_str,&il_str[pos],&C2F(cha1).buf[0],
               (j=1,&j),sz_str);
    /* */
    k=0;
    if (sz_str!=0)
    {
      while ((C2F(cha1).buf[sz_str-k-1]==' ')||
             (C2F(cha1).buf[sz_str-k-1]=='\t'))
               k++;
    }
    C2F(cha1).buf[sz_str-k]='\0';
    /* */
    name[i]=malloc((sz_str-k+1)*sizeof(char*));
    strcpy(name[i],C2F(cha1).buf);
    /* */
    pos=pos+sz_str;
  }
  /* */
  CreateVarFromPtr(2,"S",&n,&m,name);
  /* */
  LhsVar(1)=2;

  /* */
  for (i=0;i<n*m;i++)
  {
   free(name[i]);
  }
  free(name);

  return 0;
}

/* Remove empty lines in a row or
 * column character string matrix
 * at the beginning and at the end
 */
int intstripemptylines_c(char *fname)
{
  /* */
  static int *il_str;
  static int n,m;
  /* */
  int i,j,k,pos;
  int newsize,nm;
  int typ;
  int sz_str;
  char **name=NULL;

  /*begins that work with GetData*/
  il_str=(int *)GetData(1);
  /* */
  if(il_str[0]!=10)
  {
   /*empty object case*/
   if(il_str[0]==1)
   {
    //sciprint("n=%d,m=%d\n",il_str[1],il_str[2]);
    if ((il_str[1]==0)&&(il_str[2]==0))
    {
     LhsVar(1)=1;
     return 0;
    }
   }
   Scierror(55,"%s : "
               "First argument must be a string.\n",
               fname);
   return 0;
  }
  /* */
  n=il_str[1];
  m=il_str[2];
  /* */
  if ((n==1)&&(m>1)) typ=1;
  else if ((n>1)&&(m==1)) typ=2;
  else if ((n==1)&&(m==1))
  {
   LhsVar(1)=1;
   return 0;
  }
  else
  {
   Scierror(999,"%s : "
                "Bad size parameter.\n"
                "Only row or column character string\n"
                "matrix are allowed.\n",
                fname);
   return 0;
  }

  /* */
  newsize=0;
  nm=n*m;
  k=0;

  /* */
  pos=n*m+5;
  for (i=0;i<nm;i++)
  {
    sz_str=il_str[5+i]-il_str[4+i];
    /* */
    if ((sz_str!=0)||k==1)
    {
      newsize++;
      name=(char **)realloc(name,newsize*sizeof(char *));
      /* la convertion est inutile !!
       * elle n'est faite que pour faire
       * la compatibilité avec CreateVarFromPtr(,"S",...)
       */
      C2F(cha1).buf[0]=' ';
      C2F(cvstr)(&sz_str,&il_str[pos],&C2F(cha1).buf[0],
                 (j=1,&j),sz_str);
      C2F(cha1).buf[sz_str]='\0';
      name[newsize-1]=(char *)malloc((sz_str+1)*sizeof(char));
      strcpy(name[newsize-1],C2F(cha1).buf);
      k=1;
    }
    /* */
    pos=pos+sz_str;
  }

  /* */
  for (i=newsize-1;i>=0;i--)
  {
   if (strlen(name[i])!=0) break;
  }
  newsize=i+1;

  /* To disable bug for empty string*/
  if (newsize == 0)
  {
   k=1;
   name=(char **)realloc(name,sizeof(char *));
   name[0]=(char *)malloc(sizeof(char));
   name[0]="";
  }
  else k=newsize;

  /* */
  if (typ==1) {
    CreateVarFromPtr(2,"S",&n,&k,name); }
  else {
    CreateVarFromPtr(2,"S",&k,&m,name); }

  /* */
  LhsVar(1)=2;

  /* */
  for (i=0;i<newsize;i++)
  {
    free(name[i]);
  }
  free(name);

  return 0;
}


static GenericTable Tab[]={
{(Myinterfun)sci_gateway,intstripblanks_begin_c,
  "stripblanks_begin"},
{(Myinterfun)sci_gateway,intstripblanks_end_c,
  "stripblanks_end"},
{(Myinterfun)sci_gateway,intstripemptylines_c,
  "striplines"},
};

int C2F(intgendoc)()
{  Rhs = Max(0, Rhs);
(*(Tab[Fin-1].f))(Tab[Fin-1].name,
   Tab[Fin-1].F);
  return 0;
}
