function [x,y,typ]=Edge_Trig(job,arg1,arg2)
//Generated from SuperBlock on 9-Jan-2011
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
    "Set edge trigger block parameters"
  Exprs0=..
    "i"
  Bitems=..
    "rising (0), falling (-1), edge (0)"
  Ss=..
    list("pol",-1)
  scicos_context=struct()
     x=arg1
  ok=%f
  while ~ok do
    [ok,scicos_context.i,exprs]=getvalue(Btitre,Bitems,Ss,exprs)
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
              wpar=[-159.096,811.104,-108.58933,553.61067,1323,903,346,236,630,479,422,212,1.4],..
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
                gui="EDGETRIGGER",..
                graphics=scicos_graphics(..
                         orig=[301.43733,153.944],..
                         sz=[60,40],..
                         flip=%t,..
                         theta=0,..
                         exprs="i",..
                         pin=5,..
                         pout=3,..
                         pein=[],..
                         peout=[],..
                         gr_i=list("xstringb(orig(1),orig(2),[''Edge'';''trigger''],sz(1),sz(2),''fill'');",8),..
                         id="",..
                         in_implicit="E",..
                         out_implicit="E"),..
                model=scicos_model(..
                         sim=list("edgetrig",4),..
                         in=1,..
                         in2=[],..
                         intyp=1,..
                         out=1,..
                         out2=[],..
                         outtyp=1,..
                         evtin=[],..
                         evtout=[],..
                         state=[],..
                         dstate=0,..
                         odstate=list(),..
                         rpar=[],..
                         ipar=1,..
                         opar=list(),..
                         blocktype="c",..
                         firing=[],..
                         dep_ut=[%t,%f],..
                         label="",..
                         nzcross=1,..
                         nmode=0,..
                         equations=list()),..
                doc=list())
scs_m_1.objs(2)=scicos_block(..
                gui="IFTHEL_f",..
                graphics=scicos_graphics(..
                         orig=[425.37067,143.944],..
                         sz=[60,60],..
                         flip=%t,..
                         theta=0,..
                         exprs=["0";"0"],..
                         pin=3,..
                         pout=[],..
                         pein=[],..
                         peout=[7;0],..
                         gr_i=list(..
                         ["txt=[''If in>0'';'' '';'' then    else''];";
                         "xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');"],8),..
                         id="",..
                         in_implicit="E",..
                         out_implicit=[]),..
                model=scicos_model(..
                         sim=list("ifthel",-1),..
                         in=1,..
                         in2=1,..
                         intyp=-1,..
                         out=[],..
                         out2=[],..
                         outtyp=1,..
                         evtin=[],..
                         evtout=[1;1],..
                         state=[],..
                         dstate=[],..
                         odstate=list(),..
                         rpar=[],..
                         ipar=[],..
                         opar=list(),..
                         blocktype="l",..
                         firing=[-1,-1],..
                         dep_ut=[%t,%f],..
                         label="",..
                         nzcross=0,..
                         nmode=0,..
                         equations=list()),..
                doc=list())
scs_m_1.objs(3)=scicos_link(..
                  xx=[370.00876;416.79924],..
                  yy=[173.944;173.944],..
                  id="",..
                  thick=[0,0],..
                  ct=[1,1],..
                  from=[1,1,0],..
                  to=[2,1,1])
scs_m_1.objs(4)=scicos_block(..
                gui="IN_f",..
                graphics=scicos_graphics(..
                         orig=[252.8659,163.944],..
                         sz=[20,20],..
                         flip=%t,..
                         theta=0,..
                         exprs=["1";"-1";"-1"],..
                         pin=[],..
                         pout=5,..
                         pein=[],..
                         peout=[],..
                         gr_i=list(" ",8),..
                         id="",..
                         in_implicit=[],..
                         out_implicit="E"),..
                model=scicos_model(..
                         sim="input",..
                         in=[],..
                         in2=[],..
                         intyp=1,..
                         out=-1,..
                         out2=-2,..
                         outtyp=-1,..
                         evtin=[],..
                         evtout=[],..
                         state=[],..
                         dstate=[],..
                         odstate=list(),..
                         rpar=[],..
                         ipar=1,..
                         opar=list(),..
                         blocktype="c",..
                         firing=[],..
                         dep_ut=[%f,%f],..
                         label="",..
                         nzcross=0,..
                         nmode=0,..
                         equations=list()),..
                doc=list())
scs_m_1.objs(5)=scicos_link(..
                  xx=[272.8659;292.8659],..
                  yy=[173.944;173.944],..
                  id="",..
                  thick=[0,0],..
                  ct=[1,1],..
                  from=[4,1,0],..
                  to=[1,1,1])
scs_m_1.objs(6)=scicos_block(..
                gui="CLKOUTV_f",..
                graphics=scicos_graphics(..
                         orig=[435.37067,78.229714],..
                         sz=[20,30],..
                         flip=%t,..
                         theta=0,..
                         exprs="1",..
                         pin=[],..
                         pout=[],..
                         pein=7,..
                         peout=[],..
                         gr_i=list(" ",8),..
                         id="",..
                         in_implicit=[],..
                         out_implicit=[]),..
                model=scicos_model(..
                         sim="output",..
                         in=[],..
                         in2=[],..
                         intyp=1,..
                         out=[],..
                         out2=[],..
                         outtyp=1,..
                         evtin=1,..
                         evtout=[],..
                         state=[],..
                         dstate=[],..
                         odstate=list(),..
                         rpar=[],..
                         ipar=1,..
                         opar=list(),..
                         blocktype="d",..
                         firing=[],..
                         dep_ut=[%f,%f],..
                         label="",..
                         nzcross=0,..
                         nmode=0,..
                         equations=list()),..
                doc=list())
scs_m_1.objs(7)=scicos_link(..
                  xx=[445.37067;445.37067],..
                  yy=[138.22971;108.22971],..
                  id="",..
                  thick=[0,0],..
                  ct=[5,-1],..
                  from=[2,1,0],..
                  to=[6,1,1])
  model=scicos_model()
  model.sim="csuper"
  model.in=-1
  model.in2=-2
  model.intyp=-1
  model.out=[]
  model.out2=[]
  model.outtyp=1
  model.evtin=[]
  model.evtout=1
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
  i=1
  exprs=[sci2exp(i,0);]
  gr_i=list("xstringb(orig(1),orig(2),[""Edge"";""Trigger""],sz(1),sz(2),''fill'');",8)
  x=standard_define([3.5,2],model,exprs,gr_i)
end
endfunction
