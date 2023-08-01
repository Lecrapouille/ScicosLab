function selecthilite(Select, flag)
// Copyright INRIA

  if Select==[] then
    return
  end

  gh_winback = gcf() //** save the active window

  // Important assumption: all Selected are in the same window
  [junk, win, o] = get_selection(Select(1,:))
  gh_curwin = scf(win); //** select current window
  kc = find( win==windows(:,2) );
  o_size = size ( gh_curwin.children.children )
  drawlater()

  for i=1:size(Select,1)
    k = Select (i,1)
    gh_k = get_gri(k,o_size(1))
    if gh_k>0 then //** To disable some crash when we have delete obj
      gh_obj = gh_curwin.children.children(gh_k)
      gh_obj.children(1).mark_mode = flag
      draw(gh_obj)
    end

  end

  draw(gh_curwin.children);
  if gh_curwin.pixmap=='on' then
    if windows(kc,1)<0 then //** RIGTH click inside a palette window
      drawnow()
    end 
    show_pixmap()
  else
    drawnow()
  end

  scf(gh_winback) //** restore the

endfunction
