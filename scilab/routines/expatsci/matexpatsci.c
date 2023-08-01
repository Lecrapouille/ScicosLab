#include "matexpatsci.h"

extern int intxmlparsercreate_c _PARAMS((char *fname, unsigned long l));
extern int intxmlparserfree_c _PARAMS((char *fname, unsigned long l));
extern int intxmlsetuserdata_c _PARAMS((char *fname, unsigned long l));
extern int intxmlsetelementhandler_c _PARAMS((char *fname, unsigned long l));
extern int intxmlsetcharacterdatahandler_c _PARAMS((char *fname, unsigned long l));
extern int intxmlparse_c _PARAMS((char *fname, unsigned long l));
extern int intxmlconv2latin_c _PARAMS((char *fname, unsigned long l));

extern int intxmlstopparser_c _PARAMS((char *fname,unsigned long l));
extern int intxmlresumeparser_c _PARAMS((char *fname,unsigned long l));

extern int intstripblanks_begin_c _PARAMS((char *fname,unsigned long fname_len));
extern int intstripblanks_end_c _PARAMS((char *fname,unsigned long fname_len));
extern int intstripemptylines_c _PARAMS((char *fname,unsigned long fname_len));

static intexpatsciTable Tab[]={
  {intxmlparsercreate_c,"XML_ParserCreate"},
  {intxmlparserfree_c,"XML_ParserFree"},
  {intxmlsetuserdata_c,"XML_SetUserData"},
  {intxmlsetelementhandler_c,"XML_SetElementHandler"},
  {intxmlsetcharacterdatahandler_c,"XML_SetCharDataHandler"},
  {intxmlparse_c,"XML_Parse"},
  {intxmlconv2latin_c,"XML_Conv2Latin"},
  {intstripblanks_begin_c,"stripblanks_begin"},
  {intstripblanks_end_c,"stripblanks_end"},
  {intstripemptylines_c,"striplines"},
};

static intexpatsciTable Tab2[]={
  {intxmlstopparser_c,"XML_StopParser"},
  {intxmlresumeparser_c,"XML_ResumeParser"},
};

static intexpatsciTable Tab3[]={
  {intstripblanks_begin_c,"stripblanks_begin"},
  {intstripblanks_end_c,"stripblanks_end"},
  {intstripemptylines_c,"striplines"},
};

int C2F(intexpatsci)() {
 Rhs = Max(0, Rhs);
 (*(Tab[Fin-1].f)) (Tab[Fin-1].name,strlen(Tab[Fin-1].name));
 C2F(putlhsvar)();
 return 0;
}

int C2F(intexpatsciutil)() {
 Rhs = Max(0, Rhs);
 (*(Tab2[Fin-1].f)) (Tab2[Fin-1].name,strlen(Tab2[Fin-1].name));
 C2F(putlhsvar)();
 return 0;
}

int C2F(intexpatscistring)() {
 Rhs = Max(0, Rhs);
 (*(Tab3[Fin-1].f)) (Tab3[Fin-1].name,strlen(Tab3[Fin-1].name));
 C2F(putlhsvar)();
 return 0;
}
