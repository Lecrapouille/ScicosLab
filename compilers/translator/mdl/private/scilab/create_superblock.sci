function blk = create_superblock(scs_m)
  rhs=argn(2)  
  blk = instantiate_block("SUPER_f")
  if rhs>0 then
    blk.model.rpar=scs_m
    [ok,blk]=adjust_s_ports(blk)
    if ~ok then error("Unknown error"),end
  end
endfunction
