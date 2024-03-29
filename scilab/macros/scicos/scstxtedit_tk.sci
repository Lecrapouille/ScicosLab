//## scstxtedit_tk : a tcl/tk text editor for Scicos
//## author : Alan Layec, xx/xx/08

//## Mopen open a new file in the buffer
//## Recompute the size of the displayed window
//##
//## Inputs : InFile : path+name of file of the input buffer
//##          winId : the Id number of the block editor
//##
function Mopen(InFile,winId)
  //## get the input buffer
  if MSDOS then
    str_in=mgetl(strsubst(InFile,'\\\\','\'))
  else
    str_in=mgetl(InFile)
  end

  //## compute max_l/max_h
  max_h = size(str_in,1)
  max_l = max(length(str_in))
  if max_h<15 then max_h=15, end
  if max_h>45 then max_h=45, end
  max_h=max_h+2
  if max_l<30 then max_l=30, end
  if max_l>80 then max_l=80, end
  max_l=max_l+5

  //## configure $w.text widget size from new max_l/max_h
  TCL_EvalStr('set w [sciGUIName '+string(winId)+']')
  TCL_EvalStr('wm geometry $w {}')
  TCL_EvalStr('$w.text configure -height '+string(max_h)+...
                 ' -width '+string(max_l))
endfunction

//## ToCos return the text of the output buffer
//## in scilab
//##
//## Inputs : InFile : path+name of file of the input buffer
//##          OutFile : path+name of file of the output buffer
//##          winId : the Id number of the block editor
//##
function txt=ToCos(InFile,OutFile,winId)
  if MSDOS then
    txt=mgetl(strsubst(OutFile+winId,'\\\\','\'));
  else
    txt=mgetl(OutFile+winId);
  end
  //mputl(txt,InFile+winId);
endfunction

//## Quit exit from the block editor
//##
//## Inputs : InFile : path+name of file of the input buffer
//##          OutFile : path+name of file of the output buffer
//##          winId : the Id number of the block editor
//##
function Quit=Mquit(InFile,OutFile,winId)
 //## get input/output text of the buffer
 if MSDOS then
   txt_out = mgetl(strsubst(OutFile+winId,'\\\\','\'));
   txt_in  = mgetl(strsubst(InFile+winId,'\\\\','\'));
 else
   txt_out = mgetl(OutFile+winId);
   txt_in  = mgetl(InFile+winId);
 end
 Quit    = 0;

 //## compare input/output buffer
 if ~and(txt_in==txt_out)
   num=tk_message([" Buffer has not been committed.";...
                   "Do you really want to close the editor ?"],...
                   ['Yes','No']);
   if num==1 then
     TCL_EvalStr('sciGUIDestroy '+winId);
     Quit = 1;
     return
   end
 else
   TCL_EvalStr('sciGUIDestroy '+winId);
   Quit = 1;
   return
 end
endfunction

//## scstxtedit : Input function of the text editor
//##    We exit from that function if Quit or use
//##    the commit button.
//##
//## Inputs : str_in : the input text to edit
//##          clos : a flag to close the window
//##                 0 : No
//##                 1 : close
//##
//##          str_out : the edited output text
//##                   can be [] if abort
//##          Quit : a flag to say if the buffer has been
//##                 closed
//##                 0 : No
//##                 1 : Quit
//##
function [str_out,Quit] = scstxtedit_tk (str_in,ptxtedit)
  //** check lhs/rhs arg
  [lhs,rhs]=argn(0)

  //## param from ptxtedit
  clos = ptxtedit.clos
  typ  = ptxtedit.typ
  head = ptxtedit.head

  //## input param of editor
  if MSDOS then
    InFile = strsubst(TMPDIR,'/','\')+'\TTMPin';
    InFile = strsubst(InFile,'\','\\\\')';
    OutFile = strsubst(TMPDIR,'/','\')+'\TTMPout';
    OutFile = strsubst(OutFile,'\','\\\\')';
    HelpFile = strsubst(TMPDIR,'/','\')+'\TTMPHelp';
    HelpFile = strsubst(HelpFile,'\','\\\\')';
  else
    InFile = TMPDIR+'/TTMPin';
    OutFile = TMPDIR+'/TTMPout';
    HelpFile = TMPDIR+'/TTMPHelp';
  end
 
  str_out = [];
  Quit = 0;

  //## compute max_l/max_h
  max_h = size(str_in,1)
  max_l = max(length(str_in))

  if max_h<15 then max_h=15, end
  if max_h>45 then max_h=45, end
  max_h=max_h+2
  if max_l<30 then max_l=30, end
  if max_l>80 then max_l=80, end
  max_l=max_l+5

  //## store input txt in file buffer
  if MSDOS then
    mputl(str_in,strsubst(InFile,'\\\\','\'));
  else
    mputl(str_in,InFile);
  end

  //## store txt of help in file buffer
  max_hh = size(head,1)
  max_ll = max(length(head))
  if MSDOS then
    mputl(head,strsubst(HelpFile,'\\\\','\'));
  else
    mputl(head,HelpFile);
  end

  //## Init TCL/TK sciGUI interf
  sciGUI_init();
  TCL_EvalFile(SCI+'/macros/scicos/scstxtedit.tcl');

  //** retrieve current postion of the last dialog box
  //** potential TCL global variables numx/numy
  //** potential TCL global variables numxctxt/numyctxt

  //## Get position and dim of the editor
  numx=-1
  numy=-1
  ledtx=-1
  ledty=-1
  //## context
  if typ=="context" then
    if TCL_ExistVar('numxctxt') then
      numx=TCL_GetVar('numxctxt')
    end
    if TCL_ExistVar('numyctxt') then
      numy=TCL_GetVar('numyctxt')
    end
    if TCL_ExistVar('ledtxctxt') then
      ledtx=TCL_GetVar('ledtxctxt')
    end
    if TCL_ExistVar('ledtyctxt') then
      ledty=TCL_GetVar('ledtyctxt')
    end
  //## icon
  elseif typ=="icon" then
    if TCL_ExistVar('numxicon') then
      numx=TCL_GetVar('numxicon')
    end
    if TCL_ExistVar('numyicon') then
      numy=TCL_GetVar('numyicon')
    end
  //## palette
  elseif typ=="palette" then
    if TCL_ExistVar('numxpal') then
      numx=TCL_GetVar('numxpal')
    end
    if TCL_ExistVar('numypal') then
      numy=TCL_GetVar('numypal')
    end
  //## Diagram Info
  elseif typ=="scsminfo" then
    if TCL_ExistVar('numxscsmi') then
      numx=TCL_GetVar('numxscsmi')
    end
    if TCL_ExistVar('numyscsmi') then
      numy=TCL_GetVar('numyscsmi')
    end
  //## Standard block doc
  elseif typ=="standarddoc" then
    if TCL_ExistVar('numxstddoc') then
      numx=TCL_GetVar('numxstddoc')
    end
    if TCL_ExistVar('numystddoc') then
      numy=TCL_GetVar('numystddoc')
    end
  //## debug block
  elseif typ=="debugblock" then
    if TCL_ExistVar('numxdgblk') then
      numx=TCL_GetVar('numxdgblk')
    end
    if TCL_ExistVar('numydgblk') then
      numy=TCL_GetVar('numydgblk')
    end
  //## default pos and dim
  else
    if TCL_ExistVar('numx') then
      numx=TCL_GetVar('numx')
    end
    if TCL_ExistVar('numy') then
      numy=TCL_GetVar('numy')
    end
    if TCL_ExistVar('ledtx') then
      ledtx=TCL_GetVar('ledtx')
    end
    if TCL_ExistVar('ledty') then
      ledty=TCL_GetVar('ledty')
    end
  end

  //## run tk text editor
  TCL_EvalStr('ScsTxtEdit '+InFile+' '+OutFile+' '+...
              string(max_l)+' '+string(max_h)+' '+...
              HelpFile+' '+...
              string(max_ll)+' '+string(max_hh)+' '+...
              string(ledtx)+' '+string(ledty)+' '+...
              string(numx)+' '+string(numy)+' '+...
              typ+' '+string(clos));

  //## little loop to wait for a commit
  //## or a quit
  while 1==1
    xpause(50000)
    if str_out<>[]|Quit==1|clos==1 then
      break;
    end
  end
endfunction

//## close_scstxtedit_tk : force closing of a scstxtedit_tk
//##                       windows. Used for Cmenu="Quit"
//##
function [] = close_scstxtedit_tk ()
  TCL_EvalStr('ClosScsTxtEdit');
endfunction