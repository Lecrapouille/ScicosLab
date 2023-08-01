#*********************************************************************#
#                                                                     #
#                        SciCos compiler                              #
#                                                                     #
#            Pierre Weis                                              #
#                                                                     #
#                               INRIA Rocquencourt                    #
#                                                                     #
#  Copyright 2010 INRIA                                               #
#  Distributed only by permission.                                    #
#                                                                     #
#*********************************************************************#

# $Id: Makefile 5351 2013-08-26 14:01:55Z weis $

ROOT_DIR=../../../..
MAIN_DIR=..

include $(ROOT_DIR)/config/Config.mk

MATLAB=matlab
MATLAB_GENERATOR=exportall.m

GENERATED_BUILTIN_FILES=mdl_pervasives.mdli

SUB_DIRS=

default: $(COMPILE)

all: byt bin

byt bin: $(MAIN_DIR)/test_data/$(GENERATED_BUILTIN_FILES)

$(GENERATED_BUILTIN_FILES): $(MATLAB_GENERATOR)
	$(MATLAB) < $(MATLAB_GENERATOR)

$(MAIN_DIR)/test_data/$(GENERATED_BUILTIN_FILES): $(GENERATED_BUILTIN_FILES)
	$(CPC) $(GENERATED_BUILTIN_FILES) $(MAIN_DIR)/test_data

clean::
	$(RM) *~

clean_generated:
	$(RM) $(GENERATED_BUILTIN_FILES)

include $(ROOT_DIR)/config/Caml.mk
