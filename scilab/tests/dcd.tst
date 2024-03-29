// Copyright INRIA
prec=1.e-5;

// test for beta distribution 
//===========================
A=2;B=3;bn=1;
deff('[y]=Beta(x)','y=bn*(x^(A-1) * (1-x)^(B-1))');
bn=intg(0,1,Beta);bn=1/bn;
if norm(intg(0,1,Beta)-1)> prec then pause,end

x=0:0.1:1; y=1-x;
p1=[]; for k=x ; p1=[p1,intg(0,k,Beta)];end

A=2*ones(x);B=3*ones(x);
[p,q]=cdfbet('PQ',x,y,A,B);
if norm(p-p1) > prec then pause,end

[x1,y1]=cdfbet('XY',A,B,p,q);
if norm(x-x1) > prec then pause,end 
if norm(y-y1) > prec then pause,end 

A1=cdfbet('A',B,p,q,x,y);
// x=0 or x=1 do not work 
if norm(A1(2:$-1)-A(2:$-1)) > prec then pause,end 
B1=cdfbet('B',p,q,x,y,A);
if norm(B1(2:$-1)-B(2:$-1)) > prec then pause,end 

//test cdfbin 
//==========================
// CN^k pr^k(1-pr)^(Xb-k) 
XN=10;PR=0.34;
deff('k=fact(n)','if n<=1;k=1;else k=n*fact(n-1);end');
deff('cnk=CNK(N,k)','cnk=fact(N)/(fact(k)*fact(N-k))');
pr=[];
S=0:XN;
for k=S,pr=[pr,CNK(XN,k)*(PR)^k*(1-PR)^(XN-k)];end 
Sth=cumsum(pr);
[Sth1,q]=cdfbin("PQ",S,XN*ones(S),PR*ones(S),(1-PR)*ones(S));
if norm(Sth-Sth1) > prec then pause,end 

XN=10;
S=0:XN;
PR=rand(1,XN+1,'u');
OMPR=1-PR;
XN1=XN*ones(1,XN+1);
[P,Q]=cdfbin("PQ",S,XN1,PR,OMPR);
[S1]=cdfbin("S",XN1,PR,OMPR,P,Q);
[XN2]=cdfbin("Xn",PR,OMPR,P,Q,S);
[PR1,OMPR1]=cdfbin("PrOmpr",P,Q,S,XN1);
if norm(S1-S) > prec  then pause,end
if norm(XN1(1:$-1)-XN2(1:$-1)) > 10*prec  then pause,end
// not good when pr is near 1 or zero 
if norm(PR1(1:$-1)-PR(1:$-1)) > 0.1  then pause,end

// test for cdfchi
//=================
x=[0.01,0.025,0.05,0.1,0.9,0.95];
deff('[y]=chi1(x)','y=exp(-x/2)/sqrt(2*%pi*x)');
y1=[];for xx=x, y1=[y1,intg(0,xx,chi1)];end 
y2=cdfchi("PQ",x,ones(x));
if norm(y1-y2) > prec then pause,end 

df=[1,2,3,4,5,6];
[P,Q]=cdfchi("PQ",x,df);
[x1]=cdfchi("X",df,P,Q);
[df1]=cdfchi("Df",P,Q,x);
if norm(x1-x) > prec then pause,end 
if norm(df1-df) > prec then pause,end 

// test for cdfchn
//=================

x=[0.01,0.025,0.05,0.1,0.9,0.95];
y1=cdfchi("PQ",x,ones(x));
y2=cdfchn("PQ",x,ones(x),0*ones(x));
if norm(y1-y2) > prec then pause,end 
df=[1,2,3,4,5,6];
pno=df/10;
[P,Q]=cdfchn("PQ",x,df,pno);
[x1]=cdfchn("X",df,pno,P,Q);
[df1]=cdfchn("Df",pno,P,Q,x);
if norm(x1-x) > prec then pause,end 
if norm(df1-df) > prec then pause,end 

// test for cdff
//=================

f=[1:2];
dfn=[1:2];
dfd=2*dfn;

[P,Q]=cdff("PQ",f,dfn,dfd);
[f1]=cdff("F",dfn,dfd,P,Q);
[dfn1]=cdff("Dfn",dfd,P,Q,f);
[dfd1]=cdff("Dfd",P,Q,f,dfn);
if norm(f1-f) > prec then pause,end 
if norm(dfn1-dfn) > prec then pause,end 
if norm(dfd1-dfd) > prec then pause,end 

// test for cdffnc
//=================

f=[1:2];
dfn=[1:2];
dfd=2*dfn;
pn=[0,1];

