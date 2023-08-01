/*
 * Originally written by Bertrand Guiheneuf INRIA 1997
 */

#include "InitTclTk.h"
#include "TclEvents.h"
#ifndef WIN32
#include <dirent.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xutil.h>
#include <X11/cursorfont.h>
#include <ctype.h>
#endif

extern int TCL_EvalScilabCmd(ClientData clientData,Tcl_Interp * theinterp,int objc,CONST char ** argv);
extern Tcl_Obj * TclGetLibraryPath(void);
extern void sci_tk_activate(void);
extern int GetWITH_GUI(void);

#ifndef WIN32
#if defined(WITH_GTK) /*Gtk case*/

/*
 * Addint a tcl event source to enable propagation of gtk events 
 * during a tcl event loop.
 */

#include <gtk/gtk.h>
static int sci_event_source_tkhandler(Tcl_Event *evPtr, int flags)
{
  if (!(flags & TCL_WINDOW_EVENTS)) return 0;
  while (gtk_events_pending()) {
    gtk_main_iteration();
  }
  return 1;
}
static void sci_event_source_tkhandler_setup(ClientData clientData, int flags) 
{
  int BlockTime=20000;
  Tcl_Time block_time = {0, 0};
  if (!(flags & TCL_WINDOW_EVENTS)) return;
  if (!gtk_events_pending()) {
    block_time.usec = BlockTime;
  }
  Tcl_SetMaxBlockTime(&block_time);
  return;
}
static void sci_event_source_tkhandler_check(ClientData clientData, int flags)
{
  if (!(flags & TCL_WINDOW_EVENTS)) return;
  if (gtk_events_pending()) {
    Tcl_Event *event = (Tcl_Event *)ckalloc(sizeof(Tcl_Event));
    event->proc =  sci_event_source_tkhandler;
    Tcl_QueueEvent(event, TCL_QUEUE_TAIL);
  }
  return;
}
#else /*X case*/

/*
 * Addint a tcl event source to enable propagation of X11 events 
 * during a tcl event loop.
 */

#include "../xsci/x_ptyxP.h"
#include "../xsci/x_data.h"
extern void x_events(void);
extern XtermWidget term;
extern int C2F(xscion)(int *i);
extern int BasicScilab;
extern Display *the_dpy;

static int sci_event_source_tkhandler(Tcl_Event *evPtr, int flags)
{
  int INXscilab;
  C2F(xscion)(&INXscilab);
  if (!(flags & TCL_WINDOW_EVENTS)) return 0;
  if (INXscilab==1) {
    x_events();
  }
  else {
    XEvent event;
    if (BasicScilab) return 0;
    if (the_dpy == (Display *) NULL) return 0;
    if (!XPending (the_dpy)) return 0;
    do {
      XNextEvent (the_dpy, &event);
      XtDispatchEvent(&event);
    } while (QLength(the_dpy) > 0);
  }
  return 1;
}
static void sci_event_source_tkhandler_setup(ClientData clientData, int flags)
{
  int INXscilab;
  register TScreen *screen = &term->screen;
  int BlockTime=20000;
  Tcl_Time block_time = {0, 0};
  if (!(flags & TCL_WINDOW_EVENTS)) return;
  C2F(xscion)(&INXscilab);
  if (INXscilab==1) {
    if (!XPending(screen->display)) {
      block_time.usec = BlockTime;
    }
    Tcl_SetMaxBlockTime(&block_time);
  }
  else {
    if (BasicScilab) return;
    if (the_dpy == (Display *) NULL) return;
    if (!XPending (the_dpy)) {
      block_time.usec = BlockTime;
    }
    Tcl_SetMaxBlockTime(&block_time);
  }
  return;
}
static void sci_event_source_tkhandler_check(ClientData clientData, int flags) 
{
  int INXscilab;
  register TScreen *screen = &term->screen;
  if (!(flags & TCL_WINDOW_EVENTS)) return;
  C2F(xscion)(&INXscilab);
  if (INXscilab==1) {
    if (XPending(screen->display)) {
      Tcl_Event *event = (Tcl_Event *)ckalloc(sizeof(Tcl_Event));
      event->proc =  sci_event_source_tkhandler;
      Tcl_QueueEvent(event, TCL_QUEUE_TAIL);
    }
  }
  else {
    if (BasicScilab) return;
    if (the_dpy == (Display *) NULL) return;
    if (XPending (the_dpy)) {
      Tcl_Event *event = (Tcl_Event *)ckalloc(sizeof(Tcl_Event));
      event->proc =  sci_event_source_tkhandler;
      Tcl_QueueEvent(event, TCL_QUEUE_TAIL);
    }
  }
  return;
}

