/* Copyright Scilab Inria/Enpc */

#include "../machine.h"
#include "../version.h"

extern void sciprint __PARAMS((char *fmt,...));
extern int sci_show_banner ; 

#ifdef WIN32
#define BANNER_SEP  sciprint("        ___________________________________________\r\n")
#else
#define BANNER_SEP  sciprint("        -------------------------------------------\r\n")
#endif

void banner(void)
{
  BANNER_SEP;
  sciprint("                     %s\r\n",SCILAB_VERSION);
  sciprint("                    %s\r\n\n",SCILAB_VERSION_ALIAS);
  sciprint("           Copyright (c) 1989-2011 (INRIA, ENPC)\r\n");
  sciprint("              (Fri Oct 30 17:06:49 CET 2020)\r\n");
  BANNER_SEP;
}

int C2F(banier)(integer *flag)
{
  if (*flag != 999 && sci_show_banner == 1)
    {
      banner();
    }
  return 0;
} 



