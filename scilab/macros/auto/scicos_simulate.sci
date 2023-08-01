function Info=scicos_simulate(scs_m,Info,%scicos_context,flag,Ignb)
// Function for running scicos simulation in batch mode
// Info=scicos_simulate(scs_m[,Info][,%scicos_context][,flag]...
//                      [,Ignb])
//
// scs_m: scicos diagram (obtained by "load file.cos"). Note that
// the version of file.cos must be the current version. If not, load
// into scicos and save.
//
// %scicos_context: a scilab struct containing values of
// symbolic variables used in the context and Scicos blocks. This
// is often used to change a parameter in the diagram context. In that
// case, make sure that in the diagram context the variable is defined such
// that it can be modified. Say a variable "a" is to be defined in the
// context having value 1, and later in batch mode, we want to change
// the value of "a". In that case, in the context of the diagram place: 
//  if ~exists('a') then a=1,end
// If you want then to run the simulation in batch mode using the value
// a=2, set:
// %scicos_context.a=2
//
// Info: a list. It must be list() at the first call, then use output
// Info as input Info for the next calls. Info contains compilation and
// simulation information and is used to avoid recompilation when not
// needed.
//
// flag: string. If it equals 'nw' (no window), then blocks using
// graphical windows are not executed. Note that the list of such
// blocks must be updated as new blocks are added.
//
// Ignb : matrix of string : The name of blocks to ignore.
// If flag is set and equal to 'nw' then Ignb contains
// name of blocks that are added to the list
// of blocks to ignore.
//

  noguimode=find(sciargs()=="-nogui");
  if (noguimode <>[]) then
     clear noguimode
     flag='nw'
  //    warning(" Scilab in no gui mode : Scicos unavailable");
  //    abort;
  end;
  clear noguimode

  //** define Scicos data tables
  if (~isdef("scicos_pal") | ~isdef("%scicos_menu") | ..
      ~isdef("%scicos_short") | ~isdef("%scicos_help") | ..
      ~isdef("%scicos_display_mode") | ~isdef("modelica_libs") | ..
      ~isdef("scicos_pal_libs") | ~isdef("%scicos_gif") | ..
      ~isdef("%scicos_contrib") | ~isdef("%scicos_libs")) then
         [scicos_pal,%scicos_menu,...
          %scicos_short,%scicos_help,..
          %scicos_display_mode,modelica_libs,..
          scicos_pal_libs,%scicos_lhb_list,.. 
          %CmenuTypeOneVector,%scicos_gif,..
          %scicos_contrib,%scicos_libs]=initial_scicos_tables()
         clear initial_scicos_tables
  end

  //** initialize a "scicos_debug_gr" variable
  %scicos_debug_gr = %f;

  //** list of scopes to ignore
  Ignoreb=['bouncexy',...
           'cscope',...
           'cmscope',...
           'canimxy',...
           'canimxy3d',...
           'cevscpe',...
           'cfscope',...
           'cscopexy',...
           'cscopexy3d',...
	   'cscopxy',..
	   'cscopxy3d',..
           'cmatview',...
           'cmat3d',...
           'affich',...
           'affich2']

  //** load macros libraries and palettes
  load SCI/macros/scicos/lib
  exec(loadpallibs,-1)

  //** redefine some gui functions
  prot=funcprot();funcprot(0);
  deff('disablemenus()',' ')
  deff('enablemenus()',' ')
  do_terminate=do_terminate1
  funcprot(prot)

  //** check/set rhs parameters
  if argn(2)==1 then
    Info=list()
    %scicos_context=struct()
    flag=[]
    Ignb=[]
  elseif argn(2)==2 then
    if type(Info)==10&(stripblanks(Info)=='nw') then
      Info=list()
      flag='nw'
    elseif type(Info)<>15 then
      Info=list()
      flag=[]
    else
      flag=[]
    end
    %scicos_context=struct()
    Ignb=[]
  elseif argn(2)==3 then
    if type(Info)<>15 then
      Info=list()
    end
    if type(%scicos_context)==10&(stripblanks(%scicos_context)=='nw') then
      %scicos_context=struct()
      flag='nw'
    elseif type(%scicos_context)<>17 then
      %scicos_context=struct()
      flag=[]
    else
      flag=[]
    end
    Ignb=[]
  elseif argn(2)==4 then
    if type(Info)<>15 then
      Info=list()
    end
    if type(%scicos_context)<>17 then
      %scicos_context=struct()
    end
    if type(flag)<>10 then
     flag=[]
    elseif (stripblanks(flag)<>'nw') then
       flag=[]
    end
    Ignb=[]
  elseif argn(2)==5 then
    if type(Info)<>15 then
      Info=list()
    end
    if type(%scicos_context)<>17 then
      %scicos_context=struct()
    end
    if type(flag)<>10 then
      flag=[]
    elseif (stripblanks(flag)<>'nw') then
      flag=[]
    end
    if type(Ignb)<>10 then
      Ignb=[]
    else
      Ignb=(Ignb(:))'
    end
  else
     error('scicos_simulate : wrong number of parameters.')
  end

  [ierr,scicos_ver,scs_m]=update_version(scs_m)
  if ierr<>0 then
      message("Can''t convert old diagram (problem in version)")
      return
  end

