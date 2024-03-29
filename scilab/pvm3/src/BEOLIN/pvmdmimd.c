
/*
 *         PVM version 3.4:  Parallel Virtual Machine System
 *               University of Tennessee, Knoxville TN.
 *           Oak Ridge National Laboratory, Oak Ridge TN.
 *                   Emory University, Atlanta GA.
 *      Authors:  J. J. Dongarra, G. E. Fagg, M. Fischer
 *          G. A. Geist, J. A. Kohl, R. J. Manchek, P. Mucci,
 *         P. M. Papadopoulos, S. L. Scott, and V. S. Sunderam
 *                   (C) 1997 All Rights Reserved
 *
 *                              NOTICE
 *
 * Permission to use, copy, modify, and distribute this software and
 * its documentation for any purpose and without fee is hereby granted
 * provided that the above copyright notice appear in all copies and
 * that both the copyright notice and this permission notice appear in
 * supporting documentation.
 *
 * Neither the Institutions (Emory University, Oak Ridge National
 * Laboratory, and University of Tennessee) nor the Authors make any
 * representations about the suitability of this software for any
 * purpose.  This software is provided ``as is'' without express or
 * implied warranty.
 *
 * PVM version 3 was funded in part by the U.S. Department of Energy,
 * the National Science Foundation and the State of Tennessee.
 */

/*
 *	pvmdmimd.c
 *
 *  MPP interface.
 *
 *		void mpp_init(int argc, char **argv):	
 *			Initialization. Create a table to keep track of active nodes.
 *			argc, argv: passed from main.
 *
 *		int mpp_load( struct waitc_spawn *wxp ) 
 *
 *			Load executable onto nodes; create new entries in task table,
 *			encode node number and process type into task IDs, etc.
 *
 *				Construction of Task ID:
 *
 *			 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 *			+-+-+-----------------------+-+-----+--------------------------+
 *			|s|g|		host index	    |n| prt |    	node # (16384)	   |
 *			+-+-+-----------------------+-+-----+--------------------------+
 *
 *			The "n" bit is set for node task but clear for host task.
 *
 *			flags:	exec options;
 *			name:	executable to be loaded;
 *			argv:	command line argument for executable
 *			count:	number of tasks to be created;
 *			tids:	array to store new task IDs;
 *			ptid:	parent task ID.
 *
 *			mpp_new(int count, int ptid):		
 *				Allocate a set of nodes. (called by mpp_load())
 *				count: number of nodes;  ptid: parent task ID.
 *
 *		int mpp_output():	
 *			Send all pending packets to nodes via native send. Node number
 *			and process type are extracted from task ID.
 *
 *		struct task *mpp_find(int pid):
 *			Find a task in task table by its Unix pid.
 *
 *		void mpp_free(struct task *tp):
 *			Remove node/process-type from active list.
 *			tp: task pointer.
 *
: pvmdmimd.c,v $
Revision 1.1.1.1  2004/04/26 15:36:59  stochopt
Imported sources

Revision 1.1.1.1  2003/11/14 13:02:08  stochopt
Imported files

Revision 1.1.1.1  2003/02/18 09:26:05  stochopt
initial

Revision 1.1.1.1  2003/02/17 11:25:32  stochopt
initial

Revision 1.1.1.1  2003/02/03 08:42:12  stochopt
imported sources

Revision 1.1.1.1  2003/01/06 09:04:13  stochopt
Imported sources

Revision 1.1.1.1  2002/12/19 17:37:37  stochopt
start

Revision 1.1  2002/10/14 14:40:05  chanceli
update

Revision 1.1  2000/02/17 21:02:24  pvmsrc
Architecture-specific Makefile and Pvmd code.
	- submitted by Paul Springer <pls@smokeymt.jpl.nasa.gov>.
	- hacked a little by Jeembo for convention compliance...  :-)
(Spanker=kohl)

 *
 */

#include <stdlib.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <signal.h>
#include <netdb.h>
#ifdef  SYSVSTR
#include <string.h>
#define CINDEX(s,c) strchr(s,c)
#else
#include <strings.h>
#define CINDEX(s,c) index(s,c)
#endif

#include <pvm3.h>
#include <pvmproto.h>
#include "global.h"
#include "host.h"
#include "waitc.h"
#include "pvmalloc.h"
#include "pkt.h"
#include "task.h"
#include "listmac.h"
#if 0
#include "tvdefs.h"
#endif
#include "pvmdmp.h"
#include "pvmmimd.h"
#include "bfunc.h"

