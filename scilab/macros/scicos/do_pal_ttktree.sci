function scs_m = do_pal_ttktree(scicos_pal)
// Copyright INRIA

  scs_m = get_new_scs_m();
  scs_m.props.title(1) = 'Palettes';
  sup = SUPER_f('define');

  for i=1:size(scicos_pal,1)
    o = sup;
    o.model.rpar = charge(scicos_pal(i,:)); //** local functions:
                                            //** see below in this file
    scs_m.objs(i) = o;
  end

  tt = pal_TreeView(scs_m); //** local functions: see below in this file
  cur_wd = getcwd();
  chdir(TMPDIR);
  mputl(tt,scs_m.props.title(1)+'.tcl');
  chdir(cur_wd)
  TCL_EvalFile(TMPDIR+'/'+scs_m.props.title(1)+'.tcl'); 
endfunction
//**-----------------------------------------------------------------------

function scs_m=charge(pal)
  [ok,scs_m,cpr,edited]=do_load(pal(2),'palette')
  if ok & size(scs_m.objs)>0 then
    scs_m.props.title(1)=pal(1)
  else
    scs_m = get_new_scs_m();
    scs_m.props.title(1)='error loading '+pal(1)
  end
endfunction
//**------------------------------------------------------------------------

function tt = pal_TreeView(scs_m)
  [numx,numy,ledtx,ledty,...
       InFile,OutFile,HelpFile]=get_ttk_vars('paltree')

  tt=['proc MotionBlock {ww} {'
      '  set whxy [winfo geometry $ww]'
      '  regexp -- {([0-9]+)x([0-9]+)\+([-]*[0-9]+)\+([-]*[0-9]+)} $whxy -> w h x y'
      '  set xm [winfo pointerx $ww]'
      '  set ym [winfo pointery $ww]'
      '  set xm [expr $xm-$w/2]'
      '  set ym [expr $ym-$h/2]'
      '  wm geometry $ww +${xm}+${ym}'
      '}'
      ''
      'proc GetBlockImg {img} {'
      '  set ww .block'
      '  catch {destroy $ww}'
      '  toplevel $ww'
      '  wm overrideredirect $ww 1'
      '  wm attributes $ww -topmost 1'
      '  ttk::label $ww.l -image $img'
      '  pack $ww.l -expand yes -fill both'
      '  update'
      '  MotionBlock $ww'
      '  bind .block <Motion> '"MotionBlock $ww'"'
      '  bind .block <Leave> '"MotionBlock $ww'"'
      '  bind .block <FocusOut> '"MotionBlock $ww'"'
      '  bind .block <3> '"destroy $ww'"'
      '  bind .block <1> '"destroy $ww'"'
      '  return $ww'
      '}'
      ''
      'proc GetRootLst {wt item} {'
      '  set rootlst {}'
      '  set parent [$wt parent $item]'
      '  if {$parent!={}} {'
      '    set index [$wt index $parent]'
      '    set rootlst [linsert $rootlst 0 [expr $index+1]]'
      '  }'
      '  while {$parent!={}} {'
      '    set parent [$wt parent $parent]'
      '    if {$parent!={}} {'
      '      set index [$wt index $parent]'
      '      set rootlst [linsert $rootlst 0 [expr $index+1]]'
      '    }'
      '  }'
      '  set index [$wt index $item]'
      '  set rootlst [linsert $rootlst end [expr $index+1]]'
      '  set rootlst [linsert $rootlst 0 root]'
      '  return $rootlst'
      '}'
      ''
      'proc IsInTree {wxx} {'
      '  set whxy [winfo geometry $wxx]'
      '  regexp -- {([0-9]+)x([0-9]+)\+([-]*[0-9]+)\+([-]*[0-9]+)} $whxy -> w h x y'
      '  set xr [expr $x + $w]'
      '  set yr [expr $y + $h]'
      '  set xm [winfo pointerx $wxx]'
      '  set ym [winfo pointery $wxx]'
      '  set MyCond [expr {$xm>=$x && $xm<=$xr && $ym>=$y && $ym<=$yr}]'
      '  return $MyCond'
      '}'
      ''
      'proc DoubleClickTree {wt x y} {'
      '  set item [$wt identify row $x $y]'
      '  if [$wt instate {!disabled}] {'
      '    set rootlst [GetRootLst $wt $item]'
      '    set label [join $rootlst '",'"]'
      '    set parent [$wt parent $item]'
      '    if {$parent!={}} {'
      '      set img [$wt item $item -image]'
      '      #GetBlockImg $img'
      '      global TkActivated'
      '      set TkActivated 0'
      '      global blko'
      '      set blko $label'
      '      ScilabEval '"Cmenu=''PlaceinDiagram'''"'
      '    }'
      '  }'
      '}'
      ''
      'proc MotionTree {wt x y} {'
      '  global B3Release'
      '  if {$B3Release==0} {' 
      '    set item [$wt identify row $x $y]'
      '    if [$wt instate {!disabled}] {'
      '      set item [$wt selection]'
      '      set rootlst [GetRootLst $wt $item]'
      '      set label [join $rootlst '",'"]'
      '      set parent [$wt parent $item]'
      '      if {$parent!={}} {'
      '        global blko'
      '        set blko $label'
      '        global TkActivated'
      '        set TkActivated 1'
      '        ScilabEval '"Cmenu=''PlaceinDiagram'''"'
      '      }'
      '    } else {'
      '      global fx;global fy;global fw;global fh;global bdxl;global bdyt;global bdxr;global bdyb;'
      '      set xm [winfo pointerx $wt]'
      '      set ym [winfo pointery $wt]'
      '      set fxl [expr $fx + $bdxl]'
      '      set fyt [expr $fy + $bdyt]'
      '      set fxr [expr $fx + $fw - $bdxr]'
      '      set fyb [expr $fy + $fh - $bdyb]'
      '      set MyCond [expr {$xm>=$fxl && $xm<=$fxr && $ym>=$fyt && $ym<=$fyb}]'
      '      if $MyCond {'
      '        bind $wt <ButtonRelease-1> {'
      '          global B1Release'
      '          set B1Release 1'
      '        }'
      '        bind $wt <ButtonRelease-3> {'
      '          global B3Release'
      '          set B3Release 1'
      '        }'
      '      } else {'
      '        bind $wt <ButtonRelease-1> {'
      '          global B1Release'
      '          set B1Release 2'
      '        }'
      '      }'
      '    }'
      '  }'
      '}'
      ''
      'proc RightClickTree {wt x y} {'
      '  set item [$wt identify row $x $y]'
      '  if [$wt instate {!disabled}] {'
      '    global TkActivated'
      '    set TkActivated 0'
      '    $wt selection set $item'
      '    set rootlst [GetRootLst $wt $item]'
      '    set label [join $rootlst '",'"]'
      '    global blko'
      '    set blko $label'
      '    ScilabEval '"Cmenu=''TkPopup'''"'
      '  }'
      '}'
      ''
      'global TkTheme'
      'set Gifpath '"$env(SCIPATH)/macros/scicos/scicos_doc/man/gif_icons'"'
      ''
      'set wxx .palettes'
      'catch {destroy $wxx}'
      'toplevel $wxx'
      ''
      'set numx '+numx
      'set numy '+numy
      'wm geometry $wxx +$numx+$numy'
      ''
      'ttk::setTheme $TkTheme'
      'if {$TkTheme=='"xpnative'"} '"wm attributes $wxx -toolwindow 1'"'
      'if {$TkTheme=='"vista'"} '"wm attributes $wxx -toolwindow 1'"'
      'if {$TkTheme=='"winnative'"} '"wm attributes $wxx -toolwindow 1'"'
      ''
      'ttk::frame $wxx.fmsg'
      'grid $wxx.fmsg -row 0 -sticky ew -pady 0.5m -padx 1m'
      ''
      'set head '"Pal Tree'"'
      'ttk::label $wxx.fmsg.head -text $head -background white -wraplength 4i -anchor c'
      'grid $wxx.fmsg.head -sticky ew -ipady 0m'
      ''
      'set head1 '"- Double click : Place the selection in the diagram.\n'"'
      'set head2 '"- Right click : Open popup menu.\n'"'
      'set head3 '"- Motion : Drag the selection in the diagram.'"'
      'set head $head1$head2$head3'
      ''
      'ttk::label $wxx.fmsg.msg1 -text $head -background white -wraplength 4i -justify left'
      'grid $wxx.fmsg.msg1 -sticky ew -ipady 1m'
      'grid columnconfigure $wxx.fmsg $wxx.fmsg.head -weight 1'
      ''
      'ttk::notebook $wxx.note'
      'grid $wxx.note -row 1 -sticky nsew -pady [list 0.5m 0] -padx [list 1m 1m]'
      ''
      'ttk::frame $wxx.note.f'
      'pack $wxx.note.f -expand yes -fill both'
      ''
      'ttk::style configure Ma.Treeview -rowheight 52'
      ''
      'ttk::treeview $wxx.note.f.t -xscrollcommand '"$wxx.note.f.xsb set'" -yscrollcommand '"$wxx.note.f.ysb set'" -style Ma.Treeview -show {tree}'
      ''
      'ttk::scrollbar $wxx.note.f.ysb -command '"$wxx.note.f.t yview'" -orient vertical'
      'ttk::scrollbar $wxx.note.f.xsb -command '"$wxx.note.f.t xview'" -orient horizontal'
      ''
      'pack $wxx.note.f.ysb -expand no -fill y -side right'
      'pack $wxx.note.f.xsb -expand no -fill x -side bottom'
      'pack $wxx.note.f.t -expand yes -fill both'
      '' 
     ];

  tt = [tt; 'wm title $wxx '+scs_m.props.title(1) ];
  Pgif = %scicos_gif;
  GIFT = listfiles(Pgif+'*.gif');
  GIFT = strsubst(GIFT,'\','/');
  GIF  = [];

  for i=1:size(GIFT,1)
    [jxpath,Gname,jext] = splitfilepath_cos(GIFT(i));
    GIF = [GIF;Gname];
  end

  Path = 'root'
  tt = crlist(scs_m, Path, tt);
  tt = [tt;
        '$wxx.note add $wxx.note.f -text '"Pal tree'"'
        'grid rowconfigure $wxx 0 -weight 0'
        'grid rowconfigure $wxx 1 -weight 1'
        'grid columnconfigure $wxx 0 -weight 1'
        'bind $wxx.note.f.t <Double-ButtonRelease-1> '"DoubleClickTree %W %x %y'"'
        'bind $wxx.note.f.t <B1-Motion> '"MotionTree %W %x %y'"'
        'bind $wxx.note.f.t <3> '"RightClickTree %W %x %y'"'
        'bind $wxx.note.f.t <ButtonPress-1> {'
        '  global B1Release'
        '  global B3Release'
        '  set B1Release 0'
        '  set B3Release 0'
        '}'
        'bind $wxx.note.f.t <ButtonRelease-1> {'
        '  global B1Release'
        '  set B1Release 0'
        '}'
        'global B3Release'
        'set B3Release 0'
        'bind $wxx.note.f.t <ButtonRelease-3> {'
        '  global B3Release'
        '  set B3Release 0'
        '}'
        ''
        '## special bind to take the focus in ScicosLab'
        'bind $wxx <<GraphTakeFocus>> '"wm attributes $wxx -topmost 1;wm attributes $wxx -topmost 0'"'
        ''
        'wm iconphoto $wxx [image create photo -file '"$Gifpath/puffin-gtk48.gif'"]'
        'update'
        ''
        'bind $wxx <Destroy> {set tt [wm geometry $wxx];'+...
          'regexp -- {([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)} '+...
           '$tt -> lxptree lyptree numxptree numyptree}'];
