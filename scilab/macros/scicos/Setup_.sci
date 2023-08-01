function Setup_()
// Copyright INRIA
  Cmenu = [] ;
  %pt = []   ;
  if ~super_block then
    %wpar=do_setup(scs_m.props)
    %scicos_solver=%wpar.tol(6)
    if or(scs_m.props<>%wpar) then
      scs_m.props=%wpar
      edited=%t
    end
  else
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
		       'Cmenu='"Setup'";%scicos_navig=[]';
		       '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1']
  end

endfunction
