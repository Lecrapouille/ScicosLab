function model_name=get_model_name(mo_model,id,AllNames)
//Copyright INRIA
//## return an unique name for a modelica model
//## for the compiled modelica structure
//##
//## inputs :
//##   mo_model : a string that gives the name of the model
//##              in the modelica list (equations) of a modelica block.
//##
//##   Bnames   : vector of strings of already attribuate models name
//##
//## output :
//##   model_name : the output string of the model name
//##
  ido=cleanID(id);
  mo_model=cleanID(mo_model)
  ind = 1
  model_name=mo_model+'_'+ido
  while find(model_name==AllNames)<>[] then
    model_name=mo_model+'_'+ido+string(ind)
    ind = ind + 1
  end
endfunction


function id_out=cleanID(id)
  if id=='' then
    id_out='';
    return;
  end
  lid=length(id)
  ida=ascii(id);
  ido=ida;
  for i=1:length(id)
    C1= ascii('0')<=ida(i) & ida(i)<=ascii('9');
    C2= ascii('a')<=ida(i) & ida(i)<=ascii('z');
    C3= ascii('A')<=ida(i) & ida(i)<=ascii('Z');    
    if C1 | C2 | C3 then 
      ido(i)=ida(i)
    else
      ido(i)=ascii('_')
    end    
  end  
  id_out=ascii(ido);
endfunction

