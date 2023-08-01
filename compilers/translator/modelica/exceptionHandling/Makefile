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

# $Id: Makefile 4481 2011-09-16 16:01:33Z weis $

ROOT_DIR=../../../..

include $(ROOT_DIR)/config/Config.mk

CAML_FLAGS=-w A -warn-error Ae
CAML_INCLUDES=-I ../parsing -I ../compilation -I ../instantiation

ML_FILES=errorDico.ml msgDico.ml exceptHandler.ml
MLI_FILES=errorDico.mli msgDico.mli exceptHandler.mli

BYT_LIB=exceptionHandling.cma
BIN_LIB=$(BYT_LIB:.cma=.cmxa)

all: $(COMPILE)

byt: $(CMOS) $(BYT_LIB)

$(BYT_LIB):
	$(CAML_BYT) -a -o $(BYT_LIB) $(CMOS)

bin: $(CMXS) $(BIN_LIB)

$(BIN_LIB):
	$(CAML_BIN) -a -o $(BIN_LIB) $(CMXS)

include $(ROOT_DIR)/config/Caml.mk
