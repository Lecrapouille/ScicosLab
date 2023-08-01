/* Allan CORNET */
/* INRIA 2005 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <windows.h>
#include <winuser.h>
#include "../version.h"
#include "wgnuplib.h"
#include "winmain.h"
#include "printf.h"
#include "wcommon.h"


#include "Messages.h"
#include "Warnings.h"
#include "Errors.h"

extern TW textwin;

extern void Xputchar (char c);
extern int getdiary(void);
extern void diary_nnl(char *str,int *n);
extern BOOL IsWindowInterface(void);
extern LPTW GetTextWinScilab(void);

int MyPutCh (int ch)
{
  return TextPutCh (&textwin, (BYTE) ch);
}

int MyGetCh (void)
{
  return TextGetCh (&textwin);
}

char * MyFGetS (char *str, unsigned int size, FILE * file)
{
  char FAR *p;
  if (isterm (file))
    {
      p = TextGetS (&textwin, str, size);
      if (p != (char FAR *) NULL)
	return str;
      return (char *) NULL;
    }
  return fgets (str, size, file);
}

int MyFPutC (int ch, FILE * file)
{
  if (isterm (file))
    {
      MyPutCh ((BYTE) ch);
      TextMessage ();
      return ch;
    }
  return fputc (ch, file);
}

int MyFPutS (char *str, FILE * file)
{
  if (isterm (file))
    {
      TextPutS (&textwin, str);
      TextMessage ();
      return (*str);		/* different from Borland library */
    }
  return fputs (str, file);
}

/* synonym for scilab but without the */
void Scistring (char *str)
{
  int i;
  C2F (xscion) (&i);
  if (i == 0)
    fprintf (stdout, "%s", str);
  else
    {
      TextPutS (&textwin, str);
      MyPutCh ('\n');
    }
}

void sciprint (char *fmt,...)
{
  int i, count, lstr;
  char buf[MAXPRINTF];
  va_list args;
  va_start (args, fmt);

  /* next three lines added for diary SS */
  count = _vsnprintf (buf,MAXPRINTF-1, fmt, args);
  if (count == -1)
    {
      buf[MAXPRINTF-1]='\0';
    }

  lstr = strlen (buf);

  C2F (xscion) (&i);
  if (i == 0)
    {
      /*count = vfprintf(stdout, fmt, args ); */
      printf ("%s", buf);

    }
  else
    {
      /*count = vsprintf(buf,fmt,args); SS */
      TextPutS (&textwin, buf);
    }
  if (getdiary()) diary_nnl(buf,&lstr);

  va_end (args);
  /** return count; **/
}

/* the same but no diary record */

void sciprint_nd (char *fmt,...)
{
  int i, count, lstr;
  char buf[MAXPRINTF];
  va_list args;
  va_start (args, fmt);

  /* next three lines added for diary SS */
  count = _vsnprintf (buf,MAXPRINTF-1, fmt, args);
  if (count == -1)
    {
      buf[MAXPRINTF-1]='\0';
    }
  lstr = strlen (buf);

  C2F (xscion) (&i);
  if (i == 0)
    {
      /*count = vfprintf(stdout, fmt, args ); */
      printf ("%s", buf);
    }
  else
    {
      /*count = vsprintf(buf,fmt,args); SS */
      TextPutS (&textwin, buf);
    }
  va_end (args);
  /** return count; **/
}


/* sciprint adapted to long strings (>MAXPRINTF)     */
/* the long string is split into elements of smaller */
/* length (COLWIDTH characters each) before calling  */
/* sciprint for each such element                    */
/* MAXCHARSSCIPRINT_FULL is for sciprint_full - more than this gets truncated */

#define MAXCHARSSCIPRINT_FULL 5000
#define COLWIDTH 100

void sciprint_full (char *fmt,...)
{
  int lstr;
  va_list ap;
  char *s_buf=NULL;
  char *split_s_buf=NULL;
  int p_s=0;

  s_buf=MALLOC(sizeof(char)*(MAXCHARSSCIPRINT_FULL+1));
  if (s_buf == (char *) 0)
    {
      sciprint("%s: No more memory.\n","sciprint_full");
      return;
    }


  split_s_buf=MALLOC(sizeof(char)*(COLWIDTH+1));
  if (split_s_buf == (char *) 0)
    {
      sciprint("%s: No more memory.\n","sciprint_full");
      return;
    }

  va_start(ap,fmt);

#if defined(linux) || defined(_MSC_VER)
  count = vsnprintf (s_buf,MAXCHARSSCIPRINT_FULL-1, fmt, ap );
  if (count == -1)
    {
      s_buf[MAXCHARSSCIPRINT_FULL-1]='\0';
    }
#else
  (void )vsprintf(s_buf, fmt, ap );
#endif

  va_end(ap);

  lstr=(int) strlen(s_buf);

  if (lstr<COLWIDTH)
    {
      sciprint("%s",s_buf);
    }
  else
    {
      strncpy(split_s_buf,s_buf+p_s,COLWIDTH);
      split_s_buf[COLWIDTH]='\0';
      p_s=p_s+COLWIDTH;
      sciprint("%s",split_s_buf);
      sciprint("\n");
      while (p_s+COLWIDTH<lstr)
	{
	  strncpy(split_s_buf,s_buf+p_s,COLWIDTH);
	  split_s_buf[COLWIDTH]='\0';
	  p_s=p_s+COLWIDTH;
	  sciprint("  (cont'd) %s\n",split_s_buf);
	}
      strncpy(split_s_buf,s_buf+p_s,lstr-p_s);
      split_s_buf[lstr-p_s]='\0';
      sciprint("     (end) %s\n",split_s_buf);
    }

  if (s_buf){FREE(s_buf);s_buf=NULL;}
  if (split_s_buf){FREE(split_s_buf);split_s_buf=NULL;}

}


/* as sciprint but with an added first argument
 * which is ignored (used in do_printf)
 */

int sciprint2 (int iv, char *fmt,...)
{
  int i, count,lstr;
  va_list ap;
  char s_buf[MAXPRINTF];
  va_start (ap, fmt);
  /* next three lines added for diary SS */
  count = _vsnprintf (s_buf,MAXPRINTF-1, fmt, ap);
  if (count == -1)
    {
      s_buf[MAXPRINTF-1]='\0';
    }

  lstr = strlen (s_buf);

  C2F (xscion) (&i);
  if (i == 0)
    {
      printf ("%s", s_buf);
      //count = vfprintf (stdout,"%s",s_buf);
    }
  else
    {
      /* count = vsprintf (s_buf, fmt, ap); SS */
      TextPutS (&textwin, s_buf);
    }
  if (getdiary()) diary_nnl(s_buf,&lstr);

  va_end (ap);
  return count;
}

size_t MyFWrite (const void *ptr, size_t size, size_t n, FILE * file)
{
  if (isterm (file))
    {
      int i;
      for (i = 0; i < (int) n; i++)
	TextPutCh (&textwin, ((BYTE *) ptr)[i]);
      TextMessage ();
      return n;
    }
  return fwrite (ptr, size, n, file);
}

size_t MyFRead (void *ptr, size_t size, size_t n, FILE * file)
{
  if (isterm (file))
    {
      int i;
      for (i = 0; i < (int) n; i++)
	((BYTE *) ptr)[i] = TextGetChE (&textwin);
      TextMessage ();
      return n;
    }
  return fread (ptr, size, n, file);
}

/* I/O Function for scilab : this function are used when Xscilab is on */

void Xputchar (char c)
{
  MyPutCh ((int) c);
}

void Xputstring (char *str,int n)
{
  int i;
  for (i = 0; i < n; i++)	Xputchar (str[i]);
}

void C2F (xscisncr) (char *str,integer *n,integer dummy)
{
  Xputstring (str, *n);
}

void C2F (xscistring) (char *str,int *n,long int dummy)
{
  Xputstring (str, *n);
  Xputstring ("\r\n", 2);
}

void C2F (xscimore) (int *n)
{
  int n1, ln;
  *n = 0;
  ln = strlen (MORESTR);
  Xputstring (MORESTR, ln);
  n1 = TextGetCh (&textwin);
  if (n1 == 'n')
    {
      *n = 1;
      Xputstring ("\r\n", 2);
    }
  else
    {
      if (IsWindowInterface())
	{
#define NOTEXT 0xF0
	  int X=0,Y=0;
	  int i = 0;
	  LPTW lptw=GetTextWinScilab();

	  X=lptw->CursorPos.x-strlen(MORESTR);
	  Y=lptw->CursorPos.y;
	  if (Y>0)
	    {
	      i=(Y)*lptw->ScreenSize.x;

	      _fmemset(lptw->ScreenBuffer + i, ' ', lptw->ScreenSize.x);
	      _fmemset(lptw->AttrBuffer + i, NOTEXT,lptw->ScreenSize.x);

	      TextGotoXY (lptw, X,Y);
	      InvalidateRect (lptw->hWndText, NULL, TRUE);
	    }
	}
		
    }
	
  TextMessage ();
}

/* I/O Function for C routines : test for xscion */

void Scisncr (char *str)
{
  int i;
  integer lstr;
  C2F (xscion) (&i);
  if (i == 0)
    fprintf (stdout, "%s", str);
  else
    {
      lstr = strlen (str);
      C2F (xscisncr) (str, &lstr, 0L);
    }
}

