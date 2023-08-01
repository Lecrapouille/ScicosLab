/* Copyright INRIA */
#include <string.h>
#include "../machine.h"
#include "cerro.h"

extern void C2F(erro)(const char *,int l);

#define STRLEN 4096

void cerro(const char *str)
{
  int l = strlen(str) + 1;
  C2F(erro)(str,l);
}

