function [x,y,typ]=Loop_Breaker(job,arg1,arg2)
// Copyright INRIA
x=[];y=[];typ=[]

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
case 'compile' then  
  block=arg1
  block.state=zeros(2*block.out,1)
  x=block

case 'define' then
  model=scicos_model()
  model.sim=list('loopbreaker',10004)
  model.in=-1
  model.out=-1
  model.blocktype='x'
  model.dep_ut=[%f %t]
  exprs=[]

 gr_i=['txt=[''Loop'';''breaker''];';
        'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']

x=standard_define([3 2],model,exprs,gr_i)
end
endfunction
