function num=ttk_message(strings,buttons)
//** ttk_scs_message : overlad function for x_message
//**                  inside scicos

  //** check lhs/rhs arg
  [lhs,rhs]=argn(0)

  if rhs==0 then
    error(77)
  end

  if type(strings)<>10 then
    error(207,1)
  end

  if rhs==1 then
    buttons="Ok"
  end

  if rhs==2 then
    if type(buttons)<>10 then
      error(207,2)
    end
  end

  if rhs>2 then
    error(77)
  end

  //** format param
  buttons=buttons(:)
  if size(buttons,1)>2 then
    buttons=buttons(1)
  end

  strings=strings(:);

  //** create tcl/tk box txt
  txt=create_message_box(strings,buttons)

  //**
  done="0";
  while done<>"1" & done<>"2" then
    TCL_EvalStr(txt)
    done=TCL_GetVar('done')

    if done=="1" | done=="2" then
      TCL_EvalStr('destroy $w')
    end
    if done=="3" & (rhs==1 | size(buttons,1)==1) then
      done="1"
    else
      txt=create_message_box(strings,buttons)
    end
  end

  //**
  if rhs==1 | size(buttons,1)==1 then
    num=1;
  else
    num=evstr(done);
  end

endfunction

//** create_message_box : create txt of the Tcl/Tk box
function str_out=create_message_box(str_in,but_lab)

  //** check lhs/rhs arg
  [lhs,rhs]=argn(0)


  //## Init TCL/TK sciGUI interf
  [numx,numy,ledtx,ledty,...
       InFile,OutFile,HelpFile]=get_ttk_vars('message')

  //** substitute special characters
  str_in=sci2tcl(str_in)

  //**generate widgets for buttons
  but_txt=[];
  but_tt='';
  for i=1:size(but_lab,1)
     if i==1 then
       but_txt=[but_txt;
                'ttk::button $w.m.bot.but'+string(i)+' -text ""'+sci2tcl(but_lab(i))+...
                   '"" -command {set done '+string(i)+'} -default active']
     else
       but_txt=[but_txt;
                'ttk::button $w.m.bot.but'+string(i)+' -text ""'+sci2tcl(but_lab(i))+...
                   '"" -command {set done '+string(i)+'}']
     end
     but_tt=but_tt+'$w.m.bot.but'+string(i)+' ';
  end

  if size(but_lab,1)==3 then
    but_tt = ['pack $w.m.bot.but1 -side right -padx 1m -pady [list 0 1m]'
              'pack $w.m.bot.but2 -side right -padx 1m -pady [list 0 1m]'
              'pack $w.m.bot.but3 -side left -padx 1m -pady [list 0 1m]']

  elseif size(but_lab,1)==2
    but_tt = ['pack $w.m.bot.but1 -side right -padx 1m -pady [list 0 1m]'
              'pack $w.m.bot.but2 -side left -padx 1m -pady [list 0 1m]']
  elseif size(but_lab,1)==1
    but_tt = ['pack $w.m.bot.but1 -side right -padx 1m -pady [list 0 1m]']
  else
    but_tt = 'pack '+but_tt+' -side left -padx 1m -pady [list 0 1m]'
  end

  //** if only one button then press return is allowed
  if size(but_lab,1)==1 then
    bind_tt=['bind $w <Return> {set tt [wm geometry $w];'+...
             'regexp -- {([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)} '+...
             '$tt -> width height numx numy;set done 1}']
  else
    bind_tt=""
  end


  str_out=['set w .form'
           'global TkTheme'
           'set Gifpath '"$env(SCIPATH)/macros/scicos/scicos_doc/man/gif_icons'"'
           'catch {destroy $w}'
           'toplevel $w'
           'set numx '+numx
           'set numy '+numy
           'wm geometry $w +$numx+$numy'
           'wm title $w '"Scicos Information'"'
           'wm iconname $w '"form'"'
           '#### create a main frame ####'
           'ttk::frame $w.m'
           'pack $w.m -expand yes -fill both'
           '#### create two frame ####'
           'ttk::labelframe $w.m.top -text '" Message '"'
           'pack $w.m.top -expand yes -fill both -padx 1m -pady [list 1m 1m]'
           'ttk::label $w.m.top.msg -anchor center -text ""'+str_in+'"" '+...
              '-width -40 -padding [list 0 3m 0 3m] -background white '
           'pack $w.m.top.msg -expand yes -fill both'
           ''
           'ttk::frame $w.m.bot'
           'pack $w.m.bot -expand no -fill x'
            but_txt
            but_tt
           ''
           'set done 0'
            bind_tt
           'bind $w <Destroy> {set tt [wm geometry $w];'+...
             'regexp -- {([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)} '+...
             '$tt -> width height numx numy;set done 3}'
           'catch {grab set $w}'
           'wm iconphoto $w [image create photo -file '"$Gifpath/puffin-gtk48.gif'"]'
           'wm attributes $w -topmost 1'
           'focus -force $w'
           'ttk::setTheme $TkTheme'
           'if {$TkTheme=='"vista'"} '"wm attributes $w -toolwindow 1'"'
           'if {$TkTheme=='"xpnative'"} '"wm attributes $w -toolwindow 1'"'
           'if {$TkTheme=='"winnative'"} '"wm attributes $w -toolwindow 1'"'
           'tkwait variable done']
endfunction
