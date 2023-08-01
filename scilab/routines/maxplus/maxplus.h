#ifndef MAXPLUS_H 
#define MAXPLUS_H 

extern int Howard(int *ij, double *A,int nnodes,int narcs,double *chi,double *v,int *pi,
		  int *NIterations,int *NComponents,int verbosemode);

extern int Semi_Howard(int *ij, double *A,double *t,int nnodes,int narcs,double *chi,double *v,
		       int *pi,int *NIterations,int *NComponents,int verbosemode);

extern int FordBellman (int *ij, double *A, int nnodes, int narcs, int entry, double *u,int *policy, int *niterations, int arc);

extern void Karp (int *ij,double *A,int nnodes, int narcs, int entry, double *u);

extern int in_span (double *A,int n, int p, double *b, double precision);

extern void weakbasis (double *A,int n,int p, double **B, int *q, double precision);

extern void weakbasis2 (double *A,int n,int p, double **B, int *q, double precision);


extern int include_span (double *A,int n, int p, double *B, int q, double precision);

extern void STproduct (double *A, int n, int p, double *B, int q, double *C);
extern void rowbasis (double *A,int n,double *B,double **U, int *q, double precision);



extern void print_matrix(double *A, int n, int p);
extern int solve2 (double *A, int n, int p, double *B,double **U,double precision);

extern int solve3 (double *A, int n, int p, double *B,double **U,double precision);

extern void matrix_plus (double *B, int n, double *C);
extern void matrix_star (double *B, int n, double *C);

#endif 
