/**/
/* INRIA 2005 */
/* Allan CORNET */
/**/
#include "intwinqueryreg.h"
/**/
extern int InterfaceWindowsQueryRegistry (char *fname);
/**/
int C2F(intwinqueryreg) (char *fname)
{
#ifdef WIN32
  InterfaceWindowsQueryRegistry(fname);
#else
  Scierror(999,"Only for Windows\r\n");
  return 0;
#endif
  C2F(putlhsvar)();
  return 0;
}
/**/
