function Code=code_generation(rdnom,equations,eq_pts_mes,flag_type,%h,%CI,%CI1,%a,..
                              %N,%Ninitiale,impl_type,type_meth,%oper)
// Copyright INRIA
// développé par EADS-CCR
// Cette fonction conserne la génération du code de la la fonction de calcul du bloc EDP //
// entrées :                                                                             //
//           - equations : vecteurs de chaine de caractères corespond aux équation ODE   //
//                         ou DAE générées selon les différentes methodes de             //
//                         discrètisation.                                               //
//           - impl_type : entier correspond au type des équation DAE (implicites)       //
//                         ( -1 pour les systèmes algébriques, 1 pour les systèmes       //
//                         algébro-différentiels).                                       //
// sortie :                                                                              //
//           - Code : vecteur de chaine de caratères qui renvoi le code du bloc à        //
//                    imprimer par la suite dans le fichier .c                           //
// pour plus d'information voir les fonctions de calcul des blocs Scicos de type 4       //
// (explicite) et de type 10004 (implicite).                                             //
//---------------------------------------------------------------------------------------//

  Code=['#include '"'+SCI+'/routines/scicos/scicos_block.h'"'
        '#include <math.h>'
        ' '       
        'void  '+rdnom+'(scicos_block *block,int flag)'
        '{'
        ' '
        ' double **inptr = block->inptr;'
        ' double **outptr = block->outptr;'
        ' double *x = block->x;'
        ' int nx = block->nx;'
        ' double *xd = block->xd;']
  if (flag_type == 2) then
    Code=[Code
          ' double *res = block->res;']
    if (type_meth == 3 & (find(%oper == 2) ~= [] | find(%oper == 4) ~= [])) then
      if (find(%oper == 1) ~= []) then
        Code=[Code
            ' int pr%operty['+string(3*%N)+'];']
      else
        Code=[Code
            ' int pr%operty['+string(2*%N)+'];']
      end
    elseif (find(%oper == 1) ~= []) then
      Code=[Code
            ' int property['+string(2*%N)+'];']
    else
      Code=[Code
            ' int property['+string(%N)+'];']
    end
  end
  Code=[Code
        ' '
        ' int i;'
        ' double t = get_scicos_time();'
        ' '
        ' if (flag == 0){'
        equations
        ' }else if (flag == 1){'];
  if (type_meth == 3 & (find(%oper == 2) ~= [] | find(%oper == 4) ~= [])) then      
    sorties1=['   /* la première sortie */ '
              '   for (i=0;i<'+string(%N)+';i++){'
              '     outptr[0][i]=x[i+'+string(%N)+'];'
              '   }']; 
    sorties2=['   /* la deuxième sortie */ '];
    for i=1:size(eq_pts_mes,'*')
      sorties2=[sorties2
               '   outptr[1]['+string(i-1)+']='+eq_pts_mes(i)+';'];
    end
  else
    if (kbc(1) == 1) & (DF_type == 0 | DF_type == 1) then
    sorties1=['   /* la première sortie */ '
              '   for (i=1;i<'+string(%Ninitiale)+';i++){'
             '     outptr[0][i]=x[i];'
             '   }']; 
    else
      sorties1=['   /* la première sortie */ '
                '   for (i=0;i<'+string(%Ninitiale)+';i++){'
                '     outptr[0][i]=x[i];'
                '   }']; 
    end
    sorties2=['   /* la deuxième sortie */ '];
    for i=1:size(eq_pts_mes,'*')
      sorties2=[sorties2
               '   outptr[1]['+string(i-1)+']='+eq_pts_mes(i)+';'];
    end
  end
  Code=[Code
        sorties1
        sorties2
        ' }else if (flag == 4){'];
  condini=[];

//////////////////////////////////////
   %mm=getfield(1,%scicos_context)
   for %mi=%mm(3:$)
      ierr=execstr(%mi+'=%scicos_context(%mi)','errcatch')
      if ierr<>0 then
        break
      end
   end
///////////////////////////////////////

  x=%a;
  // si on a un systeme algebrique on a pas besoin des conditions initiales.
  if (impl_type ~= -1) then
    if (find(%oper == 1) == []) then
      for %ii=1:%N
        condini=[condini
                 '   x['+string(%ii-1)+']='+msprintf('%.16g',evstr(%CI))+';'];
        x=x+%h;
      end
    else
      for %ii=1:%N
        condini=[condini
                 '   x['+string(%ii-1)+']='+msprintf('%.16g',evstr(%CI))+';';
                 '   x['+string(%ii+%N-1)+']='+msprintf('%.16g',evstr(%CI1))+';'];
        x=x+%h;
      end
    end
  end
  Code=[Code
        condini
        '/* }else if (flag == 5){ */'];
  final=[];
  Code=[Code
       final]
  if (flag_type == 2) then
    property=[];
    if (find(%oper == 1) ~= []) then
      if (impl_type == 0) then
        for %ii=1:%N
          property=[property
                    '   property['+string(%ii-1)+']=-1;';
                    '   property['+string(%ii+%N-1)+']=1;';
                    '   property['+string(%ii+2*%N-1)+']=1;'];
        end
      else
        for %ii=1:2*%N
          property=[property
                    '   property['+string(%ii-1)+']='+string(impl_type)+';'];
        end
        property(%N+1)='   property['+string(%N)+']='+string(-1)+';';
        property($)='   property['+string(2*%N-1)+']='+string(-1)+';';
      end
    else
      if (impl_type == 0) then
        for %ii=1:%N
          property=[property
                    '   property['+string(%ii-1)+']=-1;';
                    '   property['+string(%ii+%N-1)+']=1;'];
        end
      else
        if (type_meth ==3 & (find(%oper == 2) ~= [] | find(%oper == 4) ~= [])) then
          for %ii=1:2*%N
            property=[property
                      '   property['+string(%ii-1)+']='+string(impl_type)+';'];
          end
        else
          property=[property
                      '   property['+string(0)+']='+string(-1)+';'];
          for %ii=2:%N-1
            property=[property
                      '   property['+string(%ii-1)+']='+string(impl_type)+';'];
          end
          property=[property
                      '   property['+string(%N-1)+']='+string(-1)+';'];
        end
      end
    end
    
    Code=[Code
          ' }else if (flag == 7){'
          property
          '  set_pointer_xproperty(property);']
  end
  Code=[Code
        ' }'
        ' return;'
        '}'];  

endfunction

