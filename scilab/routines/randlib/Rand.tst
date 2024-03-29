// tests for randlib

// for "continuous law"

generators = ["mt" "kiss" "clcg2" "clcg4" "urand"];

// test for beta random deviate 

N=10000;A=1;B=3;
Rdev=grand(1,N,'bet',A,B); 
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=cdfbet("PQ",RdevS,1-RdevS,A*ones(RdevS),B*ones(RdevS));
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")

// test for f 

N=10000;A=1;B=3;
Rdev=grand(1,N,'f',A,B); 
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=cdff("PQ",RdevS,A*ones(RdevS),B*ones(RdevS));
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")

// test for mul
 

// test for gamma 

N=10000;A=1;B=3;
Rdev=grand(1,N,'gam',A,B); 
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=cdfgam("PQ",RdevS,A*ones(RdevS),B*ones(RdevS));
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")

// test for nor 

N=10000;A=1;B=2;
Rdev=grand(1,N,'nor',A,B); 
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=cdfnor("PQ",RdevS,A*ones(RdevS),B*ones(RdevS));
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")

// test for unf 

N=10000;A=1;B=2;
Rdev=grand(1,N,'unf',A,B); 
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=RdevS-A;
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")

// test for uin ( a finir ) 

N=10000;A=1;B=10;
Rdev=grand(1,N,'uin',A,B); 
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=RdevS-A;
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")

// test for lgi 

N=10000;
Rdev=grand(1,N,'lgi')
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=RdevS-A;
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")


// test fo perm 

N=1000;
Mat=grand(N,'prm',[1:10]');
if sum([1:10]')/10 - sum(Mat,'c')/N > 0 then pause;end 

// test for nbn 

N=10000;A=5;B=0.7;
Rdev=grand(1,N,'nbn',A,B); 
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=cdfnbn("PQ",RdevS,A*ones(RdevS),B*ones(RdevS),(1-B)*ones(RdevS));
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")


// test for bin 

N=10000;A=5;B=0.7;
Rdev=grand(1,N,'bin',A,B); 
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=cdfbin("PQ",RdevS,A*ones(RdevS),B*ones(RdevS),(1-B)*ones(RdevS));
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")

// test for mn 

// test for 'def'

N=10000;
Rdev=grand(1,N,'def')
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=RdevS;
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")

// test for nch or chn 

N=10000;A=5;B=4;
Rdev=grand(1,N,'nch',A,B); 
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=cdfchn("PQ",RdevS,A*ones(RdevS),B*ones(RdevS));
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")

// test for nf or fnc

N=10000;A=5;B=4;C=10;
Rdev=grand(1,N,'nf',A,B,C); 
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=cdffnc("PQ",RdevS,A*ones(RdevS),B*ones(RdevS),C*ones(RdevS));
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")

// test for chi 

N=10000;A=5;
Rdev=grand(1,N,'chi',A);
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=cdfchi("PQ",RdevS,A*ones(RdevS));
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")

// test for poi 

N=10000;A=50;
Rdev=grand(1,N,'poi',A);
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
[P]=cdfpoi("PQ",RdevS,A*ones(RdevS));
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")


// test for exp 

N=10000;A=2;
Rdev=grand(1,N,'exp',A);
RdevS=sort(Rdev);RdevS=RdevS($:-1:1)';
PS=(1:N)'/N;
//plot2d(RdevS,PS);
// theorical result 
P=1-exp(-RdevS/A);
//plot2d(RdevS,P,2,"000")
norm(P-PS,"inf")

