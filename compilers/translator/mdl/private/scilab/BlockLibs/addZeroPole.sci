function txt=addZeroPole(txt,para,nin,nout)

       zer=para.Zeros
        pol=para.Poles
        gai=para.Gain

 num=gai+"*poly("+zer+",'"s'",'"root'")"
 den="poly("+pol+",'"s'",'"root'")"

      txt($+1)=ID+"%blk=instantiate_block('"CLR'")"
      txt($+1)=ID+'%exprs='+sci2exp([num,den],0)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
