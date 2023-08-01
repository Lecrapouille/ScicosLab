function txt=addFrom(txt,para,nin,nout)

      txt($+1)=ID+"%blk=instantiate_block('"FROM'")"
      txt($+1)=ID+'%exprs='+sci2exp([sci2exp(para.GotoTag);"1"],0)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
