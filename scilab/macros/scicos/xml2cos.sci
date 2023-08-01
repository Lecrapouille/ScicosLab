function [scs_m,atomicflg]=xml2cos(xmlfilename,typ)
 atomicflg=%f;
 [lhs,rhs]=argn(0)
 if exists('scicoslib')==0 then load('SCI/macros/scicos/lib'),end
 exec(loadpallibs,-1) //to load the palettes libraries
 if rhs<2 then
   typ=[];
   global txtline
   txtline=1
   flag=%f;
   txt=mgetl(xmlfilename)
  // unit=file('open',xmlfilename,'unknown')
 end
 while and(typ<>'</Diagram>') do
    //t=read_new_line(txt)
   //t=readc_(unit);
   //typ=tokens(t);
   //disp(typ(1))
   if typ(1)=='<Diagram' then
     scs_m=scicos_diagram();
   elseif typ(1)=='<ScicosVersion' then
     ttyp=tokens(typ(2),'""')
     if size(ttyp,'*')>1 then scs_m.version=ttyp(2);else scs_m.version='';end
   elseif typ(1)=='<AtomicDiagram' then
     ttyp=tokens(typ(2),'""');
     if ttyp(2)=='yes' then atomicflg=%t; else atomicflg=%f;end
   elseif typ(1)=='<Parameters>' then
     scs_m.props=scicos_params();
     //t=readc_(unit);
     t=read_new_line(txt);
     typ=tokens(t);
     while typ(1)<>'</Parameters>' do
       ttyp=tokens(typ(2),'''')
       //disp(ttyp(2));
       if ttyp(2)=='context' then
         //t=readc_(unit);
	 t=read_new_line(txt);
	 cntxt=cos_subst(t);
	 scs_m.props.context=evstr(cntxt);
       elseif ttyp(2)=='options' then
         scs_m=load_par('</params>','options','props')
       else
	 indx1=strindex(t,'value=''');indx1=indx1+6;
	 indx2=length(t)-4;
	 tttyp=strsplit(t,[indx1,indx2]);
	 //tttyp=tokens(typ(3),'''')
	 if ttyp(2)<>'params' then 
	   execstr('scs_m.props.'+ttyp(2)+'='+tttyp(2));
	 end
       end
       //t=readc_(unit);
       t=read_new_line(txt);
       typ=tokens(t);
       if typ(1)=='</params>' then
         //t=readc_(unit);
	 t=read_new_line(txt);
         typ=tokens(t);         
       end
     end
   elseif typ(1)=='<CodeGeneration>' then
     scs_m.codegen=scicos_codegen();
     //t=readc_(unit);
     t=read_new_line(txt);
     typ=tokens(t);
     while typ(1)<>'</CodeGeneration>' do
       ttyp=tokens(typ(2),'''')
       indx1=strindex(t,'value=''');indx1=indx1+6;
       indx2=length(t)-4;
       tttyp=strsplit(t,[indx1,indx2]);
       if ttyp(2)<>'pcodegen_target' then 
	 execstr('scs_m.codegen.'+ttyp(2)+'='+tttyp(2))
       end
       //t=readc_(unit);
       t=read_new_line(txt);
       typ=tokens(t);
     end
   elseif typ(1)=='<Objects>' then
     //t=readc_(unit);
     t=read_new_line(txt);
     typ=tokens(t);
     while typ(1)<>'</Objects>' do
     if typ(1)=='<Block' then
       scs_m=treat_blocks('</Block>',typ)
     elseif typ(1)=='<Text' then
       scs_m=treat_blocks('</Text>',typ)
     elseif typ(1)=='<Link' then
       numb=get_numb(typ);
       execstr('scs_m.objs('+numb+')=scicos_link()');
       //t=readc_(unit);
       t=read_new_line(txt);
       typ=tokens(t);
       while typ(1)<>'</Link>' do
         ttyp=tokens(typ(2),'''')
	 //disp(ttyp(2))
	 indx1=strindex(t,'value=''');indx1=indx1+6;
	 indx2=length(t)-4;
	 tttyp=strsplit(t,[indx1,indx2]);
         //tttyp=tokens(typ(3),'''')
	 if ttyp(2)<>'mlist' then 
	   execstr('scs_m.objs('+numb+').'+ttyp(2)+'='+tttyp(2));
	 end
	 //t=readc_(unit);
	 t=read_new_line(txt);
         typ=tokens(t);
       end    
     elseif typ(1)=='<Deleted' then
       numb=get_numb(typ);
       execstr('scs_m.objs('+numb+')=mlist(''Deleted'')');
     end
     //t=readc_(unit);
     t=read_new_line(txt);
     typ=tokens(t);
     end
   end
   t=read_new_line(txt);
   typ=tokens(t);   
   //disp('end')
 end
 //scs_m.version='scicos4.2'
 if rhs<2 then
   clearglobal txtline;
   //file('close',unit);
 end
endfunction

