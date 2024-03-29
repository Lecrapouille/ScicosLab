# Copyright ENPC 2009

read(`Euler.mpl`);

#----------------------------------------------------------------------------
# AND NOW THE WHEEL
#-----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# TeX Notations for my problem 
#-----------------------------------------------------------------------------

ll:= {x = `x`  , y = `y` , z= `z`,theta = `\\theta`, phi = `\\phi`,psi = `\\psi`,param =`\\alpha`, t = `\\eta` , LL = `\\LL`, _t = `\\lambda` } :
addnotations(ll):

#----------------------------------------------------------------------------
# Lagrangian for The wheel problem : 
#---------------------------------------------------------------------------

# Number of parameters:
mpar:=5:
param:=[m,J[1],J[2],r,g]:
# Number of state variables
n:=6:

# Lagragian as a function of q[k], qd[k] k=1,..,n and
# param[m] m=1,..,mpar
# Lagrangian variables :
q := [ x,y,z,theta,phi,psi]:
qd := [ seq ( cat(q[i],`d`),i=1..n)]:
qdd:= [ seq ( cat(q[i],`dd`),i=1..n)]:

#-------------------------------------------
# Geometric computations 
#-------------------------------------------
Bx:=vector([1,0,0]):
By:=vector([0,1,0]):
Bz:=vector([0,0,1]):
Bu1:=vector([cos(theta),sin(theta),0]):
Bu:= matadd(Bu1,Bz,cos(phi),-sin(phi)):
Bw:= matadd(Bu1,Bz,sin(phi),cos(phi)):
Bv:=crossprod(Bw,Bu):
Bv:=map((i)->factor(combine(i,trig)),Bv):

R:=transpose(matrix(3,3,[eval(Bu),eval(Bv),eval(Bw)])):
Rinv:=map((i)->factor(combine(i,trig)),inverse(R)):

# Omega in the (x,y,z) base 

OmegaX:= matadd(Bz,matadd(Bv,Bw,phid,psid),thetad,1):

# Omega in the (u,v,w) base

Omega:=multiply(Rinv,OmegaX):
Omega:=map((i)->factor(combine(i,trig)),Omega):

# J[1]=J[2]=J_u : J[3]=J_w

EcJ:= J[1]*(Omega[1]^2+Omega[2]^2) +J[3]*Omega[3]^2:

L:=(1/2)*( param[1]*(qd[1]^2+qd[2]^2+qd[3]^2) + EcJ )
          -param[1]*param[5]*q[3]:

sorties(`systeme.tex`,`Lagrangian`,L):

# Lhs of Euler equations 

EL:=euler_equations(L,q,qd,qdd):
EE:=map((i)->rhs(i),EL):

# don't forget the LL macro in all.tex 

sorties(`systeme.tex`,`variables :`,` q ` = matrix(nops(q),1,q)):
sortiesM(`systeme.tex`,`Lhs of Euler Equations`,[seq(EL[i,1],i=1..nops(q))]):

#-----------------------------------------------------
# Rewritting the Euler equations to have a canonical form 
#           ..         .
# El= ME(q)  q + CE(q) q^2 + RE(q,...)
# Computation of ME,CE,RE 
#-----------------------------------------------------

XX:=CEuler(EE,q,qd,qdd):

# simplifying notations for output

sortiesI(`systeme.tex`,`$M(q)\\ddot{q}+C(q)\\dot{q}^2 +R(q,\\dot{q})$`):
sorties(`systeme.tex`,`M~:`,XX[1]):
sorties(`systeme.tex`,`C~:`,XX[2]):
sorties(`systeme.tex`,`R~:`,XX[3]):

#------------------------------------------------
# Constraints on the Wheel
#------------------------------------------------

# geometric constraints

hc:=[q[3]-param[4]*sin(q[5])]:

# dynamic constraints ( contains the derivative of geometric constraint )
# v_g + crossprod(OmegaX,Bu)=0

gg:=matadd(vector([qd[1],qd[2],qd[3]]),crossprod(OmegaX,Bu),1,r):
gg:=map((i)->simplify(expand(i)),gg):

nhc:=convert(gg,list):

sortiesM(`systeme.tex`,`Geometric Constraints hc=0,hc:`,hc);
sortiesM(`systeme.tex`,`Dynamic Constraints nhc=0,nhc`,nhc);

# Derivatives of constraints are of type Aprim qd = 0 

Aprim:=genmatrix(nhc,qd):

sorties(`systeme.tex`,`Constraints : $A'(q)\\dot{q}$`,Aprim);

