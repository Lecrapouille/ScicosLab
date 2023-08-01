function AnalyzeDiagram_()
if ~super_block then
  Cmenu = [] ; 
  if needcompile>0 then 
    message("You must first compile the diagram.")
  else
    do_analyze_diagram(%cpr)
  end
else
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
		       'Cmenu='"Analyze Diagram'";%scicos_navig=[]';
		       '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1']
end
endfunction

