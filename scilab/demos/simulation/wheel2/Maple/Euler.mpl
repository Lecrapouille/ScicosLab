# Copyright ENPC (2018) Jean-Philippe Chancelier 
# with(share):
# Works with Maple7

read(`macrofort.mpl`);
use_mtex := true;

if use_mtex then 
   read(`tex.mpl`);
fi:

#----------------------------------------------------------------------------
#     GENERAL PART
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# Notation for Tex output 
# and TeX output routines
# this routines generates proper derivative notations up to second derivative
# for a set of variable. The TeX name for the variables is also given
# Warning this function will detroy previous values of texsub 
# Ex : addnotations( { x = `x`  , th = `\\theta`, y =`y` } );
#-----------------------------------------------------------------------------

addnotations:=proc(varlist)
	global texsub;
	local x,nots:
	nots:={};
	for x in varlist do
		nots:={op(nots),x, 
			cat(lhs(x),`d`)=cat(`\\dot{`,rhs(x),`}`),
			cat(lhs(x),`dd`)=cat(`\\ddot{`,rhs(x),`}`)}
	od;
	texsub:=nots
end:

sortieinit:=proc(filename)
	writeto(filename);
	writeto(terminal);
end:

if use_mtex then 

 # use mtex for tex output 
 # -----------------------
 sorties:=proc(filename,comment,exp)
	appendto(filename);
	printf("\\paragraph{%s} \n",comment);
	mtex(exp,latex);
	writeto(terminal);
end:

sortiesI:=proc(filename,comment)
	appendto(filename);
	printf("%s\n",comment);
	writeto(terminal);
end:

sortiesM1:=proc(filename,expr)
	appendto(filename);
	printf("\n");
	mtex(expr,latex);
 end:
 
 sortiesM:=proc(filename,comment,expr)
	appendto(filename);
	printf("\\paragraph{%s} \n\n",comment);
	map(x -> sortiesM1(filename,x),expr);
	writeto(terminal);
 end:

else 
 # use latex command for tex output 
 # -----------------------

 sorties:=proc(filename,comment,exp)
	appendto(filename);
	printf("\\paragraph{%s} \n \\[\n",comment);
	latex(exp,filename,'append');
	appendto(filename);
	printf(" \\]\n");
	writeto(terminal);
 end:

 sortiesI:=proc(filename,comment)
	appendto(filename);
	printf("%s\n",comment);
	writeto(terminal);
 end:

 sortiesM1:=proc(filename,expr)
	appendto(filename);
	printf("\n \\[\n",comment);
	latex(expr,filename,'append');
	appendto(filename);
	printf(" \\]\n");
	writeto(terminal);
 end:

 sortiesM:=proc(filename,comment,expr)
	appendto(filename);
	printf("\\paragraph{%s} \n",comment);
	map(x -> sortiesM1(filename,x),expr);
	writeto(terminal);
 end:
end:



texwid:=120;
sortieinit(`systeme.tex`);

#---------------------------------------------------------------
# functions for computing euler equations 
# L : the Lagrangian,
# q,qd,qdd are the state vector and its derivatives
#---------------------------------------------------------------

with(`linalg`):

euler_equations:=proc(L,q,qd,qdd)
 	local k,m,i,v:
	m:=nops(q);
	v:=matrix(m,1,0);
	for i to m  do  
           v[i,1]:=LL(q[i])=simplify(time_diff(diff(L,qd[i]),q,qd,qdd)
				-diff(L,q[i]));
	od;
	eval(v):
	end:

#---------------------------------------------------------------
# Time derivative computation of an expression 
# depending on q,qd,qdd 
# used to compute Euler equations 
#---------------------------------------------------------------

ttvar:=proc(xx)
	if type(xx,`indexed`) 
	then cat(op(0,xx),`d`)[op(xx)]
	else cat(xx,`d`) fi
end:

time_diff:=proc(phi,q,qd,qdd)
	local phi_copy,k,diff_phi:
	# subtitution to specify that q,qd ,qdd depends on time 
	phi_copy:=phi:
	phi_copy:=subs(map( xx-> xx=xx(t),[op(q),op(qd)]),phi_copy):
	diff_phi:=diff(phi_copy,t):
	# subtitution to come back to our variables 
	diff_phi:=subs(map(xx->diff(xx(t),t)=ttvar(xx),[op(q),op(qd)]),
			diff_phi):
	diff_phi:=subs(map(xx->xx(t)=xx,[op(q),op(qd),op(qdd)]),diff_phi):
end:


#-----------------------------------------------------
# Rewritting the Euler equations to have a canonical form 
#           ..         .
# El= ME(q)  q + CE(q) q^2 + RE(q)
# Computation of ME,CE,RE 
# CEuler returns a list [ME,CE,RE];
#-----------------------------------------------------

CEuler:=proc(E,q,qd,qdd)
	local Me,Ce,Re:
	Me:=MME(E,q,qd,qdd):
	Ce:=CCE(E,q,qd,qdd):
	Re:=RRE(E,Me,Ce,q,qd,qdd):
	[eval(Me),eval(Ce),eval(Re)]:
	end:


#-----------------------------------------------------
# Rewritting the Euler equations to have a canonical form 
#           ..      .
# El= ME(q)  q + RE(q,q)
# Computation of ME,RE 
# CEulerP returns a list [ME,RE];
#-----------------------------------------------------

CEulerP:=proc(E,q,qd,qdd)
	local Me,Ce,Re:
	Me:=MME(E,q,qd,qdd):
	Ce:=matrix(nops(q),nops(q),0):
	Re:=RRE(E,Me,Ce,q,qd,qdd):
	[eval(Me),eval(Re)]:
	end:

MME:=proc(E,q,qd,qdd)
	local E1:
	E1:=eval(E):
	genmatrix([seq(E1[i,1],i=1..nops(qdd))],qdd):
	end:

#-----------------------------------------------------
# extract the CE(q) matrix  El= ME(q)  qdd + CE(q) qd^2 + RE(q)
#-----------------------------------------------------

ttvarp:=proc(xx)
	if type(xx,`indexed`) 
	then cat(op(0,xx),`2`)[op(xx)]
	else cat(xx,`2`) fi
end:

CCE:=proc(E,q,qd,qdd)
 	local E_copy,q2d:
	E_copy:=eval(E):
	q2d:= map(x-> ttvarp(x),qd): 
	E_copy:=subs( map(x-> x**2=ttvarp(x),qd),eval(E_copy));
	genmatrix([seq(E_copy[i,1],i=1..nops(qd))],q2d);
	end:

#-----------------------------------------------------
# extract the RE(q) matrix  El= ME(q)  qdd + CE(q) qd^2 + RE(q)
#-----------------------------------------------------

RRE:=proc(E,ME,CE,q,qd,qdd)
	local MM:
	MM:=matadd(	E,
		matadd(multiply(ME,matrix(nops(q),1,qdd)),
	     	multiply(CE,matrix(nops(q),1,map(x->x**2,qd)))),
		1,-1);
	MM:=map((x)-> simplify(x),eval(MM)):
	end:

#
#-----------------------------------------------------
# FORTRAN GENERATION 
#-----------------------------------------------------

Gener:=proc(filename,flist)
	global optimized ;
	init_genfor();
	optimized:=true:
	writeto(filename):
	genfor(flist):
	writeto(terminal):
	end:

