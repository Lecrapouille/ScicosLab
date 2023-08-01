/* intxmlparser : scilab interfacing functions for expat library
 *
 * contains :
 *
 *  Utilities functions :
 *  -------------------
 *     -scilab : int C2F(copyvarfromname)(lw,varname)
 *               int GetSciDataLstkPtr(char *DataName)
 *               int GetSciFuncFromName(char *FuncName, int *mlhs, int *mrhs)
 *
 *     -parser : int GetIndPtrStruct(XML_Parser ptr_parser)
 *               int FreeParserPtr(XML_Parser ptr_parser)
 *               int AllowParse(int *i)
 *               int conv2latin(char **str_in, char **str_out)
 *
 *  Handle parser functions :
 *  -----------------------
 *     int start_elm_hndl(void *data,const char *el,const char **attr)
 *     int end_elm_hndl(void *data,const char *el)
 *     int char_hndl(void *data,const char *txt,int txtlen)
 *
 *  Interfacing functions :
 *  ---------------------
 *     int intxmlparsercreate_c(char *fname,unsigned long fname_len)
 *     int intxmlparserfree_c(char *fname,unsigned long fname_len)
 *     int intxmlsetuserdata_c(char *fname,unsigned long fname_len)
 *     int intxmlsetelementhandler_c(char *fname,unsigned long fname_len)
 *     int intxmlsetcharacterdatahandler_c(char *fname,unsigned long fname_len)
 *     int intxmlparse_c(char *fname,unsigned long fname_len)
 *     int intxmlconv2latin_c(char *fname,unsigned long fname_len)
 *
 * Author : A. Layec (alan.layec@inria.fr)
 *          summer work 08/2006
 *          initial revision : 17/08/06
 *          revision : 14/09/2006 support of different encoding
 *          revision : 21/09/2006 convert input char of handler
 *                                function in latin.
 *
 * TODO : constraint on lhs parameter for handler functions
 *        void test of scilab handler functions
 *        int intxmlparserstruct_c(char *fname)
 *        write intxmlparserstruct_c
 *
 */

#include "intxmlparser.h"


static XML_Parser_struct Sci_Parser =
{
  NULL, /* *p           */
  NULL, /* **DataName   */

  NULL, /* **ElmStartHndl */
  NULL, /* **ElmEndHndl   */
  NULL, /* **CharDataHndl   */

  0,    /* nb_CParser   */
  0,    /* nb_RParser   */
  NULL, /* conv2latin */
  NULL  /* CheckParser  */
};

/**********************
 * Utilities functions
 **********************/

/**** ScicosLab stack utilities functions ****/

/*
 *
 */
int C2F(copyvarfromname)(lw,varname)
     integer *lw;
     char *varname;
{
  int un=1;
  int l_lstk;
  int l;
  int sz_ddata;

  l_lstk=GetSciDataLstkPtr(varname);

  if (l_lstk!=0) {
   sz_ddata=GetDataSize(Rhs-Top_stack+l_lstk);

   l=*Lstk(l_lstk);

   CreateData(*lw, sz_ddata*sizeof(double));

   C2F(unsfdcopy)(&sz_ddata,
                  stk(l),&un,
                  stk(*Lstk(*lw + Top_stack - Rhs)),&un);

   return(1);
  }

  return(0);
}

/* Return ptr in Lstk of a scilab
 * variable given its name
 *
 * Input : DataName : the string of the
 *                    variable name to search in idstk
 *                    (null terminated)
 *
 * Output : int : return the position in Lstk of the
 *                variable
 *                return 0 if not found
 *
 */
int GetSciDataLstkPtr(char *DataName)
{
  /* */
  int nv;
  int sz_str;
  int i,j;

  /* */
  if (DataName!=NULL) {
   /* */
   sz_str=strlen(DataName);
   /* */
   if (sz_str!=0)
   {
    /* */
    nv=C2F(vstk).isiz-Bot;

    /* */
    for (j=0;j<nv;j++) {
     /* */
     C2F(cha1).buf[0]=' ';
     C2F(cvnamel)((int *)idstk(1,Bot+j),C2F(cha1).buf,
                  (i=1,&i),&sz_str);
     C2F(cha1).buf[sz_str]='\0';

     /* */
     if (strcmp(DataName,C2F(cha1).buf)==0) {
       /* */
       return(Bot+j);
       /* */
       break;
     }
    }
   }
  }

  /* */
  return(0);
}

/* Return number of lhs/rhs variable of a scilab function
 *  informed by its name
 *
 * Input : FuncName : the string of the
 *                    variable name to search in idstk
 *                    (null terminated)
 *
 * Output : mlhs the number of the lhs variable
 *          mrhs the number of the rhs variable
 *
 *          function returns 1 if succeded
 *                           0 if scilab function doesn't 
 *                              exist in idstk,
 *                          -1 if scilab function isn't
 *                             a type 11 or 13
 *
 */
int GetSciFuncFromName(char *FuncName, int *mlhs, int *mrhs)
{
  /* */
  int l_lstk;
  int type;

  /* */
  l_lstk=GetSciDataLstkPtr(FuncName);

  /* */
  if (l_lstk!=0) {
   /* Get type of scilab variable */
   type = *istk(iadr(*Lstk(l_lstk)));

   /* check if type is 11 or 13 */
   if ((type!=11)&&(type!=13))
    return(-1);

   /* get number of lhs/rhs of the scilab function */
   *mlhs=istk(iadr(*Lstk(l_lstk)))[1];
   *mrhs=istk(iadr(*Lstk(l_lstk)))[1+(*mlhs)*nsiz+1];

   return(1);
  }

  return(0);
}

/**** Parser ****/

/* Return indice in Sci_Parser structure
 * of the ptr informed by his value
 * given in Ptr_int
 *
 * Input : XML_Parser ptr_parser
 *
 * Output : int : - return indice(>=0) of XML_Parser ptr
 *                      in Sci_Parser struct
 *                - return -1 if failed
 *                - return -2 if ptr is free
 *
 */
int GetIndPtrStruct(XML_Parser ptr_parser)
{
  /* counter variable */
  int i;

  /* local variable */
  int nbp;
  int findvar;

  /*npb is the number of created XML_Parser prt*/
  nbp=Sci_Parser.nb_CParser;

  /* return -1 if no ptr */
  if (nbp==0) return(-1);

  /* set a flag */
  findvar=0;

  /* look at for value of ptr_int in
   * Sci_Parser.p struct */
  for (i=0;i<nbp;i++) {
   if(ptr_parser==Sci_Parser.p[i]) {
    findvar=1;
    break;
   }
  }

  /* test if ptr is free */
  if (findvar) {
   if (Sci_Parser.p[i]!=NULL)
      return(i);
   else
      return(-2);
  }

  /* returne default value */
  return(-1);
}

/*
 * Free a Parser ptr in Sci_Parser structure
 *
 * Input : XML_Parser ptr_parser
 *
 * Output : int return 1 if succeeded
 *              return 0 if failed
 *
 */
