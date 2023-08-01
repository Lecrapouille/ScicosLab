/* Allan CORNET 
 * INRIA 2005 
 */

#include "SciEnv.h"
#include "Messages.h"
#include "Warnings.h"
#include "Errors.h"

#include "../os_specific/win_mem_alloc.h" /* MALLOC */

static BOOL IsTheGoodShell(void);
static BOOL Set_Shell(void);


/*
 * Fixes a set of enviroenment variables 
 * 
 * SCI,TCL_LIBRARY,TK_LIBRARY are defined here 
 * scilex can therefor be used directly.
 */

void SciEnv(void)
{
  char SCIPathName[MAX_PATH];
  GetScilabDirectory(SCIPathName,TRUE);
  /* Correction Bug 1579 */
  if (!IsTheGoodShell()) 
    {
      if ( (!Set_Shell()) || (!IsTheGoodShell()))
	{
	  MessageBox(NULL,MSG_SCIMSG121,MSG_WARNING22,MB_ICONWARNING|MB_OK);
	}
    }
  set_sci_env(SCIPathName);
}

/*
 * set env variables (used when calling scilab from
 * other programs)
 */

void set_sci_env(char *DefaultSCIPATH)
{
  if (DefaultSCIPATH)
    {
      Set_SCI_PATH(DefaultSCIPATH);
      Set_HOME_PATH(DefaultSCIPATH);
#ifdef WITH_TK
      Set_TCL_LIBRARY_PATH(DefaultSCIPATH);
      Set_TK_LIBRARY_PATH(DefaultSCIPATH);
#endif
      Set_LCC_PATH(DefaultSCIPATH);
      Set_SOME_ENVIRONMENTS_VARIABLES_FOR_SCILAB();
    }
  else
    {
      /* Error */
      exit(1);
    }
}

/* get the path of LibScilab.dll module (MSG_SCIMSG9) and 
 * and obtains the SciPathName from the result.
 *
 */

int GetScilabDirectory(char *SciPathName,BOOL UnixStyle)
{
  char ScilabModuleName[MAX_PATH];
  char drive[_MAX_DRIVE];
  char dir[_MAX_DIR];
  char fname[_MAX_FNAME];
  char ext[_MAX_EXT];
  char *DirTmp=NULL;
  
  strcpy(SciPathName,"");
  
  if (!GetModuleFileName((HINSTANCE)GetModuleHandle(MSG_SCIMSG9),
			 ScilabModuleName,MAX_PATH))
    {
      return FALSE;
    }
  
   _splitpath(ScilabModuleName,drive,dir,fname,ext);
  
  if (dir[strlen(dir)-1] == '\\') dir[strlen(dir)-1] = '\0';

  DirTmp=strrchr (dir, '\\');
  if (strlen(dir)-strlen(DirTmp)>0)
    {
      dir[strlen(dir)-strlen(DirTmp)] = '\0';
    }
  else 
    {
      return FALSE;
    }

  _makepath(SciPathName,drive,dir,NULL,NULL);
    
  if ( UnixStyle )
    {	
      int i=0;
      for (i=0;i<(int)strlen(SciPathName);i++)
	{
	  if (SciPathName[i]=='\\') SciPathName[i]='/';
	}
    }
  SciPathName[strlen(SciPathName)-1]='\0';
  return TRUE;
}


BOOL ConvertPathWindowsToUnixFormat(const char *pathwindows,char *pathunix)
{
  BOOL bOK=TRUE;
  if ( (pathunix) && (pathwindows) )
    {
      int i=0;
      strcpy(pathunix,pathwindows);
      for (i=0;i<(int)strlen(pathunix);i++)
	{
	  if (pathunix[i]=='\\') pathunix[i]='/';
	}
    }
  else bOK=FALSE;

  return bOK;

}


BOOL ConvertPathUnixToWindowsFormat(const char *pathunix,char *pathwindows)
{
  BOOL bOK=TRUE;
  if ( (pathunix) && (pathwindows) )
    {
      int i=0;
      strcpy(pathwindows,pathunix);
      for (i=0;i<(int)strlen(pathwindows);i++)
	{
	  if (pathwindows[i]=='/') pathwindows[i]='\\';
	}
    }
  else bOK=FALSE;

  return bOK;

}

/* set env variables to pathes values.
 * set name=shortpathname(defaultpath)
 * set nameL=defaultpath.
 * if convert is true path are converted to unix style.
 */

