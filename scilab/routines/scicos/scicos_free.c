#if WIN32
  #include "../os_specific/win_mem_alloc.h"   /* malloc */
#else
  #include "../os_specific/sci_mem_alloc.h"  /* malloc */
#endif

#include "scicos_block.h"

#define SCICOS_FREE(x) if (x  != NULL) FREE((char *) x);

void scicos_free(void *p)
{
  SCICOS_FREE(p);
}