#endif /*defined(WITH_GTK)*/
#endif /*ifndef WIN32*/

int TK_Started=0;
#ifndef WIN32
int XTKsocket=0;
#endif
char *GetSciPath(void);
#if defined(__CYGWIN32__) 
static char *GetSciPathCyg(void);
#endif

static int first =0;
static int OpenTCLsci(void);


void initTCLTK(void)
{
  if ( GetWITH_GUI() )
    {
      if ( OpenTCLsci()==0 )
	{
	  TK_Started=1;
	}
      else
	{
	  TK_Started=0;
	}
    }
  else
    {
      TK_Started=0;
    }
}


/* Checks if tcl/tk has already been initialised and if not 
 * initialise it. It must find the tcl script 
 */

static int OpenTCLsci(void)
{
  char *SciPath=NULL;
  char TkScriptpath[2048];
  char MyCommand[2048];

#ifndef WIN32
  DIR *tmpdir=NULL;
  Display *XTKdisplay;
#endif

  FILE *tmpfile=NULL;

#ifdef TCL_MAJOR_VERSION
#ifdef TCL_MINOR_VERSION
#if TCL_MAJOR_VERSION >= 8
#if TCL_MINOR_VERSION > 0
  Tcl_FindExecutable(" ");
#endif
#endif
#endif
#endif
  SciPath=GetSciPath();

  /* test SCI validity */
  if (SciPath==NULL)
    {
      sciprint(TCL_WARNING1);
      return(1);
    }

#ifdef DEBUG_INIT_TCL
  sciprint("Warn: Test the OpenTCL\r\n");
  sciprint("Warn: Here is the scipath %s\r\n",SciPath);
#endif

#ifdef WIN32
  strcpy(TkScriptpath, SciPath);
  strcat(TkScriptpath, "/tcl/TK_Scilab.tcl");

  tmpfile = fopen(TkScriptpath,"r");
  if (tmpfile==NULL)
    {
      sciprint(TCL_WARNING2);
      return(1);
    }
  else
    {
#ifdef DEBUG_INIT_TCL
      sciprint("Warn: Tkscript %s opened with success\r\n",TkScriptpath);
#endif
      fclose(tmpfile);
    }
#else
  tmpdir=opendir(SciPath);
  if (tmpdir==NULL)
    {
      sciprint(TCL_WARNING1);
      return(1);
    }
  else
    {
      closedir(tmpdir);
    }
  strcpy(TkScriptpath,SciPath);
  strcat(TkScriptpath, "/tcl/TK_Scilab.tcl");
  tmpfile = fopen(TkScriptpath,"r");
  if (tmpfile==NULL)
    {
      sciprint(TCL_WARNING2);
      return(1);
    }
  else fclose(tmpfile);
#endif /* WIN32 */

#if defined(__CYGWIN32__)
  /* we must pass X: pathnames to tcl */
  if ( SciPath ) FREE(SciPath);
  SciPath=GetSciPathCyg();
  strcpy(TkScriptpath,SciPath);
  strcat(TkScriptpath, "/tcl/TK_Scilab.tcl");
#endif

  if (TCLinterp == NULL)
    {
#ifdef DEBUG_INIT_TCL
      Tcl_Obj *pathPtr;
      sciprint("Warn: TCLinterp is NULL \r\n");
#endif

      TCLinterp = Tcl_CreateInterp();
      if ( TCLinterp == NULL )
	{
	  Scierror(999,TCL_ERROR1);
	  return (1);
	}
#ifdef DEBUG_INIT_TCL
      sciprint("Warn: TCLinterp is Not NULL \r\n");
#endif 

#ifdef DEBUG_INIT_TCL
      pathPtr = TclGetLibraryPath();

      if (pathPtr != NULL)
	{
	  int i, objc;
	  Tcl_Obj **objv;

	  objc = 0;
	  Tcl_ListObjGetElements(NULL, pathPtr, &objc, &objv);
	  sciprint("Warn: LibraryPath contains %d values \r\n",objc);
	  for (i = 0; i < objc; i++) 
	    {
	      int length;
	      char *string;
	      string = Tcl_GetStringFromObj(objv[i], &length);
	      sciprint("Warn: LibraryPath %d = %s\r\n",i,string);
	    }
	}
#endif 

      if ( Tcl_Init(TCLinterp) == TCL_ERROR)
	{
#ifdef DEBUG_INIT_TCL
	  sciprint("Warn: Tcl_Init failed \r\n");
#endif 
	  Scierror(999,TCL_ERROR2);
	  return (1);
	}

      if ( Tk_Init(TCLinterp) == TCL_ERROR)
	{
#ifdef DEBUG_INIT_TCL
	  sciprint("Warn: Tk_Init failed \r\n");
#endif
	  Scierror(999,TCL_ERROR3);
	  return (1);
	}

      sprintf(MyCommand, "set SciPath \"%s\";",SciPath);

      if ( Tcl_Eval(TCLinterp,MyCommand) == TCL_ERROR  )
	{
#ifdef DEBUG_INIT_TCL
	  sciprint("Warn: set SciPath failed \r\n");
#endif
	  Scierror(999,TCL_ERROR4,Tcl_GetStringResult(TCLinterp));
	  return (1);
	}

      Tcl_CreateCommand(TCLinterp,"ScilabEval",TCL_EvalScilabCmd,(ClientData)1,NULL);

#ifndef WIN32
      Tcl_CreateEventSource(sci_event_source_tkhandler_setup,
			    sci_event_source_tkhandler_check, NULL);
#endif
    }

  if (TKmainWindow == NULL)
    {
      TKmainWindow = Tk_MainWindow(TCLinterp);
#ifndef WIN32
      XTKdisplay=Tk_Display(TKmainWindow);
      XTKsocket = ConnectionNumber(XTKdisplay);
#endif

      Tk_GeometryRequest(TKmainWindow,2,2);

      if ( Tcl_EvalFile(TCLinterp,TkScriptpath) == TCL_ERROR  )
	{
	  Scierror(999,TCL_ERROR4,Tcl_GetStringResult(TCLinterp));
	  return (1);
	}
      flushTKEvents();

    }
#ifdef DEBUG_INIT_TCL
  sciprint("Warn: Tcl_Init is OK \r\n");
#endif

  if (SciPath) {FREE(SciPath);SciPath=NULL;}
  return(0);

}