#define BLCOMM		"/usr/bin/rsh"
#define BLARGC		3

char *getenv();

/* Global */

extern int pvmdebmask;			/* from pvmd.c */
extern char **epaths;			/* from pvmd.c */
extern int myhostpart;			/* from pvmd.c */
extern int myndf;			/* from pvmd.c */
extern struct htab *hosts;		/* from pvmd.c */
extern struct task *locltasks;	/* from task.c */
extern int pvmmydsig;			/* from pvmd.c */
extern int pvmudpmtu;			/* from pvmd.c */


int tidtmask = TIDPTYPE;		/* mask for ptype field of tids */
int tidnmask = TIDNODE;			/* mask for node field of tids */

/* private */


static struct nodeset *busynodes;	/* active nodes; ordered by proc type */
static char pvmtxt[512];		/* scratch for error log */
static int ptypemask;			/* mask; we use these bits of ptype in tids */
static u_long *nodeaddr = 0;
static char **nodelist = 0;		/* default poe node list */
static int partsize = 0;		/* total number of nodes allocated */

static int mpppvminfo[SIZEHINFO];

void
mpp_init(argc, argv)
	int *argc;
	char **argv;
{
	struct hostent *hostaddr;
	int 	i;
	int		n;
	struct in_addr	node_sin_addr;
	char 	nname[128];	/* node name */
	char 	*p, *q;
	char 	*plist;		/* processor list */

	if ((plist = getenv("PROC_LIST"))) 
		{
		sprintf(pvmtxt, 
		  "PROC_LIST=%s\n",plist);
		pvmlogerror(pvmtxt);
		p = plist;
		while (1)
			{
			while (*p == ':')
				p++;
			if (!*p)
				break;
			n = (q = CINDEX(p, ':')) ? q - p : strlen(p);
			partsize++;
			p += n;
			}

		nodeaddr = TALLOC(partsize, u_long, "nodeaddr");
		nodelist = TALLOC(partsize, char*, "nname");
		p = plist;
		i = 0;
		while (1)
			{	/* now get the node names */
			while (*p == ':')
				p++;
			if (!*p)
				break;
			n = (q = CINDEX(p, ':')) ? q - p : strlen(p);
			strncpy(nname, p, n);
			nname[n] = 0;
			if (!(hostaddr = gethostbyname( nname )))
				{
				sprintf( pvmtxt, "mpp_init() can't gethostbyname() for %s\n", 
						nname );
				pvmlogerror( pvmtxt );
				}
			else
				{	/* got addr, now save it */
				BCOPY( hostaddr->h_addr_list[0], (char*)&node_sin_addr,
					sizeof(struct in_addr));
				}
			nodeaddr[i] = node_sin_addr.s_addr;
			nodelist[i++] = STRALLOC(nname);
			p += n;
			}


		} 
	else 
		pvmlogerror("mpp_init() PROC_LIST must be set for parallelism.\n");

	sprintf(pvmtxt, "%d nodes in list.\n", partsize);
	pvmlogerror(pvmtxt);

	busynodes = TALLOC(1, struct nodeset, "nsets");
	BZERO((char*)busynodes, sizeof(struct nodeset));
	busynodes->n_link = busynodes;
	busynodes->n_rlink = busynodes;

	ptypemask = tidtmask >> (ffs(tidtmask) - 1);
}


/*
 * find a set of free nodes from nodelist; assign ptype sequentially,
 * only tasks spawned together get the same ptype
 */
