function txt=addTerminator(txt,para,nin,nout)
      txt($+1)=ID+"%blk=instantiate_block('"MUX'")"
      txt($+1)=ID+"%blk=set_block_parameters(%blk,'"1'")"
endfunction
