#include "scicos_block4.h"
#include "../machine.h"
#include "../stack-c.h"
#include <stdio.h>
#include <string.h>

#ifndef NULL
#define NULL    0
#endif

/*YAPASDETROUDANSLESLISTESDANSLESFICHERS*/
/*ONLITPASPTR_I[8-9-10-11]*/
#define codehm \
        ptr_i[6]   = 17; \
        ptr_i[7]   = 3;  \
        ptr_i[8]   = 1;  \
        ptr_i[9]   = ptr_i[8]  + 11; \
        ptr_i[10]  = ptr_i[9]  + 4;  \
        ptr_i[11]  = ptr_i[10] + 2 + nz*nu*nu2; \
        ptr_i[12]  = 10; \
        ptr_i[13]  = 1; \
        ptr_i[14]  = 3; \
        ptr_i[15]  = 0; \
        ptr_i[16]  = 1; \
        ptr_i[17]  = ptr_i[16] + 2; \
        ptr_i[18]  = ptr_i[17] + 4; \
        ptr_i[19]  = ptr_i[18] + 7; \
        i = strlen(str_hmlst[0]);   \
        C2F(cvstr)(&i,&ptr_i[20],str_hmlst[0],(l=0,&l),(unsigned long) i); \
        j = strlen(str_hmlst[1]); \
        C2F(cvstr)(&j,&ptr_i[20+i],str_hmlst[1],(l=0,&l),(unsigned long) j); \
        k = strlen(str_hmlst[2]); \
        C2F(cvstr)(&k,&ptr_i[20+i+j],str_hmlst[2],(l=0,&l),(unsigned long) k); \
        ptr_i[33]  = 8; \
        ptr_i[34]  = 1; \
        ptr_i[35]  = 3; \
        ptr_i[36]  = 4; \
        ptr_i[37]  = nu; \
        ptr_i[38]  = nu2; \
        ptr_i[39]  = nz;

extern int C2F(cvstr) __PARAMS((integer *,integer *,char *,integer *,unsigned long int));
extern int C2F(mputnc)();
extern int C2F(namstr)();
extern void C2F(mopen)();
extern int C2F(cluni0) __PARAMS((char *name, char *nams, integer *ln, long int name_len,
                                long int nams_len));
extern void C2F(mclose) __PARAMS((integer *fd, double *res));
extern void sciprint __PARAMS((char *fmt,...));

static int id[nsiz];
static char fmtd[3]  = {'d','l','\000'};
static char fmti[3]  = {'i','l','\000'};
/* static char fmtl[3]  = {'l','l','\000'}; */
static char fmts[3]  = {'s','l','\000'};
static char fmtc[3]  = {'c','l','\000'};
static char fmtui[3]={'u','i','\000'};
/* static char fmtul[3] = {'u','l','\000'}; */
static char fmtus[3] = {'u','s','\000'};
static char fmtuc[3] = {'u','c','\000'};

static char *str_hmlst[]={"hm","dims","entries"};

#ifdef hppa
#undef FILENAME_MAX
#define FILENAME_MAX 4096
#endif

/* work struct for that block */
typedef struct {
  int cnt;
  int loop;
  void *work;
  void *workt;
} towork_struct ;

