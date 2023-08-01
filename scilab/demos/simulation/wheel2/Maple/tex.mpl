#
## <SHAREFILE=system/tex/tex.mpl >
## <DESCRIBE>
##                For generating LaTeX, plain TeX and AMS TeX output.
##                Includes facilities for breaking up large expressions
##                (for sums and products and vectors but not quotients)
##                AUTHOR: Yunliang Yu, yu@math.duke.edu
##            (update)
##                Bug fix and automatic line-breaking of large quotients
##                and matrices.
##                AUTHOR: Yunliang Yu, yu@math.duke.edu
## </DESCRIBE>
## <UPDATE=R4update >

## Updated to work with Maple >= 7 
## Chancelier 2009.

##########################
# standard input
###
# Convert from 5.2 to Release 3
#@###########################################################################
#
# mtex:                      MAPLE ===> TeX
#      ___________________________________________________________________
#
#	     Copyright (c) 1993 by Yunliang Yu. All rights reserved.
#
#	This package may be freely distributed for non-profit purposes 
#	only. It may be modified as long as no modified version is
#	distributed and the copyright notice is retained. The author 
#	is not responsible for any damage caused by using this package.
#
#	This package is revised in Maple V release 2 and it requires maple 4.2 
#	or higher; the procedure "clct" does not work under maple 4.2 because 
#	of the definition of "collect" in maple.
#
#	Please send bug reports, comments and ideas to yu@math.duke.edu
#      ___________________________________________________________________
#
# Main Features:
# -------------
#	1). typesetting in AmS-TeX, LaTeX or Plain TeX,
#	2). automatic line-breaking,
#	3). multi-level sorting,
#	4). name and index substitutions.
#
# Deficiencies:
# ------------
#       1). general tables are not implemented yet
#
# Procedures Available:
# -------------------
#	The user-level procedures are: 
#		
#		mtex, stex, tex, rlms, clct, test
#
# For Help:
# --------
# 	See ?TeX, ?TeX[usage] and ?TeX[example].
#@###########################################################################

with(StringTools):

