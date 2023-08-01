function [model,ok]=build_modelica_block(blklstm,corinvm,cmmat,NiM,NoM,scs_m,path)
  // Serge Steer 2003, Copyright INRIA
  // given the blocks definitions in blklstm and connections in cmmat this
  // function first create  the associated modelicablock  and writes its code
  // in the file named 'imppart_'+name+'.mo' in the directory given by path
  // Then modelica compiler is called to produce the C code of scicos block
  // associated to this modelica block. filbally the C code is compiled and
  // dynamically linked with Scilab.
  // The correspondind model data structure is returned.


  //## get the name of the generated main modelica file
  name=stripblanks(scs_m.props.title(1))+'_im'; 

  if (name<> cleanID1(name) )
    x_message(' Error: '''+name+''' is not a valid name for a Modelica model.');
    ok=%f
    return
  end

  //## generation of the txt for the main modelica file
  //## plus return ipar/rpar for the model of THE modelica block
  [ok,txt,ipar, opar]=create_modelica(blklstm,corinvm,cmmat,name,scs_m);
  if ~ok then return,end

  //## write txt in the file path+name+'.mo'
  path=pathconvert(stripblanks(path),%t,%t)
  mputl(txt,path+name+'.mo');
  mprintf('--------------------------------------------\n\r');
  mprintf('%s',' Main Modelica : '+path+name+'.mo'); mprintf('\n\r');

  //## search for 

  Mblocks = [];
  for i=1:lstsize(blklstm)
    if type(blklstm(i).sim)==15 then
      if blklstm(i).sim(2)==30004 then
	o = scs_m(scs_full_path(corinvm(i)))
	Mblocks=[Mblocks;
		 o.graphics.exprs.nameF]
      end
    end
  end

  //generating XML and Flat_Model
  //## compile modelica files
  [ok,name,nipar,nrpar,nopar,nz,nx,nx_der,nx_ns,nin,nout,nm,ng,dep_u]=compile_modelica(path+name+'.mo',Mblocks);


  if ~ok then return,end

  //nx is the state dimension
  //ng is the number of surfaces
  //name1 of the model+flat

  //build model data structure of the block equivalent to the implicit part
  model=scicos_model(sim=list(name,10004),... 
		     in=ones(nin,1),out=ones(nout,1),...
                     state=zeros(nx*2,1),...
                     dstate=zeros(nz,1),...
                     ipar=ipar,...
                     opar=opar,...
		     dep_ut=[dep_u %t],nzcross=ng,nmode=nm);
endfunction

function id_out=cleanID1(id)
  if id=='' then
    id_out='';
    return;
  end
  lid=length(id)
  ida=ascii(id);
  ido=ida;
  for i=1:length(id)
    C1= ascii('0')<=ida(i) & ida(i)<=ascii('9');
    C2= ascii('a')<=ida(i) & ida(i)<=ascii('z');
    C3= ascii('A')<=ida(i) & ida(i)<=ascii('Z');    
    if C1 | C2 | C3 then 
      ido(i)=ida(i)
    else
      ido(i)=ascii('_')
    end    
  end  
  
  if ( ascii('0')<=ida(1) & ida(1)<=ascii('9')) then 
    ido(1)=ascii('_')
  end

  id_out=ascii(ido);
endfunction

