function scs_m = set_diagram_location(scs_m,loc,%zoom)
scs_m.props.wpar(13)=%zoom;
pos=loc(1:2);
sz=loc(3:4)-pos;
w=sz(1);h=sz(2);
//rect=[0 0 w h];
scs_m.props.wpar(9:12)=[sz pos];
ax=sz(1)/(%zoom*w);
ay=sz(2)/(%zoom*h);
  bx = (1-1/ax)/2; 
  by = (1-1/ay)/2; 
  width  = %zoom * w * ax  ;   
  height = %zoom * h * ay  ;
scs_m.props.wpar(5:6)=[width height];
  wp=w*ax;
  hp=h*ay
  xmin=0//rect(3)-wp*(bx+(1/ax))
  ymin=0//rect(4)-hp*(by+(1/ay))
  xmax=xmin+wp; ymax=ymin+hp;
scs_m.props.wpar(1:4)=[xmin  xmax ymin ymax];
    %XSHIFT = (width - sz(1) ) / 2 ;
    %YSHIFT = (height- sz(2) ) / 2
scs_m.props.wpar(7:8)=[%XSHIFT %YSHIFT];
endfunction
