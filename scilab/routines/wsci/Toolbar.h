/* INRIA 2005 */
/* Allan CORNET */

#ifndef __TOOLBARWIN__
#define __TOOLBARWIN__

#include <windows.h>
#include "../machine.h"
#include "../stack-c.h"
#include "../version.h"
#include "wgnuplib.h"
#include "resource.h"
#include "../graphics/scigraphic.h"
#include "../graphics/Graphics.h"

#include "wgraph.h"
#include "Messages.h"
#include "Warnings.h"
#include "Errors.h"

#ifndef NULL
#define NULL 0
#endif

#define TRUE  1
#define FALSE 0

extern void SetDefaultShowToolBar(BOOL valShowToolBar);
extern void HideGraphToolBar(struct BCG * ScilabGC);
extern void ShowGraphToolBar(struct BCG * ScilabGC);
extern void CreateGraphToolBar(struct BCG * ScilabGC) ;
extern void RefreshGraphToolBar(struct BCG * ScilabGC) ;
extern void ModifyEntityPickerToolbar(struct BCG * ScilabGC,BOOL Pressed);
extern void ToolBarOnOff(LPTW lptw);
extern void CreateMyTooltip (HWND hwnd,char ToolTipString[30]);
extern int HideToolBarWin32(int WinNum);
extern int GetStateToolBarWin32(int WinNum);
extern int ToolBarWin32(int WinNum,char *onoff);
extern void EnableToolBar(LPTW lptw);
extern void DisableToolBar(LPTW lptw);

#endif /* __TOOLBARWIN__ */


