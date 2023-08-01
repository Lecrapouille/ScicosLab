function scs_m = set_final_time(scs_m,tf)
   [t, err] = evstr(tf)
   if err == 0 then
     scs_m.props.tf=t
   else
     scs_m.props.tf=30
   end
endfunction
