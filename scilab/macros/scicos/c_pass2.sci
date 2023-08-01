function cpr=c_pass2(bllst,connectmat,clkconnect,cor,corinv,flag)
  rhs=argn(2)
  if rhs <6 then flag="verbose",end

  if bllst==list() then
    message(['No block can be activated'])
    cpr=list()
    ok=%f;
    return
  end
  

  if exists('%scicos_solver')==0 then %scicos_solver=0,end


//correction of clkconnect.. Must be done before
clkconnect(find(clkconnect(:,2)==0),2)=1;


txt=["BLOCKS"
"0 0 0 1 c"];   // block 0 is added here


bnum=0
for bl=bllst
  bnum=bnum+1;
  if bl.blocktype=='l' then  //this should not happen because 
                             // synchro blocks should  not be always active
     clkconnect(find(clkconnect(:,3)==bnum&clkconnect(:,4)==0),4)=1
  end

  dep_u=bl.dep_ut(1:$-1);sizenin=size(bl.in,'*');sdepu=size(dep_u,'*');

  if (sizenin > sdepu) then
	dep_u=ones(1,sizenin)==1*bl.dep_ut(1);
  elseif sizenin==0 then
        dep_u=[]
  end

  if bl.nzcross<>0 then 
      if bl.blocktype=='l' then
          typ='lz'
      elseif size(bl.state,'*')>0 | bl.blocktype=='x' then 
          typ='xz', 
      else 
          typ='z',
      end
  else
      if size(bl.state,'*')>0  | bl.blocktype=='x' then typ='x', 
                                      else typ=bl.blocktype,end
  end


  xx="";if dep_u<>[] then for i=bool2s(dep_u),xx=xx+string(i)+' ';end;end
  txt=[txt;
       string(size(bl.in,'*'))+' '+string(size(bl.out,'*'))+' '+...
       string(size(bl.evtin,'*'))+' '+string(size(bl.evtout,'*'))+' '+...
       typ+' '+' '+xx];
end
  txt=[txt;
       "CONNECT"]
for i = 1:size(connectmat,1)
    txti=""
    for j =1:size(connectmat,2)
      txti=txti+' '+string(connectmat(i,j))
    end
    txt=[txt;txti]
end
  txt=[txt;
       "CLKCONNECT"]
for i = 1:size(clkconnect,1)
    txti=""
    for j =1:size(clkconnect,2)
      txti=txti+' '+string(clkconnect(i,j))
    end
    txt=[txt;txti]
end
txt=[txt;"END"]

pw=getcwd()
chdir(TMPDIR)

mdelete('datacos'); 
write('datacos',txt)

mdelete('mlcos.sci')

if MSDOS then
    unix_s(pathconvert(SCI)+"bin\paksazi.exe")
else
    unix_s(SCI+"/bin/paksazi.exe")
end

getf mlcos.sci

chdir(pw)

[ordptr,ordclk,critical,ztyp_blocks,dup,cord,oord,zord,iord,err_blks,err_msg,ok]=test_comp()

if ~ok then 
   if flag=="verbose" then
       ok=hilite_mult_objs(corinv,err_blks,err_msg)
   end
   cpr=list()
   return
end

critev=zeros(size(ordptr,1)-1,1);critev(critical)=1;

for i=1:size(dup,1)
  if dup(i,1)<>dup(i,2) then
     bllst(dup(i,1))=bllst(dup(i,2))
     ii=find(connectmat(:,3)==dup(i,2))
     tcon=connectmat(ii,:);tcon(:,3)=dup(i,1);
     connectmat=[connectmat;tcon]
     corinv(dup(i,1))=corinv(dup(i,2))
  end
end

[lnksz,lnktyp,inplnk,outlnk,clkptr,cliptr,inpptr,outptr,xptr,zptr,..
          ozptr,typ_mod,rpptr,ipptr,opptr,xc0,xcd0,xd0,oxd0,rpar,..
          ipar,opar,typ_z,typ_x,typ_m,funs,funtyp,initexe,labels,..
          blnk,blptr,ok]=extract_info(bllst,connectmat)

  if ~ok then
    message('Problem in port size or type');
    cpr=list()
    return,
  end
  
  // assign int32 to boolean type
  bool_index=find(lnktyp(:)==9)
  lnktyp(bool_index(:))=3
  
  typ_z0=typ_z;
  typ_z=zeros(typ_z);typ_z(ztyp_blocks)=typ_z0(ztyp_blocks);



  nb=size(typ_z,'*');
  zcptr=ones(nb+1,1);
  modptr=ones(nb+1,1);

  for i=1:nb
    zcptr(i+1)=zcptr(i)+typ_z(i)
    modptr(i+1)=modptr(i)+sign(typ_z(i))*typ_mod(i);
  end

  ztyp=sign(typ_z0)  //completement inutile pour simulation
                     // utiliser pour la generation de code
	
  if xptr($)==1 & zcptr($)>1 then
    message(['No continuous-time state. Thresholds are ignored; this '; ..
	     'may be OK if you don''t generate external events with them.'; ..
	     'If you want to reactivate the thresholds, the you need'; ..
	     'to include a block with continuous-time state in your diagram.'; ..
	     'You can for example include DUMMY CLSS block (linear palette).']);
  end

  subscr=[]
  nblk=size(bllst);ndcblk=0;
  sim=scicos_sim(funs=funs,xptr=xptr,zptr=zptr,ozptr=ozptr,..
                 zcptr=zcptr,inpptr=inpptr,outptr=outptr,..
                 inplnk=inplnk,outlnk=outlnk,rpar=rpar,rpptr=rpptr,..
                 ipar=ipar,ipptr=ipptr,opar=opar,opptr=opptr,..
                 clkptr=clkptr,ordptr=ordptr,execlk=ordclk,..
                 ordclk=ordclk,cord=cord,oord=oord,zord=zord,..
                 critev=critev(:),nb=nb,ztyp=ztyp,nblk=nblk,..
                 ndcblk=ndcblk,subscr=subscr,funtyp=funtyp,..
                 iord=iord,labels=labels,modptr=modptr);

  //initialize agenda
  [tevts,evtspt,pointi]=init_agenda(initexe,clkptr)

  //mod=0*ones(modptr($)-1,1)

  outtb=list();
  outtb=buildouttb(lnksz,lnktyp);

  iz0=zeros(nb,1);

  if max(funtyp)>10000 &%scicos_solver<100 then
      mprintf("\n\r\n\-Diagram contains implicit blocks => switching to the implicit solver\n\n\r");
    %scicos_solver=100
  end
  if %scicos_solver>=100 then xc0=[xc0;xcd0],end
  state=scicos_state()
  state.x=xc0
  state.z=xd0
  state.oz=oxd0
  state.iz=iz0
  state.tevts=tevts
  state.evtspt=evtspt
  state.pointi=pointi
  state.outtb=outtb
  //  state.mod=mod

  cpr=scicos_cpr(state=state,sim=sim,cor=cor,corinv=corinv);

