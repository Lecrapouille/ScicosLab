/*------------------------------------------------------------------------
 *    Copyright (C) 2001-2010 Enpc/Jean-Philippe Chancelier
 *    jpc@cermics.enpc.fr
 *--------------------------------------------------------------------------*/

#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <setjmp.h>
#include <ctype.h>
#include <sys/time.h>
#include <stdarg.h>
#include <stdlib.h>

#ifdef aix
#include <sys/select.h>
#endif

#include <gdk/gdkx.h>
#include <gtk/gtk.h>

#include "../graphics/Math.h"
#include "../os_specific/Os_specific.h"
#include "All-extern.h"

#ifdef WITH_TK
#include "../tclsci/TCL_Global.h"
#endif

extern void start_sci_gtk(void);
extern int getdiary();
void C2F(diary) (char *str,int *n);
void diary_nnl  (char *str,int *n);

static int BasicScilab = 1;

/*---------------------------------------------------------
 * Input output functions
 *---------------------------------------------------------*/

void C2F(xscisrn)(char *str,integer *n,long int dummy)
{
  int i;
  for ( i =0 ; i < *n; i++) {
    if ( str[i] == '\n' ) 
      {
	fprintf(stdout,"%c",'\r');
      }
    fprintf(stdout,"%c",str[i]);
  }
}

void C2F(xscisncr)(char *str,integer *n,long int dummy)
{
  int i;
  for ( i =0 ; i < *n; i++)  fprintf(stdout,"%c",str[i]);
}


void C2F(xscistring)(char *str, int *n, long int dummy)
{
  int i ;
  for ( i =0 ; i < *n; i++)  fprintf(stdout,"%c",str[i]);
  fprintf(stdout,"\n");
}

void C2F(xscimore)(int *n)
{
  int n1=0;
  *n=0;
  if ( using_readline() == 1 ) 
    n1= get_one_char("[More (y or n) ?] ");
  else {
    fprintf(stdout,"%s","[More (y or n ) ?] ");
    n1=Xorgetchar(0);
  }
  if ( n1 == 110 )  *n=1;
  fprintf(stdout,"\n");
}

/* I/O Function for C routines no test for xscion here */

void Scisncr(char *str)
{
  fprintf(stdout,"%s",str);
}

void Scistring(str)
     char *str;
{
  fprintf(stdout,"%s",str);
}

/* 
 * sciprint(format,arg1,....)
 */

void  sciprint(char *fmt,...) 
{
  integer lstr;
  va_list ap;
  char s_buf[1024];
  va_start(ap,fmt);

  (void )vfprintf(stdout, fmt, ap );
  if (getdiary()) {
    (void ) vsprintf(s_buf, fmt, ap );
    lstr=strlen(s_buf);
    diary_nnl(s_buf,&lstr);
  }
  va_end(ap);
}

/* 
 * sciprint(format,arg1,....)
 * no diary record 
 */

void  sciprint_nd(char *fmt,...) 
{
  va_list ap;
  va_start(ap,fmt);
  vprintf(fmt, ap );
  va_end(ap);
}

/*
 * sciprint adapted to long strings (>MAXPRINTF)     
 * the long string is split into elements of smaller 
 * length (COLWIDTH characters each) before calling  
 * sciprint for each such element                    
 * MAXCHARSSCIPRINT_FULL is for sciprint_full - more than this gets truncated 
 */

#define MAXCHARSSCIPRINT_FULL 5000
#define COLWIDTH 100

