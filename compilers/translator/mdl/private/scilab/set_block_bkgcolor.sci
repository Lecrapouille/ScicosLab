function blk = set_block_bkgcolor(blk,col)
   if type(blk.graphics.gr_i)==10 then,
      blk.graphics.gr_i = list(blk.graphics.gr_i,col),
   else
      blk.graphics.gr_i(2)=col
   end
endfunction
