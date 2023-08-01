function blk = set_block_bg_color(blk,clr)
    cmap=get(sdf(),"color_map")
    dif=abs(cmap-ones(size(cmap,1),1)*clr)*[1;1;1]
    [ju,col]=min(dif)

   if type(blk.graphics.gr_i)==10 then,
      blk.graphics.gr_i = list(blk.graphics.gr_i,col),
   else
      blk.graphics.gr_i(2)=col
   end
endfunction
