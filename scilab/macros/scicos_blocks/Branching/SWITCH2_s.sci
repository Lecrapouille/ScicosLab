function [x,y,typ]=SWITCH2_s(job,arg1,arg2)
  x=[];y=[];typ=[]
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
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,ot,rule,thra,nzz,exprs]=getvalue(['Set parameters';'Zero-crossing must be set to zero for non real control inputs'],..
		['Output datatype (-1=inherit 1=real double  2=complex 3=int32 ...)';'Pass first input if: u2>=a (0), u2>a (1), u2~=a (2)';..
		    'Threshold a';'Use zero crossing: yes (1), no (0)'],..
		    list('vec',1,'vec',1,'vec',-1,'vec',1),exprs)
      if ~ok then break,end
      rule=int(rule);
      if (rule<0) then rule=0, end
      if (rule>2) then rule=2, end
      graphics.exprs=exprs;
      model.ipar=rule
      model.rpar=thra
      if nzz<>0 then 
	model.nmode=1
	model.nzcross=1
        it2=1
      else
	model.nmode=0
	model.nzcross=0
        it2=-2
      end
      if ((ot<1)|(ot>8))&(ot<>-1) message("Datatype is not supported");ok=%f;end
      if ok then
	it(1)=ot;
	it(2)=it2;
	it(3)=ot;
        if size(thra,"*")>1 then
          in1=size(thra);in1=in1(:)
          in=[in1,in1,in1]'
          out=in1'
        else
          in=[-1 -3 -1;-2 -4 -2]'
          out=[-1;-2]'
        end
        [model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),[],[])
      end
      if ok then
        x.graphics=graphics;x.model=model
        break
      end
    end
   case 'compile' then
     model=arg1
     it2=model.intyp(2)
     ot=model.outtyp(1)
     if ~((model.in(1)==model.in(2)&model.in2(1)==model.in2(2))|(model.in(2)*model.in2(2)==1)) then
       error('Control input has wrong dimensions.')
     end
     if size(model.rpar,'*')==1 then
       model.rpar(1:model.in(2),1:model.in2(2))=model.rpar
     end
     model.nzcross=model.nzcross*model.in(2)*model.in2(2)
     model.nmode=model.nzcross
     if it2>8 then 
       it2=3  // use int32 for boolean
     end
     if it2 > 1 then
       model.opar=list(CastToScicosType(model.rpar,it2))
       model.rpar=[]
       model.sim(1)="switch2_"+getNameExtSwitch(it2)
    end
    x=model

   case 'define' then
    ipar=[0] // rule
    nzz=1
    rpar=0
    
    model=scicos_model()
    model.sim=list('switch2_'+getNameExtSwitch(1),4)
    model.in=[-1;1;-1]
    model.in2=[-2;1;-2]
    model.intyp=1
    model.out=-1
    model.out2=-2
    model.outtyp=1
    model.ipar=ipar
    model.rpar=rpar
    model.nzcross=nzz
    model.nmode=1
    model.blocktype='c'
    model.dep_ut=[%t %f]
    
    exprs=[sci2exp(1);string(ipar);string(rpar);string(nzz)]
    
    gr_i=['xstringb(orig(1),orig(2),[''switch''],sz(1),sz(2),''fill'');']
    x=standard_define([2 2],model,exprs,gr_i)
  end
endfunction


function txt=getNameExtSwitch(i)

  typess=["SCSREAL_COP";
	"SCSCOMPLEX_COP";
	"SCSINT32_COP";
	"SCSINT16_COP";
	"SCSINT8_COP";
	"SCSUINT32_COP";
	"SCSUINT16_COP";
	"SCSUINT8_COP" ];

    txt=typess(i)
endfunction
