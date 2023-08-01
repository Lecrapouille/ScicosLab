/*
 * INRIA 2005 
 * Allan CORNET 
 */

#include "interfaces.h" 

/**
 * C2F:
 * @intOpenTk: 
 * 
 * 
 * 
 * Returns: 
 **/

int C2F(intOpenTk) (char *fname, unsigned long fname_len)
{
  Tcl_Interp *TCLinterpLocal=NULL;

  CheckRhs(0,0);
  CheckLhs(1,1);
  
  TCLinterpLocal = Tcl_CreateInterp();
  Tcl_Init(TCLinterpLocal);
  Tk_Init(TCLinterpLocal);
  TKmainWindow = Tk_MainWindow(TCLinterpLocal);
  Tk_GeometryRequest(TKmainWindow,200,200);
  Tk_SetWindowBackground(TKmainWindow, WhitePixelOfScreen(Tk_Screen(TKmainWindow)));

  LhsVar(1) = 0;
  C2F(putlhsvar)();	
	
  return 0;
}

