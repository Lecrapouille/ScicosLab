function SaveasPalette_()
// Copyright INRIA

    Cmenu = [] ;
    spmode = pal_mode
    pal_mode = %t
    ierr=execstr('blk_tmp=PAL_f(''define'')','errcatch')
    if ierr<>0 then
      message('Block palette not found.')
      clear numk
      return
    end
    blk_tmp.graphics.sz=20*blk_tmp.graphics.sz
    scs_m=do_purge(scs_m)
    blk_tmp.model.rpar=scs_m
    scs_m_tmp=scicos_diagram(version=get_scicos_version())
    scs_m_tmp.objs(1) = blk_tmp
    scs_m=scs_m_tmp
    clear scs_m_tmp
    clear blk_tmp
    [scs_m,editedx] = do_SaveAs()
    scs_m=scs_m.objs(1).model.rpar
    if TCL_EvalStr('set toto [winfo exists .palettes]')=='1' then
      PalTree_
    end
    if ~super_block then edited=editedx,end
    pal_mode=spmode
endfunction
