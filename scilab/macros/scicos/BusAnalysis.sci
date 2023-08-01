function [ok,blklst,cmat,ccmat,cor,corinv,reg,sco_mat]=BusAnalysis(blklst,cmat,ccmat,busmat,cor,corinv,reg,MaxBlock,sco_mat,scs_m)
  ok=%t;
  cc=string(cmat);
  blklst_temp=blklst;corinv_temp=corinv;
  I='NAN';strvc=I(ones(size(cmat,1),1));
  cc=[cc strvc];
  for i=1:size(busmat,1)    
    // Adding the name of the signal 
    ind=find(cc(:,3)==string(busmat(i,1)));
    ind1=evstr(cc(ind(:),4));
    o=scs_m(scs_full_path(corinv(busmat(i,1))));
    sourcesign=evstr(list2vec(o.graphics.exprs(2)(1)));
    //sourcesign=list2vec(blklst(busmat(i,1)).opar);
    sourcesign=sourcesign(ind1);
    if and(cc(ind,5)=='NAN') then 
      cc(ind,5)=sourcesign;
    else
      ind2=find(cc(ind,5)<>'NAN');
      ind3=setdiff([1:size(ind,'*')],ind2);
      for j=ind2
	ind2b=find(cc(:,5)==cc(ind(ind2(j)),5));
	cc(ind2b,5)=sourcesign(j);
      end
       cc(ind(ind3(:)),5)=sourcesign(ind3(:));
    end
    ind=find(cc(:,1)==string(busmat(i,3)));
    ind1=evstr(cc(ind(:),2));
    o=scs_m(scs_full_path(corinv(busmat(i,3))));
    destsign=evstr(list2vec(o.graphics.exprs(2)(1)));
    //destsign=list2vec(blklst(busmat(i,3)).opar);
    destsign=destsign(ind1);
     if and(cc(ind,5)=='NAN') then 
      cc(ind,5)=destsign;
    else
      ind2=find(cc(ind,5)<>'NAN');
      ind3=setdiff([1:size(ind,'*')],ind2);
      for j=ind2
	ind2b=find(cc(:,5)==cc(ind(j),5));
	cc(ind2b,5)=destsign(j);
      end
       cc(ind(ind3(:)),5)=destsign(ind3(:));
    end
  end
      // replacing the input by the output
      cc_temp=cc;  counter=0;  mdfy=%t;
  while mdfy do
    old_cc=cc;cc=[];
    for i=1:size(cc_temp,1)
      ind=find(busmat(:,1)==evstr(cc_temp(i,3)));
      if ind<>[] then
	I1=cc_temp(i,1);
	I2=cc_temp(i,2);
	I3=cc_temp(i,5);
	cc=[cc;
	    [I1(ones(size(ind,'*'),1)) I2(ones(size(ind,'*'),1)) string(busmat(ind(:),3:4)) I3(ones(size(ind,'*'),1))]];
      else
	cc=[cc;cc_temp(i,:)];
      end
    end
    cc_temp=cc;
    mdfy=~isequalbitwise(cc,old_cc);
    counter=counter+1;
    if counter>100 then pause;break;end
  end

  dstsrc=[];
  for i=1:size(busmat,1)
    ind=find(cc(:,1)==string(busmat(i,3)));
    dstsrc=[dstsrc;ind(:)];
  end
  to_remove=[];
  //changing the dest source
  for i=1:size(dstsrc,'*')
    ind=find(cc(:,3)==cc(dstsrc(i),1)&cc(:,5)==cc(dstsrc(i),5));
    if ind==[] then
      msg='The Signal ""'+cc(dstsrc(i),5)+'"" is not defined! Please check the hilighted block.';
      path=list2vec(findinlistcmd(cor,evstr(cc(dstsrc(i),1)),'='));
      hilite_path(path,msg,%t);
      ok=%f;return;
    elseif size(ind,'*')>1 then
      msg='There are '+sci2exp(size(ind,'*'))+' signals with the same name ""'+cc(dstsrc(i),5)+'"" received by the hilighted block! Please check it.';
      path=list2vec(findinlistcmd(cor,evstr(cc(dstsrc(i),1)),'='));
      hilite_path(path,msg,%t);
      ok=%f;return;
    else     
      to_remove=[to_remove;ind];
      cc($+1,:)=[cc(ind,1:2) cc(dstsrc(i),3:4) cc(ind,5)];
    end
  end
  to_remove=unique(to_remove);
  cc(to_remove,:)=[];

  //removing the buses blocks and adjusting cor
  vec=string(unique([busmat(:,1);busmat(:,3)]));
  for i=1:size(vec,'*')
    ind=find(cc(:,1)==vec(i)|cc(:,3)==vec(i));
    cc(ind(:),:)=[];
    blklst_temp(evstr(vec(i)))='deletedblock';
    ind=corinv(evstr(vec(i)));
    tt='cor('+sci2exp(ind(1))+')';
    for j=2:size(ind,'*')
      tt=tt+'('+sci2exp(ind(j))+')';
    end
    tt=tt+'=-'+tt;
    execstr(tt);
  end
  //adjusting value in cc-->cmat, ccmat,sco_mat and cor
  vec=sort(evstr(vec))
  for i=1:size(vec,'*')
    ind1=find(evstr(cc(:,1))>=vec(i));
    if ind1<>[] then cc(ind1,1)=string(evstr(cc(ind1,1))-1);end
    ind1=find(ccmat(:,1)>=vec(i));
    if ind1<>[] then ccmat(ind1,1)=ccmat(ind1,1)-1;end
    ind1=find(evstr(sco_mat(:,1))>=vec(i) & sco_mat(:,5)=='10');
    if ind1<>[] then sco_mat(ind1,1)=string(evstr(sco_mat(ind1,1))-1);end
    ind1=find(evstr(cc(:,3))>=vec(i));
    if ind1<>[] then cc(ind1,3)=string(evstr(cc(ind1,3))-1);end
    ind1=find(ccmat(:,3)>=vec(i));
    if ind1<>[] then ccmat(ind1,3)=ccmat(ind1,3)-1;end
    //adjusting in cor

   // vv=corinv(vec(i));
   // vv=vv($);
    ind1=findinlistcmd(cor,vec(i),'>')
    for j=1:size(ind1)
      ind2=ind1(j);
      tt='cor('+sci2exp(ind2(1))+')';
      for k=2:size(ind2,'*')
	tt=tt+'('+sci2exp(ind2(k))+')';
      end
      execstr('isinfer='+tt+'< MaxBlock');
      if isinfer then
        tt=tt+'='+tt+'-1';
      else
	tt=tt+'='+tt;
      end
      execstr(tt);
    end
  end
  cmat=evstr(cc(:,1:4));
  //adjusting blklst and corinv by removing the buses
  blklst=list();corinv=list();
  for i=1:size(blklst_temp)
    if ~isequal(blklst_temp(i),'deletedblock') then
      blklst($+1)=blklst_temp(i);
      corinv($+1)=corinv_temp(i);
    end
  end
  //adjusting reg
  reg=1:size(corinv);
endfunction
