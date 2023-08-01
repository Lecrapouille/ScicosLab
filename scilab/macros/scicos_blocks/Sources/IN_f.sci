function [x,y,typ]=IN_f(job,arg1,arg2)
// Copyright INRIA
x=[];y=[];typ=[]
select job
case 'plot' then

  orig=arg1.graphics.orig;
  sz=arg1.graphics.sz;
  orient=arg1.graphics.flip;

  prt=arg1.model.ipar
  pat=xget('pattern');xset('pattern',default_color(1))
  thick=xget('thickness');xset('thickness',2)

 


  if orient then
    x=orig(1)+sz(1)*[-1/6;-1/6;1/1.5;1;1/1.5]
    y=orig(2)+sz(2)*[0;1;1; 1/2;0]
    xo=orig(1);yo=orig(2)
  else
    x=orig(1)+sz(1)*[0;1/3;7/6;7/6;1/3]
    y=orig(2)+sz(2)*[1/2;1;1;0;0]
    xo=orig(1)+sz(1)/3;yo=orig(2)
  end
  gr_i=arg1.graphics.gr_i;
  if type(gr_i)==15 then 
    coli=gr_i(2);
//    pcoli=xget('pattern')
    xfpolys(x,y,coli);
//    xset('pattern',coli)
//    xstringb(xo,yo,string(prt),sz(1)/1.5,sz(2))
//    xset('pattern',pcoli)
    xstringb(xo,yo,string(prt),sz(1)/1.5,sz(2))
  else
    xstringb(xo,yo,string(prt),sz(1)/1.5,sz(2))
    xpoly(x,y,'lines',1)
  end
  xset('thickness',thick)
  xset('pattern',pat)
  
  ident = arg1.graphics.id

  if ident <> [] then
    font=xget('font')
    xset('font', options.ID(1)(1), options.ID(1)(2))
    rect=[orig(1) orig(2) orig(1)+sz(1) orig(2)+sz(2)]
    ident = arg1.graphics.id
    rectstr = stringbox(ident, rect(1,1), rect(1,2), 0,...
                    options.ID(1)(1), options.ID(1)(2));
    w=(rectstr(1,3)-rectstr(1,2)) * %zoom;
    h=(rectstr(2,2)-rectstr(2,4)) * %zoom;
    xstringb(orig(1) + sz(1) / 2 - w / 2,..
      rect(1,2) - (h*1.1) , ident , w, h,'fill') ;
    xset('font', font(1), font(2))
  end
  x=[];y=[]
case 'getinputs' then
  x=[];y=[];typ=[]
  case 'getoutputs' then
  orig=arg1.graphics.orig;
  sz=arg1.graphics.sz;
  orient=arg1.graphics.flip;

  if orient then
    x=orig(1)+sz(1)
    y=orig(2)+sz(2)/2
  else
    x=orig(1)
    y=orig(2)+sz(2)/2
  end
  typ=ones(x)
case 'getorigin' then
  [x,y]=standard_origin(arg1)
case 'set' then
  x=arg1;
  graphics=arg1.graphics;
  model=arg1.model;
  exprs=graphics.exprs;
  if size(exprs,'*')==2 then exprs=exprs(1),end //old compatibility
  if size(exprs,'*')==1 then exprs=[exprs(1);'-1';'-1'],end //compatibility
  while %t do
    [ok,prt,otsz,ot,exprs]=getvalue('Set Input block parameters',..
	['Port number';'Outport Size (-1 for inherit)';'Outport Type (-1 for inherit)'],list('vec',1,'vec',-1,'vec',1),exprs)
    if ~ok then 
      // change port number in any case
       if execstr('prti=evstr(graphics.exprs(1))','errcatch')==0 then
        model.ipar=prti
        x.model=model
       end
       break,
    end
    prt=int(prt)
    if prt<=0 then
      message('Port number must be a positive integer')
    elseif ~isequal(size(otsz,'*'),2) & ~isequal(otsz,-1) then 
      message('Outport Size must be a 2 elements vector or -1 for inheritence')
    elseif ((ot<1|ot>9)&(ot<>-1)) then
      message('Outport type must be a number between 1 and 9, or -1 for inheritance.')
    else
      if model.ipar<>prt then needcompile=4;y=needcompile,end
      model.ipar=prt
      model.firing=[];
      if size(otsz,'*')==2 then
	model.out=otsz(1)
	model.out2=otsz(2)
      else
	model.out=-1;model.out2=-2
      end
      model.outtyp=ot;
      graphics.exprs=exprs
      x.graphics=graphics
      x.model=model
      break
    end
  end
case 'define' then
  in=-1
  prt=1
  model=scicos_model()
  model.sim='input'
  model.out=-1
  model.out2=-2
  model.outtyp=-1
  model.ipar=prt
  model.blocktype='c'
  model.dep_ut=[%f %f]

  exprs=[sci2exp(prt);'-1';'-1']
  gr_i=' '
  x=standard_define([1 1],model,exprs,gr_i)
end
endfunction
