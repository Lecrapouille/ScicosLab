function [ok,tt,dep_ut]=genfunc2(tt,inp,out,nci,nco,nx,nz,nrp,type_)
// manages dialog to get  definition (with scilab instruction) of a new scicos
// block
//!
// Copyright INRIA
ni=size(inp,1)
no=size(out,1)

mac    = []
ok     = %f
dep_ut = []
dep_u  = %f
dep_t  = %f
depp   = 't'
deqq   = 't'

if size(tt)<>7 then
  [txt1,txt0,txt2,txt3,txt4,txt5,txt6]=(' ',' ',' ',' ',' ',' ',' ')
else
  [txt1,txt0,txt2,txt3,txt4,txt5,txt6]=tt(1:7)
end

u=emptystr()
for k=1:ni
  u=u+'u'+string(k)+','
end

dep=['t,','x,','z,',u,'n_evi,','rpar']

if nx==0 then dep(2)=emptystr(),end
if nz==0 then dep(3)=emptystr(),end
//if nci==0 then dep(5)=emptystr(),end
if nrp==0 then dep(6)=emptystr(),end

//###### flag = 1 ######//
if no>0 then
  depp=strcat(dep([1:5,6]))

  w=[]
  for k=1:no
    w=[w
       'y'+string(k)+' (size: '+sci2exp(out(k,:))+')']
  end

  head=['Define function which computes the output'
        ''
        'Enter Scilab instructions defining'
        w
        'as a function(s) of '+depp]

  ptxtedit=scicos_txtedit(clos = 0,...
                          typ  = "Scifunc-1",...
                          head = head)
  textmp=txt1

  while %t do

    [txt,Quit] = scstxtedit(textmp,ptxtedit)

    if ptxtedit.clos==1 then
      break
    end

    if txt<>[] then
      txt1=txt
      // check if txt defines y from u
      mac=null()
      deff('[]=mac()',txt1,'n')
      ok1=check_mac(mac)
      if ok1 then
        vars=macrovar(mac)
        for k=1:ni
          if or(vars(3)=='u'+string(k)) then
            dep_u=%t
          end
        end
        if or(vars(3)=='t') then
          dep_t=%t
        end
        w=[]
        w(no)=%f
        for k=1:no
          if or(vars(5)=='y'+string(k)) then
            w(k)=%t
          end
        end
        if ~and(w) then
          k1=find(~w)
          w=[]
          for k=1:size(k1,'*')
            w=[w;'y'+string(k1(k))+' (size: '+sci2exp(out(k1(k),:))+')']
          end
          message('You did not define '+strcat(w,',')+' !')
        else
          ptxtedit.clos=1
        end
      end
      textmp=txt1
    end

    if Quit==1 then
      return
    end
  end
else
  txt1=' '
end

//###### flag - 0 ######//
if nx>0 then
  depp=strcat(dep([1:4,6]))

  head=['Define continuous states evolution'
        ''
        'Enter Scilab instructions defining:'
        'derivative of continuous state xd (size:'+string(nx)+')'
        'as  function(s) of '+depp]

  ptxtedit=scicos_txtedit(clos = 0,...
                          typ  = "Scifunc-0",...
                          head = head)

  if txt0==[] then
    txt0=' '
  end

  textmp=txt0

  while %t do

    [txt,Quit] = scstxtedit(textmp,ptxtedit)

    if ptxtedit.clos==1 then
      xpause(50000)
      break
    end

    if txt<>[] then
      txt0=txt
      mac=null()
      deff('[]=mac()',txt,'n')
      ok1=check_mac(mac)
      if ok1 then
        vars=macrovar(mac)
        if or(vars(5)=='xd') then
          ptxtedit.clos=1
        else
          message('You did not define xd !')
        end
      end
    else
      txt0=' '
    end
    textmp=txt0

    if Quit==1 then
      return
    end
  end
else
  txt0='xd=[]'
end

//###### flag - 2 ######//
if (nci>0 & (nx>0|nz>0)) | nz>0 then
  depp=strcat(dep([1:5,6]))

  head=['Define states evolution on discrete events'
        ''
        'You may define:']

  if nx>0 then
    head=[head
          '-new continuous state x (size:'+string(nx)+')']
  end
  if nz>0 then
    head=[head
          '-new discrete state z (size:'+string(nz)+')']
  end
  head=[head
       'at event time, as functions of '+depp]

  ptxtedit=scicos_txtedit(clos = 0,...
                          typ  = "Scifunc-2",...
                          head = head)

  if txt2==[] then
    txt2=' '
  end

  textmp=txt2

  while %t do

    [txt,Quit] = scstxtedit(textmp,ptxtedit)

    if ptxtedit.clos==1 then
      xpause(50000)
      break
    end

    if txt<>[] then
      txt2=txt
      mac=null()
      deff('[]=mac()',txt,'n')
      ok1=check_mac(mac)
      if ok1 then
        vars=macrovar(mac)
        if ~or(vars(5)=='x') & nx>0 then
          txt2=[txt2;
                'x=[]']
        end
        if ~or(vars(5)=='z') & nz>0 then
          txt2=[txt2;
                'z=[]']
        end
        ptxtedit.clos=1
      end
    else
      txt2=' '
    end
    textmp=txt2

    if Quit==1 then
      return
    end

  end
else
  txt2=' '
end

