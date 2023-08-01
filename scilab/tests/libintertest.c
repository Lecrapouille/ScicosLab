#include <mex.h> 

extern Gatefunc intfun1;
static GenericTable Tab[]={
  {(Myinterfun)sci_gateway,intfun1,"scifun1"},
};
 
int C2F(libintertest)()
{
  Rhs = Max(0, Rhs);
  (*(Tab[Fin-1].f))(Tab[Fin-1].name,Tab[Fin-1].F);
  return 0;
}
