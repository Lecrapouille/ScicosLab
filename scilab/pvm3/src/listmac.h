
/* Id: listmac.h,v 1.2 2008-05-31 06:23:45 jpc Exp $ */

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
 *	Listmac.h
 *
 *	Dll macros.
 *
 * : listmac.h,v $
 * Revision 1.1.1.1  2004/04/26 15:36:58  stochopt
 * Imported sources
 *
 * Revision 1.1.1.1  2003/11/14 13:02:08  stochopt
 * Imported files
 *
 * Revision 1.1.1.1  2003/02/18 09:26:05  stochopt
 * initial
 *
 * Revision 1.1.1.1  2003/02/17 11:25:32  stochopt
 * initial
 *
 * Revision 1.1.1.1  2003/02/03 08:42:11  stochopt
 * imported sources
 *
 * Revision 1.1.1.1  2003/01/06 09:04:12  stochopt
 * Imported sources
 *
 * Revision 1.1.1.1  2002/12/19 17:37:37  stochopt
 * start
 *
 * Revision 1.2  2002/10/14 14:37:46  chanceli
 * update
 *
 * Revision 1.5  1999/07/08 19:00:21  kohl
 * Fixed "Log" keyword placement.
 * 	- indent with " * " for new CVS.
 *
 * Revision 1.4  1997/06/25  22:08:49  pvmsrc
 * Markus adds his frigging name to the author list of
 * 	every file he ever looked at...
 *
 * Revision 1.3  1997/04/09  14:39:33  pvmsrc
 * PVM patches from the base 3.3.10 to 3.3.11 versions where applicable.
 * Originals by Bob Manchek. Altered by Graham Fagg where required.
 *
 * Revision 1.2  1997/01/28  19:27:57  pvmsrc
 * New Copyright Notice & Authors.
 *
 * Revision 1.1  1996/09/23  23:43:18  pvmsrc
 * Initial revision
 *
 * Revision 1.3  1996/05/13  20:27:36  manchek/GEF
 * added a few parens in LISTPUTAFTER, LISTPUTBEFORE
 * for picky (old) compilers
 *
 * Revision 1.2  1994/06/03  20:38:15  manchek
 * version 3.3.0
 *
 * Revision 1.1  1993/08/30  23:26:48  manchek
 * Initial revision
 *
 */

#define	LISTPUTAFTER(o,n,f,r)	{ (n)->f=(o)->f; (n)->r=(o); (o)->f->r=(n); (o)->f=(n); }
#define	LISTPUTBEFORE(o,n,f,r)	{ (n)->r=(o)->r; (n)->f=(o); (o)->r->f=(n); (o)->r=(n); }
#define	LISTDELETE(e,f,r)	{ (e)->f->r=(e)->r; (e)->r->f=(e)->f; (e)->r=(e)->f=0; }

#define	LISTFIRST(h,f)		((h)->f == (h) ? 0 : (h)->f)
#define	LISTNEXT(p,h,f)		((p)->f == (h) ? 0 : (p)->f)
#define	FORLIST(p,h,f)		for ((p) = (h)->f; (p) != (h); (p) = (p)->f)

