/* EXPAT_SCI header
 *
 * A.Layec - METALAU, INRIA
 *
 */

#ifndef EXPAT_SCI
#define EXPAT_SCI

#include <string.h>
#include <stdio.h>
#include <expat.h>

#include "../stack-c.h"
#include "../mex.h"

#ifdef WIN32
#include "../os_specific/win_mem_alloc.h" /* MALLOC */
#else
#include "../os_specific/sci_mem_alloc.h" /* MALLOC */
#endif

#ifndef NULL
  #define NULL 0
#endif

#define idstk(x,y) (C2F(vstk).idstk+(x-1)+(y-1)*nsiz)

/************************************
 * External and specific declaration
 ************************************/

extern int C2F(cvstr)  __PARAMS((integer *,integer *,char *,
                                 integer *,unsigned long int));

extern int C2F(cvnamel)(int *id,char *str,
                        int *jobptr,int *str_len);

/*****************************/
typedef struct XML_Parser_st
{
  XML_Parser *p;
  char **DataName;

  char **ElmStartHndl;
  char **ElmEndHndl;
  char **CharDataHndl;

  int nb_CParser;
  int nb_RParser;
  int *Conv2Latin;
  int *CheckParser;
} XML_Parser_struct;

int C2F(copyvarfromname)(integer *lw,char *varname);

#define CopyVarFromName(n,ct) \
     if(! C2F(copyvarfromname)((c_local=n,&c_local),ct))\
     {return 0;}

int GetSciDataLstkPtr(char *DataName);
int GetSciFuncFromName(char *FuncName, int *mlhs, int *mrhs);
int GetIndPtrStruct(XML_Parser ptr_parser);
int FreeParserPtr(XML_Parser ptr_parser);
int AllowParse(int *i);
int conv2latin(char **str_in, char **str_out);
int start_elm_hndl(void *data,const char *el,const char **attr);
int end_elm_hndl(void *data,const char *el);
int char_hndl(void *data,const char *txt,int txtlen);

#endif /* EXPAT_SCI  */
