#include <stdlib.h>
#include <string.h>

#ifdef __STDC__
#include <stdarg.h>
#else
#include <varargs.h>
#endif

#include "../machine.h"
#include "../os_specific/link.h"
#include "scicos.h"
#include "import.h"
#if WIN32
#include "blocks-vc.h"
#else
#include "blocks.h"
#endif
#include <math.h>
#include "../graphics/Math.h"
#include "../os_specific/sci_mem_alloc.h"

#include "sundials/cvode.h"	/* prototypes for CVODES fcts. and consts. */
#include "sundials/cvode_dense.h"	/* prototype for CVDense */
#include "sundials/ida.h"
#include "sundials/ida_dense.h"
#include "sundials/nvector_serial.h"	/* serial N_Vector types, fcts., and macros */
#include "sundials/sundials_dense.h"	/* definitions DenseMat and DENSE_ELEM */
#include "sundials/sundials_types.h"	/* definition of type realtype */
#include "sundials/sundials_math.h"
#include "sundials/ida_impl.h"
#include "sundials/kinsol.h"
#include "sundials/kinsol_dense.h"
#include "sundials/dopri5m.h"

#define params_curblk  C2F(curblk).kfun
#define params_deltat  *(scs_imp->deltat)
#define params_halt  C2F(coshlt).halt
#define params_hmax  *(scs_imp->hmax)
#define params_solver  C2F(cmsolver).solver
#define sim_clkptr scs_imp->clkptr
#define sim_cord  scs_imp->cord
#define sim_critev  scs_imp->critev
#define sim_evtspt  scs_imp->evtspt
#define sim_funtyp  scs_imp->funtyp
#define sim_g scs_imp->g
#define sim_inplnk  scs_imp->inplnk
#define sim_inpptr  scs_imp->inpptr
#define sim_iord   scs_imp->iord
#define sim_nblk *(scs_imp->nblk)
#define sim_ncord  *(scs_imp->ncord)
#define sim_ng  *(scs_imp->ng)
#define sim_niord  *(scs_imp->niord)
#define sim_noord  *(scs_imp->noord)
#define sim_nordclk *(scs_imp->nordclk)
#define sim_oord  scs_imp->oord
#define sim_ordclk scs_imp->ordclk
#define sim_outtbptr  scs_imp->outtbptr
#define sim_outtbsz  scs_imp->outtbsz
#define sim_outtbtyp  scs_imp->outtbtyp
#define sim_pointi  scs_imp->pointi
#define sim_tevts  scs_imp->tevts
#define sim_x scs_imp->x
#define sim_xd scs_imp->xd
#define sim_xprop  scs_imp->xprop
#define sim_xptr  scs_imp->xptr
#define sim_zcptr  scs_imp->zcptr
#define sim_iwa  scs_imp->iwa
#define sim_nx  *(scs_imp->nx)
#define sim_ordptr scs_imp->ordptr
#define sim_nzord *(scs_imp->nzord)
#define sim_zord scs_imp->zord
#define sim_nmod *(scs_imp->nmod)
#define sim_nlnk *(scs_imp->nlnk)
#define sim_mod scs_imp->mod

ScicosImport *scs_imp = NULL;

#include "ezxml.h"

typedef struct
{
  void *ida_mem;
  N_Vector ewt;
  double *rwork;
  int *iwork;
  double *gwork;		/* just added for a very special use: a
				   space passing to grblkdakr for zero crossing surfaces
				   when updating mode variables during initialization */
} *User_IDA_data;

typedef struct
{
  void *cvode_mem;
} *User_CV_data;


typedef struct
{
  double *rwork;
  double *uscale;
} *User_KIN_data;


#ifdef FORDLL
#define IMPORT  __declspec (dllimport)
#else
#define IMPORT extern
#endif

#define SUNDIALS_ONE   RCONST(1.0)
#define SUNDIALS_ZERO  RCONST(0.0)
#define T0    RCONST(0.0)

extern int C2F (intdy) ();

static int check_flag (void *flagvalue, char *funcname, int opt);
void cosini (double *);
void cosend (double *);
void cossimdaskr (double *);
void cossim (double *);
void callf (double *t, scicos_block * block, int *flag);
int C2F (simblk) (int *, double *, double *, double *);
int C2F (grblk) (int *, double *, double *, int *, double *);
int CVsimblk (realtype t, N_Vector yy, N_Vector yp, void *f_data);
void DP5simblk (unsigned n, double t, double *x, double *y, void *udata);
int DP5grblk (unsigned n, double t, double *xc, double *g, void *udata);
int simblkdaskr (realtype tres, N_Vector yy, N_Vector yp, N_Vector resval,void *rdata);
int CVgrblk (realtype t, N_Vector yy, realtype * gout, void *g_data);
int grblkdaskr (realtype t, N_Vector yy, N_Vector yp, realtype * gout,void *g_data);
static int simblkKinsol (N_Vector, N_Vector, void *);
void rmevs (int *, int *);
void addevs (double, int *, int *);
void putevs (double *, int *, int *);
void idoit (double *);
void cdoit (double *);
void doit (double *);
void ddoit (double *);
void edoit (double *, int *);
void odoit (double *, double *, double *, double *);
void ozdoit (double *, double *, double *, int *);
void zdoit (double *, double *, double *, double *);
void Jdoit (double *, double *, double *, double *, int *);	/* Jacobian */
void reinitdoit (double *);
void FREE_blocks(void);
int synchro_nev (int, int *);
int synchro_g_nev (double *, int, int *);

int Jacobians (long int Neq, realtype, N_Vector, N_Vector, N_Vector,
	       realtype, void *, DenseMat, N_Vector, N_Vector, N_Vector);
int KinJacobians0 (long int, DenseMat, N_Vector, N_Vector, void *, N_Vector,
		   N_Vector);
int KinJacobians1 (long int, DenseMat, N_Vector, N_Vector, void *, N_Vector,
		   N_Vector);

static void Multp (double *, double *, double *, int, int, int, int);
void Set_Jacobian_flag (int flag);
double Get_Jacobian_parameter (void);
double Get_Scicos_SQUR (void);
int read_xml_initial_states (int, const char *, char **, double *);
static int read_id (ezxml_t *, char *, double *);
int write_xml_states (int, const char *, char **, double *);
int Convert_number (char *, double *);
void homotopy (double *);
int rhojac_ (double *, double *, double *, double *, int *, double *, int *);
int rho_ (double *, double *, double *, double *, double *, int *);
int fx_ (double *, double *);
int hfjac_ (double *, double *, int *);
static int CallKinsol (double *);
/* utilities used in blocks */
double pow_ (double, double);
double exp_ (double);
double log_ (double);

IMPORT struct
{
  int cosd;
} C2F (cosdebug);

IMPORT struct
{
  int counter;
} C2F (cosdebugcounter);

extern void F2C (sciblk) ();
extern void sciblk2 ();
extern void sciblk4 ();
extern void GetDynFunc ();
extern void C2F (iislink) ();
extern int C2F (cvstr) ();
extern int C2F (dset) ();
extern int C2F (dcopy) ();
extern int C2F (iset) ();
extern int C2F (realtime) ();
extern int C2F (realtimeinit) ();
extern int C2F (sxevents) ();
extern int C2F (stimer) ();
extern int C2F (xscion) ();
extern int C2F (lsodar2) ();
extern int scilab_timer_check ();
extern ScicosImport *getscicosimportptr (void);
extern void call_debug_scicos (scicos_block * block, int *flag, int flagi, int deb_blk);

static int *neq;
static double params_Atol, params_rtol, params_ttol;
static int params_hot;

extern struct
{
  int iero;
} C2F (ierode);

extern struct
{
  int kfun;
} C2F (curblk);

extern struct
{
  int halt;
} C2F (coshlt);

extern struct
{
  char buf[4096];
} coserr;

extern struct
{
  int callerid;
} C2F (lscallerid);

struct
{
  double scale;
} C2F (rtfactor);

struct
{
  int solver;
} C2F (cmsolver);

/* Table of constant values */

static int *ierr;
static double *t0, *tf;

SCSREAL_COP *outtbdptr;		/*to store double of outtb */
SCSINT8_COP *outtbcptr;		/*to store int8 of outtb */
SCSINT16_COP *outtbsptr;	/*to store int16 of outtb */
SCSINT32_COP *outtblptr;	/*to store int32 of outtb */
SCSUINT8_COP *outtbucptr;	/*to store unsigned int8 of outtb */
SCSUINT16_COP *outtbusptr;	/*to store unsigned int16 of outtb */
SCSUINT32_COP *outtbulptr;	/*to store unsigned int32 of outtb */

static outtb_el *outtb_elem;
static int nelem;
static scicos_block *Blocks;

/* xproperty: sim_alpha and  *sim_beta should be added in sim structure */
static double *sim_alpha, *sim_beta;

/* pass to external variable for code generation */
/* reserved variable name */

int *block_error;
double scicos_time;
int phase;
int Jacobian_Flag;
double CI, CJ;
double SQuround;
int Sfcallerid;

static int AJacobian_block;

static int debug_block;

/* Subroutine */
int C2F (scicos) (double *x_in, int * xptr_in, double *z__,
		  void **work, int * zptr, int * modptr_in,
		  void **oz, int * ozsz, int * oztyp, int * ozptr,
		  int * iz, int * izptr, double *t0_in,
		  double *tf_in, double *tevts_in, int * evtspt_in,
		  int * nevts, int * pointi_in, void **outtbptr_in,
		  int * outtbsz_in, int * outtbtyp_in,
		  outtb_el * outtb_elem_in, int * nelem1, int * nlnk1,
		  int * funptr, int * funtyp_in, int * inpptr_in,
		  int * outptr_in, int * inplnk_in,
		  int * outlnk_in, double *rpar, int * rpptr,
		  int * ipar, int * ipptr, void **opar,
		  int * oparsz, int * opartyp, int * opptr,
		  int * clkptr_in, int * ordptr_in,
		  int * nordptr1, int * ordclk_in, int * cord_in,
		  int * ncord1, int * iord_in, int * niord1,
		  int * oord_in, int * noord1, int * zord_in,
		  int * nzord1, int * critev_in, int * nblk1,
		  int * ztyp, int * zcptr_in, int * subscr,
		  int * nsubs, double *simpar, int * flag__,
		  int * ierr_out)
{
  int *iwa = NULL;
  double *xsim_x, *xsim_xd, *xsim_g;
  int nordclk, nx;
  int *outtbsz;	/*size of object of outtb */
  void **outtbptr;		/*pointer array of object of outtb */
  int *outtbtyp;	/*type of object of outtb */
  int *zcptr, *xptr, *evtspt, *clkptr, *iord, *funtyp, *inpptr, *outptr, *critev, *ordclk, *xprop, *pointi;
  int *cord, *ordptr, *zord, *oord, *inplnk, *modptr, *outlnk, *mod;
  int i1, kf, in, out, job = 1;
  int nblk, xsim_ng, ncord, nmod, nordptr, noord, niord, nzord, nlnk;
  double hmax, deltat;
  double *tevts;
  
  extern int C2F (msgs) ();
  extern int C2F (getscsmax) ();

  extern int C2F (makescicosimport) ();
  extern int C2F (clearscicosimport) ();

  static int mxtb, ierr0, kfun0, i, j, k;
  static int ni, no;
  static int nz, noz, nopar;
  double *W;

  /*     Copyright INRIA */
  /* iz,izptr are used to pass block labels */

  t0 = t0_in;
  tf = tf_in;
  ierr = ierr_out;

  /* Parameter adjustments */
  pointi = pointi_in;
  xsim_x = x_in;
  xptr = xptr_in - 1;
  modptr = modptr_in - 1;
  --zptr;
  --izptr;
  --ozptr;
  evtspt = evtspt_in - 1;
  tevts = tevts_in - 1;
  outtbptr = outtbptr_in;
  outtbsz = outtbsz_in;
  outtbtyp = outtbtyp_in;
  outtb_elem = outtb_elem_in;
  funtyp = funtyp_in - 1;
  inpptr = inpptr_in - 1;
  outptr = outptr_in - 1;
  inplnk = inplnk_in - 1;
  outlnk = outlnk_in - 1;
  --rpptr;
  --ipptr;
  --opptr;
  clkptr = clkptr_in - 1;
  ordptr = ordptr_in - 1;
  ordclk = ordclk_in - 1;
  cord = cord_in - 1;
  iord = iord_in - 1;
  oord = oord_in - 1;
  zord = zord_in - 1;

  critev = critev_in - 1;
  --ztyp;
  zcptr = zcptr_in - 1;
  --simpar;

  /* Function Body */
  params_Atol = simpar[1];
  params_rtol = simpar[2];
  params_ttol = simpar[3];
  deltat = simpar[4];
  C2F (rtfactor).scale = simpar[5];
  params_solver = (int) simpar[6];
  hmax = simpar[7];

  nordptr = *nordptr1;
  nblk = *nblk1;
  ncord = *ncord1;
  noord = *noord1;
  nzord = *nzord1;
  niord = *niord1;
  nlnk = *nlnk1;
  nelem = *nelem1;
  *ierr = 0;

  nordclk = ordptr[nordptr] - 1;	/* number of rows in ordclk is ordptr(nclkp1)-1 */
  xsim_ng = zcptr[nblk + 1] - 1;	/* computes number of zero crossing surfaces */
  nmod = modptr[nblk + 1] - 1;	/* computes number of modes */
  nz = zptr[nblk + 1] - 1;	/* number of discrete real states */
  noz = ozptr[nblk + 1] - 1;	/* number of discrete object states */
  nopar = opptr[nblk + 1] - 1;	/* number of object parameters */
  nx = xptr[nblk + 1] - 1;	/* number of object parameters */
  neq = &nx;

  /* the fields are filled when calling makescicosimport, but 
   * we may need some of them before
   */

  scs_imp = getscicosimportptr ();
  scs_imp->nblk = &nblk;/* FREE_blocks can be called before makescicosimport */
  
  xsim_xd = &xsim_x[xptr[nblk + 1] - 1];

  for (i = 1; i <= nblk; ++i)
    {
      if (funtyp[i] < 10000)
	{
	  funtyp[i] %= 1000;
	}
      else
	{
	  funtyp[i] = funtyp[i] % 1000 + 10000;
	}
      ni = inpptr[i + 1] - inpptr[i];
      no = outptr[i + 1] - outptr[i];
      if (funtyp[i] == 1)
	{
	  if (ni + no > 11)
	    {
	      /*     hard coded maxsize in callf.c */
	      int c__90 = 90, c0= 0;
	      C2F (msgs) (&c__90, &c0);
	      params_curblk = i;
	      *ierr = i + 1005;
	      return 0;
	    }
	}
      else if (funtyp[i] == 2 || funtyp[i] == 3)
	{
	  /*     hard coded maxsize in scicos.h */
	  if (ni + no > SZ_SIZE)
	    {
	      int c__90 = 90, c0=0;
	      C2F (msgs) (&c__90, &c0);
	      params_curblk = i;
	      *ierr = i + 1005;
	      return 0;
	    }
	}
      mxtb = 0;
      if (funtyp[i] == 0)
	{
	  if (ni > 1)
	    {
	      for (j = 1; j <= ni; ++j)
		{
		  k = inplnk[inpptr[i] - 1 + j];
		  mxtb += (outtbsz[k - 1] * outtbsz[k - 1 + nlnk]);
		}
	    }
	  if (no > 1)
	    {
	      for (j = 1; j <= no; ++j)
		{
		  k = outlnk[outptr[i] - 1 + j];
		  mxtb += (outtbsz[k - 1] * outtbsz[k - 1 + nlnk]);
		}
	    }
	  if (mxtb > TB_SIZE)
	    {
	      int c__91 = 91, c0=0;
	      C2F (msgs) (&c__91, &c0);
	      params_curblk = i;
	      *ierr = i + 1005;
	      return 0;
	    }
	}
    }

  if (nx > 0)
    {				/* xprop */
      if ((xprop =
	   (int *) MALLOC (sizeof (int) * nx + sizeof (double) * nx * 2)) ==
	  NULL)
	{
	  *ierr = 5;
	  return 0;
	}
      sim_alpha = (double *) (xprop + nx);
      sim_beta = (double *) (sim_alpha + nx);
    }
  for (i = 0; i < nx; i++)
    {				/* initialize */
      xprop[i] = 1;
    }
  if (nmod > 0)
    {				/* mod */
      if ((mod = MALLOC (sizeof (int) * nmod)) == NULL)
	{
	  *ierr = 5;
	  if (nx > 0)
	    FREE (xprop);
	  return 0;
	}
    }
  if (xsim_ng > 0)
    {				/* g becomes global */
      if ((xsim_g = MALLOC (sizeof (double) * xsim_ng)) == NULL)
	{
	  *ierr = 5;
	  if (nmod > 0)
	    FREE (mod);
	  if (nx > 0)
	    FREE (xprop);
	  return 0;
	}
    }

  debug_block = -1;		/* no debug block for start */
  C2F (cosdebugcounter).counter = 0;

  if ((Blocks = MALLOC (sizeof (scicos_block) * nblk)) == NULL)
    {
      *ierr = 5;
      if (nx > 0)
	FREE (xprop);
      if (nmod > 0)
	FREE (mod);
      if (xsim_ng > 0)
	FREE (xsim_g);
      return 0;
    }

  for (kf = 0; kf < nblk; ++kf)
    {
      params_curblk = kf + 1;
      i = funptr[kf];
      Blocks[kf].type = funtyp[kf + 1];
      if (i < 0)
	{
	  switch (funtyp[kf + 1])
	    {
	    case 0:
	      Blocks[kf].funpt = F2C (sciblk);
	      break;
	    case 1:
	      sciprint ("type 1 function not allowed for scilab blocks\r\n");
	      *ierr = 1000 + kf + 1;
	      FREE_blocks ();
	      return 0;
	    case 2:
	      sciprint ("type 2 function not allowed for scilab blocks\r\n");
	      *ierr = 1000 + kf + 1;
	      FREE_blocks ();
	      return 0;
	    case 3:
	      Blocks[kf].funpt = sciblk2;
	      Blocks[kf].type = 2;
	      break;
	    case 5:
	      Blocks[kf].funpt = sciblk4;
	      Blocks[kf].type = 4;
	      break;
	    case 99:		/* debugging block */
	      Blocks[kf].funpt = sciblk4;
	      /*Blocks[kf].type=4; */
	      debug_block = kf;
	      break;

	    case 10005:
	      Blocks[kf].funpt = sciblk4;
	      Blocks[kf].type = 10004;
	      break;
	    default:
	      sciprint ("Undefined Function type\r\n");
	      *ierr = 1000 + kf + 1;
	      FREE_blocks ();
	      return 0;
	    }
	  Blocks[kf].scsptr = -i;	/* set scilab function adress for sciblk */
	}
      else if (i <= ntabsim)
	{
	  Blocks[kf].funpt = *(tabsim[i - 1].fonc);
	  Blocks[kf].scsptr = 0;	/* this is done for being able to test if a block
					   is a scilab block in the debugging phase when 
					   sciblk4 is called */
	}
      else
	{
	  i -= (ntabsim + 1);
	  GetDynFunc (i, &Blocks[kf].funpt);
	  if (Blocks[kf].funpt == (voidf) 0)
	    {
	      sciprint ("Function not found\r\n");
	      *ierr = 1000 + kf + 1;
	      FREE_blocks ();
	      return 0;
	    }
	  Blocks[kf].scsptr = 0;	/* this is done for being able to test if a block
					   is a scilab block in the debugging phase when 
					   sciblk4 is called */
	}

      Blocks[kf].ztyp = ztyp[kf + 1];
      Blocks[kf].nx = xptr[kf + 2] - xptr[kf + 1];
      Blocks[kf].ng = zcptr[kf + 2] - zcptr[kf + 1];
      Blocks[kf].nz = zptr[kf + 2] - zptr[kf + 1];
      Blocks[kf].noz = ozptr[kf + 2] - ozptr[kf + 1];
      Blocks[kf].nrpar = rpptr[kf + 2] - rpptr[kf + 1];
      Blocks[kf].nipar = ipptr[kf + 2] - ipptr[kf + 1];
      Blocks[kf].nopar = opptr[kf + 2] - opptr[kf + 1];
      /* number of input ports */
      Blocks[kf].nin = inpptr[kf + 2] - inpptr[kf + 1];
      /* number of output ports */
      Blocks[kf].nout = outptr[kf + 2] - outptr[kf + 1];	

      /* in insz, we store :
       *  - insz[0..nin-1] : first dimension of input ports
       *  - insz[nin..2*nin-1] : second dimension of input ports
       *  - insz[2*nin..3*nin-1] : type of data of input ports
       */
      Blocks[kf].insz = NULL;
      Blocks[kf].inptr = NULL;
      if (Blocks[kf].nin != 0)
	{
	  Blocks[kf].insz = MALLOC (Blocks[kf].nin * 3 * sizeof (int));
	  Blocks[kf].inptr = MALLOC (Blocks[kf].nin * sizeof (double *));
	  
	  if ( Blocks[kf].insz == NULL || Blocks[kf].inptr == NULL)
	    {
	      FREE_blocks ();
	      *ierr = 5;
	      return 0;
	    }
	
	  for (in = 0; in < Blocks[kf].nin; in++)
	    {
	      int lprt = inplnk[inpptr[kf + 1] + in];
	      Blocks[kf].inptr[in] = outtbptr[lprt - 1];
	      Blocks[kf].insz[in] = outtbsz[lprt - 1];
	      Blocks[kf].insz[Blocks[kf].nin + in] = outtbsz[(lprt - 1) + nlnk];
	      Blocks[kf].insz[2 * Blocks[kf].nin + in] = outtbtyp[lprt - 1];
	    }
	}

      /* in outsz, we store :
       *  - outsz[0..nout-1] : first dimension of output ports
       *  - outsz[nout..2*nout-1] : second dimension of output ports
       *  - outsz[2*nout..3*nout-1] : type of data of output ports
       */
      Blocks[kf].outsz = NULL;
      Blocks[kf].outptr = NULL;
      if (Blocks[kf].nout != 0)
	{
	  Blocks[kf].outsz = MALLOC (Blocks[kf].nout * 3 * sizeof (int));
	  Blocks[kf].outptr =MALLOC (Blocks[kf].nout * sizeof (double *));
	  if ( Blocks[kf].outsz == NULL || Blocks[kf].outptr == NULL )
	    {
	      FREE_blocks ();
	      *ierr = 5;
	      return 0;
	    }
	  
	  for (out = 0; out < Blocks[kf].nout; out++)
	    {
	      int lprt = outlnk[outptr[kf + 1] + out];
	      Blocks[kf].outptr[out] = outtbptr[lprt - 1];
	      Blocks[kf].outsz[out] = outtbsz[lprt - 1];
	      Blocks[kf].outsz[Blocks[kf].nout + out] = outtbsz[lprt - 1 + nlnk];
	      Blocks[kf].outsz[2 * Blocks[kf].nout + out] = outtbtyp[lprt - 1];
	    }
	}
      
      /* evtout */
      Blocks[kf].nevout = clkptr[kf + 2] - clkptr[kf + 1];
      Blocks[kf].evout = NULL;
      if (Blocks[kf].nevout != 0)
	{
	  if ((Blocks[kf].evout = CALLOC (Blocks[kf].nevout, sizeof (double))) == NULL)
	    {
	      FREE_blocks ();
	      *ierr = 5;
	      return 0;
	    }
	}

      /* z */
      Blocks[kf].z = &(z__[zptr[kf + 1] - 1]);

      /* oz */
      Blocks[kf].ozsz = NULL;
      if (Blocks[kf].noz == 0)
	{
	  Blocks[kf].ozptr = NULL;
	  Blocks[kf].oztyp = NULL;
	}
      else
	{
	  Blocks[kf].ozptr = &(oz[ozptr[kf + 1] - 1]);
	  if ((Blocks[kf].ozsz = MALLOC (Blocks[kf].noz * 2 * sizeof (int))) == NULL)
	    {
	      FREE_blocks ();
	      *ierr = 5;
	      return 0;
	    }
	  for (i = 0; i < Blocks[kf].noz; i++)
	    {
	      Blocks[kf].ozsz[i] = ozsz[(ozptr[kf + 1] - 1) + i];
	      Blocks[kf].ozsz[i + Blocks[kf].noz] =
		ozsz[(ozptr[kf + 1] - 1 + noz) + i];
	    }
	  Blocks[kf].oztyp = &(oztyp[ozptr[kf + 1] - 1]);
	}


      Blocks[kf].rpar = &(rpar[rpptr[kf + 1] - 1]);
      Blocks[kf].ipar = &(ipar[ipptr[kf + 1] - 1]);

      /* opar */
      Blocks[kf].oparsz = NULL;
      if (Blocks[kf].nopar == 0)
	{
	  Blocks[kf].oparptr = NULL;
	  Blocks[kf].opartyp = NULL;
	}
      else
	{
	  Blocks[kf].oparptr = &(opar[opptr[kf + 1] - 1]);
	  if ((Blocks[kf].oparsz =
	       MALLOC (Blocks[kf].nopar * 2 * sizeof (int))) == NULL)
	    {
	      FREE_blocks ();
	      *ierr = 5;
	      return 0;
	    }
	  for (i = 0; i < Blocks[kf].nopar; i++)
	    {
	      Blocks[kf].oparsz[i] = oparsz[(opptr[kf + 1] - 1) + i];
	      Blocks[kf].oparsz[i + Blocks[kf].nopar] =
		oparsz[(opptr[kf + 1] - 1 + nopar) + i];
	    }
	  Blocks[kf].opartyp = &(opartyp[opptr[kf + 1] - 1]);
	}

      /* res */
      Blocks[kf].res = NULL;
      if (Blocks[kf].nx != 0)
	{
	  if ((Blocks[kf].res =
	       MALLOC (Blocks[kf].nx * sizeof (double))) == NULL)
	    {
	      FREE_blocks ();
	      *ierr = 5;
	      return 0;
	    }
	}

      /* label */
      i1 = izptr[kf + 2] - izptr[kf + 1];
      if ((Blocks[kf].label = MALLOC (sizeof (char) * (i1 + 1))) == NULL)
	{
	  FREE_blocks ();
	  *ierr = 5;
	  return 0;
	}
      Blocks[kf].label[i1] = '\0';
      C2F (cvstr) (&i1, &(iz[izptr[kf + 1] - 1]), Blocks[kf].label, &job, i1);

      /* jroot */
      Blocks[kf].jroot = NULL;
      if (Blocks[kf].ng != 0)
	{
	  if ((Blocks[kf].jroot =
	       CALLOC (Blocks[kf].ng, sizeof (int))) == NULL)
	    {
	      FREE_blocks ();
	      *ierr = 5;
	      return 0;
	    }
	}

      /* work */
      Blocks[kf].work = (void **) (((double *) work) + kf);

      /* mode */
      Blocks[kf].nmode = modptr[kf + 2] - modptr[kf + 1];
      if (Blocks[kf].nmode != 0)
	{
	  Blocks[kf].mode = &(mod[modptr[kf + 1] - 1]);
	}

      /* xprop */
      Blocks[kf].xprop = NULL;
      Blocks[kf].alpha = NULL;
      Blocks[kf].alpha = NULL;
      if (Blocks[kf].nx != 0)
	{
	  Blocks[kf].xprop = &(xprop[xptr[kf + 1] - 1]);
	  Blocks[kf].alpha = &(sim_alpha[xptr[kf + 1] - 1]);
	  Blocks[kf].beta = &(sim_beta[xptr[kf + 1] - 1]);
	}

      /* g */
      Blocks[kf].g = NULL;
      if (Blocks[kf].ng != 0)
	{
	  Blocks[kf].g = &(xsim_g[zcptr[kf + 1] - 1]);
	}
    }

  if ((*nevts) != 0)
    {
      if ((iwa = MALLOC (sizeof (int) * (*nevts))) == NULL)
	{
	  FREE_blocks ();
	  *ierr = 5;
	  return 0;
	}
    }

  /* save ptr of scicos in import structure */
  C2F (makescicosimport) (xsim_x, &nx, &xptr[1], &zcptr[1], z__, &nz, &zptr[1],
			  &noz, oz, ozsz, oztyp, &ozptr[1],
			  xsim_g, &xsim_ng, mod, &nmod, &modptr[1], iz, &izptr[1],
			  &inpptr[1], &inplnk[1], &outptr[1], &outlnk[1],
			  outtbptr, outtbsz, outtbtyp,
			  outtb_elem, &nelem,
			  &nlnk, rpar, &rpptr[1], ipar, &ipptr[1],
			  opar, oparsz, opartyp, &opptr[1],
			  &nblk, subscr, nsubs,
			  &tevts[1], &evtspt[1], nevts, pointi,
			  &iord[1], &niord, &oord[1], &noord, &zord[1],
			  &nzord, funptr, &funtyp[1], &ztyp[1], &cord[1],
			  &ncord, &ordclk[1], &nordclk, &clkptr[1],
			  &ordptr[1], &nordptr, &critev[1], iwa, Blocks, t0,
			  tf, &params_Atol, &params_rtol, &params_ttol, &deltat, &hmax, xprop, xsim_xd);
    
  if (*flag__ == 1)
    {
      /* blocks initialization */
      for (kf = 0; kf < sim_nblk; ++kf)
	{
	  *(Blocks[kf].work) = NULL;
	}
      phase = 1;
      cosini (t0);
      if (*ierr != 0)
	{
	  ierr0 = *ierr;
	  kfun0 = params_curblk;
	  cosend (t0);
	  *ierr = ierr0;
	  params_curblk = kfun0;
	}
    }
  else if (*flag__ == 2)
    {
      /*     integration */
      phase = 1;
      if (params_solver == 0)
	{
	  /*  Lsodar: Method: BDF,   Nonlinear solver= NEWTON     */
	  cossim (t0);
	}
      else if (params_solver == 1)
	{
	  /*  CVODE: Method: BDF,   Nonlinear solver= FUNCTIONAL */
	  cossim (t0);
	}
      else if (params_solver == 2)
	{
	  /*  CVODE: Method: BDF,   Nonlinear solver= FUNCTIONAL */
	  cossim (t0);
	}
      else if (params_solver == 3)
	{
	  /*  CVODE: Method: ADAMS, Nonlinear solver= NEWTON     */
	  cossim (t0);
	}
      else if (params_solver == 4)
	{
	  /*  CVODE: Method: ADAMS, Nonlinear solver= FUNCTIONAL */
	  cossim (t0);
	}
      else if (params_solver == 5)
	{
	  /*  CVODE: Method: ADAMS, Nonlinear solver= FUNCTIONAL */
	  cossim (t0);
	}
      else if (params_solver == 100)
	{
	  /* IDA  : Method:       , Nonlinear solver=  */
	  cossimdaskr (t0);
	}
      else
	{
	  /*     add a warning message please */
	}
      if (*ierr != 0)
	{
	  ierr0 = *ierr;
	  kfun0 = params_curblk;
	  phase = 1;
	  cosend (t0);
	  *ierr = ierr0;
	  params_curblk = kfun0;
	}
    }
  else if (*flag__ == 3)
    {
      /* finish:  closing the blocks  */
      phase = 1;
      cosend (t0);
    }
  else if (*flag__ == 4)
    {
      /* linear */
      int jj;
      phase = 2;
      idoit (t0);
      if (*ierr == 0)
	{
	  if ((W = MALLOC (sizeof (double) * (Max (sim_nx, sim_ng)))) == NULL)
	    {
	      FREE (sim_iwa);
	      FREE_blocks ();
	      *ierr = 5;
	      return 0;
	    }
	  if (sim_ng > 0 && sim_nmod > 0)
	    {
	      /* updating modes as a function of state values; this was necessary in iGUI */
	      zdoit (t0, sim_x, sim_x + sim_nx, W);
	    }
	  for (jj = 0; jj < sim_nx; jj++)
	    W[jj] = 0.0;
	  C2F (ierode).iero = 0;
	  *ierr = 0;
	  if (params_solver < 100)
	    {
	      odoit (t0, sim_x, W, W);
	    }
	  else
	    {
	      odoit (t0, sim_x, sim_x + sim_nx, W);
	    }
	  C2F (ierode).iero = *ierr;
	  /*-----------------------------------------*/
	  for (i = 0; i < sim_nx; ++i)
	    {
	      sim_x[i] = W[i];
	    }
	  FREE (W);
	}
    }
  else if (*flag__ == 5)
    {
      /* initial_KINSOL= "Kinsol" */
      C2F (ierode).iero = 0;
      *ierr = 0;
      idoit (t0);
      CallKinsol (t0);
      *ierr = C2F (ierode).iero;
    }
  FREE (iwa);
  FREE_blocks ();
  C2F (clearscicosimport) ();
  return 0;
}

