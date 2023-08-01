#######################################################################
#                                                                     #
#                           ScicosLab                                 #
#                                                                     #
#          Pierre Weis, INRIA Rocquencourt                            #
#                                                                     #
#  Copyright 2010-2011,                                               #
#  Institut National de Recherche en Informatique et en Automatique.  #
#  All rights reserved.                                               #
#                                                                     #
#  This file is distributed under the terms of the BSD License.       #
#                                                                     #
#######################################################################

# $Id: Makefile 4588 2011-10-21 09:34:15Z weis $

ROOT_DIR=.

include $(ROOT_DIR)/config/Config.mk

SUB_DIRS=compilers scilab

.PHONY: default all byt bin install clean distclean

default: $(COMPILE)

all byt bin clean distclean:
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
	@for d in $(SUB_DIRS); do\
	   (cd $$d &&\
	    PREFIX=\"${PREFIX_INSTALL_DIR}\" $(MAKE) $@);\
	   IER=$$? &&\
	   case $$IER in\
	    0) ;;\
	    *) echo "Cannot make $@ in sub directory $$d";\
	      exit $$IER;;\
	   esac;\
	done

distclean: clean