tex:=proc(e)
	global  tex_lt, tex_sp, tex_space;
	local sq,b,tmp,ee,aa,a,t0,t1,c, i,n, nm,sp,ct,ff:
	options `Copyright (c) 1991 by Yunliang Yu`;
	if nargs=0 then  RETURN(NULL) fi;
	sp:=tex_sp:
	ct:=tex_lt:
	nm:=NULL;
	if nargs>1 then
		b:=nargs:
		if args[b]=name then nm:=name: b:=b-1: fi:
		if b>1 then
			sq:=NULL:
			for i to b-1 do
				sq:=sq,tex(args[i],nm),`,\\,`:
				tex_lt:=tex_lt+1+2/3:
			od:
			sq:=sq,tex(args[b],nm):
			RETURN(sq):
		fi:
	fi:
	if type(e,table) and nm<>name then
		RETURN( tex_table(e) );
	elif type(e,name) then
		tex_sp:=NULL:
		ee:=subs(texsub,e):
		b:=NULL: a:=ee:
		if e=ee then
			do
				if not type('%',name) then
					a:=`?`: break:
				elif type('%',indexed) then
					if b<>NULL then b:=`;`,b: fi:
					ff:=[op(a)]: n:=nops(ff):
					if n<>0 then
						b:=tex( subs(texidx,ff[n]) ,nm),b:
						for i from n-1 by -1 to 1 do
							b:=tex( subs(texidx,ff[i]) ,nm),`\\,`,b:
						od:
						tex_lt:=tex_lt+(n-1)/3:
					fi:
					a:=op(0,a):
				else
					c:=length(a):
					for n from c by -1 to 1 do
						if member(substring(a,n..n),
				     	{`0`,`1`,`2`,`3`,`4`,`5`,`6`,`7`,`8`,`9`})
						then else break fi:
					od:
					if n=0 or c-n=0 then break:
					else
						i:=substring(a,n+1..c):
						i:=subs(texidx,i):
						c:=c-n:
						tex_lt:=tex_lt+c*1:
						if b<>NULL then
							b:=i,`;`,b: tex_lt:=tex_lt+1/3:
						else b:=i: fi:
						a:=substring(a,1..n):
					fi:
				fi:
			od:
			if b=NULL then
			else
				if nops([b])=1 and length(b)=1 then b:=`_`,b:
				else b:=`_{`,b,`}`: fi:
				tex_lt:=tex_lt-(tex_lt-ct)/3:
			fi:
			a:=subs(texsub,a):
		fi:
		if   a=infinity then sq:=`\\infty`,b: tex_lt:=tex_lt+1:
		elif a=Beta     then sq:=`\\beta`,b: tex_lt:=tex_lt+1:
		elif a=GAMMA    then sq:=`\\Gamma`,b: tex_lt:=tex_lt+1:
		elif a=Zeta     then sq:=`\\zeta`,b: tex_lt:=tex_lt+1:
		elif a=Pi       then sq:=`\\pi`,b: tex_lt:=tex_lt+1:
		elif a=E        then sq:=proc() local e;e end(),b: tex_lt:=tex_lt+1:
		elif member(a,tex_greek_) then
			sq:=sprintf("\\%A",a),b: tex_lt:=tex_lt+1:
		elif member(a,tex_math_func_) then
			sq:=sprintf("\\%A",a),b: tex_lt:=tex_lt+length(a):
		elif type(a,symbol) then
			sq:=a,b: tex_lt:=tex_lt+length(a):
		else
			sq:=`{`,tex(a,nm),`}`,b:
		fi:
	elif type(e,`^`) then
		a:=op(1,e): b:=op(2,e):
		tex_sp:=NULL:
		if   b= 1/2 then tex_lt:=tex_lt+3/2:
			sq:=`\\sqrt{`,tex(a,nm),`}`:
		elif b=-1/2 then tex_lt:=tex_lt+3/2:
			if tex_caller=plain then
				sq:=`{1\\over\\sqrt{`,tex(a,nm),`}}`:
			else sq:=`\\frac1{\\sqrt{`,tex(a,nm),`}}`: fi:
		elif type(b,integer) and b<0 then
			if tex_caller=plain then
				sq:=`{1\\over `,tex(a^(-b),nm),`}`:
			else sq:=`\\frac1{`,tex(a^(-b),nm),`}`: fi:
		elif type(b*t0,`*`) and numer(b*t0)=t0 then
			tmp:=tex(denom(b),nm):
			tex_lt:=tex_lt-(tex_lt-ct)*3/4 + 3/2:
			if tex_caller=latex then
				sq:=`\\sqrt[`,tmp,`]{`,tex(a,nm),`}`:
			else sq:=`\\root{`,tmp,`}\\of{`,tex(a,nm),`}`: fi:
		else
			tex_sp:=sp:
			if type(a,{`+`,`*`,`^`,fraction}) or (type(a,numeric) and a<0) then
				if tex_tall(a) then
					tex_lt:=tex_lt+4:
					sq:=tex_insert([tex(a,nm)],`\\left(`,`\\right)`,sp):
					tex_space:=0:
				else    tex_lt:=tex_lt+2:
					sq:=tex_prep([`(`],[tex(a,nm)],sp),`)`:
				fi:
			elif type(a,numeric) or type(a,function)
				or ( type(a,symbol) and
				not member(substring(a,length(a)..length(a)),
				{`0`,`1`,`2`,`3`,`4`,`5`,`6`,`7`,`8`,`9`}) ) then
				sq:=tex(a,nm):
			else
				sq:=tex_prep([`{`],[tex(a,nm)],sp),`}`:
			fi:
			if ( type(b,integer) and b>=0 and b<=9 ) or
			   ( type(b,symbol) and length(b)=1 ) then
				tmp:=`^`,b: tex_lt:=tex_lt+2/3:
			else
				tex_sp:=NULL: ct:=tex_lt:
				c:=tex(b,nm):
				tex_lt:=tex_lt-(tex_lt-ct)/3:
				tmp:=`^{`,c,`}`:
			fi:
			tex_sp:=sp:
			RETURN( sq,tmp ):
		fi:
	elif type(e,fraction) then
		b:=NULL: tmp:=e: if e<0 then b:=`-`: tmp:=-e: fi:
		ee:=op(1,tmp): aa:=op(2,tmp): a:=length(aa): c:=length(ee):
		if not tex_tall(tmp) then
			sq:=b,ee,`/`,aa:
			tex_lt:=tex_lt + a + 1 + c:
		else
			tex_lt:=tex_lt + max( a, c )*2/3:
			if tex_caller=plain then
				RETURN( b,`{`,ee,`\\over `,aa,`}` ):
			fi:
			if ee<10 then
				sq:=b,`\\frac`, ee, `{`,aa,`}`:
			else	sq:=b,`\\frac{`,ee,`}{`,aa,`}`: fi:
		fi:
	elif type(e,integer)  then
		if e=0 then tex_lt:=tex_lt+1: sq:=0:
		elif e>0 then tex_lt:=tex_lt+length(e): sq:=e:
		else tex_lt:=tex_lt+3/2+length(e): sq:=`-`,-e:fi:
	elif type(e,numeric) then
		c:=NULL: ee:=e: if e<0 then c:=`-`: ee:=-e: fi:
			a:=op(1,ee): b:=-op(2,ee):
			while type(a/10,integer) do
				a:=a/10: b:=b-1:
			od: a:=cat(``,a): i:=length(a):
 			if i>b then
				tmp:= cat("",(substring(a,1..i-b)),".",	(substring(a,i-b+1..i))):
			else	tmp:=cat("0.",(cat(`0`$(b-i))),a): fi:
		tex_lt:=tex_lt+length(tmp)-1/2:
		sq:=c,tmp:
	elif type(e,function) then
		a:=op(0,e):
		tex_sp:=NULL:
		# assigned(cat(`tex/`,a)) always return true 
		if type(a,symbol) and member( cat(`tex/`,a), {anames()}) then
			sq:=cat(`tex/`,a)(op(e));
		elif type(a,symbol) and member( cat(`latex/`,a), {anames()}) then
			sq:=cat(`latex/`,a)(op(e));
		else
			if tex_tall({op(e)}) then
				tex_lt:=tex_lt+4-1/3:
				b:=`\\!\\left(`,tex(op(e),nm),`\\right)`:
				tex_space:=2:
			else	tex_lt:=tex_lt+2:
				b:=`(`,tex(op(e),nm),`)`:
			fi:
			if member(a,tex_math_func_) or
				(type(a,symbol) and substring(a,1..1)=`&`) then
				sq:=sprintf("\\%A",a),b:
				tex_lt:=tex_lt+length(a):
			elif type(a,{`*`,`+`}) then
				sq:=`(`,tex(a,nm),`)`,b:
				tex_lt:=tex_lt+2;
			else	sq:=tex(a,nm),b: fi:
		fi:
	elif type(e,`*`) then
		tmp:=[op(e)]:
		a:=tmp[1]:
		b:=NULL: ee:=NULL: aa:=NULL:
		if type(a,numeric) then
			tmp:=subsop(1=NULL,tmp):
			if a<0 then
				if ct=0 and tex_caller<>latex then b:=`{-}`: else b:=`-`: fi:
				tex_lt:=tex_lt+3/2: a:=-a:
			fi:
		else	a:=1: fi:
		for i in tmp do
			if type(i,`^`) and type(op(2,i),numeric) and
				op(2,i)<0 then aa:=aa,1/i:
			else	ee:=ee,i: fi:
		od:
		ee:=tex_sort([ee],1): aa:=tex_sort([aa],1):
		tex_sp:=NULL:
		if ee=[] then
			if type(a,fraction) then
				ee:=[op(1,a),op(ee)]:
				aa:=[op(2,a),op(aa)]:
			else
				ee:=[a,op(ee)]:
			fi:
		elif type(a,fraction) and op(1,a)=1 then
			aa:=[op(2,a),op(aa)]:
		elif a<>1 then
			b:=tex_prep([b],[tex(a,nm)],sp),`\\,`:
			tex_lt:=tex_lt+2/3:
		fi:
		if aa=[] then
			tex_sp:=sp: RETURN( tex_prep([b],[tex_pdt(ee,0,nm)],sp) ):
		fi:
		t0:=tex_lt:
		ff:=tex_pdt(ee,0,nm):
		t1:=tex_lt:
		tex_lt:=t0:
		tmp:=tex_pdt(aa,0,nm): tex_sp:=sp:
		tex_lt:= t0+max(t1-t0,tex_lt-t0):
		if sp=NULL or tex_lt < texwid then
			if tex_caller=plain then
				sq:=b,`{`,ff,`\\over `,tmp,`}`:
			else	sq:=b,`\\frac{`,ff,`}{`,tmp,`}`: fi:
		else
			tex_lt:=t0:
			sq:=tex_prep([b],[tex_pdt(ee,1,nm)],sp):
			tex_lt:=tex_lt+3:
			sq:=sq,tex_pdt(aa,`/`,nm):
		fi:	RETURN(sq);
	elif type(e,`+`) then
		sq:=NULL: b:=tex_sort([op(e)]):
		c:=nops(b):
		for i to c do	a:=1:
			if type(b[i],{numeric,`*`}) then a:=op(1,b[i]): fi:
			if i=1 then
				ee:=[tex(b[i],nm)]:
				ee:=op(ee):
			elif type(a,numeric) and a<0 then
				tex_lt:=tex_lt+3:
				ee:=tex_prep([`-`],[tex(-b[i],nm)],sp):
			else
				tex_lt:=tex_lt+3:
				ee:=tex_prep([`+`],[tex(b[i],nm)],sp):
			fi:
			sq:=sq,ee:
		od:
		RETURN(sq);
	elif type(e,set) then
		tmp:=tex_sort([op(e)]):
		if tex_tall(e) then
			tex_lt:=tex_lt+5:
			sq:=tex_insert([tex(op(tmp),nm)],`\\left\\{\\,`,`\\,\\right\\}`,sp):
		else	tex_lt:=tex_lt+3:
			sq:=tex_prep([`\\{\\,`],[tex(op(e),nm)],sp),`\\,\\}`:
		fi:	RETURN(sq);
	elif type(e,list) then
		if tex_tall(e) then
			tex_lt:=tex_lt+4:
			sq:=tex_insert([tex(op(e),nm)],`\\left[\\,`,`\\,\\right]`,sp):
		else	tex_lt:=tex_lt+2:
			sq:=tex_prep([`[\\,`],[tex(op(e),nm)],sp),`\\,]`:
		fi:	RETURN(sq);
	elif type(e,relation) then
		if   whattype(e) = `<=` then ee:=`\\leq `:
		elif whattype(e) = `>=` then ee:=`\\geq `:
		elif whattype(e) = `<>` then
			if tex_caller=plain then ee:=`\\not= `:
			else ee:=`\\neq `: fi:
		else	ee:=whattype( e ): fi:
		sq:=tex(op(1,e)): tex_lt:=tex_lt+3:
		sq:=sq,tex_prep([ee],[tex(op(2,e))],sp): RETURN(sq);
	elif type(e,{taylor,series}) then
		sq:=tex( convert(e,`+`) ,nm):  RETURN(sq);
	elif type(e,range) then
		tex_lt:=tex_lt+3:
		sq:=tex(op(1,e),nm),`\\ldots `,tex(op(2,e),nm): RETURN(sq);
	else	ERROR(`case hasn't defined yet.`):
	fi:
	if sp<>NULL and tex_lt>texwid and ct>0 then
		sq:=sp,sq: tex_lt:=3+(tex_lt-ct):
	fi:
	tex_sp:=sp: RETURN( sq  ):