/* check_flag */

static int check_flag (void *flagvalue, char *funcname, int opt)
{
  int *errflag;
  /* Check if SUNDIALS function returned NULL pointer - no memory allocated */
  if (opt == 0 && flagvalue == NULL)
    {
      sciprint ("\nSUNDIALS_ERROR: %s() failed - returned NULL pointer\n\n",funcname);
      return (1);
    }
  /* Check if flag < 0 */
  else if (opt == 1)
    {
      errflag = (int *) flagvalue;
      if (*errflag < 0)
	{
	  sciprint ("\nSUNDIALS_ERROR: %s() failed with flag = %d\n\n",funcname, *errflag);
	  return (1);
	}
    }
  /* Check if function returned NULL pointer - no memory allocated */
  else if (opt == 2 && flagvalue == NULL)
    {
      sciprint ("\nMEMORY_ERROR: %s() failed - returned NULL pointer\n\n",funcname);
      return (1);
    }
  return (0);
}

void cosini (double *told)
{
  double c_b14 = 0.;
  int c1 = 1;
  static int flag__;
  static int i;
  static int kfune;
  static int jj;

  SCSREAL_COP *outtbd = NULL;	/*to save double of outtb */
  SCSINT8_COP *outtbc = NULL;	/*to save int8 of outtb */
  SCSINT16_COP *outtbs = NULL;	/*to save int16 of outtb */
  SCSINT32_COP *outtbl = NULL;	/*to save int32 of outtb */
  SCSUINT8_COP *outtbuc = NULL;	/*to save unsigned int8 of outtb */
  SCSUINT16_COP *outtbus = NULL;	/*to save unsigned int16 of outtb */
  SCSUINT32_COP *outtbul = NULL;	/*to save unsigned int32 of outtb */
  int szouttbd = 0;		/*size of arrays */
  int szouttbc = 0, szouttbs = 0, szouttbl = 0;
  int szouttbuc = 0, szouttbus = 0, szouttbul = 0;
  int curouttbd = 0;		/*current position in arrays */
  int curouttbc = 0, curouttbs = 0, curouttbl = 0;
  int curouttbuc = 0, curouttbus = 0, curouttbul = 0;

  int ii, kk;			/*local counters */
  int sszz;			/*local size of element of outtb */

  /*Allocation of arrays for outtb */
  for (ii = 0; ii < sim_nlnk; ii++)
    {
      switch (sim_outtbtyp[ii])
	{
	case SCSREAL_N:
	  szouttbd += sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];	/*double real matrix */
	  outtbd =
	    (SCSREAL_COP *) REALLOC (outtbd, szouttbd * sizeof (SCSREAL_COP));
	  break;

	case SCSCOMPLEX_N:
	  szouttbd += 2 * sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];	/*double complex matrix */
	  outtbd =
	    (SCSCOMPLEX_COP *) REALLOC (outtbd,
					szouttbd * sizeof (SCSCOMPLEX_COP));
	  break;

	case SCSINT8_N:
	  szouttbc += sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];	/*int8 */
	  outtbc =
	    (SCSINT8_COP *) REALLOC (outtbc, szouttbc * sizeof (SCSINT8_COP));
	  break;

	case SCSINT16_N:
	  szouttbs += sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];	/*int16 */
	  outtbs =
	    (SCSINT16_COP *) REALLOC (outtbs,
				      szouttbs * sizeof (SCSINT16_COP));
	  break;

	case SCSINT32_N:
	  szouttbl += sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];	/*int32 */
	  outtbl =
	    (SCSINT32_COP *) REALLOC (outtbl,
				      szouttbl * sizeof (SCSINT32_COP));
	  break;

	case SCSUINT8_N:
	  szouttbuc += sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];	/*uint8 */
	  outtbuc =
	    (SCSUINT8_COP *) REALLOC (outtbuc,
				      szouttbuc * sizeof (SCSUINT8_COP));
	  break;

	case SCSUINT16_N:
	  szouttbus += sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];	/*uint16 */
	  outtbus =
	    (SCSUINT16_COP *) REALLOC (outtbus,
				       szouttbus * sizeof (SCSUINT16_COP));
	  break;

	case SCSUINT32_N:
	  szouttbul += sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];	/*uint32 */
	  outtbul =
	    (SCSUINT32_COP *) REALLOC (outtbul,
				       szouttbul * sizeof (SCSUINT32_COP));
	  break;

	default:		/* Add a message here */
	  break;
	}
    }

  /* Jacobian */
  AJacobian_block = 0;

  /* Function Body */
  *ierr = 0;

  /*     initialization (flag 4) */
  /*     loop on blocks */
  C2F (dset) (&sim_ng, &c_b14, sim_g, &c1);

  for (params_curblk = 1; params_curblk <= sim_nblk; ++params_curblk)
    {
      flag__ = 4;
      if (Blocks[params_curblk - 1].nx > 0)
	{
	  Blocks[params_curblk - 1].x  = &sim_x[sim_xptr[params_curblk - 1] - 1];
	  Blocks[params_curblk - 1].xd = &sim_xd[sim_xptr[params_curblk - 1] - 1];
	}
      Blocks[params_curblk - 1].nevprt = 0;
      if (sim_funtyp[params_curblk - 1] >= 0)
	{
	  /* debug_block is not called here */
	  Jacobian_Flag = 0;
	  callf (told, &Blocks[params_curblk - 1], &flag__);
	  if (flag__ < 0 && *ierr == 0)
	    {
	      *ierr = 5 - flag__;
	      kfune = params_curblk;
	    }
	  if ((Jacobian_Flag == 1) && (AJacobian_block == 0))
	    AJacobian_block = params_curblk;
	}
    }
  if (*ierr != 0)
    {
      params_curblk = kfune;
      goto err;
    }

  /*     initialization (flag 6) */
  flag__ = 6;
  for (jj = 1; jj <= sim_ncord; ++jj)
    {
      params_curblk = sim_cord[jj - 1];
      Blocks[params_curblk - 1].nevprt = 0;
      if (sim_funtyp[params_curblk - 1] >= 0)
	{
	  callf (told, &Blocks[params_curblk - 1], &flag__);
	  if (flag__ < 0)
	    {
	      *ierr = 5 - flag__;
	      goto err;
	    }
	}
    }
  /*     point-fix iterations */
  flag__ = 6;
  for (i = 1; i <= sim_nblk + 1; ++i)
    {
      /*     loop on blocks */
      for (jj = 1; jj <= sim_nblk; ++jj)
	{
	  params_curblk = jj;
	  Blocks[params_curblk - 1].nevprt = 0;
	  if (sim_funtyp[params_curblk - 1] >= 0)
	    {
	      callf (told, &Blocks[params_curblk - 1], &flag__);
	      if (flag__ < 0)
		{
		  *ierr = 5 - flag__;
		  goto err;
		}
	    }
	}
      flag__ = 6;
      for (jj = 1; jj <= sim_ncord; ++jj)
	{
	  /*for each continous block */
	  params_curblk = sim_cord[jj - 1];
	  if (sim_funtyp[params_curblk - 1] >= 0)
	    {
	      callf (told, &Blocks[params_curblk - 1], &flag__);
	      if (flag__ < 0)
		{
		  *ierr = 5 - flag__;
		  goto err;
		}
	    }
	}
      /*comparison between outtb and arrays */
      curouttbd = 0;
      curouttbc = 0;
      curouttbs = 0;
      curouttbl = 0;
      curouttbuc = 0;
      curouttbus = 0;
      curouttbul = 0;
      for (jj = 0; jj < sim_nlnk; jj++)
	{
	  switch (sim_outtbtyp[jj])	/*for each type of ports */
	    {
	    case SCSREAL_N:
	      outtbdptr = (SCSREAL_COP *) sim_outtbptr[jj];	/*double real matrix */
	      sszz = sim_outtbsz[jj] * sim_outtbsz[jj + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		{
		  if (outtbdptr[kk] != (SCSREAL_COP) outtbd[curouttbd + kk])
		    goto L30;
		}
	      curouttbd += sszz;
	      break;

	    case SCSCOMPLEX_N:
	      outtbdptr = (SCSCOMPLEX_COP *) sim_outtbptr[jj];	/*double complex matrix */
	      sszz = 2 * sim_outtbsz[jj] * sim_outtbsz[jj + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		{
		  if (outtbdptr[kk] !=
		      (SCSCOMPLEX_COP) outtbd[curouttbd + kk])
		    goto L30;
		}
	      curouttbd += sszz;
	      break;

	    case SCSINT8_N:
	      outtbcptr = (SCSINT8_COP *) sim_outtbptr[jj];	/*int8 */
	      sszz = sim_outtbsz[jj] * sim_outtbsz[jj + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		{
		  if (outtbcptr[kk] != (SCSINT8_COP) outtbc[curouttbc + kk])
		    goto L30;
		}
	      curouttbc += sszz;
	      break;

	    case SCSINT16_N:
	      outtbsptr = (SCSINT16_COP *) sim_outtbptr[jj];	/*int16 */
	      sszz = sim_outtbsz[jj] * sim_outtbsz[jj + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		{
		  if (outtbsptr[kk] != (SCSINT16_COP) outtbs[curouttbs + kk])
		    goto L30;
		}
	      curouttbs += sszz;
	      break;

	    case SCSINT32_N:
	      outtblptr = (SCSINT32_COP *) sim_outtbptr[jj];	/*int32 */
	      sszz = sim_outtbsz[jj] * sim_outtbsz[jj + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		{
		  if (outtblptr[kk] != (SCSINT32_COP) outtbl[curouttbl + kk])
		    goto L30;
		}
	      curouttbl += sszz;
	      break;

	    case SCSUINT8_N:
	      outtbucptr = (SCSUINT8_COP *) sim_outtbptr[jj];	/*uint8 */
	      sszz = sim_outtbsz[jj] * sim_outtbsz[jj + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		{
		  if (outtbucptr[kk] !=
		      (SCSUINT8_COP) outtbuc[curouttbuc + kk])
		    goto L30;
		}
	      curouttbuc += sszz;
	      break;

	    case SCSUINT16_N:
	      outtbusptr = (SCSUINT16_COP *) sim_outtbptr[jj];	/*uint16 */
	      sszz = sim_outtbsz[jj] * sim_outtbsz[jj + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		{
		  if (outtbusptr[kk] !=
		      (SCSUINT16_COP) outtbus[curouttbus + kk])
		    goto L30;
		}
	      curouttbus += sszz;
	      break;

	    case SCSUINT32_N:
	      outtbulptr = (SCSUINT32_COP *) sim_outtbptr[jj];	/*uint32 */
	      sszz = sim_outtbsz[jj] * sim_outtbsz[jj + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		{
		  if (outtbulptr[kk] !=
		      (SCSUINT32_COP) outtbul[curouttbul + kk])
		    goto L30;
		}
	      curouttbul += sszz;
	      break;

	    default:		/* Add a message here */
	      break;
	    }
	}
      goto err;
      return;

    L30:
      /*Save data of outtb in arrays */
      curouttbd = 0;
      curouttbc = 0;
      curouttbs = 0;
      curouttbl = 0;
      curouttbuc = 0;
      curouttbus = 0;
      curouttbul = 0;
      for (ii = 0; ii < sim_nlnk; ii++)	/*for each link */
	{
	  switch (sim_outtbtyp[ii])	/*switch to type of outtb object */
	    {
	    case SCSREAL_N:
	      outtbdptr = (SCSREAL_COP *) sim_outtbptr[ii];	/*double real matrix */
	      sszz = sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];
	      C2F (dcopy) (&sszz, outtbdptr, &c1, &outtbd[curouttbd], &c1);
	      curouttbd += sszz;
	      break;

	    case SCSCOMPLEX_N:
	      outtbdptr = (SCSCOMPLEX_COP *) sim_outtbptr[ii];	/*double complex matrix */
	      sszz = 2 * sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];
	      C2F (dcopy) (&sszz, outtbdptr, &c1, &outtbd[curouttbd], &c1);
	      curouttbd += sszz;
	      break;

	    case SCSINT8_N:
	      outtbcptr = (SCSINT8_COP *) sim_outtbptr[ii];	/*int8 */
	      sszz = sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		outtbc[curouttbc + kk] = (SCSINT8_COP) outtbcptr[kk];
	      curouttbc += sszz;
	      break;

	    case SCSINT16_N:
	      outtbsptr = (SCSINT16_COP *) sim_outtbptr[ii];	/*int16 */
	      sszz = sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		outtbs[curouttbs + kk] = (SCSINT16_COP) outtbsptr[kk];
	      curouttbs += sszz;
	      break;

	    case SCSINT32_N:
	      outtblptr = (SCSINT32_COP *) sim_outtbptr[ii];	/*int32 */
	      sszz = sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		outtbl[curouttbl + kk] = (SCSINT32_COP) outtblptr[kk];
	      curouttbl += sszz;
	      break;

	    case SCSUINT8_N:
	      outtbucptr = (SCSUINT8_COP *) sim_outtbptr[ii];	/*uint8 */
	      sszz = sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		outtbuc[curouttbuc + kk] = (SCSUINT8_COP) outtbucptr[kk];
	      curouttbuc += sszz;
	      break;

	    case SCSUINT16_N:
	      outtbusptr = (SCSUINT16_COP *) sim_outtbptr[ii];	/*uint16 */
	      sszz = sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		outtbus[curouttbus + kk] = (SCSUINT16_COP) outtbusptr[kk];
	      curouttbus += sszz;
	      break;

	    case SCSUINT32_N:
	      outtbulptr = (SCSUINT32_COP *) sim_outtbptr[ii];	/*uint32 */
	      sszz = sim_outtbsz[ii] * sim_outtbsz[ii + sim_nlnk];
	      for (kk = 0; kk < sszz; kk++)
		outtbul[curouttbul + kk] = (SCSUINT32_COP) outtbulptr[kk];
	      curouttbul += sszz;
	      break;

	    default:		/* Add a message here */
	      break;
	    }
	}
    }
  *ierr = 20;
 err:
  FREE(outtbd);
  FREE(outtbc);
  FREE(outtbs);
  FREE(outtbl);
  FREE(outtbuc);
  FREE(outtbus);
  FREE(outtbul);
}

/* Setup_Cvode */

int Setup_Cvode (void **cvode_mem, int solver, int N, N_Vector * y,
		 User_CV_data * cv_data, double reltol, double *abstol,
		 double t0, double *x, int ng1, double hmax)
{
  int flag;
  if (N <= 0) return 0;

  *y = N_VNewEmpty_Serial (N);
  if (check_flag ((void *) (*y), "N_VNewEmpty_Serial", 0))
    {
      *ierr = 10000;
      return -1;
    }

  *cvode_mem = NULL;
  NV_DATA_S ((*y)) = x;
  switch (solver)
    {
    case 1:
      *cvode_mem = CVodeCreate (CV_BDF, CV_NEWTON);
      break;
    case 2:
      *cvode_mem = CVodeCreate (CV_BDF, CV_FUNCTIONAL);
      break;
    case 3:
      *cvode_mem = CVodeCreate (CV_ADAMS, CV_NEWTON);
      break;
    case 4:
      *cvode_mem = CVodeCreate (CV_ADAMS, CV_FUNCTIONAL);
      break;
    }

  if (check_flag ((void *) (*cvode_mem), "CVodeCreate", 0))
    {
      *ierr = 10000;
      N_VDestroy_Serial ((*y));
      return -1;
    }

  if ((*cv_data = (User_CV_data) MALLOC (sizeof (**cv_data))) == NULL)
    {
      *ierr = 10000;
      CVodeFree (cvode_mem);
      N_VDestroy_Serial ((*y));
      return -1;
    };

  (*cv_data)->cvode_mem = *cvode_mem;
  CVodeSetFdata (*cvode_mem, *cv_data);

  flag = CVodeMalloc (*cvode_mem, CVsimblk, t0, *y, CV_SS, reltol, abstol);
  if (check_flag (&flag, "CVodeMalloc", 1))
    {
      *ierr = 300 + (-flag);
      FREE ((*cv_data));
      CVodeFree ((cvode_mem));
      N_VDestroy_Serial ((*y));
      return -1;
    }

  flag = CVodeRootInit (*cvode_mem, ng1, CVgrblk, NULL);
  if (check_flag (&flag, "CVodeRootInit", 1))
    {
      *ierr = 300 + (-flag);
      FREE ((*cv_data));
      CVodeFree ((cvode_mem));
      N_VDestroy_Serial ((*y));
      return -1;
    }
  /* Call CVDense to specify the CVDENSE dense linear solver */
  flag = CVDense (*cvode_mem, N);
  if (check_flag (&flag, "CVDense", 1))
    {
      *ierr = 300 + (-flag);
      FREE ((*cv_data));
      CVodeFree ((cvode_mem));
      N_VDestroy_Serial ((*y));
      return -1;
    }

  if (hmax > 0)
    {
      flag = CVodeSetMaxStep (*cvode_mem, (realtype) hmax);
      if (check_flag (&flag, "CVodeSetMaxStep", 1))
	{
	  *ierr = 300 + (-flag);
	  FREE ((*cv_data));
	  CVodeFree ((cvode_mem));
	  N_VDestroy_Serial ((*y));
	  return -1;
	}
    }

  CVodeSetMaxNumSteps (*cvode_mem, 50000);

  /* Set the Jacobian routine to Jac (user-supplied) 
     flag = CVDenseSetJacFn(cvode_mem, Jac, NULL);
     if (check_flag(&flag, "CVDenseSetJacFn", 1)) return(1);  */
  return 0;
}

/*  Setup_Lsodar */

int Setup_Lsodar (int *nrwp, int *niwp, double **rhot, int **ihot,
		  double hmax, int *iopt, int N, int ng1)
{
  int jj;
  int c1 = 1, c0 = 0;
  double c_b14 = 0.0;
  *nrwp = (N) * Max (16, N + 9) + 22 + ng1 * 3;
  *niwp = N + 20 + ng1;		/* + ng is for change in lsodar2 to handle masking */

  if ((*rhot = MALLOC (sizeof (double) * (*nrwp + 1))) == NULL)
    {
      *ierr = 10000;
      return -1;
    }
  if ((*ihot = MALLOC (sizeof (int) * (*niwp + 1))) == NULL)
    {
      *ierr = 10000;
      FREE ((*rhot));
      return -1;
    }
  jj = *niwp + 1;
  C2F (iset) (&jj, &c0, *ihot, &c1);	/*set to 0  */
  jj = *nrwp + 1;
  C2F (dset) (&jj, &c_b14, *rhot, &c1);	/*set to 0.0 */

  *iopt = 1;			/*rwork/iwork have valid values */

  /*mxstep  iwork(6) */
  (*ihot)[6] = 50000;		/*maximum number of (internally defined) steps allowed during
				  one call to the solver. The default value is 500. */
  if (hmax > 0)
    {
      (*rhot)[6] = hmax;
    }

  return 0;
}

/* cossim */

void cossim (double *told)
{
  int c1 = 1;
  int i3;
  static int flag__, jdum;
  static int ierr1;
  static int j, k;
  static double t, hmax_auto;
  static int jj;
  static double rhotmp, tstop;
  static int inxsci;
  static int kpo, kev;
  int Discrete_Jump;
  int *jroot, *zcros;
  realtype reltol, abstol;
  N_Vector y = NULL;
  void *cvode_mem = NULL;
  User_CV_data cv_data = NULL;

  DOPRI5_mem *dopri5_mem = NULL;
  User_DP5_data *dopri5_udata = NULL;

  int flag, flagr;
  int cnt = 0;
  double *rhot = NULL;
  int *ihot = NULL, niwp, nrwp;
  int itask;
  int jt, kk, lyh;
  int istate, iopt, itt;
  double tzero = 0.0, tn = 0.0;
  int zcrossing_unhandeled = 0, *jroottmp = NULL;
  int X_contain_xn = 1;
  double tnext;

  Sfcallerid = 99;
  jroot = NULL;
  zcros = NULL;
  if (sim_ng > 0)
    {
      if ((jroot = MALLOC (sizeof (int) * sim_ng * 2)) == NULL)
	{
	  *ierr = 10000;
	  return;
	}
      for (jj = 0; jj < sim_ng * 2; jj++)
	jroot[jj] = 0;
      jroottmp = jroot + sim_ng;
      if ((zcros = MALLOC (sizeof (int) * sim_ng)) == NULL)
	{
	  *ierr = 10000;
	  FREE (jroot);
	  return;
	}
    }

  reltol = (realtype) params_rtol;
  abstol = (realtype) params_Atol;
  hmax_auto = (params_hmax > 0) ? params_hmax : (*tf / 100.0);
  if (sim_noord == 0)
    hmax_auto = params_deltat;

  switch (params_solver)
    {
    case 0:			/* LSODAR initialization */
      flag =
	Setup_Lsodar (&nrwp, &niwp, &rhot, &ihot, hmax_auto, &iopt, *neq, sim_ng);
      break;
    case 1:
    case 2:
    case 3:
    case 4:			/* CVODE does not work with NEQ==0 */
      flag =
	Setup_Cvode (&cvode_mem, params_solver, *neq, &y, &cv_data,
		     reltol, &abstol, *told, sim_x, sim_ng, hmax_auto);
      break;
    case 5:			/* DOPRI5 initialization */
      flag =
	Setup_dopri5 (&dopri5_mem, *neq, DP5simblk, *told, *tf, reltol,
		      &abstol, 0, hmax_auto, sim_ng, DP5grblk, &dopri5_udata);
      break;
    }

  if (flag < 0)
    {
      if (sim_ng > 0)
	FREE (jroot);
      if (sim_ng > 0)
	FREE (zcros);
      return;
    }

  /* Function Body */
  params_halt = 0;
  *ierr = 0;
  C2F (xscion) (&inxsci);
  /*     initialization */
  C2F (realtimeinit) (told, &C2F (rtfactor).scale);
  phase = 1;
  params_hot = 0;
  itask = 5;
  jt = 2;			/*just for LSODAR */

  jj = 0;
  for (params_curblk = 1; params_curblk <= sim_nblk; ++params_curblk)
    {
      if (Blocks[params_curblk - 1].ng >= 1)
	{
	  zcros[jj] = params_curblk;
	  ++jj;
	}
    }
  /*  sim_ng >= jj */
  if (jj != sim_ng)
    {
      zcros[jj] = -1;
    }
  /*     initialisation (propagation of constant blocks outputs) */
  idoit (told);
  if (*ierr != 0)
    {
      goto err;
      return;
    }
  /*--discrete zero crossings----dzero--------------------*/
  if (sim_ng > 0)
    {				/* storing ZC signs just after a solver call */
      /*zdoit(told, g, x, x); */
      zdoit (told, sim_x, sim_x, sim_g);
      if (*ierr != 0)
	{
	  goto err;
	  return;
	}
      for (jj = 0; jj < sim_ng; ++jj)
	if (sim_g[jj] >= 0)
	  jroottmp[jj] = 5;
	else
	  jroottmp[jj] = -5;
    }
  /*--discrete zero crossings----dzero--------------------*/

  /*     main loop on time */

  tstop = *tf + params_ttol;

  while (*told < *tf)
    {

      if (inxsci == 1 && scilab_timer_check () == 1)
	{
	  C2F (sxevents) ();
	  /*     .     sxevents can modify halt */
	}
      if (params_halt != 0)
	{
	  if (params_halt == 2)
	    *told = *tf;	/* end simulation */
	  params_halt = 0;
	  goto err;
	  return;
	}
      if (*sim_pointi == 0)
	{
	  t = *tf;
	}
      else
	{
	  t = sim_tevts[*sim_pointi - 1];
	}
      if ( Abs (t - *told) < params_ttol)
	{
	  t = *told;
	  cdoit (told);
	  /*     update output part */
	}
      if (*told > t)
	{
	  /*     !  scheduling problem */
	  *ierr = 1;
	  goto err;
	  return;
	}

      if (*told >= *tf - params_ttol)
	{
	  phase = 0;
	  odoit (told, sim_x, sim_xd, sim_xd);
	  /*     .     we are at the end, update continuous part before leaving */
	  if (sim_ncord > 0)
	    {
	      cdoit (told);
	    }
	  goto err;
	  return;
	}

      if (*told != t)
	{
	  if (sim_xptr[sim_nblk] == 1)
	    {
	      /*     .     no continuous state */

	      phase = 0;
	      odoit (told, sim_x, sim_xd, sim_xd);
	      phase = 1;

	      tnext = Min (*told + hmax_auto, *told + params_deltat);

	      if (tnext + params_ttol > t)
		{
		  *told = t;
		}
	      else
		{
		  *told = tnext;
		}

	      /*     .     update outputs of 'c' type blocks with no continuous state */
	      if (*told >= *tf - params_ttol)
		{
		  phase = 0;
		  odoit (told, sim_x, sim_xd, sim_xd);
		  /*     .     we are at the end, update continuous part before leaving */
		  if (sim_ncord > 0)
		    {
		      cdoit (told);
		    }
		  goto err;
		  return;
		}
	    }
	  else
	    {
	      /*     integrate */
	      rhotmp = *tf + params_ttol;
	      if (*sim_pointi != 0)
		{
		  kpo = *sim_pointi;
		L20:
		  if (sim_critev[kpo - 1] == 1)
		    {
		      rhotmp = sim_tevts[kpo - 1];
		      goto L30;
		    }
		  kpo = sim_evtspt[kpo - 1];
		  if (kpo != 0)
		    {
		      goto L20;
		    }
		L30:
		  if (rhotmp > *tf + params_ttol)
		    rhotmp = *tf + params_ttol;
		  if (rhotmp < tstop - params_ttol)
		    {
		      params_hot = 0;
		    }
		}
	      tstop = rhotmp;
	      t = Min (*told + params_deltat, Min (t, *tf + params_ttol));

	      if (sim_ng > 0 && params_hot == 0 && sim_nmod > 0)
		{
		  zdoit (told, sim_x, sim_x, sim_g);
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		}
	      /*---------  solver's cold/hot restart management :beginning ---------------------*/
	      switch (params_solver)
		{
		case 0:
		  if (params_hot == 0)
		    {		/* hot==0 : cold restart */
		      rhot[1] = tstop;
		      istate = 1;
		    }
		  else
		    {
		      rhot[1] = tstop;
		      istate = 2;
		    }
		  break;

		case 1:
		case 2:
		case 3:
		case 4:
		  if (params_hot == 0)
		    {		/* hot==0 : cold restart */
		      flag = CVodeSetStopTime (cvode_mem, (realtype) tstop);	/* Setting the stop time */
		      if (check_flag (&flag, "CVodeSetStopTime", 1))
			{
			  *ierr = 300 + (-flag);
			  goto err;
			  return;
			}
		      flag =
			CVodeReInit (cvode_mem, CVsimblk, (realtype) (*told),
				     y, CV_SS, reltol, &abstol);
		      if (check_flag (&flag, "CVodeReInit", 1))
			{
			  *ierr = 300 + (-flag);
			  goto err;
			  return;
			}
		    }
		  break;

		case 5:	/* DOPRI5 */
		  if (params_hot == 0)
		    {		/* hot==0 : cold restart */
		      DP5_set_tstop (dopri5_mem, tstop);
		    }
		  break;
		}
	      /*---------  solver's cold/hot restart management : end ---------------------*/

	      if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
		{
		  sciprint ("****Solver from: %f to %f hot= %d  \r\n", *told, t, params_hot);
		}

	      /*--discrete zero crossings----dzero--------------------*/
	      /*--check for Dzeros after Mode settings or ddoit()----*/
	      Discrete_Jump = 0;

	      if (sim_ng > 0 && params_hot == 0)
		{
		  zdoit (told, sim_x, sim_x, sim_g);
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		  for (jj = 0; jj < sim_ng; ++jj)
		    {
		      if ((sim_g[jj] >= 0.0) && (jroottmp[jj] == -5))
			{
			  Discrete_Jump = 1;
			  jroottmp[jj] = 1;
			}
		      else if ((sim_g[jj] < 0.0) && (jroottmp[jj] == 5))
			{
			  Discrete_Jump = 1;
			  jroottmp[jj] = -1;
			}
		      else
			jroottmp[jj] = 0;
		    }
		}
	      /*--discrete zero crossings----dzero--------------------*/

	      if (Discrete_Jump == 0)
		{		/* if there was a dzero, its event should be activated */
		  phase = 2;

		  if (params_hot == 0)
		    {
		      tn = *told;
		      X_contain_xn = 1;
		      zcrossing_unhandeled = 0;
		    }
		  flag = 0;
		  if (!zcrossing_unhandeled)
		    {
		      if ((t > tn))
			{

			  if (X_contain_xn == 0)
			    {
			      switch (params_solver)
				{
				case 0:
				  lyh = 21 + 3 * sim_ng;
				  kk = 0;
				  C2F (intdy) (&tn, &kk, &(rhot[lyh]), neq, sim_x, &itt);
				  break;
				case 1:
				case 2:
				case 3:
				case 4:
				  CVodeGetDky (cvode_mem, tn, 0, y);
				  break;
				case 5:
				  //  for (i = 0; i < dopri5_mem->n; i++)
				  // contd5 (dopri5_mem, i, *told, double xold, double h_old)
				  break;
				}
			    }
			  phase = 0;
			  odoit (&tn, sim_x, sim_xd, sim_xd);

			  phase = 2;
			  switch (params_solver)
			    {
			    case 0:
			      C2F (lsodar2) (C2F (simblk), neq, sim_x, told, &t,
					     &c1, &params_rtol, &params_Atol, &itask,
					     &istate, &iopt, &rhot[1], &nrwp,
					     &ihot[1], &niwp, &jdum, &jt,
					     C2F (grblk), &sim_ng, jroot);
			      tn = rhot[13];
			      if (istate > 0)
				flag = istate + 200;
			      else
				flag = istate - 200;

			      break;
			    case 1:
			    case 2:
			    case 3:
			    case 4:
			      flag =
				CVode (cvode_mem, t, y, told,
				       CV_ONE_STEP_TSTOP);
			      CVodeGetCurrentTime (cvode_mem, &tn);
			      break;
			    case 5:
			      flag =
				dopri5_solve (dopri5_mem, told, t, sim_x, params_hot);
			      break;
			    }
			  if ((flag == LSODAR_ZERO_DETACH_RETURN)
			      || (flag == LSODAR_ROOT_RETURN)
			      || (flag == CV_ZERO_DETACH_RETURN)
			      || (flag == CV_ROOT_RETURN))
			    {
			      tzero = *told;
			      zcrossing_unhandeled = flag;
			      flag = 200;
			    }
			  X_contain_xn = 1;
			}
		    }
		  if (t <= tn)
		    *told = t;

		  if (zcrossing_unhandeled)
		    {
		      if (t >= tzero - params_ttol)
			{
			  *told = tzero;
			  flag = zcrossing_unhandeled;
			}
		    }

		  if (*told <= tn)
		    {
		      switch (params_solver)
			{
			case 0:
			  lyh = 21 + 3 * sim_ng;
			  kk = 0;
			  C2F (intdy) (told, &kk, &(rhot[lyh]), neq, sim_x, &istate);
			  break;
			case 1:
			case 2:
			case 3:
			case 4:
			  CVodeGetDky (cvode_mem, *told, 0, y);
			  break;
			case 5:
			  //      for (i = 0; i < dopri5_mem->n; i++)
			  // contd5 (dopri5_mem, i, *told, double xold, double h_old)

			  break;
			}
		      X_contain_xn = 0;
		    }

		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		  phase = 1;
		}
	      else
		{
		  flag = LSODAR_ROOT_RETURN;	/* in order to handle discrete jumps */
		  for (jj = 0; jj < sim_ng; ++jj)
		    jroot[jj] = jroottmp[jj];
		}
	      Sfcallerid = 98;

	      /*     .     update outputs of 'c' type  blocks if we are at the end */
	      if (*told >= *tf - params_ttol)
		{
		  phase = 0;
		  odoit (told, sim_x, sim_xd, sim_xd);
		  if (sim_ncord > 0)
		    {
		      cdoit (told);
		    }
		  goto err;
		  return;
		}

	      if (flag >= 0)
		{
		  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
		    sciprint ("****Solver reached: %f\r\n", *told);
		  params_hot = 1;
		  cnt = 0;
		}
	      else if (flag == CV_CONV_FAILURE || flag == CV_ERR_FAILURE ||
		       flag == LSODAR_CONV_FAILURE
		       || flag == LSODAR_ERR_FAILURE)
		{
		  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
		    sciprint
		      ("****Solver: cannot converge at time=%g (stiff region, change RTOL and ATOL)\r\n",
		       *told);
		  params_hot = 0;
		  cnt++;
		  if (cnt > 5)
		    {
		      *ierr = 300 + (-flag);
		      goto err;
		      return;
		    }
		}
	      else if (flag == CV_TOO_MUCH_WORK
		       || flag == LSODAR_TOO_MUCH_WORK)
		{
		  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
		    sciprint
		      ("****Solver: too much work at time=%g (stiff region, change RTOL and ATOL)\r\n",
		       *told);
		  params_hot = 1;
		  istate = 2;
		  cnt++;
		  if (cnt > 5)
		    {
		      params_hot = 0;
		    };
		}
	      else
		{
		  if (flag < 0)
		    *ierr = 300 + (-flag);	/* raising errors due to internal errors, other wise erros due to flagr */
		  goto err;
		  return;
		}

	      if (flag == CV_ZERO_DETACH_RETURN
		  || flag == LSODAR_ZERO_DETACH_RETURN
		  || flag == DP5_ZERO_DETACH_RETURN)
		{
		  params_hot = 0;
		  zcrossing_unhandeled = 0;
		};		/* new feature of sundials, detects zero-detaching */

	      if (flag == CV_ROOT_RETURN || flag == LSODAR_ROOT_RETURN
		  || flag == DP5_ROOT_RETURN)
		{
		  zcrossing_unhandeled = 0;
		  /*     .        at a least one root has been found */
		  params_hot = 0;
		  if (Discrete_Jump == 0)
		    {
		      switch (params_solver)
			{
			case 0:
			  break;
			case 1:
			case 2:
			case 3:
			case 4:
			  flagr = CVodeGetRootInfo (cvode_mem, jroot);
			  if (check_flag (&flagr, "CVodeGetRootInfo", 1))
			    {
			      *ierr = 300 + (-flagr);
			      goto err;
			      return;
			    }
			  break;
			case 5:
			  flagr = DP5_Get_RootInfo (dopri5_mem, jroot);
			  break;
			}
		    }
		  /*     .        at a least one root has been found */
		  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
		    {
		      sciprint ("root found at t=: %f\r\n", *told);
		    }
		  /*     .        update outputs affecting ztyp blocks ONLY FOR OLD BLOCKS */

		  zdoit (told, sim_x, sim_xd, sim_g);
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }

		  for (jj = 0; jj < sim_ng; ++jj)
		    {
		      params_curblk = zcros[jj];
		      if (params_curblk == -1)
			{
			  break;
			}
		      kev = 0;
		      for (j = sim_zcptr[params_curblk - 1] - 1; j < sim_zcptr[params_curblk - 1 + 1] - 1; ++j)
			{
			  if (jroot[j] != 0)
			    {
			      kev = 1;
			      break;
			    }
			}
		      /*   */
		      if (kev != 0)
			{
			  Blocks[params_curblk - 1].jroot =
			    &jroot[sim_zcptr[params_curblk - 1] - 1];
			  if (sim_funtyp[params_curblk - 1] > 0)
			    {
			      if (Blocks[params_curblk - 1].nevout > 0)
				{
				  /* initialize evout */
				  for (j = 0; j < Blocks[params_curblk - 1].nevout; j++)
				    {
				      Blocks[params_curblk - 1].evout[j] = -1;
				    }
				  flag__ = 3;
				  if (Blocks[params_curblk - 1].nx > 0)
				    {
				      Blocks[params_curblk - 1].x = &sim_x[sim_xptr[params_curblk - 1] - 1];
				      Blocks[params_curblk - 1].xd =&sim_xd[sim_xptr[params_curblk - 1] - 1];
				    }
				  /* call corresponding block to determine output event (kev) */
				  Blocks[params_curblk - 1].nevprt = -kev;
				  callf (told, &Blocks[params_curblk - 1], &flag__);
				  if (flag__ < 0)
				    {
				      *ierr = 5 - flag__;
				      goto err;
				      return;
				    }
				  /*     .              update event agenda */
				  for (k = 0; k < Blocks[params_curblk - 1].nevout; ++k)
				    {
				      if (isinf(Blocks[params_curblk - 1].evout[k]))
					{
					  i3 = k + sim_clkptr[params_curblk - 1];
					  rmevs (&i3, sim_pointi);
					}
				      if (Blocks[params_curblk - 1].evout[k] >= 0.)
					{
					  i3 = k + sim_clkptr[params_curblk - 1];
					  addevs (Blocks[params_curblk - 1].evout[k] + (*told), &i3, &ierr1);
					}
				    }
				}
			      /* update state */
			      if ((Blocks[params_curblk - 1].nx > 0)
				  || (Blocks[params_curblk - 1].nz > 0)
				  || (Blocks[params_curblk - 1].noz > 0)
				  || (*Blocks[params_curblk - 1].work != NULL))
				{
				  /* call corresponding block to update state */
				  flag__ = 2;
				  if (Blocks[params_curblk - 1].nx > 0)
				    {
				      Blocks[params_curblk - 1].x = &sim_x[sim_xptr[params_curblk - 1] - 1];
				      Blocks[params_curblk - 1].xd =&sim_xd[sim_xptr[params_curblk - 1] - 1];
				    }
				  Blocks[params_curblk - 1].nevprt = -kev;
				  callf (told, &Blocks[params_curblk - 1], &flag__);
				  if (flag__ < 0)
				    {
				      *ierr = 5 - flag__;
				      goto err;
				      return;
				    }
				}
			    }
			}
		    }
		}
	    }
	  /*--discrete zero crossings----dzero--------------------*/
	  if (sim_ng > 0)
	    {
	      /* storing ZC signs just after a sundials call */
	      zdoit (told, sim_x, sim_x, sim_g);
	      if (*ierr != 0)
		{
		  goto err;
		  return;
		}
	      for (jj = 0; jj < sim_ng; ++jj)
		{
		  if (sim_g[jj] >= 0)
		    {
		      jroottmp[jj] = 5;
		    }
		  else
		    {
		      jroottmp[jj] = -5;
		    }
		}
	    }
	  /*--discrete zero crossings----dzero--------------------*/
	  C2F (realtime) (told);
	}
      else
	{
	  /*     .  t==told */
	  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
	    {
	      sciprint ("Event: %d activated at t=%f\r\n", *sim_pointi, *told);
	      for (kev = 0; kev < sim_nblk; kev++)
		{
		  if (Blocks[kev].nmode > 0)
		    {
		      sciprint ("mode of block %d=%d, ", kev,
				Blocks[kev].mode[0]);
		    }
		}
	      sciprint ("**mod**\r\n");
	    }
	  ddoit (told);

	  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
	    {
	      sciprint ("End of activation\r\n");
	    }
	  if (*ierr != 0)
	    {
	      goto err;
	      return;
	    }

	}
      /*     end of main loop on time */
    }
  phase = 0;
  odoit (told, sim_x, sim_xd, sim_xd);
 err:
  switch ( params_solver )
    {				
    case 0: FREE (rhot); FREE (ihot);break;			
    case 1:						
    case 2:						
    case 3:								
    case 4: if (*neq>0) {FREE (cv_data);CVodeFree (&cvode_mem);N_VDestroy_Serial (y);};break;	
    case 5: dopri5_free (dopri5_mem);break;					
    }									
  if ( sim_ng > 0 ) FREE (jroot);						
  if ( sim_ng > 0 ) FREE (zcros);
}

int Setup_IDA (void **ida_mem, int N, N_Vector *yy, double *x, N_Vector *yp,
	       double *xd, N_Vector *IDx, double reltol, double *abstol,
	       double t0, int ng1, double hmax, User_IDA_data *ida_data)
{
  int flag, Jn, Jnx, Jno, Jni, Jactaille;
  int maxnj, maxnit, arret = 0;

  if (N <= 0)
    return 0;
  /*--------*/
  *yy = N_VNewEmpty_Serial (N);
  if (check_flag ((void *) (*yy), "N_VNew_Serial", 0))
    {
      *ierr = 10000;
      return -1;
    }
  NV_DATA_S ((*yy)) = x;
  /*--------*/
  *yp = N_VNewEmpty_Serial (N);
  if (check_flag ((void *) (*yp), "N_VNew_Serial", 0))
    {
      N_VDestroy_Serial ((*yp));
      *ierr = 10000;
      return -1;
    }
  NV_DATA_S ((*yp)) = xd;
  /*--------*/
  *IDx = N_VNew_Serial (N);
  if (check_flag ((void *) (*IDx), "N_VNew_Serial", 0))
    {
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 10000;
      return -1;
    }
  /*--------*/
  *ida_mem = NULL;
  *ida_mem = IDACreate ();
  if (check_flag ((void *) (*ida_mem), "IDACreate", 0))
    {
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 10000;
      return -1;
    }
  /*--------*/
  flag =
    IDAMalloc (*ida_mem, simblkdaskr, t0, *yy, *yp, IDA_SS, reltol, abstol);
  if (check_flag (&flag, "IDAMalloc", 1))
    {
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }
  /*--------*/
  flag = IDARootInit (*ida_mem, ng1, grblkdaskr, NULL);
  if (check_flag (&flag, "IDARootInit", 1))
    {
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }
  /*--------*/
  flag = IDADense (*ida_mem, N);
  if (check_flag (&flag, "IDADense", 1))
    {
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }
  /*--------*/
  if ((*ida_data = (User_IDA_data) MALLOC (sizeof (**ida_data))) == NULL)
    {
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }
  (*ida_data)->ida_mem = *ida_mem;
  (*ida_data)->ewt   = NULL;
  (*ida_data)->iwork = NULL;
  (*ida_data)->rwork = NULL;
  (*ida_data)->gwork = NULL;
  /*--------*/
  (*ida_data)->ewt = N_VNew_Serial (N);
  if (check_flag ((void *) ((*ida_data)->ewt), "N_VNew_Serial", 0))
    {
      FREE ((*ida_data));
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }
  /*--------*/
  if ( ng1 > 0 )
    {
      if (((*ida_data)->gwork =
	   (double *) MALLOC (ng1 * sizeof (double))) == NULL)
	{
	  N_VDestroy_Serial (((*ida_data)->ewt));
	  FREE ((*ida_data));
	  IDAFree ((ida_mem));
	  N_VDestroy_Serial ((*IDx));
	  N_VDestroy_Serial ((*yp));
	  N_VDestroy_Serial ((*yy));
	  *ierr = 200 + (-flag);
	  return -1;
	}
    }
  /*--------*/
  /*Jacobian_Flag=0; */
  if (AJacobian_block > 0)
    {
      /* set by the block with A-Jac in flag-4 using Set_Jacobian_flag(1); */
      Jn = *neq;
      Jnx = Blocks[AJacobian_block - 1].nx;
      Jno = Blocks[AJacobian_block - 1].nout;
      Jni = Blocks[AJacobian_block - 1].nin;
    }
  else
    {
      Jn = *neq;
      Jnx = 0;
      Jno = 0;
      Jni = 0;
    }

  Jactaille =
    3 * Jn + (Jn + Jni) * (Jn + Jno) + Jnx * (Jni + 2 * Jn + Jno) +
    (Jn - Jnx) * (2 * (Jn - Jnx) + Jno + Jni) + 2 * Jni * Jno;
  if (((*ida_data)->rwork =
       (double *) MALLOC (Jactaille * sizeof (double))) == NULL)
    {
      if (ng1 > 0)
	FREE ((*ida_data)->gwork);
      N_VDestroy_Serial (((*ida_data)->ewt));
      FREE ((*ida_data));
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }

  flag = IDADenseSetJacFn (*ida_mem, Jacobians, *ida_data);
  if (check_flag (&flag, "IDADenseSetJacFn", 1))
    arret = 1;

  flag = IDASetRdata (*ida_mem, *ida_data);
  if (check_flag (&flag, "IDASetRdata", 1))
    arret = 1;

  if (hmax > 0)
    {
      flag = IDASetMaxStep (*ida_mem, (realtype) hmax);
      if (check_flag (&flag, "IDASetMaxStep", 1))
	arret = 1;
    }

  maxnj = 100;/* setting the maximum number of Jacobian evaluation during a Newton step */
  flag = IDASetMaxNumJacsIC (*ida_mem, maxnj);
  if (check_flag (&flag, "IDASetMaxNumJacsIC", 1))
    arret = 1;

  maxnit = 10;/* setting the maximum number of Newton iterations in any one attemp to solve CIC */
  flag = IDASetMaxNumItersIC (*ida_mem, maxnit);
  if (check_flag (&flag, "IDASetMaxNumItersIC", 1))
    arret = 1;

  /* setting the maximum number of steps in an integration interval */
  flag = IDASetMaxNumSteps (*ida_mem, 2000);
  if (check_flag (&flag, "IDASetMaxNumSteps", 1))
    arret = 1;

  if (arret)
    {
      FREE ((*ida_data)->rwork);
      if (ng1 > 0)
	FREE ((*ida_data)->gwork);
      N_VDestroy_Serial (((*ida_data)->ewt));
      FREE ((*ida_data));
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }

  return 0;
}

void cossimdaskr (double *told)
{
  static int otimer = 0;
  int i3;
  static int flag__;
  static int ierr1;
  static int j, k;
  static double t;
  static int kk, jj;
  static int ntimer;
  static double rhotmp, tstop, hmax_auto;
  static int inxsci;
  static int kpo, kev;

  int *jroot = NULL, *zcros = NULL;
  /*int maxord;*/
  int *Mode_save;
  int Mode_change = 0;
  realtype *tmpneq = NULL;

  int flag, flagr;
  N_Vector yy = NULL, yp = NULL;
  realtype reltol, abstol;
  int Discrete_Jump;
  N_Vector IDx = NULL;
  realtype *scicos_xproperty = NULL;
  N_Vector bidon = NULL, tempv1 = NULL, tempv2 = NULL, tempv3 = NULL;
  DenseMat TJacque = NULL;
  realtype *Jacque_col;
  double tnext;
  void *ida_mem = NULL;
  User_IDA_data ida_data = NULL;
  IDAMem copy_IDA_mem = NULL;
  /*-------------------- Analytical Jacobian memory allocation ----------*/
  int maxnj;
  double uround;
  int cnt = 0, N_iters;
  double tzero = 0.0, tn = 0.0;
  int zcrossing_unhandeled = 0, *jroottmp = NULL;
  int X_contain_xn = 1;

  /*maxord = 5;*/
  Sfcallerid = 99;

  CI = 1.0;
  for (jj = 0; jj < *neq; jj++)
    {
      sim_alpha[jj] = CI;
      //sim_beta[jj]=CJ;
    }

  if (sim_ng != 0)
    {
      if ((jroot = MALLOC (sizeof (int) * sim_ng * 2)) == NULL)
	{
	  *ierr = 10000;
	  return;
	}
      jroottmp = jroot + sim_ng;
      for (jj = 0; jj < sim_ng * 2; jj++)
	jroot[jj] = 0;
      if ((zcros = MALLOC (sizeof (int) * sim_ng)) == NULL)
	{
	  *ierr = 10000;
	  if (sim_ng != 0)
	    FREE (jroot);
	  return;
	}
    }

  Mode_save = NULL;
  if (sim_nmod != 0)
    {
      if ((Mode_save = MALLOC (sizeof (int) * sim_nmod)) == NULL)
	{
	  *ierr = 10000;
	  if (sim_ng != 0)
	    FREE (jroot);
	  if (sim_ng != 0)
	    FREE (zcros);
	  return;
	}
    }
  tmpneq = NULL;
  if (*neq != 0)
    {
      if ((tmpneq = MALLOC (*neq * sizeof (realtype))) == NULL)
	{
	  *ierr = 10000;
	  if (sim_nmod)
	    FREE (Mode_save);
	  if (sim_ng != 0)
	    FREE (jroot);
	  if (sim_ng != 0)
	    FREE (zcros);
	  return;
	}
    }


  reltol = (realtype) params_rtol;
  abstol = (realtype) params_Atol;
  hmax_auto = (params_hmax > 0) ? params_hmax : (*tf / 100.0);
  if (sim_noord == 0)
    hmax_auto = params_deltat;

  if (*neq > 0)
    {
      flag =
	Setup_IDA (&ida_mem, *neq, &yy, sim_x, &yp, sim_xd, &IDx, reltol, &abstol,
		   *told, sim_ng, hmax_auto, &ida_data);
      if (flag < 0)
	{
	  *ierr = 10000;
	  if (*neq > 0)
	    FREE (tmpneq);
	  if (sim_nmod)
	    FREE (Mode_save);
	  if (sim_ng)
	    FREE (jroot);
	  if (sim_ng)
	    FREE (zcros);
	  return;
	}
      copy_IDA_mem = (IDAMem) ida_mem;
      TJacque = (DenseMat) DenseAllocMat (*neq, *neq);
    }

  uround = 1.0;
  do
    {
      uround = uround * 0.5;
    }
  while (1.0 + uround != 1.0);
  uround = uround * 2.0;
  SQuround = sqrt (uround);
  /* Function Body */

  params_halt = 0;
  *ierr = 0;
  /*     hot = .false. */
  phase = 1;
  params_hot = 0;
  /*      stuck=.false. */
  C2F (xscion) (&inxsci);
  /*     initialization */
  C2F (realtimeinit) (told, &C2F (rtfactor).scale);
  /*     ATOL and RTOL are scalars */

  jj = 0;
  for (params_curblk = 1; params_curblk <= sim_nblk; ++params_curblk)
    {
      if (Blocks[params_curblk - 1].ng >= 1)
	{
	  zcros[jj] = params_curblk;
	  ++jj;
	}
    }
  /*     . Il faut:  sim_ng >= jj */
  if (jj != sim_ng)
    {
      zcros[jj] = -1;
    }
  /*     initialisation (propagation of constant blocks outputs) */
  idoit (told);
  if (*ierr != 0)
    {
      goto err;
      return;
    }

  /*--discrete zero crossings----dzero--------------------*/
  if (sim_ng > 0)
    {				/* storing ZC signs just after a solver call */
      zdoit (told, sim_x, sim_x, sim_g);
      if (*ierr != 0)
	{
	  goto err;
	  return;
	}
      for (jj = 0; jj < sim_ng; ++jj)
	if (sim_g[jj] >= 0)
	  jroottmp[jj] = 5;
	else
	  jroottmp[jj] = -5;
    }
  /*     main loop on time */
  tstop = *tf + params_ttol;

  while (*told < *tf)
    {
      if (inxsci == 1 && scilab_timer_check () == 1)
	{
	  C2F (sxevents) ();
	  /*     .     sxevents can modify halt */
	}
      if (params_halt != 0)
	{
	  if (params_halt == 2)
	    *told = *tf;	/* end simulation */
	  params_halt = 0;
	  goto err;
	  return;
	}
      if (*sim_pointi == 0)
	{
	  t = *tf;
	}
      else
	{
	  t = sim_tevts[*sim_pointi - 1];
	}
      if (Abs (t - *told) < params_ttol)
	{
	  t = *told;
	  /*     update output part */
	}
      if (*told > t)
	{
	  /*     !  scheduling problem */
	  *ierr = 1;
	  goto err;
	  return;
	}

      if (*told >= *tf - params_ttol)
	{
	  /*     .     we are at the end, update continuous part before leaving */
	  phase = 0;
	  odoit (told, sim_x, sim_xd, tmpneq);
	  cdoit (told);
	  goto err;
	  return;
	}

      if (*told != t)
	{
	  if (sim_xptr[sim_nblk] == 1)
	    {
	      phase = 0;
	      odoit (told, sim_x, sim_xd, tmpneq);
	      phase = 1;

	      tnext = Min (*told + hmax_auto, *told + params_deltat);
	      if (tnext + params_ttol > t)
		{
		  *told = t;
		}
	      else
		{
		  *told = tnext;
		}

	      /*     .     update outputs of 'c' type blocks with no continuous state */
	      if (*told >= *tf - params_ttol)
		{
		  /*     .     we are at the end, update continuous part before leaving */
		  phase = 0;
		  odoit (told, sim_x, sim_xd, tmpneq);
		  cdoit (told);
		  goto err;
		  return;
		}
	    }
	  else
	    {
	      rhotmp = *tf + params_ttol;
	      if (*sim_pointi != 0)
		{
		  kpo = *sim_pointi;
		L20:
		  if (sim_critev[kpo - 1] == 1)
		    {
		      rhotmp = sim_tevts[kpo - 1];
		      goto L30;
		    }
		  kpo = sim_evtspt[kpo - 1];
		  if (kpo != 0)
		    {
		      goto L20;
		    }
		L30:
		  if (rhotmp > *tf + params_ttol)
		    rhotmp = *tf + params_ttol;
		  if (rhotmp < tstop - params_ttol)
		    {
		      params_hot = 0;	/* Do cold-restart the solver:if the new TSTOP isn't beyong the previous one */
		    }
		}
	      tstop = rhotmp;
	      t = Min (*told + params_deltat, Min (t, *tf + params_ttol));

	      /* Setting the stop time */
	      flag = IDASetStopTime (ida_mem, (realtype) tstop);
	      if (check_flag (&flag, "IDASetStopTime", 1))
		{
		  *ierr = 200 + (-flag);
		  goto err;
		  return;
		}
	      if (params_hot == 0)
		{
		  /* CIC calculation when hot==0 */
		  if (sim_ng > 0 && sim_nmod > 0)
		    {
		      phase = 1;
		      zdoit (told, sim_x, sim_xd, sim_g);
		      if (*ierr != 0)
			{
			  goto err;
			  return;
			}
		    }
		  /*----------ID setting/checking------------*/
		  N_VConst (SUNDIALS_ONE, IDx);	/* Initialize id to 1's. */
		  scicos_xproperty = NV_DATA_S (IDx);
		  Sfcallerid = -18;	/*Added beacuse reinitdoit() has call to blocks with flag-0 */
		  reinitdoit (told);
		  if (*ierr > 0)
		    {
		      goto err;
		      return;
		    }

		  CI = 0.0;
		  CJ = 100.0;
		  for (jj = 0; jj < *neq; jj++)
		    {
		      if (sim_xprop[jj] == 1)
			scicos_xproperty[jj] = SUNDIALS_ONE;
		      if (sim_xprop[jj] == -1)
			scicos_xproperty[jj] = SUNDIALS_ZERO;
		      sim_alpha[jj] = CI;
		      sim_beta[jj] = CJ;
		    }

		  Jacobians (*neq, (realtype) (*told), yy, yp, bidon,
			     (realtype) CJ, ida_data, TJacque, tempv1, tempv2, tempv3);

		  for (jj = 0; jj < *neq; jj++)
		    {
		      Jacque_col = DENSE_COL (TJacque, jj);
		      CI = SUNDIALS_ZERO;
		      for (kk = 0; kk < *neq; kk++)
			{
			  if ((Jacque_col[kk] - Jacque_col[kk] != 0))
			    {
			      CI = -SUNDIALS_ONE;
			      break;
			    }
			  else
			    {
			      if (Jacque_col[kk] != 0)
				{
				  CI = SUNDIALS_ONE;
				  break;
				}
			    }
			}
		      if (CI >= SUNDIALS_ZERO)
			{
			  scicos_xproperty[jj] = CI;
			}
		      else
			{
			  fprintf (stderr, "\n\rWarinng! Xproperties are not match for i=%d!", jj);
			}
		    }

		  flag = IDASetId (ida_mem, IDx);
		  if (check_flag (&flag, "IDASetId", 1))
		    {
		      *ierr = 200 + (-flag);
		      goto err;
		      return;
		    }
		  CI = 1.0;
		  for (jj = 0; jj < *neq; jj++)
		    {
		      sim_alpha[jj] = CI;
		      /* sim_beta[jj]=CJ; */
		    }

		  /*--------------------------------------------*/
		  maxnj = 100;	/* setting the maximum number of Jacobian evaluation during a Newton step */
		  flag = IDASetMaxNumJacsIC (ida_mem, maxnj);
		  if (check_flag (&flag, "IDASetMaxNumItersIC", 1))
		    {
		      *ierr = 200 + (-flag);
		      goto err;
		      return;
		    };
		  flag = IDASetLineSearchOffIC (ida_mem, FALSE);	/* (def=false)  */
		  if (check_flag (&flag, "IDASetLineSearchOffIC", 1))
		    {
		      *ierr = 200 + (-flag);
		      goto err;
		      return;
		    };
		  flag = IDASetMaxNumItersIC (ida_mem, 10);
		  /* (def=10) setting the maximum number of Newton iterations in any one attemp to solve CIC */
		  if (check_flag (&flag, "IDASetMaxNumItersIC", 1))
		    {
		      *ierr = 200 + (-flag);
		      goto err;
		      return;
		    };

		  N_iters = 10 + Min (sim_nmod * 3, 30);
		  for (j = 0; j <= N_iters; j++)
		    {		/* counter to reevaluate the
				   modes in  mode->CIC->mode->CIC-> loop
				   do it once in the absence of mode (nmod=0) */
		      /* updating the modes through Flag==9, Phase==1 */
		      if (inxsci == 1 && scilab_timer_check () == 1)
			{
			  C2F (sxevents) ();
			  otimer = ntimer;
			}
		      if (params_halt != 0)
			{
			  params_halt = 0;
			  goto err;
			  return;
			}

		      /* yy->PH */
		      flag =
			IDAReInit (ida_mem, simblkdaskr, (realtype) (*told),
				   yy, yp, IDA_SS, reltol, &abstol);
		      if (check_flag (&flag, "CVodeReInit", 1))
			{
			  *ierr = 200 + (-flag);
			  goto err;
			  return;
			}

		      phase = 2;	/* IDACalcIC: PHI-> yy0: if (ok) yy0_cic-> PHI */
		      copy_IDA_mem->ida_kk = 1;

		      flagr =
			IDACalcIC (ida_mem, IDA_YA_YDP_INIT, (realtype) (t));
		      phase = 1;
		      flag = IDAGetConsistentIC (ida_mem, yy, yp);	/* PHI->YY */

		      if (*ierr > 5)
			{
			  /* *ierr>5 => singularity in block */
			  goto err;
			  return;
			}

		      if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
			{
			  if (flagr >= 0)
			    {
			      sciprint
				("**** Solver succesfully initialized *****\r\n");
			    }
			  else
			    {
			      sciprint
				("**** Solver failed to initialize ->try again *****\r\n");
			    }
			}
		      /*-------------------------------------*/
		      /* saving the previous modes */
		      for (jj = 0; jj < sim_nmod; ++jj)
			{
			  Mode_save[jj] = sim_mod[jj];
			}
		      if (sim_ng > 0 && sim_nmod > 0)
			{
			  phase = 1;
			  zdoit (told, sim_x, sim_xd, sim_g);
			  if (*ierr != 0)
			    {
			      goto err;
			      return;
			    }
			}
		      /*------------------------------------*/
		      Mode_change = 0;
		      for (jj = 0; jj < sim_nmod; ++jj)
			{
			  if (Mode_save[jj] != sim_mod[jj])
			    {
			      Mode_change = 1;
			      break;
			    }
			}
		      if (Mode_change == 0)
			{
			  if (flagr >= 0)
			    {
			      break;	/*   if (flagr>=0) break;  else{ *ierr=200+(-flagr); goto err;  return; } */
			    }
			  else if (j >= (int) (N_iters / 2))
			    {
			      /* IDASetMaxNumStepsIC(mem,10); *//* maxnh (def=5) */
			      IDASetMaxNumJacsIC (ida_mem, 10);	/* maxnj 100 (def=4) */
			      /* IDASetMaxNumItersIC(mem,100000); *//* maxnit in IDANewtonIC (def=10) */
			      IDASetLineSearchOffIC (ida_mem, TRUE);	/* (def=false)  */
			      /* IDASetNonlinConvCoefIC(mem,1.01); *//* (def=0.01-0.33 */
			      flag = IDASetMaxNumItersIC (ida_mem, 1000);
			      if (check_flag (&flag, "IDASetMaxNumItersIC", 1))
				{
				  *ierr = 200 + (-flag);
				  goto err;
				  return;
				};
			    }
			}
		    }		/* mode-CIC  counter */
		  if (Mode_change == 1)
		    {
		      /* In tghis case, we try again by relaxing all modes and calling IDA_calc again 
		         /Masoud */
		      phase = 1;
		      copy_IDA_mem->ida_kk = 1;
		      flagr =
			IDACalcIC (ida_mem, IDA_YA_YDP_INIT, (realtype) (t));
		      phase = 1;
		      flag = IDAGetConsistentIC (ida_mem, yy, yp);	/* PHI->YY */
		      if ((flagr < 0) || (*ierr > 5))
			{	/* *ierr>5 => singularity in block */
			  *ierr = 23;
			  goto err;
			  return;
			}
		    }
		  /*-----If flagr<0 the initialization solver has not converged-----*/
		  if (flagr < 0)
		    {
		      *ierr = 237;
		      goto err;
		      return;
		    }
		}		/* CIC calculation when hot==0 */

	      if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
		{
		  sciprint ("****Solver from: %f to %f hot= %d  \r\n", *told,
			    t, params_hot);
		}

	      /*--discrete zero crossings----dzero--------------------*/
	      /*--check for Dzeros after Mode settings or ddoit()----*/
	      Discrete_Jump = 0;
	      if (sim_ng > 0 && params_hot == 0)
		{
		  zdoit (told, sim_x, sim_xd, sim_g);
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		  for (jj = 0; jj < sim_ng; ++jj)
		    {
		      if ((sim_g[jj] >= 0.0) && (jroottmp[jj] == -5))
			{
			  Discrete_Jump = 1;
			  jroottmp[jj] = 1;
			}
		      else if ((sim_g[jj] < 0.0) && (jroottmp[jj] == 5))
			{
			  Discrete_Jump = 1;
			  jroottmp[jj] = -1;
			}
		      else
			jroottmp[jj] = 0;
		    }
		}

	      /*--discrete zero crossings----dzero--------------------*/
	      if (Discrete_Jump == 0)
		{
		  /* if there was a dzero, its event should be activated */
		  phase = 2;
		  if (params_hot == 0)
		    {
		      tn = *told;
		      X_contain_xn = 1;
		      zcrossing_unhandeled = 0;
		    }

		  flag = 0;
		  if (!zcrossing_unhandeled)
		    {
		      if ((t > tn))
			{
			  if (X_contain_xn == 0)
			    {
			      IDAGetSolution (ida_mem, tn, yy, yp);
			    }
			  phase = 0;
			  odoit (&tn, sim_x, sim_xd, tmpneq);
			  phase = 2;
			  flagr = IDASolve (ida_mem, t, told, yy, yp, IDA_ONE_STEP_TSTOP);
			  IDAGetCurrentTime (ida_mem, &tn);
			  if ((flagr == IDA_ZERO_DETACH_RETURN)
			      || (flagr == IDA_ROOT_RETURN))
			    {
			      tzero = *told;
			      zcrossing_unhandeled = flagr;
			      flagr = 0;
			    }

			}
		      X_contain_xn = 1;
		    }
		  if (t <= tn)
		    *told = t;

		  if (zcrossing_unhandeled)
		    {
		      if (t >= tzero - params_ttol)
			{
			  *told = tzero;
			  flagr = zcrossing_unhandeled;
			}
		    }
		  if (*told <= tn)
		    {
		      IDAGetSolution (ida_mem, *told, yy, yp);
		      X_contain_xn = 0;
		    }

		  phase = 1;
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		}
	      else
		{
		  flagr = IDA_ROOT_RETURN;	/* in order to handle discrete jumps */
		  for (jj = 0; jj < sim_ng; ++jj)
		    jroot[jj] = jroottmp[jj];
		}
	      Sfcallerid = 98;
	      if (flagr >= 0)
		{
		  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
		    sciprint ("****Solver reached: %f\r\n", *told);
		  params_hot = 1;
		  cnt = 0;
		}
	      else if (flagr == IDA_TOO_MUCH_WORK || flagr == IDA_CONV_FAIL
		       || flagr == IDA_ERR_FAIL)
		{
		  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
		    sciprint
		      ("**** Solver: too much work at time=%g (stiff region, change RTOL and ATOL)\r\n",
		       *told);
		  params_hot = 0;
		  cnt++;
		  if (cnt > 5)
		    {
		      *ierr = 200 + (-flagr);
		      goto err;
		      return;
		    }
		}
	      else
		{
		  if (flagr < 0)
		    *ierr = 200 + (-flagr);	/* raising errors due to internal errors, other wise erros due to flagr */
		  goto err;
		  return;
		}

	      /*     update outputs of 'c' type  blocks if we are at the end */
	      if (*told >= *tf - params_ttol)
		{
		  phase = 0;
		  odoit (told, sim_x, sim_xd, tmpneq);
		  cdoit (told);
		  goto err;
		  return;
		}

	      if (flagr == IDA_ZERO_DETACH_RETURN)
		{
		  params_hot = 0;
		  zcrossing_unhandeled = 0;
		};		/* new feature of sundials, detects unmasking */
	      if (flagr == IDA_ROOT_RETURN)
		{
		  zcrossing_unhandeled = 0;
		  /*     .        at a least one root has been found */
		  params_hot = 0;
		  if (Discrete_Jump == 0)
		    {
		      flagr = IDAGetRootInfo (ida_mem, jroot);
		      if (check_flag (&flagr, "IDAGetRootInfo", 1))
			{
			  *ierr = 200 + (-flagr);
			  goto err;
			  return;
			}
		    }

		  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
		    {
		      sciprint ("root found at t=: %f\r\n", *told);
		    }
		  /*     .        update outputs affecting ztyp blocks  ONLY FOR OLD BLOCKS */
		  zdoit (told, sim_x, sim_xd, sim_g);
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		  for (jj = 0; jj < sim_ng; ++jj)
		    {
		      params_curblk = zcros[jj];
		      if (params_curblk == -1)
			{
			  break;
			}
		      kev = 0;
		      for (j = sim_zcptr[params_curblk - 1] - 1;
			   j < sim_zcptr[params_curblk - 1 + 1] - 1; ++j)
			{
			  if (jroot[j] != 0)
			    {
			      kev = 1;
			      break;
			    }
			}
		      if (kev != 0)
			{
			  Blocks[params_curblk - 1].jroot =
			    &jroot[sim_zcptr[params_curblk - 1 + 1] - 1];
			  if (sim_funtyp[params_curblk - 1] > 0)
			    {
			      if (Blocks[params_curblk - 1].nevout > 0)
				{
				  /* initialize evout */
				  for (j = 0; j < Blocks[params_curblk - 1].nevout; j++)
				    {
				      Blocks[params_curblk - 1].evout[j] = -1;
				    }
				  flag__ = 3;
				  if (Blocks[params_curblk - 1].nx > 0)
				    {
				      Blocks[params_curblk - 1].x = &sim_x[sim_xptr[params_curblk - 1] - 1];
				      Blocks[params_curblk - 1].xd =&sim_xd[sim_xptr[params_curblk - 1] - 1];
				    }
				  /* call corresponding block to determine output event (kev) */
				  Blocks[params_curblk - 1].nevprt = -kev;
				  callf (told, &Blocks[params_curblk - 1], &flag__);
				  if (flag__ < 0)
				    {
				      *ierr = 5 - flag__;
				      goto err;
				      return;
				    }
				  /*     update event agenda */
				  for (k = 0; k < Blocks[params_curblk - 1].nevout; ++k)
				    {
				      if (isinf (Blocks[params_curblk - 1].evout[k]))
					{
					  i3 = k + sim_clkptr[params_curblk - 1];
					  rmevs (&i3, sim_pointi);
					}
				      
				      if (Blocks[params_curblk - 1].evout[k] >= 0.)
					{
					  i3 = k + sim_clkptr[params_curblk - 1];
					  addevs (Blocks[params_curblk - 1].evout[k] + (*told), &i3, &ierr1);
					}
				    }
				}
			      /* update state */
			      if ((Blocks[params_curblk - 1].nx > 0)
				  || (Blocks[params_curblk - 1].nz > 0)
				  || (Blocks[params_curblk - 1].noz > 0)
				  || (*Blocks[params_curblk - 1].work != NULL))
				{
				  /* call corresponding block to update state */
				  flag__ = 2;
				  if (Blocks[params_curblk - 1].nx > 0)
				    {
				      Blocks[params_curblk - 1].x = &sim_x[sim_xptr[params_curblk - 1] - 1];
				      Blocks[params_curblk - 1].xd =&sim_xd[sim_xptr[params_curblk - 1] - 1];
				    }
				  Blocks[params_curblk - 1].nevprt = -kev;
				  Blocks[params_curblk - 1].xprop = &sim_xprop[sim_xptr[params_curblk - 1] - 1];
				  callf (told, &Blocks[params_curblk - 1], &flag__);
				  if (flag__ < 0)
				    {
				      *ierr = 5 - flag__;
				      goto err;
				      return;
				    }
				  for (j = 0; j < *neq; j++)
				    {	/* Adjust xprop for IDx */
				      if (sim_xprop[j] == 1)
					scicos_xproperty[j] = SUNDIALS_ONE;
				      if (sim_xprop[j] == -1)
					scicos_xproperty[j] = SUNDIALS_ZERO;
				    }
				}
			    }
			}
		    }
		}
	      if (inxsci == 1 && scilab_timer_check () == 1)
		{
		  C2F (sxevents) ();
		  otimer = ntimer;
		  /*     .     sxevents can modify halt */
		}
	      if (params_halt != 0)
		{
		  params_halt = 0;
		  goto err;
		  return;
		}
	      /*--discrete zero crossings----dzero--------------------*/
	      if (sim_ng > 0)
		{
		  /* storing ZC signs just after a ddaskr call */
		  zdoit (told, sim_x, sim_xd, sim_g);
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		  for (jj = 0; jj < sim_ng; ++jj)
		    {
		      if (sim_g[jj] >= 0)
			{
			  jroottmp[jj] = 5;
			}
		      else
			{
			  jroottmp[jj] = -5;
			}
		    }
		}
	      /*--discrete zero crossings----dzero--------------------*/
	    }
	  C2F (realtime) (told);
	}
      else
	{
	  /*     .  t==told */
	  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
	    {
	      sciprint ("Event: %d activated at t=%f\r\n", *sim_pointi, *told);
	    }

	  ddoit (told);
	  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
	    {
	      sciprint ("End of activation");
	    }
	  if (*ierr != 0)
	    {
	      goto err;
	      return;
	    }
	}
      /*     end of main loop on time */
    }
  phase = 0;
  odoit (told, sim_x, sim_xd, tmpneq);
 err:
  if (*neq > 0) FREE (TJacque);
  if (*neq > 0) FREE (ida_data->rwork);
  if ((sim_ng > 0) && (*neq > 0)) FREE (ida_data->gwork);
  if (*neq > 0) N_VDestroy_Serial (ida_data->ewt);
  if (*neq > 0) FREE (ida_data);
  if (*neq > 0) IDAFree (&ida_mem);
  if (*neq > 0) N_VDestroy_Serial (IDx);
  if (*neq > 0) N_VDestroy_Serial (yp);
  if (*neq > 0) N_VDestroy_Serial (yy);
  if (*neq > 0) FREE (tmpneq);
  if (sim_ng > 0) FREE (jroot);
  if (sim_ng > 0) FREE (zcros);
  if (sim_nmod > 0) FREE (Mode_save);
}

void cosend (double *told)
{
  static int flag__;
  static int kfune;
  *ierr = 0;
  /*     loop on blocks */
  for (params_curblk = 1; params_curblk <= sim_nblk; ++params_curblk)
    {
      flag__ = 5;
      Blocks[params_curblk - 1].nevprt = 0;
      if (sim_funtyp[params_curblk - 1] >= 0)
	{
	  if (Blocks[params_curblk - 1].nx > 0)
	    {
	      Blocks[params_curblk - 1].x  =&sim_x[sim_xptr[params_curblk - 1] - 1];
	      Blocks[params_curblk - 1].xd =&sim_xd[sim_xptr[params_curblk - 1] - 1];
	    }
	  callf (told, &Blocks[params_curblk - 1], &flag__);
	  if (flag__ < 0 && *ierr == 0)
	    {
	      *ierr = 5 - flag__;
	      kfune = params_curblk;
	    }
	}
    }
  if (*ierr != 0)
    {
      params_curblk = kfune;
      return;
    }
}

void callf (double *t, scicos_block * block, int *flag)
{
  double *args[SZ_SIZE];
  int sz[SZ_SIZE];
  double intabl[TB_SIZE];
  double outabl[TB_SIZE];

  int ii, in, out, ki, ko, no, ni, k, j;
  int szi, flagi;
  double *ptr_d = NULL;
  /* function pointers type def */
  voidf loc;
  ScicosF0 loc0;
  ScicosF loc1;
  ScicosF2 loc2;
  ScicosF2z loc2z;
  ScicosFi loci1;
  ScicosFi2 loci2;
  ScicosFi2z loci2z;
  ScicosF4 loc4;
  int solver = params_solver;
  int cosd = C2F (cosdebug).cosd;
  scicos_time = *t;
  block_error = flag;

  /* debug block is never called */
  if (block->type == 99)
    return;

  /* flag 7 implicit initialization */
  flagi = *flag;
  /* change flag to zero if flagi==7 for explicit block */
  if (flagi == 7 && block->type < 10000)
    {
      *flag = 0;
    }

  /* do not make a call to the debug blog itself 
   * it is only used to encapsulate call to standard blocks 
   *
   *
   * if (Scicos->sim.debug_block > -1 && Scicos->sim.debug_block + 1 == params_curblk )
   * return;
   */

  /* display information for debugging mode */
  if (cosd > 1 )
    {
      if (cosd != 3)
	{
	  sciprint ("block %d is called ", params_curblk);
	  sciprint ("with flag=%d ", *flag);
	  sciprint ("Phase=%d ", phase);
	  sciprint ("at time %f \r\n", *t);
	}
      if (debug_block > -1)
	{
	  if (cosd != 3)
	    {
	      sciprint ("Entering the block \r\n");
	      fprintf (stderr, "Entering the block=%d  %d %d %p \r\n",
		       debug_block, flagi, *flag, block);
	    }
	  call_debug_scicos (block, flag, flagi, debug_block);
	  if (*flag < 0)
	    {
	      /* a faire en cas de abort */
	      /* Scicos->params.aborted = TRUE; */
	      return; /* error in debug block */
	    }
	}
    }
  C2F (scsptr).ptr = block->scsptr;

  /* get pointer of the function */
  loc = block->funpt;

  /* continuous state */
  if (solver == 100 && block->type < 10000 && *flag == 0)
    {
      ptr_d = block->xd;
      block->xd = block->res;
    }
  /* switch loop */
  switch (block->type)
    {
      /*******************/
      /* function type 0 */
      /*******************/
    case 0:
      {
	/* This is for compatibility */
	/* jroottmp is returned in g for old type */
	if (block->nevprt < 0)
	  {
	    for (j = 0; j < block->ng; ++j)
	      {
		block->g[j] = (double) block->jroot[j];
	      }
	  }

	/* concatenated entries and concatened outputs */
	/* catenate inputs if necessary */
	ni = 0;
	if (block->nin > 1)
	  {
	    ki = 0;
	    for (in = 0; in < block->nin; in++)
	      {
		szi = block->insz[in] * block->insz[in + block->nin];
		for (ii = 0; ii < szi; ii++)
		  {
		    intabl[ki++] = *((double *) (block->inptr[in]) + ii);
		  }
		ni = ni + szi;
	      }
	    args[0] = &(intabl[0]);
	  }
	else
	  {
	    if (block->nin == 0)
	      {
		args[0] = NULL;
	      }
	    else
	      {
		args[0] = (double *) (block->inptr[0]);
		ni = block->insz[0] * block->insz[1];
	      }
	  }

	/* catenate outputs if necessary */
	no = 0;
	if (block->nout > 1)
	  {
	    ko = 0;
	    for (out = 0; out < block->nout; out++)
	      {
		szi = block->outsz[out] * block->outsz[out + block->nout];
		for (ii = 0; ii < szi; ii++)
		  {
		    outabl[ko++] = *((double *) (block->outptr[out]) + ii);
		  }
		no = no + szi;
	      }
	    args[1] = &(outabl[0]);
	  }
	else
	  {
	    if (block->nout == 0)
	      {
		args[1] = NULL;
	      }
	    else
	      {
		args[1] = (double *) (block->outptr[0]);
		no = block->outsz[0] * block->outsz[1];
	      }
	  }

	loc0 = (ScicosF0) loc;

	(*loc0) (flag, &block->nevprt, t, block->xd, block->x, &block->nx,
		 block->z, &block->nz,
		 block->evout, &block->nevout, block->rpar, &block->nrpar,
		 block->ipar, &block->nipar, (double *) args[0], &ni,
		 (double *) args[1], &no);

	/* split output vector on each port if necessary */
	if (block->nout > 1)
	  {
	    ko = 0;
	    for (out = 0; out < block->nout; out++)
	      {
		szi = block->outsz[out] * block->outsz[out + block->nout];
		for (ii = 0; ii < szi; ii++)
		  {
		    *((double *) (block->outptr[out]) + ii) = outabl[ko++];
		  }
	      }
	  }

	/* adjust values of output register */
	for (in = 0; in < block->nevout; ++in)
	  {
	    block->evout[in] = block->evout[in] - *t;
	  }

	break;
      }
      /*******************/
      /* function type 1 */
      /*******************/
    case 1:
      {
	/* This is for compatibility */
	/* jroot is returned in g for old type */
	if (block->nevprt < 0)
	  {
	    for (j = 0; j < block->ng; ++j)
	      {
		block->g[j] = (double) block->jroot[j];
	      }
	  }

	/* one entry for each input or output */
	for (in = 0; in < block->nin; in++)
	  {
	    args[in] = block->inptr[in];
	    sz[in] = block->insz[in];
	  }
	for (out = 0; out < block->nout; out++)
	  {
	    args[in + out] = block->outptr[out];
	    sz[in + out] = block->outsz[out];
	  }
	/* with zero crossing */
	if (block->ztyp > 0)
	  {
	    args[block->nin + block->nout] = block->g;
	    sz[block->nin + block->nout] = block->ng;
	  }

	loc1 = (ScicosF) loc;

	(*loc1) (flag, &block->nevprt, t, block->xd, block->x, &block->nx,
		 block->z, &block->nz,
		 block->evout, &block->nevout, block->rpar, &block->nrpar,
		 block->ipar, &block->nipar,
		 (double *) args[0], &sz[0],
		 (double *) args[1], &sz[1], (double *) args[2], &sz[2],
		 (double *) args[3], &sz[3], (double *) args[4], &sz[4],
		 (double *) args[5], &sz[5], (double *) args[6], &sz[6],
		 (double *) args[7], &sz[7], (double *) args[8], &sz[8],
		 (double *) args[9], &sz[9], (double *) args[10], &sz[10],
		 (double *) args[11], &sz[11], (double *) args[12], &sz[12],
		 (double *) args[13], &sz[13], (double *) args[14], &sz[14],
		 (double *) args[15], &sz[15], (double *) args[16], &sz[16],
		 (double *) args[17], &sz[17]);

	/* adjust values of output register */
	for (in = 0; in < block->nevout; ++in)
	  {
	    block->evout[in] = block->evout[in] - *t;
	  }

	break;
      }

      /*******************/
      /* function type 2 */
      /*******************/
    case 2:
      {
	/* This is for compatibility */
	/* jroot is returned in g for old type */
	if (block->nevprt < 0)
	  {
	    for (j = 0; j < block->ng; ++j)
	      {
		block->g[j] = (double) block->jroot[j];
	      }
	  }

	/* no zero crossing */
	if (block->ztyp == 0)
	  {
	    loc2 = (ScicosF2) loc;
	    (*loc2) (flag, &block->nevprt, t, block->xd, block->x, &block->nx,
		     block->z, &block->nz,
		     block->evout, &block->nevout, block->rpar, &block->nrpar,
		     block->ipar, &block->nipar, (double **) block->inptr,
		     block->insz, &block->nin,
		     (double **) block->outptr, block->outsz, &block->nout);
	  }
	/* with zero crossing */
	else
	  {
	    loc2z = (ScicosF2z) loc;
	    (*loc2z) (flag, &block->nevprt, t, block->xd, block->x,
		      &block->nx, block->z, &block->nz, block->evout,
		      &block->nevout, block->rpar, &block->nrpar, block->ipar,
		      &block->nipar, (double **) block->inptr, block->insz,
		      &block->nin, (double **) block->outptr, block->outsz,
		      &block->nout, block->g, &block->ng);
	  }

	/* adjust values of output register */
	for (in = 0; in < block->nevout; ++in)
	  {
	    block->evout[in] = block->evout[in] - *t;
	  }

	break;
      }
      /*******************/
      /* function type 4 */
      /*******************/
    case 4:
      {
	/* get pointer of the function type 4 */
	loc4 = (ScicosF4) loc;
	(*loc4) (block, *flag);
	break;
      }

      /***********************/
      /* function type 10001 */
      /***********************/
    case 10001:
      {
	/* This is for compatibility */
	/* jroot is returned in g for old type */
	if (block->nevprt < 0)
	  {
	    for (j = 0; j < block->ng; ++j)
	      {
		block->g[j] = (double) block->jroot[j];
	      }
	  }

	/* implicit block one entry for each input or output */
	for (in = 0; in < block->nin; in++)
	  {
	    args[in] = block->inptr[in];
	    sz[in] = block->insz[in];
	  }
	for (out = 0; out < block->nout; out++)
	  {
	    args[in + out] = block->outptr[out];
	    sz[in + out] = block->outsz[out];
	  }
	/* with zero crossing */
	if (block->ztyp > 0)
	  {
	    args[block->nin + block->nout] = block->g;
	    sz[block->nin + block->nout] = block->ng;
	  }

	loci1 = (ScicosFi) loc;
	(*loci1) (flag, &block->nevprt, t, block->res, block->xd, block->x,
		  &block->nx, block->z, &block->nz,
		  block->evout, &block->nevout, block->rpar, &block->nrpar,
		  block->ipar, &block->nipar,
		  (double *) args[0], &sz[0],
		  (double *) args[1], &sz[1], (double *) args[2], &sz[2],
		  (double *) args[3], &sz[3], (double *) args[4], &sz[4],
		  (double *) args[5], &sz[5], (double *) args[6], &sz[6],
		  (double *) args[7], &sz[7], (double *) args[8], &sz[8],
		  (double *) args[9], &sz[9], (double *) args[10], &sz[10],
		  (double *) args[11], &sz[11], (double *) args[12], &sz[12],
		  (double *) args[13], &sz[13], (double *) args[14], &sz[14],
		  (double *) args[15], &sz[15], (double *) args[16], &sz[16],
		  (double *) args[17], &sz[17]);

	/* adjust values of output register */
	for (in = 0; in < block->nevout; ++in)
	  {
	    block->evout[in] = block->evout[in] - *t;
	  }

	break;
      }

      /***********************/
      /* function type 10002 */
      /***********************/
    case 10002:
      {
	/* This is for compatibility */
	/* jroot is returned in g for old type */
	if (block->nevprt < 0)
	  {
	    for (j = 0; j < block->ng; ++j)
	      {
		block->g[j] = (double) block->jroot[j];
	      }
	  }

	/* implicit block, inputs and outputs given by a table of pointers */
	/* no zero crossing */
	if (block->ztyp == 0)
	  {
	    loci2 = (ScicosFi2) loc;
	    (*loci2) (flag, &block->nevprt, t, block->res,
		      block->xd, block->x, &block->nx,
		      block->z, &block->nz,
		      block->evout, &block->nevout, block->rpar,
		      &block->nrpar, block->ipar, &block->nipar,
		      (double **) block->inptr, block->insz, &block->nin,
		      (double **) block->outptr, block->outsz, &block->nout);
	  }
	/* with zero crossing */
	else
	  {
	    loci2z = (ScicosFi2z) loc;
	    (*loci2z) (flag, &block->nevprt, t, block->res,
		       block->xd, block->x, &block->nx,
		       block->z, &block->nz,
		       block->evout, &block->nevout, block->rpar,
		       &block->nrpar, block->ipar, &block->nipar,
		       (double **) block->inptr, block->insz, &block->nin,
		       (double **) block->outptr, block->outsz, &block->nout,
		       block->g, &block->ng);
	  }

	/* adjust values of output register */
	for (in = 0; in < block->nevout; ++in)
	  {
	    block->evout[in] = block->evout[in] - *t;
	  }

	break;
      }
      /***********************/
      /* function type 10004 */
      /***********************/
    case 10004:
      {
	/* get pointer of the function type 4 */
	loc4 = (ScicosF4) loc;
	(*loc4) (block, *flag);
	break;
      }
      /***********/
      /* default */
      /***********/
    default:
      {
	sciprint ("Undefined Function type\r\n");
	*flag = -1000;
	return;			/* exit */
      }
    }

  /* Implicit Solver & explicit block & flag==0 */
  /* adjust continuous state vector after call */
  if (solver == 100 && block->type < 10000 && *flag == 0)
    {
      block->xd = ptr_d;
      if (flagi != 7)
	{
	  for (k = 0; k < block->nx; k++)
	    {
	      block->res[k] = block->res[k] - block->xd[k];
	    }
	}
      else
	{
	  for (k = 0; k < block->nx; k++)
	    {
	      block->xd[k] = block->res[k];
	    }
	}
    }

  /* debug block */
  if (cosd > 1) /*  && Scicos->params.aborted == FALSE) */
    {
      if (debug_block > -1)
	{
	  if (*flag < 0)
	    return;		/* error in block */
	  if (cosd != 3)
	    {
	      sciprint ("Leaving block %d \r\n", params_curblk);
	    }
	  call_debug_scicos (block, flag, flagi, debug_block);
	}
    }
}

void call_debug_scicos (scicos_block * block, int *flag, int flagi, int deb_blk)
{
  voidf loc;
  int solver = params_solver, k;
  ScicosF4 loc4;
  double *ptr_d = NULL;

  C2F (cosdebugcounter).counter = C2F (cosdebugcounter).counter + 1;
  C2F (scsptr).ptr = Blocks[deb_blk].scsptr;

  loc = Blocks[deb_blk].funpt;	/* GLOBAL */
  loc4 = (ScicosF4) loc;

  /* continuous state */
  if (solver == 100 && block->type < 10000 && *flag == 0)
    {
      ptr_d = block->xd;
      block->xd = block->res;
    }
  fprintf (stderr, "In the block=%d  %d %d %p  loc=%p\r\n", deb_blk, flagi,
	   *flag, block, loc);

  (*loc4) (block, *flag);
  fprintf (stderr, "outthe block=%d  %d %d %p \r\n", deb_blk, flagi, *flag,
	   block);

  /* Implicit Solver & explicit block & flag==0 */
  /* adjust continuous state vector after call */
  if (solver == 100 && block->type < 10000 && *flag == 0)
    {
      block->xd = ptr_d;
      if (flagi != 7)
	{
	  for (k = 0; k < block->nx; k++)
	    {
	      block->res[k] = block->res[k] - block->xd[k];
	    }
	}
      else
	{
	  for (k = 0; k < block->nx; k++)
	    {
	      block->xd[k] = block->res[k];
	    }
	}
    }
  /* Note that the value of *flag can have changed during the 
   * call of previous code because flag is also transmited as 
   * a global variable
   */
  if (*flag < 0) sciprint ("Error in the Debug block \r\n");
}

/* simblk: used by lsodar2 */

int C2F (simblk) (int *neq1, double *t, double *xc, double *xcdot)
{
  double c_b14 = 0.;
  int nantest = 0, c1 = 1, i;
  C2F (dset) (neq1, &c_b14, xcdot, &c1);
  C2F (ierode).iero = 0;
  Sfcallerid = C2F (lscallerid).callerid;
  *ierr = 0;
  odoit (t, xc, xcdot, xcdot);
  C2F (ierode).iero = *ierr;
  if (*ierr == 0)
    {
      for (i = 0; i < *neq1; i++)
	{			/* NaN checking */
	  if ((xcdot[i] - xcdot[i] != 0))
	    {
	      sciprint
		("\n\rWarning: The computing function #%d returns a NaN/Inf",
		 i);
	      nantest = 1;
	      break;
	    }
	}
      if (nantest == 1)
	{
	  C2F (ierode).iero = -1;
	  return 0;		/* recoverable error; */
	}
    }


  return 0;
}

void DP5simblk (unsigned n, double t, double *x, double *y, void *udata)
{
  DOPRI5_mem *dopri5_mem = NULL;
  dopri5_mem = ((User_DP5_data *) udata)->dopri5_mem;
  DP5_Get_fcallerid (dopri5_mem, &Sfcallerid);

  C2F (ierode).iero = 0;
  *ierr = 0;
  odoit (&t, x, y, y);
  C2F (ierode).iero = *ierr;
  return;
}


int CVsimblk (realtype t, N_Vector yy, N_Vector yp, void *f_data)
{
  double c_b14 = 0.;
  double tx, *x, *xd;
  int i, nantest, c1 = 1;
  void *cvode_mem;

  cvode_mem = ((User_CV_data) f_data)->cvode_mem;
  CVodeGetfcallerid (cvode_mem, &Sfcallerid);

  tx = (double) t;
  x = (double *) NV_DATA_S (yy);
  xd = (double *) NV_DATA_S (yp);

  /*C2F (simblk)(neq, &tx, x, xd); */
  C2F (dset) (neq, &c_b14, xd, &c1);
  C2F (ierode).iero = 0;
  *ierr = 0;
  odoit (&tx, x, xd, xd);
  C2F (ierode).iero = *ierr;

  if (*ierr == 0)
    {
      nantest = 0;
      for (i = 0; i < *neq; i++)
	{			/* NaN checking */
	  if ((xd[i] - xd[i] != 0))
	    {
	      sciprint
		("\n\rWarning: The computing function #%d returns a NaN/Inf",
		 i);
	      nantest = 1;
	      break;
	    }
	}
      if (nantest == 1)
	return 349;		/* recoverable error; */
    }

  return (Abs (*ierr));		/* ierr>0 recoverable error; ierr>0 unrecoverable error; ierr=0: ok */

}				/* simblk */

/* grblk */
int C2F (grblk) (int *neq1, double *t, double *xc, int *ng1, double *g)
{
  C2F (ierode).iero = 0;
  *ierr = 0;
  zdoit (t, xc, xc, (double *) g);

  C2F (ierode).iero = *ierr;
  return 0;
}

int DP5grblk (unsigned n, double t, double *xc, double *g, void *udata)
{
  double tx = 0;
  /*DOPRI5_mem *dopri5_mem=NULL;
    dopri5_mem = ((User_DP5_data*) udata)->dopri5_mem; */
  tx = t;
  C2F (ierode).iero = 0;
  *ierr = 0;
  zdoit (&tx, xc, xc, (double *) g);

  C2F (ierode).iero = *ierr;
  return 0;
}

int CVgrblk (realtype t, N_Vector yy, realtype *gout, void *g_data)
{
  double tx, *x;
  int jj, nantest;

  tx = (double) t;
  x = (double *) NV_DATA_S (yy);
  C2F (grblk) (neq, &tx, x, &sim_ng, (double *) gout);

  if (*ierr == 0)
    {
      nantest = 0;
      for (jj = 0; jj < sim_ng; jj++)
	if (gout[jj] - gout[jj] != 0)
	  {
	    sciprint
	      ("\n\rWarning: The zero_crossing function #%d returns a NaN/Inf",
	       jj);
	    nantest = 1;
	    break;
	  }			/* NaN checking */
      if (nantest == 1)
	return 350;		/* recoverable error; */
    }
  C2F (ierode).iero = *ierr;

  return 0;
}				/* grblk */

/* simblkdaskr */

int simblkdaskr (realtype tres, N_Vector yy, N_Vector yp, N_Vector resval, void *rdata)
{
  int c1 = 1;
  double tx;
  double *xc, *xcdot, *residual;
  realtype daskr_alpha;
  void *ida_mem;

  User_IDA_data ida_data;

  realtype hh;
  int qlast;
  int jj, flag, nantest;

  ida_data = (User_IDA_data) rdata;
  ida_mem = ida_data->ida_mem;
  IDAGetfcallerid (ida_mem, &Sfcallerid);

  if (!areModesFixed (block))
    {
      /* Just to update mode in a very special case, i.e., when initialization using modes fails.
       * in this case, we relax all modes and try again one more time.
       */
      zdoit (&tx, NV_DATA_S (yy), NV_DATA_S (yp), (double *) ida_data->gwork);
    }


  hh = SUNDIALS_ZERO;
  flag = IDAGetCurrentStep (ida_mem, &hh);
  if (flag < 0)
    {
      *ierr = 200 + (-flag);
      return (*ierr);
    };

  qlast = 0;
  flag = IDAGetCurrentOrder (ida_mem, &qlast);
  if (flag < 0)
    {
      *ierr = 200 + (-flag);
      return (*ierr);
    };

  daskr_alpha = SUNDIALS_ZERO;
  for (jj = 0; jj < qlast; jj++)
    daskr_alpha = daskr_alpha - SUNDIALS_ONE / (jj + 1);
  if (hh != 0)
    CJ = - daskr_alpha / hh;
  else
    {
      *ierr = 217;
      return (*ierr);
    }
  for (jj = 0; jj < *neq; jj++)
    {
      sim_beta[jj] = CJ;
    }

  xc = (double *) NV_DATA_S (yy);
  xcdot = (double *) NV_DATA_S (yp);
  residual = (double *) NV_DATA_S (resval);
  tx = (double) tres;

  C2F (dcopy) (neq, xcdot, &c1, residual, &c1);
  *ierr = 0;
  C2F (ierode).iero = 0;
  odoit (&tx, xc, xcdot, residual);

  C2F (ierode).iero = *ierr;

  if (*ierr == 0)
    {
      nantest = 0;
      for (jj = 0; jj < *neq; jj++)
	if (residual[jj] - residual[jj] != 0)
	  {			/* NaN checking */
	    /* sciprint("\n\rWarning: The residual function #%d returns a NaN",jj); */
	    nantest = 1;
	    break;
	  }
      if (nantest == 1)
	return 257;		/* recoverable error; */
    }

  return (Abs (*ierr));		/* ierr>0 recoverable error; ierr>0 unrecoverable error; ierr=0: ok */
}				/* simblkdaskr */


int grblkdaskr (realtype t, N_Vector yy, N_Vector yp, realtype *gout, void *g_data)
{
  double tx = (double) t;
  int jj, nantest;
  
  *ierr = 0;
  C2F (ierode).iero = 0;
  zdoit (&tx, NV_DATA_S (yy), NV_DATA_S (yp), (double *) gout);
  if (*ierr == 0)
    {
      nantest = 0;		/* NaN checking */
      for (jj = 0; jj < sim_ng; jj++)
	{
	  if (gout[jj] - gout[jj] != 0)
	    {
	      sciprint
		("\n\rWarning: The zero-crossing function #%d returns a NaN",
		 jj);
	      nantest = 1;
	      break;
	    }
	}
      if (nantest == 1)
	{
	  return 258;		/* recoverable error; */
	}
    }
  C2F (ierode).iero = *ierr;
  return (*ierr);
}				/* grblkdaskr */

void rmevs (int * evtnb, int *xpointi)
{
  int k;
  if (sim_evtspt[*evtnb - 1] != -1)
    {
      if ((sim_evtspt[*evtnb - 1] == 0) && (*xpointi == *evtnb))
	{
	  sim_evtspt[*evtnb - 1] = -1;
	  *xpointi = 0;
	}
      else if (*xpointi == *evtnb)
	{
	  *xpointi = sim_evtspt[*evtnb - 1];
	  sim_evtspt[*evtnb - 1] = -1;
	}
      else
	{
	  k = *xpointi;
	  while (*evtnb != sim_evtspt[k - 1])
	    {
	      k = sim_evtspt[k - 1];
	    }
	  sim_evtspt[k - 1] = sim_evtspt[*evtnb - 1];
	  sim_evtspt[*evtnb - 1] = -1;
	}
    }
}

void addevs (double t, int *evtnb, int *ierr1)
{
  static int TCritWarning = 0;
  static int i, j;

  *ierr1 = 0;
  if (sim_evtspt[*evtnb - 1] != -1)
    {
      if (TCritWarning == 0)
	{
	  sciprint("\n\r Warning: an event is reprogrammed at t=%g by removing another", t);
	  sciprint("\n\r    (already programmed) event at  t=%g. There may be an error in",sim_tevts[*evtnb - 1]);
	  sciprint("\n\r    your model. Please check your model. This warning is reported once.\n\r");
	  TCritWarning = 1;
	}
      if ((sim_evtspt[*evtnb - 1] == 0) && (*sim_pointi == *evtnb))
	{
	  sim_tevts[*evtnb - 1] = t;
	  return;
	}
      else
	{
	  if (*sim_pointi == *evtnb)
	    {
	      *sim_pointi = sim_evtspt[*evtnb - 1];	/* remove from chain */
	    }
	  else
	    {
	      i = *sim_pointi;
	      while (*evtnb != sim_evtspt[i - 1])
		{
		  i = sim_evtspt[i - 1];
		}
	      sim_evtspt[i - 1] = sim_evtspt[*evtnb - 1];	/* remove old evtnb from chain */

	      /* do_cold_restart(): Now done before call to simulator
	       * the erased event could be a critical
	       * event, so do_cold_restart is added to
	       * refresh the critical event table 
	       */
	    }
	  sim_evtspt[*evtnb - 1] = 0;
	  sim_tevts[*evtnb - 1] = t;
	}
    }
  else
    {
      sim_evtspt[*evtnb - 1] = 0;
      sim_tevts[*evtnb - 1] = t;
    }
  if (*sim_pointi == 0)
    {
      *sim_pointi = *evtnb;
      return;
    }
  if (t < sim_tevts[*sim_pointi - 1])
    {
      sim_evtspt[*evtnb - 1] = *sim_pointi;
      *sim_pointi = *evtnb;
      return;
    }
  i = *sim_pointi;

 L100:
  if (sim_evtspt[i - 1] == 0)
    {
      sim_evtspt[i - 1] = *evtnb;
      return;
    }
  if (t >= sim_tevts[sim_evtspt[i - 1 - 1] - 1])
    {
      j = sim_evtspt[i - 1];
      if (sim_evtspt[j - 1] == 0)
	{
	  sim_evtspt[j - 1] = *evtnb;
	  return;
	}
      i = j;
      goto L100;
    }
  else
    {
      sim_evtspt[*evtnb - 1] = sim_evtspt[i - 1];
      sim_evtspt[i - 1] = *evtnb;
    }
}

void putevs (double *t, int *evtnb, int *ierr1)
{
  *ierr1 = 0;
  if (sim_evtspt[*evtnb - 1] != -1)
    {
      *ierr1 = 1;
      return;
    }
  else
    {
      sim_evtspt[*evtnb - 1] = 0;
      sim_tevts[*evtnb - 1] = *t;
    }
  if (*sim_pointi == 0)
    {
      *sim_pointi = *evtnb;
      return;
    }
  sim_evtspt[*evtnb - 1] = *sim_pointi;
  *sim_pointi = *evtnb;
}

void idoit (double *told)
{
  /* initialisation (propagation of constant blocks outputs) */
  /*     Copyright INRIA */
  int i2;
  int flag;
  int i, j;
  int ierr1;
  int *kf;

  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
    sciprint ("  idoit(): %f\r\n", *told);

  flag = 1;
  for (j = 0; j < sim_niord; j++)
    {
      kf = &sim_iord[j];
      params_curblk = *kf;	/* */
      if (sim_funtyp[*kf - 1] > -1)
	{
	  /* continuous state */
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      Blocks[*kf - 1].x = &sim_x[sim_xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &sim_xd[sim_xptr[*kf - 1] - 1];
	    }
	  Blocks[*kf - 1].nevprt = sim_iord[j + sim_niord];
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}
      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (sim_funtyp[*kf - 1] < 0)
	    {
	      i = synchro_nev (*kf, ierr);
	      if (*ierr != 0)
		{
		  return;
		}
	      i2 = i + sim_clkptr[*kf - 1] - 1;
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      doit (told);
	      if (*ierr != 0)
		{
		  return;
		}
	    }
	}
    }
}

void doit (double *told)
{				/* propagation of blocks outputs on discrete activations */
  /*     Copyright INRIA */

  int i, i2;
  int flag, nord;
  int ierr1;
  int ii, kever;
  int *kf;

  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
    sciprint ("  doit(): %f\r\n", *told);

  kever = *sim_pointi;
  *sim_pointi = sim_evtspt[kever - 1];
  sim_evtspt[kever - 1] = -1;

  nord = sim_ordptr[kever] - sim_ordptr[kever - 1];
  if (nord == 0)
    {
      return;
    }

  for (ii = sim_ordptr[kever - 1]; ii <= sim_ordptr[kever] - 1; ii++)
    {
      kf = &sim_ordclk[ii - 1];
      params_curblk = *kf;
      if (sim_funtyp[*kf - 1] > -1)
	{
	  /* continuous state */
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      Blocks[*kf - 1].x = &sim_x[sim_xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &sim_xd[sim_xptr[*kf - 1] - 1];
	    }
	  Blocks[*kf - 1].nevprt = Abs (sim_ordclk[ii + sim_nordclk - 1]);
	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      /* Initialize tvec */
      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (sim_funtyp[*kf - 1] < 0)
	    {
	      i = synchro_nev (*kf, ierr);
	      if (*ierr != 0)
		{
		  return;
		}
	      i2 = i + sim_clkptr[*kf - 1] - 1;
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      doit (told);
	      if (*ierr != 0)
		{
		  return;
		}
	    }
	}
    }
}

void cdoit (double *told)
{
  /* propagation of continuous blocks outputs */
  /*     Copyright INRIA */
  int i2;
  int flag;
  int ierr1;
  int i, j;
  int *kf;

  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
    sciprint ("  cdoit(): %f\r\n", *told);

  /* Function Body */
  for (j = 0; j < sim_ncord; j++)
    {
      kf = &sim_cord[j];
      params_curblk = *kf;
      /* continuous state */
      if (Blocks[*kf - 1].nx > 0)
	{
	  Blocks[*kf - 1].x = &sim_x[sim_xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].xd = &sim_xd[sim_xptr[*kf - 1] - 1];
	}
      Blocks[*kf - 1].nevprt = sim_cord[j + sim_ncord];
      if (sim_funtyp[*kf - 1] > -1)
	{
	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      /* Initialize tvec */
      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (sim_funtyp[*kf - 1] < 0)
	    {
	      i = synchro_nev (*kf, ierr);
	      if (*ierr != 0)
		{
		  return;
		}
	      i2 = i + sim_clkptr[*kf - 1] - 1;
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      doit (told);
	      if (*ierr != 0)
		{
		  return;
		}
	    }
	}
    }
}

void ddoit (double *told)
{
  /* update states & event out on discrete activations */
  /*     Copyright INRIA */
  int i2, j;
  int flag, kiwa;
  int i, i3, ierr1;
  int ii, keve;
  int *kf;

  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
    sciprint ("  ddoit(): %f\r\n", *told);

  /* Function Body */
  kiwa = 0;
  edoit (told, &kiwa);
  if (*ierr != 0)
    {
      return;
    }

  /* update continuous and discrete states on event */
  if (kiwa == 0)
    {
      return;
    }
  for (i = 0; i < kiwa; i++)
    {
      keve = sim_iwa[i];
      if (sim_critev[keve - 1] != 0)
	{
	  params_hot = 0;
	}
      i2 = sim_ordptr[keve] - 1;
      for (ii = sim_ordptr[keve - 1]; ii <= i2; ii++)
	{
	  kf = &sim_ordclk[ii - 1];
	  params_curblk = *kf;
	  /* continuous state */
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      Blocks[*kf - 1].x = &sim_x[sim_xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &sim_xd[sim_xptr[*kf - 1] - 1];
	    }

	  Blocks[*kf - 1].nevprt = sim_ordclk[ii + sim_nordclk - 1];

	  if (Blocks[*kf - 1].nevout > 0)
	    {
	      if (sim_funtyp[*kf - 1] >= 0)
		{
		  /* initialize evout */
		  for (j = 0; j < Blocks[*kf - 1].nevout; j++)
		    {
		      Blocks[*kf - 1].evout[j] = -1;
		    }
		  flag = 3;

		  if (Blocks[*kf - 1].nevprt > 0)
		    {		/* if event has continuous origin don't call */
		      callf (told, &Blocks[*kf - 1], &flag);
		      if (flag < 0)
			{
			  *ierr = 5 - flag;
			  return;
			}
		    }

		  for (j = 0; j < Blocks[*kf - 1].nevout; j++)
		    {
		      if (isinf (Blocks[*kf - 1].evout[j]))
			{
			  i3 = j + sim_clkptr[*kf - 1];
			  rmevs (&i3, sim_pointi);
			}
		      if (Blocks[*kf - 1].evout[j] >= 0.)
			{
			  i3 = j + sim_clkptr[*kf - 1];
			  addevs (Blocks[*kf - 1].evout[j] + (*told), &i3, &ierr1);
			}
		    }
		}
	    }

	  if (Blocks[*kf - 1].nevprt > 0)
	    {
	      if (Blocks[*kf - 1].nx + Blocks[*kf - 1].nz + Blocks[*kf - 1].noz > 0
		  || *Blocks[*kf - 1].work != NULL)
		{
		  /*  if a hidden state exists, must also call (for new scope eg)  */
		  /*  to avoid calling non-real activations */
		  flag = 2;
		  callf (told, &Blocks[*kf - 1], &flag);
		  if (flag < 0)
		    {
		      *ierr = 5 - flag;
		      return;
		    }
		}
	    }
	  else
	    {
	      if (*Blocks[*kf - 1].work != NULL)
		{
		  flag = 2;
		  Blocks[*kf - 1].nevprt = 0;	/* in case some hidden continuous blocks need updating */
		  callf (told, &Blocks[*kf - 1], &flag);
		  if (flag < 0)
		    {
		      *ierr = 5 - flag;
		      return;
		    }
		}
	    }
	}
    }
}

void edoit (double *told, int *kiwa)
{
  /* update blocks output on discrete activations */
  /*     Copyright INRIA */
  int i2;
  int flag;
  int ierr1, i;
  int kever, ii;
  int *kf;
  int nord;

  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
    sciprint ("  edoit(): %f\r\n", *told);

  /* Function Body */
  kever = *sim_pointi;

  *sim_pointi = sim_evtspt[kever - 1];
  sim_evtspt[kever - 1] = -1;

  nord = sim_ordptr[kever] - sim_ordptr[kever - 1];
  if (nord == 0)
    {
      return;
    }
  sim_iwa[*kiwa] = kever;
  ++(*kiwa);
  for (ii = sim_ordptr[kever - 1]; ii <= sim_ordptr[kever] - 1; ii++)
    {
      kf = &sim_ordclk[ii - 1];
      params_curblk = *kf;

      if (sim_funtyp[*kf - 1] > -1)
	{
	  /* continuous state */
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      Blocks[*kf - 1].x = &sim_x[sim_xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &sim_xd[sim_xptr[*kf - 1] - 1];
	    }

	  Blocks[*kf - 1].nevprt = Abs (sim_ordclk[ii + sim_nordclk - 1]);

	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      /* Initialize tvec */
      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (sim_funtyp[*kf - 1] < 0)
	    {
	      i = synchro_nev (*kf, ierr);
	      if (*ierr != 0)
		{
		  return;
		}
	      i2 = i + sim_clkptr[*kf - 1] - 1;
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      edoit (told, kiwa);
	      if (*ierr != 0)
		{
		  return;
		}
	    }
	}
    }
}

void odoit (double *told, double *xt, double *xtd, double *residual)
{
  /* update blocks derivative of continuous time block */
  /*     Copyright INRIA */
  int i2;
  int flag, keve, kiwa;
  int ierr1, i;
  int ii, jj;
  int *kf;

  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
    sciprint ("  odoit(): %f\r\n", *told);

  /* Function Body */
  kiwa = 0;
  for (jj = 0; jj < sim_noord; jj++)
    {
      kf = &sim_oord[jj];
      params_curblk = *kf;
      /* continuous state */
      if (Blocks[*kf - 1].nx > 0)
	{
	  Blocks[*kf - 1].x = &xt[sim_xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].xd = &xtd[sim_xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].res = &residual[sim_xptr[*kf - 1] - 1];
	}

      Blocks[*kf - 1].nevprt = sim_oord[jj + sim_noord];
      if (sim_funtyp[*kf - 1] > -1)
	{
	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (sim_funtyp[*kf - 1] < 0)
	    {
	      if (Blocks[*kf - 1].nmode > 0)
		{
		  i2 =
		    Blocks[*kf - 1].mode[0] + sim_clkptr[*kf - 1] - 1;
		}
	      else
		{
		  i = synchro_nev (*kf, ierr);
		  if (*ierr != 0)
		    {
		      return;
		    }
		  i2 = i + sim_clkptr[*kf - 1] - 1;
		}
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      ozdoit (told, xt, xtd, &kiwa);
	      if (*ierr != 0)
		{
		  return;
		}
	    }
	}
    }

  /*  update states derivatives */
  for (ii = 0; ii < sim_noord; ii++)
    {
      kf = &sim_oord[ii];
      params_curblk = *kf;
      if (Blocks[*kf - 1].nx > 0 || *Blocks[*kf - 1].work != NULL)
	{
	  /* work tests if a hidden state exists, used for delay block */
	  switch (phase)
	    {
	    case 0:
	    case 1:
	      flag = 2;
	      Blocks[*kf - 1].nevprt = 0;
	      break;
	    case 2:
	    default:
	      flag = 0;
	      Blocks[*kf - 1].nevprt = sim_oord[ii + sim_noord];
	      break;
	    }

	  /* continuous state */
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      Blocks[*kf - 1].x = &xt[sim_xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &xtd[sim_xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].res = &residual[sim_xptr[*kf - 1] - 1];
	    }
	  callf (told, &Blocks[*kf - 1], &flag);

	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}
    }

  for (i = 0; i < kiwa; i++)
    {
      keve = sim_iwa[i];
      for (ii = sim_ordptr[keve - 1]; ii <= sim_ordptr[keve] - 1; ii++)
	{
	  kf = &sim_ordclk[ii - 1];
	  params_curblk = *kf;
	  if (Blocks[*kf - 1].nx > 0 || *Blocks[*kf - 1].work != NULL)
	    {
	      /* work tests if a hidden state exists */
	      switch (phase)
		{
		case 0:
		case 1:
		  flag = 2;
		  Blocks[*kf - 1].nevprt = 0;
		  break;
		case 2:
		default:
		  flag = 0;
		  Blocks[*kf - 1].nevprt = sim_oord[ii + sim_noord];
		  break;
		}
	      /* continuous state */
	      if (Blocks[*kf - 1].nx > 0)
		{
		  Blocks[*kf - 1].x = &xt[sim_xptr[*kf - 1] - 1];
		  Blocks[*kf - 1].xd = &xtd[sim_xptr[*kf - 1] - 1];
		  Blocks[*kf - 1].res = &residual[sim_xptr[*kf - 1] - 1];
		}
	      Blocks[*kf - 1].nevprt = Abs (sim_ordclk[ii + sim_nordclk - 1]);
	      callf (told, &Blocks[*kf - 1], &flag);

	      if (flag < 0)
		{
		  *ierr = 5 - flag;
		  return;
		}
	    }
	}
    }
}

void reinitdoit (double *told)
{
  /* update blocks xproperties of continuous time block */
  /*     Copyright INRIA */
  int i2;
  int flag, keve, kiwa;
  int ierr1, i;
  int ii, jj;
  int *kf;

  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
    sciprint ("  reinitdoit(): %f\r\n", *told);

  /* Function Body */
  kiwa = 0;
  for (jj = 0; jj < sim_noord; jj++)
    {
      kf = &sim_oord[jj];
      params_curblk = *kf;
      /* continuous state */
      if (Blocks[*kf - 1].nx > 0)
	{
	  Blocks[*kf - 1].x = &sim_x[sim_xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].xd = &sim_xd[sim_xptr[*kf - 1] - 1];
	}
      Blocks[*kf - 1].nevprt = sim_oord[jj + sim_noord];
      if (sim_funtyp[*kf - 1] > -1)
	{
	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      if (Blocks[*kf - 1].nevout > 0 && sim_funtyp[*kf - 1] < 0)
	{
	  i = synchro_nev (*kf, ierr);
	  if (*ierr != 0)
	    {
	      return;
	    }
	  if (Blocks[*kf - 1].nmode > 0)
	    {
	      Blocks[*kf - 1].mode[0] = i;
	    }
	  i2 = i + sim_clkptr[*kf - 1] - 1;
	  putevs (told, &i2, &ierr1);
	  if (ierr1 != 0)
	    {
	      /* event conflict */
	      *ierr = 3;
	      return;
	    }
	  doit (told);
	  if (*ierr != 0)
	    {
	      return;
	    }
	}
    }

  /* re-initialize */
  for (ii = 0; ii < sim_noord; ii++)
    {
      kf = &sim_oord[ii];
      params_curblk = *kf;
      if (Blocks[*kf - 1].nx > 0)
	{
	  flag = 7;
	  Blocks[*kf - 1].x = &sim_x[sim_xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].xd = &sim_xd[sim_xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].res = &sim_xd[sim_xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].nevprt = sim_oord[ii + sim_noord];
	  Blocks[*kf - 1].xprop = &sim_xprop[sim_xptr[*kf - 1] - 1];
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}
    }

  for (i = 0; i < kiwa; i++)
    {
      keve = sim_iwa[i];
      for (ii = sim_ordptr[keve - 1]; ii <= sim_ordptr[keve] - 1; ii++)
	{
	  kf = &sim_ordclk[ii - 1];
	  params_curblk = *kf;
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      flag = 7;
	      Blocks[*kf - 1].x = &sim_x[sim_xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &sim_xd[sim_xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].res = &sim_xd[sim_xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].nevprt = Abs (sim_ordclk[ii + sim_nordclk - 1]);
	      Blocks[*kf - 1].xprop = &sim_xprop[sim_xptr[*kf - 1] - 1];
	      callf (told, &Blocks[*kf - 1], &flag);
	      if (flag < 0)
		{
		  *ierr = 5 - flag;
		  return;
		}
	    }
	}
    }
}

void ozdoit (double *told, double *xt, double *xtd, int *kiwa)
{
  /* update blocks output of continuous time block on discrete activations */
  /*     Copyright INRIA */
  int i2;
  int flag, nord;
  int ierr1, i;
  int ii, kever;
  int *kf;

  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
    sciprint ("  ozdoit(): %f\r\n", *told);

  /* Function Body */
  kever = *sim_pointi;
  *sim_pointi = sim_evtspt[kever - 1];
  sim_evtspt[kever - 1] = -1;

  nord = sim_ordptr[kever] - sim_ordptr[kever - 1];
  if (nord == 0)
    {
      return;
    }
  sim_iwa[*kiwa] = kever;
  ++(*kiwa);

  for (ii = sim_ordptr[kever - 1]; ii <= sim_ordptr[kever] - 1; ii++)
    {
      kf = &sim_ordclk[ii - 1];
      params_curblk = *kf;
      if (sim_funtyp[*kf - 1] > -1)
	{
	  /* continuous state */
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      Blocks[*kf - 1].x = &xt[sim_xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &xtd[sim_xptr[*kf - 1] - 1];
	    }
	  Blocks[*kf - 1].nevprt = Abs (sim_ordclk[ii + sim_nordclk - 1]);
	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      /* Initialize tvec */
      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (sim_funtyp[*kf - 1] < 0)
	    {
	      if (phase == 1 || Blocks[*kf - 1].nmode == 0)
		{
		  i = synchro_nev (*kf, ierr);
		  if (*ierr != 0)
		    {
		      return;
		    }
		}
	      else
		{
		  i = Blocks[*kf - 1].mode[0];
		}
	      i2 = i + sim_clkptr[*kf - 1] - 1;
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      ozdoit (told, xt, xtd, kiwa);
	    }
	}
    }
}

void zdoit (double *told, double *xt, double *xtd, double *g)
{
  /* update blocks zcross of continuous time block  */
  int i2;
  int flag, keve, kiwa;
  int ierr1, i, j;
  int ii, jj;
  int *kf;

  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
    sciprint ("  zdoit(): %f\r\n", *told);

  /* Function Body */
  for (i = 0; i < sim_ng; i++)
    {
      g[i] = 0.;
    }

  kiwa = 0;
  for (jj = 0; jj < sim_nzord; jj++)
    {
      kf = &sim_zord[jj];
      params_curblk = *kf;
      /* continuous state */
      if (Blocks[*kf - 1].nx > 0)
	{
	  Blocks[*kf - 1].x = &xt[sim_xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].xd = &xtd[sim_xptr[*kf - 1] - 1];
	}
      Blocks[*kf - 1].nevprt = sim_zord[jj + sim_nzord];

      if (sim_funtyp[*kf - 1] > -1)
	{
	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      /* Initialize tvec */
      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (sim_funtyp[*kf - 1] < 0)
	    {
	      if (phase == 1 || Blocks[*kf - 1].nmode == 0)
		{
		  i = synchro_nev (*kf, ierr);
		  if (*ierr != 0)
		    {
		      return;
		    }
		}
	      else
		{
		  i = Blocks[*kf - 1].mode[0];
		}
	      i2 = i + sim_clkptr[*kf - 1] - 1;
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      ozdoit (told, xt, xtd, &kiwa);
	      if (*ierr != 0)
		{
		  return;
		}
	    }
	}
    }

  /* update zero crossing surfaces */
  for (ii = 0; ii < sim_nzord; ii++)
    {
      kf = &sim_zord[ii];
      params_curblk = *kf;
      if (Blocks[*kf - 1].ng > 0)
	{
	  /* update g array ptr */
	  Blocks[*kf - 1].g = &g[sim_zcptr[*kf - 1] - 1];
	  if (sim_funtyp[*kf - 1] > 0)
	    {
	      flag = 9;
	      /* continuous state */
	      if (Blocks[*kf - 1].nx > 0)
		{
		  Blocks[*kf - 1].x = &xt[sim_xptr[*kf - 1] - 1];
		  Blocks[*kf - 1].xd = &xtd[sim_xptr[*kf - 1] - 1];
		}
	      Blocks[*kf - 1].nevprt = sim_zord[ii + sim_nzord];
	      callf (told, &Blocks[*kf - 1], &flag);
	      if (flag < 0)
		{
		  *ierr = 5 - flag;
		  return;
		}
	    }
	  else
	    {
	      j = synchro_g_nev (g, *kf, ierr);
	      if (*ierr != 0)
		{
		  return;
		}
	      if ((phase == 1) && (Blocks[*kf - 1].nmode > 0))
		{
		  Blocks[*kf - 1].mode[0] = j;
		}
	    }
	}
    }
  
  for (i = 0; i < kiwa; i++)
    {
      keve = sim_iwa[i];
      for (ii = sim_ordptr[keve - 1]; ii <= sim_ordptr[keve] - 1; ii++)
	{
	  kf = &sim_ordclk[ii - 1];
	  params_curblk = *kf;
	  if (Blocks[*kf - 1].ng > 0)
	    {
	      /* update g array ptr */
	      Blocks[*kf - 1].g = &g[sim_zcptr[*kf - 1] - 1];
	      if (sim_funtyp[*kf - 1] > 0)
		{
		  flag = 9;
		  /* continuous state */
		  if (Blocks[*kf - 1].nx > 0)
		    {
		      Blocks[*kf - 1].x = &xt[sim_xptr[*kf - 1] - 1];
		      Blocks[*kf - 1].xd = &xtd[sim_xptr[*kf - 1] - 1];
		    }
		  Blocks[*kf - 1].nevprt = Abs (sim_ordclk[ii + sim_nordclk - 1]);
		  callf (told, &Blocks[*kf - 1], &flag);
		  if (flag < 0)
		    {
		      *ierr = 5 - flag;
		      return;
		    }
		}
	      else
		{
		  j = synchro_g_nev (g, *kf, ierr);
		  if (*ierr != 0)
		    {
		      return;
		    }
		  if ((phase == 1) && (Blocks[*kf - 1].nmode > 0))
		    {
		      Blocks[*kf - 1].mode[0] = j;
		    }
		}
	    }
	}
    }
}

void Jdoit (double *told, double *xt, double *xtd, double *residual, int *job)
{
  /* update blocks jacobian of continuous time block  */
  /*     Copyright INRIA */
  int i2;
  int flag, keve, kiwa;
  int ierr1, i;
  int ii, jj;
  int *kf;

  if ((C2F (cosdebug).cosd >= 1) && (C2F (cosdebug).cosd != 3))
    sciprint ("  Jdoit(): %f\r\n", *told);

  /* Function Body */
  kiwa = 0;
  for (jj = 0; jj < sim_noord; jj++)
    {
      kf = &sim_oord[jj];
      params_curblk = *kf;
      Blocks[*kf - 1].nevprt = sim_oord[jj + sim_noord];
      if (sim_funtyp[*kf - 1] > -1)
	{
	  flag = 1;
	  /* applying desired output */
	  if ((*job == 2) && (sim_oord[jj] == AJacobian_block))
	    {
	    }
	  else
	    /* continuous state */
	    if (Blocks[*kf - 1].nx > 0)
	      {
		Blocks[*kf - 1].x = &xt[sim_xptr[*kf - 1] - 1];
		Blocks[*kf - 1].xd = &xtd[sim_xptr[*kf - 1] - 1];
		Blocks[*kf - 1].res = &residual[sim_xptr[*kf - 1] - 1];
	      }

	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (sim_funtyp[*kf - 1] < 0)
	    {
	      if (Blocks[*kf - 1].nmode > 0)
		{
		  i2 = Blocks[*kf - 1].mode[0] + sim_clkptr[*kf - 1] - 1;
		}
	      else
		{
		  i = synchro_nev (*kf, ierr);
		  if (*ierr != 0)
		    {
		      return;
		    }
		  i2 = i + sim_clkptr[*kf - 1] - 1;
		}
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      ozdoit (told, xt, xtd, &kiwa);
	    }
	}
    }

  /* update states derivatives */
  for (ii = 0; ii < sim_noord; ii++)
    {
      kf = &sim_oord[ii];
      params_curblk = *kf;
      if (Blocks[*kf - 1].nx > 0 || *Blocks[*kf - 1].work != NULL)
	{
	  /* work tests if a hidden state exists, used for delay block */
	  flag = 0;
	  if (((*job == 1) && (sim_oord[ii] == AJacobian_block))
	      || (*job != 1))
	    {
	      if (*job == 1)
		flag = 10;
	      /* continuous state */
	      if (Blocks[*kf - 1].nx > 0)
		{
		  Blocks[*kf - 1].x = &xt[sim_xptr[*kf - 1] - 1];
		  Blocks[*kf - 1].xd = &xtd[sim_xptr[*kf - 1] - 1];
		  Blocks[*kf - 1].res = &residual[sim_xptr[*kf - 1] - 1];
		}
	      Blocks[*kf - 1].nevprt = sim_oord[ii + sim_noord];
	      callf (told, &Blocks[*kf - 1], &flag);
	    }
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}
    }

  for (i = 0; i < kiwa; i++)
    {
      keve = sim_iwa[i];
      for (ii = sim_ordptr[keve - 1]; ii <= sim_ordptr[keve] - 1; ii++)
	{
	  kf = &sim_ordclk[ii - 1];
	  params_curblk = *kf;
	  if (Blocks[*kf - 1].nx > 0 || *Blocks[*kf - 1].work != NULL)
	    {
	      /* work tests if a hidden state exists */
	      flag = 0;
	      if (((*job == 1) && (sim_oord[ii - 1] == AJacobian_block))
		  || (*job != 1))
		{
		  if (*job == 1)
		    flag = 10;
		  /* continuous state */
		  if (Blocks[*kf - 1].nx > 0)
		    {
		      Blocks[*kf - 1].x = &xt[sim_xptr[*kf - 1] - 1];
		      Blocks[*kf - 1].xd = &xtd[sim_xptr[*kf - 1] - 1];
		      Blocks[*kf - 1].res = &residual[sim_xptr[*kf - 1] - 1];
		    }
		  Blocks[*kf - 1].nevprt = Abs (sim_ordclk[ii + sim_nordclk - 1]);
		  callf (told, &Blocks[*kf - 1], &flag);
		}
	      if (flag < 0)
		{
		  *ierr = 5 - flag;
		  return;
		}
	    }
	}
    }
}

int synchro_nev (int kf, int *ierr)
{
  /* synchro blocks computation  */
  SCSREAL_COP *outtbdptr;	/*to store double of outtb */
  SCSINT8_COP *outtbcptr;	/*to store int8 of outtb */
  SCSINT16_COP *outtbsptr;	/*to store int16 of outtb */
  SCSINT32_COP *outtblptr;	/*to store int32 of outtb */
  SCSUINT8_COP *outtbucptr;	/*to store unsigned int8 of outtb */
  SCSUINT16_COP *outtbusptr;	/*to store unsigned int16 of outtb */
  SCSUINT32_COP *outtbulptr;	/*to store unsigned int32 of outtb */

  int cond;
  int i = 0;			/* return 0 by default */
  /* if-then-else blk */
  if (sim_funtyp[kf - 1] == -1)
    {
      switch (sim_outtbtyp[sim_inplnk[sim_inpptr[kf - 1] - 1] - 1])
	{
	case SCSREAL_N:
	  outtbdptr =
	    (SCSREAL_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  cond = (*outtbdptr <= 0.);
	  break;

	case SCSCOMPLEX_N:
	  outtbdptr =
	    (SCSCOMPLEX_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  cond = (*outtbdptr <= 0.);
	  break;

	case SCSINT8_N:
	  outtbcptr =
	    (SCSINT8_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  cond = (*outtbcptr <= 0);
	  break;

	case SCSINT16_N:
	  outtbsptr =
	    (SCSINT16_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  cond = (*outtbsptr <= 0);
	  break;

	case SCSINT32_N:
	  outtblptr =
	    (SCSINT32_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  cond = (*outtblptr <= 0);
	  break;

	case SCSUINT8_N:
	  outtbucptr =
	    (SCSUINT8_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  cond = (*outtbucptr <= 0);
	  break;

	case SCSUINT16_N:
	  outtbusptr =
	    (SCSUINT16_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  cond = (*outtbusptr <= 0);
	  break;

	case SCSUINT32_N:
	  outtbulptr =
	    (SCSUINT32_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  cond = (*outtbulptr <= 0);
	  break;

	default:		/* Add a message here */
	  *ierr = 25;
	  return 0;
	  break;
	}
      if (cond)
	{
	  i = 2;
	}
      else
	{
	  i = 1;
	}
    }
  /* eselect blk */
  else if (sim_funtyp[kf - 1] == -2)
    {
      switch (sim_outtbtyp[sim_inplnk[sim_inpptr[kf - 1] - 1] - 1])
	{
	case SCSREAL_N:
	  outtbdptr =
	    (SCSREAL_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbdptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSCOMPLEX_N:
	  outtbdptr =
	    (SCSCOMPLEX_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbdptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSINT8_N:
	  outtbcptr =
	    (SCSINT8_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbcptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSINT16_N:
	  outtbsptr =
	    (SCSINT16_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbsptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSINT32_N:
	  outtblptr =
	    (SCSINT32_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtblptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSUINT8_N:
	  outtbucptr =
	    (SCSUINT8_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbucptr, Blocks[kf - 1].nevout), 1);
	  break;
	  
	case SCSUINT16_N:
	  outtbusptr =
	    (SCSUINT16_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbusptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSUINT32_N:
	  outtbulptr =
	    (SCSUINT32_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbulptr, Blocks[kf - 1].nevout), 1);
	  break;

	default:		/* Add a message here */
	  *ierr = 25;
	  return 0;
	  break;
	}
    }
  return i;
}

int synchro_g_nev (double *g, int kf, int *ierr)
{
  /* synchro blocks with zcross computation  */
  /*     Copyright INRIA */
  SCSREAL_COP *outtbdptr;	/*to store double of outtb */
  SCSINT8_COP *outtbcptr;	/*to store int8 of outtb */
  SCSINT16_COP *outtbsptr;	/*to store int16 of outtb */
  SCSINT32_COP *outtblptr;	/*to store int32 of outtb */
  SCSUINT8_COP *outtbucptr;	/*to store unsigned int8 of outtb */
  SCSUINT16_COP *outtbusptr;	/*to store unsigned int16 of outtb */
  SCSUINT32_COP *outtbulptr;	/*to store unsigned int32 of outtb */

  int cond;
  int i = 0;			/* return 0 by default */
  int jj = 0;

  /* if-then-else blk */
  if (sim_funtyp[kf - 1] == -1)
    {
      switch (sim_outtbtyp[sim_inplnk[sim_inpptr[kf - 1] - 1] - 1])
	{
	case SCSREAL_N:
	  outtbdptr =
	    (SCSREAL_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  g[sim_zcptr[kf - 1] - 1] = *outtbdptr;
	  cond = (*outtbdptr <= 0.);
	  break;

	case SCSCOMPLEX_N:
	  outtbdptr =
	    (SCSCOMPLEX_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  g[sim_zcptr[kf - 1] - 1] = *outtbdptr;
	  cond = (*outtbdptr <= 0.);
	  break;

	case SCSINT8_N:
	  outtbcptr =
	    (SCSINT8_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  g[sim_zcptr[kf - 1] - 1] = (double) *outtbcptr;
	  cond = (*outtbcptr <= 0);
	  break;

	case SCSINT16_N:
	  outtbsptr =
	    (SCSINT16_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  g[sim_zcptr[kf - 1] - 1] = (double) *outtbsptr;
	  cond = (*outtbsptr <= 0);
	  break;

	case SCSINT32_N:
	  outtblptr =
	    (SCSINT32_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  g[sim_zcptr[kf - 1] - 1] = (double) *outtblptr;
	  cond = (*outtblptr <= 0);
	  break;

	case SCSUINT8_N:
	  outtbucptr =
	    (SCSUINT8_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  g[sim_zcptr[kf - 1] - 1] = (double) *outtbucptr;
	  cond = (*outtbucptr <= 0);
	  break;

	case SCSUINT16_N:
	  outtbusptr =
	    (SCSUINT16_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  g[sim_zcptr[kf - 1] - 1] = (double) *outtbusptr;
	  cond = (*outtbusptr <= 0);
	  break;

	case SCSUINT32_N:
	  outtbulptr =
	    (SCSUINT32_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  g[sim_zcptr[kf - 1] - 1] = (double) *outtbulptr;
	  cond = (*outtbulptr <= 0);
	  break;

	default:		/* Add a message here */
	  *ierr = 25;
	  return 0;
	  break;
	}
      if (cond)
	{
	  i = 2;
	}
      else
	{
	  i = 1;
	}
    }
  /* eselect blk */
  else if (sim_funtyp[kf - 1] == -2)
    {
      switch (sim_outtbtyp[sim_inplnk[sim_inpptr[kf - 1] - 1] - 1])
	{
	case SCSREAL_N:
	  outtbdptr =
	    (SCSREAL_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[sim_zcptr[kf - 1] - 1 + jj] = *outtbdptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbdptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSCOMPLEX_N:
	  outtbdptr =
	    (SCSCOMPLEX_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[sim_zcptr[kf - 1] - 1 + jj] = *outtbdptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbdptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSINT8_N:
	  outtbcptr =
	    (SCSINT8_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[sim_zcptr[kf - 1] - 1 + jj] =
		(double) *outtbcptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbcptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSINT16_N:
	  outtbsptr =
	    (SCSINT16_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[sim_zcptr[kf - 1] - 1 + jj] =
		(double) *outtbsptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbsptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSINT32_N:
	  outtblptr =
	    (SCSINT32_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[sim_zcptr[kf - 1] - 1 + jj] =
		(double) *outtblptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtblptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSUINT8_N:
	  outtbucptr =
	    (SCSUINT8_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[sim_zcptr[kf - 1] - 1 + jj] =
		(double) *outtbucptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbucptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSUINT16_N:
	  outtbusptr =
	    (SCSUINT16_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[sim_zcptr[kf - 1] - 1 + jj] =
		(double) *outtbusptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbusptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSUINT32_N:
	  outtbulptr =
	    (SCSUINT32_COP *) sim_outtbptr[-1 + sim_inplnk[sim_inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[sim_zcptr[kf - 1] - 1 + jj] =
		(double) *outtbulptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbulptr, Blocks[kf - 1].nevout), 1);
	  break;

	default:		/* Add a message here */
	  *ierr = 25;
	  return 0;
	  break;
	}
    }
  return i;
}

int get_phase_simulation ()
{
  return phase;
}

/* 
   CVODE: 2,3 -> Functional iterations
   CVODE: 4,5 -> Newton iterations
   CVODE: 1  -> The very first call to block at cold-start
   CVODE: -2  -> (numerical-Jacobian) 
   CVODE: -3  -> CVYddNorm (Second derivative computing)
   CVODE: -4  -> (CVDoErrorTest)
   ------------------------------------------------
   IDA: 10,11 -> Newton iteration
   IDA: -12   -> (numerical-Jacobian) integration
   IDA: 13   -> (IDAnlsIC) consistent initial condition computation 
   IDA: -14   -> (IDAfnorm) consistent initial condition computation 
   IDA: -15   -> (numerical-Jacobian) consistent initial condition computation
   IDA: -17   -> (Jacobians) Analytical Jacobian defined in scicos.c
   IDA: -18   -> (reinitdoit) called by reinitdoit
*/

int get_fcaller_id (void)
{
  return Sfcallerid;
}

void do_cold_restart (void)
{
  params_hot = 0;
  return;
}

int what_is_hot (void)
{
  return params_hot;
}

/* get_scicos_time : return the current
 * simulation time
 */

double get_scicos_time (void)
{
  return scicos_time;
}

double get_final_time (void)
{
  return *tf;
}

/* get_block_number : return the current
 * block number
 */

int get_block_number (void)
{
  return params_curblk;
}

/* set_block_number : set the current
 * block number
 */

void set_block_number (int block_number)
{
  params_curblk = block_number;
}

/* set_block_error : set an error number
 * for block_error
 */

void set_block_error (int err)
{
  if (block_error != NULL)
    *block_error = err;
  return;
}

/* Coserror : copy an error message
 * in coserr.buf an set block_error to
 * -16
 */
#if WIN32
#ifndef vsnprintf
#define vsnprintf _vsnprintf
#endif
#endif

#ifdef __STDC__
void
Coserror (char *fmt, ...)
#else
  void
  Coserror (va_alist)
  va_dcl
#endif
{
  int retval;
  va_list ap;

#ifdef __STDC__
  va_start (ap, fmt);
#else

  char *fmt;
  va_start (ap);

  fmt = va_arg (ap, char *);
#endif

#if defined (vsnprintf) || defined (linux)
  retval = vsnprintf (coserr.buf, 4095, fmt, ap);
#else
  retval = vsprintf (coserr.buf, fmt, ap);
#endif

  if (retval == -1)
    {
      coserr.buf[0] = '\0';
    }

  va_end (ap);

  /* coserror use error number 10 */
  *block_error = -5;
}

/* get_block_error : get the block error
 * number
 */

int get_block_error (void)
{
  return *block_error;
}

void end_scicos_sim (void)
{
  params_halt = 2;
  return;
}

/* get_pointer_xproperty */

int *get_pointer_xproperty (void)
{
  return &sim_xprop[sim_xptr[params_curblk - 1] - 1];
}

/* get_Npointer_xproperty */

int get_npointer_xproperty ()
{
  return Blocks[params_curblk - 1].nx;
}

/* set_pointer_xproperty */

void set_pointer_xproperty (int *pointer)
{
  int i;
  for (i = 0; i < Blocks[params_curblk - 1].nx; i++)
    {
      Blocks[params_curblk - 1].xprop[i] = pointer[i];
    }
  return;
}

char *scicos_get_label (int kf)
{
  return Blocks[kf - 1].label;
}

void Set_Jacobian_flag (int flag)
{
  Jacobian_Flag = flag;
  return;
}

double Get_Jacobian_ci (void)
{
  return CI;
}

double Get_Jacobian_cj (void)
{
  return CJ;
}

double Get_Scicos_SQUR (void)
{
  return SQuround;
}

/* utilities for certain blocks (should be moved elsewhere) */

double exp_(double x) 
{
  double Limit=16;
  if (x<Limit) {return exp(x);} else {return exp(Limit)*(x+1-Limit);};
}
 
double log_(double x)
{
  double eps=1e-10;
  if (abs(x)>eps) {return log(abs(x));} else {return (abs(x)/eps)+log(eps)-1;};
}
 
double pow_(double x, double y)
{
  return exp_(y*log_(x));
}

int Jacobians (long int Neq, realtype tt, N_Vector yy, N_Vector yp,
	       N_Vector resvec, realtype cj, void *jdata, DenseMat Jacque,
	       N_Vector tempv1, N_Vector tempv2, N_Vector tempv3)
{
  double ttx;
  double *xc, *xcdot, *residual;
  /*  char chr; */
  int i, j, n, nx, ni, no, m, flag;
  double *RX, *Fx, *Fu, *Gx, *Gu, *ERR1, *ERR2;
  double *Hx, *Hu, *Kx, *Ku, *HuGx, *FuKx, *FuKuGx, *HuGuKx;
  double ysave;
  int job;
  double **y = NULL;
  double **u = NULL;
  /*  taill1= 3*n+(n+ni)*(n+no)+nx(2*nx+ni+2*m+no)+m*(2*m+no+ni)+2*ni*no */
  double inc, inc_inv, xi, xpi, srur;
  realtype *Jacque_col;
  realtype hh;
  N_Vector ewt;
  double *ewt_data;
  User_IDA_data ida_data;

  *ierr = 0;

  ida_data = (User_IDA_data) jdata;
  ewt = ida_data->ewt;

  flag = IDAGetCurrentStep (ida_data->ida_mem, &hh);
  if (flag < 0)
    {
      *ierr = 200 + (-flag);
      return (*ierr);
    };

  flag = IDAGetErrWeights (ida_data->ida_mem, ewt);
  if (flag < 0)
    {
      *ierr = 200 + (-flag);
      return (*ierr);
    };

  ewt_data = NV_DATA_S (ewt);
  xc = (double *) N_VGetArrayPointer (yy);
  xcdot = (double *) N_VGetArrayPointer (yp);
  /*residual=(double *) NV_DATA_S(resvec); */
  ttx = (double) tt;
  CJ = (double) cj;
  for (j = 0; j < Neq; j++)
    {
      sim_beta[j] = CJ;
    }

  srur = (double) RSqrt (UNIT_ROUNDOFF);

  if (AJacobian_block > 0)
    {
      nx = Blocks[AJacobian_block - 1].nx;	/* quant on est là cela signifie que AJacobian_block>0 */
      no = Blocks[AJacobian_block - 1].nout;
      ni = Blocks[AJacobian_block - 1].nin;
      y = (double **) Blocks[AJacobian_block - 1].outptr;	/*for compatibility */
      u = (double **) Blocks[AJacobian_block - 1].inptr;	/*warning pointer of y and u have changed to void ** */
    }
  else
    {
      nx = 0;
      no = 0;
      ni = 0;
    }
  n = Neq;
  /* nb = sim_nblk;*/
  m = n - nx;

  residual = (double *) ida_data->rwork;
  ERR1 = residual + n;
  ERR2 = ERR1 + n;
  RX = ERR2 + n;
  Fx = RX + (n + ni) * (n + no);	/* car (nx+ni)*(nx+no) peut etre > `a n*n */
  Fu = Fx + nx * nx;
  Gx = Fu + nx * ni;
  Gu = Gx + no * nx;
  Hx = Gu + no * ni;
  Hu = Hx + m * m;
  Kx = Hu + m * no;
  Ku = Kx + ni * m;
  HuGx = Ku + ni * no;
  FuKx = HuGx + m * nx;
  FuKuGx = FuKx + nx * m;
  HuGuKx = FuKuGx + nx * nx;
  /* HuGuKx+m*m; =>  m*m=size of HuGuKx */
  /* ------------------ Numerical Jacobian--->> Hx,Kx */
  Sfcallerid = -17;
  /* read residuals; */
  job = 0;
  Jdoit (&ttx, xc, xcdot, residual, &job);
  if (*ierr < 0)
    return -1;

  /* "residual" already contains the current residual, 
     so the first call to Jdoit can be remoevd */

  for (i = 0; i < m; i++)
    for (j = 0; j < ni; j++)
      Kx[j + i * ni] = u[j][0];

  for (i = 0; i < m; i++)
    {
      xi = xc[i];
      xpi = xcdot[i];
      inc = MAX (srur * MAX (ABS (xi), ABS (hh * xpi)), SUNDIALS_ONE / ewt_data[i]);
      if (hh * xpi < SUNDIALS_ZERO)
	inc = -inc;
      inc = (xi + inc) - xi;

      if (CI == 0)
	{
	  inc = MAX (srur * ABS (hh * xpi), SUNDIALS_ONE);
	  if (hh * xpi < SUNDIALS_ZERO)
	    inc = -inc;
	  inc = (xpi + inc) - xpi;
	}
      xc[i] += CI * inc;
      xcdot[i] += CJ * inc;
      /* a= Max(Abs(H[0]*xcdot[i]),Abs(1.0/Ewt[i]));
       * b= Max(1.0,Abs(xc[i]));
       * del=SQUR[0]*Max(a,b);    
       */
      job = 0;			/* read residuals */
      Jdoit (&ttx, xc, xcdot, ERR2, &job);
      if (*ierr < 0)
	return -1;
      inc_inv = SUNDIALS_ONE / inc;
      for (j = 0; j < m; j++)
	Hx[m * i + j] = (ERR2[j] - residual[j]) * inc_inv;
      for (j = 0; j < ni; j++)
	Kx[j + i * ni] = (u[j][0] - Kx[j + i * ni]) * inc_inv;
      xc[i] = xi;
      xcdot[i] = xpi;
    }
  /*----- Numerical Jacobian--->> Hu,Ku */

  if ((AJacobian_block == 0))
    {
      for (j = 0; j < m; j++)
	{
	  Jacque_col = DENSE_COL (Jacque, j);
	  for (i = 0; i < m; i++)
	    {
	      Jacque_col[i] = Hx[i + j * m];
	    }
	}
      C2F (ierode).iero = *ierr;
      return 0;
    }
  /****------------------***/
  job = 0;
  Jdoit (&ttx, xc, xcdot, ERR1, &job);
  for (i = 0; i < no; i++)
    for (j = 0; j < ni; j++)
      Ku[j + i * ni] = u[j][0];

  for (i = 0; i < no; i++)
    {
      ysave = y[i][0];
      inc = srur * MAX (ABS (ysave), 1);
      inc = (ysave + inc) - ysave;
      /* del=SQUR[0]* Max(1.0,Abs(y[i][0]));
       * del=(y[i][0]+del)-y[i][0]; 
       */
      y[i][0] += inc;
      job = 2;			/* applying y[i][0] to the output of imp block */
      Jdoit (&ttx, xc, xcdot, ERR2, &job);
      if (*ierr < 0)
	return -1;
      inc_inv = SUNDIALS_ONE / inc;
      for (j = 0; j < m; j++)
	Hu[m * i + j] = (ERR2[j] - ERR1[j]) * inc_inv;
      for (j = 0; j < ni; j++)
	Ku[j + i * ni] = (u[j][0] - Ku[j + i * ni]) * inc_inv;
      y[i][0] = ysave;
    }
  /*----------------------------------------------*/
  for (j = 0; j < nx * nx + nx * ni + no * nx + no * ni; j++)
    Fx[j] = 0.0;		/* Filling up FX:Fu:Gx:Gu */
  job = 1;			/* read jacobian through flag=10; */
  Jdoit (&ttx, xc, xcdot, &Fx[-m], &job);	/* Filling up the FX:Fu:Gx:Gu */
  if (*ierr != 0)
    {
      sciprint ("\n\r error in Jacobian");
      return -1;
    }
  /*-------------------------------------------------*/

  Multp (Fu, Ku, RX, nx, ni, ni, no);
  Multp (RX, Gx, FuKuGx, nx, no, no, nx);

  for (j = 0; j < nx; j++)
    {
      Jacque_col = DENSE_COL (Jacque, j + m);
      for (i = 0; i < nx; i++)
	{
	  Jacque_col[i + m] = Fx[i + j * nx] + FuKuGx[i + j * nx];
	}
    }

  Multp (Hu, Gx, HuGx, m, no, no, nx);

  for (i = 0; i < nx; i++)
    {
      Jacque_col = DENSE_COL (Jacque, i + m);
      for (j = 0; j < m; j++)
	{
	  Jacque_col[j] = HuGx[j + i * m];
	}
    }

  Multp (Fu, Kx, FuKx, nx, ni, ni, m);

  for (i = 0; i < m; i++)
    {
      Jacque_col = DENSE_COL (Jacque, i);
      for (j = 0; j < nx; j++)
	{
	  Jacque_col[j + m] = FuKx[j + i * nx];
	}
    }


  Multp (Hu, Gu, RX, m, no, no, ni);
  Multp (RX, Kx, HuGuKx, m, ni, ni, m);

  for (j = 0; j < m; j++)
    {
      Jacque_col = DENSE_COL (Jacque, j);
      for (i = 0; i < m; i++)
	{
	  Jacque_col[i] = Hx[i + j * m] + HuGuKx[i + j * m];
	}
    }

  /*  chr='Z';   printf("\n\r t=%g",ttx); DISP(Z,n,n,chr); */
  C2F (ierode).iero = *ierr;
  return 0;
}

static void Multp (double *A,double * B,double * R,int ra,int ca,int rb,int cb)
{
  int i, j, k;

  for (i = 0; i < ra; i++)
    for (j = 0; j < cb; j++)
      {
	R[i + ra * j] = 0.0;
	for (k = 0; k < ca; k++)
	  R[i + ra * j] += A[i + k * ra] * B[k + j * rb];
      }
  return;
}

#if 0
static void DISP(double *A, int ra , int ca,int *name)
{
  int i,j;
  Sciprintf("\n");
  for (i=0;i<ca;i++)
    for (j=0;j<ra;j++){
      if (A[j+i*ra]!=0) 
	Sciprintf(" %s(%d,%d)=%g;",name,j+1,i+1,A[j+i*ra]);
    }; 
}
#endif

int read_xml_initial_states (int nvar, const char *xmlfile, char **ids, double *svars)
{
  ezxml_t model, elements;
  int result = 0, i;
  double vr;

  if (nvar == 0)
    return 0;
  for (i = 0; i < nvar; i++)
    {
      if (strcmp (ids[i], "") != 0)
	{
	  result = 1;
	  break;
	}
    }
  if (result == 0)
    return 0;
  model = ezxml_parse_file (xmlfile);

  if (model == NULL)
    {
      sciprint ("Error: cannot find '%s'  \n\r", xmlfile);
      return -1;
    }

  elements = ezxml_child (model, "elements");
  for (i = 0; i < nvar; i++)
    {
      vr = 0.0;
      result = read_id (&elements, ids[i], &vr);
      if (result == 1)
	svars[i] = vr;
      else
	sciprint ("Cannot find: %s in the XML file \n", ids[i]);
    }
  ezxml_free (model);
  return 0;
}

static int read_id (ezxml_t * elements, char *id, double *value)
{
  char V1[100], V2[100];
  int ok, i, ln;

  if (strcmp (id, "") == 0)
    return 0;
  ok = search_in_child (elements, id, V1);
  if (ok == 0)
    {
      /*sciprint("Cannot find: %s=%s  \n",id,V1);      */
      return 0;
    }
  else
    {
      if (Convert_number (V1, value) != 0)
	{
	  ln = (int) (strlen (V1));
	  if (ln > 2)
	    {
	      for (i = 1; i <= ln - 2; i++)
		V2[i - 1] = V1[i];
	      V2[ln - 2] = '\0';
	      ok = read_id (elements, V2, value);
	      return ok;
	    }
	  else
	    return 0;
	}
      else
	{
	  /*      printf("\n\r ---->>>%s= %g",V1,*value); */
	  return 1;
	}
    }
}


int Convert_number (char *s, double *out)
{
  char *endp;
  double d;
  long int l;
  d = strtod (s, &endp);
  if (s != endp && *endp == '\0')
    {
      /*    printf("  It's a float with value %g ", d); */
      *out = d;
      return 0;
    }
  else
    {
      l = strtol (s, &endp, 0);
      if (s != endp && *endp == '\0')
	{
	  /*printf("  It's an int with value %ld ", 1); */
	  *out = (double) l;
	  return 0;
	}
      else
	{
	  /*printf("  string "); */
	  return -1;
	}
    }
}

int write_xml_states (int nvar, const char *xmlfile, char **ids, double *x)
{
  ezxml_t model, elements;
  int result = 0, i, err = 0;
  FILE *fd;
  char *s;
  char **xv;

  if (nvar == 0)
    return 0;
  for (i = 0; i < nvar; i++)
    {
      if (strcmp (ids[i], "") != 0)
	{
	  result = 1;
	  break;
	}
    }
  if (result == 0)
    return 0;

  xv = malloc (nvar * sizeof (char *));
  for (i = 0; i < nvar; i++)
    {
      xv[i] = malloc (nvar * 100 * sizeof (char));
      sprintf (xv[i], "%g", x[i]);
    }

  model = ezxml_parse_file (xmlfile);
  if (model == NULL)
    {
      sciprint ("Error: cannot find '%s'  \n\r", xmlfile);
      return -1;		/* file does not existe */
    }

  elements = ezxml_child (model, "elements");

  for (i = 0; i < nvar; i++)
    {
      if (strcmp (ids[i], "") == 0)
	continue;
      result = write_in_child (&elements, ids[i], xv[i]);
      if (result == 0)
	{
	  sciprint ("Cannot find: %s in the XML file \n", ids[i]);
	  /* err= -1; *//* Varaible does not existe */
	}
    }

  s = ezxml_toxml (model);
  ezxml_free (model);

  fd = fopen (xmlfile, "wb");
  if (fd < 0)
    {
      sciprint ("Error: cannot write to  '%s'  \n\r", xmlfile);
      return -3;		/* cannot write to file */
    }

  fputs (s, fd);
  fclose (fd);

  return err;
}

#if 0
static int fx_ (double *x, double *residual);
{
  double *xdot, t;
  xdot = x + *neq;
  t = 0;
  *ierr = 0;
  C2F (ierode).iero = 0;
  odoit (&t, x, xdot, residual);
  C2F (ierode).iero = *ierr;
  return (*ierr);
}
#endif

#if 0
static int rho_ (double *a, double *L, double *x, double *rho, double *rpar,
		 int *ipar)
{
  int i, N = *neq;
  fx_ (x, rho);
  for (i = 0; i < N; i++)
    rho[i] += (-1 + *L) * a[i];
  return 0;
}
#endif

#if 0
static int rhojac_ (double *a, double *lambda, double *x, double *jac, int *col,
		    double *rpar, int *ipar)
{
  /* MATRIX [d_RHO/d_LAMBDA, d_RHO/d_X_col] */
  int j, N;
  double *work;
  int job;
  double inc, inc_inv, xi, srur;
  N = *neq;
  if (*col == 1)
    {
      for (j = 0; j < N; j++)
	jac[j] = a[j];
    }
  else
    {
      if ((work = (double *) malloc (N * sizeof (double))) == NULL)
	{
	  *ierr = 10000;
	  return *ierr;
	}
      rho_ (a, lambda, x, work, rpar, ipar);
      srur = 1e-10;
      xi = x[*col - 2];
      inc = srur * Max (Abs (xi), 1);
      inc = (xi + inc) - xi;
      x[*col - 2] += inc;

      job = 0;
      rho_ (a, lambda, x, jac, rpar, ipar);
      inc_inv = 1.0 / inc;

      for (j = 0; j < N; j++)
	jac[j] = (jac[j] - work[j]) * inc_inv;

      x[*col - 2] = xi;
      free (work);
    }
  return 0;
}
#endif

#if 0
static int hfjac_ (double *x, double *jac, int *col)
{
  int N, j;
  double *work;
  double *xdot;
  int job;
  double inc, inc_inv, xi, srur;

  N = *neq;
  if ((work = (double *) MALLOC (N * sizeof (double))) == NULL)
    {
      *ierr = 10000;
      return *ierr;
    }
  srur = (double) RSqrt (UNIT_ROUNDOFF);

  fx_ (x, work);

  xi = x[*col - 1];
  inc = srur * MAX (ABS (xi), 1);
  inc = (xi + inc) - xi;
  x[*col - 1] += inc;
  xdot = x + N;

  job = 0;
  fx_ (x, jac);
  if (*ierr < 0)
    return *ierr;

  inc_inv = SUNDIALS_ONE / inc;

  for (j = 0; j < N; j++)
    jac[j] = (jac[j] - work[j]) * inc_inv;

  x[*col - 1] = xi;

  FREE (work);
  return 0;
}
#endif

static int
simblkKinsol (N_Vector yy, N_Vector resval, void *rdata)
{
  int jj, nantest;
  int N = *neq;
  double t = 0;
  double *xc = (double *) NV_DATA_S (yy);
  double *residual = (double *) NV_DATA_S (resval);
  double *xcdot = xc;
  
  if (phase == 1)
    {
      if (sim_ng > 0 && sim_nmod > 0)
	zdoit (&t, xc, xcdot, sim_g);
    }
  *ierr = 0;
  C2F (ierode).iero = 0;
  odoit (&t, xc, xcdot, residual);

  if (*ierr == 0)
    {
      nantest = 0;
      /* NaN checking */
      for (jj = 0; jj < N; jj++)
	{
	  if (residual[jj] - residual[jj] != 0)
	    {
	      sciprint("\n\rWarning: The initialization system #%d returns a NaN/Inf", jj);
	      nantest = 1;
	      break;
	    }
	}
      if (nantest == 1)
	{
	  return 258;		/* recoverable error; */
	}
    }
  C2F (ierode).iero = *ierr;

  return (Abs (*ierr));		/* ierr>0 recoverable error; ierr>0 unrecoverable error; ierr=0: ok */
}

static int
CallKinsol (double *told)
{
  N_Vector y = NULL, yscale = NULL, fscale = NULL;
  double *fsdata, *ysdata;
  int strategy, i, j, k, status;
  void *kin_mem = NULL;
  int Jn, Jnx, Jno, Jni, Jactaille;
  realtype reltol;
  /* realtype abstol;*/
  int *Mode_save;
  int Mode_change;
  int N_iters;
  User_KIN_data kin_data = NULL;
  int N = *neq;
  if (N <= 0)
    return 0;

  reltol = (realtype) params_rtol;
  /* abstol = (realtype) params_Atol; */

  Mode_save = NULL;
  if (sim_nmod > 0)
    {
      if ((Mode_save = MALLOC (sizeof (int) * sim_nmod)) == NULL)
	{
	  *ierr = 10000;
	  return -1;
	}
    }

  y = N_VNewEmpty_Serial (N);
  if (y == NULL)
    {
      FREE (Mode_save);
      return -1;
    }
  NV_DATA_S (y) = sim_x;
  yscale = N_VNew_Serial (N);
  if (yscale == NULL)
    {
      FREE (Mode_save);
      N_VDestroy_Serial (y);
      return -1;
    }
  fscale = N_VNew_Serial (N);
  if (fscale == NULL)
    {
      FREE (Mode_save);
      N_VDestroy_Serial (y);
      N_VDestroy_Serial (yscale);
      return -1;
    }
  ysdata = NV_DATA_S (yscale);
  fsdata = NV_DATA_S (fscale);
  for (j = 0; j < N; j++)
    {
      ysdata[j] = 1.0;
      fsdata[j] = 1.0;
    }

  kin_mem = KINCreate ();
  if (kin_mem == NULL)
    {
      FREE (Mode_save);
      N_VDestroy_Serial (y);
      N_VDestroy_Serial (yscale);
      N_VDestroy_Serial (fscale);
      return -1;
    }

  if ((kin_data = (User_KIN_data) MALLOC (sizeof (User_KIN_data))) == NULL)
    {
      FREE (Mode_save);
      N_VDestroy_Serial (y);
      N_VDestroy_Serial (yscale);
      N_VDestroy_Serial (fscale);
      KINFree (&kin_mem);
      return -1;
    }
  kin_data->uscale = ysdata;

  /*Jacobian_Flag=0; */
  if (AJacobian_block > 0)
    {
      /* set by the block with A-Jac in flag-4 using Set_Jacobian_flag(1); */
      Jn = *neq;
      Jnx = Blocks[AJacobian_block - 1].nx;
      Jno = Blocks[AJacobian_block - 1].nout;
      Jni = Blocks[AJacobian_block - 1].nin;
    }
  else
    {
      Jn = *neq;
      Jnx = 0;
      Jno = 0;
      Jni = 0;
    }
  Jactaille =
    3 * Jn + (Jn + Jni) * (Jn + Jno) + Jnx * (Jni + 2 * Jn + Jno) + (Jn -
								     Jnx) *
    (2 * (Jn - Jnx) + Jno + Jni) + 2 * Jni * Jno;

  if ((kin_data->rwork =
       (double *) MALLOC (Jactaille * sizeof (double))) == NULL)
    {
      FREE (Mode_save);
      N_VDestroy_Serial (y);
      N_VDestroy_Serial (yscale);
      N_VDestroy_Serial (fscale);
      KINFree (&kin_mem);
      FREE (kin_data);
      return -1;
    }
  status = KINMalloc (kin_mem, simblkKinsol, y);
  strategy = KIN_LINESEARCH;	/*KIN_NONE=without LineSearch */
  status = KINDense (kin_mem, N);
  KINDenseSetJacFn (kin_mem, KinJacobians1, kin_data);	/* Using analytical Jacobian */
  status = KINSetNumMaxIters (kin_mem, 200);	/* MaxNumIter=200->2000 */
  status = KINSetRelErrFunc (kin_mem, reltol);	/* FuncRelErr=eps->RTOL */
  status = KINSetMaxSetupCalls (kin_mem, 1);	/* MaxNumSetups=10->1=="Exact Newton" */
  status = KINSetMaxSubSetupCalls (kin_mem, 1);	/* MaxNumSubSetups=5->1 */
  /* status = KINSetNoInitSetup(kin_mem,noInitSetup);  // InitialSetup=true  */
  /* status = KINSetNoMinEps(kin_mem,noMinEps);        // MinBoundEps=true   */
  /* status = KINSetMaxBetaFails(kin_mem,mxnbcf);      // MaxNumBetaFails=10 */
  /* status = KINSetEtaForm(kin_mem,etachoice);        // EtaForm=Type1      */
  /* status = KINSetEtaConstValue(kin_mem,eta); */// Eta=0.1            */
  /* status = KINSetEtaParams(kin_mem,egamma,ealpha);  // EtaGamma=0.9  EtaAlpha=2.0 */
  /* status = KINSetMaxNewtonStep(kin_mem,mxnewtstep); // MaxNewtonStep=0.0  */
  /* status = KINSetFuncNormTol(kin_mem,fnormtol);     // FuncNormTol=eps^(1/3) */
  /* status = KINSetScaledStepTol(kin_mem,scsteptol);  // ScaledStepTol={eps^(2/3) */
  /* xmin =(double) RSqrt(UNIT_ROUNDOFF)*1e6; */
  /*========================================================*/
  phase = 2;	// modes are fixed
  status = -1;
  N_iters = 10 + Min (sim_nmod * 3, 30);
  for (k = 0; k <= N_iters; k++)
    {				/* loop for mode fixin */
      /*------------KINSOL calls-----------*/
      for (i = 0; i < 4; i++)
	{
	  /*simblkKinsol(y,ffscale,NULL); 
	    for (j=0;j<N;j++)
	    if (ffsdata[j]-ffsdata[j]!=0){
	    sciprint("\n\rWarning: The residual function #%d returns a NaN/Inf",j);
	    freekinsol;*ierr=400-status;C2F (ierode).iero=*ierr; return -1;
	    }
	    for( j=0;j<N;j++){
	    if (Abs(x[j])<=xmin)  xi=xmin;else xi=x[j];
	    if (Abs(ffsdata[j])<=xmin) fi=xmin;else fi=ffsdata[j];
	    ysdata[j]=(5*ysdata[j]+1/Abs(xi))/6;
	    fsdata[j]=(5*fsdata[j]+1/Abs(fi))/6;   
	    } */
	  status = KINSol (kin_mem, y, strategy, yscale, fscale);	/* Calling the Newton Solver */
	  if (status >= 0)
	    break;
	  C2F (sxevents) ();
	  if (params_halt != 0)
	    {
	      params_halt = 0;
	      status = 0;
	      goto end;
	      return 0;
	    }
	}
      /*---------end of KINSOL calls-----------*/
      if (phase == 2)
	{
	  for (j = 0; j < sim_nmod; ++j)
	    {
	      Mode_save[j] = sim_mod[j];
	    }
	  if (sim_ng > 0 && sim_nmod > 0)
	    {
	      phase = 1;	// updating the modes
	      zdoit (told, sim_x, sim_xd, sim_g);
	      if (*ierr != 0)
		{
		  C2F (ierode).iero = *ierr;
		  status = -1;
		  goto end;
		}
	      phase = 2;
	    }

	  Mode_change = 0;
	  for (j = 0; j < sim_nmod; ++j)
	    {
	      if (Mode_save[j] != sim_mod[j])
		{
		  Mode_change = 1;
		  break;
		}
	    }
	  if (Mode_change == 0 && status >= 0)
	    break;		/*Successful termination */
	  if (status < 0 && k >= N_iters - 0)
	    {			/*Retrying with phase=1 */
	      phase = 1;
	    }
	}
      else
	{
	  /* when calling with phase=1 */
	  if (status >= 0)
	    break;
	}

    }				/* end of the loop for mode fixing */

  if (status < 0)
    {
      *ierr = 400 - status;
      C2F (ierode).iero = *ierr;
    }
 end:
  FREE (Mode_save);				
  N_VDestroy_Serial (y);			 
  N_VDestroy_Serial (fscale);
  N_VDestroy_Serial (yscale);
  FREE (kin_data->rwork);
  FREE (kin_data);
  KINFree (&kin_mem);
  return status;
}

int
KinJacobians0 (long int n, DenseMat J, N_Vector u, N_Vector fu,
	       void *jac_data, N_Vector tmp1, N_Vector tmp2)
{
  realtype inc, inc_inv, ujsaved, ujscale, sign;
  realtype *tmp2_data, *u_data, *uscale_data;
  N_Vector ftemp, jthCol;
  long int j;
  int retval;
  double srur;
  User_KIN_data data;
  data = (User_KIN_data) jac_data;
  uscale_data = data->uscale;

  tmp2_data = N_VGetArrayPointer (tmp2);
  ftemp = tmp1;
  jthCol = tmp2;

  u_data = N_VGetArrayPointer (u);
  //uscale_data = N_VGetArrayPointer(uscale);

  srur = (double) RSqrt (UNIT_ROUNDOFF);

  for (j = 0; j < n; j++)
    {

      N_VSetArrayPointer (DENSE_COL (J, j), jthCol);

      ujsaved = u_data[j];
      ujscale = SUNDIALS_ONE / uscale_data[j];
      sign = (ujsaved >= SUNDIALS_ZERO) ? SUNDIALS_ONE : -SUNDIALS_ONE;
      inc = srur * Max (ABS (ujsaved), ujscale) * sign;
      u_data[j] += inc;

      retval = simblkKinsol (u, ftemp, jac_data);
      if (retval != 0)
	return (-1);

      u_data[j] = ujsaved;

      inc_inv = SUNDIALS_ONE / inc;
      N_VLinearSum (inc_inv, ftemp, -inc_inv, fu, jthCol);

    }
  N_VSetArrayPointer (tmp2_data, tmp2);

  return (0);
}

int
KinJacobians1 (long int Neq, DenseMat Jacque, N_Vector yy, N_Vector resvec,
	       void *jac_data, N_Vector tmp1, N_Vector tmp2)
{
  double ttx;
  double *xc, *xcdot = NULL, *residual, *uscale_data, sign;
  int i, j, n, nx, ni, no, m;
  double *RX, *Fx, *Fu, *Gx, *Gu, *ERR1, *ERR2;
  double *Hx, *Hu, *Kx, *Ku, *HuGx, *FuKx, *FuKuGx, *HuGuKx;
  double ysave;
  int job;
  double **y = NULL;
  double **u = NULL;
  /*  taill1= 3*n+(n+ni)*(n+no)+nx(2*nx+ni+2*m+no)+m*(2*m+no+ni)+2*ni*no */
  double inc, inc_inv, xi, ujscale, srur;
  realtype *Jacque_col;

  User_KIN_data kin_data;
  *ierr = 0;

  kin_data = (User_KIN_data) jac_data;
  uscale_data = kin_data->uscale;

  xc = (double *) N_VGetArrayPointer (yy);
  //residual=(double *) NV_DATA_S(resvec);
  ttx = 0;
  CJ = 0;
  CI = 1.0;
  for (j = 0; j < Neq; j++)
    {
      sim_alpha[j] = CI;
      sim_beta[j] = CJ;
    }

  srur = (double) RSqrt (UNIT_ROUNDOFF);

  if (AJacobian_block > 0)
    {
      nx = Blocks[AJacobian_block - 1].nx;	/* quant on est la cela signifie que AJacobian_block>0 */
      no = Blocks[AJacobian_block - 1].nout;
      ni = Blocks[AJacobian_block - 1].nin;
      y = (double **) Blocks[AJacobian_block - 1].outptr;	/*for compatibility */
      u = (double **) Blocks[AJacobian_block - 1].inptr;	/*warning pointer of y and u have changed to void ** */
    }
  else
    {
      nx = 0;
      no = 0;
      ni = 0;
    }
  n = Neq;
  m = n - nx;

  residual = (double *) kin_data->rwork;
  ERR1 = residual + n;
  ERR2 = ERR1 + n;
  RX = ERR2 + n;
  Fx = RX + (n + ni) * (n + no);	/* car (nx+ni)*(nx+no) peut etre > `a n*n */
  Fu = Fx + nx * nx;
  Gx = Fu + nx * ni;
  Gu = Gx + no * nx;
  Hx = Gu + no * ni;
  Hu = Hx + m * m;
  Kx = Hu + m * no;
  Ku = Kx + ni * m;
  HuGx = Ku + ni * no;
  FuKx = HuGx + m * nx;
  FuKuGx = FuKx + nx * m;
  HuGuKx = FuKuGx + nx * nx;
  /* HuGuKx+m*m; =>  m*m=size of HuGuKx */
  /* ------------------ Numerical Jacobian--->> Hx,Kx */

  /* read residuals; */
  job = 0;
  Jdoit (&ttx, xc, xcdot, residual, &job);
  if (*ierr < 0)
    return -1;

  for (i = 0; i < m; i++)
    for (j = 0; j < ni; j++)
      Kx[j + i * ni] = u[j][0];

  for (i = 0; i < m; i++)
    {
      xi = xc[i];
      ujscale = SUNDIALS_ONE / uscale_data[i];
      sign = (xi >= SUNDIALS_ZERO) ? SUNDIALS_ONE : -SUNDIALS_ONE;
      inc = srur * Max (ABS (xi), ujscale) * sign;
      inc = (xi + inc) - xi;
      xc[i] += inc;

      job = 0;			/* read residuals */
      Jdoit (&ttx, xc, xcdot, ERR2, &job);
      if (*ierr < 0)
	return -1;
      inc_inv = SUNDIALS_ONE / inc;
      for (j = 0; j < m; j++)
	Hx[m * i + j] = (ERR2[j] - residual[j]) * inc_inv;
      for (j = 0; j < ni; j++)
	Kx[j + i * ni] = (u[j][0] - Kx[j + i * ni]) * inc_inv;
      xc[i] = xi;
    }
  /*----- Numerical Jacobian--->> Hu,Ku */
  if ((AJacobian_block == 0))
    {
      for (j = 0; j < m; j++)
	{
	  Jacque_col = DENSE_COL (Jacque, j);
	  for (i = 0; i < m; i++)
	    {
	      Jacque_col[i] = Hx[i + j * m];
	    }
	}
      C2F (ierode).iero = *ierr;
      return 0;
    }
  /****------------------***/
  job = 0;
  Jdoit (&ttx, xc, xcdot, ERR1, &job);
  for (i = 0; i < no; i++)
    for (j = 0; j < ni; j++)
      Ku[j + i * ni] = u[j][0];

  for (i = 0; i < no; i++)
    {
      ysave = y[i][0];
      sign = (ysave >= SUNDIALS_ZERO) ? SUNDIALS_ONE : -SUNDIALS_ONE;
      inc = srur * Max (ABS (ysave), 1) * sign;
      inc = (ysave + inc) - ysave;
      y[i][0] += inc;
      job = 2;			/* applying y[i][0] to the output of imp block */
      Jdoit (&ttx, xc, xcdot, ERR2, &job);
      if (*ierr < 0)
	return -1;
      inc_inv = SUNDIALS_ONE / inc;
      for (j = 0; j < m; j++)
	Hu[m * i + j] = (ERR2[j] - ERR1[j]) * inc_inv;
      for (j = 0; j < ni; j++)
	Ku[j + i * ni] = (u[j][0] - Ku[j + i * ni]) * inc_inv;
      y[i][0] = ysave;
    }
  /*----------------------------------------------*/
  job = 1;			/* read jacobian through flag=10; */
  for (j = 0; j < nx * nx + nx * ni + no * nx + no * ni; j++)
    Fx[j] = 0.0;		/* Filling up FX:Fu:Gx:Gu */
  Jdoit (&ttx, xc, xcdot, &Fx[-m], &job);	/* Filling up the FX:Fu:Gx:Gu */
  if (*block_error != 0)
    sciprint ("\n\r error in Jacobian");
  /*-------------------------------------------------*/
  Multp (Fu, Ku, RX, nx, ni, ni, no);
  Multp (RX, Gx, FuKuGx, nx, no, no, nx);

  for (j = 0; j < nx; j++)
    {
      Jacque_col = DENSE_COL (Jacque, j + m);
      for (i = 0; i < nx; i++)
	{
	  Jacque_col[i + m] = Fx[i + j * nx] + FuKuGx[i + j * nx];
	}
    }

  Multp (Hu, Gx, HuGx, m, no, no, nx);

  for (i = 0; i < nx; i++)
    {
      Jacque_col = DENSE_COL (Jacque, i + m);
      for (j = 0; j < m; j++)
	{
	  Jacque_col[j] = HuGx[j + i * m];
	}
    }

  Multp (Fu, Kx, FuKx, nx, ni, ni, m);

  for (i = 0; i < m; i++)
    {
      Jacque_col = DENSE_COL (Jacque, i);
      for (j = 0; j < nx; j++)
	{
	  Jacque_col[j + m] = FuKx[j + i * nx];
	}
    }

  Multp (Hu, Gu, RX, m, no, no, ni);
  Multp (RX, Kx, HuGuKx, m, ni, ni, m);

  for (j = 0; j < m; j++)
    {
      Jacque_col = DENSE_COL (Jacque, j);
      for (i = 0; i < m; i++)
	{
	  Jacque_col[i] = Hx[i + j * m] + HuGuKx[i + j * m];
	}
    }

  C2F (ierode).iero = *ierr;
  return 0;
}

 
void FREE_blocks ()
{
  int kf;
  for (kf = 0; kf < sim_nblk; ++kf)
    {
      if (Blocks[kf].insz != NULL)
	{
	  FREE (Blocks[kf].insz);
	}
      else
	{
	  break;
	}
      if (Blocks[kf].inptr != NULL)
	{
	  FREE (Blocks[kf].inptr);
	}
      else
	{
	  break;
	}
      if (Blocks[kf].outsz != NULL)
	{
	  FREE (Blocks[kf].outsz);
	}
      else
	{
	  break;
	}
      if (Blocks[kf].outptr != NULL)
	{
	  FREE (Blocks[kf].outptr);
	}
      else
	{
	  break;
	}
      if (Blocks[kf].oparsz != NULL)
	{
	  FREE (Blocks[kf].oparsz);
	}
      else
	{
	  break;
	}
      if (Blocks[kf].ozsz != NULL)
	{
	  FREE (Blocks[kf].ozsz);
	}
      else
	{
	  break;
	}
      if (Blocks[kf].label != NULL)
	{
	  FREE (Blocks[kf].label);
	}
      else
	{
	  break;
	}
      if (Blocks[kf].evout != NULL)
	{
	  FREE (Blocks[kf].evout);
	}
      else
	{
	  break;
	}
    }
  FREE (Blocks);

  if (sim_nx > 0)
    FREE (sim_xprop);
  
  if (sim_nmod > 0)
    FREE (sim_mod);

  if (sim_ng > 0)
    FREE (sim_g);

  return;
}

int C2F (funnum) (char * fname)
{
  int i = 0, ln;
  int loc = -1;
  while (tabsim[i].name != (char *) NULL)
    {
      if (strcmp (fname, tabsim[i].name) == 0)
	return (i + 1);
      i++;
    }
  ln = (int) strlen (fname);
  C2F (iislink) (fname, &loc);
  C2F (iislink) (fname, &loc);
  if (loc >= 0)
    return (ntabsim + (int) loc + 1);
  return (0);
}