static BOOL __set_env_path(const char *name,const char *Path,BOOL convert)
{
  const char *long_path=NULL;
  BOOL bOK=FALSE;
  char env[MAX_PATH+128];
  char envcross[MAX_PATH+128];
  char ShortPath[MAX_PATH];
  
  if ( GetShortPathName(Path,ShortPath,MAX_PATH)== 0)
    {
      fprintf(stderr,"%s%s%s.\n",MSG_ERROR19,MSG_ERROR81,Path);
      return FALSE;
    }

  if (convert)
    {
      char CopyOfPath[MAX_PATH];
      ConvertPathWindowsToUnixFormat(ShortPath,CopyOfPath);
      /* here the env variable is writen in Unix style: why ? */
      sprintf (env, "%s=%s",name,CopyOfPath);
    }
  else 
    {
      /* ShorPath is in Windows style */
      sprintf (env, "%s=%s",name,ShortPath);
    }

  if (_putenv (env))
      bOK=FALSE;
  else
      bOK=TRUE;
  
  if ( bOK == FALSE ) return bOK;

  long_path = Path;

  /* if you want to remove the leading drive letter
   * if ( strlen(long_path) >= 2 && long_path[1]== ':') long_path +=2;
   */
  sprintf (envcross, "%sL=%s",name,long_path);

  if (_putenv (envcross))
      bOK=FALSE;
  else
      bOK=TRUE;

  return bOK;
}


/* try to first use getenv ("SCI") then 
 * DefaultPath 
 */ 

BOOL Set_SCI_PATH(char *DefaultPath)
{
  BOOL bOK=FALSE;
  char *GetSCIpath= getenv ("SCI");

  if ( GetSCIpath != NULL ) 
    {
      /* GetSCIpath is used with conversion to unix style */
      bOK =  __set_env_path("SCI",GetSCIpath, TRUE);
    }
  
  if (bOK == FALSE ) 
    {
      /* DefaultPath is used without conversion */
      bOK =  __set_env_path("SCI",DefaultPath, FALSE);
    }
  
  return bOK;
}


BOOL Set_HOME_PATH(char *DefaultPath)
{
  BOOL bOK=FALSE;
  char *GetSCIpath= getenv ("HOME");

  if ( GetSCIpath != NULL ) 
    {
      /* GetSCIpath is used with conversion to unix style */
      bOK =  __set_env_path("HOME",GetSCIpath, TRUE);
    }
  
  if (bOK == FALSE ) 
    {
      /* DefaultPath is used without conversion */
      bOK =  __set_env_path("HOME",DefaultPath, FALSE);
    }
  
  return bOK;
}


BOOL Set_TCL_LIBRARY_PATH(char *DefaultPath)
{
  BOOL bOK=FALSE;
  int major=8;
  int minor=4; // Par defaut
  int patchLevel=0;
  int type=0;
  char env[MAX_PATH+128];
  char ShortPath[MAX_PATH];
  char CopyOfDefaultPath[MAX_PATH];
  	
#ifdef WITH_TK
  Tcl_GetVersion(&major, &minor, &patchLevel, &type);
#endif

  /* to be sure that it's windows format */
  /* c:\progra~1\scilab-3.1\tcl\tcl8.4 */
  if (GetShortPathName(DefaultPath,ShortPath,MAX_PATH)==0)
    {
      fprintf(stderr,"\n%s%s%s.\n",MSG_ERROR22,MSG_ERROR83,DefaultPath);
      ConvertPathUnixToWindowsFormat(ShortPath,CopyOfDefaultPath);
      wsprintf (env, "TCL_LIBRARY=%s\\tcl\\tcl%d.%d",CopyOfDefaultPath,major,minor);
    }
  else
    {
      ConvertPathUnixToWindowsFormat(ShortPath,CopyOfDefaultPath);
      wsprintf (env, "TCL_LIBRARY=%s\\tcl\\tcl%d.%d",CopyOfDefaultPath,major,minor);
    }

  if (_putenv (env))
    {
      bOK=FALSE;
    }
  else
    {
      bOK=TRUE;
    }

  return bOK;
}

BOOL Set_TK_LIBRARY_PATH(char *DefaultPath)
{
  BOOL bOK=FALSE;
  char env[MAX_PATH+ 128];
  char ShortPath[MAX_PATH];
  char CopyOfDefaultPath[MAX_PATH];
  int major=8, minor=4, patchLevel=0, type=0;

#ifdef WITH_TK
  Tcl_GetVersion(&major, &minor, &patchLevel, &type);
#endif

  /* to be sure that it's windows format */
  /* c:\progra~1\scilab-3.1\tcl\tk8.4 */
  if (GetShortPathName(DefaultPath,ShortPath,MAX_PATH)==0)
    {
      fprintf(stderr,"\n%s%s%s.\n",MSG_ERROR23,MSG_ERROR84,DefaultPath);
      ConvertPathUnixToWindowsFormat(ShortPath,CopyOfDefaultPath);
      wsprintf (env, "TK_LIBRARY=%s\\tcl\\tk%d.%d",CopyOfDefaultPath,major,minor);
    }
  else
    {
      ConvertPathUnixToWindowsFormat(ShortPath,CopyOfDefaultPath);
      wsprintf (env, "TK_LIBRARY=%s\\tcl\\tk%d.%d",CopyOfDefaultPath,major,minor);
    }

  if (_putenv (env))
    {
      bOK=FALSE;
    }
  else
    {
      bOK=TRUE;
    }

  return bOK;
}

