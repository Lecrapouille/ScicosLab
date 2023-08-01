function myint8=SetString(str)
//function to convert scilab string in char
//AL
//Copyright INRIA
 if type(str)==10 then
   myint8=[]
   for i=1:size(str,2)
     if i<>1 then myint8=[myint8,10], end
     for j=1:size(str,1)
       if j<>1 then myint8=[myint8,10], end
       myint8=[myint8,ascii(str(j,i))]
     end
   end
   myint8=int8([myint8,0])
 else
   myint8=[]
 end
endfunction
