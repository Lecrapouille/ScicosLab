function scs_m=test(f)
  load("SCI/macros/scicos/lib")
  exec(loadpallibs, 1)
  options=default_options()
  load(MDL+"scilab/lib")
  exec(f,-1)
  scicos(sss)
endfunction
