function [ok, scs_m, %cpr, edited] = do_load(fname,typ)
// Copyright INRIA
//**
//** Load a Scicos diagram

  global %scicos_demo_mode ; 

  [lhs,rhs] = argn(0) ;

  if rhs<=0 then
    fname=[]
  end

  if rhs<2 then
    typ = "diagram"
  end

  if alreadyran & typ=="diagram" then
    do_terminate(); //end current simulation
  end

  scicos_debug(0); //set debug level to 0 for new diagram loaded

  current_version = get_scicos_version()
  if winsid()<>[] then
    xpause(100)  // quick and dirty fix for windows bug on fast
                 // computers
  end
  //** function [p] = tk_getfile(file_mask, path, Title, multip)
  if %scicos_demo_mode==1 then
      //** open a demo file
      if fname==[] then
        if %scicos_gui_mode==1 then
          file_mask = ["*.cos*","*.xml"]
        else
          file_mask = "*.cos*"
        end
        path      =  SCI+"/demos/scicos"
        fname     = getfile(file_mask, path)
      end
  else
      //** conventional Open
      if fname==[] then
        if %scicos_gui_mode==1 then
          fname = getfile(['*.cos*','*.xml'])
        else
          fname = getfile('*.cos*')
        end
      end
  end 
  %scicos_demo_mode = []; //** clear the variable


  fname = stripblanks(fname)

  if fname<>emptystr() then
    %cpr=list()
    scs_m=[]
    edited = %f
    [path,name,ext]=splitfilepath_cos(fname)
    //first pass
    if ext=='cos'|ext=='COS'|ext=='cosf'|ext=='COSF'|ext==''|ext=='XML'|ext=='xml' then
      if ext=='' then  // to allow user not to enter necessarily the extension
        fname=fname+'.cos'
        ext='cos'
      end
      [x,ierr]=fileinfo(fname)
      if ierr==0 then
        ww=stacksize()
        if ww(1)<2*x(1) then
          disp('stacksize increased to '+string(2*x(1)))
          stacksize(2*x(1))
        end
      else
        message([name+' cannot be loaded.';'Opening a new diagram'])
        ext='new'
      end
    else
      message(['Only *.cos (binary) and *.cosf (formatted) files';
               'allowed'])
      ok=%f
      //scs_m=scicos_diagram(version=current_version)
      scs_m = get_new_scs_m();
      return
    end

    //second pass
    if ext=='cos'|ext=='COS' then
      ierr=execstr('load(fname)','errcatch')
      ok=%t
    elseif ext=='cosf'|ext=='COSF' then
      ierr=execstr('exec(fname,-1)','errcatch')
      ok=%t
    elseif ext=='xml'|ext=='XML' then
      printf('Opening an XML file. Please wait ...............')
      ierr=execstr('scs_m=xml2cos(fname)','errcatch')
      ok=%t
    elseif ext=='new'
      ok=%t
      ierr=0
      scs_m=scicos_diagram(version=current_version)
      scs_m.props.title=name
    end
    if ierr<>0 then
      if ext=='xml'|ext=='XML' then
	message(['An error has occur during execution of '+name+'.';
	    'Please check the format of your XML file'])
	printf('Error\n');
      else
	message('An error has occur during execution of '+name+'.')
      end
      ok=%f
      scs_m=get_new_scs_m();     
      return
    end
    if ext=='xml'|ext=='XML' then
      needcompile=4;%cpr=list();
      context=scs_m.props.context
      [%scicos_context,ierr]=script2var(context,struct())
