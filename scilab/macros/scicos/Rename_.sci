function Rename_()
// Copyright INRIA

    Cmenu = []

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
      [o,edited] = do_rename(o,%f,%f)
      scs_m.objs(Select(1,1)).model.rpar=o
    else
      [scs_m,edited] = do_rename(scs_m,%f,%t)
    end
endfunction
