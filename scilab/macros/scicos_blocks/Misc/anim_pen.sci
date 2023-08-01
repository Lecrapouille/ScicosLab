///withoutPrompt 
function [blocks] = anim_pen(blocks,flag)
  win=20000+curblock()
  if flag<>4 then H=scf(win), end
  xold=blocks.z
  rpar=blocks.rpar
  plen=rpar(1)*1.6;csiz=rpar(2)/4;phi=rpar(3);
  rcirc=csiz/3;
  if flag==4 then 
    xset("window",win)
    set("figure_style","new")
    H=scf(win)
    clf(H)
    H.pixmap='on'
    Axe=H.children
    Axe.data_bounds=rpar(4:7)
    Axe.isoview='on'
    
    S=[cos(phi),-sin(phi);sin(phi),cos(phi)]
    XY=S*[rpar(4),rpar(5);-csiz,-csiz]
    xset("color",3)
    xsegs(XY(1,:),XY(2,:)-rcirc)
    
    x=0;theta=0;
    x1=x-csiz;x2=x+csiz;y1=-csiz;y2=csiz
    XY=S*[x1 x2 x2 x1 x1;y1,y1,y2,y2,y1]
    xset("color",5)
    xfpoly(XY(1,:),XY(2,:))// cart
    xset("color",2)
    xfarc(XY(1,1),XY(2,1),rcirc,rcirc,0,360*64) //wheel
    xfarc(XY(1,2),XY(2,2),rcirc,rcirc,0,360*64) //wheel

    XY=S*[x,x+plen*sin(theta);0,0+plen*cos(theta)]//pendulum
    xset("color",2)
    xsegs(XY(1,:),XY(2,:))
    
  elseif flag==2 then
    Axe=H.children
    x=blocks.inptr(1)(1)
    theta=blocks.inptr(2)(1)
    XY=Axe.children(4).data'+ [cos(phi)*(x-xold);sin(phi)*(x-xold)]*ones(1,5)
    Axe.children(4).data=XY'
    
    Axe.children(3).data(1)=XY(1,1)
    Axe.children(3).data(2)=XY(2,1)
    XY=Axe.children(4).data'+ [cos(phi)*(x-xold-rcirc);sin(phi)*(x-xold-rcirc)]*ones(1,5)
    Axe.children(2).data(1)=XY(1,2)
    Axe.children(2).data(2)=XY(2,2)
    x1=x*cos(phi);y1=x*sin(phi)
    XY=[x1,x1+plen*sin(theta);y1,y1+plen*cos(theta)]
    Axe.children(1).data=XY'
    blocks.z=x
    show_pixmap()
  end
endfunction ///\withPrompt{}

