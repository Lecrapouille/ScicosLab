//## ttk_txtedit : a tcl/ttk text editor for Scicos

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
   num=tk_message([" Modifications have not been committed.";...
                   "Do you really want to close the window ?"],...
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

//## ttk_txtedit : Input function of the text editor
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
function [str_out,Quit] = ttk_txtedit(str_in,ptxtedit)
  //** check lhs/rhs arg
  [lhs,rhs]=argn(0)

  //## param from ptxtedit
  clos = ptxtedit.clos
  typ  = ptxtedit.typ
  head = ptxtedit.head

  //## Init TCL/TK sciGUI interf
  [numx,numy,ledtx,ledty,...
       InFile,OutFile,HelpFile]=get_ttk_vars(ptxtedit.typ)

  str_out = [];
  Quit = 0;

  //## compute max_l/max_h
  max_h = size(str_in,1)
  max_l = max(length(str_in))

  if max_h<15 then max_h=15, end
  if max_h>25 then max_h=25, end
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

  //## run tk text editor
  TCL_EvalStr('ScsTxtEdit '+InFile+' '+OutFile+' '+...
              string(max_l)+' '+string(max_h)+' '+...
              HelpFile+' '+...
              string(max_ll)+' '+string(max_hh)+' '+...
              string(ledtx)+' '+string(ledty)+' '+...
              string(numx)+' '+string(numy)+' '+...
              typ+' '+string(clos));

  if TCL_ExistVar('switcha') then
    a=evstr(TCL_GetVar('switcha'))
      TCL_EvalStr('global with_tool')
    if a==1 then
      TCL_EvalStr('set with_tool 0')
    else
      TCL_EvalStr('set with_tool 1')
    end
  end
  if TCL_ExistVar('switchb') then
    a=evstr(TCL_GetVar('switchb'))
    TCL_EvalStr('global with_tool_tk')
    if a==1 then
      TCL_EvalStr('set with_tool_tk 0')
    else
      TCL_EvalStr('set with_tool_tk 1')
    end
  end
  if TCL_ExistVar('switchc') then
    a=evstr(TCL_GetVar('switchc'))
    TCL_EvalStr('global with_but')
    if a==1 then
      TCL_EvalStr('set with_but 0')
    else
      TCL_EvalStr('set with_but 1')
    end
  end

  //## little loop to wait for a commit
  //## or a quit
  while 1==1
    if str_out<>[]|Quit==1|clos==1 then
      break;
    else
      TCL_EvalStr('set done 0');
      TCL_EvalStr('tkwait variable done');
    end
  end
endfunction

//## close_scstxtedit_tk : force closing of a scstxtedit_tk
//##                       windows. Used for Cmenu="Quit"
//##
function [] = close_scstxtedit_tk ()
  TCL_EvalStr('ClosScsTxtEdit');
endfunction