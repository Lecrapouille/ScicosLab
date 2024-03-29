function [X,c]=normopt(A,B,C,D)
// Copyright INRIA
// Generated by lmitool on Wed Feb 08 16:17:01 MET 1995
  
  Mbound = 1e3;
  abstol = 1e-10;
  nu = 10;
  maxiters = 100;
  reltol = 1e-10;
  options=[Mbound,abstol,nu,maxiters,reltol];
  
  ///////////DEFINE INITIAL GUESS BELOW
  X_init=eye(A);Ib=eye(B'*B);Ic=eye(C*C');c_init=10;                
  /////////// 
  
  XLIST0=list(X_init,c_init)
  XLIST=lmisolver(XLIST0,normopt_eval,options)
  [X,c]=XLIST(:)
endfunction


/////////////////EVALUATION FUNCTION////////////////////////////

function [LME,LMI,OBJ]=normopt_eval(XLIST)
  [X,gama]=XLIST(:)
  
  /////////////////DEFINE LME, LMI and OBJ BELOW
  LME=X'-X                                                          
  LMI=-[A*X+X*A', B, X*C';
	B', -gama*Ib, D';
	C*X, D, -gama*Ic]              
  OBJ=gama                                                          
  
endfunction

