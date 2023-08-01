function [x,y,typ]=MATCATV(job,arg1,arg2)
//
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
  x=arg1
  model=arg1.model;graphics=arg1.graphics;label=graphics.exprs
  if size(label,'*')>1 then //compatibility
    label='size(evstr('+label(2)+'),''*'')'; 
  end
  while %t do
    [ok,nin,lab]=..
        getvalue('Set MATCATV block parameters',..
        ['Number of inputs'],..
         list('vec',1),label)
    if ~ok then break,end
    label=lab
    in=[-([2:nin+1]') -ones(nin,1)]
    it= -ones(nin,1);
    ot=-1;
    out=[0 -1]
    [model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),[],[])
    if ok then
      funtyp=4;
      model.sim=list('mat_catv',funtyp)
      graphics.exprs=label
      arg1.graphics=graphics
      arg1.model=model
      x=arg1
      break
    end
  end
case 'define' then
  l1=[2;2]
  model=scicos_model()
  junction_name='mat_catv';
  funtyp=4;
  model.sim=list(junction_name,funtyp)
  model.in2=[-1;-1]
  model.in=[-2;-3]
  model.intyp=[-1 -1]
  model.out=0
  model.out2=-1
  model.outtyp=-1
  model.evtin=[]
  model.evtout=[]
  model.state=[]
  model.dstate=[]
  model.rpar=[]
  model.ipar=[]
  model.blocktype='c' 
  model.firing=[]
  model.dep_ut=[%t %f]
  label=[sci2exp(2)];
  gr_i=['text=[''Vert'';'' Cat''];';'xstringb(orig(1),orig(2),text,sz(1),sz(2),''fill'');']
  x=standard_define([2 3],model,label,gr_i)
end
endfunction

