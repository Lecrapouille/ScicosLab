function blk = set_block_nout(blk,nout,impl)
   rhs=argn(2)
   if ~isempty(blk.graphics.pout) &  ~and(0==blk.graphics.pout) then
      error("Number of ports of connected blocks cannot be changed.")
   end
   blk.graphics.pout=zeros(nout,1)
   if nout>size(blk.model.out,1) then
       blk.model.out($+1:nout)=-10  // correct size
   elseif nout<size(blk.model.out,1) then
      blk.model.out=blk.model.out(1:nout)
   end
   if rhs<3 then
     I='E';
     blk.graphics.out_implicit=I(ones(nout,1));
   else
     blk.graphics.out_implicit=impl
   end
endfunction
