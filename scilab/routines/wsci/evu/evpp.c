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

/* evpp : environment variable path prepend
 *
 * inputs  - MyEnv  : the string of the input environment variable
 *         - Path   : the path to prepend in the input environment variable
 *         - Sep    : the separator of paths in the input environment variable
 *                    typically ';' for window and ":" for linux
 *
 * outputs - NewEnv : the string of the output environment variable
 *
 * return 0
 */

int evpp(char *MyEnv, char *Path, char Sep, char **NewEnv)
{
  char *NewEnv_evpp=NULL;
  char SepStr[2];
  
  /* separator in a string */
  SepStr[0]=Sep;
  SepStr[1]='\0';
  
  evpr(MyEnv,Path,Sep,&NewEnv_evpp);
  
  *NewEnv = (char*) malloc((strlen(NewEnv_evpp)+strlen(Path)+2)*sizeof(char));
  *NewEnv[0]='\0';

  strcat(*NewEnv,Path);
  if ((NewEnv_evpp[0]!=Sep) && (strlen(NewEnv_evpp)!=0))  {
    strcat(*NewEnv,SepStr);
  }
  strcat(*NewEnv,NewEnv_evpp);
  
  free(NewEnv_evpp);
  
  return 0;
}
