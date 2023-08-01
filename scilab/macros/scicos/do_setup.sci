function wpar=do_setup(wpar)
// set integration parameters
// Copyright INRIA
tolerances=wpar.tol;
tf=wpar.tf
atol=tolerances(1);rtol=tolerances(2);ttol=tolerances(3);
deltat=tolerances(4)
scale=tolerances(5);
solver=tolerances(6)
if length(tolerances)<7 then
  hmax=0
else
  hmax=tolerances(7)
end
%scs_help='Setup_Scicos'
while %t do
  [ok,tf,scale,atol,rtol,ttol,deltat,solver,hmax]=getvalue('Set simulator parameters',[
      'Final integration time';
      'Realtime scaling';
      'Integrator absolute tolerance';
      'Integrator relative tolerance';
      'Tolerance on time';
      'Maximum integration time interval'
      'Solver 0-5(ODE) / 100(DAE)'
      'Maximum step size (0 means auto)'],..
      list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1),..
      [stringcos([tf;scale;atol;rtol;ttol;deltat;solver;hmax])])
  if ~ok then break,end
  if or([tf,atol,rtol,ttol,deltat]<=0) then
    message('Parameter must  be positive')
  else
    wpar.tol=[atol;rtol;ttol;deltat;scale;solver;hmax]
    wpar.tf=tf
    break
  end
end
endfunction


function a=stringcos(s)
  a=[]
  for i=1:size(s,1)
    a(i)=string(s(i))
  end
endfunction
