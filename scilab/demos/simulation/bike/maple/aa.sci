function [out]=aa(q,qd,u,param,b0,b1,a0)
// Function generated by Maple to Scilab interface
  out=fort('aa',q,1,'d',qd,2,'d',u,3,'d',param,4,'d',b0,5,'d',...
	   b1,6,'d',a0,7,'d','out',[43,1],8,'d')
endfunction
