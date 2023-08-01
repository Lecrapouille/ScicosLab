function txt=addDLatch(txt,para,nin,nout)
      txt($+1)=ID+"%blk=instantiate_block('"DLATCH'")"
endfunction
