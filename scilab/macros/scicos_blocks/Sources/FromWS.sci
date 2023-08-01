function [x,y,typ]=FromWS(job,arg1,arg2)
//Generated from From Workspace on 8-Jan-2011
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
    "Set From Workspace block parameters"
  Exprs0=..
    ["O";"IM";"zcr";"v"]
  Bitems=["Variable name";
    "Interpolation method";
    "Enable zero-corssing (0: no, 1: yes)";
    "Output at the end (0: zero, 1: hold, 2: repeat)"]

  Ss=list("str",1,"vec",1,"vec",1,"vec",1)
  scicos_context=struct()
     x=arg1
  ok=%f
  while ~ok do
    [ok,scicos_context.v,scicos_context.IM,scicos_context.zcr,scicos_context.O,exprs]=getvalue(Btitre,Bitems,Ss,exprs)
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
              wpar=[68.831076,619.74041,101.7644,412.54459,751,430,60,0,630,417,705,200,1.4],..
              Title="From Workspace",..
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
                gui="FROMWS_c",..
                graphics=scicos_graphics(..
                         orig=[338.104,236.07733],..
                         sz=[70,40],..
                         flip=%t,..
                         theta=0,..
                         exprs=["v";"IM+v";"zcr";"O"],..
                         pin=[],..
                         pout=4,..
                         pein=2,..
                         peout=2,..
                         gr_i=list(..
                         ["txt=[''From workspace''];";
                         "xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')"],8),..
                         id="",..
                         in_implicit=[],..
                         out_implicit="E"),..
                model=scicos_model(..
                         sim=list("fromws_c",4),..
                         in=[],..
                         in2=[],..
                         intyp=1,..
                         out=-1,..
                         out2=-2,..
                         outtyp=-1,..
                         evtin=1,..
                         evtout=1,..
                         state=[],..
                         dstate=[],..
                         odstate=list(),..
                         rpar=[],..
                         ipar=[1;31;3;1;0],..
                         opar=list(),..
                         blocktype="d",..
                         firing=0,..
                         dep_ut=[%f,%t],..
                         label="",..
                         nzcross=0,..
                         nmode=0,..
                         equations=list()),..
                doc=list())
scs_m_1.objs(2)=scicos_link(..
                  xx=[373.104;373.104;327.104;327.104;373.104;373.104],..
                  yy=[230.36305;216.27733;216.27733;296.944;296.944;281.79162],..
                  id="",..
                  thick=[0,0],..
                  ct=[5,-1],..
                  from=[1,1,0],..
                  to=[1,1,1])
scs_m_1.objs(3)=scicos_block(..
                gui="OUT_f",..
                graphics=scicos_graphics(..
                         orig=[436.67543,246.07733],..
                         sz=[20,20],..
                         flip=%t,..
                         theta=0,..
                         exprs="1",..
                         pin=4,..
                         pout=[],..
                         pein=[],..
                         peout=[],..
                         gr_i=list(" ",8),..
                         id="",..
                         in_implicit="E",..
                         out_implicit=[]),..
                model=scicos_model(..
                         sim="output",..
                         in=-1,..
                         in2=-2,..
                         intyp=-1,..
                         out=[],..
                         out2=[],..
                         outtyp=1,..
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
scs_m_1.objs(4)=scicos_link(..
                  xx=[416.67543;436.67543],..
                  yy=[256.07733;256.07733],..
                  id="",..
                  thick=[0,0],..
                  ct=[1,1],..
                  from=[1,1,0],..
                  to=[3,1,1])
  model=scicos_model()
  model.sim="csuper"
  model.in=[]
  model.in2=[]
  model.intyp=1
  model.out=-1
  model.out2=-2
  model.outtyp=-1
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
  O=0
  IM=1
  zcr=1
  v=2
  exprs=[sci2exp(O,0);sci2exp(IM,0);sci2exp(zcr,0);sci2exp(v,0);]
  gr_i=list("xstringb(orig(1),orig(2),""From Workspace"",sz(1),sz(2),''fill'');",8)
  x=standard_define([3.5,2],model,exprs,gr_i)
end
endfunction
