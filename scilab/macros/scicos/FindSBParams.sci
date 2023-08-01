function [ok,params,param_types]=FindSBParams(scs_m,params)
// Copyright INRIA
  prot = funcprot();
  funcprot(0);
  deff('varargout=getvalue(a,b,c,d)',..
    ['global par_types'
     'par_types=c'
     'x=1;y=x(2)'])
  funcprot(prot);
  param_types=list()
  global par_types

  Fun=scs_m.props.context;
  [%scicos_context,ierr] = script2var(Fun,%scicos_context);
  if ierr<>0 then
    message(['Error occur when evaluating context:' lasterror()])
    ok=%f
  end
  for i=1:size(scs_m.objs)
    o=scs_m.objs(i);
    if typeof(o)=='Block' then
      if o.gui<>'PAL_f' then
        model=o.model;
        if model.sim=='super'|((model.sim=='csuper')&(model.ipar<>1))|model.sim(1)=='asuper' then
	  [ok,pparams]=FindSBParams(model.rpar,params);
	  if ~ok then return;end
          Funi='['+pparams+']'
        else
          if typeof(o.graphics.exprs)=="MBLOCK" then //modelica block
            Funi=[];
            for j=1:lstsize(o.graphics.exprs.paramv)
               Funi=[Funi;
                     '['+o.graphics.exprs.paramv(j)+']'];
            end
          else
            if type(o.graphics.exprs)==15 then
              Funi='['+o.graphics.exprs(1)(:)+']';
            else
              Funi='['+o.graphics.exprs(:)+']';
            end
            par_types=[];
            execstr('blk='+o.gui+'(''define'')')
            execstr(o.gui+'(''set'',blk)','errcatch')

            Del=[];kk=1;
            for jj=1:2:length(par_types)
              if par_types(jj)=='str' then Del=[Del,kk],end
              kk=kk+1
            end
            Funi(Del)=[]
          end
        end
        Fun=[Fun;Funi]
      end
    end
  end
  [params,ok]=GetLitParam(Fun,%t)
  if ~ok then return;end
  for X=params'
    select evstr('type(%scicos_context.'+X+')')
    case 1
      param_types($+1)='pol'
      param_types($+1)=-1
    case 2
      param_types($+1)='pol'
      param_types($+1)=-1
    case 8
      param_types($+1)='mat'
      param_types($+1)=[-1,-1]
    case 15
      param_types($+1)='lis'
      param_types($+1)=-1
    case 16
      param_types($+1)='lis'
      param_types($+1)=-1
    case 17
      param_types($+1)='lis'
      param_types($+1)=-1
    else
      param_types($+1)='gen'
      param_types($+1)=-1
    end
  end
//  clearglobal('par_types')  //recursive call, so it cannot be cleared here
endfunction

