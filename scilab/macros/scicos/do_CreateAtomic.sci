function [o,needcompile,ok]=do_CreateAtomic(o,k,scs_m)
// Last Update Fady: 15 Dec 2008
ok=%t
model=o.model
graphics=o.graphics;
needcompile=4;
XX = o;
[ok,params,param_types]=FindSBParams(model.rpar,[])
if ~ok then return;end
if params<>[] then
  message('The parameter ""'+params+'"" must be defined in the context of the atomic super block.')
  return;
end
ALL=%f;
xx=CodeGeneration_;
ierr=execstr('[ok, XX, gui_path,flgcdgen, szclkINTemp, freof,c_atomic_code,cpr] ='+ ...
             'do_compile_superblock42(scs_m, k, %t);','errcatch');
if ierr<>0 then
  message(lasterror());
  ok=%f
end
if ~ok then return; end

if freof <> [] then 
  message('An Atomic Superblock cannot contain sample clocks');ok=%f
  return
elseif (XX.model.dep_ut($)==%t & XX.model.evtin<>[]) then
  message('A Triggered Atomic Subsystem cannot contain blocks with continuous time');ok=%f
  return 
end
[ok,for_iterator_flag,init_output,nbre_iter,step,ss_input_nbre,iter_var_datatype,obj_nbre,exist_output,startingstate,iter_op]=treatforiterator(model.rpar)
if ~ok then return;end
//**quick fix for sblock that contains scope
//gh_curwin=scf(curwin)
funtyp=2004
ind=find(cpr.sim.funtyp==10004|cpr.sim.funtyp==12004)
if ind<>[] then
  funtyp=12004
  for i=ind'
    modelicafunname=cpr.sim.funs(i)
    [a,b]=c_link(modelicafunname)
    while a do
      ulink(b)
      [a,b]=c_link(modelicafunname)
    end
  end
end
o.model.sim=list('asuper',funtyp);
o.model.in=XX.model.in
o.model.in2=XX.model.in2
o.model.out=XX.model.out
o.model.out2=XX.model.out2
o.model.intyp=XX.model.intyp
o.model.outtyp=XX.model.outtyp
XX.model.sim(2)=funtyp;
//c_atomic_code=strsubst(c_atomic_code,'scicos_block.h','scicos.h')
o.graphics.exprs=list(XX.graphics.exprs,c_atomic_code,XX.model);

[a,b]=c_link(XX.model.sim(1))
while a do
  ulink(b)
  [a,b]=c_link(XX.model.sim(1))
end
if for_iterator_flag then
  o=RedrawIteratorSB(o,iter_op);
  if startingstate then
    // concatenation of the initial states
    if size(XX.model.dstate,'*')<>0 then XX.model.dstate($+1:$+size(XX.model.dstate,'*'))=XX.model.dstate;end
    if size(XX.model.state,'*')<>0 then XX.model.state($+1:$+size(XX.model.dstate,'*'))=XX.model.state;end
    if lstsize(XX.model.odstate)<>0 then XX.model.odstate=lstcat(XX.model.odstate,XX.model.odstate);end
  end
  code=generate_iter_ccode(XX.model.sim(1),init_output,nbre_iter,step,iter_var_datatype,ss_input_nbre,model,obj_nbre,exist_output,startingstate,XX.model,iter_op,cpr)
  old_funam=XX.model.sim(1);
  XX.model.sim(1)='iter_'+XX.model.sim(1)
  o.graphics.exprs=list(XX.graphics.exprs,[code;c_atomic_code],XX.model);
  [a,b]=c_link(XX.model.sim(1))
  while a do
    ulink(b)
    [a,b]=c_link(XX.model.sim(1))
  end
end
endfunction

function o=RedrawIteratorSB(o,iter_op)
  o.graphics.sz(1)=60;
  o.graphics.gr_i=list(['xstringb(orig(1),orig(2),[''    '+iter_op+''';''SubSystem''],sz(1),sz(2),''fill'')'],8);
endfunction
