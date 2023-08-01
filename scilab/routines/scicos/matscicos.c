#include "matscicos.h"
#if WIN32
#include <windows.h>
#include "../os_specific/win_mem_alloc.h"
#endif
/* @lan, xx/xx/08
 * Copyright INRIA
 */
extern int intendscicosim _PARAMS((char *fname, unsigned long l));
extern int inttimescicos _PARAMS((char *fname,unsigned long l));
extern int intduplicate _PARAMS((char *fname,unsigned long l));
extern int intdiffobjs _PARAMS((char *fname,unsigned long l));
extern int intxproperty _PARAMS((char *fname,unsigned long l));
extern int intphasesim _PARAMS((char *fname,unsigned long l));
extern int intsetxproperty _PARAMS((char *fname,unsigned long l));
extern int intsetblockerror _PARAMS((char *fname,unsigned long l));
extern int intcoserror _PARAMS((char *fname,unsigned long l));
extern int inttree2 _PARAMS((char *fname,unsigned long l));
extern int inttree3 _PARAMS((char *fname,unsigned long l));
extern int inttree4 _PARAMS((char *fname,unsigned long l));
extern int intscicosimc _PARAMS((char *fname, unsigned long l));
extern int intgetscicosvarsc _PARAMS((char *fname, unsigned long l));
extern int intcurblkc _PARAMS((char *fname, unsigned long l));
extern int intbuildouttb _PARAMS((char *fname, unsigned long l));
extern int intpermutobj_c _PARAMS((char *fname,unsigned long l));
extern int intscixstringb _PARAMS((char *fname,unsigned long l));

extern int intdata2sig _PARAMS((char *fname, unsigned long l));
extern int intsig2data _PARAMS((char *fname, unsigned long l));
extern int intmodel2blk _PARAMS((char *fname, unsigned long l));
extern int intcallblk _PARAMS((char *fname, unsigned long l));

static intcscicosTable Tab[]={
  {inttimescicos,"scicos_time"},
  {intduplicate,"duplicate"},
  {intdiffobjs,"diffobjs"},
  {intxproperty,"pointer_xproperty"},
  {intphasesim,"phase_simulation"},
  {intsetxproperty,"set_xproperty"},
  {intsetblockerror,"set_blockerror"},
  {inttree2,"ctree2"},
  {inttree3,"ctree3"},
  {inttree4,"ctree4"},
  {intscicosimc,"scicosim"},
  {intgetscicosvarsc,"getscicosvars"},
  {intcurblkc,"curblockc"},
  {intbuildouttb,"buildouttb"},
  {intpermutobj_c,"permutobj"},
  {intscixstringb,"xstringb2"},
  {intendscicosim,"end_scicosim"},
  {intcoserror,"coserror"},
};

static intcscicosTable Tab2[]={
  {intdata2sig,"data2sig"},
  {intsig2data,"sig2data"},
  {intmodel2blk,"model2blk"},
  {intcallblk,"callblk"},
};

int C2F(intcscicos)() {
 (*(Tab[Fin-1].f)) (Tab[Fin-1].name,strlen(Tab[Fin-1].name));
 C2F(putlhsvar)();
 return 0;
}

int C2F(intcutilcos)() {
 (*(Tab2[Fin-1].f)) (Tab2[Fin-1].name,strlen(Tab2[Fin-1].name));
 C2F(putlhsvar)();
 return 0;
}

