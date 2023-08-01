function PlaceinDiagram_()
// Copyright INRIA
  global scs_m_palettes
  %pa_ = TCL_GetVar('blko');%pa_=part(%pa_,6:length(%pa_));
  %pa_ = evstr(%pa_);

  if size(%pa_)==1 then
    global ClipboardPal
    ClipboardPal=%pa_(1)
    Cmenu ='Palettes'
  else
    blk=scs_m_palettes(scs_full_path(%pa_))
    [scs_m,needcompile]=do_placeindiagram(scs_m,blk,needcompile)
    Cmenu=[]
    //scs_m=do_placeindiagram(scs_m,scs_m_palettes(scs_full_path(%pa_)))
  end
endfunction
