function txt=addStateSpace(txt,para,nin,nout)
      A=para.A
      B=para.B
      C=para.C
      D=para.D
      X0=para.X0

      X0="scale_IC("+X0+","+A+")"
 //     X0="(size("+X0+",1)==1)*("+X0+"(1)*ones(size("+A+",2),1))+(size("+X0+",1)~=1)*"+A+"(1)*"+X0


      [a,er]=evstr(A)

      if er==0 & isempty(a) then
        txt($+1)=ID+"%blk=instantiate_block('"GAINBLK'")"
        txt($+1)=ID+'%exprs='+sci2exp([D;"0"],0)
        txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
      else
        txt($+1)=ID+"%blk=instantiate_block('"CLSS'")"
        txt($+1)=ID+'%exprs='+sci2exp([A;B;C;D;X0],0)
        txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
      end
endfunction
