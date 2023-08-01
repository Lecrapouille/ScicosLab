function [x,y,typ]=SENSOR_f(job,arg1,arg2)
// Copyright INRIA
x=[];y=[];typ=[];
select job
case 'plot' then
  standard_draw(arg1)
case 'getinputs' then
  [x,y,typ]=standard_inputs(arg1)
case 'getoutputs' then
  [x,y,typ]=standard_outputs(arg1)
case 'getorigin' then
  [x,y]=standard_origin(arg1)
case 'set' then
  x=arg1;
  graphics=arg1.graphics;
  exprs=graphics.exprs
  model=arg1.model;
  while %t do
    [ok,outsz,outtyp,nb,exprs]=getvalue('Set sensor block',..
      ['Output Size';'Output Type';'Sensor number'],...
      list('mat',[1 2],'vec',1,'vec',1),exprs)
    if ~ok then break,end
      [model,graphics,ok]=set_io(model,graphics,...
                                 list(),list(outsz,outtyp),...
                                 1,[]);
      model.ipar=nb
      graphics.exprs=exprs;
      graphics.id="Sensor "+string(nb)
      x.graphics=graphics;
      x.model=model;
      break
  end
case 'define' then
  out1=1
  out2=1
  outtyp=1
  dept=%f
  nb=1
  
  model=scicos_model()
  model.sim=list('bidon',2)
  model.in=[]
  model.out=out1
  model.out2=out2
  model.outtyp=outtyp
  model.ipar=1
  model.evtin=1
  
  model.blocktype='c'
  
  model.dep_ut=[%f %f]
  
  exprs=[sci2exp([out1,out2]),string(outtyp),string(nb)]

  gr_i=['txt=[''SENSOR''];';
    'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
  x=standard_define([2 2],model,exprs,gr_i)
  x.graphics.id="Sensor 1"
end
endfunction
