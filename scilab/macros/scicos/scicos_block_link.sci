function ok=scicos_block_link(funam,txt,flag,libs,cflags)
// Copyright INRIA
  [lhs,rhs]=argn(0)
  if rhs<4 then libs=[];end
  if rhs<5 then cflags=[];end
  if flag=='c' then mflag='C', else mflag='fortran',end
  if stripblanks(funam)==emptystr() then 
    ok=%f
    x_message('sorry file name not defined in '+flag+' block')
    return
  end
  cur_wd = getcwd();
  chdir(TMPDIR);
  mputl(txt,funam+'.'+flag);
  ilib_for_link=ilib_for_link;//load ilib_for_link and its subfunctions
  ilib_compile=ilib_compile;//load ilib_for_link and its subfunctions
  [ll]=lines()
  lines(-1)
  ilib_link_gen_loader(funam,flag,'loader.sce',libs,"");
  ilib_link_gen_Make(funam,funam+'.o',libs,'Makelib',"",...
                     "",cflags,"","",flag);
  [make_command,lib_name_make,lib_name,path,makename,files]= ...
      ilib_compile_get_names('lib'+funam,'Makelib',funam+'.o')
  ierr= execstr('unix_s(make_command+makename + '' ''+ files)',..
                'errcatch');
  if ierr<> 0 then
    chdir(cur_wd)
    x_message('Sorry compilation problem')
    ok=%f
    lines(ll(1))
    return
  end
  [a,b]=c_link(funam); while a;  ulink(b);[a,b]=c_link(funam);end
  ierr= execstr('unix_s(make_command+makename + '' ''+ lib_name)', ...
                'errcatch');
  if ierr<> 0 then 
    chdir(cur_wd)
    x_message('Sorry shared lib cannot be created')
    ok=%f
    lines(ll(1))
    return
  end
  ierr= exec('loader.sce','errcatch')
  if ierr<> 0 then
    chdir(cur_wd)
    x_message('Sorry link problem')
    ok=%f
    lines(ll(1))
    return
  end
  chdir(cur_wd)
  lines(ll(1))
  ok=%t
endfunction

