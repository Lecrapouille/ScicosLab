function param_name=get_param_name(mo_param,Pars)
//Copyright INRIA
//## return an unique name for a modelica parameter
//## for the compiled modelica structure
//##
//## inputs :
//##   mo_param : a string that gives the name of the parameters
//##              in the modelica list (equations) of a modelica block.
//##
//##   Pars     : vector of strings of already attribuate parameters name
//##
//## output :
//##   param_name : the output string of the parameters name
//##
  ind = 1
  param_name=strsubst(mo_param," ","")+...
                      string(ind)
  while find(param_name==Pars)<>[] then
    ind = ind + 1
    param_name=strsubst(mo_param," ","")+...
                        string(ind)
  end
endfunction
