function [cpr,ok]=c_pass3(scs_m,cpr)
// Copyright INRIA
// Reconstruct the block list structure
//Last update Fady:15 Dec 2008
bllst=list();
corinv=cpr.corinv;
sim=cpr.sim;
for k=1:size(corinv)
  if type(corinv(k))==1 then
    if size(corinv(k),'*')==1 then
      bllst(k)=scs_m.objs(corinv(k)).model;
    else
      path=get_subobj_path(corinv(k));path($+1)='model';
      bllst(k)=scs_m(path);
    end
  else
    elem=corinv(k)(1)
    if size(elem,'*')==1 then
      oo=scs_m.objs(elem);
    else
      ppath=list('objs');
      for l=elem(1:$-1),
	ppath($+1)=l;
	ppath($+1)='model';
	ppath($+1)='rpar';ppath($+1)='objs';
      end
      ppath($+1)=elem($);
      oo=scs_m(ppath);
    end
    if is_modelica_block(oo) then
      //We force here update of parameters for THE modelica block
      [%state0,state,sim]=modipar(corinv(k),%state0,cpr.state,sim,scs_m,cpr.cor);
      cpr.state=state;
      
      m=scicos_model();
      
      //here it is assumed that modelica blocs have only scalar inputs/outputs
      m.in=ones(sim.inpptr(k+1)-sim.inpptr(k),1);
      m.out=ones(sim.outptr(k+1)-sim.outptr(k),1);
      if sim.funtyp(k)<10000 then
	n=(sim.xptr(k+1)-sim.xptr(k))
      else
	n=2*(sim.xptr(k+1)-sim.xptr(k))
      end
      m.state=cpr.state.x(sim.xptr(k)+(0:n-1));
      m.dstate=cpr.state.z(sim.zptr(k):sim.zptr(k+1)-1);

      m.rpar=sim.rpar(sim.rpptr(k):sim.rpptr(k+1)-1);
      m.ipar=sim.ipar(sim.ipptr(k):sim.ipptr(k+1)-1);
      for i=sim.opptr(k):sim.opptr(k+1)-1
        m.opar($+1)=sim.opar(i)
      end
      m.label='';
      m.sim=list(sim.funs(k),sim.funtyp(k));
      //here it is assumed that modelica blocs does not have output events
      bllst(k)=m;
    elseif is_sampleclk_block(oo) then //sampleclk force a full compilation
      ok=%f;
      return;
    else //other case
      warning(' Partial recompilation not yet implemented for such a block. The recompilation is not done. Force a full compilation.')
      ok=%f;
      return;
    end
  end
end
//

[inpptr,outptr,inplnk,outlnk,clkptr]=..
    sim(['inpptr','outptr','inplnk','outlnk','clkptr'])
// computes undetermined port sizes
[ok,bllst]=adjust(bllst,inpptr,outptr,inplnk,outlnk)
if ~ok then return; end

