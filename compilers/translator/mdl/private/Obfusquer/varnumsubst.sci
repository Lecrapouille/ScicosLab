function strout=varnumsubst(strin,exp1,exp2)
// works only for exp1 of lenght 1; easy to extend

klen=length(strin)

k=0;l=0;strout="";buff="";

state=0;

while k<klen do

  k=k+1
  ch=part(strin,k)

  if state==0 then
    if ch==part(exp1,1) then
      buff=ch
      state=2
    elseif isalph(ch)|(ch=="%") then
      state=1
      strout=strout+ch
    else
      strout=strout+ch
    end   
  elseif state==1 then
    if isalphnum(ch) then
      strout=strout+ch
    else       
      strout=strout+ch
      state=0
    end
  else  // state=2
    if length(buff)<length(exp1) then
      if ch==part(exp1,length(buff)+1) then
        buff=buff+ch
      elseif isalphnum(ch) then
        strout=strout+buff+ch
        state=1
      else
        strout=strout+buff+ch
        state=0
      end   
    else  
      if buff==exp1 & ~isalphnum(ch) then
        strout=strout+exp2+ch
        state=0   
      else
        strout=strout+buff+ch
        state=1
      end
    end
  end
end
if state==2 then   
      if buff==exp1 then
        strout=strout+exp2
      else
        strout=strout+buff
      end
end
endfunction 
      


function y=isalph(ch)
  ach=ascii(ch)
  y=(ach>64&ach<91)|(ach>96&ach<123)|(ach==95)
endfunction

function y=isalphnum(ch)
  ach=ascii(ch)
  y=(ach>47&ach<58)|isalph(ch)
endfunction

