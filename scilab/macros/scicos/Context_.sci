function Context_()
// Copyright INRIA
  Cmenu   = 'Replot' ; //** is it really necessary ?
  context = scs_m.props.context
  //## set param of scstxtedit
  txtedit = scicos_txtedit(clos = 0,...
       typ = "context",...
       head=['You may enter here scilab instructions to define '
             'symbolic parameters used in block definitions using'
             'Scilab instructions.'
             ' '
             'These instructions are evaluated once confirmed, i.e.,you'
             'click on OK, by Eval and every time diagram is loaded.'])

  while %t do
    gh_now_win = gcf() ; //** get the handle
    %now_win = gh_now_win.figure_id ; //** get the window id

    [rep,Quit] = scstxtedit(context,txtedit);

    if ~or(winsid()==%now_win) then 
      Cmenu="Quit",
      txtedit.clos=1
      message('Diagram has been closed. That context is no more valid.')
      [rep,Quit] = scstxtedit(context,txtedit);
      return,
    end

    scf(%now_win) ; //** put the focus in the current window

    if txtedit.clos==1 then
       break;
    end

    if rep==[] | Quit == 1 then //** in case of no entry
      ok = %f
      break;
    else
      context = rep //** if some text is typed //**
    end

    clear %scicos_context  // to make sure only parent context is used

    if ~exists('%scicos_context') then //** create a structure "just in case"
      %scicos_context = struct() ;
    end

    //** context eval here
    [%scicos_context, ierr] = script2var(context, %scicos_context)

    //for backward compatibility for scifunc
    if ierr==0 then
      %mm = getfield(1,%scicos_context)
      for %mi=%mm(3:$)
        ierr = execstr(%mi+'=%scicos_context(%mi)','errcatch')
        if ierr<>0 then
          break; //** in case of error exit
        end
      end
    end
    //end of for backward compatibility for scifunc

    if ierr <>0 then
      message(['Error occur when evaluating context:'
               lasterror() ]);

    else //** if the first check is ok
      scs_m_save = scs_m
      nc_save    = needcompile
      scs_m.props.context = context
      edited = %t
      alreadyran = %f
      enable_undo=%t
      do_terminate()
      [scs_m,%cpr,needcompile,ok] = do_eval(scs_m, %cpr,%scicos_context)
      txtedit.clos = 1
      if ok then
        if needcompile<>4 & size(%cpr)>0 then %state0=%cpr.state, end
      else
        message(['Error during Eval operation.';
                 'Please re-examine the content of the context.'])
        scs_m=scs_m_save
        scs_m.props.context = context;
	enable_undo=%f
      end
    end
  end //** of the "infinite" while
  clear txtedit; clear rep; clear Quit;
endfunction



