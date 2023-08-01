/*      dopri5
	------


This code computes the numerical solution of a system of first order ordinary
differential equations y'=f(x,y). It uses an explicit Runge-Kutta method of
order (4)5 due to Dormand & Prince with step size control and dense output.

Authors : E. Hairer & G. Wanner
	  Universite de Geneve, dept. de Mathematiques
	  CH-1211 GENEVE 4, SWITZERLAND
	  E-mail : HAIRER@DIVSUN.UNIGE.CH, WANNER@DIVSUN.UNIGE.CH

The code is described in : E. Hairer, S.P. Norsett and G. Wanner, Solving
ordinary differential equations I, nonstiff problems, 2nd edition,
Springer Series in Computational Mathematics, Springer-Verlag (1993).

Version of April 28, 1994.

Remarks about the C version : this version allocates memory by itself, the
iwork array (among the initial FORTRAN parameters) has been splitted into
independant initial parameters, the statistical variables and last step size
and x have been encapsulated in the module and are now accessible through
dedicated functions, the variable names have been kept to maintain a kind
of reading compatibility between the C and FORTRAN codes; adaptation made by
J.Colinge (COLINGE@DIVSUN.UNIGE.CH).



INPUT PARAMETERS
----------------

n        Dimension of the system (n < UINT_MAX).

fcn      A pointer the the function definig the differential equation, this
	 function must have the following prototype

	   void fcn (unsigned n, double x, double *y, double *f)

	 where the array f will be filled with the function result.

x        Initial x value.

*y       Initial y values (double y[n]).

xend     Final x value (xend-x may be positive or negative).

*rtoler  Relative and absolute error tolerances. They can be both scalars or
*atoler  vectors of length n (in the scalar case pass the addresses of
	 variables where you have placed the tolerance values).

itoler   Switch for atoler and rtoler :
	   itoler=0 : both atoler and rtoler are scalars, the code keeps
		      roughly the local error of y[i] below
		      rtoler*abs(y[i])+atoler.
	   itoler=1 : both rtoler and atoler are vectors, the code keeps
		      the local error of y[i] below
		      rtoler[i]*abs(y[i])+atoler[i].

solout   A pointer to the output function called during integration.
	 If iout >= 1, it is called after every successful step. If iout = 0,
	 pass a pointer equal to NULL. solout must must have the following
	 prototype

	   solout (long nr, double xold, double x, double* y, unsigned n, int* irtrn)

	 where y is the solution the at nr-th grid point x, xold is the
	 previous grid point and irtrn serves to interrupt the integration
	 (if set to a negative value).

	 Continuous output : during the calls to solout, a continuous solution
	 for the interval (xold,x) is available through the function

	   contd5(i,s)

	 which provides an approximation to the i-th component of the solution
	 at the point s (s must lie in the interval (xold,x)).

iout     Switch for calling solout :
	   iout=0 : no call,
	   iout=1 : solout only used for output,
	   iout=2 : dense output is performed in solout (in this case nrdens
		    must be greater than 0).

fileout  A pointer to the stream used for messages, if you do not want any
	 message, just pass NULL.

icont    An array containing the indexes of components for which dense
	 output is required. If no dense output is required, pass NULL.

licont   The number of cells in icont.


Sophisticated setting of parameters
-----------------------------------

	 Several parameters have a default value (if set to 0) but, to better
	 adapt the code to your problem, you can specify particular initial
	 values.

uround   The rounding unit, default 2.3E-16 (this default value can be
	 replaced in the code by DBL_EPSILON providing float.h defines it
	 in your system).

safe     Safety factor in the step size prediction, default 0.9.

fac1     Parameters for step size selection; the new step size is chosen
fac2     subject to the restriction  fac1 <= hnew/hold <= fac2.
	 Default values are fac1=0.2 and fac2=10.0.

beta     The "beta" for stabilized step size control (see section IV.2 of our
	 book). Larger values for beta ( <= 0.1 ) make the step size control
	 more stable. dopri5 needs a larger beta than Higham & Hall. Negative
	 initial value provoke beta=0; default beta=0.04.

hmax     Maximal step size, default xend-x.

h        Initial step size, default is a guess computed by the function hinit.

nmax     Maximal number of allowed steps, default 100000.

meth     Switch for the choice of the method coefficients; at the moment the
	 only possibility and default value are 1.

nstiff   Test for stiffness is activated when the current step number is a
	 multiple of nstiff. A negative value means no test and the default
	 is 1000.

nrdens   Number of components for which dense outpout is required, default 0.
	 For 0 < nrdens < n, the components have to be specified in icont[0],
	 icont[1], ... icont[nrdens-1]. Note that if nrdens=0 or nrdens=n, no
	 icont is needed, pass NULL.


Memory requirements
-------------------

	 The function dopri5 allocates dynamically 8*n doubles for the method
	 stages, 5*nrdens doubles for the interpolation if dense output is
	 performed and n unsigned if 0 < nrdens < n.



OUTPUT PARAMETERS
-----------------

y       numerical solution at x=xRead() (see below).

dopri5 returns the following values

	 1 : computation successful,
	 2 : computation successful interrupted by solout,
	-1 : input is not consistent,
	-2 : larger nmax is needed,
	-3 : step size becomes too small,
	-4 : the problem is probably stff (interrupted).


Several functions provide access to different values :

xRead   x value for which the solution has been computed (x=xend after
	successful return).

hRead   Predicted step size of the last accepted step (useful for a
	subsequent call to dopri5).

nstepRead   Number of used steps.
naccptRead  Number of accepted steps.
nrejctRead  Number of rejected steps.
nfcnRead    Number of function calls.


*/


