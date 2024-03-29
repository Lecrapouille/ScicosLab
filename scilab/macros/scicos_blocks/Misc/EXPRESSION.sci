function [x,y,typ]=EXPRESSION(job,arg1,arg2)
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
  x=arg1
  model=arg1.model;graphics=arg1.graphics;
  exprs=graphics.exprs

  for ii=1:8,execstr('exprs(2)=varnumsubst(exprs(2),'"%u'"+string(ii),'"u'"+string(ii))'),end

  atan2=atan
  while %t do
    %scicos_context=%scicos_context;
    for ii=1:8,execstr('%scicos_context.u'+string(ii)+'=0'),end
    iee=ieee()
    ieee(2)

    [ok,%nin,%exx,%usenz,exprs]=getvalue(..
	['Give a scalar scilab expression using inputs u1, u2,...';
	 'If only one input, input is vector [u1,u2,...] (max 8)';
	 'ex: (dd*u1+sin(u2)>0)*u3';
	 'Note that here dd must be defined in context'],..
	  ['Number of inputs';'Scilab expression';'Use zero-crossing (0: no, 1 yes)'],..
	  list('vec',1,'vec',1,'vec',1),exprs)

    ieee(iee)
    clear %scicos_context

    if ~ok then break,end
    %exx=strsubst(exprs(2),' ','') 
    if %exx==emptystr() then %exx='0',end  //avoid empty
                                                        //expression
							
    if %nin==1 then 
      %nini=8,
    else
      %nini=%nin
    end
    %head='%foo('
    for %jji=1:%nini-1,%head=%head+'u'+string(%jji)+',',end
    %head=%head+'u'+string(%nini)+')'
    ok=execstr('deff(%head,%exx)','errcatch')==0
    if ~ok then
      message(['Erroneous expression';lasterror()])
    else
      if %nin>1 then
	[model,graphics,ok]=check_io(model,graphics,ones(1,%nin),1,[],...
				     [])
      else
	[model,graphics,ok]=check_io(model,graphics,-1,1,[],...
				     [])
      end
      if ok then
	[ok,%ok1,ipar,rpar,%nz]=compiler_expression(%foo)

	if ~ok then
	  message(['Erroneous expression';lasterror()])
	else
	  if %ok1 then
	    model.rpar=rpar
	    model.ipar=ipar
	    if %usenz then
	      model.nzcross=%nz
	      model.nmode=%nz
	    else
	      model.nzcross=0
	      model.nmode=0
	    end
            for ii=1:8
               execstr('exprs(2)=varnumsubst(exprs(2),'"u'"+string(ii),'"%u'"+string(ii))'),
            end
	    graphics.exprs=exprs
	    x.graphics=graphics
	    x.model=model
	    break
	  end
	end
      end
    end
  end
case 'define' then
  in=[1;1]
  out=1
  txt='(u1>0)*sin(u2)^2'
  deff('%foo(u1,u2)',txt)
  [%ok1,ipar,rpar,nz]=compile_expr(%foo)
  model=scicos_model()
  model.sim=list('evaluate_expr',4)
  model.in=in
  model.out=out
  model.rpar=rpar
  model.ipar=ipar
  model.nzcross=nz
  model.nmode=nz
  model.dep_ut=[%t %f]
  for ii=1:8
      execstr('txt=varnumsubst(txt,'"u'"+string(ii),'"%u'"+string(ii))'),
  end
  exprs=[string(size(in,'*'));txt;'1']
  gr_i=['xstringb(orig(1),orig(2),[''Mathematical'';''Expression''],sz(1),sz(2),''fill'');']
  x=standard_define([3 2],model,exprs,gr_i)
end
endfunction

function [ok,%ok1,ipar,rpar,%nz]=compiler_expression(%foo)	
  ok=%t,%ok1=%f,ipar=[],rpar=[],%nz=[]
  if exists('%scicos_context') then
    %mm=getfield(1,%scicos_context)
    for %mi=%mm(3:$)
      if execstr(%mi+'=%scicos_context(%mi)','errcatch')<>0 then
	ok=%f
      end
    end
  end 
  if ok then
    ok=execstr('[%ok1,ipar,rpar,%nz]=compile_expr(%foo)','errcatch')==0
  end
endfunction


function [ok,%ipar,%rpar,%nz]=compile_expr(%foo)
  ok=%t
  atan2=atan  // atan2 not defined in Scilab
  %lst=macr2lst(%foo);
  %mm=macrovar(%foo);
  %MM=%mm(3);
  %FF=['sin';'cos';'tan';'exp';'log';
       'sinh';'cosh';'tanh';
       'int';'round';'ceil';'floor';
       'sign';'abs';'max';'min';
      'asin';'acos';'atan';'asinh';'acosh';'atanh';
       'atan2';
       'log10';
      ]; // ops above 100
  %num_arg=[1;1;1;1;1;
	    1;1;1
	    1;1;1;1;
	    1;1;2;2;
	   1;1;1;1;1;1;
	    2;
	    1
	   ];  //number of arguments
  %ZCR=[16,17,18,19,20,21,28,29,30,109,110,111,112,113,114,115,116];  // ops with zero-crossing
  %UU=%mm(1)
  %ipar=[]
  %rpar=[]
  %nrpar=0
  %nz=0
  %ijk=4
  while %ijk<length(%lst)
    %ijk=%ijk+1
    select evstr(%lst(%ijk)(1))
     case 2
      %jjk=find(%lst(%ijk)(2)==%FF)
      if %jjk<> [] then
	if evstr(%lst(%ijk)(4))<>%num_arg(%jjk) then
	  message(%lst(%ijk)(2)+' must have '+string(%num_arg(%jjk))+' arguments')
	  ok=%f
	  return
	else
	  %ipar=[%ipar;5;100+%jjk]
	  if or(100+%jjk==%ZCR) then %nz=%nz+1,end
	  %ijk=%ijk+1
	end
      else
	%jjk=find(%lst(%ijk)(2)==%MM)
	if %jjk<> [] then
	  if ~exists(%MM(%jjk)) then
	    message('Variable '+%MM(%jjk)+' is not defined.')
	    ok=%f
	    return
	  end
	  %var=evstr(%MM(%jjk))
	  if size(%var,'*')<>1 then
	    message('Variable '+%MM(%jjk)+' is not scalar.')
	    ok=%f
	    return
	  else
	    %nrpar=%nrpar+1
	    %rpar(%nrpar)=%var
	    %ipar=[%ipar;6;%nrpar]
	  end
	else
	  %jjk=find(%lst(%ijk)(2)==%UU)
	  if %jjk<> [] then
	    %ipar=[%ipar;2;%jjk]
	  else
	    message('Unknow variable '+%lst(%ijk)(2))
	    ok=%f
	  end
	  //%ipar=[%ipar;2;evstr(strsubst(%lst(%ijk)(2),'u',''))]
	end
      end
     case 5
      // case of - with one operand (-u1)
      if (evstr(%lst(%ijk)(2))==2)&(evstr(%lst(%ijk)(3))==1) then
	%ipar=[%ipar;5;99]
      else
	%ipar=[%ipar;5;evstr(%lst(%ijk)(2))]
	if or(evstr(%lst(%ijk)(2))==%ZCR) then %nz=%nz+1,end
      end
     case 6
      //      %ipar=[%ipar;6;evstr(%lst(%ijk)(2))]
      %nrpar=%nrpar+1
      %rpar(%nrpar)=evstr(%lst(%ijk)(2))
      %ipar=[%ipar;6;%nrpar]
    end
  end
endfunction
