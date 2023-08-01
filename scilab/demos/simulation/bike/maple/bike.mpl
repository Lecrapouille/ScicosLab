# updated for Maple7 (2018)
# code extracted from
# Dirk von Wissel Thesis
#

read(`macrofort.mpl`);
read(`maple2scilab.mpl`);
with(`linalg`);

eulerp:=proc(kin,pot)
global M,F,Uq:
local s1,s2:
    s1:=grad(kin,qd):
    M:=evalm(jacobian(s1,qd)):
    s2:=jacobian(s1,q):
    F:=evalm(s2-1/2*transpose(s2)):
    Uq:=evalm(-grad(pot,q)):
    print(`Done`);
end:

vectstackold:=proc() local i:
#stacks an arbitrary number of vectors to one large vector
    convert(stack[new](seq(convert(args[i],matrix),i=1..nargs)),
            vector):
end:

vectstack:=proc() local i:
#stacks an arbitrary number of vectors to one large vector
    convert( [ seq(op(convert(args[i],list)),i=1..nargs)],vector):
end:

d_dt:=proc(f)
    eval(innerprod(grad(f,q),qd)+innerprod(grad(f,qd),qdd)):
end:

suss:=proc(a,b) subs(b,a): end:

p_make1:=proc(qq)
###########################################################
#creates the lists s_q, s_dq, s_ddq of distinct parameters
#and defines generalized coordinates q, qd, qdd(see p_make2)
###########################################################
global eq,s_q,s_dq,s_ddq,nv,q,qd,qdd:
local i,l,k,dqq,ddqq:
    s_q:=matrix(1,1,[x11]):
    eq:=NULL:
    dqq:=vector(nb):
    ddqq:=vector(nb):
    for k from 1 to nb do
        dqq[k]:=vector([seq(cat(d,qq[k][i]),i=1..vectdim(qq[k]))]):
        ddqq[k]:=vector([seq(cat(dd,qq[k][i]),i=1..vectdim(qq[k]))]):
        for l from 1 to vectdim(qq[k]) do
            if not(member(qq[k][l],convert(s_q,set))) then
                s_q:=extend(s_q,0,1,qq[k][l]):
            fi:
            if l > 3 and qq[k][l] <> cat(p || k,eval(l-3)) then
                eq:=eq,cat(p || k,eval(l-3))=qq[k][l],
                cat(dp || k,eval(l-3))=cat(d,qq[k][l]),
                cat(ddp || k,eval(l-3))=cat(dd,qq[k][l]):
            elif l <= 3 and qq[k][l] <> x || k || l then
                eq:=eq,x || k || l=qq[k][l],
                dx || k || l=cat(d,qq[k][l]),
                ddx || k || l=cat(dd,qq[k][l]):
            fi:
        od:
    od:
#number of variables
    s_q:=convert(s_q,vector):
    nv:=vectdim(s_q):
    q:=vector(nv):
    qd:=vector(nv):
    qdd:=vector(nv):
    s_dq:=vector([seq(cat(d,s_q[i]),i=1..nv)]):
    s_ddq:=vector([seq(cat(dd,s_q[i]),i=1..nv)]):
end:
p_make2:=proc(Ka,Ua,Ke,f,g)
global p_eq,p_Ka,p_Ua,p_f,p_g,p_Ke,param:
local i,np:
##########################################################
#Replace natural parameters and variables by generalized
#coordinates and all parameters by param[i]
##########################################################
#number of parameters
    np:=vectdim(s_param):
    param:=vector(np):
    p_eq:=seq(s_q[i]=q[i],i=1..nv),
    seq(s_dq[i]=qd[i],i=1..nv),
    seq(s_ddq[i]=qdd[i],i=1..nv),
    seq(s_param[i]=param[i],i=1..np):
    p_Ka:=subs(eq,p_eq,Ka):
    p_Ua:=subs(eq,p_eq,Ua):
    p_f:=map(suss,map(suss,f,{eq}),{p_eq}):
    p_g:=map(suss,map(suss,g,{eq}),{p_eq}):
    p_Ke:=map(suss,map(suss,Ke,{eq}),{p_eq}):
end:

