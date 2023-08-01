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

# $Id: Makefile 4935 2011-09-20 17:47:05Z weis $

ROOT_DIR=..

include $(ROOT_DIR)/config/Config.mk

LOCAL_FILES_TO_BANNERIZE= Caml.mk Config.mk.in Doc.mk Makefile Params.mk configure

.PHONY: default
.PHONY: bannerize bannerize_local

default:
	echo "****************************************************";
	echo "** This Makefile is for ScicosLab developers only **";
	echo "** If you are not a ScicosLab developers,         **";
	echo "** please refrain from using this file!           **";
	echo "****************************************************";

bannerize_local:
	for file in $(LOCAL_FILES_TO_BANNERIZE); do\
	  $(BH) -bf banner -bft make $$file;\
	  IER=$$? &&\
	  case $$IER in\
	   0) ;;\
	   *) exit $$IER;;\
	  esac;\
	done

bannerize: bannerize_local