end:
tex_pdt:=proc(ee,qt)
	global  tex_lt, tex_space;
	local sq,n,i,s,t,sp,l,tall,nm:
	options `Copyright (c) 1991 by Yunliang Yu`;
	if ee=[] then
		if qt=0 then RETURN( tex(1) ): else RETURN(NULL): fi:
	fi:
	tall:=0: if nargs<3 then nm:=NULL: else nm:=args[3]: fi:
	sq:=NULL: n:=nops(ee): sp:=tex_sp:
	for i to n do s:=ee[i]:
		if n>1 and type(s,`+`) then
			tex_lt:=tex_lt+2:
			if tex_tall(s) then
				sq:=sq,tex_insert([tex(s,nm)],`\\left(`,`\\right)`,sp):
				tex_lt:=tex_lt+2:
				tex_space:=0: tall:=1:
			else
				l:=[tex(s,nm)]:
				if sp<>NULL and l[1]=sp then
					sq:=sq,l[1],`(`,op(l[2..nops(l)]),`)`:
				elif tex_space=1 and i>1 then
					sq:=sq,`\\,`,`(`,op(l),`)`:
					tex_lt:=tex_lt+1/3:
				else	sq:=sq,`(`,op(l),`)`: fi:
				tex_lt:=tex_lt+2:
				tex_space:=1:
			fi:
		else
			if tex_tall(s) then tall:=1: fi:
			t:=tex_space: tex_space:=1:
			if t=1 and tex_space<>0 and i>1 then
				tex_lt:=tex_lt+1/3:
				sq:=sq,`\\,`,tex(s,nm):
			else	sq:=sq,tex(s,nm): fi:
		fi:
	od:
	if qt=0 then RETURN( sq ):
	elif sp=NULL then
		if tall=1 then tex_lt:=tex_lt+4: RETURN( `\\left(`, sq, `\\right)` ):
		else tex_lt:=tex_lt+2: RETURN( `(`, sq, `)`): fi:
	fi:
	sq:=[sq]:
	if qt=1 then s:=NULL:
	elif tall=1 then s:=cat(`\\Big`,qt):
	else s:=cat(`\\big`,qt): fi:
	if sq[1]=sp then
		s:=s,sq[1]:
		sq:=sq[2..nops(sq)]:
	fi:
	if (n=1 and type(ee[1],`+`)) or (n>1 and qt<>1) then
		if tall=1 then tex_lt:=tex_lt+4: sq:=[`\\left(`,op(sq),`\\right)`]:
		else tex_lt:=tex_lt+2: RETURN( s,`(`,op(sq),`)` ): fi:
		if not member(sp,sq,'l') then RETURN( s,op(sq) ): fi:
		n:=nops(sq): sq:=[op(sq[1..l-1]),`\\right.`,op(sq[l..n])]:
		for i from n by -1 to l+1 do
			if sq[i]=sp then
				sq:=[op(sq[1..i]),`\\left.{}`,op(sq[i+1..n+1])]:
				break:
			fi:
		od:
	fi:
	RETURN(s,op(sq)):