##############Model Definition for the bicycle###########################
#-number of bodies
nb:= 5:
#preliminary definitions and procedures
qq:=vector(nb):
#PARAMETRIZATION:
#################
#Declaration of variables
###############
#1-center of mass of the rear wheel + Euler angles
qq[1]:=vector([x11,x12,x13,p11,p12,p13]):
#2-center of mass of the frame + Euler angles
qq[2]:=vector([x21,x22,x23,p11,p12,p23]):
#3-center of mass of the fork + Euler angles
qq[3]:=vector([x31,x32,x33,p51,p52,p33]):
#4-lower left point of the front projection + Euler angles
qq[4]:=vector([x41,x42,x43,p51,p52,p33]):
#5-center of mass of the front wheel
qq[5]:=vector([x51,x52,x53,p51,p52,p53]):
#Define q,qd,qdd and dqq=d/dt qq , ddqq=d/dt dqq ,
p_make1(qq,q,qd):

#Name composition for constants:
###############################
# I.. : Moment of Inertia ,
# m.. : Mass
# ..rw.. : rear wheel
# ..fr.. :front whell
# ..fp.. :front projection
# ..n : normal direction
# ..r : radial direction
#Declaration of used parameters
s_param:=vector([Irwn,Irwr,mrw,Ifwn,Ifwr,mfw,rw,Ifrn,Ifrr,mfr,Ifon,Ifor,mfo,
                 Ifpr,Ifpn,mfp,l1,l2,l3,l4,l5,l6,g]):
#Moments of Inertia
J:=vector(nb):
J[1]:=diag(Irwn,Irwn,Irwr):
J[5]:=diag(Ifwn,Ifwn,Ifwr):
J[2]:=diag(Ifrr,Ifrn,Ifrn):
J[3]:=diag(Ifor,Ifon,Ifon):
J[4]:=diag(Ifpr,Ifpn,Ifpn):

#Masses
m:=vector([mrw,mfr,mfo,mfp,mfw]):

#Direct cosine matrices
############################
Az:=proc(phi) matrix(3,3,[[cos(phi),sin(phi),0],
                          [-sin(phi),cos(phi),0],
                          [0,0,1]]):end:
Ax:=proc(phi) matrix(3,3,[[1,0,0],
                          [0,cos(phi),sin(phi)],
                          [0,-sin(phi),cos(phi)]]):end:
Ay:=proc(phi) matrix(3,3, [[cos(phi),0,-sin(phi)],
                           [0,1,0],
                           [sin(phi),0,cos(phi)]]):end:
#Angular velocities
###################
omega_i:=proc(i) local s1,s2:
#Angular velocity of body i with respect to body fixed basis
    s1:=evalm(Az(p || i || 1)&*vector([0,0,dp || i || 1])):
    s2:=evalm(Ax(p || i || 2)&*(vector([dp || i || 2,0,0])+s1)):
    evalm(Az(p || i || 3)&*(vector([0,0,dp || i || 3])+s2)):
end:
omega_0:=proc(i) local s1,s2:
#Angular velocity of body i with respect to inertial frame
    s1:=evalm(transpose(Az(p || i || 3))&*vector([0,0,dp || i || 3])):
    s2:=evalm(transpose(Ax(p || i || 2))&*(vector([dp || i || 2,0,0])+s1)):
    evalm(transpose(Az(p || i || 1))&*(vector([0,0,dp || i || 1])+s2)):
end:
wi:=array([seq(omega_i(i),i=1..nb)]):
#Vectors to body fixed frames (r[i]) and its linear velocities(v[i])
#####################################################################
r:=array([seq(vector([seq(qq[i][j],j=1..3)]),i=1..nb)]):
v:=array([seq(vector([seq(cat(d,qq[i][j]),j=1..3)]),i=1..nb)]):
#Kinetic energies of the individual bodies
###########################################
#Rotational part
Tr:=array([seq(1/2*evalm(transpose(wi[i])&*J[i]&*wi[i]),i=1..nb)]):

trig_simp:=proc(expr)
    simplify(expr,trig):
end:

Tr:=map(trig_simp,Tr):
#Linear part
Tl:=array([seq(1/2*m[i]*evalm(transpose(v[i])&*v[i]),i=1..nb)]):
#Lagrangian
Ki:=vector([seq(Tr[i]+Tl[i],i=1..nb)]):
Ui:=vector([seq(m[i]*g*qq[i][3],i=1..nb)]):
# Li:=evalm(Ki-Ui):
Ka:=sum('Ki[i]','i'=1..nb):
Ua:=sum('Ui[i]','i'=1..nb):
La:=eval(Ka-Ua):

