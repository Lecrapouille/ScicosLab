#ifndef __TCLGETERRORLINE__
#define __TCLGETERRORLINE__

/*
 * Francois VOGEL 2009-
 */

#include "TCL_Global.h"

/**
 * TclGetErrorLine:
 *
 * Wrapper around interp->errorLine - See Tcl TIP #336 and Scilab bug 3877
 * @param[in] interp: pointer on a Tcl interpreter
 * @return int containing the line number where the error occurred
 */

extern int TclGetErrorLine(Tcl_Interp *interp);

#endif /* __TCLGETERRORLINE__ */
 
