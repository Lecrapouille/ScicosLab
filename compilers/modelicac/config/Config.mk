# -*- mode : Makefile -*-
#
# Warning: this file has been generated.
#
# DO NOT EDIT THIS FILE!
#
# The editable source of this file is in Config.mk.in
#
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

# $Id: Config.mk.in 5925 2013-09-14 18:30:37Z weis $

SRC_ROOT_DIR="/usr/local/src/scicoslab-svnrepos/scicoslab-sosie/compilers"
PREFIX_INSTALL_DIR="/usr/local"
SRC_INSTALL_DIR="/usr/local/src/scicoslab-svnrepos/scicoslab-sosie/compilers"

OCAMLC="ocamlc"
OCAMLOPT="ocamlopt"
CAML_BYT_COMP_FLAGS=-strict-sequence -warn-error Ae -annot -g
CAML_BIN_COMP_FLAGS=-strict-sequence -w Ae -unsafe -noassert -inline 10000
OCAMLLIB="/usr/lib/ocaml"
OCAMLLEX="ocamllex"
OCAMLYACC="ocamlyacc"
OCAMLDEP="ocamldep"
OCAMLDEP_FLAGS=-slash
OCAMLPRINTC="ocamlprintc"
OCAMLPRINTC_FLAGS=-c
HTMLC_CONF_INCLUDES=
HTMLC_CONF_ENV=
HTMLC_FLAGS=-lang en -honor_line_continuation true
HTMLC_COMMAND="htmlc"

OCAMLVERSION="4.05.0"
OCAML_VERSION_MAJOR="4"
OCAML_VERSION_MINOR="05"

# To be done 
# ocaml_moca
# ocamldoc

include $(MAIN_DIR)/config/Params.mk
include $(MAIN_DIR)/config/Commands.mk
