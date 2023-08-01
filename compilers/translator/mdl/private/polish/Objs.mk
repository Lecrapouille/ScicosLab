#*********************************************************************#
#                                                                     #
#                        SciCos compiler                              #
#                                                                     #
#            Pierre Weis                                              #
#                                                                     #
#                               INRIA Rocquencourt                    #
#                                                                     #
#  Copyright 2011 INRIA                                               #
#  Distributed only by permission.                                    #
#                                                                     #
#*********************************************************************#

# $Id: Objs.mk 5138 2013-06-27 22:52:06Z weis $

# The list of all the Caml compiled objects to make in this project.
# Each source directory has its specific make variable associated
# with the relevant list of object files.
#
# This file is shared and supposed to be included by
# each make file that needs to link and build a Caml executable.
# See below for a template of make file.

POLISH_DIR=$(MAIN_DIR)/polish

CAML_INCLUDES=\
 -I $(MAIN_DIR)/basics\
 -I +ocamlgen\

POLISH_BYT_OBJS=\
 $(POLISH_DIR)/ast_print.cmo\
 $(POLISH_DIR)/ast_pprint.cmo\
 $(POLISH_DIR)/lexer.cmo\
 $(POLISH_DIR)/parser.cmo\
 $(POLISH_DIR)/scoping.cmo\
 $(POLISH_DIR)/transl.cmo\
 $(POLISH_DIR)/deep_ast_print.cmo\
 $(POLISH_DIR)/deep_ast_pprint.cmo\
 $(POLISH_DIR)/splice_ast_print.cmo\
 $(POLISH_DIR)/splice_ast_pprint.cmo\
 $(POLISH_DIR)/splicing.cmo\
 $(POLISH_DIR)/machine_print.cmo\
 $(POLISH_DIR)/exec.cmo\
 $(POLISH_DIR)/compile.cmo\
 $(POLISH_DIR)/polish.cmo\
 $(POLISH_DIR)/print_polish.cmo\
 $(POLISH_DIR)/treat_polish.cmo\
 $(POLISH_DIR)/main_polish.cmo\

POLISH_CAML_FILES=\
 $(POLISH_DIR)/ast.mli\
 $(POLISH_DIR)/deep_ast_pprint.mli\
 $(POLISH_DIR)/scoping.mli\
 $(POLISH_DIR)/deep_ast.mli\
 $(POLISH_DIR)/splice_ast_pprint.mli\
 $(POLISH_DIR)/machine.mli\
 $(POLISH_DIR)/treat_polish.mli\
 $(POLISH_BYT_OBJS:.cmo=.ml)\
