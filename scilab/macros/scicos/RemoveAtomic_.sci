function RemoveAtomic_()
if alreadyran then
  Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
      '[alreadyran,%cpr]=do_terminate();%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1';
      'Select='+sci2exp(Select)+';Cmenu='"Remove Atomic"'';]
else
Cmenu=[];%pt=[];
if size(Select,1)<>1 | curwin<>Select(1,2) then
  ok=%f;return
end
i=Select(1)
o=scs_m.objs(i)
[o,needcompile,ok]=do_RemoveAtomic(o)
if ~ok then message('Error in removing atomic');return; end
scs_m = update_redraw_obj(scs_m,list('objs',i),o)
end
endfunction

