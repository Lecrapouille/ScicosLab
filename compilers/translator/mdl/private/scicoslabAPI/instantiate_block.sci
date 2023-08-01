function blk = instantiate_block(name)
  execstr('blk='+name+'(''define'')')
  blk.graphics.sz=20*blk.graphics.sz
endfunction


