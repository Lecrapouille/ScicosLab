function [libss,cflags,ok,cancel]=get_dynamic_lib_dir(tt,funam,flag,libss,cflags)
// Copyright INRIA
  cancel=%f
  cur_wd=getcwd();
  chdir(TMPDIR);
  mputl(tt,funam+'.'+flag);
  label=[libss;cflags];
  ok=%f

  while ~ok then
    [ok,libss,cflags,label]=getvalue('Linking the '+funam+' function',...
                                    ['External libraries (if any)';
                                     'Additionnal compiler flag(s)'],...
                                     list('str',1,'str',1),label);
    if ~ok then chdir(cur_wd);cancel=%t,return;end
    //@@ check libss
    if strindex(libss,'''')<>[] | strindex(libss,'""')<>[] then
      ierr=execstr('libss=evstr(libss)','errcatch')
      if ierr<>0  then
        message(['Can''t solve other files to link'])
        chdir(cur_wd);
        ok=%f;
      end
    else
      libss=tokens(libss,[' ',';'])
    end

    //@@ check cflags
    if strindex(cflags,'''')<>[] | strindex(cflags,'""')<>[] then
      ierr=execstr('cflags=evstr(cflags)','errcatch')
      if ierr<>0  then
        message(['Error(s) in Additionnal compiler flag(s)'])
        chdir(cur_wd);
        ok=%f;
      end
    else
      cflags=tokens(cflags,[' ',';'])
      cflags=strcat(cflags,' ')
    end

    //@@ check libraries existance
    for i=1:size(libss,'*')
      if MSDOS then
        lib_dll=libss(i)+'.dll'
      else
        lib_dll=libss(i)+'.so'
      end
      ifexst=fileinfo(lib_dll)
      if ifexst==[] then message ('the library '+lib_dll+' doesn''t exists');ok=%f;end
    end
  end
  chdir(cur_wd);
endfunction
