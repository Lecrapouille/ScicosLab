function []=do_aboutscicos()
// Copyright INRIA
  [verscicos,minver]=get_scicos_version()
  verscicos=part(verscicos,7:length(verscicos))
  if minver<>'' then
    verscicos=verscicos+'.'+minver
  end

  txt=['Scicos -'+verscicos+'-';
       'Copyright (c) 1992-2011 Metalau project INRIA'
       'For more information visit:';
       '     www.scicos.org      ']

  if MSDOS & evstr(TCL_EvalStr('file exists $env(COMSPEC)'))     then
    num=message(txt,['Open URL','Cancel']);
    if num==1 then
      TCL_EvalStr('exec $env(COMSPEC) /c start http://www.scicos.org &')
    end
  else
    message(txt);
  end
endfunction