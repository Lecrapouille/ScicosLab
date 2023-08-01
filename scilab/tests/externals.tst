//to test error recovery inside externals
//----------------------------------------------------------------------
//feval
//external evaluation error
function y=elfind(x),y = 1+SSS;endfunction
if execstr('z=feval(1:3,elfind)','errcatch')<>4 then pause,end

//incorrect value returned
function y=elfind1(x),y = %t;endfunction
if execstr('z=feval(1:3,elfind1)','errcatch')<>98 then pause,end
clear elfind elfind1
//----------------------------------------------------------------------
//ode -without jacobian
//external evaluation error
function xdot=f(t,x),xdot=1+SSS;endfunction 
if execstr('ode([1;2],0,1,f)','errcatch')<>4 then pause,end
//incorrect value returned
function xdot=f1(t,x),xdot=1;endfunction 
if execstr('ode([1;2],0,1,f1)','errcatch')<>98 then pause,end
//ode -without jacobian
A=[10,0;0,-1];
//external evaluation error
function xdot=f2(t,x),xdot=A*x,endfunction 
function J=Jacobian(t,y),J=A1,endfunction 
if execstr('ode(""stiff"",[0;1],0,1,f2,Jacobian)','errcatch')<>4 then pause,end
//incorrect value returned
function J=Jacobian1(t,y),J=1,endfunction 
if execstr('ode(""stiff"",[0;1],0,1,f2,Jacobian1)','errcatch')<>98 then  pause,end
clear f f1 Jacobian Jacobian1
//----------------------------------------------------------------------
//ode root

function ydot=f(t,y),ydot=y,endfunction
function z=g(t,y),z=y-2,endfunction
//external evaluation error
function z=g1(t,y),z=x1,endfunction
if execstr('[y,rd]=ode(""roots"",1,0,2,f,1,g1)','errcatch')<>4 then pause,end
//incorrect value returned
function z=g2(t,y),z=1:3,endfunction
if execstr('[y,rd]=ode(""roots"",1,0,2,f,1,g2)','errcatch')<>98 then  pause,end
clear f g g1 g2
//----------------------------------------------------------------------
//dassl
function [r,ires]=chemres(t,y,yd)
         r(1)=-0.04*y(1)+1d4*y(2)*y(3)-yd(1);
         r(2)=0.04*y(1)-1d4*y(2)*y(3)-3d7*y(2)*y(2)-yd(2)
         r(3)=y(1)+y(2)+y(3)-1;
         ires=0
endfunction
function pd=chemjac(x,y,yd,cj)
         pd=[-0.04-cj , 1d4*y(3)               , 1d4*y(2);
         0.04    ,-1d4*y(3)-2*3d7*y(2)-cj ,-1d4*y(2);
         1       , 1                      , 1       ]
endfunction

y0=[1;0;0];
yd0=[-0.04;0.04;0];
t=1:10
info=list([],1,[],[],[],0,0);
//external evaluation error
clear x1
function [r,ires]=chemres1(t,y,yd),r=x1,ires=0,endfunction
if execstr('y=dassl([y0,yd0],0,4d10,chemres1,info)','errcatch')<>4 then pause,end
if execstr('y=dassl([y0,yd0],0,4d10,chemres1,chemjac,info)','errcatch')<>4 then pause,end
function  pd=chemjac1(x,y,yd,cj),pd=x1;endfunction
if execstr('y=dassl([y0,yd0],0,4d10,chemres,chemjac1,info)','errcatch')<>4 then  pause,end

//incorrect value returned
function [r,ires]=chemres2(t,y,yd),r=[],ires=0,endfunction
if execstr('y=dassl([y0,yd0],0,4d10,chemres2,info)','errcatch')<>98 then pause,end
if execstr('y=dassl([y0,yd0],0,4d10,chemres2,chemjac,info)','errcatch')<>98 then pause,end
function  pd=chemjac2(x,y,yd,cj),pd=[];endfunction
if execstr('y=dassl([y0,yd0],0,4d10,chemres,chemjac2,info)','errcatch')<>98 then  pause,end

