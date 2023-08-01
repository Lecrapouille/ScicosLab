#ifndef __SCIENV_H__
#define __SCIENV_H__

/* Allan CORNET 
 * INRIA 2005 
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <windows.h>
#include <winuser.h>

#include "../version.h"

#ifdef WITH_TK
#include "tcl.h"
#include "tk.h"
#endif

#include "wcommon.h"
#include "FilesAssociations.h"
#include "GetOS.h"


#define LCCEXE		"\\lcc\\bin\\lcc.exe" 
#define LCCBIN		"\\lcc\\bin" 
#define LCCINCLUDE	"\\lcc\\include" 
#define LCCLIB		"\\lcc\\lib" 

#ifndef MAXSTR 
#define MAXSTR 256
#endif 

extern void SciEnv(void);
extern int GetScilabDirectory(char *SciPathName,BOOL UnixStyle);
extern void set_sci_env(char *DefaultSCIPATH) ; 
extern BOOL Set_SCI_PATH(char *DefaultPath);
extern BOOL Set_HOME_PATH(char *DefaultPath);
extern BOOL Set_TCL_LIBRARY_PATH(char *DefaultPath);
extern BOOL Set_TK_LIBRARY_PATH(char *DefaultPath);
extern BOOL Set_LCC_PATH(char *DefaultPath);
extern BOOL Set_SOME_ENVIRONMENTS_VARIABLES_FOR_SCILAB(void);
extern BOOL ConvertPathWindowsToUnixFormat(const char *pathwindows,char *pathunix);
extern BOOL ConvertPathUnixToWindowsFormat(const char *pathunix,char *pathwindows);

#endif /* __SCIENV_H__ */
