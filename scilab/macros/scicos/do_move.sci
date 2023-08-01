function [scs_m] = do_move(%pt, scs_m)
//** Copyright INRIA
//**
//** get a scicos object to move, and move it with connected objects
//**
//** Acquire the current window
  gh_curwin = gh_current_window ;

//** get block to move
  win = %win  ; //** recover 'clicked' window
  xc  = %pt(1);
  yc  = %pt(2); //** recover mouse position at the last event

  //** look for a valid object 
  [k,wh] = getobj(scs_m,[xc;yc]) ;
  //** "k" is the index of the object in the data structure "scs_m"
  //** "wh" is a parameter valid ONLY for the links:
  //**       if negative polyline closest point is a polyline corner: pt = [xp(-ind) yp(-ind)]
  //**       if positive pt lies on segment [ind ind+1]
  //**
  //** "wh" shortcut for "where", ia an INDEX for the polyline matrix that contains
  //**      the polylines coordinate.
  //**      If "wh" is positive means that the user has clicked near a link segment:
  //**          the 'wh' INDEX point to starting point of the segment clicked ;
  //**      If "wh" is negative means that the user has clicked near a corner,
  //**          then 'wh' is the INDEX of that corner coordinates
  //**

  if k==[] then
    return
  end ; //** if NO object found -> exit

  Cmenu = check_edge(scs_m.objs(k),"Smart Move",%pt);
  if Cmenu=="Link" then
     Cmenu=resume("Smart Link")
  end

  scs_m_save = scs_m ; //** save the diagram

  //**-------------------- Block or Text ---------------------------------
  if typeof(scs_m.objs(k))=='Block' | typeof(scs_m.objs(k))=='Text' then
    needreplay = replayifnecessary() ;    //** to be removed later (obsolete)
    scs_m = moveblock(scs_m, k, xc, yc) ; //** see below in the code

  //**------------------- Link ------------------------------
  elseif typeof(scs_m.objs(k))=='Link' then
   //** filter the two possible link cases
    if wh>0 then
      // if positive 'pt' lies on segment [ind ind+1] where 'ind = wh; '
      if %scicos_debug_gr
        disp ("SmartMove:Link:-->Segment... wh= "); disp(wh) ;
      end
      
      scs_m = movelink(scs_m, k, xc, yc, wh); //** tmp disbled for debug

    else
      // if 'wh' is negative, the polyline closest point is a polyline corner of
      //**  coordinate pt = [xp(-ind) yp(-ind)] ,   where 'ind = wh;'
      //** WARNING:  the "dist2polyline" routine has some corner detection problems
      if %scicos_debug_gr
        disp ("SmartMove:Link:-->Corner...wh= "); disp(wh) ;
      end
      scs_m = movecorner(scs_m,k,xc,yc,wh) ; //** tmp disbled for debug
    end
   //**-------------------------------------------------------
  end

  if Cmenu=='Quit' then
       //active window has been closed
       [%win,Cmenu] = resume(%win,Cmenu) ;
  end
  if %scicos_debug_gr
    disp ("SmartMove:...End") ;
  end

  [scs_m_save,enable_undo,edited,nc_save,needreplay] = resume(scs_m_save,%t,%t,needcompile,needreplay);

endfunction
//**---------------------------------------------------------------------------------------------------------


function scs_m = moveblock(scs_m,k,xc,yc)
// Move  block 'k' and modify connected links if any
//
//** This code handle the case of moving a block with connectected link(s)
//** The code has three section:
//** - find the link id, filter the three possible cases of link(s), prepare matrix where each
//**   column represent the (x,y) coordinate of the link corner
//** - interactive move of block (replace by an empty box to speed the moving operation)
//** - if the move is valid, update the scs_m data structure with the new object coordinates    
//**----------------------------------------------------------------------------------------------
  //** The code below is modified according the new graphics API

  //** For the first time I try to use the XOR mode for the intaractive part of the SmartMove
  //** changing "gh_curwin.pixel_drawing_mode

  //** pixel_drawing_mode: This field defines the bitwise operation used to draw the pixel on the
  //** screen. The default mode is 'copy' what is to say the pixel is drawn as required.
  //** More generally the bitwise operation is performed between the color of the source pixel and
  //** the color of the pixel already present on the screen.
  //** Operations are :
  //** 	"clear"       ,
  //** 	"and"         ,
  //** 	"andReverse"  ,
  //** 	"copy"        , <------- Normal operation 
  //** 	"andInverted" ,
  //** 	"noop"        ,
  //** 	"xor"         , <------- Interactive move (used to visually delete object) 
  //** 	"or"          ,
  //** 	"nor"         ,
  //** 	"equiv"       ,
  //** 	"invert"      ,
  //** 	"orReverse"   ,
  //** 	"copyInverted",
  //** 	"orInverted"  ,
  //** 	"nand"        ,
  //** 	"set"         , 
//**-----------------------------------------------------------------------------------

//**-----------------------------------------------------------------------------------
  gh_curwin = gh_current_window ;
  drawlater(); //** stay in drawlater mode

  //** at this point I need to build the [scs_m] <-> [gh_window] datastructure 
  //** I need an equivalent index for the graphics

  o_size = size (gh_curwin.children.children ) ; //** the size: number of all the object

  //** "k" is the object index in the data structure "scs_m"
  //** compute the equivalent "gh_k" for the graphics datastructure
  //gh_k = o_size(1) - k + 1 ; //** semi empirical equation :)
  gh_k=get_gri(k,o_size(1))
  gh_blk = gh_curwin.children.children(gh_k);

//**-----------------------------------------------------------------------------------
//
//** Save the mouse position at the beginning of the operation
     xo_mouse = xc ;
     yo_mouse = yc ;
