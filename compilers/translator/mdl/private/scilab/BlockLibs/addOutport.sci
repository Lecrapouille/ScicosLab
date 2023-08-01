function txt=addOutport(txt,para,nin,nout)
      txt($+1)=ID+"%blk=instantiate_block('"OUT_f'")"
      txt($+1)=ID+'%exprs='+sci2exp([string(para.Port)])
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
