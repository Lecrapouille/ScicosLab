function [m,den,off,count,m1,fir,frequ,offset,ok]=mfrequ_clk(frequ,offset)
// copyright: INRIA
// Anthor: Fady NASSIF
// Date: 2007-2008
// Last Update 15 Dec 2008
m=[];den=[];off=[];count=[];m1=[];fir=[];x=treat_sample_clk;
[m1,k]=uni(frequ,offset); // m1 is a vector of different frequencies or same frequencies with different offsets
// k is the index.
frequ=frequ(k);  // delete the dupplicated frequencies.
offset=offset(k); // delete the dupplicated offset.
v=[frequ;offset];
vv=v(find(v<>0));
min_v=min(vv);max_v=max(vv);
if (max_v/min_v)>1e5 then message(['The difference between the frequencies is very large';..
	'the clocks could not be synchronized']);
ok=%f;
return; 
end
[frd1,den]=GetDenNum(v,max_v,scs_m.props.tol(3));
ppcm=lcm(frd1(1:size(frequ,'*')));
frd1=double(frd1);
if size(frequ,'*')>1 then   // more than one frequency
  mat=[];
  for i=1:size(frequ,'*')
    mat1=[frd1(i+size(frequ,'*')):frd1(i):double(ppcm)]';// for each frequency
    mat=[mat;[mat1 2^(i-1)*ones(size(mat1,'*'),1)]]; // contains the frequency and the corresponding output.
  end
  [n,k]=gsort(mat(:,1),'g','i'); 
  mat=mat(k,:);  // sorting the mat matrix (increasingly).
  // if two outputs are called at the same time they are replaced by an other output; the intersection of the two.
  if size(mat,1)>10000 then
    num=message(['Warning: Your system is too hard to synchronize it will take some time';
	'And the stacksize has to be increase';
	' A scilab crash may occur';
	'Do You want me to continue?'],['No','Yes'])
    if num==1 then 
      ok=%f;
      return
    end
  end 
  vv=mat(2:$,1)-mat(1:$-1,1);
  vv=[1;vv;1];
  kkk=find(vv(:)==0);
  kk=find(vv);
  for i=1:size(kk,2)-1
    mat(kk(i),2)=sum(mat(kk(i):kk(i+1)-1,2));
  end
  mat(kkk(:),:)=[];

  //constructing the first element of opar
  m=[mat(1,1);mat(2:$,1)-mat(1:$-1,1)]; //contains the first element of the chain and the delay.
  last_delay=double(ppcm)-mat($,1)+mat(1,1)  // finding the last delay. 
  // In other world finding the delay between the last element
  // and the first element of mat. So we can have a cycle.
  if last_delay<>0 then   // all the offset are different from 0.
    m($+1)=last_delay  // we add the last delay to m.
    m=[m,[mat(:,2);mat(1,2)],[mat(:,1);double(ppcm)+mat(1,1)]]  // the event output for the last element
    // will be equal to the first one.
    // the time will be the lcm+the delay of the first element
  else     // there is at least one offset that is equal to 0.
    m=[m,mat(:,2),mat(:,1)];  // we don't have to add the last delay because in this case it will be equal to 0.
  end
  count=int32(m(1,1));   // we put the first element of the matrix in a variable that will initialise the counter.
  m(1,:)=[];    // we delete the first row of the matrix. the delay is conserv in the variable count.
  mn=(2**size(m1,'*'))-1;  // find the number of event output.
  fir=-ones(1,mn);  // put all the element of the firing to -1
  fir(mat(1,2))=mat(1,1)*double(den);// programming the corresponding event output
  // by the first element of the matrix mat.(first delay).
  off=0;  // the offset in this case will be equal to 0 because it is implemented in the calculation
  // of the delay.
else
  // case of one frequency
  m=[frd1(1) 1 frd1(1)];  // put the delay in the matrix. the delay will be equal to the one frequency.
  count=int32(0);   //  the counter will begin by 0.
  mat=m;         
  off=offset;       // the offset is put in the variable off. used by the simulator.
  fir=off;          // program the event output of the block by the corresponding offset.
end
endfunction