int FreeParserPtr(XML_Parser ptr_parser)
{
  /* */
  int i;

  /* */
  i=GetIndPtrStruct(ptr_parser);

  /* */
  if (i>=0) {
   /* */
   XML_ParserFree(Sci_Parser.p[i]);
   Sci_Parser.p[i]=NULL;

   /* */
   if (Sci_Parser.DataName[i]!=NULL)
          FREE(Sci_Parser.DataName[i]);
   Sci_Parser.DataName[i]=NULL;

   /* */
   if (Sci_Parser.ElmStartHndl[i]!=NULL)
          FREE(Sci_Parser.ElmStartHndl[i]);
   if (Sci_Parser.ElmEndHndl[i]!=NULL)
          FREE(Sci_Parser.ElmEndHndl[i]);
   if (Sci_Parser.CharDataHndl[i]!=NULL)
          FREE(Sci_Parser.CharDataHndl[i]);

   /* */
   Sci_Parser.nb_RParser--;

   /* */
   if (!Sci_Parser.nb_RParser) {
    FREE(Sci_Parser.p);
    Sci_Parser.p=NULL;

    FREE(Sci_Parser.DataName);
    Sci_Parser.DataName=NULL;

    FREE(Sci_Parser.ElmStartHndl);
    Sci_Parser.ElmStartHndl=NULL;

    FREE(Sci_Parser.ElmEndHndl);
    Sci_Parser.ElmEndHndl=NULL;

    FREE(Sci_Parser.CharDataHndl);
    Sci_Parser.CharDataHndl=NULL;

    FREE(Sci_Parser.CheckParser);
    Sci_Parser.CheckParser=NULL;

    FREE(Sci_Parser.Conv2Latin);
    Sci_Parser.Conv2Latin=NULL;

    Sci_Parser.nb_CParser=0;
   }
   return(1);
  }
  else return(0);
}

/*
 * Check parser structure and allow parse
 *  by putting Sci_Parser.CheckParser[*i] to 1
 *
 * Input : int *i : (valid) indice of a ptr parser 
 *                  in the Sci_Parser struct
 *
 * Output : int return 1 if succeeded
 *              return 0 if failed
 */
int AllowParse(int *i)
{
  /* */
  int l_lstk;
  int mlhs,mrhs;
  int errflag=0;
  char errbuf[4096];
  int ptr_buf=0;

  /* if CheckParser is already set then exit */
  if (Sci_Parser.CheckParser[*i])
         return(Sci_Parser.CheckParser[*i]);

  /* check Sci_Parser struct [i] */

  /* init error buffer */
  strcpy(errbuf," ");

  /* check if scilab variable already exist */

  /* get lstk adress of the scilab object */
  l_lstk=GetSciDataLstkPtr(Sci_Parser.DataName[*i]);

  /* check if scilab variable Dataname[i] exist */
  if (l_lstk==0) {
   /* */
   if(Sci_Parser.DataName[*i]!=NULL) {
     strcat(&errbuf[ptr_buf],"Checking Parser error :\n"
                    "  User data variable doesn't exist.\n"
                    "  Use XML_SetUserData to set it.\n");
     ptr_buf=strlen(errbuf);
     Scierror(999,"%s",errbuf);
     return(0);
   }
  }

  /* check function handler */

    /* check startelementhandler */
    if (Sci_Parser.ElmStartHndl[*i]!=NULL) {
      /* check if startelementhandler scilab function exists */
      switch (GetSciFuncFromName(Sci_Parser.ElmStartHndl[*i],
                                 &mlhs, &mrhs))
      {
       case -1 : {
                  strcat(&errbuf[ptr_buf],"Checking Parser error :\n"
                               "  StartElementHandler function is not\n"
                               "  a scilab function.\n"
                               "  Use XML_SetElementHandler to set it.\n");
                  ptr_buf=strlen(errbuf);
                  errflag=1;
                  break;
                 }

       case  0 : {
                  strcat(&errbuf[ptr_buf],"Checking Parser error :\n"
                               "  StartElementHandler function is missing.\n"
                               "  Use XML_SetElementHandler to set it.\n");
                  ptr_buf=strlen(errbuf);
                  errflag=1;
                  break;
                 }

       default : {
                  /* check number of rhs variable */

                  /* DataName[i] exists*/
                  if (Sci_Parser.DataName[*i]!=NULL) {
                   if(mrhs!=3) {
                    strcat(&errbuf[ptr_buf],"Checking Parser error :\n"
                                  "  StartElementHandler function : bad "
                                  "number of rhs variable.\n"
                                  "  (should be 3)\n"
                                  "  Use XML_SetElementHandler to set it.\n");
                    ptr_buf=strlen(errbuf);
                    errflag=1;
                   }
                  }
                  /* DataName[i] doesn't exists*/
                  else {
                   if(mrhs!=2) {
                    strcat(&errbuf[ptr_buf],"Checking Parser error :\n"
                                 "  StartElementHandler function : bad "
                                 "number of rhs variable.\n"
                                 "  (should be 2)\n"
                                 "  Use XML_SetElementHandler to set it.\n");
                    ptr_buf=strlen(errbuf);
                    errflag=1;
                   }
                  }
                 break;
                 }
      }
    }

    /* check endelementhandler */
    if (Sci_Parser.ElmEndHndl[*i]!=NULL) {
      /* check if endelementhandler scilab function exists */
      switch (GetSciFuncFromName(Sci_Parser.ElmEndHndl[*i],
                                 &mlhs, &mrhs))
      {
       case -1 : {
                  strcat(&errbuf[ptr_buf],"Checking Parser error :\n"
                               "  EndElementHandler function is not\n"
                               "  a scilab function.\n"
                               "  Use XML_SetElementHandler to set it.\n");
                  ptr_buf=strlen(errbuf);
                  errflag=1;
                  break;
                 }

       case  0 : {
                  strcat(&errbuf[ptr_buf],"Checking Parser error :\n"
                               "  EndElementHandler function is missing.\n"
                               "  Use XML_SetElementHandler to set it.\n");
                  ptr_buf=strlen(errbuf);
                  errflag=1;
                  break;
                 }

       default : {

                  /* check number of rhs variable */

                  /* DataName[i] exists*/
                  if (Sci_Parser.DataName[*i]!=NULL) {
                    if(mrhs!=2) {
                      strcat(&errbuf[ptr_buf],"Checking Parser error :\n"
                                     "  EndElementHandler function : bad "
                                     "number of rhs variable.\n"
                                     "  (should be 2)\n"
                                     "  Use XML_SetElementHandler to set it.\n");
                      ptr_buf=strlen(errbuf);
                      errflag=1;
                    }
                  }
                  /* DataName[i] doesn't exists*/
                  else {
                    if(mrhs!=1) {
                      strcat(&errbuf[ptr_buf],"Checking Parser error :\n"
                                 "  EndElementHandler function : bad "
                                 "number of rhs variable.\n"
                                 "  (should be 1)\n"
                                 "  Use XML_SetElementHandler to set it.\n");
                      ptr_buf=strlen(errbuf);
                      errflag=1;
                     }
                  }
                  break;
                 }
      }
    }

    /* check xmlcharacterdatahandler */
    if (Sci_Parser.CharDataHndl[*i]!=NULL) {
      /* check if characterdatahandler scilab function exists */
      switch (GetSciFuncFromName(Sci_Parser.CharDataHndl[*i],
                                 &mlhs, &mrhs))
      {
       case -1 : {
                  strcat(&errbuf[ptr_buf],"Checking Parser error :\n"
                               "  CharacterDataHandler function is not\n"
                               "  a scilab function.\n"
                               "  Use XML_SetCharacterDataHandler to set it.\n");
                  ptr_buf=strlen(errbuf);
                  errflag=1;
                  break;
                 }

       case  0 : {
                  strcat(&errbuf[ptr_buf],"Checking Parser error :\n"
                               "  CharacterDataHandler function is missing.\n"
                               "  Use XML_SetCharacterDataHandler to set it.\n");
                  ptr_buf=strlen(errbuf);
                  errflag=1;
                  break;
                 }

       default : {
                  /* check number of rhs variable */

                  /* DataName[i] exists*/
                  if (Sci_Parser.DataName[*i]!=NULL) {
                   if(mrhs!=2) {
                    strcat(&errbuf[ptr_buf],"Checking Parser error :\n"
                                  "  CharacterDataHandler function : bad "
                                  "number of rhs variable.\n"
                                  "  (should be 2)\n"
                                  "  Use XML_SetCharacterDataHandler to set it.\n");
                    ptr_buf=strlen(errbuf);
                    errflag=1;
                   }
                  }
                  /* DataName[i] doesn't exists*/
                  else {
                   if(mrhs!=1) {
                     strcat(&errbuf[ptr_buf],"Checking Parser error :\n"
                                "  CharacterDataHandler function : bad "
                                "number of rhs variable.\n"
                                "  (should be 1)\n"
                                "  Use XML_SetCharacterDataHandler to set it.\n");
                     ptr_buf=strlen(errbuf);
                     errflag=1;
                   }
                  }
                  break;
                 }
      }
    }

  /* */
  if (errflag) {
    Scierror(999,"%s",errbuf);
    return(0);
  }
  /* */
  else {
   Sci_Parser.CheckParser[*i]=1;

   /* use indice *i in UserData */
   XML_SetUserData(Sci_Parser.p[*i],
                   (void *) i);

   return(Sci_Parser.CheckParser[*i]);
  }

}

