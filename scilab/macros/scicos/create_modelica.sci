function [ok,txt,ipar, opar]=create_modelica(blklst,corinvm,cmat,name,scs_m)
// Copyright INRIA
  if exists('%Modelica_Init','global')==0 then 
    // Modelica_Init becomes true only in "Modelicainitialize_.sci"
    %Modelica_Init=%f;
  end
  if exists('%Modelica_ParEmb','global')==0 then 
    %Modelica_ParEmb=%t;
  end  
  
  Parembed=%Modelica_ParEmb & ~%Modelica_Init;

  txt=[];tab=ascii(9)
//  rpar=[];//will contain all parameters associated with the all modelica blocs
  opar=list();
  ipar=[];//will contain the "adress" of each block in rpar
  models=[]//will contain the model declaration part
  eqns=[]//will contain the modelica equations part
  Pin=[]
  Bnumbers=[]
  Bnam=[]
  Bnames=[]
  nb=size(blklst)
  Params=[];
  for k=1:nb
    ipar(k)=0
    o=blklst(k)

    //#########
    //## Params
    //#########

    if o.equations.model<>'OutPutPort' & o.equations.model<>'InPutPort' then
      //## retrieve the object in the scs_m structure
      o_scsm = scs_m(scs_full_path(corinvm(k)));
      //## 17/11/09 : Add a second call to the interfacing function (job 'compile')
      ierr=execstr('[o_out]='+o_scsm.gui+'(""compile"",o,k);','errcatch');
      if ierr==0 then
        if ~isequal(o_out,[]) then
          o=o_out
        end
      end
      //## get the structure graphics
      o_gr  = o_scsm.graphics;
      //## get the identification field or label field
      
      id = stripblanks(o_gr.id)
      if id == '' then
        id = stripblanks(o_scsm.model.label);
      end

    else
      id=''
    end
    mo=o.equations;
    BlockName=get_model_name(mo.model,id,Bnam)

    np=size(mo.parameters(1),'*');
    P=[];
    //** mo.parameters have size=2
    //** it only contains parameters
    if np<>0 then
      if lstsize(mo.parameters)==2 then
        mo.parameters(3)=zeros(1,np)
      end
    end

    for j=1:np
      //## loop on number of param value
      //## can be both scalar or array
      Parj=mo.parameters(1)(j)
      Parjv=mo.parameters(2)(j)
      Parj_in=Parj+'_'+BlockName
      if type(Parjv)==1 then // if Real/Complex	Integers are used with "fixed=true"

//	rpar=[rpar;matrix(Parjv,-1,1)] ;// should to be removed once modelciac is updated
        Parjv_plat=Parjv(:);
        for jj=1:size(Parjv_plat,'*')
         opar($+1)=Parjv_plat(jj)
        end

	ipar(k)=ipar(k)+size(Parjv,'*')
      end
      //======================================================
      [ok,Parj_out]=construct_Pars(Parj_in,Parjv,Parembed);
      if ~ok then return,end
      Params=[Params;Parj_out]
      if mo.parameters(3)(j)==0 then
	P=[P;Parj+'='+Parj_in]
      elseif mo.parameters(3)(j)==1 then   
	//eParjv=construct_redeclar(Parjv)
	P=[P;Parj+'(start='+Parj_in+')'];	 
      elseif mo.parameters(3)(j)==2 then
	//eParjv=construct_redeclar(Parjv)
	P=[P;Parj+'(start='+Parj_in+',fixed=true)'];
      end
      //======================================================
    end
    
    //#########
    //## models
    //#########

    
    Bnumbers=[Bnumbers k];

    //## update list of names of modelica blocks
    Bnam = [Bnam,BlockName];
    Bnames = [Bnames, Bnam($)]

    if P==[] then
      models=[models;
              '  '+mo.model+' '+tab+Bnames($)];
    else
      models=[models;
              '  '+mo.model+' '+tab+Bnames($)+'('+strcat(P,', ')+')'];
    end

    //## Add gr_i identification in comments of models

    if id<>'' then
      models($)=models($)+' ""'+id+'"";'
    else
      models($)=models($)+';'
    end

    //rajouter les ports
  end
  ipar=cumsum([1;ipar(:)])

  //links
  for k=1:size(cmat,1)
    from=cmat(k,1:3)
    to=cmat(k,4:6)
    if from(1)==0 then //input port
      nb=nb+1
      Bnumbers=[Bnumbers nb];
      Bnames=[Bnames,'B'+string(nb)];
      models=[models;'  InPutPort'+' '+tab+'B'+string(nb)+';'];
      n1='B'+string(nb)
    elseif from(3)==1 then
      p1=blklst(from(1)).equations.inputs(from(2))
      n1=Bnames(find(Bnumbers==from(1)))
    else
      p1=blklst(from(1)).equations.outputs(from(2))
      n1=Bnames(find(Bnumbers==from(1)))
    end
    if to(1)==0 then //output port
      nb=nb+1
      Bnumbers=[Bnumbers nb];
      Bnames=[Bnames,'B'+string(nb)];
      models=[models;'  OutPutPort'+' '+tab+'B'+string(nb)+';'];
      n1='B'+string(nb)
    elseif to(3)==1 then
      p2=blklst(to(1)).equations.inputs(to(2))
      n2=Bnames(find(Bnumbers==to(1)))
    else
      if size(blklst(to(1)).equations.outputs,'*')<to(2) then pause,end
      p2=blklst(to(1)).equations.outputs(to(2))
      n2=Bnames(find(Bnumbers==to(1)))
    end

    if or(blklst(from(1)).equations.model==['InPutPort','OutPutPort']) ...
         | or(blklst(to(1)).equations.model==['InPutPort','OutPutPort']) ...
    then 
      eqns=[eqns
            '  '+n1+'.'+p1+' = '+n2+'.'+p2+';']
    else
      eqns=[eqns
            '  connect ('+n1+'.'+p1+','+n2+'.'+p2+');']
    end
  end
   
  txt=[txt;
       'model '+name
       Params
       models
       'equation'
       eqns
       'end '+name+';']
  ok=%t;