//
//**-----------------------------------------------------------------------------------------------
//** This code segment find the Block and the Links to move; classify link in three type 
//** type :
//**        "0" : if the Link start from the Block and end in the same Block (the "Perverted Link");
//**        "1" : if the Link start from the Block ( the "Outgoing Link")
//**       "-1" : if the Link end in the Block ( the "Ingoing Link")
//**
//** The "link type" is stored as vector in 'ii'
//**
//** Create the 'xx' 'yy' matrix that contain the coordinate of the
//**
// Move  block 'k' and modify connected links if any
// look at connected links

  connected = unique(get_connected(scs_m,k)) ; //** connected links
  o  = scs_m.objs(k) ; //** block

  xx = [] ;//** matrix of the 'x' coordinate of the moving link(s)
  yy = [] ;//**               'y'
  ii = [] ;//** three value vector (link type, see above)
  mx = [] ;//** ?
  my = [] ;//** ?

  // build movable segments for all connected links

  gh_objs_invisible = [] ; //** vector of handles of object(s) that I need put invisible
                           //** during the intaractive move

  clr_nrm = [] ;//** vector that specify the 'color' of the normal (in & out) moving link(s)
  clr_per = [] ;//** vector that specify the 'color' of the perverted (in & out over same block) moving link(s)
                //** This variable is not used because each perverted link is handled separately

  //===============================================
  // look at connected links
  //** This loop classify the links and store the coordinates used for the move
  tobedrawn_out=[]
  tobedrawn_in=[]
  for i=connected
    oi = scs_m.objs(i) ; //**
    [xl, yl, ct, from, to] = (oi.xx, oi.yy, oi.ct, oi.from, oi.to)
    nl = prod(size(xl))
    if from(1)==k&to(1)==k then
    //** if the Link start from the Block and end in the same Block (the "Perverted Link")
      //move all link
      ii=[ii 0]
      clr_per = [clr_per ct(1)]; //** update the color vector

    elseif from(1)==k then
    //** if the Link start from the Block ( the "Outgoing Link")
      ii=[ii 1] ;
      clr_nrm = [clr_nrm ct(1)] ; //** update the color vector
      // build movable segments for this link
      if nl>=4 then
	x1=xl(1:4)
	y1=yl(1:4)
        if nl>4 then
          tobedrawn_out=[tobedrawn_out i]
        end
      elseif nl==3 then
	// 3 points link add one point at the begining
	x1=xl([1 1:3])
	y1=yl([1 1:3])
      elseif xl(1)==xl(2)|yl(1)==yl(2) then 
	// vertical or horizontal 2 points link, add a point in the middle
        arand=2+rand();
	x1=[xl(1);xl(1)+(xl(2)-xl(1))/arand;xl(1)+(xl(2)-xl(1))/arand;xl(2)]
	y1=[yl(1);yl(1)+(yl(2)-yl(1))/arand;yl(1)+(yl(2)-yl(1))/arand;yl(2)]
      else
	// oblique 2 points link add 2 points in the middle
        arand=2+rand();
        if abs(xl(2)-xl(1))>abs(yl(2)-yl(1)) then
          x1=[xl(1);xl(1)+(xl(2)-xl(1))/arand;xl(1)+(xl(2)-xl(1))/arand;xl(2)]
          y1=[yl(1);yl(1);yl(2);yl(2)]
        else
          x1=[xl(1);xl(1);xl(2);xl(2)]
          y1=[yl(1);yl(1)+(yl(2)-yl(1))/arand;yl(1)+(yl(2)-yl(1))/arand;yl(2)]
        end
      end
      //set allowed (x or y) move for each points of build movable segments
      if nl==3 then
	if xl(1)==xl(2) then
	  mx=[mx,[1;1;1;0]]
	  my=[my,[1;1;0;0]]
	else
	  mx=[mx,[1;1;0;0]]
	  my=[my,[1;1;1;0]]
	end
      else
        if nl==2 then
          if abs(xl(2)-xl(1))>abs(yl(2)-yl(1)) then
            mx=[mx,[1;0;0;0]]
            my=[my,[1;1;0;0]]
          else
            mx=[mx,[1;1;0;0]]
            my=[my,[1;0;0;0]]
          end
        else
          if xl(1)==xl(2) then
            mx=[mx,[1;1;0;0]]
	    my=[my,[1;0;0;0]]
          else
            mx=[mx,[1;0;0;0]]
            my=[my,[1;1;0;0]]
          end
	end
      end
      xx=[xx x1];yy=[yy y1]  //store  movable segments for this link

    else
    //** if the Link end in the Block ( the "Ingoing Link")
      ii=[ii -1]; //** add a '-1' element to the 'ii' vector
      clr_nrm = [clr_nrm ct(1)] ; //** update the color vector

      // build movable segments
      if nl>=4 then
	x1=xl(nl:-1:nl-3)
	y1=yl(nl:-1:nl-3)
        if nl>4 then
          tobedrawn_in=[tobedrawn_in i]
        end
      elseif nl==3 then 
	// 3 points link add one point at the end
	sel=[nl:-1:nl-2,nl-2]
	x1=xl([nl nl:-1:nl-2])
	y1=yl([nl nl:-1:nl-2])
      elseif xl(1)==xl(2)|yl(1)==yl(2) then
	// vertical or horizontal 2 points link add a point in the middle
	xm=xl(2)+(xl(1)-xl(2))/2
	x1= [xl(2);xm;xm;xl(1)]
	ym=yl(2)+(yl(1)-yl(2))/2;
	y1= [yl(2);ym;ym;yl(1)]
      else
	// oblique 2 points link add 2 points in the middle
        if abs(xl(2)-xl(1))>abs(yl(2)-yl(1)) then
          x1=[xl(2);xl(2)+(xl(1)-xl(2))/2;xl(2)+(xl(1)-xl(2))/2;xl(1)]
          y1=[yl(2);yl(2);yl(1);yl(1)]
        else
          x1=[xl(2);xl(2);xl(1);xl(1)]
          y1=[yl(2);yl(2)+(yl(1)-yl(2))/2;yl(2)+(yl(1)-yl(2))/2;yl(1)]
        end
      end
      if nl==3 then
	if x1(2)==x1(3) then 
	  mx=[mx,[1;1;1;0]]
	  my=[my,[1;1;0;0]]
	else
	  mx=[mx,[1;1;0;0]]
	  my=[my,[1;1;1;0]]
	end
      else
        if nl==2 then
          if abs(xl(2)-xl(1))>abs(yl(2)-yl(1)) then
            mx=[mx,[1;0;0;0]]
            my=[my,[1;1;0;0]]
          else
            mx=[mx,[1;1;0;0]]
            my=[my,[1;0;0;0]]
          end
        else
          if x1(1)==x1(2) then
            mx=[mx,[1;1;0;0]]
            my=[my,[1;0;0;0]]
          else
            mx=[mx,[1;0;0;0]]
            my=[my,[1;1;0;0]]
          end
        end
      end
      xx=[xx x1];yy=[yy y1] //store  movable segments for this link
    end

  end //** end of 'connected' link classification 

  // move a block and connected links
  //=================================
  [mxx,nxx] = size(xx)

  if connected<>[] then // move a block and connected links

    drawlater(); //** postpone the drawing

    [xmin,ymin] = getorigin(o) ;
    xc = xmin ;
    yc = ymin ;

    [xy,sz] = (o.graphics.orig,o.graphics.sz)

    //** clear block
    gr_k=get_gri(k,o_size(1))
    gh_block_invisible = gh_curwin.children.children(gr_k)
    gh_block_invisible.visible = "off" //** put the block invisible
    gh_objs_invisible = [gh_objs_invisible gh_block_invisible] //** add at the list

    //** clear links
    for i=connected
      gr_k=get_gri(i,o_size(1))
      gh_link_invisible = gh_curwin.children.children(gr_k)
      gh_link_invisible.visible = "off" //** put the link invisible
      gh_objs_invisible = [gh_objs_invisible gh_link_invisible] //** add at the list
    end

    //** This vector contains the handle(s) of the temporary object(s)
    //** created and used for the SmartMove; these object(s) are erased
    //** at the end of operation
    gh_interactive_move = [] ; //** initialize the object vector


    //@@ plot additionnal segments
    if tobedrawn_out<>[] then
      for i=tobedrawn_out
        x1 = scs_m.objs(i).xx(4:$)
        y1 = scs_m.objs(i).yy(4:$)
        xpoly(x1,y1)
        gh_poly = gce()
        if MSDOS then
          gh_poly.foreground = -2
          gh_poly.line_style  = 4
        else
          gh_poly.foreground = scs_m.objs(i).ct(1);
          gh_poly.line_style  = 2
        end
        draw(gh_poly)
        gh_interactive_move = [gh_interactive_move gh_poly]
      end
    end
    if tobedrawn_in<>[] then
      for i=tobedrawn_in
        x1 = scs_m.objs(i).xx(1:$-3)
        y1 = scs_m.objs(i).yy(1:$-3)
        xpoly(x1,y1)
        gh_poly = gce()
        if MSDOS then
          gh_poly.foreground = -2
          gh_poly.line_style  = 4
        else
          gh_poly.foreground = scs_m.objs(i).ct(1);
          gh_poly.line_style  = 2
        end
        draw(gh_poly)
        gh_interactive_move = [gh_interactive_move gh_poly]
      end
    end

  //  drawnow();
  //  show_pixmap();
    drawlater();

    gh_curwin.pixel_drawing_mode="xor"

    //** Create the empty block rectangle and store the handles
    //** rectangle (block)
    obj=o
    if MSDOS then
      obj.graphics.gr_i='xset('"foreground'",-2);xset('"line style'",4);xrect(xc, yc+sz(2), sz(1), sz(2));'
    else
      obj.graphics.gr_i='xset('"line style'",2);xrect(xc, yc+sz(2), sz(1), sz(2));'
    end
    %mprt=funcprot()
    funcprot(0)
    std_draw = standard_draw;
    deff('[] = standard_draw(o, frame, draw_ports, up)',...
         '[lhs,rhs] = argn(0);'+...
         'if rhs == 1 then std_draw(o,%f), end;'+...
         'if rhs == 2 then std_draw(o,%f), end;'+...
         'if rhs == 3 then std_draw(o,%f,draw_ports), end;'+...
         'if rhs == 4 then std_draw(o,%f,draw_ports,up), end;' )
    drawobj(obj)
    funcprot(%mprt)
    clear standard_draw
    clear obj
    gh_rect_bloc = gce()
    gh_interactive_move = [gh_interactive_move gh_rect_bloc]

    //** --------> perverted links <----------------------------------
    //** the 'perverted' links are handled as full link
    full_move = connected(find(ii==0))
    for i=full_move
      oi = scs_m.objs(i);
      xpoly( oi.xx+(xc-xmin), oi.yy+(yc-ymin) )
      gh_poly_perlink(i) = gce()
      if MSDOS then
        gh_poly_perlink(i).foreground = -2
        gh_poly_perlink(i).line_style  = 4
      else
        gh_poly_perlink(i).foreground = oi.ct(1)
        gh_poly_perlink(i).line_style  = 2
      end
      gh_interactive_move = [gh_interactive_move gh_poly_perlink(i)]
    end

    //** normal "InGoing" and "Outgoing" links
    //** xpolys(xx + mx*(xc-xmin), yy+my*(yc-ymin),clr);
    ngxx = xx+mx*(xc-xmin) ; ngyy = yy+my*(yc-ymin) ;
    v_isopoly = size(clr_nrm) ; isopoly = v_isopoly(2) ;
    for i=1:isopoly
       ngx = ngxx(:,i) ; ngy = ngyy(:,i) ; //** isolate the column vector
       xpoly( ngx, ngy )
       gh_poly_stdlink(i) = gce()
       if MSDOS then
         gh_poly_stdlink(i).foreground = -2
         gh_poly_stdlink(i).line_style  = 4
       else
         gh_poly_stdlink(i).foreground = clr_nrm(i)
         gh_poly_stdlink(i).line_style = 2
       end
       gh_interactive_move = [gh_interactive_move gh_poly_stdlink(i)]
    end

    //**---------- Interactive Move loop ----------------------------------------

    //** These variables are used to emulate the "incremental" move in order to avoid the
    //** the "block and links postion step" at the beginning of the move
    //** This sophisitication is not necessary for the link because you need to place the
    //** mouse EXACTLY on the link to move it (insteas
    delta_x = 0 ;
    delta_y = 0 ;
    if with_gtk() then queue_state=[],end
    already_draw=%f

    while 1
      if with_gtk() then
        rep = xgetmouse(queue_state=[],[%t,%t])
      else
        rep = xgetmouse(0,[%t,%t])
      end

      if with_gtk() then
        queue_state=1
        if rep(3)==10 then
          global scicos_dblclk
          scicos_dblclk=[rep(1),rep(2),curwin]
        end
        if or(rep(3)==[0,-5, 2, 3, 5]) then
          break
        end
      else
        if or(rep(3)==[0,2,3,5,-5 995]) then
          break ; //** ---> EXIT point of the while
        end
      end

      if rep(3)==-100 then //active window has been closed
        [%win,Cmenu] = resume(curwin,'Quit')
      end

      //**-------------------------------------------------------
      // draw block shape
      move(gh_rect_bloc, [delta_x , delta_y],"alone"); //** move the empty rectangle (block)
      draw(gh_rect_bloc);

      // draw normal moving links
      ngxx = xx+mx*(xc-xmin) ; ngyy = yy+my*(yc-ymin) ;
      for i=1:isopoly
         ngx = ngxx(:,i) ; ngy = ngyy(:,i)
         gh_poly_stdlink(i).data = [ngx ngy]
         draw(gh_poly_stdlink(i))
      end

      // draw perverted moving link
      for i=full_move
        oi = scs_m.objs(i)
        gh_poly_perlink(i).data = [oi.xx+(xc-xmin)  oi.yy+(yc-ymin) ]
        draw(gh_poly_perlink(i))
      end

      show_pixmap();

      draw(gh_rect_bloc);
      for i=1:isopoly
        draw(gh_poly_stdlink(i))
      end
      for i=full_move
        draw(gh_poly_perlink(i))
      end

      if %scicos_snap then
        SnapIncX = %scs_wgrid(1)
        SnapIncY = %scs_wgrid(2)
        if abs( floor(rep(1)/SnapIncX)-(rep(1)/SnapIncX) ) <...
           abs(  ceil(rep(1)/SnapIncX)-(rep(1)/SnapIncX) )
          delta_x  = floor((rep(1)-xo_mouse)/SnapIncX)*SnapIncX;
          xo_mouse = floor(rep(1)/SnapIncX)*SnapIncX ;
        else
          delta_x  = ceil((rep(1)-xo_mouse)/SnapIncX)*SnapIncX;
          xo_mouse = ceil(rep(1)/SnapIncX)*SnapIncX ;
        end
        if abs( floor(rep(2)/SnapIncY)-(rep(2)/SnapIncY) ) <...
           abs(  ceil(rep(2)/SnapIncY)-(rep(2)/SnapIncY) )
          delta_y  = floor((rep(2)-yo_mouse)/SnapIncY)*SnapIncY;
          yo_mouse = floor(rep(2)/SnapIncY)*SnapIncY ;
        else
          delta_y  = ceil((rep(2)-yo_mouse)/SnapIncY)*SnapIncY;
          yo_mouse = ceil(rep(2)/SnapIncY)*SnapIncY ;
        end
      else
        delta_x  = rep(1) - xo_mouse
        delta_y  = rep(2) - yo_mouse
        xo_mouse = rep(1)
        yo_mouse = rep(2)
      end

      xc = xc + delta_x ; //** update the absolute coordinate of the object
      yc = yc + delta_y ;

      xy = [xc, yc] ;

    end //** ... end of while() loop
    //**-----------------------------------------------------------

    gh_curwin.pixel_drawing_mode="copy"

    //** delete all the object used during the interc move
    delete(gh_interactive_move);
    if %scicos_debug_gr then
      disp("SmartMoveConnLink:End_Interactive_Loop"); //** debug only
    end

    gh_figure = gcf();
    if gh_figure.figure_id<>curwin | rep(3)==-100 then
      [%win,Cmenu] = resume(curwin,'Quit') ;
    end

    if and(rep(3)<>[2 5]) then
      //update  block
      o.graphics.orig = xy
      scs_m.objs(k)   = o
      gr_k = get_gri(k,o_size(1))
      update_gr(gr_k,o)

      //udate moved links in scicos structure
      xx = xx+mx*(xc-xmin)
      yy = yy+my*(yc-ymin)
      i  = 0
      for i1=1:prod(size(ii))
        oi = scs_m.objs(connected(i1))
        xl = oi.xx
        yl = oi.yy
        nl = prod(size(xl))
        if ii(i1)>0 then
          i = i+1
          if nl>=4 then
            xl(1:4) = xx(:,i)
            yl(1:4) = yy(:,i)
          elseif nl==3 then
            xl = xx(2:4,i)
            yl = yy(2:4,i)
          else
            xl = xx(:,i)
            yl = yy(:,i)
          end
        elseif ii(i1)<0 then
          i = i+1
          if nl>=4 then
            xl(nl-3:nl) = xx(4:-1:1,i)
            yl(nl-3:nl) = yy(4:-1:1,i)
          elseif nl==3 then
            xl = xx(4:-1:2,i)
            yl = yy(4:-1:2,i)
          else
            xl = xx(4:-1:1,i)
            yl = yy(4:-1:1,i)
          end
        else //full move
          xl = xl+(xc-xmin)
          yl = yl+(yc-ymin)
        end
        nl = prod(size(xl))
        //eliminate double points
        kz = find((xl(2:nl)-xl(1:nl-1))^2+(yl(2:nl)-yl(1:nl-1))^2==0)
        xl(kz) = []
        yl(kz) = []
        //store
        oi.xx = xl;
        oi.yy = yl;
        scs_m.objs(connected(i1)) = oi;
        gr_k = get_gri(connected(i1),o_size(1))
        update_gr(gr_k,oi)
      end
    end

    //** display block
    gr_k = get_gri(k,o_size(1))
    gh_block = gh_curwin.children.children(gr_k)
    gh_block.visible = "on" //** put the block visible

    //** display links
    for i=connected
      gr_k=get_gri(i,o_size(1))
      gh_link = gh_curwin.children.children(gr_k)
      gh_link.visible = "on" //** put the link visible
    end

    draw(gh_curwin.children)
    show_pixmap()

  else // move an unconnected block

    if %scicos_debug_gr then
      disp("SmartMove : Move block without links"); //** debug only
    end

    [xy, sz]=(o.graphics.orig, o.graphics.sz)
    xc=xy(1)
    yc=xy(2)
    delta_x=0
    delta_y=0
    drawlater()
    rep(3)=-1
    while rep(3)==-1
      rep = xgetmouse(0,[%t,%t])

      if rep(3)==-100 then [%win,Cmenu]=resume(curwin,"Quit"), end

      move (gh_blk , [delta_x , delta_y])
      draw(gh_blk.parent)
      show_pixmap()

      if %scicos_snap then
        SnapIncX = %scs_wgrid(1)
        SnapIncY = %scs_wgrid(2)
        if abs( floor(rep(1)/SnapIncX)-(rep(1)/SnapIncX) ) <...
           abs(  ceil(rep(1)/SnapIncX)-(rep(1)/SnapIncX) )
          delta_x  = floor((rep(1)-xo_mouse)/SnapIncX)*SnapIncX;
          xo_mouse = floor(rep(1)/SnapIncX)*SnapIncX ;
        else
          delta_x  = ceil((rep(1)-xo_mouse)/SnapIncX)*SnapIncX;
          xo_mouse = ceil(rep(1)/SnapIncX)*SnapIncX ;
        end
        if abs( floor(rep(2)/SnapIncY)-(rep(2)/SnapIncY) ) <...
           abs(  ceil(rep(2)/SnapIncY)-(rep(2)/SnapIncY) )
          delta_y  = floor((rep(2)-yo_mouse)/SnapIncY)*SnapIncY;
          yo_mouse = floor(rep(2)/SnapIncY)*SnapIncY ;
        else
          delta_y  = ceil((rep(2)-yo_mouse)/SnapIncY)*SnapIncY;
          yo_mouse = ceil(rep(2)/SnapIncY)*SnapIncY ;
        end
      else
        delta_x  = rep(1) - xo_mouse
        delta_y  = rep(2) - yo_mouse
        xo_mouse = rep(1)
        yo_mouse = rep(2)
      end
      xc=xc + delta_x
      yc=yc + delta_y
      xy=[xc, yc]
    end

    gh_figure = gcf()
    if gh_figure.figure_id<>curwin | rep(3)==-100 then
      [%win,Cmenu] = resume(curwin,'Quit')
    end
    // update and draw block
    if and(rep(3)<>[2 5]) then
      o.graphics.orig=xy
      scs_m.objs(k)=o
    end
  end //** of the main connected/UnConnected Block

