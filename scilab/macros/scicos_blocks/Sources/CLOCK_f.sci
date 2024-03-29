function [x,y,typ]=CLOCK_f(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[],typ=[]
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
    if arg1.model.rpar.objs(1)==mlist('Deleted') then
      path = 3  //compatibility with translated blocks
    else
      path = 2
    end
    newpar=list();
    xx=arg1.model.rpar.objs(path)// get the evtdly block
    exprs=xx.graphics.exprs
    model=xx.model;
    t0_old=model.firing
    dt_old= model.rpar
    model_n=model
    while %t do
      [ok,dt,t0,exprs0]=getvalue('Set Clock block parameters',..
				['Period';'Init time'],list('vec',1,'vec',1),exprs)
      if ~ok then break,end
      if dt<=0 then
	     message('period must be positive')
	     ok=%f
      end
      if ok then
	     xx.graphics.exprs=exprs0
	     model.rpar=dt
	     model.firing=t0
	     xx.model=model
	     arg1.model.rpar.objs(path)=xx// Update
	     break
      end
    end
    if ~and([t0_old dt_old]==[t0 dt])|~and(exprs0==exprs) then 
      // parameter  changed
      newpar(size(newpar)+1)=path// Notify modification
    end
    if t0_old<>t0 then needcompile=2,else needcompile=0,end
    x=arg1
    y=needcompile
    typ=newpar
   case 'define' then
    evtdly=EVTDLY_f('define')
    evtdly.graphics.orig=[320,232]
    evtdly.graphics.sz=[40,40]
    evtdly.graphics.flip=%t
    evtdly.graphics.exprs=['0.1';'0.1']
    evtdly.graphics.pein=6
    evtdly.graphics.peout=3
    evtdly.model.rpar=0.1
    evtdly.model.firing=0.1
    
    output_port=CLKOUT_f('define')
    output_port.graphics.orig=[399,162]
    output_port.graphics.sz=[20,20]
    output_port.graphics.flip=%t
    output_port.graphics.exprs='1'
    output_port.graphics.pein=5
    output_port.model.ipar=1
    
    split=CLKSPLIT_f('define')
    split.graphics.orig=[380.71066;172]
    split.graphics.pein=3,
    split.graphics.peout=[5;6]
    
    gr_i=list(['wd=xget(''wdim'').*[1.016,1.12];';
	       'thick=xget(''thickness'');xset(''thickness'',2);';
	       'p=wd(2)/wd(1);p=1;';
	       'rx=sz(1)*p/2;ry=sz(2)/2;';
	       'xarcs([orig(1)+0.05*sz(1);';
	       'orig(2)+0.95*sz(2);';
	       '   0.9*sz(1)*p;';
	       '   0.9*sz(2);';
	       '   0;';
	       '   360*64],scs_color(5));';
	       'xset(''thickness'',1);';
	       'xx=[orig(1)+rx    orig(1)+rx;';
	       '    orig(1)+rx    orig(1)+rx+0.6*rx*cos(%pi/6)];';
	       'yy=[orig(2)+ry    orig(2)+ry ;';
	       '  orig(2)+1.8*ry  orig(2)+ry+0.6*ry*sin(%pi/6)];';
	       'xsegs(xx,yy,scs_color(10));';
	       'xset(''thickness'',thick);'],8)
    diagram=scicos_diagram();
    diagram.objs(1)=output_port   
    diagram.objs(2)=evtdly
    diagram.objs(3)=scicos_link(xx=[340;340;380.71],..
				yy=[226.29;172;172],..
				ct=[5,-1],from=[2,1],to=[4,1])  
    diagram.objs(4)=split
    diagram.objs(5)=scicos_link(xx=[380.71;399],yy=[172;172],..
				ct=[5,-1],from=[4,1],to=[1,1])  
    diagram.objs(6)=scicos_link(xx=[380.71;380.71;340;340],..
				yy=[172;302;302;277.71],..
				ct=[5,-1],from=[4,2],to=[2,1]) 
    x=scicos_block()
    x.gui='CLOCK_f'
    x.graphics.sz=[2,2]
    x.graphics.gr_i=gr_i
    x.graphics.peout=0
    x.model.sim='csuper'
    x.model.evtout=1
    x.model.blocktype='h'
    x.model.firing=%f
    x.model.dep_ut=[%f %f]
    x.model.rpar=diagram
  end
endfunction
