/*
 * INRIA 2005 
 * Allan CORNET 
 */

#include "inttclsci.h"

#if WIN32
#include <windows.h>
#include "../os_specific/win_mem_alloc.h"
#endif
#include "../os_specific/addinter.h"

extern int GetWITH_GUI(void);
extern int TK_Started;
extern void initTCLTK(void);
extern int ReInitTCL(void);




static TCLSCITable Tab[]=
  {
    {C2F(intTclDoOneEvent),"TCL_DoOneEvent"},
    {C2F(intTclEvalFile),"TCL_EvalFile"},
    {C2F(intTclEvalStr),"TCL_EvalStr"},
    {C2F(intTclGetVar),"TCL_GetVar"},
    {C2F(intTclSetVar),"TCL_SetVar"},
    {C2F(intOpenTk),"opentk"},
    {C2F(intClose),"close"},
    {C2F(intFindObj),"findobj"},
    {C2F(intTclSet),"%s_set"},
    {C2F(intTclGet),"%s_get"},
    {C2F(intTclGcf),"TCL_gcf"},
    {C2F(intTclScf),"TCL_scf"},
    {C2F(intTclGetVersion),"TCL_GetVersion"},
    {C2F(intTclUnsetVar),"TCL_UnsetVar"},
    {C2F(intTclExistVar),"TCL_ExistVar"},
    {C2F(intTclUpVar),"TCL_UpVar"},
    {C2F(intTclDeleteInterp),"TCL_DeleteInterp"},
    {C2F(intTclCreateSlave),"TCL_CreateSlave"},
    {C2F(intTclExistInterp),"TCL_ExistInterp"}
  };

int C2F(inttclsci)()
{ 
  if ( GetWITH_GUI() )
    { 
      ReInitTCL();  
      CALL_INTERF();
    }
  else
    {
      Scierror(999,"Tcl/TK interface disabled in -nogui mode.\r\n");
      return 0;
    }
  return 0;
}

