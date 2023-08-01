function tk_message_modeless(strings)
// Copyright INRIA
//** tk_message_modeless : overlad function for x_message_modeless
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
  TCL_EvalFile(SCI+'/macros/scicos/scstxtedit.tcl');

  //** retrieve current postion of the last dialog box
  //** potential TCL global variables numx/numy
  if TCL_ExistVar('numx') then
    numx=TCL_GetVar('numx')
  else
    numx=-1
  end
  if TCL_ExistVar('numy') then
    numy=TCL_GetVar('numy')
  else
    numy=-1
  end

  //## run get info
  TCL_EvalStr('GetInfo '+InFile+' '+...
              string(max_l)+' '+string(max_h)+' '+...
              string(numx)+' '+string(numy));
endfunction
