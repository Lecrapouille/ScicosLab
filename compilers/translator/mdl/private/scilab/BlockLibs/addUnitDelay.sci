function txt=addUnitDelay(txt,para,nin,nout)
  [st,ierr]=evstr(para.SampleTime)
  if ierr>0 | st>0 then
    txt($+1)=ID+"%blk=instantiate_block('"SUPER_f'")"
    txt($+1)=ID+"%blk.graphics.gr_i(1)='" '""
    txt($+1)=ID+"scsm1=instantiate_diagram()"
    txt($+1)=ID+"scsm1 = set_diagram_location(scsm1,[384,95,810,406],1.4)"
    txt($+1)=ID+"%blk1=instantiate_block('"IN_f'")"
    txt($+1)=ID+"%blk1=set_block_orig(%blk1,[189.23733,205.744])"
    txt($+1)=ID+"%blk1=set_block_sz(%blk1,[20,20])"
    txt($+1)=ID+"%exprs=['"1'";'"-1'";'"-1'"]"
    txt($+1)=ID+"%blk1=set_block_parameters(%blk1,%exprs)"
    txt($+1)=ID+"[scsm1,%l] = add_block(scsm1,%blk1)"
 
    txt($+1)=ID+"%blk1=instantiate_block('"OUT_f'")"
    txt($+1)=ID+"%blk1=set_block_orig(%blk1,[353.504,205.744])"
    txt($+1)=ID+"%blk1=set_block_sz(%blk1,[20,20])"
    txt($+1)=ID+"%blk1=set_block_parameters(%blk1,'"1'")"
    txt($+1)=ID+"[scsm1,%l] = add_block(scsm1,%blk1)"
 
    txt($+1)=ID+"%blk1=instantiate_block('"SampleCLK'")"
    txt($+1)=ID+"%blk1=set_block_orig(%blk1,[244.504,285.21067])"
    txt($+1)=ID+"%blk1=set_block_sz(%blk1,[60,40])"
    txt($+1)=ID+"%blk1=set_block_parameters(%blk1,["+sci2exp(para.SampleTime)+";'"0'"])"
    txt($+1)=ID+"[scsm1,%l] = add_block(scsm1,%blk1)"
 
    txt($+1)=ID+"%blk1=instantiate_block('"DOLLAR_m'")"
    txt($+1)=ID+"%blk1=set_block_orig(%blk1,[254.504,195.744])"
    txt($+1)=ID+"%blk1=set_block_sz(%blk1,[40,40])"
    txt($+1)=ID+"%blk1=set_block_parameters(%blk1,["+sci2exp(para.X0)+";'"0'"])"
    txt($+1)=ID+"[scsm1,%l] = add_block(scsm1,%blk1)"
 
    txt($+1)=ID+"scsm1 = add_explicit_link(scsm1,[1,1],[4,1],[])"
    txt($+1)=ID+"scsm1 = add_explicit_link(scsm1,[4,1],[2,1],[])"
    txt($+1)=ID+"scsm1 = add_event_link(scsm1,[3,1],[4,1],[])"
    txt($+1)=ID+"%blk=fill_superblock(%blk,scsm1)"
 else
     txt($+1)=ID+"%blk=instantiate_block('"DOLLAR_m'")"
     txt($+1)=ID+"%blk=set_block_parameters(%blk,["+sci2exp(para.X0)+";'"1'"])"
 end

endfunction