void sciprint_full (char *fmt,...)
{
  int lstr;
  va_list ap;
  char *s_buf=NULL;
  char *split_s_buf=NULL;
  int count=0;
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

/* 
 * as sciprint but with an added first argument 
 * which is ignored (used in do_printf) 
 */

int  sciprint2(int iv,char *fmt,...) 
{
  int retval,lstr;
  va_list ap;
  char s_buf[1024];
  va_start(ap,fmt);

  retval= vfprintf(stdout, fmt, ap );
  if (getdiary()) {
    (void ) vsprintf(s_buf, fmt, ap );
    lstr=strlen(s_buf);
    diary_nnl(s_buf,&lstr);
  }

  va_end(ap);
  return retval;
}

/************************************************************************ 
 * This routine is called by the Scilab interpreter in the course of 
 * computation to checks for all events except typed text (but testing 
 * Ctrl )
 * and to deal with them 
 * (This function is useless in the gtk version)  
 ************************************************************************/

void xevents1()
{
  if (BasicScilab) return;
#ifdef WITH_TK
  flushTKEvents();
#endif
  /* XXXXXX */
  while ( gtk_events_pending()) 
    gtk_main_iteration(); 
}

/****************************************
 * main Input function 
 * returns a char and deal with events 
 ****************************************/

/*---------------------------------------------------------------------------
 * Functions to set or to get the scilab status 
 * i.e is it a scilab or a scilab -nw 
 *---------------------------------------------------------------------------*/

static int INXscilab=0;

void SetXsciOn()
{
#ifdef WITH_TK
  initTCLTK();
#endif
  INXscilab=1;
  BasicScilab = 0;
}

/* for Fortran calls */

int C2F(xscion)(int *i)
{
  *i=INXscilab;
  return(0);
}


int C2F(checkevts)(int *i)
{
  *i= Max(INXscilab,1-BasicScilab);
  return(0);
}

/*---------------------------------------------------------------------------
 * when there is no window 
 *    the display can be activated i.e with a plot or an x_menu 
 *    then BasicScilab has to be set to 0 
 *---------------------------------------------------------------------------*/

void SetNotBasic(void) 
{
  BasicScilab=0;
}

int GetBasic(void) { return  BasicScilab;} 



/* 
 * used to start tk at run time when scilab 
 * was started with scilab -nw 
 * open a display with DisplayInit and initialize 
 * Tk. If TK_Started is set to one then the initialization 
 * was correct.
 */

void sci_tk_activate(void)
{
#ifdef WITH_TK
  start_sci_gtk(); /* be sure that gtk is started */
  initTCLTK();
  BasicScilab = 0;
  flushTKEvents();
#endif
}



/*---------------------------------------------------------------------------
 * 
 *  Xorgetchar : function used while in the scilab -nw mode 
 *      by zzledt to get the next typed char (in stdin)
 *      but also checks for X11 events if we are using an X Window 
 *      ( ex a graphic window) with scilab -nw )
 *      
 *      stdin is supposed to be changed 
 *      so as not to wait for <cr> this is done inside zzledt 
 *      (in the following code  the key function is select )
 *---------------------------------------------------------------------------*/


#define IBSIZE 1024
char sci_input_char_buffer[IBSIZE];
int  sci_input_char_buffer_count = 0;

#define SELECT_DEBUG(x)

/*
 * send string s as if it was typed in scilab window 
 * 
 */ 

void write_scilab(char *s)
{
  while ( *s != '\0' && sci_input_char_buffer_count < IBSIZE) 
    {
      sci_input_char_buffer[sci_input_char_buffer_count++]= *s;
      s++;
    }
  sci_input_char_buffer[sci_input_char_buffer_count++]='\n';
}

/* wait for a character and check for pending events */

int Xorgetchar(int interrupt)
{
  int i;
  static int c_count = -1;
  static int GtkXsocket,fd_in,fd_out,fd_err;
  static int first = 0,max_plus1;
  static int size_first=0;
  fd_set select_mask,write_mask;
  static struct timeval select_timeout;

  /* try to get terminal size */
  if ( size_first==0 ) { sci_winch_signal(0);size_first++;}


  if ( BasicScilab) return(getchar());

  if ( first == 0) 
    {
      first++;
      GtkXsocket = ConnectionNumber(GDK_DISPLAY());
      fd_in  = fileno(stdin) ;
      fd_out = fileno(stdout);
      fd_err = fileno(stderr);
      max_plus1 = Max(fd_in,GtkXsocket);      
      max_plus1 = Max(fd_out,max_plus1);
      max_plus1 = Max(fd_err,max_plus1);
#ifdef WITH_TK 
      max_plus1 = Max(XTKsocket,max_plus1);
#endif 
      max_plus1++;
    }
  
  for( ; ; ) {
    /* always flush writes before waiting */
#ifdef WITH_TK 
    flushTKEvents();
#endif 
    gdk_flush();
    fflush(stdout); 
    fflush(stderr);
    /* Update the masks and, unless X events are already in the queue,
     * wait for I/O to be possible. 
     */
    FD_ZERO(&select_mask);
    FD_SET(fd_in , &select_mask);
    FD_SET(GtkXsocket, &select_mask);
#ifdef WITH_TK 
    FD_SET(XTKsocket, &select_mask);
#endif 
    FD_ZERO(&write_mask);
    /* XXXX : the two next FD_SET causes select not to wait 
     * and since they do not seam necessary they are commented out  
     */
    /* FD_SET(fd_out,&write_mask);
       FD_SET(fd_err,&write_mask); */

    select_timeout.tv_sec =  0;
#ifdef __APPLE__
    select_timeout.tv_usec = 10000;
#else 
    select_timeout.tv_usec = 10000;
#endif 
    while ( gtk_events_pending())
      { 
	gtk_main_iteration(); 
      }
    /* maybe a  handler to be executed  
     * note that if more than one menu were activated they will 
     * all be evaluated 
     */

    if (interrupt&&(C2F(ismenu)()==1)) return(-1);

    /* maybe a new string to execute */
    if ( sci_input_char_buffer_count > 0) 
      {
	sci_input_char_buffer_count--;
	return sci_input_char_buffer[++c_count];
      }
    else
      {
	c_count = -1;
      }

    i = select(max_plus1, &select_mask,&write_mask, (fd_set *)NULL,
	       &select_timeout);
    if (i < 0) {
      if (errno != EINTR)
	{ 
#ifdef DEBUG
	  fprintf(stderr,"error in select\n");
#endif
	  exit(0);
	  continue;
	} 
      continue ;
    }
    if ( i== 0) continue;
    /* if there's something to output */
    if ( FD_ISSET(fd_out,&write_mask)) { 
      fflush(stdout); 
    }
    if ( FD_ISSET(fd_err,&write_mask)) { 
      fflush(stderr); 
    }

    /* if there's something to read */
    if ( FD_ISSET(fd_in,&select_mask )) { 
      return getchar();
      break;
    } 
#ifdef WITH_TK 
    if ( FD_ISSET(XTKsocket,&select_mask )) { 
      flushTKEvents();
    }
#endif 
    if ( FD_ISSET(GtkXsocket,&select_mask)) { 
      /* if there are X events in our queue, it
       * counts as being readable 
       */
      while ( gtk_events_pending()) /*  ||(select_mask & gtk_mask) */
	{ 
	  gtk_main_iteration(); 
	} 
    }
  }
}
int XEvorgetchar(int interrupt)
{
  return Xorgetchar(interrupt);
}
/*---------------------------------------------------------------------------
 *  Dealing with X11 Events.
 *  xevents is called by Xorgetchar and also by DispatchEvents in 
 *  routines/system 
 *  xevents must work for scilab and scilab -nw 
 ---------------------------------------------------------------------------*/

int C2F(sxevents)(void)
{
  /* check the TK case */ 
#ifdef WITH_TK
  flushTKEvents();
#endif
  while ( gtk_events_pending())
    gtk_main_iteration(); 
  return(0);
}

/*-------------------------------------------------------
 * winch signal : window size changed 
 *-------------------------------------------------------*/

void sci_winch_signal(int n) 
{
  int rows,cols;
  /* should not be usefull here since it is supposed to be automatically called */
  sci_get_screen_size (&rows,&cols); 
  if ( rows != 0 && cols != 0 )     C2F(scilines)(&rows,&cols); 
#ifdef DEBUG 
  fprintf(stderr,"windows size changed %d %d\r\n",rows,cols); 
#endif  
}

