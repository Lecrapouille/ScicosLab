function result=ttk_mdialog(titlex,items,init)
  if argn(2)<1 then
    titlex=['this is a demo';'this is a demo']
    items=['item 1';'item 2']
  end
  if argn(2)<3 then
    init=['init 1';'init 2']
  end
  titlex=sci2tcl(titlex);
  for i=1:size(items,'*')
    items(i)=sci2tcl(items(i))
    init(i)=sci2tcl(init(i))
  end
  txt=tk_create_txt(titlex,items,init);
  result=[];
  TCL_EvalStr(txt)
  done=TCL_GetVar('done')
  if done==string(1) then
    for i=1:size(items,'*')
      execstr('result(i)=TCL_GetVar(''x'+string(i)+''')')
    end
  end
  TCL_EvalStr('destroy $www')
endfunction

function txt=tk_create_txt(titlex,items,init)
  [numx,numy,ledtx,ledty,...
       InFile,OutFile,HelpFile]=get_ttk_vars('message')

  txt=['set www .formxx'
       'global TkTheme'
       'set Gifpath '"$env(SCIPATH)/macros/scicos/scicos_doc/man/gif_icons'"'
       'catch {destroy $www}'
       'toplevel $www'
       'set numx '+numx
       'set numy '+numy
       'wm geometry $www +$numx+$numy'
       'wm title $www '"Set Block properties'"'
       'wm iconname $www '"form'"'
       '#positionWindow $www'
       'ttk::label $www.msg  -wraplength 4i -anchor c -text '"'+titlex+''"'
       'ttk::frame $www.buttons'
       'pack $www.buttons -fill x -side bottom -pady [list 1m 1m] -expand no'
       'ttk::button $www.buttons.code -text OK -command {set done 1} -default active'
       'bind $www.buttons.code <Key-Return> {set done 1}'
       'ttk::button $www.buttons.dismiss -text Cancel -command {set done 2}'
       'pack $www.buttons.code -side right -padx 1m'
       'pack $www.buttons.dismiss -side left -padx 1m'];

  for i=1:size(items,'*')
    txt=[txt
         'ttk::frame $www.f'+string(i)+''
         'ttk::entry $www.f'+string(i)+'.entry -width 40'
         'ttk::label $www.f'+string(i)+'.label'
         'pack $www.f'+string(i)+'.entry -side right -padx [list 1m 0]'
         'pack $www.f'+string(i)+'.label -side left'];
  end
  for i=1:size(items,'*')
    txt=[txt
         '$www.f'+string(i)+'.label config -text '"'+items(i)+''"'];
  end
  for i=1:size(items,'*')
    txt=[txt
         '$www.f'+string(i)+'.entry insert 0 '"'+init(i)+''"'
         'bind $www.f'+string(i)+'.entry <Key-Return> {focus [tk_focusNext %W]}'];
  end

  tt=''
  for i=1:size(items,'*')
    tt=tt+'global x'+string(i)+';set x'+string(i)+' [$www.f'+string(i)+'.entry get];'
  end
  txt=[txt;
       'proc done1 {www} {'+tt+'}']
  tt=''
  for i=1:size(items,'*')
    tt=tt+'$www.f'+string(i)+' '
  end
  txt=[txt;
       'pack $www.msg '+tt+'-side top -fill x -padx 1m -pady [list 0 1m]'
       'focus $www.f1.entry'
       'set done 0'
       'bind $www <Destroy> {set done 2}'
       'wm iconphoto $www [image create photo -file '"$Gifpath/puffin-gtk48.gif'"]'
       'wm attributes $www -topmost 1'
       'focus -force $www'
       'ttk::setTheme $TkTheme'
       'if {$TkTheme=='"xpnative'"} '"wm attributes $www -toolwindow 1'"'
       'if {$TkTheme=='"vista'"} '"wm attributes $www -toolwindow 1'"'
       'if {$TkTheme=='"winnative'"} '"wm attributes $www -toolwindow 1'"'
       'tkwait variable done'
       'if {$done==1} {done1 $www}']
endfunction
