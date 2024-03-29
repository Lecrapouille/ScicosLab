function [x,y,ok,gc]=medit_curv(x,y,job,tit,gc)
//** 21 Aug 2006: from Serge Steer
//**
//   mod_curv  - Edition  de courbe interactive
//%Syntaxe
//  [x,y,ok]=mod_curv(xd,yd,job,tit)
//%Parametres
//  xd    :  vecteur des abscisses donnees (eventuellement [])
//  yd    :  vecteur des ordonnees donnees (eventuellement [])
//  job   :  chaine de 3 caracteres  specifiant les operations
//           permises:
//            - Si la chaine contient le caractere 'a', il est 
//              possible d'ajouter des points aux donnees, sinon
//              il est seulement possible de les deplacer
//            - Si la chaine contient le caractere 'x', il est 
//              possible de deplacer les points horizontalement
//            - Si la chaine contient le caractere 'y', il est 
//              possible de deplacer les points verticalement
//  tit   : liste de trois chaines de caracteres
//          tit(1) : titre de la courbe (peut etre un vecteur colonne)
//          tit(2) : label de l'axe des abscisses
//          tit(3) : label de l'axe des ordonnees
//  x     : vecteur des abscisses resultat
//  y     : vecteur des ordonnees resultat
//  ok    : vaut %t si la sortie as ete demandee par le menu Ok
//           et  %f si la sortie as ete demandee par le menu Abort
//%menus
//  Ok    : sortie de l'editeur et retour de la courbe editee
//  Abort : sortie de l'editeur et retour au donnes initiales 
//  Undo  : annulation de la derniere modification
//  Size  : changement des bornes du graphique
//  Grids : changement des graduations du graphique
//  Clear : effacement de la courbe (x=[] et y=[]) (sans quitter l'editeur)
//  Read  : lecture de la courbe a partir d'un fichier d'extension .xy
//  Save  : sauvegarde binaire (sur un fichier d'extension .xy) de 
//          la courbe
//!
//origine: serge Steer, Habib Jreij INRIA 1993
// Copyright INRIA
  [lhs,rhs]=argn(0)
  //in line definition of get_click
  deff('[btn,xc,yc,win,Cmenu]=get_click(flag)',[
      'if ~or(winsid() == curwin) then   Cmenu = ''Quit'';return,end,';
      'if argn(2) == 1 then';
      '  [btn, xc, yc, win, str] = xclick(flag);';
      'else';
      '  [btn, xc, yc, win, str] = xclick();';
      'end';
      'if btn == -100 then';
      '  if win == curwin then';
      '    Cmenu = ''Quit'';';
      '  else';
      '    Cmenu = ''Open/Set'';';
      '  end,';
      '  return,';
      'end';
      'if btn == -2 then';
      '  xc = 0;yc = 0;';
      '  execstr(''Cmenu='' + part(str, 9:length(str) - 1));';
      '  execstr(''Cmenu='' + Cmenu);';
      '  return,';
      'end';
      'Cmenu=[]'])
  


  ok=%t
  if rhs==0 then x=[];y=[],end;
  if rhs==1 then y=x;x=(1:size(y,'*'))',end
  if rhs<3  then job='axy',end
  if rhs<4 then tit=[' ',' ',' '],end
  if size(tit,'*')<3 then tit(3)=' ',end
  //
  [mx,nx]=size(x);x=x(:)
  [my,ny]=size(y);y=y(:)
  n=min(mx*nx,my*ny)
  x=x(1:n);y=y(1:n);
  xsav=x;ysav=y;xs=x;ys=y;
  //
  lj=length(job)
  add=0;modx=0;mody=0
  for k=1:lj
    jk=part(job,k)
    select jk
    case 'a' then add=1,
    case 'x' then modx=1
    case 'y' then mody=1
    else error('parametre job incorrect')
    end
  end
  eps=0.03
  symbsiz=0.2
  // bornes initiales du graphique
  if rhs<5 then
    if mx<>0 then
      xmx=maxi(x);xmn=mini(x)
      ymx=maxi(y);ymn=mini(y)
      dx=xmx-xmn;dy=ymx-ymn
      if dx==0 then dx=maxi(xmx/2,1),end
      xmn=xmn-dx/10;xmx=xmx+dx/10
      if dy==0 then dy=maxi(ymx/2,1),end;
      ymn=ymn-dy/10;ymx=ymx+dy/10;
    else
      xmn=0;ymn=0;xmx=1;ymx=1;dx=1;dy=1
    end
    rect=[xmn,ymn,xmx,ymx];
    axisdata=[2 10 2 10]
  else
    [rect,axisdata]=gc(1:2)
    xmn=rect(1);ymn=rect(2);xmx=rect(3);ymx=rect(4)
    dx=xmx-xmn;dy=ymx-ymn
  end

  // Set menus and callbacks
  menu_d=['Read','Save','Clear']
  menu_e=['Undo','Size','Replot','Ok','Abort']
  menus=list(['Edit','Data'],menu_e,menu_d)
  w='menus(2)(';rpar=')'
  Edit=w(ones(menu_e))+string(1:size(menu_e,'*'))+rpar(ones(menu_e))
  w='menus(3)(';rpar=')'
  Data=w(ones(menu_d))+string(1:size(menu_d,'*'))+rpar(ones(menu_d))

  curwin=max(winsid())+1
  xset('window',curwin)
  xselect()

  unsetmenu(curwin,'File',1) //clear
  unsetmenu(curwin,'File',2) //select
  unsetmenu(curwin,'File',6) //load
  unsetmenu(curwin,'File',7) //close
  unsetmenu(curwin,'3D Rot.')
  //
  execstr('Edit_'+string(curwin)+'=Edit')
  execstr('Data_'+string(curwin)+'=Data')
  menubar(curwin,menus)
  //
  f=gcf();a=gca();
  a.data_bounds=[rect(1),rect(2);rect(3),rect(4)]
  a.axes_visible='on';
  a.grid=[4 4];
  if x<>[] then
    xpolys(x*[1 1],y*[1 1],[1,-1])
    hdl=a.children.children
  else
    hdl=[]
  end
  
  xtitle(tit(1),tit(2),tit(3));


  // -- boucle principale
