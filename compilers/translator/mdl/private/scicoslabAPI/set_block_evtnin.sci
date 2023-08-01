function blk = set_block_evtnin(blk,nin)
   if ~isempty(blk.graphics.pein) & ~and(0==blk.graphics.pein) then
      error("Number of ports of connected blocks cannot be changed.")
   end
   blk.graphics.pein=zeros(nin,1)
   blk.model.evtin= ones(nin,1)
endfunction