endfunction

//**------------------------------------------------------------------------------------------

function scs_m = movelink(scs_m, k, xc, yc, wh)
//** INRIA
//**
//** This function handle the case of a Smartmove of a single link where the use has clicked
//** in proximity of the link and not near any corner. In this case 'wh' is a positive integer
//** INDEX of the first coordinate of the link segment.
//** 'pt' (the user click) lies on segment [ind ind+1] ; where 'ind = wh';
//**
//** Actions: move the  segment 'wh' of the link 'k' and modify the other segments if necessary
//**
//** ----> This routine handle the main case of a LINK ONLY move <-----------------------------

  gh_curwin = gh_current_window ;
  drawlater();
  o_size = size (gh_curwin.children.children );

  gh_k=get_gri(k,o_size(1))
  gh_link=gh_curwin.children.children(gh_k);

  drawlater(); //** postpone the drawing

  gh_interactive_move = []; //** initialize the object vector
  gh_objs_invisible=[]

  o = scs_m.objs(k)

  [xx, yy, ct] = (o.xx,o.yy,o.ct)
  nl = size(o.xx,'*')  // number of link points

  //** wh=1 first segment
  //** wh>=nl-1 last segment
  //** the link has 3 (three) elements (nor the first, nor the last)
  if wh==1 then

    //**----------> Click over the first segment of the link <-----------------------
    from = o.from;
    to   = o.to;

    //** if the link has two segment
    //** AND the link start AND the link end are both split
    if is_split(scs_m.objs(from(1))) & is_split(scs_m.objs(to(1))) & nl<3 then

      [gh_interactive_move,scs_m] = movelink1(scs_m) ; //** see below for the code

    //** the link start is NOT a split (is a Block output)
    //** OR the link has two segment
    elseif ~is_split(scs_m.objs(from(1))) | nl<3 then //** ok

      //** this code create a new segment and move the new corner in the desired position
      //** I do not agree with this approach that create two "oblique" object
      p  = projaff(xx(1:2), yy(1:2), [xc,yc])
      X1 = [xx(1); p(1); xx(2)]
      Y1 = [yy(1); p(2); yy(2)]
      x1 = X1
      y1 = Y1

      gh_link.visible = "off"; //** put the link invisible
      gh_objs_invisible = [gh_objs_invisible gh_link]; //** add at the list

      xpoly(x1,y1)     //** create the moving object
      gh_poly = gce()  //** get the handle of the moving object
      gh_poly.foreground = ct(1)  //** set the color

      gh_interactive_move = [gh_interactive_move gh_poly] //** add the object at the list of
                     //** the object to be delated at the end of the operation

      //**---- Interactive loop -----------------------------
      rep(3)=-1
      drawlater();
      while and(rep(3)<>[3 0 2 5]) do

        if with_gtk() then
          rep = xgetmouse(queue_state=[],[%t,%t])
        else
          rep = xgetmouse(0,[%t,%t])
        end

        if with_gtk() then
          queue_state=1
          if rep(3)==10 then
            global scicos_dblclk
            scicos_dblclk=[rep(1),rep(2),curwin]
          end
          if or(rep(3)==[0,-5, 2, 3, 5]) then
            break
          end
        else
          if or(rep(3)==[0,2,3,5,-5 995]) then
            break ; //** ---> EXIT point of the while
          end
        end

        if rep(3)==-100 then //active window has been closed
          [%win,Cmenu] = resume(curwin,'Quit')
        end

        gh_curwin.pixel_drawing_mode="xor"
        draw(gh_poly) //** draw the moving part of the link

        xc1 = rep(1) ; //** acquire mouse coordinate
        yc1 = rep(2) ;
        x1(2) = X1(2)-(xc-xc1);
        y1(2) = Y1(2)-(yc-yc1); //** update coordinate
        gh_poly.data = [x1 y1];

        draw(gh_poly) //** delete the moving part of the link
        gh_curwin.pixel_drawing_mode="copy"
        show_pixmap() //** show on screen
      end //** of while

      gh_figure = gcf();
      if gh_figure.figure_id<>curwin | rep(3)==-100 then
        [%win,Cmenu] = resume(curwin,'Quit');
      end

      //** xpolys(x1,y1,ct(1)) //draw moving part of the link
      xx = [xx(1);x1(2);xx(2:$)] ;
      yy = [yy(1);y1(2);yy(2:$)] ;

      if and(rep(3)<>[2 5]) then 
        o.xx = xx ;
        o.yy = yy ;
        scs_m.objs(k) = o ; //** update the scs_m
      end
      o_size = size (gh_curwin.children.children)
      gr_k = get_gri(k,o_size(1))
      update_gr(gr_k,o)

    else //** ok

      //** link comes from a split
      [gh_interactive_move,scs_m] = movelink2(scs_m) ; //** ok
      if Cmenu=='Quit' then [%win,Cmenu] = resume(curwin,Cmenu), end
    end //** and of "I'm in the first segnment of a link"

  //**-----------------------------------------------------------
  elseif wh>=nl-1 then

    //**---> click over the last segment of 3 or more segment link
    to = o.to;

    if ~is_split(scs_m.objs(to(1))) | nl<3 then
    //** the start is a split  OR is a one/two segment link
      p = projaff(xx($-1:$),yy($-1:$),[xc,yc])
      X1= [xx($-1);p(1);xx($)]
      Y1= [yy($-1);p(2);yy($)]
      x1= X1;
      y1= Y1;
      //** xpolys(x1,y1,ct(1)) //erase moving part of the link
      xpoly( x1, y1 ) ; //** create the moving object
      gh_poly = gce() ; //** get the handle of the moving object
      gh_poly.foreground = ct(1) ; //** set the color

      gh_interactive_move = [gh_interactive_move gh_poly] ; //** add the object at the list of
                     //** the object to be delated at the end of the operation
      rep(3)=-1
      drawlater()
      //**---- Interactive loop -----------------------------
      while and(rep(3)<>[3 0 2 5]) do

        rep = xgetmouse([%t,%t]); //** wait for user movement :)

        if rep(3)==-100 then //active window has been closed
          [%win,Cmenu] = resume(curwin,'Quit')
        end

        gh_curwin.pixel_drawing_mode="xor"
        draw(gh_poly); //** delete the moving part of the link

        xc1 = rep(1);
        yc1 = rep(2);
        x1(2) = X1(2)-(xc-xc1);
        y1(2) = Y1(2)-(yc-yc1);
        gh_poly.data = [x1 y1];

        draw(gh_poly) //** delete the moving part of the link
        gh_curwin.pixel_drawing_mode="copy"
        show_pixmap() //** show on screen
      end

      gh_figure = gcf();
      if gh_figure.figure_id<>curwin | rep(3)==-100 then
        [%win,Cmenu] = resume(curwin,'Quit') ;
      end

      //** xpolys(x1,y1,ct(1))//draw moving part of the link
      xx = [xx(1:$-1);x1(2);xx($)]
      yy = [yy(1:$-1);y1(2);yy($)]
      //** xpolys(xx,yy,ct(1)) // erase thin link
      if and(rep(3)<>[2 5]) then
        o.xx = xx ;
        o.yy = yy ;
        scs_m.objs(k)=o
      end

      o_size = size (gh_curwin.children.children)
      gr_k = get_gri(k,o_size(1))
      update_gr(gr_k,o)

    else // link goes to a split
         // click over the last segment of 3 or more segment link
         //**
         //** the user has clicked in a end segment that goes in a split
         //**
      [gh_interactive_move,scs_m] = movelink3(scs_m) ; //** see below in the code

      if Cmenu=='Quit' then [%win,Cmenu]=resume(curwin,Cmenu),end

    end
  //**----------------------------------------------------------------

  elseif nl<4 then

    //**---> the link has 3 (three) elements (nor the first, nor the last)
    //**     is a click in the intemediate segment (wh=2 allways so is not necessary :)
    //**     check it )
    p  = projaff(xx(wh:wh+1),yy(wh:wh+1),[xc,yc]) ;
    X1 = [xx(wh);p(1);xx(wh+1)] 
    Y1 = [yy(wh);p(2);yy(wh+1)]
    x1 = X1 ;
    y1 = Y1 ;
    rep(3) = -1

    //**---- Interactive loop -----------------------------
    while and(rep(3)<>[3 0 2 5 -5 995]) do
      //** xpolys(x1,y1,ct(1))//draw moving part of the link
      rep = xgetmouse(0);
      if rep(3)==-100 then //active window has been closed
        //** driver(dr);
        [%win,Cmenu]=resume(curwin,'Quit')
      end
      //** if pixmap then xset('wshow'),end
      //** xpolys(x1,y1,ct(1))//erase moving part of the link
      xc1 = rep(1) ;
      yc1 = rep(2) ; 
      x1(2) = X1(2)-(xc-xc1)
      y1(2) = Y1(2)-(yc-yc1)
    end

    gh_figure = gcf();
    if gh_figure.figure_id<>curwin | rep(3)==-100 then
      [%win,Cmenu] = resume(curwin,'Quit') ;
    end

    //** xpolys(x1,y1,ct(1))//draw moving part of the link
    xx=[xx(1:wh);x1(2);xx(wh+1:$)]
    yy=[yy(1:wh);y1(2);yy(wh+1:$)]
    //** xpolys(xx,yy,ct(1)) // erase thin link
    if and(rep(3)<>[2 5]) then
      o.xx = xx ;
      o.yy = yy ;
      scs_m.objs(k)=o
    end
    o_size = size (gh_curwin.children.children)
    gr_k = get_gri(k,o_size(1))
    update_gr(gr_k,o)
    //** driver(dr)
    //** drawobj(o)
    //** if pixmap then xset('wshow'),end

  else

  //**---> the user has cliked over at least 4 segment long link, NOR at the start NOR at the end

    [gh_interactive_move,scs_m] = movelink4(scs_m) ; //** see below in the code

    if Cmenu=='Quit' then
      [%win,Cmenu] = resume(curwin,Cmenu)
    end

  end

  //** Clear the graphic window WHITOUT changing his parameters AND recreate all the good graphics object
  drawlater();

  if gh_interactive_move<>[] then
    delete(gh_interactive_move)
  end

  drawnow();
  show_pixmap();               //** draw the graphic object and show on screen

