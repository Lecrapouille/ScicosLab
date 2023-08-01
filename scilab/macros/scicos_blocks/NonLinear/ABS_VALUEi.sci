function [x,y,typ]=ABS_VALUEi(job,arg1,arg2)
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
      [ok,zcr,exprs]=..
	  getvalue(['Set block parameters';'For integer input output types, set zero_crossing to 0'],..
		   ['Use zero_crossing (1: yes) (0:no)'],..
		   list('vec',1),exprs)
      if ~ok then break,end
      graphics.exprs=exprs
      if zcr<>0 then 
	  model.nmode=-1;model.nzcross=-1;
          it=1
       else
	  model.nmode=0;model.nzcross=0;
          it=-1
      end 
      in=[-1,-2];
      [model,graphics,ok]=set_io(model,graphics,list(in,it),list(in,it),[],[])
      if ok
	  x.graphics=graphics;x.model=model
	  break
      end
    end
   case 'compile' then
     model=arg1
     if model.intyp==2 then
        error('Complex data type not implemented.')
     else
        model.sim(1)="absolute_valuei_"+getNameExt(model.intyp)
     end
     if model.nzcross ~= 0 then
       model.nzcross=model.in*model.in2
       model.nmode=model.in*model.in2
     end
     x=model

   case 'define' then
    model=scicos_model()
    model.sim=list('absolute_valuei'+getNameExt(1),4)
    model.in=-1
    model.in2=-2
    model.out=-1
    model.out2=-2
    model.nzcross=-1
    model.nmode=-1
    model.blocktype='c'
    model.dep_ut=[%t %f]
    
    exprs=[string([1])]
    gr_i=['txt=['' |u| ''];';
	  'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
    
    x=standard_define([2 2],model,exprs,gr_i)
  end
endfunction

function txt=getNameExt(i)
  typess=["SCSREAL_COP";
	"SCSCOMPLEX_COP";
	"SCSINT32_COP";
	"SCSINT16_COP";
	"SCSINT8_COP";
	"SCSUINT32_COP";
	"SCSUINT16_COP";
	"SCSUINT8_COP" ];
if argn(2)<1 then 
  txt=typess  
else
  txt=typess(i)
end
endfunction