endfunction

function r=validvar_modelica(s)
 r=validvar(s);

 if r then
   bad_char=['%' '#' '$']
   for j=1:size(bad_char,2)
     if strindex(s,bad_char(j)) then
       r=%f
       return
     end
   end
 end
endfunction




function     [ok,Paro]=construct_Pars(Pari,opari,Parembed)

  Paro='';
  if Pari==[] then
    ok=%f;return
  end  
  C=opari;
  [a1,b1]=size(C);
  npi=a1*b1;
  if typeof(C)== 'hypermat' then   
    x_message('type ""Hyper Matrix"" is not supported')
    ok=%f;return;
  end
  
  if (type(C)==1) then
    if isreal(C) then
      par_type='Real'
      FIXED='false'     
    else
      x_message("type ""Complex"" is not suported in Modelica");
      ok=%f;return;
    end
  elseif (typeof(C)=="int32") | (typeof(C)=="int16") |...
	(typeof(C)=="int8") |(typeof(C)=="uint32") |...
	(typeof(C)=="uint16") | (typeof(C)=="uint8") then
    par_type='Integer'
    FIXED='true'
  else 
    x_message("type """+string(typeof(C))+""" is not suported in Modelica");
    ok=%f;return;
  end
  
  if ~Parembed then 
    FIXED='true'
  end
  
  if (npi==1) then // scalar
    if par_type=='Real' then
      eopari=msprintf("%e",C)
    end  
    if par_type=='Integer' then
      eopari=msprintf("%d",C)
    end  
    fixings='(fixed='+FIXED+') '
  else
    if par_type=='Integer' then
      x_message("type ""Integer array"" is not suported in Modelica");
      ok=%f;return;
    end
    [ok,eopari]=write_nD_format(C);
    if ~ok then return;end
    fixings='(each fixed='+FIXED+') ';
    [d1,d2]=size(C);
    if (d1==1) then 
      Pari=Pari+'['+string(d2)+']'; //[d2] 
    else
      Pari=Pari+'['+string(d1)+','+string(d2)+']'; //[d1,d2] 
    end            
  end
  Paro='  parameter '+par_type+' '+Pari+ fixings+'='+eopari+ "  """+Pari+""""+';'   
  ok=%t
endfunction

 

function [ok,r]=write_nD_format(x)
  sx=size(x)
  
  if size(sx,'*')==2 then // Matrix/Vector
      [nD1,nD2]=size(x)
      if nD1==1 then //row vector or scaler
	if nD2==1 then 
	  r=msprintf("%e",x)//scaler
	else
	  r=msprintf("%e,",x(1:$-1)')+msprintf("%e",x($))// row vector
	end
	r='{'+strcat(r,',')+'}' 
	ok=%t;return;
      else
	r=[];
	for i=1:nD1
	  [ok,ri]=write_nD_format(x(i,:));//matrix or column vector
	  if ok then r(i)=ri;else return;end
	end
	r='{'+strcat(r,',')+'}';
	ok=%t;return;
      end 
  else // hypermatrix
       // typeof(x)==hypermat
       //  xd=x.entries
       //  sdims=x.dims(2:$)
       //  N=x.dims(1)
       //  cmd=':)' 
       //  n=size(sx,'c') 
       //  for i=1:n-2;cmd=':,'+cmd;end;
       //  cmd=','+cmd;
       r='';
       ok=%f;return;
  end

endfunction

// a 2x3 matrix {{xx,xx,xx},{xx,xx,xx}}
// A[2] {xx,xx}
// A[1,2] {{xx,xx}}
// A[2,1] {{xx},{xx}}
// A[1,1,2] {{{xx,xx}}}
// a=rand(2,3)
// a=[3,4];
// a=[4;2];
// a=rand(2,3);
// a=rand(1,2,3,4,5);
// a=[1 2 3 4 1 4];a(:,:,2)=[5 6 7 8 1 5] ;
//if typeof(a)== 'hypermat' then   
// disp('not supported')
//end
//sa=write_nD_format(a)


