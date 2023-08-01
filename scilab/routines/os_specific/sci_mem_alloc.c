#include "../config.h"
#include "sci_mem_alloc.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* Allan CORNET */
/* INRIA 2005 */

#ifndef NULL
#define NULL 0
#endif

/*-----------------------------------------------------------------------------------*/
void * MyReAlloc(void * lpAddress,int dwSize,char *fichier,int ligne)
{
  void * NewPointer=NULL;
 
  NewPointer = realloc(lpAddress,dwSize);
  
  if(NewPointer == NULL)
    {
	#ifndef NDEBUG
      printf("REALLOC returns NULL Error File %s Line %d \n",fichier,ligne);
      fflush(NULL);
	#endif
    }
  /*printf("MyRealloc %d %s %d\n",lpAddress,fichier,ligne);*/
  return NewPointer;
}
/*-----------------------------------------------------------------------------------*/
void * MyAlloc(unsigned int dwSize,char *fichier,int ligne)
{
  void * NewPointer=NULL;

  if (dwSize>0)
    {
      NewPointer = malloc(dwSize);
      
      if (NewPointer == NULL)
		{
		#ifndef NDEBUG
			printf("MALLOC returns NULL Error File %s Line %d \n",fichier,ligne);
			fflush(NULL);
		#endif
		}
    }
  else
    { 
		NewPointer = malloc(dwSize);
		#ifndef NDEBUG
			printf("MALLOC incorrect Size Error File %s Line %d \n",fichier,ligne);
			fflush(NULL);
		#endif
    }
  /*printf("MyAlloc %d %s %d\n",NewPointer,fichier,ligne);*/
  return NewPointer;
  
}

/*-----------------------------------------------------------------------------------*/
void * MyCalloc(unsigned int x, unsigned int y, char *fichier,int ligne)
{
  void * NewPointer=NULL;

  if ((x)*(y)>0)
    {
		NewPointer = calloc(x,y);
      
		if (NewPointer == NULL)
		{
		#ifndef NDEBUG
			printf("CALLOC returns NULL Error File %s Line %d \n",fichier,ligne);
			fflush(NULL);
		#endif
		}
    }
  else
    {
		NewPointer = calloc(x,y);
		#ifndef NDEBUG
			printf("CALLOC incorrect size Error File %s Line %d \n",fichier,ligne);
			fflush(NULL);
		#endif
    }
  /*printf("MyCalloc %d %s %d\n",NewPointer,fichier,ligne);*/
  return NewPointer;

}
/*-----------------------------------------------------------------------------------*/
void MyFree(void *x, char *fichier,int ligne)
{
	free((void*)x);
	/*printf("MyFree %d %s %d\n",x,fichier,ligne);*/
}
/*-----------------------------------------------------------------------------------*/

/* Special allocation case for the stack:
 * on 64 bits machines we use malloc_rep and free_rep
 * using function defined in os_specific/malloc.c
 */

#ifdef WITH_MALLOC_REP
extern void *malloc_rep(register size_t size);
extern void free_rep(void *f);
#define malloc malloc_rep
#define free free_rep
#endif

void * MyStackAlloc(unsigned int dwSize,char *fichier,int ligne)
{
  void * NewPointer=NULL;
  if (dwSize>0)
    {
      NewPointer = malloc(dwSize);
      if (NewPointer == NULL)
		{
#ifndef NDEBUG
		  printf("MALLOC returns NULL Error File %s Line %d \n",fichier,ligne);
		  fflush(NULL);
#endif
		}
    }
  else
    { 
	  NewPointer = malloc(dwSize);
#ifndef NDEBUG
	  printf("MALLOC incorrect Size Error File %s Line %d \n",fichier,ligne);
	  fflush(NULL);
#endif
    }
  return NewPointer;
}

void MyStackFree(void *x, char *fichier,int ligne)
{
  free(x);
}
