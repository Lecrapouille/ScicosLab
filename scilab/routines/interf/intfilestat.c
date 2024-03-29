#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <locale.h>
#include <stdio.h>
#include <string.h>

#if WIN32
#include <windows.h>
#endif

#include "../stack-c.h"

#include "../os_specific/Os_specific.h"

int C2F(intfilestat)(fname)
char * fname;
{
#ifdef WIN32
   struct _stat buf;
#else
   struct stat buf;
#endif
   int result, m1, n1, l1 , l2,one=1,n;
#if WIN32
   char DriveTemp[MAX_PATH];
#endif
   CheckRhs(1,1);
   CheckLhs(1,2);
   GetRhsVar(1, "c", &m1, &n1, &l1); /* get file name */

   n=m1*n1+256;
   CreateVar(2,"c",&one,&n,&l2);
   C2F(cluni0)(cstk(l1), cstk(l2), &m1,m1*n1,n);
   /* Get data associated with "given file": */
#ifdef WIN32
   {
		char *path=cstk(l2);
		wsprintf(DriveTemp,"%s",path);
		if (path)
		{
			if ( (path[strlen(path)-1]=='/') || (path[strlen(path)-1]=='\\') )
			{
				path[strlen(path)-1]='\0';
			}

		}
		result = _stat(path, &buf );
   }
#else
   result = stat(cstk(l2), &buf );
#endif
   /* Check if statistics are valid: */
   if( result != 0 ) 
   {
#if WIN32
	 if ( (strlen(DriveTemp)==2) ||(strlen(DriveTemp)==3) )
	 {
		 UINT DriveType=GetDriveType(DriveTemp);
		 if ( (DriveType==DRIVE_UNKNOWN) || (DriveType==DRIVE_NO_ROOT_DIR) )
		 {
			 n1=0;
			 CreateVar(2,"d",&n1,&n1,&l2);
		 }
		 else
		 {
			 n1 = 13;
			 CreateVar(2,"d",&one,&n1,&l2);

			 *stk(l2+0) =  0.0;
			 *stk(l2+1) =  16895;
			 *stk(l2+2) =  0.0;
			 *stk(l2+3) =  0.0;
			 *stk(l2+4) =  0.0;
			 *stk(l2+5) =  0.0;
			 *stk(l2+6) =  0.0;
			 *stk(l2+7) =  0.0;
			 *stk(l2+8) =  0.0;
			 *stk(l2+9) =  0.0;
			 *stk(l2+10) = 0.0;
			 *stk(l2+11) = 0.0;
			 *stk(l2+12) = 0.0;
		 }
		 LhsVar(1) = 2;
		 if (Lhs==2) 
		 {
			 CreateVar(3,"d",&one,&one,&l2);
			 *stk(l2) = (double) result;
			 LhsVar(2) = 3;
		 }
	 }
	 else
	 {
		 n1=0;
		 CreateVar(2,"d",&n1,&n1,&l2);
	 }
     
#else
	 n1=0;
	 CreateVar(2,"d",&n1,&n1,&l2);
#endif
   }
   else
   {
     n1 = 13;
     CreateVar(2,"d",&one,&n1,&l2);

     *stk(l2+0) = (double) buf.st_size;/* total size, in bytes */
     *stk(l2+1) = (double) buf.st_mode;/* protection */
     *stk(l2+2) = (double) buf.st_uid;/* user ID of owner */
     *stk(l2+3) = (double) buf.st_gid;/* group ID of owner */
     *stk(l2+4) = (double) buf.st_dev;/* device */
     *stk(l2+5) = (double) buf.st_mtime;/* time of last modification */
     *stk(l2+6) = (double) buf.st_ctime;/* time of last change */
     *stk(l2+7) = (double) buf.st_atime;/* time of last access */
     *stk(l2+8) = (double) buf.st_rdev;/* device type (if inode device) */
#ifdef WIN32
     *stk(l2+9) = 0.0;
     *stk(l2+10) = 0.0;
#else 
     *stk(l2+9) = (double) buf.st_blksize;/* blocksize for filesystem I/O */
     *stk(l2+10) = (double) buf.st_blocks;/* number of blocks allocated */
#endif 
     *stk(l2+11) = (double) buf.st_ino;/* inode */
     *stk(l2+12) = (double) buf.st_nlink;/* number of hard links */

   }
  LhsVar(1) = 2;
  if (Lhs==2) {
    CreateVar(3,"d",&one,&one,&l2);
    *stk(l2) = (double) result;
    LhsVar(2) = 3;
  }
  C2F(putlhsvar)();
  return 0;
}
