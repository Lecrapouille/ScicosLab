/*
 * INRIA 2005 
 * Allan CORNET 
 */ 

#ifndef __TCLGLOBAL__
#define __TCLGLOBAL__


#ifdef WIN32
#include <windows.h>
#endif
#include <stdio.h>
#include <string.h>
#include "../machine.h"
#include "../stack-c.h"
#include "../version.h"

#include "tcl.h"
#include "tk.h"

#include "Errors.h"
#include "Warnings.h"
#include "Messages.h"

#ifdef WIN32
#include "../os_specific/win_mem_alloc.h" /* MALLOC */
#else
#include "../os_specific/sci_mem_alloc.h" /* MALLOC */
#endif

#ifndef NULL
#define NULL 0
#endif
#ifndef TRUE 
#define TRUE  1
#endif 
#ifndef FALSE
#define FALSE 0
#endif

extern Tcl_Interp *TCLinterp;
extern Tk_Window TKmainWindow;
extern int TK_Started;
extern int XTKsocket;
extern int IsAScalar(int RhsNumber); 

extern void nocase (char *s);
extern char *Matrix2String(int RhsMatrix);
extern double *String2Matrix(char *StringIn,int *nbelemOut);
extern int MustReturnAMatrix(char *FieldPropertie);
extern int MustReturnAString(char *FieldPropertie);
extern int ValueMustBeAMatrix(char *FieldPropertie);
extern int ValueMustBeAString(char *FieldPropertie);
extern int CheckPropertyField(char *FieldPropertie);
extern char *UTF8toANSI(Tcl_Interp *TCLinterp,char *StringUTF8);

#endif /* __TCLGLOBAL__ */

