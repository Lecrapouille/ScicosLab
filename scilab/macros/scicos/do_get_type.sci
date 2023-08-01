function ot=do_get_type(C)
 if (type(C)==1) then
   if isreal(C) then
         ot=1
   else
         ot=2
   end
elseif (typeof(C)=="int32") then
	 ot=3
elseif (typeof(C)=="int16") then
	ot=4
elseif (typeof(C)=="int8") then
	ot=5
elseif (typeof(C)=="uint32") then
	ot=6
elseif (typeof(C)=="uint16") then
	ot=7
elseif (typeof(C)=="uint8") then
	ot=8
else 
        ot=9
end
endfunction