end:
tex_table:=proc(e)
		global  tex_lt, tex_sp, texwid;
		local sp,wid,tmp,m0,m1,n0,n1,i,j,sq,lt,sp0,cf,len,len0,nl,sq0,tx,c;
		options `Copyright (c) 1994 by Yunliang Yu`;
		sp:=tex_sp;
		if type(e,array) then
			if not type(e,name) then tmp:=[op(2,e)]:
			else tmp:=[op(2,eval(e))]: fi:
			if   tmp=[] then tex_lt:=tex_lt+2; RETURN(`(`,`) `):
			elif nops(tmp)=1 then
				m0:=NULL:
				n0:=op(1,tmp[1]): n1:=op(2,tmp[1]):
			elif nops(tmp)=2 then
				m0:=op(1,tmp[1]): m1:=op(2,tmp[1]):
				n0:=op(1,tmp[2]): n1:=op(2,tmp[2]):
			else
				ERROR(`cannot format arrays of dimension > 2`);
			fi:
		else	tmp:={indices(e)}:
			if not type(tmp,{set([integer]),set([integer,integer])})
			then ERROR(`unable to format table`) fi;
			if   tmp={} then tex_lt:=tex_lt+2; RETURN(`(`,`) `):
			elif nops(tmp[1])=1 then
				m0:=NULL:
				tmp:=op(map(proc(x) op(x) end,tmp)):
				n0:=min(tmp): n1:=max(tmp):
				if n0=n1 then n0:=1: fi:
			else
				m1:=seq(j[1],j=tmp); m0:=min(m1): m1:=max(m1):
				n1:=seq(j[2],j=tmp); n0:=min(n1): n1:=max(n1):
			fi:
		fi:
		lt:=(n1-n0)*2:
		if sp<>NULL and tex_lt>texwid-lt-4 then
			sq:=sp: lt:=lt+4:
		else
			sq:=NULL: lt:=tex_lt+lt+4:
		fi:
		if   tex_caller=amstex then
			sq:=sq,`\\pmatrix `:
		elif tex_caller=latex then
			sq:=sq,cat(`\\left(\\begin{array}{`,(cat('c'$(n1-n0+1))),`} `):
		else	sq:=sq,`\\pmatrix{ `: fi:
		if tex_caller<>amstex then nl:=` \\cr ` else nl:=` \\\\ ` fi:
		sq0:=sq:
		tex_sp:=NULL:
		len:=table(sparse);
		if m0=NULL then
			for j from n0 to n1-1 do
				tex_lt:=0: tx[j]:=tex(e[j],name):
				sq:=sq,tx[j],` & `: len[j]:=tex_lt:
			od:
			tex_lt:=0: tx[n1]:=tex(e[n1],name):
			sq:=sq,tx[n1]: len[n1]:=tex_lt:
		else
			for i from m0 to m1 do
				for j from n0 to n1-1 do
					tex_lt:=0: tx[i,j]:=tex(e[i,j],name):
					sq:=sq,tx[i,j],` & `:
					if tex_lt>len[j] then len[j]:=tex_lt: fi:
				od:
				tex_lt:=0: tx[i,n1]:=tex(e[i,n1],name):
				sq:=sq,tx[i,n1]:
				if i<m1 then sq:=sq,nl: fi:
				if tex_lt>len[n1] then len[n1]:=tex_lt: fi:
			od:
		fi:
		len0:=convert([seq(len[j],j=n0..n1)],`+`);
		if sp<>NULL then
			sq:=sq0: wid:=texwid:
			cf:=(texwid-lt)/len0:
			tex_sp:=`$}\\hbox{$\\;{}`: sp0:=tex_sp:
			if m0=NULL then
				for j from n0 to n1-1 do
					texwid:=len[j]*cf:
					if len[j]<=texwid then tmp:=tx[j]:
					else tex_lt:=0: tmp:=tex(e[j],name): fi:
					if member(sp0,[tmp]) then
						sq:=sq,` \\vtop{\\hbox{${}`,tmp,`$}\\medskip} `,` & `:
					else
						sq:=sq,tmp,` & `:
					fi:
				od:
				texwid:=len[n1]*cf:
				if len[n1]<=texwid then tmp:=tx[n1]:
				else tex_lt:=0: tmp:=tex(e[n1],name): fi:
				if member(sp0,[tmp]) then
					sq:=sq,` \\vtop{\\hbox{${}`,tmp,`$}\\medskip} `:
				else
					sq:=sq,tmp:
				fi:
			else
				for i from m0 to m1 do
					for j from n0 to n1-1 do
						texwid:=len[j]*cf:
						if len[j]<=texwid then tmp:=tx[i,j]:
						else tex_lt:=0: tmp:=tex(e[i,j],name): fi:
						if member(sp0,[tmp]) then
							sq:=sq,` \\vtop{\\hbox{${}`,tmp,`$}\\medskip} `,` & `:
						else
							sq:=sq,tmp,` & `:
						fi:
					od:
					texwid:=len[n1]*cf:
					if len[n1]<=texwid then tmp:=tx[i,n1]:
					else tex_lt:=0: tmp:=tex(e[i,n1],name): fi:
					if member(sp0,[tmp]) then
						sq:=sq,` \\vtop{\\hbox{${}`,tmp,`$}\\medskip} `:
					else
						sq:=sq,tmp:
					fi:
					if i<m1 then sq:=sq,nl: fi:
				od:
			fi:
			texwid:=wid:
		fi:
		tex_lt:=lt+min(len0,texwid-lt):
		if   tex_caller=amstex then
			sq:=sq,` \\endpmatrix `:
		elif tex_caller=latex then
			sq:=sq,` \\end{array} \\right)`:
		else	sq:=sq,` \\cr} `: fi:
		tex_sp:=sp: RETURN(sq);
