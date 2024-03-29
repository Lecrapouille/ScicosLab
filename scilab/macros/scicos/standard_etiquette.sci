function standard_etiquette(bloc, legende, job)
//
// standard_etiquette - Draw legends on scicos blocks
//
//%Syntaxe
// standart_etiquette(bloc, legende, 'in')
// standart_etiquette(bloc, legende, 'out')
// standart_etiquette(bloc, legende, 'clkin')
// standart_etiquette(bloc, legende, 'clkout')
// standart_etiquette(bloc, legende, 'centre')
// standart_etiquette(bloc, couleur, 'croix')
//
//%Inputs
// bloc    : Scicos bloc data structure
// legende : vector of character strings to draw or color code for job='croix'
// job     : Character string specifies where legend has to be drawn
//           'in'     : input ports
//           'out'    : output ports
//           'clkin'  : event input ports
//           'clkout' : event output ports
//           'centre' : in the block shape
//           'croix'  : draw a cross in the block shape
//%Origine 
// E. Demay E.D.F 97
//
// Last Update 16 Dec 2008 Fady: taking into consideration the thickness of the buses link 

//= Initialisations ==
//GRAPHIQUE = 2;ORIGINE = 1;TAILLE = 2
macro = bloc.gui
orient=bloc.graphics.flip
select job
case 'in' then //= Ports d'entree ==
  
  execstr('[x, y, typ] = '+macro+'(''getinputs'', bloc)')
  x = x(find(typ > 0))
  y = y(find(typ > 0))


  for i = 1:length(legende)
    rect = xstringl(0, 0, legende(i))
    if orient then //standard orientation
      xstring(x(i)-rect(3),y(i)+40/16,legende(i))
    else //tilded orientation
      xstring(x(i)+rect(3)/2,y(i)+40/16,legende(i))
    end
  end

case 'out' then //= Ports de sortie ==
  execstr('[x, y, typ] = '+macro+'(''getoutputs'', bloc)')
  x = x(find(typ > 0))
  y = y(find(typ > 0))
  for i = 1:length(legende)
    rect = xstringl(0, 0, legende(i))
    if orient then //standard orientation
      xstring(x(i),y(i)+40/16,legende(i))
    else //tilded orientation
      xstring(x(i)-rect(3),y(i)+40/16,legende(i))
    end
  end
case 'clkin' then //= Port d'entree evenement ==
  execstr('[x, y, typ] = '+macro+'(''getinputs'', bloc)')
  x = x(find(typ == -1))
  y = y(find(typ == -1))
  for i = 1:length(legende)
    rect = xstringl(0, 0, legende(i))
    xstring(x(i)-rect(3),y(i)+(i-1)*rect(4),legende(i))
  end
case 'clkout' then //= Ports de sortie evenement ==
  execstr('[x, y, typ] = '+macro+'(''getoutputs'', bloc)')
  x = x(find(typ == -1))
  y = y(find(typ == -1))
  for i = 1:length(legende)
    rect = xstringl(0, 0, legende(i))
    xstring(x(i)-rect(3), y(i)-i*rect(4)*1.2,legende(i))
  end
case 'centre' then //= Centre du bloc ==
 // origine = bloc(GRAPHIQUE)(ORIGINE)
 // taille = bloc(GRAPHIQUE)(TAILLE)
  origine = bloc.graphics.orig
  taille = bloc.graphics.sz
  xstringb(origine(1), origine(2), legende, taille(1), taille(2), 'fill')
case 'croix' then //= Identification des bases de donnees ==
//  origine = bloc(GRAPHIQUE)(ORIGINE)
//  taille = bloc(GRAPHIQUE)(TAILLE)
  origine = bloc.graphics.orig
  taille = bloc.graphics.sz
  nx = [origine(1), origine(1)+taille(1); origine(1), origine(1)+taille(1)] 
  ny = [origine(2), origine(2)+taille(2); origine(2)+taille(2), origine(2)]
  dashes = xget('dashes')
  xsegs(nx', ny', legende)
  xset('dashes', dashes)
end
endfunction





