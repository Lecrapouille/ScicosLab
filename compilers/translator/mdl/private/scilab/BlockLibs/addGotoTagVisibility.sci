function txt=addGotoTagVisibility(txt,para,nin,nout)

      txt($+1)=ID+"%blk=instantiate_block('"GotoTagVisibility'")"
      txt($+1)=ID+'%exprs='+sci2exp(sci2exp(para.GotoTag),0)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
