function txt=addMux(txt,para,nin,nout)
      txt($+1)=ID+"%blk=instantiate_block('"MUX'")"
      txt($+1)=ID+'%exprs='+sci2exp(para.Inputs)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
