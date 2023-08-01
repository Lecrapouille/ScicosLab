function blk=set_block_icon_text(blk,icon)
   txt='xstringb(orig(1),orig(2),'+sci2exp(icon,0)+',sz(1),sz(2),''fill'')'
       blk.graphics.gr_i(1)=txt
endfunction
