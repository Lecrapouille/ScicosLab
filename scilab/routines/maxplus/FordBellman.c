#include <stddef.h>
#include <stdlib.h>
#include <math.h>
#include <stdio.h>

#include "maxplus.h" 

#define EPSILON -HUGE_VAL

#define head(ij,k) ij[k<<1]
#define tail(ij,k) ij[(k<<1)+1]


/* Stephane.Gaubert@inria.fr, 16/02/2000. 
 *  Ford-Bellman Algorithm with Gauss-Seidel variant,
 *  Ref: Gondran and  Minoux, Graphes et Algorithmes,
 *  Eyrolles, 1979, chap3, sec 4.2
 *  
 *  Given an initial node and a weighted digraph (ij,A),
 *  computes for all j, the maximal weight u[j] of a path from I to j
 *  Also returns a policy pi: pi[j] is by definition the predecessor
 *  of j on an optimal path. Thus, the arcs pi[j]->j for a tree,
 *  with root the initial node.
 *
 * ij: tail/head matrix. the i-th arc goes from ij[2*i] to ij[2*i+1]
 * A: weight vector. A[i] = weight of arc i
 *
 * Modified Oct 13, 2008, pi[j] is now the number of an optimal arc pointing to node j
 * Modified Oct 14, 2008, (jpc) arc option added in the calling list 
 *  if arc==0 the policy gave the optimal predecessor node number 
 *  else policy gives the optimal predecessor arc number
 */

int FordBellman(int *ij,double *A,int nnodes, int narcs, int initial, double *u, int *policy, int *niterations, int arc)
{  
  int i,j,improved=0;
  int horizon;
  if ((initial<0)||(initial>=nnodes))
    {
      printf("Error: initial point is out of range!\n");
      return(2);
    }
  for (i=0; i<nnodes; i++)
    {
      u[i]=EPSILON;  
    }
  u[initial]=0;
  policy[initial]=initial;
  horizon=nnodes;
  for (j=0;j<horizon;j++)
    {
      improved=0;
      for (i=0;i<narcs; i++)
	{
	  if (A[i]+u[head(ij,i)] > u[tail(ij,i)]+1e-10)
	    {
	      improved=1;
	      if ( arc == 0) 
		{
		  /* policy gave the optimal predecessor node number*/
		  policy[tail(ij,i)]=head(ij,i);
		}
	      else 
		{
		  /* policy now gives the optimal predecessor arc number */
		  policy[tail(ij,i)]=i;
		}
	      u[tail(ij,i)]= A[i]+u[head(ij,i)];
	    }
	}
      if (improved==0) horizon=0; /* end of loop */
    }
  
  *niterations=j;
  if (improved)
    {
      printf("Error in FordBellman, the digraph contains a circuit with positive weight\n");
      return(1);
    }
  else
    {
      return(0);
    }
}




