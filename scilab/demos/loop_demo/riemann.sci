function demo_riemann()
  set('old_style','on');
  demo_help demo_riemann
  xbasc();
  xselect();
  C=hotcolormap(200);C=C(1:$-40,:); 
  //xset("wpos",1,1);
  //xset('wdim',700 ,900);
  SetPosition_old() ;
  //
  w=xget('window');
  //SetPosition();
  //toolbar(0,'off');
  xset('colormap',C);xset('color',30);//fond();
  
  [z,s]=cplxroot(4,25) //compute
  xset('pixmap',1)
  cplxmap(z,s,163,69)  //draw
  xset('wshow')
  realtimeinit(0.001)
  for i=1:100,
    k = 2 * i ;
    realtime(k),
    //if modulo(k,10)==0 then
      xset('wwpc')
      
      cplxmap(z,s,163+k/10,69+k/20)  //draw
      

      xset('wshow')
    //end

  end
  xdel(xget('window'))
  set('old_style','off');
endfunction

function fond()
  n=size(xget('colormap'),1) ;
  xset('background',n+1) ; 
  xset('foreground',n+2);
endfunction



function cplxmap(z,w,varargin)
//cplxmap(z,w,T,A,leg,flags,ebox)
//cplxmap Plot a function of a complex variable.
//       cplxmap(z,f(z))
// Copyright INRIA
x = real(z);
y = imag(z);
u = real(w);v = imag(w);
ncols=size(xget('colormap'),1)
[X,Y,U]=nf3d(x,y,u);
[X,Y,V]=nf3d(x,y,v);
Colors = sum(V,'r');
Colors = Colors - min(Colors);
Colors = int((ncols-1)*Colors/max(Colors)+1);
plot3d(X,Y,list(U,Colors),varargin(:))
endfunction



function [z,s]=cplxroot(n,m)
//cplxroot(n,m,T,A,leg,flags,ebox)
//CPLXROOT Riemann surface for the n-th root.
//       CPLXROOT(n) renders the Riemann surface for the n-th root.
//       CPLXROOT, by itself, renders the Riemann surface for the cube root.
//       CPLXROOT(n,m) uses an m-by-m grid.  Default m = 20.
// Use polar coordinates, (r,theta).
// Cover the unit disc n times.
// Copyright INRIA
[lhs,rhs]=argn(0)
if rhs  < 1, n = 3; end
if rhs  < 2, m = 20; end
r = (0:m)'/m;
theta = - %pi*(-n*m:n*m)/m;
z = r * exp(%i*theta);
s = r.^(1/n) * exp(%i*theta/n);
endfunction