/* conv2latin
 * Convert a string given from utf to
 *  latin string
 *
 * rmq : input/output string must be allocated
 *       before calling of conv2latin
 *
 */
int conv2latin(char **str_in, char **str_out)
{
 /* */
 char *str1,*str2;
 int lstr_in,lstr_out;

 /* */
 int j=0;
 char cv,cv2;

 /* Get string address variable */
 str1=str_in[0];
 str2=str_out[0];
 /* */
 lstr_in=strlen(str1);
 lstr_out=0;

 /*loop on number of caracter of str_in*/
 while(j<lstr_in) {
   /* */
   lstr_out++;

   /* if str1[j]>0 it is US-ASCII */
   if (str1[j]>0) {
     str2[lstr_out-1]=str1[j];
   }
   /* else try convertion */
   else {
     /* */
     cv=(str1[j]&3);
     cv2=(str1[j+1]&63);
     /* */
     cv=(cv<<6)|cv2;
     /* */
     str2[lstr_out-1]=cv;
     j++;
   }
   j++;
 }
 /* */
 str2[lstr_out]='\0';

 /* */
 return(0);
}

/*************************
 * Handle parser functions
 *************************/

/* Function called by XML_Parse
 *   Setting by XML_SetStartElementHandler
 *           or XML_SetElementHandler
 */
int start_elm_hndl(void *data,
                   const char *el,
                   const char **attr)
{
 /* */
 static int *i;
 char **Str_attr=NULL;
//  char *Str_in;
 char *Str_out;
 int ellen;

 int sz_attrN;
 int sz_attrV;

 int zero=0;
 int one=1;
 int two=2;
 int three=3;

 int m1,n1;
 int m2,n2;
 int m3,n3;

 /* */
 int ibegin;
 int j;

 /* */
 i=(int *) data;

 /* */
 if (Sci_Parser.DataName[*i]!=NULL) {
 /* calling sequence with 3 parameters */
  ibegin=Rhs+1;

  /* rhs(1) is scilab object informed by 
   *        Sci_Parser.DataName[*i] 
   */
  CopyVarFromName(ibegin,Sci_Parser.DataName[*i]);

  /* rhs(2) is const char *el */
  m2=1;
  n2=1;
  if (Sci_Parser.Conv2Latin[*i]) {
   ellen=strlen(el);

/*    Str_in=MALLOC((ellen+1)*sizeof(char));*/
   Str_out=MALLOC((ellen+1)*sizeof(char));
/*    strcpy(Str_in,el);*/

   conv2latin((char **)&el,&Str_out);

   CreateVarFromPtr(ibegin+1,"S", &m2, &n2, &Str_out);

/*    FREE(Str_in);*/
   FREE(Str_out);
  }
  else {
   CreateVarFromPtr(ibegin+1,"S", &m2, &n2, &el);
  }

  /* rhs(3) is const char **attr */
  m3=0;
  n3=2;
  for (j=0; attr[j]; j += 2) {
   /* realloc number of attr */
   Str_attr=REALLOC(Str_attr,((m3+1)*2)*sizeof(char *));
   Str_attr[m3*2]=NULL;
   Str_attr[(m3*2)+1]=NULL;

   /* copy name of attr in Str_attr[m3*2] */
   sz_attrN=strlen(attr[j]);
   Str_attr[m3*2]=REALLOC(Str_attr[m3*2],(sz_attrN+1)*sizeof(char));
   if (Sci_Parser.Conv2Latin[*i]) {
    conv2latin((char **)&attr[j],&Str_attr[m3*2]);
   }
   else {
    strcpy(Str_attr[m3*2],attr[j]);
   }

   /* copy value of attr in Str_attr[(m3*2)+1] */
   sz_attrV=strlen(attr[j+1]);
   Str_attr[(m3*2)+1]=REALLOC(Str_attr[(m3*2)+1],(sz_attrV+1)*sizeof(char));
   if (Sci_Parser.Conv2Latin[*i]) {
    conv2latin((char **)&attr[j+1],&Str_attr[(m3*2)+1]);
   }
   else {
    strcpy(Str_attr[(m3*2)+1],attr[j+1]);
   }

   /* increase m3 */
   m3++;
  }
  CreateVarFromPtr(ibegin+2,"S", &m3, &n3, Str_attr);

  for (j=0;j<m3*n3;j++) FREE(Str_attr[j]);
  FREE(Str_attr);
  Str_attr=NULL;

  /* call scilab function Sci_Parser.ElmStartHndl[*i] */
  SciString(&ibegin,Sci_Parser.ElmStartHndl[*i],&one,&three);

  /* Put user data in stack */
  PutVar(ibegin,Sci_Parser.DataName[*i]);

 }

 /* calling sequence with 2 parameters */
 else {
  ibegin=Rhs+1;

  /* rhs(1) is const char *el */
  m1=1;
  n1=1;
  if (Sci_Parser.Conv2Latin[*i])
  {
   ellen=strlen(el);

/*    Str_in=MALLOC((ellen+1)*sizeof(char));*/
   Str_out=MALLOC((ellen+1)*sizeof(char));

/*    strcpy(Str_in,el);*/

   conv2latin((char **)&el,&Str_out);

   CreateVarFromPtr(ibegin,"S", &m1, &n1, &Str_out);

/*    FREE(Str_in);*/
   FREE(Str_out);
  }
  else {
   CreateVarFromPtr(ibegin,"S", &m1, &n1, &el);
  }

  /* rhs(2) is const char **attr */
  m2=0;
  n2=2;

  for (j=0; attr[j]; j += 2) {
   /* realloc number of attr */
   Str_attr=REALLOC(Str_attr,((m2+1)*2)*sizeof(char *));
   Str_attr[m2*2]=NULL;
   Str_attr[(m2*2)+1]=NULL;

   /* copy name of attr in Str_attr[m2*2] */
   sz_attrN=strlen(attr[j]);
   Str_attr[m2*2]=REALLOC(Str_attr[m2*2],(sz_attrN+1)*sizeof(char));
   if (Sci_Parser.Conv2Latin[*i]) {
     conv2latin((char **)&attr[j],&Str_attr[m2*2]);
   }
   else {
    strcpy(Str_attr[m2*2],attr[j]);
   }

   /* copy value of attr in Str_attr[(m2*2)+1] */
   sz_attrV=strlen(attr[j+1]);
   Str_attr[(m2*2)+1]=REALLOC(Str_attr[(m2*2)+1],
                              (sz_attrV+1)*sizeof(char));
   if (Sci_Parser.Conv2Latin[*i]) {
    conv2latin((char **)&attr[j+1],&Str_attr[(m2*2)+1]);
   }
   else {
    strcpy(Str_attr[(m2*2)+1],attr[j+1]);
   }

   /* increase m2 */
   m2++;
  }

  CreateVarFromPtr(ibegin+1,"S", &m2, &n2, Str_attr);

  for (j=0;j<m2*n2;j++) FREE(Str_attr[j]);
  FREE(Str_attr);
  Str_attr=NULL;

  /* call scilab function Sci_Parser.ElmStartHndl[*i] */
  SciString(&ibegin,Sci_Parser.ElmStartHndl[*i],&zero,&two);
 }

 return 0;
}

