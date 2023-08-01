function  txt=addTransportDelay(txt,para,nin,nout)

del=para.DelayTime
Init=para.InitialOutput
bfsz=para.BufferSize

      txt($+1)=ID+"%blk=instantiate_block('"TIME_DELAY'")"
      txt($+1)=ID+'%exprs='+sci2exp([del;Init;bfsz])
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
