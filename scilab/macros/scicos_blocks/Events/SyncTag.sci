function [x,y,typ]=SyncTag(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[],typ=[]
  select job
   case 'plot' then
     orig=arg1.graphics.orig;sz=arg1.graphics.sz;orient=arg1.graphics.flip;
     pat=xget('pattern');xset('pattern',default_color(-1))
     thick=xget('thickness');xset('thickness',2)
     xx=[0:.01:1];
     yy=(1/4-(xx-1/2)^2)^(1/2)+1/2;
     x=(orig(1))*ones(1,101)+sz(1)*xx;
     y=(orig(2))*ones(1,101)+sz(2)*yy;
     xset('thickness',2);
     xpolys(x',y',5*ones(101,1));
     xx=[1:-.01:.01 0];
     yy=-(1/4-(xx-1/2)^2)^(1/2)+1/2;
     x=(orig(1))*ones(1,101)+sz(1)*xx;
     y=(orig(2))*ones(1,101)+sz(2)*yy;
     xpolys(x',y',5*ones(101,1));
     xset('thickness',1);
     xstringb(orig(1),orig(2),'SyncTag',sz(1),sz(2),"fill")
     xset('thickness',thick)
     xset('pattern',pat)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1
   case 'define' then
   model=scicos_model()
   model.sim='synctag'
   gr_i=[]
   x=standard_define([2 2],model,'',gr_i)
  end
endfunction