#include <stdio.h>
#include <limits.h>

#define DP5_SUCCESS            251
#define DP5_ROOT_RETURN        252
#define DP5_ZERO_DETACH_RETURN 253

#define DP5_TOO_MUCH_WORK    -251
#define DP5_TOO_MUCH_ACC     -252
#define DP5_ILL_INPUT        -253
#define DP5_ERR_FAILURE      -254 
#define DP5_CONV_FAILURE     -255
#define DP5_BAD_EWT          -256
#define DP5_I_R_HOT_SHORT    -257
#define DP5_RTFUNC_FAIL      -258
#define DP5_BAD_INIT_ROOT    -259
#define DP5_CLOSE_ROOTS      -260

typedef void (*FcnEqDiff)(unsigned n, double x, double *y, double *f, void *udata);
typedef int (*FcnZeroC)(unsigned n, double x, double *y, double *g, void *udata);

typedef struct {
  double    *rcont1, *rcont2, *rcont3, *rcont4, *rcont5;
  double    x, xstop, x_old, *y, *yy1, *k1, *k2, *k3, *k4, *k5, *k6, *ysti, *tmp;
  double    *atoler, rtoler, h, h_old, hmax, facold, uround;
  double    beta, safe, fac1, fac2, posneg;
  int       itoler,meth;
  long      nfcn, nstep, naccpt, nrejct, nmax,nstiff,nonsti,iasti;
  unsigned  n, ng;
  int *iroots, irfnd;
  double *glo, *ghi, *grout, tlo, thi, trout, ttol, tretlast;
  FcnEqDiff fcn;
  FcnZeroC  gcn;
  FILE* fileout;
  int  fcallerid;
  void *udata;
} DOPRI5_mem;

typedef struct {
  void *dopri5_mem;
} User_DP5_data;


#include <float.h>

#define DORI5_DOUBLE_PRECISION 1

#if defined(DORI5_SINGLE_PRECISION)
#define RCONST(x) x##F
#define BIG_REAL FLT_MAX
#define SMALL_REAL FLT_MIN
#define UNIT_ROUNDOFF FLT_EPSILON

#elif defined(DORI5_DOUBLE_PRECISION)

#define RCONST(x) x
#define BIG_REAL DBL_MAX
#define SMALL_REAL DBL_MIN
#define UNIT_ROUNDOFF DBL_EPSILON

#elif defined(DORI5_EXTENDED_PRECISION)

#define RCONST(x) x##L
#define BIG_REAL LDBL_MAX
#define SMALL_REAL LDBL_MIN
#define UNIT_ROUNDOFF LDBL_EPSILON

#endif

/*
long nfcnRead   (DOPRI5_mem *dopri5_mem);
long nstepRead  (DOPRI5_mem *dopri5_mem);
long naccptRead (DOPRI5_mem *dopri5_mem);
long nrejctRead (DOPRI5_mem *dopri5_mem);
double hRead  (DOPRI5_mem *dopri5_mem);
double xRead  (DOPRI5_mem *dopri5_mem);
*/

int DP5_set_tstop (DOPRI5_mem *dopri5_mem, double xstop);
int DP5_Get_RootInfo (DOPRI5_mem *dopri5_mem, int *jroot);
int DP5_Get_fcallerid(DOPRI5_mem *dopri5_mem,  int *fcallerid);

/*
double hinit (DOPRI5_mem *dopri5_mem, int iord);
double contd5 (DOPRI5_mem *dopri5_mem, unsigned i, double x, double xold, double h);
*/
int dopri5_solve (DOPRI5_mem *dopri5_mem,double *xio, double xout, double* yio, int hot_start);

int  Setup_dopri5(DOPRI5_mem **dopri5_mem, unsigned n, FcnEqDiff fcn, double xstart,double xend,
		  double rtoler, double* atoler, int itoler,  double hmax, unsigned ng, FcnZeroC gcn,
		  User_DP5_data **dopri5_udata);

int dopri5_free (DOPRI5_mem *dopri5_mem);
