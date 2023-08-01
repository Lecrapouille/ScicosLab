function [scs_m,needcompile]=do_ttkplaceindiagram(scs_m,blk,needcompile)

  xm = 100; ym = 100;
  xy =[xm,ym] ;
  blk.graphics.orig = xy

  xinfo('Click where you want object to be placed (right-click to cancel)');

  gh_curwin=scf(curwin);
  xselect();
  gh_blk=drawobj(blk);

  GetMyTCLVars(gh_curwin)
  TCL_EvalStr('catch {.palettes.note.f.t state disabled}')
  TCL_EvalStr('catch {bind .palettes.note.f.t <B1-Motion> '"MotionTree %W %x %y'"}')

  drawlater();
  rep(3)=-1 ;

  while rep(3)==-1

    TkActivated = evstr(TCL_GetVar('TkActivated'))

    if ~TkActivated then
      rep = xgetmouse(0,[%t,%t]);
    else
      rep = TCL_xgetmouse(gh_curwin);
    end

    if or(rep(3)==[2 5 -3]) then
      break
    end

    //** Protection from window closing
    if rep(3)==-100 then //active window has been closed
      [%win,Cmenu] = resume(curwin,'Quit')
    end

    if %scicos_snap then
      SnapIncX = %scs_wgrid(1)
      SnapIncY = %scs_wgrid(2)
      if abs( floor(rep(1)/SnapIncX)-(rep(1)/SnapIncX) ) <...
        abs(  ceil(rep(1)/SnapIncX)-(rep(1)/SnapIncX) )
        dx  = floor((rep(1)-xm)/SnapIncX)*SnapIncX;
        xm = floor(rep(1)/SnapIncX)*SnapIncX ;
      else
        dx  = ceil((rep(1)-xm)/SnapIncX)*SnapIncX;
        xm = ceil(rep(1)/SnapIncX)*SnapIncX ;
      end
      if abs( floor(rep(2)/SnapIncY)-(rep(2)/SnapIncY) ) <...
        abs(  ceil(rep(2)/SnapIncY)-(rep(2)/SnapIncY) )
        dy  = floor((rep(2)-ym)/SnapIncY)*SnapIncY;
        ym = floor(rep(2)/SnapIncY)*SnapIncY ;
      else
        dy  = ceil((rep(2)-ym)/SnapIncY)*SnapIncY;
        ym = ceil(rep(2)/SnapIncY)*SnapIncY ;
      end
    else
      dx  = rep(1) - xm
      dy  = rep(2) - ym
      xm = rep(1)
      ym = rep(2)
    end

    move (gh_blk , [dx dy]);
    draw(gh_blk.parent);
    show_pixmap();

    %xc = xm
    %yc = ym

  end //** ---> of the while loop

  TCL_EvalStr('catch {.palettes.note.f.t state !disabled}')
  TCL_EvalStr('global B1Release;set B1Release 0')
  TCL_EvalStr('global B3Release;set B3Release 0')
  TCL_EvalStr('global TkActivated;set TkActivated 0')

  //** window closing protection
  if xget('window') <> curwin then
    [%win,Cmenu]=resume(curwin,'Quit')
  end
  xinfo(' ')
  scs_m_save=scs_m;
  if and(rep(3)<>[2 5 -3]) then
    xy = [%xc,%yc];
    blk.graphics.orig=xy;
    scs_m.objs($+1) = blk 
    needcompile = 4
    nc_save=needcompile;  
    [scs_m_save, nc_save, enable_undo, edited] = resume(scs_m_save,nc_save,%t,%t)
  else
    if rep(3)==-3 then
      TCL_EvalStr('global B3Release;set B3Release 1')
      TCL_EvalStr('catch {bind .palettes.note.f.t <ButtonRelease-1> '"global B3Release;set B3Release 0'"}')
    end
    delete(gh_blk);
    gh_a = gca();
    draw(gh_a);
    show_pixmap();
  end

endfunction

function [rep]=TCL_xgetmouse(gh_curwin)
    [fx,fy,fw,fh,bdxl,bdyt]=GetMyTCLVars(gh_curwin)
    vv=xget('viewport');
    xxm=evstr(TCL_EvalStr("winfo pointerx .palettes"));
    yym=evstr(TCL_EvalStr("winfo pointery .palettes"));
    [xrep,yrep,rect]=xchange(xxm-fx+vv(1)-bdxl,yym-fy+vv(2)-bdyt,"i2f"); //OK

    B1Release = evstr(TCL_GetVar('B1Release'))
    B3Release = evstr(TCL_GetVar('B3Release'))

    if B3Release==1 then
      ibutton=-3
    else
      if B1Release==1 then
        ibutton = -5
      elseif B1Release==2 then
        ibutton = B1Release
      else
        ibutton = -1
      end
    end

    rep=[xrep yrep ibutton];

    sleep(1);
endfunction

function [fx,fy,fw,fh,bdxl,bdyt]=GetMyTCLVars(gh_curwin)
    //figure and axe properties
    fx  = gh_curwin.figure_position(1);
    fy  = gh_curwin.figure_position(2);
    fw  = gh_curwin.figure_size(1);
    fh  = gh_curwin.figure_size(2);

    //border size
    // bdxl : border size x left
    // bdyt : border size y top
    // bdxr,bdyb etc...
    if with_gtk() then
      bdxl=5
      bdyt=71
      bdxr=5
      bdyb=-60
    elseif MSDOS then
      bdxl=5
      bdyt=50
      bdxr=10
      bdyb=-110
    else
      bdxl=0
      bdyt=0
      bdxr=0
      bdyb=0
    end

    //TclSetVar
    TCL_EvalStr('global fx;set fx '"'+string(fx)+''";');
    TCL_EvalStr('global fy;set fy '"'+string(fy)+''";');
    TCL_EvalStr('global fw;set fw '"'+string(fw)+''";');
    TCL_EvalStr('global fh;set fh '"'+string(fh)+''";');
    TCL_EvalStr('global bdxl;set bdxl '"'+string(bdxl)+''";');
    TCL_EvalStr('global bdyt;set bdyt '"'+string(bdyt)+''";');
    TCL_EvalStr('global bdxr;set bdxr '"'+string(bdxr)+''";');
    TCL_EvalStr('global bdyb;set bdyb '"'+string(bdyb)+''";');
endfunction
