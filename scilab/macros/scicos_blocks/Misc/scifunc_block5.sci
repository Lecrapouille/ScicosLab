function [x,y,typ]=scifunc_block5(job,arg1,arg2)
x=[];
y=[];
typ=[];
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
  x=arg1
  model=arg1.model;
  graphics=arg1.graphics;
  label=graphics.exprs
  while %t do
    [ok,junction_name,impli,in,it,out,ot,ci,co,xx,z,oz,...
     rpar,ipar,opar,nmode,nzcr,auto0,depu,dept,lab]=..
        getvalue('Set Scilab block parameters',..
        ['Simulation function name';
         'Is block implicit? (y,n)';
         'Input ports sizes';
         'Input ports type';
         'Output port sizes';
         'Output ports type';
         'Input event ports sizes';
         'Output events ports sizes';
         'Initial continuous state';
         'Initial discrete state';
         'Initial object state';
         'Real parameters vector';
         'Integer parameters vector';
         'Object parameters list';
         'Number of modes';
         'Number of zero crossings';
         'Initial firing vector (<0 for no firing)';
         'Direct feedthrough (y or n)';
         'Time dependence (y or n)'],..
         list('str',1,'str',1,'mat',[-1 2],'vec',-1,'mat',[-1 2],'vec',-1,'vec',-1,'vec',-1,..
         'vec',-1,'vec',-1,'lis',-1,'vec',-1,'vec',-1,'lis',-1,'vec',1,'vec',1,'vec','sum(%8)',..
         'str',1,'str',1),label(1))
    if ~ok then break,end

    label(1)=lab
    junction_name=stripblanks(junction_name)
    xx=xx(:);z=z(:);rpar=rpar(:);ipar=int(ipar(:));
    nx=prod(size(xx,'*'))
    ci=int(ci(:));
    co=int(co(:));
    if part(impli,1)=='y' then
      funtyp=10005
      if ~isempty(xx) then
        if int(nx/2)*2<>nx then
          message(['Warning for implicit block initial derivative state should also be defined.';
                   'Please check number of Initial continuous state.']);
          ok=%f;
        end
      end
    else
      funtyp=5
    end
    if [ci;co]<>[] then
      if maxi([ci;co])>1 then message('vector event links not supported');ok=%f;end
    end
    if type(opar)<>15 then message('object parameter must be a list');ok=%f;end
    if type(oz)<>15 then message('discrete object state must be a list');ok=%f;end

    if ok then
      depu=stripblanks(depu);if part(depu,1)=='y' then depu=%t; else depu=%f;end
      dept=stripblanks(dept);if part(dept,1)=='y' then dept=%t; else dept=%f;end
      dep_ut=[depu dept];
      [model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),ci,co)
    end

    //@@
    if ok then
      nz=prod(size(z,'*'))+lstsize(oz)
      ni=prod(size(in,'*'))
      no=prod(size(out,'*'))
      nie=prod(size(ci,'*'))
      noe=prod(size(co,'*'))

      [ok,func_txt]=genfunc5(junction_name,label(2),ni,no,nie,noe,nx,nz,nzcr)

      if ok then
        if or(func_txt<>label(2)) then needcompile=4, end
        model.sim=list('scifunc',funtyp);
        model.state=xx
        model.dstate=z
        model.odstate=oz
        model.rpar=rpar
        model.ipar=ipar
        model.opar=opar
        model.firing=auto0
        model.nzcross=nzcr
        model.nmode=nmode
        model.dep_ut=dep_ut
        arg1.model=model
        label(2)=func_txt
        graphics.exprs=label
        arg1.graphics=graphics
        x=arg1
        needcompile=resume(needcompile)
        //break
      end
    end
  end
case 'define' then
  model=scicos_model()
  junction_name='sciblk';
  funtyp=5;
  model.sim=list('scifunc',funtyp)

  model.in=1
  model.in2=1
  model.intyp=1
  model.out=1
  model.out2=1
  model.outtyp=1
  model.dep_ut=[%t %f]
  label=list([junction_name;'n';
              sci2exp([model.in model.in2]);
              sci2exp(model.intyp);
              sci2exp([model.out model.out2])
              sci2exp(model.outtyp);
              sci2exp(model.evtin);
              sci2exp(model.evtout);
              sci2exp(model.state);
              sci2exp(model.dstate);
              sci2exp(model.odstate);
              sci2exp(model.rpar);
              sci2exp(model.ipar);
              sci2exp(model.opar);
              sci2exp(model.nmode);
              sci2exp(model.nzcross);
              sci2exp(model.firing);
              'y';
              'n'],...
              []);
  gr_i=['xstringb(orig(1),orig(2),''SciBlk'',sz(1),sz(2),''fill'');']
  x=standard_define([2 2],model,label,gr_i)
end
endfunction

