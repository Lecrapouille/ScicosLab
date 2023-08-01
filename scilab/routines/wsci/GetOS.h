/* Allan CORNET */
/* INRIA 2005 */
#ifndef __GETOSWIN_H__
#define __GETOSWIN_H__
#include <windows.h>
/*-----------------------------------------------------------------------------------*/
#define OS_ERROR		                -1
#define OS_WIN32_WINDOWS_NT_3_51	       	0
#define OS_WIN32_WINDOWS_NT_4_0		       	1
#define OS_WIN32_WINDOWS_95		      	2
#define OS_WIN32_WINDOWS_98			3
#define OS_WIN32_WINDOWS_Me			4
#define OS_WIN32_WINDOWS_2000			5
#define OS_WIN32_WINDOWS_XP		       	6
#define OS_WIN32_WINDOWS_XP_64		        7
#define OS_WIN32_WINDOWS_SERVER_2003		8
#define OS_WIN32_WINDOWS_SERVER_2003_R2		9
#define OS_WIN32_WINDOWS_SERVER_2003_64		10
#define OS_WIN32_WINDOWS_VISTA			11
#define OS_WIN32_WINDOWS_VISTA_64		12
#define OS_WIN32_WINDOWS_SERVER_2008		13
#define OS_WIN32_WINDOWS_SERVER_2008_64		14
#define OS_WIN32_WINDOWS_SEVEN			15
#define OS_WIN32_WINDOWS_SEVEN_64	      	16
#define OS_WIN32_WINDOWS_SEVEN_SERVER		17
#define OS_WIN32_WINDOWS_SEVEN_SERVER_64	18
/*-----------------------------------------------------------------------------------*/
int GetOSVersion(void);
int SciWinGetPlatformId ();
/*-----------------------------------------------------------------------------------*/
#endif /* __GETOSWIN_H__ */

