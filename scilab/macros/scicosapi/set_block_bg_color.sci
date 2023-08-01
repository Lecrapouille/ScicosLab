function blk = set_block_bg_color(blk,blk_color)
  if size(blk_color,'*') <> 1 then
    cmap=get(sdf(),"color_map")
    // cmap=xget("colormap")
    dif=abs(cmap-ones(size(cmap,1),1)*blk_color)*[1;1;1]
    [ju,blk_color]=min(dif);
  end
  if typeof(blk.graphics.gr_i)== 'string' then
    blk.graphics.gr_i = list(blk.graphics.gr_i,blk_color),
  else
    blk.graphics.gr_i(2)=blk_color;
  end
endfunction
