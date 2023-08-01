function [xi,w] = setint()
// Copyright INRIA
// développé par EADS-CCR
// la fonction fournit les point d'intégration x(i) et les poids      //
// pour la formule quadratique gaussienne.                            //                    
//  Sorties:                                                          //
//     - x(4,4):  x(:,i) is the Gaussian points of order i.           //
//     - w(4,4):  w(:,i) is the weights of quadrature of order i.     //
//                                                                    //
// Reference: Finite element, An introduction, Vol. 1 by E.Becker,    //
// G.Carey, and J.Oden, pp. 94.                                       //
//--------------------------------------------------------------------//
     xi(1,1) = 0;
     w(1,1) = 2;		// Gaussian quadrature of order 1

     xi(1,2) = -1/sqrt(3);
     xi(2,2) = -xi(1,2);
     w(1,2) = 1;
     w(2,2) = w(1,2);		// Gaussian quadrature of order 2

     xi(1,3) = -sqrt(3/5);
     xi(2,3) = 0;
     xi(3,3) = -xi(1,3);
     w(1,3) = 5/9;
     w(2,3) = 8/9;
     w(3,3) = w(1,3);	        // Gaussian quadrature of order 3

     xi(1,4) = - 0.861136311594053;
     xi(2,4) = - 0.339981043584856;
     xi(3,4) = -xi(2,4);
     xi(4,4) = -xi(1,4);
     w(1,4) = 0.347854845137454;
     w(2,4) = 0.652145154862646;
     w(3,4) = w(2,4);
     w(4,4) = w(1,4);		// Gaussian quadrature of order 4

endfunction
//--------------------------- FIN DE SETINT --------------------------//

function [gk,gf]=formkf(nelem,kind,nint,nodes,x,xi,w,nnode,a6,operi,kbc,vbc)
// Copyright INRIA
// développé par EADS-CCR
//   la fonction formkf, construit le système discret de l'element        //
//   finis en appelant la fonction elem pour avoir la matrices locales    //
//   ek, ef et la fonction assemb pour les  ajoutées aux matrices          //
//   globales gk et le second membre gf.                                  //
//   Sorties :                                                            //
//      - gk (Double) : matrice globale                                   //
//      - gf (Double) : vecteur qui correspond au scond membre            //
//   Entrées :                                                            //
//      - nelem (Entier) : est le nombre d'éléments                       //
//      - kind(i) (Entier) : ordre des fonctions de test                  //
//      - ninit(i) (Entier) :ordre d'integration Gaussian                 //
//      - x (Double):  vecteur des cordonnées des points nodales          //
//      - xi, w (Doubles) : les points Gausse et leurs poids obtenu       //
//        de setint()                                                     //
//      - a6 (String) : coefficient a(x) de l'opérateur pour lequel nous  //
//        calculons ca forme variationelle.                               //
//      - operi (Entier) : l'opérateur concerné                           //
//      - kbc (Entier) : vecteur types des conditions au limites          //
//      - vbc (String) : vecteur des conditions aux limites en a et b     //
//------------------------------------------------------------------------//

// système discrétisé
  
  gk = spzeros(nnode,nnode);
  gf = zeros(nnode,1);
    
  for nel = 1:nelem
    n = kind(nel) + 1;
    i1 = nodes(1,nel);
    i2 = nodes(n,nel);
    i3 = nint(nel);

//  Prendre le i3-éme ordre de la quadrature Gaussienne: 1, ordre 1; 2, ordre 2, ...

       xic = xi(:,i3);      wc = w(:,i3);
       [ek,ef] = elemoper(x(i1),x(i2),n,i3,xic,wc,operi,a6);
       // assemblage
       [gk,gf]=assemb(gk,gf,ek,ef,nel,n,nodes);
    end
    
    // ajustement par apport aux conditions aux limites.
      if (kbc(1) == 0 ) then
        gk(1,:)=0;
        gf(1)=0;
      end
      if (kbc(2) == 0 ) then		                    
        gk(nnode,:)=0;
        gf(nnode)=0;
      end
endfunction

//--------------------------- FIN DE FORMKF -----------------------------//

function [gk,gf]=assemb(gk,gf,ek,ef,nel,n,nodes)
// Copyright INRIA
// développé par EADS-CCR
//  la fonction assemb assemble la matrice de regidité gk et le second   //
//  membre gf en bouclant sur les nel- elements.                         //                  
//   Sorties :                                                           //
//      - gk (Double) E/S : matrice globale                              //
//      - gf (Double) E/S : vecteur qui correspond au scond membre       //
//   Entrées :                                                           //     
//      - ek (Double) : matrice élémentaire                              //
//      - ef (Double) : vecteur élémentaire du scond membre              //
//      - nel (Entier) : le nombre d'element.                            //                                     
//      - n (Entier) :   nombre de points nodales dans un element,       //
//        e.g. linear n=2; quadrtic, n=3; cubic: n=4.                    //                                  
//      - nodes (Entier) : nombre des points nodales du noeud dans les   //
//        nel elements, nodes(1,nel), nodes(2,nel), ..., nodes(n,nel).   //            
//-----------------------------------------------------------------------//
 
  for i=1:n
    ig = nodes(i,nel);
    // Assemblage global du vecteur gf
    gf(ig) = gf(ig) + ef(i);

    for j=1:n
      jg = nodes(j,nel);
      // Assemblage global de la matrice de regidité gk
      gk(ig,jg) = gk(ig,jg) + ek(i,j);
    end
  end 
endfunction
//--------------------------- FIN DE ASSEMB -----------------------------//

function [psi,dpsi]=shape(xi,n);
// Copyright INRIA
// développé par EADS-CCR
// la fonction ``shape'' evalue les valeurs des fonction de base et      //
// dérivées en un point xi.                                              //
// Sorties :                                                             //
//    - psi (Double) :  valeur de la fonction de base a xi.              //
//    - dpsi (Double) : valeur de la dérivée de la fonction de base a xi.//
// Entrées :                                                             //
//    - xi (Entier) : le point ou la fonction de base est évaluée.       //
//    - n (Entier) : la base des functions. n=2,linear,n=3,quadratic,    //
//      n=4, cubic.                                                      //
//   Reference: Finite element. An introduction y E.Becker, G.Carey,     //
//   and J.Oden, Vol.1., pp. 95-96.                                      //                           
//-----------------------------------------------------------------------//

   select n
   case 2 then
     // Linear base function
     psi(1) = (1-xi)/2;
     psi(2) = (1+xi)/2;
     dpsi(1) = -0.5;
     dpsi(2) = 0.5;  
     return

   case 3 then
     // quadratic base function
     psi(1) = xi*(xi-1)/2;
     psi(2) = 1-xi*xi;
     psi(3) = xi*(xi+1)/2;
     dpsi(1) =  xi-0.5;
     dpsi(2) = -2*xi;
     dpsi(3) = xi + 0.5;
     return

   case 4 then
     // cubic  base function
     psi(1) = 9*(1/9-xi*xi)*(xi-1)/16;
     psi(2) = 27*(1-xi*xi)*(1/3-xi)/16;
     psi(3) = 27*(1-xi*xi)*(1/3+xi)/16;
     psi(4) = -9*(1/9-xi*xi)*(1+xi)/16;

     dpsi(1) = -9*(3*xi*xi-2*xi-1/9)/16;
     dpsi(2) = 27*(3*xi*xi-2*xi/3-1)/16;
     dpsi(3) = 27*(-3*xi*xi-2*xi/3+1)/16;
     dpsi(4) = -9*(-3*xi*xi-2*xi+1/9)/16;
   else
     break
   end
endfunction
