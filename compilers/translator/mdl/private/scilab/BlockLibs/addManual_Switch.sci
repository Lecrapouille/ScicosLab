function txt=addManual_Switch(txt,para,nin,nout)
      txt($+1)=ID+"%blk=instantiate_block('"TKSWITCH'")"
      txt($+1)=ID+'%exprs='+sci2exp([para.sw+"+1";"1"])
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
//      txt($+1)=ID+"%blk=set_block_label(%blk,%exprs)"

 //     txt($+1)=ID+"%blk=instantiate_block('"RELAY_f'")"
 //     txt($+1)=ID+'%exprs='+sci2exp(["2";para.sw+"+1"])
 //     txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