endfunction

//**-----------------------------------------------------------------------------------
function [gh_interactive_move,scs_m] = movelink1(scs_m)
  // link between to splits
  //** WARNING: 'movelink1()' is up to date BUT I'm not able to create an examples !
  //**

  o; //** local copy of an external variable "o"
  e = [min(yy)-max(yy), min(xx)-max(xx)];
  e = e/norm(e) ;

  gh_link=gh_link
  gh_objs_invisible=gh_objs_invisible
  gh_curwin=gh_curwin

  //move split block and update other connected links
  connected = [get_connected(scs_m,from(1)),get_connected(scs_m,to(1))]

  gh_interactive_move = [];

  gh_link.visible   = "off"; //** put the link invisible
  gh_objs_invisible = [gh_objs_invisible gh_link]; //** add at the list
  xpoly(xx, yy);   //** create the moving object
  gh_poly = gce(); //** get the handle of the moving object
  gh_poly.foreground  = ct(1); //** set the color
  gh_interactive_move = [gh_interactive_move gh_poly];
  X1 = xx;
  Y1 = yy;

  gh_connected_1=[]
  gh_connected=[]
  con=1
  con_ind=[]
  // change links
  if connected(1)<>k then
    o_size = size (gh_curwin.children.children ) ; //** the size: number of all the object
    gh_k=get_gri(connected(1),o_size(1))
    gh_link=gh_curwin.children.children(gh_k);
    gh_link.visible   = "off"; //** put the link invisible
    gh_objs_invisible = [gh_objs_invisible gh_link]; //** add at the list
    o=scs_m.objs(connected(1));
    XX = o.xx;
    YY = o.yy;
    xpoly(XX, YY);
    gh_connected_1=gce()
    gh_connected_1.foreground  = ct(1); //** set the color
    gh_interactive_move = [gh_interactive_move gh_connected_1];
  end

  for kk=2:size(connected,'*')
    if connected(kk)<>k then
      o_size = size (gh_curwin.children.children ) ; //** the size: number of all the object
      gh_k=get_gri(connected(kk),o_size(1))
      gh_link=gh_curwin.children.children(gh_k);
      gh_link.visible   = "off"; //** put the link invisible
      gh_objs_invisible = [gh_objs_invisible gh_link]; //** add at the list
      o = scs_m.objs(connected(kk))
      con_ind = [con_ind;connected(kk)]
      XX = o.xx
      YY = o.yy
      xpoly(XX, YY)
      gh_connected(con)=gce()
      gh_connected(con).foreground  = ct(1); //** set the color
      gh_interactive_move = [gh_interactive_move gh_connected(con)];
      con=con+1
    end
  end

  rep(3)=-1
  //**---- Interactive loop ----------------------------- 
  while and(rep(3)<>[3 0 2 5 -5 995]) do

    draw(gh_curwin.children); //** draw the moving part of the link
    show_pixmap(); //** show on screen

    if with_gtk() then
       rep = xgetmouse(queue_state=[],[%t,%t])
    else
       rep = xgetmouse(0,[%t,%t])
    end

    if with_gtk() then
      queue_state=1
      if rep(3)==10 then
        global scicos_dblclk
        scicos_dblclk=[rep(1),rep(2),curwin]
      end
      if or(rep(3)==[0,-5, 2, 3, 5]) then
        break
      end
    else
      if or(rep(3)==[0,2,3,5,-5 995]) then
        break ; //** ---> EXIT point of the while
      end
    end

    if rep(3)==-100 then //active window has been closed
      [%win,Cmenu]=resume(curwin,'Quit')
    end

    //** acquire mouse coordinate
    xc1 = rep(1)
    yc1 = rep(2)

    //** update coordinate
    xx = X1 + e(1)*(xc-xc1)
    yy = Y1 + e(2)*(yc-yc1)
    gh_poly.data = [xx yy]

    // change links
    if connected(1)<>k then
      o  = scs_m.objs(connected(1))
      XX = o.xx
      YY = o.yy
      if size(XX,'*')>2 then
        if XX($)==XX($-1) then
          XX($-1:$)=XX($-1:$)+e(1)*(xc-xc1)
          YY($)=YY($)+e(2)*(yc-yc1)
        elseif YY($)==YY($-1) then
          XX($)=XX($)+e(1)*(xc-xc1)
          YY($-1:$)=YY($-1:$)+e(2)*(yc-yc1)
        else
          XX($)=XX($)+e(1)*(xc-xc1)
          YY($)=YY($)+e(2)*(yc-yc1)
        end
      else
        XX($)=XX($)+e(1)*(xc-xc1)
        YY($)=YY($)+e(2)*(yc-yc1)
      end
      gh_connected_1.data = [XX YY]
    end

    for kk=1:size(gh_connected,1)
        o  = scs_m.objs(con_ind(kk))
        XX = o.xx
        YY = o.yy
        if size(XX,'*')>2 then
          if XX(1)==XX(2) then
            XX(1:2)=XX(1:2)+e(1)*(xc-xc1)
            YY(1)=YY(1)+e(2)*(yc-yc1)
          elseif YY(1)==YY(2) then
            XX(1)=XX(1)+e(1)*(xc-xc1)
            YY(1:2)=YY(1:2)+e(2)*(yc-yc1)
          else
            XX(1)=XX(1)+e(1)*(xc-xc1)
            YY(1)=YY(1)+e(2)*(yc-yc1)
          end
        else
          XX(1)=XX(1)+e(1)*(xc-xc1)
          YY(1)=YY(1)+e(2)*(yc-yc1)
        end
        gh_connected(kk).data = [XX YY]
    end

  end
  //**--- Interactive loop ends -------------------------

  gh_figure = gcf();
  if gh_figure.figure_id<>curwin | rep(3)==-100 then
    [%win,Cmenu] = resume(curwin,'Quit') ;
  end

  if and(rep(3)<>[2 5]) then
    o.xx = xx;
    o.yy = yy;
  end

  scs_m.objs(k) = o ;

  o_size = size (gh_curwin.children.children)
  gr_k = get_gri(k,o_size(1))
  update_gr(gr_k,o)

  if or(rep(3)==[2 5]) then return,end

  // change links
  if connected(1)<>k then
    //update links coordinates
    o=scs_m.objs(connected(1));

    if size(o.xx,'*')>2 then
      if o.xx($)==o.xx($-1) then
        o.xx($-1:$)=o.xx($-1:$)+e(1)*(xc-xc1);
        o.yy($)=o.yy($)+e(2)*(yc-yc1);
      elseif o.yy($)==o.yy($-1) then
        o.xx($)=o.xx($)+e(1)*(xc-xc1);
        o.yy($-1:$)=o.yy($-1:$)+e(2)*(yc-yc1);
      else
        o.xx($)=o.xx($)+e(1)*(xc-xc1);
        o.yy($)=o.yy($)+e(2)*(yc-yc1);
      end
    else
      o.xx($)=o.xx($)+e(1)*(xc-xc1);
      o.yy($)=o.yy($)+e(2)*(yc-yc1);
    end

    scs_m.objs(connected(1))=o;
    gr_k = get_gri(connected(1),o_size(1))
    update_gr(gr_k,o)

    //** drawobj(o) //redraw link
  end

  for kk=2:size(connected,'*')
    if connected(kk)<>k then
      //update links coordinates
      o=scs_m.objs(connected(kk))

      if size(o.xx,'*')>2 then
        if o.xx(1)==o.xx(2) then
          o.xx(1:2)=o.xx(1:2)+e(1)*(xc-xc1)
          o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
        elseif o.yy(1)==o.yy(2) then
          o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
          o.yy(1:2)=o.yy(1:2)+e(2)*(yc-yc1)
        else
          o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
          o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
        end
      else
        o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
        o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
      end

      scs_m.objs(connected(kk))=o;
      gr_k = get_gri(connected(kk),o_size(1))
      update_gr(gr_k,o)
    end

  end

  //update split coordinates
  o=scs_m.objs(from(1))
  o.graphics.orig(1)=o.graphics.orig(1)+e(1)*(xc-xc1);
  o.graphics.orig(2)=o.graphics.orig(2)+e(2)*(yc-yc1);
  scs_m.objs(from(1))=o
  gr_k = get_gri(from(1),o_size(1))
  update_gr(gr_k,o)

  o=scs_m.objs(to(1))
  o.graphics.orig(1)=o.graphics.orig(1)+e(1)*(xc-xc1);
  o.graphics.orig(2)=o.graphics.orig(2)+e(2)*(yc-yc1);
  scs_m.objs(to(1))=o
  gr_k = get_gri(to(1),o_size(1))
  update_gr(gr_k,o)