end:
tex_insert:=proc(ee,st,ed,sp)
	local sq,s,l,n,i:
	options `Copyright (c) 1994 by Yunliang Yu`;
	if nargs<4 then RETURN(st,op(ee),ed) fi:
	sq:=ee: s:=NULL:
	if sq[1]=sp then s:=sq[1]: sq:=sq[2..nops(sq)]: fi:
	if not member(sp,sq,'l') then RETURN( s,st,op(sq),ed ): fi:
	n:=nops(sq): sq:=[op(sq[1..l-1]),`\\right.`,op(sq[l..n])]:
	for i from n by -1 to l+1 do
		if sq[i]=sp then
			sq:=[op(sq[1..i]),`\\left.{}`,op(sq[i+1..n+1])]:
			break:
		fi:
	od:
	RETURN( s,st,op(sq),ed ):
end:
tex_prep:=proc(l1,l2,sp)
	options `Copyright (c) 1994 by Yunliang Yu`;
	if nargs=3 and nops(l2)>0 and l2[1]=sp then
		RETURN( l2[1],op(l1),op(l2[2..nops(l2)]) );
	else
		RETURN( op(l1),op(l2) );
	fi:
end:
tex_tall:=proc(e)
	local x,i:
	options `Copyright (c) 1991 by Yunliang Yu`;
	if   hastype(e,`^`) or  hastype(e,function) then RETURN(true):
	elif type(e,{set,list,`+`}) then
		for x in e do if tex_tall(x) then RETURN(true) fi: od:
	elif hastype(e,`+`) then RETURN(true):
	elif hastype(e,fraction) then
		x:=indets(e,fraction):
		for i in x do
			if min( length(op(1,i)),length(op(2,i)) )>1 then
				RETURN(true):
			fi:
		od:
	fi:
	false:
end:
tex_print:=proc(e)
	local sq,ls,x,lx,ss:
	options `Copyright (c) 1991 by Yunliang Yu`;
	if not type(e,list) then ERROR(`argument has to be a list`): fi:
	if e=[] then RETURN(NULL) fi:
	sq:=""; ls:=0:
	for x in e do
		if x=0 then lx:=1 else lx:=length(x) fi:
    		if ls+lx>70 then
		   printf("%s\n",sq);
		   sq:=sprintf("%A",x); 
		   ls:=lx:
		else 
		     sq:=  cat(sq,"",sprintf("%A",x)): ls:=ls+lx:	
		fi:
	od:	
	printf("%s\n",sq);
end:

