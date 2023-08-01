function []=show_bike(xx,col,t,p)
  // just show one bike
  nstep=1;
  r1=0.3;  //change nstep for postscript
  [nnr,nn]=size(xx);
  i=1
  
  //---------- position of the contact point of the rear wheel
  // xrear = xx(1:6,:)
  // theta=xrear(5,:);phi=xrear(4,:);
  rr=[ r1*cos(xx(5,col)).*sin(xx(4,col));
       -r1*cos(xx(5,col)).*cos(xx(4,col));
       -r1*sin(xx(5,col))];
  xprear=xx(1:3,col)+rr;

  //------------ generation of the rear wheel
  nnn=24
  l=(1/nnn)*( 2*%pi)*(0:nnn)'
  dec = ones(l);sinl=r1*sin(l);cosl=r1*cos(l);

  cphi1=cos(xx(4,i));
  sphi1=sin(xx(4,i));
  cthe1=cos(xx(5,i));
  sthe1=sin(xx(5,i));
  //  unused  (rotation angle of wheel)
  //  cpsi1=cos(xx(6,i));
  //  spsi1=sin(xx(6,i));
  xrearar = cosl*cphi1-sinl*(sphi1.*cthe1)+dec*xx(1,i);
  yrearar=  cosl*sphi1+sinl*(cphi1.*cthe1)+dec*xx(2,i);
  zrearar = sinl*sthe1+dec*xx(3,i);

  //------------- the framefork
  xf= [ xx(1,i);2*xx(7,i)-xx(1,i);xx([15,21],i)];
  yf= [ xx(2,i);2*xx(8,i)-xx(2,i);xx([16,22],i)];
  zf= [ xx(3,i);2*xx(9,i)-xx(3,i);xx([17,23],i)];
  //------------- position of the contact point of the rear wheel
  //xfront=xx([21,22,23,18,19,20],:);
  //theta=xx(19,:);phi=xx(18,:);
  rr=[  r1*cos(xx(19,col)).*sin(xx(18,col));
	-r1*cos(xx(19,col)).*cos(xx(18,col));
	-r1*sin(xx(19,col))];
  xpfront=xx(21:23,col)+rr;

  //-------------- generation of the front wheel
  cphi1=cos(xx(18,i));
  sphi1=sin(xx(18,i));
  cthe1=cos(xx(19,i));
  sthe1=sin(xx(19,i));
  // unused
  //  cpsi1=cos(xx(20,i));
  //  spsi1=sin(xx(20,i));
  xfrontar = cosl*cphi1-sinl*(sphi1.*cthe1)+dec*xx(21,i);
  yfrontar=  cosl*sphi1+sinl*(cphi1.*cthe1)+dec*xx(22,i);
  zfrontar = sinl*sthe1+dec*xx(23,i);
  //---------------boundaries
  xp=[xprear,xpfront,[xf(2,col);yf(2,col);zf(2,col)]];
  
  xmin=mini(xp(1,col));xmax=maxi(xp(1,col));
  ymin=mini(xp(2,col));ymax=maxi(xp(2,col));
  if xmin <0 then xmin=1.04*xmin,else xmin=0.96*xmin;end
  if xmax >0 then xmax=1.04*xmax,else xmax=0.96*xmax;end
  if ymin <0 then ymin=1.04*ymin,else ymin=0.96*ymin;end
  if ymax >0 then ymax=1.04*ymax,else ymax=0.96*ymax;end
  zmin=mini(xp(3,col));zmax=maxi(xp(3,col));
  rect=[xmin,xmax,ymin,ymax,zmin,zmax]

  ct=-cos(t);cp=cos(p);st=-sin(t);sp=sin(p);
  xe=[xmin;xmax;xmax;xmin;xmin]
  ye=[ymin;ymin;ymax;ymax;ymin]
  ze=[zmin;zmin;zmin;zmin;zmin];
  xer=ct*xe-st*ye;
  yer=cp*(st*xe+ct*ye)+sp*ze;
  
  [n1,n2]=size(xfrontar);

  deff('[]=velod(i)',['xnr=ct*xfrontar(:,i)-st*yfrontar(:,i);';
		      'ynr=cp*(st*xfrontar(:,i)+ct*yfrontar(:,i))+sp*zfrontar(:,i);';
		      'xnt=ct*xf(:,i)-st*yf(:,i);';
		      'ynt=cp*(st*xf(:,i)+ct*yf(:,i))+sp*zf(:,i);';
		      'xnf=ct*xrearar(:,i)-st*yrearar(:,i),';
		      'ynf=cp*(st*xrearar(:,i)+ct*yrearar(:,i))+sp*zrearar(:,i);';
		      'xpoly(xnt,ynt,''lines'')';
		      'xfpoly(xnr,ynr)';
		      'xfpoly(xnf,ynf)']);

  xset('thickness',1); 
  isoview(mini(xer),maxi(xer),mini(yer),maxi(yer));
  xset("alufunction",6)
  xpoly(xer,yer,'lines')
  i=1;
  velod(i);
  ww=i:i+1;
  plot2d((ct*xprear(1,ww)-st*xprear(2,ww))',...
	 (cp*(st*xprear(1,ww)+ct*xprear(2,ww))+sp*xprear(3,ww))',...
	 [1,-1],"000");
  velod(i);
  velod(n2-1);
  xset("alufunction",3);
  xset('thickness',1);
endfunction



