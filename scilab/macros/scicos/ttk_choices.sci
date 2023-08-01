function rep=ttk_choices(titel,listp)
// Copyright INRIA
//## ttk_choices : a tcl/ttk widget replace x_choices

  rep=[]

  done=create_dialog(titel,listp)

  if done==string(1) then
    nitems=lstsize(listp)
    for i=1:nitems
      execstr('x=TCL_GetVar(''x'+string(i)+''')')
      rep(i)=evstr(x)+1
    end
    rep=rep'
    close_dialog()
  elseif done==string(2)
    rep=[]
    close_dialog()
  else
    TCL_EvalStr('set done 0');
    TCL_EvalStr('tkwait variable done');
  end
endfunction

function close_dialog()
  TCL_EvalStr('TkChoices '+string(0)+' '+string(0)+...
              ' '+string(0)+' '+string(0)+' '+string(0)+...
              ' '+string(1))
endfunction

function done=create_dialog(titel,listp)
  //## Init TCL/TK sciGUI interf
  if and(titel=="ID font definitions") then
    typ='IDfont'
    [numx,numy,ledtx,ledty,...
        InFile,OutFile,HelpFile]=get_ttk_vars(typ)
  else
    typ=''"'"'
    [numx,numy,ledtx,ledty,...
        InFile,OutFile,HelpFile]=get_ttk_vars('choose')
  end

  nitems=lstsize(listp)

  //## set labels and combox
  for i=1:nitems
    TCL_EvalStr('global label_f'+string(i)+';set label_f'+string(i)+' '"'+string(sci2tcl(listp(i)(1)))+''"')
    nentry = size(listp(i)(3),'*')
    TCL_EvalStr('global c_f'+string(i)+';set c_f'+string(i)+' '"'+string(nentry)+''"')
    for j=1:nentry
      TCL_EvalStr('global c_f'+string(i)+string(j)+...
                  ';set c_f'+string(i)+string(j)+' '"'+string(sci2tcl(listp(i)(3)(1,j)))+''"')
    end
    TCL_EvalStr('global index_f'+string(i)+';set index_f'+string(i)+' '"'+string(listp(i)(2)-1)+''"')
  end

  //## save titel in a file
  if MSDOS then
    mputl(titel,strsubst(HelpFile,'\\\\','\'));
  else
    mputl(titel,HelpFile);
  end

  clos=0

  TCL_EvalStr('TkChoices '+string(nitems)+' '+string(numx)+...
              ' '+string(numy)+' '+string(typ)+' '+HelpFile+...
              ' '+string(clos))

  done=TCL_GetVar('done')
endfunction