mtex:=proc(e)
	global  tex_caller, tex_lt, texwid, texsub, texidx, tex_sp, first_verbatim;
	local sp,sq,hd,tr,i,file,oldqt:
	options `Copyright (c) 1991 by Yunliang Yu`;
	if nargs=0 then RETURN(NULL): fi:
	oldqt:=interface(quiet);
	interface(quiet=true);
	for i from 2 to nargs do
		if   member(args[i],{amstex,latex,plain}) then
			tex_caller:=args[i]:
		elif type(args[i],symbol) then
			writeto(cat(args[i],`.tex`)): file:=1:
		elif type(args[i],numeric) then tex_lt:=args[i]:
		fi:
	od:
	if type(tex_lt,numeric) and tex_lt<0 then
		tex_lt:=-1000000;
	else
		tex_lt:=0:
	fi:
	if not type(texwid,numeric) then texwid:=70: fi:
	if not member(tex_caller,{amstex,latex,plain}) then
		tex_caller:=latex:
	fi:
	if not type(texsub,{list,set}) then
		texsub:={}:
	fi:
	if not type(texidx,{list,set}) then
		texidx:={}:
	fi:
	tex_sp:=``;
	if type(e,procedure) and
		not member(e,tex_math_func_) then
		if tex_caller=latex then
			printf("%s\n",`\\begin{verbatim}`);
			printf("%s\n");
			print(e);
			printf("%s\n",`\\end{verbatim}`);
		else
			if first_verbatim<>0 then
				first_verbatim:=0;
				for i in [
`%%%%%%% verbtim2.tex from ymir.claremont.edu by Tim Morgan <morgan@uci-icsa>`,
`\\def\\uncatcodespecials{\\def\\do##1{\\catcode``##1=12 } \\dospecials}`,
`\\def\\setupverbatim{\\par \\tt \\spaceskip=0pt`,
`        \\obeylines\\uncatcodespecials\\obeyspaces\\verbatimdefs}`,
`\\def\\verbatim{\\begingroup \\setupverbatim`,
`     \\parskip=0pt plus .05\\baselineskip \\parindent=0pt`,
`      \\catcode``\\ =13 \\catcode``\\^^M=13 \\catcode``\\?=0\\verbatimgobble}`,
`{\\catcode``\\^^M=13{\\catcode``\\ =13\\gdef\\verbatimdefs{\\def^^M{\\ \\par}\\let =\\ }}`,
`  \\gdef\\verbatimgobble#1^^M{}}`,
`\\let\\endverbatim=\\endgroup`,
`%%%%%%%   `] 			do printf("%s\n",i); od:
			fi;
			printf("%s\n",`\\verbatim`);
			printf("%s\n");
			print(e);
			printf("%s\n",`?endverbatim`);
		fi;
	elif type(e,{array,table}) then
		sq:=traperror(tex(e)):
		if sq=lasterror then
			writeto(terminal);
			lprint(sq);
		else
			tex_print([`$$ `,sq,` $$`]):
		fi:
	else
		if   tex_caller=amstex then
			hd:=`$$ \\align & `:
			tr:=` \\endalign $$`:
			sp:=` \\\\&\\quad `:
		elif tex_caller=latex then
			hd:=`\\begin{eqnarray*} && `:
			tr:=` \\end{eqnarray*}`:
			sp:=` \\\\&&\\quad{}`:
		elif tex_caller=plain then
			hd:=`$$ \\eqalign{& `:
			tr:=` \\cr} $$`:
			sp:=` \\cr&\\quad `:
		fi:
		tex_sp:=sp: sq:=traperror(tex(e)):
		if sq=lasterror then 
			writeto(terminal);
			lprint(sq);
                else
			if member(sp,{sq}) then
				tex_print([hd,sq,tr]):
			else
				tex_print([`$ `,sq,` $`]):
			fi:
		fi:
	fi:
	if file=1 then writeto(terminal) fi:
	interface(quiet = oldqt);
	NULL:
end:
tex_lead:=proc(a,b)
	local da,db,i, X, k, pt, p, HAS,DEG, nt:
	options `Copyright (c) 1991 by Yunliang Yu`;
	if args[nargs]=1 then p:=1: else p:=0: fi:
	HAS:=proc(x,y) frontend(has,[x,y],[{`+`,`*`,list,set},{}]) end:
	DEG:=proc(x,y) frontend(degree,[x,y],[{`+`,`*`,list,set},{}]) end:
	for i from 3 to nargs-p do
		if not HAS(a,args[i]) and not HAS(b,args[i]) then next fi:
		if p=1 then
			da:=HAS(a,args[i]): db:=HAS(b,args[i]):
			if   da and not db then RETURN(false):
			elif not da and db then RETURN(true): fi:
			k:=proc(a) if type(a,`+`) or ( type(a,`^`) and
			       type(op(1,a),`+`) ) then true else false fi end;
			da:=k(a): db:=k(b):
			if   not da and db then RETURN(true):
			elif da and not db then RETURN(false):fi:
		fi:
		nt:=nops(args[i]): X:=subsop(nt=NULL,args[i]): pt:=args[i][nt]:
		if pt=plex then
			for k in X do
				da:=DEG(a,k): db:=DEG(b,k):
				if   db=FAIL then RETURN(true):
				elif da=FAIL then RETURN(false):
				elif da>db then RETURN(true):
				elif da<db then RETURN(false): fi:
			od:
		elif pt=rlex then
			for k from nops(X) by -1 to 1 do
				da:=DEG(a,X[k]): db:=DEG(b,X[k]):
				if   db=FAIL then RETURN(true):
				elif da=FAIL then RETURN(false):
				elif da<db then RETURN(true):
				elif da>db then RETURN(false): fi:
			od:
		elif pt=tdeg then
			da:=DEG(a,{op(X)}): db:=DEG(b,{op(X)}):
			if   db=FAIL then RETURN(true):
			elif da=FAIL then RETURN(false):
			elif da>db then RETURN(true):
			elif da<db then RETURN(false): fi:
			RETURN(tex_lead(a,b,[op(X),rlex],args[i+1..nargs])):
		elif pt=rdeg then
			da:=DEG(a,{op(X)}): db:=DEG(b,{op(X)}):
			if   db=FAIL then RETURN(true):
			elif da=FAIL then RETURN(false):
			elif da<db then RETURN(true):
			elif da>db then RETURN(false): fi:
			RETURN(tex_lead(a,b,[op(X),plex],args[i+1..nargs])):
		fi:
	od:
	true:
