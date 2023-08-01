function [scs_m,corinv,cor,sco_mat,links_table,ok,flgcdgen,freof]=treat_sample_clk(scs_m,corinv,cor,sco_mat,links_table,flgcdgen,path)
// copyright: INRIA
// Anthor: Fady NASSIF
// Date: 23-1-2009
// we can put here a test for the method to use in the future 

// The Code generator will use the method with the fixed step
// Scicos Simulator will use the method of variable step
ok=%t;freof=[];
index=find(sco_mat(:,5)==string(4)) //index of SampleCLK blocks
if index<>[] then
  sco_mat1=sco_mat(index,:);
  sco_mat(index,:)=[];
  if flgcdgen<>-1 then  // Code Generator or Scicos Simulator with fixed step
    [scs_m,corinv,cor,links_table,ok,flgcdgen,freof]=FixedStepMethod(scs_m,corinv,cor,sco_mat1,links_table,path)
  else // Scicos Simulator with variable step
    [scs_m,corinv,cor,links_table,ok]=VariableStepMethod(scs_m,corinv,cor,sco_mat1,links_table,path)
  end
end
endfunction

function [scs_m,corinv,cor,Ts,ok,flgcdgen,freof]=FixedStepMethod(scs_m,corinv,cor,MAT,Ts,path)
[frequ,offset,freqdiv,flg,ok]=ComputeClockFreqOff(MAT)
if ok then 
  [scs_m,corinv,cor,Ts,flgcdgen,freof]=update_changes(scs_m,corinv,cor,MAT,Ts,path,frequ,offset,freqdiv,flg);
end
endfunction

function [frequ,offset,freqdiv,flg,ok]=ComputeClockFreqOff(MAT)
ok=%t;
flg=1;
freq1=evstr(MAT(:,3));
offset1=evstr(MAT(:,4));
[m,k]=uni(freq1,offset1);
if size(m,'*')==1 then flg=0;end  // case of one offset and one frequency.
freqdiv=freq1(k)
if size(unique(offset1),'*')==1 then  // case of one offset
  v=freqdiv;
  offset=offset1(1);
else   // multiple offsets
  offset=offset1(k);
  v=[freqdiv;offset];
  offset=0;
end
v=v(find(v<>0));
min_v=min(v);max_v=max(v);
if (max_v/min_v)>1e5 then message(['The difference between the frequencies is very large';..
	'the clocks could not be synchronized']);
  ok=%f;Ts=[];bllst=[];corinv=list();indout=[];
  return; 
end
[freqdiv,den]=GetDenNum(v,max_v,scs_m.props.tol(3));
frequ=double(den);
if frequ==[] then frequ=0;end
if offset==[] then offset=0; end
if (offset > frequ) then
   offset=modulo(offset,frequ)
   if (offset~=0) then ok=%f; end
end
endfunction

function [scs_m,corinv,cor,Ts,flgcdgen,freof]=update_changes(scs_m,corinv,cor,MAT,Ts,path,frequ,offset,freqdiv,flg)
//modification to support double
// when the function is called by the code generator we add an input event to the diagram
// the major clock will be put outside the superblock. it will be explicitly drawn.
// In the other case the major clock will be implicitly used in the diagram.

// Adding the first block 
new_blk=scicos_block();
if flgcdgen<>-1 then // when the function is called by the codegeneration.
  flgcdgen=flgcdgen+1 	// the flgcdgen contains the number of event input.
  // we incremented to be able to add the sampleclk to the diagram at the end
  // Adding the event input block.
  new_blk.model=scicos_model(sim=list("bidon",0),in=[],in2=[],intyp=1,out=[],out2=[],..
      outtyp=1,evtin=[],evtout=1,state=[],dstate=[],odstate=list(),..
      rpar=[],ipar=flgcdgen,opar=list(),blocktype="d",firing=-1,..
      dep_ut=[%f,%f],label="",nzcross=0,nmode=0,equations=list());
  freof=[frequ;offset];
