function [params,ok]=GetLitParam(str,flg)
 // flg=%t when the function is called by FindSBParams
 if argn(2)<2 then flg=%f;end
 ok=%t;
 deff('%Font3()',str)
 xx=macrovar(%Font3);
 params=xx(3)
 if flg then
   if or(xx(4)=='exec') then fnct='exec',ok=%f
   elseif or(xx(4)=='load') then fnct='load'; ok=%f
   end
   if ~ok then
     message('The context of a masked or atomic subsystem cannot contains the function ""'+fnct+'""');
     return
   end
 end

 if params<>[] then
    params(find(part(params,1)=="%"))=[] 
 end


// %vaar=["%s" "%z" "%e" "%i" "%pi"]
// [%junk,%ind]=intersect(params,%vaar)  
//  params(%ind)=[]
endfunction