[P,Q]=cdffnc("PQ",f,dfn,dfd,pn);
[f1]=cdffnc("F",dfn,dfd,pn,P,Q);
[dfn1]=cdffnc("Dfn",dfd,pn,P,Q,f);
//[dfd1]=cdffnc("Dfd",pn,P,Q,f,dfn);
[pnonc]=cdffnc("Pnonc",P,Q,f,dfn,dfd);
if norm(f1-f) > prec then pause,end 
if norm(dfn1-dfn) > prec then pause,end 
//if norm(dfd1-dfd) > prec then pause,end 
if norm(pnonc-pn) > prec then pause,end 

// test for cdfgam
//=================

shape=2;scale=3;bn=1;
deff('[y]=Gamma(x)','y=bn*(x^(shape-1) * exp(-scale*x))');
bn=intg(0,10^3,Gamma);bn=1/bn;
x=1:10;
[P,Q]=cdfgam("PQ",x,shape*ones(x),scale*ones(x));
P1=[];for xx=x; P1=[P1,intg(0,xx,Gamma)];end 
if norm(P1-P) > prec then pause,end 

shape=2*x;
scale=3*x;
[P,Q]=cdfgam("PQ",x,shape,scale);
[x1]=cdfgam("X",shape,scale,P,Q);
[shape1]=cdfgam("Shape",scale,P,Q,x);
[scale1]=cdfgam("Scale",P,Q,x,shape);
if norm(shape1-shape) > 10*prec then pause,end 
if norm(scale1-scale) > 10*prec then pause,end 
if norm(x1-x) > prec then pause,end 

// test for cdfnbn
//=================

S=2;Xn=10;
Pr=0.4;
Ompr=1-Pr;
[P,Q]=cdfnbn("PQ",S,Xn,Pr,Ompr);
[S1]=cdfnbn("S",Xn,Pr,Ompr,P,Q);
[Xn1]=cdfnbn("Xn",Pr,Ompr,P,Q,S);
[Pr1,Ompr1]=cdfnbn("PrOmpr",P,Q,S,Xn);
if norm(Pr1-Pr)> prec then pause,end
if norm(Xn1-Xn)> prec then pause,end
if norm(S1-S)> prec then pause,end

//test for cdfnor 
//===========================

x=0:0.1:3;
[p,q]=cdfnor("PQ",x,0.0*ones(x),1.0*ones(x));
if norm( p - 1/2*(1+erf(x/sqrt(2))))> 100*%eps then pause,end 
yy=cdfnor("PQ",0.5,0.0,1.0);

deff('y=f(t)','y=exp(-t^2/2)');
if norm(yy-(1/2+ 1/sqrt(2*%pi)*intg(0,0.5,f)))> %eps then pause,end

[x1]=cdfnor("X",0.0*ones(x),1.0*ones(x),p,q);
if norm(x-x1) > prec then pause,end 

M=2*x;
[p,q]=cdfnor("PQ",x,M,1.0*ones(x));
M1=cdfnor("Mean",1.0*ones(x),p,q,x);
if norm(M-M1) > prec then pause,end

// avoid M=x
M=2*x+1;
Std=x+1;
[p,q]=cdfnor("PQ",x,M,Std);
Std1=cdfnor("Std",p,q,x,M);
if norm(Std-Std1) > prec then pause,end

// test for cdfpoi
//=================

xlam=0.34;
deff('k=fact(n)','if n<=1;k=1;else k=n*fact(n-1);end');
deff('s=S(k)','s=0;for j=0:k,s=s+ exp(-xlam)*(xlam)^j/fact(j);end');
X=0:10;
C=feval(X,S);
[P,Q]=cdfpoi("PQ",X,xlam*ones(X));
if norm(P-C) > 100*%eps then pause,end 

xlam=0.1*(1:11);
X=0:10;
[P,Q]=cdfpoi("PQ",X,xlam);
X1=cdfpoi("S",xlam,P,Q);
xlam1=cdfpoi("Xlam",P,Q,X);
if norm(X1-X) > prec then pause,end 
if norm(xlam1-xlam) > prec then pause,end 

// test for cdft (student) 
//=================
// using a table 
Tab=[0.9,0.5,0.3,0.20,0.10,0.05,0.02];
Df=[1,2,3,4,5,6,7];
Th=[0.158,0.816,1.250,1.533,2.015,2.447,2.998];
[P1,Q1]=cdft("PQ",Th,Df) ;
[P2,Q2]=cdft("PQ",-Th,Df) ;
if norm(Tab-(Q1+P2)) > 0.1 then pause ; end 

[P,Q]=cdft("PQ",Th,Df);
Th1=cdft("T",Df,P,Q);
Df1=cdft("Df",P,Q,Th);

if norm(Th1-Th) > prec then pause,end 
if norm(Df1-Df) > prec then pause,end 