//###### flag - 3 ######//
if nci>0 & nco>0 then

  depp=strcat(dep)

  head=['Define output time events on discrete events'
        ''
        'Using '+depp+',you may set '
        'vector of output time events t_evo (size:'+string(nco)+')'
        'at event time. ']

  ptxtedit=scicos_txtedit(clos = 0,...
                          typ  = "Scifunc-3",...
                          head = head)

  if txt3==[] then
    txt3=' '
  end

  textmp=txt3

  while %t do

    [txt,Quit] = scstxtedit(textmp,ptxtedit)

    if ptxtedit.clos==1 then
      xpause(50000)
      break
    end

    if txt<>[] then
      txt3=txt
      mac=null()
      deff('[]=mac()',txt,'n')
      ok1=check_mac(mac)
      if ok1 then
        vars=macrovar(mac)
        if ~or(vars(5)=='t_evo') then
          txt3=[txt3;
                't_evo=[]']
        end
        ptxtedit.clos=1
      end
    else
      txt3=' '
    end
    textmp=txt3

    if Quit==1 then
      return
    end

  end
else
  txt3=' '
end

//###### flag - 4 ######//
depp=strcat(dep([2 3 6]))

head=['You may do whatever needed for initialization :'
      'File or graphic opening...,']

t1=[]
if nx>0 then
  t1=[t1
      '- continuous state x (size:'+string(nx)+')']
end
if nz>0 then
  t1=[t1
      '- discrete state z (size:'+string(nz)+')']
end
if t1<>[] then
  head=[head
        'You may also re-initialize:'
        t1]
end
if depp<>'' then
  head=[head;
        'as function(s) of '+depp]
end

ptxtedit=scicos_txtedit(clos = 0,...
                        typ  = "Scifunc-4",...
                        head = head)

if txt4==[] then
  txt4=' '
end

textmp=txt4

while %t do

  [txt,Quit] = scstxtedit(textmp,ptxtedit);

  if ptxtedit.clos==1 then
    xpause(50000)
    break
  end

  if txt<>[] then
    txt4=txt
    mac=null()
    deff('[]=mac()',txt,'n')
    ok1=check_mac(mac)
    if ok1 then
      ptxtedit.clos=1
    end
  else
    txt4=' '
  end
  textmp=txt4

  if Quit==1 then
    return
  end

end

//###### flag - 5 ######//
depp=strcat(dep([2 3 6]))

head=['You may do whatever needed to finish :'
      'File or graphic closing...,']

t1=[]
if nx>0 then
  t1=[t1
      '- continuous state x (size:'+string(nx)+')']
end
if nz>0 then
  t1=[t1
      '- discrete state z (size:'+string(nz)+')']
end
if t1<>[] then
  head=[head
        'You may also change final value of:'
        t1]
end
if depp<>'' then
  head=[head
        'as function(s) of '+depp]
end

ptxtedit=scicos_txtedit(clos = 0,...
                        typ  = "Scifunc-5",...
                        head = head)

if txt5==[] then
  txt5=' '
end

textmp=txt5

while %t do

  [txt,Quit] = scstxtedit(textmp,ptxtedit)

  if ptxtedit.clos==1 then
    xpause(50000)
    break
  end

  if txt<>[] then
    txt5=txt
    mac=null()
    deff('[]=mac()',txt5,'n')
    ok1=check_mac(mac)
    if ok1 then
      ptxtedit.clos=1
    end
  else
    txt5=' '
  end
  textmp=txt5

  if Quit==1 then
    return
  end

end

//###### flag - 6 ######//
if nx>0 | nz>0 | no>0 then

  depp=strcat(dep([2:4,6]))

  head=['You may define here functions imposing contraints'
        'on initial inputs, states and outputs.'
        'Note: these functions may be called more than once.']

  t1=[]
  if nx>0 then
    t1=[t1;'- state x (size:'+string(nx)+')']
  end
  if nz>0 then
    t1=[t1;'- state z (size:'+string(nz)+')']
  end

  w=[]
  for k=1:no
    w=[w;'- output y'+string(k)+' (size : '+sci2exp(out(k,:))+')']
  end

  t1=[t1;w]
  if t1<>[] then
    head=[head
          ''
          'Enter Scilab instructions defining:'
          t1]
  end
  if depp<>'' then
    head=[head;
          'as a function of '+depp]
  end

  if txt6==[] then
    txt6=' '
  end

  ptxtedit=scicos_txtedit(clos = 0,...
                          typ  = "Scifunc-6",...
                          head = head)

  textmp=txt6

  while %t do

    [txt,Quit] = scstxtedit(textmp,ptxtedit)

    if ptxtedit.clos==1 then
      xpause(50000)
      break
    end

    if txt<>[] then
      txt6=txt
      mac=null()
      deff('[]=mac()',txt6,'n')
      ok1=check_mac(mac)
      if ok1 then
        vars=macrovar(mac)
        for k=1:no
          if and(vars(5)<>'y'+string(k)) then
            txt6=[txt6;
                  'y'+string(k)+'=[]']
          end
        end
        ptxtedit.clos=1
      end
    else
      txt6=' '
    end
    textmp=txt6

    if Quit==1 then
      return
    end
  end
else
  txt6=' '
end

ok=%t

tt=list(txt1,txt0,txt2,txt3,txt4,txt5,txt6)
dep_ut=[dep_u dep_t]

endfunction