void tows_c(scicos_block *block,int flag)
/* Copyright INRIA */
/* Put a typed vector in a scilab file.
 * Independant platform.
 *
 * Author A.Layec - initial rev. 18/09/07
 */
{
  void **_work=GetPtrWorkPtrs(block);
  int *_ipar=GetIparPtrs(block);
 /* for mopen */
 int fd;
 char *status;
 int swap = 1;
 double res;
 int out_n;
 long int lout;
 char filename[FILENAME_MAX];
 /* for name of file */
 char str[100]={0};
 /* generic pointer */
 SCSREAL_COP *u_d,*u_cd,*ptr_d,*sav_d;
 SCSINT8_COP *u_c,*ptr_c,*sav_c;
 SCSUINT8_COP *u_uc, *ptr_uc,*sav_uc;
 SCSINT16_COP *u_s,*ptr_s,*sav_s;
 SCSUINT16_COP *u_us,*ptr_us,*sav_us;
 SCSINT_COP *ptr_i;
 SCSINT32_COP *u_l,*ptr_l,*sav_l;
 SCSUINT32_COP *u_ul,*ptr_ul,*sav_ul;
 double sav_t;
 /* the struct ptr of that block */
 towork_struct *ptr;
 /* */
 int nu,nu2,ut;
 int nz;
 double t,t_old;
 /* local */
 int i,j,k,l;
 int ierr;

 int  ismat=0;

 /* for path of TMPDIR/workspace */
 char env[256];
 char sep[2];
#ifdef _MSC_VER
  sep[0]='\\';
#else
  sep[0]='/';
#endif
  sep[1]='\0';

 /* retrieve param of that block */
 nu  = GetInPortRows(block,1); /* number of rows of inputs*/
 nu2 = GetInPortCols(block,1); /* number of cols of inputs*/
 ut  = GetInType(block,1);     /* input type */
 nz  = _ipar[0];         /* buffer size */

 /* check if u is a matrix */
 if (nu2!=1) {
   ismat=1;
 }

 if (flag==4) { /* init */

   /* begin campaign of allocations */
   if((*(_work)=(towork_struct*) scicos_malloc(sizeof(towork_struct)))==NULL) {
     set_block_error(-16);
     return;
   }

   ptr = *(_work);

   /*
    * t
    */
   if((ptr->workt=(void *) scicos_malloc(6*sizeof(int)+4*sizeof(int)+ \
                                          nz*sizeof(double)))==NULL) {
     set_block_error(-16);
     scicos_free(ptr);
     *(_work) = NULL;
     return;
   }
   ptr_i    = (int*) ptr->workt;
   ptr_i[6] = 1;
   ptr_i[7] = nz;
   ptr_i[8] = 1;
   ptr_i[9] = 0;

   ptr_d = (SCSREAL_COP *) &(ptr_i[10]);
   for (i=0;i<nz;i++) {
     ptr_d[i]=-1;
   }

   /* Scilab variable code name */
   C2F(namstr)(id,(i=29,&i),(j=1,&j),(k=0,&k));

   ptr_i    = (int*) ptr->workt;
   ptr_i[0] = id[0];
   ptr_i[1] = id[1];
   ptr_i[2] = id[2];
   ptr_i[3] = id[3];
   ptr_i[4] = id[4];
   ptr_i[5] = id[5];

   /*
    * x
    */
   switch (ut)
   {
    case SCSREAL_N    :
      if (ismat) {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int) + \
                                             2*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (2+4+7)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (3)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             nz*nu*nu2*sizeof(double)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i      = (int*) ptr->work;
        codehm
        ptr_i[40]  = 1;                     /*head of entries for hm*/
        ptr_i[41]  = nu*nu2*nz;
        ptr_i[42]  = 1;
        ptr_i[43]  = 0;
        ptr_d      = (SCSREAL_COP *) &(ptr_i[44]);

      }
      else {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int)+4*sizeof(int)+ \
                                              nz*nu*sizeof(double)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i      = (int*) ptr->work;
        ptr_i[6]   = 1;
        ptr_i[7]   = nz;
        ptr_i[8]   = nu;
        ptr_i[9]   = 0;
        ptr_d      = (SCSREAL_COP *) &(ptr_i[10]);
      }
      for (i=0;i<nu*nu2*nz;i++) {
        ptr_d[i] = 0.;
      }
      break;

    case SCSCOMPLEX_N :
      if (ismat) {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int) + \
                                             2*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (2+4+7)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (3)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             2*nz*nu*nu2*sizeof(double)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i      = (int*) ptr->work;
        codehm
        ptr_i[40]  = 1;                     /*head of entries for hm*/
        ptr_i[41]  = nu*nu2*nz;
        ptr_i[42]  = 1;
        ptr_i[43]  = 1;
        ptr_d      = (SCSREAL_COP *) &(ptr_i[44]);

      }
      else {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int)+4*sizeof(int)+ \
                                              2*nz*nu*sizeof(double)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i      = (int*) ptr->work;
        ptr_i[6]   = 1;
        ptr_i[7]   = nz;
        ptr_i[8]   = nu;
        ptr_i[9]   = 1;
        ptr_d      = (SCSREAL_COP *) &(ptr_i[10]);
      }
      for (i=0;i<2*nu*nu2*nz;i++) {
        ptr_d[i] = 0.;
      }
      break;

    case SCSINT8_N    :
      if (ismat) {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int) + \
                                             2*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (2+4+7)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (3)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             nz*nu*nu2*sizeof(SCSINT8_COP)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i      = (int*) ptr->work;
        codehm
        ptr_i[40]  = 8;                     /*head of entries for hm*/
        ptr_i[41]  = nu*nu2*nz;
        ptr_i[42]  = 1;
        ptr_i[43]  = 1;
        ptr_c      = (SCSINT8_COP *) &(ptr_i[44]);

      }
      else {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int)+4*sizeof(int)+ \
                                              nz*nu*sizeof(SCSINT8_COP)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i      = (int*) ptr->work;
        ptr_i[6]   = 8;
        ptr_i[7]   = nz;
        ptr_i[8]   = nu;
        ptr_i[9]   = 1;
        ptr_c      = (SCSINT8_COP *) &(ptr_i[10]);
      }
      for (i=0;i<nu*nu2*nz;i++) {
        ptr_c[i] = 0;
      }
      break;

    case SCSINT16_N   :
      if (ismat) {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int) + \
                                             2*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (2+4+7)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (3)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             nz*nu*nu2*sizeof(SCSINT16_COP)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i      = (int*) ptr->work;
        codehm
        ptr_i[40]  = 8;                     /*head of entries for hm*/
        ptr_i[41]  = nu*nu2*nz;
        ptr_i[42]  = 1;
        ptr_i[43]  = 2;
        ptr_s      = (SCSINT16_COP *) &(ptr_i[44]);
      }
      else {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int)+4*sizeof(int)+ \
                                              nz*nu*sizeof(SCSINT16_COP)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i      = (int*) ptr->work;
        ptr_i[6]   = 8;
        ptr_i[7]   = nz;
        ptr_i[8]   = nu;
        ptr_i[9]   = 2;
        ptr_s      = (SCSINT16_COP *) &(ptr_i[10]);
      }
      for (i=0;i<nu*nu2*nz;i++) {
        ptr_s[i] = 0;
      }
      break;

    case SCSINT32_N   :
      if (ismat) {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int) + \
                                             2*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (2+4+7)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (3)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             nz*nu*nu2*sizeof(SCSINT32_COP)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i      = (int*) ptr->work;
        codehm
        ptr_i[40]  = 8;                     /*head of entries for hm*/
        ptr_i[41]  = nu*nu2*nz;
        ptr_i[42]  = 1;
        ptr_i[43]  = 4;
        ptr_l      = (SCSINT32_COP *) &(ptr_i[44]);
      }
      else {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int)+4*sizeof(int)+ \
                                              nz*nu*sizeof(SCSINT32_COP)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i      = (int*) ptr->work;
        ptr_i[6]   = 8;
        ptr_i[7]   = nz;
        ptr_i[8]   = nu;
        ptr_i[9]   = 4;
        ptr_l      = (SCSINT32_COP *) &(ptr_i[10]);
      }
      for (i=0;i<nu*nu2*nz;i++) {
        ptr_l[i] = 0;
      }
      break;

    case SCSUINT8_N   :
      if (ismat) {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int) + \
                                             2*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (2+4+7)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (3)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             nz*nu*nu2*sizeof(SCSUINT8_COP)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i      = (int*) ptr->work;
        codehm
        ptr_i[40]  = 8;                     /*head of entries for hm*/
        ptr_i[41]  = nu*nu2*nz;
        ptr_i[42]  = 1;
        ptr_i[43]  = 11;
        ptr_uc     = (SCSUINT8_COP *) &(ptr_i[44]);
      }
      else {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int)+4*sizeof(int)+ \
                                              nz*nu*sizeof(SCSUINT8_COP)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i       = (int*) ptr->work;
        ptr_i[6]    = 8;
        ptr_i[7]    = nz;
        ptr_i[8]    = nu;
        ptr_i[9]    = 11;
        ptr_uc      = (SCSUINT8_COP *) &(ptr_i[10]);
      }
      for (i=0;i<nu*nu2*nz;i++) {
        ptr_uc[i] = 0;
      }
      break;

    case SCSUINT16_N  :
      if (ismat) {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int) + \
                                             2*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (2+4+7)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (3)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             nz*nu*nu2*sizeof(SCSUINT16_COP)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i      = (int*) ptr->work;
        codehm
        ptr_i[40]  = 8;                     /*head of entries for hm*/
        ptr_i[41]  = nu*nu2*nz;
        ptr_i[42]  = 1;
        ptr_i[43]  = 12;
        ptr_us     = (SCSUINT16_COP *) &(ptr_i[44]);
      }
      else {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int)+4*sizeof(int)+ \
                                              nz*nu*sizeof(SCSUINT16_COP)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i = (int*) ptr->work;
        ptr_i[6]    = 8;
        ptr_i[7]    = nz;
        ptr_i[8]    = nu;
        ptr_i[9]    = 12;
        ptr_us      = (SCSUINT16_COP *) &(ptr_i[10]);
      }
      for (i=0;i<nu*nu2*nz;i++) {
        ptr_us[i] = 0;
      }
      break;

    case SCSUINT32_N  :
      if (ismat) {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int) + \
                                             2*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (2+4+7)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             (3)*sizeof(int) + \
                                             4*sizeof(int) + \
                                             nz*nu*nu2*sizeof(SCSUINT32_COP)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i      = (int*) ptr->work;
        codehm
        ptr_i[40]  = 8;                     /*head of entries for hm*/
        ptr_i[41]  = nu*nu2*nz;
        ptr_i[42]  = 1;
        ptr_i[43]  = 14;
        ptr_ul     = (SCSUINT32_COP *) &(ptr_i[44]);
      }
      else {
        if((ptr->work=(void *) scicos_malloc(6*sizeof(int)+4*sizeof(int)+ \
                                              nz*nu*sizeof(SCSUINT32_COP)))==NULL) {
          set_block_error(-16);
          scicos_free(ptr->workt);
          scicos_free(ptr);
          *(_work) = NULL;
          return;
        }
        ptr_i = (int*) ptr->work;
        ptr_i[6]    = 8;
        ptr_i[7]    = nz;
        ptr_i[8]    = nu;
        ptr_i[9]    = 14;
        ptr_ul      = (SCSUINT32_COP *) &(ptr_i[10]);
      }
      for (i=0;i<nu*nu2*nz;i++) {
        ptr_ul[i] = 0;
      }
      break;

    default  : /* Add a message here */
               break;
   }

   /* Scilab variable code name */
   C2F(namstr)(id,(i=33,&i),(j=1,&j),(k=0,&k));

   ptr_i    = (int*) ptr->work;
   ptr_i[0] = id[0];
   ptr_i[1] = id[1];
   ptr_i[2] = id[2];
   ptr_i[3] = id[3];
   ptr_i[4] = id[4];
   ptr_i[5] = id[5];

   /*
    * cnt
    */
   ptr->cnt = 0;

   /*
    * loop
    */
   ptr->loop = 0;
 }

 else if (flag==5) { /* finish */

   ptr = *(_work);

   if (ptr!=NULL) {
     /* Put file name in str */
     C2F(cvstr)(&(_ipar[1]),&(_ipar[2]),str,(j=1,&j),	\
                 (unsigned long)strlen(str));
     str[_ipar[1]] = '\0';

     /* retrieve path of TMPDIR/workspace */
     strcpy(env,getenv("TMPDIR"));
     strcat(env,sep);
     strcat(env,"Workspace");
     strcat(env,sep);
     strcat(env,str);

     /* open tmp file */
     status = "wb"; /* "w" : write */
                    /* "b" : binary (required for Windows) */
     lout   = FILENAME_MAX;
     C2F(cluni0)(env, filename, &out_n,1,lout);
     C2F(mopen)(&fd,env,status,&swap,&res,&ierr);
     if (ierr != 0) {
       Coserror("Error when opening file '%s'.\n",str);
       scicos_free(ptr->workt);
       scicos_free(ptr);
       *(_work) = NULL;
       /*set_block_error(-3);*/
       return;
     }

     /* check loop */

     /* we don't are at the end of the buffer :
      * only first records will be saved
      */
     if ((ptr->cnt==0)&&(ptr->loop==0)) { /* nothing have been stored */
       ptr_i = (int*) ptr->workt;
       ptr_i[6] = 1;
       ptr_i[7] = 0;
       ptr_i[8] = 0;
       ptr_i[9] = 0;
       ptr_i = (int*) ptr->work;
       ptr_i[6] = 1;
       ptr_i[7] = 0;
       ptr_i[8] = 0;
       ptr_i[9] = 0;
     }
     if ((ptr->cnt!=0)&&(ptr->cnt!=nz)&&(ptr->loop==0)) { /* something stored */
                                                          /* but we don't are at the end */
       ptr_i    = (int*) ptr->workt;
       ptr_i[7] = ptr->cnt;
       ptr_i    = (int*) ptr->work;
       /* hmat */
       if (ismat) {
         ptr_i[39] = ptr->cnt;
         ptr_i[41] = ptr->cnt*nu*nu2;
       }
       /* vector or matrix */
       else {
         /* vector case */
         /* adjust only done for complex numbers */
         if (ptr_i[8] == 1) {
           switch (ut) {
             case SCSCOMPLEX_N :
                for(j=0;j<ptr->cnt;j++) {
                  *((double *)(&ptr_i[10]) + (j+ptr->cnt)) = \
                      *((double *)(&ptr_i[10]) + (j+nz*nu));
                }
               break;
           }
         }
         /* matrix case */
         else {
           /* */
           k=nz-ptr->cnt;
           /* */
           switch (ut) {
             case SCSREAL_N    :
                for(i=0;i<ptr_i[8]-1;i++) {
                  for(j=0;j<ptr->cnt;j++) {
                    *((double *)(&ptr_i[10]) + (((i+1)*nz)+j-(i+1)*k)) = \
                         *((double *)(&ptr_i[10]) + (((i+1)*nz)+j));
                  }
                }
               break;

             case SCSCOMPLEX_N :
                for(i=0;i<ptr_i[8]-1;i++) {
                  for(j=0;j<ptr->cnt;j++) {
                    *((double *)(&ptr_i[10]) + (((i+1)*nz)+j-(i+1)*k)) = \
                         *((double *)(&ptr_i[10]) + (((i+1)*nz)+j));
                    *((double *)(&ptr_i[10]) + (((i+1)*nz)+j-(i+1)*k)+nz*nu) = \
                         *((double *)(&ptr_i[10]) + (((i+1)*nz)+j)+nz*nu);
                  }
                }
               break;

             case SCSINT8_N :
                for(i=0;i<ptr_i[8]-1;i++) {
                  for(j=0;j<ptr->cnt;j++) {
                    *((SCSINT8_COP *)(&ptr_i[10]) + (((i+1)*nz)+j-(i+1)*k)) = \
                         *((SCSINT8_COP *)(&ptr_i[10]) + (((i+1)*nz)+j));
                  }
                }
               break;

             case SCSINT16_N :
                for(i=0;i<ptr_i[8]-1;i++) {
                  for(j=0;j<ptr->cnt;j++) {
                    *((SCSINT16_COP *)(&ptr_i[10]) + (((i+1)*nz)+j-(i+1)*k)) = \
                         *((SCSINT16_COP *)(&ptr_i[10]) + (((i+1)*nz)+j));
                  }
                }
               break;

             case SCSINT32_N :
                for(i=0;i<ptr_i[8]-1;i++) {
                  for(j=0;j<ptr->cnt;j++) {
                    *((SCSINT32_COP *)(&ptr_i[10]) + (((i+1)*nz)+j-(i+1)*k)) = \
                         *((SCSINT32_COP *)(&ptr_i[10]) + (((i+1)*nz)+j));
                  }
                }
               break;

             case SCSUINT8_N :
                for(i=0;i<ptr_i[8]-1;i++) {
                  for(j=0;j<ptr->cnt;j++) {
                    *((SCSUINT8_COP *)(&ptr_i[10]) + (((i+1)*nz)+j-(i+1)*k)) = \
                         *((SCSUINT8_COP *)(&ptr_i[10]) + (((i+1)*nz)+j));
                  }
                }
               break;

             case SCSUINT16_N :
                for(i=0;i<ptr_i[8]-1;i++) {
                  for(j=0;j<ptr->cnt;j++) {
                    *((SCSUINT16_COP *)(&ptr_i[10]) + (((i+1)*nz)+j-(i+1)*k)) = \
                         *((SCSUINT16_COP *)(&ptr_i[10]) + (((i+1)*nz)+j));
                  }
                }
               break;

             case SCSUINT32_N :
                for(i=0;i<ptr_i[8]-1;i++) {
                  for(j=0;j<ptr->cnt;j++) {
                    *((SCSUINT32_COP *)(&ptr_i[10]) + (((i+1)*nz)+j-(i+1)*k)) = \
                         *((SCSUINT32_COP *)(&ptr_i[10]) + (((i+1)*nz)+j));
                  }
                }
               break;

           }
         }
         ptr_i[7] = ptr->cnt;
       }
     }
     /* sort data */
     else if ((ptr->cnt!=0)&&(ptr->cnt!=nz)&&(ptr->loop!=0)) {
       /* shift time data */
       for(i=0;i<(nz-ptr->cnt);i++) {
         ptr_i = (int*) ptr->workt;
         sav_t = *((double *)(&ptr_i[10])+(nz-1));
         for (j=(nz-1);j>=1;j--) {
           *((double *)(&ptr_i[10])+j)=*((double *)(&ptr_i[10])+(j-1));
         }
         *((double *)(&ptr_i[10]))=sav_t;
       }
       /* shift x data */
       switch (ut) {
        case SCSREAL_N    :
          if((sav_d=(double *) scicos_malloc(nu*nu2*sizeof(double)))==NULL) {
            set_block_error(-16);
            scicos_free(ptr->workt);
            scicos_free(ptr);
            *(_work) = NULL;
            return;
          }
          ptr_i = (int*) ptr->work;
          if (ismat) {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu*nu2;k++) {
                sav_d[k] = *((double *)(&ptr_i[44])+k+(nz-1)*nu*nu2);
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu*nu2;k++) {
                  *((double *)(&ptr_i[44])+k+j*(nu*nu2))=*((double *)(&ptr_i[44])+k+(j-1)*(nu*nu2));
                }
              }
              for (k=0;k<nu*nu2;k++) {
                *((double *)(&ptr_i[44])+k)  = sav_d[k];
              }
            }
          }
          else {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu;k++) {
                sav_d[k] = *((double *)(&ptr_i[10])+k*nz+(nz-1));
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu;k++) {
                  *((double *)(&ptr_i[10])+k*nz+j)=*((double *)(&ptr_i[10])+k*nz+j-1);
                }
              }
              for (k=0;k<nu;k++) {
                *((double *)(&ptr_i[10])+k*nz)  = sav_d[k];
              }
            }
          }
          scicos_free(sav_d);
          break;
        case SCSCOMPLEX_N :
          if((sav_d=(double *) scicos_malloc(2*nu*nu2*sizeof(double)))==NULL) {
            set_block_error(-16);
            scicos_free(ptr->workt);
            scicos_free(ptr);
            *(_work) = NULL;
            return;
          }
          ptr_i = (int *) ptr->work;
          if (ismat) {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu*nu2;k++) {
                sav_d[k]        = *((double *)(&ptr_i[44])+k+(nz-1)*nu*nu2);
                sav_d[k+nu*nu2] = *((double *)(&ptr_i[44])+k+(nz-1)*nu*nu2+nz*nu*nu2);
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu*nu2;k++) {
                  *((double *)(&ptr_i[44])+k+j*(nu*nu2))= \
                       *((double *)(&ptr_i[44])+k+(j-1)*(nu*nu2));
                  *((double *)(&ptr_i[44])+k+j*(nu*nu2)+nz*nu*nu2)= \
                       *((double *)(&ptr_i[44])+k+(j-1)*(nu*nu2)+nz*nu*nu2);
                }
              }
              for (k=0;k<nu*nu2;k++) {
                *((double *)(&ptr_i[44])+k)           = sav_d[k];
                *((double *)(&ptr_i[44])+k+nz*nu*nu2) = sav_d[k+nu*nu2];
              }
            }
          }
          else {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu;k++) {
                sav_d[k]    = *((double *)(&ptr_i[10])+k*nz+(nz-1));
                sav_d[k+nu] = *((double *)(&ptr_i[10])+k*nz+(nz-1)+nz*nu);
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu;k++) {
                  *((double *)(&ptr_i[10])+k*nz+j)= \
                       *((double *)(&ptr_i[10])+k*nz+j-1);
                  *((double *)(&ptr_i[10])+k*nz+j+nz*nu)= \
                       *((double *)(&ptr_i[10])+k*nz+j-1+nz*nu);
                }
              }
              for (k=0;k<nu;k++) {
                *((double *)(&ptr_i[10])+k*nz)        = sav_d[k];
                *((double *)(&ptr_i[10])+k*nz+nz*nu)  = sav_d[k+nu];
              }
            }
          }
          scicos_free(sav_d);
          break;
        case SCSINT8_N    :
          if((sav_c=(SCSINT8_COP *) scicos_malloc(nu*nu2*sizeof(SCSINT8_COP)))==NULL) {
            set_block_error(-16);
            scicos_free(ptr->workt);
            scicos_free(ptr);
            *(_work) = NULL;
            return;
          }
          ptr_i = (int *) ptr->work;
          if (ismat) {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu*nu2;k++) {
                sav_c[k] = *((SCSINT8_COP *)(&ptr_i[44])+k+(nz-1)*nu*nu2);
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu*nu2;k++) {
                  *((SCSINT8_COP *)(&ptr_i[44])+k+j*(nu*nu2))=*((SCSINT8_COP *)(&ptr_i[44])+k+(j-1)*(nu*nu2));
                }
              }
              for (k=0;k<nu*nu2;k++) {
                *((SCSINT8_COP *)(&ptr_i[44])+k)  = sav_c[k];
              }
            }
          }
          else {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu;k++) {
                sav_c[k] = *((SCSINT8_COP *)(&ptr_i[10])+k*nz+(nz-1));
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu;k++) {
                  *((SCSINT8_COP *)(&ptr_i[10])+k*nz+j)=*((SCSINT8_COP *)(&ptr_i[10])+k*nz+j-1);
                }
              }
              for (k=0;k<nu;k++) {
                *((SCSINT8_COP *)(&ptr_i[10])+k*nz)  = sav_c[k];
              }
            }
          }
          scicos_free(sav_c);
          break;
        case SCSINT16_N   :
          if((sav_s=(SCSINT16_COP *) scicos_malloc(nu*nu2*sizeof(SCSINT16_COP)))==NULL) {
            set_block_error(-16);
            scicos_free(ptr->workt);
            scicos_free(ptr);
            *(_work) = NULL;
            return;
          }
          ptr_i = (int *) ptr->work;
          if (ismat) {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu*nu2;k++) {
                sav_s[k] = *((SCSINT16_COP *)(&ptr_i[44])+k+(nz-1)*nu*nu2);
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu*nu2;k++) {
                  *((SCSINT16_COP *)(&ptr_i[44])+k+j*(nu*nu2))=*((SCSINT16_COP *)(&ptr_i[44])+k+(j-1)*(nu*nu2));
                }
              }
              for (k=0;k<nu*nu2;k++) {
                *((SCSINT16_COP *)(&ptr_i[44])+k)  = sav_s[k];
              }
            }
          }
          else {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu;k++) {
                sav_s[k] = *((SCSINT16_COP *)(&ptr_i[10])+k*nz+(nz-1));
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu;k++) {
                  *((SCSINT16_COP *)(&ptr_i[10])+k*nz+j)=*((SCSINT16_COP *)(&ptr_i[10])+k*nz+j-1);
                }
              }
              for (k=0;k<nu;k++) {
                *((SCSINT16_COP *)(&ptr_i[10])+k*nz)  = sav_s[k];
              }
            }
          }
          scicos_free(sav_s);
          break;
        case SCSINT32_N   :
          if((sav_l=(SCSINT32_COP *) scicos_malloc(nu*nu2*sizeof(SCSINT32_COP)))==NULL) {
            set_block_error(-16);
            scicos_free(ptr->workt);
            scicos_free(ptr);
            *(_work) = NULL;
            return;
          }
          ptr_i = (int *) ptr->work;
          if (ismat) {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu*nu2;k++) {
                sav_l[k] = *((SCSINT32_COP *)(&ptr_i[44])+k+(nz-1)*nu*nu2);
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu*nu2;k++) {
                  *((SCSINT32_COP *)(&ptr_i[44])+k+j*(nu*nu2))=*((SCSINT32_COP *)(&ptr_i[44])+k+(j-1)*(nu*nu2));
                }
              }
              for (k=0;k<nu*nu2;k++) {
                *((SCSINT32_COP *)(&ptr_i[44])+k)  = sav_l[k];
              }
            }
          }
          else {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu;k++) {
                sav_l[k] = *((SCSINT32_COP *)(&ptr_i[10])+k*nz+(nz-1));
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu;k++) {
                  *((SCSINT32_COP *)(&ptr_i[10])+k*nz+j)=*((SCSINT32_COP *)(&ptr_i[10])+k*nz+j-1);
                }
              }
              for (k=0;k<nu;k++) {
                *((SCSINT32_COP *)(&ptr_i[10])+k*nz)  = sav_l[k];
              }
            }
          }
          scicos_free(sav_l);
          break;
        case SCSUINT8_N   :
          if((sav_uc=(SCSUINT8_COP *) scicos_malloc(nu*nu2*sizeof(SCSUINT8_COP)))==NULL) {
            set_block_error(-16);
            scicos_free(ptr->workt);
            scicos_free(ptr);
            *(_work) = NULL;
            return;
          }
          ptr_i = (int *) ptr->work;
          if (ismat) {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu*nu2;k++) {
                sav_uc[k] = *((SCSUINT8_COP *)(&ptr_i[44])+k+(nz-1)*nu*nu2);
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu*nu2;k++) {
                  *((SCSUINT8_COP *)(&ptr_i[44])+k+j*(nu*nu2))=*((SCSUINT8_COP *)(&ptr_i[44])+k+(j-1)*(nu*nu2));
                }
              }
              for (k=0;k<nu*nu2;k++) {
                *((SCSUINT8_COP *)(&ptr_i[44])+k)  = sav_uc[k];
              }
            }
          }
          else {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu;k++) {
                sav_uc[k] = *((SCSUINT8_COP *)(&ptr_i[10])+k*nz+(nz-1));
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu;k++) {
                  *((SCSUINT8_COP *)(&ptr_i[10])+k*nz+j)=*((SCSUINT8_COP *)(&ptr_i[10])+k*nz+j-1);
                }
              }
              for (k=0;k<nu;k++) {
                *((SCSUINT8_COP *)(&ptr_i[10])+k*nz)  = sav_uc[k];
              }
            }
          }
          scicos_free(sav_uc);
          break;
        case SCSUINT16_N  :
          if((sav_us=(SCSUINT16_COP *) scicos_malloc(nu*nu2*sizeof(SCSUINT16_COP)))==NULL) {
            set_block_error(-16);
            scicos_free(ptr->workt);
            scicos_free(ptr);
            *(_work) = NULL;
            return;
          }
          ptr_i = (int *) ptr->work;
          if (ismat) {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu*nu2;k++) {
                sav_us[k] = *((SCSUINT16_COP *)(&ptr_i[44])+k+(nz-1)*nu*nu2);
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu*nu2;k++) {
                  *((SCSUINT16_COP *)(&ptr_i[44])+k+j*(nu*nu2))=*((SCSUINT16_COP *)(&ptr_i[44])+k+(j-1)*(nu*nu2));
                }
              }
              for (k=0;k<nu*nu2;k++) {
                *((SCSUINT16_COP *)(&ptr_i[44])+k)  = sav_us[k];
              }
            }
          }
          else {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu;k++) {
                sav_us[k] = *((SCSUINT16_COP *)(&ptr_i[10])+k*nz+(nz-1));
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu;k++) {
                  *((SCSUINT16_COP *)(&ptr_i[10])+k*nz+j)=*((SCSUINT16_COP *)(&ptr_i[10])+k*nz+j-1);
                }
              }
              for (k=0;k<nu;k++) {
                *((SCSUINT16_COP *)(&ptr_i[10])+k*nz)  = sav_us[k];
              }
            }
          }
          scicos_free(sav_us);
          break;
        case SCSUINT32_N  :
          if((sav_ul=(SCSUINT32_COP *) scicos_malloc(nu*nu2*sizeof(SCSUINT32_COP)))==NULL) {
            set_block_error(-16);
            scicos_free(ptr->workt);
            scicos_free(ptr);
            *(_work) = NULL;
            return;
          }
          ptr_i = (int *) ptr->work;
          if (ismat) {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu*nu2;k++) {
                sav_ul[k] = *((SCSUINT32_COP *)(&ptr_i[44])+k+(nz-1)*nu*nu2);
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu*nu2;k++) {
                  *((SCSUINT32_COP *)(&ptr_i[44])+k+j*(nu*nu2))=*((SCSUINT32_COP *)(&ptr_i[44])+k+(j-1)*(nu*nu2));
                }
              }
              for (k=0;k<nu*nu2;k++) {
                *((SCSUINT32_COP *)(&ptr_i[44])+k)  = sav_ul[k];
              }
            }
          }
          else {
            for(i=0;i<(nz-ptr->cnt);i++) {
              for (k=0;k<nu;k++) {
                sav_ul[k] = *((SCSUINT32_COP *)(&ptr_i[10])+k*nz+(nz-1));
              }
              for (j=(nz-1);j>=1;j--) {
                for (k=0;k<nu;k++) {
                  *((SCSUINT32_COP *)(&ptr_i[10])+k*nz+j)=*((SCSUINT32_COP *)(&ptr_i[10])+k*nz+j-1);
                }
              }
              for (k=0;k<nu;k++) {
                *((SCSUINT32_COP *)(&ptr_i[10])+k*nz)  = sav_ul[k];
              }
            }
          }
          scicos_free(sav_ul);
          break;
        default  : /* Add a message here */
                   break;
       }
     }

     /* write x */
     ptr_i = (int*) ptr->work;
     C2F(mputnc)(&fd, &ptr_i[0], (j=nsiz,&j), fmti, &ierr); /* write sci id */
     if (ierr != 0) {
       Coserror("Write error in file '%s'.\n",str);
       scicos_free(ptr->workt);
       scicos_free(ptr);
       *(_work) = NULL;
       /*set_block_error(-3);*/
       return;
     }
     C2F(mputnc)(&fd, &ptr_i[6], (j=1,&j), fmti, &ierr);    /* write sci type */
     if (ierr != 0) {
       Coserror("Write error in file '%s'.\n",str);
       scicos_free(ptr->workt);
       scicos_free(ptr);
       *(_work) = NULL;
       /*set_block_error(-3);*/
       return;
     }
     if ((ptr->cnt==0)&&(ptr->loop==0)) {
       C2F(mputnc)(&fd, &ptr_i[7], (j=3,&j), fmti, &ierr);    /* write sci header */
     }
     else {
       if (ismat) {
         C2F(mputnc)(&fd, &ptr_i[7], (j=37,&j), fmti, &ierr);    /* write sci header */
       }
       else {
         C2F(mputnc)(&fd, &ptr_i[7], (j=3,&j), fmti, &ierr);    /* write sci header */
       }
     }
     if (ierr != 0) {
       Coserror("Write error in file '%s'.\n",str);
       scicos_free(ptr->workt);
       scicos_free(ptr);
       *(_work) = NULL;
       /*set_block_error(-3);*/
       return;
     }
     if ((ptr->cnt!=0)||(ptr->loop!=0)) {
       /* write data */
       switch (ut) {
         case SCSREAL_N    :
           if (ismat) {
             C2F(mputnc)(&fd, &ptr_i[44], (j=ptr_i[37]*ptr_i[38]*ptr_i[39],&j), fmtd, &ierr);
           }
           else {
             C2F(mputnc)(&fd, &ptr_i[10], (j=ptr_i[7]*ptr_i[8],&j), fmtd, &ierr);
           }
           break;
         case SCSCOMPLEX_N :
           if (ismat) {
             C2F(mputnc)(&fd, &ptr_i[44], (j=2*ptr_i[37]*ptr_i[38]*ptr_i[39],&j), fmtd, &ierr);
           }
           else {
             C2F(mputnc)(&fd, &ptr_i[10], (j=2*ptr_i[7]*ptr_i[8],&j), fmtd, &ierr);
           }
           break;
         case SCSINT8_N    :
           if (ismat) {
             C2F(mputnc)(&fd, &ptr_i[44], (j=ptr_i[37]*ptr_i[38]*ptr_i[39],&j), fmtc, &ierr);
           }
           else {
             C2F(mputnc)(&fd, &ptr_i[10], (j=ptr_i[7]*ptr_i[8],&j), fmtc, &ierr);
           }
           break;
         case SCSINT16_N   :
           if (ismat) {
             C2F(mputnc)(&fd, &ptr_i[44], (j=ptr_i[37]*ptr_i[38]*ptr_i[39],&j), fmts, &ierr);
           }
           else {
             C2F(mputnc)(&fd, &ptr_i[10], (j=ptr_i[7]*ptr_i[8],&j), fmts, &ierr);
           }
           break;
         case SCSINT32_N   :
           if (ismat) {
             C2F(mputnc)(&fd, &ptr_i[44], (j=ptr_i[37]*ptr_i[38]*ptr_i[39],&j), fmti, &ierr);
           }
           else {
             C2F(mputnc)(&fd, &ptr_i[10], (j=ptr_i[7]*ptr_i[8],&j), fmti, &ierr);
           }
           break;
         case SCSUINT8_N   :
           if (ismat) {
             C2F(mputnc)(&fd, &ptr_i[44], (j=ptr_i[37]*ptr_i[38]*ptr_i[39],&j), fmtuc, &ierr);
           }
           else {
             C2F(mputnc)(&fd, &ptr_i[10], (j=ptr_i[7]*ptr_i[8],&j), fmtuc, &ierr);
           }
           break;
         case SCSUINT16_N  :
           if (ismat) {
             C2F(mputnc)(&fd, &ptr_i[44], (j=ptr_i[37]*ptr_i[38]*ptr_i[39],&j), fmtus, &ierr);
           }
           else {
             C2F(mputnc)(&fd, &ptr_i[10], (j=ptr_i[7]*ptr_i[8],&j), fmtus, &ierr);
           }
           break;
         case SCSUINT32_N  :
           if (ismat) {
             C2F(mputnc)(&fd, &ptr_i[44], (j=ptr_i[37]*ptr_i[38]*ptr_i[39],&j), fmtui, &ierr);
           }
           else {
             C2F(mputnc)(&fd, &ptr_i[10], (j=ptr_i[7]*ptr_i[8],&j), fmtui, &ierr);
           }
           break;
         default  : /* Add a message here */
                   break;
       }
       if (ierr != 0) {
         Coserror("Write error in file '%s'.\n",str);
         scicos_free(ptr->workt);
         scicos_free(ptr);
         *(_work) = NULL;
         /*set_block_error(-3);*/
         return;
       }
     }

     /* write t */
     ptr_i = (int*) ptr->workt;
     C2F(mputnc)(&fd, &ptr_i[0], (j=nsiz,&j), fmti, &ierr);
     if (ierr != 0) {
       Coserror("Write error in file '%s'.\n",str);
       scicos_free(ptr->workt);
       scicos_free(ptr);
       *(_work) = NULL;
       /*set_block_error(-3);*/
       return;
     }
     C2F(mputnc)(&fd, &ptr_i[6], (j=1,&j), fmti, &ierr);
     if (ierr != 0) {
       Coserror("Write error in file '%s'.\n",str);
       scicos_free(ptr->workt);
       scicos_free(ptr);
       *(_work) = NULL;
       /*set_block_error(-3);*/
       return;
     }
     C2F(mputnc)(&fd, &ptr_i[7], (j=3,&j), fmti, &ierr);
     if (ierr != 0) {
       Coserror("Write error in file '%s'.\n",str);
       scicos_free(ptr->workt);
       scicos_free(ptr);
       *(_work) = NULL;
       /*set_block_error(-3);*/
       return;
     }
     if ((ptr->cnt!=0)||(ptr->loop!=0)) {
       C2F(mputnc)(&fd, &ptr_i[10], (j=ptr_i[7],&j), fmtd, &ierr);
       if (ierr != 0) {
         Coserror("Write error in file '%s'.\n",str);
         scicos_free(ptr->workt);
         scicos_free(ptr);
         *(_work) = NULL;
         /*set_block_error(-3);*/
         return;
       }
     }

     /* close tmp file */
     C2F(mclose)(&fd,&res);

     /* free */
     scicos_free(ptr->work);
     scicos_free(ptr->workt);
     scicos_free(ptr);
   }

 }

 else if ((flag==2)||(flag==0)) { /* update state */

   ptr = *(_work);

   ptr_i = (int*) ptr->work;

   /* check data dimension */
   if (ismat) {
     if ((nz!=ptr_i[39]) || (nu!=ptr_i[37]) || (nu2!=ptr_i[38])) {
       Coserror("Size of buffer or input size have changed!\n");
       /*set_block_error(-1);*/
       return;
     }
   }
   else {
     if ((nz!=ptr_i[7]) || (nu!=ptr_i[8])) {
       Coserror("Size of buffer or input size have changed!\n");
       /*set_block_error(-1);*/
       return;
     }
   }

   /*
    * test on time
    */

   ptr_i = (int*) ptr->workt;
   ptr_d = (SCSREAL_COP *) &(ptr_i[10]);

   /* get current time */
   t     = GetScicosTime(block);

   /* get old time */
   if (ptr->cnt==0) {
     t_old = ptr_d[nz-1];
   }
   else {
     t_old = ptr_d[ptr->cnt-1];
   }

   /* get current index of cnt */
   while (t_old>=t) { /*decrease*/
     if (ptr->cnt == 0) {
       ptr->cnt = nz-1;
     }
     else {
       ptr->cnt = ptr->cnt - 1;
     }

     /* get old time */
     if (ptr->cnt==0) {
       t_old = ptr_d[nz-1];
     }
     else {
       t_old = ptr_d[ptr->cnt-1];
     }
   }
   /*fprintf(stderr,"flag=%d, ptr->cnt=%d, t=%20.18f, t_old=%20.18f, t_old>=t=%d\n",flag,ptr->cnt,t,t_old,t_old>=t);*/

   /*
    *store
    */

   ptr_i = (int*) ptr->work;

   /* x */
   switch (ut)
   {
    case SCSREAL_N    :
      u_d   = GetRealInPortPtrs(block,1);
      if (ismat) {
        ptr_d = (SCSREAL_COP *) &(ptr_i[44]);
        for (i=0;i<nu*nu2;i++) {
          ptr_d[ptr->cnt*(nu*nu2)+i] = u_d[i];
        }
      }
      else {
        ptr_d = (SCSREAL_COP *) &(ptr_i[10]);
        for (i=0;i<nu*nu2;i++) {
          ptr_d[ptr->cnt+i*nz] = u_d[i];
        }
      }
      break;

    case SCSCOMPLEX_N :
      u_d  = GetRealInPortPtrs(block,1);
      u_cd = GetImagInPortPtrs(block,1);
      if (ismat) {
        ptr_d = (SCSREAL_COP *) &(ptr_i[44]);
        for (i=0;i<nu*nu2;i++) {
          ptr_d[ptr->cnt*(nu*nu2)+i] = u_d[i];
          ptr_d[nz*nu*nu2+ptr->cnt*(nu*nu2)+i] = u_cd[i];
        }
      }
      else {
        ptr_d = (SCSREAL_COP *) &(ptr_i[10]);
        for (i=0;i<nu;i++) {
          ptr_d[ptr->cnt+i*nz]       = u_d[i];
          ptr_d[nz*nu+ptr->cnt+i*nz] = u_cd[i];
        }
      }
      break;

    case SCSINT8_N    :
      u_c   = Getint8InPortPtrs(block,1);
      if (ismat) {
        ptr_c = (SCSINT8_COP *) &(ptr_i[44]);
        for (i=0;i<nu*nu2;i++) {
          ptr_c[ptr->cnt*(nu*nu2)+i] = u_c[i];
        }
      }
      else {
        ptr_c = (SCSINT8_COP *) &(ptr_i[10]);
        for (i=0;i<nu;i++) {
          ptr_c[ptr->cnt+i*nz] = u_c[i];
        }
      }
      break;

    case SCSINT16_N   :
      u_s   = Getint16InPortPtrs(block,1);
      if (ismat) {
        ptr_s = (SCSINT16_COP *) &(ptr_i[44]);
        for (i=0;i<nu*nu2;i++) {
          ptr_s[ptr->cnt*(nu*nu2)+i] = u_s[i];
        }
      }
      else {
        ptr_s = (SCSINT16_COP *) &(ptr_i[10]);
        for (i=0;i<nu;i++) {
          ptr_s[ptr->cnt*nu+i*nz] = u_s[i];
        }
      }
      break;

    case SCSINT32_N   :
      u_l   = Getint32InPortPtrs(block,1);
      if (ismat) {
        ptr_l = (SCSINT32_COP *) &(ptr_i[44]);
        for (i=0;i<nu*nu2;i++) {
          ptr_l[ptr->cnt*(nu*nu2)+i] = u_l[i];
        }
      }
      else {
        ptr_l = (SCSINT32_COP *) &(ptr_i[10]);
        for (i=0;i<nu;i++) {
          ptr_l[ptr->cnt+i*nz] = u_l[i];
        }
      }
      break;

    case SCSUINT8_N   :
      u_uc   = Getuint8InPortPtrs(block,1);
      if (ismat) {
        ptr_uc = (SCSUINT8_COP *) &(ptr_i[44]);
        for (i=0;i<nu*nu2;i++) {
          ptr_uc[ptr->cnt*(nu*nu2)+i] = u_uc[i];
        }
      }
      else {
        ptr_uc = (SCSUINT8_COP *) &(ptr_i[10]);
        for (i=0;i<nu;i++) {
          ptr_uc[ptr->cnt+i*nz] = u_uc[i];
        }
      }
      break;

    case SCSUINT16_N  :
      u_us   = Getuint16InPortPtrs(block,1);
      if (ismat) {
        ptr_us = (SCSUINT16_COP *) &(ptr_i[44]);
        for (i=0;i<nu*nu2;i++) {
          ptr_us[ptr->cnt*(nu*nu2)+i] = u_us[i];
        }
      }
      else {
        ptr_us = (SCSUINT16_COP *) &(ptr_i[10]);
        for (i=0;i<nu;i++) {
          ptr_us[ptr->cnt+i*nz] = u_us[i];
        }
      }
      break;

    case SCSUINT32_N  :
      u_ul = Getuint32InPortPtrs(block,1);
      if (ismat) {
        ptr_ul = (SCSUINT32_COP *) &(ptr_i[44]);
        for (i=0;i<nu*nu2;i++) {
          ptr_ul[ptr->cnt*(nu*nu2)+i] = u_ul[i];
        }
      }
      else {
        ptr_ul = (SCSUINT32_COP *) &(ptr_i[10]);
        for (i=0;i<nu;i++) {
          ptr_ul[ptr->cnt+i*nz]=u_ul[i];
        }
      }
      break;

    default  : /* Add a message here */
               break;
   }

   /* t */
   ptr_i           = (int*) ptr->workt;
   ptr_d           = (SCSREAL_COP *) &(ptr_i[10]);
   ptr_d[ptr->cnt]  = t;

   /*
    * update cnt
    */
   ptr->cnt++;
   if (ptr->cnt==nz) {
     ptr->cnt = 0;
     ptr->loop++;
   }
 }
}
