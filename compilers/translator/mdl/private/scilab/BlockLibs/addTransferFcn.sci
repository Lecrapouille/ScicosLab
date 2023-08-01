function txt=addTransferFcn(txt,para,nin,nout)
      txt($+1)=ID+"%blk=instantiate_block('"CLR'")"
      num="poly(mtlb_fliplr("+para.Numerator+"),'"s'",'"coeff'")"
      den="poly(mtlb_fliplr("+para.Denominator+"),'"s'",'"coeff'")"
      txt($+1)=ID+'%exprs='+sci2exp([num,den],0)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