/* Function called by XML_Parse
 *   Setting by XML_SetEndElementHandler
 *           or XML_SetElementHandler
 */
int end_elm_hndl(void *data,
                 const char *el)
{
 /* */
 static int *i;

 int zero=0;
 int one=1;
 int two=2;

 int m1,n1;
 int m2,n2;

/*  char *Str_in;*/
 char *Str_out;
 int ellen;

 /* */
 int ibegin;

 /* */
 i=(int *) data;

 /* calling sequence with 2 parameters */
 if (Sci_Parser.DataName[*i]!=NULL) {
   ibegin=Rhs+1;

   /* rhs(1) is scilab object informed by
    *        Sci_Parser.DataName[*i]
    */
   CopyVarFromName(ibegin,Sci_Parser.DataName[*i]);

   /* rhs(2) is const char *el */
   m2=1;
   n2=1;

   if (Sci_Parser.Conv2Latin[*i]) {
     ellen=strlen(el);

/*     Str_in=MALLOC((ellen+1)*sizeof(char));*/
     Str_out=MALLOC((ellen+1)*sizeof(char));

/*     strcpy(Str_in,el);*/

     conv2latin((char **)&el,&Str_out);

     CreateVarFromPtr(ibegin+1,"S", &m2, &n2, &Str_out);

/*     FREE(Str_in);*/
     FREE(Str_out);
   }
   else {
     CreateVarFromPtr(ibegin+1,"S", &m2, &n2, &el);
   }

   /* call scilab function Sci_Parser.ElmStartHndl[*i] */
   SciString(&ibegin,Sci_Parser.ElmEndHndl[*i],&one,&two);

   /* Put user data in stack */
   PutVar(ibegin,Sci_Parser.DataName[*i]);
 }

 /* calling sequence with 1 parameter */
 else {
  ibegin=Rhs+1;

  /* rhs(1) is const char *el */
  m1=1;
  n1=1;

  if (Sci_Parser.Conv2Latin[*i]) {
    ellen=strlen(el);

/*     Str_in=MALLOC((ellen+1)*sizeof(char));*/
    Str_out=MALLOC((ellen+1)*sizeof(char));

/*     strcpy(Str_in,el);*/

    conv2latin((char **)&el,&Str_out);

    CreateVarFromPtr(ibegin,"S", &m1, &n1, &Str_out);

/*     FREE(Str_in);*/
    FREE(Str_out);
  }
  else {
   CreateVarFromPtr(ibegin,"S", &m1, &n1, &el);
  }

  /* call scilab function Sci_Parser.ElmStartHndl[*i] */
  SciString(&ibegin,Sci_Parser.ElmEndHndl[*i],&zero,&one);
 }

 return 0;
}

/* Function called by XML_Parse
 *   Setting by XML_SetCharacterDataHandler
 *
 */
int char_hndl(void *data,
              const char *txt,
              int txtlen)
{
 /* */
 static int *i;

 char *Str_in=NULL;
 char *Str_out=NULL;

 int zero=0;
 int one=1;
 int two=2;

 int m1,n1;
 int m2,n2;

 /* */
 int ibegin;
 int j;

 /* */
 i=(int *) data;

 /* calling sequence with 2 parameters */
 if (Sci_Parser.DataName[*i]!=NULL) {
  ibegin=Rhs+1;

  /* rhs(1) is scilab object informed by 
   *        Sci_Parser.DataName[*i] 
   */
  CopyVarFromName(ibegin,Sci_Parser.DataName[*i]);

  /* rhs(2) is const char *el */
  if (Sci_Parser.Conv2Latin[*i]) {
    Str_in=MALLOC((txtlen+1)*sizeof(char));
    Str_out=MALLOC((txtlen+1)*sizeof(char));

    for(j=0;j<txtlen;j++) Str_in[j]=txt[j];
    Str_in[txtlen]='\0';

    conv2latin(&Str_in,&Str_out);

    m2=1;
    n2=1;
    CreateVarFromPtr(ibegin+1,"S", &m2, &n2, &Str_out);

    FREE(Str_in);
    FREE(Str_out);
  }
  else {
    m2=txtlen;
    n2=1;

    CreateVarFromPtr(ibegin+1,"c", &m2, &n2, &txt);
    Convert2Sci(ibegin+1);
  }

  /* call scilab function Sci_Parser.ElmStartHndl[*i] */
  SciString(&ibegin,Sci_Parser.CharDataHndl[*i],&one,&two);

  /* Put user data in stack */
  PutVar(ibegin,Sci_Parser.DataName[*i]);
 }

 /* calling sequence with 1 parameter */
 else {
  ibegin=Rhs+1;

  /* rhs(1) is const char *el */
  if (Sci_Parser.Conv2Latin[*i]) {
    Str_in=MALLOC((txtlen+1)*sizeof(char));
    Str_out=MALLOC((txtlen+1)*sizeof(char));

    for(j=0;j<txtlen;j++) Str_in[j]=txt[j];
    Str_in[txtlen]='\0';

    conv2latin(&Str_in,&Str_out);

    m1=1;
    n1=1;
    CreateVarFromPtr(ibegin,"S", &m1, &n1, &Str_out);

    FREE(Str_in);
    FREE(Str_out);
  }
  else {
    m1=txtlen;
    n1=1;

    CreateVarFromPtr(ibegin,"c", &m1, &n1, &txt);
    Convert2Sci(ibegin);
  }

  /* call scilab function Sci_Parser.ElmStartHndl[*i] */
  SciString(&ibegin,Sci_Parser.CharDataHndl[*i],&zero,&one);
 }

 return 0;
}