//      [ok,scs_m]=do_define_and_set(scs_m)
      [scs_m,cpr,vv,ok]=do_eval(scs_m,%cpr,%scicos_context,%f,'XML');
      if ~ok then
	x_message(['An error occured while opening the diagram';
	    lasterror();
	    'The diagram will not be opened'])
	scs_m= get_new_scs_m();;
	printf('Error\n');
	return;
      end
      printf('Done\n');
    end
    
    //for compatibility
    scicos_ver=find_scicos_version(scs_m)
    if scicos_ver=='scicos2.2' then
      if scs_m==[] then scs_m=x,end //for compatibility
    end

    //##update version
    [ierr,scicos_ver,scs_m]=update_version(scs_m)
    if ierr<>0 then
      message('An error has occured during the update of '+name+'.')
      ok=%f
      scs_m = get_new_scs_m();
      //scs_m=scicos_diagram(version=current_version)
      return
    end

    //## reset %cpr and edited=%t if we have
    //## do a convertion
    if scicos_ver<>current_version then
      %cpr=list()
      edited=%t
    end
    
  else
    ok=%f
    return
  end
  scs_m.props.title=[scs_m.props.title(1),path]
  if ext=='xml'|ext=='XML' then
    scs_m_sav=scs_m;
    [scs_m,ok]=generating_atomic_code(scs_m)
    if ~ok then scs_m=scs_m_sav;ok=%t;end
  end
  if ~ok then scs_m = get_new_scs_m();return;end
  if typ=='diagram' then
    if %cpr<>list() then

      for jj=1:size(%cpr.sim.funtyp,'*')
	if type(%cpr.corinv(jj))==15 then
	  //force recompilation if diagram contains Modelica Blocks
	  //Can be improved later, re-generating C code only...
	  %cpr=list()
	  edited=%t
	  return
	end
	
	ft=modulo(%cpr.sim.funtyp(jj),10000)
	if ft>999 then
	  funam=%cpr.sim.funs(jj)
	  //regenerate systematically dynamically linked blocks forsafety
	  //[a,b]=c_link(funam); while a;  ulink(b);[a,b]=c_link(funam);end
	  //should be better than
	  //"if  ~c_link(funam) then"
	  //but ulink remove .so files and Makefile doesnt depends on .so file...
	  if ~c_link(funam) then

	    qqq=%cpr.corinv(jj)
	    path=list('objs',qqq(1))
	    for kkk=qqq(2:$)
	      path($+1)='model'
	      path($+1)='rpar'
	      path($+1)='objs'
	      path($+1)=kkk
	    end

	    path($+1)='graphics';path($+1)='exprs';path($+1)=2;
	    tt=scs_m(path)
	    if ft>1999 then
	      pp=%cpr.corinv(jj)
	      if size(pp,'*')>1 then
	        scs_string='scs_m.objs('+sci2exp(pp(1))+').model.rpar'
		pp(1)=[]
		while size(pp,'*')>1
		  scs_string=scs_string+'.objs('+sci2exp(pp(1))+').model.rpar'
		  pp(1)=[];
                end
                scs_string=scs_string+'.objs('+sci2exp(pp(1))+')'
              else
	        scs_string='scs_m.objs('+sci2exp(pp(1))+')'
 	      end
	      execstr('fnam='+scs_string+'.model.sim(1)');
	      if fnam=='asuper' then 
	        execstr('[modeli,ok]=recur_scicos_block_link('+scs_string+',''c'')')
		clear modeli fnam pp scs_string        
	      else 
	        [ok]=scicos_block_link(funam,tt,'c')
	      end
	    else
	      [ok]=scicos_block_link(funam,tt,'f')
	    end
	  end
	end
      end
    end
//    if ext=='xml'|ext=='XML' then
      //if the diagram contains an affiche block a window is openend on eval action
//      open_win=winsid();
//      k=find(open_win==0);
//      xdel(open_win(k));
//    end
  elseif typ=='palette' then
    //## Extract palette only if the pallette is composed
    //## by only one PAL_f block
    ierr=execstr('nbobj=lstsize(scs_m.objs)','errcatch')
    if ierr==0 then
      if nbobj==1 then
        ierr=execstr('isPAL_f=(scs_m.objs(1).gui)==''PAL_f''','errcatch')
        if ierr==0 then
          if isPAL_f then
            scs_m = scs_m.objs(1).model.rpar
          end
        end
      end
    end
  end
endfunction

function [ok,scs_m]=do_define_and_set(scs_m,flg)

%mprt=funcprot()
funcprot(0) 
getvalue=setvalue;
deff('message(txt)','x_message(''In block ''+o.gui+'': ''+txt);global %scicos_prob;%scicos_prob=resume(%t)')

global %scicos_prob
%scicos_prob=%f

//## overload some functions used in GUI
deff('[ok,tt]        =  FORTR(funam,tt,i,o)','ok=%t')
deff('[ok,tt,cancel] =  CFORTR2(funam,tt,i,o)','ok=%t,cancel=%f')
deff('[ok,tt]        =  CFORTR(funam,tt,i,o)','ok=%t')
deff('[x,y,ok,gc]    =  edit_curv(x,y,job,tit,gc)','ok=%t')
deff('[ok,tt,dep_ut] = genfunc1(tt,ni,no,nci,nco,nx,nz,nrp,type_)',..
     'dep_ut=model.dep_ut;ok=%t')
