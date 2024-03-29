function [ok,tt,cancel]=CFORTR2(funam,tt)
// Copyright INRIA
//
cancel=%f

if tt==[] then
  
  textmp=[
	  '#include <math.h>';
	  '#include <stdlib.h>';
	  '#include <scicos/scicos_block.h>';
	  'void '+funam+'(scicos_block *block,int flag)';
	 ];
  ttext=[];
  textmp($+1)='{'
  textmp=[textmp;
	  '  /* ';
	  '  int block->nevprt;'
	  '  int block->nz;'
	  '  double* block->z;'
	  '  int block->nx;'
	  '  double* block->x;'
	  '  double* block->xd;'
	  '  double* block->res;'
	  '  int block->nin;'
	  '  int *block->insz;'
	  '  double **block->inptr;'
	  '  int block->nout;'
	  '  int *block->outsz;'
	  '  double **block->outptr;'
	  '  int block->nevout;'
	  '  int block->nrpar;'
	  '  double *block->rpar;'
	  '  int block->nipar;'
	  '  int *block->ipar;'
	  '  int block->ng;'
	  '  double *block->g;'
	  '  int *block->jroot;'
	  '  char block->label[41];'
	  '  */']
  
  textmp($+1)='  if (flag == 4) { /* initialization */'
  textmp($+1)='   '+funam+"_bloc_init(block,flag);"
    ttext=[ttext;'int '+funam+"_bloc_init(scicos_block *block,int flag)";
	   "{";
	   "return 0;}"];
  textmp($+1)=' '
  if nout<>0 then 
    textmp($+1)='  } else if(flag == 1) { /* output computation*/'
    textmp($+1)='   set_block_error('+funam+"_bloc_outputs(block,flag));"
    ttext=[ttext;'int '+funam+"_bloc_outputs(scicos_block *block,int flag)";
	   "{";
	   "return 0;}"];
  end
  
  if nx<>0 then 
    textmp($+1)='  } else if(flag == 0) { /* derivative or residual computation*/',
    textmp($+1)='   set_block_error('+funam+"_bloc_deriv(block,flag));"
    ttext=[ttext;'int '+funam+"_bloc_deriv(scicos_block *block,int flag)";
	   "{";
	   "return 0;}"];
  end
  
  if ng <>0 then
    textmp($+1)='  } else if(flag == 9) {/* zero crossing surface and mode computation*/',
    textmp($+1)='     set_block_error('+funam+"_bloc_zcross(block,flag));";
    ttext=[ttext;'int '+funam+"_bloc_zcross(scicos_block *block,int flag)";
	   "{";
	   "return 0;}"];
  end
  
  if nz<>0 then 
    textmp($+1)='  } else if(flag == 2) { /* computation of next discrte state*/ ',
    textmp($+1)='     set_block_error('+funam+"_bloc_states(block,flag));";
        ttext=[ttext;'int '+funam+"_bloc_states(scicos_block *block,int flag)";
	   "{";
	   "return 0;}"];
  elseif min(nx,ng+nevin)>0 then 
    textmp($+1)='  } else if(flag == 2) { /* computation of jumped state*/ ',
    textmp($+1)='     set_block_error('+funam+"_bloc_states(block,flag));";
        ttext=[ttext;'int '+funam+"_bloc_states(scicos_block *block,int flag)";
	   "{";
	   "return 0;}"];
  end
   
  if nevout<>0 then 
    textmp($+1)='  } else if(flag == 3) { /* computation of output event times*/',
    textmp($+1)='     set_block_error('+funam+"_bloc_evtout(block,flag));";
        ttext=[ttext;'int '+funam+"_bloc_evtout(scicos_block *block,int flag)";
	   "{";
	   "return 0;}"];
  end
  textmp($+1)='  } else  if (flag == 5) { /* ending */'
      textmp($+1)='     set_block_error('+funam+"_bloc_ending(block,flag));";
        ttext=[ttext;'int '+funam+"_bloc_ending(scicos_block *block,int flag)";
	   "{";
	   "return 0;}"];
  textmp($+1)='  }'
  textmp($+1)='}'
  textmp=[textmp;' '; ttext];
else
  textmp=tt;
end

tt = textmp
ok   = %t
//## set param of scstxtedit
ptxtedit=scicos_txtedit(clos = 0,...
          typ  = "Cfunc",...
          head = ['Function definition in C';
                  'Here is a skeleton of the functions which';
                  ' you shoud edit.']);

while 1==1

  [txt,Quit] = scstxtedit(textmp,ptxtedit);

  if ptxtedit.clos==1 then
    break;
  end

  if txt<>[] then
    libss='';cflags='';
    [libss,cflags,ok,cancel]=get_dynamic_lib_dir(txt,funam,'c',libss,cflags)

    if ~cancel & ok then
      [ok]=scicos_block_link(funam,txt,'c',libss,cflags)
      if ok then
        ptxtedit.clos=1
        tt=txt
        ok = %t;
      end
      textmp=txt;
    end
  end

  if Quit==1 then
    ok = %f;
    cancel =%t;
    break;
  end
end

endfunction
