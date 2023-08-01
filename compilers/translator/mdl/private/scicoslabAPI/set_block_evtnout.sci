function blk = set_block_evtnout(blk,nout)
   if ~isempty(blk.graphics.peout) & ~and(0==blk.graphics.peout) then
      error("Number of ports of connected blocks cannot be changed.")
   end
   blk.graphics.peout=zeros(nout,1)
   blk.model.evtout=ones(nout,1)
endfunction
