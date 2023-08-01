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

# $Id: Makefile 5976 2016-03-24 14:37:41Z jpc $

ROOT_DIR=..
# where to copy EXECUTABLES 
# COMPILERS_SRC_INSTALL_DIR
include ./config/Config.mk

# suffix of ocaml executables to copy 
COMPILE=bin
# command for copying
CPC=cp -f
# extension to copy when copying in $SRC_INSTALL_DIR
EXE_EXT=.exe

SUB_DIRS=xml2translator translator/modelica scicosc modelicac

EXECUTABLES=\
 xml2translator/bin/XML2Modelica\
 translator/modelica/bin/translator\
 scicosc/bin/paksazi\
 modelicac/bin/modelicac

IN_PROGRESS=translator/mdl/driver/simport\

.PHONY: all byt bin install clean distclean

.PHONY: all byt bin install install_src clean distclean

default: all

all: byt bin install_src 

byt bin:
	@for d in $(SUB_DIRS); do\
	   (cd $$d && $(MAKE) $@);\
	   IER=$$? &&\
	   case $$IER in\
	    0) ;;\
	    *) echo "Cannot make $@ in sub directory $$d";\
	       exit $$IER;;\
	   esac;\
	done

install:
	@if ! test -d $(PREFIX_INSTALL_DIR); then\
	 (mkdir $(PREFIX_INSTALL_DIR); \
	  mkdir $(PREFIX_INSTALL_DIR)/bin);\
	fi;
	@for file in $(EXECUTABLES); do\
	  command=$$(basename $$file) &&\
	  $(CPC) $${file}.$(COMPILE) $(PREFIX_INSTALL_DIR)/bin/$${command}$(EXE_EXT);\
	   IER=$$? &&\
	   case $$IER in\
	    0) ;;\
	    *) echo "Cannot make $@ in sub directory $$d";\
	       exit $$IER;;\
	   esac;\
	done

# propagate executables in th ebin directory of nsp or scicoslab

install_src:
	@for file in $(EXECUTABLES); do\
	  command=$$(basename $$file) &&\
	  $(CPC) $${file}.$(COMPILE) $(COMPILERS_SRC_INSTALL_DIR)/bin/$${command}$(EXE_EXT);\
	   IER=$$? &&\
	   case $$IER in\
	    0) ;;\
	    *) echo "Cannot make $@";\
	       exit $$IER;;\
	   esac;\
	done

clean_src:
	@for file in $(EXECUTABLES); do\
	  command=$$(basename $$file) &&\
	  $(RM) $(COMPILERS_SRC_INSTALL_DIR)/bin/$${command}$(EXE_EXT);\
	   IER=$$? &&\
	   case $$IER in\
	    0) ;;\
	    *) echo "Cannot make $@";\
	       exit $$IER;;\
	   esac;\
	done

clean: 
	@for d in $(SUB_DIRS); do\
	  (cd $$d && $(MAKE) clean);\
	  IER=$$? &&\
	  case $$IER in\
	   0) ;;\
	   *) echo "Cannot make $@ in sub directory $$d";\
	      exit $$IER;;\
	  esac;\
	done 

distclean clean-all: clean clean_src
	@for d in $(SUB_DIRS); do\
	  (cd $$d && $(MAKE) clean-all);\
	  IER=$$? &&\
	  case $$IER in\
	   0) ;;\
	   *) echo "Cannot make $@ in sub directory $$d";\
	      exit $$IER;;\
	  esac;\
	done

identity:
	FILES=`find . -type f -a -exec grep -l '$$Id:' {} \; | grep -v .svn` &&\
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
