function xstringb_fix_font(x,y,s,wo,ho,o)
  global %Scicos_Font_cor   // use instead of persistent
  if %Scicos_Font_cor==[] then
    global %Scicos_Font_cor
    fontxx=xget("font")
    for i=0:5
      xywh=xstringl(0,0,'Logical Op',fontxx(1),i)
      %Scicos_Font_cor(i+1)=xywh(3)
    end
    %Scicos_Font_cor=%Scicos_Font_cor*%zoom/50
  end


  fsz=max(0,-1+max(find(%zoom>%Scicos_Font_cor)))
  rect=xstringl(x,y,s,6,fsz)
  w=rect(3),h=rect(4),
  xset("font size",fsz)
  xstring(x+(wo-w)/2,y+(ho-h)/2,s)
endfunction 