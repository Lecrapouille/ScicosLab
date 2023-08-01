function [x,y,typ]=SAMPHOLD_m(job,arg1,arg2)
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
  x.model.firing=[] //compatibility
  graphics=x.graphics;label=graphics.exprs
  model=x.model;
  while %t do
    [ok,it,exprs]=getvalue('Set parameters Block',..
	    ['Datatype(-1=inherit 1=real double 2=Complex 3=int32 ...)'],list('vec',1),label)
    if ~ok then break,end
    if ((it==0)|(it>8)) message ("Datatype is not supported");ok=%f;end
    if ok then
      in=[model.in model.in2];
      [model,graphics,ok]=set_io(model,graphics,list(in,it),list(in,it),1,[])
      if ok then
         graphics.exprs=exprs;
         x.graphics=graphics;x.model=model;
         break
      end
    end
  end
case 'define' then
  model=scicos_model()
  model.sim=list('samphold4_m',4)
  model.in=-1
  model.in2=-2
  model.intyp=1
  model.outtyp=1
  model.out=-1
  model.out2=-2
  model.evtin=1
  model.blocktype='d'
  model.dep_ut=[%t %f]
  label=[sci2exp(1)];
  gr_i='xstringb(orig(1),orig(2),''S/H'',sz(1),sz(2),''fill'')'
  x=standard_define([2 2],model,label,gr_i)
end
endfunction