end:
rlms:=proc(e)
	local ee,sg,i,e1,e2,a,s:
	options `Copyright (c) 1991 by Yunliang Yu`;
	if   type(e,`+`) then map(rlms,e):
	elif type(e,`*`) then
		ee:=[op(e)]: sg:=1:
		for i to nops(ee) do
			e1:=rlms(ee[i]):
			if type(e1,`+`) then
				a:=tex_sort([op(e1)]):
				a:=op(1,a): s:=1:
				if type(a,{numeric,`*`}) then s:=op(1,a): fi:
				if type(s,numeric) and s<0 then
					sg:=-sg: e1:=-e1:
				fi:
			fi:
			ee:=subsop(i=e1,ee):
		od:
		sg*convert(ee,`*`):
	elif type(e,`^`) then
		e1:=rlms(op(1,e)): e2:=op(2,e):
		if not type(e1,`+`) then e1^e2:
		else 	a:=tex_sort([op(e1)]):
			a:=op(1,a): s:=1:
			if type(a,{numeric,`*`}) then s:=op(1,a): fi:
			if type(s,numeric) and s<0 then
				(-1)^e2*(-e1)^e2:
			else 	e1^e2: fi:
		fi:
	elif type(e,{function, set,list, relation, taylor,series, range}) then
		map(rlms,e):
	else	e:
	fi:
end:
clct:=proc(e)
	local var,i,v,vv,dum:
	options `Copyright (c) 1991 by Yunliang Yu`;
	var:=NULL:
	for i from 2 to nargs do
		if type(args[i],list) and args[i]<>[] then
			var:=var,args[i]:
		fi:
	od:
	if var=NULL then
		if assigned(texvar) and texvar<>NULL then
			RETURN(clct(e,texvar)):
		else	RETURN(e):	fi:
	elif nops([var])=1 then
		collect(e,var,distributed):
	else	var:=[var]: v:=var[1]: vv:=op(var[2..nops(var)]):
		dum:=subs({'Y'=vv},proc() clct(args[1],Y) end):
		collect(e,v,distributed,dum):
	fi:
end:
stex:=proc(e)
	global  tex_caller, tex_lt, texvar, tex_sort;
	local tmp,var,file,i,nt:
	options `Copyright (c) 1991 by Yunliang Yu`;
	if nargs=0 then RETURN(NULL) fi:
	file:=NULL: var:=NULL:
	for i from 2 to nargs do
		if   type(args[i],list) then
			tmp:=map(proc(x) if type(x,{name,function}) then x fi
				end, args[i]):
			if tmp=[] then next fi: nt:=nops(tmp):
			if member(tmp[nt],{tdeg,rdeg,plex,rlex}) then
				if nt=1 then next: fi:
			else	tmp:=[op(tmp),tdeg]: fi:
			var:=var,tmp:
		elif member(args[i],{amstex,latex,plain}) then
			tex_caller:=args[i]:
		elif type(args[i],symbol) then
			file:=args[i]:
		elif type(args[i],numeric) then tex_lt:=args[i]:
		fi:
	od:
	if var<>NULL then texvar:=var:
	elif assigned(texvar) then
		var:=NULL:
		for i in [texvar] do
			if not type(i,list) or i=[] then next fi:
			tmp:=map(proc(x) if type(x,{name,function}) then x fi
				end, i):
			if tmp=[] then next fi: nt:=nops(tmp):
			if member(tmp[nt],{tdeg,rdeg,plex,rlex}) then
				if nt=1 then next: fi:
			else	tmp:=[op(tmp),tdeg]: fi:
			var:=var,tmp:
		od:	texvar:=var:
	fi:
	if var=NULL then
		if type(e,{table,array}) then
			tmp:=traperror(indets({entries(e)})):
		else 	tmp:=traperror(indets(e)): fi:
		if tmp=lasterror then tmp:={}: fi:
		if tmp<>{} then
			i:=proc(a,b)
				if   not type(a,symbol) then true
				elif not type(b,symbol) then false
				else lexorder(a,b) fi: end:
			var:=[op(sort([op(tmp)],i)),tdeg]:
		fi:
	fi:
	if var<>NULL then
		tex_sort:=subs('Y'=var,
			proc() local tmp:
			if nargs=2 then
			     tmp:=proc() tex_lead(args[1],args[2],Y,1) end:
			else tmp:=proc() tex_lead(args[1],args[2],Y) end:
			fi:  sort(args[1],tmp)
			end  ):
	fi:
	tmp:=traperror( rlms(e) ):
	if tmp=lasterror then tmp:=e: fi:
	if type(e,{table,array}) then
		tmp:=traperror( mtex(e, tex_caller,file) ):
	else 	tmp:=traperror( mtex(tmp,tex_caller,file) ): fi:
	if tmp=lasterror then 
			writeto(terminal);
			lprint(sq);
	fi:

	tex_sort:=proc() args[1] end:
	NULL:
end:
test:=proc()
	global  first_verbatim, tex_caller;
	local tmp,file;
	options `Copyright (c) 1991 by Yunliang Yu`;
	file:=NULL:
	first_verbatim:=1;
	for tmp in [args[1..nargs]] do
		if member(tmp,{amstex,latex,plain}) then tex_caller:=tmp:
		elif type(tmp,symbol) then file:=tmp: fi:
	od:
	if not member(tex_caller,{amstex,latex,plain}) then
		tex_caller:=latex;
	fi:
        print(`--------- Do your stuff now, ending it with exit; -----------`);
	if file<>NULL then
		interface(quiet=true);
		writeto(cat(file,`.tex`));
	fi;
	printf("\n");
	printf("%s\n",`%%%%%%% test file for TeX package generated by test() %%%%%%%%%%`);
	printf("\n");
	if tex_caller=amstex then
		printf("%s\n",`\\input amstex`);
		printf("%s\n",`\\documentstyle{amsppt}`);
		printf("%s\n",`\\magnification=\\magstep1`);
		printf("%s\n",`\\document`);
	elif tex_caller=latex then
		printf("%s\n",`\\documentstyle[12pt]{article}`);
		printf("%s\n",`\\begin{document}`);
	else
		printf("%s\n",`\\magnification=\\magstep1`);
	fi:	printf("\n");	0:
	do
		if file<>NULL then
			writeto(terminal); printf("%s",`\n% `);
			appendto(cat(file,`.tex`));
		fi:
		traperror(readstat(`% `));
		if %=exit then
			printf("\n");
			if   tex_caller=amstex then
				printf("%s\n",`\\enddocument`);
			elif tex_caller=latex then
				printf("%s\n",`\\end{document}`);
			else
				printf("%s\n",`\\bye`);
			fi:
			writeto(terminal);
			interface(quiet=false);
			break;
		else	printf("\n");
		fi;
	od:	NULL:
end:
tex_greek_:='{alpha,beta,gamma,delta,epsilon,varepsilon,zeta,eta,theta,
      	vartheta,iota,kappa,lambda,mu,nu,xi,pi,varpi,rho,varrho,
      	sigma,varsigma,tau,upsilon,phi,varphi,chi,psi,omega,
      	Gamma,Delta,Theta,Lambda,Xi,Sigma,Upsilon,Phi,Pi,Psi,
     	Omega}':
tex_math_func_:='{arccos,arcsin,arctan,arg,cos,cosh,cot,coth,csc,
      deg,det,dim, exp,gcd, hom, inf, ker, lg, lim,
      liminf,limsup,ln,log,max,min, Pr, sec, sin, sinh,
      sup,tan,tanh}':
`tex/SetOps`:=proc()
	global  tex_lt;
	local sq,op,i;
	sq:=NULL; op:=args[nargs];
	for i to nargs-1 do
		if type(args[i],{name,set}) then
			sq:=sq,tex(args[i]);
		else
			sq:=sq,`\\left(`,tex(args[i]),`\\right)`; tex_lt:=tex_lt+1;
		fi;
		if i<nargs-1 then
			sq:=sq,op; tex_lt:=tex_lt+3/2;
		fi;
	od;
	RETURN(sq);
end:
`tex/union`:=proc() `tex/SetOps`(args,`\\cup `) end:
`tex/minus`:=proc() `tex/SetOps`(args,`\\setminus `) end:
`tex/intersect`:=proc() `tex/SetOps`(args,`\\cap `) end:
`tex/&^`:=proc() 
global  tex_lt;
tex_lt:=tex_lt+3: `\\&\\hat{}(`,tex(args),`)`: end:
tex_sort:=proc() args[1] end:
tex_lt:=0:

read "tex.msl":
#savelib( \
	'`clct`', \
	'`mtex`', \
	'`rlms`', \
	'`stex`', \
	'`test`', \
	'`tex`', \
	'`tex/SetOps`', \
	'`tex/intersect`', \
	'`tex/minus`', \
	'`tex/union`', \
	'`tex_insert`', \
	'`tex_lead`', \
	'`tex_pdt`', \
	'`tex_prep`', \
	'`tex_print`', \
	'`tex_sort`', \
	'`tex_table`', \
	'`tex_tall`', \
	'`tex_greek_`', \
	'`tex_math_func_`', \
	'`tex/&^`', \
	'`_Share`', \
	"tex.m" \
):


#print(`Save to the file ./tex.m...`);
#save `tex.m`;
#print(`Make the library ./TeX.m..................`);
#TeX[tex]:=op(tex):        tex:=evaln(tex):
#TeX[mtex]:=op(mtex):      mtex:=evaln(mtex):
#TeX[stex]:=op(stex):      stex:=evaln(stex):
#TeX[rlms]:=op(rlms):      rlms:=evaln(rlms):
#TeX[clct]:=op(clct):      clct:=evaln(clct):
#TeX[test]:=op(test):      test:=evaln(test):
#save `TeX.m`; quit
#@EOF#################################################################
#quit
