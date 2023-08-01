//predator prey
function xd=epi(t,x)
  beta_v = 1
  lambda =1
  mu=1;
  D0=2/3;
  gamma_v=1/10 ; // gamma = 1;
  xd(1)=beta_v*x(2)^2*(1-x(1))*x(1)- gamma_v*x(1);
  xd(2)=lambda*(D0-x(2))*(1-x(1)) - mu*x(2)*x(1);
endfunction

bound=[0,0,1,1];
nrect=50;
x=linspace(bound(1),bound(3),nrect);
y=linspace(bound(2),bound(4),nrect);
x0=[];
for i=1:size(x,'*')
  for j=1:size(y,'*')
    x0=[x0;x(i),y(j)];
  end
end
portrait(epi,"default",bound,[3000,0.01],'f',x0');
  
