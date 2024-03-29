/* Copyright INRIA/ENPC */
#include <string.h>
#include "../machine.h"

#ifdef WIN32 
  #include <windows.h>
  #if !(defined __CYGWIN32__)
    #include <direct.h>
    #define chdir(x) _chdir(x)
    #define GETCWD(x,y) _getcwd(x,y)
  #else 
    #include <unistd.h>
    #define GETCWD(x,y) getcwd(x,y)
  #endif
#endif 

#define FSIZE 1024
static char     cur_dir[FSIZE];

#if defined(SYSV) || defined(SVR4)
  extern char *getcwd();
  #define GETCWD(x,y) getcwd(x,y)
#else
  #ifndef WIN32
    #include <unistd.h>
    #define GETCWD(x,y) getwd(x)
    #if !(defined(netbsd)) && !(defined(freebsd))
      #define getwd(x) getcwd(x,FSIZE) 
    #endif
  #endif
#endif

extern void sciprint __PARAMS((char *fmt,...));

/*******************************
 * Changes scilab current directory 
 *******************************/

int C2F(scichdir)(char *path,int *err)
{
  *err=0;
  if (path == (char*) 0) {
    *cur_dir = '\0';
    return (0);
  }

  if (chdir(path) == -1) {
    sciprint("Can't go to directory %s \r\n", path); 
    /** XXX : a remettre , sys_errlist[errno]); **/
    *err=1;
  } 
  /** a rajouter en XWindow ? pour transmettre l'info au menu 
    if (get_directory()==0) 
    *err=1; **/
  /* scilab_status_show(path); XXXX en attente */ 
  return 0;
}

/*******************************
 * Get scilab current directory 
 *******************************/

int C2F(scigetcwd)(char **path,int *lpath,int *err)
{
    if (GETCWD(cur_dir, 1024) == (char*) 0)
      {	/* get current working dir */
	sciprint("Can't get current directory\r\n");
	*cur_dir = '\0';
	*lpath=0;
	*err=1;
      }
    else 
      {
		*path= cur_dir;
		*lpath=strlen(cur_dir);
		*err=0;
      }
    return 0;
}

