function tklib=gettklib()
  if MSDOS then 
    tklib='tk85.dll';
  elseif getos()=='Darwin' then
    tklib='libtk8.6.so';
  else
    // In the binary version libtk8.4.so has been copied in
    // the SCI/bin directory and scilab script add SCI/bin
    // to the LD_LIBRARY_PATH (or SHLIB_PATH).
    // So, If libtk8.4.so (or .sl) exists in SCI/bin ... it's ok
    
    if fileinfo(SCI+'/bin/'+'libtk8.6.so') <> [] then
      tklib='libtk8.6.so';
      return;
    end
    execstr('link(''libtk8.6.so'')', 'errcatch')
    if ans == 0 then
      tklib='libtk8.6.so'
    else
      execstr('link(''libtk8.6.so.0'')', 'errcatch')
      if ans == 0 then
	tklib='libtk8.6.so.0'
      else
	mprintf('Warning: Error loading libtk8.6.so :""'+lasterror()+'""')
      end
    end
  end
endfunction
