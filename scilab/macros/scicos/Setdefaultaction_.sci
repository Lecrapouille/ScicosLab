function Setdefaultaction_()
// Copyright INRIA
  xinfo('Set Default Actions')
  if %scicos_action==%f then repp1=2, else repp1=1, end
  if %scicos_snap==%f then repp2=2, else repp2=1, end
  l1=list('Type',repp1,["Free","Smart"]);
  l2=list('Snap',repp2,["Yes","No"]);
  repp=x_choices('Set Default Action',list(l1,l2))
  if repp(1)==2 then %scicos_action=%f, else %scicos_action=%t, end
  if repp(2)==2 then %scicos_snap=%f, else %scicos_snap=%t, end
  xinfo(' ')
  Cmenu = [] ; %pt = [];
endfunction
