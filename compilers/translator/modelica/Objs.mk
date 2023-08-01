#######################################################################
#                                                                     #
#                           Translator                                 #
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

COMPILATION_DIR=$(MAIN_DIR)/compilation
EXCEPTIONHANDLING_DIR=$(MAIN_DIR)/exceptionHandling
INSTANTIATION_DIR=$(MAIN_DIR)/instantiation
PARSING_DIR=$(MAIN_DIR)/parsing
TRANSLATION_DIR=$(MAIN_DIR)/translation

TRANSLATOR_SUB_DIRS=\
 -I $(PARSING_DIR)\
 -I $(COMPILATION_DIR)\
 -I $(INSTANTIATION_DIR)\
 -I $(EXCEPTIONHANDLING_DIR)\
 -I $(TRANSLATION_DIR)\

TRANSLATOR_CAML_INCLUDES=\
 -I $(PARSING_DIR)\
 -I $(COMPILATION_DIR)\
 -I $(INSTANTIATION_DIR)\
 -I $(EXCEPTIONHANDLING_DIR)\
 -I $(TRANSLATION_DIR)\

# Directory parsing 

PARSING_BYT_OBJS=\
 $(PARSING_DIR)/syntax.cmo\
 $(PARSING_DIR)/linenum.cmo\
 $(PARSING_DIR)/location.cmo\
 $(PARSING_DIR)/config.cmo\
 $(PARSING_DIR)/parse_error.cmo\
 $(PARSING_DIR)/parser.cmo\
 $(PARSING_DIR)/lexer.cmo\
 $(PARSING_DIR)/parse.cmo\

PARSING_CAML_FILES=\
 $(PARSING_DIR)/parser.mli\
 $(PARSING_DIR)/syntax.mli\
 $(PARSING_BYT_OBJS:.cmo=.ml)\

PARSING_CAML_GENERATED_FILES=\

# Directory compilation
ML_FILES=types.ml nameResolve.ml
MLI_FILES=types.mli nameResolve.mli

COMPILATION_BYT_OBJS=\
 $(COMPILATION_DIR)/types.cmo\
 $(COMPILATION_DIR)/nameResolve.cmo\

COMPILATION_CAML_FILES=\
 $(COMPILATION_DIR)/types.mli\
 $(COMPILATION_DIR)/nameResolve.mli\
 $(COMPILATION_BYT_OBJS:.cmo=.ml)\

COMPILATION_CAML_GENERATED_FILES=\

# Directory exceptionHandling

EXCEPTIONHANDLING_BYT_OBJS=\
 $(EXCEPTIONHANDLING_DIR)/errorDico.cmo\
 $(EXCEPTIONHANDLING_DIR)/msgDico.cmo\
 $(EXCEPTIONHANDLING_DIR)/exceptHandler.cmo\

EXCEPTIONHANDLING_CAML_FILES=\
 $(EXCEPTIONHANDLING_DIR)/errorDico.mli\
 $(EXCEPTIONHANDLING_DIR)/msgDico.mli\
 $(EXCEPTIONHANDLING_DIR)/exceptHandler.mli\
 $(EXCEPTIONHANDLING_BYT_OBJS:.cmo=.ml)\

EXCEPTIONHANDLING_CAML_GENERATED_FILES=\

# Directory instantiation

INSTANTIATION_BYT_OBJS=\
 $(INSTANTIATION_DIR)/instantiation.cmo\

INSTANTIATION_CAML_FILES=\
 $(INSTANTIATION_DIR)/instantiation.mli\
 $(INSTANTIATION_BYT_OBJS:.cmo=.ml)\

INSTANTIATION_CAML_GENERATED_FILES=\

# Directory translation

TRANSLATION_BYT_OBJS=\
 $(TRANSLATION_DIR)/codeGeneration.cmo\
 $(TRANSLATION_DIR)/libraryManager.cmo\
 $(TRANSLATION_DIR)/versiondate.cmo\
 $(TRANSLATION_DIR)/translator.cmo\

TRANSLATION_CAML_FILES=\
 $(TRANSLATION_DIR)/codeGeneration.mli\
 $(TRANSLATION_DIR)/libraryManager.mli\
 $(TRANSLATION_DIR)/versiondate.mli\
 $(TRANSLATION_BYT_OBJS:.cmo=.ml)\

TRANSLATION_CAML_GENERATED_FILES=\

# Main program 

TRANSLATOR_BYT_OBJS=\
 $(PARSING_BYT_OBJS)\
 $(COMPILATION_BYT_OBJS)\
 $(INSTANTIATION_BYT_OBJS)\
 $(EXCEPTIONHANDLING_BYT_OBJS)\
 $(TRANSLATION_BYT_OBJS)\

TRANSLATOR_CAML_FILES=\
 $(PARSING_CAML_FILES)\
 $(COMPILATION_CAML_FILES)\
 $(INSTANTIATION_CAML_FILES)\
 $(EXCEPTIONHANDLING_CAML_FILES)\
 $(TRANSLATION_CAML_FILES)\

TRANSLATOR_CAML_GENERATED_FILES=\
 $(PARSING_CAML_GENERATED_FILES)\
 $(COMPILATION_CAML_GENERATED_FILES)\
 $(INSTANTIATION_CAML_GENERATED_FILES)\
 $(EXCEPTIONHANDLING_CAML_GENERATED_FILES)\
 $(TRANSLATION_CAML_GENERATED_FILES)\

TRANSLATOR_FILES_TO_BANNERIZE=\
 $(PARSING_CAML_FILES)\
 $(COMPILATION_CAML_FILES)\
 $(INSTANTIATION_CAML_FILES)\
 $(EXCEPTIONHANDLING_CAML_FILES)\
 $(TRANSLATION_CAML_FILES)\

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