/*************************
 * Interfacing functions
 ************************/

/* Create a new XML_Parser Ptr
 *
 * Scilab Calling sequence :
 *   -->%ptr=XML_ParserCreate();
 *  or
 *   -->%ptr2=XML_ParserCreate("UTF-8");
 *
 * Input : empty
 *
 * Output : ptr to Sci_Parser.p[nbp+1]
 *
 */
int intxmlparsercreate_c(char *fname,unsigned long fname_len)
{
  /* */
  static int m1, n1;
  char **Str1;
  /*def. number of alloed entries for XML_ParserCreate*/
  int nbstr=4;
  static char *Str[]= {"US-ASCII", "UTF-8","UTF-16", "ISO-8859-1"};

  /* */
  int i,j,nbp;

  /* Check number of Lhs/Rhs parameters*/
  CheckLhs(1,1);
  CheckRhs(0,1);

  /* Check number of rhs parameter */
  if (Rhs==1) {
   /*get string data */
   GetRhsVar(1,"S",&m1,&n1,&Str1);

   /*check dims of string matrix*/
   CheckDims(1,m1,n1,1,1);
  }

  /* */
  nbp=Sci_Parser.nb_CParser;

  /* */
  Sci_Parser.p=REALLOC(Sci_Parser.p,
                       sizeof(XML_Parser)*(nbp+1));
  Sci_Parser.DataName=REALLOC(Sci_Parser.DataName,
                              sizeof(char *)*(nbp+1));

  Sci_Parser.ElmStartHndl=REALLOC(Sci_Parser.ElmStartHndl,
                                  sizeof(char *)*(nbp+1));
  Sci_Parser.ElmEndHndl=REALLOC(Sci_Parser.ElmEndHndl,
                                sizeof(char *)*(nbp+1));
  Sci_Parser.CharDataHndl=REALLOC(Sci_Parser.CharDataHndl,
                                  sizeof(char *)*(nbp+1));

  Sci_Parser.CheckParser=REALLOC(Sci_Parser.CheckParser,
                                 sizeof(int)*(nbp+1));


  Sci_Parser.Conv2Latin=REALLOC(Sci_Parser.Conv2Latin,
                                 sizeof(int)*(nbp+1));

  /* */
  if ((!Sci_Parser.p)||
      (!Sci_Parser.DataName)||
      (!Sci_Parser.ElmStartHndl)||
      (!Sci_Parser.ElmEndHndl)||
      (!Sci_Parser.CharDataHndl)||
      (!Sci_Parser.CheckParser)||
      (!Sci_Parser.Conv2Latin)) {
   Scierror(999,"%s: "
                "Couldn't allocate memory "
                "for parser structure\n",
            fname);
   return(0);
  }

  /* */
  j=0;
  if (Rhs==1) {
    for (i=0;i<nbstr;i++) {
      if (strcmp(Str1[0],Str[i])==0) {
        Sci_Parser.p[nbp]=XML_ParserCreate(Str1[0]);
        j=1;
        break;
      }
    }
    if (!j) {
      sciprint("%s : Warning : "
               "%s, unknown encoding.\n",
               fname,Str1[0]);
      Sci_Parser.p[nbp]=XML_ParserCreate(NULL);
    }
  }
  else {
    Sci_Parser.p[nbp]=XML_ParserCreate(NULL);
  }

  /* */
  if (!Sci_Parser.p[nbp]) {
    Scierror(999,"%s: "
                 "No more memory for parser\n",
             fname);

    /* */
    Sci_Parser.p=REALLOC(Sci_Parser.p,
                         sizeof(XML_Parser)*nbp);
    Sci_Parser.DataName=REALLOC(Sci_Parser.DataName,
                                sizeof(char *)*(nbp));

    Sci_Parser.ElmStartHndl=REALLOC(Sci_Parser.ElmStartHndl,
                                    sizeof(char *)*(nbp));
    Sci_Parser.ElmEndHndl=REALLOC(Sci_Parser.ElmEndHndl,
                                  sizeof(char *)*(nbp));
    Sci_Parser.CharDataHndl=REALLOC(Sci_Parser.CharDataHndl,
                                  sizeof(char *)*(nbp));

    Sci_Parser.CheckParser=REALLOC(Sci_Parser.CheckParser,
                                   sizeof(int)*(nbp));

    Sci_Parser.Conv2Latin=REALLOC(Sci_Parser.Conv2Latin,
                                   sizeof(int)*(nbp));
    return(0);
  }

  /* */
  Sci_Parser.DataName[nbp]=NULL;
  Sci_Parser.ElmStartHndl[nbp]=NULL;
  Sci_Parser.ElmEndHndl[nbp]=NULL;
  Sci_Parser.CharDataHndl[nbp]=NULL;

  /* */
  Sci_Parser.CheckParser[nbp]=0;
  Sci_Parser.Conv2Latin[nbp]=0;

  /* */
  Sci_Parser.nb_CParser++;
  Sci_Parser.nb_RParser++;

  /* Get position of lhs*/
  if (Rhs==1) {
    i=2;
    FreeRhsSVar(Str1);
  }
  else i=1;

  /* */
  CreateVarFromPtr(i,"p",(m1=1,&m1),(n1=1,&n1),
                   Sci_Parser.p[nbp]);

  /* */
  LhsVar(1)=i;

  /* */
  return(0);
}

/* Free a XML_Parser Ptr
 *
 * Scilab Calling sequence :
 *   -->XML_ParserFree(%ptr);
 *
 * Input : a scilab pointer object
 *
 * Output : nothing
 *
 */
int intxmlparserfree_c(char *fname,unsigned long fname_len)
{
  /*variable to access function parameters*/
  static int l1, m1, n1;

  /*local variable*/
  XML_Parser ptr_parser;

  /* */
  CheckRhs(1,1);

  /* */
  GetRhsVar(1,"p",&m1,&n1,&l1);
  ptr_parser = (XML_Parser) ((unsigned long int) *stk(l1));

  /* */
  if(!FreeParserPtr(ptr_parser))
     Scierror(999,"%s: "
                  "Rhs(1) : Parser ptr not valid\n",
                  fname);

  /* */
  return(0);
}

/* Set user data of handle function
 *
 * Scilab Calling sequence :
 *   -->XML_SetUserData(%ptr,'data');
 *
 * Input : rhs(1) : a scilab pointer object
 *         rhs(2) : a scilab string
 *
 * Output : nothing
 *
 */
