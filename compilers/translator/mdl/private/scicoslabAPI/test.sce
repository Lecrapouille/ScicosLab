  if MSDOS then
    MDL = get_absolute_file_path("test.sce")+'..\'
  else
    MDL = get_absolute_file_path("test.sce")+'../'
  end

  cwd=pwd();
  cd(MDL+"scicoslabAPI")

  load("SCI/macros/scicos/lib")
  exec(loadpallibs, 1)
  options=default_options();
  %scicos_context=struct();

  genlib("trancos",MDL+"scicoslabAPI",%t)
  load("lib")

  cd(cwd);

  f="e:/SVN/simport/test_data/mdl/explicit/simport/QuarterCarEKF.sci";

  exec(f,-1);
  scicos(scsm);
