function txt=addDemux(txt,para,nin,nout)
      txt($+1)=ID+"%blk=instantiate_block('"DEMUX'")"
      txt($+1)=ID+'%exprs='+sci2exp(para.Outputs)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
