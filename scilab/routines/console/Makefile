SHELL = /bin/sh

SCIDIR=../..
SCIDIR1=..\..

LIBRARY = $(SCIDIR)/libs/console.a

OBJSC =   dynamic_menus.o history.o   zzledt.o

OBJSF = 

include ../../Makefile.incl

CFLAGS = $(CC_OPTIONS) $(TK_INC_PATH) $(TCL_INC_PATH) $(XFLAGS)
FFLAGS = $(FC_OPTIONS)

include ../Make.lib

history.o: history.c history.h ../stack-c.h
zzledt.o: zzledt.c ../machine.h
dynamic_menus.o: dynamic_menus.c ../machine.h
