// Copyright INRIA
function [o,needcompile,ok]=do_RemoveAtomic(o)
ok=%t
if typeof(o)=='Block' then
  model=o.model
  graphics=o.graphics;
  if model.sim(1)=='asuper' then  //
    gh_curwin=scf(curwin)
    o.model.sim='super';
    o.model.in=-ones(size(model.in,1),size(model.in,2))
    o.model.in2=-2*ones(size(model.in2,1),size(model.in2,2))
    o.model.out=-ones(size(model.out,1),size(model.out,2))
    o.model.out2=-2*ones(size(model.out2,1),size(model.out,2))
    o.model.intyp=-ones(1,size(model.intyp,'*'))
    o.model.outtyp=o.model.intyp
    o.graphics.exprs=graphics.exprs(1)
    needcompile=4;
   // needcompile=resume(needcompile)
  else
    message('Remove Atomic can only be affected to Atomic Super Blocks.');ok=%f; return
  end
else
  message('Remove Atomic can only be affected to Atomic Super Blocks.');ok=%f; return 
end
endfunction
