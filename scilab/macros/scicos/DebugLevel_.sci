function DebugLevel_()
  if ~super_block then
    Cmenu=[]
    %scs_help='scicos_debug';
    [ok,n]=getvalue(['Set debugging level (0,1,2,3)';'It performs scicos_debug(n)'],...
                     'Debug level',list("vec",1),string(scicos_debug()));
    //n=dialog(['Set debugging level (0,1,2,3)';
    //          'It performs scicos_debug(n)'],string(scicos_debug()))
    n=evstr(n)
    if n==0|n==1|n==2|n==3 then
      scicos_debug(n)
    end
  else
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
                     'Cmenu='"Debug Level'";%scicos_navig=[]';
                     '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1']
  end
endfunction
