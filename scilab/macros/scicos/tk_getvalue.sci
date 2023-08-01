function [%ok,%1,%2,%3,%4,%5,...
          %6,%7,%8,%9,%10,...
          %11,%12,%13,%14,%15,...
          %16,%17,%18,%19,%20]=tk_getvalue(%desc,%labels,%typ,%ini)
// Copyright INRIA
//  getvalues - %window dialog for data acquisition 
//%Syntax%
//  [%ok,%1,..,%11]=getvalue(desc,labels,typ,ini)
//%Parameters
//  desc    : column vector of strings, dialog general comment 
//  labels  : n column vector of strings, labels(i) is the label of 
//            the ith required value
//  typ     : list(typ1,dim1,..,typn,dimn)
//            typi : defines the type of the ith required value
//                   if may have the following values:
//                   'mat' : stands for matrix of scalars 
//                   'col' : stands for column vector of scalars
//                   'row' : stands for row vector of scalars
//                   'vec' : stands for  vector of scalars
//                   'str' : stands for vector of strings
//                   'lis' : stands for list
//                   'pol' : stands for polynomials
//                   'r'   : stands for rational
//            dimi : defines the size of the ith required value
//                   it must be
//                    - an integer or a 2-vector of integers (-1 stands for
//                      arbitrary dimension)
//                    - an evaluatable character string
//  ini     : n column vector of strings, ini(i) gives the suggested
//            response for the ith required value
//  %ok      : boolean ,%t if %ok button pressed, %f if cancel button pressed
//  xi      : contains the ith required value if %ok==%t
//%Description
// getvalues macro encapsulate x_mdialog function with error checking,
// evaluation of numerical response, ...
//%Remarks
// All correct scilab syntax may be used as responses, for matrices 
// and vectors getvalues automatically adds [ ] around the given response
// before numerical evaluation
//%Example
// labels=['magnitude';'frequency';'phase    '];
// [ampl,freq,ph]=getvalue('define sine signal',labels,..
//            list('vec',1,'vec',1,'vec',1),['0.85';'10^2';'%pi/3'])
// 
//%See also
// x_mdialog, x_dialog

[%lhs,%rhs]=argn(0)

%nn=prod(size(%labels))
if %lhs<>%nn+2&%lhs<>%nn+1 then error(41),end
if size(%typ)<>2*%nn then
  error('%typ : list(''type'',[sizes],...)')
end
%1=[];%2=[];%3=[];%4=[];%5=[];
%6=[];%7=[];%8=[];%9=[];%10=[];
%11=[];%12=[];%13=[];%14=[];%15=[];
%16=[];%17=[];%18=[];%19=[];%20=[];

