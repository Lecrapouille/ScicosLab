function [ok,tt]=FORTR(funam,tt,inp,out)
// Copyright INRIA
//
ni=size(inp,'*')
no=size(out,'*')
if tt==[] then

  tete1=['      subroutine '+funam+'(flag,nevprt,t,xd,x,nx,z,nz,tvec,';..
      '     $        ntvec,rpar,nrpar,ipar,nipar']

  tete2= '     $        '
  for i=1:ni
    tete2=tete2+',u'+string(i)+',nu'+string(i)
  end
  for i=1:no
    tete2=tete2+',y'+string(i)+',ny'+string(i)
  end
  tete2=tete2+')'

  tete3=['      double precision t,xd(*),x(*),z(*),tvec(*)';..
    '      integer flag,nevprt,nx,nz,ntvec,nrpar,ipar(*)']

  tete4= '      double precision rpar(*)'
    for i=1:ni
      tete4=tete4+',u'+string(i)+'(*)'
    end
    for i=1:no
      tete4=tete4+',y'+string(i)+'(*)'
    end
    tetec=['c';'c'];tetev=[' ';' '];
    tetend='      end'

    textmp=[tete1;tete2;tetec;tete3;tete4;tetec;tetev;tetec;tetend];
  else
    textmp=tt;
  end

  tt = textmp
  ok   = %t
  //## set param of scstxtedit
  ptxtedit=scicos_txtedit(clos = 0,...
          typ  = "Ffunc",...
          head = ['Function definition in fortran';
                  'Here is a skeleton of the functions which';
                  ' you shoud edit.']);

  while 1==1

    [txt,Quit] = scstxtedit(textmp,ptxtedit);

    if ptxtedit.clos==1 then
      break;
    end

    if txt<>[] then
      [ok]=scicos_block_link(funam,txt,'f')
      if ok then
        ptxtedit.clos=1
        tt=txt
        ok = %t;
      end
      textmp=txt;
    end

    if Quit==1 then
      ok = %f;
      break;
    end
  end

endfunction
