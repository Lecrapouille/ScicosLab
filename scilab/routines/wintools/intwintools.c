#include "intwintools.h"
/**/
/* INRIA 2005 */
/* Allan CORNET */
/**/
#if WIN32
#include <windows.h>
#include "../os_specific/win_mem_alloc.h"
extern char *GetExceptionString(DWORD ExceptionCode);
#endif

#if defined (linux)
#include <string.h>
#endif
#include "../os_specific/addinter.h"

/**/
extern int C2F(intwinopen) (char *fname,unsigned long l);
extern int C2F(intwinqueryreg) (char *fname,unsigned long l);
extern int C2F(intgetlongpathname) (char *fname,unsigned long l);
extern int C2F(intgetshortpathname) (char *fname,unsigned long l);
extern int C2F(intddeopen) (char *fname,unsigned long l);
extern int C2F(intddeclose) (char *fname,unsigned long l);
extern int C2F(intddeexec) (char *fname,unsigned long l);
extern int C2F(intddepoke) (char *fname,unsigned long l);
extern int C2F(intddereq) (char *fname,unsigned long l);
extern int C2F(intddeisopen) (char *fname,unsigned long l);
extern int C2F(intclipboard) (char *fname,unsigned long l);
extern int C2F(inthidetoolbar) (char *fname,unsigned long l);
extern int C2F(inttoolbar) (char *fname,unsigned long l);
extern int C2F(intsetlanguagemenu) (char *fname,unsigned long l);
extern int C2F(intconsoledos) (char *fname,unsigned long l);
extern int C2F(intabout) (char *fname,unsigned long l);
extern int C2F(intmcisendstring) (char *fname,unsigned long l);
extern int C2F(intoemtochar) (char *fname,unsigned long l);
extern int C2F(intchartooem) (char *fname,unsigned long l);
extern int C2F(intprintsetupbox) (char *fname,unsigned long l);
extern int C2F(inttoprint) (char *fname,unsigned long l);
extern int C2F(intsettextcolor) (char *fname,unsigned long l);
extern int C2F(intsettextbackgroundcolor) (char *fname,unsigned long l);
extern int C2F(intfilesassociationbox) (char *fname,unsigned long l);
/**/
static WintoolsTable Tab[]=
  {
    {C2F(intwinopen),"winopen"},
    {C2F(intwinqueryreg),"winqueryreg"},
    {C2F(intgetlongpathname),"getlongpathname"},
    {C2F(intgetshortpathname),"getshortpathname"},
    {C2F(intddeopen),"ddeopen"},
    {C2F(intddeclose),"ddeclose"},
    {C2F(intddeexec),"ddeexec"},
    {C2F(intddepoke),"ddepoke"},
    {C2F(intddereq),"ddereq"},
    {C2F(intddeisopen),"ddeisopen"},
    {C2F(intclipboard),"ClipBoard"},
    {C2F(inthidetoolbar),"hidetoolbar"},
    {C2F(inttoolbar),"toolbar"},
    {C2F(intsetlanguagemenu),"setlanguagemenu"},
    {C2F(intconsoledos),"console"},
    {C2F(intabout),"about"},
    {C2F(intmcisendstring),"mcisendstring"},
    {C2F(intoemtochar),"oemtochar"},
    {C2F(intchartooem),"chartooem"},
    {C2F(intprintsetupbox),"printsetupbox"},
    {C2F(inttoprint),"toprint"},
    {C2F(intsettextcolor),"settextcolor"},
    {C2F(intsettextbackgroundcolor),"settextbackgroundcolor"},
    {C2F(intfilesassociationbox),"filesassociationbox"}
  };

/**/
int C2F(intwintools)()
{  
  CALL_INTERF();
  return 0;
}
/**/
