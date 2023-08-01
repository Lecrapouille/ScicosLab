function [ok,new_info]=do_set_info(info)
// Copyright INRIA
// This function may be redefined by the user to handle definition 
// of the informations associated with the current diagram

if prod(size(info))==0 then
  info = list(' ')
end

//new_info = x_dialog('Set Diagram informations',info(1))

//## set param of scstxtedit
ptxtedit=scicos_txtedit(clos = 0,...
          typ  = "scsminfo",...
          head = ['Set Diagram informations']);

while 1==1

  [txt,Quit] = scstxtedit(info(1),ptxtedit);

  if ptxtedit.clos==1 then
    break;
  end

  if txt==[]|Quit==1 then
    new_info=[]
    ok = %f
    break;
  else
    ok = %t
    new_info = list(txt)
    ptxtedit.clos=1
  end

end

endfunction
