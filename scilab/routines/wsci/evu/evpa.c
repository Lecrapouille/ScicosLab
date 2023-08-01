/* This file is part of evu.
 * evu is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "evu.h"

/* evpa : environment variable path append
 *
 * inputs  - MyEnv  : the string of the input environment variable
 *         - Path   : the path to append in the input environment variable
 *         - Sep    : the separator of paths in the input environment variable
 *                    typically ';' for window and ":" for linux
 *
 * outputs - NewEnv : the string of the output environment variable
 *
 * return 0
 */

int evpa(char *MyEnv, char *Path, char Sep, char **NewEnv)
{
  char *NewEnv_evpa=NULL;
  char SepStr[2];
  
  /* separator in a string */
  SepStr[0]=Sep;
  SepStr[1]='\0';
  
  evpr(MyEnv,Path,Sep,&NewEnv_evpa);
  
  *NewEnv = (char*) malloc((strlen(NewEnv_evpa)+strlen(Path)+2)*sizeof(char));
  *NewEnv[0]='\0';

  strcat(*NewEnv,NewEnv_evpa);
  if ((NewEnv_evpa[strlen(NewEnv_evpa)-1]!=Sep) && strlen(NewEnv_evpa)!=0) {
    strcat(*NewEnv,SepStr);
  }
  strcat(*NewEnv,Path);
  
  free(NewEnv_evpa);
  
  return 0;
}