else
  new_blk.model=scicos_model(sim=list("evtdly4",4),in=[],in2=[],intyp=1,out=[],out2=[],..
      outtyp=1,evtin=1,evtout=1,state=[],dstate=[],odstate=list(),..
      rpar=[frequ;offset],ipar=[],opar=list(),blocktype="d",firing=offset,..
      dep_ut=[%f,%f],label="",nzcross=0,nmode=0,equations=list());
  freof=[frequ;offset];
end
scs_m.objs($+1)=new_blk;
n_scs_m=lstsize(scs_m.objs);
// Adjusting cor and corinv
[corinv,cor]=AdjustingCorCorinv(corinv,cor,path,MAT,n_scs_m)
nb=size(corinv)
if flgcdgen==-1 then
  // linking the output of the evtdly to its input.
  Ts($+1:$+2,:)=[nb 1 -1 -1;..
	  nb 1 1  -1]
end
if flg then //more then one frequency or offset   
  nn=lcm(freqdiv);
  //Adding the counter to the block list.
  new_blk=scicos_block();
  new_blk.model=scicos_model(sim=list("counter",4),in=[],in2=[],intyp=1,out=1,out2=1,..
      outtyp=1,evtin=1,evtout=[],state=[],dstate=0,odstate=list(),..
      rpar=[],ipar=[1;double(nn);1],opar=list(),blocktype="c",firing=[],..
      dep_ut=[%f,%f],label="",nzcross=0,nmode=0,equations=list());
  scs_m.objs($+1)=new_blk;
  n_scs_m=lstsize(scs_m.objs);
  // Adjusting cor and corinv
  [corinv,cor]=AdjustingCorCorinv(corinv,cor,path,MAT,n_scs_m)
  
  // Adding the event select to the block list.
  new_blk=scicos_block();
  new_blk.model=scicos_model(sim=list("eselect",-2),in=1,in2=1,intyp=-1,out=[],out2=[],..
      outtyp=1,evtin=[],evtout=ones(nn,1),state=[],dstate=[],odstate=list(),..
      rpar=[],ipar=[],opar=list(),blocktype="l",firing=-ones(nn,1),..
      dep_ut=[%t,%f],label="",nzcross=0,nmode=0,equations=list());
  scs_m.objs($+1)=new_blk;
  n_scs_m=lstsize(scs_m.objs);
  // Adjusting cor and corinv
  [corinv,cor]=AdjustingCorCorinv(corinv,cor,path,MAT,n_scs_m)
  nb=size(corinv)
  
  // linking the event output of the evntdly or the bidon to the counter.
  // and linking the regular output of the counter to the event select.
  Ts($+1:$+4,:)=[nb-2 1 -1 -1;..
	  nb-1,1,1,-1;..
	  nb-1,1,-1,1;..
	  nb,1,1,1]
  // replacing the SampleClk by the output of the event select
  index=find(MAT(:,5)==string(4))
  for i=1:size(MAT,1)
    num=-evstr(MAT(i,1))
    Ts(find(Ts(:,1)==num),1)=-num
    K=0:nn-1;
    M=find(modulo(int(K),int(round(evstr(MAT(i,3))/frequ)))==0)';
    ON=ones(size(M,'*'),1)
    Ts($+1:2:$+2*size(M,'*'),:)=[nb*ON round(M+ON*(evstr(MAT(i,4))/frequ-offset)) -ON -ON]
    N=[1:size(M,'*')]';
    Ts($+1-(2*size(M,'*')-2):2:$+1,:)=[-num*ON N ON -ON]
  end
else
  nb=size(corinv)
  ON=ones(size(MAT,1),1)
  Ts($+1:2:$+2*size(MAT,1),:)=[nb*ON ON -ON -ON]
  num=-evstr(MAT(:,1))
  Ts($+1-(2*size(MAT,1)-2):2:$+1,:)=[-num ON ON -ON]
  for i=1:size(MAT,1)
    Ts(find(Ts(:,1)==num(i)),1)=-num(i)
  end
