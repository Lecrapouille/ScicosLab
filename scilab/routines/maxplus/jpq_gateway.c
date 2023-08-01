#include "mex.h" 
 
extern Gatefunc iFordBellman;
 
static GenericTable Tab[]={
{(Myinterfun)sci_gateway, iFordBellman,"error msg"},
	 };
 
int C2F(jpq_gateway)()
{  Rhs = Max(0, Rhs);
(*(Tab[Fin-1].f))(Tab[Fin-1].name,Tab[Fin-1].F);
  return 0;
}
 
