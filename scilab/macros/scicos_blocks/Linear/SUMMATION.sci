function [x,y,typ]=SUMMATION(job,arg1,arg2)
// Copyright INRIA
x=[];y=[];typ=[];
select job
case 'plot' then
  sgn=arg1.model.ipar
  standard_draw(arg1)
case 'getinputs' then
  [x,y,typ]=standard_inputs(arg1)
case 'getoutputs' then
  [x,y,typ]=standard_outputs(arg1)
case 'getorigin' then
  [x,y]=standard_origin(arg1)
case 'set' then
  x=arg1;
  graphics=arg1.graphics
  model=arg1.model
  exprs=graphics.exprs
  if size(exprs,1)==1 then exprs=[sci2exp(1);exprs;sci2exp(0)];
  elseif size(exprs,1)==2 then exprs=[exprs;sci2exp(0)]; end
  while %t do
    [ok,Datatype,sgn,satur,exprs]=getvalue('Set sum block parameters',..
			    ['Datatype (-1=inherit 1=real double  2=complex 3=int32 ...)';..
                             'Number of inputs or sign vector (of +1, -1)';..
			     'Do on Overflow(0=Nothing 1=Saturate 2=Error)'],..
                             list('vec',1,'vec',-1,'vec',1),exprs)
    if ~ok then break,end
    sgn=sgn(:);
    if (satur~=0&satur~=1&satur~=2) then message("Do on overflow must be 0,1,2");ok=%f;end
    if size(sgn,1)==1 then 
      if sgn<1 then
	message('Number of inputs must be > 0')
	ok=%f
      elseif sgn==1 then
	in=-1;in2=-2
	sgn=[]
	nout=1;nout2=1
      else
	in=-ones(sgn,1);in2=2*in
	sgn=ones(sgn,1)
	nout=-1;nout2=-2
      end
    else
      if ~and(abs(sgn)==1) then
	message('Signs can only be +1 or -1')
	ok=%f
      else
	in=-ones(size(sgn,1),1);in2=2*in
	nout=-1;nout2=-2
      end
    end
    if ok then
      it=Datatype*ones(1,size(in,1));
      ot=Datatype;
      [model,graphics,ok]=set_io(model,graphics,...
                                 list([in,in2],it),...
                                 list([nout,nout2],ot),[],[])
    end
    if ok then
      model.rpar=satur;
      model.ipar=sgn
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
  end

case 'compile' then
    model=arg1
    satur=model.rpar
    model.rpar=[]
    Datatype=model.outtyp(1)
    if Datatype==1 then 
       model.sim=list('summation',4)
    elseif Datatype==2 then
       model.sim=list('summation_z',4)
    elseif Datatype>8 then
	 error("Datatype is not supported");
    else
    	if satur==0 then
	    if Datatype==3 then
		model.sim=list('summation_i32n',4)
	    elseif Datatype==4 then
		model.sim=list('summation_i16n',4)
	    elseif Datatype==5 then
		model.sim=list('summation_i8n',4)
	    elseif Datatype==6 then
		model.sim=list('summation_ui32n',4)
	    elseif Datatype==7 then
		model.sim=list('summation_ui16n',4)
	    elseif Datatype==8 then
		model.sim=list('summation_ui8n',4)
	    end
    	elseif satur==1 then
	    if Datatype==3 then
		model.sim=list('summation_i32s',4)
	    elseif Datatype==4 then
		model.sim=list('summation_i16s',4)
	    elseif Datatype==5 then
		model.sim=list('summation_i8s',4)
	    elseif Datatype==6 then
		model.sim=list('summation_ui32s',4)
	    elseif Datatype==7 then
		model.sim=list('summation_ui16s',4)
	    elseif Datatype==8 then
		model.sim=list('summation_ui8s',4)
	    end
    	elseif satur==2 then
	    if Datatype==3 then
		model.sim=list('summation_i32e',4)
	    elseif Datatype==4 then
		model.sim=list('summation_i16e',4)
	    elseif Datatype==5 then
		model.sim=list('summation_i8e',4)
	    elseif Datatype==6 then
	 	model.sim=list('summation_ui32e',4)
	    elseif Datatype==7 then
		model.sim=list('summation_ui16e',4)
	    elseif Datatype==8 then
		model.sim=list('summation_ui8e',4)
	    end
    	end
    end
    x=model


case 'define' then
  sgn=[1;-1]
  model=scicos_model()
  model.sim=list('summation',4)
  model.in=[-1;-1]
  model.out=-1
  model.in2=[-2;-2]
  model.out2=-2
  model.ipar=sgn
  model.blocktype='c'
  model.dep_ut=[%t %f]

  
  exprs=sci2exp(sgn)
  gr_i=['[x,y,typ]=standard_inputs(o) ';
	'dd=sz(1)/8,de=0,'
	'if ~arg1.graphics.flip then dd=6*sz(1)/8,de=-sz(1)/8,end'
	'for k=1:size(x,''*'')';
	'if size(sgn,1)>1 then'
	'  if sgn(k)>0 then';
	'    xstring(orig(1)+dd,y(k)-4,''+'')';
	'  else';
	'    xstring(orig(1)+dd,y(k)-4,''-'')';
	'  end';
	'end';
	'end';
	'xx=sz(1)*[.8 .4 0.75 .4 .8]+orig(1)+de';
	'yy=sz(2)*[.8 .8 .5 .2 .2]+orig(2)';
	'xpoly(xx,yy,''lines'')']
  x=standard_define([2 3],model, exprs,gr_i)
end
endfunction
