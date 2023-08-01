/**/
/* INRIA 2005 */
/* Allan CORNET */
/**/
#include "intdde.h"
/**/
#ifdef WIN32
extern int InterfaceWindowsDDEopen (char *fname);
extern int InterfaceWindowsDDEclose (char *fname);
extern int InterfaceWindowsDDEexec (char *fname);
extern int InterfaceWindowsDDEpoke (char *fname);
extern int InterfaceWindowsDDEreq (char *fname);
extern int InterfaceWindowsDDEIsOpen (char *fname);
#endif
/**/
int C2F(intddeopen) (char *fname)
{
#ifdef WIN32
  InterfaceWindowsDDEopen(fname);
#else
  Scierror(999,"Only for Windows\r\n");
  return 0;
#endif
  C2F(putlhsvar)();
  return 0;
}
/**/
int C2F(intddeclose) (char *fname)
{
#ifdef WIN32
  InterfaceWindowsDDEclose(fname);
#else
  Scierror(999,"Only for Windows\r\n");
  return 0;
#endif
  C2F(putlhsvar)();
  return 0;
}
/**/
int C2F(intddeexec) (char *fname)
{
#ifdef WIN32
  InterfaceWindowsDDEexec(fname);
#else
  Scierror(999,"Only for Windows\r\n");
  return 0;
#endif
  C2F(putlhsvar)();
  return 0;
}
/**/
int C2F(intddepoke) (char *fname)
{
#ifdef WIN32
  InterfaceWindowsDDEpoke(fname);
#else
  Scierror(999,"Only for Windows\r\n");
  return 0;
#endif
  C2F(putlhsvar)();
  return 0;
}
/**/
int C2F(intddereq) (char *fname)
{
#ifdef WIN32
  InterfaceWindowsDDEreq(fname);
#else
  Scierror(999,"Only for Windows\r\n");
  return 0;
#endif
  C2F(putlhsvar)();
  return 0;
}
/**/
int C2F(intddeisopen) (char *fname)
{
#ifdef WIN32
  InterfaceWindowsDDEIsOpen(fname);
#else
  Scierror(999,"Only for Windows\r\n");
  return 0;
#endif
  C2F(putlhsvar)();
  return 0;
}
/**/
