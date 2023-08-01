function s_port_names(sbloc)
// Copyright INRIA

  scs_m=sbloc.model.rpar;
  
  etiquettes_in = list()
  etiquettes_out = list()
  etiquettes_clkin = list()
  etiquettes_clkout = list()
  font=xget('font')

  xset('font',options.ID(2)(1),options.ID(2)(2))
  inp=[],outp=[],cinp=[],coutp=[]
  for k=1:lstsize(scs_m.objs)
    o=scs_m.objs(k);
    
    if typeof(o)=='Block' then
      modelb=o.model;
      ident = o.graphics.id
      //if ident<>emptystr()&ident<>[] then
      select o.gui
      case 'IN_f' then
	inp=[inp modelb.ipar];
	etiquettes_in($+1) = ident;
      case 'BUSIN_f' then
	inp=[inp modelb.ipar];
	etiquettes_in($+1) = ident;
      case  'INIMPL_f'  then
	inp=[inp modelb.ipar];
	etiquettes_in($+1) = ident;
      case 'OUT_f' then
	outp=[outp modelb.ipar];
	etiquettes_out($+1) = ident;
      case 'BUSOUT_f' then
	outp=[outp modelb.ipar];
	etiquettes_out($+1) = ident;
      case 'OUTIMPL_f' then
	outp=[outp modelb.ipar];
	etiquettes_out($+1) = ident;
      case 'CLKIN_f' then
	cinp=[cinp modelb.ipar];
	etiquettes_clkin($+1) = ident;
      case 'CLKINV_f' then
	cinp=[cinp modelb.ipar];
	etiquettes_clkin($+1) = ident;
      case 'CLKOUT_f' then
	coutp=[coutp modelb.ipar];
	etiquettes_clkout($+1) = ident;
      case 'CLKOUTV_f' then
	coutp=[coutp modelb.ipar];
	etiquettes_clkout($+1) = ident;
      end
      //end
    end
  end
  if inp<>[] then
    [tmp,n_in]=sort(-inp)
    standard_etiquette(sbloc, list(etiquettes_in(n_in)), 'in')
  end

  if outp<>[] then
    [tmp,n_out]=sort(-outp)
    standard_etiquette(sbloc, list(etiquettes_out(n_out)), 'out')
  end
  if cinp<>[] then
    [tmp,n_cin]=sort(-cinp)
    standard_etiquette(sbloc, list(etiquettes_clkin(n_cin)), 'clkin')
  end
  if coutp<>[] then
    [tmp,n_cout]=sort(-coutp)
    standard_etiquette(sbloc, list(etiquettes_clkout(n_cout)), 'clkout')
  end
  xset('font',font(1),font(2))
endfunction