clear chemres chemres1 chemres2  chemjac chemjac1 chemjac2
//----------------------------------------------------------------------
//dasrt
y0=1;t=2:6;t0=1;y0d=3;
atol=1.d-6;rtol=0;ng=2;
function [delta,ires]=res(t,y,ydot),ires=0;delta=ydot-((2*log(y)+8)/t-5)*y,endfunction
function rts=gr(t,y),rts=[((2*log(y)+8)/t-5)*y;log(y)-2.2491],endfunction
//external evaluation error
clear x1
function [delta,ires]=res1(t,y,ydot),ires=0;delta=x1;endfunction
if execstr('[yy,nn]=dasrt([y0,y0d],t0,t,atol,rtol,res1,ng,gr)','errcatch')<>4 then pause,end
function rts=gr1(t,y),rts=x1,endfunction
if execstr('[yy,nn]=dasrt([y0,y0d],t0,t,atol,rtol,res,ng,gr1)','errcatch')<>4 then pause,end
//incorrect value returned
function [delta,ires]=res2(t,y,ydot),ires=0;delta=1:3;endfunction
if execstr('[yy,nn]=dasrt([y0,y0d],t0,t,atol,rtol,res2,ng,gr)','errcatch')<>98 then  pause,end
function rts=gr2(t,y),rts=1:3,endfunction
if execstr('[yy,nn]=dasrt([y0,y0d],t0,t,atol,rtol,res,ng,gr2)','errcatch')<>98 then  pause,end
clear res res1 res2 gr gr1 g2
//----------------------------------------------------------------------
//impl

function res=f(t,x,xdot),res=eye(2,2)*xdot-1;endfunction 
function r=a(t,y,p),r=eye(2,2)-p;endfunction 
//external evaluation error
function res=f1(t,x,xdot),res=xdot-SSS;endfunction 
function r=a1(t,y,p),r=SSS-p;endfunction 
if execstr('y=impl([1;0],[0;0],0,0.4,f1,a)','errcatch')<>4 then pause,end
if execstr('y=impl([1;0],[0;0],0,0.4,f,a1)','errcatch')<>4 then pause,end

//incorrect value returned
function res=f2(t,x,xdot),res=1;endfunction 
function r=a2(t,y,p),r=[];endfunction 
if execstr('y=impl([1;0],[0;0],0,0.4,f2,a)','errcatch')<>98 then  pause,end
if execstr('y=impl([1;0],[0;0],0,0.4,f,a2)','errcatch')<>98 then  pause,end
clear f f1 f2 a a1 a2
//----------------------------------------------------------------------
//bvode
deff('df=dfsub(x,z)','df=[0,0,-6/x**2,-6/x]')
deff('f=fsub(x,z)','f=(1 -6*x**2*z(4)-6*x*z(3))/x**3')
deff('g=gsub(i,z)','g=[z(1),z(3),z(1),z(3)];g=g(i)')
deff('dg=dgsub(i,z)',['dg=[1,0,0,0;0,0,1,0;1,0,0,0;0,0,1,0]';
                      'dg=dg(i,:)'])
deff('[z,mpar]=guess(x)','z=0;mpar=0')// unused here


fixpnt=0;m=4;ncomp=1;aleft=1;aright=2;
zeta=[1,1,2,2];ipar=zeros(1,11);
ipar(3)=1;ipar(4)=2;ipar(5)=2000;ipar(6)=200;ipar(7)=1;
ltol=[1,3];tol=[1.e-11,1.e-11];res=aleft:0.1:aright;

