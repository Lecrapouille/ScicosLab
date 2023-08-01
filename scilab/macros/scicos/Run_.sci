function Run_()
// Copyright INRIA
  if ~super_block then
    nc_save=4
    Cmenu=[]
    ok=%t
    %mm=getfield(1,%scicos_context)
    for %mi=%mm(3:$)
      ierr=execstr(%mi+'=%scicos_context(%mi)','errcatch')
      if ierr<>0 then
	break
      end
    end
    [ok,%tcur,%cpr,alreadyran,needcompile,%state0,..
                                            %scicos_solver]=do_run(%cpr)
    scs_m.props.tol(6)=%scicos_solver
    if ok then newparameters=list(),end
  else
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
		       'Cmenu='"Run'";%scicos_navig=[]';
		       '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1']
  end
endfunction
