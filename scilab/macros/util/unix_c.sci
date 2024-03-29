function unix_c(cmd)
// unix_c - used for compilation 
// cmd - a character string
  
  if prod(size(cmd))<>1 then   error(55,1),end
  
  shl=getshell();

  // done in scilab.star TMPDIR=getenv('TMPDIR')
  if MSDOS then 
    tmp=strsubst(TMPDIR,'/','\')+'\unix.out';
    if shl <> 'cmd' then
    	cmd1= cmd + ' > '+ tmp;
    else
      cmd1=cmd +'>'+ tmp +' 2>'+TMPDIR+'\unix.err';
    end
  else 
     cmd1='('+cmd+')>/dev/null 2>'+TMPDIR+'/unix.err;';
  end 
  
  stat=host(cmd1);
  
  select stat
   case 0 then
   case -1 then // host failed
    error(85)
  else 
    //sh failed
    if MSDOS then 
      if shl <> 'cmd' then
	error('unix_s: shell error');
      else
	msg=read(tmp,-1,1,'(a)');
	for i=1:size(msg,'*') do write(%io(2),'   '+msg(i));end
	msg=read(TMPDIR+'\unix.err',-1,1,'(a)');
	for i=1:size(msg,'*') do write(%io(2),'   '+msg(i));end
	error('unix_s: error during ``'+cmd+''''' execution')
	host('if exist '+TMPDIR+'\unix.err'+' del '+TMPDIR+'\unix.err');
      end
    else 
      msg=read(TMPDIR+'/unix.err',-1,1,'(a)');
      for i=1:size(msg,'*') do write(%io(2),'   '+msg(i));end
      error('unix_s: error during ``'+cmd+''''' execution')
    end 
  end
endfunction
