function [x,y,typ]=CLKOUTV_f(job,arg1,arg2)
// Copyright INRIA
x=[];y=[];typ=[];
select job
  case 'plot' then
  xf=60;
  yf=40;
  orig=arg1.graphics.orig;
  sz=arg1.graphics.sz;
  orient=arg1.graphics.flip;
  prt=arg1.model.ipar;
  pat=xget('pattern');xset('pattern',default_color(-1));
  thick=xget('thickness');xset('thickness',2);
  x=orig(1)+sz(1)*[1/2;1;  1;0;0  ];
  y=orig(2)+sz(2)*[0;  1/3;1;1;1/3];
  xo=orig(1);yo=orig(2)+sz(2)/3;

  gr_i=arg1.graphics.gr_i;
  if type(gr_i)==15 then 
    coli=gr_i(2);pcoli=xget('pattern');
    xfpolys(x,y,coli);
    xset('pattern',coli);
    xstringb(xo,yo,string(prt),sz(1),sz(2)/1.5);
    xset('pattern',pcoli);
    xstringb(xo,yo,string(prt),sz(1),sz(2)/1.5);
  else
    xstringb(xo,yo,string(prt),sz(1),sz(2)/1.5);
    xpoly(x,y,'lines',1);
  end
  in= [-1/14  1/7
     0      0
     1/14   1/7
     -1/14  1/7]*diag([xf,yf]);
  xfpoly(in(:,1)+ones(4,1)*(orig(1)+sz(1)/2),..
      in(:,2)+ones(4,1)*(orig(2)+sz(2)),1);
  xset('thickness',thick);
  xset('pattern',pat);

  ident = arg1.graphics.id
  if ident <> [] & ident <> '' then
    font=xget('font');
    xset('font', options.ID(1)(1), options.ID(1)(2));
    rectangle = xstringl(orig(1), orig(2), ident);
    w = rectangle(3);
    h = rectangle(4);
    xstringb(orig(1)+sz(1)/2-w/2, orig(2)-3*h/2 , ident , w, h);
    xset('font', font(1), font(2));
  end
  x=[];y=[];
case 'getinputs' then
  orig=arg1.graphics.orig;
  sz=arg1.graphics.sz;
  x=orig(1)+sz(1)/2
  y=orig(2)+sz(2)
  typ=-ones(x) 
case 'getoutputs' then
  x=[];y=[];typ=[];
case 'getorigin' then
  [x,y]=standard_origin(arg1)
case 'set' then
  x=arg1;
  graphics=arg1.graphics;
  model=arg1.model;
  exprs=graphics.exprs;
    while %t do
    [ok,prt,exprs]=getvalue('Set Event Output block parameters',..
	'Port number',list('vec',1),exprs)
    if ~ok then break,end
    prt=int(prt)
    if prt<=0 then
      message('Port number must be a positive integer')
    else
      model.ipar=prt
      model.evtin=1
      graphics.exprs=exprs
      x.graphics=graphics;
      x.model=model
      break
    end
  end
case 'define' then
  prt=1
  model=scicos_model()
  model.sim='output'
  model.evtin=1
  model.ipar=prt
  model.blocktype='d'
  model.firing=[]
  model.dep_ut=[%f %f]

  exprs=string(prt)
  x=standard_define([1 1.5],model,exprs,' ')
end
endfunction
