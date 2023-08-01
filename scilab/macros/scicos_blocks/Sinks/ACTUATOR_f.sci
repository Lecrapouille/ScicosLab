function [x,y,typ]=ACTUATOR_f(job,arg1,arg2)
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
    [ok,insz,intyp,heritance,nb,exprs]=getvalue('Set actuator block',..
      ['Input Size';'Input Type';'Accept herited events 0/1';'Actuator number'],...
      list('mat',[1 2],'vec',1,'vec',1,'vec',1),exprs)
    if ~ok then break,end
      if ~or(heritance==[0 1]) then
        mess=[mess;'Accept herited events must be 0 or 1';' ']
        ok=%f
      end
      if ok then
        [model,graphics,ok]=set_io(model,graphics,...
                                   list(insz,intyp),list(),...
                                   ones(1-heritance,1),[]);
      end
      if ok then
        model.ipar=nb;
        graphics.exprs=exprs;
        graphics.id="Actuator "+string(nb)
        x.graphics=graphics;
        x.model=model;
        break
      end
  end
case 'define' then
  in1=1
  in2=1
  intyp=1
  dept=%f

  model=scicos_model()
  model.sim=list('bidon',2)
  model.in=[]
  model.in=in1
  model.in2=in2
  model.intyp=intyp
  model.ipar=1
  model.evtin=1

  model.blocktype='c'

  model.dep_ut=[%t %f]

  exprs=[sci2exp([in1,in2]),string(intyp),string(0),string(1)]

  gr_i=['txt=[''ACTUATOR''];';
    'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
  x=standard_define([2 2],model,exprs,gr_i)
  x.graphics.id="Actuator 1"
end
endfunction
