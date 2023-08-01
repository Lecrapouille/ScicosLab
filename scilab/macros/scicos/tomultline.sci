function txt=tomultline(txt)
  u=ascii(txt)
  k=find(u(1:$-1)==92 & u(2:$)==110)
  if isempty(k) then
     return
  end
  j=k(1)
  txt=ascii(u(1:j-1))
  for i=k(2:$)
    txt($+1)=ascii(u(j+2:i-1))
    j=i
  end
  txt($+1)=ascii(u(j+2:$))
endfunction
