function [ok,codegeneration,edited]=do_set_codegen(codegeneration)
// Copyright INRIA
  ok=%f
  edited=%t

  mess = 'Set default properties for Code Generation'

  silent_in       = sci2exp(codegeneration.silent)
  cblock_in       = sci2exp(codegeneration.cblock)
  rdnom_in        = sci2exp(codegeneration.rdnom)
  rpat_in         = sci2exp(codegeneration.rpat)
  libs_in         = sci2exp(codegeneration.libs)
  opt_in          = sci2exp(codegeneration.opt)
  enable_debug_in = sci2exp(codegeneration.enable_debug)

  %scs_help='Setup_CodeGen'

  while %t do
    [ok,...
     silent,...
     cblock,...
     rdnom,...
     rpat,...
     libs,...
     opt,...
     enable_debug]=getvalue(mess,...
                      ["Silent mode (0:no, 1:yes)";
                       "Use CBLOCK4 (0:no, 1:yes)";
                       "Target name ([] means default)";
                       "Target path ([] means default)";
                       "External libraries ([] means default)";
                       "Standalone generation (0:no, 1:yes)";
                       "Enable debug (0:no, 1:yes)"],...
                      list("vec",[1],...
                           "vec",[1],...
                           "str",[1],...
                           "str",[1],...
                           "str",[-1],...
                           "vec",[1],...
                           "vec",[1]),...
                          [silent_in,...
                           cblock_in,...
                           rdnom_in,...
                           rpat_in,...
                           libs_in,...
                           opt_in,...
                           enable_debug_in])

    if ~ok then edited=%f, break, end

    err_mess=[]
    if find(silent==[0 1])==[] then
      err_mess=[err_mess;'Silent mode must be 0 or 1.']
    else
      silent_in=sci2exp(silent)
    end
    if find(cblock==[0 1])==[] then
      err_mess=[err_mess;'Use CBLOCK4 must be 0 or 1.']
    else
      cblock_in=sci2exp(cblock)
    end
    [H,ierr]=evstr(rdnom)
    if ierr<>0 then
      err_mess=[err_mess;'Name for codes must be a string.']
    else
      rdnom_in=sci2exp(evstr(rdnom))
    end
    [H,ierr]=evstr(rpat)
    if ierr<>0 then
      err_mess=[err_mess;'Target path must be a string.']
    else
      rpat_in=sci2exp(evstr(rpat))
    end
    [H,ierr]=evstr(libs)
    if ierr<>0 then
      err_mess=[err_mess;'External libraries must be a vector of strings.']
    else
      libs_in=sci2exp(evstr(libs))
    end
    if find(opt==[0 1])==[] then
      err_mess=[err_mess;'Standalone generation must be 0 or 1.']
    else
      opt_in=sci2exp(opt)
    end
    if find(enable_debug==[0 1])==[] then
      err_mess=[err_mess;'Enable debug must be 0 or 1.']
    else
      enable_debug_in=sci2exp(enable_debug)
    end

    if err_mess<>[] then
      message(err_mess)
    else
      codegeneration.silent=silent
      codegeneration.cblock=cblock
      codegeneration.rdnom=evstr(rdnom)
      codegeneration.rpat=evstr(rpat)
      codegeneration.libs=evstr(libs)
      codegeneration.opt=opt
      codegeneration.enable_debug=enable_debug
      break
    end
  end

endfunction
