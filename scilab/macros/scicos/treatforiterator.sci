function [ok,for_iterator_flag,init_output,nbre_iter,step,ss_input_nbre,iter_var_datatype,obj_nbre,exist_output,startingstate,iter_op]=treatforiterator(scs_m)
//Fady 15 Dec 2008
for_iterator_flag=%f;ok=%t;init_output=0;nbre_iter=-2;step=0;ss_input_nbre=0;obj_nbre=[];iter_var_datatype=1;obj_nbre=[];exist_output=0;startingstate=0;iter_op='';
for i=1:lstsize(scs_m.objs)
  o=scs_m.objs(i)
  if typeof(o)=='Block' then
    if o.gui=='ForIterator' then
      if ~for_iterator_flag then
	for_iterator_flag=%t;
	init_output=eval(o.graphics.exprs(1))
	if o.graphics.exprs(3)=='0' then
	  nbre_iter=eval(o.graphics.exprs(2));
	else
	  from_blk=scs_m.objs(scs_m.objs(o.graphics.pin(1)).from(1))
	  while from_blk.gui=='SPLIT_f' then
	    from_blk=scs_m.objs(scs_m.objs(from_blk.graphics.pin(1)).from(1));
	  end
	  if from_blk.gui=='IN_f' then
	    ss_input_nbre=eval(from_blk.graphics.exprs(1))
	  else
	    message(['When the numbre of iterations is given as an external parameter';
		'The first input of the block must be connected to the input port']);
	    ok=%f;
	    return
	  end
	end
	if o.graphics.exprs(4)=='0'|o.graphics.exprs(5)=='0'
	  step=1;
	end
	iter_var_datatype=eval(o.graphics.exprs(6));
	obj_nbre=i;
	exist_output=evstr(o.graphics.exprs(4));
	startingstate=evstr(o.graphics.exprs(7));
	iter_op='for'
      else
	message('Cannot have two iterator blocks in the same diagram');
	ok=%f;
	return;
      end
    elseif o.gui=='WhileIterator' then
      if ~for_iterator_flag then
	for_iterator_flag=%t;
	init_output=1;
	nbre_iter=evstr(o.graphics.exprs(1))
	step=1;
	obj_nbre=i;
	iter_var_datatype=evstr(o.graphics.exprs(5));
	exist_output=evstr(o.graphics.exprs(4));
	startingstate=evstr(o.graphics.exprs(3));
	op=['do while','while']
	iter_op=op(evstr(o.graphics.exprs(2))+1);
      else
	message('Cannot have two iterator blocks in the same diagram');
	ok=%f;
	return;
      end	
    end
  end
end
endfunction