endfunction
//**-----------------------------------------------------------------------------

//**================================================================
//TCL_EvalStr('$wxx.note.f.t opentree node1')
//   pa=TCL_GetVar('x');pa=part(pa,6:length(pa));
//   execstr('pa=list('+pa+')');       o=scs_m(scs_full_path(pa))
//**================================================================

function tt = crlist(scs_m,Path,tt)
  blocks_to_remove=['CLKSPLIT_f' 'SPLIT_f' 'IMPSPLIT_f']

  for i=1:size(scs_m.objs)
    o=scs_m.objs(i);
    path=Path+'_'+string(i)

    if typeof(o)=="Link" then
      //titre2='link'
      //tt=[tt;'$wxx.note.f.t insert end '+Path+' '+path+' -text '"'+titre2+''"']

    elseif typeof(o)=="Deleted" then
      //titre2='Deleted'
      //tt=[tt;'$wxx.note.f.t insert end '+Path+' '+path+' -text '"'+titre2+''"']

    else //** Blocks and Super Blocks :)

      if (o.model.sim=='super'&(o.model.rpar.props.title(1)<>'Super Block')) |...
         (o.gui=='PAL_f') then

        //** Super Blocks
        titre2 = o.model.rpar.props.title(1);
        if Path=="root" then
          tt = [tt;'set '+path+' [$wxx.note.f.t insert {} end -text '"'+titre2+''"]']
        else
          tt = [tt;'set '+path+' [$wxx.note.f.t insert $'+Path+' end -text '"'+titre2+''"]']
        end
        tt = crlist(o.model.rpar,path,tt)
      else
        //** Standard Blocks
        if (find(o.gui==blocks_to_remove(:)))==[] then
          titre2 = o.gui;
          ind = find(titre2==GIF);
          if ind<>[] then
             //** a valid icon (GIF) is found
             tt = [tt;'$wxx.note.f.t insert $'+Path+' end "+...
                   "-text '"'+titre2+''" -image [image create photo -file '"'+GIFT(ind($))+''"]']
          else
            //** NO icon is found: use the block's name
            tt = [tt;'$wxx.note.f.t insert $'+Path+' end -text '"'+titre2+''"']
          end
        end
      end //**... Blocks ans Super Blocks
    end //**.. object filter
  end //**.. object loop
endfunction
