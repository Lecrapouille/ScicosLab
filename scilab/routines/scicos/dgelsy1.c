/* Table of constant values */

static int c__1 = 1;
static int c_n1 = -1;
static int c__0 = 0;
static double c_b31 = 0.;
static int c__2 = 2;
static double c_b54 = 1.;

#define min(a,b) ((a) <= (b) ? (a) : (b))
#define max(a,b) ((a) >= (b) ? (a) : (b))
#define abs(x) ((x) >= 0 ? (x) : -(x))

/* Subroutine */ int dgelsy1_(int *m, int *n, int *nrhs, 
	double *a, int *lda, double *b, int *ldb, int *
	jpvt, double *rcond, int *rank, double *work, int *
	lwork, int *info)
{
    /* System generated locals */
    int a_dim1, a_offset, b_dim1, b_offset, i__1, i__2;
    double d__1, d__2;

    /* Local variables */
    static int i__, j;
    static double c1, c2, s1, s2;
    static int nb, mn, nb1, nb2, nb3, nb4;
    static double anrm, bnrm, smin, smax;
    static int iascl, ibscl;
    extern /* Subroutine */ int dcopy_(int *, double *, int *, 
	    double *, int *);
    static int ismin, ismax;
    extern /* Subroutine */ int dtrsm_(char *, char *, char *, char *, 
	    int *, int *, double *, double *, int *, 
	    double *, int *, int, int, int, int), dlaic1_(
	    int *, int *, double *, double *, double *, 
	    double *, double *, double *, double *);
    static double wsize;
    extern /* Subroutine */ int dgeqp3_(int *, int *, double *, 
	    int *, int *, double *, double *, int *, 
	    int *), dlabad_(double *, double *);
    extern double dlamch_(char *, int), dlange_(char *, int *, 
	    int *, double *, int *, double *, int);
    extern /* Subroutine */ int dlascl_(char *, int *, int *, 
	    double *, double *, int *, int *, double *, 
	    int *, int *, int), dlaset_(char *, int *, int 
	    *, double *, double *, double *, int *, int), 
	    xerbla_(char *, int *, int);
    extern int ilaenv_(int *, char *, char *, int *, int *, 
	    int *, int *, int, int);
    static double bignum;
    extern /* Subroutine */ int dormqr_(char *, char *, int *, int *, 
	    int *, double *, int *, double *, double *, 
	    int *, double *, int *, int *, int, int);
    static double sminpr, smaxpr, smlnum;
    static int lwkopt;
    static int lquery;


/*     -- LAPACK driver routine (version 3.0) -- */
/*     Univ. of Tennessee, Univ. of California Berkeley, NAG Ltd., */
/*     Courant Institute, Argonne National Lab, and Rice University */
/*     June 30, 1999 */

/*     .. Scalar Arguments .. */
/*     .. */
/*     .. Array Arguments .. */
/*     .. */

/*     Purpose */
/*     ======= */

/*     DGELSY1 computes a solution, with at least N-RANK zeros to a real */
/*     linear least squares problem: */
/*     minimize || A * X - B || */
/*     using a complete orthogonal factorization of A.  A is an M-by-N */
/*     matrix which may be rank-deficient. */

/*     Several right hand side vectors b and solution vectors x can be */
/*     handled in a single call; they are stored as the columns of the */
/*     M-by-NRHS right hand side matrix B and the N-by-NRHS solution */
/*     matrix X. */

/*     The routine first computes a QR factorization with column */
/*     pivoting: */
/*     A * P = Q * [ R11 R12 ] */
/*                 [  0  R22 ] */
/*     with R11 defined as the largest leading submatrix whose estimated */
/*     condition number is less than 1/RCOND.  The order of R11, RANK, */
/*     is the effective rank of A. */

/*     Then, R22 is considered to be negligible, */
/*     The  solution return is then */
/*     X = P * [ inv(R11)*Q1'*B ] */
/*             [        0       ] */
/*     where Q1 consists of the first RANK columns of Q. */

/*     This routine is basically identical to the original xGELSX except */
/*     three differences: */
/*     o The call to the subroutine xGEQPF has been substituted by the */
/*     the call to the subroutine xGEQP3. This subroutine is a Blas-3 */
/*     version of the QR factorization with column pivoting. */
/*     o Matrix B (the right hand side) is updated with Blas-3. */
/*     o The permutation of matrix B (the right hand side) is faster and */
/*     more simple. */

/*     Arguments */
/*     ========= */

/*     M       (input) int */
/*     The number of rows of the matrix A.  M >= 0. */

/*     N       (input) int */
/*     The number of columns of the matrix A.  N >= 0. */

/*     NRHS    (input) int */
/*     The number of right hand sides, i.e., the number of */
/*     columns of matrices B and X. NRHS >= 0. */

/*     A       (input/output) DOUBLE PRECISION array, dimension (LDA,N) */
/*     On entry, the M-by-N matrix A. */
/*     On exit, A has been overwritten by details of its */
/*     complete orthogonal factorization. */

/*     LDA     (input) int */
/*     The leading dimension of the array A.  LDA >= max(1,M). */

/*     B       (input/output) DOUBLE PRECISION array, dimension (LDB,NRHS */
/*     ) */
/*     On entry, the M-by-NRHS right hand side matrix B. */
/*     On exit, the N-by-NRHS solution matrix X. */

/*     LDB     (input) int */
/*     The leading dimension of the array B. LDB >= max(1,M,N). */

/*     JPVT    (input/output) int array, dimension (N) */
/*     On entry, if JPVT(i) .ne. 0, the i-th column of A is permuted */
/*     to the front of AP, otherwise column i is a free column. */
/*     On exit, if JPVT(i) = k, then the i-th column of AP */
/*     was the k-th column of A. */

/*     RCOND   (input) DOUBLE PRECISION */
/*     RCOND is used to determine the effective rank of A, which */
/*     is defined as the order of the largest leading triangular */
/*     submatrix R11 in the QR factorization with pivoting of A, */
/*     whose estimated condition number < 1/RCOND. */

/*     RANK    (output) int */
/*     The effective rank of A, i.e., the order of the submatrix */
/*     R11.  This is the same as the order of the submatrix T11 */
/*     in the complete orthogonal factorization of A. */

/*     WORK    (workspace/output) DOUBLE PRECISION array, dimension */
/*     (LWORK) */
/*     On exit, if INFO = 0, WORK(1) returns the optimal LWORK. */

/*     LWORK   (input) int */
/*     The dimension of the array WORK. */
/*     The unblocked strategy requires that: */
/*     LWORK >= MAX( MN+3*N+1, 2*MN+NRHS ), */
/*     where MN = min( M, N ). */
/*     The block algorithm requires that: */
/*     LWORK >= MAX( MN+2*N+NB*(N+1), 2*MN+NB*NRHS ), */
/*     where NB is an upper bound on the blocksize returned */
/*     by ILAENV for the routines DGEQP3, DTZRZF, STZRQF, DORMQR, */
/*     and DORMRZ. */

/*     If LWORK = -1, then a workspace query is assumed; the routine */
/*     only calculates the optimal size of the WORK array, returns */
/*     this value as the first entry of the WORK array, and no error */
/*     message related to LWORK is issued by XERBLA. */

/*     INFO    (output) int */
/*     = 0: successful exit */
/*     < 0: If INFO = -i, the i-th argument had an illegal value. */

/*     Further Details */
/*     =============== */

/*     Based on contributions by */
/*     A. Petitet, Computer Science Dept., Univ. of Tenn., Knoxville, USA */
/*     E. Quintana-Orti, Depto. de Informatica, Universidad Jaime I, */
/*     Spain */
/*     G. Quintana-Orti, Depto. de Informatica, Universidad Jaime I, */
/*     Spain */

/*     ================================================================== */
/*     === */

/*     .. Parameters .. */
/*     .. */
/*     .. Local Scalars .. */
/*     .. */
/*     .. External Functions .. */
/*     .. */
/*     .. External Subroutines .. */
/*     .. */
/*     .. Intrinsic Functions .. */
/*     .. */
/*     .. Executable Statements .. */

    /* Parameter adjustments */
    a_dim1 = *lda;
    a_offset = 1 + a_dim1;
    a -= a_offset;
    b_dim1 = *ldb;
    b_offset = 1 + b_dim1;
    b -= b_offset;
    --jpvt;
    --work;

    /* Function Body */
    mn = min(*m,*n);
    ismin = mn + 1;
    ismax = (mn << 1) + 1;

/*     Test the input arguments. */

    *info = 0;
    nb1 = ilaenv_(&c__1, "DGEQRF", " ", m, n, &c_n1, &c_n1, (int)6, (
	    int)1);
    nb2 = ilaenv_(&c__1, "DGERQF", " ", m, n, &c_n1, &c_n1, (int)6, (
	    int)1);
    nb3 = ilaenv_(&c__1, "DORMQR", " ", m, n, nrhs, &c_n1, (int)6, (int)
	    1);
    nb4 = ilaenv_(&c__1, "DORMRQ", " ", m, n, nrhs, &c_n1, (int)6, (int)
	    1);
/* Computing MAX */
    i__1 = max(nb1,nb2), i__1 = max(i__1,nb3);
    nb = max(i__1,nb4);
/* Computing MAX */
    i__1 = 1, i__2 = mn + (*n << 1) + nb * (*n + 1), i__1 = max(i__1,i__2), 
	    i__2 = (mn << 1) + nb * *nrhs;
    lwkopt = max(i__1,i__2);
    work[1] = (double) lwkopt;
    lquery = *lwork == -1;
    if (*m < 0) {
	*info = -1;
    } else if (*n < 0) {
	*info = -2;
    } else if (*nrhs < 0) {
	*info = -3;
    } else if (*lda < max(1,*m)) {
	*info = -5;
    } else /* if(complicated condition) */ {
/* Computing MAX */
	i__1 = max(1,*m);
	if (*ldb < max(i__1,*n)) {
	    *info = -7;
	} else /* if(complicated condition) */ {
/* Computing MAX */
	    i__1 = 1, i__2 = mn + *n * 3 + 1, i__1 = max(i__1,i__2), i__2 = (
		    mn << 1) + *nrhs;
	    if (*lwork < max(i__1,i__2) && ! lquery) {
		*info = -12;
	    }
	}
    }

    if (*info != 0) {
	i__1 = -(*info);
	xerbla_("DGELSY", &i__1, (int)6);
	return 0;
    } else if (lquery) {
	return 0;
    }

/*     Quick return if possible */

/* Computing MIN */
    i__1 = min(*m,*n);
    if (min(i__1,*nrhs) == 0) {
	*rank = 0;
	return 0;
    }

/*     Get machine parameters */

    smlnum = dlamch_("S", (int)1) / dlamch_("P", (int)1);
    bignum = 1. / smlnum;
    dlabad_(&smlnum, &bignum);

/*     Scale A, B if max entries outside range [SMLNUM,BIGNUM] */

    anrm = dlange_("M", m, n, &a[a_offset], lda, &work[1], (int)1);
    iascl = 0;
    if (anrm > 0. && anrm < smlnum) {

/*     Scale matrix norm up to SMLNUM */

	dlascl_("G", &c__0, &c__0, &anrm, &smlnum, m, n, &a[a_offset], lda, 
		info, (int)1);
	iascl = 1;
    } else if (anrm > bignum) {

/*     Scale matrix norm down to BIGNUM */

	dlascl_("G", &c__0, &c__0, &anrm, &bignum, m, n, &a[a_offset], lda, 
		info, (int)1);
	iascl = 2;
    } else if (anrm == 0.) {

/*     Matrix all zero. Return zero solution. */

	i__1 = max(*m,*n);
	dlaset_("F", &i__1, nrhs, &c_b31, &c_b31, &b[b_offset], ldb, (int)
		1);
	*rank = 0;
	goto L70;
    }

    bnrm = dlange_("M", m, nrhs, &b[b_offset], ldb, &work[1], (int)1);
    ibscl = 0;
    if (bnrm > 0. && bnrm < smlnum) {

/*     Scale matrix norm up to SMLNUM */

	dlascl_("G", &c__0, &c__0, &bnrm, &smlnum, m, nrhs, &b[b_offset], ldb,
		 info, (int)1);
	ibscl = 1;
    } else if (bnrm > bignum) {

/*     Scale matrix norm down to BIGNUM */

	dlascl_("G", &c__0, &c__0, &bnrm, &bignum, m, nrhs, &b[b_offset], ldb,
		 info, (int)1);
	ibscl = 2;
    }

/*     Compute QR factorization with column pivoting of A: */
/*     A * P = Q * R */

    i__1 = *lwork - mn;
    dgeqp3_(m, n, &a[a_offset], lda, &jpvt[1], &work[1], &work[mn + 1], &i__1,
	     info);
    wsize = mn + work[mn + 1];

/*     workspace: MN+2*N+NB*(N+1). */
/*     Details of Householder rotations stored in WORK(1:MN). */

/*     Determine RANK using incremental condition estimation */

    work[ismin] = 1.;
    work[ismax] = 1.;
    smax = (d__1 = a[a_dim1 + 1], abs(d__1));
    smin = smax;
    if ((d__1 = a[a_dim1 + 1], abs(d__1)) == 0.) {
	*rank = 0;
	i__1 = max(*m,*n);
	dlaset_("F", &i__1, nrhs, &c_b31, &c_b31, &b[b_offset], ldb, (int)
		1);
	goto L70;
    } else {
	*rank = 1;
    }

L10:
    if (*rank < mn) {
	i__ = *rank + 1;
	dlaic1_(&c__2, rank, &work[ismin], &smin, &a[i__ * a_dim1 + 1], &a[
		i__ + i__ * a_dim1], &sminpr, &s1, &c1);
	dlaic1_(&c__1, rank, &work[ismax], &smax, &a[i__ * a_dim1 + 1], &a[
		i__ + i__ * a_dim1], &smaxpr, &s2, &c2);

	if (smaxpr * *rcond <= sminpr) {
	    i__1 = *rank;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		work[ismin + i__ - 1] = s1 * work[ismin + i__ - 1];
		work[ismax + i__ - 1] = s2 * work[ismax + i__ - 1];
/* L20: */
	    }
	    work[ismin + *rank] = c1;
	    work[ismax + *rank] = c2;
	    smin = sminpr;
	    smax = smaxpr;
	    ++(*rank);
	    goto L10;
	}
    }

