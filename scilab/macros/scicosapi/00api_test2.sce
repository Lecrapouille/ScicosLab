load('SCI/macros/scicos/lib');
load('SCI/macros/scicosapi/lib');
exec(loadpallibs,-1);
options=default_options();

while %t
  ff=xgetfile("*.cos*","SCI/demos/scicos/");
  if ff=="" then break;end
  [ppath,fname,extension]=fileparts(ff);
  if extension == ".cos" then
     load(ff);
  elseif extension == ".cosf" then
     exec(ff,-1);
  else
     error("Unsupported file type.")
  end
  [ierr,scicos_ver,scs_m]=update_version(scs_m);
  [txt]=do_api_txt(scs_m) ;
  execstr(txt);
  scicos(scsm);
end
