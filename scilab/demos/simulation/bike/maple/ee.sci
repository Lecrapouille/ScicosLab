function [out]=ee(q,qd,param)
// Function generated by Maple to Scilab interface
  out=fort('ee',q,1,'d',qd,2,'d',param,3,'d','out',[43,43],4,'d')
endfunction