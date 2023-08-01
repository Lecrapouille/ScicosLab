function Eval_()
// Copyright INRIA
  if ~super_block then
    Cmenu='Replot'

    %now_win=xget('window')

    [%scicos_context,ierr]=script2var(scs_m.props.context,%scicos_context)
    //for backward compatibility for scifunc
    if ierr==0 then
      %mm=getfield(1,%scicos_context)
      for %mi=%mm(3:$)
	ierr=execstr(%mi+'=%scicos_context(%mi)','errcatch')
	if ierr<>0 then
	  break
	end
      end
    end
    //end of for backward compatibility for scifunc
    
    xset('window',%now_win)
    if ierr==0 then 
      do_terminate()
      [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr,%scicos_context)
      if needcompile<>4&size(%cpr)>0 then %state0=%cpr.state,end
      alreadyran=%f
    else
      message(['Incorrect context definition, ';lasterror()] )
    end
  else
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
		       'Cmenu='"Eval'";%scicos_navig=[]';
		       '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1']
  end
endfunction