struct nodeset *
mpp_new(count, ptid)
	int count;		/* number of nodes requested */
	int ptid;		/* parent's tid */
{
	struct nodeset *sp, *newp, *sp2;
	int last = -1;
	int ptype = 0;

	if (!(newp = TALLOC(1, struct nodeset, "nsets"))) {
		pvmlogerror("mpp_new() can't get memory\n");
		pvmbailout(0);
	}
	BZERO((char*)newp, sizeof(struct nodeset));

	newp->n_size = count;
	for (sp = busynodes->n_link; sp != busynodes; sp = sp->n_link) {
		if (sp->n_first - last > count)
			break;
		last = sp->n_first + sp->n_size - 1;
/*
		if (sp->n_link == busynodes && partsize - last > count)
			break;
*/
		if (ptype <= sp->n_ptype)
			ptype = sp->n_ptype + 1;
	}
	if (sp == busynodes && partsize - last <= count) {
		pvmlogerror("mpp_new() not enough nodes in partition\n");
		PVM_FREE(newp);
		return (struct nodeset *)0;
	}
	for (sp2 = busynodes->n_link; sp2 != busynodes; sp2 = sp2->n_link)
		if ((sp2->n_ptype & ptypemask) == (ptype & ptypemask))
			break;
	if (sp2 != busynodes || ptype == NPARTITIONS) {
		for (ptype = 0; ptype < NPARTITIONS; ptype++) {
			for (sp2 = busynodes->n_link; sp2 != busynodes; sp2 = sp2->n_link)
				if ((sp2->n_ptype & ptypemask) == (ptype & ptypemask))
					break;
			if (sp2 == busynodes)
				break;
		}
		if (ptype == NPARTITIONS) {
			pvmlogerror("mpp_new() out of ptypes: too many spawns\n");
			return (struct nodeset *)0;
		}
	}

done:
	if (pvmdebmask & PDMNODE) {
		sprintf(pvmtxt, "mpp_new() %d nodes %d ... ptype=%d ptid=%x\n",
			count, last+1, ptype, ptid);
		pvmlogerror(pvmtxt);
	}
	newp->n_first = last + 1;
	newp->n_ptype = ptype;
	newp->n_ptid = ptid;
	newp->n_alive = count;
	sprintf( pvmtxt, "mpp_new() sp=%x sp->n_link=%x\n", sp, sp->n_link );
	pvmlogerror( pvmtxt );
	LISTPUTBEFORE(sp, newp, n_link, n_rlink);
	sprintf( pvmtxt, "mpp_new() sp=%x sp->n_link=%x\n", sp, sp->n_link );
	pvmlogerror( pvmtxt );

	return newp;
}

/*
 * remove node/ptype from active list; if tid is the last to go, shutdown
 * pvmhost's socket, but do not destroy the node set because pvmhost may 
 * not exit immediately. To avoid a race condition, let mpp_output()
 * do the cleanup.
 */
void
mpp_free(tp)
	struct task *tp;
{
	struct nodeset *sp;
	int ptype;
#if 0
	struct timeval tout;
#endif
	struct task *tp2;
	int tid = tp->t_tid;

	if (!TIDISNODE(tid))
		return;

	ptype = TIDTOTYPE(tid);
	tp->t_txq = 0;				/* don't free pvmhost's txq */
	sp = busynodes->n_link;
	sprintf( pvmtxt, "mpp_free() sp=%x sp->n_link=%x\n", sp, sp->n_link );
	pvmlogerror( pvmtxt );
	for (sp = busynodes->n_link; sp != busynodes; sp = sp->n_link) {
		sprintf(pvmtxt, "mpp_free() n_ptype = %d, ptype = %d\n",
			sp->n_ptype, ptype );
		pvmlogerror(pvmtxt);
		if ((sp->n_ptype & ptypemask) == ptype) {

			if (pvmdebmask & PDMNODE) {
				sprintf(pvmtxt, "mpp_free() t%x type=%ld alive=%d\n",
					tid, sp->n_ptype, sp->n_alive);
				pvmlogerror(pvmtxt);
			}
			if (sp->n_alive == 0)
				{
				sprintf( pvmtxt, "mpp_free called for dead task t%x\n", tid );
				pvmlogerror( pvmtxt );
				return;
				}
			if (tp2 = task_findpid(tp->t_pid)) {
				/* find corresponding pvmhost and shut it down */
				tp2->t_flag |= TF_CLOSE;
#if 0
				pvmlogprintf( "mpp_free() Marked t%x for closure\n", tp2->t_tid );
#endif
				if (tp2->t_sock != -1) {
/*
					wrk_fds_delete(tp2->t_sock, 3);
					(void)close(tp2->t_sock);
					tp2->t_sock = -1;
*/
					shutdown(tp2->t_sock, 1);
				}
					/* close stdout after pvmhost dies */
				tp2->t_out = tp->t_out;
#if 0
				pvmlogprintf( "mpp_free() Set t%x t_tout to %d\n", tp2->t_tid, tp->t_out );
#endif
			}
			if (--sp->n_alive == 0) {
/*
				LISTDELETE(sp, n_link, n_rlink);
				PVM_FREE(sp);
*/
			}
#if 0
			if (tp->t_out >= 0) {

				fd_set rfds;
				FD_ZERO(&rfds);
				FD_SET(tp->t_out, &rfds);
				TVCLEAR(&tout);
				if (select(tp->t_out + 1,
						(fd_set *)&rfds, (fd_set *)0, (fd_set *)0,
						&tout) == 1)
					{
					pvmlogprintf( "mpp_free() unprinted stdout on t%x\n", tp->t_tid );
					loclstout( tp );
					}
				else
					pvmlogprintf( "mpp_free() no stdout on t%x\n", tp->t_tid );
			}
#endif
			tp->t_out = -1;		/* don't free shared stdout if alive > 0 */
			return;
		}
	}
	sprintf(pvmtxt, "mpp_free() t%x not active\n", tid);
	pvmlogerror(pvmtxt);
	return;
}


