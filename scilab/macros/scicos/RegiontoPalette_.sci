function RegiontoPalette_()
// Copyright INRIA
  Cmenu=[]
  if Select==[] then
    if (%win <> curwin) then
      return
    end
    [%pt, scs_m] = do_region2pal(%pt,scs_m);
  else
    if Select(1,2)<>curwin then
      return;
    end
    [%pt, scs_m] = do_select2pal(%pt, scs_m);
  end
  Cmenu='Replot';
  %pt=[];
endfunction


