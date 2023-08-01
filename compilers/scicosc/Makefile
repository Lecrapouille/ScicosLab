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

# $Id: Makefile 5972 2016-03-24 13:37:58Z jpc $

ROOT_DIR=.

MAIN_DIR=.
BIN_DIR=$(MAIN_DIR)/bin
LIB_DIR=$(MAIN_DIR)/lib
AUTO_DOC_DIR=$(MAIN_DIR)/autodoc/html

CONFIG_DIR=$(MAIN_DIR)/config

include $(CONFIG_DIR)/Config.mk

default: all

include $(MAIN_DIR)/Objs.mk
AUTO_DOC_OBJS=$(AUTO_DOC_DIR)/index.html

SRC_DIRS=\
 src\

CAML_FILES=$(PAKSAZI_CAML_FILES)
CAML_INCLUDES=$(PAKSAZI_CAML_INCLUDES)
CAML_GENERATED_FILES=$(PAKSAZI_CAML_GENERATED_FILES)

BYT_OBJS=$(PAKSAZI_BYT_OBJS)
BIN_OBJS=$(BYT_OBJS:.cmo=.cmx)

PAKSAZI_INCLUDES=
PAKSAZI_COMMAND=$(BIN_DIR)/paksazi

LINK_BYT_OBJS=$(BYT_OBJS)
LINK_BIN_OBJS=$(BIN_OBJS)

EXE=$(BIN_DIR)/paksazi

.PHONY: exebyt exebin info identity ignore
.PHONY: bannerize bannerize-local
.PHONY: test test-no-warnings test-nw
.PHONY: autodoc show

byt: $(CAML_FILES) exebyt $(PAKSAZI_LIBRARY_OBJS)

bin: $(CAML_FILES) $(BIN_OBJS) $(EXE).bin exebin $(PAKSAZI_LIBRARY_OBJS)

exebyt: $(EXE).byt
	@$(CPC) $(EXE).byt $(EXE)

exebin: $(EXE).bin
	@$(CPC) $(EXE).bin $(EXE)

$(EXE).byt: $(LINK_BYT_OBJS)
	@echo "Linking $(EXE).byt" && \
	$(CAML_BYT_LIBR) -o $(EXE).byt $(LINK_BYT_OBJS)

$(EXE).bin: $(LINK_BIN_OBJS)
	@echo "Linking $(EXE).bin" && \
	$(CAML_BIN_LIBR) -o $(EXE).bin $(LINK_BIN_OBJS)

distclean: clean-all
	@$(RM) $(CONFIG_DIR)/banner $(MATLAB_DIR)/banner

clean::
	@echo cleaning
	@$(RM) $(EXE) $(EXE).b* $(PAKSAZI_LIBRARY_OBJS)

info:
	@echo &&\
	echo "CAML_FILES are" &&\
	echo $(CAML_FILES) &&\
	echo &&\
	echo "BYT_OBJS are" &&\
	echo $(BYT_OBJS) &&\
	echo &&\
	echo "CAML_INCLUDES are" &&\
	echo $(CAML_INCLUDES) &&\
	echo "CAML_BYT_INCLUDES are" &&\
	echo $(CAML_BYT_INCLUDES) &&\
	echo "CAML_COMP_FLAGS are" &&\
	echo $(CAML_COMP_FLAGS) &&\
	echo "CAML_BYT_FLAGS are" &&\
	echo $(CAML_BYT_FLAGS) &&\
	echo "CAML_BIN_FLAGS are" &&\
	echo $(CAML_BIN_FLAGS) &&\
	echo "CAML_BYT is" &&\
	echo $(CAML_BYT) &&\
	echo "CAML_BIN is" &&\
	echo $(CAML_BIN) &&\
	echo &&\
	echo "CAML_GENERATED_FILES are" &&\
	echo $(CAML_GENERATED_FILES) &&\
	echo &&\
	echo "PAKSAZI command is" &&\
	echo $(PAKSAZI) &&\
	echo "PAKSAZI_LIBRARY_OBJS are" &&\
	echo $(PAKSAZI_LIBRARY_OBJS) &&\
	echo

autodoc: $(AUTO_DOC_OBJS)

$(AUTO_DOC_OBJS): $(CAML_FILES) $(PAKSAZI_LIBRARY_OBJS)
	HTMLDIR=$(AUTO_DOC_DIR) $(MAIN_DIR)/scripts/generate_htmldoc.sh

showdoc: $(AUTO_DOC_OBJS)
	$(BROWSER) $(AUTO_DOC_OBJS) &

identity:
	FILES=`find $(SRC_DIRS) -type f -a -exec grep -l '$$Id:' {} \; | grep -v .svn` &&\
	for file in $$FILES; do\
	  svn propset svn:keywords "Id" $$file;\
	  IER=$$? &&\
	  case $$IER in\
	    0) ;;\
	    *) echo "Cannot make $@ for file $$file" &&\
	       exit $$IER;;\
	  esac;\
	done

ignore:
	DIRS=`find . -type d | grep -v .svn` &&\
	for dir in $$DIRS; do\
	  echo $$dir &&\
	  if test -d $$dir/.svn; then\
	    if test -r $$dir/.cvsignore; then\
	      (cd $$dir &&\
	       svn propset svn:ignore -F ./.cvsignore .);\
	    fi;\
	  fi;\
	  IER=$$? &&\
	  case $$IER in\
	    0) ;;\
	    *) echo "Cannot make $@ in directory $$dir" &&\
	       exit $$IER;;\
	  esac;\
	done

LOCAL_FILES_TO_BANNERIZE=Makefile configure Objs.mk $(PAKSAZI_FILES_TO_BANNERIZE)

bannerize-local: $(LOCAL_FILES_TO_BANNERIZE)
	(\cd $(CONFIG_DIR) && $(MAKE) bannerize) &&\
	for file in $(LOCAL_FILES_TO_BANNERIZE); do\
	  if test -w $$file; then\
	    $(BH) -bf $(CONFIG_DIR)/banner -bft caml $$file;\
	  else echo "Warning: $$file is not writable.";\
	  fi;\
	  IER=$$? &&\
	  case $$IER in\
	   0) ;;\
	   *) exit $$IER;;\
	  esac;\
	done

bannerize: bannerize-local

include $(MAIN_DIR)/config/Caml.mk


