function [ok,txt_out]=genfunc5(name,txt_in,ni,no,nie,noe,nx,nz,nzcr)

  ok=%t
  txt_out=txt_in

  if txt_in==[] then
    textmp=['function [blk] = '+name+'(blk,flag)'
            ''
            '  //initialisation'
            '  if flag==4 then'
            '']

    if no<>0 then
      textmp=[textmp
              '  //output fixed point'
              '  elseif flag==6 then'
              ''
              '  //output computation'
              '  elseif flag==1 then'
              '']
    end

    if nx<>0 then
      textmp=[textmp
              '  //state derivative computation'
              '  elseif flag==0 then'
              '']
    end

    if nz<>0 then
      textmp=[textmp
              '  //discrete state computation'
              '  elseif flag==2 then'
              '']
    end

    if noe<>0 then
      textmp=[textmp
              '  //out event date computation'
              '  elseif flag==3 then'
              '']
    end

    if nzcr<>0 then
      textmp=[textmp
              '  //zero crossing computation'
              '  elseif flag==9 then'
              '']
    end

    textmp=[textmp
            '  //finish'
            '  elseif flag==5 then'
            ''
            '  end'
            ''
            'endfunction']
  else
    textmp=txt_in
  end

  ptxtedit=scicos_txtedit(clos = 0,...
          typ  = "Scifunc5",...
          head = ['Function definition in scilab language.';
                  'Here is a skeleton of the function which';
                  ' you should edit.']);

  while 1==1

    [txt,Quit] = scstxtedit(textmp,ptxtedit);

    if ptxtedit.clos==1 then
      break;
    end

    if txt<>[] then
      ok=%t
      mputl(txt,TMPDIR+'/scifunc5_tmp.sci');
      execstr('clear '+name);
      prot=funcprot();
      funcprot(0);
      getf(TMPDIR+'/scifunc5_tmp.sci','n');
      mess=['Please check your scilab instructions.';
            ''
            'Your script must define the function';
            'in the form :';
            ''
            'function [blk_out]='+name+'(blk_in,flag)';
            '...'
            'endfunction']
      if ~exists(name) then
        message([' Undefined function '''+name+'''.';
                 mess])
         ok=%f
      else
        execstr('typ=type('+name+')')
        if typ<>11 then
          message([' '''+name+''' is not a scilab function.';
                   mess])
          ok=%f
        else
          if execstr('comp('+name+')','errcatch')<>0 then
            message([' Incorrect syntax: ';
                     lasterror()
                     ''
                     'Please check your scilab function.'])
            ok=%f
          else
            execstr('vars=macrovar('+name+')');
            if size(vars(1),'*')<>2 | size(vars(2),'*')<>1 then
              if size(vars(1),'*')<>2 then
                message([' Number of input arguments is incorrect.';
                         mess])
              else
                message([' Number of output argument is incorrect.';
                         mess])
              end
              ok=%f
            end
          end
        end
        funcprot(prot)
      end


      if ok then
        ptxtedit.clos=1
        txt_out=txt
        ok = %t;
      end
      textmp=txt
    end

    if Quit==1 then
      ok = %f;
      break;
    end
  end

endfunction