endfunction
//**---------- End of movelink1 ---------------------------------------------------

//**-------------------------------------------------------------------------------------
function [gh_interactive_move,scs_m] = movelink2(scs_m)
//** Move the first segment 'wh==1' of a link that start from a split 
//** In the first part, the first segment link that start from the plist is interactively moved
//** if the move is valid, also the 'split' object is moved accordly at the link starting point
//** it is nice and it's works ! 

  o; //** local copy of an external variable "o" 
  e = [min(yy(1:2))-max(yy(1:2)), min(xx(1:2))-max(xx(1:2))];
  e = e/norm(e)
  X1 = xx(1:3)
  Y1 = yy(1:3)
  x1 = X1;
  y1 = Y1;

  gh_curwin;

  gh_interactive_move = [];

  xpoly( x1, y1 ) ; //** create the moving object
  gh_poly = gce() ; //** get the handle of the moving object
  gh_poly.foreground = ct(1) ; //** set the color
  gh_interactive_move = [gh_interactive_move gh_poly] ; //** add the object at the list of
                     //** the object to be delated at the end of the operation

  rep(3)=-1

  drawlater()
  //**---- Interactive loop -----------------------------
  while and(rep(3)<>[3 0 2 5 -5 995]) do

    rep = xgetmouse([%t,%t]); //** wait for user movement :)
    if rep(3)==-100 then //active window has been closed
        [%win,Cmenu] = resume(curwin,'Quit') ;
    end

    gh_curwin.pixel_drawing_mode="xor"
    draw(gh_poly) //** draw the moving part of the link

    xc1 = rep(1); yc1 = rep(2)      //** acquire muse coordinate
    x1(1:2) = X1(1:2)+e(1)*(xc-xc1) //** update coordinate
    y1(1:2) = Y1(1:2)+e(2)*(yc-yc1)
    gh_poly.data = [x1 y1]

    draw(gh_poly) //** delete the moving part of the link
    gh_curwin.pixel_drawing_mode="copy"
    show_pixmap() //** show on screen

  end


  //**--- Interactive loop ends -------------------------
  gh_figure = gcf();
  if gh_figure.figure_id<>curwin | rep(3)==-100 then
    [%win,Cmenu] = resume(curwin,'Quit') ;
  end

  if and(rep(3)<>[2 5]) then //** if valid move
    o.xx(1:3) = x1 ;
    o.yy(1:3) = y1 ;         //** update the object
  end

  scs_m.objs(k) = o ;        //** update the diagam
  o_size = size (gh_curwin.children.children)
  gr_k = get_gri(k,o_size(1))
  update_gr(gr_k,o)

  if or(rep(3)==[2 5]) then return, end

  //move split block and update other connected links
  connected = get_connected(scs_m,from(1))

  for j=find(connected<>k),
    //** drawobj(scs_m.objs(connected(j))); //erase  other connected links
  end

  //** drawobj(scs_m.objs(from(1)))//erase split

  // change links
  if connected(1)<>k then
    //update links coordinates
    o = scs_m.objs(connected(1));
    if size(o.xx,'*')>2 then

      if o.xx($)==o.xx($-1) then
        o.xx($-1:$)=o.xx($-1:$)+e(1)*(xc-xc1);
        o.yy($)=o.yy($)+e(2)*(yc-yc1);
      elseif o.yy($)==o.yy($-1) then
        o.xx($)=o.xx($)+e(1)*(xc-xc1);
        o.yy($-1:$)=o.yy($-1:$)+e(2)*(yc-yc1);
      else
        o.xx($)=o.xx($)+e(1)*(xc-xc1);
        o.yy($)=o.yy($)+e(2)*(yc-yc1);
      end

    else
      o.xx($)=o.xx($)+e(1)*(xc-xc1);
      o.yy($)=o.yy($)+e(2)*(yc-yc1);
    end

    scs_m.objs(connected(1))=o;
    gr_k = get_gri(connected(1),o_size(1))
    update_gr(gr_k,o)
    //** drawobj(o) //redraw link
  end

  for kk=2:size(connected,'*')
    if connected(kk)<>k then
      //update links coordinates
      o = scs_m.objs(connected(kk))
      if size(o.xx,'*')>2 then
        if o.xx(1)==o.xx(2) then
          o.xx(1:2)=o.xx(1:2)+e(1)*(xc-xc1)
          o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
        elseif o.yy(1)==o.yy(2) then
          o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
          o.yy(1:2)=o.yy(1:2)+e(2)*(yc-yc1)
        else
          o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
          o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
        end
      else
        o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
        o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
      end
      scs_m.objs(connected(kk))=o;
      gr_k = get_gri(connected(kk),o_size(1))
      update_gr(gr_k,o)
      //** drawobj(o)//redraw link
    end
  end

  //update split coordinates
  o=scs_m.objs(from(1))
  o.graphics.orig(1)=o.graphics.orig(1)+e(1)*(xc-xc1);
  o.graphics.orig(2)=o.graphics.orig(2)+e(2)*(yc-yc1);

  scs_m.objs(from(1))=o
  gr_k = get_gri(from(1),o_size(1))
  update_gr(gr_k,o)
