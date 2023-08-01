function p=tk_savefile_scicos(file_mask,path,Title,ini)
  if ~with_tk() then error('Tcl/Tk interface not defined'),end
  arg=''
  if exists('file_mask','local')==1 then
    fmask="";
    for i=1:size(file_mask,'*')
      a=file_mask(i);
      a=strsubst(a,'.','');a=strsubst(a,'*','');
      if and(a<>[[],'']) then a=convstr(a,'u');
      else a='All';
      end
      if a=='COS' then a='Scicos'; end
      fmask=fmask+"{"""+a+" Files"" {"+file_mask(i)+"}} ";
    end
    TCL_SetVar("ftypes",fmask)
    arg = arg+" -filetypes $ftypes"
    if with_ttk() then
      if strindex(fmask,'Scicos')<>[] then
        TCL_SetVar("defaultfilter","Scicos Files")
        arg = arg+" -typevariable defaultfilter"
      end
    end
  end
  if exists('path','local')==1 then
    if ~isequal(path,emptystr()) then
      path = pathconvert(path,%f,%t)
      path=strsubst(path,"\","/")
      arg = arg+" -initialdir {"+path+"}"
    else
      if MSDOS then
        global("%tk_savefile_defaultpath")
        if exists("%tk_savefile_defaultpath","global")==1 then
          arg = arg+" -initialdir {"+%tk_savefile_defaultpath+"}"
        end
      end
    end
  end
  if exists('title','local')==1 then Title=title,end
  if exists('Title','local')==1 then arg=arg+' -title ""'+Title+'""',end
  // work around Tk bugs 3071836 and 3146418 (crash in Tk on tk_getSaveFile)
  // by not using the -initialfile option on Win with Tk 8.5.9
  if ~(MSDOS & (TCL_EvalStr("info patchlevel")=="8.5.9")) then
    if exists('ini','local')==1 then arg=arg+' -initialfile ""'+ini+'.cos""',end
  end
  TCL_EvalStr('set scifilepath [tk_getSaveFile'+arg+']')
  p=TCL_GetVar('scifilepath')
  if MSDOS then
    if ~p=="" then
      global("%tk_savefile_defaultpath");
      %tk_savefile_defaultpath = dirname(p(1));
      %tk_savefile_defaultpath=strsubst(%tk_savefile_defaultpath,"\","/")
    end
  end
endfunction

