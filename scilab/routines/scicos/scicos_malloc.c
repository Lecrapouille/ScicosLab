#if WIN32
  #include "../os_specific/win_mem_alloc.h"   /* malloc */
#else
  #include "../os_specific/sci_mem_alloc.h"  /* malloc */
#endif

#include "scicos_block.h"

void * scicos_malloc(size_t size)
{
  if (size==0) return NULL;
  return MALLOC(size);
}