BOOL Set_LCC_PATH(char *DefaultPath)
{
  BOOL bOK=FALSE;
  char *PathTemp=NULL;
  
  PathTemp=getenv ("PATH");
  if (PathTemp)
    {
      char *NewPath=NULL;
      char *PathWsci= getenv ("SCI");

      if ( PathWsci == NULL )
	{
	  MessageBox(NULL,MSG_ERROR76,MSG_ERROR20,MB_ICONWARNING);
	  exit(1);
	}
      else
	{
	  char LCCFILE[MAX_PATH];
	  wsprintf(LCCFILE,"%s%s",PathWsci,LCCEXE);
	  if ( IsAFile(LCCFILE) )
	    {
	      NewPath= (char*)MALLOC( (strlen("PATH=;;;;")+strlen(PathTemp)+3*(MAX_PATH)+1)*sizeof(char));
	      wsprintf(NewPath,"PATH=%s;%s%s;%s%s;%s%s;",PathTemp,
		       PathWsci,LCCBIN,
		       PathWsci,LCCINCLUDE,
		       PathWsci,LCCLIB);
	      bOK =  (_putenv (NewPath)) ? FALSE : TRUE;
	      if (NewPath){ FREE(NewPath); NewPath=NULL; }
	    }
	}

    }
  else
    {
      MessageBox(NULL,MSG_ERROR24,MSG_ERROR20,MB_ICONWARNING);
      exit(1);
    }

  return bOK;
}

BOOL Set_SOME_ENVIRONMENTS_VARIABLES_FOR_SCILAB(void)
{
  BOOL bOK=TRUE;

#ifdef __MSC__
  putenv ("COMPILER=VC++");
#else
#ifdef __MINGW32__ 
  /* here we will use VC++ */
  putenv ("COMPILER=VC++");
#else 
#ifdef __CYGWIN32__
  /* Thus scilex will use unix scripts to run gcc */
  putenv ("COMPILER=gcc");
#else 
  putenv ("COMPILER=Unknow");
#endif 
#endif
#endif
	
  /* WIN32 variable Environment */
#ifdef _WIN32
  putenv ("WIN32=OK");
#endif
  
  /* WIN64 variable Environment */
#ifdef _WIN64
  putenv ("WIN64=OK");
#endif
  
  return bOK;
}

static BOOL IsTheGoodShell(void)
{
  BOOL bOK=FALSE;
  char shellCmd[MAX_PATH];
  char drive[_MAX_DRIVE];
  char dir[_MAX_DIR];
  char fname[_MAX_FNAME];
  char ext[_MAX_EXT];
  int OS=-1;

  strcpy(shellCmd,"");
  strcpy(fname,"");
  GetEnvironmentVariable("ComSpec", shellCmd, MAX_PATH);
  _splitpath(shellCmd,drive,dir,fname,ext);

  OS=GetOSVersion();

  if ( (OS==OS_WIN32_WINDOWS_95) || (OS==OS_WIN32_WINDOWS_98) || (OS==OS_WIN32_WINDOWS_Me) )
    {
      if (_stricmp(fname,"command")==0) bOK=TRUE;
    }
  else
    {
      if (_stricmp(fname,"cmd")==0) bOK=TRUE;
    }
  return bOK;
}

static BOOL Set_Shell(void)
{
  BOOL bOK=FALSE;
  char env[MAX_PATH+128];
  char *WINDIRPATH=NULL;
  int OS=-1;

  OS=GetOSVersion();

  if ( (OS==OS_WIN32_WINDOWS_95) || (OS==OS_WIN32_WINDOWS_98) || (OS==OS_WIN32_WINDOWS_Me) )
    {
      WINDIRPATH=getenv ("windir");
      sprintf(env,"ComSpec=%s\\command.com",WINDIRPATH);
    }
  else
    {
      WINDIRPATH=getenv ("SystemRoot");
      sprintf(env,"ComSpec=%s\\system32\\cmd.exe",WINDIRPATH);
    }

  if (_putenv (env))
    {
      bOK=FALSE;		
    }
  else
    {
      bOK=TRUE;
    }
  return bOK;
}


