/*-----------------------------------------------------------------------------------*/
/* INRIA 2005 */
/* Allan CORNET */
/*-----------------------------------------------------------------------------------*/
#ifndef __WNDPARENTGRAPHPROC__
#define __WNDPARENTGRAPHPROC__
/*-----------------------------------------------------------------------------------*/
#include <windows.h>
#include <windowsx.h>
#include "wgnuplib.h"
#include "resource.h"
#include "Messages.h"
#include "Warnings.h"
#include "Errors.h"
#include "../version.h"
#include "../os_specific/win_mem_alloc.h"
#include "wresource.h"
#include "../graphics/bcg.h"
/*-----------------------------------------------------------------------------------*/
EXPORT LRESULT CALLBACK WndParentGraphProc (HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);
/*-----------------------------------------------------------------------------------*/
#ifdef WITH_TK
#include "tcl.h"
extern void flushTKEvents ();
extern int TK_Started;
#endif
#endif /* __WNDPARENTGRAPHPROC__ */