if %rhs==3 then  %ini=emptystr(%nn,1),end
%ok=%t
while %t do
  %str=mdialog(%desc,%labels,%ini)
  if %str==[] then %ok=%f,%str=[];break,end
  //%str=%str1;
  for %kk=1:%nn
    %cod=ascii(%str(%kk))
    %spe=find(%cod==10)
    if %spe<>[] then
      %semi=ascii(';')
      %cod(%spe)=%semi*ones(%spe')
      %str(%kk)=ascii(%cod)
    end
  end
  [%vv_list,%ierr_vec,%err_mess,%ok]=context_evstr(%str,%scicos_context,%typ,'get');
  if ~%ok then
     x_message(%err_mess)
     break
  end
%ok=%t;
  %nok=0
  for %kk=1:%nn
    %vv=%vv_list(%kk)
    %ierr=%ierr_vec(%kk)
    select part(%typ(2*%kk-1),1:3)
    case 'mat'
      if %ierr<>0 then 
	%err_mess=%err_mess(%kk) 
	%nok=%inf;break
      end
      //29/12/06
      //the type of %vv is accepted if it is constant or integer
      if and(type(%vv)<>[1 8]) then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      [%mv,%nv]=size(%vv)
      %ssz=string(%sz(1))+' x '+string(%sz(2))
      if %mv*%nv==0 then
	if  %sz(1)>=0&%sz(2)>=0&%sz(1)*%sz(2)<>0 then %nok=%kk,break,end
      else
	if %sz(1)>=0 then if %mv<>%sz(1) then %nok=%kk,break,end,end
	if %sz(2)>=0 then if %nv<>%sz(2) then %nok=%kk,break,end,end
      end
    case 'vec'
      if %ierr<>0 then  
	%err_mess=%err_mess(%kk);
	%nok=%inf;break,
      end
      //17/01/07
      //the type of %vv is accepted if it is constant or integer
      if and(type(%vv)<>[1 8]) then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      %ssz=string(%sz(1))
      %nv=prod(size(%vv))
      if %sz(1)>=0 then if %nv<>%sz(1) then %nok=%kk,break,end,end
    case 'pol'
      if %ierr<>0 then   
	%err_mess=%err_mess(%kk);
	%nok=%inf;break,
      end 
      if (type(%vv)>2 & type(%vv)<>8) then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      %ssz=string(%sz(1))
      %nv=prod(size(%vv))
      if %sz(1)>=0 then if %nv<>%sz(1) then %nok=%kk,break,end,end
    case 'row'
      if %ierr<>0 then   
	%err_mess=%err_mess(%kk);
	%nok=%inf;break,
      end
      //17/01/07
      //the type of %vv is accepted if it is constant or integer
      if and(type(%vv)<>[1 8]) then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      if %sz(1)<0 then
	%ssz='1 x *'
      else
	%ssz='1 x '+string(%sz(1))
      end
      [%mv,%nv]=size(%vv)
      if %mv<>1 then %nok=%kk,break,end,
      if %sz(1)>=0 then if %nv<>%sz(1) then %nok=%kk,break,end,end
    case 'col'
      if %ierr<>0 then   
	%err_mess=%err_mess(%kk);
	%nok=%inf;break,
      end
      //17/01/07
      //the type of %vv is accepted if it is constant or integer
      if and(type(%vv)<>[1 8]) then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      if %sz(1)<0 then
	%ssz='* x 1'
      else
	%ssz=string(%sz(1))+' x 1'
      end
      [%mv,%nv]=size(%vv)
      if %nv<>1 then %nok=%kk,break,end,
      if %sz(1)>=0 then if %mv<>%sz(1) then %nok=%kk,break,end,end
    case 'str'
      %sde=%str(%kk)
      %spe=find(ascii(%str(%kk))==10)
      %spe($+1)=length(%sde)+1
      clear %vv
      %vv=[];%kk1=1
      for %kkk=1:size(%spe,'*')
	%vv(%kkk,1)=part(%sde,%kk1:%spe(%kkk)-1)
	%kk1=%spe(%kkk)+1
      end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      %ssz=string(%sz(1))
      %nv=prod(size(%vv))
      if %sz(1)>=0 then if %nv<>%sz(1) then %nok=%kk,break,end,end
    case 'lis'
      if %ierr<>0 then   
	%err_mess=%err_mess(%kk);
	%nok=%inf;break,
      end
      if type(%vv)<>15& type(%vv)<>16& type(%vv)<>17 then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      %ssz=string(%sz(1))
      %nv=size(%vv)
      if %sz(1)>=0 then if %nv<>%sz(1) then %nok=%kk,break,end,end
    case 'r  '
      if %ierr<>0 then   
	%err_mess=%err_mess(%kk);
	%nok=%inf;break,
      end
      if type(%vv)<>16 then %nok=-%kk,break,end
      if typeof(%vv)<>'rational' then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      [%mv,%nv]=size(%vv(2))
      %ssz=string(%sz(1))+' x '+string(%sz(2))
      if %mv*%nv==0 then
	if  %sz(1)>=0&%sz(2)>=0&%sz(1)*%sz(2)<>0 then %nok=%kk,break,end
      else
	if %sz(1)>=0 then if %mv<>%sz(1) then %nok=%kk,break,end,end
	if %sz(2)>=0 then if %nv<>%sz(2) then %nok=%kk,break,end,end
      end
    case 'gen'
      // accept everything
      if %ierr<>0 then 
	%err_mess=%err_mess(%kk) 
	%nok=%inf;break
      end
    else
      error('type non gere :'+%typ(2*%kk-1))
    end
    execstr('%'+string(%kk)+'=%vv')
    clear %vv
  end
  if  %nok==%inf then 
    x_message(['The evaluation of block parameters results in the error: ';
	%err_mess]);
    %ini=%str
  elseif %nok>0 then 
    x_message(['answer given for '+%labels(%nok);
             'has invalid dimension: ';
             'waiting for dimension  '+%ssz])
    %ini=%str
  elseif %nok<0 then
    if %ierr==0 then
      x_message(['answer given for '+%labels(-%nok);
	'has incorrect type :'+ %typ(-2*%nok-1)])
    else
      x_message(['answer given for '+%labels(-%nok);
	'is incorrect:'+%err_mess(-%nok)])
    end
    %ini=%str
  else
    break
  end
end
if %lhs==%nn+2 then
  execstr('%'+string(%lhs-1)+'=%str')
end
endfunction

function result=mdialog(titlex,items,init)
if argn(2)<1 then
  titlex=['this is a demo';'this is a demo']
  items=['item 1';'item 2']
end
if argn(2)<3 then
  init=['init 1';'init 2']
end
titlex=sci2tcl(titlex);
for i=1:size(items,'*')
  items(i)=sci2tcl(items(i))
  init(i)=sci2tcl(init(i))
end
result=[];
done=string(3)
while done==string(3) then
  txt=create_txt(titlex,items,init);
  TCL_EvalStr(txt)
  done=TCL_GetVar('done')
  if done==string(1) then
    for i=1:size(items,'*')
      execstr('result(i)=TCL_GetVar(''x'+string(i)+''')')
    end
  elseif done==string(3) then
    if exists('%scs_help') then
      execstr('help('''+%scs_help+''');' , 'errcatch')
    else
      execstr('help(''whatis_scicos'');' , 'errcatch')
    end
  end
end
TCL_EvalStr('catch {set numx [winfo x $w];set numy [winfo y $w];destroy $w}')
endfunction

function txt=create_txt(titlex,items,init)
 //** retrieve current postion of the last dialog box
 //** potential TCL global variables numx/numy
 if TCL_ExistVar('numx') then
   numx=TCL_GetVar('numx')
   numx_tt='set numx '+numx
 else
   numx_tt=['set numx [winfo pointerx $w]'
            'set numx [ expr $numx - 160]']
 end

 if TCL_ExistVar('numy') then
   numy=TCL_GetVar('numy')
   numy_tt='set numy '+numy
 else
   numy_tt=['set numy [winfo pointery $w]'
            'set numy [ expr $numy - 5 ]']
 end
txt=[ "set BWpath [file dirname '"$env(SCIPATH)/tcl/bwidget-1.9.13'"] "
     "if {[lsearch $auto_path $BWpath]==-1} {set auto_path [linsert $auto_path 0 $BWpath]}" 
     "package require BWidget 1.9.13"
     'namespace inscope :: package require BWidget'
     'set w .form'
     'catch {destroy $w}'
     'toplevel $w'
     'wm title $w '"Set Block properties'"'
     'wm iconname $w '"form'"'
     'label $w.msg  -wraplength 4i -justify left -text '"'+titlex+''"'
     'frame $w.buttons'
     'pack $w.buttons -side bottom -fill x -pady 2m'
     'button $w.buttons.dismiss -text Dismiss -command {set done 2}'
     'button $w.buttons.code -text OK -command {set done 1}'
     'button $w.buttons.help -text Help -command {set done 3}'
     'pack $w.buttons.dismiss $w.buttons.code -side left'
     'pack $w.buttons.help -side right'];
ln=max(length(items))+1;

for i=1:size(items,'*')
  txt=[txt
       'LabelEntry $w.f'+string(i)+' -relief sunken -width 30 -labelwidth '+string(ln)+ ' -label '"'+items(i)+''"'+' -text  '"'+init(i)+''"']
end

tt=''
for i=1:size(items,'*')
  tt=tt+'global x'+string(i)+';set x'+string(i)+' [$w.f'+string(i)+' cget  -text];'
  //tt=tt+'ScilabEval '"result('+string(i)+')=x'+string(i)+''";'
end
txt=[txt;
     'proc done1 {w} {'+tt+'}']
tt=''
for i=1:size(items,'*')
  tt=tt+'$w.f'+string(i)+' '
end
txt=[txt;
     'pack $w.msg '+tt+'-side top -fill x'
     '#update idletasks'
     '#positionWindow $w'
     'focus $w.f1'
     numx_tt
     numy_tt
     'wm geometry $w +$numx+$numy'
     'set done 0'
     'bind $w <Return> {set done 1}'
     'bind $w <Destroy> {set done 2}'
     'tkwait variable done'
     'if {$done==1} {done1 $w}']
endfunction

