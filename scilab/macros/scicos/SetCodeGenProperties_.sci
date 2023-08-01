function SetCodeGenProperties_()
// Copyright INRIA
  Cmenu=[]

  inside_sblock=%f
  if size(Select,1)==1 then
    if Select(1,2)==curwin then
      if typeof(scs_m.objs(Select(1,1)))=='Block' then
        if scs_m.objs(Select(1,1)).model.sim(1)=='super' | ...
           scs_m.objs(Select(1,1)).gui=='DSUPER' then
          inside_sblock=%t
        end
      end
    end
  end

  if inside_sblock then
    o=scs_m.objs(Select(1,1)).model.rpar
    [ok,codegen,edited]=do_set_codegen(o.codegen)
    if ok then
      scs_m.objs(Select(1,1)).model.rpar.codegen = codegen
    end
  else
    [ok,codegen,edited]=do_set_codegen(scs_m.codegen)
    if ok then
      scs_m.codegen = codegen
    end
  end

endfunction
