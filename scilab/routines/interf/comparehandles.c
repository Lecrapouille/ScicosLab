#include "../stack-c.h"
/* used to test if two graphic handles are equal or not */
int C2F(comparehandles)(long long *h1,long long *h2) 
{
  if (*h1 != *h2) return 0;
  return 1;
}

