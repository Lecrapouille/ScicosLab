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

/* evpr : environment variable path remove
 *
 * inputs  - MyEnv  : the string of the input environment variable
 *         - Path   : the path to remove in the input environment variable
 *         - Sep    : the separator of paths in the input environment variable
 *                    typically ';' for window and ":" for linux
 *
 * outputs - NewEnv : the string of the output environment variable
 *
 * return 0
 */

int evpr(char *MyEnv, char *Path, char Sep, char **NewEnv)
{
  /* decl */
  char **Paths=NULL;
  char **Paths_without_spaces=NULL;
  char **Paths_cleaned=NULL;
  char SepStr[2];
  int NewLen;
  int NPaths=1; /* default 1 */
  int NPaths_cleaned;
  int i,j,k,l;

  /* separator in a string */
  SepStr[0]=Sep;
  SepStr[1]='\0';
  
  /* 1 loop on path : get the number of paths
   * in environment variable
   */
  for(i=0;i<strlen(MyEnv);i++) {
    if (MyEnv[i]==Sep) NPaths++;
  }
  
  /* 2 allocate Paths */
  Paths = (char**) malloc(NPaths*sizeof(char *));
   
  /* 3 deconcatenate paths */
  j=0;k=0;l=0;
  for(i=0;i<strlen(MyEnv);i++) {
    if (MyEnv[i]==Sep) {
      Paths[k] = (char*) malloc((i-j)+1*sizeof(char));
      for (l=j;l<i;l++) {
	Paths[k][l-j]=MyEnv[l];
      }
      Paths[k][i-j]='\0';
      j=i+1;
      k++;
    }
  }
  Paths[k] = (char*) malloc((strlen(MyEnv)-j)+1*sizeof(char));
  for (l=j;l<strlen(MyEnv);l++) {
    Paths[k][l-j]=MyEnv[l];
  }
  Paths[k][strlen(MyEnv)-j]='\0';
  
  /* for(i=0;i<NPaths;i++) {
   * fprintf(stderr,"Path %d=%s (longueur %d)\n",i+1,Paths[i],strlen(Paths[i]));
   * }
   */
  
  /* 4 remove spaces at begin and at end of Paths */
  Paths_without_spaces = (char**) malloc(NPaths*sizeof(char *));
  for(i=0;i<NPaths;i++) {
    j=0;
    while(Paths[i][j]==' ') {
      j++;
      if (j==strlen(Paths[i])) break;
    }
    k=strlen(Paths[i]);
    if (k!=0) {
      while(Paths[i][k-1]==' ') {
        k--;
        if (k==0) break;
      }
    }
    if ((j==0) && (k==strlen(Paths[i]))) {
      Paths_without_spaces[i]=Paths[i];
    } else {
      if ((j==strlen(Paths[i])) && (k==0)) {
        Paths_without_spaces[i]=Paths[i];
      } else {
        Paths_without_spaces[i] = (char*) malloc((k-j)+1*sizeof(char));
        for(l=j;l<k;l++) {
          Paths_without_spaces[i][l-j]=Paths[i][l];
        }
        Paths_without_spaces[i][k]='\0';
      }
    }
  }
  
  /* 5 find occurences of Path in Paths_without_spaces
   * and create a cleaned list of paths without
   * the Path to prepend/append or remove
   */
  NPaths_cleaned=NPaths;
  for (i=0;i<NPaths;i++) {
    if (strcmp(Paths_without_spaces[i],Path)==0) NPaths_cleaned--;
  }
  Paths_cleaned = (char**) malloc(NPaths_cleaned*sizeof(char *));
  j=0;
  for (i=0;i<NPaths;i++) {
    if (strcmp(Paths_without_spaces[i],Path)!=0) {
      Paths_cleaned[j]=Paths[i];
      j++;
    }
  }
 
  /* 6 restore variable environment wihtout the path
   * to prepend/append or remove
   */
  NewLen=0;
  for (i=0;i<NPaths_cleaned;i++) NewLen+=strlen(Paths_cleaned[i]);
  *NewEnv = (char*) malloc((NewLen+NPaths_cleaned)*sizeof(char));
  *NewEnv[0]='\0';
  for (i=0;i<NPaths_cleaned;i++) {
    strcat(*NewEnv,Paths_cleaned[i]);
    if ((strlen(Paths_cleaned[i])!=0) && (i!=NPaths_cleaned-1)) strcat(*NewEnv,SepStr);
  }
    

  /* free allocated arrays */
  for (i=0;i<NPaths;i++) {
    free(Paths[i]);
    Paths[i]=NULL;
  }
  for (i=0;i<NPaths;i++) {
    if (Paths[i]!=NULL) free(Paths_without_spaces[i]);
  }
  free(Paths);
  free(Paths_without_spaces);
  free(Paths_cleaned);
  
  return 0;
}
