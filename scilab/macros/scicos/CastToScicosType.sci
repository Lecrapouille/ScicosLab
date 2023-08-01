function y=CastToScicosType(x,t)
select t
case 1 then
   y=real(double(x))
case 2 then
   y=double(x)+0*%i
case 3 then
   y=int32(x)
case 4 then
   y=int16(x)
case 5 then
   y=int8(x)
case 6 then
   y=uint32(x)
case 7 then
   y=uint16(x)
case 8 then
   y=uint8(x)
case 9 then
   y=real(double(x))>0 
end
endfunction
