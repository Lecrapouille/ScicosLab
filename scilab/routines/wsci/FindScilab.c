#include "FindScilab.h"
#include "../version.h"
#include "Messages.h"
#include "Warnings.h"
#include "Errors.h"

#include "wcommon.h"
#include "resource.h"

#include "../os_specific/win_mem_alloc.h" /* MALLOC */

/* Allan CORNET INRIA 2004 */
/*-----------------------------------------------------------------------------------*/

EXPORT BOOL CALLBACK ChooseScilabDlgProc(HWND hdlg, UINT wmsg, WPARAM wparam, LPARAM lparam);

#define LineMax 255
#define NumberScilabMax 10
/*-----------------------------------------------------------------------------------*/
static char BeginningWindowScilabName[LineMax];

static char ListScilabName[NumberScilabMax][LineMax];
static int NumberScilab=0;
static BOOL MoreMaxNumberScilabMax=FALSE;
/*-----------------------------------------------------------------------------------*/
static BOOL ExposeDialogBox=FALSE;
static char * ChooseScilabBox(void);
static int ItemChooseScilab;

BOOL HaveAnotherWindowScilab(void)
{
	BOOL Retour=FALSE;
	HWND CurrenthWnd=NULL;
	
	wsprintf(BeginningWindowScilabName,"%s (",SCILAB_VERSION);
	
	CurrenthWnd=GetWindow(GetDesktopWindow(),GW_CHILD);
	CurrenthWnd=GetWindow(CurrenthWnd,GW_HWNDFIRST);

	while ( CurrenthWnd!= NULL )
	{
		char Title[LineMax];

		GetWindowText(CurrenthWnd,Title,strlen(BeginningWindowScilabName)+1);
		if (strcmp(Title,BeginningWindowScilabName) == 0)
		{
			GetWindowText(CurrenthWnd,Title,LineMax);
			if (NumberScilab<NumberScilabMax)
			{
				wsprintf(ListScilabName[NumberScilab],"%s",Title);
			}
			else MoreMaxNumberScilabMax=TRUE;
			NumberScilab++;
			Retour=TRUE;
		}
	
		CurrenthWnd=GetWindow(CurrenthWnd,GW_HWNDNEXT);
	}

	return Retour;
}
/*-----------------------------------------------------------------------------------*/
char * ChooseAnotherWindowScilab(void)
{
	char *TitleScilabChoose=NULL;
	if (NumberScilab == 1)
	{
		TitleScilabChoose=MALLOC( (strlen(ListScilabName[NumberScilab-1])+1) * sizeof(char) );
		wsprintf(TitleScilabChoose,"%s",ListScilabName[NumberScilab-1]);
	}
	else
	{
		HWND hWndScilab=NULL;
		TitleScilabChoose=ChooseScilabBox();
		hWndScilab=FindWindow(NULL,TitleScilabChoose);
		if (hWndScilab==NULL) /* La fenetre n'existe plus */
		{
			FREE(TitleScilabChoose);
			TitleScilabChoose=NULL;
		}
	}

	return TitleScilabChoose;


}
/*-----------------------------------------------------------------------------------*/

extern HINSTANCE hdllInstance;

char * ChooseScilabBox(void)
{
  MSG msg;
  HWND hWndChooseScilabBox=NULL;
  char *TitleScilabChoose=NULL;
  /* DLGPROC   lpfnChooseScilabDlgProc = (DLGPROC) MyGetProcAddress("ChooseScilabDlgProc",ChooseScilabDlgProc );*/
  hWndChooseScilabBox= CreateDialog((HINSTANCE)GetModuleHandle(NULL),(LPCSTR)IDD_CHOOSEASCILAB,NULL,ChooseScilabDlgProc) ;
  
  if (hWndChooseScilabBox)
    {
      ExposeDialogBox=TRUE;
      ShowWindow(hWndChooseScilabBox, SW_SHOW);
      UpdateWindow(hWndChooseScilabBox);

      while (PeekMessage(&msg, 0, 0, 0, PM_REMOVE) || ExposeDialogBox )
	{
          TranslateMessage(&msg);
	  DispatchMessage(&msg);
	}
    
    }

  if (ItemChooseScilab==0) // Launch A new Scilab
    {
      TitleScilabChoose=NULL;
    }
  else
    {
      TitleScilabChoose=MALLOC( (strlen(ListScilabName[ItemChooseScilab-1])+1) * sizeof(char) );
      wsprintf(TitleScilabChoose,"%s",ListScilabName[ItemChooseScilab-1]);
    }

  return TitleScilabChoose;
}
/*-----------------------------------------------------------------------------------*/

BOOL CALLBACK ChooseScilabDlgProc(HWND hdlg, UINT wmsg, WPARAM wparam, LPARAM lparam)
{
  switch (wmsg) 
  {
	case WM_INITDIALOG:
		{
			int i=0;

			SendDlgItemMessage(hdlg, IDC_LISTCHOOSEASCILAB, LB_ADDSTRING, 0, (LPARAM)((LPSTR)MSG_SCIMSG10));
			for (i=0; i < NumberScilab  ; i++)
				{
				 if (i < NumberScilabMax) SendDlgItemMessage(hdlg, IDC_LISTCHOOSEASCILAB, LB_ADDSTRING, 0, (LPARAM)((LPSTR)ListScilabName[i] ));
				}
			/* Par défaut , le premier Scilab Trouvé est selectionné */
			SendDlgItemMessage(hdlg, IDC_LISTCHOOSEASCILAB, LB_SETCURSEL,1, 0L);
		}
	return TRUE;
	case WM_COMMAND:
		switch (LOWORD(wparam)) 
		{
			case IDC_LISTCHOOSEASCILAB:
				if ( HIWORD( wparam ) == LBN_DBLCLK )
				{
					ItemChooseScilab=(UINT)SendDlgItemMessage(hdlg,IDC_LISTCHOOSEASCILAB,LB_GETCURSEL,0,0L);
					ExposeDialogBox=FALSE;
					DestroyWindow(hdlg);
					return TRUE;
				}
			return FALSE;

			case IDC_OK:
				{
					ItemChooseScilab=(UINT)SendDlgItemMessage(hdlg,IDC_LISTCHOOSEASCILAB,LB_GETCURSEL,0,0L);
					ExposeDialogBox=FALSE;
					DestroyWindow(hdlg);
				}
			return TRUE;

		}
	break;
	case WM_CLOSE:
		ExposeDialogBox=FALSE;
		DestroyWindow(hdlg);
		exit(0);
		return TRUE;
	break ;

  }
  return FALSE;
}
/*-----------------------------------------------------------------------------------*/
