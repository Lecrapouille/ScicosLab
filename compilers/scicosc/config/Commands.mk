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

# $Id: Commands.mk 6148 2013-10-09 17:32:58Z weis $

# This Makefile is a generic configuration Makefile for Caml applications.
# This Makefile is independent of the software to be built and
# defines basic Unix commands and tools for Caml compilation.

# This Makefile should be included at the beginning of the Makefile that handles
# a set of Caml files (to build a library or an application).
# Simply write at the beginning of your Makefile:
# include path_to_Config.mk/Config.mk

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

CAML_BYT_FLAGS=$(CAML_BYT_COMP_FLAGS)
CAML_BIN_FLAGS=$(CAML_BIN_COMP_FLAGS)

CAML_BYT_CONFIG=$(CAML_BYT_FLAGS) $(CAML_BYT_INCLUDES)
CAML_BIN_CONFIG=$(CAML_BIN_FLAGS) $(CAML_BIN_INCLUDES)

CAML_BYT_LIBS=
CAML_BIN_LIBS=$(CAML_BYT_LIBS:.cma=.cmxa)
CAML_BYT_LIBR_CONFIG=$(CAML_BYT_INCLUDES) -a $(CAML_BYT_LIBS)
CAML_BIN_LIBR_CONFIG=$(CAML_BIN_INCLUDES)  $(CAML_BIN_LIBS)

CAML_YAC_CONFIG=-v
CAML_LEX_CONFIG=

# The Caml compilers and auxilliaries commands.
CAML_BYT=$(OCAMLC) $(CAML_BYT_CONFIG) 
CAML_BIN=$(OCAMLOPT) $(CAML_BIN_CONFIG)
CAML_YAC=$(OCAMLYACC) $(CAML_YAC_CONFIG)
CAML_LEX=$(OCAMLLEX) $(CAML_LEX_CONFIG)
CAML_BYT_LIBR=$(CAML_BYT) $(CAML_BYT_LIBR_CONFIG)
CAML_BIN_LIBR=$(CAML_BIN) $(CAML_BIN_LIBR_CONFIG)

# Tools: the pretty printer program generator
CAML_GEN_INCLUDE=$(CAML_INCLUDES)
CAML_GEN=$(OCAMLPRINTC) $(OCAMLPRINTC_FLAGS) $(CAMLGEN_INCLUDE)

# Tools: dependancies generation.
CAML_DEP=$(OCAMLDEP) $(OCAMLDEP_FLAGS) $(CAMLC_INCLUDES)

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


# Htmlc

HTMLC_CONF=$(HTMLC_CONF_INCLUDES) $(HTMLC_CONF_ENV)
HTMLC=$(HTMLC_COMMAND) $(HTMLC_FLAGS) $(HTMLC_CONF)

# To handle banners
BH=bh

# To handle simulink files
SIMPORT_FLAGS=
SIMPORT_INCLUDES=
SIMPORT_CONFIG=$(SIMPORT_FLAGS) $(SIMPORT_INCLUDES)
SIMPORT_COMMAND=simport
SIMPORT=$(SIMPORT_COMMAND) $(SIMPORT_CONFIG)

# To browse the html documentation
BROWSER=firefox
