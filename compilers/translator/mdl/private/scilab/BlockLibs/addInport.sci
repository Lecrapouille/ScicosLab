function txt=addInport(txt,para,nin,nout)
      txt($+1)=ID+"%blk=instantiate_block('"IN_f'")"
      txt($+1)=ID+'%exprs='+sci2exp([string(para.Port),'-1','-1'])
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