int intxmlsetuserdata_c(char *fname,unsigned long fname_len)
{
  /*variable to access function parameters*/
  static int l1, m1, n1;
  XML_Parser ptr_parser;

  static int m2,n2,l2;
  char **name;

  static int m3,n3,l3;

  int mlhs, mrhs;

  int sz_str;
  int i;

  /* */
  CheckRhs(2,2);

  /*****************************************/
  /* Get/check rhs(1) : XML_Parser ptr */
  GetRhsVar(1,"p",&m1,&n1,&l1);
  ptr_parser = (XML_Parser) ((unsigned long int) *stk(l1));

  i=GetIndPtrStruct(ptr_parser);

  if((i==-1)||(i==-2)) {
    Scierror(999,"%s: "
                 "Rhs(1) : Parser ptr not valid\n",
             fname);
    return(0);
  }
  /*****************************************/

  /* Get/check rhs(2) : a string (size 1x1) pointing on a scilab object */
  GetRhsVar(2,"S",&m2,&n2,&name);

  /* get lstk adress of the scilab object */
  l2=GetSciDataLstkPtr(name[0]);

  /* check if scilab variable already exist */
  if (l2!=0) {
    /* */
    sz_str=strlen(name[0]);
    Sci_Parser.DataName[i]=MALLOC((sz_str+1)*sizeof(char));
    strcpy(Sci_Parser.DataName[i],name[0]);
  }
  else {
    /* */
    if (Sci_Parser.DataName[i]!=NULL)
          FREE(Sci_Parser.DataName[i]);
    Sci_Parser.DataName[i]=NULL;

    /* user facility : create an empty scilab object */
    if(strlen(name[0])!=0) {
      /*if length of name[0] isn't 0 then create an empty scilab variable*/
      CreateVar(3,"d",(m3=0,&m3),(n3=0,&n3),&l3);
      PutVar(3, name[0]);

      /* */
      sz_str=strlen(name[0]);
      Sci_Parser.DataName[i]=MALLOC((sz_str+1)*sizeof(char));
      strcpy(Sci_Parser.DataName[i],name[0]);
    }
  }

  /* check function handler */

  /* check startelementhandler */
  if (Sci_Parser.ElmStartHndl[i]!=NULL) {
   /* check if startelementhandler scilab function exists */
   switch (GetSciFuncFromName(Sci_Parser.ElmStartHndl[i], &mlhs, &mrhs))
   {
    case -1 : {
               sciprint("Warning : StartElementHandler function : %s"
                        "  is not a scilab function.\n"
                        "  Use XML_SetElementHandler to set it.\n",
                        Sci_Parser.ElmStartHndl[i]);
               /* */
               Sci_Parser.CheckParser[i]=0;

               break;
              }

    case  0 : {
               sciprint("Warning : StartElementHandler function : %s\n"
                        "  is missing.\n"
                        "  Use XML_SetElementHandler to set it.\n",
                        Sci_Parser.ElmStartHndl[i]);
               /* */
               Sci_Parser.CheckParser[i]=0;

               break;
              }

    default : {
               /* check number of rhs variable */

               /* DataName[i] exists*/
               if (Sci_Parser.DataName[i]!=NULL)
               {
                if(mrhs!=3)
                {
                 sciprint("Warning : Start ElementHandler function :\n"
                          "  Bad number of rhs variable.\n"
                          "  (should be 3)\n"
                          "  Use XML_SetElementHandler to set it.\n");
                 /* */
                 Sci_Parser.CheckParser[i]=0;
                }
               }
               /* DataName[i] doesn't exists*/
               else
               {
                if(mrhs!=2)
                {
                 sciprint("Warning : Start ElementHandler function :\n"
                          "  Bad number of rhs variable.\n"
                          "  (should be 2)\n"
                          "  Use XML_SetElementHandler to set it.\n");
                 /* */
                 Sci_Parser.CheckParser[i]=0;
                }
               }
               break;
              }
   }
  }

  /* check endelementhandler */
  if (Sci_Parser.ElmEndHndl[i]!=NULL) {
   /* check if endelementhandler scilab function exists */
   switch (GetSciFuncFromName(Sci_Parser.ElmEndHndl[i], &mlhs, &mrhs))
   {
    case -1 : {
               sciprint("Warning : EndElementHandler function : %s"
                        "  is not a scilab function.\n"
                        "  Use XML_SetElementHandler to set it.\n",
                        Sci_Parser.ElmEndHndl[i]);
               /* */
               Sci_Parser.CheckParser[i]=0;

               break;
              }

    case  0 : {
               sciprint("Warning : EndElementHandler function : %s\n"
                        "  is missing.\n"
                        "  Use XML_SetElementHandler to set it.\n",
                        Sci_Parser.ElmEndHndl[i]);
               /* */
               Sci_Parser.CheckParser[i]=0;

               break;
              }

    default : {
               /* check number of rhs variable */

               /* DataName[i] exists*/
               if (Sci_Parser.DataName[i]!=NULL)
               {
                if(mrhs!=2)
                {
                 sciprint("Warning : End ElementHandler function :\n"
                          "  Bad number of rhs variable.\n"
                          "  (should be 2)\n"
                          "  Use XML_SetElementHandler to set it.\n");
                 /* */
                 Sci_Parser.CheckParser[i]=0;
                }
               }
               /* DataName[i] doesn't exists*/
               else
               {
                if(mrhs!=1)
                {
                 sciprint("Warning : End ElementHandler function :\n"
                          "  Bad number of rhs variable.\n"
                          "  (should be 1)\n"
                          "  Use XML_SetElementHandler to set it.\n");
                 /* */
                 Sci_Parser.CheckParser[i]=0;
                }
               }
               break;
              }
   }
  }

  /* check xmlcharacterdatahandler */
  if (Sci_Parser.CharDataHndl[i]!=NULL) {
   /* check if characterdatahandler scilab function exists */
   switch (GetSciFuncFromName(Sci_Parser.CharDataHndl[i], &mlhs, &mrhs))
   {
    case -1 : {
               sciprint("Warning : CharacterDataHandler function : %s"
                        "  is not a scilab function.\n"
                        "  Use XML_SetCharacterDataHandler to set it.\n",
                        Sci_Parser.CharDataHndl[i]);
               /* */
               Sci_Parser.CheckParser[i]=0;

               break;
              }

    case  0 : {
               sciprint("Warning : CharacterDataHandler function : %s\n"
                        "  is missing.\n"
                        "  Use XML_SetCharacterDataHandler to set it.\n",
                        Sci_Parser.CharDataHndl[i]);
               /* */
               Sci_Parser.CheckParser[i]=0;

               break;
              }

    default : {
               /* check number of rhs variable */

               /* DataName[i] exists*/
               if (Sci_Parser.DataName[i]!=NULL) {
                if(mrhs!=2) {
                 sciprint("Warning : CharacterDataHandler function :\n"
                          "  Bad number of rhs variable.\n"
                          "  (should be 2)\n"
                          "  Use XML_SetCharacterDataHandler to set it.\n");
                 /* */
                 Sci_Parser.CheckParser[i]=0;
                }
               }
               /* DataName[i] doesn't exists*/
               else {
                if(mrhs!=1) {
                 sciprint("Warning : CharacterDataHandler function :\n"
                          "  Bad number of rhs variable.\n"
                          "  (should be 1)\n"
                          "  Use XML_SetCharacterDataHandler to set it.\n");
                 /* */
                 Sci_Parser.CheckParser[i]=0;
                }
               }
               break;
              }
   }
  }

  FreeRhsSVar(name);

  return(0);
}

