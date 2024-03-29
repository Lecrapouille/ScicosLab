function [x,y,typ]=GotoTagVisibility(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[],typ=[]
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
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,tag,exprs]=getvalue('Set parameters',..
	  ['GotoTag'],..
	  list('gen',-1),exprs)
      if ~ok then break,end
      if ok then
	if model.opar<>list(tag) then needcompile=4;y=needcompile,end
	graphics.exprs=exprs;
	model.opar=list(tag);
	x.graphics=graphics;x.model=model;
	break
      end
    end
   needcompile=resume(needcompile)
   case 'define' then
   model=scicos_model()
   model.sim='gototagvisibility'
   model.in=[]
   model.in2=[]
   model.out=[]
   model.out2=[]
   model.evtin=[]
   model.intyp=1
   model.outtyp=1
   model.opar=list('""A""');
   model.blocktype='c'
   model.firing=%f
   model.dep_ut=[%f %f]
   exprs=sci2exp('A')
   gr_i=['xstringb(orig(1),orig(2),[''{''+arg1.graphics.exprs(1)+''}''],sz(1),sz(2),''fill'');'
         'txt=[''Goto Tag'';''Visibility'' ];'
         'style=5;'
         'gh_axes = gca();'
         'axes_font_style = gh_axes.font_style ;'
         'axes_font_size  = gh_axes.font_size  ;'
         'gh_axes.font_style = 5;'
         'gh_axes.font_size  = 1;'
         'rectstr=stringbox(txt,orig(1),orig(2),0,style,1);'
         'if ~exists(''%zoom'') then %zoom=1, end;'
         'w=(rectstr(1,3)-rectstr(1,2))*%zoom;'
         'h=(rectstr(2,2)-rectstr(2,4))*%zoom;'
         'xstringb(orig(1)+sz(1)/2-w/2,orig(2)-h-5,txt,w,h,''fill'');'
         'gh_axes.font_style = axes_font_style ;'
         'gh_axes.font_size  = axes_font_size  ;']
   x=standard_define([2 2],model,exprs,gr_i)
  end
endfunction