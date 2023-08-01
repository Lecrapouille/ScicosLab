function [x,y,typ]=TKSWITCH(job,arg1,arg2)
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
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    [ok,ch,inh,exprs]=getvalue('Set manual switch block parameters',..
        ['Initial connected input (1,2)';'Activation inherited (no: 0, yes: 1)'],..
        list('vec',1,'vec',1),exprs)
    if ok then
      if ch>1.5 then ch=2, else ch=1,end
      if inh<>0 then inh=1,end
      in=[-1,-2;-1,-2];out=[-1,-2];
      it=[-1,-1];ot=-1;
      [model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),ones(1-inh,1),[])
      if ok then
        graphics.exprs=exprs
        model.ipar=[ch]
        x.graphics=graphics;x.model=model
      end
    end
    case 'define' then
    ch=1;// default parameter values
    model=scicos_model()
    model.sim=list('tkswitch',5)
    model.in=[-1;-1]
    model.in2=[-2;-2]
    model.intyp=[-1;-1]
    model.out=-1
    model.out2=-2
    model.outtyp=-1
    model.evtin=1
    model.ipar=[ch]
    model.blocktype='d'
    model.dep_ut=[%t %f]
    exprs=[sci2exp(ch);string(0)]
    gr_i=['xstringb(orig(1),orig(2),[''Manual'';''TK'';''Switch''],sz(1),sz(2),''fill'')']
    x=standard_define([2 3],model,exprs,gr_i)
  end
endfunction 







