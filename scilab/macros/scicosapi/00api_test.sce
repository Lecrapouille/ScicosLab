load('SCI/macros/scicos/lib');
load('SCI/macros/scicosapi/lib');
exec(loadpallibs,-1);
options=default_options();

while %t
  ff=xgetfile("*.cosf","SCI/demos/scicos/");
  if ff=="" then break;end
  exec(ff,-1);
  [ierr,scicos_ver,scs_m]=update_version(scs_m);
  [ok,txt]=do_api_save(scs_m) ;
  if ok then
   execstr(txt);
   scicos(scsm);
  end
end
