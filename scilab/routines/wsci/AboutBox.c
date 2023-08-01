/*-----------------------------------------------------------------------------------*/
/* INRIA 2005 */
/* Allan CORNET */
/*-----------------------------------------------------------------------------------*/

#include "AboutBox.h"
#include "SciEnv.h"

/*-----------------------------------------------------------------------------------*/
extern LPTW GetTextWinScilab(void);
extern BOOL IsWindowInterface(void);
/*-----------------------------------------------------------------------------------*/

EXPORT void WINAPI AboutBox (HWND hwnd);
EXPORT BOOL CALLBACK AboutDlgProc (HWND hDlg, UINT wMsg, WPARAM wParam, LPARAM lParam);

static void ON_ABOUT_WM_DESTROY(HWND hwnd);
static BOOL ON_ABOUT_WM_INITDIALOG(HWND hDlg,HWND hwndFocus, LPARAM lParam);
static BOOL ON_ABOUT_WM_COMMAND(HWND hwnd, int id, HWND hwndCtl, UINT codeNotify);
/*-----------------------------------------------------------------------------------*/

EXPORT BOOL CALLBACK AboutDlgProc (HWND hDlg, UINT wMsg, WPARAM wParam, LPARAM lParam)
{
  switch (wMsg)
    {
    case WM_INITDIALOG:
      return HANDLE_WM_INITDIALOG(hDlg,wParam,lParam,ON_ABOUT_WM_INITDIALOG);
      
    case WM_COMMAND:
      return HANDLE_WM_COMMAND(hDlg,wParam,lParam,ON_ABOUT_WM_COMMAND);	
      
    case WM_DESTROY:
      HANDLE_WM_DESTROY(hDlg,wParam,lParam,ON_ABOUT_WM_DESTROY);
      return TRUE;
      
    case WM_CLOSE:
      HANDLE_WM_DESTROY(hDlg,wParam,lParam,ON_ABOUT_WM_DESTROY);
      return TRUE;
    }
  return FALSE;
}
/*-----------------------------------------------------------------------------------*/

extern HINSTANCE hdllInstance;

EXPORT void WINAPI AboutBox (HWND hwnd)
{ 
  DLGPROC lpfnAboutDlgProc;
  lpfnAboutDlgProc = (DLGPROC) MyGetProcAddress("AboutDlgProc",AboutDlgProc);
  if (  lpfnAboutDlgProc == NULL ) 
    MessageBox(NULL,"AboutBox: function AboutDlgProc not found in LibScilab.dll !","Warning",MB_ICONERROR); 
  DialogBox (hdllInstance, (LPCSTR)ABOUTDLGBOX,hwnd,lpfnAboutDlgProc);
}
/*-----------------------------------------------------------------------------------*/
static void ON_ABOUT_WM_DESTROY(HWND hwnd)
{
  EndDialog (hwnd,0L);
}
/*-----------------------------------------------------------------------------------*/
static BOOL ON_ABOUT_WM_INITDIALOG(HWND hDlg,HWND hwndFocus, LPARAM lParam)
{
  char buffer[MAX_PATH];
  int cpubuild=_M_IX86;
  wsprintf(buffer,"%s %s",MSG_SCIMSG31,DEFAULT_MES);
  SetDlgItemText(hDlg,IDC_VERSION_SPLASH,SCILAB_VERSION);
  SetDlgItemText(hDlg,IDC_COPYRIGHT_SPLASH,buffer);
  wsprintf(buffer,"%s %s",__DATE__,__TIME__);
  SetDlgItemText(hDlg,IDC_BUILD,buffer);
#if __MAKEFILEVC__
  strcpy(buffer,MSG_SCIMSG58);
#else
#if _DEBUG
  strcpy(buffer,MSG_SCIMSG60);
  strcat(buffer,MSG_SCIMSG61);
#else
  strcpy(buffer,MSG_SCIMSG62);
  switch(cpubuild)
    {
    case 500: // Pentium
      strcat(buffer,MSG_SCIMSG63);
      break;
    case 600: // Pentium Pro
      strcat(buffer,MSG_SCIMSG64);
      break;
    case 400: // 486
      strcat(buffer,MSG_SCIMSG65);
      break;
    case 300: // 386
      strcat(buffer,MSG_SCIMSG66);
      break;
    }
#endif
#endif
  SetDlgItemText(hDlg,IDC_COMPILMODE,buffer);

  return TRUE;
}
/*-----------------------------------------------------------------------------------*/
static BOOL ON_ABOUT_WM_COMMAND(HWND hwnd, int id, HWND hwndCtl, UINT codeNotify)
{
  switch (id)
    {
    case IDC_LICENCE:
      {
#define LICENCEFR "Licence.txt"
#define LICENSEENG "License.txt"

	char ScilabDirectory[MAX_PATH];
	char Chemin[MAX_PATH];
	int Language=0;

	int error=0;
	LPTW lptw=GetTextWinScilab();

	GetScilabDirectory(ScilabDirectory,FALSE);

	if (IsWindowInterface())
	  {
	    Language=lptw->lpmw->CodeLanguage;
	  }
	else
	  {
	    Language=0; /* English */
	  }

	switch (Language)
	  {
	  case 1: /* French */
	    {
	      wsprintf(Chemin,"%s\\%s",ScilabDirectory,LICENCEFR);
	    }
	    break;

	  default: case 0: /*English */
	    {
	      wsprintf(Chemin,"%s\\%s",ScilabDirectory,LICENSEENG);
	    }
	    break;
	  }


	error =(int)ShellExecute(NULL, "open", Chemin, NULL, NULL, SW_SHOWNORMAL);
	if (error<= 32) 
	  {
	    switch (Language)
	      {
	      case 1: /* French */
		{
		  MessageBox(NULL,MSG_WARNING26,MSG_WARNING21 ,MB_ICONWARNING);
		}
		break;

	      default: case 0: /*English */
		{
		  MessageBox(NULL,MSG_WARNING27,MSG_WARNING22,MB_ICONWARNING);
		}
		break;
	      }
	  }
      }
      break;

    case IDOK:
      EndDialog (hwnd, id);
      break;

    }
  return TRUE;
}	
/*-----------------------------------------------------------------------------------*/
