function txt=addSRFlipFlop(txt,para,nin,nout)
      txt($+1)=ID+"%blk=instantiate_block('"SRFLIPFLOP'")"
      txt($+1)=ID+'%exprs='+sci2exp(para.initial_condition)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