/* Set scilab functions for element handler
 *
 * Scilab Calling sequence :
 *   -->XML_SetElementHandler(%ptr,...
                              'start_handl',...
                              'end_handl');
 *
 * Input : rhs(1) : a scilab pointer object
 *         rhs(2) : a scilab string
 *         rhs(3) : a scilab string
 *
 * Output : nothing
 *
 */
int intxmlsetelementhandler_c(char *fname,unsigned long fname_len)
{
   /* */
  static int l1, m1, n1;
  XML_Parser ptr_parser;

  static int m2,n2,mlhs1,mrhs1;
  char **fname_1;

  static int m3,n3,mlhs2,mrhs2;
  char **fname_2;

  int i;
  int sz_str;

  /* */
  CheckRhs(3,3);

  /*****************************************/
  GetRhsVar(1,"p",&m1,&n1,&l1);
  ptr_parser = (XML_Parser) ((unsigned long int) *stk(l1));

  i=GetIndPtrStruct(ptr_parser);

  if((i==-1)||(i==-2)) {
   Scierror(999,"%s: "
                "Rhs(1) : Parser ptr not valid\n",
            fname);
   return(0);
  }
  /*****************************************/

  /******************************************/
  /* */
  GetRhsVar(2,"S",&m2,&n2,&fname_1);

  /* free ElmStartHndl[i] if fname_1[0] is emtpy */
  if (strlen(fname_1[0])==0) {
    if(Sci_Parser. ElmStartHndl[i]!=NULL) {
      FREE(Sci_Parser. ElmStartHndl[i]);
      Sci_Parser. ElmStartHndl[i]=NULL;
     }
     /* call XML_SetStartElementHandler */
     XML_SetStartElementHandler(Sci_Parser.p[i],
                                NULL);
     /* */
     FreeRhsSVar(fname_1);
  }
  else {
   switch (GetSciFuncFromName(fname_1[0], &mlhs1, &mrhs1))
   {
    case -1 : {
               Scierror(999,"%s:\n"
                            "  StartElementHandler function : %s\n"
                            "  is not a scilab function.\n",
                            fname,fname_1[0]);
               /* */
               Sci_Parser.CheckParser[i]=0;
               /* */
               FreeRhsSVar(fname_1);
               /* */
               return(0);
               break;
              }

    case  0 : {
               Scierror(999,"%s:\n"
                            "  StartElementHandler function : %s\n"
                            "  is not defined.\n",
                            fname,fname_1[0]);
               /* */
               Sci_Parser.CheckParser[i]=0;
               /* */
               FreeRhsSVar(fname_1);
               /* */
               return(0);
               break;
              }

    default : {
               /* check number of rhs variable */

               /* userdata exists */
               if (Sci_Parser.DataName[i]==NULL) {
                if (mrhs1!=2) {
                 Scierror(999,"%s: Rhs(2) :\n"
                              "  Function has invalid number of rhs argument\n"
                              "  (should be 2)\n",
                              fname);
                 FreeRhsSVar(fname_1);

                 return(0);
                 break;
                }
               }
               /* userdata doesn't exists */
               else {
                if (mrhs1!=3) {
                 Scierror(999,"%s: Rhs(2) :\n"
                              "  Function has invalid number of rhs argument\n"
                              "  (should be 3)\n",
                              fname);
                 FreeRhsSVar(fname_1);

                 return(0);
                 break;
                }
               }

               /* */
               sz_str=strlen(fname_1[0]);
               Sci_Parser.ElmStartHndl[i]=MALLOC((sz_str+1)*sizeof(char));
               strcpy(Sci_Parser.ElmStartHndl[i],fname_1[0]);

               /* call XML_SetStartElementHandler */
               XML_SetStartElementHandler(Sci_Parser.p[i],
                                         (void *) start_elm_hndl);

               FreeRhsSVar(fname_1);
               break;
              }
   }
  }

  /* */
  GetRhsVar(3,"S",&m3,&n3,&fname_2);

  /* free ElmEndHndl[i] if fname_2[0] is emtpy */
  if (strlen(fname_2[0])==0) {
    if(Sci_Parser. ElmEndHndl[i]!=NULL) {
      FREE(Sci_Parser. ElmEndHndl[i]);
      Sci_Parser. ElmEndHndl[i]=NULL;
     }
     /* call XML_SetEndElementHandler */
     XML_SetEndElementHandler(Sci_Parser.p[i],
                               NULL);
     /* */
     FreeRhsSVar(fname_2);
  }
  else {
   switch (GetSciFuncFromName(fname_2[0], &mlhs2, &mrhs2))
   {
    case -1 : {
               Scierror(999,"%s:\n"
                            "  EndElementHandler function : %s\n"
                            "  is not a scilab function.\n",
                            fname,fname_2[0]);
               /* */
               Sci_Parser.CheckParser[i]=0;
               /* */
               FreeRhsSVar(fname_2);
               /* */
               return(0);
               break;
              }

    case  0 : {
               Scierror(999,"%s:\n"
                            "  EndElementHandler function : %s\n"
                            "  is not defined.\n",
                            fname,fname_2[0]);
               /* */
               Sci_Parser.CheckParser[i]=0;
               /* */
               FreeRhsSVar(fname_2);
               /* */
               return(0);
               break;
              }

    default : {
               /* check number of rhs variable */

               /* userdata exists */
               if (Sci_Parser.DataName[i]==NULL) {
                 if (mrhs2!=1) {
                   Scierror(999,"%s: Rhs(3) :\n"
                                "  Function has invalid number of rhs argument\n"
                                "  (should be 1)\n",
                                fname);

                   FreeRhsSVar(fname_2);
                   return(0);
                   break;
                 }
               }
               /* userdata doesn't exists */
               else {
                 if (mrhs2!=2) {
                  Scierror(999,"%s: Rhs(3) :\n"
                               "  Function has invalid number of rhs argument\n"
                               "  (should be 2)\n",
                               fname);
                  FreeRhsSVar(fname_2);

                  return(0);
                  break;
                 }
               }

               /* */
               sz_str=strlen(fname_2[0]);
               Sci_Parser.ElmEndHndl[i]=MALLOC((sz_str+1)*sizeof(char));
               strcpy(Sci_Parser.ElmEndHndl[i],fname_2[0]);

               /* call XML_SetEndElementHandler */
               XML_SetEndElementHandler(Sci_Parser.p[i],
                                        (void *) end_elm_hndl);

               FreeRhsSVar(fname_2);
               break;
              }
   }
  }

  return(0);
}

/* Set scilab function for Character Data handler
 *
 * Scilab Calling sequence :
 *   -->XML_SetCharacterDataHandler(%ptr,...
                                   'char_handl');
 *
 * Input : rhs(1) : a scilab pointer object
 *         rhs(2) : a scilab string
 *
 * Output : nothing
 *
 */
