/*------------------------------------------------
 *     Scicos block simulator 
 *     Logical and block
 *     if event input exists synchronuously, output is 1 else -1
 *------------------------------------------------*/

void andlog(flag, nevprt, t, xd, x, nx, z, nz, tvec, \
            ntvec, rpar, nrpar, ipar, nipar, u, nu, y, ny)
     int *flag, *nevprt,*nx,*nz,*nrpar, *ipar, *nipar,*ntvec,*nu,*ny;
     double *t, *xd, *x, *z, *tvec, *rpar, *u, *y;
{
  if ( *flag == 1)  y[0] = ( *nevprt != 3 ) ? -1.00 :  1.00; 
}