/*     workspace: 3*MN. */

/*     intly partition R = [ R11 R12 ] */
/*     [  0  R22 ] */
/*     where R11 = R(1:RANK,1:RANK) */

/*     *     [R11,R12] = [ T11, 0 ] * Y */
/*     * */
/*     IF( RANK.LT.N ) */
/*     $   CALL DTZRZF( RANK, N, A, LDA, WORK( MN+1 ), WORK( 2*MN+1 ), */
/*     $                LWORK-2*MN, INFO ) */
/*     * */
/*     *     workspace: 2*MN. */
/*     Details of Householder rotations stored in WORK(MN+1:2*MN) */

/*     B(1:M,1:NRHS) := Q' * B(1:M,1:NRHS) */

    i__1 = *lwork - (mn << 1);
    dormqr_("Left", "Transpose", m, nrhs, &mn, &a[a_offset], lda, &work[1], &
	    b[b_offset], ldb, &work[(mn << 1) + 1], &i__1, info, (int)4, (
	    int)9);
/* Computing MAX */
    d__1 = wsize, d__2 = (mn << 1) + work[(mn << 1) + 1];
    wsize = max(d__1,d__2);

/*     workspace: 2*MN+NB*NRHS. */

/*     B(1:RANK,1:NRHS) := inv(T11) * B(1:RANK,1:NRHS) */

    dtrsm_("Left", "Upper", "No transpose", "Non-unit", rank, nrhs, &c_b54, &
	    a[a_offset], lda, &b[b_offset], ldb, (int)4, (int)5, (
	    int)12, (int)8);

    i__1 = *nrhs;
    for (j = 1; j <= i__1; ++j) {
	i__2 = *n;
	for (i__ = *rank + 1; i__ <= i__2; ++i__) {
	    b[i__ + j * b_dim1] = 0.;
/* L30: */
	}
/* L40: */
    }
