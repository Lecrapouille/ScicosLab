function [scicos_palnew]=do_edit_pal(scicos_pal)
// Copyright INRIA
scicos_palnew=[]
txt=scicos_pal(:,2);
txtnew=txt

//## set param of scstxtedit
ptxtedit= scicos_txtedit(clos = 0,...
           typ  = "palette",...
           head = 'Edit the list of palettes below');

while %t

  [txtnew,Quit] = scstxtedit(txtnew,ptxtedit);

  if ptxtedit.clos==1 then
     break;
  end

  if txtnew==[]|Quit==1 then
    scicos_palnew=[];
    break;
  end

  scicos_palnew=[]

  for i=1:size(txtnew,1)
    txtnew(i)=stripblanks(txtnew(i))
    l=length(txtnew(i))
    if l<>0 then
      k=strindex(txtnew(i),'/');if k==[] then k=0;end
      h=strindex(txtnew(i),'\');if h==[] then h=0;end
      m=max([k,h]); 
      n=strindex(txtnew(i),'.cosf')
      if n==[] then n=strindex(txtnew(i),'.cos');end
      if n==[] then
        message('All files must end with .cos or .cosf')
        scicos_palnew=[]
        break
      end
      a=part(txtnew(i),m+1:n-1);
      scicos_palnew=[scicos_palnew;[a,txtnew(i)]];
      ptxtedit.clos = 1
    end
  end
end
endfunction
