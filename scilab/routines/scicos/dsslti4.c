#include <memory.h>
#include "scicos_block4.h"
#include "../machine.h"

extern int C2F(dmmul)();
extern int C2F(dmmul1)();


void dsslti4(scicos_block *block,int flag)
{
  void **_work=GetPtrWorkPtrs(block);
  /* Copyright INRIA
     
  Scicos block simulator
  discrete state space linear system simulator
  rpar(1:nx*nx)=A
  rpar(nx*nx+1:nx*nx+nx*nu)=B
  rpar(nx*nx+nx*nu+1:nx*nx+nx*nu+nx*ny)=C */
  
  int un=1,lb,lc,ld;
  int nz=GetNdstate(block);
  double* z=GetDstate(block);
  double* rpar=GetRparPtrs(block);
  double* y=GetRealOutPortPtrs(block,1);
  double* u=GetRealInPortPtrs(block,1);
  int noutsz=GetOutPortRows(block,1);
  int ninsz=GetInPortRows(block,1);
  double *w;
  
  lb=nz*nz;
  
  if (flag ==1 || flag ==6){
    /* y=c*x+d*u */
    lc=lb+nz*ninsz;
    ld=lc+nz*noutsz;
    if (nz==0) {
      C2F(dmmul)(&rpar[ld],&noutsz,u,&ninsz,y,&noutsz,&noutsz,&ninsz,&un);
    }else{
      C2F(dmmul)(&rpar[lc],&noutsz,z,&nz,y,&noutsz,&noutsz,&nz,&un);
      C2F(dmmul1)(&rpar[ld],&noutsz,u,&ninsz,y,&noutsz,&noutsz,&ninsz,&un);
    }
  }
  else if (flag ==2){
    /* x+=a*x+b*u */
    if (nz!=0){
      w =*_work;
      memcpy(w,z,nz*sizeof(double));
      C2F(dmmul)(&rpar[0],&nz,w,&nz,z,&nz,&nz,&nz,&un);
      C2F(dmmul1)(&rpar[lb],&nz,u,&ninsz,z,&nz,&nz,&ninsz,&un);
    }
  }
  else if (flag ==4&&nz!=0){/* the workspace for temp storage
		      */
    if ((*_work=
	 scicos_malloc(sizeof(double)*nz))== NULL ) {
      set_block_error(-16);
      return;
    }
  }
  else if (flag ==5&&nz!=0){
    scicos_free(*_work);
  }
}


