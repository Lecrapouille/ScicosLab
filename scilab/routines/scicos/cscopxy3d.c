/**
   \file cscopxy3d.c
   \author Benoit Bayol
   \version 1.0
   \date September 2006 - January 2007
   \brief CSCOPXY3D is a scope in 2D which draw its input as a XYZ scope, there is no animation, everything is keep in memory instead of CANIMXY3D
   \see CSCOPXY3D.sci in macros/scicos_blocks/Sinks/
*/

#include "scoMemoryScope.h"
#include "scoWindowScope.h"
#include "scoMisc.h"
#include "scoGetProperty.h"
#include "scoSetProperty.h"
#include "scicos_block4.h"

/** \fn cscopxy3d_draw(scicos_block * block, ScopeMemory ** pScopeMemory, int firstdraw)
    \brief Function to draw or redraw the window
*/
void cscopxy3d_draw(scicos_block * block, ScopeMemory ** pScopeMemory, int firstdraw)
{
  int * ipar; //Integer Parameters
  int color_number; //Flag on Color
  int * color   ;
  int * line_size;
  int animed;
  int win; //Windows ID : To give a name to the window
  int buffer_size; //Buffer Size
  int win_pos[2]; //Position of the Window
  int win_dim[2]; //Dimension of the Window
  int nipar;
  double * rpar; //Reals parameters
  double xmin, xmax, ymin, ymax, zmin, zmax,alpha, theta; //Ymin and Ymax are vectors here
  int number_of_subwin;
  int number_of_curves_by_subwin;
  int dimension = 3;
  int i;
  int size=0;
  char *label;
  scoGraphicalObject ShortDraw;
  scoGraphicalObject LongDraw;

  /*Retrieving Parameters*/
  ipar = GetIparPtrs(block);
  nipar = GetNipar(block);
  rpar = GetRparPtrs(block);
  win = ipar[0];
  color_number = ipar[1];
  buffer_size = ipar[2];
  label = GetLabelPtrs(block);
  color = (int*)scicos_malloc(color_number*sizeof(int));
  line_size = (int*)scicos_malloc(color_number*sizeof(int));
  for(i = 0 ; i < color_number ; i++)
    {
      color[i] = ipar[i+3];
      line_size[i] = ipar[i+3+color_number];
    }
  size = 2*color_number;
  animed = ipar[size+3];
  win_pos[0] = ipar[size+4];
  win_pos[1] = ipar[size+5];
  win_dim[0] = ipar[size+6];
  win_dim[1] = ipar[size+7];
  xmin = rpar[0];
  xmax = rpar[1];
  ymin = rpar[2];
  ymax = rpar[3];
  zmin = rpar[4];
  zmax = rpar[5];
  alpha = rpar[6];
  theta = rpar[7];

  number_of_subwin = 1;
  number_of_curves_by_subwin = ipar[size+8]; //it is a trick to recognize the type of scope, not sure it is a good way because normally a curve is the combination of a short and a longdraw

  if(firstdraw == 1)
    {
      scoInitScopeMemory(GetPtrWorkPtrs(block),pScopeMemory, number_of_subwin, &number_of_curves_by_subwin);
      scoSetShortDrawSize(*pScopeMemory,0,buffer_size);
      scoSetLongDrawSize(*pScopeMemory,0,5000);
    }

  scoInitOfWindow(*pScopeMemory, dimension, win, win_pos, win_dim, &xmin, &xmax, &ymin, &ymax, &zmin, &zmax);
  if(scoGetScopeActivation(*pScopeMemory) == 1)
    {
      pSUBWIN_FEATURE(scoGetPointerAxes(*pScopeMemory,0))->alpha = alpha;
      pSUBWIN_FEATURE(scoGetPointerAxes(*pScopeMemory,0))->theta = theta;	
      scoAddTitlesScope(*pScopeMemory,label,"x","y","z");
      
	
      for(i = 0 ; i < scoGetNumberOfCurvesBySubwin(*pScopeMemory,0) ; i++)
	{
	  scoAddPolylineForShortDraw(*pScopeMemory,0,i,color[i]);
	  scoAddPolylineForLongDraw(*pScopeMemory,0,i,color[i]);
	  
	  ShortDraw = scoGetPointerShortDraw(*pScopeMemory,0,i);
	  LongDraw = scoGetPointerLongDraw(*pScopeMemory,0,i);
	  
          /* Set ShortDraw properties */
	  sciSetLineWidth(ShortDraw, line_size[i]);
	  sciSetMarkSize(ShortDraw, line_size[i]);

          /* Set LongDraw properties */
	  sciSetLineWidth(LongDraw, line_size[i]);
	  sciSetMarkSize(LongDraw, line_size[i]);

	}
    }
  scicos_free(color);
  scicos_free(line_size);
}
/** \fn void cscopxy3d(scicos_block * block, int flag)
    \brief the computational function
    \param block A pointer to a scicos_block
    \param flag An integer which indicates the state of the block (init, update, ending)
*/
void cscopxy3d(scicos_block * block, int flag)
{
  void **_work=GetPtrWorkPtrs(block);
  /* Declarations*/
  int i;
  ScopeMemory * pScopeMemory;
  scoGraphicalObject Pinceau; //Pointer to each polyline of each axes
  double *u1,*u2, *u3;
  int NbrPtsShort;
  int **user_data_ptr,*size_ptr;


  /* State Machine Control */
  switch(flag)
    {
    case Initialization:
      {
	cscopxy3d_draw(block,&pScopeMemory, 1);
	break; //Break of the switch condition don t forget it
      } //End of Initialization

    case StateUpdate:
      {
	scoRetrieveScopeMemory(_work,&pScopeMemory);
	if (scoGetPointerScopeWindow(pScopeMemory) == NULL) return;
	if(scoGetScopeActivation(pScopeMemory) == 1)
	  {
	    /* Charging Elements */
	  

	    u1 = GetRealInPortPtrs(block,1);
	    u2 = GetRealInPortPtrs(block,2);
	    u3 = GetRealInPortPtrs(block,3);
	    
	    for(i = 0 ; i < scoGetNumberOfCurvesBySubwin(pScopeMemory,0) ; i++)
	      {
		Pinceau = scoGetPointerShortDraw(pScopeMemory,0,i);
		
		NbrPtsShort = pPOLYLINE_FEATURE(Pinceau)->n1;
		
		pPOLYLINE_FEATURE(Pinceau)->pvx[NbrPtsShort] = u1[i];
		pPOLYLINE_FEATURE(Pinceau)->pvy[NbrPtsShort] = u2[i];
		pPOLYLINE_FEATURE(Pinceau)->pvz[NbrPtsShort] = u3[i];
	    
		pPOLYLINE_FEATURE(Pinceau)->n1++;
	      }
	    
	    scoDrawScopeXYStyle(pScopeMemory);
	  }
	    break; //Break of the switch don t forget it !
	  }//End of stateupdate
      
      //This case is activated when the simulation is done or when we close scicos
    case Ending:
      {
	scoRetrieveScopeMemory(_work, &pScopeMemory);
        if(scoGetScopeActivation(pScopeMemory) == 1) {
          if(scoGetPointerScopeWindow(pScopeMemory) != NULL) {
            sciSetUsedWindow(scoGetWindowID(pScopeMemory));
            Pinceau = sciGetCurrentFigure();
            sciGetPointerToUserData (Pinceau,&user_data_ptr, &size_ptr);
            FREE(*user_data_ptr);
            *user_data_ptr=NULL;
            *size_ptr = 0;
          }
        }
	scoFreeScopeMemory(_work, &pScopeMemory);
	break; //Break of the switch
      }
      //free the memory which is allocated at each turn by some variables
    }
}
