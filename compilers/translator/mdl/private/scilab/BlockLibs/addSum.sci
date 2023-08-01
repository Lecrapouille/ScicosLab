function txt=addSum(txt,para,nin,nout)
  ssign=ascii(para.Inputs)
  np=find(ssign==43)
  nm=find(ssign==45)
  l=size(ssign,2)
  kill=setdiff(1:l,[np,nm])
  ssign(kill)=[]
  ssign=(ssign==43) - (ssign==45)

  dt=1
  //if part(para.OutDataTypeStr,1:7)=="Inherit" then
  over=0
  //para.SaturateOnIntegerOverflow=0

  txt($+1)=ID+"%blk=instantiate_block('"SUMMATION'")"
  exprs=[string(dt);sci2exp(ssign,0);string(over)]
  txt($+1)=ID+"%blk=set_block_parameters(%blk,"+sci2exp(exprs,0)+")"
endfunction
