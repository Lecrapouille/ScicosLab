function Compile_()
// Copyright INRIA
  if ~super_block then
    nc_save=4
    Cmenu=[]
    needcompile=4,
    [%cpr,ok]=do_compile(scs_m)
    if ok then
      newparameters=list()
      %tcur=0 //temps courant de la simulation
      alreadyran=%f
      %state0=%cpr.state;
      needcompile=0;
    end
  else
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
		       'Cmenu='"Compile'";%scicos_navig=[]';
		       '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1']
  end
endfunction
