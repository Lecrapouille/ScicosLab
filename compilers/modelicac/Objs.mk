#######################################################################
#                                                                     #
#                           Modelicac                                 #
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

MODELICAC_SUB_DIRS=\
 -I $(SRC_DIR)\

MODELICAC_CAML_INCLUDES=\
 -I $(SRC_DIR) \

# Directory derive

SRC_BYT_OBJS=\
 $(SRC_DIR)/parseTree.cmo\
 $(SRC_DIR)/linenum.cmo\
 $(SRC_DIR)/parser.cmo\
 $(SRC_DIR)/lexer.cmo\
 $(SRC_DIR)/parse.cmo\
 $(SRC_DIR)/precompilation.cmo\
 $(SRC_DIR)/compilation.cmo\
 $(SRC_DIR)/instantiation.cmo\
 $(SRC_DIR)/graphNodeSet.cmo\
 $(SRC_DIR)/symbolicExpression.cmo\
 $(SRC_DIR)/squareSparseMatrix.cmo\
 $(SRC_DIR)/bipartiteGraph.cmo\
 $(SRC_DIR)/hungarianMethod.cmo\
 $(SRC_DIR)/causalityGraph.cmo\
 $(SRC_DIR)/optimization.cmo\
 $(SRC_DIR)/xMLCodeGeneration.cmo\
 $(SRC_DIR)/optimizingCompiler.cmo\
 $(SRC_DIR)/scicosCodeGeneration.cmo\
 $(SRC_DIR)/scicosOptimizingCompiler.cmo\

SRC_CAML_FILES=\
 $(SRC_DIR)/parseTree.mli\
 $(SRC_DIR)/precompilation.mli\
 $(SRC_DIR)/compilation.mli\
 $(SRC_DIR)/instantiation.mli\
 $(SRC_DIR)/graphNodeSet.mli\
 $(SRC_DIR)/symbolicExpression.mli\
 $(SRC_DIR)/squareSparseMatrix.mli\
 $(SRC_DIR)/bipartiteGraph.mli\
 $(SRC_DIR)/hungarianMethod.mli\
 $(SRC_DIR)/causalityGraph.mli\
 $(SRC_DIR)/optimization.mli\
 $(SRC_DIR)/xMLCodeGeneration.mli\
 $(SRC_DIR)/optimizingCompiler.mli\
 $(SRC_DIR)/scicosCodeGeneration.mli\
 $(SRC_BYT_OBJS:.cmo=.ml)\

SRC_CAML_GENERATED_FILES=\
 $(SRC_DIR)/xMLTree_print.ml\

$(SRC_DIR)/xMLTree_print.ml: $(SRC_DIR)/xMLTree.mli
	$(CAML_GEN) $(SRC_DIR)/xMLTree.mli

# Directory mdl

MODELICAC_BYT_OBJS=\
 $(SRC_BYT_OBJS)\

MODELICAC_CAML_FILES=\
 $(SRC_CAML_FILES)\

MODELICAC_CAML_GENERATED_FILES=\
 $(SRC_CAML_GENERATED_FILES)\

MODELICAC_FILES_TO_BANNERIZE=\
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