endfunction
//**---------- End of movelink2 ---------------------------------------------------

//**--------------------------------------------------------------------------------
function [gh_interactive_move,scs_m] = movelink3(scs_m)
// link goes to a split
// click over the last segment of 3 or more segment link
//**
 //** the user has clicked in a end segment that goes in a split
//**
  o ; //** local copy of an external variable "o"
  e = [min(yy($-1:$))-max(yy($-1:$)),min(xx($-1:$))-max(xx($-1:$))];
  e = e/norm(e) ;
  X1 = xx($-2:$);
  Y1 = yy($-2:$);
  x1 = X1 ;
  y1 = Y1 ;
  gh_interactive_move = [];
  xpoly(x1, y1) ; //** create the moving object
  gh_poly = gce() ; //** get the handle of the moving object
  gh_poly.foreground = ct(1) ; //** set the color
  draw(gh_poly); //** draw the segment in 'xor' mode in order to clear the relative
                 //** polyline part
  gh_interactive_move = [gh_interactive_move gh_poly] ; //** add the object at the list of
                                 //** the object to be deleted at the end of the operation
  rep(3)=-1
  //**---- Interactive loop -----------------------------
  while and(rep(3)<>[3 0 2 5 -5 995]) do
    //** xpolys(x1,y1,ct(1))//draw moving part of the link
    draw(gh_poly); //** draw the moving part of the link
    show_pixmap(); //** show on screen

    rep = xgetmouse([%t,%t]); //** wait for user movement :)

    if rep(3)==-100 then //active window has been closed
      [%win,Cmenu]=resume(curwin,'Quit')
    end
    draw(gh_poly); //** draw the moving part of the link
    show_pixmap(); //** show on screen

    xc1 = rep(1); yc1 = rep(2)
    x1($-1:$) = X1($-1:$)+e(1)*(xc-xc1) ;
    y1($-1:$) = Y1($-1:$)+e(2)*(yc-yc1) ;

    gh_poly.data = [x1 y1]; 
  end
  //**--- Interactive loop ends ------------------------

  gh_figure = gcf();
  if gh_figure.figure_id<>curwin | rep(3)==-100 then
      [%win,Cmenu] = resume(curwin,'Quit') ;
  end

  if and(rep(3)<>[2 5])  then
    o.xx($-2:$) = x1  ;
    o.yy($-2:$) = y1  ;
    scs_m.objs(k) = o ;
  end

  if or(rep(3)==[2 5]) then return,end

  //move split block and update other connected links
  connected = get_connected(scs_m,to(1))

  for j=find(connected<>k),
    drawobj(scs_m.objs(connected(j))),//erase connected links
  end

  //** drawobj(scs_m.objs(to(1))) //erase split

  for kk=2:size(connected,'*')
    //update links coordinates
    o = scs_m.objs(connected(kk))
    if size(o.xx,'*')>2 then
      if o.xx(1)==o.xx(2) then
        o.xx(1:2)=o.xx(1:2)+e(1)*(xc-xc1)
        o.yy(1)=o.yy(1)+e(2)*(yc-yc1) 
      elseif o.yy(1)==o.yy(2) then 
        o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
        o.yy(1:2)=o.yy(1:2)+e(2)*(yc-yc1)
      else
        o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
        o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
      end
    else
      o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
      o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
    end
    scs_m.objs(connected(kk))=o;
    gr_k = get_gri(connected(kk),o_size(1))
    update_gr(gr_k,o)
    //** drawobj(o) // redraw connected links
  end //** of for loop
  o = scs_m.objs(to(1))
  o.graphics.orig(1) = o.graphics.orig(1)+e(1)*(xc-xc1);
  o.graphics.orig(2) = o.graphics.orig(2)+e(2)*(yc-yc1);

  scs_m.objs(to(1))=o
  gr_k = get_gri(to(1),o_size(1))
  update_gr(gr_k,o)