#----------------------------------------------
# Computing SS:=S(q);
# S(q) will solve Aprim S(q) = 0 
# in The Euler equations  Equ= A(q)' lambda + u 
# the term A(q)lambda can be eliminated 
# if we left-multiply euler equations by S(q)'
#----------------------------------------------
ncont:=3;
SS:=linsolve(Aprim,matrix(ncont,1,0)):

sorties(`systeme.tex`,` S(q)`,SS);

#------------------------------------------------------------------------
# The constraints are now dotq=S(q)eta 
# can be used to see that eta =[phi,theta,psi]
# ( eta[i] is the maple variable ti )
# but the indices can be mixed and linsolve doesn't 
# always return the same result 
# We have to check the correspondance between t.sig(i)=[phi,theta,psi]
# and to change SS to have a good corespondance 
#-------------------------------------------------------------------------
knsize:=3;
permut:={seq(SS[i+3,1]=t_s[i],i=1..knsize)}:
SS:=subs(permut,eval(SS)):
permut:={seq(t_s[i]=t[i],i=1..knsize)}:
SS:=subs(permut,eval(SS)):

S:= genmatrix(convert(convert(SS,vector),list),[seq( t[i],i=1..knsize)]):
sorties(`systeme.tex`,`$\\dot{q}=S(q)\\eta$ Kernel of $A(q)'$~:`,S):

#-----------------------------------------------------
# this multiplication eliminates the term A(q) lambda 
# in the Euler equations 
#-----------------------------------------------------

E1:=multiply(transpose(S),EE):

# sortiesM(`systeme.tex`,`$S(q)^T E$`,E1);

#-----------------------------------------------------
# since Aprim(q) dotq=0 
# .
# q= S(q) eta ; here  eta = [t1,t2]
#                                 ..
# we use this equation to compute q
# Warning : t1 and t2 are time dependent
#-----------------------------------------------------

qt  := [ seq (t[i]  ,i=1..knsize)]:
qtd := [ seq (td[i] ,i=1..knsize)]:
qtdd:= [ seq (tdd[i],i=1..knsize)]:

qqdd:=map((x,y,z,t)-> time_diff(x,y,z,t),eval(SS),
	[op(q),op(qt)],[op(qd),op(qtd)],[op(qdd),op(qtdd)]):

#-----------------------------------------------------
#       ..                       .
# using  q= d/dt [ S(q) eta] and q= S(q) eta 
# we can subsitute these expressions in E1
#-----------------------------------------------------

E2:=subs(seq(qdd[i]=qqdd[i,1],i=1..nops(qdd)),eval(E1)):
E3:=subs(seq(qd[i]=SS[i,1],i=1..nops(qd)),eval(E2)):

#-----------------------------------------------------
# The global system is now 
#             .
#  E3 = 0 and q= S(q) eta 
#-----------------------------------------------------

E3:=map((x)-> simplify(x),E3):

sortiesM(`systeme.tex`,
	`$S(q)^T E$ simplified with $\\dot{q}=S(q)\\eta $`,E3);

#------------------------------------------------------------------
# Trying to find canonical representation 
# for the simplified euler equations
#            .
# El= ME(q)  t + RE(q,t)
# we use CEuler with a little trick in the parameter call qt,qt,qtd
#------------------------------------------------------------------

XX1:=CEulerP(E3,qt,qt,qtd):

MM3:=map((i)->factor(combine(i,trig)),XX1[1]):
RR3:=map((i)->factor(combine(i,trig)),XX1[2]):

sortiesI(`systeme.tex`,`a cononical form $M(q)\\dot{t}+R(q,t)$`);
sorties(`systeme.tex`,`C:`,MM3);
sorties(`systeme.tex`,`R:`,RR3);

#-----------------------------------------------------
# FORTRAN GENERATION 
#-----------------------------------------------------

#-----------------------------------------------------
# First routine wheel(neq,t,z,zdot)
# z= [ A,dotA, X] ou A=[theta,phi,psi] X=x,y
#       |0  I  0  |
# zdot =|0  0  0  | + Y
#       |0 S1(q) 0|   ( S1 : 2-first rows of S)
# where Y solves M(q)Y + C(q)dotA^2 + R =0 
#-----------------------------------------------------
kn:=knsize:

fvar:= {theta= z[1],phi=z[2],psi=z[3],t[1]=z[4],
	t[2]=z[5],t[3]=z[6],x=z[7],y=z[8]}:
