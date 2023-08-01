function txt=addGain(txt,para,nin,nout)
      G=para.Gain
      satur=para("SaturateOnIntegerOverflow")
      if part(para.Multiplication,1:12)=="Element-wise" then
         G="diag("+G+")"
      end
      if satur==on then 
        meth="1"
      else
        meth="0"
      end

        txt($+1)=ID+"%blk=instantiate_block('"GAINBLK'")"
        txt($+1)=ID+'%exprs='+sci2exp([G;meth],0)
        txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"

endfunction
