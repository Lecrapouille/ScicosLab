function txt=addClock(txt,para,nin,nout)
      txt($+1)=ID+"%blk=instantiate_block('"TIME_f'")"
endfunction