int CloseTCLsci(void)
{
  int bOK=0;
  if ( GetWITH_GUI() && TK_Started)
    {
      Tcl_DeleteInterp(TCLinterp);
      TCLinterp=NULL;
      TKmainWindow=NULL;
      bOK=1;
      TK_Started=0;
      first=0;
    }
  return bOK;
}

/* force SciPath to Unix format for compatibility (Windows) 
 */

char *GetSciPath(void)
{
  char *PathUnix=NULL;
  char *SciPathTmp=NULL;
  int i=0;

  SciPathTmp=getenv("SCI");

  if (SciPathTmp)
    {
      PathUnix=(char*)MALLOC( ((int)strlen(SciPathTmp)+1)*sizeof(char) );

      strcpy(PathUnix,SciPathTmp);
      for (i=0;i<(int)strlen(PathUnix);i++)
	{
	  if (PathUnix[i]=='\\') PathUnix[i]='/';
	}
    }

  return PathUnix;
}


#if defined(__CYGWIN32__)
/* from cygwin /cygdrive/f/ to f:
 * PathUnix must be a valid pathname returned by GetSciPath
 */

static char *GetSciPathCyg(void)
{
  const char *cygwin = "/cygdrive/";
  char *PathUnix=NULL;
  char *SciPathTmp=NULL;
  int i=0;

  SciPathTmp=getenv("SCI");

  if (SciPathTmp)
    {
      PathUnix=(char*)MALLOC( ((int)strlen(SciPathTmp)+1)*sizeof(char) );

      strcpy(PathUnix,SciPathTmp);
      for (i=0;i<(int)strlen(PathUnix);i++)
	{
	  if (PathUnix[i]=='\\') PathUnix[i]='/';
	}
    }
  if (strncmp(PathUnix,cygwin,strlen(cygwin))==0)
    {
      strcpy(PathUnix,SciPathTmp +strlen(cygwin)-1);
      *PathUnix = *(PathUnix+1);
      *(PathUnix+1)= ':';
    }
  return PathUnix;
}
#endif


int ReInitTCL(void)
{
  if (TK_Started != 1 )
    {
      if ( first == 0)
	{
	  sci_tk_activate();
	  first++;
	  if ( TK_Started != 1 )
	    {
	      initTCLTK();
	      /* Derniere chance ;) d'initialisation */
	      if ( TK_Started != 1 )
		{
		  Scierror(999,TCL_ERROR20);
		  return 0;
		}
	    }
	}
    }
  return 0;
}

