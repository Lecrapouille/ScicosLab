function [x,y,typ]=ENDBLOCK(job,arg1,arg2)
//Generated from SuperBlock on 8-Jan-2011
x=[];y=[];typ=[];
select job
case 'plot' then
  standard_draw(arg1)
case 'getinputs' then
  [x,y,typ]=standard_inputs(arg1)
case 'getoutputs' then
  [x,y,typ]=standard_outputs(arg1)
case 'getorigin' then
  [x,y]=standard_origin(arg1)
case 'set' then
  y=needcompile
  typ=list()
  graphics=arg1.graphics;
  exprs=graphics.exprs
  Btitre=..
    "Set final simulation time parameter"
  Exprs0=..
    "tf"
  Bitems=..
    "Final simulation time"
  Ss=..
    list("pol",-1)
  scicos_context=struct()
     x=arg1
  ok=%f
  while ~ok do
    [ok,scicos_context.tf,exprs]=getvalue(Btitre,Bitems,Ss,exprs)
    if ~ok then return;end
     %scicos_context=scicos_context
     sblock=x.model.rpar
     [%scicos_context,ierr]=script2var(sblock.props.context,%scicos_context)
     if ierr==0 then
       [sblock,%w,needcompile2,ok]=do_eval(sblock,list(),%scicos_context)
   if ok then
          y=max(2,needcompile,needcompile2)
          x.graphics.exprs=exprs
          x.model.rpar=sblock
          break
   end
     else
       err=lasterror();
       if err<>[] then message(err);end
   ok=%f
     end
  end
case 'define' then
scs_m_1=scicos_diagram(..
        version="scicos4.4",..
        props=scicos_params(..
              wpar=[56.350931,515.98125,74.444064,389.63663,630,429,0,0,630,429,241,151,1.4],..
              Title="SuperBlock",..
              tol=[0.000001,0.000001,1.000D-10,31,0,0],..
              tf=30,..
              context=" ",..
              void1=[],..
              options=tlist(["scsopt","3D","Background","Link","ID","Cmap"],list(%t,33),[8,1],[1,5,2],..
              list([4,1,10,1],[4,1,2,1]),[0.8,0.8,0.8]),..
              void2=[],..
              void3=[],..
              doc=list()))
scs_m_1.objs(1)=scicos_block(..
                gui="END_c",..
                graphics=scicos_graphics(..
                         orig=[359.9287,149.14941],..
                         sz=[40,40],..
                         flip=%t,..
                         theta=0,..
                         exprs="tf",..
                         pin=[],..
                         pout=[],..
                         pein=2,..
                         peout=2,..
                         gr_i=list("xstringb(orig(1),orig(2),'' END '',sz(1),sz(2),''fill'');",8),..
                         id="",..
                         in_implicit=[],..
                         out_implicit=[]),..
                model=scicos_model(..
                         sim=list("scicosexit",4),..
                         in=[],..
                         in2=[],..
                         intyp=1,..
                         out=[],..
                         out2=[],..
                         outtyp=1,..
                         evtin=1,..
                         evtout=1,..
                         state=[],..
                         dstate=[],..
                         odstate=list(),..
                         rpar=[],..
                         ipar=[],..
                         opar=list(),..
                         blocktype="d",..
                         firing=1,..
                         dep_ut=[%f,%f],..
                         label="",..
                         nzcross=0,..
                         nmode=0,..
                         equations=list()),..
                doc=list())
scs_m_1.objs(2)=scicos_link(..
                  xx=[379.9287;379.9287;352.55714;352.55714;352.55714;379.9287;379.9287],..
                  yy=[143.43513;127.7523;127.7523;129.21433;203.77792;203.77792;194.8637],..
                  id="",..
                  thick=[0,0],..
                  ct=[5,-1],..
                  from=[1,1,0],..
                  to=[1,1,1])
  model=scicos_model()
  model.sim="csuper"
  model.in=[]
  model.in2=[]
  model.intyp=1
  model.out=[]
  model.out2=[]
  model.outtyp=1
  model.evtin=[]
  model.evtout=[]
  model.state=[]
  model.dstate=[]
  model.odstate=list()
  model.rpar=scs_m_1
  model.ipar=1
  model.opar=list()
  model.blocktype="h"
  model.firing=[]
  model.dep_ut=[%f,%f]
  model.label=""
  model.nzcross=0
  model.nmode=0
  model.equations=list()
  tf=1
  exprs=[sci2exp(tf,0);]
  gr_i=list("xstringb(orig(1),orig(2),""END"",sz(1),sz(2),''fill'');",8)
  x=standard_define([2,2],model,exprs,gr_i)
end
endfunction