MM3F:=subs(fvar,eval(MM3)):

 # don't forget the minus sign 
RR3F:=map((x)-> -x ,subs(fvar,eval(RR3))):
SSF:=subs(fvar,eval(SS)):

flist:=[subroutinem,`wheel`,[`neq`,`t`,`z`,`zdot`],
           [
            [ declaref,`implicit double precision`,[`(t)`] ],
            [ parameterf,[`kn=` || kn]],
            [ declaref,doubleprecision,[`t,z(8),zdot(8),r,j(3),m`]],
            [ declaref,doubleprecision,[`me3s(kn,kn)`]],
            [ declaref,doubleprecision,[`const(kn,1),w(3*kn),rcond`]],
            [ declaref,integer,[`i,k,neq,ierr`]],
            [ declaref,`data g`,[`/ 9.81/`]],
            [ declaref,`data r`,[`/ 1.0/`] ],
            [ declaref,`data m`,[`/ 1.0/`] ],
            [ declaref,`data j`,[`/ 0.3,0.4,1.0/`] ],
            [ matrixm,`me3s`,MM3F ] ,
            [ matrixm,`const`,RR3F ] , 
	    [ dom , `i ` ,1,`kn `,1,[ equalf,`zdot(i)`,`z(i+kn)`]],
	    [commentf,` we must solve  M z =const `],
	    [ callf , `dlslv`,[`me3s,kn,kn,Const,kn,1,w, rcond,ierr,1`]],
	    [ if_then_m,ierr<>0,[
		[writef,6,ff_w,[]],
		[formatf,ff_w,[`'Ill conditioned matrix!'`]]]],
	    [ dom , `i ` ,1,`kn `,1,[ equalf,`zdot(kn+i)`,`const(i,1)`]],
	    [ equalf, zdot(7),SSF[1,1]],
	    [ equalf, zdot(8),SSF[2,1]],
	    [returnf]]]:


Gener(`wheel.f`,flist):

#-----------------------------------------------------
# second routine wheelg(n,k,uf,vf,wf,xx)
# n,k integer 
# uf,vf,wf ==> matrices of size (n,k)
# xx solution of ode => matrix of size(8,k)
# This routines will computes the coordinates of trajectories of n-points 
# in the (x,y,z) space , givent their trajectories in the (u,v,w) space 
# xx(:,t) gives is the evolution of the wheel 
# uf,vf,wf : on entry the coordinates in the (u,v,w) space 
# uf,vf,wf : on output the coordinates in the (x,y,z) space 
#-----------------------------------------------------

ffvar:= {theta= xx[1,i2],phi=xx[2,i2],psi=xx[3,i2],t[1]=xx[4,i2],
	t[2]=xx[5,i2],t[3]=xx[6,i2],x=xx[7,i2],y=xx[8,i2],

	uf = uf[i1,i2],vf = vf[i1,i2] ,wf= wf[i1,i2] }:


Z:=multiply(R,vector([uf,vf,wf])):
Z:=matadd(vector([x,y,r*sin(phi)]),Z,1,r):
ZF:=subs(ffvar,eval(Z)):

fffvar:={ cos(xx[1,i2])=cs1,cos(xx[2,i2])=cs2,sin(xx[1,i2])=si1,sin(xx[2,i2])=si2}:
ZF:=subs(fffvar,eval(ZF)):

flist:=[subroutinem,`wheelg`,[`n,k,uf,vf,wf,xx`],
           [
            [ declaref,`implicit double precision`,[`(t)`] ],
            [ declaref,doubleprecision,[`uf(n,k),vf(n,k),wf(n,k)`]],
            [ declaref,doubleprecision,[`uu,vv,ww,r`]],
            [ declaref,integer,[`n,k,i1,i2`]],
            [ declaref,doubleprecision,[`xx(8,k)`]],
            [ declaref,`data r`,[`/ 1.0/`] ],
	    [ dom , `i1 ` ,1,`n `,1,[
		[ dom , `i2 ` ,1,`k `,1,
			[
			 op(map((x)-> [ equalf,rhs(x),lhs(x) ],fffvar)),
			 [ equalf,`uu`,ZF[1]],
			 [ equalf,`vv`,ZF[2]],
			 [ equalf,`ww`,ZF[3]],
			 [ equalf,`uf(i1,i2)`,`uu`],
			 [ equalf,`vf(i1,i2)`,`vv`],
			 [ equalf,`wf(i1,i2)`,`ww`]]]]],
	    [returnf]]]:


Gener(`wheelg.f`,flist):





