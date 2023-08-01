#ifndef __MATEXPATSCI__
#define __MATEXPATSCI__

#ifdef WIN32
  #include <windows.h>
  #include <stdio.h>
#endif
#include <string.h>
#include "../machine.h"
#include "../stack-c.h"

typedef int (*des_interf) __PARAMS((char *fname,unsigned long l));

typedef struct table_struct {
  des_interf f;
  char *name;
} intexpatsciTable;

#endif /*  __MATEXPATSCI__ */
