function [x,y,typ]=Ground_g(job,arg1,arg2)
// Copyright INRIA
x=[];y=[];typ=[];
select job
 case 'plot' then
  standard_draw(arg1)
case 'getinputs' then
  x=[];y=[];typ=[];
case 'getoutputs' then
  [x,y,typ]=standard_outputs(arg1)
case 'getorigin' then
  [x,y]=standard_origin(arg1)
case 'set' then
  x=arg1;
case 'define' then
  C=[0]
  model=scicos_model()
  model.sim=list('cstblk4_m',4)
  model.in=[]
  model.out=1
  model.in2=[]
  model.out2=1
  model.outtyp=-1
  model.rpar=[]
  model.opar=list(C);
  model.blocktype='d'
  model.dep_ut=[%f %f]
  exprs=[]
  gr_i=['x=orig(1)*ones(5,1)+sz(1)*[1/16;15/16;1/2;1/2;1];';
  	  'y=orig(2)*ones(5,1)+sz(2)*[1/2;1/2;1/2;3/4;3/4];';
	  'xpolys(x,y);';
	  'x=orig(1)*ones(2,1)+sz(1)*[1/4;3/4];';
	  'y=orig(2)*ones(2,1)+sz(2)*[1/8+3/16;1/8+3/16];';
	  'xpolys(x,y);';
	  'x=orig(1)*ones(2,1)+sz(1)*[7/16;9/16];';
	  'y=orig(2)*ones(2,1)+sz(2)*[1/8;1/8];';
	  'xpolys(x,y);']
  x=standard_define([2 2],model,exprs,gr_i)
end
endfunction
