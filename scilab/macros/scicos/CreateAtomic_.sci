function CreateAtomic_()
// Copyright INRIA
if alreadyran then
  Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
      '[alreadyran,%cpr]=do_terminate();%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1';
      'Select='+sci2exp(Select)+';Cmenu='"Create Atomic'"';]
  //return
else
  Cmenu=[];%pt=[];
  if size(Select,1)<>1 | curwin<>Select(1,2) then
    return
  end
  i=Select(1)
  o=scs_m.objs(i)
  if typeof(o)=='Block' then
    if o.model.sim=='super' then
      if size(o.model.evtin,'*')>1 then
	message('Atomic Subsystem cannot have more than one activation port');
	return;
      end
      [o,needcompile,ok]=do_CreateAtomic(o,i,scs_m)
      if ~ok then return ;end
      scs_m = update_redraw_obj(scs_m,list('objs',i),o)
    else
      message('Atomic can only be applied to unmasked Super Blocks.');
    end
  else
    message('Atomic can only be applied to unmasked Super Blocks.');
  end
end
endfunction
