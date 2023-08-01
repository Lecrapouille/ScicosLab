function [x,y,typ]=AFFICH_m(job,arg1,arg2)
// Copyright INRIA
//** 22 Aug 2006: looking for a nasty "font" bugs 
x=[];y=[];typ=[]

select job

case 'plot' then
  ipar = arg1.model.ipar
  standard_draw(arg1)

case 'getinputs' then
  [x,y,typ]=standard_inputs(arg1)

case 'getoutputs' then
  x=[];y=[];typ=[];

case 'getorigin' then
  [x,y]=standard_origin(arg1)

case 'set' then
  x = arg1;
  graphics = arg1.graphics; exprs = graphics.exprs
  model = arg1.model;
  while %t do
    [ok,in,font,fontsize,colr,nt,nd,herit,exprs]=getvalue(..
         'Set  parameters',..
        ['Input Size',
         'Font number';
         'Font size';
         'Color';
         'Total number of digits';
         'Number of rational part digits';
         'Block inherits (1) or not (0)'],..
         list('mat',[1 2],'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs)

    if ~ok then break,end //user cancel modification

    mess = [] ; //** no message

    if font<=0 then
      mess=[mess;'Font number must be positive';' ']
      ok=%f
    end

    if fontsize<=0 then
      mess=[mess;'Font size must be positive';' ']
      ok=%f
    end

    if nt<=3 then
      mess=[mess;'Total number of digits must be greater than 3';' ']
      ok=%f
    end

    if nd<0 then
      mess=[mess;'Number of rational part digits must be '
                 'greater or equal 0';' ']
      ok=%f
    end

    if ~ok then
      message(['Some specified values are inconsistent:';
               ' ';mess]);
    end

    if ~or(herit==[0 1]) then
      mess=[mess;'Accept inherited values are 0 and 1';' ']
      ok=%f
    end

    if ~ok then
      message(['Some specified values are inconsistent:';
               ' ';mess])
    end

    //** Positive case ->
    if ok then
      //[model,graphics,ok]=check_io(model,graphics,1,[],ones(1-herit,1),[])
      [model,graphics,ok]=set_io(model,graphics,...
                                 list(in,1),list(),...
                                 ones(1-herit,1),[])
    end
    model.ipar=[font;fontsize;colr;xget('window');nt;nd;in(1,1)];
    if ok then
     model.evtin=ones(1-herit,1)
      graphics.exprs=exprs;
      x.graphics=graphics;x.model=model
      break
    end
  end

case 'compile'
   model=arg1
   in=[model.in,model.in2]
   model.ipar(7)=in(1,1)
   model.dstate = [-1;0;0;1;1;zeros(in(1,1)*in(1,2),1)]
   x=model

case 'define' then
  font = 1
  fontsize = 1
  colr = 1
  nt = 5
  nd = 1
  in = [1 1]

  model = scicos_model();
  model.sim = 'affich2' ;
  model.in = in(1,1);
  model.in2 = in(1,2);
  model.evtin  = 1 ;
  model.dstate = [-1;0;0;1;1;zeros(in(1,1)*in(1,2),1)]
  model.ipar   = [font;fontsize;colr;1000;nt;nd;in(1,1)]
  model.blocktype = 'c' ;
  model.firing = []     ;
  model.dep_ut = [%t %f]
  model.label = '' ;

  exprs = [ sci2exp([model.in model.in2]);
            string(font);
            string(fontsize);
            string(colr);
            string(nt);
            string(nd);
            string(0) ]

  gr_i=['if min([model.in,model.in2])>0 then'
        'fnt=xget(''font'')'
        'xset(''font'',ipar(1),ipar(2))';
        'str='' ''+part(''0'',ones(1,ipar(5)-ipar(6)-2))+''.''+part(''0'',ones(1,ipar(6)))'
        'str(1:model.in*model.in2)=str'
        'str=matrix(str,model.in,model.in2)'
        'rr=xstringl(orig(1),orig(2),str)'
        'xstring(orig(1)+max(0,(sz(1)-rr(3))/2),orig(2)+max(0,(sz(2)-rr(4))/2),str)'
        'xset(''font'',fnt(1),fnt(2))'
        'end']

  x = standard_define([3 2],model,exprs,gr_i)

end

endfunction
