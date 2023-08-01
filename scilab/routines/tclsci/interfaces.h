#ifndef  SCI_TCL_INTERFACES_H 
#define  SCI_TCL_INTERFACES_H 

/*
 * INRIA 2005 
 * Allan CORNET 
 */ 

#include "TCL_Global.h"

extern int C2F(intClose) (char *fname,unsigned long fname_len);
extern int C2F(intFindObj) (char *fname,unsigned long fname_len);
extern int C2F(intOpenTk) (char *fname,unsigned long fname_len);
extern int C2F(intTclCreateSlave) (char *fname,unsigned long fname_len);
extern int C2F(intTclDeleteInterp) (char *fname,unsigned long fname_len);
extern int C2F(intTclDoOneEvent) (char *fname,unsigned long fname_len);
extern int C2F(intTclEvalFile) (char *fname,unsigned long fname_len);
extern int C2F(intTclEvalStr) (char *fname,unsigned long fname_len);
extern int C2F(intTclExistInterp) (char *fname,unsigned long fname_len);
extern int C2F(intTclExistVar) (char *fname,unsigned long fname_len);
extern int C2F(intTclGcf) (char *fname,unsigned long fname_len);
extern int C2F(intTclGet) (char *fname,unsigned long fname_len);
extern int C2F(intTclGetVar) (char *fname,unsigned long fname_len);
extern int C2F(intTclGetVersion) (char *fname,unsigned long fname_len);
extern int C2F(intTclScf) (char *fname,unsigned long fname_len);
extern int C2F(intTclSet) (char *fname,unsigned long fname_len);
extern int C2F(intTclSetVar) (char *fname,unsigned long fname_len);
extern int C2F(intTclUnsetVar) (char *fname,unsigned long fname_len);
extern int C2F(intTclUpVar) (char *fname,unsigned long fname_len);

#endif



