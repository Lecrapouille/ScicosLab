function txt=addDisplay(txt,para,nin,nout)
      if para.Format=="long" then
        nt=12;nd=5
      elseif para.Format=="short" then
        nt=6;nd=3
      else
        nt=12;nd=5
        warning("Display: "+para.Format+" not supported format.")
      end
      if para.Floating~=0 then
         warning("Floating display not supported.")
      end
      if para.Decimation~="1" then
         warning("Decimation in display not supported.")
      end

      font=1,fontsize=1,colr=1,in=[-1,1]
      exprs = [sci2exp(in,0);
            string(font);
            string(fontsize);
            string(colr);
            string(nt);
            string(nd);
            string(1) ]

      txt($+1)=ID+"%blk=instantiate_block('"AFFICH_m'")"
      txt($+1)=ID+'%exprs='+sci2exp(exprs)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction
