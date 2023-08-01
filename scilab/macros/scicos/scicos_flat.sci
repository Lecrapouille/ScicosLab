function  [cor,corinv,links_table,cur_fictitious,sco_mat,ok,scs_m]=scicos_flat(scs_m,ksup,MaxBlock)
// Copyright INRIA
//Last Upadate: Fady 15 Dec 2008
//
//This function takes a hierarchical Scicos diagram and computes the
//"flat" equivalent, removing "non computational" blocs like splits.
//S. Steer, R. Nikoukhah 2003. Copyright INRIA

//NB::--------------------------------------------------------------
// Modifying this function to take care of the GOTO FROM SampleCLK and VirtualCLK0 blocks.
// A negatif number in cor and in links_table is refer to a GOTO,FROM 
// GotoTagVisibility, SampleCLK, VirtualCLK0. in other words the blocks that are virtual.
// These blocks are removed in the compilation part. 
// Modification of shiftcors. It will not shift the negatives numbers.
// A sco_mat is a string matrix composed by the :
// For the blocks GOTO, FROM, VirtualCLK0
//	- the first column : the negatif of the number of the virtual block in the cor.
//	- the second column: 1 if it is a GOTO; -1 if it is a FROM.
//                           The VirtualCLK0 is considered as a GOTO.
//	- the third column : the tag value. 'scicostimeclk0' is used in the case of the VirtualCLK0 
//	- the forth column : the tag visibility
//                           For the GOTO: + 2: scoped
//                                         + 3: global
//                           For the FROM: + 1
//                           For the VirtualCLK0: 2
//	- the fifth column : 1=regular 2=event 3=modelica 10=VirtualCLK0
// For the SampleCLK:
//	- the first column : the negatif of the number of the virtual block in the cor.
//	- the second column: the value 1.
//	- the third column : The frequency value. 
//	- the forth column : The offset value.
//	- the fifth column : the value 4.
// Another two string matrices are used for the GOTO/FROM blocks. The loc_mat it is used when the GOTO
// block is local. The from_mat to match the local from with the local goto.
// A tag_exprs matrices is used for the GotoTagVisibility and the VirtualCLK0:
// it is composed by:
//       - the first column: The tag value. 'scicostimeclk0' in the VirtualCLK0 case.
//       - the second column: 1=regular 2=event 3=modelica 10=VirtualCLK0
// The local and scoped cases are studied in this function. 
// The global case is studied in the function global_case in c_pass1.
// A Modification of update_cor in c_pass1. For the negatives numbers 
// the cor will be set to 0. (In this case the blocks are considered as IN_f ...)
// Fady NASSIF 2007. INRIA.
//-------------------------------------------------------------------

if argn(2)<=1 then ksup=0;end //used for recursion
if ksup==0 then   // main scheme
  MaxBlock=countblocks(scs_m);
  //last created fictitious block (clock split,clock sum,super_blocks, superbloc))
  cur_fictitious=MaxBlock
  path=[];       // for delete_unconnected 
  scs_m_s=scs_m ;// for delete_unconnected 
end
//-------------- suppress blocks with an unconnected regular port -------------- 
scs_m=delete_unconnected(scs_m);

//list of blocks with are not retained in the final block list
blocks_to_remove=['CLKSPLIT_f' 'SPLIT_f' 'IMPSPLIT_f' 'CLKSOM_f' 'CLKSOMV_f' 'NRMSOM_f' 'PAL_f' 'BUSSPLIT']
port_blocks=['IN_f','INIMPL_f','OUT_f','OUTIMPL_f','CLKIN_f','CLKINV_f','CLKOUT_f','CLKOUTV_f','BUSIN_f','BUSOUT_f']
block_goto=['GOTO','CLKGOTO','GOTOMO']
block_from=['FROM','CLKFROM','FROMMO']
block_tag=['GotoTagVisibility','CLKGotoTagVisibility','GotoTagVisibilityMO']
n=lstsize(scs_m.objs) //number of "objects" in the data structure
//-------------- initialize outputs --------------
nb=0;
links_table=[]; // 
corinv=list();
cor=list();for k=1:n, cor(k)=0;end

ok=%t;
Links=[] //to memorize links position in the data structure
mod_blk_exist=%f;
//-------------- Analyse blocks --------------
loc_mat=[];from_mat=[];tag_exprs=[];sco_mat=[];
for k=1:n //loop on all objects
  o=scs_m.objs(k);
  x=getfield(1,o);
  cor(k)=0
  if x(1)=='Block' then
    if or(o.gui==block_goto) then
      cur_fictitious=cur_fictitious+1;
      cor(k)=-cur_fictitious;
      if (o.graphics.exprs(2)=='1') then
	loc_mat=[loc_mat;[string(cur_fictitious),string(1),(o.graphics.exprs(1)),string(find(block_goto(:)==o.gui))]]
	locomat=[];
	for i=1:size(loc_mat,1)
	  locomat=[locomat;strcat([loc_mat(i,3) loc_mat(i,4)])]
	end
	vec=unique(locomat)
	if size(vec,1)<>size(loc_mat,1) then
	  if flgcdgen<>-1 then path=[numk path];scs_m=all_scs_m; end
	  if (ksup==0)|flgcdgen<>-1  then
	    hilite_path([path,k],"There is another local GOTO in this diagram with the same tag ''"+loc_mat($,3)+"''",%t);
	  else
	    gh_wins = gcf();
	    mxwin=maxi(winsid());
	    scs_show(scs_m,mxwin+1);
	    hilite_obj(k);
	    message("There is another local GOTO in this diagram with the same tag ''"+loc_mat($,3)+"''");
	    gh_del = scf(mxwin+1);
	    unhilite_obj(k);
	    delete(gh_del);
	    scf(gh_wins);
	  end
	  ok=%f;return
	end
      else
	sco_mat=[sco_mat;[string(cur_fictitious),string(1),o.graphics.exprs(1),o.graphics.exprs(2),string(find(block_goto(:)==o.gui))]]
      end
    elseif or(o.gui==block_from) then
      cur_fictitious=cur_fictitious+1;
      cor(k)=-cur_fictitious
      sco_mat=[sco_mat;[string(cur_fictitious),string(-1),o.graphics.exprs(1),string(1),string(find(block_from(:)==o.gui))]]
      from_mat=[from_mat;[string(cur_fictitious),string(-1),o.graphics.exprs(1),string(find(block_from(:)==o.gui))]]
    elseif or(o.gui==block_tag) then
      tag_exprs=[tag_exprs;[o.graphics.exprs(1),string(find(block_tag(:)==o.gui))]]
      cur_fictitious=cur_fictitious+1;
      cor(k)=-cur_fictitious
    elseif o.gui=='SyncTag' then
      tag_exprs=[tag_exprs;['SyncTag','4']]
    elseif o.gui=='SampleCLK' then
      if o.graphics.peout<>0 then
      	 cur_fictitious=cur_fictitious+1;
      	 cor(k)=-cur_fictitious
	 format(15);
	 sco_mat=[sco_mat;[string(cur_fictitious),sci2exp([path k]),string(o.model.rpar(1)),string(o.model.rpar(2)),string(4)]]
       end
      //Adding the VirtualCLK0. Fady 18/11/2007
    elseif o.gui=='VirtualCLK0' then
      cur_fictitious=cur_fictitious+1;
      cor(k)=-cur_fictitious
      sco_mat=[sco_mat;[string(cur_fictitious),string(1),'scicostimeclk0',..
		  string(2),string(10)]]
      tag_exprs=[tag_exprs;['scicostimeclk0',string(10)]]
      //iterator block
    elseif or(o.gui==['ForIterator','WhileIterator']) then
      if flgcdgen==-1|ksup<>0 then
	mess='The Iterator block must be in an atomic subsystem';
	if flgcdgen<>-1 then path=[numk path];scs_m=all_scs_m; end
	if (ksup==0)|flgcdgen<>-1  then
	  hilite_path([path,k],mess,%t);
	else
	  gh_wins = gcf();
	  mxwin=maxi(winsid());
	  scs_show(scs_m,mxwin+1);
	  hilite_obj(k);
	  message(mess);
	  gh_del = scf(mxwin+1);
	  unhilite_obj(k);
	  delete(gh_del);
	  scf(gh_wins);
	end 
	ok=%f;return
      else
	nb=nb+1
	corinv(nb)=k
	//[model,ok]=build_block(o.model)
	cor(k)=nb
	if or(o.model.dep_ut($)) then
	  sco_mat=[sco_mat;[string(nb) '-1' 'scicostimeclk0' '1' '10']]
	end
      end
    elseif or(o.gui==blocks_to_remove) then
      cur_fictitious=cur_fictitious+1;
      cor(k)=cur_fictitious
    elseif o.gui=='SUM_f'|o.gui=='SOM_f' then
      nb=nb+1;
      corinv(nb)=k;
      cor(k)=nb
      //scs_m=adjust_sum(scs_m,k)
    elseif or(o.gui==port_blocks) then
      //here we suppose to be inside a superblock
      //may be we can handle this blocks just as blocks_to_remove
      if ksup==0 then 
	scs_m=scs_m_s
	hilite_path([path,k],'Port blocks must be only used in a Super Block',%f)
	ok=%f;return
      end
      connected=get_connected(scs_m,k)
      if connected==[] then
	scs_m=scs_m_s
	hilite_path([path,k],'This Super Block Input port is unconnected',%t)
	ok=%f;return
      end
      if or(o.gui==['IN_f','INIMPL_f','BUSIN_f']) then
	pind=Pind(1)
      elseif or(o.gui==['OUT_f','OUTIMPL_f','BUSOUT_f']) then
	pind=Pind(2)
      elseif or(o.gui==['CLKIN_f','CLKINV_f']) then
	pind=Pind(3)
      elseif or(o.gui==['CLKOUT_f','CLKOUTV_f']) then
	pind=Pind(4)
      end 
      //connect the link to the fictitious bloc replacing the superblock
      if scs_m.objs(connected).from(1)==k then
	scs_m.objs(connected).from(1)=-(pind+o.model.ipar)
      end
      if scs_m.objs(connected).to(1)==k then
	scs_m.objs(connected).to(1)=-(pind+o.model.ipar)
      end
    elseif o.model.sim(1)=='asuper' then  
       nb=nb+1
      corinv(nb)=k
      cor(k)=nb
      if type(o.graphics.exprs)==15 then
	if lstsize(o.graphics.exprs)>1 then
	  if o.graphics.exprs(3).dep_ut($)==%t then
	    sco_mat=[sco_mat;[string(nb) '-1' 'scicostimeclk0' '1' '10']]
	  end
	else
	  message(['The Atomic Subsystem is not compiled';'Please recreate it.'])
	  ok=%f;return;
	end
      else
	message(['The Atomic Subsystem is not compiled';'Please recreate it.'])
	ok=%f;return;
      end
    elseif o.model.sim=='super'|o.model.sim=='csuper' then
      path=[path k] //superbloc path in the hierarchy
      //replace superbloc by a set of fictitious blocks (one per port)
      //and reconnect links connected to the superblock to these
      //ficitious blocks
      Pinds=[];if exists('Pind') then Pinds=Pind,end
      Pind=[] //base of ports numbering
      //mprintf("entering superblock at level "+string(size(path,'*'))+"\r\n")
      nb_pin=size(scs_m.objs(k).graphics('pin'),1);
      nb_pein=size(scs_m.objs(k).graphics('pein'),1);
      for port_type=['pin','pout','pein','peout']
	Pind=[Pind cur_fictitious]
	ip=scs_m.objs(k).graphics(port_type);
	ki=find(ip>0)
	for kk=ki
	  kc=ip(kk)
	  //**  a link is connected to the same sblock on both ends
	  if scs_m.objs(kc).to(1)==scs_m.objs(kc).from(1) then
	    //** regular input port
	    if port_type=='pin' then
	      scs_m.objs(kc).to(1)=-(cur_fictitious+scs_m.objs(kc).to(2));
	      scs_m.objs(kc).to(2)=1
	      
	      if scs_m.objs(kc).from(3)==0 then //** in connected to out
		scs_m.objs(kc).from(1)=-(cur_fictitious+scs_m.objs(kc).from(2)+nb_pin);
		scs_m.objs(kc).from(2)=1
	      else //** in connected to in
		scs_m.objs(kc).from(1)=-(cur_fictitious+scs_m.objs(kc).from(2));
		scs_m.objs(kc).from(2)=1
	      end
	      
	      //** regular output port
	    elseif port_type=='pout' then
	      scs_m.objs(kc).from(1)=-(cur_fictitious+scs_m.objs(kc).from(2));
	      scs_m.objs(kc).from(2)=1
	      
	      if scs_m.objs(kc).to(3)==0 then //** out connected to out
		scs_m.objs(kc).to(1)=-(cur_fictitious+scs_m.objs(kc).to(2));
		scs_m.objs(kc).to(2)=1
	      end
	      
	      //** event input port
	    elseif port_type=='pein' then
	      scs_m.objs(kc).to(1)=-(cur_fictitious+scs_m.objs(kc).to(2));
	      scs_m.objs(kc).to(2)=1
	      
	      scs_m.objs(kc).from(1)=-(cur_fictitious+scs_m.objs(kc).from(2)+nb_pein);
	      scs_m.objs(kc).from(2)=1
	      
	      //** peout and pein are never connected to themselves
	    end
	    
	  elseif scs_m.objs(kc).to(1)==k then  // a link going to the superblock
	    scs_m.objs(kc).to(1)=-(cur_fictitious+scs_m.objs(kc).to(2));
	    scs_m.objs(kc).to(2)=1
	    
	  elseif scs_m.objs(kc).from(1)==k then  // a link coming from the superblock
	    scs_m.objs(kc).from(1)=-(cur_fictitious+scs_m.objs(kc).from(2));
	    scs_m.objs(kc).from(2)=1
	  end
	end
	cur_fictitious=cur_fictitious+size(ip,'*')
      end
      
      
      //Analyze the superblock contents
      [cors,corinvs,lt,cur_fictitious,scop_mat,ok,scs_m1]=scicos_flat(o.model.rpar,cur_fictitious,MaxBlock)
      if ~ok then return,end
      scs_m.objs(k).model.rpar=scs_m1;
      //shifting the scop_mat for regular blocks. Fady 08/11/2007
      if scop_mat<>[] then
	v_mat=find(eval(scop_mat(:,1))<MaxBlock)
	v_mat=v_mat(:)
	for j=v_mat
	  scop_mat(j,1)=string(eval(scop_mat(j,1))+nb)
	end
      end
     
      //Adding the scop_mat to the old sco_mat.
      sco_mat=[sco_mat;scop_mat]
      nbs=size(corinvs) 
      
      //catenate superbloc data with current data
      
      f=find(lt(:,1)>0&lt(:,1)<=nbs);if f<>[] then lt(f,1)=lt(f,1)+nb,end
      links_table=[links_table;lt]

      for kk=1:nbs
	if type(corinvs(kk))==15 then
	  ncorinvs=lstsize(corinvs(kk))
	  for jj=1:ncorinvs
	    corinvs(kk)(jj)=[k,corinvs(kk)(jj)]
	  end
	  corinv(nb+kk)=corinvs(kk);
	else
	  corinv(nb+kk)=[k,corinvs(kk)];
	end
      end
      cors=shiftcors(cors,nb)
      //	cur_fictitious=cur_fictitious+nb
      cor(k)=cors
      nb=nb+nbs
      Pind=Pinds
      path($)=[]
      
    else //standard blocks
      nb=nb+1
      corinv(nb)=k
      //[model,ok]=build_block(o.model)
      cor(k)=nb
      //Adding the always activated blocks to the sco_mat to take care of the enabling if exists.
      //Fady 18/11/2007
      if ~is_modelica_block(o) then
	if o.model.dep_ut($) then
	  sco_mat=[sco_mat;[string(nb) '-1' 'scicostimeclk0' '1' '10']]
	end
      else
	mod_blk_exist=%t // Flag for the existance of modelica's blocks
      end
    end
  elseif x(1)=='Deleted'|x(1)=='Text' then
    //this objects are ignored
  else //links
    Links=[Links k] // memorize their position for use during links analysis
  end
