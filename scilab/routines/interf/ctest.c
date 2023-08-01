/*
 *    Copyright (C) 1998-2009 Enpc/Jean-Philippe Chancelier
 *    jpc@cermics.enpc.fr 
 */

#include <stdio.h>
#include <string.h>
#include "../machine.h"

int C2F(ctest)(char *str, int *lstr, long int ilstr)
{
  int i;
  fprintf(stderr,"The string transmitted [");
  for (i=0;i<*lstr;i++)
    fprintf(stderr,"%c",str[i]);
  fprintf(stderr,"]\n");
  strncpy(str,"A returned\n string\n",*lstr);
  fprintf(stderr,"and now [%s],%d\n",str,strlen(str));
  *lstr=strlen(str);
  return 0;
}


int C2F(cvs2c)(int *n, int *line, char *str, int *csiz, char *alfa, char *alfb, long int lstr, long int lalfa, long int lalfb)
{
  int eol=99,j;
  for (j=0; j < *n; j++)
    {
      int m=line[j];
      if ( m > *csiz || m < - *csiz) m=eol;
      if ( m == eol )
	str[j]= '\n';
      else
	str[j]= ( m < 0) ? alfb[-m] : alfa[m];
    }
  return 0;
}

int C2F(cvc2s)(int *n, int *line, char *str, int *csiz, char *alfa, char *alfb, long int lstr, long int lalfa, long int lalfb)
{
  int eol=99,j ;
  for (j = *n-1; j >= 0 ; j--)
    {
      int k,flag=0;
      char mc=str[j];
      for ( k =0 ; k < *csiz; k++)
	{
	  if (mc == alfa[k] ) {
	    line[j]=k; flag=1;break;}
	  else  
	    if ( mc == alfb[k] ) 
	      {
		line[j] = -(k); flag=1;break;}
	}
      if (flag==0) line[j]= eol;
    }
  return 0;
}







