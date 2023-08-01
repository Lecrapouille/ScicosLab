function [mod,scs_m]=do_label(%pt,scs_m)
// do_block - edit a block label
// Copyright INRIA
//**
//** This code must be upgrated to NEW graphics 
//** 
  mod = %f
  win = %win;
  
  if Select==[] then
    xc = %pt(1); yc=%pt(2); %pt=[]
    K  = getblock(scs_m,[xc;yc])
    if K==[] then Cmenu=[];return,end
  else
    K=Select(:,1)';%pt=[]
    if size(K,'*')>1 | curwin<>Select(1,2) then
      message("Only one block can be selected in current window for this o"+...
	      "peration.")
      Cmenu=[];return
    end
  end
  
  o = scs_m.objs(K)
  // avoid error with links
  if typeof(o)<>'Block' then 
    message("No label can be placed on Links.")  
    return,
  end
  model = o.model
  lab = model.label
  %scs_help='Label_block'
  [ok,lab] = getvalue('Give block label','label',list('str',1),lab)
  
  //** Output 
  if ok then
    
    //** drawblock(o); //** delete the block XOR mode 
    
    lab = stripblanks(lab)
    
    if length(lab)==0 then lab=' ',end
    
    model.label = lab ;
    
    o.model = model ;
    
    scs_m.objs(K) = o ;
    
    mod = %t ;
    
    //** drawblock(o); //** draw the update block 
    
    // update graphics
    gh_curwin = gh_current_window;
    o_size = size(gh_curwin.children.children);
    gr_k=get_gri(K,o_size(1));
    drawlater();
    update_gr(gr_k,o);
    draw(gh_curwin.children);
    show_pixmap();
  
  end
endfunction
