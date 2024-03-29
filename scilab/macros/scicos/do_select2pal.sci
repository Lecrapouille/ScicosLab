function [%pt,scs_m] = do_select2pal(%pt,scs_m)
// Copyright INRIA
  scs_m_save = scs_m
  nc_save    = needcompile ;
  keep = [] ; del = [];
  sel  = Select(:,1)'; //** vector of object selected
  nsel = setdiff(1:size(scs_m.objs),sel) ; //** list of object not selected

  //**-----------------------------------------------------------------
  //** Scan all the selected objects:   
  for bl=sel
    if typeof(scs_m.objs(bl))=='Block' | typeof(scs_m.objs(bl))=='Text' then
      keep=[keep bl]
    end //** end 'Block' filter
  end //** scan
  //**------------------------------------------------------------------

  //** scan all the object NOT selected 
  for bl=nsel
    if typeof(scs_m.objs(bl))=='Block' | typeof(scs_m.objs(bl))=='Text' then //** OK
      del = [del bl] ;
    end
  end
  
  
  prt = splitted_links(scs_m,keep,del) ; //** OK 
  [reg,DEL]=do_delete2(scs_m,del,%f)   ; //** OK 
  rect = dig_bound(reg) ;
  reg=do_purge(reg)
  
  if lstsize(reg.objs)==0 then return, end
  //superblock should not inherit the context nor the name
  reg.props.context=' ' 
  reg.props.title(1)='Palette'
  [reg,edited,ok] = do_rename(reg,%t,%t)
  if ~ ok then scs_m=scs_m_save;%pt=[];return;end
  sup = PAL_f('define')
  sup.graphics.orig   = [(rect(1)+rect(3))/2-20,(rect(2)+rect(4))/2-20]
  sup.graphics.sz     = [40 40]
  sup.model.rpar      = reg
  sup.graphics.id     = reg.props.title(1)
  [scs_m,DEL] = do_delete2(scs_m,keep,%f) //** Quick speed improvement using %f (was %t)
  drawobj(sup)
  scs_m.objs($+1)=sup

  [scs_m_save,nc_save,enable_undo,edited,needcompile,..
   needreplay]=resume(scs_m_save,nc_save,%t,%t,4,needreplay)

endfunction
