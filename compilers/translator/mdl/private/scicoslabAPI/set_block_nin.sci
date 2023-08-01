function blk = set_block_nin(blk,nin,impl)
   rhs=argn(2)
   if ~isempty(blk.graphics.pin) &  ~and(0==blk.graphics.pin) then
      error("Number of ports of connected blocks cannot be changed.")
   end
   blk.graphics.pin=zeros(nin,1)
   if nin>size(blk.model.in,1) then
      blk.model.in($+1:nin)=-20
   elseif nin<size(blk.model.in,1) then
      blk.model.in=blk.model.in(1:nin)
   end
   if rhs<3 then
     I='E';
     blk.graphics.in_implicit=I(ones(nin,1))
   else
     blk.graphics.in_implicit=impl
   end
endfunction
