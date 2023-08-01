// To run examples: 
//  1- exec this file: exec('sciparse.sce',-1)   
//  2- run by giving mdl file(s) as follows: testing("..\test_data\explicit\*.mdl")
 

// set the path to SVN location of MDL
if MSDOS then
  MDL = get_absolute_file_path("sciparse.sce")+'..\'
else
  MDL = get_absolute_file_path("sciparse.sce")+'../'
end
//

// Not necessary every time unless edited
cwd=pwd();
cd(MDL+"scilab")
genlib("trancos",MDL+"scilab",%t)
cd(MDL+"scilab/BlockLibs")
mdelete("*~")
mdelete("*.bin")
mdelete("names")
mdelete("lib")
genlib("blklbs",MDL+"scilab/BlockLibs",%t)
cd(cwd);
//

lines(0)
stacksize(120000000)

load(MDL+"scilab/BlockLibs/lib")

fls=read(MDL+"scilab/BlockLibs/names",-1,1,'(a)') 
_LibBlocks=[];
for fl=fls'
  _LibBlocks=[_LibBlocks,part(fl,4:length(fl))];
end

if ~exists("%scicos_context") then
   %scicos_context=struct();
end
%scicos_context.on=1;
%scicos_context.off=0;
%scicos_context.inf=%inf;
%scicos_context.pi=%pi;

on=1;off=0;conv=convol;


function scs_m=sim2cos(mdl,mfile)
   _bl=loadpervasive()
   txt=read(mdl,-1,1,'(a)') 
   [ll,i] = getmodel(txt)
   blkdeflist=getblkparamdefs(ll)
   linkdef=list2struct(finddefaults(ll,"LineDefaults"))
   annotdef=list2struct(finddefaults(ll,"AnnotationDefaults"))
   ll=inherit(ll,blkdeflist,linkdef,annotdef,_bl)
   model=list2struct(ll)
   if argn(2)>1 then
      script=read(mfile,-1,1,'(a)')       
      txt=generator(model,mat2sci(script))
   else
      txt=generator(model,[])
   end

  fname=TMPDIR+"/"+model.Name
  if MSDOS then
     fname=strsubst(fname,'/','\')
  else
     fname=strsubst(fname,'\','/')
  end

  disp(fname+".sci")
  mdelete(fname+".sci")
  //write(fname+".sci",txt,'(a)')
  fd=mopen(fname+".sci","w")
  mfprintf(fd,"%s\n",txt)
  mclose(fd) 

  %mprt=funcprot()
  funcprot(0)
  x_message=warning
 
  scs_m=test(fname+".sci")

 funcprot(%mprt)

endfunction

function testing(files)
   _bl=loadpervasive()
   lfs=ls(files)
   for f=lfs'
      disp(f)
      txt=read(f,-1,1,'(a)') 
      [ll,i] = getmodel(txt)
      disp(f+": "+string(i)+" lines")
      blkdeflist=getblkparamdefs(ll)
      linkdef=list2struct(finddefaults(ll,"LineDefaults"))
      annotdef=list2struct(finddefaults(ll,"AnnotationDefaults"))
      ll=inherit(ll,blkdeflist,linkdef,annotdef,_bl)
      model=list2struct(ll)

      txt=generator(model,[])
      fname=TMPDIR+"/"+model.Name
      if MSDOS then
         fname=strsubst(fname,'/','\')
      else
         fname=strsubst(fname,'\','/')
      end

      disp(fname+".sci")
      mdelete(fname+".sci")
      //write(fname+".sci",txt,'(a)')
      fd=mopen(fname+".sci","w")
      mfprintf(fd,"%s\n",txt)
      mclose(fd) 
 
      %mprt=funcprot()
      funcprot(0)
      x_message=warning
     
     scs_m=test(fname+".sci")

     funcprot(%mprt)

    //  scicos(scs_m)
    [pat,nom,jj]=fileparts(f) 
    fcos=pat+nom+".cos"
    mdelete(fcos)
    [u,err]=mopen(fcos,'wb')
    if err<>0 then
       warning('Directory write access denied')
    else   
      if execstr('save(u,scs_m,list())','errcatch')<>0 then
        warning(['Save error:';lasterror()])
        mclose(u)
      else
        disp("succesfuly saved '+fcos)
      end
      mclose(u)
    end
  end
endfunction

function ll=inherit(ll,blkdeflist,linkdef,annotdef,_bl)
  i=0
  while i<length(ll)
    i=i+1
    if or(ll(i)(1)==["BlockDefaults" , "BlockParameterDefaults" ,..
                     "AnnotationDefaults" , "LineDefaults"]) then
       ll(i)=null()
       i=i-1
    elseif ll(i)(1)=="System" then
       lli2=ll(i)(2)  
       st=struct()
       st._Blocks=struct();st._Lines=list();st._Annotations=list();

       for k=1:length(lli2)
          if lli2(k)(1)=="Block" then
             stx= list2struct(inherit(lli2(k)(2),blkdeflist,linkdef,annotdef,_bl));
             stx=merge_st(blkdeflist(stx.BlockType),stx)
             if stx.BlockType=="Reference" then stx.BlockType=stx.SourceType,end
             if isfield(_bl,stx.BlockType) then
               st._Blocks(stx.Name)=blk_format(_bl(stx.BlockType),stx)
             else
               if ~(stx.BlockType=="SubSystem") then
                 warning('unknown blocktype '+stx.BlockType)
               end
               if isfield(stx,"SourceBlock") then disp('in '+stx.SourceBlock),end
               st._Blocks(stx.Name)=blk_format(_bl._Unknown,stx)
             end
          elseif lli2(k)(1)=="Line" then 
             st._Lines($+1)=merge_st(linkdef,list2struct(inheritline(lli2(k)(2))))
         elseif lli2(k)(1)=="Annotation" then 
             st._Annotations($+1)=merge_st(annotdef,list2struct(inherit(lli2(k)(2),blkdeflist,linkdef,annotdef,_bl)))
         elseif type(lli2(k)(2))==15 then
             st(lli2(k)(1))=list2struct(lli2(k)(2))
         else
             st(lli2(k)(1))=lli2(k)(2)
         end
       end
       ll(i)(2)=st
    end
  end
endfunction

function ll=inheritline(ll)
  st=struct();
  _Branches=list()
  i=0
  while i<length(ll)
    i=i+1
    l=ll(i)  
    if l(1)=="Branch" then
      _Branches($+1)=list2struct(inheritline(l(2)))
      ll(i)=null();i=i-1
    end
  end
  ll($+1)=list("_Branches",_Branches)
endfunction

function stf=blk_format(stf,stx)
  nm=getfield(1,stx)
  for f=nm(3:$)
    if isfield(stf("BlockInterfaceParameters"),f)|(f=="Port"&type(stx.Port)>1) then
        stf("BlockInterfaceParameters")(f)=mexptosci(stx(f))
    else
        stf(f)=stx(f)
    end
  end
endfunction
  
function str=tclean(str)
  ii=ascii(str)
  k=find(ii==32|ii==9)
  ii(k)=[]
  str=ascii(ii)
endfunction

function vali=tostrifcan(vali)
  val1=vali
  [vali,ierr]=evstr(vali)
  if vali==[]&val1~="[]"  then vali=val1,end
endfunction

function [ll,i] = gettree(txt,i)
  ll=list();
  while i<size(txt,1)  
    i=i+1
    ti=stripblanks(txt(i),%t);
    if part(ti,1)=="'""  then
       ti=dblqt(ti)
       ll($)(2)=ll($)(2)+tostrifcan(ti)
    elseif part(ti,1:2)=="\n" then
       ll($)(2)=tostrifcan(ll($)(2)+ti)
    else
      k=strindex(ti,[' ',ascii(9)]);
      para=tclean(part(ti,1:k(1)-1))
      n=length(ti);

      if part(ti,n)=='{' then 
         [li,i]=gettree(txt,i)
         vali=li;
      elseif tclean(part(ti,1))=='}' then
         return
      else
        vali=stripblanks(part(ti,k(1)+1:n),%t);
      end
      if para=='' then disp('vide'),pause,end

      if type(vali)<>15 then 
         if part(vali,1)=="'"" then
           vali=dblqt(vali)
         end
         vali=tostrifcan(vali)
      end
      
      ll($+1)=list(para,vali)
    end
  end
endfunction
  
function vali=dblqt(vali)
  na=ascii(vali)
  K=find(na==39)
  if ~isempty(K) then 
    idx=ones(na)
    idx(K)=2
    na=duplicate(na,idx)
  end
  idq=find(na(1:$-1)==34)
  idbs=find((na(1:$-1)==92)|(na(1:$-1)==39))
  na(intersect(idq-1,idbs))=39
  vali=ascii(na)
endfunction

function l=finddefaults(ll,obj)
//obj= "BlockDefaults" , "BlockParameterDefaults" , "AnnotationDefaults" , "LineDefaults"
l=[]
for li=ll
  if li(1)==obj then
     l=li(2)
     return
  elseif type(li(2))==15 then
     l=finddefaults(li(2),obj)
     if ~isempty(l) then return,end
  end
end
endfunction

function blkdeflist=getblkparamdefs(ll)
  blkdeflist=struct()
  l=finddefaults(ll,"BlockDefaults")
  bd=list2struct(l)
  l=finddefaults(ll,"BlockParameterDefaults")
  for li=l
    if li(1)~="Block" then 
      disp('x1'), pause,
    else
      li2=li(2)
      if li2(1)(1)~="BlockType" then
         disp('x2'), pause,
      else
         blktype=li2(1)(2)
         lse=li2;lse(1)=null()
         bdi=list2struct(lse)
         bdi=merge_st(bd,bdi)
         blkdeflist(blktype)=bdi
     end
   end
  end
   blkdeflist.Reference=bd
endfunction

function bd=merge_st(bd,bdi)
   fis=getfield(1,bdi)
   for i=3:size(fis,2)
     bd(fis(i))=bdi(fis(i))
   end
endfunction

function st=list2struct(ll)
  st=struct()
  _Port=list()
  for l=ll
// THIS MUST BE FIXED; SCILAB BUG!!!!
    if l(1)=='dims' then l(1)='_dims',end
//
    if l(1)~= "_Branches" then
      if type(l(2))==15 then
        if or(l(1)== ["List","Array"]) then
          st(l(2)(1)(2))=list2struct(l(2))
        elseif l(1)== "Port" then
          _Port($+1)=list2struct(l(2))
        else
          st(l(1))=list2struct(l(2))
        end
      elseif l(1)=="Orientation" then
        if l(2)=="right" then 
           st.BlockRotation=0
           st.BlockMirror=0
        elseif l(2)=="left" then 
           st.BlockRotation=0
           st.BlockMirror=1
        elseif l(2)=="up" then 
           st.BlockRotation=-90
           st.BlockMirror=0
        elseif l(2)=="down" then 
           st.BlockRotation=90
           st.BlockMirror=0
        else
           disp('unknown Orientation "+l(1)),pause
        end
      else
        st(l(1))=l(2)
      end
   else
      st(l(1))=l(2)
   end
  end
  if length(_Port)>0 then st._Port=_Port,end
endfunction  

function [ll,i]=getmodel(txt)
  i=0
  while i<size(txt,1)
    i=i+1
    ti=stripblanks(txt(i),%t);
    n=length(ti);
    if n>0 & part(ti,1)~="#" then
      if part(ti,n)=='{' then 
       k=strindex(ti,[' ',ascii(9)]);
       para=tclean(part(ti,1:k(1)-1))
       if or(para==["Model","Library"]) then
         [ll,i] = gettree(txt,i)
       end
     end
   end
 end
endfunction

function _bl=loadpervasive()
  f=MDL+"simulinklibs\mdl_pervasives.mdli"   
  txt=read(f,-1,1,'(a)') ;
  _bl=struct();
  [ll,i] = gettree(txt,0);  
  if ll(1)(1)~= "BlockInterfaces" then
    disp('not a pervasive.'),pause
  else
    for l=ll(1)(2)
      if l(1)=="Block" then
        if l(2)(2)(2)=="Simulink" then
          _bl(l(2)(1)(2))=list2struct(l(2));
        else
          _bl(l(2)(2)(2))=list2struct(l(2));
        end
      else
        disp('not a block'),pause
      end
    end
  end
  _bl._Unknown("BlockInterfaceParameters")=struct()
endfunction

function txt=generator(model,Mworkspace)
  global %ind
  %ind=-1
  [txt,inde]=create_sub(model.System)
  txt($+1)="scsm1=%subsystem_0();"

  simpar=model.Handle("Simulink.ConfigSet").Handle("Simulink.SolverCC") 
  [final_simulation_time,ierr]=evalincontext(mexptosci(simpar.StopTime),Mworkspace)
  if ierr>0 then
    warning('Unknown final simulation time: '+simpar.StopTime+'. Using 30.')
    final_simulation_time=30
  elseif isempty(final_simulation_time) then
    warning('Undefined final simulation time: use 30.')  
    txt($+1)="scsm1 = set_final_time(scsm1,30);"
    final_simulation_time=30
  elseif final_simulation_time>100000 then
    txt($+1)="scsm1 = set_final_time(scsm1,100000);"
  else
    txt($+1)="scsm1 = set_final_time(scsm1,"+string(final_simulation_time)+");"
  end

  tol=[simpar.AbsTol;simpar.RelTol;"auto";
       string(final_simulation_time);"0";"1";simpar.MaxStep];
  //atol=tolerances(1);rtol=tolerances(2);ttol=tolerances(3);
  //deltat=tolerances(4);scale=tolerances(5);solver=tolerances(6);tolerances(7)

  txt($+1)="scsm1 = set_solver_parameters(scsm1,"+sci2exp(tol,0)+");"

  workSpace=[Mworkspace;'_final_simulation_time='+string(final_simulation_time)+";"]

  if isfield(model,"InitFcn") then 
    workSpace=[workSpace;mat2sci(m2s_str(model.InitFcn))]
  end
  if isfield(model,"PreLoadFcn") then 
    workSpace=[workSpace;mat2sci(m2s_str(model.PreLoadFcn))]
  end

  txt($+1)="%workSpace=.."
  txt=[txt;sci2exp(workSpace)]
  txt($+1)="scsm1=set_model_workspace(scsm1,%workSpace);"

  txt($+1)="scs_m=evaluate_model(scsm1,%scicos_context);"
endfunction

function [txt,inde]=create_sub(System)
global %ind
  %ind=%ind+1
  inde=%ind
  ID="    "  // Indentation
  txt="function scs_m=%subsystem_"+string(%ind)+"()"
  txt($+1)=ID+"scs_m=instantiate_diagram()"

  clr=get_coscolor(System.ScreenColor)

  txt($+1)=ID+"scs_m=set_diag_bkgcolor(scs_m,"+string(clr)+")"
  txt($+1)=ID+"scs_m = set_diag_3D(scs_m,1)"
  %zoom=evstr(System.ZoomFactor)/100
  loc = System.Location
  %hight=(loc(4)-loc(2))
  txt($+1)=ID+"scs_m = set_diagram_location(scs_m,"+sci2exp(loc)+","+string(%zoom)+")"
  txt($+1)=ID+"scs_m = set_diagram_name(scs_m,"+sci2exp(System.Name)+")"

  blks=System._Blocks
  lnks=System._Lines
  annots=System._Annotations

  [lnks,blks]=rm_branches(lnks,blks)

  bl_names=getfield(1,blks)
  for k=1:size(bl_names,'*')-2
     bl_name=bl_names(k+2)
     o=blks(bl_name)
     if ~isfield(o,"Ports") then 
       warning('block '+o.Name+' has no ports; setting arbitrarely to 3,3.')
       nin=3,nout=3  // FIX ME !!!!
     else
       select size(o.Ports,"*")
       case 0
         nin=0,nout=0
       case 1
         nin=o.Ports(1),nout=0
       else
         nin=o.Ports(1),nout=o.Ports(2)
       end
    end
    if bl_name~=o.Name then disp('problem with block name '+bl_name),pause,end
    btype=strsubst(o.BlockType,' ','_')  //replace space with _ in name
    btype=strsubst(btype,'-','_')  //replace - with _ in name
    btype=strsubst(btype,'.','')  //replace . with nothing in name
    //scilab limit length of function name to 24: -3 for add
    if length(btype)>24-3 then btype=part(btype,1:24-3),end

    if or(_LibBlocks==btype) then
      execstr("txt=add"+btype+"(txt,o.BlockInterfaceParameters,nin,nout)")
      if isfield(o,"MaskValueString") then
           txt=create_empty_scsm1(txt,nin,nout,[],o.Name);
           txt($+1)=ID+"%blk.graphics.gr_i(1)='" '""
           txt($+1)=ID+"%blk=set_block_orig(%blk,[200,200])"
           orig=o.Position([1,2]);sz=o.Position([3,4])-orig;
           txt($+1)=ID+"%blk=set_block_sz(%blk,"+sci2exp(sz)+")"
           txt($+1)=ID+"[scsm1,%l] = add_block(scsm1,%blk)"
           blknum=0;
           
           for ij=1:nin
              blknum=blknum+1;
              txt($+1)=ID+"scsm1 = add_explicit_link(scsm1,"+..
                 sci2exp([blknum,1])+","+sci2exp([nin+nout+1,ij])+")"
           end
           for ij=1:nout
              blknum=blknum+1;
              txt($+1)=ID+"scsm1 = add_explicit_link(scsm1,"+..
                 sci2exp([nin+nout+1,ij])+","+sci2exp([blknum,1])+")"
           end

           txt($+1)=ID+"%blk=instantiate_block('"SUPER_f'")"
           txt($+1)=ID+"%blk=fill_superblock(%blk,scsm1)"           
           txt=mask_superblock_blk(txt,o)
           txt($+1)=ID+"%blk.graphics.gr_i(1)='" '""
       end

       txt=set_block_graphics(txt,o,nin,nout,0,0,%hight)

    elseif btype=='SubSystem' then
       txt($+1)=ID+"%blk=instantiate_block('"SUPER_f'")"
       txt($+1)=ID+"%blk.graphics.gr_i(1)='" '""
       txt=set_block_graphics(txt,o,nin,nout,0,0,%hight)

       if isfield(o,"System") then  // because of Reference block Master 
                                    // Controller in teleoperator_exp.mdl 
                                    // which has SourceType: "SubSystem"
         [txt1,inde1]=create_sub(o.System)
         txt=[txt1;txt]
         txt($+1)=ID+"%blk=fill_superblock(%blk,%subsystem_"+string(inde1)+"())"
       else
         txt=create_empty_SB(o,txt,nin,nout)
       end

       if isfield(o,"MaskValueString") then
           txt=mask_superblock_blk(txt,o)
       end
    else
// TO REMOVE
 //     global Unknown
 //     Unknown=[Unknown,btype]
//
      txt=create_empty_SB(o,txt,nin,nout)
    end
    txt($+1)=ID+"[scs_m,%l] = add_block(scs_m,%blk)"
  end

//errcatch(-1,'pause')

  for o=lnks
    if isfield(o,"SrcBlock") then
     if or(o.DstPort==["enable","trigger","ifaction"]) then 
        warning("Use of "+o.DstPort+" port.")
     elseif o.SrcPort=="state" then
        warning("Use of "+o.SrcPort+" port.")
     else
       from=[getblknum(o.SrcBlock),o.SrcPort]
       to=[getblknum(o.DstBlock),o.DstPort]
       if isfield(o,"Points") then
         points=o.Points
         if type(points)==10 then points=evstr(points),end // oddity in Trading.mdl
         points(:,2)=-points(:,2)
       else
         points=[]
       end
       txt($+1)=ID+"scs_m = add_explicit_link(scs_m,"+..
             sci2exp(from)+","+sci2exp(to)+","+sci2exp(points,0)+")"
    end
   else
     warning("A link without a source removed.")
   end
  end

  for o=annots
      if isfield(o,"Name") then 
         txt($+1)=ID+"%blk=instantiate_block('"TEXT_f'")"

         lls=length(m2s_str(o.Name))
         wh=[max(lls)/2,size(lls,1)]*o.FontSize*%zoom  // poor estimation

         orig=o.Position([1,2])
         orig(2)=%hight-orig(2)

         orig=orig - wh  // dirty trick

         txt($+1)=ID+"%exprs=.."
         txt=[txt;ID+sci2exp([o.Name;'2';string((o.FontSize-4)/2)])]
         txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
         txt($+1)=ID+"%blk=set_block_orig(%blk,"+sci2exp(orig)+")"
         txt($+1)=ID+"[scs_m,%l] = add_block(scs_m,%blk)"
       end
  end
  txt($+1)="endfunction"
  txt($+1)="   "
endfunction

function [lnks_out,blks]=rm_branches(lnks,blks)
  global li;
  li=0;
  lnks_out=list()
  for line=lnks
    [llines,blks] = line_flatten(line,list(),blks)
    lnks_out=lstcat(lnks_out,llines)
  end
endfunction

function  txt=create_empty_SB(o,txt,nin,nout)
      txt($+1)=ID+"%blk=instantiate_block('"SUPER_f'")"
      txt($+1)=ID+"%blk.graphics.gr_i(1)='" '""
      txt=set_block_graphics(txt,o,nin,nout,0,0,%hight)
      para=o.BlockInterfaceParameters
      context='//   '+o.BlockType
      paras=getfield(1,para)
      np=size(paras,"*")-2
      for ii=1:np
       context(ii+1)=paras(2+ii)+"="+sci2exp(para(paras(2+ii)),0)
      end

      txt=create_empty_scsm1(txt,nin,nout,context,o.Name)

      txt($+1)=ID+"%blk=fill_superblock(%blk,scsm1)"
endfunction


function [llines,lblks] = line_flatten(line,llines,lblks)
//   src=line.SrcBlock  // what for?
//  points=line.Points
  if length(line._Branches)>0 then
    branches=line._Branches
    num_branches = size(branches)  // there are surely branches here
    split=get_new_split(num_branches)
    line.DstBlock=split.Name
    line.DstPort=1  // create a simple line
    llines($+1)=line;
    lblks(split.Name)=split   // add the new split to the result
    for i=1:num_branches 
       branch = branches(i)  // see branch as a line
       branch.SrcBlock = split.Name
       branch.SrcPort=i  // add the missing source to branch
       [llines,lblks]=line_flatten(branch,llines,lblks)
    end
  elseif isfield(line,"DstBlock") then
     llines($+1)=line;
     return
  else
     disp("A source has no corresponding branch or destination."),
  end
endfunction

function sp=get_new_split(n)
  global li
  sp=struct()
  sp.BackgroundColor="white"
  sp.BlockType="_Split"
  sp.Ports=[1,n]
  sp.BlockMirror=0
  sp.Position=[-1,-1,-1,-1]   // pas terrible mais dans simulink <0 pas possible
  sp.BlockRotation=0
  sp.Name="_split"+string(li)
  sp.ShowName=off
  sp.BlockInterfaceParameters=struct()
  li=li+1
endfunction

function n=getblknum(name,blks)
  names=getfield(1,blks)
  n=find(names==name)
  if size(n,'*')~=1 then disp('problem with block name '+name),pause,end
  n=n-2
endfunction
  
function scs_m=test(f)
  load("SCI/macros/scicos/lib")
  exec(loadpallibs, 1)
  options=default_options()
  load(MDL+"scilab/lib")
  exec(f,-1)
endfunction

function clr=get_coscolor(str)
  %mprt=funcprot()
  funcprot(0) 
  black=1
  white=8
  blue=2
  green=3
  red=5
  yellow=7
  lightBlue=12
  darkGreen=14
  cyan=4
  magenta=19
  orange=27
  gray=33
  funcprot(%mprt)
  clr=evstr(str)
  
  if size(clr,'*')>1 then
    cmap=get(sdf(),"color_map")
    dif=abs(cmap-ones(size(cmap,1),1)*clr)*[1;1;1]
    [ju,clr]=min(dif)
  end
endfunction

function txt=mask_superblock_blk(txt,o)
   if isfield(o,"MaskVariables") then
     vartxt=o.MaskVariables
     asc=ascii(vartxt);asc(find(asc==64|asc==38))=[]
     vartxt=ascii(asc)
     [ll,ierr]=getvardef(vartxt,struct())
     if ierr>0 then disp('problem with masked variables'),pause,end
     //for reordering if needed
     ln=length(ll);
     idx=[];for ik=3:ln,idx=[idx,getfield(ik,ll)];end
     [junk,ind]=gsort(-idx)
     //
     parnms=getfield(1,ll)
     param_names=parnms(3:$)'  // it is not assumed they are in order if not look inside ll
     param_names=param_names(ind)
   else
     param_names=[]
   end
   if ~isfield(o,"MaskPromptString") then disp('no prompt in mask'),pause,end
   pro=o.MaskPromptString
   idx=find(ascii(pro)==124)
   param_prompts=[];
   j=1
   for k=idx
     param_prompts($+1)=part(pro,j:k-1)
     j=k+1
   end
   param_prompts($+1)=part(pro,j:length(pro))
   if ~isfield(o,"MaskValueString") then disp('no value in mask'),pause,end
   pro=o.MaskValueString
   idx=find(ascii(pro)==124)
   params_values=[];
   j=1
   for k=idx
     params_values($+1)=part(pro,j:k-1)
     j=k+1
   end
   params_values($+1)=part(pro,j:length(pro))
   if ~isfield(o,"MaskDescription") then 
     warning('No description in mask')
     ptitle="?"
   else
     ptitle=o.MaskDescription
   end

   nbpara=size(params_values,"*")

   if ~isempty(param_names) then
      param_num=param_names
   else
      param_num="Mask_"+string([1:nbpara]')
   end
   if isfield(o,"MaskInitialization") then
      maskinit=strsubst(o.MaskInitialization,"@","Mask_")
      maskinit=strsubst(maskinit,"&","Mask_")
      context=mat2sci(m2s_str(maskinit))
   else
      context=[]
   end

   if ~isempty(context) then
      txt($+1)=ID+"%context=.."
      txt=[txt;ID+sci2exp(context)]
      txt($+1)=ID+"%blk = set_superblock_context(%blk,%context)"
   end
   txt($+1)=ID+"%params_values="+sci2exp(params_values,0)
   txt($+1)=ID+"%param_num="+sci2exp(param_num,0)
   txt($+1)=ID+"%param_prompts="+sci2exp(param_prompts,0)
   txt($+1)=ID+"%ptitle="+sci2exp(ptitle,0)

   txt($+1)=ID+"%blk=create_mask(%blk,%params_values,%param_num,%param_prompts,%ptitle)"
endfunction

function txt=m2s_str(txt)
  u=ascii(txt)
  k=find(u(1:$-1)==92 & u(2:$)==110)
  if isempty(k) then
     return
  end
  j=k(1)
  txt=ascii(u(1:j-1))
  for i=k(2:$)
    txt($+1)=ascii(u(j+2:i-1))
    j=i
  end
  txt($+1)=ascii(u(j+2:$))
endfunction

function [%ll,%ierr]=getvardef(%txt,%ll)
  %nww='';%ierr=0;  // to make sure %ww does not enter the difference
  %nww=size(who('get'),'*')
  execstr(%txt)
  %mm=who('get')
  %nww2=size(%mm,'*')
  %mm=%mm(1:%nww2-%nww)
  for %mi=%mm(:)'
    if type(evstr(%mi)) <> 13 then
      if %mi=="scs_m" then
	disp('the name scs_m is reseved; it cannot be used as block"+...
	     " parameter')
      else
	%ll(%mi)=evstr(%mi)
      end
    end
  end
endfunction

function txt=create_empty_scsm1(txt,nin,nout,context,diagName)
  txt($+1)=ID+'%context=...'
  txt=[txt;ID+ID+sci2exp(context)]
  txt($+1)=ID+'scsm1=instantiate_diagram()'
  txt($+1)=ID+"scsm1 = set_diagram_name(scsm1,"+sci2exp(diagName)+")" 
  txt($+1)=ID+'scsm1=set_diagram_context(scsm1,%context)' 
  for ij=1:nin
    txt($+1)=ID+'%blk1=instantiate_block('"IN_f'")'
    txt($+1)=ID+'%exprs='+sci2exp([string(ij),'-1','-1'])
    txt($+1)=ID+"%blk1=set_block_parameters(%blk1,%exprs)"
    txt($+1)=ID+"%blk1=set_block_orig(%blk1,"+sci2exp([10,ij*30])+")"
    txt($+1)=ID+"%blk1=set_block_sz(%blk1,[15,10])"
    txt($+1)=ID+"[scsm1,%l] = add_block(scsm1,%blk1)"
  end
  for ij=1:nout
    txt($+1)=ID+'%blk1=instantiate_block('"OUT_f'")'
    txt($+1)=ID+'%exprs='+sci2exp([string(ij)])
    txt($+1)=ID+"%blk1=set_block_parameters(%blk1,%exprs)"
    txt($+1)=ID+"%blk1=set_block_orig(%blk1,"+sci2exp([350,ij*30])+")"
    txt($+1)=ID+"%blk1=set_block_sz(%blk1,[15,10])"
    txt($+1)=ID+"[scsm1,%l] = add_block(scsm1,%blk1)"
  end
endfunction


function  txt=set_block_graphics(txt,o,nin,nout,enin,enout,%hight)
  clr=get_coscolor(o.BackgroundColor)

  txt($+1)=ID+"%blk=set_block_bkgcolor(%blk,"+sci2exp(clr)+")"

  txt($+1)=ID+"%blk=set_block_nin(%blk,"+string(nin)+")"
  txt($+1)=ID+"%blk=set_block_nout(%blk,"+string(nout)+")"
  txt($+1)=ID+"%blk=set_block_evtnin(%blk,"+string(enin)+")"
  txt($+1)=ID+"%blk=set_block_evtnout(%blk,"+string(enout)+")"
  txt($+1)=ID+"%blk=set_block_flip(%blk,"+sci2exp(~o.BlockMirror)+")"
  if o.ShowName then
    txt($+1)=ID+"%blk=set_block_ident(%blk,"+sci2exp(o.Name)+")"
  end
  if o.BlockType=="_Split" then
    orig=[%nan,%nan],sz=[0,0]
  else
    orig=o.Position([1,2]);sz=o.Position([3,4])-orig;
    if abs(o.BlockRotation)==90 | abs(o.BlockRotation)==270 then
       sz([1,2])=sz([2,1])
       orig(1)=orig(1)+sz(2)/2-sz(1)/2
       orig(2)=%hight-orig(2)-sz(2)/2-sz(1)/2  // simulink is upside down with top left corner
    else
       orig(2)=%hight-orig(2)-sz(2)  // simulink is upside down with top left corner
    end
  end
  txt($+1)=ID+"%blk=set_block_orig(%blk,"+sci2exp(orig)+")"
  txt($+1)=ID+"%blk=set_block_sz(%blk,"+sci2exp(sz)+")"
  txt($+1)=ID+"%blk=set_block_theta(%blk,"+sci2exp(o.BlockRotation)+")"   
endfunction

function txt=mat2sci(txt)
  if isempty(stripblanks(txt)) then return,end
  mdelete(TMPDIR+'\ff.m')
  //  write(TMPDIR+'\ff.m',txt,'(a)')  
  // solution proposed by F. Vogel
  fd=mopen(TMPDIR+'\ff.m',"w")
  mfprintf(fd,"%s\n",txt)
  mclose(fd) 
  //

if MSDOS then
  if execstr('mfile2sci(TMPDIR+''\ff.m'',TMPDIR,%f,%t,1,%f)','errcatch')==0 then
     txt=read(TMPDIR+'\ff.sci',-1,1,'(a)')  
  end
else
  if execstr('mfile2sci(TMPDIR+''/ff.m'',TMPDIR,%f,%t,1,%f)','errcatch')==0 then
     txt=read(TMPDIR+'/ff.sci',-1,1,'(a)')  
  end
end 
endfunction

function txt=mexptosci(txt)
 if type(txt)==10 then
   txt=repl_(txt,"inf","%inf")
   txt=repl_(txt,"pi","%pi")
   txt=repl_(txt,"%pi()","%pi")
 end
endfunction

function txt=repl_(txt,st1,st2)
   chanum=[48:57,65:90,97:122,95];
   vv=ascii(txt)
   u=ascii(st1)
   v=ascii(st2)
   l1=size(u,'*')
   i=0
   while i<=size(vv,'*')-l1
     i=i+1
     if isequal(vv(i:i+l1-1),u) then
       if (i==1|and(vv(i-1)~=chanum))&(i+l1>size(vv,'*')|and(vv(i+l1)~=chanum)) then
         vv=[vv(1:i-1),v,vv(i+l1:$)]
         i=i+l1-1
       end
     end
   end
   txt=ascii(vv)
endfunction


function   [val,ierr]=evalincontext(expr,Mworkspace)
  ierr=execstr(Mworkspace,"errcatch")
  if ierr==0 then
     [val,ierr]=evstr(expr)
  else
     val=[]
  end
endfunction