function field=cos_subst(field)
  field=strsubst(field,'&amp;','&');
  field=strsubst(field,'&lt;','<');
  field=strsubst(field,'&gt;','>');
  field=strsubst(field,'&quot;','""');
  field=strsubst(field,'&apos;','''');
  field=strsubst(field,'<p>','');
  field=strsubst(field,'</p>','');
endfunction

function scs_m=load_par(symbol,id1,id2)
  scs_m=scs_m;global txtline
  //t=readc_(unit);
  t=read_new_line(txt);
  typ=tokens(t);
  while typ(1)<>symbol do
    //disp(typ(1))
    if typ(1)=='<Diagram' then
 //disp('here')
      [scs_m1,atomicflg]=xml2cos(xmlfilename,typ)
      execstr('scs_m.'+id2+'.model.rpar=scs_m1');
      if atomicflg then execstr('scs_m.'+id2+'.model.sim=list(""asuper"",2004)');end
      t=read_new_line(txt);
      typ=tokens(t);
    else
      ttyp=tokens(typ(2),'''')
      //disp(ttyp(2));
      if ttyp(2)=='rpar' & size(typ,'*')==2 then  // is kept for compatibility
	if symbol=='</Block>' then
	  scs_m1=xml2cos(xmlfilename,typ);
	  if ttyp(2)<> 'mlist' then
	    execstr('scs_m.'+id2+'.'+id1+'('''+ttyp(2)+''')='+sci2exp(scs_m1,0));
	  end
	else
	  //t=readc_(unit);
	  t=read_new_line(txt);
	  if ttyp(2)<> 'mlist' then
	    execstr('scs_m.'+id2+'.'+id1+'('''+ttyp(2)+''')='+cos_subst(t));
	  end
	end
      elseif ttyp(2)=='gr_i' then
	//t=readc_(unit);
	t=read_new_line(txt);
	if ttyp(2)<> 'mlist' then
	  execstr('scs_m.'+id2+'.'+id1+'('''+ttyp(2)+''')='+cos_subst(t));
	end
      elseif ttyp(2)=='exprs' then
	exprstxt=[];
	t=read_new_line(txt);
	typ=tokens(t);
        indx_end=grep(txt,'</graphics>');
        ind=find(indx_end>txtline);ind=ind(1);
        indx_end=indx_end(ind);
        exprstxt=cos_subst(txt(txtline:indx_end-1))
        txtline=indx_end;
	if size(exprstxt,'*')>1 then
	  unit=file('open',TMPDIR+'/exprstxt.sce','unknown');
	  exprstxt=['scs_m.'+id2+'.'+id1+'('''+ttyp(2)+''')=..';exprstxt]
	  write(unit,exprstxt);
	  file('close',unit);
	  execstr('exec(""'+strsubst(TMPDIR,'''','''''')+'/exprstxt.sce"",-1);');
	else
	  if ttyp(2)<> 'mlist' then
	    execstr('scs_m.'+id2+'.'+id1+'('''+ttyp(2)+''')='+exprstxt);
	  end
	end 
      else
	indx1=strindex(t,'value=''');indx1=indx1+6;
	indx2=length(t)-4;
	tttyp=strsplit(t,[indx1,indx2]);
	//tttyp=tokens(typ(3),'''')
	//disp(tttyp(2));
	if ttyp(2)<>'tlist' & ttyp(2)<> 'mlist' & ttyp(2)<>'type' & ttyp(2)<> 'Action' & ...
	      ttyp(2)<> 'Grid' & ttyp(2)<> 'Snap' & ttyp(2)<>'D3' & ttyp(2) ...
	      <> 'Wgrid' then
	  execstr('scs_m.'+id2+'.'+id1+'('''+ttyp(2)+''')='+cos_subst(tttyp(2)))
	end
      end
      //t=readc_(unit);
      t=read_new_line(txt);
      typ=tokens(t);
      if or(typ==['</graphics>','</model>']) then
	//t=readc_(unit);
	t=read_new_line(txt);
	typ=tokens(t);
      end
    end
  end
endfunction

function numb=get_numb(typ)
 ttyp=tokens(typ(2),'''')
 ttyp=tokens(ttyp(1),'""')
 //disp(ttyp(2))
 //numb=strsplit(ttyp(2),[1:length(ttyp(2))-1])
 ind=strindex(ttyp(2),'_');
 //ind=grep(numb,'_')
 if ind==[] then
   numb=strsplit(ttyp(2),3);
 else
   numb=strsplit(ttyp(2),ind($));  
 end
 numb=numb(2);
endfunction

function scs_m=treat_blocks(symbol,typ)
 scs_m=scs_m;global txtline
 numb=get_numb(typ);
 //disp(numb);
 if symbol=='</Block>' then
   execstr('scs_m.objs('+numb+')=scicos_block();');
 else
   execstr('scs_m.objs('+numb+')=scicos_text();');
 end
 //t=readc_(unit);
 t=read_new_line(txt);
 typ=tokens(t);
 while typ(1)<>symbol do
   ttyp=tokens(typ(2),'''')
   //disp(ttyp(2))
   //disp(symbol)
   if or(ttyp(2)==['graphics','model','diagram']) then
     //if ttyp(2)=='diagram' then pause;end
     scs_m=load_par(symbol,ttyp(2),'objs('+numb+')');
   //elseif ttyp(2)=='void' then
 else
   //aboif ttyp(2)=='gui' then pause;end
     indx1=strindex(t,'value=''');indx1=indx1+6;
     indx2=length(t)-4;
     tttyp=strsplit(t,[indx1,indx2]);
     //tttyp=tokens(typ(3),'''')
     if ttyp(2)<>'mlist' then 
       execstr('scs_m.objs('+numb+').'+ttyp(2)+'='+cos_subst(tttyp(2)))
     end
   end
   //t=readc_(unit);
   t=read_new_line(txt);
   typ=tokens(t);
 end
endfunction

function blk=scicos_text(v1,v2,v3,v4,v5)
// Copyright INRIA
//Block data structure initialization
  if exists('graphics','local')==0 then graphics=scicos_graphics(),end
  if exists('model','local')==0 then model=scicos_model(),end
  if exists('void','local')==0 then void='',end
  if exists('gui','local')==0 then gui='',end
  
  blk=mlist(['Text','graphics','model','void','gui'],graphics,model,void,gui)
endfunction

function t=read_new_line(txt)
global txtline
txtline=txtline+1;
t=txt(txtline)
endfunction
