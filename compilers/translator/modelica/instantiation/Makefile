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
CAML_INCLUDES=-I ../parsing -I ../compilation

ML_FILES=instantiation.ml
MLI_FILES=instantiation.mli

BYT_LIB=instantiation.cma
BIN_LIB=$(BYT_LIB:.cma=.cmxa)

all: $(COMPILE)

byt: $(CMOS) $(BYT_LIB)

bin: $(CMXS) $(BIN_LIB)

$(BYT_LIB):
	$(CAML_BYT) -a -o $(BYT_LIB) $(CMOS)

$(BIN_LIB):
	$(CAML_BIN) -a -o $(BIN_LIB) $(CMXS)

include $(ROOT_DIR)/config/Caml.mk
