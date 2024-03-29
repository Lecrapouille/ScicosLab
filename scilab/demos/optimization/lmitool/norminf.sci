function [X,cost]=norminf(E,A,B,C,D,gama)
// Copyright INRIA
// Generated by lmitool on Mon Feb 06 11:12:51 MET 1995
  Mbound = 1e3;
  abstol = 1e-10;
  nu = 10;
  maxiters = 100;
  reltol = 1e-10;
  options=[Mbound,abstol,nu,maxiters,reltol];
  /////////////////DO NOT REMOVE THIS LINE
  X_init=eye(A);Ib=eye(B'*B);Ic=eye(C*C');
  /////////////////DO NOT REMOVE THIS LINE
  XLIST0=list(X_init)
  [XLIST,cost]=lmisolver(XLIST0,norminf_eval,options)
  [X]=XLIST(:)
endfunction

/////////////////EVALUATION FUNCTION////////////////////////////
function [LME,LMI,OBJ]=norminf_eval(XLIST)
  [X]=XLIST(:)
  /////////////////DO NOT REMOVE THIS LINE
  LME=X-X'
  LMI=-[A*X*E'+E*X*A',B,E*X*C';B',-gama*Ib,D';C*X*E',D,-gama*Ic]
  OBJ=trace(X)
endfunction

