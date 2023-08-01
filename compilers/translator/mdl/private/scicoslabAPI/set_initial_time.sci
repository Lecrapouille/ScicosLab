function scs_m = set_initial_time(scs_m,ti)
  if ti<>0 then 
    warning("Initial time "+ti+" is other than zero. This is not supported.")
  end
endfunction