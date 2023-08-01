function [x,y,typ]=WhileIterator(job,arg1,arg2)
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
  model=arg1.model;graphics=arg1.graphics;exprs=graphics.exprs
  while %t do
    [ok,nbre_iter,w_typ,resetstate,ext_out,iter_dtype,exprs]=..
	getvalue('While Iterator parameters',..
	[
	'Number of Iteration (-1 : unlimited)';
	'While type (1=while 0=do while)';
	'State when starting (0=held 1=reset)';
	'Show iteration variable(0=No 1=Yes)';
	'Iteration Datatype (1=Double 3=int32 4=int16 5=int8)'],..
	list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs);
    if ~ok then break,end
    if and(w_typ<>[0,1]) then message('While type must be zero or one');ok=%f;
    elseif and(ext_out<>[0,1]) then message('Show Iteration Variable must be zero or one');ok=%f;
    elseif and(iter_dtype<>[1,3,4,5]) then message('Data type must be one three four five');ok=%f;
    elseif ((nbre_iter<-1)|(nbre_iter<>floor(nbre_iter))) then message(['Number of Iteration must be:';'  * an integer greater than 0';' * -1']);ok=%f;
    elseif and(resetstate<>[0,1]) then message('State when starting must be zero or one');ok=%f; 
    end
    if ok then
      out=ones(ext_out,2);
      ot=iter_dtype*ones(size(out,1),1);
      in=[[1 1];ones(w_typ,2)];
      it=iter_dtype*ones(size(in,1),1);
      [model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),[],[])
      if ok then
	//if ((size(old_in,'*')<>size(in(:,1),'*')) | old_ext_i<>ext_i) then graphics.pin=zeros(size(in,1),1);end
	vv=['double','','int32','int16','int8']
	execstr('model.odstate=list('+vv(iter_dtype)+'(1))');
	graphics.exprs=exprs;
	model.ipar=[];
	x.model=model;x.graphics=graphics;
	break;
      end
    end
  end
case 'define' then
  model=scicos_model()
  junction_name='whileiterator';
  funtyp=4;
  model.sim=list(junction_name,funtyp)

  model.in=[1;1]
  model.in2=[1;1]
  model.intyp=[1;1]

  model.out=[]
  model.out2=[]
  model.outtyp=[]
  model.evtin=[];
  model.evtout=[]
  model.state=[]
  model.dstate=[];
  model.odstate=list(1);
  model.rpar=[]
  model.ipar=[]
  model.blocktype='d' 
  model.firing=[]
  model.dep_ut=[%f %f]
  exprs=['5';'1';'0';'0';'1']
  gr_i=[
      '[x,y,typ]=standard_inputs(o) ';
      'dd=sz(1)/16,de=2*sz(1)/8;';
      'if ~arg1.graphics.flip then dd=6*sz(1)/8;de=sz(1)/16;end';
      'if ~exists(''%zoom'') then %zoom=1, end;'
      'for k=1:size(x,''*'')';
	' if typ(k)==1';
	  'if k==1 then'
	    '    txt=''Cond'';';
	  'else'
	    '    txt=''IC'';';
	  'end';
	  'rectstr=stringbox(txt,orig(1)+dd,y(k)-4,0,1,1);'
	  'w=(rectstr(1,3)-rectstr(1,2))*%zoom;'
	  'h=(rectstr(2,2)-rectstr(2,4))*%zoom;'
	  'xstringb(orig(1)+dd,y(k)-4,txt,w,h,''fill'')';
	'end';
      'end';
      'if arg1.graphics.exprs(2)==''1'' then';
	'   xstringb(orig(1)+de,orig(2),[''     while {'';''   ....  '';''}     ''],3*sz(1)/4,sz(2),''fill'');';
      'else'; 
	'   xstringb(orig(1)+de,orig(2),[''     do {'';''   ....  '';''} while  ''],3*sz(1)/4,sz(2),''fill'');';
      'end';]
  
  x=standard_define([4 2],model,exprs,gr_i)
end
endfunction

