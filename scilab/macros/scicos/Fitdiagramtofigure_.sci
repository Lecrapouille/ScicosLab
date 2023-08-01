function Fitdiagramtofigure_()
// Copyright INRIA

   Cmenu=[];
   xinfo('Fit diagram to figure');
   gh_curwin = gh_current_window; //** get the handle of the current graphics window
   r = gh_curwin.figure_size;     //** acquire the current figure physical size
   rect = dig_bound(scs_m);       //** Scicos diagram size
   if rect==[] then               //** if the schematics is not defined
     return;                      //**   then return
   end
   w = (rect(3)-rect(1));
   h = (rect(4)-rect(2));
   margins = [0.02 0.02 0.02 0.02]
   %zoom_w=r(1)/(w*(1+margins(1)+margins(2)))
   %zoom_h=r(2)/(h*(1+margins(3)+margins(4)))

   //** to debug
   if %scicos_debug_gr then
     printf("zoom=%f\n",%zoom);
     printf("zoom_w=%f\n",%zoom_w);
     printf("zoom_h=%f\n",%zoom_h);
   end

   drawlater();
   clear_pixmap();
   show_pixmap();
   %zoom=min(%zoom_w,%zoom_h);

   gh_window = gcf();
   window_set_size(gh_window);
   gh_curwin = gh_window;
   if exists('%scicos_with_grid') then
     drawgrid();
     swap_handles(gh_window.children.children($),...
                  gh_window.children.children(1));
     delete(gh_window.children.children(1));
   end

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