endfunction
//**---------- End of movelink3 ---------------------------------------------------

//**---------------------------------------------------------------------------------
function [gh_interactive_move,scs_m] = movelink4(scs_m)
//**---> the user has cliked over at least 4 segment long link, NOR at the start NOR at the end

  o; //** local copy of an external variable "o"
  e = [min(yy(wh:wh+1))-max(yy(wh:wh+1)),min(xx(wh:wh+1))-max(xx(wh:wh+1))];
  e = e/norm(e) ;     //** matrix normalization
  X1 = xx(wh-1:wh+2);
  Y1 = yy(wh-1:wh+2);
  x1 = X1;
  y1 = Y1;
  gh_curwin
  gh_interactive_move = [];

  xpoly(x1, y1) ; //** create the moving object
  gh_poly = gce() ; //** get the handle of the moving object
  gh_poly.foreground = ct(1) ; //** set the color
  draw(gh_poly); //** draw the segment in 'xor' mode in order to clear the relative
                 //** polyline part
  //** add the object at the list of the object to be deleted at the end of the operation
  gh_interactive_move = [gh_interactive_move gh_poly]

  rep(3) = -1
  drawlater();
  //**---- Interactive loop -----------------------------
  while and(rep(3)<>[3 0 2 5 -5 995]) do

    rep = xgetmouse([%t,%t]); //** wait for user movement :)

    if rep(3)==-100 then //active window has been closed
      [%win,Cmenu] = resume(curwin,'Quit')
    end

    gh_curwin.pixel_drawing_mode="xor"
    draw(gh_poly) //** draw the moving part of the link

    //** xpolys(x1,y1,ct(1))//erase moving part of the link
    xc1 = rep(1); yc1 = rep(2)
    x1(2:3) = X1(2:3)+e(1)*(xc-xc1)
    y1(2:3) = Y1(2:3)+e(2)*(yc-yc1)
    gh_poly.data = [x1 y1]

    draw(gh_poly) //** delete the moving part of the link
    gh_curwin.pixel_drawing_mode="copy"
    show_pixmap() //** show on screen

  end
  //**--- Interactive loop ends -------------------------

  //erase rest of the link
  gh_figure = gcf();
  if gh_figure.figure_id<>curwin | rep(3)==-100 then
    [%win,Cmenu] = resume(curwin,'Quit') ;
  end

  if and(rep(3)<>[2 5]) then
    o.xx(wh-1:wh+2) = x1 ;
    o.yy(wh-1:wh+2) = y1 ;
    scs_m.objs(k) = o
  end

  o_size = size (gh_curwin.children.children)
  gr_k = get_gri(k,o_size(1))
  update_gr(gr_k,o)
