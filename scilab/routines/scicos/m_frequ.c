#include "scicos_block4.h"


#ifndef NULL
#define NULL    0
#endif

void m_frequ(scicos_block *block,int flag)
{
  void **_work=GetPtrWorkPtrs(block);
  double *_evout= GetNevOutPtrs(block);
  double *mat;
  double *Dt;
  double *off;
  SCSINT32_COP *icount;
  double t;
  long long *counter;
  int m;
  mat=GetRealOparPtrs(block,1);
  Dt=GetRealOparPtrs(block,2);
  off=GetRealOparPtrs(block,3);
  icount=Getint32OparPtrs(block,4);
  m=GetOparSize(block,1,1);
  
  switch(flag)
  {

   case 4 :  {/* the workspace is used to store discrete counter value */
              if ((*_work=scicos_malloc(sizeof(long long int)*2))==NULL) {
                set_block_error(-16);
                return;
              }
              counter=*_work;
              *counter=*icount;
              (*(counter+1))=0;
              break;
             }

   /* event date computation */
   case 3  : {
              counter=*_work;
              t=GetScicosTime(block); 
              *counter+=(int)mat[*(counter+1)]; /*increase counter*/
              _evout[(int)mat[*(counter+1)+m]-1]=*off+((double)*counter*(*Dt))-t;
              (*(counter+1))++;
	      *(counter+1)=*(counter+1)%m;
              break;
             }

   /* finish */
   case 5  : {
              scicos_free(*_work); /*free the workspace*/
              break;
             }

   default : break;
  }
}
