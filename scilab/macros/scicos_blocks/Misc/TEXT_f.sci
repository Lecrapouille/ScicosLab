function [x,y,typ]=TEXT_f(job,arg1,arg2)
// Copyright INRIA
//** 22-23 Aug 2006: some carefull adjustements for the fonts
//**                 inside the new graphics datastructure  
x=[]; y=[]; typ=[];

select job

case 'plot' then //normal  position
  graphics = arg1.graphics; 
  model    = arg1.model;
  
  if model.rpar==[] then
      model.rpar=graphics.exprs(1)
  end //compatibility
  
  //** save the previous parameter 
  //** ppat    = xget('pattern'); //** Get the current pattern or the current color.
  //** oldfont = xget('font')   ; //** Get font=[fontid,fontsize] .
  gh_winpal = gca(); //** get the current Axes proprieties 
 
  default_font_style = gh_winpal.font_style ;
  default_font_size  = gh_winpal.font_size  ;
  default_font_color = gh_winpal.font_color ;
  
  //** set the new parameters 
  //** xset('font',model.ipar(1),model.ipar(2))
  gh_winpal.font_style = model.ipar(1) ; 
  gh_winpal.font_size  = model.ipar(2) ;
  
  //@@ compute bbox
  rect = stringbox(model.rpar, graphics.orig(1), graphics.orig(2));

  w=(rect(1,3)-rect(1,2)) * %zoom;
  h=(rect(2,2)-rect(2,4)) * %zoom/1.4 * 1.2;

  //** special case for Windows 
  if MSDOS then
    //** xset('pattern',scs_m.props.options.Background(1))
    gh_winpal.font_color = scs_m.props.options.Background(1) ;
    
    //@@ fill txt_index in a box
    xstringb(rect(1,1),rect(2,1), model.rpar, w, h,'fill') ;

    //xstring(graphics.orig(1),graphics.orig(2),model.rpar)
  end
  
  //** set the new parameters 
  //** xset('pattern', default_color(1))  ;
  gh_winpal.font_color = default_color(1) ;
  
  //@@ fill txt_index in a box
  xstringb(rect(1,1),rect(2,1), model.rpar, w, h,'fill') ;

  //** print the string 
  //xstring(graphics.orig(1), graphics.orig(2), model.rpar)
  
  //** restore the old settings 
  //** xset('font',oldfont(1),oldfont(2))
  //** xset('pattern',ppat)
  gh_winpal.font_style = default_font_style ;
  gh_winpal.font_size  = default_font_size  ;
  gh_winpal.font_color = default_font_color ; 
   
case 'getinputs' then

case 'getoutputs' then

case 'getorigin' then
  [x,y] = standard_origin(arg1)

case 'set' then
  x = arg1 ;
  graphics = arg1.graphics ;
  orig  = graphics.orig  ;
  exprs = graphics.exprs ;
  model = arg1.model ;
  if size(exprs,'*')==1 then
       exprs = [exprs;'3';'1']
  end // compatibility
  
  while %t do
    [ok,txt,font,siz,exprs] = getvalue('Set Text block parameters',..
	['Text';'Font number';'Font size'], list('str',-1,'vec',1,'vec',1),exprs)
    
    if ~ok then break,end //** 
    
    if font<=0|font>6 then
      message('Font number must be greater than 0 and less than 7')
      ok=%f
    end
    
    if siz<0 then
      message('Font size must be positive')
      ok=%f
    end
    
    if ok then
      graphics.exprs = exprs
      
      //** save the font 
      //** oldfont = xget('font')
      gh_winpal = gca(); //** get the current Axes proprieties 
      default_font_style = gh_winpal.font_style ;
      default_font_size  = gh_winpal.font_size  ;
      default_font_color = gh_winpal.font_color ;
      
      //** set the new font 
      //** xset('font',font,siz)
      gh_winpal.font_style = font ; 
      gh_winpal.font_size  = siz  ;
      
      
      //** store the box coordinate that contains the string
      r = xstringl(0,0,exprs(1),evstr(exprs(2)),evstr(exprs(3)));
      
      //** restore the old font 
      //** xset('font',oldfont(1),oldfont(2));
      gh_winpal.font_style = default_font_style ;
      gh_winpal.font_size  = default_font_size  ;
      gh_winpal.font_color = default_font_color ; 

      txt=tomultline(txt)

      sz = r(3:4) ; 
      graphics.sz = sz        ;
      x.graphics  = graphics  ;
      ipar        = [font;siz]
      model.rpar  = txt   ;
      model.ipar  = ipar  ;
      x.model     = model ;
      break
    end
    
  end //** of while 
   
  
case 'define' then
  font = 2 ;
  siz  = 1 ;
 
  model = scicos_model()
  model.sim = 'text'
  model.rpar= 'Text'
  model.ipar=[font;siz]

  exprs = ['Text';string(font); string(siz)]
  graphics = scicos_graphics();
  graphics.orig = [0,0];
  graphics.sz =[2 1];
  graphics.exprs = exprs


  x = mlist(['Text','graphics','model','void','gui'],graphics,model,' ','TEXT_f')

end

endfunction



    
function txt=tomultline(txt)
  u=ascii(txt)
  k=find(u(1:$-1)==92 & u(2:$)==110)
  if isempty(k) then
     return
  end
  j=k(1)
  txt=ascii(u(1:j-1))
  for i=k(2:$)
    txt($+1)=ascii(u(j+2:i-1))
    j=i
  end
  txt($+1)=ascii(u(j+2:$))
endfunction
