function all_scs_m=adjust_all_scs_m(scs_m_temporary,k)
// Copyright INRIA

  //## overload some functions used
  //## in modelica block compilation
  //## disable it for adjust_all_scs_m
  %mprt=funcprot()
  funcprot(0)
  deff('[ok] =  buildnewblock(blknam,files,filestan,filesint,libs,rpat,ldflags,cflags)','ok=%t')
  deff('[]   =  mprintf(v1,v2,v3,v4,v5,v6)','return')
  funcprot(%mprt)

  [bllst,connectmat,clkconnect,cor,corinv,ok]=c_pass1(scs_m_temporary);

  if ~ok then
   message('The pre-compilation has failed; the scs_m will not be adjust');
   ok=%f;
  end

  c_pass2=c_pass2;

  if ok then
   [ok,bllst]=adjust_inout(bllst,connectmat);
  end

  if ok then
    [ok,bllst]=adjust_typ(bllst,connectmat);
  end

  if ok then
    for i=1:size(corinv)

      //## the value in corinv for m_freq (smplclk)
      //## is the number of objs in scs_m + 1.

      //## disable adjust for smplclk and modelica block
      if  type(corinv(i))==15 then
        break;
      elseif corinv(i)>size(cor) then
        break
      end

      //## corinvtemp is the scs_m.objs index(ices)
      //## of the block(sblock) bllst(i)
      corinvtemp=corinv(i)

      //## scs_m_temporary is the full scs_m
      if corinvtemp(1)==k then
        scs_m_temporary=adjust_scs_m_temp(scs_m_temporary,corinvtemp,i)
      end
    end
  end

  //##return adjusted full scs_m
  all_scs_m=scs_m_temporary
endfunction
