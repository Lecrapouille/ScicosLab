function [out]=foof7(k,x)
// Function generated by Maple to Scilab interface
[ij,v,mn]=fort('foof7',k,1,'d',x,2,'d','out',[3,2],3,'i',[3,1],4,'d',[...
2,1],5,'i')
out=sparse(ij,v,mn)
endfunction
