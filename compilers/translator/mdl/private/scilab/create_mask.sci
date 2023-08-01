function o = create_mask(blk,params_values,params_names,params_prompts,ptitle,param_types)
rhs=argn(2)
if rhs<6 then 
  n=size(params_values,1);
  param_types=list();
  for i=1:n
    param_types($+1)="gen";
    param_types($+1)=1;
  end
end
if rhs<5 then 
  ptitle="Set block parameters"
end

if typeof(blk) == 'Block' then
   o = blk
   model=o.model
   graphics=o.graphics;
   if model.sim=='super' then  //
      bname=model.rpar.props.title(1)
      model.sim='csuper'
      model.ipar=1 ;  // specifies the type of csuper (mask)
      graphics.exprs=list(params_values,list(params_names,..
                    [sci2exp(ptitle,0);params_prompts],param_types));     
      graphics.gr_i=list('xstringb(orig(1),orig(2),'"'+..
        bname+''",sz(1),sz(2),''fill'');',8)
      o.model=model;
      o.graphics=graphics;
      o.gui='DSUPER';
   else
      error('Mask can only be created for Super Blocks.')
   end
else
  error('Mask can only be created for Super Blocks.')
end
endfunction
