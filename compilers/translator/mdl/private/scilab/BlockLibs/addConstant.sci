function txt=addConstant(txt,para,nin,nout)
      txt($+1)=ID+"%blk=instantiate_block('"CONST_m'")"
      txt($+1)=ID+'%exprs='+sci2exp(para.Value)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
