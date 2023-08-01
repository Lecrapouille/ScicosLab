function [rect] = dig_bound(scs_m)
// Copyright INRIA

  n = lstsize(scs_m.objs);
  
  if n < 1 then rect=[]
      return
  end
  
  
  xmin = 100000;
  xmax = -xmin;
  ymin = xmin;
  ymax = -xmin;
  
  for i=1:n          // loop on objects
  
    o = scs_m.objs(i)
    
    if typeof(o)=='Block' then
      [orig,sz] = (o.graphics.orig,o.graphics.sz)
      xmin=min(xmin,orig(1))
      xmax=max(xmax,orig(1)+sz(1))
      ymin=min(ymin,orig(2))
      ymax=max(ymax,orig(2)+sz(2))


    elseif typeof(o)=='Text' then
      [orig,sz] = (o.graphics.orig,o.graphics.sz)
      rect = stringbox(tomultline(o.graphics.exprs(1)), orig(1), orig(2), 0, o.model.ipar(1),o.model.ipar(2))
      xstr=rect(1,1);
      ystr=rect(2,1);
      wstr=rect(1,3)-rect(1,2);
      hstr=rect(2,2)-rect(2,4);

      orig(1)=xstr
      orig(2)=ystr
      sz(1)=wstr*%zoom
      sz(2)=hstr*%zoom
      xmin=min(xmin,orig(1))
      xmax=max(xmax,orig(1)+sz(1))
      ymin=min(ymin,orig(2))
      ymax=max(ymax,orig(2)+sz(2))

    elseif typeof(o)=='Link' then
      xx=o.xx(:);yy=o.yy(:);
      xmin=min([xmin;xx])
      xmax=max([xmax;xx])
      ymin=min([ymin;yy])
      ymax=max([ymax;yy])
    end
  
  end //** --- of the for loop 
  
  rect=[xmin,ymin,xmax,ymax] //** return with the coordinate of an immaginary 
                             //** rectangle that include all the graphics object 

endfunction
