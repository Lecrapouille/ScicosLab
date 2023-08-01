function [scs_m] = do_stupidmove(%pt,Select,scs_m)
// Copyright INRIA
//**
//** This function is called ONLY on the case of SINGLE LINK selected
//** The code do some partially redundant function call becase is
//** derived from the old version.
//**

// Acquire the current window
  gh_curwin = gh_current_window ;
// get block to move
  rela = 0.1   ; //** "relative object position tolerance"
  win  = %win ;  //** window id

  xc = %pt(1) ; //** recover mouse position at the last event
  yc = %pt(2) ;
  
  //** look for a valid object
  //** this function is called only because "stupid_movecorner()" needs
  //** the "wh" parameter 
  [k, wh, scs_m] = stupid_getobj(scs_m,Select,[xc;yc]) ; 
  
  //** "k" is the object index in the data structure "scs_m"
  if k==[] then
    return
  end ;//** if NO object found -> exit

  scs_m_save = scs_m ; //** make a backup of the data structure

  //**-------------------------------------------------------------------
  if typeof(scs_m.objs(k))=='Link' then
    //**------------------- Link ------------------------------
    //** scs_m , k (scs_m object index), xc yc (mouse coordinate of the last valid event)
    scs_m = stupid_movecorner(scs_m, k, xc, yc, wh) ; //** see below in this file

  end
  //**------------------------------------------------------------------

  //** check if the windows was find closed by the previous function calls 
  if Cmenu=='Quit' then
    //active window has been closed
    [%win,Cmenu] = resume(%win, Cmenu)
  end

  [scs_m_save,enable_undo,edited,nc_save,needreplay] = resume(scs_m_save,%t,%t,needcompile,needreplay)
