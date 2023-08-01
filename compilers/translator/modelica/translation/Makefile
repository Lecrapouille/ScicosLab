######################################################################
#                                                                    #
#                           ScicosLab                                #
#                                                                    #
#          Pierre Weis, INRIA Rocquencourt                           #
#                                                                    #
#  Copyright 2010-2011,                                              #
#  Institut National de Recherche en Informatique et en Automatique. #
#  All rights reserved.                                              #
#                                                                    #
#  This file is distributed under the terms of the Q Public License. #
#                                                                    #
######################################################################

# $Id: Makefile 4800 2012-12-03 00:32:35Z weis $

ROOT_DIR=../../../..

include $(ROOT_DIR)/config/Config.mk

CAML_COMP_FLAGS=-w A -warn-error Ae
CAML_INCLUDES=-I ../parsing -I ../compilation -I ../instantiation -I ../exceptionHandling
CAML_BYT_LIBS=../parsing/parsing.cma ../compilation/compilation.cma ../instantiation/instantiation.cma ../exceptionHandling/exceptionHandling.cma unix.cma

ML_FILES=codeGeneration.ml libraryManager.ml versiondate.ml translator.ml
MLI_FILES=codeGeneration.mli libraryManager.mli versiondate.mli

EXE=translator

BYT_EXE=$(EXE)_byt$(EXE_EXT)
BIN_EXE=$(EXE)_bin$(EXE_EXT)

all: $(COMPILE)

byt: $(CMOS) $(BYT_EXE)

bin: $(CMXS) $(BIN_EXE)

$(BYT_EXE):
	$(CAML_BYT) -o $(BYT_EXE) $(CAML_BYT_LIBS) $(CMOS)

$(BIN_EXE):
	$(CAML_BIN) -o $(BIN_EXE) $(CAML_BIN_LIBS)  $(CMXS)

version_date.ml: versiondate.ml.tmpl
	$(CPP) versiondate.ml.tmpl versiondate.ml

clean::
	$(RM) $(BYT_EXE) $(BIN_EXE)

include $(ROOT_DIR)/config/Caml.mk

#opt: $(OBJSOPT)
#	$(OCAMLOPT) -verbose $(OCAMLOPTFLAGS) -o $(EXE) $(LFLAGS) $(LIBSOPT) $(OBJSOPT)  translator.ml
#	mkdir -p $(INSTDIR)
#	cp -p  $(EXE) $(INSTDIR)

#bytecode: $(OBJS)
#	$(OCAMLC) $(OCAMLFLAGS) -o $(EXE) $(LFLAGS) $(LIBS) $(OBJS) translator.ml

#custom: $(OBJS)
#	$(OCAMLC) -verbose -custom $(OCAMLFLAGS) -o $(EXE) $(LFLAGS) $(LIBS) $(OBJS) translator.ml
#	mkdir -p $(INSTDIR)
#	cp -p  $(EXE) $(INSTDIR)

#versiontarget :
#ifeq ("$(strip $(SVNLASTCHANGEDATESTR))", "")
#ifeq ("$(strip $(wildcard versiondate.ml))", "")
#	@echo "***********************************************"
#	@echo "*** Could not expand the SVN version date *****"
#	@echo "*** using the template file as it is      *****"
#	@echo "*** The build date will not be correct    *****"
#	@echo "***********************************************"
#	cp -p versiondate.ml.tmpl versiondate.ml
#else
#	@echo "***********************************************"
#	@echo "*** Reusing existing versiondate.ml      ******"
#	@echo "***********************************************"
#endif
#else
#	sed -e '/let/s/AUTO_UPDATE_DATE/$(SVNLASTCHANGEDATESTR)/' -e '/let/s/AUTO_UPDATE_REV/$(SVNLASTCHANGEREVSTR)/' < versiondate.ml.tmpl > versiondate.ml
#endif

#version:
#	$(MAKE) versiontarget

#versiondate.ml:# $(filter-out versiondate.ml, $(SRCS))
#	$(MAKE) versiontarget
