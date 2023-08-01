function lk=scicos_route(lk,scs_m)

From=lk.from(1);To=lk.to(1)
delF=scs_m.objs(From).graphics.sz/2
delT=scs_m.objs(To).graphics.sz/2
if lk.ct(2)==1 | lk.ct(2)==3 then
  forig=scs_m.objs(From).graphics.orig(1)+delF(1)
  torig=scs_m.objs(To).graphics.orig(1)+delT(1)
  [lk.xx,lk.yy]=routage(lk.xx,lk.yy,forig,torig,delF(2),delT(2))
elseif lk.ct(2)==-1   then
  forig=scs_m.objs(From).graphics.orig(2)+delF(2)
  torig=scs_m.objs(To).graphics.orig(2)+delT(2)
  [lk.yy,lk.xx]=routage(lk.yy,lk.xx,forig,torig,delF(1),delT(1))
else
  return
end
endfunction

function [x,y]=routage(x,y,forig,torig,delF,delT)
  xold=[];yold=[]
  while ~(isequal(x,xold)&isequal(y,yold))
    del=3+6*rand()
    xold=x;yold=y
    if size(x,1)>2 then
      m=find(((x(1:$-2)==x(3:$))&(x(2:$-1)==x(3:$)))|..
           ((y(1:$-2)==y(3:$))&(y(2:$-1)==y(3:$))))
      if m<>[] then
       x(m+1)=[];y(m+1)=[]
      end
    end
    n=size(x,1);
    dx=x(2:$)-x(1:$-1)
    dy=y(2:$)-y(1:$-1)
    ki=find(dx.*dy<>0)
    if ki<> [] then
     I=ones(1,n);Z=zeros(2,n)
     Z(:,ki)=1
     I=[I;Z]
    
     J=matrix(cumsum(I(:)),3,n)
     xnew=[];ynew=[]
     xnew(J(1,:),1)=x
     ynew(J(1,:),1)=y
   
     xn1=(x(ki)+x(ki+1))/2;
     xn=[xn1';xn1'];xn=xn(:);
     yn=[y(ki)';y(ki+1)'];yn=yn(:);
     j=J([2,3],ki);j=j(:)
     xnew(j,1)=xn
     ynew(j,1)=yn
     x=xnew;y=ynew
    end
    if size(x,1)>2 then
      m=find(((x(1:$-2)==x(3:$))&(x(2:$-1)==x(3:$)))|..
           ((y(1:$-2)==y(3:$))&(y(2:$-1)==y(3:$))))
      if m<>[] then
       x(m+1)=[];y(m+1)=[]
      end
    end
  end
endfunction