//external evaluation error
deff('df=dfsub1(x,z)','df=[0,0,-6/x**2,-6/x1]')
if execstr('z=bvode(res,ncomp,m,aleft,aright,zeta,ipar,ltol,tol,fixpnt,"+...
	"fsub,dfsub1,gsub,dgsub,guess)','errcatch')<>4 then pause,end

deff('f=fsub1(x,z)','f=(1 -6*x1**2*z(4)-6*x*z(3))/x**3')
if execstr('z=bvode(res,ncomp,m,aleft,aright,zeta,ipar,ltol,tol,fixpnt,"+...
	"fsub1,dfsub,gsub,dgsub,guess)','errcatch')<>4 then pause,end

deff('g=gsub1(i,z)','g=[z1(1),z(3),z(1),z(3)];g=g(i)')
if execstr('z=bvode(res,ncomp,m,aleft,aright,zeta,ipar,ltol,tol,fixpnt,"+...
	"fsub,dfsub,gsub1,dgsub,guess)','errcatch')<>4 then pause,end

deff('dg=dgsub1(i,z)',['dg=[1,0,0,0;0,0,1,0;1,0,0,0;0,0,z1,0]';
                      'dg=dg(i,:)'])
if execstr('z=bvode(res,ncomp,m,aleft,aright,zeta,ipar,ltol,tol,fixpnt,"+...
	"fsub,dfsub,gsub,dgsub1,guess)','errcatch')<>4 then pause,end

//incorrect value returned
deff('df=dfsub2(x,z)','df=[0,0,-6/x**2,-6/x,1]')
if execstr('z=bvode(res,ncomp,m,aleft,aright,zeta,ipar,ltol,tol,fixpnt,"+...
	"fsub,dfsub2,gsub,dgsub,guess)','errcatch')<>98 then  pause,end

deff('f=fsub2(x,z)','f=[1;2]')
if execstr('z=bvode(res,ncomp,m,aleft,aright,zeta,ipar,ltol,tol,fixpnt,"+...
	"fsub2,dfsub,gsub,dgsub,guess)','errcatch')<>98 then  pause,end

deff('g=gsub2(i,z)','g=[1 2]')
if execstr('z=bvode(res,ncomp,m,aleft,aright,zeta,ipar,ltol,tol,fixpnt,"+...
	"fsub,dfsub,gsub2,dgsub,guess)','errcatch')<>98 then  pause,end

deff('dg=dgsub2(i,z)',['dg=1'])
if execstr('z=bvode(res,ncomp,m,aleft,aright,zeta,ipar,ltol,tol,fixpnt,"+...
	"fsub,dfsub,gsub,dgsub2,guess)','errcatch')<>98 then  pause,end
clear dfsub dfsub1 dfsub2 fsub fsub1 fsub2 gsub gsub1 gsub2 dgsub dgsub1 dgsub2 
//----------------------------------------------------------------------
//corr
rand('normal');x=rand(1,256);y=-x;
deff('[z]=xx(inc,is)','z=x(is:is+inc-1)');
deff('[z]=yy(inc,is)','z=y(is:is+inc-1)');
//external evaluation error
deff('[z]=xx1(inc,is)','z=x1(is:is+inc-1)');
deff('[z]=yy1(inc,is)','z=y1(is:is+inc-1)');
if execstr('[c3,m3]=corr(''fft'',xx1,yy,256,32)','errcatch')<>4 then pause,end
if execstr('[c4,m4]=corr(''fft'',xx1,256,32)','errcatch')<>4 then pause,end
if execstr('[c3,m3]=corr(''fft'',xx,yy1,256,32)','errcatch')<>4 then pause,end
//incorrect value returned
deff('[z]=xx2(inc,is)','z=1');
deff('[z]=yy2(inc,is)','z=1');
if execstr('[c3,m3]=corr(''fft'',xx2,yy,256,32)','errcatch')<>98 then  pause,end
if execstr('[c4,m4]=corr(''fft'',xx2,256,32)','errcatch')<>98 then  pause,end
if execstr('[c3,m3]=corr(''fft'',xx,yy2,256,32)','errcatch')<>98 then  pause,end
clear xx xx1 xx2 yy yy1 yy2
//----------------------------------------------------------------------
//intg
function y=f(x),y=x*sin(30*x)/sqrt(1-((x/(2*%pi))^2)),endfunction
//external evaluation error
function y=f1(x),y=x1*sin(30*x)/sqrt(1-((x/(2*%pi))^2)),endfunction
if execstr('intg(0,2*%pi,f1)','errcatch')<>4 then pause,end
//incorrect value returned
function y=f2(x),y=[1 2],endfunction
if execstr('intg(0,2*%pi,f2)','errcatch')<>98 then  pause,end
clear f f1 f2
//----------------------------------------------------------------------
//int2d
X=[0,0;1,1;1,0];Y=[0,0;0,1;1,1];
deff('z=f(x,y)','z=cos(x+y)')
//external evaluation error
deff('z=f1(x,y)','z=cos(x1+y)')
if execstr('[I,e]=int2d(X,Y,f1)','errcatch')<>4 then pause,end
//incorrect value returned
deff('z=f2(x,y)','z=[]')
if execstr('[I,e]=int2d(X,Y,f2)','errcatch')<>98 then  pause,end
clear f f1 f2
//----------------------------------------------------------------------
//int3d
X=[ 0, 0,    0, 0,    0, 0,    0, 0,    0, 0,    0, 0;          
   -1,-1,   -1,-1,    1, 1,   -1,-1,   -1,-1,   -1,-1; 
    1,-1,    1,-1,    1, 1,   -1,-1,    1,-1,    1,-1;     
    1, 1,    1, 1,    1, 1,   -1,-1,    1, 1,    1, 1];         
Y=[ 0, 0,    0, 0,    0, 0,    0, 0,    0, 0,    0, 0; 
   -1,-1,   -1,-1,   -1, 1,   -1, 1,   -1,-1,    1, 1;
   -1, 1,   -1, 1,    1, 1,    1, 1,   -1,-1,    1, 1;   
    1, 1,    1, 1,   -1,-1,   -1,-1,   -1,-1,    1, 1]; 
Z=[ 0, 0,    0, 0,    0, 0,    0, 0,    0, 0,    0, 0;
   -1,-1,    1, 1,   -1, 1,   -1, 1,   -1,-1,   -1,-1; 
   -1,-1,    1, 1,   -1,-1,   -1,-1,   -1, 1,   -1, 1;  
   -1,-1,    1, 1,    1, 1,    1, 1,    1, 1,    1, 1];      

function v=f(xyz,numfun),v=exp(xyz'*xyz),endfunction
//external evaluation error
function v=f1(xyz,numfun),v=x1,endfunction
if execstr('[result,err]=int3d(X,Y,Z,f1,1,[0,100000,1.d-5,1.d-7])','errcatch')<>4 then pause,end
//incorrect value returned
function v=f2(xyz,numfun),v=[],endfunction
if execstr('[result,err]=int3d(X,Y,Z,f2,1,[0,100000,1.d-5,1.d-7])','errcatch')<>98 then  pause,end
clear f f1 f2
//----------------------------------------------------------------------
//lsqrsolve
a=[1,7;2,8;4 3];b=[10;11;-1];
function y=f(x,m),y=a*x+b;endfunction
function y=fj(x,m),y=a;endfunction
//external evaluation error
clear x1
function y=f1(x,m),y=x1;endfunction
function y=fj1(x,m),y=x1;endfunction
if execstr('[xsol,v]=lsqrsolve([100;100],f1,3)','errcatch')<>4 then pause,end
if execstr('[xsol,v]=lsqrsolve([100;100],f1,3,fj)','errcatch')<>4 then pause,end
if execstr('[xsol,v]=lsqrsolve([100;100],f,3,fj1)','errcatch')<>4 then pause,end
//incorrect value returned
function y=f2(x,m),y=1;endfunction
function y=fj2(x,m),y=[];endfunction
if execstr('[xsol,v]=lsqrsolve([100;100],f2,3)','errcatch') <>98 then  pause,end
if execstr('[xsol,v]=lsqrsolve([100;100],f2,3,fj)','errcatch')<>98 then  pause,end
if execstr('[xsol,v]=lsqrsolve([100;100],f,3,fj2)','errcatch')<>98 then  pause,end
clear f f1 f2 fj fj1 fj2
//----------------------------------------------------------------------
//optim
 xref=[1;2;3];x0=[1;-1;1]
function [f,g,ind]=cost(x,ind),f=0.5*norm(x-xref)^2,g=x-xref, endfunction
//external evaluation error
function [f,g,ind]=cost1(x,ind),f=x1, endfunction
if execstr('[f,xopt]=optim(cost1,x0)','errcatch')<>4 then pause,end
//incorrect value returned
function [f,g,ind]=cost2(x,ind),f=1:2,g=0, endfunction
if execstr('[f,xopt]=optim(cost2,x0)','errcatch')<>98 then  pause,end
clear cost cost1 cost2
//----------------------------------------------------------------------
//schur (revoir lapackf,dgees.f) 
A=diag([-0.9,-2,2,0.9]);
function t=mytest(Ev),t=abs(Ev)<0.95,endfunction
//external evaluation error
//n'est pas traitée, il faudrait modifier le code
//de dgees.f ou utiliser le longjump
function t=mytest1(Ev),t=x1,endfunction
//execstr('[U,dim,T]=schur(A,mytest1)','errcatch') -->bug here
//incorrect value returned
function t=mytest2(Ev),t=[%t %t],endfunction
if execstr('[U,dim,T]=schur(A,mytest2)','errcatch')<>268 then  pause,end
clear mytest mytest1 mytest2
//----------------------------------------------------------------------
//fsolve
a=[1,7;2,8];b=[10;11];
deff('[y]=fsol(x)','y=a*x+b');
deff('[y]=fsolj(x)','y=a');
//external evaluation error
deff('[y]=fsol1(x)','y=x1');
deff('[y]=fsolj1(x)','y=x1');
if execstr('xres=fsolve([100;100],fsol1)','errcatch')<>4 then pause,end
if execstr('xres=fsolve([100;100],fsol1,fsolj)','errcatch')<>4 then pause,end
if execstr('xres=fsolve([100;100],fsol,fsolj1)','errcatch')<>4 then pause,end
//incorrect value returned
deff('[y]=fsol2(x)','y=1');
deff('[y]=fsolj2(x)','y=1');
if execstr('xres=fsolve([100;100],fsol2)','errcatch')<>98 then  pause,end
if execstr('xres=fsolve([100;100],fsol2,fsolj)','errcatch')<>98 then  pause,end
if execstr('xres=fsolve([100;100],fsol,fsolj2)','errcatch')<>98 then  pause,end

clear fsol fsol1 fsol2 fsolj fsolj1 fsolj2
//----------------------------------------------------------------------
//odedc
function xdu=phis(t,x,u,flag),if flag==0 then xdu=A*x+B*u; else xdu=1-u;end,endfunction;
x0=[1;1];A=[-1,2;-2,-1];B=[1;2];u=0;nu=1;stdel=[1,0];u0=0;t=0:0.05:10;
//external evaluation error
function xdu=phis1(t,x,u,flag),if flag==0 then xdu=x1; else xdu=x2;end,endfunction;
if execstr('xu=odedc([x0;u0],nu,stdel,0,t,phis1);x=xu(1:2,:);u=xu(3,:)','errcatch')<>4 then pause,end
//incorrect value returned
function xdu=phis2(t,x,u,flag),if flag==0 then xdu=[]; else xdu=[];end,endfunction;
if execstr('xu=odedc([x0;u0],nu,stdel,0,t,phis2);x=xu(1:2,:);u=xu(3,:)','errcatch')<>98 then  pause,end
clear phis phis1 phis2
//----------------------------------------------------------------------

