/* This file is part of evu.
 * evu is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <windows.h>
#include "evu.h"

#define LMAX 16383

extern char *optarg;
extern int optind;
extern int opterr;

static char MyVer[]="evu version 1";

static char HKLM[]="SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment";
static char HKCU[]="Environment";

static void usage(void)
{
  fprintf(stderr,"wevu : Windows Environment Variable Update.\n\n");
  fputs("Usage : wevu [-[hv]] [-[[par] ]<string>] <HKLM|HKCU> <envvarname>\n",stderr);
  fputs("\t-h \t\tDisplay this message.\n",stderr);
  fputs("\t-v \t\tDisplay the version.\n",stderr);
  fputs("\t-p <string>\tPrepend <string> in the environment variable.\n",stderr);
  fputs("\t-a <string>\tAppend <string> in the environment variable.\n",stderr);
  fputs("\t-r <string>\tRemove <string> in the environment variable.\n",stderr);
  fputs("\tHKLM \t\tLook in the HKEY_LOCAL_MACHINE registery directory.\n",stderr);
  fputs("\tHKCU \t\tLook in the HKEY_CURRENT_USER registery directory.\n",stderr);
  fputs("\t<envvarname>\tThe environment variable to be updated.\n",stderr);
  fputs("\nExamples :\n",stderr);
  fputs(" - Prepend 'C:\\Program Files\\scicoslab\\bin' in PATH :\n",stderr);
  fputs("\twevu -p \"C:\\Program Files\\scicoslab\\bin\" HKLM PATH\n\n",stderr);
  fputs(" - Append 'F:\\Mingw\\bin' in PATH :\n",stderr);
  fputs("\twevu -a \"F:\\Mingw\\bin\" HKLM PATH\n\n",stderr);
  fputs(" - Remove 'C:\\Program Files\\MKVtoolnix' in PATH :\n",stderr);
  fputs("\twevu -r \"C:\\Program Files\\MKVtoolnix\" HKLM PATH\n",stderr);
}

/* wevu : Windows Environment Variable Update. */

int main(int argc, char **argv)
{
  int optch;
  static char optstring[] = "hvp:a:r:";
  int append=0;
  int prepend=0;
  int remove=0;
  
  char *Path=NULL;
  char *Hkey;
  char *EnvVarName;
  char *NewEnv=NULL;
  
  char VALUE[LMAX];
  HKEY key;
  DWORD Length=LMAX;
  DWORD result;

  while ( (optch = getopt(argc,argv,optstring)) != -1 )
    switch (optch) {
      case 'h' :
	usage();
	return 0;
      case 'v' :
	fprintf(stderr,"This is wevu from %s.\n",MyVer);
	return 0;
      case 'p' :
	if (append || remove) {
	  fprintf(stderr,"Only one switch -p -a or -r must be used.");
	  fputs("Use -h for help.",stderr);
	  return 1;
	} else {
	  prepend=1;
          Path=optarg;
	}
	break;
      case 'a' :
	if (prepend || remove) {
	  fprintf(stderr,"Only one switch -p -a or -r must be used.\n");
	  fputs("Use -h for help.\n",stderr);
	  return 1;
	} else {
	  append=1;
          Path=optarg;
	}
	break;
      case 'r' :
	if (append || prepend) {
	  fprintf(stderr,"Only one switch -p -a or -r must be used.\n");
	  fputs("Use -h for help.\n",stderr);
	  return 1;
	} else {
	  remove=1;
          Path=optarg;
	}
	break;
      default :
	fprintf(stderr,"Use -h for help.\n");
	return 1;
    }
  
  if (argc-optind < 1) {
    fprintf(stderr,"Missing hkey parameter.\n");
    fputs("Use -h for help.\n",stderr);
    return 1;
  } else {
    Hkey=argv[optind];
    if ((strcmp(Hkey,"HKLM")!=0) && (strcmp(Hkey,"HKCU")!=0)) {
      fprintf(stderr,"Bad hkey parameter : %s.\n",Hkey);
      fputs("Must be HKLM or HKCU.\n",stderr);
      fputs("Use -h for help.\n",stderr);
      return 1;
    }
  }

  if (argc-optind < 2) {
    fprintf(stderr,"Missing environment variable name parameter.\n");
    fputs("Use -h for help.\n",stderr);
    return 1;
  } else {
    EnvVarName=argv[optind+1];
  }

  if (strcmp(Hkey,"HKLM")==0) {
    RegOpenKeyEx(HKEY_LOCAL_MACHINE, HKLM, 0, KEY_QUERY_VALUE , &key);
  } else {
    RegOpenKeyEx(HKEY_CURRENT_USER, HKCU, 0, KEY_QUERY_VALUE , &key);
  }

  if (RegQueryValueEx(key, EnvVarName, 0, NULL, (LPBYTE)VALUE, &Length) !=  ERROR_SUCCESS ) {
    fprintf(stderr,"The environment variable %s doesn't exist.\n",EnvVarName);
    RegCloseKey(key);
    return 1;
  } else {
    if (prepend) {
      evpp(VALUE,Path,';',&NewEnv);
    } else if (append) {
      evpa(VALUE,Path,';',&NewEnv);
    } else if (remove) {
      evpr(VALUE,Path,';',&NewEnv);
    } else {
      NewEnv=VALUE;
    }
    if (prepend || append || remove) {
      if (strcmp(Hkey,"HKLM")==0) {
        RegCreateKeyEx(HKEY_LOCAL_MACHINE, HKLM, 0, NULL, REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, NULL, &key, &result);
      }	else {
        RegCreateKeyEx(HKEY_CURRENT_USER, HKCU, 0, NULL, REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, NULL, &key, &result);
      }
      if ( RegSetValueEx(key, EnvVarName, 0, REG_EXPAND_SZ, (LPBYTE)NewEnv, strlen(NewEnv)+1)!=  ERROR_SUCCESS ) {
        fprintf(stderr,"Unable to write in the registery.\n");
        RegCloseKey(key);
        return 1;
      }
      RegCloseKey(key);
      SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, 0, (LPARAM) "Environment", SMTO_ABORTIFHUNG, 5000, NULL);
    }
    fprintf(stderr,"%s=%s\n",EnvVarName,NewEnv);
  }

  return 0;
}
