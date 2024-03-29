function [ok,tt,cancel,libss,cflags]=CC4(funam,tt,libss,cflags)
// Copyright INRIA
//
cancel=%f

if tt==[] then

  textmp=['#include <scicos/scicos_block4.h>';
          ''
          'void '+funam+'(scicos_block *block,int flag)';
         ];
  ttext=[];
  textmp($+1)='{'
  textmp=[textmp]

  textmp($+1)='  /* init */'
  textmp($+1)='  if (flag == 4) {'
  textmp($+1)='   ';
  if out<>0 then
    textmp($+1)='  /* output computation */ ';
    textmp($+1)='  } else if(flag == 1) {'
    textmp($+1)='   ';
  end

  if nx<>0 then
    textmp($+1)='  /* derivative or residual computation */'
    textmp($+1)='  } else if(flag == 0) {'
    textmp($+1)='   ';
  end

  if nzcr<>0 then
    textmp($+1)='  /* zero crossing surface and mode computation */'
    textmp($+1)='  } else if(flag == 9) {'
    textmp($+1)='   ';
  end

  if nz<>0 then
    textmp($+1)='  /* computation of next discrete state*/ '
    textmp($+1)='  } else if(flag == 2) { '
    textmp($+1)='   ';

  elseif min(nx,nzcr+nevin)>0 then
    textmp($+1)='  /* computation of jumped state*/ '
    textmp($+1)='  } else if(flag == 2) {'
    textmp($+1)='   ';
  end

  if nevout<>0 then
    textmp($+1)='  /* computation of output event times*/'
    textmp($+1)='  } else if(flag == 3) {'
    textmp($+1)='   '
  end
  textmp($+1)='  /* ending */'
  textmp($+1)='  } else  if (flag == 5) {'
  textmp($+1)='   ';
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
                  ' you should edit.']);

while 1==1

  [txt,Quit] = scstxtedit(textmp,ptxtedit);

  if ptxtedit.clos==1 then
    break;
  end

  if txt<>[] then
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
