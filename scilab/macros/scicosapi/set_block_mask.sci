function o = set_block_mask (blk, mask,ptitle)

xxx=getfield(1,mask)
parnames=xxx(3:$)

params_names=[]
params_values=[]
params_prompts=[]
param_types=list();
for params_name=parnames
  params_names($+1)=params_name
  params_values($+1)=mask(params_name).value
  params_prompts($+1)=mask(params_name).prompt
    param_types($+1)="gen";
    param_types($+1)=1;
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
