function txt=addRamp(txt,para,nin,nout)

sl=para.slope
st=para.start
X0=para.X0


      txt($+1)=ID+"%blk=instantiate_block('"RAMP'")"
      txt($+1)=ID+'%exprs='+sci2exp([sl;st;X0],0)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
