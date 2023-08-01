function [x,y,typ]=LOGICAL_OP(job,arg1,arg2)
x=[];y=[];typ=[]
select job
case 'plot' then
  VOP=['AND', 'OR', 'NAND', 'NOR', 'XOR', 'NOT', 'NXOR']
  OPER=VOP(evstr( arg1.graphics.exprs(2))+1)
  standard_draw(arg1)
case 'getinputs' then
  [x,y,typ]=standard_inputs(arg1)
case 'getoutputs' then
  [x,y,typ]=standard_outputs(arg1)
case 'getorigin' then
  [x,y]=standard_origin(arg1)
case 'set' then
  x=arg1;
  graphics=arg1.graphics;exprs=graphics.exprs
  model=arg1.model;
  if size(exprs,1)==2 then exprs=[exprs;sci2exp(1);sci2exp(0)];end
  while %t do
    [ok,nin,rule,Datatype,tp,exprs]=getvalue('Set parameters',..
	['Number of inputs';..
	 'Operator: AND (0), OR (1), NAND (2), NOR (3), XOR (4), NOT (5), NXOR (6)'
         'Datatype (-1=inherit 1=double 3=int32 ...)';..
         'Bitwise Rule(0=No 1=yes)'],..
	list('vec',1,'vec',1,'vec',1,'vec',1),exprs)
    if ~ok then break,end
    nin=int(nin);rule=int(rule);tp=int(tp)
    if nin<1 then
      message('Number of inputs must be >=1 ');ok=%f
    elseif (rule<0)|(rule>6) then
      message('Incorrect operator '+string(rule)+' ; must be 0 to 6.');ok=%f
    elseif (rule==5)&(nin>1) then
      message('Only one input allowed for NOT operation')
      nin=1
    elseif ((Datatype==1)&(tp~=0))
      message("Bitwise Rule applies only if Data type is integer");ok=%f
    end
    if ok then
      if (tp~=0) then tp=1; end
      model.ipar=[rule;tp];
      if ok then
	it=Datatype*ones(nin,1);
	ot=Datatype;
	in=[-ones(nin,1) -2*ones(nin,1)]
      	if (rule<>5)&(nin==1) then
	    out=[1 1]
	    [model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),[],[])
        else
	    out=[-1 -2]
	    [model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),[],[])
        end
      end
      if ok then
	graphics.exprs=exprs;
	x.graphics=graphics;x.model=model
	break
      end
    end
  end

case 'compile' then
   model=arg1
   Datatype= model.outtyp
   if Datatype==1 then
     model.sim=list('logicalop',4)
     if size(model.ipar,'*')>1 then
       if model.ipar(2)==1 then
          error("Bitwise Rule applies only when Data type is integer")
       end
     end
     model.ipar=model.ipar(1)
   else
     if Datatype==3|Datatype==9 then
	  model.sim=list('logicalop_i32',4)
     elseif Datatype==4 then
	  model.sim=list('logicalop_i16',4)
     elseif Datatype==5 then
	  model.sim=list('logicalop_i8',4)
     elseif Datatype==6 then
	  model.sim=list('logicalop_ui32',4)
     elseif Datatype==7 then
	  model.sim=list('logicalop_ui16',4)
     elseif Datatype==8 then
	  model.sim=list('logicalop_ui8',4)
     else
          error("Datatype '+string(Datatype)+'is not supported")
     end
   end

   x=model

case 'define' then
  in=[-1;-1]
  ipar=[0;0]
  nin=2
  
  model=scicos_model()
  model.sim=list('logicalop',4)
  model.in=in
  model.out=-1
  model.ipar=ipar
  model.blocktype='c'
  model.dep_ut=[%t %f]
  
  exprs=[string(nin);string(ipar);string(1);string(0)]
  gr_i=['xstringb(orig(1),orig(2),[''Logical Op'';OPER],sz(1),sz(2),''fill'');']
  x=standard_define([2.5 2],model,exprs,gr_i)
end
endfunction
