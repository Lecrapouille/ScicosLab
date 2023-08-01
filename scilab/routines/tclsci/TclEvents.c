/*
 * INRIA 2005 
 * Allan CORNET 
 */ 

#include "TclEvents.h"
extern int GetWITH_GUI(void);
 
void flushTKEvents(void)
{
  if( GetWITH_GUI() ) 
    {
      while (Tcl_DoOneEvent(TCL_ALL_EVENTS | TCL_DONT_WAIT)==1)
	{
	}
    }
}

int tcl_check_one_event(void) 
{
  int bRes=0;

  if( GetWITH_GUI() ) 
    {
      bRes=Tcl_DoOneEvent ( TCL_DONT_WAIT);
    }
  return bRes;
}

