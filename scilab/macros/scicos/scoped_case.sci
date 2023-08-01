function [sco_mat,links_table,scs_m,ok]=scoped_case(tag_exprs,sco_mat,links_table,scs_m,corinv)

// Fady NASSIF 
// last update: 30/05/2008

// this function study the scoped case in the goto/from application

//to be modified !!!!!
//      vec=unique(tag_exprs)

//---------------------Case of multiple blocks with the same tag--------------------
for i=1:size(tag_exprs,1)
  index=find((tag_exprs(:,1)==tag_exprs(i,1))&(tag_exprs(:,2)==tag_exprs(i,2)))
  if size(index,'*') > 1  then
    message(["Error In Compilation. You cannot have multiple GotoTagVisibility";..
	    " with the same tag value in the same scs_m"])
    ok=%f;
    return
  end
end 
//----------------------------------------------------------------------------------

for i=1:size(tag_exprs,1)
  index=find((sco_mat(:,2)=='1')&(sco_mat(:,3)==tag_exprs(i,1))&(sco_mat(:,4)=='2')&(sco_mat(:,5)==tag_exprs(i,2)))
  if index<>[] then
    //------------- case of multiple goto having the same tagvisibility-----------------------------
    if size(index,'*')>1 then
      message(["Error in compilation";"Multiple GOTO are taged by the same GotoTagVisibility"])
      ok=%f
      return
    end
    //----------------------------------------------------------------------------------------------
    index1=find((sco_mat(:,2)=='-1')&(sco_mat(:,3)==tag_exprs(i,1))&(sco_mat(:,5)==tag_exprs(i,2)))
    if index1<>[] then
      for j=index1
	index2=find(links_table(:,1)==-evstr(sco_mat(j,1)))
	if index2<>[] then
	  links_table(index2',1)=-evstr(sco_mat(index,1)) //replace the from block by the goto. In this case the goto block will be treated as a split.
	end
	//linking the always active blocks to the VirtualCLK0 if exists.
	if sco_mat(j,5)=='10' then
	  links_table($+1,:)=[-evstr(sco_mat(index,1)) 1 -1 -1]
	  links_table($+1,:)=[evstr(sco_mat(j,1)) 0 1 -1]
	  scs_m.objs(corinv(evstr(sco_mat(j,1)))).model.dep_ut($)=%f;
	end 
      end
    end
    sco_mat([index1';index'],:)=[]
    //sco_mat(index,:)=[]
  end
end
endfunction
