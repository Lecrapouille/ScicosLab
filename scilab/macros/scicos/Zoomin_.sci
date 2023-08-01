function Zoomin_()
// Copyright INRIA

    Cmenu = [];
    xinfo('Zoom in');

    gh_window = gh_current_window;
    gh_curwin = gh_current_window;

    zoomfactor = 1.2
    %zoom = %zoom * zoomfactor;

    drawlater();
    clear_pixmap();
    show_pixmap();

    //** Get the current postion of the visible part of graphics in the panner.
    viewport = xget("viewport"); //** [x,y] = xget("viewport")

    //** geometrical correction: zoom in the center
    viewport = viewport * zoomfactor - 0.5 * gh_window.figure_size*(1-zoomfactor)  ;
    viewport=max([0,0],min(viewport,-gh_window.figure_size+gh_window.axes_size)) 
    window_set_size(gh_window, viewport);
    if exists('%scicos_with_grid') then
      drawgrid(); //** draw the new grid and put in the bottom of stack
      swap_handles(gh_window.children.children($), gh_window.children.children(1));
      delete(gh_window.children.children(1)); //** delete the old grid
    end
    //@@
    ko=[];
    o_size=size(gh_window.children.children)
    for i=1:o_size(1)
      if gh_window.children.children(i).type == "Text" then
        ko = [ ko; %t];
      else
        ko = [ ko; look_for_text(gh_window.children.children(i))];
      end
    end
    for i=find(ko)
      o=scs_m.objs(get_objs(i,o_size(1)));
      update_gr(i,o);
    end

    drawnow();
    show_pixmap();

    xinfo(' ');
endfunction