[lnksz,lnktyp]=lnkptrcomp(bllst,inpptr,outptr,inplnk,outlnk)
//
xptr=1;zptr=1;ozptr=1;rpptr=1;ipptr=1;opptr=1;
xc0=[];xcd0=[];xd0=[];oxd0=list();
rpar=[];ipar=[];opar=list();initexe=[];funtyp=[];labels=[];
funs=list();
//
for i=1:length(bllst)
  ll=bllst(i)
  labels=[labels;ll.label];

  //fun and funtype
  if type(ll.sim)==15 then
    if ll.sim(1)<>"scifunc" then
      funs(i)=ll.sim(1)  // replace except for compiled scifunc
    else
      funs(i)=%cpr.sim.funs(i)
    end
    funtyp(i,1)=ll.sim(2);
  else
    funs(i)=ll.sim;
    funtyp(i,1)=0;
  end

  //state
  X0=ll.state(:)
  if funtyp(i,1)<10000 then
    xcd0=[xcd0;0*X0]
    xc0=[xc0;X0]
    xptr(i+1)=xptr(i)+size(ll.state,'*')
  else
    xcd0=[xcd0;X0($/2+1:$)]
    xc0=[xc0;X0(1:$/2)]
    xptr(i+1)=xptr(i)+size(ll.state,'*')/2
  end

  //discrete state
  if (funtyp(i,1)==3 | funtyp(i,1)==5 | funtyp(i,1)==10005) then //sciblocks
     if ll.dstate==[] then xd0k=[]; else xd0k=var2vec(ll.dstate);end
  else
    xd0k=ll.dstate(:)
  end
  xd0=[xd0;xd0k];
  zptr=[zptr;zptr($)+size(xd0k,'*')]

  //object discrete state
  if type(ll.odstate)==15 then
    if ((funtyp(i,1)==5) | (funtyp(i,1)==10005)) then //sciblocks : don't extract
      if lstsize(ll.odstate)>0 then
        oxd0($+1)=ll.odstate
        ozptr=[ozptr;ozptr($)+1];
      else
        ozptr=[ozptr;ozptr($)];
      end
    elseif ((funtyp(i,1)==4) | (funtyp(i,1)==10004) | (funtyp(i,1)==2004))  //C blocks : extract
      ozsz=lstsize(ll.odstate);
      if ozsz>0 then
        for j=1:ozsz, oxd0($+1)=ll.odstate(j), end;
        ozptr=[ozptr;ozptr($)+ozsz];
      else
        ozptr=[ozptr;ozptr($)];
      end
    else
      ozptr=[ozptr;ozptr($)];
    end
  else
    //add an error message here please !
    ozptr=[ozptr;ozptr($)];
  end

  //rpar
  if (funtyp(i,1)==3 | funtyp(i,1)==5 | funtyp(i,1)==10005) then //sciblocks
    if ll.rpar==[] then rpark=[]; else rpark=var2vec(ll.rpar);end
  else
    rpark=ll.rpar(:)
  end
  rpar=[rpar;rpark]
  rpptr=[rpptr;rpptr($)+size(rpark,'*')]

  //ipar
  if type(ll.ipar)==1 then
    ipar=[ipar;ll.ipar(:)]
    ipptr=[ipptr;ipptr($)+size(ll.ipar,'*')]
  else
    ipptr=[ipptr;ipptr($)]
  end

  //opar
  if type(ll.opar)==15 then
    if ((funtyp(i,1)==5) | (funtyp(i,1)==10005)) then //sciblocks : don't extract
      if lstsize(ll.opar)>0 then
        opar($+1)=ll.opar
        opptr=[opptr;opptr($)+1];
       else
         opptr=[opptr;opptr($)];
       end
    elseif ((funtyp(i,1)==4) | (funtyp(i,1)==10004) | (funtyp(i,1)==2004)) then //C blocks : extract
      oparsz=lstsize(ll.opar);
      if oparsz>0 then
        for j=1:oparsz, opar($+1)=ll.opar(j), end;
        opptr=[opptr;opptr($)+oparsz];
      else
        opptr=[opptr;opptr($)];
      end
    else
      opptr=[opptr;opptr($)];
    end
  else
    //add an error message here please !
    opptr=[opptr;opptr($)];
  end

  //
  if ll.evtout<>[] then
    ll11=ll.firing
    if type(ll11)==4 then
      //this is for backward compatibility
      prt=find(ll11);nprt=prod(size(prt))
      initexe=[initexe;[i*ones(nprt,1),matrix(prt,nprt,1),zeros(nprt,1)]]
    else
      prt=find(ll11>=zeros(ll11));nprt=prod(size(prt))
      initexe=[initexe;..
	  [i*ones(nprt,1),matrix(prt,nprt,1),matrix(ll11(prt),nprt,1)]];
    end
  end
end
//initialize agenda
[tevts,evtspt,pointi]=init_agenda(initexe,clkptr)

sim.funtyp=funtyp
sim.funs=funs

sim.xptr=xptr
sim.zptr=zptr
sim.ozptr=ozptr

sim.inpptr=inpptr
sim.outptr=outptr
sim.inplnk=inplnk
sim.outlnk=outlnk
sim.rpar=rpar
sim.rpptr=rpptr
sim.ipar=ipar
sim.ipptr=ipptr
sim.opar=opar
sim.opptr=opptr
sim.clkptr=clkptr
sim.labels=labels
cpr.sim=sim;

outtb=list();
outtb=buildouttb(lnksz,lnktyp);

if exists('%scicos_solver')==0 then %scicos_solver=0,end
if max(funtyp)>10000 &%scicos_solver<100 then
  mprintf("\n\r\n\-Diagram contains implicit blocks => switching to the implicit solver\n\n\r");   
  %scicos_solver=100
end
if %scicos_solver>=100 then xc0=[xc0;xcd0],end

nb=size(clkptr,'*')-1;
iz0=zeros(nb,1);
state=cpr.state
state.x=xc0;
state.z=xd0;
state.oz=oxd0;
state.iz=iz0;
state.tevts=tevts;
state.evtspt=evtspt;
state.pointi=pointi;
state.outtb=outtb
cpr.state=state
endfunction
