function txt=addScope(txt,para,nin,nout)
//using o.Name, must be put in as argument
  nu=evstr(para.NumInputPorts)
  ymin=para.YMin
  ymin="["+strsubst(ymin,"~",";")+"]"
  ymax=para.YMax
  ymax="["+strsubst(ymax,"~",";")+"]"
  if para.TimeRange=="auto" then 
    per="_final_simulation_time"
  else
    per=para.TimeRange
  end
  if isfield(para,'Location')
    loc=para.Location
  else
    loc=[]
  end
  sz=loc(3:4)-loc(1:2)
  og=loc(1:2)  // this is probably wrong- must be height-loc(2)+-sz(2)

  if nin==1 then
    txt($+1)=ID+"%blk=instantiate_block('"CSCOPE'")"
    txt($+1)=ID+"%exprs=['"1 3 5 7 9 11 13 15'";'"-1'";"+sci2exp(sci2exp(og))+";"+..
     sci2exp(sci2exp(sz))+";"+sci2exp(ymin)+";"+sci2exp(ymax)+..
     ";"+sci2exp(per)+";'"20'";'"1'";"+sci2exp(o.Name)+"]"
    txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
  else
    txt($+1)=ID+"%blk=instantiate_block('"CMSCOPE'")"
    txt($+1)=ID+"%exprs=["+sci2exp(sci2exp(-[1:nu]))+..
     ";'"1 3 5 7 9 11 13 15'";'"-1'";"+sci2exp(sci2exp(og))+";"+..
     sci2exp(sci2exp(sz))+";"+sci2exp(ymin)+";"+sci2exp(ymax)+..
     ";"+sci2exp(strcat(per(ones(1,nu)),","),0)+";'"20'";'"1'";"+sci2exp(o.Name)+"]"
    txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
  end
endfunction
