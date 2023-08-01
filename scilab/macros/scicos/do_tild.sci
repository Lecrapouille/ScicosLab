function [%pt, scs_m] = do_tild(%pt, scs_m)
// Copyright INRIA
//**  BEWARE: this version has some residual graphical bug with some 
//**          Modelica electrical connected blocks
//* 

  xc = %pt(1) ;
  yc = %pt(2) ;
  k = getblock(scs_m, [xc;yc]) ; //** try to recover the block over the "click" coordinate 

  if k<>[] then
  
    //** A valid block index is found 
    scs_m_save = scs_m ; //** save the diagram for "Undo" ...
    
    //**--------- scs_m object manipulation -------------------
  
    path = list('objs',k)      ; //** acquire the index in the "global" diagram
  
    //** I need to flip the old object before the new one - in order to export 
    //** the right I/O ports  geometric coordinates - because the new one
    //** hinerit its geometric proprieties 
    o = scs_m.objs(k)    ; //** the old object 
    o_geom = o.graphics  ; //** isolate the geometric proprieties 
    o_geom.flip = ~o_geom.flip ; //** flip the object 
    o.graphics = o_geom; //** update the old object
    scs_m.objs(k) = o ;  //** update the diagram 
       
    o_n  = o ; //** "o" is already flipped  
    
    scs_m = changeports(scs_m, path, o_n); 
  
    [scs_m_save, enable_undo, edited] = resume(scs_m_save, %t, %t)
  
  else 

    return ; //** EXIT: if you click in the void ... just return back
  
  end 
  
  
endfunction