endfunction
//**---------- End of movelink4 ----------------------------------------------------

//**--------------------------------------------------------------------------------
function [scs_m] = movecorner(scs_m,k,xc,yc,wh)
//** the user has clicked near a link corner (link segment joint)
  o = scs_m.objs(k) ; //** get the object
  [xx,yy,ct] = (o.xx,o.yy,o.ct)
  if wh==-1|wh==-size(xx,'*') then // link endpoint is choosen
    scs_m = movelink(scs_m,k,xc,yc,-wh)
    return
  end

  wh = [-wh-1 -wh] ; //** ??? Ask Serge

  wh = [wh wh($)+1] ; //** ??? Ask Serge
  X1 = xx(wh) ;
  Y1 = yy(wh) ;
  x1 = X1 ;
  y1 = Y1 ;
  gh_interactive_move = [];
  gh_curwin

  //** xpolys(x1,y1,ct(1)) //erase moving part of the link
  xpoly( x1, y1 ) ; //** create the moving object
  gh_poly = gce() ; //** get the handle of the moving object
  gh_poly.foreground = ct(1) ; //** set the color
  draw(gh_poly); //** draw the segment in 'xor' mode in order to clear the realtive
                 //** polyline part

  gh_interactive_move = [gh_interactive_move gh_poly] ; //** add the object at the list of
                     //** the object to be deleted at the end of the operation

  rep(3)=-1
  drawlater();

  //**---- Interactive loop -----------------------------
  while and(rep(3)<>[3 0 2 5 -5 995]) do

    rep = xgetmouse([%t,%t]);

    if rep(3)==-100 then
      [%win,Cmenu]=resume(curwin,'Quit')
    end

    gh_curwin.pixel_drawing_mode="xor"
    draw(gh_poly);

    xc1 = rep(1); yc1 = rep(2) ;
    x1(2) = X1(2)-(xc-xc1) ;
    y1(2) = Y1(2)-(yc-yc1) ;
    gh_poly.data = [x1 y1];

    draw(gh_poly);
    gh_curwin.pixel_drawing_mode="copy"
    show_pixmap();
  end
  //**--- Interactive loop ends ------------------------

  gh_figure = gcf();
  if gh_figure.figure_id<>curwin | rep(3)==-100 then
      [%win,Cmenu] = resume(curwin,'Quit') ;
  end

  //** Dead code here ???
  //** [frect1, frect] = xgetech();
  //** //0.04*min(abs(frect(3)-frect(1)),abs(frect(4)-frect(2)))
  eps = 16 ;
  if abs(x1(1)-x1(2))<eps then
    x1(2) = x1(1) 
  elseif abs(x1(2)-x1(3))<eps then
    x1(2) = x1(3)
  end
  if abs(y1(1)-y1(2))<eps then
    y1(2) = y1(1)
  elseif abs(y1(2)-y1(3))<eps then
    y1(2) = y1(3)
  end
  d = projaff([x1(1);x1(3)],[y1(1);y1(3)],[x1(2);y1(2)]);
  if norm(d(:)-[x1(2);y1(2)])<eps then
    xx(wh) = x1
    yy(wh) = y1
    xx(wh(2)) = []
    yy(wh(2)) = []
    x1(2) = [] ;
    y1(2) = [] ;
  else
    xx(wh) = x1
    yy(wh) = y1
  end

  if and(rep(3)<>[2 5]) then
    o.xx=xx;o.yy=yy
    scs_m.objs(k)=o
  end

  o_size = size (gh_curwin.children.children)
  gr_k = get_gri(k,o_size(1))
  update_gr(gr_k,o)

endfunction