endfunction



function [lnksz,lnktyp,inplnk,outlnk,clkptr,cliptr,inpptr,outptr,xptr,zptr,..
          ozptr,typ_mod,rpptr,ipptr,opptr,xc0,xcd0,xd0,oxd0,rpar,..
          ipar,opar,typ_z,typ_x,typ_m,funs,funtyp,initexe,labels,..
          blnk,blptr,ok]=extract_info(bllst,connectmat)
  ok=%t
  nbl=length(bllst)
  clkptr=zeros(nbl+1,1);clkptr(1)=1
  cliptr=clkptr;inpptr=cliptr;outptr=inpptr;
  xptr=1;zptr=1;ozptr=1;
  rpptr=clkptr;ipptr=clkptr;opptr=clkptr;
  //
  xc0=[];xcd0=[];xd0=[];
  oxd0=list()
  rpar=[];ipar=[];
  opar=list();

  fff=ones(nbl,1)==1
  typ_z=zeros(nbl,1);typ_x=fff;typ_m=fff;typ_mod=zeros(nbl,1);

  initexe=[];
  funs=list();
  funtyp=zeros(typ_z)
  labels=[]
  [ok,bllst]=adjust_inout(bllst,connectmat)
  if ok then
    [ok,bllst]=adjust_typ(bllst,connectmat)
  end

  // placed here to make sure nzcross and nmode correctly updated
  if ~ok then
    lnksz=[],lnktyp=[],inplnk=[],outlnk=[],clkptr=[],cliptr=[],inpptr=[],outptr=[],..
    xptr=[],zptr=[],ozptr=[],rpptr=[],ipptr=[],opptr=[],xc0=[],..
    xcd0=[],xd0=[],oxd0=list(),rpar=[],ipar=[],opar=list(),..
    typ_z=[],typ_x=[],typ_m=[],funs=[],funtyp=[],initexe=[],..
    labels=[],bexe=[],boptr=[],blnk=[],blptr=[]
    return;
  end

  for i=1:nbl
    if type(corinv(i))==1 & ~isequal(corinv(i),0) then
      o=scs_m(scs_full_path(corinv(i)))
      [bllsti,ok]=do_job_compile(o,bllst(i),i)
      if ~ok then
        lnksz=[],lnktyp=[],inplnk=[],outlnk=[],..
        clkptr=[],cliptr=[],inpptr=[],outptr=[],..
        xptr=[],zptr=[],ozptr=[],rpptr=[],ipptr=[],opptr=[],xc0=[],..
        xcd0=[],xd0=[],oxd0=list(),rpar=[],ipar=[],opar=list(),..
        typ_z=[],typ_x=[],typ_m=[],funs=[],funtyp=[],initexe=[],..
        labels=[],bexe=[],boptr=[],blnk=[],blptr=[]
        return
      else
        bllst(i)=bllsti
      end
    end

    ll=bllst(i)

    if type(ll.sim)==15 then
      funs(i)=ll.sim(1)
      funtyp(i,1)=ll.sim(2)
    else
      funs(i)=ll.sim;
      funtyp(i,1)=0;
    end
    if funtyp(i,1)>999&funtyp(i,1)<10000 then
      if ~c_link(funs(i)) then
	x_message(['A C or Fortran block is used but not linked';
		   'You can save your compiled diagram and load it';
		   'This will automatically link the C or Fortran function'])
      end
    end
    inpnum=ll.in;outnum=ll.out;cinpnum=ll.evtin;coutnum=ll.evtout;
    //
    inpptr(i+1)=inpptr(i)+size(inpnum,'*')
    outptr(i+1)=outptr(i)+size(outnum,'*')
    cliptr(i+1)=cliptr(i)+size(cinpnum,'*')
    clkptr(i+1)=clkptr(i)+size(coutnum,'*')
    //
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

    //dstate
    if (funtyp(i,1)==3 | funtyp(i,1)==5 | funtyp(i,1)==10005) then //sciblocks
      if ll.dstate==[] then xd0k=[]; else xd0k=var2vec(ll.dstate);end
    else
      xd0k=ll.dstate(:)
    end
    xd0=[xd0;xd0k]
    zptr(i+1)=zptr(i)+size(xd0k,'*')

    //odstate
    if type(ll.odstate)==15 then
      if ((funtyp(i,1)==5) | (funtyp(i,1)==10005)) then //sciblocks : don't extract
        if lstsize(ll.odstate)>0 then
          oxd0($+1)=ll.odstate
          ozptr(i+1)=ozptr(i)+1;
        else
          ozptr(i+1)=ozptr(i);
        end
      elseif ((funtyp(i,1)==4)    | (funtyp(i,1)==10004) |...
              (funtyp(i,1)==2004) | (funtyp(i,1)==12004))  //C blocks : extract
        ozsz=lstsize(ll.odstate);
        if ozsz>0 then
          for j=1:ozsz, oxd0($+1)=ll.odstate(j), end;
          ozptr(i+1)=ozptr(i)+ozsz;
        else
          ozptr(i+1)=ozptr(i);
        end
      else
        ozptr(i+1)=ozptr(i);
      end
    else
      //add an error message here please !
      ozptr(i+1)=ozptr(i);
    end

    //mod
    typ_mod(i)=ll.nmode;
    if typ_mod(i)<0 then
      message('Number of modes in block '+string(i)+'cannot b"+...
	      "e determined')
      ok=%f
    end

    //real paramaters
    if (funtyp(i,1)==3 | funtyp(i,1)==5 | funtyp(i,1)==10005) then //sciblocks
      if ll.rpar==[] then rpark=[]; else rpark=var2vec(ll.rpar);end
    else
      rpark=ll.rpar(:)
    end
    rpar=[rpar;rpark]
    rpptr(i+1)=rpptr(i)+size(rpark,'*')

    //integer parameters
    if type(ll.ipar)==1 then
      ipar=[ipar;ll.ipar(:)]
      ipptr(i+1)=ipptr(i)+size(ll.ipar,'*')
    else
      ipptr(i+1)=ipptr(i)
    end

    //object parameters
    if type(ll.opar)==15 then
     if ((funtyp(i,1)==5) | (funtyp(i,1)==10005)) then //sciblocks : don't extract
        if lstsize(ll.opar)>0 then
         opar($+1)=ll.opar
         opptr(i+1)=opptr(i)+1;
        else
         opptr(i+1)=opptr(i);
        end
     elseif ((funtyp(i,1)==4)    | (funtyp(i,1)==10004) |...
             (funtyp(i,1)==2004) | (funtyp(i,1)==12004)) then //C blocks : extract
       oparsz=lstsize(ll.opar);
       if oparsz>0 then
         for j=1:oparsz, opar($+1)=ll.opar(j), end;
         opptr(i+1)=opptr(i)+oparsz;
       else
         opptr(i+1)=opptr(i);
       end
     else
       opptr(i+1)=opptr(i);
     end
    else
      //add an error message here please !
      opptr(i+1)=opptr(i);
    end

    //    typ_z(i)=ll.blocktype=='z'
    typ_z(i)=ll.nzcross
    if typ_z(i)<0 then
      message('Number of zero crossings in block '+string(i)+'cannot b"+...
	      "e determined')
      ok=%f
    end
    typ_x(i)=ll.state<>[]|ll.blocktype=='x' // some blocks like delay
                                            // need to be in oord even
                                            // without state
				
    typ_m(i)=ll.blocktype=='m'
    //
    if ll.evtout<>[] then  
      ll11=ll.firing
      prt=find(ll11>=zeros(ll11))
      nprt=prod(size(prt))
      initexe=[initexe;[i*ones(nprt,1),matrix(prt,nprt,1),matrix(ll11(prt),nprt,1)]];
    end

    if type(ll.label)==10 then
      labels=[labels;ll.label(1)]
    else
      labels=[labels;' ']
    end
  end

  //
 
  blptr=1;
  blnk=[];

  for i=1:nbl
    r=connectmat(find(connectmat(:,1)==i),3:4);
    blnk=[blnk;r];
    blptr=[blptr;blptr($)+size(r,1)];
  end  
  //

  nlnk=size(connectmat,1)
  inplnk=zeros(inpptr($)-1,1);outlnk=zeros(outptr($)-1,1);ptlnk=1;
  lnksz=[];lnktyp=[];
  for jj=1:nlnk
    ko=outlnk(outptr(connectmat(jj,1))+connectmat(jj,2)-1)
    ki=inplnk(inpptr(connectmat(jj,3))+connectmat(jj,4)-1)
    if ko<>0 & ki<>0 then
      if ko>ki then 
	outlnk(outlnk>ko)=outlnk(outlnk>ko)-1
	outlnk(outlnk==ko)=ki
	inplnk(inplnk>ko)=inplnk(inplnk>ko)-1
	inplnk(inplnk==ko)=ki
	ptlnk=-1+ptlnk
        lnksz(ko,1)=[];
        lnksz(ko,2)=[];
        lnktyp(ko) =[];
      elseif ki>ko
	outlnk(outlnk>ki)=outlnk(outlnk>ki)-1
	outlnk(outlnk==ki)=ko
	inplnk(inplnk>ki)=inplnk(inplnk>ki)-1
	inplnk(inplnk==ki)=ko
	ptlnk=-1+ptlnk
        lnksz(ki,1)=[];
        lnksz(ki,2)=[];
        lnktyp(ki) =[];
      end
    elseif ko<>0 then
      inplnk(inpptr(connectmat(jj,3))+connectmat(jj,4)-1)=ko
    elseif ki<>0 then
      outlnk(outptr(connectmat(jj,1))+connectmat(jj,2)-1)=ki
    else
      outlnk(outptr(connectmat(jj,1))+connectmat(jj,2)-1)=ptlnk
      inplnk(inpptr(connectmat(jj,3))+connectmat(jj,4)-1)=ptlnk
      lnksz(ptlnk,1)=bllst(connectmat(jj,1)).out(connectmat(jj,2));
      lnksz(ptlnk,2)=bllst(connectmat(jj,1)).out2(connectmat(jj,2));
      lnktyp(ptlnk)=bllst(connectmat(jj,1)).outtyp(connectmat(jj,2));
      ptlnk=1+ptlnk
    end
  end

  //store unconnected outputs, if any, at the end of outtb
  unco=find(outlnk==0);
  for j=unco
    m=maxi(find(outptr<=j))
    n=j-outptr(m)+1
    nm=bllst(m).out(n)
    if nm<1 then
      under_connection(corinv(m),n,nm,-1,0,0,1),ok=%f,return,
    end
    nm2=bllst(m).out2(n)
    if nm2<1 then
      under_connection(corinv(m),n,nm2,-1,0,0,1),ok=%f,return,
    end
    lnksz($+1,1)=bllst(m).out(n);
    lnksz($,2)=bllst(m).out2(n);
    lnktyp($+1)=bllst(m).outtyp(n);
    outlnk(j)=maxi(outlnk)+1
  end

  //store unconnected inputs, if any, at the end of outtb
  unco=find(inplnk==0);
  for j=unco
    m=maxi(find(inpptr<=j))
    n=j-inpptr(m)+1
    nm=bllst(m).in(n)
    if nm<1 then 
     under_connection(corinv(m),n,nm,-2,0,0,1),ok=%f,return,
    end
    nm2=bllst(m).in2(n)
    if nm2<1 then
     under_connection(corinv(m),n,nm2,-2,0,0,1),ok=%f,return,
    end
    lnksz($+1,1)=bllst(m).in(n);
    lnksz($,2)=bllst(m).in2(n);
    lnktyp($+1)=bllst(m).intyp(n);
    inplnk(j)=maxi([inplnk;maxi(outlnk)])+1
  end

endfunction



//adjust_inout : it resolves positive, negative and null size
//               of in/out port dimensions of connected block.
//               If it's not done in a first pass, the second 
//               pass try to resolve negative or null port 
//               dimensions by asking user to informed dimensions 
//               with underconnection function.
//               It is a fixed point algorithm.
//
//in parameters  : bllst : list of blocks
//
//                 connectmat : matrix of connection
//                              connectmat(lnk,1) : source block
//                              connectmat(lnk,2) : source port
//                              connectmat(lnk,3) : target block
//                              connectmat(lnk,4) : target port
//
//out parameters : ok : a boolean flag to known if adjust_inout have
//                      succeeded to resolve the in/out port size
//                      - ok = %t : all size have been resolved in bllst
//                      - ok = %f : problem in size adjustement
//
//                 bllst : modified list of blocks

function [ok,bllst]=adjust_inout(bllst,connectmat)

  //Adjust in2/out2, inttyp/outtyp
  //in accordance to in/out in bllst
  [ko,bllst]=adjust_in2out2(bllst);
  if ~ko then ok=%f,return, end //if adjust_in2out2 failed then exit
                                //adjust_inout with flag ok=%f

  nlnk=size(connectmat,1) //nlnk is the number of link

  //loop on number of block (pass 1 and pass 2)
  for hhjj=1:length(bllst)+1
     //%%%%% pass 1 %%%%%//
     for hh=1:length(bllst)+1 //second loop on number of block
        ok=%t
        for jj=1:nlnk //loop on number of link

           //intyp/outtyp are the type of the
           //target port and the source port of the observed link
           outtyp = bllst(connectmat(jj,1)).outtyp(connectmat(jj,2))
           intyp = bllst(connectmat(jj,3)).intyp(connectmat(jj,4))
           //nnin/nnout are the size (two dimensions) of the
           //target port and the source port of the observed link
           //before adjust
           nnout(1,1)=bllst(connectmat(jj,1)).out(connectmat(jj,2))
           nnout(1,2)=bllst(connectmat(jj,1)).out2(connectmat(jj,2))
           nnin(1,1)=bllst(connectmat(jj,3)).in(connectmat(jj,4))
           nnin(1,2)=bllst(connectmat(jj,3)).in2(connectmat(jj,4))

           //loop on the two dimensions of source/target port
           for ndim=1:2
              //check test source/target sizes
              //in case of negatif equal target dimensions
              //nin/nout are the size (two dimensions) of the
              //target port and the source port of the observed link
              nout(1,1)=bllst(connectmat(jj,1)).out(connectmat(jj,2))
              nout(1,2)=bllst(connectmat(jj,1)).out2(connectmat(jj,2))
              nin(1,1)=bllst(connectmat(jj,3)).in(connectmat(jj,4))
              nin(1,2)=bllst(connectmat(jj,3)).in2(connectmat(jj,4))

              //first case : dimension of source and
              //             target ports are explicitly informed
              //             informed with positive size
              if(nout(1,ndim)>0&nin(1,ndim)>0) then
                 //if dimension of source and target port doesn't match
                 //then call bad_connection, set flag ok to false and exit
                 if nin(1,ndim)<>nout(1,ndim) then
                    bad_connection(corinv(connectmat(jj,1)),connectmat(jj,2),..
                                   nnout,outtyp,..
                                   corinv(connectmat(jj,3)),connectmat(jj,4),..
                                   nnin,intyp)
                    ok=%f;return
                 end

              //second case : dimension of source port is
              //              positive and dimension of
              //              target port is negative
              elseif(nout(1,ndim)>0&nin(1,ndim)<0) then
                 //find vector of input ports of target block with
                 //first/second dimension equal to size nin(1,ndim)
                 //and assign it to nout(1,ndim)
                 ww=find(bllst(connectmat(jj,3)).in==nin(1,ndim))
                 bllst(connectmat(jj,3)).in(ww)=nout(1,ndim)
                 ww=find(bllst(connectmat(jj,3)).in2==nin(1,ndim))
                 bllst(connectmat(jj,3)).in2(ww)=nout(1,ndim)

                 //find vector of output ports of target block with
                 //first/second dimension equal to size nin(1,ndim)
                 //and assign it to nout(1,ndim)
                 ww=find(bllst(connectmat(jj,3)).out==nin(1,ndim))
                 bllst(connectmat(jj,3)).out(ww)=nout(1,ndim)
                 ww=find(bllst(connectmat(jj,3)).out2==nin(1,ndim))
                 bllst(connectmat(jj,3)).out2(ww)=nout(1,ndim)

                 //find vector of output ports of target block with
                 //ndim dimension equal to zero and sum the ndim
                 //dimension of all input ports of target block
                 //to be the new dimension of the ndim dimension
                 //of the output ports of the target block
                 if ndim==1 then
                   ww=find(bllst(connectmat(jj,3)).out==0)
                   if (ww<>[]&mini(bllst(connectmat(jj,3)).in(:))>0) then
                      bllst(connectmat(jj,3)).out(ww)=sum(bllst(connectmat(jj,3)).in(:))
                   end
                 elseif ndim==2 then
                   ww=find(bllst(connectmat(jj,3)).out2==0)
                   if (ww<>[]&mini(bllst(connectmat(jj,3)).in2(:))>0) then
                      bllst(connectmat(jj,3)).out2(ww)=sum(bllst(connectmat(jj,3)).in2(:))
                   end
                 end

                 //if nzcross of the target block match with
                 //the negative dimension nin(1,ndim) then
                 //adjust it to nout(1,ndim)
                 if bllst(connectmat(jj,3)).nzcross==nin(1,ndim) then
                    bllst(connectmat(jj,3)).nzcross=nout(1,ndim)
                 end
                 //if nmode of the target block match with
                 //the negative dimension nin(1,ndim) then
                 //adjust it to nout(1,ndim)
                 if bllst(connectmat(jj,3)).nmode==nin(1,ndim) then
                    bllst(connectmat(jj,3)).nmode=nout(1,ndim)
                 end

              //third case : dimension of source port is
              //             negative and dimension of
              //             target port is positive
              elseif(nout(1,ndim)<0&nin(1,ndim)>0) then
                 //find vector of output ports of source block with
                 //first/second dimension equal to size nout(1,ndim)
                 //and assign it to nin(1,ndim)
                 ww=find(bllst(connectmat(jj,1)).out==nout(1,ndim))
                 bllst(connectmat(jj,1)).out(ww)=nin(1,ndim)
                 ww=find(bllst(connectmat(jj,1)).out2==nout(1,ndim))
                 bllst(connectmat(jj,1)).out2(ww)=nin(1,ndim)

                 //find vector of input ports of source block with
                 //first/second dimension equal to size nout(1,ndim)
                 //and assign it to nin(1,ndim)
                 ww=find(bllst(connectmat(jj,1)).in==nout(1,ndim))
                 bllst(connectmat(jj,1)).in(ww)=nin(1,ndim)
                 ww=find(bllst(connectmat(jj,1)).in2==nout(1,ndim))
                 bllst(connectmat(jj,1)).in2(ww)=nin(1,ndim)

                 //find vector of input ports of source block with
                 //ndim dimension equal to zero and sum the ndim
                 //dimension of all output ports of source block
                 //to be the new dimension of the ndim dimension
                 //of the input ports of the source block
                 if ndim==1 then
                   ww=find(bllst(connectmat(jj,1)).in==0)
                   if (ww<>[]&mini(bllst(connectmat(jj,1)).out(:))>0) then
                      bllst(connectmat(jj,1)).in(ww)=sum(bllst(connectmat(jj,1)).out(:))
                   end
                 elseif ndim==2 then
                   ww=find(bllst(connectmat(jj,1)).in2==0)
                   if (ww<>[]&mini(bllst(connectmat(jj,1)).out2(:))>0) then
                      bllst(connectmat(jj,1)).in2(ww)=sum(bllst(connectmat(jj,1)).out2(:))
                   end
                 end

                 //if nzcross of the source block match with
                 //the negative dimension nout(1,ndim) then
                 //adjust it to nin(1,ndim)
                 if bllst(connectmat(jj,1)).nzcross==nout(1,ndim) then
                    bllst(connectmat(jj,1)).nzcross=nin(1,ndim)
                 end
                 //if nmode of the source block match with
                 //the negative dimension nout(1,ndim) then
                 //adjust it to nin(1,ndim)
                 if bllst(connectmat(jj,1)).nmode==nout(1,ndim) then
                    bllst(connectmat(jj,1)).nmode=nin(1,ndim)
                 end

              //fourth case : a dimension of source port is
              //              null
              elseif(nout(1,ndim)==0) then
                 //set ww to be the vector of size of the ndim
                 //dimension of input port of the source block
                 if ndim==1 then
                    ww=bllst(connectmat(jj,1)).in(:)
                 elseif ndim==2 then
                    ww=bllst(connectmat(jj,1)).in2(:)
                 end

                 //test if all size of the ndim dimension of input
                 //port of the source block is positive
                 if mini(ww)>0 then
                    //test if the dimension of the target port
                    //is positive
                    if nin(1,ndim)>0 then

                       //if the sum of the size of the ndim dimension of the input 
                       //port of the source block is equal to the size of the ndim dimension
                       //of the target port, then the size of the ndim dimension of the source
                       //port is equal to nin(1,ndim)
                       if sum(ww)==nin(1,ndim) then
                          if ndim==1 then
                             bllst(connectmat(jj,1)).out(connectmat(jj,2))=nin(1,ndim)
                          elseif ndim==2 then
                             bllst(connectmat(jj,1)).out2(connectmat(jj,2))=nin(1,ndim)
                          end
                       //else call bad_connection, set flag ok to false and exit
                       else
                          bad_connection(corinv(connectmat(jj,1)),0,0,1,-1,0,0,1)
                          ok=%f;return
                       end

                    //if the ndim dimension of the target port is negative
                    //then the size of the ndim dimension of the source port
                    //is equal to the sum of the size of the ndim dimension
                    //of input ports of source block, and flag ok is set to false
                    else
                       if ndim==1 then
                         bllst(connectmat(jj,1)).out(connectmat(jj,2))=sum(ww)
                       elseif ndim==2 then
                         bllst(connectmat(jj,1)).out2(connectmat(jj,2))=sum(ww)
                       end
                       ok=%f
                    end

                 else
                    //set nww to be the vector of all negative size of input ports
                    //of the source block
                    nww=ww(find(ww<0))

                    //if all negative size have same size and if size of the
                    //ndim dimension of the target port is positive then assign
                    //size of the ndim dimension of the source port to nin(1,ndim)
                    if norm(nww-nww(1),1)==0 & nin(1,ndim)>0 then
                       if ndim==1 then
                          bllst(connectmat(jj,1)).out(connectmat(jj,2))=nin(1,ndim)
                       elseif ndim==2 then
                          bllst(connectmat(jj,1)).out2(connectmat(jj,2))=nin(1,ndim)
                       end

                       //compute a size to be the difference between the size
                       //of the ndim dimension of the target block and sum of positive 
                       //size of input ports of the source block divided by the number
                       //of input ports of source block with same negative size
                       k=(nin(1,ndim)-sum(ww(find(ww>0))))/size(nww,'*')

                       //if this size is a positive integer then assign it
                       //to the size of the ndim dimension of input ports of the 
                       //source block which have negative size
                       if k==int(k)&k>0 then
                          if ndim==1 then
                             bllst(connectmat(jj,1)).in(find(ww<0))=k
                          elseif ndim==2 then
                             bllst(connectmat(jj,1)).in2(find(ww<0))=k
                          end
                       //else call bad_connection, set flag ok to false and exit
                       else
                          bad_connection(corinv(connectmat(jj,1)),0,0,1,-1,0,0,1)
                          ok=%f;return
                       end

                    //set flag ok to false
                    else
                      ok=%f
                    end

                 end

              //fifth case : a dimension of target port is
              //             null
              elseif(nin(1,ndim)==0) then
                 //set ww to be the vector of size of the ndim
                 //dimension of output port of the target block
                 if ndim==1 then
                    ww=bllst(connectmat(jj,3)).out(:)
                 elseif ndim==2 then
                    ww=bllst(connectmat(jj,3)).out2(:)
                 end

                 //test if all size of the ndim dimension of output
                 //port of the target block is positive
                 if mini(ww)>0 then
                    //test if the dimension of the source port
                    //is positive
                    if nout(1,ndim)>0 then

                       //if the sum of the size of the ndim dimension of the output 
                       //port of the target block is equal to the size of the ndim dimension
                       //of the source port, then the size of the ndim dimension of the target
                       //port is equal to nout(1,ndim)
                       if sum(ww)==nout(1,ndim) then
                          if ndim==1 then
                             bllst(connectmat(jj,3)).in(connectmat(jj,4))=nout(1,ndim)
                          elseif ndim==2 then
                             bllst(connectmat(jj,3)).in2(connectmat(jj,4))=nout(1,ndim)
                          end
                       //else call bad_connection, set flag ok to false and exit
                       else
                          bad_connection(corinv(connectmat(jj,3)),0,0,1,-1,0,0,1)
                          ok=%f;return
                       end

                    //if the ndim dimension of the source port is negative
                    //then the size of the ndim dimension of the target port
                    //is equal to the sum of the size of the ndim dimension
                    //of output ports of target block, and flag ok is set to false
                    else
                       if ndim==1 then
                         bllst(connectmat(jj,3)).in(connectmat(jj,4))=sum(ww)
                       elseif ndim==2 then
                         bllst(connectmat(jj,3)).in2(connectmat(jj,4))=sum(ww)
                       end
                       ok=%f
                    end

                 else
                    //set nww to be the vector of all negative size of output ports
                    //of the target block
                    nww=ww(find(ww<0))

                    //if all negative size have same size and if size of the
                    //ndim dimension of the source port is positive then assign
                    //size of the ndim dimension of the target port to nout(1,ndim)
                    if norm(nww-nww(1),1)==0 & nout(1,ndim)>0 then
                       if ndim==1 then
                          bllst(connectmat(jj,3)).in(connectmat(jj,4))=nout(1,ndim)
                       elseif ndim==2 then
                          bllst(connectmat(jj,3)).in2(connectmat(jj,4))=nout(1,ndim)
                       end

                       //compute a size to be the difference between the size
                       //of the ndim dimension of the source block and sum of positive 
                       //size of output ports of the target block divided by the number
                       //of output ports of target block with same negative size
                       k=(nout(1,ndim)-sum(ww(find(ww>0))))/size(nww,'*')

                       //if this size is a positive integer then assign it
                       //to the size of the ndim dimension of output ports of the 
                       //target block which have negative size
                       if k==int(k)&k>0 then
                          if ndim==1 then
                             bllst(connectmat(jj,3)).out(find(ww<0))=k
                          elseif ndim==2 then
                             bllst(connectmat(jj,3)).out2(find(ww<0))=k
                          end
                       //else call bad_connection, set flag ok to false and exit
                       else
                          bad_connection(corinv(connectmat(jj,3)),0,0,1,-1,0,0,1)
                          ok=%f;return
                       end

                    //set flag ok to false
                    else
                      ok=%f
                    end

                 end

              //sixth (& last) case : dimension of both source 
              //                      and target port are negatives
              else
                 ok=%f //set flag ok to false
              end
           end
        end
        if ok then return, end //if ok is set true then exit adjust_inout
     end
     //if failed then display message
     message(['Not enough information to find port sizes';
              'I try to find the problem']);

     //%%%%% pass 2 %%%%%//
     findflag=%f //set findflag to false

     for jj=1:nlnk //loop on number of block
        //nin/nout are the size (two dimensions) of the
        //target port and the source port of the observed link
        nout(1,1)=bllst(connectmat(jj,1)).out(connectmat(jj,2))
        nout(1,2)=bllst(connectmat(jj,1)).out2(connectmat(jj,2))
        nin(1,1)=bllst(connectmat(jj,3)).in(connectmat(jj,4))
        nin(1,2)=bllst(connectmat(jj,3)).in2(connectmat(jj,4))

        //loop on the two dimensions of source/target port
        //only case : target and source ports are both
        //            negatives or null
        if nout(1,1)<=0&nin(1,1)<=0 | nout(1,2)<=0&nin(1,2)<=0 then
            findflag=%t;
            //
            ninnout=under_connection(corinv(connectmat(jj,1)),connectmat(jj,2),nout(1,ndim),..
                                       corinv(connectmat(jj,3)),connectmat(jj,4),nin(1,ndim),1)
            //
            if size(ninnout,2) <> 2 then ok=%f;return;end
            if ninnout==[] then ok=%f;return;end
            if ninnout(1,1)<=0 | ninnout(1,2)<=0 then ok=%f;return;end
            //
            ww=find(bllst(connectmat(jj,1)).out==nout(1,1))
            bllst(connectmat(jj,1)).out(ww)=ninnout(1,1)
            ww=find(bllst(connectmat(jj,1)).out2==nout(1,1))
            bllst(connectmat(jj,1)).out2(ww)=ninnout(1,1)

            ww=find(bllst(connectmat(jj,1)).out==nout(1,2));
            bllst(connectmat(jj,1)).out(ww)=ninnout(1,2);
            ww=find(bllst(connectmat(jj,1)).out2==nout(1,2));
            bllst(connectmat(jj,1)).out2(ww)=ninnout(1,2);
            //

            if bllst(connectmat(jj,1)).nzcross==nout(1,1) then
               bllst(connectmat(jj,1)).nzcross=ninnout(1,1);
            end
            if bllst(connectmat(jj,1)).nzcross==nout(1,2) then
               bllst(connectmat(jj,1)).nzcross=ninnout(1,2);
            end
            //
            if bllst(connectmat(jj,1)).nmode==nout(1,1) then
               bllst(connectmat(jj,1)).nmode=ninnout(1,1);
            end
            if bllst(connectmat(jj,1)).nmode==nout(1,2) then
               bllst(connectmat(jj,1)).nmode=ninnout(1,2);
            end
            //
            ww=find(bllst(connectmat(jj,1)).in==nout(1,1))
            bllst(connectmat(jj,1)).in(ww)=ninnout(1,1)
            ww=find(bllst(connectmat(jj,1)).in2==nout(1,1))
            bllst(connectmat(jj,1)).in2(ww)=ninnout(1,1)

            ww=find(bllst(connectmat(jj,1)).in==nout(1,2));
            bllst(connectmat(jj,1)).in(ww)=ninnout(1,2);
            ww=find(bllst(connectmat(jj,1)).in2==nout(1,2));
            bllst(connectmat(jj,1)).in2(ww)=ninnout(1,2);
            //
            ww=find(bllst(connectmat(jj,1)).in==0);
            if (ww<>[]&mini(bllst(connectmat(jj,1)).out(:))>0) then 
               bllst(connectmat(jj,1)).in(ww)=sum(bllst(connectmat(jj,1)).out);
            end

            ww=find(bllst(connectmat(jj,1)).in2==0);
            if (ww<>[]&mini(bllst(connectmat(jj,1)).out2(:))>0) then 
                 bllst(connectmat(jj,1)).in2(ww)=sum(bllst(connectmat(jj,1)).out2);
            end
            //
            ww=find(bllst(connectmat(jj,3)).in==nin(1,1));
            bllst(connectmat(jj,3)).in(ww)=ninnout(1,1);
            ww=find(bllst(connectmat(jj,3)).in2==nin(1,1));
            bllst(connectmat(jj,3)).in2(ww)=ninnout(1,1);

            ww=find(bllst(connectmat(jj,3)).in==nin(1,2));
            bllst(connectmat(jj,3)).in(ww)=ninnout(1,2);
            ww=find(bllst(connectmat(jj,3)).in2==nin(1,2));
            bllst(connectmat(jj,3)).in2(ww)=ninnout(1,2);
            //
            if bllst(connectmat(jj,3)).nzcross==nin(1,1) then
               bllst(connectmat(jj,3)).nzcross=ninnout(1,1);
            end
            if bllst(connectmat(jj,3)).nzcross==nin(1,2) then
               bllst(connectmat(jj,3)).nzcross=ninnout(1,2);
            end
            if bllst(connectmat(jj,3)).nmode==nin(1,1) then
               bllst(connectmat(jj,3)).nmode=ninnout(1,1);
            end
            if bllst(connectmat(jj,3)).nmode==nin(1,2) then
               bllst(connectmat(jj,3)).nmode=ninnout(1,2);
            end
            //
            ww=find(bllst(connectmat(jj,3)).out==nin(1,1));
            bllst(connectmat(jj,3)).out(ww)=ninnout(1,1);
            ww=find(bllst(connectmat(jj,3)).out2==nin(1,1));
            bllst(connectmat(jj,3)).out2(ww)=ninnout(1,1);

            ww=find(bllst(connectmat(jj,3)).out==nin(1,2));
            bllst(connectmat(jj,3)).out(ww)=ninnout(1,2);
            ww=find(bllst(connectmat(jj,3)).out2==nin(1,2));
            bllst(connectmat(jj,3)).out2(ww)=ninnout(1,2);
            //
            ww=find(bllst(connectmat(jj,3)).out==0);
            if (ww<>[]&mini(bllst(connectmat(jj,3)).in(:))>0) then
               bllst(connectmat(jj,3)).out(ww)=sum(bllst(connectmat(jj,3)).in(:));
            end
            ww=find(bllst(connectmat(jj,3)).out2==0);
            if (ww<>[]&mini(bllst(connectmat(jj,3)).in2(:))>0) then
               bllst(connectmat(jj,3)).out2(ww)=sum(bllst(connectmat(jj,3)).in2(:));
            end
        end
     end

     //if failed then display message
     if ~findflag then 
        message(['I cannot find a link with undetermined size';
                 'My guess is that you have a block with unconnected';
                 'undetermined output ports']);
        ok=%f;return;
     end
  end
endfunction

function ninnout=under_connection(path_out,prt_out,nout,path_in,prt_in,nin,flagg)
// alert for badly connected blocks
// path_out : Path of the "from block" in scs_m
// path_in  : Path of the "to block" in scs_m
//!

  //** save the current figure handle
  gh_wins = gcf();

  if path_in==-1 | path_in==-2 then
    path=path_out(1:$-1)
    path_out=path_out($)
    mxwin=maxi(winsid())
    for k=1:size(path,'*')
      hilite_obj(path(k))
      scs_m=scs_m.objs(path(k)).model.rpar;
      scs_show(scs_m,mxwin+k)
    end
   
    hilite_obj(path_out);
    if path_in==-1 then
      message(['One of this block''s outputs has negative size';
	     'Please check.'])
    else
      message(['The input port '+string(prt_out)+' of this block have a negative size.';
	     'Please check.'])
    end
    unhilite_obj(path_out);

    for k=size(path,'*'):-1:1,
      gh_del = scf(mxwin+k);
      delete(gh_del)
    end
    if path<>[] then
      scf(gh_wins);
      unhilite_obj(path(1))
    end

    ninnout=0
    return
  end


  lp=mini(size(path_out,'*'),size(path_in,'*'))
  k=find(path_out(1:lp)<>path_in(1:lp))
  if k==[] then k=lp,end  // same block on  both ends
  path=path_out(1:k(1)-1) // common superbloc path

  if (size(path_out,'*')==size(path_in,'*'))&(size(path_out,'*')==size(path,'*')+1) then
     canshowlink=%t
  else
     canshowlink=%f
  end

  path_out=path_out(k(1)) // "from" block number
  path_in=path_in(k(1))   // "to" block number

  //##
  codegen=%f
  if isdef('Code_gene_run') then
    if ~ALL then
      codegen=%t
    end
  end

  if codegen then
    mxwin=maxi(winsid())
    path=path+1 // Consider locally compiled superblock as a superblock
    for k=1:size(path,'*')
      //hilite_obj(all_scs_m.objs(numk(k)))
      hilite_obj(numk(k))
      scs_m=all_scs_m.objs(numk(k)).model.rpar;
      scs_show(scs_m,mxwin+k)
    end
    //hilite_obj(scs_m.objs(path_out))
    hilite_obj(path_out)
    //if or(path_in<>path_out) then hilite_obj(scs_m.objs(path_in)),end
    if or(path_in<>path_out) then hilite_obj(path_in),end
    if flagg==1 then
      ninnout=evstr(dialog(['Hilited block(s) have connected ports ';
                    'with  sizes that cannot be determined by the context';
                    'what is the size of this link'],'[1,1]'))
    else 
      ninnout=evstr(dialog(['Hilited block(s) have connected ports ';
                    'with  types that cannot be determined by the context';
                    'what is the type of this link'],'1'))
    end
      
    for k=size(path,'*'):-1:1,
      //** select the mxwin+k window and get the handle
      gh_del = scf(mxwin+k);
      //** delete the window
      delete(gh_del)
    end
    //scs_m=null()
    //unhilite_obj(all_scs_m.objs(numk(1)))

    //** restore the active window
    scf(gh_wins);

    unhilite_obj(numk(1))
  else

    mxwin=maxi(winsid())
    kk=[];
    for k=1:size(path,'*')
      hilite_obj(path(k))
      scs_m=scs_m.objs(path(k)).model.rpar;
      scs_show(scs_m,mxwin+k)
    end
    kk=[path_out]
    if or(path_in<>path_out) then kk=[kk;path_in], end
    if canshowlink then  
      if prt_in<>[] & prt_out<>[] then
        if prt_in >0 & prt_out >0 then
          if scs_m.objs(path_out).graphics.pout(prt_out) == ...
              scs_m.objs(path_in).graphics.pin(prt_in) then // in absence of split
                kk=[kk;scs_m.objs(path_out).graphics.pout(prt_out)]
          end
        end
      end
    end
    hilite_obj(kk)
    if flagg==1 then
	ninnout=evstr(dialog(['Hilited block(s) have connected ports ';
	    'with  sizes that cannot be determined by the context';
	    'what is the size of this link'],'[1,1]'))
    else
	ninnout=evstr(dialog(['Hilited block(s) have connected ports ';
	    'with  types that cannot be determined by the context';
	    'what is the size of this link'],'1'))
    end
    unhilite_obj(kk)

    for k=size(path,'*'):-1:1,
      gh_del = scf(mxwin+k);
      delete(gh_del)
    end
    if path <> [] then
      scf(gh_wins);
      unhilite_obj(path(1))
    end
  end
endfunction

// adjust_typ: It resolves positives and negatives port types.
//		   Its Algorithm is based on the algorithm of adjust_inout
// Fady NASSIF: 14/06/2007

function [ok,bllst]=adjust_typ(bllst,connectmat)

for i=1:length(bllst)
  if size(bllst(i).in,1)<>size(bllst(i).intyp,'*') then
    bllst(i).intyp=bllst(i).intyp(1)*ones(size(bllst(i).in,1),1);
  end
  if size(bllst(i).out,1)<>size(bllst(i).outtyp,'*') then
    bllst(i).outtyp=bllst(i).outtyp(1)*ones(size(bllst(i).out,1),1);
  end
end
nlnk=size(connectmat,1) 
for hhjj=1:length(bllst)+1
  for hh=1:length(bllst)+1 
    ok=%t
    for jj=1:nlnk 
      nnout(1,1)=bllst(connectmat(jj,1)).out(connectmat(jj,2))
      nnout(1,2)=bllst(connectmat(jj,1)).out2(connectmat(jj,2))
      nnin(1,1)=bllst(connectmat(jj,3)).in(connectmat(jj,4))
      nnin(1,2)=bllst(connectmat(jj,3)).in2(connectmat(jj,4))
      outtyp = bllst(connectmat(jj,1)).outtyp(connectmat(jj,2))
      intyp = bllst(connectmat(jj,3)).intyp(connectmat(jj,4))
      
      //first case : types of source and
      //             target ports are explicitly informed
      //             with positive types
      if (intyp>0 & outtyp>0) then
	//if types of source and target port doesn't match and aren't double and complex
	//then call bad_connection, set flag ok to false and exit
	
	if intyp<>outtyp then
	  if (intyp==1 & outtyp==2) then
	    bllst(connectmat(jj,3)).intyp(connectmat(jj,4))=2;
	  elseif (intyp==2 & outtyp==1) then
	    bllst(connectmat(jj,1)).outtyp(connectmat(jj,2))=2;
	  else
	    bad_connection(corinv(connectmat(jj,1)),connectmat(jj,2),..
		nnout,outtyp,..
		corinv(connectmat(jj,3)),connectmat(jj,4),..
		nnin,intyp,1)
	    ok=%f;
	    return
	  end
	end
	
	//second case : type of source port is
	//              positive and type of
	//              target port is negative
      elseif(outtyp>0&intyp<0) then
	//find vector of input ports of target block with
	//type equal to intyp
	//and assign it to outtyp
	ww=find(bllst(connectmat(jj,3)).intyp==intyp)
	bllst(connectmat(jj,3)).intyp(ww)=outtyp
	
	//find vector of output ports of target block with
	//type equal to intyp
	//and assign it to outtyp
	ww=find(bllst(connectmat(jj,3)).outtyp==intyp)
	bllst(connectmat(jj,3)).outtyp(ww)=outtyp
	
	//third case : type of source port is
	//             negative and type of
	//             target port is positive
      elseif(outtyp<0&intyp>0) then
	//find vector of output ports of source block with
	//type equal to outtyp
	//and assign it to intyp
	ww=find(bllst(connectmat(jj,1)).outtyp==outtyp)
	bllst(connectmat(jj,1)).outtyp(ww)=intyp
	
	//find vector of input ports of source block with
	//type equal to size outtyp
	//and assign it to intyp
	ww=find(bllst(connectmat(jj,1)).intyp==outtyp)
	bllst(connectmat(jj,1)).intyp(ww)=intyp
	
	
	//fourth (& last) case : type of both source 
	//                      and target port are negatives
      else
	ok=%f //set flag ok to false
      end
    end
    if ok then return, end //if ok is set true then exit adjust_typ
  end
  //if failed then display message
  message(['Not enough information to find port type';..
	   'I will try to find the problem']);
  findflag=%f 
  for jj=1:nlnk 
    nouttyp=bllst(connectmat(jj,1)).outtyp(connectmat(jj,2))
    nintyp=bllst(connectmat(jj,3)).intyp(connectmat(jj,4))
    
    //loop on the two dimensions of source/target port
    //only case : target and source ports are both
    //            negatives or null
    if nouttyp<=0 & nintyp<=0 then
      findflag=%t;
      //
      inouttyp=under_connection(corinv(connectmat(jj,1)),connectmat(jj,2),nouttyp,..
	  corinv(connectmat(jj,3)),connectmat(jj,4),nintyp,2)			   
      //
      if inouttyp<1|inouttyp>8 then ok=%f;return;end
      //
      ww=find(bllst(connectmat(jj,1)).outtyp==nouttyp)
      bllst(connectmat(jj,1)).outtyp(ww)=inouttyp
      
      //
      ww=find(bllst(connectmat(jj,1)).intyp==nouttyp)
      bllst(connectmat(jj,1)).intyp(ww)=inouttyp
      
      ww=find(bllst(connectmat(jj,3)).intyp==nintyp)
      bllst(connectmat(jj,3)).intyp(ww)=inouttyp
      //
      ww=find(bllst(connectmat(jj,3)).outtyp==nintyp)
      bllst(connectmat(jj,3)).outtyp(ww)=inouttyp
      
      //
    end
  end
  //if failed then display message
  if ~findflag then 
    message(['I cannot find a link with undetermined size';
	'My guess is that you have a block with unconnected';
	'undetermined types']);
    ok=%f;return;
  end
end
endfunction