/*     * */
/*     *     B(1:N,1:NRHS) := Y' * B(1:N,1:NRHS) */
/*     * */
/*     IF( RANK.LT.N ) THEN */
/*     CALL DORMRZ( 'Left', 'Transpose', N, NRHS, RANK, N-RANK, A, */
/*     $                LDA, WORK( MN+1 ), B, LDB, WORK( 2*MN+1 ), */
/*     $                LWORK-2*MN, INFO ) */
/*     END IF */
/*     * */
/*     *     workspace: 2*MN+NRHS. */

/*     B(1:N,1:NRHS) := P * B(1:N,1:NRHS) */

    i__1 = *nrhs;
    for (j = 1; j <= i__1; ++j) {
	i__2 = *n;
	for (i__ = 1; i__ <= i__2; ++i__) {
	    work[jpvt[i__]] = b[i__ + j * b_dim1];
/* L50: */
	}
	dcopy_(n, &work[1], &c__1, &b[j * b_dim1 + 1], &c__1);
/* L60: */
    }

/*     workspace: N. */

/*     Undo scaling */

    if (iascl == 1) {
	dlascl_("G", &c__0, &c__0, &anrm, &smlnum, n, nrhs, &b[b_offset], ldb,
		 info, (int)1);
	dlascl_("U", &c__0, &c__0, &smlnum, &anrm, rank, rank, &a[a_offset], 
		lda, info, (int)1);
    } else if (iascl == 2) {
	dlascl_("G", &c__0, &c__0, &anrm, &bignum, n, nrhs, &b[b_offset], ldb,
		 info, (int)1);
	dlascl_("U", &c__0, &c__0, &bignum, &anrm, rank, rank, &a[a_offset], 
		lda, info, (int)1);
    }
    if (ibscl == 1) {
	dlascl_("G", &c__0, &c__0, &smlnum, &bnrm, n, nrhs, &b[b_offset], ldb,
		 info, (int)1);
    } else if (ibscl == 2) {
	dlascl_("G", &c__0, &c__0, &bignum, &bnrm, n, nrhs, &b[b_offset], ldb,
		 info, (int)1);
    }

L70:
    work[1] = (double) lwkopt;

    return 0;

/*     End of DGELSY */

} /* dgelsy1_ */

