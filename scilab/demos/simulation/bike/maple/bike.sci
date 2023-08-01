function [r,ires]=bike(t,y,ydot)
  // using dae 
  // y=[q;qdot;gamma]
  // ydot= [qdot;qddot,gammadot];
  ires= 0;
  q=y(1:23);
  qd=y(24:24+22);
  lamgamma=y(24+22+1:$);
  qdot=ydot(1:23);
  qddot=ydot(24:24+22);
  lamgammadot=ydot(24+22+1:$);
  E = ee(q,qd,param);
  A = aa(q,qd,u,param,b0,b1,a0);
  r = E*[qddot;lamgammadot] -A;
  r = [r; qdot - qd ];
endfunction

function ydot=ode_bike(t,y)
  // using ode
  // solving a linear system at each time step
  q=y(1:23);
  qd=y(24:24+22);
  E = ee(q,qd,param);
  A = aa(q,qd,u,param,b0,b1,a0);
  pause 
  sol = E\A;
  qdd = sol(1:23);
  ydot=[qd;qdd];
endfunction

ilib_for_link('aa','aa.o',[],"f");
exec('loader.sce');
exec('aa.sci');

ilib_for_link('ee','ee.o',[],"f");
exec('loader.sce');
exec('ee.sci');

//Name composition for constants:
//////////////////////////////////////
// I.. : Moment of Inertia ,
// m.. : Mass
// ..rw.. : rear wheel
// ..fr.. :front whell
// ..fp.. :front projection
// ..n : normal direction
// ..r : radial direction
//Declaration of used parameters
// vector([Irwn,Irwr,mrw,Ifwn,Ifwr,mfw,rw,Ifrn,Ifrr,mfr,Ifon,Ifor,mfo, Ifpr,Ifpn,mfp,l1,l2,l3,l4,l5,l6,g]):

P1=[0;0;rw];
P5=[1;0;rw];
P4=[1-0.05;0;rw-0.05];
H=[0.7;0;rw+0.5];
PH=[0.7;0;rw];
alpha = (2/3);
P2=P1 + (H-P1)*alpha;
P3=P4 + (H-P4)*alpha;
l1 = norm(P4-P1);
l4 = norm(H-P1);
l5 = norm(H-P4);
l2 = norm(P2-P1);
l3 = norm(P3-P4);
// cos(xi2) = norm(Ph-P1)/l4;
xi2 = acos(norm(PH-P1)/l4);

Irwn=1;
Irwr=1;
mrw=1;
Ifwn=1;
Ifwr=1;
mfw=1;
rw=0.3;
Ifrn=1;
Ifrr=1;
mfr=1;
Ifon=1;
Ifor=1;
mfo=1;
Ifpr=1;
Ifpn=1;
mfp=1;
l1=1;
l2=0.8;
l3=0.3;
l4=1.2;
l5=0.8;
l6=0.1;
g=9.81;

param=[Irwn,Irwr,mrw,Ifwn,Ifwr,mfw,rw,Ifrn,Ifrr,mfr,Ifon,Ifor,mfo, Ifpr,Ifpn,mfp,l1,l2,l3,l4,l5,l6,g];
// S2 + b1*s+b0 et s + a0 stables
a0=4;
b1=7;
b0=12;

x=read('../data/xdemo.dat',46,401,"(e10.4)");
qqd=x(:,1);

u=[0;1];

use_dassl = %f;

getf('../macros/'+'velod.sci');
getf('../macros/'+'velodp.sci');
getf('../macros/'+'show.sci');
getf('../macros/'+'velo1.sci');

if use_dassl then 
  lamgamma=zeros(20,1);
  dx0=[qqd;lamgamma];
  y=dassl(dx0,0,0:0.1:10,bike);
  x=y(2:46+1,:)
  xbasc();
  set figure_style old;
  show(x,1.6,1.47,velo1);
else
  x0=[P1;
      0;0;0;
      P2;
      xi2;
      P3;
      0;0;0;
      P4;
      P5;
     0];
  ox0=[x0;0*x0];
  y=ode(ox0,0,0:0.1:10,ode_bike);
  x=y;
  xbasc();
  set figure_style old;
  show(x,1.6,1.47,velo1);
end

