//## adjust scs_m.objs.model with bllst
function scs_m_temporary=adjust_scs_m_temp(scs_m_temporary,corinvtemp,ind)

  //## test if we are in a sblock
  corinvtemp1=corinvtemp(1);
  corinvtemp(1)=[];
  if size(corinvtemp,'*')>0 then
   scs_m_temporary1=adjust_scs_m_temp(scs_m_temporary.objs(corinvtemp1).model.rpar,corinvtemp,ind);

   //## adjust models of blocks in sblock
   scs_m_temporary.objs(corinvtemp1).model.rpar=scs_m_temporary1;

  //## test if it's a block
  else
    scs_m_temporary.objs(corinvtemp1).model=bllst(ind);
  end
endfunction
