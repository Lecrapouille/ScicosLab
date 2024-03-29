function [scs_m, edited] = do_SaveAs()
//
// Copyright INRIA

  fname=scs_m.props.title(1);

  if %scicos_gui_mode==1 then
    tit = ["Use .cos extension for binary, .cosf for ascii and .xml for"+...
         " XML file"];
    file_mask = ["*.cos*","*.xml"]
    fname = savefile(file_mask,emptystr(),tit,fname)
  else
    tit=['Use .cos extension for binary and .cosf for ascii file'];
    file_mask = ["*.cos*"]
    fname = savefile(file_mask,emptystr(),tit)
  end

  if fname==emptystr() then
    return ; //** EXIT point 
  end

  [path,name,ext] = splitfilepath_cos(fname)
  
  select ext
    
   case "cos" then
    ok = %t
    frmt = 'unformatted'
    
   case "cosf" then
    ok = %t
    frmt = 'formatted'
    
   case "" then
     ok = %t
     frmt = 'unformatted'
     fname=fname+".cos"
     ext='cos'

   case "xml" then
    ok = %t
    frmt = 'xmlformatted'
  else
    message("Only *.cos binary or cosf ascii files allowed");
    return //** EXIT Point 
  end

  if ~super_block & ~pal_mode then
    //update %cpr data structure to make it coherent with last changes
    if needcompile==4 then
      %cpr = list()
    else
      [%cpr, %state0, needcompile, alreadyran, ok] = do_update(%cpr,%state0,needcompile); 
      if ~ok then
         return
      end
      %cpr.state=%state0
    end
  else
    %cpr=list()
  end

  // open the selected file
  if frmt=='formatted'
    [u,err] = file('open',fname,'unknown',frmt)
  else
    [u,err] = mopen(fname,'wb')
  end
  if err<>0 then
    message("File or directory write access denied")
    return
  end


  scs_m;
  scs_m.props.title = [name, path] // Change the title
  if pal_mode then
    scs_m.objs(1).graphics.id=name
    scs_m.objs(1).model.rpar.props.title=[name, path] // Change the title
  end
  
  // save
  if ext=="cos" then
    save(u,scs_m,%cpr)
  elseif ext=="xml" then
    [ok,t]=cos2xml(do_purge(scs_m),'',%f)
    if ~ok then 
      message("Error in xml format")
      file('close',u)
      return
    end
    mputl(t,u);
  else
  
    ierr = cos2cosf(u,do_purge(scs_m));
    if ierr<>0 then
      message("Directory write access denied")
      file('close',u) ;
      return 
    end
  end
  
  file('close',u)

  //** disp("... SaveAs debug"); pause 
  
  //** if the current window is list of the phisically existing Scilab windows list winsid()
  if or(curwin==winsid()) then
    drawtitle(scs_m.props)  // draw the new title
  end   

  edited = %f
  if pal_mode then
    scicos_pal = update_scicos_pal(path,scs_m.props.title(1),fname),
    scicos_pal = resume(scicos_pal)
  end
endfunction
