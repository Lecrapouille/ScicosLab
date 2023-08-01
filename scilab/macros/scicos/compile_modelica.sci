function [ok,name,nipar,nrpar,nopar,nz,nx,nx_der,nx_ns,nin,nout,nm,ng,dep_u]=compile_modelica(filemo,Mblocks)
// Copyright INRIA
  lines(0)
  if exists('%Modelica_Init','global')==0 then 
    // Modelica_Init becomes true only in "Modelicainitialize_.sci"
    %Modelica_Init=%f;
  end

  if exists('%Jacobian','global')==0 then 
    %Jacobian=%t;
  end

  if exists('%Modelica_ParEmb','global')==0 then 
    %Modelica_ParEmb=%t;
  end
    
  running="off";
  try   
    %_winId=TCL_GetVar("IHMLoc")  
  catch
    %_winId="nothing";
  end
  if (%_winId <> "nothing") then  
    running=TCL_EvalStr("winfo exists [sciGUIName "+%_winId+"]")
  end
  
  tmpdir=TMPDIR+'\'; tmpdir=pathconvert(tmpdir,%f,%t)    
  ext='\*.mo';       ext=pathconvert(ext,%f,%t)  
  [ok,modelicac,translator,xml2modelica]=Modelica_execs();
  if ~ok then,
    name='';
    dep_u=%t; nipar=0;nrpar=0;nopar=0;nz=0;nx=0;nx_der=0;nx_ns=0;nin=0;nout=0;nm=0;ng=0;
    return;
  end

  filemo=pathconvert(filemo,%f,%t)  
  name=basename(filemo)
  namef=name+'f';
  Flat=tmpdir+name+'f.mo';
  Flatxml=tmpdir+name+'f.xml';
  Flat_functions=tmpdir+name+'f_functions.mo';
  xmlfile=tmpdir+name+'f_init.xml';       
  Relfile=tmpdir+name+'f_relations.xml';
  incidence=tmpdir+name+"_incidence_matrix.xml"
  xmlfileTMP=tmpdir+name+'Sim.xml';  if MSDOS then,xmlfileTMP=strsubst(xmlfileTMP,'\','\\') ;end
  Cfile=tmpdir+name+'.c'
  
  // macros/scicos/compile_modelica.sci
  // macros/auto/scicos_simulate.sci
  // macros/scicos/clickin.sci
  // macros/scicos/do_eval.sci
  // macros/scicos/do_run.sci
  // compile_init_modelica
  // MIHM
  
  if %Jacobian then, JAC=' -jac '; else, JAC=' '; end
  
  //do not update C code if needcompile==0 this allows C code
  //modifications for debuggingS_translator.er purposes  

  updateC=needcompile<>0|fileinfo(Cfile)==[]
  updateC=updateC | %Modelica_Init 
  if updateC  then
    mlibs=pathconvert(modelica_libs,%f,%t)
    mlibsM=pathconvert(TMPDIR+'/Modelica',%f,%t)      
    mlib1=[mlibs,mlibsM];
    translator_libs=strcat(' -lib ""'+mlib1+'""');
    //---->>>>>>>>>-------------------just for OS limitation-------
    if MSDOS then, Limit=1000;else, Limit=3500;end
    if (length(translator_libs)>Limit) then 
      mprintf("\n %s",['WARNING!';..
		       'There are too many Modelica files.';..
		       'it would be better to define several ';..
		       'Modelica programs in a single file.'])
      molibs=[]
      for k=1:size(Mblocks,'r')
	funam=stripblanks(Mblocks(k))
	[dirF,nameF,extF]=fileparts(funam);
	if (extF=='.mo') then
	  molibs=[molibs;""""+funam+""""];
	else
          if MSDOS then
	    molibs=[molibs;""""+mlibsM+'\'+funam+'.mo'+""""]
          else
            molibs=[molibs;""""+mlibsM+'/'+funam+'.mo'+""""]
          end
	end
      end
      
      for k=1:size(mlibs,'*')
	modelica_file=listfiles(mlibs(k)+ext); 
	if modelica_file<> [] then 
	  molibs=[molibs;""""+modelica_file+""""];
	end
      end
      
      mymopac= pathconvert(TMPDIR+'/MYMOPACKAGE.mo',%f,%t)
      txt=[];
      for k=1:size(molibs,'*')
	[pathx,fnamex,extensionx]=fileparts(molibs(k));
	if (fnamex<>'MYMOPACKAGE') then 
	  txt=[txt;mgetl(evstr(molibs(k)))];
	end
      end
      mputl(txt,mymopac);     
      translator_libs= strcat(' -lib ""'+mymopac+'""');
    end    
    //---<<<<<<<------------------just for OS limitation-------
    //---------------------------------------------------------------------
    if %Modelica_Init then with_ixml=" -with-init ";else with_ixml=" ";end    
    
    instr='""'+translator+'"" '+translator_libs+' -lib ""'+filemo+'"" -o ""'+Flat+'""'+with_ixml+'  -command ""'+name+' '+namef+';"" > ""'+tmpdir+'S_translator.err""';
    if MSDOS then,   mputl(instr,tmpdir+'gent.bat'), instr=tmpdir+'gent.bat';end
  //  pause    
    if ( %Modelica_Init ) then 
      if (fileinfo(xmlfile)==[]) then 
	overwrite=1;//Yes
      else
	overwrite=x_message(['The initialization file already exists!';...
		    'Do you want to overwrite it?'],['Yes','No'])       
      end
    else     
      // do not generate the flat file when it is already generated by
      // the initialization GUI
      if (running =="1") then 
	overwrite=2;//no
      else
	overwrite=1;//yes
      end        
    end
    if (overwrite==2) then 
      commandresult=0;
    else
      commandresult=execstr('unix_s(instr)','errcatch');
    end
    
    if commandresult==0 then
      if (%Modelica_Init) then //---------------------------
	mprintf('%s',' Init XML file : '+xmlfile); mprintf('\n\r');
	mprintf('%s',' Init Rel file : '+Relfile); mprintf('\n\r');
	name=Flat;dep_u=%t;//<<ALERT
	// dep_u of the initialization block is obtained onley when the  C
        // code is generated.
	ok=%t,nipar=0;nrpar=0;nopar=0;nz=0;nx=0;nx_der=0;nx_ns=0;nin=0;nout=0;nm=0;ng=0;      
	return;
      else
	if ~((running=="1" )& (fileinfo(xmlfile)<>[])) then 
	 // ok=fix_parameters(Flatxml,'bottom');
ok=%t
	end  
//	instr='""'+xml2modelica+'"" ""'+Flatxml+'"" -o ""'+Flat+'""  > ""'+tmpdir+'xml2modelica.err""';
//	if MSDOS then, mputl(instr,tmpdir+'genx.bat');instr=tmpdir+'genx.bat';end	
//	if ok & execstr('unix_s(instr)','errcatch')==0 then
//	  mprintf('%s',' Flat Modelica : '+Flat); mprintf('\n\r');
//	else 
//	  MSG3= mgetl(tmpdir+'xml2modelica.err');
//	  x_message(['------- XML to Modelica error message:-------';MSG3]);
//	  ok=%f,dep_u=%t; nipar=0;nrpar=0;nopar=0;nz=0;nx=0;nx_der=0;nx_ns=0;nin=0;nout=0;nm=0;ng=0;
//	  return	         
//	end
      end
    else
      MSG2=mgetl(tmpdir+'S_translator.err');
      x_message(['-------Modelica translator error message:-----';MSG2]);
      ok=%f,
      dep_u=%t; nipar=0;nrpar=0;nopar=0;nz=0;nx=0;nx_der=0;nx_ns=0;nin=0;nout=0;nm=0;ng=0;
      return
    end
 
    //---------------------------------------------------------------------
    if fileinfo(Flat_functions)==[] then,
      Flat_functions=" "; 
    else
      Flat_functions='""'+Flat_functions+'""';
    end

    if ((running=="1" )& (fileinfo(xmlfile)<>[])) then // if GUI is running
      XMLfiles=' -with-init-in ""'+xmlfileTMP+'"" -with-init-out ""'+xmlfileTMP+'""';
    else
      XMLfiles='';
    end      
    instr='""'+modelicac+'"" ""'+Flat+'""  '+Flat_functions+' '+XMLfiles+' -o ""'+Cfile+'"" '+JAC+' 1> ""'+tmpdir+'S_modelicac.out""'+' 2> ""'+tmpdir+'S_modelicac.err""';    
    if MSDOS then,   mputl(instr,tmpdir+'genm2.bat'), instr=tmpdir+'genm2.bat';end
    if execstr('unix_s(instr)','errcatch')==0 then  
      MSG3= mgetl(tmpdir+'S_modelicac.out');
      mprintf("\n %s",MSG3)      
      MSG3= mgetl(tmpdir+'S_modelicac.err');      
      [nl,nc]=size(MSG3); Index=1;
      for i=1:nl
	if strindex(MSG3(i),"Trying to reduce state... Failed")==1 then Index=2;break;end
      end
      if Index==2 then 
	MSG3=["Warning: This model is a high index DAE          ";..
	      "The solver may be unable to simulate this system.";..
	      "Please try to reduce the system index.           "];
	mprintf("\n  ---------------------------------------------------")
	mprintf("\n ! %s !",MSG3);
	mprintf("\n  ---------------------------------------------------")
      end
    else
      MSG3= mgetl(tmpdir+'S_modelicac.err');
      x_message(['-------Modelica compiler error:-------';MSG3]);	    
      ok=%f,dep_u=%t; nipar=0;nrpar=0;nopar=0;nz=0;nx=0;nx_der=0;nx_ns=0;nin=0;nout=0;nm=0;ng=0;      
      return
    end     
    //---------------------------------------------------------------------
  end // if update
  
  [nipar,nrpar,nopar,nz,nx,nx_der,nx_ns,nin,nout,nm,ng,dep_u]=reading_incidence(incidence)
  
  mprintf('\n\r Modelica blocks are reduced to a block with:');
  mprintf('\n\r Number of differential states: %d',nx_der);
  mprintf('\n\r Number of algebraic states: %d',nx-nx_der);
  mprintf('\n\r Number of discrete time states  : %d',nz);
  mprintf('\n\r Number of zero-crossing surfaces: %d',ng);
  mprintf('\n\r Number of modes  : %d',nm);
  mprintf('\n\r Number of inputs : %d',nin);
  mprintf('\n\r Number of outputs: %d',nout);
  mprintf('\n\r Input/output dependency:[ ');
  for i=1:nin,if dep_u(i) then mprintf('T ');else,mprintf('F ');end;end; mprintf(']');
  if %Jacobian then 
    mprintf('\n\r Analytical Jacobian: enabled  (\%Jacobian=\%t)');
  else
    mprintf('\n\r Analytical Jacobian: disabled (\%Jacobian=\%f)');
  end
  
  if %Modelica_ParEmb then 
    mprintf('\n\r Parameter embedding mode: enabled  (\%Modelica_ParEmb=\%t)');
  else
    mprintf('\n\r Parameter embedding mode: disabled (\%Modelica_ParEmb=\%f)');
  end

  mprintf('\n\r ');
  
  ok=Link_modelica_C(Cfile)

endfunction


function [ok]=fix_parameters(Flatxml,flag)
  // flag='all' => set fixed of all parameters to true
  // flag='top' => set fixed of only top level parameters to true
  // flag='bottom' => set fixed of only second level parameters to true

  res=execstr('xmlformat=mgetl(Flatxml)','errcatch');
  if (res~=0) then, ok=%f; return; end
    
  typ=[];input_name=[];order=[];depend=[];
  global txtline;txtline=0;
  touch=%f
  while and(typ<>'</model') do
    [typ,val]=get_typ(xmlformat);
    if typ(1)=='<elements' then
      [typ,val]=get_typ(xmlformat);      
      while typ(1)<>'</elements' do
	if typ(1)=='<terminal' then
	  [typ,val]=get_typ(xmlformat);      
	  txtline_save=txtline;
	  while typ(1)<>'</terminal' do
	    if typ(1)=='<name' then 
	     ttyp=tokens(typ(2),'<');
	     Item_name=ttyp(1);
	    end
	    if typ(1)=='<id' then 
	     ttyp=tokens(typ(2),'<');
	     Item_id=ttyp(1);
	    end
 	    if typ(1)=='<kind' then 
	     ttyp=tokens(typ(2),'<');
	     Item_kind=ttyp(1);
	    end
 	    if typ(1)=='<fixed' then 
	     Item_fixed=val;
	    end
 	    [typ,val]=get_typ(xmlformat);
	  end
	  
	  if Item_kind=='fixed_parameter' then
	     fixit=%f
	     if flag=='all' then 
	       fixit=%t
	     else 
	       if flag=='top' & (Item_id==Item_name) then 
		    fixit=%t
	       end
	       if flag=='bottom' & (Item_id~=Item_name) then 
		    fixit=%t
	       end
	     end	    
	    //----------
	    if fixit then 
	      txtline=txtline_save;
	      [typ,val]=get_typ(xmlformat);      
	      while typ(1)<>'</terminal' do
		if typ(1)=='<fixed' then 
		  [xmlformat]=set_fix(xmlformat);
		  touch=%t
		end
		[typ,val]=get_typ(xmlformat);      
	      end
	    end
	    //-----------
	  end
	end
	[typ,val]=get_typ(xmlformat);
      end
    end
  end
  
  clearglobal txtline;
  if touch then 
    res=execstr('mputl(xmlformat,Flatxml)','errcatch');
    if (res~=0) then, ok=%f; return; end    
  end 
  ok=%t
endfunction


function t=read_new_line(txt)
  global txtline
  txtline=txtline+1;
  t=txt(txtline)
endfunction

function [typx,value]=get_typ(txt)
  t=read_new_line(txt);
  typ=tokens(t);  
  typx=tokens(typ(1),'>');
  if size(typ,'*')==2 & typ=='value' then 
    valx=tokens(typ(2),['>','/'])
    execstr(valx,'errcatch')
  else
    value=[];
  end
endfunction

function [txt]=set_fix(txt)
  t=txt(txtline)
  t=strsubst(t,'false','true')
  txt(txtline)=t;
endfunction