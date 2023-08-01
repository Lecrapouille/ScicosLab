#ifndef __GEDMANAGEMENT_H_
#define __GEDMANAGEMENT_H_

/*
 * Copyright INRIA 2006                                                                    
 * File   : GedManagement.h                                                                
 * Author : Jean-Baptiste Silvy                                                            
 * Desc   : C functions to manage ged (only destroy for now)                               
 */

#include "TCL_Global.h"

/* close the graphic editor 
 */

extern int sciDestroyGed( void ) ;

/* 
 * return true if ged is opened 
 */

extern int isGedAlive( void );

/*
 * return the ged interpreter (default interpreter for now) 
 */

extern Tcl_Interp * getGedInterpreter( void ) ;

#endif /* __GEDMANAGEMENT_H_ */
