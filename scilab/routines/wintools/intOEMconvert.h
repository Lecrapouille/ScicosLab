/*-----------------------------------------------------------------------------------*/
/* INRIA 2005 */
/* Allan CORNET */
/*-----------------------------------------------------------------------------------*/ 
#ifndef __INTOEMCONVERT__
#define __INTOEMCONVERT__

#ifdef WIN32
#include <windows.h>
#endif

#include <stdio.h>
#include "../machine.h"
#include "../stack-c.h"
#include "../version.h"


#ifndef NULL
#define NULL 0
#endif

#define TRUE  1
#define FALSE 0

int C2F(intoemtochar) _PARAMS((char *fname));
int C2F(intchartooem) _PARAMS((char *fname));

#endif /* __INTOEMCONVERT__ */
/*-----------------------------------------------------------------------------------*/ 