deff('result         = dialog(labels,valueini)','result=valueini')
deff('[result,Quit]  = scstxtedit(valueini,v2)','result=valueini,Quit=0')
deff('[ok,tt]        = MODCOM(funam,tt,vinp,vout,vparam,vparamv,vpprop)',..
     '[dirF,nameF,extF]=fileparts(funam);..
      tarpath=pathconvert(TMPDIR+''/Modelica/'',%f,%t);..
      if (extF=='''')  then,..
         funam1=tarpath+nameF+''.mo'';..
      elseif fileinfo(funam)==[] then,..
         funam1=funam;..
      end;..
      mputl(tt,funam1);')
context=scs_m.props.context
if argn(2)<2 then
  global %scicos_context;
  [%scicos_context,ierr]=script2var(context,struct());
else
  [%scicos_context,ierr]=script2var(context,%scicos_context);
end
n=size(scs_m.objs);
for i=1:n
  o=scs_m.objs(i);
  if typeof(o)=='Block'|typeof(o)=='Text' then
    graphics=o.graphics;
    rpar=o.model.rpar;
    sim=o.model.sim;
    ierr=execstr('o='+o.gui+'(""define"",o);','errcatch');
     if ierr<>0 then
       x_message(['An error occured while opening the diagram';
	   lasterror();
	   'The diagram will not be opened'])
       ok=%f;
       scs_m= get_new_scs_m();;
       return
     end
    //update model compatibility with old csuper blocks
    if lstsize(o.model)<lstsize(scicos_model()) then
      o.model=update_model(o.model);
    end
    o.graphics.exprs=graphics.exprs;
    if or(o.model.sim(1)==['super','asuper'])|(o.model.sim(1)=='csuper'& ~isequal(o.model.ipar,1))
      [ok,scs_m_1]=do_define_and_set(rpar,%t)
      if ~ok then scs_m=get_new_scs_m();return;end
      o.model.rpar=scs_m_1;
      if sim(1)=="asuper" then
	o.model.sim=sim;
      end
      o.model.in=-1*ones(size(graphics.pin,'*'),1);
      o.model.in2=-2*ones(size(graphics.pin,'*'),1);
      o.model.intyp=-1*ones(1,size(graphics.pin,'*'));
      o.model.out=-1*ones(size(graphics.pout,'*'),1);
      o.model.out2=-2*ones(size(graphics.pout,'*'),1);
      o.model.outtyp=-1*ones(1,size(graphics.pout,'*'));
      o.model.evtin=ones(size(graphics.pein,'*'),1);
      o.model.evtout=ones(size(graphics.peout,'*'),1);
    else
     ierr=execstr('o='+o.gui+'(""set"",o);','errcatch');
     if ierr<>0 then
       x_message(['An error occured while opening the diagram';
	   lasterror();
	   'The diagram will not be opened'])
       ok=%f;
       scs_m= get_new_scs_m();;
       return
     end
    end
    o.graphics=graphics;
  end
  scs_m.objs(i)=o;
end
//if argn(2)<2 then
  //scs_m=do_eval(scs_m);
//end
endfunction

function model=update_model(model)
tt='model=scicos_model(';
xx=getfield(1,o.model)
for i=2:size(xx,'*')-1
  tt=tt+xx(i)+'=model.'+xx(i)+',';
end
tt=tt+xx(i+1)+'=model.'+xx(i+1)+')';
execstr(tt);
endfunction

function [scs_m,ok]=generating_atomic_code(scs_m)
scs_m_sav=scs_m;
for i=1:lstsize(scs_m.objs)
  o=scs_m.objs(i);
  if typeof(o)=='Block' then
    if or(o.model.sim(1)==['super','asuper','csuper']) then
      [scs_m1,ok]=generating_atomic_code(o.model.rpar)
      if ~ok then scs_m=scs_m_sav;return;end
      o.model.rpar=scs_m1;
      scs_m.objs(i)=o;
      if o.model.sim(1)=='asuper' then
	printf('Generating the code for the atomic subsystem ......')
	ierr=execstr('[o,needcompile,ok]=do_CreateAtomic(o,i,scs_m)','errcatch');
	if ierr<>0 then
	  printf('Error\n')
	  printf('An Error Occured While trying to generate automatically the code for the atomic subsystem\n.Please try to do it manually\n.')
	 ok=%f;return;
	end
	if ~ok then scs_m=scs_m_sav;printf('Error\n');return;end
	printf('Done\n');
	scs_m.objs(i)=o;
	//scs_m = update_redraw_obj(scs_m,list('objs',i),o);
      end
    end
  end
end
endfunction
