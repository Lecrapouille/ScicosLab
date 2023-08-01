/*
 * Interface with system function 
 * Copyright (Allan CORNET) INRIA 2005 
 */

#include<stdio.h>
#include <stdlib.h>

#ifdef WIN32
#include <windows.h>
#include "../wsci/GetOS.h"
#include "../os_specific/win_mem_alloc.h" /* MALLOC */
#else
#include "../os_specific/sci_mem_alloc.h" /* MALLOC */
#endif
#include "../machine.h"

#if WIN32
extern BOOL IsAFile(char *chainefichier);
static BOOL CallWindowsShell(char *command,BOOL WaitInput, int *ret);
#endif


int C2F(systemc)(char *command, integer *stat)
{
#if WIN32
  {
    int OS=GetOSVersion();
    if ( (OS==OS_WIN32_WINDOWS_NT_3_51) ||
	 (OS==OS_WIN32_WINDOWS_NT_4_0) ||
	 (OS==OS_WIN32_WINDOWS_95) ||
	 (OS==OS_WIN32_WINDOWS_98) ||
	 (OS==OS_WIN32_WINDOWS_Me) )
      {
	*stat =(integer)system(command);
      }
    else
      {	
	int ret;
	BOOL Status=FALSE;
	Status=CallWindowsShell(command,FALSE,&ret);
	if (Status == TRUE ) 
	  {
	    *stat = (ret == 0 ) ? 0 : 1 ;
	  }
	else 
	  {
	    /* here we should write an error */
	    /* error ("system: CreateProcess failed -- can't create child process"); */
	    *stat = -1 ; 
	  }
      }
  }
#else
  {
    int status;
    status=system(command);
    *stat=(integer)status;
  }
#endif
  return(0);
}


#if WIN32
static BOOL CallWindowsShell(char *command,BOOL WaitInput, int *ret)
{
  BOOL bReturn=FALSE;
  char shellCmd[_MAX_PATH];
  char *CmdLine=NULL;
  PROCESS_INFORMATION piProcInfo; 
  STARTUPINFO siStartInfo;
  SECURITY_ATTRIBUTES saAttr; 
  DWORD ExitCode=0;
  char *TMPDir=NULL;

  saAttr.nLength = sizeof(SECURITY_ATTRIBUTES); 
  saAttr.bInheritHandle = TRUE; 
  saAttr.lpSecurityDescriptor = NULL; 

  ZeroMemory( &piProcInfo, sizeof(PROCESS_INFORMATION) );
  ZeroMemory( &siStartInfo, sizeof(STARTUPINFO) );

  siStartInfo.cb = sizeof(STARTUPINFO); 
  siStartInfo.dwFlags      = STARTF_USESHOWWINDOW | STARTF_USESTDHANDLES;
  siStartInfo.wShowWindow  = SW_HIDE;
	
  if (WaitInput)
    {
      siStartInfo.hStdInput=GetStdHandle(STD_INPUT_HANDLE);
    }
  else
    {
      siStartInfo.hStdInput=NULL;
    }

  siStartInfo.hStdOutput = GetStdHandle(STD_OUTPUT_HANDLE);
  siStartInfo.hStdError = GetStdHandle(STD_ERROR_HANDLE);

  GetEnvironmentVariable("ComSpec", shellCmd, _MAX_PATH);
  TMPDir=getenv("TMPDIR");

  CmdLine=(char*)MALLOC( (strlen(shellCmd)+strlen(command)+strlen("%s /a /c %s")+1)*sizeof(char) );
  sprintf(CmdLine,"%s /a /c %s",shellCmd,command);

  if (CreateProcess(NULL, CmdLine, NULL, NULL, TRUE,0, NULL, NULL, &siStartInfo, &piProcInfo))
    {
      WaitForSingleObject(piProcInfo.hProcess,INFINITE);

      if ( GetExitCodeProcess(piProcInfo.hProcess,&ExitCode) == STILL_ACTIVE )
	{
	  TerminateProcess(piProcInfo.hProcess,0);
	}

      CloseHandle(piProcInfo.hProcess);

      if (CmdLine) {FREE(CmdLine);CmdLine=NULL;}

      bReturn = TRUE;
      *ret =  ExitCode;
    }
  else
    {
      CloseHandle(piProcInfo.hProcess);
      if (CmdLine) {FREE(CmdLine);CmdLine=NULL;}
      bReturn=FALSE;
    }
  return bReturn;
}
#endif

