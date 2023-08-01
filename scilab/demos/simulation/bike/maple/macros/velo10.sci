function []=velo10()
// "full wheel" version
// Copyright INRIA
  ct=-cos(t);cp=cos(p);st=-sin(t);sp=sin(p);

  [n1,n2]=size(xfrontar);

  deff('[xmin,xmax,ymin,ymax]=velod_sim(i)',['xnr=ct*xfrontar(:,i)-st*yfrontar(:,i);';
					     'ynr=cp*(st*xfrontar(:,i)+ct*yfrontar(:,i))+sp*zfrontar(:,i);';
					     'xnt=ct*xf(:,i)-st*yf(:,i);';
					     'ynt=cp*(st*xf(:,i)+ct*yf(:,i))+sp*zf(:,i);';
					     'xnf=ct*xrearar(:,i)-st*yrearar(:,i),';
					     'ynf=cp*(st*xrearar(:,i)+ct*yrearar(:,i))+sp*zrearar(:,i);';
					     'xmin=min([xnt;xnr;xnf]);'
					     'xmax=max([xnt;xnr;xnf]);'
					     'ymin=min([ynt;ynr;ynf]);'
					     'ymax=max([ynt;ynr;ynf]);']);
  
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
  [xmin,xmax,ymin,ymax]=velod_sim(1);
  isoview(xmin,xmax,ymin,ymax);
  i=1;
  velod(i);
  ww=i:i+1;
  plot2d((ct*xprear(1,ww)-st*xprear(2,ww))',...
	 (cp*(st*xprear(1,ww)+ct*xprear(2,ww))+sp*xprear(3,ww))',...
	 [1,-1],"000");
endfunction


