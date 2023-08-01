#######################################################################
#                                                                     #
#                           Paksazi                                   #
#                                                                     #
#          Pierre Weis, INRIA Rocquencourt                            #
#                                                                     #
#  Copyright 2010-2013,                                               #
#  Institut National de Recherche en Informatique et en Automatique.  #
#  All rights reserved.                                               #
#                                                                     #
#  This file is distributed under the terms of the BSD License.       #
#                                                                     #
#######################################################################

# $Id: Objs.mk 6149 2013-10-09 17:35:08Z weis $

# The list of all the Caml compiled objects to make in this project.
# Each source directory has its specific make variable associated
# with the relevant list of object files.
#
# This file is shared and supposed to be included by
# each make file that needs to link and build a Caml executable.
# See below for a template of make file.

SRC_DIR=$(MAIN_DIR)/src

PAKSAZI_SUB_DIRS=\
 -I $(SRC_DIR)\

PAKSAZI_CAML_INCLUDES=\
 -I $(SRC_DIR) \

# Directory derive

SRC_BYT_OBJS=\
 $(SRC_DIR)/paksazi.cmo\

SRC_CAML_FILES=\
 $(SRC_BYT_OBJS:.cmo=.ml)\

SRC_CAML_GENERATED_FILES=\

# Directory mdl

PAKSAZI_BYT_OBJS=\
 $(SRC_BYT_OBJS)\

PAKSAZI_CAML_FILES=\
 $(SRC_CAML_FILES)\

PAKSAZI_CAML_GENERATED_FILES=\
 $(SRC_CAML_GENERATED_FILES)\

PAKSAZI_FILES_TO_BANNERIZE=\
 $(SRC_CAML_FILES)\

############################################################
#
# The following is just a template to inspire new make files
# using the above technology ...
#
# To get the working template remove the string "## " at each
# beginning of line.
############################################################

## # $Id: Objs.mk 6149 2013-10-09 17:35:08Z weis $
## 
## MAIN_DIR=..
## 
## include $(MAIN_DIR)/config/Config.mk
## include $(MAIN_DIR)/Objs.mk
## 
## #CAMLBYTCONFIG=-annot -w A -warn-error Ae -g $(CAMLBYTINCLUDES)
## #CAMLBINCONFIG=-w A -warn-error Ae $(CAMLBININCLUDES)\
## # -unsafe -noassert -inline 10000
## 
## CAML_SOURCES=\
##  mdl_compile.mli mdl_compile.ml
## 
## CAML_FILES=$(CAML_SOURCES)
## 
## CAML_FILES=$(CAMLFILES:.ml=.cmo)
## BIN_OBJS=$(BYT_OBJS:.cmo=.cmx)
## 
## OTHER_BYT_OBJS=\
##  $(BASICS_BYT_OBJS) $(CONF_BYT_OBJS)\
##  $(LEX_BYT_OBJS) $(PARSE_BYT_OBJS)\
##  $(DAST_BYT_OBJS) $(INHERITANCE_BYT_OBJS)\
##  $(SPLIT_BYT_OBJS) $(TRANSLATION_BYT_OBJS)\
##  $(GENR_BLOCK_BYT_OBJS)\
##  $(COMPILER_BYT_OBJS) $(DRIVER_BYT_OBJS)
## 
## OTHER_BIN_OBJS=$(OTHER_BYT_OBJS:.cmo=.cmx)
## 
## LINK_BYT_OBJS=$(OTHER_BYT_OBJS) $(BYT_OBJS)
## LINK_BIN_OBJS=$(LINK_BYT_OBJS:.cmo=.cmx)
## 
## EXE=mdl_compile
## 
## SUB_DIRS=test
## 
## default: $(EXE)
## 
## all: byt bin default
## 
## byt: $(EXE).byt
## 
## $(EXE).byt: $(BYT_OBJS)
## 	$(CAMLC_BYT) -o $(EXE).byt $(LINK_BYT_OBJS)
## 
## bin: $(EXE).bin
## 
## $(EXE).bin: $(BIN_OBJS)
## 	$(CAMLC_BIN) -o $(EXE).bin $(LINK_BIN_OBJS)
## 
## $(EXE): $(EXE).bin
## 	$(CPC) $(EXE).bin $(EXE)
## 
## test:: $(MDL_FILES)
## 	@for i in `cat $(MDL_FILES)`; do \
## 	  echo "--> Test explicit \`\`$$i''" && \
## 	  ./$(EXE) -I $(TEST_DATA_DIR) $(TEST_DATA_DIR)/$$i > $$i.output; \
## 	  IER=$$? && \
## 	  if test $$IER -ne 0; then exit $$IER; fi && \
## 	  echo "<-- Test explicit \`\`$$i'' passed"; \
## 	done
## 
## clean::
## 	$(RM) $(EXE) $(EXE).b* *.output
## 	$(RM) explicit/*.output
## 
## include $(MAIN_DIR)/config/Caml.mk
