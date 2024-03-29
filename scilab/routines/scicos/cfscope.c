/**
   \file cfscope.c
   \author Benoit Bayol
   \version 1.0
   \date September 2006 - January 2007
   \brief CFSCOPE This scope has no input port because it displays the values on the designated link
   \see CFSCOPE.sci in macros/scicos_blocks/Sinks/
*/

#include "scoMemoryScope.h"
#include "scoWindowScope.h"
#include "scoMisc.h"
#include "scoGetProperty.h"
#include "scoSetProperty.h"
#include "scicos_block4.h"

/** \fn cfscope_draw(scicos_block * block, ScopeMemory ** pScopeMemory, int firstdraw)
    \brief Function to draw or redraw the window
*/
void cfscope_draw(scicos_block * block, ScopeMemory ** pScopeMemory, int firstdraw)
{

  double *rpar;
  int *ipar, nipar;   

  double period;
  int i;
  int dimension;
  double ymin, ymax, xmin, xmax;
  int buffer_size;
  int win_pos[2];
  int win_dim[2];
  int win;
  int number_of_subwin;
  int number_of_curves_by_subwin;
  double dt;
  int nbr_of_curves;
  int color_flag;
  int * colors;
  char *label;

  /*Retrieving Parameters*/
  rpar = GetRparPtrs(block);
  ipar = GetIparPtrs(block);
  nipar = GetNipar(block);
  win = ipar[0];
  color_flag = ipar[1];
  buffer_size = ipar[2];
  dt = rpar[0];
  period = rpar[3];
  ymin  = rpar[1];
  ymax = rpar[2];
  label = GetLabelPtrs(block);

  dimension = 2;
  win_pos[0] = ipar[11];
  win_pos[1] = ipar[12];
  win_dim[0] = ipar[13];
  win_dim[1] = ipar[14];
  number_of_curves_by_subwin = ipar[15]; //Here is not really what we will see i.e. if you give [2:9] there is 8 curves but in the kalman filter demo you will only see 6 curves (and 8 in the figure handle description) because only 6 are really existing.
  nbr_of_curves = number_of_curves_by_subwin;
  number_of_subwin = 1;

  colors=(int*)scicos_malloc(8*sizeof(int));
  for( i = 3 ; i < 10 ; i++)
    {
      colors[i-3] = ipar[i];
    }

  /*Allocating memory*/
  if(firstdraw == 1)
    {
      scoInitScopeMemory(GetPtrWorkPtrs(block),pScopeMemory, number_of_subwin, &number_of_curves_by_subwin);
      /*Must be placed before adding polyline or other elements*/
      scoSetLongDrawSize(*pScopeMemory, 0, 5000);
      scoSetShortDrawSize(*pScopeMemory,0,buffer_size);
      scoSetPeriod(*pScopeMemory,0,period);
    }

  xmin = period*scoGetPeriodCounter(*pScopeMemory,0);
  xmax = period*(scoGetPeriodCounter(*pScopeMemory,0)+1);

  /*Creating the Scope*/
  scoInitOfWindow(*pScopeMemory, dimension, win, win_pos, win_dim, &xmin, &xmax, &ymin, &ymax, NULL, NULL);
  if(scoGetScopeActivation(*pScopeMemory) == 1)
    {
      scoAddTitlesScope(*pScopeMemory,label,"t","y",NULL);
      
  /*Add a couple of polyline : one for the shortdraw and one for the longdraw*/
      scoAddCoupleOfPolylines(*pScopeMemory,colors);
      scicos_free(colors);
    }
}

extern int C2F(getouttb)();
/** \fn void cfscope(scicos_block * block,int flag)
    \brief the computational function
    \param block A pointer to a scicos_block
    \param flag An integer which indicates the state of the block (init, update, ending)
*/
void cfscope(scicos_block * block,int flag)
{
  void **_work=GetPtrWorkPtrs(block);
  ScopeMemory * pScopeMemory;
  scoGraphicalObject pShortDraw;
  double * sortie;
  int  *  index_of_view;
  double t;
  int nbr_of_curves;
  int *ipar;
  int i,j;
  int NbrPtsShort;
  int **user_data_ptr,*size_ptr;

  switch(flag)
    {
    case Initialization:
      {
	/*Retrieving Parameters*/
	cfscope_draw(block,&pScopeMemory,1);
	break;
      }
    case StateUpdate:
      {	
	

	/*Retreiving Scope in the _work*/
	scoRetrieveScopeMemory(_work,&pScopeMemory);
	if(scoGetPointerScopeWindow(pScopeMemory) == NULL) return;
	if(scoGetScopeActivation(pScopeMemory) == 1)
	  {
	    t = GetScicosTime(block);
	    /* If window has been destroyed we recreate it */

	/*Maybe we are in the end of axes so we have to draw new ones */
	scoRefreshDataBoundsX(pScopeMemory,t);

	//Cannot be factorized depends of the scope
	nbr_of_curves = scoGetNumberOfCurvesBySubwin(pScopeMemory,0);

	ipar = GetIparPtrs(block);
	sortie = (double*)scicos_malloc(nbr_of_curves*sizeof(double));
	index_of_view =(int*)scicos_malloc(nbr_of_curves*sizeof(int));
	for(i = 16 ; i < 16+nbr_of_curves ; i++)
	  {
	    index_of_view[i-16] = ipar[i];
	  }

	C2F(getouttb)(&nbr_of_curves,index_of_view,sortie);
	for(i = 0; i < scoGetNumberOfSubwin(pScopeMemory) ; i++)
	  {
	    for (j = 0; j < nbr_of_curves ; j++)
	      {
		pShortDraw = scoGetPointerShortDraw(pScopeMemory,i,j);
		NbrPtsShort = pPOLYLINE_FEATURE(pShortDraw)->n1;
		pPOLYLINE_FEATURE(pShortDraw)->pvx[NbrPtsShort] = t;         // get time 
		pPOLYLINE_FEATURE(pShortDraw)->pvy[NbrPtsShort] = sortie[j]; // get value
		pPOLYLINE_FEATURE(pShortDraw)->n1++;
	      }
	  }
	//End of cannot
	/*Main drawing function*/
	scoDrawScopeAmplitudeTimeStyle(pScopeMemory, t);
	
	scicos_free(sortie);
	scicos_free(index_of_view);
	  }
	break;
      }
    case Ending:
      {
	scoRetrieveScopeMemory(_work, &pScopeMemory);
        if(scoGetScopeActivation(pScopeMemory) == 1) {
          if(scoGetPointerScopeWindow(pScopeMemory) != NULL) {
            sciSetUsedWindow(scoGetWindowID(pScopeMemory));
            pShortDraw = sciGetCurrentFigure();
            sciGetPointerToUserData (pShortDraw,&user_data_ptr, &size_ptr);
            FREE(*user_data_ptr);
            *user_data_ptr=NULL;
            *size_ptr = 0;
            scoDelCoupleOfSegments(pScopeMemory);
          }
        }
	scoFreeScopeMemory(_work, &pScopeMemory);
	break;  
      }
    }
}
