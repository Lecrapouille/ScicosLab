function [numx,numy,ledtx,ledty,InFile,OutFile,HelpFile]=get_ttk_vars(typ)

  //## Init TCL/TK sciGUI interf
  sciGUI_init();
  TCL_EvalFile(SCI+'/macros/scicos/ttk_scicos_widgets.tcl');

  numx=-1
  numy=-1
  ledtx=-1
  ledty=-1

  //## Simulator setting
  if typ=="Setup_Scicos" then
    if TCL_ExistVar('numxsetup') then
      numx=TCL_GetVar('numxsetup')
    end
    if TCL_ExistVar('numysetup') then
      numy=TCL_GetVar('numysetup')
    end
  //## paltree
  elseif typ=="paltree" then
    if TCL_ExistVar('numxptree') then
      numx=TCL_GetVar('numxptree')
    else
      numx='[winfo pointerx .]'
    end
    if TCL_ExistVar('numyptree') then
      numy=TCL_GetVar('numyptree')
    else
      numy='[winfo pointery .]'
    end
    if TCL_ExistVar('lxptree') then
      ledtx=TCL_GetVar('lxptree')
    end
    if TCL_ExistVar('lyptree') then
      ledty=TCL_GetVar('lyptree')
    end
  //## context
  elseif typ=="context" then
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
  //## scilab block
  elseif typ=="Scifunc-0" | typ=="Scifunc-1" | ...
         typ=="Scifunc-2" | typ=="Scifunc-3" | ...
         typ=="Scifunc-4" | typ=="Scifunc-5" | ...
         typ=="Scifunc-6" | typ=="Scifunc5" then
    if TCL_ExistVar('numxsciblk') then
      numx=TCL_GetVar('numxsciblk')
    else
      if TCL_ExistVar('numxgetvalue') then
        numx=TCL_GetVar('numxgetvalue')
      end
    end
    if TCL_ExistVar('numysciblk') then
      numy=TCL_GetVar('numysciblk')
    else
      if TCL_ExistVar('numygetvalue') then
        numy=TCL_GetVar('numygetvalue')
      end
    end
  //## C block
  elseif typ=="Cfunc" then
    if TCL_ExistVar('numxcblk') then
      numx=TCL_GetVar('numxcblk')
    else
      if TCL_ExistVar('numxgetvalue') then
        numx=TCL_GetVar('numxgetvalue')
      end
    end
    if TCL_ExistVar('numycblk') then
      numy=TCL_GetVar('numycblk')
    else
      if TCL_ExistVar('numygetvalue') then
        numy=TCL_GetVar('numygetvalue')
      end
    end
  //## Fortran block
  elseif typ=="Ffunc" then
    if TCL_ExistVar('numxfblk') then
      numx=TCL_GetVar('numxfblk')
    else
      if TCL_ExistVar('numxgetvalue') then
        numx=TCL_GetVar('numxgetvalue')
      end
    end
    if TCL_ExistVar('numyfblk') then
      numy=TCL_GetVar('numyfblk')
    else
      if TCL_ExistVar('numygetvalue') then
        numy=TCL_GetVar('numygetvalue')
      end
    end
  //## Modelica block
  elseif typ=="ModelicaClass" then
    if TCL_ExistVar('numxmblk') then
      numx=TCL_GetVar('numxmblk')
    else
      if TCL_ExistVar('numxgetvalue') then
        numx=TCL_GetVar('numxgetvalue')
      end
    end
    if TCL_ExistVar('numymblk') then
      numy=TCL_GetVar('numymblk')
    else
      if TCL_ExistVar('numygetvalue') then
        numy=TCL_GetVar('numygetvalue')
      end
    end
  //## getvalue
  elseif typ=="getvalue" then
    if TCL_ExistVar('numxgetvalue') then
      numx=TCL_GetVar('numxgetvalue')
    end
    if TCL_ExistVar('numygetvalue') then
      numy=TCL_GetVar('numygetvalue')
    end
  //## IDfont
  elseif typ=="IDfont" then
    if TCL_ExistVar('numxidfont') then
      numx=TCL_GetVar('numxidfont')
    elseif TCL_ExistVar('numxgetvalue')
      numx=TCL_GetVar('numxgetvalue')
    end
    if TCL_ExistVar('numyidfont') then
      numy=TCL_GetVar('numyidfont')
    elseif TCL_ExistVar('numygetvalue')
      numy=TCL_GetVar('numygetvalue')
    end
  //## choose
  elseif typ=="choose" then
    if TCL_ExistVar('numxchoose') then
      numx=TCL_GetVar('numxchoose')
    end
    if TCL_ExistVar('numychoose') then
      numy=TCL_GetVar('numychoose')
    end
  //## message
  elseif typ=="message" then
    if TCL_ExistVar('numx') then
      numx=TCL_GetVar('numx')
    else
      if TCL_ExistVar('numxgetvalue') then
        numx=TCL_GetVar('numxgetvalue')
      else
        numx='[winfo pointerx .]'
      end
    end
    if TCL_ExistVar('numy') then
      numy=TCL_GetVar('numy')
    else
       if TCL_ExistVar('numygetvalue') then
         numy=TCL_GetVar('numygetvalue')
       else
         numy='[winfo pointery .]'
       end
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
    if MSDOS then
      [OS,Version]=getos();
      if (Version=="XP") | (Version=="2003") then
        TCL_EvalStr('set TkTheme '"xpnative'"')
      elseif (strindex(Version,'Vista')<>[]) | (strindex(Version,'Seven')<>[]) then
        rep=TCL_EvalStr('catch {ttk::setTheme vista}')
        if rep=='1' then
          TCL_EvalStr('set TkTheme '"xpnative'"')
        else
          TCL_EvalStr('set TkTheme '"vista'"')
        end
      else
        TCL_EvalStr('set TkTheme '"winnative'"')
      end
    else
      TCL_EvalStr('set TkTheme '"clam'"')
    end
  end

  if ~TCL_ExistVar('with_tool') then
    TCL_EvalStr('global with_tool')
    TCL_EvalStr('set with_tool 0')
  end

  if ~TCL_ExistVar('with_tool_tk') then
    TCL_EvalStr('global with_tool_tk')
    TCL_EvalStr('set with_tool_tk '"0'"')
  end

  if ~TCL_ExistVar('with_but') then
    TCL_EvalStr('global with_but')
    TCL_EvalStr('set with_but '"1'"')
  end

  TCL_EvalStr('global activback;set activback '"RoyalBlue'"')
  TCL_EvalStr('global activfor;set activfor '"white'"')
  TCL_EvalStr('global activbrd;set activbrd  1');

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

endfunction
