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

# $Id: Makefile 4849 2013-04-30 18:22:49Z weis $

ROOT_DIR=../../../..
MAIN_DIR=..

include $(ROOT_DIR)/config/Config.mk
include $(MAIN_DIR)/Objs.mk

include ./Objs.mk

CAML_INCLUDES=-I +ocamlgen

CAML_BYT_CONFIG=-w A -warn-error Ae -g $(CAML_INCLUDES)
CAML_BIN_CONFIG=-w A -warn-error Ae $(CAML_INCLUDES)\
 -unsafe -noassert -inline 10000

CAML_FILES=\
 $(POLISH_CAML_FILES)\

CAML_GENERATED_FILES=\
 parser.mli parser.ml\
 lexer.ml\

BYT_OBJS=$(POLISH_BYT_OBJS)
OTHER_BYT_OBJS=\
 $(CAML_GEN_BYT_OBJS)\
 $(BASICS_BYT_OBJS)\

BIN_OBJS=$(BYT_OBJS:.cmo=.cmx)

OTHER_BIN_OBJS=$(OTHER_BYT_OBJS:.cmo=.cmx)

LINK_BYT_OBJS=$(OTHER_BYT_OBJS) $(BYT_OBJS)
LINK_BIN_OBJS=$(LINK_BYT_OBJS:.cmo=.cmx)

EXE=polish

.PHONY: exebyt exebin

default: $(EXE)

all: byt bin

byt: $(CAML_GENERATED_FILES) $(EXE).byt exebyt

bin: $(CAML_GENERATED_FILES) $(EXE).bin exebin

$(EXE).byt: $(BYT_OBJS)
	$(CAML_BYT) -o $(EXE).byt $(LINK_BYT_OBJS)

$(EXE).bin: $(BIN_OBJS)
	$(CAML_BIN) -o $(EXE).bin $(LINK_BIN_OBJS)

exebyt: $(EXE).byt
	$(CPC) $(EXE).byt $(EXE)

exebin: $(EXE).bin
	$(CPC) $(EXE).bin $(EXE)

$(EXE): $(COMPILE)

ast_print.ml: ast.mli
	$(CAML_GEN) -f ast.mli -t $@

deep_ast_print.ml: deep_ast.mli
	$(CAML_GEN) -f deep_ast.mli -t $@

splice_ast_print.ml: splice_ast.mli
	$(CAML_GEN) -f splice_ast.mli -t $@

machine_print.ml: machine.mli
	$(CAML_GEN) -f machine.mli -t $@

test::

clean::
	$(RM) $(EXE) $(EXE).b* *.output

include $(ROOT_DIR)/config/Caml.mk
