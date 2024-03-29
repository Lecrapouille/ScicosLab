#include <machine.h>
/* Code prototype for standalone use  */
/*     Generated by Code_Generation toolbox of Scicos with scilab-2.6 */
/*     date : 15-Feb-2002 */

#include <stdio.h>
#include <string.h>
static  FILE * fd;

void thermmain1(double *z, double *t, double * rpar, integer *nrpar,
  integer *ipar,integer *nipar);

void thermmain2(double *z, double *t, double * rpar, integer *nrpar,
  integer *ipar,integer *nipar) ;

void therm_init(double *z, double *t, double * rpar, integer *nrpar,
  integer *ipar,integer *nipar) ;

void therm_end(double *z, double *t, double * rpar, integer *nrpar,
  integer *ipar,integer * nipar) ;

void therm_sim(double tf) ;

void therm_events(int *nevprt, double *t);

void set_nevprt(int nevprt);
static double RPAR1[ ] = {0,0,6,-6,10,-10,1,1,0.1,0};
static integer NRPAR1  = 10;
static integer IPAR1[ ]= {1,1,1,2};
static integer NIPAR1  = 4;
/*Main program */
int main()
{
  double tf=10.0;
  therm_sim(tf);
  return 0;
}

/*----------------------------------------  External simulation function */ 
void 
therm_sim(tf)
 
     double tf; 
{
  double t;
  int nevprt=1;

  /*Initial values */
  double z[]={0,0,0,0,0,0,6,-6,10,-10,-10,10,0,-6,-6,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0};
  t=0.0;
  therm_init(z,&t,RPAR1,&NRPAR1,IPAR1,&NIPAR1);
  while (t<=tf) {   
    therm_events(&nevprt,&t);
    set_nevprt(nevprt);
    thermmain1(z,&t,RPAR1,&NRPAR1,IPAR1,&NIPAR1);
    thermmain2(z,&t,RPAR1,&NRPAR1,IPAR1,&NIPAR1);
  }
  therm_end(z,&t,RPAR1,&NRPAR1,IPAR1,&NIPAR1);
  return ;
}
/*----------------------------------------  Lapack messag function */ 
void
C2F(xerbla)(SRNAME,INFO,L)
char *SRNAME;
int *INFO;
long int L;
{
printf("** On entry to %s, parameter number %d  had an illegal value\n",SRNAME,*INFO);
}
/*----------------------------------------  External events handling function */ 
void 
therm_events(int *nevprt,double *t)
{
/*  set next event time and associated events ports  
 *  nevprt has binary expression b1..b1 where bi is a bit 
 *  bi is set to 1 if an activation is received by port i. Note that
 *  more than one activation can be received simultaneously 
 *  Caution: at least one bi should be equal to one */

    int i,p,b[]={0};

    b[0]=1;
    *t = *t + 0.1;
    *nevprt=0;p=1;
    for (i=0;i<1;i++) {
      *nevprt=*nevprt+b[i]*p;
      p=p*2;}
}
/*---------------------------------------- Actuators */ 
void 
therm_actuator(flag,nport,nevprt,t,u,nu)
     /*
      * To be customized for standalone execution
      * flag  : specifies the action to be done
      * nport : specifies the  index of the Super Bloc 
      *         regular input (The input ports are numbered 
      *         from the top to the bottom ) 
      * nevprt: indicates if an activation had been received
      *         0 = no activation
      *         1 = activation
      * t     : the current time value
      * u     : the vector inputs value
      * nu    : the input  vector size
      */
     integer *flag,*nevprt,*nport;
     integer *nu;

     double  *t, u[];
{
  int k;
  switch (*nport) {
  case 1 :/* Port number 1 ----------*/
    /* skeleton to be customized */
    switch (*flag) {
    case 2 : 
/* CUST: added */
      printf("t=%4.1f |               | out1 = %6.2f |               |\n",*t,u[0]);
      break;
    case 4 : /* actuator initialisation */
      /* do whatever you want to initialize the actuator */
      break;
    case 5 : /* actuator ending */
      /* do whatever you want to end the actuator */
      break;
    }
  break;
  case 2 :/* Port number 2 ----------*/
    switch (*flag) {
    case 2 : 
      /* CUST: added */
      printf("t=%4.1f |               |               | OUT2 = %6.2f |\n",*t,u[0]);
      break;
    case 4 : /* actuator initialisation */
      /* do whatever you want to initialize the actuator */
      break;
    case 5 : /* actuator ending */
      /* do whatever you want to end the actuator */
      break;
    }
  break;
  }
}
/*---------------------------------------- Sensor */ 
void 
therm_sensor(flag,nport,nevprt,t,y,ny)
     /*
      * To be customized for standalone execution
      * flag  : specifies the action to be done
      * nport : specifies the  index of the Super Bloc 
      *         regular input (The input ports are numbered 
      *         from the top to the bottom ) 
      * nevprt: indicates if an activation had been received
      *         0 = no activation
      *         1 = activation
      * t     : the current time value
      * y     : the vector outputs value
      * ny    : the output  vector size
      */
     integer *flag,*nevprt,*nport;
     integer *ny;

     double  *t, y[];
{
  int k;
  float tmp;
 
  switch (*flag) {
  case 1 : /* set the ouput value */
    /* skeleton to be customized */
    /* CUST: added */
    fscanf(fd,"%e\n",&tmp);y[0]=tmp;
    printf("t=%4.1f | in   = %6.2f |               |               |\n",*t,y[0]);
    break;
  case 2 : /* Update internal discrete state if any */
    break;
  case 4 : /* sensor initialisation */
    /* do whatever you want to initialize the sensor */
    fd=fopen("data","r");/* CUST: added */
    break;
  case 5 : /* sensor ending */
    /* do whatever you want to end the sensor */
    fclose(fd);/* CUST: added */
    break;
  }
}
