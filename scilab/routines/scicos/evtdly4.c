#include "scicos_block4.h"
/*    Copyright INRIA
 *    Scicos block simulator
 *    event delay with discrete counter
 */

#ifndef NULL
#define NULL    0
#endif

void evtdly4(scicos_block *block,int flag)
{
  void **_work=GetPtrWorkPtrs(block);
  double *_rpar=GetRparPtrs(block);
  double *_evout= GetNevOutPtrs(block);
  double t;
  long long int *i;

  switch(flag)
  {
   /* init */
   case 4  : {/* the workspace is used to store discrete counter value */
              if ((*_work=scicos_malloc(sizeof(long long int)))==NULL) {
                set_block_error(-16);
                return;
              }
              i=*_work;
              (*i)=0;
              break;
             }

   /* event date computation */
   case 3  : {
              i=*_work;
              t=GetScicosTime(block);
              (*i)++; /*increase counter*/
              _evout[0]=_rpar[1]+ \
                              (*i)*_rpar[0]-t;
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
