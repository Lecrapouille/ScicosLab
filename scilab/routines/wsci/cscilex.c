/*
 * Copyright (C) 2005 INRIA Allan CORNET 
 * Modified for mingw32 jpc 2008 
 */

#include <windows.h>
#include "stdio.h"
#include "../os_specific/win_mem_alloc.h" /* MALLOC */

extern int Console_Main(int argc, char **argv);
#define MAXCMDTOKENS 128

int main (int argc, char **argv)
{
  /* 
     HINSTANCE hinstLib; 
     BOOL fFreeResult, fRunTimeLinkSuccess = FALSE; 
  */
  int argcbis=-1;
  LPSTR argvbis[MAXCMDTOKENS];
  int i=0;
  int FindNW=0;

  for (i=0;i<argc;i++)
    {
      if ( (strcmp(argv[i],"-nw")==0) || (strcmp(argv[i],"-NW")==0) ) FindNW=1;
      if ( (strcmp(argv[i],"-nwni")==0) || (strcmp(argv[i],"-NWNI")==0) ) FindNW=1;
      if ( (strcmp(argv[i],"-nogui")==0) || (strcmp(argv[i],"-NOGUI")==0) ) FindNW=1;
    }

  if (FindNW==0)
    {
      char *nwparam=NULL;
      nwparam=(char*)MALLOC((strlen("-nw")+1)*sizeof(char));
      strcpy(nwparam,"-nw");
      for (i=0;i<argc;i++)
	{
	  argvbis[i]=argv[i];
	}
      argvbis[argc]=nwparam;
      argcbis=argc+1;
    }
  else
    {
      for (i=0;i<argc;i++)
	{
	  argvbis[i]=argv[i];
	}
      argcbis=argc;
    }
    	
  Console_Main(argcbis,argvbis);
  return 0;
}