#Control: Vector of external forces
####################################
#number of controls
nu:= 2:
Ke:=vector(nv,0):
u:=vector(nu):
c:=sin(p52)*sin(p12)*cos(p11-p51)+cos(p52)*cos(p12):
Ke[4]:=eval(-u[1]*sin(p12)*cos(p11-p51)/c):
Ke[5]:=eval(-u[1]*cos(p12)*sin(p11-p51)/c):
Ke[6]:=u[2]:
Ke[14]:=eval(u[1]*sin(p12)*cos(p11-p51)/c):
Ke[16]:=eval(u[1]*cos(p33)*sin(p12)*sin(p11-p51)/c/sin(p33)):
#Constraints
###################
#2-nonholonomic constraints
###########################
#Radius vector of rear wheel
rav1_0:=evalm(transpose(Az(p11))&*transpose(Ax(p12))&*vector([0,-rw,0])):
#Radius vector of front wheel
rav5_0:=evalm(transpose(Az(p51))&*transpose(Ax(p52))&*vector([0,-rw,0])):
g1:=map(simplify,evalm(v[1]+
                       crossprod(omega_0(1),rav1_0)),trig):
g2:=map(simplify,evalm(v[5]+
                       crossprod(omega_0(5),rav5_0)),trig):
g:=vector([g1[1],g1[2],g2[1],g2[2]]):
a_2:=vector([-l2,0,0]):
b_4:=vector([l3,0,0]):
c_4:=vector([0,-l6,0]):
n_1:=vector([0,0,1]):
f1:=evalm(r[1]-r[2]-
          transpose(Az(p11))&*transpose(Ax(p12))&*transpose(Az(p23))&*a_2):
f2:=evalm(r[3]-r[4]-
          transpose(Az(p51))&*transpose(Ax(p52))&*transpose(Az(p33))&*b_4):
f3:=evalm(r[5]-r[4]-
          transpose(Az(p51))&*transpose(Ax(p52))&*transpose(Az(p33))&*c_4):

f4:=vector([sum('(evalm(r[1]-r[4])[i])^2','i'=1..3)-l1^2]):
f5:=evalm((r[1]-r[4])-
          (l4/l2*(r[1]-r[2])+l5/l3*(r[3]-r[4]))):
f6:=vector([
    dotprod(
        evalm(transpose(Az(p11))&*transpose(Ax(p12))&*n_1),
        evalm(transpose(Az(p51))&*transpose(Ax(p52))&*transpose(Az(p33))&*b_4),
	'orthogonal'
           )]):
f7:=vector([x13-rw*sin(p12)]):# primitive of g1[3]
f8:=vector([x53-rw*sin(p52)]):# primitive of g2[3]
f:=vectstack(f1,f2,f3,f4,f5,f6,f7,f8):
#Number of constraints
nc:=vectdim(f)+vectdim(g):
#Replace natural parameters by generalized coordinates
printf(`enter p_make2`):

p_make2(Ka,Ua,Ke,f,g,qq):
print(`p_make2 done`):
eulerp(p_Ka,p_Ua):
print(`Euler done`):

mkmodel:=proc(M,F,Uq,Ke,f,g,q,qd)
global EE,A,fg_x,fg:
local fq,fqqdq,ffqq,G,xd,xxd,lam:
fq:=jacobian(convert(f,vector),q):
fqqdq:=jacobian(evalm(fq&*qd),q):
ffqq:=evalm(fqqdq+ b1*fq):
G:=jacobian(convert(g,vector),qd):
fg:=vectstack(f,evalm(fq&*qd),g):
fg_x:=jacobian(fg,vectstack(q,qd)):
EE:=stackmatrix(augment(M,transpose(fq),transpose(G)),
                extend(fq,0,rowdim(fq)+rowdim(G),0),
                extend(G ,0,rowdim(fq)+rowdim(G),0)):
A:=convert(vectstack(
    evalm(-F&*qd+Uq+Ke),
    evalm(-ffqq&*qd-b0*f),
    evalm(-jacobian(convert(g,vector),q)&*qd-a0*g)),
           matrix):
end:

mkmodel(M,F,Uq,p_Ke,p_f,p_g,q,qd):

print(`model finished`):
############### writes associated fortran subroutines and SCILAB functions ###
#the fortran subroutines and scilab functions a written in rpath
maple2scilab('ee',EE,[q,qd,param],'f'):
maple2scilab('aa',A,[q,qd,u,param,b0,b1,a0],'f'):
maple2scilab('fg',fg,[q,qd,param],'f'):
maple2scilab('fg_x',fg_x,[q,qd,param],'f'):