end
endfunction

function [scs_m,corinv,cor,Ts,ok]=VariableStepMethod(scs_m,corinv,cor,MAT,Ts,path)
ok=%t  // removing the computed sample clk from the sco_mat.
frequ=evstr(MAT(:,3));  // frequencies of the sampleCLK
offset=evstr(MAT(:,4)); // offsets of the SampleCLK
offset=offset(:);frequ=frequ(:); 
[m,den,off,count,m1,fir,frequ,offset,ok]=mfrequ_clk(frequ,offset);
if ~ok then return;end
mn=(2**size(m1,'*'))-1;//number of event outputs.
new_blk=scicos_block();
new_blk.model=scicos_model(sim=list("m_frequ",4),in=[],in2=[],intyp=1,out=[],out2=[],outtyp=1,..
    evtin=1,evtout=ones(mn,1),state=[],dstate=[],odstate=list(),rpar=[],ipar=[],..
    opar=list(m,double(den),off,count),blocktype="d",firing=fir,dep_ut=[%f,%f],..
    label="",nzcross=0,nmode=0,equations=list());
scs_m.objs($+1)=new_blk;
n_scs_m=lstsize(scs_m.objs);
[corinv,cor]=AdjustingCorCorinv(corinv,cor,path,MAT,n_scs_m)
nb=size(corinv);
k=1:mn;
//connecting all the event outputs to the event input of the M_Frequ block
Ts($+1:2:$+2*mn,:)=[nb*ones(mn,1) k' -ones(mn,2)]
Ts($+1-(2*mn-2):2:$+1,:)=[nb*ones(mn,1) ones(mn,2) -ones(mn,1)]
//replacing the SampleCLK by the outputs of the M_frequ
for i=1:size(frequ,'*')
  num=evstr(MAT(find((evstr(MAT(:,3))==frequ(i))&(evstr(MAT(:,4))==offset(i))),1))
  for ii=num'
    Ts(find(Ts(:,1)==-ii),1)=ii;
    j=2**(i-1):2**i:mn;
    v=j;
    for k=1:2**(i-1)-1;
      v=[v,j+k]
    end
    v=(unique(v))
    ON=ones(size(v,'*'),1)
    N=[1:size(v,'*')]';
    Ts($+1:2:$+2*size(v,'*'),:)=[nb*ON v' -ON -ON]
    Ts($+1-(2*size(v,'*')-2):2:$+1,:)=[ii*ON N ON -ON]
  end
end
endfunction

function [m,k]=uni(fr,of)
k=[];
m=[];
ot=[];
for i=1:size(fr,'*')
  istreated=%f;
  ind=find(m==fr(i));
  if ind==[] then
    m=[m;fr(i)];
    ot=[ot;of(i)];
    k=[k;i];
  else
    for j=ind
      if of(i)==ot(j) then
	istreated=%t
      end
    end
    if ~istreated then
      m=[m;fr(i)];
      ot=[ot;of(i)]
      k=[k;i];
    end
  end
end
endfunction 

function [corinv,cor]=AdjustingCorCorinv(corinv,cor,path,MAT,n_scs_m)
corinv($+1)=list();
for i=1:size(MAT,1)
  cor_point=evstr(MAT(i,2))
  n_path=size(path,'*')
  cor_point=cor_point([n_path+1:$]);
  corinv($)(i)=cor_point;
  tt='cor'
  for j=1:size(cor_point,'*')
    tt=tt+'('+string(cor_point(j))+')'
  end
  tt=tt+'='+string(size(corinv));
  execstr(tt);
end
corinv($)($+1)=[n_scs_m]  // we will not put it in the cor because this block will be removed from corinv in c_pass1.
                              // we just put it here to be compatible with the algorithm of c_pass1.
endfunction