end //end of loop on objects

if ksup==0&nb==0 then
  message('Empty diagram')
  ok=%f
  return
end
//-------------- Analyse  links -------------- 
for k=Links
  o=scs_m.objs(k);
  f=0
  if o.from(1)<0|o.from(1)>MaxBlock then //Link coming from a superblock input port
  else
    o.from(1)=cor(o.from(1));
  end
  if o.to(1)<0 |o.to(1)>MaxBlock then //Link going to a superblock output port
  else
    o.to(1)=cor(o.to(1)),
  end
  
  if o.ct(2)==2 //implicit links
    //if abs(o.from(1))==125|abs(o.to(1))==125 then pause,end
    links_table=[links_table
	o.from(1:3)    o.ct(2) 
	o.to(1:3)      o.ct(2) ]
  else //regular or event links
    links_table=[links_table
	o.from(1:2)  -1  o.ct(2) //outputs are tagged with -1 
	o.to(1:2)    1   o.ct(2) ] //inputs are tagged with 1
  end
end
// Warning in case of modelica's blocks in an enabled diagram.
// Fady 18/11/2007
tof=find((sco_mat(:,2)=='1')& (sco_mat(:,5)=='10'))
if tof<>[] then
  if mod_blk_exist then
    message('Warning the enable does not consider the modelica blocks')
  end
