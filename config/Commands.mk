######################################################################
#                                                                    #
#                           Moca                                     #
#                                                                    #
#          Pierre Weis, INRIA Rocquencourt                           #
#          Frédéric Blanqui, projet Protheo, INRIA Lorraine          #
#                                                                    #
#  Copyright 2005-2008,                                              #
#  Institut National de Recherche en Informatique et en Automatique. #
#  All rights reserved.                                              #
#                                                                    #
#  This file is distributed under the terms of the Q Public License. #
#                                                                    #
######################################################################

# $Id: Commands.mk 4537 2011-09-25 12:46:14Z weis $

# This Makefile is a generic configuration Makefile for Caml applications.
# This Makefile is independent of the software to be built and
# defines basic Unix commands and tools for Caml compilation.

# This Makefile should be included at the beginning of the Makefile that handles
# a set of Caml files (to build a library or an application).
# Simply write at the beginning of your Makefile:
# include path_to_Config.mk/Config.mk

ML_FILES=
MLI_FILES=

CAML_FILES=\
 $(MLI_FILES)\
 $(ML_FILES)

CMIS=$(MLI_FILES:.mli=.cmi)
CMOS=$(ML_FILES:.ml=.cmo)
CMXS=$(CMOS:.cmo=.cmx)

# Basic auxiliary commands
CP_CONFIG=-pRf
CP=cp $(CP_CONFIG)
CPC=cp -f
CVS=cvs
SVN=svn
RM=rm -rf
MV=mv -f
TOUCH=touch
CHMOD=chmod
CHMOD_R=$(CHMOD) -R ug+w
SHELL=/bin/sh
MKDIR=mkdir -p
RMDIR=rm -rf
LN=ln -sf
CHGRP=chgrp -fR
TARC=tar -cvzf

# The Caml compilers default configurations.
CAML_INCLUDES=
CAML_BYT_INCLUDES=$(CAML_INCLUDES)
CAML_BIN_INCLUDES=$(CAML_INCLUDES)

CAML_COMP_FLAGS=-strict-sequence -warn-error A
CAML_BYT_FLAGS=$(CAML_COMP_FLAGS) -w A -annot -g
CAML_BIN_FLAGS=$(CAML_COMP_FLAGS) -w Ae -unsafe -noassert -inline 10000

CAML_BYT_CONFIG=$(CAML_BYT_FLAGS) $(CAML_BYT_INCLUDES)
CAML_BIN_CONFIG=$(CAML_BIN_FLAGS) $(CAML_BIN_INCLUDES)

CAML_BYT_LIBS=
CAML_BIN_LIBS=$(CAML_BYT_LIBS:.cma=.cmxa)
CAML_BYT_LIBR_CONFIG=$(CAML_BYT_INCLUDES) -a $(CAML_BYT_LIBS)
CAML_BIN_LIBR_CONFIG=-verbose $(CAML_BIN_INCLUDES) -a $(CAML_BIN_LIBS)

CAML_YAC_CONFIG=-v
CAML_LEX_CONFIG=

# The Caml compilers and auxilliaries commands.
CAML_BYT=ocamlc $(CAML_BYT_CONFIG)
CAML_BIN=ocamlopt $(CAML_BIN_CONFIG)
CAML_YAC=ocamlyacc $(CAML_YAC_CONFIG)
CAML_LEX=ocamllex $(CAML_LEX_CONFIG)
CAML_BYT_LIBR=ocamlc $(CAML_BYT_LIBR_CONFIG)
CAML_BIN_LIBR=ocamlopt $(CAML_BIN_LIBR_CONFIG)

# Tools: the pretty printer program generator
CAML_GEN=ocamlprintc

# Tools: dependancies generation.
CAML_DEP=ocamldep -slash $(CAMLC_INCLUDES)

# Tools: the moca program generator
CAML_MOCA_CONFIG=
CAML_MOCA=ocaml_moca $(CAML_MOCA_CONFIG)

# Tools: defining some macros for linking.
WITH_BYT_UNIX=unix.cma -cclib -lunix
WITH_BYT_STR=str.cma -cclib -lstr

WITH_BIN_UNIX=$(WITH_BYT_UNIX:.cma=.cmxa)
WITH_BIN_STR=$(WITH_BYT_STR:.cma=.cmxa)

# Tools: documentation generation.
CAML_DOC=ocamldoc
CAML_DOC_HTML_FLAGS=-html -d doc -v -colorize-code
CAML_DOC_LATEX_FLAGS=-latex -d doc -v

# Tools: Htmlc file generator.
# Configuration of Htmlc to generate Web pages:
# where are include files
HTMLC_CONF_INCLUDES=-I $(SRC_ROOT_DIR)/Data/Includes
# where is the configuration file for Htmlc.
HTMLC_CONF_ENV=-env $(SRC_ROOT_DIR)/Data/config.ml

HTMLC_CONF_CONFIG=-lang en $(HTMLC_CONF_ENV)

# Additional flags to set in Makefiles
HTMLC_FLAGS=-I Includes
HTMLC_CONF_FLAGS=

# Basic compilation tools
HTMLC_CONF=$(HTMLC_CONF_CONFIG) $(HTMLC_CONF_INCLUDES) $(HTMLC_CONF_FLAGS)

HTMLC=htmlc $(HTMLC_CONF) $(HTMLC_FLAGS)

# To handle banners
BH=bh