endfunction
//**------------------------------------------------------------------------------------------------------
//**
//********************************************************************************************************
//**
//** --------> This function works only with links <---------
//** ------------------ Link Supid Move ---------------------
function scs_m = stupid_movecorner(scs_m, k, xc, yc, wh)
  
  //**----------------------------------------------------------------------------------
  //** the code below is modified according the new graphics API
  gh_curwin = gh_current_window ; 
  
  //**-----------------------------------------------------------------------------------
  //** Acquire axes phisical limits (visible limits are smaller)    
     
  figure_axes_size = gh_curwin.axes_size ; //** size in pixel 
  x_f = figure_axes_size(1) ;
  y_f = figure_axes_size(2) ;
  
  [x1_f, y1_f, rect_f] = xchange([0,x_f],[0,y_f],"i2f"); //** convert to local coordinate 
  
  x_min = x1_f(1) ; x_max = x1_f(2) ; //** hor. limits
  y_min = y1_f(2) ; y_max = y1_f(1) ; //** ver. limits (inverted because the upper left corner effect)  
    
  //**-----------------------------------------------------------------------------------
  
  //** at this point I need to build the [scs_m] <-> [gh_window] datastructure 
  //** I need an equivalent index for the graphics 
  o_size = size (gh_curwin.children.children ) ; //** the size:number of all the object 
  
  //** "k" is the object index in the data structure "scs_m"
  //** compute the equivalent "gh_k" for the graphics datastructure 
  gh_k = get_gri(k,o_size(1))
  //** disp (gh_k);
  gh_blk = gh_curwin.children.children(gh_k);
  //**-----------------------------------------------------------------------------------
  
  o = scs_m.objs(k) ; //** take the Scicos object 
  
  [xx, yy, ct] = (o.xx,o.yy,o.ct) ;
  //** ct(1) is the color ; never used because it is not modified :)
  
  o_link = size (xx)    ;
  link_size = o_link(1) ; //** number of element of link (polyline) 

  //** wh point to the subsegment (sublink interested by the move) 
  moving_seg = [-wh-1:-wh+1] ;
  
  if (-wh-1) == 1 then //** the moving include the starting point  
    start_seg = [];
    X_start = []  ;
    Y_start = []  ;
  else                 //** the move need some static point from the beginning 
    start_seg = [1 : -wh-1]  ; 
    X_start = xx(start_seg)  ;
    Y_start = yy(start_seg)  ;
  end    
  
  if (-wh+1) == link_size then //** the moving include the endpoint 
    end_seg = [] ;
    X_end = []  ;
    Y_end = []  ;
  else                //** the moving need some static point to the end 
    end_seg = [-wh+1 : link_size] ;
    X_end = xx(end_seg) ;
    Y_end = yy(end_seg) ;
  end   
      
  if %scicos_debug_gr then
    disp("...subsegment -> Link move --> seg:..."); disp(moving_seg) ;
  end

  //** xpolys(xx(seg),yy(seg),ct(1)) //draw thin link
  //** gh_blk.children.data = [xx(seg), yy(seg)]; //** modify the fixed part of the link 

  X1 = xx(moving_seg) ; //** constant starting values
  Y1 = yy(moving_seg) ;
  x1 = X1 ;  //** temp variables for the move
  y1 = Y1 ;

  //** store initial gh_blk.children.data
  //**  -Alan- YAUNTOUTPETITBUGICI
  //** gh_blk.children.data peut ne pas etre en accord avec scs_m
  //** a' cause de la fonction stupid_getobj qui dans le cas
  //** des liens peut creer un nouveau point
  ini_data     = gh_blk.children(1).data;
  ini_data_id  = gh_blk.children(2).data;

  //**-----------------------------------------------------------------
  rep(3) = -1;
  drawnow();

  while 1 do
    if with_gtk() then
      if rep(3)==10 then
	global scicos_dblclk
	scicos_dblclk=[rep(1),rep(2),curwin]
      end
      if or(rep(3)==[0,2,3,5,-5,-100]) then
	break
      end
    else
      if or(rep(3)==[0,2,3,5,-5,-100]) then break,end ; //** exit point
    end 

    rect  = [min(gh_blk.children(1).data(:,1))+(max(gh_blk.children(1).data(:,1))-min(gh_blk.children(1).data(:,1)))/2 ,...
             min(gh_blk.children(1).data(:,2))+(max(gh_blk.children(1).data(:,2))-min(gh_blk.children(1).data(:,2)))/2]

    gh_figure = gcf();
    gh_figure.pixel_drawing_mode = "xor"
    draw(gh_blk.children);

    gh_blk.children(1).data = [X_start,Y_start ; x1, y1 ; X_end, Y_end ];

    draw(gh_blk.children);

    gh_figure.pixel_drawing_mode = "copy"
    show_pixmap();
    drawlater();

    rep = xgetmouse(0,[%t,%t]);

    if gh_figure.figure_id<>curwin | rep(3)==-100 then
         [%win,Cmenu] = resume(curwin,'Quit') ;
    end

    //**------------------------------------------------------------------
      //** Mouse movement limitation
       if rep(1)>x_min & rep(1)<x_max
	   xc1 = rep(1)
       end

       if rep(2)>y_min & rep(2)<y_max
	   yc1 = rep(2)
       end
    //**------------------------------------------------------------------

    x1(2) = X1(2) - (xc - xc1) ;
    y1(2) = Y1(2) - (yc - yc1) ;
    rect_now  = [min([gh_blk.children(1).data(:,1)])+(max([gh_blk.children(1).data(:,1)])-min([gh_blk.children(1).data(:,1)]))/2 ,...
                 min([gh_blk.children(1).data(:,2)])+(max([gh_blk.children(1).data(:,2)])-min([gh_blk.children(1).data(:,2)]))/2]
    gh_blk.children(2).data=[gh_blk.children(2).data(1,1) - (rect(1)-rect_now(1)),...
                             gh_blk.children(2).data(1,2) - (rect(2)-rect_now(2))]
  end //** of the while "interactive" loop  
  //**------------------------------------------------------------------

  gh_figure = gcf();
  gh_figure.pixel_drawing_mode = "copy"
  if gh_figure.figure_id<>curwin | rep(3)==-100 then
      [%win,Cmenu] = resume(curwin,'Quit') ;
  end

  if %scicos_debug_gr then
    disp("...subsegment -> Link move --> rep(3):..."); disp(rep(3)) ;
  end

  if and(rep(3)<>[2 5]) then //** if the link manipulation is OK 
    rect  = [min(gh_blk.children(1).data(:,1))+(max(gh_blk.children(1).data(:,1))-min(gh_blk.children(1).data(:,1)))/2 ,...
             min(gh_blk.children(1).data(:,2))+(max(gh_blk.children(1).data(:,2))-min(gh_blk.children(1).data(:,2)))/2]
    if abs(x1(1)-x1(2))<rela*abs(y1(1)-y1(2)) then
      x1(2)=x1(1)
    elseif abs(x1(2)-x1(3))<rela*abs(y1(2)-y1(3)) then
      x1(2)=x1(3)
    end  
    if abs(y1(1)-y1(2))<rela*abs(x1(1)-x1(2)) then
      y1(2)=y1(1)
    elseif abs(y1(2)-y1(3))<rela*abs(x1(2)-x1(3)) then
      y1(2)=y1(3)
    end  
    d = projaff([x1(1);x1(3)],[y1(1);y1(3)],[x1(2);y1(2)])
    if norm(d(:)-[x1(2);y1(2)])<..
	  rela*max(norm(d(:)-[x1(3);y1(3)]),norm(d(:)-[x1(1);y1(1)])) then
      xx(moving_seg)=x1
      yy(moving_seg)=y1
      xx(moving_seg(2))=[]
      yy(moving_seg(2))=[]
      x1(2)=[];y1(2)=[];moving_seg(3)=[]
    else
      xx(moving_seg)=x1
      yy(moving_seg)=y1
    end
    
    //** update the graphics object with the last link geometrical
    //correction 
    o.xx = xx; o.yy = yy ;
//    o=scicos_route(o,scs_m)  // to be done later

    drawlater();
    
    gh_blk.children(1).data = [o.xx , o.yy];

    rect_now = [min(xx)+(max(xx)-min(xx))/2 , min(yy)+(max(yy)-min(yy))/2]
    gh_blk.children(2).data=[gh_blk.children(2).data(1,1) - (rect(1)-rect_now(1)),...
                             gh_blk.children(2).data(1,2) - (rect(2)-rect_now(2))]
 
    draw(gh_blk.parent);
    show_pixmap();
    scs_m.objs(k)=o ; //** update the scs_m data structure

  else //** restore original position of link in figure
    
    drawlater();
    gh_blk.children(1).data = ini_data;
    gh_blk.children(2).data = ini_data_id;
    draw(gh_blk.parent);
    show_pixmap();
    
    //** DO NOT update the scs_m datastructure ! ;)
  
  end

endfunction