/* load executable onto the given set of nodes */
int
mpp_load( wxp )
struct waitc_spawn *wxp;
{
	int flags = 0;              /* exec options */
	char *name;             /* executable */
	char **argv;            /* arg list (argv[-1] must be there) */
	int count;				/* how many */
	int *tids;				/* array to store new tids */
	int ptid;				/* parent task ID */
	int ptypepart;			/* type field */
	int j;
	struct task *tp;
	struct pkt *hosttxq;	/* out-going queue of pvmhost */
	int err = 0;
	struct nodeset *sp;
	char c[128];			/* buffer to store count, name.host */
	int nargs;
	char **ep, **eplist;
	char path[MAXPATHLEN];
	struct stat sb;
	char **av;
	int hostout;			/* stdout of pvmhost */
	int hostpid;			/* Unix pid of pvmhost */

	static char *nullep[] = { "", 0 };

    /* -- initialize some variables from the waitc_spawn struct -- */

    name = wxp->w_argv[0];
    argv = wxp->w_argv;
    count = wxp->w_veclen;
    tids = wxp->w_vec;
    ptid = wxp->w_ptid;

	eplist = CINDEX(name, '/') ? nullep : epaths;

	for (ep = eplist; *ep; ep++) {
		/* search for file */
		(void)strcpy(path, *ep);
		if (path[0])
			(void)strcat(path, "/");
		(void)strncat(path, name, sizeof(path) - strlen(path) - 1);

		if (stat(path, &sb) == -1
		|| ((sb.st_mode & S_IFMT) != S_IFREG)
		|| !(sb.st_mode & S_IEXEC)) {
			if (pvmdebmask & PDMTASK) {
				sprintf(pvmtxt, "mpp_load() stat failed <%s>\n", path);
				pvmlogerror(pvmtxt);
			}
			continue;
		}

		if (!(sp = mpp_new(count, ptid))) {
			err = PvmOutOfRes;
			goto done;
		}
		ptypepart = (0 << (ffs(tidtmask) - 1)) | TIDONNODE;

		if (argv)
			for (nargs = 0; argv[nargs]; nargs++);
		else
			nargs = 0;

		/* ar[-1], rsh, host, command */
		nargs += BLARGC + 1;
		av = TALLOC(nargs + 1, char*, "argv");
		av++;				/* reserve room for debugger */
		BZERO((char*)av, nargs * sizeof(char*));
		av[0] = BLCOMM;
		av[2] = path;
		av[--nargs] = 0;
		for (j = 3; j < nargs; j++)
			av[j] = argv[j - 2];	/* poe name argv -procs # -euilib us */
/*
		if ((sock = mksock()) == -1) {
			err = PvmSysErr;
			goto done;
		}
*/
		if (flags & PvmTaskDebug)
			av++;					/* pdbx name -procs # -euilib us */

		for (j = 0; j < count; j++) 
			{
			av[1] = nodelist[sp->n_first + j];
			sprintf(pvmtxt, "mppload(): Forking to %s\n", av[1]);
			pvmlogerror(pvmtxt);
			/* if (err = forkexec(flags, av[0], av, 0, (char **)0, &tp)) */
			if (err = forkexec(flags, av[0], av, 0, (char **)0, 0,
				0, 0, &tp))
				goto done;
			tp->t_ptid = ptid;
			PVM_FREE(tp->t_a_out);
			sprintf(c, "%s.host", name);
			tp->t_a_out = STRALLOC(c);
			if (pvmdebmask & PDMNODE) 
				pvmlogprintf( "mpp_load() setting n_ptid to %x\n", tp->t_tid );
			sp->n_ptid = tp->t_tid;		/* pvmhost's tid */
			hosttxq = tp->t_txq;
			hostout = tp->t_out;
			hostpid = tp->t_pid;
			tp->t_out = -1;
			mpppvminfo[0] = TDPROTOCOL;
			mpppvminfo[1] = myhostpart + ptypepart;
			mpppvminfo[2] = ptid;
			mpppvminfo[3] = wxp->w_outtid;
			mpppvminfo[4] = wxp->w_outtag;
			mpppvminfo[5] = wxp->w_outctx;
			mpppvminfo[6] = wxp->w_trctid;
			mpppvminfo[7] = wxp->w_trctag;
			mpppvminfo[8] = wxp->w_trcctx;
			mpppvminfo[9] = pvmudpmtu;
			mpppvminfo[10] = pvmmydsig;
/*
		pvminfo[0] = TDPROTOCOL;
		pvminfo[1] = myhostpart + ptypepart;
		pvminfo[2] = ptid;
		pvminfo[3] = MAXFRAGSIZE;
		pvminfo[4] = myndf;
		if (sockconn(sock, tp, pvminfo) == -1) {
			err = PvmSysErr;
			task_free(tp);
			goto done;
		}
*/
			if (pvmdebmask & PDMTASK) {
				sprintf(pvmtxt, "mpp_load() %d type=%d ptid=%x t%x...\n",
					count, 0, ptid, myhostpart + ptypepart + sp->n_first + j);
				pvmlogerror(pvmtxt);
			}

		/* create new task structs */

			tp = task_new(myhostpart + ptypepart + sp->n_first + j);
			tp->t_a_out = STRALLOC(name);
			tp->t_ptid = ptid;
			tids[j] = tp->t_tid;
			PVM_FREE(tp->t_txq);
			tp->t_txq = hosttxq;		/* node tasks share pvmhost's txq */
			tp->t_out = hostout;        /* and stdout */
#if 0
			pvmlogprintf( "Setting t%x pid to p%d\n", tp->t_tid, hostpid );
#endif
			tp->t_pid = hostpid;		/* pvm_kill should kill pvmhost */
			tp->t_outtid = wxp->w_outtid;  /* catch stdout/stderr  */
			tp->t_outtag = wxp->w_outtag; 
			tp->t_outctx = wxp->w_outctx; 
		}
		return 0;
	}
    if (pvmdebmask & PDMTASK) {
        sprintf(pvmtxt, "mpp_load() didn't find <%s>\n", name);
        pvmlogerror(pvmtxt);
    }
    err = PvmNoFile;

done:
	for (j = 0; j < count; j++)
		tids[j] = err;
	return err;
}

