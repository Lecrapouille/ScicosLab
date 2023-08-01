function [sco_mat,links_table]=local_case(loc_mat,from_mat,sco_mat,links_table)

// Fady NASSIF
// last update 30/05/2008
//This function treat the local case of the goto from application
for i=1:size(loc_mat,1)
  index1=find((from_mat(:,2)=='-1')&(from_mat(:,3)==loc_mat(i,3))&(from_mat(:,4)==loc_mat(i,4)))
  for j=index1
    index2=find(links_table(:,1)==-evstr(from_mat(j,1)))
    // 	     for k=index2
    // 		  links_table(k,1)=-evstr(loc_mat(i,1))
    // 	     end
    if index2<>[] then
      links_table(index2',1)=-evstr(loc_mat(i,1))
    end
    index2=find(sco_mat(:,1)==from_mat(j,1))
    sco_mat(index2',:)=[]
  end
end
endfunction
