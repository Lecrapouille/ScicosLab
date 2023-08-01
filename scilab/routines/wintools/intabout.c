/**/
/* INRIA 2005 */
/* Allan CORNET */
/**/
#include "intabout.h"
#if defined (linux)
#include <string.h>
#endif

/**/
#ifdef WIN32
extern void Callback_ABOUT(void);
#endif
/**/
int C2F(intabout) (char *fname)
{
  Rhs=Max(Rhs,0);
  CheckRhs(0,0) ;
  CheckLhs(0,1) ;

#if WIN32
  Callback_ABOUT();
#else
  /* A voir sous Unix */
#endif

  LhsVar(1) = 0;
  C2F(putlhsvar)();	
	
  return 0;
}
/**/
