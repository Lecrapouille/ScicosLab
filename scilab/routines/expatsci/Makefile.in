SHELL = /bin/sh

SCIDIR=../..
SCIDIR1=..\..

LIBRARY = $(SCIDIR)/libs/expatsci.a

OBJSC = intxmlparser.o intxmlparserutil.o intgendoc.o matexpatsci.o
OBJSF =

include ../../Makefile.incl

CFLAGS = $(CC_OPTIONS) $(EXPAT_INC_PATH)
FFLAGS = $(FC_OPTIONS)

include ../Make.lib

intxmlparser.o: intxmlparser.c intxmlparser.h ../mex.h ../stack-c.h
intxmlparserutil.o: intxmlparserutil.c intxmlparser.h ../mex.h ../stack-c.h
intgendoc.o: intgendoc.c ../mex.h ../stack-c.h
matexpatsci.o: matexpatsci.c matexpatsci.h ../machine.h ../stack-c.h
