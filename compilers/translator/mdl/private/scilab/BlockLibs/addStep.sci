function txt=addStep(txt,para,nin,nout)
      txt($+1)=ID+"%blk=instantiate_block('"STEP_FUNC'")"
      tim=para.Time
      be=para.Before
      af=para.After
      txt($+1)=ID+'%exprs='+sci2exp([tim;be;af],0)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
