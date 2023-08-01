/*
 * Francois VOGEL 
 */

#include "TCL_Global.h"
#include "TclGetErrorLine.h"

int TclGetErrorLine(Tcl_Interp *interp)
{
#if (TCL_MAJOR_VERSION >= 8) && (TCL_MINOR_VERSION >= 6)
  return Tcl_GetErrorLine(interp);
#else
  return interp->errorLine;
#endif
}



