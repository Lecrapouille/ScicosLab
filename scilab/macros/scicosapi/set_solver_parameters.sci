function scs_m = set_solver_parameters(scs_m,tol)
   tol=scs_m.props.tol
   for i = 1:size(tol,"*")
     [val,ierr]=evstr(tol(i))
     if ierr>0 then
       warning('Some simulation parameter values cannot be determined')
     else
      tol(i)=val
     end
   end
   scs_m.props.tol=tol
endfunction