int intxmlsetcharacterdatahandler_c(char *fname,unsigned long fname_len)
{
  /* */
  static int l1, m1, n1;
  XML_Parser ptr_parser;

  static int m2,n2,mlhs1,mrhs1;
  char **fname_1;

  int i;
  int sz_str;

  /* */
  CheckRhs(2,2);

  /*****************************************/
  GetRhsVar(1,"p",&m1,&n1,&l1);
  ptr_parser = (XML_Parser) ((unsigned long int) *stk(l1));

  i=GetIndPtrStruct(ptr_parser);

  if((i==-1)||(i==-2)) {
    Scierror(999,"%s: "
                 "Rhs(1) : Parser ptr not valid\n",
             fname);
    return(0);
  }
  /*****************************************/

  /******************************************/
  /* */
  GetRhsVar(2,"S",&m2,&n2,&fname_1);

  /* free CharacterDataHandler[i] if fname_1[0] is emtpy */
  if (strlen(fname_1[0])==0) {
    if(Sci_Parser.CharDataHndl[i]!=NULL) {
      FREE(Sci_Parser.CharDataHndl[i]);
      Sci_Parser.CharDataHndl[i]=NULL;
     }
     /* call XML_SetCharacterDataHandler */
     XML_SetCharacterDataHandler(Sci_Parser.p[i],
                                 NULL);

     FreeRhsSVar(fname_1);
     return(0);
  }

  /* check if function is in scilab stack */
  switch (GetSciFuncFromName(fname_1[0], &mlhs1, &mrhs1))
  {
   case -1 : {
              Scierror(999,"%s:\n"
                           "  CharacterDataHandler function : %s\n"
                           "  is not a scilab function.\n",
                           fname,fname_1[0]);
              /* */
              Sci_Parser.CheckParser[i]=0;
              /* */
              FreeRhsSVar(fname_1);
              /* */
              return(0);
              break;
             }

   case  0 : {
              Scierror(999,"%s:\n"
                           "  CharacterDataHandler function : %s\n"
                           "  is not defined.\n",
                           fname,fname_1[0]);
              /* */
              Sci_Parser.CheckParser[i]=0;
              /* */
              FreeRhsSVar(fname_1);
              /* */
              return(0);
              break;
             }

   default : break;
  }

  /* check userdata */
  if (Sci_Parser.DataName[i]==NULL) {
    /* check number of rhs variable of characterdatahandler function */
    if (mrhs1!=1) {
      Scierror(999,"%s: Rhs(1) :\n"
                   "  Function has invalid number of rhs argument\n"
                   "  (should be 1)\n",
                   fname);
      FreeRhsSVar(fname_1);
      return(0);
    }
  }
  /* userdata doesn't exists */
  else {
    /* check number of rhs variable of characterdatahandler function */
    if (mrhs1!=2) {
      Scierror(999,"%s: Rhs(1) :\n"
                   "  Function has invalid number of rhs argument\n"
                   "  (should be 2)\n",
                   fname);

      FreeRhsSVar(fname_1);
      return(0);
    }
  }

  /* store name of characterdatahandler function in Sci_Parser structure */
  sz_str=strlen(fname_1[0]);
  Sci_Parser.CharDataHndl[i]=MALLOC((sz_str+1)*sizeof(char));
  strcpy(Sci_Parser.CharDataHndl[i],fname_1[0]);

  /* call XML_SetCharacterDataHandler */
  XML_SetCharacterDataHandler(Sci_Parser.p[i],
                              (void *) char_hndl);

  FreeRhsSVar(fname_1);

  return(0);
}

/* Parse scilab string
 *
 * Scilab Calling sequence :
 *   -->XML_Parse(%ptr, tt, done);
 *   or
 *   -->XML_Parse(%ptr, tt);
 *
 * Input : rhs(1) : a scilab pointer object
 *         rhs(2) : a scilab string
 *         rhs(3) : a scilab boolean (optional)
 *
 * Output : nothing
 *
 */
int intxmlparse_c(char *fname,unsigned long fname_len)
{
  static int l1, m1, n1;
  XML_Parser ptr_parser;

  static int m2,n2;
  char **str;

  static int l3, m3, n3;

  int i,j;
  int len;
  int isFinal=0;

  /* */
  CheckRhs(2,3);

  /*****************************************/
  GetRhsVar(1,"p",&m1,&n1,&l1);
  ptr_parser = (XML_Parser) ((unsigned long int) *stk(l1));

  i=GetIndPtrStruct(ptr_parser);

  if((i==-1)||(i==-2)) {
   Scierror(999,"%s: "
                "Rhs(1) : Parser ptr not valid\n",
            fname);
   return(0);
  }
  /*****************************************/

  /* */
  if(!AllowParse(&i)) return(0);

  /* */
  GetRhsVar(2,"S",&m2,&n2,&str);

  /* calling sequence with 2 parameters */
  if (Rhs==2) {
    /* */
    for (j=0;j<m2*n2;j++) {
      /* */
      len=strlen(str[j]);
      /* */
      isFinal=(j==(m2*n2)-1);
      /* */
      if (! XML_Parse(Sci_Parser.p[i], str[j], len, isFinal)) {
        Scierror(999,"%s: Parse error at line %d:\n%s\n",
                 fname,
                 XML_GetCurrentLineNumber(Sci_Parser.p[i]),
                 XML_ErrorString(XML_GetErrorCode(Sci_Parser.p[i])));
        FreeParserPtr(ptr_parser);
        FreeRhsSVar(str);
        return(0);
      }
    }
  }

  /* calling sequence with 3 parameters */
  else if (Rhs==3) {
    /* */
    GetRhsVar(3,"b",&m3,&n3,&l3);

    /* */
    isFinal=*istk(l3);

    /* */
    for (j=0;j<m2*n2;j++) {
      /* */
      len=strlen(str[j]);

      /* */
      if (! XML_Parse(Sci_Parser.p[i], str[j], len, isFinal)) {
        Scierror(999,"%s: Parse error at line %d:\n%s\n",
                 fname,
                 XML_GetCurrentLineNumber(Sci_Parser.p[i]),
                 XML_ErrorString(XML_GetErrorCode(Sci_Parser.p[i])));
        FreeParserPtr(ptr_parser);
        FreeRhsSVar(str);
        return(0);
      }
    }
  }

  if (isFinal) FreeParserPtr(ptr_parser);
  FreeRhsSVar(str);
  return(0);
}

/* revert flag Conv2Latin in SciParser structure 
 *   to convert unicode char given by expat in Latin char.
 *
 * Scilab Calling sequence :
 *   -->XML_Conv2Latin(%ptr);
 *
 * Input : rhs(1) : a scilab pointer object
 *
 * Output : nothing
 *
 */
int intxmlconv2latin_c(char *fname,unsigned long fname_len)
{
  /*variable to access function parameters*/
  static int l1, m1, n1;

  /*counter variable*/
  int i;

  /*local variable*/
  XML_Parser ptr_parser;

  /* */
  CheckRhs(1,1);

  /* */
  GetRhsVar(1,"p",&m1,&n1,&l1);
  ptr_parser = (XML_Parser) ((unsigned long int) *stk(l1));

  /* */
  i=GetIndPtrStruct(ptr_parser);

  if((i==-1)||(i==-2)) {
    Scierror(999,"%s: "
                 "Rhs(1) : Parser ptr not valid\n",
             fname);
    return(0);
  }

  /* revert  Sci_Parser.Conv2Latin flag */
  Sci_Parser.Conv2Latin[i]=~Sci_Parser.Conv2Latin[i];

  /* */
  return(0);
}
