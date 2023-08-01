function x0=scale_IC(x0,A),
   if size(x0,1)==1 then 
     x0=x0*ones(size(A,1),1),
   end,
endfunction  