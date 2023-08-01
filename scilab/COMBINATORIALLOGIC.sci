function [x,y,typ]=COMBINATORIALLOGIC(job,arg1,arg2)
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
    x=arg1;
    graphics=arg1.graphics;
    exprs=graphics.exprs;
    model=arg1.model;

    while %t do
      [ok,mat,inh,exprs]=getvalue('Set Combinatorial Logic block parameters',...
                                  ['Truth table';'Inherit (no:0, yes:1)'],...
                                  list('mat',[-1 -2],'vec',1),exprs);
      if ~ok then break, end
      
      if isempty(mat) | isempty(inh) then
        message("Parameters can''t be empty.");
        ok=%f;
      end
      if ok then
        in1=log(size(mat,1))/log(2)
        if (in1<>int(in1)) then
          message ("The number of rows of the truth table must be a power of two.");
          ok=%f;
        end
      end
      if ok then
        in=[in1 1];
        out=[size(mat,2) 1];
        ot=do_get_type(mat);
        if (inh<>0) then inh=1, end;
        [model,graphics,ok]=set_io(model,graphics,list(in,-1),list(out,ot),ones(1-inh,1),[]);
      end
      if ok then
        model.opar=list(mat);
        graphics.exprs=exprs;
        x.graphics=graphics;
        x.model=model;
        break;
      end
    end
    
   case 'compile'
    model=arg1;
    if model.intyp==2 then
      error("Complex data type not implemented.");
    else
      model.sim(1)="logic2_"+getNameExt(model.intyp)+"_"+getNameExt(model.outtyp)
    end
    x=model;

   case 'define' then
    mat=[0;0;0;1]
    inh=0
    exprs=[sci2exp(mat);sci2exp(inh)]
    model=scicos_model()
    model.sim=list('logic2_'+getNameExt(1)+'_'+getNameExt(1),4)
    model.in=log(size(mat,1))/log(2)
    model.in2=1
    model.intyp=-1
    model.out=size(mat,2)
    model.out2=1
    model.outtyp=do_get_type(mat)
    model.evtin=1-inh
    model.opar=list(mat)
    model.blocktype='c'
    model.dep_ut=[%t %f]

    gr_i='xstringb(orig(1),orig(2),['' [...] ''],sz(1),sz(2),''fill'')'
    x=standard_define([2 2],model,exprs,gr_i);//,'COMBINATORIALLOGIC')
    x.graphics.id=["Combinatorial";"      Logic"]
  end
endfunction

function txt=getNameExt(i)
  [lhs,rhs]=argn(0)
  typess=["SCSREAL_COP";
	  "SCSCOMPLEX_COP";
	  "SCSINT32_COP";
	  "SCSINT16_COP";
	  "SCSINT8_COP";
	  "SCSUINT32_COP";
	  "SCSUINT16_COP";
	  "SCSUINT8_COP" ];
  if rhs < 1 then 
    txt=typess  
  else
    txt=typess(i)
  end
endfunction
