/* used for mingw32 when the -mwindows option is used 
 *
 */

#include <windows.h>

extern int WINAPI Windows_Main (HINSTANCE hInstance, HINSTANCE hPrevInstance,PSTR szCmdLine, int iCmdShow);

int WINAPI WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance,LPSTR szCmdLine, int iCmdShow)
{
  return Windows_Main(hInstance,hPrevInstance,szCmdLine, iCmdShow);
}