// 
//   //check version
//   current_version = get_scicos_version()
//   scicos_ver = find_scicos_version(scs_m)
// 
//   //do version
//   if scicos_ver<>current_version then
//     ierr=execstr('scs_m=do_version(scs_m,scicos_ver)','errcatch')
//     if ierr<>0 then
//       message("Can''t convert old diagram (problem in version)")
//       return
//     end
//   end

  //prepare from and to workspace stuff
  curdir=getcwd()
  chdir(TMPDIR)
  mkdir('Workspace')
  chdir('Workspace')
  %a=who('get');
  %a=%a(1:$-predef()+1);  // exclude protected variables
  for %ij=1:size(%a,1) 
    var=%a(%ij)
    if var<>'ans' & typeof(evstr(var))=='st' then
      ierr=execstr('x='+var+'.values','errcatch')
      if ierr==0 then
        ierr=execstr('t='+var+'.time','errcatch')
      end
      if ierr==0 then
        execstr('save('"'+var+''",x,t)')
      end
    end
  end
  chdir(curdir)
  // end of /prepare from and to workspace stuff

  Ignore=['affich',...
          'affich2']

  if flag=='nw' then
    Ignore=Ignoreb
  end

  if Ignb<>[] then
    Ignore=[Ignore,Ignb]
  end

  //** retrieve Info list
  if Info<>list() then
    [%tcur,%cpr,alreadyran,needstart,needcompile,%state0]=Info(:)
  else
    %tcur=0;%cpr=list();alreadyran=%f;needstart=%t;needcompile=4;%state0=list();
  end
  //** set solver
  tolerances=scs_m.props.tol
  solver=tolerances(6)
  %scicos_solver=solver
  
  //** set variables of context
  [%scicos_context,ierr]=script2var(scs_m.props.context, ...
				    %scicos_context);
  if ierr==0 then 
    [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr,%scicos_context);
    if needcompile<>4&size(%cpr)>0 then %state0=%cpr.state,end
    alreadyran=%f
  else
      error(['Incorrect context definition, '+lasterror()] )
  end

  if %cpr==list()|needcompile>1 then need_suppress=%t, else need_suppress=%f,end
  [%cpr,%state0_n,needcompile,alreadyran,ok]=..
      do_update(%cpr,%state0,needcompile)
  if ~ok then error('Error updating parameters.'),end

  if or(%state0_n<>%state0) then //initial state has been changed
    %state0=%state0_n
    [alreadyran,%cpr]=do_terminate1(scs_m,%cpr)
    choix=[]
  end
  if %cpr.sim.xptr($)-1<size(%cpr.state.x,'*') & solver<100 then
    mprintf("\n\r Diagram has been compiled for implicit solver, switching to implicit Solver!\n\r")
    solver=100
    tolerances(6)=solver
  elseif (%cpr.sim.xptr($)-1==size(%cpr.state.x,'*')) & ..
	( solver==100 & size(%cpr.state.x,'*')<>0) then
    mprintf("\n\r Diagram has been compiled for explicit solver, switching to explicit Solver!\n\r")
    solver=0
    tolerances(6)=solver
  end

  if need_suppress then //this is done only once
    for i=1:length(%cpr.sim.funs)
      if type(%cpr.sim.funs(i))<>13 then
	if find(%cpr.sim.funs(i)(1)==Ignore)<>[] then
	  %cpr.sim.funs(i)(1)='trash';
	end
      end
    end
  end

  if needstart then //scicos initialisation
    if alreadyran then
      [alreadyran,%cpr]=do_terminate1(scs_m,%cpr)
      alreadyran=%f
    end
    %tcur=0
    %cpr.state=%state0
    tf=scs_m.props.tf;
    if tf*tolerances==[] then 
      error(['Simulation parameters not set']);
    end
    XML=TMPDIR+'/'+stripblanks(scs_m.props.title(1))+'_imf_init.xml';     
    XML=pathconvert(XML,%f,%t);    
    XMLTMP=TMPDIR+'/'+stripblanks(scs_m.props.title(1))+'_imSim.xml'
    XMLTMP=pathconvert(XMLTMP,%f,%t);
    
    if fileinfo(XML)<>[] then 
      if MSDOS then 
	cmnd='copy /Y /A '+XML+' '+XMLTMP;
	if execstr('unix_s(cmnd)','errcatch')<>0 then
	  x_message(['Unable to copy XML files']);
	end
      else
	cmnd='cp -f '+XML+' '+XMLTMP;
	if execstr('unix_s(cmnd)','errcatch')<>0 then
	  x_message(['Unable to copy XML files']);
	end
      end     
      
      //x_message(['Scicos cannot find the XML data file required for the simulation';..
      //	 'please either compile the diagram, in this case Sccios uses'; 
      //	 'parameters defined in Scicos blocks and the Scicos context';
      //	 'or you can save the XML file defined in the initialization GUI']);
      //return;
    end
    ierr=execstr('[state,t]=scicosim(%cpr.state,%tcur,tf,%cpr.sim,'+..
		 '''start'',tolerances)','errcatch')
    if ierr<>0 then
      error(['Initialisation problem:'])
    end
    %cpr.state=state
  end

  ierr=execstr('[state,t]=scicosim(%cpr.state,%tcur,tf,%cpr.sim,'+..
	       '''run'',tolerances)','errcatch')

  if ierr==0 then
    %cpr.state=state
    alreadyran=%t
    if tf-t<tolerances(3) then
      needstart=%t
      [alreadyran,%cpr]=do_terminate1(scs_m,%cpr)
    else
      %tcur=t
    end
  else
    error(['Simulation problem:';lasterror()])
  end

  Info=list(%tcur,%cpr,alreadyran,needstart,needcompile,%state0)

  [txt,files]=returntoscilab()
  n=size(files,1)
  for i=1:n
    load(TMPDIR+'/Workspace/'+files(i))
    execstr(files(i)+'=struct('"values'",x,'"time'",t)')
  end
  execstr(txt)
endfunction

function [alreadyran,%cpr]=do_terminate1(scs_m,%cpr)
// Copyright INRIA

  if prod(size(%cpr))<2 then   alreadyran=%f,return,end
  par=scs_m.props;

  if alreadyran then
    alreadyran=%f
    //terminate current simulation
    ierr=execstr('[state,t]=scicosim(%cpr.state,par.tf,par.tf,'+..
		 '%cpr.sim,''finish'',par.tol)','errcatch')

    %cpr.state=state
    if ierr<>0 then
      error(['End problem:';lasterror()])
    end
  end
endfunction
