      DOUBLE PRECISION FUNCTION dlngam(a)
C**********************************************************************
C
C     DOUBLE PRECISION FUNCTION DLNGAM(X)
C                 Double precision LN of the GAMma function
C
C
C                              Function
C
C
C     Returns the natural logarithm of GAMMA(X).
C
C
C                              Arguments
C
C
C     X --> value at which scaled log gamma is to be returned
C                    X is DOUBLE PRECISION
C
C
C                              Method
C
C
C     Renames GAMLN from:
C     DiDinato, A. R. and Morris,  A.   H.  Algorithm 708: Significant
C     Digit Computation of the Incomplete  Beta  Function Ratios.  ACM
C     Trans. Math.  Softw. 18 (1993), 360-373.
C
C**********************************************************************
C-----------------------------------------------------------------------
C            EVALUATION OF LN(GAMMA(A)) FOR POSITIVE A
C-----------------------------------------------------------------------
C     WRITTEN BY ALFRED H. MORRIS
C          NAVAL SURFACE WARFARE CENTER
C          DAHLGREN, VIRGINIA
C--------------------------
C     D = 0.5*(LN(2*PI) - 1)
C--------------------------
C     .. Scalar Arguments ..
      DOUBLE PRECISION a
C     ..
C     .. Local Scalars ..
      DOUBLE PRECISION c0,c1,c2,c3,c4,c5,d,t,w
      INTEGER i,n
C     ..
C     .. External Functions ..
      DOUBLE PRECISION gamln1
      EXTERNAL gamln1
C     ..
C     .. Intrinsic Functions ..
      INTRINSIC dlog
C     ..
C     .. Data statements ..
C--------------------------
      DATA d/.418938533204673D0/
      DATA c0/.833333333333333D-01/,c1/-.277777777760991D-02/,
     +     c2/.793650666825390D-03/,c3/-.595202931351870D-03/,
     +     c4/.837308034031215D-03/,c5/-.165322962780713D-02/
C     ..
C     .. Executable Statements ..
C-----------------------------------------------------------------------
      IF (a.GT.0.8D0) GO TO 10
      dlngam = gamln1(a) - dlog(a)
      RETURN

   10 IF (a.GT.2.25D0) GO TO 20
      t = (a-0.5D0) - 0.5D0
      dlngam = gamln1(t)
      RETURN
C
   20 IF (a.GE.10.0D0) GO TO 40
      n = a - 1.25D0
      t = a
      w = 1.0D0
      DO 30 i = 1,n
          t = t - 1.0D0
          w = t*w
   30 CONTINUE
      dlngam = gamln1(t-1.0D0) + dlog(w)
      RETURN
C
   40 t = (1.0D0/a)**2
      w = (((((c5*t+c4)*t+c3)*t+c2)*t+c1)*t+c0)/a
      dlngam = (d+w) + (a-0.5D0)* (dlog(a)-1.0D0)
      END
