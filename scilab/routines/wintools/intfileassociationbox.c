/**/
/* INRIA 2005 */
/* Allan CORNET */
/**/
#include "intfileassociationbox.h"
#if defined (linux)
#include <string.h>
#endif

/**/
extern void Callback_FILESASSOCIATIONBOX(void);
/**/
int C2F(intfilesassociationbox) (char *fname,unsigned long l)
{
  Rhs=Max(Rhs,0);
  CheckRhs(0,0) ;
  CheckLhs(0,1) ;

#if WIN32
  Callback_FILESASSOCIATIONBOX();
#endif
  LhsVar(1)=0;
  C2F(putlhsvar)();
  return 0;
}
/**/
