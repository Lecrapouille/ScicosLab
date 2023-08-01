/*
 * INRIA 2006
 * Allan CORNET
 */

#ifndef __FIGURETOFILE__
#define __FIGURETOFILE__

#include <windows.h>
#include "../machine.h"
#include "../stack-c.h"
#include "../version.h"
#include "../graphics/scigraphic.h"
#include "../graphics/Graphics.h"

#include "wgraph.h"
#include "wgnuplib.h"
#include "Messages.h"
#include "Warnings.h"
#include "Errors.h"
#include "SciEnv.h" 

#ifndef NULL
#define NULL 0
#endif

#ifndef TRUE
#define TRUE  1
#endif 

#ifndef FALSE 
#define FALSE 0
#endif 

extern void dos2win32 (char *filename, char *filename1);
extern char * GetFileExtension(char* filename);

#endif /* __TEXTTOFILE__ */