//   while %t then
    [n1,n2]=size(x);npt=n1*n2
//     [btn,xc,yc,win,Cmenu]=get_click()
    [btn,xc,yc,win,Cmenu]=(-2,0,0,0,'Quit')
    c1=[xc,yc]
    if Cmenu=='Quit' then Cmenu='Abort',end
    if Cmenu==[] then Cmenu='edit',end
    if Cmenu=='Exit' then Cmenu='Ok',end
    select Cmenu
    case [] then 
      //ce n est pas un menu
      break
    case 'Ok' then    //    -- ok menu
      rect=matrix(a.data_bounds',1,4)
      gc=list(rect,axisdata)

      xdel(curwin)
      return
    case 'Abort' then //    -- abort menu
      x=xsav
      y=ysav
      xdel(curwin)
      ok=%f
      return
    case 'Undo' then
      if hdl<>[] then draw(hdl),end //erase
      x=xs;y=ys
      if x<>[] then hdl.data=[x y];draw(hdl);end
    case 'Size' then
      while %t
	[ok,xmn,xmx,ymn,ymx]=getvalue('entrez les nouvelles bornes',..
				      ['xmin';'xmax';'ymin';'ymax'],..
				      list('vec',1,'vec',1,'vec',1,'vec',1),..
				      string([xmn;xmx;ymn;ymx]))
	if ~ok then break,end
	if xmn>xmx|ymn>ymx then
	  x_message('Les bornes sont incorrectes')
	else
	  break
	end
      end
      if ok then
	dx=xmx-xmn;dy=ymx-ymn
	if dx==0 then dx=maxi(xmx/2,1),xmn=xmn-dx/10;xmx=xmx+dx/10;end
	if dy==0 then dy=maxi(ymx/2,1),ymn=ymn-dy/5;ymx=ymx+dy/10;end
	rect=[xmn,ymn,xmx,ymx];
	a.data_bounds=[rect(1),rect(2);rect(3),rect(4)]
      end
    case 'Grids' then //no more used
      rep=x_mdialog('entrez les nouveaux nombres d''intervalles',..
		    ['axe des x';'axe des y'],..
		    string([axisdata(2);axisdata(4)]))
      if rep<>[] then
	rep=evstr(rep)
	axisdata(2)=rep(1);axisdata(4)=rep(2);
      end
      
    case 'Clear' then
      if hdl<>[] then delete(hdl),hdl=[];end
      x=[];y=[];
    case 'Read' then
      [x,y]=readxy()
      mx=mini(prod(size(x)),prod(size(y)))
      if mx<>0 then
	xmx=maxi(x);xmn=mini(x)
	ymx=maxi(y);ymn=mini(y)
	dx=xmx-xmn;dy=ymx-ymn
	if dx==0 then dx=maxi(xmx/2,1),xmn=xmn-dx/10;xmx=xmx+dx/10;end
	if dy==0 then dy=maxi(ymx/2,1),ymn=ymn-dy/5;ymx=ymx+dy/10;end
      else
	xmn=0;ymn=0;xmx=1;ymx=1;dx=1;dy=1
      end
      rect=[xmn,ymn,xmx,ymx];
      a.data_bounds=[rect(1),rect(2);rect(3),rect(4)]
      if x<>[]&y<>[] then 
	if hdl==[] then
	  xpolys(x(1)*[1 1],y(1)*[1 1],[1,-1])
	  hdl=gce();hdl=hdl.children
	end
	hdl.data=[x y];
      else 
	if hdl<>[] then delete(hdl),end
	x=[];y=[];
      end
    case 'Save' then
      savexy(x,y)
    case 'Replot' then
      draw(f)    
    case 'edit' then
      npt=prod(size(x))
      if npt<>0 then
	dist=((x-ones(npt,1)*c1(1))/dx)^2+((y-ones(npt,1)*c1(2))/dy)^2
	[m,k]=mini(dist);m=sqrt(m)
      else
	m=3*eps
      end
      if m<eps then                 //on deplace le point
	xs=x;ys=y
	[x,y]=movept(x,y)         
      else                          
	if add==1 then 
	  xs=x;ys=y                  //on rajoute un point de cassure
	  [x,y]=addpt(c1,x,y)
	end
      end
    end
//   end
endfunction

function [x,y]=addpt(c1,x,y)
//permet de rajouter un point de cassure
  npt=prod(size(x))
  c1=c1'
  if hdl==[] then
    x=c1(1);y=c1(2)
    xpolys(x*[1 1],y*[1 1],[1,-1])
    hdl=resume(a.children(1).children)
  end
  //recherche des intervalles en x contenant l'abscisse designee
  kk=[]
  if npt>1 then
    kk=find((x(1:npt-1)-c1(1)*ones(x(1:npt-1)))..
	    .*(x(2:npt)-c1(1)*ones(x(2:npt)))<=0)
  end
  if  kk<>[] then
    //    recherche du segment sur le quel on a designe un point
    pp=[];d=[];i=0
    for k=kk
      i=i+1
      pr=projaff(x(k:k+1),y(k:k+1),c1)
      if (x(k)-pr(1))*(x(k+1)-pr(1))<=0 then
        pp=[pp pr]
        d1=rect(3)-rect(1)
        d2=rect(4)-rect(2)
        d=[d norm([d1;d2].\(pr-c1))]
      end
    end
    if d<>[] then
      [m,i]=mini(d)
      if m<eps
        k=kk(i)
        pp=pp(:,i)
        x=x([1:k k:npt]);x(k+1)=pp(1);
        y=y([1:k k:npt]);y(k+1)=pp(2);
	hdl;drawlater();hdl.data=[x y];draw(hdl)
	return
      end
    end
  end
  d1=rect(3)-rect(1)
  d2=rect(4)-rect(2)
  if norm([d1;d2].\([x(1);y(1)]-c1))<norm([d1;d2].\([x(npt);y(npt)]-c1)) then
    //  -- mise a jour de x et y
    x(2:npt+1)=x;x(1)=c1(1)
    y(2:npt+1)=y;y(1)=c1(2)
  else
    //  -- mise a jour de x et y
    x(npt+1)=c1(1)
    y(npt+1)=c1(2)
  end
  hdl;drawlater();hdl.data=[x y];draw(hdl)
endfunction

function [x,y]=movept(x,y)
//on bouge un point existant
  hdl;
  f;f.pixmap='on';
  rep(3)=-1
  while rep(3)==-1 do
    rep=xgetmouse()
    xc=rep(1);yc=rep(2);c2=[xc;yc]
    if modx==0 then c2(1)=x(k);end
    if mody==0 then c2(2)=y(k);end
    x(k)=c2(1);y(k)=c2(2)
    hdl.data=[x,y];
    show_pixmap();drawnow()
  end
  f.pixmap='off';
endfunction


function [x,y]=readxy()
  fn=xgetfile('*.xy')
  if fn<>emptystr() then 
    if execstr('load(fn)','errcatch')<>0 then
      xy=read(fn,-1,2)
      x=xy(:,1);y=xy(:,2)
    else
      x=xy(:,1);y=xy(:,2)
    end
  else
    x=x
    y=y
  end

endfunction

function savexy(x,y)
  fn=xgetfile('*.xy')
  if fn<>emptystr()  then 
    xy=[x y];
    fil=fn+'.xy'
    if execstr('save(fil,xy)','errcatch')<>0 then
      x_message(['Impossible to save in the selected file';
		 'Check file and directory access'])
      return
    end
  end
endfunction
