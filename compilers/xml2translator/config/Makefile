#######################################################################
#                                                                     #
#                           Simport                                   #
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

# $Id: Makefile 5919 2013-09-13 14:24:48Z weis $

MAIN_DIR=..

include $(MAIN_DIR)/config/Config.mk

LOCAL_FILES_TO_BANNERIZE=\
 Commands.mk Caml.mk Simport.mk\
 Config.mk.in Doc.mk Params.mk\
 configure Makefile

.PHONY: default
.PHONY: bannerize bannerize_local

default:
	echo "****************************************************";
	echo "** This Makefile is for ScicosLab developers only **";
	echo "** If you are not a ScicosLab developers,         **";
	echo "** please refrain from using this file!           **";
	echo "****************************************************";

bannerize_local: banner
	for file in $(LOCAL_FILES_TO_BANNERIZE); do\
	  $(BH) -bf banner -bft make $$file;\
	  IER=$$? &&\
	  case $$IER in\
	   0) ;;\
	   *) exit $$IER;;\
	  esac;\
	done

bannerize: bannerize_local

banner: banner.in
	$(HTMLC) -f $< -o $@
