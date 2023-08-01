function unhilite_modelica_block(k,corinvm)
//Copyright INRIA
//## purpose : unhilite a modelica block in the scicos editor
//##           (only in opened windows)
//##           - k is the modelica compiled index modelica
//##             if k is not given then unhilite all modelica blocks
//##           - corinvm (optional) gives the corinv of the modelica
//##           block. if corinvm is not given we search in %cpr

//## Get number of Right Hand Side arguments
rhs = argn(2)

//## Test on number of Rhs
if rhs==1 then
  //## check if %cpr exists
  if ~exists('%cpr') then
    return; //## silent exit(nothing is done)
  end

  //## check if the diagram have been compiled
  if %cpr==list() then
    return; //## silent exit(nothing is done)
  end

  //## get the corinv of the modelica blocks
  corinvm = %cpr.corinv($)
end

//## check the type of corinvm
if type(corinvm)<>15 then
  return; //## silent exit(nothing is done)
end

//## k always a vector
if rhs>=1 then
  k=k(:)
else
  k=(1:lstsize(corinvm))'
end

//## retrieve the index in the main scs_m
//## and put in the path list()
//## max_path is the deepest level path of modelica block(s)
path = list();
j=1;
max_path=1;
for i=1:size(k,1)
  if find(k(i)==(1:lstsize(corinvm)))<>[] then
    setfield(j,corinvm(k(i)),path);
    max_path=max(max_path,size(corinvm(k(i)),2))
    j=j+1;
  end
end

//## check if path is not empty
if path==list() then
  return; //## silent exit(nothing is done)
end

//## put path in a matrix of size lstsize(path),max_path
mat_path=[]
for i=1:lstsize(path)
  mat_path=[mat_path;
            path(i) zeros(1,max_path-size(path(i),2))]
end

//## unhilite given modelica blocks in opened windows
already_hilite=[]
for i=1:size(mat_path,2)
  ind=find(mat_path(:,i)<>0)
  already_hilite=[]
  if ind<>[] then
    if i==1 then
      //##remove doublons
      iind=[];
      for y=1:size(ind,2)
        if find(mat_path(iind)==mat_path(ind(y)))==[] then
          iind = [iind;ind(y)];
        end
      end

      //## display path for the main scicos window
      h = scf(Main_Scicos_window);
      curwin=get(h,"figure_id");
      unhilite_obj(mat_path(iind,i),curwin);
    else

      //##remove doublons
      iind=[];
      for j=1:size(ind,2)
        already_hilite=%f;
        for kk=1:size(iind,2)
          if mat_path(iind(kk),1:i)==mat_path(ind(j),1:i) then
            already_hilite=%t;
            break;
          end
        end
        if ~already_hilite then
          iind=[iind;ind(j)];
        end
      end

      for j=1:size(iind,1)
        mini_path=mat_path(iind(j),1:i-1);
        o=scs_m(scs_full_path(mini_path));
        mini_scs_m=o.model.rpar;
        winnb = winsid();
        for k=1:size(winnb,2)
          h = scf(winnb(k));
          if isequalbitwise(h.user_data(1),mini_scs_m) then
            curwin=get(h,"figure_id");
            unhilite_obj(mat_path(iind(j),i),curwin);
            break
          end
        end
      end
    end
  end
end


endfunction