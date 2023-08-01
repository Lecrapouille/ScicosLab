/*-----------------------------------------------------------------------------------
 * Allan CORNET INRIA 2005 
 *-----------------------------------------------------------------------------------*/

#ifndef __FILESASSOCIATIONBOX__
#define __FILESASSOCIATIONBOX__

#include <windows.h>
#include <windowsx.h>
#include <shlwapi.h>
#include "wgnuplib.h"
#include "resource.h"
#include "../os_specific/win_mem_alloc.h"
#include "../version.h"

#if !defined(__MINGW32__)
#pragma comment(lib, "shlwapi.lib")
#endif

EXPORT void WINAPI FilesAssociationBox (HWND hwnd);

#endif /* __FILESASSOCIATIONBOX__ */



