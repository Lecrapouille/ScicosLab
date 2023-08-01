function ttk_message_modeless(strings)
//** ttk_message_modeless : overlad function for x_message_modeless
//**                  inside scicos

  //** check lhs/rhs arg
  [lhs,rhs]=argn(0)

  if rhs<>1 then
    error(77)
  end

  if type(strings)<>10 then
    error(207,1)
  end

  if rhs>2 then
    error(77)
  end

  strings=strings(:);

  //** create tcl/tk box txt
  display_message_box(strings)

endfunction

//** display_message_box : create txt of the Tcl/Tk box
function display_message_box(str_in)
  //** check lhs/rhs arg
  [lhs,rhs]=argn(0)

  //## input param of editor
  if MSDOS then
    InFile = strsubst(TMPDIR,'/','\')+'\TTMPin';
    InFile = strsubst(InFile,'\','\\\\')';
  else
    InFile = TMPDIR+'/TTMPin';
  end

  //## compute max_l/max_h
  max_h = size(str_in,1)
  max_l = max(length(str_in))
  if max_h<15 then max_h=15, end
  if max_h>40 then max_h=40, end
  max_h=max_h
  if max_l<30 then max_l=30, end
  if max_l>80 then max_l=80, end
  max_l=max_l+2

  //## store input txt in file buffer
  if MSDOS then
    mputl(str_in,strsubst(InFile,'\\\\','\'));
  else
    mputl(str_in,InFile);
  end

  //## Init TCL/TK sciGUI interf
  sciGUI_init();
  TCL_EvalFile(SCI+'/macros/scicos/ttk_scicos_widgets.tcl');

  //** retrieve current postion of the last dialog box
  //** potential TCL global variables numx/numy
  numx=-1
  numy=-1

  if TCL_ExistVar('numx') then
    numx=TCL_GetVar('numx')
  else
    if TCL_ExistVar('numxgetvalue') then
      numx=TCL_GetVar('numxgetvalue')
    end
  end
  if TCL_ExistVar('numy') then
    numy=TCL_GetVar('numy')
  else
    if TCL_ExistVar('numygetvalue') then
      numy=TCL_GetVar('numygetvalue')
    end
  end
  //## Initial variables
  if ~TCL_ExistVar('fontsz') then
    TCL_EvalStr('global fontsz')
    TCL_EvalStr('set fontsz 10')
  end
  if ~TCL_ExistVar('fonttyp') then
    TCL_EvalStr('global fonttyp')
    TCL_EvalStr('set fonttyp '"Arial'"')
  end
  if ~TCL_ExistVar('fontstyle1') then
    TCL_EvalStr('global fontstyle1')
    TCL_EvalStr('set fontstyle1 '"0'"')
  end
  if ~TCL_ExistVar('fontstyle2') then
    TCL_EvalStr('global fontstyle2')
    TCL_EvalStr('set fontstyle2 '"0'"')
  end
  if ~TCL_ExistVar('fontstyle3') then
    TCL_EvalStr('global fontstyle3')
    TCL_EvalStr('set fontstyle3 '"0'"')
  end
  if ~TCL_ExistVar('fontstyle') then
    TCL_EvalStr('global fontstyle')
    TCL_EvalStr('set fontstyle '"normal'"')
  end
  if ~TCL_ExistVar('TkTheme') then
    TCL_EvalStr('global TkTheme')
    TCL_EvalStr('set TkTheme '"clam'"')
  end
  if ~TCL_ExistVar('with_tool') then
    TCL_EvalStr('global with_tool')
    TCL_EvalStr('set with_tool 1')
  end
  if ~TCL_ExistVar('with_tool_tk') then
    TCL_EvalStr('global with_tool_tk')
    TCL_EvalStr('set with_tool_tk '"1'"')
  end
  if ~TCL_ExistVar('with_but') then
    TCL_EvalStr('global with_but')
    TCL_EvalStr('set with_but '"1'"')
  end

  TCL_EvalStr('global activback;set activback '"RoyalBlue'"')
  TCL_EvalStr('global activfor;set activfor '"white'"')
  TCL_EvalStr('global activbrd;set activbrd  1');

  //## run get info
  TCL_EvalStr('GetInfo '+InFile+' '+...
              string(max_l)+' '+string(max_h)+' '+...
              string(numx)+' '+string(numy));


endfunction
