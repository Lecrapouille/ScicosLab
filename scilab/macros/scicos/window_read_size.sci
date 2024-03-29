function window_read_size(gh_window)
// Copyright INRIA
   rhs = argn(2) ; //** get the number of right side arguments  
  
  if rhs==0 then 
     gh_window = gh_current_window ;   
  end  
  
  r = gh_window.figure_size ; 
  gh_window.auto_resize = "off" ; //**

  pixmap_sav=gh_window.pixmap
  gh_window.pixmap="on"

  gh_window.axes_size = scs_m.props.wpar(5:6)

  gh_window.pixmap = pixmap_sav;

  //** axes settings
  gh_axes = gh_window.children ; //** axes handle
  gh_axes.tight_limits = "on"  ; //** set the limit "gh_axes.data_bounds" in "hard mode"

  gh_axes.margins = [0,0,0,0] ;     //**


  gh_axes.data_bounds = matrix(scs_m.props.wpar(1:4),2,2)

  wrect = [0 , 0, 1, 1] ;
  gh_axes.axes_bounds = wrect ;


  dxy=min(scs_m.props.wpar(7:8),-gh_window.figure_size+gh_window.axes_size)

  xset('viewport',dxy(1),dxy(2))
				
  xselect(); //** put the current window in foreground

endfunction
