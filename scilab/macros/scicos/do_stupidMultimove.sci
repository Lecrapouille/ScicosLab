function [scs_m] = do_stupidMultimove(%pt, Select, scs_m)
// Copyright INRIA
// NB : the MultiMove works ONLY in the current window
  rel=5/100
  have_moved=%f
  gh_curwin = gh_current_window ;
  xc = %pt(1)
  yc = %pt(2)
  scs_m_save = scs_m
  needreplay = replayifnecessary()
  [scs_m,have_moved] = stupid_MultiMoveObject(scs_m, Select, xc, yc)
  if Cmenu=='Quit' then [%win,Cmenu] = resume(%win,Cmenu), end
  if have_moved then
    [scs_m_save,enable_undo,edited,nc_save,needreplay] = resume(scs_m_save,%t,%t,needcompile,needreplay)
  end
endfunction

//  ---------------------------- Move Blocks and connected Link(s) ----------------------------
function [scs_m,have_moved] = stupid_MultiMoveObject(scs_m, Select, xc, yc)
  // Move Selected Blocks/Texts and Links and modify connected (external) links if any

  //** scs_m  : the local level diagram
  //** Select : matrix [object_id win_id] of selected object
  //** xc ,yc : mouse coodinate of the last valid LEFT BUTTON PRESS
  //**
  //** Select : matrix of selected object
  //**          Each line is:  [object_id win_id] : "object_id" is the same INDEX used in "scs_m.obj"
  //**                                          and "win_id"    is the Scilab window id.
  //**          Multiple selection is permitted: each object is a line of the matrix.
  //**----------------------------------------------------------------------------------
  //**
  //** the code below is modified according the new graphics API
  gh_curwin = gh_current_window ; //** acqiore the current window handle

  //** at this point I need to build the [scs_m] <-> [gh_window] datastructure
  //** I need an equivalent index for the graphics

  //** This variable is fundamental because at the end of the move the number of graphics 
  //** object MUST BE the same 
  o_size = size (gh_curwin.children.children ) ; //** o_size(1) number of "Compound" objects 

  //**-----------------------------------------------------------------------------------------------
  //** Acquire axes physical limits (visible limits are smaller) to avoid "off window" move
  figure_axes_size = gh_curwin.axes_size ; //** size in pixel
  x_f = figure_axes_size(1) ;
  y_f = figure_axes_size(2) ;

  [x1_f, y1_f, rect_f] = xchange([0, x_f],[0, y_f],"i2f"); //** convert to local coordinate

  x_min = x1_f(1) ; x_max = x1_f(2) ; //** hor. limits
  y_min = y1_f(2) ; y_max = y1_f(1) ; //** ver. limits (inverted because the upper left corner effect)
  //**-------------------------------------------------------------------------------------------------

  //** Initialization
  gh_link_i   = [];
  gh_link_mod = [];

  //**----------------------------------------------------------------------------------
  diagram_links = [] ; //** ALL the LINKs of the diagram
  diagram_size = size(scs_m.objs)
  if diagram_size<>0
    for k=1:diagram_size //** scan ALL the diagram and look for 'Link'
      if typeof(scs_m.objs(k))=="Link" then
        diagram_links = [diagram_links k]
      end
    end
  end
  //**----------------------------------------------------------------------------------
  //** Classification of selected object
  sel_block = []; //** blocks selected by the user
  sel_link  = []; //** links
  sel_text  = []; //** text

  SelectObject_id = Select(:,1)'  ; //** select all the object in the current window

  if SelectObject_id == [] then
    k=getblocktext(scs_m,[xc;yc])
    if k==[] then return, end
    SelectObject_id = k
  end

  //** scan all the selected object
  for k=SelectObject_id
    if typeof(scs_m.objs(k))=='Block' then
      sel_block = [sel_block k]
    end
    if typeof(scs_m.objs(k))=='Link' then
      sel_link = [sel_link k]
    end
    if typeof(scs_m.objs(k))=='Text' then
      sel_text = [sel_text k]
    end
  end //** end of scan

  //**----------------------------------------------------------------------------------
  int_link = []; //** link(s) involved in the move operation

  for l = diagram_links                   //** scan all links and look for external link
     from_block = scs_m.objs(l).from(1) ; //** link proprieties
       to_block = scs_m.objs(l).to(1)   ;
     //** "from" and "to" are relatives to selected blocks
      if (or(from_block==sel_block)) & (or(to_block==sel_block)) then
           int_link = [int_link l]; //** pile up
      end
  end //** end of the link scan
  //**-----------------------------------------------------------------------------------

  //**----------------------------------------------------------------------------------
  connected = []; //** ALL the Links that from/to the supercompound
  ext_block = []; //** ALL the selected blocks that have a links from/to the supercompound

  for k = sel_block //** Scan ALL the selected block and look for external link

     sig_in = scs_m.objs(k).graphics.pin' ; //** signal input
     for l = sig_in //** scan all the input
	  if (~(or(l==int_link ))) & (or(l==diagram_links)) then //** the link is not internal
            connected = [connected l]; //** add to the list of link to move
	    ext_block = [ext_block k];
	  end
     end

     sig_out = scs_m.objs(k).graphics.pout' ; //** signal output
     for l = sig_out //** scan all the output
	  if (~(or(l==int_link ))) & (or(l==diagram_links)) then // ext link
            connected = [connected l]; //** add to the list of link to move
	    ext_block = [ext_block k];
	  end
     end

     ev_in = scs_m.objs(k).graphics.pein' ;
     for l = ev_in //** scan all the output
	  if (~(or(l==int_link ))) & (or(l==diagram_links)) then // ext link
            connected = [connected l]; //** add to the list of link to move
	    ext_block = [ext_block k];
	  end
     end
	
     ev_out = scs_m.objs(k).graphics.peout' ;
     for l = ev_out //** scan all the output
	  if (~(or(l==int_link ))) & (or(l==diagram_links)) then // ext link
	    connected = [connected l]; //** add to the list of link to move
	    ext_block = [ext_block k];
	  end
     end

  end //** end of scan
  //**-----------------------------------------------------------------------------------

  //** look for all the connected link(s) and build "impiling" the two data structures
  //** [xm , ym] for the links data points
  //** gh_link_i is a vector of the associated graphic handles

  xm = []; //** init
  ym = [];
  if connected<>[] then //** check if external link are present
    for l=1:length(connected) //** scan all the connected links
      i  = connected(l)  ;
      oi = scs_m.objs(i) ;
      gh_i = get_gri(i,o_size(1)); //** calc the handle of all the connected link(s)
      gh_link_i = [ gh_link_i gh_curwin.children.children(gh_i)]; //** vector of handles
      [xl, yl, ct, from, to] = (oi.xx, oi.yy, oi.ct, oi.from, oi.to)
      if from(1)==ext_block(l) then 
        xm = [xm, [xl(2);xl(1)] ];
        ym = [ym, [yl(2);yl(1)] ];
      end

      if to(1)==ext_block(l) then
        xm = [xm, xl($-1:$) ];
        ym = [ym, yl($-1:$) ];
      end
    end
  end
  //** ----------------------------------------------------------------------

  //** Supposing that all the selected object are in the current window
  //** create a new compund that include ALL the selected object
  SuperCompound_id = [sel_block int_link sel_text] ;

  //** -----------------------------------------------------------------------
  xmt = xm ;
  ymt = ym ; //** init ...

  //** --------------------------------- MOVE BLOCK WITH CONNECTED LINKS ------------

  xco = xc;
  yco = yc;

  move_x = 0 ;
  move_y = 0 ;

  //**-------------------------------------------------------------------
  gh_link_mod = []
  tmp_data    = []
  t_xmt       = []
  t_ymt       = []

  //** ------------------------------- INTERACTIVE MOVEMENT LOOP ------------------------------

  drawlater();
  moved_dist=0
  if with_gtk() then queue_state=[],end

    while 1 do //** interactive move loop
      if with_gtk() then
        rep = xgetmouse(queue_state=[],[%t,%t])
      else
        rep = xgetmouse(0,[%t,%t])
      end
      //** left button release, right button (press, click)
      if with_gtk() then
        queue_state=1
        if rep(3)==10 then
          global scicos_dblclk
          scicos_dblclk=[rep(1),rep(2),curwin]
        end
        if or(rep(3)==[-5, 2, 3, 5]) then
          break
        end
      else
        if or(rep(3)==[-5, 2, 3, 5]) then
          break
        end
      end

      //** Window change and window closure protection
      gh_figure = gcf()
      if gh_figure.figure_id<>curwin | rep(3)==-100 then
        [%win,Cmenu] = resume(curwin,'Quit')
      end

      if %scicos_snap then
        SnapIncX = %scs_wgrid(1)
        SnapIncY = %scs_wgrid(2)
        if abs( floor(rep(1)/SnapIncX)-(rep(1)/SnapIncX) ) <...
           abs(  ceil(rep(1)/SnapIncX)-(rep(1)/SnapIncX) )
          delta_x  = floor((rep(1)-xc)/SnapIncX)*SnapIncX;
          xc = floor(rep(1)/SnapIncX)*SnapIncX ;
        else
          delta_x  = ceil((rep(1)-xc)/SnapIncX)*SnapIncX;
          xc = ceil(rep(1)/SnapIncX)*SnapIncX ;
        end
        if abs( floor(rep(2)/SnapIncY)-(rep(2)/SnapIncY) ) <...
           abs(  ceil(rep(2)/SnapIncY)-(rep(2)/SnapIncY) )
          delta_y  = floor((rep(2)-yc)/SnapIncY)*SnapIncY;
          yc = floor(rep(2)/SnapIncY)*SnapIncY ;
        else
          delta_y  = ceil((rep(2)-yc)/SnapIncY)*SnapIncY;
          yc = ceil(rep(2)/SnapIncY)*SnapIncY ;
        end
      else
        //** Mouse movement limitation: to avoid go off the screen
        if rep(1)>x_min & rep(1)<x_max
          delta_x = rep(1) - xc ; //** calc the differential position
          xc = rep(1);
        else
          delta_x = 0.0 ;
        end

        if rep(2)>y_min & rep(2)<y_max
          delta_y = rep(2) - yc ; //** calc the differential position
          yc = rep(2)
        else
          delta_y = 0.0 ;
        end
      end

      //** Integrate the movements
      move_x = move_x +  delta_x ;
      move_y = move_y +  delta_y ;

      moved_dist=moved_dist+abs(delta_x)+abs(delta_y)
      // under window clicking on a block in a different window causes a move
      if moved_dist>.001 then have_moved=%t,end

      //** Move the SuperCompound
      for k = SuperCompound_id
        gh_k = get_gri(k,o_size(1)); //** calc the handle
        gh_ToBeMoved = gh_curwin.children.children(gh_k) ;
        move (gh_ToBeMoved, [delta_x , delta_y]);  //** ..because "move()" works only in differential
      end

      if connected<>[] then  //** Move the links
        xmt(2,:) = xm(2,:) + move_x ;
        ymt(2,:) = ym(2,:) + move_y ;
        j = 0 ;
        for l=1:length(connected)
          i  = connected(l)
          oi = scs_m.objs(i)
          [xl,from,to] = (oi.xx,oi.from,oi.to);
          gh_link_mod = gh_link_i(l);
          if from(1)==ext_block(l) then
            tmp_data = gh_link_mod.children(1).data
            xx=gh_link_mod.children(1).data(:,1);yy=gh_link_mod.children(1).data(:,2)
            rect=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
            j = j + 1 ;
            t_xmt = xmt([2,1],j)
            t_ymt = ymt([2,1],j)
            gh_link_mod.children(1).data = [ [t_xmt(1) , t_ymt(1)] ; tmp_data(2:$ , 1:$) ]
            xx=gh_link_mod.children(1).data(:,1); yy=gh_link_mod.children(1).data(:,2)
            rect_now=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
            xx=gh_link_mod.children(2).data(:,1)
            yy=gh_link_mod.children(2).data(:,2)
            gh_link_mod.children(2).data=[xx - (rect(1)-rect_now(1)), yy - (rect(2)-rect_now(2)) ]
          end

          if to(1)==ext_block(l) then
            tmp_data = gh_link_mod.children(1).data ;
            xx=gh_link_mod.children(1).data(:,1); yy=gh_link_mod.children(1).data(:,2)
            rect=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
            j = j + 1 ;
            gh_link_mod.children(1).data = [ tmp_data(1:$-2 , 1:$) ; [xmt(:,j) , ymt(:,j)] ]  ;
            xx=gh_link_mod.children(1).data(:,1);yy=gh_link_mod.children(1).data(:,2)
            rect_now=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
            xx=gh_link_mod.children(2).data(:,1)
            yy=gh_link_mod.children(2).data(:,2)
            gh_link_mod.children(2).data=[xx - (rect(1)-rect_now(1)), yy - (rect(2)-rect_now(2)) ]
          end
        end
      end

      draw(gh_curwin.children); //** draw ALL the moving objects
      show_pixmap();
    end //** ... of while Interactive move LOOP --------------------------------------------------------------

    //**-----------------------------------------------
    gh_figure = gcf();
    if gh_figure.figure_id<>curwin | rep(3)==-100 then
         [%win,Cmenu] = resume(curwin,'Quit') ;
    end
    //**-----------------------------------------------

    //** OK If update and block and links position in scs_m

    //** if the exit condition is NOT a right button press OR click
    if and(rep(3)<>[2 5]) then //** update the data structure
      //** Rigid SuperCompund Elements
      block=[];

      for k = sel_block
           block = scs_m.objs(k)    ;
	   xy_block = block.graphics.orig ;
	   xy_block(1) = xy_block(1) + move_x ;
	   xy_block(2) = xy_block(2) + move_y ;
	   block.graphics.orig = xy_block ;
	   scs_m.objs(k) = block; //update block coordinates
      end

      text=[]
      for k = sel_text
           text = scs_m.objs(k)
	   xy_text = text.graphics.orig ;
           xy_text(1) = xy_text(1) + move_x ;
	   xy_text(2) = xy_text(2) + move_y ;
	   text.graphics.orig = xy_text;
	   scs_m.objs(k) = text; //update block coordinates
      end

      link_=[]
      for l = int_link
           link_= scs_m.objs(l)
           [xl, yl] = (link_.xx, link_.yy)
	   xl = xl + move_x ;
	   yl = yl + move_y ;
	   link_.xx = xl ; link_.yy = yl ;
	   scs_m.objs(l) = link_ ; 
      end

      //** Flexible Link elements
      if connected<>[] then
          j = 0 ;
          for l=1:length(connected)
             i  = connected(l)  ;
             oi = scs_m.objs(i) ;
             [xl,from,to] = (oi.xx,oi.from,oi.to);

             if from(1)==ext_block(l) then
               j = j + 1 ;
               oi.xx(1:2) = xmt([2,1],j) ;
               oi.yy(1:2) = ymt([2,1],j) ;
             end

             if to(1)==ext_block(l) then
               j = j + 1 ;
               oi.xx($-1:$) = xmt(:,j) ;
               oi.yy($-1:$) = ymt(:,j) ;
             end
              scs_m.objs(i) = oi ; //** update the datastructure 
           end //... for loop
      end //** of if
      //**---------------------------------------------------
      if size(sel_block,2)==1&length(connected)==1 then
       k = sel_block
       lk = scs_m.objs(connected(1))

       moving=0
       if size(lk.xx,'*')==2 then
        dx=lk.xx(1)-lk.xx(2);dy=lk.yy(1)-lk.yy(2);
        if abs(dx)<rel*abs(dy) then
          dy=0;moving=1
        elseif abs(dy)<rel*abs(dx) then
          dx=0;moving=1
        end

        if moving then
           if lk.to(1)==k then
             scs_m.objs(k).graphics.orig=scs_m.objs(k).graphics.orig+[dx,dy]
             lk.xx(2)=lk.xx(2)+dx;lk.yy(2)=lk.yy(2)+dy
             scs_m.objs(connected(1))=lk
             gh_link_mod = gh_link_i(1)
             gh_link_mod.children(1).data(2,:)=gh_link_mod.children(1).data(2,:)+[dx,dy]
           elseif lk.from(1)==k  then
             scs_m.objs(k).graphics.orig=scs_m.objs(k).graphics.orig-[dx,dy]
             lk.xx(1)=lk.xx(1)-dx;lk.yy(1)=lk.yy(1)-dy
             dx=-dx;dy=-dy
             scs_m.objs(connected(1))=lk
             gh_link_mod = gh_link_i(1)
             gh_link_mod.children(1).data(1,:)=gh_link_mod.children(1).data(1,:)+[dx,dy]
           else
             Cmenu=resume('Replot') // graphics inconsistent with scs_m
           end
        end
       end

       if moving then
        o_size = size(gh_curwin.children.children); //** the size:number of all the object
        gh_k=get_gri(k,o_size(1))
        gh_blk = gh_curwin.children.children(gh_k); //** new
        move(gh_blk,[dx,dy]);  //** ..because "move()" works only in differential
        draw(gh_blk.parent);
        draw(gh_curwin.children);
        show_pixmap();
       end
      end

    //**=---> If the user abort the operation
    else //** restore original position of block and links in figure
         //** in this case: [scs_m] is not modified !
      drawlater();

        //** Move back the SuperCompound
        for k = SuperCompound_id 
          gh_k = get_gri(k,o_size(1)); //** calc the handle 
          gh_ToBeMoved = gh_curwin.children.children(gh_k) ;
	  move (gh_ToBeMoved, [-move_x , -move_y]);  //** ..because "move()" works only in differential
        end

	//**-------------------------------------------------------
        if connected<>[] then 
	    xmt(2,:) = xm(2,:);  //** original datas of links
            ymt(2,:) = ym(2,:);
            j = 0 ; //** init
            for l=1:length(connected)
               i  = connected(l)  ;
               oi = scs_m.objs(i) ;
               [xl,from,to] = (oi.xx,oi.from,oi.to);
               gh_link_mod = gh_link_i(l) ; // get the link graphics data structure

               if from(1)==ext_block(l) then
                 xx=gh_link_mod.children(1).data(:,1); yy=gh_link_mod.children(1).data(:,2)
                 rect=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
                 tmp_data = gh_link_mod.children(1).data ;
                 j = j + 1 ;
                 t_xmt = xmt([2,1],j) ;  t_ymt = ymt([2,1],j) ;
                 gh_link_mod.children(1).data = [ [t_xmt(1) , t_ymt(1)] ; tmp_data(2:$ , 1:$) ];
                 xx=gh_link_mod.children(1).data(:,1); yy=gh_link_mod.children(1).data(:,2)
                 rect_now=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
                 xx=gh_link_mod.children(2).data(:,1)
                 yy=gh_link_mod.children(2).data(:,2)
                 gh_link_mod.children(2).data=[xx - (rect(1)-rect_now(1)), yy - (rect(2)-rect_now(2)) ]
               end

               if to(1)==ext_block(l) then
                 xx=gh_link_mod.children(1).data(:,1); yy=gh_link_mod.children(1).data(:,2)
                 rect=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
                 tmp_data = gh_link_mod.children(1).data ;
                 j = j +  1 ;
                 gh_link_mod.children(1).data = [ tmp_data(1:$-2 , 1:$) ; [xmt(:,j) , ymt(:,j)] ];
                 xx=gh_link_mod.children(1).data(:,1); yy=gh_link_mod.children(1).data(:,2)
                 rect_now=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
                 xx=gh_link_mod.children(2).data(:,1)
                 yy=gh_link_mod.children(2).data(:,2)
                 gh_link_mod.children(2).data=[xx - (rect(1)-rect_now(1)), yy - (rect(2)-rect_now(2)) ]
               end
             end //... for loop
          end //** of if
         //**------------------------------------------------------

      draw(gh_curwin.children);
      show_pixmap();

    end //**----------------------------------------

endfunction
//**--------------------------------------------------------------------------

