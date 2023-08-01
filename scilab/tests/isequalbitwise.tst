//matrices of double floating points numbers
a=rand(2,3);b=a;
if ~isequalbitwise(a,b) then pause,end
if ~isequalbitwise(a+0,b) then pause,end

b(2,3)=b(2,3)+1;
if isequalbitwise(a,b) then pause,end

a=rand(3,2)+%i*rand(3,2);;b=a;
if ~isequalbitwise(a,b) then pause,end
if ~isequalbitwise(a+0,b) then pause,end

b(1,2)=b(1,2)+1;
if isequalbitwise(a,b) then pause,end

if ~isequalbitwise([],[]) then pause,end
if isequalbitwise([],b) then pause,end

if ~isequalbitwise(%nan,%nan) then pause,end
//2 different nan's which are in fact equal bitwise
if ~isequalbitwise(%nan,%nan-%nan) then pause,end

//matrices of strings
if ~isequalbitwise('123','123') then pause,end
if isequalbitwise('123','1234') then pause,end
a=['123','1' 'aa';'','1234455666','AABB'];
if ~isequalbitwise(a,a) then pause,end
if ~isequalbitwise(a+'',a) then pause,end
b=a;b($)='';
if isequalbitwise(a,b) then pause,end

//matrices de booleens
if ~isequalbitwise(%t,%t) then pause,end
if isequalbitwise(%t,%f) then pause,end

a=a==a;
if ~isequalbitwise(a,a) then pause,end
b=a;b(1)=~b(1);
if isequalbitwise(b,a) then pause,end

//Matrices de polynomes
if ~isequalbitwise(%s,%s) then pause,end
if isequalbitwise(%s,%z) then pause,end

if isequalbitwise(%s,%s+1) then pause,end
a=[1 %s+1 %s^2];
if ~isequalbitwise(a,a+0) then pause,end
b=a;b(1)=0;
if isequalbitwise(b,a) then pause,end

//Listes
if ~isequalbitwise(list(1,2),list(1,2)) then pause,end
if isequalbitwise(list(1,2),list(1,3)) then pause,end
r=rand(5,4);
a=list(r,%s+1,'ABCDEFG');
if ~isequalbitwise(a,a) then pause,end
if ~isequalbitwise(a,list(r,%s+1,'ABCDEFG')) then pause,end

b=list(rand(5,4),%s+1);
if ~isequalbitwise(b,b) then pause,end
if isequalbitwise(a,b) then pause,end
if ~isequalbitwise(list(),list()) then pause,end
a=list();a(6)=1:5;
if ~isequalbitwise(a,a) then pause,end
a=list(1,2,list(3,4),5);
if ~isequalbitwise(a,a) then pause,end


//Lib
if ~isequalbitwise(autolib,autolib) then pause,end
if isequalbitwise(elemlib,autolib) then pause,end

//Fonctions
deff('[x,y]=foo()',['x=1;y=2'],'n')
if ~isequalbitwise(foo,foo)   then pause,end
deff('[x,y]=foo1()',['x=1;y=21'],'n')
if isequalbitwise(foo,foo1)   then pause,end

//sparse matrices
a=sprand(200,100,0.01);
if ~isequalbitwise(a,a)   then pause,end
if ~isequalbitwise(a+%i*a,a+%i*a)   then pause,end
k=find(a<>0,1);
b=a;b(k)=1;
if isequalbitwise(a,b)   then pause,end
b=a;b(k)=%i;
if isequalbitwise(a,b)   then pause,end

k=find(a==0,1);
b=a;b(k)=1;
if isequalbitwise(a,b)   then pause,end
b=a;b(k)=%i;
if isequalbitwise(a,b)   then pause,end

a=sparse(zeros(10,3));
if ~isequalbitwise(a,a)   then pause,end


//Matlab sparse matrices
a=sprand(200,100,0.01);
if ~isequalbitwise(mtlb_sparse(a),mtlb_sparse(a))   then pause,end
k=find(a<>0,1);
b=a;b(k)=1;
if isequalbitwise(mtlb_sparse(a),mtlb_sparse(b))   then pause,end

k=find(a==0,1);
b=a;b(k)=1;
if isequalbitwise(mtlb_sparse(a),mtlb_sparse(b))   then pause,end

//boolean sparse matrices
a=sprand(200,100,0.01);
a=a<>0;
if ~isequalbitwise(a,a)   then pause,end
k=find(a,1);
b=a;b(k)=%f;
if isequalbitwise(a,b)   then pause,end

k=find(a==%f,1);
b=a;b(k)=%t;
if isequalbitwise(a,b)   then pause,end

// integer
a=int32(2);
if ~isequalbitwise(a,a)   then pause,end
if isequalbitwise(a,uint32(2))   then pause,end
if isequalbitwise(a,int32(1))   then pause,end

a=uint8(1:10);
if ~isequalbitwise(a,a)   then pause,end

//overloaded type
ftn=['      subroutine changetype'
     'c     to change the type of a variable(testing hard coded type overloading)'
     '      include ''stack.h'''
     '      integer iadr,sadr'
     'c     '
     '      iadr(l)=l+l-1'
     '      sadr(l)=(l/2)+1'
     ''
     '      il=iadr(lstk(top))'
     '      new=stk(sadr(il+4))'
     '      top=top-1'
     '      il=iadr(lstk(top))'
     '      if(istk(il).lt.0) il=iadr(istk(il+1))'
     '      istk(il)=new'
     '      return'
     '      end'];
mputl(ftn,TMPDIR+'/changetype.f')
libn=ilib_for_link('changetype','changetype.o',[],'f',TMPDIR+'/MakeChange');
addinter(libn,'changetype','changetype');
typename('tst',777);

a=changetype(1:3,777)


function r=%tst_isequalbitw(x,y)
   r=isequalbitwise(changetype(x,1),changetype(y,1))
endfunction

if ~isequalbitwise(a,a) then pause,end
b=changetype(1:2,777)

if isequalbitwise(a,b) then pause,end

l=list(1,list(a,2),3);
if ~isequalbitwise(l,l) then pause,end
l1=list(1,list(a,2),2);
if isequalbitwise(l,l1) then pause,end
l1=l;l1(1)=2;
if isequalbitwise(l,l1) then pause,end
l1=l;l1(2)(2)=4;
if isequalbitwise(l,l1) then pause,end
