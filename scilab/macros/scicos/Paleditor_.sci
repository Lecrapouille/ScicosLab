function Paleditor_()
// Copyright INRIA

    Cmenu = [] ;
    
    scicos_palnew = do_edit_pal(scicos_pal);
    
    if scicos_palnew<>[] & or(scicos_palnew<>scicos_pal) then 
      
      scicos_pal = scicos_palnew
      
      if execstr('save(''.scicos_pal'',scicos_pal)','errcatch')<>0 then
	message('Cannot save .scicos_pal in current directory')
      end
    
      if TCL_EvalStr('set toto [winfo exists .palettes]')=='1' then
        PalTree_
      end

    end
endfunction
