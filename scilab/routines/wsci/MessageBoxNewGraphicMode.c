/*-----------------------------------------------------------------------------------*/
/* INRIA 2005 */
/* Allan CORNET */
/*-----------------------------------------------------------------------------------*/
#include "MessageBoxNewGraphicMode.h"
#include "SciEnv.h"
/*-----------------------------------------------------------------------------------*/
extern HINSTANCE hdllInstance;
extern LPTW GetTextWinScilab(void);

/*-----------------------------------------------------------------------------------*/
BOOL CALLBACK MessageBoxNewGraphicModeDlgProc(HWND hwnd,UINT Message, WPARAM wParam, LPARAM lParam);
BOOL ON_MESSAGEBOXNEWGRAPHICMODE_WM_INITDIALOG(HWND hDlg,HWND hwndFocus, LPARAM lParam);
BOOL ON_MESSAGEBOXNEWGRAPHICMODE_WM_COMMAND(HWND hwnd, int id, HWND hwndCtl, UINT codeNotify);
/*-----------------------------------------------------------------------------------*/
static int MessageBoxLanguageCode=0;
/*-----------------------------------------------------------------------------------*/
void MessageBoxNewGraphicMode(void)
{
  HKEY key;
  DWORD result,size=4;
  char Clef[MAX_PATH];
  int DontShowMessageNewGraphicMode,Ans;

  wsprintf(Clef,"SOFTWARE\\ScicosLab\\%s\\Settings",SCILAB_VERSION);
  result=RegOpenKeyEx(HKEY_CURRENT_USER, Clef, 0, KEY_QUERY_VALUE , &key);
  
  if ( RegQueryValueEx(key, "DontShowMessageNewGraphicMode", 0, NULL, (LPBYTE)&Ans, &size) !=  ERROR_SUCCESS )
    {
      DontShowMessageNewGraphicMode = 0;
    }
  else
    {
      DontShowMessageNewGraphicMode = Ans;
    }
  
  if ( result == ERROR_SUCCESS ) RegCloseKey(key);
  
  /* do not show this dialog */
  if (0 && DontShowMessageNewGraphicMode == 0)
    {
      DialogBox(hdllInstance, "IDD_MESSAGE_NEW_GRAPHIC", NULL,MessageBoxNewGraphicModeDlgProc);
    }
}

/*-----------------------------------------------------------------------------------*/
BOOL CALLBACK MessageBoxNewGraphicModeDlgProc(HWND hwnd,UINT Message, WPARAM wParam, LPARAM lParam)
{
  switch(Message)
    {
    case WM_INITDIALOG:
      return HANDLE_WM_INITDIALOG(hwnd,wParam,lParam,ON_MESSAGEBOXNEWGRAPHICMODE_WM_INITDIALOG);
      
    case WM_COMMAND:
      return HANDLE_WM_COMMAND(hwnd,wParam,lParam,ON_MESSAGEBOXNEWGRAPHICMODE_WM_COMMAND);	
    }
   return FALSE;
}
/*-----------------------------------------------------------------------------------*/
BOOL ON_MESSAGEBOXNEWGRAPHICMODE_WM_INITDIALOG(HWND hDlg,HWND hwndFocus, LPARAM lParam)
{
  /* 
  int LanguageCode=0;
  extern char ScilexWindowName[MAX_PATH];
  LPTW lptw=GetTextWinScilab(); 

  */
  
  HKEY key;
  DWORD result,size=4;
  int Language;
  char Clef[MAX_PATH];


  
  wsprintf(Clef,"SOFTWARE\\ScicosLab\\%s\\Settings",SCILAB_VERSION);
  result=RegOpenKeyEx(HKEY_CURRENT_USER, Clef, 0, KEY_QUERY_VALUE , &key);

  if ( RegQueryValueEx(key, "Language", 0, NULL, (LPBYTE)&Language, &size) !=  ERROR_SUCCESS )
    {
      MessageBoxLanguageCode = 0; /* English Default*/
    }
  else
    {
      MessageBoxLanguageCode = Language;
    }

  if ( result == ERROR_SUCCESS ) RegCloseKey(key);

  CheckDlgButton(hDlg, IDC_CHECKNEWGRAPHIC, BST_UNCHECKED);
  switch (MessageBoxLanguageCode)
    {
    case 1:
      SetWindowText(hDlg,MSG_SCIMSG87);
      SetDlgItemText(hDlg,IDC_OPENRELEASENOTES,MSG_SCIMSG114);
      SetDlgItemText(hDlg,IDC_NEWGRAPHICMESSAGE,MSG_SCIMSG88);
      SetDlgItemText(hDlg,IDC_CHECKNEWGRAPHIC,MSG_SCIMSG89);
      break;

    case 0:default:
      SetWindowText(hDlg,MSG_WARNING22);
      SetDlgItemText(hDlg,IDC_OPENRELEASENOTES,MSG_SCIMSG115);
      SetDlgItemText(hDlg,IDC_NEWGRAPHICMESSAGE,MSG_SCIMSG90);
      SetDlgItemText(hDlg,IDC_CHECKNEWGRAPHIC,MSG_SCIMSG91);
      break;
    }
  return TRUE;
}
/*-----------------------------------------------------------------------------------*/
BOOL ON_MESSAGEBOXNEWGRAPHICMODE_WM_COMMAND(HWND hwnd, int id, HWND hwndCtl, UINT codeNotify)
{
  switch(id)
    {
    case IDOK:
      {
	HKEY key;
	DWORD result,dwsize=4;
	char Clef[MAX_PATH];
	int DontShowMessageNewGraphicMode;

	wsprintf(Clef,"SOFTWARE\\ScicosLab\\%s\\Settings",SCILAB_VERSION);  	
	RegCreateKeyEx(HKEY_CURRENT_USER, Clef, 0, NULL, REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, NULL, &key, &result);

	if(IsDlgButtonChecked(hwnd, IDC_CHECKNEWGRAPHIC) == BST_CHECKED)
	  {
	    //The Box is CHECKED!
	    DontShowMessageNewGraphicMode=1;
	    RegSetValueEx(key, "DontShowMessageNewGraphicMode", 0, REG_DWORD, (LPBYTE)&DontShowMessageNewGraphicMode, dwsize);
	  }
	else
	  {
	    //The Box is NOT checked!
	    DontShowMessageNewGraphicMode=0;
	    RegSetValueEx(key, "DontShowMessageNewGraphicMode", 0, REG_DWORD, (LPBYTE)&DontShowMessageNewGraphicMode, dwsize);
	  }

	RegCloseKey(key);
		  
	EndDialog(hwnd, IDOK);
      }
      break;
    case IDC_OPENRELEASENOTES:
      {
	char ScilabDirectory[MAX_PATH];
	char Chemin[MAX_PATH];
	int error=0;

	GetScilabDirectory(ScilabDirectory,FALSE);
			
	wsprintf(Chemin,"%s\\release_notes.txt",ScilabDirectory);
	error =(int)ShellExecute(NULL, "open", Chemin, NULL, NULL, SW_SHOWNORMAL);
	if (error<= 32)
	  {
	    switch (MessageBoxLanguageCode)
	      {
	      case 1:
		MessageBox(hwnd,MSG_WARNING32,MSG_WARNING22,MB_ICONWARNING);
		break;

	      case 0: default:
		MessageBox(hwnd,MSG_WARNING33,MSG_WARNING22,MB_ICONWARNING);
		break;
	      }
	  }
      }
      break;
    }
  return TRUE;
}
/*-----------------------------------------------------------------------------------*/
