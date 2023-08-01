function [coef1,coef2,coef21,coef22]=Disc2_5_FVM1d(h,kbc,operi,N,xn,xw,a1)
// Copyright INRIA
// développé par EADS-CCR
// Cette fonction renvoie les différentes matrices de discrétisation     //
// des opérateurs du/dx et dq/dx (q pour le changement de variable dans  //
// le cas de l'opérateur d2u/dx2)                                        //
// sorties :                                                             //
//    - coef1 (Double) : matrice de l'integrale de du/dx sur une cellule //
//    - coef2 (Double) : vecteur correspond à l'implémentation des       //
//      conditions aux limites                                           //
//    - coef21 (Double) : matrice d'integrale de dq/dx sur une cellule   //
// entrées :                                                             //
//    - h (Double) : est le pas de discretisation                        //
//    - kbc (Entier) : vecteur de types des conditions au limites        //
//    - operi (Entier) : l'opérateur concerné 2 ou 5                     //
//    - N (Entier) : est le nombre de noeuds                             //
//    - xn (Double) : vecteur colonne representant les noeuds            //
//    - xw (Double) : vecteur colonne representant les cellules          //
//      (les volumes de contrôle)                                        //
//    - a1 (String) : coefficient a(x) de l'opérateur pour lequel nous   //
//      calculons l'intégrale.                                           //
//-----------------------------------------------------------------------//
  
  coef1=[]; coef2=[]; coef21=[]; coef22=[];
  coef1=spzeros(N,N);
  coef2=spzeros(N,1);

  [a1_evw,a1_evn]=eval_a1(a1,xw,xn,N)


  
  if (operi == 5) then
    // cas oper5    
    // Dirichlet en a
    if ( kbc(1) == 0) then
      coef1(1,1)=0.5*(3*a1_evw(1)-a1_evw(2));
      coef1(1,2)=0.5*(a1_evw(1)+a1_evw(2));
      coef2(1)=-2*a1_evw(1);
    elseif (kbc(1) == 1) then
      // Neumann en a
      coef2(1)=h*a1_evn(1);
    end
    for i=2:N-1
      coef1(i,i-1)=-.5*a1_evw(i);
      coef1(i,i)=.5*(a1_evw(i)-a1_evw(i+1));
      coef1(i,i+1)=.5*a1_evw(i+1);
    end
    // Dirichlet en b
    if ( kbc(1) == 0) then
      coef1(N,N)=0.5*(a1_evw(N)-3*a1_evw(N+1));
      coef1(N,N-1)=-0.5*(a1_evw(N+1)+a1_evw(N));
      coef2(N)=2*a1_evw(N+1);
    elseif (kbc(1) == 1) then
      // Neumann en b
      coef2(N)=h*a1_evn(N);
    end
  else
    // cas oper2 
    coef21=spzeros(N,N);
    coef22=spzeros(N,1);
    // Dirichlet en a
    if ( kbc(1) == 0) then
      coef21(1,1)=1;
      coef21(1,2)=1;
      coef22(1)=-2;
      coef1(1,1)=0.5*(3*a1_evw(1)-a1_evw(2));
      coef1(1,2)=0.5*(a1_evw(1)+a1_evw(2));
    elseif (kbc(1) == 1) then
      // Neumann en a
      coef22(1)=h;
      coef1(1,1)=0.5*(3*a1_evw(1)-a1_evw(2));
      coef1(1,2)=0.5*(a1_evw(1)+a1_evw(2));
      coef2(1)=-2*a1_evw(1);
    end
    for i=2:N-1
      coef21(i,i-1)=-0.5;
      coef21(i,i+1)=0.5;
      coef1(i,i-1)=-.5*a1_evw(i);
      coef1(i,i)=.5*(a1_evw(i)-a1_evw(i+1));
      coef1(i,i+1)=.5*a1_evw(i+1);
    end
    // Dirichlet en b
    if ( kbc(1) == 0) then
      coef21(N,N)=-1;
      coef21(N,N-1)=-1;
      coef22(N)=2;
      coef1(N,N)=0.5*(a1_evw(N)-3*a1_evw(N+1));
      coef1(N,N-1)=-0.5*(a1_evw(N+1)+a1_evw(N));
    elseif (kbc(1) == 1) then
      // Neumann en b
      coef22(N)=h;
      coef1(N,N)=0.5*(a1_evw(N)-3*a1_evw(N+1));
      coef1(N,N-1)=-0.5*(a1_evw(N+1)+a1_evw(N));
      coef2(N)=2*a1_evw(N+1);
    end    
  end
  
endfunction

function  [%a1_evw,%a1_evn]=eval_a1(%a1,%xw,%xn,%N)
 if size(%xw,'*')==1 then
  x=%xw;
  %a1_evw=evstr(%a1).*ones(%N+1,1);
 else
  %a1_evw=zeros(%N+1,1)
  for %ii=1:%N+1 
    x=%xw(%ii)
    %a1_evw(%ii)=evstr(%a1)
  end
 end
 if size(%xn,'*')==1 then
  x=%xn;
  %a1_evn=evstr(%a1).*ones(%N,1);  
 else
  %a1_evn=zeros(%N,1)
  for %ii=1:%N
    x=%xn(%ii);
    %a1_evn(%ii)=evstr(%a1)
  end
 end
endfunction