end
//---------------- Treat Sample Clock equal to zero ----------------
[sco_mat,links_table]=treat_always_active(sco_mat,links_table)
//------------------------------------------------------------------
//----------------------Goto From Analyses--------------------------
// Local case
if loc_mat<>[] then
  [sco_mat,links_table]=local_case(loc_mat,from_mat,sco_mat,links_table)
end
//scoped case
if tag_exprs<>[] then
  ind=find(tag_exprs(:,2)=='4')
  synctag=tag_exprs(ind,:)
  tag_exprs(ind,:)=[];
  if tag_exprs<>[] then
    [sco_mat,links_table,scs_m,ok]=scoped_case(tag_exprs,sco_mat,links_table,scs_m,corinv)
  end
  if synctag<>[] then
    // synchronize all the sample clock that are on that level and below.
    [scs_m,corinv,cor,sco_mat,links_table,ok,flgcdgen,freof]=treat_sample_clk(scs_m,corinv,cor,sco_mat,links_table,flgcdgen,path)
  end
  if ~ok then return; end
end
//global case
// function global_case in c_pass1
//------------------------------------------------------------------------
endfunction


function [MAT,Ts]=treat_always_active(MAT,Ts)
if MAT<>[] then
  ind=vectorfind([MAT(:,3) MAT(:,5)],['0' '4'],'r')  //Sample time is equal to zero (cont)
  if ind<>[] then
    MAT1=MAT(ind,:);
    MAT(ind,:)=[];
    for i=1:size(MAT1,1)
      ii=evstr(MAT1(i,1));
      ind1=find(Ts(:,1)==-ii)
      Ts(ind1,1)=ii
      Ts($+1,:)=[0 0 -1 -1];//adding the connection to block zero when we rewrite c_pass1 it will be [0 1 -1 -1]
      Ts($+1,:)=[ii 1 1 -1]
    end
  end
end
endfunction