/* Find task by socket address */

struct task *mpp_find( tp )
	struct task	*tp;
{
	int			i;
	struct task	*nodetp = 0;
	int			ptypepart;

	for (i = 0; i < partsize; i++)
		if (nodeaddr[i] == tp->t_sad.sin_addr.s_addr)
			{
			ptypepart = (0 << (ffs(tidtmask) - 1)) | TIDONNODE;
			sprintf(pvmtxt, "mpp_find looking for t%x\n", myhostpart + ptypepart + i);
			pvmlogerror(pvmtxt);
			if (nodetp = task_find( myhostpart + ptypepart + i ))
				break;	/* found match */
			}
	if (!nodetp)
		pvmlogerror( "mpp_find:  Task not found\n" );
	return nodetp;
}	/* mpp_find() */


/*
 * Add pvmhost's socket to wfds if there are packets waiting to
 * be sent to a related node task. Node tasks have no sockets;
 * they share pvmhost's packet queue (txq). Pvmhost simply
 * forwards any packets it receives to the appropriate node.
 */

int
mpp_output(dummy1, dummy2)
	struct task *dummy1;
	struct pkt *dummy2;
{
	struct nodeset *sp, *sp2;
	struct task *tp;
	int ptype;

	sp = busynodes->n_link;
	for (sp = busynodes->n_link; sp != busynodes; sp = sp->n_link)
		if ((tp = task_find(sp->n_ptid))) {
			if (tp->t_txq->pk_link->pk_buf && tp->t_sock != -1)
				wrk_fds_add(tp->t_sock, 2);
		} else {
			if (sp->n_alive) {
				sprintf(pvmtxt, "mpp_output() pvmhost %d died!\n", sp->n_ptype);
				pvmlogerror(pvmtxt);
				/* clean up tasks it serves */
				ptype = sp->n_ptype & ptypemask;
				for (tp = locltasks->t_link; tp != locltasks; tp = tp->t_link)
					if (TIDISNODE(tp->t_tid) && TIDTOTYPE(tp->t_tid) == ptype) {
						tp->t_txq = 0;
						tp = tp->t_rlink;
						task_cleanup(tp->t_link);
						task_free(tp->t_link);
					}
			}
			/* pvmhost has died, destroy the node set */
			sp2 = sp;
			sp = sp->n_rlink;
			LISTDELETE(sp2, n_link, n_rlink);
			PVM_FREE(sp2);
		}
	return 0;
}

