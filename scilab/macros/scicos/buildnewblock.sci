function [ok]=buildnewblock(blknam,files,filestan,filesint,libs,rpat,ldflags,cflags,silent)
//Copyright (c) 1989-2010 Metalau project INRIA

//** buildnewblock : generates Makefiles for
//                   the generated C code of a scicos block,
//                   compile and link it in ScicosLab
//
// Input : blknam : a prefix
//         files : files to be compiled
//         filestan : files to be compiled and included in
//                    the standalone code
//         filesint : files to be compiled and included in
//                    the interfacing of standalone code
//         libs : a vector of string of object files
//                    to include in the building process
//         rpat     : a target directory
//         ldflags  : linker flags
//         cflags   : a vector of strings for Compiler flags
//         silent   : flag to only do the generation without compilation
//                    and linking
//
// Output :  ok : a flag to say if build is ok
//

  //** check rhs paramaters
  [lhs,rhs]=argn(0);

  if rhs <= 1 then files    = blknam, end
  if rhs <= 2 then filestan = '', end
  if rhs <= 3 then filesint = '', end //##
  if rhs <= 4 then libs     = '', end
  if rhs <= 5 then rpat     = TMPDIR, end
  if rhs <= 6 then ldflags  = '', end
  if rhs <= 7 then cflags   = '', end
  if rhs <= 8 then silent   = %f, end

  //@@ check if a fortran files exist
  [fd,ierr]=mopen(rpat+'/'+blknam+'f.f','r')
  if ierr==0 then
    mclose(fd)
    files=[files,blknam+'f']

    if filesint<>'' then
      filesint=[filesint,blknam+'f']
    end

    if filestan<>'' then
      filestan=[filestan,blknam+'f']
    end
  end

  //## define a variable to know if we use
  //## a ScicosLab interfacing function for the standalone
  if filesint<>'' then
    with_int = %t;
  else
    with_int = %f;
  end

  //** adjust path and name of object files
  //   to include in the building process
  if (libs ~= emptystr()) then
    libs=pathconvert(libs,%f,%t)
  end

  //** adjust cflags
  if (cflags ~= emptystr()) then
    cflags=strcat(cflags,' ')
  end

  //** otherlibs treatment
  [ok,libs,for_link]=link_olibs(libs,rpat)
  if ~ok then
    ok=%f;
    x_message(['sorry compiling problem';lasterror()]);
    return;
  end

  //** generate text of the loader file
  [txt]=gen_loader(blknam,for_link,with_int)

  //** write text of the loader in file
  ierr=execstr('mputl(txt,rpat+''/''+blknam+''_loader.sce'')','errcatch')
  if ierr<>0 then
    x_message(['Can''t write '+blknam+'_loader.sce';lasterror()])
    ok=%f
    return
  end

  //** def make file name
  Makename=rpat+'/'+'Makefile_'+blknam;

  //@@ generation of Makefiles
  if ~MSDOS then //@@ not windows
    SCI_sav = SCI
    [n]=predef(0)
    SCI = 'E:\scicoslab_43_cross'

    //@@ win32
    txt=gen_make_win32(blknam,files,filestan,libs,ldflags,cflags);
    Makename2 = strsubst(Makename,'/','\')+'.mak';
    ierr=execstr('mputl(txt,Makename2)','errcatch')
    if ierr<>0 then
      x_message(['Can''t write '+Makename2;lasterror()]);
      ok=%f;
      return;
    end

    //@@ lccwin32
    txt=gen_make_lccwin32(blknam,files,filestan,libs,ldflags,cflags);
    Makename2 = strsubst(Makename,'/','\')+'.lcc';
    ierr=execstr('mputl(txt,Makename2)','errcatch')
    if ierr<>0 then
      x_message(['Can''t write '+Makename2;lasterror()]);
      ok=%f;
      return;
    end

    SCI = SCI_sav
    clear SCI_sav
    predef(n(1))
  else //@@ windows
    if with_lcc()==%T then
      //@@ win32
      txt=gen_make_win32(blknam,files,filestan,libs,ldflags,cflags);
      Makename2 = strsubst(Makename,'/','\')+'.mak';
      ierr=execstr('mputl(txt,Makename2)','errcatch')
      if ierr<>0 then
        x_message(['Can''t write '+Makename2;lasterror()]);
        ok=%f;
        return;
      end
    else
      //@@ lccwin32
      txt=gen_make_lccwin32(blknam,files,filestan,libs,ldflags,cflags);
      Makename2 = strsubst(Makename,'/','\')+'.lcc';
      ierr=execstr('mputl(txt,Makename2)','errcatch')
      if ierr<>0 then
        x_message(['Can''t write '+Makename2;lasterror()]);
        ok=%f;
        return;
      end
    end

    SCI_sav = SCI
    [n]=predef(0)
    SCI = '/usr/lib/scicoslab_gtk-4.3'

    //@@ unix
    txt=gen_make_unix(blknam,files,filestan,libs,ldflags,cflags);
    Makename2 = strsubst(Makename,'/','\');
    ierr=execstr('mputl(txt,Makename2)','errcatch')
    if ierr<>0 then
      x_message(['Can''t write '+Makename2;lasterror()]);
      ok=%f;
      return;
    end

    SCI = SCI_sav
    clear SCI_sav
    predef(n(1))

  end

  //** generate txt of makefile and get wright name
  //   of the Makefile file
  [Makename2,txt]=gen_make(blknam,files,filestan,libs,Makename,ldflags,cflags);

  //** write text of the Makefile in the file called Makename
  ierr=execstr('mputl(txt,Makename2)','errcatch')
  if ierr<>0 then
    x_message(['Can''t write '+Makename2;lasterror()])
    ok=%f
    return
  end

  //@@ compile and link if needed
  if ~silent then

    //** unlink if necessary
    [a,b]=c_link(blknam);
    while a
      ulink(b);
      [a,b]=c_link(blknam);
    end

    //** save path in case of error in ilib_compile
    oldpath=getcwd();

    //** compile Makefile
    ierr=execstr('libn=ilib_compile(''lib''+blknam,Makename)','errcatch')
    if ierr<>0 then
      ok=%f;
      chdir(oldpath);
      x_message(['sorry compiling problem';lasterror()]);
      return;
    end

    //** link scicos generated code in ScicosLab
    libn=pathconvert(libn,%f,%t)
    //## ierr=execstr('libnumber=link(libn)','errcatch')
    //## ierr=execstr('link(libnumber,blknam,''c'')','errcatch')
    ierr=execstr('link(libn,blknam,''c'')','errcatch')

    if ierr<>0 then
      ok=%f;
      x_message(['sorry link problem';lasterror()]);
      return;
    end

  end

  //## generate makefile for interfacing function of the standalone
  if filesint<>'' then
     //## def name of interf func and
     //## name of interf librabry derived from name of superblock
     l_blknam=length(blknam)
     l_blknam=(l_blknam>17)*17 + (l_blknam<=17)*l_blknam
     blknamint='int'+part(blknam,1:l_blknam)
     Makename=rpat+'/'+'Makefile_'+blknamint;

     //@@ generation of Makefiles
     if ~MSDOS then //@@ not windows
       SCI_sav = SCI
       [n]=predef(0)
       SCI='E:\scicoslab_43_cross'

       //@@ win32
       txt=gen_make_win32(blknamint,filesint,'',libs,ldflags,cflags);
       Makename2 = strsubst(Makename,'/','\')+'.mak';
       ierr=execstr('mputl(txt,Makename2)','errcatch')
       if ierr<>0 then
         x_message(['Can''t write '+Makename2;lasterror()]);
         ok=%f;
         return;
       end

       //@@ lccwin32
       txt=gen_make_lccwin32(blknamint,filesint,'',libs,ldflags,cflags);
       Makename2 = strsubst(Makename,'/','\')+'.lcc';
       ierr=execstr('mputl(txt,Makename2)','errcatch')
       if ierr<>0 then
         x_message(['Can''t write '+Makename2;lasterror()]);
         ok=%f;
         return;
       end

       SCI=SCI_sav
       clear SCI_sav
       predef(n(1))
     else //@@ windows
       if with_lcc()==%T then
         //@@ win32
         txt=gen_make_win32(blknamint,filesint,'',libs,ldflags,cflags);
         Makename2 = strsubst(Makename,'/','\')+'.mak';
         ierr=execstr('mputl(txt,Makename2)','errcatch')
         if ierr<>0 then
           x_message(['Can''t write '+Makename2;lasterror()]);
           ok=%f;
           return;
         end
       else
         //@@ lccwin32
         txt=gen_make_lccwin32(blknamint,filesint,'',libs,ldflags,cflags);
         Makename2 = strsubst(Makename,'/','\')+'.lcc';
         ierr=execstr('mputl(txt,Makename2)','errcatch')
         if ierr<>0 then
           x_message(['Can''t write '+Makename2;lasterror()]);
           ok=%f;
           return;
         end
       end

       SCI_sav = SCI
       [n]=predef(0)
       SCI = '/usr/lib/scicoslab_gtk-4.3'

       //@@ unix
       txt=gen_make_unix(blknamint,filesint,'',libs,ldflags,cflags);
       Makename2 = strsubst(Makename,'/','\');
       ierr=execstr('mputl(txt,Makename2)','errcatch')
       if ierr<>0 then
         x_message(['Can''t write '+Makename2;lasterror()]);
         ok=%f;
         return;
       end

       SCI = SCI_sav
       clear SCI_sav
       predef(n(1))
     end

     //## generate txt of makefile of the Makefile
     [Makename2,txt]=gen_make(blknamint,filesint,'',libs,Makename,ldflags,cflags);

     //## write text of the Makefile in the file called Makename
     ierr=execstr('mputl(txt,Makename2)','errcatch')
     if ierr<>0 then
       x_message(['Can''t write '+Makename2;lasterror()])
       ok=%f
       return
     end

     //@@ compile and link if needed
     if ~silent then

       //## unlink if necessary
       //## with addinter, this is the interfacing function of table
       //## that is used as reference
       [a,b]=c_link(blknamint+'_sci');
       while a
         ulink(b);
         [a,b]=c_link(blknamint+'_sci');
       end

       //## compile Makefile
       ierr=execstr('libn=ilib_compile(''lib''+blknamint,Makename)','errcatch')
       if ierr<>0 then
         ok=%f;
         chdir(oldpath);
         x_message(['sorry compiling problem';lasterror()]);
         return;
       end

       //##add ScicosLab interfacing function
       txt='addinter(libn,blknamint+''_sci'',blknam);'
       ierr=execstr(txt,'errcatch')
       if ierr<>0 then
         ok=%f;
         x_message(['sorry link problem';lasterror()]);
         return;
       end

     end

  end

endfunction

function [txt]=convpathforwin(path)
//Copyright (c) 1989-2010 Metalau project INRIA

//** convpathforwin : convert path that only include
//                    a single '\' in a '\\'
//
// Input : path : the path name to be converted
//                a single string.
//
// Output : txt : the path converted
//                a single string.
//

  //@@ define initial output
  txt=''

  //@@ parse path
  for j=1:length(path)

    if part(path,j)=='\' then
      //@@ begin of string path
      if j==1 then
        if part(path,j+1)<>'\' then
          txt=txt+'\';
        end

      //@@ end of string path
      elseif j==length(path) then
        if part(path,j-1)<>'\' then
          txt=txt+'\';
        end

      //@@ somewhere in string path
      else
        if part(path,j-1)<>'\' & part(path,j+1)<>'\' then
          txt=txt+'\';
        end
      end
    end

    txt=txt+part(path,j);
  end

endfunction

function [ok]=exportlibforlcc(libs,rpat)
//Copyright (c) 1989-2010 Metalau project INRIA

//** exportlibforlcc : export a lcc.lib file from
//                     an existing dll
//
// Input : libs  : a single string containing path+name
//                 of the (dll) library
//                 for export a lcc.lib file
//
//         rpat  : a target directory for temporary generated files
//
// Output : ok : a boolean variable to say if job has succed
//
// Rmk : the lcc.lib file is generated close to the dll file,
//       in the same directory (<> rpat if it is not informed)
//

  //** get lhs,rhs nb paramaters
  [lhs,rhs]=argn(0);

  //** extract path, name and extension of libs
  [path,fname,extension]=fileparts(libs);

  //** convert path of libs if needed
  Elibs=convpathforwin(libs)

  //** check rhs paramaters
  if rhs <= 1 then
    rpat = path
    [Erpat,fname,extension]=fileparts(Elibs);
  else
    //** convert path of rpat if needed
    Erpat=convpathforwin(rpat)
  end

  //** run pedumd to extract info from dll file
  //** .lcc file is generated in rpat directory
  ierr=execstr('unix(''pedump /exp """"''+..
               Elibs+''.dll"""" >""""''+..
               Erpat+''\''+fname+''.lcc""""'')','errcatch');

  if ierr<>0 then
    ok=%f
    //add a message here please
    return
  end

  //** generate an .exp file for buildlib of lcc
  //** .exp file is generated in rpat directory
  fw=mopen(rpat+'\'+fname+'.exp',"w");
  fr=mopen(rpat+'\'+fname+'.lcc',"r");
  if (meof(fr) == 0) then
    line=mfscanf(1,fr,"%s");
    mfprintf(fw,"%s\n",line);
   //printf('.');
  end
  while ( meof(fr) == 0)
    line=mfscanf(1,fr,"%s");
    if (line ~= []) then
      mfprintf(fw,"_%s\n",line);
    end
  end
  mclose(fw);
  mclose(fr);

  //** run buildlib and then generate lcc.lib file
  //** .exp is read from rpat
  //** lcc.lib is generated in path (of the dll file)
  command='buildLib ""'+Erpat+'\'+fname+'.exp""'+...
          ' ""'+Elibs+'lcc.lib""'+' ""'+Elibs+'.dll""';
  ierr=execstr('unix(command)','errcatch')
  if ierr<>0 then
    ok=%f
    //add a message here please
    return
  end

endfunction

function [SCode]=gen_loader(blknam,for_link,with_int)
//Copyright (c) 1989-2010 Metalau project INRIA

//** gen_loader : generates the ScicosLab script to load the
//                newly created block into ScicosLab.
//
// Input : blknam   : the name of the block to compile
//         for_link : other external libraries to link with blknam
//         with_int : a flag to load an ScicosLab interfacing function
//                    of a standalone scicos simulator
//
// Output : SCode : the text of the loader file
//

  //** check rhs paramaters
  [lhs,rhs]=argn(0);

  if rhs <= 1 then for_link=[], end
  if rhs <= 2 then with_int=%f, end

  SCode=['// Script file used to load the ""compiled""'
         '// scicos block into ScicosLab'
         ''
         '//Copyright (c) 1989-2010 Metalau project INRIA'
         ''
         '//@@ Define the name of the block'
         'blknam='+sci2exp(blknam)+';';
         ''
         '//** Get the absolute path of this loader file'
         'DIR=get_absolute_file_path(blknam+''_loader.sce'');'
         ''
         '//** Define Makefile name'
         'Makename=DIR+''Makefile_''+blknam;'
         ''
         '//** Unlink if necessary'
         '[a,b]=c_link(blknam);'
         'while a'
         '  ulink(b);'
         '  [a,b]=c_link(blknam);'
         'end';
         ''
         '//** Run Makefile'
         'libn=ilib_compile('+sci2exp('lib'+blknam)+',Makename);'
         ''
         '//** Adjust path name of object files'
         'if MSDOS then'
         '  fileso=strsubst(libn,''/'',''\'');'
         'else'
         '  fileso=strsubst(libn,''\'',''/'');'
         'end';
         ''
         '//@@ Inform %scicos_libs with library'
         'if exists(''%scicos_libs'') then'
         '  if find(fileso==%scicos_libs)==[] then'
         '    %scicos_libs=[%scicos_libs,fileso];'
         '  end'
         'else'
         '  %scicos_libs=[fileso];'
         'end'
         '']

  if for_link<>[] then
    SCode=[SCode
           '//** Link otherlibs'
           for_link
           '']
  end

  SCode=[SCode
         '//** Link block routine in ScicosLab'
         'link(fileso,blknam,''c'');'
         ''
         '//** Load the gui function';
         'if fileinfo(DIR+blknam+''_c.sci'')<>[] then'
         '  getf(DIR+blknam+''_c.sci'');'
         'end'
         '']

  //@@ ScicosLab interfacing function
  if with_int then

    //## define name of interf lib
    l_blknam=length(blknam);
    l_blknam=(l_blknam>17)*17 + (l_blknam<=17)*l_blknam;
    blknamint='int'+part(blknam,1:l_blknam);

    SCode=[SCode
           '//## Define name of interf lib"
           'l_blknam=length(blknam);'
           'l_blknam=(l_blknam>17)*17 + (l_blknam<=17)*l_blknam;'
           'blknamint=''int''+part(blknam,1:l_blknam);'
           'Makename=DIR+''Makefile_''+blknamint;'
           ''
           '//** Unlink if necessary'
           '[a,b]=c_link(blknamint+''_sci'');'
           'while a'
           '  ulink(b);'
           '  [a,b]=c_link(blknam+''_sci'');'
           'end';
           ''
           '//** Run Makefile'
           'libn=ilib_compile('+sci2exp('lib'+blknamint)+',Makename);'
           ''
           '//** Adjust path name of object files'
           'if MSDOS then'
           '  fileso=strsubst(libn,''/'',''\'');'
           'else'
           '  fileso=strsubst(libn,''\'',''/'');'
           'end';
           ''
           '//## Link and add ScicosLab function of the standalone.'
           'addinter(fileso,blknamint+''_sci'',blknam);'
           '']

  end

  SCode=[SCode;
         '//@@ Clear the used variabe'
         'clear blknam'
         'clear l_blknam'
         'clear blknamint'
         'clear Makename'
         'clear DIR'
         'clear fileso'
         'clear libn'
         'clear a'
         'clear b'
         '']

endfunction

function [T]=gen_make_lccwin32(blknam,files,filestan,libs,ldflags,cflags)
//Copyright (c) 1989-2010 Metalau project INRIA

//** gen_make_lccwin32 : generate text of the Makefile
//              for scicos code generator for
//              lccwin32 compiler
//
// Input : blknam   : name of the library
//         files    : files to be compiled
//         filestan : files to be compiled and included in
//                    the standalone code
//         libs     :  a vector of object files
//                    to include in the building process
//         ldflags  : linker flags
//         cflags   : C compiler flags
//
// Output : T : the text of the makefile
//

  WSCI=strsubst(SCI,'/','\')

  T=["#generated by buildnewblock: Please do not edit this file"
     "#"
     "#Copyright (c) 1989-2010 Metalau project INRIA"
     "#"
     "# ------------------------------------------------------"
     "SCIDIR       = "+SCI
     "SCIDIR1      = "+WSCI
     "DUMPEXTS     = ""$(SCIDIR1)\bin\dumpexts"""
     "SCIIMPLIB    = ""$(SCIDIR1)\bin\LibScilablcc.lib"""
     "SCILIBS      = ""$(SCIDIR1)\bin\LibScilablcc.lib"""
     "LIBRARY      = lib"+blknam
     "CC           = lcc"
     "LINKER       = lcclnk"
     "OTHERLIBS    = "+libs
     "LINKER_FLAGS = -dll -nounderscores"
     "INCLUDES     = -I""$(SCIDIR1)\routines\f2c""" 
     "CC_COMMON    = -DWIN32 -DSTRICT -DFORDLL -D__STDC__ $(INCLUDES)"
     "CC_OPTIONS   = $(CC_COMMON)"
     "CFLAGS       = $(CC_OPTIONS) -I""$(SCIDIR1)\routines"" "+cflags
     "FFLAGS       = $(FC_OPTIONS) -I""$(SCIDIR1)\routines"""
     ""
     "OBJS         = "+strcat(files+'.obj',' ')]

  if filestan<>'' then
    T=[T;
       "OBJSSTAN     = "+strcat(filestan+'.obj',' ')]
  end

  T=[T;
     ""
     "all :: $(LIBRARY).dll"
     ""
     "$(LIBRARY).dll: $(OBJS)"
     ascii(9)+"@echo Creation of dll $(LIBRARY).dll and import lib from ..."
     ascii(9)+"@echo $(OBJS)"
     ascii(9)+"@$(DUMPEXTS) -o ""$(LIBRARY).def"" ""$*"" $(OBJS)"
     ascii(9)+"@$(LINKER) $(LINKER_FLAGS) $(OBJS) $(SCIIMPLIB) $(OTHERLIBS) "+...
              " $(XLIBSBIN) $(TERMCAPLIB) $*.def -o "+...
              " $(LIBRARY).dll"
     ".c.obj:"
     ascii(9)+"@echo ------------- Compile file $< --------------"
     ascii(9)+"$(CC) $(CFLAGS) $<"
     ".f.obj:"
     ascii(9)+"@echo ----------- Compile file $*.f (using f2c) -------------"
     ascii(9)+"@""$(SCIDIR1)\bin\f2c.exe"" $(FFLAGS) $*.f "
     ascii(9)+"@$(CC) $(CFLAGS) $*.c"
     ascii(9)+"@del $*.c"
     "clean::"
     ascii(9)+"@del *.CKP"
     ascii(9)+"@del *.ln"
     ascii(9)+"@del *.BAK"
     ascii(9)+"@del *.bak"
     ascii(9)+"@del *.def"
     ascii(9)+"@del *.dll"
     ascii(9)+"@del *.exp"
     ascii(9)+"@del *.lib"
     ascii(9)+"@del errs"
     ascii(9)+"@del *~"
     ascii(9)+"@del *.obj"
     ascii(9)+"@del .emacs_*"
     ascii(9)+"@del tags"
     ascii(9)+"@del TAGS"
     ascii(9)+"@del make.log"
     ""
     "distclean:: clean"
     ""]

  if filestan<>'' then
    T=[T;
       "standalone: $(OBJSSTAN) "
        ascii(9)+"$(LINKER) $(LINKER_FLAGS) $(OBJSSTAN)"+...
                 "$(OTHERLIBS) $(SCILIBS)  /out:standalone.exe"]
  end
endfunction


function [Makename,txt]=gen_make(blknam,files,filestan,libs,Makename,ldflags,cflags)
//Copyright (c) 1989-2010 Metalau project INRIA

//** gen_make : generate text of the Makefile
//              for scicos code generator
//              That's a wrapper for
//                 gen_make_lccwin32
//                 gen_make_win32
//                 gen_make_unix
//
// Input : blknam   : name of the Scicos block to compile
//         files    : files to be compiled
//         filestan : files to be compiled and included in
//                    the standalone code
//         libs     :  a vector of object files
//                    to include in the building process
//         Makename : the name of Makefile file
//         ldflags  : linker flags
//         cflags   : C compiler flags
//
// Output : Makename : the name of Makefile file (modified
//                     for the case of win32)
//
//          txt      : the text of the Makefile
//

  //** check rhs paramaters
  [lhs,rhs]=argn(0);

  if rhs <= 1 then files    = blknam, end
  if rhs <= 2 then filestan = '', end
  if rhs <= 3 then libs     = '', end
  if rhs <= 4 then Makename = 'Makefile_'+blknam, end
  if rhs <= 5 then ldflags  = '', end
  if rhs <= 6 then cflags   = '', end

  //** generate Makefile for LCC compilator
  if with_lcc()==%T then

    txt=gen_make_lccwin32(blknam,files,filestan,libs,ldflags,cflags)
    Makename = strsubst(Makename,'/','\')+'.lcc'

  //** generate Makefile for Crosoft compilator
  elseif getenv('WIN32','NO')=='OK' then

    txt=gen_make_win32(blknam,files,filestan,libs,ldflags,cflags)
    select COMPILER;
      case 'VC++' then
        Makename = strsubst(Makename,'/','\')+'.mak'
    end

  //** unix case
  else

    txt=gen_make_unix(blknam,files,filestan,libs,ldflags,cflags)

  end

endfunction

function [T]=gen_make_unix(blknam,files,filestan,libs,ldflags,cflags)
//Copyright (c) 1989-2010 Metalau project INRIA

//** gen_make_unix : generate text of the Makefile
//              for scicos code generator for cc/gcc
//              unix compiler
//
// Input : blknam   : name of the library
//         files    : files to be compiled
//         filestan : files to be compiled and included in
//                    the standalone code
//         libs     : a vector of object files
//                    to include in the building process
//         ldflags  : linker flags
//         cflags   : C compiler flags
//
// Output : T : the text of the makefile
//

  T=["#generated by buildnewblock: Please do not edit this file"
     "#"
     "#Copyright (c) 1989-2010 Metalau project INRIA"
     "#"
     "# ------------------------------------------------------"
     "SCIDIR       = "+SCI
     "SCILIBS      = $(SCIDIR)/libs/scicos.a "+..
       "$(SCIDIR)/libs/poly.a $(SCIDIR)/libs/calelm.a "+..
       "$(SCIDIR)/libs/blas.a $(SCIDIR)/libs/lapack.a $(SCIDIR)/libs/os_specific.a "+..
       "$(SCIDIR)/libs/signal.a"
     "LIBRARY      = lib"+blknam
     "OTHERLIBS    = "+libs
     ""
     "OBJS         = "+strcat(files+'.o',' ')]

  if filestan<>'' then
    T=[T;
       "OBJSSTAN     = "+strcat(filestan+'.o',' ')]
  end

  T=[T;
     "include $(SCIDIR)/Makefile.incl";
     "CFLAGS    = $(CC_OPTIONS) -I$(SCIDIR)/routines/ "+cflags
     "FFLAGS    = $(FC_OPTIONS) -I$(SCIDIR)/routines/"
     "include $(SCIDIR)/config/Makeso.incl"]

  if filestan<>'' then
    T=[T;
       "standalone: $(OBJSSTAN) "
       "#"+ascii(9)+"f77 $(FFLAGS) -o $@  $(OBJSSTAN) $(OTHERLIBS) $(SCILIBS)"
       ascii(9)+"gcc $(CFLAGS) -lm -lgfortran -o $@  $(OBJSSTAN) $(OTHERLIBS) $(SCILIBS)"]
  end

endfunction

function [T]=gen_make_win32(blknam,files,filestan,libs,ldflags,cflags)
//Copyright (c) 1989-2010 Metalau project INRIA

//** gen_make_win32 : generate text of the Makefile
//              for scicos code generator for
//              Mswin32 compilers
//
// Input : blknam   : name of the library
//         files    : files to be compiled
//         filestan : files to be compiled and included in
//                    the standalone code
//         libs     :  a vector of object files
//                    to include in the building process
//         ldflags  : linker flags
//         cflags   : C compiler flags
//
// Output : T : the text of the makefile
//

  WSCI=strsubst(SCI,'/','\')

  T=["#generated by buildnewblock: Please do not edit this file"
     "#"
     "#Copyright (c) 1989-2010 Metalau project INRIA"
     "#"
     "# ------------------------------------------------------"
     "SCIDIR       = "+SCI
     "SCIDIR1      = "+WSCI
     "DUMPEXTS     = ""$(SCIDIR1)\bin\dumpexts"""
     "SCIIMPLIB    = ""$(SCIDIR1)\bin\LibScilab.lib"""
     "SCILIBS      = ""$(SCIDIR1)\bin\LibScilab.lib"""
     "LIBRARY      = lib"+blknam
     "CC           = cl"
     "LINKER       = link"
     "OTHERLIBS    = "+libs
     "LINKER_FLAGS = /NOLOGO /machine:ix86"
     "INCLUDES     = -I""$(SCIDIR1)\routines\f2c"""
     "CC_COMMON    = -D__MSC__ -DWIN32 -c -DSTRICT -nologo $(INCLUDES)"
     "CC_OPTIONS   = $(CC_COMMON) -Od -Gd -W3"
     "CFLAGS       = $(CC_OPTIONS) -DFORDLL -I""$(SCIDIR1)\routines"" "+cflags
     "FFLAGS       = $(FC_OPTIONS) -DFORDLL -I""$(SCIDIR1)\routines"""
     ""
     "OBJS         = "+strcat(files+'.obj',' ')]

  if filestan<>'' then
    T=[T;
       "OBJSSTAN     = "+strcat(filestan+'.obj',' ')]
  end

  T=[T;
     ""
     "all :: $(LIBRARY).dll"
     ""
     "$(LIBRARY).dll: $(OBJS)"
     ascii(9)+"@echo Creation of dll $(LIBRARY).dll and import lib from ..."
     ascii(9)+"@echo $(OBJS)"
     ascii(9)+"@$(DUMPEXTS) -o ""$*.def"" ""$*.dll"" $**"
     ascii(9)+"@$(LINKER) $(LINKER_FLAGS) $(OBJS) $(SCIIMPLIB) $(OTHERLIBS) "+...
              "$(XLIBSBIN) $(TERMCAPLIB) /nologo /dll /out:""$*.dll"""+...
              " /implib:""$*.lib"" /def:""$*.def"""
     ".c.obj:"
     ascii(9)+"@echo ------------- Compile file $< --------------"
     ascii(9)+"$(CC) $(CFLAGS) $<"
     ".f.obj:"
     ascii(9)+"@echo ----------- Compile file $*.f (using f2c) -------------"
     ascii(9)+"@""$(SCIDIR1)\bin\f2c.exe"" $(FFLAGS) $*.f"
     ascii(9)+"@$(CC) $(CFLAGS) $*.c"
     ascii(9)+"@del $*.c"
     "clean::"
     ascii(9)+"@del *.CKP"
     ascii(9)+"@del *.ln"
     ascii(9)+"@del *.BAK"
     ascii(9)+"@del *.bak"
     ascii(9)+"@del *.def"
     ascii(9)+"@del *.dll"
     ascii(9)+"@del *.exp"
     ascii(9)+"@del *.lib"
     ascii(9)+"@del errs"
     ascii(9)+"@del *~"
     ascii(9)+"@del *.obj"
     ascii(9)+"@del .emacs_*"
     ascii(9)+"@del tags"
     ascii(9)+"@del TAGS"
     ascii(9)+"@del make.log"
     ""
     "distclean:: clean"
     ""]

  if filestan<>'' then
    T=[T;
       "standalone: $(OBJSSTAN) "
        ascii(9)+"$(LINKER) $(LINKER_FLAGS)  $(OBJSSTAN)"+...
                 " $(OTHERLIBS) $(SCILIBS)  /out:standalone.exe"]
  end

endfunction


function [ok,libs,for_link]=link_olibs(libs,rpat)
//Copyright (c) 1989-2010 Metalau project INRIA

//** link_olibs   : links otherlibs in ScicosLab
//                  for scicos C generated block
//
// Input : libs   : a matrix of string containing path+name
//                 of the libraries
//
//         rpat   : a target directory for temporary generated files
//
// Output : ok    : a boolean variable to say if job has succed
//          libs  : a matrix of string containing path+name
//                  of the libraries
//          for_link : a vector of strings with link cmd
//                     for exec or for loader.sce
//

  //** get lhs,rhs nb paramaters
  [lhs,rhs]=argn(0);

  //** decl and set local variables
  ok=%t
  x=''
  xlibs=[]
  for_link=[]

  //** get out from this function if
  //   there is nothing to do
  if libs=='' | libs==[] then return, end

  //** LCC
  if with_lcc()==%T then
    //** add lcc.lib
    //   for compatibility with dll of
    //   msvc
    libs=libs(:)';
    for x=libs
      //** extract path, name and extension of libs
      [path,fname,extension]=fileparts(x);
      if rhs <= 1 then
        rpat = path
      end
      if (extension == '') then
        //** search dll
        if fileinfo(x+'.dll')<>[] then
          if fileinfo(x+'lcc.lib')==[] then
            //** export lcc.lib
            x_message(['I will try to export a '+x+'lcc.lib']);
            ok=exportlibforlcc(x,rpat)
            if ~ok then
              x_message(['Can''t export a '+path+fname+'lcc.lib';
                         'Please try to do your own lcc.lib file with';
                         'the xx scilab function or change the path';
                         'of your library '+x+'.dll']);
              ok=%f;
              return
            end
          end
          for_link=[for_link;x+'.dll']
          link(for_link($));
          xlibs=[xlibs;x+'lcc.lib']

        //** search DLL
        elseif fileinfo(x+'.DLL')<>[] then
          if fileinfo(x+'lcc.lib')==[] then
            //** export lcc.lib
            x_message(['I will try to export a '+x+'lcc.lib']);
            ok=exportlibforlcc(x,rpat)
            if ~ok then
              x_message(['Can''t export a '+path+fname+'lcc.lib';
                         'Please try to do your own lcc.lib file with';
                         'the xx scilab function or change the path';
                         'of your library '+x+'.dll']);
              ok=%f;
              return
            end
          end
          for_link=[for_link;x+'.DLL']
          link(for_link($));
          xlibs=[xlibs;x+'lcc.lib']

        else
          //** no extension
          //   no .dll exists
          //   do something here please ?
          ok=%f
          //pause
          x_message(['I don''t know what to do !';
                     'Please report to scicos@inria.fr';])
        end
      elseif fileinfo(x)==[] then
        x_message(['Can''t include '+x;
                   'That file doesn''t exist';
                   lasterror()])
        ok=%f
        return
      //** extension assume that user know what he does
      else
        //** compiled object (.obj)
        //** compiled object doesn't need to be linked
        if extension=='.obj' | extension=='.OBJ'  then
          xlibs=[xlibs;x]
        //** library (.dll)
        elseif extension=='.dll' | extension=='.DLL' then
          for_link=[for_link;x]
          link(for_link($));
          if fileinfo(path+fname+'lcc.lib')==[] then
            //** export lcc.lib
            x_message(['I will try to export a '+path+fname+'lcc.lib']);
            ok=exportlibforlcc(path+fname,rpat)
            if ~ok then
              x_message(['Can''t export a '+path+fname+'lcc.lib';
                         'Please try to do your own lcc.lib file with';
                         'the xx scilab function or change the path';
                         'of your library '+x+'.dll']);
              ok=%f;
              return
            end
          end
          xlibs=[xlibs;path+fname+'lcc.lib']

        //** library (.lib)
        elseif extension=='.lib' | extension=='.ilib' then
          if fileinfo(path+fname+'.dll')<>[] then
            for_link=[for_link;path+fname+'.dll']
            link(for_link($));
          elseif fileinfo(path+fname+'.DLL')<>[] then
            for_link=[for_link;path+fname+'.DLL']
            link(for_link($));
          else
            //link(x);
            x_message(['I don''t know what to do !';
                      'Please report to scicos@inria.fr';])
            ok=%f
            //pause
          end
          xlibs=[xlibs;x]
        else
          //link(x);
          x_message(['I don''t know what to do !';
                     'Please report to scicos@inria.fr';])
          ok=%f
          //pause
        end
      end
    end

  //** MSVC
  elseif getenv('WIN32','NO')=='OK' then
    //** add .lib or .ilib
    libs=libs(:)';
    for x=libs
      [path,fname,extension]=fileparts(x);
      if (extension == '') then
        //** search ilib
        if fileinfo(x+'.ilib')<>[] then
          //** search dll
          if fileinfo(x+'.dll')<>[] then
            for_link=[for_link;x+'.dll']
            link(for_link($));
          //** search DLL
          elseif fileinfo(x+'.DLL')<>[] then
            for_link=[for_link;x+'.DLL']
            link(for_link($));
          //** no .dll, .DLL
          else
            x_message(['I cant''t find a dll !';
                       'Please report to scicos@inria.fr';])
            ok=%f
            //pause
          end
          xlibs=[xlibs;x+'.ilib']
        //** search lib
        elseif fileinfo(x+'.lib')<>[] then
          //** search dll
          if fileinfo(x+'.dll')<>[] then
            for_link=[for_link;x+'.dll']
            link(for_link($));
          //** search DLL
          elseif fileinfo(x+'.DLL')<>[] then
            for_link=[for_link;x+'.DLL']
            link(for_link($));
          //** no .dll, .DLL
          else
            x_message(['I cant''t find a dll !';
                       'Please report to scicos@inria.fr';])
            ok=%f
            //pause
          end
          xlibs=[xlibs;x+'.lib']
        else
          //** no extension
          //   no .lib, no .ilib exists
          //   do something here please ?
          x_message(['I don''t know what to do !';
                     'Please report to scicos@inria.fr';])
          ok=%f
          //pause
        end
      elseif fileinfo(x)==[] then
        x_message(['Can''t include '+x;
                   'That file doesn''t exist';
                   lasterror()])
        ok=%f
        return
      //** extension assume that user know what he does
      else
        //** compiled object (.obj)
        //** compiled object doesn't need to be linked
        if extension=='.obj' | extension=='.OBJ'  then
          xlibs=[xlibs;x]
        //** library (.dll)
        elseif extension=='.dll' | extension=='.DLL' then
          for_link=[for_link;x]
          link(for_link($));
          if fileinfo(path+fname+'.ilib')<> [] then
            xlibs=[xlibs;path+fname+'.ilib']
          elseif fileinfo(path+fname+'.lib')<> [] then
            xlibs=[xlibs;path+fname+'.lib']
          else
            //link(x);
            x_message(['I don''t know what to do !';
                      'Please report to scicos@inria.fr';])
            ok=%f
            //pause
          end
        //** library (.lib)
        elseif extension=='.lib' | extension=='.ilib' then
          if fileinfo(path+fname+'.dll')<>[] then
            for_link=[for_link;path+fname+'.dll']
            link(for_link($));
          elseif fileinfo(path+fname+'.DLL')<>[] then
            for_link=[for_link;path+fname+'.DLL']
            link(for_link($));
          else
            //link(x);
            x_message(['I don''t know what to do !';
                      'Please report to scicos@inria.fr';])
            ok=%f
            //pause
          end
          xlibs=[xlibs;x]
        else
          //link(x);
          x_message(['I don''t know what to do !';
                     'Please report to scicos@inria.fr';])
          ok=%f
          //pause
        end
      end
    end

  //** Unix
  else
    //** add .a
    //   for compatibility test if we have already a .a
    libs=libs(:)';
    for x=libs
      [path,fname,extension]=fileparts(x);
      //** no extension. Assume that's a so library
      if (extension == '') then
       if fileinfo(path+fname+'.so')<>[] then
        for_link=[for_link;x+'.so']
        link(for_link($));
       elseif fileinfo(path+fname+'.SO')<>[] then
        for_link=[for_link;x+'.SO']
        link(for_link($));
       else
         //link(x);
         x_message(['I don''t know what to do !';
                    'Please report to scicos@inria.fr';])
         ok=%f
         //pause
       end
       if fileinfo(x+'.a')<>[] then
         xlibs=[xlibs;x+'.a']
       elseif fileinfo(x+'.A')<>[] then
         xlibs=[xlibs;x+'.A']
       else
         //link(x);
         x_message(['I don''t know what to do !';
                    'Please report to scicos@inria.fr';])
         ok=%f
         //pause
       end
      elseif fileinfo(x)==[] then
        x_message(['Can''t include '+x;
                   'That file doesn''t exist';
                   lasterror()])
        ok=%f
        return
      //** extension assume that user know what he does
      else
        //** compiled object (.o)
        //** compiled object doesn't need to be linked
        if extension=='.o' | extension=='.O'  then
          xlibs=[xlibs;x]
        //** library (.so)
        elseif extension=='.so' | extension=='.SO' then
          for_link=[for_link;x]
          link(for_link($));
          if fileinfo(path+fname+'.a')<> [] then
            xlibs=[xlibs;path+fname+'.a']
          elseif fileinfo(path+fname+'.A')<> [] then
            xlibs=[xlibs;path+fname+'.A']
          else
            //link(x);
            x_message(['I don''t know what to do !';
                      'Please report to scicos@inria.fr';])
            ok=%f
            //pause
          end
        //** library (.a)
        elseif extension=='.a' | extension=='.A' then
          if fileinfo(path+fname+'.so')<>[] then
            for_link=[for_link;path+fname+'.so']
            link(for_link($));
          elseif fileinfo(path+fname+'.SO')<>[] then
            for_link=[for_link;path+fname+'.SO']
            link(for_link($));
          else
            //link(x);
            x_message(['I don''t know what to do !';
                      'Please report to scicos@inria.fr';])
            ok=%f
            //pause
          end
          xlibs=[xlibs;x]
        else
          //link(x);
          x_message(['I don''t know what to do !';
                    'Please report to scicos@inria.fr';])
          ok=%f
          //pause
        end
      end
    end
  end

  //** add double quote for include in
  //   Makefile
  libs=xlibs
  if MSDOS then
      libs='""'+libs+'""'
   else
     libs=''''+libs+''''
   end

  //** return link cmd for for_link
  if for_link <> [] then
    for_link = 'link(""'+for_link+'"");';
  end

  //** concatenate libs for Makefile
  if size(libs,1)<>1 then
    libs = strcat(libs,' ')
  end

endfunction
