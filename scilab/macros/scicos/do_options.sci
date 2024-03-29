function [edited,options]=do_options(opt,flag)
//
// Copyright INRIA
colors=string(1:xget("lastpattern")+2);
fontsSiz=['08','10','12','14','18','24'];
fontsIds=[ 'Courrier','Symbol','Times','Times Italic','Times Bold',..
	'Times B. It.'];
marksIds=['.','+','x','*','diamond fill.','diamond','triangle up',..
	'triangle down','trefle','circle'];

DashesIds=['Solid','-2-  -2-','-5-  -5-','-5-  -2-','-8-  -2-',..
	'-11- -2-','-11- -5-'];
//
ok=%f
edited=%f
options=opt
if flag=='3D' then
  With3D=options('3D')(1)
  if type(With3D)==4 then
    with3d=0;with3d(With3D)=1
  else
    with3d=With3D
  end
  if with3d then tt='Yes', else tt='No',end
  rep1=message(['Use 3D aspect?';'current choice is '+tt],['Yes';'No'])

    if rep1<>1 then rep1=0;end
    if rep1 then
      Color3D=options('3D')(2)
      rep2=getcolor('3D color',Color3D)
      if rep2==[] then rep2=Color3D,end
    else
      rep2=options('3D')(2)
    end
    ok=%t
    options('3D')(1)=rep1==1
    options('3D')(2)=rep2

elseif flag=='Background' then
  bac=options('Background')
  if bac==[] then bac=[8 1],end //compatibility
  if size(bac,'*')<2 then bac(2)=1,end //compatibility
  lcols_bg=list('colors Background',bac(1),colors);
  lcols_fg=list('colors Foreground',bac(2),colors);

  rep=[bac(1),bac(2)]
  rep1=getcolor('Background color',bac(1))
  if rep1<>[] then rep(1)=rep1;end
  rep2=getcolor('Foreground color',bac(2))
  if rep2<>[] then rep(2)=rep2;end
  if or(rep<>[bac(1) bac(2)]) then
    ok=%t
    options('Background')=rep
  end
elseif flag=='LinkColor' then
  lcols_rl=list('colors regular links',options('Link')(1),colors);
  lcols_el=list('colors event links  ',options('Link')(2),colors);
  rep=x_choices('Default regular and event link colors',list(lcols_rl,lcols_el))
  if rep<>[] then
    ok=%t
    options('Link')=rep
  end
elseif flag=='ID' then
  lfid_l=list('Link ID fontId',options('ID')(2)(1)+1,fontsIds);
  lfiz_l=list('Link ID fontsize',options('ID')(2)(2)+1,fontsSiz);
  lfic_l=list('Link ID color',options('ID')(2)(3),string(1:10));
  show_l=list('Show Link ID',options('ID')(2)(4)+1,['No' 'Yes']);
  lfid_b=list('Block ID fontId',options('ID')(1)(1)+1,fontsIds);
  lfiz_b=list('Block ID fontsize',options('ID')(1)(2)+1,fontsSiz);
  lfic_b=list('Block ID color',options('ID')(1)(3),string(1:10));
  show_b=list('Show Block ID',options('ID')(1)(4)+1,['No' 'Yes']);

  rep=x_choices('ID font definitions',list(lfid_l,lfiz_l,lfic_l,show_l,...
                                           lfid_b,lfiz_b,lfic_b,show_b))
  if rep<>[] then
    ok=%t
    options('ID')(1)=[rep(5:6)-1,rep(7),rep(8)-1]
    options('ID')(2)=[rep(1:2)-1,rep(3),rep(4)-1]
  end
elseif flag=='Cmap' then
  cmap=options('Cmap')
  while %t do
    [ok,R,G,B]=get_rgb_dialog();
    
    if ~ok then break,end
    if or(R<0|R>1)|or(G<0|G>1)|or(B<0|B>1) then
      x_message('RGB components are out of [0 1]')
    else
      break
    end
  end
  if ok then
    options('Cmap')=[options('Cmap');[R(:),G(:),B(:)]]
    if options('Background')==xget('lastpattern')+2 then
      options('Background')=options('Background')+size(R,'*')
    end
  end
  
end
if ok then
  edited=or(opt<>options)
end
    
endfunction
function [ok,R,G,B]=get_rgb_dialog()
  
txt=[' set current_color [tk_chooseColor]';'set c [string tolower $current_color]']
TCL_EvalStr(txt);
C=TCL_GetVar('c');
lc=length(C)
C=part(C,2:lc)
if lc==7 then 
  R=hex2dec(part(C,1:2))/255;
  G=hex2dec(part(C,3:4))/255;
  B=hex2dec(part(C,5:6))/255;
  ok=%t
else 
  if lc==13 then 
    R=hex2dec(part(C,1:4))/65535;
    G=hex2dec(part(C,5:8))/65535;
    B=hex2dec(part(C,9:12))/65535;
    ok=%t
  else
     R=-1;G=-1;B=-1;
     ok=%f
  end  
end

endfunction
