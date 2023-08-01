function [%ek,%ef] = elemoper(%x1,%x2,%n,%nl,%xi,%w,%operi,%a6)
// Copyright INRIA
// développé par EADS-CCR
//  la fonction elem evalue la matrice gk et le second memebre gf     //
//  Sorties :                                                         //
//    - %ek (Double) : matrice élémentaire                             //
//    - %ef (Double) : vecteur élémentaire du scond membre             //
//  Entrées :                                                         //     
//    - %x1,%x2 (Doubles): cordonnées %x1 et %x2 des limites de l'element //                                                
//    - %n (Entier) : Nombre des points nodals (et la fonction test)   //
//      dans l'element                                                // 
//    - %nl (Entier) : ordre d'integration Gaussian, 1,2,3,4           //  
//    - %xi(l) (Double) : la valeur de la cordonnée globale en         //
//      un point d'integration.                                       //
//    - %w(l) (Double) : le poids d'integration.                       //                                  
//    - %a6 (String) : coefficient a(x) de l'opérateur pour lequel     //
//      nous calculons ca forme variationelle.                        //
//    - %operi (Entier) : l'opérateur concerné                         //
//  Fonction appellée: shape(%xi(l),%n)                                 //
//  Reference: Finite element. An introduction by E.Becker, G.Carey,  //
//  and J.Oden, Vol.1., pp. 97-99.                                    //                             
//--------------------------------------------------------------------// 

   %mm=getfield(1,%scicos_context)
   for %mi=%mm(3:$)
      ierr=execstr(%mi+'=%scicos_context(%mi)','errcatch')
      if ierr<>0 then
        break
      end
   end

   %dx = (%x2-%x1)/2;
   
// Initialisation des matrices élémentaires
   %ef = zeros(%n,1);
   %ek = zeros(%n,%n);
// Evaluation des coefficients des opérateurs
   %x_dep = is_x_dep(%a6)   

   if (%operi ==2) then
      if %x_dep then
          // cas où %a6 depend de x, on calcul A=a(j)*dpsj+a(j+1)*dps(j+1) 
          [%psi1,%dpsi1] = shape(%x1,%n);          
          for %ii=1:%n
            x=%x1;
            %ax1=evstr(%a6);
            x=%x1+(%x2-%x1)/(%n-1);
            %ax2=evstr(%a6);
            if (%n == 2) then
              %ax=(%ax1*%dpsi1(1)+ %ax2*%dpsi1(2))/%dx;
            elseif (%n == 3) then
              x=%x1+2*(%x2-%x1)/(%n-1);
              %ax3=evstr(%a6); 
              %ax=(%ax1*%dpsi1(1)+ %ax2*%dpsi1(2)+ %ax3*%dpsi1(3))/%dx;
            end
          end
      end
   end

// Début de la boucle d'itégration
  for %l=1:%nl
    x = %x1 + (1.0 + %xi(%l))*%dx;
    [%psi,%dpsi] = shape(%xi(%l),%n);
    %ev_a6=evstr(%a6);
// Assemblage de la matrice élémentaire et le vecteur charge.
    for %ii=1:%n,
       if (%operi == 7) then
          %ef(%ii) = %ef(%ii) + %psi(%ii)*%ev_a6*%w(%l)*%dx;
       end
       for %jj=1:%n
          if ( find([1,3,6] == %operi) ~= []) then
            // %psi*%psi (oper = 1, 3, 6)
            %ek(%ii,%jj)=%ek(%ii,%jj)+(%ev_a6*%psi(%ii)*%psi(%jj) )*%w(%l)*%dx;
          elseif (%operi == 5) then 
            // %psi*%dpsi (oper =5)
            %ek(%ii,%jj)=%ek(%ii,%jj)+(%ev_a6*%psi(%ii)*%dpsi(%jj) )*%w(%l);
          elseif (%operi == 4) then
            // %dpsi*%psi (oper =4)
            %ek(%ii,%jj)=%ek(%ii,%jj)+(%ev_a6*%dpsi(%ii)*%psi(%jj) )*%w(%l);
          elseif (%operi == 2) then
            // %dpsi*%dpsi (oper =2)
            if ~%x_dep then
              // cas où %a6 ne depend pas de x 
              %ek(%ii,%jj)=%ek(%ii,%jj)+(%ev_a6*%dpsi(%ii)*%dpsi(%jj) )*%w(%l)/%dx;
            else
              // cas où %a6 depend de x, on calcul A=a(%jj)*dpsj+a(%jj+1)*dps(%jj+1) 
              %ek(%ii,%jj)=%ek(%ii,%jj)+(%ev_a6*%dpsi(%ii)*%dpsi(%jj)/%dx + %ax*%dpsi(%ii)*%psi(%jj))*%w(%l);
            end
          end
       end
    end
  end

endfunction

