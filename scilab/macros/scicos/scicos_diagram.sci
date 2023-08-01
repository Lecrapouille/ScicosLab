function scs_m=scicos_diagram(v1,v2,v3)
// Copyright INRIA
  if exists('props','local')==0 then props=scicos_params(),end
  if exists('objs','local')==0 then objs=list(),end
  if exists('version','local')==0 then version='',end
  if exists('contrib','local')==0 then contrib=list(),end
  if exists('codegen','local')==0 then codegen=scicos_codegen(),end

  scs_m=mlist(['diagram','props','objs','version','contrib','codegen'],...
                props,objs,version,contrib,codegen)
endfunction
